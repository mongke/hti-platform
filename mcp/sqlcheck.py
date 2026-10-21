"""Read-only SQL for run_sql, confined to the curated datasets (2026-10-14).

The statement is PARSED (sqlglot, Spark dialect), never pattern-matched, and checked
against catalog/datasets.json:

  * exactly one SELECT (WITH / UNION allowed); anything else is refused
  * tables: silver.<curated dataset> or a CTE defined in the statement; no other
    layer, catalog, file path or table function
  * columns: approved fields of the referenced datasets, or aliases the query
    defines; no bare * (COUNT(*) is fine); a table's row key `id` only inside JOIN ... ON
  * count_distinct fields (people, households, cars, cards, record ids) only as
    COUNT(DISTINCT field) or as a JOIN ... ON key - never selected, filtered, grouped or ordered
  * functions: an allowlist of aggregate, date, math, string and conditional ones
  * the outer query must aggregate (GROUP BY, or only aggregate expressions)
  * cost limits (OWASP MCP guide s.3): <= MAX_SQL_CHARS characters, <= MAX_TABLES table
    references, every JOIN has ON/USING (no comma or CROSS joins), <= MAX_UNION parts,
    subqueries nested <= MAX_DEPTH; the server also cancels any query after a timeout

It then REWRITES the outer SELECT(s): HAVING COUNT(*) >= K_MIN, plus a distinct-person
condition when the outer query reads a dataset directly, and LIMIT <= max_rows.
The result is plain Spark SQL; the server still runs its own guard over it.
"""
from __future__ import annotations

import sqlglot
from sqlglot import exp

ALLOWED_FUNCS = {
    "COUNT", "SUM", "AVG", "MIN", "MAX", "STDDEV", "STDDEV_SAMP", "STDDEV_POP", "VARIANCE",
    "VARIANCE_POP", "COUNT_IF", "APPROX_DISTINCT", "APPROX_QUANTILE", "MEDIAN",
    "ROUND", "ABS", "FLOOR", "CEIL", "GREATEST", "LEAST", "SAFE_DIVIDE", "MOD", "POW", "SQRT", "LN", "LOG",
    "COALESCE", "NULLIF", "IF", "CASE", "CAST", "TRY_CAST",
    "TIMESTAMP_TRUNC", "DATE_TRUNC", "YEAR", "MONTH", "DAY", "QUARTER", "WEEK", "WEEK_OF_YEAR",
    "DAY_OF_WEEK", "DAY_OF_MONTH", "DAY_OF_YEAR", "HOUR", "DATEDIFF", "DATE_DIFF", "DATE_ADD", "DATE_SUB",
    "TS_OR_DS_TO_DATE", "TO_DATE", "STR_TO_DATE", "CURRENT_DATE", "CURRENT_TIMESTAMP", "MONTHS_BETWEEN",
    "TIME_TO_STR", "LAST_DAY", "ADD_MONTHS",
    "LOWER", "UPPER", "TRIM", "LENGTH", "SUBSTRING", "CONCAT", "LEFT", "RIGHT",
}
ALLOWED_ANON = {"percentile_approx", "approx_count_distinct", "date_format", "weekofyear", "dayofweek",
                "dayofmonth", "dayofyear", "nvl", "ifnull", "trunc", "make_date", "try_divide"}
_DENY_NODES = tuple(t for t in (getattr(exp, n, None) for n in (
    "Insert", "Update", "Delete", "Merge", "Create", "Drop", "Alter", "AlterTable", "Command", "Set",
    "Use", "Describe", "Show", "Pragma", "Cache", "Uncache", "LoadData", "Transaction", "Commit",
    "Rollback", "Grant", "TruncateTable", "Lateral", "Unnest", "Explode", "Pivot",
    # Window functions look aggregate but return one value PER ROW.
    "Window")) if t is not None)


MAX_SQL_CHARS, MAX_TABLES, MAX_UNION, MAX_DEPTH = 5000, 4, 4, 3


class Refused(ValueError):
    """A client-facing reason; never contains SQL from the platform."""


def _datasets_of(tree: exp.Expression, datasets: dict, ctes: set[str]) -> dict[str, str]:
    """alias-or-name -> dataset name, for every curated table referenced."""
    seen: dict[str, str] = {}
    for t in tree.find_all(exp.Table):
        name, db, cat = t.name, t.db, t.catalog
        if not db and not cat and name.lower() in ctes:
            continue
        if cat or db.lower() != "silver" or name.lower() not in datasets or not isinstance(t.this, exp.Identifier):
            raise Refused(f"table {'.'.join(p for p in (cat, db, name) if p)!s} is not queryable; "
                          "use silver.<dataset> from list_tables")
        seen[(t.alias_or_name or name).lower()] = name.lower()
        seen[name.lower()] = name.lower()
    if not seen:
        raise Refused("the query must read at least one silver.<dataset>")
    return seen


def _is_agg(e: exp.Expression) -> bool:
    return e.find(exp.AggFunc) is not None


def _limits(tree: exp.Expression) -> None:
    if len([t for t in tree.find_all(exp.Table)]) > MAX_TABLES:
        raise Refused(f"at most {MAX_TABLES} table references per query")
    for j in tree.find_all(exp.Join):
        if (j.args.get("kind") or "").upper() == "CROSS" or not (j.args.get("on") or j.args.get("using")):
            raise Refused("every JOIN needs an ON or USING condition (no comma or CROSS joins)")
    if len([u for u in tree.find_all(exp.Union)]) >= MAX_UNION:
        raise Refused(f"at most {MAX_UNION} UNION parts")
    for sub in tree.find_all(exp.Subquery):
        depth, node = 0, sub
        while node is not None:
            depth += isinstance(node, exp.Subquery)
            node = node.parent
        if depth > MAX_DEPTH:
            raise Refused(f"subqueries nested at most {MAX_DEPTH} deep")


def check(sql: str, datasets: dict, k_min: int, max_rows: int) -> str:
    if not isinstance(sql, str) or len(sql) > MAX_SQL_CHARS:
        raise Refused(f"the query must be text of at most {MAX_SQL_CHARS} characters")
    try:
        stmts = [s for s in sqlglot.parse(sql, read="spark") if s is not None]
    except sqlglot.errors.ParseError as err:
        raise Refused(f"could not parse the query: {str(err).splitlines()[0][:160]}") from None
    if len(stmts) != 1:
        raise Refused("exactly one statement")
    tree = stmts[0]
    if not isinstance(tree, (exp.Select, exp.Union)):
        raise Refused("only SELECT queries are allowed (read-only)")
    if _DENY_NODES and tree.find(*_DENY_NODES):
        raise Refused("only plain SELECT queries are allowed (read-only)")

    _limits(tree)
    ctes = {c.alias_or_name.lower() for c in tree.find_all(exp.CTE)}
    refs = _datasets_of(tree, datasets, ctes)
    used = {d: datasets[d]["fields"] for d in set(refs.values())}
    allowed = {f.lower() for fields in used.values() for f in fields}
    tokens = {f.lower() for fields in used.values() for f, v in fields.items() if v["role"] == "count_distinct"}
    aliases = {a.alias.lower() for a in tree.find_all(exp.Alias) if a.alias} | ctes | \
              {c.lower() for cte in tree.find_all(exp.CTE) for c in (cte.args.get("alias").columns
               if cte.args.get("alias") and cte.args.get("alias").columns else [])}

    for f in tree.find_all(exp.Func):
        if isinstance(f, exp.Anonymous):
            if f.name.lower() not in ALLOWED_ANON:
                raise Refused(f"function {f.name} is not allowed")
        elif f.sql_name() not in ALLOWED_FUNCS:
            raise Refused(f"function {f.sql_name().lower()} is not allowed")

    for s in tree.find_all(exp.Star):
        if not isinstance(s.parent, exp.Count):
            raise Refused("SELECT * is not allowed; name the fields (describe_table shows them)")

    for col in tree.find_all(exp.Column):
        name = col.name.lower()
        if isinstance(col.this, exp.Star):
            raise Refused("table.* is not allowed; name the fields")
        # Joining two tables on a token (e.g. sma_users.id = sma_useractionlogs.userId) shows
        # no value, so token columns may also appear inside JOIN ... ON (2026-10-21).
        if name in tokens and isinstance(col.find_ancestor(exp.Select, exp.Join), exp.Join):
            eq = col.parent
            if not (isinstance(eq, exp.EQ) and isinstance(eq.left, exp.Column) and isinstance(eq.right, exp.Column)):
                raise Refused(f"{col.name} may appear in JOIN ... ON only as column = column")
            continue
        if name in tokens:
            if not (isinstance(col.parent, exp.Distinct) and isinstance(col.parent.parent, exp.Count)
                    and len(col.parent.expressions) == 1):
                raise Refused(f"{col.name} identifies people or records: use it only as COUNT(DISTINCT {col.name})")
            continue
        # Row keys may link tables inside JOIN ... ON, and nowhere else.
        if name == "id" and isinstance(col.find_ancestor(exp.Select, exp.Join), exp.Join):
            continue
        if name not in allowed and name not in aliases:
            raise Refused(f"field {col.name} is not available; describe_table lists the approved fields")

    outers = [tree] if isinstance(tree, exp.Select) else [s for s in tree.find_all(exp.Select)
                                                          if not s.find_ancestor(exp.Subquery, exp.CTE)]
    for sel in outers:
        group = sel.args.get("group")
        grouped = {g.sql().lower() for g in (group.expressions if group else [])}
        for i, p in enumerate(sel.expressions, 1):
            inner = p.this if isinstance(p, exp.Alias) else p
            if _is_agg(inner) or isinstance(inner, exp.Literal):
                continue
            if not group or (inner.sql().lower() not in grouped and str(i) not in grouped):
                raise Refused("aggregates only: every selected value must be aggregated or in GROUP BY")
        # Small-cell suppression on the outer level.
        sel.having(f"COUNT(*) >= {k_min}", dialect="spark", copy=False)
        from_tables = [t for t in sel.find_all(exp.Table) if t.find_ancestor(exp.Select) is sel]
        if from_tables and all(t.name.lower() in datasets for t in from_tables):
            for t in from_tables:
                person = datasets[t.name.lower()].get("person_fields") or []
                if not person:
                    continue
                q = t.alias_or_name
                who = ", ".join(f"`{q}`.`{p}`" for p in person)
                who = f"COALESCE({who})" if len(person) > 1 else who
                sel.having(f"(COUNT(DISTINCT {who}) = 0 OR COUNT(DISTINCT {who}) >= {k_min})", dialect="spark", copy=False)

    limit = tree.args.get("limit")
    n = None
    if limit is not None:
        try:
            n = int(limit.expression.name)
        except (AttributeError, ValueError):
            raise Refused("LIMIT must be a number") from None
    tree.limit(min(n or max_rows, max_rows), copy=False)
    return tree.sql(dialect="spark")

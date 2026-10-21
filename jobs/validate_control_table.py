#!/usr/bin/env python3
# =============================================================================
# hti-platform/jobs/validate_control_table.py                         NEW FILE
#
# Enforces the CLAUDE.md section 4 copy-in rules against jobs/control_table.csv
# BEFORE any loader reads it. Section 4 requires the privacy rules to live "in
# code, not in prompts"; this is that code for the allowlist.
#
# The control table is an ALLOWLIST: a table/column absent from it is not
# copied. This validator does not decide what may be copied - the data officer
# does, by signing the file. It only refuses files that contradict the policy.
#
# Usage:
#   python3 jobs/validate_control_table.py jobs/control_table.csv
#   python3 jobs/validate_control_table.py jobs/control_table.csv --warnings-as-errors
#
# Waivers are read from control_table_exceptions.csv beside the control table
# unless --exceptions says otherwise.
#
# Exit codes:  0 = clean   1 = policy violations found   2 = unusable input
#
# Stdlib only, so it runs with the system python3, inside apache/spark:3.5.7,
# and in CI, with no install step.
#
# NOTE ON COMPLETENESS: the pattern lists below are a floor, not a ceiling, and
# they are English-biased. esukh column names may be Mongolian or transliterated
# (нэр / утас / регистр ...). A clean run means "nothing known-forbidden was
# found", never "this file is safe to load" - only the data officer's signature
# means that. Extending PATTERNS is a data-officer decision; see section 9.
#
# MATCHING IS BY SUBSTRING, AND FAILS CLOSED. An earlier version matched whole
# tokens, which kept false positives down but missed every name esukh writes
# without separators: on the real schema it found 4 correspondence tables where
# substring matching finds 64 ("forumfiles", "postcomment", "messagerecieved"
# all tokenise as single words). For a privacy control that is the wrong way to
# be wrong - a false positive costs one review, a false negative copies personal
# data - so this now over-detects by design.
#
# Over-detection is made workable by an EXCEPTIONS FILE rather than by weakening
# the patterns. "filename" and "postal_code" WILL be flagged; the data officer
# clears each one in jobs/control_table_exceptions.csv with a written
# justification and their name. That file is the review record: the friction is
# the point, and nothing is waved through silently.
# =============================================================================
from __future__ import annotations

import argparse
import csv
import re
import sys
from dataclasses import dataclass, replace
from enum import Enum
from pathlib import Path
from typing import Final, Iterator, Sequence

# ---- control table format ---------------------------------------------------
# Column order is fixed so a diff of the signed file stays reviewable.
REQUIRED_COLUMNS: Final[tuple[str, ...]] = (
    "source_system",
    "source_table",
    "target_layer",
    "load_mode",
    "primary_key",
    "watermark_column",
    "columns_allowlist",
    "purpose_ref",
)

# columns_allowlist holds many values in one CSV cell; "," is taken by CSV and
# ";" reads as a sentence break, so "|" it is.
ALLOWLIST_SEPARATOR: Final[str] = "|"

VALID_TARGET_LAYERS: Final[frozenset[str]] = frozenset({"bronze", "bronze-ref"})
VALID_LOAD_MODES: Final[frozenset[str]] = frozenset({"incremental", "full"})

# ---- policy pattern lists (section 4) ---------------------------------------
# Matched as SUBSTRINGS of the identifier with separators removed, so "user_name",
# "userName" and "username" all trip "name", and "forumfiles" trips "forum".
# Plurals and separator variants therefore need no separate entries.
# Bare "tel" is deliberately absent - it would match "hotel" and "telemetry",
# while "phone"/"telephone" already cover the real cases.
IDENTITY_PATTERNS: Final[frozenset[str]] = frozenset({
    "name", "surname", "phone", "telephone", "mobile", "msisdn",
    "email", "mail", "register", "regno", "nationalid", "ssn", "passport",
    # Images of people, added 2026-09-30. A photograph identifies a person and
    # cannot be meaningfully tokenised, so it is dropped like a name.
    # This deliberately over-matches: logoImage / bgImage / stampImage / qrImage
    # / townImage are organisation branding and are cleared by waiver. The ones
    # that matter are esukh.user.image, sma.avatarUrl, esukh.picture_data and
    # parkly.inImageName / outImageName - ANPR gate captures, i.e. a photo of a
    # vehicle and its plate at a known time and place.
    "image", "avatar", "photo", "picture",
    # Mongolian forms seen in HTI systems; extend under data-officer review.
    "нэр", "утас", "имэйл", "регистр",
})

FREE_TEXT_PATTERNS: Final[frozenset[str]] = frozenset({
    "note", "comment", "remark", "message", "body", "content", "feedback",
    "complain", "desc", "reason", "answer", "question", "text", "title",
    "subject",
    # "desc" not "descr": esukh has bare `desc` columns (branchinvoicepayment,
    # propertyprivateconfig, cost) that "descr" missed. Found while picking demo
    # tables from the real schema - exactly the kind of gap that stays invisible
    # until the patterns meet a real database.
})

# Secrets. A password, PIN, API token or bank account number has no analytical
# use, so nothing in this platform may copy one. Added 2026-09-30 after the
# first esukh draft was found to allow 25 such columns across 18 tables
# (user.loginPass, town.stateBankTransLoginPass, khanToken, bankAccountNumber
# and more) - the validator had no credential rule at all, so it passed them.
#
# "pin" is a substring risk in principle ("shipping", "mapping") but matched
# nothing but tranPin and pin across all four HTI schemas when checked.
# CT018 is waivable only because of that class of false positive - token
# METADATA such as tokenDate/tokenVersion/tokenExpired is not itself a secret.
# Waiving an actual secret is never correct.
CREDENTIAL_PATTERNS: Final[frozenset[str]] = frozenset({
    "password", "passwd", "loginpass", "secret", "apikey", "privatekey",
    "credential", "token", "hash", "pin",
    # Verification codes. Spelled out rather than matching "validate"/"verif",
    # which would wrongly flag validatedDate and isVerified - those are metadata,
    # not the secret. Found 2026-09-30: esukh.user.validateCode and
    # parkly.verificationCode were both being copied.
    "validatecode", "verificationcode", "activationcode", "confirmcode",
    # Bank details. "bankaccount" alone missed smartpay.transactionBucket
    # .accountNumber and parkly.accountHolder; "account" alone would wrongly
    # flag accountId foreign keys and accountType metadata, so the patterns are
    # deliberately narrow. Found 2026-09-30 while choosing smartpay demo tables.
    "bankaccount", "accountnumber", "accountholder",
    # API request signatures (HMAC keys). Found 2026-10-14: parkly.camera
    # add/delete/select/getRecordSignature were reaching silver in plaintext.
    "signature",
})

CORRESPONDENCE_PATTERNS: Final[frozenset[str]] = frozenset({
    "forum", "chat", "message", "comment", "complain", "post", "news",
    "feedback", "note", "poll", "answer", "question", "help", "massmail",
    "notification", "support", "ticket", "inbox", "conversation", "reply",
    "review", "advertise", "internalad",
})


# Personal attributes that policy section 4 does not list as never-copied, but
# which cannot go to gold as-is: a birth date needs an age band the way an exact
# timestamp needs an hour band, and lat/long needs a location group the way an
# address does. Bronze may hold them so silver can transform them - so this is a
# WARNING, not an error. Added 2026-09-30: sma.Agents (gender, birthDate) and
# sma.Parks (latitude, longitude) passed every existing check silently.
# Bare "lat"/"lng" are deliberately absent - they would match "related",
# "translate", "late"; no schema here uses them unspelled.
BANDING_PATTERNS: Final[frozenset[str]] = frozenset({
    "gender", "birth", "latitude", "longitude",
})


# Tables whose entire purpose is to hold a secret. Matched on the TABLE name
# because the column often cannot be: esukh.otpv2 stores the passcode in a
# column called `code`, and "code" is far too generic to block (bankCode,
# serviceCode, vatDistrictCode are all legitimate). A credential store has no
# analytical value, so the whole table is refused.
# Added 2026-09-30: esukh.otp and esukh.otpv2 were both in the allowlist with
# `code` included - live one-time passcodes, one row from bronze.
# "session" is deliberately absent: a parking-session table is analytics data,
# not a credential store, and would be the exact false positive that matters.
CREDENTIAL_TABLE_PATTERNS: Final[frozenset[str]] = frozenset({
    "otp", "token", "passwordreset", "userpin", "apikey", "secret", "credential",
})


class Severity(Enum):
    ERROR = "ERROR"
    WARNING = "WARNING"


# Only the three policy rules may be waived. Structural rules (a PK that is not
# copied, a duplicate row, incremental without a watermark) are bugs, not
# judgement calls, so there is deliberately no way to sign them off.
WAIVABLE_RULES: Final[frozenset[str]] = frozenset({"CT014", "CT015", "CT016", "CT018", "CT019"})

EXCEPTIONS_COLUMNS: Final[tuple[str, ...]] = (
    "source_system", "source_table", "column", "rule", "justification", "approved_by",
)


@dataclass(frozen=True)
class Waiver:
    line: int
    justification: str
    approved_by: str


@dataclass(frozen=True)
class Violation:
    line: int          # 1-based line in the CSV, header included
    rule: str
    field: str
    message: str
    severity: Severity
    # (system, table, column, rule); column is "" for table-level rules. Set only
    # on waivable rules, so nothing else can be signed away by accident.
    waiver_key: tuple[str, str, str, str] | None = None

    def render(self) -> str:
        return f"{self.severity.value:7} line {self.line:>4}  {self.rule}  {self.field}: {self.message}"


@dataclass(frozen=True)
class ControlRow:
    line: int
    source_system: str
    source_table: str
    target_layer: str
    load_mode: str
    primary_key: str
    watermark_column: str
    columns_allowlist: tuple[str, ...]
    purpose_ref: str

    @property
    def key(self) -> tuple[str, str]:
        return (self.source_system.lower(), self.source_table.lower())


_SEPARATORS: Final[re.Pattern[str]] = re.compile(r"[^0-9A-Za-zЀ-ӿ]+")


def _normalise(identifier: str) -> str:
    """Lowercase an identifier and strip every separator.

    "user_name", "userName" and "username" all collapse to "username", so one
    pattern covers every spelling the app happens to use. Cyrillic is preserved.
    """
    return _SEPARATORS.sub("", identifier.lower())


def _forbidden_hits(identifier: str, vocabulary: frozenset[str]) -> tuple[str, ...]:
    """Every pattern appearing anywhere in the normalised identifier.

    Substring, not token: this is the fail-closed half of the control.
    """
    normalised = _normalise(identifier)
    return tuple(sorted(pattern for pattern in vocabulary if pattern in normalised))


def parse_rows(path: Path) -> tuple[tuple[ControlRow, ...], tuple[Violation, ...]]:
    """Read the CSV. Returns parsed rows plus any structural violations.

    Structural problems (bad header, wrong field count) stop row parsing for the
    affected row only - we want every violation in one pass, not the first.
    """
    violations: list[Violation] = []
    rows: list[ControlRow] = []

    with path.open(newline="", encoding="utf-8") as handle:
        reader = csv.reader(handle)
        try:
            header = next(reader)
        except StopIteration:
            violations.append(Violation(1, "CT001", "header", "file is empty", Severity.ERROR))
            return (), tuple(violations)

        actual = tuple(column.strip() for column in header)
        if actual != REQUIRED_COLUMNS:
            violations.append(Violation(
                1, "CT001", "header",
                f"expected exactly {list(REQUIRED_COLUMNS)}, got {list(actual)}",
                Severity.ERROR,
            ))
            # Field positions are unknown from here on; parsing rows would invent data.
            return (), tuple(violations)

        for values in reader:
            line = reader.line_num
            if not any(value.strip() for value in values):
                continue  # blank separator line
            if len(values) != len(REQUIRED_COLUMNS):
                violations.append(Violation(
                    line, "CT002", "row",
                    f"expected {len(REQUIRED_COLUMNS)} fields, got {len(values)}",
                    Severity.ERROR,
                ))
                continue
            cleaned = [value.strip() for value in values]
            allowlist = tuple(
                item.strip()
                for item in cleaned[6].split(ALLOWLIST_SEPARATOR)
                if item.strip()
            )
            rows.append(ControlRow(
                line=line,
                source_system=cleaned[0],
                source_table=cleaned[1],
                target_layer=cleaned[2],
                load_mode=cleaned[3],
                primary_key=cleaned[4],
                watermark_column=cleaned[5],
                columns_allowlist=allowlist,
                purpose_ref=cleaned[7],
            ))

    return tuple(rows), tuple(violations)


def load_waivers(path: Path) -> tuple[dict[tuple[str, str, str, str], Waiver], tuple[Violation, ...]]:
    """Read the exceptions file. Missing file is fine - it means no waivers."""
    waivers: dict[tuple[str, str, str, str], Waiver] = {}
    problems: list[Violation] = []
    if not path.is_file():
        return waivers, ()

    with path.open(newline="", encoding="utf-8") as handle:
        reader = csv.reader(handle)
        try:
            header = next(reader)
        except StopIteration:
            return waivers, ()
        if tuple(column.strip() for column in header) != EXCEPTIONS_COLUMNS:
            problems.append(Violation(
                1, "CT103", "exceptions",
                f"{path.name}: expected header {list(EXCEPTIONS_COLUMNS)}",
                Severity.ERROR,
            ))
            return {}, tuple(problems)

        for values in reader:
            line = reader.line_num
            if not any(value.strip() for value in values):
                continue
            if len(values) != len(EXCEPTIONS_COLUMNS):
                problems.append(Violation(line, "CT103", "exceptions",
                                          f"{path.name}: expected {len(EXCEPTIONS_COLUMNS)} fields, "
                                          f"got {len(values)}", Severity.ERROR))
                continue
            system, table, column, rule, justification, approved_by = (v.strip() for v in values)
            if rule not in WAIVABLE_RULES:
                problems.append(Violation(line, "CT104", "exceptions",
                                          f"{path.name}: rule '{rule}' cannot be waived "
                                          f"(waivable: {sorted(WAIVABLE_RULES)})", Severity.ERROR))
                continue
            # An unjustified or unattributed waiver is not a review record.
            if not justification:
                problems.append(Violation(line, "CT105", "exceptions",
                                          f"{path.name}: justification is required", Severity.ERROR))
                continue
            if not approved_by:
                problems.append(Violation(line, "CT105", "exceptions",
                                          f"{path.name}: approved_by is required", Severity.ERROR))
                continue
            waivers[(system.lower(), table.lower(), column.lower(), rule)] = Waiver(
                line=line, justification=justification, approved_by=approved_by,
            )
    return waivers, tuple(problems)


def validate_row(row: ControlRow) -> Iterator[Violation]:
    def error(rule: str, field: str, message: str) -> Violation:
        return Violation(row.line, rule, field, message, Severity.ERROR)

    if not row.source_system:
        yield error("CT003", "source_system", "must not be empty")
    if not row.source_table:
        yield error("CT003", "source_table", "must not be empty")

    if row.target_layer not in VALID_TARGET_LAYERS:
        yield error("CT004", "target_layer",
                    f"'{row.target_layer}' is not one of {sorted(VALID_TARGET_LAYERS)}")
    if row.load_mode not in VALID_LOAD_MODES:
        yield error("CT005", "load_mode",
                    f"'{row.load_mode}' is not one of {sorted(VALID_LOAD_MODES)}")

    # Incremental MERGE (N3) needs both a key to merge on and a column to advance.
    if row.load_mode == "incremental":
        if not row.primary_key:
            yield error("CT006", "primary_key", "required when load_mode=incremental")
        if not row.watermark_column:
            yield error("CT007", "watermark_column", "required when load_mode=incremental")
    elif row.load_mode == "full" and row.watermark_column:
        yield Violation(row.line, "CT101", "watermark_column",
                        "set but load_mode=full, so it is ignored - drop it or "
                        "switch to incremental", Severity.WARNING)

    if not row.columns_allowlist:
        yield error("CT008", "columns_allowlist",
                    "must not be empty - this is an allowlist, an empty cell copies nothing")
    if any(column == "*" for column in row.columns_allowlist):
        yield error("CT009", "columns_allowlist",
                    "'*' is not permitted - section 4 requires columns named explicitly, so "
                    "new columns from app migrations do not flow until approved")

    seen: set[str] = set()
    for column in row.columns_allowlist:
        lowered = column.lower()
        if lowered in seen:
            yield error("CT010", "columns_allowlist", f"'{column}' listed more than once")
        seen.add(lowered)

    # A key we merge on, or a watermark we advance, must actually be copied.
    if row.primary_key and row.primary_key.lower() not in seen:
        yield error("CT011", "primary_key",
                    f"'{row.primary_key}' is not in columns_allowlist, so it would not be copied")
    if row.watermark_column and row.watermark_column.lower() not in seen:
        yield error("CT012", "watermark_column",
                    f"'{row.watermark_column}' is not in columns_allowlist, so it would not be copied")

    # Policy step 1: no purpose, no copy.
    if not row.purpose_ref:
        yield error("CT013", "purpose_ref",
                    "required - every copied table needs a purpose register entry (policy step 1)")

    # ---- section 4: never copied at all ----
    store_hits = _forbidden_hits(row.source_table, CREDENTIAL_TABLE_PATTERNS)
    if store_hits:
        yield Violation(row.line, "CT019", "source_table",
                        f"matched {list(store_hits)} - this table exists to hold secrets "
                        "(one-time codes, API tokens, PINs). It has no analytical value and is "
                        "never copied, whatever its columns are called",
                        Severity.ERROR,
                        (row.source_system.lower(), row.source_table.lower(), "", "CT019"))

    table_hits = _forbidden_hits(row.source_table, CORRESPONDENCE_PATTERNS)
    if table_hits:
        yield Violation(row.line, "CT014", "source_table",
                        f"looks like a correspondence table (matched {list(table_hits)}); "
                        "content is sensitive under policy 4.1.4 and is never copied",
                        Severity.ERROR,
                        (row.source_system.lower(), row.source_table.lower(), "", "CT014"))

    for column in row.columns_allowlist:
        credential_hits = _forbidden_hits(column, CREDENTIAL_PATTERNS)
        # "pass" as a substring would flag passport/passenger/isPassed, so only a
        # name ENDING in it counts. Found 2026-10-14: parkly.camera.pass and
        # routerConfig.routerPass/anydeskPass held plaintext device passwords.
        if not credential_hits and _normalise(column).endswith("pass"):
            credential_hits = ("*pass",)
        if credential_hits:
            yield Violation(row.line, "CT018", "columns_allowlist",
                            f"'{column}' matched {list(credential_hits)} - looks like a stored "
                            "secret (password, PIN, API token, bank account). Secrets have no "
                            "analytical use and must never be copied to any layer. Waive ONLY if "
                            "this is token metadata such as a version or expiry date, never the "
                            "secret itself",
                            Severity.ERROR,
                            (row.source_system.lower(), row.source_table.lower(),
                             column.lower(), "CT018"))

        identity_hits = _forbidden_hits(column, IDENTITY_PATTERNS)
        if identity_hits:
            yield Violation(row.line, "CT015", "columns_allowlist",
                            f"'{column}' matched {list(identity_hits)} - names, phones, emails, "
                            "register numbers and photographs of people are never copied; they are "
                            "dropped, not tokenised",
                            Severity.ERROR,
                            (row.source_system.lower(), row.source_table.lower(),
                             column.lower(), "CT015"))
        banding_hits = _forbidden_hits(column, BANDING_PATTERNS)
        if banding_hits:
            yield Violation(row.line, "CT106", "columns_allowlist",
                            f"'{column}' matched {list(banding_hits)} - a personal attribute that "
                            "must be banded or grouped before gold (birth date -> age band, "
                            "lat/long -> location group). Permitted in bronze so silver can "
                            "transform it; confirm the transform exists with the data officer",
                            Severity.WARNING)

        free_text_hits = _forbidden_hits(column, FREE_TEXT_PATTERNS)
        if free_text_hits:
            yield Violation(row.line, "CT016", "columns_allowlist",
                            f"'{column}' matched {list(free_text_hits)} - free-text fields are never "
                            "copied; if this column is not free text, waive it in the exceptions "
                            "file with a justification",
                            Severity.ERROR,
                            (row.source_system.lower(), row.source_table.lower(),
                             column.lower(), "CT016"))


def validate_table(rows: Sequence[ControlRow]) -> Iterator[Violation]:
    first_seen: dict[tuple[str, str], int] = {}
    for row in rows:
        previous = first_seen.get(row.key)
        if previous is not None:
            yield Violation(row.line, "CT017", "source_table",
                            f"duplicate of {row.source_system}.{row.source_table} "
                            f"already defined on line {previous}", Severity.ERROR)
        else:
            first_seen[row.key] = row.line


def validate(path: Path, exceptions_path: Path) -> tuple[Violation, ...]:
    rows, violations = parse_rows(path)
    collected = list(violations)
    for row in rows:
        collected.extend(validate_row(row))
    collected.extend(validate_table(rows))

    waivers, waiver_problems = load_waivers(exceptions_path)
    collected.extend(waiver_problems)

    applied: set[tuple[str, str, str, str]] = set()
    resolved: list[Violation] = []
    for violation in collected:
        key = violation.waiver_key
        if key is not None and key in waivers:
            waiver = waivers[key]
            applied.add(key)
            resolved.append(replace(
                violation,
                severity=Severity.WARNING,
                message=f"{violation.message}  [waived line {waiver.line} by "
                        f"{waiver.approved_by}: {waiver.justification}]",
            ))
        else:
            resolved.append(violation)

    # A waiver that matches nothing is stale - it hides nothing today, but it
    # will silently pre-approve a future row that happens to match.
    for key, waiver in sorted(waivers.items(), key=lambda item: item[1].line):
        if key not in applied:
            system, table, column, rule = key
            target = f"{system}.{table}" + (f".{column}" if column else "")
            resolved.append(Violation(
                waiver.line, "CT102", "exceptions",
                f"waiver for {target} / {rule} matched nothing - remove it",
                Severity.WARNING,
            ))

    resolved.sort(key=lambda violation: (violation.line, violation.rule))
    return tuple(resolved)


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Validate jobs/control_table.csv against the CLAUDE.md section 4 copy-in rules.",
    )
    parser.add_argument("control_table", type=Path, help="path to control_table.csv")
    parser.add_argument("--warnings-as-errors", action="store_true",
                        help="exit non-zero on warnings too (use in CI)")
    parser.add_argument("--exceptions", type=Path, default=None,
                        help="signed waivers (default: control_table_exceptions.csv "
                             "beside the control table)")
    args = parser.parse_args(argv)

    path: Path = args.control_table
    if not path.is_file():
        print(f"error: {path} is not a file", file=sys.stderr)
        return 2

    exceptions_path: Path = (
        args.exceptions if args.exceptions is not None
        else path.with_name("control_table_exceptions.csv")
    )

    try:
        violations = validate(path, exceptions_path)
    except UnicodeDecodeError as exc:
        print(f"error: {path} is not valid UTF-8: {exc}", file=sys.stderr)
        return 2
    except csv.Error as exc:
        print(f"error: {path} is not readable as CSV: {exc}", file=sys.stderr)
        return 2

    errors = [v for v in violations if v.severity is Severity.ERROR]
    warnings = [v for v in violations if v.severity is Severity.WARNING]

    for violation in violations:
        print(violation.render())

    waived = sum(1 for v in warnings if "[waived line " in v.message)
    print(f"\n{path}: {len(errors)} error(s), {len(warnings)} warning(s)"
          + (f", {waived} waived" if waived else ""))
    if exceptions_path.is_file():
        print(f"waivers read from {exceptions_path}")
    if errors:
        print("REJECTED - do not load this control table.")
        return 1
    if warnings and args.warnings_as_errors:
        print("REJECTED - warnings treated as errors.")
        return 1
    print("No known-forbidden entries found. This is not a substitute for the "
          "data officer's signature (see section 9).")
    return 0


if __name__ == "__main__":
    sys.exit(main())

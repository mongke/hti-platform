-- =============================================================================
-- hti-platform/tokenmap/schema.sql                                    NEW FILE
--
-- N4 token map. Loaded at volume init, before anything can connect.
--
-- THIS TABLE IS THE MOST SENSITIVE OBJECT ON THE PLATFORM. It is the only place
-- where a token can be reversed to the real plate or user id, so it holds the
-- personal data that silver and gold are designed not to. Hence: a separate
-- instance, separate credentials, no route from dbt/BI/humans, and pgAudit (N10).
--
-- PER-SYSTEM BY DEFAULT. The unique key includes source_system, so the same
-- plate in esukh and parkly gets DIFFERENT tokens and cannot be joined across
-- systems. Cross-system linking is a data-officer decision (section 9) and
-- would mean a deliberate schema change here, not a config flag.
-- =============================================================================

CREATE TABLE token_map (
    source_system   text        NOT NULL,
    entity_type     text        NOT NULL,   -- 'property', 'user', 'plate', ...
    natural_value   text        NOT NULL,   -- the real value; this is the PII
    token           uuid        NOT NULL DEFAULT gen_random_uuid(),
    created_at      timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT token_map_pk PRIMARY KEY (source_system, entity_type, natural_value),
    CONSTRAINT token_map_token_uniq UNIQUE (source_system, entity_type, token)
);

-- Reverse lookup, for a lawful re-identification request only.
CREATE INDEX token_map_by_token ON token_map (source_system, entity_type, token);

-- Staging table the tokenise job bulk-loads into, then upserts from. Separate
-- so the job never needs INSERT on token_map's natural key directly from Spark.
CREATE TABLE token_stage (
    source_system   text NOT NULL,
    entity_type     text NOT NULL,
    natural_value   text NOT NULL
);
CREATE INDEX token_stage_lookup ON token_stage (source_system, entity_type);

-- The tokenise job's account: it must be able to mint new tokens and read them
-- back, and nothing else. No DELETE, no UPDATE - a token must never change, or
-- every silver row referring to it silently re-points to a different person.
CREATE ROLE tokenise_job LOGIN;
GRANT SELECT, INSERT ON token_map  TO tokenise_job;
GRANT SELECT, INSERT, DELETE ON token_stage TO tokenise_job;   -- DELETE: clears its own staging rows
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

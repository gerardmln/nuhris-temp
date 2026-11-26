--
-- PostgreSQL database dump
--

\restrict ZgZxVztKBop0bZJoftzmUK46J2yduH7159HEwBBMuUdJzGWfWB1X1IhOqqQOmIH

-- Dumped from database version 17.11
-- Dumped by pg_dump version 19.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA extensions;


--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql;


--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql_public;


--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgbouncer;


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA realtime;


--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA storage;


--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA vault;


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone',
    'recovery_code'
);


--
-- Name: oauth_authorization_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_authorization_status AS ENUM (
    'pending',
    'approved',
    'denied',
    'expired'
);


--
-- Name: oauth_client_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_client_type AS ENUM (
    'public',
    'confidential'
);


--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


--
-- Name: oauth_response_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_response_type AS ENUM (
    'code'
);


--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


--
-- Name: action; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in',
    'like',
    'ilike',
    'is',
    'match',
    'imatch',
    'isdistinct'
);


--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text,
	negate boolean
);


--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


--
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: -
--

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS',
    'VECTOR'
);


--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    SET search_path TO ''
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
    revoke trigger on cron.job_run_details from postgres;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    SET search_path TO ''
    AS $_$
begin
    if not exists (
        select 1
        from pg_catalog.pg_event_trigger_ddl_commands() ev
        join pg_catalog.pg_extension e on ev.objid = e.oid
        where e.extname = 'pg_graphql'
    ) then
        return;
    end if;

    drop function if exists graphql_public.graphql;
    create or replace function graphql_public.graphql(
        "operationName" text default null,
        query text default null,
        variables jsonb default null,
        extensions jsonb default null
    )
        returns jsonb
        language sql
    as $$
        select graphql.resolve(
            query := query,
            variables := coalesce(variables, '{}'),
            "operationName" := "operationName",
            extensions := extensions
        );
    $$;

    -- Attach the wrapper to the extension so DROP EXTENSION cascades to it,
    -- which in turn triggers set_graphql_placeholder to reinstall the "not enabled" stub.
    alter extension pg_graphql add function graphql_public.graphql(text, text, jsonb, jsonb);

    grant usage on schema graphql to postgres, anon, authenticated, service_role;
    grant execute on function graphql.resolve to postgres, anon, authenticated, service_role;
    grant usage on schema graphql to postgres with grant option;
    grant usage on schema graphql_public to postgres with grant option;
end;
$_$;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    SET search_path TO ''
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8.0', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    SET search_path TO ''
    AS $$
DECLARE
  cmd record;
  obj_schema text;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    -- triggers and rules have no schema of their own (schema_name is NULL),
    -- so use the schema of the table they belong to
    obj_schema := CASE
      WHEN cmd.object_type IN ('trigger', 'rule')
        THEN (pg_identify_object_as_address(cmd.classid, cmd.objid, cmd.objsubid)).object_names[1]
      ELSE cmd.schema_name
    END;

    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    -- also exclude any objects inside Supabase schemas
    AND COALESCE(obj_schema, '') NOT IN ('pg_temp', 'auth', 'realtime', '_realtime', 'storage')
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    SET search_path TO ''
    AS $$
DECLARE
  obj record;
  obj_schema text;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    -- triggers and rules have no schema of their own (schema_name is NULL),
    -- so use the schema of the table they belonged to
    obj_schema := CASE
      WHEN obj.object_type IN ('trigger', 'rule') THEN obj.address_names[1]
      ELSE obj.schema_name
    END;

    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    -- also exclude any objects inside Supabase schemas
    AND COALESCE(obj_schema, '') NOT IN ('pg_temp', 'auth', 'realtime', '_realtime', 'storage')
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    SET search_path TO ''
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
            set search_path to ''
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: graphql(text, text, jsonb, jsonb); Type: FUNCTION; Schema: graphql_public; Owner: -
--

CREATE FUNCTION graphql_public.graphql("operationName" text DEFAULT NULL::text, query text DEFAULT NULL::text, variables jsonb DEFAULT NULL::jsonb, extensions jsonb DEFAULT NULL::jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: -
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $_$
  BEGIN
      RAISE DEBUG 'PgBouncer auth request: %', p_usename;

      RETURN QUERY
      SELECT
          rolname::text,
          CASE WHEN rolvaliduntil < now()
              THEN null
              ELSE rolpassword::text
          END
      FROM pg_authid
      WHERE rolname=$1 and rolcanlogin;
  END;
  $_$;


--
-- Name: enqueue_announcement_notifications(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.enqueue_announcement_notifications() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
declare
  target_user record;
begin

  -- Send to ALL users
  if (NEW.target_office is null or NEW.target_office = 'ALL') then

    for target_user in
      select u.id
      from public.users u
    loop

      insert into public.announcement_notifications (
        announcement_id,
        user_id,
        created_at,
        updated_at
      )
      values (
        NEW.id,
        target_user.id,
        now(),
        now()
      );

    end loop;

  else

    -- Send to users belonging to the selected department/office
    for target_user in
      select u.id
      from public.users u
      join public.employees e
        on e.user_id = u.id
      where e.department = NEW.target_office
    loop

      insert into public.announcement_notifications (
        announcement_id,
        user_id,
        created_at,
        updated_at
      )
      values (
        NEW.id,
        target_user.id,
        now(),
        now()
      );

    end loop;

  end if;

  return NEW;
end;
$$;


--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
    -- Regclass of the table e.g. public.notes
    entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

    -- I, U, D, T: insert, update ...
    action realtime.action = (
        case wal ->> 'action'
            when 'I' then 'INSERT'
            when 'U' then 'UPDATE'
            when 'D' then 'DELETE'
            else 'ERROR'
        end
    );

    -- Is row level security enabled for the table
    is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

    subscriptions realtime.subscription[] = array_agg(subs)
        from
            realtime.subscription subs
        where
            subs.entity = entity_
            -- Filter by action early - only get subscriptions interested in this action
            -- action_filter column can be: '*' (all), 'INSERT', 'UPDATE', or 'DELETE'
            and (subs.action_filter = '*' or subs.action_filter = action::text);

    -- Subscription vars
    working_role regrole;
    working_selected_columns text[];
    claimed_role regrole;
    claims jsonb;

    subscription_id uuid;
    subscription_has_access bool;
    visible_to_subscription_ids uuid[] = '{}';

    -- structured info for wal's columns
    columns realtime.wal_column[];
    -- previous identity values for update/delete
    old_columns realtime.wal_column[];

    -- the same values as wal2json sent them, which is what filters compare against
    raw_columns realtime.wal_column[] =
        array_agg((x->>'name', x->>'type', x->>'typeoid', x->'value', null, null)::realtime.wal_column)
        from jsonb_array_elements(wal -> 'columns') x;
    raw_old_columns realtime.wal_column[] =
        array_agg((x->>'name', x->>'type', x->>'typeoid', x->'value', null, null)::realtime.wal_column)
        from jsonb_array_elements(wal -> 'identity') x;

    error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

    -- Primary jsonb output for record
    output jsonb;

    -- Loop record for iterating unique roles (outer loop)
    role_record record;
    -- Loop record for iterating unique selected_columns within a role (inner loop)
    cols_record record;
    -- Subscription ids visible at the role level (before fanning out by selected_columns)
    visible_role_sub_ids uuid[] = '{}';

begin
    perform set_config('role', null, true);

    columns =
        array_agg(
            (
                x->>'name',
                x->>'type',
                x->>'typeoid',
                realtime.cast(
                    (x->'value') #>> '{}',
                    coalesce(
                        (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                        (x->>'type')::regtype
                    )
                ),
                (pks ->> 'name') is not null,
                true
            )::realtime.wal_column
        )
        from
            jsonb_array_elements(wal -> 'columns') x
            left join jsonb_array_elements(wal -> 'pk') pks
                on (x ->> 'name') = (pks ->> 'name');

    old_columns =
        array_agg(
            (
                x->>'name',
                x->>'type',
                x->>'typeoid',
                realtime.cast(
                    (x->'value') #>> '{}',
                    coalesce(
                        (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                        (x->>'type')::regtype
                    )
                ),
                (pks ->> 'name') is not null,
                true
            )::realtime.wal_column
        )
        from
            jsonb_array_elements(wal -> 'identity') x
            left join jsonb_array_elements(wal -> 'pk') pks
                on (x ->> 'name') = (pks ->> 'name');

    for role_record in
        select claims_role
        from (select distinct claims_role from unnest(subscriptions)) t
        order by claims_role::text
    loop
        working_role := role_record.claims_role;

        -- Update `is_selectable` for columns and old_columns (once per role)
        columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(columns) c;

        old_columns =
                array_agg(
                    (
                        c.name,
                        c.type_name,
                        c.type_oid,
                        c.value,
                        c.is_pkey,
                        pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                    )::realtime.wal_column
                )
                from
                    unnest(old_columns) c;

        if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
            -- Fan out 400 error per distinct selected_columns for this role
            for cols_record in
                select selected_columns
                from (select distinct selected_columns from unnest(subscriptions) s where s.claims_role = working_role) t
                order by coalesce(array_to_string(selected_columns, ','), '')
            loop
                working_selected_columns := cols_record.selected_columns;
                return next (
                    jsonb_build_object(
                        'schema', wal ->> 'schema',
                        'table', wal ->> 'table',
                        'type', action
                    ),
                    is_rls_enabled,
                    (select array_agg(s.subscription_id) from unnest(subscriptions) as s where s.claims_role = working_role and (s.selected_columns is not distinct from working_selected_columns)),
                    array['Error 400: Bad Request, no primary key']
                )::realtime.wal_rls;
            end loop;

        -- The claims role does not have SELECT permission to the primary key of entity
        elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
            -- Fan out 401 error per distinct selected_columns for this role
            for cols_record in
                select selected_columns
                from (select distinct selected_columns from unnest(subscriptions) s where s.claims_role = working_role) t
                order by coalesce(array_to_string(selected_columns, ','), '')
            loop
                working_selected_columns := cols_record.selected_columns;
                return next (
                    jsonb_build_object(
                        'schema', wal ->> 'schema',
                        'table', wal ->> 'table',
                        'type', action
                    ),
                    is_rls_enabled,
                    (select array_agg(s.subscription_id) from unnest(subscriptions) as s where s.claims_role = working_role and (s.selected_columns is not distinct from working_selected_columns)),
                    array['Error 401: Unauthorized']
                )::realtime.wal_rls;
            end loop;

        else
            -- Create the prepared statement (once per role)
            if is_rls_enabled and action <> 'DELETE' then
                if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                    deallocate walrus_rls_stmt;
                end if;
                execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
            end if;

            -- Collect all visible subscription IDs for this role (filter check + RLS check)
            visible_role_sub_ids = '{}';

            for subscription_id, claims in (
                    select
                        subs.subscription_id,
                        subs.claims
                    from
                        unnest(subscriptions) subs
                    where
                        subs.entity = entity_
                        and subs.claims_role = working_role
                        and (
                            realtime.is_visible_through_filters(raw_columns, subs.filters)
                            or (
                              action = 'DELETE'
                              and realtime.is_visible_through_filters(raw_old_columns, subs.filters)
                            )
                        )
            ) loop

                if not is_rls_enabled or action = 'DELETE' then
                    visible_role_sub_ids = visible_role_sub_ids || subscription_id;
                else
                    -- Check if RLS allows the role to see the record
                    perform
                        -- Trim leading and trailing quotes from working_role because set_config
                        -- doesn't recognize the role as valid if they are included
                        set_config('role', trim(both '"' from working_role::text), true),
                        set_config('request.jwt.claims', claims::text, true);

                    execute 'execute walrus_rls_stmt' into subscription_has_access;

                    -- Reset the role on every FOR..LOOP batch execution.
                    -- The first batch of 10 rows is pre-fetched using the current connection role (PG internal behaviour)
                    -- then we have to reset it again otherwise it would use the role defined in the `set_config` above
                    -- to fetch the remaining rows when rows>10, which could be a user-defined role that lacks execution grants.
                    -- The flow is:
                    --   1. run batch with conn role
                    --   2. set_config working_role
                    --   3. execute walrus
                    --   4. reset role (revert)
                    --   5. repeat
                    perform set_config('role', null, true);

                    if subscription_has_access then
                        visible_role_sub_ids = visible_role_sub_ids || subscription_id;
                    end if;
                end if;
            end loop;

            perform set_config('role', null, true);

            -- Inner loop: per distinct selected_columns for this role
            for cols_record in
                select selected_columns
                from (select distinct selected_columns from unnest(subscriptions) s where s.claims_role = working_role) t
                order by coalesce(array_to_string(selected_columns, ','), '')
            loop
                working_selected_columns := cols_record.selected_columns;

                output = jsonb_build_object(
                    'schema', wal ->> 'schema',
                    'table', wal ->> 'table',
                    'type', action,
                    'commit_timestamp', to_char(
                        ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                        'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
                    ),
                    'columns', (
                        select
                            jsonb_agg(
                                jsonb_build_object(
                                    'name', pa.attname,
                                    'type', pt.typname
                                )
                                order by pa.attnum asc
                            )
                        from
                            pg_attribute pa
                            join pg_type pt
                                on pa.atttypid = pt.oid
                            left join (
                                select unnest(conkey) as pkey_attnum
                                from pg_constraint
                                where conrelid = entity_ and contype = 'p'
                            ) pk on pk.pkey_attnum = pa.attnum
                        where
                            attrelid = entity_
                            and attnum > 0
                            and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
                            and (working_selected_columns is null or pa.attname = any(working_selected_columns) or pk.pkey_attnum is not null)
                    )
                )
                -- Add "record" key for insert and update
                || case
                    when action in ('INSERT', 'UPDATE') then
                        jsonb_build_object(
                            'record',
                            (
                                select
                                    jsonb_object_agg(
                                        -- if unchanged toast, get column name and value from old record
                                        coalesce((c).name, (oc).name),
                                        case
                                            when (c).name is null then (oc).value
                                            else (c).value
                                        end
                                    )
                                from
                                    unnest(columns) c
                                    full outer join unnest(old_columns) oc
                                        on (c).name = (oc).name
                                where
                                    coalesce((c).is_selectable, (oc).is_selectable)
                                    and (working_selected_columns is null or coalesce((c).name, (oc).name) = any(working_selected_columns) or coalesce((c).is_pkey, (oc).is_pkey))
                                    and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            )
                        )
                    else '{}'::jsonb
                end
                -- Add "old_record" key for update and delete
                || case
                    when action = 'UPDATE' then
                        jsonb_build_object(
                                'old_record',
                                (
                                    select jsonb_object_agg((c).name, (c).value)
                                    from unnest(old_columns) c
                                    where
                                        (c).is_selectable
                                        and (working_selected_columns is null or (c).name = any(working_selected_columns) or (c).is_pkey)
                                        and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                                )
                            )
                    when action = 'DELETE' then
                        jsonb_build_object(
                            'old_record',
                            (
                                select jsonb_object_agg((c).name, (c).value)
                                from unnest(old_columns) c
                                where
                                    (c).is_selectable
                                    and (working_selected_columns is null or (c).name = any(working_selected_columns) or (c).is_pkey)
                                    and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                                    and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                            )
                        )
                    else '{}'::jsonb
                end;

                -- Filter visible_role_sub_ids to those matching the current selected_columns group
                visible_to_subscription_ids = coalesce(
                    (
                        select array_agg(s.subscription_id)
                        from unnest(subscriptions) s
                        where s.claims_role = working_role
                          and (s.selected_columns is not distinct from working_selected_columns)
                          and s.subscription_id = any(visible_role_sub_ids)
                    ),
                    '{}'::uuid[]
                );

                return next (
                    output,
                    is_rls_enabled,
                    visible_to_subscription_ids,
                    case
                        when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                        else '{}'
                    end
                )::realtime.wal_rls;
            end loop;

        end if;
    end loop;

    perform set_config('role', null, true);
end;
$$;


--
-- Name: authorize(text, text, text, text, text, text[], text[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.authorize(role_name text, topic_name text, claims text, sub text, headers text, read_extensions text[], write_extensions text[], OUT read_allowed boolean[], OUT write_allowed boolean[]) RETURNS record
    LANGUAGE plpgsql
    AS $$
declare
  probe_ids uuid[];
  probe_inserted_at timestamp := now() at time zone 'utc';
  visible_ids uuid[];
  ext text;
  allowed boolean;
begin
  -- The probe inserts are rolled back, but they still give the transaction an xid, so it ends
  -- in a commit. Nothing durable was written, so skip waiting on the WAL flush and sync standbys.
  -- Set outside the block below, whose rollback would undo it.
  perform set_config('synchronous_commit', 'off', true);

  -- The RAISE at the end of this block rolls back everything in it.
  begin
    probe_ids := array(select gen_random_uuid() from unnest(read_extensions));

    insert into realtime.messages (id, topic, extension, inserted_at, updated_at)
    select p.id, topic_name, p.extension, probe_inserted_at, probe_inserted_at
    from unnest(probe_ids, read_extensions) as p(id, extension);

    perform set_config('role', role_name, true),
            set_config('realtime.topic', topic_name, true),
            set_config('request.jwt.claims', claims, true),
            set_config('request.jwt.claim.sub', sub, true),
            set_config('request.jwt.claim.role', role_name, true),
            set_config('request.headers', headers, true);

    -- One lookup for every probe, by the full primary key. Skipped without probes, so the
    -- SELECT policies are not planned for a write.
    if cardinality(probe_ids) > 0 then
      visible_ids := array(
        select m.id
        from realtime.messages m
        where m.inserted_at = probe_inserted_at
          and m.id = any(probe_ids));
    end if;

    read_allowed := array(
      select p.id = any(visible_ids)
      from unnest(probe_ids) with ordinality as p(id, n)
      order by p.n);

    write_allowed := '{}';

    foreach ext in array write_extensions loop
      begin
        insert into realtime.messages (topic, extension, inserted_at, updated_at)
        values (topic_name, ext, now() at time zone 'utc', now() at time zone 'utc');

        allowed := true;
      exception when insufficient_privilege then
        allowed := false;
      end;

      write_allowed := write_allowed || allowed;
    end loop;

    raise sqlstate 'RTA01';
  exception when sqlstate 'RTA01' then
    null;
  end;
end;
$$;


--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
  res jsonb;
begin
  if type_::text = 'bytea' then
    return to_jsonb(val);
  end if;
  execute format('select to_jsonb(%L::'|| type_::text || ')', val) into res;
  return res;
end
$$;


--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
/*
Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
*/
declare
    op_symbol text = (
        case
            when op = 'eq' then '='
            when op = 'neq' then '!='
            when op = 'lt' then '<'
            when op = 'lte' then '<='
            when op = 'gt' then '>'
            when op = 'gte' then '>='
            when op = 'in' then '= any'
            else 'UNKNOWN OP'
        end
    );
    res boolean;
begin
    execute format(
        'select %L::'|| type_::text || ' ' || op_symbol
        || ' ( %L::'
        || (
            case
                when op = 'in' then type_::text || '[]'
                else type_::text end
        )
        || ')', val_1, val_2) into res;
    return res;
end;
$$;


--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text, negate boolean) RETURNS boolean
    LANGUAGE plpgsql STABLE
    AS $$
declare
    op_symbol text;
    res boolean;
begin
    -- IS DISTINCT FROM / IS NOT DISTINCT FROM: infix, both sides typed literals
    if op = 'isdistinct' then
        execute format(
            'select %L::%s %s %L::%s',
            val_1,
            type_::text,
            case when negate then 'IS NOT DISTINCT FROM' else 'IS DISTINCT FROM' end,
            val_2,
            type_::text
        ) into res;
        return res;
    end if;

    -- IS requires a keyword RHS (NULL, TRUE, FALSE, UNKNOWN), not a typed literal
    if op = 'is' then
        if val_2 not in ('null', 'true', 'false', 'unknown') then
            raise exception 'invalid value for is filter: must be null, true, false, or unknown';
        end if;
        execute format(
            'select %L::%s %s %s',
            val_1,
            type_::text,
            case when negate then 'IS NOT' else 'IS' end,
            upper(val_2)
        ) into res;
        return res;
    end if;

    op_symbol = case
        when op = 'eq'    then '='
        when op = 'neq'   then '!='
        when op = 'lt'    then '<'
        when op = 'lte'   then '<='
        when op = 'gt'    then '>'
        when op = 'gte'   then '>='
        when op = 'in'    then '= any'
        when op = 'like'   then 'LIKE'
        when op = 'ilike'  then 'ILIKE'
        when op = 'match'  then '~'
        when op = 'imatch' then '~*'
        else null
    end;

    if op_symbol is null then
        raise exception 'unsupported equality operator: %', op::text;
    end if;

    execute format(
        'select %L::%s %s (%L::%s)',
        val_1,
        type_::text,
        op_symbol,
        val_2,
        case when op = 'in' then type_::text || '[]' else type_::text end
    ) into res;

    return case when negate then not res else res end;
end;
$$;


--
-- Name: filters_hash(realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.filters_hash(filters realtime.user_defined_filter[]) RETURNS bytea
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE
    AS $$
  select pg_catalog.int8send(pg_catalog.hash_array_extended(filters, 0))
      || pg_catalog.int8send(pg_catalog.hash_array_extended(filters, 1))
$$;


--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
    select
        filters is null
        or array_length(filters, 1) is null
        or coalesce(
            count(col.name) = count(1)
            and sum(
                realtime.check_equality_op(
                    op:=f.op,
                    type_:=coalesce(col.type_oid::regtype, col.type_name::regtype),
                    val_1:=col.value #>> '{}',
                    val_2:=f.value,
                    negate:=coalesce(f.negate, false)
                )::int
            ) filter (where col.name is not null) = count(col.name),
            false
        )
    from
        unnest(filters) f
        left join unnest(columns) col
            on f.column_name = col.name;
$$;


--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS TABLE(wal jsonb, is_rls_enabled boolean, subscription_ids uuid[], errors text[], slot_changes_count bigint)
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
  WITH pub AS (
    SELECT
      concat_ws(
        ',',
        CASE WHEN bool_or(pubinsert) THEN 'insert' ELSE NULL END,
        CASE WHEN bool_or(pubupdate) THEN 'update' ELSE NULL END,
        CASE WHEN bool_or(pubdelete) THEN 'delete' ELSE NULL END
      ) AS w2j_actions,
      coalesce(
        string_agg(
          realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
          ','
        ) filter (WHERE ppt.tablename IS NOT NULL),
        ''
      ) AS w2j_add_tables
    FROM pg_publication pp
    LEFT JOIN pg_publication_tables ppt ON pp.pubname = ppt.pubname
    WHERE pp.pubname = publication
    GROUP BY pp.pubname
    LIMIT 1
  ),
  -- MATERIALIZED ensures pg_logical_slot_get_changes is called exactly once
  w2j AS MATERIALIZED (
    SELECT x.*, pub.w2j_add_tables
    FROM pub,
         pg_logical_slot_get_changes(
           slot_name, null, max_changes,
           'include-pk', 'true',
           'include-transaction', 'false',
           'include-timestamp', 'true',
           'include-type-oids', 'true',
           'format-version', '2',
           'actions', pub.w2j_actions,
           'add-tables', pub.w2j_add_tables
         ) x
  ),
  slot_count AS (
    SELECT count(*)::bigint AS cnt
    FROM w2j
    WHERE w2j.w2j_add_tables <> ''
  ),
  rls_filtered AS (
    SELECT xyz.wal, xyz.is_rls_enabled, xyz.subscription_ids, xyz.errors
    FROM w2j,
         realtime.apply_rls(
           wal := w2j.data::jsonb,
           max_record_bytes := max_record_bytes
         ) xyz(wal, is_rls_enabled, subscription_ids, errors)
    WHERE w2j.w2j_add_tables <> ''
      AND xyz.subscription_ids[1] IS NOT NULL
  )
  SELECT rf.wal, rf.is_rls_enabled, rf.subscription_ids, rf.errors, sc.cnt
  FROM rls_filtered rf, slot_count sc

  UNION ALL

  SELECT null, null, null, null, sc.cnt
  FROM slot_count sc
  WHERE NOT EXISTS (SELECT 1 FROM rls_filtered)
$$;


--
-- Name: list_changes_sync(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.list_changes_sync(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS TABLE(wal jsonb, is_rls_enabled boolean, subscription_ids uuid[], errors text[], slot_changes_count bigint)
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
  WITH pub AS (
    SELECT
      concat_ws(
        ',',
        CASE WHEN bool_or(pubinsert) THEN 'insert' ELSE NULL END,
        CASE WHEN bool_or(pubupdate) THEN 'update' ELSE NULL END,
        CASE WHEN bool_or(pubdelete) THEN 'delete' ELSE NULL END
      ) AS w2j_actions,
      coalesce(
        string_agg(
          realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
          ','
        ) filter (WHERE ppt.tablename IS NOT NULL),
        ''
      ) AS w2j_add_tables
    FROM pg_publication pp
    LEFT JOIN pg_publication_tables ppt ON pp.pubname = ppt.pubname
    WHERE pp.pubname = publication
    GROUP BY pp.pubname
    LIMIT 1
  ),
  -- MATERIALIZED ensures the slot is read exactly once.
  consumed AS MATERIALIZED (
    SELECT x.*, pub.w2j_add_tables
    FROM pub,
         realtime.settled_changes(
           slot_name, max_changes,
           'include-pk', 'true',
           'include-transaction', 'false',
           'include-timestamp', 'true',
           'include-type-oids', 'true',
           'format-version', '2',
           'actions', pub.w2j_actions,
           'add-tables', pub.w2j_add_tables
         ) x
  ),
  slot_count AS (
    SELECT count(*)::bigint AS cnt
    FROM consumed
    WHERE consumed.w2j_add_tables <> ''
  ),
  rls_filtered AS (
    SELECT xyz.wal, xyz.is_rls_enabled, xyz.subscription_ids, xyz.errors
    FROM consumed,
         realtime.apply_rls(
           wal := consumed.data::jsonb,
           max_record_bytes := max_record_bytes
         ) xyz(wal, is_rls_enabled, subscription_ids, errors)
    WHERE consumed.w2j_add_tables <> ''
      AND xyz.subscription_ids[1] IS NOT NULL
  )
  SELECT rf.wal, rf.is_rls_enabled, rf.subscription_ids, rf.errors, sc.cnt
  FROM rls_filtered rf, slot_count sc

  UNION ALL

  SELECT null, null, null, null, sc.cnt
  FROM slot_count sc
  WHERE NOT EXISTS (SELECT 1 FROM rls_filtered)
$$;


--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
  SELECT
    realtime.wal2json_escape_identifier(nsp.nspname::text)
    || '.'
    || realtime.wal2json_escape_identifier(pc.relname::text)
  FROM pg_class pc
  JOIN pg_namespace nsp ON pc.relnamespace = nsp.oid
  WHERE pc.oid = entity
$$;


--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
  final_payload jsonb;
BEGIN
  BEGIN
    generated_id := gen_random_uuid();

    -- Check if payload has an 'id' key, if not, add the generated UUID
    IF payload ? 'id' THEN
      final_payload := payload;
    ELSE
      final_payload := jsonb_set(payload, '{id}', to_jsonb(generated_id));
    END IF;

    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    INSERT INTO realtime.messages (id, payload, event, topic, private, extension)
    VALUES (generated_id, final_payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING 'WarnSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


--
-- Name: send_binary(bytea, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.send_binary(payload bytea, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
BEGIN
  BEGIN
    generated_id := gen_random_uuid();

    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    INSERT INTO realtime.messages (id, binary_payload, event, topic, private, extension)
    VALUES (generated_id, payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING 'WarnSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


--
-- Name: settled_changes(name, integer, text[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.settled_changes(slot_name name, max_changes integer, VARIADIC opts text[]) RETURNS TABLE(lsn pg_lsn, xid xid, data text)
    LANGUAGE plpgsql
    AS $$
declare
  upto pg_lsn;
  total bigint;
  xids xid[];
  starts bigint[];
  snapshot pg_snapshot;
  running_xids xid[];
  xmax_age int;
  cut bigint;
begin
  -- Each statement in a volatile function takes its own snapshot, which is what lets the
  -- check below see a writer that was still in flight when the peek ran. Under REPEATABLE
  -- READ the snapshot never advances, so a deferred change would never be released.
  if current_setting('transaction_isolation') <> 'read committed' then
    raise exception 'realtime.settled_changes requires READ COMMITTED';
  end if;

  -- The peek and the read below cover the same WAL, so the read cannot reach a commit the
  -- check never saw.
  upto := pg_current_wal_flush_lsn();

  -- One entry per transaction, in commit order: its xid and the position of its first
  -- change. The peek uses the caller's own options, so max_changes counts exactly what the
  -- read counts. A non-transactional logical message is emitted as soon as it is decoded,
  -- tagged with the xid of whatever transaction wrote it, so it does not mark where that
  -- transaction starts.
  select coalesce(sum(g.n), 0),
         array_agg(g.x order by g.first) filter (where g.first is not null),
         array_agg(g.first order by g.first) filter (where g.first is not null)
    into total, xids, starts
    from (
      select p.xid as x, count(*) as n,
             min(p.ord) filter (where not case
               when starts_with(p.data, '{"action":"M"') then (p.data::jsonb->>'transactional')::boolean is false
               else false
             end) as first
      from pg_logical_slot_peek_changes(slot_name, upto, max_changes, variadic opts)
           with ordinality as p(lsn, xid, data, ord)
      group by p.xid
    ) g;

  -- Nothing for the caller, but the slot still has to move past what the peek covered.
  if total = 0 then
    perform pg_replication_slot_advance(slot_name, upto);
    return;
  end if;

  if xids is not null then
    -- Taken after the peek is materialized, so a writer that was still in flight during
    -- decoding is guaranteed to show up here.
    snapshot := pg_current_snapshot();

    -- A commit record reaches the WAL before the writer leaves the proc array, so a change
    -- can be decoded while its row is invisible. apply_rls would resolve a policy against a
    -- row it cannot see and authorize it for nobody, while the read consumed it regardless.
    --
    -- xip lists transactions running when the snapshot was taken. It does not cover a writer
    -- whose xid sits at or beyond xmax, which never appears there, so the horizon is checked
    -- too. age() counts backwards from the current xid and so compares correctly across
    -- wraparound.
    select coalesce(array_agg(running.x::xid), array[]::xid[])
      into running_xids
      from pg_snapshot_xip(snapshot) running(x);
    xmax_age := age(pg_snapshot_xmax(snapshot)::xid);

    select min(u.s) into cut
      from unnest(xids, starts) as u(x, s)
      where u.x = any(running_xids) or age(u.x) <= xmax_age;
  end if;

  -- The read stops right after the commit that brings its count to upto_nchanges, so the
  -- count of changes in front of the first unsettled transaction stops it just before that
  -- transaction.
  if cut is null then
    return query
      select p.* from pg_logical_slot_get_changes(slot_name, upto, max_changes, variadic opts) p;
  elsif cut > 1 then
    return query
      select p.* from pg_logical_slot_get_changes(slot_name, upto, (cut - 1)::int, variadic opts) p;
  end if;
end;
$$;


--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    col_names text[] = coalesce(
            array_agg(a.attname order by a.attnum),
            '{}'::text[]
        )
        from
            pg_catalog.pg_attribute a
        where
            a.attrelid = new.entity
            and a.attnum > 0
            and not a.attisdropped
            and pg_catalog.has_column_privilege(
                (new.claims ->> 'role'),
                a.attrelid,
                a.attnum,
                'SELECT'
            );
    filter realtime.user_defined_filter;
    col_type regtype;
    in_val jsonb;
    selected_col text;
begin
    for filter in select * from unnest(new.filters) loop
        if not filter.column_name = any(col_names) then
            raise exception 'invalid column for filter %', filter.column_name;
        end if;

        col_type = (
            select atttypid::regtype
            from pg_catalog.pg_attribute
            where attrelid = new.entity
                  and attname = filter.column_name
        );
        if col_type is null then
            raise exception 'failed to lookup type for column %', filter.column_name;
        end if;

        if filter.op = 'in'::realtime.equality_op then
            in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
            if coalesce(jsonb_array_length(in_val), 0) > 100 then
                raise exception 'too many values for `in` filter. Maximum 100';
            end if;
        elsif filter.op = 'is'::realtime.equality_op then
            -- `is` requires a keyword RHS rather than a typed literal
            if filter.value not in ('null', 'true', 'false', 'unknown') then
                raise exception 'invalid value for is filter: must be null, true, false, or unknown';
            end if;
            -- IS NULL works for any type, but IS TRUE/FALSE/UNKNOWN require a boolean
            -- operand. Reject the non-null keywords on non-boolean columns here so they
            -- don't abort apply_rls at WAL time.
            if filter.value <> 'null' and col_type <> 'boolean'::regtype then
                raise exception 'is % filter requires a boolean column, got %', filter.value, col_type::text;
            end if;
        elsif filter.op in ('like'::realtime.equality_op, 'ilike'::realtime.equality_op) then
            -- like/ilike apply the text pattern operator (~~); reject column types that
            -- have no such operator instead of failing at WAL time
            if not exists (
                select 1 from pg_catalog.pg_operator
                where oprname = '~~' and oprleft = col_type
            ) then
                raise exception 'operator % requires a text-compatible column type, got %', filter.op::text, col_type::text;
            end if;
        elsif filter.op in ('match'::realtime.equality_op, 'imatch'::realtime.equality_op) then
            -- match/imatch apply the regex operators ~ / ~*; reject column types that have
            -- no such operator (e.g. integer) instead of failing at WAL time, mirroring the
            -- like/ilike guard above.
            if not exists (
                select 1 from pg_catalog.pg_operator
                where oprname = case when filter.op = 'imatch'::realtime.equality_op then '~*' else '~' end
                  and oprleft = col_type
                  and oprright = col_type
                  and oprresult = 'boolean'::regtype
            ) then
                raise exception 'operator % requires a text-compatible column type, got %', filter.op::text, col_type::text;
            end if;
            -- validate the regex eagerly so a bad pattern is rejected here, not inside
            -- apply_rls where it would abort the WAL stream for the entity
            begin
                perform '' ~ filter.value;
            exception when others then
                raise exception 'invalid regular expression for % filter: %', filter.op::text, sqlerrm;
            end;
        else
            -- eq/neq/lt/lte/gt/gte: value must be coercable to the type
            perform realtime.cast(filter.value, col_type);
        end if;
    end loop;

    if new.selected_columns is not null then
        for selected_col in select * from unnest(new.selected_columns) loop
            if not selected_col = any(col_names) then
                raise exception 'invalid column for select %', selected_col;
            end if;
        end loop;
    end if;

    -- Apply consistent order to filters so the unique constraint can't be tricked by a
    -- different filter order. negate is part of the sort key.
    new.filters = coalesce(
        array_agg(f order by f.column_name, f.op, f.value, f.negate),
        '{}'
    ) from unnest(new.filters) f;

    -- Normalize selected_columns order so ARRAY['a','b'] and ARRAY['b','a'] are treated
    -- as the same subscription group in apply_rls. Preserve an empty array as '{}'
    -- ("primary keys only") so it stays distinct from NULL ("all columns"); array_agg
    -- over an empty set would otherwise collapse '{}' back to NULL.
    if new.selected_columns is not null then
        new.selected_columns = coalesce(
            (
                select array_agg(c order by c)
                from unnest(new.selected_columns) c
            ),
            '{}'::text[]
        );
    end if;

    return new;
end;
$$;


--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


--
-- Name: wal2json_escape_identifier(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.wal2json_escape_identifier(name text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
  -- Prefix `\`, `,`, `.`, and any whitespace with `\`
  SELECT regexp_replace(name, '([\\,.[:space:]])', '\\\1', 'g')
$$;


--
-- Name: allow_any_operation(text[]); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.allow_any_operation(expected_operations text[]) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  WITH current_operation AS (
    SELECT storage.operation() AS raw_operation
  ),
  normalized AS (
    SELECT CASE
      WHEN raw_operation LIKE 'storage.%' THEN substr(raw_operation, 9)
      ELSE raw_operation
    END AS current_operation
    FROM current_operation
  )
  SELECT EXISTS (
    SELECT 1
    FROM normalized n
    CROSS JOIN LATERAL unnest(expected_operations) AS expected_operation
    WHERE expected_operation IS NOT NULL
      AND expected_operation <> ''
      AND n.current_operation = CASE
        WHEN expected_operation LIKE 'storage.%' THEN substr(expected_operation, 9)
        ELSE expected_operation
      END
  );
$$;


--
-- Name: allow_only_operation(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.allow_only_operation(expected_operation text) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  WITH current_operation AS (
    SELECT storage.operation() AS raw_operation
  ),
  normalized AS (
    SELECT
      CASE
        WHEN raw_operation LIKE 'storage.%' THEN substr(raw_operation, 9)
        ELSE raw_operation
      END AS current_operation,
      CASE
        WHEN expected_operation LIKE 'storage.%' THEN substr(expected_operation, 9)
        ELSE expected_operation
      END AS requested_operation
    FROM current_operation
  )
  SELECT CASE
    WHEN requested_operation IS NULL OR requested_operation = '' THEN FALSE
    ELSE COALESCE(current_operation = requested_operation, FALSE)
  END
  FROM normalized;
$$;


--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


--
-- Name: delete_lifecycle_objects(uuid[]); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.delete_lifecycle_objects(object_ids uuid[]) RETURNS TABLE(id uuid, is_delete_marker boolean, metadata jsonb)
    LANGUAGE plpgsql
    AS $$
DECLARE
    object_id uuid;
    deleted_row storage.objects%ROWTYPE;
    deleted_ids uuid[];
    deleted_markers boolean[];
    deleted_metadata jsonb[];
    bulk_deleted boolean := false;
BEGIN
    -- Surface pre-existing deferred violations instead of treating them as blocked rows.
    SET CONSTRAINTS ALL IMMEDIATE;
    PERFORM set_config('storage.allow_delete_query', 'true', true);

    -- One subxact keeps the subxid cache from overflowing; rows return only once it commits.
    BEGIN
        WITH deleted AS (
            DELETE FROM storage.objects AS object_row
              WHERE object_row.id = ANY(object_ids) AND object_row.archived_at IS NOT NULL
              RETURNING object_row.id, object_row.is_delete_marker, object_row.metadata
        )
        SELECT array_agg(deleted.id), array_agg(deleted.is_delete_marker), array_agg(deleted.metadata)
          INTO deleted_ids, deleted_markers, deleted_metadata
          FROM deleted;
        bulk_deleted := true;
    EXCEPTION
        WHEN OTHERS THEN
            -- User triggers may use insufficient_privilege to block a row.
            IF SQLSTATE <> '42501' AND left(SQLSTATE, 2) IN ('08', '40', '42', '53', '55', '57', '58', 'XX') THEN
                RAISE;
            END IF;
    END;
    IF bulk_deleted THEN
        RETURN QUERY SELECT * FROM unnest(deleted_ids, deleted_markers, deleted_metadata);
        RETURN;
    END IF;

    FOREACH object_id IN ARRAY object_ids LOOP
        BEGIN
            DELETE FROM storage.objects AS object_row
              WHERE object_row.id = object_id AND object_row.archived_at IS NOT NULL
              RETURNING object_row.* INTO deleted_row;
            IF FOUND THEN
                id := deleted_row.id;
                is_delete_marker := deleted_row.is_delete_marker;
                metadata := deleted_row.metadata;
                RETURN NEXT;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                IF SQLSTATE <> '42501' AND left(SQLSTATE, 2) IN ('08', '40', '42', '53', '55', '57', '58', 'XX') THEN
                    RAISE;
                END IF;
        END;
    END LOOP;
END;
$$;


--
-- Name: enforce_bucket_lifecycle_service_role(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.enforce_bucket_lifecycle_service_role() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog'
    AS $$
BEGIN
  IF current_user::text IS DISTINCT FROM TG_ARGV[0] THEN
    -- Keep this check AFTER caller RLS accepts the proposed row. The API
    -- recognizes this exact signal after rolling back its permission probe.
    RAISE EXCEPTION 'bucket control columns may only be changed by the configured storage service role'
      USING ERRCODE = 'PST01',
            SCHEMA = TG_TABLE_SCHEMA,
            TABLE = TG_TABLE_NAME,
            CONSTRAINT = TG_NAME;
  END IF;

  RETURN NULL;
END;
$$;


--
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.enforce_bucket_name_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


--
-- Name: enforce_versioning_status_transition(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.enforce_versioning_status_transition() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.versioning_status = OLD.versioning_status THEN
        RETURN NEW;
    END IF;

    IF NEW.versioning_status = 'DISABLED' OR
       (OLD.versioning_status = 'DISABLED' AND NEW.versioning_status = 'SUSPENDED') THEN
        RAISE EXCEPTION 'Cannot transition bucket versioning status from % to %',
            OLD.versioning_status, NEW.versioning_status;
    END IF;

    RETURN NEW;
END;
$$;


--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Get the last path segment (the actual filename)
    SELECT _parts[array_length(_parts, 1)] INTO _filename;
    -- Extract extension: reverse, split on '.', then reverse again
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    SELECT string_to_array(name, '/') INTO _parts;
    RETURN _parts[array_length(_parts, 1)];
END
$$;


--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


--
-- Name: get_common_prefix(text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_common_prefix(p_key text, p_prefix text, p_delimiter text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
SELECT CASE
    WHEN p_delimiter <> ''
         AND position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)) > 0
    THEN left(
        p_key,
        length(p_prefix)
            + position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1))
            + length(p_delimiter) - 1
    )
    ELSE NULL
END;
$$;


--
-- Name: get_size_by_bucket(text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_size_by_bucket(noncurrent_versions text DEFAULT 'include'::text, delete_markers text DEFAULT 'include'::text) RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    -- COALESCE first: NULL NOT IN (...) evaluates to NULL (not TRUE), so a
    -- bare NOT IN check silently leaves an explicit NULL argument unreset.
    noncurrent_versions := COALESCE(noncurrent_versions, 'include');
    delete_markers := COALESCE(delete_markers, 'include');
    IF noncurrent_versions NOT IN ('exclude', 'only', 'include') THEN
        noncurrent_versions := 'include';
    END IF;
    IF delete_markers NOT IN ('exclude', 'only', 'include') THEN
        delete_markers := 'include';
    END IF;

    return query
        select sum((metadata->>'size')::bigint)::bigint as size, obj.bucket_id
        from "storage".objects as obj
        where (noncurrent_versions != 'exclude' OR obj.archived_at IS NULL)
          and (noncurrent_versions != 'only' OR obj.archived_at IS NOT NULL)
          and (delete_markers != 'exclude' OR NOT obj.is_delete_marker)
          and (delete_markers != 'only' OR obj.is_delete_marker)
        group by obj.bucket_id;
END
$$;


--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text, raw_prefix_param text DEFAULT NULL::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE sql STABLE
    AS $_$
WITH candidates AS (
    SELECT
        upload.key AS object_key,
        CASE
            WHEN position($3 IN substring(upload.key FROM length(coalesce($7, $2)) + 1)) > 0
            THEN left(
                upload.key,
                length(coalesce($7, $2))
                    + position($3 IN substring(upload.key FROM length(coalesce($7, $2)) + 1))
                    + length($3) - 1
            )
            ELSE upload.key
        END AS result_key,
        upload.id,
        upload.created_at,
        position($3 IN substring(upload.key FROM length(coalesce($7, $2)) + 1)) > 0 AS is_common_prefix
    FROM storage.s3_multipart_uploads AS upload
    WHERE upload.bucket_id = $1
      AND upload.key COLLATE "C" LIKE $2 || '%'
), filtered AS (
    SELECT candidate.*
    FROM candidates AS candidate
    WHERE $5 = ''
       OR candidate.result_key COLLATE "C" > $5
       OR (
           candidate.result_key COLLATE "C" = $5
           AND NOT candidate.is_common_prefix
           AND $6 <> ''
           -- A completed or aborted marker repeats the remaining same-key uploads.
           AND COALESCE(
               (candidate.created_at, candidate.id COLLATE "C") > (
                   SELECT marker.created_at, marker.id COLLATE "C"
                   FROM storage.s3_multipart_uploads AS marker
                   WHERE marker.bucket_id = $1
                     AND marker.key COLLATE "C" = $5
                     AND marker.id = $6
               ),
               TRUE
           )
       )
), ranked AS (
    SELECT
        filtered.*,
        row_number() OVER (
            PARTITION BY filtered.result_key COLLATE "C"
            ORDER BY filtered.created_at, filtered.id COLLATE "C"
        ) AS prefix_rank
    FROM filtered
)
SELECT ranked.result_key, ranked.id, ranked.created_at
FROM ranked
WHERE NOT ranked.is_common_prefix OR ranked.prefix_rank = 1
ORDER BY ranked.result_key COLLATE "C", ranked.created_at, ranked.id COLLATE "C"
LIMIT $4;
$_$;


--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text, text, text, text, timestamp with time zone, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_objects_with_delimiter(_bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, noncurrent_versions text DEFAULT 'exclude'::text, delete_markers text DEFAULT 'exclude'::text, next_token_archived_at timestamp with time zone DEFAULT NULL::timestamp with time zone, next_token_version text DEFAULT ''::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, version text, archived_at timestamp with time zone, is_delete_marker boolean, is_versioned boolean)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;

    -- Configuration
    v_is_asc BOOLEAN;
    v_prefix TEXT;
    v_start TEXT;
    v_start_relative TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;
    v_version_filter TEXT;

    -- true when noncurrent_versions can return >1 row per name; keeps them
    -- ordered most-recent-first and lets pagination resume mid-key
    v_multi_row BOOLEAN;
    v_name_order TEXT;
    v_exact_range_predicate TEXT;
    v_strict_range_predicate TEXT;
    v_inclusive_range_predicate TEXT;

    -- Seek state for the current name. archived_at is normalized to JavaScript's
    -- millisecond precision and version breaks ties within the same millisecond.
    -- Current rows use 'infinity'; NULL means no tiebreak has been established.
    v_next_seek TEXT;
    v_next_seek_at TIMESTAMPTZ;
    v_next_seek_version TEXT;
    v_next_seek_strict BOOLEAN := false;
    v_cursor_is_folder BOOLEAN;
    v_count INT := 0;
    v_previous_seek TEXT;
    v_previous_seek_at TIMESTAMPTZ;
    v_previous_seek_version TEXT;
    v_previous_count INT;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;
    v_batch_query_strict TEXT;
    v_delete_marker_peek_query TEXT;
    v_delete_marker_peek_query_strict TEXT;

BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_is_asc := lower(coalesce(sort_order, 'asc')) = 'asc';
    v_prefix := coalesce(prefix_param, '');
    v_start := CASE WHEN coalesce(next_token, '') <> '' THEN next_token ELSE coalesce(start_after, '') END;
    v_file_batch_size := LEAST(GREATEST(max_keys * 2, 100), 1000);
    v_next_seek_at := NULL;
    v_next_seek_version := '';

    -- COALESCE first: NULL NOT IN (...) evaluates to NULL (not TRUE), so a
    -- bare NOT IN check silently leaves an explicit NULL argument unreset.
    noncurrent_versions := COALESCE(noncurrent_versions, 'exclude');
    delete_markers := COALESCE(delete_markers, 'exclude');
    IF noncurrent_versions NOT IN ('exclude', 'only', 'include') THEN
        noncurrent_versions := 'exclude';
    END IF;
    IF delete_markers NOT IN ('exclude', 'only', 'include') THEN
        delete_markers := 'exclude';
    END IF;

    v_multi_row := noncurrent_versions IN ('only', 'include');
    v_name_order := CASE WHEN v_is_asc THEN 'ASC' ELSE 'DESC' END;

    v_version_filter := '';
    IF noncurrent_versions = 'exclude' THEN
        v_version_filter := v_version_filter || ' AND o.archived_at IS NULL';
    ELSIF noncurrent_versions = 'only' THEN
        v_version_filter := v_version_filter || ' AND o.archived_at IS NOT NULL';
    END IF;
    IF delete_markers = 'exclude' THEN
        v_version_filter := v_version_filter || ' AND NOT o.is_delete_marker';
    ELSIF delete_markers = 'only' THEN
        v_version_filter := v_version_filter || ' AND o.is_delete_marker';
    END IF;

    -- Calculate upper bound for prefix filtering (bytewise, using COLLATE "C")
    IF v_prefix = '' THEN
        v_upper_bound := NULL;
    ELSE
        v_upper_bound := left(v_prefix, -1) || chr(ascii(right(v_prefix, 1)) + 1);
    END IF;

    -- Keep caller-provided cursors inside the requested prefix range.
    IF v_start <> '' AND v_upper_bound IS NOT NULL THEN
        IF v_is_asc THEN
            IF v_start COLLATE "C" < v_prefix COLLATE "C" THEN
                v_start := '';
            ELSIF v_start COLLATE "C" >= v_upper_bound COLLATE "C" THEN
                RETURN;
            END IF;
        ELSE
            IF v_start COLLATE "C" < v_prefix COLLATE "C" THEN
                RETURN;
            ELSIF v_start COLLATE "C" >= v_upper_bound COLLATE "C" THEN
                v_start := '';
            END IF;
        END IF;
    END IF;

    v_start_relative := substring(v_start FROM length(v_prefix) + 1);

    -- Direction affects only the indexed name range and its ordering. Cursor
    -- state transitions and within-key version ordering stay shared.
    IF v_is_asc THEN
        v_exact_range_predicate := 'TRUE';
        v_strict_range_predicate := 'o.name COLLATE "C" > $2';
        v_inclusive_range_predicate := 'o.name COLLATE "C" >= $2';
        IF v_upper_bound IS NOT NULL THEN
            v_exact_range_predicate := 'o.name COLLATE "C" < $3';
            v_strict_range_predicate := v_strict_range_predicate || ' AND o.name COLLATE "C" < $3';
            v_inclusive_range_predicate := v_inclusive_range_predicate || ' AND o.name COLLATE "C" < $3';
        END IF;
    ELSE
        v_exact_range_predicate := 'TRUE';
        v_strict_range_predicate := 'o.name COLLATE "C" < $2';
        v_inclusive_range_predicate := 'o.name COLLATE "C" < $2';
        IF v_prefix <> '' THEN
            v_exact_range_predicate := 'o.name COLLATE "C" >= $3';
            v_strict_range_predicate := v_strict_range_predicate || ' AND o.name COLLATE "C" >= $3';
            v_inclusive_range_predicate := v_inclusive_range_predicate || ' AND o.name COLLATE "C" >= $3';
        END IF;
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    -- The multi-row order matches the externally serialized cursor exactly:
    -- archived_at at millisecond precision, then version as the final tiebreak.
    --
    -- When v_multi_row, the seek is a keyset tuple comparison ("name > $2 OR
    -- (name = $2 AND tiebreak)") - Postgres won't split that OR into indexable
    -- form (confirmed even with fully literal values), so as one WHERE clause
    -- it forces a full bucket scan filtered row-by-row. Splitting it into two
    -- independently-indexable branches (exact name match with the tiebreak
    -- filter, vs. strictly-past names) combined with UNION ALL lets each
    -- branch keep name as a real index condition; the outer ORDER BY/LIMIT
    -- re-merges them into the same page the single query used to produce.
    IF v_multi_row THEN
        v_batch_query := format(
            $sql$
            SELECT *
            FROM (
                (
                    SELECT o.name, o.id, o.updated_at, o.created_at,
                           o.last_accessed_at, o.metadata, o.version,
                           o.archived_at, o.is_delete_marker, o.is_versioned
                    FROM storage.objects o
                    WHERE o.bucket_id = $1
                      AND o.name COLLATE "C" = $2
                      AND %s
                      AND NOT $7::boolean
                      AND (
                          $5::timestamptz IS NULL
                          OR COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) < $5
                          OR (
                              COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) = $5
                              AND COALESCE(o.version, '') > $6
                          )
                      )
                      %s
                    ORDER BY
                        COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) DESC,
                        COALESCE(o.version, '') ASC
                    LIMIT $4
                )
                UNION ALL
                (
                    SELECT o.name, o.id, o.updated_at, o.created_at,
                           o.last_accessed_at, o.metadata, o.version,
                           o.archived_at, o.is_delete_marker, o.is_versioned
                    FROM storage.objects o
                    WHERE o.bucket_id = $1
                      AND %s
                      %s
                    ORDER BY
                        o.name COLLATE "C" %s,
                        COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) DESC,
                        COALESCE(o.version, '') ASC
                    LIMIT $4
                )
            ) sub
            ORDER BY
                sub.name COLLATE "C" %s,
                COALESCE(date_trunc('milliseconds', sub.archived_at), 'infinity'::timestamptz) DESC,
                COALESCE(sub.version, '') ASC
            LIMIT $4
            $sql$,
            v_exact_range_predicate,
            v_version_filter,
            v_strict_range_predicate,
            v_version_filter,
            v_name_order,
            v_name_order
        );
    ELSE
        v_batch_query := format(
            $sql$
            SELECT o.name, o.id, o.updated_at, o.created_at,
                   o.last_accessed_at, o.metadata, o.version,
                   o.archived_at, o.is_delete_marker, o.is_versioned
            FROM storage.objects o
            WHERE o.bucket_id = $1
              AND %s
              %s
            ORDER BY o.name COLLATE "C" %s, o.archived_at DESC
            LIMIT $4
            $sql$,
            v_inclusive_range_predicate,
            v_version_filter,
            v_name_order
        );

        -- Strict counterpart of the query above: used once the single-row
        -- ASC batch advance (below) has left v_next_seek pointing at the
        -- last row already emitted, so an inclusive predicate would
        -- re-match it forever. Only single-row mode ever sets strict mode,
        -- so this variant is never needed when v_multi_row.
        v_batch_query_strict := format(
            $sql$
            SELECT o.name, o.id, o.updated_at, o.created_at,
                   o.last_accessed_at, o.metadata, o.version,
                   o.archived_at, o.is_delete_marker, o.is_versioned
            FROM storage.objects o
            WHERE o.bucket_id = $1
              AND %s
              %s
            ORDER BY o.name COLLATE "C" %s, o.archived_at DESC
            LIMIT $4
            $sql$,
            v_strict_range_predicate,
            v_version_filter,
            v_name_order
        );
    END IF;

    -- The static peek predicates cannot use the partial delete-marker index
    -- once PL/pgSQL switches to a generic plan because whether
    -- is_delete_marker is required remains parameter-dependent. Reuse the
    -- already-specialized batch query with a one-row limit for this sparse
    -- filter so the plan sees a literal `o.is_delete_marker` predicate.
    IF delete_markers = 'only' THEN
        v_delete_marker_peek_query :=
            'SELECT marker_page.name FROM (' || v_batch_query || ') marker_page LIMIT 1';
        IF NOT v_multi_row THEN
            v_delete_marker_peek_query_strict :=
                'SELECT marker_page.name FROM (' || v_batch_query_strict || ') marker_page LIMIT 1';
        END IF;
    END IF;

    -- ========================================================================
    -- SEEK INITIALIZATION: Determine starting position
    -- ========================================================================
    IF v_start = '' THEN
        IF v_is_asc THEN
            v_next_seek := v_prefix;
        ELSE
            -- DESC without cursor performs one specialized initial seek so
            -- partial current-version and delete-marker indexes remain available.
            EXECUTE format(
                'SELECT o.name FROM storage.objects o WHERE o.bucket_id = $1%s%s ORDER BY o.name COLLATE "C" DESC LIMIT 1',
                CASE WHEN v_upper_bound IS NOT NULL
                    THEN ' AND o.name COLLATE "C" >= $2 AND o.name COLLATE "C" < $3'
                    ELSE ''
                END,
                v_version_filter
            )
            INTO v_next_seek
            USING _bucket_id, v_prefix, v_upper_bound;

            IF v_next_seek IS NOT NULL THEN
                v_next_seek := v_next_seek || delimiter_param;
            ELSE
                RETURN;
            END IF;
        END IF;
    ELSE
        -- Folder continuation tokens retain their trailing delimiter. A
        -- delimiter-less startAfter is always a literal key boundary.
        v_cursor_is_folder := delimiter_param <> ''
            AND v_start_relative <> ''
            AND right(v_start_relative, length(delimiter_param)) = delimiter_param;

        IF v_cursor_is_folder THEN
            v_next_seek := CASE
                WHEN right(v_start, length(delimiter_param)) = delimiter_param
                    THEN v_start
                ELSE v_start || delimiter_param
            END;
            IF v_is_asc THEN
                v_next_seek := left(v_next_seek, -1)
                    || chr(ascii(right(v_next_seek, 1)) + 1);
            END IF;
            v_next_seek_strict := NOT v_is_asc;
        ELSE
            -- leaf object: when v_multi_row, stay on v_start with the
            -- caller-supplied tiebreak so a page boundary mid-key resumes
            -- that key's remaining rows instead of skipping them. Truncate
            -- to milliseconds like every other v_next_seek_at assignment -
            -- harmless today since object.ts's cursor always round-trips
            -- through JS Date first, but this shouldn't rely on that.
            IF v_multi_row THEN
                v_next_seek := v_start;
                v_next_seek_at := date_trunc('milliseconds', next_token_archived_at);
                v_next_seek_version := coalesce(next_token_version, '');
                v_next_seek_strict := coalesce(next_token, '') = '';
            ELSIF v_is_asc THEN
                v_next_seek := v_start;
                v_next_seek_strict := true;
            ELSE
                v_next_seek := v_start;
            END IF;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= max_keys;

        v_previous_seek := v_next_seek;
        v_previous_seek_at := v_next_seek_at;
        v_previous_seek_version := v_next_seek_version;
        v_previous_count := v_count;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        -- v_multi_row is branched here (rather than folded into the WHERE
        -- clause as a bound parameter) so each concrete query keeps an
        -- unconditional seek predicate - once PL/pgSQL switches to its
        -- cached generic plan (after 5 calls), a parameter-gated
        -- "(NOT v_multi_row AND name >= $x) OR (v_multi_row AND ...)"
        -- predicate stops the planner from using name as an index
        -- condition at all, degrading every subsequent peek to a full
        -- index scan filtered row-by-row instead of a bounded range scan.
        -- v_multi_row's seek predicate is a keyset tuple comparison
        -- ("name > x OR (name = x AND tiebreak)") - Postgres does not
        -- split this OR into indexable form even with fully literal
        -- values, so it falls back to a full scan filtered row-by-row.
        -- Splitting it into two independently-indexable branches (exact
        -- name match with the tiebreak filter, vs. strictly-past name)
        -- combined with UNION ALL lets each branch keep name as a real
        -- index condition; the outer ORDER BY/LIMIT picks whichever of
        -- the (at most 2) rows sorts first.
        IF delete_markers = 'only' THEN
            EXECUTE CASE WHEN v_next_seek_strict AND NOT v_multi_row
                THEN v_delete_marker_peek_query_strict
                ELSE v_delete_marker_peek_query
            END
                INTO v_peek_name
                USING _bucket_id, v_next_seek,
                    CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix) ELSE v_prefix END,
                    1, v_next_seek_at, v_next_seek_version, v_next_seek_strict;
        ELSIF v_multi_row THEN
            IF v_is_asc THEN
                IF v_upper_bound IS NOT NULL THEN
                    SELECT sub.name INTO v_peek_name FROM (
                        (SELECT o.name FROM storage.objects o
                         WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" = v_next_seek
                           AND o.name COLLATE "C" < v_upper_bound
                           AND NOT v_next_seek_strict
                           AND (v_next_seek_at IS NULL
                                OR COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) < v_next_seek_at
                                OR (COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) = v_next_seek_at
                                    AND COALESCE(o.version, '') > v_next_seek_version))
                           AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                           AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                           AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                           AND (delete_markers != 'only' OR o.is_delete_marker)
                         ORDER BY COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) DESC, COALESCE(o.version, '') ASC LIMIT 1)
                        UNION ALL
                        (SELECT o.name FROM storage.objects o
                         WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" > v_next_seek AND o.name COLLATE "C" < v_upper_bound
                           AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                           AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                           AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                           AND (delete_markers != 'only' OR o.is_delete_marker)
                         ORDER BY o.name COLLATE "C" ASC LIMIT 1)
                    ) sub ORDER BY sub.name COLLATE "C" ASC LIMIT 1;
                ELSE
                    SELECT sub.name INTO v_peek_name FROM (
                        (SELECT o.name FROM storage.objects o
                         WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" = v_next_seek
                           AND NOT v_next_seek_strict
                           AND (v_next_seek_at IS NULL
                                OR COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) < v_next_seek_at
                                OR (COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) = v_next_seek_at
                                    AND COALESCE(o.version, '') > v_next_seek_version))
                           AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                           AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                           AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                           AND (delete_markers != 'only' OR o.is_delete_marker)
                         ORDER BY COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) DESC, COALESCE(o.version, '') ASC LIMIT 1)
                        UNION ALL
                        (SELECT o.name FROM storage.objects o
                         WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" > v_next_seek
                           AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                           AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                           AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                           AND (delete_markers != 'only' OR o.is_delete_marker)
                         ORDER BY o.name COLLATE "C" ASC LIMIT 1)
                    ) sub ORDER BY sub.name COLLATE "C" ASC LIMIT 1;
                END IF;
            ELSE
                IF v_upper_bound IS NOT NULL THEN
                    SELECT sub.name INTO v_peek_name FROM (
                        (SELECT o.name FROM storage.objects o
                         WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" = v_next_seek
                           AND o.name COLLATE "C" >= v_prefix
                           AND NOT v_next_seek_strict
                           AND (v_next_seek_at IS NULL
                                OR COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) < v_next_seek_at
                                OR (COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) = v_next_seek_at
                                    AND COALESCE(o.version, '') > v_next_seek_version))
                           AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                           AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                           AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                           AND (delete_markers != 'only' OR o.is_delete_marker)
                         ORDER BY COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) DESC, COALESCE(o.version, '') ASC LIMIT 1)
                        UNION ALL
                        (SELECT o.name FROM storage.objects o
                         WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                           AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                           AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                           AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                           AND (delete_markers != 'only' OR o.is_delete_marker)
                         ORDER BY o.name COLLATE "C" DESC LIMIT 1)
                    ) sub ORDER BY sub.name COLLATE "C" DESC LIMIT 1;
                ELSE
                    SELECT sub.name INTO v_peek_name FROM (
                        (SELECT o.name FROM storage.objects o
                         WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" = v_next_seek
                           AND NOT v_next_seek_strict
                           AND (v_next_seek_at IS NULL
                                OR COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) < v_next_seek_at
                                OR (COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) = v_next_seek_at
                                    AND COALESCE(o.version, '') > v_next_seek_version))
                           AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                           AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                           AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                           AND (delete_markers != 'only' OR o.is_delete_marker)
                         ORDER BY COALESCE(date_trunc('milliseconds', o.archived_at), 'infinity'::timestamptz) DESC, COALESCE(o.version, '') ASC LIMIT 1)
                        UNION ALL
                        (SELECT o.name FROM storage.objects o
                         WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek
                           AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                           AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                           AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                           AND (delete_markers != 'only' OR o.is_delete_marker)
                         ORDER BY o.name COLLATE "C" DESC LIMIT 1)
                    ) sub ORDER BY sub.name COLLATE "C" DESC LIMIT 1;
                END IF;
            END IF;
        ELSE
            -- Single-row mode is always noncurrent_versions='exclude'. Keep
            -- this predicate literal so generic plans use the current index.
            IF v_is_asc THEN
                IF v_next_seek_strict AND v_upper_bound IS NOT NULL THEN
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = _bucket_id
                      AND o.name COLLATE "C" > v_next_seek
                      AND o.name COLLATE "C" < v_upper_bound
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                      AND (delete_markers != 'only' OR o.is_delete_marker)
                    ORDER BY o.name COLLATE "C" ASC LIMIT 1;
                ELSIF v_next_seek_strict THEN
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = _bucket_id
                      AND o.name COLLATE "C" > v_next_seek
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                      AND (delete_markers != 'only' OR o.is_delete_marker)
                    ORDER BY o.name COLLATE "C" ASC LIMIT 1;
                ELSIF v_upper_bound IS NOT NULL THEN
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = _bucket_id
                      AND o.name COLLATE "C" >= v_next_seek
                      AND o.name COLLATE "C" < v_upper_bound
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                      AND (delete_markers != 'only' OR o.is_delete_marker)
                    ORDER BY o.name COLLATE "C" ASC LIMIT 1;
                ELSE
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = _bucket_id
                      AND o.name COLLATE "C" >= v_next_seek
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                      AND (delete_markers != 'only' OR o.is_delete_marker)
                    ORDER BY o.name COLLATE "C" ASC LIMIT 1;
                END IF;
            ELSE
                IF v_upper_bound IS NOT NULL THEN
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = _bucket_id
                      AND o.name COLLATE "C" < v_next_seek
                      AND o.name COLLATE "C" >= v_prefix
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                      AND (delete_markers != 'only' OR o.is_delete_marker)
                    ORDER BY o.name COLLATE "C" DESC LIMIT 1;
                ELSE
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = _bucket_id
                      AND o.name COLLATE "C" < v_next_seek
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                      AND (delete_markers != 'only' OR o.is_delete_marker)
                    ORDER BY o.name COLLATE "C" DESC LIMIT 1;
                END IF;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(v_peek_name, v_prefix, delimiter_param);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Emit and skip to next folder (no heap access needed)
            name := v_common_prefix;
            id := NULL;
            updated_at := NULL;
            created_at := NULL;
            last_accessed_at := NULL;
            metadata := NULL;
            version := NULL;
            archived_at := NULL;
            is_delete_marker := NULL;
            is_versioned := NULL;
            RETURN NEXT;
            v_count := v_count + 1;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := left(v_common_prefix, -1)
                    || chr(ascii(right(v_common_prefix, 1)) + 1);
            ELSE
                v_next_seek := v_common_prefix;
            END IF;
            v_next_seek_at := NULL;
            v_next_seek_version := '';
            v_next_seek_strict := NOT v_is_asc;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE CASE WHEN v_next_seek_strict AND NOT v_multi_row THEN v_batch_query_strict ELSE v_batch_query END
                USING _bucket_id, v_next_seek,
                CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix) ELSE v_prefix END, v_file_batch_size, v_next_seek_at, v_next_seek_version,
                v_next_seek_strict
            LOOP
                v_common_prefix := storage.get_common_prefix(v_current.name, v_prefix, delimiter_param);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it. Reset
                    -- strict mode too it may have been set by an earlier
                    -- row in this same batch (see the single-row ASC advance
                    -- below), and v_next_seek here is the folder-triggering
                    -- row's own name, which the next peek must find inclusively.
                    v_next_seek := CASE
                        WHEN v_is_asc THEN v_current.name
                        ELSE v_current.name || delimiter_param
                    END;
                    v_next_seek_at := NULL;
                    v_next_seek_version := '';
                    v_next_seek_strict := false;
                    EXIT;
                END IF;

                -- Emit file
                name := v_current.name;
                id := v_current.id;
                updated_at := v_current.updated_at;
                created_at := v_current.created_at;
                last_accessed_at := v_current.last_accessed_at;
                metadata := v_current.metadata;
                version := v_current.version;
                archived_at := v_current.archived_at;
                is_delete_marker := v_current.is_delete_marker;
                is_versioned := v_current.is_versioned;
                RETURN NEXT;
                v_count := v_count + 1;

                -- when v_multi_row, stay on this name and record its
                -- archived_at as the new tiebreak so remaining rows for the
                -- same key are picked up before moving to the next name
                IF v_multi_row THEN
                    v_next_seek := v_current.name;
                    v_next_seek_at := COALESCE(date_trunc('milliseconds', v_current.archived_at), 'infinity'::timestamptz);
                    v_next_seek_version := COALESCE(v_current.version, '');
                    v_next_seek_strict := false;
                ELSIF v_is_asc THEN
                    -- Appending the delimiter as a fake lexical successor
                    -- would skip a real key like `name || '!'` (or any
                    -- character sorting below the delimiter), which sorts
                    -- between `name` and `name || delimiter`. Track the real
                    -- name and mark the next comparison strict instead.
                    v_next_seek := v_current.name;
                    v_next_seek_strict := true;
                ELSE
                    v_next_seek := v_current.name;
                END IF;

                EXIT WHEN v_count >= max_keys;
            END LOOP;
        END IF;

        IF v_count = v_previous_count
           AND v_next_seek IS NOT DISTINCT FROM v_previous_seek
           AND v_next_seek_at IS NOT DISTINCT FROM v_previous_seek_at
           AND v_next_seek_version IS NOT DISTINCT FROM v_previous_seek_version THEN
            RAISE EXCEPTION 'storage.list_objects_with_delimiter made no progress at seek (%, %, %)',
                v_next_seek, v_next_seek_at, v_next_seek_version;
        END IF;
    END LOOP;
END;
$_$;


--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


--
-- Name: protect_active_lifecycle_states(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.protect_active_lifecycle_states() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM storage.bucket_lifecycle_states
        WHERE bucket_id = OLD.id
          AND NOT (
              continuation IS NULL
              OR (continuation @> '{"continuationVersion": 1}' AND continuation #> '{batch,inFlight}' IS NULL)
          )
    ) THEN
        RAISE EXCEPTION 'update or delete on table "buckets" violates foreign key constraint "bucket_lifecycle_states_bucket_id_fkey" on table "bucket_lifecycle_states"'
            USING ERRCODE = 'foreign_key_violation',
                  DETAIL = format('Key (id)=(%s) is still referenced from table "bucket_lifecycle_states".', OLD.id),
                  SCHEMA = 'storage',
                  TABLE = 'bucket_lifecycle_states',
                  CONSTRAINT = 'bucket_lifecycle_states_bucket_id_fkey';
    END IF;
    RETURN OLD;
END;
$$;


--
-- Name: protect_bucket_control_columns(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.protect_bucket_control_columns() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog'
    AS $$
DECLARE
  configuration_changed boolean;
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.lifecycle_configuration IS NOT NULL
       OR NEW.lifecycle_configuration_generation IS NOT NULL THEN
      IF NOT pg_has_role(current_user, TG_ARGV[0], 'MEMBER') THEN
        RAISE EXCEPTION 'only members of the configured storage service role may insert lifecycle policy state'
          USING ERRCODE = '42501',
                HINT = format(
                  'Insert with both lifecycle columns NULL and configure lifecycle through the Storage API afterward, or insert as a member of %I.',
                  TG_ARGV[0]
                );
      END IF;
    END IF;

    RETURN NEW;
  END IF;

  configuration_changed =
    OLD.lifecycle_configuration IS DISTINCT FROM NEW.lifecycle_configuration
    OR OLD.lifecycle_configuration_generation IS DISTINCT FROM NEW.lifecycle_configuration_generation;

  IF NOT configuration_changed THEN
    RETURN NEW;
  END IF;

  IF NEW.type IS DISTINCT FROM 'STANDARD' THEN
    RAISE EXCEPTION 'bucket versioning and lifecycle controls require a Standard bucket'
      USING ERRCODE = '0A000';
  END IF;

  IF NEW.lifecycle_configuration IS NULL
     AND NEW.lifecycle_configuration_generation IS NULL THEN
    RETURN NEW;
  END IF;

  IF NEW.lifecycle_configuration IS NULL
     OR NEW.lifecycle_configuration_generation IS NULL
     OR OLD.lifecycle_configuration IS NOT DISTINCT FROM NEW.lifecycle_configuration
     OR OLD.lifecycle_configuration_generation IS NOT DISTINCT FROM NEW.lifecycle_configuration_generation THEN
    RAISE EXCEPTION 'a changed lifecycle policy requires a new non-null generation'
      USING ERRCODE = '22023';
  END IF;

  RETURN NEW;
END;
$$;


--
-- Name: protect_delete(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.protect_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if storage.allow_delete_query is set to 'true'
    IF COALESCE(current_setting('storage.allow_delete_query', true), 'false') != 'true' THEN
        RAISE EXCEPTION 'Direct deletion from storage tables is not allowed. Use the Storage API instead.'
            USING HINT = 'This prevents accidental data loss from orphaned objects.',
                  ERRCODE = '42501';
    END IF;
    RETURN NULL;
END;
$$;


--
-- Name: reconcile_lifecycle_state(text, boolean); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.reconcile_lifecycle_state(target_bucket_id text, policy_changed boolean) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
DECLARE
    bucket storage.buckets%ROWTYPE;
    active boolean;
    idle boolean;
    state_generation uuid;
BEGIN
    SELECT * INTO bucket FROM storage.buckets WHERE id = target_bucket_id FOR NO KEY UPDATE;
    IF NOT FOUND THEN
        RETURN;
    END IF;

    SELECT continuation IS NULL OR (
               continuation @> '{"continuationVersion": 1}'
               AND continuation #> '{batch,inFlight}' IS NULL
           ), generation
    INTO idle, state_generation
    FROM storage.bucket_lifecycle_states
    WHERE bucket_id = target_bucket_id
    FOR UPDATE;

    IF bucket.lifecycle_configuration IS NULL THEN
        DELETE FROM storage.bucket_lifecycle_states
        WHERE bucket_id = target_bucket_id
          AND idle IS TRUE;

        UPDATE storage.bucket_lifecycle_states
        SET next_run_at = clock_timestamp(), updated_at = clock_timestamp()
        WHERE bucket_id = target_bucket_id
          AND idle IS NOT TRUE;
        RETURN;
    END IF;

    active := bucket.versioning_status <> 'DISABLED'
        AND bucket.lifecycle_configuration @> '{"rules":[{"status":"Enabled"}]}'::jsonb;

    -- The state row records the generation it was reconciled with so callers need not detect
    -- policy changes. Rows without a recorded generation keep their work.
    policy_changed := policy_changed OR (
        state_generation IS NOT NULL AND state_generation <> bucket.lifecycle_configuration_generation
    );

    INSERT INTO storage.bucket_lifecycle_states AS state (bucket_id, generation, next_run_at)
    VALUES (bucket.id, bucket.lifecycle_configuration_generation, CASE WHEN active THEN clock_timestamp() END)
    ON CONFLICT (bucket_id) DO UPDATE
    SET next_run_at = CASE
            WHEN policy_changed THEN
                CASE WHEN active OR idle IS NOT TRUE THEN clock_timestamp() END
            ELSE EXCLUDED.next_run_at
        END,
        generation = EXCLUDED.generation,
        claim_id = CASE WHEN policy_changed AND idle IS TRUE
                        THEN NULL ELSE state.claim_id END,
        claim_until = CASE WHEN policy_changed AND idle IS TRUE
                           THEN NULL ELSE state.claim_until END,
        continuation = CASE WHEN policy_changed AND idle IS TRUE
                            THEN NULL ELSE state.continuation END,
        failure_count = CASE WHEN policy_changed AND idle IS TRUE
                             THEN 0 ELSE state.failure_count END,
        last_error = CASE WHEN policy_changed AND idle IS TRUE
                          THEN NULL ELSE state.last_error END,
        updated_at = clock_timestamp()
    WHERE policy_changed OR (state.next_run_at IS NULL AND EXCLUDED.next_run_at IS NOT NULL);
END;
$$;


--
-- Name: search(text, text, integer, integer, integer, text, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text, noncurrent_versions text DEFAULT 'exclude'::text, delete_markers text DEFAULT 'exclude'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb, version text, archived_at timestamp with time zone, is_delete_marker boolean, is_versioned boolean)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;
    v_delimiter CONSTANT TEXT := '/';

    -- Configuration
    v_limit INT;
    v_prefix TEXT;
    v_prefix_lower TEXT;
    v_prefix_len INT;
    v_prefix_start INT;
    v_combined_levels INT;
    v_is_asc BOOLEAN;
    v_order_by TEXT;
    v_sort_order TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;
    v_version_filter TEXT;
    v_multi_row BOOLEAN;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;
    v_delete_marker_peek_query TEXT;
    v_delete_marker_peek_query_strict TEXT;

    -- Seek state
    v_next_seek TEXT;
    v_next_seek_at TIMESTAMPTZ;
    v_next_seek_version TEXT;
    v_next_seek_strict BOOLEAN := false;
    v_count INT := 0;
    v_skipped INT := 0;
    v_previous_seek TEXT;
    v_previous_seek_at TIMESTAMPTZ;
    v_previous_seek_version TEXT;
    v_previous_count INT;
    v_previous_skipped INT;
BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_limit := LEAST(coalesce(limits, 100), 1500);
    v_prefix := coalesce(prefix, '') || coalesce(search, '');
    v_prefix_lower := lower(v_prefix);
    v_prefix_len := length(coalesce(prefix, ''));
    v_prefix_start := coalesce(array_length(string_to_array(coalesce(prefix, ''), v_delimiter), 1), 1);
    v_combined_levels := coalesce(array_length(string_to_array(v_prefix, v_delimiter), 1), 1);
    v_is_asc := lower(coalesce(sortorder, 'asc')) = 'asc';
    v_file_batch_size := LEAST(GREATEST(v_limit * 2, 100), 1000);
    v_next_seek_at := NULL;
    v_next_seek_version := '';

    -- COALESCE first: NULL NOT IN (...) evaluates to NULL (not TRUE), so a
    -- bare NOT IN check silently leaves an explicit NULL argument unreset.
    noncurrent_versions := COALESCE(noncurrent_versions, 'exclude');
    delete_markers := COALESCE(delete_markers, 'exclude');
    IF noncurrent_versions NOT IN ('exclude', 'only', 'include') THEN
        noncurrent_versions := 'exclude';
    END IF;
    IF delete_markers NOT IN ('exclude', 'only', 'include') THEN
        delete_markers := 'exclude';
    END IF;

    v_multi_row := noncurrent_versions IN ('only', 'include');

    v_version_filter := '';
    IF noncurrent_versions = 'exclude' THEN
        v_version_filter := v_version_filter || ' AND o.archived_at IS NULL';
    ELSIF noncurrent_versions = 'only' THEN
        v_version_filter := v_version_filter || ' AND o.archived_at IS NOT NULL';
    END IF;
    IF delete_markers = 'exclude' THEN
        v_version_filter := v_version_filter || ' AND NOT o.is_delete_marker';
    ELSIF delete_markers = 'only' THEN
        v_version_filter := v_version_filter || ' AND o.is_delete_marker';
    END IF;

    -- Validate sort column
    CASE lower(coalesce(sortcolumn, 'name'))
        WHEN 'name' THEN v_order_by := 'name';
        WHEN 'updated_at' THEN v_order_by := 'updated_at';
        WHEN 'created_at' THEN v_order_by := 'created_at';
        WHEN 'last_accessed_at' THEN v_order_by := 'last_accessed_at';
        ELSE v_order_by := 'name';
    END CASE;

    v_sort_order := CASE WHEN v_is_asc THEN 'asc' ELSE 'desc' END;

    -- ========================================================================
    -- NON-NAME SORTING: Use path_tokens approach
    -- ========================================================================
    IF v_order_by != 'name' THEN
        RETURN QUERY EXECUTE format(
            $sql$
            WITH folders AS (
                SELECT array_to_string(path_tokens[$1:$2], '/') AS folder
                FROM storage.objects
                WHERE objects.name ILIKE $3 || '%%'
                  AND bucket_id = $4
                  AND array_length(objects.path_tokens, 1) <> $2
                  AND ($7 != 'exclude' OR objects.archived_at IS NULL)
                  AND ($7 != 'only' OR objects.archived_at IS NOT NULL)
                  AND ($8 != 'exclude' OR NOT objects.is_delete_marker)
                  AND ($8 != 'only' OR objects.is_delete_marker)
                GROUP BY folder
                ORDER BY folder %s
            )
            (SELECT folder AS "name",
                   NULL::uuid AS id,
                   NULL::timestamptz AS updated_at,
                   NULL::timestamptz AS created_at,
                   NULL::timestamptz AS last_accessed_at,
                   NULL::jsonb AS metadata,
                   NULL::text AS version,
                   NULL::timestamptz AS archived_at,
                   NULL::boolean AS is_delete_marker,
                   NULL::boolean AS is_versioned FROM folders)
            UNION ALL
            (SELECT array_to_string(path_tokens[$1:$2], '/') AS "name",
                   id, updated_at, created_at, last_accessed_at, metadata,
                   version, archived_at, is_delete_marker, is_versioned
             FROM storage.objects
             WHERE objects.name ILIKE $3 || '%%'
               AND bucket_id = $4
               AND array_length(objects.path_tokens, 1) = $2
               AND ($7 != 'exclude' OR objects.archived_at IS NULL)
               AND ($7 != 'only' OR objects.archived_at IS NOT NULL)
               AND ($8 != 'exclude' OR NOT objects.is_delete_marker)
               AND ($8 != 'only' OR objects.is_delete_marker)
             -- name, then version, as tiebreaks so two versions of the same
             -- key tying on the sort column still sort deterministically
             ORDER BY %I %s, name COLLATE "C" %s, COALESCE(version, '') %s)
            LIMIT $5 OFFSET $6
            $sql$, v_sort_order, v_order_by, v_sort_order, v_sort_order, v_sort_order
        ) USING v_prefix_start, v_combined_levels, v_prefix, bucketname, v_limit, offsets, noncurrent_versions, delete_markers;
        RETURN;
    END IF;

    -- ========================================================================
    -- NAME SORTING: Hybrid skip-scan with batch optimization
    -- ========================================================================

    -- Calculate upper bound for prefix filtering
    IF v_prefix_lower = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix_lower, 1) = v_delimiter THEN
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(v_delimiter) + 1);
    ELSE
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(right(v_prefix_lower, 1)) + 1);
    END IF;

    -- Build a resume-safe batch query. The exact-name branch returns remaining
    -- versions after the current (archived_at, version) boundary; the strict
    -- name branch returns subsequent keys. UNION ALL keeps both predicates
    -- independently indexable.
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT * FROM (' ||
                '(SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata, o.version, o.archived_at, o.is_delete_marker, o.is_versioned FROM storage.objects o ' ||
                'WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" = $2 AND ($5::timestamptz IS NULL OR COALESCE(o.archived_at, ''infinity''::timestamptz) < $5 OR (COALESCE(o.archived_at, ''infinity''::timestamptz) = $5 AND COALESCE(o.version, '''') > $6))' ||
                v_version_filter || ' ORDER BY COALESCE(o.archived_at, ''infinity''::timestamptz) DESC, COALESCE(o.version, '''') ASC LIMIT $4) UNION ALL ' ||
                '(SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata, o.version, o.archived_at, o.is_delete_marker, o.is_versioned FROM storage.objects o ' ||
                'WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" > $2 AND lower(o.name) COLLATE "C" < $3' || v_version_filter ||
                ' ORDER BY lower(o.name) COLLATE "C" ASC, COALESCE(o.archived_at, ''infinity''::timestamptz) DESC, COALESCE(o.version, '''') ASC LIMIT $4)' ||
                ') sub ORDER BY lower(sub.name) COLLATE "C" ASC, COALESCE(sub.archived_at, ''infinity''::timestamptz) DESC, COALESCE(sub.version, '''') ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT * FROM (' ||
                '(SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata, o.version, o.archived_at, o.is_delete_marker, o.is_versioned FROM storage.objects o ' ||
                'WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" = $2 AND ($5::timestamptz IS NULL OR COALESCE(o.archived_at, ''infinity''::timestamptz) < $5 OR (COALESCE(o.archived_at, ''infinity''::timestamptz) = $5 AND COALESCE(o.version, '''') > $6))' ||
                v_version_filter || ' ORDER BY COALESCE(o.archived_at, ''infinity''::timestamptz) DESC, COALESCE(o.version, '''') ASC LIMIT $4) UNION ALL ' ||
                '(SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata, o.version, o.archived_at, o.is_delete_marker, o.is_versioned FROM storage.objects o ' ||
                'WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" > $2' || v_version_filter ||
                ' ORDER BY lower(o.name) COLLATE "C" ASC, COALESCE(o.archived_at, ''infinity''::timestamptz) DESC, COALESCE(o.version, '''') ASC LIMIT $4)' ||
                ') sub ORDER BY lower(sub.name) COLLATE "C" ASC, COALESCE(sub.archived_at, ''infinity''::timestamptz) DESC, COALESCE(sub.version, '''') ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT * FROM (' ||
                '(SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata, o.version, o.archived_at, o.is_delete_marker, o.is_versioned FROM storage.objects o ' ||
                'WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" = $2 AND ($5::timestamptz IS NULL OR COALESCE(o.archived_at, ''infinity''::timestamptz) < $5 OR (COALESCE(o.archived_at, ''infinity''::timestamptz) = $5 AND COALESCE(o.version, '''') > $6))' ||
                v_version_filter || ' ORDER BY COALESCE(o.archived_at, ''infinity''::timestamptz) DESC, COALESCE(o.version, '''') ASC LIMIT $4) UNION ALL ' ||
                '(SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata, o.version, o.archived_at, o.is_delete_marker, o.is_versioned FROM storage.objects o ' ||
                'WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 AND lower(o.name) COLLATE "C" >= $3' || v_version_filter ||
                ' ORDER BY lower(o.name) COLLATE "C" DESC, COALESCE(o.archived_at, ''infinity''::timestamptz) DESC, COALESCE(o.version, '''') ASC LIMIT $4)' ||
                ') sub ORDER BY lower(sub.name) COLLATE "C" DESC, COALESCE(sub.archived_at, ''infinity''::timestamptz) DESC, COALESCE(sub.version, '''') ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT * FROM (' ||
                '(SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata, o.version, o.archived_at, o.is_delete_marker, o.is_versioned FROM storage.objects o ' ||
                'WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" = $2 AND ($5::timestamptz IS NULL OR COALESCE(o.archived_at, ''infinity''::timestamptz) < $5 OR (COALESCE(o.archived_at, ''infinity''::timestamptz) = $5 AND COALESCE(o.version, '''') > $6))' ||
                v_version_filter || ' ORDER BY COALESCE(o.archived_at, ''infinity''::timestamptz) DESC, COALESCE(o.version, '''') ASC LIMIT $4) UNION ALL ' ||
                '(SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata, o.version, o.archived_at, o.is_delete_marker, o.is_versioned FROM storage.objects o ' ||
                'WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2' || v_version_filter ||
                ' ORDER BY lower(o.name) COLLATE "C" DESC, COALESCE(o.archived_at, ''infinity''::timestamptz) DESC, COALESCE(o.version, '''') ASC LIMIT $4)' ||
                ') sub ORDER BY lower(sub.name) COLLATE "C" DESC, COALESCE(sub.archived_at, ''infinity''::timestamptz) DESC, COALESCE(sub.version, '''') ASC LIMIT $4';
        END IF;
    END IF;

    -- Keep the delete-marker predicate literal so the cached generic
    -- plan can use idx_objects_delete_markers during the main-loop peek.
    IF delete_markers = 'only' THEN
        IF v_multi_row THEN
            v_delete_marker_peek_query :=
                'SELECT marker_page.name FROM (' || v_batch_query || ') marker_page LIMIT 1';
        ELSIF v_is_asc THEN
            -- Two separate literal query strings, not one gated by a bound
            -- boolean: folding "$n AND op1 OR NOT $n AND op2" into a single
            -- query defeats the generic plan's ability to push either
            -- comparison into the index. Branching in PL/pgSQL control flow
            -- instead keeps each query's index condition intact.
            v_delete_marker_peek_query :=
                'SELECT o.name FROM storage.objects o WHERE o.bucket_id = $1 ' ||
                'AND lower(o.name) COLLATE "C" >= $2' ||
                CASE WHEN v_upper_bound IS NOT NULL
                    THEN ' AND lower(o.name) COLLATE "C" < $3'
                    ELSE ''
                END ||
                v_version_filter ||
                ' ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1';
            -- Strict variant: used once the single-row ASC batch advance
            -- (below) has left v_next_seek pointing at the last row already
            -- emitted, so a plain >= would re-match it forever.
            v_delete_marker_peek_query_strict :=
                'SELECT o.name FROM storage.objects o WHERE o.bucket_id = $1 ' ||
                'AND lower(o.name) COLLATE "C" > $2' ||
                CASE WHEN v_upper_bound IS NOT NULL
                    THEN ' AND lower(o.name) COLLATE "C" < $3'
                    ELSE ''
                END ||
                v_version_filter ||
                ' ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1';
        ELSE
            v_delete_marker_peek_query :=
                'SELECT o.name FROM storage.objects o WHERE o.bucket_id = $1 ' ||
                'AND lower(o.name) COLLATE "C" < $2' ||
                CASE WHEN v_upper_bound IS NOT NULL
                    THEN ' AND lower(o.name) COLLATE "C" >= $3'
                    ELSE ''
                END ||
                v_version_filter ||
                ' ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1';
        END IF;
    END IF;

    -- Initialize seek position
    IF v_is_asc THEN
        v_next_seek := v_prefix_lower;
    ELSE
        -- DESC performs one specialized initial seek so partial current-version
        -- and delete-marker indexes remain available.
        EXECUTE format(
            'SELECT o.name FROM storage.objects o WHERE o.bucket_id = $1%s%s ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1',
            CASE WHEN v_upper_bound IS NOT NULL
                THEN ' AND lower(o.name) COLLATE "C" >= $2 AND lower(o.name) COLLATE "C" < $3'
                ELSE ''
            END,
            v_version_filter
        )
        INTO v_peek_name
        USING bucketname, v_prefix_lower, v_upper_bound;

        IF v_peek_name IS NOT NULL THEN
            v_next_seek := lower(v_peek_name) || v_delimiter;
        ELSE
            RETURN;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch and
    -- the delete-marker-only path
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= v_limit;

        v_previous_seek := v_next_seek;
        v_previous_seek_at := v_next_seek_at;
        v_previous_seek_version := v_next_seek_version;
        v_previous_count := v_count;
        v_previous_skipped := v_skipped;

        -- STEP 1: PEEK
        v_peek_name := NULL;
        IF delete_markers = 'only' THEN
            EXECUTE CASE WHEN v_next_seek_strict
                THEN v_delete_marker_peek_query_strict
                ELSE v_delete_marker_peek_query
            END
                INTO v_peek_name
                USING bucketname, v_next_seek,
                    CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix_lower) ELSE v_prefix_lower END,
                    1, v_next_seek_at, v_next_seek_version;
        ELSIF v_multi_row AND v_next_seek_at IS NOT NULL THEN
            SELECT o.name INTO v_peek_name
            FROM storage.objects o
            WHERE o.bucket_id = bucketname
              AND lower(o.name) COLLATE "C" = v_next_seek
              AND (COALESCE(o.archived_at, 'infinity'::timestamptz) < v_next_seek_at
                   OR (COALESCE(o.archived_at, 'infinity'::timestamptz) = v_next_seek_at
                       AND COALESCE(o.version, '') > v_next_seek_version))
              AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
              AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
              AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
              AND (delete_markers != 'only' OR o.is_delete_marker)
            ORDER BY COALESCE(o.archived_at, 'infinity'::timestamptz) DESC,
                     COALESCE(o.version, '') ASC
            LIMIT 1;

            -- The current key is exhausted. Clear its version boundary and
            -- make the following ASC name peek strict. Appending '/' is not a
            -- valid lexical successor because keys ending in characters such
            -- as '!' sort between the exhausted name and name || '/'.
            IF v_peek_name IS NULL THEN
                IF v_is_asc THEN
                    v_next_seek_strict := true;
                END IF;
                v_next_seek_at := NULL;
                v_next_seek_version := '';
            END IF;
        END IF;

        -- Single-row mode is always noncurrent_versions='exclude'. Keep the
        -- current-row predicate literal so generic plans use the current index.
        IF delete_markers != 'only' AND v_peek_name IS NULL AND NOT v_multi_row THEN
            IF v_is_asc THEN
                IF v_next_seek_strict AND v_upper_bound IS NOT NULL THEN
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" > v_next_seek AND lower(o.name) COLLATE "C" < v_upper_bound
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                    ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
                ELSIF v_next_seek_strict THEN
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" > v_next_seek
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                    ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
                ELSIF v_upper_bound IS NOT NULL THEN
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek AND lower(o.name) COLLATE "C" < v_upper_bound
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                    ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
                ELSE
                    SELECT o.name INTO v_peek_name FROM storage.objects o
                    WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek
                      AND o.archived_at IS NULL
                      AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                    ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
                END IF;
            ELSIF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                  AND o.archived_at IS NULL
                  AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek
                  AND o.archived_at IS NULL
                  AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            END IF;
        ELSIF delete_markers != 'only' AND v_peek_name IS NULL AND v_is_asc THEN
            IF v_next_seek_strict AND v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" > v_next_seek AND lower(o.name) COLLATE "C" < v_upper_bound
                  AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                  AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                  AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                  AND (delete_markers != 'only' OR o.is_delete_marker)
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            ELSIF v_next_seek_strict THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" > v_next_seek
                  AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                  AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                  AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                  AND (delete_markers != 'only' OR o.is_delete_marker)
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            ELSIF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek AND lower(o.name) COLLATE "C" < v_upper_bound
                  AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                  AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                  AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                  AND (delete_markers != 'only' OR o.is_delete_marker)
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek
                  AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                  AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                  AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                  AND (delete_markers != 'only' OR o.is_delete_marker)
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSIF delete_markers != 'only' AND v_peek_name IS NULL THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                  AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                  AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                  AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                  AND (delete_markers != 'only' OR o.is_delete_marker)
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek
                  AND (noncurrent_versions != 'exclude' OR o.archived_at IS NULL)
                  AND (noncurrent_versions != 'only' OR o.archived_at IS NOT NULL)
                  AND (delete_markers != 'exclude' OR NOT o.is_delete_marker)
                  AND (delete_markers != 'only' OR o.is_delete_marker)
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- If the peek landed on a different key than we were tracking, any
        -- version boundary belongs to the OLD key and must not leak into the
        -- new one - e.g. the deleteMarkers='only' peek doesn't know or care
        -- whether it's continuing the same key or jumping to a new one, so
        -- it never clears these itself.
        IF lower(v_peek_name) IS DISTINCT FROM v_next_seek THEN
            v_next_seek_at := NULL;
            v_next_seek_version := '';
        END IF;

        -- The peek is authoritative for the next key to process. This is
        -- especially important after exhausting a multi-version key: the
        -- version boundary has been cleared, so executing the batch against
        -- a stale v_next_seek would replay every version of that old key.
        v_next_seek := lower(v_peek_name);
        v_next_seek_strict := false;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(lower(v_peek_name), v_prefix_lower, v_delimiter);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Handle offset, emit if needed, skip to next folder
            IF v_skipped < offsets THEN
                v_skipped := v_skipped + 1;
            ELSE
                name := substring(rtrim(storage.get_common_prefix(v_peek_name, v_prefix, v_delimiter), v_delimiter) from v_prefix_len + 1);
                id := NULL;
                updated_at := NULL;
                created_at := NULL;
                last_accessed_at := NULL;
                metadata := NULL;
                version := NULL;
                archived_at := NULL;
                is_delete_marker := NULL;
                is_versioned := NULL;
                RETURN NEXT;
                v_count := v_count + 1;
            END IF;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := lower(left(v_common_prefix, -1)) || chr(ascii(v_delimiter) + 1);
            ELSE
                v_next_seek := lower(v_common_prefix);
            END IF;
            v_next_seek_at := NULL;
            v_next_seek_version := '';
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix_lower is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query
                USING bucketname, v_next_seek,
                    CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix_lower) ELSE v_prefix_lower END, v_file_batch_size,
                    v_next_seek_at, v_next_seek_version
            LOOP
                v_common_prefix := storage.get_common_prefix(lower(v_current.name), v_prefix_lower, v_delimiter);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it. Reset
                    -- strict mode too - it may have been set by an earlier
                    -- row in this same batch (see the single-row ASC advance
                    -- below), and v_next_seek here is the folder-triggering
                    -- row's own name, which the next peek must find inclusively.
                    v_next_seek := CASE
                        WHEN v_is_asc THEN lower(v_current.name)
                        ELSE lower(v_current.name) || v_delimiter
                    END;
                    v_next_seek_at := NULL;
                    v_next_seek_version := '';
                    v_next_seek_strict := false;
                    EXIT;
                END IF;

                -- Handle offset skipping
                IF v_skipped < offsets THEN
                    v_skipped := v_skipped + 1;
                ELSE
                    -- Emit file
                    name := substring(v_current.name from v_prefix_len + 1);
                    id := v_current.id;
                    updated_at := v_current.updated_at;
                    created_at := v_current.created_at;
                    last_accessed_at := v_current.last_accessed_at;
                    metadata := v_current.metadata;
                    version := v_current.version;
                    archived_at := v_current.archived_at;
                    is_delete_marker := v_current.is_delete_marker;
                    is_versioned := v_current.is_versioned;
                    RETURN NEXT;
                    v_count := v_count + 1;
                END IF;

                -- Multi-row mode must remain on this key until all of its
                -- versions have crossed the internal batch boundary.
                IF v_multi_row THEN
                    v_next_seek := lower(v_current.name);
                    v_next_seek_at := COALESCE(v_current.archived_at, 'infinity'::timestamptz);
                    v_next_seek_version := COALESCE(v_current.version, '');
                ELSIF v_is_asc THEN
                    -- Appending the delimiter as a fake lexical successor would
                    -- skip a real key like `name || '!'` (or any character
                    -- sorting below the delimiter), which sorts between `name`
                    -- and `name || delimiter`. Track the real name and mark the
                    -- next comparison strict instead - same fix as the
                    -- exhausted-key case above.
                    v_next_seek := lower(v_current.name);
                    v_next_seek_strict := true;
                ELSE
                    v_next_seek := lower(v_current.name);
                END IF;

                EXIT WHEN v_count >= v_limit;
            END LOOP;
        END IF;

        IF v_count = v_previous_count
           AND v_skipped = v_previous_skipped
           AND v_next_seek IS NOT DISTINCT FROM v_previous_seek
           AND v_next_seek_at IS NOT DISTINCT FROM v_previous_seek_at
           AND v_next_seek_version IS NOT DISTINCT FROM v_previous_seek_version THEN
            RAISE EXCEPTION 'storage.search made no progress at seek (%, %, %)',
                v_next_seek, v_next_seek_at, v_next_seek_version;
        END IF;
    END LOOP;
END;
$_$;


--
-- Name: search_by_timestamp(text, text, integer, integer, text, text, text, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_by_timestamp(p_prefix text, p_bucket_id text, p_limit integer, p_level integer, p_start_after text, p_sort_order text, p_sort_column text, p_sort_column_after text, noncurrent_versions text DEFAULT 'exclude'::text, delete_markers text DEFAULT 'exclude'::text, p_start_after_version text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb, version text, archived_at timestamp with time zone, is_delete_marker boolean, is_versioned boolean)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_cursor_op text;
    v_query text;
    v_prefix text;
    v_prefix_pattern text;
    v_sort_order text;
    v_sort_column text;
    v_version_tiebreak text;
BEGIN
    v_prefix := coalesce(p_prefix, '');
    -- Keep the raw prefix for common-prefix calculations and escape only LIKE metacharacters.
    v_prefix_pattern := replace(v_prefix, chr(92), chr(92) || chr(92));
    v_prefix_pattern := replace(v_prefix_pattern, '%', chr(92) || '%');
    v_prefix_pattern := replace(v_prefix_pattern, '_', chr(92) || '_');

    -- COALESCE first: NULL NOT IN (...) evaluates to NULL (not TRUE), so a
    -- bare NOT IN check silently leaves an explicit NULL argument unreset.
    noncurrent_versions := COALESCE(noncurrent_versions, 'exclude');
    delete_markers := COALESCE(delete_markers, 'exclude');
    IF noncurrent_versions NOT IN ('exclude', 'only', 'include') THEN
        noncurrent_versions := 'exclude';
    END IF;
    IF delete_markers NOT IN ('exclude', 'only', 'include') THEN
        delete_markers := 'exclude';
    END IF;

    -- $9 is only populated in multi-row mode; it's always '' otherwise, so
    -- only use each row's real version as a tiebreak in multi-row mode.
    v_version_tiebreak := CASE WHEN noncurrent_versions IN ('only', 'include') THEN 'COALESCE(version, '''')' ELSE '''''' END;

    -- Defense-in-depth: this function is independently reachable and must
    -- not trust p_sort_order/p_sort_column to already be validated by a
    -- caller. Normalize to the same strict allow-list storage.search_v2
    -- uses before interpolating anything into dynamic SQL below.
    v_sort_order := lower(coalesce(p_sort_order, 'asc'));
    IF v_sort_order NOT IN ('asc', 'desc') THEN
        v_sort_order := 'asc';
    END IF;

    v_sort_column := lower(coalesce(p_sort_column, 'updated_at'));
    IF v_sort_column NOT IN ('updated_at', 'created_at') THEN
        v_sort_column := 'updated_at';
    END IF;

    IF v_sort_order = 'asc' THEN
        v_cursor_op := '>';
    ELSE
        v_cursor_op := '<';
    END IF;

    v_query := format($sql$
        WITH raw_objects AS (
            SELECT
                o.name AS obj_name,
                o.id AS obj_id,
                o.updated_at AS obj_updated_at,
                o.created_at AS obj_created_at,
                o.last_accessed_at AS obj_last_accessed_at,
                o.metadata AS obj_metadata,
                o.version AS obj_version,
                o.archived_at AS obj_archived_at,
                o.is_delete_marker AS obj_is_delete_marker,
                o.is_versioned AS obj_is_versioned,
                storage.get_common_prefix(o.name, $1, '/') AS common_prefix
            FROM storage.objects o
            WHERE o.bucket_id = $2
              AND o.name COLLATE "C" LIKE $10 || '%%'
              AND ($7 != 'exclude' OR o.archived_at IS NULL)
              AND ($7 != 'only' OR o.archived_at IS NOT NULL)
              AND ($8 != 'exclude' OR NOT o.is_delete_marker)
              AND ($8 != 'only' OR o.is_delete_marker)
        ),
        -- Aggregate common prefixes (folders)
        -- Both created_at and updated_at use MIN(obj_created_at) to match the old prefixes table behavior
        aggregated_prefixes AS (
            SELECT
                common_prefix AS name,
                NULL::uuid AS id,
                MIN(obj_created_at) AS updated_at,
                MIN(obj_created_at) AS created_at,
                NULL::timestamptz AS last_accessed_at,
                NULL::jsonb AS metadata,
                NULL::text AS version,
                NULL::timestamptz AS archived_at,
                NULL::boolean AS is_delete_marker,
                NULL::boolean AS is_versioned,
                TRUE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NOT NULL
            GROUP BY common_prefix
        ),
        leaf_objects AS (
            SELECT
                obj_name AS name,
                obj_id AS id,
                obj_updated_at AS updated_at,
                obj_created_at AS created_at,
                obj_last_accessed_at AS last_accessed_at,
                obj_metadata AS metadata,
                obj_version AS version,
                obj_archived_at AS archived_at,
                obj_is_delete_marker AS is_delete_marker,
                obj_is_versioned AS is_versioned,
                FALSE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NULL
        ),
        combined AS (
            SELECT * FROM aggregated_prefixes
            UNION ALL
            SELECT * FROM leaf_objects
        ),
        filtered AS (
            SELECT *
            FROM combined
            WHERE (
                $5 = ''
                OR ROW(
                    COALESCE(date_trunc('milliseconds', %I), 'epoch'::timestamptz),
                    name COLLATE "C",
                    %s
                ) %s ROW(
                    -- truncated the same way as the stored value above
                    date_trunc('milliseconds', COALESCE(NULLIF($6, '')::timestamptz, 'epoch'::timestamptz)),
                    $5,
                    $9
                )
            )
        )
        SELECT
            split_part(name, '/', $3) AS key,
            name,
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata,
            version,
            archived_at,
            is_delete_marker,
            is_versioned
        FROM filtered
        ORDER BY
            COALESCE(date_trunc('milliseconds', %I), 'epoch'::timestamptz) %s,
            name COLLATE "C" %s,
            COALESCE(version, '') %s
        LIMIT $4
    $sql$,
        v_sort_column,
        v_version_tiebreak,
        v_cursor_op,
        v_sort_column,
        v_sort_order,
        v_sort_order,
        v_sort_order
    );

    -- version is the third tiebreak component for two versions of the same
    -- key tying on both timestamp and name (see filtered CTE / ORDER BY above)
    RETURN QUERY EXECUTE v_query
    USING v_prefix, p_bucket_id, p_level, p_limit, p_start_after, p_sort_column_after, noncurrent_versions, delete_markers, coalesce(p_start_after_version, ''), v_prefix_pattern;
END;
$_$;


--
-- Name: search_v2(text, text, integer, integer, text, text, text, text, text, text, timestamp with time zone, text, boolean); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, sort_column text DEFAULT 'name'::text, sort_column_after text DEFAULT ''::text, noncurrent_versions text DEFAULT 'exclude'::text, delete_markers text DEFAULT 'exclude'::text, start_after_archived_at timestamp with time zone DEFAULT NULL::timestamp with time zone, start_after_version text DEFAULT ''::text, start_after_is_continuation boolean DEFAULT false) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb, version text, archived_at timestamp with time zone, is_delete_marker boolean, is_versioned boolean)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_sort_col text;
    v_sort_ord text;
    v_limit int;
BEGIN
    -- Cap limit to maximum of 1500 records
    v_limit := LEAST(coalesce(limits, 100), 1500);

    -- Validate and normalize sort_order
    v_sort_ord := lower(coalesce(sort_order, 'asc'));
    IF v_sort_ord NOT IN ('asc', 'desc') THEN
        v_sort_ord := 'asc';
    END IF;

    -- Validate and normalize sort_column
    v_sort_col := lower(coalesce(sort_column, 'name'));
    IF v_sort_col NOT IN ('name', 'updated_at', 'created_at') THEN
        v_sort_col := 'name';
    END IF;

    -- Route to appropriate implementation
    IF v_sort_col = 'name' THEN
        -- Use list_objects_with_delimiter for name sorting (most efficient: O(k * log n))
        RETURN QUERY
        SELECT
            split_part(l.name, '/', levels) AS key,
            l.name AS name,
            l.id,
            l.updated_at,
            l.created_at,
            l.last_accessed_at,
            l.metadata,
            l.version,
            l.archived_at,
            l.is_delete_marker,
            l.is_versioned
        FROM storage.list_objects_with_delimiter(
            bucket_name,
            coalesce(prefix, ''),
            '/',
            v_limit,
            CASE WHEN start_after_is_continuation THEN '' ELSE start_after END,
            CASE WHEN start_after_is_continuation THEN start_after ELSE '' END,
            v_sort_ord,
            noncurrent_versions,
            delete_markers,
            start_after_archived_at,
            start_after_version
        ) l;
    ELSE
        -- Use aggregation approach for timestamp sorting
        -- Not efficient for large datasets but supports correct pagination
        RETURN QUERY SELECT * FROM storage.search_by_timestamp(
            prefix, bucket_name, v_limit, levels, start_after,
            v_sort_ord, v_sort_col, sort_column_after,
            noncurrent_versions, delete_markers, start_after_version
        );
    END IF;
END;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


--
-- Name: wake_lifecycle_state(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.wake_lifecycle_state() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.lifecycle_configuration IS NULL THEN
        RETURN NEW;
    END IF;

    PERFORM storage.reconcile_lifecycle_state(NEW.id, false);
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: custom_oauth_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.custom_oauth_providers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    provider_type text NOT NULL,
    identifier text NOT NULL,
    name text NOT NULL,
    client_id text NOT NULL,
    client_secret text NOT NULL,
    acceptable_client_ids text[] DEFAULT '{}'::text[] NOT NULL,
    scopes text[] DEFAULT '{}'::text[] NOT NULL,
    pkce_enabled boolean DEFAULT true NOT NULL,
    attribute_mapping jsonb DEFAULT '{}'::jsonb NOT NULL,
    authorization_params jsonb DEFAULT '{}'::jsonb NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    email_optional boolean DEFAULT false NOT NULL,
    issuer text,
    discovery_url text,
    skip_nonce_check boolean DEFAULT false NOT NULL,
    cached_discovery jsonb,
    discovery_cached_at timestamp with time zone,
    authorization_url text,
    token_url text,
    userinfo_url text,
    jwks_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    custom_claims_allowlist text[] DEFAULT '{}'::text[] NOT NULL,
    client_auth_method text DEFAULT 'client_secret'::text NOT NULL,
    client_assertion_audience text,
    CONSTRAINT custom_oauth_providers_authorization_url_https CHECK (((authorization_url IS NULL) OR (authorization_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_authorization_url_length CHECK (((authorization_url IS NULL) OR (char_length(authorization_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_client_id_length CHECK (((char_length(client_id) >= 1) AND (char_length(client_id) <= 512))),
    CONSTRAINT custom_oauth_providers_discovery_url_length CHECK (((discovery_url IS NULL) OR (char_length(discovery_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_identifier_format CHECK ((identifier ~ '^[a-z0-9][a-z0-9:-]{0,48}[a-z0-9]$'::text)),
    CONSTRAINT custom_oauth_providers_issuer_length CHECK (((issuer IS NULL) OR ((char_length(issuer) >= 1) AND (char_length(issuer) <= 2048)))),
    CONSTRAINT custom_oauth_providers_jwks_uri_https CHECK (((jwks_uri IS NULL) OR (jwks_uri ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_jwks_uri_length CHECK (((jwks_uri IS NULL) OR (char_length(jwks_uri) <= 2048))),
    CONSTRAINT custom_oauth_providers_name_length CHECK (((char_length(name) >= 1) AND (char_length(name) <= 100))),
    CONSTRAINT custom_oauth_providers_oauth2_requires_endpoints CHECK (((provider_type <> 'oauth2'::text) OR ((authorization_url IS NOT NULL) AND (token_url IS NOT NULL) AND (userinfo_url IS NOT NULL)))),
    CONSTRAINT custom_oauth_providers_oidc_discovery_url_https CHECK (((provider_type <> 'oidc'::text) OR (discovery_url IS NULL) OR (discovery_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_issuer_https CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NULL) OR (issuer ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_requires_issuer CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NOT NULL))),
    CONSTRAINT custom_oauth_providers_provider_type_check CHECK ((provider_type = ANY (ARRAY['oauth2'::text, 'oidc'::text]))),
    CONSTRAINT custom_oauth_providers_token_url_https CHECK (((token_url IS NULL) OR (token_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_token_url_length CHECK (((token_url IS NULL) OR (char_length(token_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_userinfo_url_https CHECK (((userinfo_url IS NULL) OR (userinfo_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_userinfo_url_length CHECK (((userinfo_url IS NULL) OR (char_length(userinfo_url) <= 2048)))
);


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text,
    code_challenge_method auth.code_challenge_method,
    code_challenge text,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone,
    invite_token text,
    referrer text,
    oauth_client_state_id uuid,
    linking_target_id uuid,
    email_optional boolean DEFAULT false NOT NULL
);


--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.flow_state IS 'Stores metadata for all OAuth/SSO login flows';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid,
    last_webauthn_challenge_data jsonb
);


--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: COLUMN mfa_factors.last_webauthn_challenge_data; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.mfa_factors.last_webauthn_challenge_data IS 'Stores the latest WebAuthn challenge data including attestation/assertion for customer verification';


--
-- Name: mfa_recovery_code_sets; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_recovery_code_sets (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    mfa_factor_id uuid NOT NULL,
    failed_verification_count integer DEFAULT 0 NOT NULL,
    verification_locked_until timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT mfa_recovery_code_sets_failed_verification_count_check CHECK ((failed_verification_count >= 0))
);


--
-- Name: mfa_recovery_codes; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_recovery_codes (
    id uuid NOT NULL,
    mfa_recovery_code_set_id uuid NOT NULL,
    code_hash text NOT NULL,
    consumed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: oauth_authorizations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_authorizations (
    id uuid NOT NULL,
    authorization_id text NOT NULL,
    client_id uuid NOT NULL,
    user_id uuid,
    redirect_uri text NOT NULL,
    scope text NOT NULL,
    state text,
    resource text,
    code_challenge text,
    code_challenge_method auth.code_challenge_method,
    response_type auth.oauth_response_type DEFAULT 'code'::auth.oauth_response_type NOT NULL,
    status auth.oauth_authorization_status DEFAULT 'pending'::auth.oauth_authorization_status NOT NULL,
    authorization_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:03:00'::interval) NOT NULL,
    approved_at timestamp with time zone,
    nonce text,
    CONSTRAINT oauth_authorizations_authorization_code_length CHECK ((char_length(authorization_code) <= 255)),
    CONSTRAINT oauth_authorizations_code_challenge_length CHECK ((char_length(code_challenge) <= 128)),
    CONSTRAINT oauth_authorizations_expires_at_future CHECK ((expires_at > created_at)),
    CONSTRAINT oauth_authorizations_nonce_length CHECK ((char_length(nonce) <= 255)),
    CONSTRAINT oauth_authorizations_redirect_uri_length CHECK ((char_length(redirect_uri) <= 2048)),
    CONSTRAINT oauth_authorizations_resource_length CHECK ((char_length(resource) <= 2048)),
    CONSTRAINT oauth_authorizations_scope_length CHECK ((char_length(scope) <= 4096)),
    CONSTRAINT oauth_authorizations_state_length CHECK ((char_length(state) <= 4096))
);


--
-- Name: oauth_client_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_client_states (
    id uuid NOT NULL,
    provider_type text NOT NULL,
    code_verifier text,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: TABLE oauth_client_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.oauth_client_states IS 'Stores OAuth states for third-party provider authentication flows where Supabase acts as the OAuth client.';


--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_secret_hash text,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    client_type auth.oauth_client_type DEFAULT 'confidential'::auth.oauth_client_type NOT NULL,
    token_endpoint_auth_method text NOT NULL,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048)),
    CONSTRAINT oauth_clients_token_endpoint_auth_method_check CHECK ((token_endpoint_auth_method = ANY (ARRAY['client_secret_basic'::text, 'client_secret_post'::text, 'none'::text])))
);


--
-- Name: oauth_consents; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_consents (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    client_id uuid NOT NULL,
    scopes text NOT NULL,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_at timestamp with time zone,
    CONSTRAINT oauth_consents_revoked_after_granted CHECK (((revoked_at IS NULL) OR (revoked_at >= granted_at))),
    CONSTRAINT oauth_consents_scopes_length CHECK ((char_length(scopes) <= 2048)),
    CONSTRAINT oauth_consents_scopes_not_empty CHECK ((char_length(TRIM(BOTH FROM scopes)) > 0))
);


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone,
    link_token_hash text,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: -
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: -
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    dedicated_scope boolean,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: scim_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.scim_tokens (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    token_hash text NOT NULL,
    prefix text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone,
    revoked_at timestamp with time zone,
    last_used_at timestamp with time zone,
    CONSTRAINT scim_tokens_expires_at_future CHECK (((expires_at IS NULL) OR (expires_at > created_at))),
    CONSTRAINT scim_tokens_revoked_after_created CHECK (((revoked_at IS NULL) OR (revoked_at >= created_at))),
    CONSTRAINT scim_tokens_token_hash_check CHECK ((token_hash ~ '^[0-9a-f]{64}$'::text))
);


--
-- Name: scim_users; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.scim_users (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    user_id uuid,
    resource jsonb NOT NULL,
    user_name text GENERATED ALWAYS AS (lower((resource ->> 'userName'::text))) STORED NOT NULL,
    external_id text GENERATED ALWAYS AS ((resource ->> 'externalId'::text)) STORED,
    active boolean GENERATED ALWAYS AS (COALESCE(((resource ->> 'active'::text))::boolean, true)) STORED NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text,
    oauth_client_id uuid,
    refresh_token_hmac_key text,
    refresh_token_counter bigint,
    scopes text,
    CONSTRAINT sessions_scopes_length CHECK ((char_length(scopes) <= 4096))
);


--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: COLUMN sessions.refresh_token_hmac_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_hmac_key IS 'Holds a HMAC-SHA256 key used to sign refresh tokens for this session.';


--
-- Name: COLUMN sessions.refresh_token_counter; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_counter IS 'Holds the ID (counter) of the last issued refresh token.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: webauthn_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.webauthn_challenges (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    challenge_type text NOT NULL,
    session_data jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    CONSTRAINT webauthn_challenges_challenge_type_check CHECK ((challenge_type = ANY (ARRAY['signup'::text, 'registration'::text, 'authentication'::text])))
);


--
-- Name: webauthn_credentials; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.webauthn_credentials (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    credential_id bytea NOT NULL,
    public_key bytea NOT NULL,
    attestation_type text DEFAULT ''::text NOT NULL,
    aaguid uuid,
    sign_count bigint DEFAULT 0 NOT NULL,
    transports jsonb DEFAULT '[]'::jsonb NOT NULL,
    backup_eligible boolean DEFAULT false NOT NULL,
    backed_up boolean DEFAULT false NOT NULL,
    friendly_name text DEFAULT ''::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    last_used_at timestamp with time zone
);


--
-- Name: academic_calendar_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.academic_calendar_entries (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    entry_type character varying(255) NOT NULL,
    event_date date NOT NULL,
    description text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    day_type character varying(255) DEFAULT 'non_working'::character varying NOT NULL,
    CONSTRAINT academic_calendar_entries_day_type_check CHECK (((day_type)::text = ANY ((ARRAY['working'::character varying, 'non_working'::character varying])::text[]))),
    CONSTRAINT academic_calendar_entries_entry_type_check CHECK (((entry_type)::text = ANY ((ARRAY['holiday'::character varying, 'event'::character varying, 'wfh_class_suspension'::character varying])::text[])))
);


--
-- Name: academic_calendar_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.academic_calendar_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: academic_calendar_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.academic_calendar_entries_id_seq OWNED BY public.academic_calendar_entries.id;


--
-- Name: admin_audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_audit_logs (
    id bigint NOT NULL,
    user_id bigint,
    action character varying(30) NOT NULL,
    module character varying(100) NOT NULL,
    description text NOT NULL,
    status character varying(20) DEFAULT 'Success'::character varying NOT NULL,
    metadata json,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: admin_audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_audit_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_audit_logs_id_seq OWNED BY public.admin_audit_logs.id;


--
-- Name: admin_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_configs (
    id bigint NOT NULL,
    key character varying(255) NOT NULL,
    value json NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: admin_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_configs_id_seq OWNED BY public.admin_configs.id;


--
-- Name: announcement_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.announcement_notifications (
    id bigint NOT NULL,
    announcement_id bigint NOT NULL,
    user_id bigint NOT NULL,
    is_read boolean DEFAULT false NOT NULL,
    read_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    redirect_url character varying(2048)
);


--
-- Name: announcement_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.announcement_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: announcement_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.announcement_notifications_id_seq OWNED BY public.announcement_notifications.id;


--
-- Name: announcements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.announcements (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    content text NOT NULL,
    priority character varying(255) DEFAULT 'medium'::character varying NOT NULL,
    target_user_type smallint,
    published_at timestamp(0) without time zone,
    expires_at date,
    is_published boolean DEFAULT true NOT NULL,
    created_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    target_office character varying(255),
    target_employee_type character varying(255),
    target_department_id bigint,
    target_ranking character varying(255),
    target_user_id bigint,
    type character varying(255) DEFAULT 'notification'::character varying NOT NULL,
    CONSTRAINT announcements_priority_check CHECK (((priority)::text = ANY ((ARRAY['low'::character varying, 'medium'::character varying, 'high'::character varying])::text[])))
);


--
-- Name: announcements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.announcements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: announcements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.announcements_id_seq OWNED BY public.announcements.id;


--
-- Name: attendance_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attendance_records (
    id bigint NOT NULL,
    employee_id bigint NOT NULL,
    record_date date NOT NULL,
    time_in time(0) without time zone,
    time_out time(0) without time zone,
    scheduled_time_in time(0) without time zone,
    scheduled_time_out time(0) without time zone,
    tardiness_minutes integer DEFAULT 0 NOT NULL,
    undertime_minutes integer DEFAULT 0 NOT NULL,
    overtime_minutes integer DEFAULT 0 NOT NULL,
    status character varying(255) DEFAULT 'present'::character varying NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    schedule_status character varying(255) DEFAULT 'validated'::character varying NOT NULL,
    schedule_notes text,
    CONSTRAINT attendance_records_status_check CHECK (((status)::text = ANY ((ARRAY['present'::character varying, 'absent'::character varying, 'on_leave'::character varying])::text[])))
);


--
-- Name: attendance_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attendance_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attendance_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attendance_records_id_seq OWNED BY public.attendance_records.id;


--
-- Name: cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cache (
    key character varying(255) NOT NULL,
    value text NOT NULL,
    expiration bigint NOT NULL
);


--
-- Name: cache_locks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cache_locks (
    key character varying(255) NOT NULL,
    owner character varying(255) NOT NULL,
    expiration bigint NOT NULL
);


--
-- Name: departments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.departments (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: departments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.departments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: departments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.departments_id_seq OWNED BY public.departments.id;


--
-- Name: employee_credentials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.employee_credentials (
    id bigint NOT NULL,
    employee_id bigint NOT NULL,
    credential_type character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    department_id bigint,
    expires_at date,
    description text,
    file_path character varying(255),
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    original_filename character varying(255),
    reviewed_by bigint,
    reviewed_at timestamp(0) without time zone,
    review_notes text,
    degree_level character varying(255),
    CONSTRAINT employee_credentials_credential_type_check CHECK (((credential_type)::text = ANY ((ARRAY['resume'::character varying, 'prc'::character varying, 'seminars'::character varying, 'degrees'::character varying, 'ranking'::character varying])::text[]))),
    CONSTRAINT employee_credentials_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'verified'::character varying, 'rejected'::character varying, 'needs_update'::character varying])::text[])))
);


--
-- Name: employee_credentials_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.employee_credentials_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: employee_credentials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.employee_credentials_id_seq OWNED BY public.employee_credentials.id;


--
-- Name: employee_schedule_days; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.employee_schedule_days (
    id bigint NOT NULL,
    schedule_submission_id bigint NOT NULL,
    day_name character varying(16) NOT NULL,
    day_index smallint NOT NULL,
    has_work boolean DEFAULT true NOT NULL,
    time_in time(0) without time zone,
    time_out time(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: employee_schedule_days_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.employee_schedule_days_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: employee_schedule_days_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.employee_schedule_days_id_seq OWNED BY public.employee_schedule_days.id;


--
-- Name: employee_schedule_submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.employee_schedule_submissions (
    id bigint NOT NULL,
    employee_id bigint NOT NULL,
    submitted_by bigint NOT NULL,
    reviewed_by bigint,
    semester_label character varying(255) NOT NULL,
    academic_year character varying(255),
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    submitted_at timestamp(0) without time zone NOT NULL,
    reviewed_at timestamp(0) without time zone,
    review_notes text,
    is_current boolean DEFAULT false NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    term_label character varying(255),
    term_start_date date,
    CONSTRAINT employee_schedule_submissions_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'approved'::character varying, 'declined'::character varying, 'reset'::character varying])::text[])))
);


--
-- Name: employee_schedule_submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.employee_schedule_submissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: employee_schedule_submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.employee_schedule_submissions_id_seq OWNED BY public.employee_schedule_submissions.id;


--
-- Name: employees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.employees (
    id bigint NOT NULL,
    employee_id character varying(255) NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    department_id bigint NOT NULL,
    "position" character varying(255) NOT NULL,
    employment_type character varying(255),
    ranking character varying(255),
    status character varying(255) DEFAULT 'active'::character varying NOT NULL,
    hire_date date,
    official_time_in time(0) without time zone,
    official_time_out time(0) without time zone,
    resume_last_updated_at date,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    employment_status character varying(255) DEFAULT 'probationary'::character varying NOT NULL,
    leave_term_started_at date,
    CONSTRAINT employees_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'on_leave'::character varying, 'resigned'::character varying, 'terminated'::character varying])::text[])))
);


--
-- Name: employees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.employees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: employees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.employees_id_seq OWNED BY public.employees.id;


--
-- Name: extraction_validation_runs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.extraction_validation_runs (
    id bigint NOT NULL,
    user_id bigint,
    pdf_filename character varying(255) NOT NULL,
    ground_truth_filename character varying(255) NOT NULL,
    format character varying(255) NOT NULL,
    pages integer DEFAULT 0 NOT NULL,
    extraction_seconds numeric(8,2) DEFAULT '0'::numeric NOT NULL,
    expected_rows integer NOT NULL,
    extracted_rows integer NOT NULL,
    matched_rows integer NOT NULL,
    time_in_correct integer NOT NULL,
    time_out_correct integer NOT NULL,
    fully_correct_rows integer NOT NULL,
    employee_matched_rows integer NOT NULL,
    mismatches json,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: extraction_validation_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.extraction_validation_runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: extraction_validation_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.extraction_validation_runs_id_seq OWNED BY public.extraction_validation_runs.id;


--
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.failed_jobs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;


--
-- Name: job_batches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_batches (
    id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    total_jobs integer NOT NULL,
    pending_jobs integer NOT NULL,
    failed_jobs integer NOT NULL,
    failed_job_ids text NOT NULL,
    options text,
    cancelled_at integer,
    created_at integer NOT NULL,
    finished_at integer
);


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jobs (
    id bigint NOT NULL,
    queue character varying(255) NOT NULL,
    payload text NOT NULL,
    attempts smallint NOT NULL,
    reserved_at integer,
    available_at integer NOT NULL,
    created_at integer NOT NULL
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- Name: leave_balances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.leave_balances (
    id bigint NOT NULL,
    employee_id bigint NOT NULL,
    leave_type character varying(255) NOT NULL,
    remaining_days numeric(5,2) DEFAULT '0'::numeric NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: leave_balances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.leave_balances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: leave_balances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.leave_balances_id_seq OWNED BY public.leave_balances.id;


--
-- Name: leave_import_runs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.leave_import_runs (
    id uuid NOT NULL,
    user_id bigint,
    status character varying(255) DEFAULT 'processing'::character varying NOT NULL,
    original_filename character varying(255),
    imported integer DEFAULT 0 NOT NULL,
    skipped integer DEFAULT 0 NOT NULL,
    total_records integer DEFAULT 0 NOT NULL,
    unmatched_employees json,
    applied_employees json,
    error text,
    started_at timestamp(0) without time zone,
    finished_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: leave_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.leave_requests (
    id bigint NOT NULL,
    employee_id bigint NOT NULL,
    leave_type character varying(255) NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    days_deducted numeric(5,2) DEFAULT '0'::numeric NOT NULL,
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    cutoff_date date,
    reason text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    source_leave_id character varying(255),
    CONSTRAINT leave_requests_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'approved'::character varying, 'rejected'::character varying])::text[])))
);


--
-- Name: leave_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.leave_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: leave_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.leave_requests_id_seq OWNED BY public.leave_requests.id;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.password_reset_tokens (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);


--
-- Name: privacy_notice_acknowledgments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.privacy_notice_acknowledgments (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    privacy_notice_version character varying(20) NOT NULL,
    acknowledged_at timestamp(0) without time zone NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: privacy_notice_acknowledgments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.privacy_notice_acknowledgments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: privacy_notice_acknowledgments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.privacy_notice_acknowledgments_id_seq OWNED BY public.privacy_notice_acknowledgments.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id character varying(255) NOT NULL,
    user_id bigint,
    ip_address character varying(45),
    user_agent text,
    payload text NOT NULL,
    last_activity integer NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    email_verified_at timestamp(0) without time zone,
    password character varying(255) NOT NULL,
    remember_token character varying(100),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    user_type smallint DEFAULT '3'::smallint NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: wfh_monitoring_submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wfh_monitoring_submissions (
    id bigint NOT NULL,
    employee_id bigint NOT NULL,
    submitted_by bigint NOT NULL,
    reviewed_by bigint,
    wfh_date date NOT NULL,
    time_in time(0) without time zone,
    time_out time(0) without time zone,
    file_path character varying(255),
    original_filename character varying(255),
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    submitted_at timestamp(0) without time zone NOT NULL,
    reviewed_at timestamp(0) without time zone,
    review_notes text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    monitoring_link character varying(2048),
    CONSTRAINT wfh_monitoring_submissions_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'approved'::character varying, 'declined'::character varying])::text[])))
);


--
-- Name: wfh_monitoring_submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wfh_monitoring_submissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wfh_monitoring_submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wfh_monitoring_submissions_id_seq OWNED BY public.wfh_monitoring_submissions.id;


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT timezone('utc'::text, clock_timestamp()) NOT NULL,
    inserted_at timestamp without time zone DEFAULT timezone('utc'::text, clock_timestamp()) NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea,
    skip_broadcast boolean DEFAULT false NOT NULL,
    expires_at timestamp without time zone
)
PARTITION BY RANGE (inserted_at);


--
-- Name: messages_2026_10_11; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2026_10_11 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT timezone('utc'::text, clock_timestamp()) NOT NULL,
    inserted_at timestamp without time zone DEFAULT timezone('utc'::text, clock_timestamp()) NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea,
    skip_broadcast boolean DEFAULT false NOT NULL,
    expires_at timestamp without time zone,
    CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL)))
);


--
-- Name: messages_2026_10_12; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2026_10_12 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT timezone('utc'::text, clock_timestamp()) NOT NULL,
    inserted_at timestamp without time zone DEFAULT timezone('utc'::text, clock_timestamp()) NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea,
    skip_broadcast boolean DEFAULT false NOT NULL,
    expires_at timestamp without time zone,
    CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL)))
);


--
-- Name: messages_2026_10_13; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2026_10_13 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT timezone('utc'::text, clock_timestamp()) NOT NULL,
    inserted_at timestamp without time zone DEFAULT timezone('utc'::text, clock_timestamp()) NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea,
    skip_broadcast boolean DEFAULT false NOT NULL,
    expires_at timestamp without time zone,
    CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL)))
);


--
-- Name: messages_2026_10_14; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2026_10_14 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT timezone('utc'::text, clock_timestamp()) NOT NULL,
    inserted_at timestamp without time zone DEFAULT timezone('utc'::text, clock_timestamp()) NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea,
    skip_broadcast boolean DEFAULT false NOT NULL,
    expires_at timestamp without time zone,
    CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL)))
);


--
-- Name: messages_2026_10_15; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2026_10_15 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT timezone('utc'::text, clock_timestamp()) NOT NULL,
    inserted_at timestamp without time zone DEFAULT timezone('utc'::text, clock_timestamp()) NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea,
    skip_broadcast boolean DEFAULT false NOT NULL,
    expires_at timestamp without time zone,
    CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL)))
);


--
-- Name: messages_2026_10_16; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2026_10_16 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT timezone('utc'::text, clock_timestamp()) NOT NULL,
    inserted_at timestamp without time zone DEFAULT timezone('utc'::text, clock_timestamp()) NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea,
    skip_broadcast boolean DEFAULT false NOT NULL,
    expires_at timestamp without time zone,
    CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL)))
);


--
-- Name: messages_2026_10_17; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages_2026_10_17 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT timezone('utc'::text, clock_timestamp()) NOT NULL,
    inserted_at timestamp without time zone DEFAULT timezone('utc'::text, clock_timestamp()) NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea,
    skip_broadcast boolean DEFAULT false NOT NULL,
    expires_at timestamp without time zone,
    CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL)))
);


--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    action_filter text DEFAULT '*'::text,
    selected_columns text[],
    CONSTRAINT subscription_action_filter_check CHECK ((action_filter = ANY (ARRAY['*'::text, 'INSERT'::text, 'UPDATE'::text, 'DELETE'::text])))
);


--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: -
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: bucket_lifecycle_states; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.bucket_lifecycle_states (
    bucket_id text NOT NULL,
    generation uuid,
    next_run_at timestamp with time zone,
    claim_id uuid,
    claim_until timestamp with time zone,
    continuation jsonb,
    last_started_at timestamp with time zone,
    last_completed_at timestamp with time zone,
    last_success_at timestamp with time zone,
    last_result jsonb,
    failure_count integer DEFAULT 0 NOT NULL,
    last_error jsonb,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT bucket_lifecycle_continuation_object_check CHECK (((continuation IS NULL) OR (jsonb_typeof(continuation) = 'object'::text))),
    CONSTRAINT bucket_lifecycle_failure_count_check CHECK ((failure_count >= 0)),
    CONSTRAINT bucket_lifecycle_last_result_object_check CHECK (((last_result IS NULL) OR (jsonb_typeof(last_result) = 'object'::text))),
    CONSTRAINT bucket_lifecycle_recovery_due_check CHECK (((next_run_at IS NOT NULL) OR (NOT jsonb_path_exists(COALESCE(continuation, '{}'::jsonb), '$."batch"."inFlight"'::jsonpath))))
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text,
    type storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL,
    versioning_status text DEFAULT 'DISABLED'::text NOT NULL,
    lifecycle_configuration jsonb,
    lifecycle_configuration_generation uuid,
    CONSTRAINT buckets_lifecycle_configuration_pair_check CHECK (((lifecycle_configuration IS NULL) = (lifecycle_configuration_generation IS NULL))),
    CONSTRAINT buckets_lifecycle_configuration_shape_check CHECK (((lifecycle_configuration IS NULL) OR ((jsonb_typeof(lifecycle_configuration) = 'object'::text) AND (lifecycle_configuration ? 'rules'::text) AND
CASE
    WHEN (jsonb_typeof((lifecycle_configuration -> 'rules'::text)) = 'array'::text) THEN ((jsonb_array_length((lifecycle_configuration -> 'rules'::text)) >= 1) AND (jsonb_array_length((lifecycle_configuration -> 'rules'::text)) <= 1000))
    ELSE false
END))),
    CONSTRAINT buckets_lifecycle_configuration_standard_only_check CHECK (((type = 'STANDARD'::storage.buckettype) OR ((lifecycle_configuration IS NULL) AND (lifecycle_configuration_generation IS NULL)))),
    CONSTRAINT buckets_versioning_standard_only_check CHECK (((type = 'STANDARD'::storage.buckettype) OR (versioning_status = 'DISABLED'::text))),
    CONSTRAINT buckets_versioning_status_check CHECK ((versioning_status = ANY (ARRAY['DISABLED'::text, 'ENABLED'::text, 'SUSPENDED'::text])))
);


--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_analytics (
    name text NOT NULL,
    type storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    format text DEFAULT 'ICEBERG'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: buckets_vectors; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_vectors (
    id text NOT NULL,
    type storage.buckettype DEFAULT 'VECTOR'::storage.buckettype NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: lifecycle_abandoned_artifacts; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.lifecycle_abandoned_artifacts (
    bucket_id text NOT NULL,
    key text NOT NULL,
    name text NOT NULL,
    version text,
    attempted_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: objects; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb,
    archived_at timestamp with time zone,
    is_delete_marker boolean DEFAULT false NOT NULL,
    is_versioned boolean DEFAULT false NOT NULL
);


--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb,
    metadata jsonb
);


--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: vector_indexes; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.vector_indexes (
    id text DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    bucket_id text NOT NULL,
    data_type text NOT NULL,
    dimension integer NOT NULL,
    distance_metric text NOT NULL,
    metadata_configuration jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: messages_2026_10_11; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_10_11 FOR VALUES FROM ('2026-10-11 00:00:00') TO ('2026-10-12 00:00:00');


--
-- Name: messages_2026_10_12; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_10_12 FOR VALUES FROM ('2026-10-12 00:00:00') TO ('2026-10-13 00:00:00');


--
-- Name: messages_2026_10_13; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_10_13 FOR VALUES FROM ('2026-10-13 00:00:00') TO ('2026-10-14 00:00:00');


--
-- Name: messages_2026_10_14; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_10_14 FOR VALUES FROM ('2026-10-14 00:00:00') TO ('2026-10-15 00:00:00');


--
-- Name: messages_2026_10_15; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_10_15 FOR VALUES FROM ('2026-10-15 00:00:00') TO ('2026-10-16 00:00:00');


--
-- Name: messages_2026_10_16; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_10_16 FOR VALUES FROM ('2026-10-16 00:00:00') TO ('2026-10-17 00:00:00');


--
-- Name: messages_2026_10_17; Type: TABLE ATTACH; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_10_17 FOR VALUES FROM ('2026-10-17 00:00:00') TO ('2026-10-18 00:00:00');


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Name: academic_calendar_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.academic_calendar_entries ALTER COLUMN id SET DEFAULT nextval('public.academic_calendar_entries_id_seq'::regclass);


--
-- Name: admin_audit_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_audit_logs ALTER COLUMN id SET DEFAULT nextval('public.admin_audit_logs_id_seq'::regclass);


--
-- Name: admin_configs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_configs ALTER COLUMN id SET DEFAULT nextval('public.admin_configs_id_seq'::regclass);


--
-- Name: announcement_notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcement_notifications ALTER COLUMN id SET DEFAULT nextval('public.announcement_notifications_id_seq'::regclass);


--
-- Name: announcements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcements ALTER COLUMN id SET DEFAULT nextval('public.announcements_id_seq'::regclass);


--
-- Name: attendance_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance_records ALTER COLUMN id SET DEFAULT nextval('public.attendance_records_id_seq'::regclass);


--
-- Name: departments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departments ALTER COLUMN id SET DEFAULT nextval('public.departments_id_seq'::regclass);


--
-- Name: employee_credentials id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_credentials ALTER COLUMN id SET DEFAULT nextval('public.employee_credentials_id_seq'::regclass);


--
-- Name: employee_schedule_days id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_schedule_days ALTER COLUMN id SET DEFAULT nextval('public.employee_schedule_days_id_seq'::regclass);


--
-- Name: employee_schedule_submissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_schedule_submissions ALTER COLUMN id SET DEFAULT nextval('public.employee_schedule_submissions_id_seq'::regclass);


--
-- Name: employees id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees ALTER COLUMN id SET DEFAULT nextval('public.employees_id_seq'::regclass);


--
-- Name: extraction_validation_runs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.extraction_validation_runs ALTER COLUMN id SET DEFAULT nextval('public.extraction_validation_runs_id_seq'::regclass);


--
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- Name: leave_balances id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leave_balances ALTER COLUMN id SET DEFAULT nextval('public.leave_balances_id_seq'::regclass);


--
-- Name: leave_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leave_requests ALTER COLUMN id SET DEFAULT nextval('public.leave_requests_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: privacy_notice_acknowledgments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.privacy_notice_acknowledgments ALTER COLUMN id SET DEFAULT nextval('public.privacy_notice_acknowledgments_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: wfh_monitoring_submissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wfh_monitoring_submissions ALTER COLUMN id SET DEFAULT nextval('public.wfh_monitoring_submissions_id_seq'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
\.


--
-- Data for Name: custom_oauth_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.custom_oauth_providers (id, provider_type, identifier, name, client_id, client_secret, acceptable_client_ids, scopes, pkce_enabled, attribute_mapping, authorization_params, enabled, email_optional, issuer, discovery_url, skip_nonce_check, cached_discovery, discovery_cached_at, authorization_url, token_url, userinfo_url, jwks_uri, created_at, updated_at, custom_claims_allowlist, client_auth_method, client_assertion_audience) FROM stdin;
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at, invite_token, referrer, oauth_client_state_id, linking_target_id, email_optional) FROM stdin;
89e94b72-453c-4f20-b6dc-ec6175e94e2c	b0116d6f-8cc2-4ee1-9253-93e4c7f6b7ac	a64e19cf-c133-496f-b0dd-77248a64b5ad	s256	gwwy1uIUiWf5juLL_nDOVT8GAsji2K9HpmRDtLSFCAc	email			2026-05-03 10:19:41.429415+00	2026-05-03 10:19:41.429415+00	email/signup	\N	\N	\N	\N	\N	f
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
a95c61fb-b1a8-4a66-bd77-f87a42e1d30e	a95c61fb-b1a8-4a66-bd77-f87a42e1d30e	{"sub": "a95c61fb-b1a8-4a66-bd77-f87a42e1d30e", "email": "jane.doe@example.com", "email_verified": false, "phone_verified": false}	email	2026-09-19 16:41:47.925732+00	2026-09-19 16:41:47.925787+00	2026-09-19 16:41:47.925787+00	a2664236-c52b-47d8-9378-d451c79564f3
8b841be5-23cb-47c4-a06e-c0fc5d62c8d0	8b841be5-23cb-47c4-a06e-c0fc5d62c8d0	{"sub": "8b841be5-23cb-47c4-a06e-c0fc5d62c8d0", "email": "corwin.kendrick@example.org", "email_verified": false, "phone_verified": false}	email	2026-09-19 16:42:20.132479+00	2026-09-19 16:42:20.132528+00	2026-09-19 16:42:20.132528+00	494e3468-587c-4056-8d67-440d3b404419
a8ffc58a-dc7b-4349-b962-3210fe4dfdff	a8ffc58a-dc7b-4349-b962-3210fe4dfdff	{"sub": "a8ffc58a-dc7b-4349-b962-3210fe4dfdff", "email": "ogerlach@example.org", "email_verified": false, "phone_verified": false}	email	2026-09-19 16:42:22.972539+00	2026-09-19 16:42:22.9734+00	2026-09-19 16:42:22.9734+00	405d81c8-5c10-42cb-9243-da2fc02dfd87
cdbf1ad0-9a79-42f4-8dcb-fcd62f1c752c	cdbf1ad0-9a79-42f4-8dcb-fcd62f1c752c	{"sub": "cdbf1ad0-9a79-42f4-8dcb-fcd62f1c752c", "email": "emmy.gislason@example.com", "email_verified": false, "phone_verified": false}	email	2026-09-19 17:05:52.940149+00	2026-09-19 17:05:52.940204+00	2026-09-19 17:05:52.940204+00	9663d54b-b608-47e1-aa63-a5db3ff06af9
c6c37413-8872-4d9a-89e1-4ab386550320	c6c37413-8872-4d9a-89e1-4ab386550320	{"sub": "c6c37413-8872-4d9a-89e1-4ab386550320", "email": "cohara@example.org", "email_verified": false, "phone_verified": false}	email	2026-09-19 17:05:55.688606+00	2026-09-19 17:05:55.688651+00	2026-09-19 17:05:55.688651+00	f80ca914-ff47-4e93-a974-2b1ab1a77cf8
7dddedef-acc6-4460-89ee-f6759890cb89	7dddedef-acc6-4460-89ee-f6759890cb89	{"sub": "7dddedef-acc6-4460-89ee-f6759890cb89", "email": "mosciski.elise@example.com", "email_verified": false, "phone_verified": false}	email	2026-09-19 18:09:03.039934+00	2026-09-19 18:09:03.039984+00	2026-09-19 18:09:03.039984+00	785ec247-6e35-4661-b32c-bbbe9af21e9c
39c4594a-625c-40e4-bd01-64cc3d393aa3	39c4594a-625c-40e4-bd01-64cc3d393aa3	{"sub": "39c4594a-625c-40e4-bd01-64cc3d393aa3", "email": "qconroy@example.org", "email_verified": false, "phone_verified": false}	email	2026-09-19 18:09:05.888395+00	2026-09-19 18:09:05.888445+00	2026-09-19 18:09:05.888445+00	3e23d1ca-160a-4090-9a46-ddaf2bf7729b
3745a390-135d-4a73-a59c-dd78435cdcb8	3745a390-135d-4a73-a59c-dd78435cdcb8	{"sub": "3745a390-135d-4a73-a59c-dd78435cdcb8", "email": "tatyana39@example.net", "email_verified": false, "phone_verified": false}	email	2026-09-20 07:22:29.754051+00	2026-09-20 07:22:29.754111+00	2026-09-20 07:22:29.754111+00	30348024-e12b-4a16-9e79-496a169d87f4
b482173f-e3f0-400c-a466-b1ffba4f65d5	b482173f-e3f0-400c-a466-b1ffba4f65d5	{"sub": "b482173f-e3f0-400c-a466-b1ffba4f65d5", "email": "yasmin24@example.org", "email_verified": false, "phone_verified": false}	email	2026-09-20 07:22:32.408481+00	2026-09-20 07:22:32.409018+00	2026-09-20 07:22:32.409018+00	0ba890c0-4736-4aeb-b7a6-1f7d815d8881
af73fd05-fee8-4d9e-a789-b39cac2b7dcc	af73fd05-fee8-4d9e-a789-b39cac2b7dcc	{"sub": "af73fd05-fee8-4d9e-a789-b39cac2b7dcc", "email": "kassulke.elsa@example.net", "email_verified": false, "phone_verified": false}	email	2026-09-24 11:01:31.95408+00	2026-09-24 11:01:31.954137+00	2026-09-24 11:01:31.954137+00	80dd2fa4-8956-475b-9a65-81b2812515e0
7c2914c1-f5f0-4ca3-8cda-1dd33ee02b13	7c2914c1-f5f0-4ca3-8cda-1dd33ee02b13	{"sub": "7c2914c1-f5f0-4ca3-8cda-1dd33ee02b13", "email": "pfeffer.magnus@example.net", "email_verified": false, "phone_verified": false}	email	2026-09-24 11:01:37.620067+00	2026-09-24 11:01:37.620115+00	2026-09-24 11:01:37.620115+00	4182063c-60c6-4352-8d05-8bbe6bbe0139
6477014d-9bc4-4546-88b7-4b5b05c4e19f	6477014d-9bc4-4546-88b7-4b5b05c4e19f	{"sub": "6477014d-9bc4-4546-88b7-4b5b05c4e19f", "email": "lyric09@example.com", "email_verified": false, "phone_verified": false}	email	2026-09-28 14:52:32.042382+00	2026-09-28 14:52:32.042434+00	2026-09-28 14:52:32.042434+00	a2a7d0df-d14e-4c1d-8b69-a2bb5b012c01
a5ebcdfc-c5de-4121-be4e-5f03401e9dba	a5ebcdfc-c5de-4121-be4e-5f03401e9dba	{"sub": "a5ebcdfc-c5de-4121-be4e-5f03401e9dba", "email": "muhammad.stehr@example.org", "email_verified": false, "phone_verified": false}	email	2026-09-28 14:52:37.829522+00	2026-09-28 14:52:37.82957+00	2026-09-28 14:52:37.82957+00	0c688bee-726e-4d6b-80d2-9e8282f3f97a
bf9c72a7-012b-4bd2-bb90-fcf2a34f274b	bf9c72a7-012b-4bd2-bb90-fcf2a34f274b	{"sub": "bf9c72a7-012b-4bd2-bb90-fcf2a34f274b", "email": "yjohns@example.net", "email_verified": false, "phone_verified": false}	email	2026-09-29 12:33:08.242028+00	2026-09-29 12:33:08.242084+00	2026-09-29 12:33:08.242084+00	9cf8037a-c4de-4b11-afa6-74b967f642ee
59ddaa6f-c4a6-4003-b462-44d98324fea6	59ddaa6f-c4a6-4003-b462-44d98324fea6	{"sub": "59ddaa6f-c4a6-4003-b462-44d98324fea6", "email": "vlynch@example.com", "email_verified": false, "phone_verified": false}	email	2026-09-29 12:33:11.599288+00	2026-09-29 12:33:11.599342+00	2026-09-29 12:33:11.599342+00	07393860-02e2-47b9-ad76-73cf83323744
ed2b08d5-0f59-420a-a8b9-d12ccd7ce066	ed2b08d5-0f59-420a-a8b9-d12ccd7ce066	{"sub": "ed2b08d5-0f59-420a-a8b9-d12ccd7ce066", "email": "marquardt.reese@example.org", "email_verified": false, "phone_verified": false}	email	2026-09-29 12:44:50.074133+00	2026-09-29 12:44:50.074184+00	2026-09-29 12:44:50.074184+00	048987e6-ec2b-421a-8bfb-fc16408c48cf
7158309d-64d5-4391-8f41-ad5952681cd2	7158309d-64d5-4391-8f41-ad5952681cd2	{"sub": "7158309d-64d5-4391-8f41-ad5952681cd2", "email": "cristal.reichel@example.org", "email_verified": false, "phone_verified": false}	email	2026-09-29 12:44:53.406693+00	2026-09-29 12:44:53.406744+00	2026-09-29 12:44:53.406744+00	0f2d0e2e-ca82-4ba1-969e-fb5860d1022a
b1b21d76-4214-4092-93e6-d610336f6b63	b1b21d76-4214-4092-93e6-d610336f6b63	{"sub": "b1b21d76-4214-4092-93e6-d610336f6b63", "email": "blaze24@example.net", "email_verified": false, "phone_verified": false}	email	2026-10-01 14:27:43.03178+00	2026-10-01 14:27:43.031832+00	2026-10-01 14:27:43.031832+00	2641fbc7-59fc-4dae-b943-90e4a328390a
56eb65ce-a3a7-4275-b120-9844eb919a28	56eb65ce-a3a7-4275-b120-9844eb919a28	{"sub": "56eb65ce-a3a7-4275-b120-9844eb919a28", "email": "hartmann.maurice@example.com", "email_verified": false, "phone_verified": false}	email	2026-10-01 14:27:46.814036+00	2026-10-01 14:27:46.814109+00	2026-10-01 14:27:46.814109+00	559d1883-8fca-424e-b5d2-7a48428ba6f2
758adfd0-1331-4d60-ba1d-dcae6c90565f	758adfd0-1331-4d60-ba1d-dcae6c90565f	{"sub": "758adfd0-1331-4d60-ba1d-dcae6c90565f", "email": "evalyn.davis@example.org", "email_verified": false, "phone_verified": false}	email	2026-10-05 04:31:55.529328+00	2026-10-05 04:31:55.529387+00	2026-10-05 04:31:55.529387+00	27ebbd22-ac4c-4ceb-9497-e6741d8836a2
582e3584-2bca-489e-8d80-8b9d9deaa736	582e3584-2bca-489e-8d80-8b9d9deaa736	{"sub": "582e3584-2bca-489e-8d80-8b9d9deaa736", "email": "susie41@example.net", "email_verified": false, "phone_verified": false}	email	2026-10-05 04:31:59.292046+00	2026-10-05 04:31:59.292091+00	2026-10-05 04:31:59.292091+00	0f72af18-bf87-467f-b3b4-3a6349f544b6
4870c15d-0b86-48e5-bd80-e35ba2eb89ff	4870c15d-0b86-48e5-bd80-e35ba2eb89ff	{"sub": "4870c15d-0b86-48e5-bd80-e35ba2eb89ff", "email": "thiel.alisha@example.com", "email_verified": false, "phone_verified": false}	email	2026-10-05 04:53:15.156014+00	2026-10-05 04:53:15.156694+00	2026-10-05 04:53:15.156694+00	77eb4b7f-a749-43e6-8f67-45843cf55f39
02c911f1-8288-443d-957b-b96012c30f2d	02c911f1-8288-443d-957b-b96012c30f2d	{"sub": "02c911f1-8288-443d-957b-b96012c30f2d", "email": "cordia.veum@example.com", "email_verified": false, "phone_verified": false}	email	2026-10-05 04:53:18.842596+00	2026-10-05 04:53:18.842658+00	2026-10-05 04:53:18.842658+00	cc7417a4-8dc6-4f51-a662-b3e2a8b65105
2fb809bc-b975-4369-a744-a8fa4372b992	2fb809bc-b975-4369-a744-a8fa4372b992	{"sub": "2fb809bc-b975-4369-a744-a8fa4372b992", "email": "guiseppe.kassulke@example.org", "email_verified": false, "phone_verified": false}	email	2026-10-05 05:08:42.339474+00	2026-10-05 05:08:42.33953+00	2026-10-05 05:08:42.33953+00	af0dd8b6-5370-42ec-9cea-cc4eb6fce6e8
34556ff5-eae0-4047-976f-174980356a7e	34556ff5-eae0-4047-976f-174980356a7e	{"sub": "34556ff5-eae0-4047-976f-174980356a7e", "email": "gleason.bonita@example.net", "email_verified": false, "phone_verified": false}	email	2026-10-05 05:08:45.812821+00	2026-10-05 05:08:45.81291+00	2026-10-05 05:08:45.81291+00	82d450df-16dd-4c9e-8b8b-0d72e911cda3
40f338bb-bd40-4622-9083-d45fa35b6f61	40f338bb-bd40-4622-9083-d45fa35b6f61	{"sub": "40f338bb-bd40-4622-9083-d45fa35b6f61", "email": "christiansen.gertrude@example.net", "email_verified": false, "phone_verified": false}	email	2026-10-05 06:15:29.421542+00	2026-10-05 06:15:29.421592+00	2026-10-05 06:15:29.421592+00	4d7b55ba-3711-4d3e-90f3-04501a394512
731e5ea3-c782-46bd-8d62-32d31e357ed7	731e5ea3-c782-46bd-8d62-32d31e357ed7	{"sub": "731e5ea3-c782-46bd-8d62-32d31e357ed7", "email": "mbins@example.net", "email_verified": false, "phone_verified": false}	email	2026-10-05 06:15:33.155598+00	2026-10-05 06:15:33.155646+00	2026-10-05 06:15:33.155646+00	1410a46f-81c6-4ae4-b3e9-299a806e5529
0bc972d7-2333-4cab-a458-932332b5b4e1	0bc972d7-2333-4cab-a458-932332b5b4e1	{"sub": "0bc972d7-2333-4cab-a458-932332b5b4e1", "email": "leanna.treutel@example.org", "email_verified": false, "phone_verified": false}	email	2026-10-05 06:28:11.342475+00	2026-10-05 06:28:11.342525+00	2026-10-05 06:28:11.342525+00	21e5c0b0-beb9-4dbd-8030-06b01ed0952f
52b21747-5738-46d0-9058-8a5d0f5e6ba3	52b21747-5738-46d0-9058-8a5d0f5e6ba3	{"sub": "52b21747-5738-46d0-9058-8a5d0f5e6ba3", "email": "rosamond.blanda@example.org", "email_verified": false, "phone_verified": false}	email	2026-10-05 06:28:15.026268+00	2026-10-05 06:28:15.02633+00	2026-10-05 06:28:15.02633+00	629d8dc9-a7d1-4d35-8a3e-2c3b65d94b37
7e531406-ceef-4f16-9f6c-2b867d04351d	7e531406-ceef-4f16-9f6c-2b867d04351d	{"sub": "7e531406-ceef-4f16-9f6c-2b867d04351d", "email": "vwatsica@example.com", "email_verified": false, "phone_verified": false}	email	2026-10-05 06:37:08.146821+00	2026-10-05 06:37:08.146909+00	2026-10-05 06:37:08.146909+00	92ad557e-2f58-41cf-9dfe-ade71241fb76
2260d0d8-0666-40a0-8007-ab57c69c35e8	2260d0d8-0666-40a0-8007-ab57c69c35e8	{"sub": "2260d0d8-0666-40a0-8007-ab57c69c35e8", "email": "scarlett.nicolas@example.com", "email_verified": false, "phone_verified": false}	email	2026-10-05 06:37:11.899397+00	2026-10-05 06:37:11.899451+00	2026-10-05 06:37:11.899451+00	a2b2082e-97a2-461b-8ca4-5ba755a595e2
6dc94d10-0d0a-4704-bb31-c70380519237	6dc94d10-0d0a-4704-bb31-c70380519237	{"sub": "6dc94d10-0d0a-4704-bb31-c70380519237", "email": "thompson.elwyn@example.net", "email_verified": false, "phone_verified": false}	email	2026-10-05 06:54:16.170925+00	2026-10-05 06:54:16.170977+00	2026-10-05 06:54:16.170977+00	a92b043e-40e5-4924-a08c-756dfd263e8e
792db754-e8ee-4e90-bfd6-ec0438f9b231	792db754-e8ee-4e90-bfd6-ec0438f9b231	{"sub": "792db754-e8ee-4e90-bfd6-ec0438f9b231", "email": "considine.barbara@example.net", "email_verified": false, "phone_verified": false}	email	2026-10-05 06:54:20.004964+00	2026-10-05 06:54:20.005032+00	2026-10-05 06:54:20.005032+00	a5aa68f3-6807-4c80-ad7f-1b5fd24d7b25
4b53f53e-d4b0-4284-8963-889d7164a4cb	4b53f53e-d4b0-4284-8963-889d7164a4cb	{"sub": "4b53f53e-d4b0-4284-8963-889d7164a4cb", "email": "vmonahan@example.net", "email_verified": false, "phone_verified": false}	email	2026-10-05 07:02:07.228881+00	2026-10-05 07:02:07.228936+00	2026-10-05 07:02:07.228936+00	19921177-61ef-4430-9182-133b44426c1e
8e760aa8-1684-408f-a088-441fe6099e86	8e760aa8-1684-408f-a088-441fe6099e86	{"sub": "8e760aa8-1684-408f-a088-441fe6099e86", "email": "hartmann.ivah@example.net", "email_verified": false, "phone_verified": false}	email	2026-10-05 07:02:12.980496+00	2026-10-05 07:02:12.980556+00	2026-10-05 07:02:12.980556+00	8be022f8-baf3-4022-9b7e-82ca111f65bf
c35640db-bb56-43e9-9be6-d77d641c6cf8	c35640db-bb56-43e9-9be6-d77d641c6cf8	{"sub": "c35640db-bb56-43e9-9be6-d77d641c6cf8", "email": "timekeeper@example.com", "email_verified": false, "phone_verified": false}	email	2026-10-05 08:20:06.965351+00	2026-10-05 08:20:06.965403+00	2026-10-05 08:20:06.965403+00	1cf2ec3e-eb1a-4c84-853e-ea0532180224
11bb3f53-c8d9-4250-84d9-c5d8bc34b756	11bb3f53-c8d9-4250-84d9-c5d8bc34b756	{"sub": "11bb3f53-c8d9-4250-84d9-c5d8bc34b756", "email": "nulptimekeeping@gmail.com", "email_verified": false, "phone_verified": false}	email	2026-10-05 08:48:54.083157+00	2026-10-05 08:48:54.083214+00	2026-10-05 08:48:54.083214+00	0242eb8c-c9b3-40af-b508-c4be80b1a0ab
2dd3114b-dc80-4a27-afa2-0be20fb50d2e	2dd3114b-dc80-4a27-afa2-0be20fb50d2e	{"sub": "2dd3114b-dc80-4a27-afa2-0be20fb50d2e", "email": "cummerata.jacques@example.com", "email_verified": false, "phone_verified": false}	email	2026-10-12 12:50:29.665295+00	2026-10-12 12:50:29.665765+00	2026-10-12 12:50:29.665765+00	5cff5747-e1b3-4a20-94a6-6cde022084ff
c3ea8274-ab7e-4e6f-a25f-0ed183031a39	c3ea8274-ab7e-4e6f-a25f-0ed183031a39	{"sub": "c3ea8274-ab7e-4e6f-a25f-0ed183031a39", "email": "tristin.konopelski@example.org", "email_verified": false, "phone_verified": false}	email	2026-10-12 12:50:32.40785+00	2026-10-12 12:50:32.407912+00	2026-10-12 12:50:32.407912+00	740aae98-587f-4a79-899c-0fe47400cfa1
2852fb70-6a1f-44b5-bc2c-506490a4aaad	2852fb70-6a1f-44b5-bc2c-506490a4aaad	{"sub": "2852fb70-6a1f-44b5-bc2c-506490a4aaad", "email": "shiela.natanuan.1@gmail.com", "email_verified": false, "phone_verified": false}	email	2026-10-13 07:55:59.357336+00	2026-10-13 07:55:59.357388+00	2026-10-13 07:55:59.357388+00	69313938-060d-4388-8ec1-5895e1f30afd
ac33c8d8-8dd4-4f62-b20f-0b57651fe7a3	ac33c8d8-8dd4-4f62-b20f-0b57651fe7a3	{"sub": "ac33c8d8-8dd4-4f62-b20f-0b57651fe7a3", "email": "sharleneanne.hidalgo@gmail.com", "email_verified": false, "phone_verified": false}	email	2026-10-13 08:03:43.380988+00	2026-10-13 08:03:43.381054+00	2026-10-13 08:03:43.381054+00	152c8c01-e85b-443d-91cf-53aa62124cee
1ab9ac5c-1a7b-4709-8164-968215cfa07f	1ab9ac5c-1a7b-4709-8164-968215cfa07f	{"sub": "1ab9ac5c-1a7b-4709-8164-968215cfa07f", "email": "candace.gottlieb@example.net", "email_verified": false, "phone_verified": false}	email	2026-10-13 09:15:56.874509+00	2026-10-13 09:15:56.874578+00	2026-10-13 09:15:56.874578+00	cd05e6c7-5a7f-4a56-9971-d39572f5efea
28d314e7-f9b5-4452-87e8-8542e797e4ce	28d314e7-f9b5-4452-87e8-8542e797e4ce	{"sub": "28d314e7-f9b5-4452-87e8-8542e797e4ce", "email": "cledner@example.com", "email_verified": false, "phone_verified": false}	email	2026-10-13 09:15:59.704169+00	2026-10-13 09:15:59.704236+00	2026-10-13 09:15:59.704236+00	db57b84a-7813-4833-8c1b-d838a05e017d
fb54eaf5-b11c-44ad-b924-04c16024eda9	fb54eaf5-b11c-44ad-b924-04c16024eda9	{"sub": "fb54eaf5-b11c-44ad-b924-04c16024eda9", "email": "jaysargetesting1013@gmail.com", "email_verified": false, "phone_verified": false}	email	2026-10-13 15:49:55.907023+00	2026-10-13 15:49:55.907076+00	2026-10-13 15:49:55.907076+00	17bcdf45-fd43-4423-a06a-bcfd449dffe9
9855edf9-6256-46d3-869f-66790b2360f3	9855edf9-6256-46d3-869f-66790b2360f3	{"sub": "9855edf9-6256-46d3-869f-66790b2360f3", "email": "francisca19@example.net", "email_verified": false, "phone_verified": false}	email	2026-10-15 16:36:22.023445+00	2026-10-15 16:36:22.0235+00	2026-10-15 16:36:22.0235+00	b9ee374a-66ed-4df4-86cf-a21fe549e14b
e1c9ffe5-f261-4899-b42c-4145eb91b8e6	e1c9ffe5-f261-4899-b42c-4145eb91b8e6	{"sub": "e1c9ffe5-f261-4899-b42c-4145eb91b8e6", "email": "akulas@example.org", "email_verified": false, "phone_verified": false}	email	2026-10-15 16:36:24.988963+00	2026-10-15 16:36:24.989016+00	2026-10-15 16:36:24.989016+00	0dff3840-a5e5-431d-9a64-26265dff98a3
73f6c948-99c9-46dd-ba7f-6b5b638b1819	73f6c948-99c9-46dd-ba7f-6b5b638b1819	{"sub": "73f6c948-99c9-46dd-ba7f-6b5b638b1819", "email": "nicholas61@example.com", "email_verified": false, "phone_verified": false}	email	2026-10-16 02:25:47.049974+00	2026-10-16 02:25:47.051358+00	2026-10-16 02:25:47.051358+00	b20bb104-d2eb-4720-9d67-c2735d1fd22a
b1c1dbe7-11b8-401a-95d7-bc437c3c7dbf	b1c1dbe7-11b8-401a-95d7-bc437c3c7dbf	{"sub": "b1c1dbe7-11b8-401a-95d7-bc437c3c7dbf", "email": "joseabeltesting1013@gmail.com", "email_verified": false, "phone_verified": false}	email	2026-10-13 15:52:07.522531+00	2026-10-13 15:52:07.522589+00	2026-10-13 15:52:07.522589+00	f51a9b8e-1236-4a2d-a7f6-485a3d4fdc46
a06ca5cd-0838-46da-a20a-70deb44e2828	a06ca5cd-0838-46da-a20a-70deb44e2828	{"sub": "a06ca5cd-0838-46da-a20a-70deb44e2828", "email": "judyanntesting1013@gmail.com", "email_verified": false, "phone_verified": false}	email	2026-10-13 15:54:57.597027+00	2026-10-13 15:54:57.597082+00	2026-10-13 15:54:57.597082+00	18ee03cd-3c02-40b8-8e10-371e17168a58
e45f74ce-d96a-44fb-b1dd-d2f2c02e91ff	e45f74ce-d96a-44fb-b1dd-d2f2c02e91ff	{"sub": "e45f74ce-d96a-44fb-b1dd-d2f2c02e91ff", "email": "clarissatesting1013@gmail.com", "email_verified": false, "phone_verified": false}	email	2026-10-13 15:57:12.869051+00	2026-10-13 15:57:12.869108+00	2026-10-13 15:57:12.869108+00	0b743365-e34d-472b-b825-b3e316de0944
8a635d51-8ec6-42d2-819b-cd632f092ba7	8a635d51-8ec6-42d2-819b-cd632f092ba7	{"sub": "8a635d51-8ec6-42d2-819b-cd632f092ba7", "email": "jamir.keeling@example.com", "email_verified": false, "phone_verified": false}	email	2026-10-14 02:11:21.560645+00	2026-10-14 02:11:21.560706+00	2026-10-14 02:11:21.560706+00	da52fb17-799e-481c-8a8f-5df2991dd0b5
d4a09ac9-7118-49f9-bbd3-90bc6ffd5c2d	d4a09ac9-7118-49f9-bbd3-90bc6ffd5c2d	{"sub": "d4a09ac9-7118-49f9-bbd3-90bc6ffd5c2d", "email": "jayne60@example.org", "email_verified": false, "phone_verified": false}	email	2026-10-14 02:11:24.719208+00	2026-10-14 02:11:24.720329+00	2026-10-14 02:11:24.720329+00	62aa7487-28a7-4b7c-8dbc-c0280ad99322
f5b3f82f-ed69-4a3f-a04c-dcd84921ffe7	f5b3f82f-ed69-4a3f-a04c-dcd84921ffe7	{"sub": "f5b3f82f-ed69-4a3f-a04c-dcd84921ffe7", "email": "leonor23@example.org", "email_verified": false, "phone_verified": false}	email	2026-10-15 13:06:06.488179+00	2026-10-15 13:06:06.488232+00	2026-10-15 13:06:06.488232+00	5d34d8c8-7c42-4b99-905d-82b3595fa4ac
53d2d2e8-a570-4c52-b2e7-4124986d7b9f	53d2d2e8-a570-4c52-b2e7-4124986d7b9f	{"sub": "53d2d2e8-a570-4c52-b2e7-4124986d7b9f", "email": "ola.hoppe@example.net", "email_verified": false, "phone_verified": false}	email	2026-10-15 13:06:09.526088+00	2026-10-15 13:06:09.527842+00	2026-10-15 13:06:09.527842+00	766c80f8-6ead-48e7-a151-d63ed228da86
b4ae48be-606a-4f80-a06b-88d943300ca5	b4ae48be-606a-4f80-a06b-88d943300ca5	{"sub": "b4ae48be-606a-4f80-a06b-88d943300ca5", "email": "dmoen@example.org", "email_verified": false, "phone_verified": false}	email	2026-10-15 13:08:31.934043+00	2026-10-15 13:08:31.934093+00	2026-10-15 13:08:31.934093+00	545ffc4e-88a4-4ede-8310-370a9c735680
a0a82a45-eb97-4334-bb99-2479c91b5f1b	a0a82a45-eb97-4334-bb99-2479c91b5f1b	{"sub": "a0a82a45-eb97-4334-bb99-2479c91b5f1b", "email": "macejkovic.rae@example.org", "email_verified": false, "phone_verified": false}	email	2026-10-15 13:08:34.914153+00	2026-10-15 13:08:34.9142+00	2026-10-15 13:08:34.9142+00	2b62c151-fb53-4b74-bfd4-bd7ebaac196c
fbe6825c-696c-4ea4-94ad-f79dfb522ba0	fbe6825c-696c-4ea4-94ad-f79dfb522ba0	{"sub": "fbe6825c-696c-4ea4-94ad-f79dfb522ba0", "email": "tremayne44@example.net", "email_verified": false, "phone_verified": false}	email	2026-10-15 13:10:45.008582+00	2026-10-15 13:10:45.008639+00	2026-10-15 13:10:45.008639+00	d26af70f-355d-4d8c-962d-351d0a67308a
cf600dae-95b9-433b-ae65-a54a7a8be20d	cf600dae-95b9-433b-ae65-a54a7a8be20d	{"sub": "cf600dae-95b9-433b-ae65-a54a7a8be20d", "email": "kelley29@example.com", "email_verified": false, "phone_verified": false}	email	2026-10-15 13:10:47.986311+00	2026-10-15 13:10:47.987132+00	2026-10-15 13:10:47.987132+00	05e43fd9-9df7-4cdb-a87f-aaf0411e4dcf
e5d732d7-85aa-45f0-81ff-3dfc0c1248a4	e5d732d7-85aa-45f0-81ff-3dfc0c1248a4	{"sub": "e5d732d7-85aa-45f0-81ff-3dfc0c1248a4", "email": "roberts.lilliana@example.net", "email_verified": false, "phone_verified": false}	email	2026-10-15 13:20:46.72306+00	2026-10-15 13:20:46.723114+00	2026-10-15 13:20:46.723114+00	35a49b86-1a70-46a1-b611-767e0a97edcd
4e04d5e2-16da-4506-9694-76cc803da07a	4e04d5e2-16da-4506-9694-76cc803da07a	{"sub": "4e04d5e2-16da-4506-9694-76cc803da07a", "email": "igibson@example.net", "email_verified": false, "phone_verified": false}	email	2026-10-15 13:20:50.494885+00	2026-10-15 13:20:50.494941+00	2026-10-15 13:20:50.494941+00	489cad5e-d7b3-4808-8cbb-9f383688e5dc
176a1b46-f53e-443a-a921-c5c129646c9a	176a1b46-f53e-443a-a921-c5c129646c9a	{"sub": "176a1b46-f53e-443a-a921-c5c129646c9a", "email": "windler.jewel@example.net", "email_verified": false, "phone_verified": false}	email	2026-10-15 13:37:56.458938+00	2026-10-15 13:37:56.458992+00	2026-10-15 13:37:56.458992+00	29b8d43e-36cd-4afc-8192-d05fd57369cc
0bf4b302-bfe9-4e0e-9190-0c4d148ea3df	0bf4b302-bfe9-4e0e-9190-0c4d148ea3df	{"sub": "0bf4b302-bfe9-4e0e-9190-0c4d148ea3df", "email": "sam.okon@example.org", "email_verified": false, "phone_verified": false}	email	2026-10-15 13:37:59.799614+00	2026-10-15 13:37:59.799657+00	2026-10-15 13:37:59.799657+00	a10577c0-3caf-42cd-a5b3-e7cfc79afa6a
17d66cf1-d01c-4b35-abf0-9bcf2468f16f	17d66cf1-d01c-4b35-abf0-9bcf2468f16f	{"sub": "17d66cf1-d01c-4b35-abf0-9bcf2468f16f", "email": "qfisher@example.net", "email_verified": false, "phone_verified": false}	email	2026-10-15 13:59:20.313524+00	2026-10-15 13:59:20.314271+00	2026-10-15 13:59:20.314271+00	1f8f6343-a78c-45a4-8477-2e8b8cca9ef6
6dddb34e-8862-4aef-8503-715e292a5871	6dddb34e-8862-4aef-8503-715e292a5871	{"sub": "6dddb34e-8862-4aef-8503-715e292a5871", "email": "johns.junius@example.net", "email_verified": false, "phone_verified": false}	email	2026-10-15 13:59:23.570686+00	2026-10-15 13:59:23.570736+00	2026-10-15 13:59:23.570736+00	0fa4c364-723e-414b-a984-7435d994266a
6bc0eb16-c890-45de-8b60-23067150936a	6bc0eb16-c890-45de-8b60-23067150936a	{"sub": "6bc0eb16-c890-45de-8b60-23067150936a", "email": "lcrona@example.com", "email_verified": false, "phone_verified": false}	email	2026-10-15 14:14:06.80013+00	2026-10-15 14:14:06.800189+00	2026-10-15 14:14:06.800189+00	4cf4b15f-2d77-43a2-a585-bc641d9f169e
a451920e-3f72-4812-85cd-1426ed78bcb5	a451920e-3f72-4812-85cd-1426ed78bcb5	{"sub": "a451920e-3f72-4812-85cd-1426ed78bcb5", "email": "mariana.brown@example.com", "email_verified": false, "phone_verified": false}	email	2026-10-15 14:14:09.863608+00	2026-10-15 14:14:09.863653+00	2026-10-15 14:14:09.863653+00	791a2ea8-8509-4971-9cbe-3507e8cc01b1
7280cfb2-4a88-44cf-b38b-e6121a955f02	7280cfb2-4a88-44cf-b38b-e6121a955f02	{"sub": "7280cfb2-4a88-44cf-b38b-e6121a955f02", "email": "lexus65@example.net", "email_verified": false, "phone_verified": false}	email	2026-10-15 15:06:50.894494+00	2026-10-15 15:06:50.894551+00	2026-10-15 15:06:50.894551+00	2919ce9f-937c-4715-b4c5-32255d9bcb89
6790adb6-f2bc-4a32-be51-095e9dc11107	6790adb6-f2bc-4a32-be51-095e9dc11107	{"sub": "6790adb6-f2bc-4a32-be51-095e9dc11107", "email": "santino.purdy@example.com", "email_verified": false, "phone_verified": false}	email	2026-10-15 15:06:53.999773+00	2026-10-15 15:06:53.999826+00	2026-10-15 15:06:53.999826+00	9c3ff1a7-4357-491b-b9cf-2b41370f7e73
5c6e8399-14b2-4aa4-b9c2-4355963a1eb9	5c6e8399-14b2-4aa4-b9c2-4355963a1eb9	{"sub": "5c6e8399-14b2-4aa4-b9c2-4355963a1eb9", "email": "angelus.malaluan@gmail.com", "email_verified": false, "phone_verified": false}	email	2026-10-15 15:42:06.243994+00	2026-10-15 15:42:06.244438+00	2026-10-15 15:42:06.244438+00	54a199e9-f43e-4db8-a117-d9c126e1facd
4e924c47-79c8-486e-8e94-0e39ab350052	4e924c47-79c8-486e-8e94-0e39ab350052	{"sub": "4e924c47-79c8-486e-8e94-0e39ab350052", "email": "malaluangerard@gmail.com", "email_verified": false, "phone_verified": false}	email	2026-10-15 15:42:10.787834+00	2026-10-15 15:42:10.788428+00	2026-10-15 15:42:10.788428+00	e5003bbb-ef5b-4c9d-8ac7-3a917cf413b6
09c7a59e-6435-46be-96a0-d05eb2ab50c3	09c7a59e-6435-46be-96a0-d05eb2ab50c3	{"sub": "09c7a59e-6435-46be-96a0-d05eb2ab50c3", "email": "pritongtalong808@gmail.com", "email_verified": false, "phone_verified": false}	email	2026-10-15 15:42:14.863898+00	2026-10-15 15:42:14.863946+00	2026-10-15 15:42:14.863946+00	5fa621ce-aca8-4b1e-b782-7346df356f07
7ac10bff-ecac-4a48-9780-2e1318d8e6ee	7ac10bff-ecac-4a48-9780-2e1318d8e6ee	{"sub": "7ac10bff-ecac-4a48-9780-2e1318d8e6ee", "email": "delpha.strosin@example.com", "email_verified": false, "phone_verified": false}	email	2026-10-15 16:11:18.913161+00	2026-10-15 16:11:18.913212+00	2026-10-15 16:11:18.913212+00	a4647583-694e-4b00-bd7b-2d3d54bcb848
488d7284-dcdc-4760-a53e-b5e55f722038	488d7284-dcdc-4760-a53e-b5e55f722038	{"sub": "488d7284-dcdc-4760-a53e-b5e55f722038", "email": "kozey.clare@example.com", "email_verified": false, "phone_verified": false}	email	2026-10-15 16:11:21.843467+00	2026-10-15 16:11:21.843517+00	2026-10-15 16:11:21.843517+00	174db138-e8df-4e7b-a064-e51b293ce0f6
ed91aa33-8bc0-4221-a376-cd2860f426a9	ed91aa33-8bc0-4221-a376-cd2860f426a9	{"sub": "ed91aa33-8bc0-4221-a376-cd2860f426a9", "email": "silas.senger@example.org", "email_verified": false, "phone_verified": false}	email	2026-10-16 02:25:50.276805+00	2026-10-16 02:25:50.276875+00	2026-10-16 02:25:50.276875+00	bc7509f7-5bb0-4009-8011-9e45fb583305
643e31d4-af13-4bc1-bd65-2bea5a2b7a0b	643e31d4-af13-4bc1-bd65-2bea5a2b7a0b	{"sub": "643e31d4-af13-4bc1-bd65-2bea5a2b7a0b", "email": "donoharmbygrd@gmail.com", "email_verified": false, "phone_verified": false}	email	2026-10-16 02:40:18.885535+00	2026-10-16 02:40:18.885589+00	2026-10-16 02:40:18.885589+00	af389abd-913d-446e-a53a-972e590d2108
43ceb03c-2415-4632-aca0-5ebea17f9a55	43ceb03c-2415-4632-aca0-5ebea17f9a55	{"sub": "43ceb03c-2415-4632-aca0-5ebea17f9a55", "email": "handerson@example.com", "email_verified": false, "phone_verified": false}	email	2026-10-16 03:39:18.421446+00	2026-10-16 03:39:18.421498+00	2026-10-16 03:39:18.421498+00	8706d993-7bfc-420b-8e6d-873918c0c3cd
964eb022-0ed0-4f87-bbcb-af2c411d9150	964eb022-0ed0-4f87-bbcb-af2c411d9150	{"sub": "964eb022-0ed0-4f87-bbcb-af2c411d9150", "email": "burley48@example.com", "email_verified": false, "phone_verified": false}	email	2026-10-16 03:39:21.485047+00	2026-10-16 03:39:21.485097+00	2026-10-16 03:39:21.485097+00	527db29b-5e9b-47bc-9f8e-32bb55239047
f3c029d0-d800-42cd-9dfd-4dd38c85ca42	f3c029d0-d800-42cd-9dfd-4dd38c85ca42	{"sub": "f3c029d0-d800-42cd-9dfd-4dd38c85ca42", "email": "brandi40@example.org", "email_verified": false, "phone_verified": false}	email	2026-10-16 04:10:19.40367+00	2026-10-16 04:10:19.403724+00	2026-10-16 04:10:19.403724+00	a6495106-803a-4fa5-8fe5-b57864027c0a
08ad2b62-b00d-4b72-abf6-77b824e56156	08ad2b62-b00d-4b72-abf6-77b824e56156	{"sub": "08ad2b62-b00d-4b72-abf6-77b824e56156", "email": "glind@example.net", "email_verified": false, "phone_verified": false}	email	2026-10-16 04:10:22.237322+00	2026-10-16 04:10:22.237385+00	2026-10-16 04:10:22.237385+00	e071f4a7-3009-49c8-96c9-e2f017f58b59
3329da08-12c3-404e-a92c-a6c97c3b30bc	3329da08-12c3-404e-a92c-a6c97c3b30bc	{"sub": "3329da08-12c3-404e-a92c-a6c97c3b30bc", "email": "iwisoky@example.net", "email_verified": false, "phone_verified": false}	email	2026-11-23 02:42:21.421532+00	2026-11-23 02:42:21.424172+00	2026-11-23 02:42:21.424172+00	31270673-f0df-449c-9a4c-88adafd17967
7ab7594c-292c-4894-a143-884761dff5a2	7ab7594c-292c-4894-a143-884761dff5a2	{"sub": "7ab7594c-292c-4894-a143-884761dff5a2", "email": "qkerluke@example.org", "email_verified": false, "phone_verified": false}	email	2026-11-23 02:42:25.491075+00	2026-11-23 02:42:25.491119+00	2026-11-23 02:42:25.491119+00	ba86caa3-c39b-4548-94d2-889ea2964b11
5c81993a-4828-445e-85f7-7b03c71890d9	5c81993a-4828-445e-85f7-7b03c71890d9	{"sub": "5c81993a-4828-445e-85f7-7b03c71890d9", "email": "gay24@example.net", "email_verified": false, "phone_verified": false}	email	2026-11-26 01:53:01.51779+00	2026-11-26 01:53:01.517856+00	2026-11-26 01:53:01.517856+00	e9ee9800-afb0-4ff5-8ed4-e9bcb16e90e9
f3df3bae-9051-4ad9-aac9-f7a6cc0d3415	f3df3bae-9051-4ad9-aac9-f7a6cc0d3415	{"sub": "f3df3bae-9051-4ad9-aac9-f7a6cc0d3415", "email": "kertzmann.amy@example.org", "email_verified": false, "phone_verified": false}	email	2026-11-26 01:53:02.566257+00	2026-11-26 01:53:02.566304+00	2026-11-26 01:53:02.566304+00	d9c7f89e-2e69-45b5-83e1-9a9876890b94
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid, last_webauthn_challenge_data) FROM stdin;
\.


--
-- Data for Name: mfa_recovery_code_sets; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_recovery_code_sets (id, user_id, mfa_factor_id, failed_verification_count, verification_locked_until, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_recovery_codes; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_recovery_codes (id, mfa_recovery_code_set_id, code_hash, consumed_at, created_at) FROM stdin;
\.


--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_authorizations (id, authorization_id, client_id, user_id, redirect_uri, scope, state, resource, code_challenge, code_challenge_method, response_type, status, authorization_code, created_at, expires_at, approved_at, nonce) FROM stdin;
\.


--
-- Data for Name: oauth_client_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_client_states (id, provider_type, code_verifier, created_at) FROM stdin;
\.


--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_clients (id, client_secret_hash, registration_type, redirect_uris, grant_types, client_name, client_uri, logo_uri, created_at, updated_at, deleted_at, client_type, token_endpoint_auth_method) FROM stdin;
\.


--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_consents (id, user_id, client_id, scopes, granted_at, revoked_at) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at, expires_at, link_token_hash) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format, dedicated_scope) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
20250717082212
20250731150234
20250804100000
20250901200500
20250903112500
20250904133000
20250925093508
20251007112900
20251104100000
20251111201300
20251201000000
20260115000000
20260121000000
20260219120000
20260302000000
20260625000000
20260821000000
20260821010000
20260824000000
20260824000001
20260831180000
20260911120000
20261030120000
20261116120000
\.


--
-- Data for Name: scim_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.scim_tokens (id, sso_provider_id, token_hash, prefix, created_at, expires_at, revoked_at, last_used_at) FROM stdin;
\.


--
-- Data for Name: scim_users; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.scim_users (id, sso_provider_id, user_id, resource, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag, oauth_client_id, refresh_token_hmac_key, refresh_token_counter, scopes) FROM stdin;
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at, disabled) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
00000000-0000-0000-0000-000000000000	7dddedef-acc6-4460-89ee-f6759890cb89	authenticated	authenticated	mosciski.elise@example.com	$2a$10$cfR54Xdl07.0uoj6QOj6pexAYp4UWCasmNugJJp9ZQhp/VqAf1EG6	2026-09-19 18:09:03.056904+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 17}	\N	2026-09-19 18:09:03.018601+00	2026-09-19 18:09:03.057811+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	a95c61fb-b1a8-4a66-bd77-f87a42e1d30e	authenticated	authenticated	jane.doe@example.com	$2a$10$Ef9eUmCUjnssljOzUFWFy.6.9N4KmbjDLqMwoaHUKt6fgsD.WtFpa	2026-09-19 16:41:47.939824+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 4}	\N	2026-09-19 16:41:47.910848+00	2026-09-19 16:41:47.942335+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	cdbf1ad0-9a79-42f4-8dcb-fcd62f1c752c	authenticated	authenticated	emmy.gislason@example.com	$2a$10$LBHJSmVhWQEWlMzcENZgle.0QLm/S7ylW8KTVsbeJgTB713zO4FjK	2026-09-19 17:05:52.961376+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 17}	\N	2026-09-19 17:05:52.918476+00	2026-09-19 17:05:52.966135+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	8b841be5-23cb-47c4-a06e-c0fc5d62c8d0	authenticated	authenticated	corwin.kendrick@example.org	$2a$10$b0eisA/7HmVjzjFCtw4fyeKveKFV7Ehp56WWFIU3TRqht1oXelODy	2026-09-19 16:42:20.143757+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 17}	\N	2026-09-19 16:42:20.126048+00	2026-09-19 16:42:20.153114+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	b482173f-e3f0-400c-a466-b1ffba4f65d5	authenticated	authenticated	yasmin24@example.org	$2a$10$655bemitpdsjdDMpaWOjH.a832HKNw0wYINRa1bgbQbEJSY4b/EVS	2026-09-20 07:22:32.411248+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 18}	\N	2026-09-20 07:22:32.405441+00	2026-09-20 07:22:32.41308+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	7c2914c1-f5f0-4ca3-8cda-1dd33ee02b13	authenticated	authenticated	pfeffer.magnus@example.net	$2a$10$a9J1FDOHgSqNfQSwumbAiuCyZ0EsqX7dq0R47UB0De3kBC1UXfGES	2026-09-24 11:01:37.623385+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 18}	\N	2026-09-24 11:01:37.616717+00	2026-09-24 11:01:37.626078+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	c6c37413-8872-4d9a-89e1-4ab386550320	authenticated	authenticated	cohara@example.org	$2a$10$735Skc6POPSb76v08VJ3BuwWYqWREbbE54PXq9jvPRwuhMQEsiCzu	2026-09-19 17:05:55.690099+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 18}	\N	2026-09-19 17:05:55.685097+00	2026-09-19 17:05:55.69129+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	a8ffc58a-dc7b-4349-b962-3210fe4dfdff	authenticated	authenticated	ogerlach@example.org	$2a$10$FFVV/lFA0WWywwtE2mjWguQ3bMeiyru/dNJM5e34uNQ6gbq0hJwYy	2026-09-19 16:42:22.977158+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 18}	\N	2026-09-19 16:42:22.969221+00	2026-09-19 16:42:22.982363+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	39c4594a-625c-40e4-bd01-64cc3d393aa3	authenticated	authenticated	qconroy@example.org	$2a$10$6LYvRqID9.L6ncJXiX7MFeu2oI3mfo3uhKbYk4Px3p8TYujDMgWdO	2026-09-19 18:09:05.891694+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 18}	\N	2026-09-19 18:09:05.886712+00	2026-09-19 18:09:05.893453+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	3745a390-135d-4a73-a59c-dd78435cdcb8	authenticated	authenticated	tatyana39@example.net	$2a$10$ecWKc7ZJe/vlop5PmGYHEOpV17A8gg5GvYfsKc2BRA49zJNMIen6.	2026-09-20 07:22:29.771028+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 17}	\N	2026-09-20 07:22:29.736832+00	2026-09-20 07:22:29.778255+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	a5ebcdfc-c5de-4121-be4e-5f03401e9dba	authenticated	authenticated	muhammad.stehr@example.org	$2a$10$gUC0.t4GZ5QlYxrAx62gDOWMbwV61.UOaKYUVvcxtJIUlWlqSjZSy	2026-09-28 14:52:37.83132+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 18}	\N	2026-09-28 14:52:37.82802+00	2026-09-28 14:52:37.833368+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	af73fd05-fee8-4d9e-a789-b39cac2b7dcc	authenticated	authenticated	kassulke.elsa@example.net	$2a$10$4zmikr2fDs2lYLbCnoHHsebw3F9imUuIeFUUsgi5g.AZnbAjKqHw2	2026-09-24 11:01:31.97057+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 17}	\N	2026-09-24 11:01:31.938425+00	2026-09-24 11:01:31.976508+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	6477014d-9bc4-4546-88b7-4b5b05c4e19f	authenticated	authenticated	lyric09@example.com	$2a$10$IbPSNkSMLvBtg/0oquYlPeTbCD8OykF6f2eJPOdcvPW3xFxyakjXG	2026-09-28 14:52:32.058843+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 17}	\N	2026-09-28 14:52:32.024266+00	2026-09-28 14:52:32.060453+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	bf9c72a7-012b-4bd2-bb90-fcf2a34f274b	authenticated	authenticated	yjohns@example.net	$2a$10$S2z8y4VGUwMxI/pviVONFekbZ2PXjitTkn10wJ.qOB2MazdBFBHDa	2026-09-29 12:33:08.254332+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 17}	\N	2026-09-29 12:33:08.229701+00	2026-09-29 12:33:08.257182+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	59ddaa6f-c4a6-4003-b462-44d98324fea6	authenticated	authenticated	vlynch@example.com	$2a$10$QhjSEdIdfrbbz2/D0k2bTemd.LXzRnVHQbhjkkIQjdeY2TU9W/KCy	2026-09-29 12:33:11.60097+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 18}	\N	2026-09-29 12:33:11.595877+00	2026-09-29 12:33:11.601739+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	ed2b08d5-0f59-420a-a8b9-d12ccd7ce066	authenticated	authenticated	marquardt.reese@example.org	$2a$10$HUI.pzoPruHBMLmSIMm7POQL1kYTzQ8CcuingYXXvigifo2VtvAJ2	2026-09-29 12:44:50.089791+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 17}	\N	2026-09-29 12:44:50.057177+00	2026-09-29 12:44:50.098333+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	2fb809bc-b975-4369-a744-a8fa4372b992	authenticated	authenticated	guiseppe.kassulke@example.org	$2a$10$JRYxnckWAcAynWNc3SMBlOrjz8HpkRqszNsmrbusUq1iM1.DLzVrq	2026-10-05 05:08:42.350587+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 16}	\N	2026-10-05 05:08:42.323495+00	2026-10-05 05:08:42.351554+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	582e3584-2bca-489e-8d80-8b9d9deaa736	authenticated	authenticated	susie41@example.net	$2a$10$3y5XVB9i8HrHSvle5esHUu5.C1MPHUesjUTwn5S8IZG4E/oSDdFvO	2026-10-05 04:31:59.29453+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 17}	\N	2026-10-05 04:31:59.290983+00	2026-10-05 04:31:59.29678+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	7158309d-64d5-4391-8f41-ad5952681cd2	authenticated	authenticated	cristal.reichel@example.org	$2a$10$MLTNO9.3L9avhI4H9NuZg.hlIyzpSbWA98PTrDsR8K/nzm//gCOJq	2026-09-29 12:44:53.409051+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 18}	\N	2026-09-29 12:44:53.404413+00	2026-09-29 12:44:53.411202+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	b1b21d76-4214-4092-93e6-d610336f6b63	authenticated	authenticated	blaze24@example.net	$2a$10$csJxWMNwLcMFkQdA0nCCCOL/klP4YPQrc/jTmjrSQ4N09IWWe.Q6i	2026-10-01 14:27:43.04622+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 16}	\N	2026-10-01 14:27:43.017358+00	2026-10-01 14:27:43.049116+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	40f338bb-bd40-4622-9083-d45fa35b6f61	authenticated	authenticated	christiansen.gertrude@example.net	$2a$10$5uL7hdOKHOOKxNZz1vgaA.M8B7bpeWqyd7G2Xbd.w1Afr7TM/QCYy	2026-10-05 06:15:29.44196+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 16}	\N	2026-10-05 06:15:29.412742+00	2026-10-05 06:15:29.444346+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	4870c15d-0b86-48e5-bd80-e35ba2eb89ff	authenticated	authenticated	thiel.alisha@example.com	$2a$10$ggbnGdYnX8bNzpAJv3bEZOYONG500G306asH4Rh0d.G9Lln1CTAvG	2026-10-05 04:53:15.178701+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 12}	\N	2026-10-05 04:53:15.126959+00	2026-10-05 04:53:15.185977+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	56eb65ce-a3a7-4275-b120-9844eb919a28	authenticated	authenticated	hartmann.maurice@example.com	$2a$10$4NOUmb36ER1Qbk4uGssTuucprFzID/F8gWBs7Im40zi4cUBARvq7a	2026-10-01 14:27:46.827565+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 17}	\N	2026-10-01 14:27:46.800625+00	2026-10-01 14:27:46.828758+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	758adfd0-1331-4d60-ba1d-dcae6c90565f	authenticated	authenticated	evalyn.davis@example.org	$2a$10$AeEcNqcXAU3G.WqEqoC/7e3NCWZZqg2xkV2I1OruT2sNuchJXnKHy	2026-10-05 04:31:55.541726+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 16}	\N	2026-10-05 04:31:55.520783+00	2026-10-05 04:31:55.543873+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	34556ff5-eae0-4047-976f-174980356a7e	authenticated	authenticated	gleason.bonita@example.net	$2a$10$2Qi4u8UyEMhx7Mpuff8G7OOnhCOKZrAbIPJkJUuvRg6.2AvxvRK4a	2026-10-05 05:08:45.81859+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 17}	\N	2026-10-05 05:08:45.809847+00	2026-10-05 05:08:45.820458+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	02c911f1-8288-443d-957b-b96012c30f2d	authenticated	authenticated	cordia.veum@example.com	$2a$10$qbFlgdxlfgZzBqxbM/rNv.BIOTYy6kZihsNgsWHCKpQUM0MdqiQai	2026-10-05 04:53:18.848379+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 13}	\N	2026-10-05 04:53:18.838339+00	2026-10-05 04:53:18.850264+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	52b21747-5738-46d0-9058-8a5d0f5e6ba3	authenticated	authenticated	rosamond.blanda@example.org	$2a$10$IXMPul9Y5kS3XwP4oS1ZC.S5XOEf6oes.KvUERwhVrP0swYHRGRZS	2026-10-05 06:28:15.027781+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 17}	\N	2026-10-05 06:28:15.024628+00	2026-10-05 06:28:15.02853+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	0bc972d7-2333-4cab-a458-932332b5b4e1	authenticated	authenticated	leanna.treutel@example.org	$2a$10$mF7XuusEIjXNIYd/I6Fi7OVY6h.ZNDUMidfD9G/xtfmgs9WNgC/oC	2026-10-05 06:28:11.350425+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 16}	\N	2026-10-05 06:28:11.33618+00	2026-10-05 06:28:11.351372+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	731e5ea3-c782-46bd-8d62-32d31e357ed7	authenticated	authenticated	mbins@example.net	$2a$10$h7SwEeWsWTQQyU/Ev1qz0e3lJatD7O0wS8A06OxZ1hgf.vx9J4Kaa	2026-10-05 06:15:33.157848+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 17}	\N	2026-10-05 06:15:33.154166+00	2026-10-05 06:15:33.159558+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	7e531406-ceef-4f16-9f6c-2b867d04351d	authenticated	authenticated	vwatsica@example.com	$2a$10$yFnVSQqxn.H1/AOS/Hu8p.shpG6tnIM4NRCwGPZjdAHO4nvOC7Aeq	2026-10-05 06:37:08.164481+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 16}	\N	2026-10-05 06:37:08.129716+00	2026-10-05 06:37:08.167289+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	2260d0d8-0666-40a0-8007-ab57c69c35e8	authenticated	authenticated	scarlett.nicolas@example.com	$2a$10$1ujuXHvqHkzLxD8qkNi1N.snDIeesmCaprbY6FtUUyPii6.LnAGzO	2026-10-05 06:37:11.903707+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 17}	\N	2026-10-05 06:37:11.895914+00	2026-10-05 06:37:11.90763+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	6dc94d10-0d0a-4704-bb31-c70380519237	authenticated	authenticated	thompson.elwyn@example.net	$2a$10$oOoMhs/BO1IHFaY53j8ehuEiKI1UY6ZKfMuNTK67fPxNi5HFChR6C	2026-10-05 06:54:16.181983+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 16}	\N	2026-10-05 06:54:16.161192+00	2026-10-05 06:54:16.183004+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	792db754-e8ee-4e90-bfd6-ec0438f9b231	authenticated	authenticated	considine.barbara@example.net	$2a$10$fZnDw6aBAIFg5AlLqjqP1e7507roXvQfe1Yob/o57uO0DgSFHrpK6	2026-10-05 06:54:20.019343+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 17}	\N	2026-10-05 06:54:19.972295+00	2026-10-05 06:54:20.027574+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	4b53f53e-d4b0-4284-8963-889d7164a4cb	authenticated	authenticated	vmonahan@example.net	$2a$10$.wDCHMRAuheMmJUFxFZYkuCfnkWgth83HlgI3s7wu2pFn4L4rDwKy	2026-10-05 07:02:07.272422+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 16}	\N	2026-10-05 07:02:07.190025+00	2026-10-05 07:02:07.27937+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	11bb3f53-c8d9-4250-84d9-c5d8bc34b756	authenticated	authenticated	nulptimekeeping@gmail.com	$2a$10$gQfwhHRXMDsv8B0KBNsCb.tFkqOenHCAUojNzo3yuk9Us/TaFzOc2	2026-10-12 13:10:41.576024+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 2, "email_verified": true, "laravel_user_id": 78}	\N	2026-10-05 08:48:54.066637+00	2026-10-12 13:10:41.595346+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	8e760aa8-1684-408f-a088-441fe6099e86	authenticated	authenticated	hartmann.ivah@example.net	$2a$10$qnNsGIXLFKDIeFQlzrqIaukXNroEiNEbtME5vcrZ.fFzoW8ziHeNS	2026-10-05 07:02:13.044775+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 17}	\N	2026-10-05 07:02:12.825673+00	2026-10-05 07:02:13.072768+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	2852fb70-6a1f-44b5-bc2c-506490a4aaad	authenticated	authenticated	shiela.natanuan.1@gmail.com	$2a$10$aS0Smgov/.dYoRSg.gKH0O2c9Rr3gWbuq3J/9HLfCAxsHpNz6OQ8m	2026-10-13 07:55:59.38062+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 47}	\N	2026-10-13 07:55:59.341539+00	2026-10-13 07:55:59.385288+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	2dd3114b-dc80-4a27-afa2-0be20fb50d2e	authenticated	authenticated	cummerata.jacques@example.com	$2a$10$TeRD71YzXFDqvkrri8UxXuVu9FLzv.jcl1gN4Ippbi00BACAl70QG	2026-10-12 12:50:29.691262+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 25}	\N	2026-10-12 12:50:29.637017+00	2026-10-12 12:50:29.696516+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	ac33c8d8-8dd4-4f62-b20f-0b57651fe7a3	authenticated	authenticated	sharleneanne.hidalgo@gmail.com	$2a$10$0Wz75P7zA6uZYehf6BuilO7VJlxNBy9Eh1X7xcZcTCc7Iz8jtQ5c.	2026-10-13 08:03:43.398534+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 48}	\N	2026-10-13 08:03:43.366284+00	2026-10-13 08:03:43.406162+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	1ab9ac5c-1a7b-4709-8164-968215cfa07f	authenticated	authenticated	candace.gottlieb@example.net	$2a$10$4zsunceJjxPcSih7zUItY.ucu1FF4ti.5Ua5p1YvC04BoyWW3mily	2026-10-13 09:15:56.899415+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 25}	\N	2026-10-13 09:15:56.837452+00	2026-10-13 09:15:56.906727+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	c35640db-bb56-43e9-9be6-d77d641c6cf8	authenticated	authenticated	timekeeper@example.com	$2a$10$BRG2pgQMO0l2v/ft8DMJ/uFFIGDaUw1LHecFZknB63.SImqWFdPrK	2026-10-05 08:20:06.988926+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 2, "email_verified": true, "laravel_user_id": 2}	\N	2026-10-05 08:20:06.951364+00	2026-10-05 08:20:06.990792+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	c3ea8274-ab7e-4e6f-a25f-0ed183031a39	authenticated	authenticated	tristin.konopelski@example.org	$2a$10$2aqlVFGvua9WO1U/Xo7AHucypUlUYQzdrLRFMgmIYOKBjfYAJo0pm	2026-10-12 12:50:32.410229+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 26}	\N	2026-10-12 12:50:32.404191+00	2026-10-12 12:50:32.411866+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	28d314e7-f9b5-4452-87e8-8542e797e4ce	authenticated	authenticated	cledner@example.com	$2a$10$Ms0f2B/Xg6fPkSP6NqArDemg.V5jno0/OiC2o9Mrz9g.A0osMTCv6	2026-10-13 09:15:59.707045+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 26}	\N	2026-10-13 09:15:59.694711+00	2026-10-13 09:15:59.708161+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	a06ca5cd-0838-46da-a20a-70deb44e2828	authenticated	authenticated	judyanntesting1013@gmail.com	$2a$10$6WT0jV0K5YpfgiVOjpGsl.YZEMCk.LyIl4KqnVRZWIT0/dto.1sdy	2026-10-13 15:54:57.613126+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 59}	\N	2026-10-13 15:54:57.582926+00	2026-10-13 15:54:57.616065+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	fb54eaf5-b11c-44ad-b924-04c16024eda9	authenticated	authenticated	jaysargetesting1013@gmail.com	$2a$10$pgLMYTTMP2j0Xt.6NrMBMes3.xwGHIur30xu8bJFU/nPyZta6z0Zy	2026-10-13 15:49:55.918269+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 57}	\N	2026-10-13 15:49:55.894912+00	2026-10-13 15:49:55.929688+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	b1c1dbe7-11b8-401a-95d7-bc437c3c7dbf	authenticated	authenticated	joseabeltesting1013@gmail.com	$2a$10$YXcjAPna2nP5LGo9GpvPROaDXWRg2doshrwjVvkbsxUfKwgN8XNYq	2026-10-13 15:52:07.557837+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 58}	\N	2026-10-13 15:52:07.494168+00	2026-10-13 15:52:07.564163+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	e45f74ce-d96a-44fb-b1dd-d2f2c02e91ff	authenticated	authenticated	clarissatesting1013@gmail.com	$2a$10$qu0pOaKLyVHNRFk.Ap2tcOvvHYMhGvOQc2xkVCji7Gmqcu44KzwD6	2026-10-13 15:57:12.884526+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 60}	\N	2026-10-13 15:57:12.855973+00	2026-10-13 15:57:12.885547+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	8a635d51-8ec6-42d2-819b-cd632f092ba7	authenticated	authenticated	jamir.keeling@example.com	$2a$10$jjpRqrPkfrsbxcVvX6GliOulgnyCABbVRYlB6oU3gDYcv6QlfYhBm	2026-10-14 02:11:21.584603+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 25}	\N	2026-10-14 02:11:21.538593+00	2026-10-14 02:11:21.587046+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	d4a09ac9-7118-49f9-bbd3-90bc6ffd5c2d	authenticated	authenticated	jayne60@example.org	$2a$10$EKidXhiQJEx2y1CeIrUzweNCq0PLnAkxVbLxH7.0/v479yYtLBFnW	2026-10-14 02:11:24.723963+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 26}	\N	2026-10-14 02:11:24.71682+00	2026-10-14 02:11:24.725812+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	f5b3f82f-ed69-4a3f-a04c-dcd84921ffe7	authenticated	authenticated	leonor23@example.org	$2a$10$5E3hywAIBVGQMCTgqhvpfe63ZZ53xLjqqaoSXDBud5dsWCmTMLN5y	2026-10-15 13:06:06.524746+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 24}	\N	2026-10-15 13:06:06.451151+00	2026-10-15 13:06:06.529122+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	53d2d2e8-a570-4c52-b2e7-4124986d7b9f	authenticated	authenticated	ola.hoppe@example.net	$2a$10$DeSCflQ3C28yCs47cqjVJurmtHHtdQCoHSoaPW6tcbswphRyaMJv6	2026-10-15 13:06:09.536907+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 25}	\N	2026-10-15 13:06:09.52183+00	2026-10-15 13:06:09.541623+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	b4ae48be-606a-4f80-a06b-88d943300ca5	authenticated	authenticated	dmoen@example.org	$2a$10$98NAMem8MptAQL6jxuw76eSQ7nioTN7/EWwCtDNyt9bu7Y7LuDepy	2026-10-15 13:08:31.945366+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 24}	\N	2026-10-15 13:08:31.924462+00	2026-10-15 13:08:31.94959+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	6dddb34e-8862-4aef-8503-715e292a5871	authenticated	authenticated	johns.junius@example.net	$2a$10$buMjo7CQpY0icuIfCcBC9uqcpkMolDLsHT5BlyCyvQa3mssUDPHuS	2026-10-15 13:59:23.573184+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 22}	\N	2026-10-15 13:59:23.565664+00	2026-10-15 13:59:23.574748+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	a0a82a45-eb97-4334-bb99-2479c91b5f1b	authenticated	authenticated	macejkovic.rae@example.org	$2a$10$PN957Oolq0pDzfnjQOKM0.NMlN/NBcxMKOYYaEGa1QKVclbtbQZKW	2026-10-15 13:08:34.917543+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 25}	\N	2026-10-15 13:08:34.909685+00	2026-10-15 13:08:34.971992+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	176a1b46-f53e-443a-a921-c5c129646c9a	authenticated	authenticated	windler.jewel@example.net	$2a$10$Hj.N/Xbg0knxuBoTwvsCN.rKKsVwPp1PQgDt4oPChDJ5NU0LPnIDy	2026-10-15 13:37:56.471656+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 24}	\N	2026-10-15 13:37:56.443115+00	2026-10-15 13:37:56.472613+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	fbe6825c-696c-4ea4-94ad-f79dfb522ba0	authenticated	authenticated	tremayne44@example.net	$2a$10$.5zXbPva9sVmX7E/f0gjG.cr9DYxzKmjEicwaQqOXT6piOnE8XR.e	2026-10-15 13:10:45.03634+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 25}	\N	2026-10-15 13:10:44.981649+00	2026-10-15 13:10:45.037456+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	cf600dae-95b9-433b-ae65-a54a7a8be20d	authenticated	authenticated	kelley29@example.com	$2a$10$3V9i/JidQoMrGqWXyx9Q5.02V.wJ/4XZ1u9oTfRJlw8p5KseSfsAO	2026-10-15 13:10:48.014792+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 26}	\N	2026-10-15 13:10:47.954438+00	2026-10-15 13:10:48.022852+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	0bf4b302-bfe9-4e0e-9190-0c4d148ea3df	authenticated	authenticated	sam.okon@example.org	$2a$10$9PCKcqu98oa5yRXdZyXSxOXS/ffHb4wp/rG/Nm5w48o3x/TOqDkze	2026-10-15 13:37:59.801011+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 25}	\N	2026-10-15 13:37:59.798622+00	2026-10-15 13:37:59.802223+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	e5d732d7-85aa-45f0-81ff-3dfc0c1248a4	authenticated	authenticated	roberts.lilliana@example.net	$2a$10$PtqXBkdzf1hzzVT7pfzW1.gG8EIlycgAvACzGhvOqHNAbLWeQZDYK	2026-10-15 13:20:46.745714+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 24}	\N	2026-10-15 13:20:46.701223+00	2026-10-15 13:20:46.750545+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	6bc0eb16-c890-45de-8b60-23067150936a	authenticated	authenticated	lcrona@example.com	$2a$10$GdmxraMmsE6UQRxbr9/E9Oss7UpWSERU6ENhT8.APIAKgegO9wGce	2026-10-15 14:14:06.836232+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 21}	\N	2026-10-15 14:14:06.774932+00	2026-10-15 14:14:06.839221+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	4e04d5e2-16da-4506-9694-76cc803da07a	authenticated	authenticated	igibson@example.net	$2a$10$I2kxHSS5QXQcvksE2O.PuOiVz.Sj0PzOULZku9gH6hmqPET02Ut4m	2026-10-15 13:20:50.524607+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 25}	\N	2026-10-15 13:20:50.452039+00	2026-10-15 13:20:50.527024+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	17d66cf1-d01c-4b35-abf0-9bcf2468f16f	authenticated	authenticated	qfisher@example.net	$2a$10$coyJ/pxis7mv4jisAeUd6OS/XESV0ld/4LhE1eGc76brYAtEM/Jb6	2026-10-15 13:59:20.333628+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 21}	\N	2026-10-15 13:59:20.288311+00	2026-10-15 13:59:20.338975+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	5c6e8399-14b2-4aa4-b9c2-4355963a1eb9	authenticated	authenticated	angelus.malaluan@gmail.com	$2a$10$V7YOHM9YVNninXAnlZBMGupqrQW7lJlMoK7mVfkt6aWVdmmOJUssW	2026-10-15 15:42:06.253739+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 65}	\N	2026-10-15 15:42:06.21259+00	2026-10-15 15:42:06.255378+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	7280cfb2-4a88-44cf-b38b-e6121a955f02	authenticated	authenticated	lexus65@example.net	$2a$10$vslY0Fe42Zqcunz25StJg.gpOyvlilTj6F8loeEiTPFyOzjB7qizO	2026-10-15 15:06:50.907679+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 21}	\N	2026-10-15 15:06:50.866907+00	2026-10-15 15:06:50.910067+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	a451920e-3f72-4812-85cd-1426ed78bcb5	authenticated	authenticated	mariana.brown@example.com	$2a$10$ZTqMYuuewlluugS8fnW5r.TM76H8cBc96hqbMpeJ6Qa.co0w3Ofy2	2026-10-15 14:14:09.866116+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 22}	\N	2026-10-15 14:14:09.858884+00	2026-10-15 14:14:09.867966+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	6790adb6-f2bc-4a32-be51-095e9dc11107	authenticated	authenticated	santino.purdy@example.com	$2a$10$5fAdMqM3yRdDzSE3D0NMZeV88INTUYvPq5sqr3stb22WJQFFMkfNe	2026-10-15 15:06:54.001774+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 22}	\N	2026-10-15 15:06:53.992533+00	2026-10-15 15:06:54.002521+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	4e924c47-79c8-486e-8e94-0e39ab350052	authenticated	authenticated	malaluangerard@gmail.com	$2a$10$Mzzx7hgNFznrpUowl4hKGeDGzNypgjItH9q0P5nZq4Lk1jFNusTbG	2026-10-15 15:42:10.792326+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 66}	\N	2026-10-15 15:42:10.783752+00	2026-10-15 15:42:10.798935+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	09c7a59e-6435-46be-96a0-d05eb2ab50c3	authenticated	authenticated	pritongtalong808@gmail.com	$2a$10$q0I0ilhkkaZTlCaNnDL6EuPzWyOc9bDZLw0YmugM3Xkojqy4brBBa	2026-10-15 15:42:14.867656+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 68}	\N	2026-10-15 15:42:14.860275+00	2026-10-15 15:42:14.871086+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	7ac10bff-ecac-4a48-9780-2e1318d8e6ee	authenticated	authenticated	delpha.strosin@example.com	$2a$10$Huux6/DLkjslzLsNdCX8H.H2REv8kk4GP6rKR4kCp.T1QqdZ4nnj6	2026-10-15 16:11:18.92654+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 21}	\N	2026-10-15 16:11:18.897767+00	2026-10-15 16:11:18.927559+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	f3c029d0-d800-42cd-9dfd-4dd38c85ca42	authenticated	authenticated	brandi40@example.org	$2a$10$/DLeY9Th3WVhm03fvR2ZcO680/u1xMQq1s/i8I7vaCRhG6J5u2VKm	2026-10-16 04:10:19.417509+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 21}	\N	2026-10-16 04:10:19.383435+00	2026-10-16 04:10:19.419779+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	488d7284-dcdc-4760-a53e-b5e55f722038	authenticated	authenticated	kozey.clare@example.com	$2a$10$Zur6FX2xky/HXPhQErbnfepk5O1YdkXHHTh2msPSi7N2NkBjMxa26	2026-10-15 16:11:21.846297+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 22}	\N	2026-10-15 16:11:21.840825+00	2026-10-15 16:11:21.847541+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	643e31d4-af13-4bc1-bd65-2bea5a2b7a0b	authenticated	authenticated	donoharmbygrd@gmail.com	$2a$10$b/L2NcGgtCX3XNZ0Oq8.dOqFPILocSTNO3/etsQlLWMsAcziZlH.q	2026-10-16 02:40:18.907513+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 69}	\N	2026-10-16 02:40:18.868125+00	2026-10-16 02:40:18.910461+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	9855edf9-6256-46d3-869f-66790b2360f3	authenticated	authenticated	francisca19@example.net	$2a$10$8k6N3jQNIY7Wke9BgVHYv.8wbh3ACS/46Bg8hP5XGdZNz0EVDW8Lm	2026-10-15 16:36:22.042595+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 21}	\N	2026-10-15 16:36:22.003407+00	2026-10-15 16:36:22.045099+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	e1c9ffe5-f261-4899-b42c-4145eb91b8e6	authenticated	authenticated	akulas@example.org	$2a$10$yKHyas7.8FbdHZaJbbIvH.Mnpki4wPUkGR3JxpMCgiUyU4w0Rw7cG	2026-10-15 16:36:24.99084+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 22}	\N	2026-10-15 16:36:24.985496+00	2026-10-15 16:36:24.993376+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	43ceb03c-2415-4632-aca0-5ebea17f9a55	authenticated	authenticated	handerson@example.com	$2a$10$SDJg5GsMh4vtsjBuwgdVrOq4hJYMNDOotbp0J5FsWW76Cbg4b8sW2	2026-10-16 03:39:18.441464+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 21}	\N	2026-10-16 03:39:18.409748+00	2026-10-16 03:39:18.443444+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	73f6c948-99c9-46dd-ba7f-6b5b638b1819	authenticated	authenticated	nicholas61@example.com	$2a$10$2AfRX4yNxCqlqTnGeBnznu5uPhsg3lV4gmxF7BcoYEZPUCWRHjEoO	2026-10-16 02:25:47.069711+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 21}	\N	2026-10-16 02:25:47.031813+00	2026-10-16 02:25:47.07267+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	08ad2b62-b00d-4b72-abf6-77b824e56156	authenticated	authenticated	glind@example.net	$2a$10$VmEwwO068NTb657d42Mkb.WL0ag8wCH0So7wxz4hUKQ0Z7XSPwYUa	2026-10-16 04:10:22.240596+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 22}	\N	2026-10-16 04:10:22.234064+00	2026-10-16 04:10:22.242175+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	ed91aa33-8bc0-4221-a376-cd2860f426a9	authenticated	authenticated	silas.senger@example.org	$2a$10$9v1kVnAsMCQYPNItbk5bueEzLwTlmjVqBdlc1PIhCz7hYfsO3XDI.	2026-10-16 02:25:50.305581+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 22}	\N	2026-10-16 02:25:50.269472+00	2026-10-16 02:25:50.308504+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	964eb022-0ed0-4f87-bbcb-af2c411d9150	authenticated	authenticated	burley48@example.com	$2a$10$WGbt.y77l1XJ0T94gLVU.O/9c/oZDFqTksW8SjiuLnLiYh3KSQdRi	2026-10-16 03:39:21.486948+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 22}	\N	2026-10-16 03:39:21.482928+00	2026-10-16 03:39:21.487661+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	7ab7594c-292c-4894-a143-884761dff5a2	authenticated	authenticated	qkerluke@example.org	$2a$10$BaEgFdE/SdiEUmR0mYtO8OhGHcXC7Us/rz29gh2WMK6mKYkMDVd5W	2026-11-23 02:42:25.493788+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 22}	\N	2026-11-23 02:42:25.490036+00	2026-11-23 02:42:25.494458+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	3329da08-12c3-404e-a92c-a6c97c3b30bc	authenticated	authenticated	iwisoky@example.net	$2a$10$hBlaNrkPFjGn4D92o.9v4euMaE6OPWTqotXkCK8TviqgXg1J9xes.	2026-11-23 02:42:21.43447+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 21}	\N	2026-11-23 02:42:21.411804+00	2026-11-23 02:42:21.435469+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	f3df3bae-9051-4ad9-aac9-f7a6cc0d3415	authenticated	authenticated	kertzmann.amy@example.org	$2a$10$5R29/K/HmbaDxDyVXTl9vuHL8rrh6DGf75G9gIA/uMqgd3zMv8t0K	2026-11-26 01:53:02.568485+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 0, "email_verified": true, "laravel_user_id": 1}	\N	2026-11-26 01:53:02.565198+00	2026-11-26 01:53:02.569217+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	5c81993a-4828-445e-85f7-7b03c71890d9	authenticated	authenticated	gay24@example.net	$2a$10$oyK1IeX7/B1bIAiDdRWqoear0zKnpqKbfETGmoiUFgz2NFL19X.8e	2026-11-26 01:53:01.532896+00	\N		\N		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"user_type": 3, "email_verified": true, "laravel_user_id": 1}	\N	2026-11-26 01:53:01.509469+00	2026-11-26 01:53:01.533962+00	\N	\N			\N		0	\N		\N	f	\N	f
\.


--
-- Data for Name: webauthn_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.webauthn_challenges (id, user_id, challenge_type, session_data, created_at, expires_at) FROM stdin;
\.


--
-- Data for Name: webauthn_credentials; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.webauthn_credentials (id, user_id, credential_id, public_key, attestation_type, aaguid, sign_count, transports, backup_eligible, backed_up, friendly_name, created_at, updated_at, last_used_at) FROM stdin;
\.


--
-- Data for Name: academic_calendar_entries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.academic_calendar_entries (id, title, entry_type, event_date, description, created_at, updated_at, day_type) FROM stdin;
8	Sample Holiday	holiday	2026-10-06	\N	2026-10-12 21:35:59	2026-10-12 21:35:59	non_working
9	Bonifacio Day	holiday	2026-11-30	Commemorates the birth of Andrés Bonifacio, a key figure in the Philippine Revolution.	2026-10-13 20:04:00	2026-10-13 20:04:00	non_working
10	All Saints' Day	holiday	2026-11-01	Honors saints and remembers the lives of the departed faithful.	2026-10-13 20:05:21	2026-10-13 20:05:21	non_working
11	All Souls' Day	holiday	2026-11-02	Dedicated to remembering and praying for deceased loved ones.	2026-10-13 20:06:27	2026-10-13 20:06:27	non_working
12	Feast of the Immaculate Conception of Mary	holiday	2026-12-08	Commemorates the Catholic belief in Mary's conception without original sin.	2026-10-13 20:11:57	2026-10-13 20:11:57	non_working
13	Feast of the Immaculate Conception of Mary	holiday	2026-12-08	Commemorates the Catholic belief in Mary's conception without original sin.	2026-10-13 20:11:59	2026-10-13 20:11:59	non_working
14	Christmas Eve	holiday	2026-12-24	The day before Christmas, traditionally observed through family gatherings and preparations.	2026-10-13 20:13:05	2026-10-13 20:13:05	non_working
15	Last Day of the Year	holiday	2026-12-31	Marks the final day of the calendar year and preparations for New Year's Day.	2026-10-13 20:14:01	2026-10-13 20:14:01	non_working
16	SAMPLE LANG NON WORKING SEPT 26	holiday	2026-09-26	\N	2026-10-16 11:00:44	2026-10-16 11:00:44	non_working
\.


--
-- Data for Name: admin_audit_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.admin_audit_logs (id, user_id, action, module, description, status, metadata, created_at, updated_at) FROM stdin;
1005	41	DELETE	Employees	Deleted employee Allainer Reyes (2408130).	Success	{"employee_id":"2408130","email":"malaluangerard@gmail.com","ip":"136.158.79.70"}	2026-10-13 21:35:24	2026-10-13 21:35:24
1064	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"2001:fd8:2697:8c30:c7fe:47c:c88b:abd6"}	2026-10-14 12:47:13	2026-10-14 12:47:13
1127	41	CREATE	Leave Management	Leave file processed — 4 new, 4 updated, 288 skipped, 26 attendance day(s) auto-fulfilled.	Success	{"original_filename":"June-October 2026.xlsx","imported":4,"updated":4,"skipped":288,"ip":"127.0.0.1"}	2026-10-15 23:27:40	2026-10-15 23:27:40
5	\N	LOGIN	Authentication	Failed login attempt for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"127.0.0.1"}	2026-10-12 20:54:16	2026-10-12 20:54:16
6	\N	LOGIN	Authentication	Failed login attempt for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"127.0.0.1"}	2026-10-12 20:54:25	2026-10-12 20:54:25
7	\N	LOGIN	Authentication	Failed login attempt for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"127.0.0.1"}	2026-10-12 20:55:16	2026-10-12 20:55:16
8	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"127.0.0.1"}	2026-10-12 20:57:48	2026-10-12 20:57:48
9	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"127.0.0.1"}	2026-10-12 21:00:13	2026-10-12 21:00:13
10	\N	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"127.0.0.1"}	2026-10-12 21:00:25	2026-10-12 21:00:25
11	\N	LOGIN	Authentication	Failed login attempt for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"136.158.79.70"}	2026-10-12 21:01:25	2026-10-12 21:01:25
12	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"127.0.0.1"}	2026-10-12 21:05:08	2026-10-12 21:05:08
13	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"127.0.0.1"}	2026-10-12 21:05:12	2026-10-12 21:05:12
14	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"127.0.0.1"}	2026-10-12 21:05:19	2026-10-12 21:05:19
15	40	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-10-12 21:05:25	2026-10-12 21:05:25
16	40	LOGOUT	Authentication	Logged out test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"127.0.0.1"}	2026-10-12 21:05:57	2026-10-12 21:05:57
17	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"127.0.0.1"}	2026-10-12 21:06:11	2026-10-12 21:06:11
18	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-10-12 21:06:16	2026-10-12 21:06:16
19	41	CREATE	Role Management	Created HR Timekeeper account for nulptimekeeping@gmail.com.	Success	{"user_id":42,"email":"nulptimekeeping@gmail.com","email_sent":true,"ip":"127.0.0.1"}	2026-10-12 21:07:25	2026-10-12 21:07:25
20	41	LOGOUT	Authentication	Logged out test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"127.0.0.1"}	2026-10-12 21:08:41	2026-10-12 21:08:41
21	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"136.158.79.70"}	2026-10-12 21:09:10	2026-10-12 21:09:10
22	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.70"}	2026-10-12 21:09:22	2026-10-12 21:09:22
23	42	RESET	Authentication	Password reset link requested for nulptimekeeping@gmail.com.	Success	{"email":"nulptimekeeping@gmail.com","ip":"127.0.0.1"}	2026-10-12 21:10:15	2026-10-12 21:10:15
24	42	RESET	Authentication	Password reset completed for nulptimekeeping@gmail.com.	Success	{"email":"nulptimekeeping@gmail.com","ip":"127.0.0.1"}	2026-10-12 21:10:42	2026-10-12 21:10:42
25	42	LOGIN	Authentication	Logged in as nulptimekeeping@gmail.com.	Success	{"email":"nulptimekeeping@gmail.com","ip":"127.0.0.1"}	2026-10-12 21:10:51	2026-10-12 21:10:51
26	42	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-10-12 21:10:57	2026-10-12 21:10:57
27	\N	RESET	Authentication	Password reset link request failed for zaproxy@example.com.	Failed	{"email":"zaproxy@example.com","ip":"49.144.35.159"}	2026-10-12 21:18:47	2026-10-12 21:18:47
28	\N	LOGIN	Authentication	Failed login attempt for zaproxy@example.com.	Failed	{"email":"zaproxy@example.com","ip":"49.144.35.159"}	2026-10-12 21:18:47	2026-10-12 21:18:47
29	42	LOGOUT	Authentication	Logged out nulptimekeeping@gmail.com.	Success	{"email":"nulptimekeeping@gmail.com","ip":"127.0.0.1"}	2026-10-12 21:20:32	2026-10-12 21:20:32
1285	41	CREATE	Employees	Created employee Jojit Aguirre (26-08036).	Success	{"employee_id":"26-08036","email":"jojit@gmail.com","email_sent":true,"ip":"58.97.164.243"}	2026-11-23 11:56:30	2026-11-23 11:56:30
32	42	LOGIN	Authentication	Logged in as nulptimekeeping@gmail.com.	Success	{"email":"nulptimekeeping@gmail.com","ip":"127.0.0.1"}	2026-10-12 21:22:14	2026-10-12 21:22:14
33	42	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-10-12 21:22:20	2026-10-12 21:22:20
1286	41	CREATE	DTR	Biometric PDF processed — 17 attendance row(s) imported, 642 skipped (unmatched employees).	Success	{"original_filename":"sahs nov 1-15 1 (2).pdf","imported":17,"skipped":642,"format":"NU Lipa Timesheet Report","pages":60,"rows_extracted":659,"extraction_seconds":1.13,"ip":"58.97.164.243"}	2026-11-23 11:57:05	2026-11-23 11:57:05
38	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"127.0.0.1"}	2026-10-12 21:34:48	2026-10-12 21:34:48
39	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-10-12 21:34:54	2026-10-12 21:34:54
40	41	CREATE	Academic Calendar	Added calendar date: Sample Holiday (2026-10-06).	Success	{"entry_id":8,"event_date":"2026-10-06","ip":"127.0.0.1"}	2026-10-12 21:35:59	2026-10-12 21:35:59
41	41	UPDATE	Schedules	Updated schedule for Jei Pastrana.	Success	{"submission_id":1,"employee_id":"238041","ip":"127.0.0.1"}	2026-10-12 21:38:28	2026-10-12 21:38:28
82	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:13:24	2026-10-12 22:13:24
84	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:13:32	2026-10-12 22:13:32
86	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:13:41	2026-10-12 22:13:41
88	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:13:48	2026-10-12 22:13:48
1006	41	UPDATE	Employees	Updated employee Jei Pastrana (238041).	Success	{"employee_id":"238041","fields":["employee_id","first_name","last_name","email","department_id","position","employment_type","employment_status","ranking","hire_date"],"ip":"136.158.79.70"}	2026-10-13 21:50:31	2026-10-13 21:50:31
43	41	DELETE	Leave Management	Cleared 1 leave file cache entry.	Success	{"deleted_upload_entries":1,"leave_records_affected":false,"ip":"127.0.0.1"}	2026-10-12 21:40:42	2026-10-12 21:40:42
44	41	DELETE	DTR	Cleared 2 DTR upload cache entries.	Success	{"deleted_upload_entries":2,"attendance_records_affected":false,"ip":"127.0.0.1"}	2026-10-12 21:41:03	2026-10-12 21:41:03
50	42	LOGOUT	Authentication	Logged out nulptimekeeping@gmail.com.	Success	{"email":"nulptimekeeping@gmail.com","ip":"127.0.0.1"}	2026-10-12 21:55:08	2026-10-12 21:55:08
1066	\N	LOGIN	Authentication	Failed login attempt for malaluangerard@gmail.com.	Failed	{"email":"malaluangerard@gmail.com","ip":"131.226.106.15"}	2026-10-14 14:18:05	2026-10-14 14:18:05
1067	\N	LOGIN	Authentication	Failed login attempt for malaluangerard@gmail.com.	Failed	{"email":"malaluangerard@gmail.com","ip":"131.226.106.15"}	2026-10-14 14:18:53	2026-10-14 14:18:53
53	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:09:54	2026-10-12 22:09:54
54	40	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"103.60.171.134"}	2026-10-12 22:10:02	2026-10-12 22:10:02
55	\N	RESET	Authentication	Password reset link request failed for johannesclaus30@gmail.com.	Failed	{"email":"johannesclaus30@gmail.com","ip":"27.49.138.147"}	2026-10-12 22:10:21	2026-10-12 22:10:21
56	40	LOGOUT	Authentication	Logged out test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:11:54	2026-10-12 22:11:54
1065	\N	LOGOUT	Authentication	Logged out mejeipastrana@gmail.com.	Success	{"email":"mejeipastrana@gmail.com","ip":"131.226.106.15"}	2026-10-14 14:17:20	2026-10-14 14:17:20
58	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:11:59	2026-10-12 22:11:59
1128	41	CREATE	Leave Management	Leave file processed — 26 new, 67 updated, 5063 skipped, 32 attendance day(s) auto-fulfilled, 3 WFH notification(s) sent.	Success	{"original_filename":"LPA-23-8111-1791876860-LeaveApplications (1).xlsx","imported":26,"updated":67,"skipped":5063,"ip":"127.0.0.1"}	2026-10-15 23:35:00	2026-10-15 23:35:00
60	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:12:07	2026-10-12 22:12:07
61	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:12:11	2026-10-12 22:12:11
63	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:12:16	2026-10-12 22:12:16
1227	40	CREATE	DTR	Biometric PDF processed — 66 attendance row(s) imported, 1187 skipped (unmatched employees).	Success	{"original_filename":"ASP Sep 1-30.pdf","imported":66,"skipped":1187,"format":"Civil Service Form 48 (Daily Time Record)","pages":77,"rows_extracted":1253,"extraction_seconds":0.38,"ip":"127.0.0.1"}	2026-11-07 01:36:37	2026-11-07 01:36:37
65	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:12:24	2026-10-12 22:12:24
66	40	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"103.60.171.134"}	2026-10-12 22:12:29	2026-10-12 22:12:29
1180	\N	CREATE	Leave Management	Leave file processed — 0 new, 175 updated, 5062 skipped, 3 WFH notification(s) sent.	Success	{"original_filename":"LPA-23-8111-1791876860-LeaveApplications (1).xlsx","imported":0,"updated":175,"skipped":5062,"verification":{"records_checked":175,"records_found":175,"fields_checked":875,"fields_correct":875,"fully_correct":175,"not_imported":5062,"superseded":0,"mismatch_count":0,"field_accuracy":100,"record_accuracy":100},"ip":"127.0.0.1"}	2026-10-16 11:10:58	2026-10-16 11:10:58
68	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:12:32	2026-10-12 22:12:32
1287	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"223.25.38.218"}	2026-11-23 14:41:59	2026-11-23 14:41:59
70	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:12:40	2026-10-12 22:12:40
72	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:12:48	2026-10-12 22:12:48
1353	41	CREATE	Schedules	Added and approved schedule for Jojit Aguirre.	Success	{"submission_id":32,"employee_id":"26-08036","leave_term_started":true,"ip":"223.25.38.218"}	2026-11-24 11:45:03	2026-11-24 11:45:03
74	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:12:55	2026-10-12 22:12:55
1391	41	CREATE	Employees	Created employee Michael Joseph Aramil (23-8035).	Success	{"employee_id":"23-8035","email":"aramil67@gmail.com","credentials_email_sent":true,"ip":"58.97.164.243"}	2026-11-24 15:23:48	2026-11-24 15:23:48
76	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:13:01	2026-10-12 22:13:01
1436	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"216.247.87.131"}	2026-11-25 16:46:17	2026-11-25 16:46:17
78	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:13:08	2026-10-12 22:13:08
80	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:13:17	2026-10-12 22:13:17
45	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"136.158.79.70"}	2026-10-12 21:50:40	2026-10-12 21:50:40
46	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.70"}	2026-10-12 21:50:50	2026-10-12 21:50:50
91	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:14:01	2026-10-12 22:14:01
93	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:14:07	2026-10-12 22:14:07
89	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:13:52	2026-10-12 22:13:52
1007	41	CREATE	Employees	Created employee Allainer Reyes (2408130).	Success	{"employee_id":"2408130","email":"malaluangerard@gmail.com","credentials_email_sent":true,"ip":"136.158.79.70"}	2026-10-13 21:52:45	2026-10-13 21:52:45
1068	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"216.247.80.173"}	2026-10-14 14:20:03	2026-10-14 14:20:03
1069	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"216.247.80.173"}	2026-10-14 14:20:14	2026-10-14 14:20:14
1129	42	LOGIN	Authentication	Logged in as nulptimekeeping@gmail.com.	Success	{"email":"nulptimekeeping@gmail.com","ip":"136.158.79.222"}	2026-10-15 23:39:27	2026-10-15 23:39:27
1130	42	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.222"}	2026-10-15 23:39:36	2026-10-15 23:39:36
1131	42	LOGOUT	Authentication	Logged out nulptimekeeping@gmail.com.	Success	{"email":"nulptimekeeping@gmail.com","ip":"136.158.79.222"}	2026-10-15 23:39:56	2026-10-15 23:39:56
1132	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"136.158.79.222"}	2026-10-15 23:40:14	2026-10-15 23:40:14
1133	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.222"}	2026-10-15 23:40:25	2026-10-15 23:40:25
1134	41	DELETE	Employees	Deleted employee Jei Pastrana (238041).	Success	{"employee_id":"238041","email":"malaluangerard@gmail.com","ip":"136.158.79.222"}	2026-10-15 23:40:54	2026-10-15 23:40:54
1135	41	DELETE	Employees	Deleted employee Jerimaiah Padua (238111).	Success	{"employee_id":"238111","email":"pritongtalong808@gmail.com","ip":"136.158.79.222"}	2026-10-15 23:41:09	2026-10-15 23:41:09
1136	41	DELETE	Employees	Deleted employee Allainer Reyes (2408130).	Success	{"employee_id":"2408130","email":"donoharmbygrd@gmail.com","ip":"136.158.79.222"}	2026-10-15 23:41:23	2026-10-15 23:41:23
1181	\N	DELETE	Schedules	Cleared approved schedule for Allainer Reyes. Started a new leave term (3 VL / 3 SL / 3 EL). Completed after the 11:11 clear failed on a missing database column.	Success	{"employee_id":"2408130","submission_id":12,"leave_term_reset":true,"ip":"127.0.0.1"}	2026-10-16 11:12:54	2026-10-16 11:12:54
1228	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"127.0.0.1"}	2026-11-16 15:36:13	2026-11-16 15:36:13
1229	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-11-16 15:36:21	2026-11-16 15:36:21
1288	41	CREATE	Employees	Created employee CAROL ALFARO (238056).	Success	{"employee_id":"238056","email":"carol@gmail.com","email_sent":true,"ip":"58.97.160.46"}	2026-11-23 14:57:12	2026-11-23 14:57:12
1318	41	CREATE	Employees	Created employee Lyndon Catapang (238038).	Success	{"employee_id":"238038","email":"catapang@gmail.com","email_sent":true,"ip":"58.97.160.46"}	2026-11-24 09:56:12	2026-11-24 09:56:12
1354	41	CREATE	Schedules	Added and approved schedule for Joseph Benedic Bandelaria,.	Success	{"submission_id":33,"employee_id":"2508050","leave_term_started":false,"ip":"223.25.38.218"}	2026-11-24 11:53:31	2026-11-24 11:53:31
1392	41	CREATE	Employees	Created employee Irene Balmes (23-8045).	Success	{"employee_id":"23-8045","email":"balmes@gmail.com","credentials_email_sent":true,"ip":"58.97.164.243"}	2026-11-24 15:27:00	2026-11-24 15:27:00
1393	41	CREATE	Employees	Created employee Noli Castro (23-8068).	Success	{"employee_id":"23-8068","email":"noli123@gmail.com","credentials_email_sent":true,"ip":"223.25.38.218"}	2026-11-24 15:28:26	2026-11-24 15:28:26
1437	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"223.25.38.218"}	2026-11-26 09:27:55	2026-11-26 09:27:55
90	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:13:55	2026-10-12 22:13:55
951	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"216.247.87.207"}	2026-10-13 15:44:30	2026-10-13 15:44:30
1008	41	DELETE	Employees	Deleted employee Jerimaiah Padua (23-8111).	Success	{"employee_id":"23-8111","email":"JEREMIAHPADUA16@GMAIL.COM","ip":"136.158.79.70"}	2026-10-13 21:57:36	2026-10-13 21:57:36
1070	\N	LOGIN	Authentication	Failed login attempt for malaluangerard@gmail.com.	Failed	{"email":"malaluangerard@gmail.com","ip":"223.25.38.218"}	2026-10-14 14:24:04	2026-10-14 14:24:04
1071	\N	LOGIN	Authentication	Failed login attempt for malaluangerard@gmail.com.	Failed	{"email":"malaluangerard@gmail.com","ip":"223.25.38.218"}	2026-10-14 14:24:11	2026-10-14 14:24:11
1137	41	DELETE	Employees	Deleted employee Reymark Natividad (2508064).	Success	{"employee_id":"2508064","email":"angelus.malaluan@gmail.com","ip":"136.158.79.222"}	2026-10-15 23:41:36	2026-10-15 23:41:36
1139	41	CREATE	Employees	Bulk upload employee_import_sample.xlsx: created 4 of 4 login account(s), emailed credentials to 4.	Success	{"accounts_created":4,"emails_sent":4,"already_had_login":0,"account_failures":[],"ip":"136.158.79.222"}	2026-10-15 23:42:16	2026-10-15 23:42:16
1230	41	LOGOUT	Authentication	Logged out test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"127.0.0.1"}	2026-11-16 15:43:24	2026-11-16 15:43:24
1182	\N	APPROVE	Schedules	Approved schedule for Allainer Reyes.	Success	{"submission_id":12,"employee_id":"2408130","ip":"127.0.0.1"}	2026-10-16 11:14:52	2026-10-16 11:14:52
1183	\N	CREATE	DTR	Biometric PDF processed — 29 attendance row(s) imported, 766 skipped (unmatched employees).	Success	{"original_filename":"sace sep 1-30 1.pdf","imported":29,"skipped":766,"format":"NU Lipa Timesheet Report","pages":34,"rows_extracted":795,"extraction_seconds":0.18,"ip":"127.0.0.1"}	2026-10-16 11:15:23	2026-10-16 11:15:23
1289	41	CREATE	Schedules	Added and approved schedule for CAROL ALFARO.	Success	{"submission_id":19,"employee_id":"238056","leave_term_started":false,"ip":"58.97.160.46"}	2026-11-23 15:00:56	2026-11-23 15:00:56
1355	41	CREATE	Schedules	Added and approved schedule for Marjeric Buenafe.	Success	{"submission_id":34,"employee_id":"22-8034","leave_term_started":false,"ip":"223.25.38.218"}	2026-11-24 11:55:56	2026-11-24 11:55:56
1394	41	CREATE	Employees	Created employee Jayson Malabanan (2408053).	Success	{"employee_id":"2408053","email":"Malabanan@gmail.com","email_sent":true,"ip":"58.97.164.243"}	2026-11-24 15:29:50	2026-11-24 15:29:50
1395	41	CREATE	Employees	Created employee Erwin De Castro (23-8130).	Success	{"employee_id":"23-8130","email":"jpk@gmail.com","credentials_email_sent":true,"ip":"58.97.164.243"}	2026-11-24 15:30:00	2026-11-24 15:30:00
1396	41	CREATE	Employees	Created employee Nathaniel Nino Magpantay (24-08067).	Success	{"employee_id":"24-08067","email":"nmp123@gmaiol.com","credentials_email_sent":true,"ip":"58.97.164.243"}	2026-11-24 15:31:19	2026-11-24 15:31:19
113	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:17:42	2026-10-12 22:17:42
1438	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"58.97.164.243"}	2026-11-26 09:28:42	2026-11-26 09:28:42
115	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:17:48	2026-10-12 22:17:48
118	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:17:55	2026-10-12 22:17:55
120	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:18:02	2026-10-12 22:18:02
122	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:18:08	2026-10-12 22:18:08
124	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:18:12	2026-10-12 22:18:12
126	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:18:17	2026-10-12 22:18:17
128	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:18:22	2026-10-12 22:18:22
130	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:18:27	2026-10-12 22:18:27
132	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:18:33	2026-10-12 22:18:33
144	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:19:39	2026-10-12 22:19:39
146	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:19:45	2026-10-12 22:19:45
134	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:18:39	2026-10-12 22:18:39
135	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:18:45	2026-10-12 22:18:45
136	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:18:51	2026-10-12 22:18:51
147	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:19:49	2026-10-12 22:19:49
148	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:19:54	2026-10-12 22:19:54
1072	\N	RESET	Authentication	Password reset link requested for malaluangerard@gmail.com.	Success	{"email":"malaluangerard@gmail.com","ip":"223.25.38.218"}	2026-10-14 14:24:36	2026-10-14 14:24:36
1075	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"2001:fd8:2697:8c30:ee6a:cd0e:f8f:ce99"}	2026-10-14 14:24:54	2026-10-14 14:24:54
1076	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"2001:fd8:2697:8c30:ee6a:cd0e:f8f:ce99"}	2026-10-14 14:24:57	2026-10-14 14:24:57
1077	\N	LOGIN	Authentication	Failed login attempt for malaluangerard@gmail.com.	Failed	{"email":"malaluangerard@gmail.com","ip":"223.25.38.218"}	2026-10-14 14:25:32	2026-10-14 14:25:32
1078	\N	LOGIN	Authentication	Failed login attempt for malaluangerard@gmail.com.	Failed	{"email":"malaluangerard@gmail.com","ip":"223.25.38.218"}	2026-10-14 14:25:47	2026-10-14 14:25:47
1009	\N	LOGIN	Authentication	Logged in as mejeipastrana@gmail.com.	Success	{"email":"mejeipastrana@gmail.com","ip":"1.37.89.26"}	2026-10-13 22:00:28	2026-10-13 22:00:28
1010	\N	LOGIN	Authentication	Logged in as mejeipastrana@gmail.com.	Success	{"email":"mejeipastrana@gmail.com","ip":"110.54.189.27"}	2026-10-13 22:00:40	2026-10-13 22:00:40
1140	41	UPDATE	Role Management	Updated pritongtalong808@gmail.com role from Employee to HR.	Success	{"user_id":68,"email":"pritongtalong808@gmail.com","from":"Employee","to":"HR","ip":"136.158.79.222"}	2026-10-15 23:44:38	2026-10-15 23:44:38
1231	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"127.0.0.1"}	2026-11-17 07:56:16	2026-11-17 07:56:16
1232	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"127.0.0.1"}	2026-11-17 07:56:22	2026-11-17 07:56:22
1233	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-11-17 07:56:29	2026-11-17 07:56:29
1141	\N	LOGIN	Authentication	Failed login attempt for pritongtalong808@gmail.com.	Failed	{"email":"pritongtalong808@gmail.com","ip":"136.158.79.222"}	2026-10-15 23:45:24	2026-10-15 23:45:24
1142	\N	LOGIN	Authentication	Logged in as pritongtalong808@gmail.com.	Success	{"email":"pritongtalong808@gmail.com","ip":"136.158.79.222"}	2026-10-15 23:45:48	2026-10-15 23:45:48
1143	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.222"}	2026-10-15 23:45:57	2026-10-15 23:45:57
1184	\N	CREATE	Leave Management	Leave file processed — 0 new, 175 updated, 5062 skipped, 3 WFH notification(s) sent.	Success	{"original_filename":"LPA-23-8111-1791876860-LeaveApplications (1).xlsx","imported":0,"updated":175,"skipped":5062,"verification":{"records_checked":175,"records_found":175,"fields_checked":875,"fields_correct":875,"fully_correct":175,"not_imported":5062,"superseded":0,"mismatch_count":0,"field_accuracy":100,"record_accuracy":100},"ip":"127.0.0.1"}	2026-10-16 11:17:27	2026-10-16 11:17:27
1290	41	CREATE	Employees	Created employee ALLIC CLARISA (238070).	Success	{"employee_id":"238070","email":"allic@gmail.com","email_sent":true,"ip":"58.97.164.243"}	2026-11-23 15:08:24	2026-11-23 15:08:24
1291	41	DELETE	Schedules	Cleared approved schedule for CAROL ALFARO.	Success	{"submission_id":19,"employee_id":"238056","ip":"58.97.164.243"}	2026-11-23 15:09:51	2026-11-23 15:09:51
1321	41	CREATE	Employees	Created employee Merry Jaine Liwanag (238040).	Success	{"employee_id":"238040","email":"Liwanag@gmail.com","email_sent":true,"ip":"58.97.160.46"}	2026-11-24 10:12:33	2026-11-24 10:12:33
1356	41	CREATE	Schedules	Added and approved schedule for Cherry Lyn Carpio.	Success	{"submission_id":35,"employee_id":"238029","leave_term_started":false,"ip":"58.97.160.46"}	2026-11-24 11:58:54	2026-11-24 11:58:54
1357	41	CREATE	Schedules	Added and approved schedule for Jeroe Marvi Casupanan.	Success	{"submission_id":36,"employee_id":"23-8005","leave_term_started":false,"ip":"58.97.160.46"}	2026-11-24 11:59:52	2026-11-24 11:59:52
1397	41	CREATE	Employees	Created employee John Carlo Torres (23-8008).	Success	{"employee_id":"23-8008","email":"carlo098@gmail.com","credentials_email_sent":true,"ip":"58.97.160.46"}	2026-11-24 15:33:31	2026-11-24 15:33:31
1439	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"58.97.164.243"}	2026-11-26 09:28:49	2026-11-26 09:28:49
1011	\N	LOGIN	Authentication	Logged in as jeremiahpadua16@gmail.com.	Success	{"email":"jeremiahpadua16@gmail.com","ip":"136.158.79.70"}	2026-10-13 22:00:42	2026-10-13 22:00:42
1013	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.70"}	2026-10-13 22:00:55	2026-10-13 22:00:55
1073	\N	LOGIN	Authentication	Logged in as malaluangerard@gmail.com.	Success	{"email":"malaluangerard@gmail.com","ip":"2001:fd8:2697:8c30:ee6a:cd0e:f8f:ce99"}	2026-10-14 14:24:38	2026-10-14 14:24:38
149	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:20:45	2026-10-12 22:20:45
1074	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"2001:fd8:2697:8c30:ee6a:cd0e:f8f:ce99"}	2026-10-14 14:24:53	2026-10-14 14:24:53
151	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:20:50	2026-10-12 22:20:50
1012	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"110.54.189.27"}	2026-10-13 22:00:53	2026-10-13 22:00:53
153	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:20:56	2026-10-12 22:20:56
155	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:21:01	2026-10-12 22:21:01
157	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:21:07	2026-10-12 22:21:07
1144	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"136.158.79.222"}	2026-10-15 23:47:01	2026-10-15 23:47:01
159	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:21:11	2026-10-12 22:21:11
1145	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.222"}	2026-10-15 23:47:10	2026-10-15 23:47:10
161	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:21:16	2026-10-12 22:21:16
1185	41	DELETE	Schedules	Cleared schedule for Allainer Reyes. Started a new leave term (3 VL / 3 SL / 3 EL).	Success	{"submission_id":12,"employee_id":"2408130","leave_term_reset":true,"ip":"127.0.0.1"}	2026-10-16 11:22:58	2026-10-16 11:22:58
163	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:21:22	2026-10-12 22:21:22
1234	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"115.147.167.99"}	2026-11-17 09:30:53	2026-11-17 09:30:53
165	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:21:27	2026-10-12 22:21:27
1235	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"115.147.167.99"}	2026-11-17 09:31:01	2026-11-17 09:31:01
1236	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"115.147.167.99"}	2026-11-17 09:31:10	2026-11-17 09:31:10
1237	41	LOGOUT	Authentication	Logged out test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"115.147.167.99"}	2026-11-17 09:31:31	2026-11-17 09:31:31
1292	41	CREATE	Schedules	Added and approved schedule for CAROL ALFARO.	Success	{"submission_id":20,"employee_id":"238056","leave_term_started":false,"ip":"58.97.164.243"}	2026-11-23 15:14:47	2026-11-23 15:14:47
1293	41	CREATE	Schedules	Added and approved schedule for ALLIC CLARISA.	Success	{"submission_id":21,"employee_id":"238070","leave_term_started":false,"ip":"58.97.160.46"}	2026-11-23 15:16:45	2026-11-23 15:16:45
1322	41	CREATE	Employees	Created employee Mendoza Jess Virrey (238050).	Success	{"employee_id":"238050","email":"Mendoza@gmail.com","email_sent":true,"ip":"58.97.164.243"}	2026-11-24 10:14:50	2026-11-24 10:14:50
1323	41	CREATE	Employees	Created employee Maria Lourdes Culla Bañaga (238060).	Success	{"employee_id":"238060","email":"Banaga@gmail.com","email_sent":true,"ip":"58.97.164.243"}	2026-11-24 10:16:24	2026-11-24 10:16:24
1358	41	CREATE	Schedules	Added and approved schedule for Ronald Catapang.	Success	{"submission_id":37,"employee_id":"23-8037","leave_term_started":false,"ip":"58.97.164.243"}	2026-11-24 12:02:27	2026-11-24 12:02:27
1398	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"58.97.160.46"}	2026-11-25 10:42:41	2026-11-25 10:42:41
1440	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"58.97.164.243"}	2026-11-26 09:29:07	2026-11-26 09:29:07
176	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:22:44	2026-10-12 22:22:44
178	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:22:52	2026-10-12 22:22:52
180	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:22:59	2026-10-12 22:22:59
182	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:23:07	2026-10-12 22:23:07
183	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:23:08	2026-10-12 22:23:08
1014	\N	LOGOUT	Authentication	Logged out jeremiahpadua16@gmail.com.	Success	{"email":"jeremiahpadua16@gmail.com","ip":"136.158.79.70"}	2026-10-13 22:04:00	2026-10-13 22:04:00
1082	42	LOGIN	Authentication	Logged in as nulptimekeeping@gmail.com.	Success	{"email":"nulptimekeeping@gmail.com","ip":"223.25.38.218"}	2026-10-14 14:28:13	2026-10-14 14:28:13
1083	42	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"223.25.38.218"}	2026-10-14 14:28:27	2026-10-14 14:28:27
1079	\N	LOGIN	Authentication	Failed login attempt for malaluangerard@gmail.com.	Failed	{"email":"malaluangerard@gmail.com","ip":"223.25.38.218"}	2026-10-14 14:26:38	2026-10-14 14:26:38
1080	\N	LOGIN	Authentication	Logged in as malaluangerard@gmail.com.	Success	{"email":"malaluangerard@gmail.com","ip":"223.25.38.218"}	2026-10-14 14:26:54	2026-10-14 14:26:54
1081	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"223.25.38.218"}	2026-10-14 14:27:02	2026-10-14 14:27:02
1015	\N	LOGIN	Authentication	Logged in as mejeipastrana@gmail.com.	Success	{"email":"mejeipastrana@gmail.com","ip":"136.158.79.70"}	2026-10-13 22:04:24	2026-10-13 22:04:24
1016	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.70"}	2026-10-13 22:04:33	2026-10-13 22:04:33
1017	\N	LOGOUT	Authentication	Logged out mejeipastrana@gmail.com.	Success	{"email":"mejeipastrana@gmail.com","ip":"136.158.79.70"}	2026-10-13 22:05:51	2026-10-13 22:05:51
1238	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"115.147.167.99"}	2026-11-17 10:23:27	2026-11-17 10:23:27
1239	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"115.147.167.99"}	2026-11-17 10:23:32	2026-11-17 10:23:32
1146	\N	APPROVE	Schedules	Approved schedule for Jerimaiah Padua.	Success	{"submission_id":10,"employee_id":"238111","ip":"136.158.79.222"}	2026-10-15 23:50:57	2026-10-15 23:50:57
1186	\N	APPROVE	Schedules	Approved schedule for Allainer Reyes.	Success	{"submission_id":13,"employee_id":"2408130","ip":"127.0.0.1"}	2026-10-16 11:25:33	2026-10-16 11:25:33
1187	\N	CREATE	Leave Management	Leave file processed — 1 new, 175 updated, 5061 skipped, 3 WFH notification(s) sent.	Success	{"original_filename":"LPA-23-8111-1791876860-LeaveApplications (1).xlsx","imported":1,"updated":175,"skipped":5061,"verification":{"records_checked":176,"records_found":176,"fields_checked":880,"fields_correct":880,"fully_correct":176,"not_imported":5061,"superseded":0,"mismatch_count":0,"field_accuracy":100,"record_accuracy":100},"ip":"127.0.0.1"}	2026-10-16 11:27:04	2026-10-16 11:27:04
1294	41	CREATE	Employees	Created employee Joseph Benedic Bandelaria, (2508050).	Success	{"employee_id":"2508050","email":"bandelaria@gmail.com","email_sent":true,"ip":"58.97.160.46"}	2026-11-23 15:21:42	2026-11-23 15:21:42
1324	41	CREATE	Employees	Created employee Rose Anne Magsino (238063).	Success	{"employee_id":"238063","email":"Magsino@gmail.com","email_sent":true,"ip":"58.97.164.243"}	2026-11-24 10:17:47	2026-11-24 10:17:47
1359	41	CREATE	Schedules	Added and approved schedule for Irish Dimaculangan.	Success	{"submission_id":38,"employee_id":"238100","leave_term_started":false,"ip":"58.97.164.243"}	2026-11-24 13:39:27	2026-11-24 13:39:27
1399	41	CREATE	Employees	Bulk upload processed 252 row(s): 0 added, 131 already registered, 121 with errors.	Success	{"original_filename":"employee_bulkimport_sample.xlsx","bulk_upload":true,"total_rows":252,"created":0,"existing":131,"failed":121,"verification":{"records_checked":0,"records_found":0,"fields_checked":0,"fields_correct":0,"fully_correct":0,"not_imported":0,"superseded":0,"mismatch_count":0,"field_accuracy":null,"record_accuracy":null},"ip":"58.97.164.243"}	2026-11-25 11:10:49	2026-11-25 11:10:49
1400	41	CREATE	Employees	Bulk upload processed 252 row(s): 0 added, 131 already registered, 121 with errors.	Success	{"original_filename":"employee_bulkimport_sample new.xlsx","bulk_upload":true,"total_rows":252,"created":0,"existing":131,"failed":121,"verification":{"records_checked":0,"records_found":0,"fields_checked":0,"fields_correct":0,"fully_correct":0,"not_imported":0,"superseded":0,"mismatch_count":0,"field_accuracy":null,"record_accuracy":null},"ip":"223.25.38.218"}	2026-11-25 11:12:09	2026-11-25 11:12:09
1441	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"115.147.167.99"}	2026-11-26 09:35:58	2026-11-26 09:35:58
1442	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"115.147.167.99"}	2026-11-26 09:36:03	2026-11-26 09:36:03
1084	42	LOGOUT	Authentication	Logged out nulptimekeeping@gmail.com.	Success	{"email":"nulptimekeeping@gmail.com","ip":"223.25.38.218"}	2026-10-14 14:28:41	2026-10-14 14:28:41
1018	\N	LOGIN	Authentication	Logged in as reymarknatividad9@gmail.com.	Success	{"email":"reymarknatividad9@gmail.com","ip":"136.158.79.70"}	2026-10-13 22:07:43	2026-10-13 22:07:43
188	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:24:48	2026-10-12 22:24:48
1019	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.70"}	2026-10-13 22:07:52	2026-10-13 22:07:52
190	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:24:57	2026-10-12 22:24:57
192	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:25:05	2026-10-12 22:25:05
194	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:25:11	2026-10-12 22:25:11
196	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:25:19	2026-10-12 22:25:19
1240	41	DELETE	Employees	Cleared 4 employee bulk upload history entries.	Success	{"deleted_upload_entries":4,"employee_records_affected":false,"ip":"115.147.167.99"}	2026-11-17 10:26:12	2026-11-17 10:26:12
1147	\N	APPROVE	Schedules	Approved schedule for Allainer Reyes.	Success	{"submission_id":9,"employee_id":"2408130","ip":"136.158.79.222"}	2026-10-15 23:51:10	2026-10-15 23:51:10
1148	\N	CREATE	DTR	Biometric PDF processed — 66 attendance row(s) imported, 1187 skipped (unmatched employees).	Success	{"original_filename":"ASP Sep 1-30.pdf","imported":66,"skipped":1187,"ip":"136.158.79.222"}	2026-10-15 23:52:00	2026-10-15 23:52:00
1149	\N	CREATE	DTR	Biometric PDF processed — 29 attendance row(s) imported, 766 skipped (unmatched employees).	Success	{"original_filename":"sace sep 1-30 1.pdf","imported":29,"skipped":766,"ip":"136.158.79.222"}	2026-10-15 23:52:36	2026-10-15 23:52:36
1188	\N	CREATE	Leave Management	Leave file processed — 0 new, 176 updated, 5061 skipped, 1 attendance day(s) auto-fulfilled, 3 WFH notification(s) sent.	Success	{"original_filename":"LPA-23-8111-1791876860-LeaveApplications (1).xlsx","imported":0,"updated":176,"skipped":5061,"verification":{"records_checked":176,"records_found":176,"fields_checked":880,"fields_correct":880,"fully_correct":176,"not_imported":5061,"superseded":0,"mismatch_count":0,"field_accuracy":100,"record_accuracy":100},"ip":"127.0.0.1"}	2026-10-16 11:33:38	2026-10-16 11:33:38
204	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:26:19	2026-10-12 22:26:19
1295	41	CREATE	Employees	Created employee Albien Ryne Bautista, (2408055).	Success	{"employee_id":"2408055","email":"albien@gmail.com","email_sent":true,"ip":"223.25.38.218"}	2026-11-23 15:30:37	2026-11-23 15:30:37
206	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:26:29	2026-10-12 22:26:29
1325	41	CREATE	Employees	Created employee Charmaine Gellieann Ramos Magsino (238080).	Success	{"employee_id":"238080","email":"Charmaine@gmail.com","email_sent":true,"ip":"58.97.160.46"}	2026-11-24 10:23:57	2026-11-24 10:23:57
1326	41	CREATE	Employees	Created employee Khim Joshua Magtibay (238097).	Success	{"employee_id":"238097","email":"Magtibay@gmail.com","email_sent":true,"ip":"223.25.38.218"}	2026-11-24 10:25:53	2026-11-24 10:25:53
209	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:27:13	2026-10-12 22:27:13
1327	41	CREATE	Employees	Created employee Lorena Manimtim (238081).	Success	{"employee_id":"238081","email":"Manimtim@gmail.com","email_sent":true,"ip":"223.25.38.218"}	2026-11-24 10:27:51	2026-11-24 10:27:51
211	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:27:20	2026-10-12 22:27:20
1360	41	CREATE	Schedules	Added and approved schedule for Rosa Maria Cayabyab.	Success	{"submission_id":39,"employee_id":"22-8036","leave_term_started":false,"ip":"223.25.38.218"}	2026-11-24 13:48:36	2026-11-24 13:48:36
213	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:28:05	2026-10-12 22:28:05
1401	41	CREATE	Employees	Bulk upload processed 19 row(s): 0 added, 14 already registered, 5 with errors.	Success	{"original_filename":"new updated profile.xlsx","bulk_upload":true,"total_rows":19,"created":0,"existing":14,"failed":5,"verification":{"records_checked":0,"records_found":0,"fields_checked":0,"fields_correct":0,"fully_correct":0,"not_imported":0,"superseded":0,"mismatch_count":0,"field_accuracy":null,"record_accuracy":null},"ip":"58.97.160.46"}	2026-11-25 11:14:38	2026-11-25 11:14:38
215	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:28:12	2026-10-12 22:28:12
1443	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"127.0.0.1"}	2026-11-26 09:41:59	2026-11-26 09:41:59
217	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:28:18	2026-10-12 22:28:18
1444	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-11-26 09:42:05	2026-11-26 09:42:05
219	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:28:24	2026-10-12 22:28:24
221	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:28:30	2026-10-12 22:28:30
223	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:28:36	2026-10-12 22:28:36
225	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:28:41	2026-10-12 22:28:41
227	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:28:46	2026-10-12 22:28:46
231	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:28:55	2026-10-12 22:28:55
235	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:29:05	2026-10-12 22:29:05
243	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:29:30	2026-10-12 22:29:30
245	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:29:36	2026-10-12 22:29:36
247	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:29:40	2026-10-12 22:29:40
226	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:28:42	2026-10-12 22:28:42
230	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:28:52	2026-10-12 22:28:52
234	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:29:02	2026-10-12 22:29:02
238	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:29:14	2026-10-12 22:29:14
240	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:29:20	2026-10-12 22:29:20
242	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:29:26	2026-10-12 22:29:26
1020	42	CREATE	DTR	Biometric PDF processed — 29 attendance row(s) imported, 766 skipped (unmatched employees).	Success	{"original_filename":"sace sep 1-30 1.pdf","imported":29,"skipped":766,"ip":"136.158.79.70"}	2026-10-13 22:12:14	2026-10-13 22:12:14
1021	42	CREATE	DTR	Biometric PDF processed — 45 attendance row(s) imported, 1208 skipped (unmatched employees).	Success	{"original_filename":"ASP Sep 1-30.pdf","imported":45,"skipped":1208,"ip":"136.158.79.70"}	2026-10-13 22:12:46	2026-10-13 22:12:46
1022	41	UPDATE	Employees	Updated employee Sharlene Anne Hidalgo (23-8026).	Success	{"employee_id":"23-8026","fields":["employee_id","first_name","last_name","email","department_id","position","employment_type","employment_status","ranking","hire_date"],"ip":"136.158.79.70"}	2026-10-13 22:13:51	2026-10-13 22:13:51
1023	42	CREATE	DTR	Biometric PDF processed — 66 attendance row(s) imported, 1187 skipped (unmatched employees).	Success	{"original_filename":"ASP Sep 1-30.pdf","imported":66,"skipped":1187,"ip":"136.158.79.70"}	2026-10-13 22:14:06	2026-10-13 22:14:06
1085	\N	LOGIN	Authentication	Logged in as jeremiahpadua16@gmail.com.	Success	{"email":"jeremiahpadua16@gmail.com","ip":"2001:fd8:2697:8c30:ee6a:cd0e:f8f:ce99"}	2026-10-14 14:33:29	2026-10-14 14:33:29
1086	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"2001:fd8:2697:8c30:ee6a:cd0e:f8f:ce99"}	2026-10-14 14:33:44	2026-10-14 14:33:44
1087	\N	LOGIN	Authentication	Logged in as jeremiahpadua16@gmail.com.	Success	{"email":"jeremiahpadua16@gmail.com","ip":"2405:8d40:4090:735a:9d3c:e03e:f57f:f915"}	2026-10-14 14:34:14	2026-10-14 14:34:14
1088	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"2405:8d40:4090:735a:9d3c:e03e:f57f:f915"}	2026-10-14 14:34:24	2026-10-14 14:34:24
1189	41	DELETE	Schedules	Cleared schedule for Allainer Reyes.	Success	{"submission_id":13,"employee_id":"2408130","ip":"127.0.0.1"}	2026-10-16 12:15:41	2026-10-16 12:15:41
1242	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"115.147.167.99"}	2026-11-17 14:15:41	2026-11-17 14:15:41
1243	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"115.147.167.99"}	2026-11-17 14:15:48	2026-11-17 14:15:48
1244	40	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"115.147.167.99"}	2026-11-17 14:15:55	2026-11-17 14:15:55
1245	40	LOGOUT	Authentication	Logged out test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"115.147.167.99"}	2026-11-17 14:16:36	2026-11-17 14:16:36
1246	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"115.147.167.99"}	2026-11-17 14:16:48	2026-11-17 14:16:48
1247	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"115.147.167.99"}	2026-11-17 14:16:54	2026-11-17 14:16:54
1150	\N	CREATE	Leave Management	Leave file processed — 11 new, 0 updated, 256 skipped, 17 attendance day(s) auto-fulfilled.	Success	{"original_filename":"Jan-May 2026.xlsx","imported":11,"updated":0,"skipped":256,"ip":"136.158.79.222"}	2026-10-15 23:56:54	2026-10-15 23:56:54
1296	41	CREATE	Schedules	Added and approved schedule for Albien Ryne Bautista,.	Success	{"submission_id":22,"employee_id":"2408055","leave_term_started":false,"ip":"223.25.38.218"}	2026-11-23 15:38:06	2026-11-23 15:38:06
1328	41	CREATE	Employees	Created employee Rowena Alcoba (23-8099).	Success	{"employee_id":"23-8099","email":"alcoba@gmail.com","credentials_email_sent":true,"ip":"58.97.160.46"}	2026-11-24 10:31:24	2026-11-24 10:31:24
1361	41	CREATE	Schedules	Added and approved schedule for Jay-ar Dimaculangan.	Success	{"submission_id":40,"employee_id":"22-8020","leave_term_started":false,"ip":"58.97.160.46"}	2026-11-24 13:50:12	2026-11-24 13:50:12
1402	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"58.97.164.243"}	2026-11-25 11:36:08	2026-11-25 11:36:08
1403	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"58.97.164.243"}	2026-11-25 11:36:24	2026-11-25 11:36:24
1404	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"58.97.164.243"}	2026-11-25 11:36:29	2026-11-25 11:36:29
1445	41	CREATE	Schedules	Added and approved schedule for Angelina Acuzar.	Success	{"submission_id":66,"employee_id":"25-08079","leave_term_started":false,"ip":"223.25.38.218"}	2026-11-26 09:50:17	2026-11-26 09:50:17
1446	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"165.225.235.21"}	2026-11-26 09:51:54	2026-11-26 09:51:54
1447	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"165.225.235.21"}	2026-11-26 09:52:04	2026-11-26 09:52:04
1024	41	DELETE	Leave Management	Cleared 0 leave file cache entries.	Success	{"deleted_upload_entries":0,"leave_records_affected":false,"ip":"136.158.79.70"}	2026-10-13 22:21:45	2026-10-13 22:21:45
229	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:28:51	2026-10-12 22:28:51
233	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:29:00	2026-10-12 22:29:00
1089	\N	LOGOUT	Authentication	Logged out jeremiahpadua16@gmail.com.	Success	{"email":"jeremiahpadua16@gmail.com","ip":"2001:fd8:2697:8c30:ee6a:cd0e:f8f:ce99"}	2026-10-14 14:34:25	2026-10-14 14:34:25
237	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:29:13	2026-10-12 22:29:13
239	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:29:19	2026-10-12 22:29:19
241	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:29:25	2026-10-12 22:29:25
249	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:29:45	2026-10-12 22:29:45
1248	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"115.147.167.99"}	2026-11-18 08:58:20	2026-11-18 08:58:20
251	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:29:50	2026-10-12 22:29:50
1249	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"223.25.38.218"}	2026-11-18 08:58:29	2026-11-18 08:58:29
253	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:29:54	2026-10-12 22:29:54
1250	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"115.147.167.99"}	2026-11-18 08:58:34	2026-11-18 08:58:34
255	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:29:59	2026-10-12 22:29:59
1251	41	DELETE	Employees	Deleted employee Josierene Abel (238066).	Success	{"employee_id":"238066","email":"JoseAbelTesting1013@gmail.com","ip":"115.147.167.99"}	2026-11-18 08:58:51	2026-11-18 08:58:51
257	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:30:03	2026-10-12 22:30:03
1151	\N	CREATE	Leave Management	Leave file processed — 13 new, 4 updated, 288 skipped, 26 attendance day(s) auto-fulfilled.	Success	{"original_filename":"June-October 2026.xlsx","imported":13,"updated":4,"skipped":288,"ip":"136.158.79.222"}	2026-10-15 23:57:53	2026-10-15 23:57:53
1190	\N	APPROVE	Schedules	Approved schedule for Allainer Reyes. Leave term starts Jun 8, 2026 (3 VL / 3 SL / 3 EL).	Success	{"submission_id":12,"employee_id":"2408130","leave_term_started":true,"ip":"127.0.0.1"}	2026-10-16 12:16:56	2026-10-16 12:16:56
1191	\N	CREATE	DTR	Biometric PDF processed — 29 attendance row(s) imported, 766 skipped (unmatched employees).	Success	{"original_filename":"sace sep 1-30 1.pdf","imported":29,"skipped":766,"format":"NU Lipa Timesheet Report","pages":34,"rows_extracted":795,"extraction_seconds":0.18,"ip":"127.0.0.1"}	2026-10-16 12:18:06	2026-10-16 12:18:06
1297	41	CREATE	Employees	Created employee Belen Kamil Angela (2508073).	Success	{"employee_id":"2508073","email":"belen@gmail.com","email_sent":true,"ip":"58.97.164.243"}	2026-11-23 15:45:31	2026-11-23 15:45:31
1329	41	CREATE	Employees	Created employee Noelah Mae Borbon (24-08068).	Success	{"employee_id":"24-08068","email":"borbon@gmail.com","credentials_email_sent":true,"ip":"58.97.164.243"}	2026-11-24 10:35:41	2026-11-24 10:35:41
1330	41	CREATE	Employees	Created employee Irish Dimaculangan (238100).	Success	{"employee_id":"238100","email":"Dimaculangan@gmail.com","email_sent":true,"ip":"58.97.160.46"}	2026-11-24 10:36:19	2026-11-24 10:36:19
1362	41	CREATE	Schedules	Added and approved schedule for Josele Mari Figueroa.	Success	{"submission_id":41,"employee_id":"24-08084","leave_term_started":false,"ip":"58.97.164.243"}	2026-11-24 13:51:40	2026-11-24 13:51:40
1363	41	CREATE	Schedules	Added and approved schedule for Larry Fronda Jr..	Success	{"submission_id":42,"employee_id":"23-8059","leave_term_started":false,"ip":"58.97.164.243"}	2026-11-24 13:53:22	2026-11-24 13:53:22
1405	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"58.97.160.46"}	2026-11-25 13:48:48	2026-11-25 13:48:48
1406	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"58.97.160.46"}	2026-11-25 13:49:06	2026-11-25 13:49:06
1448	41	CREATE	Schedules	Added and approved schedule for Ma. Cielo Africa.	Success	{"submission_id":67,"employee_id":"25-08087","leave_term_started":false,"ip":"58.97.164.243"}	2026-11-26 09:52:12	2026-11-26 09:52:12
1449	41	CREATE	Schedules	Added and approved schedule for Allen Paul Alcantara.	Success	{"submission_id":68,"employee_id":"23-8031","leave_term_started":false,"ip":"58.97.160.46"}	2026-11-26 09:54:40	2026-11-26 09:54:40
280	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:32:40	2026-10-12 22:32:40
282	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:32:45	2026-10-12 22:32:45
1025	41	UPDATE	Employees	Updated employee Jerimaiah Padua (23-8111).	Success	{"employee_id":"23-8111","fields":["employee_id","first_name","last_name","email","department_id","position","employment_type","employment_status","ranking","hire_date"],"ip":"136.158.79.70"}	2026-10-13 22:30:05	2026-10-13 22:30:05
284	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:32:51	2026-10-12 22:32:51
286	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:32:56	2026-10-12 22:32:56
288	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:33:02	2026-10-12 22:33:02
1090	\N	LOGIN	Authentication	Logged in as mejeipastrana@gmail.com.	Success	{"email":"mejeipastrana@gmail.com","ip":"223.25.38.218"}	2026-10-14 14:59:47	2026-10-14 14:59:47
290	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:33:06	2026-10-12 22:33:06
1091	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"223.25.38.218"}	2026-10-14 15:00:06	2026-10-14 15:00:06
292	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:33:10	2026-10-12 22:33:10
294	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:33:15	2026-10-12 22:33:15
296	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:33:20	2026-10-12 22:33:20
298	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:33:24	2026-10-12 22:33:24
1152	\N	LOGOUT	Authentication	Logged out donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"136.158.79.222"}	2026-10-16 00:02:39	2026-10-16 00:02:39
1252	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"223.25.38.218"}	2026-11-18 08:58:53	2026-11-18 08:58:53
1253	41	DELETE	Employees	Deleted employee Clarisa Alic (238070).	Success	{"employee_id":"238070","email":"ClarissaTesting1013@gmail.com","ip":"115.147.167.99"}	2026-11-18 08:59:01	2026-11-18 08:59:01
1254	41	DELETE	Employees	Deleted employee Judy Ann Braza (2508033).	Success	{"employee_id":"2508033","email":"JudyAnnTesting1013@gmail.com","ip":"115.147.167.99"}	2026-11-18 08:59:42	2026-11-18 08:59:42
1255	41	DELETE	Employees	Deleted employee Sharlene Anne Hidalgo (23-8026).	Success	{"employee_id":"23-8026","email":"sharleneanne.hidalgo@gmail.com","ip":"115.147.167.99"}	2026-11-18 09:00:13	2026-11-18 09:00:13
1192	\N	CREATE	Leave Management	Leave file processed — 0 new, 176 updated, 5061 skipped, 1 attendance day(s) auto-fulfilled, 3 WFH notification(s) sent.	Success	{"original_filename":"LPA-23-8111-1791876860-LeaveApplications (1).xlsx","imported":0,"updated":176,"skipped":5061,"verification":{"records_checked":176,"records_found":176,"fields_checked":880,"fields_correct":880,"fully_correct":176,"not_imported":5061,"superseded":0,"mismatch_count":0,"field_accuracy":100,"record_accuracy":100},"ip":"127.0.0.1"}	2026-10-16 12:20:17	2026-10-16 12:20:17
1153	\N	LOGIN	Authentication	Logged in as malaluangerard@gmail.com.	Success	{"email":"malaluangerard@gmail.com","ip":"136.158.79.222"}	2026-10-16 00:03:33	2026-10-16 00:03:33
1154	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.222"}	2026-10-16 00:03:42	2026-10-16 00:03:42
1298	41	CREATE	Schedules	Added and approved schedule for Belen Kamil Angela.	Success	{"submission_id":23,"employee_id":"2508073","leave_term_started":false,"ip":"58.97.160.46"}	2026-11-23 15:49:43	2026-11-23 15:49:43
1331	41	CREATE	Employees	Created employee Marjeric Buenafe (22-8034).	Success	{"employee_id":"22-8034","email":"buenafe@gmail.com","credentials_email_sent":true,"ip":"223.25.38.218"}	2026-11-24 10:37:19	2026-11-24 10:37:19
1364	41	CREATE	Schedules	Added and approved schedule for Gene Roy Hernandez.	Success	{"submission_id":43,"employee_id":"23-8028","leave_term_started":false,"ip":"58.97.164.243"}	2026-11-24 13:54:52	2026-11-24 13:54:52
1407	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"58.97.160.46"}	2026-11-25 13:57:44	2026-11-25 13:57:44
315	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:35:14	2026-10-12 22:35:14
1408	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"58.97.160.46"}	2026-11-25 13:57:50	2026-11-25 13:57:50
1450	41	CREATE	Schedules	Added and approved schedule for Alyssa Pearl Alon-Alon.	Success	{"submission_id":69,"employee_id":"26-08028","leave_term_started":false,"ip":"58.97.160.46"}	2026-11-26 09:55:30	2026-11-26 09:55:30
321	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:35:30	2026-10-12 22:35:30
323	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:35:35	2026-10-12 22:35:35
325	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:35:41	2026-10-12 22:35:41
281	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:32:41	2026-10-12 22:32:41
311	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:35:03	2026-10-12 22:35:03
313	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:35:09	2026-10-12 22:35:09
1026	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"127.0.0.1"}	2026-10-13 22:32:58	2026-10-13 22:32:58
317	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:35:20	2026-10-12 22:35:20
319	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:35:25	2026-10-12 22:35:25
1027	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"127.0.0.1"}	2026-10-13 22:33:03	2026-10-13 22:33:03
1028	40	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-10-13 22:33:14	2026-10-13 22:33:14
327	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:35:46	2026-10-12 22:35:46
1092	41	LOGOUT	Authentication	Logged out test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"223.25.38.218"}	2026-10-14 15:02:21	2026-10-14 15:02:21
329	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:35:51	2026-10-12 22:35:51
1093	42	LOGIN	Authentication	Logged in as nulptimekeeping@gmail.com.	Success	{"email":"nulptimekeeping@gmail.com","ip":"223.25.38.218"}	2026-10-14 15:02:31	2026-10-14 15:02:31
1094	42	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"223.25.38.218"}	2026-10-14 15:02:44	2026-10-14 15:02:44
1193	41	DELETE	Schedules	Cleared schedule for Allainer Reyes.	Success	{"submission_id":12,"employee_id":"2408130","ip":"127.0.0.1"}	2026-10-16 12:21:42	2026-10-16 12:21:42
1256	41	DELETE	Employees	Deleted employee Shiela Morfi (24-08051).	Success	{"employee_id":"24-08051","email":"shiela.natanuan.1@gmail.com","ip":"115.147.167.99"}	2026-11-18 09:00:25	2026-11-18 09:00:25
1257	41	DELETE	Employees	Deleted employee Reymark Natividad (2508064).	Success	{"employee_id":"2508064","email":"angelus.malaluan@gmail.com","ip":"115.147.167.99"}	2026-11-18 09:00:34	2026-11-18 09:00:34
1179	\N	CREATE	DTR	Biometric PDF processed — 29 attendance row(s) imported, 766 skipped (unmatched employees).	Success	{"original_filename":"sace sep 1-30 1.pdf","imported":29,"skipped":766,"format":"NU Lipa Timesheet Report","pages":34,"rows_extracted":795,"extraction_seconds":0.18,"ip":"127.0.0.1"}	2026-10-16 11:08:57	2026-10-16 11:08:57
1155	\N	APPROVE	Schedules	Approved schedule for Jei Pastrana.	Success	{"submission_id":11,"employee_id":"238041","ip":"136.158.79.222"}	2026-10-16 00:05:19	2026-10-16 00:05:19
1178	\N	APPROVE	Schedules	Approved schedule for Allainer Reyes.	Success	{"submission_id":12,"employee_id":"2408130","ip":"127.0.0.1"}	2026-10-16 11:08:21	2026-10-16 11:08:21
1258	41	DELETE	Employees	Deleted employee Jerimaiah Padua (238111).	Success	{"employee_id":"238111","email":"pritongtalong808@gmail.com","ip":"115.147.167.99"}	2026-11-18 09:00:46	2026-11-18 09:00:46
340	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:37:07	2026-10-12 22:37:07
1259	41	DELETE	Employees	Deleted employee Jei Pastrana (238041).	Success	{"employee_id":"238041","email":"malaluangerard@gmail.com","ip":"115.147.167.99"}	2026-11-18 09:00:55	2026-11-18 09:00:55
342	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:37:12	2026-10-12 22:37:12
1260	41	DELETE	Employees	Deleted employee Allainer Reyes (2408130).	Success	{"employee_id":"2408130","email":"donoharmbygrd@gmail.com","ip":"115.147.167.99"}	2026-11-18 09:01:06	2026-11-18 09:01:06
344	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:37:18	2026-10-12 22:37:18
1261	41	DELETE	Employees	Deleted employee Jay Sargento (238064).	Success	{"employee_id":"238064","email":"jaysargetesting1013@gmail.com","ip":"115.147.167.99"}	2026-11-18 09:01:18	2026-11-18 09:01:18
346	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:37:25	2026-10-12 22:37:25
1262	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"223.25.38.218"}	2026-11-18 09:01:40	2026-11-18 09:01:40
348	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:37:31	2026-10-12 22:37:31
1263	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"223.25.38.218"}	2026-11-18 09:01:52	2026-11-18 09:01:52
1299	41	CREATE	Employees	Created employee Bobby Buendia (238055).	Success	{"employee_id":"238055","email":"bobby@gmail.com","email_sent":true,"ip":"223.25.38.218"}	2026-11-23 15:56:47	2026-11-23 15:56:47
1332	41	CREATE	Employees	Created employee Jay Sargento (238064).	Success	{"employee_id":"238064","email":"Sargento@gmail.com","email_sent":true,"ip":"58.97.164.243"}	2026-11-24 10:44:28	2026-11-24 10:44:28
1365	41	CREATE	Schedules	Added and approved schedule for Charmaine Gellieann Ramos Magsino.	Success	{"submission_id":44,"employee_id":"238080","leave_term_started":false,"ip":"58.97.164.243"}	2026-11-24 13:55:49	2026-11-24 13:55:49
1366	41	CREATE	Schedules	Added and approved schedule for Judylen Monterey.	Success	{"submission_id":45,"employee_id":"25-8085","leave_term_started":false,"ip":"223.25.38.218"}	2026-11-24 13:56:31	2026-11-24 13:56:31
1409	41	CREATE	Schedules	Added and approved schedule for Carlos Caesar Caday.	Success	{"submission_id":50,"employee_id":"24-08044","leave_term_started":false,"ip":"58.97.160.46"}	2026-11-25 14:01:55	2026-11-25 14:01:55
1451	41	CREATE	Schedules	Added and approved schedule for Hannah Ericka Andal.	Success	{"submission_id":70,"employee_id":"25-08040","leave_term_started":false,"ip":"58.97.164.243"}	2026-11-26 09:57:15	2026-11-26 09:57:15
356	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:38:22	2026-10-12 22:38:22
357	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:38:27	2026-10-12 22:38:27
360	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:38:34	2026-10-12 22:38:34
362	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:38:40	2026-10-12 22:38:40
364	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:38:46	2026-10-12 22:38:46
365	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:38:50	2026-10-12 22:38:50
366	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:38:56	2026-10-12 22:38:56
367	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:39:01	2026-10-12 22:39:01
368	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:39:06	2026-10-12 22:39:06
369	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:39:11	2026-10-12 22:39:11
1029	41	DELETE	Employees	Deleted employee Jerimaiah Padua (23-8111).	Success	{"employee_id":"23-8111","email":"jeremiahpadua16@gmail.com","ip":"136.158.79.70"}	2026-10-13 23:06:22	2026-10-13 23:06:22
1030	41	CREATE	Employees	Created employee Jerimaiah Padua (238111).	Success	{"employee_id":"238111","email":"jeremiahpadua16@gmail.com","credentials_email_sent":true,"ip":"136.158.79.70"}	2026-10-13 23:07:35	2026-10-13 23:07:35
1032	\N	LOGIN	Authentication	Failed login attempt for jeremiahpadua16@gmail.com.	Failed	{"email":"jeremiahpadua16@gmail.com","ip":"136.158.79.70"}	2026-10-13 23:08:14	2026-10-13 23:08:14
1095	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"223.25.38.218"}	2026-10-14 15:17:48	2026-10-14 15:17:48
1096	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"223.25.38.218"}	2026-10-14 15:17:58	2026-10-14 15:17:58
1031	\N	LOGOUT	Authentication	Logged out reymarknatividad9@gmail.com.	Success	{"email":"reymarknatividad9@gmail.com","ip":"136.158.79.70"}	2026-10-13 23:07:56	2026-10-13 23:07:56
1194	41	UPDATE	Schedules	Updated schedule for Allainer Reyes.	Success	{"submission_id":13,"employee_id":"2408130","ip":"127.0.0.1"}	2026-10-16 12:24:22	2026-10-16 12:24:22
1195	41	APPROVE	Schedules	Approved schedule for Allainer Reyes. Leave term starts Oct 15, 2026 (3 VL / 3 SL / 3 EL).	Success	{"submission_id":13,"employee_id":"2408130","leave_term_started":true,"ip":"127.0.0.1"}	2026-10-16 12:24:48	2026-10-16 12:24:48
1156	\N	CREATE	DTR	Biometric PDF processed — 29 attendance row(s) imported, 766 skipped (unmatched employees).	Success	{"original_filename":"sace sep 1-30 1.pdf","imported":29,"skipped":766,"ip":"136.158.79.222"}	2026-10-16 00:07:05	2026-10-16 00:07:05
1196	\N	CREATE	Leave Management	Leave file processed — 0 new, 176 updated, 5061 skipped, 3 WFH notification(s) sent.	Success	{"original_filename":"LPA-23-8111-1791876860-LeaveApplications (1).xlsx","imported":0,"updated":176,"skipped":5061,"verification":{"records_checked":176,"records_found":176,"fields_checked":880,"fields_correct":880,"fully_correct":176,"not_imported":5061,"superseded":0,"mismatch_count":0,"field_accuracy":100,"record_accuracy":100},"ip":"127.0.0.1"}	2026-10-16 12:27:01	2026-10-16 12:27:01
1264	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"223.25.38.218"}	2026-11-18 09:01:52	2026-11-18 09:01:52
1300	41	CREATE	Schedules	Added and approved schedule for Bobby Buendia.	Success	{"submission_id":24,"employee_id":"238055","leave_term_started":false,"ip":"58.97.160.46"}	2026-11-23 16:00:51	2026-11-23 16:00:51
1333	41	CREATE	Employees	Created employee Kenneth Myro Garcia (228083).	Success	{"employee_id":"228083","email":"Garcia@gmail.com","email_sent":true,"ip":"58.97.164.243"}	2026-11-24 10:57:15	2026-11-24 10:57:15
1334	41	CREATE	Employees	Created employee Jeroe Marvi Casupanan (23-8005).	Success	{"employee_id":"23-8005","email":"casupanan@gmail.com","credentials_email_sent":true,"ip":"58.97.160.46"}	2026-11-24 10:58:35	2026-11-24 10:58:35
1367	41	CREATE	Schedules	Added and approved schedule for Redem Quinagoran.	Success	{"submission_id":46,"employee_id":"22-8049","leave_term_started":false,"ip":"58.97.160.46"}	2026-11-24 13:58:34	2026-11-24 13:58:34
1410	41	CREATE	Schedules	Added and approved schedule for Lyndon Catapang.	Success	{"submission_id":51,"employee_id":"238038","leave_term_started":false,"ip":"58.97.164.243"}	2026-11-25 14:05:38	2026-11-25 14:05:38
1452	41	CREATE	Schedules	Added and approved schedule for Michael Joseph Aramil.	Success	{"submission_id":71,"employee_id":"23-8035","leave_term_started":false,"ip":"58.97.160.46"}	2026-11-26 09:59:58	2026-11-26 09:59:58
1453	41	CREATE	Schedules	Added and approved schedule for Rylgem Arcega.	Success	{"submission_id":72,"employee_id":"25-08072","leave_term_started":false,"ip":"58.97.160.46"}	2026-11-26 10:01:07	2026-11-26 10:01:07
1033	41	DELETE	Employees	Deleted employee Jerimaiah Padua (238111).	Success	{"employee_id":"238111","email":"jeremiahpadua16@gmail.com","ip":"136.158.79.70"}	2026-10-13 23:10:06	2026-10-13 23:10:06
371	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:44:59	2026-10-12 22:44:59
373	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:45:04	2026-10-12 22:45:04
1097	42	CREATE	DTR	Biometric PDF processed — 29 attendance row(s) imported, 766 skipped (unmatched employees).	Success	{"original_filename":"sace sep 1-30 1.pdf","imported":29,"skipped":766,"ip":"58.97.160.46"}	2026-10-14 16:01:46	2026-10-14 16:01:46
375	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:45:09	2026-10-12 22:45:09
1034	\N	LOGIN	Authentication	Logged in as jeremiahpadua16@gmail.com.	Success	{"email":"jeremiahpadua16@gmail.com","ip":"136.158.79.70"}	2026-10-13 23:11:38	2026-10-13 23:11:38
377	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:45:16	2026-10-12 22:45:16
1035	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.70"}	2026-10-13 23:11:55	2026-10-13 23:11:55
379	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:45:23	2026-10-12 22:45:23
1157	41	CREATE	DTR	Biometric PDF processed — 29 attendance row(s) imported, 766 skipped (unmatched employees).	Success	{"original_filename":"sace sep 1-30 1.pdf","imported":29,"skipped":766,"format":"NU Lipa Timesheet Report","pages":34,"rows_extracted":795,"extraction_seconds":0.17,"ip":"127.0.0.1"}	2026-10-16 00:25:54	2026-10-16 00:25:54
381	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:45:27	2026-10-12 22:45:27
1197	41	UPDATE	Schedules	Updated schedule for Allainer Reyes.	Success	{"submission_id":13,"employee_id":"2408130","ip":"127.0.0.1"}	2026-10-16 12:28:03	2026-10-16 12:28:03
383	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:45:32	2026-10-12 22:45:32
385	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:45:37	2026-10-12 22:45:37
1198	\N	CREATE	Leave Management	Leave file processed — 0 new, 176 updated, 5061 skipped, 1 attendance day(s) auto-fulfilled, 3 WFH notification(s) sent.	Success	{"original_filename":"LPA-23-8111-1791876860-LeaveApplications (1).xlsx","imported":0,"updated":176,"skipped":5061,"verification":{"records_checked":176,"records_found":176,"fields_checked":880,"fields_correct":880,"fully_correct":176,"not_imported":5061,"superseded":0,"mismatch_count":0,"field_accuracy":100,"record_accuracy":100},"ip":"127.0.0.1"}	2026-10-16 12:29:23	2026-10-16 12:29:23
387	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:45:42	2026-10-12 22:45:42
1265	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"223.25.38.218"}	2026-11-23 10:17:35	2026-11-23 10:17:35
389	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:45:47	2026-10-12 22:45:47
1266	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"223.25.38.218"}	2026-11-23 10:17:48	2026-11-23 10:17:48
1335	41	CREATE	Employees	Created employee Maria Andrea Magaling (238002).	Success	{"employee_id":"238002","email":"Magaling@gmail.com","email_sent":true,"ip":"58.97.164.243"}	2026-11-24 10:59:13	2026-11-24 10:59:13
1368	41	CREATE	Schedules	Added and approved schedule for Aaron Christian Rodriguez.	Success	{"submission_id":47,"employee_id":"24-08108","leave_term_started":true,"ip":"223.25.38.218"}	2026-11-24 14:03:17	2026-11-24 14:03:17
1411	41	CREATE	Employees	Bulk upload processed 10 row(s): 8 added, 0 already registered, 2 with errors.	Success	{"original_filename":"employee_bulkimport_sample (1).xlsx","bulk_upload":true,"total_rows":10,"created":8,"existing":0,"failed":2,"verification":{"records_checked":8,"records_found":8,"fields_checked":72,"fields_correct":72,"fully_correct":8,"not_imported":0,"superseded":0,"mismatch_count":0,"field_accuracy":100,"record_accuracy":100},"ip":"58.97.160.46"}	2026-11-25 14:08:52	2026-11-25 14:08:52
1412	41	CREATE	Employees	Bulk upload employee_bulkimport_sample (1).xlsx: created 8 of 8 login account(s), emailed credentials to 8.	Success	{"accounts_created":8,"emails_sent":8,"already_had_login":0,"account_failures":[],"ip":"58.97.160.46"}	2026-11-25 14:09:09	2026-11-25 14:09:09
1454	41	CREATE	Schedules	Added and approved schedule for Judylen Monterey.	Success	{"submission_id":73,"employee_id":"25-08085","leave_term_started":false,"ip":"58.97.160.46"}	2026-11-26 10:03:46	2026-11-26 10:03:46
1455	41	CREATE	Schedules	Added and approved schedule for Vernis Ventilacion-Monteza.	Success	{"submission_id":74,"employee_id":"24-08102","leave_term_started":false,"ip":"58.97.160.46"}	2026-11-26 10:05:30	2026-11-26 10:05:30
400	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:46:46	2026-10-12 22:46:46
402	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:47:21	2026-10-12 22:47:21
404	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:47:28	2026-10-12 22:47:28
406	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:47:34	2026-10-12 22:47:34
408	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:47:39	2026-10-12 22:47:39
410	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:47:45	2026-10-12 22:47:45
412	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:47:50	2026-10-12 22:47:50
414	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:47:55	2026-10-12 22:47:55
1036	42	CREATE	DTR	Biometric PDF processed — 66 attendance row(s) imported, 1187 skipped (unmatched employees).	Success	{"original_filename":"ASP Sep 1-30.pdf","imported":66,"skipped":1187,"ip":"136.158.79.70"}	2026-10-13 23:14:54	2026-10-13 23:14:54
1098	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"127.0.0.1"}	2026-10-15 20:52:55	2026-10-15 20:52:55
1099	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-10-15 20:53:01	2026-10-15 20:53:01
1158	41	CREATE	Leave Management	Leave file processed — 0 new, 17 updated, 288 skipped.	Success	{"original_filename":"June-October 2026.xlsx","imported":0,"updated":17,"skipped":288,"ip":"127.0.0.1"}	2026-10-16 00:27:28	2026-10-16 00:27:28
426	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:50:19	2026-10-12 22:50:19
1202	\N	DELETE	Schedules	Cleared approved schedule for Jei Pastrana.	Success	{"submission_id":11,"employee_id":"238041","ip":"127.0.0.1"}	2026-10-16 12:34:43	2026-10-16 12:34:43
1200	\N	LOGIN	Authentication	Logged in as malaluangerard@gmail.com.	Success	{"email":"malaluangerard@gmail.com","ip":"127.0.0.1"}	2026-10-16 12:34:16	2026-10-16 12:34:16
1201	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-10-16 12:34:21	2026-10-16 12:34:21
1199	\N	LOGOUT	Authentication	Logged out donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"127.0.0.1"}	2026-10-16 12:33:16	2026-10-16 12:33:16
444	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:51:04	2026-10-12 22:51:04
1267	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"223.25.38.218"}	2026-11-23 10:17:52	2026-11-23 10:17:52
1302	41	CREATE	Employees	Created employee Maria Dolores Evangelista (228021).	Success	{"employee_id":"228021","email":"maria@gmail.com","email_sent":true,"ip":"58.97.164.243"}	2026-11-23 16:36:09	2026-11-23 16:36:09
1303	41	CREATE	Employees	Created employee Krizel Joanne Escala (228033).	Success	{"employee_id":"228033","email":"krizel@gmail.com","email_sent":true,"ip":"223.25.38.218"}	2026-11-23 16:37:48	2026-11-23 16:37:48
1336	41	CREATE	Schedules	Added and approved schedule for Jiselle Umali.	Success	{"submission_id":25,"employee_id":"238030","leave_term_started":false,"ip":"58.97.164.243"}	2026-11-24 11:02:33	2026-11-24 11:02:33
1337	41	CREATE	Employees	Created employee Ronald Catapang (23-8037).	Success	{"employee_id":"23-8037","email":"Catapang@gmail.com","credentials_email_sent":true,"ip":"223.25.38.218"}	2026-11-24 11:03:40	2026-11-24 11:03:40
1369	41	CREATE	Schedules	Added and approved schedule for Krizel Joanne Escala.	Success	{"submission_id":48,"employee_id":"228033","leave_term_started":false,"ip":"58.97.160.46"}	2026-11-24 14:03:48	2026-11-24 14:03:48
1370	41	CREATE	Schedules	Added and approved schedule for Sebulino Honorato.	Success	{"submission_id":49,"employee_id":"24-08017","leave_term_started":false,"ip":"223.25.38.218"}	2026-11-24 14:05:03	2026-11-24 14:05:03
1413	41	CREATE	Employees	Bulk upload processed 2 row(s): 2 added, 0 already registered, 0 with errors.	Success	{"original_filename":"employee_bulkimport_sample (1).xlsx","bulk_upload":true,"total_rows":2,"created":2,"existing":0,"failed":0,"verification":{"records_checked":2,"records_found":2,"fields_checked":18,"fields_correct":18,"fully_correct":2,"not_imported":0,"superseded":0,"mismatch_count":0,"field_accuracy":100,"record_accuracy":100},"ip":"58.97.160.46"}	2026-11-25 14:10:17	2026-11-25 14:10:17
463	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:51:55	2026-10-12 22:51:55
484	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:53:54	2026-10-12 22:53:54
485	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:53:59	2026-10-12 22:53:59
1414	41	CREATE	Employees	Bulk upload employee_bulkimport_sample (1).xlsx: created 2 of 2 login account(s), emailed credentials to 2.	Success	{"accounts_created":2,"emails_sent":2,"already_had_login":0,"account_failures":[],"ip":"58.97.160.46"}	2026-11-25 14:10:24	2026-11-25 14:10:24
1456	41	CREATE	Schedules	Added and approved schedule for Arnolfo Arcibal.	Success	{"submission_id":75,"employee_id":"25-08065","leave_term_started":false,"ip":"223.25.38.218"}	2026-11-26 10:23:47	2026-11-26 10:23:47
411	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:47:48	2026-10-12 22:47:48
417	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:48:02	2026-10-12 22:48:02
418	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:48:07	2026-10-12 22:48:07
419	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:48:11	2026-10-12 22:48:11
420	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:48:17	2026-10-12 22:48:17
416	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:48:00	2026-10-12 22:48:00
428	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:50:24	2026-10-12 22:50:24
430	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:50:30	2026-10-12 22:50:30
432	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:50:36	2026-10-12 22:50:36
434	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:50:42	2026-10-12 22:50:42
436	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:50:46	2026-10-12 22:50:46
438	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:50:50	2026-10-12 22:50:50
440	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:50:55	2026-10-12 22:50:55
442	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:51:00	2026-10-12 22:51:00
1041	41	DELETE	Leave Management	Cleared 3 leave file cache entries.	Success	{"deleted_upload_entries":3,"leave_records_affected":false,"ip":"136.158.79.70"}	2026-10-13 23:30:39	2026-10-13 23:30:39
446	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:51:10	2026-10-12 22:51:10
449	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:51:15	2026-10-12 22:51:15
451	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:51:22	2026-10-12 22:51:22
452	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:51:27	2026-10-12 22:51:27
455	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:51:34	2026-10-12 22:51:34
457	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:51:40	2026-10-12 22:51:40
459	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:51:45	2026-10-12 22:51:45
461	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:51:50	2026-10-12 22:51:50
1037	\N	LOGOUT	Authentication	Logged out jeremiahpadua16@gmail.com.	Success	{"email":"jeremiahpadua16@gmail.com","ip":"136.158.79.70"}	2026-10-13 23:26:29	2026-10-13 23:26:29
1100	\N	LOGIN	Authentication	Logged in as jeremiahpadua16@gmail.com.	Success	{"email":"jeremiahpadua16@gmail.com","ip":"127.0.0.1"}	2026-10-15 21:08:01	2026-10-15 21:08:01
1101	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-10-15 21:08:06	2026-10-15 21:08:06
1159	41	CREATE	Leave Management	Leave file processed — 0 new, 17 updated, 288 skipped.	Success	{"original_filename":"June-October 2026.xlsx","imported":0,"updated":17,"skipped":288,"verification":{"records_checked":17,"records_found":17,"fields_checked":85,"fields_correct":85,"fully_correct":17,"not_imported":288,"superseded":0,"mismatch_count":0,"field_accuracy":100,"record_accuracy":100},"ip":"127.0.0.1"}	2026-10-16 00:40:42	2026-10-16 00:40:42
1203	41	UPDATE	Employees	Updated employee Jei Pastrana (238041).	Success	{"employee_id":"238041","fields":["employee_id","first_name","last_name","email","department_id","position","employment_type","employment_status","ranking","hire_date"],"ip":"127.0.0.1"}	2026-10-16 12:35:22	2026-10-16 12:35:22
1204	41	UPDATE	Employees	Updated employee Jei Pastrana (238041).	Success	{"employee_id":"238041","fields":["employee_id","first_name","last_name","email","department_id","position","employment_type","employment_status","ranking","hire_date"],"ip":"127.0.0.1"}	2026-10-16 12:36:17	2026-10-16 12:36:17
1268	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"115.147.167.99"}	2026-11-23 10:28:02	2026-11-23 10:28:02
1269	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"115.147.167.99"}	2026-11-23 10:28:08	2026-11-23 10:28:08
1304	41	CREATE	Employees	Created employee Janice Fischer (228045).	Success	{"employee_id":"228045","email":"janice@gmail.com","email_sent":true,"ip":"58.97.160.46"}	2026-11-23 16:39:53	2026-11-23 16:39:53
1338	41	CREATE	Schedules	Added and approved schedule for Camille Silva.	Success	{"submission_id":26,"employee_id":"228028","leave_term_started":false,"ip":"58.97.164.243"}	2026-11-24 11:08:10	2026-11-24 11:08:10
1371	41	CREATE	Employees	Created employee Romielyn Morcilla (238019).	Success	{"employee_id":"238019","email":"Morcilla@gmail.com","email_sent":true,"ip":"58.97.164.243"}	2026-11-24 14:07:25	2026-11-24 14:07:25
1372	41	CREATE	DTR	Biometric PDF processed — 118 attendance row(s) imported, 37 skipped (unmatched employees).	Success	{"original_filename":"SABM Nov 1-15 1.pdf","imported":118,"skipped":37,"format":"NU Lipa Timesheet Report","pages":14,"rows_extracted":155,"extraction_seconds":0.17,"ip":"223.25.38.218"}	2026-11-24 14:07:37	2026-11-24 14:07:37
1415	41	CREATE	Schedules	Added and approved schedule for Alestair Dimaculangan.	Success	{"submission_id":52,"employee_id":"26-08048","leave_term_started":false,"ip":"223.25.38.218"}	2026-11-25 14:12:32	2026-11-25 14:12:32
1416	41	CREATE	Employees	Bulk upload processed 23 row(s): 14 added, 4 already registered, 5 with errors.	Success	{"original_filename":"employee_bulkimport_sample (1).xlsx","bulk_upload":true,"total_rows":23,"created":14,"existing":4,"failed":5,"verification":{"records_checked":14,"records_found":14,"fields_checked":126,"fields_correct":126,"fully_correct":14,"not_imported":0,"superseded":0,"mismatch_count":0,"field_accuracy":100,"record_accuracy":100},"ip":"223.25.38.218"}	2026-11-25 14:13:24	2026-11-25 14:13:24
1417	41	CREATE	Employees	Bulk upload employee_bulkimport_sample (1).xlsx: created 14 of 14 login account(s), emailed credentials to 14.	Success	{"accounts_created":14,"emails_sent":14,"already_had_login":0,"account_failures":[],"ip":"223.25.38.218"}	2026-11-25 14:13:48	2026-11-25 14:13:48
1457	41	CREATE	Schedules	Added and approved schedule for Marvin Atanacio.	Success	{"submission_id":76,"employee_id":"24-08090","leave_term_started":false,"ip":"223.25.38.218"}	2026-11-26 10:26:17	2026-11-26 10:26:17
487	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:54:04	2026-10-12 22:54:04
492	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:55:23	2026-10-12 22:55:23
496	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:55:34	2026-10-12 22:55:34
498	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:55:40	2026-10-12 22:55:40
500	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:55:46	2026-10-12 22:55:46
502	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:55:51	2026-10-12 22:55:51
504	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:55:56	2026-10-12 22:55:56
506	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:56:01	2026-10-12 22:56:01
508	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:56:05	2026-10-12 22:56:05
1042	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"127.0.0.1"}	2026-10-13 23:39:18	2026-10-13 23:39:18
510	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:56:10	2026-10-12 22:56:10
1043	40	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-10-13 23:39:23	2026-10-13 23:39:23
512	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:56:14	2026-10-12 22:56:14
1044	40	CREATE	Leave Management	Leave file processed — 0 new, 95 updated, 5142 skipped.	Success	{"original_filename":"LPA-23-8111-1791876860-LeaveApplications (1).xlsx","imported":0,"updated":95,"skipped":5142,"ip":"127.0.0.1"}	2026-10-13 23:40:35	2026-10-13 23:40:35
514	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:56:19	2026-10-12 22:56:19
1102	41	UPDATE	Role Management	Updated jeremiahpadua16@gmail.com role from Employee to HR.	Success	{"user_id":56,"email":"jeremiahpadua16@gmail.com","from":"Employee","to":"HR","ip":"127.0.0.1"}	2026-10-15 21:12:49	2026-10-15 21:12:49
516	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:56:26	2026-10-12 22:56:26
518	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:56:32	2026-10-12 22:56:32
1205	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"136.158.79.70"}	2026-10-19 00:43:10	2026-10-19 00:43:10
483	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:53:53	2026-10-12 22:53:53
486	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:54:00	2026-10-12 22:54:00
493	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:55:25	2026-10-12 22:55:25
495	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:55:31	2026-10-12 22:55:31
497	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:55:36	2026-10-12 22:55:36
499	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:55:42	2026-10-12 22:55:42
501	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:55:47	2026-10-12 22:55:47
503	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:55:51	2026-10-12 22:55:51
505	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:55:56	2026-10-12 22:55:56
507	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:56:01	2026-10-12 22:56:01
1206	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"136.158.79.70"}	2026-10-19 00:43:23	2026-10-19 00:43:23
1207	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"136.158.79.70"}	2026-10-19 00:43:32	2026-10-19 00:43:32
1208	40	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.70"}	2026-10-19 00:43:41	2026-10-19 00:43:41
1161	\N	LOGIN	Authentication	Logged in as pritongtalong808@gmail.com.	Success	{"email":"pritongtalong808@gmail.com","ip":"136.158.79.222"}	2026-10-16 09:57:59	2026-10-16 09:57:59
1162	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.222"}	2026-10-16 09:58:11	2026-10-16 09:58:11
1270	41	CREATE	Employees	Created employee Gerard Angelus Malaluan (238041).	Success	{"employee_id":"238041","email":"malaluangerard@gmail.com","credentials_email_sent":true,"ip":"115.147.167.99"}	2026-11-23 10:32:20	2026-11-23 10:32:20
1305	41	CREATE	Employees	Created employee Nesiel Oros Manalo (228044).	Success	{"employee_id":"228044","email":"nisiel@gmail.com","email_sent":true,"ip":"58.97.164.243"}	2026-11-23 16:44:23	2026-11-23 16:44:23
1339	41	CREATE	Employees	Created employee Rosa Maria Cayabyab (22-8036).	Success	{"employee_id":"22-8036","email":"cayabyab@gmail.com","credentials_email_sent":true,"ip":"58.97.164.243"}	2026-11-24 11:10:02	2026-11-24 11:10:02
494	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:55:28	2026-10-12 22:55:28
1045	42	CREATE	Leave Management	Leave file processed — 0 new, 95 updated, 5142 skipped.	Success	{"original_filename":"LPA-23-8111-1791876860-LeaveApplications (1).xlsx","imported":0,"updated":95,"skipped":5142,"ip":"136.158.79.70"}	2026-10-13 23:47:25	2026-10-13 23:47:25
1103	\N	LOGIN	Authentication	Logged in as mejeipastrana@gmail.com.	Success	{"email":"mejeipastrana@gmail.com","ip":"127.0.0.1"}	2026-10-15 21:17:14	2026-10-15 21:17:14
1104	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-10-15 21:17:20	2026-10-15 21:17:20
1163	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"136.158.79.222"}	2026-10-16 10:16:31	2026-10-16 10:16:31
1164	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.222"}	2026-10-16 10:16:40	2026-10-16 10:16:40
1209	\N	LOGIN	Authentication	Logged in as pritongtalong808@gmail.com.	Success	{"email":"pritongtalong808@gmail.com","ip":"58.97.160.46"}	2026-10-19 12:19:50	2026-10-19 12:19:50
1210	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"223.25.38.218"}	2026-10-19 12:19:58	2026-10-19 12:19:58
1211	\N	CREATE	DTR	Biometric PDF processed — 66 attendance row(s) imported, 1187 skipped (unmatched employees).	Success	{"original_filename":"ASP Sep 1-30.pdf","imported":66,"skipped":1187,"format":"Civil Service Form 48 (Daily Time Record)","pages":77,"rows_extracted":1253,"extraction_seconds":1.76,"ip":"223.25.38.218"}	2026-10-19 12:21:15	2026-10-19 12:21:15
534	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:58:36	2026-10-12 22:58:36
1271	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"127.0.0.1"}	2026-11-23 10:36:59	2026-11-23 10:36:59
536	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:58:42	2026-10-12 22:58:42
1272	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-11-23 10:37:05	2026-11-23 10:37:05
538	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:58:47	2026-10-12 22:58:47
1306	41	CREATE	Employees	Created employee Tiffanny Gail Nova (228009).	Success	{"employee_id":"228009","email":"nova@gmail.com","email_sent":true,"ip":"223.25.38.218"}	2026-11-23 16:48:17	2026-11-23 16:48:17
540	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:58:52	2026-10-12 22:58:52
1340	41	CREATE	Employees	Created employee Jay-ar Dimaculangan (22-8020).	Success	{"employee_id":"22-8020","email":"dimaculangan@gmail.com","credentials_email_sent":true,"ip":"58.97.164.243"}	2026-11-24 11:11:22	2026-11-24 11:11:22
542	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:58:59	2026-10-12 22:58:59
1374	41	CREATE	Employees	Bulk upload employee_bulkimport_sample.xlsx: created 1 of 1 login account(s), emailed credentials to 1.	Success	{"accounts_created":1,"emails_sent":1,"already_had_login":0,"account_failures":[],"ip":"58.97.160.46"}	2026-11-24 14:38:04	2026-11-24 14:38:04
544	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:59:03	2026-10-12 22:59:03
1418	41	CREATE	Schedules	Added and approved schedule for Regina Endaya.	Success	{"submission_id":53,"employee_id":"2408009","leave_term_started":false,"ip":"223.25.38.218"}	2026-11-25 14:14:35	2026-11-25 14:14:35
546	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:59:08	2026-10-12 22:59:08
1419	41	CREATE	Employees	Bulk upload processed 23 row(s): 5 added, 18 already registered, 0 with errors.	Success	{"original_filename":"employee_bulkimport_sample (1).xlsx","bulk_upload":true,"total_rows":23,"created":5,"existing":18,"failed":0,"verification":{"records_checked":5,"records_found":5,"fields_checked":45,"fields_correct":45,"fully_correct":5,"not_imported":0,"superseded":0,"mismatch_count":0,"field_accuracy":100,"record_accuracy":100},"ip":"58.97.164.243"}	2026-11-25 14:15:29	2026-11-25 14:15:29
548	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:59:12	2026-10-12 22:59:12
1420	41	CREATE	Employees	Bulk upload employee_bulkimport_sample (1).xlsx: created 5 of 5 login account(s), emailed credentials to 5.	Success	{"accounts_created":5,"emails_sent":5,"already_had_login":0,"account_failures":[],"ip":"58.97.164.243"}	2026-11-25 14:15:40	2026-11-25 14:15:40
550	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:59:17	2026-10-12 22:59:17
1458	41	CREATE	Schedules	Added and approved schedule for Pola Bianca Donia Balmaceda.	Success	{"submission_id":77,"employee_id":"25-08049","leave_term_started":false,"ip":"223.25.38.218"}	2026-11-26 10:28:26	2026-11-26 10:28:26
552	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:59:22	2026-10-12 22:59:22
554	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:59:27	2026-10-12 22:59:27
556	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:59:32	2026-10-12 22:59:32
1046	41	LOGOUT	Authentication	Logged out test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"136.158.79.70"}	2026-10-14 00:02:21	2026-10-14 00:02:21
1047	42	LOGOUT	Authentication	Logged out nulptimekeeping@gmail.com.	Success	{"email":"nulptimekeeping@gmail.com","ip":"136.158.79.70"}	2026-10-14 00:03:08	2026-10-14 00:03:08
1105	\N	CREATE	DTR	Biometric PDF processed — 29 attendance row(s) imported, 766 skipped (unmatched employees).	Success	{"original_filename":"sace sep 1-30 1.pdf","imported":29,"skipped":766,"ip":"127.0.0.1"}	2026-10-15 21:23:53	2026-10-15 21:23:53
1165	\N	LOGIN	Authentication	Logged in as pritongtalong808@gmail.com.	Success	{"email":"pritongtalong808@gmail.com","ip":"127.0.0.1"}	2026-10-16 10:19:35	2026-10-16 10:19:35
1166	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-10-16 10:19:42	2026-10-16 10:19:42
571	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:02:02	2026-10-12 23:02:02
1273	41	CREATE	Schedules	Added and approved schedule for Gerard Angelus Malaluan.	Success	{"submission_id":14,"employee_id":"238041","leave_term_started":false,"ip":"127.0.0.1"}	2026-11-23 10:49:17	2026-11-23 10:49:17
573	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:02:08	2026-10-12 23:02:08
574	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:02:14	2026-10-12 23:02:14
1274	41	DELETE	Schedules	Cleared schedule for Gerard Angelus Malaluan.	Success	{"submission_id":14,"employee_id":"238041","ip":"127.0.0.1"}	2026-11-23 10:49:40	2026-11-23 10:49:40
1275	41	CREATE	Schedules	Added and approved schedule for Gerard Angelus Malaluan.	Success	{"submission_id":15,"employee_id":"238041","leave_term_started":false,"ip":"127.0.0.1"}	2026-11-23 10:50:58	2026-11-23 10:50:58
577	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:02:21	2026-10-12 23:02:21
1307	41	CREATE	Employees	Created employee Camille Silva (228028).	Success	{"employee_id":"228028","email":"silva@gmail.com","email_sent":true,"ip":"58.97.164.243"}	2026-11-23 17:08:24	2026-11-23 17:08:24
579	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:02:28	2026-10-12 23:02:28
1341	41	CREATE	Employees	Created employee Josele Mari Figueroa (24-08084).	Success	{"employee_id":"24-08084","email":"Josele@gmail.com","credentials_email_sent":true,"ip":"58.97.160.46"}	2026-11-24 11:13:20	2026-11-24 11:13:20
581	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:02:33	2026-10-12 23:02:33
1342	41	CREATE	Employees	Created employee Larry Fronda Jr. (23-8059).	Success	{"employee_id":"23-8059","email":"Fronda@gmail.com","credentials_email_sent":true,"ip":"58.97.164.243"}	2026-11-24 11:14:55	2026-11-24 11:14:55
583	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:02:38	2026-10-12 23:02:38
585	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:02:44	2026-10-12 23:02:44
1376	41	CREATE	Employees	Bulk upload employee_bulkimport_sample.xlsx: created 34 of 34 login account(s), emailed credentials to 34.	Success	{"accounts_created":34,"emails_sent":34,"already_had_login":0,"account_failures":[],"ip":"223.25.38.218"}	2026-11-24 14:43:13	2026-11-24 14:43:13
587	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:02:49	2026-10-12 23:02:49
1421	41	CREATE	Schedules	Added and approved schedule for Jhyn Concordia.	Success	{"submission_id":54,"employee_id":"23-8049","leave_term_started":false,"ip":"58.97.164.243"}	2026-11-25 14:26:18	2026-11-25 14:26:18
589	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:02:54	2026-10-12 23:02:54
1422	41	CREATE	Schedules	Added and approved schedule for Lawrence Zyril Lizardo.	Success	{"submission_id":55,"employee_id":"24-08115","leave_term_started":false,"ip":"58.97.164.243"}	2026-11-25 14:27:26	2026-11-25 14:27:26
591	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:02:59	2026-10-12 23:02:59
592	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:03:07	2026-10-12 23:03:07
594	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:03:13	2026-10-12 23:03:13
596	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:03:19	2026-10-12 23:03:19
598	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:03:25	2026-10-12 23:03:25
600	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:03:31	2026-10-12 23:03:31
623	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:05:51	2026-10-12 23:05:51
604	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:03:45	2026-10-12 23:03:45
605	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:03:50	2026-10-12 23:03:50
606	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:03:55	2026-10-12 23:03:55
607	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:03:59	2026-10-12 23:03:59
608	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:04:04	2026-10-12 23:04:04
609	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:04:09	2026-10-12 23:04:09
610	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:04:15	2026-10-12 23:04:15
611	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:04:21	2026-10-12 23:04:21
612	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:04:26	2026-10-12 23:04:26
613	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:04:32	2026-10-12 23:04:32
614	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:04:37	2026-10-12 23:04:37
615	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:04:42	2026-10-12 23:04:42
616	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:04:47	2026-10-12 23:04:47
617	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:04:52	2026-10-12 23:04:52
618	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:05:14	2026-10-12 23:05:14
620	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:05:21	2026-10-12 23:05:21
622	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:05:44	2026-10-12 23:05:44
625	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:05:59	2026-10-12 23:05:59
1048	42	LOGIN	Authentication	Logged in as nulptimekeeping@gmail.com.	Success	{"email":"nulptimekeeping@gmail.com","ip":"136.158.79.70"}	2026-10-14 09:13:57	2026-10-14 09:13:57
1049	42	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.70"}	2026-10-14 09:15:06	2026-10-14 09:15:06
1051	42	CREATE	Leave Management	Leave file processed — 7 new, 167 updated, 5063 skipped, 90 attendance day(s) auto-fulfilled, 3 WFH notification(s) sent.	Success	{"original_filename":"LPA-23-8111-1791876860-LeaveApplications (1).xlsx","imported":7,"updated":167,"skipped":5063,"ip":"136.158.79.70"}	2026-10-14 09:18:42	2026-10-14 09:18:42
1106	41	UPDATE	Role Management	Updated mejeipastrana@gmail.com role from Employee to Admin.	Success	{"user_id":52,"email":"mejeipastrana@gmail.com","from":"Employee","to":"Admin","ip":"127.0.0.1"}	2026-10-15 21:45:05	2026-10-15 21:45:05
1107	41	UPDATE	Role Management	Updated mejeipastrana@gmail.com role from Admin to Employee.	Success	{"user_id":52,"email":"mejeipastrana@gmail.com","from":"Admin","to":"Employee","ip":"127.0.0.1"}	2026-10-15 21:45:41	2026-10-15 21:45:41
1167	41	DELETE	Employees	Deleted employee Allainer Reyes (2408130).	Success	{"employee_id":"2408130","email":"donoharmbygrd@gmail.com","ip":"136.158.79.222"}	2026-10-16 10:39:05	2026-10-16 10:39:05
1213	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"223.25.38.218"}	2026-10-19 13:52:45	2026-10-19 13:52:45
1214	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"223.25.38.218"}	2026-10-19 13:52:55	2026-10-19 13:52:55
1168	\N	CREATE	Employees	Created employee Allainer Reyes (2408130).	Success	{"employee_id":"2408130","email":"donoharmbygrd@gmail.com","email_sent":true,"ip":"127.0.0.1"}	2026-10-16 10:40:24	2026-10-16 10:40:24
1276	41	DELETE	Schedules	Cleared schedule for Gerard Angelus Malaluan.	Success	{"submission_id":15,"employee_id":"238041","ip":"115.147.167.99"}	2026-11-23 10:56:31	2026-11-23 10:56:31
1308	41	CREATE	DTR	Biometric PDF processed — 98 attendance row(s) imported, 561 skipped (unmatched employees).	Success	{"original_filename":"sahs nov 1-15 1 (2).pdf","imported":98,"skipped":561,"format":"NU Lipa Timesheet Report","pages":60,"rows_extracted":659,"extraction_seconds":0.86,"ip":"58.97.164.243"}	2026-11-23 17:09:50	2026-11-23 17:09:50
1343	41	CREATE	Employees	Created employee Gene Roy Hernandez (23-8028).	Success	{"employee_id":"23-8028","email":"Hernandez@gmail.com","credentials_email_sent":true,"ip":"58.97.164.243"}	2026-11-24 11:16:03	2026-11-24 11:16:03
1377	41	CREATE	Employees	Created employee Darwin Magpili (22-8042).	Success	{"employee_id":"22-8042","email":"Magpili@gmail.com","email_sent":true,"ip":"223.25.38.218"}	2026-11-24 14:50:15	2026-11-24 14:50:15
1423	41	CREATE	Schedules	Added and approved schedule for Jan Michael Maglinao.	Success	{"submission_id":56,"employee_id":"24-08099","leave_term_started":false,"ip":"58.97.164.243"}	2026-11-25 14:29:14	2026-11-25 14:29:14
619	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:05:15	2026-10-12 23:05:15
621	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:05:44	2026-10-12 23:05:44
1050	42	LOGIN	Authentication	Logged in as nulptimekeeping@gmail.com.	Success	{"email":"nulptimekeeping@gmail.com","ip":"136.158.79.70"}	2026-10-14 09:18:32	2026-10-14 09:18:32
626	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:06:00	2026-10-12 23:06:00
1052	42	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.70"}	2026-10-14 09:18:43	2026-10-14 09:18:43
1108	41	DELETE	Employees	Deleted employee Jerimaiah Padua (23-8111).	Success	{"employee_id":"23-8111","email":"jeremiahpadua16@gmail.com","ip":"127.0.0.1"}	2026-10-15 22:43:27	2026-10-15 22:43:27
1109	41	DELETE	Employees	Deleted employee Allainer Reyes (2408130).	Success	{"employee_id":"2408130","email":"malaluangerard@gmail.com","ip":"127.0.0.1"}	2026-10-15 22:43:43	2026-10-15 22:43:43
1062	\N	LOGIN	Authentication	Logged in as mejeipastrana@gmail.com.	Success	{"email":"mejeipastrana@gmail.com","ip":"2001:fd8:2697:8c30:c7fe:47c:c88b:abd6"}	2026-10-14 12:46:59	2026-10-14 12:46:59
631	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:06:57	2026-10-12 23:06:57
1063	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"2001:fd8:2697:8c30:c7fe:47c:c88b:abd6"}	2026-10-14 12:47:08	2026-10-14 12:47:08
633	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:07:03	2026-10-12 23:07:03
1110	41	DELETE	Employees	Deleted employee Jei Pastrana (238041).	Success	{"employee_id":"238041","email":"mejeipastrana@gmail.com","ip":"127.0.0.1"}	2026-10-15 22:43:53	2026-10-15 22:43:53
635	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:07:08	2026-10-12 23:07:08
1111	41	DELETE	Employees	Deleted employee Reymark Natividad (2508064).	Success	{"employee_id":"2508064","email":"reymarknatividad9@gmail.com","ip":"127.0.0.1"}	2026-10-15 22:44:02	2026-10-15 22:44:02
637	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:07:13	2026-10-12 23:07:13
639	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:07:19	2026-10-12 23:07:19
641	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:07:23	2026-10-12 23:07:23
1169	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"127.0.0.1"}	2026-10-16 10:44:03	2026-10-16 10:44:03
643	40	LOGIN	Authentication	Login blocked by rate limit for test101HR@gmail.com.	Failed	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:07:27	2026-10-12 23:07:27
1277	41	CREATE	Schedules	Added and approved schedule for Gerard Angelus Malaluan.	Success	{"submission_id":16,"employee_id":"238041","leave_term_started":false,"ip":"115.147.167.99"}	2026-11-23 10:57:18	2026-11-23 10:57:18
1278	41	DELETE	Employees	Deleted employee Gerard Angelus Malaluan (238041).	Success	{"employee_id":"238041","email":"malaluangerard@gmail.com","ip":"115.147.167.99"}	2026-11-23 10:58:39	2026-11-23 10:58:39
1309	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"58.97.160.46"}	2026-11-24 09:07:20	2026-11-24 09:07:20
1344	41	CREATE	Employees	Created employee Judylen Monterey (25-8085).	Success	{"employee_id":"25-8085","email":"Monterey@gmail.com","credentials_email_sent":true,"ip":"58.97.160.46"}	2026-11-24 11:26:04	2026-11-24 11:26:04
1379	41	CREATE	Employees	Bulk upload employee_bulkimport_sample (1).xlsx: created 31 of 31 login account(s), emailed credentials to 31.	Success	{"accounts_created":31,"emails_sent":31,"already_had_login":0,"account_failures":[],"ip":"223.25.38.218"}	2026-11-24 15:05:46	2026-11-24 15:05:46
651	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:08:04	2026-10-12 23:08:04
1381	41	CREATE	Employees	Bulk upload employee_bulkimport_sample (1).xlsx: created 1 of 1 login account(s), emailed credentials to 1.	Success	{"accounts_created":1,"emails_sent":1,"already_had_login":0,"account_failures":[],"ip":"223.25.38.218"}	2026-11-24 15:05:55	2026-11-24 15:05:55
653	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:08:43	2026-10-12 23:08:43
1424	41	CREATE	Schedules	Added and approved schedule for Francis Mateos.	Success	{"submission_id":57,"employee_id":"25-08090","leave_term_started":false,"ip":"58.97.164.243"}	2026-11-25 14:30:39	2026-11-25 14:30:39
655	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:09:02	2026-10-12 23:09:02
1425	41	CREATE	Schedules	Added and approved schedule for Russel Jimenez.	Success	{"submission_id":58,"employee_id":"26-08006","leave_term_started":false,"ip":"58.97.164.243"}	2026-11-25 14:30:50	2026-11-25 14:30:50
657	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:09:09	2026-10-12 23:09:09
1426	41	CREATE	Schedules	Added and approved schedule for Kimberly Camille Mendoza.	Success	{"submission_id":59,"employee_id":"25-08010","leave_term_started":false,"ip":"58.97.164.243"}	2026-11-25 14:31:27	2026-11-25 14:31:27
659	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:09:20	2026-10-12 23:09:20
1053	42	LOGIN	Authentication	Logged in as nulptimekeeping@gmail.com.	Success	{"email":"nulptimekeeping@gmail.com","ip":"127.0.0.1"}	2026-10-14 09:24:03	2026-10-14 09:24:03
1054	42	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-10-14 09:24:31	2026-10-14 09:24:31
1112	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"127.0.0.1"}	2026-10-15 23:11:31	2026-10-15 23:11:31
668	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:11:29	2026-10-12 23:11:29
1113	40	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-10-15 23:11:38	2026-10-15 23:11:38
670	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:11:36	2026-10-12 23:11:36
672	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:11:42	2026-10-12 23:11:42
1115	40	CREATE	Employees	Bulk upload employee_import_sample.xlsx: created 4 of 4 login account(s), emailed credentials to 4.	Success	{"accounts_created":4,"emails_sent":4,"already_had_login":0,"account_failures":[],"ip":"127.0.0.1"}	2026-10-15 23:12:20	2026-10-15 23:12:20
674	40	LOGIN	Authentication	Failed login attempt for test101hr@gmail.com.	Failed	{"email":"test101hr@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:11:49	2026-10-12 23:11:49
1216	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"112.198.210.117"}	2026-10-23 23:10:12	2026-10-23 23:10:12
677	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:12:10	2026-10-12 23:12:10
1217	40	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"112.198.210.117"}	2026-10-23 23:10:25	2026-10-23 23:10:25
679	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:12:19	2026-10-12 23:12:19
1170	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-10-16 10:45:11	2026-10-16 10:45:11
681	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:12:28	2026-10-12 23:12:28
1279	41	CREATE	Employees	Created employee Jei Pastrana (238041).	Success	{"employee_id":"238041","email":"angelus.malaluan@gmail.com","credentials_email_sent":true,"ip":"115.147.167.99"}	2026-11-23 10:59:30	2026-11-23 10:59:30
683	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:12:37	2026-10-12 23:12:37
1280	41	DELETE	Employees	Deleted employee Jei Pastrana (238041).	Success	{"employee_id":"238041","email":"angelus.malaluan@gmail.com","ip":"115.147.167.99"}	2026-11-23 10:59:59	2026-11-23 10:59:59
685	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:12:47	2026-10-12 23:12:47
1310	41	CREATE	Employees	Created employee John Lesther Panggat (220356).	Success	{"employee_id":"220356","email":"panggat@gmail.com","email_sent":true,"ip":"223.25.38.218"}	2026-11-24 09:15:48	2026-11-24 09:15:48
687	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:12:56	2026-10-12 23:12:56
1345	41	CREATE	Employees	Created employee Redem Quinagoran (22-8049).	Success	{"employee_id":"22-8049","email":"Quinagoran@gmail.com","credentials_email_sent":true,"ip":"58.97.160.46"}	2026-11-24 11:27:14	2026-11-24 11:27:14
689	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:13:04	2026-10-12 23:13:04
1346	41	CREATE	Employees	Created employee Aaron Christian Rodriguez (24-08108).	Success	{"employee_id":"24-08108","email":"Rodriguez@gmail.com","credentials_email_sent":true,"ip":"58.97.160.46"}	2026-11-24 11:28:47	2026-11-24 11:28:47
691	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:13:12	2026-10-12 23:13:12
693	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:13:20	2026-10-12 23:13:20
1427	41	CREATE	Schedules	Added and approved schedule for Alena Ocampo.	Success	{"submission_id":60,"employee_id":"23-8069","leave_term_started":false,"ip":"58.97.164.243"}	2026-11-25 14:32:41	2026-11-25 14:32:41
695	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:13:29	2026-10-12 23:13:29
1428	41	CREATE	Schedules	Added and approved schedule for Rosario Polintang.	Success	{"submission_id":61,"employee_id":"25-08083","leave_term_started":false,"ip":"58.97.164.243"}	2026-11-25 14:33:19	2026-11-25 14:33:19
697	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:13:37	2026-10-12 23:13:37
699	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:13:46	2026-10-12 23:13:46
702	\N	RESET	Authentication	Password reset link request failed for zaproxy@example.com.	Failed	{"email":"zaproxy@example.com","ip":"136.158.79.70"}	2026-10-12 23:24:24	2026-10-12 23:24:24
703	\N	LOGIN	Authentication	Failed login attempt for zaproxy@example.com.	Failed	{"email":"zaproxy@example.com","ip":"136.158.79.70"}	2026-10-12 23:24:25	2026-10-12 23:24:25
706	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:28:52	2026-10-13 00:28:52
707	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"180.191.75.158"}	2026-10-13 00:29:14	2026-10-13 00:29:14
708	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"180.191.75.158"}	2026-10-13 00:29:20	2026-10-13 00:29:20
709	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:32:28	2026-10-13 00:32:28
710	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:32:34	2026-10-13 00:32:34
711	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:32:39	2026-10-13 00:32:39
712	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:32:44	2026-10-13 00:32:44
713	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:32:49	2026-10-13 00:32:49
714	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:32:53	2026-10-13 00:32:53
715	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:32:57	2026-10-13 00:32:57
716	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:33:01	2026-10-13 00:33:01
717	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:33:05	2026-10-13 00:33:05
718	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:33:09	2026-10-13 00:33:09
719	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:33:13	2026-10-13 00:33:13
720	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:33:17	2026-10-13 00:33:17
721	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:33:21	2026-10-13 00:33:21
722	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:33:25	2026-10-13 00:33:25
723	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:33:31	2026-10-13 00:33:31
724	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:33:35	2026-10-13 00:33:35
725	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:33:40	2026-10-13 00:33:40
726	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:33:45	2026-10-13 00:33:45
727	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:34:04	2026-10-13 00:34:04
728	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:34:06	2026-10-13 00:34:06
729	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:34:09	2026-10-13 00:34:09
730	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:34:12	2026-10-13 00:34:12
731	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:34:14	2026-10-13 00:34:14
732	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:34:17	2026-10-13 00:34:17
733	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:34:19	2026-10-13 00:34:19
734	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:34:22	2026-10-13 00:34:22
735	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:34:25	2026-10-13 00:34:25
736	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:34:27	2026-10-13 00:34:27
737	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:34:35	2026-10-13 00:34:35
738	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:34:38	2026-10-13 00:34:38
739	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:35:06	2026-10-13 00:35:06
740	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:35:10	2026-10-13 00:35:10
741	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:35:13	2026-10-13 00:35:13
742	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:35:15	2026-10-13 00:35:15
743	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:35:18	2026-10-13 00:35:18
744	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:35:21	2026-10-13 00:35:21
745	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:35:23	2026-10-13 00:35:23
746	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:35:26	2026-10-13 00:35:26
747	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:35:29	2026-10-13 00:35:29
748	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:35:45	2026-10-13 00:35:45
749	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:35:50	2026-10-13 00:35:50
750	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:35:55	2026-10-13 00:35:55
751	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:35:59	2026-10-13 00:35:59
752	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:36:19	2026-10-13 00:36:19
753	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:36:22	2026-10-13 00:36:22
754	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:36:26	2026-10-13 00:36:26
755	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:36:30	2026-10-13 00:36:30
756	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:36:34	2026-10-13 00:36:34
758	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:36:43	2026-10-13 00:36:43
761	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"180.191.75.158"}	2026-10-13 00:37:07	2026-10-13 00:37:07
763	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"180.191.75.158"}	2026-10-13 00:37:12	2026-10-13 00:37:12
764	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:37:27	2026-10-13 00:37:27
765	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:37:31	2026-10-13 00:37:31
767	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:37:35	2026-10-13 00:37:35
768	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:37:38	2026-10-13 00:37:38
769	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:37:42	2026-10-13 00:37:42
770	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:37:45	2026-10-13 00:37:45
771	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:37:47	2026-10-13 00:37:47
772	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:37:50	2026-10-13 00:37:50
773	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:37:53	2026-10-13 00:37:53
774	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:37:55	2026-10-13 00:37:55
775	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:37:58	2026-10-13 00:37:58
776	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:38:00	2026-10-13 00:38:00
777	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:38:03	2026-10-13 00:38:03
778	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:38:06	2026-10-13 00:38:06
779	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:38:08	2026-10-13 00:38:08
780	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:38:11	2026-10-13 00:38:11
781	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:38:14	2026-10-13 00:38:14
782	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:38:16	2026-10-13 00:38:16
783	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:38:19	2026-10-13 00:38:19
784	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:38:21	2026-10-13 00:38:21
785	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:38:24	2026-10-13 00:38:24
786	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:38:27	2026-10-13 00:38:27
787	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:38:29	2026-10-13 00:38:29
788	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:38:48	2026-10-13 00:38:48
789	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:38:51	2026-10-13 00:38:51
790	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:38:54	2026-10-13 00:38:54
791	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:38:58	2026-10-13 00:38:58
792	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:39:01	2026-10-13 00:39:01
793	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:39:04	2026-10-13 00:39:04
794	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:39:06	2026-10-13 00:39:06
795	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:39:09	2026-10-13 00:39:09
796	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:39:11	2026-10-13 00:39:11
757	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:36:40	2026-10-13 00:36:40
759	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"180.191.75.158"}	2026-10-13 00:36:43	2026-10-13 00:36:43
760	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:37:05	2026-10-13 00:37:05
762	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:37:09	2026-10-13 00:37:09
766	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"180.191.75.158"}	2026-10-13 00:37:32	2026-10-13 00:37:32
799	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:39:33	2026-10-13 00:39:33
800	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:39:35	2026-10-13 00:39:35
801	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:39:38	2026-10-13 00:39:38
802	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:39:41	2026-10-13 00:39:41
803	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:39:43	2026-10-13 00:39:43
804	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:39:48	2026-10-13 00:39:48
805	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:39:52	2026-10-13 00:39:52
806	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:39:55	2026-10-13 00:39:55
807	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:39:59	2026-10-13 00:39:59
808	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:40:09	2026-10-13 00:40:09
809	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:40:11	2026-10-13 00:40:11
810	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:40:14	2026-10-13 00:40:14
811	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:40:16	2026-10-13 00:40:16
812	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:40:19	2026-10-13 00:40:19
828	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:41:30	2026-10-13 00:41:30
829	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"180.191.75.158"}	2026-10-13 00:41:30	2026-10-13 00:41:30
830	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:41:50	2026-10-13 00:41:50
831	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:41:53	2026-10-13 00:41:53
832	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:41:56	2026-10-13 00:41:56
833	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:41:58	2026-10-13 00:41:58
834	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:42:03	2026-10-13 00:42:03
835	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:42:06	2026-10-13 00:42:06
836	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:42:10	2026-10-13 00:42:10
837	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:42:13	2026-10-13 00:42:13
839	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:42:45	2026-10-13 00:42:45
840	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:42:48	2026-10-13 00:42:48
841	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:42:50	2026-10-13 00:42:50
842	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:42:53	2026-10-13 00:42:53
843	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:42:56	2026-10-13 00:42:56
844	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:42:58	2026-10-13 00:42:58
845	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:43:04	2026-10-13 00:43:04
846	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:43:07	2026-10-13 00:43:07
847	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:43:11	2026-10-13 00:43:11
848	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:43:14	2026-10-13 00:43:14
849	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:43:18	2026-10-13 00:43:18
850	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:43:20	2026-10-13 00:43:20
851	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:43:23	2026-10-13 00:43:23
797	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:39:14	2026-10-13 00:39:14
798	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:39:30	2026-10-13 00:39:30
813	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:40:29	2026-10-13 00:40:29
814	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:40:31	2026-10-13 00:40:31
815	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:40:34	2026-10-13 00:40:34
816	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:40:37	2026-10-13 00:40:37
817	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:40:39	2026-10-13 00:40:39
818	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:41:00	2026-10-13 00:41:00
819	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:41:04	2026-10-13 00:41:04
820	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:41:07	2026-10-13 00:41:07
821	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:41:11	2026-10-13 00:41:11
822	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:41:14	2026-10-13 00:41:14
823	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:41:17	2026-10-13 00:41:17
824	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:41:19	2026-10-13 00:41:19
825	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:41:22	2026-10-13 00:41:22
826	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:41:25	2026-10-13 00:41:25
827	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:41:27	2026-10-13 00:41:27
838	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:42:43	2026-10-13 00:42:43
1055	\N	CREATE	Leave Management	Leave file processed — 0 new, 174 updated, 5063 skipped, 3 WFH notification(s) sent.	Success	{"original_filename":"jvsAnrdm8DHGcogRqR0xdXHzqUNkXEs9IVYGTHHy.xlsx","imported":0,"updated":174,"skipped":5063,"ip":"127.0.0.1"}	2026-10-14 09:43:26	2026-10-14 09:43:26
1117	41	DELETE	Employees	Cleared 2 employee bulk upload history entries.	Success	{"deleted_upload_entries":2,"employee_records_affected":false,"ip":"127.0.0.1"}	2026-10-15 23:13:49	2026-10-15 23:13:49
1118	41	UPDATE	Role Management	Updated pritongtalong808@gmail.com role from Employee to HR.	Success	{"user_id":64,"email":"pritongtalong808@gmail.com","from":"Employee","to":"HR","ip":"127.0.0.1"}	2026-10-15 23:14:22	2026-10-15 23:14:22
1218	40	LOGOUT	Authentication	Logged out test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"112.198.208.159"}	2026-10-24 20:07:55	2026-10-24 20:07:55
1219	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"112.198.208.159"}	2026-10-24 20:08:11	2026-10-24 20:08:11
1220	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"112.198.208.159"}	2026-10-24 20:08:24	2026-10-24 20:08:24
1171	\N	APPROVE	Schedules	Approved schedule for Allainer Reyes.	Success	{"submission_id":12,"employee_id":"2408130","ip":"127.0.0.1"}	2026-10-16 10:49:41	2026-10-16 10:49:41
1281	41	CREATE	Employees	Created employee JOSIERENE Abel (23-8066).	Success	{"employee_id":"23-8066","email":"abel@gmail.com","email_sent":true,"ip":"58.97.160.46"}	2026-11-23 11:43:05	2026-11-23 11:43:05
1311	41	CREATE	Employees	Created employee Cherry Lyn Carpio (238029).	Success	{"employee_id":"238029","email":"carpio@gmail.com","email_sent":true,"ip":"223.25.38.218"}	2026-11-24 09:18:04	2026-11-24 09:18:04
1347	41	CREATE	Employees	Created employee Sebulino Honorato (24-08017).	Success	{"employee_id":"24-08017","email":"Honorato@gmail.com","credentials_email_sent":true,"ip":"223.25.38.218"}	2026-11-24 11:30:32	2026-11-24 11:30:32
1348	41	CREATE	Schedules	Added and approved schedule for John Lesther Panggat.	Success	{"submission_id":27,"employee_id":"220356","leave_term_started":false,"ip":"58.97.164.243"}	2026-11-24 11:31:56	2026-11-24 11:31:56
1349	41	CREATE	Schedules	Added and approved schedule for Rowena Alcoba.	Success	{"submission_id":28,"employee_id":"23-8099","leave_term_started":false,"ip":"223.25.38.218"}	2026-11-24 11:32:26	2026-11-24 11:32:26
1383	41	CREATE	Employees	Created employee Regina Endaya (2408009).	Success	{"employee_id":"2408009","email":"Endaya@gmail.com","email_sent":true,"ip":"223.25.38.218"}	2026-11-24 15:13:24	2026-11-24 15:13:24
1429	41	CREATE	Schedules	Added and approved schedule for Charlene Villegas.	Success	{"submission_id":62,"employee_id":"26-08008","leave_term_started":false,"ip":"223.25.38.218"}	2026-11-25 14:34:44	2026-11-25 14:34:44
852	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:43:26	2026-10-13 00:43:26
853	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:43:28	2026-10-13 00:43:28
854	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:43:31	2026-10-13 00:43:31
855	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:43:33	2026-10-13 00:43:33
856	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:43:36	2026-10-13 00:43:36
857	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:43:43	2026-10-13 00:43:43
858	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:43:46	2026-10-13 00:43:46
859	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:43:48	2026-10-13 00:43:48
860	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:44:21	2026-10-13 00:44:21
861	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:44:24	2026-10-13 00:44:24
862	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:44:28	2026-10-13 00:44:28
863	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:44:31	2026-10-13 00:44:31
864	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:44:35	2026-10-13 00:44:35
865	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:44:37	2026-10-13 00:44:37
866	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:44:40	2026-10-13 00:44:40
867	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:44:42	2026-10-13 00:44:42
868	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:44:45	2026-10-13 00:44:45
869	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:44:47	2026-10-13 00:44:47
870	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:44:50	2026-10-13 00:44:50
871	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:44:53	2026-10-13 00:44:53
872	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:44:55	2026-10-13 00:44:55
873	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:44:58	2026-10-13 00:44:58
874	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:45:19	2026-10-13 00:45:19
875	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:45:23	2026-10-13 00:45:23
876	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:45:27	2026-10-13 00:45:27
877	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:45:30	2026-10-13 00:45:30
878	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:45:34	2026-10-13 00:45:34
879	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:45:38	2026-10-13 00:45:38
880	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:45:40	2026-10-13 00:45:40
881	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:45:43	2026-10-13 00:45:43
882	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:45:46	2026-10-13 00:45:46
883	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:45:48	2026-10-13 00:45:48
884	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:45:51	2026-10-13 00:45:51
885	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:45:53	2026-10-13 00:45:53
886	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:46:18	2026-10-13 00:46:18
887	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:46:20	2026-10-13 00:46:20
888	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:46:25	2026-10-13 00:46:25
889	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:46:29	2026-10-13 00:46:29
890	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:46:32	2026-10-13 00:46:32
891	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:46:36	2026-10-13 00:46:36
892	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:46:39	2026-10-13 00:46:39
893	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:46:42	2026-10-13 00:46:42
894	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:46:44	2026-10-13 00:46:44
895	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:46:47	2026-10-13 00:46:47
896	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:46:49	2026-10-13 00:46:49
897	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:46:52	2026-10-13 00:46:52
898	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:46:54	2026-10-13 00:46:54
899	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:46:57	2026-10-13 00:46:57
900	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:46:59	2026-10-13 00:46:59
901	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:47:02	2026-10-13 00:47:02
902	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:47:19	2026-10-13 00:47:19
903	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:47:34	2026-10-13 00:47:34
904	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:47:38	2026-10-13 00:47:38
905	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:47:43	2026-10-13 00:47:43
906	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:47:57	2026-10-13 00:47:57
907	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:48:01	2026-10-13 00:48:01
908	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:48:03	2026-10-13 00:48:03
909	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:48:06	2026-10-13 00:48:06
910	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:48:08	2026-10-13 00:48:08
911	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:48:11	2026-10-13 00:48:11
912	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:48:13	2026-10-13 00:48:13
913	41	LOGIN	Authentication	Login blocked by rate limit for test101A@gmail.com.	Failed	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:48:16	2026-10-13 00:48:16
914	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"180.191.75.158"}	2026-10-13 00:48:16	2026-10-13 00:48:16
915	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:48:38	2026-10-13 00:48:38
916	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:48:51	2026-10-13 00:48:51
917	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:48:56	2026-10-13 00:48:56
918	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:49:03	2026-10-13 00:49:03
919	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:49:53	2026-10-13 00:49:53
920	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:49:58	2026-10-13 00:49:58
921	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:50:03	2026-10-13 00:50:03
922	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:50:08	2026-10-13 00:50:08
923	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"180.191.75.158"}	2026-10-13 00:50:30	2026-10-13 00:50:30
924	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:50:31	2026-10-13 00:50:31
925	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"180.191.75.158"}	2026-10-13 00:50:36	2026-10-13 00:50:36
926	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:50:37	2026-10-13 00:50:37
927	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"180.191.75.158"}	2026-10-13 00:50:41	2026-10-13 00:50:41
928	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:50:43	2026-10-13 00:50:43
929	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"180.191.75.158"}	2026-10-13 00:50:47	2026-10-13 00:50:47
930	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:50:49	2026-10-13 00:50:49
931	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"180.191.75.158"}	2026-10-13 00:50:54	2026-10-13 00:50:54
932	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:50:55	2026-10-13 00:50:55
933	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"180.191.75.158"}	2026-10-13 00:51:00	2026-10-13 00:51:00
934	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:51:01	2026-10-13 00:51:01
935	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"180.191.75.158"}	2026-10-13 00:51:06	2026-10-13 00:51:06
936	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:51:07	2026-10-13 00:51:07
937	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"180.191.75.158"}	2026-10-13 00:51:12	2026-10-13 00:51:12
1056	\N	CREATE	Leave Management	Leave file processed — 5 new, 169 updated, 5063 skipped, 3 WFH notification(s) sent.	Success	{"original_filename":"xfgpnTpoUiFCfyC2134mhG0QYPtXA4MbpfvODgHA.xlsx","imported":5,"updated":169,"skipped":5063,"ip":"127.0.0.1"}	2026-10-14 09:47:43	2026-10-14 09:47:43
1057	42	CREATE	Leave Management	Leave file processed — 0 new, 174 updated, 5063 skipped, 3 WFH notification(s) sent.	Success	{"original_filename":"LPA-23-8111-1791876860-LeaveApplications (1).xlsx","imported":0,"updated":174,"skipped":5063,"ip":"127.0.0.1"}	2026-10-14 09:49:35	2026-10-14 09:49:35
1119	\N	LOGIN	Authentication	Logged in as pritongtalong808@gmail.com.	Success	{"email":"pritongtalong808@gmail.com","ip":"127.0.0.1"}	2026-10-15 23:15:09	2026-10-15 23:15:09
1120	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-10-15 23:15:16	2026-10-15 23:15:16
1221	41	LOGIN	Authentication	Failed login attempt for test101a@gmail.com.	Failed	{"email":"test101a@gmail.com","ip":"136.158.79.70"}	2026-10-26 21:11:54	2026-10-26 21:11:54
1222	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"136.158.79.70"}	2026-10-26 21:12:02	2026-10-26 21:12:02
1223	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.70"}	2026-10-26 21:12:12	2026-10-26 21:12:12
1172	\N	CREATE	DTR	Biometric PDF processed — 29 attendance row(s) imported, 766 skipped (unmatched employees).	Success	{"original_filename":"sace sep 1-30 1.pdf","imported":29,"skipped":766,"format":"NU Lipa Timesheet Report","pages":34,"rows_extracted":795,"extraction_seconds":0.18,"ip":"127.0.0.1"}	2026-10-16 10:50:22	2026-10-16 10:50:22
1282	41	CREATE	Schedules	Added and approved schedule for JOSIERENE Abel.	Success	{"submission_id":17,"employee_id":"23-8066","leave_term_started":true,"ip":"58.97.164.243"}	2026-11-23 11:46:22	2026-11-23 11:46:22
1312	41	CREATE	Employees	Created employee Jiselle Umali (238030).	Success	{"employee_id":"238030","email":"umali@gmail.com","email_sent":true,"ip":"58.97.160.46"}	2026-11-24 09:20:20	2026-11-24 09:20:20
1350	41	CREATE	Schedules	Added and approved schedule for Diane Angelika Novicio.	Success	{"submission_id":29,"employee_id":"238034","leave_term_started":false,"ip":"223.25.38.218"}	2026-11-24 11:34:05	2026-11-24 11:34:05
1384	41	DELETE	Employees	Cleared 10 employee bulk upload history entries.	Success	{"deleted_upload_entries":10,"employee_records_affected":false,"ip":"223.25.38.218"}	2026-11-24 15:15:52	2026-11-24 15:15:52
1385	41	CREATE	Employees	Bulk upload processed 67 row(s): 18 added, 15 already registered, 34 with errors.	Success	{"original_filename":"employee_bulkimport_sample (1).xlsx","bulk_upload":true,"total_rows":67,"created":18,"existing":15,"failed":34,"verification":{"records_checked":18,"records_found":18,"fields_checked":162,"fields_correct":162,"fully_correct":18,"not_imported":0,"superseded":0,"mismatch_count":0,"field_accuracy":100,"record_accuracy":100},"ip":"223.25.38.218"}	2026-11-24 15:16:13	2026-11-24 15:16:13
1386	41	CREATE	Employees	Bulk upload employee_bulkimport_sample (1).xlsx: created 18 of 18 login account(s), emailed credentials to 18.	Success	{"accounts_created":18,"emails_sent":18,"already_had_login":0,"account_failures":[],"ip":"223.25.38.218"}	2026-11-24 15:16:45	2026-11-24 15:16:45
1430	41	CREATE	Schedules	Added and approved schedule for Chelsea Louella Lat.	Success	{"submission_id":63,"employee_id":"24-08129","leave_term_started":false,"ip":"223.25.38.218"}	2026-11-25 14:55:34	2026-11-25 14:55:34
938	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:51:14	2026-10-13 00:51:14
939	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"180.191.75.158"}	2026-10-13 00:51:19	2026-10-13 00:51:19
940	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:51:20	2026-10-13 00:51:20
941	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"180.191.75.158"}	2026-10-13 00:51:25	2026-10-13 00:51:25
944	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:51:33	2026-10-13 00:51:33
945	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"180.191.75.158"}	2026-10-13 00:51:37	2026-10-13 00:51:37
1058	42	CREATE	Leave Management	Leave file processed — 0 new, 174 updated, 5063 skipped, 3 WFH notification(s) sent.	Success	{"original_filename":"LPA-23-8111-1791876860-LeaveApplications (1).xlsx","imported":0,"updated":174,"skipped":5063,"ip":"127.0.0.1"}	2026-10-14 10:03:21	2026-10-14 10:03:21
1121	\N	LOGIN	Authentication	Logged in as malaluangerard@gmail.com.	Success	{"email":"malaluangerard@gmail.com","ip":"127.0.0.1"}	2026-10-15 23:18:28	2026-10-15 23:18:28
1122	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-10-15 23:18:37	2026-10-15 23:18:37
1174	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"127.0.0.1"}	2026-10-16 11:00:04	2026-10-16 11:00:04
1175	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-10-16 11:00:14	2026-10-16 11:00:14
1224	\N	LOGIN	Authentication	Failed login attempt for apcalub@national-u.edu.ph.	Failed	{"email":"apcalub@national-u.edu.ph","ip":"203.82.34.100"}	2026-11-05 09:41:46	2026-11-05 09:41:46
1173	\N	CREATE	Leave Management	Leave file processed — 93 new, 82 updated, 5062 skipped, 33 attendance day(s) auto-fulfilled, 3 WFH notification(s) sent.	Success	{"original_filename":"LPA-23-8111-1791876860-LeaveApplications (1).xlsx","imported":93,"updated":82,"skipped":5062,"verification":{"records_checked":175,"records_found":175,"fields_checked":875,"fields_correct":875,"fully_correct":175,"not_imported":5062,"superseded":0,"mismatch_count":0,"field_accuracy":100,"record_accuracy":100},"ip":"127.0.0.1"}	2026-10-16 10:57:06	2026-10-16 10:57:06
1283	41	DELETE	Schedules	Cleared approved schedule for JOSIERENE Abel.	Success	{"submission_id":17,"employee_id":"23-8066","ip":"58.97.164.243"}	2026-11-23 11:47:24	2026-11-23 11:47:24
1313	41	CREATE	Employees	Created employee Diane Angelika Novicio (238034).	Success	{"employee_id":"238034","email":"Novicio@gmail.com","email_sent":true,"ip":"58.97.164.243"}	2026-11-24 09:22:22	2026-11-24 09:22:22
1351	41	CREATE	Schedules	Added and approved schedule for Noelah Mae Borbon.	Success	{"submission_id":30,"employee_id":"24-08068","leave_term_started":false,"ip":"223.25.38.218"}	2026-11-24 11:36:53	2026-11-24 11:36:53
1387	41	CREATE	Employees	Bulk upload processed 67 row(s): 28 added, 33 already registered, 6 with errors.	Success	{"original_filename":"employee_bulkimport_sample (1).xlsx","bulk_upload":true,"total_rows":67,"created":28,"existing":33,"failed":6,"verification":{"records_checked":28,"records_found":28,"fields_checked":252,"fields_correct":252,"fully_correct":28,"not_imported":0,"superseded":0,"mismatch_count":0,"field_accuracy":100,"record_accuracy":100},"ip":"223.25.38.218"}	2026-11-24 15:20:35	2026-11-24 15:20:35
1388	41	CREATE	Employees	Bulk upload employee_bulkimport_sample (1).xlsx: created 28 of 28 login account(s), emailed credentials to 28.	Success	{"accounts_created":28,"emails_sent":28,"already_had_login":0,"account_failures":[],"ip":"223.25.38.218"}	2026-11-24 15:21:21	2026-11-24 15:21:21
1389	41	CREATE	Employees	Created employee Francis Jay Enriquez (2408025).	Success	{"employee_id":"2408025","email":"Enriquez@gmail.com","email_sent":true,"ip":"58.97.160.46"}	2026-11-24 15:22:24	2026-11-24 15:22:24
1431	41	CREATE	Schedules	Added and approved schedule for Janice Fischer.	Success	{"submission_id":64,"employee_id":"228045","leave_term_started":false,"ip":"223.25.38.218"}	2026-11-25 15:35:44	2026-11-25 15:35:44
1432	41	CREATE	Schedules	Added and approved schedule for Francis Jay Enriquez.	Success	{"submission_id":65,"employee_id":"2408025","leave_term_started":false,"ip":"223.25.38.218"}	2026-11-25 15:37:31	2026-11-25 15:37:31
942	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:51:27	2026-10-13 00:51:27
943	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"180.191.75.158"}	2026-10-13 00:51:31	2026-10-13 00:51:31
1059	42	CREATE	Leave Management	Leave file processed — 0 new, 11 updated, 256 skipped.	Success	{"original_filename":"Jan-May 2026.xlsx","imported":0,"updated":11,"skipped":256,"ip":"136.158.79.70"}	2026-10-14 10:34:33	2026-10-14 10:34:33
1060	42	CREATE	Leave Management	Leave file processed — 0 new, 17 updated, 288 skipped, 10 attendance day(s) auto-fulfilled.	Success	{"original_filename":"June-October 2026.xlsx","imported":0,"updated":17,"skipped":288,"ip":"136.158.79.70"}	2026-10-14 10:35:39	2026-10-14 10:35:39
1123	\N	APPROVE	Schedules	Approved schedule for Jerimaiah Padua.	Success	{"submission_id":8,"employee_id":"238111","ip":"127.0.0.1"}	2026-10-15 23:20:01	2026-10-15 23:20:01
1124	\N	CREATE	DTR	Biometric PDF processed — 66 attendance row(s) imported, 1187 skipped (unmatched employees).	Success	{"original_filename":"ASP Sep 1-30.pdf","imported":66,"skipped":1187,"ip":"127.0.0.1"}	2026-10-15 23:20:44	2026-10-15 23:20:44
1176	41	CREATE	Academic Calendar	Added calendar date: SAMPLE LANG NON WORKING SEPT 26 (2026-09-26).	Success	{"entry_id":16,"event_date":"2026-09-26","ip":"127.0.0.1"}	2026-10-16 11:00:44	2026-10-16 11:00:44
1177	41	DELETE	Schedules	Cleared schedule for Allainer Reyes.	Success	{"submission_id":12,"employee_id":"2408130","ip":"127.0.0.1"}	2026-10-16 11:02:10	2026-10-16 11:02:10
1225	40	LOGIN	Authentication	Logged in as test101HR@gmail.com.	Success	{"email":"test101HR@gmail.com","ip":"127.0.0.1"}	2026-11-07 01:32:52	2026-11-07 01:32:52
1226	40	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-11-07 01:33:01	2026-11-07 01:33:01
1284	41	CREATE	Schedules	Added and approved schedule for JOSIERENE Abel.	Success	{"submission_id":18,"employee_id":"23-8066","leave_term_started":true,"ip":"58.97.164.243"}	2026-11-23 11:51:53	2026-11-23 11:51:53
1314	41	CREATE	Employees	Created employee Anna Mae Sales Olan (238036).	Success	{"employee_id":"238036","email":"Olan@gmail.com","email_sent":true,"ip":"223.25.38.218"}	2026-11-24 09:30:53	2026-11-24 09:30:53
1352	41	CREATE	Schedules	Added and approved schedule for Lorena Manimtim.	Success	{"submission_id":31,"employee_id":"238081","leave_term_started":false,"ip":"58.97.164.243"}	2026-11-24 11:40:53	2026-11-24 11:40:53
1390	41	CREATE	Employees	Created employee Carlos Caesar Caday (2408044).	Success	{"employee_id":"2408044","email":"Caday@gmail.com","email_sent":true,"ip":"223.25.38.218"}	2026-11-24 15:23:46	2026-11-24 15:23:46
1433	\N	LOGIN	Authentication	Failed login attempt for test101@gmail.com.	Failed	{"email":"test101@gmail.com","ip":"216.247.87.131"}	2026-11-25 16:45:39	2026-11-25 16:45:39
1434	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"216.247.87.131"}	2026-11-25 16:46:06	2026-11-25 16:46:06
1435	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"216.247.87.131"}	2026-11-25 16:46:13	2026-11-25 16:46:13
946	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"180.191.75.158"}	2026-10-13 00:51:39	2026-10-13 00:51:39
947	42	LOGIN	Authentication	Logged in as nulptimekeeping@gmail.com.	Success	{"email":"nulptimekeeping@gmail.com","ip":"58.97.160.46"}	2026-10-13 15:17:25	2026-10-13 15:17:25
948	42	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"58.97.160.46"}	2026-10-13 15:17:34	2026-10-13 15:17:34
952	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"136.158.79.70"}	2026-10-13 16:07:25	2026-10-13 16:07:25
953	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.70"}	2026-10-13 16:07:38	2026-10-13 16:07:38
954	41	UPDATE	Employees	Updated employee Jeremiah Padua (23-8111).	Success	{"employee_id":"23-8111","fields":["employee_id","first_name","last_name","email","department_id","position","employment_type","ranking","hire_date"],"ip":"136.158.79.70"}	2026-10-13 16:08:11	2026-10-13 16:08:11
956	42	LOGIN	Authentication	Logged in as nulptimekeeping@gmail.com.	Success	{"email":"nulptimekeeping@gmail.com","ip":"136.158.79.70"}	2026-10-13 16:13:23	2026-10-13 16:13:23
958	42	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.70"}	2026-10-13 16:14:43	2026-10-13 16:14:43
959	42	LOGOUT	Authentication	Logged out nulptimekeeping@gmail.com.	Success	{"email":"nulptimekeeping@gmail.com","ip":"223.25.38.218"}	2026-10-13 16:15:33	2026-10-13 16:15:33
960	42	LOGIN	Authentication	Logged in as nulptimekeeping@gmail.com.	Success	{"email":"nulptimekeeping@gmail.com","ip":"223.25.38.218"}	2026-10-13 16:15:40	2026-10-13 16:15:40
961	42	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"223.25.38.218"}	2026-10-13 16:15:48	2026-10-13 16:15:48
962	42	LOGIN	Authentication	Logged in as nulptimekeeping@gmail.com.	Success	{"email":"nulptimekeeping@gmail.com","ip":"127.0.0.1"}	2026-10-13 16:53:12	2026-10-13 16:53:12
963	42	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-10-13 16:53:26	2026-10-13 16:53:26
964	42	CREATE	DTR	Biometric PDF processed — 22 attendance row(s) imported, 1231 skipped (unmatched employees).	Success	{"original_filename":"ASP Sep 1-30.pdf","imported":22,"skipped":1231,"ip":"127.0.0.1"}	2026-10-13 16:55:53	2026-10-13 16:55:53
965	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"136.158.79.70"}	2026-10-13 16:58:38	2026-10-13 16:58:38
966	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.70"}	2026-10-13 16:58:45	2026-10-13 16:58:45
967	41	UPDATE	Employees	Updated employee Jerimaiah Padua (23-8111).	Success	{"employee_id":"23-8111","fields":["employee_id","first_name","last_name","email","department_id","position","employment_type","ranking","hire_date"],"ip":"136.158.79.70"}	2026-10-13 16:59:17	2026-10-13 16:59:17
968	42	CREATE	DTR	Biometric PDF processed — 45 attendance row(s) imported, 1208 skipped (unmatched employees).	Success	{"original_filename":"ASP Sep 1-30.pdf","imported":45,"skipped":1208,"ip":"127.0.0.1"}	2026-10-13 16:59:32	2026-10-13 16:59:32
969	42	CREATE	DTR	Biometric PDF processed — 29 attendance row(s) imported, 766 skipped (unmatched employees).	Success	{"original_filename":"sace sep 1-30 1.pdf","imported":29,"skipped":766,"ip":"127.0.0.1"}	2026-10-13 17:06:27	2026-10-13 17:06:27
970	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"127.0.0.1"}	2026-10-13 18:11:51	2026-10-13 18:11:51
971	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-10-13 18:11:57	2026-10-13 18:11:57
972	41	UPDATE	Employees	Updated employee Jei Pastrana (238041).	Success	{"employee_id":"238041","fields":["employee_id","first_name","last_name","email","department_id","position","employment_type","employment_status","ranking","hire_date"],"ip":"127.0.0.1"}	2026-10-13 18:13:08	2026-10-13 18:13:08
973	41	UPDATE	Employees	Updated employee Sharlene Anne Hildago (23-8026).	Success	{"employee_id":"23-8026","fields":["employee_id","first_name","last_name","email","department_id","position","employment_type","employment_status","ranking","hire_date"],"ip":"127.0.0.1"}	2026-10-13 18:13:51	2026-10-13 18:13:51
974	41	UPDATE	Employees	Updated employee Shiela Morfi (24-08051).	Success	{"employee_id":"24-08051","fields":["employee_id","first_name","last_name","email","department_id","position","employment_type","employment_status","ranking","hire_date"],"ip":"127.0.0.1"}	2026-10-13 18:14:08	2026-10-13 18:14:08
975	41	UPDATE	Employees	Updated employee Jerimaiah Padua (23-8111).	Success	{"employee_id":"23-8111","fields":["employee_id","first_name","last_name","email","department_id","position","employment_type","employment_status","ranking","hire_date"],"ip":"127.0.0.1"}	2026-10-13 18:14:28	2026-10-13 18:14:28
976	41	DELETE	Employees	Deleted employee Reymark Natividad (2508064).	Success	{"employee_id":"2508064","email":"angelus.malaluan@gmail.com","ip":"127.0.0.1"}	2026-10-13 18:17:45	2026-10-13 18:17:45
977	41	DELETE	Employees	Deleted employee Allainer Reyes (2408130).	Success	{"employee_id":"2408130","email":"malaluangerard@gmail.com","ip":"127.0.0.1"}	2026-10-13 18:18:56	2026-10-13 18:18:56
949	\N	LOGIN	Authentication	Logged in as JEREMIAHPADUA16@GMAIL.COM.	Success	{"email":"JEREMIAHPADUA16@GMAIL.COM","ip":"216.247.87.207"}	2026-10-13 15:44:20	2026-10-13 15:44:20
950	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"216.247.87.207"}	2026-10-13 15:44:29	2026-10-13 15:44:29
980	41	UPDATE	Employees	Updated employee Reymark Natividad (2508064).	Success	{"employee_id":"2508064","fields":["employee_id","first_name","last_name","email","department_id","position","employment_type","employment_status","ranking","hire_date"],"ip":"127.0.0.1"}	2026-10-13 18:29:26	2026-10-13 18:29:26
955	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"136.158.79.70"}	2026-10-13 16:13:16	2026-10-13 16:13:16
957	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.70"}	2026-10-13 16:13:26	2026-10-13 16:13:26
1061	42	CREATE	DTR	Biometric PDF processed — 66 attendance row(s) imported, 1187 skipped (unmatched employees).	Success	{"original_filename":"ASP Sep 1-30.pdf","imported":66,"skipped":1187,"ip":"136.158.79.70"}	2026-10-14 10:39:04	2026-10-14 10:39:04
1125	41	UPDATE	DTR	Updated DTR record for Jerimaiah Padua on 2026-09-05.	Success	{"attendance_record_id":921,"record_date":"2026-09-05","ip":"127.0.0.1"}	2026-10-15 23:25:35	2026-10-15 23:25:35
981	41	UPDATE	Employees	Updated employee Reymark Natividad (2508064).	Success	{"employee_id":"2508064","fields":["employee_id","first_name","last_name","email","department_id","position","employment_type","employment_status","ranking","hire_date"],"ip":"127.0.0.1"}	2026-10-13 18:30:50	2026-10-13 18:30:50
982	41	UPDATE	Employees	Updated employee Reymark Natividad (2508064).	Success	{"employee_id":"2508064","fields":["employee_id","first_name","last_name","email","department_id","position","employment_type","employment_status","ranking","hire_date"],"ip":"127.0.0.1"}	2026-10-13 18:31:05	2026-10-13 18:31:05
985	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"112.202.107.3"}	2026-10-13 19:59:42	2026-10-13 19:59:42
986	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"112.202.107.3"}	2026-10-13 19:59:51	2026-10-13 19:59:51
987	41	CREATE	Academic Calendar	Added calendar date: Bonifacio Day (2026-11-30).	Success	{"entry_id":9,"event_date":"2026-11-30","ip":"112.202.107.3"}	2026-10-13 20:04:00	2026-10-13 20:04:00
988	41	CREATE	Academic Calendar	Added calendar date: All Saints' Day (2026-11-01).	Success	{"entry_id":10,"event_date":"2026-11-01","ip":"112.202.107.3"}	2026-10-13 20:05:22	2026-10-13 20:05:22
989	41	CREATE	Academic Calendar	Added calendar date: All Souls' Day (2026-11-02).	Success	{"entry_id":11,"event_date":"2026-11-02","ip":"112.202.107.3"}	2026-10-13 20:06:27	2026-10-13 20:06:27
990	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"112.202.107.3"}	2026-10-13 20:09:43	2026-10-13 20:09:43
991	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"112.202.107.3"}	2026-10-13 20:09:58	2026-10-13 20:09:58
992	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"112.202.107.3"}	2026-10-13 20:09:59	2026-10-13 20:09:59
993	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"112.202.107.3"}	2026-10-13 20:10:02	2026-10-13 20:10:02
994	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"112.202.107.3"}	2026-10-13 20:10:06	2026-10-13 20:10:06
995	41	CREATE	Academic Calendar	Added calendar date: Feast of the Immaculate Conception of Mary (2026-12-08).	Success	{"entry_id":12,"event_date":"2026-12-08","ip":"112.202.107.3"}	2026-10-13 20:11:57	2026-10-13 20:11:57
996	41	CREATE	Academic Calendar	Added calendar date: Feast of the Immaculate Conception of Mary (2026-12-08).	Success	{"entry_id":13,"event_date":"2026-12-08","ip":"112.202.107.3"}	2026-10-13 20:11:59	2026-10-13 20:11:59
997	41	CREATE	Academic Calendar	Added calendar date: Christmas Eve (2026-12-24).	Success	{"entry_id":14,"event_date":"2026-12-24","ip":"112.202.107.3"}	2026-10-13 20:13:05	2026-10-13 20:13:05
998	41	CREATE	Academic Calendar	Added calendar date: Last Day of the Year (2026-12-31).	Success	{"entry_id":15,"event_date":"2026-12-31","ip":"112.202.107.3"}	2026-10-13 20:14:02	2026-10-13 20:14:02
999	42	LOGIN	Authentication	Logged in as nulptimekeeping@gmail.com.	Success	{"email":"nulptimekeeping@gmail.com","ip":"136.158.79.70"}	2026-10-13 21:25:52	2026-10-13 21:25:52
1000	42	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.70"}	2026-10-13 21:26:37	2026-10-13 21:26:37
1001	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"136.158.79.70"}	2026-10-13 21:32:09	2026-10-13 21:32:09
1002	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.70"}	2026-10-13 21:33:16	2026-10-13 21:33:16
978	\N	LOGIN	Authentication	Logged in as angelus.malaluan@gmail.com.	Success	{"email":"angelus.malaluan@gmail.com","ip":"127.0.0.1"}	2026-10-13 18:26:30	2026-10-13 18:26:30
979	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-10-13 18:26:35	2026-10-13 18:26:35
983	\N	LOGIN	Authentication	Logged in as angelus.malaluan@gmail.com.	Success	{"email":"angelus.malaluan@gmail.com","ip":"136.158.79.70"}	2026-10-13 18:42:31	2026-10-13 18:42:31
984	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.70"}	2026-10-13 18:42:40	2026-10-13 18:42:40
1003	41	DELETE	Employees	Deleted employee Ar-Ar Da Divitan (2508064).	Success	{"employee_id":"2508064","email":"angelus.malaluan@gmail.com","ip":"136.158.79.70"}	2026-10-13 21:34:43	2026-10-13 21:34:43
30	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"127.0.0.1"}	2026-10-12 21:20:50	2026-10-12 21:20:50
31	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-10-12 21:20:55	2026-10-12 21:20:55
36	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"127.0.0.1"}	2026-10-12 21:27:23	2026-10-12 21:27:23
37	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"127.0.0.1"}	2026-10-12 21:27:38	2026-10-12 21:27:38
83	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:13:31	2026-10-12 22:13:31
85	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:13:39	2026-10-12 22:13:39
87	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:13:45	2026-10-12 22:13:45
47	\N	LOGOUT	Authentication	Logged out donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"136.158.79.70"}	2026-10-12 21:53:37	2026-10-12 21:53:37
48	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"136.158.79.70"}	2026-10-12 21:53:51	2026-10-12 21:53:51
49	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.70"}	2026-10-12 21:54:14	2026-10-12 21:54:14
51	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 21:58:56	2026-10-12 21:58:56
274	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:31:33	2026-10-12 22:31:33
1315	41	LOGIN	Authentication	Logged in as test101A@gmail.com.	Success	{"email":"test101A@gmail.com","ip":"223.25.38.218"}	2026-11-24 09:44:42	2026-11-24 09:44:42
1316	41	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"223.25.38.218"}	2026-11-24 09:44:49	2026-11-24 09:44:49
52	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"103.60.171.134"}	2026-10-12 21:59:10	2026-10-12 21:59:10
57	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:11:56	2026-10-12 22:11:56
59	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:12:05	2026-10-12 22:12:05
62	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:12:13	2026-10-12 22:12:13
64	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:12:21	2026-10-12 22:12:21
67	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:12:29	2026-10-12 22:12:29
69	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:12:35	2026-10-12 22:12:35
71	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:12:42	2026-10-12 22:12:42
73	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:12:50	2026-10-12 22:12:50
75	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:13:00	2026-10-12 22:13:00
77	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:13:07	2026-10-12 22:13:07
79	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:13:16	2026-10-12 22:13:16
81	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:13:24	2026-10-12 22:13:24
92	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:14:02	2026-10-12 22:14:02
94	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:14:10	2026-10-12 22:14:10
95	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:14:18	2026-10-12 22:14:18
96	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:14:27	2026-10-12 22:14:27
97	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:14:36	2026-10-12 22:14:36
98	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:14:45	2026-10-12 22:14:45
99	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:14:55	2026-10-12 22:14:55
100	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:15:03	2026-10-12 22:15:03
101	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:15:12	2026-10-12 22:15:12
102	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:15:22	2026-10-12 22:15:22
103	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:15:31	2026-10-12 22:15:31
104	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:15:42	2026-10-12 22:15:42
105	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:15:52	2026-10-12 22:15:52
106	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:16:01	2026-10-12 22:16:01
107	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:16:10	2026-10-12 22:16:10
108	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:16:19	2026-10-12 22:16:19
109	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:16:29	2026-10-12 22:16:29
110	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:16:37	2026-10-12 22:16:37
111	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:16:46	2026-10-12 22:16:46
112	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:16:56	2026-10-12 22:16:56
114	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:17:42	2026-10-12 22:17:42
116	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:17:48	2026-10-12 22:17:48
117	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:17:54	2026-10-12 22:17:54
119	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:18:00	2026-10-12 22:18:00
121	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:18:06	2026-10-12 22:18:06
123	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:18:11	2026-10-12 22:18:11
125	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:18:15	2026-10-12 22:18:15
127	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:18:19	2026-10-12 22:18:19
129	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:18:25	2026-10-12 22:18:25
131	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:18:30	2026-10-12 22:18:30
133	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:18:35	2026-10-12 22:18:35
137	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:18:56	2026-10-12 22:18:56
138	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:19:01	2026-10-12 22:19:01
139	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:19:07	2026-10-12 22:19:07
140	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:19:13	2026-10-12 22:19:13
141	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:19:19	2026-10-12 22:19:19
142	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:19:24	2026-10-12 22:19:24
143	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:19:38	2026-10-12 22:19:38
145	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:19:44	2026-10-12 22:19:44
150	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:20:46	2026-10-12 22:20:46
152	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:20:51	2026-10-12 22:20:51
154	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:20:57	2026-10-12 22:20:57
156	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:21:03	2026-10-12 22:21:03
158	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:21:09	2026-10-12 22:21:09
160	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:21:13	2026-10-12 22:21:13
162	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:21:18	2026-10-12 22:21:18
164	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:21:22	2026-10-12 22:21:22
166	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:21:27	2026-10-12 22:21:27
167	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:21:32	2026-10-12 22:21:32
168	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:21:37	2026-10-12 22:21:37
169	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:21:42	2026-10-12 22:21:42
170	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:21:48	2026-10-12 22:21:48
171	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:21:53	2026-10-12 22:21:53
172	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:21:59	2026-10-12 22:21:59
173	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:22:04	2026-10-12 22:22:04
174	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:22:10	2026-10-12 22:22:10
175	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:22:17	2026-10-12 22:22:17
177	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:22:45	2026-10-12 22:22:45
179	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:22:53	2026-10-12 22:22:53
181	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:23:01	2026-10-12 22:23:01
184	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:23:16	2026-10-12 22:23:16
185	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:23:42	2026-10-12 22:23:42
186	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:24:02	2026-10-12 22:24:02
187	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:24:12	2026-10-12 22:24:12
189	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:24:51	2026-10-12 22:24:51
191	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:25:00	2026-10-12 22:25:00
193	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:25:08	2026-10-12 22:25:08
195	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:25:16	2026-10-12 22:25:16
197	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:25:24	2026-10-12 22:25:24
198	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:25:30	2026-10-12 22:25:30
199	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:25:38	2026-10-12 22:25:38
200	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:25:46	2026-10-12 22:25:46
201	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:25:55	2026-10-12 22:25:55
202	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:26:04	2026-10-12 22:26:04
203	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:26:19	2026-10-12 22:26:19
205	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:26:24	2026-10-12 22:26:24
207	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:26:30	2026-10-12 22:26:30
208	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:27:12	2026-10-12 22:27:12
210	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:27:17	2026-10-12 22:27:17
212	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:28:02	2026-10-12 22:28:02
214	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:28:09	2026-10-12 22:28:09
216	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:28:15	2026-10-12 22:28:15
218	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:28:21	2026-10-12 22:28:21
220	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:28:26	2026-10-12 22:28:26
222	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:28:32	2026-10-12 22:28:32
224	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:28:37	2026-10-12 22:28:37
228	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:28:47	2026-10-12 22:28:47
232	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:28:57	2026-10-12 22:28:57
236	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:29:07	2026-10-12 22:29:07
244	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:29:31	2026-10-12 22:29:31
246	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:29:37	2026-10-12 22:29:37
248	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:29:41	2026-10-12 22:29:41
250	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:29:46	2026-10-12 22:29:46
252	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:29:50	2026-10-12 22:29:50
254	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:29:55	2026-10-12 22:29:55
256	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:30:00	2026-10-12 22:30:00
258	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:30:05	2026-10-12 22:30:05
259	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:30:09	2026-10-12 22:30:09
260	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:30:15	2026-10-12 22:30:15
261	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:30:20	2026-10-12 22:30:20
262	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:30:26	2026-10-12 22:30:26
263	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:30:32	2026-10-12 22:30:32
264	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:30:38	2026-10-12 22:30:38
265	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:30:44	2026-10-12 22:30:44
266	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:30:49	2026-10-12 22:30:49
267	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:30:55	2026-10-12 22:30:55
268	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:31:01	2026-10-12 22:31:01
269	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:31:07	2026-10-12 22:31:07
270	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:31:12	2026-10-12 22:31:12
271	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:31:17	2026-10-12 22:31:17
272	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:31:23	2026-10-12 22:31:23
273	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:31:28	2026-10-12 22:31:28
275	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:31:38	2026-10-12 22:31:38
276	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:31:43	2026-10-12 22:31:43
277	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:31:48	2026-10-12 22:31:48
278	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:31:54	2026-10-12 22:31:54
279	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:32:00	2026-10-12 22:32:00
283	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:32:47	2026-10-12 22:32:47
285	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:32:53	2026-10-12 22:32:53
287	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:32:58	2026-10-12 22:32:58
289	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:33:03	2026-10-12 22:33:03
291	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:33:08	2026-10-12 22:33:08
293	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:33:13	2026-10-12 22:33:13
295	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:33:18	2026-10-12 22:33:18
297	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:33:22	2026-10-12 22:33:22
299	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:33:27	2026-10-12 22:33:27
300	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:33:31	2026-10-12 22:33:31
301	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:33:36	2026-10-12 22:33:36
302	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:33:42	2026-10-12 22:33:42
303	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:33:47	2026-10-12 22:33:47
304	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:33:52	2026-10-12 22:33:52
305	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:33:58	2026-10-12 22:33:58
306	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:34:03	2026-10-12 22:34:03
307	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:34:09	2026-10-12 22:34:09
308	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:34:14	2026-10-12 22:34:14
309	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:34:20	2026-10-12 22:34:20
310	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:35:00	2026-10-12 22:35:00
312	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:35:06	2026-10-12 22:35:06
316	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:35:18	2026-10-12 22:35:18
318	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:35:24	2026-10-12 22:35:24
322	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:35:33	2026-10-12 22:35:33
324	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:35:38	2026-10-12 22:35:38
314	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:35:12	2026-10-12 22:35:12
320	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:35:28	2026-10-12 22:35:28
326	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:35:42	2026-10-12 22:35:42
328	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:35:47	2026-10-12 22:35:47
330	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:35:52	2026-10-12 22:35:52
331	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:35:57	2026-10-12 22:35:57
332	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:36:04	2026-10-12 22:36:04
333	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:36:09	2026-10-12 22:36:09
334	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:36:14	2026-10-12 22:36:14
335	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:36:19	2026-10-12 22:36:19
336	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:36:25	2026-10-12 22:36:25
337	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:36:30	2026-10-12 22:36:30
338	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:36:35	2026-10-12 22:36:35
339	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:36:41	2026-10-12 22:36:41
341	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:37:08	2026-10-12 22:37:08
343	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:37:14	2026-10-12 22:37:14
345	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:37:20	2026-10-12 22:37:20
347	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:37:26	2026-10-12 22:37:26
349	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:37:31	2026-10-12 22:37:31
350	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:37:36	2026-10-12 22:37:36
351	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:37:41	2026-10-12 22:37:41
352	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:37:46	2026-10-12 22:37:46
353	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:37:51	2026-10-12 22:37:51
354	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:37:55	2026-10-12 22:37:55
355	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:38:21	2026-10-12 22:38:21
358	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:38:27	2026-10-12 22:38:27
359	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:38:34	2026-10-12 22:38:34
361	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:38:40	2026-10-12 22:38:40
363	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:38:46	2026-10-12 22:38:46
370	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:44:56	2026-10-12 22:44:56
372	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:45:01	2026-10-12 22:45:01
374	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:45:07	2026-10-12 22:45:07
376	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:45:12	2026-10-12 22:45:12
378	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:45:18	2026-10-12 22:45:18
380	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:45:24	2026-10-12 22:45:24
382	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:45:28	2026-10-12 22:45:28
384	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:45:33	2026-10-12 22:45:33
386	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:45:38	2026-10-12 22:45:38
388	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:45:43	2026-10-12 22:45:43
390	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:45:48	2026-10-12 22:45:48
391	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:45:53	2026-10-12 22:45:53
392	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:45:59	2026-10-12 22:45:59
393	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:46:06	2026-10-12 22:46:06
394	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:46:11	2026-10-12 22:46:11
395	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:46:16	2026-10-12 22:46:16
396	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:46:21	2026-10-12 22:46:21
397	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:46:26	2026-10-12 22:46:26
398	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:46:32	2026-10-12 22:46:32
399	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:46:38	2026-10-12 22:46:38
401	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:46:46	2026-10-12 22:46:46
403	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:47:23	2026-10-12 22:47:23
405	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:47:30	2026-10-12 22:47:30
407	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:47:36	2026-10-12 22:47:36
409	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:47:41	2026-10-12 22:47:41
421	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:48:24	2026-10-12 22:48:24
422	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:48:49	2026-10-12 22:48:49
423	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:48:55	2026-10-12 22:48:55
424	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:49:01	2026-10-12 22:49:01
425	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:49:06	2026-10-12 22:49:06
431	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:50:31	2026-10-12 22:50:31
433	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:50:37	2026-10-12 22:50:37
435	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:50:42	2026-10-12 22:50:42
437	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:50:46	2026-10-12 22:50:46
439	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:50:51	2026-10-12 22:50:51
441	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:50:56	2026-10-12 22:50:56
443	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:51:00	2026-10-12 22:51:00
447	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:51:11	2026-10-12 22:51:11
448	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:51:15	2026-10-12 22:51:15
450	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:51:22	2026-10-12 22:51:22
453	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:51:28	2026-10-12 22:51:28
454	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:51:34	2026-10-12 22:51:34
456	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:51:39	2026-10-12 22:51:39
458	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:51:44	2026-10-12 22:51:44
460	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:51:49	2026-10-12 22:51:49
488	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:54:06	2026-10-12 22:54:06
489	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:54:11	2026-10-12 22:54:11
490	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:54:16	2026-10-12 22:54:16
491	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:54:21	2026-10-12 22:54:21
413	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:47:52	2026-10-12 22:47:52
415	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:47:57	2026-10-12 22:47:57
427	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:50:20	2026-10-12 22:50:20
429	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:50:25	2026-10-12 22:50:25
445	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:51:05	2026-10-12 22:51:05
462	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:51:54	2026-10-12 22:51:54
464	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:51:58	2026-10-12 22:51:58
465	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:52:04	2026-10-12 22:52:04
466	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:52:09	2026-10-12 22:52:09
467	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:52:14	2026-10-12 22:52:14
468	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:52:19	2026-10-12 22:52:19
469	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:52:25	2026-10-12 22:52:25
470	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:52:31	2026-10-12 22:52:31
471	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:52:36	2026-10-12 22:52:36
472	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:52:42	2026-10-12 22:52:42
473	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:52:48	2026-10-12 22:52:48
474	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:52:53	2026-10-12 22:52:53
475	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:52:58	2026-10-12 22:52:58
476	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:53:03	2026-10-12 22:53:03
477	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:53:09	2026-10-12 22:53:09
478	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:53:14	2026-10-12 22:53:14
479	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:53:20	2026-10-12 22:53:20
480	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:53:25	2026-10-12 22:53:25
481	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:53:30	2026-10-12 22:53:30
482	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:53:36	2026-10-12 22:53:36
509	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:56:07	2026-10-12 22:56:07
511	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:56:11	2026-10-12 22:56:11
513	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:56:16	2026-10-12 22:56:16
515	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:56:20	2026-10-12 22:56:20
517	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:56:28	2026-10-12 22:56:28
519	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:56:33	2026-10-12 22:56:33
520	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:56:38	2026-10-12 22:56:38
521	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:56:44	2026-10-12 22:56:44
522	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:56:49	2026-10-12 22:56:49
523	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:56:55	2026-10-12 22:56:55
524	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:57:00	2026-10-12 22:57:00
525	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:57:06	2026-10-12 22:57:06
526	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:57:12	2026-10-12 22:57:12
527	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:57:17	2026-10-12 22:57:17
528	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:57:22	2026-10-12 22:57:22
529	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:57:27	2026-10-12 22:57:27
530	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:57:32	2026-10-12 22:57:32
531	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:57:38	2026-10-12 22:57:38
532	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:57:43	2026-10-12 22:57:43
533	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:57:49	2026-10-12 22:57:49
535	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:58:37	2026-10-12 22:58:37
537	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:58:43	2026-10-12 22:58:43
539	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:58:49	2026-10-12 22:58:49
541	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:58:55	2026-10-12 22:58:55
543	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:59:01	2026-10-12 22:59:01
545	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:59:05	2026-10-12 22:59:05
547	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:59:10	2026-10-12 22:59:10
549	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:59:15	2026-10-12 22:59:15
551	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:59:20	2026-10-12 22:59:20
553	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:59:25	2026-10-12 22:59:25
555	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:59:30	2026-10-12 22:59:30
557	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:59:35	2026-10-12 22:59:35
558	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:59:41	2026-10-12 22:59:41
559	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:59:46	2026-10-12 22:59:46
560	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:59:52	2026-10-12 22:59:52
561	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 22:59:58	2026-10-12 22:59:58
562	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:00:04	2026-10-12 23:00:04
563	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:00:12	2026-10-12 23:00:12
564	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:00:19	2026-10-12 23:00:19
565	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:00:25	2026-10-12 23:00:25
566	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:00:31	2026-10-12 23:00:31
567	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:00:36	2026-10-12 23:00:36
568	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:00:42	2026-10-12 23:00:42
569	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:00:48	2026-10-12 23:00:48
570	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:02:01	2026-10-12 23:02:01
572	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:02:07	2026-10-12 23:02:07
575	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:02:15	2026-10-12 23:02:15
576	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:02:20	2026-10-12 23:02:20
578	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:02:26	2026-10-12 23:02:26
580	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:02:31	2026-10-12 23:02:31
582	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:02:36	2026-10-12 23:02:36
584	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:02:41	2026-10-12 23:02:41
586	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:02:48	2026-10-12 23:02:48
588	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:02:53	2026-10-12 23:02:53
590	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:02:58	2026-10-12 23:02:58
593	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:03:07	2026-10-12 23:03:07
595	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:03:14	2026-10-12 23:03:14
597	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:03:20	2026-10-12 23:03:20
599	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:03:26	2026-10-12 23:03:26
601	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:03:32	2026-10-12 23:03:32
602	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:03:37	2026-10-12 23:03:37
603	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:03:41	2026-10-12 23:03:41
624	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:05:52	2026-10-12 23:05:52
627	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:06:06	2026-10-12 23:06:06
628	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:06:14	2026-10-12 23:06:14
629	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:06:23	2026-10-12 23:06:23
630	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:06:57	2026-10-12 23:06:57
632	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:07:02	2026-10-12 23:07:02
634	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:07:07	2026-10-12 23:07:07
636	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:07:12	2026-10-12 23:07:12
638	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:07:18	2026-10-12 23:07:18
640	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:07:22	2026-10-12 23:07:22
642	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:07:26	2026-10-12 23:07:26
644	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:07:31	2026-10-12 23:07:31
645	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:07:35	2026-10-12 23:07:35
646	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:07:40	2026-10-12 23:07:40
647	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:07:45	2026-10-12 23:07:45
648	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:07:49	2026-10-12 23:07:49
649	\N	LOGIN	Authentication	Login blocked by rate limit for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:07:53	2026-10-12 23:07:53
650	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:07:59	2026-10-12 23:07:59
652	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:08:04	2026-10-12 23:08:04
654	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:08:45	2026-10-12 23:08:45
656	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:09:04	2026-10-12 23:09:04
658	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:09:11	2026-10-12 23:09:11
660	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:09:23	2026-10-12 23:09:23
661	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:09:30	2026-10-12 23:09:30
662	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:09:38	2026-10-12 23:09:38
663	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:09:47	2026-10-12 23:09:47
664	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:09:55	2026-10-12 23:09:55
665	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:10:04	2026-10-12 23:10:04
666	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:10:13	2026-10-12 23:10:13
667	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:10:21	2026-10-12 23:10:21
669	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:11:32	2026-10-12 23:11:32
671	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:11:39	2026-10-12 23:11:39
673	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:11:47	2026-10-12 23:11:47
675	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:11:54	2026-10-12 23:11:54
676	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:12:09	2026-10-12 23:12:09
678	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:12:18	2026-10-12 23:12:18
680	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:12:26	2026-10-12 23:12:26
682	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:12:35	2026-10-12 23:12:35
684	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:12:43	2026-10-12 23:12:43
686	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:12:52	2026-10-12 23:12:52
688	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:13:00	2026-10-12 23:13:00
690	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:13:09	2026-10-12 23:13:09
692	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:13:19	2026-10-12 23:13:19
694	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:13:27	2026-10-12 23:13:27
696	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:13:35	2026-10-12 23:13:35
698	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"103.60.171.134"}	2026-10-12 23:13:43	2026-10-12 23:13:43
700	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"119.94.197.193"}	2026-10-12 23:22:00	2026-10-12 23:22:00
701	\N	LOGIN	Authentication	Failed login attempt for donoharmbygrd@gmail.com.	Failed	{"email":"donoharmbygrd@gmail.com","ip":"119.94.197.193"}	2026-10-12 23:22:19	2026-10-12 23:22:19
704	\N	LOGIN	Authentication	Logged in as donoharmbygrd@gmail.com.	Success	{"email":"donoharmbygrd@gmail.com","ip":"136.158.79.70"}	2026-10-12 23:27:11	2026-10-12 23:27:11
705	\N	PRIVACY_NOTICE_ACKNOWLEDGED	Privacy Notice	Acknowledged Privacy Notice version 1.1.	Success	{"privacy_notice_version":"1.1","ip":"136.158.79.70"}	2026-10-12 23:27:21	2026-10-12 23:27:21
1004	41	DELETE	Employees	Deleted employee Jei Pastrana (238041).	Success	{"employee_id":"238041","email":"donoharmbygrd@gmail.com","ip":"136.158.79.70"}	2026-10-13 21:34:54	2026-10-13 21:34:54
1126	41	CREATE	Leave Management	Leave file processed — 4 new, 0 updated, 256 skipped, 17 attendance day(s) auto-fulfilled.	Success	{"original_filename":"Jan-May 2026.xlsx","imported":4,"updated":0,"skipped":256,"ip":"127.0.0.1"}	2026-10-15 23:26:57	2026-10-15 23:26:57
\.


--
-- Data for Name: admin_configs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.admin_configs (id, key, value, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: announcement_notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.announcement_notifications (id, announcement_id, user_id, is_read, read_at, created_at, updated_at, redirect_url) FROM stdin;
152	116	72	f	\N	2026-11-23 11:47:24	2026-11-23 11:47:24	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
6	3	40	f	\N	2026-10-12 21:21:53	2026-10-12 21:21:53	http://127.0.0.1:8000/hr/schedule-management
7	3	42	f	\N	2026-10-12 21:21:53	2026-10-12 21:21:53	http://127.0.0.1:8000/hr/schedule-management
154	118	74	f	\N	2026-11-23 15:00:55	2026-11-23 15:00:55	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
9	5	40	f	\N	2026-10-12 21:24:39	2026-10-12 21:24:39	http://127.0.0.1:8000/hr/employees/profile?employee=3
10	5	42	f	\N	2026-10-12 21:24:39	2026-10-12 21:24:39	http://127.0.0.1:8000/hr/employees/profile?employee=3
11	6	40	f	\N	2026-10-12 21:24:42	2026-10-12 21:24:42	http://127.0.0.1:8000/hr/employees/profile?employee=3
156	120	74	f	\N	2026-11-23 15:14:47	2026-11-23 15:14:47	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
157	121	75	f	\N	2026-11-23 15:16:45	2026-11-23 15:16:45	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
15	9	40	f	\N	2026-10-12 21:31:47	2026-10-12 21:31:47	http://127.0.0.1:8000/hr/schedule-management
16	9	42	f	\N	2026-10-12 21:31:47	2026-10-12 21:31:47	http://127.0.0.1:8000/hr/schedule-management
159	123	78	f	\N	2026-11-23 15:49:42	2026-11-23 15:49:42	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
18	11	40	f	\N	2026-10-12 21:32:39	2026-10-12 21:32:39	http://127.0.0.1:8000/hr/wfh-monitoring
19	11	42	t	2026-10-12 21:32:49	2026-10-12 21:32:39	2026-10-12 21:32:49	http://127.0.0.1:8000/hr/wfh-monitoring
12	6	42	t	2026-10-12 21:33:06	2026-10-12 21:24:42	2026-10-12 21:33:06	http://127.0.0.1:8000/hr/employees/profile?employee=3
161	125	88	f	\N	2026-11-24 11:02:33	2026-11-24 11:02:33	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
163	127	86	f	\N	2026-11-24 11:31:56	2026-11-24 11:31:56	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
22	14	40	f	\N	2026-10-13 15:48:45	2026-10-13 15:48:45	https://nuhris.com/hr/schedule-management
23	14	42	f	\N	2026-10-13 15:48:45	2026-10-13 15:48:45	https://nuhris.com/hr/schedule-management
164	128	99	f	\N	2026-11-24 11:32:26	2026-11-24 11:32:26	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
166	130	100	f	\N	2026-11-24 11:36:53	2026-11-24 11:36:53	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
168	132	73	f	\N	2026-11-24 11:45:03	2026-11-24 11:45:03	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
170	134	102	f	\N	2026-11-24 11:55:56	2026-11-24 11:55:56	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
173	137	107	f	\N	2026-11-24 12:02:27	2026-11-24 12:02:27	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
175	139	108	f	\N	2026-11-24 13:48:36	2026-11-24 13:48:36	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
177	141	110	f	\N	2026-11-24 13:51:39	2026-11-24 13:51:39	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
178	142	111	f	\N	2026-11-24 13:53:21	2026-11-24 13:53:21	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
31	22	40	f	\N	2026-10-13 18:35:15	2026-10-13 18:35:15	http://127.0.0.1:8000/hr/employees
32	22	42	t	2026-10-13 18:35:30	2026-10-13 18:35:15	2026-10-13 18:35:30	http://127.0.0.1:8000/hr/employees
33	23	40	f	\N	2026-10-13 22:03:39	2026-10-13 22:03:39	https://nuhris.com/hr/schedule-management
34	23	42	f	\N	2026-10-13 22:03:39	2026-10-13 22:03:39	https://nuhris.com/hr/schedule-management
35	24	40	f	\N	2026-10-13 22:05:38	2026-10-13 22:05:38	https://nuhris.com/hr/schedule-management
36	24	42	f	\N	2026-10-13 22:05:38	2026-10-13 22:05:38	https://nuhris.com/hr/schedule-management
37	25	40	f	\N	2026-10-13 22:10:23	2026-10-13 22:10:23	https://nuhris.com/hr/schedule-management
38	25	42	f	\N	2026-10-13 22:10:23	2026-10-13 22:10:23	https://nuhris.com/hr/schedule-management
180	144	96	f	\N	2026-11-24 13:55:48	2026-11-24 13:55:48	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
181	145	113	f	\N	2026-11-24 13:56:31	2026-11-24 13:56:31	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
183	147	115	f	\N	2026-11-24 14:03:17	2026-11-24 14:03:17	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
42	29	40	f	\N	2026-10-13 23:13:25	2026-10-13 23:13:25	https://nuhris.com/hr/schedule-management
43	29	42	t	2026-10-13 23:13:41	2026-10-13 23:13:25	2026-10-13 23:13:41	https://nuhris.com/hr/schedule-management
186	150	120	f	\N	2026-11-25 14:01:55	2026-11-25 14:01:55	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
188	152	121	f	\N	2026-11-25 14:12:32	2026-11-25 14:12:32	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
190	154	250	f	\N	2026-11-25 14:26:18	2026-11-25 14:26:18	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
191	155	243	f	\N	2026-11-25 14:27:26	2026-11-25 14:27:26	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
66	52	42	f	\N	2026-10-14 14:27:39	2026-10-14 14:27:39	https://nuhris.com/hr/schedule-management
67	52	40	f	\N	2026-10-14 14:27:39	2026-10-14 14:27:39	https://nuhris.com/hr/schedule-management
69	53	40	f	\N	2026-10-14 15:01:38	2026-10-14 15:01:38	https://nuhris.com/hr/employees/profile?employee=12
68	53	42	t	2026-10-14 15:03:17	2026-10-14 15:01:38	2026-10-14 15:03:17	https://nuhris.com/hr/employees/profile?employee=12
71	55	42	f	\N	2026-10-15 23:17:34	2026-10-15 23:17:34	http://127.0.0.1:8000/hr/schedule-management
73	55	40	f	\N	2026-10-15 23:17:34	2026-10-15 23:17:34	http://127.0.0.1:8000/hr/schedule-management
79	60	42	f	\N	2026-10-15 23:47:56	2026-10-15 23:47:56	https://nuhris.com/hr/schedule-management
80	60	40	f	\N	2026-10-15 23:47:56	2026-10-15 23:47:56	https://nuhris.com/hr/schedule-management
82	61	42	f	\N	2026-10-15 23:49:11	2026-10-15 23:49:11	https://nuhris.com/hr/schedule-management
83	61	40	f	\N	2026-10-15 23:49:11	2026-10-15 23:49:11	https://nuhris.com/hr/schedule-management
87	64	42	f	\N	2026-10-16 00:04:32	2026-10-16 00:04:32	https://nuhris.com/hr/schedule-management
88	64	40	f	\N	2026-10-16 00:04:32	2026-10-16 00:04:32	https://nuhris.com/hr/schedule-management
151	115	72	f	\N	2026-11-23 11:46:22	2026-11-23 11:46:22	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
91	66	42	f	\N	2026-10-16 10:49:16	2026-10-16 10:49:16	http://127.0.0.1:8000/hr/schedule-management
92	66	40	f	\N	2026-10-16 10:49:16	2026-10-16 10:49:16	http://127.0.0.1:8000/hr/schedule-management
153	117	72	f	\N	2026-11-23 11:51:53	2026-11-23 11:51:53	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
155	119	74	f	\N	2026-11-23 15:09:51	2026-11-23 15:09:51	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
158	122	77	f	\N	2026-11-23 15:38:06	2026-11-23 15:38:06	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
160	124	79	f	\N	2026-11-23 16:00:51	2026-11-23 16:00:51	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
162	126	85	f	\N	2026-11-24 11:08:10	2026-11-24 11:08:10	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
165	129	89	f	\N	2026-11-24 11:34:04	2026-11-24 11:34:04	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
167	131	98	f	\N	2026-11-24 11:40:53	2026-11-24 11:40:53	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
99	72	42	f	\N	2026-10-16 11:08:04	2026-10-16 11:08:04	http://127.0.0.1:8000/hr/schedule-management
100	72	40	f	\N	2026-10-16 11:08:04	2026-10-16 11:08:04	http://127.0.0.1:8000/hr/schedule-management
169	133	76	f	\N	2026-11-24 11:53:31	2026-11-24 11:53:31	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
171	135	87	f	\N	2026-11-24 11:58:54	2026-11-24 11:58:54	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
172	136	105	f	\N	2026-11-24 11:59:52	2026-11-24 11:59:52	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
174	138	101	f	\N	2026-11-24 13:39:27	2026-11-24 13:39:27	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
176	140	109	f	\N	2026-11-24 13:50:12	2026-11-24 13:50:12	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
179	143	112	f	\N	2026-11-24 13:54:52	2026-11-24 13:54:52	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
107	78	42	f	\N	2026-10-16 11:14:36	2026-10-16 11:14:36	http://127.0.0.1:8000/hr/schedule-management
108	78	40	f	\N	2026-10-16 11:14:36	2026-10-16 11:14:36	http://127.0.0.1:8000/hr/schedule-management
182	146	114	f	\N	2026-11-24 13:58:34	2026-11-24 13:58:34	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
184	148	81	f	\N	2026-11-24 14:03:48	2026-11-24 14:03:48	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
185	149	116	f	\N	2026-11-24 14:05:02	2026-11-24 14:05:02	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
187	151	91	f	\N	2026-11-25 14:05:37	2026-11-25 14:05:37	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
189	153	186	f	\N	2026-11-25 14:14:34	2026-11-25 14:14:34	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
192	156	244	f	\N	2026-11-25 14:29:14	2026-11-25 14:29:14	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
115	84	42	f	\N	2026-10-16 11:25:12	2026-10-16 11:25:12	http://127.0.0.1:8000/hr/schedule-management
116	84	40	f	\N	2026-10-16 11:25:12	2026-10-16 11:25:12	http://127.0.0.1:8000/hr/schedule-management
193	157	245	f	\N	2026-11-25 14:30:39	2026-11-25 14:30:39	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
194	158	126	f	\N	2026-11-25 14:30:50	2026-11-25 14:30:50	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
195	159	246	f	\N	2026-11-25 14:31:27	2026-11-25 14:31:27	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
196	160	251	f	\N	2026-11-25 14:32:41	2026-11-25 14:32:41	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
197	161	247	f	\N	2026-11-25 14:33:19	2026-11-25 14:33:19	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
198	162	249	f	\N	2026-11-25 14:34:44	2026-11-25 14:34:44	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
199	163	130	f	\N	2026-11-25 14:55:34	2026-11-25 14:55:34	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
200	164	82	f	\N	2026-11-25 15:35:44	2026-11-25 15:35:44	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
201	165	233	f	\N	2026-11-25 15:37:31	2026-11-25 15:37:31	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
126	93	42	f	\N	2026-10-16 12:16:31	2026-10-16 12:16:31	http://127.0.0.1:8000/hr/schedule-management
127	93	40	f	\N	2026-10-16 12:16:31	2026-10-16 12:16:31	http://127.0.0.1:8000/hr/schedule-management
202	166	185	f	\N	2026-11-26 09:50:16	2026-11-26 09:50:16	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
203	167	118	f	\N	2026-11-26 09:52:12	2026-11-26 09:52:12	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
204	168	205	f	\N	2026-11-26 09:54:40	2026-11-26 09:54:40	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
205	169	206	f	\N	2026-11-26 09:55:29	2026-11-26 09:55:29	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
206	170	154	f	\N	2026-11-26 09:57:15	2026-11-26 09:57:15	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
207	171	235	f	\N	2026-11-26 09:59:58	2026-11-26 09:59:58	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
134	99	42	f	\N	2026-10-16 12:23:36	2026-10-16 12:23:36	http://127.0.0.1:8000/hr/schedule-management
208	172	207	f	\N	2026-11-26 10:01:07	2026-11-26 10:01:07	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
209	173	141	f	\N	2026-11-26 10:03:45	2026-11-26 10:03:45	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
210	174	248	f	\N	2026-11-26 10:05:30	2026-11-26 10:05:30	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
211	175	119	f	\N	2026-11-26 10:23:46	2026-11-26 10:23:46	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
212	176	187	f	\N	2026-11-26 10:26:17	2026-11-26 10:26:17	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
135	99	40	t	2026-11-17 14:16:17	2026-10-16 12:23:36	2026-11-17 14:16:17	http://127.0.0.1:8000/hr/schedule-management
213	177	208	f	\N	2026-11-26 10:28:25	2026-11-26 10:28:25	https://melodic-darkorchid-mongoose-59.hostingersite.com/employee/attendance-dtr
\.


--
-- Data for Name: announcements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.announcements (id, title, content, priority, target_user_type, published_at, expires_at, is_published, created_by, created_at, updated_at, deleted_at, target_office, target_employee_type, target_department_id, target_ranking, target_user_id, type) FROM stdin;
1	Sample Announcement	Sample only please disregard	high	\N	2026-10-12 21:19:15	2026-10-19	t	42	2026-10-12 21:19:15	2026-10-12 21:19:15	\N	\N	faculty	\N	\N	\N	announcement
2	Sample Expired Announcement	Expired Only	high	\N	2026-10-12 21:19:53	2026-10-08	t	42	2026-10-12 21:19:53	2026-10-12 21:19:53	\N	\N	\N	\N	\N	\N	announcement
4	Schedule approved	Your weekly schedule for 1st Term  was approved by HR.	medium	\N	2026-10-12 21:22:48	\N	t	42	2026-10-12 21:22:48	2026-10-12 21:22:48	\N	\N	employee	\N	\N	\N	notification
7	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026).	high	\N	2026-10-12 21:26:06	\N	t	42	2026-10-12 21:26:06	2026-10-12 21:26:06	\N	\N	employee	\N	\N	\N	notification
8	Schedule cleared	Your approved weekly schedule for term "1st Term" was cleared by HR. Please resubmit a revised schedule.	medium	\N	2026-10-12 21:31:02	\N	t	42	2026-10-12 21:31:02	2026-10-12 21:31:02	\N	\N	employee	\N	\N	\N	notification
10	Schedule approved	Your weekly schedule for 1st Term  was approved by HR.	medium	\N	2026-10-12 21:32:05	\N	t	42	2026-10-12 21:32:05	2026-10-12 21:32:05	\N	\N	employee	\N	\N	\N	notification
12	Schedule updated by Admin	Your weekly schedule for term "1st Term" was updated by the administrator. Please check your schedule.	high	\N	2026-10-12 21:38:27	\N	t	41	2026-10-12 21:38:27	2026-10-12 21:38:27	\N	\N	employee	\N	\N	\N	notification
13	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026).	high	\N	2026-10-12 21:40:09	\N	t	41	2026-10-12 21:40:09	2026-10-12 21:40:09	\N	\N	employee	\N	\N	\N	notification
15	Schedule approved	Your weekly schedule for 1st Term  was approved by HR.	medium	\N	2026-10-13 15:49:08	\N	t	42	2026-10-13 15:49:08	2026-10-13 15:49:08	\N	\N	employee	\N	\N	\N	notification
16	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 18, 2026).	high	\N	2026-10-13 16:18:18	\N	t	42	2026-10-13 16:18:18	2026-10-13 16:18:18	\N	\N	employee	\N	\N	\N	notification
17	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 04, 2026).	high	\N	2026-10-13 16:25:09	\N	t	42	2026-10-13 16:25:09	2026-10-13 16:25:09	\N	\N	employee	\N	\N	\N	notification
18	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 18, 2026).	high	\N	2026-10-13 16:25:10	\N	t	42	2026-10-13 16:25:10	2026-10-13 16:25:10	\N	\N	employee	\N	\N	\N	notification
19	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026).	high	\N	2026-10-13 18:25:20	\N	t	42	2026-10-13 18:25:20	2026-10-13 18:25:20	\N	\N	employee	\N	\N	\N	notification
22	Employee Profile Updated	Ar-Ar Da Divitan updated their profile: name: Reymark Natividad → Ar-Ar Da Divitan.	medium	2	2026-10-13 18:35:14	\N	t	\N	2026-10-13 18:35:14	2026-10-13 18:35:14	\N	\N	\N	\N	\N	\N	notification
20	Congratulations on Your Regular Employment Status!	Congratulations, Reymark Natividad! Your employment status has been updated to Regular. We appreciate your continued commitment and contributions to NU HRIS.	high	\N	2026-10-13 18:29:25	\N	t	41	2026-10-13 18:29:25	2026-10-13 18:29:25	\N	\N	\N	\N	\N	\N	notification
21	Congratulations on Your Regular Employment Status!	Congratulations, Reymark Natividad! Your employment status has been updated to Regular. We appreciate your continued commitment and contributions to NU Lipa.	high	\N	2026-10-13 18:31:05	\N	t	41	2026-10-13 18:31:05	2026-10-13 18:31:05	\N	\N	\N	\N	\N	\N	notification
3	Jei Pastrana submitted a weekly schedule	Jei Pastrana submitted a weekly schedule for term "1st Term" and is waiting for HR approval.	medium	\N	2026-10-12 21:21:53	\N	t	\N	2026-10-12 21:21:53	2026-10-12 21:21:53	\N	\N	hr	\N	\N	\N	notification
5	New degree submission	Jei Pastrana submitted a Undergraduate Degree for HR review.	medium	\N	2026-10-12 21:24:38	\N	t	\N	2026-10-12 21:24:38	2026-10-12 21:24:38	\N	\N	\N	\N	\N	\N	notification
6	New degree submission	Jei Pastrana submitted a Master's Degree for HR review.	medium	\N	2026-10-12 21:24:42	\N	t	\N	2026-10-12 21:24:42	2026-10-12 21:24:42	\N	\N	\N	\N	\N	\N	notification
9	Jei Pastrana submitted a weekly schedule	Jei Pastrana submitted a weekly schedule for term "1st Term" and is waiting for HR approval.	medium	\N	2026-10-12 21:31:46	\N	t	\N	2026-10-12 21:31:46	2026-10-12 21:31:46	\N	\N	hr	\N	\N	\N	notification
11	New WFH monitoring link submitted	Jei Pastrana submitted a WFH monitoring link for October 05, 2026 and is waiting for HR review.	medium	2	2026-10-12 21:32:38	\N	t	\N	2026-10-12 21:32:38	2026-10-12 21:32:38	\N	\N	\N	\N	\N	\N	notification
14	Jere Padua submitted a weekly schedule	Jere Padua submitted a weekly schedule for term "1st Term" and is waiting for HR approval.	medium	\N	2026-10-13 15:48:44	\N	t	\N	2026-10-13 15:48:44	2026-10-13 15:48:44	\N	\N	hr	\N	\N	\N	notification
26	Schedule approved	Your weekly schedule for 1st Term  was approved by HR.	medium	\N	2026-10-13 22:10:56	\N	t	42	2026-10-13 22:10:56	2026-10-13 22:10:56	\N	\N	employee	\N	\N	\N	notification
27	Schedule approved	Your weekly schedule for 1st Term  was approved by HR.	medium	\N	2026-10-13 22:11:08	\N	t	42	2026-10-13 22:11:08	2026-10-13 22:11:08	\N	\N	employee	\N	\N	\N	notification
28	Schedule approved	Your weekly schedule for 1st Term  was approved by HR.	medium	\N	2026-10-13 22:11:21	\N	t	42	2026-10-13 22:11:21	2026-10-13 22:11:21	\N	\N	employee	\N	\N	\N	notification
23	Jerimaiah Padua submitted a weekly schedule	Jerimaiah Padua submitted a weekly schedule for term "1st Term" and is waiting for HR approval.	medium	\N	2026-10-13 22:03:39	\N	t	\N	2026-10-13 22:03:39	2026-10-13 22:03:39	\N	\N	hr	\N	\N	\N	notification
30	Schedule approved	Your weekly schedule for 1st Term  was approved by HR.	medium	\N	2026-10-13 23:13:56	\N	t	42	2026-10-13 23:13:56	2026-10-13 23:13:56	\N	\N	employee	\N	\N	\N	notification
31	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026).	high	\N	2026-10-13 23:28:18	\N	t	41	2026-10-13 23:28:18	2026-10-13 23:28:18	\N	\N	employee	\N	\N	\N	notification
24	Jei Pastrana submitted a weekly schedule	Jei Pastrana submitted a weekly schedule for term "1st Term" and is waiting for HR approval.	medium	\N	2026-10-13 22:05:38	\N	t	\N	2026-10-13 22:05:38	2026-10-13 22:05:38	\N	\N	hr	\N	\N	\N	notification
25	Reymark Natividad submitted a weekly schedule	Reymark Natividad submitted a weekly schedule for term "1st Term" and is waiting for HR approval.	medium	\N	2026-10-13 22:10:23	\N	t	\N	2026-10-13 22:10:23	2026-10-13 22:10:23	\N	\N	hr	\N	\N	\N	notification
32	Please Upload your Schedule! (Sample)	Sample	medium	\N	2026-10-13 23:58:42	2026-10-16	t	42	2026-10-13 23:58:42	2026-10-13 23:58:42	\N	\N	\N	\N	\N	\N	announcement
34	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 11, 2026).	high	\N	2026-10-14 09:18:40	\N	t	42	2026-10-14 09:18:40	2026-10-14 09:18:40	\N	\N	employee	\N	\N	\N	notification
35	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 10, 2026).	high	\N	2026-10-14 09:18:41	\N	t	42	2026-10-14 09:18:41	2026-10-14 09:18:41	\N	\N	employee	\N	\N	\N	notification
36	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to August 29, 2026).	high	\N	2026-10-14 09:18:42	\N	t	42	2026-10-14 09:18:42	2026-10-14 09:18:42	\N	\N	employee	\N	\N	\N	notification
37	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 11, 2026).	high	\N	2026-10-14 09:20:16	\N	t	42	2026-10-14 09:20:16	2026-10-14 09:20:16	\N	\N	employee	\N	\N	\N	notification
38	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 10, 2026).	high	\N	2026-10-14 09:20:17	\N	t	42	2026-10-14 09:20:17	2026-10-14 09:20:17	\N	\N	employee	\N	\N	\N	notification
39	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 11, 2026).	high	\N	2026-10-14 09:43:24	\N	t	40	2026-10-14 09:43:24	2026-10-14 09:43:24	\N	\N	employee	\N	\N	\N	notification
40	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 10, 2026).	high	\N	2026-10-14 09:43:25	\N	t	40	2026-10-14 09:43:25	2026-10-14 09:43:25	\N	\N	employee	\N	\N	\N	notification
41	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to August 29, 2026).	high	\N	2026-10-14 09:43:26	\N	t	40	2026-10-14 09:43:26	2026-10-14 09:43:26	\N	\N	employee	\N	\N	\N	notification
42	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 11, 2026).	high	\N	2026-10-14 09:47:41	\N	t	40	2026-10-14 09:47:41	2026-10-14 09:47:41	\N	\N	employee	\N	\N	\N	notification
43	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 10, 2026).	high	\N	2026-10-14 09:47:42	\N	t	40	2026-10-14 09:47:42	2026-10-14 09:47:42	\N	\N	employee	\N	\N	\N	notification
44	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to August 29, 2026).	high	\N	2026-10-14 09:47:43	\N	t	40	2026-10-14 09:47:43	2026-10-14 09:47:43	\N	\N	employee	\N	\N	\N	notification
45	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 11, 2026).	high	\N	2026-10-14 09:49:33	\N	t	42	2026-10-14 09:49:33	2026-10-14 09:49:33	\N	\N	employee	\N	\N	\N	notification
46	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 10, 2026).	high	\N	2026-10-14 09:49:34	\N	t	42	2026-10-14 09:49:34	2026-10-14 09:49:34	\N	\N	employee	\N	\N	\N	notification
47	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to August 29, 2026).	high	\N	2026-10-14 09:49:34	\N	t	42	2026-10-14 09:49:34	2026-10-14 09:49:34	\N	\N	employee	\N	\N	\N	notification
48	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 11, 2026).	high	\N	2026-10-14 10:02:08	\N	t	42	2026-10-14 10:02:08	2026-10-14 10:02:08	\N	\N	employee	\N	\N	\N	notification
49	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 11, 2026).	high	\N	2026-10-14 10:03:18	\N	t	42	2026-10-14 10:03:18	2026-10-14 10:03:18	\N	\N	employee	\N	\N	\N	notification
50	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 10, 2026).	high	\N	2026-10-14 10:03:19	\N	t	42	2026-10-14 10:03:19	2026-10-14 10:03:19	\N	\N	employee	\N	\N	\N	notification
51	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to August 29, 2026).	high	\N	2026-10-14 10:03:20	\N	t	42	2026-10-14 10:03:20	2026-10-14 10:03:20	\N	\N	employee	\N	\N	\N	notification
54	Degree approved	Nulptimekeeping approved the Undergraduate Degree degree submission for Jei Pastrana.	medium	\N	2026-10-14 15:04:09	\N	t	42	2026-10-14 15:04:09	2026-10-14 15:04:09	\N	\N	employee	\N	\N	\N	notification
29	Jerimaiah Padua submitted a weekly schedule	Jerimaiah Padua submitted a weekly schedule for term "1st Term" and is waiting for HR approval.	medium	\N	2026-10-13 23:13:25	\N	t	\N	2026-10-13 23:13:25	2026-10-13 23:13:25	\N	\N	hr	\N	\N	\N	notification
33	SAMPLE ANNOUNCEMENT FOR SIR JAPZ	sample lang po!	medium	\N	2026-10-13 23:59:29	2026-10-17	t	42	2026-10-13 23:59:29	2026-10-13 23:59:29	\N	\N	\N	\N	\N	\N	announcement
52	Allainer Reyes submitted a weekly schedule	Allainer Reyes submitted a weekly schedule for term "1st Term" and is waiting for HR approval.	medium	\N	2026-10-14 14:27:39	\N	t	\N	2026-10-14 14:27:39	2026-10-14 14:27:39	\N	\N	hr	\N	\N	\N	notification
53	New degree submission	Jei Pastrana submitted a Undergraduate Degree for HR review.	medium	\N	2026-10-14 15:01:38	\N	t	\N	2026-10-14 15:01:38	2026-10-14 15:01:38	\N	\N	\N	\N	\N	\N	notification
57	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 11, 2026).	high	\N	2026-10-15 23:34:58	\N	t	41	2026-10-15 23:34:58	2026-10-15 23:34:58	\N	\N	employee	\N	\N	\N	notification
58	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 10, 2026).	high	\N	2026-10-15 23:34:59	\N	t	41	2026-10-15 23:34:59	2026-10-15 23:34:59	\N	\N	employee	\N	\N	\N	notification
59	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to August 29, 2026).	high	\N	2026-10-15 23:34:59	\N	t	41	2026-10-15 23:34:59	2026-10-15 23:34:59	\N	\N	employee	\N	\N	\N	notification
55	Jerimaiah Padua submitted a weekly schedule	Jerimaiah Padua submitted a weekly schedule for term "1st Term" and is waiting for HR approval.	medium	\N	2026-10-15 23:17:33	\N	t	\N	2026-10-15 23:17:33	2026-10-15 23:17:33	\N	\N	hr	\N	\N	\N	notification
56	Schedule approved	Your weekly schedule for 1st Term  was approved by HR.	medium	\N	2026-10-15 23:20:01	\N	t	\N	2026-10-15 23:20:01	2026-10-15 23:20:01	\N	\N	employee	\N	\N	\N	notification
60	Allainer Reyes submitted a weekly schedule	Allainer Reyes submitted a weekly schedule for term "1st Term" and is waiting for HR approval.	medium	\N	2026-10-15 23:47:55	\N	t	\N	2026-10-15 23:47:55	2026-10-15 23:47:55	\N	\N	hr	\N	\N	\N	notification
71	Schedule cleared	Your weekly schedule for term "1st Term" was cleared by the administrator. Please resubmit a revised schedule.	high	\N	2026-10-16 11:02:09	\N	t	41	2026-10-16 11:02:09	2026-10-16 11:02:09	\N	\N	employee	\N	\N	\N	notification
64	Jei Pastrana submitted a weekly schedule	Jei Pastrana submitted a weekly schedule for term "1st Term" and is waiting for HR approval.	medium	\N	2026-10-16 00:04:31	\N	t	\N	2026-10-16 00:04:31	2026-10-16 00:04:31	\N	\N	hr	\N	\N	\N	notification
66	Allainer Reyes submitted a weekly schedule	Allainer Reyes submitted a weekly schedule for term "1st Term" and is waiting for HR approval.	medium	\N	2026-10-16 10:49:15	\N	t	\N	2026-10-16 10:49:15	2026-10-16 10:49:15	\N	\N	hr	\N	\N	\N	notification
72	Allainer Reyes submitted a weekly schedule	Allainer Reyes submitted a weekly schedule for term "1st Term" and is waiting for HR approval.	medium	\N	2026-10-16 11:08:03	\N	t	\N	2026-10-16 11:08:03	2026-10-16 11:08:03	\N	\N	hr	\N	\N	\N	notification
78	Allainer Reyes submitted a weekly schedule	Allainer Reyes submitted a weekly schedule for term "1st Term" and is waiting for HR approval.	medium	\N	2026-10-16 11:14:35	\N	t	\N	2026-10-16 11:14:35	2026-10-16 11:14:35	\N	\N	hr	\N	\N	\N	notification
83	Schedule cleared	Your weekly schedule for term "1st Term" was cleared by the administrator. Please resubmit a revised schedule.	high	\N	2026-10-16 11:22:56	\N	t	41	2026-10-16 11:22:56	2026-10-16 11:22:56	\N	\N	employee	\N	\N	\N	notification
92	Schedule cleared	Your weekly schedule for term "2nd Term" was cleared by the administrator. Please resubmit a revised schedule.	high	\N	2026-10-16 12:15:40	\N	t	41	2026-10-16 12:15:40	2026-10-16 12:15:40	\N	\N	employee	\N	\N	\N	notification
98	Schedule cleared	Your weekly schedule for term "1st Term" was cleared by the administrator. Please resubmit a revised schedule.	high	\N	2026-10-16 12:21:42	\N	t	41	2026-10-16 12:21:42	2026-10-16 12:21:42	\N	\N	employee	\N	\N	\N	notification
100	Schedule updated by Admin	Your weekly schedule for term "2nd Term" was updated by the administrator. Please check your schedule.	high	\N	2026-10-16 12:24:22	\N	t	41	2026-10-16 12:24:22	2026-10-16 12:24:22	\N	\N	employee	\N	\N	\N	notification
104	Schedule updated by Admin	Your weekly schedule for term "2nd Term" was updated by the administrator. Please check your schedule.	high	\N	2026-10-16 12:28:03	\N	t	41	2026-10-16 12:28:03	2026-10-16 12:28:03	\N	\N	employee	\N	\N	\N	notification
85	Schedule approved	Your weekly schedule for 2nd Term  was approved by HR.	medium	\N	2026-10-16 11:25:33	\N	t	\N	2026-10-16 11:25:33	2026-10-16 11:25:33	\N	\N	employee	\N	\N	\N	notification
84	Allainer Reyes submitted a weekly schedule	Allainer Reyes submitted a weekly schedule for term "2nd Term" and is waiting for HR approval.	medium	\N	2026-10-16 11:25:12	\N	t	\N	2026-10-16 11:25:12	2026-10-16 11:25:12	\N	\N	hr	\N	\N	\N	notification
93	Allainer Reyes submitted a weekly schedule	Allainer Reyes submitted a weekly schedule for term "1st Term" and is waiting for HR approval.	medium	\N	2026-10-16 12:16:31	\N	t	\N	2026-10-16 12:16:31	2026-10-16 12:16:31	\N	\N	hr	\N	\N	\N	notification
99	Allainer Reyes submitted a weekly schedule	Allainer Reyes submitted a weekly schedule for term "2nd Term" and is waiting for HR approval.	medium	\N	2026-10-16 12:23:35	\N	t	\N	2026-10-16 12:23:35	2026-10-16 12:23:35	\N	\N	hr	\N	\N	\N	notification
131	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-24 11:40:53	\N	t	41	2026-11-24 11:40:53	2026-11-24 11:40:53	\N	\N	employee	\N	\N	\N	notification
132	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-24 11:45:02	\N	t	41	2026-11-24 11:45:02	2026-11-24 11:45:02	\N	\N	employee	\N	\N	\N	notification
133	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-24 11:53:31	\N	t	41	2026-11-24 11:53:31	2026-11-24 11:53:31	\N	\N	employee	\N	\N	\N	notification
134	Schedule added by Admin	A weekly schedule for term "2nd Term" was added and approved for you by the administrator.	high	\N	2026-11-24 11:55:56	\N	t	41	2026-11-24 11:55:56	2026-11-24 11:55:56	\N	\N	employee	\N	\N	\N	notification
135	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-24 11:58:53	\N	t	41	2026-11-24 11:58:53	2026-11-24 11:58:53	\N	\N	employee	\N	\N	\N	notification
136	Schedule added by Admin	A weekly schedule for term "2nd Term" was added and approved for you by the administrator.	high	\N	2026-11-24 11:59:52	\N	t	41	2026-11-24 11:59:52	2026-11-24 11:59:52	\N	\N	employee	\N	\N	\N	notification
137	Schedule added by Admin	A weekly schedule for term "2nd Term" was added and approved for you by the administrator.	high	\N	2026-11-24 12:02:26	\N	t	41	2026-11-24 12:02:26	2026-11-24 12:02:26	\N	\N	employee	\N	\N	\N	notification
138	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-24 13:39:27	\N	t	41	2026-11-24 13:39:27	2026-11-24 13:39:27	\N	\N	employee	\N	\N	\N	notification
139	Schedule added by Admin	A weekly schedule for term "2nd Term" was added and approved for you by the administrator.	high	\N	2026-11-24 13:48:36	\N	t	41	2026-11-24 13:48:36	2026-11-24 13:48:36	\N	\N	employee	\N	\N	\N	notification
140	Schedule added by Admin	A weekly schedule for term "2nd Term" was added and approved for you by the administrator.	high	\N	2026-11-24 13:50:12	\N	t	41	2026-11-24 13:50:12	2026-11-24 13:50:12	\N	\N	employee	\N	\N	\N	notification
141	Schedule added by Admin	A weekly schedule for term "2nd Term" was added and approved for you by the administrator.	high	\N	2026-11-24 13:51:39	\N	t	41	2026-11-24 13:51:39	2026-11-24 13:51:39	\N	\N	employee	\N	\N	\N	notification
142	Schedule added by Admin	A weekly schedule for term "2nd Term" was added and approved for you by the administrator.	high	\N	2026-11-24 13:53:21	\N	t	41	2026-11-24 13:53:21	2026-11-24 13:53:21	\N	\N	employee	\N	\N	\N	notification
143	Schedule added by Admin	A weekly schedule for term "2nd Term" was added and approved for you by the administrator.	high	\N	2026-11-24 13:54:52	\N	t	41	2026-11-24 13:54:52	2026-11-24 13:54:52	\N	\N	employee	\N	\N	\N	notification
144	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-24 13:55:48	\N	t	41	2026-11-24 13:55:48	2026-11-24 13:55:48	\N	\N	employee	\N	\N	\N	notification
145	Schedule added by Admin	A weekly schedule for term "2nd Term" was added and approved for you by the administrator.	high	\N	2026-11-24 13:56:31	\N	t	41	2026-11-24 13:56:31	2026-11-24 13:56:31	\N	\N	employee	\N	\N	\N	notification
146	Schedule added by Admin	A weekly schedule for term "2nd Term" was added and approved for you by the administrator.	high	\N	2026-11-24 13:58:34	\N	t	41	2026-11-24 13:58:34	2026-11-24 13:58:34	\N	\N	employee	\N	\N	\N	notification
147	Schedule added by Admin	A weekly schedule for term "2nd Term" was added and approved for you by the administrator.	high	\N	2026-11-24 14:03:17	\N	t	41	2026-11-24 14:03:17	2026-11-24 14:03:17	\N	\N	employee	\N	\N	\N	notification
148	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-24 14:03:48	\N	t	41	2026-11-24 14:03:48	2026-11-24 14:03:48	\N	\N	employee	\N	\N	\N	notification
149	Schedule added by Admin	A weekly schedule for term "2nd Term" was added and approved for you by the administrator.	high	\N	2026-11-24 14:05:02	\N	t	41	2026-11-24 14:05:02	2026-11-24 14:05:02	\N	\N	employee	\N	\N	\N	notification
150	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-25 14:01:55	\N	t	41	2026-11-25 14:01:55	2026-11-25 14:01:55	\N	\N	employee	\N	\N	\N	notification
151	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-25 14:05:37	\N	t	41	2026-11-25 14:05:37	2026-11-25 14:05:37	\N	\N	employee	\N	\N	\N	notification
152	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-25 14:12:32	\N	t	41	2026-11-25 14:12:32	2026-11-25 14:12:32	\N	\N	employee	\N	\N	\N	notification
153	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-25 14:14:34	\N	t	41	2026-11-25 14:14:34	2026-11-25 14:14:34	\N	\N	employee	\N	\N	\N	notification
154	Schedule added by Admin	A weekly schedule for term "2nd Term" was added and approved for you by the administrator.	high	\N	2026-11-25 14:26:18	\N	t	41	2026-11-25 14:26:18	2026-11-25 14:26:18	\N	\N	employee	\N	\N	\N	notification
155	Schedule added by Admin	A weekly schedule for term "2nd Term" was added and approved for you by the administrator.	high	\N	2026-11-25 14:27:25	\N	t	41	2026-11-25 14:27:25	2026-11-25 14:27:25	\N	\N	employee	\N	\N	\N	notification
156	Schedule added by Admin	A weekly schedule for term "2nd Term" was added and approved for you by the administrator.	high	\N	2026-11-25 14:29:14	\N	t	41	2026-11-25 14:29:14	2026-11-25 14:29:14	\N	\N	employee	\N	\N	\N	notification
61	Jerimaiah Padua submitted a weekly schedule	Jerimaiah Padua submitted a weekly schedule for term "1st Term" and is waiting for HR approval.	medium	\N	2026-10-15 23:49:10	\N	t	\N	2026-10-15 23:49:10	2026-10-15 23:49:10	\N	\N	hr	\N	\N	\N	notification
62	Schedule approved	Your weekly schedule for 1st Term  was approved by HR.	medium	\N	2026-10-15 23:50:56	\N	t	\N	2026-10-15 23:50:56	2026-10-15 23:50:56	\N	\N	employee	\N	\N	\N	notification
63	Schedule approved	Your weekly schedule for 1st Term  was approved by HR.	medium	\N	2026-10-15 23:51:10	\N	t	\N	2026-10-15 23:51:10	2026-10-15 23:51:10	\N	\N	employee	\N	\N	\N	notification
65	Schedule approved	Your weekly schedule for 1st Term  was approved by HR.	medium	\N	2026-10-16 00:05:19	\N	t	\N	2026-10-16 00:05:19	2026-10-16 00:05:19	\N	\N	employee	\N	\N	\N	notification
67	Schedule approved	Your weekly schedule for 1st Term  was approved by HR.	medium	\N	2026-10-16 10:49:40	\N	t	\N	2026-10-16 10:49:40	2026-10-16 10:49:40	\N	\N	employee	\N	\N	\N	notification
68	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 11, 2026).	high	\N	2026-10-16 10:57:03	\N	t	\N	2026-10-16 10:57:03	2026-10-16 10:57:03	\N	\N	employee	\N	\N	\N	notification
69	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 10, 2026).	high	\N	2026-10-16 10:57:03	\N	t	\N	2026-10-16 10:57:03	2026-10-16 10:57:03	\N	\N	employee	\N	\N	\N	notification
70	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to August 29, 2026).	high	\N	2026-10-16 10:57:04	\N	t	\N	2026-10-16 10:57:04	2026-10-16 10:57:04	\N	\N	employee	\N	\N	\N	notification
73	Schedule approved	Your weekly schedule for 1st Term  was approved by HR.	medium	\N	2026-10-16 11:08:21	\N	t	\N	2026-10-16 11:08:21	2026-10-16 11:08:21	\N	\N	employee	\N	\N	\N	notification
74	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 11, 2026).	high	\N	2026-10-16 11:10:54	\N	t	\N	2026-10-16 11:10:54	2026-10-16 11:10:54	\N	\N	employee	\N	\N	\N	notification
75	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 10, 2026).	high	\N	2026-10-16 11:10:55	\N	t	\N	2026-10-16 11:10:55	2026-10-16 11:10:55	\N	\N	employee	\N	\N	\N	notification
76	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to August 29, 2026).	high	\N	2026-10-16 11:10:56	\N	t	\N	2026-10-16 11:10:56	2026-10-16 11:10:56	\N	\N	employee	\N	\N	\N	notification
77	Schedule cleared	Your approved weekly schedule for term "1st Term" was cleared by HR. Please resubmit a revised schedule.	medium	\N	2026-10-16 11:11:53	\N	t	\N	2026-10-16 11:11:53	2026-10-16 11:11:53	\N	\N	employee	\N	\N	\N	notification
79	Schedule approved	Your weekly schedule for 1st Term  was approved by HR.	medium	\N	2026-10-16 11:14:51	\N	t	\N	2026-10-16 11:14:51	2026-10-16 11:14:51	\N	\N	employee	\N	\N	\N	notification
80	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 11, 2026).	high	\N	2026-10-16 11:17:24	\N	t	\N	2026-10-16 11:17:24	2026-10-16 11:17:24	\N	\N	employee	\N	\N	\N	notification
81	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 10, 2026).	high	\N	2026-10-16 11:17:25	\N	t	\N	2026-10-16 11:17:25	2026-10-16 11:17:25	\N	\N	employee	\N	\N	\N	notification
82	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to August 29, 2026).	high	\N	2026-10-16 11:17:25	\N	t	\N	2026-10-16 11:17:25	2026-10-16 11:17:25	\N	\N	employee	\N	\N	\N	notification
86	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 11, 2026).	high	\N	2026-10-16 11:27:01	\N	t	\N	2026-10-16 11:27:01	2026-10-16 11:27:01	\N	\N	employee	\N	\N	\N	notification
87	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 10, 2026).	high	\N	2026-10-16 11:27:02	\N	t	\N	2026-10-16 11:27:02	2026-10-16 11:27:02	\N	\N	employee	\N	\N	\N	notification
88	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to August 29, 2026).	high	\N	2026-10-16 11:27:02	\N	t	\N	2026-10-16 11:27:02	2026-10-16 11:27:02	\N	\N	employee	\N	\N	\N	notification
89	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 11, 2026).	high	\N	2026-10-16 11:33:34	\N	t	\N	2026-10-16 11:33:34	2026-10-16 11:33:34	\N	\N	employee	\N	\N	\N	notification
90	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 10, 2026).	high	\N	2026-10-16 11:33:35	\N	t	\N	2026-10-16 11:33:35	2026-10-16 11:33:35	\N	\N	employee	\N	\N	\N	notification
91	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to August 29, 2026).	high	\N	2026-10-16 11:33:36	\N	t	\N	2026-10-16 11:33:36	2026-10-16 11:33:36	\N	\N	employee	\N	\N	\N	notification
94	Schedule approved	Your weekly schedule for 1st Term  was approved by HR.	medium	\N	2026-10-16 12:16:53	\N	t	\N	2026-10-16 12:16:53	2026-10-16 12:16:53	\N	\N	employee	\N	\N	\N	notification
95	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 11, 2026).	high	\N	2026-10-16 12:20:14	\N	t	\N	2026-10-16 12:20:14	2026-10-16 12:20:14	\N	\N	employee	\N	\N	\N	notification
96	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 10, 2026).	high	\N	2026-10-16 12:20:15	\N	t	\N	2026-10-16 12:20:15	2026-10-16 12:20:15	\N	\N	employee	\N	\N	\N	notification
97	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to August 29, 2026).	high	\N	2026-10-16 12:20:15	\N	t	\N	2026-10-16 12:20:15	2026-10-16 12:20:15	\N	\N	employee	\N	\N	\N	notification
101	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 11, 2026).	high	\N	2026-10-16 12:26:57	\N	t	\N	2026-10-16 12:26:57	2026-10-16 12:26:57	\N	\N	employee	\N	\N	\N	notification
102	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 10, 2026).	high	\N	2026-10-16 12:26:58	\N	t	\N	2026-10-16 12:26:58	2026-10-16 12:26:58	\N	\N	employee	\N	\N	\N	notification
103	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to August 29, 2026).	high	\N	2026-10-16 12:26:59	\N	t	\N	2026-10-16 12:26:59	2026-10-16 12:26:59	\N	\N	employee	\N	\N	\N	notification
105	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 11, 2026).	high	\N	2026-10-16 12:29:19	\N	t	\N	2026-10-16 12:29:19	2026-10-16 12:29:19	\N	\N	employee	\N	\N	\N	notification
106	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to September 10, 2026).	high	\N	2026-10-16 12:29:20	\N	t	\N	2026-10-16 12:29:20	2026-10-16 12:29:20	\N	\N	employee	\N	\N	\N	notification
107	WFH Action Required	Your approved Work From Home leave requires WFH materials. Please upload your WFH monitoring sheet so HR can review and finalize your attendance as Present. Affected request(s): Work From Home (August 06, 2026 to August 29, 2026).	high	\N	2026-10-16 12:29:21	\N	t	\N	2026-10-16 12:29:21	2026-10-16 12:29:21	\N	\N	employee	\N	\N	\N	notification
108	Schedule cleared	Your approved weekly schedule for term "1st Term" was cleared by HR. Please resubmit a revised schedule.	medium	\N	2026-10-16 12:34:43	\N	t	\N	2026-10-16 12:34:43	2026-10-16 12:34:43	\N	\N	employee	\N	\N	\N	notification
109	Congratulations on Your Regular Employment Status!	Congratulations, Jei Pastrana! Your employment status has been updated to Regular. We appreciate your continued commitment and contributions to NU Lipa.	high	\N	2026-10-16 12:36:16	\N	t	41	2026-10-16 12:36:16	2026-10-16 12:36:16	\N	\N	\N	\N	\N	\N	notification
110	Schedule added by Admin	A weekly schedule for term "1st Term" was added and approved for you by the administrator.	high	\N	2026-11-23 10:49:16	\N	t	41	2026-11-23 10:49:16	2026-11-23 10:49:16	\N	\N	employee	\N	\N	\N	notification
111	Schedule cleared	Your weekly schedule for term "1st Term" was cleared by the administrator. Please resubmit a revised schedule.	high	\N	2026-11-23 10:49:40	\N	t	41	2026-11-23 10:49:40	2026-11-23 10:49:40	\N	\N	employee	\N	\N	\N	notification
112	Schedule added by HR	A weekly schedule for term "1st Term" was added and approved for you by HR.	medium	\N	2026-11-23 10:50:58	\N	t	41	2026-11-23 10:50:58	2026-11-23 10:50:58	\N	\N	employee	\N	\N	\N	notification
113	Schedule cleared	Your weekly schedule for term "1st Term" was cleared by the administrator. Please resubmit a revised schedule.	high	\N	2026-11-23 10:56:30	\N	t	41	2026-11-23 10:56:30	2026-11-23 10:56:30	\N	\N	employee	\N	\N	\N	notification
114	Schedule added by Admin	A weekly schedule for term "1st Term" was added and approved for you by the administrator.	high	\N	2026-11-23 10:57:18	\N	t	41	2026-11-23 10:57:18	2026-11-23 10:57:18	\N	\N	employee	\N	\N	\N	notification
115	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-23 11:46:21	\N	t	41	2026-11-23 11:46:21	2026-11-23 11:46:21	\N	\N	employee	\N	\N	\N	notification
116	Schedule cleared	Your approved weekly schedule for term "2nd Term" was cleared by HR. Please resubmit a revised schedule.	medium	\N	2026-11-23 11:47:23	\N	t	41	2026-11-23 11:47:23	2026-11-23 11:47:23	\N	\N	employee	\N	\N	\N	notification
117	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-23 11:51:53	\N	t	41	2026-11-23 11:51:53	2026-11-23 11:51:53	\N	\N	employee	\N	\N	\N	notification
118	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-23 15:00:55	\N	t	41	2026-11-23 15:00:55	2026-11-23 15:00:55	\N	\N	employee	\N	\N	\N	notification
119	Schedule cleared	Your approved weekly schedule for term "2nd Term" was cleared by HR. Please resubmit a revised schedule.	medium	\N	2026-11-23 15:09:50	\N	t	41	2026-11-23 15:09:50	2026-11-23 15:09:50	\N	\N	employee	\N	\N	\N	notification
120	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-23 15:14:47	\N	t	41	2026-11-23 15:14:47	2026-11-23 15:14:47	\N	\N	employee	\N	\N	\N	notification
121	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-23 15:16:44	\N	t	41	2026-11-23 15:16:44	2026-11-23 15:16:44	\N	\N	employee	\N	\N	\N	notification
122	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-23 15:38:06	\N	t	41	2026-11-23 15:38:06	2026-11-23 15:38:06	\N	\N	employee	\N	\N	\N	notification
123	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-23 15:49:42	\N	t	41	2026-11-23 15:49:42	2026-11-23 15:49:42	\N	\N	employee	\N	\N	\N	notification
124	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-23 16:00:50	\N	t	41	2026-11-23 16:00:50	2026-11-23 16:00:50	\N	\N	employee	\N	\N	\N	notification
125	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-24 11:02:33	\N	t	41	2026-11-24 11:02:33	2026-11-24 11:02:33	\N	\N	employee	\N	\N	\N	notification
126	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-24 11:08:10	\N	t	41	2026-11-24 11:08:10	2026-11-24 11:08:10	\N	\N	employee	\N	\N	\N	notification
127	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-24 11:31:56	\N	t	41	2026-11-24 11:31:56	2026-11-24 11:31:56	\N	\N	employee	\N	\N	\N	notification
128	Schedule added by Admin	A weekly schedule for term "2nd Term" was added and approved for you by the administrator.	high	\N	2026-11-24 11:32:25	\N	t	41	2026-11-24 11:32:25	2026-11-24 11:32:25	\N	\N	employee	\N	\N	\N	notification
129	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-24 11:34:04	\N	t	41	2026-11-24 11:34:04	2026-11-24 11:34:04	\N	\N	employee	\N	\N	\N	notification
130	Schedule added by Admin	A weekly schedule for term "2nd Term" was added and approved for you by the administrator.	high	\N	2026-11-24 11:36:53	\N	t	41	2026-11-24 11:36:53	2026-11-24 11:36:53	\N	\N	employee	\N	\N	\N	notification
157	Schedule added by Admin	A weekly schedule for term "2nd Term" was added and approved for you by the administrator.	high	\N	2026-11-25 14:30:39	\N	t	41	2026-11-25 14:30:39	2026-11-25 14:30:39	\N	\N	employee	\N	\N	\N	notification
158	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-25 14:30:49	\N	t	41	2026-11-25 14:30:49	2026-11-25 14:30:49	\N	\N	employee	\N	\N	\N	notification
159	Schedule added by Admin	A weekly schedule for term "2nd Term" was added and approved for you by the administrator.	high	\N	2026-11-25 14:31:27	\N	t	41	2026-11-25 14:31:27	2026-11-25 14:31:27	\N	\N	employee	\N	\N	\N	notification
160	Schedule added by Admin	A weekly schedule for term "2nd Term" was added and approved for you by the administrator.	high	\N	2026-11-25 14:32:41	\N	t	41	2026-11-25 14:32:41	2026-11-25 14:32:41	\N	\N	employee	\N	\N	\N	notification
161	Schedule added by Admin	A weekly schedule for term "2nd Term" was added and approved for you by the administrator.	high	\N	2026-11-25 14:33:18	\N	t	41	2026-11-25 14:33:18	2026-11-25 14:33:18	\N	\N	employee	\N	\N	\N	notification
162	Schedule added by Admin	A weekly schedule for term "2nd Term" was added and approved for you by the administrator.	high	\N	2026-11-25 14:34:44	\N	t	41	2026-11-25 14:34:44	2026-11-25 14:34:44	\N	\N	employee	\N	\N	\N	notification
163	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-25 14:55:34	\N	t	41	2026-11-25 14:55:34	2026-11-25 14:55:34	\N	\N	employee	\N	\N	\N	notification
164	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-25 15:35:43	\N	t	41	2026-11-25 15:35:43	2026-11-25 15:35:43	\N	\N	employee	\N	\N	\N	notification
165	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-25 15:37:31	\N	t	41	2026-11-25 15:37:31	2026-11-25 15:37:31	\N	\N	employee	\N	\N	\N	notification
166	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-26 09:50:16	\N	t	41	2026-11-26 09:50:16	2026-11-26 09:50:16	\N	\N	employee	\N	\N	\N	notification
167	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-26 09:52:12	\N	t	41	2026-11-26 09:52:12	2026-11-26 09:52:12	\N	\N	employee	\N	\N	\N	notification
168	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-26 09:54:40	\N	t	41	2026-11-26 09:54:40	2026-11-26 09:54:40	\N	\N	employee	\N	\N	\N	notification
169	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-26 09:55:29	\N	t	41	2026-11-26 09:55:29	2026-11-26 09:55:29	\N	\N	employee	\N	\N	\N	notification
170	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-26 09:57:15	\N	t	41	2026-11-26 09:57:15	2026-11-26 09:57:15	\N	\N	employee	\N	\N	\N	notification
171	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-26 09:59:57	\N	t	41	2026-11-26 09:59:57	2026-11-26 09:59:57	\N	\N	employee	\N	\N	\N	notification
172	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-26 10:01:06	\N	t	41	2026-11-26 10:01:06	2026-11-26 10:01:06	\N	\N	employee	\N	\N	\N	notification
173	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-26 10:03:45	\N	t	41	2026-11-26 10:03:45	2026-11-26 10:03:45	\N	\N	employee	\N	\N	\N	notification
174	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-26 10:05:29	\N	t	41	2026-11-26 10:05:29	2026-11-26 10:05:29	\N	\N	employee	\N	\N	\N	notification
175	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-26 10:23:46	\N	t	41	2026-11-26 10:23:46	2026-11-26 10:23:46	\N	\N	employee	\N	\N	\N	notification
176	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-26 10:26:17	\N	t	41	2026-11-26 10:26:17	2026-11-26 10:26:17	\N	\N	employee	\N	\N	\N	notification
177	Schedule added by HR	A weekly schedule for term "2nd Term" was added and approved for you by HR.	medium	\N	2026-11-26 10:28:25	\N	t	41	2026-11-26 10:28:25	2026-11-26 10:28:25	\N	\N	employee	\N	\N	\N	notification
\.


--
-- Data for Name: attendance_records; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.attendance_records (id, employee_id, record_date, time_in, time_out, scheduled_time_in, scheduled_time_out, tardiness_minutes, undertime_minutes, overtime_minutes, status, created_at, updated_at, schedule_status, schedule_notes) FROM stdin;
1495	32	2026-11-05	07:57:00	17:09:00	08:00:00	17:00:00	0	0	9	present	2026-11-23 11:57:04	2026-11-23 17:09:49	validated	\N
1496	32	2026-11-06	07:04:00	17:07:00	07:00:00	17:00:00	0	0	7	present	2026-11-23 11:57:04	2026-11-23 17:09:49	validated	\N
1497	32	2026-11-07	08:30:00	16:27:00	09:00:00	16:00:00	0	0	27	present	2026-11-23 11:57:04	2026-11-23 17:09:49	validated	\N
1498	32	2026-11-09	08:03:00	17:06:00	08:00:00	17:00:00	0	0	6	present	2026-11-23 11:57:04	2026-11-23 17:09:49	validated	\N
1499	32	2026-11-10	06:55:00	17:14:00	07:00:00	17:00:00	0	0	14	present	2026-11-23 11:57:04	2026-11-23 17:09:49	validated	\N
1500	32	2026-11-12	07:58:00	17:05:00	08:00:00	17:00:00	0	0	5	present	2026-11-23 11:57:04	2026-11-23 17:09:49	validated	\N
1501	32	2026-11-13	07:05:00	17:17:00	07:00:00	17:00:00	0	0	17	present	2026-11-23 11:57:04	2026-11-23 17:09:49	validated	\N
1502	32	2026-11-14	09:03:00	16:08:00	09:00:00	16:00:00	0	0	8	present	2026-11-23 11:57:04	2026-11-23 17:09:49	validated	\N
1503	33	2026-11-03	06:51:00	17:04:00	\N	\N	0	0	0	absent	2026-11-23 11:57:04	2026-11-23 17:09:49	no_schedule	No schedule available
1504	33	2026-11-04	07:34:00	20:13:00	\N	\N	0	0	0	absent	2026-11-23 11:57:04	2026-11-23 17:09:49	no_schedule	No schedule available
1505	33	2026-11-05	07:15:00	17:05:00	\N	\N	0	0	0	absent	2026-11-23 11:57:04	2026-11-23 17:09:49	no_schedule	No schedule available
1506	33	2026-11-06	07:18:00	14:09:00	\N	\N	0	0	0	absent	2026-11-23 11:57:04	2026-11-23 17:09:49	no_schedule	No schedule available
1507	33	2026-11-09	06:53:00	17:12:00	\N	\N	0	0	0	absent	2026-11-23 11:57:04	2026-11-23 17:09:49	no_schedule	No schedule available
1508	33	2026-11-10	06:50:00	18:08:00	\N	\N	0	0	0	absent	2026-11-23 11:57:04	2026-11-23 17:09:49	no_schedule	No schedule available
1509	33	2026-11-11	06:51:00	19:00:00	\N	\N	0	0	0	absent	2026-11-23 11:57:04	2026-11-23 17:09:49	no_schedule	No schedule available
1510	33	2026-11-12	07:18:00	16:34:00	\N	\N	0	0	0	absent	2026-11-23 11:57:04	2026-11-23 17:09:49	no_schedule	No schedule available
1511	33	2026-11-13	07:04:00	13:52:00	\N	\N	0	0	0	absent	2026-11-23 11:57:04	2026-11-23 17:09:49	no_schedule	No schedule available
1610	59	2026-11-03	07:47:00	19:28:00	08:00:00	19:00:00	0	0	28	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1611	59	2026-11-04	07:36:00	20:39:00	08:00:00	19:00:00	0	0	99	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1612	59	2026-11-05	07:39:00	18:51:00	08:00:00	19:00:00	0	9	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1613	59	2026-11-09	07:51:00	20:01:00	08:00:00	19:00:00	0	0	61	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1614	59	2026-11-10	07:53:00	19:08:00	08:00:00	19:00:00	0	0	8	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1615	59	2026-11-11	07:47:00	19:06:00	08:00:00	19:00:00	0	0	6	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1616	59	2026-11-12	08:03:00	18:59:00	08:00:00	19:00:00	0	1	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1617	60	2026-11-03	08:03:00	17:06:00	08:00:00	17:00:00	0	0	6	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1618	60	2026-11-04	08:00:00	17:08:00	08:00:00	17:00:00	0	0	8	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1619	60	2026-11-05	08:03:00	17:14:00	08:00:00	17:00:00	0	0	14	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1620	60	2026-11-06	07:36:00	17:08:00	08:00:00	17:00:00	0	0	8	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1621	60	2026-11-09	08:01:00	17:12:00	08:00:00	17:00:00	0	0	12	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1622	60	2026-11-10	08:01:00	17:05:00	08:00:00	17:00:00	0	0	5	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1623	60	2026-11-11	08:18:00	17:17:00	08:00:00	17:00:00	3	0	17	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1624	60	2026-11-12	08:00:00	17:09:00	08:00:00	17:00:00	0	0	9	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1625	60	2026-11-13	07:56:00	17:25:00	08:00:00	17:00:00	0	0	25	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1626	62	2026-11-03	06:41:00	19:43:00	09:30:00	19:30:00	0	0	13	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1627	62	2026-11-04	09:05:00	19:49:00	\N	\N	0	0	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	Non-working day: present due to attendance record
1628	62	2026-11-05	06:36:00	20:09:00	07:00:00	19:00:00	0	0	69	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1629	62	2026-11-06	09:03:00	19:07:00	09:30:00	19:30:00	0	23	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1630	62	2026-11-07	09:53:00	14:46:00	\N	\N	0	0	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	Non-working day: present due to attendance record
1631	65	2026-11-03	06:45:00	19:06:00	06:30:00	15:30:00	0	0	216	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1632	65	2026-11-04	06:51:00	15:04:00	06:30:00	15:30:00	6	26	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1633	65	2026-11-06	06:43:00	18:55:00	06:30:00	15:30:00	0	0	205	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1634	65	2026-11-09	07:02:00	20:19:00	06:30:00	15:30:00	17	0	289	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1635	65	2026-11-10	06:50:00	13:00:00	06:30:00	15:30:00	5	150	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1636	65	2026-11-11	06:01:00	15:33:00	06:30:00	15:30:00	0	0	3	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1637	65	2026-11-12	06:08:00	15:36:00	06:30:00	15:30:00	0	0	6	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1638	65	2026-11-13	06:28:00	15:30:00	06:30:00	15:30:00	0	0	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1639	67	2026-11-03	08:48:00	19:43:00	09:00:00	19:30:00	0	0	13	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1640	67	2026-11-04	09:19:00	19:49:00	09:30:00	19:30:00	0	0	19	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1641	67	2026-11-05	08:54:00	20:09:00	09:30:00	19:30:00	0	0	39	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1642	67	2026-11-06	08:52:00	18:07:00	09:00:00	13:00:00	0	0	307	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1643	67	2026-11-07	08:46:00	14:46:00	\N	\N	0	0	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	Non-working day: present due to attendance record
1644	67	2026-11-09	08:58:00	19:34:00	09:30:00	19:30:00	0	0	4	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1645	67	2026-11-10	08:53:00	19:39:00	09:00:00	19:30:00	0	0	9	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1529	34	2026-11-03	10:14:00	17:16:00	08:00:00	17:00:00	119	0	16	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1530	34	2026-11-05	09:19:00	19:07:00	09:00:00	19:00:00	4	0	7	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1531	34	2026-11-06	08:06:00	19:20:00	08:00:00	19:00:00	0	0	20	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1532	34	2026-11-07	09:01:00	14:55:00	09:00:00	13:00:00	0	0	115	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1533	34	2026-11-09	09:04:00	19:22:00	09:00:00	19:00:00	0	0	22	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1534	34	2026-11-10	08:04:00	17:13:00	08:00:00	17:00:00	0	0	13	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1535	34	2026-11-12	09:07:00	19:11:00	09:00:00	19:00:00	0	0	11	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1536	34	2026-11-13	07:14:00	19:02:00	08:00:00	19:00:00	0	0	2	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1537	34	2026-11-14	08:44:00	16:01:00	09:00:00	13:00:00	0	0	181	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1538	35	2026-11-03	10:42:00	19:35:00	11:00:00	19:00:00	0	0	35	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1539	35	2026-11-05	06:45:00	19:07:00	07:00:00	19:00:00	0	0	7	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1540	35	2026-11-06	10:46:00	19:20:00	11:00:00	19:00:00	0	0	20	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1541	35	2026-11-07	06:45:00	14:55:00	07:00:00	11:00:00	0	0	235	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1542	35	2026-11-09	19:21:00	19:22:00	07:00:00	19:00:00	726	0	22	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1543	35	2026-11-10	10:42:00	19:07:00	11:00:00	19:00:00	0	0	7	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1544	35	2026-11-12	06:43:00	19:11:00	07:00:00	19:00:00	0	0	11	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1545	35	2026-11-13	07:21:00	19:02:00	11:00:00	19:00:00	0	0	2	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1546	35	2026-11-14	07:09:00	16:01:00	07:00:00	11:00:00	0	0	301	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1547	36	2026-11-04	06:43:00	18:03:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1548	36	2026-11-05	07:02:00	19:13:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1549	36	2026-11-06	06:54:00	19:00:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1550	36	2026-11-09	06:51:00	18:37:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1551	36	2026-11-10	13:20:00	18:05:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1552	36	2026-11-11	07:17:00	20:36:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1553	36	2026-11-12	07:09:00	19:03:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1554	36	2026-11-13	07:22:00	\N	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1555	37	2026-11-03	08:24:00	17:06:00	11:00:00	17:00:00	0	0	6	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1556	37	2026-11-04	09:50:00	17:14:00	10:00:00	17:00:00	0	0	14	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1557	37	2026-11-05	06:30:00	17:14:00	07:00:00	17:00:00	0	0	14	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1558	37	2026-11-06	06:26:00	17:08:00	07:00:00	17:00:00	0	0	8	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1559	37	2026-11-09	06:34:00	19:00:00	07:00:00	19:00:00	0	0	0	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1560	37	2026-11-10	10:26:00	17:14:00	11:00:00	17:00:00	0	0	14	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1561	37	2026-11-11	09:37:00	17:17:00	10:00:00	17:00:00	0	0	17	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1562	37	2026-11-12	06:29:00	17:09:00	07:00:00	17:00:00	0	0	9	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1646	67	2026-11-11	09:24:00	19:36:00	09:30:00	19:30:00	0	0	6	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1563	37	2026-11-13	06:31:00	17:25:00	07:00:00	17:00:00	0	0	25	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1647	67	2026-11-12	09:18:00	20:18:00	09:30:00	19:30:00	0	0	48	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1564	38	2026-11-03	08:06:00	20:02:00	08:00:00	20:00:00	0	0	2	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1648	67	2026-11-13	08:54:00	18:30:00	09:00:00	13:00:00	0	0	330	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1565	38	2026-11-04	07:37:00	16:21:00	07:00:00	19:00:00	22	159	0	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1566	38	2026-11-05	09:35:00	20:37:00	09:00:00	16:00:00	20	0	277	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1567	38	2026-11-06	10:03:00	16:22:00	08:00:00	16:00:00	108	0	22	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1568	38	2026-11-09	12:07:00	18:49:00	12:00:00	18:00:00	0	0	49	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1649	67	2026-11-14	10:05:00	14:00:00	\N	\N	0	0	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	Non-working day: present due to attendance record
1569	38	2026-11-10	08:20:00	20:04:00	08:00:00	20:00:00	5	0	4	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1650	68	2026-11-03	08:30:00	20:01:00	\N	\N	0	0	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	Non-working day: present due to attendance record
1570	38	2026-11-11	07:13:00	19:50:00	07:00:00	19:00:00	0	0	50	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1651	68	2026-11-04	10:28:00	19:49:00	08:30:00	19:30:00	103	0	19	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1652	68	2026-11-05	08:29:00	21:03:00	10:30:00	19:30:00	0	0	93	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1571	38	2026-11-12	08:44:00	16:34:00	09:00:00	16:00:00	0	0	34	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1653	68	2026-11-06	08:07:00	19:07:00	08:30:00	19:30:00	0	23	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1654	68	2026-11-07	11:09:00	\N	07:00:00	11:00:00	234	0	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1655	68	2026-11-09	08:30:00	19:34:00	10:30:00	19:30:00	0	0	4	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1656	68	2026-11-10	08:28:00	19:38:00	\N	\N	0	0	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	Non-working day: present due to attendance record
1572	38	2026-11-13	08:16:00	20:03:00	08:00:00	16:00:00	1	0	243	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1573	39	2026-11-03	06:54:00	17:37:00	08:00:00	17:00:00	0	0	37	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1574	39	2026-11-04	07:45:00	17:33:00	08:00:00	17:00:00	0	0	33	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1575	39	2026-11-05	07:46:00	17:52:00	08:00:00	17:00:00	0	0	52	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1576	39	2026-11-06	08:04:00	17:16:00	08:00:00	17:00:00	0	0	16	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1577	39	2026-11-08	08:58:00	\N	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1578	39	2026-11-09	06:36:00	17:19:00	07:00:00	17:00:00	0	0	19	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1579	39	2026-11-10	07:06:00	17:10:00	08:00:00	17:00:00	0	0	10	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1580	39	2026-11-11	07:51:00	17:35:00	08:00:00	17:00:00	0	0	35	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1581	39	2026-11-12	07:45:00	18:34:00	08:00:00	17:00:00	0	0	94	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1582	39	2026-11-13	07:33:00	17:07:00	08:00:00	17:00:00	0	0	7	present	2026-11-23 17:09:49	2026-11-23 17:09:49	validated	\N
1583	40	2026-11-03	07:10:00	17:11:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1584	40	2026-11-04	07:22:00	17:16:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1585	40	2026-11-05	07:39:00	17:28:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1586	40	2026-11-06	07:26:00	17:41:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1587	40	2026-11-07	10:06:00	14:13:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1588	40	2026-11-09	07:07:00	17:07:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1589	40	2026-11-11	07:17:00	17:34:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1590	40	2026-11-12	07:16:00	17:12:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1591	40	2026-11-13	07:26:00	17:19:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1592	43	2026-11-03	06:44:00	17:06:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1593	43	2026-11-04	06:59:00	11:09:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1594	43	2026-11-05	07:00:00	17:02:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1595	43	2026-11-06	06:58:00	17:07:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1596	43	2026-11-09	06:53:00	17:06:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1597	43	2026-11-10	07:00:00	17:13:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1598	43	2026-11-11	06:58:00	11:10:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1599	43	2026-11-12	06:48:00	17:14:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1600	43	2026-11-13	07:07:00	19:02:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1601	45	2026-11-03	11:06:00	17:48:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1602	45	2026-11-04	08:49:00	18:11:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1603	45	2026-11-05	08:29:00	17:42:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1604	45	2026-11-06	08:31:00	17:39:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1605	45	2026-11-09	08:31:00	17:49:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1606	45	2026-11-10	08:44:00	18:04:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1607	45	2026-11-11	08:43:00	17:51:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1608	45	2026-11-12	08:38:00	17:45:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1609	45	2026-11-13	08:38:00	17:47:00	\N	\N	0	0	0	absent	2026-11-23 17:09:49	2026-11-23 17:09:49	no_schedule	No schedule available
1657	68	2026-11-12	08:34:00	\N	10:30:00	19:30:00	0	0	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1658	68	2026-11-13	13:44:00	18:30:00	08:30:00	19:30:00	299	60	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1659	69	2026-11-03	08:17:00	18:06:00	08:03:00	17:30:00	0	0	36	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1660	69	2026-11-04	08:48:00	17:45:00	08:30:00	17:30:00	3	0	15	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1661	69	2026-11-05	08:21:00	19:26:00	08:30:00	17:30:00	0	0	116	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1662	69	2026-11-06	08:27:00	18:21:00	08:30:00	17:30:00	0	0	51	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1663	69	2026-11-07	08:33:00	13:54:00	08:30:00	17:30:00	0	216	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1664	69	2026-11-09	08:33:00	19:24:00	08:30:00	17:30:00	0	0	114	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1665	69	2026-11-10	12:53:00	18:45:00	08:03:00	17:30:00	275	0	75	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1666	69	2026-11-11	08:30:00	18:37:00	08:30:00	17:30:00	0	0	67	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1667	69	2026-11-12	08:43:00	19:29:00	08:30:00	17:30:00	0	0	119	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1668	69	2026-11-13	08:25:00	17:42:00	08:30:00	17:30:00	0	0	12	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1669	69	2026-11-14	08:33:00	\N	08:30:00	17:30:00	0	0	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1670	70	2026-11-03	06:43:00	18:57:00	07:00:00	19:00:00	0	3	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1671	70	2026-11-05	06:29:00	17:00:00	07:00:00	15:00:00	0	0	120	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1672	70	2026-11-06	06:24:00	19:02:00	07:00:00	19:00:00	0	0	2	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1673	70	2026-11-07	08:10:00	13:39:00	\N	\N	0	0	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	Non-working day: present due to attendance record
1674	70	2026-11-10	06:58:00	19:02:00	07:00:00	19:00:00	0	0	2	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1675	70	2026-11-11	07:03:00	12:22:00	07:00:00	12:00:00	0	0	22	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1676	70	2026-11-12	06:55:00	14:58:00	07:00:00	15:00:00	0	2	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1677	70	2026-11-13	07:01:00	18:52:00	07:00:00	19:00:00	0	8	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1678	71	2026-11-03	08:10:00	13:56:00	08:00:00	17:00:00	0	184	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1679	71	2026-11-05	06:59:00	19:03:00	08:00:00	18:00:00	0	0	63	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1680	71	2026-11-06	07:59:00	19:00:00	08:00:00	16:00:00	0	0	180	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1681	71	2026-11-07	08:08:00	17:00:00	08:00:00	16:00:00	0	0	60	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1682	71	2026-11-09	06:51:00	19:06:00	08:00:00	18:00:00	0	0	66	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1683	71	2026-11-12	07:01:00	13:17:00	08:00:00	18:00:00	0	283	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1684	72	2026-11-03	08:17:00	17:44:00	08:30:00	17:30:00	0	0	14	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1685	72	2026-11-05	08:03:00	17:46:00	08:30:00	17:30:00	0	0	16	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1686	72	2026-11-06	08:17:00	18:11:00	08:30:00	17:30:00	0	0	41	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1687	72	2026-11-07	08:48:00	17:06:00	\N	\N	0	0	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	Non-working day: present due to attendance record
1688	72	2026-11-09	08:27:00	17:37:00	08:30:00	17:30:00	0	0	7	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1689	72	2026-11-10	08:19:00	17:54:00	08:30:00	17:30:00	0	0	24	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1690	72	2026-11-11	08:24:00	17:38:00	08:30:00	17:30:00	0	0	8	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1691	72	2026-11-13	08:24:00	19:49:00	08:30:00	17:30:00	0	0	139	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1692	73	2026-11-03	06:52:00	17:07:00	08:00:00	17:00:00	0	0	7	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1693	73	2026-11-04	08:00:00	17:08:00	08:00:00	17:00:00	0	0	8	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1694	73	2026-11-05	08:03:00	17:14:00	08:00:00	17:00:00	0	0	14	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1695	73	2026-11-06	07:37:00	17:08:00	08:00:00	17:00:00	0	0	8	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1696	73	2026-11-07	08:13:00	14:24:00	\N	\N	0	0	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	non_working_day	Non-working day
1697	73	2026-11-09	07:25:00	17:14:00	08:00:00	17:00:00	0	0	14	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1698	73	2026-11-10	07:30:00	17:05:00	08:00:00	17:00:00	0	0	5	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1699	73	2026-11-11	08:10:00	17:17:00	08:00:00	17:00:00	0	0	17	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1700	73	2026-11-12	07:19:00	17:10:00	08:00:00	17:00:00	0	0	10	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1701	73	2026-11-13	07:02:00	17:25:00	08:00:00	17:00:00	0	0	25	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1702	74	2026-11-03	07:39:00	19:43:00	08:00:00	17:00:00	0	0	163	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1703	74	2026-11-04	06:59:00	17:00:00	\N	\N	0	0	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	Non-working day: present due to attendance record
1704	74	2026-11-05	07:43:00	17:09:00	08:00:00	19:30:00	0	141	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1705	74	2026-11-07	09:36:00	14:46:00	07:00:00	22:00:00	141	434	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1706	74	2026-11-09	07:13:00	19:34:00	08:00:00	19:30:00	0	0	4	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1707	74	2026-11-10	07:13:00	19:38:00	08:00:00	17:00:00	0	0	158	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1708	74	2026-11-11	07:14:00	13:41:00	\N	\N	0	0	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	Non-working day: present due to attendance record
1709	74	2026-11-12	07:04:00	20:18:00	08:00:00	19:30:00	0	0	48	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1710	74	2026-11-13	07:14:00	16:18:00	08:00:00	15:00:00	0	0	78	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1711	75	2026-11-03	14:52:00	19:01:00	15:00:00	19:00:00	0	0	1	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1712	75	2026-11-04	14:58:00	19:11:00	15:00:00	19:00:00	0	0	11	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1713	75	2026-11-05	15:04:00	19:00:00	15:00:00	19:00:00	0	0	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1714	75	2026-11-06	14:52:00	19:02:00	15:00:00	19:00:00	0	0	2	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1715	75	2026-11-10	15:03:00	19:08:00	15:00:00	19:00:00	0	0	8	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1716	75	2026-11-11	15:03:00	19:07:00	15:00:00	19:00:00	0	0	7	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1717	75	2026-11-12	14:58:00	19:02:00	15:00:00	19:00:00	0	0	2	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1718	75	2026-11-13	15:02:00	19:02:00	15:00:00	19:00:00	0	0	2	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1719	76	2026-11-03	07:53:00	19:02:00	08:00:00	17:00:00	0	0	122	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1720	76	2026-11-05	07:32:00	19:43:00	08:00:00	19:00:00	0	0	43	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1721	76	2026-11-06	07:51:00	15:22:00	08:00:00	17:00:00	0	98	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1722	76	2026-11-07	07:55:00	17:00:00	\N	\N	0	0	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	Non-working day: present due to attendance record
1723	76	2026-11-09	07:58:00	19:04:00	08:00:00	19:00:00	0	0	4	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1724	76	2026-11-10	08:03:00	17:48:00	08:00:00	17:00:00	0	0	48	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1725	76	2026-11-11	07:56:00	12:00:00	08:00:00	12:00:00	0	0	0	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1726	76	2026-11-12	07:59:00	19:02:00	08:00:00	19:00:00	0	0	2	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
1727	76	2026-11-13	07:56:00	17:02:00	08:00:00	17:00:00	0	0	2	present	2026-11-24 14:07:37	2026-11-24 14:07:37	validated	\N
\.


--
-- Data for Name: cache; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cache (key, value, expiration) FROM stdin;
laravel-cache-test101@gmail.com|216.247.87.131:timer	i:1795596397;	1795596397
laravel-cache-test101@gmail.com|216.247.87.131	i:1;	1795596398
\.


--
-- Data for Name: cache_locks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cache_locks (key, owner, expiration) FROM stdin;
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.departments (id, name, created_at, updated_at) FROM stdin;
4	ASP	2026-10-12 21:11:10	2026-10-12 21:11:10
5	SABM - School of Accountancy, Business and Management	2026-10-12 21:11:11	2026-10-12 21:11:11
6	SAHS - School of Allied Health and Sciences	2026-10-12 21:11:11	2026-10-12 21:11:11
7	SACE - School of Architecture, Computing and Engineering	2026-10-12 21:11:12	2026-10-12 21:11:12
8	SHS - Senior High School	2026-10-12 21:11:12	2026-10-12 21:11:12
\.


--
-- Data for Name: employee_credentials; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.employee_credentials (id, employee_id, credential_type, title, department_id, expires_at, description, file_path, status, created_at, updated_at, original_filename, reviewed_by, reviewed_at, review_notes, degree_level) FROM stdin;
\.


--
-- Data for Name: employee_schedule_days; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.employee_schedule_days (id, schedule_submission_id, day_name, day_index, has_work, time_in, time_out, created_at, updated_at) FROM stdin;
151	18	Monday	1	t	08:00:00	17:00:00	2026-11-23 11:51:49	2026-11-23 11:51:49
152	18	Tuesday	2	t	07:00:00	17:00:00	2026-11-23 11:51:49	2026-11-23 11:51:49
153	18	Wednesday	3	f	\N	\N	2026-11-23 11:51:50	2026-11-23 11:51:50
154	18	Thursday	4	t	08:00:00	17:00:00	2026-11-23 11:51:50	2026-11-23 11:51:50
155	18	Friday	5	t	07:00:00	17:00:00	2026-11-23 11:51:50	2026-11-23 11:51:50
156	18	Saturday	6	t	09:00:00	16:00:00	2026-11-23 11:51:50	2026-11-23 11:51:50
163	20	Monday	1	t	09:00:00	19:00:00	2026-11-23 15:14:44	2026-11-23 15:14:44
164	20	Tuesday	2	t	08:00:00	17:00:00	2026-11-23 15:14:45	2026-11-23 15:14:45
165	20	Wednesday	3	f	\N	\N	2026-11-23 15:14:45	2026-11-23 15:14:45
166	20	Thursday	4	t	09:00:00	19:00:00	2026-11-23 15:14:45	2026-11-23 15:14:45
167	20	Friday	5	t	08:00:00	19:00:00	2026-11-23 15:14:45	2026-11-23 15:14:45
168	20	Saturday	6	t	09:00:00	13:00:00	2026-11-23 15:14:45	2026-11-23 15:14:45
169	21	Monday	1	t	07:00:00	19:00:00	2026-11-23 15:16:42	2026-11-23 15:16:42
170	21	Tuesday	2	t	11:00:00	19:00:00	2026-11-23 15:16:42	2026-11-23 15:16:42
171	21	Wednesday	3	f	\N	\N	2026-11-23 15:16:43	2026-11-23 15:16:43
172	21	Thursday	4	t	07:00:00	19:00:00	2026-11-23 15:16:43	2026-11-23 15:16:43
173	21	Friday	5	t	11:00:00	19:00:00	2026-11-23 15:16:43	2026-11-23 15:16:43
174	21	Saturday	6	t	07:00:00	11:00:00	2026-11-23 15:16:43	2026-11-23 15:16:43
175	22	Monday	1	t	07:00:00	19:00:00	2026-11-23 15:38:03	2026-11-23 15:38:03
176	22	Tuesday	2	t	11:00:00	17:00:00	2026-11-23 15:38:04	2026-11-23 15:38:04
177	22	Wednesday	3	t	10:00:00	17:00:00	2026-11-23 15:38:04	2026-11-23 15:38:04
178	22	Thursday	4	t	07:00:00	17:00:00	2026-11-23 15:38:04	2026-11-23 15:38:04
179	22	Friday	5	t	07:00:00	17:00:00	2026-11-23 15:38:04	2026-11-23 15:38:04
180	22	Saturday	6	f	\N	\N	2026-11-23 15:38:05	2026-11-23 15:38:05
181	23	Monday	1	t	12:00:00	18:00:00	2026-11-23 15:49:40	2026-11-23 15:49:40
182	23	Tuesday	2	t	08:00:00	20:00:00	2026-11-23 15:49:40	2026-11-23 15:49:40
183	23	Wednesday	3	t	07:00:00	19:00:00	2026-11-23 15:49:41	2026-11-23 15:49:41
184	23	Thursday	4	t	09:00:00	16:00:00	2026-11-23 15:49:41	2026-11-23 15:49:41
185	23	Friday	5	t	08:00:00	16:00:00	2026-11-23 15:49:41	2026-11-23 15:49:41
186	23	Saturday	6	f	\N	\N	2026-11-23 15:49:41	2026-11-23 15:49:41
187	24	Monday	1	t	07:00:00	17:00:00	2026-11-23 16:00:48	2026-11-23 16:00:48
188	24	Tuesday	2	t	08:00:00	17:00:00	2026-11-23 16:00:48	2026-11-23 16:00:48
189	24	Wednesday	3	t	08:00:00	17:00:00	2026-11-23 16:00:49	2026-11-23 16:00:49
190	24	Thursday	4	t	08:00:00	17:00:00	2026-11-23 16:00:49	2026-11-23 16:00:49
191	24	Friday	5	t	08:00:00	17:00:00	2026-11-23 16:00:49	2026-11-23 16:00:49
192	24	Saturday	6	f	\N	\N	2026-11-23 16:00:49	2026-11-23 16:00:49
193	25	Monday	1	t	08:00:00	17:00:00	2026-11-24 11:02:31	2026-11-24 11:02:31
194	25	Tuesday	2	t	07:00:00	17:00:00	2026-11-24 11:02:31	2026-11-24 11:02:31
195	25	Wednesday	3	t	07:00:00	18:00:00	2026-11-24 11:02:31	2026-11-24 11:02:31
196	25	Thursday	4	t	07:00:00	17:00:00	2026-11-24 11:02:31	2026-11-24 11:02:31
197	25	Friday	5	t	07:00:00	11:00:00	2026-11-24 11:02:32	2026-11-24 11:02:32
198	25	Saturday	6	f	\N	\N	2026-11-24 11:02:32	2026-11-24 11:02:32
199	26	Monday	1	t	08:30:00	17:30:00	2026-11-24 11:08:08	2026-11-24 11:08:08
200	26	Tuesday	2	t	08:30:00	17:30:00	2026-11-24 11:08:08	2026-11-24 11:08:08
201	26	Wednesday	3	t	08:30:00	17:30:00	2026-11-24 11:08:08	2026-11-24 11:08:08
202	26	Thursday	4	t	08:30:00	17:30:00	2026-11-24 11:08:08	2026-11-24 11:08:08
203	26	Friday	5	t	08:30:00	17:30:00	2026-11-24 11:08:09	2026-11-24 11:08:09
204	26	Saturday	6	f	\N	\N	2026-11-24 11:08:09	2026-11-24 11:08:09
205	27	Monday	1	t	07:00:00	18:00:00	2026-11-24 11:31:53	2026-11-24 11:31:53
206	27	Tuesday	2	t	07:00:00	16:00:00	2026-11-24 11:31:54	2026-11-24 11:31:54
207	27	Wednesday	3	t	07:00:00	19:00:00	2026-11-24 11:31:54	2026-11-24 11:31:54
208	27	Thursday	4	t	07:00:00	16:00:00	2026-11-24 11:31:54	2026-11-24 11:31:54
209	27	Friday	5	t	07:00:00	11:00:00	2026-11-24 11:31:54	2026-11-24 11:31:54
210	27	Saturday	6	f	\N	\N	2026-11-24 11:31:55	2026-11-24 11:31:55
211	28	Monday	1	t	08:00:00	19:00:00	2026-11-24 11:32:23	2026-11-24 11:32:23
212	28	Tuesday	2	t	08:00:00	19:00:00	2026-11-24 11:32:23	2026-11-24 11:32:23
213	28	Wednesday	3	t	08:00:00	19:00:00	2026-11-24 11:32:24	2026-11-24 11:32:24
214	28	Thursday	4	t	08:00:00	19:00:00	2026-11-24 11:32:24	2026-11-24 11:32:24
215	28	Friday	5	f	\N	\N	2026-11-24 11:32:24	2026-11-24 11:32:24
216	28	Saturday	6	f	\N	\N	2026-11-24 11:32:24	2026-11-24 11:32:24
217	29	Monday	1	t	08:30:00	17:30:00	2026-11-24 11:34:02	2026-11-24 11:34:02
218	29	Tuesday	2	t	08:30:00	17:30:00	2026-11-24 11:34:02	2026-11-24 11:34:02
219	29	Wednesday	3	t	08:30:00	17:30:00	2026-11-24 11:34:02	2026-11-24 11:34:02
220	29	Thursday	4	t	08:30:00	17:30:00	2026-11-24 11:34:03	2026-11-24 11:34:03
221	29	Friday	5	t	08:30:00	17:30:00	2026-11-24 11:34:03	2026-11-24 11:34:03
222	29	Saturday	6	f	\N	\N	2026-11-24 11:34:03	2026-11-24 11:34:03
223	30	Monday	1	t	08:00:00	17:00:00	2026-11-24 11:36:50	2026-11-24 11:36:50
224	30	Tuesday	2	t	08:00:00	17:00:00	2026-11-24 11:36:51	2026-11-24 11:36:51
225	30	Wednesday	3	t	08:00:00	17:00:00	2026-11-24 11:36:51	2026-11-24 11:36:51
226	30	Thursday	4	t	08:00:00	17:00:00	2026-11-24 11:36:51	2026-11-24 11:36:51
227	30	Friday	5	t	08:00:00	17:00:00	2026-11-24 11:36:51	2026-11-24 11:36:51
228	30	Saturday	6	f	\N	\N	2026-11-24 11:36:52	2026-11-24 11:36:52
229	31	Monday	1	t	06:30:00	17:00:00	2026-11-24 11:40:51	2026-11-24 11:40:51
230	31	Tuesday	2	t	06:30:00	16:00:00	2026-11-24 11:40:51	2026-11-24 11:40:51
231	31	Wednesday	3	f	\N	\N	2026-11-24 11:40:51	2026-11-24 11:40:51
232	31	Thursday	4	t	06:30:00	17:00:00	2026-11-24 11:40:51	2026-11-24 11:40:51
233	31	Friday	5	t	06:30:00	16:00:00	2026-11-24 11:40:52	2026-11-24 11:40:52
234	31	Saturday	6	t	11:00:00	15:00:00	2026-11-24 11:40:52	2026-11-24 11:40:52
235	32	Monday	1	t	07:00:00	17:00:00	2026-11-24 11:44:58	2026-11-24 11:44:58
236	32	Tuesday	2	t	07:00:00	17:00:00	2026-11-24 11:44:59	2026-11-24 11:44:59
237	32	Wednesday	3	t	07:00:00	18:00:00	2026-11-24 11:44:59	2026-11-24 11:44:59
238	32	Thursday	4	t	07:00:00	16:00:00	2026-11-24 11:44:59	2026-11-24 11:44:59
239	32	Friday	5	t	07:00:00	12:00:00	2026-11-24 11:44:59	2026-11-24 11:44:59
240	32	Saturday	6	f	\N	\N	2026-11-24 11:45:00	2026-11-24 11:45:00
241	33	Monday	1	t	06:30:00	16:30:00	2026-11-24 11:53:28	2026-11-24 11:53:28
242	33	Tuesday	2	t	09:30:00	14:00:00	2026-11-24 11:53:29	2026-11-24 11:53:29
243	33	Wednesday	3	t	06:30:00	18:30:00	2026-11-24 11:53:29	2026-11-24 11:53:29
244	33	Thursday	4	t	06:30:00	18:30:00	2026-11-24 11:53:29	2026-11-24 11:53:29
245	33	Friday	5	t	06:30:00	11:00:00	2026-11-24 11:53:29	2026-11-24 11:53:29
246	33	Saturday	6	f	\N	\N	2026-11-24 11:53:30	2026-11-24 11:53:30
247	34	Monday	1	t	07:00:00	19:00:00	2026-11-24 11:55:53	2026-11-24 11:55:53
248	34	Tuesday	2	t	09:30:00	19:30:00	2026-11-24 11:55:54	2026-11-24 11:55:54
249	34	Wednesday	3	f	\N	\N	2026-11-24 11:55:54	2026-11-24 11:55:54
250	34	Thursday	4	t	07:00:00	19:00:00	2026-11-24 11:55:54	2026-11-24 11:55:54
251	34	Friday	5	t	09:30:00	19:30:00	2026-11-24 11:55:54	2026-11-24 11:55:54
252	34	Saturday	6	f	\N	\N	2026-11-24 11:55:55	2026-11-24 11:55:55
253	35	Monday	1	f	\N	\N	2026-11-24 11:58:51	2026-11-24 11:58:51
254	35	Tuesday	2	t	07:00:00	17:00:00	2026-11-24 11:58:51	2026-11-24 11:58:51
255	35	Wednesday	3	t	07:00:00	17:00:00	2026-11-24 11:58:52	2026-11-24 11:58:52
256	35	Thursday	4	t	07:00:00	17:00:00	2026-11-24 11:58:52	2026-11-24 11:58:52
257	35	Friday	5	t	10:00:00	17:00:00	2026-11-24 11:58:52	2026-11-24 11:58:52
258	35	Saturday	6	t	09:00:00	17:00:00	2026-11-24 11:58:52	2026-11-24 11:58:52
259	36	Monday	1	t	06:30:00	15:30:00	2026-11-24 11:59:49	2026-11-24 11:59:49
260	36	Tuesday	2	t	06:30:00	15:30:00	2026-11-24 11:59:50	2026-11-24 11:59:50
261	36	Wednesday	3	t	06:30:00	15:30:00	2026-11-24 11:59:50	2026-11-24 11:59:50
262	36	Thursday	4	t	06:30:00	15:30:00	2026-11-24 11:59:50	2026-11-24 11:59:50
263	36	Friday	5	t	06:30:00	15:30:00	2026-11-24 11:59:50	2026-11-24 11:59:50
264	36	Saturday	6	f	\N	\N	2026-11-24 11:59:51	2026-11-24 11:59:51
265	37	Monday	1	t	09:30:00	19:30:00	2026-11-24 12:02:24	2026-11-24 12:02:24
266	37	Tuesday	2	t	09:00:00	19:30:00	2026-11-24 12:02:24	2026-11-24 12:02:24
267	37	Wednesday	3	t	09:30:00	19:30:00	2026-11-24 12:02:25	2026-11-24 12:02:25
268	37	Thursday	4	t	09:30:00	19:30:00	2026-11-24 12:02:25	2026-11-24 12:02:25
269	37	Friday	5	t	09:00:00	13:00:00	2026-11-24 12:02:25	2026-11-24 12:02:25
270	37	Saturday	6	f	\N	\N	2026-11-24 12:02:25	2026-11-24 12:02:25
271	38	Monday	1	t	07:00:00	11:00:00	2026-11-24 13:39:25	2026-11-24 13:39:25
272	38	Tuesday	2	t	07:00:00	19:00:00	2026-11-24 13:39:25	2026-11-24 13:39:25
273	38	Wednesday	3	t	07:00:00	18:00:00	2026-11-24 13:39:25	2026-11-24 13:39:25
274	38	Thursday	4	t	07:00:00	11:00:00	2026-11-24 13:39:25	2026-11-24 13:39:25
275	38	Friday	5	t	07:00:00	19:00:00	2026-11-24 13:39:26	2026-11-24 13:39:26
276	38	Saturday	6	f	\N	\N	2026-11-24 13:39:26	2026-11-24 13:39:26
277	39	Monday	1	t	10:30:00	19:30:00	2026-11-24 13:48:33	2026-11-24 13:48:33
278	39	Tuesday	2	f	\N	\N	2026-11-24 13:48:34	2026-11-24 13:48:34
279	39	Wednesday	3	t	08:30:00	19:30:00	2026-11-24 13:48:34	2026-11-24 13:48:34
280	39	Thursday	4	t	10:30:00	19:30:00	2026-11-24 13:48:34	2026-11-24 13:48:34
281	39	Friday	5	t	08:30:00	19:30:00	2026-11-24 13:48:34	2026-11-24 13:48:34
282	39	Saturday	6	t	07:00:00	11:00:00	2026-11-24 13:48:35	2026-11-24 13:48:35
283	40	Monday	1	t	08:30:00	17:30:00	2026-11-24 13:50:10	2026-11-24 13:50:10
284	40	Tuesday	2	t	08:03:00	17:30:00	2026-11-24 13:50:10	2026-11-24 13:50:10
285	40	Wednesday	3	t	08:30:00	17:30:00	2026-11-24 13:50:10	2026-11-24 13:50:10
286	40	Thursday	4	t	08:30:00	17:30:00	2026-11-24 13:50:10	2026-11-24 13:50:10
287	40	Friday	5	t	08:30:00	17:30:00	2026-11-24 13:50:11	2026-11-24 13:50:11
288	40	Saturday	6	t	08:30:00	17:30:00	2026-11-24 13:50:11	2026-11-24 13:50:11
289	41	Monday	1	t	07:00:00	15:00:00	2026-11-24 13:51:37	2026-11-24 13:51:37
290	41	Tuesday	2	t	07:00:00	19:00:00	2026-11-24 13:51:37	2026-11-24 13:51:37
291	41	Wednesday	3	t	07:00:00	12:00:00	2026-11-24 13:51:37	2026-11-24 13:51:37
292	41	Thursday	4	t	07:00:00	15:00:00	2026-11-24 13:51:37	2026-11-24 13:51:37
293	41	Friday	5	t	07:00:00	19:00:00	2026-11-24 13:51:38	2026-11-24 13:51:38
294	41	Saturday	6	f	\N	\N	2026-11-24 13:51:38	2026-11-24 13:51:38
295	42	Monday	1	t	08:00:00	18:00:00	2026-11-24 13:53:19	2026-11-24 13:53:19
296	42	Tuesday	2	t	08:00:00	17:00:00	2026-11-24 13:53:19	2026-11-24 13:53:19
297	42	Wednesday	3	f	\N	\N	2026-11-24 13:53:19	2026-11-24 13:53:19
298	42	Thursday	4	t	08:00:00	18:00:00	2026-11-24 13:53:19	2026-11-24 13:53:19
299	42	Friday	5	t	08:00:00	16:00:00	2026-11-24 13:53:20	2026-11-24 13:53:20
300	42	Saturday	6	t	08:00:00	16:00:00	2026-11-24 13:53:20	2026-11-24 13:53:20
301	43	Monday	1	t	08:30:00	17:30:00	2026-11-24 13:54:49	2026-11-24 13:54:49
302	43	Tuesday	2	t	08:30:00	17:30:00	2026-11-24 13:54:50	2026-11-24 13:54:50
303	43	Wednesday	3	t	08:30:00	17:30:00	2026-11-24 13:54:50	2026-11-24 13:54:50
304	43	Thursday	4	t	08:30:00	17:30:00	2026-11-24 13:54:50	2026-11-24 13:54:50
305	43	Friday	5	t	08:30:00	17:30:00	2026-11-24 13:54:50	2026-11-24 13:54:50
306	43	Saturday	6	f	\N	\N	2026-11-24 13:54:51	2026-11-24 13:54:51
307	44	Monday	1	t	07:00:00	17:00:00	2026-11-24 13:55:46	2026-11-24 13:55:46
308	44	Tuesday	2	t	08:00:00	17:00:00	2026-11-24 13:55:46	2026-11-24 13:55:46
309	44	Wednesday	3	t	08:00:00	17:00:00	2026-11-24 13:55:46	2026-11-24 13:55:46
310	44	Thursday	4	t	08:00:00	17:00:00	2026-11-24 13:55:47	2026-11-24 13:55:47
311	44	Friday	5	t	08:00:00	16:00:00	2026-11-24 13:55:47	2026-11-24 13:55:47
312	44	Saturday	6	f	\N	\N	2026-11-24 13:55:47	2026-11-24 13:55:47
313	45	Monday	1	t	08:00:00	17:00:00	2026-11-24 13:56:29	2026-11-24 13:56:29
314	45	Tuesday	2	t	08:00:00	17:00:00	2026-11-24 13:56:29	2026-11-24 13:56:29
315	45	Wednesday	3	t	08:00:00	17:00:00	2026-11-24 13:56:29	2026-11-24 13:56:29
316	45	Thursday	4	t	08:00:00	17:00:00	2026-11-24 13:56:29	2026-11-24 13:56:29
317	45	Friday	5	t	08:00:00	17:00:00	2026-11-24 13:56:29	2026-11-24 13:56:29
318	45	Saturday	6	f	\N	\N	2026-11-24 13:56:30	2026-11-24 13:56:30
319	46	Monday	1	t	08:00:00	19:30:00	2026-11-24 13:58:32	2026-11-24 13:58:32
320	46	Tuesday	2	t	08:00:00	17:00:00	2026-11-24 13:58:32	2026-11-24 13:58:32
321	46	Wednesday	3	f	\N	\N	2026-11-24 13:58:32	2026-11-24 13:58:32
322	46	Thursday	4	t	08:00:00	19:30:00	2026-11-24 13:58:33	2026-11-24 13:58:33
323	46	Friday	5	t	08:00:00	15:00:00	2026-11-24 13:58:33	2026-11-24 13:58:33
324	46	Saturday	6	t	07:00:00	22:00:00	2026-11-24 13:58:33	2026-11-24 13:58:33
325	47	Monday	1	t	15:00:00	19:00:00	2026-11-24 14:03:12	2026-11-24 14:03:12
326	47	Tuesday	2	t	15:00:00	19:00:00	2026-11-24 14:03:12	2026-11-24 14:03:12
327	47	Wednesday	3	t	15:00:00	19:00:00	2026-11-24 14:03:13	2026-11-24 14:03:13
328	47	Thursday	4	t	15:00:00	19:00:00	2026-11-24 14:03:13	2026-11-24 14:03:13
329	47	Friday	5	t	15:00:00	19:00:00	2026-11-24 14:03:13	2026-11-24 14:03:13
330	47	Saturday	6	f	\N	\N	2026-11-24 14:03:13	2026-11-24 14:03:13
331	48	Monday	1	t	07:00:00	19:00:00	2026-11-24 14:03:46	2026-11-24 14:03:46
332	48	Tuesday	2	t	07:00:00	13:00:00	2026-11-24 14:03:46	2026-11-24 14:03:46
333	48	Wednesday	3	t	07:00:00	17:00:00	2026-11-24 14:03:46	2026-11-24 14:03:46
334	48	Thursday	4	t	07:00:00	13:00:00	2026-11-24 14:03:46	2026-11-24 14:03:46
335	48	Friday	5	t	07:00:00	17:00:00	2026-11-24 14:03:47	2026-11-24 14:03:47
336	48	Saturday	6	f	\N	\N	2026-11-24 14:03:47	2026-11-24 14:03:47
337	49	Monday	1	t	08:00:00	19:00:00	2026-11-24 14:05:00	2026-11-24 14:05:00
338	49	Tuesday	2	t	08:00:00	17:00:00	2026-11-24 14:05:00	2026-11-24 14:05:00
339	49	Wednesday	3	t	08:00:00	12:00:00	2026-11-24 14:05:00	2026-11-24 14:05:00
340	49	Thursday	4	t	08:00:00	19:00:00	2026-11-24 14:05:01	2026-11-24 14:05:01
341	49	Friday	5	t	08:00:00	17:00:00	2026-11-24 14:05:01	2026-11-24 14:05:01
342	49	Saturday	6	f	\N	\N	2026-11-24 14:05:01	2026-11-24 14:05:01
343	50	Monday	1	f	\N	\N	2026-11-25 14:01:52	2026-11-25 14:01:52
344	50	Tuesday	2	t	07:00:00	16:00:00	2026-11-25 14:01:53	2026-11-25 14:01:53
345	50	Wednesday	3	t	07:00:00	16:00:00	2026-11-25 14:01:53	2026-11-25 14:01:53
346	50	Thursday	4	t	08:40:00	17:40:00	2026-11-25 14:01:53	2026-11-25 14:01:53
347	50	Friday	5	t	07:00:00	16:00:00	2026-11-25 14:01:53	2026-11-25 14:01:53
348	50	Saturday	6	t	07:00:00	16:00:00	2026-11-25 14:01:53	2026-11-25 14:01:53
349	51	Monday	1	t	08:40:00	17:40:00	2026-11-25 14:05:35	2026-11-25 14:05:35
350	51	Tuesday	2	t	08:40:00	17:40:00	2026-11-25 14:05:35	2026-11-25 14:05:35
351	51	Wednesday	3	t	08:20:00	20:20:00	2026-11-25 14:05:35	2026-11-25 14:05:35
352	51	Thursday	4	t	07:40:00	17:40:00	2026-11-25 14:05:36	2026-11-25 14:05:36
353	51	Friday	5	t	08:00:00	12:00:00	2026-11-25 14:05:36	2026-11-25 14:05:36
354	51	Saturday	6	f	\N	\N	2026-11-25 14:05:36	2026-11-25 14:05:36
355	52	Monday	1	t	07:00:00	16:00:00	2026-11-25 14:12:29	2026-11-25 14:12:29
356	52	Tuesday	2	t	11:00:00	20:00:00	2026-11-25 14:12:29	2026-11-25 14:12:29
357	52	Wednesday	3	t	09:00:00	18:00:00	2026-11-25 14:12:30	2026-11-25 14:12:30
358	52	Thursday	4	t	07:00:00	16:00:00	2026-11-25 14:12:30	2026-11-25 14:12:30
359	52	Friday	5	t	09:00:00	18:00:00	2026-11-25 14:12:30	2026-11-25 14:12:30
360	52	Saturday	6	f	\N	\N	2026-11-25 14:12:30	2026-11-25 14:12:30
361	53	Monday	1	t	07:00:00	16:00:00	2026-11-25 14:14:32	2026-11-25 14:14:32
362	53	Tuesday	2	t	07:00:00	16:00:00	2026-11-25 14:14:32	2026-11-25 14:14:32
363	53	Wednesday	3	t	07:00:00	16:00:00	2026-11-25 14:14:32	2026-11-25 14:14:32
364	53	Thursday	4	t	07:00:00	16:00:00	2026-11-25 14:14:32	2026-11-25 14:14:32
365	53	Friday	5	t	07:00:00	16:00:00	2026-11-25 14:14:33	2026-11-25 14:14:33
366	53	Saturday	6	f	\N	\N	2026-11-25 14:14:33	2026-11-25 14:14:33
367	54	Monday	1	f	\N	\N	2026-11-25 14:26:16	2026-11-25 14:26:16
368	54	Tuesday	2	t	09:00:00	19:00:00	2026-11-25 14:26:16	2026-11-25 14:26:16
369	54	Wednesday	3	f	\N	\N	2026-11-25 14:26:16	2026-11-25 14:26:16
370	54	Thursday	4	f	\N	\N	2026-11-25 14:26:16	2026-11-25 14:26:16
371	54	Friday	5	t	09:00:00	19:00:00	2026-11-25 14:26:17	2026-11-25 14:26:17
372	54	Saturday	6	f	\N	\N	2026-11-25 14:26:17	2026-11-25 14:26:17
373	55	Monday	1	f	\N	\N	2026-11-25 14:27:23	2026-11-25 14:27:23
374	55	Tuesday	2	f	\N	\N	2026-11-25 14:27:24	2026-11-25 14:27:24
375	55	Wednesday	3	t	09:00:00	19:00:00	2026-11-25 14:27:24	2026-11-25 14:27:24
376	55	Thursday	4	f	\N	\N	2026-11-25 14:27:24	2026-11-25 14:27:24
377	55	Friday	5	f	\N	\N	2026-11-25 14:27:24	2026-11-25 14:27:24
378	55	Saturday	6	t	09:00:00	19:00:00	2026-11-25 14:27:24	2026-11-25 14:27:24
379	56	Monday	1	f	\N	\N	2026-11-25 14:29:11	2026-11-25 14:29:11
380	56	Tuesday	2	t	09:00:00	19:00:00	2026-11-25 14:29:12	2026-11-25 14:29:12
381	56	Wednesday	3	f	\N	\N	2026-11-25 14:29:12	2026-11-25 14:29:12
382	56	Thursday	4	f	\N	\N	2026-11-25 14:29:12	2026-11-25 14:29:12
383	56	Friday	5	f	\N	\N	2026-11-25 14:29:12	2026-11-25 14:29:12
384	56	Saturday	6	f	\N	\N	2026-11-25 14:29:13	2026-11-25 14:29:13
385	57	Monday	1	f	\N	\N	2026-11-25 14:30:36	2026-11-25 14:30:36
386	57	Tuesday	2	t	07:00:00	19:00:00	2026-11-25 14:30:37	2026-11-25 14:30:37
387	57	Wednesday	3	f	\N	\N	2026-11-25 14:30:37	2026-11-25 14:30:37
388	57	Thursday	4	f	\N	\N	2026-11-25 14:30:37	2026-11-25 14:30:37
389	57	Friday	5	t	15:00:00	19:00:00	2026-11-25 14:30:37	2026-11-25 14:30:37
390	57	Saturday	6	f	\N	\N	2026-11-25 14:30:38	2026-11-25 14:30:38
391	58	Monday	1	f	\N	\N	2026-11-25 14:30:47	2026-11-25 14:30:47
392	58	Tuesday	2	t	07:00:00	17:00:00	2026-11-25 14:30:48	2026-11-25 14:30:48
393	58	Wednesday	3	t	13:00:00	17:00:00	2026-11-25 14:30:48	2026-11-25 14:30:48
394	58	Thursday	4	t	07:00:00	17:00:00	2026-11-25 14:30:48	2026-11-25 14:30:48
395	58	Friday	5	t	07:00:00	17:00:00	2026-11-25 14:30:48	2026-11-25 14:30:48
396	58	Saturday	6	t	07:00:00	17:00:00	2026-11-25 14:30:48	2026-11-25 14:30:48
397	59	Monday	1	f	\N	\N	2026-11-25 14:31:25	2026-11-25 14:31:25
398	59	Tuesday	2	f	\N	\N	2026-11-25 14:31:25	2026-11-25 14:31:25
399	59	Wednesday	3	f	\N	\N	2026-11-25 14:31:25	2026-11-25 14:31:25
400	59	Thursday	4	f	\N	\N	2026-11-25 14:31:25	2026-11-25 14:31:25
401	59	Friday	5	f	\N	\N	2026-11-25 14:31:26	2026-11-25 14:31:26
402	59	Saturday	6	t	09:00:00	19:00:00	2026-11-25 14:31:26	2026-11-25 14:31:26
403	60	Monday	1	f	\N	\N	2026-11-25 14:32:39	2026-11-25 14:32:39
404	60	Tuesday	2	f	\N	\N	2026-11-25 14:32:39	2026-11-25 14:32:39
405	60	Wednesday	3	t	07:00:00	15:00:00	2026-11-25 14:32:39	2026-11-25 14:32:39
406	60	Thursday	4	f	\N	\N	2026-11-25 14:32:39	2026-11-25 14:32:39
407	60	Friday	5	t	09:00:00	19:00:00	2026-11-25 14:32:40	2026-11-25 14:32:40
408	60	Saturday	6	f	\N	\N	2026-11-25 14:32:40	2026-11-25 14:32:40
409	61	Monday	1	f	\N	\N	2026-11-25 14:33:16	2026-11-25 14:33:16
410	61	Tuesday	2	f	\N	\N	2026-11-25 14:33:16	2026-11-25 14:33:16
411	61	Wednesday	3	f	\N	\N	2026-11-25 14:33:17	2026-11-25 14:33:17
412	61	Thursday	4	f	\N	\N	2026-11-25 14:33:17	2026-11-25 14:33:17
413	61	Friday	5	f	\N	\N	2026-11-25 14:33:17	2026-11-25 14:33:17
414	61	Saturday	6	t	07:00:00	17:00:00	2026-11-25 14:33:17	2026-11-25 14:33:17
415	62	Monday	1	f	\N	\N	2026-11-25 14:34:42	2026-11-25 14:34:42
416	62	Tuesday	2	t	09:00:00	15:00:00	2026-11-25 14:34:42	2026-11-25 14:34:42
417	62	Wednesday	3	t	13:00:00	17:00:00	2026-11-25 14:34:42	2026-11-25 14:34:42
418	62	Thursday	4	f	\N	\N	2026-11-25 14:34:42	2026-11-25 14:34:42
419	62	Friday	5	t	09:00:00	15:00:00	2026-11-25 14:34:42	2026-11-25 14:34:42
420	62	Saturday	6	f	\N	\N	2026-11-25 14:34:43	2026-11-25 14:34:43
421	63	Monday	1	t	07:00:00	16:00:00	2026-11-25 14:55:32	2026-11-25 14:55:32
422	63	Tuesday	2	t	07:00:00	17:00:00	2026-11-25 14:55:32	2026-11-25 14:55:32
423	63	Wednesday	3	t	09:00:00	15:00:00	2026-11-25 14:55:32	2026-11-25 14:55:32
424	63	Thursday	4	t	07:00:00	17:00:00	2026-11-25 14:55:32	2026-11-25 14:55:32
425	63	Friday	5	t	07:00:00	17:00:00	2026-11-25 14:55:33	2026-11-25 14:55:33
426	63	Saturday	6	f	\N	\N	2026-11-25 14:55:33	2026-11-25 14:55:33
427	64	Monday	1	t	07:00:00	16:00:00	2026-11-25 15:35:41	2026-11-25 15:35:41
428	64	Tuesday	2	t	07:00:00	16:00:00	2026-11-25 15:35:41	2026-11-25 15:35:41
429	64	Wednesday	3	t	07:00:00	16:00:00	2026-11-25 15:35:42	2026-11-25 15:35:42
430	64	Thursday	4	t	07:00:00	16:00:00	2026-11-25 15:35:42	2026-11-25 15:35:42
431	64	Friday	5	t	07:00:00	16:00:00	2026-11-25 15:35:42	2026-11-25 15:35:42
432	64	Saturday	6	f	\N	\N	2026-11-25 15:35:42	2026-11-25 15:35:42
433	65	Monday	1	t	07:00:00	16:00:00	2026-11-25 15:37:28	2026-11-25 15:37:28
434	65	Tuesday	2	t	07:00:00	16:00:00	2026-11-25 15:37:29	2026-11-25 15:37:29
435	65	Wednesday	3	t	07:00:00	16:00:00	2026-11-25 15:37:29	2026-11-25 15:37:29
436	65	Thursday	4	t	07:00:00	16:00:00	2026-11-25 15:37:29	2026-11-25 15:37:29
437	65	Friday	5	t	07:00:00	16:00:00	2026-11-25 15:37:29	2026-11-25 15:37:29
438	65	Saturday	6	f	\N	\N	2026-11-25 15:37:30	2026-11-25 15:37:30
439	66	Monday	1	t	07:00:00	17:00:00	2026-11-26 09:50:14	2026-11-26 09:50:14
440	66	Tuesday	2	t	07:00:00	17:00:00	2026-11-26 09:50:14	2026-11-26 09:50:14
441	66	Wednesday	3	t	07:00:00	17:00:00	2026-11-26 09:50:14	2026-11-26 09:50:14
442	66	Thursday	4	t	07:00:00	17:00:00	2026-11-26 09:50:15	2026-11-26 09:50:15
443	66	Friday	5	t	07:00:00	16:00:00	2026-11-26 09:50:15	2026-11-26 09:50:15
444	66	Saturday	6	t	08:30:00	12:30:00	2026-11-26 09:50:15	2026-11-26 09:50:15
445	67	Monday	1	t	07:00:00	17:00:00	2026-11-26 09:52:10	2026-11-26 09:52:10
446	67	Tuesday	2	f	\N	\N	2026-11-26 09:52:10	2026-11-26 09:52:10
447	67	Wednesday	3	t	07:00:00	15:00:00	2026-11-26 09:52:10	2026-11-26 09:52:10
448	67	Thursday	4	t	07:00:00	17:00:00	2026-11-26 09:52:10	2026-11-26 09:52:10
449	67	Friday	5	f	\N	\N	2026-11-26 09:52:11	2026-11-26 09:52:11
450	67	Saturday	6	t	07:00:00	15:00:00	2026-11-26 09:52:11	2026-11-26 09:52:11
451	68	Monday	1	f	\N	\N	2026-11-26 09:54:38	2026-11-26 09:54:38
452	68	Tuesday	2	f	\N	\N	2026-11-26 09:54:38	2026-11-26 09:54:38
453	68	Wednesday	3	t	15:00:00	19:00:00	2026-11-26 09:54:38	2026-11-26 09:54:38
454	68	Thursday	4	t	07:00:00	20:00:00	2026-11-26 09:54:39	2026-11-26 09:54:39
455	68	Friday	5	f	\N	\N	2026-11-26 09:54:39	2026-11-26 09:54:39
456	68	Saturday	6	f	\N	\N	2026-11-26 09:54:39	2026-11-26 09:54:39
457	69	Monday	1	f	\N	\N	2026-11-26 09:55:27	2026-11-26 09:55:27
458	69	Tuesday	2	t	07:00:00	16:00:00	2026-11-26 09:55:27	2026-11-26 09:55:27
459	69	Wednesday	3	f	\N	\N	2026-11-26 09:55:27	2026-11-26 09:55:27
460	69	Thursday	4	f	\N	\N	2026-11-26 09:55:27	2026-11-26 09:55:27
461	69	Friday	5	t	07:00:00	16:00:00	2026-11-26 09:55:28	2026-11-26 09:55:28
462	69	Saturday	6	f	\N	\N	2026-11-26 09:55:28	2026-11-26 09:55:28
463	70	Monday	1	t	08:00:00	18:00:00	2026-11-26 09:57:12	2026-11-26 09:57:12
464	70	Tuesday	2	t	08:00:00	18:00:00	2026-11-26 09:57:13	2026-11-26 09:57:13
465	70	Wednesday	3	t	08:00:00	18:00:00	2026-11-26 09:57:13	2026-11-26 09:57:13
466	70	Thursday	4	t	08:00:00	18:00:00	2026-11-26 09:57:13	2026-11-26 09:57:13
467	70	Friday	5	t	08:30:00	17:30:00	2026-11-26 09:57:13	2026-11-26 09:57:13
468	70	Saturday	6	t	08:30:00	12:30:00	2026-11-26 09:57:14	2026-11-26 09:57:14
469	71	Monday	1	t	08:30:00	17:30:00	2026-11-26 09:59:55	2026-11-26 09:59:55
470	71	Tuesday	2	t	07:00:00	18:00:00	2026-11-26 09:59:55	2026-11-26 09:59:55
471	71	Wednesday	3	t	09:00:00	18:00:00	2026-11-26 09:59:56	2026-11-26 09:59:56
472	71	Thursday	4	t	08:30:00	12:30:00	2026-11-26 09:59:56	2026-11-26 09:59:56
473	71	Friday	5	t	07:00:00	18:00:00	2026-11-26 09:59:56	2026-11-26 09:59:56
474	71	Saturday	6	f	\N	\N	2026-11-26 09:59:56	2026-11-26 09:59:56
475	72	Monday	1	f	\N	\N	2026-11-26 10:01:04	2026-11-26 10:01:04
476	72	Tuesday	2	f	\N	\N	2026-11-26 10:01:04	2026-11-26 10:01:04
477	72	Wednesday	3	f	\N	\N	2026-11-26 10:01:04	2026-11-26 10:01:04
478	72	Thursday	4	f	\N	\N	2026-11-26 10:01:05	2026-11-26 10:01:05
479	72	Friday	5	f	\N	\N	2026-11-26 10:01:05	2026-11-26 10:01:05
480	72	Saturday	6	t	07:00:00	20:00:00	2026-11-26 10:01:05	2026-11-26 10:01:05
481	73	Monday	1	t	08:00:00	17:00:00	2026-11-26 10:03:43	2026-11-26 10:03:43
482	73	Tuesday	2	t	08:00:00	17:00:00	2026-11-26 10:03:43	2026-11-26 10:03:43
483	73	Wednesday	3	t	08:00:00	17:00:00	2026-11-26 10:03:43	2026-11-26 10:03:43
484	73	Thursday	4	t	08:00:00	17:00:00	2026-11-26 10:03:44	2026-11-26 10:03:44
485	73	Friday	5	t	08:00:00	17:00:00	2026-11-26 10:03:44	2026-11-26 10:03:44
486	73	Saturday	6	f	\N	\N	2026-11-26 10:03:44	2026-11-26 10:03:44
487	74	Monday	1	f	\N	\N	2026-11-26 10:05:27	2026-11-26 10:05:27
488	74	Tuesday	2	f	\N	\N	2026-11-26 10:05:28	2026-11-26 10:05:28
489	74	Wednesday	3	t	09:00:00	19:00:00	2026-11-26 10:05:28	2026-11-26 10:05:28
490	74	Thursday	4	f	\N	\N	2026-11-26 10:05:28	2026-11-26 10:05:28
491	74	Friday	5	f	\N	\N	2026-11-26 10:05:28	2026-11-26 10:05:28
492	74	Saturday	6	t	09:00:00	19:00:00	2026-11-26 10:05:28	2026-11-26 10:05:28
493	75	Monday	1	t	07:00:00	19:00:00	2026-11-26 10:23:44	2026-11-26 10:23:44
494	75	Tuesday	2	t	11:00:00	19:00:00	2026-11-26 10:23:44	2026-11-26 10:23:44
495	75	Wednesday	3	t	08:00:00	12:00:00	2026-11-26 10:23:44	2026-11-26 10:23:44
496	75	Thursday	4	t	07:00:00	19:00:00	2026-11-26 10:23:45	2026-11-26 10:23:45
497	75	Friday	5	t	11:00:00	19:00:00	2026-11-26 10:23:45	2026-11-26 10:23:45
498	75	Saturday	6	f	\N	\N	2026-11-26 10:23:45	2026-11-26 10:23:45
499	76	Monday	1	t	07:00:00	19:00:00	2026-11-26 10:26:14	2026-11-26 10:26:14
500	76	Tuesday	2	t	09:00:00	19:00:00	2026-11-26 10:26:14	2026-11-26 10:26:14
501	76	Wednesday	3	f	\N	\N	2026-11-26 10:26:15	2026-11-26 10:26:15
502	76	Thursday	4	t	07:00:00	19:00:00	2026-11-26 10:26:15	2026-11-26 10:26:15
503	76	Friday	5	t	09:00:00	19:00:00	2026-11-26 10:26:15	2026-11-26 10:26:15
504	76	Saturday	6	f	\N	\N	2026-11-26 10:26:15	2026-11-26 10:26:15
505	77	Monday	1	t	13:00:00	20:00:00	2026-11-26 10:28:23	2026-11-26 10:28:23
506	77	Tuesday	2	f	\N	\N	2026-11-26 10:28:23	2026-11-26 10:28:23
507	77	Wednesday	3	f	\N	\N	2026-11-26 10:28:23	2026-11-26 10:28:23
508	77	Thursday	4	f	\N	\N	2026-11-26 10:28:23	2026-11-26 10:28:23
509	77	Friday	5	t	17:00:00	21:00:00	2026-11-26 10:28:24	2026-11-26 10:28:24
510	77	Saturday	6	f	\N	\N	2026-11-26 10:28:24	2026-11-26 10:28:24
\.


--
-- Data for Name: employee_schedule_submissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.employee_schedule_submissions (id, employee_id, submitted_by, reviewed_by, semester_label, academic_year, status, submitted_at, reviewed_at, review_notes, is_current, created_at, updated_at, term_label, term_start_date) FROM stdin;
48	41	41	41	2nd Term	\N	approved	2026-11-24 14:03:45	2026-11-24 14:03:45	Added and approved by HR	t	2026-11-24 14:03:45	2026-11-24 14:03:45	2nd Term	\N
49	76	41	41	2nd Term	\N	approved	2026-11-24 14:05:00	2026-11-24 14:05:00	Added and approved by Admin	t	2026-11-24 14:05:00	2026-11-24 14:05:00	2nd Term	\N
50	80	41	41	2nd Term	\N	approved	2026-11-25 14:01:52	2026-11-25 14:01:52	Added and approved by HR	t	2026-11-25 14:01:52	2026-11-25 14:01:52	2nd Term	\N
18	32	41	41	2nd Term	\N	approved	2026-11-23 11:51:49	2026-11-23 11:51:49	Added and approved by HR	t	2026-11-23 11:51:49	2026-11-23 11:51:49	2nd Term	2026-11-02
17	32	41	41	2nd Term	\N	reset	2026-11-23 11:46:16	2026-11-23 11:47:23	Cleared by HR	f	2026-11-23 11:46:16	2026-11-23 11:51:50	2nd Term	2026-11-03
20	34	41	41	2nd Term	\N	approved	2026-11-23 15:14:44	2026-11-23 15:14:44	Added and approved by HR	t	2026-11-23 15:14:44	2026-11-23 15:14:44	2nd Term	\N
19	34	41	41	2nd Term	\N	reset	2026-11-23 15:00:53	2026-11-23 15:09:50	Cleared by HR	f	2026-11-23 15:00:53	2026-11-23 15:14:46	2nd Term	\N
21	35	41	41	2nd Term	\N	approved	2026-11-23 15:16:42	2026-11-23 15:16:42	Added and approved by HR	t	2026-11-23 15:16:42	2026-11-23 15:16:42	2nd Term	\N
22	37	41	41	2nd Term	\N	approved	2026-11-23 15:38:03	2026-11-23 15:38:03	Added and approved by HR	t	2026-11-23 15:38:03	2026-11-23 15:38:03	2nd Term	\N
23	38	41	41	2nd Term	\N	approved	2026-11-23 15:49:40	2026-11-23 15:49:40	Added and approved by HR	t	2026-11-23 15:49:40	2026-11-23 15:49:40	2nd Term	\N
24	39	41	41	2nd Term	\N	approved	2026-11-23 16:00:48	2026-11-23 16:00:48	Added and approved by HR	t	2026-11-23 16:00:48	2026-11-23 16:00:48	2nd Term	\N
25	48	41	41	2nd Term	\N	approved	2026-11-24 11:02:30	2026-11-24 11:02:30	Added and approved by HR	t	2026-11-24 11:02:30	2026-11-24 11:02:30	2nd Term	\N
26	45	41	41	2nd Term	\N	approved	2026-11-24 11:08:07	2026-11-24 11:08:07	Added and approved by HR	t	2026-11-24 11:08:07	2026-11-24 11:08:07	2nd Term	\N
27	46	41	41	2nd Term	\N	approved	2026-11-24 11:31:53	2026-11-24 11:31:53	Added and approved by HR	t	2026-11-24 11:31:53	2026-11-24 11:31:53	2nd Term	\N
28	59	41	41	2nd Term	\N	approved	2026-11-24 11:32:23	2026-11-24 11:32:23	Added and approved by Admin	t	2026-11-24 11:32:23	2026-11-24 11:32:23	2nd Term	\N
29	49	41	41	2nd Term	\N	approved	2026-11-24 11:34:02	2026-11-24 11:34:02	Added and approved by HR	t	2026-11-24 11:34:02	2026-11-24 11:34:02	2nd Term	\N
30	60	41	41	2nd Term	\N	approved	2026-11-24 11:36:50	2026-11-24 11:36:50	Added and approved by Admin	t	2026-11-24 11:36:50	2026-11-24 11:36:50	2nd Term	\N
31	58	41	41	2nd Term	\N	approved	2026-11-24 11:40:50	2026-11-24 11:40:50	Added and approved by HR	t	2026-11-24 11:40:50	2026-11-24 11:40:50	2nd Term	\N
32	33	41	41	2nd Term	\N	approved	2026-11-24 11:44:58	2026-11-24 11:44:58	Added and approved by HR	t	2026-11-24 11:44:58	2026-11-24 11:44:58	2nd Term	2026-11-03
33	36	41	41	2nd Term	\N	approved	2026-11-24 11:53:28	2026-11-24 11:53:28	Added and approved by HR	t	2026-11-24 11:53:28	2026-11-24 11:53:28	2nd Term	\N
34	62	41	41	2nd Term	\N	approved	2026-11-24 11:55:53	2026-11-24 11:55:53	Added and approved by Admin	t	2026-11-24 11:55:53	2026-11-24 11:55:53	2nd Term	\N
35	47	41	41	2nd Term	\N	approved	2026-11-24 11:58:51	2026-11-24 11:58:51	Added and approved by HR	t	2026-11-24 11:58:51	2026-11-24 11:58:51	2nd Term	\N
36	65	41	41	2nd Term	\N	approved	2026-11-24 11:59:49	2026-11-24 11:59:49	Added and approved by Admin	t	2026-11-24 11:59:49	2026-11-24 11:59:49	2nd Term	\N
37	67	41	41	2nd Term	\N	approved	2026-11-24 12:02:24	2026-11-24 12:02:24	Added and approved by Admin	t	2026-11-24 12:02:24	2026-11-24 12:02:24	2nd Term	\N
38	61	41	41	2nd Term	\N	approved	2026-11-24 13:39:24	2026-11-24 13:39:24	Added and approved by HR	t	2026-11-24 13:39:24	2026-11-24 13:39:24	2nd Term	\N
39	68	41	41	2nd Term	\N	approved	2026-11-24 13:48:33	2026-11-24 13:48:33	Added and approved by Admin	t	2026-11-24 13:48:33	2026-11-24 13:48:33	2nd Term	\N
40	69	41	41	2nd Term	\N	approved	2026-11-24 13:50:09	2026-11-24 13:50:09	Added and approved by Admin	t	2026-11-24 13:50:09	2026-11-24 13:50:09	2nd Term	\N
41	70	41	41	2nd Term	\N	approved	2026-11-24 13:51:36	2026-11-24 13:51:36	Added and approved by Admin	t	2026-11-24 13:51:36	2026-11-24 13:51:36	2nd Term	\N
42	71	41	41	2nd Term	\N	approved	2026-11-24 13:53:18	2026-11-24 13:53:18	Added and approved by Admin	t	2026-11-24 13:53:18	2026-11-24 13:53:18	2nd Term	\N
43	72	41	41	2nd Term	\N	approved	2026-11-24 13:54:49	2026-11-24 13:54:49	Added and approved by Admin	t	2026-11-24 13:54:49	2026-11-24 13:54:49	2nd Term	\N
44	56	41	41	2nd Term	\N	approved	2026-11-24 13:55:46	2026-11-24 13:55:46	Added and approved by HR	t	2026-11-24 13:55:46	2026-11-24 13:55:46	2nd Term	\N
45	73	41	41	2nd Term	\N	approved	2026-11-24 13:56:28	2026-11-24 13:56:28	Added and approved by Admin	t	2026-11-24 13:56:28	2026-11-24 13:56:28	2nd Term	\N
46	74	41	41	2nd Term	\N	approved	2026-11-24 13:58:32	2026-11-24 13:58:32	Added and approved by Admin	t	2026-11-24 13:58:32	2026-11-24 13:58:32	2nd Term	\N
47	75	41	41	2nd Term	\N	approved	2026-11-24 14:03:12	2026-11-24 14:03:12	Added and approved by Admin	t	2026-11-24 14:03:12	2026-11-24 14:03:12	2nd Term	2026-11-03
51	51	41	41	2nd Term	\N	approved	2026-11-25 14:05:35	2026-11-25 14:05:35	Added and approved by HR	t	2026-11-25 14:05:35	2026-11-25 14:05:35	2nd Term	\N
52	81	41	41	2nd Term	\N	approved	2026-11-25 14:12:29	2026-11-25 14:12:29	Added and approved by HR	t	2026-11-25 14:12:29	2026-11-25 14:12:29	2nd Term	\N
53	146	41	41	2nd Term	\N	approved	2026-11-25 14:14:31	2026-11-25 14:14:31	Added and approved by HR	t	2026-11-25 14:14:31	2026-11-25 14:14:31	2nd Term	\N
54	210	41	41	2nd Term	\N	approved	2026-11-25 14:26:15	2026-11-25 14:26:15	Added and approved by Admin	t	2026-11-25 14:26:15	2026-11-25 14:26:15	2nd Term	\N
55	203	41	41	2nd Term	\N	approved	2026-11-25 14:27:23	2026-11-25 14:27:23	Added and approved by Admin	t	2026-11-25 14:27:23	2026-11-25 14:27:23	2nd Term	\N
56	204	41	41	2nd Term	\N	approved	2026-11-25 14:29:11	2026-11-25 14:29:11	Added and approved by Admin	t	2026-11-25 14:29:11	2026-11-25 14:29:11	2nd Term	\N
57	205	41	41	2nd Term	\N	approved	2026-11-25 14:30:36	2026-11-25 14:30:36	Added and approved by Admin	t	2026-11-25 14:30:36	2026-11-25 14:30:36	2nd Term	\N
58	86	41	41	2nd Term	\N	approved	2026-11-25 14:30:47	2026-11-25 14:30:47	Added and approved by HR	t	2026-11-25 14:30:47	2026-11-25 14:30:47	2nd Term	\N
59	206	41	41	2nd Term	\N	approved	2026-11-25 14:31:24	2026-11-25 14:31:24	Added and approved by Admin	t	2026-11-25 14:31:24	2026-11-25 14:31:24	2nd Term	\N
60	211	41	41	2nd Term	\N	approved	2026-11-25 14:32:39	2026-11-25 14:32:39	Added and approved by Admin	t	2026-11-25 14:32:39	2026-11-25 14:32:39	2nd Term	\N
61	207	41	41	2nd Term	\N	approved	2026-11-25 14:33:16	2026-11-25 14:33:16	Added and approved by Admin	t	2026-11-25 14:33:16	2026-11-25 14:33:16	2nd Term	\N
62	209	41	41	2nd Term	\N	approved	2026-11-25 14:34:41	2026-11-25 14:34:41	Added and approved by Admin	t	2026-11-25 14:34:41	2026-11-25 14:34:41	2nd Term	\N
63	90	41	41	2nd Term	\N	approved	2026-11-25 14:55:31	2026-11-25 14:55:31	Added and approved by HR	t	2026-11-25 14:55:31	2026-11-25 14:55:31	2nd Term	\N
64	42	41	41	2nd Term	\N	approved	2026-11-25 15:35:41	2026-11-25 15:35:41	Added and approved by HR	t	2026-11-25 15:35:41	2026-11-25 15:35:41	2nd Term	\N
65	193	41	41	2nd Term	\N	approved	2026-11-25 15:37:28	2026-11-25 15:37:28	Added and approved by HR	t	2026-11-25 15:37:28	2026-11-25 15:37:28	2nd Term	\N
66	145	41	41	2nd Term	\N	approved	2026-11-26 09:50:14	2026-11-26 09:50:14	Added and approved by HR	t	2026-11-26 09:50:14	2026-11-26 09:50:14	2nd Term	\N
67	78	41	41	2nd Term	\N	approved	2026-11-26 09:52:09	2026-11-26 09:52:09	Added and approved by HR	t	2026-11-26 09:52:09	2026-11-26 09:52:09	2nd Term	\N
68	165	41	41	2nd Term	\N	approved	2026-11-26 09:54:38	2026-11-26 09:54:38	Added and approved by HR	t	2026-11-26 09:54:38	2026-11-26 09:54:38	2nd Term	\N
69	166	41	41	2nd Term	\N	approved	2026-11-26 09:55:26	2026-11-26 09:55:26	Added and approved by HR	t	2026-11-26 09:55:26	2026-11-26 09:55:26	2nd Term	\N
70	114	41	41	2nd Term	\N	approved	2026-11-26 09:57:12	2026-11-26 09:57:12	Added and approved by HR	t	2026-11-26 09:57:12	2026-11-26 09:57:12	2nd Term	\N
71	195	41	41	2nd Term	\N	approved	2026-11-26 09:59:55	2026-11-26 09:59:55	Added and approved by HR	t	2026-11-26 09:59:55	2026-11-26 09:59:55	2nd Term	\N
72	167	41	41	2nd Term	\N	approved	2026-11-26 10:01:04	2026-11-26 10:01:04	Added and approved by HR	t	2026-11-26 10:01:04	2026-11-26 10:01:04	2nd Term	\N
73	101	41	41	2nd Term	\N	approved	2026-11-26 10:03:43	2026-11-26 10:03:43	Added and approved by HR	t	2026-11-26 10:03:43	2026-11-26 10:03:43	2nd Term	\N
74	208	41	41	2nd Term	\N	approved	2026-11-26 10:05:27	2026-11-26 10:05:27	Added and approved by HR	t	2026-11-26 10:05:27	2026-11-26 10:05:27	2nd Term	\N
75	79	41	41	2nd Term	\N	approved	2026-11-26 10:23:44	2026-11-26 10:23:44	Added and approved by HR	t	2026-11-26 10:23:44	2026-11-26 10:23:44	2nd Term	\N
76	147	41	41	2nd Term	\N	approved	2026-11-26 10:26:14	2026-11-26 10:26:14	Added and approved by HR	t	2026-11-26 10:26:14	2026-11-26 10:26:14	2nd Term	\N
77	168	41	41	2nd Term	\N	approved	2026-11-26 10:28:22	2026-11-26 10:28:22	Added and approved by HR	t	2026-11-26 10:28:22	2026-11-26 10:28:22	2nd Term	\N
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.employees (id, employee_id, first_name, last_name, email, department_id, "position", employment_type, ranking, status, hire_date, official_time_in, official_time_out, resume_last_updated_at, created_at, updated_at, deleted_at, employment_status, leave_term_started_at) FROM stdin;
49	238034	Diane Angelika	Novicio	Novicio@gmail.com	6	Associate Professor	Faculty	Associate Professor 1	active	2023-08-01	\N	\N	\N	2026-11-24 09:22:18	2026-11-24 09:22:18	\N	probationary	\N
50	238036	Anna Mae Sales	Olan	Olan@gmail.com	6	Assistant Professor	Faculty	Assistant Professor 4	active	2023-08-23	\N	\N	\N	2026-11-24 09:30:49	2026-11-24 09:30:49	\N	regular	\N
51	238038	Lyndon	Catapang	catapang@gmail.com	6	Assistant Professor	Faculty	Assistant Professor 4	active	2023-08-01	\N	\N	\N	2026-11-24 09:56:07	2026-11-24 09:56:07	\N	regular	\N
52	238040	Merry Jaine	Liwanag	Liwanag@gmail.com	6	Assistant Professor	Faculty	Assistant Professor 4	active	2023-07-01	\N	\N	\N	2026-11-24 10:12:29	2026-11-24 10:12:29	\N	regular	\N
53	238050	Mendoza	Jess Virrey	Mendoza@gmail.com	6	Associate Professor	Faculty	Associate Professor 1	active	2023-08-01	\N	\N	\N	2026-11-24 10:14:46	2026-11-24 10:14:46	\N	regular	\N
54	238060	Maria Lourdes Culla	Bañaga	Banaga@gmail.com	6	Associate Professor	Faculty	Associate Professor 1	active	2023-08-01	\N	\N	\N	2026-11-24 10:16:19	2026-11-24 10:16:19	\N	regular	\N
55	238063	Rose Anne	Magsino	Magsino@gmail.com	6	Assistant Professor	Faculty	Assistant Professor 3	active	2023-08-07	\N	\N	\N	2026-11-24 10:17:42	2026-11-24 10:17:42	\N	regular	\N
56	238080	Charmaine Gellieann Ramos	Magsino	Charmaine@gmail.com	6	Assistant Professor	Faculty	Assistant Professor 2	active	2023-08-14	\N	\N	\N	2026-11-24 10:23:53	2026-11-24 10:23:53	\N	probationary	\N
32	23-8066	JOSIERENE	Abel	abel@gmail.com	6	Assistant Professor	Contractual Full-Time Faculty	Assistant Professor 1	active	2026-11-23	\N	\N	\N	2026-11-23 11:42:59	2026-11-23 11:51:51	\N	probationary	2026-11-02
34	238056	CAROL	ALFARO	carol@gmail.com	6	Assistant Professor	Faculty	Assistant Professor 3	active	2023-08-01	\N	\N	\N	2026-11-23 14:57:08	2026-11-23 14:57:08	\N	regular	\N
35	238070	ALLIC	CLARISA	allic@gmail.com	6	Instructor	Faculty	Instructor 4	active	2023-08-14	\N	\N	\N	2026-11-23 15:08:19	2026-11-23 15:08:19	\N	regular	\N
36	2508050	Joseph Benedic	Bandelaria,	bandelaria@gmail.com	6	Instructor	Faculty	Instructor 2	active	2025-07-30	\N	\N	\N	2026-11-23 15:21:37	2026-11-23 15:21:37	\N	probationary	\N
37	2408055	Albien Ryne	Bautista,	albien@gmail.com	6	Assistant Professor	Faculty	Assistant Professor 4	active	2024-07-22	\N	\N	\N	2026-11-23 15:30:33	2026-11-23 15:30:33	\N	probationary	\N
38	2508073	Belen	Kamil Angela	belen@gmail.com	6	Instructor	Faculty	Instructor 3	active	2026-07-13	\N	\N	\N	2026-11-23 15:45:25	2026-11-23 15:45:25	\N	probationary	\N
39	238055	Bobby	Buendia	bobby@gmail.com	6	Assistant Professor	Faculty	Assistant Professor 4	active	2024-07-22	\N	\N	\N	2026-11-23 15:56:42	2026-11-23 15:56:42	\N	probationary	\N
40	228021	Maria Dolores	Evangelista	maria@gmail.com	6	Associate Professor	Faculty	Associate Professor 1	active	2022-12-12	\N	\N	\N	2026-11-23 16:36:04	2026-11-23 16:36:04	\N	regular	\N
41	228033	Krizel Joanne	Escala	krizel@gmail.com	6	Associate Professor	Faculty	Associate Professor 3	active	2022-07-01	\N	\N	\N	2026-11-23 16:37:44	2026-11-23 16:37:44	\N	regular	\N
42	228045	Janice	Fischer	janice@gmail.com	6	Assistant Professor	Faculty	Assistant Professor 4	active	2022-08-01	\N	\N	\N	2026-11-23 16:39:48	2026-11-23 16:39:48	\N	regular	\N
43	228044	Nesiel Oros	Manalo	nisiel@gmail.com	6	Assistant Professor	Faculty	Assistant Professor 4	active	2024-07-22	\N	\N	\N	2026-11-23 16:44:18	2026-11-23 16:44:18	\N	regular	\N
44	228009	Tiffanny Gail	Nova	nova@gmail.com	6	Assistant Professor	Faculty	Assistant Professor 4	active	2019-06-03	\N	\N	\N	2026-11-23 16:48:14	2026-11-23 16:48:14	\N	regular	\N
45	228028	Camille	Silva	silva@gmail.com	6	Assistant Professor	Faculty	Assistant Professor 4	active	2022-08-01	\N	\N	\N	2026-11-23 17:08:19	2026-11-23 17:08:19	\N	regular	\N
46	220356	John Lesther	Panggat	panggat@gmail.com	6	Assistant Professor	Faculty	Assistant Professor 4	active	2021-08-01	\N	\N	\N	2026-11-24 09:15:44	2026-11-24 09:15:44	\N	probationary	\N
47	238029	Cherry Lyn	Carpio	carpio@gmail.com	6	Assistant Professor	Faculty	Assistant Professor 4	active	2023-07-17	\N	\N	\N	2026-11-24 09:17:59	2026-11-24 09:17:59	\N	regular	\N
48	238030	Jiselle	Umali	umali@gmail.com	6	Assistant Professor	Faculty	Assistant Professor 3	active	2023-08-03	\N	\N	\N	2026-11-24 09:20:16	2026-11-24 09:20:16	\N	regular	\N
57	238097	Khim Joshua	Magtibay	Magtibay@gmail.com	6	Assistant Professor	Faculty	Assistant Professor 2	active	2023-08-14	\N	\N	\N	2026-11-24 10:25:49	2026-11-24 10:25:49	\N	probationary	\N
58	238081	Lorena	Manimtim	Manimtim@gmail.com	6	Instructor	Faculty	Instructor 4	active	2024-04-25	\N	\N	\N	2026-11-24 10:27:46	2026-11-24 10:27:46	\N	regular	\N
59	23-8099	Rowena	Alcoba	alcoba@gmail.com	5	Full Professor	Faculty	Full Professor 1	active	2023-08-22	\N	\N	\N	2026-11-24 10:31:20	2026-11-24 10:31:20	\N	regular	\N
60	24-08068	Noelah Mae	Borbon	borbon@gmail.com	5	Full Professor	Faculty	Full Professor 1	active	2024-07-22	\N	\N	\N	2026-11-24 10:35:36	2026-11-24 10:35:36	\N	regular	\N
61	238100	Irish	Dimaculangan	Dimaculangan@gmail.com	6	Associate Professor	Faculty	Associate Professor 1	active	2024-02-07	\N	\N	\N	2026-11-24 10:36:14	2026-11-24 10:36:14	\N	regular	\N
62	22-8034	Marjeric	Buenafe	buenafe@gmail.com	5	Associate Professor	Faculty	Associate Professor 2	active	2022-08-01	\N	\N	\N	2026-11-24 10:37:15	2026-11-24 10:37:15	\N	regular	\N
63	238064	Jay	Sargento	Sargento@gmail.com	6	Associate Professor	Faculty	Associate Professor 1	active	2024-07-22	\N	\N	\N	2026-11-24 10:44:23	2026-11-24 10:44:23	\N	regular	\N
64	228083	Kenneth Myro	Garcia	Garcia@gmail.com	6	Associate Professor	Faculty	Associate Professor 1	active	2023-07-25	\N	\N	\N	2026-11-24 10:57:11	2026-11-24 10:57:11	\N	probationary	\N
65	23-8005	Jeroe Marvi	Casupanan	casupanan@gmail.com	5	Assistant Professor	Faculty	Assistant Professor 2	active	2024-07-22	\N	\N	\N	2026-11-24 10:58:30	2026-11-24 10:58:30	\N	probationary	\N
66	238002	Maria Andrea	Magaling	Magaling@gmail.com	6	Associate Professor	Faculty	Associate Professor 1	active	2024-07-22	\N	\N	\N	2026-11-24 10:59:09	2026-11-24 10:59:09	\N	probationary	\N
67	23-8037	Ronald	Catapang	Catapang@gmail.com	5	Associate Professor	Faculty	Associate Professor 1	active	2023-08-01	\N	\N	\N	2026-11-24 11:03:36	2026-11-24 11:03:36	\N	regular	\N
68	22-8036	Rosa Maria	Cayabyab	cayabyab@gmail.com	5	Assistant Professor	Faculty	Assistant Professor 1	active	2023-08-01	\N	\N	\N	2026-11-24 11:09:57	2026-11-24 11:09:57	\N	regular	\N
69	22-8020	Jay-ar	Dimaculangan	dimaculangan@gmail.com	5	Associate Professor	Faculty	Associate Professor 2	active	2022-07-01	\N	\N	\N	2026-11-24 11:11:18	2026-11-24 11:11:18	\N	regular	\N
70	24-08084	Josele Mari	Figueroa	Josele@gmail.com	5	Assistant Professor	Faculty	Assistant Professor 1	active	2025-07-21	\N	\N	\N	2026-11-24 11:13:15	2026-11-24 11:13:15	\N	probationary	\N
71	23-8059	Larry	Fronda Jr.	Fronda@gmail.com	5	Assistant Professor	Faculty	Assistant Professor 2	active	2023-08-14	\N	\N	\N	2026-11-24 11:14:51	2026-11-24 11:14:51	\N	regular	\N
72	23-8028	Gene Roy	Hernandez	Hernandez@gmail.com	5	Associate Professor	Faculty	Associate Professor 4	active	2023-08-14	\N	\N	\N	2026-11-24 11:15:58	2026-11-24 11:15:58	\N	regular	\N
73	25-8085	Judylen	Monterey	Monterey@gmail.com	5	Associate Professor	Faculty	Associate Professor 3	active	2025-11-17	\N	\N	\N	2026-11-24 11:26:00	2026-11-24 11:26:00	\N	probationary	\N
74	22-8049	Redem	Quinagoran	Quinagoran@gmail.com	5	Assistant Professor	Faculty	Assistant Professor 2	active	2023-08-01	\N	\N	\N	2026-11-24 11:27:09	2026-11-24 11:27:09	\N	regular	\N
76	24-08017	Sebulino	Honorato	Honorato@gmail.com	5	Assistant Professor	Faculty	Assistant Professor 1	active	2024-07-22	\N	\N	\N	2026-11-24 11:30:27	2026-11-24 11:30:27	\N	probationary	\N
33	26-08036	Jojit	Aguirre	jojit@gmail.com	6	Instructor	Contractual Full-Time Faculty	Instructor 1	active	2026-11-19	\N	\N	\N	2026-11-23 11:56:25	2026-11-24 11:45:00	\N	probationary	2026-11-03
75	24-08108	Aaron Christian	Rodriguez	Rodriguez@gmail.com	5	Assistant Professor	Contractual Full-Time Faculty	Assistant Professor 2	active	2026-03-02	\N	\N	\N	2026-11-24 11:28:42	2026-11-24 14:03:14	\N	probationary	2026-11-03
77	238019	Romielyn	Morcilla	Morcilla@gmail.com	6	Assistant Professor	Faculty	Assistant Professor 3	active	2023-03-23	\N	\N	\N	2026-11-24 14:07:19	2026-11-24 14:07:19	\N	regular	\N
78	25-08087	Ma. Cielo	Africa	dummyacc@gmail.com	7	Assistant Professor	Faculty	Assistant Professor 3	active	2026-07-13	\N	\N	\N	2026-11-24 14:37:58	2026-11-24 14:37:58	\N	probationary	\N
79	25-08065	Arnolfo	Arcibal	dummyacc1@gmail.com17	7	Instructor	Faculty	Instructor 4	active	2025-07-30	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
80	24-08044	Carlos Caesar	Caday	dummyacc1@gmail.com47	6	Instructor	Faculty	Instructor 4	active	2024-11-18	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
81	26-08048	Alestair	Dimaculangan	dummyacc1@gmail.com86	6	Instructor	Faculty	Instructor 2	active	2026-08-24	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
82	24-08025	Francis Jay	Enriquez	dummyacc1@gmail.com97	6	Assistant Professor	Faculty	Assistant Professor 2	active	2024-07-22	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
83	24-08131	Rose Ann	Fernandez	dummyacc1@gmail.com105	8	Teacher (SHS)	Faculty	Teacher 2	active	2024-12-18	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
84	23-8090	Beatrice	Gadiana	dummyacc1@gmail.com110	7	Assistant Professor	Faculty	Assistant Professor 2	active	2024-07-22	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
85	25-08053	Carl	Garcia	dummyacc1@gmail.com112	7	Instructor	Faculty	Instructor 1	active	2025-07-30	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
86	26-08006	Russel	Jimenez	dummyacc1@gmail.com126	6	Assistant Professor	Faculty	Assistant Professor 2	active	2026-03-16	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
87	26-08031	Lawrence Matthew	Juan	dummyacc1@gmail.com127	8	Senior Teacher (SHS)	Faculty	Senior Teacher 3	active	2026-07-13	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
88	23-8088	Nico Shawn	Lambio	dummyacc1@gmail.com133	7	Assistant Professor	Faculty	Assistant Professor 2	active	2024-07-22	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
89	24-08021	Flordeliza	Lantican	dummyacc1@gmail.com134	8	Senior Teacher (SHS)	Faculty	Senior Teacher 3	active	2024-04-11	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
90	24-08129	Chelsea Louella	Lat	dummyacc1@gmail.com135	6	Instructor	Faculty	Instructor 1	active	2025-11-06	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
91	25-08086	Benlene	Llantero	dummyacc1@gmail.com144	6	Assistant Professor	Faculty	Assistant Professor 1	active	2026-07-13	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
92	26-08025	Maria Eberliza	Macalindong	dummyacc1@gmail.com151	6	Assistant Professor	Faculty	Assistant Professor 4	active	2026-07-13	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
93	24-08035	Jeffrey	Magbuhos	dummyacc1@gmail.com155	8	Teacher (SHS)	Faculty	Teacher 3	active	2024-04-15	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
94	25-08024	Marithess Vianca	Magsino	dummyacc1@gmail.com161	6	Instructor	Faculty	Instructor 1	active	2025-07-21	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
95	26-08027	Darwin	Manalo	dummyacc1@gmail.com171	7	Instructor	Faculty	Instructor 4	active	2026-07-13	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
96	25-08017	Pauline Andrei	Marquez	dummyacc1@gmail.com180	6	Instructor	Faculty	Instructor 4	active	2025-07-17	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
97	24-08072	Gladys	Matira	dummyacc1@gmail.com187	7	Assistant Professor	Faculty	Assistant Professor 4	active	2025-07-14	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
98	25-08004	John Eric	Medina	dummyacc1@gmail.com189	7	Assistant Professor	Faculty	Assistant Professor 4	active	2025-07-14	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
99	26-08026	Joseph	Melo	dummyacc1@gmail.com191	7	Associate Professor	Faculty	Associate Professor 4	active	2026-07-13	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
100	26-08023	Ma. Aileen	Mesias	dummyacc1@gmail.com198	6	Instructor	Faculty	Instructor 4	active	2026-07-13	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
101	25-08085	Judylen	Monterey	dummyacc1@gmail.com201	5	Associate Professor	Faculty	Associate Professor 4	active	2025-11-17	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
102	25-08064	Reymark	Natividad	dummyacc1@gmail.com205	7	Assistant Professor	Faculty	Assistant Professor 4	active	2025-07-30	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
103	26-08032	Carlo	Olano	dummyacc1@gmail.com215	7	Instructor	Faculty	Instructor 4	active	2026-07-13	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
104	23-8094	Ryan Christian	Panapanaan	dummyacc1@gmail.com219	7	Associate Professor	Faculty	Associate Professor 4	active	2024-07-22	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
105	25-08012	Sarah Jane	Panganiban	dummyacc1@gmail.com220	6	Instructor	Faculty	Instructor 4	active	2025-04-14	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
106	24-08062	Ian	Pasahol	dummyacc1@gmail.com224	6	Assistant Professor	Faculty	Assistant Professor 4	active	2024-07-22	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
107	25-08051	Yushua	Ras	dummyacc1@gmail.com239	6	Instructor	Faculty	Instructor 4	active	2025-07-30	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
108	26-08035	Daniel Janick	Razo	dummyacc1@gmail.com240	6	Assistant Professor	Faculty	Assistant Professor 4	active	2026-07-16	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
109	25-08031	John Steve	Sabido	dummyacc1@gmail.com249	7	Instructor	Faculty	Instructor 4	active	2025-07-21	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
110	25-08026	Jonathan Rey	Sulayao	dummyacc1@gmail.com257	6	Associate Professor	Faculty	Associate Professor 4	active	2025-07-21	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
111	24-08074	Rommel	Tubig	dummyacc1@gmail.com269	7	Associate Professor	Faculty	Associate Professor 4	active	2026-01-05	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
112	24-08065	Jhon Rafael Franco	Vergara	dummyacc1@gmail.com276	6	Instructor	Faculty	Instructor 4	active	2024-07-22	\N	\N	\N	2026-11-24 14:42:17	2026-11-24 14:42:17	\N	probationary	\N
113	22-8042	Darwin	Magpili	Magpili@gmail.com	6	Instructor	Faculty	Instructor 3	active	2023-02-15	\N	\N	\N	2026-11-24 14:50:11	2026-11-24 14:50:11	\N	regular	\N
114	25-08040	Hannah Ericka	Andal	dummyacc1@gmail.com287	4	Guidance Services Office (GSO)	Admin Support Personnel	\N	active	2025-05-13	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
115	23-8043	Rio	Atienza	dummyacc1@gmail.com288	4	Health Services Office (HSO)	Admin Support Personnel	\N	active	2023-01-03	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
116	22-8073	Mike Ivan	Caguimbal	dummyacc1@gmail.com292	4	Admissions Office	Admin Support Personnel	\N	active	2023-08-16	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
117	22-8070	Jeffrey	Catibog	dummyacc1@gmail.com295	4	Admissions Office	Admin Support Personnel	\N	active	2024-09-11	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
118	25-08077	Princess	Dimaano	dummyacc1@gmail.com300	4	Treasury Office	Admin Support Personnel	\N	active	2025-10-06	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
119	24-08064	Marcela	Fernandez	dummyacc1@gmail.com304	4	Health Services Office (HSO)	Admin Support Personnel	\N	active	2024-07-22	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
120	23-8026	Sharlene Anne	Hidalgo	dummyacc1@gmail.com308	4	Human Resource Office (HR)	Admin Support Personnel	\N	active	2023-12-01	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
121	26-08001	Gemmaris	Kasilag	dummyacc1@gmail.com309	4	Treasury Office	Admin Support Personnel	\N	active	2026-01-12	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
122	25-08096 	John Carlo	Lacanlale	dummyacc1@gmail.com310	4	Learning Resource Center (LRC)	Admin Support Personnel	\N	active	2025-12-16	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
123	23-8118	Cheriffer	Laguitao	dummyacc1@gmail.com311	4	Human Resource Office (HR)	Admin Support Personnel	\N	active	2023-11-13	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
124	22-8019	Rizzalina	Lat	dummyacc1@gmail.com312	4	Registrar's Office	Admin Support Personnel	\N	active	2022-04-11	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
125	24-08121	Kyle Francis	Librea	dummyacc1@gmail.com313	4	Human Resource Office (HR)	Admin Support Personnel	\N	active	2026-08-17	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
126	24-08082	Jun	Maalihan	dummyacc1@gmail.com314	4	Discipline Office (DO)	Admin Support Personnel	\N	active	2023-03-13	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
127	24-08119	Princess Dian	Macion	dummyacc1@gmail.com315	4	Admissions Office	Admin Support Personnel	\N	active	2025-08-01	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
128	26-08050	Renan	Mallari	dummyacc1@gmail.com318	4	Guidance Services Office (GSO)	Admin Support Personnel	\N	active	2026-09-01	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
129	25-08039	Aeron Kriz	Manalo	dummyacc1@gmail.com319	4	Learning Resource Center (LRC)	Admin Support Personnel	\N	active	2025-05-02	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
130	22-8069	Angelica	Manalo	dummyacc1@gmail.com320	4	Registrar's Office	Admin Support Personnel	\N	active	2023-02-16	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
131	22-8067	Cristine	Maranan	dummyacc1@gmail.com321	4	Alumni Affairs Office (AAO)	Admin Support Personnel	\N	active	2022-09-02	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
132	26-08020	Larah Aliosa	Maulion	dummyacc1@gmail.com322	4	Treasury Office	Admin Support Personnel	\N	active	2026-05-18	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
133	25-08082	Chelzea	Mercado	dummyacc1@gmail.com324	4	Treasury Office	Admin Support Personnel	\N	active	2026-04-13	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
134	21-0130	Marie Locelle	Molate	dummyacc1@gmail.com325	4	Registrar's Office	Admin Support Personnel	\N	active	2019-08-19	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
135	24-08051	Shiela	Morfi	dummyacc1@gmail.com326	4	Human Resource Office (HR)	Admin Support Personnel	\N	active	2024-06-10	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
136	23-8111	Jeremiah	Padua	dummyacc1@gmail.com329	4	Human Resource Office (HR)	Admin Support Personnel	\N	active	2024-09-11	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
137	24-08076	Jacquelyn	Parangan	dummyacc1@gmail.com330	4	Learning Resource Center (LRC)	Admin Support Personnel	\N	active	2024-07-22	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
138	22-8018	Pia Jasmin	Quizon	dummyacc1@gmail.com333	4	Registrar's Office	Admin Support Personnel	\N	active	2022-04-11	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
139	22-8008	Alex	Solomon	dummyacc1@gmail.com334	4	Asset Management Office	Admin Support Personnel	\N	active	2022-02-16	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
140	25-08080	Kim Czarina	Torres	dummyacc1@gmail.com335	4	Marketing Office	Admin Support Personnel	\N	active	2025-11-03	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
141	25-08005	Evangeline	Umali	dummyacc1@gmail.com336	4	Learning Resource Center (LRC)	Admin Support Personnel	\N	active	2025-01-10	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
142	25-08081	Rica	Umali	dummyacc1@gmail.com337	4	Registrar's Office	Admin Support Personnel	\N	active	2025-11-03	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
143	24-08117	Zia	Villena	dummyacc1@gmail.com339	4	Registrar's Office	Admin Support Personnel	\N	active	2025-07-16	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
144	26-08051	Ken Andrew	Vispo	dummyacc1@gmail.com340	4	Marketing Office	Admin Support Personnel	\N	active	2026-09-01	\N	\N	\N	2026-11-24 15:04:47	2026-11-24 15:04:47	\N	regular	\N
145	25-08079	Angelina	Acuzar	dummyacc1@gmail.com286	4	Guidance Services Office (GSO)	Admin Support Personnel	\N	active	2025-10-16	\N	\N	\N	2026-11-24 15:05:49	2026-11-24 15:05:49	\N	regular	\N
146	2408009	Regina	Endaya	Endaya@gmail.com	6	Instructor	Faculty	Instructor 3	active	2023-02-15	\N	\N	\N	2026-11-24 15:13:19	2026-11-24 15:13:19	\N	regular	\N
147	24-08090	Marvin	Atanacio	dummyacc1@gmail.com18	7	Assistant Professor	Faculty	Assistant Professor 3	active	2024-08-07	\N	\N	\N	2026-11-24 15:16:12	2026-11-24 15:16:12	\N	regular	\N
148	24-08092	Jeanne Pauline	Calvez	dummyacc1@gmail.com50	7	Assistant Professor	Faculty	Assistant Professor 4	active	2024-08-07	\N	\N	\N	2026-11-24 15:16:12	2026-11-24 15:16:12	\N	regular	\N
149	23-8093	Sean Kirby	Dejucos	dummyacc1@gmail.com80	7	Associate Professor	Faculty	Associate Professor 3	active	2023-11-27	\N	\N	\N	2026-11-24 15:16:12	2026-11-24 15:16:12	\N	regular	\N
150	23-8047	Kyle Irvin	Dimaano	dummyacc1@gmail.com84	7	Associate Professor	Faculty	Associate Professor 1	active	2023-08-01	\N	\N	\N	2026-11-24 15:16:12	2026-11-24 15:16:12	\N	regular	\N
151	23-8022	Joel	Enriquez	dummyacc1@gmail.com98	7	Assistant Professor	Faculty	Assistant Professor 3	active	2023-11-27	\N	\N	\N	2026-11-24 15:16:12	2026-11-24 15:16:12	\N	regular	\N
152	24-08080	Wendell	Gonzales	dummyacc1@gmail.com117	7	Assistant Professor	Faculty	Assistant Professor 4	active	2024-08-01	\N	\N	\N	2026-11-24 15:16:12	2026-11-24 15:16:12	\N	regular	\N
153	24-08095	Jayson	Guia	dummyacc1@gmail.com118	7	Associate Professor	Faculty	Associate Professor 1	active	2024-08-12	\N	\N	\N	2026-11-24 15:16:12	2026-11-24 15:16:12	\N	regular	\N
154	23-8084	Larilyn	Ilao	dummyacc1@gmail.com124	7	Instructor	Faculty	Instructor 2	active	2023-11-27	\N	\N	\N	2026-11-24 15:16:12	2026-11-24 15:16:12	\N	regular	\N
155	24-08027	Alice	Lacorte	dummyacc1@gmail.com131	7	Associate Professor	Faculty	Associate Professor 4	active	2024-07-01	\N	\N	\N	2026-11-24 15:16:12	2026-11-24 15:16:12	\N	regular	\N
156	23-8092	Jojo	Leonar	dummyacc1@gmail.com138	7	Associate Professor	Faculty	Associate Professor 2	active	2023-11-27	\N	\N	\N	2026-11-24 15:16:12	2026-11-24 15:16:12	\N	regular	\N
157	23-8004	Emmanuel	Maala	dummyacc1@gmail.com147	7	Assistant Professor	Faculty	Assistant Professor 2	active	2023-07-17	\N	\N	\N	2026-11-24 15:16:12	2026-11-24 15:16:12	\N	regular	\N
158	22-8025	Roy	Maranan	dummyacc1@gmail.com176	7	Assistant Professor	Faculty	Assistant Professor 4	active	2022-07-01	\N	\N	\N	2026-11-24 15:16:12	2026-11-24 15:16:12	\N	regular	\N
159	22-8014	Carolyn	Matira	dummyacc1@gmail.com186	7	Assistant Professor	Faculty	Assistant Professor 4	active	2019-07-03	\N	\N	\N	2026-11-24 15:16:12	2026-11-24 15:16:12	\N	regular	\N
160	24-08037	Archie	Menisis	dummyacc1@gmail.com196	7	Assistant Professor	Faculty	Assistant Professor 4	active	2024-04-22	\N	\N	\N	2026-11-24 15:16:12	2026-11-24 15:16:12	\N	regular	\N
161	23-8041	Jei	Pastrana	dummyacc1@gmail.com225	7	Assistant Professor	Faculty	Assistant Professor 4	active	2023-07-17	\N	\N	\N	2026-11-24 15:16:12	2026-11-24 15:16:12	\N	regular	\N
162	24-08066	Stephenn	Rabano	dummyacc1@gmail.com236	7	Assistant Professor	Faculty	Assistant Professor 4	active	2024-08-01	\N	\N	\N	2026-11-24 15:16:12	2026-11-24 15:16:12	\N	regular	\N
163	23-8033	Neres Ann	Repollo	dummyacc1@gmail.com242	7	Associate Professor	Faculty	Associate Professor 4	active	2023-08-01	\N	\N	\N	2026-11-24 15:16:12	2026-11-24 15:16:12	\N	regular	\N
164	23-8067	Darwin	Tiquio	dummyacc1@gmail.com264	7	Assistant Professor	Faculty	Assistant Professor 4	active	2023-08-08	\N	\N	\N	2026-11-24 15:16:12	2026-11-24 15:16:12	\N	regular	\N
165	23-8031	Allen Paul	Alcantara	dummyacc1@gmail.com4	7	Part-Time Faculty	Part-Time Faculty	\N	active	2023-01-03	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
166	26-08028	Alyssa Pearl	Alon-Alon	dummyacc1@gmail.com8	7	Part-Time Faculty	Part-Time Faculty	\N	active	2026-07-13	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
167	25-08072	Rylgem	Arcega	dummyacc1@gmail.com16	7	Part-Time Faculty	Part-Time Faculty	\N	active	2025-08-16	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
168	25-08049	Pola Bianca Donia	Balmaceda	dummyacc1@gmail.com23	7	Part-Time Faculty	Part-Time Faculty	\N	active	2025-07-30	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
169	23-8074	Deanmarc Patrick	Baluyot	dummyacc1@gmail.com25	7	Part-Time Faculty	Part-Time Faculty	\N	active	2023-08-14	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
170	25-08047	Michael	Baylon	dummyacc1@gmail.com29	7	Part-Time Faculty	Part-Time Faculty	\N	active	2025-07-21	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
171	23-8091	Aira Denessa	Bulanhagui	dummyacc1@gmail.com45	7	Part-Time Faculty	Part-Time Faculty	\N	active	2026-03-02	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
172	26-08033	Junel	Buyagon	dummyacc1@gmail.com46	7	Part-Time Faculty	Part-Time Faculty	\N	active	2026-07-15	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
173	25-08059	Angeline	Cas	dummyacc1@gmail.com52	7	Part-Time Faculty	Part-Time Faculty	\N	active	2025-07-30	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
174	24-08096	Aldwin	Cueto	dummyacc1@gmail.com67	7	Part-Time Faculty	Part-Time Faculty	\N	active	2024-08-12	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
175	24-08078	Jun Orlyn	De Castro	dummyacc1@gmail.com74	7	Part-Time Faculty	Part-Time Faculty	\N	active	2024-08-05	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
176	25-08061	Ariel	Dela Cruz	dummyacc1@gmail.com81	7	Part-Time Faculty	Part-Time Faculty	\N	active	2025-07-30	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
177	24-08118	Monica	Dela Luna	dummyacc1@gmail.com83	7	Part-Time Faculty	Part-Time Faculty	\N	active	2024-09-18	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
178	25-08045	Rainiel Vinzon	Maala	dummyacc1@gmail.com148	7	Part-Time Faculty	Part-Time Faculty	\N	active	2025-07-21	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
179	25-08088	Cyril	Malaga	dummyacc1@gmail.com166	7	Part-Time Faculty	Part-Time Faculty	\N	active	2025-11-24	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
180	25-08074	Mariel	Maralit	dummyacc1@gmail.com174	7	Part-Time Faculty	Part-Time Faculty	\N	active	2025-08-28	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
181	25-08044	Judy Ann	Marasigan	dummyacc1@gmail.com178	7	Part-Time Faculty	Part-Time Faculty	\N	active	2026-07-13	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
182	25-08089	Myron Alvin	Matanguihan	dummyacc1@gmail.com184	7	Part-Time Faculty	Part-Time Faculty	\N	active	2025-11-22	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
183	23-8062	Ken	Mendigorin	dummyacc1@gmail.com192	7	Part-Time Faculty	Part-Time Faculty	\N	active	2026-07-13	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
184	25-08014	Morris Angelo	Nieva	dummyacc1@gmail.com207	7	Part-Time Faculty	Part-Time Faculty	\N	active	2025-03-27	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
185	24-08114	Digna	Nocum	dummyacc1@gmail.com210	7	Part-Time Faculty	Part-Time Faculty	\N	active	2024-08-30	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
186	24-08100	Michael	Ramilo	dummyacc1@gmail.com237	7	Part-Time Faculty	Part-Time Faculty	\N	active	2024-08-05	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
187	24-08130	Allainer	Reyes	dummyacc1@gmail.com243	7	Part-Time Faculty	Part-Time Faculty	\N	active	2024-12-18	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
188	26-08034	Andres Carlo	Roxas	dummyacc1@gmail.com248	7	Part-Time Faculty	Part-Time Faculty	\N	active	2026-07-18	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
189	24-08073	Augusto Jr.	Sison	dummyacc1@gmail.com254	7	Part-Time Faculty	Part-Time Faculty	\N	active	2024-08-05	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
190	26-08029	Ronwaldo	Tito, Ronwaldo	dummyacc1@gmail.com265	7	Part-Time Faculty	Part-Time Faculty	\N	active	2026-07-15	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
191	25-08003	Ian Carlo	Umali	dummyacc1@gmail.com271	7	Part-Time Faculty	Part-Time Faculty	\N	active	2025-01-09	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
192	24-08111	Vladimir	Viray	dummyacc1@gmail.com283	7	Part-Time Faculty	Part-Time Faculty	\N	active	2024-08-17	\N	\N	\N	2026-11-24 15:20:34	2026-11-24 15:20:34	\N	probationary	\N
193	2408025	Francis Jay	Enriquez	Enriquez@gmail.com	6	Assistant Professor	Faculty	Assistant Professor 2	active	2024-07-22	\N	\N	\N	2026-11-24 15:22:19	2026-11-24 15:22:19	\N	regular	\N
194	2408044	Carlos Caesar	Caday	Caday@gmail.com	6	Assistant Professor	Faculty	Assistant Professor 2	active	2023-03-30	\N	\N	\N	2026-11-24 15:23:42	2026-11-24 15:23:42	\N	probationary	\N
195	23-8035	Michael Joseph	Aramil	aramil67@gmail.com	7	Associate Professor	Faculty	Associate Professor 2	active	2023-07-17	\N	\N	\N	2026-11-24 15:23:44	2026-11-24 15:23:44	\N	regular	\N
196	23-8045	Irene	Balmes	balmes@gmail.com	7	Associate Professor	Faculty	Associate Professor 2	active	2023-08-01	\N	\N	\N	2026-11-24 15:26:55	2026-11-24 15:26:55	\N	regular	\N
197	23-8068	Noli	Castro	noli123@gmail.com	7	Assistant Professor	Faculty	Assistant Professor 2	active	2025-08-01	\N	\N	\N	2026-11-24 15:28:22	2026-11-24 15:28:22	\N	probationary	\N
198	2408053	Jayson	Malabanan	Malabanan@gmail.com	6	Instructor	Faculty	Instructor 4	active	2024-04-01	\N	\N	\N	2026-11-24 15:29:46	2026-11-24 15:29:46	\N	probationary	\N
199	23-8130	Erwin	De Castro	jpk@gmail.com	7	Part-Time Faculty	Part-Time Faculty	\N	active	2023-12-16	\N	\N	\N	2026-11-24 15:29:56	2026-11-24 15:29:56	\N	probationary	\N
200	24-08067	Nathaniel Nino	Magpantay	nmp123@gmaiol.com	7	Assistant Professor	Faculty	Assistant Professor 2	active	2024-07-22	\N	\N	\N	2026-11-24 15:31:14	2026-11-24 15:31:14	\N	regular	\N
201	23-8008	John Carlo	Torres	carlo098@gmail.com	7	Assistant Professor	Faculty	Assistant Professor 1	active	2023-07-17	\N	\N	\N	2026-11-24 15:33:27	2026-11-24 15:33:27	\N	regular	\N
202	26-08002	Jennie Margaret	Apritado	dummyacc1@gmail.com14	5	Part-Time Faculty	Part-Time Faculty	\N	active	2026-03-06	\N	\N	\N	2026-11-25 14:08:51	2026-11-25 14:08:51	\N	probationary	\N
203	24-08115	Lawrence Zyril	Lizardo	dummyacc1@gmail.com143	5	Part-Time Faculty	Part-Time Faculty	\N	active	2024-09-07	\N	\N	\N	2026-11-25 14:08:51	2026-11-25 14:08:51	\N	probationary	\N
204	24-08099	Jan Michael	Maglinao	dummyacc1@gmail.com156	5	Part-Time Faculty	Part-Time Faculty	\N	active	2024-08-17	\N	\N	\N	2026-11-25 14:08:51	2026-11-25 14:08:51	\N	probationary	\N
205	25-08090	Francis	Mateos	dummyacc1@gmail.com185	5	Part-Time Faculty	Part-Time Faculty	\N	active	2025-11-27	\N	\N	\N	2026-11-25 14:08:51	2026-11-25 14:08:51	\N	probationary	\N
206	25-08010	Kimberly Camille	Mendoza	dummyacc1@gmail.com194	5	Part-Time Faculty	Part-Time Faculty	\N	active	2025-02-08	\N	\N	\N	2026-11-25 14:08:51	2026-11-25 14:08:51	\N	probationary	\N
207	25-08083	Rosario	Polintang	dummyacc1@gmail.com230	5	Part-Time Faculty	Part-Time Faculty	\N	active	2025-11-08	\N	\N	\N	2026-11-25 14:08:51	2026-11-25 14:08:51	\N	probationary	\N
208	24-08102	Vernis	Ventilacion-Monteza	dummyacc1@gmail.com274	5	Part-Time Faculty	Part-Time Faculty	\N	active	2024-08-10	\N	\N	\N	2026-11-25 14:08:51	2026-11-25 14:08:51	\N	probationary	\N
209	26-08008	Charlene	Villegas	dummyacc1@gmail.com280	5	Part-Time Faculty	Part-Time Faculty	\N	active	2026-03-19	\N	\N	\N	2026-11-25 14:08:51	2026-11-25 14:08:51	\N	probationary	\N
210	23-8049	Jhyn	Concordia	dummyacc1@gmail.com65	5	Part-Time Faculty	Part-Time Faculty	\N	active	2023-08-14	\N	\N	\N	2026-11-25 14:10:16	2026-11-25 14:10:16	\N	probationary	\N
211	23-8069	Alena	Ocampo	dummyacc1@gmail.com213	5	Part-Time Faculty	Part-Time Faculty	\N	active	2023-08-14	\N	\N	\N	2026-11-25 14:10:16	2026-11-25 14:10:16	\N	probationary	\N
212	22-8080	Arriane Joy	Añonuevo	dummyacc1@gmail.com13	8	Senior Teacher (SHS)	Faculty	Senior Teacher 3	active	2022-12-12	\N	\N	\N	2026-11-25 14:13:22	2026-11-25 14:13:22	\N	regular	\N
213	24-08075	DJ Grace	De Guzman	dummyacc1@gmail.com77	8	Senior Teacher (SHS)	Faculty	Senior Teacher 3	active	2024-07-22	\N	\N	\N	2026-11-25 14:13:22	2026-11-25 14:13:22	\N	probationary	\N
214	23-8096	Genely	Dimayuga	dummyacc1@gmail.com89	8	Senior Teacher (SHS)	Faculty	Senior Teacher 3	active	2023-08-17	\N	\N	\N	2026-11-25 14:13:22	2026-11-25 14:13:22	\N	regular	\N
215	25-08019	Jerico	Fernandez	dummyacc1@gmail.com103	8	Senior Teacher (SHS)	Faculty	Senior Teacher 3	active	2025-04-02	\N	\N	\N	2026-11-25 14:13:22	2026-11-25 14:13:22	\N	probationary	\N
216	24-08001	Edmerson	Geronimo	dummyacc1@gmail.com115	8	Associate Professor	Faculty	Associate Professor 3	active	2024-01-04	\N	\N	\N	2026-11-25 14:13:22	2026-11-25 14:13:22	\N	regular	\N
217	23-8128	Sarah Jane	Layas	dummyacc1@gmail.com137	8	Senior Teacher (SHS)	Faculty	Senior Teacher 3	active	2023-12-11	\N	\N	\N	2026-11-25 14:13:22	2026-11-25 14:13:22	\N	regular	\N
218	24-08063	John Lorenz	Macalinao	dummyacc1@gmail.com150	8	Senior Teacher (SHS)	Faculty	Senior Teacher 3	active	2024-07-22	\N	\N	\N	2026-11-25 14:13:22	2026-11-25 14:13:22	\N	probationary	\N
219	25-08055	Nabil	Marquez	dummyacc1@gmail.com179	8	Senior Teacher (SHS)	Faculty	Senior Teacher 3	active	2025-07-30	\N	\N	\N	2026-11-25 14:13:22	2026-11-25 14:13:22	\N	probationary	\N
220	26-08024	Aron	Masangkay	dummyacc1@gmail.com182	8	Teacher (SHS)	Faculty	Teacher 3	active	2026-07-09	\N	\N	\N	2026-11-25 14:13:22	2026-11-25 14:13:22	\N	probationary	\N
221	25-08042 	Diether	Paz	dummyacc1@gmail.com226	8	Senior Teacher (SHS)	Faculty	Senior Teacher 3	active	2025-07-09	\N	\N	\N	2026-11-25 14:13:22	2026-11-25 14:13:22	\N	probationary	\N
222	25-08007	Nina Rica	Pesigan	dummyacc1@gmail.com229	8	Senior Teacher (SHS)	Faculty	Senior Teacher 3	active	2025-01-13	\N	\N	\N	2026-11-25 14:13:22	2026-11-25 14:13:22	\N	probationary	\N
223	24-08112	Princess	Pricas	dummyacc1@gmail.com232	8	Senior Teacher (SHS)	Faculty	Senior Teacher 3	active	2024-08-19	\N	\N	\N	2026-11-25 14:13:22	2026-11-25 14:13:22	\N	probationary	\N
224	25-08043	Joseph	Sangalang	dummyacc1@gmail.com250	8	Senior Teacher (SHS)	Faculty	Senior Teacher 3	active	2025-07-09	\N	\N	\N	2026-11-25 14:13:22	2026-11-25 14:13:22	\N	probationary	\N
225	23-8078	Patrick	Villamayor	dummyacc1@gmail.com278	8	Senior Teacher (SHS)	Faculty	Senior Teacher 3	active	2023-08-14	\N	\N	\N	2026-11-25 14:13:22	2026-11-25 14:13:22	\N	regular	\N
226	26-08014	Kyle Zyrene	Bolaños	dummyacc1@gmail.com38	8	Teacher (SHS)	Faculty	Teacher 3	active	2026-06-16	\N	\N	\N	2026-11-25 14:15:28	2026-11-25 14:15:28	\N	probationary	\N
227	23-8079	Ace Miguel	Bravo	dummyacc1@gmail.com40	8	Senior Teacher (SHS)	Faculty	Senior Teacher 3	active	2023-08-14	\N	\N	\N	2026-11-25 14:15:28	2026-11-25 14:15:28	\N	regular	\N
228	23-8021	Ma. Karena	Celestino	dummyacc1@gmail.com63	8	Senior Teacher (SHS)	Faculty	Senior Teacher 3	active	2023-07-17	\N	\N	\N	2026-11-25 14:15:28	2026-11-25 14:15:28	\N	regular	\N
229	26-08037	Arianne	Cruz	dummyacc1@gmail.com66	8	Part-Time Faculty	Part-Time Faculty	\N	active	2026-07-28	\N	\N	\N	2026-11-25 14:15:28	2026-11-25 14:15:28	\N	probationary	\N
230	25-08063	Joshua	Magtibay	dummyacc1@gmail.com163	8	Senior Teacher (SHS)	Faculty	Senior Teacher 3	active	2025-07-30	\N	\N	\N	2026-11-25 14:15:28	2026-11-25 14:15:28	\N	probationary	\N
\.


--
-- Data for Name: extraction_validation_runs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.extraction_validation_runs (id, user_id, pdf_filename, ground_truth_filename, format, pages, extraction_seconds, expected_rows, extracted_rows, matched_rows, time_in_correct, time_out_correct, fully_correct_rows, employee_matched_rows, mismatches, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: failed_jobs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.failed_jobs (id, uuid, connection, queue, payload, exception, failed_at) FROM stdin;
1	2934e77a-77e8-4f33-8450-0c5bcf691fde	database	default	{"uuid":"2934e77a-77e8-4f33-8450-0c5bcf691fde","displayName":"App\\\\Jobs\\\\ProcessLeaveUpload","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":1,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":900,"retryUntil":null,"deleteWhenMissingModels":false,"data":{"commandName":"App\\\\Jobs\\\\ProcessLeaveUpload","command":"O:27:\\"App\\\\Jobs\\\\ProcessLeaveUpload\\":2:{s:4:\\"path\\";s:59:\\"leave-imports\\/sjwbKEGoj634xtxizcWB2t6tE3y0NY4xBF4tzhQj.xlsx\\";s:7:\\"actorId\\";i:42;}","batchId":null},"createdAt":1791901728,"delay":null}	Symfony\\Component\\HttpFoundation\\File\\Exception\\FileNotFoundException: The file "/Users/gerardmln/Laravel Projects/nuhris-final/storage/app/private/leave-imports/sjwbKEGoj634xtxizcWB2t6tE3y0NY4xBF4tzhQj.xlsx" does not exist in /Users/gerardmln/Laravel Projects/nuhris-final/vendor/symfony/http-foundation/File/File.php:36\nStack trace:\n#0 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/symfony/http-foundation/File/UploadedFile.php(75): Symfony\\Component\\HttpFoundation\\File\\File->__construct('/Users/gerardml...', true)\n#1 /Users/gerardmln/Laravel Projects/nuhris-final/app/Jobs/ProcessLeaveUpload.php(36): Symfony\\Component\\HttpFoundation\\File\\UploadedFile->__construct('/Users/gerardml...', 'sjwbKEGoj634xtx...', NULL, NULL, true)\n#2 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(36): App\\Jobs\\ProcessLeaveUpload->handle(Object(App\\Http\\Controllers\\Hr\\OperationsController), Object(App\\Services\\LeaveMonitoringService))\n#3 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/Util.php(43): Illuminate\\Container\\BoundMethod::{closure:Illuminate\\Container\\BoundMethod::call():35}()\n#4 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(96): Illuminate\\Container\\Util::unwrapIfClosure(Object(Closure))\n#5 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(35): Illuminate\\Container\\BoundMethod::callBoundMethod(Object(Illuminate\\Foundation\\Application), Array, Object(Closure))\n#6 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/Container.php(801): Illuminate\\Container\\BoundMethod::call(Object(Illuminate\\Foundation\\Application), Array, Array, NULL)\n#7 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Bus/Dispatcher.php(136): Illuminate\\Container\\Container->call(Array)\n#8 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Pipeline/Pipeline.php(180): Illuminate\\Bus\\Dispatcher->{closure:Illuminate\\Bus\\Dispatcher::dispatchNow():133}(Object(App\\Jobs\\ProcessLeaveUpload))\n#9 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Pipeline/Pipeline.php(137): Illuminate\\Pipeline\\Pipeline->{closure:Illuminate\\Pipeline\\Pipeline::prepareDestination():178}(Object(App\\Jobs\\ProcessLeaveUpload))\n#10 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Bus/Dispatcher.php(140): Illuminate\\Pipeline\\Pipeline->then(Object(Closure))\n#11 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/CallQueuedHandler.php(155): Illuminate\\Bus\\Dispatcher->dispatchNow(Object(App\\Jobs\\ProcessLeaveUpload), false)\n#12 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Pipeline/Pipeline.php(180): Illuminate\\Queue\\CallQueuedHandler->{closure:Illuminate\\Queue\\CallQueuedHandler::dispatchThroughMiddleware():148}(Object(App\\Jobs\\ProcessLeaveUpload))\n#13 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Pipeline/Pipeline.php(137): Illuminate\\Pipeline\\Pipeline->{closure:Illuminate\\Pipeline\\Pipeline::prepareDestination():178}(Object(App\\Jobs\\ProcessLeaveUpload))\n#14 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/CallQueuedHandler.php(148): Illuminate\\Pipeline\\Pipeline->then(Object(Closure))\n#15 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/CallQueuedHandler.php(86): Illuminate\\Queue\\CallQueuedHandler->dispatchThroughMiddleware(Object(Illuminate\\Queue\\Jobs\\DatabaseJob), Object(App\\Jobs\\ProcessLeaveUpload))\n#16 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/Jobs/Job.php(102): Illuminate\\Queue\\CallQueuedHandler->call(Object(Illuminate\\Queue\\Jobs\\DatabaseJob), Array)\n#17 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/Worker.php(559): Illuminate\\Queue\\Jobs\\Job->fire()\n#18 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/Worker.php(505): Illuminate\\Queue\\Worker->process('database', Object(Illuminate\\Queue\\Jobs\\DatabaseJob), Object(Illuminate\\Queue\\WorkerOptions))\n#19 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/Worker.php(418): Illuminate\\Queue\\Worker->runJob(Object(Illuminate\\Queue\\Jobs\\DatabaseJob), 'database', Object(Illuminate\\Queue\\WorkerOptions))\n#20 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/Console/WorkCommand.php(149): Illuminate\\Queue\\Worker->runNextJob('database', 'default', Object(Illuminate\\Queue\\WorkerOptions))\n#21 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/Console/WorkCommand.php(132): Illuminate\\Queue\\Console\\WorkCommand->runWorker('database', 'default')\n#22 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(36): Illuminate\\Queue\\Console\\WorkCommand->handle()\n#23 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/Util.php(43): Illuminate\\Container\\BoundMethod::{closure:Illuminate\\Container\\BoundMethod::call():35}()\n#24 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(96): Illuminate\\Container\\Util::unwrapIfClosure(Object(Closure))\n#25 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(35): Illuminate\\Container\\BoundMethod::callBoundMethod(Object(Illuminate\\Foundation\\Application), Array, Object(Closure))\n#26 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/Container.php(801): Illuminate\\Container\\BoundMethod::call(Object(Illuminate\\Foundation\\Application), Array, Array, NULL)\n#27 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Console/Command.php(292): Illuminate\\Container\\Container->call(Array)\n#28 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/symfony/console/Command/Command.php(341): Illuminate\\Console\\Command->execute(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Illuminate\\Console\\OutputStyle))\n#29 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Console/Command.php(261): Symfony\\Component\\Console\\Command\\Command->run(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Illuminate\\Console\\OutputStyle))\n#30 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/symfony/console/Application.php(1117): Illuminate\\Console\\Command->run(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#31 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/symfony/console/Application.php(356): Symfony\\Component\\Console\\Application->doRunCommand(Object(Illuminate\\Queue\\Console\\WorkCommand), Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#32 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/symfony/console/Application.php(195): Symfony\\Component\\Console\\Application->doRun(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#33 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Foundation/Console/Kernel.php(198): Symfony\\Component\\Console\\Application->run(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#34 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Foundation/Application.php(1242): Illuminate\\Foundation\\Console\\Kernel->handle(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#35 /Users/gerardmln/Laravel Projects/nuhris-final/artisan(16): Illuminate\\Foundation\\Application->handleCommand(Object(Symfony\\Component\\Console\\Input\\ArgvInput))\n#36 {main}	2026-10-14 09:42:02
2	b8e3e37e-360e-4c6e-a072-041be5b1e58e	database	default	{"uuid":"b8e3e37e-360e-4c6e-a072-041be5b1e58e","displayName":"App\\\\Jobs\\\\ProcessLeaveUpload","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":1,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":900,"retryUntil":null,"deleteWhenMissingModels":false,"data":{"commandName":"App\\\\Jobs\\\\ProcessLeaveUpload","command":"O:27:\\"App\\\\Jobs\\\\ProcessLeaveUpload\\":2:{s:4:\\"path\\";s:59:\\"leave-imports\\/TLTxSDDyQVga6tEGHKapiLX67xCLMoLlro2BENHc.xlsx\\";s:7:\\"actorId\\";i:42;}","batchId":null},"createdAt":1791901821,"delay":null}	Symfony\\Component\\HttpFoundation\\File\\Exception\\FileNotFoundException: The file "/Users/gerardmln/Laravel Projects/nuhris-final/storage/app/private/leave-imports/TLTxSDDyQVga6tEGHKapiLX67xCLMoLlro2BENHc.xlsx" does not exist in /Users/gerardmln/Laravel Projects/nuhris-final/vendor/symfony/http-foundation/File/File.php:36\nStack trace:\n#0 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/symfony/http-foundation/File/UploadedFile.php(75): Symfony\\Component\\HttpFoundation\\File\\File->__construct('/Users/gerardml...', true)\n#1 /Users/gerardmln/Laravel Projects/nuhris-final/app/Jobs/ProcessLeaveUpload.php(36): Symfony\\Component\\HttpFoundation\\File\\UploadedFile->__construct('/Users/gerardml...', 'TLTxSDDyQVga6tE...', NULL, NULL, true)\n#2 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(36): App\\Jobs\\ProcessLeaveUpload->handle(Object(App\\Http\\Controllers\\Hr\\OperationsController), Object(App\\Services\\LeaveMonitoringService))\n#3 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/Util.php(43): Illuminate\\Container\\BoundMethod::{closure:Illuminate\\Container\\BoundMethod::call():35}()\n#4 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(96): Illuminate\\Container\\Util::unwrapIfClosure(Object(Closure))\n#5 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(35): Illuminate\\Container\\BoundMethod::callBoundMethod(Object(Illuminate\\Foundation\\Application), Array, Object(Closure))\n#6 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/Container.php(801): Illuminate\\Container\\BoundMethod::call(Object(Illuminate\\Foundation\\Application), Array, Array, NULL)\n#7 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Bus/Dispatcher.php(136): Illuminate\\Container\\Container->call(Array)\n#8 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Pipeline/Pipeline.php(180): Illuminate\\Bus\\Dispatcher->{closure:Illuminate\\Bus\\Dispatcher::dispatchNow():133}(Object(App\\Jobs\\ProcessLeaveUpload))\n#9 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Pipeline/Pipeline.php(137): Illuminate\\Pipeline\\Pipeline->{closure:Illuminate\\Pipeline\\Pipeline::prepareDestination():178}(Object(App\\Jobs\\ProcessLeaveUpload))\n#10 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Bus/Dispatcher.php(140): Illuminate\\Pipeline\\Pipeline->then(Object(Closure))\n#11 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/CallQueuedHandler.php(155): Illuminate\\Bus\\Dispatcher->dispatchNow(Object(App\\Jobs\\ProcessLeaveUpload), false)\n#12 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Pipeline/Pipeline.php(180): Illuminate\\Queue\\CallQueuedHandler->{closure:Illuminate\\Queue\\CallQueuedHandler::dispatchThroughMiddleware():148}(Object(App\\Jobs\\ProcessLeaveUpload))\n#13 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Pipeline/Pipeline.php(137): Illuminate\\Pipeline\\Pipeline->{closure:Illuminate\\Pipeline\\Pipeline::prepareDestination():178}(Object(App\\Jobs\\ProcessLeaveUpload))\n#14 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/CallQueuedHandler.php(148): Illuminate\\Pipeline\\Pipeline->then(Object(Closure))\n#15 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/CallQueuedHandler.php(86): Illuminate\\Queue\\CallQueuedHandler->dispatchThroughMiddleware(Object(Illuminate\\Queue\\Jobs\\DatabaseJob), Object(App\\Jobs\\ProcessLeaveUpload))\n#16 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/Jobs/Job.php(102): Illuminate\\Queue\\CallQueuedHandler->call(Object(Illuminate\\Queue\\Jobs\\DatabaseJob), Array)\n#17 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/Worker.php(559): Illuminate\\Queue\\Jobs\\Job->fire()\n#18 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/Worker.php(505): Illuminate\\Queue\\Worker->process('database', Object(Illuminate\\Queue\\Jobs\\DatabaseJob), Object(Illuminate\\Queue\\WorkerOptions))\n#19 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/Worker.php(418): Illuminate\\Queue\\Worker->runJob(Object(Illuminate\\Queue\\Jobs\\DatabaseJob), 'database', Object(Illuminate\\Queue\\WorkerOptions))\n#20 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/Console/WorkCommand.php(149): Illuminate\\Queue\\Worker->runNextJob('database', 'default', Object(Illuminate\\Queue\\WorkerOptions))\n#21 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/Console/WorkCommand.php(132): Illuminate\\Queue\\Console\\WorkCommand->runWorker('database', 'default')\n#22 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(36): Illuminate\\Queue\\Console\\WorkCommand->handle()\n#23 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/Util.php(43): Illuminate\\Container\\BoundMethod::{closure:Illuminate\\Container\\BoundMethod::call():35}()\n#24 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(96): Illuminate\\Container\\Util::unwrapIfClosure(Object(Closure))\n#25 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(35): Illuminate\\Container\\BoundMethod::callBoundMethod(Object(Illuminate\\Foundation\\Application), Array, Object(Closure))\n#26 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/Container.php(801): Illuminate\\Container\\BoundMethod::call(Object(Illuminate\\Foundation\\Application), Array, Array, NULL)\n#27 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Console/Command.php(292): Illuminate\\Container\\Container->call(Array)\n#28 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/symfony/console/Command/Command.php(341): Illuminate\\Console\\Command->execute(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Illuminate\\Console\\OutputStyle))\n#29 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Console/Command.php(261): Symfony\\Component\\Console\\Command\\Command->run(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Illuminate\\Console\\OutputStyle))\n#30 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/symfony/console/Application.php(1117): Illuminate\\Console\\Command->run(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#31 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/symfony/console/Application.php(356): Symfony\\Component\\Console\\Application->doRunCommand(Object(Illuminate\\Queue\\Console\\WorkCommand), Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#32 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/symfony/console/Application.php(195): Symfony\\Component\\Console\\Application->doRun(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#33 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Foundation/Console/Kernel.php(198): Symfony\\Component\\Console\\Application->run(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#34 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Foundation/Application.php(1242): Illuminate\\Foundation\\Console\\Kernel->handle(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#35 /Users/gerardmln/Laravel Projects/nuhris-final/artisan(16): Illuminate\\Foundation\\Application->handleCommand(Object(Symfony\\Component\\Console\\Input\\ArgvInput))\n#36 {main}	2026-10-14 09:42:19
3	85021940-73e8-4ff4-a116-ea897446379f	database	default	{"uuid":"85021940-73e8-4ff4-a116-ea897446379f","displayName":"App\\\\Jobs\\\\ProcessLeaveUpload","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":1,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":900,"retryUntil":null,"deleteWhenMissingModels":false,"data":{"commandName":"App\\\\Jobs\\\\ProcessLeaveUpload","command":"O:27:\\"App\\\\Jobs\\\\ProcessLeaveUpload\\":2:{s:4:\\"path\\";s:59:\\"leave-imports\\/RAWE2dIrrDqzjoOMSGMBJcY2tZx1llSSUVeQO2Mt.xlsx\\";s:7:\\"actorId\\";i:42;}","batchId":null},"createdAt":1791902419,"delay":null}	Symfony\\Component\\HttpFoundation\\File\\Exception\\FileNotFoundException: The file "/Users/gerardmln/Laravel Projects/nuhris-final/storage/app/private/leave-imports/RAWE2dIrrDqzjoOMSGMBJcY2tZx1llSSUVeQO2Mt.xlsx" does not exist in /Users/gerardmln/Laravel Projects/nuhris-final/vendor/symfony/http-foundation/File/File.php:36\nStack trace:\n#0 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/symfony/http-foundation/File/UploadedFile.php(75): Symfony\\Component\\HttpFoundation\\File\\File->__construct('/Users/gerardml...', true)\n#1 /Users/gerardmln/Laravel Projects/nuhris-final/app/Jobs/ProcessLeaveUpload.php(36): Symfony\\Component\\HttpFoundation\\File\\UploadedFile->__construct('/Users/gerardml...', 'RAWE2dIrrDqzjoO...', NULL, NULL, true)\n#2 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(36): App\\Jobs\\ProcessLeaveUpload->handle(Object(App\\Http\\Controllers\\Hr\\OperationsController), Object(App\\Services\\LeaveMonitoringService))\n#3 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/Util.php(43): Illuminate\\Container\\BoundMethod::{closure:Illuminate\\Container\\BoundMethod::call():35}()\n#4 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(96): Illuminate\\Container\\Util::unwrapIfClosure(Object(Closure))\n#5 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(35): Illuminate\\Container\\BoundMethod::callBoundMethod(Object(Illuminate\\Foundation\\Application), Array, Object(Closure))\n#6 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/Container.php(801): Illuminate\\Container\\BoundMethod::call(Object(Illuminate\\Foundation\\Application), Array, Array, NULL)\n#7 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Bus/Dispatcher.php(136): Illuminate\\Container\\Container->call(Array)\n#8 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Pipeline/Pipeline.php(180): Illuminate\\Bus\\Dispatcher->{closure:Illuminate\\Bus\\Dispatcher::dispatchNow():133}(Object(App\\Jobs\\ProcessLeaveUpload))\n#9 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Pipeline/Pipeline.php(137): Illuminate\\Pipeline\\Pipeline->{closure:Illuminate\\Pipeline\\Pipeline::prepareDestination():178}(Object(App\\Jobs\\ProcessLeaveUpload))\n#10 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Bus/Dispatcher.php(140): Illuminate\\Pipeline\\Pipeline->then(Object(Closure))\n#11 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/CallQueuedHandler.php(155): Illuminate\\Bus\\Dispatcher->dispatchNow(Object(App\\Jobs\\ProcessLeaveUpload), false)\n#12 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Pipeline/Pipeline.php(180): Illuminate\\Queue\\CallQueuedHandler->{closure:Illuminate\\Queue\\CallQueuedHandler::dispatchThroughMiddleware():148}(Object(App\\Jobs\\ProcessLeaveUpload))\n#13 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Pipeline/Pipeline.php(137): Illuminate\\Pipeline\\Pipeline->{closure:Illuminate\\Pipeline\\Pipeline::prepareDestination():178}(Object(App\\Jobs\\ProcessLeaveUpload))\n#14 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/CallQueuedHandler.php(148): Illuminate\\Pipeline\\Pipeline->then(Object(Closure))\n#15 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/CallQueuedHandler.php(86): Illuminate\\Queue\\CallQueuedHandler->dispatchThroughMiddleware(Object(Illuminate\\Queue\\Jobs\\DatabaseJob), Object(App\\Jobs\\ProcessLeaveUpload))\n#16 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/Jobs/Job.php(102): Illuminate\\Queue\\CallQueuedHandler->call(Object(Illuminate\\Queue\\Jobs\\DatabaseJob), Array)\n#17 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/Worker.php(559): Illuminate\\Queue\\Jobs\\Job->fire()\n#18 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/Worker.php(505): Illuminate\\Queue\\Worker->process('database', Object(Illuminate\\Queue\\Jobs\\DatabaseJob), Object(Illuminate\\Queue\\WorkerOptions))\n#19 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/Worker.php(418): Illuminate\\Queue\\Worker->runJob(Object(Illuminate\\Queue\\Jobs\\DatabaseJob), 'database', Object(Illuminate\\Queue\\WorkerOptions))\n#20 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/Console/WorkCommand.php(149): Illuminate\\Queue\\Worker->runNextJob('database', 'default', Object(Illuminate\\Queue\\WorkerOptions))\n#21 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Queue/Console/WorkCommand.php(132): Illuminate\\Queue\\Console\\WorkCommand->runWorker('database', 'default')\n#22 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(36): Illuminate\\Queue\\Console\\WorkCommand->handle()\n#23 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/Util.php(43): Illuminate\\Container\\BoundMethod::{closure:Illuminate\\Container\\BoundMethod::call():35}()\n#24 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(96): Illuminate\\Container\\Util::unwrapIfClosure(Object(Closure))\n#25 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(35): Illuminate\\Container\\BoundMethod::callBoundMethod(Object(Illuminate\\Foundation\\Application), Array, Object(Closure))\n#26 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Container/Container.php(801): Illuminate\\Container\\BoundMethod::call(Object(Illuminate\\Foundation\\Application), Array, Array, NULL)\n#27 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Console/Command.php(292): Illuminate\\Container\\Container->call(Array)\n#28 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/symfony/console/Command/Command.php(341): Illuminate\\Console\\Command->execute(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Illuminate\\Console\\OutputStyle))\n#29 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Console/Command.php(261): Symfony\\Component\\Console\\Command\\Command->run(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Illuminate\\Console\\OutputStyle))\n#30 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/symfony/console/Application.php(1117): Illuminate\\Console\\Command->run(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#31 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/symfony/console/Application.php(356): Symfony\\Component\\Console\\Application->doRunCommand(Object(Illuminate\\Queue\\Console\\WorkCommand), Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#32 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/symfony/console/Application.php(195): Symfony\\Component\\Console\\Application->doRun(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#33 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Foundation/Console/Kernel.php(198): Symfony\\Component\\Console\\Application->run(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#34 /Users/gerardmln/Laravel Projects/nuhris-final/vendor/laravel/framework/src/Illuminate/Foundation/Application.php(1242): Illuminate\\Foundation\\Console\\Kernel->handle(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))\n#35 /Users/gerardmln/Laravel Projects/nuhris-final/artisan(16): Illuminate\\Foundation\\Application->handleCommand(Object(Symfony\\Component\\Console\\Input\\ArgvInput))\n#36 {main}	2026-10-14 09:44:12
\.


--
-- Data for Name: job_batches; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.job_batches (id, name, total_jobs, pending_jobs, failed_jobs, failed_job_ids, options, cancelled_at, created_at, finished_at) FROM stdin;
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.jobs (id, queue, payload, attempts, reserved_at, available_at, created_at) FROM stdin;
6	default	{"uuid":"c1e57bf0-7d7d-4382-8397-d934ff29ef52","displayName":"App\\\\Jobs\\\\ProcessLeaveUpload","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":1,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":900,"retryUntil":null,"deleteWhenMissingModels":false,"data":{"commandName":"App\\\\Jobs\\\\ProcessLeaveUpload","command":"O:27:\\"App\\\\Jobs\\\\ProcessLeaveUpload\\":2:{s:4:\\"path\\";s:62:\\"queued-uploads\\/leave-dc6bfe28-38d9-43ad-b4e9-b023e0cb0d1c.xlsx\\";s:7:\\"actorId\\";i:42;}","batchId":null},"createdAt":1791941228,"delay":null}	0	\N	1791941228	1791941228
9	default	{"uuid":"026586b2-5c33-4254-995e-5a9f7817a2af","displayName":"App\\\\Jobs\\\\ProcessLeaveUpload","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":1,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":900,"retryUntil":null,"deleteWhenMissingModels":false,"data":{"commandName":"App\\\\Jobs\\\\ProcessLeaveUpload","command":"O:27:\\"App\\\\Jobs\\\\ProcessLeaveUpload\\":3:{s:4:\\"path\\";s:60:\\"queued-uploads\\/aPDcD9ickPvru51hPqXvBHKXpNUpJk2niGxI5c7R.xlsx\\";s:7:\\"actorId\\";i:42;s:5:\\"runId\\";s:36:\\"d77f7365-a93a-49c9-bdc8-b776282d522e\\";}","batchId":null},"createdAt":1791943983,"delay":null}	0	\N	1791943983	1791943983
10	default	{"uuid":"0613b060-85f9-4b46-bf16-53c323ed3c53","displayName":"App\\\\Jobs\\\\ProcessLeaveUpload","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":1,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":900,"retryUntil":null,"deleteWhenMissingModels":false,"data":{"commandName":"App\\\\Jobs\\\\ProcessLeaveUpload","command":"O:27:\\"App\\\\Jobs\\\\ProcessLeaveUpload\\":3:{s:4:\\"path\\";s:60:\\"queued-uploads\\/4XsLsRm6OXuF8S2IObsB29I1BAsg8iNC0u6qPpoX.xlsx\\";s:7:\\"actorId\\";i:42;s:5:\\"runId\\";s:36:\\"7c5c479a-d5e0-48ba-8e44-5726f175970f\\";}","batchId":null},"createdAt":1791944570,"delay":null}	0	\N	1791944570	1791944570
7	default	{"uuid":"623bad36-4e32-4ed0-a265-0c33bc911d32","displayName":"App\\\\Jobs\\\\ProcessLeaveUpload","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":1,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":900,"retryUntil":null,"deleteWhenMissingModels":false,"data":{"commandName":"App\\\\Jobs\\\\ProcessLeaveUpload","command":"O:27:\\"App\\\\Jobs\\\\ProcessLeaveUpload\\":2:{s:4:\\"path\\";s:59:\\"leave-imports\\/jvsAnrdm8DHGcogRqR0xdXHzqUNkXEs9IVYGTHHy.xlsx\\";s:7:\\"actorId\\";N;}","batchId":null},"createdAt":1791942145,"delay":null}	0	\N	1791942145	1791942145
8	default	{"uuid":"455bd64b-9988-4fb1-a48f-5b90658c956a","displayName":"App\\\\Jobs\\\\ProcessLeaveUpload","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":1,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":900,"retryUntil":null,"deleteWhenMissingModels":false,"data":{"commandName":"App\\\\Jobs\\\\ProcessLeaveUpload","command":"O:27:\\"App\\\\Jobs\\\\ProcessLeaveUpload\\":2:{s:4:\\"path\\";s:59:\\"leave-imports\\/xfgpnTpoUiFCfyC2134mhG0QYPtXA4MbpfvODgHA.xlsx\\";s:7:\\"actorId\\";N;}","batchId":null},"createdAt":1791942248,"delay":null}	0	\N	1791942248	1791942248
\.


--
-- Data for Name: leave_balances; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.leave_balances (id, employee_id, leave_type, remaining_days, created_at, updated_at) FROM stdin;
121	44	Vacation Leave	15.00	2026-11-24 09:32:08	2026-11-24 09:32:08
122	44	Sick Leave	15.00	2026-11-24 09:32:09	2026-11-24 09:32:09
123	44	Emergency Leave	3.00	2026-11-24 09:32:10	2026-11-24 09:32:10
124	49	Vacation Leave	15.00	2026-11-24 09:32:11	2026-11-24 09:32:11
125	49	Sick Leave	15.00	2026-11-24 09:32:11	2026-11-24 09:32:11
126	49	Emergency Leave	3.00	2026-11-24 09:32:12	2026-11-24 09:32:12
127	50	Vacation Leave	15.00	2026-11-24 09:32:13	2026-11-24 09:32:13
128	50	Sick Leave	15.00	2026-11-24 09:32:14	2026-11-24 09:32:14
129	50	Emergency Leave	3.00	2026-11-24 09:32:14	2026-11-24 09:32:14
130	46	Vacation Leave	15.00	2026-11-24 09:32:15	2026-11-24 09:32:15
131	46	Sick Leave	15.00	2026-11-24 09:32:16	2026-11-24 09:32:16
132	46	Emergency Leave	3.00	2026-11-24 09:32:17	2026-11-24 09:32:17
133	45	Vacation Leave	15.00	2026-11-24 09:32:18	2026-11-24 09:32:18
134	45	Sick Leave	15.00	2026-11-24 09:32:18	2026-11-24 09:32:18
135	45	Emergency Leave	3.00	2026-11-24 09:32:19	2026-11-24 09:32:19
136	48	Vacation Leave	15.00	2026-11-24 09:32:20	2026-11-24 09:32:20
137	48	Sick Leave	15.00	2026-11-24 09:32:21	2026-11-24 09:32:21
138	48	Emergency Leave	3.00	2026-11-24 09:32:21	2026-11-24 09:32:21
139	75	Vacation Leave	3.00	2026-11-24 14:03:15	2026-11-24 14:03:15
140	75	Sick Leave	3.00	2026-11-24 14:03:16	2026-11-24 14:03:16
141	75	Emergency Leave	3.00	2026-11-24 14:03:16	2026-11-24 14:03:16
142	145	Vacation Leave	11.00	2026-11-25 11:36:40	2026-11-25 11:36:40
143	145	Sick Leave	11.00	2026-11-25 11:36:40	2026-11-25 11:36:40
144	145	Emergency Leave	3.00	2026-11-25 11:36:41	2026-11-25 11:36:41
145	78	Vacation Leave	11.00	2026-11-25 11:36:42	2026-11-25 11:36:42
146	78	Sick Leave	11.00	2026-11-25 11:36:43	2026-11-25 11:36:43
147	78	Emergency Leave	3.00	2026-11-25 11:36:43	2026-11-25 11:36:43
148	165	Vacation Leave	9.00	2026-11-25 11:36:46	2026-11-25 11:36:46
82	32	Vacation Leave	3.00	2026-11-23 11:46:19	2026-11-23 11:46:19
83	32	Sick Leave	3.00	2026-11-23 11:46:20	2026-11-23 11:46:20
84	32	Emergency Leave	3.00	2026-11-23 11:46:21	2026-11-23 11:46:21
85	33	Vacation Leave	3.00	2026-11-24 09:31:41	2026-11-24 09:31:41
86	33	Sick Leave	3.00	2026-11-24 09:31:42	2026-11-24 09:31:42
87	33	Emergency Leave	3.00	2026-11-24 09:31:42	2026-11-24 09:31:42
88	34	Vacation Leave	15.00	2026-11-24 09:31:43	2026-11-24 09:31:43
89	34	Sick Leave	15.00	2026-11-24 09:31:44	2026-11-24 09:31:44
90	34	Emergency Leave	3.00	2026-11-24 09:31:44	2026-11-24 09:31:44
91	36	Vacation Leave	13.00	2026-11-24 09:31:45	2026-11-24 09:31:45
92	36	Sick Leave	13.00	2026-11-24 09:31:46	2026-11-24 09:31:46
149	165	Sick Leave	9.00	2026-11-25 11:36:47	2026-11-25 11:36:47
93	36	Emergency Leave	3.00	2026-11-24 09:31:47	2026-11-24 09:31:47
150	165	Emergency Leave	3.00	2026-11-25 11:36:48	2026-11-25 11:36:48
94	37	Vacation Leave	15.00	2026-11-24 09:31:48	2026-11-24 09:31:48
95	37	Sick Leave	15.00	2026-11-24 09:31:48	2026-11-24 09:31:48
96	37	Emergency Leave	3.00	2026-11-24 09:31:49	2026-11-24 09:31:49
97	39	Vacation Leave	15.00	2026-11-24 09:31:50	2026-11-24 09:31:50
151	59	Vacation Leave	15.00	2026-11-25 11:36:49	2026-11-25 11:36:49
98	39	Sick Leave	15.00	2026-11-24 09:31:51	2026-11-24 09:31:51
99	39	Emergency Leave	3.00	2026-11-24 09:31:51	2026-11-24 09:31:51
100	47	Vacation Leave	15.00	2026-11-24 09:31:52	2026-11-24 09:31:52
101	47	Sick Leave	15.00	2026-11-24 09:31:53	2026-11-24 09:31:53
102	47	Emergency Leave	3.00	2026-11-24 09:31:54	2026-11-24 09:31:54
103	35	Vacation Leave	15.00	2026-11-24 09:31:55	2026-11-24 09:31:55
104	35	Sick Leave	15.00	2026-11-24 09:31:55	2026-11-24 09:31:55
105	35	Emergency Leave	3.00	2026-11-24 09:31:56	2026-11-24 09:31:56
106	41	Vacation Leave	15.00	2026-11-24 09:31:57	2026-11-24 09:31:57
107	41	Sick Leave	15.00	2026-11-24 09:31:58	2026-11-24 09:31:58
108	41	Emergency Leave	3.00	2026-11-24 09:31:58	2026-11-24 09:31:58
109	40	Vacation Leave	15.00	2026-11-24 09:31:59	2026-11-24 09:31:59
110	40	Sick Leave	15.00	2026-11-24 09:32:00	2026-11-24 09:32:00
111	40	Emergency Leave	3.00	2026-11-24 09:32:01	2026-11-24 09:32:01
112	42	Vacation Leave	15.00	2026-11-24 09:32:01	2026-11-24 09:32:01
152	59	Sick Leave	15.00	2026-11-25 11:36:49	2026-11-25 11:36:49
153	59	Emergency Leave	3.00	2026-11-25 11:36:50	2026-11-25 11:36:50
154	166	Vacation Leave	9.00	2026-11-25 11:36:53	2026-11-25 11:36:53
155	166	Sick Leave	9.00	2026-11-25 11:36:54	2026-11-25 11:36:54
113	42	Sick Leave	15.00	2026-11-24 09:32:02	2026-11-24 09:32:02
114	42	Emergency Leave	3.00	2026-11-24 09:32:03	2026-11-24 09:32:03
115	38	Vacation Leave	11.00	2026-11-24 09:32:04	2026-11-24 09:32:04
116	38	Sick Leave	11.00	2026-11-24 09:32:05	2026-11-24 09:32:05
117	38	Emergency Leave	3.00	2026-11-24 09:32:05	2026-11-24 09:32:05
118	43	Vacation Leave	15.00	2026-11-24 09:32:06	2026-11-24 09:32:06
119	43	Sick Leave	15.00	2026-11-24 09:32:07	2026-11-24 09:32:07
120	43	Emergency Leave	3.00	2026-11-24 09:32:08	2026-11-24 09:32:08
156	166	Emergency Leave	3.00	2026-11-25 11:36:54	2026-11-25 11:36:54
157	114	Vacation Leave	11.00	2026-11-25 11:36:55	2026-11-25 11:36:55
158	114	Sick Leave	11.00	2026-11-25 11:36:56	2026-11-25 11:36:56
159	114	Emergency Leave	3.00	2026-11-25 11:36:57	2026-11-25 11:36:57
160	195	Vacation Leave	15.00	2026-11-25 11:36:58	2026-11-25 11:36:58
161	195	Sick Leave	15.00	2026-11-25 11:36:59	2026-11-25 11:36:59
162	195	Emergency Leave	3.00	2026-11-25 11:36:59	2026-11-25 11:36:59
163	167	Vacation Leave	9.00	2026-11-25 11:37:00	2026-11-25 11:37:00
164	167	Sick Leave	9.00	2026-11-25 11:37:01	2026-11-25 11:37:01
165	167	Emergency Leave	3.00	2026-11-25 11:37:02	2026-11-25 11:37:02
166	79	Vacation Leave	13.00	2026-11-25 11:37:03	2026-11-25 11:37:03
167	79	Sick Leave	13.00	2026-11-25 11:37:03	2026-11-25 11:37:03
168	79	Emergency Leave	3.00	2026-11-25 11:37:04	2026-11-25 11:37:04
169	147	Vacation Leave	15.00	2026-11-25 11:37:05	2026-11-25 11:37:05
170	147	Sick Leave	15.00	2026-11-25 11:37:06	2026-11-25 11:37:06
171	147	Emergency Leave	3.00	2026-11-25 11:37:07	2026-11-25 11:37:07
172	115	Vacation Leave	15.00	2026-11-25 11:37:08	2026-11-25 11:37:08
173	115	Sick Leave	15.00	2026-11-25 11:37:08	2026-11-25 11:37:08
174	115	Emergency Leave	3.00	2026-11-25 11:37:09	2026-11-25 11:37:09
175	168	Vacation Leave	9.00	2026-11-25 11:37:10	2026-11-25 11:37:10
176	168	Sick Leave	9.00	2026-11-25 11:37:11	2026-11-25 11:37:11
177	168	Emergency Leave	3.00	2026-11-25 11:37:12	2026-11-25 11:37:12
178	196	Vacation Leave	15.00	2026-11-25 11:37:13	2026-11-25 11:37:13
179	196	Sick Leave	15.00	2026-11-25 11:37:13	2026-11-25 11:37:13
180	196	Emergency Leave	3.00	2026-11-25 11:37:14	2026-11-25 11:37:14
181	169	Vacation Leave	9.00	2026-11-25 11:37:15	2026-11-25 11:37:15
182	169	Sick Leave	9.00	2026-11-25 11:37:16	2026-11-25 11:37:16
183	169	Emergency Leave	3.00	2026-11-25 11:37:16	2026-11-25 11:37:16
184	54	Vacation Leave	15.00	2026-11-25 11:37:17	2026-11-25 11:37:17
185	54	Sick Leave	15.00	2026-11-25 11:37:18	2026-11-25 11:37:18
186	54	Emergency Leave	3.00	2026-11-25 11:37:19	2026-11-25 11:37:19
187	170	Vacation Leave	9.00	2026-11-25 11:37:23	2026-11-25 11:37:23
188	170	Sick Leave	9.00	2026-11-25 11:37:24	2026-11-25 11:37:24
189	170	Emergency Leave	3.00	2026-11-25 11:37:25	2026-11-25 11:37:25
190	60	Vacation Leave	15.00	2026-11-25 11:37:26	2026-11-25 11:37:26
191	60	Sick Leave	15.00	2026-11-25 11:37:27	2026-11-25 11:37:27
192	60	Emergency Leave	3.00	2026-11-25 11:37:27	2026-11-25 11:37:27
193	62	Vacation Leave	15.00	2026-11-25 11:37:28	2026-11-25 11:37:28
194	62	Sick Leave	15.00	2026-11-25 11:37:29	2026-11-25 11:37:29
195	62	Emergency Leave	3.00	2026-11-25 11:37:30	2026-11-25 11:37:30
196	171	Vacation Leave	9.00	2026-11-25 11:37:32	2026-11-25 11:37:32
197	171	Sick Leave	9.00	2026-11-25 11:37:33	2026-11-25 11:37:33
198	171	Emergency Leave	3.00	2026-11-25 11:37:34	2026-11-25 11:37:34
199	172	Vacation Leave	9.00	2026-11-25 11:37:35	2026-11-25 11:37:35
200	172	Sick Leave	9.00	2026-11-25 11:37:36	2026-11-25 11:37:36
201	172	Emergency Leave	3.00	2026-11-25 11:37:36	2026-11-25 11:37:36
202	194	Vacation Leave	15.00	2026-11-25 11:37:37	2026-11-25 11:37:37
203	194	Sick Leave	15.00	2026-11-25 11:37:38	2026-11-25 11:37:38
204	194	Emergency Leave	3.00	2026-11-25 11:37:39	2026-11-25 11:37:39
205	80	Vacation Leave	15.00	2026-11-25 11:37:40	2026-11-25 11:37:40
206	80	Sick Leave	15.00	2026-11-25 11:37:40	2026-11-25 11:37:40
207	80	Emergency Leave	3.00	2026-11-25 11:37:41	2026-11-25 11:37:41
208	116	Vacation Leave	15.00	2026-11-25 11:37:42	2026-11-25 11:37:42
209	116	Sick Leave	15.00	2026-11-25 11:37:43	2026-11-25 11:37:43
210	116	Emergency Leave	3.00	2026-11-25 11:37:44	2026-11-25 11:37:44
211	148	Vacation Leave	15.00	2026-11-25 11:37:45	2026-11-25 11:37:45
212	148	Sick Leave	15.00	2026-11-25 11:37:45	2026-11-25 11:37:45
213	148	Emergency Leave	3.00	2026-11-25 11:37:46	2026-11-25 11:37:46
214	173	Vacation Leave	9.00	2026-11-25 11:37:49	2026-11-25 11:37:49
215	173	Sick Leave	9.00	2026-11-25 11:37:50	2026-11-25 11:37:50
216	173	Emergency Leave	3.00	2026-11-25 11:37:50	2026-11-25 11:37:50
217	197	Vacation Leave	13.00	2026-11-25 11:37:51	2026-11-25 11:37:51
218	197	Sick Leave	13.00	2026-11-25 11:37:52	2026-11-25 11:37:52
219	197	Emergency Leave	3.00	2026-11-25 11:37:53	2026-11-25 11:37:53
220	65	Vacation Leave	15.00	2026-11-25 11:37:54	2026-11-25 11:37:54
221	65	Sick Leave	15.00	2026-11-25 11:37:54	2026-11-25 11:37:54
222	65	Emergency Leave	3.00	2026-11-25 11:37:55	2026-11-25 11:37:55
223	51	Vacation Leave	15.00	2026-11-25 11:37:56	2026-11-25 11:37:56
224	51	Sick Leave	15.00	2026-11-25 11:37:57	2026-11-25 11:37:57
225	51	Emergency Leave	3.00	2026-11-25 11:37:58	2026-11-25 11:37:58
226	67	Vacation Leave	15.00	2026-11-25 11:37:59	2026-11-25 11:37:59
227	67	Sick Leave	15.00	2026-11-25 11:37:59	2026-11-25 11:37:59
228	67	Emergency Leave	3.00	2026-11-25 11:38:00	2026-11-25 11:38:00
229	117	Vacation Leave	13.00	2026-11-25 11:38:01	2026-11-25 11:38:01
230	117	Sick Leave	13.00	2026-11-25 11:38:02	2026-11-25 11:38:02
231	117	Emergency Leave	3.00	2026-11-25 11:38:03	2026-11-25 11:38:03
232	68	Vacation Leave	15.00	2026-11-25 11:38:04	2026-11-25 11:38:04
233	68	Sick Leave	15.00	2026-11-25 11:38:04	2026-11-25 11:38:04
234	68	Emergency Leave	3.00	2026-11-25 11:38:05	2026-11-25 11:38:05
235	174	Vacation Leave	9.00	2026-11-25 11:38:08	2026-11-25 11:38:08
236	174	Sick Leave	9.00	2026-11-25 11:38:09	2026-11-25 11:38:09
237	174	Emergency Leave	3.00	2026-11-25 11:38:09	2026-11-25 11:38:09
238	199	Vacation Leave	9.00	2026-11-25 11:38:10	2026-11-25 11:38:10
239	199	Sick Leave	9.00	2026-11-25 11:38:11	2026-11-25 11:38:11
240	199	Emergency Leave	3.00	2026-11-25 11:38:12	2026-11-25 11:38:12
241	175	Vacation Leave	9.00	2026-11-25 11:38:13	2026-11-25 11:38:13
242	175	Sick Leave	9.00	2026-11-25 11:38:14	2026-11-25 11:38:14
243	175	Emergency Leave	3.00	2026-11-25 11:38:14	2026-11-25 11:38:14
244	149	Vacation Leave	15.00	2026-11-25 11:38:15	2026-11-25 11:38:15
245	149	Sick Leave	15.00	2026-11-25 11:38:16	2026-11-25 11:38:16
246	149	Emergency Leave	3.00	2026-11-25 11:38:17	2026-11-25 11:38:17
247	176	Vacation Leave	9.00	2026-11-25 11:38:18	2026-11-25 11:38:18
248	176	Sick Leave	9.00	2026-11-25 11:38:18	2026-11-25 11:38:18
249	176	Emergency Leave	3.00	2026-11-25 11:38:19	2026-11-25 11:38:19
250	177	Vacation Leave	9.00	2026-11-25 11:38:20	2026-11-25 11:38:20
251	177	Sick Leave	9.00	2026-11-25 11:38:21	2026-11-25 11:38:21
252	177	Emergency Leave	3.00	2026-11-25 11:38:22	2026-11-25 11:38:22
253	150	Vacation Leave	15.00	2026-11-25 11:38:23	2026-11-25 11:38:23
254	150	Sick Leave	15.00	2026-11-25 11:38:23	2026-11-25 11:38:23
255	150	Emergency Leave	3.00	2026-11-25 11:38:24	2026-11-25 11:38:24
256	118	Vacation Leave	11.00	2026-11-25 11:38:25	2026-11-25 11:38:25
257	118	Sick Leave	11.00	2026-11-25 11:38:26	2026-11-25 11:38:26
258	118	Emergency Leave	3.00	2026-11-25 11:38:27	2026-11-25 11:38:27
259	81	Vacation Leave	11.00	2026-11-25 11:38:28	2026-11-25 11:38:28
260	81	Sick Leave	11.00	2026-11-25 11:38:28	2026-11-25 11:38:28
261	81	Emergency Leave	3.00	2026-11-25 11:38:29	2026-11-25 11:38:29
262	61	Vacation Leave	15.00	2026-11-25 11:38:30	2026-11-25 11:38:30
263	61	Sick Leave	15.00	2026-11-25 11:38:31	2026-11-25 11:38:31
264	61	Emergency Leave	3.00	2026-11-25 11:38:32	2026-11-25 11:38:32
265	69	Vacation Leave	15.00	2026-11-25 11:38:32	2026-11-25 11:38:32
266	69	Sick Leave	15.00	2026-11-25 11:38:33	2026-11-25 11:38:33
267	69	Emergency Leave	3.00	2026-11-25 11:38:34	2026-11-25 11:38:34
268	146	Vacation Leave	15.00	2026-11-25 11:38:35	2026-11-25 11:38:35
269	146	Sick Leave	15.00	2026-11-25 11:38:36	2026-11-25 11:38:36
270	212	Vacation Leave	15.00	2026-11-26 09:32:16	2026-11-26 09:32:16
271	212	Sick Leave	15.00	2026-11-26 09:32:17	2026-11-26 09:32:17
272	212	Emergency Leave	3.00	2026-11-26 09:32:18	2026-11-26 09:32:18
273	202	Vacation Leave	9.00	2026-11-26 09:32:19	2026-11-26 09:32:19
274	202	Sick Leave	9.00	2026-11-26 09:32:19	2026-11-26 09:32:19
275	202	Emergency Leave	3.00	2026-11-26 09:32:20	2026-11-26 09:32:20
276	226	Vacation Leave	11.00	2026-11-26 09:32:41	2026-11-26 09:32:41
277	226	Sick Leave	11.00	2026-11-26 09:32:41	2026-11-26 09:32:41
278	226	Emergency Leave	3.00	2026-11-26 09:32:42	2026-11-26 09:32:42
279	227	Vacation Leave	15.00	2026-11-26 09:32:44	2026-11-26 09:32:44
280	227	Sick Leave	15.00	2026-11-26 09:32:45	2026-11-26 09:32:45
281	227	Emergency Leave	3.00	2026-11-26 09:32:46	2026-11-26 09:32:46
282	228	Vacation Leave	15.00	2026-11-26 09:33:13	2026-11-26 09:33:13
283	228	Sick Leave	15.00	2026-11-26 09:33:14	2026-11-26 09:33:14
284	228	Emergency Leave	3.00	2026-11-26 09:33:14	2026-11-26 09:33:14
285	210	Vacation Leave	9.00	2026-11-26 09:33:17	2026-11-26 09:33:17
286	210	Sick Leave	9.00	2026-11-26 09:33:17	2026-11-26 09:33:17
287	210	Emergency Leave	3.00	2026-11-26 09:33:18	2026-11-26 09:33:18
288	229	Vacation Leave	9.00	2026-11-26 09:33:19	2026-11-26 09:33:19
289	229	Sick Leave	9.00	2026-11-26 09:33:20	2026-11-26 09:33:20
290	229	Emergency Leave	3.00	2026-11-26 09:33:20	2026-11-26 09:33:20
291	213	Vacation Leave	15.00	2026-11-26 09:33:26	2026-11-26 09:33:26
292	213	Sick Leave	15.00	2026-11-26 09:33:27	2026-11-26 09:33:27
293	213	Emergency Leave	3.00	2026-11-26 09:33:28	2026-11-26 09:33:28
294	214	Vacation Leave	15.00	2026-11-26 09:33:42	2026-11-26 09:33:42
295	214	Sick Leave	15.00	2026-11-26 09:33:42	2026-11-26 09:33:42
296	214	Emergency Leave	3.00	2026-11-26 09:33:43	2026-11-26 09:33:43
297	146	Emergency Leave	3.00	2026-11-26 09:33:45	2026-11-26 09:33:45
298	193	Vacation Leave	15.00	2026-11-26 09:33:46	2026-11-26 09:33:46
299	193	Sick Leave	15.00	2026-11-26 09:33:46	2026-11-26 09:33:46
300	193	Emergency Leave	3.00	2026-11-26 09:33:47	2026-11-26 09:33:47
301	82	Vacation Leave	15.00	2026-11-26 09:33:48	2026-11-26 09:33:48
302	82	Sick Leave	15.00	2026-11-26 09:33:49	2026-11-26 09:33:49
303	82	Emergency Leave	3.00	2026-11-26 09:33:49	2026-11-26 09:33:49
304	151	Vacation Leave	15.00	2026-11-26 09:33:50	2026-11-26 09:33:50
305	151	Sick Leave	15.00	2026-11-26 09:33:51	2026-11-26 09:33:51
306	151	Emergency Leave	3.00	2026-11-26 09:33:52	2026-11-26 09:33:52
307	215	Vacation Leave	13.00	2026-11-26 09:33:56	2026-11-26 09:33:56
308	215	Sick Leave	13.00	2026-11-26 09:33:57	2026-11-26 09:33:57
309	215	Emergency Leave	3.00	2026-11-26 09:33:57	2026-11-26 09:33:57
310	119	Vacation Leave	13.00	2026-11-26 09:33:58	2026-11-26 09:33:58
311	119	Sick Leave	13.00	2026-11-26 09:33:59	2026-11-26 09:33:59
312	119	Emergency Leave	3.00	2026-11-26 09:34:00	2026-11-26 09:34:00
\.


--
-- Data for Name: leave_import_runs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.leave_import_runs (id, user_id, status, original_filename, imported, skipped, total_records, unmatched_employees, applied_employees, error, started_at, finished_at, created_at, updated_at) FROM stdin;
d77f7365-a93a-49c9-bdc8-b776282d522e	42	processing	LPA-23-8111-1791876860-LeaveApplications (1).xlsx	0	0	0	\N	\N	\N	2026-10-14 10:13:03	\N	2026-10-14 10:13:03	2026-10-14 10:13:03
7c5c479a-d5e0-48ba-8e44-5726f175970f	42	processing	LPA-23-8111-1791876860-LeaveApplications (1).xlsx	0	0	0	\N	\N	\N	2026-10-14 10:22:50	\N	2026-10-14 10:22:50	2026-10-14 10:22:50
\.


--
-- Data for Name: leave_requests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.leave_requests (id, employee_id, leave_type, start_date, end_date, days_deducted, status, cutoff_date, reason, created_at, updated_at, source_leave_id) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.migrations (id, migration, batch) FROM stdin;
1	0001_01_01_000000_create_users_table	1
2	0001_01_01_000001_create_cache_table	1
3	0001_01_01_000002_create_jobs_table	1
4	2026_03_28_000100_create_departments_table	1
5	2026_03_28_000200_create_employees_table	1
6	2026_03_28_001000_add_user_type_to_users_table	1
7	2026_03_28_001100_create_announcements_table	1
8	2026_03_28_001200_create_announcement_notifications_table	1
9	2026_04_04_000100_create_employee_credentials_table	1
10	2026_04_04_000200_create_attendance_records_table	1
11	2026_04_04_000300_create_leave_balances_table	1
12	2026_04_04_000400_create_leave_requests_table	1
13	2026_04_04_000500_add_address_to_employees_table	1
14	2026_04_04_001300_create_admin_configs_table	1
15	2026_04_04_001400_create_admin_audit_logs_table	1
16	2026_04_06_122600_add_target_office_to_announcements_table	1
17	2026_04_20_000100_add_approval_fields_to_employee_credentials_table	1
18	2026_04_20_000200_purge_soft_deleted_employees	1
19	2026_04_20_000300_add_dashboard_indexes_to_employees	1
20	2026_04_27_000100_add_employee_targeting_to_announcements_table	1
21	2026_04_28_000100_add_redirect_url_to_announcement_notifications_table	1
22	2026_04_28_000100_create_employee_schedule_submissions_table	1
23	2026_04_28_000200_add_schedule_status_to_attendance_records_table	1
24	2026_04_28_000300_add_term_label_to_employee_schedule_submissions_table	1
25	2026_04_29_000100_create_wfh_monitoring_submissions_table	1
26	2026_05_04_000000_optimize_sessions_table	1
27	2026_08_01_000100_create_academic_calendar_entries_table	1
28	2026_08_01_000200_add_day_type_to_academic_calendar_entries_table	1
29	2026_08_01_000300_add_wfh_class_suspension_to_academic_calendar_entries_table	1
30	2026_08_01_000400_add_wfh_class_suspension_check_constraint	1
31	2026_10_01_000100_create_privacy_notice_acknowledgments_table	1
32	2026_10_05_000100_add_degree_level_to_employee_credentials_table	1
33	2026_10_05_000100_add_monitoring_link_to_wfh_monitoring_submissions_table	1
34	2026_10_05_000200_add_target_user_to_announcements_table	1
35	2026_10_05_000600_remove_phone_and_address_from_employees_table	1
36	2026_10_07_000100_add_type_to_announcements_table	1
37	2026_10_13_000001_add_source_leave_id_to_leave_requests_table	2
38	2026_10_13_000100_add_employment_status_to_employees_table	3
39	2026_10_14_000001_create_leave_import_runs_table	4
40	2026_10_16_000211_create_extraction_validation_runs_table	5
41	2026_10_16_120000_add_leave_term_started_at_to_employees_table	5
42	2026_10_16_130000_add_term_start_date_to_employee_schedule_submissions_table	6
\.


--
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.password_reset_tokens (email, token, created_at) FROM stdin;
malaluangerard@gmail.com	$2y$12$qbK/g8kms6mXOxbvoUMAruwEgutX3knlytiD4ydskIxi7JnMmqb.C	2026-10-14 14:24:30
\.


--
-- Data for Name: privacy_notice_acknowledgments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.privacy_notice_acknowledgments (id, user_id, privacy_notice_version, acknowledged_at, created_at, updated_at) FROM stdin;
4	42	1.1	2026-10-15 23:39:35	2026-10-12 21:10:57	2026-10-15 23:39:36
2	40	1.1	2026-11-17 14:15:54	2026-10-12 21:05:25	2026-11-17 14:15:55
3	41	1.1	2026-11-26 09:52:03	2026-10-12 21:06:16	2026-11-26 09:52:03
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sessions (id, user_id, ip_address, user_agent, payload, last_activity) FROM stdin;
n21hz1XKEbRvjrVpo6lNNzMTQTMn7FabjaxDXMQr	\N	52.167.144.179	Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm) Chrome/116.0.1938.76 Safari/537.36	eyJfdG9rZW4iOiJ1cVlkeDJDRDE5dTYwTlZoTGNrOUJDYjFkYlYwaVNJZGpQeFlua1ExIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHBzOlwvXC9udWhyaXMuY29tXC9sb2dpbiIsInJvdXRlIjoibG9naW4ifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==	1793842152
naYP9oNkyzm3Qo4espUooT5Z708VC9IPFAsOV2AS	\N	2a02:4780:a:5e11::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 HostingerSelfie/3	eyJfdG9rZW4iOiJNS0NZZ001VHZjUjd3QkZOcjBVUXZ3b0gySUpET2JzQld3MTlaQVhCIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHBzOlwvXC9kZWVwc2t5Ymx1ZS1naXJhZmZlLTg5MDQ1Ny5ob3N0aW5nZXJzaXRlLmNvbSIsInJvdXRlIjoiaG9tZSJ9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19	1793850689
cwUbqI3toy6JyCSapuHmj07Kly5b4VDO5iQicqOW	\N	2a02:4780:a:5e11::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 HostingerSelfie/3	eyJfdG9rZW4iOiJnU0RicFJINEdFUGdoSDBxSDZFaG9rOFY3enV2eXFnRGNCTERZWHJsIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHBzOlwvXC9kZWVwc2t5Ymx1ZS1naXJhZmZlLTg5MDQ1Ny5ob3N0aW5nZXJzaXRlLmNvbVwvbG9naW4iLCJyb3V0ZSI6ImxvZ2luIn0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfX0=	1793850690
f5rHfiEieRCNFmPOX3mcaTlnDylGnuJOmX45xdp6	\N	40.77.167.10	Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm) Chrome/116.0.1938.76 Safari/537.36	eyJfdG9rZW4iOiJUeVNMT05YVGhCSEwzUGFNa1lVbEZEeEszVVVnY1VZUkFjUVY3VnVLIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHBzOlwvXC9udWhyaXMuY29tXC9sb2dpbiIsInJvdXRlIjoibG9naW4ifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==	1793835891
2AQYDca3JjdiMsjhM8ldG8dF51NOkClCSVdlqr9c	\N	203.82.34.100	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0	eyJfdG9rZW4iOiJTQnVDaXFVclVOZkdiTU5PWEEyVnlaNFU3NnFHdHlEbGE0dThiVkZaIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHBzOlwvXC9udWhyaXMuY29tXC9sb2dpbiIsInJvdXRlIjoibG9naW4ifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==	1793843010
Iti6ur7vxumFoQjjoDAoLSaIAYaxkmQFOAHpEfsY	\N	115.147.167.99	Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:160.0) Gecko/20100101 Firefox/160.0	eyJfdG9rZW4iOiJLWXVGNDFJSFhjUUI0U0ZHMzdZYXkxZkhkV2NQamdpNmVRTTVqOVBnIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHBzOlwvXC9udWhyaXMuY29tIiwicm91dGUiOiJob21lIn0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfX0=	1794879031
RCaHBHwAW1sX00k5oLH8iI9S598admg2RvjunCRz	\N	115.147.167.99	Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:160.0) Gecko/20100101 Firefox/160.0	eyJfdG9rZW4iOiJXUHV3cHU5NW1QQ1hnc29WMUJFSnAzSFdicW5pRXF6bWUza044SjhpIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHBzOlwvXC9udWhyaXMuY29tXC9sb2dpbiIsInJvdXRlIjoibG9naW4ifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==	1794879033
5yulGBlpGVGes3igCNhN8IneNxQzM1aPYsWDRJ6u	\N	40.77.167.10	Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm) Chrome/116.0.1938.76 Safari/537.36	eyJfdG9rZW4iOiJ5a3pYc0hpV2cwWHgzU3JPZW9hZ2o3STkzeGpid25wd1NVWmRCc3NRIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHBzOlwvXC9udWhyaXMuY29tXC9sb2dpbiIsInJvdXRlIjoibG9naW4ifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==	1793836274
dgSbd4KkmCsQvu3JpgLdOndZk2xXA4ozZX2SrO4u	\N	115.147.167.99	Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:160.0) Gecko/20100101 Firefox/160.0	eyJfdG9rZW4iOiJNMlNydUVqUHRFSjNyZkNHOGt3TDhYYzU2cktDdjVMYzVaUVRUTjEyIiwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119LCJfcHJldmlvdXMiOnsidXJsIjoiaHR0cHM6XC9cL251aHJpcy5jb21cL2xvZ2luIiwicm91dGUiOiJsb2dpbiJ9fQ==	1794879093
gXYGufrMtNPUTPDEOQrXY5kMgLp5VFFG2MbNS484	\N	40.77.167.30	Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm) Chrome/116.0.1938.76 Safari/537.36	eyJfdG9rZW4iOiJuYWwydlMwWlJtMU9GaDh1bHlXMmJTQ25lMjBoVDZhRHlxTUgyU3RrIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHBzOlwvXC9udWhyaXMuY29tXC9sb2dpbiIsInJvdXRlIjoibG9naW4ifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==	1793847500
lUyHnCUyUNHaoYHdn7pIXrLAzfMbM6mTHiKzFC2n	\N	194.104.11.244	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36/Nutch-1.23-SNAPSHOT	eyJfdG9rZW4iOiJWU2JjNUxDaXlDV25pSEg5b2E2UHlsSEk3V2M5c1V0ZmpvdjBaMVdNIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHBzOlwvXC9udWhyaXMuY29tIiwicm91dGUiOiJob21lIn0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfX0=	1793838459
5mEqYdkdhXE7vstlEWMyfxZyZGaDHsoWIEnJwXJz	\N	194.104.11.244	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36/Nutch-1.23-SNAPSHOT	eyJfdG9rZW4iOiJ4b3pDS3BlYjd6dHZOeGtLck1KSE9QUDBjV1lJUFhHeG81VFF5elpFIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHBzOlwvXC9udWhyaXMuY29tXC9sb2dpbiIsInJvdXRlIjoibG9naW4ifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==	1793838461
Ez9SqzFAIDDCocEkzN2q1xDkHB6x8tXxoajngQzh	\N	20.69.144.137	DuckDuckBot/1.0; (+http://duckduckgo.com/duckduckbot.html)	eyJfdG9rZW4iOiJwSFQ0UE4wbXJyT0hCWHlXMDFwbFNrSnRDS1FjSEhKc3F3MVdhY0dwIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHBzOlwvXC9udWhyaXMuY29tXC9sb2dpbiIsInJvdXRlIjoibG9naW4ifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==	1793848210
oXb2fLtMXS2Yh7MOkuxXiBn0YnhhYWwvjLa8BOil	\N	20.191.45.212	DuckDuckBot/1.1; (+http://duckduckgo.com/duckduckbot.html)	eyJfdG9rZW4iOiJtdkZVcVRTcUw5dnA1Sm13YW1NbDJ3RzlQbFY1OHpOUmFseVFwekR6IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHBzOlwvXC9udWhyaXMuY29tIiwicm91dGUiOiJob21lIn0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfX0=	1793841432
Ys850lHLGiIEYIMITgpY6voHyv62w7etnpIzPSmh	\N	20.191.45.212	DuckDuckBot/1.1; (+http://duckduckgo.com/duckduckbot.html)	eyJfdG9rZW4iOiIzNXJ1V0FXb0FqY2hROUMzdEZRR3ZieEswd05xZEhnMTVlOXB2UUNNIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHBzOlwvXC9udWhyaXMuY29tXC9sb2dpbiIsInJvdXRlIjoibG9naW4ifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==	1793841434
8bDtgIJVDyADMSls26s9S4MW04EjtDv6RZyrOXTd	\N	203.82.34.100	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0	eyJfdG9rZW4iOiIzekxBSzN6c0NSVXhxdDh3cmxDQmFTR0FvWGJxUVR4WnlDb2Joc1d3IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHBzOlwvXC9udWhyaXMuY29tXC9sb2dpbiIsInJvdXRlIjoibG9naW4ifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==	1793842930
vx5FNDnMR4jCrdbwCKftapiZFJwfM9uITCLmfupp	\N	66.249.77.160	Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)	eyJfdG9rZW4iOiJmMlE5SVkxOFBJa3JRQ0NqWVpEdG1yNkNTejlsN2pFbktIV1RMa2MwIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHBzOlwvXC9udWhyaXMuY29tXC9sb2dpbiIsInJvdXRlIjoibG9naW4ifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==	1793849766
diD3LSeC8aLPi5EWywrkmSl5mGyRgiEwAWiyDb3F	\N	66.249.77.160	Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)	eyJfdG9rZW4iOiJnbnpyVkswUmdjRDZWSDBheEx4SVVQR09BZzY2Q0JXdm0zU3AyR0VQIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHBzOlwvXC9udWhyaXMuY29tXC9sb2dpbiIsInJvdXRlIjoibG9naW4ifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==	1793849768
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, name, email, email_verified_at, password, remember_token, created_at, updated_at, user_type) FROM stdin;
92	Merry Jaine Liwanag	Liwanag@gmail.com	\N	$2y$12$XqXPTxV0D0Q/JDxbXdwzB.SoLXCHj9N1lzHLMjBWoINlcK8GC066a	\N	2026-11-24 10:12:30	2026-11-24 10:12:30	3
93	Mendoza Jess Virrey	Mendoza@gmail.com	\N	$2y$12$tc3loxvFuGNFfo.d1DK6v.877yleckeyn48OD65xhyj9wcZVtDfKq	\N	2026-11-24 10:14:47	2026-11-24 10:14:47	3
94	Maria Lourdes Culla Bañaga	Banaga@gmail.com	\N	$2y$12$nc/72w8hgnpnZZaIOy7J3urBfADIvLSYzUgpDypGxUKFe1PT77gK6	\N	2026-11-24 10:16:20	2026-11-24 10:16:20	3
95	Rose Anne Magsino	Magsino@gmail.com	\N	$2y$12$j0TVs4LkZXn8.II3O8UfOeosv7f5kXOUU7KSEd.Ncs6YCWkpCkL5e	\N	2026-11-24 10:17:43	2026-11-24 10:17:43	3
40	Test HR	test101HR@gmail.com	2026-10-12 21:11:53	$2y$12$pqATnXBXlV55KAeovZITOua5DhSteXWU8btA6D49o.DK2vI4ScLaC	phVw9qyXHobnNyhWVByvJApqgSzYiqhGCV1kku5oLfVU55ltxtIofBQzQFr3	2026-10-12 21:04:27	2026-10-12 21:11:53	2
41	Test Admin	test101A@gmail.com	2026-10-12 21:11:54	$2y$12$TSMtXEOWCY73cRY4bApw6.64dZjDKmKskUk5DX/HTBXBYtDRKPtpi	9ihVuXfxTmzfoVqoHENECc8fW1KXbNFbvZgdRBo1Hk3mOvPb5wHxthQ953Iv	2026-10-12 21:04:28	2026-10-12 21:11:54	1
42	Nulptimekeeping	nulptimekeeping@gmail.com	\N	$2y$12$hqZcae.P5plNM.tKJDX7x.PpOUTGyX4ev9GtwTO6Vmi.2C2xrtwC.	ogTsAWqx8W9No84tA4hYILE7nGUpUhuVIjm0yDJFxFyPHScbbR0uTr6gOAUV	2026-10-12 21:07:19	2026-10-12 21:10:40	2
72	JOSIERENE Abel	abel@gmail.com	\N	$2y$12$h1e5O.9U4xcfviv38vQEj.4ZaAsCUGbPfukkpK1p1udl4Iyz6lUD2	\N	2026-11-23 11:43:00	2026-11-23 11:43:00	3
73	Jojit Aguirre	jojit@gmail.com	\N	$2y$12$oOjQWmCtCBCJAzKaUGNLTuFT4rKp0hK9xBcSfsQHiCca6BKPpQYEq	\N	2026-11-23 11:56:26	2026-11-23 11:56:26	3
74	CAROL ALFARO	carol@gmail.com	\N	$2y$12$N9CJqMwOdZZPrOHhzGvcQOWM7Lw.rmuhUx1arQBJKKpJNqqfS3q0W	\N	2026-11-23 14:57:09	2026-11-23 14:57:09	3
75	ALLIC CLARISA	allic@gmail.com	\N	$2y$12$VtAMKqqLaCTx3eUR4c6cpuD7CIK6FyM1NeR1Qs9ufQDhD0xpWM.6C	\N	2026-11-23 15:08:20	2026-11-23 15:08:20	3
76	Joseph Benedic Bandelaria,	bandelaria@gmail.com	\N	$2y$12$HImGjU0i8mL/N3gVhTy0FeeJy0JPWWavtc20/8/Qdp/ro0sS.rUAu	\N	2026-11-23 15:21:38	2026-11-23 15:21:38	3
77	Albien Ryne Bautista,	albien@gmail.com	\N	$2y$12$BcaNWVakS.Zj1aNAVLKMIehp4TGl7qfYx86j/X/oVggXijiI4QmmC	\N	2026-11-23 15:30:34	2026-11-23 15:30:34	3
78	Belen Kamil Angela	belen@gmail.com	\N	$2y$12$JNfcHd2tNpb1uqemEarq0uNfg0S4QN3qc6mSIzfyL6/pbPukQxZZm	\N	2026-11-23 15:45:26	2026-11-23 15:45:26	3
79	Bobby Buendia	bobby@gmail.com	\N	$2y$12$mgKSuJsbA8zpm7i6OvMfteBOhsrnHk9c9DkVY7gv8doLsbgKWEdxS	\N	2026-11-23 15:56:43	2026-11-23 15:56:43	3
80	Maria Dolores Evangelista	maria@gmail.com	\N	$2y$12$W87SUgdOCNMFswDQ62ID5e9dCClbOTO6Ow/jK6mm.r.d9r5xRAv7W	\N	2026-11-23 16:36:05	2026-11-23 16:36:05	3
81	Krizel Joanne Escala	krizel@gmail.com	\N	$2y$12$HIFD5Dh8TeKnmwdwdVB0qexMXSRK8drKxunXkz/4MPHSPBnyuxtWG	\N	2026-11-23 16:37:45	2026-11-23 16:37:45	3
96	Charmaine Gellieann Ramos Magsino	Charmaine@gmail.com	\N	$2y$12$vioo7ZgdGI5fPK00Hw49o.NkLEhEbGcSBKi6wZFvmt6Ake1K.OQUW	\N	2026-11-24 10:23:54	2026-11-24 10:23:54	3
97	Khim Joshua Magtibay	Magtibay@gmail.com	\N	$2y$12$IJif25E.BZ731/rLys1inO6ZUXw8qjDlBywtvXIbpC9vrRYJh2TbW	\N	2026-11-24 10:25:49	2026-11-24 10:25:49	3
82	Janice Fischer	janice@gmail.com	\N	$2y$12$Usqll1FbkV99YDIJM5igweiMqSKAdxSu9GWDau9dnzw1NMWnqK4dO	\N	2026-11-23 16:39:49	2026-11-23 16:39:49	3
83	Nesiel Oros Manalo	nisiel@gmail.com	\N	$2y$12$XgwwFQnl63omXhbGXmymTOwcczGAy3nat8R73Uk2msmvCNbe6Y6zW	\N	2026-11-23 16:44:19	2026-11-23 16:44:19	3
84	Tiffanny Gail Nova	nova@gmail.com	\N	$2y$12$Sz80srGv1ba1vDlFGKl6DuvQCdebXwpncVepdz.CTCdYrRW2lHFl6	\N	2026-11-23 16:48:14	2026-11-23 16:48:14	3
85	Camille Silva	silva@gmail.com	\N	$2y$12$Exg.eWMBO4UMNaYYY93wvu227M6I8g7DNsei7.hgOfSg4IlErrvmO	\N	2026-11-23 17:08:20	2026-11-23 17:08:20	3
86	John Lesther Panggat	panggat@gmail.com	\N	$2y$12$0muIUnFtlOD6wZr29icsjOtGGr95QjAo1azxDdrb1RUqHhMLUCWmW	\N	2026-11-24 09:15:44	2026-11-24 09:15:44	3
87	Cherry Lyn Carpio	carpio@gmail.com	\N	$2y$12$pjE66R89CEE6MekXDfqikulLYQpfiurk9E0CR0EsZTN7y98da4oUG	\N	2026-11-24 09:18:00	2026-11-24 09:18:00	3
88	Jiselle Umali	umali@gmail.com	\N	$2y$12$1eP6dKFRNsfABBvfXzh.AeChQnMyYKuGixhOXqb/E9qpP0KZXWEs2	\N	2026-11-24 09:20:16	2026-11-24 09:20:16	3
89	Diane Angelika Novicio	Novicio@gmail.com	\N	$2y$12$zqIFWhQGMWY/cbLEpB81TuJquTak2upajfdJEyhj.m1L2uLbw0C.O	\N	2026-11-24 09:22:19	2026-11-24 09:22:19	3
90	Anna Mae Sales Olan	Olan@gmail.com	\N	$2y$12$cVYDJPAp56wZPKAASZFUzuOqFDKX9PBh5Y.zFqAsibBkg4zFrYFs.	\N	2026-11-24 09:30:50	2026-11-24 09:30:50	3
91	Lyndon Catapang	catapang@gmail.com	\N	$2y$12$uQVHJj7BTnk0BxGAm8Zbv.1H56utlO6Z7enKWfUHrFAtbZcsYCLQS	\N	2026-11-24 09:56:08	2026-11-24 09:56:08	3
98	Lorena Manimtim	Manimtim@gmail.com	\N	$2y$12$9mbZVKarN8QZxd/KyFxSmOs9uKsm3v3svK3wvXRnZRx5pHlfAOT6.	\N	2026-11-24 10:27:47	2026-11-24 10:27:47	3
99	Rowena Alcoba	alcoba@gmail.com	\N	$2y$12$fE/YYKnee51ogNflkClAPuJLIp93C9DidCA.MSdkwNu/Pnkr2xI6e	\N	2026-11-24 10:31:20	2026-11-24 10:31:20	3
100	Noelah Mae Borbon	borbon@gmail.com	\N	$2y$12$dzWqusaIZrwMYMeegKzL1uskvDP.slhgvF8vXV2qyp9hdqaJ4o.Zi	\N	2026-11-24 10:35:37	2026-11-24 10:35:37	3
101	Irish Dimaculangan	Dimaculangan@gmail.com	\N	$2y$12$foH4CTlG7IENI0dOKqKJYe64ObqoKGxyQtJmekoOIb.M3GOffJKC2	\N	2026-11-24 10:36:15	2026-11-24 10:36:15	3
102	Marjeric Buenafe	buenafe@gmail.com	\N	$2y$12$PFqMJeEbFqzRLQxeGmSoMOcCe23LkxsEmbGwR32GTx3wjIFaAr5aW	\N	2026-11-24 10:37:16	2026-11-24 10:37:16	3
103	Jay Sargento	Sargento@gmail.com	\N	$2y$12$HAhkkrYtgbLIPph0HavJ5eR4F6Mgns3L3kA9zTD7hf8ahod6uDlhy	\N	2026-11-24 10:44:24	2026-11-24 10:44:24	3
104	Kenneth Myro Garcia	Garcia@gmail.com	\N	$2y$12$m9HKDLv0ain9SC9gxdRNh.afH.8TTTomT5whgmyRkqthHkCSzFtDq	\N	2026-11-24 10:57:11	2026-11-24 10:57:11	3
105	Jeroe Marvi Casupanan	casupanan@gmail.com	\N	$2y$12$7rnfVah4FCuvIPkNMy28nOaK0IeOu5f53V0OMnThT6n0oGa1GJZs2	\N	2026-11-24 10:58:31	2026-11-24 10:58:31	3
106	Maria Andrea Magaling	Magaling@gmail.com	\N	$2y$12$C.g9m4Prrqba4HhiyCwuxOAzhm1R1R3c4QR6wtyLiLLKB1OK0x32K	\N	2026-11-24 10:59:09	2026-11-24 10:59:09	3
107	Ronald Catapang	Catapang@gmail.com	\N	$2y$12$P77eARmS4GwG8GprZQI50OOwRL620R0IYaSTEX89RPgK8YPS1FZpu	\N	2026-11-24 11:03:36	2026-11-24 11:03:36	3
108	Rosa Maria Cayabyab	cayabyab@gmail.com	\N	$2y$12$2bWswbM.ge21WNQ7GhZbZe8p4ipRkv.H/rMAkTVJvZTK0nY3mBMAq	\N	2026-11-24 11:09:58	2026-11-24 11:09:58	3
109	Jay-ar Dimaculangan	dimaculangan@gmail.com	\N	$2y$12$fjsNT/RoyO1.pLcv88BA0efXWxfA56lFIF2rNCagXTyWhKxVAS7PW	\N	2026-11-24 11:11:18	2026-11-24 11:11:18	3
110	Josele Mari Figueroa	Josele@gmail.com	\N	$2y$12$zmzAdpmy1QwDu99vLphR4eJhuRS5AtJ4UsYPxiptoAafRLH33ZYN2	\N	2026-11-24 11:13:16	2026-11-24 11:13:16	3
111	Larry Fronda Jr.	Fronda@gmail.com	\N	$2y$12$SrDgsG5y8aP.Qx9N.jXvx.hUU6PX.qKRaJNxNnOhFTI6S2Lg7zAKS	\N	2026-11-24 11:14:52	2026-11-24 11:14:52	3
112	Gene Roy Hernandez	Hernandez@gmail.com	\N	$2y$12$2HNjoEq7pPJb8s5T6uz8hORjyVcSX0teDfeD2Y4umfh6J3id8sWe6	\N	2026-11-24 11:15:59	2026-11-24 11:15:59	3
113	Judylen Monterey	Monterey@gmail.com	\N	$2y$12$qKQcirV93.SCIjyLcR/P7O.Jhav0c135PFlwFHh/bu.d10NPTiTzu	\N	2026-11-24 11:26:01	2026-11-24 11:26:01	3
114	Redem Quinagoran	Quinagoran@gmail.com	\N	$2y$12$sqa/Qps5IPymOHgAzuWVyui03U5KSqAL7qxNP/l6ICu0DNT/ecpnC	\N	2026-11-24 11:27:09	2026-11-24 11:27:09	3
115	Aaron Christian Rodriguez	Rodriguez@gmail.com	\N	$2y$12$EaNpy/ILtRiOo/zxEswq5.GcoD1861yG.9JiVnX.Al5VEcA20RK9a	\N	2026-11-24 11:28:43	2026-11-24 11:28:43	3
116	Sebulino Honorato	Honorato@gmail.com	\N	$2y$12$WPo/lSXf5uNTF0FybK2V1O0WS6W8lWjhD4dUAjQv4cRENT98gobtW	\N	2026-11-24 11:30:28	2026-11-24 11:30:28	3
117	Romielyn Morcilla	Morcilla@gmail.com	\N	$2y$12$zQXt.k6hl0ifsOYEnpfufuCWclfHO2TcucDtMIvTFPL1498csbxbm	\N	2026-11-24 14:07:20	2026-11-24 14:07:20	3
118	Ma. Cielo Africa	dummyacc@gmail.com	\N	$2y$12$jt.eNJ/QEbMjNlxDWajdTOQ1XZpAyygHSTCvuU0nHMi4ZKfUxLJNG	\N	2026-11-24 14:38:00	2026-11-24 14:38:00	3
119	Arnolfo Arcibal	dummyacc1@gmail.com17	\N	$2y$12$coMChsv4PlxXbUolHUlKaeTlLx7P9hdXy6XCb3PDX9qOMDnALHgKq	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
120	Carlos Caesar Caday	dummyacc1@gmail.com47	\N	$2y$12$yBOWcx7WarozRN.ldLdy4uKpDfzp6f3JPWTAqYdTeArdVSGaqDi5.	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
121	Alestair Dimaculangan	dummyacc1@gmail.com86	\N	$2y$12$4EYWKHUfKkkzEuOotS4J1.nD23CoZovYP7cKiIDSGUYzgznMQ6.CG	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
122	Francis Jay Enriquez	dummyacc1@gmail.com97	\N	$2y$12$GrjI3ZAleXQWiVOcAcBOVO3ZRlrZ9S20CQzmsrjYx5ikDao2iuN1.	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
123	Rose Ann Fernandez	dummyacc1@gmail.com105	\N	$2y$12$uixuw35cPB/ZgDIO94dTEuL3nmiEEUGrQRO7VZHld1YM5B7EI0YX2	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
124	Beatrice Gadiana	dummyacc1@gmail.com110	\N	$2y$12$lxu0K25Smr5e.kT8GNkTWeV261eKRaJVZ0HAJxSZMrgW87eGy8HvW	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
125	Carl Garcia	dummyacc1@gmail.com112	\N	$2y$12$.SEDALdpLSq2Uu3tQvx8iezlOBHhT7O..ywIJ/pLPgOSWI0bXsd1m	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
126	Russel Jimenez	dummyacc1@gmail.com126	\N	$2y$12$oswOhC9ehCwkkc2Rd8D8K.iGIChvNj4WHVBwmeU310xIPHBvyI6pi	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
127	Lawrence Matthew Juan	dummyacc1@gmail.com127	\N	$2y$12$Q1fGIWtrWIr1LACGMjkjfOBbRVNX0Lhwhg7ASWD.vGHC25pohxQqq	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
128	Nico Shawn Lambio	dummyacc1@gmail.com133	\N	$2y$12$o4JiQ4Il57Yh6YSNh9w3..YF66bGEcF5zZqu2TP4LYZ1SuVxvRtNu	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
129	Flordeliza Lantican	dummyacc1@gmail.com134	\N	$2y$12$v12vlosh/nmZt.R/61/hiOlmIgdAaUkBJS7eEp3GeWKu35CCTlFoq	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
130	Chelsea Louella Lat	dummyacc1@gmail.com135	\N	$2y$12$MX5iUvF4KB/Gv/R9XH.Hze77XjX/CaHKcdiqiFxVlgzKN.uf7JvIe	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
131	Benlene Llantero	dummyacc1@gmail.com144	\N	$2y$12$vdHoQkDqDy/qqTE8ga6aleu1q1lmKx2L2GUzwT6C2/qPv/ifHjCoS	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
132	Maria Eberliza Macalindong	dummyacc1@gmail.com151	\N	$2y$12$3j3Mv24wG4s5tiznlz1yCuFcKy06hViTOfPYk133HwgGdL6wg0sby	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
133	Jeffrey Magbuhos	dummyacc1@gmail.com155	\N	$2y$12$9foPNJ.q1c.ueDJIC7GiGOAn2sLSuFGhWkLjddhkH9C3ChJfKjd6q	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
134	Marithess Vianca Magsino	dummyacc1@gmail.com161	\N	$2y$12$MzBxcwWxTk94VCjnEz432ezy0O8fu3CIF62uW1uRhOP89vCl7Ky96	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
135	Darwin Manalo	dummyacc1@gmail.com171	\N	$2y$12$1frl5W7M6ifuxCrUiwa92usByX47BfgoBFjFi.g2B.y9zjA./ajH6	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
136	Pauline Andrei Marquez	dummyacc1@gmail.com180	\N	$2y$12$m4HFJHIAi1qyd8aRg2QVQ.0hmSD.gbWXSjJ6kG1Ir447eFvA5Uvbq	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
137	Gladys Matira	dummyacc1@gmail.com187	\N	$2y$12$TMHvmS3yt/3kBydpQBEULOT4p2T95mYUAgo3UW2Xz1IQOCB1JkLTi	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
138	John Eric Medina	dummyacc1@gmail.com189	\N	$2y$12$b8fFTZ0qWf08cRyhwLWUnOk7pwbv0qYLB8ru/g9fgG6yheZ51mkj2	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
139	Joseph Melo	dummyacc1@gmail.com191	\N	$2y$12$RvDTqfAUSA8DPq2S/CdLVehFfEE5PErMP63kUQqU8D7JFU3jhwwn2	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
140	Ma. Aileen Mesias	dummyacc1@gmail.com198	\N	$2y$12$7JT1TBrcMjsoy6EFEjvW4upR6y0mvehg8HaXDE9Dww0FgA3RVeU2K	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
141	Judylen Monterey	dummyacc1@gmail.com201	\N	$2y$12$GexyjBWvAQ0XLkn8FKz5EuZDyhTqErTeGHQGJ0AyutI5ex.RyD1Sm	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
142	Reymark Natividad	dummyacc1@gmail.com205	\N	$2y$12$Wtbgpv3Ryg0JtJFGTjQbhuWYCpa10fUjDu/wqL3VPzkCM3uz2qS0O	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
143	Carlo Olano	dummyacc1@gmail.com215	\N	$2y$12$zQnD01V6QFoWYgilu5/NFe7mCMCdJ11oDo9K34ssJxc1N0yWRKYJ.	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
144	Ryan Christian Panapanaan	dummyacc1@gmail.com219	\N	$2y$12$2i5msxuksadYcjPYqdA63eL6DV3inRxIrC4jLqAn4EpZj1p4vEy7G	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
145	Sarah Jane Panganiban	dummyacc1@gmail.com220	\N	$2y$12$AEaoPo2yAMq7Aps5GkeZu.QI6FjZtJC2IdMRm42XMod38Qe41e9bq	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
146	Ian Pasahol	dummyacc1@gmail.com224	\N	$2y$12$oJ1qjnKGEydPBMeKIwQ/LeQar9rvRUjYFJf6ItzYqlAeCQQwxHh9a	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
147	Yushua Ras	dummyacc1@gmail.com239	\N	$2y$12$Wsr6dLG4FmER/2homcbC4umjWx2NF8P.pG0OtZqeV1LMg74ChpLY6	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
148	Daniel Janick Razo	dummyacc1@gmail.com240	\N	$2y$12$Mj1Ole92lg6YNcef.g9s5uPXua5ihHNeWNBWagS1kgpzF0hfsfUtO	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
149	John Steve Sabido	dummyacc1@gmail.com249	\N	$2y$12$PA3VhB93M0BPWS6ofRleoOA4YUU/wWjaezf3/PKw8pQDRNT6ZODr6	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
150	Jonathan Rey Sulayao	dummyacc1@gmail.com257	\N	$2y$12$4QN9PwEIOHNC/SIA2Nfo0OQoUtioWmqKCDGo3n7zatVsgT2wQ.VMy	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
151	Rommel Tubig	dummyacc1@gmail.com269	\N	$2y$12$KwYm7meE5RvjbDFzZ/vr..BLbBhfPjY1jJxx9BnmO35EPK.HvvcSe	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
152	Jhon Rafael Franco Vergara	dummyacc1@gmail.com276	\N	$2y$12$D9.fc5GHj83DevddNKUy0usXodF7TkLN5BfEtyVCYSzhEN5JiOPXu	\N	2026-11-24 14:42:19	2026-11-24 14:42:19	3
153	Darwin Magpili	Magpili@gmail.com	\N	$2y$12$02RyWqqzNdmdNsdwjcnzI.wCN82Ih8iZ76ZZ.CtQUoW.QSJ9gF1hu	\N	2026-11-24 14:50:12	2026-11-24 14:50:12	3
154	Hannah Ericka Andal	dummyacc1@gmail.com287	\N	$2y$12$lk7RqbKAx.WUrwSmadPc.e6AFZyZJv2gllzXaA6.4FrT4twYw0V72	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
155	Rio Atienza	dummyacc1@gmail.com288	\N	$2y$12$7a1BA9RC5vm8vVT1a6EkQOjFdxxVUMaRckTb6rSi9lJ67McauW3SS	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
156	Mike Ivan Caguimbal	dummyacc1@gmail.com292	\N	$2y$12$EKyMgKAM34fxeK2EKFOJcO.HYicmI9hObMHcZzYf9dVpJSP3jL36i	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
157	Jeffrey Catibog	dummyacc1@gmail.com295	\N	$2y$12$3YFgdK/hEZYWxb7la90jv.4mfz/sMI7M.6OxBl3ODqPUynFD3PkpS	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
158	Princess Dimaano	dummyacc1@gmail.com300	\N	$2y$12$qPnAQELhT37VIVI3bEY9KOgJe.SRysuc4Wm6XVWYjRP87I5RaH7yW	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
159	Marcela Fernandez	dummyacc1@gmail.com304	\N	$2y$12$j50z5tCPFwetADa1zhZRcuEVDjVlr5ySG8i3hbVixF07CvGqthno6	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
160	Sharlene Anne Hidalgo	dummyacc1@gmail.com308	\N	$2y$12$MaXkaHDvQF7Gzi2zv77fNeVF/5KSlmypxrYkYwEaCt8PIIlqjx9Lm	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
161	Gemmaris Kasilag	dummyacc1@gmail.com309	\N	$2y$12$UbWBLJpGacUE8NZKN6kFBOwlrbqdqeJzHgYbrr3o.0FQ3UHxRNoGO	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
162	John Carlo Lacanlale	dummyacc1@gmail.com310	\N	$2y$12$0WxdGH.6Sgrwcg3cPTomfuu1x8jWQhlhxUHFfqQLEioGw0n9IJPTq	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
163	Cheriffer Laguitao	dummyacc1@gmail.com311	\N	$2y$12$u7EQdEe.FbbwCDWyWct4sOGE1IXq.5ezbIY7JtFltgrs60fyj.3TG	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
164	Rizzalina Lat	dummyacc1@gmail.com312	\N	$2y$12$n7WRmb/FRc6Ula.nTbnsKuOTvTaCfv3pkzKwz0kga/oXZ806GMoky	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
165	Kyle Francis Librea	dummyacc1@gmail.com313	\N	$2y$12$6CpkIoYi/h317yjvJ7GfU.1tmVvCnIXWkldql411iLMeigaIJEDsC	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
166	Jun Maalihan	dummyacc1@gmail.com314	\N	$2y$12$BFgvJuKqLAdQz3WHUI/rG.WySylUoUc9uQv.I97THVILlY8Kd.PqO	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
167	Princess Dian Macion	dummyacc1@gmail.com315	\N	$2y$12$ewqt3/xZdD7XmeDNdMGrUeOwrPa9U1BVuUVgd7HWA7o7SRNTlc6SS	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
168	Renan Mallari	dummyacc1@gmail.com318	\N	$2y$12$tNxkUjv2WjdpEHBSE6X8letknjdh.uUIN0pkAACwyKOOE8u96mXd2	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
169	Aeron Kriz Manalo	dummyacc1@gmail.com319	\N	$2y$12$DoPKk1z0M1mHosHmRfg0YeqCsQVJAfNtB/vZQmHpVa1CFYwpZ3xua	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
170	Angelica Manalo	dummyacc1@gmail.com320	\N	$2y$12$fRmGSBeq2129hz.PMfoxhuErdCu3jaDEqLHpK2lam96/szTHJzpOy	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
171	Cristine Maranan	dummyacc1@gmail.com321	\N	$2y$12$jtLsxe/ZPUQM23kPYTSffuZGT6I67sYE1yEv6VDNRbxkY.R.6XZ3W	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
172	Larah Aliosa Maulion	dummyacc1@gmail.com322	\N	$2y$12$xIYENvv0fWpGyuSqBVJE/e6OcAMaEB9RBMxykCmGxal.SSmHxPj7C	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
173	Chelzea Mercado	dummyacc1@gmail.com324	\N	$2y$12$booFyHnp7wm3uYIAeoQ2I.6sv/95JwMwYg/x1Au.4TG1oPWU3o03O	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
174	Marie Locelle Molate	dummyacc1@gmail.com325	\N	$2y$12$syv7YzmIl9WHONuy/FE78uAxUwhhA9YizO5k6dg9MOpr7GaBEybui	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
175	Shiela Morfi	dummyacc1@gmail.com326	\N	$2y$12$jh5bvEaJi6qTapAso4JO4u3SqkZuBRkO6grgUsCqa5qrH9L/yia8e	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
176	Jeremiah Padua	dummyacc1@gmail.com329	\N	$2y$12$aDKRWrjpz34VBBI8nnWDaujbD/3qaVUsL0e7b6.rST1PLw9jFVlGa	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
177	Jacquelyn Parangan	dummyacc1@gmail.com330	\N	$2y$12$cvxWjx55kcQeGOGIHEJX/urVRW4//5./fJyGW.WSQnIba1hNdXElC	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
178	Pia Jasmin Quizon	dummyacc1@gmail.com333	\N	$2y$12$fMvUCuEL1h1/VQjB8cXiZeNXAGzDOgBG8dn4NCvxKC1e27Mc7qNce	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
179	Alex Solomon	dummyacc1@gmail.com334	\N	$2y$12$rWSfNb1W9qpkc8JCnYyBOeVwrpxTVyHx4Wrd9mLW3vcZBzAnYJgfq	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
180	Kim Czarina Torres	dummyacc1@gmail.com335	\N	$2y$12$tMWr/NXDisWFQWjUXR0cUe4qSDJ2px5hHv4N9LL5Gt6MudC0z2T/W	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
181	Evangeline Umali	dummyacc1@gmail.com336	\N	$2y$12$8FWiuiQjVztY1/UpcD9iI.AZJin3PT80rE/s2O2j7kCZx4GNym3UW	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
182	Rica Umali	dummyacc1@gmail.com337	\N	$2y$12$bpmFiyxAmyoAwRWfx/Qf9ePk4DW6zk7XjNPME5WWhaUw6cJ8kyeMW	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
183	Zia Villena	dummyacc1@gmail.com339	\N	$2y$12$7ZF851OhIEYx97t4EDH98Org/QOfUtvXETVHVyz6FbUC6prJOfafG	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
184	Ken Andrew Vispo	dummyacc1@gmail.com340	\N	$2y$12$INpmvb8NIc7e4dO0oTgFNu77tmDgDoifuqdUPB1Oz8EyLvOaNfW/q	\N	2026-11-24 15:04:49	2026-11-24 15:04:49	3
185	Angelina Acuzar	dummyacc1@gmail.com286	\N	$2y$12$BOgxYAhWsCPmjhrHD5TwrO/gBQHvX3nWrtNXuwc0tzBdP/kN31Exm	\N	2026-11-24 15:05:51	2026-11-24 15:05:51	3
186	Regina Endaya	Endaya@gmail.com	\N	$2y$12$V9dfWxlcKRLyxaV/0nggRuCLGMlbZx6LyWioa/IUZ7FcZjZEMSG2S	\N	2026-11-24 15:13:20	2026-11-24 15:13:20	3
187	Marvin Atanacio	dummyacc1@gmail.com18	\N	$2y$12$ynRX5ksiPE4bTGUTs6lMs.eckAfVtbVKJLuUBBhWFdsKNSOMRkkNO	\N	2026-11-24 15:16:14	2026-11-24 15:16:14	3
188	Jeanne Pauline Calvez	dummyacc1@gmail.com50	\N	$2y$12$ZmNA6ykfEGQATdiQGGApeOBT3PHChX.LgcGftTv82IOtOEjTnuY/G	\N	2026-11-24 15:16:14	2026-11-24 15:16:14	3
189	Sean Kirby Dejucos	dummyacc1@gmail.com80	\N	$2y$12$hVvETGfcCi9Addm8c2t9SuUpRqOqqOyZx2OvVlexztT2P5jXT7LL.	\N	2026-11-24 15:16:14	2026-11-24 15:16:14	3
190	Kyle Irvin Dimaano	dummyacc1@gmail.com84	\N	$2y$12$FNoFmH1iYwCxP3fQUgKmueYijU7fiQm9oNCE6sX3fG7YBKlxvHiS.	\N	2026-11-24 15:16:14	2026-11-24 15:16:14	3
191	Joel Enriquez	dummyacc1@gmail.com98	\N	$2y$12$tHNQI0VJEXNV.STY2fBXfOjqCb8tyXMHJClZXLD70mvXsZGWBBwKq	\N	2026-11-24 15:16:14	2026-11-24 15:16:14	3
192	Wendell Gonzales	dummyacc1@gmail.com117	\N	$2y$12$nHM7YH0QERckYsdf.26L0ebLannejgeGkihtf2Fq216xh9aTCdSWq	\N	2026-11-24 15:16:14	2026-11-24 15:16:14	3
193	Jayson Guia	dummyacc1@gmail.com118	\N	$2y$12$eBKmRjlW50olST94GoYWF.cIb6HZcMkOZBZTPk604CSVI5x.jxNNa	\N	2026-11-24 15:16:14	2026-11-24 15:16:14	3
194	Larilyn Ilao	dummyacc1@gmail.com124	\N	$2y$12$ohXCvITLmrXYAqo/BZeTAe2mwBsRp5yq6ZX3WSA1IeR8K11b3LZOC	\N	2026-11-24 15:16:14	2026-11-24 15:16:14	3
195	Alice Lacorte	dummyacc1@gmail.com131	\N	$2y$12$bxaz/2vS7C/KPBXixpd9aeF7cjc7aiWJXIgkzEKMkKdYqCOiCbqD6	\N	2026-11-24 15:16:14	2026-11-24 15:16:14	3
196	Jojo Leonar	dummyacc1@gmail.com138	\N	$2y$12$PCsaEWyJ19Zn60oqdDNQ3eWbnQnfMimurlt9Klf.7mktJnjsN7rO.	\N	2026-11-24 15:16:14	2026-11-24 15:16:14	3
197	Emmanuel Maala	dummyacc1@gmail.com147	\N	$2y$12$F1h/L9HfWGwTj5mSIYoaE.uE5XCkyc/QOFJRLEL2g4.r8IMg9hjAm	\N	2026-11-24 15:16:14	2026-11-24 15:16:14	3
198	Roy Maranan	dummyacc1@gmail.com176	\N	$2y$12$CnNcvxJviDASRKjKsJKerexgbLHUtwlJaDCKz00DWAlTtlYoEh9HK	\N	2026-11-24 15:16:14	2026-11-24 15:16:14	3
199	Carolyn Matira	dummyacc1@gmail.com186	\N	$2y$12$oCg8SV4fJoQ.Anz9CRAx4Os92e4yBHKsFBNQjvpIEYrl2zBj5mJQS	\N	2026-11-24 15:16:14	2026-11-24 15:16:14	3
200	Archie Menisis	dummyacc1@gmail.com196	\N	$2y$12$XhXMMwdCk0aOQgAKWsA8Y.ve9mVCB78J68yJRiwhHMljuv3YtBRZ.	\N	2026-11-24 15:16:14	2026-11-24 15:16:14	3
201	Jei Pastrana	dummyacc1@gmail.com225	\N	$2y$12$KWlMGmi/S5lfM7X.pa713u01LkJTJq8DaAqM1OhHR4fc5ObUv.D52	\N	2026-11-24 15:16:14	2026-11-24 15:16:14	3
202	Stephenn Rabano	dummyacc1@gmail.com236	\N	$2y$12$3Lsj74AKVrlTCZYXKH.XEuhejB0ZvNbo2UyyFqZ3RtydRbFQdv.tO	\N	2026-11-24 15:16:14	2026-11-24 15:16:14	3
203	Neres Ann Repollo	dummyacc1@gmail.com242	\N	$2y$12$dtyb02MUKTMBqL1Upip03eEuEMBHHQWQesOllD35/X98yf98wVqUi	\N	2026-11-24 15:16:14	2026-11-24 15:16:14	3
204	Darwin Tiquio	dummyacc1@gmail.com264	\N	$2y$12$mDJF1STlygluc7sviwonTe/VEioBS2dzkbLa2qTulmkHiBZ8Pwg5.	\N	2026-11-24 15:16:14	2026-11-24 15:16:14	3
205	Allen Paul Alcantara	dummyacc1@gmail.com4	\N	$2y$12$Hegm05kM071ig1zQjhgjMed64kFD3VG2r2kY5ElDB0g8J.KW9pagm	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
206	Alyssa Pearl Alon-Alon	dummyacc1@gmail.com8	\N	$2y$12$c/bhJI/PP3vzdg3yTy52ve/FiWNWEAx2yOJAt0Jh8PnR1A1Vv9k0m	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
207	Rylgem Arcega	dummyacc1@gmail.com16	\N	$2y$12$KWXK7Jmz0MLx.8YUPL0mKerF2uurwDNlFdALfyRiswHRaovuorij2	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
208	Pola Bianca Donia Balmaceda	dummyacc1@gmail.com23	\N	$2y$12$sCJxk9Uy4.YWV8aVpYET1udhNYe/H7j1/8CkfkL8Sliy3YR7RJGYe	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
209	Deanmarc Patrick Baluyot	dummyacc1@gmail.com25	\N	$2y$12$.q15LQasOv8ADsUaI5jrye8GfFzvg61YfzmxSepMBVHeE.u0xxS5W	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
210	Michael Baylon	dummyacc1@gmail.com29	\N	$2y$12$RDlJRFwIac57IAKU/gj86ep1Ii5OPFjtrASCL4TeZA9Pqt3beBNjy	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
211	Aira Denessa Bulanhagui	dummyacc1@gmail.com45	\N	$2y$12$6z74llWjU12tinmXvgxd7uvz2AM0wXhivtWq648X0k4XHeQyacHL.	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
212	Junel Buyagon	dummyacc1@gmail.com46	\N	$2y$12$IcN/d4ruJnMhK2vxOAKt4.XoNNS07Gm4dFgBLaKDndf.XaK72X6G2	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
213	Angeline Cas	dummyacc1@gmail.com52	\N	$2y$12$KTIwem2123rNc1iYC6KzpuKd/f5JmOn7cY2esV6bwMtllGFcDNMte	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
214	Aldwin Cueto	dummyacc1@gmail.com67	\N	$2y$12$y1Upi/3SMcVLODPBBcJbhuWC2NoN1DDgUpdJdN2ZdUZkmkQHB47Ay	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
215	Jun Orlyn De Castro	dummyacc1@gmail.com74	\N	$2y$12$IXT1bVLAlVLQvcVz94m97Ob6vVscsfqz0QQBjwNJAIqgIEGPguXH2	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
216	Ariel Dela Cruz	dummyacc1@gmail.com81	\N	$2y$12$pduvwVopMMFXUffzOWNxP.osWoIpoJLi0fh2Yi2TTW6SWboD89D3S	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
217	Monica Dela Luna	dummyacc1@gmail.com83	\N	$2y$12$xL5816f8CYpLfE7hiwGo7uVzy3YX3MXDaOZWbQtaOyBMFHMcjkksK	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
218	Rainiel Vinzon Maala	dummyacc1@gmail.com148	\N	$2y$12$5LivT1TOmkBkyUb.S4r2WOzQPagX.aSLTT9hd0Duj9B9yypRPoCWK	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
219	Cyril Malaga	dummyacc1@gmail.com166	\N	$2y$12$bDP./2vttWaoYpHulnh4A.2hgWkZhe5LoCzkTWkShat0yi8wmvTda	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
220	Mariel Maralit	dummyacc1@gmail.com174	\N	$2y$12$6gzezszjKJgtM1BA1xyKtuDaJ72x.bTLfluNhjN8EQRmTizoAib5m	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
221	Judy Ann Marasigan	dummyacc1@gmail.com178	\N	$2y$12$VhBYSvaera49MjmiwTJYLOOiLJfKVa1GkgdgfSmmNWA64aBtUyciy	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
222	Myron Alvin Matanguihan	dummyacc1@gmail.com184	\N	$2y$12$gfmQXemQdonC1kTrZglCG.dlMxL0bwlNKCgOLI9pYS42Mmhcp840G	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
223	Ken Mendigorin	dummyacc1@gmail.com192	\N	$2y$12$v8UYIQ3.b8Tbaho.3UkYnuV0xmZCBbR2f/0O9xmir2OCdgjI53NPq	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
224	Morris Angelo Nieva	dummyacc1@gmail.com207	\N	$2y$12$C6vfL/vBBXhlKTMU/JWfm.a4zKt/IrnzqqKEN42ZUHjGJr9Hp4phu	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
225	Digna Nocum	dummyacc1@gmail.com210	\N	$2y$12$1syjlCkl7fHKKNo4Mfu4VOB7q9ZxFKrz3GuglC2wIZmplfdi2YkOe	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
226	Michael Ramilo	dummyacc1@gmail.com237	\N	$2y$12$N1AFHELFAlCeS0.vkzMTx.ct2Zz7n41XUVOb05m4ZAixrgOSF8usm	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
227	Allainer Reyes	dummyacc1@gmail.com243	\N	$2y$12$6gAw7FaeTAwGNNt7TBf7cOKlZ4pYx5ZdbupyMvb9ikIXQ0uGCtr.m	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
228	Andres Carlo Roxas	dummyacc1@gmail.com248	\N	$2y$12$xmlMD1FfMhZVMPIslnM80OL8Yr.Opu9OA5YFx4NPHH/qM5SMrNs2y	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
229	Augusto Jr. Sison	dummyacc1@gmail.com254	\N	$2y$12$SGBKVmxWgUELxIV/1MTnp.oS7qa5972GgIi.gtBL.5bwMYGF3Vhhm	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
230	Ronwaldo Tito, Ronwaldo	dummyacc1@gmail.com265	\N	$2y$12$6s5tKRkKBovp0po845359.d4Ei1l4JGzHW4BzM.h2WmeuN5dlI3sW	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
231	Ian Carlo Umali	dummyacc1@gmail.com271	\N	$2y$12$Ogt4ibnMT7Ur2LrkAlkHAOajXMxzvOZaxruwz5cGqfS5sZkGvomU.	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
232	Vladimir Viray	dummyacc1@gmail.com283	\N	$2y$12$XXFStBwqnXRhqyd0xO9WUO5R0axJzqrZYB5RnULFR90cJo3r.csS2	\N	2026-11-24 15:20:36	2026-11-24 15:20:36	3
233	Francis Jay Enriquez	Enriquez@gmail.com	\N	$2y$12$.Sz1gpqsGiYL1czkDfTRz.5roFa2vPGxpfesZKJapNcGqo4XN1BVq	\N	2026-11-24 15:22:20	2026-11-24 15:22:20	3
234	Carlos Caesar Caday	Caday@gmail.com	\N	$2y$12$bWotb95Xbx4sYZx6.SK.IORLLPJUtSEAw490T0oW4qyOQF.pad27.	\N	2026-11-24 15:23:43	2026-11-24 15:23:43	3
235	Michael Joseph Aramil	aramil67@gmail.com	\N	$2y$12$057aWlB2.y6BLSsm40wVK.smjZi0kTK0RE5JkNmSMoOAQeG2ypCla	\N	2026-11-24 15:23:44	2026-11-24 15:23:44	3
236	Irene Balmes	balmes@gmail.com	\N	$2y$12$AFqqSrvMRMjL0mHbcu/4f.mRiVBOpHPdM4eUF3u1AXL9Ut9yBgOtu	\N	2026-11-24 15:26:56	2026-11-24 15:26:56	3
237	Noli Castro	noli123@gmail.com	\N	$2y$12$6eaHxZU8uTXZ3fgpymOhZe3SrhqI6DxYGhmkQXoNr/5QvoiEeBy3q	\N	2026-11-24 15:28:23	2026-11-24 15:28:23	3
238	Jayson Malabanan	Malabanan@gmail.com	\N	$2y$12$elL4giGEWvHcz2A.qc1jb.C0jS4nYJKLMlUYMoLICmpN11IPK83VS	\N	2026-11-24 15:29:47	2026-11-24 15:29:47	3
239	Erwin De Castro	jpk@gmail.com	\N	$2y$12$Kx8ADkT3H6IDOVjr.XwOE.vVZ8JMFmodthTH5Bg7XasCAog7TjmVS	\N	2026-11-24 15:29:57	2026-11-24 15:29:57	3
240	Nathaniel Nino Magpantay	nmp123@gmaiol.com	\N	$2y$12$uIr8ugnZZpK5T1ppdenGOOzgSG5lH3jr7UbIM4hKCEhdA7xxNfXW2	\N	2026-11-24 15:31:15	2026-11-24 15:31:15	3
241	John Carlo Torres	carlo098@gmail.com	\N	$2y$12$9B.7Gl0m1zBAv1G34erysuRXTuTvkBFKhe9su7ZZchucEc/9ECvne	\N	2026-11-24 15:33:28	2026-11-24 15:33:28	3
242	Jennie Margaret Apritado	dummyacc1@gmail.com14	\N	$2y$12$AGUEFa2v1A1x2.R1knJx5.hmY.0pWtHPgjLGW6bI6sU4Y3B.QrbZW	\N	2026-11-25 14:08:53	2026-11-25 14:08:53	3
243	Lawrence Zyril Lizardo	dummyacc1@gmail.com143	\N	$2y$12$fL.MDqyb6Hqke4bArXrheetNVwBHFmeWVTBhD5ciDOJpYs2H.trYK	\N	2026-11-25 14:08:53	2026-11-25 14:08:53	3
244	Jan Michael Maglinao	dummyacc1@gmail.com156	\N	$2y$12$Yehd/9vDb7Gs62OC6k/ahONamjmX/Xd8wGlF3bv4x9NyhWYyc19B.	\N	2026-11-25 14:08:53	2026-11-25 14:08:53	3
245	Francis Mateos	dummyacc1@gmail.com185	\N	$2y$12$CpMznaEUQ4jOKRnVsLzMsORdT6wsKWvByk2v6lOybCzVzB7uwR4cW	\N	2026-11-25 14:08:53	2026-11-25 14:08:53	3
246	Kimberly Camille Mendoza	dummyacc1@gmail.com194	\N	$2y$12$lGGJjK8bQTG87l9hHnFrPO0V0gKVLufBtNtDD.50OWnqec997pcn2	\N	2026-11-25 14:08:53	2026-11-25 14:08:53	3
247	Rosario Polintang	dummyacc1@gmail.com230	\N	$2y$12$dZ6kreSJDjmc8lFUjU.iqu7jRACl9LRJosE4JfVRLdNYFYFh1mRGi	\N	2026-11-25 14:08:53	2026-11-25 14:08:53	3
248	Vernis Ventilacion-Monteza	dummyacc1@gmail.com274	\N	$2y$12$F2CLSsM33cT7Jp7jmfdnCeU5RrwomJetZshti7d5Yg12l2tRyPfQC	\N	2026-11-25 14:08:53	2026-11-25 14:08:53	3
249	Charlene Villegas	dummyacc1@gmail.com280	\N	$2y$12$m8K7G4AD2Dz2AMY0CjLYm.46opJk0cTxHEzCF6rT4mGWz7vMUnGdu	\N	2026-11-25 14:08:53	2026-11-25 14:08:53	3
250	Jhyn Concordia	dummyacc1@gmail.com65	\N	$2y$12$tENGl1HjrB2zfcBg9Xg9xeQseneY4LPtGN7tqq0tCmgGlo3Xngx7i	\N	2026-11-25 14:10:18	2026-11-25 14:10:18	3
251	Alena Ocampo	dummyacc1@gmail.com213	\N	$2y$12$pM.g90uBBJ2haTpBOz.1FOm7G0p5lQuJ14pzIxyeD6b3VpeciVQvi	\N	2026-11-25 14:10:18	2026-11-25 14:10:18	3
252	Arriane Joy Añonuevo	dummyacc1@gmail.com13	\N	$2y$12$WA3gHxLZiBq1Kwc5EjDP3O2uLPT2pFRnAX5JEzROFjvPjzASXOU5O	\N	2026-11-25 14:13:24	2026-11-25 14:13:24	3
253	DJ Grace De Guzman	dummyacc1@gmail.com77	\N	$2y$12$VZ/dclogT4AXyI05O5ZvQOTqAPpudeNZk1hFj5YVcLQ5C25KUR6w6	\N	2026-11-25 14:13:24	2026-11-25 14:13:24	3
254	Genely Dimayuga	dummyacc1@gmail.com89	\N	$2y$12$jTNZMxUR8HxduUjpYlx69.Gr8dFZ8oqESIQdnWlEtcZ1RgtpH62vG	\N	2026-11-25 14:13:24	2026-11-25 14:13:24	3
255	Jerico Fernandez	dummyacc1@gmail.com103	\N	$2y$12$wiLHT52/xFtH5wRjyXlpMuKqWGCRao/FbLS2Npirn9dob/Omo.Ozu	\N	2026-11-25 14:13:24	2026-11-25 14:13:24	3
256	Edmerson Geronimo	dummyacc1@gmail.com115	\N	$2y$12$xXoSh1v13eCDOFblUqo74uwiEwrPQpxB5oZQ1.lyNHjZUAGaWpYnC	\N	2026-11-25 14:13:24	2026-11-25 14:13:24	3
257	Sarah Jane Layas	dummyacc1@gmail.com137	\N	$2y$12$WsG4LrhyeMe0n3ALvSYlPuG84gj3zOgFeHFB1CxV7BzQyw6UJaXnG	\N	2026-11-25 14:13:24	2026-11-25 14:13:24	3
258	John Lorenz Macalinao	dummyacc1@gmail.com150	\N	$2y$12$iAckUyab0xr2gpVsGBADXuVQ4qWYlxK55KmslrFF8Nh9oH6B.VywG	\N	2026-11-25 14:13:24	2026-11-25 14:13:24	3
259	Nabil Marquez	dummyacc1@gmail.com179	\N	$2y$12$46Xk2Dkp7BLJBkGLLC8XAe98zLQ0kxZnRCz2aM6..yMMmKlTcafqi	\N	2026-11-25 14:13:24	2026-11-25 14:13:24	3
260	Aron Masangkay	dummyacc1@gmail.com182	\N	$2y$12$GF/cYd6q1UXA6TQ1QmYQPuUObCSsnNEZX0F.n3YgWFhbhgzv.du8i	\N	2026-11-25 14:13:24	2026-11-25 14:13:24	3
261	Diether Paz	dummyacc1@gmail.com226	\N	$2y$12$Dz8U.4I/lquwqEF9tWNkbu5cHVM5dwfp.Ko2.I0ZkknQW83mQWP.6	\N	2026-11-25 14:13:24	2026-11-25 14:13:24	3
262	Nina Rica Pesigan	dummyacc1@gmail.com229	\N	$2y$12$NKlHAQG5AZ8jIAslbJLHqOHdPes1Q/UQRltdWSEi/UEZOaTi8vmdW	\N	2026-11-25 14:13:24	2026-11-25 14:13:24	3
263	Princess Pricas	dummyacc1@gmail.com232	\N	$2y$12$2ELsE4Kxo3G72wPuhzvu/u1F3RCJz4DiH0zyQEZUd44pTaniKX/HC	\N	2026-11-25 14:13:24	2026-11-25 14:13:24	3
264	Joseph Sangalang	dummyacc1@gmail.com250	\N	$2y$12$yPXad0gcbx6Dh9MeOaNna.A/OrB0agUrCIQFdq.lfQvsKfTCCxJHS	\N	2026-11-25 14:13:24	2026-11-25 14:13:24	3
265	Patrick Villamayor	dummyacc1@gmail.com278	\N	$2y$12$6M57hwyOM9BjPSwy19peceoOLdm3/lPGKC4OvKNnZPe1lDHsMaRhe	\N	2026-11-25 14:13:24	2026-11-25 14:13:24	3
266	Kyle Zyrene Bolaños	dummyacc1@gmail.com38	\N	$2y$12$GT3iLfJwe9iX1mzb8qDBTexCZJu.37pQEeP2L75mNkg8uqivMh8c6	\N	2026-11-25 14:15:30	2026-11-25 14:15:30	3
267	Ace Miguel Bravo	dummyacc1@gmail.com40	\N	$2y$12$NuU9UrtLX5JcyQ5wvhbQ3.Wogx2wPtT1KORHpIYC/y/DYRy.Ekqtu	\N	2026-11-25 14:15:30	2026-11-25 14:15:30	3
268	Ma. Karena Celestino	dummyacc1@gmail.com63	\N	$2y$12$JdRj.s17wjHIWF1ToCOm2uu2KlJctX0x9jysC.mF9L3wjvxXt716G	\N	2026-11-25 14:15:30	2026-11-25 14:15:30	3
269	Arianne Cruz	dummyacc1@gmail.com66	\N	$2y$12$PFn8s5AcxhZW8SWXiEIGleP8nc9bjRo0nARTXLjXY2rFcpcgzg7eK	\N	2026-11-25 14:15:30	2026-11-25 14:15:30	3
270	Joshua Magtibay	dummyacc1@gmail.com163	\N	$2y$12$L.E4Gk06rykx43IV4YEKy.ozWpOylKkUzJmOTSmpexmCUo67gkmkG	\N	2026-11-25 14:15:30	2026-11-25 14:15:30	3
\.


--
-- Data for Name: wfh_monitoring_submissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.wfh_monitoring_submissions (id, employee_id, submitted_by, reviewed_by, wfh_date, time_in, time_out, file_path, original_filename, status, submitted_at, reviewed_at, review_notes, created_at, updated_at, monitoring_link) FROM stdin;
\.


--
-- Data for Name: messages_2026_10_11; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.messages_2026_10_11 (topic, extension, payload, event, private, updated_at, inserted_at, id, binary_payload, skip_broadcast, expires_at) FROM stdin;
\.


--
-- Data for Name: messages_2026_10_12; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.messages_2026_10_12 (topic, extension, payload, event, private, updated_at, inserted_at, id, binary_payload, skip_broadcast, expires_at) FROM stdin;
\.


--
-- Data for Name: messages_2026_10_13; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.messages_2026_10_13 (topic, extension, payload, event, private, updated_at, inserted_at, id, binary_payload, skip_broadcast, expires_at) FROM stdin;
\.


--
-- Data for Name: messages_2026_10_14; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.messages_2026_10_14 (topic, extension, payload, event, private, updated_at, inserted_at, id, binary_payload, skip_broadcast, expires_at) FROM stdin;
\.


--
-- Data for Name: messages_2026_10_15; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.messages_2026_10_15 (topic, extension, payload, event, private, updated_at, inserted_at, id, binary_payload, skip_broadcast, expires_at) FROM stdin;
\.


--
-- Data for Name: messages_2026_10_16; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.messages_2026_10_16 (topic, extension, payload, event, private, updated_at, inserted_at, id, binary_payload, skip_broadcast, expires_at) FROM stdin;
\.


--
-- Data for Name: messages_2026_10_17; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.messages_2026_10_17 (topic, extension, payload, event, private, updated_at, inserted_at, id, binary_payload, skip_broadcast, expires_at) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2026-03-31 08:43:06
20211116045059	2026-03-31 08:43:07
20211116050929	2026-03-31 09:37:49
20211116051442	2026-03-31 09:37:49
20211116212300	2026-03-31 09:37:50
20211116213355	2026-03-31 09:37:51
20211116213934	2026-03-31 09:37:52
20211116214523	2026-03-31 09:37:53
20211122062447	2026-03-31 09:37:53
20211124070109	2026-03-31 09:37:54
20211202204204	2026-03-31 09:37:55
20211202204605	2026-03-31 09:37:56
20211210212804	2026-03-31 09:37:58
20211228014915	2026-03-31 09:37:59
20220107221237	2026-03-31 09:37:59
20220228202821	2026-03-31 09:38:00
20220312004840	2026-03-31 09:38:01
20220603231003	2026-03-31 09:38:02
20220603232444	2026-03-31 09:38:02
20220615214548	2026-03-31 09:38:03
20220712093339	2026-03-31 09:38:04
20220908172859	2026-03-31 09:38:05
20220916233421	2026-03-31 09:38:05
20230119133233	2026-03-31 09:38:06
20230128025114	2026-03-31 09:38:07
20230128025212	2026-03-31 09:38:08
20230227211149	2026-03-31 09:38:08
20230228184745	2026-03-31 09:38:09
20230308225145	2026-03-31 09:38:10
20230328144023	2026-03-31 09:38:10
20231018144023	2026-03-31 09:38:11
20231204144023	2026-03-31 09:38:12
20231204144024	2026-03-31 09:38:13
20231204144025	2026-03-31 09:38:14
20240108234812	2026-03-31 09:38:14
20240109165339	2026-03-31 09:38:15
20240227174441	2026-03-31 09:38:16
20240311171622	2026-03-31 09:38:17
20240321100241	2026-03-31 09:38:19
20240401105812	2026-03-31 09:38:21
20240418121054	2026-03-31 09:38:22
20240523004032	2026-03-31 09:38:24
20240618124746	2026-03-31 09:38:25
20240801235015	2026-03-31 09:38:26
20240805133720	2026-03-31 09:38:26
20240827160934	2026-03-31 09:38:27
20240919163303	2026-03-31 09:38:28
20240919163305	2026-03-31 09:38:29
20241019105805	2026-03-31 09:38:29
20241030150047	2026-03-31 09:38:33
20241108114728	2026-03-31 09:38:34
20241121104152	2026-03-31 09:38:35
20241130184212	2026-03-31 09:38:36
20241220035512	2026-03-31 09:38:37
20241220123912	2026-03-31 09:38:37
20241224161212	2026-03-31 09:38:38
20250107150512	2026-03-31 09:38:39
20250110162412	2026-03-31 09:38:40
20250123174212	2026-03-31 09:38:40
20250128220012	2026-03-31 09:38:41
20250506224012	2026-03-31 09:38:42
20250523164012	2026-03-31 09:38:42
20250714121412	2026-03-31 09:38:43
20250905041441	2026-03-31 09:38:44
20251103001201	2026-03-31 09:38:45
20251120212548	2026-03-31 09:38:46
20251120215549	2026-03-31 09:38:47
20260218120000	2026-03-31 09:38:47
20260326120000	2026-04-11 20:16:36
20260514120000	2026-07-30 10:58:47
20260527120000	2026-07-30 10:58:49
20260528120000	2026-07-30 10:58:50
20260603120000	2026-07-30 10:58:51
20260605120000	2026-07-30 10:58:52
20260606110000	2026-07-30 10:58:53
20260616120000	2026-07-30 10:58:55
20260624120000	2026-07-30 10:58:57
20260626120000	2026-07-30 10:59:00
20260706120000	2026-07-30 10:59:01
20260707120000	2026-07-30 10:59:05
20260709120000	2026-07-30 10:59:06
20260714120000	2026-09-05 14:54:22
20260827120000	2026-09-21 08:11:44
20260914120000	2026-09-27 15:09:40
20260916120000	2026-09-27 15:09:41
20260922120000	2026-09-27 15:09:42
20260925120000	2026-10-05 08:20:53
20260928120000	2026-10-05 08:20:54
20261002120000	2026-10-09 09:49:53
20261007120000	2026-11-26 02:39:49
20261008120000	2026-11-26 02:39:49
20261009120000	2026-11-26 02:39:50
20261022120000	2026-11-26 02:39:51
20261027120000	2026-11-26 02:39:53
20261029120000	2026-11-26 02:39:53
20261103130000	2026-11-26 02:39:54
20261111120000	2026-11-26 02:39:55
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at, action_filter, selected_columns) FROM stdin;
\.


--
-- Data for Name: bucket_lifecycle_states; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.bucket_lifecycle_states (bucket_id, generation, next_run_at, claim_id, claim_until, continuation, last_started_at, last_completed_at, last_success_at, last_result, failure_count, last_error, updated_at) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id, type, versioning_status, lifecycle_configuration, lifecycle_configuration_generation) FROM stdin;
credentials	credentials	\N	2026-04-20 01:49:24.130868+00	2026-04-20 01:49:24.130868+00	f	f	\N	\N	\N	STANDARD	DISABLED	\N	\N
\.


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets_analytics (name, type, format, created_at, updated_at, id, deleted_at) FROM stdin;
\.


--
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets_vectors (id, type, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: lifecycle_abandoned_artifacts; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.lifecycle_abandoned_artifacts (bucket_id, key, name, version, attempted_at) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2026-03-31 08:43:05.433495
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2026-03-31 08:43:05.47829
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2026-03-31 08:43:05.58814
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2026-03-31 08:43:06.156624
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2026-03-31 08:43:06.165195
6	change-column-name-in-get-size	ded78e2f1b5d7e616117897e6443a925965b30d2	2026-03-31 08:43:06.1758
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2026-03-31 08:43:06.184476
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2026-03-31 08:43:06.191303
9	fix-search-function	af597a1b590c70519b464a4ab3be54490712796b	2026-03-31 08:43:06.19832
10	search-files-search-function	b595f05e92f7e91211af1bbfe9c6a13bb3391e16	2026-03-31 08:43:06.207106
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2026-03-31 08:43:06.21439
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2026-03-31 08:43:06.2229
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2026-03-31 08:43:06.232356
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2026-03-31 08:43:06.241487
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2026-03-31 08:43:06.354578
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2026-03-31 08:43:06.364358
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2026-03-31 08:43:06.371202
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2026-03-31 08:43:06.377907
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2026-03-31 08:43:06.465992
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2026-03-31 08:43:06.473475
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2026-03-31 08:43:06.483808
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2026-03-31 08:43:06.568143
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2026-03-31 08:43:06.600971
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2026-03-31 08:43:06.60849
25	custom-metadata	d974c6057c3db1c1f847afa0e291e6165693b990	2026-03-31 08:43:06.616198
26	objects-prefixes	215cabcb7f78121892a5a2037a09fedf9a1ae322	2026-03-31 08:43:06.623406
27	search-v2	859ba38092ac96eb3964d83bf53ccc0b141663a6	2026-03-31 08:43:06.629904
28	object-bucket-name-sorting	c73a2b5b5d4041e39705814fd3a1b95502d38ce4	2026-03-31 08:43:06.636401
29	create-prefixes	ad2c1207f76703d11a9f9007f821620017a66c21	2026-03-31 08:43:06.642918
30	update-object-levels	2be814ff05c8252fdfdc7cfb4b7f5c7e17f0bed6	2026-03-31 08:43:06.649384
31	objects-level-index	b40367c14c3440ec75f19bbce2d71e914ddd3da0	2026-03-31 08:43:06.655998
32	backward-compatible-index-on-objects	e0c37182b0f7aee3efd823298fb3c76f1042c0f7	2026-03-31 08:43:06.662721
33	backward-compatible-index-on-prefixes	b480e99ed951e0900f033ec4eb34b5bdcb4e3d49	2026-03-31 08:43:06.66947
34	optimize-search-function-v1	ca80a3dc7bfef894df17108785ce29a7fc8ee456	2026-03-31 08:43:06.675954
35	add-insert-trigger-prefixes	458fe0ffd07ec53f5e3ce9df51bfdf4861929ccc	2026-03-31 08:43:06.682483
36	optimise-existing-functions	6ae5fca6af5c55abe95369cd4f93985d1814ca8f	2026-03-31 08:43:06.693199
37	add-bucket-name-length-trigger	3944135b4e3e8b22d6d4cbb568fe3b0b51df15c1	2026-03-31 08:43:06.699667
38	iceberg-catalog-flag-on-buckets	02716b81ceec9705aed84aa1501657095b32e5c5	2026-03-31 08:43:06.711618
39	add-search-v2-sort-support	6706c5f2928846abee18461279799ad12b279b78	2026-03-31 08:43:06.729129
40	fix-prefix-race-conditions-optimized	7ad69982ae2d372b21f48fc4829ae9752c518f6b	2026-03-31 08:43:06.735581
41	add-object-level-update-trigger	07fcf1a22165849b7a029deed059ffcde08d1ae0	2026-03-31 08:43:06.742062
42	rollback-prefix-triggers	771479077764adc09e2ea2043eb627503c034cd4	2026-03-31 08:43:06.749104
43	fix-object-level	84b35d6caca9d937478ad8a797491f38b8c2979f	2026-03-31 08:43:06.755504
44	vector-bucket-type	99c20c0ffd52bb1ff1f32fb992f3b351e3ef8fb3	2026-03-31 08:43:06.761794
45	vector-buckets	049e27196d77a7cb76497a85afae669d8b230953	2026-03-31 08:43:07.071409
46	buckets-objects-grants	fedeb96d60fefd8e02ab3ded9fbde05632f84aed	2026-03-31 08:43:07.092929
47	iceberg-table-metadata	649df56855c24d8b36dd4cc1aeb8251aa9ad42c2	2026-03-31 08:43:07.100183
48	iceberg-catalog-ids	e0e8b460c609b9999ccd0df9ad14294613eed939	2026-03-31 08:43:07.111995
49	buckets-objects-grants-postgres	072b1195d0d5a2f888af6b2302a1938dd94b8b3d	2026-03-31 08:43:07.25113
50	search-v2-optimised	6323ac4f850aa14e7387eb32102869578b5bd478	2026-03-31 08:43:07.259031
51	index-backward-compatible-search	2ee395d433f76e38bcd3856debaf6e0e5b674011	2026-03-31 08:43:23.53701
52	drop-not-used-indexes-and-functions	5cc44c8696749ac11dd0dc37f2a3802075f3a171	2026-03-31 08:43:23.538934
53	drop-index-lower-name	d0cb18777d9e2a98ebe0bc5cc7a42e57ebe41854	2026-03-31 08:43:23.551291
54	drop-index-object-level	6289e048b1472da17c31a7eba1ded625a6457e67	2026-03-31 08:43:23.554036
55	prevent-direct-deletes	262a4798d5e0f2e7c8970232e03ce8be695d5819	2026-03-31 08:43:23.555334
57	s3-multipart-uploads-metadata	f127886e00d1b374fadbc7c6b31e09336aad5287	2026-04-11 15:48:20.88515
58	operation-ergonomics	00ca5d483b3fe0d522133d9002ccc5df98365120	2026-04-11 15:48:20.90501
56	fix-optimized-search-function	b823ed1e418101032fa01374edc9a436e54e3ed4	2026-03-31 08:43:23.573071
59	drop-unused-functions	38456f13e39691c2bbb4b5151d0d1cdbabd4a8c4	2026-05-14 05:21:16.353068
60	optimize-existing-functions-again	db35e1c91a9201e59f4fef8d972c2f277d68b157	2026-05-14 05:21:16.390527
61	mark-filename-immutable	fe0096517ae9d60aaec1d110172ba9036dc66bb7	2026-08-13 11:54:45.283206
63	fix-search-name-relative-to-prefix	c7485e417624f795ce8bb2da21927f48e088904d	2026-08-23 09:28:46.001524
64	fix-search-by-timestamp-sqli	0af424ecd388a39bb1645184b222185a12149675	2026-08-23 09:28:46.040771
66	objects-current-version-index	191466c93aa2c46a00e36505577c5fcab8d7cb4b	2026-09-08 10:25:59.853525
67	objects-null-version-index	15bfe8c35b66642b6c78ba60060fa8793bd2207a	2026-09-08 10:25:59.866687
65	objects-key-version-index	da319c4b89ba800ce795d1b699f3a70675138058	2026-09-08 10:25:59.831467
68	bucket-lifecycle-configuration	3c08f6f889922f399519722a932b51007c11bebc	2026-09-24 03:24:55.210713
69	validate-bucket-lifecycle-constraints	4febacaaaa0e61e2b783bef081fe03a287e65eb3	2026-09-24 03:24:55.323773
70	list-objects-with-versions	5c17c3777616cd8d7b18b82835525fa3205af57b	2026-09-24 03:24:55.342213
71	objects-delete-marker-index	6d14858e66c66f8d6accf8a2630aefd1527fddba	2026-09-24 03:24:55.514788
2	storage-schema	cdc19a79b298ce37cc730487821a1a7b06b98105	2026-03-31 08:43:05.496146
62	object-versioning-core	c6567e688f8c4a76887e7c1b117b2d58f4feccba	2026-08-20 06:46:49.703643
72	drop-bucketid-objname-index	302beb09e1b469d7d4db19566f2389d280b64aa3	2026-09-24 03:24:55.669657
73	revoke-grants-to-unused-operations	ba9244051be09f22f714fc0170a2539f8b5f0e68	2026-10-14 04:19:55.684362
74	unlock-object-versioning	dacb58ecb37678de855505b3e1c5aec0d5df7894	2026-11-02 14:20:13.209975
75	enforce-bucket-lifecycle-update-role	8454a556116c985db857d3b99de94a31a68ad273	2026-11-06 18:32:44.819045
76	noncurrent-lifecycle	052cbe11956fd14b85861fc19537c0303b73010e	2026-11-06 18:32:44.85681
77	noncurrent-lifecycle-archived-order-index	d68b03438a987aa1324a0fca68f7078cb2ffb849	2026-11-06 18:32:45.058766
78	noncurrent-lifecycle-archived-due-index	c82ba0e577ec5c3496b1077ff385ce4645497698	2026-11-06 18:32:45.074017
79	lifecycle-writer-coordination	3b38458424d2099e6b2e3cb4233590060f527fe1	2026-11-06 18:32:45.077261
80	revoke-extra-lifecycle-postgres-grants	18cfbf5c5b356469e1e95f3aa1b59ba111d82a06	2026-11-15 17:43:22.724407
81	s3-multipart-uploads-parts-index	ffc7c8ec576435de8231e5d2f5b3f76679fde502	2026-11-26 02:39:53.26277
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata, archived_at, is_delete_marker, is_versioned) FROM stdin;
866a0e83-de55-49bd-8f1e-33a483d0492c	credentials	employee-10/1776650397_2178fffc.pdf	\N	2026-04-20 02:00:00.201271+00	2026-04-20 02:00:00.201271+00	2026-04-20 02:00:00.201271+00	{"eTag": "\\"44715b2c10b3c912e236be71b77718be\\"", "size": 1279607, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-04-20T02:00:01.000Z", "contentLength": 1279607, "httpStatusCode": 200}	ed893837-002c-4a92-80c0-475aedd92c31	\N	{}	\N	f	f
3c881a49-fc7e-45c5-a294-99bc60dd3287	credentials	employee-32/1776903760_e41d8120.pdf	\N	2026-04-23 00:22:41.717609+00	2026-04-23 00:22:41.717609+00	2026-04-23 00:22:41.717609+00	{"eTag": "\\"81b1037d2f3d19e01b60e5733ed6fbbb\\"", "size": 781779, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-04-23T00:22:42.000Z", "contentLength": 781779, "httpStatusCode": 200}	f8d528a2-3155-4f6f-b91f-e3052af10a62	\N	{}	\N	f	f
9f6ca4c2-0830-4d28-8feb-5b7066e3788f	credentials	employee-10/1776906779_2ce51a5f.pdf	\N	2026-04-23 01:13:00.708316+00	2026-04-23 01:13:00.708316+00	2026-04-23 01:13:00.708316+00	{"eTag": "\\"81b1037d2f3d19e01b60e5733ed6fbbb\\"", "size": 781779, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-04-23T01:13:01.000Z", "contentLength": 781779, "httpStatusCode": 200}	4fe7966c-513d-40c4-96d3-f872cc41c656	\N	{}	\N	f	f
5eab3b02-4109-42bc-bb21-5a361f3fe170	credentials	employee-54/wfh-monitoring/1777799408_385fa3fa.pdf	\N	2026-05-03 09:10:09.451415+00	2026-05-03 09:10:09.451415+00	2026-05-03 09:10:09.451415+00	{"eTag": "\\"4966b73eea0b29317f536faa30b4f303\\"", "size": 42707, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-05-03T09:10:10.000Z", "contentLength": 42707, "httpStatusCode": 200}	a2ce1338-c932-41ad-ac87-f7811e381b7d	\N	{}	\N	f	f
dbb9a040-e545-46b8-b741-1e04e920d3df	credentials	employee-39/1777094016_40dd68fd.pdf	\N	2026-04-25 05:13:37.964816+00	2026-04-25 05:13:37.964816+00	2026-04-25 05:13:37.964816+00	{"eTag": "\\"66c2fedfeffa170d5aca2c0d834a8678\\"", "size": 1279649, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-04-25T05:13:38.000Z", "contentLength": 1279649, "httpStatusCode": 200}	408242e0-7e99-4f51-bc43-1315d8eac6e1	\N	{}	\N	f	f
0de15416-21e7-45ab-bca8-1b391995c41c	credentials	employee-32/1777279454112_pdf-sample_0.pdf	50533191-7bde-469f-9142-25844023ffdd	2026-04-27 08:44:14.602656+00	2026-04-27 08:44:14.602656+00	2026-04-27 08:44:14.602656+00	{"eTag": "\\"2942bfabb3d05332b66eb128e0842cff\\"", "size": 13264, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-04-27T08:44:15.000Z", "contentLength": 13264, "httpStatusCode": 200}	0426afbd-3f55-42b6-bc2a-7790c7963b7e	50533191-7bde-469f-9142-25844023ffdd	{}	\N	f	f
009e02cf-3ef3-4e83-adea-5aa8219539c7	credentials	employee-53/wfh-monitoring/1777799919_c04c0c52.pdf	\N	2026-05-03 09:18:41.028985+00	2026-05-03 09:18:41.028985+00	2026-05-03 09:18:41.028985+00	{"eTag": "\\"de32ce587761b6fb11fed93416bc5d73\\"", "size": 1279625, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-05-03T09:18:41.000Z", "contentLength": 1279625, "httpStatusCode": 200}	07766036-6530-400d-829c-6388aa762bc1	\N	{}	\N	f	f
6b0822c7-5995-4b3f-8e27-ff0540190db6	credentials	employee-32/1777279651656_pdf-sample_0.pdf	50533191-7bde-469f-9142-25844023ffdd	2026-04-27 08:47:31.96465+00	2026-04-27 08:47:31.96465+00	2026-04-27 08:47:31.96465+00	{"eTag": "\\"2942bfabb3d05332b66eb128e0842cff\\"", "size": 13264, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-04-27T08:47:32.000Z", "contentLength": 13264, "httpStatusCode": 200}	ae747d13-2ee1-4da0-a786-c2001d58a2c9	50533191-7bde-469f-9142-25844023ffdd	{}	\N	f	f
21ef2ee7-c81e-46bf-aba7-d903316b481d	credentials	employee-32/1777279663811_pdf-sample_0.pdf	50533191-7bde-469f-9142-25844023ffdd	2026-04-27 08:47:43.64248+00	2026-04-27 08:47:43.64248+00	2026-04-27 08:47:43.64248+00	{"eTag": "\\"2942bfabb3d05332b66eb128e0842cff\\"", "size": 13264, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-04-27T08:47:44.000Z", "contentLength": 13264, "httpStatusCode": 200}	bb9fd10e-b0cc-4c1d-ac1f-3812ec535ef3	50533191-7bde-469f-9142-25844023ffdd	{}	\N	f	f
34ae635d-6610-44fc-8140-17083c647682	credentials	employee-32/1777280177475_pdf-sample_0.pdf	50533191-7bde-469f-9142-25844023ffdd	2026-04-27 08:56:17.941059+00	2026-04-27 08:56:17.941059+00	2026-04-27 08:56:17.941059+00	{"eTag": "\\"2942bfabb3d05332b66eb128e0842cff\\"", "size": 13264, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-04-27T08:56:18.000Z", "contentLength": 13264, "httpStatusCode": 200}	ac2bd4ce-23fb-4c92-93f4-81d19140a780	50533191-7bde-469f-9142-25844023ffdd	{}	\N	f	f
77faa7ee-690d-476f-904d-7e13f061fc17	credentials	employee-32/1777280354217_pdf-sample_0.pdf	50533191-7bde-469f-9142-25844023ffdd	2026-04-27 08:59:14.376169+00	2026-04-27 08:59:14.376169+00	2026-04-27 08:59:14.376169+00	{"eTag": "\\"2942bfabb3d05332b66eb128e0842cff\\"", "size": 13264, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-04-27T08:59:15.000Z", "contentLength": 13264, "httpStatusCode": 200}	5981de47-e0bd-4f7a-a40a-0c72a5cbd1d6	50533191-7bde-469f-9142-25844023ffdd	{}	\N	f	f
fa8ab327-7eb0-48eb-a4b0-1fb4cf662b29	credentials	employee-58/wfh-monitoring/1777902379_7ce7745e.pdf	\N	2026-05-04 13:46:21.209813+00	2026-05-04 13:46:21.209813+00	2026-05-04 13:46:21.209813+00	{"eTag": "\\"21a83f3bc7955a45d5189a0745a24fb5\\"", "size": 1279652, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-05-04T13:46:22.000Z", "contentLength": 1279652, "httpStatusCode": 200}	93490efc-4750-4914-8f9c-376246ba2c92	\N	{}	\N	f	f
35bd7cc4-61cb-4e7e-bf85-51b6819b9f8f	credentials	employee-59/1777920612488_download__1_.jpeg	87a84067-a247-4455-a9e4-60b0295ea16c	2026-05-04 18:50:13.249354+00	2026-05-04 18:50:13.249354+00	2026-05-04 18:50:13.249354+00	{"eTag": "\\"6c241ab270080422f39d2667022b9d4c\\"", "size": 6797, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-05-04T18:50:14.000Z", "contentLength": 6797, "httpStatusCode": 200}	19e7214f-cdeb-445c-a1f7-c48047811054	87a84067-a247-4455-a9e4-60b0295ea16c	{}	\N	f	f
a4268356-0acd-436a-b1de-11f1d01b620e	credentials	employee-63/wfh-monitoring/1777975326_04cc0393.jpg	\N	2026-05-05 10:02:10.829427+00	2026-05-05 10:02:10.829427+00	2026-05-05 10:02:10.829427+00	{"eTag": "\\"7a347e05d0d4dd66e613094c733904f3\\"", "size": 301260, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2026-05-05T10:02:11.000Z", "contentLength": 301260, "httpStatusCode": 200}	3755df76-881b-4eeb-8a56-db34f01f4cc1	\N	{}	\N	f	f
b7ae0f55-2612-4e1a-b618-e00a5e15d636	credentials	employee-32/1777280378692_pdf-sample_0.pdf	50533191-7bde-469f-9142-25844023ffdd	2026-04-27 08:59:38.864699+00	2026-04-27 08:59:38.864699+00	2026-04-27 08:59:38.864699+00	{"eTag": "\\"2942bfabb3d05332b66eb128e0842cff\\"", "size": 13264, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-04-27T08:59:39.000Z", "contentLength": 13264, "httpStatusCode": 200}	fc4a3c60-214d-4497-92bf-b55df7bd5db9	50533191-7bde-469f-9142-25844023ffdd	{}	\N	f	f
f82481bf-039c-4d22-96d9-4d3e9351fce4	credentials	employee-32/1777280458048_pdf-sample_0.pdf	50533191-7bde-469f-9142-25844023ffdd	2026-04-27 09:00:57.962482+00	2026-04-27 09:00:57.962482+00	2026-04-27 09:00:57.962482+00	{"eTag": "\\"2942bfabb3d05332b66eb128e0842cff\\"", "size": 13264, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-04-27T09:00:58.000Z", "contentLength": 13264, "httpStatusCode": 200}	42cba287-7582-44be-a102-235751e73544	50533191-7bde-469f-9142-25844023ffdd	{}	\N	f	f
bd1f1390-cba5-45ab-a09f-6d5c1d2bd84a	credentials	employee-48/wfh-monitoring/1777744664_d3c4b308.csv	\N	2026-05-02 17:57:45.756076+00	2026-05-02 17:57:45.756076+00	2026-05-02 17:57:45.756076+00	{"eTag": "\\"2e47641db2a2dced21982cdf8af0584c\\"", "size": 994, "mimetype": "text/csv", "cacheControl": "no-cache", "lastModified": "2026-05-02T17:57:46.000Z", "contentLength": 994, "httpStatusCode": 200}	b73ee539-3ec4-408f-827a-70e4f148cb14	\N	{}	\N	f	f
0486b86c-1aec-4a11-a685-6b3af2dc09a6	credentials	employee-32/1777280672194_pdf-sample_0.pdf	50533191-7bde-469f-9142-25844023ffdd	2026-04-27 09:04:33.039198+00	2026-04-27 09:04:33.039198+00	2026-04-27 09:04:33.039198+00	{"eTag": "\\"2942bfabb3d05332b66eb128e0842cff\\"", "size": 13264, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-04-27T09:04:33.000Z", "contentLength": 13264, "httpStatusCode": 200}	00447d5b-3bc9-4b61-9e9e-1b6a341a04f7	50533191-7bde-469f-9142-25844023ffdd	{}	\N	f	f
709f2222-dae8-40f3-a74e-fc894be07250	credentials	employee-32/1777283518772_sample-local-pdf.pdf	50533191-7bde-469f-9142-25844023ffdd	2026-04-27 09:51:59.109689+00	2026-04-27 09:51:59.109689+00	2026-04-27 09:51:59.109689+00	{"eTag": "\\"55f924af410dd775524d069ffe80dbdc\\"", "size": 49672, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-04-27T09:52:00.000Z", "contentLength": 49672, "httpStatusCode": 200}	3b2d3217-ccc1-4380-85e1-a19d33f1ec14	50533191-7bde-469f-9142-25844023ffdd	{}	\N	f	f
982fda27-318d-4cf9-ab4c-80e361901880	credentials	employee-45/1777745206887_download__1_.jpeg	e968745f-25ac-4ac9-84ca-0c0be900ef4a	2026-05-02 18:06:47.861889+00	2026-05-02 18:06:47.861889+00	2026-05-02 18:06:47.861889+00	{"eTag": "\\"6c241ab270080422f39d2667022b9d4c\\"", "size": 6797, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-05-02T18:06:48.000Z", "contentLength": 6797, "httpStatusCode": 200}	8c249846-5fc6-4c39-a719-a505e4d61dbb	e968745f-25ac-4ac9-84ca-0c0be900ef4a	{}	\N	f	f
a1c462fc-0220-4be5-a519-3a82c1138809	credentials	employee-32/1777283774029_sample-local-pdf.pdf	50533191-7bde-469f-9142-25844023ffdd	2026-04-27 09:56:14.588833+00	2026-04-27 09:56:14.588833+00	2026-04-27 09:56:14.588833+00	{"eTag": "\\"55f924af410dd775524d069ffe80dbdc\\"", "size": 49672, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-04-27T09:56:15.000Z", "contentLength": 49672, "httpStatusCode": 200}	38a8e896-4a3f-4ab2-b161-590d02dabc10	50533191-7bde-469f-9142-25844023ffdd	{}	\N	f	f
381833c7-0658-4fb5-adda-70f31b9a1b71	credentials	employee-41/1777285306_5f2ee541.pdf	\N	2026-04-27 10:21:48.126028+00	2026-04-27 10:21:48.126028+00	2026-04-27 10:21:48.126028+00	{"eTag": "\\"66c2fedfeffa170d5aca2c0d834a8678\\"", "size": 1279649, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-04-27T10:21:49.000Z", "contentLength": 1279649, "httpStatusCode": 200}	3b97a8bf-b519-4039-824e-b87e3ecb5c89	\N	{}	\N	f	f
d92c190d-dd39-4bb6-b16b-8fbc41b73899	credentials	38da8829-ac0b-4ca3-b7e3-50b4183be14b/avatar.jpg	38da8829-ac0b-4ca3-b7e3-50b4183be14b	2026-05-03 11:27:25.574957+00	2026-05-03 11:27:25.574957+00	2026-05-03 11:27:25.574957+00	{"eTag": "\\"0321291c1184ba232e6bcf7c19b003c1\\"", "size": 10227, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-05-03T11:27:26.000Z", "contentLength": 10227, "httpStatusCode": 200}	e32e0686-9a14-4bbf-89d5-710582c01bdc	38da8829-ac0b-4ca3-b7e3-50b4183be14b	{}	\N	f	f
b687f693-6d18-4eb5-acef-b86b5540be9c	credentials	employee-32/1777288707070_IMG_20260427_104923.jpg	50533191-7bde-469f-9142-25844023ffdd	2026-04-27 11:18:28.131126+00	2026-04-27 11:18:28.131126+00	2026-04-27 11:18:28.131126+00	{"eTag": "\\"ff448296ddaff30c312427b385bff699\\"", "size": 200061, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-04-27T11:18:29.000Z", "contentLength": 200061, "httpStatusCode": 200}	14f0c9a2-1d62-4923-bcc2-4c0641c336fa	50533191-7bde-469f-9142-25844023ffdd	{}	\N	f	f
52526e42-a879-4241-9a67-488d4028a3df	credentials	employee-41/1777297581_e2095254.pdf	\N	2026-04-27 13:46:23.01029+00	2026-04-27 13:46:23.01029+00	2026-04-27 13:46:23.01029+00	{"eTag": "\\"21a83f3bc7955a45d5189a0745a24fb5\\"", "size": 1279652, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-04-27T13:46:23.000Z", "contentLength": 1279652, "httpStatusCode": 200}	f44527d9-5124-408a-aae2-2c62d277a661	\N	{}	\N	f	f
c4bb2246-0262-4513-9579-8072a3451c80	credentials	employee-41/1777297955_ee4769b4.pdf	\N	2026-04-27 13:52:42.299569+00	2026-04-27 13:52:42.299569+00	2026-04-27 13:52:42.299569+00	{"eTag": "\\"66c2fedfeffa170d5aca2c0d834a8678\\"", "size": 1279649, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-04-27T13:52:43.000Z", "contentLength": 1279649, "httpStatusCode": 200}	ccd4c8d6-8170-42e1-b8d3-887d1391b1fa	\N	{}	\N	f	f
265bc7e7-fb02-4e80-be76-2723a98c20e9	credentials	employee-41/1777298381_54733f6a.pdf	\N	2026-04-27 13:59:42.603483+00	2026-04-27 13:59:42.603483+00	2026-04-27 13:59:42.603483+00	{"eTag": "\\"8e27a35e407956ec5697b3c2e9d0e653\\"", "size": 1279645, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-04-27T13:59:43.000Z", "contentLength": 1279645, "httpStatusCode": 200}	d6cb0887-6adf-4947-97c5-5bb0a86f1cd8	\N	{}	\N	f	f
d0566d40-4721-45c9-8630-c76d07a66dc1	credentials	7db104a0-28dd-4018-a809-5e7ff229b792/1777347370596_avatar.jpg	7db104a0-28dd-4018-a809-5e7ff229b792	2026-04-28 03:36:11.235373+00	2026-04-28 03:36:11.235373+00	2026-04-28 03:36:11.235373+00	{"eTag": "\\"0321291c1184ba232e6bcf7c19b003c1\\"", "size": 10227, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-04-28T03:36:12.000Z", "contentLength": 10227, "httpStatusCode": 200}	05d6b969-01dd-479c-a627-5df537575c95	7db104a0-28dd-4018-a809-5e7ff229b792	{}	\N	f	f
70def6fb-f24b-4b0f-aea3-168835703723	credentials	7db104a0-28dd-4018-a809-5e7ff229b792/1777347601121_avatar.jpg	7db104a0-28dd-4018-a809-5e7ff229b792	2026-04-28 03:40:01.791517+00	2026-04-28 03:40:01.791517+00	2026-04-28 03:40:01.791517+00	{"eTag": "\\"0321291c1184ba232e6bcf7c19b003c1\\"", "size": 10227, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-04-28T03:40:02.000Z", "contentLength": 10227, "httpStatusCode": 200}	57cd92a3-07a3-45c9-9744-9d47c3c7477c	7db104a0-28dd-4018-a809-5e7ff229b792	{}	\N	f	f
37a43122-f97e-4c70-bbae-11831c86b7b1	credentials	employee-45/1777746575949_sample-local-pdf.pdf	e968745f-25ac-4ac9-84ca-0c0be900ef4a	2026-05-02 18:29:37.469262+00	2026-05-02 18:29:37.469262+00	2026-05-02 18:29:37.469262+00	{"eTag": "\\"55f924af410dd775524d069ffe80dbdc\\"", "size": 49672, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-05-02T18:29:38.000Z", "contentLength": 49672, "httpStatusCode": 200}	9a0b1d65-83c8-4929-8f73-c1bcb2baab80	e968745f-25ac-4ac9-84ca-0c0be900ef4a	{}	\N	f	f
f244c0da-2dc6-4ed3-9213-00a0f1839132	credentials	7db104a0-28dd-4018-a809-5e7ff229b792/profile.jpg	7db104a0-28dd-4018-a809-5e7ff229b792	2026-04-28 04:36:14.386153+00	2026-04-28 04:36:14.386153+00	2026-04-28 04:36:14.386153+00	{"eTag": "\\"0321291c1184ba232e6bcf7c19b003c1\\"", "size": 10227, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-04-28T04:36:15.000Z", "contentLength": 10227, "httpStatusCode": 200}	f7f138e9-1879-4185-9817-192929d900ab	7db104a0-28dd-4018-a809-5e7ff229b792	{}	\N	f	f
b72a1b0d-f9bf-4085-8ce0-f40cef10dcbd	credentials	employee-41/1777387968_e90ec677.pdf	\N	2026-04-28 14:52:52.359237+00	2026-04-28 14:52:52.359237+00	2026-04-28 14:52:52.359237+00	{"eTag": "\\"66c2fedfeffa170d5aca2c0d834a8678\\"", "size": 1279649, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-04-28T14:52:53.000Z", "contentLength": 1279649, "httpStatusCode": 200}	009e9a5a-7cd9-48f3-9573-8eda68ab77ff	\N	{}	\N	f	f
66b59401-4cac-4372-93eb-1d038964b83b	credentials	628613d1-57db-4fa9-b4e3-11ed26ee43cd/avatar.jpg	628613d1-57db-4fa9-b4e3-11ed26ee43cd	2026-05-03 12:00:20.823523+00	2026-05-03 12:00:20.823523+00	2026-05-03 12:00:20.823523+00	{"eTag": "\\"7f0d3646a20be27d23d5c995bd428b6b\\"", "size": 9247, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-05-03T12:00:21.000Z", "contentLength": 9247, "httpStatusCode": 200}	1cc131cf-c55d-4496-a6b7-a68948548b9f	628613d1-57db-4fa9-b4e3-11ed26ee43cd	{}	\N	f	f
b8394ea1-d042-4be8-8789-468ab3201cca	credentials	employee-44/1777453667_7b6599d7.pdf	\N	2026-04-29 09:07:48.221178+00	2026-04-29 09:07:48.221178+00	2026-04-29 09:07:48.221178+00	{"eTag": "\\"4966b73eea0b29317f536faa30b4f303\\"", "size": 42707, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-04-29T09:07:49.000Z", "contentLength": 42707, "httpStatusCode": 200}	6754dc75-3539-458d-8f82-fd37fa8af5c9	\N	{}	\N	f	f
821f1193-e037-4c73-b77d-664f13939968	credentials	employee-60/wfh-monitoring/1777910656_cd84b8af.pdf	\N	2026-05-04 16:04:17.603033+00	2026-05-04 16:04:17.603033+00	2026-05-04 16:04:17.603033+00	{"eTag": "\\"4966b73eea0b29317f536faa30b4f303\\"", "size": 42707, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-05-04T16:04:18.000Z", "contentLength": 42707, "httpStatusCode": 200}	322a3f27-533d-4ad5-a73f-17667590caec	\N	{}	\N	f	f
c1cc5b21-b316-4cd1-ac45-cd634fd26c33	credentials	employee-44/1777453755_d773a1d7.pdf	\N	2026-04-29 09:09:16.239257+00	2026-04-29 09:09:16.239257+00	2026-04-29 09:09:16.239257+00	{"eTag": "\\"4966b73eea0b29317f536faa30b4f303\\"", "size": 42707, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-04-29T09:09:17.000Z", "contentLength": 42707, "httpStatusCode": 200}	2c46ac63-f67c-4f49-94d7-8700c362db77	\N	{}	\N	f	f
f3c9074f-e655-4806-8736-102681ea45ed	credentials	employee-44/1777454199_fea04f69.pdf	\N	2026-04-29 09:16:40.10794+00	2026-04-29 09:16:40.10794+00	2026-04-29 09:16:40.10794+00	{"eTag": "\\"21a83f3bc7955a45d5189a0745a24fb5\\"", "size": 1279652, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-04-29T09:16:41.000Z", "contentLength": 1279652, "httpStatusCode": 200}	197b7841-465e-4537-a497-b9ec6d2021b8	\N	{}	\N	f	f
08c01537-33fc-419d-9e41-37d53c700b1d	credentials	employee-44/wfh-monitoring/1777457589_533d5d62.pdf	\N	2026-04-29 10:13:09.746868+00	2026-04-29 10:13:09.746868+00	2026-04-29 10:13:09.746868+00	{"eTag": "\\"66c2fedfeffa170d5aca2c0d834a8678\\"", "size": 1279649, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-04-29T10:13:10.000Z", "contentLength": 1279649, "httpStatusCode": 200}	427192dc-59d8-44fc-969b-91a0244defd3	\N	{}	\N	f	f
84909bbe-d60a-459c-b0ef-84bab34e052c	credentials	02b9a3bc-d1cd-462f-a217-efed39dcea79/avatar.jpg	02b9a3bc-d1cd-462f-a217-efed39dcea79	2026-04-29 10:19:02.556761+00	2026-04-29 10:19:02.556761+00	2026-04-29 10:19:02.556761+00	{"eTag": "\\"7f0d3646a20be27d23d5c995bd428b6b\\"", "size": 9247, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-04-29T10:19:03.000Z", "contentLength": 9247, "httpStatusCode": 200}	086f1cef-6eb0-44d7-9b7d-647b820006f0	02b9a3bc-d1cd-462f-a217-efed39dcea79	{}	\N	f	f
ba52d164-91ec-488b-8de2-9f6359f1d650	credentials	employee-44/wfh-monitoring/1777458379_f6a79e9e.pdf	\N	2026-04-29 10:26:20.295661+00	2026-04-29 10:26:20.295661+00	2026-04-29 10:26:20.295661+00	{"eTag": "\\"66c2fedfeffa170d5aca2c0d834a8678\\"", "size": 1279649, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-04-29T10:26:21.000Z", "contentLength": 1279649, "httpStatusCode": 200}	d3730be9-7725-4c88-a9b1-e8bc01244f85	\N	{}	\N	f	f
a9334bd7-be55-459f-9f44-c55c2300fd69	credentials	employee-44/wfh-monitoring/1777458702_153e7f05.pdf	\N	2026-04-29 10:31:44.07712+00	2026-04-29 10:31:44.07712+00	2026-04-29 10:31:44.07712+00	{"eTag": "\\"66c2fedfeffa170d5aca2c0d834a8678\\"", "size": 1279649, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-04-29T10:31:45.000Z", "contentLength": 1279649, "httpStatusCode": 200}	8049d697-a441-4630-869f-94e22bca98e3	\N	{}	\N	f	f
b61f09fd-cd8a-46ca-b25d-7a0875ebba57	credentials	e968745f-25ac-4ac9-84ca-0c0be900ef4a/avatar.jpg	e968745f-25ac-4ac9-84ca-0c0be900ef4a	2026-05-02 19:45:35.724304+00	2026-05-02 19:45:35.724304+00	2026-05-02 19:45:35.724304+00	{"eTag": "\\"2797c499a390efea2530e0f8350cc05e\\"", "size": 9829, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-05-02T19:45:36.000Z", "contentLength": 9829, "httpStatusCode": 200}	f6784cf0-cc0f-4889-80c2-c202917d2e0a	e968745f-25ac-4ac9-84ca-0c0be900ef4a	{}	\N	f	f
88fba797-4ce8-47d2-a37a-79c3064dc2ba	credentials	employee-44/wfh-monitoring/1777459286_b83742ff.pdf	\N	2026-04-29 10:41:27.463128+00	2026-04-29 10:41:27.463128+00	2026-04-29 10:41:27.463128+00	{"eTag": "\\"66c2fedfeffa170d5aca2c0d834a8678\\"", "size": 1279649, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-04-29T10:41:28.000Z", "contentLength": 1279649, "httpStatusCode": 200}	a36ecd6b-c8b5-4b00-8063-4b3cd2ffad62	\N	{}	\N	f	f
b337fe33-a32c-41c2-8515-051f850df256	credentials	employee-44/wfh-monitoring/1777459785_3134ad40.pdf	\N	2026-04-29 10:49:46.139229+00	2026-04-29 10:49:46.139229+00	2026-04-29 10:49:46.139229+00	{"eTag": "\\"4966b73eea0b29317f536faa30b4f303\\"", "size": 42707, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-04-29T10:49:47.000Z", "contentLength": 42707, "httpStatusCode": 200}	9539a048-98cf-4cee-9ab9-6ea63c46b369	\N	{}	\N	f	f
b9162af8-a692-429d-b77e-f6512799ddd8	credentials	employee-54/wfh-monitoring/1777824071_47666398.pdf	\N	2026-05-03 16:01:12.541952+00	2026-05-03 16:01:12.541952+00	2026-05-03 16:01:12.541952+00	{"eTag": "\\"66c2fedfeffa170d5aca2c0d834a8678\\"", "size": 1279649, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-05-03T16:01:13.000Z", "contentLength": 1279649, "httpStatusCode": 200}	4a0cee83-239f-49e2-876f-ab72fb2b3ba6	\N	{}	\N	f	f
e3e03c65-9fbb-43b2-91c7-eb25f15eb145	credentials	employee-44/wfh-monitoring/1777459973_e49b11ac.pdf	\N	2026-04-29 10:52:54.30163+00	2026-04-29 10:52:54.30163+00	2026-04-29 10:52:54.30163+00	{"eTag": "\\"de32ce587761b6fb11fed93416bc5d73\\"", "size": 1279625, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-04-29T10:52:55.000Z", "contentLength": 1279625, "httpStatusCode": 200}	ef0888d5-de18-4de8-829b-d587ababc9e4	\N	{}	\N	f	f
13ddc227-dc80-4260-88c2-bf709bcd398b	credentials	employee-60/wfh-monitoring/1777910922_0b81c60a.pdf	\N	2026-05-04 16:08:43.608512+00	2026-05-04 16:08:43.608512+00	2026-05-04 16:08:43.608512+00	{"eTag": "\\"4966b73eea0b29317f536faa30b4f303\\"", "size": 42707, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-05-04T16:08:44.000Z", "contentLength": 42707, "httpStatusCode": 200}	fceaa00c-68d2-4df5-8544-0c49a25f7be7	\N	{}	\N	f	f
d1124eed-e077-4d5c-935b-f31730d92b3e	credentials	employee-44/wfh-monitoring/1777460091_b60730b2.pdf	\N	2026-04-29 10:54:52.090497+00	2026-04-29 10:54:52.090497+00	2026-04-29 10:54:52.090497+00	{"eTag": "\\"de32ce587761b6fb11fed93416bc5d73\\"", "size": 1279625, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-04-29T10:54:53.000Z", "contentLength": 1279625, "httpStatusCode": 200}	6563aa0e-9378-470b-9fac-9fc746bc60e4	\N	{}	\N	f	f
302c5311-861d-4067-9768-46b38fb02fed	credentials	employee-44/1777463395_a3a630d0.pdf	\N	2026-04-29 11:49:58.330966+00	2026-04-29 11:49:58.330966+00	2026-04-29 11:49:58.330966+00	{"eTag": "\\"8e27a35e407956ec5697b3c2e9d0e653\\"", "size": 1279645, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-04-29T11:49:59.000Z", "contentLength": 1279645, "httpStatusCode": 200}	779ad54c-444c-44a3-9f28-3522705a9575	\N	{}	\N	f	f
b06091d6-ddf2-4c78-95bc-3c8e5f669b82	credentials	employee-60/1777911109_82ba5f74.jpg	\N	2026-05-04 16:11:50.332649+00	2026-05-04 16:11:50.332649+00	2026-05-04 16:11:50.332649+00	{"eTag": "\\"4d0e58bc48decafcf86e7be309a8aaef\\"", "size": 71867, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2026-05-04T16:11:51.000Z", "contentLength": 71867, "httpStatusCode": 200}	f060040a-855c-4768-8526-e72bff8506e0	\N	{}	\N	f	f
5d636267-02f3-4337-ac78-3a26c884822d	credentials	02b9a3bc-d1cd-462f-a217-efed39dcea79/1777478881801_sample-local-pdf.pdf	02b9a3bc-d1cd-462f-a217-efed39dcea79	2026-04-29 16:08:04.677607+00	2026-04-29 16:08:04.677607+00	2026-04-29 16:08:04.677607+00	{"eTag": "\\"55f924af410dd775524d069ffe80dbdc\\"", "size": 49672, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-04-29T16:08:05.000Z", "contentLength": 49672, "httpStatusCode": 200}	5dd6ba93-e8d8-46d2-b441-d6253160544c	02b9a3bc-d1cd-462f-a217-efed39dcea79	{}	\N	f	f
4a8907bc-8389-4aa4-8a57-722a1a045605	credentials	employee-44/wfh-monitoring/1777640366_96d5889a.csv	\N	2026-05-01 12:59:27.807104+00	2026-05-01 12:59:27.807104+00	2026-05-01 12:59:27.807104+00	{"eTag": "\\"2e47641db2a2dced21982cdf8af0584c\\"", "size": 994, "mimetype": "text/csv", "cacheControl": "no-cache", "lastModified": "2026-05-01T12:59:28.000Z", "contentLength": 994, "httpStatusCode": 200}	8a5f193e-3398-4786-94d2-1642ff9c8da3	\N	{}	\N	f	f
3f367e66-3fd9-4834-9809-c5b8e1fcc2ad	credentials	employee-45/wfh-monitoring/1777641644_3ca99eef.pdf	\N	2026-05-01 13:20:46.408012+00	2026-05-01 13:20:46.408012+00	2026-05-01 13:20:46.408012+00	{"eTag": "\\"4966b73eea0b29317f536faa30b4f303\\"", "size": 42707, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-05-01T13:20:47.000Z", "contentLength": 42707, "httpStatusCode": 200}	0caed8b4-a3eb-4d98-bdcc-8377df388f4c	\N	{}	\N	f	f
fe9189a5-82e1-4122-8d32-b888d08a4043	credentials	employee-45/wfh-monitoring/1777646372_47f40a00.pdf	\N	2026-05-01 14:39:33.9919+00	2026-05-01 14:39:33.9919+00	2026-05-01 14:39:33.9919+00	{"eTag": "\\"81b1037d2f3d19e01b60e5733ed6fbbb\\"", "size": 781779, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-05-01T14:39:34.000Z", "contentLength": 781779, "httpStatusCode": 200}	5190fe0c-9850-40f6-a3d1-88a22cca6210	\N	{}	\N	f	f
90436cea-8c00-4bd8-a6a6-5a0c135e6c5a	credentials	employee-45/wfh-monitoring/1777649664_f2a49123.xlsx	\N	2026-05-01 15:34:25.940008+00	2026-05-01 15:34:25.940008+00	2026-05-01 15:34:25.940008+00	{"eTag": "\\"ccff608d4ee4d3ac1362494dd54405f1\\"", "size": 88929, "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "cacheControl": "no-cache", "lastModified": "2026-05-01T15:34:26.000Z", "contentLength": 88929, "httpStatusCode": 200}	d552ec9d-6556-43b3-9b60-e7ca05b89fd2	\N	{}	\N	f	f
801618e7-aea9-4b26-9299-bf380a50c317	credentials	employee-52/1777794933_82cec4d0.pdf	\N	2026-05-03 07:55:34.893857+00	2026-05-03 07:55:34.893857+00	2026-05-03 07:55:34.893857+00	{"eTag": "\\"21a83f3bc7955a45d5189a0745a24fb5\\"", "size": 1279652, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-05-03T07:55:35.000Z", "contentLength": 1279652, "httpStatusCode": 200}	1caf9833-0383-44c8-b55f-eeb3c4655be2	\N	{}	\N	f	f
4e1ef5b4-d4f9-4185-ab77-efa195f840b5	credentials	employee-41/1777659088955_download.jpeg	02b9a3bc-d1cd-462f-a217-efed39dcea79	2026-05-01 18:11:30.873826+00	2026-05-01 18:11:30.873826+00	2026-05-01 18:11:30.873826+00	{"eTag": "\\"5e8dc38f946afc39a89289ad54983656\\"", "size": 7143, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-05-01T18:11:31.000Z", "contentLength": 7143, "httpStatusCode": 200}	22ee761a-1be3-4799-9fe0-d39a0b10eee7	02b9a3bc-d1cd-462f-a217-efed39dcea79	{}	\N	f	f
cbe6da7b-2f01-488a-81d4-ac64a2d967c9	credentials	employee-41/wfh-monitoring/1777659791_8594582c.pdf	\N	2026-05-01 18:23:12.529766+00	2026-05-01 18:23:12.529766+00	2026-05-01 18:23:12.529766+00	{"eTag": "\\"fb69f67dad50aeb2e4ecf886fb3d7e7a\\"", "size": 74656, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-05-01T18:23:13.000Z", "contentLength": 74656, "httpStatusCode": 200}	3d6011af-663f-40d6-bf63-77ae71e411b7	\N	{}	\N	f	f
c2a8b74c-63d1-4d70-b029-3b5ef8d9bbcc	credentials	employee-55/wfh-monitoring/1777825599_4d7f841e.pdf	\N	2026-05-03 16:26:40.314555+00	2026-05-03 16:26:40.314555+00	2026-05-03 16:26:40.314555+00	{"eTag": "\\"66c2fedfeffa170d5aca2c0d834a8678\\"", "size": 1279649, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-05-03T16:26:41.000Z", "contentLength": 1279649, "httpStatusCode": 200}	3131195c-9188-4ef7-8b97-bfb1b9ab9b7b	\N	{}	\N	f	f
ca3884d2-4126-4e70-a57e-d357a8a37e24	credentials	employee-41/1777660491733_sample-local-pdf.pdf	02b9a3bc-d1cd-462f-a217-efed39dcea79	2026-05-01 18:34:56.473339+00	2026-05-01 18:34:56.473339+00	2026-05-01 18:34:56.473339+00	{"eTag": "\\"55f924af410dd775524d069ffe80dbdc\\"", "size": 49672, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-05-01T18:34:57.000Z", "contentLength": 49672, "httpStatusCode": 200}	a572d19e-e619-4f61-99df-f375ddaf889c	02b9a3bc-d1cd-462f-a217-efed39dcea79	{}	\N	f	f
b235c6d4-38a1-4336-a539-44d715606e15	credentials	employee-41/1777660817221_sample-local-pdf.pdf	02b9a3bc-d1cd-462f-a217-efed39dcea79	2026-05-01 18:40:21.530555+00	2026-05-01 18:40:21.530555+00	2026-05-01 18:40:21.530555+00	{"eTag": "\\"55f924af410dd775524d069ffe80dbdc\\"", "size": 49672, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-05-01T18:40:22.000Z", "contentLength": 49672, "httpStatusCode": 200}	16d37173-3e59-4ffc-be2c-cd2eb9e1a510	02b9a3bc-d1cd-462f-a217-efed39dcea79	{}	\N	f	f
b35ebc5e-17d9-44bd-a12c-a7d92f22e92e	credentials	employee-55/wfh-monitoring/1777825641_24a8e743.pdf	\N	2026-05-03 16:27:21.881428+00	2026-05-03 16:27:21.881428+00	2026-05-03 16:27:21.881428+00	{"eTag": "\\"8e27a35e407956ec5697b3c2e9d0e653\\"", "size": 1279645, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-05-03T16:27:22.000Z", "contentLength": 1279645, "httpStatusCode": 200}	eafb7505-8cb4-4ae8-836c-0e32b11ce16f	\N	{}	\N	f	f
8118cb48-db8e-457d-94a1-c6ebe5dda0e5	credentials	employee-50/wfh-monitoring/1777719888_ca201d74.pdf	\N	2026-05-02 11:04:49.814428+00	2026-05-02 11:04:49.814428+00	2026-05-02 11:04:49.814428+00	{"eTag": "\\"599db148ffe0f4b63c1c0b1c72eb2d58\\"", "size": 294683, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-05-02T11:04:50.000Z", "contentLength": 294683, "httpStatusCode": 200}	3d3b8b91-9bee-4044-9c7e-f42f336bd33f	\N	{}	\N	f	f
c2b0907a-8ec9-4983-bc10-0308b4f32da9	credentials	employee-50/wfh-monitoring/1777721137_ce782880.png	\N	2026-05-02 11:25:38.513878+00	2026-05-02 11:25:38.513878+00	2026-05-02 11:25:38.513878+00	{"eTag": "\\"5816fae0f557ea163d336cd38d30c1bf\\"", "size": 106162, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-05-02T11:25:39.000Z", "contentLength": 106162, "httpStatusCode": 200}	462aaa75-1975-4f2c-9e9e-02b693bfe8e6	\N	{}	\N	f	f
52d19d14-481b-48d3-9933-813e0e50c4a5	credentials	employee-50/wfh-monitoring/1777730020_53808a4a.pdf	\N	2026-05-02 13:53:41.53977+00	2026-05-02 13:53:41.53977+00	2026-05-02 13:53:41.53977+00	{"eTag": "\\"4966b73eea0b29317f536faa30b4f303\\"", "size": 42707, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-05-02T13:53:42.000Z", "contentLength": 42707, "httpStatusCode": 200}	7499864d-4682-4c20-8725-b4c22d385d49	\N	{}	\N	f	f
af0eeeaf-437b-4deb-a87d-c85a8f7a092b	credentials	employee-50/1777735620_c379b27d.pdf	\N	2026-05-02 15:27:01.569852+00	2026-05-02 15:27:01.569852+00	2026-05-02 15:27:01.569852+00	{"eTag": "\\"4966b73eea0b29317f536faa30b4f303\\"", "size": 42707, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-05-02T15:27:02.000Z", "contentLength": 42707, "httpStatusCode": 200}	8974a39b-b767-4a3c-ae4a-81ec15c73156	\N	{}	\N	f	f
277c40eb-db3c-475d-a036-884c0cd3147c	credentials	employee-45/1777736059280_sample-local-pdf.pdf	e968745f-25ac-4ac9-84ca-0c0be900ef4a	2026-05-02 15:34:20.831406+00	2026-05-02 15:34:20.831406+00	2026-05-02 15:34:20.831406+00	{"eTag": "\\"55f924af410dd775524d069ffe80dbdc\\"", "size": 49672, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-05-02T15:34:21.000Z", "contentLength": 49672, "httpStatusCode": 200}	a37b03f7-145b-43b0-85b9-1b0b40a8dc09	e968745f-25ac-4ac9-84ca-0c0be900ef4a	{}	\N	f	f
e6d600e3-872b-48fe-b8dc-689840668362	credentials	employee-45/1777736124929_sample-local-pdf.pdf	e968745f-25ac-4ac9-84ca-0c0be900ef4a	2026-05-02 15:35:26.326319+00	2026-05-02 15:35:26.326319+00	2026-05-02 15:35:26.326319+00	{"eTag": "\\"55f924af410dd775524d069ffe80dbdc\\"", "size": 49672, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-05-02T15:35:27.000Z", "contentLength": 49672, "httpStatusCode": 200}	c656f74e-c340-479a-a9ce-1302c175e352	e968745f-25ac-4ac9-84ca-0c0be900ef4a	{}	\N	f	f
ed36cea1-faf6-4824-9e88-52b56958f3e6	credentials	employee-51/wfh-monitoring/1777737371_b0ec55b4.pdf	\N	2026-05-02 15:56:13.497889+00	2026-05-02 15:56:13.497889+00	2026-05-02 15:56:13.497889+00	{"eTag": "\\"de32ce587761b6fb11fed93416bc5d73\\"", "size": 1279625, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-05-02T15:56:14.000Z", "contentLength": 1279625, "httpStatusCode": 200}	9fb9fc52-8f36-4a84-b3a2-dcc8bbf01d83	\N	{}	\N	f	f
0746233d-6f7d-4e5b-bbaf-51ade91fcb22	credentials	employee-56/wfh-monitoring/1777878002_cb1d68e2.pdf	\N	2026-05-04 07:00:04.349114+00	2026-05-04 07:00:04.349114+00	2026-05-04 07:00:04.349114+00	{"eTag": "\\"66c2fedfeffa170d5aca2c0d834a8678\\"", "size": 1279649, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-05-04T07:00:05.000Z", "contentLength": 1279649, "httpStatusCode": 200}	e7894730-77f0-4ec7-a375-4638a4d4a2c4	\N	{}	\N	f	f
f3e036f7-b542-4567-a480-aa8e3d2dcaf1	credentials	employee-56/wfh-monitoring/1777878044_ff918562.xlsx	\N	2026-05-04 07:00:45.366082+00	2026-05-04 07:00:45.366082+00	2026-05-04 07:00:45.366082+00	{"eTag": "\\"0c38cdeefc33e0f5d06465a27126de16\\"", "size": 24654, "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "cacheControl": "no-cache", "lastModified": "2026-05-04T07:00:46.000Z", "contentLength": 24654, "httpStatusCode": 200}	2abc1ecb-0782-489e-bf02-7fe475e2b3c7	\N	{}	\N	f	f
05bfa8dd-ba0e-4bdd-aa75-e2a2f4e8cc89	credentials	employee-56/1777878626_e4601f0c.png	\N	2026-05-04 07:10:27.879928+00	2026-05-04 07:10:27.879928+00	2026-05-04 07:10:27.879928+00	{"eTag": "\\"707199767aa631411832e32173304c38\\"", "size": 655755, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-05-04T07:10:28.000Z", "contentLength": 655755, "httpStatusCode": 200}	6ca9be52-52d6-466c-8427-7c45af13dae7	\N	{}	\N	f	f
81028a67-ab28-48cd-b002-e736daf30889	credentials	employee-56/1777878655_43cf9ba2.pdf	\N	2026-05-04 07:10:56.062865+00	2026-05-04 07:10:56.062865+00	2026-05-04 07:10:56.062865+00	{"eTag": "\\"599db148ffe0f4b63c1c0b1c72eb2d58\\"", "size": 294683, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-05-04T07:10:56.000Z", "contentLength": 294683, "httpStatusCode": 200}	e0f7c534-7f73-457b-b6eb-4b6a1d9d6a01	\N	{}	\N	f	f
605c12df-515f-4057-b01f-6c03ade080b2	credentials	employee-59/1777919342362_sample-local-pdf.pdf	87a84067-a247-4455-a9e4-60b0295ea16c	2026-05-04 18:29:03.408698+00	2026-05-04 18:29:03.408698+00	2026-05-04 18:29:03.408698+00	{"eTag": "\\"55f924af410dd775524d069ffe80dbdc\\"", "size": 49672, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-05-04T18:29:04.000Z", "contentLength": 49672, "httpStatusCode": 200}	976b56f0-1090-455e-a224-c119d0f0d5bb	87a84067-a247-4455-a9e4-60b0295ea16c	{}	\N	f	f
46b03276-2d6e-4ddd-be37-dc96fe5f80a6	credentials	employee-61/1777965581065_sample-local-pdf.pdf	877c9019-74c4-4cf7-abfd-62652329d067	2026-05-05 07:19:42.643714+00	2026-05-05 07:19:42.643714+00	2026-05-05 07:19:42.643714+00	{"eTag": "\\"55f924af410dd775524d069ffe80dbdc\\"", "size": 49672, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-05-05T07:19:43.000Z", "contentLength": 49672, "httpStatusCode": 200}	037873e4-e94b-4b4e-8c8d-14b98ac9776d	877c9019-74c4-4cf7-abfd-62652329d067	{}	\N	f	f
a9aaf8d2-ca60-4786-a581-c9a83a358d36	credentials	employee-65/1786037262_0120e3de.pdf	\N	2026-08-06 17:27:43.298274+00	2026-08-06 17:27:43.298274+00	2026-08-06 17:27:43.298274+00	{"eTag": "\\"599db148ffe0f4b63c1c0b1c72eb2d58\\"", "size": 294683, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-08-06T17:27:44.000Z", "contentLength": 294683, "httpStatusCode": 200}	06a06798-10fd-40e0-bd60-7ed65d930261	\N	{}	\N	f	f
be7990e7-c924-4505-ae66-24c13948aa2f	credentials	employee-72/1786817008_56c556db.docx	\N	2026-08-15 18:03:29.29668+00	2026-08-15 18:03:29.29668+00	2026-08-15 18:03:29.29668+00	{"eTag": "\\"41d505984a470590878e459a0a38e992\\"", "size": 25716, "mimetype": "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "cacheControl": "no-cache", "lastModified": "2026-08-15T18:03:30.000Z", "contentLength": 25716, "httpStatusCode": 200}	7049a531-af3a-48ca-b10b-7b1084d6f248	\N	{}	\N	f	f
b2118b4e-7183-43af-9133-ddc0490bafa5	credentials	employee-72/wfh-monitoring/1786817622_041d948a.jpeg	\N	2026-08-15 18:13:42.959201+00	2026-08-15 18:13:42.959201+00	2026-08-15 18:13:42.959201+00	{"eTag": "\\"81a0ed191ebf72e46f3e922e56e9eb75\\"", "size": 26819, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2026-08-15T18:13:43.000Z", "contentLength": 26819, "httpStatusCode": 200}	b9de7aeb-7457-4875-8611-7e1820905968	\N	{}	\N	f	f
b0aa404b-f8e0-4b91-8e78-9a223a00fc19	credentials	employee-73/1787237281_46ba0355.docx	\N	2026-08-20 14:48:02.515209+00	2026-08-20 14:48:02.515209+00	2026-08-20 14:48:02.515209+00	{"eTag": "\\"1b0808bebe75d0c85dcb810d6435de78\\"", "size": 73547, "mimetype": "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "cacheControl": "no-cache", "lastModified": "2026-08-20T14:48:03.000Z", "contentLength": 73547, "httpStatusCode": 200}	141e9ee7-bf4a-4d2d-9764-af86c7bf96aa	\N	{}	\N	f	f
ead7a948-0643-4cbd-8573-4c3e2b0d7cc2	credentials	employee-73/1787237645_6cf40e8e.png	\N	2026-08-20 14:54:07.853647+00	2026-08-20 14:54:07.853647+00	2026-08-20 14:54:07.853647+00	{"eTag": "\\"f20b24272cc03cf62f63d8add1e8fecc\\"", "size": 41991, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-08-20T14:54:08.000Z", "contentLength": 41991, "httpStatusCode": 200}	756014cf-365f-4fdb-97e1-385dd9be99b9	\N	{}	\N	f	f
fe5f67f1-e0ab-453e-8ac6-e0d92dd407d4	credentials	employee-74/wfh-monitoring/1787253585_ce016139.pdf	\N	2026-08-20 19:19:47.86102+00	2026-08-20 19:19:47.86102+00	2026-08-20 19:19:47.86102+00	{"eTag": "\\"437055da6fdf243f6209650b3ddbc618\\"", "size": 115825, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-08-20T19:19:48.000Z", "contentLength": 115825, "httpStatusCode": 200}	c63aa6a4-27fa-425b-b9af-530399301414	\N	{}	\N	f	f
ffa5b0fd-6e35-4d89-b067-0749a8330658	credentials	employee-74/1787254482_f43376c1.pdf	\N	2026-08-20 19:34:44.494018+00	2026-08-20 19:34:44.494018+00	2026-08-20 19:34:44.494018+00	{"eTag": "\\"c546570f74fc2d26e769bc35237532ff\\"", "size": 103003, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-08-20T19:34:45.000Z", "contentLength": 103003, "httpStatusCode": 200}	8c771ae2-a95b-4474-9729-2db60123fd30	\N	{}	\N	f	f
bb05a098-6586-43cb-bf77-8a78455dae65	credentials	employee-73/1788618794_3b21da3f.jpg	\N	2026-09-05 14:33:15.314279+00	2026-09-05 14:33:15.314279+00	2026-09-05 14:33:15.314279+00	{"eTag": "\\"a2a7768529e55306151cbad8df8c4ad1\\"", "size": 11814, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2026-09-05T14:33:16.000Z", "contentLength": 11814, "httpStatusCode": 200}	17602e3a-86ff-4b60-8e89-2f31061a30a6	\N	{}	\N	f	f
c211db0d-6d1a-41d1-8aec-10553eb036db	credentials	employee-85/wfh-monitoring/1788773171_1bcc225e.jpg	\N	2026-09-07 09:26:11.814604+00	2026-09-07 09:26:11.814604+00	2026-09-07 09:26:11.814604+00	{"eTag": "\\"d32f3953735725deb1e389811a560fda\\"", "size": 4179, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2026-09-07T09:26:12.000Z", "contentLength": 4179, "httpStatusCode": 200}	875d4636-5492-4587-9480-bb7eafdcbbfa	\N	{}	\N	f	f
0e526682-70d7-48eb-a16a-80d2a834e432	credentials	employee-87/1789831106_6ae81489.pdf	\N	2026-09-19 15:18:27.370343+00	2026-09-19 15:18:27.370343+00	2026-09-19 15:18:27.370343+00	{"eTag": "\\"3cf8311c03a83cd9e05dc1ba96edc938\\"", "size": 54064, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-09-19T15:18:28.000Z", "contentLength": 54064, "httpStatusCode": 200}	ce0eca51-b133-4ee8-83f5-7153dce0e05d	\N	{}	\N	f	f
3c8c319c-713a-4442-b1e9-3876644740d8	credentials	employee-87/wfh-monitoring/1789834160_4161572a.xlsx	\N	2026-09-19 16:09:21.062187+00	2026-09-19 16:09:21.062187+00	2026-09-19 16:09:21.062187+00	{"eTag": "\\"d3b4dfc622b79dafd86f786252b2437e\\"", "size": 9680, "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "cacheControl": "no-cache", "lastModified": "2026-09-19T16:09:22.000Z", "contentLength": 9680, "httpStatusCode": 200}	e0da2ec3-a905-4672-b425-2795729f3c11	\N	{}	\N	f	f
78639103-aec3-4d36-a5de-d4a185703682	credentials	employee-90/1789839527_72bceba7.pdf	\N	2026-09-19 17:38:47.817402+00	2026-09-19 17:38:47.817402+00	2026-09-19 17:38:47.817402+00	{"eTag": "\\"3cf8311c03a83cd9e05dc1ba96edc938\\"", "size": 54064, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-09-19T17:38:48.000Z", "contentLength": 54064, "httpStatusCode": 200}	ac0971ee-3498-48d9-86c0-dc9be2873a74	\N	{}	\N	f	f
97a92b66-f8f5-4668-9d18-583c2492f439	credentials	employee-90/1789839864_b3750420.pdf	\N	2026-09-19 17:44:25.263134+00	2026-09-19 17:44:25.263134+00	2026-09-19 17:44:25.263134+00	{"eTag": "\\"beb1d5b74286065289a07fa253098dad\\"", "size": 3819746, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-09-19T17:44:26.000Z", "contentLength": 3819746, "httpStatusCode": 200}	a0eb921f-aafb-4957-b49c-912c2d1ac118	\N	{}	\N	f	f
7f3ec5a2-ead2-4b5e-8de5-17d562ea3780	credentials	employee-91/wfh-monitoring/1790223757_8fe774e4.xlsx	\N	2026-09-24 04:22:37.79721+00	2026-09-24 04:22:37.79721+00	2026-09-24 04:22:37.79721+00	{"eTag": "\\"d3b4dfc622b79dafd86f786252b2437e\\"", "size": 9680, "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "cacheControl": "no-cache", "lastModified": "2026-09-24T04:22:38.000Z", "contentLength": 9680, "httpStatusCode": 200}	39340086-17a4-4290-9365-9cc8e0e69bce	\N	{}	\N	f	f
4ca6f63b-12e9-49e7-9047-1119bfcffdbb	credentials	employee-94/1790516147_6ce13180.pdf	\N	2026-09-27 13:35:48.120352+00	2026-09-27 13:35:48.120352+00	2026-09-27 13:35:48.120352+00	{"eTag": "\\"8eb830379217dccc73786971c52e0871\\"", "size": 207702, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-09-27T13:35:49.000Z", "contentLength": 207702, "httpStatusCode": 200}	9fe7e6ed-15c4-4c22-85d4-2e2ecf4b46b8	\N	{}	\N	f	f
da6a0540-5d45-4152-bd09-82003fff76d7	credentials	employee-94/wfh-monitoring/1790516293_72db8d3d.png	\N	2026-09-27 13:38:14.045965+00	2026-09-27 13:38:14.045965+00	2026-09-27 13:38:14.045965+00	{"eTag": "\\"4943e8e33adc2c5096c164e8bb8d264a\\"", "size": 388212, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-09-27T13:38:14.000Z", "contentLength": 388212, "httpStatusCode": 200}	414b8091-c6a3-4d32-9aa1-4df5c662a399	\N	{}	\N	f	f
dd3ea686-dd89-46ce-ab88-fc01bc888f70	credentials	employee-95/degrees/1791174817_5eb0c3a1.pdf	\N	2026-10-05 04:33:37.917714+00	2026-10-05 04:33:37.917714+00	2026-10-05 04:33:37.917714+00	{"eTag": "\\"90f6c0e0f24c26d977c4e56058392f57\\"", "size": 485048, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-10-05T04:33:38.000Z", "contentLength": 485048, "httpStatusCode": 200}	cf1be9b0-1056-4ead-96eb-ac26dccc1e63	\N	{}	\N	f	f
c43fa68f-74a4-45e7-86af-9b14b37eec17	credentials	employee-96/degrees/1791184622_84658fb7.pdf	\N	2026-10-05 07:17:02.755623+00	2026-10-05 07:17:02.755623+00	2026-10-05 07:17:02.755623+00	{"eTag": "\\"90f6c0e0f24c26d977c4e56058392f57\\"", "size": 485048, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-10-05T07:17:03.000Z", "contentLength": 485048, "httpStatusCode": 200}	b2c6b70a-c507-4318-99ff-963d3e96ab3a	\N	{}	\N	f	f
12d326e2-a6d3-4fda-a86a-3c27f2cd787c	credentials	employee-96/degrees/1791184634_ccfc2a6c.pdf	\N	2026-10-05 07:17:15.014137+00	2026-10-05 07:17:15.014137+00	2026-10-05 07:17:15.014137+00	{"eTag": "\\"cc88b194b5c20aea2f0c2fa823aaa9c7\\"", "size": 403578, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-10-05T07:17:15.000Z", "contentLength": 403578, "httpStatusCode": 200}	dd15da5e-7cd9-4d1b-9422-418d5c24a1bf	\N	{}	\N	f	f
e96fde25-e3b1-4dfd-986b-119bd4b42d46	credentials	employee-98/degrees/1791204094_3bb5b53b.pdf	\N	2026-10-05 12:41:35.339723+00	2026-10-05 12:41:35.339723+00	2026-10-05 12:41:35.339723+00	{"eTag": "\\"4feed0ccfd94a49432dd775112d910ce\\"", "size": 533609, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-10-05T12:41:36.000Z", "contentLength": 533609, "httpStatusCode": 200}	8f30efd2-915f-4649-9ba7-dd771c294fd1	\N	{}	\N	f	f
384d15c3-7efb-44c7-899a-4de8e8f94488	credentials	employee-95/degrees/1791312332_e2855b33.pdf	\N	2026-10-06 18:45:32.776891+00	2026-10-06 18:45:32.776891+00	2026-10-06 18:45:32.776891+00	{"eTag": "\\"cc88b194b5c20aea2f0c2fa823aaa9c7\\"", "size": 403578, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-10-06T18:45:33.000Z", "contentLength": 403578, "httpStatusCode": 200}	b58e97cf-7084-4a4b-a9d3-e75226c73831	\N	{}	\N	f	f
9cf38509-8057-4297-9faa-2b6c3d109ced	credentials	employee-95/degrees/1791317246_59f20add.pdf	\N	2026-10-06 20:07:27.061124+00	2026-10-06 20:07:27.061124+00	2026-10-06 20:07:27.061124+00	{"eTag": "\\"76037478a7ee77155fd9fba335bd4ff9\\"", "size": 892919, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-10-06T20:07:28.000Z", "contentLength": 892919, "httpStatusCode": 200}	938accd7-a532-46f9-99f0-571d4f5a1360	\N	{}	\N	f	f
2dce514e-0885-4c45-aed5-d2b3f0fa1642	credentials	employee-3/degrees/1791811477_0649da95.pdf	\N	2026-10-12 13:24:38.413685+00	2026-10-12 13:24:38.413685+00	2026-10-12 13:24:38.413685+00	{"eTag": "\\"8a530c02363bee24d9a66a4cc0c87dca\\"", "size": 49896, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-10-12T13:24:39.000Z", "contentLength": 49896, "httpStatusCode": 200}	d0cfc25a-2cb3-41bb-9ab6-f9a33c4472fe	\N	{}	\N	f	f
dcefd5b7-16ea-44ab-9975-04a006e63075	credentials	employee-3/degrees/1791811481_de946bf2.pdf	\N	2026-10-12 13:24:41.737734+00	2026-10-12 13:24:41.737734+00	2026-10-12 13:24:41.737734+00	{"eTag": "\\"017a52141ad049962e4dd63bfcaf8de6\\"", "size": 131534, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-10-12T13:24:42.000Z", "contentLength": 131534, "httpStatusCode": 200}	e19ced3c-f7db-4cab-b957-53429bb81f4c	\N	{}	\N	f	f
fade5661-4846-422f-824d-1fcc620946a2	credentials	employee-12/degrees/1791961297_8ddf4f21.pdf	\N	2026-10-14 07:01:38.281446+00	2026-10-14 07:01:38.281446+00	2026-10-14 07:01:38.281446+00	{"eTag": "\\"8a6b07c7fd3676cce165aea9051a56dc\\"", "size": 277851, "mimetype": "application/pdf", "cacheControl": "no-cache", "lastModified": "2026-10-14T07:01:39.000Z", "contentLength": 277851, "httpStatusCode": 200}	c2aaf7e4-e788-4e8f-bd80-7a7dbe35b695	\N	{}	\N	f	f
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata, metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.vector_indexes (id, name, bucket_id, data_type, dimension, distance_metric, metadata_configuration, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: -
--

COPY vault.secrets (id, name, description, secret, key_id, nonce, created_at, updated_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: -
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 255, true);


--
-- Name: academic_calendar_entries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.academic_calendar_entries_id_seq', 16, true);


--
-- Name: admin_audit_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.admin_audit_logs_id_seq', 1458, true);


--
-- Name: admin_configs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.admin_configs_id_seq', 1, false);


--
-- Name: announcement_notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.announcement_notifications_id_seq', 213, true);


--
-- Name: announcements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.announcements_id_seq', 177, true);


--
-- Name: attendance_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.attendance_records_id_seq', 1727, true);


--
-- Name: departments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.departments_id_seq', 8, true);


--
-- Name: employee_credentials_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.employee_credentials_id_seq', 3, true);


--
-- Name: employee_schedule_days_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.employee_schedule_days_id_seq', 510, true);


--
-- Name: employee_schedule_submissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.employee_schedule_submissions_id_seq', 77, true);


--
-- Name: employees_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.employees_id_seq', 230, true);


--
-- Name: extraction_validation_runs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.extraction_validation_runs_id_seq', 1, false);


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.failed_jobs_id_seq', 3, true);


--
-- Name: jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.jobs_id_seq', 10, true);


--
-- Name: leave_balances_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.leave_balances_id_seq', 312, true);


--
-- Name: leave_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.leave_requests_id_seq', 572, true);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.migrations_id_seq', 42, true);


--
-- Name: privacy_notice_acknowledgments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.privacy_notice_acknowledgments_id_seq', 18, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 270, true);


--
-- Name: wfh_monitoring_submissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.wfh_monitoring_submissions_id_seq', 1, true);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: -
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 13, true);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: custom_oauth_providers custom_oauth_providers_identifier_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_identifier_key UNIQUE (identifier);


--
-- Name: custom_oauth_providers custom_oauth_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: mfa_recovery_code_sets mfa_recovery_code_sets_mfa_factor_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_recovery_code_sets
    ADD CONSTRAINT mfa_recovery_code_sets_mfa_factor_id_key UNIQUE (mfa_factor_id);


--
-- Name: mfa_recovery_code_sets mfa_recovery_code_sets_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_recovery_code_sets
    ADD CONSTRAINT mfa_recovery_code_sets_pkey PRIMARY KEY (id);


--
-- Name: mfa_recovery_code_sets mfa_recovery_code_sets_user_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_recovery_code_sets
    ADD CONSTRAINT mfa_recovery_code_sets_user_id_key UNIQUE (user_id);


--
-- Name: mfa_recovery_codes mfa_recovery_codes_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_recovery_codes
    ADD CONSTRAINT mfa_recovery_codes_pkey PRIMARY KEY (id);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_code_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_code_key UNIQUE (authorization_code);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_id_key UNIQUE (authorization_id);


--
-- Name: oauth_authorizations oauth_authorizations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_pkey PRIMARY KEY (id);


--
-- Name: oauth_client_states oauth_client_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_client_states
    ADD CONSTRAINT oauth_client_states_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_user_client_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_client_unique UNIQUE (user_id, client_id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: scim_tokens scim_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.scim_tokens
    ADD CONSTRAINT scim_tokens_pkey PRIMARY KEY (id);


--
-- Name: scim_users scim_users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.scim_users
    ADD CONSTRAINT scim_users_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: webauthn_challenges webauthn_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_challenges
    ADD CONSTRAINT webauthn_challenges_pkey PRIMARY KEY (id);


--
-- Name: webauthn_credentials webauthn_credentials_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_pkey PRIMARY KEY (id);


--
-- Name: academic_calendar_entries academic_calendar_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.academic_calendar_entries
    ADD CONSTRAINT academic_calendar_entries_pkey PRIMARY KEY (id);


--
-- Name: admin_audit_logs admin_audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_audit_logs
    ADD CONSTRAINT admin_audit_logs_pkey PRIMARY KEY (id);


--
-- Name: admin_configs admin_configs_key_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_configs
    ADD CONSTRAINT admin_configs_key_unique UNIQUE (key);


--
-- Name: admin_configs admin_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_configs
    ADD CONSTRAINT admin_configs_pkey PRIMARY KEY (id);


--
-- Name: announcement_notifications announcement_notifications_announcement_id_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcement_notifications
    ADD CONSTRAINT announcement_notifications_announcement_id_user_id_unique UNIQUE (announcement_id, user_id);


--
-- Name: announcement_notifications announcement_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcement_notifications
    ADD CONSTRAINT announcement_notifications_pkey PRIMARY KEY (id);


--
-- Name: announcements announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);


--
-- Name: attendance_records attendance_records_employee_id_record_date_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance_records
    ADD CONSTRAINT attendance_records_employee_id_record_date_unique UNIQUE (employee_id, record_date);


--
-- Name: attendance_records attendance_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance_records
    ADD CONSTRAINT attendance_records_pkey PRIMARY KEY (id);


--
-- Name: cache_locks cache_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cache_locks
    ADD CONSTRAINT cache_locks_pkey PRIMARY KEY (key);


--
-- Name: cache cache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cache
    ADD CONSTRAINT cache_pkey PRIMARY KEY (key);


--
-- Name: departments departments_name_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_name_unique UNIQUE (name);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: employee_credentials employee_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_credentials
    ADD CONSTRAINT employee_credentials_pkey PRIMARY KEY (id);


--
-- Name: employee_schedule_days employee_schedule_days_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_schedule_days
    ADD CONSTRAINT employee_schedule_days_pkey PRIMARY KEY (id);


--
-- Name: employee_schedule_days employee_schedule_days_schedule_submission_id_day_index_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_schedule_days
    ADD CONSTRAINT employee_schedule_days_schedule_submission_id_day_index_unique UNIQUE (schedule_submission_id, day_index);


--
-- Name: employee_schedule_submissions employee_schedule_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_schedule_submissions
    ADD CONSTRAINT employee_schedule_submissions_pkey PRIMARY KEY (id);


--
-- Name: employees employees_email_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_email_unique UNIQUE (email);


--
-- Name: employees employees_employee_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_employee_id_unique UNIQUE (employee_id);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- Name: extraction_validation_runs extraction_validation_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.extraction_validation_runs
    ADD CONSTRAINT extraction_validation_runs_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (uuid);


--
-- Name: job_batches job_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_batches
    ADD CONSTRAINT job_batches_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: leave_balances leave_balances_employee_id_leave_type_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leave_balances
    ADD CONSTRAINT leave_balances_employee_id_leave_type_unique UNIQUE (employee_id, leave_type);


--
-- Name: leave_balances leave_balances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leave_balances
    ADD CONSTRAINT leave_balances_pkey PRIMARY KEY (id);


--
-- Name: leave_import_runs leave_import_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leave_import_runs
    ADD CONSTRAINT leave_import_runs_pkey PRIMARY KEY (id);


--
-- Name: leave_requests leave_requests_employee_id_source_leave_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_employee_id_source_leave_id_unique UNIQUE (employee_id, source_leave_id);


--
-- Name: leave_requests leave_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (email);


--
-- Name: privacy_notice_acknowledgments privacy_notice_acknowledgments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.privacy_notice_acknowledgments
    ADD CONSTRAINT privacy_notice_acknowledgments_pkey PRIMARY KEY (id);


--
-- Name: privacy_notice_acknowledgments privacy_notice_acknowledgments_user_id_privacy_notice_version_u; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.privacy_notice_acknowledgments
    ADD CONSTRAINT privacy_notice_acknowledgments_user_id_privacy_notice_version_u UNIQUE (user_id, privacy_notice_version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: wfh_monitoring_submissions wfh_monitoring_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wfh_monitoring_submissions
    ADD CONSTRAINT wfh_monitoring_submissions_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_10_11 messages_2026_10_11_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2026_10_11
    ADD CONSTRAINT messages_2026_10_11_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_10_12 messages_2026_10_12_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2026_10_12
    ADD CONSTRAINT messages_2026_10_12_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_10_13 messages_2026_10_13_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2026_10_13
    ADD CONSTRAINT messages_2026_10_13_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_10_14 messages_2026_10_14_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2026_10_14
    ADD CONSTRAINT messages_2026_10_14_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_10_15 messages_2026_10_15_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2026_10_15
    ADD CONSTRAINT messages_2026_10_15_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_10_16 messages_2026_10_16_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2026_10_16
    ADD CONSTRAINT messages_2026_10_16_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2026_10_17 messages_2026_10_17_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages_2026_10_17
    ADD CONSTRAINT messages_2026_10_17_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages messages_payload_exclusive; Type: CHECK CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages
    ADD CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL))) NOT VALID;


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: bucket_lifecycle_states bucket_lifecycle_states_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.bucket_lifecycle_states
    ADD CONSTRAINT bucket_lifecycle_states_pkey PRIMARY KEY (bucket_id);


--
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: buckets_vectors buckets_vectors_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_vectors
    ADD CONSTRAINT buckets_vectors_pkey PRIMARY KEY (id);


--
-- Name: lifecycle_abandoned_artifacts lifecycle_abandoned_artifacts_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.lifecycle_abandoned_artifacts
    ADD CONSTRAINT lifecycle_abandoned_artifacts_pkey PRIMARY KEY (bucket_id, key);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: vector_indexes vector_indexes_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_pkey PRIMARY KEY (id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: custom_oauth_providers_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_created_at_idx ON auth.custom_oauth_providers USING btree (created_at);


--
-- Name: custom_oauth_providers_enabled_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_enabled_idx ON auth.custom_oauth_providers USING btree (enabled);


--
-- Name: custom_oauth_providers_identifier_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_identifier_idx ON auth.custom_oauth_providers USING btree (identifier);


--
-- Name: custom_oauth_providers_provider_type_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_provider_type_idx ON auth.custom_oauth_providers USING btree (provider_type);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_oauth_client_states_created_at; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_oauth_client_states_created_at ON auth.oauth_client_states USING btree (created_at);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: mfa_recovery_codes_set_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_recovery_codes_set_id_idx ON auth.mfa_recovery_codes USING btree (mfa_recovery_code_set_id);


--
-- Name: oauth_auth_pending_exp_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_auth_pending_exp_idx ON auth.oauth_authorizations USING btree (expires_at) WHERE (status = 'pending'::auth.oauth_authorization_status);


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- Name: oauth_consents_active_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_client_idx ON auth.oauth_consents USING btree (client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_active_user_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_user_client_idx ON auth.oauth_consents USING btree (user_id, client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_user_order_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_user_order_idx ON auth.oauth_consents USING btree (user_id, granted_at DESC);


--
-- Name: one_time_tokens_link_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_link_token_hash_hash_idx ON auth.one_time_tokens USING hash (link_token_hash);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: scim_tokens_expires_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_tokens_expires_at_idx ON auth.scim_tokens USING btree (expires_at);


--
-- Name: scim_tokens_revoked_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_tokens_revoked_at_idx ON auth.scim_tokens USING btree (revoked_at);


--
-- Name: scim_tokens_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_tokens_sso_provider_id_idx ON auth.scim_tokens USING btree (sso_provider_id);


--
-- Name: scim_tokens_token_hash_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX scim_tokens_token_hash_key ON auth.scim_tokens USING btree (token_hash);


--
-- Name: scim_users_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_users_created_at_idx ON auth.scim_users USING btree (sso_provider_id, created_at, id) WHERE (deleted_at IS NULL);


--
-- Name: scim_users_deleted_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_users_deleted_at_idx ON auth.scim_users USING btree (deleted_at);


--
-- Name: scim_users_external_id_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX scim_users_external_id_key ON auth.scim_users USING btree (sso_provider_id, external_id) WHERE ((external_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: scim_users_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_users_id_idx ON auth.scim_users USING btree (sso_provider_id, id) WHERE (deleted_at IS NULL);


--
-- Name: scim_users_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_users_sso_provider_id_idx ON auth.scim_users USING btree (sso_provider_id);


--
-- Name: scim_users_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_users_updated_at_idx ON auth.scim_users USING btree (sso_provider_id, updated_at, id) WHERE (deleted_at IS NULL);


--
-- Name: scim_users_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_users_user_id_idx ON auth.scim_users USING btree (user_id);


--
-- Name: scim_users_user_name_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX scim_users_user_name_idx ON auth.scim_users USING btree (sso_provider_id, user_name COLLATE "C", id) WHERE (deleted_at IS NULL);


--
-- Name: scim_users_user_name_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX scim_users_user_name_key ON auth.scim_users USING btree (sso_provider_id, user_name) WHERE (deleted_at IS NULL);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_oauth_client_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_oauth_client_id_idx ON auth.sessions USING btree (oauth_client_id);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: webauthn_challenges_expires_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_challenges_expires_at_idx ON auth.webauthn_challenges USING btree (expires_at);


--
-- Name: webauthn_challenges_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_challenges_user_id_idx ON auth.webauthn_challenges USING btree (user_id);


--
-- Name: webauthn_credentials_credential_id_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX webauthn_credentials_credential_id_key ON auth.webauthn_credentials USING btree (credential_id);


--
-- Name: webauthn_credentials_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_credentials_user_id_idx ON auth.webauthn_credentials USING btree (user_id);


--
-- Name: academic_calendar_entries_entry_type_event_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX academic_calendar_entries_entry_type_event_date_index ON public.academic_calendar_entries USING btree (entry_type, event_date);


--
-- Name: admin_audit_logs_module_created_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX admin_audit_logs_module_created_at_index ON public.admin_audit_logs USING btree (module, created_at);


--
-- Name: admin_audit_logs_status_created_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX admin_audit_logs_status_created_at_index ON public.admin_audit_logs USING btree (status, created_at);


--
-- Name: announcements_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX announcements_type_index ON public.announcements USING btree (type);


--
-- Name: cache_expiration_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cache_expiration_index ON public.cache USING btree (expiration);


--
-- Name: cache_locks_expiration_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cache_locks_expiration_index ON public.cache_locks USING btree (expiration);


--
-- Name: employee_credentials_employee_id_credential_type_degree_level_i; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX employee_credentials_employee_id_credential_type_degree_level_i ON public.employee_credentials USING btree (employee_id, credential_type, degree_level);


--
-- Name: employee_schedule_submissions_employee_id_is_current_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX employee_schedule_submissions_employee_id_is_current_index ON public.employee_schedule_submissions USING btree (employee_id, is_current);


--
-- Name: employee_schedule_submissions_employee_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX employee_schedule_submissions_employee_id_status_index ON public.employee_schedule_submissions USING btree (employee_id, status);


--
-- Name: employees_resume_updated_deleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX employees_resume_updated_deleted_idx ON public.employees USING btree (resume_last_updated_at, deleted_at);


--
-- Name: employees_status_deleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX employees_status_deleted_idx ON public.employees USING btree (status, deleted_at);


--
-- Name: jobs_queue_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX jobs_queue_index ON public.jobs USING btree (queue);


--
-- Name: sessions_last_activity_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sessions_last_activity_index ON public.sessions USING btree (last_activity);


--
-- Name: sessions_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sessions_user_id_index ON public.sessions USING btree (user_id);


--
-- Name: sessions_user_id_last_activity_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sessions_user_id_last_activity_index ON public.sessions USING btree (user_id, last_activity);


--
-- Name: wfh_monitoring_submissions_employee_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX wfh_monitoring_submissions_employee_id_status_index ON public.wfh_monitoring_submissions USING btree (employee_id, status);


--
-- Name: wfh_monitoring_submissions_employee_id_wfh_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX wfh_monitoring_submissions_employee_id_wfh_date_index ON public.wfh_monitoring_submissions USING btree (employee_id, wfh_date);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: messages_replay_index; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_replay_index ON ONLY realtime.messages USING btree (topic, inserted_at DESC, COALESCE(expires_at, 'infinity'::timestamp without time zone)) WHERE ((extension = 'broadcast'::text) AND (private = true));


--
-- Name: messages_2026_10_11_topic_inserted_at_coalesce_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2026_10_11_topic_inserted_at_coalesce_idx ON realtime.messages_2026_10_11 USING btree (topic, inserted_at DESC, COALESCE(expires_at, 'infinity'::timestamp without time zone)) WHERE ((extension = 'broadcast'::text) AND (private = true));


--
-- Name: messages_2026_10_12_topic_inserted_at_coalesce_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2026_10_12_topic_inserted_at_coalesce_idx ON realtime.messages_2026_10_12 USING btree (topic, inserted_at DESC, COALESCE(expires_at, 'infinity'::timestamp without time zone)) WHERE ((extension = 'broadcast'::text) AND (private = true));


--
-- Name: messages_2026_10_13_topic_inserted_at_coalesce_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2026_10_13_topic_inserted_at_coalesce_idx ON realtime.messages_2026_10_13 USING btree (topic, inserted_at DESC, COALESCE(expires_at, 'infinity'::timestamp without time zone)) WHERE ((extension = 'broadcast'::text) AND (private = true));


--
-- Name: messages_2026_10_14_topic_inserted_at_coalesce_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2026_10_14_topic_inserted_at_coalesce_idx ON realtime.messages_2026_10_14 USING btree (topic, inserted_at DESC, COALESCE(expires_at, 'infinity'::timestamp without time zone)) WHERE ((extension = 'broadcast'::text) AND (private = true));


--
-- Name: messages_2026_10_15_topic_inserted_at_coalesce_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2026_10_15_topic_inserted_at_coalesce_idx ON realtime.messages_2026_10_15 USING btree (topic, inserted_at DESC, COALESCE(expires_at, 'infinity'::timestamp without time zone)) WHERE ((extension = 'broadcast'::text) AND (private = true));


--
-- Name: messages_2026_10_16_topic_inserted_at_coalesce_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2026_10_16_topic_inserted_at_coalesce_idx ON realtime.messages_2026_10_16 USING btree (topic, inserted_at DESC, COALESCE(expires_at, 'infinity'::timestamp without time zone)) WHERE ((extension = 'broadcast'::text) AND (private = true));


--
-- Name: messages_2026_10_17_topic_inserted_at_coalesce_idx; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_2026_10_17_topic_inserted_at_coalesce_idx ON realtime.messages_2026_10_17 USING btree (topic, inserted_at DESC, COALESCE(expires_at, 'infinity'::timestamp without time zone)) WHERE ((extension = 'broadcast'::text) AND (private = true));


--
-- Name: subscription_subscription_id_entity_filters_hash_key; Type: INDEX; Schema: realtime; Owner: -
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_hash_key ON realtime.subscription USING btree (subscription_id, entity, realtime.filters_hash(filters), action_filter, COALESCE(selected_columns, '{}'::text[]));


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucket_lifecycle_states_due_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX bucket_lifecycle_states_due_idx ON storage.bucket_lifecycle_states USING btree (next_run_at, bucket_id) WHERE (next_run_at IS NOT NULL);


--
-- Name: buckets_analytics_unique_name_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX buckets_analytics_unique_name_idx ON storage.buckets_analytics USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_multipart_uploads_parts_upload_part; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_multipart_uploads_parts_upload_part ON storage.s3_multipart_uploads_parts USING btree (upload_id, part_number);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: idx_objects_current_version; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX idx_objects_current_version ON storage.objects USING btree (bucket_id, name COLLATE "C") WHERE (archived_at IS NULL);


--
-- Name: idx_objects_delete_markers; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_delete_markers ON storage.objects USING btree (bucket_id, name COLLATE "C") WHERE is_delete_marker;


--
-- Name: idx_objects_null_version; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX idx_objects_null_version ON storage.objects USING btree (bucket_id, name COLLATE "C") WHERE (NOT is_versioned);


--
-- Name: lifecycle_abandoned_artifacts_attempted_at_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX lifecycle_abandoned_artifacts_attempted_at_idx ON storage.lifecycle_abandoned_artifacts USING btree (attempted_at);


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: objects_archived_due_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX objects_archived_due_idx ON storage.objects USING btree (bucket_id, archived_at, name COLLATE "C") INCLUDE (id, version, is_delete_marker) WHERE (archived_at IS NOT NULL);


--
-- Name: objects_archived_order_uq; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX objects_archived_order_uq ON storage.objects USING btree (bucket_id, name COLLATE "C", archived_at) WHERE (archived_at IS NOT NULL);


--
-- Name: objects_bucket_id_name_version_key; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX objects_bucket_id_name_version_key ON storage.objects USING btree (bucket_id, name COLLATE "C", version) NULLS NOT DISTINCT;


--
-- Name: vector_indexes_name_bucket_id_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX vector_indexes_name_bucket_id_idx ON storage.vector_indexes USING btree (name, bucket_id);


--
-- Name: messages_2026_10_11_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_10_11_pkey;


--
-- Name: messages_2026_10_11_topic_inserted_at_coalesce_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_replay_index ATTACH PARTITION realtime.messages_2026_10_11_topic_inserted_at_coalesce_idx;


--
-- Name: messages_2026_10_12_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_10_12_pkey;


--
-- Name: messages_2026_10_12_topic_inserted_at_coalesce_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_replay_index ATTACH PARTITION realtime.messages_2026_10_12_topic_inserted_at_coalesce_idx;


--
-- Name: messages_2026_10_13_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_10_13_pkey;


--
-- Name: messages_2026_10_13_topic_inserted_at_coalesce_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_replay_index ATTACH PARTITION realtime.messages_2026_10_13_topic_inserted_at_coalesce_idx;


--
-- Name: messages_2026_10_14_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_10_14_pkey;


--
-- Name: messages_2026_10_14_topic_inserted_at_coalesce_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_replay_index ATTACH PARTITION realtime.messages_2026_10_14_topic_inserted_at_coalesce_idx;


--
-- Name: messages_2026_10_15_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_10_15_pkey;


--
-- Name: messages_2026_10_15_topic_inserted_at_coalesce_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_replay_index ATTACH PARTITION realtime.messages_2026_10_15_topic_inserted_at_coalesce_idx;


--
-- Name: messages_2026_10_16_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_10_16_pkey;


--
-- Name: messages_2026_10_16_topic_inserted_at_coalesce_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_replay_index ATTACH PARTITION realtime.messages_2026_10_16_topic_inserted_at_coalesce_idx;


--
-- Name: messages_2026_10_17_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_10_17_pkey;


--
-- Name: messages_2026_10_17_topic_inserted_at_coalesce_idx; Type: INDEX ATTACH; Schema: realtime; Owner: -
--

ALTER INDEX realtime.messages_replay_index ATTACH PARTITION realtime.messages_2026_10_17_topic_inserted_at_coalesce_idx;


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: -
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();


--
-- Name: buckets enforce_versioning_status_transition; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER enforce_versioning_status_transition BEFORE UPDATE OF versioning_status ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_versioning_status_transition();


--
-- Name: buckets protect_active_lifecycle_states; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_active_lifecycle_states BEFORE DELETE ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.protect_active_lifecycle_states();


--
-- Name: buckets protect_bucket_control_insert; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_bucket_control_insert BEFORE INSERT ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.protect_bucket_control_columns('service_role');


--
-- Name: buckets protect_bucket_control_update; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_bucket_control_update BEFORE UPDATE OF lifecycle_configuration, lifecycle_configuration_generation ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.protect_bucket_control_columns();


--
-- Name: buckets protect_bucket_control_update_role; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_bucket_control_update_role AFTER UPDATE OF lifecycle_configuration, lifecycle_configuration_generation ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_lifecycle_service_role('service_role');


--
-- Name: buckets protect_buckets_delete; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_buckets_delete BEFORE DELETE ON storage.buckets FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();


--
-- Name: objects protect_objects_delete; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_objects_delete BEFORE DELETE ON storage.objects FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: buckets wake_lifecycle_on_policy_write; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER wake_lifecycle_on_policy_write AFTER INSERT OR UPDATE OF lifecycle_configuration_generation ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.wake_lifecycle_state();


--
-- Name: buckets wake_lifecycle_on_versioning_enable; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER wake_lifecycle_on_versioning_enable AFTER UPDATE OF versioning_status ON storage.buckets FOR EACH ROW WHEN ((new.lifecycle_configuration IS NOT NULL)) EXECUTE FUNCTION storage.wake_lifecycle_state();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_recovery_code_sets mfa_recovery_code_sets_mfa_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_recovery_code_sets
    ADD CONSTRAINT mfa_recovery_code_sets_mfa_factor_id_fkey FOREIGN KEY (mfa_factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_recovery_code_sets mfa_recovery_code_sets_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_recovery_code_sets
    ADD CONSTRAINT mfa_recovery_code_sets_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_recovery_codes mfa_recovery_codes_mfa_recovery_code_set_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_recovery_codes
    ADD CONSTRAINT mfa_recovery_codes_mfa_recovery_code_set_id_fkey FOREIGN KEY (mfa_recovery_code_set_id) REFERENCES auth.mfa_recovery_code_sets(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: scim_tokens scim_tokens_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.scim_tokens
    ADD CONSTRAINT scim_tokens_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: scim_users scim_users_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.scim_users
    ADD CONSTRAINT scim_users_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: scim_users scim_users_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.scim_users
    ADD CONSTRAINT scim_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: sessions sessions_oauth_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_oauth_client_id_fkey FOREIGN KEY (oauth_client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: webauthn_challenges webauthn_challenges_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_challenges
    ADD CONSTRAINT webauthn_challenges_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: webauthn_credentials webauthn_credentials_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: admin_audit_logs admin_audit_logs_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_audit_logs
    ADD CONSTRAINT admin_audit_logs_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: announcement_notifications announcement_notifications_announcement_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcement_notifications
    ADD CONSTRAINT announcement_notifications_announcement_id_foreign FOREIGN KEY (announcement_id) REFERENCES public.announcements(id) ON DELETE CASCADE;


--
-- Name: announcement_notifications announcement_notifications_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcement_notifications
    ADD CONSTRAINT announcement_notifications_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: announcements announcements_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: announcements announcements_target_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_target_department_id_foreign FOREIGN KEY (target_department_id) REFERENCES public.departments(id) ON DELETE SET NULL;


--
-- Name: announcements announcements_target_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_target_user_id_foreign FOREIGN KEY (target_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: attendance_records attendance_records_employee_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance_records
    ADD CONSTRAINT attendance_records_employee_id_foreign FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- Name: employee_credentials employee_credentials_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_credentials
    ADD CONSTRAINT employee_credentials_department_id_foreign FOREIGN KEY (department_id) REFERENCES public.departments(id) ON DELETE SET NULL;


--
-- Name: employee_credentials employee_credentials_employee_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_credentials
    ADD CONSTRAINT employee_credentials_employee_id_foreign FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- Name: employee_credentials employee_credentials_reviewed_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_credentials
    ADD CONSTRAINT employee_credentials_reviewed_by_foreign FOREIGN KEY (reviewed_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: employee_schedule_days employee_schedule_days_schedule_submission_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_schedule_days
    ADD CONSTRAINT employee_schedule_days_schedule_submission_id_foreign FOREIGN KEY (schedule_submission_id) REFERENCES public.employee_schedule_submissions(id) ON DELETE CASCADE;


--
-- Name: employee_schedule_submissions employee_schedule_submissions_employee_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_schedule_submissions
    ADD CONSTRAINT employee_schedule_submissions_employee_id_foreign FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- Name: employee_schedule_submissions employee_schedule_submissions_reviewed_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_schedule_submissions
    ADD CONSTRAINT employee_schedule_submissions_reviewed_by_foreign FOREIGN KEY (reviewed_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: employee_schedule_submissions employee_schedule_submissions_submitted_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employee_schedule_submissions
    ADD CONSTRAINT employee_schedule_submissions_submitted_by_foreign FOREIGN KEY (submitted_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: employees employees_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_department_id_foreign FOREIGN KEY (department_id) REFERENCES public.departments(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: extraction_validation_runs extraction_validation_runs_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.extraction_validation_runs
    ADD CONSTRAINT extraction_validation_runs_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: leave_balances leave_balances_employee_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leave_balances
    ADD CONSTRAINT leave_balances_employee_id_foreign FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- Name: leave_import_runs leave_import_runs_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leave_import_runs
    ADD CONSTRAINT leave_import_runs_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: leave_requests leave_requests_employee_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_employee_id_foreign FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- Name: privacy_notice_acknowledgments privacy_notice_acknowledgments_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.privacy_notice_acknowledgments
    ADD CONSTRAINT privacy_notice_acknowledgments_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: wfh_monitoring_submissions wfh_monitoring_submissions_employee_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wfh_monitoring_submissions
    ADD CONSTRAINT wfh_monitoring_submissions_employee_id_foreign FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- Name: wfh_monitoring_submissions wfh_monitoring_submissions_reviewed_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wfh_monitoring_submissions
    ADD CONSTRAINT wfh_monitoring_submissions_reviewed_by_foreign FOREIGN KEY (reviewed_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: wfh_monitoring_submissions wfh_monitoring_submissions_submitted_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wfh_monitoring_submissions
    ADD CONSTRAINT wfh_monitoring_submissions_submitted_by_foreign FOREIGN KEY (submitted_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: bucket_lifecycle_states bucket_lifecycle_states_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.bucket_lifecycle_states
    ADD CONSTRAINT bucket_lifecycle_states_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id) ON DELETE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: vector_indexes vector_indexes_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets_vectors(id);


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: objects Allow users to view profile images; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "Allow users to view profile images" ON storage.objects FOR SELECT TO authenticated USING (((auth.uid())::text = (storage.foldername(name))[1]));


--
-- Name: objects Allow users upload to their own folder; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "Allow users upload to their own folder" ON storage.objects FOR INSERT TO authenticated WITH CHECK (((auth.uid())::text = (storage.foldername(name))[1]));


--
-- Name: objects allow_insert_own_auth_uid; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY allow_insert_own_auth_uid ON storage.objects FOR INSERT TO authenticated WITH CHECK (((auth.role() = 'authenticated'::text) AND ("left"(name, length((auth.uid())::text)) = (auth.uid())::text)));


--
-- Name: bucket_lifecycle_states; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.bucket_lifecycle_states ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_vectors; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_vectors ENABLE ROW LEVEL SECURITY;

--
-- Name: objects employees_can_read_credentials_files; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY employees_can_read_credentials_files ON storage.objects FOR SELECT TO authenticated USING ((bucket_id = 'credentials'::text));


--
-- Name: objects employees_can_upload_credentials_files; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY employees_can_upload_credentials_files ON storage.objects FOR INSERT TO authenticated WITH CHECK (((bucket_id = 'credentials'::text) AND (((storage.foldername(name))[1] ~~ 'employee-%'::text) OR ((storage.foldername(name))[1] ~~ 'user-%'::text))));


--
-- Name: lifecycle_abandoned_artifacts; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.lifecycle_abandoned_artifacts ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: vector_indexes; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.vector_indexes ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: -
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


--
-- Name: supabase_realtime_messages_publication; Type: PUBLICATION; Schema: -; Owner: -
--

CREATE PUBLICATION supabase_realtime_messages_publication WITH (publish = 'insert, update, delete, truncate');


--
-- Name: supabase_realtime_messages_publication messages; Type: PUBLICATION TABLE; Schema: realtime; Owner: -
--

ALTER PUBLICATION supabase_realtime_messages_publication ADD TABLE ONLY realtime.messages;


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


--
-- PostgreSQL database dump complete
--

\unrestrict ZgZxVztKBop0bZJoftzmUK46J2yduH7159HEwBBMuUdJzGWfWB1X1IhOqqQOmIH


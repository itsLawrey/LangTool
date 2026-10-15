-- Cloud copies of each user's language packs and entries, synced from the
-- app's local database.
--
-- Sync model:
-- * Clients generate ids and timestamps. `updated_at` is the client's edit
--   time and decides which version wins (last write wins).
-- * Rows are never hard-deleted by clients; `deleted_at` marks a deletion so
--   it can reach other devices.
-- * `server_updated_at` is set by the server on every accepted write. Clients
--   pull changes ordered by it, so device clock skew cannot hide changes.

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

-- Language packs ----------------------------------------------------------

create table public.language_packs (
  id uuid primary key,
  owner_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  name text not null check (length(btrim(name)) > 0),
  language_code text not null check (language_code <> ''),
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  server_updated_at timestamptz not null default clock_timestamp()
);

comment on table public.language_packs is
  'User-named collections of dictionary entries, synced from devices.';

-- Pull query: owner_id = ? and server_updated_at > ? order by server_updated_at, id
create index language_packs_owner_server_updated_idx
  on public.language_packs (owner_id, server_updated_at, id);

-- Entries -----------------------------------------------------------------

create table public.entries (
  id uuid primary key,
  owner_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  pack_id uuid not null
    references public.language_packs (id) on delete cascade,
  word_type text not null check (
    word_type in (
      'noun', 'verb', 'adjective', 'adverb', 'phrase',
      'preposition', 'conjunction', 'pronoun', 'other'
    )
  ),
  term text not null,
  forms jsonb not null default '{}' check (jsonb_typeof(forms) = 'object'),
  translations jsonb not null default '[]'
    check (jsonb_typeof(translations) = 'array'),
  examples jsonb not null default '[]' check (jsonb_typeof(examples) = 'array'),
  tags jsonb not null default '[]' check (jsonb_typeof(tags) = 'array'),
  notes text,
  schema_version integer not null check (schema_version > 0),
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  server_updated_at timestamptz not null default clock_timestamp()
);

comment on table public.entries is
  'Dictionary entries of a language pack, synced from devices.';

create index entries_owner_server_updated_idx
  on public.entries (owner_id, server_updated_at, id);

-- Foreign key lookups (pack deletion cascade).
create index entries_pack_id_idx on public.entries (pack_id);

-- Write rules -------------------------------------------------------------

-- Stamps server_updated_at, keeps owner_id and created_at immutable, and
-- drops updates that carry an older edit than the stored row (last write
-- wins even when devices sync concurrently or out of order).
create function private.apply_sync_write()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE' then
    if new.updated_at < old.updated_at then
      return null;
    end if;
    new.owner_id := old.owner_id;
    new.created_at := old.created_at;
  end if;
  new.server_updated_at := clock_timestamp();
  return new;
end;
$$;

create trigger language_packs_apply_sync_write
  before insert or update on public.language_packs
  for each row execute function private.apply_sync_write();

create trigger entries_apply_sync_write
  before insert or update on public.entries
  for each row execute function private.apply_sync_write();

-- Access ------------------------------------------------------------------

-- Only signed-in users, and no hard deletes from clients.
revoke all on public.language_packs, public.entries from anon, authenticated;
grant select, insert, update
  on public.language_packs, public.entries to authenticated;

alter table public.language_packs enable row level security;
alter table public.entries enable row level security;

create policy "Users read their own packs"
  on public.language_packs for select to authenticated
  using ((select auth.uid()) = owner_id);

create policy "Users add their own packs"
  on public.language_packs for insert to authenticated
  with check ((select auth.uid()) = owner_id);

create policy "Users update their own packs"
  on public.language_packs for update to authenticated
  using ((select auth.uid()) = owner_id)
  with check ((select auth.uid()) = owner_id);

create policy "Users read their own entries"
  on public.entries for select to authenticated
  using ((select auth.uid()) = owner_id);

-- Entries may only be placed in the user's own packs.
create policy "Users add entries to their own packs"
  on public.entries for insert to authenticated
  with check (
    (select auth.uid()) = owner_id
    and exists (
      select 1 from public.language_packs p
      where p.id = pack_id and p.owner_id = (select auth.uid())
    )
  );

create policy "Users update entries in their own packs"
  on public.entries for update to authenticated
  using ((select auth.uid()) = owner_id)
  with check (
    (select auth.uid()) = owner_id
    and exists (
      select 1 from public.language_packs p
      where p.id = pack_id and p.owner_id = (select auth.uid())
    )
  );

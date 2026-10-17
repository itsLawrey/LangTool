-- Cloud copies of each user's recap decks, synced from the app's local
-- database with the same model as packs and entries (see
-- 20261015154844_create_sync_tables.sql).
--
-- A deck stores only its filter rules (`filters`, a JSON array of objects
-- with a `type` discriminator); the entries it selects are resolved on the
-- device. Unknown filter types are stored as they are, so data written by a
-- newer app version survives.

create table public.decks (
  id uuid primary key,
  owner_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  pack_id uuid not null
    references public.language_packs (id) on delete cascade,
  name text not null check (length(btrim(name)) > 0),
  filters jsonb not null default '[]' check (jsonb_typeof(filters) = 'array'),
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  server_updated_at timestamptz not null default clock_timestamp()
);

comment on table public.decks is
  'Recap decks of a language pack (filter rules over its entries), synced from devices.';

-- Pull query: owner_id = ? and server_updated_at > ? order by server_updated_at, id
create index decks_owner_server_updated_idx
  on public.decks (owner_id, server_updated_at, id);

-- Foreign key lookups (pack deletion cascade).
create index decks_pack_id_idx on public.decks (pack_id);

-- Write rules -------------------------------------------------------------

create trigger decks_apply_sync_write
  before insert or update on public.decks
  for each row execute function private.apply_sync_write();

-- Access ------------------------------------------------------------------

-- Only signed-in users, and no hard deletes from clients.
revoke all on public.decks from anon, authenticated;
grant select, insert, update on public.decks to authenticated;

alter table public.decks enable row level security;

create policy "Users read their own decks"
  on public.decks for select to authenticated
  using ((select auth.uid()) = owner_id);

-- Decks may only be placed in the user's own packs.
create policy "Users add decks to their own packs"
  on public.decks for insert to authenticated
  with check (
    (select auth.uid()) = owner_id
    and exists (
      select 1 from public.language_packs p
      where p.id = pack_id and p.owner_id = (select auth.uid())
    )
  );

create policy "Users update decks in their own packs"
  on public.decks for update to authenticated
  using ((select auth.uid()) = owner_id)
  with check (
    (select auth.uid()) = owner_id
    and exists (
      select 1 from public.language_packs p
      where p.id = pack_id and p.owner_id = (select auth.uid())
    )
  );

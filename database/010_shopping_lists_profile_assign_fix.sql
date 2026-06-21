-- Grocery2U by RH v1.3.14
-- Shopping list profile assignment + MVP RLS fix

alter table public.shopping_lists
  add column if not exists created_by_profile_id uuid references public.family_profiles(id) on delete set null,
  add column if not exists assigned_to_profile_id uuid references public.family_profiles(id) on delete set null;

create index if not exists idx_shopping_lists_family_id on public.shopping_lists(family_id);
create index if not exists idx_shopping_lists_created_by_profile on public.shopping_lists(created_by_profile_id);
create index if not exists idx_shopping_lists_assigned_to_profile on public.shopping_lists(assigned_to_profile_id);
create index if not exists idx_shopping_list_items_list_id on public.shopping_list_items(list_id);

-- MVP QA mode: allow frontend anon key while Grocery2U is being tested.
-- Tighten this later with proper authenticated policies / Edge Functions.
alter table public.shopping_lists disable row level security;
alter table public.shopping_list_items disable row level security;

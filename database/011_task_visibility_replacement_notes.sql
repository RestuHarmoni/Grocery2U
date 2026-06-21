-- Grocery2U by RH v1.3.15
-- Task visibility by active family profile + replacement/unavailable notes

alter table public.shopping_list_items
  add column if not exists replacement_note text,
  add column if not exists unavailable_reason text,
  add column if not exists unavailable_note text;

create index if not exists idx_shopping_lists_status on public.shopping_lists(status);
create index if not exists idx_shopping_list_items_status on public.shopping_list_items(status);

-- MVP QA mode. Tighten later with authenticated policies / Edge Functions.
alter table public.shopping_lists disable row level security;
alter table public.shopping_list_items disable row level security;

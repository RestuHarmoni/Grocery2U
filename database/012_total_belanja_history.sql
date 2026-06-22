-- Grocery2U by RH v1.3.18
-- Total belanja sebelum complete + history tugasan

alter table public.shopping_lists
  add column if not exists total_amount numeric(10,2) default 0,
  add column if not exists completion_note text,
  add column if not exists completed_at timestamptz;

create index if not exists idx_shopping_lists_completed_at on public.shopping_lists(completed_at);
create index if not exists idx_shopping_lists_total_amount on public.shopping_lists(total_amount);

-- MVP QA mode. Tighten later with proper policies / RPC.
alter table public.shopping_lists disable row level security;
alter table public.shopping_list_items disable row level security;

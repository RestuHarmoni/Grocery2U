# Grocery2U v1.3.14 - Assigned List Receiver Fix

## Fix
- Senarai kini disimpan ke Supabase `shopping_lists`.
- Barang senarai disimpan ke `shopping_list_items`.
- `created_by_profile_id` dan `assigned_to_profile_id` ditambah.
- Home/List akan memaparkan senarai yang dihantar kepada profile aktif.
- Contoh: Aidah hantar kepada Encik Shuq, profile Encik Shuq akan nampak senarai tersebut selepas refresh/login semula.

## SQL wajib run
`database/010_shopping_lists_profile_assign_fix.sql`

## QA
1. Login sebagai akaun family.
2. Pilih profile Aidah.
3. Buat senarai dan hantar kepada Encik Shuq.
4. Switch profile kepada Encik Shuq.
5. Senarai mesti muncul di bahagian Untuk Saya.
6. Semak table `shopping_lists` dan `shopping_list_items` di Supabase.

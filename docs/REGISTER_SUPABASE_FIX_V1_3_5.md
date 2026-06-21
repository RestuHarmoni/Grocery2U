# Grocery2U v1.3.5 - Supabase Register Write Fix

Fix bug QA:
- Admin generate code berjaya di UI tetapi tidak masuk Supabase.
- User register guna code berjaya di UI/localStorage tetapi tiada record di Supabase.

Update:
- Admin `Generate 1 Kod` sekarang insert ke table `access_codes`.
- User register sekarang panggil RPC `grocery2u_register_user_with_access_code`.
- RPC akan insert `app_users`, update `access_codes.used_count`, dan insert `access_code_uses`.

Run di Supabase:
1. `database/003_access_codes.sql`

QA:
1. Admin generate code `RH-XXXXXX`.
2. Semak Supabase table `access_codes`.
3. Register user guna code tersebut.
4. Semak table `app_users`, `access_codes.used_count`, `access_code_uses`.

# Grocery2U v1.3.6 - Supabase Integration Fix

Patch ini membetulkan isu QA:

- Admin dashboard sebelum ini baca localStorage kerana `/admin` tidak load `../supabase-config.js`.
- Access Code generator simpan local jika Supabase config tidak dikesan.
- Dashboard admin sekarang baca table Supabase jika config aktif.
- SQL v1.3.6 tambah grants untuk anon key dan disable RLS untuk MVP username+PIN.

## Run di Supabase

Run semula:

```text
database/003_access_codes.sql
```

## QA wajib

1. Buka `/admin` dan login.
2. Access Codes → Generate 1 Kod.
3. Semak Supabase table `access_codes`. Kod mesti muncul.
4. Register user dengan kod itu.
5. Semak `app_users`. User mesti muncul.
6. Semak `access_code_uses`. Rekod penggunaan mesti muncul.
7. Semak `access_codes.used_count`. Nilai mesti naik.
8. Create Family. Semak table `families` dan `family_members`.

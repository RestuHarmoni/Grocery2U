# Grocery2U by RH v1.3.0 - Admin Username/Password

Admin tidak menggunakan email.

## URL Admin

`/admin`

## Login awal demo/setup

- Username: `superadmin`
- Password: `grocery2u123`

Tukar password selepas setup production.

## Fail Supabase yang perlu run

1. `database/001_supabase_schema.sql`
2. `database/002_admin_username_password.sql`

## Tukar password admin melalui SQL Editor

```sql
select grocery2u_change_admin_password('superadmin', 'password_baru_yang_kuat');
```

## Nota keselamatan

Untuk production penuh, jangan verify `password_hash` terus dari browser. Gunakan Supabase Edge Function atau backend trusted untuk semak password dan cipta session admin.

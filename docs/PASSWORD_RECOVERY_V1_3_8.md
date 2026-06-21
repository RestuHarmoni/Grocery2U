# Grocery2U v1.3.8 Password Recovery

## Flow

1. Staf buka `/admin` > tab User.
2. Tekan `Reset Password` pada user.
3. Sistem generate password sementara seperti `G2U849201`.
4. User login guna password sementara.
5. App paksa user tukar password baru.
6. User juga boleh tukar password sendiri di `Setting > Account Security`.

## SQL perlu run

Run file:

```text
database/005_password_recovery.sql
```

## Table/column baru

- `app_users.password_reset_required`
- `app_users.password_reset_at`
- `app_users.password_updated_at`
- `app_users.reset_by_admin_username`
- `user_password_events`

## Nota MVP

Password/PIN masih disimpan dalam field `pin_hash` seperti versi awal. Untuk production penuh, pindahkan verification password ke Supabase Edge Function/backend dan guna hashing sebenar.

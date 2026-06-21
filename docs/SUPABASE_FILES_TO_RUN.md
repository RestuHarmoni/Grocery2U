# Supabase Files To Run — Grocery2U by RH

Run ikut turutan ini dalam Supabase SQL Editor:

```text
database/001_supabase_schema.sql
database/002_admin_username_password.sql
database/003_access_codes.sql
```

Bucket yang diperlukan:

```text
receipts
```

Had awal production:

```text
Total family maksimum: 3,000
Family per user maksimum: 5
Access Code: 1 kod = 50 family secara default
```


## v1.3.8 Password Recovery
Run: `database/005_password_recovery.sql`

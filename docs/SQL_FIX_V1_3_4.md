# SQL Fix v1.3.4

Masalah: `column c.campaign_name does not exist` semasa run `database/003_access_codes.sql`.

Punca: table `access_codes` lama sudah wujud, jadi `create table if not exists` tidak menambah column baru.

Fix: `database/003_access_codes.sql` kini safe migration dan akan `alter table add column if not exists` untuk `campaign_name`, `max_family`, `used_count`, `status`, `created_by_admin_id`, dan `expires_at`.

Run semula fail ini dalam Supabase SQL Editor:

```text
database/003_access_codes.sql
```

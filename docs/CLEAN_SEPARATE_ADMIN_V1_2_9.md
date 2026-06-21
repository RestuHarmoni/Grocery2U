# Grocery2U by RH v1.2.9 - Clean Separate Admin

Update:
- Admin dibuang sepenuhnya daripada user app `/index.html`.
- Staff admin kekal berasingan di `/admin/index.html`.
- User app hanya ada Home, Senarai, Claim/Resit dan Setting.
- Admin login menggunakan username + password staf.
- SQL dan semua dokumen disusun dalam folder standard.

Struktur baru:
- `/docs/` untuk README, nota release dan panduan setup.
- `/database/001_supabase_schema.sql` untuk SQL Supabase.
- `/admin/` untuk staff admin page sahaja.

Supabase:
Run fail `database/001_supabase_schema.sql` dalam Supabase SQL Editor.

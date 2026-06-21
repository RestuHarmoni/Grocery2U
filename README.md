# Grocery2U by RH v1.3.13

Patch: Family Profile Supabase Persist Fix.

Run SQL terbaru:
- `database/009_family_profile_persist_fix.sql`

Selepas run SQL, profile keluarga tidak lagi hilang selepas clear browser kerana app akan load dari Supabase table `family_profiles`.

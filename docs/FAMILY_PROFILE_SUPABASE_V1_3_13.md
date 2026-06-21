# Grocery2U v1.3.13 - Family Profile Supabase Persist Fix

Fix utama:
- Tambah profil keluarga kini insert ke Supabase `family_profiles`.
- App baca semula profil dari Supabase selepas login/refresh.
- Jika browser/localStorage clear, profil masih kekal kerana sumber data ialah Supabase.

Run SQL:
`database/009_family_profile_persist_fix.sql`

QA:
1. Login user.
2. Tambah profil Ayah/Ibu/Anak.
3. Semak table `family_profiles` di Supabase.
4. Clear browser localStorage/cache.
5. Login semula.
6. Profil mesti muncul semula dari Supabase.

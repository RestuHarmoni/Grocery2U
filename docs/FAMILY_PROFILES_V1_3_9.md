# Grocery2U v1.3.9 — Family Account + Netflix Profile

## Rule baru

- 1 username login = 1 akaun family sahaja.
- Selepas login, user wajib pilih profil dahulu sebelum masuk dashboard.
- Jika user baru daftar dan belum ada profil, app akan paksa create profil pertama.
- 1 family maksimum 5 profil.
- Profil contoh: Ayah, Ibu, Anak 1, Anak 2, Anak 3.
- Shopping list boleh dihantar antara mana-mana profil:
  - Isteri → Suami
  - Suami → Isteri
  - Ibu → Anak 1
  - Anak → Ayah/Ibu

## Supabase file yang perlu run

Run selepas file sebelumnya:

```text
database/006_family_profiles_v1_3_9.sql
```

## Table baru

```text
family_profiles
```

## Field shopping list baru

```text
created_by_profile_id
assigned_to_profile_id
progress_percent
```

## QA

1. Register user baru.
2. Login.
3. Pastikan tidak terus masuk Home.
4. Create profile pertama.
5. Pilih profile.
6. Masuk Home.
7. Add profile kedua.
8. Buat senarai daripada profile pertama kepada profile kedua.
9. Tukar profile dan semak senarai diterima.

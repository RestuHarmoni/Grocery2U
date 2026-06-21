# Grocery2U v1.3.10 — Profile Gate Blank Screen Fix

Fix for console error:

```text
Cannot read properties of undefined (reading 'filter')
```

Cause:
Older browser/localStorage data did not contain `db.profiles`, so the profile gate crashed when calling `.filter()`.

Fix:
- Added migration guard for `db.profiles = []`.
- Made `familyProfiles()` safe with `Array.isArray()`.
- Create Profile screen now appears for new users with no profile.
- Cache/version updated to `1.3.10`.

QA:
1. Login family account.
2. If no profile exists, app must show Create/Tambah Profil screen.
3. Create Ayah/Ibu/Anak profile.
4. Select profile.
5. Dashboard opens normally.

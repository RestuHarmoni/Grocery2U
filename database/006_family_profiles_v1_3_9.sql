-- Grocery2U by RH v1.3.9
-- Family Account + Netflix-style Profiles
-- Rule: 1 app user account = 1 family, maximum 5 profiles per family.

ALTER TABLE families
ADD COLUMN IF NOT EXISTS account_user_id uuid;

-- Backfill account_user_id from existing created_by where possible.
UPDATE families
SET account_user_id = created_by
WHERE account_user_id IS NULL AND created_by IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_families_account_user_id
ON families(account_user_id)
WHERE account_user_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS family_profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id uuid NOT NULL REFERENCES families(id) ON DELETE CASCADE,
  name text NOT NULL,
  role text NOT NULL DEFAULT 'Ahli',
  avatar text,
  status text NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_family_profiles_family_id ON family_profiles(family_id);

CREATE OR REPLACE FUNCTION enforce_max_5_family_profiles()
RETURNS trigger AS $$
BEGIN
  IF (
    SELECT count(*)
    FROM family_profiles
    WHERE family_id = NEW.family_id
      AND status <> 'inactive'
  ) >= 5 THEN
    RAISE EXCEPTION 'Maximum 5 profiles per family reached';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_max_5_family_profiles ON family_profiles;
CREATE TRIGGER trg_max_5_family_profiles
BEFORE INSERT ON family_profiles
FOR EACH ROW
EXECUTE FUNCTION enforce_max_5_family_profiles();

ALTER TABLE shopping_lists
ADD COLUMN IF NOT EXISTS created_by_profile_id uuid REFERENCES family_profiles(id),
ADD COLUMN IF NOT EXISTS assigned_to_profile_id uuid REFERENCES family_profiles(id),
ADD COLUMN IF NOT EXISTS progress_percent int DEFAULT 0;

CREATE INDEX IF NOT EXISTS idx_shopping_lists_created_profile ON shopping_lists(created_by_profile_id);
CREATE INDEX IF NOT EXISTS idx_shopping_lists_assigned_profile ON shopping_lists(assigned_to_profile_id);

-- MVP policy/grants for username+password custom auth.
ALTER TABLE family_profiles DISABLE ROW LEVEL SECURITY;
GRANT ALL ON family_profiles TO anon, authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

COMMENT ON TABLE family_profiles IS 'Grocery2U v1.3.9 Netflix-style family profiles. 1 family max 5 profiles.';

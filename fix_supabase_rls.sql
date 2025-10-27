-- Script pour corriger les permissions RLS sur Supabase
-- LaVideoLaPlusVue - Hall of Fame

-- 1. Vérifier l'état actuel de RLS
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables
WHERE tablename = 'hall_of_fame';

-- 2. Désactiver RLS temporairement pour permettre les opérations anonymes
ALTER TABLE hall_of_fame DISABLE ROW LEVEL SECURITY;

-- 3. Supprimer toutes les policies existantes
DROP POLICY IF EXISTS "Enable read access for all users" ON hall_of_fame;
DROP POLICY IF EXISTS "Enable insert for all users" ON hall_of_fame;
DROP POLICY IF EXISTS "Enable update for all users" ON hall_of_fame;

-- 4. Créer des policies permissives
-- Permettre la lecture pour tous (authentifiés et anonymes)
CREATE POLICY "Enable read access for all users" ON hall_of_fame
    FOR SELECT
    USING (true);

-- Permettre l'insertion pour tous (authentifiés et anonymes)
CREATE POLICY "Enable insert for all users" ON hall_of_fame
    FOR INSERT
    WITH CHECK (true);

-- 5. Réactiver RLS avec les nouvelles policies
ALTER TABLE hall_of_fame ENABLE ROW LEVEL SECURITY;

-- 6. Accorder les permissions nécessaires au rôle anon
GRANT SELECT, INSERT ON hall_of_fame TO anon;
GRANT USAGE ON SEQUENCE hall_of_fame_id_seq TO anon;

-- 7. Vérifier les policies
SELECT 
    pol.polname,
    pol.polpermissive,
    pol.polcmd,
    pol.polqual::text,
    pol.polwithcheck::text
FROM pg_policy pol
JOIN pg_class pc ON pol.polrelid = pc.oid
WHERE pc.relname = 'hall_of_fame';

-- 8. Test d'insertion
-- INSERT INTO hall_of_fame (user_name, score) VALUES ('Test', 15);
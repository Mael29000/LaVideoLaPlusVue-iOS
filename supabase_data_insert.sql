-- Script pour insérer les données initiales dans le Hall of Fame
-- LaVideoLaPlusVue

-- Vérifier d'abord la structure de la table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'hall_of_fame';

-- Insérer les données préexistantes
INSERT INTO hall_of_fame (user_name, score, created_at) VALUES
  ('William', 34, NOW() - INTERVAL '1 day'),
  ('Louen', 26, NOW() - INTERVAL '2 days'),
  ('Emilien', 24, NOW() - INTERVAL '3 days'),
  ('Maël', 17, NOW() - INTERVAL '5 days')
ON CONFLICT (user_name) DO NOTHING;

-- Vérifier que les données ont été insérées
SELECT * FROM hall_of_fame ORDER BY score DESC;
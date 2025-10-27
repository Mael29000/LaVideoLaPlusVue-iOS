-- Script de mise à jour de la base de données Supabase
-- LaVideoLaPlusVue - Hall of Fame

-- 1. Supprimer la colonne device_id
ALTER TABLE hall_of_fame DROP COLUMN IF EXISTS device_id;

-- 2. Ajouter les données préexistantes
INSERT INTO hall_of_fame (user_name, score, created_at) VALUES
  ('Maël', 17, NOW() - INTERVAL '5 days'),
  ('Emilien', 24, NOW() - INTERVAL '3 days'),
  ('Louen', 26, NOW() - INTERVAL '2 days'),
  ('William', 34, NOW() - INTERVAL '1 day');

-- Vérifier que les données ont bien été insérées
SELECT * FROM hall_of_fame ORDER BY score DESC;
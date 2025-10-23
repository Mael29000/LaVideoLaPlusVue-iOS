#!/usr/bin/env python3
"""
Script pour récupérer les URLs des avatars YouTube et enrichir le fichier data.json.

Usage:
1. Remplacer 'YOUR_YOUTUBE_API_KEY_HERE' par votre vraie clé API
2. Exécuter: python fetch_channel_avatars.py

Le script va:
- Lire data.json existant
- Extraire tous les channelIds uniques
- Récupérer les URLs d'avatars via l'API YouTube
- Enrichir chaque entrée avec channelAvatarUrl
- Sauvegarder le fichier mis à jour
"""

import json
import requests
import sys
from collections import defaultdict
from typing import Dict, List, Set

# ==========================================
# CONFIGURATION
# ==========================================

# 🔑 REMPLACE CETTE CLÉ PAR TA VRAIE CLÉ API YOUTUBE
YOUTUBE_API_KEY = "YOUR_YOUTUBE_API_KEY_HERE"

# Fichiers
DATA_JSON_PATH = "data.json"
BACKUP_PATH = "data_backup.json"

# API YouTube Data v3
YOUTUBE_API_BASE = "https://www.googleapis.com/youtube/v3"

# ==========================================
# FONCTIONS PRINCIPALES
# ==========================================

def load_json_data(file_path: str) -> List[Dict]:
    """Charge le fichier JSON existant."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        print(f"✅ Fichier {file_path} chargé: {len(data)} entrées")
        return data
    except Exception as e:
        print(f"❌ Erreur lors du chargement de {file_path}: {e}")
        sys.exit(1)

def save_json_data(data: List[Dict], file_path: str) -> None:
    """Sauvegarde les données dans un fichier JSON."""
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        print(f"✅ Fichier {file_path} sauvegardé: {len(data)} entrées")
    except Exception as e:
        print(f"❌ Erreur lors de la sauvegarde de {file_path}: {e}")
        sys.exit(1)

def extract_unique_channel_ids(data: List[Dict]) -> Set[str]:
    """Extrait tous les channelIds uniques du dataset."""
    channel_ids = set()
    for item in data:
        if 'channelId' in item:
            channel_ids.add(item['channelId'])
    
    print(f"📊 {len(channel_ids)} chaînes YouTube uniques trouvées")
    return channel_ids

def fetch_channel_avatars_batch(channel_ids: List[str]) -> Dict[str, str]:
    """
    Récupère les URLs d'avatars pour une liste de channel IDs via l'API YouTube.
    
    Returns:
        Dict mapping channelId -> avatar_url
    """
    if not YOUTUBE_API_KEY or YOUTUBE_API_KEY == "YOUR_YOUTUBE_API_KEY_HERE":
        print("❌ Erreur: Clé API YouTube non configurée!")
        print("📝 Modifiez la variable YOUTUBE_API_KEY dans le script")
        sys.exit(1)
    
    # L'API YouTube peut traiter jusqu'à 50 IDs par requête
    batch_size = 50
    avatar_urls = {}
    
    for i in range(0, len(channel_ids), batch_size):
        batch = channel_ids[i:i + batch_size]
        batch_str = ",".join(batch)
        
        print(f"🔍 Récupération batch {i//batch_size + 1}: {len(batch)} chaînes...")
        
        url = f"{YOUTUBE_API_BASE}/channels"
        params = {
            'part': 'snippet',
            'id': batch_str,
            'key': YOUTUBE_API_KEY,
            'fields': 'items(id,snippet(title,thumbnails))'
        }
        
        try:
            response = requests.get(url, params=params)
            response.raise_for_status()
            
            data = response.json()
            
            if 'items' in data:
                for item in data['items']:
                    channel_id = item['id']
                    channel_title = item['snippet']['title']
                    
                    # Prioriser la meilleure qualité d'avatar disponible
                    thumbnails = item['snippet']['thumbnails']
                    avatar_url = None
                    
                    # Ordre de priorité: high > medium > default
                    for quality in ['high', 'medium', 'default']:
                        if quality in thumbnails:
                            avatar_url = thumbnails[quality]['url']
                            break
                    
                    if avatar_url:
                        avatar_urls[channel_id] = avatar_url
                        print(f"  ✅ {channel_title}: {avatar_url}")
                    else:
                        print(f"  ⚠️ {channel_title}: Pas d'avatar trouvé")
            
            # Vérifier les chaînes non trouvées dans cette batch
            found_ids = set(item['id'] for item in data.get('items', []))
            missing_ids = set(batch) - found_ids
            for missing_id in missing_ids:
                print(f"  ❌ Chaîne non trouvée: {missing_id}")
                
        except requests.exceptions.RequestException as e:
            print(f"❌ Erreur API pour la batch {i//batch_size + 1}: {e}")
            continue
        except Exception as e:
            print(f"❌ Erreur inattendue pour la batch {i//batch_size + 1}: {e}")
            continue
    
    print(f"🎯 {len(avatar_urls)} avatars récupérés sur {len(channel_ids)} chaînes")
    return avatar_urls

def enrich_data_with_avatars(data: List[Dict], avatar_urls: Dict[str, str]) -> List[Dict]:
    """Enrichit chaque entrée du dataset avec l'URL de l'avatar de la chaîne."""
    enriched_count = 0
    
    for item in data:
        if 'channelId' in item and item['channelId'] in avatar_urls:
            item['channelAvatarUrl'] = avatar_urls[item['channelId']]
            enriched_count += 1
    
    print(f"📝 {enriched_count} entrées enrichies avec les avatars")
    return data

def main():
    """Fonction principale du script."""
    print("🚀 Démarrage du script de récupération d'avatars YouTube")
    print("=" * 60)
    
    # 1. Charger les données existantes
    print("📖 Chargement du fichier data.json...")
    data = load_json_data(DATA_JSON_PATH)
    
    # 2. Créer une sauvegarde
    print("💾 Création d'une sauvegarde...")
    save_json_data(data, BACKUP_PATH)
    
    # 3. Extraire les channel IDs uniques
    print("🔍 Extraction des channel IDs...")
    channel_ids = extract_unique_channel_ids(data)
    
    if not channel_ids:
        print("❌ Aucun channel ID trouvé dans le fichier!")
        sys.exit(1)
    
    # 4. Récupérer les avatars via l'API YouTube
    print("🌐 Récupération des avatars via l'API YouTube...")
    avatar_urls = fetch_channel_avatars_batch(list(channel_ids))
    
    if not avatar_urls:
        print("❌ Aucun avatar récupéré!")
        sys.exit(1)
    
    # 5. Enrichir les données
    print("📝 Enrichissement des données...")
    enriched_data = enrich_data_with_avatars(data, avatar_urls)
    
    # 6. Sauvegarder le fichier mis à jour
    print("💾 Sauvegarde du fichier enrichi...")
    save_json_data(enriched_data, DATA_JSON_PATH)
    
    print("=" * 60)
    print("🎉 Script terminé avec succès!")
    print(f"📊 Statistiques:")
    print(f"   • Entrées totales: {len(enriched_data)}")
    print(f"   • Chaînes uniques: {len(channel_ids)}")
    print(f"   • Avatars récupérés: {len(avatar_urls)}")
    print(f"   • Fichier sauvegardé: {DATA_JSON_PATH}")
    print(f"   • Sauvegarde créée: {BACKUP_PATH}")

if __name__ == "__main__":
    main()
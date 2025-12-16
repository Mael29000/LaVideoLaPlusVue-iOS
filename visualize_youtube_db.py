#!/usr/bin/env python3
"""
Script pour visualiser la base de données YouTube sous forme de grille HTML.
Affiche les YouTubers avec leurs avatars et toutes leurs vidéos en miniatures.
"""

import json
from collections import defaultdict
from datetime import datetime
import os

def load_youtube_data(file_path):
    """Charge les données JSON depuis le fichier."""
    with open(file_path, 'r', encoding='utf-8') as f:
        return json.load(f)

def group_videos_by_channel(videos):
    """Groupe les vidéos par chaîne YouTube."""
    channels = defaultdict(list)
    
    for video in videos:
        channel_key = (video['channelId'], video['channelTitle'], video.get('channelAvatarUrl', ''))
        channels[channel_key].append(video)
    
    # Convertir en liste triée par nombre de vidéos (décroissant)
    sorted_channels = sorted(channels.items(), key=lambda x: len(x[1]), reverse=True)
    
    return sorted_channels

def format_number(num):
    """Formate les nombres avec des espaces pour la lisibilité."""
    return f"{num:,}".replace(',', ' ')

def generate_html(channels_data):
    """Génère le contenu HTML."""
    
    total_videos = sum(len(videos) for _, videos in channels_data)
    total_channels = len(channels_data)
    
    html = f"""<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Visualisation Base de Données YouTube - LaVideoLaPlusVue</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}
        
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background-color: #0f0f0f;
            color: #fff;
            padding: 20px;
        }}
        
        .header {{
            text-align: center;
            margin-bottom: 40px;
            padding: 20px;
            background-color: #1a1a1a;
            border-radius: 12px;
        }}
        
        .header h1 {{
            font-size: 2.5em;
            margin-bottom: 10px;
            background: linear-gradient(45deg, #ff0000, #ff4444);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }}
        
        .stats {{
            display: flex;
            justify-content: center;
            gap: 40px;
            margin-top: 20px;
        }}
        
        .stat {{
            text-align: center;
        }}
        
        .stat-value {{
            font-size: 2em;
            font-weight: bold;
            color: #ff4444;
        }}
        
        .stat-label {{
            font-size: 0.9em;
            color: #aaa;
        }}
        
        .channel-section {{
            margin-bottom: 60px;
            background-color: #1a1a1a;
            border-radius: 12px;
            padding: 20px;
            border: 1px solid #2a2a2a;
        }}
        
        .channel-header {{
            display: flex;
            align-items: center;
            gap: 20px;
            margin-bottom: 20px;
            padding-bottom: 20px;
            border-bottom: 2px solid #333;
        }}
        
        .channel-avatar {{
            width: 80px;
            height: 80px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid #ff4444;
        }}
        
        .channel-avatar.missing {{
            background-color: #333;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 36px;
            color: #666;
        }}
        
        .channel-info {{
            flex: 1;
        }}
        
        .channel-name {{
            font-size: 1.8em;
            font-weight: bold;
            margin-bottom: 5px;
        }}
        
        .video-count {{
            font-size: 1.1em;
            color: #aaa;
        }}
        
        .video-count span {{
            color: #ff4444;
            font-weight: bold;
        }}
        
        .videos-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 15px;
        }}
        
        .video-item {{
            position: relative;
            background-color: #222;
            border-radius: 8px;
            overflow: hidden;
            transition: transform 0.3s, box-shadow 0.3s;
        }}
        
        .video-item:hover {{
            transform: translateY(-4px);
            box-shadow: 0 8px 20px rgba(255, 68, 68, 0.3);
        }}
        
        .video-thumbnail {{
            width: 100%;
            aspect-ratio: 16/9;
            object-fit: cover;
        }}
        
        .video-thumbnail.missing {{
            background-color: #333;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #666;
            font-size: 14px;
            text-align: center;
            padding: 10px;
        }}
        
        .video-views {{
            position: absolute;
            bottom: 5px;
            right: 5px;
            background-color: rgba(0, 0, 0, 0.8);
            color: #fff;
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 12px;
        }}
        
        .timestamp {{
            text-align: center;
            color: #666;
            font-size: 0.9em;
            margin-top: 40px;
        }}
    </style>
</head>
<body>
    <div class="header">
        <h1>LaVideoLaPlusVue - Base de Données</h1>
        <div class="stats">
            <div class="stat">
                <div class="stat-value">{total_channels}</div>
                <div class="stat-label">YouTubers</div>
            </div>
            <div class="stat">
                <div class="stat-value">{format_number(total_videos)}</div>
                <div class="stat-label">Vidéos</div>
            </div>
        </div>
    </div>
"""
    
    # Générer la section pour chaque YouTuber
    for channel_info, videos in channels_data:
        channel_id, channel_name, avatar_url = channel_info
        video_count = len(videos)
        
        html += f"""
    <div class="channel-section">
        <div class="channel-header">"""
        
        if avatar_url:
            html += f"""
            <img src="{avatar_url}" alt="{channel_name}" class="channel-avatar" 
                 onerror="this.onerror=null; this.outerHTML='<div class=\\'channel-avatar missing\\'>👤</div>'">"""
        else:
            html += f"""
            <div class="channel-avatar missing">👤</div>"""
        
        html += f"""
            <div class="channel-info">
                <div class="channel-name">{channel_name}</div>
                <div class="video-count"><span>{video_count}</span> vidéo{'s' if video_count > 1 else ''}</div>
            </div>
        </div>
        
        <div class="videos-grid">"""
        
        # Ajouter chaque vidéo
        for video in videos:
            view_count = format_number(video.get('viewCount', 0))
            thumbnail_url = video.get('thumbnailUrl', '')
            title = video.get('title', 'Sans titre')
            video_id = video.get('id', '')
            
            html += f"""
            <div class="video-item" title="{title.replace('"', '&quot;')}">"""
            
            if thumbnail_url:
                html += f"""
                <img src="{thumbnail_url}" alt="{title.replace('"', '&quot;')}" class="video-thumbnail"
                     onerror="this.onerror=null; this.outerHTML='<div class=\\'video-thumbnail missing\\'>Miniature non disponible</div>'">"""
            else:
                html += f"""
                <div class="video-thumbnail missing">Miniature non disponible</div>"""
            
            html += f"""
                <div class="video-views">{view_count} vues</div>
            </div>"""
        
        html += """
        </div>
    </div>"""
    
    # Footer avec timestamp
    timestamp = datetime.now().strftime("%d/%m/%Y à %H:%M:%S")
    html += f"""
    <div class="timestamp">
        Généré le {timestamp}
    </div>
</body>
</html>"""
    
    return html

def main():
    """Fonction principale."""
    # Chemins des fichiers
    data_file = "LaVideoLaPlusVue/Data/data.json"
    output_file = "youtube_db_visualization.html"
    
    # Vérifier si le fichier existe
    if not os.path.exists(data_file):
        print(f"Erreur : Le fichier {data_file} n'existe pas!")
        return
    
    # Charger les données
    print("Chargement des données...")
    videos = load_youtube_data(data_file)
    print(f"✓ {len(videos)} vidéos chargées")
    
    # Grouper par chaîne
    print("Organisation des données par YouTuber...")
    channels = group_videos_by_channel(videos)
    print(f"✓ {len(channels)} YouTubers trouvés")
    
    # Générer le HTML
    print("Génération du fichier HTML...")
    html_content = generate_html(channels)
    
    # Écrire le fichier
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(html_content)
    
    print(f"\n✅ Fichier généré avec succès : {output_file}")
    print(f"   Taille : {os.path.getsize(output_file) / 1024 / 1024:.2f} MB")
    print("\n📊 Statistiques :")
    print(f"   - {len(channels)} YouTubers")
    print(f"   - {len(videos)} vidéos au total")
    print(f"   - Moyenne : {len(videos) / len(channels):.1f} vidéos par YouTuber")
    
    # Top 5 des YouTubers avec le plus de vidéos
    print("\n🏆 Top 5 des YouTubers avec le plus de vidéos :")
    for i, (channel_info, vids) in enumerate(channels[:5], 1):
        _, channel_name, _ = channel_info
        print(f"   {i}. {channel_name} : {len(vids)} vidéos")

if __name__ == "__main__":
    main()
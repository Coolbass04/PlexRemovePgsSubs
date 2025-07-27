# PlexRemovePgsSubs

A Python script to remove PGS (Picture-based Graphics Subtitles) from Plex media files.

## Features
- Connects to your Plex Media Server
- Identifies media files with PGS subtitles
- Removes PGS subtitle tracks while preserving other subtitle formats
- Supports batch processing of your entire library

## Requirements
- Python 3.8+
- Plex Media Server
- Plex API credentials

## Installation
1. Clone this repository
2. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

## Usage
```bash
python plex_remove_pgs.py --server-url <PLEX_SERVER_URL> --token <PLEX_TOKEN>
```

## Configuration
You'll need to provide:
- Your Plex Media Server URL
- Your Plex API token
- Optional: Library sections to process (movies, tv shows, etc.)

## Note
Make sure to backup your media files before running this script as it will modify the subtitle tracks.

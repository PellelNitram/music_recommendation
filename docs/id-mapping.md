# Mapping Item IDs Between ListenBrainz and Navidrome

## The Two ID Worlds

**ListenBrainz / MusicBrainz** identifies tracks by MusicBrainz Recording MBIDs (UUIDs like `a1b2c3d4-...`). Listening history and recommendations from ListenBrainz are keyed on these.

**Navidrome** assigns its own internal IDs to tracks when it scans the music folder. It exposes them via the Subsonic API.

## Mapping Approaches

### 1. MusicBrainz Tags Embedded in Files (Recommended)

If music files have MusicBrainz tags embedded (`MUSICBRAINZ_TRACKID` / `musicbrainz_recordingid`), Navidrome reads and stores them. The MBID then serves as the shared key:

- **Via Subsonic API** -- responses from `getMusicDirectory` / `search3` include an `mbid` field when available.
- **Via SQLite DB** -- the `media_file` table in `navidrome.db` has a `mbz_recording_id` column.

To tag untagged files, run them through [MusicBrainz Picard](https://picard.musicbrainz.org/) and re-scan in Navidrome.

### 2. Fuzzy Metadata Matching (Fallback)

When files lack MusicBrainz tags, match on `(artist, title)` between:

- ListenBrainz listen data (`artist_name`, `track_name`)
- Navidrome indexed metadata (via API or DB)

Less reliable due to spelling variations, but workable for smaller collections.

## Recommended Pipeline

```
ListenBrainz API  --(MBID)-->  Rec Model  --(MBID)-->  Navidrome DB lookup
                                                        (mbz_recording_id -> navidrome_id)
                                                             |
                                                             v
                                                     Subsonic API: createPlaylist
```

1. **Pull listening history** from ListenBrainz (keyed on MBIDs).
2. **Train the rec model** using MBIDs as item IDs.
3. **Map recommendations back** to Navidrome by joining on `mbz_recording_id` in `navidrome.db`.
4. **Create playlists** via the Subsonic API.

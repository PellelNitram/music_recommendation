# Music Recommendation System

A lean, self-hosted music discovery system built on top of [Navidrome](https://www.navidrome.org/) and [ListenBrainz](https://listenbrainz.org/).

## What it does

Generates daily personalized playlists in Navidrome by running a recommender system trained on your ListenBrainz scrobbling history. Recommendations are a mix of tracks you haven't heard yet (discovery) and tracks worth revisiting.

Playlists are created once per day (at night) with names like `Recommended for you - 2026-03-19`.

Tracks recommended by the model that aren't in your local library are written to a `missing_tracks.json` file (keyed by date) so you can decide whether to add them later.

## Architecture

```
ListenBrainz API  --(scrobbles + recs)-->  Recommender Model
                                                  |
                                               (MBIDs)
                                                  |
                                    Navidrome SQLite DB lookup
                                    (mbz_recording_id -> navidrome_id)
                                         |                  |
                                         v                  v
                                  Subsonic API        missing_tracks.json
                                 (createPlaylist)    (tracks not in library)
```

**MusicBrainz Recording IDs (MBIDs)** are the shared key between ListenBrainz and Navidrome. Navidrome stores them in the `mbz_recording_id` column of its SQLite database when files are tagged.

## Setup prerequisites

1. **Tag your music library with MusicBrainz Picard** — run it once over your library to embed MBIDs via audio fingerprinting (AcoustID). This is a one-time automated step.
2. **Rescan Navidrome** after tagging so MBIDs are indexed in the database.
3. **Enable ListenBrainz scrobbling** in Navidrome so your listening history is available for training.

## Scope

- Primary target: Navidrome (via Subsonic API)
- Designed to be extendable to other Subsonic-compatible servers, but Navidrome is the only supported target for now
- Recommender algorithm is intentionally left open — the framework provides the data pipeline and integration layer; the model is pluggable

## Output files

| File | Description |
|------|-------------|
| Navidrome playlist | In-library recommendations, created nightly |
| `missing_tracks.json` | Recommended tracks not found in local library, accumulated by date |

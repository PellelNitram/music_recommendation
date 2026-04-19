# Music Recommendation System

A lean, self-hosted music discovery system built on top of [Navidrome](https://www.navidrome.org/) and [ListenBrainz](https://listenbrainz.org/).

## What it does

Generates daily personalized playlists in Navidrome using a recommender system trained on the entire ListenBrainz community's listening data. Your personal ListenBrainz scrobbles are used as input to query the model for personalized suggestions. Recommendations are a mix of tracks you haven't heard yet (discovery) and tracks worth revisiting.

Playlists are created once per day (at night) with names like `Recommended for you - 2026-03-19`.

Tracks recommended by the model that aren't in your local library are written to a `missing_tracks.json` file (keyed by date) so you can decide whether to add them later.

## Architecture

```
ListenBrainz community data  --(training)-->  Recommender Model
Your ListenBrainz scrobbles  --(query)---->
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

MusicBrainz Recording IDs (MBIDs) are used as the shared key between ListenBrainz and Navidrome — see [ADR 001](docs/adr/001-mbid-as-shared-key.md) for the rationale and alternatives. Setup prerequisites (Picard tagging, Navidrome rescanning, scrobbling config) will be documented in `docs/setup.md` once validated.

## Scope

- Primary target: Navidrome (via Subsonic API)
- Designed to be extendable to other Subsonic-compatible servers, but Navidrome is the only supported target for now
- Recommender algorithm is intentionally left open — the framework provides the data pipeline and integration layer; the model is pluggable

## Output files

| File | Description |
|------|-------------|
| Navidrome playlist | In-library recommendations, created nightly |
| `missing_tracks.json` | Recommended tracks not found in local library, accumulated by date |

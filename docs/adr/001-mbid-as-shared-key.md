# ADR 001: Use MusicBrainz Recording ID (MBID) as the Shared Key Between ListenBrainz and Navidrome

## Status

Proposed

## Context

The recommender system needs to map between two ID spaces:

- **ListenBrainz** identifies tracks by MusicBrainz Recording IDs (MBIDs) — UUIDs like `a1b2c3d4-...`
- **Navidrome** assigns its own internal IDs when scanning the local music library

Without a shared key, matching recommended tracks to local library entries requires fuzzy matching on `(artist, title)`, which is unreliable due to spelling variations and metadata inconsistencies.

## Decision

Use MBIDs as the shared key. Music files will be tagged with MBIDs using [MusicBrainz Picard](https://picard.musicbrainz.org/) (via audio fingerprinting / AcoustID) as a one-time setup step. Picard writes the MBID into the `MUSICBRAINZ_TRACKID` / `musicbrainz_recordingid` tag field.

After reindexing, Navidrome surfaces the MBID in two ways:
- **Subsonic API** — `getMusicDirectory` / `search3` responses include an `mbid` field when available
- **SQLite DB** — the `media_file` table in `navidrome.db` has a `mbz_recording_id` column

For playlist generation, the lookup goes: MBID → `mbz_recording_id` in `navidrome.db` → Navidrome internal ID → `createPlaylist` via Subsonic API.

Fuzzy `(artist, title)` matching is retained as a fallback for files that Picard cannot match, using `artist_name` / `track_name` from ListenBrainz listen data against Navidrome's indexed metadata.

## Alternatives Considered

- **Fuzzy matching only** — no setup required, but unreliable at scale and produces false positives
- **Manual tagging** — too labour-intensive for large libraries

## Consequences

- The system depends on Picard tagging succeeding for a large enough fraction of the library to be useful. If MBID coverage turns out to be too low, the fuzzy fallback may need to be promoted to the primary approach.
- A validated setup guide (covering Picard, Navidrome rescanning, and ListenBrainz scrobbling configuration) is needed before this approach can be confirmed in practice. Until then, this ADR remains **Proposed**. Once the setup is validated, the guide will live in `docs/setup.md` and this ADR will be updated to **Accepted**.

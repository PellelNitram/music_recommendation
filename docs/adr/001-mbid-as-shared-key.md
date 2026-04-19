# ADR 001: Use MusicBrainz Recording ID (MBID) as the Shared Key Between ListenBrainz and Navidrome

## Status

Proposed

## Context

The recommender system needs to map between two ID spaces:

- **ListenBrainz** identifies tracks by MusicBrainz Recording IDs (MBIDs) — UUIDs like `a1b2c3d4-...`
- **Navidrome** assigns its own internal IDs when scanning the local music library

Without a shared key, matching recommended tracks to local library entries requires fuzzy matching on `(artist, title)`, which is unreliable due to spelling variations and metadata inconsistencies.

## Decision

Use MBIDs as the shared key. Music files will be tagged with MBIDs using [MusicBrainz Picard](https://picard.musicbrainz.org/) (via audio fingerprinting / AcoustID) as a one-time setup step. After reindexing, Navidrome stores the MBID in the `mbz_recording_id` column of its SQLite database, making lookups straightforward.

Fuzzy `(artist, title)` matching is retained as a fallback for files that Picard cannot match.

## Alternatives Considered

- **Fuzzy matching only** — no setup required, but unreliable at scale and produces false positives
- **Manual tagging** — too labour-intensive for large libraries

## Consequences

- The system depends on Picard tagging succeeding for a large enough fraction of the library to be useful. If MBID coverage turns out to be too low, the fuzzy fallback may need to be promoted to the primary approach.
- A validated setup guide (covering Picard, Navidrome rescanning, and ListenBrainz scrobbling configuration) is needed before this approach can be confirmed in practice. Until then, this ADR remains **Proposed**. Once the setup is validated, the guide will live in `docs/setup.md` and this ADR will be updated to **Accepted**.

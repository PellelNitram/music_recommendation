from datetime import datetime
from pathlib import Path

import pyarrow as pa
import pyarrow.parquet as pq
import pytest


def _make_listens_table(rows: list[dict]) -> pa.Table:
    schema = pa.schema([
        ("user_id", pa.int64()),
        ("listened_at", pa.timestamp("ns")),
        ("recording_mbid", pa.string()),
        ("recording_msid", pa.string()),
    ])
    return pa.table(
        {col: [r[col] for r in rows] for col in schema.names},
        schema=schema,
    )


@pytest.fixture()
def listen_data_dir(tmp_path: Path) -> Path:
    dump_a = tmp_path / "100"
    dump_a.mkdir()
    pq.write_table(
        _make_listens_table([
            {
                "user_id": 1,
                "listened_at": datetime(2026, 4, 20, 10, 0, 0),
                "recording_mbid": "aaaa-bbbb",
                "recording_msid": "1111-2222",
            },
            {
                "user_id": 2,
                "listened_at": datetime(2026, 4, 20, 9, 0, 0),
                "recording_mbid": None,
                "recording_msid": "3333-4444",
            },
        ]),
        dump_a / "0.parquet",
    )

    dump_b = tmp_path / "101"
    dump_b.mkdir()
    pq.write_table(
        _make_listens_table([
            {
                "user_id": 1,
                "listened_at": datetime(2026, 4, 21, 12, 0, 0),
                "recording_mbid": "cccc-dddd",
                "recording_msid": "5555-6666",
            },
        ]),
        dump_b / "0.parquet",
    )

    return tmp_path

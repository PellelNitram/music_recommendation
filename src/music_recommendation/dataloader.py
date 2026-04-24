from pathlib import Path

import pyarrow as pa
import pyarrow.compute as pc
import pyarrow.parquet as pq

LISTEN_COLUMNS = ["user_id", "listened_at", "recording_mbid", "recording_msid"]


def load_listens(data_dir: str | Path) -> pa.Table:
    data_dir = Path(data_dir)
    tables = []
    for parquet_file in sorted(data_dir.rglob("*.parquet")):
        table = pq.read_table(str(parquet_file), columns=LISTEN_COLUMNS)
        tables.append(table)
    if not tables:
        raise FileNotFoundError(f"No parquet files found in {data_dir}")
    combined = pa.concat_tables(tables)
    return combined.sort_by("listened_at")

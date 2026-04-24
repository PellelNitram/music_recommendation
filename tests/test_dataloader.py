from pathlib import Path

import pyarrow.compute as pc
import pytest

from music_recommendation.dataloader import LISTEN_COLUMNS, load_listens

DATA_DIR = Path("data/listenbrainz")


class TestLoadListens:
    def test_returns_expected_columns(self, listen_data_dir: Path):
        table = load_listens(listen_data_dir)
        assert table.column_names == LISTEN_COLUMNS

    def test_loads_all_rows_across_dumps(self, listen_data_dir: Path):
        table = load_listens(listen_data_dir)
        assert table.num_rows == 3

    def test_sorted_by_listened_at(self, listen_data_dir: Path):
        table = load_listens(listen_data_dir)
        timestamps = table.column("listened_at").to_pylist()
        assert timestamps == sorted(timestamps)

    def test_preserves_null_recording_mbid(self, listen_data_dir: Path):
        table = load_listens(listen_data_dir)
        mbids = table.column("recording_mbid").to_pylist()
        assert None in mbids

    def test_raises_on_empty_directory(self, tmp_path: Path):
        with pytest.raises(FileNotFoundError, match="No parquet files found"):
            load_listens(tmp_path)

    def test_raises_on_nonexistent_directory(self, tmp_path: Path):
        with pytest.raises(FileNotFoundError, match="No parquet files found"):
            load_listens(tmp_path / "nonexistent")


@pytest.mark.integration
class TestLoadFullData:
    @pytest.fixture(autouse=True)
    def _require_data(self):
        if not DATA_DIR.exists() or not list(DATA_DIR.rglob("*.parquet")):
            pytest.skip("ListenBrainz data not downloaded (run make download-listens)")

    def test_loads_expected_volume(self):
        table = load_listens(DATA_DIR)
        assert table.num_rows > 10_000_000

    def test_recording_mbid_coverage_above_80_percent(self):
        table = load_listens(DATA_DIR)
        non_null = table.num_rows - pc.sum(pc.is_null(table.column("recording_mbid"))).as_py()
        assert non_null / table.num_rows > 0.80

    def test_no_duplicate_rows(self):
        table = load_listens(DATA_DIR)
        unique = table.group_by(LISTEN_COLUMNS).aggregate([]).num_rows
        assert unique == table.num_rows

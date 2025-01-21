import inspect
import pandas
import pathlib
import pytest
from cumulus_library.databases import create_db_backend
from cumulus_library.template_sql import base_templates
from cumulus_library import base_utils, cli
import cumulus_library

@pytest.fixture
def mock_db_core_config(tmp_path):
    """Provides a DuckDatabaseBackend for local testing"""
    db, _ = create_db_backend(
        {
            "db_type": "duckdb",
            "database": f"{tmp_path}/duck.db",
            "load_ndjson_dir": "tests/test_data/duckdb_data",
        }
    )
    config = base_utils.StudyConfig(
        db=db,
        schema="main",
    )
    lib = pathlib.Path(inspect.getfile(cumulus_library)).parent
    builder = cli.StudyRunner(config, data_path=f"{tmp_path}/data_path")
    builder.clean_and_build_study(
        lib / "studies/core",
        options={},
    )
    cursor = db.cursor()
    cursor.execute("CREATE SCHEMA umls")
    for parquet in sorted(pathlib.Path("tests/test_data/icd10").iterdir()):
        df = pandas.read_parquet(parquet)
        cursor.execute(
            base_templates.get_ctas_from_parquet_query(
                schema_name='umls',
                table_name = parquet.stem,
                local_location = parquet,
                table_cols = df.columns,
                remote_location = None,
                remote_table_cols_types=None,

            )
        )
    config = base_utils.StudyConfig(db=db, schema="main")
    yield config
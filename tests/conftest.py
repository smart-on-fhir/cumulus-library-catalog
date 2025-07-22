import inspect
import pathlib

import cumulus_library
import pandas
import pytest
from cumulus_library import base_utils, cli
from cumulus_library.databases import create_db_backend
from cumulus_library.template_sql import base_templates


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
    icd10_parquet = (
        pathlib.Path(__file__).parent / "test_data/icd10_hierarchy/icd10_hierarchy.parquet"
    )
    df = pandas.read_parquet(icd10_parquet)

    cursor.execute(
        base_templates.get_ctas_from_parquet_query(
            schema_name='umls',
            table_name = icd10_parquet.stem,
            local_location = icd10_parquet,
            table_cols = df.columns,
            remote_location = None,
            remote_table_cols_types=None,

        )
    )
    config = base_utils.StudyConfig(db=db, schema="main")
    yield config
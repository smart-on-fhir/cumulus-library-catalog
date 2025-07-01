import pathlib
from cumulus_library import cli, StudyManifest

from cumulus_library_catalog.catalog import icd10_annotated_counts


def test_count_diagnoses(mock_db_core_config):
    cursor = mock_db_core_config.db.cursor()
 
    manifest=StudyManifest(study_path="./cumulus_library_catalog/")
    builder = icd10_annotated_counts.IcdCountsBuilder(manifest)
    builder.execute_queries(mock_db_core_config,manifest, min_subject=1)
    res = cursor.execute("select * from catalog__count_icd10_diagnoses").fetchall()

    # There's exactly one ICD10 code in our mock condition data, so we get a small result back.
    assert res[0] == (
        1,
        'B05.89',
        'A00-B99',
        'Certain infectious and parasitic diseases (A00-B99)',
        'B00-B09',
        'Viral infections characterized by skin and mucous membrane lesions (B00-B09)',
        'B05',
        'Measles',
        'B05.8',
        'Measles with other complications',
        'B05.89',
        'Other measles complications',
        None,
        None,
        None,
        None
    )

def test_build_study(mock_db_core_config):
    cursor = mock_db_core_config.db.cursor()
    table_count = len(cursor.execute("select * from information_schema.tables").fetchall())
    study_path = pathlib.Path(__file__).parent.parent / "cumulus_library_catalog/"
    builder = cli.StudyRunner(
        mock_db_core_config, 
        data_path=study_path
    )
    builder.clean_and_build_study(
        study_path,
        options={},
    )
    new_count = len(cursor.execute("select * from information_schema.tables").fetchall())
    assert new_count == table_count + 4


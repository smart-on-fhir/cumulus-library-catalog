import pathlib

from cumulus_library import base_utils, databases, db_config, StudyManifest

from cumulus_library_catalog.catalog import icd10_builder, icd10_counts


def test_umls_tree(tmp_path, mock_db_core_config):
    cursor = mock_db_core_config.db.cursor()
    #cursor.execute("CREATE SCHEMA umls")
    filepath = pathlib.Path.cwd() / "tests/test_data/"
    for file, columns in [
        (
            "MRCONSO",
            [
                "CUI",
                "LAT",
                "TS",
                "LUI",
                "STT",
                "SUI",
                "ISPREF",
                "AUI",
                "SAUI",
                "SCUI",
                "SDUI",
                "SAB",
                "TTY",
                "CODE",
                "STR",
                "SRL",
                "SUPPRESS",
                "CVF",
            ],
        ),
        (
            "MRREL",
            [
                "CUI1",
                "AUI1",
                "STYPE1",
                "REL",
                "CUI2",
                "AUI2",
                "STYPE2",
                "RELA",
                "RUI",
                "SRUI",
                "SAB",
                "SL",
                "RG",
                "DIR",
                "SUPPRESS",
                "CVF",
            ],
        ),
    ]:
        cursor.execute(
            f"""CREATE TABLE "umls"."{file}" AS SELECT "{'","'.join(columns)}"
        FROM read_parquet('{filepath}/{file}/{file}.parquet')"""
        )


    manifest=StudyManifest(study_path="./cumulus_library_catalog/")
    builder = icd10_builder.ICDCohortBuilder(manifest)
    builder.execute_queries(mock_db_core_config,manifest)
    res = cursor.execute("select * from catalog__icd10_cohort limit 10").fetchall()
    # TODO: on centralization of test tools, change this to point to a
    # record created via the testbed
    assert res[0] == (
        'C0348191', 'C0348191', 'B05.89', 'Other measles complications', 
        'AMB', None, 25, 'female', 'white', 'hispanic or latino', 
        'Patient/24906e2c-e556-71dc-23d9-3e1d5fb08986', 
        'Encounter/1154d05c-8727-9373-4224-25b9fdba9ab3', 'finished'
    )


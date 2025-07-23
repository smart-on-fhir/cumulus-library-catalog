import pathlib

import pytest
from cumulus_library import StudyManifest, cli

from cumulus_library_catalog.catalog import icd10_annotated_counts

"""
        
        (
            "category",
            (
                1,
                "B00-B09",
                "Viral infections characterized by skin and mucous membrane lesions (B00-B09)",
                "Measles",
                "B05",
            ),
        ),
        ("subcategory_1", (1, "B05", "Measles", "Measles with other complications", "B05.8")),
        (
            "subcategory_2",
            (
                1,
                "B05.8",
                "Measles with other complications",
                "Other measles complications",
                "B05.89",
            ),
        ),
        ("subcategory_3", ()),
        ("extension", ()),
"""


@pytest.mark.parametrize(
    "tier,expected",
    [
        ("all", (2,)),
        ("chapter", (1, "A00-B99", "Certain infectious and parasitic diseases (A00-B99)")),
        (
            "block",
            (
                1,
                "A00-B99",
                "Certain infectious and parasitic diseases (A00-B99)",
                "B00-B09",
                "Viral infections characterized by skin and mucous membrane lesions (B00-B09)",
            ),
        ),
        (
            "category",
            (
                1,
                "B00-B09",
                "Viral infections characterized by skin and mucous membrane lesions (B00-B09)",
                "B05",
                "Measles",
            ),
        ),
        ("subcategory_1", (1, "B05", "Measles", "B05.8", "Measles with other complications")),
        (
            "subcategory_2",
            (
                1,
                "B05.8",
                "Measles with other complications",
                "B05.89",
                "Other measles complications",
            ),
        ),
        ("subcategory_3", ()),
        ("extension", ()),
    ],
)
def test_count_tiers(mock_db_core_config, tier, expected):
    cursor = mock_db_core_config.db.cursor()

    manifest = StudyManifest(study_path="./cumulus_library_catalog/")
    builder = icd10_annotated_counts.IcdCountsBuilder(manifest)
    builder.execute_queries(mock_db_core_config, manifest, min_subject=1)
    res = cursor.execute(f"select * from catalog__count_icd10_{tier}").fetchall()
    if tier in ("subcategory_3", "extension"):
        assert res == []
    else:
        assert res[0] == expected


def test_build_study(mock_db_core_config):
    cursor = mock_db_core_config.db.cursor()
    table_count = len(cursor.execute("select * from information_schema.tables").fetchall())
    study_path = pathlib.Path(__file__).parent.parent / "cumulus_library_catalog/"
    builder = cli.StudyRunner(mock_db_core_config, data_path=study_path)
    builder.clean_and_build_study(
        study_path,
        options={},
    )
    new_count = len(cursor.execute("select * from information_schema.tables").fetchall())
    assert new_count == table_count + 11

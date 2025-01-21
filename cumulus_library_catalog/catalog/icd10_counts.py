import pathlib
import dataclasses

import cumulus_library
from cumulus_library import study_manifest
from cumulus_library.template_sql import base_templates


@dataclasses.dataclass(kw_only=True)
class IcdCountTable:
    name: str
    source: str
    columns: list
    count: str
    function_type: str

class ICDCohortBuilder(cumulus_library.CountsBuilder):
    display_text = "Creating ICD10 count tables..."
    tables =[  # noqa: RUF012
        #category
        IcdCountTable(
            name="catalog__count_patient_icd10_cohort_category",
            columns=[
                "icd10_category_display",
                "age_at_visit",
                "gender",
                "race_display",
                "ethnicity_display"
            ],
            source="catalog__icd10_cohort_category",
            count="subject_ref",
            function_type='patient'
        ),
        IcdCountTable(
            name="catalog__count_encounter_icd10_cohort_category",
            columns=[
                "icd10_category_display",
                "class_code",
                "servicetype_display",
            ],
            source="catalog__icd10_cohort_category",
            count="encounter_ref",
            function_type='encounter',
        ),
        #block
        IcdCountTable(
            name="catalog__count_patient_icd10_cohort_block",
            columns=[
                "icd10_block_display",
                "age_at_visit",
                "gender",
                "race_display",
                "ethnicity_display"
            ],
            source="catalog__icd10_cohort_block",
            count="subject_ref",
            function_type='patient'
        ),
        IcdCountTable(
            name="catalog__count_encounter_icd10_cohort_block",
            columns=[
                "icd10_block_display",
                "class_code",
                "servicetype_display",
            ],
            source="catalog__icd10_cohort_block",
            count="encounter_ref",
            function_type='encounter',
        ),
        #chapter
        IcdCountTable(
            name="catalog__count_patient_icd10_cohort_chapter",
            columns=[
                "icd10_chapter_display",
                "age_at_visit",
                "gender",
                "race_display",
                "ethnicity_display"
            ],
            source="catalog__icd10_cohort_chapter",
            count="subject_ref",
            function_type='patient'
        ),
        IcdCountTable(
            name="catalog__count_encounter_icd10_cohort_chapter",
            columns=[
                "icd10_chapter_display",
                "class_code",
                "servicetype_display",
            ],
            source="catalog__icd10_cohort_chapter",
            count="encounter_ref",
            function_type='encounter',
        ),
        #code
        IcdCountTable(
            name="catalog__count_patient_icd10_cohort_code",
            columns=[
                "icd10_code_parent_display",
                "age_at_visit",
                "gender",
                "race_display",
                "ethnicity_display"
            ],
            source="catalog__icd10_cohort_code",
            count="subject_ref",
            function_type='patient'
        ),
        IcdCountTable(
            name="catalog__count_encounter_icd10_cohort_code",
            columns=[
                "icd10_code_parent_display",
                "class_code",
                "servicetype_display",
            ],
            source="catalog__icd10_cohort_code",
            count="encounter_ref",
            function_type='encounter',
        ),
    ]


    def prepare_queries(
        self, *args, manifest: study_manifest.StudyManifest | None = None, **kwargs
    ):
        for count in self.tables:
            match count.function_type:
                case 'patient':
                    self.queries.append(
                        self.count_patient(
                            table_name = count.name,
                            source_table = count.source,
                            table_cols = count.columns
                        )
                    )
                case 'encounter':
                    self.queries.append(
                        self.count_encounter(
                            table_name = count.name,
                            source_table = count.source,
                            table_cols = count.columns
                        )
                    )

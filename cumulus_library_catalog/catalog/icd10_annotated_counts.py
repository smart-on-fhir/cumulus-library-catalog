import cumulus_library
from cumulus_library import study_manifest



class IcdCountsBuilder(cumulus_library.CountsBuilder):
    display_text = "Creating ICD10 counts..."
    def get_icd10_diagnosis_query(self, min_subject: int | None = None):
        """Convenience function for getting icd10 table

        Primarily exists for overriding min_subject for small bins in
        test data.
        """
        if min_subject is None:
            min_subject = 10
        return self.count_patient(
            table_name = "catalog__count_icd10_diagnoses",
            table_cols=[
                "code",
            ],
            source_table="core__condition",
            where_clauses=[
                # These codes are excluded from the catalog because they correspond
                # to sensitive conditions (mental health/STDs) that hospitals 
                # do not want to share with others for legal reasons
                "block_code not in('A50-A64','A70-A74','B20-B20')",
                "chapter_code not in('F01-F99','Z00-Z99')",
                f"cnt_subject_ref >= {min_subject}"
                ],
            annotation= cumulus_library.CountAnnotation(
                    field = 'code',
                    join_table= '"umls"."icd10_hierarchy"',
                    join_field = 'leaf_code',
                    columns= ([    
                        ('chapter_code', None),
                        ('chapter_str', None),
                        ('block_code', None),
                        ('block_str', None),
                        ('category_code', None),
                        ('category_str', None),
                        ('subcategory_1_code', None),
                        ('subcategory_1_str', None),
                        ('subcategory_2_code', None),
                        ('subcategory_2_str', None),
                        ('subcategory_3_code', None),
                        ('subcategory_3_str', None),
                        ('extension_code', None),
                        ('extension_str', None),
                    ])
                ),
            )
    def prepare_queries(
        self, 
        *args, 
        manifest: study_manifest.StudyManifest | None = None,
        min_subject: int | None=None,
        **kwargs,
    ):
        self.queries.append(
            self.get_icd10_diagnosis_query(min_subject)
        )

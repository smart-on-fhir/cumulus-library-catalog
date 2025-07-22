import cumulus_library
from cumulus_library import errors, study_manifest



class IcdCountsBuilder(cumulus_library.CountsBuilder):
    display_text = "Creating ICD10 counts..."
    def get_icd10_diagnosis_query(self, table_name, depth, min_subject: int | None = None):
        """Convenience function for getting icd10 table

        Primarily exists for overriding min_subject for small bins in
        test data.
        """
        potential_cols = [
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
        ]
        if depth *2 > len(potential_cols) | depth <=0:
            raise errors.CountsBuilderError(
                f'Requested ICD10 depth expected to be between 1 and {len(potential_cols)/2}'
            )
        annotation_cols = []
        #if not at the tree root, get the parent tier for annotation
        if depth !=1:
            annotation_cols.append(potential_cols[(depth-2)*2])
            annotation_cols.append(potential_cols[(depth-2)*2 + 1])
        annotation_cols.append(potential_cols[(depth-1)*2+1])
        annotation_cols.append(potential_cols[(depth-1)*2])
        target_col = potential_cols[(depth-1)*2][0]

        if min_subject is None:
            min_subject = 10
        return self.count_patient(
            table_name = table_name,
            source_table="core__condition",
            table_cols = ['code', 'system'],
            where_clauses=[
                # These codes are excluded from the catalog because they correspond
                # to sensitive conditions (mental health/STDs) that hospitals 
                # do not want to share with others for legal reasons
                "block_code NOT IN ('A50-A64','A70-A74','B20-B20')",
                "chapter_code NOT IN ('F01-F99','Z00-Z99')",
                f"cnt_subject_ref >= {min_subject}",
                f"{target_col} IS NOT NULL",
                "system ='http://hl7.org/fhir/sid/icd-10-cm'"
                ],
            annotation= cumulus_library.CountAnnotation(
                    field = 'code',
                    join_table= '"umls"."icd10_hierarchy"',
                    join_field = 'leaf_code',
                    columns= annotation_cols,
                    alt_target=target_col
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
            "CREATE TABLE catalog__count_icd10_all AS ("
            "SELECT count(DISTINCT subject_ref) AS cnt FROM core__condition "
            "WHERE system ='http://hl7.org/fhir/sid/icd-10-cm');"
        )
        for table_info in (
            (1,'chapter'),
            (2,'block'),
            (3,'category'),
            (4,'subcategory_1'),
            (5,'subcategory_2'),
            (6,'subcategory_3'),
            (7,'extension'),
        ):
            self.queries.append(
                self.get_icd10_diagnosis_query(
                    f"catalog__count_icd10_{table_info[1]}",
                    table_info[0],
                    min_subject
                )
            )

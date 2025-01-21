import pathlib

import cumulus_library


class ICDCohortBuilder(cumulus_library.BaseTableBuilder):
    display_text = "Creating ICD10 cohort tables..."
    def prepare_queries(self, *args, **kwargs):
        for name in ['cohort','category','block','chapter','code']:
            self.queries.append(
                cumulus_library.get_template(
                    "icd10",
                    pathlib.Path(__file__).resolve().parent / "templates/",
                    name=name,
                )
            )

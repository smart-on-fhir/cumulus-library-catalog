import pathlib

import cumulus_library
from cumulus_library.template_sql import base_templates


class ICDCohortBuilder(cumulus_library.BaseTableBuilder):
    display_text = "Creating ICD10 cohort tables..."
    def prepare_queries(self, *args, **kwargs):
        for name in ['cohort','category','block','chapter','code']:
            self.queries.append(
                base_templates.get_template(
                    "icd10",
                    pathlib.Path(__file__).resolve().parent / "templates/",
                    name=name,
                )
            )

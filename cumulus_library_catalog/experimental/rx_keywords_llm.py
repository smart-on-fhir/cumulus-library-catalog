import os, csv
from typing import List
from pathlib import Path

###############################################################################
# LLM Textual constants.
###############################################################################

LLM_RESPOND_JSON = """
Your output is a JSON dictionary with {key:value}  pairs
{"ingredient":  [list of ingredients]}
{"generic": [list of generic names]}
{"brand": [list of brand names] }
"""

LLM_INSTRUCTION = """
You are a helpful assistant tasked with providing medication names. 
Your input is a drug class from the MED-RT (Medication reference Terminology). 
I will now prompt you with a series of drug classes, and you will respond with JSON. 
"""

###############################################################################
# Clean text
###############################################################################
CLEAN_WORDS = ['[MoA]', '[EPC]', '[PE]', '[PK]', '[TC]', '[EXT]',
               '(substance)', '(medicinal product)', '(product)']

def clean_words(drug_class: str) -> str:
    for remove in CLEAN_WORDS:
        drug_class = drug_class.replace(remove, '')
    return drug_class

###############################################################################
# Paths
###############################################################################

def path_download(filename: str) -> Path:
    return Path(os.path.join(os.path.dirname(__file__)), '..', 'download', filename)

def path_prompts(filename: str) -> Path:
    return Path(os.path.join(os.path.dirname(__file__)), '..', 'prompts', filename)

def path_medrt_drugs_leaf(filename='medrt_drugs_leaf.csv'):
    return path_download(filename)


###############################################################################
# Drug Class
###############################################################################

class DrugClass:
    cui1: str = None
    cui2: str = None
    medrt: str = None

    def __init__(self, cui1: str, cui2: str, medrt: str):
        """
        :param cui1: CUI of the MED-RT derived "parent".
        :param cui2: CUI of the MED-RT dervied "child".
        :param medrt: parent:child name to supply to LLM.
        """
        self.cui1 = cui1
        self.cui2 = cui2
        self.medrt = medrt

    def key(self):
        return f'{self.cui1}_{self.cui2}'

    def filename(self):
        return self.key() + '.txt'

    def filepath(self):
        return path_prompts(self.filename())

    def prompt(self) -> str:
        cleaner = clean_words(self.medrt)
        drug_class = f'What are the medications associated with the drug class: "{cleaner}" ?\n'
        return drug_class + LLM_RESPOND_JSON

    @staticmethod
    def load_saved() -> List:
        """
        :return: List[DrugClass]
        """
        seen = dict()
        output = list()
        with open(path_medrt_drugs_leaf(), 'r') as csv_file:
            for row in csv.reader(csv_file, delimiter=',', quotechar='"'):
                cui1 = row[0]
                cui2 = row[1]
                medrt = row[2]

                if cui1 not in seen.keys():
                    seen[cui1] = list()
                if cui2 not in seen.get(cui1):
                    output.append(DrugClass(cui1, cui2, medrt))
                    seen[cui1].append(cui2)
        return output

###############################################################################
# Make
###############################################################################

def make_llm_prompts() -> List[str]:
    manifest = list()
    for drug_class in DrugClass.load_saved():
        with open(drug_class.filepath(), 'w') as fp:
            text = drug_class.prompt()
            fp.write(text)
            manifest.append(drug_class.filepath())
    return manifest


if __name__ == "__main__":
    outputs = make_llm_prompts()
    outputs = [str(f) for f in outputs]
    print('\n'.join(outputs))

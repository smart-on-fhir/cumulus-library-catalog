import os
import csv
import hashlib
from typing import List
from pathlib import Path

###############################################################################
# LLM Textual constants.
###############################################################################

LLM_RESPOND_JSON = """
Do NOT list sources. 
Do NOT explain your answer.
 
Respond using a JSON dictionary with {key:value}  pairs
{"ingredient":  [list of ingredients]}
{"generic": [list of generic names]}
{"brand": [list of brand names]}
"""

LLM_INSTRUCTION = """
You are a helpful assistant tasked with providing medication names. 
Your input is a drug class from the MED-RT (Medication reference Terminology). 
I will now prompt you with a series of drug classes and you will respond with JSON.  
"""

LLM_TTY = {
    'PIN': 'precise ingredient',
    'IN': 'ingredient',
    'GN': 'generic name',
    'BN': 'brand name',
    'SU': 'active substance'
}

###############################################################################
# Clean text
###############################################################################
CLEAN_TEXT = ['[MoA]', '[EPC]', '[PE]', '[PK]', '[TC]', '[EXT]',
              '(substance)', '(medicinal product)', '(product)']

def clean_text(drug_class: str) -> str:
    for remove in CLEAN_TEXT:
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

def path_medrt_keywords(filename='medrt_drugs_keywords.csv'):
    return path_download(filename)

###############################################################################
# Drug Class
###############################################################################

class DrugClass:
    cui1: str = None
    cui2: str = None
    label: str = None

    def __init__(self, cui1: str, cui2: str, medrt: str):
        """
        :param cui1: CUI of the MED-RT derived "parent".
        :param cui2: CUI of the MED-RT dervied "child".
        :param medrt: parent:child name to supply to LLM.
        """
        self.cui1 = cui1
        self.cui2 = cui2
        self.label = medrt

    def key(self):
        return f'{self.cui1}_{self.cui2}'

    def path_prompt(self):
        return path_prompts(self.key() + '.txt')

    def prompt(self) -> str:
        _drug_class = clean_text(self.label)
        question = f'What are the medications associated with the drug class: "{_drug_class}" ?\n'
        return question + LLM_RESPOND_JSON

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

                if cui1 != 'CUI1': #skip header
                    if cui1 not in seen.keys():
                        seen[cui1] = list()
                    if cui2 not in seen.get(cui1):
                        output.append(DrugClass(cui1, cui2, medrt))
                        seen[cui1].append(cui2)
        return output

###############################################################################
# DrugAlias
###############################################################################

class DrugKeyword:
    tty: str = None
    label: str = None

    def __init__(self, tty: str, text: str):
        """
        :param tty: CUI of the MED-RT derived "parent".
        :param text: CUI of the MED-RT dervied "child".
        :param medrt: parent:child name to supply to LLM.
        """
        self.tty = tty
        self.label = text

    def key(self):
        short = hashlib.sha256(self.label.lower().encode()).hexdigest()[:8]
        return f'alias_{self.tty}_{short}'

    def path_prompt(self) -> Path:
        return path_prompts(self.key() + '.txt')

    def prompt(self) -> str:
        _label = self.label.title()
        _tty = LLM_TTY[self.tty]
        question = f'What are the medications associated with the {_tty} "{_label}" ?\n'
        return question + LLM_RESPOND_JSON

    @staticmethod
    def load_saved() -> List:
        """
        :return: List[DrugClass]
        """
        output = list()
        with open(path_medrt_keywords(), 'r') as csv_file:
            for row in csv.reader(csv_file, delimiter=',', quotechar='"'):
                tty = row[0]
                label = row[1]
                if tty in LLM_TTY.keys():
                    output.append(DrugKeyword(tty, label))
        return output


###############################################################################
# Make
###############################################################################

def make_drug_class() -> List[str]:
    manifest = list()
    for drug_class in DrugClass.load_saved():
        with open(drug_class.path_prompt(), 'w') as fp:
            text = drug_class.prompt()
            fp.write(text)
            manifest.append(drug_class.path_prompt())
    return manifest

def make_drug_alias() -> List[str]:
    manifest = list()
    for drug_alias in DrugKeyword.load_saved():
        with open(drug_alias.path_prompt(), 'w') as fp:
            text = drug_alias.prompt()
            fp.write(text)
            manifest.append(drug_alias.path_prompt())
    return manifest


if __name__ == "__main__":
    outputs = make_drug_class() + make_drug_alias()
    outputs = [str(f) for f in outputs]
    print('\n'.join(outputs))

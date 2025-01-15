from pathlib import Path
from typing import List, Dict
from collections import OrderedDict
from cumulus_library_catalog.rx_keywords import filetool

def sort_dict_value(unsorted: dict, reverse=True) -> OrderedDict:
    return OrderedDict(sorted(unsorted.items(), key=lambda item: item[1], reverse=reverse))

def term_freq(term_list: List[str]) -> Dict[str, int]:
    freq = dict()
    term_list = [term.lower() for term in term_list]
    for term in term_list:
        if term not in freq.keys():
            freq[term] = list()
        freq[term].append(term)

    out = {key: len(values) for key, values in freq.items()}
    return sort_dict_value(out)

def file_glob(expression: str) -> List[Path]:
    iter = filetool.path_prompts().glob(expression)
    return [Path(i) for i in iter]

def list_files() -> List[Path]:
    return file_glob('C*_C*.json')

def parse_filename(filename: Path) -> (str, str):
    simple = filename.name.replace('.json', '')
    cui1, cui2 = simple.split('_')
    return cui1, cui2

def make():
    merged = dict()
    merged['term'] = list()
    merged['ingredient'] = list()
    merged['brand'] = list()
    merged['generic'] = list()

    for filepath in list_files():
        answer = filetool.read_json(filepath)
        cui1, cui2 = parse_filename(filepath)

        if cui1 not in merged.keys():
            merged[cui1] = dict()
        if cui2 not in merged[cui1].keys():
            merged[cui1][cui2] = dict()

        ingredient = answer.get('ingredient', list())
        generic = answer.get('generic', list())
        brand = answer.get('brand', list())

        merged['term'] += ingredient + generic + brand
        merged['ingredient'] += ingredient
        merged['generic'] += generic
        merged['brand'] += brand

        merged[cui1][cui2]['ingredient'] = ingredient
        merged[cui1][cui2]['generic'] = generic
        merged[cui1][cui2]['brand'] = brand

    # calculate overlapping terms
    term_set = set([term.lower() for term in merged['term']])
    overlap = dict()
    for term1 in term_set:
        for term2 in term_set:
            if term1 != term2:
                if term1 in term2:
                    if term1 not in overlap:
                        overlap[term1] = list()
                    overlap[term1].append(term2)

    merged['overlap'] = overlap
    merged['term'] = term_freq(merged['term'])
    merged['ingredient'] = term_freq(merged['ingredient'])
    merged['generic'] = term_freq(merged['generic'])
    merged['brand'] = term_freq(merged['brand'])

    filetool.write_json(merged, filetool.path_prompts('merged_cui1_cui2.json'))


if __name__ == "__main__":
    make()

import os
import json
from typing import List, Dict, Any
from pathlib import Path

###############################################################################
# Paths
###############################################################################

def path_download(filename: str = None) -> Path:
    if filename:
        return Path(os.path.join(os.path.dirname(__file__)), '..', 'download', filename)
    else:
        return Path(os.path.join(os.path.dirname(__file__)), '..', 'download')

def path_prompts(filename: str = None) -> Path:
    if filename:
        return Path(os.path.join(os.path.dirname(__file__)), '..', 'prompts', filename)
    else:
        return Path(os.path.join(os.path.dirname(__file__)), '..', 'prompts')

def path_medrt_drugs_leaf(filename='medrt_drugs_leaf.csv'):
    return path_download(filename)

def path_medrt_keywords(filename='medrt_drugs_keywords.csv'):
    return path_download(filename)

def file_exists(filename: Path | str) -> bool:
    """
    FAIL FAST if not exists `filename`
    :param filename: check for existance
    :return: BOOL True or raise exception (fail fast)
    """
    target = Path(filename)
    if not target.exists():
        raise Exception('file not found: ' + str(target))
    return True

###############################################################################
#
# Read/Write Text
#
###############################################################################

def read_text(text_file: Path | str, encoding: str = 'UTF-8') -> str:
    """
    Read text from file
    :param text_file: absolute path to file
    :param encoding: provided file's encoding
    :return: file text contents
    """
    if file_exists(text_file):
        with open(file=text_file, encoding=encoding) as t_file:
            return t_file.read()

###############################################################################
#
# Read/Write JSON
#
###############################################################################
def read_json(json_file: Path | str, encoding: str = 'UTF-8') -> Dict[Any, Any]:
    """
    Read json from file
    :param json_file: absolute path to file
    :param encoding: provided file's encoding
    :return: json file contents
    """
    if file_exists(json_file):
        with open(file=json_file, encoding=encoding) as j_file:
            return json.load(j_file)

def write_json(contents: Dict[Any, Any], json_file_path: Path | str, encoding: str = 'UTF-8') -> Path:
    """
    Write JSON to file
    :param contents: json (dict) contents
    :param json_file_path: absolute destination file path
    :param encoding: provided file's encoding
    :return: file name
    """
    directory = os.path.dirname(json_file_path)
    os.makedirs(directory, exist_ok=True)
    with open(file=json_file_path, mode='w', encoding=encoding) as json_file_path:
        json.dump(contents, json_file_path, indent=4)
        return Path(json_file_path.name)

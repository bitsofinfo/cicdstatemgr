#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
"""

import collections.abc
import os

# https://gist.github.com/angstwad/bf22d1822c38a92ec0a9
def dict_merge(*args, add_keys=True, append_to_lists=False):
    assert len(args) >= 2, "dict_merge requires at least two dicts to merge"
    rtn_dct = args[0].copy()
    merge_dicts = args[1:]
    for merge_dct in merge_dicts:
        if add_keys is False:
            merge_dct = {key: merge_dct[key] for key in set(rtn_dct).intersection(set(merge_dct))}
        for k, v in merge_dct.items():
            if not rtn_dct.get(k):
                rtn_dct[k] = v
            elif k in rtn_dct and type(v) != type(rtn_dct[k]):
                raise TypeError(f"Overlapping keys exist with different types: original is {type(rtn_dct[k])}, new value is {type(v)}")
            elif isinstance(rtn_dct[k], dict) and isinstance(merge_dct[k], collections.abc.Mapping):
                rtn_dct[k] = dict_merge(rtn_dct[k], merge_dct[k], add_keys=add_keys)
            elif isinstance(v, list) and append_to_lists:
                for list_value in v:
                    if list_value not in rtn_dct[k]:
                        rtn_dct[k].append(list_value)
            else:
                rtn_dct[k] = v
    return rtn_dct


def get_file_path(filePath:str):
    if filePath and not filePath.startswith('./') and not filePath.startswith('/'):
        filePath = os.path.join(os.getcwd(),filePath)
        filePath = os.path.abspath(os.path.realpath(filePath))

    return filePath
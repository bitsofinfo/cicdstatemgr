#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
"""

import os
import collections.abc
import logging
import re

from . import CicdContextDataSource
from ..utils import get_file_path

class DataSource(CicdContextDataSource):
    filePath = None
    isPrimary = False
    excludeKeyNames = []

    def __init__(self, config=dict):
        self.filePath = config['path']
        if 'excludeKeyNames' in config:
            self.excludeKeyNames = config['excludeKeyNames']

        if 'isPrimary' in config:
            self.isPrimary = config['isPrimary']

        self.filePath = get_file_path(self.filePath)

        logging.debug("{} -> {} isPrimary:{} isLocal:{}".format(self.get_name(),self.filePath,self.isPrimary,self.is_local()))

    def is_local(self) -> bool:
        return True

    def get_name(self) -> str:
        return 'shellfile'

    def is_primary(self) -> bool:
        return self.isPrimary

    def flatten(self, d, parent_key='', sep="__"):
        items = []
        for k, v in d.items():

            # skip.... if key is in excludes
            if self.excludeKeyNames and k in self.excludeKeyNames:
                continue

            if isinstance(v,list) and len(v) > 0:
                for i in range(len(v)):
                    new_key = parent_key + sep + k + sep + str(i) if parent_key else k
                    itemVal = v[i]
                    if isinstance(itemVal, collections.abc.MutableMapping):
                        items.extend(self.flatten(itemVal, new_key, sep=sep).items())
                    else:
                        items.append((new_key, itemVal))
            else:
                new_key = parent_key + sep + k if parent_key else k
                if isinstance(v, collections.abc.MutableMapping):
                    items.extend(self.flatten(v, new_key, sep=sep).items())
                else:
                    items.append((new_key, v))
        return dict(items)

    def supports_load(self) -> bool:
        return False

    def persist(self,  cicdContextDataId:str, cicdContextData:object):

        os.makedirs(os.path.dirname(self.filePath),exist_ok=True)

        kvMap = self.flatten(cicdContextData)

        shellVars = ""
        for prop in kvMap:
            if kvMap[prop]:
                propVal = kvMap[prop]
                if propVal and isinstance(propVal,str):
                    propVal = propVal.replace('`','\`').replace('"','\"')

                shellVars += "CICD_{}=\"{}\"\n".format(re.sub('[^0-9a-zA-Z_]+', '_', prop),propVal)

        with open(self.filePath,'w') as f:
            f.write(shellVars)

    def load(self, cicdContextDataId:str) -> dict:
        raise NotImplementedError

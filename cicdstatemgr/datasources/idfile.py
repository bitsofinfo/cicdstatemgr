#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
"""

import yaml
import os
import logging

from . import CicdContextDataSource

from ..utils import get_file_path

class DataSource(CicdContextDataSource):
    filePath = None
    isPrimary = False

    def __init__(self, config=dict):
        self.filePath = config['path']

        if 'isPrimary' in config:
            self.isPrimary = config['isPrimary']

        self.filePath = get_file_path(self.filePath)

        logging.debug("{} -> {} isPrimary:{} isLocal:{}".format(self.get_name(),self.filePath,self.isPrimary,self.is_local()))

    def is_local(self) -> bool:
        return True

    def supports_load(self) -> bool:
        return False

    def get_name(self) -> str:
        return 'idfile'

    def is_primary(self) -> bool:
        return self.isPrimary

    def persist(self, cicdContextDataId:str, cicdContextData:object):
        os.makedirs(os.path.dirname(self.filePath),exist_ok=True)
        with open(self.filePath, 'w') as f:
            f.write(cicdContextDataId)

    def load(self, cicdContextDataId:str) -> dict:
        raise Exception("idfile does not support load()")

#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
"""

CONFIG_DATA_KEY = "cicdstatemgr"
SECRET_DATA_KEY = "cicdstatemgr"
STATE = 'state'
CONFIG_DATA = 'configData'
SECRET_DATA = 'secretData'
CICD_CONTEXT_DATA_ID = 'cicdContextDataId'
CICD_CONTEXT_NAME = 'cicdContextName'

class CicdContextData():
    cicdContextData:dict

    def __init__(self,cicdContextData:dict):
        self.cicdContextData = cicdContextData


    def getCicdContextDataId(self) -> str:
        return self.cicdContextData[STATE][CICD_CONTEXT_DATA_ID]


    def getCicdContextData(self) -> str:
        return self.cicdContextData
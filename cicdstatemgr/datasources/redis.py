#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
"""

import yaml
import os
import redis
import logging

from . import CicdContextDataSource

class DataSource(CicdContextDataSource):
    host = "localhost"
    port = 6379
    db = 0
    conn = None
    password = None
    username = 'default'
    isPrimary = False

    def __init__(self, config:dict):
        self.host =  config['host'] if 'host' in config else None
        self.port = config['port'] if 'port' in config else None
        self.db = config['db'] if 'db' in config else None
        self.password = config['password'] if 'password' in config else None
        self.username = config['username'] if 'username' in config else None

        if 'isPrimary' in config:
            self.isPrimary = config['isPrimary']

        self.init()

        logging.debug("{} -> {} isPrimary:{} isLocal:{}".format(self.get_name(),self.host,self.isPrimary,self.is_local()))

    def is_local(self) -> bool:
        return False

    def get_name(self) -> str:
        return 'redis'

    def is_primary(self) -> bool:
        return self.isPrimary

    def init(self):
        self.conn = redis.Redis(host=self.host, port=self.port, db=self.db, username=self.username, password=self.password)

    def persist(self, cicdContextDataId:str, cicdContextData:object):
        obj = yaml.dump(cicdContextData, default_flow_style=False, sort_keys=False)
        self.conn.set(cicdContextDataId, obj)

    def load(self, cicdContextDataId:str) -> dict:
        self.init()
        yamlStr = self.conn.get(cicdContextDataId)
        return yaml.load(yamlStr, Loader=yaml.FullLoader)

    def supports_load(self) -> bool:
        return True

#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
"""

import abc
import logging
import importlib

from .. import CicdContextData

class CicdContextDataSource(metaclass=abc.ABCMeta):
    @classmethod
    def __subclasshook__(cls, subclass):
        return (hasattr(subclass, 'persist') and 
                callable(subclass.persist) and 
                hasattr(subclass, 'load') and 
                callable(subclass.load) or 
                NotImplemented)

    @abc.abstractmethod
    def get_name(self) -> str:
        raise NotImplementedError

    @abc.abstractmethod
    def is_primary(self) -> bool:
        raise NotImplementedError

    @abc.abstractmethod
    def is_local(self) -> bool:
        raise NotImplementedError

    @abc.abstractmethod
    def persist(self,  cicdContextDataId:str, cicdContextData:object):
        raise NotImplementedError

    @abc.abstractmethod
    def load(self, cicdContextDataId:str) -> dict:
        raise NotImplementedError

    @abc.abstractmethod
    def supports_load(self) -> bool:
        raise NotImplementedError


class DataSourceMgr():

    dataSources:dict = {}
    primaryDataSource:CicdContextDataSource = None

    def __init__(self, dsConfigs:dict):
        for dsName in dsConfigs:
            logging.debug("DataSourceMgr() Initializing datasource: {}".format(dsName))

            try:
                module = importlib.import_module('.{}'.format(dsName), package=__name__)
                ds = module.DataSource(dsConfigs[dsName])
                self.dataSources[dsName] = ds
                if ds.is_primary():
                    if self.primaryDataSource:
                        logging.error("DataSourceMgr() you cannot have more than one isPrimary data source defined: {} , current primary = {}".format(dsName,self.primaryDataSource.get_name()))
                    else:
                        logging.info("DataSourceMgr() primary ds = {}".format(dsName))
                        self.primaryDataSource = ds

            except ModuleNotFoundError as e:
                logging.error("No datasource module found by name: {} .. ignoring".format(dsName))

        if not self.primaryDataSource:
            raise Exception("DataSourceMgr() you have no isPrimary=True datasource configured! Invalid")

    def persist(self, cicdContextData:CicdContextData, skipPrimary=False):
        logging.debug("DataSourceMgr.persist() skipPrimary={} cicdContextDataId={}".format(skipPrimary,cicdContextData.getCicdContextDataId()))

        for dsName in self.dataSources:
            ds = self.dataSources[dsName]
            if skipPrimary and ds.is_primary():
                logging.debug("DataSourceMgr.persist() skipping primary: {} as skipPrimary={}".format(dsName,skipPrimary))
                continue

            logging.debug("DataSourceMgr.persist() persisting in: {}".format(dsName))
            ds.persist(cicdContextData.getCicdContextDataId(),cicdContextData.getCicdContextData())

    def load(self, cicdContextDataId:str, fromPrimary=True, fromLocal=False):
        logging.debug("DataSourceMgr.load() fromPrimary={} fromLocal={} cicdContextDataId={}".format(fromPrimary,fromLocal,cicdContextDataId))

        if fromPrimary and self.primaryDataSource.is_primary():

            if fromLocal and not self.primaryDataSource.is_local():
                raise Exception("DataSourceMgr.load() cannot pass " + \
                    "fromPrimary={} and fromLocal={} as the primaryDataSource[{}] is_local()=false".format(fromPrimary,fromLocal,self.primaryDataSource.get_name()))

            return self.primaryDataSource.load(cicdContextDataId)
            
        else:
            for dsName in self.dataSources:
                ds = self.dataSources[dsName]
                if not ds.is_primary() and ds.supports_load():
                    if fromLocal and ds.is_local():
                        logging.debug("DataSourceMgr.load() loading from {}".format(dsName))
                        return ds.load(cicdContextDataId)

        raise Exception("DataSourceMgr.load() cannot pass " + \
            "fromPrimary={} and fromLocal={}, no datasources meet this criteria".format(fromPrimary,fromLocal))


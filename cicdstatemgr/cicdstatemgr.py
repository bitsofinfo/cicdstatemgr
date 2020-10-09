#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
"""

import argparse
import yaml
import redis
import json
import os
import sys
import collections.abc
import re
import jsonpath_ng 
import requests
import datetime
import logging
import time 
import pprint
import copy
import base64

from importlib import import_module

from jinja2 import Environment, Template


from .jinja2util import createEnvironment
from .datasources import CicdContextData
from .datasources import DataSourceMgr
from .utils import dict_merge, get_file_path

__author__ = "bitsofinfo"

CONFIG_DATA_KEY = "cicdstatemgr"
SECRET_DATA_KEY = "cicdstatemgr"
STATE = 'state'
CONFIG_DATA = 'configData'
SECRET_DATA = 'secretData'
CICD_CONTEXT_DATA_ID = 'cicdContextDataId'
CICD_CONTEXT_NAME = 'cicdContextName'


class InitializeArgs():

    cicdContextDataId:str = None
    cicdContextName:str = None
    appConfigFilePathstr:str = None
    appConfigFileBasesDirPath:str = None
    valuesToSet:list = None
    eventPipelineName:str = None
    tmplCtxVars:list = None
    eventNameToFire:str = None

    def __init__(self, cicdContextDataId,
                        cicdContextName, 
                        appConfigFilePath,
                        appConfigFileBasesDirPath,
                        valuesToSet,
                        eventPipelineName,
                        tmplCtxVars,
                        eventNameToFire):

        self.cicdContextDataId = cicdContextDataId
        self.cicdContextName = cicdContextName
        self.appConfigFilePath = appConfigFilePath
        self.appConfigFileBasesDirPath = appConfigFileBasesDirPath
        self.valuesToSet = valuesToSet
        self.eventPipelineName = eventPipelineName
        self.tmplCtxVars = tmplCtxVars
        self.eventNameToFire = eventNameToFire
    
class LoadArgs():

    cicdContextDataId:str = None
    valuesToSet:list = None
    eventPipelineName:str = None
    eventNameToFire:str = None
    tmplCtxVars:list = None

    def __init__(self, cicdContextDataId,
                    valuesToSet,
                    eventPipelineName,
                    eventNameToFire,
                    tmplCtxVars):

        self.cicdContextDataId = cicdContextDataId
        self.valuesToSet = valuesToSet
        self.eventPipelineName = eventPipelineName
        self.eventNameToFire = eventNameToFire
        self.tmplCtxVars = tmplCtxVars

class GetArgs():

    cicdContextDataId:str = None
    expression:str = None
    tmplCtxVars:list = None

    def __init__(self, cicdContextDataId, expression, tmplCtxVars):
        self.cicdContextDataId = cicdContextDataId
        self.expression = expression
        self.tmplCtxVars = tmplCtxVars

class GenerateArgs():

    cicdContextDataId:str = None
    generatorKeyPath:str = None

    def __init__(self, cicdContextDataId, generatorKeyPath):
        self.cicdContextDataId = cicdContextDataId
        self.generatorKeyPath = generatorKeyPath

class HandleEventArgs():

    cicdContextDataId:str = None
    eventNameToFire:str = None
    eventPipelineName:str = None
    tmplCtxVars:list = None
    valuesToSet:list = None 
    preSetValuesForceReload:bool = False

    def __init__(self, eventNameToFire, cicdContextDataId, eventPipelineName, tmplCtxVars, valuesToSet, preSetValuesForceReload):
        self.cicdContextDataId = cicdContextDataId
        self.eventNameToFire = eventNameToFire
        self.eventPipelineName = eventPipelineName
        self.tmplCtxVars = tmplCtxVars
        self.valuesToSet = valuesToSet
        self.preSetValuesForceReload = preSetValuesForceReload


class SetArgs():

    cicdContextDataId:str = None
    valuesToSet:list = None
    preSetValuesForceReload:bool = False

    def __init__(self, cicdContextDataId, valuesToSet, preSetValuesForceReload):
        self.cicdContextDataId = cicdContextDataId
        self.valuesToSet = valuesToSet
        self.preSetValuesForceReload = preSetValuesForceReload


class CicdStateMgr():

    configData = None
    secretData = None
    dataSourceMgr = None
 
    jinja2Environment = createEnvironment()

    def __init__(self, configFilePath:str=None, secretsFilePath:str=None):

        configFilePath = get_file_path(configFilePath)
        secretsFilePath = get_file_path(secretsFilePath)
        
        with open(configFilePath) as f:
            self.configData = yaml.load(f, Loader=yaml.FullLoader)

        if secretsFilePath:
            with open(secretsFilePath) as f:
                self.secretData = yaml.load(f, Loader=yaml.FullLoader)

        # create all data sources
        dsConfigs = copy.deepcopy(self.configData[CONFIG_DATA_KEY]["datasources"])
        if self.secretData and 'datasources' in self.secretData[SECRET_DATA_KEY]:
            dsConfigs = dict_merge(dsConfigs,copy.deepcopy(self.secretData[SECRET_DATA_KEY]["datasources"]))
        self.dataSourceMgr = DataSourceMgr(dsConfigs)


    def parse_template(self, template, context, blankOnError=False):

        if not template and blankOnError:
            return ""

        origTemplate = template

        if 'jinja2Macros' in context:
            allMacros = context['jinja2Macros']['all']
            template = allMacros+template
 
        try:
            result = self.jinja2Environment.from_string(template).render(context)
            return result
        except Exception as e:
            logging.error("parse_template() template = {} error: {}".format(origTemplate,str(sys.exc_info()[:2])))
            if blankOnError:
                return ""
            else:
                return "<jinja2 parse error> {}".format(origTemplate)

    def persist(self, cicdContextData, skipPrimary=False):
        logging.debug("persist() skipPrimary={} cicdContextDataId={}".format(skipPrimary,cicdContextData[STATE][CICD_CONTEXT_DATA_ID]))
        self.dataSourceMgr.persist(CicdContextData(cicdContextData),skipPrimary=skipPrimary)

    def initialize(self, id:str, 
                    cicdContextName:str, 
                    pathToAppCicdConfigYamlFile:str, 
                    basesDir:str, 
                    valsToSet:str, 
                    eventPipelineName:str, 
                    eventNameToFire:str,
                    tmplCtxVars:list) -> CicdContextData:
        
        logging.debug("initialize() id={} cicdContextName={} pathToAppCicdConfigYamlFile={} basesDir={} eventPipelineName={} eventNameToFire={} tmplCtxVars={}".format(id, cicdContextName, pathToAppCicdConfigYamlFile, basesDir, eventPipelineName, eventNameToFire, tmplCtxVars))
    
        # the identifier for this context data
        cicdContextDataId = id

        # load the apps pipeline file
        pathToAppCicdConfigYamlFile = get_file_path(pathToAppCicdConfigYamlFile)

        logging.debug("initialize() loading app pipeline template: " + pathToAppCicdConfigYamlFile)
        
        with open(pathToAppCicdConfigYamlFile,'r') as f:
            appPipelineConfig = yaml.load(f, Loader=yaml.FullLoader)

        # our base pipeline config object that we will build
        cicdConfig = {}

        # merge all specified bases into cicdConfig, in order
        if 'bases' in appPipelineConfig and isinstance(appPipelineConfig['bases'],list):
            for baseTemplateFileName in appPipelineConfig['bases']:

                baseTemplatePath = basesDir + "/" + baseTemplateFileName
                if not os.path.exists(baseTemplatePath):
                    logging.error("initialize() base pipeline template does not exists: {}".format(baseTemplatePath))
                    sys.exit(1)

                logging.debug("initialize() applying base pipeline template: " + baseTemplatePath)
                with open(baseTemplatePath,'r') as f:
                    baseTemplate = yaml.load(f, Loader=yaml.FullLoader)
                    cicdConfig = dict_merge(cicdConfig,baseTemplate)

        # finally merge the appPipelineConfig into the final product...
        cicdConfig = dict_merge(cicdConfig,appPipelineConfig)

        # now we have a final config to begin to update
        # here we grab the requested cicdContextName out of the 
        # cicdConfig object and that becomes our cicdContextData
        cicdContextData = cicdConfig['cicd-contexts'][cicdContextName]

        # We also store within the cicdContextData a copy of the original
        # appPipelineConfig, as we swithc cicdContexts in the future this
        # is consulted for setting up new cicdContextData objects
        cicdContextData['appPipelinesConfig'] = copy.deepcopy(appPipelineConfig)

        # transfer over macros
        cicdContextData['jinja2Macros'] = {
            'byName': {},
            'all': ""
        }
        if 'jinja2-macros' in cicdConfig:
            for m in cicdConfig['jinja2-macros']:
                cicdContextData['jinja2Macros']['byName'][m] = cicdConfig['jinja2-macros'][m]
                cicdContextData['jinja2Macros']['all'] += cicdConfig['jinja2-macros'][m].strip() # we strip! to avoid adding extra whitespace

        # build the state object
        cicdContextData[STATE] = { 
                                CICD_CONTEXT_DATA_ID: cicdContextDataId,
                                CICD_CONTEXT_NAME: cicdContextName
                                }

        # set any additional values provided via --set
        self.set_values_in_dict_via_pro_path_kvpairs(cicdContextData,valsToSet)

        # transfer over variables (we do this AFTER state is initialized)
        # as variables can reference the config itself (i.e. templates)
        if 'variables' in cicdConfig:
            for v in cicdConfig['variables']:
                if 'variables' not in cicdContextData:
                    cicdContextData['variables'] = {}
                cicdContextData['variables'][v] = self.parse_template(cicdConfig['variables'][v],cicdContextData)

        # handle --handle-event args if passed  (do not persist)
        if eventNameToFire and eventPipelineName:    
            self.on_event_handler(eventNameToFire,cicdContextData, \
                            eventPipelineName,tmplCtxVars,
                            persistCicdContextData=False)
            
        #pprint.pprint(cicdContextData)
        #sys.exit(1)

        # persist it all
        self.persist(cicdContextData,skipPrimary=False)

        return CicdContextData(cicdContextData)


    def load(self, cicdContextDataId:str, valsToSet:str=None, eventPipelineName:str=None, eventNameToFire:str=None, tmplCtxVars:list=None):

        logging.debug("load() {}".format(cicdContextDataId))

        cicdContextData = self.dataSourceMgr.load(cicdContextDataId,fromPrimary=True)

        if not cicdContextData:
            raise Exception("load() {} cicdContextData is NULL...".format(cicdContextDataId))

        # set any additional values provided via --set
        if valsToSet:
            self.set_values_in_dict_via_pro_path_kvpairs(cicdContextData,valsToSet)

        # handle --handle-event args if passed  (do not persist)
        if eventNameToFire and eventPipelineName:    
            self.on_event_handler(eventNameToFire,cicdContextData, \
                            eventPipelineName,tmplCtxVars,
                            persistCicdContextData=False)

        # persist!
        self.persist(cicdContextData)

        return cicdContextData


    def get_cicd_context_data(self, cicdContextDataId):
        
        # try from local non-primary first
        cicdContextData = self.dataSourceMgr.load(cicdContextDataId,fromPrimary=False, fromLocal=True)

        if not cicdContextData:
            cicdContextData = self.dataSourceMgr.load(cicdContextDataId,fromPrimary=True)
            self.persist(cicdContextData,skipPrimary=True) # skip back to primary

        return cicdContextData

    def generate(self, cicdContextDataId:str, generatorKeyPath:str):
        cicdContextData = self.get_cicd_context_data(cicdContextDataId)
        
        logging.debug("generate() attempting to invoke generator at: {}".format(generatorKeyPath))

        parsed = jsonpath_ng.parse(generatorKeyPath)

        match = parsed.find(cicdContextData)

        if match and (len(match) > 1 or len(match) == 0):
            logging.error("generate() generatorKeyPath:{}, the generatorKeyPath yielded nothing OR more than one value... {}".format(generatorKeyPath,match) + \
                " The generatorKeyPath should only return a single object in the cicdContextData, that contains a 'set[{key=?,value=?},...]' configuration and optional 'if' condition")
            sys.exit(1)

        generatorConfig = match[0].value
        mustPersist = False

        for generatorItemName, generatorItemConfig in generatorConfig.items():

            logging.debug("generate() processing generator item: {}".format(generatorItemName))

            templateContext = self.create_custom_template_context('generator',generatorItemConfig,cicdContextData,None)

            # if we didn't get a value back, exit quick (note blankOnError=True)
            if 'if' in generatorItemConfig and not self.parse_template(generatorItemConfig.get('if'),templateContext,blankOnError=True).strip():
                logging.debug("generate() {}.if for {} did not yield anything, ".format(generatorItemName,generatorKeyPath) + \
                    "nothing todo. generatorItemConfig['if']={}".format(generatorItemConfig.get('if')))
                continue

            # if the 'if" did return something, then we can proceed
            for keyValueConf in generatorItemConfig['set']:
                keyToSet = self.parse_template(keyValueConf['key'],templateContext)
                if keyToSet and isinstance(keyToSet,str):
                    valueToSet = keyValueConf['value']
                    if valueToSet:
                        valueToSet = self.parse_template(valueToSet,templateContext)
                        self.set_value_in_dict_via_prop_path(cicdContextData, keyToSet.strip(), valueToSet)
                        mustPersist = True

        # persist everything
        if mustPersist:
            self.persist(cicdContextData,skipPrimary=False)



    def get_value(self, cicdContextDataId:str, propPath:str, tmplCtxVars:list):
        
        cicdContextData = self.get_cicd_context_data(cicdContextDataId)

        logging.debug("get_value() attempting to get: {}".format(propPath))

        parsed = jsonpath_ng.parse(propPath)

        match = parsed.find(cicdContextData)

        toReturn = None

        if match and len(match) > 1:
            tmp = []
            for v in match:
                tmp.append(v.value)

            toReturn = tmp

        elif len(match) == 1:
            toReturn = match[0].value

        if toReturn and isinstance(toReturn,str):
            templateContext = self.create_template_context(cicdContextData,tmplCtxVars)
            return self.parse_template(toReturn,templateContext) 
        else:
            logging.warning("get_value() propPath:{} tmplCtxVars:{}, the propPath yielded a non-string value {}".format(propPath,tmplCtxVars,toReturn) + \
                " I cannot parse the value as a template... returning object {} as-is (JSON marshalled)".format(str(type(toReturn))))

        if isinstance(toReturn,list):
            return json.dumps(toReturn)

        return toReturn



    def recursive_set(self, propPath:str, value:object, mapp:dict, parentKey:str=None):

        logging.debug("recursive_set() setting {} to {} within parent of: {}".format(propPath,value,parentKey))

        parts = propPath.split(".")
        key = parts[0]

        intentIsList = False
        intentIsSet = False

        if '[]' in key:
            intentIsList = True
            key = key.replace('[]','')

        if '{}' in key:
            intentIsSet = True
            key = key.replace('{}','')

        if key in mapp:

            v = mapp[key]

            # list/set flag and not a list type? 
            # seed a empty one
            if not v and (intentIsList or intentIsSet):
                v = []
                mapp[key] = v

            # are there remaining entries in the propPath?
            remaining = propPath.split(".")[1:]

            if isinstance(v,dict) and not intentIsList and not intentIsSet and remaining:
                return self.recursive_set(".".join(remaining),value,v,key)

            elif isinstance(v,list) and intentIsList:
                if value == '[]': # empty
                    mapp[key] = []
                else:
                    valsToSet = value.split(',')
                    v.extend(valsToSet)

            elif isinstance(v,list) and intentIsSet:
                # hack w/ a temp set and swap back to a list
                # as to not have to deal w/ JSON's lack of marshaller 
                # for set datatype
                if value == '[]': # empty
                    mapp[key] = []
                else:
                    valsToSet = value.split(',')
                    v.extend(valsToSet)
                    reordered = sorted(set(v),key=v.index)
                    mapp[key] = reordered

            elif not intentIsList and not intentIsSet:
                mapp[key] = value
                return value

            else:
                logging.error("recursive_set() propPath:{} key:{} hints as a list[] or set\{\}, yet a list/set does not exist at this position!".format(propPath,key))
                sys.exit(1)

        elif len(parts) > 1:
            remaining = propPath.split(".")[1:]
            mapp[key] = {}
            return self.recursive_set(".".join(remaining),value,mapp[key],key)
            
        elif intentIsList or intentIsSet:
            mapp[key] = []
            if value != '[]': 
                valsToSet = value.split(',')
                if intentIsSet:
                    valsToSet = sorted(set(valsToSet),key=valsToSet.index)
                mapp[key].extend(valsToSet)

        else:
            mapp[key] = value

        return value


    # does NOT persist to disk/redis
    def set_value_in_dict_via_prop_path(self, setDataInDict:dict, propPath:str, value:object):
        propPath = propPath.strip()

        if isinstance(value,str):

            value = value.strip()

            # file? load it... (try json, yaml, then just raw)
            if value and value.startswith('file://'):
                filePath = value.replace('file://','')
                if filePath and filePath != '' and os.path.exists(filePath):
                    try:
                        with open(filePath,'r') as f:
                            value = json.load(f)
                    except:
                        try :
                            with open(filePath,'r') as f:
                                value = yaml.load(f,Loader=yaml.FullLoader)
                        except:
                            with open(filePath,'r') as f:
                                value = f.read()
            
        # set it...
        self.recursive_set(propPath, value, setDataInDict)

    # does NOT persist to disk/redis
    def set_values_in_dict_via_pro_path_kvpairs(self, cicdContextData, listOfKvPairs):

        # do each one
        for kvPair in listOfKvPairs:

            kvPair = kvPair.strip()

            if not '=' in kvPair:
                logging.warning("setValues() invalid kvPair: {}".format(kvPair))
                continue

            kvParts = kvPair.split('=')
            propPath = kvParts.pop(0).strip() # only grab 1st as key as val could have additional = in it
            value = '='.join(kvParts).strip() # join them back

            if not propPath or not value:
                logging.warning("setValues() invalid kvPair: {}".format(kvPair))
                continue

            propPath = propPath.strip()
            value = value.strip()

            self.set_value_in_dict_via_prop_path(cicdContextData,propPath,value)



    # This method PERSISTS after the set. 
    # each kv pair can be an propPathExpression=value|file://
    def set_value_and_persist(self, cicdContextDataId, propPath, value, preSetForceReload=False):
        set_values_and_persist(cicdContextDataId,["{}={}".format(propPath,value)],preSetForceReload)


    # This method PERSISTS after the set. 
    # each kv pair can be an propPathExpression=value|file://
    def set_values_and_persist(self, cicdContextDataId, listOfKvPairs, preSetForceReload=False):

        if not listOfKvPairs or len(listOfKvPairs) == 0:
            logging.error("setValues() invalid listOfKvPairs: {}".format(listOfKvPairs))
            return

        logging.debug("setValues() processing listOfKvPairs: {}".format(listOfKvPairs))

        # force reload?
        if preSetForceReload:
            self.load(cicdContextDataId)

        # fetch the data to set again
        cicdContextData = self.get_cicd_context_data(cicdContextDataId)

        # set values in context data
        self.set_values_in_dict_via_pro_path_kvpairs(cicdContextData,listOfKvPairs)

        # persist everything
        self.persist(cicdContextData,skipPrimary=False)


    def on_event_handler_via_id(self, eventName, cicdContextDataId, pipelineName, tmplCtxVars, valuesToSet, preSetValuesForceReload):

        if valuesToSet:
            self.set_values_and_persist(cicdContextDataId,valuesToSet,preSetValuesForceReload)

        cicdContextData = self.get_cicd_context_data(cicdContextDataId)
        self.on_event_handler(eventName,cicdContextData,pipelineName,tmplCtxVars)


    def on_event_handler(self, eventName, cicdContextData, pipelineName, tmplCtxVars, persistCicdContextData=True):

        logging.debug("on_event_handler() eventName={}, cicdContextDataId={}, pipelineName={} tmplCtxVars={}".format(eventName, cicdContextData[STATE][CICD_CONTEXT_DATA_ID], pipelineName, tmplCtxVars))

        if pipelineName not in cicdContextData['pipelines']:
            logging.error("on_event_handler() No pipeline found by pipelineName in cicdContextData! " + \
                "eventName={}, cicdContextDataId={}, pipelineName={} eventDataPath={}".format(eventName, cicdContextData[STATE][CICD_CONTEXT_DATA_ID], pipelineName, eventDataPath))
            sys.exit(1)

        # for every handler
        if eventName in cicdContextData['pipelines'][pipelineName]['event-handlers']:
            handlers = cicdContextData['pipelines'][pipelineName]['event-handlers'][eventName]

            for handlerName in handlers:

                # get the config for the handler
                handlerConfig = handlers[handlerName]

                # check for 'enabled' flag permits derivatives
                # to toggle on off, inherited handler configs
                if 'enabled' in handlerConfig:
                    enabledVal = handlerConfig['enabled'] 
                    if type(enabledVal) == bool and (enabledVal == False):
                        logging.debug("on_event_handler() {} enabled:{} skipping....".format(handlerName,enabledVal))
                        continue

                # ok we can proceed
                if handlerName == 'trigger-pipeline':
                    self.event_handle_trigger_pipeline(handlerConfig,cicdContextData, tmplCtxVars)
                if handlerName == 'manual-choice':
                    self.event_handle_manual_choice(handlerConfig,cicdContextData, tmplCtxVars)
                if handlerName == 'notify':
                    self.event_handle_notify(handlerConfig, cicdContextData, tmplCtxVars)
                if handlerName == 'respond':
                    self.event_handle_respond(handlerConfig, cicdContextData, tmplCtxVars)
                if handlerName == 'set-values':
                    self.event_handle_set_values(handlerConfig, cicdContextData, tmplCtxVars)

        # persist it all
        if persistCicdContextData:
            self.persist(cicdContextData)

    def get_via_jsonng_expression(self, getValueExpression, findInData) -> object:
        logging.debug("get_via_jsonng_expression() looking for {}".format(getValueExpression))

        try:
            parsed = jsonpath_ng.parse(getValueExpression)
        except Exception as e:
            logging.error("get_via_jsonng_expression() error parsing expression? returning expression as literal value {}. error: {}".format(getValueExpression,str(sys.exc_info()[:2])))
            return getValueExpression

        match = parsed.find(findInData)

        # return expression literal by default
        valueToReturn = getValueExpression

        # parsed.find returns an array
        if match and len(match) > 1:
            toReturn = []
            for v in match:
                toReturn.append(v.value)

            valueToReturn = toReturn
        elif match and len(match) == 1:
            valueToReturn = match[0].value
        else:
            logging.debug("get_via_jsonng_expression() expression {} yielded nothing, returning literal: {}".format(getValueExpression,getValueExpression))

        return valueToReturn


    def create_template_context(self, cicdContextData:dict, tmplCtxVars:list) -> dict:
        templateContext = copy.deepcopy(cicdContextData)
        templateContext[CONFIG_DATA] = self.configData[CONFIG_DATA_KEY]

        # add any custom template context vars into the tmpContext
        if tmplCtxVars:
            for kvPair in tmplCtxVars:
                parts = kvPair.split('=',1) # only split on first one
                if len(parts) != 2:
                    raise Exception("create_template_context() tmplCtxVars item {} needs to be in format propPath=expression".format(kvPair))
                
                propPath = parts[0]
                valueExpression = parts[1]
                
                # get the value to be set in the tmpContext and set if not null
                logging.debug("create_template_context() getting value at: {}".format(valueExpression))
                valToSet = self.get_via_jsonng_expression(valueExpression, cicdContextData)
                if valToSet:
                    logging.debug("create_template_context() got value at: {} = {}".format(valueExpression,valToSet))
                    self.set_value_in_dict_via_prop_path(templateContext,propPath,valToSet)

        return templateContext


    def create_custom_template_context(self, customConfigName:str, customConfig:dict, cicdContextData:dict, tmplCtxVars:list):
        templateContext = self.create_template_context(cicdContextData,tmplCtxVars)
        templateContext[customConfigName] = copy.deepcopy(customConfig)
        return templateContext

    def event_handle_set_values(self, setValuesConfigs, cicdContextData, tmplCtxVars):

        # support backwards compatibility w/ no subkeys
        if 'set' in setValuesConfigs:
            setValuesConfigs = { "default" : setValuesConfigs } 

        # setValuesConfig can contain multiple blocks of conditional set stanzas
        for setValueConfName in setValuesConfigs:

            logging.debug("event_handle_set_values() processing set-values for: {}".format(setValueConfName))

            setValuesConfig = setValuesConfigs[setValueConfName]

            # build a transient template context
            templateContext = self.create_custom_template_context('set-values',setValuesConfig,cicdContextData,tmplCtxVars)

            cicdContextDataId = cicdContextData[STATE][CICD_CONTEXT_DATA_ID]

            # if we didn't get a value back, exit quick (note blankOnError=True)
            if 'if' in setValuesConfig and not self.parse_template(setValuesConfig.get('if'),templateContext,blankOnError=True).strip():
                logging.debug("event_handle_set_values() {}.if for {} did not yield anything, ".format(setValueConfName,setValueConfName) + \
                    "nothing todo. setValuesConfig['if']={}".format(setValuesConfig.get('if')))
                continue

            # if the 'if" did return something, then we can proceed
            for fromToConf in setValuesConfig['set']:
                valueToSet = self.parse_template(fromToConf['from'],templateContext)
                if valueToSet and isinstance(valueToSet,str):
                    valueToSet = valueToSet.strip()
                    if valueToSet:
                        toPropPath = self.parse_template(fromToConf['to'],templateContext)
                        self.set_value_in_dict_via_prop_path(cicdContextData, toPropPath, valueToSet)

    def event_handle_respond(self, respondConfigs, cicdContextData, tmplCtxVars):

        # support backwards compatibility, w/ no subkeys
        if 'message' in respondConfigs:
            respondConfigs = { "default" : respondConfigs } 
        
        # respondConfigs can contain multiple blocks of conditional set stanzas
        for respondConfName in respondConfigs:

            logging.debug("event_handle_respond() processing respond for: {}".format(respondConfName))

            respondConfig = respondConfigs[respondConfName]

            # build a transient template context
            templateContext = self.create_custom_template_context('respond',respondConfig,cicdContextData,tmplCtxVars)

            # if we didn't get a value back, exit quick
            if 'if' in respondConfig and not self.parse_template(respondConfig.get('if'),templateContext,blankOnError=True):
                logging.debug("event_handle_respond() {}.if did not yield anything, ".format(respondConfName) + \
                    "nothing todo. respondConfig['if']={}".format(respondConfig.get('if')))
                continue

            # if the 'if" did return something, then we can proceed
            # lets parse the message into its final result
            templateContext['respond']['message'] = self.parse_template(respondConfig['message'],templateContext).strip()

            # no message? skip
            if not templateContext['respond']['message']:
                logging.debug("event_handle_respond() 'message' did not yield anything, " + \
                    "nothing todo. respondConfig['message']={}".format(respondConfig['message']))
                continue

            # auto parse all remaining fields in the respond config other than the known ones
            # which are already handled manually (message, url, if)
            tmpRespondHandlerConfigToParsed = copy.deepcopy(templateContext['respond'])
            for propName,propValue in templateContext['respond'].items():
                if propName not in ["message","url","if"]:
                    tmpRespondHandlerConfigToParsed[propName] = self.parse_template(propValue,templateContext)
            templateContext['respond'] = tmpRespondHandlerConfigToParsed

            # get the overal config's template for this handler
            responderTemplate = self.configData[CONFIG_DATA_KEY]['templates']['respond']

            # render the payload
            respondPayload = self.parse_template(responderTemplate,templateContext)
            
            # render the target URl we respond to
            respondToUrl = self.parse_template(respondConfig['url'],templateContext).strip()

            # no url? skip
            if not respondToUrl:
                logging.debug("event_handle_respond() 'url' did not yield anything, " + \
                    "nothing todo. respondConfig['url']={}".format(respondConfig['url']))
                continue

            # get our token from secretData
            responderToken = self.secretData[SECRET_DATA_KEY]['slack']['token']

            # setup headers w/ token
            headers = {
                'Content-Type': "application/json; charset=UTF-8",
                'Accept': "*/*",
                'Authorization': "Bearer {}".format(responderToken),
                'Cache-Control': "no-cache",
                'Connection': 'keep-alive'
            }

            logging.debug("event_handle_respond(): POSTing response to {} : {}".format(respondToUrl,respondPayload))

            response = requests.request("POST", respondToUrl, data=respondPayload, headers=headers)
            
            if response.status_code >= 200 and response.status_code <= 299:
                try:
                    responseBodyObj = json.loads(response.content)
                except:
                    logging.debug("event_handle_respond() {}, response content not JSON..".format(response.status_code))
                    responseBodyObj = response.content

                logging.debug("event_handle_respond(): POST response OK {} ".format(responseBodyObj))

            
            else:
                logging.error("handle_resevent_handle_respondponder() http response code: {} FAILED: {} ".format(response.status_code,response.content))


    def capture_http_response_data(self, cicdContextData:dict, responseBodyObj, eventHandlerName:str, eventHandlerConfig:dict ):

        logging.debug("capture_http_response_data() for {} ".format(eventHandlerName))
        
        contextDataForTemplate = copy.deepcopy(cicdContextData)
        contextDataForTemplate['configData'] = self.configData[CONFIG_DATA_KEY]
        contextDataForTemplate['body'] = responseBodyObj
        
        # always apply global auto capture rules
        if eventHandlerName in self.configData[CONFIG_DATA_KEY]:
            if 'auto-capture-response-data' in self.configData[CONFIG_DATA_KEY][eventHandlerName]:
                captureConfs = self.configData[CONFIG_DATA_KEY][eventHandlerName]['auto-capture-response-data']
                for captureConf in captureConfs:
                    valueToSet = self.parse_template(str(captureConf['from']),contextDataForTemplate)
                    if valueToSet and isinstance(valueToSet,str):
                        valueToSet = valueToSet.strip()
                        if valueToSet:
                            # the 'to' directive can be a template as well
                            setToKey = self.parse_template(captureConf['to'],contextDataForTemplate)
                            self.set_value_in_dict_via_prop_path(cicdContextData, setToKey, valueToSet)

        # ... and then apply the pipeline specific notify capture rules
        if 'capture-response-data' in eventHandlerConfig:
            captureConfs = eventHandlerConfig['capture-response-data']
            for captureConf in captureConfs:
                valueToSet = self.parse_template(str(captureConf['from']),contextDataForTemplate)
                if valueToSet and isinstance(valueToSet,str):
                    valueToSet = valueToSet.strip()
                    if valueToSet:
                        # the 'to' directive can be a template as well
                        setToKey = self.parse_template(captureConf['to'],contextDataForTemplate)
                        self.set_value_in_dict_via_prop_path(cicdContextData, setToKey, valueToSet)


    def event_handle_notify(self, notifyConfigs, cicdContextData, tmplCtxVars):

        # support backwards compatibility where there are no nested named subkeys
        if 'message' in notifyConfigs:
            notifyConfigs = { "default" : notifyConfigs } 
        
        # notifyConfigs can contain multiple blocks of conditional set stanzas
        for notifyConfName in notifyConfigs:

            logging.debug("event_handle_notify() processing notify for: {}".format(notifyConfName))

            notifyConfig = notifyConfigs[notifyConfName]

            # build a transient template context
            templateContext = self.create_custom_template_context('notify',notifyConfig,cicdContextData,tmplCtxVars)

            # if we didn't get a value back, exit quick
            if 'if' in notifyConfig and not self.parse_template(notifyConfig.get('if'),templateContext,blankOnError=True):
                logging.debug("event_handle_notify() {}.if did not yield anything, ".format(notifyConfName) + \
                    "nothing todo. notifyConfig['if']={}".format(notifyConfig.get('if')))
                continue

            templateContext['notify']['message'] = self.parse_template(notifyConfig['message'],templateContext)

            notifyTemplate = self.configData[CONFIG_DATA_KEY]['templates']['notify']
            notifyPayload = self.parse_template(notifyTemplate,templateContext)
            

            notifyUrl = self.configData[CONFIG_DATA_KEY]['slack']['url']
            notifyToken = self.secretData[CONFIG_DATA_KEY]['slack']['token']

            headers = {
                'Content-Type': "application/json; charset=UTF-8",
                'Accept': "*/*",
                'Authorization': "Bearer {}".format(notifyToken),
                'Cache-Control': "no-cache",
                'Connection': 'keep-alive'
            }

            logging.debug("event_handle_notify(): POSTing notification to {} : {}".format(notifyUrl,notifyPayload))

            response = requests.request("POST", notifyUrl, data=notifyPayload, headers=headers)
            
            if response.status_code >= 200 and response.status_code <= 299:

                cicdContextDataId = cicdContextData[STATE][CICD_CONTEXT_DATA_ID]

                responseBodyObj = json.loads(response.content)
                logging.debug("event_handle_notify(): POST response OK {} ".format(responseBodyObj))

                self.capture_http_response_data(cicdContextData, responseBodyObj, 'notify', notifyConfig)
                
            else:
                logging.error("event_handle_notify() http response code: {} FAILED: {} ".format(response.status_code,response.content))



    def event_handle_manual_choice(self, manualChoiceConfigs, cicdContextData, tmplCtxVars):

        # support backwards compatibility where there are no nested keys
        if 'title' in manualChoiceConfigs:
            manualChoiceConfigs = { "default" : manualChoiceConfigs } 
        
        # manualChoiceConfigs can contain multiple blocks of conditional set stanzas
        for manualChoiceConfName in manualChoiceConfigs:

            logging.debug("event_handle_manual_choice() processing manual-choice for: {}".format(manualChoiceConfName))

            manualChoiceConfig = manualChoiceConfigs[manualChoiceConfName]

            # build a transient template context
            templateContext = self.create_custom_template_context('manualChoice',manualChoiceConfig,cicdContextData,tmplCtxVars)

            # if we didn't get a value back, exit quick
            if 'if' in manualChoiceConfig and not self.parse_template(manualChoiceConfig.get('if'),templateContext,blankOnError=True):
                logging.debug("event_handle_manual_choice() {}.if did not yield anything, ".format(manualChoiceConfName) + \
                    "nothing todo. manualChoiceConfig['if']={}".format(manualChoiceConfig.get('if')))
                continue

            templateContext['manualChoice']['title'] = self.parse_template(manualChoiceConfig['title'],templateContext)

            # pre-process and generate any "choices" that come from "choice-generators"
            if 'choice-generators' in templateContext['manualChoice']:
                choiceGenerators = templateContext['manualChoice']['choice-generators']
                for generatorName, generator in choiceGenerators.items():
                    logging.debug("manualChoice: processing choice-generator: {}".format(generatorName))
                    if 'foreach' not in generator or 'template' not in generator:
                        logging.debug("manualChoice: invalid choice-generator: {}, expected 'foreach' and 'template' properties".format(generatorName))
                    
                    # parse foreach template, then "get" that resolved path which should return a dictionary
                    foreachJsonPathExp = self.parse_template(generator['foreach'],templateContext)
                    foreachDict = self.get_value(cicdContextData[STATE][CICD_CONTEXT_DATA_ID],foreachJsonPathExp,None)

                    iteratorJsonPathExp = self.parse_template(generator['iterator'],templateContext)
                    iteratorName = self.get_value(cicdContextData[STATE][CICD_CONTEXT_DATA_ID],iteratorJsonPathExp,None)
                    if not iteratorName:
                        iteratorName = generator['iterator']
                    
                    for itemName,item in foreachDict.items():
                        templateContext[iteratorName] = item
                        optionsYaml = self.parse_template(generator['template'],templateContext)

                        # iterate and render into a choices yaml, turn into object
                        # then dynamically append to ['manualChoice']['choices']
                        generatedChoice = yaml.load(optionsYaml, Loader=yaml.FullLoader)
                        choiceKeyName = list(generatedChoice.keys())[0] 
                        choiceConfig = list(generatedChoice.values())[0]
                        templateContext['manualChoice']['choices'][choiceKeyName] = choiceConfig


            # now render out all choices...
            for choiceName in templateContext['manualChoice']['choices']:
                choiceConfig = templateContext['manualChoice']['choices'][choiceName]
                choiceConfig['header'] = self.parse_template(choiceConfig['header'],templateContext)
                for option in choiceConfig['options']:
                    option['value'] = self.parse_template(option['value'],templateContext)
                    option['text'] = self.parse_template(option['text'],templateContext)

            manualChoiceTemplate = self.configData[CONFIG_DATA_KEY]['templates']['manual-choice']

            notifyPayload = self.parse_template(manualChoiceTemplate,templateContext)

            notifyUrl = self.configData[CONFIG_DATA_KEY]['slack']['url']
            notifyToken = self.secretData[SECRET_DATA_KEY]['slack']['token']

            headers = {
                'Content-Type': "application/json; charset=UTF-8",
                'Accept': "*/*",
                'Authorization': "Bearer {}".format(notifyToken),
                'Cache-Control': "no-cache",
                'Connection': 'keep-alive'
            }

            logging.debug("event_handle_manual_choice(): POSTing manual choices to {} : {}".format(notifyUrl,notifyPayload))

            response = requests.request("POST", notifyUrl, data=notifyPayload, headers=headers)
            
            if response.status_code >= 200 and response.status_code <= 299:
                responseBodyObj = json.loads(response.content)
                logging.debug("event_handle_manual_choice(): POST response OK {} ".format(json.dumps(responseBodyObj)))
                self.capture_http_response_data(cicdContextData, responseBodyObj, 'manual-choice', manualChoiceConfig)
                
            else:
                logging.error("event_handle_manual_choice() http response code: {} FAILED: {} ".format(response.status_code,response.content))


    def event_handle_trigger_pipeline(self, triggerPipelineConfigs, cicdContextData, tmplCtxVars):

        # support backwards compatibility, w/ no subkeys
        if 'name' in triggerPipelineConfigs:
            triggerPipelineConfigs = { "default" : triggerPipelineConfigs } 
        
        # triggerPipelineConfigs can contain multiple blocks of conditional set stanzas
        for triggerPipelineConfName in triggerPipelineConfigs:

            logging.debug("event_handle_trigger_pipeline() processing notify for: {}".format(triggerPipelineConfName))

            triggerPipelineConfig = triggerPipelineConfigs[triggerPipelineConfName]

            # build a transient template context
            templateContext = self.create_custom_template_context('triggerPipeline',triggerPipelineConfig,cicdContextData,tmplCtxVars)

            # if we didn't get a value back, exit quick
            if 'if' in triggerPipelineConfig and not self.parse_template(triggerPipelineConfig.get('if'),templateContext,blankOnError=True):
                logging.debug("event_handle_trigger_pipeline() {}.if did not yield anything, ".format(triggerPipelineConfName) + \
                    "nothing todo. triggerPipelineConfig['if']={}".format(triggerPipelineConfig.get('if')))
                continue

            triggerUrl = self.configData[CONFIG_DATA_KEY]['trigger']['url']
            cicdKey = self.secretData[SECRET_DATA_KEY]['trigger']['token']

            payload = {}

            # always apply global trigger auto args
            if 'auto-args' in self.configData[CONFIG_DATA_KEY]['trigger']:
                autoArgsConf = self.configData[CONFIG_DATA_KEY]['trigger']['auto-args']
                for argName in autoArgsConf:
                    payload[argName] = self.parse_template(str(autoArgsConf[argName]),templateContext)

            # and also apply any pipeline specific args which can override the latter
            if 'args' in triggerPipelineConfig:
                for argName in triggerPipelineConfig['args']:
                    argumentValue = triggerPipelineConfig['args'][argName]
                    payload[argName] = self.parse_template(str(argumentValue),templateContext)
                    
            headers = {
                'Content-Type': "application/json",
                'Accept': "*/*",
                'Cache-Control': "no-cache"
            }

            # add secret data
            templateContext[SECRET_DATA] = self.secretData[SECRET_DATA_KEY]

            for headerConfig in self.configData[CONFIG_DATA_KEY]['trigger']['headers']:
                headerName = headerConfig['name']
                headerValue = self.parse_template(str(headerConfig['value']),templateContext)
                headers[headerName] = headerValue

            logging.debug("event_handle_trigger_pipeline(): POSTing trigger pipeline to {} : {}".format(triggerUrl,json.dumps(payload)))

            response = requests.request("POST", triggerUrl, data=json.dumps(payload), headers=headers)
            
            if response.status_code >= 200 and response.status_code <= 299:
                logging.debug("event_handle_trigger_pipeline(): POST response OK {} ".format(json.loads(response.content)))
            else:
                logging.error("event_handle_trigger_pipeline() http response code: {} FAILED: {} ".format(response.status_code,response.content))




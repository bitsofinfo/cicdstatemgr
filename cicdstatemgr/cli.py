#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
"""

import argparse
import logging
import time
import sys
import os

from .cicdstatemgr import CicdStateMgr, InitializeArgs, LoadArgs, SetArgs, HandleEventArgs, GetArgs


class CicdStateMgrCli():

    def get_set_arg_vals_to_set(self,setArg):

        valsToSet = []

        if isinstance(setArg,list):
            for item in setArg:
                valsToSet.extend(item.split('|'))
        else:
            valsToSet.extend(setArg.split('|'))

        return valsToSet

    def cli_add_log_arguments(self, parser:argparse.ArgumentParser):
        parser.add_argument('-l', '--log-level', dest='log_level', default="DEBUG", \
            help="log level, DEBUG, INFO, etc")

    def cli_add_config_arguments(self, parser:argparse.ArgumentParser):
        parser.add_argument('--config', default=None, \
            help="Full or relative path to yaml config file, if not specified will auto consume " + \
                "from the path defined by the environment variable CICDSTATEMGR_CONFIG_PATH")

        parser.add_argument('--secrets', default=None, \
            help="Full or relative path to secrets yaml config file, if not specified will auto consume " + \
                "from the path defined by the environment variable CICDSTATEMGR_SECRETS_PATH")


    def cli_add_init_arguments(self, parser:argparse.ArgumentParser):
        parser.add_argument('--init-new', default=None, \
            help="Initialize a new cicdContextData w/ given identifier, must pass additional --init-* args, outputs the generated cicdContextDataId value to STDOUT")

        parser.add_argument('--init-cicd-context-name', help="The cicd context name, default 'stage'", default="stage")

        parser.add_argument('--init-bases-dir', default=None, \
            help="Full or relative path to directory that contains pipeline YAML base files. CICDSTATEMGR_BASES_DIR_PATH")
        
        parser.add_argument('--init-app-config-file', default=None, \
            help="Full or relative path to the app's CICD config file, if not specified will auto consume " + \
                "from the path defined by the environment variable CICDSTATEMGR_INIT_APP_CONFIG_PATH")

    def cli_add_id_arguments(self, parser:argparse.ArgumentParser):
        parser.add_argument('--id', default=None, help="The cicdContextDataId value, can also be set in the CICDSTATEMGR_CONTEXT_DATA_ID")

    def cli_add_tmpl_arguments(self, parser:argparse.ArgumentParser):
        parser.add_argument('--tmpl-ctx-var', action='append', default=None, \
            help="Defines custom jinja2 template context key=value entries that will be made available for all jinja2 evaluations. " + \
                " The 'key' can be any property path expression where the result of the 'value' expression will be copied to, i.e " +\
                "my.custom.property=value.yeilded.by.cicContextData.path")

    def cli_add_load_arguments(self, parser:argparse.ArgumentParser):
        parser.add_argument('--load', action='store_true', default=False)

    def cli_add_get_arguments(self, parser:argparse.ArgumentParser):
        parser.add_argument('--get', default=None, help="Get a value via a jsonpath expression: https://github.com/h2non/jsonpath-ng, " + \
            "outputs to STDOUT. Multiple values or non-primitives are returned as JSON")

    def cli_add_set_arguments(self, parser:argparse.ArgumentParser):
        parser.add_argument('--set', action='append', default=None, \
            help="The context data prop path to be set, i.e. x.y.z=<primitiveValue | /path/to/file.[json|yaml]>, can be using during --init-*")

        parser.add_argument('--pre-set-force-reload', action='store_true', default=False,
            help="Prior to setting, force reload of context data from redis, only needed in concurrent task situations")

    def cli_add_handle_event_arguments(self, parser:argparse.ArgumentParser):
        parser.add_argument('--handle-event', default=None, help="Pass <pipelineName=init|failure|success|...>")


    def cli_add_all_arguments(self, parser:argparse.ArgumentParser):

        self.cli_add_log_arguments(parser)
        self.cli_add_config_arguments(parser)
        self.cli_add_init_arguments(parser)
        self.cli_add_id_arguments(parser)
        self.cli_add_tmpl_arguments(parser)
        self.cli_add_load_arguments(parser)
        self.cli_add_get_arguments(parser)
        self.cli_add_set_arguments(parser)
        self.cli_add_handle_event_arguments(parser)


    def cli_args_2_cicd_state_mgr(self,args) -> CicdStateMgr:
        # We must have a configFile
        configFilePath = args.config
        if not configFilePath:
            configFilePath = os.getenv("CICDSTATEMGR_CONFIG_PATH")
        if not configFilePath:
            raise Exception("USAGE: --config <path> is required or set env var CICDSTATEMGR_CONFIG_PATH")

        # We can also have have a secrets configFile
        secretsFilePath = args.secrets
        if not secretsFilePath:
            secretsFilePath = os.getenv("CICDSTATEMGR_SECRETS_PATH")
        # not required anymore
        if not secretsFilePath:
            raise Exception("USAGE: --secrets <path> is required or set env var CICDSTATEMGR_SECRETS_PATH")

        return CicdStateMgr(configFilePath,secretsFilePath)



    def cli_consume_init_new_args(self,args) -> InitializeArgs:
        # we need the app config file path
        appConfigFilePath = args.init_app_config_file
        if not appConfigFilePath:
            appConfigFilePath = os.getenv("CICDSTATEMGR_INIT_APP_CONFIG_PATH")
        if not appConfigFilePath:
            raise Exception("USAGE: --init-app-config <path> is required or set env var CICDSTATEMGR_INIT_APP_CONFIG_PATH")


        # We optionally can have a basesDir for init
        basesDirPath = args.init_bases_dir
        if not basesDirPath:
            basesDirPath = os.getenv("CICDSTATEMGR_BASES_DIR_PATH")
        #if not basesDirPath or not os.path.exists(basesDirPath):
        #    raise Exception("USAGE: --init-bases-dir <path> is required (and must exist) or set env var CICDSTATEMGR_BASES_DIR_PATH")


        # was --set also passed? set those values
        valsToSet = None
        if args.set:
            if not isinstance(args.set,list) and "=" not in args.set:
                raise Exception("USAGE: --set path.to.prop=<primitiveValue | /path/to/file.[json|yaml]>")

            valsToSet = self.get_set_arg_vals_to_set(args.set)

        # was --handle-event passed? 
        handleEventArgs = self.get_handle_event_arg_vals_to_set(args)

        return InitializeArgs(args.init_new, # the identifier to use
                                    args.init_cicd_context_name, 
                                    appConfigFilePath,
                                    basesDirPath,
                                    valsToSet,
                                    handleEventArgs['eventPipelineName'],
                                    handleEventArgs['tmplCtxVars'],
                                    handleEventArgs['eventNameToFire'])


    def cli_consume_load_args(self,args) -> LoadArgs:
        
        # --id is required
        cicdContextDataId = args.id
        if not cicdContextDataId:
            cicdContextDataId = os.getenv("CICDSTATEMGR_CONTEXT_DATA_ID")
        if not cicdContextDataId:
            raise Exception("USAGE: --id <cicdContextDataId> required or set env var CICDSTATEMGR_CONTEXT_DATA_ID")

        # was --set also passed? set those values
        valsToSet = None
        if args.set:
            if not isinstance(args.set,list) and "=" not in args.set:
                raise Exception("USAGE: --set path.to.prop=<primitiveValue | /path/to/file.[json|yaml]>")

            valsToSet = self.get_set_arg_vals_to_set(args.set)

        # was --handle-event passed? 
        handleEventArgs = self.get_handle_event_arg_vals_to_set(args)

        return LoadArgs(cicdContextDataId,
                        valsToSet,
                        handleEventArgs['eventPipelineName'],
                        handleEventArgs['eventNameToFire'],
                        handleEventArgs['tmplCtxVars'])


    def cli_consume_get_args(self,args) -> GetArgs:
        cicdContextDataId = args.id
        if not cicdContextDataId:
            cicdContextDataId = os.getenv("CICDSTATEMGR_CONTEXT_DATA_ID")
        if not cicdContextDataId:
            raise Exception("USAGE: --id <cicdContextDataId> required or set env var CICDSTATEMGR_CONTEXT_DATA_ID")

        return GetArgs(cicdContextDataId,args.get,args.tmpl_ctx_var)

    def get_handle_event_arg_vals_to_set(self,args) -> dict:

        if args.handle_event:
            parts = args.handle_event.split("=")
            if len(parts) != 2:
                raise Exception("USAGE: --handle-event <pipelineName=init|failure|success|...>")

            eventPipelineName = parts[0]
            eventNameToFire = parts[1]

        else:
            eventPipelineName = None
            eventNameToFire = None

        return {
            'eventPipelineName': eventPipelineName,
            'eventNameToFire': eventNameToFire,
            'tmplCtxVars': args.tmpl_ctx_var
        }


    def cli_consume_handle_event_args(self,args) -> HandleEventArgs:

        # --id required
        cicdContextDataId = args.id
        if not cicdContextDataId:
            cicdContextDataId = os.getenv("CICDSTATEMGR_CONTEXT_DATA_ID")

        if not cicdContextDataId:
            raise Exception("USAGE: --id <cicdContextDataId> required or set env var CICDSTATEMGR_CONTEXT_DATA_ID")
            
        if not args.handle_event:
            raise Exception("USAGE: --handle-event <pipelineName.pipelineRunUid=init|failure|success|...> ")

        handleEventArgs = self.get_handle_event_arg_vals_to_set(args)

        # optionally handle sets prior to the event
        valsToSet = None
        if args.set:
            if not isinstance(args.set,list) and "=" not in args.set:
                raise Exception("USAGE: --set path.to.prop=<primitiveValue | /path/to/file.[json|yaml]>")
            valsToSet = self.get_set_arg_vals_to_set(args.set)


        return HandleEventArgs(handleEventArgs['eventNameToFire'],
                              cicdContextDataId,
                              handleEventArgs['eventPipelineName'],
                              handleEventArgs['tmplCtxVars'],
                              valsToSet,
                              args.pre_set_force_reload)

    def cli_consume_set_args(self,args) -> SetArgs:

        # --id required
        id = args.id
        if not id:
            id = os.getenv("CICDSTATEMGR_CONTEXT_DATA_ID")
        if not id:
            raise Exception("USAGE: --id <cicdContextDataId> required or set env var CICDSTATEMGR_CONTEXT_DATA_ID")
            
        if not isinstance(args.set,list) and "=" not in args.set:
            raise Exception("USAGE: --set path.to.prop=<primitiveValue | /path/to/file.[json|yaml]>")

        valsToSet = self.get_set_arg_vals_to_set(args.set)

        return SetArgs(id,valsToSet,args.pre_set_force_reload)


    def cli_execute(self, parser:argparse.ArgumentParser):

        args = parser.parse_args()

        logging.basicConfig(level=logging.getLevelName(args.log_level),
                            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                            filename=None,filemode='w')
        logging.Formatter.converter = time.gmtime

        try:
            # get an instance of CicdStateMgr
            cicdStateMgr = self.cli_args_2_cicd_state_mgr(args)

            # handle --init-new [id]
            if args.init_new:
                initArgs = self.cli_consume_init_new_args(args)

                # ok lets construct a new CicdStateMgr and initialize a new CicdContextData
                cicdContextData = cicdStateMgr.initialize(initArgs.cicdContextDataId,
                                                            initArgs.cicdContextName, 
                                                            initArgs.appConfigFilePath,
                                                            initArgs.appConfigFileBasesDirPath,
                                                            initArgs.valuesToSet,
                                                            initArgs.eventPipelineName,
                                                            initArgs.eventNameToFire,
                                                            initArgs.tmplCtxVars)
                print(cicdContextData.getCicdContextDataId())

            # handle --load
            elif args.load:
                loadArgs = self.cli_consume_load_args(args)

                # ok, do a load operation
                cicdStateMgr.load(loadArgs.cicdContextDataId,
                                  loadArgs.valuesToSet,
                                  loadArgs.eventPipelineName,
                                  loadArgs.eventNameToFire,
                                  loadArgs.tmplCtxVars)

            # handle --get
            elif args.get:
                getArgs = self.cli_consume_get_args(args)

                # ok, do a get operation
                val = cicdStateMgr.get_value(getArgs.cicdContextDataId, getArgs.expression, getArgs.tmplCtxVars)
                print(val)

            # handle --handle-event
            elif args.handle_event:
                handleEventArgs = self.cli_consume_handle_event_args(args)

                # ok, do a handle event operation
                cicdStateMgr.on_event_handler_via_id(handleEventArgs.eventNameToFire,
                                                    handleEventArgs.cicdContextDataId,
                                                    handleEventArgs.eventPipelineName,
                                                    handleEventArgs.tmplCtxVars,
                                                    handleEventArgs.valuesToSet,
                                                    handleEventArgs.preSetValuesForceReload)

            # handle --set
            elif args.set:
                setArgs = self.cli_consume_set_args(args)

                # ok, do a set operation
                cicdStateMgr.set_values_and_persist(setArgs.cicdContextDataId,
                                                    setArgs.valuesToSet,
                                                    setArgs.preSetValuesForceReload)

        except Exception as e:
            logging.exception("cli() error: {}".format(str(sys.exc_info()[:2])))
            parser.print_help()
            sys.exit(1)


def main():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    cli = CicdStateMgrCli()
    cli.cli_add_all_arguments(parser)
    cli.cli_execute(parser)




## Initialize a new set of cicd context data

Lets start by imagining a new `build` pipeline starts in our CICD system, we have a task in the `build` pipeline that needs to initialize a new set of CICD context data. Within our `build` pipelines we could have a task/step that uses `cicdstatemgr` to initialize a new set of CICD context data.

For the following set of examples here we are just running these commands locally.

Run the following command from within the root of this project. This command will initialized a brand new `cicdContextData` object bound to an identifier you specify in the `--init-new` argument

```
cicdstatemgr \
    --config examples/basics/config.yaml  \
    --secrets examples/basics/secrets.yaml \
        \
    --init-new "contextData1" \
    --init-bases-dir examples/basics/bases \
    --init-app-config-file examples/basics/app.yaml \
    --init-cicd-context-name stage \
    \
    --set "state.key1=value1"

2020-07-07 20:44:52,257 - root - DEBUG - DataSourceMgr() Initializing datasource: redis
2020-07-07 20:44:52,261 - root - DEBUG - redis -> localhost isPrimary:True isLocal:False
2020-07-07 20:44:52,262 - root - ERROR - DataSourceMgr() primary ds = redis
2020-07-07 20:44:52,262 - root - DEBUG - DataSourceMgr() Initializing datasource: yamlfile
2020-07-07 20:44:52,264 - root - DEBUG - yamlfile -> /bitsofinfo/cicdstatemgr/examples/basics/localdata/cicdContextData.yaml isPrimary:False isLocal:True
2020-07-07 20:44:52,264 - root - DEBUG - DataSourceMgr() Initializing datasource: jsonfile
2020-07-07 20:44:52,268 - root - DEBUG - jsonfile -> /bitsofinfo/cicdstatemgr/examples/basics/localdata/cicdContextData.json isPrimary:False isLocal:True
2020-07-07 20:44:52,268 - root - DEBUG - DataSourceMgr() Initializing datasource: shellfile
2020-07-07 20:44:52,272 - root - DEBUG - shellfile -> /bitsofinfo/cicdstatemgr/examples/basics/localdata/cicdContextData.sh isPrimary:False isLocal:True
2020-07-07 20:44:52,273 - root - DEBUG - DataSourceMgr() Initializing datasource: idfile
2020-07-07 20:44:52,277 - root - DEBUG - idfile -> /bitsofinfo/cicdstatemgr/examples/basics/localdata/cicdContextData.id isPrimary:False isLocal:True
2020-07-07 20:44:52,277 - root - DEBUG - initialize() id=contextData1 cicdContextName=stage pathToAppCicdConfigYamlFile=examples/basics/app.yaml basesDir=examples/basics/bases eventPipelineName=None eventNameToFire=None tmplCtxVars=None
2020-07-07 20:44:52,277 - root - DEBUG - initialize() loading app pipeline template: /bitsofinfo/cicdstatemgr/examples/basics/app.yaml
2020-07-07 20:44:52,282 - root - DEBUG - initialize() applying base pipeline template: examples/basics/bases/base1.yaml
2020-07-07 20:44:52,285 - root - DEBUG - recursive_set() setting state.key1 to value1 within parent of: None
2020-07-07 20:44:52,285 - root - DEBUG - recursive_set() setting key1 to value1 within parent of: state
2020-07-07 20:44:52,290 - root - DEBUG - persist() skipPrimary=False cicdContextDataId=contextData1
2020-07-07 20:44:52,290 - root - DEBUG - DataSourceMgr.persist() skipPrimary=False cicdContextDataId=contextData1
2020-07-07 20:44:52,290 - root - DEBUG - DataSourceMgr.persist() persisting in: redis
2020-07-07 20:44:52,306 - root - DEBUG - DataSourceMgr.persist() persisting in: yamlfile
2020-07-07 20:44:52,312 - root - DEBUG - DataSourceMgr.persist() persisting in: jsonfile
2020-07-07 20:44:52,313 - root - DEBUG - DataSourceMgr.persist() persisting in: shellfile
2020-07-07 20:44:52,314 - root - DEBUG - DataSourceMgr.persist() persisting in: idfile
```

## So what did this do?

* Loaded its configuration from `config.yaml`, `secrets.yaml`
* Loaded `app.yaml` and merged it with all its `bases` (`bases` file reference are under `--init-bases-dir examples/basics/bases`)
* Initialized a new `cicdContextData` object with identifier `--init-new "contextData1"`
* Stored a copy of the app's merged `pipelines` and `jinja2macros`
* Setup a `state` object within the `cicdContextData`
* `--set` set a value `state.key1=value1`
* All of this was persisted in the `datastores` defined in `config.yaml` with `redis` being the primary and various local files located under `examples/basics/localdata`

## Take a look at the data

The data is available in redis:
```
$ redis-cli 
127.0.0.1:6379> auth cicdstatemgr 123$aBcZ
OK

127.0.0.1:6379> mget contextData1
1) "channel: stage\npipelines:\n  start:\n    event-handlers:\n      some-event:\n        notify:\n          message: '{{ basicMacro(''some-event fired'') }}\n\n            '\n      init:\n        notify:\n          message: '{{ helloWorld(''start is successful'') }}\n\n            '\nappPipelinesConfig:\n  bases:\n  - base1.yaml\n  jinja2-macros:\n    helloWorld: \"{%- macro helloWorld(msg) -%}\\n  Hello world msg = {{msg}}\\n{%- endmacro\\\n      \\ -%}\\n\"\n  variables:\n    myVar1: test\n  cicd-contexts:\n    stage:\n      channel: stage\n      pipelines:\n        start:\n          event-handlers:\n            init:\n              notify:\n                message: '{{ helloWorld(''start is successful'') }}\n\n                  '\njinja2Macros:\n  byName:\n    basicMacro: \"{%- macro basicMacro(msg) -%}\\n  This is basicMacro! msg = {{msg}}\\n\\\n      {%- endmacro -%}\\n\"\n    helloWorld: \"{%- macro helloWorld(msg) -%}\\n  Hello world msg = {{msg}}\\n{%- endmacro\\\n      \\ -%}\\n\"\n  all: \"{%- macro basicMacro(msg) -%}\\n  This is basicMacro! msg = {{msg}}\\n{%- endmacro\\\n    \\ -%}{%- macro helloWorld(msg) -%}\\n  Hello world msg = {{msg}}\\n{%- endmacro\\\n    \\ -%}\"\nstate:\n  cicdContextDataId: contextData1\n  cicdContextName: stage\n  key1: value1\nvariables:\n  baseVar1: baseVarVal1\n  myVar1: test\n"
```

The data is available on the filesystem:

ID file:
```
cat examples/basics/localdata/cicdContextData.id

contextData1
```

as JSON:
```
cat examples/basics/localdata/cicdContextData.json | jq .'state'

{
  "cicdContextDataId": "contextData1",
  "cicdContextName": "stage",
  "key1": "value1"
}
```

as YAML:
```
cat examples/basics/localdata/cicdContextData.yaml | yq r - 'state'

cicdContextDataId: contextData1
cicdContextName: stage
key1: value1
```

as a sourceable shell script:
```
source examples/basics/localdata/cicdContextData.sh

$ echo $CICD_state__key1
value1

$ echo $CICD_pipelines__start__event_handlers__init__notify__message
{{ helloWorld('start is successful') }}
```
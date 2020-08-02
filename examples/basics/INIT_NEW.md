## Initialize a new set of cicd context data

Lets start by imagining a new `build` pipeline starts in our CICD system, we have a task in the `build` pipeline that needs to initialize a new set of CICD context data. Within our `build` pipelines we could have a task/step that uses `cicdstatemgr` to initialize a new set of CICD context data.

For the following set of examples here we are just running these commands locally.

Run the following command from within the root of this project. This command will initialized a brand new `cicdContextData` object bound to an identifier you specify in the `--init-new` argument

`--init-new` can be used along with the `--set` and `--handle-event` arguments as well

```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
        \
    --init-new "context-data-id-1" \
    --init-bases-dir bases \
    --init-app-config-file app.yaml \
    --init-cicd-context-name stage \
    \
    --set "state.key1=value1"

2020-07-14 17:39:42,440 - root - DEBUG - DataSourceMgr() Initializing datasource: redis
2020-07-14 17:39:42,442 - root - DEBUG - redis -> localhost isPrimary:True isLocal:False
2020-07-14 17:39:42,442 - root - INFO - DataSourceMgr() primary ds = redis
2020-07-14 17:39:42,442 - root - DEBUG - DataSourceMgr() Initializing datasource: yamlfile
2020-07-14 17:39:42,443 - root - DEBUG - yamlfile -> examples/basics/examples/basics/localdata/cicdContextData.yaml isPrimary:False isLocal:True
2020-07-14 17:39:42,443 - root - DEBUG - DataSourceMgr() Initializing datasource: jsonfile
2020-07-14 17:39:42,444 - root - DEBUG - jsonfile -> examples/basics/examples/basics/localdata/cicdContextData.json isPrimary:False isLocal:True
2020-07-14 17:39:42,444 - root - DEBUG - DataSourceMgr() Initializing datasource: shellfile
2020-07-14 17:39:42,445 - root - DEBUG - shellfile -> examples/basics/examples/basics/localdata/cicdContextData.sh isPrimary:False isLocal:True
2020-07-14 17:39:42,445 - root - DEBUG - DataSourceMgr() Initializing datasource: idfile
2020-07-14 17:39:42,445 - root - DEBUG - idfile -> examples/basics/examples/basics/localdata/cicdContextData.id isPrimary:False isLocal:True
2020-07-14 17:39:42,446 - root - DEBUG - initialize() id=context-data-id-1 cicdContextName=stage pathToAppCicdConfigYamlFile=app.yaml basesDir=bases eventPipelineName=None eventNameToFire=None tmplCtxVars=None
2020-07-14 17:39:42,446 - root - DEBUG - initialize() loading app pipeline template: examples/basics/app.yaml
2020-07-14 17:39:42,450 - root - DEBUG - initialize() applying base pipeline template: bases/base1.yaml
2020-07-14 17:39:42,452 - root - DEBUG - recursive_set() setting state.key1 to value1 within parent of: None
2020-07-14 17:39:42,452 - root - DEBUG - recursive_set() setting key1 to value1 within parent of: state
2020-07-14 17:39:42,457 - root - DEBUG - persist() skipPrimary=False cicdContextDataId=context-data-id-1
2020-07-14 17:39:42,457 - root - DEBUG - DataSourceMgr.persist() skipPrimary=False cicdContextDataId=context-data-id-1
2020-07-14 17:39:42,457 - root - DEBUG - DataSourceMgr.persist() persisting in: redis
2020-07-14 17:39:42,470 - root - DEBUG - DataSourceMgr.persist() persisting in: yamlfile
2020-07-14 17:39:42,475 - root - DEBUG - DataSourceMgr.persist() persisting in: jsonfile
2020-07-14 17:39:42,476 - root - DEBUG - DataSourceMgr.persist() persisting in: shellfile
2020-07-14 17:39:42,476 - root - DEBUG - DataSourceMgr.persist() persisting in: idfile
context-data-id-1
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

The data is available in redis: (its stored in YAML)
```
redis-cli --user cicdstatemgr --pass '123$aBcZ' mget contextData1

1) "channel: stage\npipelines:\n  start:\n    event-handlers:\n      some-event:\n        notify:\n          message: '{{ basicMacro(''some-event fired'') }}\n\n            '\n  build:\n    event-handlers:\n      init:\n        notify:\n          message: '{{ helloWorld(''build is successful'') }}\n\n            '\nappPipelinesConfig:\n  bases:\n  - base1.yaml\n  jinja2-macros:\n    helloWorld: \"{%- macro helloWorld(msg) -%}\\n  Hello world msg = {{msg}}\\n{%- endmacro\\\n      \\ -%}\\n\"\n  variables:\n    myVar1: test\n  cicd-contexts:\n    stage:\n      channel: stage\n      pipelines:\n        build:\n          event-handlers:\n            init:\n              notify:\n                message: '{{ helloWorld(''build is successful'') }}\n\n                  '\njinja2Macros:\n  byName:\n    basicMacro: \"{%- macro basicMacro(msg) -%}\\n  This is basicMacro! msg = {{msg}}\\n\\\n      {%- endmacro -%}\\n\"\n    helloWorld: \"{%- macro helloWorld(msg) -%}\\n  Hello world msg = {{msg}}\\n{%- endmacro\\\n      \\ -%}\\n\"\n  all: \"{%- macro basicMacro(msg) -%}\\n  This is basicMacro! msg = {{msg}}\\n{%- endmacro\\\n    \\ -%}{%- macro helloWorld(msg) -%}\\n  Hello world msg = {{msg}}\\n{%- endmacro\\\n    \\ -%}\"\nstate:\n  cicdContextDataId: contextData1\n  cicdContextName: stage\n  key1: value1\nvariables:\n  baseVar1: baseVarVal1\n  myVar1: test\n"
```

The data is available on the filesystem:

ID file:
```
cat localdata/cicdContextData.id

context-data-id-1
```

as JSON:
```
cat localdata/cicdContextData.json | jq .'state'

{
  "cicdContextDataId": "context-data-id-1",
  "cicdContextName": "stage",
  "key1
```

as YAML:
```
cat localdata/cicdContextData.yaml | yq r - 'state'

cicdContextDataId: context-data-id-1
cicdContextName: stage
key1: value1
```

as a sourceable shell script:
```
source localdata/cicdContextData.sh

$ echo $CICD_state__key1
value1

$ echo $CICD_pipelines__build__event_handlers__init__notify__message
{{ helloWorld('start is successful') }}

$ echo $CICD_state__cicdContextDataId
context-data-id-1
```


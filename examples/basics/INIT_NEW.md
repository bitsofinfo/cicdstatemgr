# Initialize a new set of cicd context data

*NOTE: see the functioning [scripts in the test/ directory](test/) for commands that match what is described in this doc*

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

2020-08-06 11:55:57,116 - root - DEBUG - DataSourceMgr() Initializing datasource: redis
2020-08-06 11:55:57,119 - root - DEBUG - redis -> localhost isPrimary:True isLocal:False
2020-08-06 11:55:57,120 - root - INFO - DataSourceMgr() primary ds = redis
2020-08-06 11:55:57,120 - root - DEBUG - DataSourceMgr() Initializing datasource: yamlfile
2020-08-06 11:55:57,122 - root - DEBUG - yamlfile -> /Users/bof/Documents/xyz/code/github.com/bitsofinfo/cicdstatemgr/examples/basics/localdata/cicdContextData.yaml isPrimary:False isLocal:True
2020-08-06 11:55:57,122 - root - DEBUG - DataSourceMgr() Initializing datasource: jsonfile
2020-08-06 11:55:57,123 - root - DEBUG - jsonfile -> /Users/bof/Documents/xyz/code/github.com/bitsofinfo/cicdstatemgr/examples/basics/localdata/cicdContextData.json isPrimary:False isLocal:True
2020-08-06 11:55:57,123 - root - DEBUG - DataSourceMgr() Initializing datasource: shellfile
2020-08-06 11:55:57,125 - root - DEBUG - shellfile -> /Users/bof/Documents/xyz/code/github.com/bitsofinfo/cicdstatemgr/examples/basics/localdata/cicdContextData.sh isPrimary:False isLocal:True
2020-08-06 11:55:57,125 - root - DEBUG - DataSourceMgr() Initializing datasource: idfile
2020-08-06 11:55:57,126 - root - DEBUG - idfile -> /Users/bof/Documents/xyz/code/github.com/bitsofinfo/cicdstatemgr/examples/basics/localdata/cicdContextData.id isPrimary:False isLocal:True
2020-08-06 11:55:57,126 - root - DEBUG - initialize() id=context-data-id-1 cicdContextName=stage pathToAppCicdConfigYamlFile=app.yaml basesDir=bases eventPipelineName=None eventNameToFire=None tmplCtxVars=None
2020-08-06 11:55:57,126 - root - DEBUG - initialize() loading app pipeline template: /Users/bof/Documents/xyz/code/github.com/bitsofinfo/cicdstatemgr/examples/basics/app.yaml
2020-08-06 11:55:57,143 - root - DEBUG - initialize() applying base pipeline template: bases/base1.yaml
2020-08-06 11:55:57,147 - root - DEBUG - recursive_set() setting state.key1 to value1 within parent of: None
2020-08-06 11:55:57,147 - root - DEBUG - recursive_set() setting key1 to value1 within parent of: state
2020-08-06 11:55:57,159 - root - DEBUG - persist() skipPrimary=False cicdContextDataId=context-data-id-1
2020-08-06 11:55:57,159 - root - DEBUG - DataSourceMgr.persist() skipPrimary=False cicdContextDataId=context-data-id-1
2020-08-06 11:55:57,159 - root - DEBUG - DataSourceMgr.persist() persisting in: redis
2020-08-06 11:55:57,211 - root - DEBUG - DataSourceMgr.persist() persisting in: yamlfile
2020-08-06 11:55:57,245 - root - DEBUG - DataSourceMgr.persist() persisting in: jsonfile
2020-08-06 11:55:57,247 - root - DEBUG - DataSourceMgr.persist() persisting in: shellfile
2020-08-06 11:55:57,251 - root - DEBUG - DataSourceMgr.persist() persisting in: idfile
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
redis-cli --user cicdstatemgr --pass '123$aBcZ' mget context-data-id-1

1) "channel: stage\npipelines:\n  start:\n    event-handlers:\n      some-event:\n        notify:\n          message: '{{ basicMacro(''some-event fired in the start pipeline'') }}\n\n            '\n  build:\n    event-handlers:\n      testNotifyEvent:\n        notify:\n          message: '{{ basicMacro(''build is successful'') }}\n\n            '\n          capture-response-data:\n          - from: '{{ body.data.channel }}'\n            to: state.lastPostedToNotifyChannel\n          - from: '{{ body }}'\n            to: state.lastPostedHttpResponse\n      testRespondEvent:\n        respond:\n          if: '{{ state.lastPostedHttpResponse }}'\n          url: '{{ event.data.params.request.body.response_url }}'\n          message: '{{ responderMessage(event.data.params.request.body) }}\n\n            '\n      testSetValuesEvent:\n        set-values:\n          gitValues:\n            if: '{{ event.data.params.request.body.head_commit }}'\n            set:\n            - from: '{{ event.data.params.request.body.head_commit.message }}'\n              to: state.commitMsg\n            - from: '{{ event.data.params.request.body.after }}'\n              to: state.commitId\n            - from: '{{ event.data.params.request.body.repository.clone_url }}'\n              to: state.gitCloneUrl\n      testTriggerPipelineEvent:\n        trigger-pipeline:\n          name: build\n          args:\n            whatever: '{{state.postedData.headers.userAgent}}'\n      testManualChoiceEvent:\n        manual-choice:\n          title: '{{ basicMacro(''here are my choices'') }}\n\n            '\n          choices:\n            choiceGroup1:\n              header: 'Choice group one:'\n              options:\n              - text: Choice 1\n                value: c1\n              - text: Choice 2\n                value: c2\n            choiceGroup2:\n              header: 'Choice group two {{ echo(''blah'') }}:'\n              options:\n              - text: '{{state.postedData[state.lastPostedDataRandomId].headers.userAgent}}'\n                value: '{{state.postedData[state.lastPostedDataRandomId].headers.userAgent}}'\nappPipelinesConfig:\n  bases:\n  - base1.yaml\n  jinja2-macros:\n    helloWorld: \"{%- macro helloWorld(msg) -%}\\n  Hello world msg = {{msg}}\\n{%- endmacro\\\n      \\ -%}\\n\"\n  variables:\n    myVar1: test\n  cicd-contexts:\n    stage:\n      channel: stage\n      pipelines:\n        build:\n          event-handlers:\n            testNotifyEvent:\n              notify:\n                message: '{{ basicMacro(''build is successful'') }}\n\n                  '\n                capture-response-data:\n                - from: '{{ body.data.channel }}'\n                  to: state.lastPostedToNotifyChannel\n                - from: '{{ body }}'\n                  to: state.lastPostedHttpResponse\n            testRespondEvent:\n              respond:\n                if: '{{ state.lastPostedHttpResponse }}'\n                url: '{{ event.data.params.request.body.response_url }}'\n                message: '{{ responderMessage(event.data.params.request.body) }}\n\n                  '\n            testSetValuesEvent:\n              set-values:\n                gitValues:\n                  if: '{{ event.data.params.request.body.head_commit }}'\n                  set:\n                  - from: '{{ event.data.params.request.body.head_commit.message }}'\n                    to: state.commitMsg\n                  - from: '{{ event.data.params.request.body.after }}'\n                    to: state.commitId\n                  - from: '{{ event.data.params.request.body.repository.clone_url\n                      }}'\n                    to: state.gitCloneUrl\n            testTriggerPipelineEvent:\n              trigger-pipeline:\n                name: build\n                args:\n                  whatever: '{{state.postedData.headers.userAgent}}'\n            testManualChoiceEvent:\n              manual-choice:\n                title: '{{ basicMacro(''here are my choices'') }}\n\n                  '\n                choices:\n                  choiceGroup1:\n                    header: 'Choice group one:'\n                    options:\n                    - text: Choice 1\n                      value: c1\n                    - text: Choice 2\n                      value: c2\n                  choiceGroup2:\n                    header: 'Choice group two {{ echo(''blah'') }}:'\n                    options:\n                    - text: '{{state.postedData[state.lastPostedDataRandomId].headers.userAgent}}'\n                      value: '{{state.postedData[state.lastPostedDataRandomId].headers.userAgent}}'\njinja2Macros:\n  byName:\n    basicMacro: \"{%- macro basicMacro(msg) -%}\\n  This is basicMacro! msg = {{msg}}\\n\\\n      {%- endmacro -%}\\n\"\n    echo: \"{%- macro echo(msg) -%}\\n  {{msg}}\\n{%- endmacro -%}\\n\"\n    random: \"{%- macro random() -%}\\n  {{ range(10000, 99999) | random }}\\n{%- endmacro\\\n      \\ -%}\\n\"\n    helloWorld: \"{%- macro helloWorld(msg) -%}\\n  Hello world msg = {{msg}}\\n{%- endmacro\\\n      \\ -%}\\n\"\n  all: \"{%- macro basicMacro(msg) -%}\\n  This is basicMacro! msg = {{msg}}\\n{%- endmacro\\\n    \\ -%}{%- macro echo(msg) -%}\\n  {{msg}}\\n{%- endmacro -%}{%- macro random() -%}\\n\\\n    \\  {{ range(10000, 99999) | random }}\\n{%- endmacro -%}{%- macro helloWorld(msg)\\\n    \\ -%}\\n  Hello world msg = {{msg}}\\n{%- endmacro -%}\"\nstate:\n  cicdContextDataId: context-data-id-1\n  cicdContextName: stage\n  key1: value1\nvariables:\n  baseVar1: baseVarVal1\n  myVar1: test\n"
```

Format nicely:
```
redis-cli --user cicdstatemgr --pass '123$aBcZ' mget context-data-id-1 | yq r -
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
  "key1": "value1"
}
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

$ echo $CICD_pipelines__build__event_handlers__testEvent__notify__message
{{ basicMacro('testEventFired!!! yes...') }}

$ echo $CICD_state__cicdContextDataId
context-data-id-1
```


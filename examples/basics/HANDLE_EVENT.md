# --handle-event 

*NOTE: see the functioning [scripts in the test/ directory](test/) for commands that match what is described in this doc*

This demonstrates the usage of `--handle-event` which provides a way to take action (by invoking REST endpoints) and sending data to those endpoints (i.e. Slack or Tekton EventListeners) that reference data within the `cicdContextData` itself. The data that is sent is generally produced via `jinja2` templates which are provided via each event's configuration within an app's pipeline-config.yaml file.

The `--handle-event` argument takes the following syntax:

```
--handle-event <pipelineName>=<eventName>
```

Where `<pipelineName>` is the name of a `pipeline` as defined within an app's `pipeline-config.yaml` for the current cicd context (whether literally or dervied via one or more `bases`)

Where `<eventName>` is the logical name of an event within the named `<pipelineName>`

For example, in an app's pipeline-config.yaml you might have a block like this that defines a `testEvent` within the `stage` `build` pipeline which gets handled by the `notify` event handler.

```
cicd-contexts:
  stage:
    pipelines:
      build:
        event-handlers:
          testEvent:
            notify:
              message: |
                {{ basicMacro('build is successful') }}
```

## event handlers

There are several different event handlers that can be configured. All of the handlers are centered around the concept of taking data from the current `cicdContextData` + event configuration, rendering it via `jinja2` then POSTing it to an endpoint, then optionally consuming values off of the response that is returned and storing them back in the `cicdContextData`

* [notify](#notify)
* [trigger-pipeline](#trigger)
* [manual-choice](#choice)
* [respond](#respond)
* [set-values](#set)

**IMPORTANT**: for purposes of this example, you should run the examples in the order as they appear in the document below

# <a name="#notify"/>notify

The `notify` event handler constructs a `jinja2` context which is a copy of the the `cicdContextData` object PLUS the following keys:

```
configData: <contents of the --config file>
notify: <contents of the notify config stanza>
[any --tmpl-ctx-vars set paths]
```

This context object is then evaluated against the `jinja2` template located in the `--config` file at the `templates.notify` location

The result of that evaluation is then sent as a JSON body over an HTTP(s) `POST` to the `--config` file's configured `slack.url`

The HTTP response from the `POST` (if JSON) is then passed to another `jinja2` evaluation against the rules defined in the `--config` file's `notify.auth-capture-response-data` section as well as the optional `notify.capture-response-data`. This creates a `jinja2` context which is the `cicdContextData` object PLUS the following keys:

```
configData: <contents of the --config file>
body: <the response body unmarshalled from JSON>
```

This context is then used to evaluate each `notify.capture-response-data` and/or `--config` yaml file's `notify.auth-capture-response-data` set of `from:` and `to:` items. Which can be used to capture values from a HTTP response and save them into the `cicdContextData`

The syntax for each `notify` block within an app's pipeline config is:
```
notify:
    message: <any string literal or jinja2 template>

    # array of from/to rules for capturing data from
    # the notify post response body and setting them
    # to property values on the cicdContextData
    capture-response-data:
        - from: <jinja2 template who's output will be set to 'to'>
            to: <jinja2 template that yields a target property.path to set the value found via 'from'>
        ...
```

## notify example

The `notify` event handler is intended to render a message that will be POSTed to an endpoint (like slack). The message is intended to be informative only and not interactive. If you need to render an interactive message, take a look at `manual-choice` instead.

See the [app.yaml](app.yaml) for the event this is referencing:

```
cicdstatemgr    \
     --config config.yaml \
     --secrets secrets.yaml \
     --id "context-data-id-1" \
     --handle-event build=testNotifyEvent
```

Ok what did this do?

* Processed the `event-handlers` under `build` in the current cicd context named `testNotifyEvent` of type `notify` (see [app.yaml](app.yaml))
  
* The `testNotifyEvent` configures a `notify` event handler config. It evaluated the `notify.message` and then applied that against the `templates.notify` in [config.yaml](config.yaml)
  
* The resulting data was then sent via a HTTP post to the `slack.url` configured in [config.yaml](config.yaml) which is https://postman-echo.com/post
  
* The HTTP response returned was then passed back to the `notify.capture-response-data` in [app.yaml](app.yaml) as well as the `notify.auto-capture-response-data` located in [config.yaml](config.yaml)
  
* The `cicdContextData` was updated and saved.

Lets take a look at the state now:

```
redis-cli --user cicdstatemgr --pass '123$aBcZ' mget context-data-id-1 | yq r - state
```

Result in all the extra info captured in our `state`:
```
cicdContextDataId: context-data-id-1
cicdContextName: stage
key1: value1
postedData:
  '15062':
    body:
      message: This is basicMacro! msg = build is successful
    headers:
      userAgent: python-requests/2.24.0
lastPostedDataRandomId: '15062'
lastPostedToNotifyChannel: stage
lastPostedHttpResponse: '{''args'': {}, ''data'': {''channel'': ''stage'', ''message'':
  ''This is basicMacro! msg = build is successful'', ''randomId'': ''15062''}, ''files'':
  {}, ''form'': {}, ''headers'': {''x-forwarded-proto'': ''https'', ''x-forwarded-port'':
  ''443'', ''host'': ''postman-echo.com'', ''x-amzn-trace-id'': ''Root=1-5f2bf058-0aa059cebb6ed2b2300afc00'',
  ''content-length'': ''103'', ''user-agent'': ''python-requests/2.24.0'', ''accept-encoding'':
  ''gzip, deflate'', ''accept'': ''*/*'', ''content-type'': ''application/json; charset=UTF-8'',
  ''authorization'': ''Bearer FAKE_TOKEN'', ''cache-control'': ''no-cache''}, ''json'':
  {''channel'': ''stage'', ''message'': ''This is basicMacro! msg = build is successful'',
  ''randomId'': ''15062''}, ''url'': ''https://postman-echo.com/post''}'
  ```


# <a name="#trigger"/>trigger-pipeline

The `trigger-pipeline` event handler is logically intended to be a special action where you want to automatically trigger another thread of execution within the CICD engine. The `trigger-pipeline` event handler results in a custom HTTP POST being forumlated comprised of a set of custom headers + simple KV pair JSON body POSTED to an HTTP endpoint. This is intended to trigger additional things in a self referencing way such as invoking a [Tekton Triggers EventListener endpoint](https://github.com/tektoncd/triggers/blob/master/docs/eventlisteners.md)

See the [app.yaml](app.yaml) for the event this is referencing as well as the `trigger` section within [config.yaml](config.yaml)

```
cicdstatemgr    \
     --config config.yaml \
     --secrets secrets.yaml \
     --id "context-data-id-1" \
     --set state.triggerAutoArg1=dummyVal \
     --handle-event build=testTriggerPipelineEvent
```

Ok what did this do?

* Processed the `event-handlers` under `build` in the current cicd context named `testTriggerPipelineEvent` of type `trigger-pipeline` (see [app.yaml](app.yaml))
  
* The `testTriggerPipelineEvent` configures a `trigger-pipeline` event handler config. It contains the `title` and multiple `choices` within it, each comprised of a `header` then an array of `text/value` options. These will be consumed by the template in the `templates.manual-choice` section in [config.yaml](config.yaml)
  
* The `trigger` section in [config.yaml](config.yaml) defines where data will be posted to (`url`), the headers that will be auto generated as well as the set of key-value pairs (`auto-args`) that will be combined with the `trigger-pipeline.args` in [app.conf](app.conf) and rendered into JSON body payload. 
  
* The resulting payload was then sent via a HTTP post to the `trigger.url` configured in [config.yaml](config.yaml) which is https://postman-echo.com/post

The `cicdContextData` has no changes applied to it after a `trigger-pipeline` occurs.

The logs will show a POST as follows:

```
2020-08-06 12:38:51,581 - root - DEBUG - event_handle_trigger_pipeline(): POSTing trigger pipeline to https://postman-echo.com/post : {"autoArg1": "dummyVal", "randomId": "52665", "triggerPipelineName": "build", "whatever": "python-requests/2.24.0"}
```


<a name="#choice"/># manual-choice

The `manual-choice` event handler is logically intended to render a message that contains one or more manual sets of "choices", where each set of choices is made up of a `header` and an array of one or more "options" which yield `text` and `value`. How exactly these choice groups and their options are rendered into a message that gets POSTed to an endpoint is entirely up to you. You can define the template that these are rendered against within the `templates.manual-choice` template within [config.yaml](config.yaml)

See the [app.yaml](app.yaml) for the event this is referencing as well as the `templates.manual-choice` section within [config.yaml](config.yaml)

```
cicdstatemgr    \
     --config config.yaml \
     --secrets secrets.yaml \
     --id "context-data-id-1" \
     --handle-event build=testManualChoiceEvent
```

Ok what did this do?

* Processed the `event-handlers` under `build` in the current cicd context named `testManualChoiceEvent` of type `manual-choice` (see [app.yaml](app.yaml))
  
* The `testManualChoiceEvent` configures a `manual-choice` event handler config. It contains the `name` and `args` properties which will be against the configuration located under the `trigger` section in [config.yaml](config.yaml)

* The `templates.manual-choice` section in [config.yaml](config.yaml) defines the template that the `manual-choice` config will be applied against. The result of this is a JSON body that will be POSTed to `slack.url`
  
* The resulting payload was then sent via a HTTP post to the `slack.url` configured in [config.yaml](config.yaml) which is https://postman-echo.com/post

The `cicdContextData` has no changes applied to it after a `manual-choice` POST occurs.

The logs will show a POST as follows:

```
2020-08-06 12:44:41,433 - root - DEBUG - event_handle_manual_choice(): POSTing manual choices to https://postman-echo.com/post : {
   "channel": "stage",
   "randomId": "99678",
    choices": [
      
          { 
            "header": "Choice group one:"
            "options": [
                    
                      {
                        "value": "c1",
                        "text": "Choice 1"
                      } ,
                    
                      {
                        "value": "c2",
                        "text": "Choice 2"
                      } 
                    
                  ]
          } ,
      
          { 
            "header": "Choice group two blah:"
            "options": [
                    
                      {
                        "value": "python-requests/2.24.0",
                        "text": "python-requests/2.24.0"
                      } 
                    
                  ]
          } 
      
    ]
}
```

Again the intent of `manual-choice` is to permit you to render some sort of interactive message to be posted to the configured `slack.url` endpoint. You are responsible for configuring an appropriate application in the target system that will handle the user-interactions by POSTing them BACK to your CICD engine (in the case of Tekton, an [Tekton Trigger EventListener endpoint](https://github.com/tektoncd/triggers/blob/master/docs/eventlisteners.md)) and then parsing the inbound POST, extracting the selected values and then triggering another pipeline that can interpret and act on those values.


# <a name="#set"/>set-values

The `set-values` event handler is logically intended to evaluate something with an `if` and then passing, consume values `from` some reference within a jinja2 context and if that reference yeilds a non-blank value, to set that value `to` another location in `cicdContextData`. 

Each `set-values` block can declare one or more arbitrarilly named items, each of which containing an `if` jinja2 template where if the rendered value is not blank, will then proceed to `set` against the array of `from` and `to` directives

See the [app.yaml](app.yaml) for an example `set-values` event config.

```
cicdstatemgr    \
     --config config.yaml \
     --secrets secrets.yaml \
     --id "context-data-id-1" \
     --handle-event build=testSetValuesEvent
```

Ok what did this do?

* Processed the `event-handlers` under `build` in the current cicd context named `testSetValuesEvent` of type `set-values` (see [app.yaml](app.yaml))
  
* The `testSetValuesEvent` configures a `set-values` event handler config. It contains the `if` and `set` properties 

* The `if` block evaluated the existance of the `state.lastPostedHttpResponse` (set via the `notify` example previously) for existance.

* Because the `if` emitted a non-empty value, it then proceeded to the `set` section which extracted the `data.message` portion of that JSON and set it `to` `state.lastPostedNotifyMessage`
  
* The `cicdContextData` was persisted with this change

Now we can fetch it:
```
redis-cli --user cicdstatemgr --pass '123$aBcZ' mget context-data-id-1 | yq r - state.lastPostedNotifyMessage

This is basicMacro! msg = build is successful
```

# <a name="#respond"/>respond

The `respond` event handler is logically intended to be a quick way to define an event that sends a `message` to a custom `url` `if` some condition passes.

Each `respond` block declares an `if` which if evaluated (jinja2) to a non-blank result will then proceed to evaluate the `url` as well as the `message`. The `message` will be applied against the `templates.responder` template within [config.yaml](config.yaml) and then an HTTP POST with the resulting data to the `url`.

See the [app.yaml](app.yaml) for an example `respond` event config.

```
cicdstatemgr    \
     --config config.yaml \
     --secrets secrets.yaml \
     --id "context-data-id-1" \
     --handle-event build=testRespondEvent
```

Ok what did this do?

* Processed the `event-handlers` under `build` in the current cicd context named `testResponderEvent` of type `responder` (see [app.yaml](app.yaml))
  
* The `testResponderEvent` configures a `respond` event handler config. It contains the `if`, `url` and `set` properties 

* The `if` block evaluated the existance of the `state.lastPostedHttpResponse` (set via the `notify` example previously) for existance.

* Because the `if` emitted a non-empty value, it then proceeded to the `message` section generated a custom message, this was then applied to the `templates.respond` found in [config.yaml](config.yaml) and then POSTed to the `url`

```
2020-08-06 14:04:31,587 - root - DEBUG - event_handle_respond(): POSTing response to https://postman-echo.com/post : {
  "response_text": "dummy responder message for 16769"
}
2020-08-06 14:04:31,600 - urllib3.connectionpool - DEBUG - Starting new HTTPS connection (1): postman-echo.com:443
2020-08-06 14:04:31,819 - urllib3.connectionpool - DEBUG - https://postman-echo.com:443 "POST /post HTTP/1.1" 200 565
2020-08-06 14:04:31,821 - root - DEBUG - event_handle_respond(): POST response OK {'args': {}, 'data': {'response_text': 'dummy responder message for 16769'}, 'files': {}, 'form': {}, 'headers': {'x-forwarded-proto': 'https', 'x-forwarded-port': '443', 'host': 'postman-echo.com', 'x-amzn-trace-id': 'Root=1-5f2c0def-27008cf2dd4baf0e8bbf5026', 'content-length': '58', 'user-agent': 'python-requests/2.24.0', 'accept-encoding': 'gzip, deflate', 'accept': '*/*', 'content-type': 'application/json; charset=UTF-8', 'authorization': 'Bearer FAKE_TOKEN', 'cache-control': 'no-cache'}, 'json': {'response_text': 'dummy responder message for 16769'}, 'url': 'https://postman-echo.com/post'} 
```
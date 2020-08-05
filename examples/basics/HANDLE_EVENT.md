## --handle-event 

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

* `notify`
* `trigger-pipeline`
* `manual-choice`
* `respond`
* `set-values`

## notify

The `notify` event handler constructs a `jinja2` context which is a copy of the the `cicdContextData` object PLUS the following keys:

```
configData: <contents of the --config file>
notify: <contents of the notify config stanza>
[any --tmpl-ctx-vars set paths]
```

This context object is then evaluated against the `jinja2` template located in the `--config` file at the `templates.notify` location

The result of that evaluation is then sent over an HTTP(s) `POST` to the `--config` file's configured `slack.url`

The HTTP response from the `POST` (if JSON) is then passed to another `jinja2` evaluation against the rules defined in the `--config` file's `notify.auth-capture-response-data` section as well as the optional `notify.capture-response-data`. This creates a `jinja2` context which is the `cicdContextData` object PLUS the following keys:

```
configData: <contents of the --config file>
body: <the response body unmarshalled from JSON>
```

This context is then used to evaluate each `notify.capture-response-data` and/or `--config` yaml file's `notify.auth-capture-response-data` set of `from:` and `to:` items. Which can be used to capture values from a HTTP response and save them into the `cicdContextData`


## trigger-pipeline

## manual-choice

## set-values

## respond


`--handle-event` can be used on its own or in conjunction with with `--set`, `--load` and `--init-new` 

This assumes you've already run [INIT_NEW](INIT_NEW.md)

Let's just ensure our latest data exists locally for use by invoking `--load` 
```
rm -rf localdata/*

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --load

ls -al localdata/*
-rw-r--r--  1 bof  staff    17 Aug  2 18:17 localdata/cicdContextData.id
-rw-r--r--  1 bof  staff  1821 Aug  2 18:17 localdata/cicdContextData.json
-rw-r--r--  1 bof  staff  1444 Aug  2 18:17 localdata/cicdContextData.sh
-rw-r--r--  1 bof  staff  1415 Aug  2 18:17 localdata/cicdContextData.yaml
```

Note that the PATH of where the local files are written as well as the filenames themselves can be controlled via the `datasources` section within a [config.yaml](config.yaml) file.

After data is locally cached via `--load` the idea is that you can then utilize the data in various ways:

* Via any programs that can read directly from JSON or YAML such as `jq`, `yq` or others you wrote yourself. Really anything.
  
* Via shell scripts by doing a `source localdata/cicdContextData.sh` to load all variables into the shell for subsequent use

* Via `cicdstatemgr` itself via its `--get` method etc


Load can also be combined w/ `--set` and `--handle-event` such as:
```
cicdstatemgr    \
     --config config.yaml \
     --secrets secrets.yaml \
     --id "context-data-id-1" \
     --load \
     --set state.key1=valuechanged \
     --set state.testHeader2Value="myvalueforheader2" \
     --set state.triggerAutoArg1=99999 \
     --handle-event build=testEvent
```

The above will load the data, write it to all non-primary datasources, then `--set` all your specified values, and then finally `--handle-event` which can subsequently have handlers that reference the data `--set` previously.
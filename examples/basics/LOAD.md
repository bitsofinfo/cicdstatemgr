## --load 

*NOTE: see the functioning [scripts in the test/ directory](test/) for commands that match what is described in this doc*

This demonstrates the usage of `--load` which provides a way to load all data for a given `cicdContextDataId` into both memory for the current invocation as well as into all non-primary stores, sourced from the primary store. 

If you look at [config.yaml](config.yaml) you will see there are multiple `datasources` listed. When `--load` is invoked, the data is loaded from the primary and then flushed to non-primary stores. In this example's case the non-primary stores are just local files, so when you are running a CICD system, `--load` would be called at the start of a task, where the data can then be referenced from numerous subsequent steps. This works nicely w/ [Tekton pipelines](https://github.com/tektoncd/pipeline) as each `Task` is a pod that is made up of multiple `steps` which are `containers`, all of which share a common filesystem. In this setup your first Tekton `Task` `step` can call `--load` to seed the filesystem with local copies of the context data that originates from the primary.

`--load` can be decorated with `--set`, `--handle-event` 

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
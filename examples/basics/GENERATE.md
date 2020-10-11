# --generate 

*NOTE: see the functioning [scripts in the test/ directory](test/) for commands that match what is described in this doc*

This demonstrates the usage of `--generate` which provides a way pre-define data to be generated into the `cicdContextData` on demand at some point in the future. A `generator` is simply a key within an app pipeline config file (like [app.yaml](app.yaml)) that contains one or more `generator configs` defined as:

```
...
generators: 
    # an arbitrarily named "generator" which
    # contains one or more generator configs
    <generatorName>: 

        # a generator config, this can be
        # named anything you want
        <generatorConfigName>:  

            # an optional 'if' condition (jinja2 tmpl) 
            # which if yields a non blank result lets
            # the `set:` items to be set into the cicdContextData
            if: "<jinja2 tmpl>"

            # the key paths and values that will be evaluated
            # and set into the cicdContextData if the condition
            # above passes (or is not specified aat all)
            set:
            - key: "path.to.targetkey (will be jinja2 evaluated)"
              value: "value to be set @key, (will be jinja2 evaluated)"
```

Whenever you call `--generate <pathToNamedGenerator>` the named generator will be looked up at the given `<pathToNamedGenerator>`; for each sub-key within it (i.e. named generatorConfigs), each one will have it's optional `if` evaluated (if it exists); and then each `set` stanza will have its `key/value` evaluated and the resulting `value` will be written into the `cicdContextData`

The `generators` feature can be used to pre-define possible values to be set into the `cicdContextData` at some point in the future, based on the current state in the `cicdContextData` when the `--generate <path>` command is invoked.

This assumes you've already run [INIT_NEW](INIT_NEW.md)

This example is using the `generators` defined in the example [app.yaml](app.yaml)

Let's ensure the following value exists via `--set`:
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set "state.gitTag=myapp-alpine-1.5.9" \
    --set "state.gitAppName=my-application"
```

Run the generator that consumes these values:
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --generate pipelines.build.generators.dockerfile
```

Now lets `--get` the value the generator writes to:
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get state.build.dockerfileInfo.generateDockerfileCmd

./gendockerfile.sh -f alpine:latest -x myapp-alpine-1.5.9
```

Let's change some variables via `--set`:
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set "state.gitTag=myapp-centos-1.5.9" \
    --set "state.gitAppName=my-application"
```

re-run the generator that consumes these values:
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --generate pipelines.build.generators.dockerfile
```

Now lets `--get` the value the generator writes to again, note its different:
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get state.build.dockerfileInfo.generateDockerfileCmd

./gendockerfile.sh -f centos:latest -x myapp-centos-1.5.9
```

## --get 

This assumes you've already run [INIT_NEW](INIT_NEW.md)


Lets create a little template in our `state`:
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
        \
    --id "context-data-id-1" \
    \
    --set "state.templateTest={{tmplctx.prop1}}"
```

Lets use `--get`'s functionality to render templates on a `--get` by passing one or more `--tmpl-ctx-var` that the template references:
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
        \
    --id "context-data-id-1" \
    \
    --get "state.templateTest" \
    --tmpl-ctx-var tmplctx.prop1=state.key1
```

Ok, lets change the value referenced by the template:
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
        \
    --id "context-data-id-1" \
    \
    --set "state.key1=yet a new value"
```

Lets `--get` the template again:
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
        \
    --id "context-data-id-1" \
    \
    --get "state.templateTest" \
    --tmpl-ctx-var tmplctx.prop1=state.key1
```

We can also `--get` it and render out a string literal:
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
        \
    --id "context-data-id-1" \
    \
    --get "state.templateTest" \
    --tmpl-ctx-var tmplctx.prop1=just-a-literal-value
```

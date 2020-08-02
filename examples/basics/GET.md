## --get 

This demonstrates the usage of `--get` which provides a way to fetch any value from the `cicdContextData`. The key feature of `--get` is that the raw value will be evaluated as a `jinja2` template. This permits you to define templates in your `cicdContextData` that refer to any variables, including short lived variables that you can define via the `--tmpl-ctx-data` attribute that will be made available in the `jinja2` context when the `--get` rendering occurs.

Its important to note that the you can still `--get` any literal value, the values can optionally contain `jinja2` syntax.

This assumes you've already run [INIT_NEW](INIT_NEW.md)

Whenever you call `--get` the `cicdContextData` that is loaded will be fetched from any non-primary stores first (i.e. disk files) and then only fetched from a primary store as a last resort if data does not exist in non-primary stores already. See [config.yaml](config.yaml)

Let's ensure the following value exists via `--set`:
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set "state.key1=value1"
```

Get the value:
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get "state.key1"

value1
```

Lets create a little template in our `state` called `templateTest`
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.templateTest={{tmplctx.prop1}}'
```

Lets use `--get`'s functionality to render a template on a `--get` call by passing one or more `--tmpl-ctx-var` that the template references. The left hand side of the value in `--tmpl-ctx-var` is just an arbitrary KV pair that will be added to the `jinja2` context used in the parsing of the value retrieved by `--get`, and the right hand side of the `--tmpl-ctx-var` can either be a literal value or a `jsonpath` expression referencing any other variable in the `cicdContextData`:
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get "state.templateTest" \
    --tmpl-ctx-var tmplctx.prop1=state.key1

value1
```

Ok, lets change the value referenced in the `state.templateTest` value:
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set "state.key1=yet a new value"
```

Lets `--get` the template again:
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get "state.templateTest" \
    --tmpl-ctx-var tmplctx.prop1=state.key1

yet a new value
```

We can also just use `--get` in combination with `--tmpl-ctx-var` where the right hand side of `--tmpl-ctx-var` is just a string literal:
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get "state.templateTest" \
    --tmpl-ctx-var tmplctx.prop1=just-a-literal-value

just-a-literal-value
```

If we `--get` the templated value, but without the `--tmpl-ctx-data`, we will get a normal `jinja2` error
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get "state.templateTest" 

...
2020-08-02 20:23:16,083 - root - DEBUG - get_value() attempting to get: state.templateTest
2020-08-02 20:23:16,104 - root - ERROR - parse_template() template = {{tmplctx.prop1}} error: (<class 'jinja2.exceptions.UndefinedError'>, UndefinedError("'tmplctx' is undefined"))
<jinja2 parse error>
```


And as always, you can just use `--get` to just get a value where the raw value is not a jinja2 template:
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get "state.key1"

yet a new value
```

You can also just assign it to a variable:
```
FETCHED_VALUE=$(cicdstatemgr --config config.yaml  --secrets secrets.yaml --id "context-data-id-1" --get "state.key1")

echo $FETCHED_VALUE

yet a new value
```
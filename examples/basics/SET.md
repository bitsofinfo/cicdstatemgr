# --set 

*NOTE: see the functioning [scripts in the test/ directory](test/) for commands that match what is described in this doc*

This demonstrates the usage of `--set` which provides a way to set any value within the `cicdContextData` as well as load values from `file://` references. 

`--set` can be used in combination with `--init-new`, `--handle-event` and `--load`

This assumes you've already run [INIT_NEW](INIT_NEW.md)

Whenever you call `--set` the `cicdContextData` that is loaded will be fetched from any non-primary stores first (i.e. disk files) and then only fetched from a primary store as a last resort. See [config.yaml](config.yaml)

Each time you `--set` the data is re-flushed to all data sources (primary and non-primary). See [config.yaml](config.yaml)

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

Let's `--set` multiple times:
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set "state.key1=value1" \
    --set "state.key2=value2"
```


Let's reference the contents of a file as the value for `--set`. The syntax in this case is `--set key=file://<pathToFile>` where the file's contents will be written to the `key` within `cicdContextData`. If the file is `JSON` or `YAML` the object/array marshalled from those file types will be injected under the `key`.

Lets just try a simple text file:
```
echo "simple body contents" > set.simple.file

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.fileBody=file://set.simple.file'

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.fileBody'

simple body contents
```


JSON contents w/ an array:
```
echo "[1,2,3]" > set.simple.json

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.fileBody=file://set.simple.json'

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.fileBody[2]'

3
```

JSON contents w/ an object:
```
echo '{"dog":"beagle", "bark":{"quality":"high","volume":"loud"}}' > set.simple.json

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.fileBody=file://set.simple.json'

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.fileBody.bark.quality'

high
```


YAML contents:
```
printf "dog: beagle\nbark:\n  quality: high\n  volume: loud\n" > set.simple.yaml

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.fileBody=file://set.simple.yaml'

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.fileBody.bark.quality'

high
```

---

Let's set an `list`:
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.testList[]=a,b,c'
```

Get it: 
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.testList[2]'

c
```

Append:
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.testList[]=d,e,f'

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.testList'

["a", "b", "c", "d", "e", "f"]
```

Clear and reset + new + append
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.testList[]=[]' \
    --set 'state.testList[]=x,y,z' \
    --set 'state.testList[]=d' 

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.testList'

["x", "y", "z", "d"]
```

---

Let's set an `set` (list w/ no duplicates permitted):
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.testSet{}=a,b,c,c,c,c'
```

Get it: 
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.testSet'

["a", "b", "c"]
```

Append:
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.testSet{}=d,e,e,e,f'

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.testSet'

["a", "b", "c", "d", "e", "f"]
```

Clear and reset + new + append
```
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.testSet{}=[]' \
    --set 'state.testSet{}=x,y,z' \
    --set 'state.testSet{}=d,d,d' 

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.testSet'

["x", "y", "z", "d"]
```
#!/bin/bash

#-----------------
# SET.md
#-----------------

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set "state.key1=value1"

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set "state.key1=value1" \
    --set "state.key2=value2"

echo "simple body contents" > set.simple.file

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.fileBody=file://set.simple.file'

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.fileBody') 
if [ "$VALUE" != 'simple body contents' ]; then
    echo
    echo "FAIL: GET: state.fileBody != simple body contents"
    echo
    exit 1
else
    echo
    echo "OK: GET: state.fileBody"
    echo
fi


echo "[1,2,3]" > set.simple.json

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.fileBody=file://set.simple.json'


VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.fileBody[2]') 
if [ "$VALUE" != '3' ]; then
    echo
    echo "FAIL: GET: state.fileBody[2] != 3"
    echo
    exit 1
else
    echo
    echo "OK: GET: state.fileBody[2]"
    echo
fi



echo '{"dog":"beagle", "bark":{"quality":"high","volume":"loud"}}' > set.simple.json

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.fileBody=file://set.simple.json'

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.fileBody.bark.quality') 
if [ "$VALUE" != 'high' ]; then
    echo
    echo "FAIL: GET: json: state.fileBody.bark.quality != high"
    echo
    exit 1
else
    echo
    echo "OK: GET: json: state.fileBody.bark.quality"
    echo
fi



printf "dog: beagle\nbark:\n  quality: high\n  volume: loud\n" > set.simple.yaml

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.fileBody=file://set.simple.yaml'

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.fileBody.bark.quality') 
if [ "$VALUE" != 'high' ]; then
    echo
    echo "FAIL: GET: yaml: state.fileBody.bark.quality != state.fileBody.bark.quality"
    echo
    exit 1
else
    echo
    echo "OK: GET: yaml: state.fileBody.bark.quality"
    echo
fi





# set: list[]
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.testList[]=a,b,c'

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.testList[2]') 
if [ "$VALUE" != 'c' ]; then
    echo
    echo "FAIL: GET: yaml: state.testList[2] != c"
    echo
    exit 1
else
    echo
    echo "OK: GET: yaml: state.testList[2] == c"
    echo
fi





cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.testList[]=d,e,f'

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.testList') 
if [ "$VALUE" != '["a", "b", "c", "d", "e", "f"]' ]; then
    echo
    echo "FAIL: GET: yaml: state.testList != [\"a\", \"b\", \"c\", \"d\", \"e\", \"f\"]"
    echo
    exit 1
else
    echo
    echo "OK: GET: yaml: state.testList == [\"a\", \"b\", \"c\", \"d\", \"e\", \"f\"]"
    echo
fi




cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.testList[]=x,y,z'

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.testList') 
if [ "$VALUE" != '["a", "b", "c", "d", "e", "f", "x", "y", "z"]' ]; then
    echo
    echo "FAIL: GET: yaml: state.testList != [\"a\", \"b\", \"c\", \"d\", \"e\", \"f\", \"x\", \"y\", \"z\"]"
    echo
    exit 1
else
    echo
    echo "OK: GET: yaml: state.testList == [\"a\", \"b\", \"c\", \"d\", \"e\", \"f\", \"x\", \"y\", \"z\"]"
    echo
fi




cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.testList[]=[]'

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.testList') 
if [ "$VALUE" != '[]' ]; then
    echo
    echo "FAIL: GET: yaml: state.testList != []"
    echo
    exit 1
else
    echo
    echo "OK: GET: yaml: state.testList == []"
    echo
fi




cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.testList[]=a'

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.testList') 
if [ "$VALUE" != '["a"]' ]; then
    echo
    echo "FAIL: GET: yaml: state.testList != [\"a\"]"
    echo
    exit 1
else
    echo
    echo "OK: GET: yaml: state.testList == [\"a\"]"
    echo
fi





## SET (set{})
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.testSet{}=a,a,a'

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.testSet') 
if [ "$VALUE" != '["a"]' ]; then
    echo
    echo "FAIL: GET: yaml: state.testSet != [\"a\"]"
    echo
    exit 1
else
    echo
    echo "OK: GET: yaml: state.testSet == [\"a\"]"
    echo
fi


cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.testSet{}=a,b,b'

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.testSet') 
if [ "$VALUE" != '["a", "b"]' ]; then
    echo
    echo "FAIL: GET: yaml: state.testSet != [\"a\", \"b\"]"
    echo
    exit 1
else
    echo
    echo "OK: GET: yaml: state.testSet == [\"a\", \"b\"]"
    echo
fi



cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.testSet{}=[]'

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.testSet') 
if [ "$VALUE" != '[]' ]; then
    echo
    echo "FAIL: GET: yaml: state.testSet != []"
    echo
    exit 1
else
    echo
    echo "OK: GET: yaml: state.testSet == []"
    echo
fi


cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.testSet{}=a,b,b,c,d,d'

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.testSet') 
if [ "$VALUE" != '["a", "b", "c", "d"]' ]; then
    echo
    echo "FAIL: GET: yaml: state.testSet != [\"a\", \"b\", \"c\", \"d\"]"
    echo
    exit 1
else
    echo
    echo "OK: GET: yaml: state.testSet == [\"a\", \"b\", \"c\", \"d\"]"
    echo
fi
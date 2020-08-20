# Basic example

The following examples will give you a decent overview of how you can make use of `cicdstatemgr`

[For more background info see this blog post](https://bitsofinfo.wordpress.com/2020/08/13/tekton-pipelines-cicd-slack-triggers-state/)

## scripts

Note that all the examples provided in the various markdown files in this directory are also covered in the [scripts in the test/ directory](test/)

## Pre-req: Setup Redis

Make sure you are within this directory (examples/basics) on your local machine when running the commands below

Start a local redis
```
docker run \
    -d \
    -v `pwd`/redis.conf:/usr/local/etc/redis/redis.conf \
    -p 6379:6379 \
    --name cicdstatemgr-redis redis redis-server /usr/local/etc/redis/redis.conf
```

Verify connectivity:
```
$ redis-cli

127.0.0.1:6379> mset x y
(error) NOAUTH Authentication required.

127.0.0.1:6379> auth cicdstatemgr 123$aBcZ
OK

127.0.0.1:6379> mset x y
OK

127.0.0.1:6379> mget x
1) "y"
```

## Setup your redis configuration

Take a look at `config.yaml` and `secrets.yaml`. Within these files are non-secret configs and sensitive configs. The general structure of both files is the same with secrets separated from non-secret config data. 

## Setup a local python virtual env

```
python3 -m venv venv
source venv/bin/activate
pip install wheel
pip install cicdstatemgr
```

## Optionally install yq & jq

https://github.com/mikefarah/yq

https://github.com/stedolan/jq

# Exploring the cicdstatemgr CLI options

## --init-new

Lets start by imagining a new pipeline starts in our CICD system, we have a task that needs to initialize a new set of CICD context data.

Lets start by using the [--init-new set of arguments](INIT_NEW.md)

## --get

Next lets `--get` some values from the context data by using the [--get argument](GET.md)

## --set

Next lets `--set` some values into the context data by using the [--set argument](SET.md)

## --load

Next lets `--load` the context data for usage via [--load argument](LOAD.md)

## --handle-event

Finally lets play with the `--handle-event` option to fire off HTTP POSTs to endpoints and automatically set values etc via the [--handle-event argument](HANDLE_EVENT.md)

# Notes

local dev in this dir: 
```
pip install --requirement requirements.txt
```
# Basic example

The following examples will give you a brief overview of how you can uses `cicdstatemgr`

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

## --init-new

Lets start by imagining a new pipeline starts in our CICD system, we have a task that needs to initialize a new set of CICD context data.

Lets start by using the [--init-new set of arguments](INIT_NEW.md)



## --get

Next lets `--get` some values from the context data by using the [--get argument](GET.md)
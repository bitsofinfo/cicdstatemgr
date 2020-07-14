# cicdstatemgr

[![PyPI version](https://badge.fury.io/py/cicdstatemgr.svg)](https://badge.fury.io/py/cicdstatemgr) [![Docker build](https://img.shields.io/docker/automated/bitsofinfo/cicdstatemgr)](https://hub.docker.com/repository/docker/bitsofinfo/cicdstatemgr)


`cicdstatemgr` is a Python package who's intent is to make your life a bit easier when developing a CICD solution that needs to maintain configuration and state across multiple workflows and contexts of execution while providing a framework for enabling reaction to "events" by invoking custom endpoints.

This project was born out of needs that arised when building a custom CI/CD solution using the Kubernetes native [Tekton Pipelines](https://github.com/tektoncd/pipeline) project.

* [Examples](examples/) 
* [Install](#install)

## Overview and concepts

So what does this do exactly?

`cicdstatemgr` provides a small library and CLI to help you maintain state and configuration that can span process/task boundaries in a CICD system that does not natively provide such a facility. It also provides some built in features that let you handle "events" by invoking HTTP endpoints for doing things like notifications, triggering hooks etc.

Within a CICD system you often have one or more pipelines, each of which is made up of one or more tasks. Sometimes tasks run one after another, other times there is some manual intervention etc. Likewise when you have different but related pipelines that have to execute in a specific order. Within this kind of setup you generally have a lot of configuration and execution "state" that you want to maintain, i.e. variables, meta-data, audit information etc, and you want to be able to manage this state across different processes boundaries. 

You also might have a need to let each application that is being pushed through a pipeline to provide its own customizations to modify the behavior of your CICD engine.

For example in its simplest form, some raw `state` might look like this:
```
state:
  appVersion: 1.0.0
  appName: my-app
  myProp: myValue
  myProp2: 
    p1: v1
    p2: v2
  events:
    build:
      status: failed
  ...
```

Your tasks might need to both read and write to information in this `state` and ensure its persisted somewhere. `cicdstatemgr` can help with this.

**What cicdstatemgr is not**

* It is not a CICD engine, its only a tool that you can use within a CICD engine to help configure, customize and maintain state for your CICD application


### Concepts

Here are some relevant terms referred to when using `cicdstatemgr`. 

* **cicd context**: defines a logical context within a CICD system; a CICD context is comprised of one or more named "pipelines". You can have multiple `cicd-contexts` within a system. What makes one `cicd-context` different from another might be the target systems it deploys application to, or the security context it executes within etc. The names and how many contexts you have is totally up to you.
  
* **cicd context data**: defines a set of "data" (configuration + state) that is created at the start of a new `cicd-context` and made available to all pipelines that execute within scope of the `cicd-context`. What is contained within the `state` is totally up to you.

* **cicd context data ID**: the unique identifier for each set of `cicd context data`


## Requirements

Python 3.8+

## Install

`cicdstatemgr` can be used as a Python module dependency within another Python script OR you can run it independently via its CLI interface natively or via Docker.

### Install via pip

```
pip install cicdstatemgr 
```

Once installed you can just use the CLI:
```
cicdstatemgr --help
```

Or use it from within another Python program:
```
$> python3
Python 3.8.3 (default, Jul  7 2020, 13:01:48) 
[Clang 11.0.0 (clang-1100.0.33.17)] on darwin
Type "help", "copyright", "credits" or "license" for more information.

>>> from cicdstatemgr import cicdstatemgr

>>> mgr=cicdstatemgr.CicdStateMgr(configFilePath='examples/basics/config.yaml',secretsFilePath='examples/basics/secrets.yaml')

>>> mgr
<cicdstatemgr.cicdstatemgr.CicdStateMgr object at 0x10df2e310>
```

### Run via Docker

```
docker run -it bitsofinfo/cicdstatemgr:1.0.17 cicdstatemgr -h
```




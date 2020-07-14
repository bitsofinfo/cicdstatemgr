# cicdstatemgr

[![PyPI version](https://badge.fury.io/py/cicdstatemgr.svg)](https://badge.fury.io/py/cicdstatemgr) [![Docker build](https://img.shields.io/docker/automated/bitsofinfo/cicdstatemgr)](https://hub.docker.com/repository/docker/bitsofinfo/cicdstatemgr)


`cicdstatemgr` is a Python package who's intent is to make your life a bit easier when developing a CICD solution that needs to maintain state across multiple workflows and contexts of execution while providing a framework for enabling end-user interaction via tools like Slack.

This project was born out of needs that arised when building a custom CI/CD solution using the Kubernetes native [Tekton Pipelines](https://github.com/tektoncd/pipeline) project.

* [Examples](examples/) 
* [Install](#install)


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




#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
"""

import base64
import yaml
import json
from jinja2 import Environment

def createEnvironment() -> Environment:
    env = Environment(extensions=['jinja2.ext.loopcontrols'])
    env.filters['to_nice_yaml'] = to_nice_yaml
    env.filters['from_json'] = from_json
    env.filters['kv_comma_pairs_to_json'] = kv_comma_pairs_to_json
    env.filters['to_base64'] = to_base64
    return env
    

# Jinja filter
def from_json(value):
    return json.loads(value)

# Jinja filter
def to_nice_yaml(value, default_flow_style=False, sort_keys=False, indent=2):
    return yaml.dump(value, default_flow_style=False, sort_keys=sort_keys, indent=indent)

# Jinja filter
def kv_comma_pairs_to_json(value):
    obj = {}
    for kvpair in value.split(","):
        if kvpair and kvpair != '' and '=' in kvpair:
            key = kvpair.split("=")[0]
            val = kvpair.split("=")[1]
            obj[key] = val

    return json.dumps(obj)

# Jinja filter
def to_base64(value):
    return base64.b64encode(value.encode('utf-8')).decode('utf-8')



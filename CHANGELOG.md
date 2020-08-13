# 1.0.22
* add support for toggling any `event-handlers:` sub entry in a derivative via `enabled: False` See #4

# 1.0.21
* jinja2 parse error include original non-macro prefixed template
* parse `to` on set-values handlers
* add `from_json` jinja2 filter
* all CLI env var names change prefix from `CICDOPS_` to `CICDSTATEMGR_`

# 1.0.20
* fix `--get` when `get_via_jsonng_expression()` has jsonpath parse error. return literal expression as the value
  
# 1.0.19
* fix `--get` value parse handling where right hand side is not an expression, return literal value on no-match

# 1.0.18
* documentation
* log statement level clarity
* added `latest` docker tag
* fix `setup.py` for dependencies

# 1.0.0 - 1.0.17
* getting travis functioning properly
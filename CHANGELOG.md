# 1.2.4
* fix `generate` json patch match comparison

# 1.2.3
* bump `FROM bitsofinfo/cicd-toolbox:3.0.5`
  
# 1.2.2
* Do not emit `None` on `--get` if value returned is `None` (null, not found etc)
  
# 1.2.1
* Ensure `--tmpl-ctx-var` can be used in combination w/ `--generate`
  
# 1.2.0
* Support for new `generators` capability and `--generate` argument to the CLI. https://github.com/bitsofinfo/cicdstatemgr/issues/9

# 1.1.3
* Fix bug w/ `trigger-pipeline` and no subkey configuration

# 1.1.2
* Support multiple handlers of type `notify` and `trigger-pipeline` per https://github.com/bitsofinfo/cicdstatemgr/issues/1
* Add `if` support for `notify` and `trigger-pipeline` blocks

# 1.1.1
* Fix non-json http responses in `respond` handling
* Support arbitrary variables in `respond` config blocks and jinja2 parse them

# 1.1.0
* Added support for `choice-generators` within `manual-choice` event handlers. Permits the dynamic generation of new choice sets via a `template` based on a pointer to a dictionary containing data that can be cross referened in an `iterator`. 
* Added `*-capture-response-data` support for `manual-choice` POSTs
 
# 1.0.26
* address #8 new jinja2 filter `json_dumps(value,indent=None,stripLeadingTrailingQuotes=False)`
 
# 1.0.25
* address #6 fix `--tmpl-ctx-var` w/ `=` vals

# 1.0.24
* address #5 exclude shell datasource from generating jinja2macro shell vars (too large)

# 1.0.23

* document/refine support for the `list` datatype for the `--set` argument
  * i.e. `--set some.path.myset[]=e,f,g,e` = [e,f,g,e]
  * any subsequent `--set` calls to same key act as an add/extension to existing values
  * `--set some.path.myset[]=[]` clears any pre-existing values

* add support for the `set` datatype (no-duplicates list) for the `--set` argument
  * i.e. `--set some.path.myset{}=e,f,g,e` = [e,f,g]
  * any subsequent `--set` calls to same key act as an add/extension to existing values
  * `--set some.path.myset{}=[]` clears any pre-existing values
  
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
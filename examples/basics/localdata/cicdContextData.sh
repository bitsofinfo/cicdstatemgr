CICD_channel="stage"
CICD_pipelines__start__event_handlers__some_event__notify__message="{{ basicMacro('some-event fired') }}
"
CICD_pipelines__build__event_handlers__init__notify__message="{{ helloWorld('build is successful') }}
"
CICD_appPipelinesConfig__bases__0="base1.yaml"
CICD_appPipelinesConfig__jinja2_macros__helloWorld="{%- macro helloWorld(msg) -%}
  Hello world msg = {{msg}}
{%- endmacro -%}
"
CICD_appPipelinesConfig__variables__myVar1="test"
CICD_appPipelinesConfig__cicd_contexts__stage__channel="stage"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__init__notify__message="{{ helloWorld('build is successful') }}
"
CICD_jinja2Macros__byName__basicMacro="{%- macro basicMacro(msg) -%}
  This is basicMacro! msg = {{msg}}
{%- endmacro -%}
"
CICD_jinja2Macros__byName__helloWorld="{%- macro helloWorld(msg) -%}
  Hello world msg = {{msg}}
{%- endmacro -%}
"
CICD_jinja2Macros__all="{%- macro basicMacro(msg) -%}
  This is basicMacro! msg = {{msg}}
{%- endmacro -%}{%- macro helloWorld(msg) -%}
  Hello world msg = {{msg}}
{%- endmacro -%}"
CICD_state__cicdContextDataId="context-data-id-1"
CICD_state__cicdContextName="stage"
CICD_state__key1="value1"
CICD_variables__baseVar1="baseVarVal1"
CICD_variables__myVar1="test"

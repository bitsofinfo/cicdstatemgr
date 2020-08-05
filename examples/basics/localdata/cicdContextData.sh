CICD_channel="stage"
CICD_pipelines__start__event_handlers__some_event__notify__message="{{ basicMacro('some-event fired in the start pipeline') }}
"
CICD_pipelines__build__event_handlers__testEvent__notify__message="{{ basicMacro('build is successful') }}
"
CICD_pipelines__build__event_handlers__testEvent__trigger_pipeline__name="build"
CICD_pipelines__build__event_handlers__testEvent__trigger_pipeline__args__whatever="{{state.postedData.headers.userAgent}}"
CICD_pipelines__build__event_handlers__testEvent__manual_choice__title="{{ basicMacro('here are my choices') }}
"
CICD_pipelines__build__event_handlers__testEvent__manual_choice__choices__choiceGroup1__header="Choice group one:"
CICD_pipelines__build__event_handlers__testEvent__manual_choice__choices__choiceGroup1__options__0__text="Choice 1"
CICD_pipelines__build__event_handlers__testEvent__manual_choice__choices__choiceGroup1__options__0__value="c1"
CICD_pipelines__build__event_handlers__testEvent__manual_choice__choices__choiceGroup1__options__1__text="Choice 2"
CICD_pipelines__build__event_handlers__testEvent__manual_choice__choices__choiceGroup1__options__1__value="c2"
CICD_pipelines__build__event_handlers__testEvent__manual_choice__choices__choiceGroup2__header="Choice group two {{ echo('blah') }}:"
CICD_pipelines__build__event_handlers__testEvent__manual_choice__choices__choiceGroup2__options__0__text="{{state.postedData[state.lastPostedDataRandomId].headers.userAgent}}"
CICD_pipelines__build__event_handlers__testEvent__manual_choice__choices__choiceGroup2__options__0__value="{{state.postedData[state.lastPostedDataRandomId].headers.userAgent}}"
CICD_appPipelinesConfig__bases__0="base1.yaml"
CICD_appPipelinesConfig__jinja2_macros__helloWorld="{%- macro helloWorld(msg) -%}
  Hello world msg = {{msg}}
{%- endmacro -%}
"
CICD_appPipelinesConfig__variables__myVar1="test"
CICD_appPipelinesConfig__cicd_contexts__stage__channel="stage"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testEvent__notify__message="{{ basicMacro('build is successful') }}
"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testEvent__trigger_pipeline__name="build"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testEvent__trigger_pipeline__args__whatever="{{state.postedData.headers.userAgent}}"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testEvent__manual_choice__title="{{ basicMacro('here are my choices') }}
"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testEvent__manual_choice__choices__choiceGroup1__header="Choice group one:"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testEvent__manual_choice__choices__choiceGroup1__options__0__text="Choice 1"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testEvent__manual_choice__choices__choiceGroup1__options__0__value="c1"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testEvent__manual_choice__choices__choiceGroup1__options__1__text="Choice 2"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testEvent__manual_choice__choices__choiceGroup1__options__1__value="c2"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testEvent__manual_choice__choices__choiceGroup2__header="Choice group two {{ echo('blah') }}:"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testEvent__manual_choice__choices__choiceGroup2__options__0__text="{{state.postedData[state.lastPostedDataRandomId].headers.userAgent}}"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testEvent__manual_choice__choices__choiceGroup2__options__0__value="{{state.postedData[state.lastPostedDataRandomId].headers.userAgent}}"
CICD_jinja2Macros__byName__basicMacro="{%- macro basicMacro(msg) -%}
  This is basicMacro! msg = {{msg}}
{%- endmacro -%}
"
CICD_jinja2Macros__byName__echo="{%- macro echo(msg) -%}
  {{msg}}
{%- endmacro -%}
"
CICD_jinja2Macros__byName__random="{%- macro random() -%}
  {{ range(10000, 99999) | random }}
{%- endmacro -%}
"
CICD_jinja2Macros__byName__helloWorld="{%- macro helloWorld(msg) -%}
  Hello world msg = {{msg}}
{%- endmacro -%}
"
CICD_jinja2Macros__all="{%- macro basicMacro(msg) -%}
  This is basicMacro! msg = {{msg}}
{%- endmacro -%}{%- macro echo(msg) -%}
  {{msg}}
{%- endmacro -%}{%- macro random() -%}
  {{ range(10000, 99999) | random }}
{%- endmacro -%}{%- macro helloWorld(msg) -%}
  Hello world msg = {{msg}}
{%- endmacro -%}"
CICD_state__cicdContextDataId="context-data-id-1"
CICD_state__cicdContextName="stage"
CICD_state__key1="valuechanged"
CICD_state__testHeader2Value="myvalueforheader2"
CICD_state__triggerAutoArg1="99999"
CICD_state__postedData__12191__body__message="This is basicMacro! msg = some-event fired in the start pipeline"
CICD_state__postedData__12191__headers__userAgent="python-requests/2.24.0"
CICD_state__lastPostedDataRandomId="12191"
CICD_variables__baseVar1="baseVarVal1"
CICD_variables__myVar1="test"

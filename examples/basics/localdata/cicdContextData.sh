CICD_channel="stage"
CICD_pipelines__start__event_handlers__some_event__notify__message="{{ basicMacro('some-event fired in the start pipeline') }}
"
CICD_pipelines__test__event_handlers__another_event__notify__message="{{ basicMacro('another-event fired in the test pipeline') }}
"
CICD_pipelines__build__event_handlers__testEvent__notify__message="{{ basicMacro('testEventFired!!! yes...') }}
"
CICD_pipelines__build__event_handlers__testNotifyEvent__notify__message="{{ basicMacro('build is successful') }}
"
CICD_pipelines__build__event_handlers__testNotifyEvent__notify__capture_response_data__0__from="{{ body.data.channel }}"
CICD_pipelines__build__event_handlers__testNotifyEvent__notify__capture_response_data__0__to="state.lastPostedToNotifyChannel"
CICD_pipelines__build__event_handlers__testNotifyEvent__notify__capture_response_data__1__from="{{ body|tojson }}"
CICD_pipelines__build__event_handlers__testNotifyEvent__notify__capture_response_data__1__to="state.lastPostedHttpResponse"
CICD_pipelines__build__event_handlers__testRespondEvent__respond__if="{{ state.lastPostedHttpResponse }}"
CICD_pipelines__build__event_handlers__testRespondEvent__respond__url="{{ (state.lastPostedHttpResponse|from_json).url }}"
CICD_pipelines__build__event_handlers__testRespondEvent__respond__message="dummy responder message for {{ state.lastPostedDataRandomId }}
"
CICD_pipelines__build__event_handlers__testSetValuesEvent__set_values__extractLastPostedNotifyMessage__if="{%- if state.lastPostedHttpResponse -%}
  1
{%- endif -%}  
"
CICD_pipelines__build__event_handlers__testSetValuesEvent__set_values__extractLastPostedNotifyMessage__set__0__from="{%- set lastPostedHttpResponse = (state.lastPostedHttpResponse|from_json) -%}
{{- lastPostedHttpResponse.data.message -}}
"
CICD_pipelines__build__event_handlers__testSetValuesEvent__set_values__extractLastPostedNotifyMessage__set__0__to="state.lastPostedNotifyMessage"
CICD_pipelines__build__event_handlers__testTriggerPipelineEvent__trigger_pipeline__name="build"
CICD_pipelines__build__event_handlers__testTriggerPipelineEvent__trigger_pipeline__args__whatever="{{state.postedData[state.lastPostedDataRandomId].headers.userAgent}}"
CICD_pipelines__build__event_handlers__testManualChoiceEvent__manual_choice__title="{{ basicMacro('here are my choices') }}
"
CICD_pipelines__build__event_handlers__testManualChoiceEvent__manual_choice__choices__choiceGroup1__header="Choice group one:"
CICD_pipelines__build__event_handlers__testManualChoiceEvent__manual_choice__choices__choiceGroup1__options__0__text="Choice 1"
CICD_pipelines__build__event_handlers__testManualChoiceEvent__manual_choice__choices__choiceGroup1__options__0__value="c1"
CICD_pipelines__build__event_handlers__testManualChoiceEvent__manual_choice__choices__choiceGroup1__options__1__text="Choice 2"
CICD_pipelines__build__event_handlers__testManualChoiceEvent__manual_choice__choices__choiceGroup1__options__1__value="c2"
CICD_pipelines__build__event_handlers__testManualChoiceEvent__manual_choice__choices__choiceGroup2__header="Choice group two {{ echo('blah') }}:"
CICD_pipelines__build__event_handlers__testManualChoiceEvent__manual_choice__choices__choiceGroup2__options__0__text="{{state.postedData[state.lastPostedDataRandomId].headers.userAgent}}"
CICD_pipelines__build__event_handlers__testManualChoiceEvent__manual_choice__choices__choiceGroup2__options__0__value="{{state.postedData[state.lastPostedDataRandomId].headers.userAgent}}"
CICD_appPipelinesConfig__bases__0="base1.yaml"
CICD_appPipelinesConfig__jinja2_macros__helloWorld="{%- macro helloWorld(msg) -%}
  Hello world msg = {{msg}}
{%- endmacro -%}
"
CICD_appPipelinesConfig__variables__myVar1="test"
CICD_appPipelinesConfig__cicd_contexts__stage__channel="stage"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testEvent__notify__message="{{ basicMacro('testEventFired!!! yes...') }}
"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testNotifyEvent__notify__message="{{ basicMacro('build is successful') }}
"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testNotifyEvent__notify__capture_response_data__0__from="{{ body.data.channel }}"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testNotifyEvent__notify__capture_response_data__0__to="state.lastPostedToNotifyChannel"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testNotifyEvent__notify__capture_response_data__1__from="{{ body|tojson }}"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testNotifyEvent__notify__capture_response_data__1__to="state.lastPostedHttpResponse"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testRespondEvent__respond__if="{{ state.lastPostedHttpResponse }}"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testRespondEvent__respond__url="{{ (state.lastPostedHttpResponse|from_json).url }}"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testRespondEvent__respond__message="dummy responder message for {{ state.lastPostedDataRandomId }}
"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testSetValuesEvent__set_values__extractLastPostedNotifyMessage__if="{%- if state.lastPostedHttpResponse -%}
  1
{%- endif -%}  
"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testSetValuesEvent__set_values__extractLastPostedNotifyMessage__set__0__from="{%- set lastPostedHttpResponse = (state.lastPostedHttpResponse|from_json) -%}
{{- lastPostedHttpResponse.data.message -}}
"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testSetValuesEvent__set_values__extractLastPostedNotifyMessage__set__0__to="state.lastPostedNotifyMessage"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testTriggerPipelineEvent__trigger_pipeline__name="build"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testTriggerPipelineEvent__trigger_pipeline__args__whatever="{{state.postedData[state.lastPostedDataRandomId].headers.userAgent}}"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testManualChoiceEvent__manual_choice__title="{{ basicMacro('here are my choices') }}
"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testManualChoiceEvent__manual_choice__choices__choiceGroup1__header="Choice group one:"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testManualChoiceEvent__manual_choice__choices__choiceGroup1__options__0__text="Choice 1"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testManualChoiceEvent__manual_choice__choices__choiceGroup1__options__0__value="c1"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testManualChoiceEvent__manual_choice__choices__choiceGroup1__options__1__text="Choice 2"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testManualChoiceEvent__manual_choice__choices__choiceGroup1__options__1__value="c2"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testManualChoiceEvent__manual_choice__choices__choiceGroup2__header="Choice group two {{ echo('blah') }}:"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testManualChoiceEvent__manual_choice__choices__choiceGroup2__options__0__text="{{state.postedData[state.lastPostedDataRandomId].headers.userAgent}}"
CICD_appPipelinesConfig__cicd_contexts__stage__pipelines__build__event_handlers__testManualChoiceEvent__manual_choice__choices__choiceGroup2__options__0__value="{{state.postedData[state.lastPostedDataRandomId].headers.userAgent}}"
CICD_state__cicdContextDataId="context-data-id-1"
CICD_state__cicdContextName="stage"
CICD_state__key1="valuechanged"
CICD_state__templateTest="{{tmplctx.prop1}}"
CICD_state__key2="value2"
CICD_state__fileBody__dog="beagle"
CICD_state__fileBody__bark__quality="high"
CICD_state__fileBody__bark__volume="loud"
CICD_state__testList__0="a"
CICD_state__testSet__0="a"
CICD_state__testSet__1="b"
CICD_state__testSet__2="c"
CICD_state__testSet__3="d"
CICD_state__testHeader2Value="myvalueforheader2"
CICD_state__triggerAutoArg1="dummyVal"
CICD_state__postedData__50608__body__message="This is basicMacro! msg = testEventFired!!! yes..."
CICD_state__postedData__50608__headers__userAgent="python-requests/2.24.0"
CICD_state__postedData__25350__body__message="This is basicMacro! msg = build is successful"
CICD_state__postedData__25350__headers__userAgent="python-requests/2.24.0"
CICD_state__lastPostedDataRandomId="25350"
CICD_state__lastPostedToNotifyChannel="stage"
CICD_state__lastPostedHttpResponse="{"args": {}, "data": {"channel": "stage", "message": "This is basicMacro! msg = build is successful", "randomId": "25350"}, "files": {}, "form": {}, "headers": {"accept": "*/*", "accept-encoding": "gzip, deflate", "authorization": "Bearer FAKE_TOKEN", "cache-control": "no-cache", "content-length": "103", "content-type": "application/json; charset=UTF-8", "host": "postman-echo.com", "user-agent": "python-requests/2.24.0", "x-amzn-trace-id": "Root=1-5f3eb56d-2e4f112af109c06ea527b2e4", "x-forwarded-port": "443", "x-forwarded-proto": "https"}, "json": {"channel": "stage", "message": "This is basicMacro! msg = build is successful", "randomId": "25350"}, "url": "https://postman-echo.com/post"}"
CICD_state__lastPostedNotifyMessage="This is basicMacro! msg = build is successful"
CICD_variables__baseVar1="baseVarVal1"
CICD_variables__myVar1="test"

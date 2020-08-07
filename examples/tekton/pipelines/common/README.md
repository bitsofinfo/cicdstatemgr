# common

This folder contains shared `common` `Tasks` and `Conditions`

## tasks/handle-event.yaml

Called by various pipelines, amongst other params, takes a string `eventName` and a `setContextDataValues` list of `state` values to set prior to firing the named event. 

##  conditions/conditions.yaml

Defines various Tekton `Condition` tasks that are used for evaluating exit-codes or arbitrary inputs. These are used by most `Pipelines` for evaluating success/failures etc.

# common

This folder contains shared `common` `Tasks` and `Conditions`

## tasks/handle-event.yaml

Called by various pipelines, amongst other params, takes a string `eventName` and a `setContextDataValues` list of `state` values to set prior to firing the named event. 

## tasks/init.yaml

Called at the start of most pipelines to initialize it within an already pre-existing CICD context identified by `cicdContextDataId`, invokes `cicd-pipeline-boot.py` which will authorize the `invokedBy` parameter and then proceed to `load` the latest CICD context state, set arbitrary cicd context data values, and then fire the `init` event.

##  conditions/conditions.yaml

Defines various Tekton `Condition` tasks that are used for evaluating exit-codes or arbitrary inputs. These are used by most `Pipelines` for evaluating success/failures etc.

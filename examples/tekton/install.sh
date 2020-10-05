#!/bin/bash

cd core
./install.sh

echo "Sleeping 30s for tekton core resources to come up....."
sleep 30

cd ../pipelines
./install.sh

cd ..

echo
echo "Waiting for services to come up "
READY=1
while [ "$READY" != "0" ]; do
    sleep 1
    CAPTURE=$(kubectl get pods | grep el-event-listener| grep Running)
    READY=$?
    echo -n "."
done

sleep 5

EVENT_LISTENER_TUNNEL_URI=$(minikube service el-event-listener --url -n tekton-pipelines)
DASHBOARD_TUNNEL_URI=$(minikube service tekton-dashboard --url -n tekton-pipelines)

echo
echo

#exit 0

NGROK_URL=""

if [ ! -z "$EVENT_LISTENER_TUNNEL_URI" ]; then
    EVENT_LISTENER_TUNNEL_URI_IP_PORT="${EVENT_LISTENER_TUNNEL_URI#http://}"
    NGROK_CMD="ngrok http $EVENT_LISTENER_TUNNEL_URI_IP_PORT &>/dev/null"
    echo "Starting ngrok: cmd: $NGROK_CMD ...."
    eval "($NGROK_CMD) &"
    NGROK_PID=$!
    echo -n $NGROK_PID > .ngrok.pid
    sleep 5
    NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq .tunnels[0].public_url)
    NGROK_URL="${NGROK_URL%\"}"
    NGROK_URL="${NGROK_URL#\"}"
    echo
    echo "Local EventListener: $EVENT_LISTENER_TUNNEL_URI"
    echo "Public NGROK EventListener: $NGROK_URL"
    echo "Kill with: kill -TERM $NGROK_PID"
    echo
else
    echo
    echo "You should run the following in a separate terminal:"
    echo ""
    echo "  minikube service el-event-listener-v1 --url -n tekton-pipelines"
    echo
    echo "Once up, grab the port for the el-event-listener-v1 service exposed locally and pass it to ngrok"
    echo
    echo "  ngrok http -log-level \"debug\" [port]"
    echo ""
fi

if [ ! -z "$DASHBOARD_TUNNEL_URI" ]; then
    echo "Tekton dashboard: $DASHBOARD_TUNNEL_URI"
    echo
else
    echo
    echo "You should run the following in a separate terminal:"
    echo ""
    echo "  minikube service tekton-dashboard --url -n tekton-pipelines"
fi


# install the confs
cd pipelines
./install-confs.sh $NGROK_URL $DASHBOARD_TUNNEL_URI
cd ..

echo
echo "Finally go to your fork of https://github.com/bitsofinfo/nginx-hello-world and go to Setting > Webhooks"
echo "and add new new webhook with the following settings:"
echo
echo "  Payload URL = $NGROK_URL"
echo "  Context type = application/json"
echo "  Secret = 123"
echo ""
echo "Next you can trigger a build by pushing a tag from within your nginx-hello-world fork"
echo "  git tag -a [tag] -m \"test\"; git push origin [tag]"
echo ""
echo "After pushing a new tag, go to your tekton-dashboard to view whats going on"
echo ""
echo "Slack notifications are emitted to the bitsofinfo.slack.com #cicdstatemgr-example channel:"
echo "  https://app.slack.com/client/TE2KJDF4L/CE46X7NQN"
echo
echo "Your tag of nginx-hello-world should be deployed, lets hit it:"
echo "  minikube service list"
echo "  minikube service nginx-hello-world-[tag] --url -n apps-dev"
echo ""
echo "  curl http://localhost:[port]"
echo "  You should see 'nginx-hello-world:[tag]] is running within environment: apps-dev'"
echo
echo

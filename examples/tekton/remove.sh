#!/bin/bash


NGROK_PID=$(cat .ngrok.pid)

echo "Killing (-TERM) NGROK at pid: $NGROK_PID"
kill -TERM `cat .ngrok.pid`

echo "Issuing minikube delete"
minikube delete
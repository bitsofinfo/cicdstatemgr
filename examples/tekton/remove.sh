#!/bin/bash

kill -TERM `cat .ngrok.pid`

minikube delete
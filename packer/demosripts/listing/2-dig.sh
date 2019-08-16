#!/usr/bin/env bash

echo "query mongo address:  dig +short mongodb.service.consul srv"
echo

dig +short mongodb.service.consul srv

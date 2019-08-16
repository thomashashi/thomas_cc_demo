#!/usr/bin/env bash

echo "query product address:  dig +short product.connect.consul srv"
echo

dig +short product.connect.consul srv

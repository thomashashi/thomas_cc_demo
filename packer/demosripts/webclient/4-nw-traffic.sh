#!/usr/bin/env bash

dig +short product.connect.consul srv > .rec && HN=$(awk 'NR==1{print $4}' .rec | sed s/\.$//) && HP=$(awk 'NR==1{print $3}' .rec)

sudo tcpdump -A "host $HN and port $HP and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)"

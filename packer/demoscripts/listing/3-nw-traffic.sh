#!/usr/bin/env bash

sudo tcpdump -A 'host mongodb.service.consul and port 27017 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'

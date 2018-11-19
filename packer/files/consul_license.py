#!/usr/bin/python3

# Run as a service under Systemd, fetch consul license from 
# AWS instance user data and apply

# Copyright 2018 HashiCorp, Inc.

import json
import sys
import time

import requests

class LicenseConsulException(Exception):
    pass

class LicenseConsul(object):
    def __init__(self):
        self.state = "START"
        self.license = None


    def do_start(self):
        """Download license file"""
        r = requests.get("http://169.254.169.254/latest/user-data")
        if r.status_code != 200:
            raise LicenseConsulException("Getting user data returned status {}".format(r.status_code))

        self.license = r.text
        self.state = "HAVELICENSE"


    def wait_for_consul(self):
        try:
            r = requests.get('http://127.0.0.1:8500/v1/operator/license', timeout=2)
        except requests.exceptions.Timeout:
            raise LicenseConsulException(
                    "Got timeout trying to fetch license status from Consul, retrying")

        if r.status_code != 200:
            raise LicenseConsulException(
                    "Got status_code {} trying to fetch license status from Consul, retrying".format(r.status_code))

        try:
            license_data = r.json()
        except json.decoder.JSONDecodeError:
            raise LicenseConsulException("Got garbled license json from Consul, retrying")

        license_id = license_data.get('License', {}).get('license_id', None)

        if not isinstance(license_id, str):
            raise LicenseConsulException("`license_id` not found or a not a string, retrying")

        if license_id == 'temporary':
            print("Consul up, we have temporary license")
            self.state = "CONSUL-UP"
        else:
            print("Consul up and doesn't have temporary license, exiting")
            sys.exit(0)


    def register_license(self):
        try:
            r = requests.put('http://127.0.0.1:8500/v1/operator/license',
                    data = self.license,
                    timeout = 2)
        except requests.exceptions.Timeout:
            self.state = "HAVELICENSE"
            raise LicenseConsulException("Timeout trying to apply license, waiting for Consul")

        if r.status_code != 200:
            raise LicenseConsulException("Got status_code {} trying to apply license, retrying")

        print("Consul licensed")
        sys.exit(0)


    def inner_run(self):
        if self.state == "START":
            self.do_start()
        elif self.state == "HAVELICENSE":
            self.wait_for_consul()
        elif self.state == "CONSUL-UP":
            self.register_license()
        else:
            self.state = "START"
            raise LicenseConsulException("Unknown state")


    def run(self):
        while True:
            try:
                self.inner_run()
            except Exception as e:
                print("EXCEPTION noted: {!r}".format(e))
                time.sleep(1)

    
if __name__ == "__main__":
    lc = LicenseConsul()
    lc.run()

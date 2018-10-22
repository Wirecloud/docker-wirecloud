#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (c) 2018 Future Internet Consulting and Development Solutions S.L.

import os
import shutil
import time
import unittest
from urllib.parse import parse_qs, urlparse

import requests
import sh


class WireCloudTests(object):

    def test_version_api_should_be_available(self):
        response = requests.get("http://localhost/api/version")
        self.assertEqual(response.status_code, 200)

    def test_search_engine_should_work(self):
        response = requests.get("http://localhost/api/search?namespace=workspace&maxresults=1")
        self.assertEqual(response.status_code, 200)

    def test_root_page_should_work(self):
        response = requests.get("http://localhost/")
        self.assertEqual(response.status_code, 200)

    def test_home_page_should_work(self):
        response = requests.get("http://localhost/wirecloud/home")
        self.assertEqual(response.status_code, 200)

    def test_should_serve_static_files(self):
        response = requests.get("http://localhost/static/theme/wirecloud.defaulttheme/images/logos/header.png")
        self.assertEqual(response.status_code, 200)


class StandaloneTests(unittest.TestCase, WireCloudTests):

    @classmethod
    def setUpClass(cls):
        print("#")
        print("# Initializing standalone test case")
        print("#\n")
        sh.docker_compose("-f", "docker-compose-standalone.yml", "up", d=True, remove_orphans=True, _fg=True)
        time.sleep(30)
        print()

    @classmethod
    def tearDownClass(cls):
        print()
        print("#")
        print("# Removing containers and volumes")
        print("#\n")
        sh.docker_compose.down(remove_orphans=True, v=True, _fg=True)
        shutil.rmtree('wirecloud-data')
        shutil.rmtree('wirecloud-static')
        print()


class SimpleTests(unittest.TestCase, WireCloudTests):

    @classmethod
    def setUpClass(cls):
        print("#")
        print("# Initializing simple test case")
        print("#\n")
        sh.docker_compose("-f", "docker-compose-simple.yml", "up", d=True, remove_orphans=True, _fg=True)
        time.sleep(30)
        print()

    @classmethod
    def tearDownClass(cls):
        print()
        print("#")
        print("# Removing containers and volumes")
        print("#\n")
        sh.docker_compose.down(remove_orphans=True, v=True, _fg=True)
        shutil.rmtree('wirecloud-data')
        shutil.rmtree('wirecloud-static')
        print()


class ComposedTests(unittest.TestCase, WireCloudTests):

    @classmethod
    def setUpClass(cls):
        print("#")
        print("# Initializing composed test case")
        print("#\n")
        sh.docker_compose.up(d=True, remove_orphans=True, _fg=True)
        time.sleep(30)
        print()

    @classmethod
    def tearDownClass(cls):
        print()
        print("#")
        print("# Removing containers and volumes")
        print("#\n")
        sh.docker_compose.down(remove_orphans=True, v=True, _fg=True)
        shutil.rmtree('wirecloud-data')
        shutil.rmtree('wirecloud-static')
        shutil.rmtree('elasticsearch-data')
        shutil.rmtree('postgres-data')
        print()


class IDMTests(unittest.TestCase, WireCloudTests):

    @classmethod
    def setUpClass(cls):
        print("#")
        print("# Initializing idm test case")
        print("#\n")

        env = {}
        env.update(os.environ)
        env["FIWARE_IDM_SERVER"] = "https://accounts.example.com"
        env["SOCIAL_AUTH_FIWARE_KEY"] = "wirecloud_test_client_id"
        env["SOCIAL_AUTH_FIWARE_SECRET"] = "notused"
        sh.docker_compose("-f", "docker-compose-idm.yml", "up", d=True, remove_orphans=True, _env=env, _fg=True)
        time.sleep(45)
        print()

    @classmethod
    def tearDownClass(cls):
        print()
        print("#")
        print("# Removing containers and volumes")
        print("#\n")
        sh.docker_compose.down(remove_orphans=True, v=True, _fg=True)
        shutil.rmtree('wirecloud-data')
        shutil.rmtree('wirecloud-static')
        shutil.rmtree('elasticsearch-data')
        shutil.rmtree('postgres-data')
        print()

    def test_login_should_redirect_to_idm(self):
        response = requests.get("http://localhost/login/fiware/", allow_redirects=False)
        self.assertEqual(response.status_code, 302)
        location = urlparse(response.headers['Location'])
        self.assertEqual(location.scheme, 'https')
        self.assertEqual(location.netloc, 'accounts.example.com')
        self.assertEqual(location.path, '/oauth2/authorize')
        parameters = parse_qs(location.query)
        self.assertEqual(parameters['client_id'], ['wirecloud_test_client_id'])
        self.assertEqual(parameters['redirect_uri'], ['http://localhost/complete/fiware/'])


if __name__ == "__main__":
    unittest.main(verbosity=2)

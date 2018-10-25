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


class ComposedTests(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        print("#")
        print("# Initializing composed test case")
        print("#\n")
        sh.docker_compose.up(d=True, remove_orphans=True, _fg=True)
        time.sleep(40)
        print()

    @classmethod
    def tearDownClass(cls):
        print()
        print("#")
        print("# Removing containers and volumes")
        print("#\n")
        sh.docker_compose.down(remove_orphans=True, v=True, _fg=True)
        shutil.rmtree('wirecloud_instance')
        shutil.rmtree('postgres-data')
        shutil.rmtree('static')
        print()

    def test_features_api_should_be_available(self):
        response = requests.get("http://localhost/api/features")
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


if __name__ == "__main__":
    unittest.main(verbosity=2)


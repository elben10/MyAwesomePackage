.PHONY: clean clean-test clean-pyc clean-build docs help install test
.DEFAULT_GOAL := help

define BROWSER_PYSCRIPT
import os, webbrowser, sys

try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"

define PRINT_HELP_PYSCRIPT
import re, sys, textwrap

with open('Makefile', 'r') as f:
	matches = re.findall('([A-Za-z-_]+): .*?#@ (.*(?:\n#@ .*)*)', f.read())
	for target, help in matches:
		help = textwrap.wrap(help.replace('\n#@', ''), 60)
		for idx, j in enumerate(help):
			if idx == 0:
				print(f'{target:20s} {j}')
			else:
				print(f'{"":20s} {j}')
endef
export PRINT_HELP_PYSCRIPT

define REMOVE_FOLDER
from glob import glob
from os.path import isdir
from shutil import rmtree
import sys

folder = sys.argv[1]
for i in glob(folder):
	if isdir(i):
		try: 
			rmtree(i)
		except FileNotFoundError:
			pass
endef
export REMOVE_FOLDER

define REMOVE_FOLDER_RECURSIVELY
from glob import glob
from os.path import isdir
from shutil import rmtree
import sys

folder = sys.argv[1]

for i in glob(folder, recursive=True):
	if isdir(i):
		try: 
			rmtree(i)
		except FileNotFoundError:
			pass
endef
export REMOVE_FOLDER_RECURSIVELY

define REMOVE_FILE
from glob import glob
from os import remove
from os.path import isfile
import sys

file = sys.argv[1]

for i in glob(file):
	if isfile(i):
		remove(i)
endef
export REMOVE_FILE

help: 
	@python -c "$$PRINT_HELP_PYSCRIPT"

clean: clean-build clean-pycache clean-test #@ remove all build, python artifacts, test and coverage artifacts

clean-build: #@ remove build artifacts
	@python -c "$$REMOVE_FOLDER" "build"
	@python -c "$$REMOVE_FOLDER" "dist"
	@python -c "$$REMOVE_FOLDER" "*.egg-info"
	@python -c "$$REMOVE_FOLDER" "*.egg"

clean-pycache: #@ remove python artifacts
	@python -c "$$REMOVE_FOLDER_RECURSIVELY" "**/__pycache__"

clean-test: #@ remove test and coverage artifacts
	@python -c "$$REMOVE_FOLDER" ".tox"
	@python -c "$$REMOVE_FOLDER" ".coverage"
	@python -c "$$REMOVE_FOLDER" "htmlcov"
	@python -c "$$REMOVE_FOLDER" ".pytest_cache"

dist: clean ## builds source and wheel package
	python setup.py sdist
	python setup.py bdist_wheel
	ls -l dist

docs: #@ generate Sphinx HTML documentation, including API docs
	$(MAKE) -C docs clean
	$(MAKE) -C docs html
	$(BROWSER) docs/_build/html/index.html

install: clean #@ install the package within the current python site-package folder
	python setup.py install

lint: #@ check style with black
	black MyAwesomePackage tests

release: dist ## package and upload a release
	twine upload dist/*

test: install #@ quickly test package using current python
	pytest

test-all: #@ run tests on every Python version with tox
	tox

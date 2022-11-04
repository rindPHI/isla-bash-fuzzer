#!/usr/bin/env bash

../../fuzzer/fuzz.sh render_rst.py docutils input.rst specs/rest.bnf specs/*.isla

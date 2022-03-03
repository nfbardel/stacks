#!/bin/bash
VERSION=1.0.0

docker build --build-arg VERSION=$VERSION -t "grupoagni/mongo_delphi/7.2" -f Dockerfile .

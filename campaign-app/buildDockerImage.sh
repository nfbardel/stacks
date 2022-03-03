#!/bin/bash
VERSION=2.0.0.delphi
docker build --build-arg VERSION=$VERSION -t "campaign-app/7.2" -f Dockerfile .
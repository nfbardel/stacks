#!/bin/bash
VERSION=2.0.0

docker build --build-arg VERSION=$VERSION -t "php-sidekick/7.2" -f Dockerfile .


#!/bin/bash

podman compose -f compose-podman.yml down
podman compose -f compose-podman.yml up -d

# podman run -it --entrypoint /bin/sh localhost/avey777/ruoqi-v:latest

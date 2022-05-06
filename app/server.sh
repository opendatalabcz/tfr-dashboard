#!/bin/bash

PORT=8080

cd build/web/
echo 'Starting server on port' $PORT
python3 -m http.server $PORT

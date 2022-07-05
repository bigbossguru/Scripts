#!/bin/bash

#######################################
# A script autocreate of the React JS project structure.
# Author: Eldar
# Date: 05.07.2022
#######################################

set -e

echo "Start generate project folder"
echo "-----------------------------"

cd project || mkdir project
cd project || :
npx create-react-app frontend --template typescript

printf "## Frontend\n
[Frontend Manual](frontend/README.md)\n" >> README.md

cd frontend
npm install axios
npm install react-router-dom
touch Dockerfile entrypoint.sh .env .dockerignore

mkdir src/api
mkdir src/components
mkdir src/context
mkdir src/hoc
mkdir src/hooks
mkdir src/layout
mkdir src/pages

echo "-----------------------------"
echo Finished $@

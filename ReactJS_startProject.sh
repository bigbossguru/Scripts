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
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
npm install @reduxjs/toolkit react-redux

printf "/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    \"./src/**/*.{js,jsx,ts,tsx}\",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}" > tailwind.config.js

printf "@tailwind base;
@tailwind components;
@tailwind utilities;" > src/index.css

#touch Dockerfile entrypoint.sh .env .dockerignore

#mkdir src/api
mkdir src/components
mkdir src/store
mkdir src/models
#mkdir src/context
#mkdir src/hoc
mkdir src/hooks
#mkdir src/layout
mkdir src/pages

rm src/App.css
rm src/App.test.tsx
rm src/logo.svg
rm src/reportWebVitals.ts
rm -rf .git

echo "-----------------------------"
echo Finished $@

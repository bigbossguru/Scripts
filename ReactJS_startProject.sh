#!/bin/bash

#######################################
# A script autocreate of the React JS project structure.
# Author: Eldar
# Date: 05.07.2022
#######################################

set -e

echo "-----------------------------"
echo "Start generate project folder"
echo "-----------------------------"
npx create-react-app frontend --template typescript


echo "-----------------------------------------------"
echo "Install all necessary libraries and dependencie"
echo "-----------------------------------------------"
cd frontend
npm install axios
npm install react-router-dom
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
npm install @reduxjs/toolkit react-redux @types/react-redux


echo "-------------------------"
echo "Preparing default folders"
echo "-------------------------"
mkdir src/components
mkdir src/store
mkdir src/models
mkdir src/hooks
mkdir src/pages


echo "------------------------------"
echo "Preparing default boilerplates"
echo "------------------------------"
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

printf "import React from \"react\";
import ReactDOM from \"react-dom/client\";
import \"./index.css\";
import App from \"./App\";
import { store } from \"./store\";
import { BrowserRouter } from \"react-router-dom\";
import { Provider } from \"react-redux\";

const root = ReactDOM.createRoot(
  document.getElementById(\"root\") as HTMLElement
);
root.render(
  <Provider store={store}>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </Provider>
);" > src/index.tsx

printf "import React from \"react\";
import { Route, Routes } from \"react-router-dom\";
import HomePage from \"./pages/HomePage\";

function App() {
  return (
    <>
      <Routes>
        <Route path=\"/\" element={<HomePage />} />
      </Routes>
    </>
  );
}

export default App;" > src/App.tsx

printf "import React from 'react'

export default function HomePage() {
  return (
    <div>HomePage</div>
  )
}" > src/pages/HomePage.tsx

printf "import { configureStore } from \"@reduxjs/toolkit\";


export const store = configureStore({
  reducer: {

  }
});" > src/store/index.ts


echo "------------------------------------"
echo "Removing unnecessary files and dirs"
echo "------------------------------------"
rm src/App.css
rm src/App.test.tsx
rm src/logo.svg
rm src/reportWebVitals.ts
rm -rf .git

echo "------------------------------------"
echo Finished $@
echo "------------------------------------"
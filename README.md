# Installation

    pip install gigasetelements-cli
    npm install
    elm-package install
    
# Usage

    npm run watch

Check the other scripts in `package.json` to see how to run it without developing.

# Packaging

Currently, only the RaspberryPi is supported as a target. Note that building of the application is currently not supported on the Raspberry Pi. You need a different machine for building.

    npm install
    npm run build:pi

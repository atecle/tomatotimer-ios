#!/bin/sh

# Set the -e flag to stop running the script in case a command returns
# a nonzero exit code.
set -e

echo "Installing Tuist...\n"

curl -Ls https://install.tuist.io | bash

echo "Tuist installed. Fetching dependencies..."

cd ..

tuist fetch

echo "Dependencies fetched. Generating workspace..."

tuist generate

exit 0

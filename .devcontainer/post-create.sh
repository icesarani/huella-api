#!/bin/bash

set -e

# Instals ruby dependencies
bundle install

# Creates the db
bundle exec rails db:create
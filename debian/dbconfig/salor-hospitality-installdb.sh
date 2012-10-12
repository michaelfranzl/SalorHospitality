#!/bin/bash

echo "XXX called with $1 and $2"
rake1.9.1 db:migrate
SEED_MODE=minimal rake1.9.1 db:seed
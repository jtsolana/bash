#!/bin/bash
# A simple password generator that display 8 character or more.
# Simply modify the head -c8 to generate the desired number of characters.

PASSWORD=$(date +%s%N | sha256sum | head -c8)
echo "${PASSWORD}"

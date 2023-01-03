#!/bin/bash

#Linux - Kill all processes of deleted files that are still open
 lsof|grep deleted|awk '{print $2}'|xargs kill -9
#!/bin/bash

isql -U${USER} -P${PASS} -S${SERVER} -w200 -Jutf8 -i ${INTERFACE_NAME}/cleanup.sql


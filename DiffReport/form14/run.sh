#!/bin/bash

echo "init_form_13_diff_cn.sql"
isql -Usa -Ppassword -SCPAC -Jutf8 -i init_form_14_diff_data.sql

echo "init_form_13_diff_job_order.sql"
isql -Usa -Ppassword -SCPAC -Jutf8 -i init_form_14_diff_job_order.sql 


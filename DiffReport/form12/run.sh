#!/bin/bash

echo "cleanup.sql"
isql -Usa -Ppassword -SCPAC -Jutf8 -i cleanup.sql

echo "init_form_13_diff_cn.sql"
isql -Usa -Ppassword -SCPAC -Jutf8 -i init_form_13_diff_cn.sql

echo "init_form_13_diff_adj_cn.sql"
isql -Usa -Ppassword -SCPAC -Jutf8 -i init_form_13_diff_adj_cn.sql

echo "init_form_13_diff_adj_receipt.sql"
isql -Usa -Ppassword -SCPAC -Jutf8 -i init_form_13_diff_adj_receipt.sql

echo "init_form_13_diff_receipt.sql"
isql -Usa -Ppassword -SCPAC -Jutf8 -i init_form_13_diff_receipt.sql

echo "init_form_13_diff_adj.sql"
isql -Usa -Ppassword -SCPAC -Jutf8 -i init_form_13_diff_adj.sql


echo "init_form_13_diff_job_order.sql"
isql -Usa -Ppassword -SCPAC -Jutf8 -i init_form_13_diff_job_order.sql 


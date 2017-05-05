#!/bin/bash

cd /test_db-master && "${mysql[@]}" < employees.sql;
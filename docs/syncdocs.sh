#!/bin/sh

aws s3 sync --delete s3://wbkb/docs/ /var/www/ 
python3 /home/ubuntu/make_index.py

#!/bin/sh

# Config
rm -rf conf
# Hook
cp /home/svn/config/hooks/post-commit hooks/post-commit
cp /home/svn/config/hooks/pre-commit hooks/pre-commit
# remove me 
rm -rf start.sh


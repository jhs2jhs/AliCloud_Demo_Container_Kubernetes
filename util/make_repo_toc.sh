#!/bin/bash

# https://github.com/michalbe/md-file-tree

cd ..
md-file-tree > util/repo_toc.md
echo "cehck output in file: util/repo_toc.md"
cd util
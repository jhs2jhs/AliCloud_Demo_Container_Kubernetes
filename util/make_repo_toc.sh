#!/bin/bash

# https://github.com/michalbe/md-file-tree

cd ..
md-file-tree > util/repo_toc_raw.md
cd util
sed 's/AliCloud\_Demo\_Container\_Kubernetes\///g' repo_toc_raw.md > repo_toc_correct_url.md
cat repo_toc_correct_url.md
echo "cehck output in file: util/repo_toc_correct_url.md"

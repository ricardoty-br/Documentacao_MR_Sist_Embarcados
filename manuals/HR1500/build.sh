#!/bin/bash

set -e

echo "========================================="
echo " Gerando documentação HR1500"
echo "========================================="

mkdir -p output

pandoc \
    docs/01-instalacao-ubuntu.md \
    docs/02-conexoes-hr1500.md \
    --metadata-file=metadata.yaml \
    --resource-path=docs \
    --toc \
    --number-sections \
    --pdf-engine=xelatex \
    -o output/Manual_HR1500.pdf

echo
echo "PDF gerado com sucesso:"
echo "output/Manual_HR1500.pdf"

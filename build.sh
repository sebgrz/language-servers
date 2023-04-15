#!/bin/bash

TMP_CSS_DIR=/tmp/css
TMP_CSS_LIB_DIR=$TMP_CSS_DIR"-lib"

if [ $1 = "vscode" ]
then
	echo "vscode build"
	cd vscode
	yarn
	yarn compile

	mkdir $TMP_CSS_DIR
	cp -r extensions/css-language-features/server/out/* $TMP_CSS_DIR

	npm install -g @babel/core@7.21.4 @babel/cli@7.21.0
	npx babel $TMP_CSS_DIR --out-dir $TMP_CSS_LIB_DIR
elif [ $1 = "css-lsp" ]
then
	echo "css language server"
	cp -r $TMP_CSS_LIB_DIR/* css-language-server
	cd css-language-server
	npm install
	npm pack
fi

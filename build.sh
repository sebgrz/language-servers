#!/bin/bash

TMP_CSS_DIR=/tmp/css
TMP_CSS_LIB_DIR=$TMP_CSS_DIR"-lib"
CSS_LSP_DIR=css-language-server
VERSION=0.0.$GITHUB_RUN_NUMBER

CSS_LSP_FILENAME=css-language-server-$VERSION.tgz 

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
	cp -r $TMP_CSS_LIB_DIR/* $CSS_LSP_DIR
	cd $CSS_LSP_DIR
	npm install
elif [ $1 = "prepare-release" ]
then
	cd $CSS_LSP_DIR
	sed s/0.0.1/$VERSION/g -i package.json
	npm pack
elif [ $1 = "release" ]
then
	echo "create release"
	RELEASE_ID=$(curl -L \
		-X POST \
		-H "Accept: application/vnd.github+json" \
		-H "Authorization: Bearer $GITHUB_TOKEN"\
		-H "X-GitHub-Api-Version: 2022-11-28" \
		https://api.github.com/repos/$GITHUB_REPOSITORY/releases \
		-d '{"tag_name":"v'$VERSION'","name":"v'$VERSION'","body":"","generate_release_notes":false}' | jq .id)
	echo "ReleaseID: $RELEASE_ID"

	echo "upload assets"
	curl -L \
		-X POST \
		-H "Accept: application/vnd.github+json" \
		-H "Authorization: Bearer $GITHUB_TOKEN"\
		-H "X-GitHub-Api-Version: 2022-11-28" \
		-H "Content-Type: application/octet-stream" \
		https://uploads.github.com/repos/$GITHUB_REPOSITORY/releases/$RELEASE_ID/assets?name=$CSS_LSP_FILENAME \
		--data-binary "@$CSS_LSP_DIR/$CSS_LSP_FILENAME" > /dev/null
fi


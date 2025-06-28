#!/usr/local/bin/bash

#find ./{docs,overrides,snippets}/ -type f ! -name '*.gif' ! -name '*.png' ! -name '*.jpg' ! -name '*.jpeg' ! -name '*.ico' ! -name '*.svg' ! -name '*.webp' -exec sed -e 's/.$//' -i '' {} \;

find ./{docs,overrides,snippets}/ -type f ! -name '*.gif' ! -name '*.png' ! -name '*.jpg' ! -name '*.jpeg' ! -name '*.ico' ! -name '*.svg' ! -name '*.webp' -exec sed -e 's/[ \t]*$//' -i '' {} \;

find ./{docs,overrides,snippets}/ -type f ! -name '*.gif' ! -name '*.png' ! -name '*.jpg' ! -name '*.jpeg' ! -name '*.ico' ! -name '*.svg' ! -name '*.webp' -exec sed -e '/./,$!d' -i '' {} \;

find ./{docs,overrides,snippets}/ -type f ! -name '*.gif' ! -name '*.png' ! -name '*.jpg' ! -name '*.jpeg' ! -name '*.ico' ! -name '*.svg' ! -name '*.webp' -exec sed -e :a -e '/^\n*$/N;/\n$/ba' -i '' {} \;

find ./{docs,overrides,snippets}/ -type f ! -name '*.gif' ! -name '*.png' ! -name '*.jpg' ! -name '*.jpeg' ! -name '*.ico' ! -name '*.svg' ! -name '*.webp' -exec echo {} \;




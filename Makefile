all: build compile

build:
	npm install

SRC_DIR = ./server.coffee
compile:
	./node_modules/coffee-script/bin/coffee -b -c $(SRC_DIR)
	#coffee -w -b -o $(LIB_DIR) -c $(SRC_DIR)

MAIN_JS = ./server.js
run:
	node $(MAIN_JS)

.PHONY: all build compile run


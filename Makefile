all: install build run

install:
	npm install

TARGET := $(shell find . -type f -name '*.coffee')
build: $(TARGET)
	./node_modules/coffee-script/bin/coffee -b -c $^
	#coffee -w -b -o $(LIB_DIR) -c $(SRC_DIR)

MAIN_JS = ./server.js
run:
	node $(MAIN_JS)

.PHONY: all install build run


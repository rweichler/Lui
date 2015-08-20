BIN=luikit.so

all: $(BIN)

$(BIN):
	gcc -o $@ luikit.m -llua -framework Foundation -dynamiclib

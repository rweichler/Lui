NAME=objc-bindings
BIN=$(NAME).so

all: $(BIN)

$(BIN): $(NAME).m
	gcc -o $@ $< -llua -framework Foundation -dynamiclib

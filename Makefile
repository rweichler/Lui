NAME=objc-bindings
BIN=$(NAME).so

all: $(BIN)

$(BIN): $(NAME).m
	gcc -o $@ $< include/lua/liblua.a -framework Foundation -dynamiclib -Iinclude

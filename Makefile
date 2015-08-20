NAME=objc-bindings
BIN=$(NAME).so
IOS=ios.out


ifeq ("$(PLAT)", "ios")
ARCH=-arch armv7 -arch arm64 -isysroot ~/code/iPhoneOS8.1.sdk
OUT=$(BIN) $(IOS)
else
OUT=$(BIN)
endif

all: $(OUT)

clean:
	rm -f $(BIN) $(IOS)

lua:
	cd include/lua && $(MAKE) clean
	cd include/lua && $(MAKE) PLAT=$(PLAT)

$(BIN): $(NAME).m
	gcc -o $@ $< include/lua/liblua.a $(ARCH) -framework Foundation -dynamiclib -Iinclude

$(IOS): ios_launcher.m
	gcc -o $@ $< -framework Foundation -framework UIKit $(ARCH) -isysroot ~/code/iPhoneOS8.1.sdk -Iinclude include/lua/liblua.a

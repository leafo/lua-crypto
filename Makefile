# Some functions for candiness-looking
err =						\
	@echo -e "\e[1;31m*\e[0m $(1)\e[0m";	\
	@exit 1;
inf =						\
	@echo -e "\e[1;32m*\e[0m $(1)\e[0m";
wrn =						\
	@echo -e "\e[1;33m*\e[0m $(1)\e[0m";
ext =						\
	@echo -e "\e[1;35m*\e[0m $(1)\e[0m";

# LibName and LibVersion
T= crypto
V= 0.3.1

CRYPTO_ENGINE := openssl
# Getting needed variables from OS
UNAME := $(shell uname)
DESTDIR := "/"
LUA_LIBDIR= ${DESTDIR}$(shell pkg-config --variable INSTALL_CMOD lua)
LUA_INC= $(shell pkg-config --variable INSTALL_INC lua)
LUA_VERSION_NUM= ${$(shell pkg-config --variable R lua)//.}


ifeq ($(CRYPTO_ENGINE), openssl)
LUACRYPTO_LIBS= -L$(shell pkg-config --variable libdir openssl) -lcrypto -lssl
LUACRYPTO_INCS= -I$(shell pkg-config --variable includedir openssl) -DCRYPTO_OPENSSL=1
endif
ifeq ($(CRYPTO_ENGINE), gcrypt)
LUACRYPTO_LIBS= $(shell libgcrypt-config --libs)
LUACRYPTO_INCS= $(shell libgcrypt-config --cflags) -DCRYPTO_GCRYPT=1
endif
ifeq ($(UNAME), Linux)
LIB_OPTION= -shared
endif
ifeq ($(UNAME), Darwin)
LIB_OPTION= -bundle -undefined dynamic_lookup
endif

# Compilation directives
WARN= -O2 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings
INCS= -I$(LUA_INC)
CC= gcc


OBJ= src/${T}.o
SRC= src/${T}.c
HDR= src/${T}.h
SYMNAME= ${T}.so
LIBNAME= ${SYMNAME}.${V}
SYMPATH= src/${SYMNAME}
LIBPATH= src/${LIBNAME}

all: ${LIBPATH}

${OBJ}:
	@$(call ext,"Object files compliling in progress...")
	$(CC) $(WARN) $(LUACRYPTO_INCS) $(INCS) $(CFLAGS) $(LDFLAGS) ${LIB_OPTION} -c -o ${OBJ} ${SRC}
	@$(call inf,"Object files compliling is done!")

${LIBPATH}: ${OBJ}
	@$(call ext,"Library compiling and linking...")
	@export MACOSX_DEPLOYMENT_TARGET="10.3";
	$(CC) $(WARN) $(LUACRYPTO_INCS) $(INCS) $(CFLAGS) $(LDFLAGS) ${LIB_OPTION} -o ${LIBPATH} ${OBJ} ${LUACRYPTO_LIBS};
	@ln -s ${LIBNAME} ${SYMPATH}
	@$(call inf,"Library compiling and linking is done!")

install:
	@$(call ext,"Installing...")
	@mkdir -p $(LUA_LIBDIR)
	cp -f ${LIBPATH} ${SYMPATH} $(LUA_LIBDIR)
	@$(call inf,"Installing is done!")

clean:
	@$(call wrn,"Cleaning...")
	rm -f ${LIBPATH} ${SYMPATH} ${OBJ}
	@$(call inf,"Cleaning is done!")

uninstall: clean
	@$(call wrn,"Uninstalling...")
	@cd $(LUA_LIBDIR);
	rm -f ${LIBNAME}
	@$(call inf,"Uninstalling is done!")
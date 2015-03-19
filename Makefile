# file      Makefile
# copyright Copyright (c) 2012 Toradex AG
#           [Software License Agreement]
# author    $Author$
# version   $Rev$
# date      $Date$
# brief     a simple makefile to (cross) compile.
#           uses either a openembedded provided sysroot and toolchain or
#           the rootfs from our binary image with an external cross toolchain.
# target    linux on Colibri T20 / Colibri T30
# caveats   -

##############################################################################
# Setup your project settings
##############################################################################

# Set the input source files, the binary name and used libraries to link
SRCS = gpio-interrupt.c
PROG := gpio-interrupt
LIBS = 

# Set flags to the compiler and linker
CFLAGS = -O0 -g -Wall
LDFLAGS = 

##############################################################################
# Setup your build environment
##############################################################################

# If you have a oe built sysroot with toolchain and target libraries/headers 
# set to 1, 0 otherwise
HAVE_OECORE_SYSROOT = 1

# Set the path to the target libraries resp. the oe built sysroot and
# Set the prefix for the cross compiler
ifeq ($(strip $(HAVE_OECORE_SYSROOT)),0)
  # Rootfs and external toolchain
  OECORE_TARGET_SYSROOT ?= /srv/nfs/rootfs/
  CROSS_COMPILE ?= $(HOME)/bin/arm/bin/arm-none-linux-gnueabi-
else
  # oe sysroot
  OECORE_NATIVE_SYSROOT ?= $(HOME)/oe-core/build/out-eglibc/sysroots/x86_64-linux/
  OECORE_TARGET_SYSROOT ?= $(HOME)/oe-core/build/out-eglibc/sysroots/colibri-t20/
  CROSS_COMPILE ?= $(OECORE_NATIVE_SYSROOT)usr/bin/armv7ahf-vfp-angstrom-linux-gnueabi/arm-angstrom-linux-gnueabi-
endif

##############################################################################
# The rest of the Makefile usually needs no change
##############################################################################

# Set differencies between native and cross compilation
ifneq ($(strip $(CROSS_COMPILE)),)
  LDFLAGS += -L$(OECORE_TARGET_SYSROOT)usr/lib -Wl,-rpath-link,$(OECORE_TARGET_SYSROOT)usr/lib -L$(OECORE_TARGET_SYSROOT)lib -Wl,-rpath-link,$(OECORE_TARGET_SYSROOT)lib
  ARCH_CFLAGS = -march=armv7-a -fno-tree-vectorize -mthumb-interwork -mfloat-abi=softfp -mtune=cortex-a9
  BIN_POSTFIX =
  ifeq ($(strip $(HAVE_OECORE_SYSROOT)),0)
    PKG-CONFIG = pkg-config
    LDFLAGS += -Wl,--allow-shlib-undefined
    # This configuration uses the buildsystems headers, don't emit warnings about that
    ARCH_CFLAGS += -Wno-poison-system-directories
  else
  PKG-CONFIG = export PKG_CONFIG_SYSROOT_DIR=$(OECORE_TARGET_SYSROOT); \
               export PKG_CONFIG_PATH=$(OECORE_TARGET_SYSROOT)/usr/lib/pkgconfig/; \
               $(OECORE_NATIVE_SYSROOT)usr/bin/pkg-config
  endif
else
# Native compile
  PKG-CONFIG = pkg-config
  ARCH_CFLAGS = 
# Append .x86 to the object files and binaries, so that native and cross builds can live side by side
  BIN_POSTFIX = .x86
endif

# Toolchain binaries
CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)gcc
STRIP = $(CROSS_COMPILE)strip
RM = rm -f

# Sets the output filename and object files
PROG := $(PROG)$(BIN_POSTFIX)
OBJS = $(SRCS:.c=$(BIN_POSTFIX).o)
DEPS = $(OBJS:.o=.o.d)

# pull in dependency info for *existing* .o files
-include $(DEPS)

all: $(PROG)

$(PROG): $(OBJS) Makefile
	$(CC) $(CFLAGS) -o $@ $(OBJS) $(LIBS) $(LDFLAGS)
	#$(STRIP) $@ 

%$(BIN_POSTFIX).o: %.c
	$(CC) -c $(CFLAGS) -o $@ $<
	$(CC) -MM $(CFLAGS) $< > $@.d

clean:
	$(RM) $(OBJS) $(PROG) $(DEPS) *.o *.o.d *.x86

.PHONY: all clean

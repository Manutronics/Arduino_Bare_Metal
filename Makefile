# Makefile for compiling Arduino PROJECTes

# Set the path to your Arduino installation
ARDUINO_DIR = C:/Users/<username>/AppData/Local/Arduino15/packages/arduino
AVR_TOOLS_DIR = $(ARDUINO_DIR)/tools/avr-gcc/7.3.0-atmel3.6.1-arduino7
AVRDUDE_DIR = $(ARDUINO_DIR)/tools/avrdude/6.3.0-arduino17

# Board and port settings
PORT = COM15

# Project name
PROJECT = projeto

# Paths
ARDUINO_CORE = $(ARDUINO_DIR)/hardware/avr/1.8.6/cores/arduino
ARDUINO_VARIANT = $(ARDUINO_DIR)/hardware/avr/1.8.6/variants/standard
ARDUINO_LIBRARIES = $(ARDUINO_DIR)/hardware/avr/1.8.6/libraries

# Compiler settings
CC = $(AVR_TOOLS_DIR)/bin/avr-gcc
CXX = $(AVR_TOOLS_DIR)/bin/avr-g++
OBJCOPY = $(AVR_TOOLS_DIR)/bin/avr-objcopy
OBJDUMP = $(AVR_TOOLS_DIR)/bin/avr-objdump
AVRDUDE = $(AVRDUDE_DIR)/bin/avrdude

# Compiler flags
# In order to compile the code, a mcu or target must be privided
CFLAGS = -c -Os -Wall -mmcu=atmega328p -DF_CPU=16000000UL -I$(ARDUINO_VARIANT) -I$(ARDUINO_CORE) 
CXXFLAGS = $(CFLAGS) -fno-exceptions
LDFLAGS = -Os -mmcu=atmega328p -L$(ARDUINO_CORE) -lm #-Wl,--verbose

# Source files
SRCS = $(PROJECT).c
CORE_ASM_SRC = $(wildcard $(ARDUINO_CORE)/*.S)
CORE_C_SRCS = $(wildcard $(ARDUINO_CORE)/*.c)
# CORE_CPP_SRCS = $(filter-out $(ARDUINO_CORE)/main.cpp, $(wildcard $(ARDUINO_CORE)/*.cpp))
CORE_CPP_SRCS = $(wildcard $(ARDUINO_CORE)/*.cpp)

# Object files
OBJS = $(SRCS:.c=.o)
CORE_ASM_OBJ = $(CORE_ASM_SRC:.S=.o)
CORE_C_OBJS = $(CORE_C_SRCS:.c=.o)
CORE_CPP_OBJS = $(CORE_CPP_SRCS:.cpp=.o)
CORE_OBJS = $(CORE_C_OBJS) $(CORE_CPP_OBJS) $(CORE_ASM_OBJ)

# Output files
TARGET = $(PROJECT).elf
HEX = $(PROJECT).hex

OK := $(shell if [ -d $(ARDUINO_DIR) ]; then echo "ok"; fi)

all: check_dir $(HEX)

$(HEX): $(TARGET)
	$(OBJCOPY) -O ihex -R .eeprom $< $@

$(TARGET): $(OBJS) $(CORE_OBJS)
	$(CXX) $(LDFLAGS) -o $@ $^

%.o: %.S
	$(CC) $(CFLAGS) -std=gnu11 $< -o $@

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -std=gnu++17 $< -o $@

%.o: %.c 
	$(CC) $(CFLAGS) -std=gnu11 $< -o $@

upload: $(HEX)
	$(AVRDUDE) -C$(AVRDUDE_DIR)/etc/avrdude.conf -v -p m328p -c arduino -P $(PORT) -b 115200 -D -U flash:w:$(HEX):i

clean:
	rm -f $(OBJS) $(CORE_OBJS) $(TARGET) $(HEX)

check_dir:
ifneq "$(OK)" "ok"
	$(error Folder $(ARDUINO_DIR) does not exist, maybe you forgot to set <username> in ARDUINO_DIR)
endif


.PHONY: all upload clean check_dir
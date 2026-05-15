# Toolchain
CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
SIZE = arm-none-eabi-size

# Target
TARGET = firmware
BUILD_DIR = build
LDSCRIPT = linker/STM32F429ZITX_FLASH.ld

# MCU Configuration
CPU = cortex-m4
FPU = fpv4-sp-d16
FLOAT_ABI = hard

MCU_FLAGS = \
				-mcpu=$(CPU) \
				-mthumb \
				-mfpu=$(FPU) \
				-mfloat-abi=$(FLOAT_ABI)

# Paths
SRC_DIRS = \
					 src \
					 src/app \
					 src/common \
					 src/drivers \
					 src/test

INCLUDE_DIRS =\
							src/app \
							src/common \
							src/drivers \
							src/test \

# Source Discovery
C_SOURCES := $(shell find $(SRC_DIRS) -name '*.c')

# Object generation
OBJECTS = $(patsubst %.c,$(BUILD_DIR)/%.o,$(C_SOURCES))

# Includes
INCLUDES = $(addprefix -I,$(INCLUDE_DIRS))

# Defines
DEFINES = \
					-DSTM32F429xx

# Compiler flags
CFLAGS= \
				$(MCU_FLAGS) \
				$(DEFINES) \
				$(INCLUDES) \
				-std=gnu11 \
				-O0 \
				-g3 \
				-Wall \
				-ffunction-sections \
				-fdata-sections \
				-fstack-usage \
				-MMD -MP

# Linker Flags
LDFLAGS = \
					$(MCU_FLAGS) \
					-T$(LDSCRIPT) \
					--specs=nano.specs \
					--specs=nosys.specs \
					-Wl,-Map=$(BUILD_DIR)/$(TARGET).map \
					-Wl,--gc-sections

LDLIBS = \
				 -lc \
				 -lm

# Build Rules
all : $(BUILD_DIR)/$(TARGET).elf

$(BUILD_DIR)/$(TARGET).elf : $(OBJECTS)
	@mkdir -p $(dir $@)
	$(CC) $(OBJECTS) $(LDFLAGS) $(LDLIBS) -o $@
	$(SIZE) $(BUILD_DIR)/$(TARGET).elf
	
$(BUILD_DIR)/%.o : %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

bin : $(BUILD_DIR)/$(TARGET).elf
	$(OBJCOPY) -O binary $< $(BUILD_DIR)/$(TARGET).bin

hex : $(BUILD_DIR)/$(TARGET).elf
	$(OBJCOPY) -O ihex $< $(BUILD_DIR)/$(TARGET).hex

clean :
	rm -rf $(BUILD_DIR)

# TODO flash

# ============================================================
# PROJECT CONFIGURATION
# ============================================================
PROJECT = firmware
MCU = STM32U575xx

# ============================================================
# DIRECTORIES
# ============================================================
BUILD_DIR = build
SRC_DIR = src
INC_DIR = include
LIB_DIR = lib
STARTUP_DIR = Startup

# Vendor library paths
CMSIS_DIR = $(LIB_DIR)/CMSIS
HAL_DIR = $(LIB_DIR)/STM32U5xx_HAL_Driver
NUCLEO_DIR = $(LIB_DIR)/STM32U5xx_Nucleo

# ============================================================
# TOOLCHAIN
# ============================================================
PREFIX = arm-none-eabi-
CC = $(PREFIX)gcc
AS = $(PREFIX)gcc -x assembler-with-cpp
OBJCOPY = $(PREFIX)objcopy
SIZE = $(PREFIX)size
OBJDUMP = $(PREFIX)objdump

# ============================================================
# MCU CONFIGURATION
# ============================================================
# STM32U575 = Cortex-M33 with FPU
CPU = -mcpu=cortex-m33
FPU = -mfpu=fpv5-sp-d16
FLOAT_ABI = -mfloat-abi=hard
MCU_FLAGS = $(CPU) -mthumb $(FPU) $(FLOAT_ABI)

# ============================================================
# SOURCE FILES
# ============================================================
# Application sources (auto-discover in src subdirectories)
C_SOURCES = \
    $(wildcard $(SRC_DIR)/*.c) \
    $(wildcard $(SRC_DIR)/communication/*.c) \
    $(wildcard $(SRC_DIR)/hal/*.c) \
    $(wildcard $(SRC_DIR)/processing/*.c) \
    $(wildcard $(SRC_DIR)/sensors/*.c) \
    $(wildcard $(SRC_DIR)/system/*.c)

# HAL Driver sources (add specific drivers as needed)
# Start with minimal required drivers, add more as needed
HAL_SOURCES = \
    $(HAL_DIR)/Src/stm32u5xx_hal.c \
    $(HAL_DIR)/Src/stm32u5xx_hal_cortex.c \
    $(HAL_DIR)/Src/stm32u5xx_hal_rcc.c \
    $(HAL_DIR)/Src/stm32u5xx_hal_rcc_ex.c \
    $(HAL_DIR)/Src/stm32u5xx_hal_pwr.c \
    $(HAL_DIR)/Src/stm32u5xx_hal_pwr_ex.c \
    $(HAL_DIR)/Src/stm32u5xx_hal_gpio.c \
    $(HAL_DIR)/Src/stm32u5xx_hal_dma.c \
    $(HAL_DIR)/Src/stm32u5xx_hal_dma_ex.c \
    $(HAL_DIR)/Src/stm32u5xx_hal_flash.c \
    $(HAL_DIR)/Src/stm32u5xx_hal_flash_ex.c

# Nucleo board support (optional - uncomment if using Nucleo board features)
NUCLEO_SOURCES = \
    $(NUCLEO_DIR)/stm32u5xx_nucleo.c

# Combine all vendor sources
VENDOR_SOURCES = $(HAL_SOURCES)
VENDOR_SOURCES += $(NUCLEO_SOURCES)

# Assembly startup file
ASM_SOURCES = $(STARTUP_DIR)/startup_stm32u575zitxq.s

# Combine all sources
ALL_C_SOURCES = $(C_SOURCES) $(VENDOR_SOURCES)

# ============================================================
# INCLUDE PATHS
# ============================================================
# Application includes
INCLUDES = \
    -I$(INC_DIR)

# CMSIS includes
CMSIS_INCLUDES = \
    -I$(CMSIS_DIR)/Include \
    -I$(CMSIS_DIR)/Device/ST/STM32U5xx/Include

# HAL Driver includes
HAL_INCLUDES = \
    -I$(HAL_DIR)/Inc \
    -I$(HAL_DIR)/Inc/Legacy

# Nucleo board includes (uncomment if needed)
NUCLEO_INCLUDES = -I$(NUCLEO_DIR)

# Combine all includes
INCLUDES += $(CMSIS_INCLUDES)
INCLUDES += $(HAL_INCLUDES)
INCLUDES += $(NUCLEO_INCLUDES)

# ============================================================
# DEFINES
# ============================================================
DEFINES = \
    -D$(MCU) \
    -DUSE_HAL_DRIVER

# Optional: Add more defines as needed
# DEFINES += -DUSE_FULL_ASSERT

# ============================================================
# COMPILER FLAGS
# ============================================================
# Warning flags
WARNING_FLAGS = \
    -Wall \
    -Wextra \
    -Wshadow \
    -Wformat=2 \
    -Wdouble-promotion

# Security flags
SECURITY_FLAGS = \
    -fstack-protector-strong \
    -D_FORTIFY_SOURCE=2

# Optimization and code generation
OPT_FLAGS = \
    -O0 \
    -ffunction-sections \
    -fdata-sections

# Dependency generation
DEP_FLAGS = -MMD -MP

# Combined compiler flags
CFLAGS = \
    $(MCU_FLAGS) \
    $(DEFINES) \
    $(INCLUDES) \
    $(OPT_FLAGS) \
    $(WARNING_FLAGS) \
    $(SECURITY_FLAGS) \
    $(DEP_FLAGS)

# Assembly flags
ASFLAGS = $(MCU_FLAGS) -g3

# ============================================================
# LINKER FLAGS
# ============================================================
# Linker script (Flash only)
LDSCRIPT = STM32U575ZITXQ_FLASH.ld

# Linker flags
LDFLAGS = \
    $(MCU_FLAGS) \
    -T$(LDSCRIPT) \
    -specs=nano.specs \
    -specs=nosys.specs \
    -Wl,--gc-sections \
    -Wl,--print-memory-usage \
    -Wl,-Map=$(BUILD_DIR)/$(PROJECT).map \
    -Wl,--cref \
    -static \
    -Wl,--start-group -lc -lm -Wl,--end-group

# Note: 
# - specs=nosys.specs prevents default heap allocation
# - Your sysmem.c and syscalls.c handle memory management

# ============================================================
# BUILD PATHS
# ============================================================
# Generate object file paths (flatten to build directory)
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(ALL_C_SOURCES:.c=.o)))
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))

# Dependency files
DEPS = $(OBJECTS:.o=.d)

# Target binary files
TARGET = $(BUILD_DIR)/$(PROJECT)

# ============================================================
# VPATH (Source file search paths)
# ============================================================
# Application source paths
VPATH = \
    $(SRC_DIR) \
    $(SRC_DIR)/communication \
    $(SRC_DIR)/hal \
    $(SRC_DIR)/processing \
    $(SRC_DIR)/sensors \
    $(SRC_DIR)/system \
    $(STARTUP_DIR)

# Vendor source paths
VPATH += $(HAL_DIR)/Src
VPATH += $(NUCLEO_DIR)

# ============================================================
# PHONY TARGETS
# ============================================================
.PHONY: all clean flash size disasm info help libs

# ============================================================
# DEFAULT TARGET
# ============================================================
all: $(BUILD_DIR) $(TARGET).elf $(TARGET).bin $(TARGET).hex size

# ============================================================
# CREATE BUILD DIRECTORY
# ============================================================
$(BUILD_DIR):
	@mkdir -p $@

# ============================================================
# COMPILATION RULES
# ============================================================
# Compile C sources
$(BUILD_DIR)/%.o: %.c | $(BUILD_DIR)
	@echo "Compiling $(notdir $<)"
	@$(CC) -c $(CFLAGS) $< -o $@

# Assemble startup file
$(BUILD_DIR)/%.o: %.s | $(BUILD_DIR)
	@echo "Assembling $(notdir $<)"
	@$(AS) -c $(ASFLAGS) $< -o $@

# ============================================================
# LINKING
# ============================================================
$(TARGET).elf: $(OBJECTS)
	@echo ""
	@echo "===== Linking $(PROJECT) ====="
	@$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	@echo ""

# ============================================================
# BINARY CONVERSION
# ============================================================
$(TARGET).bin: $(TARGET).elf
	@echo "Creating binary $(notdir $@)"
	@$(OBJCOPY) -O binary $< $@

$(TARGET).hex: $(TARGET).elf
	@echo "Creating hex $(notdir $@)"
	@$(OBJCOPY) -O ihex $< $@

# ============================================================
# UTILITY TARGETS
# ============================================================
# Show memory usage
size: $(TARGET).elf
	@echo ""
	@echo "===== Memory Usage ====="
	@$(SIZE) $<
	@echo ""

# Generate disassembly
disasm: $(TARGET).elf
	@echo "Generating disassembly..."
	@$(OBJDUMP) -D $< > $(BUILD_DIR)/$(PROJECT).dis
	@echo "Disassembly saved to $(BUILD_DIR)/$(PROJECT).dis"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)

# Flash to device (using st-flash)
flash: $(TARGET).bin
	@echo "Flashing to STM32U575..."
	st-flash write $< 0x08000000

# Alternative: Flash using OpenOCD
flash-openocd: $(TARGET).elf
	@echo "Flashing with OpenOCD..."
	openocd -f interface/stlink.cfg -f target/stm32u5x.cfg \
		-c "program $(TARGET).elf verify reset exit"

# List available HAL drivers
libs:
	@echo "===== Available HAL Drivers ====="
	@ls -1 $(HAL_DIR)/Src/*.c | xargs -n1 basename
	@echo ""
	@echo "To add a driver, update HAL_SOURCES in Makefile"

# Project information
info:
	@echo "===== Project Information ====="
	@echo "Project:      $(PROJECT)"
	@echo "MCU:          $(MCU)"
	@echo "Linker:       $(LDSCRIPT)"
	@echo "Build Dir:    $(BUILD_DIR)"
	@echo ""
	@echo "===== Source Statistics ====="
	@echo "Application:  $(words $(C_SOURCES)) C files"
	@echo "HAL Drivers:  $(words $(HAL_SOURCES)) files"
	@echo "Assembly:     $(words $(ASM_SOURCES)) files"
	@echo "Total:        $(words $(OBJECTS)) object files"
	@echo ""
	@echo "===== Compiler Flags ====="
	@echo "MCU:          $(MCU_FLAGS)"
	@echo "Optimization: $(OPT_FLAGS)"
	@echo "Security:     $(SECURITY_FLAGS)"
	@echo "Warnings:     $(WARNING_FLAGS)"
	@echo ""

# Help
help:
	@echo "===== Makefile Targets ====="
	@echo "  make              - Build all (default)"
	@echo "  make clean        - Remove build artifacts"
	@echo "  make flash        - Flash firmware using st-flash"
	@echo "  make flash-openocd- Flash firmware using OpenOCD"
	@echo "  make size         - Show memory usage"
	@echo "  make disasm       - Generate disassembly listing"
	@echo "  make info         - Show project information"
	@echo "  make libs         - List available HAL drivers"
	@echo "  make help         - Show this help"
	@echo ""
	@echo "===== Build Options ====="
	@echo "  DEBUG=1           - Build with debug symbols (no optimization)"
	@echo "  VERBOSE=1         - Show full compiler commands"
	@echo ""
	@echo "===== Examples ====="
	@echo "  make clean all    - Clean and rebuild"
	@echo "  make DEBUG=1      - Debug build"
	@echo "  make VERBOSE=1    - Verbose build"
	@echo ""

# ============================================================
# DEBUG BUILD OPTION
# ============================================================
DEBUG ?= 0
ifeq ($(DEBUG),1)
    OPT_FLAGS = -O0 -g3
    DEFINES += -DDEBUG
    SECURITY_FLAGS =
    $(info *** Debug build enabled ***)
endif

# ============================================================
# VERBOSE BUILD OPTION
# ============================================================
VERBOSE ?= 0
ifneq ($(VERBOSE),1)
    .SILENT:
endif

# ============================================================
# INCLUDE DEPENDENCY FILES
# ============================================================
-include $(DEPS)

# ============================================================
# COLOR OUTPUT (optional - comment out if not desired)
# ============================================================
RED    = \033[0;31m
GREEN  = \033[0;32m
YELLOW = \033[0;33m
BLUE   = \033[0;34m
NC     = \033[0m # No Color

# Override echo for colored output
define print_compile
	@echo "$(GREEN)[CC]$(NC) $(1)"
endef

define print_link
	@echo "$(BLUE)[LD]$(NC) $(1)"
endef

define print_success
	@echo "$(GREEN)✓ $(1)$(NC)"
endef

# ============================================================
# END OF MAKEFILE
# ============================================================ 

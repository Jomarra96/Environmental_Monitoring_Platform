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
# Application (auto-discover in src subdirectories)
C_SOURCES = \
    $(wildcard $(SRC_DIR)/*.c) \
    $(wildcard $(SRC_DIR)/communication/*.c) \
    $(wildcard $(SRC_DIR)/hal/*.c) \
    $(wildcard $(SRC_DIR)/processing/*.c) \
    $(wildcard $(SRC_DIR)/sensors/*.c) \
    $(wildcard $(SRC_DIR)/system/*.c)

# HAL Drivers (add specific drivers as needed)
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

# Nucleo board support (optional)
NUCLEO_SOURCES = \
    $(NUCLEO_DIR)/stm32u5xx_nucleo.c

# Assembly startup file
ASM_SOURCES = $(STARTUP_DIR)/startup_stm32u575zitxq.s

# Combine all sources
ALL_C_SOURCES = $(C_SOURCES) $(NUCLEO_SOURCES) $(HAL_SOURCES)

# ============================================================
# INCLUDE PATHS
# ============================================================
# Application
INCLUDES = \
    -I$(INC_DIR)

# CMSIS
CMSIS_INCLUDES = \
    -I$(CMSIS_DIR)/Include \
    -I$(CMSIS_DIR)/Device/ST/STM32U5xx/Include

# HAL Driver
HAL_INCLUDES = \
    -I$(HAL_DIR)/Inc \
    -I$(HAL_DIR)/Inc/Legacy

# Nucleo board (uncomment if needed)
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

# DEFINES += -DUSE_FULL_ASSERT # Debug build, enables HAL assert

# ============================================================
# COMPILER FLAGS
# ============================================================
# Warning flags
# -Wall              : Common warnings (uninitialized vars, unused, etc.)
# -Wextra            : Additional warnings beyond Wall
# -Wshadow           : Warn when local var shadows another var
# -Wformat=2         : Strict printf/scanf format checking
# -Wdouble-promotion : Warn when float auto-promotes to double (costly on M33!)
# -Wconversion       : Implicit type conversions (catches int/uint bugs)
# -Wundef            : Warn if undefined macro used in #if
# -Wcast-align       : Pointer cast alignment issues (M0/M33 care about this)
# -Wstrict-prototypes: Functions must have prototypes
# -Wmissing-prototypes: Warn if global func has no prior prototype
# -Wredundant-decls  : Redundant declarations
# -Wnull-dereference : Potential null pointer dereference (needs -O1+)
# -Werror=return-type: Error if non-void function missing return
# -Wstack-usage=256  : Warn if function stack exceeds N bytes
# -fno-common        : Error on tentative definitions (catches missing extern)
WARNING_FLAGS = \
    -Wall \
    -Wextra \
    -Wshadow \
    -Wformat=2 \
    -Wdouble-promotion \
    -Wconversion \
    -Wundef \
    -Wcast-align \
    -Wredundant-decls \
    -Wnull-dereference \
    -Werror=return-type \
    -Wstack-usage=256 \
    -fno-common

# Note: Keep these for your code only, if needed. Library code (HAL, CMSIS) may trigger warnings.
# -Wstrict-prototypes: Functions must have prototypes
# -Wmissing-prototypes: Warn if global func has no prior prototype


# Security flags
# -fstack-protector-strong: Stack canaries for buffer overflow protection
#                           Requires __stack_chk_guard and __stack_chk_fail
#                           High overhead - consider disabling for release
SECURITY_FLAGS = \
    -fstack-protector-strong

# Optimization and code generation
# -O0               : No optimization (dev/debugging)
# -ffunction-sections: Each function in own section (enables dead code removal)
# -fdata-sections   : Each variable in own section (enables dead data removal)
OPT_FLAGS = \
    -O0 \
    -ffunction-sections \
    -fdata-sections

# Dependency generation
# -MMD            : Generate .d file with dependencies (excluding system headers)
# -MP             : Add phony targets for headers (avoids errors if header deleted)
# -MF $(@:.o=.d)  : Output to .d file matching .o name
DEP_FLAGS = -MMD -MP -MF $(@:.o=.d)

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
# -g3: Maximum debug info (includes macro definitions)
ASFLAGS = $(MCU_FLAGS) -g3

# ============================================================
# LINKER FLAGS
# ============================================================
# Linker script (memory layout, sections)
LDSCRIPT = STM32U575ZITXQ_FLASH.ld

# Linker flags
# -T$(LDSCRIPT)             : Use this linker script
# -specs=nano.specs         : Use newlib-nano (smaller libc, ~10x smaller printf)
# -specs=nosys.specs        : Stub syscalls (no OS, provides empty _exit, _sbrk, etc.). Prevents heap allocation
# -Wl,--gc-sections         : Remove unused functions/data (works with -ffunction-sections)
# -Wl,--print-memory-usage  : Show RAM/Flash usage after linking
# -Wl,-Map=...              : Generate map file (symbol addresses, sizes)
# -Wl,--cref                : Cross-reference table in map (who calls what)
# -static                   : Static linking (standard for bare-metal)
# -Wl,--start-group ... --end-group : Link libc and libm, resolve circular deps
# -Wl,--wrap=malloc/calloc/realloc/free : Wrap malloc family for custom allocator
#                                         or to trap accidental heap usage
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
    -Wl,--start-group -lc -lm -Wl,--end-group \
    -Wl,--wrap=malloc \
    -Wl,--wrap=calloc \
    -Wl,--wrap=realloc \
    -Wl,--wrap=free

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

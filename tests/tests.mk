# Compile programs for RISCV and generate additional files.
#
# Michael Zimmer (mzimmer@eecs.berkeley.edu)

#VPATH = $(TESTS_DIR)/include $(PROG_SRC_DIR)
VPATH = $(TESTS_DIR)/include:$(PROG_SRC_DIR)

# RISC-V commands.
RISCV_GCC = riscv-gcc -m32
RISCV_OBJDUMP = riscv-objdump --disassemble-all --section=.text --section=.data --section=.bss
RISCV_OBJCOPY = riscv-objcopy
RISCV_SPLIT_DATA = $(RISCV_OBJCOPY) --only-section .data --only-section .bss -O binary
RISCV_SPLIT_INST = $(RISCV_OBJCOPY) --only-section .text -O binary
RISCV_TO_MEM = hexdump -v -e '1/4 "%08X" "\n"'

# Default Options.
RISCV_OLEVEL ?= 2
RISCV_C_OPTS ?= -Wall -O$(RISCV_OLEVEL) -I$(TESTS_DIR)/include
RISCV_S_OPTS ?= -I$(TESTS_DIR)/include
RISCV_LD_OPTS ?= -nostdlib -I$(TESTS_DIR)/include -Xlinker -defsym -Xlinker TEXT_START_ADDR=0x2000000 -Xlinker -defsym -Xlinker DATA_START_ADDR=0x4000000 -T

# TODO: support fpga target

# Default rules for compiling executable.
DEFAULT_RULES = $(eval $(call COMPILE_TEMPLATE,\
				$(PROG),\
				$(C_STARTUP),\
				layout.ld,\
				$(RISCV_GCC) $(RISCV_S_OPTS),\
				$(RISCV_GCC) $(RISCV_C_OPTS),\
				$(RISCV_GCC) $(RISCV_LD_OPTS),\
				))

#
%.inst: %.bin
	$(RISCV_SPLIT_INST) $< $@

#
%.data: %.bin
	$(RISCV_SPLIT_DATA) $< $@

#
%.inst.mem: %.inst
	$(RISCV_TO_MEM) $(@:.mem=) > $@

#
%.data.mem: %.data
	$(RISCV_TO_MEM) $(@:.mem=) > $@

ifdef C
C_STARTUP ?= startup
endif

## 1: Programs
## 2: Object dependencies (shared by all programs)
## 3: Link script
## 4: .S compile command
## 5: .c compile command
## 6: Linker command
## 7: Additional .c line
define COMPILE_TEMPLATE

# Create build directory.
$(PROG_BUILD_DIR):
	mkdir -p $$@

# Compile .S files.
$(PROG_BUILD_DIR)/%.o: %.S | $(PROG_BUILD_DIR)
	$(4) -c $$< -o $$@

# Compile .c files.
$(PROG_BUILD_DIR)/%.o: %.c | $(PROG_BUILD_DIR)
	$(5) -c $$< -o $$@
	$(7)

# Link all files. Generate additional files.
$(1:%=$(PROG_BUILD_DIR)/%.bin): %.bin: $(3) %.o $(2:%=$(PROG_BUILD_DIR)/%.o)
	$(6) $$^ -o $$@
	$(RISCV_OBJDUMP) $$@ > $$(@:.bin=.dump)

endef


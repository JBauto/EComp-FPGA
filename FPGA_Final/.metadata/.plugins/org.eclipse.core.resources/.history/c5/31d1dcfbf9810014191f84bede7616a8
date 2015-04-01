################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include subdir.mk
-include src/subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
ELFSIZE += \
camera_sw_hist.elf.size \

ELFCHECK += \
camera_sw_hist.elf.elfcheck \


# All Target
all: camera_sw_hist.elf secondary-outputs

# Tool invocations
camera_sw_hist.elf: $(OBJS) ../src/lscript.ld $(USER_OBJS)
	@echo Building target: $@
	@echo Invoking: MicroBlaze gcc linker
	mb-gcc -Wl,--no-relax -Wl,-T -Wl,../src/lscript.ld -L../../running_leds/microblaze_0/lib -mxl-barrel-shift -mxl-pattern-compare -mno-xl-soft-div -mcpu=v8.40.a -mno-xl-soft-mul -o"camera_sw_hist.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo Finished building target: $@
	@echo ' '

camera_sw_hist.elf.size: camera_sw_hist.elf
	@echo Invoking: MicroBlaze Print Size
	mb-size camera_sw_hist.elf  |tee "camera_sw_hist.elf.size"
	@echo Finished building: $@
	@echo ' '

camera_sw_hist.elf.elfcheck: camera_sw_hist.elf
	@echo Invoking: Xilinx ELF Check
	elfcheck camera_sw_hist.elf -hw ../../FPGA_hw_platform/system.xml -pe microblaze_0  |tee "camera_sw_hist.elf.elfcheck"
	@echo Finished building: $@
	@echo ' '

# Other Targets
clean:
	-$(RM) $(OBJS)$(C_DEPS)$(EXECUTABLES)$(ELFSIZE)$(ELFCHECK)$(S_UPPER_DEPS) camera_sw_hist.elf
	-@echo ' '

secondary-outputs: $(ELFSIZE) $(ELFCHECK)

.PHONY: all clean dependents
.SECONDARY:

-include ../makefile.targets

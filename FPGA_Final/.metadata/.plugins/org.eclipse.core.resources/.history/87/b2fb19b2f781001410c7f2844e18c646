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
c_running_leds.elf.size \

ELFCHECK += \
c_running_leds.elf.elfcheck \


# All Target
all: c_running_leds.elf secondary-outputs

# Tool invocations
c_running_leds.elf: $(OBJS) ../src/lscript.ld $(USER_OBJS)
	@echo Building target: $@
	@echo Invoking: MicroBlaze gcc linker
	mb-gcc -Wl,--no-relax -Wl,-T -Wl,../src/lscript.ld -L../../running_leds/microblaze_0/lib -mxl-barrel-shift -mxl-pattern-compare -mcpu=v8.40.a -mno-xl-soft-mul -o"c_running_leds.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo Finished building target: $@
	@echo ' '

c_running_leds.elf.size: c_running_leds.elf
	@echo Invoking: MicroBlaze Print Size
	mb-size c_running_leds.elf  |tee "c_running_leds.elf.size"
	@echo Finished building: $@
	@echo ' '

c_running_leds.elf.elfcheck: c_running_leds.elf
	@echo Invoking: Xilinx ELF Check
	elfcheck c_running_leds.elf -hw ../../FPGA_hw_platform/system.xml -pe microblaze_0  |tee "c_running_leds.elf.elfcheck"
	@echo Finished building: $@
	@echo ' '

# Other Targets
clean:
	-$(RM) $(OBJS)$(C_DEPS)$(EXECUTABLES)$(ELFSIZE)$(ELFCHECK)$(S_UPPER_DEPS) c_running_leds.elf
	-@echo ' '

secondary-outputs: $(ELFSIZE) $(ELFCHECK)

.PHONY: all clean dependents
.SECONDARY:

-include ../makefile.targets

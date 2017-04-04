PROJECT=md380

.PHONY:: all clean
all obj/md380.bin:: freertos/.git/HEAD
	@ninja | cat

clean::
	ninja -t clean





#############################################################################
#
#  Documentation
#
#############################################################################
.PHONY:: doc
doc:: doc/stm32f405.pdf
doc/stm32f405.pdf:
	mkdir -p doc
	wget -O $@ -c http://www.st.com/resource/en/datasheet/stm32f405rg.pdf
doc:: doc/stm32f405_Reference_Manual.pdf
doc/stm32f405_Reference_Manual.pdf:
	mkdir -p doc
	wget -O $@ -c http://www.st.com/resource/en/reference_manual/dm00031020.pdf
doc:: doc/stm32f405_Programming_Manual.pdf
doc/stm32f405_Programming_Manual.pdf:
	mkdir -p doc
	wget -O $@ -c http://www.st.com/resource/en/programming_manual/dm00046982.pdf
doc:: doc/STM32Cube_UM1725_HAL_LL_Driver_description.pdf
doc/STM32Cube_UM1725_HAL_LL_Driver_description.pdf:
	mkdir -p doc
	wget -O $@ -c http://www.st.com/resource/en/user_manual/dm00105879.pdf
doc:: doc/STM32Cube_UM1734_USB_Device_Library.pdf
doc/STM32Cube_UM1734_USB_Device_Library.pdf:
	mkdir -p doc
	wget -O $@ -c http://www.st.com/resource/en/user_manual/dm00108129.pdf


#############################################################################
#
#  Freertos
#
#############################################################################

# Woah, the GIT mirror has much faster download times than
# sourceforge's file download. Let's use it:
.PHONY:: getrtos
getrtos: freertos/.git/HEAD
freertos/.git/HEAD:
	git clone --depth 1 https://github.com/cjlano/freertos

# I have a prune target that removes the unneeded things. That way I
# can much faster search with "ag" (or "grep -r") inside freertos/
.PHONY:: prunertos
prunertos:
	rm -rf freertos/FreeRTOS-Plus
	rm -rf freertos/FreeRTOS/Demo/ARM7*
	rm -rf freertos/FreeRTOS/Demo/ARM9*
	rm -rf freertos/FreeRTOS/Demo/AVR*
	rm -rf freertos/FreeRTOS/Demo/CORTEX_A*
	rm -rf freertos/FreeRTOS/Demo/CORTEX_C*
	rm -rf freertos/FreeRTOS/Demo/CORTEX_E*
	rm -rf freertos/FreeRTOS/Demo/CORTEX_K*
	rm -rf freertos/FreeRTOS/Demo/CORTEX_L*
	rm -rf freertos/FreeRTOS/Demo/CORTEX_LPC*
	rm -rf freertos/FreeRTOS/Demo/CORTEX_M0*
	rm -rf freertos/FreeRTOS/Demo/CORTEX_M4F_ATSAM4E_Atmel_Studio
	rm -rf freertos/FreeRTOS/Demo/CORTEX_M4F_CEC1302_Keil_GCC/
	rm -rf freertos/FreeRTOS/Demo/CORTEX_M4F_CEC1302_MikroC/
	rm -rf freertos/FreeRTOS/Demo/CORTEX_M4F_CEC_MEC_17xx_Keil_GCC/
	rm -rf freertos/FreeRTOS/Demo/CORTEX_M4F_Infineon_*
	rm -rf freertos/FreeRTOS/Demo/CORTEX_M4F_M0_LPC43xx_Keil/
	rm -rf freertos/FreeRTOS/Demo/CORTEX_M4F_MSP432_LaunchPad_IAR_CCS_Keil/
	rm -rf freertos/FreeRTOS/Demo/CORTEX_M4_*
	rm -rf freertos/FreeRTOS/Demo/CORTEX_M7*
	rm -rf freertos/FreeRTOS/Demo/CORTEX_MB*
	rm -rf freertos/FreeRTOS/Demo/CORTEX_MPU*
	rm -rf freertos/FreeRTOS/Demo/CORTEX_R*
	rm -rf freertos/FreeRTOS/Demo/CORTEX_STM32F100_Atollic
	rm -rf freertos/FreeRTOS/Demo/CORTEX_STM32F103_IAR/
	rm -rf freertos/FreeRTOS/Demo/CORTEX_STM32F103_Keil/
	rm -rf freertos/FreeRTOS/Demo/CORTEX_STM32L152_Discovery_IAR/
	rm -rf freertos/FreeRTOS/Demo/CORTEX_STM32L152_IAR/
	rm -rf freertos/FreeRTOS/Demo/CORTEX_Sm*
	rm -rf freertos/FreeRTOS/Demo/CORTUS*
	rm -rf freertos/FreeRTOS/Demo/ColdFire*
	rm -rf freertos/FreeRTOS/Demo/Cygnal
	rm -rf freertos/FreeRTOS/Demo/Flshlite
	rm -rf freertos/FreeRTOS/Demo/H8S
	rm -rf freertos/FreeRTOS/Demo/HCS12*
	rm -rf freertos/FreeRTOS/Demo/IA32*
	rm -rf freertos/FreeRTOS/Demo/M*
	rm -rf freertos/FreeRTOS/Demo/MSP*
	rm -rf freertos/FreeRTOS/Demo/NEC*
	rm -rf freertos/FreeRTOS/Demo/Nios*
	rm -rf freertos/FreeRTOS/Demo/PC
	rm -rf freertos/FreeRTOS/Demo/PIC*
	rm -rf freertos/FreeRTOS/Demo/PPC*
	rm -rf freertos/FreeRTOS/Demo/RL78*
	rm -rf freertos/FreeRTOS/Demo/RX*
	rm -rf freertos/FreeRTOS/Demo/SuperH*
	rm -rf freertos/FreeRTOS/Demo/TriCore*
	rm -rf freertos/FreeRTOS/Demo/Unsupported*
	rm -rf freertos/FreeRTOS/Demo/WIN32*
	rm -rf freertos/FreeRTOS/Demo/WizNET*
	rm -rf freertos/FreeRTOS/Demo/Xilinx*
	rm -rf freertos/FreeRTOS/Demo/dsPIC*
	rm -rf freertos/FreeRTOS/Demo/lwIP*
	rm -rf freertos/FreeRTOS/Demo/msp*
	rm -rf freertos/FreeRTOS/Demo/uIP*
	rm -rf freertos/FreeRTOS/Source/portable/BCC
	rm -rf freertos/FreeRTOS/Source/portable/CCS
	rm -rf freertos/FreeRTOS/Source/portable/CodeWarrior
	rm -rf freertos/FreeRTOS/Source/portable/IAR
	rm -rf freertos/FreeRTOS/Source/portable/Keil
	rm -rf freertos/FreeRTOS/Source/portable/MikroC
	rm -rf freertos/FreeRTOS/Source/portable/MPLAB
	rm -rf freertos/FreeRTOS/Source/portable/MSVC-MingW
	rm -rf freertos/FreeRTOS/Source/portable/oWatcom
	rm -rf freertos/FreeRTOS/Source/portable/Paradigm
	rm -rf freertos/FreeRTOS/Source/portable/Renesas
	rm -rf freertos/FreeRTOS/Source/portable/Rowley
	rm -rf freertos/FreeRTOS/Source/portable/RVDS
	rm -rf freertos/FreeRTOS/Source/portable/SDCC
	rm -rf freertos/FreeRTOS/Source/portable/Softune
	rm -rf freertos/FreeRTOS/Source/portable/Tasking
	rm -rf freertos/FreeRTOS/Source/portable/WizC



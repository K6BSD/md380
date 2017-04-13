# @compile: disasm/checksort.py disasm/boot.r

### Setting up the CPU
e asm.arch = arm
e asm.cpu = cortex
e asm.bits = 16

## Setup sections. Radara will normally get sections from ELF
## images, but our boot.bin is a "pure" binary.
S 0x08000000 0x08000000 0x0000c000 0x0000c000 boot  -r-x
s 0x08000000
S 0x10000000 0x10000000 0x00010000 0x00010000 TCRAM mrw
S 0x20000000 0x20000000 0x000f0000 0x000f0000 ram   mrwx
S 0xe0000000 0xe0000000 0x01000000 0x01000000 m4    mrw
S 0x40000000 0x40000000 0x01000000 0x01000000 stm32 mrw

### Setting up the ESIL VM
e esil.stack.addr = 0x20000000
e esil.stack.size = 0x000f0000
aeim

### Misc radare settings
e cfg.fortunes = false
e asm.lines.ret = true
e asm.cmtcol = 55
e asm.maxrefs = 50
e scr.utf8 = 1
e scr.nkey = func
e asm.emustr = true
#e asm.section.sub = true
e bin.baddr = 0x80000000
e io.va = true
#e anal.hasnext = true


### Setup analysis
# Enable "aa*", which needs a symbol named "entry0"
f entry0 @ 0x080056a4
e search.in = io.sections.exec



#############################################################################
#
# Some macros that allow me to format the source code a little bit nicer,
# i.E. not have the definitions stagger around to much.

# Define a functiona AND analyze it:
#   fs symbols              put the new symbol into the "symbols" flagspace
#   f sym.name @ addr       define new flag
#   fs *                    switch back to global flagspace
#   s addr                  seek to addr so that "af" works
#   e anal.a2f=1            switch to anal algorithm that doesn't create "fcn.*" symbols
#   af                      analyze function (so that "pdf" and "f." works)
#   e anal.a2f=0            switch back to normal analyze algorithm
#   s-                      undo seek
(func addr name,fs symbols,f sym.$1 @ $0,fs *,s $0,e anal.a2f=1,af,e anal.a2f=1,s-)

# Define things that reside in data parts of the image
(d4 addr size,Cd 4 $1 @ $0)            # define 4-byte long word
(ds addr len lbl,Cs $1 @ $0,f $2 @ $0) # define string
(dv addr name,f $1 @ $0)               # define variable



#############################################################################
# see core_cm4.h

.(d4 0x08000000 98)

.(func 0x08000188 NVIC_SystemReset)

#############################################################################
# see usbd_dfu_core.c

.(func 0x080001a8 usbd_dfu_Init)
CCa 0x080001b2 STATE_dfuIDLE
CCa 0x080001ba STATUS_OK

.(func 0x080001ce usbd_dfu_DeInit)
CCa 0x080001d4 STATE_dfuIDLE
CCa 0x080001dc STATUS_OK

.(func 0x08000204 usbd_dfu_Setup)
CCa 0x0800020a req.bmRequest
CCa 0x0800020c USB_REQ_TYPE_MASK
CCa 0x08000212 USB_REQ_TYPE_STANDARD
CCa 0x08000216 USB_REQ_TYPE_CLASS
CCa 0x0800021a req.bRequest
f. case.dnload @ 0x8000234
f. case.upload @ 0x800023a
f. case.getstatus @ 0x8000240
f. case.clearstatus @ 0x8000246
f. case.getstate @ 0x800024c
f. case.abort @ 0x8000252
f. case.detach @ 0x8000258
f. case.default @ 0x800025e
CCa 0x08000262 USBD_FAIL
CCa 0x08000266 req.bRequest
f. case.req_get_descriptor @ 0x8000276
f. case.req_get_interface @ 0x800029c
f. case.req_set_interface @ 0x80002a8
CCa 0x0800027e DFU_DESCRIPTOR_TYPE

# XXX quite interesting function, because this function
# XXX decodes the DFU protocol and acts accordingly
.(func 0x080002c2 EP0_TxSent)
CCa 0x080002cc STATE_dfuDNBUSY
CCa 0x080002e4 CMD_GETCOMMANDS
CCa 0x0800030a CMD_SETADDRESSPOINTER
CCa 0x0800036e CMD_ERASE
CCa 0x080003e8 CMD_MD380_ACCESS_CLOCK_MEMORY?
CCa 0x08000412 CMD_MD380_INTERNAL?
f. loc.cmd_md380_programming @ 0x8000444
f. loc.cmd_md380_set_time @ 0x8000494
f. loc.cmd_md380_internal_3 @ 0x80004a8
f. loc.cmd_md380_internal_4 @ 0x80004da
f. loc.cmd_md380_reboot @ 0x800050c
f. loc.cmd_md380_begin_fwupd @ 0x8000520
CCa 0x0800054a Command 0xC4 with wLength 10
CCa 0x0800059e Command 0xB2 with wLength 33
CCa 0x080005e2 Command 0xB3 with wLength 25
CCa 0x0800062e Command 0xD5 with wLength 513
f. loc.ep0txsent.dnbusy @ 0x80007e2
CCa 0x080007e8 STATE_dfuMANIFEST
# Later there is code with command b4

.(func 0x080007f4 EP0_RxReady)
CCa 0x080007f4 USBD_OK

.(func 0x080007f8 DFU_Req_DETACH)
CCa 0x08000802 STATE_dfuIDLE
CCa 0x0800080c STATE_dfuDNLOAD_SYNC
CCa 0x08000816 STATE_dfuDNLOAD_IDLE
CCa 0x08000820 STATE_dfuMANIFEST_SYNC
CCa 0x0800082a STATE_dfuUPLOAD_IDLE
CCa 0x08000832 STATE_dfuIDLE

.(func 0x0800089a DFU_Req_DNLOAD)
CCA 0x0800089c req.wLength
CCa 0x080008a8 STATE_dfuIDLE
CCa 0x080008b2 STATE_dfuDNLOAD_IDLE
CCa 0x080008f8 STATE_dfuDNLOAD_IDLE
CCa 0x08000902 STATE_dfuIDLE
CCa 0x08000912 STATE_dfuMANIFEST_SYNC

.(func 0x08000942 DFU_Req_UPLOAD)
CCa 0x08000958 STATE_dfuIDLE
CCa 0x08000962 STATE_dfuUPLOAD_IDLE
CCa 0x08000984 XXX here it get's interesting
f. loc.upload_1 @ 0x80009b8
f. loc.upload_3 @ 0x8000a90
f. loc.upload_4 @ 0x8000af6
f. loc.upload_5 @ 0x8000b56
f. loc.upload_7 @ 0x8000bb8
f. loc.upload_x32 @ 0x8000c14

# TODO .(dv 0x0004b510 Pointer)
.(d4 0x08000dd4 11)

.(func 0x08000e04 DFU_Req_GETSTATUS)
CCa 0x08000e0a STATE_dfuDNLOAD_SYNC
CCa 0x08000e0e STATE_dfuMANIFEST_SYNC
CCa 0x08000e46 CMD_ERASE

.(d4 0x08000fe8 1)

.(func 0x08000fec DFU_Req_CLEARSTATUS)

.(func 0x08001050 DFU_Req_GETSTATE)

.(d4 0x0800105c 7)

.(func 0x08001078 DFU_Req_ABORT)

.(d4 0x080010dc 1)

.(func 0x080010e0 DFU_LeaveDFUMode)
CCa 0x080010e4 Manifest_complete

.(func 0x08001140 USBD_DFU_GetCfgDesc)

.(func 0x08001148 USBD_DFU_GetUsrStringDesc)

#############################################################################
# see usbd_dfu_mal.c

.(d4 0x0800116c 15)

.(func 0x080011a8 MAL_Init)
CCa 0x080011c6 tMALTab.pMAL_Init

.(func 0x080011d2 MAL_DeInit)
CCa 0x080011f0 tMALTab.pMAL_DeInit

.(func 0x080011fc MAL_Erase)
CCa 0x0800123c tMALTab.pMAL_Erase

.(func 0x08001298 MAL_Read)
CCa 0x080012c2 tMALTab.pMAL_Read

.(func 0x080012ce MAL_GetStatus)
CCa 0x0800134a tMALTab.pMAL_CheckAdd

#############################################################################
# see usbd_req.c

.(func 0x0800132e MAL_CheckAdd)

.(d4 0x0800135c 2)

.(func 0x08001364 USBD_StdDevReq)

.(func 0x080013bc USBD_StdItfReq)

.(func 0x0800140c USBD_StdEPReq)

.(func 0x08001574 USBD_GetDescriptor)
CCa 0x08001582 USB_DESC_TYPE_DEVICE
CCa 0x08001586 USB_DESC_TYPE_CONFIGURATION
CCa 0x0800158a USB_DESC_TYPE_STRING
CCa 0x0800158e USB_DESC_TYPE_DEVICE_QUALIFIER
CCa 0x08001592 USB_DESC_TYPE_OTHER_SPEED_CONFIGURATION
f. loc.getdesc_type @ 0x8001598
f. loc.getdesc_conf @ 0x80015d6
f. loc.getdesc_string @ 0x80015ec
f. loc.getdesc_devqual @ 0x800166a
f. loc.getdesc_other_speedconf @ 0x8001674
f. loc.getdesc_default @ 0x800167e

.(func 0x0800169c USBD_SetAddress)
CCa 0x080016b6 USB_OTG_CONFIGURED

.(func 0x080016f4 USBD_SetConfig)
CCa 0x08001712 USB_OTG_ADDRESSED
CCa 0x08001716 USB_OTG_CONFIGURED

.(func 0x080017b4 USBD_GetConfig)
CCa 0x080017c6 USB_OTG_ADDRESSED
CCa 0x080017ca USB_OTG_CONFIGURED

.(func 0x080017ec USBD_GetStatus)

.(func 0x08001822 USBD_SetFeature)
CCa 0x0800182e USB_FEATURE_REMOTE_WAKEUP
CCa 0x08001848 USB_FEATURE_TEST_MODE

.(d4 0x080018ac 5)

.(func 0x080018c0 USBD_ClrFeature)
CCa 0x080018e2 pdev.dev.class_cb.Setup

.(func 0x080018f4 USBD_ParseSetupRequest)
.(func 0x08001938 USBD_CtlError)
.(func 0x08001954 USBD_GetString)
.(func 0x0800199a USBD_GetLen)

#############################################################################
# see usbd_ioreq.c

.(func 0x080019ae USBD_CtlSendData)
.(func 0x080019d6 USBD_CtlContinueSendData)
.(func 0x080019ec USBD_CtlPrepareRx)
.(func 0x08001a14 USBD_CtlContinueRx)

.(func 0x08001a2a USBD_CtlSendStatus)
CCa 0x08001a30 USB_OTG_EP0_STATUS_IN

.(func 0x08001a4e USBD_CtlReceiveStatus)
CCa 0x08001a54 USB_OTG_EP0_STATUS_OUT

#############################################################################
# no source yet :-(

.(func 0x08001a72 XXX_08001a72)
.(func 0x08001aa0 XXX_08001aa0)
.(func 0x08001af6 XXX_08001af6)
.(func 0x08001b18 XXX_08001b18)
.(func 0x08001b3c XXX_08001b3c)
.(func 0x08001b70 XXX_08001b70)
.(func 0x08001b82 XXX_08001b82)
.(func 0x08001b9c XXX_08001b9c_something_with_CRC)
CCa 0x08001bcc ENABLE
CCa 0x08001bce RCC_AHB1Periph_CRC
CCa 0x08001c08 DISABLE
CCa 0x08001c0a RCC_AHB1Periph_CRC

.(func 0x08001c14 XXX_08001c14)
.(func 0x08001c26 XXX_08001c26)
.(func 0x08001c38 XXX_08001c38)
.(func 0x08001c52 XXX_08001c52)
.(func 0x08001c68 XXX_08001c68)
.(func 0x08001c8c XXX_08001c8c)
.(func 0x08001ce2 XXX_08001ce2)
.(func 0x08001cfc XXX_08001cfc)
.(func 0x08001d1e XXX_08001d1e)
.(func 0x08001d74 XXX_08001d74)
.(func 0x08001d8a XXX_08001d8a)
.(func 0x08001da0 XXX_08001da0)
.(func 0x08001db6 XXX_08001db6)
.(func 0x08001dce XXX_08001dce)
.(func 0x08001dde XXX_08001dde)

#############################################################################
# no source yet :-(

.(d4 0x08001df0 26)

.(func 0x08001e58 FLASH_Unlock)

.(func 0x08001e78 XXX_08001e78)
.(func 0x08001e8a XXX_08001e8a)
.(func 0x08001f3a XXX_08001f3a)
CCa 0x08001f52 clear PSIZE
CCa 0x08001f5e set PSIZE to program x32
CCa 0x08001f6a activate flash programming
CCa 0x08001f7e weird method to clear bit 0 and stop programming

.(func 0x08001f8c FLASH_UnlockOpt)
CCa 0x08001f90 isolate the OPTLOCK bit

.(func 0x08001fa2 FLASH_LockOpt)

.(func 0x08001fb0 rdp_lock)
CCa 0x08001fb0 rdp_lock(0x55) locks the device, rdp_lock(0xAA) unlocks it.

# sym.rdp_lock
CCa 0x08001fd0 set OPTSTRT

.(func 0x08001fc8 rdp_applylock)
CCa 0x08001fc8 After calling rdp_lock(), rdp_applylock() sets the state.

.(func 0x08001fe4 rdp_isnotlocked)
CCa 0x08001fe4 Returns 1 if RDP is not locked.  0 if it is locked.

.(func 0x08001ffa FLASH_GetFlagStatus)
CCa 0x08002000 isolate BSY bit
CCa 0x08002004 FLASH_FLAG_BSY

.(d4 0x08002038 10)
.(func 0x08002060 flash_wait)

#############################################################################
# see usb_dcd.c

.(func 0x08002088 DCD_Init)
.(func 0x0800211e DCD_EP_Close)
.(func 0x08002178 DCD_EP_PrepareRx)
.(func 0x080021be DCD_EP_Tx)
.(func 0x080021fc DCD_EP_Stall)
.(func 0x08002242 DCD_EP_ClrStall)
.(func 0x08002288 DCD_EP_SetAddress)
.(func 0x0800229c DevConnect)
.(func 0x080022b2 DCD_DevDisconnect)

#############################################################################
# see usb_bsp_template.c, usb_bsp.c

.(func 0x080022c8 USB_OTG_BSP_Init)
CCa 0x0800231c ENABLE
CCa 0x0800231e RCC_APB2Periph_SYSCFG
CCa 0x08002326 ENABLE
CCa 0x08002328 RCC_AHB2Periph_OTG_FS
CCa 0x08002308 GPIO_AF_OTG_FS
CCa 0x0800230a Pin PA11
CCa 0x08002312 GPIO_AF_OTG_FS
CCa 0x08002314 Pin PA12

# .(func 0x08003b52 GPIO_PinAFConfig)
# CCa 0x08003b52 r0=io_GPIOx, r1=pinsource, r2=GPIO_AF

.(d4 0x08002330 1)

.(func 0x08002334 USB_OTG_BSP_EnableInterrupt)
CCa 0x0800233e OTG_FS_IRQn
# calls maybe NVIC_Init, see https://www.mikrocontroller.net/topic/274570

.(func 0x0800235e USB_OTG_BSP_uDelay)

.(func 0x08002374 USB_OTG_BSP_mDelay)

#############################################################################
# see usb_bsp_template.c / usbd_core.c

.(func 0x08002384 USBD_Init)
.(func 0x080023c8 USBD_DeInit)
.(func 0x080023cc USBD_SetupStage)
.(func 0x0800241e XXX_0800241e)
.(func 0x080024b2 XXX_080024b2)
.(func 0x0800257e XXX_0800257e)
.(d4 0x0800258c 1)
.(func 0x08002590 XXX_08002590)
.(func 0x080025c0 XXX_080025c0)
.(func 0x080025de XXX_080025de)
.(func 0x080025fa XXX_080025fa)
.(func 0x08002612 USBD_SetCfg)
.(func 0x0800262e USBD_ClrCfg)
.(func 0x0800263e XXX_0800263e)
.(func 0x0800264c XXX_0800264c)
.(func 0x0800265c XXX_0800265c)
.(func 0x0800267c XXX_0800267c)
.(func 0x080026de XXX_080026de)
.(func 0x0800271e XXX_0800271e)
.(func 0x08002748 USB_OTG_SelectCore)
.(func 0x08002822 USB_OTG_CoreInit)
.(func 0x080028d8 USB_OTG_EnableGlobalInt)
.(func 0x080028f0 USB_OTG_DisableGlobalInt)
.(func 0x0800290a XXX_0800290a)
.(func 0x08002950 XXX_08002950)
.(d4 0x08002990 2)
.(func 0x08002998 USB_OTG_SetCurrentMode)
.(func 0x080029ce XXX_080029ce)
.(func 0x080029d8 XXX_080029d8)
.(func 0x080029ec XXX_080029ec)
.(func 0x080029fe XXX_080029fe)
.(func 0x08002a0e USB_OTG_CoreInitDev)
.(func 0x08002b7e XXX_08002b7e)
.(func 0x08002bd6 XXX_08002bd6)
.(func 0x08002c02 XXX_08002c02)
.(func 0x08002c4c USB_OTG_EPDeactivate)
.(func 0x08002cbe USB_OTG_EPStartXfer)
.(func 0x08002e24 USB_OTG_EP0StartXfer)
.(func 0x08002f4a USB_OTG_EPSetStall)
.(func 0x08002f88 USB_OTG_EPClearStall)
.(func 0x08002fc6 XXX_08002fc6)
.(func 0x08002fd4 XXX_08002fd4)
.(func 0x08002fe8 XXX_08002fe8)
.(func 0x08002ff6 USB_OTG_EP0_OutStart)

#############################################################################

.(func 0x08003048 CPU_SR_Save_0)
CCa 0x08003048 store current PRIMASK in r0
CCa 0x0800304c disable IRQ via PRIMASK
.(func 0x08003050 CPU_SR_Restore_)
.(func 0x08003056 XXX_08003056)
.(func 0x08003072 XXX_08003072)
.(func 0x0800307a XXX_0800307a)
.(func 0x08003082 vec.PEND_SV)
f vec.PEND_SV @ 0x08003082
.(d4 0x080030d8 9)
.(func 0x080030fc XXX_080030fc)
.(func 0x08003176 XXX_08003176)
.(func 0x08003202 XXX_08003202)
.(func 0x08003234 XXX_08003234)
.(func 0x08003290 XXX_08003290)
.(d4 0x080032b0 11)

.(func 0x080032dc XXX_080032dc_maybe_init_spi1)
CCa 0x080032e0 ENABLE
CCa 0x080032e2 RCC_APB2Periph_SPI1

.(func 0x0800335e XXX_0800335e)
.(func 0x08003392 XXX_08003392)
.(func 0x080033c6 XXX_080033c6)
.(func 0x08003412 XXX_08003412)
.(func 0x0800355e XXX_0800355e)
.(func 0x080035a4 XXX_080035a4)
.(func 0x080035de XXX_080035de)
.(func 0x080035f0 XXX_080035f0)
.(func 0x08003612 XXX_08003612)  # something with SPI1
.(func 0x0800362e XXX_0800362e)  # something with SPI1
.(func 0x08003646 XXX_08003646)
.(d4 0x08003908 4)
.(func 0x08003918 XXX_08003918)
.(func 0x0800394c XXX_0800394c)
.(func 0x08003998 XXX_08003998)
.(func 0x080039e8 XXX_080039e8)

#############################################################################
# see stm32f4xx_rcc.c

.(func 0x080039f2 RCC_AHB1PeriphClockCmd)
CCa 0x080039f4 r1 is NewState
CCa 0x080039f2 r0 is RCC_AHB1Periph

.(func 0x08003a12 RCC_AHB2PeriphClockCmd)
.(func 0x08003a32 RCC_APB2PeriphClockCmd)
.(d4 0x08003a54 4)

#############################################################################
# see stm32f4xx_crc.c

.(func 0x08003a64 CRC_ResetDR)
CCa 0x08003a66 CRC_CR_RESET

.(func 0x08003a6c CRC_CalcCRC)
.(d4 0x08003a78 2)

#############################################################################
# see stm32f4xx_gpio.c

.(func 0x08003a80 GPIO_Init)
CCa 0x08003a80 r0=io_GPIOx, r1=*GPIO_InitStruct
CCa 0x08003a82 r2 holds pinpos
CCa 0x08003a90 r3 holds pos
CCa 0x08003a94 r4 holds currentpin

.(func 0x08003b26 GPIO_ReadInputDataBit)
CCa 0x08003b26 r0_io_GPIOx, r1 = has pin mask
CCa 0x08003b28 read GPIOx input data register

.(func 0x08003b3c GPIO_SetBits)
CCa 0x08003b3c BSRRL

.(func 0x08003b40 GPIO_ResetBits)
CCa 0x08003b40 BSRRL

.(func 0x08003b44 GPIO_WriteBit)
CCa 0x08003b4a BSRRL
CCa 0x08003b4e BSRRL

.(func 0x08003b52 GPIO_PinAFConfig)
CCa 0x08003b52 r0=io_GPIOx, r1=pinsource, r2=GPIO_AF

.(func 0x08003ba4 XXX_08003ba4_maybe_set_AIRCR)
.(func 0x08003bae XXX_08003bae_maybe_set_IRQ_Priority)
.(d4 0x08003c18 5)
.(func 0x08003c2c XXX_08003c2c)
.(func 0x08003c6c XXX_08003c6c)
.(func 0x08003c88 XXX_08003c88)
.(func 0x08003c8c XXX_08003c8c)
.(func 0x08003c90 XXX_08003c90)
.(func 0x08003ca4 XXX_08003ca4)
.(d4 0x08003d80 3)
.(func 0x08003d8c XXX_08003d8c)
.(func 0x08003de8 otg_fs_int)
.(func 0x08003eba XXX_08003eba)
.(func 0x08003f02 XXX_08003f02)
.(func 0x08003f8a XXX_08003f8a)
.(func 0x0800407e XXX_0800407e)
.(func 0x08004148 XXX_08004148)
.(func 0x08004164 XXX_08004164)
.(func 0x08004202 XXX_08004202)
.(func 0x0800428a XXX_0800428a)
.(func 0x08004344 XXX_08004344)
.(func 0x0800438e XXX_0800438e)
.(func 0x080043aa XXX_080043aa)
.(d4 0x080043c8 2)
.(func 0x080043d0 XXX_080043d0)
.(func 0x080043f0 unk_080043f0)

.(func 0x08004574 XXX_08004574_maybe_init_gpio)
CCa 0x08004578 ENABLE
CCa 0x0800457a RCC_AHB1Periph_GPIOA..E
CCa 0x08004580 ENABLE
CCa 0x08004582 RCC_APB2Periph_SYSCFG
CCa 0x0800458a DISABLE
CCa 0x0800458c RCC_APB2Periph_TIM1

.(func 0x080045e0 XXX_080045e0)
# NOTE: this function doesn't match the schematics: it sets PC3, PC4, PC5, PC13, PC14 to SPI
CCa 0x08004728 GPIO_AF_SPI
CCa 0x08004734 GPIO_AF_SPI
CCa 0x08004740 GPIO_AF_SPI
CCa 0x0800474c GPIO_AF_SPI
CCa 0x08004758 GPIO_AF_SPI
CCa 0x08004764 GPIO_AF_SPI

.(func 0x0800478a XXX_0800478a)
.(func 0x080047ee XXX_080047ee)
.(d4 0x08004970 17)

.(func 0x080049b4 unk_080049b0)
.(func 0x080049ee XXX_080049ee)
.(func 0x08004a08 call_firmware)
CCa 0x08004a0c 1 << 11
CCa 0x08004a18 1 << 9
CCa 0x080044a8 Change this immediate from 0x55 to 0xAA to jailbreak the bootloader.
.(d4 0x08004a6c 10)

.(func 0x08004a94 unk_08004a94)

.(d4 0x08004ae4 1)

# The cipher table has been found with "/x 2edf40b5bdda"
f cipher_table @ 0x08004ae8
Cd 1024 @ 0x08004ae8

.(func 0x08004ee8 unk_08004ee8)
.(func 0x08004ef2 unk_08004ef2)
.(func 0x08004efc unk_08004efc)
.(func 0x08004f10 unk_08004f10)
.(func 0x08005020 unk_08005020)
.(func 0x08005024 unk_08005024)

.(d4 0x08005038 13)

#############################################################################
# see stm32f4xx.c

.(func 0x0800506c SystemInit)
# Enable FPU
CCa 0x0800506e access Coprozessor Access Control Register
CCa 0x08005072 enable CP10 and CP11 coprocessors (FPU)
# Set up PLL
CCa 0x0800507e set HSION
CCa 0x08005088 weird, reset value already 0x00000000
CCa 0x08005092 unset PLLON, CSSON, HSEON
CCa 0x0800509c weird, reset value already 0x24003010
CCa 0x080050a2 unset HSEBYP
CCa 0x080050ac weird, reset value already 0x00000000
CCa 0x080050b0 delay loop
# Set up vector table
CCa 0x080050c2 Vector Table Offset Register
CCa 0x080050da set HSEON
CCa 0x080050e6 check HSERDY
CCa 0x080050fa HSE_STARTUP_TIMEOUT
CCa 0x08005104 RCC_CR & RCC_CR_HSERDY) != RESET
CCa 0x08005114 if (HSEStatus == 0x01)
CCa 0x0800511c set PWREN
CCa 0x08005128 set PWR_CR_VOS

.(func 0x080050cc SetSysClock)
CCa 0x080055e4 set DN (Default NaN)
CCa 0x080055e8 store in FPSCR

.(d4 0x08005198 76)

f vec.NMI @ 0x080054b8
f vec.HARD_FAULT @ 0x080054ba
f vec.MEM_MANAGE @ 0x080054bc
f vec.BUS_FAULT @ 0x080054be
f vec.USAGE_FAULT @ 0x080054c0
f vec.SVCALL @ 0x080054c2
f vec.DEBUG_MONITOR @ 0x080054c4
f vec.SYSTICK @ 0x080054c6

f vec.OTG_FS_WKUP @ 0x080054c8

f vec.OTG_FS @ 0x080054ca
.(d4 0x080054d4 1)

f vec.EXTI3 @ 0x080054d8
f vec.EXTI2 @ 0x080054da
f vec.EXTI1 @ 0x080054dc
f vec.EXTI0 @ 0x080054de
f vec.TIM4_INT @ 0x080054e0
f vec.TIM3_INT @ 0x080054e2
f vec.TIM6_DAC @ 0x080054e4
f vec.TIM7 @ 0x080054e6
f vec.TIM8_UP_TIM13 @ 0x080054e8
f vec.RTC_WKUP @ 0x080054ea

f vec.DMA2_Stream3 @ 0x080054ec
.(ds 0x080054f0 40 str.SPI_Flash_Memory1)
.(ds 0x08005518 40 str.SPI_Flash_Memory2)

.(func 0x08005540 XXX_weird_jumptable)
#e asm.emustr=0
#afvr r1 r1_ptr int
#afvr r4 r4_end int

.(d4 0x08005560 2)

.(d4 0x08005580 2)

.(d4 0x0800558c 11)
f loc.weird_jumptable @ 0x800558c

.(ds 0x080055b8 0x1c str.Radio_USB_Mode)

.(func 0x080055d4 init_fpu)
CCa 0x080055dc access CPACE
CCa 0x080055de enable CP10 and CP11 coprocessors (FPU)

.(ds 0x080055f0 0x14 str.Radio_Config)

.(ds 0x08005608 0x18 str.Radio_Interface)
.(func 0x08005620 main2)

.(func 0x08005636 store_1_in_r0)

.(func 0x0800563a XXX_0800563a)

.(ds 0x08005660 0x14 str.Anytone)
.(ds 0x08005674 0x10 str.AnyRoad)
.(ds 0x08005684 0x10 str.00000000010B)
.(ds 0x08005694 0x10 str.00000000010C)

.(func 0x080056a4 Reset_Handler)
CCa 0x080056a4 this is SystemInit as thumb address
CCa 0x080056a8 this is main as thumb address

.(d4 0x080056ac 5)

.(d4 0x080056ac 5)

.(func 0x080056c0 main)

# 5552: r1 = 2c         
# 5544: r1 = 5574                     # r1 += pc
# 5546: r1 = 558c                     # r1 += 0x18
# 5548: r4 = 54
# 554a: r4 = 55a2                     # r4 += pc
# 555c: r4 = 55b8                     # r4 += 0x16
# 554e: b 555a
# 555a: cmp r1,r4
# 555c: bne 5550
# 5550: r0 = 5590                     # r0 = r1 + 4
# 5552: r2 = 0xffffc56b               # r2 = [r0], this is -14997
# 5554: r1 = 1af7                     # r1 = r2 + r1
# 5556: bl 0x08001af6

# 1af6: r1 = 1000, r0 = 5594          # ldr r1, [r0], 4
# 1afa: cbz (!r1) end
# 1afc: r2 = 10000000, r0 = 5598      # ldr r2, [r0], 4
# 1b00: r3 = 0                        # r2 = r3 << 31
# 1b02: itt mi
# 1b04: ignored
# 1b06: ignored
# 1b08: r2 = 10000000                 # r2 = r3 + r2
# 1b0a: r3 = 0
# 1b0c: r2 = 10000004                 # *r2++ = 0
# 1b10: r1 = 0ffc
# 1b12: bne 1b0a
#       r0 = 55a0?

# The following seems to be wrong :-(
# 5558: r1 = 55a0
# 555a: cmp r1, r4
# 555c: bne 5550
# 5550: r0 = 55a4                     # r0 = r1 + 4
# 5552: r2 = 0xffffc4cf               # r2 = [r0], this is -15153
# 5554: r1 = 1a6f                     # r1 = r2 + r1
# 5556: bl 0x8001a6e?

# 
CCa 0x08001af6 clear 0x10000000-0x10001000 and 0x20000138-0x20001230
CCa 0x0800558c points to 0x08001af6, the function that will interpret this table
CCa 0x08005590 bytes in TCRAM to clear
CCa 0x08005594 start in TCRAM to clear
CCa 0x08005598 bytes in RAM to clear
CCa 0x0800559c start in RAM to clear
CCa 0x080055a0 end of table


f vec.WWDG @ 0x080056f0
f vec.PVD @ 0x080056f4
f vec.TAMP_STAMP @ 0x080056f8
f vec.FLASH @ 0x08005700
f vec.RCC @ 0x08005704
f vec.EXTI4 @ 0x08005718
f vec.DMA1_Stream0 @ 0x0800571c
f vec.DMA1_Stream1 @ 0x08005720
f vec.DMA1_Stream2 @ 0x08005724
f vec.DMA1_Stream3 @ 0x08005728
f vec.DMA1_Stream4 @ 0x0800572c
f vec.DMA1_Stream5 @ 0x08005730
f vec.DMA1_Stream6 @ 0x08005734
f vec.ADC @ 0x08005738
f vec.CAN1_TX @ 0x0800573c
f vec.CAN1_RX0 @ 0x08005740
f vec.CAN1_RX1 @ 0x08005744
f vec.CAN1_SCE @ 0x08005748
f vec.EXTI9_5 @ 0x0800574c
f vec.TIM1_BRK_TIM9 @ 0x08005750
f vec.TIM1_UP_TIM10 @ 0x08005754
f vec.IM1_TRG_COM_TIM11 @ 0x08005758
f vec.TIM1_CC @ 0x0800575c
f vec.TIM2 @ 0x08005760
f vec.I2C1_EV @ 0x0800576c
f vec.I2C1_ER @ 0x08005770
f vec.I2C2_EV @ 0x08005774
f vec.I2C2_ER @ 0x08005778
f vec.SPI1 @ 0x0800577c
f vec.SPI2 @ 0x08005780
f vec.USART1 @ 0x08005784
f vec.USART2 @ 0x08005788
f vec.USART3 @ 0x0800578c
f vec.EXTI5_10 @ 0x08005790
f vec.RTC_ALARM @ 0x08005794
f vec.TIM8_BRK_TIM12 @ 0x0800579c
f vec.TIM8_TRG_COM_TIM14 @ 0x080057a4
f vec.TIM8_CC @ 0x080057a8
f vec.DMA1_Stream7 @ 0x080057ac
f vec.FSMC @ 0x080057b0
f vec.SDIO @ 0x080057b4
f vec.TIM5 @ 0x080057b8
f vec.SPI3 @ 0x080057bc
f vec.UART4 @ 0x080057c0
f vec.UART5 @ 0x080057c4
f vec.DMA2_Stream0 @ 0x080057d0
f vec.DMA2_Stream1 @ 0x080057d4
f vec.DMA2_Stream2 @ 0x080057d8
f vec.DMA2_Stream4 @ 0x080057e0
f vec.ETH @ 0x080057e4
f vec.ETH_WKUP @ 0x080057e8
f vec.CAN2_TX @ 0x080057ec
f vec.CAN2_RX0 @ 0x080057f0
f vec.CAN2_RX1 @ 0x080057f4
f vec.CAN2_SCE @ 0x080057f8
f vec.DMA2_Stream5 @ 0x08005800
f vec.DMA2_Stream6 @ 0x08005804
f vec.DMA2_Stream7 @ 0x08005808
f vec.USART6 @ 0x0800580c
f vec.I2C3_EV @ 0x08005810
f vec.I2C3_ER @ 0x08005814
f vec.OTG_HS_EP1_OUT @ 0x08005818
f vec.OTG_HS_EP1_IN @ 0x0800581c
f vec.OTG_HS_WKUP @ 0x08005820
f vec.OTG_HS @ 0x08005824
f vec.DCMI @ 0x08005828
f vec.CRYP @ 0x0800582c
f vec.HASH_RNG @ 0x08005830
f vec.FPU @ 0x08005834



#############################################################################
#
#  Memory locations
#
#############################################################################

.(dv 0x0800c000 firmware_stack)
.(dv 0x0800c004 firmware_resetvec)
.(dv 0x2000005c DeviceState2)
.(dv 0x20000077 wLength)
.(dv 0x20000114 tMALTab)
.(dv 0x20000724 usbd_dfu_AltSet)
.(dv 0x200011c0 DeviceState1)
.(dv 0x200011dc firmware_entry1)
.(dv 0x200011e0 firmware_entry0)
.(dv 0x200011fc Manifest_State)
.(dv 0x20001200 DeviceStatus)
.(dv 0x20001204 wBlockNum)
.(dv 0x20001208 usbd_dfu_Desc)
.(dv 0x20001210 USBD_default_cfg)
.(dv 0x20001214 USBD_cfg_status)
.(dv 0x20001218 MAL_Buffer)
.(dv 0x2000122c DeviceState3)



#############################################################################
#
#  STM43F4 and Cortex-M4 registers
#
#############################################################################

. cpu.r

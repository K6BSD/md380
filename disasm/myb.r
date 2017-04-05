# Setting the cortex CPU
e asm.cpu = cortex
# TODO Setup two RAM regions
# TODO Emulating memory mapped devices
# TODO ESIL emulation of Thumb2 code
# TODO Force filter search hits aligned to 4 bytes
# TODO Configure sections with iS, S, S=, o.
S 0x08000000 0x08000000 0x0000c000 0x0000c000 boot  -r-x
S 0xe0000000 0xe0000000 0x01000000 0x01000000 m4    mrw
S 0x40000000 0x40000000 0x01000000 0x01000000 stm32 mrw
S 0x20000000 0x20000000 0x00020000 0x00020000 ram   mrw
S 0x10000000 0x10000000 0x00010000 0x00010000 TCRAM mrw
#e asm.section.sub = true

# Generate signures with: ./make_ucos_sigs
# . sig_ucos.r

e cfg.fortunes = false
e asm.lines.ret = true
e asm.cmtcol = 55
e scr.utf8 = 1

# Define a function, optionally analyze it recursively and seek to it
(f_ addr,)
(fr addr,)
(f addr name sz,f $1 $2 @ $0)
(func addr sz name,f sym.$2 $1 @ $0)

# Define a data section and seek to it
(d4 addr size,Cd 4 $1 @ $0)            # define 4-byte long word
(ds addr len lbl,Cs $1 @ $0,f $2 @ $0) # define string
(dv addr name,f $1 @ $0)                # define variable

. cpu.r
f RCC_CR @ 0x40023800
f RCC_PLLCFGR @ 0x40023804
f RCC_CFGR @ 0x40023808
f RCC_CIR @ 0x4002380C
f CPACE @ 0xE000ED88
f AIRCR @ 0xE000ED0C

. bootloader.r

#############################################################################
#
#  Named functions
#
#############################################################################
# Keep names functions near the top, so that they are known when the
# unnamed functions trigger an afr.

.(dv 0x2000005c DeviceState2)
.(dv 0x20000077 wLength)
.(dv 0x20000724 usbd_dfu_AltSet)
.(dv 0x200011c0 DeviceState1)
.(dv 0x200011fc Manifest_State)
.(dv 0x20001200 DeviceStatus)
.(dv 0x20001204 wBlockNum)
.(dv 0x20001218 MAL_Buffer)
.(dv 0x2000122c DeviceState3)

#############################################################################
# see core_cm4.
.(func 0x08000188 30 NVIC_SystemReset)

#############################################################################
# see usbd_dfu_core.c

.(func 0x080001a8 38 usbd_dfu_Init)
CCa 0x080001b2 STATE_dfuIDLE
CCa 0x080001ba STATUS_OK

.(func 0x080001ce 54 usbd_dfu_DeInit)
CCa 0x080001d4 STATE_dfuIDLE
CCa 0x080001dc STATUS_OK

.(func 0x08000204 190 usbd_dfu_Setup)
CCa 0x0800020a req.bmRequest
CCa 0x0800020c USB_REQ_TYPE_MASK
CCa 0x08000212 USB_REQ_TYPE_STANDARD
CCa 0x08000216 USB_REQ_TYPE_CLASS
CCa 0x0800021a req.bRequest
f case.detach @ 0x8000258
f case.upload @ 0x800023a
f case.dnload @ 0x8000234
f case.clearstatus @ 0x8000246
f case.getstatus @ 0x8000240
f case.abort @ 0x8000252
f case.getstate @ 0x800024c
f case.default @ 0x800025e
CCa 0x08000262 USBD_FAIL
CCa 0x08000266 req.bRequest
f case.req_get_descriptor @ 0x8000276
f case.req_get_interface @ 0x800029c
f case.req_set_interface @ 0x80002a8
CCa 0x0800027e DFU_DESCRIPTOR_TYPE

# XXX quite interesting function, because this function
# XXX decodes the DFU protocol and acts accordingly
.(func 0x080002c2 1330 EP0_TxSent)
f loc.ep0txsent.dnbusy @ 0x80007e2
CCa 0x080002cc STATE_dfuDNBUSY
CCa 0x080002e4 CMD_GETCOMMANDS
CCa 0x0800030a CMD_SETADDRESSPOINTER
CCa 0x0800036e CMD_ERASE
CCa 0x080003e8 CMD_MD380_ACCESS_CLOCK_MEMORY?
CCa 0x08000412 CMD_MD380_INTERNAL?
f loc.cmd_md380_programming @ 0x8000444
f loc.cmd_md380_set_time @ 0x8000494
f loc.cmd_md380_internal_3 @ 0x80004a8
f loc.cmd_md380_internal_4 @ 0x80004da
f loc.cmd_md380_reboot @ 0x800050c
f loc.cmd_md380_begin_fwupd @ 0x8000520
CCa 0x0800054a Command 0xC4 with wLength 10
CCa 0x0800059e Command 0xB2 with wLength 33
CCa 0x080005e2 Command 0xB3 with wLength 25
CCa 0x0800062e Command 0xD5 with wLength 513
# Later there is code with command b4
CCa 0x080007e8 STATE_dfuMANIFEST

.(func 0x080007f4 4 EP0_RxReady)
CCa 0x080007f4 USBD_OK

.(func 0x80007f8 162 DFU_Req_DETACH)
CCa 0x08000802 STATE_dfuIDLE
CCa 0x0800080c STATE_dfuDNLOAD_SYNC
CCa 0x08000816 STATE_dfuDNLOAD_IDLE
CCa 0x08000820 STATE_dfuMANIFEST_SYNC
CCa 0x0800082a STATE_dfuUPLOAD_IDLE
CCa 0x08000832 STATE_dfuIDLE

.(func 0x0800089a 168 DFU_Req_DNLOAD)
CCA 0x0800089c req.wLength
CCa 0x080008a8 STATE_dfuIDLE
CCa 0x080008b2 STATE_dfuDNLOAD_IDLE
CCa 0x080008f8 STATE_dfuDNLOAD_IDLE
CCa 0x08000902 STATE_dfuIDLE
CCa 0x08000912 STATE_dfuMANIFEST_SYNC

.(func 0x08000942 1170 DFU_Req_UPLOAD)
CCa 0x08000958 STATE_dfuIDLE
CCa 0x08000962 STATE_dfuUPLOAD_IDLE
CCa 0x08000984 XXX here it get's interesting
f loc.upload_1 @ 0x80009b8
f loc.upload_3 @ 0x8000a90
f loc.upload_4 @ 0x8000af6
f loc.upload_5 @ 0x8000b56
f loc.upload_7 @ 0x8000bb8
f loc.upload_x32 @ 0x8000c14

.(func 0x08000e00 446 DFU_Req_GETSTATUS)
CCa 0x08000e0a STATE_dfuDNLOAD_SYNC
CCa 0x08000e0e STATE_dfuMANIFEST_SYNC
CCa 0x08000e46 CMD_ERASE

.(func 0x08000fec 100 DFU_Req_CLEARSTATUS)

.(func 0x08001050 12 DFU_Req_GETSTATE)

.(func 0x08001078 98 DFU_Req_ABORT)

.(func 0x080010e0 96 DFU_LeaveDFUMode)
CCa 0x080010e4 Manifest_complete

.(func 0x08001140 8 USBD_DFU_GetCfgDesc)

.(func 0x08001148 36 USBD_DFU_GetUsrStringDesc)

#############################################################################
# see usbd_dfu_mal.c

.(func 0x080011a8 42 MAL_Init)
.(dv 0x20000114 tMALTab)
CCa 0x080011c6 tMALTab.pMAL_Init

.(func 0x080011d2 42 MAL_DeInit)
CCa 0x080011f0 tMALTab.pMAL_DeInit

.(func 0x080011fc 76 MAL_Erase)
CCa 0x0800123c tMALTab.pMAL_Erase

.(func 0x08001298 54 MAL_Read)
CCa 0x080012c2 tMALTab.pMAL_Read

.(func 0x080012ce 96 MAL_GetStatus)
CCa 0x0800134a tMALTab.pMAL_CheckAdd

#############################################################################
# see usbd_req.c

.(func 0x08001364 88 USBD_StdDevReq)

.(func 0x080013bc 80 USBD_StdItfReq)

.(func 0x0800132e 20 MAL_CheckAdd)

.(func 0x0800140c 360 USBD_StdEPReq)

.(func 0x08001574 296 USBD_GetDescriptor)
CCa 0x08001582 USB_DESC_TYPE_DEVICE
CCa 0x08001586 USB_DESC_TYPE_CONFIGURATION
CCa 0x0800158a USB_DESC_TYPE_STRING
CCa 0x0800158e USB_DESC_TYPE_DEVICE_QUALIFIER
CCa 0x08001592 USB_DESC_TYPE_OTHER_SPEED_CONFIGURATION
f loc.getdesc_type @ 0x8001598
f loc.getdesc_conf @ 0x80015d6
f loc.getdesc_string @ 0x80015ec
f loc.getdesc_devqual @ 0x800166a
f loc.getdesc_other_speedconf @ 0x8001674
f loc.getdesc_default @ 0x800167e

.(func 0x0800169c 88 USBD_SetAddress)
CCa 0x080016b6 USB_OTG_CONFIGURED

.(func 0x080016f4 192 USBD_SetConfig)
CCa 0x08001712 USB_OTG_ADDRESSED
CCa 0x08001716 USB_OTG_CONFIGURED

.(func 0x080017b4 56 USBD_GetConfig)
CCa 0x080017c6 USB_OTG_ADDRESSED
CCa 0x080017ca USB_OTG_CONFIGURED
.(dv 0x20001210 USBD_default_cfg)

.(func 0x080017ec 54 USBD_GetStatus)
.(dv 0x20001214 USBD_cfg_status)

.(func 0x08001822 136 USBD_SetFeature)
CCa 0x0800182e USB_FEATURE_REMOTE_WAKEUP
CCa 0x08001848 USB_FEATURE_TEST_MODE

.(func 0x080018c0 52 USBD_ClrFeature)
CCa 0x080018e2 pdev.dev.class_cb.Setup

.(func 0x080018f4 68 USBD_ParseSetupRequest)
.(func 0x08001938 28 USBD_CtlError)
.(func 0x08001954 70 USBD_GetString)
.(func 0x0800199a 20 USBD_GetLen)

#############################################################################
# see usbd_ioreq.c

.(func 0x080019ae 40 USBD_CtlSendData)
.(func 0x080019d6 22 USBD_CtlContinueSendData)
.(func 0x080019ec 40 USBD_CtlPrepareRx)
.(func 0x08001a14 22 USBD_CtlContinueRx)

.(func 0x08001a2a 36 USBD_CtlSendStatus)
CCa 0x08001a30 USB_OTG_EP0_STATUS_IN

.(func 0x08001a4e 36 USBD_CtlReceiveStatus)
CCa 0x08001a54 USB_OTG_EP0_STATUS_OUT

#############################################################################
# no source yet :-(

.(func 0x08001a72 46 XXX_08001a72)
.(func 0x08001aa0 85 XXX_08001aa0)
.(func 0x08001af6 34 XXX_08001af6)
.(func 0x08001b18 36 XXX_08001b18)
.(func 0x08001b3c 52 XXX_08001b3c)
.(func 0x08001b70 18 XXX_08001b70)
.(func 0x08001b82 26 XXX_08001b82)
.(func 0x08001b9c 120 XXX_08001b9c)
.(func 0x08001c14 18 XXX_08001c14)
.(func 0x08001c26 18 XXX_08001c26)
.(func 0x08001c38 26 XXX_08001c38)
.(func 0x08001c52 22 XXX_08001c52)
.(func 0x08001c68 36 XXX_08001c68)
.(func 0x08001c8c 86 XXX_08001c8c)
.(func 0x08001ce2 26 XXX_08001ce2)
.(func 0x08001cfc 34 XXX_08001cfc)
.(func 0x08001d1e 86 XXX_08001d1e)
.(func 0x08001d74 22 XXX_08001d74)
.(func 0x08001d8a 22 XXX_08001d8a)
.(func 0x08001da0 22 XXX_08001da0)
.(func 0x08001db6 24 XXX_08001db6)
.(func 0x08001dce 16 XXX_08001dce)
.(func 0x08001dde 16 XXX_08001dde)

#############################################################################
# no source yet :-(

.(func 0x08001e58 32 FLASH_Unlock)
f FLASH_KEYR @ 0x40023c04

.(func 0x08001e78 18 XXX_08001e78)
.(func 0x08001e8a 176 XXX_08001e8a)
.(func 0x08001f3a 82 XXX_08001f3a)
f FLASH_CR @ 0x40023c10
CCa 0x08001f52 clear PSIZE
CCa 0x08001f5e set PSIZE to program x32
CCa 0x08001f6a activate flash programming
CCa 0x08001f7e weird method to clear bit 0 and stop programming

.(func 0x08001f8c 22 FLASH_UnlockOpt)
f FLASH_OPTCR @ 0x40023c14
f FLASH_OPTKEYR @ 0x40023c08
CCa 0x08001f90 isolate the OPTLOCK bit

.(func 0x08001fa2 14 FLASH_LockOpt)

# sym.rdp_lock
f FLASH_OPTCR_RDP @ 0x40023c15
CCa 0x08001fd0 set OPTSTRT

.(func 0x08001ffa 58 FLASH_GetFlagStatus)
f FLASH_SR @ 0x40023c0C
CCa 0x08002000 isolate BSY bit
CCa 0x08002004 FLASH_FLAG_BSY

#############################################################################
# see usb_dcd.c

.(func 0x08002088 150 DCD_Init)
s 0x080021fc

.(func 0x0800211e 90 DCD_EP_Close)
.(func 0x08002178 70 DCD_EP_PrepareRx)
.(func 0x080021be 62 DCD_EP_Tx)
.(func 0x080021fc 70 DCD_EP_Stall)
.(func 0x08002242 70 DCD_EP_ClrStall)
.(func 0x08002288 20 DCD_EP_SetAddress)
.(func 0x0800229c 22 DevConnect)
.(func 0x080022b2 22 DCD_DevDisconnect)
.(func 0x08002374 14 USB_OTG_BSP_mDelay)
.(func 0x08002612 28 USBD_SetCfg)
.(func 0x0800262e 16 USBD_ClrCfg)
.(func 0x08002748 218 USB_OTG_SelectCore)
.(func 0x08002822 182 USB_OTG_CoreInit)
.(func 0x080028d8 24 USB_OTG_EnableGlobalInt)
.(func 0x080028f0 26 USB_OTG_DisableGlobalInt)
.(func 0x08002998 54 USB_OTG_SetCurrentMode)
.(func 0x08002a0e 368 USB_OTG_CoreInitDev)
.(func 0x08002c4c 114 USB_OTG_EPDeactivate)
.(func 0x08002cbe 358 USB_OTG_EPStartXfer)
.(func 0x08002e24 294 USB_OTG_EP0StartXfer)
.(func 0x08002f4a 62 USB_OTG_EPSetStall)
.(func 0x08002f88 52 USB_OTG_EPClearStall)
.(func 0x08002ff6 80 USB_OTG_EP0_OutStart)
.(func 0x08003048 8 CPU_SR_Save_0)
.(func 0x08003050 6 CPU_SR_Restore_)
.(func 0x08003082 86 vec.PEND_SV)
.(func 0x08003de8 210 otg_fs_int)
.(func 0x0800506c 96 SystemInit)
.(func 0x080050cc 202 SetSysClock)
.(func 0x080055d4 26 init_fpu)
.(func 0x08005620 26 main2)
.(func 0x080056a4 8 vec.RESET)
.(func 0x080056c0 16 main0)

#############################################################################
#
#  Vectors
#
#############################################################################
# The vectors are described in the PM chapter 12.2

.(d4 0x08000000 98)
f vec.RESET @ 0x080056a4
f vec.NMI @ 0x080054b8
f vec.HARD_FAULT @ 0x080054ba
f vec.MEM_MANAGE @ 0x080054bc
f vec.BUS_FAULT @ 0x080054be
f vec.USAGE_FAULT @ 0x080054c0
f vec.SVCALL @ 0x080054c2
f vec.DEBUG_MONITOR @ 0x080054c4
f vec.PEND_SV @ 0x08003082
f vec.SYSTICK @ 0x080054c6
f vec.WWDG @ 0x080056f0
f vec.PVD @ 0x080056f4
f vec.TAMP_STAMP @ 0x080056f8
f vec.RTC_WKUP @ 0x080054ea
f vec.FLASH @ 0x08005700
f vec.RCC @ 0x08005704
f vec.EXTI0 @ 0x080054de
f vec.EXTI1 @ 0x080054dc
f vec.EXTI2 @ 0x080054da
f vec.EXTI3 @ 0x080054d8
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
f vec.TIM3_INT @ 0x080054e2
f vec.TIM4_INT @ 0x080054e0
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
f vec.OTG_FS_WKUP @ 0x080054c8
f vec.TIM8_BRK_TIM12 @ 0x0800579c
f vec.TIM8_UP_TIM13 @ 0x080054e8
f vec.TIM8_TRG_COM_TIM14 @ 0x080057a4
f vec.TIM8_CC @ 0x080057a8
f vec.DMA1_Stream7 @ 0x080057ac
f vec.FSMC @ 0x080057b0
f vec.SDIO @ 0x080057b4
f vec.TIM5 @ 0x080057b8
f vec.SPI3 @ 0x080057bc
f vec.UART4 @ 0x080057c0
f vec.UART5 @ 0x080057c4
f vec.TIM6_DAC @ 0x080054e4
f vec.TIM7 @ 0x080054e6
f vec.DMA2_Stream0 @ 0x080057d0
f vec.DMA2_Stream1 @ 0x080057d4
f vec.DMA2_Stream2 @ 0x080057d8
f vec.DMA2_Stream3 @ 0x080054ec
f vec.DMA2_Stream4 @ 0x080057e0
f vec.ETH @ 0x080057e4
f vec.ETH_WKUP @ 0x080057e8
f vec.CAN2_TX @ 0x080057ec
f vec.CAN2_RX0 @ 0x080057f0
f vec.CAN2_RX1 @ 0x080057f4
f vec.CAN2_SCE @ 0x080057f8
f vec.OTG_FS @ 0x080054ca
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
#  Misc data areas
#
#############################################################################

.(d4 0x08000dd4 11)
.(d4 0x08000fe8 1)
.(d4 0x0800105c 7)
.(d4 0x080010dc 1)
.(d4 0x0800116c 15)
.(d4 0x0800135c 2)
.(d4 0x080018ac 5)
.(d4 0x08001df0 26)
.(d4 0x08002330 1)
.(d4 0x08002990 2)
.(d4 0x080030d8 9)
.(d4 0x080032b0 11)
.(d4 0x08003908 4)
.(d4 0x08003a54 4)
.(d4 0x08003a78 2)
.(d4 0x08003c18 5)
.(d4 0x08003d80 3)
.(d4 0x08004970 16)
.(d4 0x08004a6c 10)
.(d4 0x08004ae4 1)
.(d4 0x08005038 13)
.(d4 0x8002038 10)
CCa 0x08003048 store current PRIMASK in r0
CCa 0x0800304c disable IRQ via PRIMASK

# CCa 0x0800506c see stm/system_stm32f4xx.c
# # Enable FPU
# CCa 0x0800506e access Coprozessor Access Control Register
# CCa 0x08005072 enable CP10 and CP11 coprocessors (FPU)
# # Set up PLL
# CCa 0x0800507e set HSION
# CCa 0x08005088 weird, reset value already 0x00000000
# CCa 0x08005092 unset PLLON, CSSON, HSEON
# CCa 0x0800509c weird, reset value already 0x24003010
# CCa 0x080050a2 unset HSEBYP
# CCa 0x080050ac weird, reset value already 0x00000000
# CCa 0x080050b0 delay loop
# # Set up vector table
# f VTOR @ 0xe000ed08
# CCa 0x080050c2 Vector Table Offset Register
# .(d4 0x08005198 76)
# .(d4 0x080054d4 1)
# .(d4 0x080056ac 5)
# .(ds 0x080054f0 40 str.SPI_Flash_Memory1)
# .(ds 0x08005518 40 str.SPI_Flash_Memory2)
# CCa 0x080055dc access CPACE
# CCa 0x080055de enable CP10 and CP11 coprocessors (FPU)
# CCa 0x080055e4 set DN (Default NaN)
# CCa 0x080055e8 store in FPSCR
# #afvs 0 HSEStatus int
# #afvs 4 StartUpCounter qint
# CCa 0x080050da set HSEON
# CCa 0x080050e6 check HSERDY
# CCa 0x080050fa HSE_STARTUP_TIMEOUT
# CCa 0x08005104 RCC_CR & RCC_CR_HSERDY) != RESET
# CCa 0x08005114 if (HSEStatus == 0x01)
# f RCC_RCC_APB1ENR @ 0x40023840
# CCa 0x0800511c set PWREN
# f RCC_RCC_APB1ENR @ 0x40023840
# CCa 0x08005128 set PWR_CR_VOS


# Enable "aa*"
f entry0 @ vec.RESET
aa*

Vp

#include <CPU11.def>
#include <Global.def>
#include <RN_DSP_Cfg.def>
#include <DMA_ParaCfg.def>
#include <GPIO.def>
#include <MarchC.def>
#include <DMA_ALU.def>
#include <ALU.def>
#include <Random.def>
#include <string.def>
#include <init.def>
#include <STA.def>
#include <FMT.def>
#include <FuncTest.def>
#include <FFT.def>

extern _Rs_Multi;

CODE SEGMENT Func_Test_F;


//////////////////////////////////////////////////////////////////////////
//  ��������:
//      CP_Test
//  ��������:
//      ����������������CP���Թ���
//  �������:
//      ��
//  ��������:
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField CP_Test;
    //��ַ��ʼ��
    RD0 = RN_RSP_START;
    RSP = RD0;
    RD0 = RN_Const_StartAddr;
    RA5 = RD0;
    RD0 = PortExt_Addr;
    RA6 = RD0;

    //����DSP����ʱ��
	RD0 = RN_CFG_DSP48M+RN_CFG_FLOW_DIV8;  //Slow = 4MHz
    DSP_FreqDiv = RD0;

    //ʹ��DSP����
    DSP_Enable;
    Pull_Enable;

	//��ȡ��������
    call CKT_GetDW;
    RD2 = RD0;// CP��������
Debug_Reg32 = RD0;
	RF_GetH4(RD0);
	if(RD0_nZero) goto L_CP_Test_End;

	//�������Speed
	RD0 = RD2;
    call Recover_Speed;
    
    //��������ѡ������в���
    RD3 = RD0;  //��2λ�����ٶ�ָʾλ
L_CP_Test_2:
    RD0 = RD2;
    if(RD0_Bit2 == 0) goto L_CP_Test_3;
    call GRAM_Test;
    if(RD0_nZero) goto L_CP_Test_3;
    RD0 = RN_MASK_GRAM_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;

L_CP_Test_3:
    RD0 = RD2;
    if(RD0_Bit3 == 0) goto L_CP_Test_4;
    call XRAM_Test;
    if(RD0_nZero) goto L_CP_Test_4;
    RD0 = RN_MASK_XRAM_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;

L_CP_Test_4:
    RD0 = RD2;
    if(RD0_Bit4 == 0) goto L_CP_Test_5;
    call PRAM_Test;
    if(RD0_nZero) goto L_CP_Test_5;
    RD0 = RN_MASK_PRAM_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;

L_CP_Test_5:
    RD0 = RD2;
    if(RD0_Bit5 == 0) goto L_CP_Test_6;
    call FlowRAM0_Test;
    if(RD0_nZero) goto L_CP_Test_6;
    call FlowRAM1_Test;
    if(RD0_nZero) goto L_CP_Test_6;
    RD0 = RN_MASK_FLOWRAM_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;

L_CP_Test_6:
    RD0 = RD2;
    if(RD0_Bit6 == 0) goto L_CP_Test_7;
    call FFT128RAM0_Test;
    if(RD0_nZero) goto L_CP_Test_7;
	call FFT128RAM1_Test;
    if(RD0_nZero) goto L_CP_Test_7;
    RD0 = RN_MASK_FFTRAM_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;

L_CP_Test_7:
    RD0 = RD2;
    if(RD0_Bit7 == 0) goto L_CP_Test_8;
    call I2SRAM0_Test;
    if(RD0_nZero) goto L_CP_Test_8;
	call I2SRAM1_Test;
    if(RD0_nZero) goto L_CP_Test_8;
    RD0 = RN_MASK_I2SRAM_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;

L_CP_Test_8:
    RD0 = RD2;
    if(RD0_Bit8 == 0) goto L_CP_Test_9;
    call BaseROM_Test;
    if(RD0_nZero) goto L_CP_Test_9;
    RD0 = RN_MASK_BASEROM_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;

L_CP_Test_9:
    RD0 = RD2;
    if(RD0_Bit9 == 0) goto L_CP_Test_10;
    call ConstROM_Test;
    if(RD0_nZero) goto L_CP_Test_10;
    RD0 = RN_MASK_CONSTROM_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;

L_CP_Test_10:
    RD0 = RD2;
    if(RD0_Bit10 == 0) goto L_CP_Test_11;
    call DMA_Trans_Test;
    if(RD0_nZero) goto L_CP_Test_11;
    RD0 = RN_MASK_DMA_TRANS_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;

L_CP_Test_11:
    RD0 = RD2;
    if(RD0_Bit11 == 0) goto L_CP_Test_12;
    call Split_Banks_Test;
    if(RD0_nZero) goto L_CP_Test_12;
    RD0 = RN_MASK_SPLIT_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;

L_CP_Test_12:
    RD0 = RD2;
    if(RD0_Bit12 == 0) goto L_CP_Test_13;
    call STA1_Test;
    if(RD0_nZero) goto L_CP_Test_13;
    RD0 = RN_MASK_STA1_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;

L_CP_Test_13:
    RD0 = RD2;
    if(RD0_Bit13 == 0) goto L_CP_Test_14;
    call STA2_Test;
    if(RD0_nZero) goto L_CP_Test_14;
    RD0 = RN_MASK_STA2_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;

L_CP_Test_14:
    RD0 = RD2;
    if(RD0_Bit14 == 0) goto L_CP_Test_15;
    call STA3_Test;
    if(RD0_nZero) goto L_CP_Test_15;
    RD0 = RN_MASK_STA3_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;

L_CP_Test_15:
    RD0 = RD2;
    if(RD0_Bit15 == 0) goto L_CP_Test_16;
    call FMT_Test;
    if(RD0_nZero) goto L_CP_Test_16;
    RD0 = RN_MASK_FMT_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;

L_CP_Test_16:
    RD0 = RD2;
    if(RD0_Bit16 == 0) goto L_CP_Test_17;
	call ALU_MAC_TEST;
    if(RD0_nZero) goto L_CP_Test_17;
    RD0 = RN_MASK_MAC_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;

L_CP_Test_17:
    RD0 = RD2;
    if(RD0_Bit17 == 0) goto L_CP_Test_18;
    call Add_LMT_Test;
    if(RD0_nZero) goto L_CP_Test_18;
    call Sub_LMT_Test;
    if(RD0_nZero) goto L_CP_Test_18;
    RD0 = RN_MASK_LMT_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;

L_CP_Test_18:
    RD0 = RD2;
    if(RD0_Bit18 == 0) goto L_CP_Test_19;
    call ALU_PATH1_Add_Test;
    if(RD0_nZero) goto L_CP_Test_19;
    call ALU_PATH1_Sub_Test;
    if(RD0_nZero) goto L_CP_Test_19;
    RD0 = RN_MASK_ALU1_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;
    	
L_CP_Test_19:
    RD0 = RD2;
    if(RD0_Bit19 == 0) goto L_CP_Test_20;
    call ALU_PATH2_Add_Test;
    if(RD0_nZero) goto L_CP_Test_20;
    call ALU_PATH2_Sub_Test;
    if(RD0_nZero) goto L_CP_Test_20;
    RD0 = RN_MASK_ALU2_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;
    	
L_CP_Test_20:
    RD0 = RD2;
    if(RD0_Bit20 == 0) goto L_CP_Test_21;
    call IIR_PATH1_Test;
    if(RD0_nZero) goto L_CP_Test_21;
    RD0 = RN_MASK_IIR1_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;

L_CP_Test_21:
    RD0 = RD2;
    if(RD0_Bit21 == 0) goto L_CP_Test_22;
    call IIR_PATH3_Test;
    if(RD0_nZero) goto L_CP_Test_22;
    RD0 = RN_MASK_IIR3_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;

L_CP_Test_22:
    RD0 = RD2;
    if(RD0_Bit22 == 0) goto L_CP_Test_23;
	call FFT_Test;
    if(RD0_nZero) goto L_CP_Test_23;
    RD0 = RN_MASK_FFTS_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;

L_CP_Test_23:
    RD0 = RD2;
    if(RD0_Bit23 == 0) goto L_CP_Test_24;
	call FFT_Fast128_Test;
    if(RD0_nZero) goto L_CP_Test_24;
    RD0 = RN_MASK_FFTF_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;

L_CP_Test_24:
    RD0 = RD2;
    if(RD0_Bit24 == 0) goto L_CP_Test_25;
    call LMS_Test;
    if(RD0_nZero) goto L_CP_Test_25;
    RD0 = RN_MASK_LMSDSP_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;

L_CP_Test_25:
    RD0 = RD2;
    if(RD0_Bit25 == 0) goto L_CP_Test_26;
    call BaseRAM_Test;
    if(RD0_nZero) goto L_CP_Test_26;
    RD0 = RN_MASK_BASERAM_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;

L_CP_Test_26:
    RD0 = RD2;
    if(RD0_Bit26 == 0) goto L_CP_Test_Output;
    call Cache_Test;
    if(RD0_nZero) goto L_CP_Test_Output;
    RD0 = RN_MASK_CACHE_TEST;
    RD3 |= RD0;
RD0 = RD3;
Debug_Reg32 = RD0;

L_CP_Test_Output:
    RD0 = RD3;
    call CKT_PutDW;

L_CP_Test_End:
	RD0 = RD3;
	return_autofield(0);

//L_CP_Test_25:
//    RD0 = RD2;
//    if(RD0_Bit25 == 0) goto L_CP_Test_Output;
//    call GPIO_Test;
//    if(RD0_nZero) goto L_CP_Test_Output;
//    RD0 = RN_MASK_GPIO_TEST;
//    RD3 |= RD0;
//RD0 = RD3;
//Debug_Reg32 = RD0;


//////////////////////////////////////////////////////////////////////////
//  ��������:
//      BaseRAM_Test
//  ��������:
//      ����BaseRAM
//  �������:
//      ��
//  ��������:
//      RD0:0~���� ����~������
//////////////////////////////////////////////////////////////////////////
sub_autofield BaseRAM_Test;
    RD2 = RN_RAM_StarAddr;
    RD3 = RN_RAM_SIZE_TEST;
    call Marchc_NoMMU;
    return_autofield(0);



//////////////////////////////////////////////////////////////////////////
//  ��������:
//      Cache_Test
//  ��������:
//      ����BaseRAM
//  �������:
//      ��
//  ��������:
//      RD0:0~���� ����~������
//////////////////////////////////////////////////////////////////////////
sub_autofield Cache_Test;
    Sel_Cache4Data;
    RD3 = RN_Cache_StartAddr;
    RD4 = RN_Cache_SIZE_TEST;
    call Marchc_Cache;
    Sel_Cache4Inst;
    return_autofield(0);



//////////////////////////////////////////////////////////////////////////
//  ��������:
//      GRAM_Test
//  ��������:
//      ����GRAM
//  �������:
//      ��
//  ��������:
//      RD0:0~���� ����~������
//////////////////////////////////////////////////////////////////////////
sub_autofield GRAM_Test;
    call En_AllGRAM_To_CPU;
    RD2 = RN_GRAM_START;
    RD3 = RN_GRAM_SIZE_TEST;
    call Marchc_NoMMU;
    return_autofield(0);



//////////////////////////////////////////////////////////////////////////
//  ��������:
//      XRAM_Test
//  ��������:
//      ����XRAM
//  �������:
//      ��
//  ��������:
//      RD0:0~���� ����~������
//////////////////////////////////////////////////////////////////////////
sub_autofield XRAM_Test;
    call En_AllXRAM_To_CPU;
    RD2 = RN_XRAM_START;
    RD3 = RN_XRAM_SIZE_TEST;
    call Marchc_NoMMU;
    return_autofield(0);



//////////////////////////////////////////////////////////////////////////
//  ��������:
//      PRAM_Test
//  ��������:
//      ����PRAM
//  �������:
//      ��
//  ��������:
//      RD0:0~���� ����~������
//////////////////////////////////////////////////////////////////////////
sub_autofield PRAM_Test;
    RD2 = RN_PRAM_START;
    RD3 = RN_PRAM_SIZE_TEST;
    call Marchc_NoMMU;
    return_autofield(0);



//////////////////////////////////////////////////////////////////////////
//  ��������:
//      FlowRAM0_Test
//  ��������:
//      ����FlowRAM0
//  �������:
//      ��
//  ��������:
//      RD0:0~���� ����~������
//////////////////////////////////////////////////////////////////////////
sub_autofield FlowRAM0_Test;
    RD0 = FlowRAM_Addr0;
    call En_GRAM_To_CPU;
    RD2 = FlowRAM_Addr0;
    RD3 = RN_FLOWRAM0_SIZE_TEST;
    call Marchc_NoMMU;
    return_autofield(0);


//////////////////////////////////////////////////////////////////////////
//  ��������:
//      FlowRAM1_Test
//  ��������:
//      ����FlowRAM1
//  �������:
//      ��
//  ��������:
//      RD0:0~���� ����~������
//////////////////////////////////////////////////////////////////////////
sub_autofield FlowRAM1_Test;
    RD0 = FlowRAM_Addr1;
    call En_GRAM_To_CPU;
    RD2 = FlowRAM_Addr1;
    RD3 = RN_FLOWRAM1_SIZE_TEST;
    call Marchc_NoMMU;
    return_autofield(0);


//////////////////////////////////////////////////////////////////////////
//  ��������:
//      FFTRAM0_Test
//  ��������:
//      ����FFTRAM0
//  �������:
//      ��
//  ��������:
//      RD0:0~���� ����~������
//////////////////////////////////////////////////////////////////////////
sub_autofield FFT128RAM0_Test;
    RD0 = FFT128RAM_Addr0;
    call En_GRAM_To_CPU;
    RD2 = FFT128RAM_Addr0;
    RD3 = RN_FFTRAM0_SIZE_TEST;
    call Marchc_NoMMU;
    return_autofield(0);


//////////////////////////////////////////////////////////////////////////
//  ��������:
//      FFTRAM1_Test
//  ��������:
//      ����FFTRAM1
//  �������:
//      ��
//  ��������:
//      RD0:0~���� ����~������
//////////////////////////////////////////////////////////////////////////
sub_autofield FFT128RAM1_Test;
    RD0 = FFT128RAM_Addr1;
    call En_GRAM_To_CPU;
    RD2 = FFT128RAM_Addr1;
    RD3 = RN_FFTRAM1_SIZE_TEST;
    call Marchc_NoMMU;
    return_autofield(0);


//////////////////////////////////////////////////////////////////////////
//  ��������:
//      I2SRAM0_Test
//  ��������:
//      ����I2SRAM0
//  �������:
//      ��
//  ��������:
//      RD0:0~���� ����~������
//////////////////////////////////////////////////////////////////////////
sub_autofield I2SRAM0_Test;
    RD0 = I2SRAM_Addr0;
    call En_GRAM_To_CPU;
    RD2 = I2SRAM_Addr0;
    RD3 = RN_I2SRAM0_SIZE_TEST;
    call Marchc_NoMMU;
    return_autofield(0);


//////////////////////////////////////////////////////////////////////////
//  ��������:
//      I2SRAM1_Test
//  ��������:
//      ����I2SRAM1
//  �������:
//      ��
//  ��������:
//      RD0:0~���� ����~������
//////////////////////////////////////////////////////////////////////////
sub_autofield I2SRAM1_Test;
    RD0 = I2SRAM_Addr1;
    call En_GRAM_To_CPU;
    RD2 = I2SRAM_Addr1;
    RD3 = RN_I2SRAM1_SIZE_TEST;
    call Marchc_NoMMU;
    return_autofield(0);



//////////////////////////////////////////////////////////////////////////
//  ��������:
//      BaseROM_Test
//  ��������:
//      ����BaseROM
//  �������:
//      ��
//  ��������:
//      RD0:0~���� ����~������
//////////////////////////////////////////////////////////////////////////
sub_autofield BaseROM_Test;
    // ��_Verify_Sum_16_Reg������ConstROM������Cache
    Sel_Cache4Data;
    RD0 = RN_Cache_StartAddr;
    RA1 = RD0;
L_BaseROM_Test_Loop1:
	RD0 = 0x7A80; M[RA1] = RD0; RA1 += 2;
	RD0 = 0xD8AE; M[RA1] = RD0; RA1 += 2;
	RD0 = 0xC2A6; M[RA1] = RD0; RA1 += 2;
	RD0 = 0x2378; M[RA1] = RD0; RA1 += 2;
	RD0 = 0x3356; M[RA1] = RD0; RA1 += 2;
	RD0 = 0x4334; M[RA1] = RD0; RA1 += 2;
	RD0 = 0x5312; M[RA1] = RD0; RA1 += 2;
	RD0 = 0xC3AC; M[RA1] = RD0; RA1 += 2;
	RD0 = 0x9800; M[RA1] = RD0; RA1 += 2;
	RD0 = 0xC068; M[RA1] = RD0; RA1 += 2;
	RD0 = 0x7002; M[RA1] = RD0; RA1 += 2;
	RD0 = 0xC378; M[RA1] = RD0; RA1 += 2;
	RD0 = 0xE165; M[RA1] = RD0; RA1 += 2;
	RD0 = 0x7FEC; M[RA1] = RD0; RA1 += 2;
	RD0 = 0xFFFA; M[RA1] = RD0; RA1 += 2;
	RD0 = 0xC3A4; M[RA1] = RD0; RA1 += 2;
	RD0 = 0x7880; M[RA1] = RD0; RA1 += 2;
    Sel_Cache4Inst;

    // ��ʽ����BaseROM
    RD1 = RN_ROM_START;
    RD0 = RN_BASEROM_SIZE_TEST/2;
    goto RN_Cache_StartAddr_Program;
    RD1 = RN_BaseROM_Verify_ADDR;
    RA0 = RD1;
    RD1 = M[RA0];
Debug_Reg32 = RD0;
Debug_Reg32 = RD1;
    RD0 ^= RD1;
    return_autofield(0);


//Sub_AutoField _Verify_Sum_16_Reg;
//    //Set_ConstInt_Dis;
//    RA0 = RD1;    //����ָ����ַ
//    RD2 = RD0;    //Length
//
//    RD3 = 0x12345678;
//    RD1 = RD3;
//Verify_Sum_16_Reg_L:
//    RD0 = M[RA0];
//    RD1 += RD0;
//    RA0 += 2;
//    RD3 += RD1;
//    RD2 --;
//    if(RQ_nZero) goto Verify_Sum_16_Reg_L;
//    RD0 = RD3;
//    //Set_ConstInt_En;
//    Return_AutoField(0*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  ��������:
//      ConstROM_Test
//  ��������:
//      ����BaseROM
//  �������:
//      ��
//  ��������:
//      RD0:0~���� ����~������
//////////////////////////////////////////////////////////////////////////
sub_autofield ConstROM_Test;
    RD1 = RN_Const_StartAddr;
    RD0 = RN_CONSTROM_SIZE_TEST;  //���1��Dword���BaseROM_Verify
    call _Verify_Sum_Const32;
    RD1 = 0x3e61450e;
    RD0 ^= RD1;
    return_autofield(0);


//////////////////////////////////////////////////////////////////////////
//  ��������:
//      DMA_Trans_Test
//  ��������:
//      DMA_�������
//  �������:
//      ��
//  ��������:
//      RD0:0~���� ����~������
//////////////////////////////////////////////////////////////////////////
sub_autofield DMA_Trans_Test;
    RD8 = 0x98ac9081;
    // ��ǰ8��GRAMע��α�����
    call En_AllRAM_To_CPU;
    RD0 = RN_GRAM0;
    RD1 = RN_GRAM_BANK_SIZE*8;
//RD1 = 8*MMU_BASE;
    call _RandomGet;

// =================== GRAM[0,1] to AD_Buf[0,1] =====================
    // ��AD_Buf[0,1]������PATH1
    RD0 = FlowRAM_Addr0;
    RA0 = RD0;
    RD0 = 2;
    RD1 = DMA_PATH1;
    call En_RAM_To_PATHx;

    // ��RN_GRAM[0,1]������PATH1
    RD0 = RN_GRAM0;
    RA0 = RD0;
    RD0 = 2;
    RD1 = DMA_PATH1;
    call En_RAM_To_PATHx;

    // GRAM[0,1] ---> AD_Buf[0,1]
    RD0 = RN_GRAM0;
    RA0 = RD0;
    RD0 = FlowRAM_Addr0;
    RA1 = RD0;
    RD0 = 0x2C53a744;// 512*2+4 = 1028
//RD0 = 0x7ff1c71c;// 8*2+4
    call DMA_Trans_PATH1;

    // �ж�AD_Buf0������ȷ��
    call En_AllGRAM_To_CPU;
    call En_AllFlowRAM_To_CPU;
    RD0 = RN_GRAM0;
    RA0 = RD0;
    RD0 = FlowRAM_Addr0;
    RA1 = RD0;
    RD0 = RN_GRAM_BANK_SIZE*2;
//RD0 = 32;
    call memcmp;
//Debug_Reg32 = RD0;
	if(RD0_nZero) goto L_DMA_Trans_Test_Err;
  // ���GRAM[0,1]
// =================== AD_Buf[0,1] to GRAM[0,1] =====================
    // ��AD_Buf[0,1]������PATH1
    RD0 = FlowRAM_Addr0;
    RA0 = RD0;
    RD0 = 2;
    RD1 = DMA_PATH1;
    call En_RAM_To_PATHx;

    // ��RN_GRAM[0,1]������PATH1
    RD0 = RN_GRAM0;
    RA0 = RD0;
    RD0 = 2;
    RD1 = DMA_PATH1;
    call En_RAM_To_PATHx;

    // AD_Buf[0,1] ---> GRAM[0,1]
    RD0 = FlowRAM_Addr0;
    RA0 = RD0;
    RD0 = RN_GRAM0;
    RA1 = RD0;
    RD0 = 0x2C53a744;// 512*2+4 = 1028
//RD0 = 0x7ff1c71c;// 8*2+4
    call DMA_Trans_PATH1;

    // �ж�AD_Buf0������ȷ��
    call En_AllGRAM_To_CPU;
    call En_AllFlowRAM_To_CPU;
    RD0 = RN_GRAM0;
    RA0 = RD0;
    RD0 = FlowRAM_Addr0;
    RA1 = RD0;
    RD0 = RN_GRAM_BANK_SIZE*2;
//RD0 = 32;
    call memcmp;
//Debug_Reg32 = RD0;
	if(RD0_nZero) goto L_DMA_Trans_Test_Err;
// =================== GRAM to GRAM/XRAM =====================
    // ��16��GRAM��8��XRAMȫ��������PATH3
    RD0 = RN_GRAM0;
    RA0 = RD0;
    RD0 = 24;
    RD1 = DMA_PATH1;
    call En_RAM_To_PATHx;

    // GRAM[0,7] ---> GRAM[8,15]
    RD0 = RN_GRAM0;
    RA0 = RD0;
    RD0 = RN_GRAM8;
    RA1 = RD0;
    RD0 = 0x3c0cf006;// 2048*2+4 = 4100
//RD0 = 0x7ff1c71c;// 8*2+4
    call DMA_Trans_PATH1;

    // ��16��GRAM��8��XRAMȫ��������PATH3
    RD0 = RN_GRAM0;
    RA0 = RD0;
    RD0 = 24;
    RD1 = DMA_PATH1;
    call En_RAM_To_PATHx;

    // GRAM[0,7] ---> XRAM[0,7]
    RD0 = RN_GRAM0;
    RA0 = RD0;
    RD0 = RN_XRAM0;
    RA1 = RD0;
    RD0 = 0x3c0cf006;// 2048*2+4 = 4100
//RD0 = 0x7ff1c71c;// 8*2+4
    call DMA_Trans_PATH1;

    // �ж�GRAM������ȷ��
    call En_AllRAM_To_CPU;
    RD0 = RN_GRAM0;
    RA0 = RD0;
    RD0 = RN_GRAM8;
    RA1 = RD0;
    RD0 = RN_GRAM_BANK_SIZE*8;
//RD0 = 32;
    call memcmp;
//Debug_Reg32 = RD0;
	if(RD0_nZero) goto L_DMA_Trans_Test_Err;

    // �ж�XRAM������ȷ��
    call En_AllRAM_To_CPU;
    RD0 = RN_GRAM0;
    RA0 = RD0;
    RD0 = RN_XRAM0;
    RA1 = RD0;
    RD0 = RN_GRAM_BANK_SIZE*8;
//RD0 = 32;
    call memcmp;
//Debug_Reg32 = RD0;
	if(RD0_nZero) goto L_DMA_Trans_Test_Err;
// =================== XRAM to GRAM =====================
    // ����8��GRAM��8��XRAMȫ��������PATH1
    RD0 = RN_GRAM8;
    RA0 = RD0;
    RD0 = 16;
    RD1 = DMA_PATH1;
    call En_RAM_To_PATHx;

    // XRAM[0,7] ---> GRAM[8,15]
    RD0 = RN_XRAM0;
    RA0 = RD0;
    RD0 = RN_GRAM8;
    RA1 = RD0;
    RD0 = 0x3c0cf006;// 2048*2+4 = 4100
//RD0 = 0x7ff1c71c;// 8*2+4
    call DMA_Trans_PATH1;

    call En_AllRAM_To_CPU;

    // �ж�GRAM������ȷ��
    RD0 = RN_GRAM8;
    RA0 = RD0;
    RD0 = RN_XRAM0;
    RA1 = RD0;
    RD0 = RN_GRAM_BANK_SIZE*8;
//RD0 = 32;
    call memcmp;
//Debug_Reg32 = RD0;
	if(RD0_nZero) goto L_DMA_Trans_Test_Err;
// =================== XRAM to XRAM =====================
    // ��8��XRAM������PATH1
    RD0 = RN_XRAM0;
    RA0 = RD0;
    RD0 = 8;
    RD1 = DMA_PATH1;
    call En_RAM_To_PATHx;

    // XRAM[0,3] ---> XRAM[4,7]
    RD0 = RN_XRAM0;
    RA0 = RD0;
    RD0 = RN_XRAM4;
    RA1 = RD0;
    RD0 = 0x62c58b02;//(256*4)*2+4 = 2052
//RD0 = 0x7ff1c71c;// 8*2+4
    call DMA_Trans_PATH1;

    call En_AllRAM_To_CPU;

    // �ж�XRAM������ȷ��
    RD0 = RN_XRAM0;
    RA0 = RD0;
    RD0 = RN_XRAM4;
    RA1 = RD0;
    RD0 = RN_GRAM_BANK_SIZE*4;

//RD0 = 32;
    call memcmp;
//Debug_Reg32 = RD0;
	if(RD0_nZero) goto L_DMA_Trans_Test_Err;

    RD0 = 0;
    return_autofield(0);

L_DMA_Trans_Test_Err:
    RD0 = 1;
    return_autofield(0);

//////////////////////////////////////////////////////////////////////////
//  ��������:
//      Split_Banks_Test
//  ��������:
//      ���Է��Ӵ��˲�����
//  �������:
//      ��
//  ��������:
//      RD0:0~���� ����~������
//////////////////////////////////////////////////////////////////////////
sub_autofield Split_Banks_Test;
    // ��ConstROM����һ��Multi_Sin��Ƶ����GRAM0
    RD0 = RN_GRAM0;
    RA1 = RD0;
    call En_GRAM_To_CPU;
    RD2 = 80;
    RD0 = RN_Multi_Sin_ADDR;
    RA0 = RD0;
L_Split_Banks_Test_Loop1:
    RD0 = M[RA0];
    RA0 += 1;
    M[RA1++] = RD0;
    RD2 --;
    if(RQ_nZero) goto L_Split_Banks_Test_Loop1;

    //��ʼ�� IIR_BANK
    IIR_BANK_Enable;
    MemSetRAM4K_Enable;
    RD0 = RN_SPLIT_8CH_4SEG_ADDR;  //�˲�����ϵ���׵�ַ
    call _IIR_BANK_INIT_8ch_4seg;
    IIR_BANK_Disable;
    IIR_BANK_Enable;
    MemSet_Disable; //Set_All

    // ���Ӵ�
    RD0 = RN_GRAM_START;
    RA0 = RD0;
    RD1 = RN_XRAM_START;
    RA1 = RD1;
    RD2 = 2;
L_Split_Banks_Test_Loop2:
    RD0 = RA0;
    RD1 = RA1;
    call Split_Band_8ch_4seg;
    RA0 += 16*MMU_BASE;
    RA1 += 16*MMU_BASE;
    RD2 --;
    if(RQ_nZero) goto L_Split_Banks_Test_Loop2;

    call En_AllXRAM_To_CPU;
    RD0= RN_SPLIT_RST_ADDR;
    RA0 = RD0;
    RD0 = RN_XRAM0;
    RA1 = RD0;
    RD3 = 8;
L_Split_Banks_Test_Check:
    RD0 = 128;
    call memcmp2;
    if(RD0_nZero) goto L_Split_Banks_Test_Err;
    RD0 = RN_XRAM_BANK_SIZE;
    RA1 += RD0; // ָ����һ��XRAM
    RD0 = 32;
    RA0 += RD0; // ָ����һ�ν��
    RD3 --;
    if(RQ_nZero) goto L_Split_Banks_Test_Check;

    RD0 = 0;
    return_autofield(0);

L_Split_Banks_Test_Err:
    RD0 = 1;
    return_autofield(0);



//===============================
//���ܣ���ʼ��IIR�˲�����
//��ڣ�RD0 :�˲�����ϵ���׵�ַ���洢��ConstROM��
//      �������ã�����Bankѡ�����ۺ����Ȩλ����
//���ڣ���
//===============================
Sub_AutoField _IIR_BANK_INIT_8ch_4seg;
    //����ϵ��
    //�������ã�����Bankѡ�����ۺ����Ȩλ����
    RD1 = RN_SEL_IIRB_ROW0+RN_SEL_IIRB_XB0+RN_SEL_IIRB_CB0+RN_SEL_IIRB_SynSftR0;//ԭʼ��
    //RD1 = RN_SEL_IIRB_ROW0+RN_SEL_IIRB_XB0+RN_SEL_IIRB_CB0+RN_SEL_IIRB_SynSftR2;//�����Ӵ��ۺ��������ʱ�޸�
    IIR_BANK_Sel = RD1;

//bank0  G0_recip = 253   G1_recip = 253
    IIR_BANK_Colum = RN_SEL_IIRB_COL0;
    //RD0 = RN_Const_StartAddr;   //RD0Ϊ���
    call _IIR_BANK_SetHD2;
//bank1 G0_recip = 34   G1_recip = 34
    IIR_BANK_Colum = RN_SEL_IIRB_COL1;
    call _IIR_BANK_SetHD2;
//bank2 G0_recip = 32    G1_recip = 32
    IIR_BANK_Colum = RN_SEL_IIRB_COL2;
    call _IIR_BANK_SetHD2;
//bank3 G0_recip = 33    G1_recip = 33
    IIR_BANK_Colum = RN_SEL_IIRB_COL3;
    call _IIR_BANK_SetHD2;

//bank4 G0_recip = 33    G1_recip = 33
    IIR_BANK_Colum = RN_SEL_IIRB_COL4;
    call _IIR_BANK_SetHD2;
//bank5 G0_recip = 33    G1_recip = 33
    IIR_BANK_Colum = RN_SEL_IIRB_COL5;
    call _IIR_BANK_SetHD2;
//bank6 G0_recip = 33    G1_recip = 33
    IIR_BANK_Colum = RN_SEL_IIRB_COL6;
    call _IIR_BANK_SetHD2;
//bank7 G0_recip = 33    G1_recip = 33
    IIR_BANK_Colum = RN_SEL_IIRB_COL7;
    call _IIR_BANK_SetHD2;

    Return_AutoField(0*MMU_BASE);



//===============================
//���ܣ�����IIR�˲�����ϵ������ͨ
//��ڣ�RD0  ��ǰϵ��ָ��
//���ڣ�RD0  ��һ��ϵ��ָ��
//===============================
Sub_AutoField _IIR_BANK_SetHD2;
    RA0 = RD0;
    RD1 = 20; //_IIR_BANK_SetHD2�ڲ�ѭ��������ÿѭ��д2�μĴ���

L_IIR_BANK_SetHD_Loop:
    RD0 = M[RA0];
    RA0 += 1;
    IIR_BANK_HD = RD0;
    RF_RotateR16(RD0);
    IIR_BANK_HD = RD0;

    RD1 --;
    if(RQ_nZero) goto L_IIR_BANK_SetHD_Loop;

    //�Ĵ�����ַ��λ
    IIR_BANK_CLRADDR;
    RD0 = RA0;
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  ��������:
//      Split_Band
//  ��������:
//      �Ӵ�����
//  ��ڲ���:
//      RD0:��������ָ��
//      RD1:�������ָ��
//  ���ڲ���:
//      ��
////////////////////////////////////////////////////////
sub Split_Band_8ch_4seg;
    push RA0;
    push RA1;

    RA0 = RD0;
    RA1 = RD1;
    RD0 = RN_SEL_IIRB_ROW0+RN_SEL_IIRB_SynSftR0;
    RD1 = 0;  // 8ͨ��
    call _IIR_Sub_Analyze_8ch_4seg;

    pop RA1;
    pop RA0;
    return(0);



//=====================================================================
//���ܣ�8��16���Ӵ������˲�
//��ڣ�RD0��Common������Ϣ
//      ʾ����RD0 = RN_SEL_IIRB_ROW0+RN_SEL_IIRB_SynSftR0;
//      RD1: ͨ����Ŀѡ�� ��0:8ͨ��    !0:16ͨ��
//      RA0���������ݵ�ַ��������XDRAM��ַ�������м���ռ�ã�
//      RA1��Ŀ���ַ��������XDRAM��ַ��8��XDRAM���м���
//˵��: �������洢ӳ�����£�
//                    | XD0 | XD1 | XD2 | XD3 | XD4 | XD5 | XD6 | XD7 |
//            RA1-->  | 0#  | 1#  | 2#  | 3#  | 4#  | 5#  | 6#  | 7#  |
//RA1+FRAME_LEN*4-->  | 8#  | 9#  | 10# | 11# | 12# | 13# | 14# | 15# |
//      �Ӵ�00~07�˲��У�ϵ������CBANK0�����ݲ���XBank0
//      �Ӵ�08~15�˲��У�ϵ������CBANK1�����ݲ���XBank1
//���ڣ���
//=====================================================================
Sub_AutoField _IIR_Sub_Analyze_8ch_4seg;
//0~7ͨ��
    //Ӳ������
    RD2 = RD0;          //�洢Common����
    RD3 = RD1;          //�ݴ�ͨ����Ŀ��־
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH4] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
    M[RA1+MGRP_PATH4] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
    MemSetRAM4K_Enable;  //Set_All
    //IIR_Bankѡ��
    RD0 += RN_SEL_IIRB_CB0+RN_SEL_IIRB_XB0;    //CB0�̶��洢ǰ8���Ӵ���ϵ��
    IIR_BANK_Sel = RD0;   //RD0����ڣ�Bankֵ
IIR_BANK_Colum = RN_SEL_IIRB_COL0T7;// 8ͨ��
//IIR_BANK_Colum = RN_SEL_IIRB_COL0T3;// 4ͨ��
    //RAMͨ������
    RD0 = DMA_PATH4;
    M[RA0] = RD0;
    XDRAM_SetAll_Enable;
    M[RA1] = RD0;      //XD0
    XDRAM_SetAll_Disable;
    MemSet_Disable; //Set_All
    //ǰ8���Ӵ��˲�
    RD0 = RA0;
    send_para(RA0);
    RD0 = RA1;
    send_para(RA1);
    RD0 = FL_M88_A1;// 4��
    //RD0 = FL_M48_A1;// 2��
    send_para(RD0);
    call _DMA_IIRBANK_Analyze;
    //����ͳ��ֵ
//  RD0 = ADDR_SUB_PARA0007;
//  call _Get_IIR_Static;
    return_autoField(0*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  ��������:
//      STA1_Test
//  ��������:
//      ���Ը���������
//  �������:
//      ��
//  ��������:
//      RD0:0~���� ����~������
//////////////////////////////////////////////////////////////////////////
sub_autofield STA1_Test;
    RD0 = RN_XRAM0;
    call En_GRAM_To_CPU;
    RD0 = RN_Multi_Sin_ADDR;
    RA0 = RD0;
    RD0 = RN_XRAM0;
    RA1 = RD0;
    RD0 = 32*4;
    call memcpy2;
    RD0 = RN_XRAM0;
    RD1 = 0x1d89d8a5;// 32*2+4 = 68
    call STA1_Run;
    call STA1_Rst;

    RD2 = 0x56f1c778;
    RD2 ^= RD0;
    if(RQ_nZero) goto L_STA1_Test_Err;
    RD2 = 0x0905f81c;
    RD2 ^= RD1;
    if(RQ_nZero) goto L_STA1_Test_Err;
    RD0 = RD4;
    RD2 = 0x00e47322;
    RD2 ^= RD0;
    if(RQ_nZero) goto L_STA1_Test_Err;

    RD0 = 0;
    return_autoField(0*MMU_BASE);

L_STA1_Test_Err:
    RD0 = 1;
    return_autoField(0*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  ��������:
//      STA2_Test
//  ��������:
//      ���Ը���������
//  �������:
//      ��
//  ��������:
//      RD0:0~���� ����~������
//////////////////////////////////////////////////////////////////////////
sub_autofield STA2_Test;
    RD0 = RN_XRAM0;
    call En_GRAM_To_CPU;
    RD0 = RN_Multi_Sin_ADDR;
    RA0 = RD0;
    RD0 = RN_XRAM0;
    RA1 = RD0;
    RD0 = 32*4;
    call memcpy2;
    RD0 = RN_XRAM0;
    RD1 = 0x1d89d8a5;// 32*2+4 = 68
    call STA2_Run;
    call STA2_Rst;

    RD2 = 0x56f1ffdd;
    RD2 ^= RD0;
    if(RQ_nZero) goto L_STA2_Test_Err;
    RD2 = 0x0905f81c;
    RD2 ^= RD1;
    if(RQ_nZero) goto L_STA2_Test_Err;
    RD0 = RD4;
    RD2 = 0x00e47322;
    RD2 ^= RD0;
    if(RQ_nZero) goto L_STA2_Test_Err;

    RD0 = 0;
    return_autoField(0*MMU_BASE);

L_STA2_Test_Err:
    RD0 = 1;
    return_autoField(0*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  ��������:
//      STA3_Test
//  ��������:
//      ���Ը���������
//  �������:
//      ��
//  ��������:
//      RD0:0~���� ����~������
//////////////////////////////////////////////////////////////////////////
sub_autofield STA3_Test;
    RD0 = RN_XRAM0;
    call En_GRAM_To_CPU;
    RD0 = RN_Multi_Sin_ADDR;
    RA0 = RD0;
    RD0 = RN_XRAM0;
    RA1 = RD0;
    RD0 = 32*4;
    call memcpy2;
    RD0 = RN_XRAM0;
    RD1 = 0x1d89d8a5;// 32*2+4 = 68
    call STA3_Run;
    call STA3_Rst;

    RD2 = 0x56f1c778;
    RD2 ^= RD0;
    if(RQ_nZero) goto L_STA3_Test_Err;
    RD2 = 0x0005f81c;
    RD2 ^= RD1;
    if(RQ_nZero) goto L_STA3_Test_Err;
    RD0 = RD4;
    RD2 = 0x00e4731d;
    RD2 ^= RD0;
    if(RQ_nZero) goto L_STA3_Test_Err;

    RD0 = 0;
    return_autoField(0*MMU_BASE);

L_STA3_Test_Err:
    RD0 = 1;
    return_autoField(0*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  ��������:
//      FMT_Test
//  ��������:
//      ���Ը���������
//  �������:
//      ��
//  ��������:
//      RD0:0~���� ����~������
//////////////////////////////////////////////////////////////////////////
sub_autofield FMT_Test;
    RD0 = RN_XRAM0;
    call En_GRAM_To_CPU;
    RD0 = RN_Multi_Sin_ADDR;
    RA0 = RD0;
    RD0 = RN_XRAM0;
    RA1 = RD0;
    RD0 = 128;
    call memcpy2;

    RD0 = RN_XRAM0;
    RA0 = RD0;
    RD0 = RN_XRAM1;
    RA1 = RD0;
    RD0 = 0x27627629;// 32*2+2 = 66
    call Real_To_Complex2;

    RD0 = RN_XRAM1;
    call En_GRAM_To_CPU;
    RD0 = RN_FMT_RST_ADDR;
    RA0 = RD0;
    RD0 = RN_XRAM1;
    RA1 = RD0;
    RD0 = 256;
    call memcmp2;
    if(RD0_nZero) goto L_FMT_Test_Err;
    RD0 = 0;
    return_autoField(0*MMU_BASE);

L_FMT_Test_Err:
    RD0 = 1;
    return_autoField(0*MMU_BASE);


////////////////////////////////////////////////////////
//  ��������:
//      ALU_MAC_TEST
//  ��������:
//      ����MAC��ԪALU32λ�˷��Ĳ����Ƿ���ȷ
//  �����β�:
//      RD0
////////////////////////////////////////////////////////
Sub_AutoField ALU_MAC_TEST;
	push RA2;
	push RA5;
	RD0 = RN_GRAM0;
	RA0 = RD0;    //����Դ��ַ
	RD0 = RN_GRAM1;
	RA1 = RD0;    //����Դ��ַ
	RD0 = RN_GRAM2;
	RA2 = RD0;    //����Ŀ���ַ

	// Multi64����Ϊ�з�������
    Multi64_Enable;
    RD0 = 0;
    Multi64_Cfg = RD0;

//д��������
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
    RD0 = DMA_PATH0;
    M[RA0] = RD0;
    MemSet_Disable;     //���ý���
    CPU_WorkEnable;
	RD1 = 16;
    RD2 = 32;
L_ALU_MAC_TEST_SetNum_L0:
    RD0 = M[RA5+RD1];
	M[RA0++] = RD0;
	RD1 ++;
	RD2 --;
	if(RQ_nZero) goto L_ALU_MAC_TEST_SetNum_L0;
	CPU_WorkDisable;

	MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
    RD0 = DMA_PATH0;
    M[RA1] = RD0;
    MemSet_Disable;     //���ý���
    CPU_WorkEnable;
    RD1 = 49;
    RD2 = 32;
L_ALU_MAC_TEST_SetNum_L1:
	RD0 = M[RA5+RD1];
	M[RA1++] = RD0;
	RD1 ++;
	RD2 --;
	if(RQ_nZero) goto L_ALU_MAC_TEST_SetNum_L1;
	CPU_WorkDisable;

	RD0 = RN_GRAM0;
	RA0 = RD0;    //����Դ��ַ1
	RD0 = RN_GRAM1;
	RA1 = RD0;    //����Դ��ַ2

//--------------------------------------------------
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH2] = RD0;//ѡ��PATH2��ͨ����Ϣ��ƫַ��
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //����ALU����
    RD0 = RN_CFG_MAC_TYPE0;//    //X[n]*CONST/32767
    M[RA6+9*MMU_BASE] = RD0;     //MACдָ��˿�
    RD0 = 1;     //CONSTΪ16λ���ߵ�16λд��ͬ����
    M[RA6+10*MMU_BASE] = RD0;    //дConst�˿�
    //������ص�4KRAM
    RD0 = DMA_PATH2;
    M[RA0] = RD0;
    M[RA1] = RD0;
	M[RA2] = RD0;
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ������
    RD0 = RA0;//Դ��ַ1
    send_para(RD0);
    RD0 = RA1;//Դ��ַ2
    send_para(RD0);
	RD0 = RA2;//Ŀ���ַ 
    send_para(RD0);
    RD0 = 0x452C52FA;   //(����+1)*3
    send_para(RD0);
    call _DMA_ParaCfg_MAC;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH2;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_MAC;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
	
	//CPU���� ��DSP�ȽϽ�� 
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    RD0 = DMA_PATH0;
    M[RA0] = RD0;
    M[RA1] = RD0;
	M[RA2] = RD0;
    MemSet_Disable; 
	CPU_WorkEnable;
	RD2 = 32;
L_ALU_MAC_TEST_Compa_Num_L1:
	RD0 = M[RA0];
	RF_GetH16(RD0);
	RD0_SignExtL16;
	RD1 = RD0;
	RD0 = M[RA1];
	RF_GetH16(RD0);
	RD0_SignExtL16;
	call _Rs_Multi;
	RF_ShiftL1(RD0);
	RF_GetH16(RD0);
	RF_RotateL16(RD0);
	RD3 = RD0;

	RD0 = M[RA0++];
	RF_GetL16(RD0);
	RD0_SignExtL16;
	RD1 = RD0;
	RD0 = M[RA1++];
	RF_GetL16(RD0);
	RD0_SignExtL16;
	call _Rs_Multi;
	RF_ShiftL1(RD0);
	RF_GetH16(RD0);
	RD0 += RD3; 
	RD1 = M[RA2++];
	RD0 -= RD1;
	if (RQ_nZero) goto L_ALU_MAC_TEST_Err;	
	RD2--;
	if (RQ_nZero) goto L_ALU_MAC_TEST_Compa_Num_L1;
	RD0 = 0x0;
	CPU_WorkDisable;
	goto L_ALU_MAC_TEST_End;
L_ALU_MAC_TEST_Err:
	RD0 = -1;
	CPU_WorkDisable;
L_ALU_MAC_TEST_End:
	pop RA5;
	pop RA2;
	Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////////
//  �������ƣ�
//			ALU_PATH1_Add_Test
//	���ܣ���������64λ���ĺ�(��ALU_PATH2_Add_Test��ͨ����ͬ)
//		GRAM0  ����Դ��ַ1
//		GRAM1  ����Դ��ַ2
//		GRAM2  Ŀ���ַ
//  ��ڣ�
//		��
//	���ڣ�
//		RD0 (0Ϊ��ȷ��44bb44bbΪ����)
///////////////////////////////////////////////////////////
Sub_AutoField ALU_PATH1_Add_Test;
	push RA2;
	push RA5;
	RD0 = RN_GRAM0;
	RA0 = RD0;    //����Դ��ַ
	RD0 = RN_GRAM1;
	RA1 = RD0;    //����Ŀ���ַ
	RD0 = RN_GRAM2;
	RA2 = RD0;    //����Ŀ���ַ
	
	//д��������
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
    RD0 = DMA_PATH0;
    M[RA0] = RD0;
    MemSet_Disable;     //���ý���
    CPU_WorkEnable;
	RD1 = 16;
    RD2 = 64;
L_ALU_PATH1_Add_Test_L0:
    RD0 = M[RA5+RD1];
	M[RA0++] = RD0;
	RD1 ++;
	RD2 --;
	if(RQ_nZero) goto L_ALU_PATH1_Add_Test_L0;
	CPU_WorkDisable;

	MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
    RD0 = DMA_PATH0;
    M[RA1] = RD0;
    MemSet_Disable;     //���ý���
    CPU_WorkEnable;
    RD1 = 100;
    RD2 = 64;
L_ALU_PATH1_Add_Test_L1:
	RD0 = M[RA5+RD1];
	M[RA1++] = RD0;
	RD1 ++;
	RD2 --;
	if(RQ_nZero) goto L_ALU_PATH1_Add_Test_L1;
	CPU_WorkDisable;

	RD0 = RN_GRAM0;
	RA0 = RD0;    //����Դ��ַ1
	RD0 = RN_GRAM1;
	RA1 = RD0;    //����Դ��ַ2

    //--------------------------------------------------
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //����ALU����
    RD0 = Rff_Add+Op32Bit;//       RN_CFG_MAC_HDMUL+RN_CFG_MAC_QM1M0H16;     //�ӷ�ָ��
    M[RA6+0*MMU_BASE] = RD0;     //ALU1дָ��˿�
	RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1дConst�˿�
    //������ص�4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;
	M[RA2] = RD0;
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ������
    RD0 = RA0;//Դ��ַ1
    send_para(RD0);
    RD0 = RA1;//Դ��ַ2
    send_para(RD0);
	RD0 = RA2;//Ŀ���ַ
    send_para(RD0);
    RD0 = 0x7542DE75;   //64*3 + 4
    send_para(RD0);
    call _DMA_ParaCfg_Rff;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

//CPU�����������Ƚ�
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    RD0 = DMA_PATH0;
    M[RA0] = RD0;
    M[RA1] = RD0;
	M[RA2] = RD0;
    MemSet_Disable;
	CPU_WorkEnable;
	RD2 = 64;
L_ALU_PATH1_Add_Test_L2:
	RD0 = M[RA0++];
	RD0 += M[RA1++];
	RD0 -= M[RA2++];
	if(RQ_nZero) goto L_ALU_PATH1_Add_Test_L3;
	RD2 --;
	if(RQ_nZero) goto L_ALU_PATH1_Add_Test_L2;
	RD0 = 0x0;
	CPU_WorkDisable;
	pop RA5;
	pop RA2;
	Return_Autofield(0*MMU_BASE);

L_ALU_PATH1_Add_Test_L3:
	RD0 = -1;
	CPU_WorkDisable;
	pop RA5;
	pop RA2;
	Return_Autofield(0*MMU_BASE);


////////////////////////////////////////////////////////////
//  �������ƣ�
//			ALU_PATH2_Add_Test
//	���ܣ���������64λ���ĺ�(��ALU_PATH1_Add_Test��ͨ����ͬ)
//		GRAM0  ����Դ��ַ1
//		GRAM1  ����Դ��ַ2
//		GRAM2  Ŀ���ַ
//  ��ڣ�
//		��
//	���ڣ�
//		RD0 (0Ϊ��ȷ��44bb44bbΪ����)
///////////////////////////////////////////////////////////
sub_autofield ALU_PATH2_Add_Test;
	push RA2;
	push RA5;
	RD0 = RN_GRAM0;
	RA0 = RD0;    //����Դ��ַ
	RD0 = RN_GRAM1;
	RA1 = RD0;    //����Դ��ַ
	RD0 = RN_GRAM2;
	RA2 = RD0;    //����Ŀ���ַ
	
	//д��������
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
    RD0 = DMA_PATH0;
    M[RA0] = RD0;
    MemSet_Disable;     //���ý���
    CPU_WorkEnable;
	RD1 = 16;
    RD2 = 64;
L_ALU_PATH2_Add_Test_L0:
    RD0 = M[RA5+RD1];
	M[RA0++] = RD0;
	RD1 ++;
	RD2 --;
	if(RQ_nZero) goto L_ALU_PATH2_Add_Test_L0;
	CPU_WorkDisable;

	MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
    RD0 = DMA_PATH0;
    M[RA1] = RD0;
    MemSet_Disable;     //���ý���
    CPU_WorkEnable;
    RD1 = 100;
    RD2 = 64;
L_ALU_PATH2_Add_Test_L1:
	RD0 = M[RA5+RD1];
	M[RA1++] = RD0;
	RD1 ++;
	RD2 --;
	if(RQ_nZero) goto L_ALU_PATH2_Add_Test_L1;
	CPU_WorkDisable;

	RD0 = RN_GRAM0;
	RA0 = RD0;    //����Դ��ַ1
	RD0 = RN_GRAM1;
	RA1 = RD0;    //����Դ��ַ2
	

    //--------------------------------------------------
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //����ALU����
    RD0 = Rff_Add+Op32Bit;//       RN_CFG_MAC_HDMUL+RN_CFG_MAC_QM1M0H16;     //�ӷ�ָ��
    M[RA6+0*MMU_BASE] = RD0;     //ALU1дָ��˿�
	RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1дConst�˿�
    //������ص�4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;
	M[RA2] = RD0;
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ������
    RD0 = RA0;//Դ��ַ1
    send_para(RD0);
    RD0 = RA1;//Դ��ַ2
    send_para(RD0);
	RD0 = RA2;//Ŀ���ַ
    send_para(RD0);
    RD0 = 0x7542DE75;   //64*3 + 4
    send_para(RD0);
    call _DMA_ParaCfg_Rff;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

//CPU�����������Ƚ�
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    RD0 = DMA_PATH0;
    M[RA0] = RD0;
    M[RA1] = RD0;
	M[RA2] = RD0;
    MemSet_Disable;
	CPU_WorkEnable;
	RD2 = 64;
L_ALU_PATH2_Add_Test_L2:
	RD0 = M[RA0++];
	RD0 += M[RA1++];
	RD0 -= M[RA2++];
	if(RQ_nZero) goto L_ALU_PATH2_Add_Test_L3;
	RD2 --;
	if(RQ_nZero) goto L_ALU_PATH2_Add_Test_L2;
	CPU_WorkDisable;
	pop RA5;
	pop RA2;
	RD0 = 0x0;
	Return_AutoField(0*MMU_BASE);

L_ALU_PATH2_Add_Test_L3:
	CPU_WorkDisable;
	pop RA5;
	pop RA2;
	RD0 = -1;
	Return_AutoField(0*MMU_BASE);




////////////////////////////////////////////////////////
//  ��������:
//      ALU_PATH1_Sub_Test
//  ��������:
//      ����ALU32λ�����Ĳ����Ƿ���ȷ����ALU_PATH2_Sub_Test��ͨ����ͬ��
//  �����β�:
//      RD0 (0Ϊ��ȷ������Ϊ����)
////////////////////////////////////////////////////////
Sub_AutoField ALU_PATH1_Sub_Test;
//--------------------------------------------------
	push RA2;
	push RA5;
/////////////////////////////////////////////////////////
//����Ϊ������ƽ������ʾ������
	RD0 = RN_GRAM0;
	RA0 = RD0;    //����Դ��ַ
	RD0 = RN_GRAM1;
	RA1 = RD0;    //����Դ��ַ
	RD0 = RN_GRAM2;
	RA2 = RD0;    //����Ŀ���ַ

//д��������
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
    RD0 = DMA_PATH0;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //���ý���
    
    CPU_WorkEnable;
    RD0 = 16;
	RA5 += RD0;//����Const_ROM�ĳ�ʼλ��
    RD2 = 64;
L_ALU_PATH1_Sub_Test_SetNum_L0:
	RD0 = M[RA5];
	RA5 ++;
	M[RA0++] = RD0;
	RD2 --;
	if(RQ_nZero) goto L_ALU_PATH1_Sub_Test_SetNum_L0;

    RD2 = 64;
    RD1 = 36;
L_ALU_PATH1_Sub_Test_SetNum_L1:
	RD0 = M[RA5+RD1];
	RD1 ++;
	M[RA1++] = RD0;
	RD2 --;
	if(RQ_nZero) goto L_ALU_PATH1_Sub_Test_SetNum_L1;
	CPU_WorkDisable;

	RD0 = RN_GRAM0;
	RA0 = RD0;    //����Դ��ַ
	RD0 = RN_GRAM1;
	RA1 = RD0;    //����Ŀ���ַ

    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //������ص�1KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;
	M[RA2] = RD0;

	//����ALU����
    RD0 = Rff_Sub+Op32Bit;//       RN_CFG_MAC_HDMUL+RN_CFG_MAC_QM1M0H16;     //�ӷ�ָ��
    M[RA6+0*MMU_BASE] = RD0;     //ALU1дָ��˿�
    RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1дConst�˿�
	
	MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ������
    RD0 = RA0;//Դ��ַ0
    send_para(RD0);
	RD0 = RA1;//Դ��ַ1
    send_para(RD0);
    RD0 = RA2;//Ŀ���ַ
    send_para(RD0);
    RD0 = 0x7542de75;   //64*3 + 4
    send_para(RD0);
    call _DMA_ParaCfg_Rff;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    
    //Set_CPUSpeed4;
	//CPU���� ��DSP�ȽϽ�� 
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    RD0 = DMA_PATH0;
    M[RA0] = RD0;
    M[RA1] = RD0;
	M[RA2] = RD0;
    MemSet_Disable; 
	CPU_WorkEnable;
	RD2 = 64;
L_ALU_PATH1_Sub_Test_Compa_Num_L1:
	RD0 =  M[RA0++];
	RD0 -= M[RA1++];
	RD0 -= M[RA2++];
	if (RQ_nZero) goto L_ALU_PATH1_Sub_Test_Err;
	RD2--;
	if (RQ_nZero) goto L_ALU_PATH1_Sub_Test_Compa_Num_L1;
	CPU_WorkDisable;
	RD0 = 0x0;
	pop RA5;
	pop RA2;
	return_autofield(0*MMU_BASE);

L_ALU_PATH1_Sub_Test_Err:
	CPU_WorkDisable;
	RD0 = -1;
	pop RA5;
	pop RA2;
	return_autofield(0*MMU_BASE);
	
	
	
	
	
////////////////////////////////////////////////////////
//  ��������:
//      ALU_PATH2_Sub_Test
//  ��������:
//      ����ALU32λ�����Ĳ����Ƿ���ȷ����ALU_PATH2_Sub_Test��ͨ����ͬ��
//  �����β�:
//      RD0 (0Ϊ��ȷ������Ϊ����)
////////////////////////////////////////////////////////
sub_autofield ALU_PATH2_Sub_Test;
//--------------------------------------------------
	push RA2;
	push RA5;
/////////////////////////////////////////////////////////
//����Ϊ������ƽ������ʾ������
	RD0 = RN_GRAM0;
	RA0 = RD0;    //����Դ��ַ
	RD0 = RN_GRAM1;
	RA1 = RD0;    //����Դ��ַ
	RD0 = RN_GRAM2;
	RA2 = RD0;    //����Ŀ���ַ

//д��������
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
    RD0 = DMA_PATH0;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //���ý���
    
    CPU_WorkEnable;
    RD0 = 16;
	RA5 += RD0;//����Const_ROM�ĳ�ʼλ��
    RD2 = 64;
L_ALU_PATH2_Sub_Test_SetNum_L0:
	RD0 = M[RA5];
	RA5 ++;
	M[RA0++] = RD0;
	RD2 --;
	if(RQ_nZero) goto L_ALU_PATH2_Sub_Test_SetNum_L0;

    RD2 = 64;
    RD1 = 36;
L_ALU_PATH2_Sub_Test_SetNum_L1:
	RD0 = M[RA5+RD1];
	RD1 ++;
	M[RA1++] = RD0;
	RD2 --;
	if(RQ_nZero) goto L_ALU_PATH2_Sub_Test_SetNum_L1;
	CPU_WorkDisable;

	RD0 = RN_GRAM0;
	RA0 = RD0;    //����Դ��ַ
	RD0 = RN_GRAM1;
	RA1 = RD0;    //����Ŀ���ַ

    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //������ص�1KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;
	M[RA2] = RD0;

	//����ALU����
    RD0 = Rff_Sub+Op32Bit;//       RN_CFG_MAC_HDMUL+RN_CFG_MAC_QM1M0H16;     //�ӷ�ָ��
    M[RA6+0*MMU_BASE] = RD0;     //ALU1дָ��˿�
    RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1дConst�˿�
	
	MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ������
    RD0 = RA0;//Դ��ַ0
    send_para(RD0);
	RD0 = RA1;//Դ��ַ1
    send_para(RD0);
    RD0 = RA2;//Ŀ���ַ
    send_para(RD0);
    RD0 = 0x7542de75;   //64*3 + 4
    send_para(RD0);
    call _DMA_ParaCfg_Rff;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    
    //Set_CPUSpeed4;
	//CPU���� ��DSP�ȽϽ�� 
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    RD0 = DMA_PATH0;
    M[RA0] = RD0;
    M[RA1] = RD0;
	M[RA2] = RD0;
    MemSet_Disable; 
	CPU_WorkEnable;
	RD2 = 64;
L_ALU_PATH2_Sub_Test_Compa_Num_L1:
	RD0 =  M[RA0++];
	RD0 -= M[RA1++];
	RD0 -= M[RA2++];
	if (RQ_nZero) goto L_ALU_PATH2_Sub_Test_Err;
	RD2--;
	if (RQ_nZero) goto L_ALU_PATH2_Sub_Test_Compa_Num_L1;
	CPU_WorkDisable;
	RD0 = 0x0;
	pop RA5;
	pop RA2;
	return_autofield(0*MMU_BASE);

L_ALU_PATH2_Sub_Test_Err:
	CPU_WorkDisable;
	RD0 = -1;
	pop RA5;
	pop RA2;
	return_autofield(0*MMU_BASE);	


////////////////////////////////////////////////////////
//  ��������:
//      Add_LMT_Test
//  ��������:
//      �����޷�Add_LMT 32λ�ӷ��Ĳ����Ƿ���ȷ
//  �����β�:
//      RD0
////////////////////////////////////////////////////////
sub_autofield Add_LMT_Test;
//--------------------------------------------------
	push RA2;
	push RA5;
	push RD4;
/////////////////////////////////////////////////////////
	RD0 = RN_GRAM0;
	RA0 = RD0;    //����Դ��ַ
	RD0 = RN_GRAM1;
	RA1 = RD0;    //����Դ��ַ
	RD0 = RN_GRAM2;
	RA2 = RD0;    //����Ŀ���ַ

//д��������
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
    RD0 = DMA_PATH0;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //���ý���
    
    CPU_WorkEnable;
    RD0 = 17;
	RA5 += RD0;//����Const_ROM�ĳ�ʼλ��
    RD2 = 64;
L_Add_LMT_Test_SetNum_L0:
	RD0 = M[RA5];
	RA5 ++;
	M[RA0++] = RD0;
	RD2 --;
	if(RQ_nZero) goto L_Add_LMT_Test_SetNum_L0;

    RD2 = 64;
L_Add_LMT_Test_SetNum_L1:
	RD0 = M[RA5];
	RA5 ++;
	M[RA1++] = RD0;
	RD2 --;
	if(RQ_nZero) goto L_Add_LMT_Test_SetNum_L1;
	CPU_WorkDisable;
	
//����Add_LMT�����㣬����浽GRAM2����
	RD0 = RN_GRAM0;
	RA0 = RD0;    //��������1ָ��
	RD0 = RN_GRAM1;
	RA1 = RD0;    //��������2ָ��
	RD0 = RN_GRAM2;
	RD1 = RD0;    //�������ָ��
	RD0 = 0x7542de75;   //TimerNumֵ = 64*3 + 4
	call Add_LMT;

    //Set_CPUSpeed4;
	//CPU���� ��DSP�ȽϽ�� 
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    RD0 = DMA_PATH0;
    M[RA0] = RD0;
    M[RA1] = RD0;
	M[RA2] = RD0;
    MemSet_Disable; 
	CPU_WorkEnable;
	RD2 = 64;
L_Add_LMT_Test_Compa_Num_L1:
	//GRAM0��GRAM1�еĵ�16λ���
	RD0 =  M[RA0];
	RF_GetL16(RD0);
	RF_RotateL16(RD0);
	RD3 = RD0;          //RD3�ݴ�GRAM0�еĵ�16λ��	

	RD0 =  M[RA1];
	RF_GetL16(RD0);
	RF_RotateL16(RD0);
	RD0 +=RD3;			//GRAM0�е�L16 + GRAM1�е�L16
	if (RQ_OverFlow) goto L_Add_LMT_Test_L16_LM;
	RF_GetH16(RD0);
	RD4 =RD0;			//RD4�ݴ��16λ��������  	
	goto L_Add_LMT_Test_H16;
	
L_Add_LMT_Test_L16_LM:
	if (RD0_Bit31 == 1) goto L_Add_LMT_Test_L16_LM_7FFF;
	RD4 =  0x00008001;
	goto L_Add_LMT_Test_H16;
	
L_Add_LMT_Test_L16_LM_7FFF:
	RD4 =  0x00007FFF;

L_Add_LMT_Test_H16:
	//GRAM0��GRAM1�еĸ�16λ���
	RD0 =  M[RA0++];
	RF_GetH16(RD0);
	RF_RotateL16(RD0);
	RD3 = RD0;          //RD3�ݴ�GRAM0�еĸ�16λ��

	RD0 =  M[RA1++];
	RF_GetH16(RD0);
	RF_RotateL16(RD0);
	RD0 +=RD3;			//GRAM0�е�H16 + GRAM1�е�H16
	if (RQ_OverFlow) goto L_Add_LMT_Test_H16_LM;
	goto L_Add_LMT_Test_H16_After;
	
L_Add_LMT_Test_H16_LM:
	if (RD0_Bit31 == 1) goto L_Add_LMT_Test_H16_LM_7FFF;
	RD0 =  0x80010000;
	goto L_Add_LMT_Test_H16_After;
	
L_Add_LMT_Test_H16_LM_7FFF:
	RD0 =  0x7FFF0000;
L_Add_LMT_Test_H16_After:
	RD0 +=RD4;			//��H16�Ľ���� �� ��L16�Ľ���� ���Ϊ32λ��
	RD0 -= M[RA2++];
	if (RQ_nZero) goto L_Add_LMT_Test_Err;
	RD2--;
	if (RQ_nZero) goto L_Add_LMT_Test_Compa_Num_L1;
	RD0 = 0x0;
	goto L_Add_LMT_Test_End;
L_Add_LMT_Test_Err:
	RD0 = -1;
L_Add_LMT_Test_End:
	CPU_WorkDisable;
	pop RD4;
	pop RA5;
	pop RA2;
	return_autofield(0*MMU_BASE);



////////////////////////////////////////////////////////
//  ��������:
//      Sub_LMT_Test
//  ��������:
//      �����޷�Sub_LMT 32λ�����Ĳ����Ƿ���ȷ
//  �����β�:
//      RD0
////////////////////////////////////////////////////////
sub_autofield Sub_LMT_Test;
//--------------------------------------------------
	push RA2;
	push RA5;
	push RD4;
/////////////////////////////////////////////////////////
	RD0 = RN_GRAM0;
	RA0 = RD0;    //����Դ��ַ
	RD0 = RN_GRAM1;
	RA1 = RD0;    //����Դ��ַ
	RD0 = RN_GRAM2;
	RA2 = RD0;    //����Ŀ���ַ

//д��������
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
    RD0 = DMA_PATH0;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //���ý���
    
    CPU_WorkEnable;
    RD0 = 17;
	RA5 += RD0;//����Const_ROM�ĳ�ʼλ��
    RD2 = 64;
L_Sub_LMT_Test_SetNum_L0:
	RD0 = M[RA5];
	RA5 ++;
	M[RA0++] = RD0;
	RD2 --;
	if(RQ_nZero) goto L_Sub_LMT_Test_SetNum_L0;

    RD2 = 64;
L_Sub_LMT_Test_SetNum_L1:
	RD0 = M[RA5];
	RA5 ++;
	M[RA1++] = RD0;
	RD2 --;
	if(RQ_nZero) goto L_Sub_LMT_Test_SetNum_L1;
	CPU_WorkDisable;
	
//����Sub_LMT�����㣬����浽GRAM2����
	RD0 = RN_GRAM0;
	RA0 = RD0;    //��������1ָ��
	RD0 = RN_GRAM1;
	RA1 = RD0;    //��������2ָ��
	RD0 = RN_GRAM2;
	RD1 = RD0;    //�������ָ��
	RD0 = 0x7542de75;   //TimerNumֵ = 64*3 + 4
	call Sub_LMT;	
	//CPU���� ��DSP�ȽϽ�� 
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    RD0 = DMA_PATH0;
    M[RA0] = RD0;
    M[RA1] = RD0;
	M[RA2] = RD0;
    MemSet_Disable; 
	CPU_WorkEnable;
	RD2 = 64;
L_Sub_LMT_Test_Compa_Num_L1:
	//GRAM0��GRAM1�еĵ�16λ���
	RD0 =  M[RA1];
	RF_GetL16(RD0);
	RF_RotateL16(RD0);
	RD3 = RD0;          //RD3�ݴ�GRAM0�еĵ�16λ��	

	RD0 =  M[RA0];
	RF_GetL16(RD0);
	RF_RotateL16(RD0);
	RD0 -=RD3;			//GRAM0�е�L16 - GRAM1�е�L16
	if (RQ_OverFlow) goto L_Sub_LMT_Test_L16_LM;
	RF_GetH16(RD0);
	RD4 =RD0;			//RD4�ݴ��16λ��������  	
	goto L_Sub_LMT_Test_H16;
	
L_Sub_LMT_Test_L16_LM:
	if (RD0_Bit31 == 1) goto L_Sub_LMT_Test_L16_LM_7FFF;
	RD4 =  0x00008001;
	goto L_Sub_LMT_Test_H16;
	
L_Sub_LMT_Test_L16_LM_7FFF:
	RD4 =  0x00007FFF;
	
L_Sub_LMT_Test_H16:
	//GRAM0��GRAM1�еĸ�16λ���
	RD0 =  M[RA1++];
	RF_GetH16(RD0);
	RF_RotateL16(RD0);
	RD3 = RD0;          //RD3�ݴ�GRAM0�еĸ�16λ��
	RD0 =  M[RA0++];
	RF_GetH16(RD0);
	RF_RotateL16(RD0);
	RD0 -=RD3;			//GRAM0�е�H16 - GRAM1�е�H16
	if (RQ_OverFlow) goto L_Sub_LMT_Test_H16_LM;
	goto L_Sub_LMT_Test_H16_After;
L_Sub_LMT_Test_H16_LM:
	if (RD0_Bit31 == 1) goto L_Sub_LMT_Test_H16_LM_7FFF;
	RD0 =  0x80010000;
	goto L_Sub_LMT_Test_H16_After;
L_Sub_LMT_Test_H16_LM_7FFF:
	RD0 =  0x7FFF0000;
L_Sub_LMT_Test_H16_After:
	RD0 +=RD4;			//��H16�Ľ���� �� ��L16�Ľ���� ���Ϊ32λ��
	RD0 -= M[RA2++];
	if (RQ_nZero) goto L_Sub_LMT_Test_Err;
	RD2--;
	if (RQ_nZero) goto L_Sub_LMT_Test_Compa_Num_L1;
	RD0 = 0x0;
	goto L_Sub_LMT_Test_End;
L_Sub_LMT_Test_Err:
	RD0 = -1;
L_Sub_LMT_Test_End:
	CPU_WorkDisable;
	pop RD4;
	pop RA5;
	pop RA2;
	return_autofield(0*MMU_BASE);


////////////////////////////////////////////////////////
//  ����:
//      IIR_PATH1_Test
//  ����:
//      ʹ��PATH1�ϵ�IIR�˲���,�����ݴ���GRAM0,��ȷ�������GRAM2
//      ����������GRAM1,�ȽϽ����ȷ��
//  ����:
//      ��
//  ����ֵ:
//      RD0(0Ϊ��ȷ����0Ϊ����)
////////////////////////////////////////////////////////
Sub_AutoField IIR_PATH1_Test;

 	call CKT_Filt_IIR_PATH1;
 	    
 	RD0 = RN_GRAM1; 
	RA0 = RD0;            
	MemSetRAM4K_Enable;
	RD0 = DMA_PATH0;
	M[RA0] = RD0;    
	MemSet_Disable; 
	CPU_WorkEnable;
	 
	RD1 = 0;
	RD2 = 256;
L_IIR_Test_L2:
	RD0 = M[RA0++];
	RD1 += RD0;
	RD2--;
	if(RQ_nZero) goto L_IIR_Test_L2;
	RD0 = 0x156eedbb;
	RD1 -= RD0;
	RD0 = RD1;
	if(RQ_nZero) goto L_IIR_Test_Err;
	RD0 = 0x0;
	Return_AutoField(0*MMU_BASE);

L_IIR_Test_Err:
	RD0 = -1;
	Return_AutoField(0*MMU_BASE);


////////////////////////////////////////////////////////
//  ����:
//      CKT_Filt_IIR_PATH1
//  ����:
//      ʹ��PATH1�ϵ�IIR�˲�������һ������
//  ����:
//      ��
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField CKT_Filt_IIR_PATH1;
	//�ò�������(256�㣬128Dword)
	call Set_IIR_data1;

	RD0 = RN_GRAM0;
	RA0 = RD0;
	RD1 = RN_GRAM1;
	RA1 = RD1;

    //��ʼ��IIR_PATH1�˲���
    IIR_PATH1_Enable;
    MemSetRAM4K_Enable;
    RD0 = 0x0;// Para0, Data00
    IIR_PATH1_BANK = RD0;
    call IIR_PATH1_TestInit;
    IIR_PATH1_Disable;

//--------------------------------------------------
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
	MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
	RD0 = DMA_PATH1;
	M[RA0] = RD0;
	M[RA1] = RD0;
	MemSet_Disable;     //���ý���
    
    //����DMA_Ctrl������������ַ.����
    RD0 = RN_GRAM0;//Դ��ַ
    send_para(RD0);
    RD0 = RN_GRAM1;//Ŀ���ַ
    send_para(RD0);
    RD0 = 0x48bcbffb;//242Dword��(����Dword����*88)+1
    send_para(RD0);
    call _DMA_ParaCfg_FiltIIR;

	IIR_PATH1_Enable;
    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_IIR;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    IIR_PATH1_Disable;

    Return_AutoField(0*MMU_BASE);








////////////////////////////////////////////////////////
//  ����:
//      IIR_PATH1_TestInit
//  ����:
//      ����IIR_PATH1�˲���ϵ��,Ϊ����˲���
//  ����:
//      ��
//  ����ֵ:
//      ��
//  ע��:
//      ͨ�� F_SAMPLE / 4 (����˲�����
//      Set_IIRSftL2XY;
//          ABϵ��������һ����A2B2)����2��ţ���ϵ�����ȴ���4ʱ���á�
//      Set_IIRSftR2X;
//          �������4,���������256ʱ���á�
//      ���ݸ�ʽ:����λ��BIT15) + ����ֵ��BIT14-BIT0)
//      Aϵ�������5 6 7 8������λȡ��
//      ���100DB, ����0.1DB, ���ȴ���+-��205/48K, ���� 1/G0 = 440
//      ������� ��256/���棩  256��24λ���
//      IIRϵ��
//      // IIR0
//      2000, 53FA, 53FA, 2000, 0    //Bϵ��������������λ+����ֵû�б仯
//      2000, B123, 1E78, 8748, 0    //Aϵ��������
//      //    3123, 9E78, 748, 0,     //Aϵ������λȡ��
//      
//      // IIR1
//      2000, 307C, 50B8, 307C, 2000
//      2000, A22A, 33BC, 97C8, E5C
//      //    222A, B3BC, 17C8, 8E5C,     //Aϵ������λȡ��
//      
//      // IIR2
//      2000,  D92, 414D,  D92, 2000
//      2000, 8AF8, 3A69, 89F8, 19D8
//      //     AF8, BA69,  9F8, 99D8,     //Aϵ������λȡ��
//      // IIR3
//      2000,  46F, 4026,  46F, 2000
//      2000, 83C4, 3EC6, 83B2, 1EAD
//      //     3C4, BEC6,  3B2, 9EAD,     //Aϵ������λȡ��
////////////////////////////////////////////////////////
Sub_AutoField IIR_PATH1_TestInit;
//IIR0
//2000, 53FA, 53FA, 2000, 0
////    3123, 9E78, 748, 0,     //Aϵ������λȡ��
    RD0 = 0x2000;      //8192
    IIR_PATH1_HD = RD0;
    RD0 = 0x53FA;      //21498
    IIR_PATH1_HD = RD0;
    RD0 = 0x53FA;      //21498
    IIR_PATH1_HD = RD0;
    RD0 = 0x2000;      //8192
    IIR_PATH1_HD = RD0;
    RD0 = 0x0;         //0000
    IIR_PATH1_HD = RD0;
    RD0 = 0x3123;      //12597
    IIR_PATH1_HD = RD0;
    //RD0 = 0xcfb1;
    RD0 = 0x9E78;      //-7800
    IIR_PATH1_HD = RD0;
    RD0 = 0x748;       //1864
    IIR_PATH1_HD = RD0;
    RD0 = 0x0;         //0000
    IIR_PATH1_HD = RD0;
    RD0 = 0x0C9;
    IIR_PATH1_HD = RD0; //����ֵ
//IIR1
//2000, 307C, 50B8, 307C, 2000
////    222A, B3BC, 17C8, 8E5C,     //Aϵ������λȡ��
    RD0 = 0x2000;      //
    IIR_PATH1_HD = RD0;
    RD0 = 0x307C;
    IIR_PATH1_HD = RD0;
    RD0 = 0x50B8;
    IIR_PATH1_HD = RD0;
    RD0 = 0x307C;
    IIR_PATH1_HD = RD0;
    RD0 = 0x2000;
    IIR_PATH1_HD = RD0;

    RD0 = 0x222A;
    IIR_PATH1_HD = RD0;
    RD0 = 0xB3BC;
    IIR_PATH1_HD = RD0;
    RD0 = 0x17C8;
    IIR_PATH1_HD = RD0;
    RD0 = 0x8E5C;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0; //��дһ��

//// IIR2
//2000,  D92, 414D,  D92, 2000
////     AF8, BA69,  9F8, 99D8,     //Aϵ������λȡ��
    RD0 = 0x2000;
    IIR_PATH1_HD = RD0;
    RD0 = 0xD92;
    IIR_PATH1_HD = RD0;
    RD0 = 0x414D;
    IIR_PATH1_HD = RD0;
    RD0 = 0xD92;
    IIR_PATH1_HD = RD0;
    RD0 = 0x2000;
    IIR_PATH1_HD = RD0;

    RD0 = 0xAF8;
    IIR_PATH1_HD = RD0;
    RD0 = 0xBA69;
    IIR_PATH1_HD = RD0;
    RD0 = 0x9F8;
    IIR_PATH1_HD = RD0;
    RD0 = 0x99D8;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0; //��дһ��
//// IIR3
//2000,  46F, 4026,  46F, 2000
////    83C4, BEC6, 83B2, 9EAD,     //Aϵ������λȡ��

    RD0 = 0x2000;
    IIR_PATH1_HD = RD0;
    RD0 = 0x46F;
    IIR_PATH1_HD = RD0;
    RD0 = 0x4026;
    IIR_PATH1_HD = RD0;
    RD0 = 0x46F;
    IIR_PATH1_HD = RD0;
    RD0 = 0x2000;
    IIR_PATH1_HD = RD0;

    RD0 = 0x3C4;
    IIR_PATH1_HD = RD0;
    RD0 = 0xBEC6;
    IIR_PATH1_HD = RD0;
    RD0 = 0x3B2;
    IIR_PATH1_HD = RD0;
    RD0 = 0x9EAD;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0; //��дһ��

    Return_AutoField(0*MMU_BASE);
    
    
////////////////////////////////////////////////////////
//  ����:
//      Set_IIR_data1
//  ����:
//      ��Const_ROM��GRAM0д��256���ʼ����
//  ����:
//      ��
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////    
Sub_AutoField Set_IIR_data1;
    push RA5;
	RD0 = RN_GRAM0;
	RA0 = RD0;
	MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
	RD0 = DMA_PATH0;
	M[RA0] = RD0;
	MemSet_Disable;     //���ý���
	CPU_WorkEnable;
    RD2 = 256;
L_Set_IIR_data1_L0:
	RD0 = M[RA5++];
	M[RA0++] = RD0;
	RD2 --;
	if(RQ_nZero) goto L_Set_IIR_data1_L0;
	pop RA5;
	Return_AutoField(0*MMU_BASE);





////////////////////////////////////////////////////////
//  ����:
//      IIR_PATH3_Test
//  ����:
//      ʹ��PATH3�ϵ�IIR�˲���,�����ݴ���GRAM0,��ȷ�������GRAM2
//      ����������GRAM1,�ȽϽ����ȷ��
//  ����:
//      ��
//  ����ֵ:
//      RD0(0Ϊ��ȷ����0Ϊ����)
////////////////////////////////////////////////////////
Sub_AutoField IIR_PATH3_Test;

 	call CKT_Filt_IIR_PATH3;
 	    
 	RD0 = RN_GRAM1; 
	RA0 = RD0;            
	MemSetRAM4K_Enable;
	RD0 = DMA_PATH0;
	M[RA0] = RD0;    
	MemSet_Disable; 
	CPU_WorkEnable;
	 
	RD1 = 0;
	RD2 = 256;
L_IIR3_Test_L2:
	RD0 = M[RA0++];
	RD1 += RD0;
	RD2--;
	if(RQ_nZero) goto L_IIR3_Test_L2;
	RD0 = 0x156eedbb;
	RD1 -= RD0;
	RD0 = RD1;
	if(RQ_nZero) goto L_IIR3_Test_Err;
	RD0 = 0x0;
	Return_AutoField(0*MMU_BASE);

L_IIR3_Test_Err:
	RD0 = -1;
	Return_AutoField(0*MMU_BASE);


////////////////////////////////////////////////////////
//  ����:
//      CKT_Filt_IIR_PATH3
//  ����:
//      ʹ��PATH3�ϵ�IIR�˲�������һ������
//  ����:
//      ��
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField CKT_Filt_IIR_PATH3;
	//�ò�������(256�㣬128Dword)
	call Set_IIR_data3;

	RD0 = RN_GRAM0;
	RA0 = RD0;
	RD1 = RN_GRAM1;
	RA1 = RD1;

    //��ʼ��IIR_PATH1�˲���
    IIR_PATH3_Enable;
    MemSetRAM4K_Enable;
    RD0 = 0x0;// Para0, Data00
    IIR_PATH3_BANK = RD0;
    call IIR_PATH3_TestInit;
    IIR_PATH1_Disable;

//--------------------------------------------------
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH3] = RD0;//ѡ��PATH3��ͨ����Ϣ��ƫַ��
	MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
	RD0 = DMA_PATH3;
	M[RA0] = RD0;
	M[RA1] = RD0;
	MemSet_Disable;     //���ý���
    
    //����DMA_Ctrl������������ַ.����
    RD0 = RN_GRAM0;//Դ��ַ
    send_para(RD0);
    RD0 = RN_GRAM1;//Ŀ���ַ
    send_para(RD0);
    RD0 = 0x48bcbffb;//242Dword��(����Dword����*88)+1
    send_para(RD0);
    call _DMA_ParaCfg_FiltIIR;

	IIR_PATH3_Enable;
    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH3;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_IIR;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    IIR_PATH3_Disable;

    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  ����:
//      IIR_PATH3_TestInit
//  ����:
//      ����IIR_PATH3�˲���ϵ��,Ϊ����˲���
//  ����:
//      ��
//  ����ֵ:
//      ��
//  ע��:
//      ͨ�� F_SAMPLE / 4 (����˲�����
//      Set_IIRSftL2XY;
//          ABϵ��������һ����A2B2)����2��ţ���ϵ�����ȴ���4ʱ���á�
//      Set_IIRSftR2X;
//          �������4,���������256ʱ���á�
//      ���ݸ�ʽ:����λ��BIT15) + ����ֵ��BIT14-BIT0)
//      Aϵ�������5 6 7 8������λȡ��
//      ���100DB, ����0.1DB, ���ȴ���+-��205/48K, ���� 1/G0 = 440
//      ������� ��256/���棩  256��24λ���
//      IIRϵ��
//      // IIR0
//      2000, 53FA, 53FA, 2000, 0    //Bϵ��������������λ+����ֵû�б仯
//      2000, B123, 1E78, 8748, 0    //Aϵ��������
//      //    3123, 9E78, 748, 0,     //Aϵ������λȡ��
//      
//      // IIR1
//      2000, 307C, 50B8, 307C, 2000
//      2000, A22A, 33BC, 97C8, E5C
//      //    222A, B3BC, 17C8, 8E5C,     //Aϵ������λȡ��
//      
//      // IIR2
//      2000,  D92, 414D,  D92, 2000
//      2000, 8AF8, 3A69, 89F8, 19D8
//      //     AF8, BA69,  9F8, 99D8,     //Aϵ������λȡ��
//      // IIR3
//      2000,  46F, 4026,  46F, 2000
//      2000, 83C4, 3EC6, 83B2, 1EAD
//      //     3C4, BEC6,  3B2, 9EAD,     //Aϵ������λȡ��
////////////////////////////////////////////////////////
Sub_AutoField IIR_PATH3_TestInit;
//IIR0
//2000, 53FA, 53FA, 2000, 0
////    3123, 9E78, 748, 0,     //Aϵ������λȡ��
    RD0 = 0x2000;      //8192
    IIR_PATH3_HD = RD0;
    RD0 = 0x53FA;      //21498
    IIR_PATH3_HD = RD0;
    RD0 = 0x53FA;      //21498
    IIR_PATH3_HD = RD0;
    RD0 = 0x2000;      //8192
    IIR_PATH3_HD = RD0;
    RD0 = 0x0;         //0000
    IIR_PATH3_HD = RD0;
    RD0 = 0x3123;      //12597
    IIR_PATH3_HD = RD0;
    //RD0 = 0xcfb1;
    RD0 = 0x9E78;      //-7800
    IIR_PATH3_HD = RD0;
    RD0 = 0x748;       //1864
    IIR_PATH3_HD = RD0;
    RD0 = 0x0;         //0000
    IIR_PATH3_HD = RD0;
    RD0 = 0x0C9;
    IIR_PATH3_HD = RD0; //����ֵ
//IIR1
//2000, 307C, 50B8, 307C, 2000
////    222A, B3BC, 17C8, 8E5C,     //Aϵ������λȡ��
    RD0 = 0x2000;      //
    IIR_PATH3_HD = RD0;
    RD0 = 0x307C;
    IIR_PATH3_HD = RD0;
    RD0 = 0x50B8;
    IIR_PATH3_HD = RD0;
    RD0 = 0x307C;
    IIR_PATH3_HD = RD0;
    RD0 = 0x2000;
    IIR_PATH3_HD = RD0;

    RD0 = 0x222A;
    IIR_PATH3_HD = RD0;
    RD0 = 0xB3BC;
    IIR_PATH3_HD = RD0;
    RD0 = 0x17C8;
    IIR_PATH3_HD = RD0;
    RD0 = 0x8E5C;
    IIR_PATH3_HD = RD0;
    IIR_PATH3_HD = RD0; //��дһ��

//// IIR2
//2000,  D92, 414D,  D92, 2000
////     AF8, BA69,  9F8, 99D8,     //Aϵ������λȡ��
    RD0 = 0x2000;
    IIR_PATH3_HD = RD0;
    RD0 = 0xD92;
    IIR_PATH3_HD = RD0;
    RD0 = 0x414D;
    IIR_PATH3_HD = RD0;
    RD0 = 0xD92;
    IIR_PATH3_HD = RD0;
    RD0 = 0x2000;
    IIR_PATH3_HD = RD0;

    RD0 = 0xAF8;
    IIR_PATH3_HD = RD0;
    RD0 = 0xBA69;
    IIR_PATH3_HD = RD0;
    RD0 = 0x9F8;
    IIR_PATH3_HD = RD0;
    RD0 = 0x99D8;
    IIR_PATH3_HD = RD0;
    IIR_PATH3_HD = RD0; //��дһ��
//// IIR3
//2000,  46F, 4026,  46F, 2000
////    83C4, BEC6, 83B2, 9EAD,     //Aϵ������λȡ��

    RD0 = 0x2000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x46F;
    IIR_PATH3_HD = RD0;
    RD0 = 0x4026;
    IIR_PATH3_HD = RD0;
    RD0 = 0x46F;
    IIR_PATH3_HD = RD0;
    RD0 = 0x2000;
    IIR_PATH3_HD = RD0;

    RD0 = 0x3C4;
    IIR_PATH3_HD = RD0;
    RD0 = 0xBEC6;
    IIR_PATH3_HD = RD0;
    RD0 = 0x3B2;
    IIR_PATH3_HD = RD0;
    RD0 = 0x9EAD;
    IIR_PATH3_HD = RD0;
    IIR_PATH3_HD = RD0; //��дһ��

    Return_AutoField(0*MMU_BASE);
    
    
////////////////////////////////////////////////////////
//  ����:
//      Set_IIR_data3
//  ����:
//      ��Const_ROM��GRAM0д��256���ʼ����
//  ����:
//      ��
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////    
Sub_AutoField Set_IIR_data3;
    push RA5;
	RD0 = RN_GRAM0;
	RA0 = RD0;
	MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
	RD0 = DMA_PATH0;
	M[RA0] = RD0;
	MemSet_Disable;     //���ý���
	CPU_WorkEnable;
    RD2 = 256;
L_Set_IIR_data3_L0:
	RD0 = M[RA5++];
	M[RA0++] = RD0;
	RD2 --;
	if(RQ_nZero) goto L_Set_IIR_data3_L0;
	pop RA5;
	Return_AutoField(0*MMU_BASE);
	


////////////////////////////////////////////////////////
//  ����:
//      FFT_Fast128_Test
//  ����:
//      ����128������FFT�Ľ��
//  ����:
//      ��
//  ����ֵ:
//      RD0:44bb44bb�������0������ȷ
////////////////////////////////////////////////////////
Sub_AutoField FFT_Fast128_Test;
	call Set_FFT128data;

	RD0 = RN_GRAM0;
	RD1 = RN_GRAM1;
	call FFT_Fast128;

	RD0 = RN_GRAM1;
	RA0 = RD0;
	MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
	RD0 = DMA_PATH0;
    M[RA0] = RD0;
    MemSet_Disable;     //���ý���
    CPU_WorkEnable;
	RD2 = 128;
	RD1 = 0;
	
FFT_Fast128_Test_L2:
    RD0 = M[RA0++];
    RD1 += RD0;
	RD2 --;
    if(RQ_nZero) goto FFT_Fast128_Test_L2;
	RD0 = 0x600affc0;
    RD1 -= RD0;
    RD0 = RD1;
    if(RQ_nZero) goto L_FFT_OutErr;
	CPU_WorkDisable;
	RD0 = 0x0;
	Return_AutoField(0*MMU_BASE);

L_FFT_OutErr:
	RD0 = -1;
	CPU_WorkDisable;
	Return_AutoField(0*MMU_BASE);


////////////////////////////////////////////////////////
//  ����:
//      Set_FFT128data
//  ����:
//      ��CONST_ROM��FFT���Եĳ�ʼ����д��GRAM0
//��ڲ���:
//      ��
//  ���ڲ���:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField Set_FFT128data;
	push RA5;
	
	RD0 = RN_GRAM0;
 	RA1 = RD0;
	MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
    RD0 = DMA_PATH0;
    M[RA1] = RD0;
    MemSet_Disable;     //���ý���
    CPU_WorkEnable;
	
	RD2 = 128;
L_Set_FFT128data_L0:
	RD0 = M[RA5++];
	M[RA1++] = RD0;
	RD2 --;
	if(RQ_nZero) goto L_Set_FFT128data_L0;
	
	pop RA5;
	Return_AutoField(0*MMU_BASE);


////////////////////////////////////////////////////////
//  ��������:
//      FFT_Test;
//  ��������:
//     ʹ��FFT����,�����ݴ���GRAM0,��ȷ�������GRAM2
//     ����������GRAM1,�ȽϽ����ȷ��
//  ��ڲ���:
//      ��
//  ���ڲ���:
//      RD0(0Ϊ��ȷ��44BB44BBΪ����)
////////////////////////////////////////////////////////
Sub_AutoField FFT_Test;
	// FFT���ʼ����GRAM
    call FFT_Init;
	call Set_FFT128data;
L_FFT_Test_Start:
	RD0 = RN_GRAM0;
	RD1 = RN_GRAM1;
	call FFT_fix128;

	RD0 = RN_GRAM1;
	RA0 = RD0;
	MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
	RD0 = DMA_PATH0;
    M[RA0] = RD0;
    MemSet_Disable;     //���ý���
    CPU_WorkEnable;

	RD2 = 128;
	RD1 = 0;
L_FFT_Test_L0:
    RD0 = M[RA0++];
Debug_Reg32 = RD0;
    RD1 += RD0;
	RD2 --;
    if(RQ_nZero) goto L_FFT_Test_L0;
	RD0 = 0x600affc0;
    RD1 -= RD0;
    RD0 = RD1;
	if(RQ_nZero) goto L_FFT_OutErr;
	CPU_WorkDisable;
	RD0 = 0x0;

	Return_AutoField(0*MMU_BASE);
L_FFT_Test_OutErr:
	CPU_WorkDisable;
	RD0 = -1;
	Return_AutoField(0*MMU_BASE);

//////////////////////////////////////////////////////////////////////////
//  ��������:
//      GPIO_Test
//  ��������:
//      ����GPIO
//  �������:
//      ��
//  ��������:
//      RD0:0~���� ����~������
//////////////////////////////////////////////////////////////////////////
sub_autofield GPIO_Test;
	// ����GPIO
    RD0 = GP0_0|GP0_1|GP0_2|GP0_3|GP0_4|GP0_5|GP0_6|GP0_7;
    GPIO_WEn0 = RD0;
    RD0 = GPIO_OUT;
    GPIO_Set0 = RD0;

	// д���ƽ�����
	RD0 = GP0_0|GP0_2|GP0_4|GP0_6;
    GPIO_Data0 = RD0;
	RD1 = GPIO_Data0;
Debug_Reg32 = RD1;
	RD0 ^= RD1;
    if(RQ_nZero) goto L_GPIO_Test_Err;

	// д���ƽ�����
	RD0 = GP0_1|GP0_3|GP0_5|GP0_7;
    GPIO_Data0 = RD0;
	RD1 = GPIO_Data0;
Debug_Reg32 = RD1;
	RD0 ^= RD1;
    if(RQ_nZero) goto L_GPIO_Test_Err;

	// ����GPIO
    RD0 = GP1_0|GP1_1|GP1_2|GP1_3|GP1_4;
    GPIO_WEn1 = RD0;
    RD0 = GPIO_OUT;
    GPIO_Set1 = RD0;
	
	// д���ƽ�����
	RD0 = GP1_0|GP1_2|GP1_4;
    GPIO_Data1 = RD0;
	RD1 = GPIO_Data1;
Debug_Reg32 = RD1;
	RD0 ^= RD1;
    if(RQ_nZero) goto L_GPIO_Test_Err;

	// д���ƽ�����
	RD0 = GP1_1|GP1_3;
    GPIO_Data1 = RD0;
	RD1 = GPIO_Data1;
Debug_Reg32 = RD1;
	RD0 ^= RD1;
    if(RQ_nZero) goto L_GPIO_Test_Err;

    RD0 = 0;
    return_autofield(0);

L_GPIO_Test_Err:
    RD0 = 1;
    return_autofield(0);


//////////////////////////////////////////////////////////////////////////
//  ��������:
//    _Verify_Sum_Reg32:
//  ��������:
//    �����ۼӺ�У���룻
//  �������:
//    RD0:Length�����ݳ��ȣ���DWord��32bit��Ϊ��λ
//    RD1:����ָ����ַ
//  ��������:
//    RD0: У����
//////////////////////////////////////////////////////////////////////////
Sub_AutoField _Verify_Sum_Reg32;
    Set_ConstInt_Dis;

    RA0 = RD1;    //����ָ����ַ
    RD2 = RD0;    //Length
	call _Verify_Sum_L16_Reg;
	RD3 = RD0;    //��16λУ����

    RD0 = RD2;    //����ָ����ַ
    RD1 = RA0;    //Length
	call _Verify_Sum_H16_Reg;
	RD0 += RD3;   //��λ���λ���
	Set_ConstInt_En;
    Return_AutoField(0*MMU_BASE);


//////////////////////////////////////////////////////////////////////////
//  ��������:
//    _Verify_Sum_Const32:
//  ��������:
//    �����ۼӺ�У���룻
//  �������:
//    RD0:Length�����ݳ��ȣ���DWord��16bit��Ϊ��λ��1����ַΪ1��Dword
//    RD1:����ָ����ַ
//  ��������:
//    RD0: У����
//////////////////////////////////////////////////////////////////////////
Sub_AutoField _Verify_Sum_Const32;
    RA0 = RD1;
    RD2 = RD0;
    RD0 = 0x123456;//RESET
    RD1 = 0x123456;//TEMP
L_Verify_Sum_Const32_Loop:
	RD3 = M[RA0];
    RD1 += RD3;
    RD0 += RD1;
    RA0 ++;
    RD2 --;
    if(RQ_nZero) goto L_Verify_Sum_Const32_Loop;
    Return_AutoField(0*MMU_BASE);


//////////////////////////////////////////////////////////////////////////
//  ��������:
//    _Verify_Sum_L16_Reg:
//  ��������:
//    �����ۼӺ�У���룻
//  �������:
//    RD0:Length�����ݳ��ȣ���Word��16bit��Ϊ��λ
//    RD1:����ָ����ַ
//  ��������:
//    RD0: У����
//////////////////////////////////////////////////////////////////////////
Sub_AutoField _Verify_Sum_L16_Reg;

    RA0 = RD1;    //����ָ����ַ
    RD2 = RD0;    //Length

    RD3 = 0x12345678;
    RD1 = RD3;
Verify_Sum_L16_Reg_L:
    RD0 = M[RA0];
    RF_GetL16(RD0);
    RD1 += RD0;
    RA0 ++;
    RD3 += RD1;
    RD2 --;
    if(RQ_nZero) goto Verify_Sum_L16_Reg_L;
    RD0 = RD3;

    Return_AutoField(0*MMU_BASE);
    
//////////////////////////////////////////////////////////////////////////
//  ��������:
//    _Verify_Sum_H16_Reg:
//  ��������:
//    �����ۼӺ�У���룻
//  �������:
//    RD0:Length�����ݳ��ȣ���Word��16bit��Ϊ��λ
//    RD1:����ָ����ַ
//  ��������:
//    RD0: У����
//////////////////////////////////////////////////////////////////////////
Sub_AutoField _Verify_Sum_H16_Reg;

    RA0 = RD1;    //����ָ����ַ
    RD2 = RD0;    //Length

    RD3 = 0x12345678;
    RD1 = RD3;
Verify_Sum_H16_Reg_L:
    RD0 = M[RA0];
    RF_GetH16(RD0);
    RD1 += RD0;
    RA0 ++;
    RD3 += RD1;
    RD2 --;
    if(RQ_nZero) goto Verify_Sum_H16_Reg_L;
    RD0 = RD3;

    Return_AutoField(0*MMU_BASE);


////////////////////////////////////////////////////////
//  ��������:
//      Recover_Speed
//  ��������:
//      �ָ�Ĭ����Ƶ
//  ��ڲ���:
//      RD0:  Set_Speed(RD0+2)
//  ���ڲ���:
//      ��
////////////////////////////////////////////////////////
sub_autofield Recover_Speed;
    RD2 = 0b11;
    RD2 &= RD0;
    RD0 = RD2;
    if(RD0_Zero) goto L_Recover_Speed_2;
    RD0 --;
    if(RD0_Zero) goto L_Recover_Speed_3;
    RD0 --;
    if(RD0_Zero) goto L_Recover_Speed_4;
    RD0 --;
    if(RD0_Zero) goto L_Recover_Speed_5;
	goto L_Recover_Speed_4;

L_Recover_Speed_2:
    Set_CPUSpeed2;
    RD0 = RD2;
    return_autofield(0);

L_Recover_Speed_3:
    Set_CPUSpeed3;
    RD0 = RD2;
    return_autofield(0);

L_Recover_Speed_4:
    Set_CPUSpeed4;
    RD0 = RD2;
    return_autofield(0);

L_Recover_Speed_5:
    Set_CPUSpeed5;
    RD0 = RD2;
	return_autofield(0);



////////////////////////////////////////////////////////
//  ��������:
//      LMS_Test
//  ��������:
//      ����LMSģ���װ���Ƿ�������ȱ��
//  ��ڲ���:
//      ��
//  ���ڲ���:
//      RD0 = 0                     ��ȷ
//		RD0 = ����                  ����
////////////////////////////////////////////////////////
Sub_AutoField LMS_Test;
    call LMS_Test_Init;//Ԥ�����׶�
	RD0 = RN_Const_StartAddr+3771;
	RA2 = RD0;

	//��������ռ�
	RSP -= 4*MMU_BASE;
	RD0 = RSP;
	RA4 = RD0;
	
#define EN          M[RA4+0*MMU_BASE]
#define RN          M[RA4+1*MMU_BASE]   //VNPOWER / 2^8
//#define VNPT_BIAS   M[RA4+2*MMU_BASE]   //VNPOWER / 2^8
	EN = 0;
	RN = 0;
	
	RD0 = RN_LMSRAM_START;
	RA1 = RD0;
	RD0 = RN_LMSRAM_START+64*MMU_BASE;
	RA0 = RD0;
	
#define VN          M[RA0]
#define VNDEL       M[RA1]
/////////////////���㲢����rn��ֵ
	RD2 = 256;//�ܵ���
L_Set_Frist_D1:
	RD0 = VN;       //M[RA0+RD1],ȡVN[n-64]
	LMS_W_16D = RD0;//��vn����LMS������y^n
	RF_ShiftL1(RD0);//��vn�Ŵ������������ǻ���·����YN
	RF_ShiftL2(RD0); 
	RF_ShiftL2(RD0); //YN�Ŵ�16���Ա�֤���յ�����Ч����YN = 16 * Filter(VN)
	RD1 = RD0;
	RD0 = RD2;
	if(RD0_Bit0 == 0) goto L_GetH16_DATA_SN;
	RD0 = M[RA2]; 
	RF_GetL16(RD0);
	RD0 += RD1;//SN + YN
	goto L_GetL16_DATA_SN;
	
L_GetH16_DATA_SN: 
	RD0 = M[RA2]; 
	RF_GetH16(RD0);
	RD0 += RD1;//SN + YN

L_GetL16_DATA_SN:
	RA2++;
	RD1 = LMS_R_16D; //YN^
	RD0 -= RD1;//SN + YN - YN^ = EN
	RF_Lmt32T16(RD0);
	EN = RD0;
////////////////////////////////////////
	//����RN+VN^2
	RD0 = VN;
	LMS_ANEX_WVn2 = RD0;
	nop;
	RD0 = LMS_ANEX_RD;
	RN += RD0;
	//����RN-VNDEL^2
	RD0 = VNDEL;
	LMS_ANEX_WVn2 = RD0;
	nop;
	RD0 = LMS_ANEX_RD;
	RN -= RD0;
	if(RQ>=0) goto L_LMS_L00;
	RN = 0;

	//����1/RN
L_LMS_L00:
	RD0 = EN; 
	LMS_ANEX_WEn = RD0;
	RD0 = RN;
	LMS_ANEX_WRn = RD0;
	nop;nop;nop;
	RD0 = LMS_ANEX_RD;
	LMS_W_Mu = RD0; //ˢ��ϵ��
	
	//����VN[n]������VNDEL��ַ
	RD0 = EN;
	RF_ShiftL1(RD0);
	RF_Lmt32T16(RD0);

	VNDEL = RD0;    //����VN

	RD0 = 0x200;
	RF_Not(RD0);
	//����VNƫ��ָ��
	RA0 += MMU_BASE;
	RA0 &= RD0;
	RA1 += MMU_BASE;
	RA1 &= RD0;

	RD2 --;
	if(RQ_nZero) goto L_Set_Frist_D1;
		
	LMS_DSP_WorkDis;
	RD2 = 64;	
	RD1 = 0;
L_LMS_Check:
	RD0 = LMS_R_24W;
	RD1 += RD0;
	RD2--;
	if(RQ_nZero)goto L_LMS_Check;
	RD0 = 0x3dee0f;
	RD0 -= RD1;
	
//Debug_Reg32 = RD0; 
	RD1 = 4*MMU_BASE;
	RSP += RD1;

#undefine EN          M[RA4+0*MMU_BASE]
#undefine RN          M[RA4+1*MMU_BASE]   //VNPOWER / 2^8
#undefine VN          M[RA0]
#undefine VNDEL       M[RA1]

Return_AutoField(0);



////////////////////////////////////////////////////////
//  ��������:
//      LMS_Test_Init
//  ��������:
//      Ԥ��LMS�˲���ϵ�������ݳ�ֵ(ȫ0)
//  ��ڲ���:
//      ��
//  ���ڲ���:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField LMS_Test_Init;
    RD0 = RN_Const_StartAddr + 3707;
    RA0 = RD0;
	LMS_DSP_SelOpCPU;
	          
	LMS_ANEX_Disable;
	RD0 =0xF1; //дMu(����ֵΪmu���ݵľ���ֵ��20������Mu=1/32=2^(-5),ʵ��д��ֵΪ 5-20=-15)
	LMS_ANEX_WMu = RD0;
	LMS_ANEX_Enable;

	RD2 = 64;
L_Set_Frist_W_LMS://Ԥ��LMSϵ��
	RD0 = M[RA0];
	LMS_W_24W = RD0;
	RA0++;
	RD2--;
	if(RQ_nZero)goto L_Set_Frist_W_LMS;

	LMS_DSP_WorkEn;//ʹ��LMS

	RD2 =64;
L_Set_Frist_D://Ԥ��LMS��H��64λ0
	RD0 = 0;
	LMS_W_16D = RD0;
	RD2--;
	if(RQ_nZero)goto L_Set_Frist_D;

	RD0 = RN_LMSRAM_START;
	RA0 = RD0;         //VN����,128Dword
	RD2 = 128;
	RD0 = 0;
L_Clr_VnBuff:
	M[RA0++] = RD0;
	RD2--;
	if(RQ_nZero) goto L_Clr_VnBuff;
		
	RD2 = 128;
	RD0 = RN_Recip_Table_ADDR;
	RA1 = RD0;
L_Set_recip:
	RD0 = M[RA1];
	M[RA0++] = RD0;
	RA1++;
	RD2--;
	if(RQ_nZero) goto L_Set_recip;	

Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  ��������:
//      CKT_GetDW
//  ��������:
//      ͬ�����н��գ�����bit��Ϊ��λ�ȷ�����
//  �������:
//      ��
//  ��������:
//      RD0 ����4λ��0��������ʱ����24λΪָ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField CKT_GetDW;
    RD0 = CKT_TX;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;    //Tx==1 �������ready

    RD3 = 32;
    RD2 = 1000*100;    //��ʱ����
    RD0 = 0x00;
L_CKT_GetDW_Loop:
	RD2 --;
	if(RQ_Zero) goto L_CKT_GetDW_TO;
	nop;
	if(RFlag_CKT_CP == 1) goto L_CKT_GetDW_Loop; //���½���
L_CKT_GetDW_Loop_L0:
	RD2 --;
	if(RQ_Zero) goto L_CKT_GetDW_TO;
	nop;
	if(RFlag_CKT_CP == 0) goto L_CKT_GetDW_Loop_L0; //��������
    RF_ShiftL1(RD0);
    if(RFlag_CKT_Rx == 0) goto L_CKT_GetDW_L1;
    RD0 ++;
L_CKT_GetDW_L1:
    RD3 --;
    if(RQ_nZero) goto L_CKT_GetDW_Loop;
    RF_Reverse(RD0);     //ת�ã�����bit��Ϊ��λ�ȷ�
    Return_AutoField(0);

L_CKT_GetDW_TO:
	RD0 = -1;
	Return_AutoField(0);


//////////////////////////////////////////////////////////////////////////
//  ��������:
//      CKT_PutDW
//  ��������:
//      ͬ�����з��ͣ���λ�ȷ�����
//  �������:
//      RD0
//  ��������:
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField CKT_PutDW;
    RD3 = 32;
    RD1 = CKT_TX;
    GPIO_WEn1 = RD1;
    RD1 = 0;
    GPIO_Data1 = RD1;    //Tx==0 ������ready
    
    RD1 = 0;
L_CKT_PutDW_Loop:
	nop; nop;
	if(RFlag_CKT_CP == 1) goto L_CKT_PutDW_Loop; //���½���
	if(RD0_Bit0 == 0) goto L_CKT_PutDW_Tx0;
	RF_Not(RD1);
L_CKT_PutDW_Tx0:
    GPIO_Data1 = RD1;
L_CKT_PutDW_L1:
	nop; nop;
	if(RFlag_CKT_CP == 0) goto L_CKT_PutDW_L1; //��������
    RF_ShiftR1(RD0);
    RD1 = 0;
    RD3 --;
    if(RQ_nZero) goto L_CKT_PutDW_Loop;
    RD2 = 1000;
    call _Delay_RD2;
    RD0 = CKT_TX;
    GPIO_Data1 = RD0;
    	
    Return_AutoField(0);


END SEGMENT
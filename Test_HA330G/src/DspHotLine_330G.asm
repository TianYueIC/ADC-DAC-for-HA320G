////////////////////////////
// DspHotLine_330G.asm for HA330G (Chip Core:HA320G)
// WENDI YANG 2021/11/29
////////////////////////////
//	Notes
//	1. ������Speed5���ã�
//	2. 
//	3. 
//	4. 
////////////////////////////

#define _DSPHOTLINE_330G_F_

#include <CPU11.def>
#include <resource_allocation.def>
#include <Global.def>
#include <RN_DSP_Cfg.def>
#include <DMA_ParaCfg.def>
#include <DspHotLine_330G.def>
#include <DMA_ALU.def>

CODE SEGMENT DspHotLine_code;




////////////////////////////////////////////////////////
//  ����:
//      DSP_HotLine_init
//  ����:
//      ��DMA���г�ʼ��
//  ����:
//      
//      
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
//HotLine #0----DMA_ParaNum_GetADC_Ave_Max_Min	
//				���ڽ�ADC FlowRAM�����ݰ��Ƶ�Gram0�У�ͬʱ����STA���㣬���ave��max��minͳ����
//HotLine #1----DMA_ParaNum_MAC_RffC
//				��GRAM0�����ݳ˳���
//HotLine #2----DMA_ParaNum_Send_DAC
//				����DAC����д��.�����λ���������룬�������ݰ��Ƶ�FlowRAM��
//HotLine #3----DMA_ParaNum_FFT128_ClrRAM
//				����FFT��RAM����(�����PRAM����)
//HotLine #4----DMA_ParaNum_MAC_Rff
//				MAC˫���г˷�
//HotLine #5----
//				
////////////////////////////////////////////////////////
Sub_AutoField DSP_HotLine_init;

//	RD0 = RN_PRAM_START;
//	RA0 = RD0;
	
L_DSP_HotLine_init_0: 
L_DSP_HotLine_init_GetADC_Ave_Max_Min://#0	���ڽ�ADC FlowRAM�����ݰ��Ƶ�Gram0�У�ͬʱ����STA���㣬���ave��max��minͳ����	
		RD0 = RN_PRAM_START+DMA_ParaNum_GetADC_Ave_Max_Min*MMU_BASE*8;
		RA0 = RD0;
		// 0*MMU_BASE: CntF+Դ��ַDW��Ĭ��ֵ��FlowBank0
		RD0 = FlowRAM_Addr0;
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0_ClrByteH8;
		RD0 -=2;
		M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
		// 1*MMU_BASE: CntW+Ŀ���ַDW��Ĭ��ֵ��GRAM0
		RD0 = RN_GRAM0;
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0 -= 2;                  //��ˮ��ǰ����д��Ч
		RD0_ClrByteH8;
		RD1 = CntFWB4_32b;          //CntW is 4
		RD0 += RD1;
		M[RA0+1*MMU_BASE] = RD0;
		// 2*MMU_BASE: CntB
		RD0 = CntFWB1_32b;          //CntB is 1
		M[RA0+2*MMU_BASE] = RD0;
		// 3*MMU_BASE: Step0    
		RD0 = 0x0C230002;//16Bit Step0
		M[RA0+3*MMU_BASE] = RD0;
		// 4*MMU_BASE: Step1  
		RD0 = 0x02020001;//Step1
		M[RA0+4*MMU_BASE] = RD0;
		// 5*MMU_BASE: Null
		RD0 = 0x00000000;//Null
		M[RA0+5*MMU_BASE] = RD0;
		// 6*MMU_BASE: Loop_Num 
		RD0 = FL_M2_A4;
		M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
		// 7*MMU_BASE: FData==== -1
		RD0 = -1;
		M[RA0+7*MMU_BASE] = RD0;
		
L_DSP_HotLine_init_1: 
L_DSP_HotLine_init_MAC_RffC://#1 ��GRAM0�����ݳ˳���
		RD0 = RN_PRAM_START+DMA_ParaNum_MAC_RffC*MMU_BASE*8;
		RA0 = RD0;
		// 0*MMU_BASE:
		M[RA0+0*MMU_BASE] = 0;            //CntF is 0
		// 1*MMU_BASE: CntW+Դ��ַDW��Ĭ��ֵ��GRAM0
		RD0 = RN_GRAM0;
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0_ClrByteH8;
		RD1 = CntFWB4_32b;          //CntW is 4
		RD0 += RD1;
		M[RA0+1*MMU_BASE] = RD0;  
		// 2*MMU_BASE: CntB+Ŀ���ַDW��Ĭ��ֵ��GRAM0
		RD0 = RN_GRAM0;
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0 -= 1;                  //��ˮ��ǰ1��д��Ч
		RD0_ClrByteH8;
		RD1 = CntFWB2_32b;          //CntB is 2
		RD0 += RD1;
		M[RA0+2*MMU_BASE] = RD0;
		// 3*MMU_BASE: Step0=1
		RD0 = 0x0C080000;//16Bit Step0
		M[RA0+3*MMU_BASE] = RD0;
		// 4*MMU_BASE: Step1  
		RD0 = 0x06040001;//Step1
		M[RA0+4*MMU_BASE] = RD0;
		// 5*MMU_BASE: Null
		RD0 = 0x00000001;//Step2
		M[RA0+5*MMU_BASE] = RD0;
		// 6*MMU_BASE: Loop_Num 
		RD0 = FL_M3_A3;
		M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
		// 7*MMU_BASE: FData==== -1
		RD0 = -1;
		M[RA0+7*MMU_BASE] = RD0;

L_DSP_HotLine_init_2: 
L_DSP_HotLine_init_Send_DAC_SignSftR_RndOff://#2	����DAC����д��.�����λ�����ݰ��Ƶ�FlowRAM��
		RD0 = RN_PRAM_START+DMA_ParaNum_Send_DAC*MMU_BASE*8;
		RA0 = RD0;
		// 0*MMU_BASE: CntF+Դ��ַDW��Ĭ��ֵ��RN_GRAM0
		RD0 = RN_GRAM0;   		
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0 --;
		RD0_ClrByteH8;
		RD1 = RD0;
		M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
		// 1*MMU_BASE: CntW+Ŀ���ַDW��Ĭ��ֵ��GRAM0
		RD0 = RN_GRAM0;
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0 -= 2;                  //��ˮ��ǰ����д��Ч
		RD0_ClrByteH8;
		RD1 = CntFWB4_32b;          //CntW is 4
		RD0 += RD1;
		M[RA0+1*MMU_BASE] = RD0;
		// 2*MMU_BASE: CntB
		RD0 = CntFWB1_32b;          //CntB is 1
		M[RA0+2*MMU_BASE] = RD0;
		// 3*MMU_BASE: Step0    
		//RD0 = 0x04130001;//16Bit Step0 //��ͳ��
		RD0 = 0x04020001;//16Bit Step0 //����ͳ��
		M[RA0+3*MMU_BASE] = RD0;
		// 4*MMU_BASE: Step1  
		RD0 = 0x02020001;//Step1
		M[RA0+4*MMU_BASE] = RD0;
		// 5*MMU_BASE: Null
		RD0 = 0x00000000;//Null
		M[RA0+5*MMU_BASE] = RD0;
		// 6*MMU_BASE: Loop_Num
		RD0 = L32_M2_A4;// 1/8��㣡
		M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
		// 7*MMU_BASE: FData==== -1
		RD0 = -1;
		M[RA0+7*MMU_BASE] = RD0;

L_DSP_HotLine_init_3: 
L_DSP_HotLine_init_FFT128_ClrRAM://#3	����FFT128��RAM����
		RD0 = RN_PRAM_START+DMA_ParaNum_FFT128_ClrRAM*MMU_BASE*8;
		RA0 = RD0;
		// 0*MMU_BASE: CntF+Դ��ַDW��Ĭ��ֵ��0
		//RD0 = FFT128RAM_Addr0;   		
		//RF_ShiftR2(RD0);           //��ΪDword��ַ
		//RD0 --;
		//RD0_ClrByteH8;
		//RD1 = RD0;
		M[RA0+0*MMU_BASE] = 0;            //CntF is 0
		// 1*MMU_BASE: CntW+Ŀ���ַDW��Ĭ��ֵ��FFT128RAM_Addr0
		RD0 = FFT128RAM_Addr0;
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0 -= 2;                  //��ˮ��ǰ����д��Ч
		RD0_ClrByteH8;
		RD1 = CntFWB4_32b;          //CntW is 4
		RD0 += RD1;
		M[RA0+1*MMU_BASE] = RD0;
		// 2*MMU_BASE: CntB
		RD0 = CntFWB1_32b;          //CntB is 1
		M[RA0+2*MMU_BASE] = RD0;
		// 3*MMU_BASE: Step0    
		RD0 = 0x04820000;//16Bit Step0,FFT����ͨ��
		M[RA0+3*MMU_BASE] = RD0;
		// 4*MMU_BASE: Step1  
		RD0 = 0x02020001;//Step1
		M[RA0+4*MMU_BASE] = RD0;
		// 5*MMU_BASE: Null
		RD0 = 0x00000000;//Null
		M[RA0+5*MMU_BASE] = RD0;
		// 6*MMU_BASE: Loop_Num 
		RD0 = L128_M2_A4;	//128Sa
		M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
		// 7*MMU_BASE: FData==== -1
		RD0 = -1;
		M[RA0+7*MMU_BASE] = RD0;

L_DSP_HotLine_init_4: 
L_DSP_HotLine_init_MAC_Rff://#4 MAC˫����,���ڼӴ�,����32DW
		RD0 = RN_PRAM_START+DMA_ParaNum_MAC_Rff*MMU_BASE*8;
		RA0 = RD0;
		// 0*MMU_BASE: CntW+Դ��ַ0 DW��Ĭ��ֵ��GRAM0
		RD0 = RN_GRAM0;
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0_ClrByteH8;
		M[RA0+0*MMU_BASE] = 0;            //CntF is 0
		// 1*MMU_BASE: CntW+Դ��ַ1 DW��Ĭ��ֵ��GRAM0
		RD0 = RN_GRAM0;
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0_ClrByteH8;
		RD1 = CntFWB4_32b;          //CntW is 4
		RD0 += RD1;
		M[RA0+1*MMU_BASE] = RD0;  
		// 2*MMU_BASE: CntB+Ŀ���ַDW��Ĭ��ֵ��GRAM0
		RD0 = RN_GRAM0;
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0 -= 1;                  //��ˮ��ǰ1��д��Ч
		RD0_ClrByteH8;
		RD1 = CntFWB2_32b;          //CntB is 2
		RD0 += RD1;
		M[RA0+2*MMU_BASE] = RD0;
		// 3*MMU_BASE: Step0=1
		RD0 = 0x04080001;//16Bit Step0
		M[RA0+3*MMU_BASE] = RD0;
		// 4*MMU_BASE: Step1  
		RD0 = 0x06040001;//Step1
		M[RA0+4*MMU_BASE] = RD0;
		// 5*MMU_BASE: Null
		RD0 = 0x00000001;//Step2
		M[RA0+5*MMU_BASE] = RD0;
		// 6*MMU_BASE: Loop_Num 
		RD0 = L32_M3_A3;
		M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
		// 7*MMU_BASE: FData==== -1
		RD0 = -1;
		M[RA0+7*MMU_BASE] = RD0;

L_DSP_HotLine_init_5: 
L_DSP_HotLine_init_FMT_Send2FFT128://#5 FMT�����У�д��FFT128 RAM����ͨ��
		RD0 = RN_PRAM_START+DMA_ParaNum_FMT_Send2FFT128*MMU_BASE*8;
		RA0 = RD0;
		// 0*MMU_BASE: CntW+Դ��ַ0 DW��Ĭ��ֵ��GRAM0
		RD0 = RN_GRAM0;
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0_ClrByteH8;
		M[RA0+0*MMU_BASE] = 0;            //CntF is 0
		// 1*MMU_BASE: CntW+Ŀ���ַDW��Ĭ��ֵ��FFT128RAM_Addr0+16*MMU_BASE
		RD0 = FFT128RAM_Addr0+16*MMU_BASE;
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0 -= 2;                  //��ˮ��
		RD0_ClrByteH8;
		RD1 = CntFWB3_32b;          //CntW is 3
		RD0 += RD1;
		M[RA0+1*MMU_BASE] = RD0;  
		// 2*MMU_BASE: CntB
		RD0 = CntFWB1_32b;          //CntB is 1
		M[RA0+2*MMU_BASE] = RD0;
		// 3*MMU_BASE: Step0=1
		RD0 = 0x04C80001;//16Bit Step0//,FFT����ͨ��
		M[RA0+3*MMU_BASE] = RD0;
		// 4*MMU_BASE: Step1  
		RD0 = 0x02020002;//Step1
		M[RA0+4*MMU_BASE] = RD0;
		// 5*MMU_BASE: Null
		RD0 = 0x00000000;//Step2
		M[RA0+5*MMU_BASE] = RD0;
		// 6*MMU_BASE: Loop_Num 
		RD0 = L32_M2_A2;
		M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
		// 7*MMU_BASE: FData==== -1
		RD0 = -1;
		M[RA0+7*MMU_BASE] = RD0;


/*/////HOTLIINE ģ��-------
L_DSP_HotLine_init_0: 
L_DSP_HotLine_init_GetADC_Ave_Max_Min://#0	���ڽ�ADC FlowRAM�����ݰ��Ƶ�Gram0�У�ͬʱ����STA���㣬���ave��max��minͳ����	
		RD0 = RN_PRAM_START+DMA_ParaNum_GetADC_Ave_Max_Min*MMU_BASE*8;
		RA0 = RD0;
		// 0*MMU_BASE: CntF+Դ��ַDW��Ĭ��ֵ��FlowBank0
		RD0 = FlowRAM_Addr0;
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0_ClrByteH8;
		RD0 -=2;
		M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
		// 1*MMU_BASE: CntW+Ŀ���ַDW��Ĭ��ֵ��GRAM0
		RD0 = RN_GRAM0;
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0 -= 2;                  //��ˮ��ǰ����д��Ч
		RD0_ClrByteH8;
		RD1 = CntFWB4_32b;          //CntW is 4
		RD0 += RD1;
		M[RA0+1*MMU_BASE] = RD0;
		// 2*MMU_BASE: CntB
		RD0 = CntFWB1_32b;          //CntB is 1
		M[RA0+2*MMU_BASE] = RD0;
		// 3*MMU_BASE: Step0    
		RD0 = 0x0C230002;//16Bit Step0
		M[RA0+3*MMU_BASE] = RD0;
		// 4*MMU_BASE: Step1  
		RD0 = 0x02020001;//Step1
		M[RA0+4*MMU_BASE] = RD0;
		// 5*MMU_BASE: Null
		RD0 = 0x00000000;//Null
		M[RA0+5*MMU_BASE] = RD0;
		// 6*MMU_BASE: Loop_Num 
		RD0 = FL_M2_A4;
		M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
		// 7*MMU_BASE: FData==== -1
		RD0 = -1;
		M[RA0+7*MMU_BASE] = RD0;
L_DSP_HotLine_init_3: 
L_DSP_HotLine_init_ALU_RFFC://#3	����ALU���������㣬������RAM����
		RD0 = RN_PRAM_START+DMA_ParaNum_ALU_RFFC*MMU_BASE*8;
		RA0 = RD0;
		// 0*MMU_BASE: CntF+Դ��ַDW��Ĭ��ֵ��FlowRAM_Addr0
		RD0 = FlowRAM_Addr0;   		
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0 --;
		RD0_ClrByteH8;
		RD1 = RD0;
		M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
		// 1*MMU_BASE: CntW+Ŀ���ַDW��Ĭ��ֵ��FlowRAM_Addr0
		RD0 = FlowRAM_Addr0;
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0 -= 2;                  //��ˮ��ǰ����д��Ч
		RD0_ClrByteH8;
		RD1 = CntFWB4_32b;          //CntW is 4
		RD0 += RD1;
		M[RA0+1*MMU_BASE] = RD0;
		// 2*MMU_BASE: CntB
		RD0 = CntFWB1_32b;          //CntB is 1
		M[RA0+2*MMU_BASE] = RD0;
		// 3*MMU_BASE: Step0    
		RD0 = 0x04020001;//16Bit Step0
		M[RA0+3*MMU_BASE] = RD0;
		// 4*MMU_BASE: Step1  
		RD0 = 0x02020001;//Step1
		M[RA0+4*MMU_BASE] = RD0;
		// 5*MMU_BASE: Null
		RD0 = 0x00000000;//Null
		M[RA0+5*MMU_BASE] = RD0;
		// 6*MMU_BASE: Loop_Num 
		RD0 = FL_M2_A4;
		M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
		// 7*MMU_BASE: FData==== -1
		RD0 = -1;
		M[RA0+7*MMU_BASE] = RD0;		
*/


		Return_AutoField(0*MMU_BASE);
		
////////////////////////////////////////////////////////
//  ����:
//      _GetADC_Ave_Max_Min
//  ����:
//      ���ڽ�ADC FlowRAM�����ݰ��Ƶ�Gram0�У�
//      ��ȥ����ֱ��ֵ��������޷�������ͬʱ����STA���㣬��ñ�֡���ݵ�ave��max��minͳ����
//  ����:
//      1.RA0:Դָ��
//      2.RA1:Ŀ��ָ��(out)
//			3.RD0:��Ҫ��RA0�м�ȥ��ֱ��ֵC���ⲿ����Ȩ�ض��룬��ƴ��ΪH16��L16��ʽ��
//  ����ֵ:
//      1.RD0��������ۼӺͣ���SUM(Xi-C),32bit�з�����
//      2.RD1�����ֵ��Vpp=Max-Min��32bit�з�����
////////////////////////////////////////////////////////
Sub_AutoField _GetADC_Ave_Max_Min;
		push RA2;
		
		// ����Group��PATH������
		MemSetPath_Enable;  //����Groupͨ��ʹ��
		M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
		M[RA1+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

		MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
		// ���ӵ�PATH1
		M[RA0] = DMA_PATH1;
		M[RA1] = DMA_PATH1;

		//����ALU����
		ALU_PATH1_CFG = Op16Bit| RffC_Sub;     //ALU1дָ��˿�//16bit �����м�������������޷�����
		ALU_PATH1_Const = RD0;     //ALU1дConst�˿�
		MemSet_Disable;     //���ý���

		//����DMA_Ctrl������������ַ.����
		//�˶δ��޸�2021/11/15 10:55:12
		RD0 = RN_PRAM_START+DMA_ParaNum_GetADC_Ave_Max_Min*MMU_BASE*8;
		RA2 = RD0;
		// 0*MMU_BASE: CntF+Դ��ַDW��Ĭ��ֵ��FlowBank0
		RD0 = RA0;//Դ��ַ0
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0 -=2;
		RD0_ClrByteH8;
		M[RA2+0*MMU_BASE] = RD0;            //CntF is 0
		// 1*MMU_BASE: CntW+Ŀ���ַDW��Ĭ��ֵ��GRAM0
		RD0 = RA1;//Ŀ���ַ
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0 -= 2;                  //��ˮ��ǰ����д��Ч
		RD0_ClrByteH8;
		RD1 = CntFWB4_32b;          //CntW is 4
		RD0 += RD1;
		M[RA2+1*MMU_BASE] = RD0;
	
		//ѡ��DMA_Ctrlͨ��������������
		//�˶δ��޸�2021/11/15 10:55:12
		ParaMem_Num = DMA_PATH1;
		ParaMem_Addr = DMA_nParaNum_GetADC_Ave_Max_Min;
		nop;nop;nop;nop;nop;nop;
		Wait_While(Flag_DMAWork==0);//�˶δ��޸�2021/11/15 10:55:12
		
		//�黹bank
		MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
		M[RA0] = DMA_PATH5;
		MemSet_Disable;     //���ý���
		
		//����STA�����VPP
		MemSetRAM4K_Enable;
		RD0 = STA1_Read;//���ֵ<31:16> | ��Сֵ<15:0>
		MemSet_Disable;
		RD2 = RD0;
		// ��ǰ֡���ֵmax
		RF_GetH16(RD0);
		RD0_SignExtL16;
		RD1 = RD0;	//max
		// ��ǰ֡��Сֵmin
		RD0 = RD2;
		RD0_SignExtL16;//min
		// RD1 =���ֵ  Vpp = max-min
		RD1 -= RD0;
		
		//����STA�����Sum(Xi-C)
		MemSetRAM4K_Enable;
		RD0 = STA1_Read;//�ۼӺ�<23:0>    
		MemSet_Disable;
		RD0_SignExtL24; //�ۼӺ�<23:0>
	
		pop RA2;
		
		Return_AutoField(0);    
		
////////////////////////////////////////////////////////
//  ����:
//      _MAC_RffC
//  ����:
//      RA0�����ݣ��˳���
//  ����:
//      1.RA0:Դָ��(in),RA0����Ϊ������16bit(�м䲻��Ҫ��0)
//      2.RA1:Ŀ��ָ��(out),������16bit
//			3.RD0:����Ϊ16bit�������з�����,H16��L16Ӧд��ͬ��ֵ(��0x7FFF7FFF).���7FFF����Ӧ��ʾ32767/32768=0.99997
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _MAC_RffC;    
		push RA2;
		
		// ����Group��PATH������
		MemSetPath_Enable;  //����Groupͨ��ʹ��
		M[RA0+MGRP_PATH2] = RD0;//ѡ��PATH2��ͨ����Ϣ��ƫַ��
		M[RA1+MGRP_PATH2] = RD0;//ѡ��PATH2��ͨ����Ϣ��ƫַ��

		MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
		// ���ӵ�PATH1
		M[RA0] = DMA_PATH2;
		M[RA1] = DMA_PATH2;

		//����MAC����
		MAC_CFG = RN_CFG_MAC_TYPE2;     //MACдָ��˿� //X[n]*CONST/32768
		MAC_Const = RD0;    //MACдConst�˿�//CONSTΪ16λ���ߵ�16λд��ͬ����
		MemSet_Disable;     //���ý���

		//����DMA_Ctrl������������ַ.����
		RD0 = RN_PRAM_START+DMA_ParaNum_MAC_RffC*MMU_BASE*8;
		RA2 = RD0;
		// 1*MMU_BASE: CntW+Դ��ַDW
		RD0 = RA0;//Դ��ַ0
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0_ClrByteH8;
		RD1 = CntFWB4_32b;          //CntW is 4
		RD0 += RD1;
		M[RA2+1*MMU_BASE] = RD0;
		// 2*MMU_BASE:
		RD0 = RA1;//Ŀ���ַ
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0 -= 1;                  //��ˮ��ǰ1��д��Ч
		RD0_ClrByteH8;
		RD1 = CntFWB2_32b;          //CntB is 2
		RD0 += RD1;
		M[RA2+2*MMU_BASE] = RD0;            //CntF is 0
	
		//ѡ��DMA_Ctrlͨ��������������
		//�˶δ��޸�2021/11/19 9:36:43
		ParaMem_Num = DMA_PATH2;
		ParaMem_Addr = DMA_nParaNum_MAC_RffC;
		nop;nop;nop;nop;nop;nop;
		Wait_While(Flag_DMAWork==0);//�˶δ��޸�2021/11/19 9:36:38
		
		pop RA2;
		Return_AutoField(0);     
		
		
////////////////////////////////////////////////////////
//  ����:
//      _Send_DAC_SignSftR_RndOff
//  ����:
//      RA0�е����ݣ�����������RD0λ���������롣������FlowRAM�У���DACʹ��
//  ����:
//      1.RA0: Դ��ַ��(in),RA0����Ϊ������16bit(�м䲻��Ҫ��0)
//      2.RA1: Ŀ���ַ(out),FlowRAM0��FlowRAM1
//      3.RD0: ȡ0ʱ��ֱ�Ӱ������ݡ�ȡ1~14ʱ��������λ�����������롣
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _Send_DAC_SignSftR_RndOff;    
		push RA2;
		RD2 = RD0;
		
		// ����Group��PATH������
		MemSetPath_Enable;  //����Groupͨ��ʹ��
		M[RA0+MGRP_PATH2] = RD0;//ѡ��PATH2��ͨ����Ϣ��ƫַ��
		M[RA1+MGRP_PATH2] = RD0;//ѡ��PATH2��ͨ����Ϣ��ƫַ��

		MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
		// ���ӵ�PATH2
		M[RA0] = DMA_PATH2;
		M[RA1] = DMA_PATH2;
		MemSet_Disable;     //���ý���
		
		//����PRAM--��ʼ��
		RD1 = RN_PRAM_START+DMA_ParaNum_Send_DAC*8*MMU_BASE;
		RA2 = RD1;
		RD0 = RA0;   		
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0 --;
		RD0_ClrByteH8;
		RD1 = RD0;
		M[RA2+0*MMU_BASE] = RD0;            //CntF is 0
	
		RD0 = RD2;
		if(RD0_nZero) goto L_ALU2_SignSftR_RndOff;
		RD0 = RA1;   		
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		//RD0 -=4;//1/4��㣡
		RD0 -=2;	//1/8��㣡
		RD0_ClrByteH8;
		RD1 = 0x75000000;          //CntW is 3
		RD0 += RD1;
		M[RA2+1*MMU_BASE] = RD0;
		//RD0 = 0x02020002;//Step1//1/4��㣡
		RD0 = 0x02020001;//Step1//1/8��㣡 TEST��
		M[RA2+4*MMU_BASE] = RD0;
		//ֻ�����ݰ���
		MemSet1_Enable;
		ALU_PATH2_CFG = Op32Bit+Rf_SftL0;     //ALU1дָ��˿�
		MemSet1_Disable;
		//ѡ��DMA_Ctrlͨ��������������
		ParaMem_Num = DMA_PATH2;
		ParaMem_Addr = DMA_nParaNum_Send_DAC;
		nop;nop;nop;nop;nop;nop;
		Wait_While(Flag_DMAWork==0);//�˶δ��޸�2021/11/25 8:59:07
		goto L_Send_DAC_END;

L_ALU2_SignSftR_RndOff:
		RD0 = RA0;   		
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0 -=2;
		RD0_ClrByteH8;
		RD1 = 0x75000000;          //CntW is 3
		RD0 += RD1;
		M[RA2+1*MMU_BASE] = RD0;
		RD0 = 0x02020001;//Step1
		M[RA2+4*MMU_BASE] = RD0;
		//׼����λ
		RD0=RD2;				//��N-1��
		RD0--;
		if(RD0_Zero) goto L_ALU2_RoundOff_SFTR;	//��λ1�Σ�������λ��
L_ALU2_SignSftR_Bit3:	
		if(RD0_Bit3 == 0) goto L_ALU2_SignSftR_Bit2;
		//����ALU���� --- ����8bit
		//MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
		MemSet1_Enable;
		ALU_PATH2_CFG = Op16Bit+Rf_SftSR8;     //ALU1дָ��˿�
		MemSet1_Disable;
		//ѡ��DMA_Ctrlͨ��������������
		ParaMem_Num = DMA_PATH2;
		ParaMem_Addr = DMA_nParaNum_Send_DAC;
		nop;nop;nop;nop;nop;nop;
		Wait_While(Flag_DMAWork==0);//�˶δ��޸�2021/11/25 8:59:07
		
L_ALU2_SignSftR_Bit2:
		if(RD0_Bit2 == 0) goto L_ALU2_SignSftR_Bit1;
		//����ALU���� --- ����4bit
		MemSet1_Enable;
		ALU_PATH2_CFG = Op16Bit+Rf_SftSR4;     //ALU1дָ��˿�
		MemSet1_Disable;
		//ѡ��DMA_Ctrlͨ��������������
		ParaMem_Num = DMA_PATH2;
		ParaMem_Addr = DMA_nParaNum_Send_DAC;
		nop;nop;nop;nop;nop;nop;
		Wait_While(Flag_DMAWork==0);//�˶δ��޸�2021/11/25 8:59:07

L_ALU2_SignSftR_Bit1:
		if(RD0_Bit1 == 0) goto L_ALU2_SignSftR_Bit0;
		//����ALU���� --- ����2bit
		MemSet1_Enable;
		ALU_PATH2_CFG = Op16Bit+Rf_SftSR2;     //ALU1дָ��˿�
		MemSet1_Disable;
		//ѡ��DMA_Ctrlͨ��������������
		ParaMem_Num = DMA_PATH2;
		ParaMem_Addr = DMA_nParaNum_Send_DAC;
		nop;nop;nop;nop;nop;nop;
		Wait_While(Flag_DMAWork==0);//�˶δ��޸�2021/11/25 8:59:07

L_ALU2_SignSftR_Bit0:
		if(RD0_Bit0 == 0) goto L_ALU2_RoundOff;
		//����ALU��������1bit
		MemSet1_Enable;
		ALU_PATH2_CFG = Op16Bit+Rf_SftSR1;     //ALU1дָ��˿�
		MemSet1_Disable;
		//ѡ��DMA_Ctrlͨ��������������
		ParaMem_Num = DMA_PATH2;
		ParaMem_Addr = DMA_nParaNum_Send_DAC;
		nop;nop;nop;nop;nop;nop;
		Wait_While(Flag_DMAWork==0);//�˶δ��޸�2021/11/25 8:59:07

L_ALU2_RoundOff:   	
L_ALU2_RoundOff_ADD1:
		//����ALU������ADD1
		MemSet1_Enable;
		ALU_PATH2_CFG = Op16Bit+RffC_Add;     //ALU1дָ��˿�
		RD0 = 0x00010001;
		ALU_PATH2_Const = RD0;     //ALU1дConst�˿�
		MemSet1_Disable;
		//ѡ��DMA_Ctrlͨ��������������
		ParaMem_Num = DMA_PATH2;
		ParaMem_Addr = DMA_nParaNum_Send_DAC;
		nop;nop;nop;nop;nop;nop;
		Wait_While(Flag_DMAWork==0);//�˶δ��޸�2021/11/25 8:59:07
	
L_ALU2_RoundOff_SFTR:	
		RD0 = RA1;   		
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		//RD0 -=4;
		RD0 -=2;	// TEST 1/8��㣡
		RD0_ClrByteH8;
		RD1 = 0x75000000;          //CntW is 3
		RD0 += RD1;
		M[RA2+1*MMU_BASE] = RD0;
		//RD0 = 0x02020002;//Step1
		RD0 = 0x02020001;//Step1 TEST 1/8��㣡
		M[RA2+4*MMU_BASE] = RD0;
		//����ALU��������1bit
		MemSet1_Enable;
		ALU_PATH2_CFG = Op16Bit+Rf_SftSR1;     //ALU1дָ��˿�
		MemSet1_Disable;    
		//ѡ��DMA_Ctrlͨ��������������
		ParaMem_Num = DMA_PATH2;
		ParaMem_Addr = DMA_nParaNum_Send_DAC;
		nop;nop;nop;nop;nop;nop;
		Wait_While(Flag_DMAWork==0);//�˶δ��޸�2021/11/25 8:59:07


L_Send_DAC_END:        
		//�黹bank
		MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
		M[RA1] = DMA_PATH5;
		MemSet_Disable;     //���ý���
		pop RA2;
		Return_AutoField(0);         



////////////////////////////////////////////////////////
//  ����:
//      _FFT_ClrRAM
//  ����:
//      FFT128RAM����
//  ����:
//      ��
//  ����ֵ:
//      ��
//	ע��:
//			��ֹ�ⲿ���ã�
//			���� FFT128 ����ʹ�ã��ڼӴ�(MAC����)ǰ���á�
//			�˳�ʱDSP Path1�������ڽ��У����������ſ���ʹ��Path1
////////////////////////////////////////////////////////
Sub_AutoField _FFT_ClrRAM;    
		RD0 = FFT128RAM_Addr0;
		RA0 = RD0;
		RD0_SetBit10;											//FFT128 Bank1
		RA1 = RD0;
		
		// ����Group��PATH������
		MemSetPath_Enable;  //����Groupͨ��ʹ��
		M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

		MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
		// ���ӵ�PATH1
		M[RA0] = DMA_PATH1;
		M[RA1] = DMA_PATH1;

		//����ALU����
		ALU_PATH1_CFG = Op32Bit| Rf_Const;     //ALU1дָ��˿� //����
		ALU_PATH1_Const = 0;     //ALU1дConst�˿�
		MemSet_Disable;     //���ý���

		//ѡ��DMA_Ctrlͨ��������������
		//�˶δ��޸�2021/11/15 10:55:12
		ParaMem_Num = DMA_PATH1;
		ParaMem_Addr = DMA_nParaNum_FFT128_ClrRAM;
		nop;nop;nop;nop;nop;nop;
		//�˴����ȴ�DSP������ɣ�Path1����ʱռ�á�
		Return_AutoField(0);  
		
////////////////////////////////////////////////////////
//  ����:
//      _MAC_Rff
//  ����:
//      ˫���г˷����̶���������
//  ����:
//      1.RA0:Դָ��0(in),������16bit
//      2.RA1:Դָ��1(in),������16bit
//			3.RA2:Ŀ��ָ��(out),������16bit
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _MAC_Rff;    
		
		// ����Group��PATH������
		MemSetPath_Enable;  //����Groupͨ��ʹ��
		M[RA0+MGRP_PATH2] = RD0;//ѡ��PATH2��ͨ����Ϣ��ƫַ��
		M[RA1+MGRP_PATH2] = RD0;//ѡ��PATH2��ͨ����Ϣ��ƫַ��
		M[RA2+MGRP_PATH2] = RD0;//ѡ��PATH2��ͨ����Ϣ��ƫַ��

		MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
		// ���ӵ�PATH1
		M[RA0] = DMA_PATH2;
		M[RA1] = DMA_PATH2;
		M[RA2] = DMA_PATH2;

		//����MAC����
		MAC_CFG = RN_CFG_MAC_TYPE0;     //MACдָ��˿� //X[n]*Y[n]
		MemSet_Disable;     //���ý���

		//����DMA_Ctrl������������ַ.����
		RD1 = RN_PRAM_START+DMA_ParaNum_MAC_Rff*MMU_BASE*8;
		RD0 = RA0;//Դ��ַ0
		RA0 = RD1;
		// 0*MMU_BASE: CntW+Դ��ַ0DW
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0_ClrByteH8;
		M[RA0+0*MMU_BASE] = RD0;
		// 1*MMU_BASE: CntW+Դ��ַ1DW
		RD0 = RA1;//Դ��ַ0
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0_ClrByteH8;
		RD1 = CntFWB4_32b;          //CntW is 4
		RD0 += RD1;
		M[RA0+1*MMU_BASE] = RD0;
		// 2*MMU_BASE:
		RD0 = RA2;//Ŀ���ַ
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0 -= 1;                  //��ˮ��ǰ1��д��Ч
		RD0_ClrByteH8;
		RD1 = CntFWB2_32b;          //CntB is 2
		RD0 += RD1;
		M[RA0+2*MMU_BASE] = RD0;            //CntF is 0
	
		//ѡ��DMA_Ctrlͨ��������������
		//�˶δ��޸�2021/11/19 9:36:43
		ParaMem_Num = DMA_PATH2;
		ParaMem_Addr = DMA_nParaNum_MAC_Rff;
		nop;nop;nop;nop;nop;nop;
		Wait_While(Flag_DMAWork==0);//�˶δ��޸�2021/11/19 9:36:38
		//�˴����ȴ�DSP������ɣ�Path2����ʱռ�á�
		
		Return_AutoField(0);     		
		
////////////////////////////////////////////////////////
//  ����:
//      _Win_FFT
//  ����:
//      FFT�Ӵ�
//  ����:
//      1.RA0:Դָ��0(in),������16bit
//      2.RA1:Դָ��1(in),������16bit
//			3.RA2:Ŀ��ָ��(out),������16bit
//  ����ֵ:
//      ��
//  ע��:
//			��ֹ�ⲿ���ã�
////////////////////////////////////////////////////////
Sub_AutoField _Win_FFT;    
		
		// ����Group��PATH������
		MemSetPath_Enable;  //����Groupͨ��ʹ��
		M[RA0+MGRP_PATH2] = RD0;//ѡ��PATH2��ͨ����Ϣ��ƫַ��
		M[RA1+MGRP_PATH2] = RD0;//ѡ��PATH2��ͨ����Ϣ��ƫַ��
		M[RA2+MGRP_PATH2] = RD0;//ѡ��PATH2��ͨ����Ϣ��ƫַ��

		MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
		// ���ӵ�PATH1
		M[RA0] = DMA_PATH2;
		M[RA1] = DMA_PATH2;
		M[RA2] = DMA_PATH2;

		//����MAC����
		MAC_CFG = RN_CFG_MAC_TYPE0;     //MACдָ��˿� //X[n]*Y[n]
		MemSet_Disable;     //���ý���

		//����DMA_Ctrl������������ַ.����
		RD1 = RN_PRAM_START+DMA_ParaNum_MAC_Rff*MMU_BASE*8;
		RD0 = RA0;//Դ��ַ0
		RA0 = RD1;
		// 0*MMU_BASE: CntW+Դ��ַ0DW
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0_ClrByteH8;
		M[RA0+0*MMU_BASE] = RD0;
		// 1*MMU_BASE: CntW+Դ��ַ1DW
		RD0 = RA1;//Դ��ַ0
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0_ClrByteH8;
		RD1 = CntFWB4_32b;          //CntW is 4
		RD0 += RD1;
		M[RA0+1*MMU_BASE] = RD0;
		// 2*MMU_BASE:
		RD0 = RA2;//Ŀ���ַ
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0 -= 1;                  //��ˮ��ǰ1��д��Ч
		RD0_ClrByteH8;
		RD1 = CntFWB2_32b;          //CntB is 2
		RD0 += RD1;
		M[RA0+2*MMU_BASE] = RD0;            //CntF is 0
	
		//ѡ��DMA_Ctrlͨ��������������
		//�˶δ��޸�2021/11/19 9:36:43
		ParaMem_Num = DMA_PATH2;
		ParaMem_Addr = DMA_nParaNum_MAC_Rff;
		nop;nop;nop;nop;nop;nop;
		//Wait_While(Flag_DMAWork==0);//�˶δ��޸�2021/11/19 9:36:38
		//�˴����ȴ�DSP������ɣ�Path2����ʱռ�á�
		
		Return_AutoField(0);     			
		
////////////////////////////////////////////////////////
//  ����:
//      _SendFFT128
//  ����:
//      ����16bit����ת��ΪFFT128���ݸ�ʽ��������FFT128Fast���㡣
//			���ݳ��ȹ̶�Ϊ32DW��ǰ��0
//			�̶������ַΪ FFT128RAM_Addr0 �� FFT128RAM_Addr1��������ַ��������ͬ����������
//  ����:
//      1.RA0:��������ָ�룬������16bit
//  ����ֵ:
//      ��
//  ע��:
//			��ֹ�ⲿ���ã�
////////////////////////////////////////////////////////
Sub_AutoField _SendFFT128;
		
    //�洢��ַ��չΪ�������鲿��0
    ////ż����ַ
    //--------------------------------------------------
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //���ò���
    RD0 = 0x2020;  			//ż�����0x2020  //�������0x1010
    FMT_CFG = RD0;     //дָ��˿�    
    MemSet_Disable;     //���ý���
    
    RD0 = RN_PRAM_START+DMA_ParaNum_FMT_Send2FFT128*MMU_BASE*8;
		RA2 = RD0;
		RD3 = RD0;
		// 0*MMU_BASE: CntW+Դ��ַ0 DW��Ĭ��ֵ��GRAM0
		RD0 = RA0;
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0_ClrByteH8;
		M[RA2+0*MMU_BASE] = RD0;            //CntF is 0
    
    RD0 = FFT128RAM_Addr0+16*MMU_BASE;//Ŀ���ַ��FFT128 Bank0
		RA1 = RD0;
		RD0_SetBit10;											//Ŀ���ַ��FFT128 Bank1
		RA2 = RD0;
    
    Wait_While(Flag_DMAWork==0);//��clrFFT����
    
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
    M[RA1+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
    M[RA2+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
    

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //������ص�4KRAM
    M[RA0] = DMA_PATH1;
    M[RA1] = DMA_PATH1;
    M[RA2] = DMA_PATH1;
    MemSet_Disable;     //���ý���

    
    //ѡ��DMA_Ctrlͨ��������������
    ParaMem_Num = DMA_PATH1;
    ParaMem_Addr = DMA_nParaNum_FMT_Send2FFT128;
    nop;nop;nop;nop;nop;nop;
		
		//---------------------------------------------------
    //������ַ
    //--------------------------------------------------
		RD0 = RD3;
		RA2 = RD0;
		RD0 = M[RA2+1*MMU_BASE];
		RD2 = RD0;	//�ݴ����ߣ������黹;		
		// 1*MMU_BASE: CntW+Ŀ���ַDW��Ĭ��ֵ��GRAM0
		RD0 = RA1;
		RD0 += MMU_BASE;//������ַ��1��ʼ
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0 -= 2;                  //��ˮ��
		RD0_ClrByteH8;
		RD1 = CntFWB3_32b;          //CntW is 3
		RD0 += RD1;
		M[RA2+1*MMU_BASE] = RD0;  		

		Wait_While(Flag_DMAWork==0);//��FMT0����
		
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //���ò���
    RD0 = 0x1010;  //ż�����0x2020  //�������0x1010
    FMT_CFG = RD0;     //ALU1дָ��˿�
    MemSet_Disable;     //���ý���
    
    //ѡ��DMA_Ctrlͨ��������������
    ParaMem_Num = DMA_PATH1;
    ParaMem_Addr = DMA_nParaNum_FMT_Send2FFT128;
    nop;nop;nop;nop;nop;nop;
		//Wait_While(Flag_DMAWork==0);//�˶δ��޸�2021/11/29 17:32:16
		
		//���߸�ԭΪż��ַ
//		RD0 = RN_PRAM_START+DMA_ParaNum_FMT_Send2FFT128*MMU_BASE*8;
//		RA2 = RD0;
		// 1*MMU_BASE: 
		RD0 = RD2;
		M[RA2+1*MMU_BASE] = RD0;  		
		
		RD0 = FFT128RAM_Addr0;
		RA0 = RD0;
		//RD0 = FFT128RAM_Addr1;
		RD0_SetBit10;											//FFT128 Bank1
		RA1 = RD0;

		Wait_While(Flag_DMAWork==0);//��FMT1����
		
		MemSetRAM4K_Enable;;   //Memory ����ʹ��
		M[RA0] = DMA_PATH5;    //                                                               ͨ��ѡ��FFTģ��ˣ�
		M[RA1] = DMA_PATH5;
		MemSet_Disable;   //���ùر�
	
		Enable_FFT_Fast128;
		Start_FFT128W;   //FFT��ʼ
		nop; nop;
		Wait_While(RFlag_FFT128End==0);

		//����λ��Ч����λ��0(��HA350B�����ӵ��Ż�����)
    MemSetRAM4K_Enable;
    RD0 = 0b0111;
    RD0 &= FFT128_GAIN;
    RD0 ++;
    MemSet_Disable;
		Disable_FFT_Fast128;
		
    
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      FFT_Fast128_HotLineRun
//  ����:
//      ���ݼӴ������FFT���㣬RD0����FFT Gain
//  ����:
//      1.RA0:���ݵ�ַ(in),������16bit������32DW
//	    2.RA1:������(in),������16bit������32DW
//			3.RA2:�ݸ�ֽ��ַ(out),������16bit������32DW
//  ����ֵ:
//      RD0��FFT128_GAIN
////////////////////////////////////////////////////////
Sub_AutoField FFT_Fast128_HotLineRun;
    
    call _FFT_ClrRAM;    
    
    RD0 = RA2;
    RD2 = RD0;
    call _Win_FFT;
    
    RD0 = RD2;
    RA0 = RD0;
    call _SendFFT128;

		Return_AutoField(0);

END SEGMENT    
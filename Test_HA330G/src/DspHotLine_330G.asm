////////////////////////////
// DspHotLine_330G.asm for HA330G (Chip Core:HA320G)
// WENDI YANG 2021/12/27 16:14:22
////////////////////////////
//	Notes
//	1. ������Speed5���á�
//	2. �������ߵĹ��̣���ע�����߳�ͻ���⣡
//      (Ŀǰ�����߱���ó�0-6�����㷨���ԡ�ͬʱʹ�����ߺ�ROM�е�DSP�������������߳�ͻ��)
//      (�ȴ������淶��������ROM��DSP����)
//	3. ������ǰ��"_"�ĺ�������ֹ�ⲿ���á�
//	4. ���߽�ֹ�����޸ġ�
//	5. δ�������ߵ�DSP������ͳһ��������ߵ�ַ���ã�����
//		//#define	DMA_ParaNum_			0b11111	//31	���ʹ�ã�Ĭ��λ�ã�
//		//#define	DMA_nParaNum_			0b00000	//31	���ʹ�ã�Ĭ��λ�ã�
//	6.
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
//		���ڽ�ADC FlowRAM�����ݰ��Ƶ�Gram0�У�ͬʱ����STA���㣬���ave��max��minͳ����
//HotLine #1----DMA_ParaNum_MAC_RffC
//		��GRAM0�����ݳ˳���
//HotLine #2----DMA_ParaNum_Send_DAC
//		����DAC����д��.�����λ���������룬�������ݰ��Ƶ�FlowRAM��
//HotLine #3----DMA_ParaNum_FFT128_ClrRAM
//		����FFT��RAM����(�����PRAM����)����ֹ�ⲿ���ã�
//HotLine #4----DMA_ParaNum_MAC_Rff
//		MAC˫���г˷�
//HotLine #5----DMA_ParaNum_FMT_Send2FFT128
//		FMT���������㣬д��FFT128 RAM����ͨ������ֹ�ⲿ���ã�
//HotLine #6----DMA_ParaNum_ALU_Send2IFFT128
//		ALU�����У���FFT���д��FFT128 RAM����ͨ������ֹ�ⲿ���ã�
//HotLine #7----DMA_ParaNum_FMT_GetH16
//		FMT��Get_Real��ȡʵ��������IFFT128����ֹ�ⲿ���ã�
//HotLine #8----DMA_ParaNum_ALU_RffC
//		ALU�����У�����IFFT��
//HotLine #9----DMA_ParaNum_SingleSerPSD
//		MAC��PSD����FFTʹ�ã���ֹ�ⲿ���ã�
//HotLine #10---DMA_ParaNum_ALU_Send2IFFT128
//		ALU˫���У�DAC��ֵ������ֹ�ⲿ���ã�
//HotLine #0-#6ʵ�ʵ�ַ����Ϊ#11-#17,���㷨���ԡ�
//HotLine #18---DMA_ParaNum_MAC_CFGLEN
//              MAC�������㣬�е����г˷���MAC_RFFC_CFGLEN
//                           ��˫���г˷���MAC_RFF_CFGLEN��
//                           ��������CFG����ģʽ��LoopNumber
//HotLine #19---DMA_ParaNum_ALU_RFF_CFGLEN
//              ALU˫�������㣬��ALU_path1����: ALU_RFF_CFGLEN
//                             ��LMT����: LMT_CFGLEN
//                             ��������CFG����ģʽ��LoopNumber
//HotLine #20---DMA_ParaNum_ALU_RFFC_CFGLEN
//              ALU�������������㣬ALU1�ϵĺ���: ALU_RFFC_CFGLEN
//                             ������CFG����ģʽ��LoopNumber
////////////////////////////////////////////////////////
// 2021/12/20 15:26:56 NOTE
// 7\8\9\18\19���޸ģ�����ע�ͣ�
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
	M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
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
	M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
	// 1*MMU_BASE: CntW+Ŀ���ַDW��Ĭ��ֵ��FFT128RAM_Addr0+32*MMU_BASE
	RD0 = FFT128RAM_Addr0+32*MMU_BASE;
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

L_DSP_HotLine_init_6:
L_DSP_HotLine_init_ALU_Send2IFFT128://#6	ALU�����У�д��FFT128 RAM����ͨ��
	RD0 = RN_PRAM_START+DMA_ParaNum_ALU_Send2IFFT128*MMU_BASE*8;
	RA0 = RD0;
	// 0*MMU_BASE: CntF+Դ��ַDW��Ĭ��ֵ��FFT128RAM_Addr0
	RD0 = FFT128RAM_Addr0;
	RF_ShiftR2(RD0);           //��ΪDword��ַ
	RD0_ClrByteH8;
	RD0 --;
	M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
	// 1*MMU_BASE: CntW+Ŀ���ַDW��Ĭ��ֵ��FFT128RAM_Addr0+127*MMU_Base
	RD0 = FFT128RAM_Addr0;
	RF_ShiftR2(RD0);           //��ΪDword��ַ
	RD1 = 129;
	RD0 += RD1;                  //��ˮ��ǰ����д��Ч
	RD0_ClrByteH8;
	RD1 = CntFWB4_32b;          //CntW is 4
	RD0 += RD1;
	M[RA0+1*MMU_BASE] = RD0;
	// 2*MMU_BASE: CntB
	RD0 = CntFWB1_32b;          //CntB is 1
	M[RA0+2*MMU_BASE] = RD0;
	// 3*MMU_BASE: Step0
	RD0 = 0x04830001;//16Bit Step0
	M[RA0+3*MMU_BASE] = RD0;
	// 4*MMU_BASE: Step1
	//RD0 = 0x02020001;//Step1
	RD0 = 0x0202FFFF;//Step1,����
	M[RA0+4*MMU_BASE] = RD0;
	// 5*MMU_BASE: Null
	RD0 = 0x00000000;//Null
	M[RA0+5*MMU_BASE] = RD0;
	// 6*MMU_BASE: Loop_Num
	RD0 = L64_M2_A4;
	M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
	// 7*MMU_BASE: FData==== -1
	RD0 = -1;
	M[RA0+7*MMU_BASE] = RD0;

L_DSP_HotLine_init_7:
L_DSP_HotLine_init_FMT_GetH16:	//#7	Get_Real��ȡʵ��
	RD0 = RN_PRAM_START+DMA_ParaNum_FMT_GetH16*MMU_BASE*8;	//���ߵ�ַ
	RA0 = RD0;						//RA0ֱ��д�룬��ѹջ
	RD0 = FFT128RAM_Addr0 + 32 * MMU_BASE;			//�����ַ��//Y(n)�׵�ַ
	RF_ShiftR2(RD0);   				//��ΪDword��ַ
	RD0 -= 1;            				//������Ӧ��ˮ��
	RD0_ClrByteH8;
	M[RA0+0*MMU_BASE] = RD0;    			//CntF is 0
	RD0 ++;
	RD0_ClrByteH8;
    RD1 = CntFWB3_32b;  				//CntW is 3
	RD0 += RD1;  						//X(n)�׵�ַ
	M[RA0+1*MMU_BASE] = RD0;
	RD0 = FFT128RAM_Addr0;   				//Z(n)�׵�ַ//����Ŀ���ַ
	RF_ShiftR2(RD0);   				//��ΪDword��ַ
	RD0 --;
	RD0_ClrByteH8;
    RD1 = CntFWB1_32b;  				//CntB is 1
	RD0 += RD1;
	M[RA0+2*MMU_BASE] = RD0;
	RD0 = 0x0C080002;//Step0
	M[RA0+3*MMU_BASE] = RD0;
	RD0 = 0x06040002;//Step1
	M[RA0+4*MMU_BASE] = RD0;
	RD0 = 0x00000001;//Step2
	M[RA0+5*MMU_BASE] = RD0;
	RD0 = -1;
	M[RA0+7*MMU_BASE] = RD0;
	RD0 = FL_M3_A3;						//�������������г���
	M[RA0+6*MMU_BASE] = RD0;  				//Loop_Num

L_DSP_HotLine_init_8:
L_DSP_HotLine_init_DMA_ParaNum_ALU_RffC:	//#8	��λ����
	RD0 = RN_PRAM_START+DMA_ParaNum_ALU_RffC*8*MMU_BASE;
	RA0 = RD0;
	RD0 = FFT128RAM_Addr0; 					//RD0 = RA0;   //X(n)�׵�ַ//RA0�׵�ַ��ʱδ֪
	RF_ShiftR2(RD0);   				//��ΪDword��ַ
	RD0 --;
	RD0_ClrByteH8;
	M[RA0+0*MMU_BASE] = RD0;    			//CntF is 0
	RD1 = CntFWB4_32b;  				//CntW is 3
	RD0 =  FFT128RAM_Addr0;
	RF_ShiftR2(RD0);
	RD0 -= 2;
	RD0_ClrByteH8;
	RD0 += RD1;
	M[RA0+1*MMU_BASE] = RD0;
	RD0 = CntFWB1_32b;  				//CntB is 1
	M[RA0+2*MMU_BASE] = RD0;
	RD0 = 0x04130001;					//Step0//RD0 = 0x0C020001;//Step0  Bit21 0~��Absͳ�� 1~����Absͳ��
	M[RA0+3*MMU_BASE] = RD0;
	RD0 = 0x02020001;					//Step1
	M[RA0+4*MMU_BASE] = RD0;
	// 5*MMU_BASE: Null
	RD0 = 0x00000000;//Null
	M[RA0+5*MMU_BASE] = RD0;
	RD0 = -1;
	M[RA0+7*MMU_BASE] = RD0;
	RD0 = L32_M2_A4;	  				//Loop_Num
	M[RA0+6*MMU_BASE] = RD0;  				//Loop_Num

L_DSP_HotLine_init_9:
L_DSP_HotLine_init_DMA_ParaNum_SingleSerPSD://#9	�����׼���
	RD0 = RN_PRAM_START+DMA_ParaNum_SingleSerPSD*MMU_BASE*8;
	RA0 = RD0;
	RD0 = RN_GRAM1;   //Y(n)�׵�ַ
	RF_ShiftR2(RD0);           //��ΪDword��ַ
	RD0_ClrByteH8;
	M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
	RD0 =  RN_GRAM1 + 64 * MMU_BASE;  //X(n)�׵�ַ
	RF_ShiftR2(RD0);           //��ΪDword��ַ
	RD0 -= 2;
	RD0_ClrByteH8;
	RD1 = CntFWB7_32b;          //CntW is 7
	RD0 += RD1;  //X(n)�׵�ַ
	M[RA0+1*MMU_BASE] = RD0;
	RD0 =  RN_GRAM1 + 64 * MMU_BASE;   //Z(n)�׵�ַ
	RF_ShiftR2(RD0);           //��ΪDword��ַ
	RD0 --;
	RD0_ClrByteH8;
	RD1 = CntFWB1_32b;          //CntB is 1
	RD0 += RD1;
	M[RA0+2*MMU_BASE] = RD0;
	RD0 = 0x0C080001;//Step0
	M[RA0+3*MMU_BASE] = RD0;
	RD0 = 0x02040001;//Step1
	M[RA0+4*MMU_BASE] = RD0;
	RD0 = 0x00000001;//Step2
	M[RA0+5*MMU_BASE] = RD0;
	RD0 = -1;
	M[RA0+7*MMU_BASE] = RD0;
//	RD0 = L32_M3_A5;
	M[RA0+6*MMU_BASE] = RD0;  //Loop_Num




L_DSP_HotLine_init_10:
L_DSP_HotLine_init_FMT_Send_DAC://#10	DAC ��ֵ����
	RD0 = RN_PRAM_START+DMA_ParaNum_FMT_Send_DAC*MMU_BASE*8;//���ߵ�ַ
	RA0 = RD0;
	// 0*MMU_BASE: CntW+Դ��ַ0 DW��Ĭ��ֵ��GRAM0
	RD0 = RN_GRAM0;
	RF_ShiftR2(RD0);           //��ΪDword��ַ
	RD0 -= 1;                    //������Ӧ��ˮ��,ǰ1����Ч
	RD0_ClrByteH8;
	M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
	// 1*MMU_BASE: CntW+Դ��ַ1 DW��Ĭ��ֵ��GRAM0(��ԭֵ)
	RD0 ++;
	RD0_ClrByteH8;
	RD1 = CntFWB3_32b;          //CntW is 3
	RD0 += RD1;
	M[RA0+1*MMU_BASE] = RD0;
	// 2*MMU_BASE: CntB+Ŀ���ַDW��Ĭ��ֵ��GRAM0+16DW
	RD0 = RN_GRAM0+16*MMU_BASE;   //Z(n)�׵�ַ//����Ŀ���ַ
	RF_ShiftR2(RD0);           //��ΪDword��ַ
	RD0 -=2;
	RD0_ClrByteH8;
	RD1 = CntFWB1_32b;          //CntB is 1
	RD0 += RD1;
	M[RA0+2*MMU_BASE] = RD0;
	// 3*MMU_BASE: Step0
	RD0 = 0x04080001;//Step0
	M[RA0+3*MMU_BASE] = RD0;
	// 4*MMU_BASE: Step1
	RD0 = 0x06040001;//Step1
	M[RA0+4*MMU_BASE] = RD0;
	// 5*MMU_BASE: Step2
	RD0 = 0x00000002;//Step2
	M[RA0+5*MMU_BASE] = RD0;
	// 6*MMU_BASE: Loop_Num
	RD0 = FL_M3_A3;//�������������г���
	M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
	// 7*MMU_BASE: FData==== -1
	RD0 = -1;
	M[RA0+7*MMU_BASE] = RD0;

L_DSP_HotLine_init_18:
L_DSP_HotLine_init_DMA_ParaNum_MAC_CFGLEN:			//#18	MAC�������㣬������CFG��LoopNUMBER
	RD0 = RN_PRAM_START+DMA_ParaNum_MAC_CFGLEN*MMU_BASE*8;
    RA0 = RD0;
    RD0 = RN_GRAM0;   					//Y(n)�׵�ַ
    RF_ShiftR2(RD0);   				//��ΪDword��ַ
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;    			//CntF is 0
    RD0 = RN_GRAM1;  					//X(n)�׵�ַ
    RF_ShiftR2(RD0);   				//��ΪDword��ַ
    RD0_ClrByteH8;
    RD1 = CntFWB3_32b;  				//CntW is 3
    RD0 += RD1;  						//X(n)�׵�ַ
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = RN_GRAM2;   					//Z(n)�׵�ַ
    RF_ShiftR2(RD0);   				//��ΪDword��ַ
    RD0 --;
    RD0_ClrByteH8;
    RD1 = CntFWB1_32b;  				//CntB is 1
    RD0 += RD1;
    M[RA0+2*MMU_BASE] = RD0;
    RD0 = 0x0C080001;					//Step0
    M[RA0+3*MMU_BASE] = RD0;
    RD0 = 0x06040001;					//Step1
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;					//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = L32_M3_A3;
    M[RA0+6*MMU_BASE] = RD0;  				//Loop_Num

L_DSP_HotLine_init_19:
L_DSP_HotLine_init_DMA_ParaNum_ALU_RFF_CFGLEN://#19	ALU1˫���У�������CFG��LoopNUMBER
	RD0 = RN_PRAM_START+DMA_ParaNum_ALU_RFF_CFGLEN*8*MMU_BASE;
    RA0 = RD0;
    //0*MMU_BASE��Դ��ַ1��
    RD0 = RN_GRAM1;
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 --;                    //������Ӧ��ˮ��
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    //1*MMU_BASE��Դ��ַ2��
    RD0 = RN_GRAM1;
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0_ClrByteH8;
    RD1 = CntFWB3_32b;          //CntW is 3
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    //2*MMU_BASE��Ŀ���ַ��
    RD0 = RN_GRAM0;
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 --;
    RD0_ClrByteH8;
    RD1 = CntFWB1_32b;          //CntB is 1
    RD0 += RD1;
    M[RA0+2*MMU_BASE] = RD0;
    RD0 = 0x0C020001;//Step0
    M[RA0+3*MMU_BASE] = RD0;
    RD0 = 0x06040001;//Step1
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    //6*MMU_BASE��LoopNumber
    RD0 = L32_M3_A4;
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num

L_DSP_HotLine_init_20:
L_DSP_HotLine_init_DMA_ParaNum_ALU_RFFC_CFGLEN://#20	ALU1�����У�������CFG��LoopNUMBER
	RD0 = RN_PRAM_START+DMA_ParaNum_ALU_RFFC_CFGLEN*8*MMU_BASE;
    RA0 = RD0;
    //0*MMU_BASE��Դ��ַ��
    RD0 = RN_GRAM0;
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 --;
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    //1*MMU_BASE��Ŀ���ַ��
    RD1 = CntFWB4_32b;          //CntW is 3
    RD0 = RN_GRAM1;
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 -= 2;
    RD0_ClrByteH8;
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = CntFWB1_32b;          //CntB is 1
    M[RA0+2*MMU_BASE] = RD0;
    RD0 = 0x0C130001;//Step0//RD0 = 0x0C020001;//Step0  Bit21 0~��Absͳ�� 1~����Absͳ��
    M[RA0+3*MMU_BASE] = RD0;
    RD0 = 0x02020001;//Step1
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    //6*MMU_BASE��LoopNumber
    RD0 = L32_M2_A4;
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num

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
//		3.RD0:��Ҫ��RA0�м�ȥ��ֱ��ֵC���ⲿ����Ȩ�ض��룬��ƴ��ΪH16��L16��ʽ��
//  ����ֵ:
//      1.RD0��������ۼӺͣ���SUM(Xi-C),32bit�з�����
//      2.RD1����ǰ֡������ֵ��32bit�з�����
//	ע�⣺
//	ADCר�ú�����bankδ�黹����ֹ�ⲿ���ã�
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
	ParaMem_Num = DMA_PATH1;
	ParaMem_Addr = DMA_nParaNum_GetADC_Ave_Max_Min;
	nop;nop;nop;nop;nop;nop;
	Wait_While(Flag_DMAWork==0);

//	//�ݲ��黹bank��SendDAC���ٹ黹Bank
//	MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
//	M[RA0] = DMA_PATH5;
//	MemSet_Disable;     //���ý���

	//����STA�����VPP
	MemSetRAM4K_Enable;
	RD0 = STA1_Read;//���ֵ<31:16> | ��Сֵ<15:0>
	MemSet_Disable;
	RD2 = RD0;
	// ��ǰ֡���ֵmax
	RF_GetH16(RD0);
	RD0_SignExtL16;
	RF_Abs(RD0);
	RD1 = RD0;
	// ��ǰ֡��Сֵmin
	RD0 = RD2;
	RD0_SignExtL16;//min
	RF_Abs(RD0);
	RD0 -= RD1;
	if(RQ_Borrow) goto L_VPP_0;
	RD1 += RD0;
L_VPP_0:
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
//      RA0�����ݣ��˳������̶�����
//  ����:
//      1.RA0:Դָ��(in),RA0����Ϊ������16bit(�м䲻��Ҫ��0)
//      2.RA1:Ŀ��ָ��(out),������16bit
//	    3.RD0:����Ϊ16bit�������з�����,H16��L16Ӧд��ͬ��ֵ(��0x7FFF7FFF).���7FFF����Ӧ��ʾ32767/32768=0.99997
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
	ParaMem_Num = DMA_PATH2;
	ParaMem_Addr = DMA_nParaNum_MAC_RffC;
	nop;nop;nop;nop;nop;nop;
	Wait_While(Flag_DMAWork==0);

	pop RA2;
	Return_AutoField(0);
	
////////////////////////////////////////////////////////
//  ����:
//      _MAC_RffC_ADC
//  ����:
//      ADCʹ�õ����г˳�����Դ��ַĿ���ַ����AD_buf���̶�����
//  ����:
//      1.RA0:Դָ��(in),RA0����Ϊ������16bit(�м䲻��Ҫ��0)
//      2.RA1:Ŀ��ָ��(out),������16bit
//	    3.RD0:����Ϊ16bit�������з�����,H16��L16Ӧд��ͬ��ֵ(��0x7FFF7FFF).���7FFF����Ӧ��ʾ32767/32768=0.99997
//  ����ֵ:
//      ��
//  ע�⣺
//	    ADCר�ú�����bankδ�黹����ֹ�ⲿ���ã�
////////////////////////////////////////////////////////
Sub_AutoField _MAC_RffC_ADC;

	push RA2;

	// ����Group��PATH������
	MemSetPath_Enable;  //����Groupͨ��ʹ��
	M[RA0+MGRP_PATH2] = RD0;//ѡ��PATH2��ͨ����Ϣ��ƫַ��

	MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
	// ���ӵ�PATH1
	M[RA0] = DMA_PATH2;

	//����MAC����
	MAC_CFG = RN_CFG_MAC_TYPE2;     //MACдָ��˿� //X[n]*CONST/32768
	MAC_Const = RD1;    //MACдConst�˿�//CONSTΪ16λ���ߵ�16λд��ͬ����
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
	RD0 = RA0;//Ŀ���ַ
	RF_ShiftR2(RD0);           //��ΪDword��ַ
	RD0 -= 2;                  //��ˮ��ǰ1��д��Ч
	RD0_ClrByteH8;
	RD1 = CntFWB2_32b;          //CntB is 2
	RD0 += RD1;
	M[RA2+2*MMU_BASE] = RD0;            //CntF is 0
	// 4*MMU_BASE: Step1
	RD0 = 0x06040002;//Step1
	M[RA2+4*MMU_BASE] = RD0;
	// 5*MMU_BASE: Null
	RD0 = 0x00000002;//Step2
	M[RA2+5*MMU_BASE] = RD0;

	//ѡ��DMA_Ctrlͨ��������������
	ParaMem_Num = DMA_PATH2;
	ParaMem_Addr = DMA_nParaNum_MAC_RffC;
	nop;nop;nop;nop;nop;nop;


	//�黹ParaMem
	// 4*MMU_BASE: Step1
	RD0 = 0x06040001;//Step1
	M[RA2+4*MMU_BASE] = RD0;
	// 5*MMU_BASE: Null
	RD0 = 0x00000001;//Step2
	M[RA2+5*MMU_BASE] = RD0;
	Wait_While(Flag_DMAWork==0);
//	//�ݲ��黹bank��SendDAC���ٹ黹Bank
//	MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
//	M[RA0] = DMA_PATH5;
//	MemSet_Disable;     //���ý���

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
//	ע�⣺
//	    DACר�ú�������ֹ�ⲿ���ã�
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
	Wait_While(Flag_DMAWork==0);
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
	RD0=RD2;	//��N-1��
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
	Wait_While(Flag_DMAWork==0);

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
	Wait_While(Flag_DMAWork==0);

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
	Wait_While(Flag_DMAWork==0);

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
	Wait_While(Flag_DMAWork==0);

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
	Wait_While(Flag_DMAWork==0);

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
	Wait_While(Flag_DMAWork==0);


L_Send_DAC_END:
	//�黹bank
	MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
	M[RA1] = DMA_PATH5;
	MemSet_Disable;     //���ý���
	pop RA2;
	Return_AutoField(0);


////////////////////////////////////////////////////////
//  ����:
//      _Send_DAC_Interpolation
//  ����:
//      ���ݲ�ֵ����DACʹ�á�
//	����Դ��ַRA0��RA1��L16_0,L16_1���ΪRA2��Data_0,H16_0,H16_1���ΪRA2��Data_1
//  ����:
//      1.RA0: Դ��ַ0(in),������16bit
//      2.RA1: Դ��ַ1(in),������16bit.��RA1==RA0ʱ,��ʵ�ֲ�ԭֵ.
//      2.RA2: Ŀ���ַ(out),������16bit,RA2�����Ժ�RA0\RA1һ�����������ַ��32DW
//  ����ֵ:
//      ��
//	ע�⣺
//	    DACר�ú�������ֹ�ⲿ���ã�2021/12/13 10:21:24
////////////////////////////////////////////////////////
Sub_AutoField _Send_DAC_Interpolation;
	RD0 = RA2;
	RD2 = RD0;

	MemSetPath_Enable;  //����Groupͨ��ʹ��
	M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
	M[RA1+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
	M[RA2+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

	MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
	//������ص�4KRAM
	M[RA0] = DMA_PATH1;//��RA0����path1
	M[RA1] = DMA_PATH1;//��RA0����path1
	M[RA2] = DMA_PATH1;//��RA0����path1

	//���ò���
	RD0 = 0x8282;//��ȡL16		//ȡ�鲿0x8282;//ȡʵ��0x4141
	FMT_CFG = RD0;     //ALU1дָ��˿�
	MemSet_Disable;     //���ý���

	RD0 = RN_PRAM_START+DMA_ParaNum_FMT_Send_DAC*MMU_BASE*8;//���ߵ�ַ
	RA2 = RD0;
	// 0*MMU_BASE: CntW+Դ��ַ0 DW��Ĭ��ֵ��GRAM0
	RD0 = RA0;
	RF_ShiftR2(RD0);           //��ΪDword��ַ
	RD0 -= 1;                    //������Ӧ��ˮ��,ǰ1����Ч
	RD0_ClrByteH8;
	M[RA2+0*MMU_BASE] = RD0;            //CntF is 0
	// 1*MMU_BASE: CntW+Դ��ַ1 DW��Ĭ��ֵ��GRAM0(��ԭֵ)
	RD0 = RA1;
	RF_ShiftR2(RD0);           //��ΪDword��ַ
	RD0_ClrByteH8;
	RD1 = 0x7a000000;          //CntW is 3
	RD0 += RD1;
	M[RA2+1*MMU_BASE] = RD0;
	// 2*MMU_BASE: CntB+Ŀ���ַDW��Ĭ��ֵ��GRAM0+16DW
	RD0 = RD2;   		//����Ŀ���ַ
	RF_ShiftR2(RD0);           //��ΪDword��ַ
	RD0 -=2;
	RD0_ClrByteH8;
	RD1 = 0x7e000000;          //CntB is 1
	RD0 += RD1;
	M[RA2+2*MMU_BASE] = RD0;

	//ѡ��DMA_Ctrlͨ��������������
	ParaMem_Num = DMA_PATH1;
	ParaMem_Addr = DMA_nParaNum_FMT_Send_DAC;
	nop;nop;nop;nop;nop;nop;

	RD0++;
	M[RA2+2*MMU_BASE] = RD0;	//FMT-H16���׵�ַ

	Wait_While(Flag_DMAWork==0);//�ȴ�FMT-L16����

	//���ò���
	MemSet1_Enable;
	RD0 = 0x4141;//ȡH16
	FMT_CFG = RD0;     //ALU1дָ��˿�
	MemSet_Disable;     //���ý���

	//ѡ��DMA_Ctrlͨ��������������
	ParaMem_Num = DMA_PATH1;
	ParaMem_Addr = DMA_nParaNum_FMT_Send_DAC;
	nop;nop;nop;nop;nop;nop;
	Wait_While(Flag_DMAWork==0);//�ȴ�FMT-H16����

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
//		��ֹ�ⲿ���ã�
//		���� FFT128 ����ʹ�ã��ڼӴ�(MAC����)ǰ���á�
//		�˳�ʱDSP Path1�������ڽ��У����������ſ���ʹ��Path1
////////////////////////////////////////////////////////
Sub_AutoField _FFT_ClrRAM;
	RD0 = FFT128RAM_Addr0;
	RA0 = RD0;
	RD0_SetBit10;			//FFT128 Bank1
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
//	    3.RA2:Ŀ��ָ��(out),������16bit
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
	ParaMem_Num = DMA_PATH2;
	ParaMem_Addr = DMA_nParaNum_MAC_Rff;
	nop;nop;nop;nop;nop;nop;
	Wait_While(Flag_DMAWork==0);

	Return_AutoField(0);

////////////////////////////////////////////////////////
//  ����:
//      _Win_FFT
//  ����:
//      FFT�Ӵ�
//  ����:
//      1.RA0:Դָ��0(in),������16bit
//      2.RA1:Դָ��1(in),������16bit
//		3.RA2:Ŀ��ָ��(out),������16bit
//  ����ֵ:
//      ��
//  ע��:
//		��ֹ�ⲿ���ã�
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
	ParaMem_Num = DMA_PATH2;
	ParaMem_Addr = DMA_nParaNum_MAC_Rff;
	nop;nop;nop;nop;nop;nop;
	//�˴����ȴ�DSP������ɣ�Path2����ʱռ�á�
	Return_AutoField(0);


////////////////////////////////////////////////////////
//  ����:
//      _Win_FFT_IFFT
//  ����:
//      FFT�Ӵ�
//  ����:
//      1.RA0:Դָ��0(in),������16bit
//      2.RA1:Դָ��1(in),������16bit
//	    3.RA2:Ŀ��ָ��(out),������16bit
//  ����ֵ:
//      ��
//  ע��:
//		��ֹ�ⲿ���ã�
////////////////////////////////////////////////////////
Sub_AutoField _Win_FFT_IFFT;
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
	MemSet_Disable;     //���ý���
	//ѡ��DMA_Ctrlͨ��������������
	ParaMem_Num = DMA_PATH2;
	ParaMem_Addr = DMA_nParaNum_MAC_Rff;
	nop;nop;nop;nop;nop;nop;
	//�˴����ȴ�DSP������ɣ�Path2����ʱռ�á�
	Return_AutoField(0);

////////////////////////////////////////////////////////
//  ����:
//      _SendFFT128
//  ����:
//      ����16bit����ת��ΪFFT128���ݸ�ʽ��������FFT128Fast���㡣
//		���ݳ��ȹ̶�Ϊ32DW��ǰ��0
//		�̶������ַΪ FFT128RAM_Addr0
//  ����:
//      1.RA0:��������ָ�룬������16bit
//  ����ֵ:
//      ��
//  ע��:
//		��ֹ�ⲿ���ã�
////////////////////////////////////////////////////////
Sub_AutoField _SendFFT128;

	//�洢��ַ��չΪ�������鲿��0
	////ż����ַ
	//--------------------------------------------------
	MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
	//���ò���
	RD0 = 0x2020;  	//ż�����0x2020  //�������0x1010
	FMT_CFG = RD0;     //дָ��˿�
	MemSet_Disable;     //���ý���

	RD0 = RN_PRAM_START+DMA_ParaNum_FMT_Send2FFT128*MMU_BASE*8;
	RA2 = RD0;
	RD3 = RD0;
	// 0*MMU_BASE: CntW+Դ��ַ0 DW
	RD0 = RA0;
	RF_ShiftR2(RD0);           //��ΪDword��ַ
	RD0_ClrByteH8;
	M[RA2+0*MMU_BASE] = RD0;            //CntF is 0

	RD0 = FFT128RAM_Addr0+32*MMU_BASE;//Ŀ���ַ��FFT128 Bank0+32*MMU_BASE
	RA1 = RD0;
	RD0_SetBit10;			//Ŀ���ַ��FFT128 Bank1
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
	//Wait_While(Flag_DMAWork==0);

	//���߸�ԭΪż��ַ

	// 1*MMU_BASE:
	RD0 = RD2;
	M[RA2+1*MMU_BASE] = RD0;

	RD0 = FFT128RAM_Addr0;
	RA0 = RD0;
	RD0_SetBit10;			//FFT128 Bank1
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
//		3.RA2:�ݸ�ֽ��ַ(out),������16bit������32DW
//  ����ֵ:
//      1.RD0��FFT128_GAIN
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

////////////////////////////////////////////////////////
//  ����:
//      _Send2IFFT128
//  ����:
//      ����IFFT���㣬����ȡ�������д��FFT128ר��RAM������FFT
//  ����:
//      1.RA0:Դָ��
//  ����ֵ:
//
////////////////////////////////////////////////////////
Sub_AutoField _Send2IFFT128;
    push RA2;
L_Send2IFFT128_Addr0_Set0:
	//(0) <0> set zero
	MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
	M[RA1] = DMA_PATH0;
	M[RA2] = DMA_PATH0;
	MemSet_Disable;     //���ý���

	CPU_WorkEnable;
	M[RA1] = 0;
	M[RA2] = 0;
	CPU_WorkDisable;

L_Send2IFFT128_Addr1to127:
	// ����Group��PATH������
	MemSetPath_Enable;  //����Groupͨ��ʹ��
	M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
	M[RA1+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

	MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
	M[RA0] = DMA_PATH1;
	M[RA1] = DMA_PATH1;
	M[RA2] = DMA_PATH1;
	//MemSet_Disable;     //���ý���

L_Send2IFFT128_Addr64to127:
	//(1) ��64:127�� Trans
	//����ALU����
	//MemSet1_Enable;
	ALU_PATH1_CFG = Op32Bit+Rf_SftL0;     //ALU1дָ��˿�
	MemSet_Disable;     //���ý���

	//����DMA_Ctrl������������ַ.����
	RD0 = RN_PRAM_START+DMA_ParaNum_ALU_Send2IFFT128*MMU_BASE*8;
	RA2 = RD0;
	// 0*MMU_BASE: CntF+Դ��ַDW��Ƶ�׵�ַ<1>
	RD0 = RA0;//Դ��ַ0
	RF_ShiftR2(RD0);           //��ΪDword��ַ
	RD0_ClrByteH8;
	M[RA2+0*MMU_BASE] = RD0;            //CntF is 0

	//ѡ��DMA_Ctrlͨ��������������
	ParaMem_Num = DMA_PATH1;
	ParaMem_Addr = DMA_nParaNum_ALU_Send2IFFT128;
	nop;nop;nop;nop;nop;nop;
	//Wait_While(Flag_DMAWork==0);//�˴����ȴ���Path1ռ��

L_Send2IFFT128_Addr1to64:
	//(2)���1:64��
	RD0 = M[RA2+4*MMU_BASE];//�޸�step1,�����ָ�;
	RD0_ClrByteL16;
	RD0++;//Setp1 ==1
	M[RA2+4*MMU_BASE] = RD0;
	RD0 = M[RA2+1*MMU_BASE];//�ݴ�Ŀ���ַ,�����ָ�;
	RD3 = RD0;
	//	// 1*MMU_BASE: CntW+Ŀ���ַDW,
	RD0 = RA1;//Ŀ���ַ,<1>
	RF_ShiftR2(RD0);           //��ΪDword��ַ
	RD0 -= 1;                  //��ˮ��ǰ����д��Ч
	RD0_ClrByteH8;
	RD1 = CntFWB4_32b;          //CntW is 4
	RD0 += RD1;
	RD2 = RD0;	//Ŀ���ַΪFFT128RAM
	RD0 = RA0;//Ŀ���ַ,<1>
	RF_ShiftR2(RD0);           //��ΪDword��ַ
	RD0 -= 1;                  //��ˮ��ǰ����д��Ч
	RD0_ClrByteH8;
	RD1 = CntFWB4_32b;          //CntW is 4
	RD1 += RD0;	//Ŀ���ַΪRA0

L_Send2IFFT128_Addr64to127_Wait:
	Wait_While(Flag_DMAWork==0);//��<64:127>����

	//�ж��Ƿ���ҪAdd1������Ŀ���ַΪRA0����FFT128RAM��
	MemSetRAM4K_Enable;
	RD0 = STA1_Read;//���ֵ<31:16> | ��Сֵ<15:0>����СֵΪ0x8000ʱ������+1��
	MemSet_Disable;     //���ý���
	if(RD0_Bit15 == 0) goto L_Send2IFFT128_Addr1to64_FlagAdd;
	RF_GetL16(RD0);
	RD0_ClrBit15;
	if(RD0_nZero) goto L_Send2IFFT128_Addr1to64_FlagAdd;
	RD0 = RD2;
	M[RA2+1*MMU_BASE] = RD0;//Ŀ���ַ��FFT
	RD1 = 0; 	//Flag,RD1==0,	����Add1
	goto L_Send2IFFT128_Addr1to64_Cal_getNot;

L_Send2IFFT128_Addr1to64_FlagAdd:
	//Flag, RD1!=0,��ҪAdd1
	M[RA2+1*MMU_BASE] = RD1;//Ŀ���ַΪRA0

L_Send2IFFT128_Addr1to64_Cal_getNot:
	//����ALU����
	MemSet1_Enable;
	ALU_PATH1_CFG = Op16Bit| RffC_Xor;     //ALU1дָ��˿�
	RD0 = 0xFFFF;
	ALU_PATH1_Const = RD0;     //ALU1дConst�˿�
	MemSet_Disable;     //���ý���

	//ѡ��DMA_Ctrlͨ��������������
	ParaMem_Num = DMA_PATH1;
	ParaMem_Addr = DMA_nParaNum_ALU_Send2IFFT128;
	nop;nop;nop;nop;nop;nop;
	//Wait_While(Flag_DMAWork==0);

	//�ж��Ƿ���Ҫ+1;
	RD0 = RD1;
	if(RD0_Zero) goto L_Send2IFFT128_Addr1to64_End;
L_Send2IFFT128_Addr1to64_Cal_Add1:
	RD0 = RD2;
	M[RA2+1*MMU_BASE] = RD0;//Ŀ���ַFFT128RAM

	Wait_While(Flag_DMAWork==0);//�ȴ�

	//����ALU����
	MemSet1_Enable;
	ALU_PATH1_CFG = Op16Bit| RffC_Add;     //ALU1дָ��˿�
	ALU_PATH1_Const = 0x1;     //ALU1дConst�˿�
	MemSet_Disable;     //���ý���

	//ѡ��DMA_Ctrlͨ��������������
	ParaMem_Num = DMA_PATH1;
	ParaMem_Addr = DMA_nParaNum_ALU_Send2IFFT128;
	nop;nop;nop;nop;nop;nop;
	//Wait_While(Flag_DMAWork==0);

L_Send2IFFT128_Addr1to64_End:
	//�黹��������
	RD0 = M[RA2+4*MMU_BASE];
	RD0_SetByteL16;
	M[RA2+4*MMU_BASE] = RD0;
	RD0 = RD3;
	M[RA2+1*MMU_BASE] = RD0;
	//�˴����ȴ�DSP������ɣ�Path1����ʱռ�á�
    pop RA2;
	Return_AutoField(0);

////////////////////////////////////////////////////////
//  ����:
//      _FMT_GetH16
//  ����:
//      ��ȡʵ��
//  ����:
//      1.RA0:��������ָ�룬��ʽ[Re | Im]
//      2.RA1:�������ָ�룬��ʽ[Re(n+1) | Re(n)](out)
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _FMT_GetH16;

	MemSetPath_Enable;  					//����Groupͨ��ʹ��
	M[RA0+MGRP_PATH1] = RD0;				//ѡ��PATH1��ͨ����Ϣ��ƫַ��

	MemSetRAM4K_Enable; 					//ʹ����չ�˿ڻ�RAM����ʱʹ��
	//���ò���
	RD0 = 0x4141;							//ȡ�鲿0x8282;//ȡʵ��0x4141
	FMT_CFG = RD0; 					//ALU1дָ��˿�

	//������ص�4KRAM
	M[RA0] = DMA_PATH1;						//��RA0����path1
	MemSet_Disable; 					//���ý���
	//����DMA_Ctrl������������ַ.����
	RD1 = RN_PRAM_START+DMA_ParaNum_FMT_GetH16*MMU_BASE*8;	//���ߵ�ַ
	RD0 = RA0;			//�����ַ��//Y(n)�׵�ַ
	RA0 = RD1;
	RF_ShiftR2(RD0);   				//��ΪDword��ַ
	RD0 -= 1;            				//������Ӧ��ˮ��
	RD0_ClrByteH8;
	M[RA0+0*MMU_BASE] = RD0;    			//CntF is 0
	RD0 ++;
	RD0_ClrByteH8;
    RD1 = CntFWB3_32b;  				//CntW is 3
	RD0 += RD1;  						//X(n)�׵�ַ
	M[RA0+1*MMU_BASE] = RD0;
	RD0 = RA1;   				//Z(n)�׵�ַ//����Ŀ���ַ
	RF_ShiftR2(RD0);   				//��ΪDword��ַ
	RD0 --;
	RD0_ClrByteH8;
    RD1 = CntFWB1_32b;  				//CntB is 1
	RD0 += RD1;
	M[RA0+2*MMU_BASE] = RD0;

	//ѡ��DMA_Ctrlͨ��������������
	ParaMem_Num = DMA_PATH1;
	ParaMem_Addr = DMA_nParaNum_FMT_GetH16;			//���ߵ�ַ
	nop;nop;nop;nop;nop;nop;
	Wait_While(Flag_DMAWork==0);
    Return_AutoField(0);

////////////////////////////////////////////////////////
//  ����:
//      _FMT_GetH16_IFFT
//  ����:
//      ��ȡʵ��
//  ����:
//      1.RA0:��������ָ�룬��ʽ[Re | Im]
//      2.RA1:�������ָ�룬��ʽ[Re(n+1) | Re(n)](out)
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _FMT_GetH16_IFFT;

	MemSetPath_Enable;  					//����Groupͨ��ʹ��
	M[RA0+MGRP_PATH1] = RD0;				//ѡ��PATH1��ͨ����Ϣ��ƫַ��

	MemSetRAM4K_Enable; 					//ʹ����չ�˿ڻ�RAM����ʱʹ��
	//������ص�4KRAM
	M[RA0] = DMA_PATH1;						//��RA0����path1
	MemSet_Disable; 					//���ý���

	//ѡ��DMA_Ctrlͨ��������������
	ParaMem_Num = DMA_PATH1;
	ParaMem_Addr = DMA_nParaNum_FMT_GetH16;			//���ߵ�ַ
	nop;nop;nop;nop;nop;nop;
	//�˴����ȴ�DSP������ɣ�Path����ʱռ�á�
    Return_AutoField(0);

////////////////////////////////////////////////////////
//  ����:
//      ALU_Shift_Qbit_16b_32DW(b:bit DW:Dword)
//  ����:
//      ����32DW��������16b������λQbitλ���㣬Q����[0,14]
//      ʹ��PATH1 ALU1
//  ����:
//      1.RA0:��������ָ��(out),ַͬд�ء�
//      2.RD0:������λ��λ��,Bit31=1���ƣ�Bit31=0����
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField ALU_Shift_Qbit_16b_32DW;
	RD2 = RD0;						//ShiftR 's Number
	//����Group
	MemSetPath_Enable;					//����Groupͨ��ʹ��
	M[RA0+MGRP_PATH1] = RD0;				//ѡ��PATH1��ͨ����Ϣ��ƫַ��//RA0ֻ��ϰ����д������ʵ������

	//������ص�4KRAM
	MemSetRAM4K_Enable; 				//ʹ����չ�˿ڻ�RAM����ʱʹ��
	M[RA0] = DMA_PATH1;
	MemSet_Disable;	 				//���ý���
	//����DMA_Ctrl������������ַ.����
	RD1 = RN_PRAM_START+DMA_ParaNum_ALU_RffC*8*MMU_BASE;
	RA1 = RD1;
	RD0 = RA0; 					//RD0 = RA0;	 //X(n)�׵�ַ//RA0�׵�ַ��ʱδ֪
	RF_ShiftR2(RD0);			 				//��ΪDword��ַ
	RD0 --;
	RD0_ClrByteH8;
	M[RA1+0*MMU_BASE] = RD0;						//CntF is 0
	RD1 = CntFWB4_32b;  				//CntW is 3
	RD0 =	RA0;
	RF_ShiftR2(RD0);
	RD0 -= 2;
	RD0_ClrByteH8;
	RD0 += RD1;
	M[RA1+1*MMU_BASE] = RD0;
	RD0 = CntFWB1_32b;  				//CntB is 1
	M[RA1+2*MMU_BASE] = RD0;

	//׼����λ
	RD0 = RD2; 							//ShiftL 's Number

	if(RD0_Bit3 == 0) goto L_ALU1_Shift_Qbit_16b_32DW_Bit2;
	//����ALU���� --- �ƶ�8bit
	//MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
	MemSet1_Enable;
	//�ж�bit��־λ��31λΪ0ʱ����
	if (RD0_Bit31==0) goto L_ShiftLeftBit3;
	ALU_PATH1_CFG = Op16Bit+Rf_SftSR8;	 		//ALU1дָ��˿�
	goto L_ShiftBit3End;
L_ShiftLeftBit3:
	ALU_PATH1_CFG = Op16Bit+Rf_SftL8;	 		//ALU1дָ��˿�
L_ShiftBit3End:
	MemSet1_Disable;
	//ѡ��DMA_Ctrlͨ��������������
	ParaMem_Num = DMA_PATH1;
	ParaMem_Addr = DMA_nParaNum_ALU_RffC;
	nop;nop;nop;nop;nop;nop;
	Wait_While(Flag_DMAWork==0);//�˴����ȴ���Path1ռ��

L_ALU1_Shift_Qbit_16b_32DW_Bit2:
	RD0 = RD2;
	if(RD0_Bit2 == 0) goto L_ALU1_Shift_Qbit_16b_32DW_Bit1;
	//����ALU���� --- �ƶ�4bit
	MemSet1_Enable;
	//�ж�bit��־λ��31λΪ0ʱ����
	if (RD0_Bit31==0) goto L_ShiftLeftBit2;
	ALU_PATH1_CFG = Op16Bit+Rf_SftSR4;	 //ALU1дָ��˿�
	goto L_ShiftBit2End;
L_ShiftLeftBit2:
	ALU_PATH1_CFG = Op16Bit+Rf_SftL4;	 //ALU1дָ��˿�
L_ShiftBit2End:
	MemSet1_Disable;
	//ѡ��DMA_Ctrlͨ��������������
	ParaMem_Num = DMA_PATH1;
	ParaMem_Addr = DMA_nParaNum_ALU_RffC;
	nop;nop;nop;nop;nop;nop;
	Wait_While(Flag_DMAWork==0);//�˴����ȴ���Path1ռ��

L_ALU1_Shift_Qbit_16b_32DW_Bit1:
	RD0 = RD2;
	if(RD0_Bit1 == 0) goto L_ALU1_Shift_Qbit_16b_32DW_Bit0;
	//����ALU���� --- �ƶ�2bit
	MemSet1_Enable;
	//�ж�bit��־λ��31λΪ0ʱ����
	if (RD0_Bit31==0) goto L_ShiftLeftBit1;
	ALU_PATH1_CFG = Op16Bit+Rf_SftSR2;	 //ALU1дָ��˿�
	goto L_ShiftBit1End;
L_ShiftLeftBit1:
	ALU_PATH1_CFG = Op16Bit+Rf_SftL2;	 //ALU1дָ��˿�
L_ShiftBit1End:
	MemSet1_Disable;
	//ѡ��DMA_Ctrlͨ��������������
	ParaMem_Num = DMA_PATH1;
	ParaMem_Addr = DMA_nParaNum_ALU_RffC;
	nop;nop;nop;nop;nop;nop;
	Wait_While(Flag_DMAWork==0);//�˴����ȴ���Path1ռ��

L_ALU1_Shift_Qbit_16b_32DW_Bit0:
	RD0 = RD2;
	if(RD0_Bit0 == 0) goto L_ALU1_Shift_Qbit_16b_32DW_End;
	//����ALU���� --- �ƶ�2bit
	MemSet1_Enable;
	//�ж�bit��־λ��31λΪ0ʱ����
	if (RD0_Bit31==0) goto L_ShiftLeftBit0;
	ALU_PATH1_CFG = Op16Bit+Rf_SftSR1;	 //ALU1дָ��˿�
	goto L_ShiftBit0End;
L_ShiftLeftBit0:
	ALU_PATH1_CFG = Op16Bit+Rf_SfAdd;	 //ALU1дָ��˿�
L_ShiftBit0End:
	MemSet1_Disable;
	//ѡ��DMA_Ctrlͨ��������������
	ParaMem_Num = DMA_PATH1;
	ParaMem_Addr = DMA_nParaNum_ALU_RffC;
	nop;nop;nop;nop;nop;nop;
	Wait_While(Flag_DMAWork==0);//�˴����ȴ���Path1ռ��

L_ALU1_Shift_Qbit_16b_32DW_End:
	Return_AutoField(0);

////////////////////////////////////////////////////////
//  ����:
//      ALU_Shift_Qbit_16b_32DW_IFFT(b:bit DW:Dword)
//  ����:
//      ����32DW��������16b������λQbitλ���㣬Q����[0,14]
//      ʹ��PATH1 ALU1
//  ����:
//      1.RA0:��������ָ��(out),ַͬд�ء�
//      2.RD0:������λ��λ��,Bit31=1���ƣ�Bit31=0����
//  ����ֵ:
//      ��
/////////////////////////////////  ///////////////////////
Sub_AutoField ALU_Shift_Qbit_16b_32DW_IFFT;
	RD2 = RD0;						//ShiftR 's Number
	//����Group
	MemSetPath_Enable;					//����Groupͨ��ʹ��
	M[RA0+MGRP_PATH1] = RD0;				//ѡ��PATH1��ͨ����Ϣ��ƫַ��//RA0ֻ��ϰ����д������ʵ������

	//������ص�4KRAM
	MemSetRAM4K_Enable; 				//ʹ����չ�˿ڻ�RAM����ʱʹ��
	M[RA0] = DMA_PATH1;
	MemSet_Disable;	 				//���ý���

	//׼����λ
	RD0 = RD2; 							//ShiftL 's Number

	if(RD0_Bit3 == 0) goto L_IFFT_ALU1_Shift_Qbit_16b_32DW_Bit2;
	//����ALU���� --- �ƶ�8bit
	//MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
	MemSet1_Enable;
	//�ж�bit��־λ��31λΪ0ʱ����
	if (RD0_Bit31==0) goto L_IFFT_ShiftLeftBit3;
	ALU_PATH1_CFG = Op16Bit+Rf_SftSR8;	 		//ALU1дָ��˿�
	goto L_IFFT_ShiftBit3End;
L_IFFT_ShiftLeftBit3:
	ALU_PATH1_CFG = Op16Bit+Rf_SftL8;	 		//ALU1дָ��˿�
L_IFFT_ShiftBit3End:
	MemSet1_Disable;
	//ѡ��DMA_Ctrlͨ��������������
	ParaMem_Num = DMA_PATH1;
	ParaMem_Addr = DMA_nParaNum_ALU_RffC;
	nop;nop;nop;nop;nop;nop;
	Wait_While(Flag_DMAWork==0);//�˴����ȴ���Path1ռ��

L_IFFT_ALU1_Shift_Qbit_16b_32DW_Bit2:
	RD0 = RD2;
	if(RD0_Bit2 == 0) goto L_IFFT_ALU1_Shift_Qbit_16b_32DW_Bit1;
	//����ALU���� --- �ƶ�4bit
	MemSet1_Enable;
	//�ж�bit��־λ��31λΪ0ʱ����
	if (RD0_Bit31==0) goto L_IFFT_ShiftLeftBit2;
	ALU_PATH1_CFG = Op16Bit+Rf_SftSR4;	 //ALU1дָ��˿�
	goto L_IFFT_ShiftBit2End;
L_IFFT_ShiftLeftBit2:
	ALU_PATH1_CFG = Op16Bit+Rf_SftL4;	 //ALU1дָ��˿�
L_IFFT_ShiftBit2End:
	MemSet1_Disable;
	//ѡ��DMA_Ctrlͨ��������������
	ParaMem_Num = DMA_PATH1;
	ParaMem_Addr = DMA_nParaNum_ALU_RffC;
    nop;nop;nop;nop;nop;nop;
	Wait_While(Flag_DMAWork==0);//�˴����ȴ���Path1ռ��

L_IFFT_ALU1_Shift_Qbit_16b_32DW_Bit1:
	RD0 = RD2;
	if(RD0_Bit1 == 0) goto L_IFFT_ALU1_Shift_Qbit_16b_32DW_Bit0;
	//����ALU���� --- �ƶ�2bit
	MemSet1_Enable;
	//�ж�bit��־λ��31λΪ0ʱ����
	if (RD0_Bit31==0) goto L_IFFT_ShiftLeftBit1;
	ALU_PATH1_CFG = Op16Bit+Rf_SftSR2;	 //ALU1дָ��˿�
	goto L_IFFT_ShiftBit1End;
L_IFFT_ShiftLeftBit1:
	ALU_PATH1_CFG = Op16Bit+Rf_SftL2;	 //ALU1дָ��˿�
L_IFFT_ShiftBit1End:
	MemSet1_Disable;
	//ѡ��DMA_Ctrlͨ��������������
	ParaMem_Num = DMA_PATH1;
	ParaMem_Addr = DMA_nParaNum_ALU_RffC;
    nop;nop;nop;nop;nop;nop;
	Wait_While(Flag_DMAWork==0);//�˴����ȴ���Path1ռ��

L_IFFT_ALU1_Shift_Qbit_16b_32DW_Bit0:
	RD0 = RD2;
	if(RD0_Bit0 == 0) goto L_IFFT_ALU1_Shift_Qbit_16b_32DW_End;
	//����ALU���� --- �ƶ�2bit
	MemSet1_Enable;
	//�ж�bit��־λ��31λΪ0ʱ����
	if (RD0_Bit31==0) goto L_IFFT_ShiftLeftBit0;
	ALU_PATH1_CFG = Op16Bit+Rf_SftSR1;	 //ALU1дָ��˿�
	goto L_IFFT_ShiftBit0End;
L_IFFT_ShiftLeftBit0:
	ALU_PATH1_CFG = Op16Bit+Rf_SfAdd;	 //ALU1дָ��˿�
L_IFFT_ShiftBit0End:
	MemSet1_Disable;
	//ѡ��DMA_Ctrlͨ��������������
	ParaMem_Num = DMA_PATH1;
	ParaMem_Addr = DMA_nParaNum_ALU_RffC;
    nop;nop;nop;nop;nop;nop;
	Wait_While(Flag_DMAWork==0);//�˴����ȴ���Path1ռ��

L_IFFT_ALU1_Shift_Qbit_16b_32DW_End:
	Return_AutoField(0);

////////////////////////////////////////////////////////
//  ����:
//      SingleSerPSD
//  ����:
//      ���������ף�REAL^2 + IM^2�������32λ��Ч
//  ����:
//      1.RA0:��������ָ�룬������ʽ
//      2.RA1:�������ָ�룬32λ������ֵ
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField SingleSerPSD;
////	push RA2;
////
////	MemSetPath_Enable;  //����Groupͨ��ʹ��
////	M[RA0+MGRP_PATH2] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
////
////	MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
////	//����ALU����
////	RD0 =RN_CFG_MAC_TYPE4;
////	MAC_CFG = RD0;     //ALU1дָ��˿�
////
////	//������ص�4KRAM
////	M[RA0] = DMA_PATH2;
////	M[RA1] = DMA_PATH2;
////	MemSet_Disable;     //���ý���
////
////	//����DMA_Ctrl������������ַ.����
////	RD0 = RN_PRAM_START+DMA_ParaNum_SingleSerPSD*MMU_BASE*8;
////	RA2 = RD0;
////	// 0*MMU_BASE: Դ��ַ RA0;
////    RD0 = RA0;
////	RF_ShiftR2(RD0);           //��ΪDword��ַ
////    RD1 = RD0;
////	RD0_ClrByteH8;
////    M[RA2+0*MMU_BASE] = RD0;            //CntF is 0
////    // 1*MMU_BASE: Դ��ַ RA0;
////    RD0 = RD1;
////	RD0 -= 2;
////	RD0_ClrByteH8;
////    RD1 = CntFWB7_32b;          //CntW is 7
////    RD0 += RD1;
////    M[RA2+1*MMU_BASE] = RD0;
////    // 2*MMU_BASE: Ŀ���ַ
////    RD0 =  RA1;
////	RF_ShiftR2(RD0);           //��ΪDword��ַ
////	RD0 --;
////	RD0_ClrByteH8;
////    RD1 = CntFWB1_32b;          //CntB is 1
////	RD0 += RD1;
////    M[RA2+2*MMU_BASE] = RD0;
////
////	//ѡ��DMA_Ctrlͨ��������������
////	ParaMem_Num = DMA_PATH2;
////	ParaMem_Addr = DMA_nParaNum_SingleSerPSD;
////	nop;nop;nop;nop;nop;nop;
////	Wait_While(Flag_DMAWork==0);
//
//    pop RA2;
	Return_AutoField(0);

/*////////////////////////////////////////////////////////
//  ����:
//      SingleSerPSD_FFT
//  ����:
//      ���������ף�REAL^2 + IM^2�������32λ��Ч
//  ����:
//      1.RA0:��������ָ�룬������ʽ
//      2.RA1:�������ָ�룬32λ������ֵ
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField SingleSerPSD_FFT;

	MemSetPath_Enable;  //����Groupͨ��ʹ��
	M[RA0+MGRP_PATH2] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

	MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
	//������ص�4KRAM
	RD0 = DMA_PATH2;
	M[RA0] = RD0;
	M[RA1] = RD0;
	MemSet_Disable;     //���ý���

	//ѡ��DMA_Ctrlͨ��������������
	ParaMem_Num = DMA_PATH2;
	ParaMem_Addr = DMA_nParaNum_SingleSerPSD;
	Wait_While(Flag_DMAWork==0);

	Return_AutoField(0);
*/


////////////////////////////////////////////////////////
//  ����:
//      IFFT_Fast128_HotLineRun
//  ����:
//      ����IFFT���㣬����ȡ����&������д��FFT128ר��RAM������FFT��
//      ȡʵ�����Ӵ����������棨�����߷�ʽʵ�֣�
//  ����:
//      1.RA0:Դָ�룬����ʹ��FFT128ר��RAM��
//	    2.RA1:��ϵ��
//	    3.RD0:��λ����
//  ����ֵ:��
////////////////////////////////////////////////////////
Sub_AutoField IFFT_Fast128_HotLineRun;
    push RA2;	//����RA2
	push RA1;	//RA1��������ϵ����ջ
	RD2 = RD0;  //�ݴ���λ

	RD0 = FFT128RAM_Addr0;
	RA1 = RD0;
	RD0_SetBit10;		//FFT128 Bank1
	RA2 = RD0;
	RD3 = RD0;

	call _Send2IFFT128;//Դ��ַRA0�ɺ�����ڸ�����Ŀ���ַΪFFT128ר��RAM

	RD0 = RD3;
	RA2 = RD0;

	Wait_While(Flag_DMAWork==0);	//�ȴ�_Send2IFFT128���

	MemSetRAM4K_Enable;   		//Memory ����ʹ��
	M[RA1] = DMA_PATH5;		//ͨ��ѡ��FFTģ��ˣ�
	M[RA2] = DMA_PATH5;
	MemSet_Disable;   		//���ùر�

	Enable_FFT_Fast128;
	Start_FFT128W;   		//FFT��ʼ
	nop; nop;

	//Get_H16������ʼ����
	//FMT PRAM����
	MemSetRAM4K_Enable; 		//ʹ����չ�˿ڻ�RAM����ʱʹ��
	//���ò���
	RD0 = 0x4141;		//ȡ�鲿0x8282;//ȡʵ��0x4141
	FMT_CFG = RD0; 		//FMTдָ��˿�
	MemSet_Disable; 		//���ý���

	//����DMA_Ctrl������������ַ.����
    RD0 = RN_PRAM_START+DMA_ParaNum_FMT_GetH16*MMU_BASE*8;	//���ߵ�ַ
    RA2 = RD0;
    //0*MMU_BASE: Դ��ַ RA0;
    RD0 = FFT128RAM_Addr0 + 32 * MMU_BASE;
	RF_ShiftR2(RD0);   	//��ΪDword��ַ
	RD0 -= 1;            	//������Ӧ��ˮ��
	RD0_ClrByteH8;
    M[RA2+0*MMU_BASE] = RD0;    			//CntF is 0
    // 1*MMU_BASE: Դ��ַ RA0;
	RD0 ++;
	RD0_ClrByteH8;
    RD1 = CntFWB3_32b;  				//CntW is 3
    RD0 += RD1;
    M[RA2+1*MMU_BASE] = RD0;
    // 2*MMU_BASE: Ŀ���ַ
    RD0 = FFT128RAM_Addr0;
	RF_ShiftR2(RD0);   	//��ΪDword��ַ
	RD0 --;
	RD0_ClrByteH8;
	RD1 = CntFWB1_32b;  				//CntB is 1
	RD0 += RD1;
	M[RA2+2*MMU_BASE] = RD0;

	Wait_While(RFlag_FFT128End==0);	//�ȴ�FFT����

	//����λ��Ч����λ��0(��HA350B�����ӵ��Ż�����)
	//��ȡFFT����
	MemSetRAM4K_Enable;
	RD0 = 0b0111;
	RD0 &= FFT128_GAIN;
	RD0 ++;
	MemSet_Disable;
	Disable_FFT_Fast128;

	//�����ƽ
	RD0 += RD2;
	RD0 -= 7;
	RD2 = RD0;		//SFT
	if(RD0_Bit31 == 0) goto L_IFFT_Fast128_HotLineRun_FMT;
	RF_Neg(RD0);		//ȡ��
	RD0_SetBIT31;		//����λ ��1�����ں�����λ�жϷ���
	RD2 = RD0;

L_IFFT_Fast128_HotLineRun_FMT:
	//FMT_GetH16
	RD0 = FFT128RAM_Addr0 + 32 * MMU_BASE;
	RA0 = RD0;
	RD0 = FFT128RAM_Addr0;
	RA1 = RD0;
	call _FMT_GetH16_IFFT;

	//MAC PRAM����
	//�Ӵ�����
	MemSetRAM4K_Enable; 		//ʹ����չ�˿ڻ�RAM����ʱʹ��
	//����MAC����
	MAC_CFG = RN_CFG_MAC_TYPE0; 	//MACдָ��˿� //X[n]*Y[n]
	MemSet_Disable; 		//���ý���

	//����DMA_Ctrl������������ַ.����
	RD0 = RN_PRAM_START+DMA_ParaNum_MAC_Rff*MMU_BASE*8;
	RA2 = RD0;
	// 0*MMU_BASE: Դ��ַ FFT128RAM_Addr0;
	RD0 = FFT128RAM_Addr0;
	RF_ShiftR2(RD0);   	//��ΪDword��ַ
	RD0_ClrByteH8;
	M[RA2+0*MMU_BASE] = RD0;
	// 1*MMU_BASE: Դ��ַ ��ϵ��
	pop RA1;	//�����Ĵ��ڶ�ջ�е�Դ��ַ
	RD0 = RA1;
	RF_ShiftR2(RD0);   	//��ΪDword��ַ
	RD0_ClrByteH8;
	RD1 = CntFWB4_32b;  	//CntW is 4
	RD0 += RD1;
	M[RA2+1*MMU_BASE] = RD0;
	// 2*MMU_BASE:Ŀ���ַFFT128RAM_Addr0
	RD0 = FFT128RAM_Addr0;
	RF_ShiftR2(RD0);   	//��ΪDword��ַ
	RD0 -= 1;          	//��ˮ��ǰ1��д��Ч
	RD0_ClrByteH8;
	RD1 = CntFWB2_32b;  	//CntB is 2
	RD0 += RD1;
	M[RA2+2*MMU_BASE] = RD0;    			//CntF is 0

	Wait_While(Flag_DMAWork==0);	//�ȴ�Get_H16��������

	RD0 = FFT128RAM_Addr0;
	RA0 = RD0;  		//���¸���ַ��Ϊ�˺��������ͨ��
	RD0 = FFT128RAM_Addr0;
	RA2 = RD0;
	call _Win_FFT_IFFT;

	//����DMA_Ctrl������������ַ.����
	//��λPRAM����ָ��
	RD0 = RN_PRAM_START+DMA_ParaNum_ALU_RffC*8*MMU_BASE;
	RA2 = RD0;
	// 0*MMU_BASE: Դ��ַ FFT128RAM_Addr0;
	RD0 = FFT128RAM_Addr0;
	RF_ShiftR2(RD0);   	//��ΪDword��ַ
	RD0 --;
	RD0_ClrByteH8;
	M[RA2+0*MMU_BASE] = RD0;    			//CntF is 0
	// 1*MMU_BASE: Դ��ַ FFT128RAM_Addr0;
	RD1 = CntFWB4_32b;  				//CntW is 3
	RD0 =  FFT128RAM_Addr0;
	RF_ShiftR2(RD0);
	RD0 -= 2;
	RD0_ClrByteH8;
	RD0 += RD1;
	M[RA2+1*MMU_BASE] = RD0;
	RD0 = CntFWB1_32b;  				//CntB is 1
	M[RA2+2*MMU_BASE] = RD0;

	// �ȴ��Ӵ���������
	Wait_While(Flag_DMAWork==0);

	// ��λ��ʼ
	RD0 = FFT128RAM_Addr0;
	RA0 = RD0;
	RD0 = RD2;		//��λλ����Bit31=1���ƣ�Bit31=0����
	call ALU_Shift_Qbit_16b_32DW_IFFT;
	Wait_While(Flag_DMAWork==0);
	pop RA2;

Return_AutoField(0);

////////////////////////////////////////////////////////
//  ����:
//      ALU_RFFC_CFGLEN
//  ����:
//      ALU���������㣬������CFG��LoopNumber
//  ����:
//      1.RA0:Դָ��
//      2.RA1:Ŀ��ָ��(out)
//		3.RD0:ָ������
//		4.RD1:LoopNumber,��Ӧ(Dword����*2)+4
//      5.RD2:Const
//  ����ֵ:
//		��
////////////////////////////////////////////////////////
Sub_AutoField ALU_RFFC_CFGLEN;
	push RA2;//RA2����PRAM���ã�ѹջ����

	// ����Group��PATH������
	MemSetPath_Enable;  //����Groupͨ��ʹ��
	M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
	M[RA1+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

	MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
	// ���ӵ�PATH1
	M[RA0] = DMA_PATH1;
	M[RA1] = DMA_PATH1;

	//����ALU����
	ALU_PATH1_CFG = RD0;     //ALUдָ��˿�,��RD0��������ֵ
	RD0 = RD2;
	ALU_PATH1_Const = RD0;     //ALUдConst�˿�
	MemSet_Disable;     //���ý���

	//����DMA_Ctrl������������ַ.����
	RD0 = RN_PRAM_START+DMA_ParaNum_ALU_RFFC_CFGLEN*8*MMU_BASE;
    RA2 = RD0;
    //6*MMU_BASE��LoopNumber
    M[RA2+6*MMU_BASE] = RD1;  //Loop_Num
    //0*MMU_BASE��Դ��ַ��RA0
    RD0 = RA0;
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 --;
    RD0_ClrByteH8;
    M[RA2+0*MMU_BASE] = RD0;            //CntF is 0
    //1*MMU_BASE��Ŀ���ַ��RA1
    RD1 = CntFWB4_32b;          //CntW is 3
    RD0 = RA1;
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 -= 2;
    RD0_ClrByteH8;
    RD0 += RD1;
    M[RA2+1*MMU_BASE] = RD0;
    RD0 = CntFWB1_32b;          //CntB is 1
    M[RA2+2*MMU_BASE] = RD0;

	//ѡ��DMA_Ctrlͨ��������������
	ParaMem_Num = DMA_PATH1;
	ParaMem_Addr = DMA_nParaNum_ALU_RFFC_CFGLEN;
	nop;nop;nop;nop;nop;nop;		//����nop�ȴ����ý���
	Wait_While(Flag_DMAWork==0);	//Wait_While�ȴ��������
	
	pop RA2;
    Return_AutoField(0);

////////////////////////////////////////////////////////
//  ����:
//      ALU_RFF_CFGLEN
//  ����:
//      ALU˫�������㣬������CFG��LoopNumber
//  ����:
//      1.RA0:��������1ָ�룬32bit��ʽ����
//      2.RA1:��������2ָ�룬32bit��ʽ����
//      3.RA2:�������ָ�룬32bit��ʽ����(out)
//      4.RD1:LoopNumber,��Ӧ(Dword����*3)+4
//		5.RD0:ָ������
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField ALU_RFF_CFGLEN;

    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
    M[RA1+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
    M[RA2+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //������ص�4KRAM
    M[RA0] = DMA_PATH1;
    M[RA1] = DMA_PATH1;
    M[RA2] = DMA_PATH1;

    RD0 = RA2;
	RD2 = RD0;			//����Ŀ���ַ

    //����ALU����
    ALU_PATH1_CFG = RD0;     //ALU1дָ��˿�,ָ������RD0
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    RD0 = RN_PRAM_START+DMA_ParaNum_ALU_RFF_CFGLEN*8*MMU_BASE;
    RA2 = RD0;
    //6*MMU_BASE��LoopNumber
    RD0 = RD1;
    M[RA2+6*MMU_BASE] = RD0;  //Loop_Num
    //0*MMU_BASE��Դ��ַ1��RA0
    RD0 = RA0;
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 --;                    //������Ӧ��ˮ��
    RD0_ClrByteH8;
    M[RA2+0*MMU_BASE] = RD0;            //CntF is 0
    //1*MMU_BASE��Դ��ַ2��RA1
    RD0 = RA1;
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0_ClrByteH8;
    RD1 = CntFWB3_32b;          //CntW is 3
    RD0 += RD1;
    M[RA2+1*MMU_BASE] = RD0;
    //2*MMU_BASE��Ŀ���ַ��pop RD0(RA2)
    RD0 = RD2;					//Ŀ���ַ������RD0
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 --;
    RD0_ClrByteH8;
    RD1 = CntFWB1_32b;          //CntB is 1
    RD0 += RD1;
    M[RA2+2*MMU_BASE] = RD0;


    //ѡ��DMA_Ctrlͨ��������������
    ParaMem_Num = DMA_PATH1;
    ParaMem_Addr = DMA_nParaNum_ALU_RFF_CFGLEN;
    nop;nop;nop;nop;nop;nop;
    Wait_While(Flag_DMAWork==0);

Return_AutoField(0);

////////////////////////////////////////////////////////
//  ����:
//      MAC_RFFC_CFGLEN
//  ����:
//      ������MAC����
//  ����:
//      1.RA0:Դָ��(in),RA0����Ϊ������16bit(�м䲻��Ҫ��0)
//      2.RA1:Ŀ��ָ��(out),������16bit
//	    3.RD0:ָ������
//  	4.RD1:Len(TimeNum)
//  	5.RD2:Constֵ
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField MAC_RFFC_CFGLEN;
	push RA2;

	// ����Group��PATH������
	MemSetPath_Enable;  		//����Groupͨ��ʹ��
	M[RA0+MGRP_PATH2] = RD0;		//ѡ��PATH2��ͨ����Ϣ��ƫַ��
	M[RA1+MGRP_PATH2] = RD0;		//ѡ��PATH2��ͨ����Ϣ��ƫַ��

	MemSetRAM4K_Enable; 		//ʹ����չ�˿ڻ�RAM����ʱʹ��
	// ���ӵ�PATH1
	M[RA0] = DMA_PATH2;
	M[RA1] = DMA_PATH2;

	//����MAC����
	MAC_CFG = RD0;
	RD0 = RD2;
	MAC_Const = RD0;		//MACдConst�˿�//CONSTΪ16λ���ߵ�16λд��ͬ����
	MemSet_Disable; 		//���ý���

	//����DMA_Ctrl������������ַ.����
	RD0 = RN_PRAM_START+DMA_ParaNum_MAC_CFGLEN*MMU_BASE*8;
	RA2 = RD0;
	// 6*MMU_BASE: Loop_Num
	M[RA2+6*MMU_BASE] = RD1;  		//Loop_Num
	// 0*MMU_BASE: Դ��ַRA0
	RD0 = RA0;
	RF_ShiftR2(RD0);   		//��ΪDword��ַ
	RD0_ClrByteH8;
	M[RA2+0*MMU_BASE] = RD0;
	// 1*MMU_BASE: Դ��ַRA1
	RD0 = RA1;
	RF_ShiftR2(RD0);   		//��ΪDword��ַ
	RD0_ClrByteH8;
	RD1 = CntFWB4_32b;  		//CntW is 4
	RD0 += RD1;
	M[RA2+1*MMU_BASE] = RD0;
	// 2*MMU_BASE:Ŀ���ַRA2
	pop RD0;
	RF_ShiftR2(RD0);   		//��ΪDword��ַ
	RD0 -= 1;      		//��ˮ��ǰ1��д��Ч
	RD0_ClrByteH8;
	RD1 = CntFWB2_32b; 		//CntB is 2
	RD0 += RD1;
	M[RA2+2*MMU_BASE] = RD0;	//CntF is 0

	//ѡ��DMA_Ctrlͨ��������������
	ParaMem_Num = DMA_PATH2;
	ParaMem_Addr = DMA_nParaNum_MAC_CFGLEN;
	nop;nop;nop;nop;nop;nop;
	Wait_While(Flag_DMAWork==0);

    pop RA2;
	Return_AutoField(0);

////////////////////////////////////////////////////////
//  ����:
//      MAC_Rff_CFGLEN
//  ����:
//      ˫����MAC����
//  ����:
//      1.RA0:Դָ��0(in),������16bit
//      2.RA1:Դָ��1(in),������16bit
//	    3.RA2:Ŀ��ָ��(out),������16bit
//	    4.RD0:ָ������
//	    5.RD1:Len(TimeNum),��Ӧ(����+1)*3
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField MAC_Rff_CFGLEN;
	RD0 = RA2;
	RD2 = RD0;			//����Ŀ���ַ
	
	// ����Group��PATH������
	MemSetPath_Enable;  		//����Groupͨ��ʹ��
	M[RA0+MGRP_PATH2] = RD0;		//ѡ��PATH2��ͨ����Ϣ��ƫַ��
	M[RA1+MGRP_PATH2] = RD0;		//ѡ��PATH2��ͨ����Ϣ��ƫַ��
	M[RA2+MGRP_PATH2] = RD0;		//ѡ��PATH2��ͨ����Ϣ��ƫַ��

	MemSetRAM4K_Enable; 		//ʹ����չ�˿ڻ�RAM����ʱʹ��
	// ���ӵ�PATH1
	M[RA0] = DMA_PATH2;
	M[RA1] = DMA_PATH2;
	M[RA2] = DMA_PATH2;

	//����MAC����
	MAC_CFG = RD0; 			//MACдָ��˿� //X[n]*Y[n]
	MemSet_Disable; 		//���ý���

	//����DMA_Ctrl������������ַ.����
	RD0 = RN_PRAM_START+DMA_ParaNum_MAC_CFGLEN*MMU_BASE*8;
	RA2 = RD0;
	// 6*MMU_BASE: Loop_Num
	M[RA2+6*MMU_BASE] = RD1;  		//Loop_Num
	// 0*MMU_BASE: Դ��ַRA0
	RD0 = RA0;
	RF_ShiftR2(RD0);   		//��ΪDword��ַ
	RD0_ClrByteH8;
	M[RA2+0*MMU_BASE] = RD0;
	// 1*MMU_BASE: Դ��ַRA1
	RD0 = RA1;
	RF_ShiftR2(RD0);   		//��ΪDword��ַ
	RD0_ClrByteH8;
	RD1 = CntFWB4_32b;  		//CntW is 4
	RD0 += RD1;
	M[RA2+1*MMU_BASE] = RD0;
	// 2*MMU_BASE:Ŀ���ַRA2
	RD0 = RD2;
	RF_ShiftR2(RD0);   		//��ΪDword��ַ
	RD0 -= 1;      		//��ˮ��ǰ1��д��Ч
	RD0_ClrByteH8;
	RD1 = CntFWB2_32b; 		//CntB is 2
	RD0 += RD1;
	M[RA2+2*MMU_BASE] = RD0;	//CntF is 0

	//ѡ��DMA_Ctrlͨ��������������
	ParaMem_Num = DMA_PATH2;
	ParaMem_Addr = DMA_nParaNum_MAC_CFGLEN;
	nop;nop;nop;nop;nop;nop;
	Wait_While(Flag_DMAWork==0);

	Return_AutoField(0);

////////////////////////////////////////////////////////
//  ����:
//      LMT_CFGLEN
//  ����:
//      LMT�������㣨�޷���16bit��
//  ����:
//      1.RA0:��������1ָ�룬32bit��ʽ����
//      2.RA1:��������2ָ�룬32bit��ʽ����
//      3.RA2:�������ָ�룬32bit��ʽ����(out)
//      4.RD1:TimerNumֵ = (����Dword����*3)+4
// 	  	5.RD0:ָ�����ͣ�0Ϊ�ӷ���1Ϊ����
//	����ֵ��
//      ��
////////////////////////////////////////////////////////
Sub_AutoField LMT_CFGLEN;
    RD0 = RA2;
	RD2 = RD0;			//����Ŀ���ַ

    MemSetPath_Enable;
		//����Groupͨ��ʹ��
    M[RA0+MGRP_PATH3] = RD0;				//ѡ��PATH3��ͨ����Ϣ��ƫַ��
    M[RA1+MGRP_PATH3] = RD0;				//ѡ��PATH3��ͨ����Ϣ��ƫַ��
    M[RA2+MGRP_PATH3] = RD0;				//ѡ��PATH3��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; 		//ʹ����չ�˿ڻ�RAM����ʱʹ��
    //������ص�4KRAM
    M[RA0] = DMA_PATH3;
    M[RA1] = DMA_PATH3;
    M[RA2] = DMA_PATH3;

    //����ALU����
    LMT_CFG = RD0; 					//ALU3дָ��˿�
    MemSet_Disable; 					//���ý���

        //����DMA_Ctrl������������ַ.����
    RD0 = RN_PRAM_START+DMA_ParaNum_ALU_RFF_CFGLEN*8*MMU_BASE;
    RA2 = RD0;
    //6*MMU_BASE��LoopNumber
    RD0 = RD1;
    M[RA2+6*MMU_BASE] = RD0;  //Loop_Num
    //0*MMU_BASE��Դ��ַ1��RA0
    RD0 = RA0;
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 --;                    //������Ӧ��ˮ��
    RD0_ClrByteH8;
    M[RA2+0*MMU_BASE] = RD0;            //CntF is 0
    //1*MMU_BASE��Դ��ַ2��RA1
    RD0 = RA1;
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0_ClrByteH8;
    RD1 = CntFWB3_32b;          //CntW is 3
    RD0 += RD1;
    M[RA2+1*MMU_BASE] = RD0;
    //2*MMU_BASE��Ŀ���ַ��pop RD0(RA2)
    RD0 = RD2;					//Ŀ���ַ������RD0
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 --;
    RD0_ClrByteH8;
    RD1 = CntFWB1_32b;          //CntB is 1
    RD0 += RD1;
    M[RA2+2*MMU_BASE] = RD0;

    //ѡ��DMA_Ctrlͨ��������������
    ParaMem_Num = DMA_PATH3;
    ParaMem_Addr = DMA_nParaNum_ALU_RFF_CFGLEN;
    nop;nop;nop;nop;nop;nop;
    Wait_While(Flag_DMAWork==0);

    Return_AutoField(0);


/*�ɰ汾��IFFT��ֱ���˳�
Sub_AutoField IFFT_Fast128_HotLineRun;
	push RA2;

	RD0 = FFT128RAM_Addr0;
	RA1 = RD0;
	RD0_SetBit10;			//FFT128 Bank1
	RA2 = RD0;
	RD3 = RD0;

	call _Send2IFFT128;

	RD0 = RD3;
	RA2 = RD0;

	Wait_While(Flag_DMAWork==0);//�ȴ�_Send2IFFT128���

	MemSetRAM4K_Enable;;   //Memory ����ʹ��
	M[RA1] = DMA_PATH5;    //                                                               ͨ��ѡ��FFTģ��ˣ�
	M[RA2] = DMA_PATH5;
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

	pop RA2;
	Return_AutoField(0);
	*/

END SEGMENT
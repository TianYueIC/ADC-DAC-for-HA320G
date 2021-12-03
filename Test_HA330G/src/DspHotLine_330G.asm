////////////////////////////
// DspHotLine_330G.asm for HA330G (Chip Core:HA320G)
// WENDI YANG 2021/11/29
////////////////////////////
//	Notes
//	1. 必须在Speed5调用！
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
//  名称:
//      DSP_HotLine_init
//  功能:
//      对DMA进行初始化
//  参数:
//      
//      
//  返回值:
//      无
////////////////////////////////////////////////////////
//HotLine #0----DMA_ParaNum_GetADC_Ave_Max_Min	
//				用于将ADC FlowRAM的数据搬移到Gram0中，同时进行STA运算，获得ave，max，min统计量
//HotLine #1----DMA_ParaNum_MAC_RffC
//				将GRAM0的数据乘常数
//HotLine #2----DMA_ParaNum_Send_DAC
//				用于DAC数据写回.完成移位、四舍五入，并将数据搬移到FlowRAM中
//HotLine #3----DMA_ParaNum_FFT128_ClrRAM
//				用于FFT的RAM清零(无需改PRAM配置)
//HotLine #4----DMA_ParaNum_MAC_Rff
//				MAC双序列乘法
//HotLine #5----
//				
////////////////////////////////////////////////////////
Sub_AutoField DSP_HotLine_init;

//	RD0 = RN_PRAM_START;
//	RA0 = RD0;
	
L_DSP_HotLine_init_0: 
L_DSP_HotLine_init_GetADC_Ave_Max_Min://#0	用于将ADC FlowRAM的数据搬移到Gram0中，同时进行STA运算，获得ave，max，min统计量	
		RD0 = RN_PRAM_START+DMA_ParaNum_GetADC_Ave_Max_Min*MMU_BASE*8;
		RA0 = RD0;
		// 0*MMU_BASE: CntF+源地址DW，默认值：FlowBank0
		RD0 = FlowRAM_Addr0;
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0_ClrByteH8;
		RD0 -=2;
		M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
		// 1*MMU_BASE: CntW+目标地址DW，默认值：GRAM0
		RD0 = RN_GRAM0;
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0 -= 2;                  //流水线前两次写无效
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
L_DSP_HotLine_init_MAC_RffC://#1 将GRAM0的数据乘常数
		RD0 = RN_PRAM_START+DMA_ParaNum_MAC_RffC*MMU_BASE*8;
		RA0 = RD0;
		// 0*MMU_BASE:
		M[RA0+0*MMU_BASE] = 0;            //CntF is 0
		// 1*MMU_BASE: CntW+源地址DW，默认值：GRAM0
		RD0 = RN_GRAM0;
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0_ClrByteH8;
		RD1 = CntFWB4_32b;          //CntW is 4
		RD0 += RD1;
		M[RA0+1*MMU_BASE] = RD0;  
		// 2*MMU_BASE: CntB+目标地址DW，默认值：GRAM0
		RD0 = RN_GRAM0;
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0 -= 1;                  //流水线前1次写无效
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
L_DSP_HotLine_init_Send_DAC_SignSftR_RndOff://#2	用于DAC数据写回.完成移位、数据搬移到FlowRAM中
		RD0 = RN_PRAM_START+DMA_ParaNum_Send_DAC*MMU_BASE*8;
		RA0 = RD0;
		// 0*MMU_BASE: CntF+源地址DW，默认值：RN_GRAM0
		RD0 = RN_GRAM0;   		
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0 --;
		RD0_ClrByteH8;
		RD1 = RD0;
		M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
		// 1*MMU_BASE: CntW+目标地址DW，默认值：GRAM0
		RD0 = RN_GRAM0;
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0 -= 2;                  //流水线前两次写无效
		RD0_ClrByteH8;
		RD1 = CntFWB4_32b;          //CntW is 4
		RD0 += RD1;
		M[RA0+1*MMU_BASE] = RD0;
		// 2*MMU_BASE: CntB
		RD0 = CntFWB1_32b;          //CntB is 1
		M[RA0+2*MMU_BASE] = RD0;
		// 3*MMU_BASE: Step0    
		//RD0 = 0x04130001;//16Bit Step0 //带统计
		RD0 = 0x04020001;//16Bit Step0 //不带统计
		M[RA0+3*MMU_BASE] = RD0;
		// 4*MMU_BASE: Step1  
		RD0 = 0x02020001;//Step1
		M[RA0+4*MMU_BASE] = RD0;
		// 5*MMU_BASE: Null
		RD0 = 0x00000000;//Null
		M[RA0+5*MMU_BASE] = RD0;
		// 6*MMU_BASE: Loop_Num
		RD0 = L32_M2_A4;// 1/8抽点！
		M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
		// 7*MMU_BASE: FData==== -1
		RD0 = -1;
		M[RA0+7*MMU_BASE] = RD0;

L_DSP_HotLine_init_3: 
L_DSP_HotLine_init_FFT128_ClrRAM://#3	用于FFT128的RAM清零
		RD0 = RN_PRAM_START+DMA_ParaNum_FFT128_ClrRAM*MMU_BASE*8;
		RA0 = RD0;
		// 0*MMU_BASE: CntF+源地址DW，默认值：0
		//RD0 = FFT128RAM_Addr0;   		
		//RF_ShiftR2(RD0);           //变为Dword地址
		//RD0 --;
		//RD0_ClrByteH8;
		//RD1 = RD0;
		M[RA0+0*MMU_BASE] = 0;            //CntF is 0
		// 1*MMU_BASE: CntW+目标地址DW，默认值：FFT128RAM_Addr0
		RD0 = FFT128RAM_Addr0;
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0 -= 2;                  //流水线前两次写无效
		RD0_ClrByteH8;
		RD1 = CntFWB4_32b;          //CntW is 4
		RD0 += RD1;
		M[RA0+1*MMU_BASE] = RD0;
		// 2*MMU_BASE: CntB
		RD0 = CntFWB1_32b;          //CntB is 1
		M[RA0+2*MMU_BASE] = RD0;
		// 3*MMU_BASE: Step0    
		RD0 = 0x04820000;//16Bit Step0,FFT特殊通道
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
L_DSP_HotLine_init_MAC_Rff://#4 MAC双序列,用于加窗,长度32DW
		RD0 = RN_PRAM_START+DMA_ParaNum_MAC_Rff*MMU_BASE*8;
		RA0 = RD0;
		// 0*MMU_BASE: CntW+源地址0 DW，默认值：GRAM0
		RD0 = RN_GRAM0;
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0_ClrByteH8;
		M[RA0+0*MMU_BASE] = 0;            //CntF is 0
		// 1*MMU_BASE: CntW+源地址1 DW，默认值：GRAM0
		RD0 = RN_GRAM0;
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0_ClrByteH8;
		RD1 = CntFWB4_32b;          //CntW is 4
		RD0 += RD1;
		M[RA0+1*MMU_BASE] = RD0;  
		// 2*MMU_BASE: CntB+目标地址DW，默认值：GRAM0
		RD0 = RN_GRAM0;
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0 -= 1;                  //流水线前1次写无效
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
L_DSP_HotLine_init_FMT_Send2FFT128://#5 FMT单序列，写入FFT128 RAM特殊通道
		RD0 = RN_PRAM_START+DMA_ParaNum_FMT_Send2FFT128*MMU_BASE*8;
		RA0 = RD0;
		// 0*MMU_BASE: CntW+源地址0 DW，默认值：GRAM0
		RD0 = RN_GRAM0;
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0_ClrByteH8;
		M[RA0+0*MMU_BASE] = 0;            //CntF is 0
		// 1*MMU_BASE: CntW+目标地址DW，默认值：FFT128RAM_Addr0+16*MMU_BASE
		RD0 = FFT128RAM_Addr0+16*MMU_BASE;
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0 -= 2;                  //流水线
		RD0_ClrByteH8;
		RD1 = CntFWB3_32b;          //CntW is 3
		RD0 += RD1;
		M[RA0+1*MMU_BASE] = RD0;  
		// 2*MMU_BASE: CntB
		RD0 = CntFWB1_32b;          //CntB is 1
		M[RA0+2*MMU_BASE] = RD0;
		// 3*MMU_BASE: Step0=1
		RD0 = 0x04C80001;//16Bit Step0//,FFT特殊通道
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


/*/////HOTLIINE 模板-------
L_DSP_HotLine_init_0: 
L_DSP_HotLine_init_GetADC_Ave_Max_Min://#0	用于将ADC FlowRAM的数据搬移到Gram0中，同时进行STA运算，获得ave，max，min统计量	
		RD0 = RN_PRAM_START+DMA_ParaNum_GetADC_Ave_Max_Min*MMU_BASE*8;
		RA0 = RD0;
		// 0*MMU_BASE: CntF+源地址DW，默认值：FlowBank0
		RD0 = FlowRAM_Addr0;
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0_ClrByteH8;
		RD0 -=2;
		M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
		// 1*MMU_BASE: CntW+目标地址DW，默认值：GRAM0
		RD0 = RN_GRAM0;
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0 -= 2;                  //流水线前两次写无效
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
L_DSP_HotLine_init_ALU_RFFC://#3	用于ALU单序列运算，可用于RAM清零
		RD0 = RN_PRAM_START+DMA_ParaNum_ALU_RFFC*MMU_BASE*8;
		RA0 = RD0;
		// 0*MMU_BASE: CntF+源地址DW，默认值：FlowRAM_Addr0
		RD0 = FlowRAM_Addr0;   		
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0 --;
		RD0_ClrByteH8;
		RD1 = RD0;
		M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
		// 1*MMU_BASE: CntW+目标地址DW，默认值：FlowRAM_Addr0
		RD0 = FlowRAM_Addr0;
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0 -= 2;                  //流水线前两次写无效
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
//  名称:
//      _GetADC_Ave_Max_Min
//  功能:
//      用于将ADC FlowRAM的数据搬移到Gram0中，
//      减去给定直流值（结果不限幅！），同时进行STA运算，获得本帧数据的ave，max，min统计量
//  参数:
//      1.RA0:源指针
//      2.RA1:目标指针(out)
//			3.RD0:需要从RA0中减去的直流值C（外部进行权重对齐，并拼凑为H16、L16格式）
//  返回值:
//      1.RD0：结果的累加和，即SUM(Xi-C),32bit有符号数
//      2.RD1：峰峰值，Vpp=Max-Min，32bit有符号数
////////////////////////////////////////////////////////
Sub_AutoField _GetADC_Ave_Max_Min;
		push RA2;
		
		// 设置Group与PATH的连接
		MemSetPath_Enable;  //设置Group通道使能
		M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上
		M[RA1+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上

		MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
		// 连接到PATH1
		M[RA0] = DMA_PATH1;
		M[RA1] = DMA_PATH1;

		//配置ALU参数
		ALU_PATH1_CFG = Op16Bit| RffC_Sub;     //ALU1写指令端口//16bit 单序列减常数（结果无限幅！）
		ALU_PATH1_Const = RD0;     //ALU1写Const端口
		MemSet_Disable;     //配置结束

		//配置DMA_Ctrl参数，包括地址.长度
		//此段待修改2021/11/15 10:55:12
		RD0 = RN_PRAM_START+DMA_ParaNum_GetADC_Ave_Max_Min*MMU_BASE*8;
		RA2 = RD0;
		// 0*MMU_BASE: CntF+源地址DW，默认值：FlowBank0
		RD0 = RA0;//源地址0
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0 -=2;
		RD0_ClrByteH8;
		M[RA2+0*MMU_BASE] = RD0;            //CntF is 0
		// 1*MMU_BASE: CntW+目标地址DW，默认值：GRAM0
		RD0 = RA1;//目标地址
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0 -= 2;                  //流水线前两次写无效
		RD0_ClrByteH8;
		RD1 = CntFWB4_32b;          //CntW is 4
		RD0 += RD1;
		M[RA2+1*MMU_BASE] = RD0;
	
		//选择DMA_Ctrl通道，并启动运算
		//此段待修改2021/11/15 10:55:12
		ParaMem_Num = DMA_PATH1;
		ParaMem_Addr = DMA_nParaNum_GetADC_Ave_Max_Min;
		nop;nop;nop;nop;nop;nop;
		Wait_While(Flag_DMAWork==0);//此段待修改2021/11/15 10:55:12
		
		//归还bank
		MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
		M[RA0] = DMA_PATH5;
		MemSet_Disable;     //配置结束
		
		//读回STA结果，VPP
		MemSetRAM4K_Enable;
		RD0 = STA1_Read;//最大值<31:16> | 最小值<15:0>
		MemSet_Disable;
		RD2 = RD0;
		// 当前帧最大值max
		RF_GetH16(RD0);
		RD0_SignExtL16;
		RD1 = RD0;	//max
		// 当前帧最小值min
		RD0 = RD2;
		RD0_SignExtL16;//min
		// RD1 =峰峰值  Vpp = max-min
		RD1 -= RD0;
		
		//读回STA结果，Sum(Xi-C)
		MemSetRAM4K_Enable;
		RD0 = STA1_Read;//累加和<23:0>    
		MemSet_Disable;
		RD0_SignExtL24; //累加和<23:0>
	
		pop RA2;
		
		Return_AutoField(0);    
		
////////////////////////////////////////////////////////
//  名称:
//      _MAC_RffC
//  功能:
//      RA0的数据，乘常数
//  参数:
//      1.RA0:源指针(in),RA0数据为紧凑型16bit(中间不需要插0)
//      2.RA1:目标指针(out),紧凑型16bit
//			3.RD0:常数为16bit紧凑型有符号数,H16、L16应写相同的值(如0x7FFF7FFF).最大7FFF，对应表示32767/32768=0.99997
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _MAC_RffC;    
		push RA2;
		
		// 设置Group与PATH的连接
		MemSetPath_Enable;  //设置Group通道使能
		M[RA0+MGRP_PATH2] = RD0;//选择PATH2，通道信息在偏址上
		M[RA1+MGRP_PATH2] = RD0;//选择PATH2，通道信息在偏址上

		MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
		// 连接到PATH1
		M[RA0] = DMA_PATH2;
		M[RA1] = DMA_PATH2;

		//配置MAC参数
		MAC_CFG = RN_CFG_MAC_TYPE2;     //MAC写指令端口 //X[n]*CONST/32768
		MAC_Const = RD0;    //MAC写Const端口//CONST为16位，高低16位写相同数据
		MemSet_Disable;     //配置结束

		//配置DMA_Ctrl参数，包括地址.长度
		RD0 = RN_PRAM_START+DMA_ParaNum_MAC_RffC*MMU_BASE*8;
		RA2 = RD0;
		// 1*MMU_BASE: CntW+源地址DW
		RD0 = RA0;//源地址0
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0_ClrByteH8;
		RD1 = CntFWB4_32b;          //CntW is 4
		RD0 += RD1;
		M[RA2+1*MMU_BASE] = RD0;
		// 2*MMU_BASE:
		RD0 = RA1;//目标地址
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0 -= 1;                  //流水线前1次写无效
		RD0_ClrByteH8;
		RD1 = CntFWB2_32b;          //CntB is 2
		RD0 += RD1;
		M[RA2+2*MMU_BASE] = RD0;            //CntF is 0
	
		//选择DMA_Ctrl通道，并启动运算
		//此段待修改2021/11/19 9:36:43
		ParaMem_Num = DMA_PATH2;
		ParaMem_Addr = DMA_nParaNum_MAC_RffC;
		nop;nop;nop;nop;nop;nop;
		Wait_While(Flag_DMAWork==0);//此段待修改2021/11/19 9:36:38
		
		pop RA2;
		Return_AutoField(0);     
		
		
////////////////////////////////////////////////////////
//  名称:
//      _Send_DAC_SignSftR_RndOff
//  功能:
//      RA0中的数据，带符号右移RD0位，四舍五入。结果存放FlowRAM中，供DAC使用
//  参数:
//      1.RA0: 源地址，(in),RA0数据为紧凑型16bit(中间不需要插0)
//      2.RA1: 目标地址(out),FlowRAM0或FlowRAM1
//      3.RD0: 取0时，直接搬移数据。取1~14时，进行移位，并四舍五入。
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _Send_DAC_SignSftR_RndOff;    
		push RA2;
		RD2 = RD0;
		
		// 设置Group与PATH的连接
		MemSetPath_Enable;  //设置Group通道使能
		M[RA0+MGRP_PATH2] = RD0;//选择PATH2，通道信息在偏址上
		M[RA1+MGRP_PATH2] = RD0;//选择PATH2，通道信息在偏址上

		MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
		// 连接到PATH2
		M[RA0] = DMA_PATH2;
		M[RA1] = DMA_PATH2;
		MemSet_Disable;     //配置结束
		
		//配置PRAM--初始化
		RD1 = RN_PRAM_START+DMA_ParaNum_Send_DAC*8*MMU_BASE;
		RA2 = RD1;
		RD0 = RA0;   		
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0 --;
		RD0_ClrByteH8;
		RD1 = RD0;
		M[RA2+0*MMU_BASE] = RD0;            //CntF is 0
	
		RD0 = RD2;
		if(RD0_nZero) goto L_ALU2_SignSftR_RndOff;
		RD0 = RA1;   		
		RF_ShiftR2(RD0);           //变为Dword地址
		//RD0 -=4;//1/4抽点！
		RD0 -=2;	//1/8抽点！
		RD0_ClrByteH8;
		RD1 = 0x75000000;          //CntW is 3
		RD0 += RD1;
		M[RA2+1*MMU_BASE] = RD0;
		//RD0 = 0x02020002;//Step1//1/4抽点！
		RD0 = 0x02020001;//Step1//1/8抽点！ TEST！
		M[RA2+4*MMU_BASE] = RD0;
		//只做数据搬移
		MemSet1_Enable;
		ALU_PATH2_CFG = Op32Bit+Rf_SftL0;     //ALU1写指令端口
		MemSet1_Disable;
		//选择DMA_Ctrl通道，并启动运算
		ParaMem_Num = DMA_PATH2;
		ParaMem_Addr = DMA_nParaNum_Send_DAC;
		nop;nop;nop;nop;nop;nop;
		Wait_While(Flag_DMAWork==0);//此段待修改2021/11/25 8:59:07
		goto L_Send_DAC_END;

L_ALU2_SignSftR_RndOff:
		RD0 = RA0;   		
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0 -=2;
		RD0_ClrByteH8;
		RD1 = 0x75000000;          //CntW is 3
		RD0 += RD1;
		M[RA2+1*MMU_BASE] = RD0;
		RD0 = 0x02020001;//Step1
		M[RA2+4*MMU_BASE] = RD0;
		//准备移位
		RD0=RD2;				//移N-1次
		RD0--;
		if(RD0_Zero) goto L_ALU2_RoundOff_SFTR;	//移位1次，不做舍位。
L_ALU2_SignSftR_Bit3:	
		if(RD0_Bit3 == 0) goto L_ALU2_SignSftR_Bit2;
		//配置ALU参数 --- 右移8bit
		//MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
		MemSet1_Enable;
		ALU_PATH2_CFG = Op16Bit+Rf_SftSR8;     //ALU1写指令端口
		MemSet1_Disable;
		//选择DMA_Ctrl通道，并启动运算
		ParaMem_Num = DMA_PATH2;
		ParaMem_Addr = DMA_nParaNum_Send_DAC;
		nop;nop;nop;nop;nop;nop;
		Wait_While(Flag_DMAWork==0);//此段待修改2021/11/25 8:59:07
		
L_ALU2_SignSftR_Bit2:
		if(RD0_Bit2 == 0) goto L_ALU2_SignSftR_Bit1;
		//配置ALU参数 --- 右移4bit
		MemSet1_Enable;
		ALU_PATH2_CFG = Op16Bit+Rf_SftSR4;     //ALU1写指令端口
		MemSet1_Disable;
		//选择DMA_Ctrl通道，并启动运算
		ParaMem_Num = DMA_PATH2;
		ParaMem_Addr = DMA_nParaNum_Send_DAC;
		nop;nop;nop;nop;nop;nop;
		Wait_While(Flag_DMAWork==0);//此段待修改2021/11/25 8:59:07

L_ALU2_SignSftR_Bit1:
		if(RD0_Bit1 == 0) goto L_ALU2_SignSftR_Bit0;
		//配置ALU参数 --- 右移2bit
		MemSet1_Enable;
		ALU_PATH2_CFG = Op16Bit+Rf_SftSR2;     //ALU1写指令端口
		MemSet1_Disable;
		//选择DMA_Ctrl通道，并启动运算
		ParaMem_Num = DMA_PATH2;
		ParaMem_Addr = DMA_nParaNum_Send_DAC;
		nop;nop;nop;nop;nop;nop;
		Wait_While(Flag_DMAWork==0);//此段待修改2021/11/25 8:59:07

L_ALU2_SignSftR_Bit0:
		if(RD0_Bit0 == 0) goto L_ALU2_RoundOff;
		//配置ALU参数右移1bit
		MemSet1_Enable;
		ALU_PATH2_CFG = Op16Bit+Rf_SftSR1;     //ALU1写指令端口
		MemSet1_Disable;
		//选择DMA_Ctrl通道，并启动运算
		ParaMem_Num = DMA_PATH2;
		ParaMem_Addr = DMA_nParaNum_Send_DAC;
		nop;nop;nop;nop;nop;nop;
		Wait_While(Flag_DMAWork==0);//此段待修改2021/11/25 8:59:07

L_ALU2_RoundOff:   	
L_ALU2_RoundOff_ADD1:
		//配置ALU参数，ADD1
		MemSet1_Enable;
		ALU_PATH2_CFG = Op16Bit+RffC_Add;     //ALU1写指令端口
		RD0 = 0x00010001;
		ALU_PATH2_Const = RD0;     //ALU1写Const端口
		MemSet1_Disable;
		//选择DMA_Ctrl通道，并启动运算
		ParaMem_Num = DMA_PATH2;
		ParaMem_Addr = DMA_nParaNum_Send_DAC;
		nop;nop;nop;nop;nop;nop;
		Wait_While(Flag_DMAWork==0);//此段待修改2021/11/25 8:59:07
	
L_ALU2_RoundOff_SFTR:	
		RD0 = RA1;   		
		RF_ShiftR2(RD0);           //变为Dword地址
		//RD0 -=4;
		RD0 -=2;	// TEST 1/8抽点！
		RD0_ClrByteH8;
		RD1 = 0x75000000;          //CntW is 3
		RD0 += RD1;
		M[RA2+1*MMU_BASE] = RD0;
		//RD0 = 0x02020002;//Step1
		RD0 = 0x02020001;//Step1 TEST 1/8抽点！
		M[RA2+4*MMU_BASE] = RD0;
		//配置ALU参数右移1bit
		MemSet1_Enable;
		ALU_PATH2_CFG = Op16Bit+Rf_SftSR1;     //ALU1写指令端口
		MemSet1_Disable;    
		//选择DMA_Ctrl通道，并启动运算
		ParaMem_Num = DMA_PATH2;
		ParaMem_Addr = DMA_nParaNum_Send_DAC;
		nop;nop;nop;nop;nop;nop;
		Wait_While(Flag_DMAWork==0);//此段待修改2021/11/25 8:59:07


L_Send_DAC_END:        
		//归还bank
		MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
		M[RA1] = DMA_PATH5;
		MemSet_Disable;     //配置结束
		pop RA2;
		Return_AutoField(0);         



////////////////////////////////////////////////////////
//  名称:
//      _FFT_ClrRAM
//  功能:
//      FFT128RAM清零
//  参数:
//      无
//  返回值:
//      无
//	注意:
//			禁止外部调用！
//			仅供 FFT128 清零使用，在加窗(MAC运算)前调用。
//			退出时DSP Path1进程仍在进行，清零结束后才可以使用Path1
////////////////////////////////////////////////////////
Sub_AutoField _FFT_ClrRAM;    
		RD0 = FFT128RAM_Addr0;
		RA0 = RD0;
		RD0_SetBit10;											//FFT128 Bank1
		RA1 = RD0;
		
		// 设置Group与PATH的连接
		MemSetPath_Enable;  //设置Group通道使能
		M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上

		MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
		// 连接到PATH1
		M[RA0] = DMA_PATH1;
		M[RA1] = DMA_PATH1;

		//配置ALU参数
		ALU_PATH1_CFG = Op32Bit| Rf_Const;     //ALU1写指令端口 //常数
		ALU_PATH1_Const = 0;     //ALU1写Const端口
		MemSet_Disable;     //配置结束

		//选择DMA_Ctrl通道，并启动运算
		//此段待修改2021/11/15 10:55:12
		ParaMem_Num = DMA_PATH1;
		ParaMem_Addr = DMA_nParaNum_FFT128_ClrRAM;
		nop;nop;nop;nop;nop;nop;
		//此处不等待DSP运算完成，Path1被临时占用。
		Return_AutoField(0);  
		
////////////////////////////////////////////////////////
//  名称:
//      _MAC_Rff
//  功能:
//      双序列乘法，固定长度序列
//  参数:
//      1.RA0:源指针0(in),紧凑型16bit
//      2.RA1:源指针1(in),紧凑型16bit
//			3.RA2:目标指针(out),紧凑型16bit
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _MAC_Rff;    
		
		// 设置Group与PATH的连接
		MemSetPath_Enable;  //设置Group通道使能
		M[RA0+MGRP_PATH2] = RD0;//选择PATH2，通道信息在偏址上
		M[RA1+MGRP_PATH2] = RD0;//选择PATH2，通道信息在偏址上
		M[RA2+MGRP_PATH2] = RD0;//选择PATH2，通道信息在偏址上

		MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
		// 连接到PATH1
		M[RA0] = DMA_PATH2;
		M[RA1] = DMA_PATH2;
		M[RA2] = DMA_PATH2;

		//配置MAC参数
		MAC_CFG = RN_CFG_MAC_TYPE0;     //MAC写指令端口 //X[n]*Y[n]
		MemSet_Disable;     //配置结束

		//配置DMA_Ctrl参数，包括地址.长度
		RD1 = RN_PRAM_START+DMA_ParaNum_MAC_Rff*MMU_BASE*8;
		RD0 = RA0;//源地址0
		RA0 = RD1;
		// 0*MMU_BASE: CntW+源地址0DW
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0_ClrByteH8;
		M[RA0+0*MMU_BASE] = RD0;
		// 1*MMU_BASE: CntW+源地址1DW
		RD0 = RA1;//源地址0
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0_ClrByteH8;
		RD1 = CntFWB4_32b;          //CntW is 4
		RD0 += RD1;
		M[RA0+1*MMU_BASE] = RD0;
		// 2*MMU_BASE:
		RD0 = RA2;//目标地址
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0 -= 1;                  //流水线前1次写无效
		RD0_ClrByteH8;
		RD1 = CntFWB2_32b;          //CntB is 2
		RD0 += RD1;
		M[RA0+2*MMU_BASE] = RD0;            //CntF is 0
	
		//选择DMA_Ctrl通道，并启动运算
		//此段待修改2021/11/19 9:36:43
		ParaMem_Num = DMA_PATH2;
		ParaMem_Addr = DMA_nParaNum_MAC_Rff;
		nop;nop;nop;nop;nop;nop;
		Wait_While(Flag_DMAWork==0);//此段待修改2021/11/19 9:36:38
		//此处不等待DSP运算完成，Path2被临时占用。
		
		Return_AutoField(0);     		
		
////////////////////////////////////////////////////////
//  名称:
//      _Win_FFT
//  功能:
//      FFT加窗
//  参数:
//      1.RA0:源指针0(in),紧凑型16bit
//      2.RA1:源指针1(in),紧凑型16bit
//			3.RA2:目标指针(out),紧凑型16bit
//  返回值:
//      无
//  注意:
//			禁止外部调用！
////////////////////////////////////////////////////////
Sub_AutoField _Win_FFT;    
		
		// 设置Group与PATH的连接
		MemSetPath_Enable;  //设置Group通道使能
		M[RA0+MGRP_PATH2] = RD0;//选择PATH2，通道信息在偏址上
		M[RA1+MGRP_PATH2] = RD0;//选择PATH2，通道信息在偏址上
		M[RA2+MGRP_PATH2] = RD0;//选择PATH2，通道信息在偏址上

		MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
		// 连接到PATH1
		M[RA0] = DMA_PATH2;
		M[RA1] = DMA_PATH2;
		M[RA2] = DMA_PATH2;

		//配置MAC参数
		MAC_CFG = RN_CFG_MAC_TYPE0;     //MAC写指令端口 //X[n]*Y[n]
		MemSet_Disable;     //配置结束

		//配置DMA_Ctrl参数，包括地址.长度
		RD1 = RN_PRAM_START+DMA_ParaNum_MAC_Rff*MMU_BASE*8;
		RD0 = RA0;//源地址0
		RA0 = RD1;
		// 0*MMU_BASE: CntW+源地址0DW
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0_ClrByteH8;
		M[RA0+0*MMU_BASE] = RD0;
		// 1*MMU_BASE: CntW+源地址1DW
		RD0 = RA1;//源地址0
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0_ClrByteH8;
		RD1 = CntFWB4_32b;          //CntW is 4
		RD0 += RD1;
		M[RA0+1*MMU_BASE] = RD0;
		// 2*MMU_BASE:
		RD0 = RA2;//目标地址
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0 -= 1;                  //流水线前1次写无效
		RD0_ClrByteH8;
		RD1 = CntFWB2_32b;          //CntB is 2
		RD0 += RD1;
		M[RA0+2*MMU_BASE] = RD0;            //CntF is 0
	
		//选择DMA_Ctrl通道，并启动运算
		//此段待修改2021/11/19 9:36:43
		ParaMem_Num = DMA_PATH2;
		ParaMem_Addr = DMA_nParaNum_MAC_Rff;
		nop;nop;nop;nop;nop;nop;
		//Wait_While(Flag_DMAWork==0);//此段待修改2021/11/19 9:36:38
		//此处不等待DSP运算完成，Path2被临时占用。
		
		Return_AutoField(0);     			
		
////////////////////////////////////////////////////////
//  名称:
//      _SendFFT128
//  功能:
//      紧凑16bit数据转换为FFT128数据格式，并启动FFT128Fast运算。
//			数据长度固定为32DW，前后补0
//			固定输出地址为 FFT128RAM_Addr0 和 FFT128RAM_Addr1（两个地址上留有相同的运算结果）
//  参数:
//      1.RA0:输入序列指针，紧凑型16bit
//  返回值:
//      无
//  注意:
//			禁止外部调用！
////////////////////////////////////////////////////////
Sub_AutoField _SendFFT128;
		
    //存储地址扩展为两倍，虚部置0
    ////偶数地址
    //--------------------------------------------------
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置参数
    RD0 = 0x2020;  			//偶数序号0x2020  //奇数序号0x1010
    FMT_CFG = RD0;     //写指令端口    
    MemSet_Disable;     //配置结束
    
    RD0 = RN_PRAM_START+DMA_ParaNum_FMT_Send2FFT128*MMU_BASE*8;
		RA2 = RD0;
		RD3 = RD0;
		// 0*MMU_BASE: CntW+源地址0 DW，默认值：GRAM0
		RD0 = RA0;
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0_ClrByteH8;
		M[RA2+0*MMU_BASE] = RD0;            //CntF is 0
    
    RD0 = FFT128RAM_Addr0+16*MMU_BASE;//目标地址，FFT128 Bank0
		RA1 = RD0;
		RD0_SetBit10;											//目标地址，FFT128 Bank1
		RA2 = RD0;
    
    Wait_While(Flag_DMAWork==0);//等clrFFT结束
    
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上
    M[RA1+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上
    M[RA2+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上
    

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置相关的4KRAM
    M[RA0] = DMA_PATH1;
    M[RA1] = DMA_PATH1;
    M[RA2] = DMA_PATH1;
    MemSet_Disable;     //配置结束

    
    //选择DMA_Ctrl通道，并启动运算
    ParaMem_Num = DMA_PATH1;
    ParaMem_Addr = DMA_nParaNum_FMT_Send2FFT128;
    nop;nop;nop;nop;nop;nop;
		
		//---------------------------------------------------
    //奇数地址
    //--------------------------------------------------
		RD0 = RD3;
		RA2 = RD0;
		RD0 = M[RA2+1*MMU_BASE];
		RD2 = RD0;	//暂存热线，后续归还;		
		// 1*MMU_BASE: CntW+目标地址DW，默认值：GRAM0
		RD0 = RA1;
		RD0 += MMU_BASE;//奇数地址从1开始
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0 -= 2;                  //流水线
		RD0_ClrByteH8;
		RD1 = CntFWB3_32b;          //CntW is 3
		RD0 += RD1;
		M[RA2+1*MMU_BASE] = RD0;  		

		Wait_While(Flag_DMAWork==0);//等FMT0结束
		
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置参数
    RD0 = 0x1010;  //偶数序号0x2020  //奇数序号0x1010
    FMT_CFG = RD0;     //ALU1写指令端口
    MemSet_Disable;     //配置结束
    
    //选择DMA_Ctrl通道，并启动运算
    ParaMem_Num = DMA_PATH1;
    ParaMem_Addr = DMA_nParaNum_FMT_Send2FFT128;
    nop;nop;nop;nop;nop;nop;
		//Wait_While(Flag_DMAWork==0);//此段待修改2021/11/29 17:32:16
		
		//热线复原为偶地址
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

		Wait_While(Flag_DMAWork==0);//等FMT1结束
		
		MemSetRAM4K_Enable;;   //Memory 设置使能
		M[RA0] = DMA_PATH5;    //                                                               通道选择（FFT模块端）
		M[RA1] = DMA_PATH5;
		MemSet_Disable;   //设置关闭
	
		Enable_FFT_Fast128;
		Start_FFT128W;   //FFT开始
		nop; nop;
		Wait_While(RFlag_FFT128End==0);

		//低三位有效，高位置0(在HA350B中增加的优化操作)
    MemSetRAM4K_Enable;
    RD0 = 0b0111;
    RD0 &= FFT128_GAIN;
    RD0 ++;
    MemSet_Disable;
		Disable_FFT_Fast128;
		
    
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      FFT_Fast128_HotLineRun
//  功能:
//      数据加窗后进行FFT运算，RD0返回FFT Gain
//  参数:
//      1.RA0:数据地址(in),紧凑型16bit，长度32DW
//	    2.RA1:窗函数(in),紧凑型16bit，长度32DW
//			3.RA2:草稿纸地址(out),紧凑型16bit，长度32DW
//  返回值:
//      RD0：FFT128_GAIN
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
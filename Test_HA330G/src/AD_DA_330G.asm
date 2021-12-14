////////////////////////////
// AD_DA_330G.asm for HA330G (Chip Core:HA320G)
// WENDI YANG 2021/12/7
////////////////////////////
//      Modified Notes
//      1.  DAC由直通变为先插值。在sendDAC函数中实现插值。
//      2.  校准不包含在ADDA init中。
//      3.  更改DAC IIR系数。
//      4. 
////////////////////////////

#define _AD_DA_330G_F_
#define ADC0_12dB    //AGC初始档位          
//#define ADC0_15dB          

#include <CPU11.def>
#include <resource_allocation.def>
#include <RN_DSP_Cfg.def>
#include <Global.def>
#include <DMA_ParaCfg.def>
#include <DspHotLine_330G.def>
#include <AD_DA_330G.def>
#include <Trimming.def> //单片测试用



CODE SEGMENT AD_DA_330G_code;
////////////////////////////////////////////////////////
//  名称:
//      AD_DA_INIT_330G
//  功能:
//      HA330G 芯片校准、ADC、DAC、DSP的初始化。
//  参数:
//      RD0:  0b00000001:MIC0    0b00000010:MIC1
//  返回值:
//      无
//  说明：
//      1.函数配置芯片工作的基本设置，包括：
//        (a)ADC的初始化（模拟和数字配置）；
//        (b)DAC的初始化（模拟和数字设置）；
//        (c)DSP初始化（包括使能DSP、热线指令初始化）
//      2.ADC使用的全局变量-----------------------------（全局变量待修改更新）
//      (a)帧计数器,                    g_Cnt_Frame
//		(b)每一路MIC需要4个全局变量
//			(1)当前帧权位               g_WeightFrame_Now_0 
//			(2)下一帧权位               g_WeightFrame_Next_0 
//			(3)当前帧Vpp                g_Vpp_0
//			(4)前一块（512帧）平均值    g_LastBank_Average_0 : 高8位为直流配置值；低16位为去直流修正值，权位为0；bit16为当前块（512帧）是否改过档位的标志位，1：改过，0：未改过 
//			(5)平均值累加器             g_ADC_DC_0 ：平均值累加器,权位为0
//			(6)配置值寄存器             g_ADC_CFG_0 ：高16位ADC前置放大器配置值，低16位ADC_CFG端口配置值
//			(7)连续小信号帧计数器       g_SmallSignal_Count_0      
//      3.DAC使用的全局变量-----------------------------（全局变量待修改更新）
//          g_DAC_Cfg               bit15-12:IIR输出增益；bit7 6：CIC输出增益。1000 10是默认值，此时0dB
//          g_Vol                   音量档位（dB），暂定32bit定点数
//          g_WeightFrame_Now_0     当前帧权位
//          g_WeightFrame_Next_0    下一帧权位
////////////////////////////////////////////////////////
Sub_AutoField AD_DA_INIT_330G;

		RD3 = RD0; //暂存MIC配置
	
		//---------------------------------------
		//(a)DSP的初始化；
		//配置DSP工作时钟
		RD0 = RN_CFG_DSP48M+RN_CFG_FLOW_DIV4;  //Slow = 8MHz 1/8降采样！DAC过采样OSR = 2
		DSP_FreqDiv = RD0;
		nop; nop; nop; nop;
		//使能DSP工作
		DSP_Disable;
		DSP_Enable;
		Pull_Enable;

		//---------------------------------------
		//(b)ADC初始化，RD1配置MIC使能
		//RD0 = 0b11;//使能双MIC
		//RD0 = 0b10;//使能MIC1
		//RD0 = 0b01;//使能MIC0
		RD0 = RD3;
		call ADC_INIT_330G;
	
		//---------------------------------------
		//(c)DAC初始化
		call DAC_INIT_330G;
	
		//---Speed5配置其他电路
		RD1 = RN_SP5;
		RP_B15;
		Set_Pulse_Ext8;
		nop;nop;

		//(d)DSP热线初始化
		call DSP_HotLine_init;

//		//初始化IIR_PATH3滤波器，用于对原始信号进行高通滤波(用于去除ADDA测试中的500Hz尖峰)
//    IIR_PATH3_Enable;
//    MemSetRAM4K_Enable;
//    RD0 = 0x0;// Para0, Data00
//    IIR_PATH3_BANK = RD0;
//		call IIR_PATH3_HP500Init;
//    IIR_PATH3_Disable;
//    MemSet_Disable;

		Return_AutoField(0*MMU_BASE);


////////////////////////////////////////////////////////
//  名称:
//      ADC_INIT_330G
//  功能:
//      HA330G ADC初始化，过采样率128，量化4bit
//  参数:
//      RD0:  0b00000001:MIC0    0b00000010:MIC1
//  返回值:
//      无
//  说明：
//      1.函数配置ADC的模拟和数字设置
//      2.ADC使用的全局变量
//      (a)帧计数器,                    g_Cnt_Frame
//		(b)每一路MIC需要4个全局变量
//			(1)当前帧权位               g_WeightFrame_Now_0 
//			(2)下一帧权位               g_WeightFrame_Next_0 
//			(3)当前帧Vpp                g_Vpp_0
//			(4)前一块（512帧）平均值    g_LastBank_Average_0 : 高8位为直流配置值；低16位为去直流修正值，权位为0；bit16为当前块（512帧）是否改过档位的标志位，1：改过，0：未改过 
//			(5)平均值累加器             g_ADC_DC_0 ：平均值累加器,权位为0
//			(6)配置值寄存器             g_ADC_CFG_0 ：高16位ADC前置放大器配置值，低16位ADC_CFG端口配置值
//			(7)连续小信号帧计数器       g_SmallSignal_Count_0      
//
////////////////////////////////////////////////////////
Sub_AutoField ADC_INIT_330G;
    //ADC全局变量初始化
    g_Cnt_Frame = 0;        
    //MIC0全局变量初始化
    g_WeightFrame_Now_0 = 0;
    g_WeightFrame_Next_0 = 0;
    g_Vpp_0 = 0;
    g_SmallSignal_Count_0 = 0;
    RD1 = 0x07000000;
    g_LastBank_Average_0 = RD1;
    g_ADC_DC_0 = 0; //g_ADC_DC ：平均值累加器,权位为0
#ifdef ADC0_12dB
    RD1 = 0x3f07C7;
#endif
#ifdef ADC0_15dB
    RD1 = 0x7f07C7;
#endif
	g_ADC_CFG_0 = RD1; //g_ADC_CFG ：高16位ADC前置放大器放大倍数,低16位ADC_CFG端口配置值
	//MIC1全局变量初始化
//	g_Weight_Frame_1 = 0;
//	RD1 = 0x07000000;
//	g_LastBank_Average_1 = RD1;
//	g_ADC_DC_1 = 0; //g_ADC_DC ：平均值累加器,权位为0
//	RD1 = 0x003F07C7;
//	g_ADC_CFG_1 = RD1; //g_ADC_CFG ：高16位ADC前置放大器放大倍数,低16位ADC_CFG端口配置值

    //模拟域设置
    ADC_Disable;// ADC初始化之前必须关闭ADC
    ADC_Enable;
    ADC_CPUCtrl_Enable;
    
    //配置MIC通路使能，RD0入口
    RD1 = RN_ADCPORT_ANAPARA;
    ADC_PortSel = RD1;
    ADC_Cfg = RD0;
    
		// 前置放大器，放大倍数选择方法：正常声音经放大后，峰峰值在6~128mV之间。
    RD0 = RN_ADCPORT_AGC0+RN_ADCPORT_AGC1;
    ADC_PortSel = RD0;
    RD0 = g_ADC_CFG_0;    //配置值寄存器, g_ADC_CFG_0 ：高16位ADC前置放大器放大倍数
    RF_GetH16(RD0);
		//RD0 = 0b00000111111;//测试用   12dB
    ADC_Cfg = RD0;
    
    //直流值默认为7
    //MIC0
    RD0 = g_LastBank_Average_0;			//g_LastBank_Average_0 ：高8位为直流配置值
    RF_GetH8(RD0);

		//RD0 = RN_ADDC_VAL;//测试用 RN_ADDC_VAL
		Volt_Vref2 = RD0;
		//MIC1
		Volt_Vref3 = RD0;
    
    //配置ADC，两路一起配置
    RD0 = RN_ADCPORT_ADC0CFG+RN_ADCPORT_ADC1CFG;
    ADC_PortSel = RD0;
    
    //设定转换表
    RD0 = RN_ADC_TABLE_ADDR;
    call _ADC_Table_330G;       //Table for 330G
    
    //配置ADC_CFG
    RD0 = g_ADC_CFG_0;//配置值寄存器, g_ADC_CFG 低16位ADC_CFG端口配置值
    RF_GetL16(RD0);
    //RD0 = 0x7C7;//测试用
    ADC_Cfg = RD0;
    
    //配置IIR for ADC
    call IIR_SetLP_89DB_ADC330G;
    
		//归还端口
    RD0 = 0;
    ADC_PortSel = RD0;
    ADC_CPUCtrl_Disable;
    //ADC_TestView_Enable;        //测试用
    Return_AutoField(0*MMU_BASE);
    
//===============================
//功能：配置HA330G ADC的6-16转换表
//入口：无
//出口：无
//===============================
Sub_AutoField _ADC_Table_330G;
    RD0 = RN_ADDR_ADC_TABLE;
    RA1 = RD0;  //表地址

    //核心表，16 X 16bit    
    RD0 = -7168;//Norm0,-7168
    RD1 = 0x400;    //Table step 1024
    RD2 = 16;
L_ADC_Table_330G:         //Set Norm 0:15
    M[RA1] = RD0;   
    RA1 += 2;
    RD0 += RD1;     
    RD2--;
    if(RQ_nZero) goto L_ADC_Table_330G;
    
    //其他6个溢出值表
    RD0 = RN_ADDR_ADC_TABLE;
RD0_SetBit5;
    RA1 = RD0;
    RD0 = 0;    //偏址
    RD0_SetBit6;
    
    RD1 = -32767;         M[RA1+RD0] = RD1;//Sel_L2
    RF_ShiftL1(RD0);
    RD1 = -16384;         M[RA1+RD0] = RD1;//Sel_L1
    RF_ShiftL1(RD0);

    RD1 = -12288;         M[RA1+RD0] = RD1;//Sel_L0
    RF_ShiftL1(RD0);
    RD1 = 13312;M[RA1+RD0] = RD1;//Sel_H0
    RF_ShiftL1(RD0);
    
    RD1 = 17408;M[RA1+RD0] = RD1;//Sel_H1
    RF_ShiftL1(RD0);

    RD1 = 32767;M[RA1+RD0] = RD1;//Sel_H2
    RF_ShiftL1(RD0);
    
    //增加一个抽头保持对称
    RD1 = -8192;M[RA1+RD0] = RD1;//Sel_N1
    Return_AutoField(0*MMU_BASE);
    


////////////////////////////////////////////////////////
//  名称:
//      IIR_SetLP_89DB_ADC330G
//  功能:
//      初始化用于1/8抽点的ADC330G三段12阶低通滤波器
//  参数:
//      无
//  返回值:
//      无
//  注释:
//      Set_IIRSftL2XY;
//          AB系数中最大的一个（A2B2)除以2存放，在系数幅度大于4时启用。
//      Set_IIRSftR2X;
//          增益除以4,在增益大于256时启用。
//      时域滤波公式：y(n) = (-a1)y(n-1) + (-a2)y(n-2) + ... + b0 *x(n) + b1 *x(n-1) + ...;
//          ai bi 是matlab给出的z变换域公式系数。硬件规定 a0 = 8192，即所有系数ai和bi都乘以8192(2^13)后四舍五入取整
//          硬件要求数据格式:符号位（BIT15) + 绝对值（BIT14-BIT0)
//          根据公式，计算时使用（-ai）与（bi）
//        	a系数为负时，求补
//        	a系数为正时，符号位取反
//        	b系数为正时，不变
//        	b系数为负时，求补，然后符号位置1
//      IIR指标
//          HA330G_ADC_Downsampling_1_8_iir_ellip_7400_8400_12800_0.60_89.75_rsc8000_48.00_G1_recip_15495_to_91.txt
//          [7400,8400,0.04,90], fs=128000, G1_recip = 15495, iir_seg = 3, N = 12;
//          gain =0.13dB, rpc = 0.61dB,rsc = -89.44dB, rsc8000 = -47.82dB（标准）;
//          gain =-44.55dB, rpc = 0.60dB,rsc = -89.75dB, rsc8000 = -48.00dB, G1_recip=91（降增益）
//          b1/3.884901548453264, b2/5.681591488336551, b3/7.678203617152247;
//          三段的期望放大倍数: [16,2,2.86], G1_recip_exp = 16*2*2.86 = 91;
//          滤波器系数转换时,固定G1_recip=1000;
//          阻带-89.05dB, 带内0.60dB, 过度带(-600/400)/8000Hz, 增益1/G0 = 91
//          2021/11/18 13:39:32
//
//      IIR系数
//      // IIR0
//      原始数据    
//        	2000, CCD7, 3229, CCD7, 2000    //b系数
//   		      8CA8, 0A015, 9B09, 1850    //a系数
//      b系数可以统一移位，以调整增益。右移1位，增益减少一半。
//        	083D, F2D5, 0CE9, F2D5, 083D    //b系数除以3.884901548453264
//   		      8CA8, 0A015, 9B09, 1850
//      Set_IIRSftL2XY有效，A2、B2除以2存放，在系数幅度大于4时启用。
//        	083D, F2D5, 0675, F2D5, 083D
//   		      8CA8, 500B, 9B09, 1850
//      硬件数据
//        	083D, 8D2B, 0674, 8D2B, 083D    //b系数为正时，不变；为负时，求补，然后符号位置1
//    		      7358, D00A, 64F7, 9850    //a系数为负时，求补；为正时，符号位取反
//
//      // IIR1
//      原始数据
//        	2000, 8FBF, 0A265, 8FBF, 2000
//   		      8C05, 0A323, 96D1, 1A4F
//      b系数可以统一移位，以调整增益。右移1位，增益减少一半。
//        	05A2, EC3E, 1C95, EC3E, 05A2    //b系数除以5.681591488336551
//    		      8C05, 0A323, 96D1, 1A4F
//      Set_IIRSftL2XY有效，A2、B2除以2存放，在系数幅度大于4时启用。
//        	05A2, EC3E, 0E4B, EC3E, 05A2
//    		      8C05, 5192, 96D1, 1A4F
//      硬件数据
//        	05A2, 93C2, 0E4A, 93C2, 05A2    //b系数为正时，不变；为负时，求补，然后符号位置1
//    		      73FB, D191, 692F, 9A4F    //a系数为负时，求补；为正时，符号位取反
//
//      // IIR2
//      原始数据
//        	2000, 97B1, 093CD, 97B1, 2000
//   		      8C67, 0A173, 990D, 1949
//      b系数可以统一移位，以调整增益。右移1位，增益减少一半。
//        	042B, F26A, 1340, F26A, 042B    //b系数除以7.678203617152247
//   		      8C67, 0A173, 990D, 1949
//      Set_IIRSftL2XY有效，A2、B2除以2存放，在系数幅度大于4时启用。
//        	042B, F26A, 09A0, F26A, 042B
//   		      8C67, 50BA, 990D, 1949
//      硬件数据
//        	042B, 8D96, 09A0, 8D96, 042B    //b系数为正时，不变；为负时，求补，然后符号位置1
//    		      7399, D0B9, 66F3, 9949    //a系数为负时，求补；为正时，符号位取反
////////////////////////////////////////////////////////
Sub_AutoField IIR_SetLP_89DB_ADC330G;
		//  IIR0
		//  083D, 8D2B, 0674, 8D2B, 083D
		//        7358, D00A, 64F7, 9850
		RD0 = 0x083D;
		ADC_FiltHD = RD0;  //b0
		RD0 = 0x8D2B;
		ADC_FiltHD = RD0;  //b1
		RD0 = 0x0674;
		ADC_FiltHD = RD0;  //b2
		RD0 = 0x8D2B;
		ADC_FiltHD = RD0;  //b3
		RD0 = 0x083D;
		ADC_FiltHD = RD0;  //b4
		RD0 = 0x7358;
		ADC_FiltHD = RD0;  //a1
		RD0 = 0xD00A;
		ADC_FiltHD = RD0;  //a2
		RD0 = 0x64F7;
		ADC_FiltHD = RD0;  //a3
		RD0 = 0x9850;
		ADC_FiltHD = RD0;  //a4
		ADC_FiltHD = RD0;  //空写一个
	
		//  IIR1
		//  05A2, 93C2, 0E4A, 93C2, 05A2
		//        73FB, D191, 692F, 9A4F
		RD0 = 0x05A2;
		ADC_FiltHD = RD0;  //b0
		RD0 = 0x93C2;
		ADC_FiltHD = RD0;  //b1
		RD0 = 0x0E4A;
		ADC_FiltHD = RD0;  //b2
		RD0 = 0x93C2;
		ADC_FiltHD = RD0;  //b3
		RD0 = 0x05A2;
		ADC_FiltHD = RD0;  //b4
		RD0 = 0x73FB;
		ADC_FiltHD = RD0;  //a1
		RD0 = 0xD191;
		ADC_FiltHD = RD0;  //a2
		RD0 = 0x692F;
		ADC_FiltHD = RD0;  //a3
		RD0 = 0x9A4F;
		ADC_FiltHD = RD0;  //a4
		ADC_FiltHD = RD0;  //空写一个
	
		//  IIR2
		//  042B, 8D96, 09A0, 8D96, 042B
		//        7399, D0B9, 66F3, 9949
		RD0 = 0x042B;
		ADC_FiltHD = RD0;  //b0
		RD0 = 0x8D96;
		ADC_FiltHD = RD0;  //b1
		RD0 = 0x09A0;
		ADC_FiltHD = RD0;  //b2
		RD0 = 0x8D96;
		ADC_FiltHD = RD0;  //b3
		RD0 = 0x042B;
		ADC_FiltHD = RD0;  //b4
		RD0 = 0x7399;
		ADC_FiltHD = RD0;  //a1
		RD0 = 0xD0B9;
		ADC_FiltHD = RD0;  //a2
		RD0 = 0x66F3;
		ADC_FiltHD = RD0;  //a3
		RD0 = 0x9949;
		ADC_FiltHD = RD0;  //a4
		ADC_FiltHD = RD0;  //空写一个
	
		Return_AutoField(0*MMU_BASE);




////////////////////////////////////////////////////////
//  名称:
//      ADC_En_nDis_330G
//  功能:
//      HA330G ADC 使能和关闭，同时配置增益
//  参数:
//      1.RD0:MIC的使能、关闭配置
//						0b00000001:MIC1关闭、MIC0使能
//						0b00000010:MIC1使能、MIC0关闭
//						0b00000011:MIC1使能、MIC0使能
//      2.RD1:MIC的初始化增益配置
//						初始放大倍数选择方法：正常声音经放大后，峰峰值在6~128mV之间。
//						bit15:0对应配置MIC0,bit31:16对应MIC1.
//  返回值:
//      无
//  说明：
//		1.函数配置ADC的模拟和数字设置
////////////////////////////////////////////////////////
Sub_AutoField ADC_En_nDis_330G;
		//push RD4;
			
		RD2 = RD0;		//暂存MIC使能配置
		RD3 = RD1;		//暂存MIC的初始化增益配置
			
		if(RD0_nZero) goto L_ADC_En_nDis_330G;
			
L_ADC330G_AllDis://MIC全部关闭，直接关闭ADC，退出
		ADC_Disable;
		g_Cnt_Frame = 0;
		Return_AutoField(0*MMU_BASE);
		
L_ADC_En_nDis_330G://MIC使能
		ADC_Enable;
		RD1 = RN_ADCPORT_ANAPARA;
		ADC_CPUCtrl_Enable;	
		//配置MIC通路使能
    ADC_PortSel = RD1;
    ADC_Cfg = RD0;//MIC的使能和关闭	
    //归还端口
    RD0 = 0;
    ADC_PortSel = RD0;
    ADC_CPUCtrl_Disable;//暂时关闭，减少ADC数据流中断
    
		RD0=RD2;
		if( RD0_Bit0 == 0) goto L_ADC_En_nDis_330G_MIC1;
		
L_ADC_En_nDis_330G_MIC0:		//MIC0 配置
	//配置MIC0 直流值
	RD0 = g_LastBank_Average_0;			//g_LastBank_Average_0 : 高8位为直流配置值
	RF_GetH8(RD0);
	Volt_Vref2 = RD0;
		
    //配置MIC0 AGC增益
		RD0 = RN_ADCPORT_AGC0;
		RD1 = RD3;
		RF_GetL16(RD1);
		ADC_CPUCtrl_Enable;	
    ADC_PortSel = RD0;    
    ADC_Cfg = RD1;
    
    //配置MIC0 ADC_CFG
    RD0 = RN_ADCPORT_ADC0CFG;
 		RD1 = ADC_CFG_Init;
    ADC_PortSel = RD0;    
    ADC_Cfg = RD1;
    
    //归还端口
    RD0 = 0;
    ADC_PortSel = RD0;
    ADC_CPUCtrl_Disable;
    
    RD1 = RD3;
    RF_GetL16(RD1);
		RF_RotateL16(RD1);//配置值寄存器, g_ADC_CFG ：高16位ADC前置放大器放大倍数
		RD0 = ADC_CFG_Init;
    RD1 += RD0;
    g_ADC_CFG_0 = RD1;//配置值寄存器写回
    
		RD0 = RD2;
		if(RD0_Bit1 == 0) goto L_ADC_En_nDis_330G_END;//MIC1未开启，结束
		
L_ADC_En_nDis_330G_MIC1:			//MIC1 配置	
		//配置MIC1 直流值
//		RD0 = g_LastBank_Average_1;			//g_LastBank_Average_1 : 高8位为直流配置值
//		RF_GetH8(RD0);
//		Volt_Vref3 = RD0;
//		
//    //配置MIC1 AGC增益
//		RD0 = RN_ADCPORT_AGC1;
//		RD1 = RD3;
//		RF_GetH16(RD1);
//		ADC_CPUCtrl_Enable;	
//    ADC_PortSel = RD0;    
//    ADC_Cfg = RD1;
//    
//    //配置MIC1 ADC_CFG
//    RD0 = RN_ADCPORT_ADC1CFG;
// 		RD1 = ADC_CFG_Init;
//    ADC_PortSel = RD0;    
//    ADC_Cfg = RD1;
    
    //归还端口
//    RD0 = 0;
//    ADC_PortSel = RD0;
//    ADC_CPUCtrl_Disable;
//    
//    RD1 = RD3;
//    RF_GetH16(RD1);
//		RF_RotateL16(RD1);//配置值寄存器, g_ADC_CFG ：高16位ADC前置放大器放大倍数
//		RD0 = ADC_CFG_Init;
//    RD1 += RD0;
//    g_ADC_CFG_1 = RD1;//配置值寄存器写回
L_ADC_En_nDis_330G_END:    
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      DAC_INIT_330G
//  功能:
//      HA330G DAC初始化
//  参数:
//      无
//  返回值:
//      无
//  说明：
//      1.函数配置DAC的模拟和数字设置
//      2.DAC使用的全局变量
//          g_DAC_Cfg               bit15-12:IIR输出增益；bit7 6：CIC输出增益。1000 10是默认值，此时0dB
//          g_Vol                   音量档位（dB），暂定32bit定点数
////////////////////////////////////////////////////////
Sub_AutoField DAC_INIT_330G;

		//DAC全局变量初始化初始化
		//RD0 = 0x802300;   //测试用
		//RD0 = 0x808380;   //E=0
        
		//RD0 = 0x808180;   //测试用，!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        RD0 = 0x808180;   //E=0，Y2不拉
		//RD0 = 0x808380;   //测试用
		g_DAC_Cfg = RD0;
		g_Vol = 0;
		//--------------------------------------------------
		//(1)初始化Bank0&1，清0
		RD0 = FlowRAM_Addr0;
		RA0 = RD0;      //Bank0地址
		RD0 = FlowRAM_Addr1;
		RA1 = RD0;      //Bank1地址

		//设置4KRAM_PATH
		MemSetRAM4K_Enable; //使用扩展端口或RAM特殊配置时使能
		RD0 = DMA_PATH0;
		M[RA0] = RD0;
		M[RA1] = RD0;
		MemSet_Disable;     //配置结束
		CPU_WorkEnable;

		//Bank0 &1，清0(暂时用CPU操作，后续换成DSP清)
		RD0 = 255;
		RF_ShiftL2(RD0);
		M[RA0] = 0;
		M[RA1] = 0;
L_InitADCFlowBank:
		M[RA0+RD0] = 0;
		M[RA1+RD0] = 0;
		RD0-=4;
		if(RQ_nZero) goto L_InitADCFlowBank;

		//--------------------------------------------------
		//配置Flow_RAM为DMA_Flow操作
		MemSetRAM4K_Enable;  //Set_All
		RD0 = DMA_PATH5;
		M[RA0] = RD0;
		M[RA1] = RD0;
		MemSet_Disable; //Set_All

		MemSetRAM4K_Enable;
		DAC_Enable;

		//配置DAC系数
        call IIR_SetLP_97DB_DAC330G;//

		//配置DAC参数
		RD0 = g_DAC_Cfg ;
		//RD0 = 0x80F380;   //测试用//
		//RD0 = 0x8083C0;   //测试用//E=0
		//RD0 = 0x808380;   //测试用，E=-6
		DAC_CFG = RD0;
		MemSet_Disable;     //配置结束

		//ADC-->DAC过程
		//准备进程Flow参数映像
//    RD0 = 0;//Bank偏移地址，字节
//    send_para(RD0);
//		RD0 = AD_Buf_Len;//4MHz
//    send_para(RD0);
//    RD0 = RN_CFG_FLOW_TYPE3;//Slow = 8MHz
//    send_para(RD0);
//    call _DMA_ParaCfg_Flow2;
		RD0 = RN_PRAM_START+DMA_ParaNum_ADDA_Flow*MMU_BASE*8;
		RA0 = RD0;
		RD0=RN_CFG_DAC_DIV1+RN_CFG_MEM_DIV512+RN_CFG_ADC_DIV2;
		M[RA0+0*MMU_BASE] = RD0;
		RD0 = 0;   //Bank起始地址
		RF_ShiftR2(RD0);           //变为Dword地址
		RF_Not(RD0);               //硬件要求
		M[RA0+2*MMU_BASE] = RD0;
		RD0 = 0x1e01fffd; //0x70ff0001;
		M[RA0+1*MMU_BASE] = RD0;  //Loop_Num

		//选择DMA_Flow通道，并启动运算
		RD0 = 0x80;
		ParaMem_Num = RD0;
		RD0 = DMA_nParaNum_ADDA_Flow;
		ParaMem_Addr = RD0;

		// 使能DAC Class-D 输出
		SDM_DRV0_ENABLE;    //1倍驱动，默认值，不修改
		//SDM_DRV1_ENABLE;    //2倍驱动
		//SDM_DRV0_ENABLE;SDM_DRV1_ENABLE;    //3倍驱动

		Return_AutoField(0*MMU_BASE);

////////////////////////////////////////////////////////
//  名称:
//      DAC_En_nDis_330G
//  功能:
//      HA330G DAC关闭和重开
//  参数:
//      RD0: 0关闭DAC，1开启DAC
//  返回值:
//      无
//  说明：
//      1.函数配置DAC的模拟和数字设置
//      2.DAC使用的全局变量
//        (a)配置值寄存器, g_DAC_Cfg ：低16位DAC_CFG端口配置值 bit15-12:IIR输出增益；bit7 6：CIC输出增益。1000 01是默认值，此时0dB
//        (b)g_Vol：音量档位（dB），暂定32bit定点数
//
////////////////////////////////////////////////////////
Sub_AutoField DAC_En_nDis_330G;
		if(RD0_nZero) goto L_DAC_En_330G;
L_DAC_nDis_330G://关闭DAC和Class-D输出
		SDM_DRV0_DISABLE;
		SDM_DRV1_DISABLE;
		DAC_Disable;
		Return_AutoField(0*MMU_BASE);
L_DAC_En_330G://暂定重新启动DAC时，Bank已由FW维护好，无需清零
		RD0 = FlowRAM_Addr0;
		RA0 = RD0;      //Bank0地址
		RD0 = FlowRAM_Addr1;
		RA1 = RD0;      //Bank1地址
		//配置Flow_RAM为DMA_Flow操作
		MemSetRAM4K_Enable;  //Set_All
		RD0 = DMA_PATH5;
		M[RA0] = RD0;
		M[RA1] = RD0;
		MemSet_Disable; //Set_All

		MemSetRAM4K_Enable;
		DAC_Enable;

		//配置DAC参数
		RD0 = g_DAC_Cfg ;
		//RD0 = 0x80F380;   //测试用//
		//RD0 = 0x8083C0;   //测试用//E=0
		//RD0 = 0x808380;   //测试用，E=-6
		DAC_CFG = RD0;
		MemSet_Disable;     //配置结束

		//ADC-->DAC过程
		//准备进程Flow参数映像
		RD0 = RN_PRAM_START+DMA_ParaNum_ADDA_Flow*MMU_BASE*8;
		RA0 = RD0;
		RD0=RN_CFG_DAC_DIV1+RN_CFG_MEM_DIV512+RN_CFG_ADC_DIV2;
		M[RA0+0*MMU_BASE] = RD0;
		RD0 = 0;   //Bank起始地址
		RF_ShiftR2(RD0);           //变为Dword地址
		RF_Not(RD0);               //硬件要求
		M[RA0+2*MMU_BASE] = RD0;
		RD0 = 0x1e01fffd; //0x70ff0001;
		M[RA0+1*MMU_BASE] = RD0;  //Loop_Nums

		//选择DMA_Flow通道，并启动运算
		RD0 = 0x80;
		ParaMem_Num = RD0;
		RD0 = DMA_nParaNum_ADDA_Flow;
		ParaMem_Addr = RD0;


		// 使能DAC Class-D 输出
		SDM_DRV0_ENABLE;    //1倍驱动，默认值，不修改
		//SDM_DRV1_ENABLE;    //2倍驱动
		//SDM_DRV0_ENABLE;SDM_DRV1_ENABLE;    //3倍驱动

		Return_AutoField(0*MMU_BASE);


////////////////////////////////////////////////////////
//  名称:
//      IIR_SetLP_97DB_DAC330G
//  功能:
//      初始化用于1/8插点的DAC330G四段14阶低通滤波器
//  参数:
//      无
//  返回值:
//      无
//  注释:
//      Set_IIRSftL2XY;
//          AB系数中最大的一个（A2B2)除以2存放，在系数幅度大于4时启用。
//      Set_IIRSftR2X;
//          增益除以4,在增益大于256时启用。
//      时域滤波公式：y(n) = (-a1)y(n-1) + (-a2)y(n-2) + ... + b0 *x(n) + b1 *x(n-1) + ...;
//          ai bi 是matlab给出的z变换域公式系数。硬件规定 a0 = 8192，即所有系数ai和bi都乘以8192(2^13)后四舍五入取整
//          硬件要求数据格式:符号位（BIT15) + 绝对值（BIT14-BIT0)
//          根据公式，计算时使用（-ai）与（bi）
//              a系数为负时，求补
//              a系数为正时，符号位取反
//              b系数为正时，不变
//              b系数为负时，求补，然后符号位置1
//      IIR指标
////////////////////////////////////////////////////////


//[5 5 5 3] - [24  2  1.2  20/9]
Sub_AutoField IIR_SetLP_97DB_DAC330G;
// RD0 = 0x01A1;        // CFG

// IIR0
RD0 = 0x0975;
DAC_IIR1_HD = RD0;
RD0 = 0x8D1A;
DAC_IIR1_HD = RD0;
RD0 = 0x0586;
DAC_IIR1_HD = RD0;
RD0 = 0x8D1A;
DAC_IIR1_HD = RD0;
RD0 = 0x0975;
DAC_IIR1_HD = RD0;
RD0 = 0x71FC;
DAC_IIR1_HD = RD0;
RD0 = 0xCDFF;
DAC_IIR1_HD = RD0;
RD0 = 0x60CE;
DAC_IIR1_HD = RD0;
RD0 = 0x96E3;
DAC_IIR1_HD = RD0;
DAC_IIR1_HD = RD0;

// IIR1
RD0 = 0x0441;
DAC_IIR1_HD = RD0;
RD0 = 0x8EB5;
DAC_IIR1_HD = RD0;
RD0 = 0x0A9A;
DAC_IIR1_HD = RD0;
RD0 = 0x8EB5;
DAC_IIR1_HD = RD0;
RD0 = 0x0441;
DAC_IIR1_HD = RD0;
RD0 = 0x7296;
DAC_IIR1_HD = RD0;
RD0 = 0xCF35;
DAC_IIR1_HD = RD0;
RD0 = 0x63F5;
DAC_IIR1_HD = RD0;
RD0 = 0x9857;
DAC_IIR1_HD = RD0;
DAC_IIR1_HD = RD0;

// IIR2
RD0 = 0x0187;
DAC_IIR1_HD = RD0;
RD0 = 0x84D5;
DAC_IIR1_HD = RD0;
RD0 = 0x0364;
DAC_IIR1_HD = RD0;
RD0 = 0x84D5;
DAC_IIR1_HD = RD0;
RD0 = 0x0187;
DAC_IIR1_HD = RD0;
RD0 = 0x723D;
DAC_IIR1_HD = RD0;
RD0 = 0xCE87;
DAC_IIR1_HD = RD0;
RD0 = 0x623E;
DAC_IIR1_HD = RD0;
RD0 = 0x9793;
DAC_IIR1_HD = RD0;
DAC_IIR1_HD = RD0;

// IIR3
RD0 = 0x30CF;
DAC_IIR1_HD = RD0;
RD0 = 0xDA0B;
DAC_IIR1_HD = RD0;
RD0 = 0x1867;
DAC_IIR1_HD = RD0;
RD0 = 0x0000;
DAC_IIR1_HD = RD0;
RD0 = 0x0000;
DAC_IIR1_HD = RD0;
RD0 = 0x3BAB;
DAC_IIR1_HD = RD0;
RD0 = 0x8FDC;
DAC_IIR1_HD = RD0;
RD0 = 0x8000;
DAC_IIR1_HD = RD0;
RD0 = 0x8000;
DAC_IIR1_HD = RD0;
DAC_IIR1_HD = RD0;

Return_AutoField(0*MMU_BASE);
//////////////////////////////////////////////////////////
////  名称:
////      IIR_PATH3_HP500Init
////  功能:
////      设置高通滤波器系数
////  参数:
////      无？？？
////  返回值:
////      无
////  注释:
////      [50,500,0.1,40], fs=16000, G1_recip=1, iir_seg = 1
////      gain = 0.00dB, rpc = 0.23dB, rsc = -40.07dB
////      G1_recip =
////           1
////      b11 =
////              8192      -24557       24557       -8192
////      a11 =
////              8192      -22116       20013       -6058
//////////////////////////////////////////////////////////
//    Sub_AutoField IIR_PATH3_HP500Init;
//
//    // HA330G_FW_HP_iir_ellip_16000_50_500_0.1_40.txt
//    //转换成功
//    //配置值	0x0042
//    //最终增益	1
//    //最终段数	4
//    //没有绝对值大于32767的数
//
//    RD0 = 0x7FFF;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0042;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x7FFF;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0042;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x7FFF;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0042;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x2000;
//    IIR_PATH3_HD = RD0;     // b0
//    RD0 = 0xDFED;
//    IIR_PATH3_HD = RD0;     // b1
//    RD0 = 0x5FED;
//    IIR_PATH3_HD = RD0;     // b2
//    RD0 = 0xA000;
//    IIR_PATH3_HD = RD0;     // b3
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;     // b4
//    RD0 = 0x5664;
//    IIR_PATH3_HD = RD0;     // a1
//    RD0 = 0xCE2D;
//    IIR_PATH3_HD = RD0;     // a2
//    RD0 = 0x17AA;
//    IIR_PATH3_HD = RD0;     // a3
//    RD0 = 0x8000;
//    IIR_PATH3_HD = RD0;     // a4
//    RD0 = 0x0042;
//    IIR_PATH3_HD = RD0;     // CFG
//
//    //寄存器地址复位
//    IIR_PATH3_CLRADDR;
//    Return_AutoField(0*MMU_BASE);

//////////////////////////////////////////////////////////////////////////
//  名称:
//      Get_ADC
//  功能:
//      从ADC获得1帧数据
//  参数:
//      无
//  返回值：
//			RD0 == 0 :获得了一帧数据
//			RD0 != 0 :未能获得数据
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Get_ADC;
		
    //检查有无新数据
    RD0 = g_Cnt_Frame;
    if(RD0_Bit0==0) goto L_Get_ADC_AD_Even;
    // 轮询奇数帧数据
    RD1 = FlowRAM_Addr1;	//源地址为FlowRAM_Addr1（奇数帧）
    if(RFlag_Flow2Bank0==1) goto L_Get_ADC_DATA;
    Return_AutoField(0*MMU_BASE);	//没有新数据，返回，RD0为帧计数值，非零
L_Get_ADC_AD_Even:
    // 轮询偶数帧数据
    RD1 = FlowRAM_Addr0;	//源地址为FlowRAM_Addr0（偶数帧）
    if(RFlag_Flow2Bank0==0) goto L_Get_ADC_DATA;
    Return_AutoField(0*MMU_BASE);	//没有新数据，返回，RD0为帧计数值，非零
    
    //有新数据
L_Get_ADC_DATA:
    RA0 = RD1;        
    call Get_ADC_Function;

	RD0 = 0;
    Return_AutoField(0*MMU_BASE);


//////////////////////////////////////////////////////////////////////////
//  名称:
//      Get_ADC_Function 
//  功能:
//      对ADC获得的数据统计，以此为据去直流、调增益
//  参数:
//      RA0     AD_buf数据指针
//  返回值：
//		无
//  说明：
//      (a)帧计数器,                    g_Cnt_Frame
//		(b)每一路MIC需要4个全局变量
//			(1)当前帧权位               g_WeightFrame_Now_0 
//			(2)下一帧权位               g_WeightFrame_Next_0 
//			(3)当前帧Vpp                g_Vpp_0
//			(4)前一块（512帧）平均值    g_LastBank_Average_0 : 高8位为直流配置值；低16位为去直流修正值，权位为0；bit16为当前块（512帧）是否改过档位的标志位，1：改过，0：未改过 
//			(5)平均值累加器             g_ADC_DC_0 ：平均值累加器,权位为0
//			(6)配置值寄存器             g_ADC_CFG_0 ：高16位ADC前置放大器配置值，低16位ADC_CFG端口配置值
//			(7)连续小信号帧计数器       g_SmallSignal_Count_0      
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Get_ADC_Function;
    
    RD0 = RA0;
    RD2 = RD0;
    //////1、数据统计
    //权位修正：硬件增益非整倍数，需要软件修正
    RD0 = g_WeightFrame_Now_0;
    if(RD0_Zero) goto L_ExpFix_End;
    if(RD0_Bit31 == 1) goto L_ExpFix_1;
    //E=2
#ifdef ADC0_12dB
    RD1 = 0x60006000;   //修正值
#endif
#ifdef ADC0_15dB
    RD1 = 0x67FF67FF;   //修正值
#endif
    goto L_ExpFix_0;
L_ExpFix_1:
    //E=-2
#ifdef ADC0_12dB
    RD1 = 0x68B968B9;   //修正值
#endif
#ifdef ADC0_15dB
    RD1 = 0x64D864D8;   //修正值
#endif
L_ExpFix_0:
    call _MAC_RffC_ADC;

L_ExpFix_End:    

	//ALU计算xi-g_LastBank_Average_0，g_LastBank_Average_0：前一块（512帧）数据的均值
    RD0 = RD2;
    RA0 = RD0;
	RD0 = RN_GRAM_IN;
	RA1 = RD0;
	call ADC0_C0;   //RD0:紧凑型格式，需要减去的直流值（外部进行权重对齐，并拼凑为H16、L16格式），即前512帧平均值（权位同步）
	call _GetADC_Ave_Max_Min;   //1.RD0：结果的累加和，即SUM(Xi-C),32bit有符号数 2.RD1：峰峰值，Vpp=Max-Min，32bit有符号数
    g_Vpp_0 = RD1;  
    call ADC0_Weight;     //更新累加和  

goto L_ADC_Bias_Adj_Start;//////////////!!!!!!!!!!!!测试用
           
    //////2、AGC增益调整
    // 2.1小信号处理
    call ADC0_SmallSignal;
    
    if(RD0_Zero) goto L_ADC_Bias_Adj_Start; //当前属于小信号帧，跳过大信号处理
    // 2.2大信号处理
    call ADC0_StrongSignal;

L_ADC_Bias_Adj_Start:
    //更新DAC_CFG,放在此处接近ADC_Cfg调整，减少更改档位带来的震荡
    RD0 = g_DAC_Cfg; 
    CPU_WorkEnable;
    DAC_CFG = RD0;
    CPU_WorkDisable;

    //////3、去直流
    RD0 = g_Cnt_Frame;  //帧计数器
    if(RD0_Zero) goto L_ADC_Bias_Adj_End;                      
    if(RD0_L8 != 0) goto L_ADC_Bias_Adj_End; 
    if(RD0_Bit8 == 1) goto L_ADC_Bias_Adj_End;  //判是否满512帧，不满跳过                 
    call ADC0_Step;
    RD2 = RD0;          //当前512帧平均值
//RD0 = g_Cnt_Frame;
//send_para(RD0);
//call UART_PutDword_COM1;
//RD0 = g_Vpp_0;
//send_para(RD0);
//call UART_PutDword_COM1;
//RD0 = g_WeightFrame_Now_0;
//send_para(RD0);
//call UART_PutDword_COM1;
//RD0 = g_DAC_Cfg;
//send_para(RD0);
//call UART_PutDword_COM1;                             
//RD0 = g_ADC_CFG_0;
//send_para(RD0);
//call UART_PutDword_COM1;   
    //RD0 = g_WeightFrame_Now_0;
    //if(RD0_nZero) goto L_ADC_Bias_Adj_End;      //E!=0,不做硬件直流调整                             
    RD0 = g_Cnt_Frame;  //帧计数器                              
    if(RD0_Bit9 == 1) goto L_ADC_Bias_Adj_End;  // 判是否满1024帧，不满跳走不做计算         
    RD0 = g_LastBank_Average_0;                 // 高8位为直流配置值；低16位为前512帧平均值，权位为0；bit16为当前块（512帧）是否改过档位的标志位，1：改过，0：未改过 
    if(RD0_Bit16 == 0) goto L_ADC_Bias_Adj_0;   // 判是否改过AGC档位的标志位
    // 当前帧改过AGC档位
    RD0_ClrBit16;
    g_LastBank_Average_0 = RD0;                 // 清除标志位
    goto L_ADC_Bias_Adj_End;
    
L_ADC_Bias_Adj_0:   //未改档位
    RD0 = RD2;
    call ADC0_Bias_Adj;

L_ADC_Bias_Adj_End:    


    Return_AutoField(0*MMU_BASE);
//////////////////////////////////////////////////////////////////////////
//  名称:
//      Send_DAC
//  功能:
//      向DAC发送1帧数据
//  参数:
//      无
//  返回值：
//		无
//  说明：  
//      g_DAC_Cfg               bit15-12:IIR输出增益；bit7 6：CIC输出增益。1000 10是默认值，此时0dB
//      g_Vol                   音量档位（dB），暂定32bit定点数
//      g_WeightFrame_Now_0     当前帧权位
//      g_WeightFrame_Next_0    下一帧权位
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Send_DAC;
	
//    RD0 = g_WeightFrame_Now_0;
//    RF_ShiftL1(RD0);//E*2       
//    RD1 = RD0;
//    RD0 += RD1;
//    RD0 += RD1;     //E*6
//    RD0 += g_Vol;   //总增益=6*E+音量值
//    call Find_k;   
//    RD2 = RD1;  //右移位数 
//    call DAC_Tab;
//    //先进行乘法
//    if(RD0_Zero) goto L_Send_DAC_xx;
//    //非6的整数倍，插kx   
//    RD1 = RD0;    
//	RD0 = RN_GRAM_IN; 
//    RA0 = RD0;
//	RD0 = RN_GRAM_IN; ///////////////////////！！！！！！！！！暂定寄存器 ！！！！！！
//    RD0 += 16*MMU_BASE;
//    RA1 = RD0;
//    RD0 = RD1;
//    call _MAC_RffC;          
//
//    RD0 = RN_GRAM_IN; 
//    RA0 = RD0;
//	RD0 = RN_GRAM_IN; ///////////////////////！！！！！！！！！暂定寄存器 ！！！！！！
//    RD0 += 16*MMU_BASE;    
//    RA1 = RD0;
//    RD0 = RN_GRAM1; 
//    RA2 = RD0;
//    call _Send_DAC_Interpolation;   
//    goto L_Send_DAC_Odd;
//L_Send_DAC_xx:
//    RD0 = RN_GRAM_IN; 
//    RA0 = RD0;
//    RA1 = RD0;
//    RD0 = RN_GRAM1; 
//    RA2 = RD0;
//    call _Send_DAC_Interpolation;   
//
//L_Send_DAC_Odd:        
//	RD1 = FlowRAM_Addr1;	
//    RD0 = g_Cnt_Frame;
//    if(RD0_Bit0==1) goto L_Send_DAC_Even;
//	RD1 = FlowRAM_Addr0;	
//L_Send_DAC_Even:
//    
//    //移位
//	RD0 = RN_GRAM1;
//    RA0 = RD0;
//    RA1 = RD1;
//    RD0 = RD2;
//    call _Send_DAC_SignSftR_RndOff;
    
    RD0 = RN_GRAM_IN;
    RA0 = RD0;
    RD0 = RN_GRAM1;
    RA1 = RD0;
    MemSetRAM4K_Enable; //使用扩展端口或RAM特殊配置时使能
    RD0 = DMA_PATH0;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //配置结束

    //申请128字节缓冲区
    RD0 = 32*MMU_BASE;
    RSP -= RD0;
    RA1 = RSP;   

    CPU_WorkEnable;
    //拷贝并内插,至缓冲区
    RD2 = 16;
L_DATA_XXX_L0:
    
    RD0 = g_Cnt_Frame;
    if(RD0_Bit8 == 0) goto L_L8_0; 

    RD3 = M[RA0++];
    RD0 = RD3;
    RF_GetL16(RD0);
    RD1 = RD0;
    RF_RotateR16(RD1);
    RD0 += RD1;    
    M[RA1++] = RD0;

    RD0 = RD3;
    RF_GetH16(RD0);
    RD1 = RD0;
    RF_RotateR16(RD1);
    RD0 += RD1;    
    M[RA1++] = RD0;    
    goto L_L8_1;

L_L8_0:

    RD3 = M[RA0++];
    RD0 = RD3;
    RF_GetL16(RD0);
    RD0_SignExtL16;
    RF_ShiftL1(RD0);
    RD0_ClrByteH16;    
    M[RA1++] = RD0;
     
    RD0 = RD3; 
    RF_GetH16(RD0);
    RD0_SignExtL16;
    RF_ShiftL1(RD0);
    RD0_ClrByteH16;    
    M[RA1++] = RD0; 

L_L8_1:
        
    RD2 --;
    if(RQ_nZero) goto L_DATA_XXX_L0;
    RD0 = RN_GRAM1;
    RA0 = RD0;
    RA1 = RSP;
    RD2 = 16;
L_DATA_XXX_L1:
    RD0 = M[RA1++];
    M[RA0++] = RD0;
    RD0 = M[RA1++];
    M[RA0++] = RD0;
    RD2 --;
    if(RQ_nZero) goto L_DATA_XXX_L1;
    CPU_WorkDisable;

    //释放128字节缓冲区
    RD0 = 32*MMU_BASE;
    RSP += RD0;
    
    
    
    RD0 = g_Cnt_Frame;
    if(RD0_Bit0==1) goto L_Send_DAC_Even;
    //偶数帧
    
	RD0 = RN_GRAM1;
    RA0 = RD0;
	RD1 = FlowRAM_Addr0;
    RA1 = RD1;
    RD0 = 0;
    call _Send_DAC_SignSftR_RndOff;
       

    goto L_Send_DAC_Even_End;
		
L_Send_DAC_Even:
    //奇数帧
    
//    RD0 = RN_GRAM_IN; 
//    RA0 = RD0;
//    RA1 = RD0;
//    RD0 = RN_GRAM1; 
//    RA2 = RD0;
//    call _Send_DAC_Interpolation;   
    
	RD0 = RN_GRAM1;
    RA0 = RD0;
	RD1 = FlowRAM_Addr1;	
    RA1 = RD1;
    RD0 = 0;
    call _Send_DAC_SignSftR_RndOff;

L_Send_DAC_Even_End:



    //更新权位
    RD0 = g_WeightFrame_Next_0;    
    g_WeightFrame_Now_0 = RD0;
    

    //帧计数器累加
    g_Cnt_Frame ++;    

    Return_AutoField(0*MMU_BASE);    
    
    
//////////////////////////////////////////////////////////////////////////
//  名称:
//      DATA_kX 
//  功能:
//      插kX
//  参数:
//      RD0 源数据x地址 
//      RD1 kx地址
//  返回值：
//		无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField DATA_kX;

    push RA2;
    
    RA0 = RD0;
    RA2 = RD1;
    RD3 = RD0;
    MemSetRAM4K_Enable; //使用扩展端口或RAM特殊配置时使能
    RD0 = DMA_PATH0;
    M[RA0] = RD0;
    M[RA2] = RD0;
    MemSet_Disable;     //配置结束

    //申请128字节缓冲区
    RD0 = 32*MMU_BASE;
    RSP -= RD0;
    RA1 = RSP;   

    CPU_WorkEnable;
    //拷贝并内插,至缓冲区
    RD2 = 16;
L_DATA_kX_L0:
    RD0 = M[RA0]; //源数据x
    RD1 = M[RA2]; //kx
    RF_GetL16(RD0);
    RF_GetL16(RD1);
    RF_RotateR16(RD1);
    RD0 += RD1;
    M[RA1++] = RD0;
     
    RD0 = M[RA0++]; //源数据x
    RD1 = M[RA2++]; //kx
    RF_GetH16(RD0);
    RF_GetH16(RD1);
    RF_RotateR16(RD1);
    RD0 += RD1;
    M[RA1++] = RD0; 
    
    RD2 --;
    if(RQ_nZero) goto L_DATA_kX_L0;
    //拷贝回原地址
    RD0 = RD3;
    RA0 = RD0;
    RA1 = RSP;
    RD2 = 16;
L_DATA_kX_L1:
    RD0 = M[RA1++];
    M[RA0++] = RD0;
    RD0 = M[RA1++];
    M[RA0++] = RD0;
    RD2 --;
    if(RQ_nZero) goto L_DATA_kX_L1;
    CPU_WorkDisable;

    //释放128字节缓冲区
    RD0 = 32*MMU_BASE;
    RSP += RD0;
    
    pop RA2;
    Return_AutoField(0);
//////////////////////////////////////////////////////////////////////////
//  名称:
//      DATA_XX 
//  功能:
//      插原值
//  参数:
//      RD0 源数据地址
//  返回值：
//		无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField DATA_XX;

    push RA2;
    
    RA2 = RD0;
    RA0 = RD0;
    MemSetRAM4K_Enable; //使用扩展端口或RAM特殊配置时使能
    RD0 = DMA_PATH0;
    M[RA0] = RD0;
    MemSet_Disable;     //配置结束

    //申请128字节缓冲区
    RD0 = 32*MMU_BASE;
    RSP -= RD0;
    RA1 = RSP;   

    CPU_WorkEnable;
    //拷贝并内插,至缓冲区
    RD2 = 16;
L_DATA_XX_L0:
    RD3 = M[RA0++];
    RD0 = RD3;
    RF_GetL16(RD0);
    RD1 = RD0;
    RF_RotateR16(RD1);
    RD0 += RD1;
    
    M[RA1++] = RD0;
    RD0 = RD3;
    RF_GetH16(RD0);
    RD1 = RD0;
    RF_RotateR16(RD1);
    RD0 += RD1;
    
    M[RA1++] = RD0;
    
    RD2 --;
    if(RQ_nZero) goto L_DATA_XX_L0;

    //拷贝回原地址
    RD0 = RA2;
    RA0 = RD0;
    RA1 = RSP;
    RD2 = 16;
L_DATA_XX_L1:
    RD0 = M[RA1++];
    M[RA0++] = RD0;
    RD0 = M[RA1++];
    M[RA0++] = RD0;
    RD2 --;
    if(RQ_nZero) goto L_DATA_XX_L1;
    CPU_WorkDisable;

    //释放128字节缓冲区
    RD0 = 32*MMU_BASE;
    RSP += RD0;
    
    pop RA2;
    Return_AutoField(0);


//////////////////////////////////////////////////////////////////////////
//  名称:
//      ADC0_Weight
//  功能:
//      更新累加和计数器
//  参数:
//      RD0 : 当前帧累加和（带权位）
//  返回值：
//		无
//  全局变量：
//      g_WeightFrame_Now_0 当前帧权位
//      g_ADC_DC_0:         累加和计数器（权位0）
//////////////////////////////////////////////////////////////////////////
Sub_AutoField ADC0_Weight;

    // 根据帧权位左右移累加和，使权位置0
    RD1 = RD0;
    RD0 = g_WeightFrame_Now_0;
    if(RD0_Zero) goto L_ADC_Weight_End; 
    if(RD0_Bit31 == 0) goto L_ADC_Weight_0;
    // 权位为负数
L_ADC_Weight_1:
    RF_Sft32SR1(RD1);
    RD0 ++;
    if(RD0_nZero) goto L_ADC_Weight_1;
    goto L_ADC_Weight_End;
L_ADC_Weight_0:
    // 权位为正数
    RF_ShiftL1(RD1);     
    RD0 --;
    if(RD0_nZero) goto L_ADC_Weight_0;
L_ADC_Weight_End:   // 当前帧累加和在RD1上（权位0）            
        
    //平均值累加器 += 当前帧累加和（权位0）
    RD0 = g_ADC_DC_0;
    RD0 += RD1;
    g_ADC_DC_0 = RD0;   
    
    Return_AutoField(0);
        
//////////////////////////////////////////////////////////////////////////
//  名称:
//      ADC0_C0
//  功能:
//      将前512帧平均值（权位0）调至当前帧权位
//  参数:
//      无
//  返回值：
//		RD0:紧凑型格式，需要减去的直流值（外部进行权重对齐，并拼凑为H16、L16格式），即前512帧平均值（权位同步）
//  全局变量：
//      g_WeightFrame_Now_0     当前帧权位
//		g_LastBank_Average_0    高8位为直流配置值；低16位为前512帧平均值，权位为0；bit16为当前块（512帧）是否改过档位的标志位。1：改过，0：未改过 
//////////////////////////////////////////////////////////////////////////
Sub_AutoField ADC0_C0;
    
    RD0 = g_LastBank_Average_0;
    RD0_SignExtL16;     //前512帧平均值（权位0）

    // 根据帧权位左右移平均值，使权位置0
    RD1 = RD0;
    RD0 = g_WeightFrame_Now_0;  // 当前帧权位
    if(RD0_Zero) goto L_ADC0_C0_End; 
    if(RD0_Bit31 == 0) goto L_ADC0_C0_0;
    // 权位为负数
L_ADC0_C0_1:
    RF_ShiftL1(RD1);     
    RD0 ++;
    if(RD0_nZero) goto L_ADC0_C0_1;
    goto L_ADC0_C0_End;
L_ADC0_C0_0:
    // 权位为正数
    RF_Sft32SR1(RD1);
    RD0 --;
    if(RD0_nZero) goto L_ADC0_C0_0;
L_ADC0_C0_End:             
    //RD1:前512帧平均值（权位同步后）
    RD0 = RD1;
	RD0_ClrByteH16;
	RD1 = RD0;
	RF_RotateL16(RD0);
	RD0 += RD1; //RD0:需要从RA0中减去的直流值（外部进行权重对齐，并拼凑为H16、L16格式）      
    
    Return_AutoField(0);
//////////////////////////////////////////////////////////////////////////
//  名称:
//      ADC0_SmallSignal
//  功能:
//      ADC0小信号处理
//  参数:
//      无
//  返回值：
//		RD0:    0:当前属于小信号帧；1:当前不属于小信号帧
//  全局变量：
//		g_Vpp_0                 当前帧Vpp
//		g_SmallSignal_Count_0   连续小信号帧计数器
//		g_WeightFrame_Now_0     当前帧权位                
//		g_WeightFrame_Next_0    下一帧权位               
//		g_ADC_CFG_0;            高16位ADC前置放大器配置值，低16位ADC_CFG端口配置值
//////////////////////////////////////////////////////////////////////////
Sub_AutoField ADC0_SmallSignal;
    
    RD0 = g_Vpp_0;
    RD0_ClrBit8;
    RD0_ClrBit9;
    RD0_ClrBit10;
    RD0_ClrBit11;
    RD0_ClrByteL8;
    if(RD0_Zero) goto L_ADC0_SmallSignal_0;  //Vpp<2^12
    //未检测到小信号，清零计数器，跳走
    g_SmallSignal_Count_0 = 0;        
    goto L_ADC0_SmallSignal_End;     

L_ADC0_SmallSignal_0:
    //检测到小信号
    RD0 = g_SmallSignal_Count_0;
    RD1 = 128;  //小信号帧计数器
    RD0 -= RD1;
    if(RD0_Zero) goto L_ADC0_SmallSignal_1; 
    //不满足连续x帧小信号，计数器++，跳走
    g_SmallSignal_Count_0 ++;
    goto L_ADC0_SmallSignal_5;  // 当前帧属于小信号帧，跳过大信号处理
        
L_ADC0_SmallSignal_1:           // 小信号计数器达标，进行增益放大处理
    g_SmallSignal_Count_0 = 0;                // 计数器清零
    
    RD0 = g_WeightFrame_Now_0;
    if(RD0_nZero) goto L_ADC0_SmallSignal_2;
    //当前E=0，下一帧变为-2
    RD0 = -2;
	g_WeightFrame_Next_0 = RD0;
    RD0 = g_ADC_CFG_0;
    RD0_ClrByteH16;
#ifdef ADC0_12dB
    RD1 = 0x3ff0000;
#endif
#ifdef ADC0_15dB
    RD1 = 0x7ff0000;
#endif
    RD0 += RD1;
    g_ADC_CFG_0 = RD0;
    goto L_ADC0_SmallSignal_4;
L_ADC0_SmallSignal_2:        
    if(RD0_Bit31 == 0) goto L_ADC0_SmallSignal_3;
    //当前E=-2，到顶不调整
    goto L_ADC0_SmallSignal_5;
L_ADC0_SmallSignal_3:
    //当前E=2，下一帧变为0
    g_WeightFrame_Next_0 = 0;
    RD0 = g_ADC_CFG_0;
    RD0_ClrByteH16;
#ifdef ADC0_12dB
    RD1 = 0x3f0000;
#endif
#ifdef ADC0_15dB
    RD1 = 0x7f0000;
#endif
    RD0 += RD1;
    g_ADC_CFG_0 = RD0;  

L_ADC0_SmallSignal_4:
    //ADC_Cfg更新
    RF_RotateR16(RD1);
    RD0 = RN_ADCPORT_AGC0;
    ////Try ADC
    ADC_CPUCtrl_Enable;
    //配置ADC0    
    ADC_PortSel = RD0;
    ADC_Cfg = RD1;
    RD0 = 0;
    ADC_PortSel = RD0;
    ADC_CPUCtrl_Disable;

L_ADC0_SmallSignal_5:    
    RD0 = 0;       
    Return_AutoField(0);

L_ADC0_SmallSignal_End: 
    RD0 = 1; 
    Return_AutoField(0);


//////////////////////////////////////////////////////////////////////////
//  名称:
//      ADC0_StrongSignal
//  功能:
//      ADC0大信号处理
//  参数:
//      无
//  返回值：
//		无
//  全局变量：
//		g_Vpp_0                 当前帧Vpp
//		g_WeightFrame_Now_0     当前帧权位                
//		g_WeightFrame_Next_0    下一帧权位               
//		g_ADC_CFG_0;            高16位ADC前置放大器配置值，低16位ADC_CFG端口配置值
//////////////////////////////////////////////////////////////////////////
Sub_AutoField ADC0_StrongSignal;
    
    RD0 = g_Vpp_0;
    if(RD0_Bit15 == 0) goto L_ADC0_StrongSignal_End; 
//    if(RD0_Bit14 == 0) goto L_ADC0_StrongSignal_End; 
    //bit14 15都为1，减少增益    
    RD0 = g_WeightFrame_Now_0;
    if(RD0_nZero) goto L_ADC0_StrongSignal_0;  
    //E=0,调整为2
    RD0 = 2;
    g_WeightFrame_Next_0 = RD0;
#ifdef ADC0_12dB
    RD1 = 0x70000; 
#endif
#ifdef ADC0_15dB
    RD1 = 0xf0000;
#endif
    goto L_ADC0_StrongSignal_3;
L_ADC0_StrongSignal_0:
    if(RD0_Bit31 == 1) goto L_ADC0_StrongSignal_2;
    //E=2,无法降低
    goto L_ADC0_StrongSignal_End;
L_ADC0_StrongSignal_2:    
    //E=-2,调整为0
    g_WeightFrame_Next_0 = 0;
#ifdef ADC0_12dB
    RD1 = 0x3f0000;
#endif
#ifdef ADC0_15dB
    RD1 = 0x7f0000;
#endif      
L_ADC0_StrongSignal_3:
    //ADC_Cfg更新
    RD0 = g_ADC_CFG_0;
    RD0_ClrByteH16;
    RD0 += RD1;
    g_ADC_CFG_0 = RD0;
    RF_RotateR16(RD1);

    RD0 = RN_ADCPORT_AGC0;
    ////Try ADC
    ADC_CPUCtrl_Enable;
    //配置ADC0    
    ADC_PortSel = RD0;
    ADC_Cfg = RD1;
    RD0 = 0;
    ADC_PortSel = RD0;
    ADC_CPUCtrl_Disable;
  
L_ADC0_StrongSignal_End: 
     Return_AutoField(0);     


//////////////////////////////////////////////////////////////////////////
//  名称:
//      ADC0_Bias_Adj;
//  功能:
//      直流配置值调整
//  参数:
//      RD0:当前512帧平均值
//  返回值：
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField ADC0_Bias_Adj;

    RD2 = RD0;
    
    RF_Abs(RD0);
    RD0 -= 255; //去直流调整阈值
    if(RQ_Borrow) goto L_ADC0_Bias_Adj_End;     // Vpp<x时，不再调整
    RD0 = RD2;
    if(RD0_Bit15 == 0) goto L_ADC0_Bias_Adj_1;  // 判平均值符号
    //均值为负
    RD0 = g_LastBank_Average_0;                 // 高8位为直流配置值；低16位为前512帧平均值，权位为0；bit16为当前块（512帧）是否改过档位的标志位，1：改过，0：未改过  
    RF_GetH8(RD0);  //直流配置值
    RD1 = 15;
    RD1 -= RD0;
    if(RQ == 0) goto L_ADC0_Bias_Adj_End; //判溢出
    //未溢出
    RD0 ++;
    Volt_Vref2 = RD0;   //修正档位
	RD0 = g_LastBank_Average_0;
	RD1 = 0x1000000;
	RD0 += RD1;  
    g_LastBank_Average_0 = RD0;
    goto L_ADC0_Bias_Adj_End;    
L_ADC0_Bias_Adj_1:  //均值为正
    RD0 = g_LastBank_Average_0;                   // 高8位为直流配置值；低16位为前512帧平均值，权位为0；bit16为当前块（512帧）是否改过档位的标志位，1：改过，0：未改过  
    RF_GetH8(RD0);  //直流配置值
    if(RD0 == 0) goto L_ADC0_Bias_Adj_End; //判溢出
    RD0 --;
    Volt_Vref2 = RD0;   //修正档位        
	RD0 = g_LastBank_Average_0;
	RD1 = 0x1000000;
	RD0 -= RD1;  
    g_LastBank_Average_0 = RD0;
    
L_ADC0_Bias_Adj_End:
    
    Return_AutoField(0*MMU_BASE);

//////////////////////////////////////////////////////////////////////////
//  名称:
//      ADC0_Step;
//  功能:
//      每512帧更新下一块平均值，并清零平均值累加器
//  参数:
//      无
//  返回值：
//      RD0:当前512帧数据实际平均值（复原后）
//////////////////////////////////////////////////////////////////////////
Sub_AutoField ADC0_Step;

    RD0 = g_ADC_DC_0;   //平均值累加器，512帧数据累加和，每帧32个点     
    RF_Sft32SR8(RD0); 
    RF_Sft32SR4(RD0); 
    RF_Sft32SR2(RD0);   //2^14个数据平均值 X-C0 
    RD1 = RD0;  //Y=X-C0
    RF_Sft32SR2(RD1);   //1/4*Y
    RD2 = RD0;  //Y
    RD0 = g_LastBank_Average_0;   //高8位为直流配置值；低16位为前512帧平均值，权位为0； 
    RD0_SignExtL16; //C0
    RD1 += RD0;     //1/4*Y+C0=1/4*(C1-C0)+C0,C1=X=Y+C0,下一块平均值应为C1，降低步长为1/4，减少噪音
    RD0 += RD2;     //X=Y+C0
    RD2 = RD0;
    RD0 = RD1;
    RD0_ClrByteH16;    
    RD1 = RD0;
    RD0 = g_LastBank_Average_0;   //高8位为直流配置值；低16位为前512帧平均值，权位为0；    
    RD0_ClrByteL16;
    RD0 += RD1;
    g_LastBank_Average_0 = RD0;
    g_ADC_DC_0 = 0;   //平均值累加器清零
    
    RD0 = RD2;
    Return_AutoField(0*MMU_BASE);
    
    
//////////////////////////////////////////////////////////////////////////
//  名称:
//      Find_k
//  功能:
//      通过总增益计算DAC档位配置值，以及k与移位个数。总音量=-6*n-k，0<=k<6。n∈非负整数 
//  参数:
//      RD0:总增益，32bit有符号数,单位dB
//  返回值：
//		RD0:k
//		RD1:右移位数
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Find_k;

    RD2 = 0;

    if(RD0_Bit31 == 1) goto L_Find_k_0;
    if(RD0_nZero) goto L_Find_k_1;
    //0dB
    RD0 = 0x8080;
    RD1 = 0;
    goto L_Find_k_End;
        
L_Find_k_1:        
    // 总增益>0
    RD0 = 0xF0C0;
    RD1 = 0;
    goto L_Find_k_End;           
    
L_Find_k_0:  
    //总增益为负数
    RD0 += 5;
    if(RD0_Bit31 == 1) goto L_Find_k_2;
    //-1~-5dB
    RD1 = 5;
    RD1 -= RD0;
    RD0 = 0x8080;
    goto L_Find_k_End;
                      
L_Find_k_2:
    RD0 += 6;
    if(RD0_Bit31 == 1) goto L_Find_k_3;
    //-6~-11dB
    RD1 = 5;
    RD1 -= RD0;
    RD0 = 0x8040;
    goto L_Find_k_End;
    
L_Find_k_3:    
    RD0 += 6;
    if(RD0_Bit31 == 1) goto L_Find_k_4;
    //-12~-17dB
    RD1 = 5;
    RD1 -= RD0;
    RD0 = 0x8000;
    goto L_Find_k_End;
    
L_Find_k_4:    
    RD0 += 6;
    if(RD0_Bit31 == 1) goto L_Find_k_5;
    //-18~-23dB
    RD1 = 5;
    RD1 -= RD0;
    RD0 = 0x4000;
    goto L_Find_k_End;

L_Find_k_5:    
    RD0 += 6;
    if(RD0_Bit31 == 1) goto L_Find_k_6;
    //-24~-29dB
    RD1 = 5;
    RD1 -= RD0;
    RD0 = 0x2000;
    goto L_Find_k_End;

L_Find_k_6:    
    RD0 += 6;
    if(RD0_Bit31 == 1) goto L_Find_k_7;
    //-30~-35dB
    RD1 = 5;
    RD1 -= RD0;
    RD0 = 0x1000;
    goto L_Find_k_End;

L_Find_k_7:
    RD0 += 6;
    RD2 ++;
    if(RD0_Bit31 == 1) goto L_Find_k_7;
    //<-35dB
    RD1 = 5;
    RD1 -= RD0;
    RD0 = 0x1000;
    
    RD2 -= 14;
    if(RQ_Borrow) goto L_Find_k_8;
    RD2 = 0;
L_Find_k_8: 
    RD2 += 14;   
L_Find_k_End:
    RD3 = RD0;    
	RD0 = g_DAC_Cfg;
    RD0_ClrBit6;
    RD0_ClrBit7;
    RD0_ClrBit12;
    RD0_ClrBit13;
    RD0_ClrBit14;
    RD0_ClrBit15;   //g_DAC_Cfg初始化，清零配置位
    RD0 += RD3;
    g_DAC_Cfg = RD0;    
    
    RD0 = RD1;
    RD1 = RD2;

    Return_AutoField(0*MMU_BASE);

//////////////////////////////////////////////////////////////////////////
//  名称:
//      DAC_Tab
//  功能:
//      通过k查表得出乘法器参数c
//  参数:
//      RD0:k
//  返回值：
//		RD0:c
//////////////////////////////////////////////////////////////////////////
Sub_AutoField DAC_Tab;
     
    if(RD0_Zero) goto L_DAC_Tab_0;
    RD0 --;
    if(RQ_Zero) goto L_DAC_Tab_1;
    RD0 --;
    if(RQ_Zero) goto L_DAC_Tab_2;
    RD0 --;
    if(RQ_Zero) goto L_DAC_Tab_3;
    RD0 --;
    if(RQ_Zero) goto L_DAC_Tab_4;
    //余数k=5
    RD0 = 0x0FF60FF6;   
    goto L_DAC_Tab_End;
L_DAC_Tab_0:
    //余数k=0    
    RD0 = 0;        
    goto L_DAC_Tab_End;
L_DAC_Tab_1:
    //余数k=1
    RD0 = 0x64296429;    
    goto L_DAC_Tab_End;
L_DAC_Tab_2:
    //余数k=2,
    RD0 = 0x4B594B59;    
    goto L_DAC_Tab_End;
L_DAC_Tab_3:
    //余数k=3   
    RD0 = 0x353B353B; 
    goto L_DAC_Tab_End;
L_DAC_Tab_4:
    //余数k=4    
    RD0 = 0x21862186;   
       
L_DAC_Tab_End:
    Return_AutoField(0*MMU_BASE);
    
    
    
        
END SEGMENT
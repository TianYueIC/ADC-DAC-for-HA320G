////////////////////////////
// AD_DA_330G.asm for HA330G (Chip Core:HA320G)
// WENDI YANG 2021/12/1 17:08:21
////////////////////////////
//      Modified Notes
//      1.  DAC由直通变为先插值。在sendDAC函数中实现插值。
//      2.  校准不包含在ADDA init中
//      3.  加入500Hz高通
//      4. 
////////////////////////////

#define _AD_DA_330G_F_

#include <CPU11.def>
#include <resource_allocation.def>
#include <RN_DSP_Cfg.def>
#include <Global.def>
#include <DMA_ParaCfg.def>
#include <DspHotLine_330G.def>
#include <AD_DA_330G.def>
#include <Trimming.def> //单片测试用


extern _DMA_ParaCfg_Flow2;	//1/8插值！


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
//        (a)帧计数器,       g_Cnt_Frame: 低16位为帧计数器，最高8位为连续小信号帧计数器
//        (b)每一路MIC需要4个全局变量
//      	(1)帧权位,       g_Weight_Frame
//      	(2)前一帧权位,   g_Weight_Frame_Last
//      	(3)平均值累加器, g_ADC_DC ：高8位为直流配置值，低24位为平均值累加器
//      	(4)配置值寄存器, g_ADC_CFG ：高16位ADC前置放大器放大倍数,低16位ADC_CFG端口配置值
//      3.DAC使用的全局变量-----------------------------（全局变量待修改更新）
//
////////////////////////////////////////////////////////
Sub_AutoField AD_DA_INIT_330G;
	RD3 = RD0; //暂存MIC配置
	
		//---------------------------------------
		//(a)DSP的初始化；
		//配置DSP工作时钟
    RD0 = RN_CFG_DSP48M+RN_CFG_FLOW_DIV4;  //Slow = 8MHz 1/8降采样！DAC过采样OSR = 2
    //RD0 = RN_CFG_DSP48M+RN_CFG_FLOW_DIV2;  //TEST!//Slow = 16MHz !!!!!!!!!!!!!!!!!!!!!!
    //RD0 = RN_CFG_DSP48M+RN_CFG_FLOW_DIVPASS;  //TEST!//Slow = 32MHz !!!!!!!!!!!!!!!!!!!!!!
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
	
		//初始化IIR_PATH3滤波器，用于对原始信号进行高通滤波(用于去除ADDA测试中的500Hz尖峰)
    IIR_PATH3_Enable;
    MemSetRAM4K_Enable;
    RD0 = 0x0;// Para0, Data00
    IIR_PATH3_BANK = RD0;
		call IIR_PATH3_HP500Init;
    IIR_PATH3_Disable;
    MemSet_Disable;
		
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
//      (a)帧计数器,       			  g_Cnt_Frame
//      (b)每一路MIC需要4个全局变量
//        (1)帧权位					  g_Weight_Frame_0 : 高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
//        (2)前一块（512帧）平均值    g_LastBank_Average_0 : 高8位为直流配置值；低16位为前512帧平均值，权位为0；bit16为当前块（512帧）是否改过档位的标志位，1：改过，0：未改过 
//        (3)平均值累加器             g_ADC_DC_0 ：平均值累加器,权位为0
//        (4)配置值寄存器             g_ADC_CFG_0 ：高16位ADC前置放大器配置值，低16位ADC_CFG端口配置值
//
////////////////////////////////////////////////////////
Sub_AutoField ADC_INIT_330G;
		//ADC全局变量初始化
		g_Cnt_Frame = 0;        
		//MIC0全局变量初始化
		g_Weight_Frame_0 = 0;
		RD1 = 0x07000000;
		g_LastBank_Average_0 = RD1;
		g_ADC_DC_0 = 0; //g_ADC_DC ：平均值累加器,权位为0
		RD1 = 0x003F07C7;
		g_ADC_CFG_0 = RD1; //g_ADC_CFG ：高16位ADC前置放大器放大倍数,低16位ADC_CFG端口配置值
		//MIC1全局变量初始化
		g_Weight_Frame_1 = 0;
		RD1 = 0x07000000;
		g_LastBank_Average_1 = RD1;
		g_ADC_DC_1 = 0; //g_ADC_DC ：平均值累加器,权位为0
		RD1 = 0x003F07C7;
		g_ADC_CFG_1 = RD1; //g_ADC_CFG ：高16位ADC前置放大器放大倍数,低16位ADC_CFG端口配置值

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
	ADC_FiltHD = RD0;
	RD0 = 0x8D2B;
	ADC_FiltHD = RD0;
	RD0 = 0x0674;
	ADC_FiltHD = RD0;
	RD0 = 0x8D2B;
	ADC_FiltHD = RD0;
	RD0 = 0x083D;
	ADC_FiltHD = RD0;
	RD0 = 0x7358;
	ADC_FiltHD = RD0;
	RD0 = 0xD00A;
	ADC_FiltHD = RD0;
	RD0 = 0x64F7;
	ADC_FiltHD = RD0;
	RD0 = 0x9850;
	ADC_FiltHD = RD0;
	ADC_FiltHD = RD0;
	
	//  IIR1
	//  05A2, 93C2, 0E4A, 93C2, 05A2
	//        73FB, D191, 692F, 9A4F
	RD0 = 0x05A2;
	ADC_FiltHD = RD0;
	RD0 = 0x93C2;
	ADC_FiltHD = RD0;
	RD0 = 0x0E4A;
	ADC_FiltHD = RD0;
	RD0 = 0x93C2;
	ADC_FiltHD = RD0;
	RD0 = 0x05A2;
	ADC_FiltHD = RD0;
	RD0 = 0x73FB;
	ADC_FiltHD = RD0;
	RD0 = 0xD191;
	ADC_FiltHD = RD0;
	RD0 = 0x692F;
	ADC_FiltHD = RD0;
	RD0 = 0x9A4F;
	ADC_FiltHD = RD0;
	ADC_FiltHD = RD0;
	
	//  IIR2
	//  042B, 8D96, 09A0, 8D96, 042B
	//        7399, D0B9, 66F3, 9949
	RD0 = 0x042B;
	ADC_FiltHD = RD0;
	RD0 = 0x8D96;
	ADC_FiltHD = RD0;
	RD0 = 0x09A0;
	ADC_FiltHD = RD0;
	RD0 = 0x8D96;
	ADC_FiltHD = RD0;
	RD0 = 0x042B;
	ADC_FiltHD = RD0;
	RD0 = 0x7399;
	ADC_FiltHD = RD0;
	RD0 = 0xD0B9;
	ADC_FiltHD = RD0;
	RD0 = 0x66F3;
	ADC_FiltHD = RD0;
	RD0 = 0x9949;
	ADC_FiltHD = RD0;
	ADC_FiltHD = RD0;
	
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
		RD0 = g_LastBank_Average_1;			//g_LastBank_Average_1 : 高8位为直流配置值
		RF_GetH8(RD0);
		Volt_Vref3 = RD0;
		
    //配置MIC1 AGC增益
		RD0 = RN_ADCPORT_AGC1;
		RD1 = RD3;
		RF_GetH16(RD1);
		ADC_CPUCtrl_Enable;	
    ADC_PortSel = RD0;    
    ADC_Cfg = RD1;
    
    //配置MIC1 ADC_CFG
    RD0 = RN_ADCPORT_ADC1CFG;
 		RD1 = ADC_CFG_Init;
    ADC_PortSel = RD0;    
    ADC_Cfg = RD1;
    
    //归还端口
    RD0 = 0;
    ADC_PortSel = RD0;
    ADC_CPUCtrl_Disable;
    
    RD1 = RD3;
    RF_GetH16(RD1);
		RF_RotateL16(RD1);//配置值寄存器, g_ADC_CFG ：高16位ADC前置放大器放大倍数
		RD0 = ADC_CFG_Init;
    RD1 += RD0;
    g_ADC_CFG_1 = RD1;//配置值寄存器写回
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
//        (a)配置值寄存器, g_DAC_Cfg ：低16位DAC_CFG端口配置值 bit15-12:IIR输出增益；bit7 6：CIC输出增益。1000 01是默认值，此时0dB
//        (b)g_Vol：音量档位（dB），暂定32bit定点数
//
////////////////////////////////////////////////////////
Sub_AutoField DAC_INIT_330G;
		//DAC全局变量初始化初始化
        //RD0 = 0x802300;   //测试用，7.5X ,16bit满幅数据输出满幅!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		RD0 = 0x8083C0;   //E=0
		//RD0 = 0x808380;   //测试用，E=-6
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
    //call IIR_SetLP_88DB_DAC330G;//1/8 带滤波器,4段,第4段B系数的增益可调整
    call IIR_SetLP_99DB_DAC330G;//1/8 带滤波器,4段,3段4段换位置，2021/12/2 10:31:06（待发布的版本，E需要调整）
    
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
    
    //TEST!
    RD0 = RN_PRAM_START+DMA_ParaNum_Flow*MMU_BASE*8;
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
    RD0 = DMA_nParaNum_Flow;
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
    RD0 = 0;//Bank偏移地址，字节
    send_para(RD0);
		RD0 = AD_Buf_Len;//4MHz
    send_para(RD0);
    RD0 = RN_CFG_FLOW_TYPE3;//Slow = 8MHz
    send_para(RD0);
    call _DMA_ParaCfg_Flow2;

    //选择DMA_Flow通道，并启动运算
    RD0 = 0x80;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_Flow;
    ParaMem_Addr = RD0;

    // 使能DAC Class-D 输出
    SDM_DRV0_ENABLE;    //1倍驱动，默认值，不修改
    //SDM_DRV1_ENABLE;    //2倍驱动
    //SDM_DRV0_ENABLE;SDM_DRV1_ENABLE;    //3倍驱动
		
Return_AutoField(0*MMU_BASE);


////////////////////////////////////////////////////////
//  名称:
//      IIR_SetLP_88DB_DAC330G
//  功能:
//      初始化用于1/8抽点的DAC330G四段13阶低通滤波器
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
//				 tianyue_hearingaid_low_pass_1_8 for DAC Upsampling, 2021/11/28 0:20:10
//				 [7200,8200,0.01,90], fs=128000, G1_recip = 17259（标准）, iir_seg = 4, N = 13; G1_recip = 64（降增益）
//				 gain= 0.029dB, rpc=0.61dB, rsc=-89.94dB, rsc8000=-108.28dB, fp3db = 7311Hz（标准）;
//				 gain=-48.70dB, rpc=0.54dB, rsc=-88.50dB, rsc8000=-117.38dB, fp3db = 7311Hz（降增益）;
//				 段调整前的各段增益:
//				 gain_seg0 = [23.291227497870580, 26.096926326771687, 32.334240764604374, 3.046531884514397]（标准）
//				 gain_seg2 = [6.077319286673054,  5.879658371710145,  24.073716735368698, 0.009488391848975]（降增益）;
//				 段调整后的各段增益:
//				 gain_seg0 = [32.334240764604374, 23.291227497870580, 26.096926326771687, 3.046531884514397]（标准）
//				 gain_seg2 = [24.073716735368698, 6.077319286673054,  5.879658371710145,  0.009488391848975]（降增益）;
//				
//				  G1_recip =
//				      1000
//				  b11 =
//				          3168       -8871       11988       -8871        3168
//				  a11 =
//				          8192      -29122       39768      -24644        5837
//				  b21 =
//				          1122        -942        -942        1122
//				  a21 =
//				          8192      -22148       20889       -6788
//				  b31 =
//				           812       -2754        3954       -2754         812
//				  a31 =
//				          8192      -29199       40067      -25032        6017
//				  b41 =
//				          5769      -10660        5769
//				  a41 =
//				          8192      -15277        8120
////////////////////////////////////////////////////////
Sub_AutoField IIR_SetLP_88DB_DAC330G;
    // RD0 = 0x01A1;        // CFG

    //  IIR0
    //  0C60, A2A7, 176A, A2A7, 0C60
    //        71C2, CDAC, 6044, 96CD
    RD0 = 0x0C60;
    DAC_IIR1_HD = RD0;  //b0
    RD0 = 0xA2A7;
    DAC_IIR1_HD = RD0;  //b1
    RD0 = 0x176A;
    DAC_IIR1_HD = RD0;  //b2
    RD0 = 0xA2A7;
    DAC_IIR1_HD = RD0;  //b3
    RD0 = 0x0C60;
    DAC_IIR1_HD = RD0;  //b4
    RD0 = 0x71C2;
    DAC_IIR1_HD = RD0;  //a1
    RD0 = 0xCDAC;
    DAC_IIR1_HD = RD0;  //a2
    RD0 = 0x6044;
    DAC_IIR1_HD = RD0;  //a3
    RD0 = 0x96CD;
    DAC_IIR1_HD = RD0;  //a4
    DAC_IIR1_HD = RD0;  //空写一个

    //  IIR1
    //  0462, 83AE, 81D7, 0462, 0000
    //        5684, A8CC, 1A84, 8000
    RD0 = 0x0462;
    DAC_IIR1_HD = RD0;  //b0
    RD0 = 0x83AE;
    DAC_IIR1_HD = RD0;  //b1
    RD0 = 0x81D7;
    DAC_IIR1_HD = RD0;  //b2
    RD0 = 0x0462;
    DAC_IIR1_HD = RD0;  //b3
    RD0 = 0x0000;
    DAC_IIR1_HD = RD0;  //b4
    RD0 = 0x5684;
    DAC_IIR1_HD = RD0;  //a1
    RD0 = 0xA8CC;
    DAC_IIR1_HD = RD0;  //a2
    RD0 = 0x1A84;
    DAC_IIR1_HD = RD0;  //a3
    RD0 = 0x8000;
    DAC_IIR1_HD = RD0;  //a4
    DAC_IIR1_HD = RD0;  //空写一个

    //  IIR2
    //  032C, 8AC2, 07B9, 8AC2, 032C
    //        720F, CE41, 61C8, 9781
    RD0 = 0x032C;
    DAC_IIR1_HD = RD0;  //b0
    RD0 = 0x8AC2;
    DAC_IIR1_HD = RD0;  //b1
    RD0 = 0x07B9;
    DAC_IIR1_HD = RD0;  //b2
    RD0 = 0x8AC2;
    DAC_IIR1_HD = RD0;  //b3
    RD0 = 0x032C;
    DAC_IIR1_HD = RD0;  //b4
    RD0 = 0x720F;
    DAC_IIR1_HD = RD0;  //a1
    RD0 = 0xCE41;
    DAC_IIR1_HD = RD0;  //a2
    RD0 = 0x61C8;
    DAC_IIR1_HD = RD0;  //a3
    RD0 = 0x9781;
    DAC_IIR1_HD = RD0;  //a4
    DAC_IIR1_HD = RD0;  //空写一个

    /*
    //  IIR3
    //  1689, A9A4, 0B44, 0000, 0000
    //        3BAD, 8FDC, 8000, 8000
    RD0 = 0x1689;
    DAC_IIR1_HD = RD0;  //b0
    RD0 = 0xA9A4;
    DAC_IIR1_HD = RD0;  //b1
    RD0 = 0x0B44;
    DAC_IIR1_HD = RD0;  //b2
    RD0 = 0x0000;
    DAC_IIR1_HD = RD0;  //b3
    RD0 = 0x0000;
    DAC_IIR1_HD = RD0;  //b4
    RD0 = 0x3BAD;
    DAC_IIR1_HD = RD0;  //a1
    RD0 = 0x8FDC;
    DAC_IIR1_HD = RD0;  //a2
    RD0 = 0x8000;
    DAC_IIR1_HD = RD0;  //a3
    RD0 = 0x8000;
    DAC_IIR1_HD = RD0;  //a4
    DAC_IIR1_HD = RD0;  //空写一个
    */
    //  IIR3
    //  B系数x2,注意符号位！
    //  1689, A9A4, 0B44, 0000, 0000
    //        3BAD, 8FDC, 8000, 8000
    RD0 = 0x2D12;
    DAC_IIR1_HD = RD0;  //b0
    RD0 = 0xD348;
    DAC_IIR1_HD = RD0;  //b1
    RD0 = 0x1689;
    DAC_IIR1_HD = RD0;  //b2
    RD0 = 0x0000;
    DAC_IIR1_HD = RD0;  //b3
    RD0 = 0x0000;
    DAC_IIR1_HD = RD0;  //b4
    RD0 = 0x3BAD;
    DAC_IIR1_HD = RD0;  //a1
    RD0 = 0x8FDC;
    DAC_IIR1_HD = RD0;  //a2
    RD0 = 0x8000;
    DAC_IIR1_HD = RD0;  //a3
    RD0 = 0x8000;
    DAC_IIR1_HD = RD0;  //a4
    DAC_IIR1_HD = RD0;  //空写一个

    Return_AutoField(0*MMU_BASE);


//================================================================================
// tianyue_hearingaid_low_pass_1_8 for DAC Upsampling, 2021/12/2 10:19:20
// [7200,8200,0.005,100], fs=128000, iir_seg = 4, N = 14, G1_recip = 44713 to 256;
// gain=-0.002dB, rpc=0.39dB, rsc=-99.75dB, rsc8000=-83.36dB, G1_recip=44713（标准）;
// gain2=-44.83dB, rpc=0.36dB, rsc=-99.11dB, rsc8000=-83.34dB, G1_recip=256（降增益）;
// gain_seg0 = [38.193689348040017, 23.547025892242225, 27.997751599320949, 3.269089063469961]（标准）
// gain_seg2 = [24.094138795835576,  5.958783905151940,  6.015049518999269,  12.111050198676283]（降增益）;
//
// G1_recip =
//    1000
// b11 =
//         1614       -2236        1886       -2236        1614
// a11 =
//         8192      -29180       39935      -24782        5859
// b21 =
//         1089       -3765        5429       -3765        1089
// a21 =
//         8192      -29334       40554      -25589        6231
// b31 =
//        11245      -20746       11245
// a31 =
//         8192      -15275        8121
// b41 =
//         1305       -4122        5790       -4122        1305
// a41 =
//         8192      -29245       40207      -25150        6035
//
//================================================================================
//第3段，S18，空缺1bit。
//1-2段，S19，正常
//4段，S20，正常
Sub_AutoField IIR_SetLP_99DB_DAC330G;
// RD0 = 0x01A1;        // CFG

//  IIR0
//  064E, 88BC, 03AF, 88BC, 064E
//  71FC, CDFF, 60CE, 96E3
RD0 = 0x064E;
DAC_IIR1_HD = RD0;  //b0
RD0 = 0x88BC;
DAC_IIR1_HD = RD0;  //b1
RD0 = 0x03AF;
DAC_IIR1_HD = RD0;  //b2
RD0 = 0x88BC;
DAC_IIR1_HD = RD0;  //b3
RD0 = 0x064E;
DAC_IIR1_HD = RD0;  //b4
RD0 = 0x71FC;
DAC_IIR1_HD = RD0;  //a1
RD0 = 0xCDFF;
DAC_IIR1_HD = RD0;  //a2
RD0 = 0x60CE;
DAC_IIR1_HD = RD0;  //a3
RD0 = 0x96E3;
DAC_IIR1_HD = RD0;  //a4
DAC_IIR1_HD = RD0;  //空写一个

//  IIR1
//  0441, 8EB5, 0A9A, 8EB5, 0441
//  7296, CF35, 63F5, 9857 
RD0 = 0x0441;
DAC_IIR1_HD = RD0;  //b0
RD0 = 0x8EB5;
DAC_IIR1_HD = RD0;  //b1
RD0 = 0x0A9A;
DAC_IIR1_HD = RD0;  //b2
RD0 = 0x8EB5;
DAC_IIR1_HD = RD0;  //b3
RD0 = 0x0441;
DAC_IIR1_HD = RD0;  //b4
RD0 = 0x7296;
DAC_IIR1_HD = RD0;  //a1
RD0 = 0xCF35;
DAC_IIR1_HD = RD0;  //a2
RD0 = 0x63F5;
DAC_IIR1_HD = RD0;  //a3
RD0 = 0x9857;
DAC_IIR1_HD = RD0;  //a4
DAC_IIR1_HD = RD0;  //空写一个

//  IIR2
//  2BED, D10A, 15F6, 0000, 0000 
//  3BAB, 8FDC, 8000, 8000
RD0 = 0x2BED;
DAC_IIR1_HD = RD0;  //b0
RD0 = 0xD10A;
DAC_IIR1_HD = RD0;  //b1
RD0 = 0x15F6;
DAC_IIR1_HD = RD0;  //b2
RD0 = 0x0000;
DAC_IIR1_HD = RD0;  //b3
RD0 = 0x0000;
DAC_IIR1_HD = RD0;  //b4
RD0 = 0x3BAB;
DAC_IIR1_HD = RD0;  //a1
RD0 = 0x8FDC;
DAC_IIR1_HD = RD0;  //a2
RD0 = 0x8000;
DAC_IIR1_HD = RD0;  //a3
RD0 = 0x8000;
DAC_IIR1_HD = RD0;  //a4
DAC_IIR1_HD = RD0;  //空写一个

//  IIR3
//  0519, 901A, 0B4F, 901A, 0519
//  723D, CE87, 623E, 9793
RD0 = 0x0519;
DAC_IIR1_HD = RD0;  //b0
RD0 = 0x901A;
DAC_IIR1_HD = RD0;  //b1
RD0 = 0x0B4F;
DAC_IIR1_HD = RD0;  //b2
RD0 = 0x901A;
DAC_IIR1_HD = RD0;  //b3
RD0 = 0x0519;
DAC_IIR1_HD = RD0;  //b4
RD0 = 0x723D;
DAC_IIR1_HD = RD0;  //a1
RD0 = 0xCE87;
DAC_IIR1_HD = RD0;  //a2
RD0 = 0x623E;
DAC_IIR1_HD = RD0;  //a3
RD0 = 0x9793;
DAC_IIR1_HD = RD0;  //a4
DAC_IIR1_HD = RD0;  //空写一个

Return_AutoField(0*MMU_BASE);




////////////////////////////////////////////////////////
//  名称:
//      IIR_PATH3_HP500Init
//  功能:
//      设置高通滤波器系数
//  参数:
//      无？？？
//  返回值:
//      无
//  注释:
//      [50,500,0.1,40], fs=16000, G1_recip=1, iir_seg = 1
//      gain = 0.00dB, rpc = 0.23dB, rsc = -40.07dB 
//      G1_recip =
//           1
//      b11 =
//              8192      -24557       24557       -8192
//      a11 =
//              8192      -22116       20013       -6058
////////////////////////////////////////////////////////
    Sub_AutoField IIR_PATH3_HP500Init;
    
    // HA330G_FW_HP_iir_ellip_16000_50_500_0.1_40.txt
    //转换成功
    //配置值	0x0042
    //最终增益	1
    //最终段数	4
    //没有绝对值大于32767的数
    
    RD0 = 0x7FFF;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0042;
    IIR_PATH3_HD = RD0;
    RD0 = 0x7FFF;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0042;
    IIR_PATH3_HD = RD0;
    RD0 = 0x7FFF;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0042;
    IIR_PATH3_HD = RD0;
    RD0 = 0x2000;
    IIR_PATH3_HD = RD0;     // b0
    RD0 = 0xDFED;
    IIR_PATH3_HD = RD0;     // b1
    RD0 = 0x5FED;
    IIR_PATH3_HD = RD0;     // b2
    RD0 = 0xA000;
    IIR_PATH3_HD = RD0;     // b3
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;     // b4
    RD0 = 0x5664;
    IIR_PATH3_HD = RD0;     // a1
    RD0 = 0xCE2D;
    IIR_PATH3_HD = RD0;     // a2
    RD0 = 0x17AA;
    IIR_PATH3_HD = RD0;     // a3
    RD0 = 0x8000;
    IIR_PATH3_HD = RD0;     // a4
    RD0 = 0x0042;
    IIR_PATH3_HD = RD0;     // CFG
    
    //寄存器地址复位
    IIR_PATH3_CLRADDR;
    Return_AutoField(0*MMU_BASE);

END SEGMENT
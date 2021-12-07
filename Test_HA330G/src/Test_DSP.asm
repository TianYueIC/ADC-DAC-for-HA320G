#define _Test_MultiArray_F_

#include <cpu11.def>
#include <resource_allocation.def>
#include <DMA_ALU.def>
#include <DMA_ParaCfg.def>
#include <RN_DSP_Cfg.def>
#include <USI.def>
#include <GPIO.def>
#include <Global.def>
#include <string.def>
#include <MAC.def>
#include <ALU.def>
#include <GPIO.def>
#include <Debug.def>
#include <usi.def>
#include <SOC_Common.def>
#include <SPI_Master.def>
#include <IIR.def>
#include <MATH.def>
#include <Init.def>
#include <Debug.def>
#include <Trimming.def>
#include <AD_DA_330G.def>
#include <DspHotLine_330G.def>

extern _DMA_ParaCfg_Flow;
extern UART_PutDword_COM1;
extern UART_Init;
extern UART_Putchar_COM1;
//========================================
//仿真&硬件选择
//========================================
#define OnBoardChip_test  //硬件实测
//#define Calibration_byHand  //开启手动校准
//#define Simulation_byCadence  //仿真
#define         RN_SPI_CLK_CFG                  0x7ffffffc;//32000000/8000000/2 = 2


///////////////////////////////////////
//Rom 程序标准头
///////////////////////////////////////
CODE SEGMENT Test_Main_F;
//中断向量表
//-------------------------
//中断0~6只能到ROM
// ... ...
//
L_Test_Main0:
		CPU_SimpleLevel_L;

	
	
	Set_CPUSpeed5;
	//Set_CPUSpeed2;
	//Set_CPUSpeed1;
	
    //地址初始化
    RD0 = RN_RSP_START;
    RD1 = RN_PARA_TOTAL_LEN_B;
    RD0 -= RD1;
    RSP = RD0;
    RA4 = RD0;
    RD0 = RN_Const_StartAddr;
    RA5 = RD0;
    RD0 = PortExt_Addr;
    RA6 = RD0;
    
L_Calibration:
	//(a)基准电压Vref\Vcore、基准频率的初始化；
	//---Speed3下配置
	RD1 = RN_SP3;
    RP_B15;
    Set_Pulse_Ext8;
    nop;nop;
    
	//---Set Vref
    RD0 = RN_VREF_VAL;
    RF_Not(RD0);
    StandBy_WRCfg = RD0;
    
    //---Set OSC
    RD0 = 0;
    RD0_SetBit19;
    StandBy_WRSel = RD0;
    RD0 = RN_FREQ_VAL;
    StandBy_WRCfg = RD0;
    RD2 = 2000;     //延迟1ms等待频率稳定
    call _Delay_RD2;
    
	  //---CPU工作电压调节1.2V
	RD0 = 0;
	RD0_SetBit22;
	StandBy_WRSel = RD0;
	//RD0 = 0b110000;  //基准电压调节值
	RD0 = 0b111011;  //基准电压调节值,固定值！
	RF_Not(RD0);
	StandBy_WRCfg = RD0;
	//---//测试用
	//L_TEST_FREQ:			
	//	CPU_SimpleLevel_H;
	//	nop;
	//	CPU_SimpleLevel_L;
	//	goto L_TEST_FREQ;	
	
	//5ms等待稳定时间
	#ifdef OnBoardChip_test  //测试用
	RD2 = 2000*5;
	call _Delay_RD2;
	#endif  //测试用    
    
#ifdef Simulation_byCadence
    RD0 = 0x11171016;
    Debug_Reg32 = RD0;
#endif


    //GP0_3  ，按键
    RD0 = GP0_3;
    GPIO_WEn0 = RD0;
    RD0 = GPIO_IN|GPIO_PULL;
    GPIO_Set0 = RD0;
    RD0 = GP0_7;
    GPIO_WEn0 = RD0;
    RD0 = GPIO_IN|GPIO_PULL;
    GPIO_Set0 = RD0;

    //RD0 = 0b11;//使能双MIC
    //RD0 = 0b10;//使能MIC1
	//RD0 = 0b01;//使能MIC0
	RD0 = 0b01;//使能MIC0
	call AD_DA_INIT_330G;
    RD2 = 4000*2000;
    call _Delay_RD2;// 延时10ms等待信号稳定（切换通道后信号建立时间<1ms）


#ifdef OnBoardChip_test  
L_UART_init:
		call UART1_Initial;
		
		RD0 = 0xABCDEF5A;
		send_para(RD0);
		call UART_PutDword_COM1;
		RD0 = 0xABCDEF5A;
		send_para(RD0);
		call UART_PutDword_COM1;
#endif
/*
    RD0 = RN_GRAM3;
    RA1 = RD0;
	//写测试数据
    MemSetRAM4K_Enable; //使用扩展端口或RAM特殊配置时使能
    RD0 = DMA_PATH0;
    M[RA1] = RD0;
    MemSet_Disable;     //配置结束
    
    CPU_WorkEnable;
    CPU_SimpleLevel_H;
    RD0 = 0x30fb0000;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0x76415a82;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0x76417fff;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0x30fb5a82;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0xcf050000;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0x89bfa57e;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0x89bf8001;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0xcf05a57e;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0x30fb0000;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0x76415a82;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0x76417fff;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0x30fb5a82;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0xcf050000;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0x89bfa57e;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0x89bf8001;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0xcf05a57e;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    CPU_WorkDisable;
*/		
		
			//开始测试！等待按键GP0-3
L_Wait_Key0:
	
	CPU_SimpleLevel_L;
	nop; nop; nop; nop;
	RD0 = GPIO_Data0;
#ifdef OnBoardChip_test
	//if(RD0_Bit3 == 1) goto L_Wait_Key0;
#endif
   
    
    CPU_SimpleLevel_H;
    
    //goto L_Wait_Key0;


    RD0 = 0;
    g_Vol = RD0;    //音量调整值
Loop:   //main
    
    call Get_ADC;
    nop;nop;nop;nop;
    if(RD0_nZero) goto Loop;
/*
//使用测试数据替代ADC输入
    RD0 = RN_GRAM_IN;
    RA1 = RD0;
	//写测试数据
    MemSetRAM4K_Enable; //使用扩展端口或RAM特殊配置时使能
    RD0 = DMA_PATH0;
    M[RA1] = RD0;
    MemSet_Disable;     //配置结束
    
    CPU_WorkEnable;
    CPU_SimpleLevel_H;

    //1kHz正弦信号
    RD0 = 0x30fb0000;
    M[RA1++] = RD0;
    RD0 = 0x76415a82;
    M[RA1++] = RD0;
    RD0 = 0x76417ffe;//
    M[RA1++] = RD0;
    RD0 = 0x30fb5a82;
    M[RA1++] = RD0;
    RD0 = 0xcf050000;
    M[RA1++] = RD0;
    RD0 = 0x89bfa57e;
    M[RA1++] = RD0;
    RD0 = 0x89bf8001;
    M[RA1++] = RD0;
    RD0 = 0xcf05a57e;
    M[RA1++] = RD0;
    RD0 = 0x30fb0000;
    M[RA1++] = RD0;
    RD0 = 0x76415a82;
    M[RA1++] = RD0;
    RD0 = 0x76417ffe;//
    M[RA1++] = RD0;
    RD0 = 0x30fb5a82;
    M[RA1++] = RD0;
    RD0 = 0xcf050000;
    M[RA1++] = RD0;
    RD0 = 0x89bfa57e;
    M[RA1++] = RD0;
    RD0 = 0x89bf8001;
    M[RA1++] = RD0;
    RD0 = 0xcf05a57e;
    M[RA1++] = RD0;
    CPU_WorkDisable;   
*/
//此处可修改算法，音频流在RN_GRAM_IN


//音量调整 测试用
//GPIO7按下减小音量，GPIO3按下增大音量
//每次调整时，打印当前帧g_DAC_Cfg，打印下一帧音量
	RD0 = GPIO_Data0;
	if(RD0_Bit7 == 0) goto L_TEST_1;
	goto  L_TEST_END;   
L_TEST_1:
    nop;nop;
	RD0 = GPIO_Data0;
	if(RD0_Bit7 == 0) goto L_TEST_1;

RD1 = g_DAC_Cfg;
send_para(RD1);
call UART_PutDword_COM1;
    RD0 = g_Vol;
    RD0 -= 1;
    g_Vol = RD0;
send_para(RD0);
call UART_PutDword_COM1;
L_TEST_END:
	RD0 = GPIO_Data0;
	if(RD0_Bit3 == 0) goto L_TEST_2;
	goto  L_TEST_END1;   
L_TEST_2:
    nop;nop;
	RD0 = GPIO_Data0;
	if(RD0_Bit3 == 0) goto L_TEST_2;
RD1 = g_DAC_Cfg;
send_para(RD1);
call UART_PutDword_COM1;
    RD0 = g_Vol;
    RD0 += 1;
    g_Vol = RD0;
send_para(RD0);
call UART_PutDword_COM1;

L_TEST_END1:
/////////音量调整结束
    
    call Send_DAC;        
    goto Loop;


    




////////////////////////////
//		L_Data_Err
////////////////////////////
L_Data_Err:
	    CPU_SimpleLevel_L;
	    CPU_SimpleLevel_H;    
	    CPU_SimpleLevel_L;
	    nop;
	    CPU_SimpleLevel_H;  
	    CPU_SimpleLevel_L;
	    nop;nop;
	    CPU_SimpleLevel_H;  
	    goto L_Data_Err;
	



////////////////////////////////////////////////////////
//  函数名称:
//      _Mem_Copy1F
//  函数功能:
//      拷贝1帧（64字节）数据
//  入口参数:
//      RD0:源地址
//      RA2:目标
//  出口参数:
//      无，破坏RA2
//2021/11/6 16:29:49 FOR SIMULATION
////////////////////////////////////////////////////////
Sub_AutoField _Mem_Copy1F;
	RA0 = RD0;
	RD2 = 16;
L_Mem_Copy1F_L0:
	RD0 = M[RA0++];
	RA0 += MMU_BASE;
	M[RA2++] = RD0;
	RD2 --;
	if(RQ_nZero) goto L_Mem_Copy1F_L0;
	Return_AutoField(0*MMU_BASE);

////////////////////////////////////////////////////////
//  函数名称:
//      UART1_Initial
//  函数功能:
//      初始化UART_COM1
//      GP05 : Tx    GP06 : Rx
//  入口参数:
//      无
//  出口参数:
//      无
////////////////////////////////////////////////////////
Sub_AutoField UART1_Initial;
	//GP0_5  UART_COM1_Tx
    RD0 = GP0_5;
    GPIO_WEn0 = RD0;
    RD0 = GPIO_OUT|GPIO_PULL;
    GPIO_Set0 = RD0;
    //GP0_6  UART_COM1_Rx
    RD0 = GP0_6;
    GPIO_WEn0 = RD0;
    RD0 = GPIO_IN|GPIO_PULL;
    GPIO_Set0 = RD0;

	RD0 = COM1;
	send_para(RD0);
	RD0 = 0x52faa192;  //主频32M,115200 bps
	send_para(RD0);
	RD0 = 2;
	send_para(RD0);
	RD0 = 0;
	send_para(RD0);
	call UART_Init;

	Return_AutoField(0*MMU_BASE);

//=========================================
//功能：PWM配置
//入口：1：端口数
//      2：脉宽宽度
//      3：周期
//出口： 无
//破坏：RD0
//=========================================
Sub_AutoField _PWM_Config;

    RD0 = M[RSP+2*MMU_BASE];
    USI_Num = RD0;

    USI_Disable;

    RD0 = M[RSP+0*MMU_BASE];
    send_para(RD0);
    call _Timer_Number;

    USI_Enable;
    USI_SelPort = Config_Port;
    RD1 = 0b110010000000010;
    USI_Data = RD1;

    USI_SelPort = Counter1_Port;    //写周期
    USI_Data = RD0;

    USI_SelPort = Counter0_Port;    //写脉宽
    RD0 = M[RSP+1*MMU_BASE];
    USI_Data = RD0;

    RD0 = 0;
    USI_SelPort = Counter2_Port|Data_Port;
    USI_Data = RD0; //初始化寄存器状态、启动周期计数器
    USI_StartCnt0;  //启动脉冲计数器

    Return_AutoField(3*MMU_BASE);

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
	
    RD0 = g_WeightFrame_Now_0;
    RF_ShiftL1(RD0);//E*2       
    RD1 = RD0;
    RD0 += RD1;
    RD0 += RD1;     //E*6
    RD0 += g_Vol;   //总增益=6*E+音量值
    call Find_k;   
    RD2 = RD1;  //右移位数 
    call DAC_Tab;
    //先进行乘法
    if(RD0_Zero) goto L_Send_DAC_xx;
    //非6的整数倍，插kx   
    RD1 = RD0;    
	RD0 = RN_GRAM_IN; 
    RA0 = RD0;
	RD0 = RN_GRAM1; ///////////////////////！！！！！！！！！暂定寄存器 ！！！！！！
    RA1 = RD0;
    RD0 = RD1;
    call _MAC_RffC;          

    RD0 = RN_GRAM_IN; 
    RD1 = RN_GRAM1;
    call DATA_kX;
    goto L_Send_DAC_Odd;
L_Send_DAC_xx:
    //6的整数倍，插原值
    RD0 = RN_GRAM_IN; 
    call DATA_XX;   

L_Send_DAC_Odd:        
	RD1 = FlowRAM_Addr1;	
    RD0 = g_Cnt_Frame;
    if(RD0_Bit0==1) goto L_Send_DAC_Even;
	RD1 = FlowRAM_Addr0;	
L_Send_DAC_Even:
    
    //移位
	RD0 = RN_GRAM_IN;
    RA0 = RD0;
    RA1 = RD1;
    RD0 = RD2;
    call _Send_DAC_SignSftR_RndOff;
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
    RD1 = 0x3ff0000;
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
    RD1 = 0x3f0000;
    RD0 += RD1;
    g_ADC_CFG_0 = RD0;  

L_ADC0_SmallSignal_4:
    //ADC_Cfg更新
    RD0 = g_ADC_CFG_0;
    RF_GetH16(RD0);
    RD1 = RD0;     
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
    RD1 = 0x70000; 
    goto L_ADC0_StrongSignal_3;
L_ADC0_StrongSignal_0:
    if(RD0_Bit31 == 1) goto L_ADC0_StrongSignal_2;
    //E=2,无法降低
    goto L_ADC0_StrongSignal_End;
L_ADC0_StrongSignal_2:    
    //E=-2,调整为0
    RD0 = 0;
    g_WeightFrame_Next_0 = RD0;
    RD1 = 0x3ff0000;
      
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
    RD1 = 0x60006000;   //修正值
    goto L_ExpFix_0;
L_ExpFix_1:
    //E=-2
    RD1 = 0x68B968B9;   //修正值
    goto L_ExpFix_0;
L_ExpFix_0:
    //RA0@ADBUFF
    //临时修改ParaMEM
    //配置DMA_Ctrl参数，包括地址.长度
	RD0 = RN_PRAM_START+DMA_ParaNum_MAC_RffC*MMU_BASE*8;
	RA2 = RD0;
	// 4*MMU_BASE: Step1  
	RD0 = 0x06040002;//Step1
	M[RA2+4*MMU_BASE] = RD0;
	// 5*MMU_BASE: Null
	RD0 = 0x00000002;//Step2
	M[RA2+5*MMU_BASE] = RD0;
    //////MAC_RFFC
    	// 设置Group与PATH的连接
		MemSetPath_Enable;  //设置Group通道使能
		M[RA0+MGRP_PATH2] = RD0;//选择PATH2，通道信息在偏址上

		MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
		// 连接到PATH1
		M[RA0] = DMA_PATH2;

		//配置MAC参数
		MAC_CFG = RN_CFG_MAC_TYPE2;     //MAC写指令端口 //X[n]*CONST/32768
		MAC_Const = RD1;    //MAC写Const端口//CONST为16位，高低16位写相同数据
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
		RD0 = RA0;//目标地址
		RF_ShiftR2(RD0);           //变为Dword地址
		RD0 -= 2;                  //流水线前1次写无效
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
		
			//归还bank
		MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
		M[RA0] = DMA_PATH5;
		MemSet_Disable;     //配置结束

    //归还ParaMem
    // 4*MMU_BASE: Step1  
	RD0 = 0x06040001;//Step1
	M[RA2+4*MMU_BASE] = RD0;
	// 5*MMU_BASE: Null
	RD0 = 0x00000001;//Step2
	M[RA2+5*MMU_BASE] = RD0;

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

//goto L_ADC_Bias_Adj_Start;//////////////!!!!!!!!!!!!测试用
           
    //////2、AGC增益调整
    // 2.1小信号处理
    call ADC0_SmallSignal;
    
    if(RD0_Zero) goto L_ADC_Bias_Adj_Start; //当前属于小信号帧，跳过大信号处理
    // 2.2大信号处理
    call ADC0_StrongSignal;

    //////3、去直流
L_ADC_Bias_Adj_Start:
    //更新DAC_CFG
    RD0 = g_DAC_Cfg; 
    CPU_WorkEnable;
    DAC_CFG = RD0;
    CPU_WorkDisable;
/*
//test    
RD0 = g_Cnt_Frame;  //帧计数器                              
if(RD0_L8 != 0) goto L_ADC_TEST_End; 
if(RD0_Bit8 == 1) goto L_ADC_TEST_End;  //判是否满512帧，不满跳过                 
if(RD0_Bit9 == 1) goto L_ADC_TEST;  //判是否满512帧，不满跳过                 
//ADC_Cfg更新
RD0 = 0x3;
RD1 = RD0;     
RD0 = RN_ADCPORT_AGC0;
////Try ADC
ADC_CPUCtrl_Enable;
//配置ADC0    
ADC_PortSel = RD0;
ADC_Cfg = RD1;
RD0 = 0;
ADC_PortSel = RD0;
ADC_CPUCtrl_Disable;        
goto L_ADC_TEST_End;        
L_ADC_TEST:
//ADC_Cfg更新
RD0 = 0xF;
RD1 = RD0;     
RD0 = RN_ADCPORT_AGC0;
//Try ADC
ADC_CPUCtrl_Enable;
//配置ADC0    
ADC_PortSel = RD0;
ADC_Cfg = RD1;
RD0 = 0;
ADC_PortSel = RD0;
ADC_CPUCtrl_Disable;    
L_ADC_TEST_End:    

RD0 = 2;
L_223:
nop;
RD0 --;
if(RQ_nZero) goto L_223; 
      
RD0 = g_Cnt_Frame;  //帧计数器
RD0 -= 2;                              
if(RD0_L8 != 0) goto L_ADC_TEST_End1; 
if(RD0_Bit8 == 1) goto L_ADC_TEST_End1;  //判是否满512帧，不满跳过                 
if(RD0_Bit9 == 1) goto L_ADC_TEST1;  
//更新DAC_CFG
RD0 = 0x8083C0; 
CPU_WorkEnable;
DAC_CFG = RD0;
CPU_WorkDisable;           
goto L_ADC_TEST_End1;        
L_ADC_TEST1:
//更新DAC_CFG
RD0 = 0x808380; 
CPU_WorkEnable;
DAC_CFG = RD0;
CPU_WorkDisable;      
L_ADC_TEST_End1:     
*/             
    RD0 = g_Cnt_Frame;  //帧计数器
    if(RD0_Zero) goto L_ADC_Bias_Adj_End;                      
    if(RD0_L8 != 0) goto L_ADC_Bias_Adj_End; 
    if(RD0_Bit8 == 1) goto L_ADC_Bias_Adj_End;  //判是否满512帧，不满跳过                 
    call ADC0_Step;
    RD2 = RD0;          //当前512帧平均值
RD0 = g_Cnt_Frame;
send_para(RD0);
call UART_PutDword_COM1;
RD0 = g_Vpp_0;
send_para(RD0);
call UART_PutDword_COM1;
RD0 = g_WeightFrame_Now_0;
send_para(RD0);
call UART_PutDword_COM1;
RD0 = g_DAC_Cfg;
send_para(RD0);
call UART_PutDword_COM1;                             
RD0 = g_ADC_CFG_0;
send_para(RD0);
call UART_PutDword_COM1;   
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
//      SPI_Export_IO_Init;
//  功能:
//      SPI输出数据IO初始化
//  参数:
//      无
//  返回值：
//      无
//  注释：
//      Speed3下运行
//////////////////////////////////////////////////////////////////////////
Sub SPI_Export_IO_Init;
    // GP0_5 SPI_MOSI
    // GP0_7 SPI_CLK
    RD0 = GP0_4;
    GPIO_WEn0 = RD0;
    RD0 = GPIO_IN;
    GPIO_Set0 = RD0;
    RD0 = GP0_5|GP0_7;
    GPIO_WEn0 = RD0;
    RD0 = GPIO_OUT;
    GPIO_Set0 = RD0;
    RD0 = COM1;
    RD1 = RN_SPI_CLK_CFG;
    call SPI_Master_Init;
    return(0);    
    

END SEGMENT


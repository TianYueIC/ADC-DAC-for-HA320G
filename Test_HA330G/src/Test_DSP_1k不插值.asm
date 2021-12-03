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
		
		
			//开始测试！等待按键GP0-3
L_Wait_Key0:
	
	CPU_SimpleLevel_L;
	nop; nop; nop; nop;
	RD0 = GPIO_Data0;
#ifdef OnBoardChip_test
	//if(RD0_Bit3 == 1) goto L_Wait_Key0;
#endif
   
//    RD0 = RN_ADCPORT_AGC0;
//    RD1 = 0xFF;
//    ////Try ADC
//    ADC_CPUCtrl_Enable;
//    //配置ADC0    
//    ADC_PortSel = RD0;
//    //RD0 = 0x7F;
//    ADC_Cfg = RD1;
//    RD0 = 0;
//    ADC_PortSel = RD0;
//    ADC_CPUCtrl_Disable;  
    
    CPU_SimpleLevel_H;
    
    //goto L_Wait_Key0;


    RD0 = 0;
    g_Vol = RD0;    //音量调整值
Loop:   //main
    
    call Get_ADC;
    nop;nop;nop;nop;
    if(RD0_nZero) goto Loop;

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


//此处可修改算法，音频流在RN_GRAM_IN
//RD1 = 0xffff8888;
//send_para(RD1);
//call UART_PutDword_COM1;
//RD1 = 0xffff8888;
//send_para(RD1);
//call UART_PutDword_COM1;
//RD1 = 0xffff8888;
//send_para(RD1);
//call UART_PutDword_COM1;




//	RD0 = RN_GRAM3;
//    RA0 = RD0;
//	RD0 = RN_GRAM0;
//    RA1 = RD0;
//    RD0 = 0;
//    call _GetADC_Ave_Max_Min;



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

//    RD0 = RN_GRAM0;
//    RA0 = RD0;
//    RD0 = RN_GRAM0;
//    RA1 = RD0;
//    RD0 = FL_M88_A1;
//    call _IIR_PATH3_HP;

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
    if(RFlag_Flow2Bank0==1) goto L_halfSin;
RD0 = 0x7d877d87; M[RA1++] = RD0;
RD0 = 0x763f763f; M[RA1++] = RD0;
RD0 = 0x6a6b6a6b; M[RA1++] = RD0;
RD0 = 0x5a805a80; M[RA1++] = RD0;
RD0 = 0x471b471b; M[RA1++] = RD0;
RD0 = 0x30fb30fb; M[RA1++] = RD0;
RD0 = 0x18f818f8; M[RA1++] = RD0;
RD0 = 0x00000000; M[RA1++] = RD0;
RD0 = 0xe708e708; M[RA1++] = RD0;
RD0 = 0xcf05cf05; M[RA1++] = RD0;
RD0 = 0xb8e5b8e5; M[RA1++] = RD0;
RD0 = 0xa580a580; M[RA1++] = RD0;
RD0 = 0x95959595; M[RA1++] = RD0;
RD0 = 0x89c189c1; M[RA1++] = RD0;
RD0 = 0x82798279; M[RA1++] = RD0;
RD0 = 0x80038003; M[RA1++] = RD0;

goto L_DATA_pre_finish;
L_halfSin:
RD0 = 0x82798279; M[RA1++] = RD0;
RD0 = 0x89c189c1; M[RA1++] = RD0;
RD0 = 0x95959595; M[RA1++] = RD0;
RD0 = 0xa580a580; M[RA1++] = RD0;
RD0 = 0xb8e5b8e5; M[RA1++] = RD0;
RD0 = 0xcf05cf05; M[RA1++] = RD0;
RD0 = 0xe708e708; M[RA1++] = RD0;
RD0 = 0x00000000; M[RA1++] = RD0;
RD0 = 0x18f818f8; M[RA1++] = RD0;
RD0 = 0x30fb30fb; M[RA1++] = RD0;
RD0 = 0x471b471b; M[RA1++] = RD0;
RD0 = 0x5a805a80; M[RA1++] = RD0;
RD0 = 0x6a6b6a6b; M[RA1++] = RD0;
RD0 = 0x763f763f; M[RA1++] = RD0;
RD0 = 0x7d877d87; M[RA1++] = RD0;
RD0 = 0x7ffd7ffd; M[RA1++] = RD0;

L_DATA_pre_finish:
    CPU_WorkDisable;  

//    RD0 = RN_GRAM_IN; 
//    call DATA_XX;   //插原值    
//    
//    RD0 = RN_GRAM_IN;
//    RA0 = RD0;
//    RD0 = FlowRAM_Addr0;
//    RA1 = RD0;   
//    if(RFlag_Flow2Bank0==0) goto L_Send;
//    CPU_SimpleLevel_L;    
//    RD0 = FlowRAM_Addr1;
//    RA1 = RD0;   
//L_Send:    
//    RD0 = 0;
//    call _Send_DAC_SignSftR_RndOff;
//    
//    //帧计数器累加
//    g_Cnt_Frame ++;  
*/    
    
    
    
    
    call Send_DAC;
    
//RD1 = RN_SP3;
//RP_B15;
//Set_Pulse_Ext8;
//nop;nop;    
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
////查到数据，切回S5
//RD2 = RD1;
//RD1 = RN_SP5;
//RP_B15;
//Set_Pulse_Ext8;
//nop;nop;
//RD1 = RD2

    RA0 = RD1;
//
    //更新DAC_CFG
    RD0 = g_DAC_Cfg; 
    CPU_WorkEnable;
    DAC_CFG = RD0;
    CPU_WorkDisable;
        
    call Get_ADC_Function;

	RD0 = 0;
    Return_AutoField(0*MMU_BASE);

//////////////////////////////////////////////////////////////////////////
//  名称:
//      Find_n_k
//  功能:
//      通过总增益计算n、k。总音量=6*n+k，0<=k<6
//  参数:
//      RD0:总音量，32bit有符号数
//  返回值：
//		RD0:k
//      RD1:-n
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Find_n_k;
    if(RD0_Bit31 ==1) goto L_Find_n_k_0;
    if(RD0_nZero) goto L_Find_n_k_1;
    //0dB
    RD0 = 0;
    RD1 = 0;
    goto L_Find_n_k_End;    
L_Find_n_k_1:        
    // 总增益0-12dB    
    RD0 -= 6;
    if(RD0_nZero) goto L_Find_n_k_2;
    // 6dB
    RD0 = 0;
    RD1 = -1;
    goto L_Find_n_k_End;        
L_Find_n_k_2:
    if(RD0_Bit31 == 0) goto L_Find_n_k_3;
    // 1-5dB
    RF_Neg(RD0);    //-(n-6)
    RD1 = -1;   //n
    goto L_Find_n_k_End;
L_Find_n_k_3:
    // >=7dB
    RD0 = 0;
    RD1 = -2;    
    goto L_Find_n_k_End;
  
//2021/11/28 15:18:59 废弃，大音量时不做微调    
//    RD0 -= 6;
//    if(RQ_nBorrow) goto L_Find_n_k_4;
//    // 7-11dB
//    RF_Neg(RD0);    //-(n-12)
//    RD1 = -2;   //n
//    goto L_Find_n_k_End;
//L_Find_n_k_4:
//    // >=12dB  
//    RD0 = 0;
//    RD1 = -2;
//    goto L_Find_n_k_End;    
    
L_Find_n_k_0:  
    //总增益为负数
    RF_Neg(RD0);    // 总增益求负便于算法设计
    RD2 = RD0;
    RD0 -= 72;  /////////////////////////////暂定，小音量极限值
    if(RQ_Borrow) goto L_Find_n_k_6;
    //小音量截顶
    RD0 = 0;
    RD1 = 12;   /////////////////////////////小音量极限值/6，跟随小音量极限值一并调整  
    goto L_Find_n_k_End;    
    
L_Find_n_k_6:       //调整范围内
    RD0 = RD2;
    RD1 = -1;       //n
L_Find_n_k_5:
    RD1 ++;  
    RD0 -= 6;
    if(RD0_Bit31 == 0) goto L_Find_n_k_5;   
    RD0 += 6;       //余数k，总增益=6*n+k，k<6  
      
L_Find_n_k_End:
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
    RD0 = 0x47FA47FA;   
    goto L_DAC_Tab_End;
L_DAC_Tab_0:
    //余数k=0    
    RD0 = 0;   //          
    goto L_DAC_Tab_End;
L_DAC_Tab_1:
    //余数k=1,RD0=1/10^(1/20),q15
    RD0 = 0x72147214;    
    goto L_DAC_Tab_End;
L_DAC_Tab_2:
    //余数k=2,RD0=1/10^(2/20),q15    
    RD0 = 0x65AC65AC;    
    goto L_DAC_Tab_End;
L_DAC_Tab_3:
    //余数k=3   
    RD0 = 0x5A9D5A9D; 
    goto L_DAC_Tab_End;
L_DAC_Tab_4:
    //余数k=4    
    RD0 = 0x50C350C3;   
       
L_DAC_Tab_End:
    Return_AutoField(0*MMU_BASE);


//////////////////////////////////////////////////////////////////////////
//  名称:
//      DAC_UpdateCfg
//  功能:
//      通过移位数n，确定DAC_Cfg中IIR与CIC参数，以及CPU移位数
//  参数:
//      RD0:-n
//  返回值：
//      RD1: CPU移位数
//      RD0: DAC_Cfg中IIR与CIC参数
//////////////////////////////////////////////////////////////////////////
Sub_AutoField DAC_UpdateCfg;
    
    RD2 = RD0;
    RD0 -= 5;
    if(RD0_Bit31 == 1) goto L_DAC_UpdateCfg_0;   
    //n>=5，右移n-5位，IIR档位-3，Mult档位-2
    RD1 = RD0;  //暂存移位值
    RD0 = 0x1000;
    goto L_DAC_UpdateCfg_End;

L_DAC_UpdateCfg_0:
    RD0 = RD2;
    RD0 -= 4;
    if(RD0_nZero) goto L_DAC_UpdateCfg_1;   
    //n=4，右移0位，IIR档位-3，Mult档位-1
    RD0 = 0x1040;
    RD1 = 0;    //右移0位
    goto L_DAC_UpdateCfg_End;
    
L_DAC_UpdateCfg_1:
    RD0 = RD2;
    RD0 -= 3;
    if(RD0_nZero) goto L_DAC_UpdateCfg_2;   
    //n=3，右移0位，IIR档位-3，Mult档位0
    RD0 = 0x1080;
    RD1 = 0;    //右移0位
    goto L_DAC_UpdateCfg_End;
        
L_DAC_UpdateCfg_2:
    RD0 = RD2;
    RD0 -= 2;
    if(RD0_nZero) goto L_DAC_UpdateCfg_3;   
    //n=2，右移0位，IIR档位-2，Mult档位0
    RD0 = 0x2080;
    RD1 = 0;    //右移0位
    goto L_DAC_UpdateCfg_End;    
    
L_DAC_UpdateCfg_3:
    RD0 = RD2;
    RD0 -= 1;
    if(RD0_nZero) goto L_DAC_UpdateCfg_4;   
    //n=1，右移0位，IIR档位-1，Mult档位0
    RD0 = 0x4080;
    RD1 = 0;    //右移0位
    goto L_DAC_UpdateCfg_End;      
        
L_DAC_UpdateCfg_4:
    RD0 = RD2;
    if(RD0_nZero) goto L_DAC_UpdateCfg_5;   
    //n=0，右移0位，IIR档位0，Mult档位0
    RD0 = 0x8080;
    RD1 = 0;    //右移0位
    goto L_DAC_UpdateCfg_End;      

L_DAC_UpdateCfg_5:
    RD0 = RD2;
    RD0 ++;
    if(RD0_nZero) goto L_DAC_UpdateCfg_6;   
    //n=-1，右移0位，IIR档位0，Mult档位1
    RD0 = 0x80C0;
    RD1 = 0;    //右移0位
    goto L_DAC_UpdateCfg_End;      
    
L_DAC_UpdateCfg_6:
    //n=-2，右移0位，IIR档位1，Mult档位1
    RD0 = 0xF0C0;
    RD1 = 0;    //右移0位
    
L_DAC_UpdateCfg_End:    
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
//      g_DAC_Cfg: bit15-12:IIR输出增益；bit7 6：CIC输出增益。1000 10是默认值，此时0dB
//      g_Vol：音量档位（dB），暂定32bit定点数
//      g_Weight_Frame_0：高8位为当前帧权位(*2)，小数点在bit1上。例：0b1111表示-0.5
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Send_DAC;
	
    RD0 = g_Weight_Frame_0;   //高8位为当前帧权位(*2)
    RF_GetH8(RD0);
    RD0_SignExtL8;
    RD1 = RD0;
    RD0 += RD1;
    RD0 += RD1;     //RD0*3,相当于权位E*6
    RD0 += 6;       //2021/11/28 15:11:58修改，CIC初始档位0b10变为0b11
    RD0 += g_Vol;   //总增益=6*E+音量值
    
    call Find_n_k;
    RD2 = RD1;  //n

    call DAC_Tab;
    RD3 = RD0;  // 查表结果c在RD3上        
    RD0 = RD2;
    call DAC_UpdateCfg;

    RD2 = RD0;  // DAC_Cfg中IIR与CIC参数
	RD0 = g_DAC_Cfg;
    RD0_ClrBit6;
    RD0_ClrBit7;
    RD0_ClrBit12;
    RD0_ClrBit13;
    RD0_ClrBit14;
    RD0_ClrBit15;   //g_DAC_Cfg初始化，清零配置位
    RD0 += RD2;
    g_DAC_Cfg = RD0;

    //先进行乘法
    RD0 = RD3;  //c在RD3上
    RD3 = RD1;  //移位数据

    if(RD0_Zero) goto L_Send_DAC_Odd;   //6的整数倍，无需乘法
    RD1 = RD0;    
	RD0 = RN_GRAM_IN; 
    RA0 = RD0;
	RD0 = RN_GRAM_IN; 
    RA1 = RD0;
    RD0 = RD1;
    call _MAC_RffC;          

L_Send_DAC_Odd:
    
    RD0 = RN_GRAM_IN; 
    call DATA_XX;   //插原值    
        
	RD1 = FlowRAM_Addr1;	
    RD0 = g_Cnt_Frame;
    if(RD0_Bit0==1) goto L_Send_DAC_Even;
	RD1 = FlowRAM_Addr0;	
L_Send_DAC_Even:
    
    //移位
	RD0 = RN_GRAM_IN;
    RA0 = RD0;
    RA1 = RD1;
    RD0 = RD3;
    call _Send_DAC_SignSftR_RndOff;
    
    //更新g_Weight_Frame_0
    RD1 = g_Weight_Frame_0;   //高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器 
    RF_GetMH8(RD1);
    RF_RotateR8(RD1);
    RD0 = g_Weight_Frame_0;   //高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器 
    RD0_ClrByteH8;
    RD0 += RD1;
    g_Weight_Frame_0 = RD0;

    //帧计数器累加
    g_Cnt_Frame ++;    
     
    Return_AutoField(0*MMU_BASE);    
    
    
//////////////////////////////////////////////////////////////////////////
//  名称:
//      DATA_XX 
//  功能:
//      插原值
//  参数:
//      RD0 : 源地址
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
//      g_Weight_Frame_0：  高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
//      g_ADC_DC_0:         累加和计数器（权位0）
//////////////////////////////////////////////////////////////////////////
Sub_AutoField ADC0_Weight;

    // 根据帧权位左右移累加和，使权位置0
    RD1 = RD0;
    RD0 = g_Weight_Frame_0;     // 高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
    RF_GetH8(RD0);              // 当前帧权位
    if(RD0_Zero) goto L_ADC_Weight_End; 
    RD0_SignExtL8;   
    if(RD0_Bit3 == 0) goto L_ADC_Weight_0;
    // 权位为负数
    if(RD0_Bit0 == 0) goto L_ADC_Weight_1;
    RD0 --; //-2.5当做-3计算，-3.5当做-4计算
L_ADC_Weight_1:
    RF_Sft32SR1(RD1);
    RD0 ++;
    RD0 ++;
    if(RD0_nZero) goto L_ADC_Weight_1;
    goto L_ADC_Weight_End;
L_ADC_Weight_0:
    // 权位为2
    RF_ShiftL2(RD1);     
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
//      g_Weight_Frame_0：      高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
//		g_LastBank_Average_0    高8位为直流配置值；低16位为前512帧平均值，权位为0；bit16为当前块（512帧）是否改过档位的标志位。1：改过，0：未改过 
//////////////////////////////////////////////////////////////////////////
Sub_AutoField ADC0_C0;
    
    RD0 = g_LastBank_Average_0;
    RD0_SignExtL16;     //前512帧平均值（权位0）

    // 根据帧权位左右移平均值，使权位置0
    RD1 = RD0;
    RD0 = g_Weight_Frame_0;     // 高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
    RF_GetH8(RD0);              // 当前帧权位
    if(RD0_Zero) goto L_ADC0_C0_End; 
    RD0_SignExtL8;   
    if(RD0_Bit3 == 0) goto L_ADC0_C0_0;
    // 权位为负数
    if(RD0_Bit0 == 0) goto L_ADC0_C0_1;
    RD0 --; //-2.5当做-3计算，-3.5当做-4计算
L_ADC0_C0_1:
    RF_ShiftL1(RD1);     
    RD0 ++;
    RD0 ++;
    if(RD0_nZero) goto L_ADC0_C0_1;
    goto L_ADC0_C0_End;
L_ADC0_C0_0:
    // 权位为2
    RF_Sft32SR2(RD1);
L_ADC0_C0_End:             
    //RD1:前512帧平均值（权位同步）
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
//      RD0:Vpp
//  返回值：
//		RD0:    0:当前属于小信号帧；1:当前不属于小信号帧
//  全局变量：
//      g_Weight_Frame_0：      高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
//		g_ADC_CFG_0;            高16位ADC前置放大器配置值，低16位ADC_CFG端口配置值
//////////////////////////////////////////////////////////////////////////
Sub_AutoField ADC0_SmallSignal;

    RD0_ClrBit8;
    RD0_ClrBit9;
    RD0_ClrBit10;
    RD0_ClrByteL8;
    if(RD0_Zero) goto L_ADC0_SmallSignal_0;  //Vpp<2^11
    //未检测到小信号，清零计数器，跳走
    RD0 = g_Weight_Frame_0;         // 高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
    RD0_ClrByteL16;
    g_Weight_Frame_0 = RD0;         // 小信号帧计数器清零
    goto L_ADC0_SmallSignal_End;     

L_ADC0_SmallSignal_0:
    //检测到小信号
    RD0 = g_Weight_Frame_0;         // 高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
    RD0_ClrByteH16;
    RD1 = 512;  //小信号帧计数器
    RD0 -= RD1;
    if(RD0_Zero) goto L_ADC0_SmallSignal_1; 
    //不满足连续x帧小信号，计数器++，跳走
    g_Weight_Frame_0 ++;
    goto L_ADC0_SmallSignal_6;  // 当前帧属于小信号帧，跳过大信号处理
        
L_ADC0_SmallSignal_1:           // 小信号计数器达标，进行增益放大处理
    RD0 = g_Weight_Frame_0;     // 高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
    RD0_ClrByteL16;             // 计数器清零
    g_Weight_Frame_0 = RD0;
    
    RD0 = g_ADC_CFG_0;      // 高16位ADC前置放大器配置值，低16位ADC_CFG端口配置值
    RF_GetH16(RD0);         // 高16位ADC前置放大器配置值
    if(RD0_Bit10 == 1) goto L_ADC0_SmallSignal_6; // 27dB档位，已到顶，不调整   
    if(RD0_Bit9 == 0) goto L_ADC0_SmallSignal_2;
    // 24dB档位，调至27dB，E-0.5
    RD0_SetBit10;
    RD1 = RD0;                  // 暂存ADC前置放大器配置值
    RD0 = g_Weight_Frame_0;     // 高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
    RF_GetH8(RD0);              // 当前帧权位（*2）
    RD0 --;
    RD0_ClrByteH24;            
    RF_RotateL16(RD0);
    RD2 = RD0;    
    RD0 = g_Weight_Frame_0;     // 高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
    RD0_ClrByteMH8;    
    RD0 += RD2;
    g_Weight_Frame_0 = RD0;
    goto L_ADC0_SmallSignal_5;    
L_ADC0_SmallSignal_2:
    if(RD0_Bit1 == 1) goto L_ADC0_SmallSignal_3;
    //当前为-6dB,调至6dB,权位置0，E-2
    RD0_SetBit1;
    RD0_SetBit2;
    RD0_SetBit3;
    RD1 = RD0;                  // 暂存ADC前置放大器配置值
    RD0 = g_Weight_Frame_0;     // 高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
    RD0_ClrByteMH8;    
    g_Weight_Frame_0 = RD0;     // 下一帧权位为0        
    goto L_ADC0_SmallSignal_5;    
L_ADC0_SmallSignal_3:
    RD0 = g_Weight_Frame_0;     // 高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
    RF_GetH8(RD0);              // 当前帧权位（*2）
    RD0 -= 4;
    if(RD0_nZero) goto L_ADC0_SmallSignal_4;
    //当前帧权位为2，权位置0,E-2    
    RD0 = g_ADC_CFG_0;      // 高16位ADC前置放大器配置值，低16位ADC_CFG端口配置值
    RF_GetH16(RD0);         // 高16位ADC前置放大器配置值
    RF_ShiftL2(RD0);
    RF_ShiftL2(RD0);
    RD0 += 15;  
    RD1 = RD0;                  // 暂存ADC前置放大器配置值
    RD0 = g_Weight_Frame_0;     // 高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
    RD0_ClrByteMH8;    
    g_Weight_Frame_0 = RD0;     // 下一帧权位为0        
    goto L_ADC0_SmallSignal_5;    
L_ADC0_SmallSignal_4:    
    //正常调整，增加6dB,E-1
    RD0 = g_ADC_CFG_0;      // 高16位ADC前置放大器配置值，低16位ADC_CFG端口配置值
    RF_GetH16(RD0);         // 高16位ADC前置放大器配置值
    RF_ShiftL2(RD0);
    RD0 += 3;  
    RD1 = RD0;                  // 暂存ADC前置放大器配置值
    RD0 = g_Weight_Frame_0;     // 高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
    RF_GetH8(RD0);              // 当前帧权位（*2）
    RD0 --;
    RD0 --;
    RD0_ClrByteH24;            
    RF_RotateL16(RD0);
    RD2 = RD0;    
    RD0 = g_Weight_Frame_0;     // 高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
    RD0_ClrByteMH8;    
    RD0 += RD2;
    g_Weight_Frame_0 = RD0;

L_ADC0_SmallSignal_5:
    RD0 = g_LastBank_Average_0;   //bit16为当前块（512帧）是否改过档位的标志位
    RD0_SetBit16;        
    g_LastBank_Average_0 = RD0;
    RD0 = g_ADC_CFG_0;        // 高16位ADC前置放大器配置值，低16位ADC_CFG端口配置值 
    RD0_ClrByteH16;       
    RF_RotateL16(RD1);
    RD0 += RD1;    
    g_ADC_CFG_0 = RD0;

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

    //更新DAC_CFG
    RD0 = g_DAC_Cfg; 
    CPU_WorkEnable;
    DAC_CFG = RD0;
    CPU_WorkDisable;
L_ADC0_SmallSignal_6:    
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
//      RD0:Vpp
//  返回值：
//		无
//  全局变量：
//      g_Weight_Frame_0：      高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
//		g_ADC_CFG_0;            高16位ADC前置放大器配置值，低16位ADC_CFG端口配置值
//////////////////////////////////////////////////////////////////////////
Sub_AutoField ADC0_StrongSignal;

    if(RD0_Bit15 == 0) goto L_ADC0_StrongSignal_End; 
    if(RD0_Bit14 == 0) goto L_ADC0_StrongSignal_End; 
    //bit14 15都为1，减少增益
    
    RD0 = g_Weight_Frame_0;     // 高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
    RF_GetH8(RD0);             
    RD0 -= 4;
    if(RD0_Zero) goto L_ADC0_StrongSignal_End;  //当前权位为2，无法缩小，结束
    RD0 = g_Weight_Frame_0;     // 高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器        
    if(RD0_Bit24 == 0) goto L_ADC0_StrongSignal_0;
    //当前帧为.5权位，调至24dB,E+0.5
    RD0 = g_ADC_CFG_0;          // 高16位ADC前置放大器配置值，低16位ADC_CFG端口配置值
    RF_GetH16(RD0);             // 高16位ADC前置放大器配置值
    RD0_ClrBit10;
    RD1 = RD0;                  // 暂存ADC前置放大器配置值
    RD0 = g_Weight_Frame_0;     // 高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
    RF_GetH8(RD0);              // 当前帧权位（*2）
    RD0 ++;
    RF_RotateL16(RD0);
    RD2 = RD0;    
    RD0 = g_Weight_Frame_0;     // 高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
    RD0_ClrByteMH8;    
    RD0 += RD2;
    g_Weight_Frame_0 = RD0;
    goto L_ADC0_StrongSignal_3;       
L_ADC0_StrongSignal_0:
    //非.5权位
    RD0 = g_ADC_CFG_0;          // 高16位ADC前置放大器配置值，低16位ADC_CFG端口配置值
    RF_GetH16(RD0);             // 高16位ADC前置放大器放大倍数
    if(RD0_Bit4 == 1) goto L_ADC0_StrongSignal_1;
    //当前6dB,增益变为-6dB,E=2
//2021/12/2 9:29:29 存疑，当前6dB权位2的可能没考虑
    RD0_ClrBit1;    
    RD0_ClrBit2;    
    RD0_ClrBit3;    
    RD1 = RD0;                  // 暂存ADC前置放大器配置值
    RD0 = g_Weight_Frame_0;     // 高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
    RD0_ClrByteMH8;
    RD0_SetBit18;        
    g_Weight_Frame_0 = RD0;     // 下一帧权位为2        
    goto L_ADC0_StrongSignal_3;          
L_ADC0_StrongSignal_1:    
    RD0 = g_Weight_Frame_0;     // 高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
    RF_GetH8(RD0);              // 当前帧权位（*2）
    if(RD0_nZero) goto L_ADC0_StrongSignal_2;

//2021/12/2 11:35:51跳过E=2
goto L_ADC0_StrongSignal_End;

    //当前帧权位为0，增益-12dB,E=2
    RD0 = g_ADC_CFG_0;          // 高16位ADC前置放大器配置值，低16位ADC_CFG端口配置值
    RF_GetH16(RD0);             // 高16位ADC前置放大器配置值
    RF_ShiftR2(RD0);
    RF_ShiftR2(RD0);            // 根据配置表右移四位
    RD1 = RD0;                  // 暂存ADC前置放大器配置值
    RD0 = g_Weight_Frame_0;     // 高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
    RD0_ClrByteMH8;
    RD0_SetBit18;        
    g_Weight_Frame_0 = RD0;     // 下一帧权位为2        
    goto L_ADC0_StrongSignal_3;
L_ADC0_StrongSignal_2:
    //其他情况，增益-6dB,E+1
    RD0 = g_ADC_CFG_0;          // 高16位ADC前置放大器配置值，低16位ADC_CFG端口配置值
    RF_GetH16(RD0);         // 高16位ADC前置放大器配置值
    RF_ShiftR2(RD0);        // 根据配置表右移2位
    RD1 = RD0;              // 暂存ADC前置放大器配置值
    RD0 = g_Weight_Frame_0; // 高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
    RF_GetH8(RD0);          // 当前帧权位（*2）
    RD0 ++;
    RD0 ++;
    RF_RotateL16(RD0);
    RD2 = RD0;    
    RD0 = g_Weight_Frame_0;   // 高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
    RD0_ClrByteMH8;    
    RD0 += RD2;
    g_Weight_Frame_0 = RD0;
    
L_ADC0_StrongSignal_3:
    //根据档位配置当前帧权位、ADC前置放大器配置值
    RD0 = g_LastBank_Average_0;   //bit16为当前块（512帧）是否改过档位的标志位
    RD0_SetBit16;        
    g_LastBank_Average_0 = RD0;
    RD0 = g_ADC_CFG_0;        // 高16位ADC前置放大器配置值，低16位ADC_CFG端口配置值 
    RD0_ClrByteH16;       
    RF_RotateL16(RD1);
    RD0 += RD1;    
    g_ADC_CFG_0 = RD0;

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



    //更新DAC_CFG
    RD0 = g_DAC_Cfg; 
    CPU_WorkEnable;
    DAC_CFG = RD0;
    CPU_WorkDisable;    
L_ADC0_StrongSignal_End: 
     Return_AutoField(0);
       
//////////////////////////////////////////////////////////////////////////
//  名称:
//      Get_ADC_Function 
//  功能:
//      对ADC获得的数据统计，以此为据去直流、调增益
//  参数:
//      无
//  返回值：
//		无
//  说明：
//      (a)帧计数器,                    g_Cnt_Frame
//		(b)每一路MIC需要4个全局变量
//			(1)帧权位                   g_Weight_Frame_0 : 高8位为当前帧权位（*2），中高8位为下一帧权位（*2），低16位为连续小信号帧计数器
//			(2)前一块（512帧）平均值    g_LastBank_Average_0 : 高8位为直流配置值；低16位为前512帧平均值，权位为0；bit16为当前块（512帧?┦欠窀墓滴坏谋曛疚弧?：改过，0：未改过 
//			(3)平均值累加器             g_ADC_DC_0 ：平均值累加器,权位为0
//			(4)配置值寄存器             g_ADC_CFG_0 ：高16位ADC前置放大器配置值，低16位ADC_CFG端口配置值
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Get_ADC_Function;

    //////1、数据统计    
	//ALU计算xi-g_LastBank_Average_0，g_LastBank_Average_0：前一块（512帧）数据的均值
	RD0 = RN_GRAM_IN;
	RA1 = RD0;
	call ADC0_C0;   //RD0:紧凑型格式，需要减去的直流值（外部进行权重对齐，并拼凑为H16、L16格式），即前512帧平均值（权位同步）
	call _GetADC_Ave_Max_Min;   //1.RD0：结果的累加和，即SUM(Xi-C),32bit有符号数 2.RD1：峰峰值，Vpp=Max-Min，32bit有符号数
    RD3 = RD1;  
    call ADC0_Weight;     //更新累加和     
goto L_ADC_Bias_Adj_Start;        
    //////2、AGC增益调整
    // 2.1小信号处理
    RD0 = RD3;  // Vpp
    call ADC0_SmallSignal;
    
    if(RD0_Zero) goto L_ADC_Bias_Adj_Start; //当前属于小信号帧，跳过大信号处理
    // 2.2大信号处理
    RD0 = RD3;  // Vpp
    call ADC0_StrongSignal;

    //////3、去直流
L_ADC_Bias_Adj_Start:
/*
//test    
RD0 = g_Cnt_Frame;  //帧计数器                              
if(RD0_L8 != 0) goto L_ADC_TEST_End; 
if(RD0_Bit8 == 1) goto L_ADC_TEST_End;  //判是否满512帧，不满跳过                 
if(RD0_Bit9 == 1) goto L_ADC_TEST;  //判是否满512帧，不满跳过                 
//ADC_Cfg更新
RD0 = 0x3;
RD1 = RD0;     
//RD0 = RN_ADCPORT_AGC0;
//////Try ADC
//ADC_CPUCtrl_Enable;
////配置ADC0    
//ADC_PortSel = RD0;
//ADC_Cfg = RD1;
//RD0 = 0;
//ADC_PortSel = RD0;
//ADC_CPUCtrl_Disable;        
goto L_ADC_TEST_End;        
L_ADC_TEST:
//ADC_Cfg更新
RD0 = 0xF;
RD1 = RD0;     
//RD0 = RN_ADCPORT_AGC0;
//////Try ADC
//ADC_CPUCtrl_Enable;
////配置ADC0    
//ADC_PortSel = RD0;
//ADC_Cfg = RD1;
//RD0 = 0;
//ADC_PortSel = RD0;
//ADC_CPUCtrl_Disable;    
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
RD0 = 0x8043C0; 
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
//RD0 = g_Cnt_Frame;
//send_para(RD0);
//call UART_PutDword_COM1;
//send_para(RD3);
//call UART_PutDword_COM1;
//RD0 = g_Weight_Frame_0;
//send_para(RD0);
//call UART_PutDword_COM1;
//RD0 = g_LastBank_Average_0;
//send_para(RD0);
//call UART_PutDword_COM1;               

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


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
#include <IIR.def>
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
#define	        SPI_Master_Init                             0x00003fb6


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
    RD0 = GP0_4;
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


				
	RD0 = 0b11;//使能MIC0
	call AD_DA_INIT_330G;
	
//	L_TEST_FREQ:			
//		CPU_SimpleLevel_H;
//		nop;
//		CPU_SimpleLevel_L;
//		goto L_TEST_FREQ;			
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
CPU_SimpleLevel_H;nop;

    
    call Get_ADC;
    nop;nop;nop;nop;
    if(RD0_nZero) goto Loop;
CPU_SimpleLevel_L;
        
        
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
//	RD0 = GPIO_Data0;
//	if(RD0_Bit3 == 0) goto L_TEST_1;
//	goto  L_TEST_END1;   
//L_TEST_1:
//    nop;nop;
//	RD0 = GPIO_Data0;
//	if(RD0_Bit3 == 0) goto L_TEST_1;
//    RD0 = g_Vol;
//    RD0 += 1;
//    g_Vol = RD0;
//    RD2 = 2000*100;     
//    call _Delay_RD2;
//L_TEST_END1:
//    
//	RD0 = GPIO_Data0;
//	if(RD0_Bit7 == 0) goto L_TEST_2;
//	goto  L_TEST_END2;   
//L_TEST_2:
//    nop;nop;
//	RD0 = GPIO_Data0;
//	if(RD0_Bit7 == 0) goto L_TEST_2;
//    RD0 = g_Vol;
//    RD0 -= 1;
//    g_Vol = RD0;
//    RD2 = 2000*100;     
//    call _Delay_RD2;
//L_TEST_END2:
//    
//	RD0 = GPIO_Data0;
//	if(RD0_Bit4 == 0) goto L_TEST_3;
//	goto  L_TEST_END3;   
//L_TEST_3:
//    nop;nop;
//	RD0 = GPIO_Data0;
//	if(RD0_Bit4 == 0) goto L_TEST_3;
//    RD0 = g_Vol;
//    if(RD0_nZero) goto L_TEST_3_0;
//    RD0 = -100;
//    goto L_TEST_3_1;
//L_TEST_3_0:        
//    RD0 = 0;
//L_TEST_3_1:
//    g_Vol = RD0;
//    RD2 = 2000*100;     
//    call _Delay_RD2;
//L_TEST_END3:  
/////////音量调整结束


//增加过采样处理
	//Step1: 1倍内插0，占用地址(RN_SAMPLES_STREAM_OUT+512)作为缓冲区，共128字节
    RD0 = RN_SAMPLES_STREAM_0;
    RA0 = RD0;
    RD0 = RN_SAMPLES_STREAM_OUT;
    RA1 = RD0;
    RD0 = FL_M2_A2;
    call Real_To_Complex2;
	//Step2: 半带滤波，消除镜像频谱
	RD0 = RN_SAMPLES_STREAM_OUT;
    RA1 = RD0;
    RA0 = RD0;
    RD0 = FL2_M88_A1;// DWord长度*88+1
    call _IIR_PATH3_HB;



//音量调整 测试用
//GPIO7按下减小音量，GPIO3按下增大音量
	RD0 = GPIO_Data0;
	if(RD0_Bit7 == 0) goto L_TEST_1;
	goto  L_TEST_END1;   
L_TEST_1:
    nop;nop;
	RD0 = GPIO_Data0;
	if(RD0_Bit7 == 0) goto L_TEST_1;
    RD0 = g_Vol;
    RD1 = 6*256;
    RD0 += RD1;
    g_Vol = RD0;
    RD2 = 2000*100;     
    call _Delay_RD2;
L_TEST_END1:
    
	RD0 = GPIO_Data0;
	if(RD0_Bit4 == 0) goto L_TEST_2;
	goto  L_TEST_END2;   
L_TEST_2:
    nop;nop;
	RD0 = GPIO_Data0;
	if(RD0_Bit4 == 0) goto L_TEST_2;
    RD0 = g_Vol;
    RD1 = 6*256;
    RD0 -= RD1;
    g_Vol = RD0;
    RD2 = 2000*100;     
    call _Delay_RD2;
L_TEST_END2:    
   
    // 调节音量
    RD0 = g_Vol;
    send_para(RD0);
    RD0 = RN_SAMPLES_STREAM_0;
    send_para(RD0);
    RD0 = FL2_M3_A3;
    send_para(RD0);
    call Adj_Vol;
    

    call Send_Data_To_DAC_16bit_FSX2;

    g_Cnt_Frame ++;
    
    
//    RD0 = RN_GRAM_IN;
//    call Send_DAC;        
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
//  名称:
//      Adj_Vol
//  功能:
//      调节音量, 输入增益值范围为（-90dB~+90dB）
//  参数:
//      1.M[RSP+2*MMU_BASE]: 增益值（对数域q8）
//      2.M[RSP+1*MMU_BASE]: 数据地址
//      3.M[RSP+0*MMU_BASE]: 数据长度对应的TimerNum值，对应(Len*3)+3 FL_M3_A3
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_Autofield Adj_Vol;
// 先将dB增益转换至LOG2增益
// 后判断增益的整数部分即阶码确定所使用的MAC乘法器

    RD2 = M[RSP+0*MMU_BASE];   // 长度
    RD3 = M[RSP+1*MMU_BASE];   // 地址
#define    LEN_REG               RD2
#define    ADDR_REG              RD3

    // 转换至LOG2进行后续计算
    RD0 = RN_Pow2_Table_ADDR;  // 2^n ROM表地址, 查表具体方式可参考ROM中power_fix函数
    RA0 = RD0;

    RD0 = M[RSP+2*MMU_BASE];   // 增益
    RD1 = 10885;               // 0.33219 Q16
    call _Rs_Multi;
    RF_Sft32SR8(RD0);
    RF_Sft32SR8(RD0);
    // 最后一位舍入操作
    if(RD0_Bit31 == 1) goto L_Adj_Vol_0;
    // 负数无需舍入
    RD0 ++;
L_Adj_Vol_0:

    push RD0;                                     // 四舍五入后的增益
    // 获取增益小数部分进行查表操作
    RF_GetL8(RD0);                                // 取得增益小数部分
    RD1 = RD0;
    RF_ShiftR2(RD1);                              // ROM以DWORD单位寻址
    RD1 = M[RA0 + RD1];
    if (RD0_Bit1 == 0) goto L_Adj_Vol_1;          // 判断取表高位或低位
    RF_RotateL16(RD1);
L_Adj_Vol_1:
    RF_GetL16(RD1);

    // 判断增益整数部分, 选择所需使用的MAC配置
    pop RD0;
    RF_Sft32SR8(RD0);                             // 取得增益整数部分
    if(RD0_Bit31 == 0) goto L_Adj_Vol_2;          // 正负增益判断
    // 负增益使用Q15MAC
    RD0 += 24;                                    // 预留24Bit进行增益值量化
    RF_Exp(RD0);
    call _Rs_Multi;
    RF_Sft32SR8(RD0);                             // 量化增益值
    RF_Sft32SR8(RD0);                             // 量化增益值
    RD1 = RD0;
    RF_RotateL16(RD0);
    RD1 += RD0;

    RD0 = ADDR_REG;
    RA0 = RD0;
    RA1 = RD0;
    RD0 = LEN_REG;
    call MultiConstH16L16;             // Q15调节音量
    
    goto L_Adj_Vol_End;

L_Adj_Vol_2:                           // 正增益采用Q7MAC
    RD0 -= 7;
    if(RD0_Bit31 == 1) goto L_Adj_Vol_3;   // 若增益整数部分 > 7 需要额外进行一次放大
    push RD0;
    push RD1;
    send_para(ADDR_REG);
    RD0 = 0x40004000;                  // 放大128倍
    send_para(RD0);
    send_para(ADDR_REG);
    send_para(LEN_REG);
    call MAC_MultiConst16_Q2207;
    pop RD1;
    pop RD0;
    RD0 -= 7;

L_Adj_Vol_3:
    RD0 += 7;
    RF_Exp(RD0);
    call _Rs_Multi;                    // 计算剩余的增益值
    RD1 = RD0;
    RF_RotateL16(RD0);
    RD0 += RD1;

    send_para(ADDR_REG);
    send_para(RD0);
    send_para(ADDR_REG);
    send_para(LEN_REG);
    call MAC_MultiConst16_Q2207;
    
L_Adj_Vol_End:

#undef    LEN_REG
#undef    ADDR_REG
    Return_Autofield(3*MMU_BASE);
////////////////////////////////////////////////////////
//  名称:
//      Send_Data_To_DAC_16bit_FSX2
//  功能:
//      将音频样点拷贝到DAC缓冲器
//      由CPU执行拷贝过程，同时做削顶处理，限制数据在[-32768,32767]
//      数据入口：RN_SAMPLES_STREAM_OUT(全局)
//  参数:
//      无
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField Send_Data_To_DAC_16bit_FSX2;
    push RA2;
    RD0 = g_Cnt_Frame;
    if(RD0_Bit0==0) goto L_Send_Data_To_DAC_16bit_0;

    RD0 = FlowRAM_Addr1;
    call En_GRAM_To_CPU;
    RD0 = FlowRAM_Addr1;
    RA1 = RD0;
    goto L_Send_Data_To_DAC_16bit_1;

L_Send_Data_To_DAC_16bit_0:
    RD0 = FlowRAM_Addr0;
    call En_GRAM_To_CPU;
    RD0 = FlowRAM_Addr0;
    RA1 = RD0;
L_Send_Data_To_DAC_16bit_1:

    // 从GRAM拷贝至DAC_Buf1，并削顶
    RD0 = RN_SAMPLES_STREAM_OUT;
    call En_GRAM_To_CPU;

    RD2 = 32/2;
    RD0 = RN_SAMPLES_STREAM_OUT;
    RA0 = RD0;

L_Send_Data_To_DAC_16bit_Loop1:
Set_Opcode_Dis;nop;nop;
    RD0 = M[RA0++];
    M[RA1++] = RD0;
    RD0 = M[RA0++];
    M[RA1++] = RD0;
    RD2 --;
    if(RQ_nZero) goto L_Send_Data_To_DAC_16bit_Loop1;
    call Dis_GRAM_To_CPU;

    RD0 = g_Cnt_Frame;
    if(RD0_Bit0==0) goto L_Send_Data_To_DAC_16bit_2;
    // 6.将AD_Buf1切回Flow通道
    call SetADBuf1_Flow;
    goto L_Send_Data_To_DAC_16bit_End;

L_Send_Data_To_DAC_16bit_2:
    // 6.将AD_Buf0切回Flow通道
    call SetADBuf0_Flow;

L_Send_Data_To_DAC_16bit_End:

Set_Opcode_Dis;nop;nop;

    pop RA2;
    Return_AutoField(0);
    
    
Sub_AutoField Wait_Flag_DMAWork;
L_Wait_Flag_DMAWork0:
    nop;nop;
    if(Flag_DMAWork==0) goto L_Wait_Flag_DMAWork0;
Return_AutoField(0); 
////////////////////////////////////////////////////////
//  名称:
//      Real_To_Complex2
//  功能:
//      紧凑16bit格式转换为复数格式，虚部置零
//  参数:
//      1.RA0:输入序列指针，格式[Re(n+1) | Re(n)]
//      2.RA1:输出序列指针，格式[Re | 0](out)
//      3.RD0:TimerNum值 = (输入序列Dword长度*2)+2
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField Real_To_Complex2;
    RD2 = RD0;
    //以下为实数序列转换成复数操作示例程序
    //存储地址扩展为两倍，虚部置0
    ////偶数地址
    //--------------------------------------------------
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置参数
    RD0 = 0x2020;  //偶数序号0x2020  //奇数序号0x1010
    M[RA6+11*MMU_BASE] = RD0;     //ALU1写指令端口
    //配置相关的4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //配置结束
    //配置DMA_Ctrl参数，包括地址.长度
    RD0 = RA0;//源地址0
    send_para(RD0);
    RD0 = RA1;//目标地址
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_Real2Complex;
    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_Format;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
Set_Opcode_Dis;nop;nop;
    call Wait_Flag_DMAWork;
    //---------------------------------------------------
    //奇数地址
    //--------------------------------------------------
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置参数
    RD0 = 0x1010;  //偶数序号0x2020  //奇数序号0x1010
    M[RA6+11*MMU_BASE] = RD0;     //ALU1写指令端口
    //配置相关的4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;
    RD1 = 1024;
    M[RA1+RD1] = RD0;
    MemSet_Disable;     //配置结束
    //配置DMA_Ctrl参数，包括地址.长度
    RD0 = RA0;//源地址0
    send_para(RD0);
    RD0 = RA1;//目标地址
    RD0 += MMU_BASE;//奇数地址从1开始
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_Real2Complex;
    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_Format;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
Set_Opcode_Dis;nop;nop;
    call Wait_Flag_DMAWork;
    Return_AutoField(0);
    
    
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


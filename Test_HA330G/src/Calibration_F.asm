#define _CALCULATION_F_

#include <cpu11.def>
#include <resource_allocation.def>
#include <RN_DSP_Cfg.def>
#include <gpio.def>
#include <global.def>
#include <GD25.def>

#define RN_DELAY_VREF_STABLE    (10*2000)
#define RN_VREF_VAL_STD         249 //对应VCK0==972mV，VREF==1V
#define RN_IO_MAP_FREQ_CAL              GP0_7   // 校准频率输入
#define Flag_PORT_GP07                  RD0_Bit7
#define Flag_Cal_Pin_Out                Flag_PORT_GP01
#define Flag_Cal_Pin_In                 Flag_PORT_GP02
#define Flag_Freq_Cal                   Flag_PORT_GP07    

extern Delay_RD0;

CODE SEGMENT CALCULATION_F;
////////////////////////////////////////////////////////
//  名称:
//      VrefSetCfg_HA320G
//  功能:
//      根据校准记录设置基准电压
//      注释：本函数仅当一次性标记Bit0==0时执行（POR后一次性标志位Bit0==0,置位后为1,只能POR复位）
//  参数:
//      1.RD0: 校准控制码，b10~b0有效
//             b10~b8 电流偏置配置值，POR值为3'b000，此字段为系统设置值，校准时不更改
//             b7 :   保留
//             b6~b0  基准电压配置值，POR值为7'b1000011，校准时调整此字段
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField VrefSetCfg_HA320G;
    RA0 = RD0;
    RD0 = StandBy_RDCfg;
    if(RD0_Bit0==1) goto L_VrefSetCfg_OK;
    RD0 = 0x77F;
    RA0 &= RD0;         //清除无效位

    RD0 = 0;
    RD0_SetBit16;
    StandBy_WRSel = RD0;//打开配置端口
    RD0 = RA0;
    RF_Not(RD0);        //校准后的存储值为反码
    StandBy_WRCfg = RD0;

	//等待10ms时间
    RD2 = RN_DELAY_VREF_STABLE;
    call _Delay_RD2;
L_VrefSetCfg_OK:
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      POR_Set_Flag
//  功能:
//      置位POR的一次性标记Bit0为1（POR后一次性标志位Bit0==0,置位后为1,只能POR复位）
//  参数:
//      无
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField POR_Set_Flag;
    Push_Set_CPUSpeed(RN_SP3);
    RD0 = 0;
    RD0_SetBit17;
    StandBy_WRSel = RD0;
    RD0 = 1;
    StandBy_WRCfg = RD0;
    RD0 = 0;
    RD0_SetBit18;
    StandBy_WRSel = RD0;
    StandBy_WRCfg = RD0;
    Pop_CPUSpeed;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      VrefInit_BySAR_HA320G;
//  功能:
//      通过SAR_ADC校准Vref，并输出校准控制码
//      注释：执行本函数时需有972mV电压从V_CHK0引脚输入
//  参数:
//      无
//  返回值:
//      1.RD0 :  0~OK  1~校准范围过高  2~校准范围过低
//      2.RD1 :  校准控制码
////////////////////////////////////////////////////////
Sub_AutoField VrefInit_BySAR_HA320G;

    RD0 = StandBy_RDCfg;
    if(RD0_Bit0==1) goto L_VrefInit_BySAR_End2;

    //配置DSP工作时钟
    DSP_Disable;
    RD0 = RN_CFG_DSP48M+RN_CFG_FLOW_DIV8;  //Slow = 4MHz
    DSP_FreqDiv = RD0;
    //使能DSP工作
    DSP_Enable;
    Pull_Enable;
    // 初始化SAR,选择通道为VCHK0输入
    RD0 = 0;
    RD0_SetBit7;
    RD0_SetBit8;
    StandBy_WRSel = RD0;
    RD0 = 0;
    StandBy_WRCfg = RD0;
    SAR_Enable;
    RD0 = 0b0100;// 4KHz采样
    SAR_Cfg = RD0;
    RD2 = 10*2000;
    call _Delay_RD2;// 延时10ms等待信号稳定（切换通道后信号建立时间<1ms）

    // 设置Vref
    RD0 = RN_VREF_VAL_STD;
    RA0 = RD0;
    RD0 = 0;
    RD0_SetBit16;
    StandBy_WRSel = RD0;
    RD3 = 0b00111100;// 初值(0x3c)
    RD0 = RD3;
    RF_Not(RD0);
    StandBy_WRCfg = RD0;
    RD2 = RN_DELAY_VREF_STABLE;
    call _Delay_RD2;

    // 启动SAR_ADC并读值
    Start_SAR;
    Wait_While(RFlag_SAR==1);
    RD0 = SAR_Data;
	RD0_ClrByteL8;
    RD0 -= RA0;
    if(RD0_Zero) goto L_VrefInit_BySAR_OK;// 判断读值是否对应972mV（Val=50）
    if(RD0_Bit31==0) goto L_VrefInit_BySAR_H0;// 读值偏大，说明Vref偏低

    //Vref偏高，调整至相等或偏低
    RD1 = 0x3D;
L_VrefInit_BySAR_L0:
    RD3 --;
    RD0 = RD3;
    RF_Not(RD0);
    StandBy_WRCfg = RD0;

    RD2 = RN_DELAY_VREF_STABLE;
    call _Delay_RD2;

    Start_SAR;
    Wait_While(RFlag_SAR==1);
    RD0 = SAR_Data;
    RD0 -= RA0;
    if(RD0_Bit31==0) goto L_VrefInit_BySAR_OK;
    RD1 --;
    if(RQ_nZero) goto L_VrefInit_BySAR_L0;
    RD0 = 1;  //最低还偏高，报错
    goto L_VrefInit_BySAR_End;

    //Vref偏低，往大调整Vref，读值逐渐减小
L_VrefInit_BySAR_H0:
    RD1 = 0x42;
L_VrefInit_BySAR_H1:
    RD3 ++;
    RD0 = RD3;
    RF_Not(RD0);
    StandBy_WRCfg = RD0;

    RD2 = RN_DELAY_VREF_STABLE;
    call _Delay_RD2;

    Start_SAR;
    Wait_While(RFlag_SAR==1);
    RD0 = SAR_Data;
    RD0 -= RA0;
    if(RD0_Zero) goto L_VrefInit_BySAR_OK;
    if(RD0_Bit31==1) goto L_VrefInit_BySAR_OK;
    RD1 --;
    if(RQ_nZero) goto L_VrefInit_BySAR_H1;
    RD0 = 2;  //最高还偏低，报错
    goto L_VrefInit_BySAR_End;

L_VrefInit_BySAR_OK:
    RD0 = 0;
L_VrefInit_BySAR_End:
    RD1 = RD3;

    //禁能DSP工作
    DSP_Disable;
    Pull_Disable;
L_VrefInit_BySAR_End2:
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      ClkCal_HA320G
//  功能:
//      校准主频至32MHz，并输出校准控制码
//      注释：执行本函数时需有1KHz 50%占空比基准方波从DEBUG_EN引脚输入
//  参数:
//      无
//  返回值:
//      1.RD0 ：0 校准正常完成
//            : 1 未成功，内部频率偏快
//            : 2 未成功，内部频率偏慢
//      2.RD1 ：校准控制码,
//             b6~b0:7位值与频率为单调增函数，
//             POR值：7'b0111111
//             即7'b0000000为频率最低
//               7'b1111111为频率最低
//      设置主频时调用函数 ClkSetCfg_HA320G;
////////////////////////////////////////////////////////
Sub_AutoField ClkCal_HA320G;
    push RD4;
    Set_CPUSpeed(RN_SP3);   //2MIPS

    // 基准时钟输入端，初始化为高阻输入
    RD0 = RN_IO_MAP_FREQ_CAL;
    GPIO_WEn0 = RD0;
    RD0 = GPIO_IN;
    GPIO_Set0 = RD0;

    // 重置时钟配置值为复位值
    RD3 = 0b0111111;
    call ClkInit_WBL7;
    call ClkInit_FreqCheck_Confirm; //RD0 = 0:内部频率偏快
    if(RD0_Zero) goto L_OSC_Cal_Sub_Loop;// 当前偏快，需要向慢调节

    // 当前偏慢，需要向快调节
L_OSC_Cal_Add_Loop:
    RD3 ++;
    RD0 = RD3;
    if(RD0_Bit7 == 1) goto L_OSC_Cal_ErrL;// 调到最快仍然偏慢
    call ClkInit_WBL7;
    call ClkInit_FreqCheck_Confirm; //0~内部频率偏快 -1~内部频率偏慢
    if(RD0_Zero) goto L_OSC_Cal_OK;
    goto L_OSC_Cal_Add_Loop;

    //当前偏快，需要向慢调节
L_OSC_Cal_Sub_Loop:
    RD3 --;
    if(RQ_Borrow) goto L_OSC_Cal_ErrH;// 调到最慢仍然偏快
    call ClkInit_WBL7;
    call ClkInit_FreqCheck_Confirm; //0~内部频率偏快 -1~内部频率偏慢
    RD0 ++;
    if(RD0_Zero) goto L_OSC_Cal_OK;
    goto L_OSC_Cal_Sub_Loop;

L_OSC_Cal_ErrL:
    RD0 = 2;
    RD1 = 0b1111111;
    goto L_OSC_Cal_End;
L_OSC_Cal_ErrH:
    RD0 = 1;
    RD1 = 0b0000000;
    goto L_OSC_Cal_End;
L_OSC_Cal_OK:
    RD0 = 0;
    RD1 = RD3;
L_OSC_Cal_End:
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      ClkSetCfg_HA320G
//  功能:
//      根据校准记录设置主频
//  参数:
//      1.RD0：校准控制码
//             b7~b0:  低位控制码直接写入
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField ClkSetCfg_HA320G;
    RD3 = RD0;
    RD0 = StandBy_RDCfg;
    if(RD0_Bit0==1) goto L_ClkSetCfg_End;
    RF_GetL8(RD3);
    call ClkInit_WBL7;
    RD2 = 2000;
    call _Delay_RD2; //延迟1ms等待频率稳定
L_ClkSetCfg_End:
    Return_AutoField(0);


////////////////////////////////////////////////////////
//  名称:
//      ClkInit_WBL7
//  功能:
//      时钟校准写入低7位控制值
//  参数:
//      1.RD3:控制值
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField ClkInit_WBL7;
    RD0 = 0;
    RD0_SetBit19;
    StandBy_WRSel = RD0;
    RD0 = RD3;
    StandBy_WRCfg = RD0;
    RD2 = 2000;     //延迟1ms等待频率稳定
    call _Delay_RD2;
    Return_AutoField(0);


////////////////////////////////////////////////////////
//  名称:
//      ClkInit_FreqCheck_Confirm
//  功能:
//      多次确认当前主频是否已接近目标值
//  参数:
//      无
//  返回值:
//      1.RD0: 0~内部频率偏快 -1~内部频率偏慢
//      2.RD1: 稳定前确认次数
////////////////////////////////////////////////////////
Sub_AutoField ClkInit_FreqCheck_Confirm;
    push RD4;

    RD2 = 1;// RD2:总检测次数计数器
    // 初次检测频率
    call ClkInit_FreqCheck;
    RD4 = RD1;
    goto L_ClkInit_FreqCheck_Confirm_0;
    // 多次检测频率直到频率稳定
L_ClkInit_FreqCheck_Confirm_Loop:
    // 更新RD4为上次检测的计数值
    RD0 = RD3;
    RD4 = RD0;
L_ClkInit_FreqCheck_Confirm_0:
    // 或许这里需要增加延时？？？？？？？？？？？
    RD2 ++;
    call ClkInit_FreqCheck;
    RD3 = RD1;// 寄存当前检测计数值
    RD1 -= RD4;// 计算本次计数值与上次计数值差异
    RF_Abs(RD1);
    RD1 -= 10;// 当差异大于阈值时，继续检测
    if(RQ_nBorrow) goto L_ClkInit_FreqCheck_Confirm_Loop;

    // 差异小于阈值，过程结束
    RD1 = RD2;

    pop RD4;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  功能:时钟校准计数
//           2MIPS(Speed3)计数Debug_En低电平500us
//  返回值:
//      RD0 ：0 内部频率偏快
//          : -1 内部频率偏慢
//          RD1 : 内部计数值（暂时用于调试）
////////////////////////////////////////////////////////
Sub_AutoField ClkInit_FreqCheck;
    RD2 = 200;
    RD3 = 0;//计数器

//MODI 2020/5/28 15:52:24

    //同步下跳沿
//    Wait_While(Flag_DebugEn==0);
//    nop; nop;
//    Wait_While(Flag_DebugEn==1);
    RD0 = RN_IO_MAP_FREQ_CAL;
    GPIO_WEn0 = RD0;
L_ClkInit_FreqCheck_Sync0:
    RD0 = GPIO_Data0;
    if(Flag_Freq_Cal==0) goto L_ClkInit_FreqCheck_Sync0;
    nop;nop;
L_ClkInit_FreqCheck_Sync1:
    RD0 = GPIO_Data0;
    if(Flag_Freq_Cal==1) goto L_ClkInit_FreqCheck_Sync1;

    //一个循环4条指令，标定目标RD0 = 250
L_ClkInit_FreqCheck_L0:
    nop;
    RD3 ++;
    RD0 = GPIO_Data0;
    if(Flag_Freq_Cal==0) goto L_ClkInit_FreqCheck_L0;
    //if(Flag_DebugEn==0) goto L_ClkInit_FreqCheck_L0;

    RD1 = RD3;
    RD0 = RD3;
    RD0 -= RD2;
    if(RQ_nBorrow) goto L_ClkInit_FreqCheck_Fast;
L_ClkInit_FreqCheck_Slow:
    RD0 = -1;
    Return_AutoField(0);
L_ClkInit_FreqCheck_Fast:
    RD0 = 0;
    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      Set_Vref_SysClk
//  功能:
//      从GD25中读取电压校准值、频率校准值，写入基准系统
//      对应平台PrimoU600_V110
//  参数:
//      无
//  返回值：
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Set_Vref_SysClk;
    RD0 = StandBy_RDCfg;
    if(RD0_Bit0==1) goto L_Set_Vref_SysClk_End;
    RSP -= 3*MMU_BASE;
    RA0 = RSP;

#define GD25_VOLT    M[RA0+0*MMU_BASE]
#define GD25_FREQ    M[RA0+1*MMU_BASE]
#define GD25_Scene   M[RA0+0*MMU_BASE]
#define GD25_Vol     M[RA0+1*MMU_BASE]
#define GD25_Flag    M[RA0+2*MMU_BASE]

    // 读取校准值
    RD0 = RN_GD25_VOLT_ADDR;
    send_para(RD0);// 源地址
    send_para(RA0);// 目标地址
    RD0 = 2*MMU_BASE;
    send_para(RD0);// 读出长度（单位：字节）必须为4的整倍数
    call GD25_Read_Data;

    // 根据校准值设置电压、频率
    RD0 = GD25_FREQ;
    call ClkSetCfg_HA320G;
    RD0 = GD25_VOLT;
    call VrefSetCfg_HA320G;

#undef GD25_VOLT
#undef GD25_FREQ
#undef GD25_Scene
#undef GD25_Vol
#undef GD25_Flag

    RSP += 3*MMU_BASE;
L_Set_Vref_SysClk_End:
    Return_AutoField(0);

END SEGMENT
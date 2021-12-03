#define _TIMER_F_

#include <CPU11.def>
#include <Timer.def>
#include <SOC_Common.def>
#include <global.def>

extern Read_Flag10bit;
extern Write_Flag10bit;

CODE SEGMENT TIMER_F;
////////////////////////////////////////////
//  函数名称:
//      WatchDog_Init
//  函数功能:
//      看门狗初始化；
//  函数入口:无
//  函数出口:
//      无
////////////////////////////////////////////
Sub_AutoField  WatchDog_Init;
    OSC_Slow;
    RD0 = WatchDogDivFre;
    send_para(RD0);
    call _Timer_Number;      
    WatchDog_Time = RD0;
L_WatchDog_Init_End:
    Return_AutoField(0);



////////////////////////////////////////////
//  函数名称:
//      WatchDog_Start
//  函数功能:
//      看门狗启动；
//  函数入口:
//      无
//  函数出口:
//      无
////////////////////////////////////////////
Sub_AutoField WatchDog_Start;
    WatchDog_Disable;
    WatchDog_Enable;
    Push_Set_CPUSpeed(RN_SP2);
    WatchDog_Str;
    Pop_CPUSpeed;      
    Return_AutoField(0*MMU_BASE);


//////////////////////////////////////////////////////////////////////////
//  名称:
//      WatchDog_Reset
//  功能:
//      复位看门狗
//  参数:
//      无
//  返回值：
//      无
//////////////////////////////////////////////////////////////////////////
sub_autofield WatchDog_Reset;
    call Read_Flag10bit;
    if(RD0_Bit6==0) goto L_WatchDog_Reset_End;
    call WatchDog_Start;
L_WatchDog_Reset_End:
    Return_AutoField(0);


//////////////////////////////////////////////////////////////////////////
//  名称:
//      Read_Flag10bit
//  功能:
//      读出10bit信息
//  参数:
//      无
//  返回值：
//      1.RD0: 10bit数据，高位为0(out)
//  注释：
//      Speed3下运行
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Read_Flag10bit;
    Push_Set_CPUSpeed(RN_SP3);
    RD0 = StandBy_RDCfg;
    RF_RotateL8(RD0);
    RF_RotateL2(RD0);
    RD2 = 0x3ff;
    RD0 &= RD2;
    Pop_CPUSpeed;
    return_autofield(0);


END SEGMENT

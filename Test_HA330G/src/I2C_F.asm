#define _I2C_F_

#include <CPU11.def>
#include <SOC_Common.def>
#include <GPIO.def>
#include <I2C.def>

CODE SEGMENT I2C_F;
//// =============== Demo for I2C ===============
//    Sel_Cache4Data;// Cache设置为数据模式，CPU可读写其中的数据
//
//    // 初始化GPIO
//    RD0 = I2C_SDA | I2C_SCL;
//    GPIO_WEn0 = RD0;
//    RD0 = GPIO_IN|GPIO_PULL;
//    GPIO_Set0 = RD0;
//
//    // 接收数据
//    call I2C_Scan_Addr;
//    if(RD0_Bit0==0) goto L_Gets;
//    // 报错并忽略
//L_Gets:
//    RD0 = RN_Cache_StartAddr;
//    RA0 = RD0;
//    RD0 = RN_Cache_SIZE;
//    call I2C_Gets;
//    call I2C_Wait_Stop;
//
//    // 校验
//    RD0 = 0x123456;
//    send_para(RD0);// Temp
//    send_para(RD0);// Rst
//    send_para(RA0);
//    RD0 = RN_Cache_SIZE;
//    send_para(RD0);
//    call VerifySum_32;
//    RD2 = RD0;
//
//    // 发送校验值
//    call I2C_Scan_Addr;
//    if(RD0_Bit0==1) goto L_Puts;
//    // 报错并忽略
//L_Puts:
//    push RD2;
//    RA0 = RSP;
//    RD0 = 4;
//    call I2C_Puts;
//    call I2C_Wait_Stop;
//  pop RD0;
//    Sel_Cache4Inst;// Cache设置为指令模式，CPU可在其中取指令并执行
//
//// =============== End of Demo for I2C ===============



//////////////////////////////////////////////////////////////////////////
//  名称:
//      I2C_Scan_Addr
//  功能:
//      I2C扫描总线呼叫地址，一旦发现呼叫本机，给出Ack
//  参数:
//      无
//  返回值：
//      1.RD0:bit<7:1>~Addr   bit0~R/nW
//////////////////////////////////////////////////////////////////////////
Sub_AutoField I2C_Scan_Addr;
    // 等待起始位
L_I2C_Scan_Addr_Wait_Start:
    RD0 = I2C_SDA | I2C_SCL;
    GPIO_WEn0 = RD0;
L_I2C_Scan_Addr_Wait_Start_Loop:
    RD0 = GPIO_Data0;
    if(I2C_SDA_Level == 1) goto L_I2C_Scan_Addr_Wait_Start_Loop;

    // 读取呼叫地址（本机地址为0x00）
    call I2C_Getchar;
    RD2 = RD0;
    RF_ShiftR1(RD0);
    if(RD0_Zero) goto L_I2C_Scan_Addr_Ack;

    // 等待停止位并重新等待起始位
    call I2C_Wait_Stop;
    goto L_I2C_Scan_Addr_Wait_Start;

L_I2C_Scan_Addr_Ack:
    // 发送Ack
    call I2C_Send_Ack;
    RD0 = RD2;
    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      I2C_Wait_Stop
//  功能:
//      I2C等待停止位
//  参数:
//      无
//  返回值：
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField I2C_Wait_Stop;
    RD0 = I2C_SCL;
    GPIO_WEn0 = RD0;
L_I2C_Wait_Stop_Loop2:
    RD0 = GPIO_Data0;
    if(I2C_SCL_Level == 1) goto L_I2C_Wait_Stop_Loop2;

    RD0 = I2C_SCL|I2C_SDA;
    GPIO_WEn0 = RD0;
    GPIO_Data0 = RD0;
    RD0 = GPIO_IN|GPIO_PULL;
    GPIO_Set0 = RD0;

L_I2C_Wait_Stop_Loop:
    RD0 = GPIO_Data0;
    if(I2C_SCL_Level == 0) goto L_I2C_Wait_Stop_Cancel;
    if(I2C_SDA_Level == 0) goto L_I2C_Wait_Stop_Loop;
    goto L_I2C_Wait_Stop_End;

L_I2C_Wait_Stop_Cancel:
    // 等待SCL上升沿
    RD0 = GPIO_Data0;
    if(I2C_SCL_Level == 0) goto L_I2C_Wait_Stop_Cancel;
    goto L_I2C_Wait_Stop_Loop;

L_I2C_Wait_Stop_End:
    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      I2C_Getchar
//  功能:
//      I2C接收1字节数据，不含Ack操作
//  参数:
//      无
//  返回值：
//      1.RD0:接收到的1字节数据
//////////////////////////////////////////////////////////////////////////
Sub_AutoField I2C_Getchar;
    push RD4;

    RD3 = 0;// 数据寄存器
    RD4 = 8;// 循环变量
L_I2C_Getchar_Loop:
    // 等待SCL下降沿
    RD0 = I2C_SCL;
    GPIO_WEn0 = RD0;
L_I2C_Getchar_Wait_SCL_Negedge:
    RD0 = GPIO_Data0;
    if(I2C_SCL_Level == 1) goto L_I2C_Getchar_Wait_SCL_Negedge;

    // 设置SDA为带上拉输入
    RD0 = I2C_SDA;
    GPIO_WEn0 = RD0;
    GPIO_Data0 = RD0;
    RD0 = GPIO_IN|GPIO_PULL;
    GPIO_Set0 = RD0;

    // 等待SCL上升沿
    RD0 = I2C_SCL;
    GPIO_WEn0 = RD0;
L_I2C_Getchar_Wait_SCL_Posedge:
    RD0 = GPIO_Data0;
    if(I2C_SCL_Level == 0) goto L_I2C_Getchar_Wait_SCL_Posedge;

    // 读取1bit数据
    RD0 = I2C_SDA;
    GPIO_WEn0 = RD0;
    RF_ShiftL1(RD3);
    RD0 = GPIO_Data0;
    if(I2C_SDA_Level == 0) goto L_I2C_Getchar_SDA_Zero;
    RD3 ++;
L_I2C_Getchar_SDA_Zero:
    RD4 --;
    if(RQ_nZero) goto L_I2C_Getchar_Loop;
    RD0 = RD3;
    pop RD4;
    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      I2C_Send_Ack
//  功能:
//      发送Ack
//  参数:
//      无
//  返回值：
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField I2C_Send_Ack;
    // 等待SCL下降沿
    GPIO_WEn0 = I2C_SCL;
L_I2C_Send_Ack_Wait_SCL_Negedge:
    RD0 = GPIO_Data0;
    if(I2C_SCL_Level == 1) goto L_I2C_Send_Ack_Wait_SCL_Negedge;

    // 设置SDA为带上拉OC输出并拉低，表示发送Ackx
    GPIO_WEn0 = I2C_SDA;
    RD0 = GPIO_OUT|GPIO_OC|GPIO_PULL;
    GPIO_Set0 = RD0;
    GPIO_Data0 = 0;

    // 等待SCL上升沿
    GPIO_WEn0 = I2C_SCL;
L_I2C_Send_Ack_Wait_SCL_Posedge:
    RD0 = GPIO_Data0;
    if(I2C_SCL_Level == 0) goto L_I2C_Send_Ack_Wait_SCL_Posedge;

    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      I2C_Gets
//  功能:
//      I2C接收指定长度的数据
//  参数:
//      1.RA0:数据首地址
//      2.RD0:长度(单位：字节，满足4的整倍数)
//  返回值：
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField I2C_Gets;
    RD2 = RD0;
L_I2C_Gets_Loop:
    call I2C_Getchar;
    RD3 = RD0;
    call I2C_Send_Ack;
    RF_RotateL8(RD3);
    call I2C_Getchar;
    RD3 += RD0;
    call I2C_Send_Ack;
    RF_RotateL8(RD3);
    call I2C_Getchar;
    RD3 += RD0;
    call I2C_Send_Ack;
    RF_RotateL8(RD3);
    call I2C_Getchar;
    RD3 += RD0;
    call I2C_Send_Ack;
    M[RA0++] = RD3;
    RD2 -= 4;
    if(RQ_nZero) goto L_I2C_Gets_Loop;

    Return_AutoField(0);


//////////////////////////////////////////////////////////////////////////
//  名称:
//      I2C_Putchar
//  功能:
//      I2C发送1字节数据，不含Ack检测。
//  参数:
//      1.RD0:要发送的1字节数据，低8位有效
//  返回值：
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField I2C_Putchar;
    push RD4;

    RD3 = RD0;// 数据寄存器
    RD4 = 8;// 循环变量
L_I2C_Putchar_Loop:
    // 等待SCL下降沿
    RD0 = I2C_SCL;
    GPIO_WEn0 = RD0;
L_I2C_Putchar_Wait_SCL_Negedge:
    RD0 = GPIO_Data0;
    if(I2C_SCL_Level == 1) goto L_I2C_Putchar_Wait_SCL_Negedge;

    // 设置SDA为带上拉OC输出
    RD0 = I2C_SDA;
    GPIO_WEn0 = RD0;
    GPIO_Data0 = RD0;
    RD0 = GPIO_OUT|GPIO_OC|GPIO_PULL;
    GPIO_Set0 = RD0;

    // 发送1bit数据
    RD0 = RD3;
    RF_ShiftL1(RD3);
    if(RD0_Bit7==0) goto L_I2C_Putchar_SDA_Zero;
    RD0 = I2C_SDA;
    GPIO_Data0 = RD0;
    goto L_I2C_Putchar_Wait_SCL_Posedge;
L_I2C_Putchar_SDA_Zero:
    RD0 = 0;
    GPIO_Data0 = RD0;

    // 等待SCL上升沿
L_I2C_Putchar_Wait_SCL_Posedge:
    RD0 = I2C_SCL;
    GPIO_WEn0 = RD0;
L_I2C_Putchar_Wait_SCL_Posedge_Loop:
    RD0 = GPIO_Data0;
    if(I2C_SCL_Level == 0) goto L_I2C_Putchar_Wait_SCL_Posedge_Loop;

    RD4 --;
    if(RQ_nZero) goto L_I2C_Putchar_Loop;

    pop RD4;
    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      I2C_Get_Ack
//  功能:
//      检测Ack，暂时固定返回正常，忽略nAck
//  参数:
//      无
//  返回值：
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField I2C_Get_Ack;
    // 等待SCL下降沿
    RD0 = I2C_SCL;
    GPIO_WEn0 = RD0;
L_I2C_Get_Ack_Wait_SCL_Negedge:
    RD0 = GPIO_Data0;
    if(I2C_SCL_Level == 1) goto L_I2C_Get_Ack_Wait_SCL_Negedge;

    // 设置SDA为带上拉输入
    RD0 = I2C_SDA;
    GPIO_WEn0 = RD0;
    GPIO_Data0 = RD0;
    RD0 = GPIO_IN|GPIO_PULL;
    GPIO_Set0 = RD0;

    // 等待SCL上升沿
    RD0 = I2C_SCL;
    GPIO_WEn0 = RD0;
L_I2C_Get_Ack_Wait_SCL_Posedge:
    RD0 = GPIO_Data0;
    if(I2C_SCL_Level == 0) goto L_I2C_Get_Ack_Wait_SCL_Posedge;
    Return_AutoField(0);


//////////////////////////////////////////////////////////////////////////
//  名称:
//      I2C_Puts
//  功能:
//      I2C发送指定长度的数据
//  参数:
//      1.RA0:数据首地址
//      2.RD0:长度(单位：字节，满足4的整倍数)
//  返回值：
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField I2C_Puts;
    RD2 = RD0;
L_I2C_Puts_Loop:
    RD3 = M[RA0++];
    RF_RotateL8(RD3);
    RD0 = RD3;
    call I2C_Putchar;
    call I2C_Get_Ack;
    RF_RotateL8(RD3);
    RD0 = RD3;
    call I2C_Putchar;
    call I2C_Get_Ack;
    RF_RotateL8(RD3);
    RD0 = RD3;
    call I2C_Putchar;
    call I2C_Get_Ack;
    RF_RotateL8(RD3);
    RD0 = RD3;
    call I2C_Putchar;
    call I2C_Get_Ack;

    RD2 -= 4;
    if(RQ_nZero) goto L_I2C_Puts_Loop;

    Return_AutoField(0);

END SEGMENT
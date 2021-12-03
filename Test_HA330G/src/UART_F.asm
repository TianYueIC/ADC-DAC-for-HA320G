#define _UART_F_

#include <CPU11.def>
#include <USI.def>
#include <SOC_Common.def>

CODE SEGMENT UART_F;
////////////////////////////////////////////////////////
//  名称:
//      UART_Init
//  功能:
//      USI_COM0配置为UART
//  参数:
//      1.端口号
//      2.波特率对应的TimerNum值 = F(主频Hz / bps / 2)
//      3.停止位 1 2
//      4.校验设置 0无校验，1偶校验，2奇校验
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField UART_Init;

    RD2 = 0b100001011001011;// slow
    //RD2 = 0b100001001001011;// fast

    RD3 = 9;

    RD0 = M[RSP+3*MMU_BASE];
    USI_Num = RD0;                      //设置端口号
    USI_Disable;

//    RD0 = RV_RN_FreqCPU;
//    RD1 = 12282;
//    call _Ru_Multi;
//    RD1 = M[RSP+2*MMU_BASE];
//    call _Ru_Div;
//    send_para(RD0);
//    call _Timer_Number;                 //得到选定波特率的分频数
    RD0 = M[RSP+2*MMU_BASE];
    RF_Not(RD0);
    USI_SelPort = Counter1_Port;
    USI_Data = RD0;                     //配置BPS值

    RD0 = M[RSP+0*MMU_BASE];            //判断有无校验位
    RD1 = RD0;
    if(RD0_Zero) goto _UART_Init_Sel_StopBit;
    RD0 = RD2;
    RD0_SetBit4;                        //配置为有校验位
    RD2 = RD0;
    RD3 += 1;                           //有校验位，计数器长度加一
    RD1 -= 1;
    if(RQ_nZero) goto _UART_Init_Sel_StopBit;
    RD0 = RD2;
    RD0_SetBit5;                        //设置为奇校验
    RD2 = RD0;

_UART_Init_Sel_StopBit:
    RD0 = M[RSP+1*MMU_BASE];
    RD0 -= 1;
    if(RD0<=0) goto _UART_Init_Set_Port;
    RD3 += 1;
    RD0 = RD2;
    RD0_ClrBit6;                        //设置为两个停止位
    RD2 = RD0;

_UART_Init_Set_Port:
    RD0 = RD2;
    USI_SelPort = Config_Port;
    USI_Data = RD0;

    RD0 = RD3;
    RF_Exp(RD0);
    USI_SelPort = Counter2_Port;
    USI_Data = RD0;

_UART_Init_End:
    USI_SelPort = Data_Port;            //最后将端口类型默认设置为数据

    USI_Enable;
    USI_EnableRx;

    Return_AutoField(4*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      UART_Putchar
//  功能:
//      UART_COM0发送1字节数据
//  参数:
//      1.待发送的1字节数据，低8位有效
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField UART_Putchar;
    USI_Num = COM0;

    USI_Disable;
    USI_Enable;
    USI_DisTxRx;
    USI_EnableTx;
    RD0 = M[RSP+0*MMU_BASE];
    USI_Data = RD0;
_UART_Putchar_End:
    if(USI_Flag==0) goto _UART_Putchar_End;
    USI_DisTxRx;
    USI_EnableRx;
    Return_AutoField(1*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      UART_Puts
//  功能:
//      UART_COM0发送指定长度数据
//  参数:
//      1.长度(单位：字节，满足4的整倍数)
//      2.待发送的数据首地址
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField UART_Puts;
    USI_Num = COM0;
    RD2 = M[RSP+1*MMU_BASE];
    RA0 = M[RSP+0*MMU_BASE];
L_UART_Puts_Loop:
    RD3 = M[RA0];
//RF_RotateL16(RD3);

    RF_RotateL8(RD3);
    send_para(RD3);
    call UART_Putchar;

    RF_RotateL8(RD3);
    send_para(RD3);
    call UART_Putchar;

    RF_RotateL8(RD3);
    send_para(RD3);
    call UART_Putchar;

    RF_RotateL8(RD3);
    send_para(RD3);
    call UART_Putchar;

    RA0 += 4;
    RD2 -= 4;
    if(RQ_nZero) goto L_UART_Puts_Loop;
    Return_AutoField(2*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      UART_PutDword
//  功能:
//      UART_COM0发送4字节数据
//  参数:
//      1.待发送的4字节数据
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField UART_PutDword;
    USI_Num = COM0;
    RD3 = M[RSP+0*MMU_BASE];

    RF_RotateL8(RD3);
    send_para(RD3);
    call UART_Putchar;

    RF_RotateL8(RD3);
    send_para(RD3);
    call UART_Putchar;

    RF_RotateL8(RD3);
    send_para(RD3);
    call UART_Putchar;

    RF_RotateL8(RD3);
    send_para(RD3);
    call UART_Putchar;

    Return_AutoField(1*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      UART_Putchar_COM1
//  功能:
//      UART_COM1发送1字节数据
//  参数:
//      1.待发送的1字节数据，低8位有效
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField UART_Putchar_COM1;
    USI_Num = COM1;

    USI_Disable;
    USI_Enable;
    USI_DisTxRx;
    USI_EnableTx;
    RD0 = M[RSP+0*MMU_BASE];
    USI_Data = RD0;
_UART_Putchar_COM1_End:
    if(USI_Flag==0) goto _UART_Putchar_COM1_End;
    USI_DisTxRx;
    USI_EnableRx;
    Return_AutoField(1*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      UART_PutDword_COM1
//  功能:
//      UART_COM1发送4字节数据
//  参数:
//      1.待发送的4字节数据
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField UART_PutDword_COM1;
    USI_Num = COM1;
    RD3 = M[RSP+0*MMU_BASE];

    RF_RotateL8(RD3);
    send_para(RD3);
    call UART_Putchar_COM1;

    RF_RotateL8(RD3);
    send_para(RD3);
    call UART_Putchar_COM1;

    RF_RotateL8(RD3);
    send_para(RD3);
    call UART_Putchar_COM1;

    RF_RotateL8(RD3);
    send_para(RD3);
    call UART_Putchar_COM1;

    Return_AutoField(1*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      UART_SetRev
//  功能:
//      将UART_COM0设置为接收状态
//  参数:
//      无
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField UART_SetRev;
    USI_Num = COM0;
    USI_EnableRx;
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      UART_CheckEnd
//  功能:
//      查询UART_COM0是否已经接收到数据
//  参数:
//      无
//  返回值:
//      1.RD0:COM0~已接收到1字节，0~未接收到
////////////////////////////////////////////////////////
Sub_AutoField UART_CheckEnd;
    RD0 = COM0;
    USI_Num = COM0;
    if(USI_Flag==1) goto L_UART_CheckEnd_End;
    RD0 = 0;
L_UART_CheckEnd_End:
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      UART_WaitEnd
//  功能:
//      等待UART_COM0接收到数据//，超时时间100ms
//  参数:
//      无
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField UART_WaitEnd;
    USI_Num = COM0;
    RD0 = 1;

    RD2 = 600000/5;// 100ms @6MIPS Speed5
L_UART_WaitEnd:
    RD2 --;
    //if(RQ_Zero) goto L_UART_WaitEnd_TO;
    if(USI_Flag==0) goto L_UART_WaitEnd;
    RD0 = 0;
L_UART_WaitEnd_TO:
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      UART_ReadBuf
//  功能:
//      读取UART_COM0硬件缓冲区(1字节)
//  参数:
//      无
//  返回值:
//      1.RD0:收到的1字节数据，低8位有效
////////////////////////////////////////////////////////
Sub_AutoField UART_ReadBuf;
    USI_Num = COM0;
    RD0 = USI_Data;
    RF_ShiftR2(RD0);
    RF_ShiftR1(RD0);
    RF_GetL8(RD0);
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      UART_Gets
//  功能:
//      UART_COM0接收指定长度数据
//  参数:
//      1.长度(单位：字节，满足4的整倍数)
//      2.接收缓冲区首地址(out)
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField UART_Gets;
    USI_Num = COM0;

    RA0 = M[RSP+0*MMU_BASE];
    RD1 = M[RSP+1*MMU_BASE];

_UART_Gets_Loop:
    RD3 = 750000/9;
_UART_Gets_Loop_Wait1:
    nop;nop;nop;nop;
    RD3--;
    //if(RQ_Zero) goto L_UART_Gets_TO;
    if(USI_Flag==0) goto _UART_Gets_Loop_Wait1;

    RD0 = USI_Data;
    RF_ShiftR2(RD0);
    RF_ShiftR1(RD0);
    RF_GetL8(RD0);
    RD2 = RD0;
    RF_RotateL8(RD2);

    RD3 = 750000/9;
_UART_Gets_Loop_Wait2:
    nop;nop;nop;nop;
    RD3--;
    //if(RQ_Zero) goto L_UART_Gets_TO;
    if(USI_Flag==0) goto _UART_Gets_Loop_Wait2;

    RD0 = USI_Data;
    RF_ShiftR2(RD0);
    RF_ShiftR1(RD0);
    RF_GetL8(RD0);
    RD2 |= RD0;
    RF_RotateL8(RD2);

    RD3 = 750000/9;
_UART_Gets_Loop_Wait3:
    nop;nop;nop;nop;
    RD3--;
    //if(RQ_Zero) goto L_UART_Gets_TO;
    if(USI_Flag==0) goto _UART_Gets_Loop_Wait3;

    RD0 = USI_Data;
    RF_ShiftR2(RD0);
    RF_ShiftR1(RD0);
    RF_GetL8(RD0);
    RD2 |= RD0;
    RF_RotateL8(RD2);

    RD3 = 750000/9;
_UART_Gets_Loop_Wait4:
    nop;nop;nop;nop;
    RD3--;
    //if(RQ_Zero) goto L_UART_Gets_TO;
    if(USI_Flag==0) goto _UART_Gets_Loop_Wait4;

    RD0 = USI_Data;
    RF_ShiftR2(RD0);
    RF_ShiftR1(RD0);
    RF_GetL8(RD0);
    RD2 |= RD0;

    M[RA0++] = RD2;
    RD1 -= 4;
    if(RQ_nZero) goto _UART_Gets_Loop;

_UART_Gets_Loop_End:
    RD0 = 0;
    Return_AutoField(2*MMU_BASE);

L_UART_Gets_TO:
    RD0 = 1;
    Return_AutoField(2*MMU_BASE);

END SEGMENT
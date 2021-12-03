#define _UART_F_

#include <CPU11.def>
#include <USI.def>
#include <SOC_Common.def>

CODE SEGMENT UART_F;
////////////////////////////////////////////////////////
//  ����:
//      UART_Init
//  ����:
//      USI_COM0����ΪUART
//  ����:
//      1.�˿ں�
//      2.�����ʶ�Ӧ��TimerNumֵ = F(��ƵHz / bps / 2)
//      3.ֹͣλ 1 2
//      4.У������ 0��У�飬1żУ�飬2��У��
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField UART_Init;

    RD2 = 0b100001011001011;// slow
    //RD2 = 0b100001001001011;// fast

    RD3 = 9;

    RD0 = M[RSP+3*MMU_BASE];
    USI_Num = RD0;                      //���ö˿ں�
    USI_Disable;

//    RD0 = RV_RN_FreqCPU;
//    RD1 = 12282;
//    call _Ru_Multi;
//    RD1 = M[RSP+2*MMU_BASE];
//    call _Ru_Div;
//    send_para(RD0);
//    call _Timer_Number;                 //�õ�ѡ�������ʵķ�Ƶ��
    RD0 = M[RSP+2*MMU_BASE];
    RF_Not(RD0);
    USI_SelPort = Counter1_Port;
    USI_Data = RD0;                     //����BPSֵ

    RD0 = M[RSP+0*MMU_BASE];            //�ж�����У��λ
    RD1 = RD0;
    if(RD0_Zero) goto _UART_Init_Sel_StopBit;
    RD0 = RD2;
    RD0_SetBit4;                        //����Ϊ��У��λ
    RD2 = RD0;
    RD3 += 1;                           //��У��λ�����������ȼ�һ
    RD1 -= 1;
    if(RQ_nZero) goto _UART_Init_Sel_StopBit;
    RD0 = RD2;
    RD0_SetBit5;                        //����Ϊ��У��
    RD2 = RD0;

_UART_Init_Sel_StopBit:
    RD0 = M[RSP+1*MMU_BASE];
    RD0 -= 1;
    if(RD0<=0) goto _UART_Init_Set_Port;
    RD3 += 1;
    RD0 = RD2;
    RD0_ClrBit6;                        //����Ϊ����ֹͣλ
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
    USI_SelPort = Data_Port;            //��󽫶˿�����Ĭ������Ϊ����

    USI_Enable;
    USI_EnableRx;

    Return_AutoField(4*MMU_BASE);



////////////////////////////////////////////////////////
//  ����:
//      UART_Putchar
//  ����:
//      UART_COM0����1�ֽ�����
//  ����:
//      1.�����͵�1�ֽ����ݣ���8λ��Ч
//  ����ֵ:
//      ��
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
//  ����:
//      UART_Puts
//  ����:
//      UART_COM0����ָ����������
//  ����:
//      1.����(��λ���ֽڣ�����4��������)
//      2.�����͵������׵�ַ
//  ����ֵ:
//      ��
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
//  ����:
//      UART_PutDword
//  ����:
//      UART_COM0����4�ֽ�����
//  ����:
//      1.�����͵�4�ֽ�����
//  ����ֵ:
//      ��
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
//  ����:
//      UART_Putchar_COM1
//  ����:
//      UART_COM1����1�ֽ�����
//  ����:
//      1.�����͵�1�ֽ����ݣ���8λ��Ч
//  ����ֵ:
//      ��
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
//  ����:
//      UART_PutDword_COM1
//  ����:
//      UART_COM1����4�ֽ�����
//  ����:
//      1.�����͵�4�ֽ�����
//  ����ֵ:
//      ��
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
//  ����:
//      UART_SetRev
//  ����:
//      ��UART_COM0����Ϊ����״̬
//  ����:
//      ��
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField UART_SetRev;
    USI_Num = COM0;
    USI_EnableRx;
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  ����:
//      UART_CheckEnd
//  ����:
//      ��ѯUART_COM0�Ƿ��Ѿ����յ�����
//  ����:
//      ��
//  ����ֵ:
//      1.RD0:COM0~�ѽ��յ�1�ֽڣ�0~δ���յ�
////////////////////////////////////////////////////////
Sub_AutoField UART_CheckEnd;
    RD0 = COM0;
    USI_Num = COM0;
    if(USI_Flag==1) goto L_UART_CheckEnd_End;
    RD0 = 0;
L_UART_CheckEnd_End:
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  ����:
//      UART_WaitEnd
//  ����:
//      �ȴ�UART_COM0���յ�����//����ʱʱ��100ms
//  ����:
//      ��
//  ����ֵ:
//      ��
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
//  ����:
//      UART_ReadBuf
//  ����:
//      ��ȡUART_COM0Ӳ��������(1�ֽ�)
//  ����:
//      ��
//  ����ֵ:
//      1.RD0:�յ���1�ֽ����ݣ���8λ��Ч
////////////////////////////////////////////////////////
Sub_AutoField UART_ReadBuf;
    USI_Num = COM0;
    RD0 = USI_Data;
    RF_ShiftR2(RD0);
    RF_ShiftR1(RD0);
    RF_GetL8(RD0);
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  ����:
//      UART_Gets
//  ����:
//      UART_COM0����ָ����������
//  ����:
//      1.����(��λ���ֽڣ�����4��������)
//      2.���ջ������׵�ַ(out)
//  ����ֵ:
//      ��
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
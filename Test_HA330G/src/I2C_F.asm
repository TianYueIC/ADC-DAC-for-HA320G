#define _I2C_F_

#include <CPU11.def>
#include <SOC_Common.def>
#include <GPIO.def>
#include <I2C.def>

CODE SEGMENT I2C_F;
//// =============== Demo for I2C ===============
//    Sel_Cache4Data;// Cache����Ϊ����ģʽ��CPU�ɶ�д���е�����
//
//    // ��ʼ��GPIO
//    RD0 = I2C_SDA | I2C_SCL;
//    GPIO_WEn0 = RD0;
//    RD0 = GPIO_IN|GPIO_PULL;
//    GPIO_Set0 = RD0;
//
//    // ��������
//    call I2C_Scan_Addr;
//    if(RD0_Bit0==0) goto L_Gets;
//    // ��������
//L_Gets:
//    RD0 = RN_Cache_StartAddr;
//    RA0 = RD0;
//    RD0 = RN_Cache_SIZE;
//    call I2C_Gets;
//    call I2C_Wait_Stop;
//
//    // У��
//    RD0 = 0x123456;
//    send_para(RD0);// Temp
//    send_para(RD0);// Rst
//    send_para(RA0);
//    RD0 = RN_Cache_SIZE;
//    send_para(RD0);
//    call VerifySum_32;
//    RD2 = RD0;
//
//    // ����У��ֵ
//    call I2C_Scan_Addr;
//    if(RD0_Bit0==1) goto L_Puts;
//    // ��������
//L_Puts:
//    push RD2;
//    RA0 = RSP;
//    RD0 = 4;
//    call I2C_Puts;
//    call I2C_Wait_Stop;
//  pop RD0;
//    Sel_Cache4Inst;// Cache����Ϊָ��ģʽ��CPU��������ȡָ�ִ��
//
//// =============== End of Demo for I2C ===============



//////////////////////////////////////////////////////////////////////////
//  ����:
//      I2C_Scan_Addr
//  ����:
//      I2Cɨ�����ߺ��е�ַ��һ�����ֺ��б���������Ack
//  ����:
//      ��
//  ����ֵ��
//      1.RD0:bit<7:1>~Addr   bit0~R/nW
//////////////////////////////////////////////////////////////////////////
Sub_AutoField I2C_Scan_Addr;
    // �ȴ���ʼλ
L_I2C_Scan_Addr_Wait_Start:
    RD0 = I2C_SDA | I2C_SCL;
    GPIO_WEn0 = RD0;
L_I2C_Scan_Addr_Wait_Start_Loop:
    RD0 = GPIO_Data0;
    if(I2C_SDA_Level == 1) goto L_I2C_Scan_Addr_Wait_Start_Loop;

    // ��ȡ���е�ַ��������ַΪ0x00��
    call I2C_Getchar;
    RD2 = RD0;
    RF_ShiftR1(RD0);
    if(RD0_Zero) goto L_I2C_Scan_Addr_Ack;

    // �ȴ�ֹͣλ�����µȴ���ʼλ
    call I2C_Wait_Stop;
    goto L_I2C_Scan_Addr_Wait_Start;

L_I2C_Scan_Addr_Ack:
    // ����Ack
    call I2C_Send_Ack;
    RD0 = RD2;
    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      I2C_Wait_Stop
//  ����:
//      I2C�ȴ�ֹͣλ
//  ����:
//      ��
//  ����ֵ��
//      ��
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
    // �ȴ�SCL������
    RD0 = GPIO_Data0;
    if(I2C_SCL_Level == 0) goto L_I2C_Wait_Stop_Cancel;
    goto L_I2C_Wait_Stop_Loop;

L_I2C_Wait_Stop_End:
    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      I2C_Getchar
//  ����:
//      I2C����1�ֽ����ݣ�����Ack����
//  ����:
//      ��
//  ����ֵ��
//      1.RD0:���յ���1�ֽ�����
//////////////////////////////////////////////////////////////////////////
Sub_AutoField I2C_Getchar;
    push RD4;

    RD3 = 0;// ���ݼĴ���
    RD4 = 8;// ѭ������
L_I2C_Getchar_Loop:
    // �ȴ�SCL�½���
    RD0 = I2C_SCL;
    GPIO_WEn0 = RD0;
L_I2C_Getchar_Wait_SCL_Negedge:
    RD0 = GPIO_Data0;
    if(I2C_SCL_Level == 1) goto L_I2C_Getchar_Wait_SCL_Negedge;

    // ����SDAΪ����������
    RD0 = I2C_SDA;
    GPIO_WEn0 = RD0;
    GPIO_Data0 = RD0;
    RD0 = GPIO_IN|GPIO_PULL;
    GPIO_Set0 = RD0;

    // �ȴ�SCL������
    RD0 = I2C_SCL;
    GPIO_WEn0 = RD0;
L_I2C_Getchar_Wait_SCL_Posedge:
    RD0 = GPIO_Data0;
    if(I2C_SCL_Level == 0) goto L_I2C_Getchar_Wait_SCL_Posedge;

    // ��ȡ1bit����
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
//  ����:
//      I2C_Send_Ack
//  ����:
//      ����Ack
//  ����:
//      ��
//  ����ֵ��
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField I2C_Send_Ack;
    // �ȴ�SCL�½���
    GPIO_WEn0 = I2C_SCL;
L_I2C_Send_Ack_Wait_SCL_Negedge:
    RD0 = GPIO_Data0;
    if(I2C_SCL_Level == 1) goto L_I2C_Send_Ack_Wait_SCL_Negedge;

    // ����SDAΪ������OC��������ͣ���ʾ����Ackx
    GPIO_WEn0 = I2C_SDA;
    RD0 = GPIO_OUT|GPIO_OC|GPIO_PULL;
    GPIO_Set0 = RD0;
    GPIO_Data0 = 0;

    // �ȴ�SCL������
    GPIO_WEn0 = I2C_SCL;
L_I2C_Send_Ack_Wait_SCL_Posedge:
    RD0 = GPIO_Data0;
    if(I2C_SCL_Level == 0) goto L_I2C_Send_Ack_Wait_SCL_Posedge;

    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      I2C_Gets
//  ����:
//      I2C����ָ�����ȵ�����
//  ����:
//      1.RA0:�����׵�ַ
//      2.RD0:����(��λ���ֽڣ�����4��������)
//  ����ֵ��
//      ��
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
//  ����:
//      I2C_Putchar
//  ����:
//      I2C����1�ֽ����ݣ�����Ack��⡣
//  ����:
//      1.RD0:Ҫ���͵�1�ֽ����ݣ���8λ��Ч
//  ����ֵ��
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField I2C_Putchar;
    push RD4;

    RD3 = RD0;// ���ݼĴ���
    RD4 = 8;// ѭ������
L_I2C_Putchar_Loop:
    // �ȴ�SCL�½���
    RD0 = I2C_SCL;
    GPIO_WEn0 = RD0;
L_I2C_Putchar_Wait_SCL_Negedge:
    RD0 = GPIO_Data0;
    if(I2C_SCL_Level == 1) goto L_I2C_Putchar_Wait_SCL_Negedge;

    // ����SDAΪ������OC���
    RD0 = I2C_SDA;
    GPIO_WEn0 = RD0;
    GPIO_Data0 = RD0;
    RD0 = GPIO_OUT|GPIO_OC|GPIO_PULL;
    GPIO_Set0 = RD0;

    // ����1bit����
    RD0 = RD3;
    RF_ShiftL1(RD3);
    if(RD0_Bit7==0) goto L_I2C_Putchar_SDA_Zero;
    RD0 = I2C_SDA;
    GPIO_Data0 = RD0;
    goto L_I2C_Putchar_Wait_SCL_Posedge;
L_I2C_Putchar_SDA_Zero:
    RD0 = 0;
    GPIO_Data0 = RD0;

    // �ȴ�SCL������
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
//  ����:
//      I2C_Get_Ack
//  ����:
//      ���Ack����ʱ�̶���������������nAck
//  ����:
//      ��
//  ����ֵ��
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField I2C_Get_Ack;
    // �ȴ�SCL�½���
    RD0 = I2C_SCL;
    GPIO_WEn0 = RD0;
L_I2C_Get_Ack_Wait_SCL_Negedge:
    RD0 = GPIO_Data0;
    if(I2C_SCL_Level == 1) goto L_I2C_Get_Ack_Wait_SCL_Negedge;

    // ����SDAΪ����������
    RD0 = I2C_SDA;
    GPIO_WEn0 = RD0;
    GPIO_Data0 = RD0;
    RD0 = GPIO_IN|GPIO_PULL;
    GPIO_Set0 = RD0;

    // �ȴ�SCL������
    RD0 = I2C_SCL;
    GPIO_WEn0 = RD0;
L_I2C_Get_Ack_Wait_SCL_Posedge:
    RD0 = GPIO_Data0;
    if(I2C_SCL_Level == 0) goto L_I2C_Get_Ack_Wait_SCL_Posedge;
    Return_AutoField(0);


//////////////////////////////////////////////////////////////////////////
//  ����:
//      I2C_Puts
//  ����:
//      I2C����ָ�����ȵ�����
//  ����:
//      1.RA0:�����׵�ַ
//      2.RD0:����(��λ���ֽڣ�����4��������)
//  ����ֵ��
//      ��
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
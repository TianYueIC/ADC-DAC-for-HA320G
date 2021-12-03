#define _GD25_F_

#include <CPU11.def>
#include <resource_allocation.def>
#include <GPIO.def>
#include <GD25.def>
#include <BL_SPI.def>
#include <string.def>
#include <global.def>
#include <Timer.def>

CODE SEGMENT GD25_F;
//////////////////////////////////////////////////////////////////////////
//  ����:
//      GD25_Release_DP
//  ����:
//      �˳��������ģʽ
//  ����:
//      ��
//  ����ֵ:
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Release_DP;

     //CS�õ�
    RD0 = CS;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;

    RD0 = 0xAB;
    call SPI_Send_Byte;

    //CS�ø�
    RD0 = CS;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;

    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      GD25_DP
//  ����:
//      �����������ģʽ
//  ����:
//      ��
//  ����ֵ:
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_DP;

     //CS�õ�
    RD0 = CS;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;

    RD0 = 0xB9;
    call SPI_Send_Byte;

    //CS�ø�
    RD0 = CS;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;

    Return_AutoField(0);

//////////////////////////////////////////////////////////////////////////
//  ����:
//      GD25_Write_En
//  ����:
//      дʹ��
//  ����:
//      ��
//  ����ֵ:
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Write_En;

     //CS�õ�
    RD0 = CS;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;

    RD0 = 0x06;
    call SPI_Send_Byte;

    //CS�ø�
    RD0 = CS;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;

    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      GD25_Write_Dis
//  ����:
//      д����
//  ����:
//      ��
//  ����ֵ:
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Write_Dis;

    //CS�õ�
    RD0 = CS;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;

    RD0 = 0x04;
    call SPI_Send_Byte;

    //CS�ø�
    RD0 = CS;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;

    Return_AutoField(0);


//////////////////////////////////////////////////////////////////////////
//  ����:
//      GD25_Read_Status_Register
//  ����:
//      ��״̬�Ĵ���
//  ����:
//      ��
//  ����ֵ:
//      1.RD0:�Ĵ�����״̬λ
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Read_Status_Register;

     //CS�õ�
    RD0 = CS;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;

    RD0 = 0x05;
    call SPI_Send_Byte;
    call SPI_Read_Byte;

    //CS�ø�
    RD1 = CS;
    GPIO_WEn1 = RD1;
    GPIO_Data1 = RD1;

    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      GD25_Write_Status_Register
//  ����:
//      д״̬�Ĵ���
//  ����:
//      1.״̬�Ĵ���ֵ
//  ����ֵ:
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Write_Status_Register;
    call GD25_Write_En;
    //CS�õ�
    RD0 = CS;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;

    RD0 = 01;
    call SPI_Send_Byte;
    RD0 = M[RSP+0*MMU_BASE];
    call SPI_Send_Byte;

    //CS�ø�
    RD0 = CS;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;

    call GD25_Wait_Busy;
    Return_AutoField(1*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      GD25_Read_Data
//  ����:
//      ��ָ����ַ�ͳ��ȶ�������
//  ����:
//      1.Դ��ַ
//      2.Ŀ���ַ
//      3.�������ȣ���λ���ֽڣ�����Ϊ4��������
//  ����ֵ:
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Read_Data;

    //CS�õ�
    RD0 = CS;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;

//Դ��ַW25
    RD2 = M[RSP+2*MMU_BASE];

//д�������0x03��W25
    RD0 = 0x03;
    call SPI_Send_Byte;

//д�������ֽڵĵ�ַ��W25
    RF_RotateR16(RD2);
    RD0 = RD2;
    call SPI_Send_Byte;
    RF_RotateL8(RD2);
    RD0 = RD2;
    call SPI_Send_Byte;
    RF_RotateL8(RD2);
    RD0 = RD2;
    call SPI_Send_Byte;

//Ŀ���ַ Flash
    RA1 = M[RSP+1*MMU_BASE];

//�������ݳ���
    RD2 = M[RSP+0*MMU_BASE];
L_GD25_Read_Data_Loop:
    call WatchDog_Reset;

//��W25�ж�ȡ��һ�����ݵ�Flash
    call SPI_Read_Byte;
    RD3 = RD0;
    RF_RotateL8(RD3);

//�ڶ���byte
    call SPI_Read_Byte;
    RD3 += RD0;
    RF_RotateL8(RD3);

//������byte
    call SPI_Read_Byte;
    RD3 += RD0;
    RF_RotateL8(RD3);

//���ĸ�byte
    call SPI_Read_Byte;
    RD3 += RD0;

//������W25���ݴ洢�����ջ�����
    M[RA1++] = RD3;

    RD2 -= 4;
    if(RQ_nZero) goto L_GD25_Read_Data_Loop;

    //CS�ø�
    RD0 = CS;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;

    Return_AutoField(3*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      GD25_Write_Data_Check
//  ����:
//      ��ָ����ַ�ͳ���д�����ݣ�С��256�ֽڣ��������д����
//  ����:
//      1.Դ��ַ
//      2.Ŀ���ַ
//      3.д�볤�ȣ���λ���ֽڣ�
//      4.���Դ���
//  ����ֵ:
//      1.RD0:0~�ɹ� 1~ʧ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Write_Data_Check;
    push RD4;
    push RA2;

    RD4 = M[RSP+2*MMU_BASE];// ���Դ���
    RA0 = M[RSP+5*MMU_BASE];// Դ��ַ
    RA2 = M[RSP+4*MMU_BASE];// Ŀ���ַ
    RD2 = M[RSP+3*MMU_BASE];// ����

    RD0 = 256;
    RSP -= RD0;
    RA1 = RSP;
L_GD25_Write_Data_Check_Begin:
    // ��д
    send_para(RA0);
    send_para(RA2);
    send_para(RD2);
    call GD25_Write_Data;

    // ��Flash����n�ֽ�
    send_para(RA2);
    send_para(RA1);
    send_para(RD2);
    call GD25_Read_Data;

    // ���������ȷ��
    RD0 = RD2;
    call memcmp;
    if(RD0_nZero) goto L_GD25_Write_Data_Check_Retry;

    //RD0 = 0;
L_GD25_Write_Data_Check_End:
    RD1 = 256;
    RSP += RD1;

    pop RA2;
    pop RD4;
    Return_AutoField(4*MMU_BASE);

L_GD25_Write_Data_Check_Retry:
    RD4 --;
    RD0 = RD4;
    if(RD0_Zero) goto L_GD25_Write_Data_Check_Err;
    goto L_GD25_Write_Data_Check_Begin;

L_GD25_Write_Data_Check_Err:
    RD0 = 1;
    goto L_GD25_Write_Data_Check_End;



//////////////////////////////////////////////////////////////////////////
//  ����:
//      GD25_Write_Data
//  ����:
//      ��ָ����ַ�ͳ���д�����ݣ�С��256�ֽڣ�
//  ����:
//      1.Դ��ַ
//      2.Ŀ���ַ
//      3.д�볤�ȣ���λ���ֽڣ�
//  ����ֵ:
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Write_Data;

    call GD25_Write_En;

    //CS�õ�
    RD0 = CS;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;

//д����0x02��W25
    RD0 = 0x02;
    call SPI_Send_Byte;

 // д�����ֽڵĵ�ַ
    RD2 = M[RSP+1*MMU_BASE];
    RF_RotateR16(RD2);
    RD0 = RD2;
    call SPI_Send_Byte;
    RF_RotateL8(RD2);
    RD0 = RD2;
    call SPI_Send_Byte;
    RF_RotateL8(RD2);
    RD0 = RD2;
    call SPI_Send_Byte;

    //д���ݵ�W25
    RA1 = M[RSP+2*MMU_BASE];  //Դ��ַ
    RD2 = M[RSP+0*MMU_BASE];  //д�볤��  Ϊ4��������
L_GD25_Write_Data_Loop:
    call WatchDog_Reset;
    RD3 = M[RA1++];         //ȡFlash�е����� M[RA1++]= 32bit

//�Ͱ�λ  ��һ���ֽڷ���
    RF_RotateL8(RD3);
    RD0 = RD3;
    call SPI_Send_Byte;

//  �ڶ����ֽڷ���
    RF_RotateL8(RD3);
    RD0 = RD3;
    call SPI_Send_Byte;

//  �������ֽڷ���
    RF_RotateL8(RD3);
    RD0 = RD3;
    call SPI_Send_Byte;

//  ���ĸ��ֽڷ���
    RF_RotateL8(RD3);
    RD0 = RD3;
    call SPI_Send_Byte;

    RD2 -= 4;
    if(RQ_nZero) goto L_GD25_Write_Data_Loop;

     //CS�ø�
    RD0 = CS;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;
    call GD25_Wait_Busy;

    Return_AutoField(3*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      GD25_Wait_Busy
//  ����:
//      �ȴ�æ
//  ����:
//      ��
//  ����ֵ:
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Wait_Busy;
L_GD25_Wait_Busy_Loop:
    call WatchDog_Reset;
    call GD25_Read_Status_Register;
    if(RD0_Bit0 == 1) goto L_GD25_Wait_Busy_Loop;
    if(RD0_Bit1 == 1) goto L_GD25_Wait_Busy_Loop;
    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      GD25_Sector_Erase_Check
//  ����:
//      ҳ����������������������ʱ�Զ����ԣ����Դ����ɲ���ָ��
//  ����:
//      1.RD0:��������ַ
//      2.RD1:���Դ���
//  ����ֵ��
//      1.RD0:0~�ɹ� 1~ʧ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Sector_Erase_Check;
    push RD4;
    push RD5;

    RD4 = RD1;// �Ĵ����Դ���
    RD5 = RD0;// �Ĵ�Flash��ַ

    // ����256�ֽ���ʱ�ռ䣬���ڻ��������Flash����
    RD0 = 256;
    RSP -= RD0;
    RA1 = RSP;

L_GD25_Sector_Erase_Check_Begin:
    // ҳ����
    RD0 = RD5;
    call GD25_Sector_Erase;

    // RA0 ---> Flash����Sector��ַ
    RD0 = RD5;
    RA0 = RD0;

    // ѭ�����4KB���ݣ�ÿ��ѭ�����256�ֽ�
    RD2 = 4*1024/256;
L_GD25_Sector_Erase_Check_Loop:

    // ��Flash����256�ֽ�
    RA1 = RSP;
    send_para(RA0);
    send_para(RA1);
    RD0 = 256;
    send_para(RD0);
    call GD25_Read_Data;

    // ���256�ֽ��Ƿ�Ϊȫ0xFF
    RD3 = 256/4;
    RD0 = 0xFFFFFFFF;
L_GD25_Sector_Erase_Check_Loop2:
    RD0 &= M[RA1++];
    RD3 --;
    if(RQ_nZero) goto L_GD25_Sector_Erase_Check_Loop2;

    RF_Not(RD0);// ȫ0xFFȡ�� = 0x00000000
    if(RD0_nZero) goto L_GD25_Sector_Erase_Check_Retry;

    // ָ����һ��256�ֽڣ��������
    RD0 = 256;
    RA0 += RD0;
    RD2 --;
    if(RQ_nZero) goto L_GD25_Sector_Erase_Check_Loop;// �ж��Ƿ�ȫ��������

    RD0 = 0;// ������������0
L_GD25_Sector_Erase_Check_End:
    // �ͷ�256�ֽ���ʱ�ռ�
    RD1 = 256;
    RSP += RD1;

    pop RD5;
    pop RD4;
    Return_AutoField(0);


L_GD25_Sector_Erase_Check_Retry:
    RD4 --;
    RD0 = RD4;
    if(RD0_Zero) goto L_GD25_Sector_Erase_Check_Err;// �����Դ�������ʱ�������˳�
    goto L_GD25_Sector_Erase_Check_Begin;

L_GD25_Sector_Erase_Check_Err:
    RD0 = 1;// �����쳣����1
    goto L_GD25_Sector_Erase_Check_End;



//////////////////////////////////////////////////////////////////////////
//  ����:
//      GD25_Sector_Erase
//  ����:
//      ��������
//  ����:
//      1.RD0:ҳ���ַ
//  ����ֵ:
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Sector_Erase;
    RD2 = RD0;
    call GD25_Write_En;

    //CS�õ�
    RD0 = CS;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;

    //��������
    RD0 = 0x20;
    call SPI_Send_Byte;

    RD0 = RD2;
    RF_GetMH8(RD0);
    call SPI_Send_Byte;
    RD0 = RD2;
    RF_GetML8(RD0);
    call SPI_Send_Byte;
    RD0 = RD2;
    RF_GetL8(RD0);
    call SPI_Send_Byte;

    //CS�ø�
    RD0 = CS;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;

    call GD25_Wait_Busy;

    Return_AutoField(0*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      GD25_Read_ID
//  ����:
//      ��ID��
//  ����:
//      ��
//  ����ֵ:
//      1.RD0:ID��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Read_ID;
    //CS�õ�
    RD0 = CS;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;

    //��id
    RD0 = 0x9F;
    call SPI_Send_Byte;
    call SPI_Read_Byte;
    RD2 = RD0;
    call SPI_Read_Byte;
    RF_RotateL8(RD2);
    RD2 += RD0;
    call SPI_Read_Byte;
    RF_RotateL8(RD2);
    RD2 += RD0;

    //CS�ø�
    RD0 = CS;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;

    RD0 = RD2;

    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      GD25_Erase_Write_Data_Check
//  ����:
//      ��ָ����ַ�ͳ��ȸ�д���ݣ�С��256�ֽڣ��������д����
//      �����ڲ��в�������
//      Ϊ�Ż�ִ��Ч�ʣ�ֻ�Ը�����ǰ256�ֽڽ��и�д����
//  ����:
//      1.Դ��ַ
//      2.Ŀ���ַ
//      3.д�볤�ȣ���λ���ֽڣ�
//  ����ֵ:
//      1.RD0:0~�ɹ� 1~����ʧ�� 2~д��ʧ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Erase_Write_Data_Check;
    push RA2;

    // �������
    RD2 = M[RSP+1*MMU_BASE];// д�볤�ȣ���λ���ֽڣ�
    RA1 = M[RSP+2*MMU_BASE];// Ŀ���ַ
    RA0 = M[RSP+3*MMU_BASE];// Դ��ַ

    // ���뻺����
    RD0 = 256;
    RSP -= RD0;
    RA2 = RSP;// �������ݵĻ����ַ

    // ����RN_GD25_VAR_ADDRǰ256�ֽ�
    RD0 = RA1;
    RD1 = 0xFFFFF000;
    RD0 &= RD1;
    send_para(RD0);// Դ��ַ
    send_para(RA2);// �������ݵĻ����ַ
    RD0 = 256;
    send_para(RD0);
    call GD25_Read_Data;

    // ����RN_GD25_VAR_ADDR
    RD0 = RA1;
    RD1 = 0xFFFFF000;
    RD0 &= RD1;
    RD1 = RN_GD25_ER_RETRY_TIMES;
    call GD25_Sector_Erase_Check;
    if(RD0_nZero) goto L_GD25_Erase_Write_Data_Check_Err1;

    // ��д����
    send_para(RD2);// д�볤�ȣ���λ���ֽڣ�
    send_para(RA0);// Դ��ַ
    RD0 = RA1;
    RD1 = 0xFF;
    RD0 &= RD1;
    RD0 += RA2;
    send_para(RD0);// Ŀ��ƫַ
    call memcpy;

    // ��дRN_GD25_VAR_ADDR
    send_para(RA2);// Դ��ַ
    RD0 = RA1;
    RD1 = 0xFFFFF000;
    RD0 &= RD1;
    send_para(RD0);// Ŀ���ַ
    RD0 = 256;
    send_para(RD0);// д�볤�ȣ���λ���ֽڣ�
    RD0 = RN_GD25_ER_RETRY_TIMES;
    send_para(RD0);// ���Դ���
    call GD25_Write_Data_Check;
    if(RD0_nZero) goto L_GD25_Erase_Write_Data_Check_Err2;
    RD0 = 0;

L_GD25_Erase_Write_Data_Check_End:
    RD1 = 256;
    RSP += RD1;

    pop RA2;
    Return_AutoField(3*MMU_BASE);

L_GD25_Erase_Write_Data_Check_Err1:
    RD0 = 1;
    goto L_GD25_Erase_Write_Data_Check_End;

L_GD25_Erase_Write_Data_Check_Err2:
    RD0 = 2;
    goto L_GD25_Erase_Write_Data_Check_End;

//////////////////////////////////////////////////////////////////////////
//  ����:
//      FL_Init
//  ����:
//      
//  ����:
//      ��
//  ����ֵ��
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField FL_Init;

    // WP����
    RD0 = WP;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;
    // SRP����
    RD0 = 0x9C;
    send_para(RD0);
    call GD25_Write_Status_Register;
    // WP����
    RD0 = WP;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = 0;
    
    Return_AutoField(0);



END SEGMENT

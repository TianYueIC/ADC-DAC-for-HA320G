#define _BL_SPI_F_

#include <CPU11.def>
#include <SOC_Common.def>
#include <Global.def>
#include <Debug.def>
#include <USI.def>
#include <GPIO.def>
#include <BL_SPI.def>

CODE SEGMENT BL_SPI_F;
//////////////////////////////////////////////////////////////////////////
//  ��������:
//      Load_Data
//  ��������:
//      ��SPI�洢��������ȡ���ݴ洢��Cache
//  �������:
//      ��
//  ��������:
//      ��
//////////////////////////////////////////////////////////////////////////
sub_autofield Load_Data;
    RD0 = CS;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;

    RD0 = 0x03;
    call SPI_Send_Byte;
    RD0 = 0;
    call SPI_Send_Byte;
    RD0 = 0;
    call SPI_Send_Byte;
    RD0 = 0;
    call SPI_Send_Byte;



    // Load Cache��
    RD0 = RN_Cache_StartAddr;
    RA1 = RD0;
    RD3 = RN_Cache_SIZE/2;

    Sel_Cache4Data;
L_Load_Data_Loop:
    call SPI_Read_Byte;
    RD2 = RD0;
    RF_RotateL8(RD2);
    call SPI_Read_Byte;
    RD2 += RD0;
    M[RA1] = RD2;
    RA1 += 2;
    RD3 --;
    if(RQ_nZero) goto L_Load_Data_Loop;
    Sel_Cache4Inst;


    return_autofield(0);




//////////////////////////////////////////////////////////////////////////
//  ��������:
//      SPI_Init
//  ��������:
//      SPI��ʼ��
//  �������:
//      ��
//  ��������:
//      ��
//////////////////////////////////////////////////////////////////////////
sub_autofield SPI_Init;
    // ��������˿�
    RD0 = SCL|MOSI|CS|WP;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;
    RD0 = GPIO_OUT;
    GPIO_Set1 = RD0;

    // ��������˿�
    RD0 = MISO;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;
    RD0 = GPIO_IN|GPIO_PULL;
    GPIO_Set1 = RD0;

    call dalay2ms;
    
    return_autofield(0);


//////////////////////////////////////////////////////////////////////////
//  ����:
//      SPI_Read_Byte
//  ����:
//      SPI����1�ֽ�
//  ����:
//      ��
//  ����ֵ:
//      1.RD0:���յ���1�ֽ�����
//////////////////////////////////////////////////////////////////////////
Sub_AutoField SPI_Read_Byte;
    RD3 = 8;
    RD2 = 0;

L_SPI_Read_Byte_Loop:
    // SCL�õ�_Delay_�ø�
    RD0 = SCL;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;
    nop;nop;nop;nop;nop;nop;
    RD0 = SCL;
    GPIO_Data1 = RD0;

    // ��ȡ���ֽ��յ���1bit����
    RF_RotateL1(RD2);
    RD0 = MISO;
    GPIO_WEn1 = RD0;
    RD0 = GPIO_Data1;
    if(RD0_Bit1==0) goto L_SPI_Read_Byte_1;
    RD2 ++;
L_SPI_Read_Byte_1:
    RD3 --;
    if(RQ_nZero) goto L_SPI_Read_Byte_Loop;
    RD0 = RD2;

    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      SPI_Send_Byte
//  ����:
//      SPI����1�ֽڣ�MOSI��GP1_0�޸���GP1_3
//
//  ����:
//      1.RD0:Ҫ���͵�1�ֽ�
//  ����ֵ:
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField SPI_Send_Byte;
    RD2 = RD0;
    RF_RotateR8(RD2);
/*  //HA320E��HA320F��MOSI��GP1_0�޸���GP1_3ʱ��Ҫ�����������
//	RF_RotateL2(RD2);  
//	RF_RotateL1(RD2);
*/
    RD3 = 8;
L_SPI_Send_Byte_Loop:

    // SCL�õ�_Delay_�ø�
    RD0 = SCL;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;

    // ���������MOSI
    RF_RotateL1(RD2);
    RD0 = MOSI;
    GPIO_WEn1 = RD0;
    RD0 = RD2;
    GPIO_Data1 = RD0;

    RD0 = SCL;
    GPIO_WEn1 = RD0;
    RD0 = SCL;
    GPIO_Data1 = RD0;

    RD3 --;
    if(RQ_nZero) goto L_SPI_Send_Byte_Loop;

    Return_AutoField(0);
    
    
/*
//////////////////////////////////////////////////////////////////////////
//  ����:
//      SPI_Read_Byte
//  ����:
//      SPI����1�ֽ�
//  ����:
//      ��
//  ����ֵ:
//      1.RD0:���յ���1�ֽ�����
//////////////////////////////////////////////////////////////////////////
Sub_AutoField SPI_Read_Byte;
	ENABLE_GPSFT;  nop;
	GPSFT_CLKLOW;  nop;
	GPSFT_CLKHIGH; nop;
	GPSFT_CLKLOW;  nop;
	GPSFT_CLKHIGH; nop;
	GPSFT_CLKLOW;  nop;
	GPSFT_CLKHIGH; nop;
	GPSFT_CLKLOW;  nop;
	GPSFT_CLKHIGH; nop;
	GPSFT_CLKLOW;  nop;
	GPSFT_CLKHIGH; nop;
	GPSFT_CLKLOW;  nop;
	GPSFT_CLKHIGH; nop;
	GPSFT_CLKLOW;  nop;
	GPSFT_CLKHIGH; nop;
	GPSFT_CLKLOW;  nop;
	GPSFT_CLKHIGH; nop;
	RD0 = GPSFT_DATA;
	RF_GetL8(RD0);
	DISABLE_GPSFT;
    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      SPI_Send_Byte
//  ����:
//      SPI����1�ֽڣ�MOSI��GP1_0�޸���GP1_3
//
//  ����:
//      1.RD0:Ҫ���͵�1�ֽ�
//  ����ֵ:
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField SPI_Send_Byte;
	ENABLE_GPSFT;
	GPSFT_DATA = RD0;
	GPSFT_SETDATA; nop;
	GPSFT_CLKLOW;  nop;
	GPSFT_CLKHIGH; nop;
	GPSFT_CLKLOW;  nop;
	GPSFT_CLKHIGH; nop;
	GPSFT_CLKLOW;  nop;
	GPSFT_CLKHIGH; nop;
	GPSFT_CLKLOW;  nop;
	GPSFT_CLKHIGH; nop;
	GPSFT_CLKLOW;  nop;
	GPSFT_CLKHIGH; nop;
	GPSFT_CLKLOW;  nop;
	GPSFT_CLKHIGH; nop;
	GPSFT_CLKLOW;  nop;
	GPSFT_CLKHIGH; nop;
	GPSFT_CLKLOW;  nop;
	GPSFT_CLKHIGH; nop;
	DISABLE_GPSFT;
    Return_AutoField(0);
*/




sub_autofield dalay2ms;
    RD2 = 60240/3;//10ms @6MIPS Speed4
    //RD2 = 12048/3;//2ms @6MIPS Speed4

L_dalay50ms_Loop:
    RD2 --;
    if(RQ_nZero) goto L_dalay50ms_Loop;
    return_autofield(0);

END SEGMENT

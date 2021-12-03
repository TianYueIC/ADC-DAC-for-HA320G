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
//  函数名称:
//      Load_Data
//  函数功能:
//      从SPI存储器连续读取数据存储至Cache
//  函数入口:
//      无
//  函数出口:
//      无
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



    // Load Cache段
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
//  函数名称:
//      SPI_Init
//  函数功能:
//      SPI初始化
//  函数入口:
//      无
//  函数出口:
//      无
//////////////////////////////////////////////////////////////////////////
sub_autofield SPI_Init;
    // 配置输出端口
    RD0 = SCL|MOSI|CS|WP;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;
    RD0 = GPIO_OUT;
    GPIO_Set1 = RD0;

    // 配置输入端口
    RD0 = MISO;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;
    RD0 = GPIO_IN|GPIO_PULL;
    GPIO_Set1 = RD0;

    call dalay2ms;
    
    return_autofield(0);


//////////////////////////////////////////////////////////////////////////
//  名称:
//      SPI_Read_Byte
//  功能:
//      SPI接收1字节
//  参数:
//      无
//  返回值:
//      1.RD0:接收到的1字节数据
//////////////////////////////////////////////////////////////////////////
Sub_AutoField SPI_Read_Byte;
    RD3 = 8;
    RD2 = 0;

L_SPI_Read_Byte_Loop:
    // SCL置低_Delay_置高
    RD0 = SCL;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;
    nop;nop;nop;nop;nop;nop;
    RD0 = SCL;
    GPIO_Data1 = RD0;

    // 读取本轮接收到的1bit数据
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
//  名称:
//      SPI_Send_Byte
//  功能:
//      SPI发送1字节，MOSI由GP1_0修改至GP1_3
//
//  参数:
//      1.RD0:要发送的1字节
//  返回值:
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField SPI_Send_Byte;
    RD2 = RD0;
    RF_RotateR8(RD2);
/*  //HA320E、HA320F中MOSI由GP1_0修改至GP1_3时需要添加以下两条
//	RF_RotateL2(RD2);  
//	RF_RotateL1(RD2);
*/
    RD3 = 8;
L_SPI_Send_Byte_Loop:

    // SCL置低_Delay_置高
    RD0 = SCL;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;

    // 数据输出至MOSI
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
//  名称:
//      SPI_Read_Byte
//  功能:
//      SPI接收1字节
//  参数:
//      无
//  返回值:
//      1.RD0:接收到的1字节数据
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
//  名称:
//      SPI_Send_Byte
//  功能:
//      SPI发送1字节，MOSI由GP1_0修改至GP1_3
//
//  参数:
//      1.RD0:要发送的1字节
//  返回值:
//      无
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

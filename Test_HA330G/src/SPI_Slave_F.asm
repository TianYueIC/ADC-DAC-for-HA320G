#define _SPI_SLAVE_F_

#include <cpu11.def>
#include <USI.def>

CODE SEGMENT SPI_SLAVE_F;
//////////////////////////////////////////////////////////////////////////
//  名称:
//      SPI_Slave_Init
//  功能:
//      将USI配置为SPI从机
//  参数:
//      1.RD0:端口号COM0/COM1
//  返回值：
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField  SPI_Slave_Init;
    RD0 = M[RSP+0*MMU_BASE];
    //RF_Exp(RD0);
    USI_Num = RD0;

    USI_Disable;
    USI_SelPort = Counter2_Port;
    RD0 = 0x80000000;
    USI_Data = RD0;
    USI_SelPort = Config_Port;
    RD0 = 0b00000101000100000000;
    USI_Data = RD0;
    USI_SelPort = Data_Port;
    USI_Enable;

SPI_Slave_Init_End:
    Return_AutoField(1*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      SPI_Slave_Gets
//  功能:
//      连续接收指定长度的数据
//  参数:
//      1.端口号COM0/COM1
//      2.长度(单位：字节，满足4的整倍数)
//      3.数据首地址(out)
//  返回值：
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField SPI_Slave_Gets;
    RD0 = M[RSP+2*MMU_BASE];
    USI_Num = RD0;
    RD2 = M[RSP+1*MMU_BASE];
    RA0 = M[RSP+0*MMU_BASE];
    USI_EnableRx;
    USI_Data = RD0;                     //重置Cnt2

_SPI_Slave_Gets_Loop:
	nop;nop;
    if(USI_Flag==0) goto _SPI_Slave_Gets_Loop;
    RD0 = USI_Data;
    RF_Reverse(RD0);
    M[RA0++] = RD0;
    RD2 -= 4;
    if(RQ_nZero) goto _SPI_Slave_Gets_Loop;

    USI_DisTxRx;
    Return_AutoField(3*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      SPI_Slave_Puts
//  功能:
//      连续发送指定长度的数据
//  参数:
//      1.端口号COM0/COM1
//      2.长度(单位：字节，满足4的整倍数)
//      3.数据首地址
//  返回值：
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField SPI_Slave_Puts;
    RD0 = M[RSP+2*MMU_BASE];
    USI_Num = RD0;
    RD2 = M[RSP+1*MMU_BASE];
    RA0 = M[RSP+0*MMU_BASE];

    USI_EnableTx;
    USI_SelPort = Data_Port; // WR

    RD0 = M[RA0++];
    RF_Reverse(RD0);
    USI_Data = RD0;

    RD2 -= 4;
    if(RQ_Zero) goto _SPI_Slave_Puts_End;

    RD0 = M[RA0++];
	RF_Reverse(RD0);

    USI_Data = RD0;
    RD2 -= 4;
    if(RQ_Zero) goto _SPI_Slave_Puts_End_L0;

_SPI_Slave_Puts_Loop:
    if(USI_Flag==0) goto _SPI_Slave_Puts_Loop;
    RD0 = M[RA0++];
    RF_Reverse(RD0);
    USI_Data = RD0;
    RD2 -= 4;
    if(RQ_nZero) goto _SPI_Slave_Puts_Loop;

_SPI_Slave_Puts_End_L0:
    if(USI_Flag==0) goto _SPI_Slave_Puts_End_L0;

    RD0 = USI_Data;   //清Flag，不能用写信号，否则不能停止bps计数器。
_SPI_Slave_Puts_End:
    if(USI_Flag==0) goto _SPI_Slave_Puts_End;
    USI_DisTxRx;

    Return_AutoField(3*MMU_BASE);

END SEGMENT
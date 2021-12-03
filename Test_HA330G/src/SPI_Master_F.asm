#define _SPI_MASTER_F_

#include <CPU11.def>
#include <SOC_Common.def>
#include <USI.def>
#include <gpio.def>

CODE SEGMENT SPI_MASTER_F;
//////////////////////////////////////////////////////////////////////////
//  名称:
//      SPI_Master_Init
//  功能:
//      将USI配置为SPI主机
//  参数:
//      1.RD0:端口号COM0/COM1
//      2.RD1:时钟分频配置值 = F(主频/SCK频率/2)
//  返回值：
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField SPI_Master_Init;
    Set_IntASM_Dis;
    USI_Num = RD0;
    USI_Disable;
    USI_SelPort = Config_Port;
    RD0 = 0b100010100000010; // ？？？？？？？？？？？？？？
    USI_Data = RD0;
    USI_Enable;
    USI_SelPort = Counter1_Port;
    
RF_Not(RD1);    
    
    USI_Data = RD1; // 设置时钟计数值
    USI_SelPort = Data_Port;
    USI_SelPort = Counter2_Port;
    RD0 = 0x80000000;
    USI_Data = RD0; // 将计数器设置为32位模式
    USI_SelPort = Data_Port;
    Set_IntASM_En;
    Return_AutoField(0*MMU_BASE);
    
    
    
//////////////////////////////////////////////////////////////////////////
//  名称:
//      SPI_Master_Puts
//  功能:
//      连续发送指定长度的数据，为输出关键数据，高16bit先行发送
//  参数:
//      1.RD0:端口号COM0/COM1
//      2.RD1:长度(单位：字节，满足4的整倍数)
//      3.RA0:数据首地址
//  返回值：
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField SPI_Master_Puts;
    Set_IntASM_Dis;
    USI_Num = RD0;
    USI_EnableTx;
    RF_ShiftR2(RD1);
    RD2 = RD1;                          // DW个数

//// cs 拉低
//RD0 = GP0_4;
//GPIO_WEn0 = RD0;
//RD0 = 0;
//GPIO_Data0 = RD0;

    RD0 = M[RA0++];
    RF_Reverse(RD0);
    USI_Data = RD0;
    RD2 -= 1;                           // 写X
    if(RQ_Zero) goto L_SPI_Master_Puts_End;

L_SPI_Master_Puts_Loop:
    RD0 = M[RA0++];
    RF_Reverse(RD0);
    USI_Data = RD0;                     // 写X+1

L_SPI_Master_Puts_Loop_Wait:            // 听X
    if(USI_Flag==0) goto L_SPI_Master_Puts_Loop_Wait;
    RD2 -= 1;
    if(RQ_nZero) goto L_SPI_Master_Puts_Loop;
    RD0 = USI_Data;                     // 清除倒数第二包的标志

L_SPI_Master_Puts_End:                  // 听X+1
    if(USI_Flag==0) goto L_SPI_Master_Puts_End;


//// cs 拉高
//RD0 = GP0_4;
//GPIO_WEn0 = RD0;
//RD0 = GP0_4;
//GPIO_Data0 = RD0;

    USI_DisTxRx;
    Set_IntASM_En;
    Return_AutoField(0*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      SPI_Master_Puts_Prot
//  功能:
//      连续发送指定长度的数据，为输出数字音频，低16bit先行发送
//  参数:
//      1.RD0:端口号COM0/COM1
//      2.RD1:长度(单位：字节，满足4的整倍数)
//      3.RA0:数据首地址
//  返回值：
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField SPI_Master_Puts_Prot;
    Set_IntASM_Dis;
    USI_Num = RD0;
    USI_EnableTx;
    RF_ShiftR2(RD1);
    RD2 = RD1;                          // DW个数

//// cs 拉低
//RD0 = GP0_4;
//GPIO_WEn0 = RD0;
//RD0 = 0;
//GPIO_Data0 = RD0;

    RD0 = M[RA0++];
    RF_Reverse(RD0);
    RF_RotateL16(RD0);
    USI_Data = RD0;
    RD2 -= 1;                           // 写X
    if(RQ_Zero) goto L_SPI_Master_Puts_Prot_End;

L_SPI_Master_Puts_Prot_Loop:
    RD0 = M[RA0++];
    RF_Reverse(RD0);
    RF_RotateL16(RD0);
    USI_Data = RD0;                     // 写X+1

L_SPI_Master_Puts_Prot_Loop_Wait:            // 听X
    if(USI_Flag==0) goto L_SPI_Master_Puts_Prot_Loop_Wait;
    RD2 -= 1;
    if(RQ_nZero) goto L_SPI_Master_Puts_Prot_Loop;
    RD0 = USI_Data;                     // 清除倒数第二包的标志

L_SPI_Master_Puts_Prot_End:                  // 听X+1
    if(USI_Flag==0) goto L_SPI_Master_Puts_Prot_End;


//// cs 拉高
//RD0 = GP0_4;
//GPIO_WEn0 = RD0;
//RD0 = GP0_4;
//GPIO_Data0 = RD0;

    USI_DisTxRx;
    Set_IntASM_En;
    Return_AutoField(0*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      SPI_Master_Gets_Prot
//  功能:
//      连续接收指定长度的数据，为输入数字音频，低16bit先行接收
//  参数:
//      1.RD0:端口号COM0/COM1
//      2.RD1:长度(单位：字节，满足4的整倍数)
//      3.RA0:数据首地址(out)
//  返回值：
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField SPI_Master_Gets_Prot;
    Set_IntASM_Dis;
    USI_Num = RD0;
    USI_EnableRx;
    RF_ShiftR2(RD1);
    RD2 = RD1;

//// cs 拉低
//RD0 = GP0_4;
//GPIO_WEn0 = RD0;
//RD0 = 0;
//GPIO_Data0 = RD0;

    USI_Data = RD0;
    RD2 -= 1;                           // 空写，启动
    if(RQ_Zero) goto L_SPI_Master_Gets_Prot_End;

L_SPI_Master_Gets_Prot_Loop:
    USI_Data = RD0;                     // 写X+1
L_SPI_Master_Gets_Prot_Wait:                 // 听
    if(USI_Flag==0) goto  L_SPI_Master_Gets_Prot_Wait;
    RD0 = USI_Data;
    RF_Reverse(RD0);
    RF_RotateL16(RD0);
    M[RA0++] = RD0;
    RD2 -= 1;
    if(RQ_nZero) goto L_SPI_Master_Gets_Prot_Loop;

L_SPI_Master_Gets_Prot_End:
    if(USI_Flag==0) goto L_SPI_Master_Gets_Prot_End;
    RD0 = USI_Data;
    RF_Reverse(RD0);
    RF_RotateL16(RD0);
    M[RA0++] = RD0;

//// cs 拉高
//RD0 = GP0_4;
//GPIO_WEn0 = RD0;
//RD0 = GP0_4;
//GPIO_Data0 = RD0;

    USI_DisTxRx;
    Set_IntASM_En;
    Return_AutoField(0*MMU_BASE);

END SEGMENT
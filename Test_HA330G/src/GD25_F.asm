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
//  名称:
//      GD25_Release_DP
//  功能:
//      退出深度休眠模式
//  参数:
//      无
//  返回值:
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Release_DP;

     //CS置低
    RD0 = CS;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;

    RD0 = 0xAB;
    call SPI_Send_Byte;

    //CS置高
    RD0 = CS;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;

    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      GD25_DP
//  功能:
//      进入深度休眠模式
//  参数:
//      无
//  返回值:
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_DP;

     //CS置低
    RD0 = CS;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;

    RD0 = 0xB9;
    call SPI_Send_Byte;

    //CS置高
    RD0 = CS;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;

    Return_AutoField(0);

//////////////////////////////////////////////////////////////////////////
//  名称:
//      GD25_Write_En
//  功能:
//      写使能
//  参数:
//      无
//  返回值:
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Write_En;

     //CS置低
    RD0 = CS;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;

    RD0 = 0x06;
    call SPI_Send_Byte;

    //CS置高
    RD0 = CS;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;

    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      GD25_Write_Dis
//  功能:
//      写禁能
//  参数:
//      无
//  返回值:
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Write_Dis;

    //CS置低
    RD0 = CS;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;

    RD0 = 0x04;
    call SPI_Send_Byte;

    //CS置高
    RD0 = CS;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;

    Return_AutoField(0);


//////////////////////////////////////////////////////////////////////////
//  名称:
//      GD25_Read_Status_Register
//  功能:
//      读状态寄存器
//  参数:
//      无
//  返回值:
//      1.RD0:寄存器个状态位
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Read_Status_Register;

     //CS置低
    RD0 = CS;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;

    RD0 = 0x05;
    call SPI_Send_Byte;
    call SPI_Read_Byte;

    //CS置高
    RD1 = CS;
    GPIO_WEn1 = RD1;
    GPIO_Data1 = RD1;

    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      GD25_Write_Status_Register
//  功能:
//      写状态寄存器
//  参数:
//      1.状态寄存器值
//  返回值:
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Write_Status_Register;
    call GD25_Write_En;
    //CS置低
    RD0 = CS;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;

    RD0 = 01;
    call SPI_Send_Byte;
    RD0 = M[RSP+0*MMU_BASE];
    call SPI_Send_Byte;

    //CS置高
    RD0 = CS;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;

    call GD25_Wait_Busy;
    Return_AutoField(1*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      GD25_Read_Data
//  功能:
//      按指定地址和长度读出数据
//  参数:
//      1.源地址
//      2.目标地址
//      3.读出长度（单位：字节）必须为4的整倍数
//  返回值:
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Read_Data;

    //CS置低
    RD0 = CS;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;

//源地址W25
    RD2 = M[RSP+2*MMU_BASE];

//写入读命令0x03到W25
    RD0 = 0x03;
    call SPI_Send_Byte;

//写入三个字节的地址到W25
    RF_RotateR16(RD2);
    RD0 = RD2;
    call SPI_Send_Byte;
    RF_RotateL8(RD2);
    RD0 = RD2;
    call SPI_Send_Byte;
    RF_RotateL8(RD2);
    RD0 = RD2;
    call SPI_Send_Byte;

//目标地址 Flash
    RA1 = M[RSP+1*MMU_BASE];

//读出数据长度
    RD2 = M[RSP+0*MMU_BASE];
L_GD25_Read_Data_Loop:
    call WatchDog_Reset;

//从W25中读取第一个数据到Flash
    call SPI_Read_Byte;
    RD3 = RD0;
    RF_RotateL8(RD3);

//第二个byte
    call SPI_Read_Byte;
    RD3 += RD0;
    RF_RotateL8(RD3);

//第三个byte
    call SPI_Read_Byte;
    RD3 += RD0;
    RF_RotateL8(RD3);

//第四个byte
    call SPI_Read_Byte;
    RD3 += RD0;

//读出的W25数据存储到接收缓冲区
    M[RA1++] = RD3;

    RD2 -= 4;
    if(RQ_nZero) goto L_GD25_Read_Data_Loop;

    //CS置高
    RD0 = CS;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;

    Return_AutoField(3*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      GD25_Write_Data_Check
//  功能:
//      按指定地址和长度写入数据（小于256字节），并检查写入结果
//  参数:
//      1.源地址
//      2.目标地址
//      3.写入长度（单位：字节）
//      4.重试次数
//  返回值:
//      1.RD0:0~成功 1~失败
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Write_Data_Check;
    push RD4;
    push RA2;

    RD4 = M[RSP+2*MMU_BASE];// 重试次数
    RA0 = M[RSP+5*MMU_BASE];// 源地址
    RA2 = M[RSP+4*MMU_BASE];// 目标地址
    RD2 = M[RSP+3*MMU_BASE];// 长度

    RD0 = 256;
    RSP -= RD0;
    RA1 = RSP;
L_GD25_Write_Data_Check_Begin:
    // 烧写
    send_para(RA0);
    send_para(RA2);
    send_para(RD2);
    call GD25_Write_Data;

    // 从Flash读出n字节
    send_para(RA2);
    send_para(RA1);
    send_para(RD2);
    call GD25_Read_Data;

    // 检查数据正确性
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
//  名称:
//      GD25_Write_Data
//  功能:
//      按指定地址和长度写入数据（小于256字节）
//  参数:
//      1.源地址
//      2.目标地址
//      3.写入长度（单位：字节）
//  返回值:
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Write_Data;

    call GD25_Write_En;

    //CS置低
    RD0 = CS;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;

//写命令0x02到W25
    RD0 = 0x02;
    call SPI_Send_Byte;

 // 写三个字节的地址
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

    //写数据到W25
    RA1 = M[RSP+2*MMU_BASE];  //源地址
    RD2 = M[RSP+0*MMU_BASE];  //写入长度  为4的整数倍
L_GD25_Write_Data_Loop:
    call WatchDog_Reset;
    RD3 = M[RA1++];         //取Flash中的数据 M[RA1++]= 32bit

//低八位  第一个字节发送
    RF_RotateL8(RD3);
    RD0 = RD3;
    call SPI_Send_Byte;

//  第二个字节发送
    RF_RotateL8(RD3);
    RD0 = RD3;
    call SPI_Send_Byte;

//  第三个字节发送
    RF_RotateL8(RD3);
    RD0 = RD3;
    call SPI_Send_Byte;

//  第四个字节发送
    RF_RotateL8(RD3);
    RD0 = RD3;
    call SPI_Send_Byte;

    RD2 -= 4;
    if(RQ_nZero) goto L_GD25_Write_Data_Loop;

     //CS置高
    RD0 = CS;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;
    call GD25_Wait_Busy;

    Return_AutoField(3*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      GD25_Wait_Busy
//  功能:
//      等待忙
//  参数:
//      无
//  返回值:
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Wait_Busy;
L_GD25_Wait_Busy_Loop:
    call WatchDog_Reset;
    call GD25_Read_Status_Register;
    if(RD0_Bit0 == 1) goto L_GD25_Wait_Busy_Loop;
    if(RD0_Bit1 == 1) goto L_GD25_Wait_Busy_Loop;
    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      GD25_Sector_Erase_Check
//  功能:
//      页擦除并检查结果，当结果有误时自动重试，重试次数由参数指定
//  参数:
//      1.RD0:待擦除地址
//      2.RD1:重试次数
//  返回值：
//      1.RD0:0~成功 1~失败
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Sector_Erase_Check;
    push RD4;
    push RD5;

    RD4 = RD1;// 寄存重试次数
    RD5 = RD0;// 寄存Flash地址

    // 开辟256字节临时空间，用于缓存读出的Flash数据
    RD0 = 256;
    RSP -= RD0;
    RA1 = RSP;

L_GD25_Sector_Erase_Check_Begin:
    // 页擦除
    RD0 = RD5;
    call GD25_Sector_Erase;

    // RA0 ---> Flash待擦Sector地址
    RD0 = RD5;
    RA0 = RD0;

    // 循环检查4KB数据，每次循环检查256字节
    RD2 = 4*1024/256;
L_GD25_Sector_Erase_Check_Loop:

    // 从Flash读出256字节
    RA1 = RSP;
    send_para(RA0);
    send_para(RA1);
    RD0 = 256;
    send_para(RD0);
    call GD25_Read_Data;

    // 检查256字节是否为全0xFF
    RD3 = 256/4;
    RD0 = 0xFFFFFFFF;
L_GD25_Sector_Erase_Check_Loop2:
    RD0 &= M[RA1++];
    RD3 --;
    if(RQ_nZero) goto L_GD25_Sector_Erase_Check_Loop2;

    RF_Not(RD0);// 全0xFF取反 = 0x00000000
    if(RD0_nZero) goto L_GD25_Sector_Erase_Check_Retry;

    // 指向下一个256字节，继续检查
    RD0 = 256;
    RA0 += RD0;
    RD2 --;
    if(RQ_nZero) goto L_GD25_Sector_Erase_Check_Loop;// 判断是否全部检查完毕

    RD0 = 0;// 功能正常返回0
L_GD25_Sector_Erase_Check_End:
    // 释放256字节临时空间
    RD1 = 256;
    RSP += RD1;

    pop RD5;
    pop RD4;
    Return_AutoField(0);


L_GD25_Sector_Erase_Check_Retry:
    RD4 --;
    RD0 = RD4;
    if(RD0_Zero) goto L_GD25_Sector_Erase_Check_Err;// 当重试次数过多时，报错退出
    goto L_GD25_Sector_Erase_Check_Begin;

L_GD25_Sector_Erase_Check_Err:
    RD0 = 1;// 功能异常返回1
    goto L_GD25_Sector_Erase_Check_End;



//////////////////////////////////////////////////////////////////////////
//  名称:
//      GD25_Sector_Erase
//  功能:
//      扇区擦除
//  参数:
//      1.RD0:页面地址
//  返回值:
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Sector_Erase;
    RD2 = RD0;
    call GD25_Write_En;

    //CS置低
    RD0 = CS;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;

    //擦除扇区
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

    //CS置高
    RD0 = CS;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;

    call GD25_Wait_Busy;

    Return_AutoField(0*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      GD25_Read_ID
//  功能:
//      读ID号
//  参数:
//      无
//  返回值:
//      1.RD0:ID号
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Read_ID;
    //CS置低
    RD0 = CS;
    GPIO_WEn1 = RD0;
    RD0 = 0;
    GPIO_Data1 = RD0;

    //读id
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

    //CS置高
    RD0 = CS;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;

    RD0 = RD2;

    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      GD25_Erase_Write_Data_Check
//  功能:
//      按指定地址和长度改写数据（小于256字节），并检查写入结果
//      函数内部有擦除操作
//      为优化执行效率，只对该扇区前256字节进行改写操作
//  参数:
//      1.源地址
//      2.目标地址
//      3.写入长度（单位：字节）
//  返回值:
//      1.RD0:0~成功 1~擦除失败 2~写入失败
//////////////////////////////////////////////////////////////////////////
Sub_AutoField GD25_Erase_Write_Data_Check;
    push RA2;

    // 函数入参
    RD2 = M[RSP+1*MMU_BASE];// 写入长度（单位：字节）
    RA1 = M[RSP+2*MMU_BASE];// 目标地址
    RA0 = M[RSP+3*MMU_BASE];// 源地址

    // 申请缓冲区
    RD0 = 256;
    RSP -= RD0;
    RA2 = RSP;// 读出数据的缓存地址

    // 读出RN_GD25_VAR_ADDR前256字节
    RD0 = RA1;
    RD1 = 0xFFFFF000;
    RD0 &= RD1;
    send_para(RD0);// 源地址
    send_para(RA2);// 读出数据的缓存地址
    RD0 = 256;
    send_para(RD0);
    call GD25_Read_Data;

    // 擦除RN_GD25_VAR_ADDR
    RD0 = RA1;
    RD1 = 0xFFFFF000;
    RD0 &= RD1;
    RD1 = RN_GD25_ER_RETRY_TIMES;
    call GD25_Sector_Erase_Check;
    if(RD0_nZero) goto L_GD25_Erase_Write_Data_Check_Err1;

    // 改写变量
    send_para(RD2);// 写入长度（单位：字节）
    send_para(RA0);// 源地址
    RD0 = RA1;
    RD1 = 0xFF;
    RD0 &= RD1;
    RD0 += RA2;
    send_para(RD0);// 目标偏址
    call memcpy;

    // 回写RN_GD25_VAR_ADDR
    send_para(RA2);// 源地址
    RD0 = RA1;
    RD1 = 0xFFFFF000;
    RD0 &= RD1;
    send_para(RD0);// 目标地址
    RD0 = 256;
    send_para(RD0);// 写入长度（单位：字节）
    RD0 = RN_GD25_ER_RETRY_TIMES;
    send_para(RD0);// 重试次数
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
//  名称:
//      FL_Init
//  功能:
//      
//  参数:
//      无
//  返回值：
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField FL_Init;

    // WP解锁
    RD0 = WP;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;
    // SRP锁定
    RD0 = 0x9C;
    send_para(RD0);
    call GD25_Write_Status_Register;
    // WP锁定
    RD0 = WP;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = 0;
    
    Return_AutoField(0);



END SEGMENT

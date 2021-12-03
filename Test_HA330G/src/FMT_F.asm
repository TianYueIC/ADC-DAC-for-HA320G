#define _FMT_F_

#include <CPU11.def>
#include <resource_allocation.def>
#include <RN_DSP_Cfg.def>
#include <DMA_ParaCfg.def>
#include <DMA_ALU.def>
#include <FMT.def>
#include <Global.def>

CODE SEGMENT FMT_F;
////////////////////////////////////////////////////////
//  名称:
//      Get_Real
//  功能:
//      提取实部
//  参数:
//      1.RA0:输入序列指针，格式[Re | Im]
//      2.RA1:输出序列指针，格式[Re(n+1) | Re(n)](out)
//      3.RD0:TimerNum值 = (输出序列Dword长度*3)+3
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField Get_Real;
    RD2 = RD0;
    //以下为双目操作示例程序
    //--------------------------------------------------
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置参数
    RD0 = 0x4141;//取虚部0x8282;//取实部0x4141
    M[RA6+11*MMU_BASE] = RD0;     //ALU1写指令端口
    //配置相关的4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    RD0 = RA0;//源地址0
    send_para(RD0);
    RD0 = RA1;//目标地址
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_GetH16L16;//单目运算配置专用函数

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_Format;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      Get_Imag
//  功能:
//      提取虚部
//  参数:
//      1.RA0:输入序列指针，格式[Re | Im]
//      2.RA1:输出序列指针，格式[Im(n+1) | Im(n)](out)
//      3.RD0:TimerNum值 = (输出序列Dword长度*3)+3
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField Get_Imag;
    RD2 = RD0;
    //以下为双目操作示例程序
    //--------------------------------------------------
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置参数
    RD0 = 0x8282;//取虚部0x8282;//取实部0x4141
    M[RA6+11*MMU_BASE] = RD0;     //ALU1写指令端口
    //配置相关的4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    RD0 = RA0;//源地址0
    send_para(RD0);
    RD0 = RA1;//目标地址
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_GetH16L16;//单目运算配置专用函数

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_Format;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    Return_AutoField(0);



//////////////////////////////////////////////////////////
////  名称:
////      Real_To_Complex
////  功能:
////      紧凑16bit格式转换为复数格式，虚部置零
////  参数:
////      1.RA0:输入序列指针，格式[Re(n+1) | Re(n)]
////      2.RA1:输出序列指针，格式[Re | 0](out)
////  返回值:
////      无
//////////////////////////////////////////////////////////
//Sub_AutoField Real_To_Complex;
//    RA0 = RD0;
//    RA1 = RD1;
//
//    //以下为实数序列转换成复数操作示例程序
//    //存储地址扩展为两倍，虚部置0
//    ////偶数地址
//    //--------------------------------------------------
//    MemSetPath_Enable;  //设置Group通道使能
//    M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上
//
//    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
//    //配置参数
//    RD0 = 0x2020;  //偶数序号0x2020  //奇数序号0x1010
//    M[RA6+11*MMU_BASE] = RD0;     //ALU1写指令端口
//    //配置相关的4KRAM
//    RD0 = DMA_PATH1;
//    M[RA0] = RD0;
//    M[RA1] = RD0;
//    MemSet_Disable;     //配置结束
//
//    //配置DMA_Ctrl参数，包括地址.长度
//    RD0 = RA0;//源地址0
//    send_para(RD0);
//    RD0 = RA1;//目标地址
//    send_para(RD0);
//    RD0 = FL_M2_A2;
//    send_para(RD0);
//    call _DMA_ParaCfg_Real2Complex;
//
//    //选择DMA_Ctrl通道，并启动运算
//    RD0 = DMA_PATH1;
//    ParaMem_Num = RD0;
//    RD0 = DMA_nParaNum_Format;
//    ParaMem_Addr = RD0;
//    Wait_While(Flag_DMAWork==1);
//    nop; nop;
//    Wait_While(Flag_DMAWork==0);
//    //---------------------------------------------------
//
//    //奇数地址
//    //--------------------------------------------------
//    MemSetPath_Enable;  //设置Group通道使能
//    M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上
//
//    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
//    //配置参数
//    RD0 = 0x1010;  //偶数序号0x2020  //奇数序号0x1010
//    M[RA6+11*MMU_BASE] = RD0;     //ALU1写指令端口
//    //配置相关的4KRAM
//    RD0 = DMA_PATH1;
//    M[RA0] = RD0;
//    M[RA1] = RD0;
//    RD1 = 1024;
//    M[RA1+RD1] = RD0;
//    MemSet_Disable;     //配置结束
//
//    //配置DMA_Ctrl参数，包括地址.长度
//    RD0 = RA0;//源地址0
//    send_para(RD0);
//    RD0 = RA1;//目标地址
//    RD0 += MMU_BASE;//奇数地址从1开始
//    send_para(RD0);
//    RD0 = FL_M2_A2;
//    send_para(RD0);
//    call _DMA_ParaCfg_Real2Complex;
//
//    //选择DMA_Ctrl通道，并启动运算
//    RD0 = DMA_PATH1;
//    ParaMem_Num = RD0;
//    RD0 = DMA_nParaNum_Format;
//    ParaMem_Addr = RD0;
//    Wait_While(Flag_DMAWork==1);
//    nop; nop;
//    Wait_While(Flag_DMAWork==0);
//    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      Real_To_Complex2
//  功能:
//      紧凑16bit格式转换为复数格式，虚部置零
//  参数:
//      1.RA0:输入序列指针，格式[Re(n+1) | Re(n)]
//      2.RA1:输出序列指针，格式[Re | 0](out)
//      3.RD0:TimerNum值 = (输入序列Dword长度*2)+2
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField Real_To_Complex2;
    RD2 = RD0;
    //以下为实数序列转换成复数操作示例程序
    //存储地址扩展为两倍，虚部置0
    ////偶数地址
    //--------------------------------------------------
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置参数
    RD0 = 0x2020;  //偶数序号0x2020  //奇数序号0x1010
    M[RA6+11*MMU_BASE] = RD0;     //ALU1写指令端口
    //配置相关的4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //配置结束
    //配置DMA_Ctrl参数，包括地址.长度
    RD0 = RA0;//源地址0
    send_para(RD0);
    RD0 = RA1;//目标地址
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_Real2Complex;
    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_Format;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    //---------------------------------------------------
    //奇数地址
    //--------------------------------------------------
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置参数
    RD0 = 0x1010;  //偶数序号0x2020  //奇数序号0x1010
    M[RA6+11*MMU_BASE] = RD0;     //ALU1写指令端口
    //配置相关的4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;
    RD1 = 1024;
    M[RA1+RD1] = RD0;
    MemSet_Disable;     //配置结束
    //配置DMA_Ctrl参数，包括地址.长度
    RD0 = RA0;//源地址0
    send_para(RD0);
    RD0 = RA1;//目标地址
    RD0 += MMU_BASE;//奇数地址从1开始
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_Real2Complex;
    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_Format;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    Return_AutoField(0);



END SEGMENT

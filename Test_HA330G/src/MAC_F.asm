#define _MAC_F_

#include <CPU11.def>
#include <resource_allocation.def>
#include <RN_DSP_Cfg.def>
#include <DMA_ParaCfg.def>
#include <DMA_ALU.def>
#include <Global.def>
#include <MAC.def>

extern _Debug_Memory_File_Bank;

CODE SEGMENT MAC_F;
////////////////////////////////////////////////////////
//  名称:
//      SingleSerSquare
//  功能:
//      单序列平方运算
//  参数:
//      1.RD0:输入序列指针，紧凑16bit格式
//      2.RD1:输出序列指针，紧凑16bit格式(out)
//      3.RD2:TimerNumber = (Dword长度*3)+3
//  返回值值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField SingleSerSquare;
    RA0 = RD0;
    RA1 = RD1;

    //以下为单序列平方操作示例程序
    //--------------------------------------------------
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH2] = RD0;//选择PATH1，通道信息在偏址上

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置ALU参数
    RD0 = RN_CFG_MAC_TYPE0;//       RN_CFG_MAC_HDMUL+RN_CFG_MAC_QM1M0H16;     //加法指令
    M[RA6+9*MMU_BASE] = RD0;     //ALU1写指令端口
    RD0 = 0;
    M[RA6+10*MMU_BASE] = RD0;     //ALU1写Const端口
    //配置相关的4KRAM
    RD0 = DMA_PATH2;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    RD0 = RA0;//源地址0
    send_para(RD0);
    RD0 = RA0;//源地址1
    send_para(RD0);
    RD0 = RA1;//目标地址
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_MAC;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH2;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_MAC;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      MultiSum_Init
//  功能:
//      双序列乘累加运算（不读取累加结果）
//  参数:
//      1.RA0:输入序列1指针，紧凑16bit格式序列
//      2.RA1:输入序列2指针，紧凑16bit格式序列
//      3.RD1:输出序列指针，紧凑16bit格式序列(out)
//      4.RD0:TimerNum值 = (Len*3)+3
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField MultiSum_Init;
    push RA2;
    RD2 = RD0;
    RA2 = RD1;
    //--------------------------------------------------
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH2] = RD0;//选择PATH1，通道信息在偏址上
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置ALU参数
    RD0 = RN_CFG_MAC_TYPE0ACC;//       RN_CFG_MAC_HDMUL+RN_CFG_MAC_QM1M0M16;     //加法指令
    M[RA6+9*MMU_BASE] = RD0;     //MAC写指令端口
    RD0 = 0;
    M[RA6+10*MMU_BASE] = RD0;    //MAC写Const端口
    //配置相关的4KRAM
    RD0 = DMA_PATH2;
    M[RA0] = RD0;
    M[RA1] = RD0;
    M[RA2] = RD0;
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    RD0 = RA0;//源地址0
    send_para(RD0);
    RD0 = RA1;//源地址1
    send_para(RD0);
    RD0 = RA2;//目标地址
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_MAC;//单目运算配置专用函数

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH2;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_MAC;
    ParaMem_Addr = RD0;

    pop RA2;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      MAC_MultiConst16
//  功能:
//      为单序列乘常量操作配置DMA_Ctrl参数
//  参数:
//      1.M[RSP+3*MMU_BASE]：X(n) 首地址（字节地址）
//      2.M[RSP+2*MMU_BASE]：Const 注意要求高16位与低16位相同
//      3.M[RSP+1*MMU_BASE]：Z(n) 首地址
//      4.M[RSP+0*MMU_BASE]：数据长度对应的TimerNum值，对应(Len*3)+3
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField MAC_MultiConst16;
    RA0 = M[RSP+3*MMU_BASE];
    RA1 = M[RSP+1*MMU_BASE];
    //--------------------------------------------------
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH2] = RD0;//选择PATH2，通道信息在偏址上

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置MAC参数
    RD0 = RN_CFG_MAC_TYPE2;//    //X[n]*CONST/32767
    M[RA6+9*MMU_BASE] = RD0;     //MAC写指令端口
    RD0 = M[RSP+2*MMU_BASE];     //CONST为16位，高低16位写相同数据
    M[RA6+10*MMU_BASE] = RD0;    //MAC写Const端口
    //配置相关的4KRAM
    RD0 = DMA_PATH2;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    RD1 = M[RSP+0*MMU_BASE];
    RD0 = RA0;//源地址0
    send_para(RD0);
    RD0 = RA0;//源地址1
    send_para(RD0);
    RD0 = RA1;//目标地址
    send_para(RD0);
    send_para(RD1);//长度
    call _DMA_ParaCfg_MAC;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH2;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_MAC;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    Return_AutoField(4*MMU_BASE);


////////////////////////////////////////////////////////
//  名称:
//      MAC_MultiConst24_DivQ7
//  功能:
//      为单序列乘常量操作配置DMA_Ctrl参数，结果自动除以Q7，保留32bit
//  参数:
//      1.M[RSP+3*MMU_BASE]：X(n) 首地址（字节地址）
//      2.M[RSP+2*MMU_BASE]：Const 注意要求高24位是Const数据，低8位须保持全0
//      3.M[RSP+1*MMU_BASE]：Z(n) 首地址
//      4.M[RSP+0*MMU_BASE]：数据长度对应的TimerNum值，对应(Len*3)+3
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField MAC_MultiConst24_DivQ7;
    RA0 = M[RSP+3*MMU_BASE];
    RA1 = M[RSP+1*MMU_BASE];
    //--------------------------------------------------
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH2] = RD0;//选择PATH2，通道信息在偏址上

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置MAC参数
    RD0 = RN_CFG_MAC_HDCONST24+RN_CFG_MAC_QM1L32;    //X[n]*CONST/Q7
    M[RA6+9*MMU_BASE] = RD0;     //MAC写指令端口
    RD0 = M[RSP+2*MMU_BASE];     //CONST
    M[RA6+10*MMU_BASE] = RD0;    //MAC写Const端口

    //配置相关的4KRAM
    RD0 = DMA_PATH2;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    RD1 = M[RSP+0*MMU_BASE];
    RD0 = RA0;//源地址0
    send_para(RD0);
    RD0 = RA0;//源地址1
    send_para(RD0);
    RD0 = RA1;//目标地址
    send_para(RD0);
    send_para(RD1);//长度
    call _DMA_ParaCfg_MAC;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH2;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_MAC;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    Return_AutoField(4*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      MAC_MultiConst16_Q2207
//  功能:
//      为单序列乘常量操作配置DMA_Ctrl参数
//  参数:
//      1.M[RSP+3*MMU_BASE]：X(n) 首地址（字节地址）
//      2.M[RSP+2*MMU_BASE]：Const 注意要求高16位与低16位相同
//      3.M[RSP+1*MMU_BASE]：Z(n) 首地址
//      4.M[RSP+0*MMU_BASE]：数据长度对应的TimerNum值，对应(Len*3)+3
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField MAC_MultiConst16_Q2207;
    RA0 = M[RSP+3*MMU_BASE];
    RA1 = M[RSP+1*MMU_BASE];
    //--------------------------------------------------
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH2] = RD0;//选择PATH2，通道信息在偏址上

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置MAC参数
    RD0 = RN_CFG_MAC_TYPE3L;//    //X[n]*CONST/32767
    M[RA6+9*MMU_BASE] = RD0;     //MAC写指令端口
    RD0 = M[RSP+2*MMU_BASE];     //CONST为16位，高低16位写相同数据
    M[RA6+10*MMU_BASE] = RD0;    //MAC写Const端口
    //配置相关的4KRAM
    RD0 = DMA_PATH2;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    RD1 = M[RSP+0*MMU_BASE];
    RD0 = RA0;//源地址0
    send_para(RD0);
    RD0 = RA0;//源地址1
    send_para(RD0);
    RD0 = RA1;//目标地址
    send_para(RD0);
    send_para(RD1);//长度
    call _DMA_ParaCfg_MAC;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH2;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_MAC;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    Return_AutoField(4*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      ModulationToZero
//  功能:
//      调制
//  参数:
//      1.RA0:表地址
//      2.RA1:操作数地址
//      3.RD1:目标地址
//      4.RD0:数据长度对应的TimerNum值(Dword长度*3+3)
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField ModulationToZero;
    push RA2;
    RA2 = RD1;
    RD2 = RD0;
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH2] = RD0;//选择PATH1，通道信息在偏址上

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置ALU参数
    RD0 = RN_CFG_MAC_TYPE1;//       RN_CFG_MAC_HDMODU+RN_CFG_MAC_QM1M0H16
    M[RA6+9*MMU_BASE] = RD0;     //ALU1写指令端口
    RD0 = 0;
    M[RA6+10*MMU_BASE] = RD0;     //ALU1写Const端口
    //配置相关的4KRAM
    RD0 = DMA_PATH2;
    M[RA0] = RD0;
    M[RA1] = RD0;
    M[RA2] = RD0;
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    RD0 = RA0;//源地址0
    send_para(RD0);
    RD0 = RA1;//源地址1
    send_para(RD0);
    RD0 = RA2;//目标地址
    send_para(RD0);
    send_para(RD2);//长度
    call _DMA_ParaCfg_MAC;//单目运算配置专用函数

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH2;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_MAC;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    pop RA2;
    Return_AutoField(0);


////////////////////////////////////////////////////////
//  名称:
//      MultiConstH16L16
//  功能:
//      序列与Const相乘运算
//  参数:
//      RA0:输入序列1指针，紧凑16bit格式序列
//      RA1:输出序列指针，紧凑16bit格式序列(out)
//      RD1:Const值
//      RD0:TimerNum值 = (Len*3)+3
//  返回值:
//      RD0:乘累加结果
////////////////////////////////////////////////////////
Sub_AutoField MultiConstH16L16;
    RD2 = RD0;
    RD3 = RD1;
    //--------------------------------------------------
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH2] = RD0;//选择PATH1，通道信息在偏址上

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置ALU参数
    RD0 = RN_CFG_MAC_TYPE2;//RN_CFG_MAC_HDCONST16+RN_CFG_MAC_QM1M0H16//X[n]*CONST
    M[RA6+9*MMU_BASE] = RD0;     //MAC写指令端口
    RD0 = RD3;
    M[RA6+10*MMU_BASE] = RD0;     //MAC写Const端口
    //配置相关的4KRAM
    RD0 = DMA_PATH2;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    send_para(RA0);//源地址0
    send_para(RA0);//源地址1，空操作
    send_para(RA1);//目标地址
    send_para(RD2);//计数值
    call _DMA_ParaCfg_MAC;//单目运算配置专用函数

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH2;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_MAC;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    //---------------------------------------------------
    Return_AutoField(0);


END SEGMENT

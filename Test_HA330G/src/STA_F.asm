#define _STA_F_

#include <CPU11.def>
#include <resource_allocation.def>
#include <RN_DSP_Cfg.def>
#include <DMA_ParaCfg.def>
#include <DMA_ALU.def>
#include <STA.def>

CODE SEGMENT STA_F;
////////////////////////////////////////////////////////
//  名称:
//      FindMaxMin
//  功能:
//      求序列极值（STA1）
//  参数:
//      1.RD0:数据地址
//      2.RD1:数据长度对应的TimerNum值(Dword长度+2)*2+1
//  返回值:
//      1.RD0:最大值
//      2.RD1:最小值
////////////////////////////////////////////////////////
Sub_AutoField FindMaxMin;
    RA0 = RD0;
    RD2 = RD1;
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能

    //配置相关的4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;

    //配置ALU参数
    RD0 = Op32Bit;      //ALU处理位宽选择为32位
    RD0 += RffC_Add;     //加法指令
    M[RA6+0*MMU_BASE] = RD0;     //ALU1写指令端口
    RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1写Const端口
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    send_para(RA0);//源地址0
    send_para(RA0);//目标地址
    send_para(RD2);
    RD0 = 0x0C130001;
    send_para(RD0);
    call _DMA_ParaCfg_RffC_Rf;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
//Set_LevelL10;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
//Set_LevelH10;

    //读取直方图统计结果
    MemSetRAM4K_Enable;  //操作扩展端口时需使能
    RD0 = M[RA6+0*MMU_BASE]; //DW0
    //RD0 = M[RA6+2*MMU_BASE]; //DW1
    //RD0 = M[RA6+2*MMU_BASE]; //DW2
    MemSet_Disable;  //Set_All
    RD1 = RD0;
    RF_GetH16(RD0);
    RF_GetL16(RD1);
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      AbsSum
//  功能:
//      求序列的绝对值累加和（STA1）
//  参数:
//      1.RD0:数据地址
//      2.RD1:数据长度对应的TimerNum值(Dword长度*2+4+1)
//  返回值:
//      1.RD0:绝对值累加和
////////////////////////////////////////////////////////
Sub_AutoField AbsSum;
    RA0 = RD0;
    RD2 = RD1;
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能

    //配置相关的4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;

    //配置ALU参数
    RD0 = Op32Bit;      //ALU处理位宽选择为32位
    RD0 += RffC_Add;     //加法指令
    M[RA6+0*MMU_BASE] = RD0;     //ALU1写指令端口
    RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1写Const端口
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    send_para(RA0);//源地址0
    send_para(RA0);//目标地址
    RD0 = RD2;
    send_para(RD0);
    call _DMA_ParaCfg_RffC;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
//Set_LevelL10;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
//Set_LevelH10;

    //读取直方图统计结果
    MemSetRAM4K_Enable;  //操作扩展端口时需使能
    RD0 = M[RA6+0*MMU_BASE]; //DW0
    RD0 = M[RA6+0*MMU_BASE]; //DW1
    //RD0 = M[RA6+2*MMU_BASE]; //DW2
    MemSet_Disable;  //Set_All
    RD0_ClrByteH8;
    //RF_ShiftL1(RD0);
    //RF_ShiftL3(RD0);

    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      nAbsSum
//  功能:
//      求序列的累加和（STA1）
//  参数:
//      1.RD0:数据地址
//      2.RD1:数据长度对应的TimerNum值(Dword长度+2)*2+1
//  返回值:
//      1.RD0:累加和
////////////////////////////////////////////////////////
Sub_AutoField nAbsSum;
    RA0 = RD0;
    RD2 = RD1;
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能

    //配置相关的4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;

    //配置ALU参数
    RD0 = Op16Bit;      //ALU处理位宽选择为16位
    RD0 += RffC_Add;     //加法指令
    M[RA6+0*MMU_BASE] = RD0;     //ALU1写指令端口
    RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1写Const端口
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    send_para(RA0);//源地址0
    send_para(RA0);//目标地址
    RD0 = RD2;
    send_para(RD0);
    call _DMA_ParaCfg_RffC_nAbs;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
//Set_LevelL10;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
//Set_LevelH10;

    //读取直方图统计结果
    MemSetRAM4K_Enable;  //操作扩展端口时需使能
    RD0 = M[RA6+0*MMU_BASE]; //DW0
    RD0 = M[RA6+0*MMU_BASE]; //DW1
    //RD0 = M[RA6+2*MMU_BASE]; //DW2
    MemSet_Disable;  //Set_All
    RD0_ClrByteH8;
    //RF_ShiftL1(RD0);
    //RF_ShiftL3(RD0);

    Return_AutoField(0);




////////////////////////////////////////////////////////
//  名称:
//      MeanSquareAverage
//  功能:
//      求序列的均方（STA1），均值分母为32
//  参数:
//      1.RD0:数据地址
//      2.RD1:数据长度对应的TimerNum值(Dword长度+2)*2+2
//  返回值:
//      1.RD0:均方值
////////////////////////////////////////////////////////
Sub_AutoField MeanSquareAverage;
    RA0 = RD0;
    RD2 = RD1;
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能

    //配置相关的4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;

    //配置ALU参数
    RD0 = Op32Bit;      //ALU处理位宽选择为32位
    RD0 += RffC_Add;     //加法指令
    M[RA6+0*MMU_BASE] = RD0;     //ALU1写指令端口
    RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1写Const端口
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    send_para(RA0);//源地址0
    send_para(RA0);//目标地址
    RD0 = RD2;
    send_para(RD0);
    call _DMA_ParaCfg_RffC;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    //读取直方图统计结果
    MemSetRAM4K_Enable;  //操作扩展端口时需使能
    RD0 = M[RA6+0*MMU_BASE]; //DW0
    RD0 = M[RA6+0*MMU_BASE]; //DW1
    RD0 = M[RA6+0*MMU_BASE]; //DW2
    MemSet_Disable;  //Set_All
    RF_ShiftL1(RD0);
    RF_ShiftL2(RD0);

    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      FindMaxIndex
//  功能:
//      求序列绝对值的最大值的Index（STA2）
//  参数:
//      1.RD0:数据地址
//      2.RD1:数据长度对应的TimerNum值(Dword长度+2)*2
//  返回值:
//      1.RD0:最大值的Index
////////////////////////////////////////////////////////
Sub_AutoField FindMaxIndex;
    RA0 = RD0;
    RD2 = RD1;
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH2] = RD0;//选择PATH2，通道信息在偏址上

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能

    //配置相关的4KRAM
    RD0 = DMA_PATH2;
    M[RA0] = RD0;

    //配置ALU参数
    RD0 = Op32Bit;      //ALU处理位宽选择为32位
    RD0 += RffC_Add;     //加法指令
    M[RA6+2*MMU_BASE] = RD0;     //ALU1写指令端口
    RD0 = 0;
    M[RA6+3*MMU_BASE] = RD0;     //ALU1写Const端口
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    send_para(RA0);//源地址0
    send_para(RA0);//目标地址
    RD0 = RD2;
    send_para(RD0);
    call _DMA_ParaCfg_RffC;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH2;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    //读取直方图统计结果
    MemSetRAM4K_Enable;  //操作扩展端口时需使能
    RD0 = M[RA6+1*MMU_BASE];//Max值 | ~(Index)
    RF_Not(RD0);
    RF_GetL16(RD0);
    RF_ShiftR1(RD0);
    MemSet_Disable;  //Set_All

    Return_AutoField(0);


////////////////////////////////////////////////////////
//  函数名称:
//      STA1_Run
//  函数功能:
//      启动STA1统计器并等待统计完毕
//  入口参数:
//      RD0:数据地址
//      RD1:数据长度对应的TimerNum值
//  出口参数:
//      无
////////////////////////////////////////////////////////
sub_autofield STA1_Run;
    RA0 = RD0;
    RD2 = RD1;
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能

    //配置相关的4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;

    //配置ALU参数
    RD0 = Op32Bit;      //ALU处理位宽选择为32位
    RD0 += RffC_Add;     //加法指令
    M[RA6+0*MMU_BASE] = RD0;     //ALU1写指令端口
    RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1写Const端口
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址、长度
    send_para(RA0);//源地址0
    send_para(RA0);//目标地址
    RD0 = RD2;
    send_para(RD0);
    call _DMA_ParaCfg_RffC;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    return_autofield(0);



////////////////////////////////////////////////////////
//  函数名称:
//      STA2_Run
//  函数功能:
//      启动STA2统计器并等待统计完毕
//  入口参数:
//      RD0:数据地址
//      RD1:数据长度对应的TimerNum值
//  出口参数:
//      无
////////////////////////////////////////////////////////
sub_autofield STA2_Run;
    RA0 = RD0;
    RD2 = RD1;
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH2] = RD0;//选择PATH2，通道信息在偏址上

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能

    //配置相关的4KRAM
    RD0 = DMA_PATH2;
    M[RA0] = RD0;

    //配置ALU参数
    RD0 = Op32Bit;      //ALU处理位宽选择为32位
    RD0 += RffC_Add;     //加法指令
    M[RA6+2*MMU_BASE] = RD0;     //ALU1写指令端口
    RD0 = 0;
    M[RA6+3*MMU_BASE] = RD0;     //ALU1写Const端口
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址、长度
    send_para(RA0);//源地址0
    send_para(RA0);//目标地址
    RD0 = RD2;
    send_para(RD0);
    call _DMA_ParaCfg_RffC;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH2;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    return_autofield(0);



////////////////////////////////////////////////////////
//  函数名称:
//      STA3_Run
//  函数功能:
//      启动STA3统计器并等待统计完毕
//  入口参数:
//      RD0:数据地址
//      RD1:数据长度对应的TimerNum值
//  出口参数:
//      无
////////////////////////////////////////////////////////
sub_autofield STA3_Run;
    RA0 = RD0;
    RD2 = RD1;
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH3] = RD0;//选择PATH3，通道信息在偏址上

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能

    //配置相关的4KRAM
    RD0 = DMA_PATH3;
    M[RA0] = RD0;

    //配置ALU参数
    RD0 = Op32Bit;      //ALU处理位宽选择为32位
    RD0 += RffC_Add;     //加法指令
    M[RA6+4*MMU_BASE] = RD0;     //ALU1写指令端口
    RD0 = 0;
    M[RA6+5*MMU_BASE] = RD0;     //ALU1写Const端口
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址、长度
    send_para(RA0);//源地址0
    send_para(RA0);//目标地址
    RD0 = RD2;
    send_para(RD0);
    call _DMA_ParaCfg_RffC;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH3;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    return_autofield(0);



////////////////////////////////////////////////////////
//  函数名称:
//      STA1_Rst
//  函数功能:
//      读取STA1统计器的结果
//  入口参数:
//      无
//  出口参数:
//      RD0:Max<31:16> | Min<15:0>
//      RD1:过零率_L<31:24> | 累加和<23:0>
//      RD4:过零率_H<31:29> | 平方和/256<28:0>
////////////////////////////////////////////////////////
sub_autofield STA1_Rst;
    MemSetRAM4K_Enable;
    RD0 = M[RA6+0*MMU_BASE];
    RD1 = M[RA6+0*MMU_BASE];
    RD4 = M[RA6+0*MMU_BASE];
    MemSet_Disable;
    return_autofield(0);



////////////////////////////////////////////////////////
//  函数名称:
//      STA2_Rst
//  函数功能:
//      读取STA2统计器的结果
//  入口参数:
//      无
//  出口参数:
//      RD0:Max<31:16> | ~(Index)<11:0>
//      RD1:过零率_L<31:24> | 累加和<23:0>
//      RD4:过零率_H<31:29> | 平方和/256<28:0>
////////////////////////////////////////////////////////
sub_autofield STA2_Rst;
    MemSetRAM4K_Enable;
    RD0 = M[RA6+1*MMU_BASE];
    RD1 = M[RA6+1*MMU_BASE];
    RD4 = M[RA6+1*MMU_BASE];
    MemSet_Disable;
    return_autofield(0);



////////////////////////////////////////////////////////
//  函数名称:
//      STA3_Rst
//  函数功能:
//      读取STA3统计器的结果
//  入口参数:
//      无
//  出口参数:
//      RD0:Max<31:16> | Min<15:0>
//      RD1:累加和<31:0>
//      RD4:平方和/256<31:0>
////////////////////////////////////////////////////////
sub_autofield STA3_Rst;
    MemSetRAM4K_Enable;
    RD0 = M[RA6+2*MMU_BASE];
    RD1 = M[RA6+2*MMU_BASE];
    RD4 = M[RA6+2*MMU_BASE];
    MemSet_Disable;
    return_autofield(0);



END SEGMENT

#define _IIR_F_

#include <CPU11.def>
#include <resource_allocation.def>
#include <RN_DSP_Cfg.def>
#include <DMA_ParaCfg.def>
#include <DMA_ALU.def>
#include <IIR.def>

extern _Debug_Memory_File_Bank;



CODE SEGMENT IIR_F;
////////////////////////////////////////////////////////
//  名称:
//      _IIR_PATH1_FiltLP32
//  功能:
//      使用IIR1_1执行低通滤波，Para0, Data00
//  参数:
//      1.RA0:输入序列指针，16bit紧凑格式序列
//      2.RA1:输出序列指针，16bit紧凑格式序列(out)
//      3.RD0:TimerNum值 = (序列Dword长度*48)+1
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _IIR_PATH1_FiltLP32;
    RD2 = RD0;
    //--------------------------------------------------
    //设置GRAM属性为DMA_Ctrl1操作，Group为单位
    MemSetPath_Enable;  //设置通道使能
    M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上

    //配置ALU参数
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置相关的4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;

    IIR_PATH1_Enable;
    RD0 = 0x0;
    IIR_PATH1_BANK = RD0;

    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    RD0 = RA0;//源地址
    send_para(RD0);
    RD0 = RA1;//目标地址
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_FiltIIR;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_IIR;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
	IIR_PATH1_CLRADDR;
    //IIR_PATH1_Disable;
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      _IIR_PATH1_FiltLP4Class
//  功能:
//      使用IIR1_1执行低通滤波，Para1, Data01
//  参数:
//      1.RA0:输入序列指针，16bit紧凑格式序列
//      2.RA1:输出序列指针，16bit紧凑格式序列(out)
//      3.RD0:TimerNum值 = (输出序列Dword长度*28)+1
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _IIR_PATH1_FiltLP4Class;
    RD2 = RD0;
    //--------------------------------------------------
    //设置GRAM属性为DMA_Ctrl1操作，Group为单位
    MemSetPath_Enable;  //设置通道使能
    M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上

    //配置ALU参数
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置相关的4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;
    IIR_PATH1_Enable;
    RD0 = 0x5;// Para1, Data01
    IIR_PATH1_BANK = RD0;
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    RD0 = RA0;//源地址
    send_para(RD0);
    RD0 = RA1;//目标地址
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_FiltIIR;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_IIR;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
	IIR_PATH1_CLRADDR;
    IIR_PATH1_Disable;
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      _IIR_PATH1_FiltHP4Class
//  功能:
//      使用IIR1_1执行高通滤波，Para1, Data11
//  参数:
//      1.RA0:输入序列指针，16bit紧凑格式序列
//      2.RA1:输出序列指针，16bit紧凑格式序列(out)
//      3.RD0:TimerNum值 = (输出序列Dword长度*48)+1
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _IIR_PATH1_FiltHP4Class;
    RD2 = RD0;
    //--------------------------------------------------
    //设置GRAM属性为DMA_Ctrl1操作，Group为单位
    MemSetPath_Enable;  //设置通道使能
    M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上

    //配置ALU参数
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置相关的4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;
    IIR_PATH1_Enable;
    RD0 = 0x7;// Para1, Data11
    IIR_PATH1_BANK = RD0;
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    RD0 = RA0;//源地址
    send_para(RD0);
    RD0 = RA1;//目标地址
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_FiltIIR;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_IIR;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
	IIR_PATH1_CLRADDR;
    IIR_PATH1_Disable;
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      _IIR_PATH1_HawlClr
//  功能:
//      使用IIR1_1执行陷波，Para1, Data10
//  参数:
//      1.RA0:输入序列指针，16bit紧凑格式序列
//      2.RA1:输出序列指针，16bit紧凑格式序列(out)
//      3.RD0:TimerNum值 = (输出序列Dword长度*48)+1
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _IIR_PATH1_HawlClr;
    RD2 = RD0;
    //--------------------------------------------------
    //设置GRAM属性为DMA_Ctrl1操作，Group为单位
    MemSetPath_Enable;  //设置通道使能
    M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上

    //配置ALU参数
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置相关的4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;
    //IIR_PATH1_Enable;
    RD0 = 0x6;
    IIR_PATH1_BANK = RD0;
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    RD0 = RA0;//源地址
    send_para(RD0);
    RD0 = RA1;//目标地址
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_FiltIIR;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_IIR;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
	IIR_PATH1_CLRADDR;
    //IIR_PATH1_Disable;
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      _IIR_PATH3_HP
//  功能:
//      使用IIR2_3执行高通滤波，高通起始频率170Hz，Para0, Data00
//  参数:
//      1.RA0:输入序列指针，16bit紧凑格式序列
//      2.RA1:输出序列指针，16bit紧凑格式序列(out)
//      3.RD0:TimerNum值 = (序列Dword长度*88)+1
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _IIR_PATH3_HP;
    RD2 = RD0;
    //--------------------------------------------------
    //设置GRAM属性为DMA_Ctrl1操作，Group为单位
    MemSetPath_Enable;  //设置通道使能
    M[RA0+MGRP_PATH3] = RD0;//选择PATH1，通道信息在偏址上

    //配置ALU参数
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置相关的4KRAM
    RD0 = DMA_PATH3;
    M[RA0] = RD0;
    M[RA1] = RD0;

    IIR_PATH3_Enable;
    RD0 = 0x0;
    IIR_PATH3_BANK = RD0;

    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    RD0 = RA0;//源地址
    send_para(RD0);
    RD0 = RA1;//目标地址
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_FiltIIR;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH3;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_IIR;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
	IIR_PATH3_CLRADDR;
//    IIR_PATH3_Disable;
    Return_AutoField(0*MMU_BASE);

////////////////////////////////////////////////////////
//  名称:
//      _IIR_PATH3_HB
//  功能:
//      使用IIR2_3执行内插0后的半带滤波，Para1, Data01
//  参数:
//      1.RA0:输入序列指针，16bit紧凑格式序列
//      2.RA1:输出序列指针，16bit紧凑格式序列(out)
//      3.RD0:TimerNum值 = (序列Dword长度*88)+1
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _IIR_PATH3_HB;
    RD2 = RD0;
    //--------------------------------------------------
    //设置GRAM属性为DMA_Ctrl1操作，Group为单位
    MemSetPath_Enable;  //设置通道使能
    M[RA0+MGRP_PATH3] = RD0;//选择PATH1，通道信息在偏址上

    //配置ALU参数
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置相关的4KRAM
    RD0 = DMA_PATH3;
    M[RA0] = RD0;
    M[RA1] = RD0;

    IIR_PATH3_Enable;
    RD0 = 0b0101;
    IIR_PATH3_BANK = RD0;

    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    RD0 = RA0;//源地址
    send_para(RD0);
    RD0 = RA1;//目标地址
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_FiltIIR;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH3;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_IIR;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

//    IIR_PATH3_Disable;
	IIR_PATH3_CLRADDR;
    Return_AutoField(0*MMU_BASE);

////////////////////////////////////////////////////////
//  名称:
//      _IIR_PATH3_FSFT
//  功能:
//      使用IIR2_3执行1/4带低通滤波，Para1, Data01/Data10/Data11
//  参数:
//      1.RA0:输入序列指针，16bit紧凑格式序列
//      2.RA1:输出序列指针，16bit紧凑格式序列(out)
//      3.RD0:TimerNum值 = (序列Dword长度*88)+1
//      4.RD1:Data Bank号 1/2/3
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _IIR_PATH3_FSFT;
    RD2 = RD0;
    RD3 = RD1;
    //--------------------------------------------------
    //设置GRAM属性为DMA_Ctrl1操作，Group为单位
    MemSetPath_Enable;  //设置通道使能
    M[RA0+MGRP_PATH3] = RD0;//选择PATH1，通道信息在偏址上

    //配置ALU参数
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置相关的4KRAM
    RD0 = DMA_PATH3;
    M[RA0] = RD0;
    M[RA1] = RD0;

    IIR_PATH3_Enable;
    RD0 = 4;
    RD0 += RD3;
    IIR_PATH3_BANK = RD0;

    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    RD0 = RA0;//源地址
    send_para(RD0);
    RD0 = RA1;//目标地址
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_FiltIIR;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH3;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_IIR;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
	IIR_PATH3_CLRADDR;
//    IIR_PATH3_Disable;
    Return_AutoField(0*MMU_BASE);


END SEGMENT

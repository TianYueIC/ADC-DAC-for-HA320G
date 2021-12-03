#define _FFT_F_

#include <CPU11.def>
#include <resource_allocation.def>
#include <RN_DSP_Cfg.def>
#include <DMA_ParaCfg.def>
#include <DMA_ALU.def>
#include <Global.def>
#include <FFT.def>

CODE SEGMENT FFT_F;
////////////////////////////////////////////////////////
//  名称:
//      FFT_fix
//  功能:
//      FFT运算
//      数据入口：RN_FFT_COFF_GRAM_ADDR
//  参数:
//      1.RD0:输入序列指针，高位16bit格式序列
//      2.RD1:输出序列指针，复数格式(out)
//  返回值:
//      1.RD0:增益系数
////////////////////////////////////////////////////////
Sub_AutoField FFT_fix;
    push RD4;
    push RA2;

    RA0 = RD0;
    RA1 = RD1;
//FFT 地址逆序
    //初始化 FFT,512点
    //--------------------------------------------------
    //设置GRAM属性为DMA_Ctrl3操作，Group为单位
    MemSetPath_Enable;  //设置通道使能
    M[RA0+MGRP_PATH3] = RD0;//选择PATH3，通道信息在偏址上

    //配置LMT参数
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    RD0 = 0x4;          //数据传送指令
    M[RA6+4*MMU_BASE] = RD0;     //LMT写指令端口
    //配置相关的RAM，512点复数占用2K字节空间
    RD0 = DMA_PATH3;
    RD1 = RN_GRAM_BANK_SIZE;
    M[RA0] = RD0;
    M[RA0+RD1] = RD0;
    M[RA1] = RD0;
    M[RA1+RD1] = RD0;
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    RD0 = RA0;//源地址
    send_para(RD0);
    RD0 = RA1;//目标地址
    send_para(RD0);
    call _DMA_ParaCfg_FFT512_Revs;//单目运算配置专用函数

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH3;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_FFTRevs;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    //---------------------------------------------------

//硬件初始化

    //RAM指针设定
    RD0 = RN_FFT_COFF_GRAM_ADDR;
    RA2 = RD0;          //FFT系数地址

    RD3 = 0;            //记录缩放倍数
    RD4 = -1;            //溢出控制  0：不移位
    RD2 = 9;           //分解次数  1024:10  512:9

    Sel_PATH3_FFT;
    //分解循环
L_FFT_Loop_L0:
    //设置GRAM属性为DMA_Ctrl3操作，Group为单位
    MemSetPath_Enable;         //设置通道使能
    M[RA1+MGRP_PATH3] = RD0;   //选择PATH3，通道信息在偏址上

    //配置4KRAM通道
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    RD0 = DMA_PATH3;
    RD1 = RN_GRAM_BANK_SIZE;
    M[RA1] = RD0;       //逆序后的地址
    M[RA1+RD1] = RD0;
    M[RA2] = RD0;       //FFT系数地址
M[RA2+RD1] = RD0;
RD1 = RN_GRAM_BANK_SIZE*2;
M[RA2+RD1] = RD0;
RD1 = RN_GRAM_BANK_SIZE*3;
M[RA2+RD1] = RD0;
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数
    send_para(RA2);     //FFT系数地址
    send_para(RA1);     //数据地址
    send_para(RD4);     //是否移位 0：不移位
    call _DMA_ParaCfg_FFT512;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH3;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_FFT;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    //---------------------------------------------------

    //判断并控制溢出风险
    RD4 = 0;
    if(RFlag_OverFlowFFT==0) goto L_FFT_Loop_L1;
    RD3 ++;
    RD4 = -1;
L_FFT_Loop_L1:

    //控制分解第次
    FFT_Next_Round;
    RD2 --;
    if(RQ_nZero) goto L_FFT_Loop_L0;

    Dis_PATH3_FFT;

    RD0 = RD3;

    pop RA2;
    pop RD4;

    Return_AutoField(0);


////////////////////////////////////////////////////////
//  名称:
//      FFT_fix128
//  功能:
//      FFT运算
//      数据入口：RN_FFT_COFF_GRAM_ADDR
//  参数:
//      1.RD0:输入序列指针，高位16bit格式序列
//      2.RD1:输出序列指针，复数格式
//  返回值:
//      RD0:增益系数
////////////////////////////////////////////////////////
Sub_autofield FFT_fix128;
    push RD4;
    push RA2;

    RA0 = RD0;
    RA1 = RD1;
//FFT 地址逆序
    //初始化 FFT,128点
    //--------------------------------------------------
    //设置GRAM属性为DMA_Ctrl3操作，Group为单位
    MemSetPath_Enable;  //设置通道使能
    M[RA0+MGRP_PATH3] = RD0;//选择PATH3，通道信息在偏址上

    //配置LMT参数
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    RD0 = 0x4;          //数据传送指令
    M[RA6+4*MMU_BASE] = RD0;     //LMT写指令端口
    //配置相关的RAM，128点复数占用512字节空间
    RD0 = DMA_PATH3;
    RD1 = RN_GRAM_BANK_SIZE;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //配置结束

	Sel_SE256FFT;

    //配置DMA_Ctrl参数，包括地址、长度
    RD0 = RA0;//源地址
    send_para(RD0);
    RD0 = RA1;//目标地址
    send_para(RD0);
    call _DMA_ParaCfg_FFT128_Revs;//单目运算配置专用函数

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH3;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_FFTRevs;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    //---------------------------------------------------

//硬件初始化

    //RAM指针设定
    RD0 = RN_FFT_COFF_GRAM_ADDR;
    RA2 = RD0;          //FFT系数地址

    RD3 = 0;            //记录缩放倍数
    RD4 = -1;            //溢出控制  0：不移位
    RD2 = 7;           //分解次数  1024:10  512:9

    Sel_PATH3_FFT;
    //分解循环
L_FFT128_Loop_L0:
    //设置GRAM属性为DMA_Ctrl3操作，Group为单位
    MemSetPath_Enable;         //设置通道使能
    M[RA1+MGRP_PATH3] = RD0;   //选择PATH3，通道信息在偏址上

    //配置4KRAM通道
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    RD0 = DMA_PATH3;
    RD1 = RN_GRAM_BANK_SIZE;
    M[RA1] = RD0;       //逆序后的地址
    M[RA2] = RD0;       //FFT系数地址
M[RA2+RD1] = RD0;
RD1 = RN_GRAM_BANK_SIZE*2;
M[RA2+RD1] = RD0;
RD1 = RN_GRAM_BANK_SIZE*3;
M[RA2+RD1] = RD0;
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数
    send_para(RA2);     //FFT系数地址
    send_para(RA1);     //数据地址
    send_para(RD4);     //是否移位 0：不移位
    call _DMA_ParaCfg_FFT128;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH3;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_FFT;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    //---------------------------------------------------

    //判断并控制溢出风险
    RD4 = 0;
    if(RFlag_OverFlowFFT==0) goto L_FFT128_Loop_L1;
    RD3 ++;
    RD4 = -1;
L_FFT128_Loop_L1:

    //控制分解第次
    FFT_Next_Round;
    RD2 --;
    if(RQ_nZero) goto L_FFT128_Loop_L0;
	Sel_LE256FFT;
    Dis_PATH3_FFT;

    RD0 = RD3;

    pop RA2;
    pop RD4;

    Return_autofield(0);





////////////////////////////////////////////////////////
//  名称:
//      FFT_fix64
//  功能:
//      64点FFT运算
//      数据入口：RN_FFT_COFF_GRAM_ADDR
//  参数:
//      1.RD0:输入序列指针，高位16bit格式序列
//      2.RD1:输出序列指针，复数格式
//  返回值:
//      RD0:增益系数
////////////////////////////////////////////////////////
sub_autofield FFT_fix64;
    push RD4;
    push RA2;

    RA0 = RD0;
    RA1 = RD1;
//FFT 地址逆序
    //初始化 FFT,128点
    //--------------------------------------------------
    //设置GRAM属性为DMA_Ctrl3操作，Group为单位
    MemSetPath_Enable;  //设置通道使能
    M[RA0+MGRP_PATH3] = RD0;//选择PATH3，通道信息在偏址上

    //配置LMT参数
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    RD0 = 0x4;          //数据传送指令
    M[RA6+4*MMU_BASE] = RD0;     //LMT写指令端口
    //配置相关的RAM，128点复数占用512字节空间
    RD0 = DMA_PATH3;
    RD1 = RN_GRAM_BANK_SIZE;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //配置结束

	Sel_SE256FFT;

    //配置DMA_Ctrl参数，包括地址、长度
    RD0 = RA0;//源地址
    send_para(RD0);
    RD0 = RA1;//目标地址
    send_para(RD0);
    call _DMA_ParaCfg_FFT64_Revs;//单目运算配置专用函数

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH3;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_FFTRevs;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    //---------------------------------------------------

//硬件初始化

    //RAM指针设定
    RD0 = RN_FFT_COFF_GRAM_ADDR;
    RA2 = RD0;          //FFT系数地址

    RD3 = 0;            //记录缩放倍数
    RD4 = -1;            //溢出控制  0：不移位
    RD2 = 6;           //分解次数  1024:10  512:9

    Sel_PATH3_FFT;
    //分解循环
L_FFT64_Loop_L0:
    //设置GRAM属性为DMA_Ctrl3操作，Group为单位
    MemSetPath_Enable;         //设置通道使能
    M[RA1+MGRP_PATH3] = RD0;   //选择PATH3，通道信息在偏址上

    //配置4KRAM通道
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    RD0 = DMA_PATH3;
    RD1 = RN_GRAM_BANK_SIZE;
    M[RA1] = RD0;       //逆序后的地址
    M[RA2] = RD0;       //FFT系数地址
M[RA2+RD1] = RD0;
RD1 = RN_GRAM_BANK_SIZE*2;
M[RA2+RD1] = RD0;
RD1 = RN_GRAM_BANK_SIZE*3;
M[RA2+RD1] = RD0;
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数
    send_para(RA2);     //FFT系数地址
    send_para(RA1);     //数据地址
    send_para(RD4);     //是否移位 0：不移位
    call _DMA_ParaCfg_FFT128;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH3;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_FFT;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    //---------------------------------------------------

    //判断并控制溢出风险
    RD4 = 0;
    if(RFlag_OverFlowFFT==0) goto L_FFT64_Loop_L1;
    RD3 ++;
    RD4 = -1;
L_FFT64_Loop_L1:

    //控制分解第次
    FFT_Next_Round;
    RD2 --;
    if(RQ_nZero) goto L_FFT64_Loop_L0;
	Sel_LE256FFT;
    Dis_PATH3_FFT;

    RD0 = RD3;

    pop RA2;
    pop RD4;

    return_autofield(0);


////////////////////////////////////////////////////////
//  函数名称:
//      FFT_Fast128
//  函数功能:
//      128点FFT运算，采用128点专用加速器
//  形参:
//      1.RD0:输入序列指针，高位16bit格式序列
//      2.RD1:输出序列指针，复数格式
//  返回值:
//      RD0:增益系数
//  入口：
//      1.形参1
//      2.RN_FFT_COFF_GRAM_ADDR
//  出口：
//      1.形参2
////////////////////////////////////////////////////////
sub_autofield FFT_Fast128;
    push RD4;
    push RA2;

    RA0 = RD0;
    RA1 = RD1;
    RD0 = FFT128RAM_Addr0;
    RA2 = RD0;

//FFT数据拷贝至专用缓存，同时进行地址逆序
    //--------------------------------------------------
    //设置GRAM属性为DMA_Ctrl1操作，Group为单位
    MemSetPath_Enable;  //设置通道使能
    M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上
	M[RA2+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上
    //配置ALU1参数
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    RD0 = RffC_Add;          //数据传送指令
    M[RA6+0*MMU_BASE] = RD0;     //ALU1写指令端口
    RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1写指令端口
    //配置相关的RAM，512点复数占用2K字节空间
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA2] = RD0;
	RD1 = 1024;
	M[RA2+RD1] = RD0;
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址、长度
    RD0 = RA0;//源地址
    send_para(RD0);
    call _DMA_ParaCfg_FFT128_Write;//单目运算配置专用函数

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_FFT;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    //---------------------------------------------------

    MemSetRAM4K_Enable;;   //Memory 设置使能
	RD0 = DMA_PATH5;
	M[RA2] = RD0;    //                                                               通道选择（FFT模块端）
	RD1 = 1024;
	M[RA2+RD1] = RD0;
	MemSet_Disable;   //设置关闭

	Enable_FFT_Fast128;
	Start_FFT128W;   //FFT开始
	nop; nop;
	Wait_While(RFlag_FFT128End==0);

	//设置通道使能
    MemSetPath_Enable;  
    M[RA1+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上
	M[RA2+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置相关的RAM
    RD0 = DMA_PATH1;
    RD1 = RN_GRAM_BANK_SIZE;
    M[RA1] = RD0;
    M[RA2] = RD0;
	RD1 = 1024;
	M[RA2+RD1] = RD0;
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址、长度
    RD0 = RA1;//目标地址
    send_para(RD0);
    call _DMA_ParaCfg_FFT128_Read;//单目运算配置专用函数

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_FFT;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    //低三位有效，高位置0(在HA350B中增加的优化操作)
    MemSetRAM4K_Enable;
    RD0 = 0b0111;
    RD0 &= FFT128_GAIN;
    RD0 ++;
    MemSet_Disable;
	Disable_FFT_Fast128;
    pop RA2;
    pop RD4;

    Return_autofield(0);




END SEGMENT

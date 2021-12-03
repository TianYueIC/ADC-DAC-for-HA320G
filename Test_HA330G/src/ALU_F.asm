#define _ALU_F_

#include <CPU11.def>
#include <resource_allocation.def>
#include <RN_DSP_Cfg.def>
#include <DMA_ParaCfg.def>
#include <DMA_ALU.def>
#include <ALU.def>
#include <Global.def>

CODE SEGMENT ALU_F;
////////////////////////////////////////////////////////
//  名称:
//      DMA_Trans_AD
//  功能:
//      从ADC缓冲区读取采样点
//  参数:
//      1.RD0:源指针
//      2.RD1:目标指针(out)
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField DMA_Trans_AD;
    // 将AD_Buf连接到PATH1
    // 设置Group与PATH的连接
    RA0 = RD0;
    RA1 = RD1;
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上
    M[RA1+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    // 将AD_Buf0连接到PATH1
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;

    //配置ALU参数
    RD0 = Op32Bit;      //ALU处理位宽选择为32位
    RD0 += RffC_Add;    //加法指令
    M[RA6+0*MMU_BASE] = RD0;     //ALU1写指令端口
    RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1写Const端口
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    send_para(RA0);//源地址0
    send_para(RA1);//目标地址
    RD0 = FL_M2_A4;
    send_para(RD0);
    call _DMA_ParaCfg_AD_Copy;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    Return_AutoField(0);





////////////////////////////////////////////////////////
//  名称:
//      Ram_Clr
//  功能:
//      清除指定的GRAM块
//  参数:
//      1.RA1:指定的GRAM块地址(out)
//      2.RA0:借用的地址，必须指向另一个Group
//      3.RD1:TimerNum值 = (Dword长度*1)+2
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField Ram_Clr;
    RD2 = RD1;

    MemSetPath_Enable;      //源地址设置通道使能
    M[RA0+DMA_PATH1] = RD0;

    MemSetAutoAddr_Enable;  //目标地址设置Auto使能，同时Group通道使能
    RD0 = RA1;              //目标地址
    RF_ShiftR2(RD0);        //Dword 地址
    RF_Not(RD0);            //硬件相位原因要求对地址取反写入
    M[RA1] = RD0;           //设置Auto地址，只能作为目标地址
    MemSet_Disable;         //设置Auto时，必须有此句，产生set_addr信号

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置ALU参数
    RD0 = Op32Bit;      //ALU处理位宽选择为32位
    RD0 += Rf_Const; //Rf_PassFast; //
    M[RA6+0*MMU_BASE] = RD0;     //ALU1写指令端口
    RD0 = 0x1122aabb;            //写入常数（无效操作，可删除，未实验）
    M[RA6+1*MMU_BASE] = RD0;     //ALU1写Const端口（无效操作，可删除，未实验）
    //配置相关的4KRAM
    RD0 = DMA_PATH1;
    M[RA1] = RD0;
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    RD0 = RA0;//源地址
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_Clear;//Auto拷贝配置专用函数

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;

    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    Return_AutoField(0);


////////////////////////////////////////////////////////
//  名称:
//      Dual_Ser_Add32
//  功能:
//      双序列加法运算，32bit运算
//  参数:
//      1.RA0:输入序列1指针，32bit格式序列(out)
//      2.RA1:输入序列2指针，32bit格式序列
//      3.RD0:TimerNum值 = (序列Dword长度*3)+4
//  返回值:
//      1.RD0:无
////////////////////////////////////////////////////////
Sub_AutoField Dual_Ser_Add32;
    RD2 = RD0;
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH1] = RD0;//选择PATH2，通道信息在偏址上
    M[RA1+MGRP_PATH1] = RD0;//选择PATH2，通道信息在偏址上
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置相关的4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;
    //配置ALU参数
    RD0 = Op32Bit;      //ALU处理位宽选择为32位
    RD0 += Rff_Add;
    M[RA6+0*MMU_BASE] = RD0;     //ALU1写指令端口
    RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1写Const端口
    MemSet_Disable;     //配置结束
    //配置DMA_Ctrl参数，包括地址.长度
    send_para(RA0);//源地址0
    send_para(RA1);//源地址1
    send_para(RA0);//目标地址
    send_para(RD2);
    call _DMA_ParaCfg_Rff;
    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    Return_AutoField(0);

////////////////////////////////////////////////////////
//  名称:
//      Dual_Ser_Sub32
//  功能:
//      双序列减法运算，32bit运算
//  参数:
//      1.RA0:输入序列1指针，32bit格式序列
//      2.RA1:输入序列2指针，32bit格式序列
//      3.RD1:输出序列指针，32bit格式序列(out)
//      4.RD0:TimerNum值 = (序列Dword长度*3)+4
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField Dual_Ser_Sub32;
    push RA2;
    RD2 = RD0;
    RA2 = RD1;
    //--------------------------------------------------
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上
    M[RA1+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上
    M[RA2+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置ALU参数
    RD0 = Op32Bit;      //ALU处理位宽选择为32位
    RD0 += Rff_Sub;     //减法指令
    M[RA6+0*MMU_BASE] = RD0;     //ALU1写指令端口
    RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1写Const端口

    //配置相关的4KRAM
    RD0 = DMA_PATH1;
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
    call _DMA_ParaCfg_Rff;//单目运算配置专用函数

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    pop RA2;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      Cal_Single_Shift
//  功能:
//      单序列移位运算，配置可选
//  参数:
//      1.RD0:处理位宽+移位处理 (例:Op32bit+Rf_SftR1)
//      2.RD1:TimerNum值 = (输入序列Dword长度*2)+4
//      3.RA0:输入序列指针(out)
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField Cal_Single_Shift;
    RD3 = RD0;
    RD2 = RD1;
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH2] = RD0;//选择PATH2，通道信息在偏址上

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置相关的4KRAM
    RD0 = DMA_PATH2;
    M[RA0] = RD0;

    //配置ALU参数
    M[RA6+2*MMU_BASE] = RD3;     //ALU1写指令端口
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

    Return_AutoField(0);









////////////////////////////////////////////////////////
//  名称:
//      Add_LMT
//  功能:
//      双序列加法运算（限幅至16bit），32bit运算
//  参数:
//      1.RA0:输入序列1指针，32bit格式序列
//      2.RA1:输入序列2指针，32bit格式序列
//      3.RD1:输出序列指针，32bit格式序列(out)
//      4.RD0:TimerNum值 = (序列Dword长度*3)+4
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField Add_LMT;
    push RA2;
    RD2 = RD0;
    RA2 = RD1;
    //--------------------------------------------------
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH3] = RD0;//选择PATH3，通道信息在偏址上
    M[RA1+MGRP_PATH3] = RD0;//选择PATH3，通道信息在偏址上
    M[RA2+MGRP_PATH3] = RD0;//选择PATH3，通道信息在偏址上

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置相关的4KRAM
    RD0 = DMA_PATH3;
    M[RA0] = RD0;
    M[RA1] = RD0;
    M[RA2] = RD0;

    //配置ALU参数
    RD0 = 0;
    M[RA6+4*MMU_BASE] = RD0;     //ALU3写指令端口
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    RD0 = RA0;//源地址0
    send_para(RD0);
    RD0 = RA1;//源地址1
    send_para(RD0);
    RD0 = RA2;//目标地址
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_Rff;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH3;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    pop RA2;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      Sub_LMT
//  功能:
//      双序列减法运算（限幅至16bit），32bit运算
//  参数:
//      1.RA0:输入序列1指针，32bit格式序列
//      2.RA1:输入序列2指针，32bit格式序列
//      3.RD1:输出序列指针，32bit格式序列(out)
//      4.RD0:TimerNum值 = (序列Dword长度*3)+4
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField Sub_LMT;
    push RA2;
    RD2 = RD0;
    RA2 = RD1;
    //--------------------------------------------------
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH3] = RD0;//选择PATH3，通道信息在偏址上
    M[RA1+MGRP_PATH3] = RD0;//选择PATH3，通道信息在偏址上
    M[RA2+MGRP_PATH3] = RD0;//选择PATH3，通道信息在偏址上

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置相关的4KRAM
    RD0 = DMA_PATH3;
    M[RA0] = RD0;
    M[RA1] = RD0;
    M[RA2] = RD0;

    //配置ALU参数
    RD0 = 1;
    M[RA6+4*MMU_BASE] = RD0;     //ALU3写指令端口
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    RD0 = RA0;//源地址0
    send_para(RD0);
    RD0 = RA1;//源地址1
    send_para(RD0);
    RD0 = RA2;//目标地址
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_Rff;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH3;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    pop RA2;
    Return_AutoField(0);




////////////////////////////////////////////////////////
//  名称:
//      DMA_Trans
//  功能:
//      DMA传输数据
//  参数:
//      1.RA0:源地址
//      2.RA1:目标地址(out)
//      3.RD0:数据长度对应的TimerNum值，对应(Dword长度*2)+4
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField DMA_Trans;
    // 将AD_Buf连接到PATH1
    // 设置Group与PATH的连接
    RD2 = RD0;
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上
    M[RA1+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    // 将AD_Buf0连接到PATH1
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;

    //配置ALU参数
    RD0 = Op32Bit;      //ALU处理位宽选择为32位
    RD0 += RffC_Add;    //加法指令
    M[RA6+0*MMU_BASE] = RD0;     //ALU1写指令端口
    RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1写Const端口
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    send_para(RA0);//源地址0
    send_para(RA1);//目标地址
    send_para(RD2);
    call _DMA_ParaCfg_RffC;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
//Set_LevelL8;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
//Set_LevelH8;

    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      Cal_Single_Add_Const
//  功能:
//      单序列加常量
//  参数:
//      1.RD1:Const
//      2.RA0:源地址
//      3.RA1:目标地址(out)
//      4.RD0:数据长度对应的TimerNum值，对应(Dword长度*2)+4
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField Cal_Single_Add_Const;
    // 将AD_Buf连接到PATH1
    // 设置Group与PATH的连接
    RD2 = RD0;
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上
    M[RA1+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    // 将AD_Buf0连接到PATH1
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;

    //配置ALU参数
    RD0 = Op16Bit;      //ALU处理位宽选择为16位
    RD0 += RffC_Add;    //加法指令
    M[RA6+0*MMU_BASE] = RD0;     //ALU1写指令端口
    RD0 = RD1;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1写Const端口
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    send_para(RA0);//源地址0
    send_para(RA1);//目标地址
    send_para(RD2);
    call _DMA_ParaCfg_RffC;

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
//Set_LevelL8;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
//Set_LevelH8;

    Return_AutoField(0);

////////////////////////////////////////////////////////
//  函数名称:
//      DMA_Trans_PATH1
//  函数功能:
//      DMA传输数据
//  入口参数:
//      RA0:源地址
//      RA1:目标地址
//      RD0:数据长度对应的TimerNum值，对应(Dword长度*2)+4
//  出口参数:
//      无
////////////////////////////////////////////////////////
sub_autofield DMA_Trans_PATH1;
    // 将AD_Buf连接到PATH1
    // 设置Group与PATH的连接
    RD2 = RD0;
    MemSetPath_Enable;  //设置Group通道使能
    M[RA0+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上
    M[RA1+MGRP_PATH1] = RD0;//选择PATH1，通道信息在偏址上

    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    // 将AD_Buf0连接到PATH1
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;

    //配置ALU参数
    RD0 = Op32Bit;      //ALU处理位宽选择为32位
    RD0 += RffC_Add;    //加法指令
    M[RA6+0*MMU_BASE] = RD0;     //ALU1写指令端口
    RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1写Const端口
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址、长度
    send_para(RA0);//源地址0
    send_para(RA1);//目标地址
    send_para(RD2);
    //call _DMA_ParaCfg_AD_Copy;
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


END SEGMENT

#define _CPU11_F_

#include <CPU11.def>

//====================================================================
//  系统常量定义(汇编语言使用RA6寻址的常量在此定义)
//====================================================================
//DATA SEGMENT Const_RA6 = RN_Const_StartAddr;
//    DEFINEWORD
//    0x0000;
//END SEGMENT

CODE SEGMENT CPU09_F;

Sub _Goto_IPaddRD1;

Sub Guaiyi;
    M[RSP] += RD1;
    Return(0);

Sub GuaiyiA;
    RD1 --;
    M[RSP] = RD1;
    Return(0);


//===============================
//函数名：_Delay
//功  能：延时
//入  口：RD0:延迟的指令周期数
//出  口：无
//2012/3/16 13:46:52
//===============================
Sub_AutoField _Delay;
    RD2 = RD0;
    goto L_Delay_RD2_Begin;

//===============================
//函数名：_Delay_RD2
//功  能：延时
//入  口：RD2:延迟的指令周期数
//出  口：无
//说明：RD0 RD1都不破坏，不破坏任何现场
//===============================
Sub_AutoField _Delay_RD2;

L_Delay_RD2_Begin:
    RF_ShiftR2(RD2);
    RF_ShiftR1(RD2);
    if(RQ_Zero) goto L_Delay_RD2_End;

L_Delay_RD2_Loop:
    nop;nop;nop;nop;nop;
    RD2 --;
    if(RQ_nZero) goto L_Delay_RD2_Loop;

L_Delay_RD2_End:
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////////////////////////
////  名称:
////    _Verify_Sum_16_Reg:
////  功能:
////    计算累加和校验码；
////  参数:
////    RD0:Length：数据长度，以Word（16bit）为单位
////    RD1:数据指针首址
////  返回值:
////    RD0: 校验码
////////////////////////////////////////////////////////////////////////////
//Sub_AutoField _Verify_Sum_16_Reg;
//
//    //Set_ConstInt_Dis;
//
//    RA0 = RD1;    //数据指针首址
//    RD2 = RD0;    //Length
//
//    RD3 = 0x12345678;
//    RD1 = RD3;
//Verify_Sum_16_Reg_L:
//    RD0 = M[RA0];
//    RD1 += RD0;
//    RA0 += 2;
//    RD3 += RD1;
//    RD2 --;
//    if(RQ_nZero) goto Verify_Sum_16_Reg_L;
//    RD0 = RD3;
//
//    //Set_ConstInt_En;
//
//    Return_AutoField(0*MMU_BASE);



//////////////////////////////////////////////////////////
////名称：
////      _Aone_Hash_no_sbox_Reg
////功能：
////      指定长度简单列散
////入口：
////     RD0：长度（单位：Dword，最小值1）
////     RA0：数据首址
////出口：
////     RD0：32位Hash值
//////////////////////////////////////////////////////////
//Sub_AutoField _Aone_Hash_no_sbox_Reg;
//    RD2 = RD0;                                          // 长度
//    RD3 = 0x616f6e65;                                   // Hash初值
//
//L_Aone_Hash_no_sbox_Reg_Loop:
//    RD0 = M[RA0++];
//    call _Aone_Hash_no_sbox_1Dword_Reg;
//    RD3 ^= RD0;
//    RD2 --;
//    if(RQ_nZero) goto L_Aone_Hash_no_sbox_Reg_Loop;
//
//    RD0 = RD3;
//    Return_AutoField(0*MMU_BASE);



/////////////////////////////////////////
////名称：
////      _Aone_Hash_no_sbox_1Dword_Reg
////功能：
////      简单列散
////入口：
////      RD0
////出口：
////      RD0
/////////////////////////////////////////
//Sub_AutoField _Aone_Hash_no_sbox_1Dword_Reg;
//
//    RD2 = 0xff;
//    RD2 += RD0;
//
//    RD3 = 4;
//L_Aone_Hash_no_sbox_1Dword_Reg_Loop:
//    RF_Disorder(RD2);
//    RD2 ^= RD0;
//    RF_Reverse(RD0);
//    RD0 += RD2;
//    RD3 --;
//    if(RQ_nZero) goto L_Aone_Hash_no_sbox_1Dword_Reg_Loop;
//
//    Return_AutoField(0*MMU_BASE);

/////////////////////////////////////////
////函数名：_Aone_Hash
////功能：32位简单列散
////入口：RD0
////出口：
////    RD0
/////////////////////////////////////////
//Sub_AutoField _Aone_Hash;
//    AES_En;
//
//    AES_Port_Sbox = RD0;
//    RD0 = AES_RDSbox;
//    RD2 = RD0;
//    RF_Disorder(RD0);
//    RD0 ^= RD2;
//
//    AES_Port_Sbox = RD0;
//    RD0 = AES_RDSbox;
//    RD2 = RD0;
//    RF_Reverse(RD0);
//    RD0 += RD2;
//
//    AES_Dis;
//Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////////////////
////  模块名称：
////    _Push_Field;
////  模块功能:
////    保留现场:
////  模块入口:
////    Null
////  模块出口:
////    Null
////  注释：  RSP 增加9*MMU_BASE
///////////////////////////////////////////////////////////////////
//Sub_AutoField _Push_Field;
//    push RA0;
//    push RA1;
//    push RA2;
//    push RD2;
//    push RD3;
//    push RD4;
//    push RD5;
//    push RD6;
//    push RD7;
//    Return_AutoField(0);
//
////////////////////////////////////////////////////////////////////
////  模块名称：
////    _Pop_Field;
////  模块功能:
////    恢复现场;
////  模块入口:
////    Null
////  模块出口:
////    Null
///////////////////////////////////////////////////////////////////
//Sub _Pop_Field;
//
//    RD7 = M[RSP+1*MMU_BASE];
//    RD6 = M[RSP+2*MMU_BASE];
//    RD5 = M[RSP+3*MMU_BASE];
//    RD4 = M[RSP+4*MMU_BASE];
//    RD3 = M[RSP+5*MMU_BASE];
//    RD2 = M[RSP+6*MMU_BASE];
//    RA2 = M[RSP+7*MMU_BASE];
//    RA1 = M[RSP+8*MMU_BASE];
//    RA0 = M[RSP+9*MMU_BASE];
//
//    Return(9*MMU_BASE);



////////////////////////////////////////////////////////////////////////////
////  名称:
////    _Set_IntEn4DrvProg:
////  功能:
////    驱动程序开放中断入口
////  参数:
////    无
////  返回值:
////    无
////////////////////////////////////////////////////////////////////////////
//Sub _Set_IntEn4DrvProg;
//    Set_IntASM_En;
//    nop; nop; nop;
//    Set_IntASM_Dis;
//    Return(0*MMU_BASE);

//打开中断模板程序，其中“FuncName”为当前函数名
/*
    if(RFlag_NoInt) goto _FuncName_NoInt;
    call _Set_IntEn4DrvProg;
_FuncName_NoInt:
*/



//////////////////////////////////////////////////////////
////功能：
////      定长拷贝内存单元
////入口：
////      长度，单位：Dword
////      源地址
////      目标地址
////返回：
////      目标地址
//////////////////////////////////////////////////////////
//Sub_AutoField _MemcpyDword;
//
//    RD1 = M[RSP+2*MMU_BASE];            // 长度
//    if(RQ_Zero) goto _MemcpyDword_End;
//    RA1 = M[RSP+0*MMU_BASE];            // 目标地址
//    RA0 = M[RSP+1*MMU_BASE];            // 源地址
//
//_MemcpyDword_Loop:
//    RD0 = M[RA0++];
//    M[RA1++] = RD0;
//    RD1 --;
//    if(RQ_nZero) goto _MemcpyDword_Loop;
//
//_MemcpyDword_End:
//    Return_AutoField(3*MMU_BASE);



//////////////////////////////////////////////////////////
////功能：
////      以Word为单位，定长拷贝内存单元
////入口：
////      长度，单位：Word
////      源地址
////      目标地址
////返回：
////      目标地址
//////////////////////////////////////////////////////////
//Sub_AutoField _MemcpyWord;
//
//    RD1 = M[RSP+2*MMU_BASE];            // 长度
//    if(RQ_Zero) goto _MemcpyWord_End;
//    RA1 = M[RSP+0*MMU_BASE];            // 目标地址
//    RA0 = M[RSP+1*MMU_BASE];            // 源地址
//
//_MemcpyWord_Loop:
//    uWord_RD0 = M[RA0];
//    M[RA1] = uWord_RD0;
//    RA0 += 2;
//    RA1 += 2;
//    RD1 --;
//    if(RQ_nZero) goto _MemcpyWord_Loop;
//
//_MemcpyWord_End:
//    Return_AutoField(3*MMU_BASE);


//////////////////////////////////////////////////////////
////名称：
////      _MemcmpDword
////功能：
////      定长比较内存单元
////入口：
////      长度，单位：Dword
////      地址1
////      地址2
////返回：
////      目标地址
//////////////////////////////////////////////////////////
//Sub_AutoField _MemcmpDword;
//
//    RD1 = M[RSP+2*MMU_BASE];            // 长度
//    if(RQ_Zero) goto _MemcmpDword_End;
//
//    RA1 = M[RSP+0*MMU_BASE];            // 地址2
//    RA0 = M[RSP+1*MMU_BASE];            // 地址1
//
//_MemcmpDword_Loop:
//    RD0 = M[RA0++];
//    RD0 ^= M[RA1++];
//    if(RD0_nZero) goto _MemcmpDword_End;
//    RD1 --;
//    if(RQ_nZero) goto _MemcmpDword_Loop;
//
//_MemcmpDword_End:
//    Return_AutoField(3*MMU_BASE);




//////////////////////////////////////////////////////////////////////////
//  名称:
//      _Timer_Number
//  功能:
//      计算计数器的预置值；
//  参数:
//      1.分频数（指令频率的分频）
//  返回值:
//      RD0: 预置值
//  注释:
//      破坏 RD4\5\6\7
//2009-4-24 14:07:03
//////////////////////////////////////////////////////////////////////////
Sub_AutoField _Timer_Number;
    push RD8;
    push RD9;
    push RD10;
    push RD11;

    //RD4:乘法进位
    //RD5:乘数Y
    //RD6:一次乘法循环次数
    //RD7:计数器初值
    //RD8:模数
    //RD9:计数器级数
    //RD10:幂长度
    //RD11:计数长度

    //与计数器硬件结构有关的直接赋值
    //模数：本原多项式G(x) = x**31 + x**3 + 1;从x**3看起，即为0x90000001，
    //单反馈时可以逆序看
    RD8 = 0x90000001;
    RD4 = 0x80000000;             //乘法进位即模数的最高位
    RD9 = 31;                     //计数器级数
    RD7 = 0x7fffffff;             //计数器初值为全1

//将计数长度移到高位
    RD0 = M[RSP+4*MMU_BASE];
    RD11 = RD0;
    RF_Log(RD0);
    RD0 ++;
    RD10 = RD0;                     //幂长度

    RD0 = RD11;
_Counter_Convert_L0:
    RD0 += RD0;
    if(RQ_nCarry) goto _Counter_Convert_L0;
    RD11 = RD0;

    //结果置初值=2
    RD2 = 0x02;
_Counter_Convert_L3:
    RD10 --;
    if(RQ_Zero) goto _Counter_Convert_L5;
    RD1 = RD2;
    RD5 = RD1;
    RD2 = 0;
    RD3 = 1;
    RD0 = RD9;
    RD6 = RD0;

_Counter_Convert_L3A:
    //计算平方
    //RD1:乘数X   RD5:乘数Y   RD2:积   RD3:扫描位
    RD0 = RD3;
    RD0 &= RD5;
    if(RD0_Zero) goto _Counter_Convert_L4;
    RD2 ^= RD1;
_Counter_Convert_L4:
    RD6 --;
    if(RQ_Zero) goto _Counter_Convert_L3B;
    RD3 <<;
    RD1 <<;
    RD0 = RD1;
    RD0 &= RD4;
    if(RD0_Zero) goto _Counter_Convert_L3A;
    RD1 ^= RD8;
    goto _Counter_Convert_L3A;

_Counter_Convert_L3B:
    //看计数长度
    RD0 = RD11;
    RD11 += RD0;
    if(RQ_nCarry) goto _Counter_Convert_L3;
    //计数长度移出为1，结果乘2
    RD2 <<;
    RD0 = RD2;
    RD0 &= RD4;
    if(RD0_Zero) goto _Counter_Convert_L3;
    RD1 = RD8;
    RD2 ^= RD1;
    goto _Counter_Convert_L3;

_Counter_Convert_L5:
    //计算初值乘RD2
    //RD1:乘数X   RD5:乘数Y   RD2:积   RD3:扫描位
    RD1 = RD2;
    RD5 = RD1;
    RD1 = RD7;
    RD2 = 0;
    RD3 = 1;
    RD0 = RD9;
    RD6 = RD0;
_Counter_Convert_L5A:
    RD0 = RD3;
    RD0 &= RD5;
    if(RD0_Zero) goto _Counter_Convert_L5B;
    RD2 ^= RD1;
_Counter_Convert_L5B:
    RD6 --;
    if(RQ_Zero) goto _Counter_Convert_L6;
    RD3 <<;
    RD1 <<;
    RD0 = RD1;
    RD0 &= RD4;
    if(RD0_Zero) goto _Counter_Convert_L5A;
    RD1 ^= RD8;
    goto _Counter_Convert_L5A;

    //与计数器硬件结构有关的直接赋值
_Counter_Convert_L6:
    RF_RotateL4(RD2);
    RF_RotateR1(RD2);
    RD1 = RD2;
    RF_RotateL1(RD1);
    RD0 = 7;
    RD1 &= RD0;

    RD0 = 0x7ffffff8;
    RD0 &= RD2;
    RD0 += RD1;      //结果
    RF_Not(RD0);

    pop RD11;
    pop RD10;
    pop RD9;
    pop RD8;
    Return_AutoField(1*MMU_BASE);



/////////////////////////////////////////////////////////
////  名称:
////      _Debug_Memory_File:
////  功能:
////      在文件中记录Memory的数据；
////  参数:
////      1.ID号（Debug识别）
////      2.存储器地址
////      3.存储器长度(DWord为单位)
////  返回值:
////      无
/////////////////////////////////////////////////////////
//Sub _Debug_Memory_File;
//    push RD0;
//    push RD1;
//    push RA0;
//    //M[RSP+4*MMU_BASE]:存储器长度
//    //M[RSP+5*MMU_BASE]:存储器地址
//    //M[RSP+6*MMU_BASE]:ID号
//
//    RD1 = M[RSP+4*MMU_BASE];
//    RA0 = M[RSP+5*MMU_BASE];
//    
//    Debug_Start;
//    nop;
//    RD0 = M[RSP+6*MMU_BASE];    //Read Flag
//_Debug_Multi_L0:
//    RD0 = M[RA0++];             //Read Data
//
//
//    RD1 --;
//    if(RQ_nZero) goto _Debug_Multi_L0;
//    Debug_End;
//    
//    pop RA0;
//    pop RD1;
//    pop RD0;
//    Return(3*MMU_BASE);



/////////////////////////////////////////////////////////
////  名称:
////      _Debug_Memory_File:
////  功能:
////      在文件中记录Memory的数据；
////  参数:
////      1.ID号（Debug识别）
////      2.存储器地址
////      3.存储器长度(DWord为单位)
////  返回值:
////      无
/////////////////////////////////////////////////////////
//Sub _Debug_Memory_File_Bank;
//    push RD0;
//    push RD1;
//    push RA0;
//    //M[RSP+4*MMU_BASE]:存储器长度
//    //M[RSP+5*MMU_BASE]:存储器地址
//    //M[RSP+6*MMU_BASE]:ID号
//
//    RD1 = M[RSP+4*MMU_BASE];
//    RA0 = M[RSP+5*MMU_BASE];
//    RD0 = M[RSP+6*MMU_BASE];    //Read Flag
//    
//    if(RD0_Zero) goto L_Debug_Memory_File_Bank_0;
//    RD0 --;
//    if(RD0_Zero) goto L_Debug_Memory_File_Bank_1;
//    RD0 --;
//    if(RD0_Zero) goto L_Debug_Memory_File_Bank_2;
//    RD0 --;
//    if(RD0_Zero) goto L_Debug_Memory_File_Bank_3;
//    RD0 --;
//    if(RD0_Zero) goto L_Debug_Memory_File_Bank_4;
//    RD0 --;
//    if(RD0_Zero) goto L_Debug_Memory_File_Bank_5;
//    RD0 --;
//    if(RD0_Zero) goto L_Debug_Memory_File_Bank_6;
//    RD0 --;
//    if(RD0_Zero) goto L_Debug_Memory_File_Bank_7;
//    
//L_Debug_Memory_File_Bank_0:
//	Set_LevelL0;
//	goto L_Debug_Memory_File_Bank_Start;
//L_Debug_Memory_File_Bank_1:    
//	Set_LevelL1;
//	goto L_Debug_Memory_File_Bank_Start;
//L_Debug_Memory_File_Bank_2:  
//	Set_LevelL2;
//	goto L_Debug_Memory_File_Bank_Start;  
//L_Debug_Memory_File_Bank_3:    
//	Set_LevelL3;
//	goto L_Debug_Memory_File_Bank_Start;
//L_Debug_Memory_File_Bank_4:    
//	Set_LevelL4;
//	goto L_Debug_Memory_File_Bank_Start;
//L_Debug_Memory_File_Bank_5:    
//	Set_LevelL5;
//	goto L_Debug_Memory_File_Bank_Start;
//L_Debug_Memory_File_Bank_6:    
//	Set_LevelL6;
//	goto L_Debug_Memory_File_Bank_Start;
//L_Debug_Memory_File_Bank_7:
//	Set_LevelL7;
//
//L_Debug_Memory_File_Bank_Start:
//	
//L_Debug_Memory_File_Bank_L0:
//    RD0 = M[RA0++];             //Read Data
//    RD1 --;
//    if(RQ_nZero) goto L_Debug_Memory_File_Bank_L0;
//
//    Set_LevelH0;
//    Set_LevelH1;
//    Set_LevelH2;
//    Set_LevelH3;
//    Set_LevelH4;
//    Set_LevelH5;
//    Set_LevelH6;    
//	Set_LevelH7;
//    
//    pop RA0;
//    pop RD1;
//    pop RD0;
//    Return(3*MMU_BASE);
    


/////////////////////////////////////////////////////////
////  名称:
////      _Debug_Memory_File_DWAddr:
////  功能:
////      在文件中记录Memory的数据，
////      存储器地址的硬件接法为Dword，例:RA0+=1表示地址增加一个Dword；
////  参数:
////      1.ID号（Debug识别）
////      2.存储器地址(地址为Dword地址)
////      3.存储器长度(DWord为单位)
////  返回值:
////      无
/////////////////////////////////////////////////////////
//Sub _Debug_Memory_File_DWAddr;
//    push RD0;
//    push RD1;
//    push RA0;
//    //M[RSP+4*MMU_BASE]:存储器长度
//    //M[RSP+5*MMU_BASE]:存储器地址
//    //M[RSP+6*MMU_BASE]:ID号
//
//    RD1 = M[RSP+4*MMU_BASE];
//    RA0 = M[RSP+5*MMU_BASE];
//    
//    Debug_Start;
//    nop;
//    RD0 = M[RSP+6*MMU_BASE];    //Read Flag
//_Debug_Memory_File_DWAddr_L0:
//    RD0 = M[RA0];             //Read Data
//    RA0 += 1;
//    RD1 --;
//    if(RQ_nZero) goto _Debug_Memory_File_DWAddr_L0;
//    Debug_End;
//    
//    pop RA0;
//    pop RD1;
//    pop RD0;
//    Return(3*MMU_BASE);
//

//////////////////////////////////////////////////////////////////////////
//  函数名称:
//    _Verify_Sum_16_Reg:
//  函数功能:
//    计算累加和校验码；
//  函数入口:
//    RD0:Length：数据长度，以Word（16bit）为单位
//    RD1:数据指针首址
//  函数出口:
//    RD0: 校验码
//////////////////////////////////////////////////////////////////////////


END SEGMENT

#define _SOC_COMMON_F_

#include <CPU11.def>
#include <resource_allocation.def>
#include <Barrel.def>

CODE SEGMENT SOC_COMMON_F;
////////////////////////////////////////////////////////
//  名称:
//      _Rf_ShiftL_Reg
//  功能:
//      RD0左移RD1次，右补0
//  参数:
//      1.RD0：被移动的数
//      2.RD1：要移的次数
//  返回值:
//      1.RD0: 移位结果
////////////////////////////////////////////////////////
Sub_AutoField _Rf_ShiftL_Reg;
    RD2 = RD0;
    RD0 = 0x1F;
    RF_Not(RD0);
    RD0 &= RD1;
    if(RD0_nZero) goto L_Rf_ShiftL_Reg_End0;
    RD0 = BRL_SFT + BRL_L;
    RD0 += RD1;
      
    Barrel0_Ctrl = RD0;
    Barrel0_Op(RD2);

    RD0 = RD2;
    Return_AutoField(0);
L_Rf_ShiftL_Reg_End0:
    RD0 = 0;
    Return_AutoField(0);
    


////////////////////////////////////////////////////////
//  名称:
//      _Rf_ShiftR_Reg
//  功能:
//      RD0右移RD1次，左补0
//  参数:
//      1.RD0：被移动的数
//      2.RD1：要移的次数
//  返回值:
//      1.RD0: 移位结果
////////////////////////////////////////////////////////
Sub_AutoField _Rf_ShiftR_Reg;
	RD2 = RD0;
    RD0 = 0x1F;
    RF_Not(RD0);
    RD0 &= RD1;
    if(RD0_nZero) goto L_Rf_ShiftR_Reg_End0;
    RD0 = BRL_SFT + BRL_R;
    RD0 += RD1;
    Barrel0_Ctrl = RD0;
    Barrel0_Op(RD2);
    RD0 = RD2;
    Return_AutoField(0);
L_Rf_ShiftR_Reg_End0:
    RD0 = 0;
    Return_AutoField (0);



////////////////////////////////////////////////////////
//  名称:
//      _Rf_ShiftR_Signed_Reg
//  功能:
//      RD0右移RD1次，左补符号位
//  参数:
//      1.RD0：被移动的数
//      2.RD1：要移的次数
//  返回值:
//      1.RD0: 移位结果
////////////////////////////////////////////////////////
Sub_AutoField _Rf_ShiftR_Signed_Reg;
	RD2 = RD0;
	//RF_Abs(RD0);		
	call _Rf_ShiftR_Reg;
	RD1 = 1;
	RF_RotateR1(RD1);
	RD1 &= RD2;
	if(RQ_nZero) goto L_Rf_ShiftR_Signed_Reg_N;
	Return_AutoField(0);
	
L_Rf_ShiftR_Signed_Reg_N:
	RD3 = RD0;
	RF_Log(RD0);
	RD0 ++;
	RF_Exp(RD0);
	RD0 --;
	RF_Not(RD0);
	RD0 += RD3;
	Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      _Rf_ShiftL
//  功能:
//      RD0左移RD1次，右补0
//  参数:
//      1.RD0：被移动的数
//      2.RD1：要移的次数
//  返回值:
//      1.RD0: 移位结果
////////////////////////////////////////////////////////
Sub_AutoField _Rf_ShiftL;

    RD1 -= 8;
    if(RQ_Borrow) goto _ShiftL_Little_8;
    RD1 -= 8;
    if(RQ_Borrow) goto _ShiftL_Little_16;
    RD1 -= 8;
    if(RQ_Borrow) goto _ShiftL_Little_24;
    RD1 -= 8;
    RF_GetL8(RD0);
    RF_RotateL24(RD0);
    goto _ShiftL_Little_8;

_ShiftL_Little_24:
    RF_GetL16(RD0);
    RF_RotateL16(RD0);
    goto _ShiftL_Little_8;

_ShiftL_Little_16:
    RF_RotateL8(RD0);
    RD0_CLRBYTEL8;

_ShiftL_Little_8:
    RD1 += 8;
_ShiftL_Little_8_loop:
    if(RQ_Zero) goto _ShiftL_End;
    RF_ShiftL1(RD0);
    RD1 --;
    if(RQ_nZero) goto _ShiftL_Little_8_loop;

_ShiftL_End:
    Return_AutoField (0);



////////////////////////////////////////////////////////
//  名称:
//      _Rf_ShiftR
//  功能:
//      RD0右移RD1次，左补0
//  参数:
//      1.RD0：被移动的数
//      2.RD1：要移的次数
//  返回值:
//      1.RD0: 移位结果
////////////////////////////////////////////////////////
Sub_AutoField _Rf_ShiftR;
//  功能:  RD0右移RD1次;
//  入口:  RD0，RD1;
//  出口:  RD0;

    RD1 -= 8;
    if(RQ_Borrow) goto _ShiftR_Little_8;
    RD1 -= 8;
    if(RQ_Borrow) goto _ShiftR_Little_16;
    RD1 -= 8;
    if(RQ_Borrow) goto _ShiftR_Little_24;
    RD1 -= 8;
    RF_GetH8(RD0);
    goto _ShiftR_Little_8;

_ShiftR_Little_24:
    RF_GetH16(RD0);
    goto _ShiftR_Little_8;

_ShiftR_Little_16:
    RF_RotateR8(RD0);
    RD0_CLRBYTEH8;

_ShiftR_Little_8:
    RD1 += 8;
_ShiftR_Little_8_loop:
    if(RQ_Zero) goto _ShiftR_End;
    RF_ShiftR1(RD0);
    RD1 --;
    if(RQ_nZero) goto _ShiftR_Little_8_loop;

_ShiftR_End:
    Return_AutoField (0);



////////////////////////////////////////////////////////
//  名称:
//      _Rf_ShiftR_Signed
//  功能:
//      RD0右移RD1次，左补符号位
//  参数:
//      1.RD0：被移动的数
//      2.RD1：要移的次数
//  返回值:
//      1.RD0: 移位结果
////////////////////////////////////////////////////////
Sub_AutoField _Rf_ShiftR_Signed;

    RD2 = 0;
    if(RD0_Bit31==0) goto _ShiftR_Signed_L1;
    RD2 = 1;                                      //负数标志

_ShiftR_Signed_L1:
    RD1 -= 8;
    if(RQ_Borrow) goto _ShiftR_Signed_Little_8;
    RD1 -= 8;
    if(RQ_Borrow) goto _ShiftR_Signed_Little_16;
    RD1 -= 8;
    if(RQ_Borrow) goto _ShiftR_Signed_Little_24;
    RD1 -= 8;
    RF_GetH8(RD0);
    RD2 += 0;
    if(RQ_Zero) goto _ShiftR_Signed_Little_8;
    RD0_SetByteH24;
    goto _ShiftR_Signed_Little_8;

_ShiftR_Signed_Little_24:
    RF_GetH16(RD0);
    RD2 += 0;
    if(RQ_Zero) goto _ShiftR_Signed_Little_8;
    RD0_SetByteH16;
    goto _ShiftR_Signed_Little_8;

_ShiftR_Signed_Little_16:
    RF_RotateR8(RD0);
    RD0_CLRBYTEH8;
    RD2 += 0;
    if(RQ_Zero) goto _ShiftR_Signed_Little_8;
    RD0_SetByteH8;
    goto _ShiftR_Signed_Little_8;

_ShiftR_Signed_Little_8:
    RD1 += 8;
    if(RQ_Zero) goto _ShiftR_Signed_End;

_ShiftR_Signed_Little_8_loop:
    RF_ShiftR1(RD0);
    RD2 += 0;
    if(RQ_Zero) goto _ShiftR_Signed_Little_8_loop_in;
    RD0_SetBit31;

_ShiftR_Signed_Little_8_loop_in:
    RD1 --;
    if(RQ_nZero) goto _ShiftR_Signed_Little_8_loop;

_ShiftR_Signed_End:
    Return_AutoField (0);


/////////////////////////////////////////////////////////////
//  模块名称: _Ru_Multi;
//  模块功能: 无符号乘法
//    计算[zh,zl]=x*y; x,y,zh,zl均为32比特的整数,zh,zl分别
//    为结果的高部.低部;
//  模块入口:
//    RD0:乘数x;
//    RD1:乘数y;
//  模块出口:
//    RD0:zl-乘积低部;
//    RD1:zh-乘积高部;
//2012/3/20 11:23:40
////////////////////////////////////////////////////////////
Sub_AutoField _Ru_Multi;

    RD2 = 0;                    // Sum_L
    RD3 = 0;                    // Sum_H

    if(RD0==0) goto _Ru_Multi_Reg_End;  // 乘数x
    RA0 = RD1;                          // 乘数y
    if(RQ==0) goto _Ru_Multi_Reg_End;
    RD1 -= RD0;                         // 若y比x大，交换x和y
    if(RQ<=0) goto _Ru_Multi_Reg_L0;
    RD1 = RA0;
    RA0 = RD0;
    RD0 = RD1;

_Ru_Multi_Reg_L0:
    RD1 = 0;                    // RD1 = X_H=0

_Ru_Multi_Reg_L1:
    RA0 += 0;
    if(RQ_Bit0==0) goto _Ru_Multi_Reg_L2;
    RD2 += RD0;
    RD3 ^+= RD1;

_Ru_Multi_Reg_L2:
    RD0 += RD0;
    RD1 ^+= RD1;
    RF_ShiftR1(RA0);
    if(RQ!=0) goto _Ru_Multi_Reg_L1;

_Ru_Multi_Reg_End:
    RD0 = RD2;                  // Sum_L
    RD1 = RD3;                  // Sum_H

    Return_AutoField(0);



/////////////////////////////////////////////////////////////
//  模块名称: _Rs_Multi;
//  模块功能: 有符号乘法
//    计算[zh,zl]=x*y; x,y,zh,zl均为32比特的整数,zh,zl分别
//    为结果的高部.低部;
//  模块入口:
//    RD0:被乘数x;
//    RD1:乘数y;
//  模块出口:
//    RD0:zl-乘积低部;
//    RD1:zh-乘积高部;
//2012/3/20 11:23:59
////////////////////////////////////////////////////////////
Sub_AutoField _Rs_Multi;
	Multi64_X = RD0;
	Multi64_Y = RD1;
	nop;nop;nop;
	RD0 = Multi64_XYL;
	RD1 = Multi64_XYH;
    Return_AutoField(0);



///////////////////////////////////////
//函数名：_Ru_Div
//功能：求整除(快速算法)
//入口：
//    RD1:除数
//    RD0:被除数
//出口：
//    RD0:商
//    RD1:余数
//2010-6-22 9:52:01
///////////////////////////////////////
Sub_AutoField _Ru_Div;

    //RD2:被除数
    //RD3:除数
    //RA0:除数左移次数

    RD3 = RD1;
    if(RQ_nZero) goto _Ru_Div_Reg_L0;       //判除数是否为零
    RF_Not(RD1);                            //商与余数为全f
    RD0 = RD1;
    goto _Ru_Div_Reg_End;

_Ru_Div_Reg_L0:
    if(RD0_nZero) goto _Ru_Div_Reg_L1;      //判被除数是否为零
    RD1 = RD0;
    goto _Ru_Div_Reg_End;

_Ru_Div_Reg_L1:
    RD2 = RD0;
    RF_Log(RD1);
    RF_Log(RD0);
    RD0 -= RD1;                             //被除数与除数的位差
    if(RD0>=0) goto _Ru_Div_Reg_L2;
    RD0 = 0;                                //被除数小于除数
    RD1 = RD2;
    goto _Ru_Div_Reg_End;

_Ru_Div_Reg_L2:
    RA0 = 0;
    RD1 = 8;
_Ru_Div_Reg_L2A:
    RD0 -= RD1;
    if(RD0<0) goto _Ru_Div_Reg_L3;
    RA0 += RD1;
    RF_RotateL8(RD3);
    goto _Ru_Div_Reg_L2A;
_Ru_Div_Reg_L3:
    RD0 += RD1;
    if(RD0_Zero) goto _Ru_Div_Reg_L4;
_Ru_Div_Reg_L3A:
    RA0 += 1;
    RF_ShiftL1(RD3);
    RD0 --;
    if(RD0_nZero) goto _Ru_Div_Reg_L3A;
_Ru_Div_Reg_L4:
    RA0 += 1;
    RD0 = 0;                                //商
    RD1 = RD2;
_Ru_Div_Reg_L4A:
    RD1 -= RD3;
    if(RQ<0) goto _Ru_Div_Reg_L5;
    RD0 ++;
    goto _Ru_Div_Reg_L6;
_Ru_Div_Reg_L5:
    RD1 += RD3;
_Ru_Div_Reg_L6:
    RA0 -= 1;
    if(RQ_Zero) goto _Ru_Div_Reg_End;
    RF_RotateR1(RD3);
    RF_ShiftL1(RD0);
    goto _Ru_Div_Reg_L4A;

_Ru_Div_Reg_End:
    Return_AutoField(0);



///////////////////////////////////////
//函数名：_Ru_Mod
//功能：求余数
//入口：
//    RD1:除数
//    RD0:被除数
//出口：
//    RD0:余数
//2010-6-22 15:25:39
///////////////////////////////////////
Sub _Ru_Mod;
    call _Ru_Div;
    RD0 = RD1;
    Return(0);



///////////////////////////////////////
//函数名：_Rs_Div
//功能：有符号整除
//入口：
//    RD1:除数
//    RD0:被除数
//出口：
//    RD0:商
//    RD1:余数
//2009-4-22 17:57:40
///////////////////////////////////////
Sub_AutoField _Rs_Div;

    RD1 += 0;
    if(RQ_nZero) goto _Rs_Div_Reg_L0;       //除数
    RF_Not(RD1);
    RD0 = RD1;
    goto _Rs_Div_Reg_End;

_Rs_Div_Reg_L0:
    RD2 = RD0;                              //被除数
    RD3 = RD0;
    if(RD0_Bit31==0) goto _Rs_Div_Reg_L1;   //判断被除数的符号
    RF_Neg(RD0);                            //负数变正数

_Rs_Div_Reg_L1:
    RD2 ^= RD1;                             //RD2除数与被除数的正负关系
    RD1 += 0;
    if(RQ_Bit31==0) goto _Rs_Div_Reg_L2;    //判断除数的符号
    RF_Neg(RD1);                            //负数变正数

_Rs_Div_Reg_L2:
    call _Ru_Div;                       //除法 RD0 被除数 RD1 除数

    RD2 += 0;                               //判断除数与被除数的正负关系
    if(RQ_Bit31==0) goto _Rs_Div_Reg_L4;    //bit31!=0异号  bit31==0同号
    RF_Neg(RD0);                            //改变商的符号

_Rs_Div_Reg_L4:
    RD3 += 0;
    if(RQ_Bit31==0) goto _Rs_Div_Reg_End;   //bit31!=0异号  bit31==0同号
    RF_Neg(RD1);                            //改变余数的符号

_Rs_Div_Reg_End:
    Return_AutoField(0);



///////////////////////////////////////
//函数名：_Rs_Mod
//功能：求余数
//入口：
//    RD1:除数
//    RD0:被除数
//出口：
//    RD0:余数
//2010-6-22 15:37:24
///////////////////////////////////////
Sub _Rs_Mod;
    call _Rs_Div;
    RD0 = RD1;
    Return(0);



///////////////////////////////////////////////////////////////////
//  模块名称:
//      DIV_64;
//  模块功能:
//      计算32位除数除以64位被除数;
//  模块入口:
//      RD0:    被除数X高32位.
//      RD1:    被除数X低32位.
//      RD4:    除数32位. 如果为0则按60计算.
//  模块出口:
//      RD0:    商高32位.
//      RD1:    商低32位.
//      RD4:    除法余数.
//  模块说明:
//      用来计算T = T0/Tc, 如果被除数Tc为0则按60计算.
//      原来的出口：RD3:除法余数.
///////////////////////////////////////////////////////////////////
Sub_AutoField DIV_64;
    push RD5;
    push RD6;
    push RD7;
    push RD8;
    push RD9;

    // 被除数X
    RD8 = RD0;                                          // X.H32
    RD7 = RD1;                                          // X.L32

    // 参数检查, 如果为0则按60计算.
    RD0 = RD4;
    if(RD0_nZero) goto L_DIV_64_1;
    RD4 = 60;

    // Sum
L_DIV_64_1:
    RD2 = 0;                                           // sum.L32
    RD3 = 0;                                            // sum.H32
    // U = (Y << (63 - Y.MSBPOS))
    RD9 = 0;
    RD0 = RD4;
L_DIV_64_2:
    if(RD0_Bit31 == 1) goto L_DIV_64_3;
    RD0 <<;
    RD9 ++;
    goto L_DIV_64_2;
L_DIV_64_3:
    RD9 += 32;                                          // U = Tc<<RD9
    RD5 = 0;                                            // U.L32
    RD6 = RD0;                                          // U.H32

L_DIV_64_Loop:
    // 判断X是否大于等于U
    RD0 = RD8;                                          // X.H32
    RD0 -= RD6;                                         // X.H32 -= U.H32
    if(RQ_Borrow) goto L_DIV_64_4;
    if(RD0_nZero) goto L_DIV_64_5;
    // x.H32 == u.H32, 判L32.
    RD0 = RD7;                                          // X.L32
    RD0 -= RD5;                                         // X.L32 -= U.L32
    if(RQ_Borrow) goto L_DIV_64_4;

    // X >= U
L_DIV_64_5:
    // X -= U
    RD0 = RD5;                                          // U.L32
    RD1 = RD6;                                          // U.H32
    RD7 -= RD0;                                         // X.L32 -= U.L32

    RF_Not(RD1);  RD8 ^+= RD1;//RD8 ^-= RD1;                                        // X.H32 ^-= U.H32

    // Sum ++
    RD2 ++;                                            // sum.L32
    goto L_DIV_64_Loop;

    // X < U
L_DIV_64_4:
    // U >>= 1
    RD5 >>;                                             // U.L32 >>= 1
    RD0 = RD6;                                          // U.H32
    if(RD0_Bit0 == 0) goto L_DIV_64_6;
    RD0 = RD5;
    RD0_SetBit31;
    RD5 = RD0;
L_DIV_64_6:
    RD6 >>;                                             // U.H32 >>= 1

    // sum <<= 1
    RD3 <<;                                             // sum.H32 <<= 1
    RD0 = RD2;                                         // sum.L32
    if(RD0_Bit31 == 0) goto L_DIV_64_7;
    RD3 ++;
L_DIV_64_7:
    RD2 <<;                                            // sum.L32 <<= 1
    RD9 --;
    if(RQ_nZero) goto L_DIV_64_Loop;

    // 商为奇数时结果校正.
    // 如果X >= Y, 则sum ++, X -= Y.
    RD0 = RD7;                                          // X.L32
    RD0 -= RD4;
    if(RQ_Borrow) goto L_DIV_64_End;
    RD7 = RD0;                                          // X = X - Y
    RD2 ++;                                            // sum ++

L_DIV_64_End:
    // 返回结果:
    RD0 = RD7;
    RD4 = RD0;                                          // RD4返回余数
    RD1 = RD2;                                          // X.L32
    RD0 = RD3;                                          // X.H32

    // 恢复现场:
    pop RD9;
    pop RD8;
    pop RD7;
    pop RD6;
    pop RD5;
    Return_AutoField(0*MMU_BASE);


///////////////////////////////////////////////
//  模块名称:
//      HEXtoBCD
//  模块功能:
//      十进制自然数转换成BCD数据;
//  模块入口:
//      RD0: N；
//      RD1: HEX;
//  模块出口:
//      RD0: BCD;
///////////////////////////////////////////////
Sub_AutoField HEXtoBCD;
    push RD4;

    RA0 = RD0;
    RD3 = 0;
    RD2 = RD0;
Loop:
    RD0 = 0;
    // RD1 = HEX
    RD4 = 10;
    call DIV_64;                                        // [RD0,RD1,RD4]=DIV_64(RD0,RD1,RD4);
    RD0 = RD4;
    RF_RotateR4(RD0);
    RF_RotateR4(RD3);
    RD3 += RD0;
    RD2 --;
    if(RQ_nZero) goto Loop;

    RA0 -= 8;
    if(RQ_Zero) goto End;
    RF_RotateR8(RD3);

End:
    RD0 = RD3;
    pop RD4;
    Return_AutoField(0);


///////////////////////////////////////////////////////////////////
//  模块名称:
//      MFGetDwordNum_Hash;
//  模块功能:
//      提取klen比特长的消息M的总块数,块长32比特;
//  模块入口:
//      RD0: 消息M的比特长度klen;
//  模块出口:
//      RD0: 消息M的总块数;
///////////////////////////////////////////////////////////////////
Sub_AutoField MFGetDwordNum_Hash;
    RD2=RD0;                                            // RD2=klen
    RF_ShiftR2(RD0);
    RF_ShiftR2(RD0);
    RF_ShiftR1(RD0);
    RD1=0x1f;
    RD1&=RD2;
    if(RQ_Zero) goto L_MFGetDwordNum_Hash_1;
    RD0++;
L_MFGetDwordNum_Hash_1:
    Return_AutoField(0*MMU_BASE);

///////////////////////////////////////////////////////////////////
//  模块名称:
//      MFProcessTail_Hash;
//  模块功能:
//      处理消息M的尾巴;
//  模块入口:
//      RD0:    消息M首址 Addr_Msg;
//      RD1:    消息M的比特长度  Msg_BitLen;
//  模块出口:
//      RD0:    消息尾块地址;
//      RD1:    消息尾位数目(tail_bits);
///////////////////////////////////////////////////////////////////
Sub_AutoField MFProcessTail_Hash;
    RA0 = RD0;
    RD2 = RD1;
    RF_ShiftR2(RD2);
    RF_ShiftR2(RD2);
    RF_ShiftR1(RD2);                                    // RD2=消息M的整DWORD数目
    RD0=0x1f;
    RD0&=RD1;
    if(RD0_Zero) goto MFProcessTail_Hash_Loop;
    // 有多余bits情况:
    RD1=RD2;
    RF_ShiftL2(RD1);
    RA0+=RD1;                                           // RA0=尾块首址
    RD1 = 32;
    RD1 -= RD0;
    RF_Exp(RD1);
    RD1 --;
    RF_Not(RD1);
    M[RA0]&=RD1;
    RD1 = RD0;
    RD0 = RA0;
    goto MFProcessTail_Hash_End;

MFProcessTail_Hash_Loop:
    // 整DWORD情况:
    RF_ShiftL2(RD2);
    RD0 = RA0;
    RD0 += RD2;
    RD1 = 0;

MFProcessTail_Hash_End:
    Return_AutoField(0*MMU_BASE);

////////////////////////////////////////////
//  名称:
//      MFROMtoRAM2_Hash:
//  功能:
//      将ROM中的2n个短字合并为RAM中的n个字：
//  参数：
//      addr_rom: ROM数据首址;
//      num_rom:  ROM数据短字的个数(2n);
//      addr_ram: RAM数据目址;
//  返回值：
//      none;
////////////////////////////////////////////
Sub_AutoField MFROMtoRAM2_Hash;
    // 1. 保存现场:
    push RD0;
    push RD1;
    // 参数地址:
    // M[RSP+2*MMU_BASE]: addr_ram
    // M[RSP+3*MMU_BASE]: num_rom
    // M[RSP+4*MMU_BASE]: addr_rom
#define   addr_ram    M[RSP+2*MMU_BASE]
#define   num_rom     M[RSP+3*MMU_BASE]
#define   addr_rom    M[RSP+4*MMU_BASE]

    // 2. 初始化:
    RD2=0xffff;                                         // const=0xffff
    RF_ShiftR1(num_rom);                                // 2n=>n
    RA0=addr_rom;                                       // src
    RA1=addr_ram;                                       // dest

    // 3. 将16位的ROM数据连接成32位的RAM数据:
L_MFROMtoRAM2_Hash_1:
    RD0=M[RA0];
    RA0+=1*ROM_BASE;
    RD0&=RD2;                                           // RD0=low_16位
    RD1=M[RA0];
    RA0+=1*ROM_BASE;
    RD1&=RD2;                                           // RD3=high_16位
    RF_RotateL16(RD1);
    RD0^=RD1;
    M[RA1++]=RD0;
    num_rom--;
    if(RQ_nZero) goto L_MFROMtoRAM2_Hash_1;

    // 4. 恢复现场:
    pop RD1;
    pop RD0;
    Return_AutoField(3*MMU_BASE);


//////////////////////////////////////////////////////////////////////////
//  名称:
//      _Timer_Number_ms
//  功能:
//      计算计数器的预置值
//  参数:
//      1.时间值（单位：ms）
//      2.当前主频（单位：KHz）
//  返回值:
//      1.RD0: 预置值
//  注释:
//      破坏 RD4\5\6\7
//////////////////////////////////////////////////////////////////////////
Sub _Timer_Number_ms;
    RD1 = M[RSP+1*MMU_BASE];    // 当前主频
    RD0 = M[RSP+2*MMU_BASE];    // 时间值
    call _Ru_Multi;
    send_para(RD0);
    call _Timer_Number;
    Return(2*MMU_BASE);



////////////////////////////////////
//函数名：_Duration_DIV
//输入：被除数RD0，除数RD1
//输出：商 RD1 ;模RD0;
////////////////////////////////////
Sub_AutoField _Duration_DIV;
    RD2 = 0;
L_Duration_DIV_Loop:
    RD0 -= RD1;
    if(RQ_Borrow) goto L_Duration_DIV_End;
    RD2 ++;
    goto L_Duration_DIV_Loop;
L_Duration_DIV_End:
    RD0 += RD1;
    RD1 = RD2;
    Return_AutoField(0);

END SEGMENT

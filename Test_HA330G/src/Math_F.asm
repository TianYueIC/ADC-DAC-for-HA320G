#include <cpu11.def>
#include <Math.def>
#include <SOC_Common.def>
#include <resource_allocation.def>
#include <Global.def>
#include <USI.def>

CODE SEGMENT Math_F;
////////////////////////////////////////////////////////
//  名称:
//      Float_From_Int
//  功能:
//      32位整形数据转换为 24Bit Float格式
//  参数:
//      1.RD0: 整型数据
//  返回值:
//      1.RD0: 24Bit Float格式
////////////////////////////////////////////////////////
Sub_AutoField Float_From_Int;
    push RD4;

    if(RD0 == 0) goto L_Float_From_Int_End;
    RD2 = RD0;//备份原码

    //计算移位距离
    RF_Abs(RD0);
    RD4 = RD0;
    RF_Log(RD0);
    RD1 = 22;
    RD0 -= RD1;
    RD3 = RD0;// 右移位数

    //取绝对值后归一化
    RD1 = RD3;
    if(RD0_Bit31==0) goto L_Float_From_Int_0;
    //阶码为负时左移底数
    RF_Abs(RD1);
    RD0 = RD4;
    call _Rf_ShiftL_Reg;
    goto L_Float_From_Int_1;
L_Float_From_Int_0:
  //阶码为正时右移底数
    RD0 = RD4;
    call _Rf_ShiftR_Reg;
L_Float_From_Int_1:

    //恢复数据正负号
    RD1 = RD0;
    RD0 = RD2;
    if(RD0_Bit31==0) goto L_Float_From_Int_2;
    RF_Neg(RD1);
L_Float_From_Int_2:
    RD0 = RD1;
    RD3 += 22;

    //拼接阶码
    RD0_ClrByteH8;
    RF_GetL8(RD3);
    RF_RotateR8(RD3);
    RD0 += RD3;
L_Float_From_Int_End:
    pop RD4;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      Float_To_Int
//  功能:
//      24Bit Float格式转换为32位整形数据
//  参数:
//      1.RD0: 24Bit Float格式
//  返回值:
//      1.RD0: 整形数据
////////////////////////////////////////////////////////
Sub_AutoField Float_To_Int;
    //备份输入值到RD2
    RD2 = RD0;

    //取阶码->RD1
    RF_GetH8(RD0);
    RD1 = RD0;
    RD1 -= 22;

    //取底数->RD3
    RD0 = RD2;
    RD0_ClrByteH8;
    RD0_SignExtL24;
    RD3 = RD0;

    RD0 = RD1;
    RF_Abs(RD1);
    if(RD0_Bit31==1) goto L_Float_To_Int_ShiftR;
    //阶码为正数则左移
    RD0 = RD3;
    call _Rf_ShiftL_Reg;
    goto L_Float_To_Int_1;

L_Float_To_Int_ShiftR:
    //阶码为负数则右移
    RD0 = RD3;
    call _Rf_ShiftR_Signed_Reg;


L_Float_To_Int_1:
    RD1 = RD2;
    if(RQ_Bit31==0) goto L_Float_To_Int_End;
    RF_Neg(RD0);

L_Float_To_Int_End:

  Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      _Float_Add
//  功能:
//      浮点加
//  参数:
//      1.RD0:x
//      2.RD1:y
//  返回值:
//      1.RD0: x+y;
////////////////////////////////////////////////////////
Sub_AutoField _Float_Add;
    push RD4;
    push RD6;
    push RD7;

    RD2 = RD0;
    RD3 = RD1;
    RD4 = 0;// 归一化阶码调整量初值，若相加后无溢出，则RD4++

    // x底数
    RD0_ClrByteH8;
    RF_ShiftR1(RD0); // 为避免底数相加溢出，先右移一位后再相加
    if(RD0_Bit22==0) goto L_Float_Add_2;
    RD0_SetBit23;
L_Float_Add_2:
    RD0_SignExtL24;
    RD6 = RD0;// 寄存x的底数

    // y底数
    RD0 = RD1;
    RD0_ClrByteH8;
    RF_ShiftR1(RD0);// 为避免底数相加溢出，先右移一位后再相加
    if(RD0_Bit22==0) goto L_Float_Add_3;
    RD0_SetBit23;
L_Float_Add_3:
    RD0_SignExtL24;
    RD7 = RD0;      // 寄存y的底数

    // 阶码相减比大小
    RD0 = RD3;
    RF_GetH8(RD0);
    RD0_SignExtL8;
    RD1 = RD0;      // y的阶码（扩展符号位到32bit）
    RD0 = RD2;
    RF_GetH8(RD0);
    RD0_SignExtL8;  // x的阶码（扩展符号位到32bit）
    RD0 -= RD1;
    if(SRQ>0) goto L_Float_Add_xBig;

// y大x小，x底数右移后相加
    RD1 = RD0;
    RF_Abs(RD1);
    RD0 = RD6;
    call _Rf_ShiftR_Signed_Reg;
    RD0 += RD7;

    // 判断bit22与bit23是否相等，若相等则需归一化，RD4++
    RD1 = RD0;
    RF_ShiftR1(RD1);
    RD1 ^= RD0;
    if(RQ_Bit22==1) goto L_Float_Add_0;
    RF_ShiftL1(RD0);
    goto L_Float_Add_4;

L_Float_Add_0:
    RD4 ++;
L_Float_Add_4:
    // 拼接阶码
    RD1 = RD3;
    RF_GetH8(RD1);
    RD1 += RD4;         // 归一化调整
    RF_RotateR8(RD1);
    RD0_ClrByteH8;
    RD0 += RD1;

    goto L_Float_Add_End;

// x大y小，y底数右移后相加
L_Float_Add_xBig:
    RD1 = RD0;
    RF_Abs(RD1);
    RD0 = RD7;
    call _Rf_ShiftR_Signed_Reg;
    RD0 += RD6;

    // 判断bit22与bit23是否相等，若相等则需归一化，RD4++
    RD1 = RD0;
    RF_ShiftR1(RD1);
    RD1 ^= RD0;
    if(RQ_Bit22==1) goto L_Float_Add_1;
    RF_ShiftL1(RD0);
    goto L_Float_Add_5;

L_Float_Add_1:
    RD4 ++;

L_Float_Add_5:
    // 拼接阶码
    RD1 = RD2;
    RF_GetH8(RD1);
    RD1 += RD4;         // 归一化调整
    RF_RotateR8(RD1);
    RD0_ClrByteH8;
    RD0 += RD1;

L_Float_Add_End:
    call _Stan;
    pop RD7;
    pop RD6;
    pop RD4;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      _Float_Sub
//  功能:
//      浮点减
//  参数:
//      1.RD0:x
//      2.RD1:y
//  返回值:
//      1.RD0: x-y;
////////////////////////////////////////////////////////
Sub_AutoField _Float_Sub;
    push RD4;
    push RD6;
    push RD7;

    RD2 = RD0;
    RD3 = RD1;
    RD4 = 0;// 归一化阶码调整量初值，若相减后无溢出，则RD4++

    // x底数
    RD0_ClrByteH8;
    RF_ShiftR1(RD0); // 为避免底数相减溢出，先右移一位后再相减
    if(RD0_Bit22==0) goto L_Float_Sub_2;
    RD0_SetBit23;
L_Float_Sub_2:
    RD0_SignExtL24;
    RD6 = RD0;// 寄存x的底数

    // y底数
    RD0 = RD1;
    RD0_ClrByteH8;
    RF_ShiftR1(RD0);// 为避免底数相减溢出，先右移一位后再相减
    if(RD0_Bit22==0) goto L_Float_Sub_3;
    RD0_SetBit23;
L_Float_Sub_3:
    RD0_SignExtL24;
    RD7 = RD0;      // 寄存y的底数

    // 阶码相减比大小
    RD0 = RD3;
    RF_GetH8(RD0);
    RD0_SignExtL8;
    RD1 = RD0;      // y的阶码（扩展符号位到32bit）
    RD0 = RD2;
    RF_GetH8(RD0);
    RD0_SignExtL8;  // x的阶码（扩展符号位到32bit）
    RD0 -= RD1;
    if(SRQ>0) goto L_Float_Sub_xBig;

// y大x小，x底数右移后相减
    RD1 = RD0;
    RF_Abs(RD1);
    RD0 = RD6;
    call _Rf_ShiftR_Signed_Reg;
    RD0 -= RD7;

    // 判断bit22与bit23是否相等，若相等则需归一化，RD4++
    RD1 = RD0;
    RF_ShiftR1(RD1);
    RD1 ^= RD0;
    if(RQ_Bit22==1) goto L_Float_Sub_0;

    RF_ShiftL1(RD0);
    goto L_Float_Sub_4;

L_Float_Sub_0:
    RD4 ++;
L_Float_Sub_4:
    // 拼接阶码
    RD1 = RD3;
    RF_GetH8(RD1);
    RD1 += RD4;         // 归一化调整

    RF_RotateR8(RD1);
    RD0_ClrByteH8;
    RD0 += RD1;
    goto L_Float_Sub_End;

// x大y小，y底数右移后相减
L_Float_Sub_xBig:
    RD1 = RD0;
    RF_Abs(RD1);
    RD0 = RD7;
    call _Rf_ShiftR_Signed_Reg;
    RD6 -= RD0;
    RD0 = RD6;

    // 判断bit22与bit23是否相等，若相等则需归一化，RD4++
    RD1 = RD0;
    RF_ShiftR1(RD1);
    RD1 ^= RD0;
    if(RQ_Bit22==1) goto L_Float_Sub_1;
    RF_ShiftL1(RD0);
    goto L_Float_Sub_5;

L_Float_Sub_1:
    RD4 ++;
L_Float_Sub_5:
    // 拼接阶码
    RD1 = RD2;
    RF_GetH8(RD1);
    RD1 += RD4;         // 归一化调整
    RF_RotateR8(RD1);
    RD0_ClrByteH8;
    RD0 += RD1;

L_Float_Sub_End:
    call _Stan;

    pop RD7;
    pop RD6;
    pop RD4;
    Return_AutoField(0);



////////////////////////////////////////////////////////////
////  名称:
////      _Float_Div
////  功能:
////      浮点除法
////  参数:
////      1.RD0:x
////      2.RD1:y
////  返回值:
////      1.RD0: x/y;
////////////////////////////////////////////////////////////
//Sub_AutoField _Float_Div;
//
//    RD2=RD0;
//    RD0=RD1;
//    call _Float_Recip;
//    RD1 =RD2;
//    call _Float_Multi;
//
//    Return_AutoField (0);


////////////////////////////////////////////////////////////
////  名称:
////      _Float_Recip
////  功能:
////      求倒数运算(带阶码)
////  参数:
////      1.RD0:x;
////  返回值:
////      1.RD0: 1/x;
////  注释:
////      1.1/(x*2^y)=1/x*2^(-y)
////////////////////////////////////////////////////////////
//Sub_AutoField _Float_Recip;
//
//    RD1=RD0;
//    RF_GetH8(RD0);
//    RD2=RD0;                                          // x的order位y保存在RD2中
//    RD0=RD1;
//    RD0_ClrByteH8;                                        //  RD0高8位置0
//    RD1=RD0;
//    call _Recip;                                      //  1/x=RD0*order(-1)
//    RD1=RD0;
//
//    RD0=RD2;
//    RF_Neg(RD0);
//        RD0 -= 1;                                                                                    //order置0
//    RD0_ClrByteH24;                                   //-Y
//    RF_RotateR8(RD0);
//    RD0 += RD1;
//
//    call _Stan;
//
//    Return_AutoField (0);

////////////////////////////////////////////////////////
//  名称:
//      _Float_Multi
//  功能:
//      求乘法运算(带阶码)
//  参数:
//      1.RD0:x
//      2.RD1:y
//  返回值:
//      1.RD0: x*y;
//  注释:
//      1.(2^n*x)*(2^m*y)=2^(n+m)xy
////////////////////////////////////////////////////////
Sub_AutoField _Float_Multi;
    push RD4;
    push RD5;

    // 取x底数->RD3
    RD5=RD0;
    RF_GetH8(RD0);
    RD2=RD0;// x的order位y保存在RD2中
    RD0=RD5;
    RD0_ClrByteH8;
    RD0_SignExtL24;
    RD3 = RD0;

    // 取y底数->RD0
    RD5=RD1;
    RD0=RD1;
    RF_GetH8(RD0);
    RD4=RD0;// x的order位y保存在RD4中
    RD0=RD5;
    RD0_ClrByteH8;
    RD0_SignExtL24;

    // 底数相乘
    Multi24_X=RD0;
    RD0=RD3;
    Multi24_Y=RD0;
    nop;
    RD0=Multi24_XY;
    RD0_ClrByteH8;

    // 计算阶码
    RD1 = RD2;
    RD1 += RD4;
    RD1 ++;
    RF_GetL8(RD1);

    // 拼接阶码
    RF_RotateR8(RD1);
    RD0 += RD1;

L_Float_Multi_End:
    // 归一化
    call _Stan;

    pop RD5;
    pop RD4;
    Return_AutoField (0);



////////////////////////////////////////////////////////
//  名称:
//      _Float_Lg
//  功能:
//      求以10为底的对数运算(带阶码)
//  参数:
//      1.RD0:x
//  返回值:
//      1.RD0: lg(x);
//  注释:
//      1.lg(x*2^y)=lgx+y*lg2
////////////////////////////////////////////////////////
Sub_AutoField _Float_Lg;

    //32位带阶码数
    RD1=RD0;
    RF_GetH8(RD0);
    RD2=RD0;                                          // x的order位y保存在RD2中
    RD0=RD1;
    RD0_ClrByteH8;                                        //  RD0高8位置0
    RD1 = RD0;
    call _Lg;                                         //  lgx=RD0*order(-1)
    RF_ShiftR2(RD0);
    RF_ShiftR2(RD0);
    RF_ShiftR2(RD0);
    RF_ShiftR2(RD0);                                //  lgx=RD0*order(7)
    RD3 = RD0;

    RD0 = RD2;
    RF_RotateR16(RD0);                                //  y=RD0*order（6）
    if(RD0_Bit23 == 0) goto L_Float_Lg_0;
    RD0_SetByteH8;
L_Float_Lg_0:
    Multi24_X=RD0;
    RD0=0;
    RD0_SetBit20;
    RD0_SetBit17;
    RD0_SetBit16;
    RD0_SetBit14;
    RD0_SetBit10;
    RD0_SetBit4;
    RD0_SetBit1;
    RD0_SetBit0;                                      // lg2 =(1 0011 0100 0100 0001 0011)2=RD0*order(0)

    Multi24_Y=RD0;
    nop;
    nop;
    nop;
    RD0=Multi24_XY;                                   //  y*lg2= RD0*order(7)
    RD0_ClrByteH8;

    RD0 += RD3;//32位，小数点在22位上
    RD1=RD0;
    RD0=7;
    RF_RotateR8(RD0);
    RD0+=RD1;
    call _Stan;

    Return_AutoField (0);

//////////////////////////////////////////////////////////////
//////  名称:
//////      _Stan
//////  功能:
//////      将32位非归一化数据（高八位阶码，22位小数位）归一化
//////  参数:
//////      1.RD0:原数据;
//////  返回值:
//////      1.RD0: 归一化结果;
//////  注释:
//////      1.底数为归一化格式的意义: x是正数,b23=0,b22=1;x是负数,b23=1,b22=0;;x是0,b23=0,b22=0;
//////////////////////////////////////////////////////////////
//Sub_AutoField _Stan2;
//    push RD4;
//    push RD5;
//
//    RD2 = RD0;
//    RD0_ClrByteH8;
//    if(RD0_Zero) goto L_Stan_Zero;
//    RD0 = RD2;
//
//    //归一化
//    RD5=RD0;
//    RF_GetH8(RD0);
//    RD4=RD0;                                          // x的order位y保存在RD4中
//    RD0=RD5;
//    RD0_ClrByteH8;                                    //  RD0高8位置0
//    RD3 = RD0;                                        //  低24位
//    RD2 = 0;
//
//    if(RD0_Bit23 == 0) goto L_Stan_2;
//L_Stan_10:
//    RF_ShiftL1(RD0);
//    RD2++;
//    if(RD0_Bit23 == 1) goto L_Stan_10;
//    RF_ShiftR1(RD0);
//    RD0_SetBit23;
//    RD0_ClrByteH8;                                        //  RD0高8位置0 低24位归一化
//    RD1 = RD0;
//    RD0 = RD4;
//    RD0-=RD2;
//    RD0 ++;
//    RD0_ClrByteH24;
//    RF_RotateR8(RD0);
//    RD0 += RD1;
//    goto L_End;
//L_Stan_2:
//    if(RD0 == 0) goto L_Stan_1;
//    RD2++;
//    RF_ShiftR1(RD0);
//    goto L_Stan_2;
//L_Stan_1:
//    RD0 = RD2;
//    RD0 +=9; //阶码-23+32
//    RD1 = RD0;
//    RD0 = RD3;
//L_Stan_3:
//    RF_RotateR1(RD0);
//    RD1 -- ;
//    if(RQ!=0) goto L_Stan_3;
//    RD0_ClrByteH8;                                        //  RD0高8位置0 低24位归一化
//    RD1 = RD0;
//
//    RD0 = RD2;
//    RD0+=RD4;
//    RD0 -= 23;
//    RD0_ClrByteH24;
//    RF_RotateR8(RD0);
//    RD0 += RD1;
//L_End:
//    pop RD5;
//    pop RD4;
//    Return_AutoField (0);
//
//L_Stan_Zero:
//    RD0 = 0;
//    pop RD5;
//    pop RD4;
//    Return_AutoField (0);
//
////////////////////////////////////////////////////////
//  名称:
//      _Stan
//  功能:
//      将32位非归一化数据（高八位阶码，22位小数位）归一化
//  参数:
//      1.RD0:原数据;
//  返回值:
//      1.RD0: 归一化结果;
//  注释:
//      1.底数为归一化格式的意义: x是正数,b23=0,b22=1;x是负数,b23=1,b22=0;;x是0,b23=0,b22=0;
////////////////////////////////////////////////////////
Sub_AutoField _Stan;
    if(RD0_Bit23==0) goto L_Stan_Pos;
    RD2 = RD0;
    RD3 = RD0;
    RF_GetH8(RD2);// 阶码
    RF_Not(RD0);
    RD0_ClrByteH8;// 底数反码
    RF_Log(RD0);
    RD1 = 22;
    RD1 -= RD0;
    RD2 -= RD1;// 调整阶码
    RF_GetL8(RD2);
    RD0 = RD3;
    RD0_ClrByteH8;
    call _Rf_ShiftL_Reg;
    RD0_ClrByteH8;
    RF_RotateR8(RD2);
    RD0 += RD2;
    goto L_Stan_End;

L_Stan_Pos:
    RD2 = RD0;
    RF_GetH8(RD2);// 阶码
    RD0_ClrByteH8;// 底数
    RD3 = RD0;
    RF_Log(RD0);
    RD1 = 22;
    RD1 -= RD0;
    RD2 -= RD1;// 调整阶码
    RF_GetL8(RD2);
    RD0 = RD3;
    call _Rf_ShiftL_Reg;
    RF_RotateR8(RD2);
    RD0 += RD2;

L_Stan_End:
    Return_AutoField (0);

//Sub_AutoField _Stan;
//      //归一化
//      RD5=RD0;
//      RF_GetH8(RD0);
//      RD4=RD0;                                                                                    // x的order位y保存在RD4中
//
//      RD0=RD5;
//      if(RD0_Bit23 == 0) goto L_Stan_1;
//      RF_Neg(RD0);
//L_Stan_1:
//      RD0_ClrByteH8;                                                                      //  RD0高8位置0
//      RD2 = RD0;
//      RF_Log(RD0);
//      RD1 = 22;
//      RD1 -= RD0;
//      RD3 = RD1;
//      RD0 = RD2;
//      call _Rf_ShiftL_Reg;
//
//      RD0_ClrByteH8;                                                                      //  RD0高8位置0
//      RD1 = RD0;
//      RD0 = RD5;
//      if(RD0_Bit23 == 0) goto L_Stan_2;
//      RD0=RD1;
//      RF_Neg(RD0);
//      RD0_ClrByteH8;                                                                      //  RD0高8位置0
//      RD1 = RD0;
//L_Stan_2:
//
//      RD0 = RD4;
//      RD0 -= RD3;
//      RD0_ClrByteH24;
//      RF_RotateR8(RD0);
//      RD0 += RD1;
//
//      Return_AutoField (0);

//////////////////////////////////////////////////////////
////  名称:
////      _Recip
////  功能:
////      求倒数; 1/x=a*(1-b)(1+b^2)=a*(1-b+b^2-b^3),x=xh+xl,a=1/xh,b=xl*(1/xh);
////  参数:
////      1.RD1:x,24BIT FLOAT,底数为归一化格式,且x≠0;
////  返回值:
////      1.RD0: 1/x = RD0*order(-1) ;
////  注释:
////      1. 底数为归一化格式的意义: x是正数,b23=0,b22=1;x是负数,b23=1,b22=0;
////      2. 如果底数不为归一化格式,调用该函数前,需对x进行底数归一化;
////      3. 该函数不处理阶码,由外部自行计算;
//////////////////////////////////////////////////////////
//Sub_AutoField _Recip;
//    push RD4;
//    RD4 = 0xFFFFFF;
//
//    RD0 = RN_Addr_Float;
//    RA1 = RD0;                                                       // 浮点数格式加速器基址
//    RD0 = RN_Addr_Recip;
//    RA0 = RD0;                                                             // 倒数ROM基址
//
//    // 判断x的正负
//    RD0 = RD1;
//    RD3 = RD1;
//    if(RD0_Bit23==0) goto L_Recip_0;
//    RF_Neg(RD0);
//L_Recip_0:
//    // 将x分解成高低两部分:
//
//
//    M[RA1+L24Bit_ToFloat]=RD0;
//    RF_ShiftL1(RD0);
//    RD1 = 0X7FFFF;
//    RD1 &= RD0;
//    //RD1=M[RA1+Read_Float_L];                                              // xl=RD1*order(-1)
//    RD0=M[RA1+Read_Float_H];                                                // RD0=x的高五位的中间三位,D21,D20,D19.D22为1,忽略;D18?嬖贔lag_XH_LSB中.
//
//    // x的高位查表:
//    RD0=M[RA0+RD0];
//
//    // 根据xh的LSB位,取查表结果的L16,H16:
//    if(Flag_XH_LSB==1) goto L_Recip_1;
//    M[RA1+L16Bit_ToFloat]=RD0;
//    goto L_Recip_2;
//L_Recip_1:
//    M[RA1+H16Bit_ToFloat]=RD0;
//L_Recip_2:
//    RD0=M[RA1+Read_Float];                                                  // a=1/xh=RD0*order(-1)
//    RD2=RD0;                                                                                // a=1/xh=RD2*order(-1)
//
//    // 计算b=xl*(1/xh):
//    RF_ShiftL2(RD1);                                                                // 将xl左移四位,以便在做乘法运算时保留精度
//    RF_ShiftL2(RD1);                                                                // xl=RD1*order(-5)
//    Multi24_X=RD1;
//    Multi24_Y=RD0;
//    nop;
//    RD0=Multi24_XY;                                                              // b=xl*(1/xh)=RD1*order(-5) (乘法结果order+=1)
//    RD0_ClrByteH8;
//    RD1 = RD0;
//
//    // 计算b^2:
//    Multi24_X=RD0;
//    Multi24_Y=RD0;
//
//    // 计算1-b:
//    RD0=0;
//    RD0_SetBit30;                                                                       // 1=RD0*order(-8)
//    RF_ShiftL2(RD1);                                                                // b=RD1*order(-7)
//    RF_ShiftL1(RD1);                                                                // b=RD1*order(-8)
//    RD0-=RD1;                                                                               // (1-b)=RD0*order(-8)
//
//    // 计算b^3:
//    RD1=Multi24_XY;                                                                 // b^2=RD1*order(-9)
//    RD1 &= RD4;
//    RF_ShiftR1(RD1);                                                                // b^2=RD1*order(-8)
//    Multi24_Y=RD1;                                                                  // Multi24_X=b*order(-5),保持不变;
//
//    // 计算(1-b)+b^2
//    RD0 += RD1;                                                                         // (1-b)+b^2=RD0*order(-8)
//
//    // 计算[(1-b)+b^2]-b^3
//    RD1=Multi24_XY;                                                                 // b^3=RD0*order(-12)
//    RD1 &= RD4;
//    RF_ShiftR2(RD1);
//    RF_ShiftR2(RD1);                                                                // b^3=RD0*order(-8)
//    RD0 -= RD1;                                                                         // [(1-b)+b^2]-b^3=RD0*order(-8)
//    RF_ShiftR2(RD0);                                                                // 进乘法器前需要保证D23及更高位为符号位.
//    RF_ShiftR2(RD0);
//    RF_ShiftR2(RD0);
//    RF_ShiftR2(RD0);                                                                // [(1-b)+b^2]-b^3=RD0*order(0)
//
//    // 计算a*[(1-b)+b^2-b^3]
//    Multi24_X=RD0;
//    RD0 = RD2;                                                                          // a=1/xh=RD2*order(-1)
//    Multi24_Y=RD0;
//
//    // 判断x的正负
//    RD0 = RD3;
//    if(RD0_Bit23==0) goto L_Recip_3;
//    RD0 = Multi24_XY;
//    RF_ShiftL1(RD0);                                                                // 1/x = RD0*order(-1)
//    RF_Neg(RD0);
//    RD0_ClrByteH8;//RD0 &= RD20;
//    goto L_Recip_End;
//L_Recip_3:
//    RD0 = Multi24_XY;
//    RF_ShiftL1(RD0);                                                                // 1/x = RD0*order(-1)
//    RD0_ClrByteH8;//RD0 &= RD20;
//
//L_Recip_End:
//    pop RD4;
//    Return_AutoField(0);


/*
////////////////////////////////////////////////////////
//  名称:
//      _Recip
//  功能:
//      求倒数; 1/x=a*(1-b)(1+b^2)=a*(1-b+b^2-b^3),x=xh+xl,a=1/xh,b=xl*(1/xh);
//  参数:
//      1.RD1:x,24BIT FLOAT,底数为归一化格式,且x≠0;
//  返回值:
//      1.RD0: 1/x = RD0*order(-1) ;
//  注释:
//      1. 底数为归一化格式的意义: x是正数,b23=0,b22=1;x是负数,b23=1,b22=0;
//      2. 如果底数不为归一化格式,调用该函数前,需对x进行底数归一化;
//      3. 该函数不处理阶码,由外部自行计算;
////////////////////////////////////////////////////////
Sub_AutoField _Recip;
    push RD4;
    RD4 = 0xFFFFFF;

    RA1=RN_Addr_Float;                              // 浮点数格式加速器基址
    RA0=RN_Addr_Recip;                              // 倒数ROM基址

    // 判断x的正负
    RD0 = RD1;
    RD3 = RD1;
    if(RD0_Bit23==0) goto L_Recip_0;
    RF_Neg(RD0);
L_Recip_0:
    // 将x分解成高低两部分:
    M[RA1+L24Bit_ToFloat]=RD0;
    RF_ShiftL1(RD0);
    RD1 = 0X7FFFF;
    RD1 &= RD0;
    //RD1=M[RA1+Read_Float_L];                                              // xl=RD1*order(-1)
    RD0=M[RA1+Read_Float_H];                        // RD0=x的高五位的中间三位,D21,D20,D19.D22为1,忽略;D18存在Flag_XH_LSB中.
    //RF_ShiftL2(RD0);

    // x的高位查表:
    RD0=M[RA0+RD0];

    // 根据xh的LSB位,取查表结果的L16,H16:
    if(Flag_XH_LSB==1) goto L_Recip_1;
    M[RA1+L16Bit_ToFloat]=RD0;
    goto L_Recip_2;
L_Recip_1:
    M[RA1+H16Bit_ToFloat]=RD0;
L_Recip_2:
    RD0=M[RA1+Read_Float];                          // a=1/xh=RD0*order(-1)
    RD2=RD0;                                        // a=1/xh=RD2*order(-1)

    // 计算b=xl*(1/xh):
    RF_ShiftL2(RD1);                                // 将xl左移四位,以便在做乘法运算时保留精度
    RF_ShiftL2(RD1);                                // a=1/xh=RD0*order(-5)
    Multi24_X=RD1;
    Multi24_Y=RD0;
    nop;
    RD0=Multi24_XY;                                 // b=xl*(1/xh)=RD1*order(-5) (乘法结果order+=1)
  RD0_ClrByteH8;

    // 计算b^2:
    Multi24_X=RD0;
    Multi24_Y=RD0;                                  // b=RD1*order(-5)

    // 计算1-b:
    RD0=0;
    RD0_SetBit30;                                   // 1=RD0*order(-8)
    RF_ShiftL2(RD1);                                // b=RD1*order(-7)
    RF_ShiftL1(RD1);                                // b=RD1*order(-8)
    RD0-=RD1;                                       // (1-b)=RD0*order(-8)

    // 计算b^3:
    RD1=Multi24_XY;                                 // b^2=RD1*order(-9)
  RD1 &= RD4;
    RF_ShiftR1(RD1);                                // b^2=RD1*order(-8)
    Multi24_Y=RD1;                                  // Multi24_X=b*order(-5),保持不变;

    // 计算(1-b)+b^2
    RD0 += RD1;                                     // (1-b)+b^2=RD0*order(-8)

    // 计算[(1-b)+b^2]-b^3
    RD1=Multi24_XY;                                 // b^3=RD0*order(-12)
  RD1 &= RD4;
    RF_ShiftR2(RD1);
    RF_ShiftR2(RD1);                                // b^3=RD0*order(-8)
    RD0 -= RD1;                                     // [(1-b)+b^2]-b^3=RD0*order(-8)
    RF_ShiftR2(RD0);                                // 进乘法器前需要保证D23及更高位为符号位.
    RF_ShiftR2(RD0);
    RF_ShiftR2(RD0);
    RF_ShiftR1(RD0);                                // [(1-b)+b^2]-b^3=RD0*order(-1)

    // 计算a*[(1-b)+b^2-b^3]
    Multi24_X=RD0;
    RD0 = RD2;                                      // a=1/xh=RD2*order(-1)
    Multi24_Y=RD0;

    // 判断x的正负
    RD0 = RD3;
    if(RD0_Bit23==0) goto L_Recip_3;
    RD0 = Multi24_XY;                                // 1/x = RD0*order(-1)
  RD0_ClrByteH8;//RD0 &= RD20;
    RF_Neg(RD0);
    goto L_Recip_End;
L_Recip_3:
    RD0 = Multi24_XY;                                // 1/x = RD0*order(-1)
  RD0_ClrByteH8;//RD0 &= RD20;

L_Recip_End:
  pop RD4;
    Return_AutoField(0);
*/

////////////////////////////////////////////////////////////
////  名称:
////      _Sqrt
////  功能:
////      求平方根; z=sqrt(x),x=xh+xl,a=sqrt(xh),b=xl/xh,z=a*(8+b*4-b^2)/8;
////  参数:
////      1.RD1:x,24BIT FLOAT,底数为归一化格式非负数;
////  返回值:
////      1.RD0: 1/x;
////  注释:
////      1.计算b之前需要将xl左移四位,以保证后面乘法计算的精度;
////      2.计算加减法时需要将所有数据的order统一,本算法计算时将order统一为-5;
////      3.乘法计算时需保证D23位及更高位为符号位,乘法前需将两个乘数首位1移至D22位,并记下order.
////      4.底数为归一化格式的意义: x是正数,b23=0,b22=1;x是负数,b23=1,b22=0;;x是0,b23=0,b22=0;
////      5.如果底数不为归一化格式,调用该函数前,需对x进行底数归一化;
////      6.该函数不处理阶码,由外部自行计算.
////////////////////////////////////////////////////////////
//Sub_AutoField _Sqrt;
//
//    RD0=RN_Addr_Float;
//    RA1 = RD0;                                 // 浮点数格式加速器基址
//    RD0=RN_Addr_Sqrt;
//    RA0 = RD0;                                  // 平方根ROM基址
//
////////////////////////////////////////////////////////////
//////计算sqrt(Xh)
//    // 将x分解成高低两部分:
//    M[RA1+L24Bit_ToFloat]=RD1;
//    RD0=M[RA1+Read_Float_H];                        // RD0=x的高五位的中间三位,D21,D20,D19.D22为1,忽略;D18存在Flag_XH_LSB中.
//    //RF_ShiftL2(RD0);
//    // x的高位查表:
//    RD0=M[RA0+RD0];
//
//
//    // 根据x的D18,取查表结果的L16,H16
//    if(Flag_XH_LSB==1) goto L_Sqrt_1;               // FLAG_FLOAT是D18
//    M[RA1+L16Bit_ToFloat]=RD0;
//    goto L_Sqrt_2;
//L_Sqrt_1:
//    M[RA1+H16Bit_ToFloat]=RD0;
//L_Sqrt_2:
//    RD0=M[RA1+Read_Float];                          // a=sqrt(xh)=RD0*order(0)
//    RD3=RD0;                                        // a=sqrt(Xh)=RD0*order(0)
//
//////////////////////////////////////////////////////////////
//////计算1/xh
//    RD0 = RN_Addr_Recip;
//    RA0 = RD0;                                // 倒数ROM基址
//    M[RA1+L24Bit_ToFloat]=RD1;
//    RD1=M[RA1+Read_Float_L];                        // xl=RD1*order(-1),xl是x的低18位
//    RD0=M[RA1+Read_Float_H];                        // RD0=x的高五位的中间三位,D21,D20,D19.D22为1,忽略;D18存在Flag_XH_LSB中.
//    //RF_ShiftL2(RD0);
//    // x的高位查表:
//    RD0=M[RA0+RD0];
//
//    // 根据xh的LSB位,取查表结果的L16,H16:
//    if(Flag_XH_LSB==1) goto L_Sqrt2_1;
//    M[RA1+L16Bit_ToFloat]=RD0;
//    goto L_Sqrt2_2;
//L_Sqrt2_1:
//    M[RA1+H16Bit_ToFloat]=RD0;
//L_Sqrt2_2:
//    RD0=M[RA1+Read_Float];                          // 1/xh=RD0*order(-1)
//
//////////////////////////////////////////////////////////////
//    // 计算b=Xl*(1/Xh):
//    RF_ShiftL2(RD1);                                // 将xl左移四位,以便在做乘法运算时保留精度
//    RF_ShiftL2(RD1);                                // a=1/xh=RD0*order(-5)
//    Multi24_X=RD1;
//    Multi24_Y=RD0;
//    nop;
//    RD1=Multi24_XY;                                      // b=Xl*(1/Xh)=RD1*order(-5)
//    RD2=RD1;                                        // b=Xl*(1/Xh)=RD4*order(-5)
//
//    // 计算b*4,即将b左移两位:
//    RF_ShiftL2(RD1);                                // b*4=RD1*order(-5)
//
//    // 计算8+b*4:
//    RD0=0;
//    RD0_SetBit30;                                   // 1=RD0*order(-5)
//    RD0+=RD1;                                       // (8+b*4)=RD0*order(-5)
//
//    // 计算b^2:
//    RD1=RD2;
//    Multi24_X=RD1;
//    Multi24_Y=RD1;
//    nop;
//    RD1=Multi24_XY;                                      // b^2=RD0*order(-9)=RD0*2^(-4)*order(-5)
//
//    // 将b^2右移四位:
//    RF_ShiftR2(RD1);
//    RF_ShiftR2(RD1);                                // (b^2)=RD0*order(-5)
//
//
//    //计算(8+b*4-b^2):
//    RD0-=RD1;                                       // (8+b*4-b^2)=RD0*order(-5)
//
//    //因为(8+b*4-b^2)在D30位有1,乘法器无法计算,需右移8位.
//    RF_ShiftR2(RD0);
//    RF_ShiftR2(RD0);
//    RF_ShiftR2(RD0);
//    RF_ShiftR2(RD0);                                // (8+b*4-b^2)=RD0*order(3)
//
//    //计算a*(8+b*4-b^2):
//    RD1=RD3;
//    Multi24_X=RD1;
//    Multi24_Y=RD0;
//    nop;
//    RD0=Multi24_XY;                                      // a*(8+b*4-b^2)=RD0*order(4),因为Sqrt(x)=a*(8+b*4-b^2)/8,所以Sqrt(x)=RD0*order(1).
//    RF_ShiftL2(RD0);                                // Sqrt(x)=RD0*order(-1)
//
//    Return_AutoField (0);
//

////////////////////////////////////////////////////////
//  名称:
//      _Ln
//  功能:
//      求ln; z=ln(x),x=xh+xl,a=ln(xh),b=xl/xh,z=a+b-b^2/2+b^3/3;
//  参数:
//      1.RD1:x,24BIT FLOAT,底数为归一化格式正数;
//  返回值:
//      1.RD0:ln(x);
//  注释:
//      1.计算b之前需要将xl左移四位,以保证后面乘法计算的精度;
//      2.计算加减法时需要将所有数据的order统一,本算法计算时将order统一为-9;
//      3.乘法计算时需保证D23位及更高位为符号位,乘法前需将两个乘数首位1移至D22位,并记下order.
//      4.底数为归一化格式的意义: x是正数,b23=0,b22=1;
//      5.如果底数不为归一化格式,调用该函数前,需对x进行底数归一化;
//      6.该函数不处理阶码,由外部自行计算.
////////////////////////////////////////////////////////
Sub_AutoField _Ln;
    push RD4;

L_aaa:
    RD0 = RN_Addr_Float;
    RA1 = RD0;                                 // 浮点数格式加速器基址
    RD0 = RN_Addr_Ln;
    RA0 = RD0;                                   // Ln的ROM基址

//////////////////////////////////////////////////////////
////计算ln(Xh)
    // 将x分解成高低两部分:
    M[RA1+L24Bit_ToFloat]=RD1;
    RD0=M[RA1+Read_Float_H];                        // RD0=x的高五位的中间三位,D21,D20,D19.D22为1,忽略;D18存在Flag_XH_LSB中.
    //RF_ShiftL2(RD0);
    // x的高位查表:
    RD0=M[RA0+RD0];

    // 根据x的D18,取查表结果的L16,H16
    if(Flag_XH_LSB==1) goto L_Ln_1;                 // FLAG_FLOAT是D18
    M[RA1+L16Bit_ToFloat]=RD0;
    goto L_Ln_2;
L_Ln_1:
    M[RA1+H16Bit_ToFloat]=RD0;
L_Ln_2:
    RD0=M[RA1+Read_Float];                          // a=ln(xh)=RD0*order(-1)
    RD3=RD0;                                        // a=ln(Xh)=RD3*order(-1)

////////////////////////////////////////////////////////////
////计算1/xh
    RD0 = RN_Addr_Recip;
    RA0 = RD0;                              // 倒数ROM基址
    M[RA1+L24Bit_ToFloat]=RD1;
    RD1=M[RA1+Read_Float_L];                        // xl=RD1*order(-1),xl是x的低18位
    RD0=M[RA1+Read_Float_H];                        // RD0=x的高五位的中间三位,D21,D20,D19.D22为1,忽略;D18存在Flag_XH_LSB中.
    //RF_ShiftL2(RD0);

    // x的高位查表:
    RD0=M[RA0+RD0];
    // 根据xh的LSB位,取查表结果的L16,H16:
    if(Flag_XH_LSB==1) goto L_Ln2_1;
    M[RA1+L16Bit_ToFloat]=RD0;
    goto L_Ln2_2;
L_Ln2_1:
    M[RA1+H16Bit_ToFloat]=RD0;
L_Ln2_2:
    RD0=M[RA1+Read_Float];                          // 1/xh=RD0*order(-1)

////////////////////////////////////////////////////////////
    // 计算b=Xl*(1/Xh):
    RF_ShiftL2(RD1);                                // 将xl左移四位,以便在做乘法运算时保留精度
    RF_ShiftL2(RD1);                                // 1/xh=RD0*order(-5)

    Multi24_X=RD1;
    Multi24_Y=RD0;
    nop;
    RD1=Multi24_XY;                                      // b=Xl*(1/Xh)=RD1*order(-5)
    RD2=RD1;                                        // b=Xl*(1/Xh)=RD2*order(-5)

    // 计算a+b
    RD0=RD3;
    RF_ShiftL2(RD1);
    RF_ShiftL2(RD1);                                // b=Xl*(1/Xh)=RD1*order(-9)
    RF_ShiftL2(RD0);
    RF_ShiftL2(RD0);
    RF_ShiftL2(RD0);
    RF_ShiftL2(RD0);                                // a=ln(Xh)=RD0*order(-9)
    RD0+=RD1;                                       // a+b=RD0*order(-9)

    // 计算b^2:
    RD1=RD2;
    Multi24_X=RD1;
    Multi24_Y=RD1;
    nop;
    RD1=Multi24_XY;                                      // b^2=RD1*order(-9)
    RD3=RD1;                                        // b^2=RD3*order(-9)

    // 计算b^2/2:
    RF_ShiftR1(RD1);                                // b^2/2=RD1*order(-9)

    // 计算(a+b)-b^2/2:
    RD0-=RD1;                                       // (a+b)-b^2/2=RD0*order(-9)
    RD4=RD0;

    // 计算b^3:
    RD1=RD2;                                        // b=RD2*order(-5)
    RD0=RD3;                                        // b^2=RD3*order(-9)
    Multi24_X=RD1;
    Multi24_Y=RD1;
    nop;
    RD1=Multi24_XY;                                      // b^3=RD1*order(-13)

    // 计算b^3/3:
    RD0=0;
    RD0_SetBit21;
    RD0_SetBit19;
    RD0_SetBit17;
    RD0_SetBit15;
    RD0_SetBit13;
    RD0_SetBit11;
    RD0_SetBit9;                                    // 1/3=RD0*order(-1)
    Multi24_X=RD1;
    Multi24_Y=RD0;
    nop;
    RD1=Multi24_XY;                                      // b^3/3=RD1*order(-13)

    // 计算(a+b-b^2/2)+b^3/3
    RF_ShiftR2(RD1);
    RF_ShiftR2(RD1);                                // b^3/3=RD1*order(-9)
    RD0=RD4;
    RD0+=RD1;                                       // Ln(x)=a+b-b^2/2+b^3/3=RD0*order(-9)
    RF_ShiftR2(RD0);
    RF_ShiftR2(RD0);
    RF_ShiftR2(RD0);
    RF_ShiftR2(RD0);                                // Ln(x)=a+b-b^2/2+b^3/3=RD0*order(-1)

    pop RD4;
    Return_AutoField (0);



////////////////////////////////////////////////////////
//  名称:
//      _Lg
//  功能:
//      求以10为底的对数运算; z=lg(x),z=ln(x)/ln(10),z=ln(x)*1/ln(10);
//  参数:
//      1.RD1:x,24BIT FLOAT,底数为归一化格式正数;
//  返回值:
//      1.RD0: lg(x);
//  注释:
//      1.底数为归一化格式的意义: x是正数,b23=0,b22=1;
//      2.如果底数不为归一化格式,调用该函数前,需对x进行底数归一化;
//      3.该函数不处理阶码,由外部自行计算;
////////////////////////////////////////////////////////
Sub_AutoField _Lg;

    // 计算ln(x):
    call _Ln;                                       // ln(x) = RD0*order(-1)
    RD2=RD0;

    // 计算1/ln(10)
    RD0=0;
    RD0_SetBit21;
    RD0_SetBit20;
    RD0_SetBit18;
    RD0_SetBit17;
    RD0_SetBit16;
    RD0_SetBit15;
    RD0_SetBit12;
    RD0_SetBit10;
    RD0_SetBit9;
    RD0_SetBit8;                                    // 1/ln(10)=(0.011011110010111)2=RD0*order(-1)

    // 计算z=ln(x)*1/ln(10):
    Multi24_X=RD0;
    RD0=RD2;
    Multi24_Y=RD0;
    nop;
    RD0=Multi24_XY;                                      // z=z=ln(x)*1/ln(10)=RD0*order(-1)

    Return_AutoField(0);

////////////////////////////////////////////////////////////
////  名称:
////      _Log2
////  功能:
////      求以2为底的对数运算; z=log2(x),z=ln(x)/ln(2),z=ln(x)*1/ln(2);
////  参数:
////      1.RD1:x,24BIT FLOAT,底数为归一化格式正数;
////  返回值:
////      1.RD0: log2(x);
////  注释:
////      1.底数为归一化格式的意义: x是正数,b23=0,b22=1;
////      2.如果底数不为归一化格式,调用该函数前,需对x进行底数归一化;
////      3.该函数不处理阶码,由外部自行计算;
////////////////////////////////////////////////////////////
//Sub_AutoField _Log2;
//
//    // 计算ln(x):
//    call _Ln;                                       // ln(x) = RD0*order(-1)
//    RD2=RD0;
//
//    // 计算1/ln(2)
//    RD0=0;
//    RD0_SetBit22;
//    RD0_SetBit20;
//    RD0_SetBit19;
//    RD0_SetBit18;
//    RD0_SetBit14;
//    RD0_SetBit12;
//    RD0_SetBit10;
//    RD0_SetBit8;                                    // 1/ln(2)=(1.01110001010101)2=RD0*order(0)
//
//    // 计算z=ln(x)*1/ln(10):
//    Multi24_X=RD0;
//    RD0=RD2;
//    Multi24_Y=RD0;
//    nop;
//    RD0=Multi24_XY;                                      // z=z=ln(x)*1/ln(10)=RD0*order(0)
//    RF_ShiftL1(RD0);                                // z=z=ln(x)*1/ln(10)=RD0*order(-1)
//
//    Return_AutoField(0);



////////////////////////////////////////////////////////////
////  名称:
////      _2Power
////  功能:
////      求2的幂函数; z=2^x,x=xh+xl,a=2^xh,b=xl,z=a+a*b*ln2+a*b^2*(ln2)^2/2+a*b^3*(ln2)^3/6;
////  参数:
////      1.RD1:x,24BIT FLOAT,底数为归一化格式;
////  返回值:
////      1.RD0: 2^x,order=1;
////  注释:
////      1.乘法计算时需保证D23位及更高位为符号位,乘法前需将两个乘数首位1移至D22位,并记下order.
////      2.底数为归一化格式的意义: x是正数,b23=0,b22=1;x是负数,b23=1,b22=0;;x是0,b23=0,b22=0;
////      3.如果底数不为归一化格式,调用该函数前,需对x进行底数归一化;
////      4.该函数不处理阶码,由外部自行计算.
////////////////////////////////////////////////////////////
//Sub_AutoField _2Power;
//
//    RD0 = RN_Addr_Float;
//    RA1 = RD0;                                                             // 浮点数格式加速器基址
//    RD0 = RN_Addr_2Power;
//    RA0 = RD0;                                                            // 平方根ROM基址
//
//    RD5=0x58B90B;                                                                   //  ln2 = RD5*order(-1)
//
//    // 判断x的正负
//    RD0 = RD1;
//    RD3 = RD1;
//    if(RD0_Bit23==0) goto L_2Power_0;
//    RF_Neg(RD0);
//    RD1=RD0;
//L_2Power_0:
////////////////////////////////////////////////////////////
//////计算2^(Xh)
//    // 将x分解成高低两部分:
//    M[RA1+L24Bit_ToFloat]=RD1;
//    RF_ShiftL1(RD0);
//    RD1 = 0X7FFFF;
//    RD1 &= RD0;
//    //RD1=M[RA1+Read_Float_L];                                              // b=xl=RD1*order(-1)
//    RD2 = RD1;
//    RD0=M[RA1+Read_Float_H];                                                // RD0=x的高五位的中间三位,D21,D20,D19.D22为1,忽略;D18?嬖贔lag_XH_LSB中.
//    //RF_ShiftL2(RD0);
//    // x的高位查表:
//    RD0=M[RA0+RD0];
//
//    // 根据x的D18,取查表结果的L16,H16
//    if(Flag_XH_LSB==1) goto L_2Power_1;                          // FLAG_FLOAT是D18
//    M[RA1+L16Bit_ToFloat]=RD0;
//    goto L_2Power_2;
//L_2Power_1:
//    M[RA1+H16Bit_ToFloat]=RD0;
//L_2Power_2:
//    RD0=M[RA1+Read_Float];                                                  // a=2^(xh)=RD0*order(1)
//    RD4=RD0;                                                                                // a=2^(Xh)=RD0*order(1)
//
//    //计算a*b*ln2
//    Multi24_X=RD0;
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                  // a*b=RD0*order(1)
//    Multi24_X=RD0;
//    RD1 = RD5;
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                  // a*b*ln2=RD0*order(1)
//    RD1 = RD4;
//    RD0 += RD1;
//    RD6 = RD0;                                                                              //a+a*b*ln2=RD0*order(1)
//
//    //计算a*b^2*(ln2)^2/2
//    RD0 = RD4;                                                                              //  a=2^(xh)=RD0*order(1)
//    Multi24_X=RD0;
//    RD1 = RD2;
//    Multi24_Y=RD1;                                                                      //  b=RD1*order(-1)
//    nop;
//    RD0=Multi24_XY;                                                                  // a*b=RD0*order(1)
//    Multi24_X=RD0;
//    RD1 = RD2;
//    Multi24_Y=RD1;                                                                      //  b=RD1*order(-1)
//    nop;
//    RD0=Multi24_XY;                                                                  // a*b*b=RD0*order(1)
//    Multi24_X=RD0;
//    RD1 = RD5;                                                                              //  ln2=RD1*order(-1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                  // a*b*b*ln2=RD0*order(1)
//    Multi24_X=RD0;
//    RD1 = RD5;                                                                              //  ln2=RD1*order(-1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                  // a*b*b*ln2*ln2=RD0*order(1)
//    RF_ShiftR1(RD0);                                                                    //  a*b*b*ln2*ln2/2=RD0*order(1)
//    RD1 = RD6;
//    RD0 += RD1;                                                                             //  a+a*b*ln2+a*b*b*ln2*ln2/2=RD0*order(1)
//    RD6 = RD0;
//
//    //计算a*b^3*(ln2)^3/6
//    RD0 = RD4;                                                                              //  a=2^(xh)=RD0*order(1)
//    Multi24_X=RD0;
//    RD1 = RD2;
//    Multi24_Y=RD1;                                                                      //  b=RD1*order(-1)
//    nop;
//    RD0=Multi24_XY;                                                                  // a*b=RD0*order(1)
//    Multi24_X=RD0;
//    RD1 = RD2;
//    Multi24_Y=RD1;                                                                      //  b=RD1*order(-1)
//    nop;
//    RD0=Multi24_XY;                                                                  // a*b*b=RD0*order(1)
//    Multi24_X=RD0;
//    RD1 = RD2;
//    Multi24_Y=RD1;                                                                      //  b=RD1*order(-1)
//    nop;
//    RD0=Multi24_XY;                                                                  // a*b*b*b=RD0*order(1)
//    Multi24_X=RD0;
//    RD1 = RD5;                                                                              //  ln2=RD1*order(-1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b*b*ln2=RD0*order(1)
//    Multi24_X=RD0;
//    RD1 = RD5;                                                                              //  ln2=RD1*order(-1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b*b*ln2*ln2=RD0*order(1)
//    Multi24_X=RD0;
//    RD1 = RD5;                                                                              //  ln2=RD1*order(-1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b*b*ln2*ln2*ln2=RD0*order(1)
//    Multi24_X=RD0;
//    RD0 = 0x155555;                                                                     //  1/6=RD1*order(-1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b*b*ln2*ln2*ln2/6=RD0*order(1)
//    RD1 = RD6;
//    RD0 += RD1;                                                                             //  a+a*b*ln2+a*b*b*ln2*ln2/2+a*b*b*b*ln2*ln2*ln2/6=RD0*order(1)
//    RD2 = RD0;
//
//    // 判断x的正负
//    RD0 = RD3;
//    if(RD0_Bit23==0) goto L_2Power_End;
//    RD1 = RD2;
//    call _Recip;
//    RF_ShiftR2(RD0);
//    RF_ShiftR1(RD0);
//    RD2 = RD0;
//L_2Power_End:
//    RD0 = RD2;
//    Return_AutoField (0);


////////////////////////////////////////////////////////////
////  名称:
////      _10Power
////  功能:
////      求10的幂函数; z=2^x,x=xh+xl,a=2^xh,b=xl,z=a+a*b*ln10+a*b^2*(ln10)^2/2+a*b^3*(ln10)^3/6;
////  参数:
////      1.RD0:x,24BIT FLOAT，底数为绝对值小于1的归一化格式;
////  返回值:
////      1.RD0: 10^x,浮点数;
////  注释:
////      1.乘法计算时需保证D23位及更高位为符号位,乘法前需将两个乘数首位1移至D22位,并记下order.
////      2.底数为绝对值小于1的归一化格式的意义:-1<x<1;x是正数,b23=0,b22=0;x是负数,b23=1,b22=1;
////      3.如果底数不为归一化格式,调用该函数前,需对x进行底数归一化;
////      4.精度2^-14;
////////////////////////////////////////////////////////////
//Sub_AutoField _10Power;
//    RD1=RN_Addr_Float;
//    RA1 = RD1;                                                               // 浮点数格式加速器基址
//    RD1 = RN_Addr_10Power;
//    RA0 = RD1;                                                          // 平方根ROM基址
//
//    RD5=0x49AEC6;                                                                   //  ln10 = RD5*order(1)
//
//    // 判断x的正负
//    RD1 = RD0;
//    RD3 = RD1;
//    if(RD0_Bit23==0) goto L_10Power_0;
//    RF_Neg(RD0);
//    RD1=RD0;
//    RD0 = RD3;
//    RF_GetH8(RD0);
//    RD0-=0X80;
//    if(RQ>=0)  goto L_10Power_0;
//    RD0 = 0XFC666666;
//    RD2 = RD0;
//    goto L_10Power_End;
//
//L_10Power_0:
//    RD0 = RD3;
//    RF_GetH8(RD0);
//    RD2 = RD0;
//    RD0 = 0x100;
//    RD0 -= RD2;
//    RD2 = RD0;
//    RD0 = RD1;
//    RD0_ClrByteH8;                                                                              //  RD0高8位置0
//    RD1 = RD0;
//    RD0 = RD2;
//L_10Power_10:
//    RD0--;
//    RF_ShiftR1(RD1);
//    if(RD0!=0) goto L_10Power_10;
//    RD4 = RD1;
////////////////////////////////////////////////////////////
//////计算10^(Xh)
//    // 将x分解成高低两部分:
//    RD0 = RD1;
//    RF_ShiftL1(RD0);
//    RD1 = 0X7FFFF;
//    RD0 &= RD1;                                                                         // b=xl=RD1*order(-1)
//    RF_ShiftL2(RD0);                                                                // 将xl左移四位,以便在做乘法运算时保留精度
//    RF_ShiftL2(RD0);                                                                // b=xl=RD1*order(-5)
//    RD1 = RD0;
//    RD2 = RD1;
//
//    // 使用字节编制ROM时，采用下段程序
//    //RD0 = RD4;
//    //RD0_ClrByteH8;                                                                              //  RD0高8位置0
//    //RF_RotateR16(RD0);
//    //RD0_ClrByteH16;
//
//    // 使用Dword编制ROM时，采用下段程序                                                                          //  RD0高8位置0
//    RD0 = RD4;
//    RF_RotateL8(RD0);
//    RF_GetH8(RD0);
//    RF_ShiftR2(RD0);
//    RD0_ClrBit19;
//
//    RD0=M[RA0+RD0];                                                                 // a=10^(xh)=RD0*order(3)
//    RD4=RD0;                                                                                // a=10^(Xh)=RD0*order(3)
//
//    //计算a*b*ln10
//    Multi24_X=RD0;
//    Multi24_Y=RD1;                                                                      //  b=xl=RD1*order(-5)
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b=RD0*order(-1)
//    Multi24_X=RD0;
//    RD1 = RD5;                                                                              //  ln10 = RD5*order(1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*ln10=RD0*order(1)
//    RF_ShiftR2(RD0);                                                                    //  a*b*ln10=RD0*order(3)
//    RD1 = RD4;
//    RD0 += RD1;
//    RD6 = RD0;                                                                              //  a+a*b*ln10=RD0*order(3)
//
//    //计算a*b^2*(ln2)^2/2
//    RD0 = RD4;                                                                              //  a=10^(xh)=RD0*order(3)
//    Multi24_X=RD0;
//    RD1 = RD2;
//    Multi24_Y=RD1;                                                                      //  b=xl=RD1*order(-5)
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b=RD0*order(-1)
//    Multi24_X=RD0;
//    RD1 = RD2;
//    Multi24_Y=RD1;                                                                      //  b=xl=RD1*order(-5)
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b=RD0*order(-5)
//    Multi24_X=RD0;
//    RD1 = RD5;                                                                              //  ln10=RD1*order(1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b*ln2=RD0*order(-3)
//    Multi24_X=RD0;
//    RD1 = RD5;                                                                              //  ln10=RD1*order(1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b*ln10*ln10=RD0*order(-1)
//    RF_ShiftR1(RD0);
//    RF_ShiftR2(RD0);
//    RF_ShiftR2(RD0);                                                                    //  a*b*b*ln10*ln10/2=RD0*order(3)
//    RD1 = RD6;
//    RD0 += RD1;                                                                             //  a+a*b*ln10+a*b*b*ln10*ln10/2=RD0*order(3)
//    RD6 = RD0;
//
//    //计算a*b^3*(ln2)^3/6
//    RD0 = RD4;                                                                              //  a=10^(xh)=RD0*order(3)
//    Multi24_X=RD0;
//    RD1 = RD2;
//    Multi24_Y=RD1;                                                                      //  b=xl=RD1*order(-5)
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b=RD0*order(-1)
//    Multi24_X=RD0;
//    RD1 = RD2;
//    Multi24_Y=RD1;                                                                      //  b=xl=RD1*order(-5)
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b=RD0*order(-5)
//    Multi24_X=RD0;
//    RD1 = RD2;
//    Multi24_Y=RD1;                                                                      //  b=xl=RD1*order(-5)
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b*b=RD0*order(-9)
//    Multi24_X=RD0;
//    RD1 = RD5;                                                                              //  ln10=RD1*order(1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b*b*ln2=RD0*order(-7)
//    Multi24_X=RD0;
//    RD1 = RD5;                                                                              //  ln10=RD1*order(1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b*b*ln10*ln10=RD0*order(-5)
//    Multi24_X=RD0;
//    RD1 = RD5;                                                                              //  ln10=RD1*order(1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b*b*ln10*ln10*ln10=RD0*order(-3)
//    Multi24_X=RD0;
//    RD0 = 0x155555;                                                                     //  1/6=RD0*order(-1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b*b*ln2*ln2*ln2/6=RD0*order(-3)
//    RF_ShiftR2(RD0);
//    RF_ShiftR2(RD0);
//    RF_ShiftR2(RD0);                                                                    //  a*b*b*b*ln2*ln2*ln2/6=RD0*order(3)
//    RD1 = RD6;
//    RD0 += RD1;                                                                             //  a+a*b*ln10+a*b*b*ln10*ln10/2+a*b*b*b*ln10*ln10*ln10/6=RD0*order(3)
//    RD2 = RD0;
//
//    RD0=3;
//    RF_RotateR8(RD0);
//    RD0+=RD2;
//    call _Stan;
//    RD2 = RD0;
//    // 判断x的正负
//    RD0 = RD3;
//    if(RD0_Bit23==0) goto L_10Power_End;
//    RD0=RD2;
//    call _Float_Recip;
//    RD2 = RD0;
//L_10Power_End:
//    RD0 = RD2;
//    Return_AutoField (0);




////////////////////////////////////////////////////////
//  名称:
//      sqrt_fix
//  功能:
//      定点开根号
//  参数:
//      1.RD0: 数据
//  返回值:
//      1.RD0: 结果
////////////////////////////////////////////////////////
Sub_AutoField sqrt_fix;
    push RD4;
    push RD5;
    push RD6;

#define E  RD4
#define MM RD5
#define x  RD6

    x = RD0;

    // E = log2_cpu(x) + 1;
    RF_Log(RD0);
    RD0 ++;
    E = RD0;

    // if ((E - 1) > index)
    RD1 = 8;
    RD1 -= RD0;
    if(RQ<0) goto L_sqrt_fix_0;

    // else if ((E - 1) < index)
    RD1 = 8;
    RD1 -= RD0;
    if(RQ>0) goto L_sqrt_fix_1;

    // M = x;
    RD0 = x;
    MM = RD0;
    goto L_sqrt_fix_2;

L_sqrt_fix_0:
    // M = x >> (E - 1 - index);
    RD0 = x;
    RD1 = E;
    RD1 -= 8;
    call _Rf_ShiftR_Reg;
    MM = RD0;
    goto L_sqrt_fix_2;

L_sqrt_fix_1:
    // M = x << (index + 1 - E);
    RD0 = x;
    RD1 = 8;
    RD1 -= E;
    call _Rf_ShiftL_Reg;
    MM = RD0;

    // if ((M & 0x1) == 1)
L_sqrt_fix_2:
    RD0 = MM;

    if(RD0_Bit0 == 0) goto L_sqrt_fix_3;
    // M += 2;
    MM += 2;

L_sqrt_fix_3:


    // M = M >> 1;
    RD0 = MM;
    RF_ShiftR1(RD0);
    MM = RD0;
    goto L_sqrt_fix_4;


L_sqrt_fix_4:


    // if (E & 0x1 == 1)
    RD0 = E;
    if(RD0_Bit0 == 0) goto L_sqrt_fix_5;
    // E = E + 1;
    E ++;
    // M = M >> 1;
    RF_ShiftR1(MM);

L_sqrt_fix_5:
    // E = E >> 1;
    RF_ShiftR1(E);


    // if (M == N)
    RD1 = MM;
    RD1 -= 128;
    if(RQ_nZero) goto L_sqrt_fix_6;
    // M -= 1;
    MM --;

L_sqrt_fix_6:
    RD0 = MM;


    RF_ShiftL1(RD0);
    RD1 = RN_Sqrt_Table_ADDR;
    RF_GetL16(RD1);
    RF_ShiftL2(RD1);
    RD0 += RD1;
    call ConstROM_Read_Word;

    RD1 = E;
    call _Rf_ShiftL_Reg;

#undef E
#undef MM
#undef x

    pop RD6;
    pop RD5;
    pop RD4;

    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      log2_fix
//  功能:
//      定点求log2
//  参数:
//      1.RD0: 数据
//  返回值:
//      1.RD0: 结果（q15）
////////////////////////////////////////////////////////
Sub_AutoField log2_fix;

    push RD4;
    push RD5;
    push RD6;

#define E  RD4
#define MM RD5
#define x  RD6

    x = RD0;

    // 1. 计算E和M，根据公式 x = 2^E * M,  E为正整数 ， M为[0.5~1]的数
    // E = log2(x) + 1;             // 汇编有CPU指令支持
    RF_Log(RD0);
    RD0 ++;
    E = RD0;

    // if (E > index)
    RD1 = 8;
    RD1 -= RD0;
    if(RQ<0) goto L_log2_fix_0;

    // else if (E < index)
    RD1 = 8;
    RD1 -= RD0;
    if(RQ>0) goto L_log2_fix_1;

    // M = x - N;
    RD0 = x;
    RD0 -= 128;
    MM = RD0;
    goto L_log2_fix_2;

L_log2_fix_0:
    // M = (x >> (E-index)) - N;
    RD0 = x;
    RD1 = E;
    RD1 -= 8;
    call _Rf_ShiftR_Reg;
    RD0 -= 128;
    MM = RD0;
    goto L_log2_fix_2;

L_log2_fix_1:
    // M = (x << (index - E)) - N;
    RD0 = x;
    RD1 = 8;
    RD1 -= E;
    call _Rf_ShiftL_Reg;
    RD0 -= 128;
    MM = RD0;

L_log2_fix_2:
    // 2. 以M为地址读取结果
    //rst = (E<<15) + log2_table[M];
    RD0 = E;
    RD1 = 15;
    call _Rf_ShiftL_Reg;
    RD2 = RD0;

    RD0 = MM;
    RF_ShiftL1(RD0);
    RD1 = RN_Log2_Table_ADDR;
    RF_GetL16(RD1);
    RF_ShiftL2(RD1);
    RD0 += RD1;
    call ConstROM_Read_Word;
    RD0 += RD2;

#undef E
#undef MM
#undef x

    pop RD6;
    pop RD5;
    pop RD4;

    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      power_fix
//  功能:
//      定点求Power = 10^(RD0/10)
//  参数:
//      1.RD0: 数据
//  返回值:
//      1.RD0: 结果（32q8）
////////////////////////////////////////////////////////
Sub_AutoField power_fix;

    push RD4;
    push RD5;
    push RD6;
    push RD7;

#define E  RD4
#define MM RD5
#define x  RD6
#define r  RD7

    x = RD0;

    // 1. 计算x = Level*0.33219 = (Level*10885)/Q15
    // x = level * 10885;
//    RD0 = 10885;
//    Multi24_X=RD0;
//    RD0 = x;
//    Multi24_Y=RD0;
//    nop;
//    RD0=Multi24_XY;
//    RD0_ClrByteH8;
    //x = RD0;

    RD1 = 10885;
    call _Rs_Multi;

    //x >>= 15;
    RD1 = 15;
    call _Rf_ShiftR_Reg;
    x = RD0;

    // 2. 计算E和r，根据公式 x = (E+1) + (r-1),  E为正整数 ， r为[0,1)的数
    // E = (x >> 8) + 1;               // x是16q8，低8位为小数
    //RD0 = x;
    RD1 = 8;
    call _Rf_ShiftR_Reg;
    RD0 ++;
    E = RD0;

    // r = x & 0xFF;
    RD0 = x;
    RF_GetL8(RD0);
    r = RD0;

    //  if ((r & 0x1) == 1)         // 判bit0是否为1
    if(RD0_Bit0 == 0) goto L_power_fix_0;
    //r += 2;
    r += 2;

L_power_fix_0:
    //r = r >> 1;                   // 移剩下的1
    RF_ShiftR1(r);

    // 如果r==N,r-=1
    // if (r == N)
    RD1 = 128;
    RD1 -= r;
    if(RQ_nZero) goto L_power_fix_1;
    // r -= 1;
    r --;
L_power_fix_1:

    // 2. 以M为地址读取结果
    //rst = (1 << E) * exp2_table[r];
    RD0 = E;
    RF_Exp(RD0);
    RD2 = RD0;

    RD0 = r;
    RF_ShiftL1(RD0);
    RD1 = RN_Pow2_Table_ADDR;
    RF_GetL16(RD1);
    RF_ShiftL2(RD1);
    RD0 += RD1;
    call ConstROM_Read_Word;
    RD1 = RD2;

    call _Rs_Multi;
//    Multi24_X=RD1;
//    //RD0 = x;
//    Multi24_Y=RD0;
//    nop;
//    RD0=Multi24_XY;
//    RD0_ClrByteH8;

#undef E
#undef MM
#undef x
#undef r

    pop RD7;
    pop RD6;
    pop RD5;
    pop RD4;

    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      recip_fix_Q7
//  功能:
//      定点求倒数
//  参数:
//      1.RD0: 数据(q7)
//  返回值:
//      1.RD0: 结果（q7）
////////////////////////////////////////////////////////
Sub_AutoField recip_fix_Q7;
    call recip_fix;
    RF_ShiftR2(RD0);
    RF_ShiftR2(RD0);
    RF_ShiftR2(RD0);
    RF_ShiftR2(RD0);
    RF_ShiftR1(RD0);
    Return_AutoField(0);
////////////////////////////////////////////////////////
//  名称:
//      recip_fix
//  功能:
//      定点求倒数
//  参数:
//      1.RD0: 数据(q0)
//  返回值:
//      1.RD0: 结果（q23）
////////////////////////////////////////////////////////
Sub_AutoField recip_fix;

    push RD4;
    push RD5;
    push RD6;

#define E  RD4
#define MM RD5
#define x  RD6

    RD2 = 0;
    if(RD0_Bit31 == 0) goto L_recip_fix_2;
    RD2 = 1;
    RF_Not(RD0);
    RD0 ++;
L_recip_fix_2:
    // 1. 计算E和M，根据公式 x = 2^E * M,  E为正整数 ， M为[0.5~1)的数
    // E = log2(x);                 // 汇编有CPU指令支持
    x = RD0;
    RF_Log(RD0);
    E = RD0;

    // M = x << index;                 // 汇编可优化成移位
    RD0 = x;
    RD1 = 8;
    call _Rf_ShiftL_Reg;
    MM = RD0;

    // M = M >> (E);                   // 先移log2(x)-1    目的是四舍五入
    RD0 = MM;
    RD1 = E;
    call _Rf_ShiftR_Reg;
    MM = RD0;

    // if ((M & 0x1) == 1)             // 判bit0是否为1
    if(RD0_Bit0 == 0) goto L_recip_fix_0;
    // M += 2;
    MM += 2;

L_recip_fix_0:
    // M = (M >> 1) - 128;                 // 移剩下的1
    RD0 = MM;
    RF_ShiftR1(RD0);
    RD0 -= 128;
    MM = RD0;

    // 2. 以M为地址读取结果
    // 如果M==N,M-=1
    // if (M == N)
    RD1 = 128;
    RD0 = MM;
    RD1 -= RD0;
    if(RQ_nZero) goto L_recip_fix_1;
    // M -= 1;
    MM --;

L_recip_fix_1:
    // rst = recip_table[M] >> (E);
    RD0 = MM;
    RD1 = RN_Recip_Table_ADDR;
    RA0 = RD1;
    RD0 = M[RA0+RD0];

    RD1 = E;
    call _Rf_ShiftR_Reg;

#undef E
#undef MM
#undef x
    RD1 = 1;
    RD1 ^= RD2;
    if(RQ_nZero) goto L_recip_fix_End;
    RF_Not(RD0);
    RD0 ++;
L_recip_fix_End:

    pop RD6;
    pop RD5;
    pop RD4;

    Return_AutoField(0);

END SEGMENT
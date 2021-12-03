#define _MEMORY_F_

#include <CPU11.def>
#include <Memory.def>

CODE SEGMENT Memory_F;

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
//////////////      XL操作            //////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////

//寄存器传参方式,调用方式见示例
////////////////////////////
//_Mem_Clear_Reg
//功能:Memory 指定长度清0
//调用方式:见示例
//破坏 RD0
//入口:长度,首地址
//使用示例
/*
    Set_LoopNum = 32;                                   // 参数——长度
    Maddr_WriteAuto = RA0;                              // 参数——首地址,等号右边可以为各种寻址方式;
    call _Mem_Clear_Reg;                                // 0 => dest; 破坏RD0; dest为指定模长;[]=_Mem_Clear_Reg(Set_LoopNum,Maddr_WriteAuto);in:Set_LoopNum,Maddr_WriteAuto; out:none;
*/
////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_Clear_Reg;
    RD0 = 0;
_Mem_Clear_Reg_Loop:
    Mx = RD0;
    goto _Mem_Clear_Reg_Loop;



////////////////////////////
//_Mem_Copy_Reg
//功能:Memory 由源拷贝至目标
//调用方式:见示例
//破坏 RD0
//入口:长度,源首址,目标地址
// 使用示例
/*
    Set_LoopNum = 32;                                   // 参数——长度
    Set_AutoMemAlt;                                     // 必须有
    Maddr_ReadAuto = RA0++;                             // 参数——源地址
    Maddr_WriteAuto = RA0;                              // 参数——目标地址
    call _Mem_Copy_Reg;                                 // src => dest; 破坏RD0; dest,src为指定模长;[]=_Mem_Copy_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
//////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_Copy_Reg;
_Mem_Copy_Reg_Loop:
    RD0 = Mx;
    Mx = RD0;
    goto _Mem_Copy_Reg_Loop;



/////////////////////////////
//_Mem_Add_AB_Reg
//功能:Memory 由源加至目标
//调用方式:见示例
//破坏 RD0
//入口:长度,源首址,目标地址
//使用示例
/*
    Set_LoopNum = 32;                                   // 参数——长度
    Set_AutoMemAlt;                                     // 必须有
    Maddr_ReadAuto = RA0;                               // 参数——源地址
    Maddr_WriteAuto = RA1;                              // 参数——目标地址
    call _Mem_Add_AB_Reg;                               // dest+=src,破坏RD0;src,dest为指定模长;[]=_Mem_Add_AB_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_Add_AB_Reg;
    RD0 = 0;
    RD0 += RD0;
_Mem_Add_AB_Reg_Loop:
    RD0 = Mx;
    Mxx ^+= RD0;
    goto _Mem_Add_AB_Reg_Loop;

/////////////////////////////
//_Mem_Aequ2B_Reg
//功能:Memory 由源加至目标
//调用方式:见示例
//破坏 RD0
//入口:长度,源首址,目标地址
//使用示例
/*
    Set_LoopNum = 32;                                   // 参数——长度
    Set_AutoMemAlt;                                     // 必须有
    Maddr_ReadAuto = RA0;                               // 参数——源地址
    Maddr_WriteAuto = RA1;                              // 参数——目标地址
    call _Mem_Add_AB_Reg;                               // dest+=src,破坏RD0;src,dest为指定模长;[]=_Mem_Add_AB_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_Aequ2B_Reg;
    RD0 = 0;
    RD0 += RD0;
_Mem_Aequ2B_Reg_Loop:
    RD0 = Mx;
    RD0 ^+= RD0;
    Mx = RD0;
    goto _Mem_Aequ2B_Reg_Loop;


/////////////////////////////
//_Mem_Sub_AB_Reg
//功能:Memory 目标减源至目标
//调用方式:见示例
//破坏 RD0
//入口:长度,源首址,目标地址
//使用示例
/*
    Set_LoopNum = 32;                                   // 参数——长度
    Set_AutoMemAlt;                                     // 必须有
    Maddr_ReadAuto = RA0;                               // 参数——源地址
    Maddr_WriteAuto = RA1;                              // 参数——目标地址
    call _Mem_Sub_AB_Reg;                               // dest-=src,破坏RD0;src,dest为指定模长;[]=_Mem_Sub_AB_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_Sub_AB_Reg;
    RD0 = Mx;
    RF_Neg(RD0);
    Mxx += RD0;
    nop;
_Mem_Sub_AB_Loop:
    RD0 = Mx;
    RF_Not(RD0);
    Mxx ^+= RD0;
    goto _Mem_Sub_AB_Loop;


//=======================================
//长整数 A (+/-) n*B 操作,寄存器传参方式
//=======================================

/////////////////////////////////////////
//_Mem_Sub_A2B_Reg
//功能：Memory  A -= 2B;
//调用方式：call _Mem_Sub_A2B_Reg; 见示例
//破坏：RD0
//入口：长度.源首址(B).目标首址(A)
//使用示例
/*
    Set_LoopNum = 32;                                   // 参数——长度
    Set_AutoMemAlt;                                     // 必须有
    Maddr_ReadAuto = RA0;                               // 参数——源地址
    Maddr_WriteAuto = RA1;                              // 参数——目标地址
    call _Mem_Sub_A2B_Reg;                               // dest-=2src,破坏RD0;src,dest为指定模长;[]=_Mem_Sub_A2B_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_Sub_A2B_Reg;
    RD1 = 0;
    RD2 = 0;
    RD3 = 0;
_Mem_Sub_A2B_Loop:
    RD0 = Mx;
    RD2 = RD0;
    RD0 += RD3;
    RD3 = 0;
    RD3 ^+= RD1;
    RD0  += RD2;
    RD3 ^+= RD1;
    Mxx -= RD0;
    if(RQ_nBorrow) goto _Mem_Sub_A2B_Loop;
    RD3 += 1;
    goto _Mem_Sub_A2B_Loop;


/////////////////////////////////////////
//_Mem_Sub_A3B_Reg
//功能：Memory  A -= 3B;
//调用方式：call _Mem_Sub_A3B_Reg; 见示例
//破坏：RD0.RD1
//入口：长度.源首址(B).目标首址(A)
//使用示例
/*
    Set_LoopNum = 32;                                   // 参数——长度
    Set_AutoMemAlt;                                     // 必须有
    Maddr_ReadAuto = RA0;                               // 参数——源地址
    Maddr_WriteAuto = RA1;                              // 参数——目标地址
    call _Mem_Sub_A3B_Reg;                              // dest-=3src,破坏RD0,RD1;src,dest为指定模长;[]=_Mem_Sub_A3B_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_Sub_A3B_Reg;
    RD1 = 0;
    RD2 = 0;
    RD3 = 0;
_Mem_Sub_A3B_Loop:
    RD0 = Mx;
    RD2 = RD0;        //加上次循环CarryOut
    RD0 += RD3;
    RD3 = 0;
    RD3 ^+= RD1;
    RD0  += RD2;
    RD3 ^+= RD1;
    RD0  += RD2;        //3*B
    RD3 ^+= RD1;
    Mxx -= RD0;
    if(RQ_nBorrow) goto _Mem_Sub_A3B_Loop;
    RD3 += 1;
    goto _Mem_Sub_A3B_Loop;

/////////////////////////////////////////
//_Mem_Sub_A4B
//功能：Memory  A -= 4B;
//调用方式：call _Mem_Sub_A4B_Reg; 见示例
//破坏：RD0.RD1
//入口：RA0：源首址(B).
//      RA1：目标首址(A)
//调用方式：
/////////////////////////////////////////
Sub _Mem_Sub_A4B;
    Set_AutoMemAlt;                                     // 必须有
    Maddr_ReadAuto = RA0;                               // 参数——源地址
    Maddr_WriteAuto = RA1;    
    call _Mem_Sub_A2B_Reg;
    Set_AutoMemAlt;                                     // 必须有
    Maddr_ReadAuto = RA0;                               // 参数——源地址
    Maddr_WriteAuto = RA1;    
    call _Mem_Sub_A2B_Reg;    
Return(0*MMU_BASE);



/////////////////////////////////////////
//_Mem_Sub_A5B
//功能：Memory  A -= 5B;
//调用方式：call _Mem_Sub_A5B; 见示例
//破坏：RD0.RD1
//入口：RA0：源首址(B).
//      RA1：目标首址(A)
//调用方式：
/////////////////////////////////////////
Sub _Mem_Sub_A5B;
    Set_AutoMemAlt;                                     // 必须有
    Maddr_ReadAuto = RA0;                               // 参数——源地址
    Maddr_WriteAuto = RA1;
    call _Mem_Sub_A3B_Reg;
    Set_AutoMemAlt;                                     // 必须有
    Maddr_ReadAuto = RA0;                               // 参数——源地址
    Maddr_WriteAuto = RA1;    
    call _Mem_Sub_A2B_Reg;    
Return(0*MMU_BASE);


/////////////////////////////////////////
//_Mem_Sub_A6B
//功能：Memory  A -= 6B;
//调用方式：call _Mem_Sub_A6B; 见示例
//破坏：RD0.RD1
//入口：RA0：源首址(B).
//      RA1：目标首址(A)
//      长度提前由Set_LoopNum端口写入
//示例：Set_LoopNum = 32;
//      call _Mem_Sub_A6B;
/////////////////////////////////////////
Sub _Mem_Sub_A6B;
    Set_AutoMemAlt;                                     // 必须有
    Maddr_ReadAuto = RA0;                               // 参数——源地址
    Maddr_WriteAuto = RA1;    
    call _Mem_Sub_A3B_Reg;
    Set_AutoMemAlt;                                     // 必须有
    Maddr_ReadAuto = RA0;                               // 参数——源地址
    Maddr_WriteAuto = RA1;    
    call _Mem_Sub_A3B_Reg;    
Return(0*MMU_BASE);


/////////////////////////////////////////
//_Mem_Sub_A7B
//功能：Memory  A -= 7B;
//调用方式：call _Mem_Sub_A7B; 见示例
//破坏：RD0.RD1
//入口：RA0：源首址(B).
//      RA1：目标首址(A)
//      长度提前由Set_LoopNum端口写入
//示例：Set_LoopNum = 32;
//      call _Mem_Sub_A6B;
/////////////////////////////////////////
Sub _Mem_Sub_A7B;
    Set_AutoMemAlt;                                     // 必须有
    Maddr_ReadAuto = RA0;                               // 参数——源地址
    Maddr_WriteAuto = RA1;    
    call _Mem_Sub_A3B_Reg;
    Set_AutoMemAlt;                                     // 必须有
    Maddr_ReadAuto = RA0;                               // 参数——源地址
    Maddr_WriteAuto = RA1;    
    call _Mem_Sub_A2B_Reg; 
    Set_AutoMemAlt;                                     // 必须有
    Maddr_ReadAuto = RA0;                               // 参数——源地址
    Maddr_WriteAuto = RA1;    
    call _Mem_Sub_A2B_Reg;    
Return(0*MMU_BASE);



//=======================================
//长整数 Shift 操作,寄存器传参方式
//=======================================

/////////////////////////////////////////
//_Mem_ShiftL1_Reg
//功能：Memory指定长度左移1位
//调用方式：call _Mem_ShiftL1_Reg;见示例
//破坏：RD0.RD1
//入口：长度.源首址.目标首址（源＝目标）
/////////////////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_ShiftL1_Reg;
    RD1 = 0;
    RD3 = 1;
_Mem_ShiftL1_Loop:
    RD0 = Mx;
    RD2 = RD0;
    RF_ShiftL1(RD0);
    RD0 += RD1;
    Mx = RD0;
    RD1 = RD2;
    RF_RotateL1(RD1);
    RD1 &= RD3;
    goto _Mem_ShiftL1_Loop;

/////////////////////////////////////////
//_Mem_ShiftL2_Reg
//功能：Memory指定长度左移2位
//调用方式：call _Mem_ShiftL2_Reg; 见示例
//破坏：RD0.RD1
//入口：长度.源首址.目标地址（源＝目标）
//使用示例
/*
    Set_LoopNum = 32;                                   // 参数——长度
    Set_AutoMemAlt;                                     // 必须有
    Maddr_ReadAuto = RA0;                               // 参数——源地址
    Maddr_WriteAuto = RA0;                              // 参数——目标地址
    call _Mem_ShiftL2_Reg;                              // dest=src<<2,破坏RD0,RD1;src,dest为指定模长;[]=_Mem_ShiftL2_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_ShiftL2_Reg;
    RD1 = 0;
    RD3 = 3;
_Mem_ShiftL2_Loop:
    RD0 = Mx;
    RD2 = RD0;
    RF_ShiftL2(RD0);
    RD0 += RD1;
    Mx = RD0;
    RD1 = RD2;
    RF_RotateL2(RD1);
    RD1 &= RD3;
    goto _Mem_ShiftL2_Loop;


/////////////////////////////////////////
//_Mem_ShiftL3_Reg
//功能：Memory指定长度左移3位
//调用方式：call _Mem_ShiftL3_Reg; 见示例
//破坏：RD0.RD1
//入口：长度.源首址.目标地址（源＝目标）
//使用示例
/*
    Set_LoopNum = 32;                                   // 参数——长度
    Set_AutoMemAlt;                                     // 必须有
    Maddr_ReadAuto = RA0;                               // 参数——源地址
    Maddr_WriteAuto = RA0;                              // 参数——目标地址
    call _Mem_ShiftL3_Reg;                              // dest=src<<3,破坏RD0,RD1;src,dest为指定模长;[]=_Mem_ShiftL3_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_ShiftL3_Reg;
    RD1 = 0;
    RD3 = 7;
_Mem_ShiftL3_Loop:
    RD0 = Mx;
    RD2 = RD0;
    RF_ShiftL2(RD0);
    RF_ShiftL1(RD0);
    RD0 += RD1;
    Mx = RD0;
    RD1 = RD2;
    RF_RotateL2(RD1);
    RF_RotateL1(RD1);
    RD1 &= RD3;
    goto _Mem_ShiftL3_Loop;


/////////////////////////////////////////
//_Mem_ShiftL4_Reg
//功能：Memory指定长度左移4位
//调用方式：call _Mem_ShiftL4_Reg; 见示例
//破坏：RD0.RD1
//入口：长度.源首址.目标地址（源＝目标）
//使用示例
/*
    Set_LoopNum = 32;                                   // 参数——长度
    Set_AutoMemAlt;                                     // 必须有
    Maddr_ReadAuto = RA0;                               // 参数——源地址
    Maddr_WriteAuto = RA0;                              // 参数——目标地址
    call _Mem_ShiftL4_Reg;                              // dest=src<<4,破坏RD0,RD1;src,dest为指定模长;[]=_Mem_ShiftL4_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_ShiftL4_Reg;
    RD1 = 0;
    RD3 = 0xf;
_Mem_ShiftL4_Loop:
    RD0 = Mx;
    RD2 = RD0;
    RF_ShiftL2(RD0);
    RF_ShiftL2(RD0);
    RD0 += RD1;
    Mx = RD0;
    RD1 = RD2;
    RF_RotateL4(RD1);
    RD1 &= RD3;
    goto _Mem_ShiftL4_Loop;


/////////////////////////////////////////
//_Mem_ShiftL8_Reg
//功能：Memory指定长度左移8位
//调用方式：call _Mem_ShiftL8_Reg; 见示例
//破坏：RD0.RD1
//入口：长度.源首址.目标地址（源＝目标）
//使用示例
/*
    Set_LoopNum = 32;                                   // 参数——长度
    Set_AutoMemAlt;                                     // 必须有
    Maddr_ReadAuto = RA0;                               // 参数——源地址
    Maddr_WriteAuto = RA0;                              // 参数——目标地址
    call _Mem_ShiftL8_Reg;                              // dest=src<<8,破坏RD0,RD1;src,dest为指定模长;[]=_Mem_ShiftL8_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_ShiftL8_Reg;
    RD1 = 0;
    RD3 = 0xff;
_Mem_ShiftL8_Loop:
    RD0 = Mx;
    RD2 = RD0;
    RF_RotateL8(RD0);
    RD0_ClrByteL8;
    RD0 += RD1;
    Mx = RD0;
    RD1 = RD2;
    RF_RotateL8(RD1);
    RD1 &= RD3;
    goto _Mem_ShiftL8_Loop;


/////////////////////////////////////////
//_Mem_ShiftL16_Reg
//功能：Memory指定长度左移16位
//调用方式：call _Mem_ShiftL8_Reg; 见示例
//破坏：RD0.RD1
//入口：长度.源首址.目标地址（源＝目标）
//使用示例
/*
    Set_LoopNum = 32;                                   // 参数——长度
    Set_AutoMemAlt;                                     // 必须有
    Maddr_ReadAuto = RA0;                               // 参数——源地址
    Maddr_WriteAuto = RA0;                              // 参数——目标地址
    call _Mem_ShiftL16_Reg;                             // dest=src<<16,破坏RD0,RD1;src,dest为指定模长;[]=_Mem_ShiftL16_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_ShiftL16_Reg;
    RD1 = 0;
    RD3 = 0xffff;
_Mem_ShiftL16_Loop:
    RD0 = Mx;
    RD2 = RD0;
    RF_RotateL16(RD0);
    RD0_ClrByteL16;
    RD0 += RD1;
    Mx = RD0;
    RD1 = RD2;
    RF_RotateL16(RD1);
    RD1 &= RD3;
    goto _Mem_ShiftL16_Loop;

/////////////////////////////////////////
//_Mem_ShiftR1_Reg
//功能：Memory指定长度右移1位
//调用方式：call _Mem_ShiftR1_Reg;
//         与示例  _Mem_ShiftL1_Reg相同
//破坏：RD0.RD1
//入口：长度.源首址.目标首址（源＝目标+MMU_BASE）
//注意: 长度MAX=M_OperModLen-1,M[M_OperModLen]=>M[M_OperModLen-1]
//使用示例
/*
    Set_LoopNum = 32;                                   // 参数——长度,长度MAX=M_OperModLen-1,M[M_OperModLen]=>M[M_OperModLen-1]
    Set_AutoMemAlt;                                     // 必须有
    Maddr_ReadAuto = RA0+1*MMU_B ASE;                   // 参数——源地址,源＝目标+MMU_BASE
    Maddr_WriteAuto = RA0;                              // 参数——目标地址
    call _Mem_ShiftR1_Reg;                              // dest=src>>1,破坏RD0,RD1;src,dest为指定模长;[]=_Mem_ShiftL1_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////////////////

sub(Para_Normal,Para_MemWrite) _Mem_ShiftR1_Reg;
    RD0 = 0;
    RD0_SetBit31;
    RD3 = RD0;
_Mem_ShiftR1_Loop:
    RD0 = Mx;             //源
    RF_RotateR1(RD0);
    RD0 &= RD3;           //目标最高位
    RD1 = Mx;             //目标
    RF_ShiftR1(RD1);
    RD0 |= RD1;
    Mx = RD0;
    goto _Mem_ShiftR1_Loop;






/////////////////////////////////////////
//_Mem_Zero_Reg
//功能：判断Memory指定长度是否为0
//调用方式：call _Mem_Zero_Reg; 见示例
//破坏：RD0.RD1
//入口：长度+1.源首址
//出口：RD1
//使用示例
/*
    RD0=M_BufQ0;
    RA0=RD0;
    RD0=M_OperModLen;
    RD0++;
    Set_LoopNum = RD0;                                  // 参数——长度,RD0=M_OperModLen+1
    Maddr_ReadAuto = RA0;                               // 参数——源地址
    call _Mem_Zero_Reg;                                 // src==0,破坏RD0,RD1;dest为指定模长; [RD1]=_Mem_Zero_Reg(Set_LoopNum,Maddr_ReadAuto);in:Set_LoopNum,Maddr_ReadAuto;out:RD1=0/none_0-X=0/none_0;
    RD0=RD1;
    if(RD0_Zero) goto L_MFGenRSAPrime_End;              // z-1==0 => z==1 => prime generated OK
*/
/////////////////////////////////////////
sub(Para_Normal,Para_MemRead) _Mem_Zero_Reg;
    RD1 = 0;
_Mem_Zero_Loop:
    RD0 = Mx;
    if(RD0_Zero) goto _Mem_Zero_Loop;
    RD1 = RD0;
    goto _Mem_Zero_Loop;



/*
/////////////////////////////////////////
//_Mem_3A_Reg使用示例
/////////////////////////////////////////
    Set_LoopNum = 32;                                   // 参数——长度
    Set_AutoMemAlt;                                     // 必须有
    Maddr_ReadAuto = RA0;                               // 参数——源地址
    Maddr_WriteAuto = RA0;                              // 参数——目标即源
    call _Mem_3A_Reg;                                   // dest=3*src,破坏RD0,RD1,RD2,RD3;src,dest为指定模长;[]=_Mem_3A_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////
//_Mem_3A_Reg
//功能:计算3A=>A;
//调用方式:见示例
//破坏 RD0,RD1,RD2,RD3;
//入口:长度,源首址,目标地址
/////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_3A_Reg;
    RD0 = 0;
    RD1 = 0;
    RD2 = 0;
    RD0 += RD0;     //ensure carry is 0
_Mem_3A_Reg_Loop:
    RD0 = Mx;
    RD3 = RD0;
    RD0 ^+= RD1;
    RD1 = 0;
    RD1 ^+=RD2; //RD2 must be 0
    RD0 += RD3;
    RD1 ^+=RD2; //RD2 must be 0
    Mxx += RD0;
    goto _Mem_3A_Reg_Loop;



/////////////////////////////
//_Mem_Add_A1_Reg
//功能:Memory   A+=1，完成后可判 Carry
//调用方式:见示例
//破坏 RD0
//入口:长度,源首址,目标地址
//使用示例
/*
    Set_LoopNum = 32;
    Set_AutoMemAlt;
    Maddr_ReadAuto = RA0;
    Maddr_WriteAuto = RA0;
    call _Mem_Add_A1_Reg;
*/
/////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_Add_A1_Reg;
    RD0 = 0;
    RD0 += RD0;
    RD0 = 1;
_Mem_Add_A1_Reg_Loop:
    RD1 = Mx;
    Mxx ^+= RD0;
    goto _Mem_Add_A1_Reg_Loop;


/////////////////////////////
//_Mem_Sub_A2_Reg
//功能:Memory A-=2，完成后可判 Borrow
//调用方式:见示例
//破坏 RD0.RD1
//入口:长度,源首址,目标地址
//使用示例
/*
    Set_LoopNum = 32;
    Set_AutoMemAlt;
    Maddr_ReadAuto = RA0;
    Maddr_WriteAuto = RA0;
    call _Mem_Sub_A2_Reg;
*/
/////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_Sub_A2_Reg;
    RD0 = -1;
    RD0 --;
    RD1 = Mx;
    Mxx += RD0;
    RD0 = -1;    
_Mem_Sub_A2_Reg_Loop:
    RD1 = Mx;
    Mxx ^+= RD0;
    goto _Mem_Sub_A2_Reg_Loop;


/////////////////////////////
//_Mem_Sub_A1_Reg
//功能:Memory A-=1，完成后可判 Borrow
//调用方式:见示例
//破坏 RD0.RD1
//入口:长度,源首址,目标地址
//使用示例
/*
    Set_LoopNum = 32;
    Set_AutoMemAlt;
    Maddr_ReadAuto = RA0;
    Maddr_WriteAuto = RA0;
    call _Mem_Sub_A2_Reg;
*/
/////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_Sub_A1_Reg;
    RD1 = -1;
    RD0 = 0;
    RD0 += RD0;
_Mem_Sub_A1_Reg_Loop: 
    RD0 = Mx;
    Mxx ^+= RD1;
    goto _Mem_Sub_A1_Reg_Loop;


/////////////////////////////
//_Mem_Madd_AB_Reg
//功能:Memory 目标异或源至目标
//调用方式:见示例
//破坏 RD0
//入口:长度,源首址,目标地址
//使用示例
/*
    Set_LoopNum = 32;                                   // 参数——长度
    Set_AutoMemAlt;                                     // 必须有
    Maddr_ReadAuto = RA0;                               // 参数——源地址
    Maddr_WriteAuto = RA1;                              // 参数——目标地址
    call _Mem_Madd_AB_Reg;                              // dest^=src,破坏RD0;src,dest为指定模长;[]=_Mem_Sub_AB_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_Madd_AB_Reg;
_Mem_Madd_AB_Reg_Loop:
    RD0 = Mx;
    Mxx ^= RD0;
    goto _Mem_Madd_AB_Reg_Loop;


//=======================================================================
//         End  XL
//=======================================================================


END SEGMENT

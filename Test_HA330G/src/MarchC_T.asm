#define _MARCHC_T_

#include <CPU11.def>
#include <MarchC.def>

CODE SEGMENT MARCHC_T;
//===============================
//函数名：Marchc_NoMMU
//功  能：32位RAM的March+C测试
//入  口：
//      1.RD2 起始地址
//      2.RD3 长度（以字节为单位）
//出  口：
//      1.RD0: 0-正确.非0-错误码
//===============================
sub_autofield Marchc_NoMMU;
    RD0 = RD2;
    RA0 = RD0;
    RD1 = RD3;
    RF_ShiftR2(RD1);

L_Marchc_M1_NoMMU:
    RD0 = 0x0;
    M[RA0++] = RD0;
    RD1--;
    if(RQ_nZero) goto L_Marchc_M1_NoMMU;

    RD0 = RD2;
    RA0 = RD0;
    RD1 = RD3;
    RF_ShiftR2(RD1);

L_Marchc_M2_NoMMU:
    RD0 = M[RA0];
    if(RD0 != 0)  goto L_Marchc_M2_Fault_NoMMU;
    RD0 = 0xffffffff;
    M[RA0++] = RD0;
    RD1--;
    if(RQ_nZero) goto L_Marchc_M2_NoMMU;

    RD0 = RD2;
    RA0 = RD0;
    RD1 = RD3;
    RF_ShiftR2(RD1);

    RD1 = RD3;
    RF_ShiftR2(RD1);

L_Marchc_M3_NoMMU:
    RD0 = M[RA0];
    RF_Not(RD0);
    if(RD0 != 0)  goto L_Marchc_M3_Fault_NoMMU;
    M[RA0++] = RD0;
    RD1--;
    if(RQ_nZero) goto L_Marchc_M3_NoMMU;

    RD0 = RD2;
    RA0 = RD0;
    RD1 = RD3;
    RA0 += RD1;
    RA0 -= 4;
    RD1 = RD3;
    RF_ShiftR2(RD1);

L_Marchc_M4_NoMMU:
    RD0 = M[RA0];
    if(RD0 != 0)  goto L_Marchc_M4_Fault_NoMMU;
    RD0 = 0xffffffff;
    M[RA0--] = RD0;
    RD1--;
    if(RQ_nZero) goto L_Marchc_M4_NoMMU;

    RD0 = RD2;
    RA0 = RD0;
    RD1 = RD3;
    RA0 += RD1;
    RA0 -= 4;
    RD1 = RD3;
    RF_ShiftR2(RD1);

L_Marchc_M5_NoMMU:
    RD0 = M[RA0];
    RF_Not(RD0);
    if(RD0 != 0)  goto L_Marchc_M5_Fault_NoMMU;
    M[RA0--] = RD0;
    RD1--;
    if(RQ_nZero) goto L_Marchc_M5_NoMMU;

    RD0 = RD2;
    RA0 = RD0;
    RD1 = RD3;
    RF_ShiftR2(RD1);

L_Marchc_M6_NoMMU:
    RD0 = M[RA0++];
    if(RD0 != 0)  goto L_Marchc_M6_Fault_NoMMU;
    RD1--;
    if(RQ_nZero) goto L_Marchc_M6_NoMMU;
    goto L_Marchc_End_NoMMU;

L_Marchc_M2_Fault_NoMMU:
    RD0 = Marchc_M2_Code;
    goto L_Marchc_End_NoMMU;

L_Marchc_M3_Fault_NoMMU:
    RD0 = Marchc_M3_Code;
    goto L_Marchc_End_NoMMU;

L_Marchc_M4_Fault_NoMMU:
    RD0 = Marchc_M4_Code;
    goto L_Marchc_End_NoMMU;

L_Marchc_M5_Fault_NoMMU:
    RD0 = Marchc_M5_Code;
    goto L_Marchc_End_NoMMU;

L_Marchc_M6_Fault_NoMMU:
    RD0 = Marchc_M6_Code;
    goto L_Marchc_End_NoMMU;

L_Marchc_End_NoMMU:
    return_autofield(0*MMU_BASE);



//===============================
//函数名：Marchc_Cache
//功  能：Cache的March+C测试
//入  口：
//      1.RD3 起始地址
//      2.RD4 长度（以字节为单位）
//出  口：
//      1.RD0: 0-正确.非0-错误码
//===============================
sub_autofield Marchc_Cache;
    Sel_Cache4Data;

    RD0 = RD3;
    RA0 = RD0;
    RD1 = RD4;
    RF_ShiftR1(RD1);

L_Marchc_M1_Cache:
    RD0 = 0x0;
    M[RA0] = RD0;
    RA0 += 2;
    RD1--;
    if(RQ_nZero) goto L_Marchc_M1_Cache;

    RD0 = RD3;
    RA0 = RD0;
    RD1 = RD4;
    RF_ShiftR1(RD1);

L_Marchc_M2_Cache:
    RD0 = M[RA0];
    RF_GetL16(RD0);
    if(RD0 != 0)  goto L_Marchc_M2_Fault_Cache;
    RD0 = 0xffff;
    M[RA0] = RD0;
    RA0 += 2;
    RD1--;
    if(RQ_nZero) goto L_Marchc_M2_Cache;

    RD0 = RD3;
    RA0 = RD0;
    RD1 = RD4;
    RF_ShiftR1(RD1);

L_Marchc_M3_Cache:
    RD0 = M[RA0];
    RF_GetL16(RD0);
    RD2 = 0xffff;
    RD0 ^= RD2;
    if(RD0 != 0)  goto L_Marchc_M3_Fault_Cache;
    M[RA0] = RD0;
    RA0 += 2;
    RD1--;
    if(RQ_nZero) goto L_Marchc_M3_Cache;

    RD0 = RD3;
    RA0 = RD0;
    RD1 = RD4;
    RA0 += RD1;
    RA0 -= 2;
    RD1 = RD4;
    RF_ShiftR1(RD1);

L_Marchc_M4_Cache:
    RD0 = M[RA0];
    RF_GetL16(RD0);
    if(RD0 != 0)  goto L_Marchc_M4_Fault_Cache;
    RD0 = 0xffff;
    M[RA0] = RD0;
    RA0 -= 2;
    RD1--;
    if(RQ_nZero) goto L_Marchc_M4_Cache;

    RD0 = RD3;
    RA0 = RD0;
    RD1 = RD4;
    RA0 += RD1;
    RA0 -= 2;
    RD1 = RD4;
    RF_ShiftR1(RD1);

L_Marchc_M5_Cache:
    RD0 = M[RA0];
    RF_GetL16(RD0);
    RD2 = 0xffff;
    RD0 ^= RD2;
    if(RD0 != 0)  goto L_Marchc_M5_Fault_Cache;
    M[RA0] = RD0;
    RA0 -= 2;
    RD1--;
    if(RQ_nZero) goto L_Marchc_M5_Cache;

    RD0 = RD3;
    RA0 = RD0;
    RD1 = RD4;
    RF_ShiftR1(RD1);

L_Marchc_M6_Cache:
    RD0 = M[RA0];
    RF_GetL16(RD0);
    RA0 += 2;
    if(RD0 != 0)  goto L_Marchc_M6_Fault_Cache;
    RD1--;
    if(RQ_nZero) goto L_Marchc_M6_Cache;
    goto L_Marchc_End_Cache;

L_Marchc_M2_Fault_Cache:
    RD0 = Marchc_M2_Code;
    goto L_Marchc_End_Cache;

L_Marchc_M3_Fault_Cache:
    RD0 = Marchc_M3_Code;
    goto L_Marchc_End_Cache;

L_Marchc_M4_Fault_Cache:
    RD0 = Marchc_M4_Code;
    goto L_Marchc_End_Cache;

L_Marchc_M5_Fault_Cache:
    RD0 = Marchc_M5_Code;
    goto L_Marchc_End_Cache;

L_Marchc_M6_Fault_Cache:
    RD0 = Marchc_M6_Code;
    goto L_Marchc_End_Cache;

L_Marchc_End_Cache:

    Sel_Cache4Inst;
    return_autofield(0*MMU_BASE);



END SEGMENT
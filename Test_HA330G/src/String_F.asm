#define _STRING_F_

#include <CPU11.def>

CODE SEGMENT STRING_F;
////////////////////////////////////////////////////////
//  名称:
//      memcpy
//  功能:
//      定长拷贝内存单元
//  参数:
//      1.len
//      2.src
//      3.dest(out)
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub memcpy;
    push RA1;
    push RA0;
    push RD2;

    RA1 = M[RSP+4*MMU_BASE];//目的
    RA0 = M[RSP+5*MMU_BASE];//源
    RD2 = M[RSP+6*MMU_BASE];//长度
    RF_ShiftR2(RD2);

    RD0 = RD2;
    if(RD0==0) goto L_memcpy_End;

L_memcpy_Intloop:
    RD0 = M[RA0++];
    M[RA1++] = RD0;
    RD2 --;
    if(RQ_nZero) goto L_memcpy_Intloop;


L_memcpy_End:
    pop RD2;
    pop RA0;
    pop RA1;
    Return(3*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      memcpy2
//  功能:
//      定长拷贝内存单元
//  参数:
//      1.RD0:len
//      2.RA0:src指向DW编址存储器
//      3.RA1:dest指向Byte编址存储器(out)
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField memcpy2;
    RF_ShiftR2(RD0);
    RD2 = RD0;
L_memcpy2_loop:
    RD0 = M[RA0];
    RA0++;
    M[RA1++] = RD0;
    RD2 --;
    if(RQ_nZero) goto L_memcpy2_loop;
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      memset
//  功能:
//      定长内存单元置数
//  参数:
//      1.长度，须是4的整倍数(单位：字节)
//      2.数值
//      3.首址(out)
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub memset;
    push RA1;

    RA1 = M[RSP+2*MMU_BASE];//目的
    RD1 = M[RSP+4*MMU_BASE];//长度
    RF_ShiftR2(RD1);//整包数
    RD0 = M[RSP+3*MMU_BASE];
L_memset_Intloop:
    M[RA1++] = RD0;
    RD1--;
    if(RQ_nZero) goto L_memset_Intloop;

    pop RA1;
    Return(3*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      memcmp
//  功能:
//      在指定长度内对比内存单元
//  参数:
//      1.RD0:长度，须是4的整倍数(单位：字节)
//      2.RA1:内存首址2
//      3.RA0:内存首址1
//  返回值:
//      1.RD0：==0 相等（包括长度为0时）
//              <0 str1<str2
//              >0 str1>str2
////////////////////////////////////////////////////////
Sub_AutoField memcmp;
    RD3 = RD0;//长度
    RF_ShiftR2(RD3);

L_memcmp_Intloop:
    RD2 = M[RA1++];
    RD0 = M[RA0++];
    RD0 -= RD2;
    if(RD0_nZero) goto L_memcmp_End;
    RD3 --;
    if(RQ_nZero) goto L_memcmp_Intloop;

L_memcmp_End:
    //RD0 = RA0;
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      memcmp2
//  功能:
//      在指定长度内对比内存单元
//  参数:
//      1.RD0:长度，须是4的整倍数(单位：字节)
//      2.RA1:内存首址2，指向Byte编址存储器
//      3.RA0:内存首址1，指向DW编址存储器
//  返回值:
//      1.RD0：==0 相等（包括长度为0时）
//              <0 str1<str2
//              >0 str1>str2
////////////////////////////////////////////////////////
Sub_AutoField memcmp2;
    RD3 = RD0;//长度
    RF_ShiftR2(RD3);

L_memcmp_Intloop2:
    RD2 = M[RA1++];
    RD0 = M[RA0];
    RA0++;
    RD0 -= RD2;
    if(RD0_nZero) goto L_memcmp_End2;
    RD3 --;
    if(RQ_nZero) goto L_memcmp_Intloop2;

L_memcmp_End2:
    //RD0 = RA0;
    Return_AutoField(0*MMU_BASE);

END SEGMENT
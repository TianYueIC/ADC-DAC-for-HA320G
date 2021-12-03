#define _RANDOM_F_

#include <CPU11.def>
#include <Random.def>
#include <resource_allocation.def>

CODE SEGMENT RANDOM_F;
//////////////////////////////////////////////////////////////////////////
//  随机数使用例程：
//  1.上电之后随机数必需预热；
//    1.1 汇编语言 RandomEnable；
//    1.2 延时时间必需1ms以上；
//    1.3 预热完成后可以关掉随机数；
//        汇编语言 RandomDisable；
//////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////
//  名称:
//      _RandomGet
//  功能:
//      按指定长度获取随机数
//  参数:
//      1.RD0:出口指针(out)
//      2.RD1:随机数长度，以Byte为单位（须是4的整倍数）
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _RandomGet;
    Random_Enable;
    RA0 = RD0;
    RF_ShiftR2(RD1);
    RD2 = RD1;
RandomGet_L1:
    RD0 = RandomData;
    RD0 ^= RandomData;
    RF_Disorder(RD0);
    RD0 += RandomData;
    RF_Reverse(RD0);
    RD0 ^= RandomData;
    RF_Disorder(RD0);
    M[RA0++] = RD0;               //RA0+=4
    RD2--;
    if(RQ_nZero) goto RandomGet_L1;
    Random_Disable;
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      Random_Gets1
//  功能:
//      按指定长度获取随机数
//  参数:
//      1.随机数长度，以Byte为单位（须是4的整倍数）
//      2.出口指针(out)
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField Random_Gets1;
    //M[RSP+0*MMU_BASE]:随机数的指针首址
    //M[RSP+1*MMU_BASE]:Length
    Random_Enable;
    RA0 = M[RSP+0*MMU_BASE];
    RD2 = M[RSP+1*MMU_BASE];
    RF_ShiftR2(RD2);

L_Random_Gets_0:
    RD0 = RandomData;
    RD0 ^= RandomData;
    RF_Disorder(RD0);
    RD0 += RandomData;
    RF_Reverse(RD0);
    RD0 ^= RandomData;
    RF_Disorder(RD0);
    M[RA0++] = RD0;               //RA0+=4
    RD2--;
    if(RQ_nZero) goto L_Random_Gets_0;
    Random_Disable;
    Return_AutoField(2*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      _Random_Get1
//  功能:
//      读取一个DWord长度的随机数
//  参数:
//      无
//  返回值:
//      1.RD0: 读取的随机数
////////////////////////////////////////////////////////
Sub_AutoField _Random_Get1;
    Random_Enable;
    RD0 = RandomData;
    RD0 ^= RandomData;
    RF_Disorder(RD0);
    RD0 += RandomData;
    RF_Reverse(RD0);
    RD0 ^= RandomData;
    RF_Disorder(RD0);
    Random_Disable;
    Return_AutoField(0*MMU_BASE);

END SEGMENT

#define _WDRC_F_

#include <CPU11.def>
#include <WDRC.def>
#include <Math.def>
#include <SOC_Common.def>
#include <string.def>
#include <Global.def>
#include <STA.def>
#include <USI.def>
#include <GPIO.def>
#include <ALU.def>
#include <AGC.def>

CODE SEGMENT WDRC_F;
//////////////////////////////////////////////////////////////////////////
//  名称:
//      loud_comp_Frame
//  功能:
//      计算WDRC增益
//  参数:
//      1.chan 通道号
//      2.dataLen 数据长度
//      3.dataBuf 数据指针
//  返回值：
//      1.RD0: dBgain
//      2.RD1: 当前帧的spl
//////////////////////////////////////////////////////////////////////////
Sub loud_comp_Frame;
  push RA2;
  push RA7;
  push RD2;
  push RD3;

  RA2 = RSP;// 入参基址
#define dataBuf   M[RA2+5*MMU_BASE]
#define dataLen   M[RA2+6*MMU_BASE]
#define chan      M[RA2+7*MMU_BASE]

    //int flag = 0;
    //short spl, dbgain, gain;
    RD0 = 4*MMU_BASE;
    RSP -= RD0;
    RA7 = RSP;// 局部变量基址
#define spl        M[RA7+0*MMU_BASE]
#define dbgain     M[RA7+1*MMU_BASE]
#define gain       M[RA7+2*MMU_BASE]

    // 1. 计算本帧声压级
    //spl = splcal_fix(dataBuf + i, FRAME_LEN, bufl[chan], corrected);  // spl : 16q8
    RD0 = corrected;
    send_para(RD0);
    RD0 = chan;
    RF_ShiftL2(RD0);
    RD1 = RD0;
    RF_ShiftL2(RD0);
    RD0 += RD1;
    RD0 += Buf1_Offset;
    RD0 += RA4;
    send_para(RD0);
    RD0 = FRAME_LEN_Word;
    send_para(RD0);
    RD0 = dataBuf;
    send_para(RD0);
    call splcal_fix;
    RD2 = RD0;

    // 观察子带内声压级(未修正)
    RD0 = MASK_CHAN_ISPL_ORG_CHECK;
    RD0 &= g_Switch;
    if(RQ_Zero) goto L_CHAN_ISPL_ORG_Check_Dis;
    push RD2;
    RD0 = RSP;
    RD1 = 4;
    call Export_Data_32bit;
    pop RD0;
L_CHAN_ISPL_ORG_Check_Dis:
    // 校准输入端声压级
    RD1 = g_Mic_Gain;
    RD0 = RD2;
    RD0 -= RD1;
    // 修正PGA增益系数
    RD2 = RD0;
    RD0 = g_G1_PGA;
    RD2 -= RD0;
    RD0 = RD2;

    RD1 = chan;
    if(RQ==0) goto L_loud_comp_Frame_CH0;
    RD1 --;
    if(RQ==0) goto L_loud_comp_Frame_CH1;
    RD1 --;
    if(RQ==0) goto L_loud_comp_Frame_CH2;
    RD1 --;
    if(RQ==0) goto L_loud_comp_Frame_CH3;
    RD1 --;
    if(RQ==0) goto L_loud_comp_Frame_CH4;
    RD1 --;
    if(RQ==0) goto L_loud_comp_Frame_CH5;
    RD1 --;
    if(RQ==0) goto L_loud_comp_Frame_CH6;
    RD1 --;
    if(RQ==0) goto L_loud_comp_Frame_CH7;

L_loud_comp_Frame_CH0:
    RD1 = RN_G2_CH0;
    goto L_DSP_Frame_WDRC;
L_loud_comp_Frame_CH1:
    RD1 = RN_G2_CH1;
    goto L_DSP_Frame_WDRC;
L_loud_comp_Frame_CH2:
    RD1 = RN_G2_CH2;
    goto L_DSP_Frame_WDRC;
L_loud_comp_Frame_CH3:
    RD1 = RN_G2_CH3;
    goto L_DSP_Frame_WDRC;
L_loud_comp_Frame_CH4:
    RD1 = RN_G2_CH4;
    goto L_DSP_Frame_WDRC;
L_loud_comp_Frame_CH5:
    RD1 = RN_G2_CH5;
    goto L_DSP_Frame_WDRC;
L_loud_comp_Frame_CH6:
    RD1 = RN_G2_CH6;
    goto L_DSP_Frame_WDRC;
L_loud_comp_Frame_CH7:
    RD1 = RN_G2_CH7;
    //goto L_DSP_Frame_WDRC;

L_DSP_Frame_WDRC:
    RD0 -= RD1;
    // 缓存当前声压级
    RD3 = RD0;
    RD2 = RD0;


//    // 计算历史4帧的统计值总和
//    RD0 = Spl_Array_Offset;
//    RD0 += RA4;
//    RA0 = RD0;
//    RD1 = chan;
//    RD0 = RD1;
//    RF_ShiftL1(RD1);
//    RD0 += RD1;
//    RF_ShiftL2(RD0);
//    RA0 += RD0;
//
//    RD0 = M[RA0];
//    RD2 += RD0;
//    RD0 = M[RA0+1*MMU_BASE];
//    RD2 += RD0;
//    RD0 = M[RA0+2*MMU_BASE];
//    RD2 += RD0;
//
//    // 滚动历史帧统计值的队列
//    RD0 = M[RA0+1*MMU_BASE];
//    M[RA0] = RD0;
//    RD0 = M[RA0+2*MMU_BASE];
//    M[RA0+1*MMU_BASE] = RD0;
//    M[RA0+2*MMU_BASE] = RD3;
    // 观察子带内声压级(已修正)
    RD0 = MASK_CHAN_ISPL_CHECK;
    RD0 &= g_Switch;
    if(RQ_Zero) goto L_CHAN_ISPL_Check_Dis;
    push RD2;
    RD0 = RSP;
    RD1 = 4;
    call Export_Data_32bit;
    pop RD0;
L_CHAN_ISPL_Check_Dis:

    // 每8帧计算一次WDRC增益
    RD0 = g_Cnt_Frame;
    RD1 = 7;
    RD0 &= RD1;
    RD1 = chan;
    RD0 ^= RD1;
    if(RQ_Zero) goto L_loud_comp_Frame_WDRC;
    goto L_loud_comp_Frame_WDRC;

    // 不计算降噪增益时，取既有增益值代替
    RD0 = Gain_WDRC_Array_Offset;
    RD0 += RA4;
    RA0 = RD0;
    RD1 = chan;
    RF_ShiftL2(RD1);
    RD0 = M[RA0+RD1];
    goto L_loud_comp_Frame_End;

L_loud_comp_Frame_WDRC:
    RD0 = RD3;

    // 确保用于评估的WDRC输入声压级为非负数
    if(RD0_Bit31 == 0) goto L_loud_comp_Frame_0;
    RD0 = 0;
L_loud_comp_Frame_0:
    spl = RD0;

L_loud_comp_Frame_4:
    // 2. 计算增益值
    //dbgain = wdrc_fix(spl, k[chan], b[chan], PART_NUM, tpi);          // dbgain : 16q8
    RD0 = RN_TPI_ADDR;
    send_para(RD0);
    RD0 = PART_NUM;
    send_para(RD0);
    RD0 = chan;
    RF_ShiftL2(RD0);
    RF_ShiftL2(RD0);
    RF_ShiftL1(RD0);
    RD0 += RA4;
    RD1 = RD0;
    RD0 += WDRC_B_Offset;
    send_para(RD0);
    RD1 += WDRC_K_Offset;
    send_para(RD1);
    RD0 = spl;
    send_para(RD0);
    call wdrc_fix;
    dbgain = RD0;

    // 更新WDRC增益
    RD1 = Gain_WDRC_Array_Offset;
    RD1 += RA4;
    RA0 = RD1;
    RD1 = chan;
    RF_ShiftL2(RD1);
    M[RA0+RD1] = RD0;
    RD1 = RD3;

L_loud_comp_Frame_End:

    RD1 = 4*MMU_BASE;
    RSP += RD1;
    RD1 = spl;

#undef dataBuf
#undef dataLen
#undef chan
#undef spl
#undef dbgain
#undef gain

    pop RD3;
    pop RD2;
    pop RA7;
    pop RA2;
    Return(3*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      splcal_fix
//  功能:
//      计算声压级（包含攻击释放）
//  参数:
//      1.k 声压级计算修正系数
//      2.buf 指向缓存数据，para指向平滑系数
//      3.len 采样点数量
//      4.x 指向输入的一帧信号，len为一帧信号长度
//  返回值：
//      1.RD0: 声压级（定点 16q8）
//////////////////////////////////////////////////////////////////////////
Sub splcal_fix;
    push RA2;
    push RA7;

    RA2 = RSP;// 入参基址
#define x       M[RA2+3*MMU_BASE]
#define len     M[RA2+4*MMU_BASE]
#define buf     M[RA2+5*MMU_BASE]
#define k       M[RA2+6*MMU_BASE]

    RD0 = 4*MMU_BASE;
    RSP -= RD0;
    RA7 = RSP;// 局部变量基址
#define p           M[RA7+0*MMU_BASE]
#define p_temp      M[RA7+1*MMU_BASE]
#define spl         M[RA7+2*MMU_BASE]
#define i           M[RA7+3*MMU_BASE]
#define p0          939;    // 16q8 : 3.67
#define splmax      30720;  // 16q8 : 120
#define q8          256;    // q8

    p = 0;
    p_temp = 0;
    spl = 0;
    i = 0;

    //计算有效声压，采用RMS算法,spl = 10*log(sum(x^2)/N)+3.67;
    // 1. 求所有点的平方和(32位)的均值
    RD0 = x;
    RD1 = FL_M2_A4_A1;
    call MeanSquareAverage;
    p = RD0;

    // 2. 计算10*log(p)
    //spl = (short)((10 * log10((double)p)) * q8);  // 16q8
    RD0 = p;
    call Float_From_Int;
    call _Float_Lg;
    RD1 = 0x03500000;//Float(10.0);
    call _Float_Multi;
    RD1 = 8;
    RF_RotateR8(RD1);
    RD0 += RD1;
    call Float_To_Int;
    RD1 = p0;
    RD0 += RD1;
    //spl = spl - k;
    RD1 = k;
    RD0 -= RD1;
    spl = RD0;
    if(RD0_Bit31==0) goto L_splcal_fix_2;
    spl = 0;
L_splcal_fix_2:
    RD1 = splmax;
    RD1 -= RD0;
    if(RQ>=0) goto L_splcal_fix_3;
    RD0 = splmax;
    spl = RD0;

L_splcal_fix_3:
    RD0 = spl;
    RA0 = buf;
    RD1 = M[RA0+0*MMU_BASE];// 上一帧的spl
    RD1 -= RD0;
    if(RQ<=0) goto L_splcal_attack;

    // 释放
    RD0 = spl;
    RD1 = g_b;
    call _Rs_Multi;
    push RD0;
    RD0 = M[RA0+0*MMU_BASE];
    RD1 = 65536;
    RD1 -= g_b;
    call _Rs_Multi;
    pop RD1;
    RD0 += RD1;
    RF_GetH16(RD0);
    M[RA0+0*MMU_BASE] = RD0;
    goto L_splcal_After_Attack_Release;

    // 攻击
L_splcal_attack:
    RD0 = spl;
    RD1 = g_a;
    call _Rs_Multi;
    push RD0;
    RD0 = M[RA0+0*MMU_BASE];
    RD1 = 65536;
    RD1 -= g_a;
    call _Rs_Multi;
    pop RD1;
    RD0 += RD1;
    RF_GetH16(RD0);
    M[RA0+0*MMU_BASE] = RD0;


L_splcal_After_Attack_Release:
    RD1 = 4*MMU_BASE;
    RSP += RD1;

#undef k
#undef buf
#undef len
#undef x
#undef p
#undef p_temp
#undef spl
#undef i
#undef p0
#undef splmax
#undef q8

    pop RA7;
    pop RA2;

    Return(4*MMU_BASE);


//////////////////////////////////////////////////////////////////////////
//  名称:
//      wdrc_fix
//  功能:
//      计算所WDRC增益值
//  参数:
//      1.int *tpi 指向各拐点及两处端点值
//      2.int part_num 表示I/O曲线从0-120dB SPL所分的段数
//      3.short *b指向当前通道的I/O曲线各直线段的参数 其中 b为16q8
//      4.short *k指向当前通道的I/O曲线各直线段的参数 其中 k为16q14
//      5.int spl 一帧信号的声压级值
//  返回值：
//      1.RD0: dBgain（定点 16q8）
//////////////////////////////////////////////////////////////////////////
Sub wdrc_fix;
    push RA0;
    push RA2;
    push RA7;
    push RD4;

    RA2 = RSP;// 入参基址
#define spl         M[RA2+5*MMU_BASE]
#define k           M[RA2+6*MMU_BASE]
#define b           M[RA2+7*MMU_BASE]
#define part_num    M[RA2+8*MMU_BASE]
#define tpi         M[RA2+9*MMU_BASE]

    RD0 = 2*MMU_BASE;
    RSP -= RD0;
    RA7 = RSP;// 局部变量基址
#define ig      M[RA7+0*MMU_BASE]
#define temp    M[RA7+1*MMU_BASE]
#define i       RD4
#define q8      256

    //for (i = 0; i<part_num; i++)
    i = 0;
    RA0 = tpi;
L_wdrc_fix_Loop:
    //判断当前spl值在曲线的哪一段
    //if (spl >= *(tpi + i) && spl <= *(tpi + i + 1))
    RD0 = spl;
    RD1 = M[RA0];
    RA0 ++;
    RD1 -= RD0;
    if(RQ>0) goto L_wdrc_fix_1;
    RD1 = M[RA0];
    RD1 -= RD0;
    if(RQ<0) goto L_wdrc_fix_1;
    //{
        //计算所需的db域增益值
        //ig = *(k + i) - q14;
        RD0 = i;
        RF_ShiftL2(RD0);
        RD0 += k;
        RA0 = RD0;
        RD0 = M[RA0];
        RD1 = q14;
        RD0 -= RD1;
        //ig = RD0;

        //ig = ig*spl;  // 16q14 放大256倍
        RD1 = spl;
        call _Rs_Multi;
        //ig = RD0;

        //ig /= 256;        // 16q14 此处应注意ig可能为负值，那么移位与除并不相同(带符号移)
        RD1 = 8;
        call _Rf_ShiftR_Signed_Reg;
        ig = RD0;

        //temp = *(b + i);// 16q8
        RD0 = i;
        RF_ShiftL2(RD0);
        RD0 += b;
        RA0 = RD0;
        RD0 = M[RA0];
        //temp = RD0;

        //temp <<= 6;       // 16q14
        RD1 = 6;
        call _Rf_ShiftL_Reg;
        //temp = RD0;

        //ig += temp;       // 16q14
        ig += RD0;

        //ig >>= 6;     // 16q8 (带符号移)
        RD0 = ig;
        RD1 = 6;
        call _Rf_ShiftR_Signed_Reg;
        ig = RD0;

        //break;
        goto L_wdrc_fix_2;
    //}

L_wdrc_fix_1:
    //end for (i = 0; i<part_num; i++)
    i ++;
    part_num --;
    if(RQ_nZero) goto L_wdrc_fix_Loop;

L_wdrc_fix_2:
    RD1 = 2*MMU_BASE;
    RSP += RD1;

    pop RD4;
    pop RA7;
    pop RA2;
    pop RA0;

#undef tpi
#undef part_num
#undef b
#undef k
#undef spl
#undef ig
#undef temp
#undef i
#undef q8
    Return(5*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      nondb2db_fix
//  功能:
//      将增益值从dB域转为线性域
//  参数:
//      1.short ig(q8)
//  返回值：
//      1.RD0: gain 正增益时输出24q7，负增益时输出25q7
//////////////////////////////////////////////////////////////////////////
Sub nondb2db_fix;
    push RD2;

#define ig         M[RSP+2*MMU_BASE]

    //gain = power_fix(ig >> 1);
    RD0 = ig;
    RF_Abs(RD0);
    RF_ShiftR1(RD0);
    call power_fix;
    RF_ShiftR1(RD0);// 从q8转到q7
    RD2 = RD0;

    RD0 = ig;
    if(RD0>=0) goto L_nondb2db_fix_End;
    RD0 = RD2;
    call recip_fix_Q7;
    RD2 = RD0;

L_nondb2db_fix_End:
    RD0 = RD2;

    pop RD2;

#undef ig
    Return(1*MMU_BASE);


END SEGMENT

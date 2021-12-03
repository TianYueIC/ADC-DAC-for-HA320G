#define _AGC_F_

#include <CPU11.def>
#include <WDRC.def>
#include <Math.def>
#include <SOC_Common.def>
#include <RN_DSP_Cfg.def>
#include <string.def>
#include <Global.def>
#include <STA.def>
#include <USI.def>
#include <GPIO.def>
#include <ALU.def>

// 参考声压级(dB)
//#define AGCI_SPL_REF         (78*256)
// 最大的AD增益下标
#define AGCI_GAIN_INDEX_MAX  (9)
// 最小的AD增益下标
#define AGCI_GAIN_INDEX_MIN  (0)
// 增益调节步长3db
#define AGCI_GAIN_STEP       (3*256)

CODE SEGMENT AGC_F;
//////////////////////////////////////////////////////////////////////////
//  名称:
//      splcal_AGC_fix
//  功能:
//      AGCO使用的计算声压级（包含攻击释放）
//  参数:
//      1.k 声压级计算修正系数
//      2.buf 指向缓存数据，para指向平滑系数
//      3.len 采样点数量
//      4.x 指向输入的一帧信号，len为一帧信号长度
//      5、para_a 攻击平缓系数 （定点 16q16）
//      6、para_b 释放平缓系数 （定点 16q16）
//  返回值：
//      1.RD0: 声压级（定点 16q8）
//////////////////////////////////////////////////////////////////////////
Sub splcal_AGC_fix;
    push RA2;
    push RA7;

    RA2 = RSP;// 入参基址
#define para_b  M[RA2+3*MMU_BASE]
#define para_a  M[RA2+4*MMU_BASE]
#define x       M[RA2+5*MMU_BASE]
#define len     M[RA2+6*MMU_BASE]
#define buf     M[RA2+7*MMU_BASE]
#define k       M[RA2+8*MMU_BASE]

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
    if(RD0_Bit31==0) goto L_splcal_AGC_fix_2;
    spl = 0;
L_splcal_AGC_fix_2:
    RD1 = splmax;
    RD1 -= RD0;
    if(RQ>=0) goto L_splcal_AGC_fix_3;
    RD0 = splmax;
    spl = RD0;

L_splcal_AGC_fix_3:
    RD0 = spl;
    RA0 = buf;
    RD1 = M[RA0+0*MMU_BASE];// 上一帧的spl
    RD1 -= RD0;
    if(RQ<=0) goto L_splcal_attack;

    // 释放
    RD0 = spl;
    RD1 = para_b;
//RD1 = AGCO_b_Offset;
//RD1 = M[RA4+RD1];
    call _Rs_Multi;
    push RD0;
    RD0 = M[RA0+0*MMU_BASE];
    RD1 = 65536;
    RD1 -= para_b;
    call _Rs_Multi;
    pop RD1;
    RD0 += RD1;
    RF_GetH16(RD0);
    M[RA0+0*MMU_BASE] = RD0;
    goto L_splcal_After_Attack_Release;

    // 攻击
L_splcal_attack:
    RD0 = spl;
    RD1 = para_a;
//RD1 = AGCO_a_Offset;
//RD1 = M[RA4+RD1];
    call _Rs_Multi;
    push RD0;
    RD0 = M[RA0+0*MMU_BASE];
    RD1 = 65536;
    RD1 -= para_a;
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
#undef para_a
#undef para_b
#undef p
#undef p_temp
#undef spl
#undef i
#undef p0
#undef splmax
#undef q8

    pop RA7;
    pop RA2;

    Return(6*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  函数名称:
//      set_ADC_Gain
//  功能:
//      设置ADC增益值
//  形参:
//      无
//  返回值：
//      无
//  入口：
//      RD0 ADC增益等级0~11, 其中2对应0db
//  出口：
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField set_ADC_Gain;
    RD2 = RD0;

    // 判断是否与Buf_ADC_GainLvNow_Offset里的一样,一样则退出
    RD1 = Buf_ADC_GainLvNow_Offset;
    RD1 = M[RA4+RD1];
    RD1 ^= RD0;
    if(RQ_Zero) goto L_set_ADC_Gain_End;

    RD1 = 0;
    RD0 -= RD1;
    if(SRQ<0) goto L_set_ADC_Gain_End;  // RD0<0 退出
    RD1 = 11;
    RD0 -= RD1;
    if(SRQ>0) goto  L_set_ADC_Gain_End;  // RD0>11 退出

    RD0 = RD2;
    RF_Exp(RD0);
    RD0--;
    RD3 = RD0;

    //ADC_Cfg 配置值
    //（HEX）"  dB
    //b000 0000 0000    -6.60
    //b000 0000 0001    -3.30
    //b000 0000 0011    0.00
    //b000 0000 0111    3.30
    //b000 0000 1111    6.60
    //b000 0001 1111    9.90
    //b000 0011 1111    13.20
    //b000 0111 1111    16.50
    //b000 1111 1111    19.80
    //b001 1111 1111    23.10
    //b011 1111 1111    26.40
    //b111 1111 1111    29.70

    //AGC调整
    ADC_CPUCtrl_Enable;
    RD0 = RN_ADCPORT_AGC0;
    ADC_PortSel = RD0;
    RD0 = RD3;// 0dB
    ADC_Cfg = RD0;
    ADC_CPUCtrl_Disable;

    // 写回Buf_ADC_GainLvNow_Offset
    RD1 = Buf_ADC_GainLvNow_Offset;
    RD0 = RD2;
    M[RA4+RD1] = RD0;

L_set_ADC_Gain_End:
    return_autofield(0);



//////////////////////////////////////////////////////////////////////////
//  函数名称:
//      get_ADC_Gain
//  功能:
//      由序号求实际增益值(Q8)
//  形参:
//      无
//  返回值：
//      无
//  入口：
//      RD0 (0~11)
//  出口：
//      RD0
//////////////////////////////////////////////////////////////////////////
Sub_AutoField get_ADC_Gain;

    RSP -= 12*MMU_BASE;
    RA0 = RSP;

    // 填充增益值
    RD1 = -3072;//-3083;
    M[RA0++] = RD1;
    RD1 = -1536;//-1541;
    M[RA0++] = RD1;
    RD1 = 0;
    M[RA0++] = RD1;
    RD1 = 768;//902;
    M[RA0++] = RD1;
    RD1 = 1536;//1541;
    M[RA0++] = RD1;
    RD1 = 2304;//2443;
    M[RA0++] = RD1;
    RD1 = 3328;//3344;
    M[RA0++] = RD1;
    RD1 = 4096;//4162;
    M[RA0++] = RD1;
    RD1 = 5120;//5120;
    M[RA0++] = RD1;
    RD1 = 6144;//6022;
    M[RA0++] = RD1;
    RD1 = 7168;//6873;
    M[RA0++] = RD1;
    RD1 = 7936;//7775;
    M[RA0++] = RD1;
    RA0 = RSP;

    RF_ShiftL2(RD0);            // RD0*MMU_BASE
    RD0 += RA0;                 // RA0+RD0*MMU_BASE
    RA1 = RD0;
    RD0 = M[RA1];               // 用序号找对应的增益值

    RSP += 12*MMU_BASE;
L_get_ADC_Gain_End:
    return_autofield(0);



//////////////////////////////////////////////////////////////////////////
//  函数名称:
//      cal_ADC_Gain
//  功能:
//      计算下一帧的ADC增益值,并更新到g_ADC_Gain,在更新前把当前帧的ADC增益值存入g_ADC_Gain_Old,提供给后续算法使用.
//  形参:
//      无
//  返回值：
//      无
//  入口：
//      RD0 当前帧声压级(Q8)
//      全局变量 g_ADC_Gain
//  出口：
//      全局变量 g_ADC_Gain, g_ADC_Gain_Next
//////////////////////////////////////////////////////////////////////////
Sub_AutoField cal_ADC_Gain;

    // RA0->agci_releFr_offset
    RD1 = agci_releFr_offset;
    RD1 += RA4;
    RA0 = RD1;

    // g_ADC_Gain_Next -> g_ADC_Gain
    RD1 = g_G1_PGA_Next;
    g_G1_PGA = RD1;

    // 根据声压级和当前帧的ADC增益计算下一帧的ADC增益 -> RD0
    // 求差值(db)
    RD1 = g_spl_ref_agci;
    RD0 -= RD1;
    RD2 = RD0;
    RF_Abs(RD0);

    // 除以AGCI_GAIN_STEP,并求整除结果
    RD3 = 0;                                        // 要调整的台阶数
    RD1 = AGCI_GAIN_STEP;
L_cal_ADC_Gain_Loop:
    RD0 -= RD1;
    if(SRQ<0) goto  L_cal_ADC_Gain_Loop_End;
    RD3 ++;
    goto L_cal_ADC_Gain_Loop;
L_cal_ADC_Gain_Loop_End:
    RD0 = RD3;
    if(RD0==0) goto L_cal_ADC_Gain_End;             // 台阶为0,表示本次不用调整AD增益

    RD0 = RD2;
    if(RD0>0) goto L_cal_ADC_Gain_2;
    RD0 = g_agci_releFr_cnt;
    RD0--;
    if(RD0==0) goto L_cal_ADC_Gain_Up;
    g_agci_releFr_cnt = RD0;
    goto L_cal_ADC_Gain_End;    // 本次不调节

L_cal_ADC_Gain_Up:
    RD0 = M[RA0];
    g_agci_releFr_cnt = RD0;    // 恢复累加器初值
    RD1 = g_G1_PGA;
    //RD1 += RD3;
    RD1 ++;
    RD0 = RD1;
    RD0 -= AGCI_GAIN_INDEX_MAX;
    if(SRQ<0) goto L_cal_ADC_Gain_3;
    RD1 = AGCI_GAIN_INDEX_MAX;
    goto L_cal_ADC_Gain_3;

L_cal_ADC_Gain_2:
    RD1 = g_G1_PGA;
    RD1 -= RD3;
    RD0 = RD1;
    RD0 -= AGCI_GAIN_INDEX_MIN;
    if(SRQ>0) goto L_cal_ADC_Gain_3;
    RD1 = AGCI_GAIN_INDEX_MIN;

L_cal_ADC_Gain_3:
    // 更新g_ADC_Gain_Next
    g_G1_PGA_Next = RD1;

L_cal_ADC_Gain_End:

    return_autofield(0);
END SEGMENT

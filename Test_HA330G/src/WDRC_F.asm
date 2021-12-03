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
//  ����:
//      loud_comp_Frame
//  ����:
//      ����WDRC����
//  ����:
//      1.chan ͨ����
//      2.dataLen ���ݳ���
//      3.dataBuf ����ָ��
//  ����ֵ��
//      1.RD0: dBgain
//      2.RD1: ��ǰ֡��spl
//////////////////////////////////////////////////////////////////////////
Sub loud_comp_Frame;
  push RA2;
  push RA7;
  push RD2;
  push RD3;

  RA2 = RSP;// ��λ�ַ
#define dataBuf   M[RA2+5*MMU_BASE]
#define dataLen   M[RA2+6*MMU_BASE]
#define chan      M[RA2+7*MMU_BASE]

    //int flag = 0;
    //short spl, dbgain, gain;
    RD0 = 4*MMU_BASE;
    RSP -= RD0;
    RA7 = RSP;// �ֲ�������ַ
#define spl        M[RA7+0*MMU_BASE]
#define dbgain     M[RA7+1*MMU_BASE]
#define gain       M[RA7+2*MMU_BASE]

    // 1. ���㱾֡��ѹ��
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

    // �۲��Ӵ�����ѹ��(δ����)
    RD0 = MASK_CHAN_ISPL_ORG_CHECK;
    RD0 &= g_Switch;
    if(RQ_Zero) goto L_CHAN_ISPL_ORG_Check_Dis;
    push RD2;
    RD0 = RSP;
    RD1 = 4;
    call Export_Data_32bit;
    pop RD0;
L_CHAN_ISPL_ORG_Check_Dis:
    // У׼�������ѹ��
    RD1 = g_Mic_Gain;
    RD0 = RD2;
    RD0 -= RD1;
    // ����PGA����ϵ��
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
    // ���浱ǰ��ѹ��
    RD3 = RD0;
    RD2 = RD0;


//    // ������ʷ4֡��ͳ��ֵ�ܺ�
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
//    // ������ʷ֡ͳ��ֵ�Ķ���
//    RD0 = M[RA0+1*MMU_BASE];
//    M[RA0] = RD0;
//    RD0 = M[RA0+2*MMU_BASE];
//    M[RA0+1*MMU_BASE] = RD0;
//    M[RA0+2*MMU_BASE] = RD3;
    // �۲��Ӵ�����ѹ��(������)
    RD0 = MASK_CHAN_ISPL_CHECK;
    RD0 &= g_Switch;
    if(RQ_Zero) goto L_CHAN_ISPL_Check_Dis;
    push RD2;
    RD0 = RSP;
    RD1 = 4;
    call Export_Data_32bit;
    pop RD0;
L_CHAN_ISPL_Check_Dis:

    // ÿ8֡����һ��WDRC����
    RD0 = g_Cnt_Frame;
    RD1 = 7;
    RD0 &= RD1;
    RD1 = chan;
    RD0 ^= RD1;
    if(RQ_Zero) goto L_loud_comp_Frame_WDRC;
    goto L_loud_comp_Frame_WDRC;

    // �����㽵������ʱ��ȡ��������ֵ����
    RD0 = Gain_WDRC_Array_Offset;
    RD0 += RA4;
    RA0 = RD0;
    RD1 = chan;
    RF_ShiftL2(RD1);
    RD0 = M[RA0+RD1];
    goto L_loud_comp_Frame_End;

L_loud_comp_Frame_WDRC:
    RD0 = RD3;

    // ȷ������������WDRC������ѹ��Ϊ�Ǹ���
    if(RD0_Bit31 == 0) goto L_loud_comp_Frame_0;
    RD0 = 0;
L_loud_comp_Frame_0:
    spl = RD0;

L_loud_comp_Frame_4:
    // 2. ��������ֵ
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

    // ����WDRC����
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
//  ����:
//      splcal_fix
//  ����:
//      ������ѹ�������������ͷţ�
//  ����:
//      1.k ��ѹ����������ϵ��
//      2.buf ָ�򻺴����ݣ�paraָ��ƽ��ϵ��
//      3.len ����������
//      4.x ָ�������һ֡�źţ�lenΪһ֡�źų���
//  ����ֵ��
//      1.RD0: ��ѹ�������� 16q8��
//////////////////////////////////////////////////////////////////////////
Sub splcal_fix;
    push RA2;
    push RA7;

    RA2 = RSP;// ��λ�ַ
#define x       M[RA2+3*MMU_BASE]
#define len     M[RA2+4*MMU_BASE]
#define buf     M[RA2+5*MMU_BASE]
#define k       M[RA2+6*MMU_BASE]

    RD0 = 4*MMU_BASE;
    RSP -= RD0;
    RA7 = RSP;// �ֲ�������ַ
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

    //������Ч��ѹ������RMS�㷨,spl = 10*log(sum(x^2)/N)+3.67;
    // 1. �����е��ƽ����(32λ)�ľ�ֵ
    RD0 = x;
    RD1 = FL_M2_A4_A1;
    call MeanSquareAverage;
    p = RD0;

    // 2. ����10*log(p)
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
    RD1 = M[RA0+0*MMU_BASE];// ��һ֡��spl
    RD1 -= RD0;
    if(RQ<=0) goto L_splcal_attack;

    // �ͷ�
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

    // ����
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
//  ����:
//      wdrc_fix
//  ����:
//      ������WDRC����ֵ
//  ����:
//      1.int *tpi ָ����յ㼰�����˵�ֵ
//      2.int part_num ��ʾI/O���ߴ�0-120dB SPL���ֵĶ���
//      3.short *bָ��ǰͨ����I/O���߸�ֱ�߶εĲ��� ���� bΪ16q8
//      4.short *kָ��ǰͨ����I/O���߸�ֱ�߶εĲ��� ���� kΪ16q14
//      5.int spl һ֡�źŵ���ѹ��ֵ
//  ����ֵ��
//      1.RD0: dBgain������ 16q8��
//////////////////////////////////////////////////////////////////////////
Sub wdrc_fix;
    push RA0;
    push RA2;
    push RA7;
    push RD4;

    RA2 = RSP;// ��λ�ַ
#define spl         M[RA2+5*MMU_BASE]
#define k           M[RA2+6*MMU_BASE]
#define b           M[RA2+7*MMU_BASE]
#define part_num    M[RA2+8*MMU_BASE]
#define tpi         M[RA2+9*MMU_BASE]

    RD0 = 2*MMU_BASE;
    RSP -= RD0;
    RA7 = RSP;// �ֲ�������ַ
#define ig      M[RA7+0*MMU_BASE]
#define temp    M[RA7+1*MMU_BASE]
#define i       RD4
#define q8      256

    //for (i = 0; i<part_num; i++)
    i = 0;
    RA0 = tpi;
L_wdrc_fix_Loop:
    //�жϵ�ǰsplֵ�����ߵ���һ��
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
        //���������db������ֵ
        //ig = *(k + i) - q14;
        RD0 = i;
        RF_ShiftL2(RD0);
        RD0 += k;
        RA0 = RD0;
        RD0 = M[RA0];
        RD1 = q14;
        RD0 -= RD1;
        //ig = RD0;

        //ig = ig*spl;  // 16q14 �Ŵ�256��
        RD1 = spl;
        call _Rs_Multi;
        //ig = RD0;

        //ig /= 256;        // 16q14 �˴�Ӧע��ig����Ϊ��ֵ����ô��λ���������ͬ(��������)
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

        //ig >>= 6;     // 16q8 (��������)
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
//  ����:
//      nondb2db_fix
//  ����:
//      ������ֵ��dB��תΪ������
//  ����:
//      1.short ig(q8)
//  ����ֵ��
//      1.RD0: gain ������ʱ���24q7��������ʱ���25q7
//////////////////////////////////////////////////////////////////////////
Sub nondb2db_fix;
    push RD2;

#define ig         M[RSP+2*MMU_BASE]

    //gain = power_fix(ig >> 1);
    RD0 = ig;
    RF_Abs(RD0);
    RF_ShiftR1(RD0);
    call power_fix;
    RF_ShiftR1(RD0);// ��q8ת��q7
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

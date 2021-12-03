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

// �ο���ѹ��(dB)
//#define AGCI_SPL_REF         (78*256)
// ����AD�����±�
#define AGCI_GAIN_INDEX_MAX  (9)
// ��С��AD�����±�
#define AGCI_GAIN_INDEX_MIN  (0)
// ������ڲ���3db
#define AGCI_GAIN_STEP       (3*256)

CODE SEGMENT AGC_F;
//////////////////////////////////////////////////////////////////////////
//  ����:
//      splcal_AGC_fix
//  ����:
//      AGCOʹ�õļ�����ѹ�������������ͷţ�
//  ����:
//      1.k ��ѹ����������ϵ��
//      2.buf ָ�򻺴����ݣ�paraָ��ƽ��ϵ��
//      3.len ����������
//      4.x ָ�������һ֡�źţ�lenΪһ֡�źų���
//      5��para_a ����ƽ��ϵ�� ������ 16q16��
//      6��para_b �ͷ�ƽ��ϵ�� ������ 16q16��
//  ����ֵ��
//      1.RD0: ��ѹ�������� 16q8��
//////////////////////////////////////////////////////////////////////////
Sub splcal_AGC_fix;
    push RA2;
    push RA7;

    RA2 = RSP;// ��λ�ַ
#define para_b  M[RA2+3*MMU_BASE]
#define para_a  M[RA2+4*MMU_BASE]
#define x       M[RA2+5*MMU_BASE]
#define len     M[RA2+6*MMU_BASE]
#define buf     M[RA2+7*MMU_BASE]
#define k       M[RA2+8*MMU_BASE]

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
    RD1 = M[RA0+0*MMU_BASE];// ��һ֡��spl
    RD1 -= RD0;
    if(RQ<=0) goto L_splcal_attack;

    // �ͷ�
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

    // ����
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
//  ��������:
//      set_ADC_Gain
//  ����:
//      ����ADC����ֵ
//  �β�:
//      ��
//  ����ֵ��
//      ��
//  ��ڣ�
//      RD0 ADC����ȼ�0~11, ����2��Ӧ0db
//  ���ڣ�
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField set_ADC_Gain;
    RD2 = RD0;

    // �ж��Ƿ���Buf_ADC_GainLvNow_Offset���һ��,һ�����˳�
    RD1 = Buf_ADC_GainLvNow_Offset;
    RD1 = M[RA4+RD1];
    RD1 ^= RD0;
    if(RQ_Zero) goto L_set_ADC_Gain_End;

    RD1 = 0;
    RD0 -= RD1;
    if(SRQ<0) goto L_set_ADC_Gain_End;  // RD0<0 �˳�
    RD1 = 11;
    RD0 -= RD1;
    if(SRQ>0) goto  L_set_ADC_Gain_End;  // RD0>11 �˳�

    RD0 = RD2;
    RF_Exp(RD0);
    RD0--;
    RD3 = RD0;

    //ADC_Cfg ����ֵ
    //��HEX��"  dB
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

    //AGC����
    ADC_CPUCtrl_Enable;
    RD0 = RN_ADCPORT_AGC0;
    ADC_PortSel = RD0;
    RD0 = RD3;// 0dB
    ADC_Cfg = RD0;
    ADC_CPUCtrl_Disable;

    // д��Buf_ADC_GainLvNow_Offset
    RD1 = Buf_ADC_GainLvNow_Offset;
    RD0 = RD2;
    M[RA4+RD1] = RD0;

L_set_ADC_Gain_End:
    return_autofield(0);



//////////////////////////////////////////////////////////////////////////
//  ��������:
//      get_ADC_Gain
//  ����:
//      �������ʵ������ֵ(Q8)
//  �β�:
//      ��
//  ����ֵ��
//      ��
//  ��ڣ�
//      RD0 (0~11)
//  ���ڣ�
//      RD0
//////////////////////////////////////////////////////////////////////////
Sub_AutoField get_ADC_Gain;

    RSP -= 12*MMU_BASE;
    RA0 = RSP;

    // �������ֵ
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
    RD0 = M[RA1];               // ������Ҷ�Ӧ������ֵ

    RSP += 12*MMU_BASE;
L_get_ADC_Gain_End:
    return_autofield(0);



//////////////////////////////////////////////////////////////////////////
//  ��������:
//      cal_ADC_Gain
//  ����:
//      ������һ֡��ADC����ֵ,�����µ�g_ADC_Gain,�ڸ���ǰ�ѵ�ǰ֡��ADC����ֵ����g_ADC_Gain_Old,�ṩ�������㷨ʹ��.
//  �β�:
//      ��
//  ����ֵ��
//      ��
//  ��ڣ�
//      RD0 ��ǰ֡��ѹ��(Q8)
//      ȫ�ֱ��� g_ADC_Gain
//  ���ڣ�
//      ȫ�ֱ��� g_ADC_Gain, g_ADC_Gain_Next
//////////////////////////////////////////////////////////////////////////
Sub_AutoField cal_ADC_Gain;

    // RA0->agci_releFr_offset
    RD1 = agci_releFr_offset;
    RD1 += RA4;
    RA0 = RD1;

    // g_ADC_Gain_Next -> g_ADC_Gain
    RD1 = g_G1_PGA_Next;
    g_G1_PGA = RD1;

    // ������ѹ���͵�ǰ֡��ADC���������һ֡��ADC���� -> RD0
    // ���ֵ(db)
    RD1 = g_spl_ref_agci;
    RD0 -= RD1;
    RD2 = RD0;
    RF_Abs(RD0);

    // ����AGCI_GAIN_STEP,�����������
    RD3 = 0;                                        // Ҫ������̨����
    RD1 = AGCI_GAIN_STEP;
L_cal_ADC_Gain_Loop:
    RD0 -= RD1;
    if(SRQ<0) goto  L_cal_ADC_Gain_Loop_End;
    RD3 ++;
    goto L_cal_ADC_Gain_Loop;
L_cal_ADC_Gain_Loop_End:
    RD0 = RD3;
    if(RD0==0) goto L_cal_ADC_Gain_End;             // ̨��Ϊ0,��ʾ���β��õ���AD����

    RD0 = RD2;
    if(RD0>0) goto L_cal_ADC_Gain_2;
    RD0 = g_agci_releFr_cnt;
    RD0--;
    if(RD0==0) goto L_cal_ADC_Gain_Up;
    g_agci_releFr_cnt = RD0;
    goto L_cal_ADC_Gain_End;    // ���β�����

L_cal_ADC_Gain_Up:
    RD0 = M[RA0];
    g_agci_releFr_cnt = RD0;    // �ָ��ۼ�����ֵ
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
    // ����g_ADC_Gain_Next
    g_G1_PGA_Next = RD1;

L_cal_ADC_Gain_End:

    return_autofield(0);
END SEGMENT

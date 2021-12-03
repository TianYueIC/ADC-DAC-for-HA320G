#define _CLASS_F_

#include <CPU11.def>
#include <Class.def>
#include <Math.def>
#include <SOC_Common.def>
#include <string.def>
#include <Global.def>
#include <STA.def>
#include <ALU.def>
#include <IIR.def>
#include <MAC.def>
#include <USI.def>
#include <Init.def>
#include <Debug.def>
#include <DMA_ALU.def>




CODE SEGMENT CLASS_F;
//////////////////////////////////////////////////////////////////////////
//  ����:
//      classFrame
//  ����:
//      ����ȷּ��㷨����ƽ��
//  ����:
//      1.��Ƶ����ָ��
//  ����ֵ��
//      1.g_class��ȫ�֣� 1~������ 2~����������� 3~������
//////////////////////////////////////////////////////////////////////////
Sub classFrame;
    push RA2;
    push RD2;

    RA2 = RSP;// ��λ�ַ
#define dataBuf   M[RA2+3*MMU_BASE]               // ��������ָ��

    // �ҳ����ֵ
    RD0 = dataBuf;
    RD1 = FL_M2_A4_A1;
    call FindMaxMin;//PATH1 ���ݰ�16λ���ո�ʽ�洢��
    RD0_SignExtL16;

    RD2 = RD0;
    RD0 = g_env_LP;
    RA0 = RD0;
    call En_GRAM_To_CPU;
    RD1 = g_classFrameCount;
    RF_ShiftL2(RD1);
    M[RA0+RD1] = RD2;
    call Dis_GRAM_To_CPU;

    g_classFrameCount ++;

//  if (g_classFrameCount >= n_frames_per_obs)
    RD1 = n_frames_per_obs;
    RD0 = g_classFrameCount;
    RD1 -= RD0;
    if(RQ>0) goto L_classFrame_00;

//      g_classFrameCount = 0;
    g_classFrameCount = 0;

//      g_class_c = classification(g_env_LP);
    call classification;
    g_class_cur = RD0;
    g_m_10 ++;

//      if (g_class_c == 1)
    RD2 = g_class_cur;
    RD2 --;
    if(RQ_Zero) goto L_classFrame_01;
//      if (g_class_c == 2)
    RD2 --;
    if(RQ_Zero) goto L_classFrame_02;
//      if (g_class_c == 3)
    RD2 --;
    if(RQ_Zero) goto L_classFrame_03;

L_classFrame_01:
    g_count_1 ++;
    goto L_classFrame_04;

L_classFrame_02:
    g_count_2 ++;
    goto L_classFrame_04;

L_classFrame_03:
    g_count_3 ++;
    //goto L_classFrame_04;

L_classFrame_04:

//      if (g_m_10 == 1)//m_10 ��ʾ m_10���ж�һ�� ��=1��1s�ж�һ��
    RD0 = g_m_10;
    RD1 = 1;
    RD1 -= RD0;
    if(RQ>0) goto L_classFrame_00;
//          if (g_count_1 >= g_count_2 && g_count_1 >= g_count_3)
//              g_class = 1;
//          if (g_count_2>g_count_1 && g_count_2 >= g_count_3)
//              g_class = 2;
//          if (g_count_3 >= g_count_1 && g_count_3 >= g_count_2)
//              g_class = 3;
    RD0 = g_count_1;
    RD1 = g_count_2;
    RD1 -= RD0;
    if(RQ<0) goto L_classFrame_05;

// ����g_count_2 >= g_count_1�����
    RD2 = 2;
    RD0 = g_count_2;
    RD1 = g_count_3;
    RD1 -= RD0;
    if(RQ<0) goto L_classFrame_06;
    RD2 = 1;
    goto L_classFrame_06;

// ����g_count_2 < g_count_1�����
L_classFrame_05:
    RD2 = 3;
    RD0 = g_count_1;
    RD1 = g_count_3;
    RD1 -= RD0;
    if(RQ<0) goto L_classFrame_06;
    RD2 = 1;

L_classFrame_06:
// �ȽϽ���
    g_class = RD2;
    g_m_10 = 0;
    g_count_1 = 0;
    g_count_2 = 0;
    g_count_3 = 0;

L_classFrame_00:
    pop RD2;
    pop RA2;

#undef dataBuf
    Return(1*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      classification
//  ����:
//      ����ȷּ��㷨
//      ������ڣ�g_env_LP��ȫ�֣�
//  ����:
//      ��
//  ����ֵ��
//      1.RD0:1~������ 2~����������� 3~������
//////////////////////////////////////////////////////////////////////////
Sub classification;
   push RA0;
   push RA1;
   push RA7;
   push RD2;
   push RD3;

#define env_LP          g_env_LP // ����ָ��

#define st_RMS          RD4
#define st_RMS1         RD5
#define st_RMS3         RD6
#define m               RD7
#define K1        0x00190019// 25

    // 1. ����RMS��������ֵ��ע�����Ƶ�7��Ӧn_frames_per_obs=128
    RD0 = env_LP;
    RD1 = L128_M2_A4_A2;
    call MeanSquareAverage;// ���ݰ�32λ�洢����16λ��Ϊ0

    // ��ƽ��
    call sqrt_fix;
    RD1 = 15;
    call _Rf_ShiftR_Reg;
    st_RMS = RD0;

    // 2. ȥֱ�� (��ALU�����м����п�������)
    // ����ֵ�ȳ�2
    RD0 = env_LP;
    RA0 = RD0;
    RD0 = Op32Bit+Rf_SftR1;
    RD1 = L128_M2_A4;
    call Cal_Single_Shift;

    // һ�ײ��
    RD0 = env_LP;
    RA0 = RD0;
    RA1 = RD0;
    RD0 = 1*MMU_BASE;
    RA0 += RD0;
    RD1 = p_env_diff+1*MMU_BASE;
    RD0 = L128_M3_A2;
    call Dual_Ser_Sub32;//PATH1 ���ݰ�32λ�洢����16λ��Ϊ0�����Ҳ��32λ�洢����16λ��Ч����λ��ȫ0��ȫ1���ֱ��Ӧ������

    // ��һ��������
    RD0 = p_env_diff;
    RA0 = RD0;
    call En_GRAM_To_CPU;
    M[RA0] = 0;
    call Dis_GRAM_To_CPU;

    // �����ʽ
    RD0 = p_env_diff;
    RA0 = RD0;
    RD0 = p_env_diff;
    RA1 = RD0;
    RD0 = L128_M3_A3;
    call Get_Imag;//PATH1

    // 3. �����˲����� ��ͨ����ͨ����ͨ
    //��ʼ��IIR_PATH1�˲���
    IIR_PATH1_Enable;
    MemSetRAM4K_Enable;
    RD0 = 0x05;// Para1, Data01
    IIR_PATH1_BANK = RD0;
    call IIR_PATH1_LP4Class;
    IIR_PATH1_Disable;
    MemSet_Disable;

    RD0 = p_env_diff;
    RA0 = RD0;
    RD0 = p_env_chan1;
    RA1 = RD0;
    RD0 = L64_M28_A1;
    call _IIR_PATH1_FiltLP4Class;

    //��ʼ��IIR_PATH1�˲���
    IIR_PATH1_Enable;
    MemSetRAM4K_Enable;
    RD0 = 0x07;// Para1, Data11
    IIR_PATH1_BANK = RD0;
    call IIR_PATH1_HP4Class;
    IIR_PATH1_Disable;
    MemSet_Disable;

    RD0 = p_env_diff;
    RA0 = RD0;
    RD0 = p_env_chan3;
    RA1 = RD0;
    RD0 = L64_M48_A1;
    call _IIR_PATH1_FiltHP4Class;

    // 4. �������� ������ALU���٣����гˣ�
    RD0 = p_env_chan1;
    send_para(RD0);
    RD0 = K1;
    RF_RotateL8(RD0);
    RF_RotateR1(RD0);
    send_para(RD0);
    RD0 = p_env_chan1;
    send_para(RD0);
    RD0 = L64_M3_A3;
    send_para(RD0);
    call MAC_MultiConst16_Q2207;

    // 5. �ֱ����RMS��������ֵ��ע�����Ƶ�7��Ӧn_frames_per_obs=128
    RD0 = p_env_chan1;
    RD1 = L64_M2_A4_A2;
    call MeanSquareAverage;
    // ��ƽ��
    call sqrt_fix;
    RD1 = 15;
    call _Rf_ShiftR_Reg;
    st_RMS1 = RD0;

    RD0 = p_env_chan3;
    RD1 = L64_M2_A4_A2;
    call MeanSquareAverage;
    // ��ƽ��
    call sqrt_fix;
    RD1 = 15;
    call _Rf_ShiftR_Reg;
    st_RMS3 = RD0;

    // 6. ������ȱ�׼��
    // m = st_RMS1 - st_RMS3;
    RD0 = st_RMS1;
    RD0 -= st_RMS3;
    m = RD0;

    // st_RMS_T1 = (st_RMS >> 8) * 102;        // 102 = T1 *256 = 0.4 * 256
    RD0 = st_RMS;
    RD1 = 8;
    call _Rf_ShiftR_Signed_Reg;
    RD1 = 102;
    call _Rs_Multi;
    RD2 = RD0;

    // st_RMS_T2 = (st_RMS >> 8) * 25;         // 25 = T2 *256 = 0.1 * 256
    RD0 = st_RMS;
    RD1 = 8;
    call _Rf_ShiftR_Signed_Reg;
    RD1 = 25;
    call _Rs_Multi;
    RD3 = RD0;

    RD0 = m;
    if(RD0_Bit31==0) goto L_classification_02;// ��Ϊ����ʹ���޷��ŷ�ʽ���бȴ�С������Ƚ�m<0�����ȫ����ΪReturn 3
    RD0 = 3;
    goto L_classification_End;

L_classification_02:
    RD2 -= RD0;
    if(RQ>0) goto L_classification_00;
    RD0 = 1;
    goto L_classification_End;

L_classification_00:
    RD3 -= RD0;
    if(RQ<0) goto L_classification_01;
    RD0 = 3;
    goto L_classification_End;
L_classification_01:
    RD0 = 2;

L_classification_End:

    pop RD3;
    pop RD2;
    pop RA7;
    pop RA1;
    pop RA0;

#undef env_LP
#undef st_RMS
#undef st_RMS1
#undef st_RMS3
#undef m
#undef p_env_diff
#undef p_env_chan1
#undef p_env_chan3
#undef K1
#undef K3

    Return(0*MMU_BASE);

END SEGMENT

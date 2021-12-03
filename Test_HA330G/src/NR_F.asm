#define _NR_F_

#include <CPU11.def>
#include <NR.def>
#include <Math.def>
#include <SOC_Common.def>
#include <string.def>
#include <Global.def>
#include <STA.def>
#include <MAC.def>
#include <Debug.def>
#include <USI.def>
#include <GPIO.def>
#include <AGC.def>

CODE SEGMENT NR_F;
//////////////////////////////////////////////////////////////////////////
//  ����:
//      NoiseReduction
//  ����:
//      ���㽵������
//  ����:
//      1.vn_p ��������ָ��
//      2.vs_p �źŰ���ָ��
//      3.chan ͨ����
//      4.class_data ����ȵȼ�
//      5.input_fix ��������
//  ����ֵ��
//      1.RD0: dBgain ��������
//////////////////////////////////////////////////////////////////////////
Sub NoiseReduction;
   push RA0;
   push RA1;
   push RA2;
   push RA2;
   push RA7;
   push RD2;
   push RD3;

   RA2 = RSP;// ��λ�ַ
   RA1 = M[RA2+8*MMU_BASE];           // input_fix ��������
#define input_fix   RA1               // input_fix ��������
#define class_data  M[RA2+9*MMU_BASE] // ����ֵ
#define chan        M[RA2+10*MMU_BASE]// ͨ����
#define vs_p        M[RA2+11*MMU_BASE]// �źŰ���ָ��
#define vn_p        M[RA2+12*MMU_BASE]// ��������ָ��

   RD0 = 8*MMU_BASE;
   RSP -= RD0;
   RA7 = RSP;// �ֲ�������ַ
#define vs          M[RA7+0*MMU_BASE]
#define vn          M[RA7+1*MMU_BASE]
#define vs_db       M[RA7+2*MMU_BASE]
#define vn_db       M[RA7+3*MMU_BASE]
#define snr         M[RA7+4*MMU_BASE]
#define mean        M[RA7+5*MMU_BASE]
#define snr1        M[RA7+6*MMU_BASE]
#define snr2        M[RA7+7*MMU_BASE]
#define tmp         RD4
#define i           RD5
#define gain        RD6
#define sum         RD7

    sum = 0;
    gain = 0;
    mean = 0;
    vs = 0;
    vn = 0;
    snr = 0;
    tmp = 0;

    // ��ȡsnr1[chan][class]��snr2[chan][class]
    //  (class-1)*32 + chan*4
    RD0 = class_data;
    RD0 --;
    RF_RotateL4(RD0);
    RF_RotateL1(RD0);
    RD1 = chan;
    RF_RotateL2(RD1);
    RD0 += RD1;
    RD1 = NR_SNR1_Offset;
    RD1 += RA4;
    RD1 += RD0;
    RA0 = RD1;
    RD1 = M[RA0];// g_snr1[chan][class]
    snr1 = RD1;
    RD1 = NR_SNR2_Offset;
    RD1 += RA4;
    RD1 += RD0;
    RA0 = RD1;
    RD1 = M[RA0];// g_snr2[chan][class]
    snr2 = RD1;

    // ���㵱ǰ֡�ľ���ֵ�ۼӺ�
    RD0 = input_fix;
    RD1 = FL_M2_A4_A1;
    call AbsSum;
    sum = RD0;
    RD2 = RD0;

    // ������ʷ4֡��ͳ��ֵ�ܺ�
    RD0 = Sum_Array_Offset;
    RD0 += RA4;
    RA0 = RD0;
    RD1 = chan;
    RD0 = RD1;
    RF_ShiftL1(RD1);
    RD0 += RD1;
    RF_ShiftL2(RD0);
    RA0 += RD0;

    sum += M[RA0];
    sum += M[RA0+1*MMU_BASE];
    sum += M[RA0+2*MMU_BASE];

    // ������ʷ֡ͳ��ֵ�Ķ���
    RD0 = M[RA0+1*MMU_BASE];
    M[RA0] = RD0;
    RD0 = M[RA0+2*MMU_BASE];
    M[RA0+1*MMU_BASE] = RD0;
    M[RA0+2*MMU_BASE] = RD2;

    // ÿ8֡����һ�ν�������
    RD0 = g_Cnt_Frame;
    RD1 = 7;
    RD0 &= RD1;
    RD1 = chan;
    RD0 ^= RD1;
    if(RQ_Zero) goto L_NoiseReduction_NR;

    // �����㽵������ʱ��ȡ��������ֵ����
    RD0 = Gain_NR_Array_Offset;
    RD0 += RA4;
    RA0 = RD0;
    RD1 = chan;
    RF_ShiftL2(RD1);
    RD0 = M[RA0+RD1];
    goto L_NoiseReduction_End;

L_NoiseReduction_NR:
    //sum=sum/FRAME_LEN; FRAME_LEN = 128 ������7λʵ��
    //������Ҫ������Ч���ȣ��˴�����128���洢����˲����г�������
    //mean = 20 * log10((double)sum / 32768 / 128 );
    //mean = ((10*log10_fix(sum >> 7) << 1) - (20*log10(32768))*q15) / q15;
    //     = ((3*log2_fix(sum >> 7) << 1) - 2959245) / q15; // 2959245 = (20*log32768)*q15
    RD0 = sum;
    RD1 = 5;
    call _Rf_ShiftR_Signed_Reg;
    call log2_fix;
    RD1 = RD0;
    RF_ShiftL1(RD1);
    RD0 += RD1;
    RF_ShiftL1(RD0);
    RD1 = 2959245;
    RD0 -= RD1;

    push RD0;
    RD0 = g_G1_PGA;
    RF_ShiftL2(RD0);
    RF_ShiftL2(RD0);
    RF_ShiftL2(RD0);
    RF_ShiftL1(RD0);
    pop RD1;
    RD1 -= RD0;
    RD0 = RD1;

    call Float_From_Int;
    RD1 = 15;
    RF_RotateR8(RD1);
    RD0 -= RD1;
    mean = RD0;

    //vs_db=(Ts*vs_p[chan]+(1-Ts)*mean);//�����źŰ���
    RD1 = mean;
    RD0 = g_nTs;
    call _Float_Multi;
    RD2 = RD0;
    RD0 = vs_p;
    RA0 = RD0;
    RD0 = chan;
    RF_ShiftL2(RD0);
    RD0 = M[RA0+RD0];//vs_p[chan]
    RD1 = g_Ts;
    call _Float_Multi;
    RD1 = RD2;
    call _Float_Add;
    vs_db = RD0;

    //vs_p[chan] = vs_db;
    RD1 = chan;
    RF_ShiftL2(RD1);
    M[RA0+RD1] = RD0;

    //vs = vs_db * 1024
    RD1 = 10;
    RF_RotateR8(RD1);
    RD0 += RD1;
    call Float_To_Int;
    vs = RD0;

    //if(vs_db>vn_p[chan])
    RD1 = vn_p;
    RA0 = RD1;
    RD1 = chan;
    RF_ShiftL2(RD1);
    RD1 = M[RA0+RD1];
    RD0 = vs_db;
    call _Float_Sub;

    if(RD0_Bit23==0) goto L_NoiseReduction_1;

    //׼����vn_p��ָ��
    RD0 = vn_p;
    RA0 = RD0;

    //vn_db=vs_db;
    RD0 = vs_db;
    vn_db = RD0;
    goto L_NoiseReduction_2;

L_NoiseReduction_1:
    //vn_db=(Tn*vn_p[chan]+(1-Tn)*vs_db);
    RD1 = vs_db;
    RD0 = g_nTn;
    call _Float_Multi;
    RD2 = RD0;
    RD0 = vn_p;
    RA0 = RD0;
    RD0 = chan;
    RF_ShiftL2(RD0);
    RD0 = M[RA0+RD0];//vn_p[chan]
    RD1 = g_Tn;
    call _Float_Multi;
    RD1 = RD2;
    call _Float_Add;
    vn_db = RD0;

L_NoiseReduction_2:
    //vn_p[chan] = vn_db;
    RD1 = chan;
    RF_ShiftL2(RD1);
    M[RA0+RD1] = RD0;

    //vn = vn_db * 1024
    RD1 = 10;
    RF_RotateR8(RD1);
    RD0 += RD1;
    call Float_To_Int;
    vn = RD0;

    //snr=vs-vn;//�õ������
    RD0 = vs;
    RD0 -= vn;

    if(RD0_Bit31==0) goto L_NoiseReduction_snr_confirm;
    RD0 = 0;
L_NoiseReduction_snr_confirm:
    snr = RD0;

    RD0 = MASK_SNR_CHECK;
    RD0 &= g_Switch;
    if(RQ_Zero) goto L_SNR_Check_Dis;
    RD0 = snr;
    push RD0;
    RD0 = RSP;
    RD1 = 4;
    call Export_Data_32bit;
    pop RD0;
L_SNR_Check_Dis:


    //���ݳ���ѡ�����溯���Ĳ���
    //switch(class_data)
    RD0 = class_data;
    if(RD0_Zero) goto L_NoiseReduction_Class1;//�����ڵĳ���
    RD0 --;
    if(RD0_Zero) goto L_NoiseReduction_Class1;
    RD0 --;
    if(RD0_Zero) goto L_NoiseReduction_Class2;
    RD0 --;
    if(RD0_Zero) goto L_NoiseReduction_Class3;
    goto L_NoiseReduction_Class3;//�����ڵĳ���

L_NoiseReduction_Class1:
    RD0 = RN_B0_1_8_ADDR;
    RD0 = NR_B0_1_Offset;
    RD0 += RA4;
    push RD0;
    RD0 = RN_K0_1_8_ADDR;
    RD0 = NR_K0_1_Offset;
    RD0 += RA4;
    push RD0;
    RD0 = RN_B1_1_8_ADDR;
    RD0 = NR_B1_1_Offset;
    RD0 += RA4;
    push RD0;
    RD0 = RN_K1_1_8_ADDR;
    RD0 = NR_K1_1_Offset;
    RD0 += RA4;
    push RD0;
    goto L_NoiseReduction_Choose_Para;

L_NoiseReduction_Class2:
    RD0 = RN_B0_2_8_ADDR;
    RD0 = NR_B0_2_Offset;
    RD0 += RA4;
    push RD0;
    RD0 = RN_K0_2_8_ADDR;
    RD0 = NR_K0_2_Offset;
    RD0 += RA4;
    push RD0;
    RD0 = RN_B1_2_8_ADDR;
    RD0 = NR_B1_2_Offset;
    RD0 += RA4;
    push RD0;
    RD0 = RN_K1_2_8_ADDR;
    RD0 = NR_K1_2_Offset;
    RD0 += RA4;
    push RD0;
    goto L_NoiseReduction_Choose_Para;

L_NoiseReduction_Class3:
    RD0 = RN_B0_3_8_ADDR;
    RD0 = NR_B0_3_Offset;
    RD0 += RA4;
    push RD0;
    RD0 = RN_K0_3_8_ADDR;
    RD0 = NR_K0_3_Offset;
    RD0 += RA4;
    push RD0;
    RD0 = RN_B1_3_8_ADDR;
    RD0 = NR_B1_3_Offset;
    RD0 += RA4;
    push RD0;
    RD0 = RN_K1_3_8_ADDR;
    RD0 = NR_K1_3_Offset;
    RD0 += RA4;
    push RD0;
    goto L_NoiseReduction_Choose_Para;

L_NoiseReduction_Choose_Para:
    RD0 = snr1;
    RD0 -= snr;
    if(RQ>0) goto L_NoiseReduction_3;
    RD0 = snr2;
    RD0 -= snr;
    if(RQ>0) goto L_NoiseReduction_4;
    k_c = 0;
    b_c = 0;
    RD0 = 4*MMU_BASE;
    RSP += RD0;
    goto L_NoiseReduction_After_Switch0;//break;

L_NoiseReduction_3:
    //k_c=k0[class_data-1][chan];
    RD0 = 2*MMU_BASE;
    RSP += RD0;
    pop RA0;
    RD0 = chan;
RF_ShiftL2(RD0);
    RD0 = M[RA0+RD0];
    k_c = RD0;
    //b_c=b0[class_data-1][chan];
    pop RA0;
    RD0 = chan;
RF_ShiftL2(RD0);
    RD0 = M[RA0+RD0];
    b_c = RD0;
    goto L_NoiseReduction_After_Switch0;//break;

L_NoiseReduction_4:
    //k_c=k1[class_data-1][chan];
    pop RA0;
    RD0 = chan;
RF_ShiftL2(RD0);
    RD0 = M[RA0+RD0];
    k_c = RD0;
    //b_c=b1[class_data-1][chan];
    pop RA0;
    RD0 = 2*MMU_BASE;
    RSP += RD0;
    RD0 = chan;
RF_ShiftL2(RD0);
    RD0 = M[RA0+RD0];
    b_c = RD0;

L_NoiseReduction_After_Switch0:
    //����֮���л�������ƽ������ TatԽ����1��ƽ��Խ��
    //kt=Tat*k_p+(1-Tat)*k_c;
    //�ȼ�ʽkt = ((k_p<<10) - k_p + k_c) >> 10;
    RD0 = chan;
    RF_ShiftL2(RD0);
    RD0 += k_p_Offset;
    RD0 += RA4;
    RA0 = RD0;
    RD0 = M[RA0];
    RD1 = 6;
    call _Rf_ShiftL_Reg;
    RD0 -= M[RA0];
    RD0 += k_c;
    kt = RD0;
    RD1 = 6;
    call _Rf_ShiftR_Signed_Reg;
    kt = RD0;

    //k_p=kt;//����
    RD0 = kt;
    M[RA0] = RD0;

    // bt=Tat*b_p+(1-Tat)*b_c;
    // �ȼ�ʽbt = ((b_p<<10) - b_p + b_c) >> 10;
    RD0 = chan;
    RF_ShiftL2(RD0);
    RD0 += b_p_Offset;
    RD0 += RA4;
    RA0 = RD0;
    RD0 = M[RA0];
    RD1 = 6;
    call _Rf_ShiftL_Reg;
    RD0 -= M[RA0];
    RD0 += b_c;
    RD1 = 6;
    call _Rf_ShiftR_Signed_Reg;
    bt = RD0;

    // b_p=bt;//����
    RD0 = bt;
    M[RA0] = RD0;

    // ��������
    // gain=kt*snr+bt;
    // �ȼ�ʽgain = ( kt*snr + (bt<<10));
    RD0 = snr;
    RD1 = kt;
    call _Rs_Multi;
    push RD0;
    RD0 = bt;
    RD1 = 10;
    call _Rf_ShiftL_Reg;
    pop RD1;
    RD0 += RD1;
    gain = RD0;

    // gain=pow(10.,2*gain)*1.0; //ת��������
    // �ȼ�ʽgain=int(pow(10.0, ((double)gain)*2 / 131072 / 1024) * 32768);
    // ��ѡ���ʵ��
    if(RD0_Bit31==1) goto L_NoiseReduction_5;
    RD0 = 0;
L_NoiseReduction_5:
    RD1 = 19;// ԭ����131072*1024 ~ q27����q19��Ϊq8
    call _Rf_ShiftR_Signed_Reg;// q8
    RD1 = 40;
    call _Rs_Multi;// ��WDRCͳһ���٣���ʱûŪ���ײ�40����ԭ��ֻ�ǵ��Ʋ�40��

    // ���½�������
    push RD0;
    RD0 = Gain_NR_Array_Offset;
    RD0 += RA4;
    RA0 = RD0;
    RD1 = chan;
    RF_ShiftL2(RD1);
    pop RD0;
    M[RA0+RD1] = RD0;
//Debug_Reg32 = RD0;

L_NoiseReduction_End:
    RD1 = 8*MMU_BASE;
    RSP += RD1;
    pop RD3;
    pop RD2;
    pop RA7;
    pop RA2;
    pop RA2;
    pop RA1;
    pop RA0;

#undef input_fix
#undef class_data
#undef chan
#undef vs_p
#undef vn_p
#undef vs
#undef vn
#undef vs_db
#undef vn_db
#undef snr
#undef mean
#undef tmp
#undef i
#undef gain
#undef sum

    Return(5*MMU_BASE);

END SEGMENT

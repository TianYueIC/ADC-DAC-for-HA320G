#define _AFC_F_

#include <CPU11.def>
#include <Math.def>
#include <SOC_Common.def>
#include <string.def>
#include <Global.def>
#include <STA.def>
#include <IIR.def>
#include <FMT.def>
#include <FFT.def>
#include <MAC.def>
#include <ALU.def>
#include <USI.def>
#include <Init.def>
#include <Debug.def>
#include <DMA_ParaCfg.def>

#define threshold0_fix  (1677670)                // ������ֵ ������� 1677670.4 = 512*32767*0.1
#define threshold1_fix  (16776)                  // ������ֵ ��С���� 16776.704 = 512*32767*0.001
#define threshhold2     (100)                    // ע���޸�ʱͬʱ�޸ĳ���Ρ�Х�е������������������ı�ֵ��ֵ��������10������������ƽ���ͼ��㣬���Ҳƽ��
#define Qmodul          (32767)                  // �����õ�cos sin��Ľ�

CODE SEGMENT AFC_F;
//////////////////////////////////////////////////////////////////////////
//  ����:
//      HowlingDetect_fix
//  ����:
//      ������Ƶ��ƽ��ֵ��ȫƵ��ƽ��ֵ�ı�ֵ
//      ������ڣ�RN_history_comp_ADDR��ȫ�֣� [Real|0]��ʽ��ʷ���������
//  ����:
//      1.&freq �ֲ�Х��Ƶ��ָ��(out)
//      2.&howl Х�����ָ��(out) 0-��Х�� 1-��Х�� 2-��������ֵ
//  ����ֵ��
//      1.RD0:0~ִ����� 1~ִ�й���
//////////////////////////////////////////////////////////////////////////
Sub HowlingDetect_fix;
    push RA0;
    push RA2;
    push RA7;
    push RD2;

    RA2 = RSP;// ��λ�ַ
#define howl    M[RA2+5*MMU_BASE]
#define freq    M[RA2+6*MMU_BASE]

    RD0 = 7*MMU_BASE+FRAME_LEN2*2;
    RSP -= RD0;
    RA7 = RSP;// �ֲ�������ַ
#define powerin         M[RA7+0*MMU_BASE]
#define index           M[RA7+1*MMU_BASE]
#define index_max       M[RA7+2*MMU_BASE]
#define sum             M[RA7+3*MMU_BASE]
#define howlsum         M[RA7+4*MMU_BASE]
#define howlcount       M[RA7+5*MMU_BASE]
#define k               M[RA7+6*MMU_BASE]

//=====================40us===============================
    // �ֲ�������ʼ��
    RD0 = 0;
    powerin   = RD0;
    index     = RD0;
    index_max = RD0;
    sum       = RD0;
    howlsum   = RD0;
    RD0 = 1;
    howlcount = RD0;

    // 1. ����512��ľ���ֵ֮�ʹ���powerin
    RD0 = RN_history_comp_ADDR_Plus;
    call En_RAM_To_PATH1;
    RD0 = RN_history_comp_ADDR1;
    RD1 = L512_M2_A4_A1;// (512+2)*2+1 = 1029
    call AbsSum;//PATH1 ���ݰ�32λ��ʽ�洢��ÿ��Dword��16λΪ��
//========================================================

//=====================500us===============================
    powerin = RD0;

    // 2. ɸ������������С
    RD1 = threshold0_fix;
    RD1 -= RD0;
    if(RQ>=0) goto L_HowlingDetect_fix_1;
    RD1 = howl;
    RA0 = RD1;
    RD1 = 2;
    M[RA0] = RD1;
    goto L_HowlingDetect_fix_End;   // ������ֵ����ʱ������2

L_HowlingDetect_fix_1:
    RD1 = threshold1_fix;
    RD1 -= RD0;
    if(RQ<0) goto L_HowlingDetect_fix_2;
    RD1 = howl;
    RA0 = RD1;
    RD1 = 0;
    M[RA0] = RD1;
    goto L_HowlingDetect_fix_End;   // ������ֵ��Сʱ������0

L_HowlingDetect_fix_2:
    //call FFT_Init;  // FFT���ʼ����GRAM

    // 3. FFT����
    RD0 = RN_history_comp_ADDR1;
    RD1 = RN_FFT_RESULT_ADDR;

    call FFT_fix;//PATH3 2��Ӳ������

    // 4. FFT�����ģƽ��
    // 4.1 FFT���ʵ�����鲿�ֱ�ƽ����ע��������ܵ�����һ�룩
//====================================================


//====================212us==============================
    RD0 = RN_FFT_RESULT_ADDR_Plus;
    call En_RAM_To_PATH2;
    RD0 = RN_FFT_RESULT_ADDR;
    RD1 = RN_Imag_ADDR;
    RD2 = L256_M3_A3;
    call SingleSerSquare;//PATH2

    // 4.2 ʵ��ƽ�����鲿ƽ������ʵ��
    RD0 = RN_Imag_ADDR;
    call En_GRAM_To_CPU;
    RD2 = 256;
    RD0 = RN_Imag_ADDR;
    RA0 = RD0;

L_HowlingDetect_fix_10:
    RD0 = M[RA0];
    RD1 = RD0;
    RF_GetH16(RD0);
    RF_GetL16(RD1);
    RD0 += RD1;
    M[RA0++] = RD0;
    RD2 --;
    if(RQ_nZero) goto L_HowlingDetect_fix_10;
    RD0 = RN_Imag_ADDR;
    call Dis_GRAM_To_CPU;
//====================================================

//================23us==================================

    // 5. ��Imag���еļ���ֵ��λ�ã�ע��������ܵ�����һ�룬256�㣬1DW/�㣩
    RD0 = RN_Imag_ADDR;
    RD1 = L256_M2_A4;
    call FindMaxIndex;//PATH2
    index = RD0;
    index_max = RD0;
//====================================================

//====================83us=============================

    // 6. �������Ӧ��Ƶ��
    //*freq = index_max * 16384/512; //Ƶ�����
    RD1 = 5;
    call _Rf_ShiftL_Reg; // �˴�������5λ(*= 32)����*16384/512
    RD1 = freq;
    RA0 = RD1;
    M[RA0] = RD0;
    push RD0;
    RD0 = RN_Imag_ADDR;
    call En_GRAM_To_CPU;
    pop RD0;
    RD1 = 500;
    RD1 -= RD0;
    if(RQ<0) goto L_HowlingDetect_fix_3;
    RD1 = howl;
    RA0 = RD1;
    RD1 = 0;
    M[RA0] = RD1;

    goto L_HowlingDetect_fix_End;   // �����Ƶ�ʵ���500Hzʱ������0

L_HowlingDetect_fix_3:
    RD1 = index;
    RF_ShiftL2(RD1);
    RD0 = RN_Imag_ADDR;
    RA0 = RD0;
    RD0 = M[RA0+RD1];
    howlsum = RD0;

    // Imag[index] = 0;
    M[RA0+RD1] = 0;

    // Х��Ƶ����Χ���������ƽ����ΪХ������
    RD1 = 0;
    RD0 = index;
    RD1 -= RD0;
    if(RQ>=0) goto L_HowlingDetect_fix_4;
    RD1 = index;
    RD1 --;
    RF_ShiftL2(RD1);
    RD0 = RN_Imag_ADDR;
    RA0 = RD0;
    RD0 = M[RA0+RD1];
    howlsum += RD0;
    M[RA0+RD1] = 0;
    howlcount ++;

L_HowlingDetect_fix_4:
    RD1 = FRAME_LEN2 - 1;
    RD0 = index;
    RD1 -= RD0;
    if(RQ<=0) goto L_HowlingDetect_fix_5;
    RD1 = index;
    RD1 ++;
    RF_ShiftL2(RD1);
    RD0 = RN_Imag_ADDR;
    RA0 = RD0;
    RD0 = M[RA0+RD1];
    howlsum += RD0;
    M[RA0+RD1] = 0;
    howlcount ++;

L_HowlingDetect_fix_5:
    RD0 = RN_Imag_ADDR;
    call Dis_GRAM_To_CPU;

    // ��ȥ��3������Ұ��
    RD2 = 3;
L_HowlingDetect_fix_6:
    RD0 = RN_Imag_ADDR;
    RD1 = L256_M2_A4;
    call FindMaxIndex;//PATH2
    push RD0;
    RD0 = RN_Imag_ADDR;
    call En_GRAM_To_CPU;
    pop RD0;
    RF_ShiftL2(RD0);
    RD1 = RN_Imag_ADDR;
    RA0 = RD1;
    M[RA0+RD0] = 0;
    RD0 = RN_Imag_ADDR;
    call Dis_GRAM_To_CPU;
    RD2 --;
    if(RQ_nZero) goto L_HowlingDetect_fix_6;
    RD0 = RN_Imag_ADDR;
    call En_GRAM_To_CPU;
//====================================================

//======================30us==========================

    // ��ʣ�����е�ƽ��ֵ��ע��������ܵ�����һ�룬256�㣬1DW/�㣩
    RD0 = RN_Imag_ADDR;
    RD1 = L256_M2_A4;
    call AbsSum;
    RD1 = 8;
    call _Rf_ShiftR_Reg;
    sum = RD0;

    // �Ƚ�howlsum�� sum*howlcount*ratioTh�Ĵ�С
    RD2 = howlcount;
    RD1 = sum;
    RD0 = 0;
L_HowlingDetect_fix_7:
    RD0 += RD1;
    RD2 --;
    if(RQ_nZero) goto L_HowlingDetect_fix_7;
    sum = RD0;

    RD0 = g_AFC_CFG;
    RD1 = 64;
    RD0 ^= RD1;
    if(RQ_Zero) goto L_HowlingDetect_fix_8;
    //    sum *= 100;
    RD0 = sum;
    RD1 = sum;
    RF_ShiftL2(RD1);// RD1 = 4*sum
    RD0 = RD1;      // RD0 = 4*sum
    RF_ShiftL2(RD1);// RD1 = 16*sum
    RF_ShiftL1(RD1);// RD1 = 32*sum
    RD0 += RD1;     // RD0 = 36*sum
    RF_ShiftL1(RD1);// RD1 = 64*sum
    RD0 += RD1;     // RD0 = 100*sum
    sum = RD0;
    goto L_HowlingDetect_fix_81;

L_HowlingDetect_fix_8:
    //    sum *= 64;
    RD0 = sum;
    RF_ShiftL2(RD0);// RD0 = 4*sum
    RF_ShiftL2(RD0);// RD0 = 16*sum
    RF_ShiftL2(RD0);// RD0 = 64*sum
    sum = RD0;

L_HowlingDetect_fix_81:
    RD1 = sum;
    RD1 -= howlsum;
    if(RQ<0) goto L_HowlingDetect_fix_9;
    RD1 = howl;
    RA0 = RD1;
    M[RA0] = 0;
    goto L_HowlingDetect_fix_End;   // ��howlsum <= sumʱ������0

L_HowlingDetect_fix_9:
    RD1 = howl;
    RA0 = RD1;
    RD0 = 1;
    M[RA0] = RD0;   // ��howlsum > sumʱ������1

L_HowlingDetect_fix_End:
    RD0 = RN_Imag_ADDR;
    call Dis_GRAM_To_CPU;

    RD1 = 7*MMU_BASE+FRAME_LEN2*2;
    RSP += RD1;

    RD0 = 0;

    pop RD2;
    pop RA7;
    pop RA2;
    pop RA0;
//====================================================

#undef in
#undef howl
#undef freq
#undef powerin
#undef index
#undef index_max
#undef sum
#undef howlsum
#undef howlcount
#undef k

  Return(2*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      zfft_fix
//  ����:
//      ��ȷ���Х��Ƶ��
//      ������ڣ�RN_history_comp_ADDR��ȫ�֣� [Real|0]��ʽ��ʷ���������
//  ����:
//      1.&freq ����Х��Ƶ��ָ��(out)
//      2.fs ������
//      3.f0 ƫ���� ���ֲ�Ƶ��-100��
//  ����ֵ��
//      1.RD0:0~ִ����� 1~ִ�й���
//////////////////////////////////////////////////////////////////////////
Sub zfft_fix;
    push RA0;
    push RA1;
    push RA2;
    push RA2;
    push RA7;
    push RD2;
    push RD3;

    RA2 = RSP;// ��λ�ַ
//#define x       M[RA2+8*MMU_BASE]
#define f0      M[RA2+8*MMU_BASE]
#define fs      M[RA2+9*MMU_BASE]
#define freq    M[RA2+10*MMU_BASE]

//  int D = 32;                             // Ĭ��ϸ����
//  int M;                                  // M=(2PI*if0/fs)/(2PI/8192)=i*f0*(8192/fs), ��fs=16*1024ʱ��M=i*f0/2; fs=8000ʱ,MԼ=i*f0
//  int simbolcos=0, simbolsin=0;           // cos,sinֵ�ķ���λ��0��1��
//  int index;
//  int i;
//  Complex_fix x1_fix[FRAME_LEN4];
//  int  XImag[FRAME_LEN4];
//  tableModule myTableMod[FRAME_LEN4];

    RD1 = 6*MMU_BASE;// + 512*MMU_BASE;
    RSP -= RD1;
    RA7 = RSP;// �ֲ�������ַ
#define D                   M[RA7+0*MMU_BASE]
#define MM                   M[RA7+1*MMU_BASE]
#define simbolcos           M[RA7+2*MMU_BASE]
#define simbolsin           M[RA7+3*MMU_BASE]
#define index               M[RA7+4*MMU_BASE]
#define i                   M[RA7+5*MMU_BASE]

    // 1. ������(Ӳ�����ò��ʵ��)
    // 1.1 ����ԭ���˲�����Ӳ����Ӧ��Ԥ��õģ�
    //tableModule tableMod[1024];
    // �з־�����45��/1024����ʽcos(PI*i/4096),sin(PI*i/4096),����16λ�洢
//  for (int i = 0; i<1024; i++)
//  {
//      tableMod[i].vcos = (int)(cos(PI*(i + 1) / 4096) * (Qmodul));
//      tableMod[i].vsin = (int)(sin(PI*(i + 1) / 4096) * (Qmodul));
//  }

    // ����GRAM15ΪCPU����ģʽ
    RD0 = RN_myTableMod_ADDR;
    call En_GRAM_To_CPU;
    RD0 = RN_myTableMod_ADDR_Plus;
    call En_GRAM_To_CPU;

    // zfft���̲��Ϊ14���ӹ��̣��ֱ���14֡��ִ��
    // S1ִ���Ʊ��һ��
    RD0 = g_Status_zfft;
    RD0 --;
    if(RQ_Zero) goto L_zfft_fix_S1;

    // S2~S8ִ���Ʊ���߶�
    RD0 = g_Status_zfft;
    RD1 = 8;
    RD1 -= RD0;
    if(RQ>=0) goto L_zfft_fix_S2to8;

    // S9ִ�е���
    RD1 = 9;
    RD1 ^= RD0;
    if(RQ_Zero) goto L_zfft_fix_S9;

    // S10ִ���˲�1
    RD1 = 10;
    RD1 ^= RD0;
    if(RQ_Zero) goto L_zfft_fix_S10;

    // S11ִ���˲�2
    RD1 = 11;
    RD1 ^= RD0;
    if(RQ_Zero) goto L_zfft_fix_S11;

    // S12ִ�г��
    RD1 = 12;
    RD1 ^= RD0;
    if(RQ_Zero) goto L_zfft_fix_S12;

    // S13ִ��FFT
    RD1 = 13;
    RD1 ^= RD0;
    if(RQ_Zero) goto L_zfft_fix_S13;

    // S14ִ��Others
    RD1 = 14;
    RD1 ^= RD0;
    if(RQ_Zero) goto L_zfft_fix_S14;

//    RD0 = 0;
//    goto L_zfft_fix_End;

    // �����֧

L_zfft_fix_S1:
    // 1.2 ��ʵ��f0������������Ҫ�õı���Ҫʵ�֣�
    // 0��ֱ�Ӹ�ֵ
    //myTableMod[0].vcos = Qmodul;
    //myTableMod[0].vsin = 0;
    RD1 = RN_myTableMod_ADDR;
    RA1 = RD1;
    RD0 = Qmodul;
    RF_RotateL16(RD0);
    M[RA1] = RD0;

L_zfft_fix_S2to8:
    RD0 = f0;
    RD3 = RD0;
    // i = (g_Status_zfft-1)*64+1
    RD0 = g_Status_zfft;
    RD0 --;
    RF_RotateL8(RD0);
    RF_RotateR2(RD0);
    RD0 ++;
    i = RD0;

    RD2 = 64;
L_zfft_fix_Loop1:
    // 1~512��
    //for (int i = 1; i < FRAME_LEN4; i++)
    //{
    // 1.2.1 ����M=i*f0/2
    //MM = f0*i;�üӷ���ܳ˷�
    RD0 = RD3;
    RD1 = f0;
    RD3 += RD1;

    //MM >>= 1;        // ����8kʱ�رգ���ʽ������Ҫ�ſ��˴���ע������
//    RD1 = 1;
//    call _Rf_ShiftR_Signed_Reg;
    RF_ShiftR1(RD0);
    //MM = RD0;

    // 1.2.2 M mod 8192 ��8192�൱��360��
    //MM = M & 0x1FFF;
    RD1 = 0x1FFF;
    RD0 &= RD1;
    //MM = RD0;

    //MM = 8192 - MM;               // ����ʽ���и��ţ���-i*f0/2�����Դ˴���ȥ����
    RD1 = 8192;
    RD1 -= RD0;
    MM = RD1;
    RD0 = RD1;

    // 1.2.3 �ж�M�����ĸ�����[0,2048),[2048,4096),[4096,6144),[6144,8192)
    //switch ((M >> 11) & 3)
    //{
    if(RD0_Bit11==1) goto L_zfft_fix_2;
    if(RD0_Bit12==1) goto L_zfft_fix_0b10;
L_zfft_fix_0b00:
    // [0,2048)
    simbolcos = 0;
    simbolsin = 0;
    goto L_zfft_fix_break;

L_zfft_fix_2:
    if(RD0_Bit12==1) goto L_zfft_fix_0b11;
L_zfft_fix_0b01:
    // [2048,4096)
    //MM = 4096 - MM;
    simbolcos = 1;
    simbolsin = 0;
    RD1 = 4096;
    RD0 = MM;
    RD1 -= RD0;
    MM = RD1;
    goto L_zfft_fix_break;

L_zfft_fix_0b10:
    // [4096,6144)
    //MM = MM - 4096;
    simbolcos = 1;
    simbolsin = 1;
    RD0 = 4096;
    MM -= RD0;
    goto L_zfft_fix_break;

L_zfft_fix_0b11:
    // [6144,8192)
    //MM = 8192 - MM;
    simbolcos = 0;
    simbolsin = 1;
    RD1 = 8192;
    RD0 = MM;
    RD1 -= RD0;
    MM = RD1;
    //goto L_zfft_fix_break;

L_zfft_fix_break:
    // 1.2.4 �ж�MM�Ƿ����1024
//    if (MM < 1024)
    RD1 = 1024;
    RD0 = MM;
    RD1 -= RD0;
    if(RQ<=0) goto L_zfft_fix_else_1;
//    {
//        if (MM == 0)
//        {
    if(RD0!=0) goto L_zfft_fix_else_2;
//            myTableMod[i].vcos = 1;
//            myTableMod[i].vsin = 0;

    RD1 = RN_myTableMod_ADDR;
    RA1 = RD1;
    RD1 = i;
    RF_ShiftL2(RD1);
    RD0 = 0x00010000;
    M[RA1+RD1] = RD0;
    goto L_zfft_fix_if_end1;
//        }
L_zfft_fix_else_2:
//        else
//        {
//            MM -= 1;
    MM --;
//            myTableMod[i].vcos = tableMod[MM].vcos;
//            myTableMod[i].vsin = tableMod[MM].vsin;
    // ��tableMod[MM]
    RD0 = MM;
    //RF_ShiftL2(RD0);
    RD1 = RN_tableMod_ADDR;
    RD1 += RD0;
    RA0 = RD1;// RA0 ---> tableMod[MM]
    // ��myTableMod[i]
    RD1 = i;
    RF_ShiftL2(RD1);
    RD0 = RN_myTableMod_ADDR;
    RA1 = RD0;// RA1 ---> myTableMod   RD1 = offset i*4
    // copy����
    RD0 = M[RA0];
    M[RA1+RD1] = RD0;
    goto L_zfft_fix_if_end1;
//        }
//    }
L_zfft_fix_else_1:
//    else
//    {
//        MM = 2048 - MM;
    RD0 = 2048;
    RD1 = MM;
    RD0 -= RD1;
    MM = RD0;
//        if (MM == 0)
    if(RD0!=0) goto L_zfft_fix_else_3;
//        {
//            myTableMod[i].vcos = 0;
//            myTableMod[i].vsin = 1;
//        }

    RD1 = RN_myTableMod_ADDR;
    RA1 = RD1;
    RD1 = i;
    RF_ShiftL2(RD1);
    RD0 = 0x00000001;
    M[RA1+RD1] = RD0;
    goto L_zfft_fix_if_end1;

L_zfft_fix_else_3:
//        else
//        {
//            MM -= 1;
    MM --;
//            myTableMod[i].vcos = tableMod[MM].vsin;
//            myTableMod[i].vsin = tableMod[MM].vcos;
//        }
    // ��tableMod[MM]
    RD0 = MM;
    //RF_ShiftL2(RD0);
    RD1 = RN_tableMod_ADDR;
    RD1 += RD0;
    RA0 = RD1;// RA0 ---> tableMod[MM]
    // ��myTableMod[i]
    RD1 = i;
    RF_ShiftL2(RD1);
    RD0 = RN_myTableMod_ADDR;
    RA1 = RD0;// RA1 ---> myTableMod   RD1 = offset i*4
    // copy����
    RD0 = M[RA0];
    RF_ExchangeL16(RD0);//??????????
    RF_MSB2LSB(RD0);
    RF_ExchangeL16(RD0);//??????????

    M[RA1+RD1] = RD0;
    goto L_zfft_fix_if_end1;
//    }

L_zfft_fix_if_end1:

    // 1.2.5 ������
    //if (simbolcos)
    //    myTableMod[i].vcos = -myTableMod[i].vcos;
    RD0 = simbolcos;
    if(RD0==0) goto L_zfft_fix_3;
    RD0 = 0xFFFF0000;
    M[RA1+RD1] ^= RD0;
    RD0 = 0x00010000;
    M[RA1+RD1] += RD0;

L_zfft_fix_3:
//    if (simbolsin)
//        myTableMod[i].vsin = -myTableMod[i].vsin;
    RD0 = simbolsin;
    if(RD0==0) goto L_zfft_fix_4;
    RD0 = 0x0000FFFF;
    M[RA1+RD1] ^= RD0;
    M[RA1+RD1] ++;

L_zfft_fix_4:
//    }
    i ++;
    RD2 --;
    if(RQ_nZero) goto L_zfft_fix_Loop1;

L_zfft_fix_1:
    // ���GRAM15��CPU����ģʽ
    call Dis_GRAM_To_CPU;
    goto L_zfft_fix_Suspend;


L_zfft_fix_S9:
    // 1.3 ����ÿ�����ʵ��x*cos �鲿x*sin
    // 16λx��24λϵ����ˣ��������16λ
    // ����
    RD0 = RN_history_comp_ADDR_Plus;
    call En_RAM_To_PATH2;
    RD0 = RN_myTableMod_ADDR_Plus;
    call En_RAM_To_PATH2;
    RD0 = RN_x1_fix_ADDR_Plus;
    call En_RAM_To_PATH2;
    RD0 = RN_myTableMod_ADDR;
    RA0 = RD0;
    RD0 = RN_history_comp_ADDR1;
    RA1 = RD0;
    RD1 = RN_x1_fix_ADDR;
    RD0 = L512_M3_A3;// (512+1)*3
    call ModulationToZero;//PATH2

    // �����ʽ
    RD0 = RN_x1_fix_ADDR_Plus;
    call En_RAM_To_PATH1;
    RD0 = RN_x1_fix_ADDR;
    RA0 = RD0;
    RD0 = RN_iirBuf_Re_ADDR;
    RA1 = RD0;
    RD0 = L256_M3_A3;// 256
    call Get_Real;//PATH1

RD0 = RN_x1_fix_ADDR_Plus;
call En_RAM_To_PATH1;
    RD0 = RN_x1_fix_ADDR;
    RA0 = RD0;
    RD0 = RN_iirBuf_Im_ADDR;
    RA1 = RD0;
    RD0 = L256_M3_A3;
    call Get_Imag;//PATH1
    goto L_zfft_fix_Suspend;

L_zfft_fix_S10:
    // �˲�1
    RD0 = RN_iirBuf_Re_ADDR;
    RA0 = RD0;
    RD0 = RN_iirBuf_Re2_ADDR;
    RA1 = RD0;
    RD0 = L256_M48_A1;
    call _IIR_PATH1_FiltLP32;//PATH1
    goto L_zfft_fix_Suspend;

L_zfft_fix_S11:
    // �˲�2
    RD0 = RN_iirBuf_Im_ADDR;
    RA0 = RD0;
    RD0 = RN_iirBuf_Im2_ADDR;
    RA1 = RD0;
    RD0 = L256_M48_A1;//256*48+1 DWord����*48+1
    call _IIR_PATH1_FiltLP32;//PATH1

    goto L_zfft_fix_Suspend;

L_zfft_fix_S12:

    RD0 = RN_x2_fix_ADDR;
    RA1 = RD0;
    RD0 = RN_XRAM0;
    RA0 = RD0;
    RD1 = L256_M1_A2;
    call Ram_Clr;

    RD0 = RN_x2_fix_ADDR_Plus;
    RA1 = RD0;
    RD0 = RN_XRAM0;
    RA0 = RD0;
    RD1 = L256_M1_A2;
    call Ram_Clr;

    // ���1/32
    RD0 = RN_x2_fix_ADDR;
    call En_GRAM_To_CPU;
RD0 = RN_x2_fix_ADDR_Plus;
call En_GRAM_To_CPU;
    RD0 = RN_iirBuf_Re2_ADDR;
    call En_GRAM_To_CPU;
    RD0 = RN_iirBuf_Im2_ADDR;
    call En_GRAM_To_CPU;

    push RA2;

    RD0 = RN_iirBuf_Re2_ADDR;
    RA0 = RD0;
    RD0 = RN_iirBuf_Im2_ADDR;
    RA1 = RD0;
    RD0 = RN_x2_fix_ADDR;
    RA2 = RD0;

    RD2 = 16;
L_zfft_fix_Loop2:
    RD0 = M[RA0+15*MMU_BASE];//ʵ��ƴ������
    RF_GetL16(RD0);
    RF_RotateL16(RD0);
    RD1 = M[RA1+15*MMU_BASE];//�鲿ƴ������
    RF_GetL16(RD1);
    RD0 += RD1;
    M[RA2++] = RD0;
    RD1 = 16*MMU_BASE;
    RA0 += RD1;
    RA1 += RD1;
    RD2 --;
    if(RQ_nZero) goto L_zfft_fix_Loop2;

    pop RA2;
    goto L_zfft_fix_Suspend;

L_zfft_fix_S13:
    // 3.2 �������е�FFT
    //ComplexFFT_fix(x1_fix, X1_fix, FRAME_LEN4);

    // 3. FFT���㣨���ʵ��Ӧ�ο�оƬ��FFTӲ���涨��
    //FFT_fix(in, in_comp); // FFT����in  ----->  in_comp
RD0 = RN_x2_fix_ADDR_Plus;
call En_RAM_To_PATH3;
RD0 = RN_x2_comp_ADDR_Plus;
call En_RAM_To_PATH3;
    RD0 = RN_x2_fix_ADDR;
    RD1 = RN_x2_comp_ADDR;
    call FFT_fix;//PATH3 2��
    goto L_zfft_fix_Suspend;

L_zfft_fix_S14:
    RD0 = 0;
    g_Status_zfft = RD0;

    // 4. FFT�����ģƽ����Ӧ����Ӳ�����٣���ע�������������һ�룩
    //absSquareComplex_fix(in_comp, Imag, FRAME_LEN2);
RD0 = RN_x2_comp_ADDR_Plus;
call En_RAM_To_PATH2;
RD0 = RN_x2_Imag_ADDR_Plus;
call En_RAM_To_PATH2;
    RD0 = RN_x2_comp_ADDR;
    RD1 = RN_x2_Imag_ADDR;
    RD2 = L256_M3_A3;
    call SingleSerSquare;//PATH2

    RD0 = RN_x2_Imag_ADDR;
    call En_GRAM_To_CPU;
RD0 = RN_x2_Imag_ADDR_Plus;
call En_GRAM_To_CPU;

    // ʵ��ƽ�����鲿ƽ��
    RD2 = 256;
    RD0 = RN_x2_Imag_ADDR;
    RA0 = RD0;
L_HowlingDetect_fix_11:
    RD0 = M[RA0];
    RD1 = RD0;
    RF_GetH16(RD0);
    RF_GetL16(RD1);
    RD0 += RD1;
    M[RA0++] = RD0;
    RD2 --;
    if(RQ_nZero) goto L_HowlingDetect_fix_11;

    call Dis_GRAM_To_CPU;

//CPU_SimpleLevel_L;
//    // ����FFT���
//    RD0 = RN_x2_Imag_ADDR;
//    RD1 = 1024;
//    call Export_Vector_32bit;
//CPU_SimpleLevel_H;

    // 5. ��Imag���еļ���ֵ��λ�ã�Ӧ����Ӳ�����٣���ע�������������һ�룩
    //find_max_fix(Imag, FRAME_LEN2, &index);
RD0 = RN_x2_Imag_ADDR_Plus;
call En_RAM_To_PATH2;
    RD0 = RN_x2_Imag_ADDR;
    RD1 = L256_M2_A4;
    call FindMaxIndex;//PATH2
    index = RD0;

    // 3.3 FFT�����ģƽ����Ӧ����Ӳ�����٣���ע�������������һ�룩
    //absSquareComplex_fix(X1_fix, XImag, FRAME_LEN2);
    // 3.4 ��Imag���еļ���ֵ��λ�ã�Ӧ����Ӳ�����٣���ע�������������һ�룩
    //find_max_fix(XImag, FRAME_LEN2, &index);

    // 4. �����Ӧ��Ƶ�� ��ʽ��*freq=index*fs/(N*D)+f0; DĬ��Ϊ32
    //*freq=index + f0;       //  Ƶ�����    ����Ϊframe16384.txtʱ���˴���׼���Ϊ3226
    //*freq = (index>>1) + f0;  //  Ƶ�����    (������Ҫ����ʱ�޸ģ�����������ʽ��) ����Ϊframe8192.txtʱ���˴���׼���Ϊ3226
    RD0 = freq;
    RA0 = RD0;
    RD0 = f0;
    RD0 += index;
    M[RA0] = RD0;

    RD0 = 0;

L_zfft_fix_End:
    RD1 = 6*MMU_BASE;// + 512*MMU_BASE;
    RSP += RD1;

    pop RD3;
    pop RD2;
    pop RA7;
    pop RA2;
    pop RA2;
    pop RA1;
    pop RA0;

#undef x
#undef f0
#undef fs
#undef freq
#undef D
#undef M
#undef simbolcos
#undef simbolsin
#undef index
#undef i

    Return(3*MMU_BASE);

L_zfft_fix_Suspend:
    g_Status_zfft ++;
    RD0 = 1;
    goto L_zfft_fix_End;



//////////////////////////////////////////////////////////////////////////
//  ����:
//      howlDetectFrame_fix
//  ����:
//      Х�м�⼰�ݲ�����
//  ����:
//      1.��Ƶ����ָ��
//  ����ֵ��
//      ��
//////////////////////////////////////////////////////////////////////////
Sub howlDetectFrame_fix;
    push RA2;
    push RA7;
    push RD2;

    RA2 = RSP;// ��λ�ַ
#define dataBuf     M[RA2+4*MMU_BASE]       // ��Ƶ����ָ��

    RD1 = 11*MMU_BASE;
    RSP -= RD1;
    RA7 = RSP;// �ֲ�������ַ
//#define howlflagtmp         M[RA7+0*MMU_BASE]   // ȡֵ  0,1,2����0  δХ��  ��1 Х��   2 ��������ֵ
#define p_origin            M[RA7+1*MMU_BASE]   // originָ��history�еĵ�ǰ֡��ַ
#define howlfreq            M[RA7+2*MMU_BASE]   // ��ȷ��Х��Ƶ��ֵ
#define howlfreq_Offset     (2*MMU_BASE)

//#define freq                M[RA7+3*MMU_BASE]   // ���Ե�Х��Ƶ��ֵ
#define k_AFC               M[RA7+4*MMU_BASE]
#define a1                  M[RA7+10*MMU_BASE]
#define a2                  M[RA7+9*MMU_BASE]
#define a3                  M[RA7+8*MMU_BASE]
#define b1                  M[RA7+7*MMU_BASE]
#define b2                  M[RA7+6*MMU_BASE]
#define b3                  M[RA7+5*MMU_BASE]

    RD0 = 0;
    //HowlDelNum = RD0;
    //HowlStartNum = RD0;
    g_howlflagtmp = RD0;
    howlfreq = RD0;
    //g_freq = RD0;
    k_AFC = RD0;

    // ������ʷ3֡����ǰƽ��
RD0 = RN_history_comp_ADDR_Plus;
call En_RAM_To_PATH1;
    RD0 = RN_history_comp_ADDR2;// Դ��ַ
    RA0 = RD0;
    RD0 = RN_history_comp_ADDR1;// Ŀ���ַ
    RA1 = RD0;
    RD0 = L_Move_Howl_M2_A4;
    call DMA_Trans;

    // ��������Ϊ�������ʽд�뻺��
//    RD0 = dataBuf;
//    RD1 = RN_history_comp_new;
//    call Real_To_Complex;//PATH1 2��
    RA0 = dataBuf;
    RD0 = RN_history_comp_new;
    RA1 = RD0;
    RD0 = FL_M2_A2;
    call Real_To_Complex2;//PATH1 2��

    // ========================= �ּ쿪ʼ =============================
    g_howlindex_fix++;

    RD0 = g_howlindex_fix;
    RD0 -= 16;  // ��16֡����ּ�Х�е�һ��
    if(RQ_Zero) goto L_howlDetectFrame_fix_S16_S17;
    RD0 = g_howlindex_fix;
    RD0 -= 17;  // ��16֡����ּ�Х�еڶ���
    if(RQ_Zero) goto L_howlDetectFrame_fix_S16_S17;
    goto L_howlDetectFrame_fix_SCheck_End;

L_howlDetectFrame_fix_S16_S17:
    // �ֲ�Х��
    RD0 = g_freq_Offset;
    RD0 += RA4;
    send_para(RD0);
    RD0 = g_howlflagtmp_Offset;
    RD0 += RA4;
    send_para(RD0);
    call HowlingDetect_fix;
    if(RD0_nZero) goto L_howlDetectFrame_fix_Notch;// �ּ����ʱ���Թ�����
    g_howlindex_fix = 0;// ����S0״̬

    // �ּ���Х��ʱ��HowlStartNum++��HowlDelNum����;
    // �ۼ�6�δּ���Х���ж�Ϊ��Х�У��ͷ���Х�б�ǣ�����6���ж�Ϊ��Х�У��ͷ�����Х�б��;
    // �ּ���Х��ʱ��HowlDelNum++;
    // ����10�δּ���Х���ж�Ϊ����Х�У��ͷ�����Х�б�ǣ�HowlStartNum���㣬HowlDelNum����;
    RD0 = g_howlflagtmp;
    if(RD0==0) goto L_howlDetectFrame_fix_nHowl_S;// ��ѹ��С����Х��
    RD0 -= 2;
    if(RD0==0) goto L_howlDetectFrame_fix_nHowl_S;// ��ѹ����ֵ����Х��
    g_HowlDelNum = 0;// �ݲ��رռ���������
    g_HowlStartNum++;// �ݲ�����������++
    RD1 = RN_NOTCH_START_TH;// �ۼƷ���RN_NOTCH_START_TH��Х����Ϊ��Х��
    RD0 = g_HowlStartNum;
    RD1 -= RD0;
    if(RQ>0) goto L_howlDetectFrame_fix_Howl_nConfirm;// δ�ۼƴﵽ���δֲ�Х��


    // ����Х�У�����ݲ���ʹ���ź�
    RD0 = 1;
    g_howlflag_fix = RD0;
    goto L_howlDetectFrame_fix_SCheck_End;

L_howlDetectFrame_fix_Howl_nConfirm:
    // ����Х�У�����ݲ��������ź�
    g_howlflag_fix = 0;
    goto L_howlDetectFrame_fix_SCheck_End;

L_howlDetectFrame_fix_nHowl_S:
    g_HowlDelNum++;// �ݲ��رռ�����++
    RD0 = g_HowlDelNum;
    RD1 = RN_NOTCH_STOP_TH;// ����RN_NOTCH_STOP_TH����Х����Ϊ����Х��
    RD1 -= RD0;
    if(RQ>0) goto L_howlDetectFrame_fix_SCheck_End;
    // ����Х��
    g_howlflag_fix = 0;
    g_HowlDelNum = 0;
    g_HowlStartNum = 0;
    g_Notch_Freq0 = 0;
    g_Notch_Freq1 = 0;
    g_Notch_Freq2 = 0;
    g_Notch_Index = 0;

L_howlDetectFrame_fix_SCheck_End:
// ========================= �ּ���� =============================

// ========================= ���쿪ʼ =============================
    RD0 = g_Status_zfft;
    if(RD0_nZero) goto L_howlDetectFrame_fix_S1to14;// �������Ѿ�����ʱ��ֱ�ӽ��뾫�����

    // �����촦�ھ�ֹ״̬(S0)ʱ������ݲ���ʹ���ź������һ�δּ�Х�о���Чʱ��ת����S1
    RD0 = g_howlflag_fix;
    if(RD0_Zero) goto L_howlDetectFrame_fix_Notch;
    RD0 = g_howlflagtmp;
    if(RD0_Zero) goto L_howlDetectFrame_fix_Notch;
    g_howlflagtmp = 0;
    g_Status_zfft ++;// S0 ---> S1
    goto L_howlDetectFrame_fix_Notch;

L_howlDetectFrame_fix_S1to14:
    // ����Х��Ƶ��
    RD0 = howlfreq_Offset;// ����Ƶ��
    RD0 += RA7;
    send_para(RD0);
    RD0 = 16384;
    send_para(RD0);
    RD0 = g_freq;// �ּ�Ƶ��
    RD0 -= 100;
    send_para(RD0);
    call zfft_fix;
    if(RD0_nZero) goto L_howlDetectFrame_fix_Notch;// ��������˳�

    // ������ɣ��Ǽǲ������ݲ���ϵ��
    RD0 = howlfreq;
    call Regist_Notch_Freq;
// ========================= ������� =============================

// ========================= �ݲ���ʼ =============================
L_howlDetectFrame_fix_Notch:
    // 3. �ݲ�(��Ҫ��history���������ҲҪд������Դ��ַ��������)
    RD0 = MASK_NOTCH;
    RD0 &= g_Switch;// ���乤�߿���
    if(RQ_Zero) goto L_howlDetectFrame_fix_Notch_Dis;

    // �ж��Ƿ���Ҫִ���ݲ���0
    RD0 = g_Notch_Freq0;
    if(RD0_Zero) goto L_howlDetectFrame_fix_Notch1;

    // �����ݲ���ϵ��
    RD1 = RA7;
    RD1 += 5*MMU_BASE;
    RA0 = RD1;
    call SetiirNotch_4Order;
    call _IIR_PATH3_SetHD_HawlClr;

    // �ݲ���0ʹ��
    RD0 = dataBuf;
    RA0 = RD0;
    RA1 = RD0;
    RD0 = L16_M68_A1;
    RD1 = 1;
    call _IIR_PATH3_HawlClr;

L_howlDetectFrame_fix_Notch1:
    // �ж��Ƿ���Ҫִ���ݲ���1
    RD0 = g_Notch_Freq1;
    if(RD0_Zero) goto L_howlDetectFrame_fix_Notch2;
//goto L_howlDetectFrame_fix_Notch2;
    // �����ݲ���ϵ��
    RD1 = RA7;
    RD1 += 5*MMU_BASE;
    RA0 = RD1;
    call SetiirNotch_4Order;
    call _IIR_PATH3_SetHD_HawlClr;

    // �ݲ���1ʹ��
    RD0 = dataBuf;
    RA0 = RD0;
    RA1 = RD0;
    RD0 = L16_M68_A1;
    RD1 = 2;
    call _IIR_PATH3_HawlClr;

L_howlDetectFrame_fix_Notch2:
    // �ж��Ƿ���Ҫִ���ݲ���2
    RD0 = g_Notch_Freq2;
    if(RD0_Zero) goto L_howlDetectFrame_fix_Notch_End;
//goto L_howlDetectFrame_fix_Notch_End;
    // �����ݲ���ϵ��
    RD1 = RA7;
    RD1 += 5*MMU_BASE;
    RA0 = RD1;
    call SetiirNotch_4Order;
    call _IIR_PATH3_SetHD_HawlClr;

    // �ݲ���2ʹ��
    RD0 = dataBuf;
    RA0 = RD0;
    RA1 = RD0;
    RD0 = L16_M68_A1;
    RD1 = 3;
    call _IIR_PATH3_HawlClr;

L_howlDetectFrame_fix_Notch_Dis:
L_howlDetectFrame_fix_Notch_End:
// ========================= �ݲ����� =============================

    RD1 = 11*MMU_BASE;
    RSP += RD1;

    pop RD2;
    pop RA7;
    pop RA2;

#undef howlflagtmp
#undef p_origin
#undef howlfreq
#undef freq
#undef k_AFC
#undef a1
#undef a2
#undef a3
#undef b1
#undef b2
#undef b3

    Return(1*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      SetiirNotch_4Order
//  ����:
//      ����Ŀ��Ƶ�������ݲ���ϵ��
//  ����:
//      1.RD0:Ŀ��Ƶ��
//      2.RA0:������ַ(out)
//            ϵ��a1    M[RA0+5*MMU_BASE]
//            ϵ��a2    M[RA0+4*MMU_BASE]
//            ϵ��a3    M[RA0+3*MMU_BASE]
//            ϵ��b1    M[RA0+2*MMU_BASE]
//            ϵ��b2    M[RA0+1*MMU_BASE]
//            ϵ��b3    M[RA0+0*MMU_BASE]
//  ����ֵ��
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField SetiirNotch_4Order;
    push RD4;
    push RD5;
    push RD6;

#define w    RD4
#define sign RD5
#define w2   RD6

    RD1 = RA0;
    RA1 = RD1;

#define a1   M[RA1+5*MMU_BASE]
#define a2   M[RA1+4*MMU_BASE]
#define a3   M[RA1+3*MMU_BASE]
#define b1   M[RA1+2*MMU_BASE]
#define b2   M[RA1+1*MMU_BASE]
#define b3   M[RA1+0*MMU_BASE]

    // �������cos(2*PI*freq/fs)
    //  M = f0 >> 1;
    sign = 0;
    RF_ShiftR1(RD0);// f0>>1

    RD1 = 2048;
    RD1 -= RD0;
    if(RQ>=0) goto L_SetiirNotch_4Order_1;
    //  if (M > 2048)
    //  {
    //      sign = 1;
    //      M = 4096 - M;
    //  }
    sign = 1;
    RD1 = 4096;
    RD1 -= RD0;
    RD0 = RD1;

L_SetiirNotch_4Order_1:
    RD1 = 1024;
    RD1 -= RD0;
    if(RQ<=0) goto L_SetiirNotch_4Order_2;
    if(RD0!=0) goto L_SetiirNotch_4Order_3;
    w = 1;
    goto L_SetiirNotch_4Order_Lookup_End;

L_SetiirNotch_4Order_3:
    RD0 --;
    //RF_ShiftL2(RD0);
    RD1 = RN_tableMod_ADDR;
    RD1 += RD0;
    RA0 = RD1;// RA0 ---> tableMod[MM]
    RD0 = M[RA0];
    RF_GetH16(RD0);
    w = RD0;
    goto L_SetiirNotch_4Order_Lookup_End;

L_SetiirNotch_4Order_2:
    RD1 = 2048;
    RD1 -= RD0;
    RD0 = RD1;
    if(RD0!=0) goto L_SetiirNotch_4Order_5;
    w = 0;
    goto L_SetiirNotch_4Order_Lookup_End;

L_SetiirNotch_4Order_5:
    RD0 --;
    //RF_ShiftL2(RD0);
    RD1 = RN_tableMod_ADDR;
    RD1 += RD0;
    RA0 = RD1;// RA0 ---> tableMod[MM]
    RD0 = M[RA0];
    RF_GetL16(RD0);
    w = RD0;

L_SetiirNotch_4Order_Lookup_End:
    // w2 = (w * w) / 32768;
    RD0 = w;
    RD1 = w;
    call _Rs_Multi;
    w2 = RD0;
    RD1 = 15;
    call _Rf_ShiftR_Signed_Reg;
    w2 = RD0;

    // b1 = w;
    RD0 = w;
    b1 = RD0;

    // a1 = (w * NOTCH_R) / 8192;(NOTCH_R = 5734)
    // 5734w = (4096 + 1024 + 512 + 64 + 32 + 4 + 2) * w
    RD1 = w;
    RF_ShiftL1(RD1);// 2w
    RD0 = RD1;
    RF_ShiftL1(RD1);// 4w
    RD0 += RD1;     // (4 + 2) * w
    RF_ShiftL2(RD1);
    RF_ShiftL1(RD1);// 32w
    RD0 += RD1;     // (32 + 4 + 2) * w
    RF_ShiftL1(RD1);// 64w
    RD0 += RD1;     // (64 + 32 + 4 + 2) * w
    RF_ShiftL2(RD1);
    RF_ShiftL1(RD1);// 512w
    RD0 += RD1;     // (512 + 64 + 32 + 4 + 2) * w
    RF_ShiftL1(RD1);// 1024w
    RD0 += RD1;     // (1024 + 512 + 64 + 32 + 4 + 2) * w
    RF_ShiftL2(RD1);// 4096w
    RD0 += RD1;     // (4096 + 1024 + 512 + 64 + 32 + 4 + 2) * w
    RD1 = 13;
    call _Rf_ShiftR_Reg;// 5734w /= 8192
    a1 = RD0;

    // a3 = (w * NOTCH_R3) / 8192;(NOTCH_R3 = 2809)
    // 2809w = (2048 + 512 + 128 + 64 + 32 + 16 + 8 + 1) * w
    RD0 = w;
    RD1 = w;
    RF_ShiftL2(RD1);
    RF_ShiftL1(RD1);// 8w
    RD0 += RD1;     // (8 + 1) * w
    RF_ShiftL1(RD1);// 16w
    RD0 += RD1;     // (16 + 8 + 1) * w
    RF_ShiftL1(RD1);// 32w
    RD0 += RD1;     // (32 + 16 + 8 + 1) * w
    RF_ShiftL1(RD1);// 64w
    RD0 += RD1;     // (64 + 32 + 16 + 8 + 1) * w
    RF_ShiftL1(RD1);// 128w
    RD0 += RD1;     // (128 + 64 + 32 + 16 + 8 + 1) * w
    RF_ShiftL2(RD1);// 512w
    RD0 += RD1;     // (512 + 128 + 64 + 32 + 16 + 8 + 1) * w
    RF_ShiftL2(RD1);// 2048w
    RD0 += RD1;     // (2048 + 512 + 128 + 64 + 32 + 16 + 8 + 1) * w
    RD1 = 13;
    call _Rf_ShiftR_Reg;// 2809w /= 8192
    a3 = RD0;

    // ���w����Ϊ��������Ҫ��b1,a1,a3ȡ����
    RD0 = sign;
    if(RD0_nZero) goto L_SetiirNotch_4Order_4;
    // b1 = -b1;
    RD0 = b1;
    RF_Not(RD0);
    RD0 ++;
    b1 = RD0;

    // a1 = -a1;
    RD0 = a1;
    RF_Not(RD0);
    RD0 ++;
    a1 = RD0;

    // a3 = -a3;
    RD0 = a3;
    RF_Not(RD0);
    RD0 ++;
    a3 = RD0;
L_SetiirNotch_4Order_4:
    // b2 = w2 + 16384;
    RD0 = w2;
    RD1 = 16384;
    RD0 += RD1;
    b2 = RD0;

    // b3 = b1;
    RD0 = b1;
    b3 = RD0;

    // a2 = (w2 * NOTCH_R2) / 8192 + NOTCH_R2 * 2;(NOTCH_R2 = 4014)
    // 4014w2 = (4096 - 64 - 16 - 2) * w2
    RD0 = w2;
    RF_ShiftL1(RD0);    // 2w2
    RD1 = RD0;          // 2w2
    RF_ShiftL1(RD0);
    RF_ShiftL2(RD0);    // 16w2
    RD1 += RD0;         // (16 + 2) * w
    RF_ShiftL2(RD0);    // 64w2
    RD1 += RD0;         // (64 + 16 + 2) * w
    RD2 = RD1;
    // ��4096w2
    RD0 = w2;
    RD1 = 12;
    call _Rf_ShiftL_Reg;// 4096w2
    RD0 -= RD2;         // (4096 - 64 - 16 - 2) * w2
    RD1 = 13;
    call _Rf_ShiftR_Reg;// w2 * NOTCH_R2 / 8192
    RD1 = 4014*2;
    RD0 += RD1;         // (w2 * NOTCH_R2) / 8192 + NOTCH_R2 * 2
    a2 = RD0;

#undef w
#undef sign
#undef w2

#undef a1
#undef a2
#undef a3
#undef b1
#undef b2
#undef b3

    pop RD6;
    pop RD5;
    pop RD4;
    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      _IIR_PATH1_SetHD_HawlClr
//  ����:
//      ����IIR_PATH1�˲���CBank1ϵ��
//  ����:
//      1.H16=b1��L16=a1
//  ����ֵ��
//      ��
//  ע�ͣ�
//      b11 = 0x2000      xxxx       0x2000       0       0
//      a11 =             xxxx       0x99eb       0       0
//      int b1  = { 8192, -3385, 8192, 0, 0 }; // �ݲ���ϵ����ֵ�������н��޸�[1]ֵ��������
//      int a1  = { 8192, -3046, 6635, 0, 0 }; // �ݲ���ϵ����ֵ�������н��޸�[1]ֵ��������
//////////////////////////////////////////////////////////////////////////
Sub_AutoField _IIR_PATH1_SetHD_HawlClr;
    RD2 = RD0;
    //ϵ����ʽת��
    RF_GetH16(RD0);
    if(RD0_Bit15==0) goto L_HawlClr_L0;
    RF_Neg(RD0);
    RF_GetL16(RD0);
    RD0_SetBit15;
L_HawlClr_L0:
    RD3 = RD0;      //b1Ӳ����ʽ��{����λ������ֵ}
    RD0 = RD2;
    if(RD0_Bit15==0) goto L_HawlClr_L1;
    RF_Neg(RD0);
    RF_GetL16(RD0);
    RD0_SetBit15;
L_HawlClr_L1:
    RD2 = 0x8000;
    RD2 ^= RD0;     //a1Ӳ����ʽ��{����λȡ��������ֵ}

    MemSetRAM4K_Enable;
    IIR_PATH1_Enable;
    RD0 = 0x6;      //����CBank1��XBank2
    IIR_PATH1_BANK = RD0;

    RD0 = 0x2000;
    IIR_PATH1_HD = RD0;
    RD0 = RD3;
    IIR_PATH1_HD = RD0;
    RD0 = 0x2000;
    IIR_PATH1_HD = RD0;
    RD0 = 0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;

    RD0 = RD2;
    IIR_PATH1_HD = RD0;
    RD0 = 0x99eb;
    IIR_PATH1_HD = RD0;
    RD0 = 0;
    IIR_PATH1_HD = RD0;
    RD0 = 0;
    IIR_PATH1_HD = RD0;
    RD0 = 0x047C;    //�˴�Ϊϵ����Ӧ������
    IIR_PATH1_HD = RD0;

    //����һ����������ڣ�����*4
    RD0 = 0x7fff;
    IIR_PATH1_HD = RD0;
    RD0 = 0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;

    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    //IIR_PATH1_Disable;
    MemSet_Disable;

    IIR_PATH1_CLRADDR;

    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////////////////////////
////  ����:
////      _IIR_PATH1_SetHD_Const
////  ����:
////      ����IIR_PATH1�˲����̶�ϵ��
////  ����:
////      ��
////  ����ֵ��
////      ��
////  ע�ͣ�G1 = 6 , 256/16/6 = 2.5
////      b11 = 0x2000    0x9b12    0x3d2f    0x9b12    0x2000
////      a11 =           0x0e39    0x805a    0x01ad    0x8469
////      b21 = 0x2000    0x94f2    0x20db    0x94f2    0x2000
////      a21 =           0x1091    0x8c11    0x0bbb    0x955e
////      b31 = 0x2000    0x92ea    0x1779    0x92ea    0x2000
////      a31 =           0x11a7    0x9185    0x10a6    0x9dcc
////////////////////////////////////////////////////////////////////////////
//Sub_AutoField _IIR_PATH1_SetHD_Const;
//    MemSetRAM4K_Enable;
//    IIR_PATH1_Enable;
//    RD0 = 0x6;      //����CBank1��XBank2
//    IIR_PATH1_BANK = RD0;
//
//    RD0 = 0x2000;         // b11ϵ��
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x9b12;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x3d2f;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x9b12;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x2000;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x0e39;         // a11ϵ��
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x805a;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x01ad;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x8469;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x024C;//��������λ
//    IIR_PATH1_HD = RD0;
////      b21 = 0x2000    0x94f2    0x20db    0x94f2    0x2000
////      a21 =           0x1091    0x8c11    0x0bbb    0x955e
//    RD0 = 0x2000;         // b21ϵ��
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x94f2;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x20db;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x94f2;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x2000;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x1091;         // a21ϵ��
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x8c11;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x0bbb;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x955e;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x024C;//��������λ
//    IIR_PATH1_HD = RD0;
////      b31 = 0x2000    0x92ea    0x1779    0x92ea    0x2000
////      a31 =           0x11a7    0x9185    0x10a6    0x9dcc
//    RD0 = 0x2000;         // b31ϵ��
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x92ea;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x1779;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x92ea;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x2000;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x11a7;         // a31ϵ��
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x9185;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x10a6;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x9dcc;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x024C;//��������λ
//    IIR_PATH1_HD = RD0;
//
//    //IIR_PATH1_Disable;
//    MemSet_Disable;
//
//    IIR_PATH1_CLRADDR;
//
//    Return_AutoField(0*MMU_BASE);


//////////////////////////////////////////////////////////////////////////
//  ����:
//      Regist_Notch_Freq
//  ����:
//      �Ǽ��ݲ�������Ƶ�ʣ��������ݲ���ϵ��
//  ���ݳ��ڣ�
//      1.g_Notch_Freq0
//      2.g_Notch_Freq1
//      3.g_Notch_Freq2
//      4.g_Notch_Index
//  ����:
//      1.RD0:�ݲ�������Ƶ��
//  ����ֵ��
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Regist_Notch_Freq;
    RD2 = RD0;

    // ����²�Ƶ����g_Notch_Freq0���ƣ��򲻵Ǽ�
    RD0 = RD2;
    RD1 = g_Notch_Freq0;
    RD0 -= RD1;
    RF_Abs(RD0);
    RD1 = RN_NOTCH_FREQ_TOLERANCE;
    RD1 -= RD0;
    if(RQ>0) goto L_Regist_Notch_Freq_End;

    // ����²�Ƶ����g_Notch_Freq1���ƣ��򲻵Ǽ�
    RD0 = RD2;
    RD1 = g_Notch_Freq1;
    RD0 -= RD1;
    RF_Abs(RD0);
    RD1 = RN_NOTCH_FREQ_TOLERANCE;
    RD1 -= RD0;
    if(RQ>0) goto L_Regist_Notch_Freq_End;

    // ����²�Ƶ����g_Notch_Freq2���ƣ��򲻵Ǽ�
    RD0 = RD2;
    RD1 = g_Notch_Freq2;
    RD0 -= RD1;
    RF_Abs(RD0);
    RD1 = RN_NOTCH_FREQ_TOLERANCE;
    RD1 -= RD0;
    if(RQ>0) goto L_Regist_Notch_Freq_End;

    // �Ǽ��µ�Ƶ��
    RD0 = g_Notch_Freq0_Offset;
    RD1 = g_Notch_Index;
    RF_ShiftL2(RD1);
    RD0 += RD1;
    M[RA4+RD0] = RD2;


    // �ɹ��Ǽ��µ�Ƶ�ʺ�g_Notch_Index = (g_Notch_Index++) mod 3;
    g_Notch_Index ++;
    RD1 = RN_NOTCH_QTY;
    RD1 ^= g_Notch_Index;
    if(RQ_nZero) goto L_Regist_Notch_Freq_End;
    g_Notch_Index = 0;
L_Regist_Notch_Freq_End:
    Return_AutoField(0*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      _IIR_PATH3_SetHD_HawlClr
//  ����:
//      ����IIR_PATH3�˲���CBank1ϵ�������ڶ༶�ݲ�
//  ����:
//      1.RA0��������ַ
//              a1   M[RA0+5*MMU_BASE]
//              a2   M[RA0+4*MMU_BASE]
//              a3   M[RA0+3*MMU_BASE]
//              b1   M[RA0+2*MMU_BASE]
//              b2   M[RA0+1*MMU_BASE]
//              b3   M[RA0+0*MMU_BASE]
//  ����ֵ��
//      ��
//  ע�ͣ�
//  b11 = 0x2000      b1      b2     b3     0x2000
//  a11 = 0x2000      a1      a2     a3     NOTCH_R4
//////////////////////////////////////////////////////////////////////////
Sub_AutoField _IIR_PATH3_SetHD_HawlClr;
    //M[RSP+0*MMU_BASE]    b3
    //M[RSP+1*MMU_BASE]    b2
    //M[RSP+2*MMU_BASE]    b1

#define NOTCH_R4   0x87AE   //0x7AE=>1966    // r��4�η�,������Q13,r=0.7ʱ

#define b3      M[RA0+0*MMU_BASE]
#define b2      M[RA0+1*MMU_BASE]
#define b1      M[RA0+2*MMU_BASE]
#define a3      M[RA0+3*MMU_BASE]
#define a2      M[RA0+4*MMU_BASE]
#define a1      M[RA0+5*MMU_BASE]
    //b2�п��ܳ���32768����b2��a2ȡ1/2
    RD0 = b2;
    //RD0_SignExtL16;
    RF_ShiftR1(RD0);
    b2 = RD0;
    RD0 = a2;
    //RD0_SignExtL16;
    RF_ShiftR1(RD0);
    a2 = RD0;
    //bϵ����ʽת��->{����λ������ֵ}
    RD1 = 0;
    RD2 = 3;
L_HawlClr3_Lb:
    RD0 = M[RA0+RD1];
    if(RD0_Bit15==0) goto L_HawlClr3_L0;
    RF_Neg(RD0);
    RD0_SetBit15;
L_HawlClr3_L0:
    M[RA0+RD1] = RD0;      //b1Ӳ����ʽ��{����λ������ֵ}
    RD1 += MMU_BASE;
    RD2 --;
    if(RQ_nZero) goto L_HawlClr3_Lb;

    //aϵ����ʽת��->{����λȡ��������ֵ}
    RD0 = 0x8000;
    RA1 = RD0;
    RD2 = 3;
L_HawlClr3_La:
    RD0 = M[RA0+RD1];
    if(RD0_Bit15==0) goto L_HawlClr3_L1;
    RF_Neg(RD0);
    RD0_SetBit15;
L_HawlClr3_L1:
    RD0 ^= RA1;      //����λȡ��
    M[RA0+RD1] = RD0;      //b1Ӳ����ʽ��{����λ������ֵ}
    RD1 += MMU_BASE;
    RD2 --;
    if(RQ_nZero) goto L_HawlClr3_La;

    MemSetRAM4K_Enable;
    IIR_PATH3_Enable;
    RD0 = 0x4;      //����CBank1��XBankΪ��ڲ���
    IIR_PATH3_BANK = RD0;

    IIR_PATH3_CLRADDR;  // �������ò����Ĵ���ָ�����
    //���Ӷ�����������ڣ�����*4
    RD0 = 0x7fff;
    IIR_PATH3_HD = RD0;
    RD0 = 0;
    IIR_PATH3_HD = RD0;
    IIR_PATH3_HD = RD0;
    IIR_PATH3_HD = RD0;
    IIR_PATH3_HD = RD0;

    IIR_PATH3_HD = RD0;
    IIR_PATH3_HD = RD0;
    IIR_PATH3_HD = RD0;
    IIR_PATH3_HD = RD0;
    RD0 = 0x037C;    //�˴�Ϊϵ����Ӧ�����ã�ע��b2/a2 ��λ�洢
    IIR_PATH3_HD = RD0;

    //����һ����������ڣ�����*4
    RD0 = 0x7fff;
    IIR_PATH3_HD = RD0;
    RD0 = 0;
    IIR_PATH3_HD = RD0;
    IIR_PATH3_HD = RD0;
    IIR_PATH3_HD = RD0;
    IIR_PATH3_HD = RD0;

    IIR_PATH3_HD = RD0;
    IIR_PATH3_HD = RD0;
    IIR_PATH3_HD = RD0;
    IIR_PATH3_HD = RD0;
    IIR_PATH3_HD = RD0;

    RD0 = 0x2000;
    IIR_PATH3_HD = RD0;
    RD0 = b1;
    IIR_PATH3_HD = RD0;
    RD0 = b2;
    IIR_PATH3_HD = RD0;
    RD0 = b3;
    IIR_PATH3_HD = RD0;
    RD0 = 0x2000;
    IIR_PATH3_HD = RD0;

    RD0 = a1;
    IIR_PATH3_HD = RD0;
    RD0 = a2;
    IIR_PATH3_HD = RD0;
    RD0 = a3;
    IIR_PATH3_HD = RD0;
    RD0 = NOTCH_R4;
    IIR_PATH3_HD = RD0;
    RD0 = 0x037C;    //�˴�Ϊϵ����Ӧ�����ã�ע��b2/a2 ��λ�洢
    IIR_PATH3_HD = RD0;

#undef b3
#undef b2
#undef b1
#undef a3
#undef a2
#undef a1
#undef NOTCH_R4

    //IIR_PATH1_Disable;
    MemSet_Disable;

    IIR_PATH3_CLRADDR;

    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  ����:
//      _IIR_PATH3_HawlClr
//  ����:
//      ʹ��IIR1_3ִ���ݲ���Para1, Data10
//  ����:
//      1.RA0:��������ָ�룬16bit���ո�ʽ����
//      2.RA1:�������ָ�룬16bit���ո�ʽ����(out)
//      3.RD0:TimerNumֵ = (�������Dword����*48)+1
//      4.RD1:���ݻ�����0~3
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _IIR_PATH3_HawlClr;
    RD2 = RD0;
    //--------------------------------------------------
    //����GRAM����ΪDMA_Ctrl3������GroupΪ��λ
    MemSetPath_Enable;  //����ͨ��ʹ��
    M[RA0+MGRP_PATH3] = RD0;//ѡ��PATH3��ͨ����Ϣ��ƫַ��

    //����ALU����
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //������ص�4KRAM
    RD0 = DMA_PATH3;
    M[RA0] = RD0;
    M[RA1] = RD0;
    //IIR_PATH3_Enable;
    RD0 = 0x4;
    RD0 += RD1;
    IIR_PATH3_BANK = RD0;
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    RD0 = RA0;//Դ��ַ
    send_para(RD0);
    RD0 = RA1;//Ŀ���ַ
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_FiltIIR;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH3;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_IIR;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    //IIR_PATH3_Disable;
    Return_AutoField(0*MMU_BASE);
END SEGMENT

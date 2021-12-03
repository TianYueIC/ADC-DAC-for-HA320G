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

#define threshold0_fix  (1677670)                // 能量阈值 最大能量 1677670.4 = 512*32767*0.1
#define threshold1_fix  (16776)                  // 能量阈值 最小能量 16776.704 = 512*32767*0.001
#define threshhold2     (100)                    // 注意修改时同时修改程序段。啸叫点能量与其他点能量的比值阈值，浮点是10，这里能量按平方和计算，因此也平方
#define Qmodul          (32767)                  // 调制用的cos sin表的阶

CODE SEGMENT AFC_F;
//////////////////////////////////////////////////////////////////////////
//  名称:
//      HowlingDetect_fix
//  功能:
//      计算尖峰频率平均值与全频带平均值的比值
//      数据入口：RN_history_comp_ADDR（全局） [Real|0]格式历史输入端样点
//  参数:
//      1.&freq 粗测啸叫频点指针(out)
//      2.&howl 啸叫情况指针(out) 0-无啸叫 1-有啸叫 2-能量过阈值
//  返回值：
//      1.RD0:0~执行完毕 1~执行挂起
//////////////////////////////////////////////////////////////////////////
Sub HowlingDetect_fix;
    push RA0;
    push RA2;
    push RA7;
    push RD2;

    RA2 = RSP;// 入参基址
#define howl    M[RA2+5*MMU_BASE]
#define freq    M[RA2+6*MMU_BASE]

    RD0 = 7*MMU_BASE+FRAME_LEN2*2;
    RSP -= RD0;
    RA7 = RSP;// 局部变量基址
#define powerin         M[RA7+0*MMU_BASE]
#define index           M[RA7+1*MMU_BASE]
#define index_max       M[RA7+2*MMU_BASE]
#define sum             M[RA7+3*MMU_BASE]
#define howlsum         M[RA7+4*MMU_BASE]
#define howlcount       M[RA7+5*MMU_BASE]
#define k               M[RA7+6*MMU_BASE]

//=====================40us===============================
    // 局部变量初始化
    RD0 = 0;
    powerin   = RD0;
    index     = RD0;
    index_max = RD0;
    sum       = RD0;
    howlsum   = RD0;
    RD0 = 1;
    howlcount = RD0;

    // 1. 计算512点的绝对值之和存入powerin
    RD0 = RN_history_comp_ADDR_Plus;
    call En_RAM_To_PATH1;
    RD0 = RN_history_comp_ADDR1;
    RD1 = L512_M2_A4_A1;// (512+2)*2+1 = 1029
    call AbsSum;//PATH1 数据按32位格式存储，每个Dword低16位为零
//========================================================

//=====================500us===============================
    powerin = RD0;

    // 2. 筛查能量过大或过小
    RD1 = threshold0_fix;
    RD1 -= RD0;
    if(RQ>=0) goto L_HowlingDetect_fix_1;
    RD1 = howl;
    RA0 = RD1;
    RD1 = 2;
    M[RA0] = RD1;
    goto L_HowlingDetect_fix_End;   // 当能量值过大时，返回2

L_HowlingDetect_fix_1:
    RD1 = threshold1_fix;
    RD1 -= RD0;
    if(RQ<0) goto L_HowlingDetect_fix_2;
    RD1 = howl;
    RA0 = RD1;
    RD1 = 0;
    M[RA0] = RD1;
    goto L_HowlingDetect_fix_End;   // 当能量值过小时，返回0

L_HowlingDetect_fix_2:
    //call FFT_Init;  // FFT表初始化置GRAM

    // 3. FFT计算
    RD0 = RN_history_comp_ADDR1;
    RD1 = RN_FFT_RESULT_ADDR;

    call FFT_fix;//PATH3 2次硬件过程

    // 4. FFT结果求模平方
    // 4.1 FFT结果实部与虚部分别平方（注意点数是总点数的一半）
//====================================================


//====================212us==============================
    RD0 = RN_FFT_RESULT_ADDR_Plus;
    call En_RAM_To_PATH2;
    RD0 = RN_FFT_RESULT_ADDR;
    RD1 = RN_Imag_ADDR;
    RD2 = L256_M3_A3;
    call SingleSerSquare;//PATH2

    // 4.2 实部平方加虚部平方，软实现
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

    // 5. 求Imag序列的极大值的位置（注意点数是总点数的一半，256点，1DW/点）
    RD0 = RN_Imag_ADDR;
    RD1 = L256_M2_A4;
    call FindMaxIndex;//PATH2
    index = RD0;
    index_max = RD0;
//====================================================

//====================83us=============================

    // 6. 计算尖峰对应的频率
    //*freq = index_max * 16384/512; //频点粗算
    RD1 = 5;
    call _Rf_ShiftL_Reg; // 此处用左移5位(*= 32)代替*16384/512
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

    goto L_HowlingDetect_fix_End;   // 当尖峰频率低于500Hz时，返回0

L_HowlingDetect_fix_3:
    RD1 = index;
    RF_ShiftL2(RD1);
    RD0 = RN_Imag_ADDR;
    RA0 = RD0;
    RD0 = M[RA0+RD1];
    howlsum = RD0;

    // Imag[index] = 0;
    M[RA0+RD1] = 0;

    // 啸叫频点周围的三个点的平均作为啸叫能量
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

    // 再去除3个最大的野点
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

    // 求剩余序列的平均值（注意点数是总点数的一半，256点，1DW/点）
    RD0 = RN_Imag_ADDR;
    RD1 = L256_M2_A4;
    call AbsSum;
    RD1 = 8;
    call _Rf_ShiftR_Reg;
    sum = RD0;

    // 比较howlsum与 sum*howlcount*ratioTh的大小
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
    goto L_HowlingDetect_fix_End;   // 当howlsum <= sum时，返回0

L_HowlingDetect_fix_9:
    RD1 = howl;
    RA0 = RD1;
    RD0 = 1;
    M[RA0] = RD0;   // 当howlsum > sum时，返回1

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
//  名称:
//      zfft_fix
//  功能:
//      精确检测啸叫频点
//      数据入口：RN_history_comp_ADDR（全局） [Real|0]格式历史输入端样点
//  参数:
//      1.&freq 精测啸叫频点指针(out)
//      2.fs 采样率
//      3.f0 偏移量 （粗测频点-100）
//  返回值：
//      1.RD0:0~执行完毕 1~执行挂起
//////////////////////////////////////////////////////////////////////////
Sub zfft_fix;
    push RA0;
    push RA1;
    push RA2;
    push RA2;
    push RA7;
    push RD2;
    push RD3;

    RA2 = RSP;// 入参基址
//#define x       M[RA2+8*MMU_BASE]
#define f0      M[RA2+8*MMU_BASE]
#define fs      M[RA2+9*MMU_BASE]
#define freq    M[RA2+10*MMU_BASE]

//  int D = 32;                             // 默认细化度
//  int M;                                  // M=(2PI*if0/fs)/(2PI/8192)=i*f0*(8192/fs), 即fs=16*1024时，M=i*f0/2; fs=8000时,M约=i*f0
//  int simbolcos=0, simbolsin=0;           // cos,sin值的符号位，0正1负
//  int index;
//  int i;
//  Complex_fix x1_fix[FRAME_LEN4];
//  int  XImag[FRAME_LEN4];
//  tableModule myTableMod[FRAME_LEN4];

    RD1 = 6*MMU_BASE;// + 512*MMU_BASE;
    RSP -= RD1;
    RA7 = RSP;// 局部变量基址
#define D                   M[RA7+0*MMU_BASE]
#define MM                   M[RA7+1*MMU_BASE]
#define simbolcos           M[RA7+2*MMU_BASE]
#define simbolsin           M[RA7+3*MMU_BASE]
#define index               M[RA7+4*MMU_BASE]
#define i                   M[RA7+5*MMU_BASE]

    // 1. 复调制(硬件上用查表法实现)
    // 1.1 生成原表（此步骤在硬件上应是预存好的）
    //tableModule tableMod[1024];
    // 切分精度在45度/1024，公式cos(PI*i/4096),sin(PI*i/4096),各自16位存储
//  for (int i = 0; i<1024; i++)
//  {
//      tableMod[i].vcos = (int)(cos(PI*(i + 1) / 4096) * (Qmodul));
//      tableMod[i].vsin = (int)(sin(PI*(i + 1) / 4096) * (Qmodul));
//  }

    // 设置GRAM15为CPU控制模式
    RD0 = RN_myTableMod_ADDR;
    call En_GRAM_To_CPU;
    RD0 = RN_myTableMod_ADDR_Plus;
    call En_GRAM_To_CPU;

    // zfft过程拆分为14个子过程，分别在14帧内执行
    // S1执行制表第一段
    RD0 = g_Status_zfft;
    RD0 --;
    if(RQ_Zero) goto L_zfft_fix_S1;

    // S2~S8执行制表后七段
    RD0 = g_Status_zfft;
    RD1 = 8;
    RD1 -= RD0;
    if(RQ>=0) goto L_zfft_fix_S2to8;

    // S9执行调制
    RD1 = 9;
    RD1 ^= RD0;
    if(RQ_Zero) goto L_zfft_fix_S9;

    // S10执行滤波1
    RD1 = 10;
    RD1 ^= RD0;
    if(RQ_Zero) goto L_zfft_fix_S10;

    // S11执行滤波2
    RD1 = 11;
    RD1 ^= RD0;
    if(RQ_Zero) goto L_zfft_fix_S11;

    // S12执行抽点
    RD1 = 12;
    RD1 ^= RD0;
    if(RQ_Zero) goto L_zfft_fix_S12;

    // S13执行FFT
    RD1 = 13;
    RD1 ^= RD0;
    if(RQ_Zero) goto L_zfft_fix_S13;

    // S14执行Others
    RD1 = 14;
    RD1 ^= RD0;
    if(RQ_Zero) goto L_zfft_fix_S14;

//    RD0 = 0;
//    goto L_zfft_fix_End;

    // 错误分支

L_zfft_fix_S1:
    // 1.2 按实际f0制作本次运算要用的表（需要实现）
    // 0点直接赋值
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
    // 1~512点
    //for (int i = 1; i < FRAME_LEN4; i++)
    //{
    // 1.2.1 计算M=i*f0/2
    //MM = f0*i;用加法规避乘法
    RD0 = RD3;
    RD1 = f0;
    RD3 += RD1;

    //MM >>= 1;        // 测试8k时关闭，正式版里需要放开此处备注！！！
//    RD1 = 1;
//    call _Rf_ShiftR_Signed_Reg;
    RF_ShiftR1(RD0);
    //MM = RD0;

    // 1.2.2 M mod 8192 ，8192相当于360度
    //MM = M & 0x1FFF;
    RD1 = 0x1FFF;
    RD0 &= RD1;
    //MM = RD0;

    //MM = 8192 - MM;               // 所求公式中有负号，是-i*f0/2，所以此处是去负号
    RD1 = 8192;
    RD1 -= RD0;
    MM = RD1;
    RD0 = RD1;

    // 1.2.3 判断M属于哪个区间[0,2048),[2048,4096),[4096,6144),[6144,8192)
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
    // 1.2.4 判断MM是否大于1024
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
    // 找tableMod[MM]
    RD0 = MM;
    //RF_ShiftL2(RD0);
    RD1 = RN_tableMod_ADDR;
    RD1 += RD0;
    RA0 = RD1;// RA0 ---> tableMod[MM]
    // 找myTableMod[i]
    RD1 = i;
    RF_ShiftL2(RD1);
    RD0 = RN_myTableMod_ADDR;
    RA1 = RD0;// RA1 ---> myTableMod   RD1 = offset i*4
    // copy数据
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
    // 找tableMod[MM]
    RD0 = MM;
    //RF_ShiftL2(RD0);
    RD1 = RN_tableMod_ADDR;
    RD1 += RD0;
    RA0 = RD1;// RA0 ---> tableMod[MM]
    // 找myTableMod[i]
    RD1 = i;
    RF_ShiftL2(RD1);
    RD0 = RN_myTableMod_ADDR;
    RA1 = RD0;// RA1 ---> myTableMod   RD1 = offset i*4
    // copy数据
    RD0 = M[RA0];
    RF_ExchangeL16(RD0);//??????????
    RF_MSB2LSB(RD0);
    RF_ExchangeL16(RD0);//??????????

    M[RA1+RD1] = RD0;
    goto L_zfft_fix_if_end1;
//    }

L_zfft_fix_if_end1:

    // 1.2.5 正负号
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
    // 解除GRAM15的CPU控制模式
    call Dis_GRAM_To_CPU;
    goto L_zfft_fix_Suspend;


L_zfft_fix_S9:
    // 1.3 计算每个点的实部x*cos 虚部x*sin
    // 16位x与24位系数相乘，结果保留16位
    // 调制
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

    // 整理格式
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
    // 滤波1
    RD0 = RN_iirBuf_Re_ADDR;
    RA0 = RD0;
    RD0 = RN_iirBuf_Re2_ADDR;
    RA1 = RD0;
    RD0 = L256_M48_A1;
    call _IIR_PATH1_FiltLP32;//PATH1
    goto L_zfft_fix_Suspend;

L_zfft_fix_S11:
    // 滤波2
    RD0 = RN_iirBuf_Im_ADDR;
    RA0 = RD0;
    RD0 = RN_iirBuf_Im2_ADDR;
    RA1 = RD0;
    RD0 = L256_M48_A1;//256*48+1 DWord长度*48+1
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

    // 抽点1/32
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
    RD0 = M[RA0+15*MMU_BASE];//实部拼接在左
    RF_GetL16(RD0);
    RF_RotateL16(RD0);
    RD1 = M[RA1+15*MMU_BASE];//虚部拼接在右
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
    // 3.2 复数序列的FFT
    //ComplexFFT_fix(x1_fix, X1_fix, FRAME_LEN4);

    // 3. FFT计算（汇编实现应参考芯片的FFT硬件规定）
    //FFT_fix(in, in_comp); // FFT运算in  ----->  in_comp
RD0 = RN_x2_fix_ADDR_Plus;
call En_RAM_To_PATH3;
RD0 = RN_x2_comp_ADDR_Plus;
call En_RAM_To_PATH3;
    RD0 = RN_x2_fix_ADDR;
    RD1 = RN_x2_comp_ADDR;
    call FFT_fix;//PATH3 2次
    goto L_zfft_fix_Suspend;

L_zfft_fix_S14:
    RD0 = 0;
    g_Status_zfft = RD0;

    // 4. FFT结果求模平方（应考虑硬件加速）（注意点数是总数的一半）
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

    // 实部平方加虚部平方
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
//    // 导出FFT结果
//    RD0 = RN_x2_Imag_ADDR;
//    RD1 = 1024;
//    call Export_Vector_32bit;
//CPU_SimpleLevel_H;

    // 5. 求Imag序列的极大值的位置（应考虑硬件加速）（注意点数是总数的一半）
    //find_max_fix(Imag, FRAME_LEN2, &index);
RD0 = RN_x2_Imag_ADDR_Plus;
call En_RAM_To_PATH2;
    RD0 = RN_x2_Imag_ADDR;
    RD1 = L256_M2_A4;
    call FindMaxIndex;//PATH2
    index = RD0;

    // 3.3 FFT结果求模平方（应考虑硬件加速）（注意点数是总数的一半）
    //absSquareComplex_fix(X1_fix, XImag, FRAME_LEN2);
    // 3.4 求Imag序列的极大值的位置（应考虑硬件加速）（注意点数是总数的一半）
    //find_max_fix(XImag, FRAME_LEN2, &index);

    // 4. 计算对应的频率 公式：*freq=index*fs/(N*D)+f0; D默认为32
    //*freq=index + f0;       //  频点粗算    输入为frame16384.txt时，此处标准结果为3226
    //*freq = (index>>1) + f0;  //  频点粗算    (测试需要，临时修改！！上面是正式版) 输入为frame8192.txt时，此处标准结果为3226
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
//  名称:
//      howlDetectFrame_fix
//  功能:
//      啸叫检测及陷波消除
//  参数:
//      1.音频数据指针
//  返回值：
//      无
//////////////////////////////////////////////////////////////////////////
Sub howlDetectFrame_fix;
    push RA2;
    push RA7;
    push RD2;

    RA2 = RSP;// 入参基址
#define dataBuf     M[RA2+4*MMU_BASE]       // 音频数据指针

    RD1 = 11*MMU_BASE;
    RSP -= RD1;
    RA7 = RSP;// 局部变量基址
//#define howlflagtmp         M[RA7+0*MMU_BASE]   // 取值  0,1,2，，0  未啸叫  ，1 啸叫   2 能量过阈值
#define p_origin            M[RA7+1*MMU_BASE]   // origin指向history中的当前帧地址
#define howlfreq            M[RA7+2*MMU_BASE]   // 精确的啸叫频点值
#define howlfreq_Offset     (2*MMU_BASE)

//#define freq                M[RA7+3*MMU_BASE]   // 粗略的啸叫频点值
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

    // 拷贝历史3帧，向前平移
RD0 = RN_history_comp_ADDR_Plus;
call En_RAM_To_PATH1;
    RD0 = RN_history_comp_ADDR2;// 源地址
    RA0 = RD0;
    RD0 = RN_history_comp_ADDR1;// 目标地址
    RA1 = RD0;
    RD0 = L_Move_Howl_M2_A4;
    call DMA_Trans;

    // 整理数据为复数域格式写入缓存
//    RD0 = dataBuf;
//    RD1 = RN_history_comp_new;
//    call Real_To_Complex;//PATH1 2次
    RA0 = dataBuf;
    RD0 = RN_history_comp_new;
    RA1 = RD0;
    RD0 = FL_M2_A2;
    call Real_To_Complex2;//PATH1 2次

    // ========================= 粗检开始 =============================
    g_howlindex_fix++;

    RD0 = g_howlindex_fix;
    RD0 -= 16;  // 第16帧进入粗检啸叫第一步
    if(RQ_Zero) goto L_howlDetectFrame_fix_S16_S17;
    RD0 = g_howlindex_fix;
    RD0 -= 17;  // 第16帧进入粗检啸叫第二步
    if(RQ_Zero) goto L_howlDetectFrame_fix_S16_S17;
    goto L_howlDetectFrame_fix_SCheck_End;

L_howlDetectFrame_fix_S16_S17:
    // 粗测啸叫
    RD0 = g_freq_Offset;
    RD0 += RA4;
    send_para(RD0);
    RD0 = g_howlflagtmp_Offset;
    RD0 += RA4;
    send_para(RD0);
    call HowlingDetect_fix;
    if(RD0_nZero) goto L_howlDetectFrame_fix_Notch;// 粗检挂起时，略过精检
    g_howlindex_fix = 0;// 返回S0状态

    // 粗检有啸叫时，HowlStartNum++，HowlDelNum清零;
    // 累计6次粗检有啸叫判定为真啸叫，释放真啸叫标记，不足6次判定为无啸叫，释放无真啸叫标记;
    // 粗检无啸叫时，HowlDelNum++;
    // 连续10次粗检无啸叫判定为无真啸叫，释放无真啸叫标记，HowlStartNum清零，HowlDelNum清零;
    RD0 = g_howlflagtmp;
    if(RD0==0) goto L_howlDetectFrame_fix_nHowl_S;// 声压过小不算啸叫
    RD0 -= 2;
    if(RD0==0) goto L_howlDetectFrame_fix_nHowl_S;// 声压超阈值不算啸叫
    g_HowlDelNum = 0;// 陷波关闭计数器清零
    g_HowlStartNum++;// 陷波启动计数器++
    RD1 = RN_NOTCH_START_TH;// 累计发现RN_NOTCH_START_TH次啸叫判为真啸叫
    RD0 = g_HowlStartNum;
    RD1 -= RD0;
    if(RQ>0) goto L_howlDetectFrame_fix_Howl_nConfirm;// 未累计达到六次粗测啸叫


    // 有真啸叫，输出陷波器使能信号
    RD0 = 1;
    g_howlflag_fix = RD0;
    goto L_howlDetectFrame_fix_SCheck_End;

L_howlDetectFrame_fix_Howl_nConfirm:
    // 无真啸叫，输出陷波器禁能信号
    g_howlflag_fix = 0;
    goto L_howlDetectFrame_fix_SCheck_End;

L_howlDetectFrame_fix_nHowl_S:
    g_HowlDelNum++;// 陷波关闭计数器++
    RD0 = g_HowlDelNum;
    RD1 = RN_NOTCH_STOP_TH;// 连续RN_NOTCH_STOP_TH次无啸叫判为真无啸叫
    RD1 -= RD0;
    if(RQ>0) goto L_howlDetectFrame_fix_SCheck_End;
    // 真无啸叫
    g_howlflag_fix = 0;
    g_HowlDelNum = 0;
    g_HowlStartNum = 0;
    g_Notch_Freq0 = 0;
    g_Notch_Freq1 = 0;
    g_Notch_Freq2 = 0;
    g_Notch_Index = 0;

L_howlDetectFrame_fix_SCheck_End:
// ========================= 粗检结束 =============================

// ========================= 精检开始 =============================
    RD0 = g_Status_zfft;
    if(RD0_nZero) goto L_howlDetectFrame_fix_S1to14;// 当精检已经启动时，直接进入精检过程

    // 当精检处于静止状态(S0)时，如果陷波器使能信号与最后一次粗检啸叫均有效时，转移至S1
    RD0 = g_howlflag_fix;
    if(RD0_Zero) goto L_howlDetectFrame_fix_Notch;
    RD0 = g_howlflagtmp;
    if(RD0_Zero) goto L_howlDetectFrame_fix_Notch;
    g_howlflagtmp = 0;
    g_Status_zfft ++;// S0 ---> S1
    goto L_howlDetectFrame_fix_Notch;

L_howlDetectFrame_fix_S1to14:
    // 精检啸叫频率
    RD0 = howlfreq_Offset;// 精检频率
    RD0 += RA7;
    send_para(RD0);
    RD0 = 16384;
    send_para(RD0);
    RD0 = g_freq;// 粗检频率
    RD0 -= 100;
    send_para(RD0);
    call zfft_fix;
    if(RD0_nZero) goto L_howlDetectFrame_fix_Notch;// 精检挂起退出

    // 精检完成，登记并设置陷波器系数
    RD0 = howlfreq;
    call Regist_Notch_Freq;
// ========================= 精检结束 =============================

// ========================= 陷波开始 =============================
L_howlDetectFrame_fix_Notch:
    // 3. 陷波(既要对history缓存操作，也要写回数据源地址？？？？)
    RD0 = MASK_NOTCH;
    RD0 &= g_Switch;// 验配工具开关
    if(RQ_Zero) goto L_howlDetectFrame_fix_Notch_Dis;

    // 判断是否需要执行陷波器0
    RD0 = g_Notch_Freq0;
    if(RD0_Zero) goto L_howlDetectFrame_fix_Notch1;

    // 更新陷波器系数
    RD1 = RA7;
    RD1 += 5*MMU_BASE;
    RA0 = RD1;
    call SetiirNotch_4Order;
    call _IIR_PATH3_SetHD_HawlClr;

    // 陷波器0使能
    RD0 = dataBuf;
    RA0 = RD0;
    RA1 = RD0;
    RD0 = L16_M68_A1;
    RD1 = 1;
    call _IIR_PATH3_HawlClr;

L_howlDetectFrame_fix_Notch1:
    // 判断是否需要执行陷波器1
    RD0 = g_Notch_Freq1;
    if(RD0_Zero) goto L_howlDetectFrame_fix_Notch2;
//goto L_howlDetectFrame_fix_Notch2;
    // 更新陷波器系数
    RD1 = RA7;
    RD1 += 5*MMU_BASE;
    RA0 = RD1;
    call SetiirNotch_4Order;
    call _IIR_PATH3_SetHD_HawlClr;

    // 陷波器1使能
    RD0 = dataBuf;
    RA0 = RD0;
    RA1 = RD0;
    RD0 = L16_M68_A1;
    RD1 = 2;
    call _IIR_PATH3_HawlClr;

L_howlDetectFrame_fix_Notch2:
    // 判断是否需要执行陷波器2
    RD0 = g_Notch_Freq2;
    if(RD0_Zero) goto L_howlDetectFrame_fix_Notch_End;
//goto L_howlDetectFrame_fix_Notch_End;
    // 更新陷波器系数
    RD1 = RA7;
    RD1 += 5*MMU_BASE;
    RA0 = RD1;
    call SetiirNotch_4Order;
    call _IIR_PATH3_SetHD_HawlClr;

    // 陷波器2使能
    RD0 = dataBuf;
    RA0 = RD0;
    RA1 = RD0;
    RD0 = L16_M68_A1;
    RD1 = 3;
    call _IIR_PATH3_HawlClr;

L_howlDetectFrame_fix_Notch_Dis:
L_howlDetectFrame_fix_Notch_End:
// ========================= 陷波结束 =============================

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
//  名称:
//      SetiirNotch_4Order
//  功能:
//      根据目标频率设置陷波器系数
//  参数:
//      1.RD0:目标频率
//      2.RA0:参数基址(out)
//            系数a1    M[RA0+5*MMU_BASE]
//            系数a2    M[RA0+4*MMU_BASE]
//            系数a3    M[RA0+3*MMU_BASE]
//            系数b1    M[RA0+2*MMU_BASE]
//            系数b2    M[RA0+1*MMU_BASE]
//            系数b3    M[RA0+0*MMU_BASE]
//  返回值：
//      无
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

    // 查表法计算cos(2*PI*freq/fs)
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

    // 如果w符号为正，则需要把b1,a1,a3取负数
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
    // 求4096w2
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
//  名称:
//      _IIR_PATH1_SetHD_HawlClr
//  功能:
//      更新IIR_PATH1滤波器CBank1系数
//  参数:
//      1.H16=b1，L16=a1
//  返回值：
//      无
//  注释：
//      b11 = 0x2000      xxxx       0x2000       0       0
//      a11 =             xxxx       0x99eb       0       0
//      int b1  = { 8192, -3385, 8192, 0, 0 }; // 陷波器系数初值，过程中仅修改[1]值其他不变
//      int a1  = { 8192, -3046, 6635, 0, 0 }; // 陷波器系数初值，过程中仅修改[1]值其他不变
//////////////////////////////////////////////////////////////////////////
Sub_AutoField _IIR_PATH1_SetHD_HawlClr;
    RD2 = RD0;
    //系数格式转换
    RF_GetH16(RD0);
    if(RD0_Bit15==0) goto L_HawlClr_L0;
    RF_Neg(RD0);
    RF_GetL16(RD0);
    RD0_SetBit15;
L_HawlClr_L0:
    RD3 = RD0;      //b1硬件格式，{符号位，绝对值}
    RD0 = RD2;
    if(RD0_Bit15==0) goto L_HawlClr_L1;
    RF_Neg(RD0);
    RF_GetL16(RD0);
    RD0_SetBit15;
L_HawlClr_L1:
    RD2 = 0x8000;
    RD2 ^= RD0;     //a1硬件格式，{符号位取反，绝对值}

    MemSetRAM4K_Enable;
    IIR_PATH1_Enable;
    RD0 = 0x6;      //采用CBank1，XBank2
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
    RD0 = 0x047C;    //此处为系数对应的配置
    IIR_PATH1_HD = RD0;

    //增加一段做增益调节，增益*4
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
////  名称:
////      _IIR_PATH1_SetHD_Const
////  功能:
////      设置IIR_PATH1滤波器固定系数
////  参数:
////      无
////  返回值：
////      无
////  注释：G1 = 6 , 256/16/6 = 2.5
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
//    RD0 = 0x6;      //采用CBank1，XBank2
//    IIR_PATH1_BANK = RD0;
//
//    RD0 = 0x2000;         // b11系数
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x9b12;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x3d2f;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x9b12;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x2000;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x0e39;         // a11系数
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x805a;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x01ad;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x8469;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x024C;//增益配置位
//    IIR_PATH1_HD = RD0;
////      b21 = 0x2000    0x94f2    0x20db    0x94f2    0x2000
////      a21 =           0x1091    0x8c11    0x0bbb    0x955e
//    RD0 = 0x2000;         // b21系数
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x94f2;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x20db;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x94f2;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x2000;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x1091;         // a21系数
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x8c11;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x0bbb;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x955e;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x024C;//增益配置位
//    IIR_PATH1_HD = RD0;
////      b31 = 0x2000    0x92ea    0x1779    0x92ea    0x2000
////      a31 =           0x11a7    0x9185    0x10a6    0x9dcc
//    RD0 = 0x2000;         // b31系数
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x92ea;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x1779;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x92ea;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x2000;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x11a7;         // a31系数
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x9185;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x10a6;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x9dcc;
//    IIR_PATH1_HD = RD0;
//    RD0 = 0x024C;//增益配置位
//    IIR_PATH1_HD = RD0;
//
//    //IIR_PATH1_Disable;
//    MemSet_Disable;
//
//    IIR_PATH1_CLRADDR;
//
//    Return_AutoField(0*MMU_BASE);


//////////////////////////////////////////////////////////////////////////
//  名称:
//      Regist_Notch_Freq
//  功能:
//      登记陷波器工作频率，并设置陷波器系数
//  数据出口：
//      1.g_Notch_Freq0
//      2.g_Notch_Freq1
//      3.g_Notch_Freq2
//      4.g_Notch_Index
//  参数:
//      1.RD0:陷波器工作频率
//  返回值：
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Regist_Notch_Freq;
    RD2 = RD0;

    // 如果新测频率与g_Notch_Freq0相似，则不登记
    RD0 = RD2;
    RD1 = g_Notch_Freq0;
    RD0 -= RD1;
    RF_Abs(RD0);
    RD1 = RN_NOTCH_FREQ_TOLERANCE;
    RD1 -= RD0;
    if(RQ>0) goto L_Regist_Notch_Freq_End;

    // 如果新测频率与g_Notch_Freq1相似，则不登记
    RD0 = RD2;
    RD1 = g_Notch_Freq1;
    RD0 -= RD1;
    RF_Abs(RD0);
    RD1 = RN_NOTCH_FREQ_TOLERANCE;
    RD1 -= RD0;
    if(RQ>0) goto L_Regist_Notch_Freq_End;

    // 如果新测频率与g_Notch_Freq2相似，则不登记
    RD0 = RD2;
    RD1 = g_Notch_Freq2;
    RD0 -= RD1;
    RF_Abs(RD0);
    RD1 = RN_NOTCH_FREQ_TOLERANCE;
    RD1 -= RD0;
    if(RQ>0) goto L_Regist_Notch_Freq_End;

    // 登记新的频率
    RD0 = g_Notch_Freq0_Offset;
    RD1 = g_Notch_Index;
    RF_ShiftL2(RD1);
    RD0 += RD1;
    M[RA4+RD0] = RD2;


    // 成功登记新的频率后，g_Notch_Index = (g_Notch_Index++) mod 3;
    g_Notch_Index ++;
    RD1 = RN_NOTCH_QTY;
    RD1 ^= g_Notch_Index;
    if(RQ_nZero) goto L_Regist_Notch_Freq_End;
    g_Notch_Index = 0;
L_Regist_Notch_Freq_End:
    Return_AutoField(0*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      _IIR_PATH3_SetHD_HawlClr
//  功能:
//      更新IIR_PATH3滤波器CBank1系数，用于多级陷波
//  参数:
//      1.RA0：参数基址
//              a1   M[RA0+5*MMU_BASE]
//              a2   M[RA0+4*MMU_BASE]
//              a3   M[RA0+3*MMU_BASE]
//              b1   M[RA0+2*MMU_BASE]
//              b2   M[RA0+1*MMU_BASE]
//              b3   M[RA0+0*MMU_BASE]
//  返回值：
//      无
//  注释：
//  b11 = 0x2000      b1      b2     b3     0x2000
//  a11 = 0x2000      a1      a2     a3     NOTCH_R4
//////////////////////////////////////////////////////////////////////////
Sub_AutoField _IIR_PATH3_SetHD_HawlClr;
    //M[RSP+0*MMU_BASE]    b3
    //M[RSP+1*MMU_BASE]    b2
    //M[RSP+2*MMU_BASE]    b1

#define NOTCH_R4   0x87AE   //0x7AE=>1966    // r的4次方,量纲是Q13,r=0.7时

#define b3      M[RA0+0*MMU_BASE]
#define b2      M[RA0+1*MMU_BASE]
#define b1      M[RA0+2*MMU_BASE]
#define a3      M[RA0+3*MMU_BASE]
#define a2      M[RA0+4*MMU_BASE]
#define a1      M[RA0+5*MMU_BASE]
    //b2有可能超出32768，对b2和a2取1/2
    RD0 = b2;
    //RD0_SignExtL16;
    RF_ShiftR1(RD0);
    b2 = RD0;
    RD0 = a2;
    //RD0_SignExtL16;
    RF_ShiftR1(RD0);
    a2 = RD0;
    //b系数格式转换->{符号位，绝对值}
    RD1 = 0;
    RD2 = 3;
L_HawlClr3_Lb:
    RD0 = M[RA0+RD1];
    if(RD0_Bit15==0) goto L_HawlClr3_L0;
    RF_Neg(RD0);
    RD0_SetBit15;
L_HawlClr3_L0:
    M[RA0+RD1] = RD0;      //b1硬件格式，{符号位，绝对值}
    RD1 += MMU_BASE;
    RD2 --;
    if(RQ_nZero) goto L_HawlClr3_Lb;

    //a系数格式转换->{符号位取反，绝对值}
    RD0 = 0x8000;
    RA1 = RD0;
    RD2 = 3;
L_HawlClr3_La:
    RD0 = M[RA0+RD1];
    if(RD0_Bit15==0) goto L_HawlClr3_L1;
    RF_Neg(RD0);
    RD0_SetBit15;
L_HawlClr3_L1:
    RD0 ^= RA1;      //符号位取反
    M[RA0+RD1] = RD0;      //b1硬件格式，{符号位，绝对值}
    RD1 += MMU_BASE;
    RD2 --;
    if(RQ_nZero) goto L_HawlClr3_La;

    MemSetRAM4K_Enable;
    IIR_PATH3_Enable;
    RD0 = 0x4;      //采用CBank1，XBank为入口参数
    IIR_PATH3_BANK = RD0;

    IIR_PATH3_CLRADDR;  // 本操作让参数寄存器指针归零
    //增加二段做增益调节，增益*4
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
    RD0 = 0x037C;    //此处为系数对应的配置，注意b2/a2 缩位存储
    IIR_PATH3_HD = RD0;

    //增加一段做增益调节，增益*4
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
    RD0 = 0x037C;    //此处为系数对应的配置，注意b2/a2 缩位存储
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
//  名称:
//      _IIR_PATH3_HawlClr
//  功能:
//      使用IIR1_3执行陷波，Para1, Data10
//  参数:
//      1.RA0:输入序列指针，16bit紧凑格式序列
//      2.RA1:输出序列指针，16bit紧凑格式序列(out)
//      3.RD0:TimerNum值 = (输出序列Dword长度*48)+1
//      4.RD1:数据缓存编号0~3
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _IIR_PATH3_HawlClr;
    RD2 = RD0;
    //--------------------------------------------------
    //设置GRAM属性为DMA_Ctrl3操作，Group为单位
    MemSetPath_Enable;  //设置通道使能
    M[RA0+MGRP_PATH3] = RD0;//选择PATH3，通道信息在偏址上

    //配置ALU参数
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    //配置相关的4KRAM
    RD0 = DMA_PATH3;
    M[RA0] = RD0;
    M[RA1] = RD0;
    //IIR_PATH3_Enable;
    RD0 = 0x4;
    RD0 += RD1;
    IIR_PATH3_BANK = RD0;
    MemSet_Disable;     //配置结束

    //配置DMA_Ctrl参数，包括地址.长度
    RD0 = RA0;//源地址
    send_para(RD0);
    RD0 = RA1;//目标地址
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_FiltIIR;

    //选择DMA_Ctrl通道，并启动运算
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

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
//  名称:
//      classFrame
//  功能:
//      信噪比分级算法，带平滑
//  参数:
//      1.音频数据指针
//  返回值：
//      1.g_class（全局） 1~纯语音 2~噪声语音混合 3~纯噪声
//////////////////////////////////////////////////////////////////////////
Sub classFrame;
    push RA2;
    push RD2;

    RA2 = RSP;// 入参基址
#define dataBuf   M[RA2+3*MMU_BASE]               // 输入数据指针

    // 找出最大值
    RD0 = dataBuf;
    RD1 = FL_M2_A4_A1;
    call FindMaxMin;//PATH1 数据按16位紧凑格式存储。
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

//      if (g_m_10 == 1)//m_10 表示 m_10秒判断一次 ，=1即1s判断一次
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

// 处理g_count_2 >= g_count_1的情况
    RD2 = 2;
    RD0 = g_count_2;
    RD1 = g_count_3;
    RD1 -= RD0;
    if(RQ<0) goto L_classFrame_06;
    RD2 = 1;
    goto L_classFrame_06;

// 处理g_count_2 < g_count_1的情况
L_classFrame_05:
    RD2 = 3;
    RD0 = g_count_1;
    RD1 = g_count_3;
    RD1 -= RD0;
    if(RQ<0) goto L_classFrame_06;
    RD2 = 1;

L_classFrame_06:
// 比较结束
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
//  名称:
//      classification
//  功能:
//      信噪比分级算法
//      数据入口：g_env_LP（全局）
//  参数:
//      无
//  返回值：
//      1.RD0:1~纯噪声 2~噪声语音混合 3~纯语音
//////////////////////////////////////////////////////////////////////////
Sub classification;
   push RA0;
   push RA1;
   push RA7;
   push RD2;
   push RD3;

#define env_LP          g_env_LP // 包络指针

#define st_RMS          RD4
#define st_RMS1         RD5
#define st_RMS3         RD6
#define m               RD7
#define K1        0x00190019// 25

    // 1. 计算RMS，即均方值，注意右移的7对应n_frames_per_obs=128
    RD0 = env_LP;
    RD1 = L128_M2_A4_A2;
    call MeanSquareAverage;// 数据按32位存储，高16位均为0

    // 开平方
    call sqrt_fix;
    RD1 = 15;
    call _Rf_ShiftR_Reg;
    st_RMS = RD0;

    // 2. 去直流 (用ALU的序列减进行快速运算)
    // 序列值先除2
    RD0 = env_LP;
    RA0 = RD0;
    RD0 = Op32Bit+Rf_SftR1;
    RD1 = L128_M2_A4;
    call Cal_Single_Shift;

    // 一阶差分
    RD0 = env_LP;
    RA0 = RD0;
    RA1 = RD0;
    RD0 = 1*MMU_BASE;
    RA0 += RD0;
    RD1 = p_env_diff+1*MMU_BASE;
    RD0 = L128_M3_A2;
    call Dual_Ser_Sub32;//PATH1 数据按32位存储，高16位均为0，结果也按32位存储，低16位有效，高位是全0或全1，分别对应正负数

    // 第一个数清零
    RD0 = p_env_diff;
    RA0 = RD0;
    call En_GRAM_To_CPU;
    M[RA0] = 0;
    call Dis_GRAM_To_CPU;

    // 整理格式
    RD0 = p_env_diff;
    RA0 = RD0;
    RD0 = p_env_diff;
    RA1 = RD0;
    RD0 = L128_M3_A3;
    call Get_Imag;//PATH1

    // 3. 调制滤波器组 低通，带通，高通
    //初始化IIR_PATH1滤波器
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

    //初始化IIR_PATH1滤波器
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

    // 4. 修正因子 （调用ALU加速，序列乘）
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

    // 5. 分别计算RMS，即均方值，注意右移的7对应n_frames_per_obs=128
    RD0 = p_env_chan1;
    RD1 = L64_M2_A4_A2;
    call MeanSquareAverage;
    // 开平方
    call sqrt_fix;
    RD1 = 15;
    call _Rf_ShiftR_Reg;
    st_RMS1 = RD0;

    RD0 = p_env_chan3;
    RD1 = L64_M2_A4_A2;
    call MeanSquareAverage;
    // 开平方
    call sqrt_fix;
    RD1 = 15;
    call _Rf_ShiftR_Reg;
    st_RMS3 = RD0;

    // 6. 调制深度标准化
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
    if(RD0_Bit31==0) goto L_classification_02;// 因为后面使用无符号方式进行比大小，因此先将m<0的情况全部归为Return 3
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

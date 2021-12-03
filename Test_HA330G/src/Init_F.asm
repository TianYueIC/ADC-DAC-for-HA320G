#define _INIT_F_

#include <CPU11.def>
#include <resource_allocation.def>
#include <RN_DSP_Cfg.def>
#include <DMA_ParaCfg.def>
#include <Global.def>
#include <USI.def>
#include <SPI_Master.def>
#include <SPI_Slave.def>
#include <UART.def>
#include <GPIO.def>
#include <string.def>
#include <SAR.def>
#include <BL_SPI.def>
#include <GD25.def>
#include <Trimming.def>

extern _DMA_ParaCfg_Flow2;
extern _DMA_ParaCfg_I2S;
CODE SEGMENT INIT_F;

////////////////////////////////////////////////////////
//  名称:
//      Mem_Init
//  功能:
//      系统内存初始化
//  参数:
//      无
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField Mem_Init;
    // 全局变量初始化
    g_Cnt_Frame = 0;
    g_class = 1;
    g_class_cur = 0;
    g_count_1 = 0;
    g_classFrameCount = 0;
    g_count_2 = 0;
    g_count_3 = 0;
    g_m_10 = 0;

    g_ADC_Bias_Adj = 32;
    g_dBGain_Bank = 0;
    g_Vol = RN_VOL_DEFAULT;
    g_Switch = 0;

    RD0 = RN_out_history_comp_ADDR7;
    g_NLMS_history_ADDR = RD0;
    g_rn_1 = 0;
    g_rn_2 = 0;
    g_rn_3 = 0;
    g_Timer = 0;
    g_Bank_Num = CHANNEL_NUM;
    g_Key_ID = 0;
    g_VT3 = 0;

    g_Flag_Import_Sound = 0;

    g_Ind_1KHz = 0;
    g_Ind_Silent = 0;
    g_Ind_SW_Times = 0;

    RD0 = RN_PGA_GAIN;
    g_G1_PGA = RD0;
    g_G1_PGA_Next = RD0;
    g_Scene = 0;
    RD0 = 500;
    g_Cnt1 = RD0;
    g_SysStatus = 0;
    RD0 = 0x3F003F3F;// VCHK1(锂电电量)最高  Vref无效  VBAT3V(按键)最高  VCHK0(音量)最高
    g_SAR_AD = RD0;

    RD0 = 1;
    g_agci_releFr_cnt = RD0;
    RD1 = agci_releFr_offset;
    RD1 += RA4;
    RA1 = RD1;
    M[RA1] = RD0;


    // vs_p，vn_p清0
    RD0 = 2*16*MMU_BASE;
    send_para(RD0);
    RD0 = 0;
    send_para(RD0);
    RD0 = vs_p_Offset;
    RD0 += RA4;
    send_para(RD0);
    call memset;

    // k_p置初值，选取信噪比最小情况（最大斜率）
    RD0 = k_p_Offset;
    RD0 += RA4;
    RA1 = RD0;
    RD0 = 0x00000CCC;
    M[RA1++] = RD0;
    RD0 = 0x00000CCC;
    M[RA1++] = RD0;
    RD0 = 0x00000AB3;
    M[RA1++] = RD0;
    RD0 = 0x00000899;
    M[RA1++] = RD0;

    // b_p置初值，选取信噪比最小情况（最大截距）
    RD0 = b_p_Offset;
    RD0 += RA4;
    RA1 = RD0;
    RD0 = 0xFFFF1C78;
    M[RA1++] = RD0;
    RD0 = 0xFFFF1C78;
    M[RA1++] = RD0;
    RD0 = 0xFFFF38E2;
    M[RA1++] = RD0;
    RD0 = 0xFFFF555A;
    M[RA1++] = RD0;

    // 音量表置初值
    RD0 = Volume_Table_Offset;
    RD0 += RA4;
    RA1 = RD0;
    RD0 = 0xfe;// 17.5
    M[RA1++] = RD0;
    RD0 = 0xce;// 15.6
    M[RA1++] = RD0;
    RD0 = 0x8e;// 12.0
    M[RA1++] = RD0;
    RD0 = 0x6e;// 9.5
    M[RA1++] = RD0;
    RD0 = 0x4e;// 6.0
    M[RA1++] = RD0;
    RD0 = 0x3e;// 3.5
    M[RA1++] = RD0;
    RD0 = 0x2e;// 0.0
    M[RA1++] = RD0;
    RD0 = 0xb0;// -3.3
    M[RA1++] = RD0;
    RD0 = 0x1e;// -6.0
    M[RA1++] = RD0;
    RD0 = 0xb2;// -9.3
    M[RA1++] = RD0;
    RD0 = 0x82;// -12.0
    M[RA1++] = RD0;
    RD0 = 0xb4;// -15.3
    M[RA1++] = RD0;
    RD0 = 0x84;// -18.1
    M[RA1++] = RD0;
    RD0 = 0xb6;// -21.3
    M[RA1++] = RD0;
    RD0 = 0x86;// -24.1
    M[RA1++] = RD0;
    RD0 = 0xb8;// -27.3
    M[RA1++] = RD0;
    RD0 = 0x88;// -30.1
    M[RA1++] = RD0;
    RD0 = 0xba;// -33.4
    M[RA1++] = RD0;
    RD0 = 0x8a;// -36.1
    M[RA1++] = RD0;
    RD0 = 0xbc;// -39.4
    M[RA1++] = RD0;
    RD0 = 0x8c;// -42.1
    M[RA1++] = RD0;
    RD0 = 0x6c;// -44.6
    M[RA1++] = RD0;
    RD0 = 0x4c;// -48.2
    M[RA1++] = RD0;

    //配置参数区独立字清零
    RD2 = (RN_PARA_LEN_B/4)+1;
    RD1 = g_Switch_Offset;
L_Para_Init_Loop:
    M[RA4+RD1] = 0;
    RD1 += 4;
    RD2 --;
    if(RQ_nZero) goto L_Para_Init_Loop;
    //Buf1清零（WDRC）
    RD2 = 90;
    RD1 = Buf1_Offset;
L_WDRC_Buf_Init_Loop:
    M[RA4+RD1] = 0;
    RD1 += 4;
    RD2 --;
    if(RQ_nZero) goto L_WDRC_Buf_Init_Loop;

    //清零
    //Gain_NR_Array_Offset
    //Gain_WDRC_Array_Offset
    //Sum_Array_Offset
    //Spl_Array_Offset
    RD2 = 8+8+24+24;
    RD1 = Gain_NR_Array_Offset;
L_Array_Init_Loop:
    M[RA4+RD1] = 0;
    RD1 += 4;
    RD2 --;
    if(RQ_nZero) goto L_Array_Init_Loop;

    //MS_Offset清零
    RD2 = 4;
    RD1 = MS_Offset;
L_Array2_Init_Loop:
    M[RA4+RD1] = 0;
    RD1 += 4;
    RD2 --;
    if(RQ_nZero) goto L_Array2_Init_Loop;

    //nAbsSum_p_Offset清零  //,Buf_AGCO_SPL_Offset,AGCO_a_Offset,AGCO_b_Offset
    RD1 = nAbsSum_p_Offset;
    M[RA4+RD1] = 0;
    RD1 = Buf_AGCO_SPL_Offset;
    M[RA4+RD1] = 0;
    RD1 = Buf_AGCI_SPL_Offset;
    M[RA4+RD1] = 0;
    RD1 = Buf_ADC_GainLvNow_Offset;
    RD0 = 2;
    M[RA4+RD1] = RD0;
//    RD1 = AGCO_a_Offset;
//    //RD0 = 0x3bec;
//    RD0 = 21605;
//    M[RA4+RD1] = RD0;
//    RD1 = AGCO_b_Offset;
//    //RD0 =  1040;
//    RD0 = 26;
//    M[RA4+RD1] = RD0;
//    RD1 = AGCO_SPL_Ref_Offset;
//    RD0 = 90*256;
//    M[RA4+RD1] = RD0;

    // 清空RAM
    call Clr_RAM;

    // FFT表初始化置GRAM
    call FFT_Init;

    Return_AutoField(0);


////////////////////////////////////////////////////////
//  名称:
//      FFT_Init
//  功能:
//      FFT系数初始化
//  参数:
//      无
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField FFT_Init;
    RD0 = RN_FFT_COFF_GRAM_ADDR;
    call En_GRAM_To_CPU;
    RD0 = RN_FFT_COFF_GRAM_ADDR_Plus1;
    call En_GRAM_To_CPU;
    RD0 = RN_FFT_COFF_GRAM_ADDR_Plus2;
    call En_GRAM_To_CPU;
    RD0 = RN_FFT_COFF_GRAM_ADDR_Plus3;
    call En_GRAM_To_CPU;

    RD0 = RN_FFT_COFF_ADDR;
    RA0 = RD0;
    RD0 = RN_FFT_COFF_GRAM_ADDR;
    RA1 = RD0;
    RD2 = 1024;
L_FFT_Init_Loop:
    RD0 = M[RA0];
    RA0 ++;
    M[RA1++] = RD0;
    RD2 --;
    if(RQ_nZero) goto L_FFT_Init_Loop;
    RD0 = RN_FFT_COFF_GRAM_ADDR;
    call Dis_GRAM_To_CPU;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      IIR_PATH1_LP4Class
//  功能:
//      初始化用于信噪比分级算法的低通滤波器，IIR_PATH1，？？？？？
//      b = { 8192,   -7452,   -7452,    8192,   0 }符号位不取反
//      a = { 8192,  -22973,   21615,   -6817,   0 }符号位取反
//      滤波器原本带90增益，通过后续调整，消除该增益（归一化）
//  参数:
//      无？？？？？
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField IIR_PATH1_LP4Class;
    // b
    RD0 = 0x2000;
    IIR_PATH1_HD = RD0;

    RD0 = 0x9d1c;
    IIR_PATH1_HD = RD0;
    RD0 = 0x9d1c;
    IIR_PATH1_HD = RD0;
    RD0 = 0x2000;
    IIR_PATH1_HD = RD0;
    RD0 = 0;
    IIR_PATH1_HD = RD0;

    // a
    RD0 = 0x59bd;
    IIR_PATH1_HD = RD0;
    RD0 = 0xD46f;
    IIR_PATH1_HD = RD0;
    RD0 = 0x1aa1;
    IIR_PATH1_HD = RD0;
    RD0 = 0;
    IIR_PATH1_HD = RD0;

    // 系数
    RD0 = 0x0659;      //此处为系数对应的配置，增益调整值:(2+0.5+0.25)/256 = 0.0107421875 滤波增益 = 90 * 0.0107421875 = 0.966796875
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
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    //寄存器地址复位
    IIR_PATH1_CLRADDR;
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      IIR_PATH1_HP4Class
//  功能:
//      初始化用于信噪比分级算法的低通滤波器，初始化IIR_PATH1，？？？？？
//      b = { 8192,  -29647,   21543*2,  -29647,    8192 } 符号位不取反
//      a = { 8192,  -16236,   7989*2,   -7227,    1577 } 符号位取反
//      滤波器原本带2.42增益，通过后续调整，消除该增益（归一化）
//  参数:
//      无？？？？？
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField IIR_PATH1_HP4Class;
    // b
    RD0 = 0x2000;
    IIR_PATH1_HD = RD0;

    RD0 = 0xF3CF;
    IIR_PATH1_HD = RD0;
    RD0 = 0x5427;
    IIR_PATH1_HD = RD0;
    RD0 = 0xF3CF;
    IIR_PATH1_HD = RD0;
    RD0 = 0x2000;
    IIR_PATH1_HD = RD0;

    // a
    RD0 = 0x3F6C;
    IIR_PATH1_HD = RD0;
    RD0 = 0x9F35;
    IIR_PATH1_HD = RD0;
    RD0 = 0x1C3B;
    IIR_PATH1_HD = RD0;
    RD0 = 0x8629;
    IIR_PATH1_HD = RD0;

    // 系数
    RD0 = 0x057C;      //此处为系数对应的配置，增益调整值:(16*3.75)/256 = 0.234 滤波增益 = 2.42 * 0.234375 = 0.5671875
    IIR_PATH1_HD = RD0;

    RD0 = 0x5A45;      //为调整增益增加一段滤波 8192*(1.6/0.5671875) = 0x5A45 相当于归一化后乘1.6
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
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    //寄存器地址复位
    IIR_PATH1_CLRADDR;
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      ADC_Table_Init
//  功能:
//      配置ADC的6-16转换表
//  参数:
//      1.RD0:表首地址(输出很难超过30000)
//				不移位，16b表
//  返回值:
//      无
////////////////////////////////////////////////////////
/*Sub_AutoField ADC_Table_Init;
    RA0 = RD0;  //源地址
    RD0 = RN_ADDR_ADC_TABLE;
    RD0_SetBit7;
    RA1 = RD0;  //表地址

    //核心表，64 X 16bit
    RD2 = 32;
L_ADTable_Init_L0:
    RD0 = M[RA0];
    RA0++;
    M[RA1] = RD0;
    RF_RotateR16(RD0);
    M[RA1+2] = RD0;
    RA1 += MMU_BASE;
    RD2 --;
    if(RQ_nZero) goto L_ADTable_Init_L0;
    //其他6个溢出值表
    RD0 = RN_ADDR_ADC_TABLE;
    RA1 = RD0;
    RD0 = 0;
    RD0_SetBit8;
    RD1 = M[RA0];//0xa0009000;//
    RA0 ++;
    M[RA1+RD0] = RD1;
    RF_ShiftL1(RD0);
    RF_RotateR16(RD1);
    M[RA1+RD0] = RD1;
    RF_ShiftL1(RD0);
    RD1 = M[RA0];//0x3f00c000;//
    RA0 ++;
    M[RA1+RD0] = RD1;
    RF_ShiftL1(RD0);
    RF_RotateR16(RD1);
    M[RA1+RD0] = RD1;
    RF_ShiftL1(RD0);
    RD1 = M[RA0];//0x70005f00;//
    RA0 ++;
    M[RA1+RD0] = RD1;
    RF_ShiftL1(RD0);
    RF_RotateR16(RD1);
    M[RA1+RD0] = RD1;
    Return_AutoField(0*MMU_BASE);
*/


////////////////////////////////////////////////////////
//  名称:
//      IIR_PATH1_LP32Init
//  功能:
//      初始化用于1/32抽点的低通滤波器，初始化IIR_PATH1，？？？？？
//  参数:
//      无？？？？
//  返回值:
//      无
//  注释:
//      原系数:
//      b11 =   8192       -7971       -7971        8192
//      a11 =   8192      -23482       22487       -7193
//      b21 =   8192      -16268        8192
//      a21 =   8192      -16196        8088
//      硬件格式:
//      b11 = 0x2000      0x9f23       0x9f23       0x2000       0
//      a11 =             0x5bba       0xd7d7       0x1c19       0
//      b21 = 0x2000      0xbf8c       0x2000       0            0
//      a21 =             0x3f44       0x9f98       0            0
////////////////////////////////////////////////////////
Sub_AutoField IIR_PATH1_LP32Init;
    RD0 = 0x2000;
    IIR_PATH1_HD = RD0;
    RD0 = 0x9f23;
    IIR_PATH1_HD = RD0;
    RD0 = 0x9f23;
    IIR_PATH1_HD = RD0;
    RD0 = 0x2000;
    IIR_PATH1_HD = RD0;
    RD0 = 0;
    IIR_PATH1_HD = RD0;
    RD0 = 0x5bba;
    IIR_PATH1_HD = RD0;
    RD0 = 0xd7d7;
    IIR_PATH1_HD = RD0;
    RD0 = 0x1c19;
    IIR_PATH1_HD = RD0;
    RD0 = 0;
    IIR_PATH1_HD = RD0;
    RD0 = 0x0431;      //此处为系数对应的配置
    IIR_PATH1_HD = RD0;

    RD0 = 0x2000;
    IIR_PATH1_HD = RD0;
    RD0 = 0xbf8c;
    IIR_PATH1_HD = RD0;
    RD0 = 0x2000;
    IIR_PATH1_HD = RD0;
    RD0 = 0;
    IIR_PATH1_HD = RD0;
    RD0 = 0;
    IIR_PATH1_HD = RD0;
    RD0 = 0x3f44;
    IIR_PATH1_HD = RD0;
    RD0 = 0x9f98;
    IIR_PATH1_HD = RD0;
    RD0 = 0;
    IIR_PATH1_HD = RD0;
    RD0 = 0;
    IIR_PATH1_HD = RD0;
    RD0 = 0x0431;
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
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    IIR_PATH1_HD = RD0;
    //寄存器地址复位
    IIR_PATH1_CLRADDR;
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      IIR1_SetHD_100DB
//  功能:
//      初始化用于1/32抽点的低通滤波器，初始化IIR_PATH1，？？？？？
//  参数:
//      无？？？？
//  返回值:
//      无
//  注释:
//      通带 F_SAMPLE / 8 (1/4带滤波器）
//      Set_IIRSftL2XY;
//          AB系数中最大的一个（A2B2)除以2存放，在系数幅度大于4时启用。
//      Set_IIRSftR2X;
//          增益除以4,在增益大于256时启用。
//      数据格式:符号位（BIT15) + 绝对值（BIT14-BIT0)
//      A系数（序号5 6 7 8）符号位取反
//      阻带100DB, 带内0.1DB, 过度带（+-）205/48K, 增益 1/G0 = 1986
//      IIR系数
//      // IIR0
//      2000, 1A77, 2CBE, 1A77, 2000      //B系数都是正，符号位+绝对值没有变化
//      2000, E035, 717D, BDF2,  D2B          //A系数有正负
//      //    6035, F17D, 3DF2, 8D2B      //A系数符号位取反
//
//      // IIR1
//      2000, CAB7, 6B46, CAB7, 2000
//      2000, DCD9, 7A50, CFC7, 178C
//      //    5CD9, FA50, 4FC7, 978C,     //A系数符号位取反
//
//      // IIR2
//      2000, D785, 7BD5, D785, 2000
//      2000, DB51, 7EFB, D83A, 1DDD
//      //    5B51, FEFB, 583A, 9DDD,     //A系数符号位取反
//      // IIR3
//      2000, ACB0, 2000, 0, 0
//      2000, ADA3, 1FD1, 0, 0
//      //    2DA3, 9FD1, 0, 0,     //A系数符号位取反
////////////////////////////////////////////////////////
Sub_AutoField IIR1_SetHD_100DB;
//// IIR0
//2000, 1A77, 2CBE, 1A77, 2000
////    6035, F17D, 3DF2, 8D2B
    RD0 = 0x2000;
    DAC_IIR1_HD = RD0;
    RD0 = 0x1A77;
    DAC_IIR1_HD = RD0;
    RD0 = 0x2CBE;
    DAC_IIR1_HD = RD0;
    RD0 = 0x1A77;
    DAC_IIR1_HD = RD0;
    RD0 = 0x2000;
    DAC_IIR1_HD = RD0;
    RD0 = 0x6035;
    
    DAC_IIR1_HD = RD0;
    RD0 = 0xF17D;
    DAC_IIR1_HD = RD0;
    RD0 = 0x3DF2;
    DAC_IIR1_HD = RD0;
    RD0 = 0x8D2B;
    DAC_IIR1_HD = RD0;
    DAC_IIR1_HD = RD0; //空写一个
//// IIR1
//2000, CAB7, 6B46, CAB7, 2000
////    5CD9, FA50, 4FC7, 978C,     //A系数符号位取反
    RD0 = 0x2000;
    DAC_IIR1_HD = RD0;
    RD0 = 0xCAB7;
    DAC_IIR1_HD = RD0;
    RD0 = 0x6B46;
    DAC_IIR1_HD = RD0;
    RD0 = 0xCAB7;
    DAC_IIR1_HD = RD0;
    RD0 = 0x2000;
    DAC_IIR1_HD = RD0;
    RD0 = 0x5CD9;
    DAC_IIR1_HD = RD0;
    RD0 = 0xFA50;
    DAC_IIR1_HD = RD0;
    RD0 = 0x4FC7;
    DAC_IIR1_HD = RD0;
    RD0 = 0x978C;
    DAC_IIR1_HD = RD0;
    DAC_IIR1_HD = RD0; //空写一个
//// IIR2
//2000, D785, 7BD5, D785, 2000
////    5B51, FEFB, 583A, 9DDD,     //A系数符号位取反
    RD0 = 0x2000;
    DAC_IIR1_HD = RD0;
    RD0 = 0xD785;
    DAC_IIR1_HD = RD0;
    RD0 = 0x7BD5;
    DAC_IIR1_HD = RD0;
    RD0 = 0xD785;
    DAC_IIR1_HD = RD0;
    RD0 = 0x2000;
    DAC_IIR1_HD = RD0;
    RD0 = 0x5B51;
    DAC_IIR1_HD = RD0;
    RD0 = 0xFEFB;
    DAC_IIR1_HD = RD0;
    RD0 = 0x583A;
    DAC_IIR1_HD = RD0;
    RD0 = 0x9DDD;
    DAC_IIR1_HD = RD0;
    DAC_IIR1_HD = RD0; //空写一个
//// IIR3
//2000, ACB0, 2000, 0, 0
////    2DA3, 9FD1, 0, 0,     //A系数符号位取反
    RD0 = 0x2000;
    DAC_IIR1_HD = RD0;
    RD0 = 0xACB0;
    DAC_IIR1_HD = RD0;
    RD0 = 0x2000;
    DAC_IIR1_HD = RD0;
    RD0 = 0x0;
    DAC_IIR1_HD = RD0;
    RD0 = 0x0;
    DAC_IIR1_HD = RD0;
    RD0 = 0x2DA3;
    DAC_IIR1_HD = RD0;
    RD0 = 0x9FD1;
    DAC_IIR1_HD = RD0;
    RD0 = 0x0;
    DAC_IIR1_HD = RD0;
    RD0 = 0x0;
    DAC_IIR1_HD = RD0;
    DAC_IIR1_HD = RD0; //空写一个
    Return_AutoField(0*MMU_BASE);

////////////////////////////////////////////////////////
//  名称:
//      IIR1_SetHD_80DB
//  功能:
//      初始化用于1/4抽点的低通滤波器
//  注释:
//      通带 F_SAMPLE / 8 (1/4带滤波器）
// 		无过冲1/4带IIR滤波器,量化后rpc=0.3dB,rsc=-75db,
//                           delta=200Hz,G1_receip=1952
//      freqsample = 48000, fp = 5800, fs = 6000
////////////////////////////////////////////////////////
Sub_AutoField IIR1_SetHD_85DB;
	RD0 = 0x2000;
	DAC_IIR1_HD = RD0;
	RD0 = 0x24A7;
	DAC_IIR1_HD = RD0;
	RD0 = 0x1253;
	DAC_IIR1_HD = RD0;
	RD0 = 0x2000;
	DAC_IIR1_HD = RD0;
	RD0 = 0x0000;
	DAC_IIR1_HD = RD0;
	RD0 = 0x48FF;
	DAC_IIR1_HD = RD0;
	RD0 = 0x9CD2;
	DAC_IIR1_HD = RD0;
	RD0 = 0x0FB4;
	DAC_IIR1_HD = RD0;
	RD0 = 0x8000;
	DAC_IIR1_HD = RD0;
	DAC_IIR1_HD = RD0;
	
	RD0 = 0x2000;
	DAC_IIR1_HD = RD0;
	RD0 = 0xC49D;
	DAC_IIR1_HD = RD0;
	RD0 = 0x31F6;
	DAC_IIR1_HD = RD0;
	RD0 = 0xC49D;
	DAC_IIR1_HD = RD0;
	RD0 = 0x2000;
	DAC_IIR1_HD = RD0;
	RD0 = 0x5EE8;
	DAC_IIR1_HD = RD0;
	RD0 = 0xBD4A;
	DAC_IIR1_HD = RD0;
	RD0 = 0x4D78;
	DAC_IIR1_HD = RD0;
	RD0 = 0x9536;
	DAC_IIR1_HD = RD0;
	DAC_IIR1_HD = RD0;
	
	RD0 = 0x2000;
	DAC_IIR1_HD = RD0;
	RD0 = 0xD842;
	DAC_IIR1_HD = RD0;
	RD0 = 0x3E6B;
	DAC_IIR1_HD = RD0;
	RD0 = 0xD842;
	DAC_IIR1_HD = RD0;
	RD0 = 0x2000;
	DAC_IIR1_HD = RD0;
	RD0 = 0x5D5F;
	DAC_IIR1_HD = RD0;
	RD0 = 0xC08F;
	DAC_IIR1_HD = RD0;
	RD0 = 0x5902;
	DAC_IIR1_HD = RD0;
	RD0 = 0x9D11;
	DAC_IIR1_HD = RD0;
	DAC_IIR1_HD = RD0;
	
	RD0 = 0x2000;
	DAC_IIR1_HD = RD0;
	RD0 = 0xAD70;
	DAC_IIR1_HD = RD0;
	RD0 = 0x1000;
	DAC_IIR1_HD = RD0;
	RD0 = 0x0000;
	DAC_IIR1_HD = RD0;
	RD0 = 0x0000;
	DAC_IIR1_HD = RD0;
	RD0 = 0x8000;
	DAC_IIR1_HD = RD0;
	RD0 = 0x8000;
	DAC_IIR1_HD = RD0;
	RD0 = 0x8000;
	DAC_IIR1_HD = RD0;
	RD0 = 0x8000;
	DAC_IIR1_HD = RD0;
	DAC_IIR1_HD = RD0;
    Return_AutoField(0*MMU_BASE);


////////////////////////////////////////////////////////
//  名称:
//      IIR1_SetHD_75DB
//  功能:
//      初始化用于1/4抽点的低通滤波器
//  注释:
//      通带 F_SAMPLE / 8 (1/4带滤波器）
// 		无过冲1/4带IIR滤波器,量化后rpc=0.3dB,rsc=-75db,
//                           delta=200Hz,G1_receip=1131
//      freqsample = 48000, fp = 5800, fs = 6000
////////////////////////////////////////////////////////

Sub_AutoField IIR1_SetHD_75DB;
	RD0 = 0x2000;
	DAC_IIR1_HD = RD0;
	RD0 = 0x223B;
	DAC_IIR1_HD = RD0;
	RD0 = 0x223B;
	DAC_IIR1_HD = RD0;
	RD0 = 0x2000;
	DAC_IIR1_HD = RD0;
	RD0 = 0x0000;
	DAC_IIR1_HD = RD0;
	RD0 = 0x4789;
	DAC_IIR1_HD = RD0;
	RD0 = 0xB7B6;
	DAC_IIR1_HD = RD0;
	RD0 = 0x0F0B;
	DAC_IIR1_HD = RD0;
	RD0 = 0x8000;
	DAC_IIR1_HD = RD0;
	DAC_IIR1_HD = RD0;
	
	RD0 = 0x2000;
	DAC_IIR1_HD = RD0;
	RD0 = 0xC657;
	DAC_IIR1_HD = RD0;
	RD0 = 0x65EB;
	DAC_IIR1_HD = RD0;
	RD0 = 0xC657;
	DAC_IIR1_HD = RD0;
	RD0 = 0x2000;
	DAC_IIR1_HD = RD0;
	RD0 = 0x5D6C;
	DAC_IIR1_HD = RD0;
	RD0 = 0xF8A9;
	DAC_IIR1_HD = RD0;
	RD0 = 0x4CA1;
	DAC_IIR1_HD = RD0;
	RD0 = 0x956A;
	DAC_IIR1_HD = RD0;
	DAC_IIR1_HD = RD0;
	
	RD0 = 0x2000;
	DAC_IIR1_HD = RD0;
	RD0 = 0xD837;
	DAC_IIR1_HD = RD0;
	RD0 = 0x7CC9;
	DAC_IIR1_HD = RD0;
	RD0 = 0xD837;
	DAC_IIR1_HD = RD0;
	RD0 = 0x2000;
	DAC_IIR1_HD = RD0;
	RD0 = 0x5C49;
	DAC_IIR1_HD = RD0;
	RD0 = 0xFFE1;
	DAC_IIR1_HD = RD0;
	RD0 = 0x5875;
	DAC_IIR1_HD = RD0;
	RD0 = 0x9D64;
	DAC_IIR1_HD = RD0;
	DAC_IIR1_HD = RD0;
	
	RD0 = 0x2000;
	DAC_IIR1_HD = RD0;
	RD0 = 0xAD3D;
	DAC_IIR1_HD = RD0;
	RD0 = 0x2000;
	DAC_IIR1_HD = RD0;
	RD0 = 0x0000;
	DAC_IIR1_HD = RD0;
	RD0 = 0x0000;
	DAC_IIR1_HD = RD0;
	RD0 = 0x8000;
	DAC_IIR1_HD = RD0;
	RD0 = 0x8000;
	DAC_IIR1_HD = RD0;
	RD0 = 0x8000;
	DAC_IIR1_HD = RD0;
	RD0 = 0x8000;
	DAC_IIR1_HD = RD0;
    DAC_IIR1_HD = RD0; //空写一个
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      IIR_PATH3_HPInit_HP
//  功能:
//      设置高通滤波器系数
//  参数:
//      1.RD0：系数缓存地址
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField IIR_PATH3_HPInit_HP;
    RA0 = RD0;
    RD2 = RN_GD25_HP_LEN/MMU_BASE;
    IIR_PATH3_CLRADDR;
L_IIR_PATH3_HPInit_HP_Loop:
    RD0 = M[RA0++];
    IIR_PATH3_HD = RD0;
    RD2 --;
    if(RQ_nZero) goto L_IIR_PATH3_HPInit_HP_Loop;
    IIR_PATH3_CLRADDR;
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      IIR_PATH3_HPInit_HP2
//  功能:
//      设置高通滤波器系数
//  参数:
//      无？？？
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField IIR_PATH3_HPInit_HP2;
// hp2_cheb1_20_800_0.2_40
#define b11         0x2000
#define b12         0xc000
#define b13         0x2000
#define b14         0x0000
#define b15         0x0000
#define a12         0x3789
#define a13         0x98bb
#define a14         0x0000
#define a15         0x0000
#define c0          0x0000
    //增加一段做增益调节，增益*4
    //RD0 = 0x7fff;
RD0 = 25558;
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
    RD0 = 0x0079;
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

    //以下填入滤波器系数
    RD0 = b11;
    IIR_PATH3_HD = RD0;
    RD0 = b12;
    IIR_PATH3_HD = RD0;
    RD0 = b13;
    IIR_PATH3_HD = RD0;
    RD0 = b14;
    IIR_PATH3_HD = RD0;
    RD0 = b15;
    IIR_PATH3_HD = RD0;
    RD0 = a12;
    IIR_PATH3_HD = RD0;
    RD0 = a13;
    IIR_PATH3_HD = RD0;
    RD0 = a14;
    IIR_PATH3_HD = RD0;
    RD0 = a15;
    IIR_PATH3_HD = RD0;
    RD0 = c0;
    IIR_PATH3_HD = RD0;

    IIR_PATH3_CLRADDR;

#undef b11
#undef b12
#undef b13
#undef b14
#undef b15
#undef a12
#undef a13
#undef a14
#undef a15
#undef c0
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      IIR_PATH3_HP340Init
//  功能:
//      设置高通滤波器系数
//  参数:
//      无？？？
//  返回值:
//      无
//  注释:
//      原系数:
//      b11 = 8192      -24547       24547       -8192        0
//      a11 = 8192      -22608       20859       -6424        0
//      硬件格式:
//      b11 = 0x2000      0xdfe3     0x5fe3      0xa000       0
//      a11 =             0x5850     0xd17b      0x1918       0
//      切比雪夫
//      b11 = 0x2000      0xe000     0x6000      0xa000       0
//      a11 =             0x581b     0xd110      0x18e5       0
////////////////////////////////////////////////////////
Sub_AutoField IIR_PATH3_HP340Init;
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
    RD0 = 0x0079;
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

    //增加一段做增益调节，增益*4
    RD0 = 0x2000;
    IIR_PATH3_HD = RD0;
    RD0 = 0xe000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x6000;
    IIR_PATH3_HD = RD0;
    RD0 = 0xa000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0x581b;
    IIR_PATH3_HD = RD0;
    RD0 = 0xd110;
    IIR_PATH3_HD = RD0;
    RD0 = 0x18e5;
    IIR_PATH3_HD = RD0;
    RD0 = 0x0000;
    IIR_PATH3_HD = RD0;
    RD0 = 0;      //此处为系数对应的配置
    IIR_PATH3_HD = RD0;

    IIR_PATH3_CLRADDR;
    Return_AutoField(0*MMU_BASE);


////////////////////////////////////////////////////////
//  名称:
//      IIR1_HalfBand_80DB
//  功能:
//      半带滤波器，用于倍增采样率插0值后重建信号
//G1_recip = 246
//b11 =   8192       21452       21452        8192
//a11 =   8192       -9393        4696        -916
//b21 =   8192       12205       20507       12205        8192
//a21 =   8192       -7026       11001       -4266        2712
//b31 =   8192        3354       16695        3354        8192
//a31 =   8192       -2672       14489       -2356        6209
//b41 =   8192         750        8192
//a41 =   8192        -777        7988
//////////////////////////////////////////////////////////
Sub_AutoField IIR_PATH3_HalfBand_Init;
#define b11         0x2000
#define b12         0x53CC
#define b13         0x53CC
#define b14         0x2000
#define b15         0x0000
#define a12         0x24B1
#define a13         0x9258
#define a14         0x0394
#define a15         0x0000
//---------------------------
#define b21         0x2000
#define b22         0x2FAD
#define b23         0x505A
#define b24         0x2FAD
#define b25         0x2000
#define a22         0x1B72
#define a23         0xAAF9
#define a24         0x10AA
#define a25         0x8AA1
//---------------------------
#define b31         0x2000
#define b32         0x0D1A
#define b33         0x4137
#define b34         0x0D1A
#define b35         0x2000
#define a32         0x0A70
#define a33         0xB899
#define a34         0x0934
#define a35         0x9841
//---------------------------
#define b41         0x2000
#define b42         0x02EE
#define b43         0x2000
#define b44         0x0000
#define b45         0x0000
#define a42         0x0309
#define a43         0x9F34
#define a44         0x0000
#define a45         0x0000
//---------------------------
#define c00         0x0021

	RD0 = b11;    IIR_PATH3_HD = RD0;
	RD0 = b12;    IIR_PATH3_HD = RD0;
	RD0 = b13;    IIR_PATH3_HD = RD0;
	RD0 = b14;    IIR_PATH3_HD = RD0;
	RD0 = b15;    IIR_PATH3_HD = RD0;
	RD0 = a12;    IIR_PATH3_HD = RD0;
	RD0 = a13;    IIR_PATH3_HD = RD0;
	RD0 = a14;    IIR_PATH3_HD = RD0;
	RD0 = a15;    IIR_PATH3_HD = RD0;
	RD0 = c00;    IIR_PATH3_HD = RD0;
	RD0 = b21;    IIR_PATH3_HD = RD0;
	RD0 = b22;    IIR_PATH3_HD = RD0;
	RD0 = b23;    IIR_PATH3_HD = RD0;
	RD0 = b24;    IIR_PATH3_HD = RD0;
	RD0 = b25;    IIR_PATH3_HD = RD0;
	RD0 = a22;    IIR_PATH3_HD = RD0;
	RD0 = a23;    IIR_PATH3_HD = RD0;
	RD0 = a24;    IIR_PATH3_HD = RD0;
	RD0 = a25;    IIR_PATH3_HD = RD0;
	RD0 = c00;    IIR_PATH3_HD = RD0;
	RD0 = b31;    IIR_PATH3_HD = RD0;
	RD0 = b32;    IIR_PATH3_HD = RD0;
	RD0 = b33;    IIR_PATH3_HD = RD0;
	RD0 = b34;    IIR_PATH3_HD = RD0;
	RD0 = b35;    IIR_PATH3_HD = RD0;
	RD0 = a32;    IIR_PATH3_HD = RD0;
	RD0 = a33;    IIR_PATH3_HD = RD0;
	RD0 = a34;    IIR_PATH3_HD = RD0;
	RD0 = a35;    IIR_PATH3_HD = RD0;
	RD0 = c00;    IIR_PATH3_HD = RD0;
	RD0 = b41;    IIR_PATH3_HD = RD0;
	RD0 = b42;    IIR_PATH3_HD = RD0;
	RD0 = b43;    IIR_PATH3_HD = RD0;
	RD0 = b44;    IIR_PATH3_HD = RD0;
	RD0 = b45;    IIR_PATH3_HD = RD0;
	RD0 = a42;    IIR_PATH3_HD = RD0;
	RD0 = a43;    IIR_PATH3_HD = RD0;
	RD0 = a44;    IIR_PATH3_HD = RD0;
	RD0 = a45;    IIR_PATH3_HD = RD0;
	RD0 = c00;    IIR_PATH3_HD = RD0;
    IIR_PATH3_CLRADDR;

#undef b11
#undef b12
#undef b13
#undef b14
#undef b15
#undef a12
#undef a13
#undef a14
#undef a15
#undef b21
#undef b22
#undef b23
#undef b24
#undef b25
#undef a22
#undef a23
#undef a24
#undef a25
#undef b31
#undef b32
#undef b33
#undef b34
#undef b35
#undef a32
#undef a33
#undef a34
#undef a35
#undef b41
#undef b42
#undef b43
#undef b44
#undef b45
#undef a42
#undef a43
#undef a44
#undef a45
#undef c00

    Return_AutoField(0*MMU_BASE);



//===============================
//功能：配置IIR滤波器系数
//入口：无
//出口：无
//G1_Reiceip = 1787
//b11 =
//        8192        -409        -409        8192
//a11 =
//        8192      -19712       15986       -4365
//b21 =
//        8192      -27570       39554      -27570        8192
//a21 =
//        8192      -29109       40069      -25232        6149
//===============================
Sub_AutoField _IIRAD_SetHD_8TH70DB;
    RD0 = 0x2000;
    ADC_FiltHD = RD0;
    RD0 = 0x8199;
    ADC_FiltHD = RD0;
    RD0 = 0x80CC;
    ADC_FiltHD = RD0;
    RD0 = 0x2000;
    ADC_FiltHD = RD0;
    RD0 = 0x0000;
    ADC_FiltHD = RD0;
    RD0 = 0x4D00;
    ADC_FiltHD = RD0;
    RD0 = 0x9F39;
    ADC_FiltHD = RD0;
    RD0 = 0x110D;
    ADC_FiltHD = RD0;
    RD0 = 0x0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0; //空写一个
    RD0 = 0x2000;
    ADC_FiltHD = RD0;
    RD0 = 0xEBB2;
    ADC_FiltHD = RD0;
    RD0 = 0x4D41;
    ADC_FiltHD = RD0;
    RD0 = 0xEBB2;
    ADC_FiltHD = RD0;
    RD0 = 0x2000;
    ADC_FiltHD = RD0;
    RD0 = 0x71B5;
    ADC_FiltHD = RD0;
    RD0 = 0xCE42;
    ADC_FiltHD = RD0;
    RD0 = 0x6290;
    ADC_FiltHD = RD0;
    RD0 = 0x9805;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0; //空写一个

    RD0 = 0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0; //空写一个

    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0; //空写一个
    Return_AutoField(0*MMU_BASE);



//===============================
//功能：配置IIR滤波器系数
//入口：无
//出口：无
// 通带 F_SAMPLE / 16 (1/8带滤波器），G1_recip = 1757
// 无过冲1/4带IIR滤波器,量化后rpc=0.056dB,rsc=-81.0dB,delta=600Hz,rsc_6000=24dB
//IIR系数
//b11 =
//        0x2000  0x84dc  0x826e*  0x2000  0x0000
//a11 =
//                0x4b37  0x9de3*  0x100a  0x0000
//b21 =
//        0x2000  0xedbd  0x4f01*  0xedbd  0x2000
//a21 =
//                0x70ee  0xcd96*  0x61ee  0x980b
//===============================
Sub_AutoField _IIRAD_SetHD_8TH60DB;
    RD0 = 0x2000;
    ADC_FiltHD = RD0;
    RD0 = 0x84dc;
    ADC_FiltHD = RD0;
    RD0 = 0x826e;
    ADC_FiltHD = RD0;
    RD0 = 0x2000;
    ADC_FiltHD = RD0;
    RD0 = 0;
    ADC_FiltHD = RD0;
    RD0 = 0x4b37;
    ADC_FiltHD = RD0;
    RD0 = 0x9de3;
    ADC_FiltHD = RD0;
    RD0 = 0x100a;
    ADC_FiltHD = RD0;
    RD0 = 0x0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0; //空写一个

    RD0 = 0x2000;
    ADC_FiltHD = RD0;
    RD0 = 0xedbd;
    ADC_FiltHD = RD0;
    RD0 = 0x4f01;
    ADC_FiltHD = RD0;
    RD0 = 0xedbd;
    ADC_FiltHD = RD0;
    RD0 = 0x2000;
    ADC_FiltHD = RD0;
    RD0 = 0x70ee;
    ADC_FiltHD = RD0;
    RD0 = 0xcd96;
    ADC_FiltHD = RD0;
    RD0 = 0x61ee;
    ADC_FiltHD = RD0;
    RD0 = 0x980b;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0; //空写一个

    RD0 = 0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0; //空写一个

    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0;
    ADC_FiltHD = RD0; //空写一个
    Return_AutoField(0*MMU_BASE);


//===============================



//===============================
//功能：配置ADC的6-16转换表
//入口：RD0，表首地址(输出很难超过30000)
//出口：无
//330G表，右移1b
//===============================
/*Sub_AutoField _ADC_Table_Init128;
    RA0 = RD0;  //源地址
    RD0 = RN_ADDR_ADC_TABLE;
    RA1 = RD0;  //表地址

    //核心表，16 X 16bit
    RD2 = 8;
L_ADTable_Init128_L0:
    RD0 = M[RA0];
    RF_EXT10(RD0);
    RA0++;
    M[RA1] = RD0;
    RF_RotateR16(RD0);
    M[RA1+2] = RD0;
    RA1 += MMU_BASE;
    RD2 --;
    if(RQ_nZero) goto L_ADTable_Init128_L0;
    	
    //其他6个溢出值表
    RD0 = RN_ADDR_ADC_TABLE;
	RD0_SetBit5;
    RA1 = RD0;
    RD0 = 0;
    RD0_SetBit6;
    
    RD1 = M[RA0];
    RF_EXT10(RD1);
    RA0 ++;
    M[RA1+RD0] = RD1;
    RF_ShiftL1(RD0);
    RF_RotateR16(RD1);
    M[RA1+RD0] = RD1;
    RF_ShiftL1(RD0);
    
    RD1 = M[RA0];
    RF_EXT10(RD1);
    RA0 ++;
    M[RA1+RD0] = RD1;
    RF_ShiftL1(RD0);
    RF_RotateR16(RD1);
    M[RA1+RD0] = RD1;
    RF_ShiftL1(RD0);
    
    RD1 = M[RA0];
    RF_EXT10(RD1);
    RA0 ++;
    M[RA1+RD0] = RD1;
    RF_ShiftL1(RD0);
    RF_RotateR16(RD1);
    M[RA1+RD0] = RD1;
    RF_ShiftL1(RD0);
    
    //增加一个抽头保持对称
    RD1 = M[RA0];
    RF_EXT10(RD1);
    M[RA1+RD0] = RD1;
    Return_AutoField(0*MMU_BASE);
*/



/*2*/
//===============================
//功能：配置ADC的6-16转换表
//2_table  16383
//入口：无
//出口：无
//===============================
Sub_AutoField _ADC_Table_Init128;//写立即数:(ADC Table)
    RD0 = RN_ADDR_ADC_TABLE;
    RA1 = RD0;  //表地址
//2021/11/8 14:12:46
//增加256直流偏移

    //核心表，16 X 16bit	
    RD0 = -3840;	RD0+=256;		M[RA1] = RD0;//N0
    RD0 = -3328;	RD0+=256;			M[RA1+2] = RD0;//N1
    				RA1 += MMU_BASE;
    RD0 = -2816;	RD0+=256;			M[RA1] = RD0;//N2
    RD0 = -2304;	RD0+=256;			M[RA1+2] = RD0;//N3
    				RA1 += MMU_BASE;    
    RD0 = -1792;	RD0+=256;			M[RA1] = RD0;//N4
    RD0 = -1280;	RD0+=256;			M[RA1+2] = RD0;//N5
    				RA1 += MMU_BASE;
    RD0 = -768;		RD0+=256;			M[RA1] = RD0;//N6
    RD0 = -256;		RD0+=256;			M[RA1+2] = RD0;//N7
    				RA1 += MMU_BASE;        
    RD0 = 256;		RD0+=256;			M[RA1] = RD0;//N8
    RD0 = 768;		RD0+=256;			M[RA1+2] = RD0;//N9
    				RA1 += MMU_BASE;
    RD0 = 1280;		RD0+=256;			M[RA1] = RD0;//N10
    RD0 = 1792;		RD0+=256;			M[RA1+2] = RD0;//N11
    				RA1 += MMU_BASE;    
    RD0 = 2304;		RD0+=256;			M[RA1] = RD0;//N12
    RD0 = 2816;		RD0+=256;			M[RA1+2] = RD0;//N13
    				RA1 += MMU_BASE;
    RD0 = 3328;		RD0+=256;			M[RA1] = RD0;//N14
    RD0 = 3840;		RD0+=256;			M[RA1+2] = RD0;//N15
    				RA1 += MMU_BASE;     

    	
    //其他6个溢出值表
    RD0 = RN_ADDR_ADC_TABLE;
		RD0_SetBit5;
    RA1 = RD0;
    RD0 = 0;
    RD0_SetBit6;
    
    RD1 = -16384;		RD1+=256;		M[RA1+RD0] = RD1;//Sel_L2
    RF_ShiftL1(RD0);
    RD1 = -8448;		RD1+=256;		M[RA1+RD0] = RD1;//Sel_L1
    RF_ShiftL1(RD0);

    RD1 = -6400;		RD1+=256;		M[RA1+RD0] = RD1;//Sel_L0
    RF_ShiftL1(RD0);
    RD1 = 6400;			RD1+=256;		M[RA1+RD0] = RD1;//Sel_H0
    RF_ShiftL1(RD0);
    
    RD1 = 8448;			RD1+=256;		M[RA1+RD0] = RD1;//Sel_H1
    RF_ShiftL1(RD0);

    RD1 = 16383;		RD1+=256;		M[RA1+RD0] = RD1;//Sel_H2
    RF_ShiftL1(RD0);
    
    //增加一个抽头保持对称

    RD1 = -4352;		RD1+=256;		M[RA1+RD0] = RD1;//Sel_N1
    Return_AutoField(0*MMU_BASE);
/*2*/



//===============================
//功能：配置ADC的6-16转换表
//4_table
//入口：无
//出口：无
//===============================
/*4//Sub_AutoField _ADC_Table_Init128;//写立即数:(ADC Table)
    RA0 = RD0;  //源地址
    RD0 = RN_ADDR_ADC_TABLE;
    RA1 = RD0;  //表地址

    //核心表，16 X 16bit	
    RD0 = -5760;		M[RA1] = RD0;//N0
    RD0 = -4992;		M[RA1+2] = RD0;//N1
    				RA1 += MMU_BASE;
    RD0 = -4224;		M[RA1] = RD0;//N2
    RD0 = -3456;		M[RA1+2] = RD0;//N3
    				RA1 += MMU_BASE;    
    RD0 = -2688;		M[RA1] = RD0;//N4
    RD0 = -1920;		M[RA1+2] = RD0;//N5
    				RA1 += MMU_BASE;
    RD0 = -1152;			M[RA1] = RD0;//N6
    RD0 = -384;			M[RA1+2] = RD0;//N7
    				RA1 += MMU_BASE;        
    RD0 = 384;			M[RA1] = RD0;//N8
    RD0 = 1152;			M[RA1+2] = RD0;//N9
    				RA1 += MMU_BASE;
    RD0 = 1920;			M[RA1] = RD0;//N10
    RD0 = 2688;			M[RA1+2] = RD0;//N11
    				RA1 += MMU_BASE;    
    RD0 = 3456;			M[RA1] = RD0;//N12
    RD0 = 4224;			M[RA1+2] = RD0;//N13
    				RA1 += MMU_BASE;
    RD0 = 4992;			M[RA1] = RD0;//N14
    RD0 = 5760;			M[RA1+2] = RD0;//N15
    				RA1 += MMU_BASE;     

    	
    //其他6个溢出值表
    RD0 = RN_ADDR_ADC_TABLE;
	RD0_SetBit5;
    RA1 = RD0;
    RD0 = 0;
    RD0_SetBit6;
    
    RD1 = -16384;		M[RA1+RD0] = RD1;//Sel_L2
    RF_ShiftL1(RD0);
    RD1 = -12672;		M[RA1+RD0] = RD1;//Sel_L1
    RF_ShiftL1(RD0);

    RD1 = -9600;		M[RA1+RD0] = RD1;//Sel_L0
    RF_ShiftL1(RD0);
    RD1 = 9600;		M[RA1+RD0] = RD1;//Sel_H0
    RF_ShiftL1(RD0);
    
    RD1 = 12672;		M[RA1+RD0] = RD1;//Sel_H1
    RF_ShiftL1(RD0);

    RD1 = 16383;		M[RA1+RD0] = RD1;//Sel_H2
    RF_ShiftL1(RD0);
    
    //增加一个抽头保持对称

    RD1 = -6528;		M[RA1+RD0] = RD1;//Sel_N1
    Return_AutoField(0*MMU_BASE);
4*/




//==================================================
Sub_AutoField _ADC_INIT_OS128;
    //模拟域设置
    RD2 = RD0;
    ADC_Enable;
    ADC_CPUCtrl_Enable;
    //配置模拟参数，RD0入口
    RD0 = RN_ADCPORT_ANAPARA;
    ADC_PortSel = RD0;
    RD0 = RD2;
    ADC_Cfg = RD0;
    //配置ADC0
    RD0 = RN_ADCPORT_ADC0CFG;
    ADC_PortSel = RD0;
    //设定转换表
    RD0 = RN_ADC_TABLE_ADDR;
    call _ADC_Table_Init128;

    //配置IIR {NULL,SEL_GAIN[3:0]}
	//RD0 = 0x29B;
	RD0 = 0x10B;
	//10B
    ADC_Cfg = RD0;
    call _IIRAD_SetHD_8TH70DB;

	//直流值标定
	RD0 = RN_ADDC_VAL;
	Volt_Vref2 = RD0;

    RD0 = 0;
    ADC_PortSel = RD0;
    ADC_CPUCtrl_Disable;
    ADC_TestView_Enable;
    Return_AutoField(0*MMU_BASE);


Sub_AutoField _ADC_INIT_ALL;
    //模拟域设置
    ADC_Enable;
    ADC_CPUCtrl_Enable;
    //配置模拟参数，RD0入口
    RD0 = RN_ADCPORT_ANAPARA;
    ADC_PortSel = RD0;
    RD0 = 0b11;
    ADC_Cfg = RD0;
    //配置ADC0
    RD0 = RN_ADCPORT_ADC0CFG+RN_ADCPORT_ADC1CFG;
    ADC_PortSel = RD0;
    //设定转换表
    RD0 = RN_ADC_TABLE_ADDR;
    call _ADC_Table_Init128;

    //配置IIR {NULL,SEL_GAIN[3:0]}
	RD0 = 0x29B;
    ADC_Cfg = RD0;
    call _IIRAD_SetHD_8TH70DB;
    
    RD0 = 0;
    ADC_PortSel = RD0;
    ADC_CPUCtrl_Disable;
    ADC_TestView_Enable;
    Return_AutoField(0*MMU_BASE);
//==================================================


//==================================================
Sub_AutoField DAC_Init;
    MemSetRAM4K_Enable;
    DAC_Enable;

//    //配置IIR1系数
//    call IIR1_SetHD_100DB;
//    //配置DAC参数
//	RD0 = 0x802240;
//    DAC_CFG = RD0;
//    MemSet_Disable;     //配置结束

    call IIR1_SetHD_85DB;
    //配置DAC参数
	RD0 = 0x802340; //1X
    DAC_CFG = RD0;
    MemSet_Disable; //配置结束

    //RAM测试
    RD0 = FlowRAM_Addr0;
    RA0 = RD0;      //Bank0地址
    RD0 = FlowRAM_Addr1;
    RA1 = RD0;      //Bank1地址

    //设置Group_PATH
    //MemSetPath_Enable;  //设置通道使能
    //M[RA0+DMA_PATH0] = RD0;//PATH0不用设置

    //设置4KRAM_PATH
    MemSetRAM4K_Enable; //使用扩展端口或RAM特殊配置时使能
    RD0 = DMA_PATH0;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //配置结束
    CPU_WorkEnable;

    //初始化Bank0，清0
    RD0 = 0;
    RD2 = 256;//0xffff;
L_InitNum_L0:
    M[RA0++] = RD0;
    RD2 --;
    if(RQ_nZero) goto L_InitNum_L0;

    //初始化Bank1，清0
    RD0 = 0;
    RD2 = 256;//0xffff;
L_InitNum_L00:
    M[RA1++] = RD0;
    RD2 --;
    if(RQ_nZero) goto L_InitNum_L00;

    //恢复RA0、RA1
    RD0 = FlowRAM_Addr0;
    RA0 = RD0;      //Bank0地址
    RD0 = FlowRAM_Addr1;
    RA1 = RD0;      //Bank1地址

    //--------------------------------------------------
    //配置Flow_RAM为DMA_Flow操作
    MemSetRAM4K_Enable;  //Set_All
    RD0 = DMA_PATH5;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable; //Set_All

    //准备进程Flow参数映像
    RD0 = 0;                //Bank偏移地址，字节
    send_para(RD0);
	RD0 = AD_Buf_Len;//4MHz
    send_para(RD0);
	RD0 = RN_CFG_FLOW_TYPE2;//Slow = 4MHz
    send_para(RD0);
    call _DMA_ParaCfg_Flow;
    nop;
	Return_AutoField(0*MMU_BASE);

//==================================================
Sub_AutoField DAC_Init2;
    MemSetRAM4K_Enable;
    DAC_Enable;

//    //配置IIR1系数
//    call IIR1_SetHD_100DB;
//    //配置DAC参数
//	RD0 = 0x802240; //1X
//    DAC_CFG = RD0;
//    MemSet_Disable;     //配置结束

    call IIR1_SetHD_85DB;
    //配置DAC参数
	RD0 = 0x802340; //1X
    DAC_CFG = RD0;
    MemSet_Disable; //配置结束

    //RAM测试
    RD0 = FlowRAM_Addr0;
    RA0 = RD0;      //Bank0地址
    RD0 = FlowRAM_Addr1;
    RA1 = RD0;      //Bank1地址

    //设置Group_PATH
    //MemSetPath_Enable;  //设置通道使能
    //M[RA0+DMA_PATH0] = RD0;//PATH0不用设置

    //设置4KRAM_PATH
    MemSetRAM4K_Enable; //使用扩展端口或RAM特殊配置时使能
    RD0 = DMA_PATH0;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //配置结束
    CPU_WorkEnable;

    //初始化Bank0，清0
    RD0 = 0;
    RD2 = 256;//0xffff;
L_InitNum2_L0:
    M[RA0++] = RD0;
    RD2 --;
    if(RQ_nZero) goto L_InitNum2_L0;

    //初始化Bank1，清0
    RD0 = 0;
    RD2 = 256;//0xffff;
L_InitNum2_L00:
    M[RA1++] = RD0;
    RD2 --;
    if(RQ_nZero) goto L_InitNum2_L00;

    //恢复RA0、RA1
    RD0 = FlowRAM_Addr0;
    RA0 = RD0;      //Bank0地址
    RD0 = FlowRAM_Addr1;
    RA1 = RD0;      //Bank1地址

    //--------------------------------------------------
    //配置Flow_RAM为DMA_Flow操作
    MemSetRAM4K_Enable;  //Set_All
    RD0 = DMA_PATH5;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable; //Set_All

    //准备进程Flow参数映像
    RD0 = 0;                //Bank偏移地址，字节
    send_para(RD0);
	RD0 = AD_Buf_Len;//4MHz
    send_para(RD0);
	RD0 = RN_CFG_FLOW_TYPE3;//Slow = 4MHz
    send_para(RD0);
    call _DMA_ParaCfg_Flow2;
    nop;
	Return_AutoField(0*MMU_BASE);

////////////////////////////////////////////////////////
//  名称:
//      I2S_Init
//  功能:
//      系统内存初始化
//  参数:
//      RD0:I2S模式配置参数（控制I2S数据来源及比特率）
//		RD1:控制I2S-Buffer步进模式及读写速率
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField I2S_Init;
//I2S主输出AD0数据
	RD2 = RD0;
	RD3 = RD1;
    //恢复RA0、RA1
    RD0 = I2SRAM_Addr0;//FlowRAM_Addr0;
    RA0 = RD0;      //Bank0地址
    RD0 = I2SRAM_Addr1;//FlowRAM_Addr1;
    RA1 = RD0;      //Bank1地址

    //--------------------------------------------------
    //配置I2S_RAM为DMA_Flow操作

    MemSetRAM4K_Enable;  //Set_All
//    Sel_MCLK;
    RD0 = DMA_PATH5;
    RD1 = 1024;
    M[RA0] = RD0;
    M[RA0+RD1] = RD0;
    M[RA1] = RD0;
    M[RA0+RD1] = RD0;
    MemSet_Disable; //Set_All

//I2S配置
	MemSetRAM4K_Enable;
	RD0 = RD2;
	I2S_CFG = RD0;
	MemSet_Disable;

	//GPIO配置
    RD0 = GP1_5+GP1_6+GP1_7;
    GPIO_WEn1 = RD0;
    RD0 = GPIO_OUT;
    GPIO_Set1 = RD0;

    //准备进程Flow参数映像
    RD0 = 0;                //Bank偏移地址，字节
    send_para(RD0);
	//RD0 = 2*AD_Buf_Len;//8MHz
	RD0 = AD_Buf_Len;//4MHz
    send_para(RD0);
	RD0 = RD3;
    send_para(RD0);
    call _DMA_ParaCfg_I2S;

    Return_AutoField(0);

END SEGMENT

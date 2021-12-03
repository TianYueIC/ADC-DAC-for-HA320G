#include <cpu11.def>
#include <resource_allocation.def>
#include <DMA_ParaCfg.def>
#include <Global.def>

#include <usi.def>


CODE SEGMENT _DMA_ParaCfg_F_;


////////////////////////////////////////////////////////
//  名称:
//      _DMA_ParaCfg_Clear
//  功能:
//      完成对Memory清0
//  参数:
//      1.M[RSP+1*MMU_BASE]：操作首地址
//      2.M[RSP+0*MMU_BASE]：TimerNum值，对应(Dword长度*1)+2
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_Clear;
    RD0 = RN_PRAM_START+DMA_ParaNum_Copy*8*MMU_BASE;
    RA0 = RD0;
    RD0 = M[RSP+1*MMU_BASE];   //X(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD0 = 0x7e000000;          //CntW is 1
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x7e000000;          //CntB is 1
    M[RA0+2*MMU_BASE] = RD0;
    RD0 = 0x08020000;//Step0
    M[RA0+3*MMU_BASE] = RD0;
    RD0 = 0x00010001;//Step1
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = M[RSP+0*MMU_BASE];
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
    Return_AutoField(2*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      _DMA_ParaCfg_Rff
//  功能:
//      为双序列操作配置DMA_Ctrl参数
//  参数:
//      1.M[RSP+3*MMU_BASE]：X(n) 首地址（字节地址）
//      2.M[RSP+2*MMU_BASE]：Y(n) 首地址
//      3.M[RSP+1*MMU_BASE]：Z(n) 首地址
//      4.M[RSP+0*MMU_BASE]：TimerNum值，对应(Dword长度*3)+4
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_Rff;
    RD0 = RN_PRAM_START+DMA_ParaNum_ALU*8*MMU_BASE;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //Y(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 --;                    //调整适应流水线
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD0 = M[RSP+3*MMU_BASE];  //X(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0_ClrByteH8;
    RD1 = 0x7a000000;          //CntW is 3
    RD0 += RD1;  //X(n)首地址
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 --;
    RD0_ClrByteH8;
    RD1 = 0x7e000000;          //CntB is 1
    RD0 += RD1;
    M[RA0+2*MMU_BASE] = RD0;
    RD0 = 0x0C020001;//Step0
    M[RA0+3*MMU_BASE] = RD0;
    RD0 = 0x06040001;//Step1
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = M[RSP+0*MMU_BASE];
//    RD0 ++;
//    RD1 = RD0;
//    RF_ShiftL1(RD0);
//    RD0 += RD1;      //Lenth * 3
//    RD0 ++;
//    send_para(RD0);
//    call _Timer_Number;
//    RF_Not(RD0);
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
    Return_AutoField(4*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      _DMA_ParaCfg_RffC
//  功能:
//      为单序列与常数操作配置DMA_Ctrl参数
//  参数:
//      1.M[RSP+2*MMU_BASE]：X(n) 首地址
//      2.M[RSP+1*MMU_BASE]：Z(n) 首地址
//      3.M[RSP+0*MMU_BASE]：TimerNum值，对应(Dword长度*2)+4
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_RffC;
    RD0 = RN_PRAM_START+DMA_ParaNum_ALU*8*MMU_BASE;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //X(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 --;
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD1 = 0x75000000;          //CntW is 3
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 -= 2;
    RD0_ClrByteH8;
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x7e000000;          //CntB is 1
    M[RA0+2*MMU_BASE] = RD0;
    RD0 = 0x0C130001;//Step0//RD0 = 0x0C020001;//Step0  Bit21 0~带Abs统计 1~不带Abs统计
    M[RA0+3*MMU_BASE] = RD0;
    RD0 = 0x02020001;//Step1
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = M[RSP+0*MMU_BASE];
//  RD0 += 2;
//  RF_ShiftL1(RD0);//Lenth * 2
//  //send_para(RD0);
//  //call _Timer_Number;
//  RF_Not(RD0);
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
    Return_AutoField(3*MMU_BASE);

////////////////////////////////////////////////////////
//  名称:
//      _DMA_ParaCfg_RffC_nAbs
//  功能:
//      为单序列与常数操作配置DMA_Ctrl参数
//  参数:
//      1.M[RSP+2*MMU_BASE]：X(n) 首地址
//      2.M[RSP+1*MMU_BASE]：Z(n) 首地址
//      3.M[RSP+0*MMU_BASE]：TimerNum值，对应(Dword长度*2)+4
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_RffC_nAbs;
    RD0 = RN_PRAM_START+DMA_ParaNum_ALU*8*MMU_BASE;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //X(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 --;
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD1 = 0x75000000;          //CntW is 3
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 -= 2;
    RD0_ClrByteH8;
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x7e000000;          //CntB is 1
    M[RA0+2*MMU_BASE] = RD0;
    RD0 = 0x0C330001;//Step0//RD0 = 0x0C020001;//Step0  Bit21 0~带Abs统计 1~不带Abs统计
    M[RA0+3*MMU_BASE] = RD0;
    RD0 = 0x02020001;//Step1
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = M[RSP+0*MMU_BASE];
//  RD0 += 2;
//  RF_ShiftL1(RD0);//Lenth * 2
//  //send_para(RD0);
//  //call _Timer_Number;
//  RF_Not(RD0);
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
    Return_AutoField(3*MMU_BASE);
    


////////////////////////////////////////////////////////
//  名称:
//      _DMA_ParaCfg_RffC_Rf
//  功能:
//      为单序列与常数操作配置DMA_Ctrl参数
//  参数:
//      1.M[RSP+3*MMU_BASE]：X(n) 首地址
//      2.M[RSP+2*MMU_BASE]：Z(n) 首地址
//      3.M[RSP+1*MMU_BASE]：TimerNum值，带统计：(Dword长度+2)*2+2 -------- 平方和
//                                             (Dword长度+2)*2+1 -------- 统计其他
//                                     不统计：(Dword长度)*2+4   -------- 单序列单目运算
//                                             (Dword长度)*3+4   -------- 双序列运算
//                                             (Dword长度)*3+3   -------- MAC FMT 双序列乘（MAC）
//      M[RSP+0*MMU_BASE]：Bit16 == 0不带统计 
//						   Bit16 == 1带统计 
//						   Bit21 == 0先行Abs 
//						   Bit21 == 1无Abs
//						   其余位按此数填写：0x0C130001;
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_RffC_Rf;
    RD0 = RN_PRAM_START+DMA_ParaNum_ALU*8*MMU_BASE;
    RA0 = RD0;
    RD0 = M[RSP+3*MMU_BASE];   //X(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 --;
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;   //CntF is 0
    RD1 = 0x75000000;          //CntW is 3
    RD0 = M[RSP+2*MMU_BASE];   //Z(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 -= 2;
    RD0_ClrByteH8;
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x7e000000;          //CntB is 1
    M[RA0+2*MMU_BASE] = RD0;
    //RD0 = 0x0C130001;//Step0//RD0 = 0x0C020001;//Step0  Bit21 0~带Abs统计 1~不带Abs统计
    RD0 = M[RSP+0*MMU_BASE];
    M[RA0+3*MMU_BASE] = RD0;
    RD0 = 0x02020001;//Step1
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = M[RSP+1*MMU_BASE];
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
    Return_AutoField(4*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      _DMA_ParaCfg_Rf
//  功能:
//      为单序列操作配置DMA_Ctrl参数
//  参数:
//      1.M[RSP+2*MMU_BASE]：X(n) 首地址
//      2.M[RSP+1*MMU_BASE]：Z(n) 首地址
//      3.M[RSP+0*MMU_BASE]：长度 (Dword为单位)
//  返回值:
//      无
//  注释：
//      仅供内部函数调用，入口借用上层函数栈，
//      返回时不弹栈
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_Rf;
    RD0 = RN_PRAM_START+DMA_ParaNum_ALU*8*MMU_BASE;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];    //X(n)首地址
    RF_ShiftR2(RD0);            //变为Dword地址
    RD0 --;
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;    //CntF is 0
    RD1 = 0x75000000;           //CntW is 3
    RD0 = M[RSP+1*MMU_BASE];    //Z(n)首地址
    RF_ShiftR2(RD0);            //变为Dword地址
    RD0 -= 2;
    RD0_ClrByteH8;
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x7e000000;           //CntB is 1
    M[RA0+2*MMU_BASE] = RD0;
    RD0 = 0x0C030001;           //Step0
    M[RA0+3*MMU_BASE] = RD0;
    RD0 = 0x02020001;//Step1
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = M[RSP+0*MMU_BASE];
    RD0 += 2;
    RF_ShiftL1(RD0);//Lenth * 2
    send_para(RD0);
    call _Timer_Number;
    RF_Not(RD0);
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
    Return_AutoField(3*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      _DMA_ParaCfg_AD_Copy
//  功能:
//      为从AD到GRAM拷贝（源地址步长为2）配置DMA_Ctrl参数
//  参数:
//      1.M[RSP+2*MMU_BASE]：X(n) 首地址
//      2.M[RSP+1*MMU_BASE]：Z(n) 首地址
//      3.M[RSP+0*MMU_BASE]：TimerNum值，对应(Dword长度*2)+4
//  返回值:
//      无
//  注释：
//      仅供内部函数调用，入口借用上层函数栈，
//      返回时不弹栈
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_AD_Copy;
    RD0 = RN_PRAM_START+DMA_ParaNum_ALU*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //X(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 -= 2;// ???????
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD1 = 0x75000000;          //CntW is 3
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 -= 2;
    RD0_ClrByteH8;
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x7e000000;          //CntB is 1
    M[RA0+2*MMU_BASE] = RD0;
    RD0 = 0x0C030002;//Step0
    M[RA0+3*MMU_BASE] = RD0;
    RD0 = 0x02020001;//Step1
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = M[RSP+0*MMU_BASE];
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
    Return_AutoField(3*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      _DMA_ParaCfg_DA_Copy
//  功能:
//      为从GRAM到DA拷贝（目标地址步长为2）配置DMA_Ctrl参数
//  参数:
//      1.M[RSP+2*MMU_BASE]：X(n) 首地址
//      2.M[RSP+1*MMU_BASE]：Z(n) 首地址
//      3.M[RSP+0*MMU_BASE]：TimerNum值，对应(Dword长度*2)+4
//  返回值:
//      无
//  注释：
//      仅供内部函数调用，入口借用上层函数栈，
//      返回时不弹栈
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_DA_Copy;
    RD0 = RN_PRAM_START+DMA_ParaNum_ALU*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //X(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 --;
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD1 = 0x75000000;          //CntW is 3
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 -= 2*2;// ????????
    RD0_ClrByteH8;
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x7e000000;          //CntB is 1
    M[RA0+2*MMU_BASE] = RD0;
    RD0 = 0x0C030001;//Step0
    M[RA0+3*MMU_BASE] = RD0;
    RD0 = 0x02020002;//Step1
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = M[RSP+0*MMU_BASE];
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
    Return_AutoField(3*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      _DMA_ParaCfg_Flow
//  功能:
//      为乘法器操作配置DMA_Ctrl参数
//  参数:
//      1.M[RSP+2*MMU_BASE]：Bank起始 地址
//      2.M[RSP+1*MMU_BASE]：Bank长度 (Dword为单位)
//      3.M[RSP+0*MMU_BASE]：时钟分频
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_Flow;
    RD0 = RN_PRAM_START+DMA_ParaNum_Flow*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+0*MMU_BASE];   //时钟分频
    M[RA0+0*MMU_BASE] = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //Bank起始地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RF_Not(RD0);               //硬件要求
    M[RA0+2*MMU_BASE] = RD0;
    //RD0 = M[RSP+1*MMU_BASE];
    //send_para(RD0);
    //call _Timer_Number;
    //RF_Not(RD0);
// MODI
RD0 = 0x70ff0001;
    M[RA0+1*MMU_BASE] = RD0;  //Loop_Num
    Return_AutoField(3*MMU_BASE);


////////////////////////////////////////////////////////
//  名称:
//      _DMA_ParaCfg_Flow2
//  功能:
//      为乘法器操作配置DMA_Ctrl参数
//  参数:
//      1.M[RSP+2*MMU_BASE]：Bank起始 地址
//      2.M[RSP+1*MMU_BASE]：Bank长度 (Dword为单位)
//      3.M[RSP+0*MMU_BASE]：时钟分频
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_Flow2;
    RD0 = RN_PRAM_START+DMA_ParaNum_Flow*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+0*MMU_BASE];   //时钟分频
    M[RA0+0*MMU_BASE] = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //Bank起始地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RF_Not(RD0);               //硬件要求
    M[RA0+2*MMU_BASE] = RD0;
    //RD0 = M[RSP+1*MMU_BASE];
    //send_para(RD0);
    //call _Timer_Number;
    //RF_Not(RD0);
// MODI
RD0 = 0x1e01fffd; //0x70ff0001;
    M[RA0+1*MMU_BASE] = RD0;  //Loop_Num
    Return_AutoField(3*MMU_BASE);

////////////////////////////////////////////////////////
//  名称:
//      _DMA_ParaCfg_I2S
//  功能:
//      为I2S接口配置DMA_Ctrl参数
//  参数:
//      1.M[RSP+2*MMU_BASE]：Bank起始 地址
//      2.M[RSP+1*MMU_BASE]：Bank长度 (Dword为单位)
//      3.M[RSP+0*MMU_BASE]：时钟分频
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_I2S;
    RD0 = RN_PRAM_START+DMA_ParaNum_I2S*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+0*MMU_BASE];   //时钟分频
    M[RA0+0*MMU_BASE] = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //Bank起始地址
    RF_ShiftR2(RD0);//           //变为Dword地址
    RF_Not(RD0);               //硬件要求
    M[RA0+2*MMU_BASE] = RD0;
    //RD0 = M[RSP+1*MMU_BASE];
    //send_para(RD0);
    //call _Timer_Number;
    //RF_Not(RD0);
// MODI
RD0 = 0x70ff0001;
    M[RA0+1*MMU_BASE] = RD0;  //Loop_Num
    Return_AutoField(3*MMU_BASE);


////////////////////////////////////////////////////////
//  名称:
//      _DMA_ParaCfg_MAC
//  功能:
//      为双序列相乘.乘累加操作配置DMA_Ctrl参数
//  参数:
//      1.M[RSP+3*MMU_BASE]：X(n) 首地址（字节地址）
//      2.M[RSP+2*MMU_BASE]：Y(n) 首地址
//      3.M[RSP+1*MMU_BASE]：Z(n) 首地址
//      4.M[RSP+0*MMU_BASE]：TimerNum值，对应(长度+1)*3 (Dword为单位)
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_MAC;
    RD0 = RN_PRAM_START+DMA_ParaNum_MAC*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //Y(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD0 = M[RSP+3*MMU_BASE];  //X(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0_ClrByteH8;
    RD1 = 0x7a000000;          //CntW is 3
    RD0 += RD1;  //X(n)首地址
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 --;
    RD0_ClrByteH8;
    RD1 = 0x7e000000;          //CntB is 1
    RD0 += RD1;
    M[RA0+2*MMU_BASE] = RD0;
    RD0 = 0x0C080001;//Step0
    M[RA0+3*MMU_BASE] = RD0;
    RD0 = 0x06040001;//Step1
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = M[RSP+0*MMU_BASE];
    //RD0 ++;
    //RD1 = RD0;
    //RF_ShiftL1(RD0);
    //RD0 += RD1;      //Lenth * 3
    //send_para(RD0);
    //call _Timer_Number;
//Debug_Reg32 = RD0;
    //RD0 = 0x855e90c5;
    //RF_Not(RD0);
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
    Return_AutoField(4*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      _DMA_IIRBANK_Analyze
//  功能:
//      为IIR滤波器组操作配置DMA_Ctrl参数，并进行子带分析
//  参数:
//      1.M[RSP+2*MMU_BASE]：XD(n) 首地址
//      2.M[RSP+1*MMU_BASE]：SQ(n) 首地址
//      3.M[RSP+0*MMU_BASE]：长度 (Dword为单位)
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _DMA_IIRBANK_Analyze;
    //G4处理
    RD0 = RN_PRAM_START+DMA_ParaNum_IIRBANK*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //X(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 -= 2;                  //流水线前两次写无效
    RD0_ClrByteH8;
    RD1 = 0x55000000;          //CntW is 6
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x55000000;          //CntB is 6
    M[RA0+2*MMU_BASE] = RD0;
    RD0 = 0x0C010001;//16Bit Step0
    M[RA0+3*MMU_BASE] = RD0;
    RD0 = 0x02400001;//Step1
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = M[RSP+0*MMU_BASE];
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH4;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_IIRBANK;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    Return_AutoField(3*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      _DMA_IIRBANK_Synthesis
//  功能:
//      为IIR滤波器组操作配置DMA_Ctrl参数，并进行子带综合
//  参数:
//      1.M[RSP+2*MMU_BASE]：XD(n) 首地址
//      2.M[RSP+1*MMU_BASE]：SQ(n) 首地址
//      3.M[RSP+0*MMU_BASE]：长度 (Dword为单位)
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _DMA_IIRBANK_Synthesis;
    //G4处理
    RD0 = RN_PRAM_START+DMA_ParaNum_IIRBANK*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //X(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 -= 2;                  //流水线前两次写无效
    RD0_ClrByteH8;
    RD1 = 0x55000000;          //CntW is 6
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x55000000;          //CntB is 6
    M[RA0+2*MMU_BASE] = RD0;
    RD0 = 0x0C020001;//16Bit Step0
    M[RA0+3*MMU_BASE] = RD0;
    RD0 = 0x02400001;//Step1
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = M[RSP+0*MMU_BASE];
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num

    //选择DMA_Ctrl通道，并启动运算
    RD0 = DMA_PATH4;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_IIRBANK;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    Return_AutoField(3*MMU_BASE);    



////////////////////////////////////////////////////////
//  名称:
//      _DMA_ParaCfg_FFT512_Revs
//  功能:
//      配置512点的FFT复数数据做地址逆序转换
//  参数:
//      1.M[RSP+1*MMU_BASE]：X(n) 首地址
//      2.M[RSP+0*MMU_BASE]：Z(n) 首地址
//  返回值:
//      无
//  注释：
//      仅供内部函数调用，入口借用上层函数栈，
//      返回时不弹栈
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_FFT512_Revs;
    RD0 = RN_PRAM_START+DMA_ParaNum_FFTRevs*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+1*MMU_BASE];   //X(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 --;
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;   //CntF is 0
    RD1 = 0x75000000;          //CntW is 3
    RD0 = M[RSP+0*MMU_BASE];   //Z(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 -= 2;
    RD0_ClrByteH8;
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x7e000000;          //CntB is 1
    M[RA0+2*MMU_BASE] = RD0;
    RD0 = 0x0C830001;//Step0   //0CC30001(1024) 0C830001(512) 0C430001(256)
    M[RA0+3*MMU_BASE] = RD0;
    RD0 = 0x02020001;//Step1
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = 512;
    RD0 += 2;
    RF_ShiftL1(RD0);//Lenth * 2
//  send_para(RD0);
//  call _Timer_Number;
//  RF_Not(RD0);
    RD0 = 0x2C53A744;
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
    Return_AutoField(2*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      _DMA_ParaCfg_FFT512
//  功能:
//      配置512点复数数据进行FFT运算，完成一个分解
//  参数:
//      1.M[RSP+2*MMU_BASE]：W(n) 首地址
//      2.M[RSP+1*MMU_BASE]：X(n) 首地址
//      3.M[RSP+0*MMU_BASE]
//  返回值:
//      无
//  注释：
//      输出在原址，覆盖原数据
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_FFT512;
    RD0 = RN_PRAM_START+DMA_ParaNum_FFT*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //X(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;   //CntF is 0
    RD1 = 0x55000000;          //CntW is 5
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0_ClrByteH8;
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x7e000000;          //CntB is 1
    M[RA0+2*MMU_BASE] = RD0;
    RD1 = 0x0C840001;//Step0   //0CC40001(1024) 0C840001(512) 0C440001(256)
    RD0 = M[RSP+0*MMU_BASE];   //0 ：上次分解计算没有满位，无需右移数据
    if(RD0_Zero) goto L_FFT512_L0;
    RD0 = 0x00080000;          //!0: 已满位，当前次分解计算需右移数据
    RD1 += RD0;
L_FFT512_L0:
    M[RA0+3*MMU_BASE] = RD1;
    RD0 = 0x07200001;//Step1   //选择Mode7 A R W A X W A R A R
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = 256*6;  //N/2次蝶形运算，每次需要4个时钟周期
    RD0 += 3;     //加补流水线
//  send_para(RD0);
//  call _Timer_Number;
//  RF_Not(RD0);
    RD0 = 0x7a7162c7;
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num    //0x0B162C0A
    Return_AutoField(3*MMU_BASE);


////////////////////////////////////////////////////////
//  函数名称:
//      _DMA_ParaCfg_FFT128_Revs
//  函数功能:
//      配置128点的FFT复数数据做地址逆序转换
//  入口参数:
//      M[RSP+1*MMU_BASE]：X(n) 首地址
//      M[RSP+0*MMU_BASE]：Z(n) 首地址
//  出口参数:
//      无
//  说明：
//      仅供内部函数调用，入口借用上层函数栈，
//      返回时不弹栈
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_FFT128_Revs;
    RD0 = RN_PRAM_START+DMA_ParaNum_FFTRevs*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+1*MMU_BASE];   //X(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 --;
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;   //CntF is 0
    RD1 = 0x75000000;          //CntW is 3
    RD0 = M[RSP+0*MMU_BASE];   //Z(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 -= 2;
    RD0_ClrByteH8;
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x7e000000;          //CntB is 1
    M[RA0+2*MMU_BASE] = RD0;
    RD0 = 0x0CC30001;//Step0   //0CC30001(128) 0C830001(64)
    M[RA0+3*MMU_BASE] = RD0;
    RD0 = 0x02020001;//Step1
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = 128;
    RD0 += 2;
    RF_ShiftL1(RD0);//Lenth * 2
//  send_para(RD0);
//  call _Timer_Number;
//  RF_Not(RD0);
    RD0 = 0x218d4ce6;
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
    Return_AutoField(2*MMU_BASE);

    
    

//////////////////////////////////////////////////////////
//  名称:
//      _DMA_ParaCfg_FFT128
//  功能:
//      配置128点复数数据进行FFT运算，完成一个分解
//  参数:
//      1.M[RSP+2*MMU_BASE]：W(n) 首地址
//      2.M[RSP+1*MMU_BASE]：X(n) 首地址
//      3.M[RSP+0*MMU_BASE]
//  返回值:
//      无
//  注释：
//      输出在原址，覆盖原数据
//////////////////////////////////////////////////////////

Sub_AutoField _DMA_ParaCfg_FFT128;
    RD0 = RN_PRAM_START+DMA_ParaNum_FFT*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //X(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;   //CntF is 0
    RD1 = 0x55000000;          //CntW is 5
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0_ClrByteH8;
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x7e000000;          //CntB is 1
    M[RA0+2*MMU_BASE] = RD0;
    RD1 = 0x0CC40001;//Step0   //0CC40001(128) 0C840001(64)
    RD0 = M[RSP+0*MMU_BASE];   //0 ：上次分解计算没有满位，无需右移数据
    if(RD0_Zero) goto L_FFT128_L0;
    RD0 = 0x00080000;          //!0: 已满位，当前次分解计算需右移数据
    RD1 += RD0;
L_FFT128_L0:
    M[RA0+3*MMU_BASE] = RD1;
    RD0 = 0x07200001;//Step1   //选择Mode7 A R W A X W A R A R
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = 64*6;  //N/2次蝶形运算，每次需要4个时钟周期
    RD0 += 3;     //加补流水线
//  send_para(RD0);
//  call _Timer_Number;
//  RF_Not(RD0);
    RD0 = 0x549f2ec6;
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num    //0x0B162C0A
    Return_AutoField(3*MMU_BASE);
    
    
    
////////////////////////////////////////////////////////
//  名称:
//      _DMA_ParaCfg_FFT64_Revs
//  功能:
//      配置64点的FFT复数数据做地址逆序转换
//  参数:
//      1.M[RSP+1*MMU_BASE]：X(n) 首地址
//      2.M[RSP+0*MMU_BASE]：Z(n) 首地址
//  返回值:
//      无
//  注释：
//      仅供内部函数调用，入口借用上层函数栈，
//      返回时不弹栈
////////////////////////////////////////////////////////

Sub_AutoField _DMA_ParaCfg_FFT64_Revs;
    RD0 = RN_PRAM_START+DMA_ParaNum_FFTRevs*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+1*MMU_BASE];   //X(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 --;
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;   //CntF is 0
    RD1 = 0x75000000;          //CntW is 3
    RD0 = M[RSP+0*MMU_BASE];   //Z(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 -= 2;
    RD0_ClrByteH8;
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x7e000000;          //CntB is 1
    M[RA0+2*MMU_BASE] = RD0;
    RD0 = 0x0C830001;//Step0   //0CC30001(64) 0C830001(64)
    M[RA0+3*MMU_BASE] = RD0;
    RD0 = 0x02020001;//Step1
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = 64;
    RD0 += 2;
    RF_ShiftL1(RD0);//Lenth * 2
//  send_para(RD0);
//  call _Timer_Number;
//  RF_Not(RD0);
    RD0 = 0x20a5f543;
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
    Return_AutoField(2*MMU_BASE);
    
    

////////////////////////////////////////////////////////
//  名称:
//      _DMA_ParaCfg_FFT64
//  功能:
//      配置64点复数数据进行FFT运算，完成一个分解
//  参数:
//      M[RSP+2*MMU_BASE]：W(n) 首地址
//      M[RSP+1*MMU_BASE]：X(n) 首地址
//      M[RSP+0*MMU_BASE]
//  返回值:
//      无
//  注释：
//      输出在原址，覆盖原数据
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_FFT64;
    RD0 = RN_PRAM_START+DMA_ParaNum_FFT*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //X(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;   //CntF is 0
    RD1 = 0x55000000;          //CntW is 5
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0_ClrByteH8;
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x7e000000;          //CntB is 1
    M[RA0+2*MMU_BASE] = RD0;
    RD1 = 0x0C840001;//Step0   //0CC40001(64) 0C840001(64)
    RD0 = M[RSP+0*MMU_BASE];   //0 ：上次分解计算没有满位，无需右移数据
    if(RD0_Zero) goto L_FFT64_L0;
    RD0 = 0x00080000;          //!0: 已满位，当前次分解计算需右移数据
    RD1 += RD0;
L_FFT64_L0:
    M[RA0+3*MMU_BASE] = RD1;
    RD0 = 0x07200001;//Step1   //选择Mode7 A R W A X W A R A R
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = 64*6;  //N/2次蝶形运算，每次需要4个时钟周期
    RD0 += 3;     //加补流水线
//  send_para(RD0);
//  call _Timer_Number;
//  RF_Not(RD0);
    RD0 = 0x7aa16f3a;
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num    //0x0B162C0A
    Return_AutoField(3*MMU_BASE);
    
    


////////////////////////////////////////////////////////
//  名称:
//      _DMA_ParaCfg_Real2Complex
//  功能:
//      实数序列整理成复数格式_虚部置0
//      注意：需两次调用，写地址步长为2
//            一次进程只完成偶数序号或奇数序号
//  参数:
//      1.M[RSP+2*MMU_BASE]：X(n) 首地址
//      2.M[RSP+1*MMU_BASE]：Z(n) 首地址
//      3.M[RSP+0*MMU_BASE]：长度 (Dword为单位)
//  返回值:
//      无
//  注释：
//      仅供内部函数调用，入口借用上层函数栈，
//      返回时不弹栈
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_Real2Complex;
    RD0 = RN_PRAM_START+DMA_ParaNum_Format*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //X(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD1 = 0x7a000000;          //CntW is 3
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 -= 2;
    RD0_ClrByteH8;
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x7e000000;          //CntB is 1
    M[RA0+2*MMU_BASE] = RD0;
    RD0 = 0x0C480001;//Step0
    M[RA0+3*MMU_BASE] = RD0;
    RD0 = 0x02020002;//Step1
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = M[RSP+0*MMU_BASE];
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
    Return_AutoField(3*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      _DMA_ParaCfg_GetH16L16
//  功能:
//      提取复数中的实部或者虚部，整理成标准序列
//  参数:
//      1.M[RSP+2*MMU_BASE]：X(n) 首地址（字节地址）
//      2.M[RSP+1*MMU_BASE]：Z(n) 首地址
//      3.M[RSP+0*MMU_BASE]：TimerNum值，对应(长度/2+1)*3 (Dword为单位)
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_GetH16L16;
    RD0 = RN_PRAM_START+DMA_ParaNum_Format*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //Y(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 -= 1;                    //调整适应流水线
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD0 ++;
    RD0_ClrByteH8;
    RD1 = 0x7a000000;          //CntW is 3
    RD0 += RD1;  //X(n)首地址
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 --;
    RD0_ClrByteH8;
    RD1 = 0x7e000000;          //CntB is 1
    RD0 += RD1;
    M[RA0+2*MMU_BASE] = RD0;
    RD0 = 0x0C080002;//Step0
    M[RA0+3*MMU_BASE] = RD0;
    RD0 = 0x06040002;//Step1
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = M[RSP+0*MMU_BASE];
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
    Return_AutoField(3*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      _DMA_ParaCfg_FiltIIR
//  功能:
//      为IIR滤波器操作配置DMA_Ctrl参数
//  参数:
//      1.M[RSP+2*MMU_BASE]：X(n) 首地址
//      2.M[RSP+1*MMU_BASE]：Z(n) 首地址
//      3.M[RSP+0*MMU_BASE]：（Dword长度*48+1）
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_FiltIIR;
    RD0 = RN_PRAM_START+DMA_ParaNum_IIR*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //X(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 -= 2;                  //流水线前两次写无效
    RD0_ClrByteH8;
    RD1 = 0x55000000;          //CntW is 6
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x55000000;          //CntB is 6
    M[RA0+2*MMU_BASE] = RD0;
    RD0 = 0x0C040001;//16Bit Step0
    M[RA0+3*MMU_BASE] = RD0;
    RD0 = 0x02400001;//Step1
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = M[RSP+0*MMU_BASE];
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
    Return_AutoField(3*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      _DMA_ParaCfg_Rff_Step2
//  功能:
//      为双序列操作配置DMA_Ctrl参数，地址步长为2Dword
//  参数:
//      1.M[RSP+3*MMU_BASE]：X(n) 首地址（字节地址）
//      2.M[RSP+2*MMU_BASE]：Y(n) 首地址
//      3.M[RSP+1*MMU_BASE]：Z(n) 首地址
//      4.M[RSP+0*MMU_BASE]：TimerNum值，对应(Dword长度*3)+4
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_Rff_Step2;
    RD0 = RN_PRAM_START+DMA_ParaNum_ALU*8*MMU_BASE;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //Y(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 -= 2;                  //调整适应流水线
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD0 = M[RSP+3*MMU_BASE];  //X(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0_ClrByteH8;
    RD1 = 0x7a000000;          //CntW is 3
    RD0 += RD1;  //X(n)首地址
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 --;
    RD0_ClrByteH8;
    RD1 = 0x7e000000;          //CntB is 1
    RD0 += RD1;
    M[RA0+2*MMU_BASE] = RD0;
    RD0 = 0x0C020002;//Step0
    M[RA0+3*MMU_BASE] = RD0;
    RD0 = 0x06040002;//Step1
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = M[RSP+0*MMU_BASE];
//    RD0 ++;
//    RD1 = RD0;
//    RF_ShiftL1(RD0);
//    RD0 += RD1;      //Lenth * 3
//    RD0 ++;
//    send_para(RD0);
//    call _Timer_Number;
//    RF_Not(RD0);
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
    Return_AutoField(4*MMU_BASE);


////////////////////////////////////////////////////////
//  名称:
//      _DMA_ParaCfg_FFT128_Write
//  功能:
//      为从GRAM到FFT128专用缓存拷贝并逆序
//     （目标地址步长为1）配置DMA_Ctrl参数
//  参数:
//      M[RSP+0*MMU_BASE]：X(n) 首地址
//  返回值:
//      无
//  注释：
//      仅供内部函数调用，入口借用上层函数栈，
//      返回时不弹栈
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_FFT128_Write;
    RD0 = RN_PRAM_START+DMA_ParaNum_FFT*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+0*MMU_BASE];   //X(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 --;
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD1 = 0x75000000;          //CntW is 3
    RD0 = FFT128RAM_Addr0;   //Z(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 -= 2;
    RD0_ClrByteH8;
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x7e000000;          //CntB is 1
    M[RA0+2*MMU_BASE] = RD0;
    RD0 = 0x0C820001;//Step0
    M[RA0+3*MMU_BASE] = RD0;
    RD0 = 0x02020001;//Step1
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = 0x218d4ce6;
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
    Return_AutoField(1*MMU_BASE);//      M[RSP+0*MMU_BASE]：TimerNum值，对应(Dword长度*2)+4



////////////////////////////////////////////////////////
//  名称:
//      _DMA_ParaCfg_FFT128_Read
//  功能:
//      为从FFT128专用缓存拷贝到GRAM
//     （目标地址步长为1）配置DMA_Ctrl参数
//  参数:
//      M[RSP+0*MMU_BASE]：Z(n) 目标地址
//  返回值:
//      无
//  注释：
//      仅供内部函数调用，入口借用上层函数栈，
//      返回时不弹栈
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_FFT128_Read;
    RD0 = RN_PRAM_START+DMA_ParaNum_FFT*MMU_BASE*8;
    RA0 = RD0;
    RD0 = FFT128RAM_Addr0;   //X(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 --;
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD1 = 0x75000000;          //CntW is 3
    RD0 = M[RSP+0*MMU_BASE];   //Z(n)首地址
    RF_ShiftR2(RD0);           //变为Dword地址
    RD0 -= 2;
    RD0_ClrByteH8;
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x7e000000;          //CntB is 1
    M[RA0+2*MMU_BASE] = RD0;
    RD0 = 0x0C020001;//Step0
    M[RA0+3*MMU_BASE] = RD0;
    RD0 = 0x02020001;//Step1
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = 0x218d4ce6;
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num
    Return_AutoField(1*MMU_BASE);//      M[RSP+0*MMU_BASE]：TimerNum值，对应(Dword长度*2)+4



END SEGMENT

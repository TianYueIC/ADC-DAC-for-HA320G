#include <cpu11.def>
#include <resource_allocation.def>
#include <DMA_ParaCfg.def>
#include <Global.def>

#include <usi.def>


CODE SEGMENT _DMA_ParaCfg_F_;


////////////////////////////////////////////////////////
//  ����:
//      _DMA_ParaCfg_Clear
//  ����:
//      ��ɶ�Memory��0
//  ����:
//      1.M[RSP+1*MMU_BASE]�������׵�ַ
//      2.M[RSP+0*MMU_BASE]��TimerNumֵ����Ӧ(Dword����*1)+2
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_Clear;
    RD0 = RN_PRAM_START+DMA_ParaNum_Copy*8*MMU_BASE;
    RA0 = RD0;
    RD0 = M[RSP+1*MMU_BASE];   //X(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
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
//  ����:
//      _DMA_ParaCfg_Rff
//  ����:
//      Ϊ˫���в�������DMA_Ctrl����
//  ����:
//      1.M[RSP+3*MMU_BASE]��X(n) �׵�ַ���ֽڵ�ַ��
//      2.M[RSP+2*MMU_BASE]��Y(n) �׵�ַ
//      3.M[RSP+1*MMU_BASE]��Z(n) �׵�ַ
//      4.M[RSP+0*MMU_BASE]��TimerNumֵ����Ӧ(Dword����*3)+4
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_Rff;
    RD0 = RN_PRAM_START+DMA_ParaNum_ALU*8*MMU_BASE;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //Y(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 --;                    //������Ӧ��ˮ��
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD0 = M[RSP+3*MMU_BASE];  //X(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0_ClrByteH8;
    RD1 = 0x7a000000;          //CntW is 3
    RD0 += RD1;  //X(n)�׵�ַ
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
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
//  ����:
//      _DMA_ParaCfg_RffC
//  ����:
//      Ϊ�������볣����������DMA_Ctrl����
//  ����:
//      1.M[RSP+2*MMU_BASE]��X(n) �׵�ַ
//      2.M[RSP+1*MMU_BASE]��Z(n) �׵�ַ
//      3.M[RSP+0*MMU_BASE]��TimerNumֵ����Ӧ(Dword����*2)+4
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_RffC;
    RD0 = RN_PRAM_START+DMA_ParaNum_ALU*8*MMU_BASE;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //X(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 --;
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD1 = 0x75000000;          //CntW is 3
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 -= 2;
    RD0_ClrByteH8;
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x7e000000;          //CntB is 1
    M[RA0+2*MMU_BASE] = RD0;
    RD0 = 0x0C130001;//Step0//RD0 = 0x0C020001;//Step0  Bit21 0~��Absͳ�� 1~����Absͳ��
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
//  ����:
//      _DMA_ParaCfg_RffC_nAbs
//  ����:
//      Ϊ�������볣����������DMA_Ctrl����
//  ����:
//      1.M[RSP+2*MMU_BASE]��X(n) �׵�ַ
//      2.M[RSP+1*MMU_BASE]��Z(n) �׵�ַ
//      3.M[RSP+0*MMU_BASE]��TimerNumֵ����Ӧ(Dword����*2)+4
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_RffC_nAbs;
    RD0 = RN_PRAM_START+DMA_ParaNum_ALU*8*MMU_BASE;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //X(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 --;
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD1 = 0x75000000;          //CntW is 3
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 -= 2;
    RD0_ClrByteH8;
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x7e000000;          //CntB is 1
    M[RA0+2*MMU_BASE] = RD0;
    RD0 = 0x0C330001;//Step0//RD0 = 0x0C020001;//Step0  Bit21 0~��Absͳ�� 1~����Absͳ��
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
//  ����:
//      _DMA_ParaCfg_RffC_Rf
//  ����:
//      Ϊ�������볣����������DMA_Ctrl����
//  ����:
//      1.M[RSP+3*MMU_BASE]��X(n) �׵�ַ
//      2.M[RSP+2*MMU_BASE]��Z(n) �׵�ַ
//      3.M[RSP+1*MMU_BASE]��TimerNumֵ����ͳ�ƣ�(Dword����+2)*2+2 -------- ƽ����
//                                             (Dword����+2)*2+1 -------- ͳ������
//                                     ��ͳ�ƣ�(Dword����)*2+4   -------- �����е�Ŀ����
//                                             (Dword����)*3+4   -------- ˫��������
//                                             (Dword����)*3+3   -------- MAC FMT ˫���гˣ�MAC��
//      M[RSP+0*MMU_BASE]��Bit16 == 0����ͳ�� 
//						   Bit16 == 1��ͳ�� 
//						   Bit21 == 0����Abs 
//						   Bit21 == 1��Abs
//						   ����λ��������д��0x0C130001;
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_RffC_Rf;
    RD0 = RN_PRAM_START+DMA_ParaNum_ALU*8*MMU_BASE;
    RA0 = RD0;
    RD0 = M[RSP+3*MMU_BASE];   //X(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 --;
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;   //CntF is 0
    RD1 = 0x75000000;          //CntW is 3
    RD0 = M[RSP+2*MMU_BASE];   //Z(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 -= 2;
    RD0_ClrByteH8;
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x7e000000;          //CntB is 1
    M[RA0+2*MMU_BASE] = RD0;
    //RD0 = 0x0C130001;//Step0//RD0 = 0x0C020001;//Step0  Bit21 0~��Absͳ�� 1~����Absͳ��
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
//  ����:
//      _DMA_ParaCfg_Rf
//  ����:
//      Ϊ�����в�������DMA_Ctrl����
//  ����:
//      1.M[RSP+2*MMU_BASE]��X(n) �׵�ַ
//      2.M[RSP+1*MMU_BASE]��Z(n) �׵�ַ
//      3.M[RSP+0*MMU_BASE]������ (DwordΪ��λ)
//  ����ֵ:
//      ��
//  ע�ͣ�
//      �����ڲ��������ã���ڽ����ϲ㺯��ջ��
//      ����ʱ����ջ
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_Rf;
    RD0 = RN_PRAM_START+DMA_ParaNum_ALU*8*MMU_BASE;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];    //X(n)�׵�ַ
    RF_ShiftR2(RD0);            //��ΪDword��ַ
    RD0 --;
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;    //CntF is 0
    RD1 = 0x75000000;           //CntW is 3
    RD0 = M[RSP+1*MMU_BASE];    //Z(n)�׵�ַ
    RF_ShiftR2(RD0);            //��ΪDword��ַ
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
//  ����:
//      _DMA_ParaCfg_AD_Copy
//  ����:
//      Ϊ��AD��GRAM������Դ��ַ����Ϊ2������DMA_Ctrl����
//  ����:
//      1.M[RSP+2*MMU_BASE]��X(n) �׵�ַ
//      2.M[RSP+1*MMU_BASE]��Z(n) �׵�ַ
//      3.M[RSP+0*MMU_BASE]��TimerNumֵ����Ӧ(Dword����*2)+4
//  ����ֵ:
//      ��
//  ע�ͣ�
//      �����ڲ��������ã���ڽ����ϲ㺯��ջ��
//      ����ʱ����ջ
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_AD_Copy;
    RD0 = RN_PRAM_START+DMA_ParaNum_ALU*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //X(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 -= 2;// ???????
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD1 = 0x75000000;          //CntW is 3
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
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
//  ����:
//      _DMA_ParaCfg_DA_Copy
//  ����:
//      Ϊ��GRAM��DA������Ŀ���ַ����Ϊ2������DMA_Ctrl����
//  ����:
//      1.M[RSP+2*MMU_BASE]��X(n) �׵�ַ
//      2.M[RSP+1*MMU_BASE]��Z(n) �׵�ַ
//      3.M[RSP+0*MMU_BASE]��TimerNumֵ����Ӧ(Dword����*2)+4
//  ����ֵ:
//      ��
//  ע�ͣ�
//      �����ڲ��������ã���ڽ����ϲ㺯��ջ��
//      ����ʱ����ջ
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_DA_Copy;
    RD0 = RN_PRAM_START+DMA_ParaNum_ALU*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //X(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 --;
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD1 = 0x75000000;          //CntW is 3
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
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
//  ����:
//      _DMA_ParaCfg_Flow
//  ����:
//      Ϊ�˷�����������DMA_Ctrl����
//  ����:
//      1.M[RSP+2*MMU_BASE]��Bank��ʼ ��ַ
//      2.M[RSP+1*MMU_BASE]��Bank���� (DwordΪ��λ)
//      3.M[RSP+0*MMU_BASE]��ʱ�ӷ�Ƶ
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_Flow;
    RD0 = RN_PRAM_START+DMA_ParaNum_Flow*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+0*MMU_BASE];   //ʱ�ӷ�Ƶ
    M[RA0+0*MMU_BASE] = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //Bank��ʼ��ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RF_Not(RD0);               //Ӳ��Ҫ��
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
//  ����:
//      _DMA_ParaCfg_Flow2
//  ����:
//      Ϊ�˷�����������DMA_Ctrl����
//  ����:
//      1.M[RSP+2*MMU_BASE]��Bank��ʼ ��ַ
//      2.M[RSP+1*MMU_BASE]��Bank���� (DwordΪ��λ)
//      3.M[RSP+0*MMU_BASE]��ʱ�ӷ�Ƶ
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_Flow2;
    RD0 = RN_PRAM_START+DMA_ParaNum_Flow*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+0*MMU_BASE];   //ʱ�ӷ�Ƶ
    M[RA0+0*MMU_BASE] = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //Bank��ʼ��ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RF_Not(RD0);               //Ӳ��Ҫ��
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
//  ����:
//      _DMA_ParaCfg_I2S
//  ����:
//      ΪI2S�ӿ�����DMA_Ctrl����
//  ����:
//      1.M[RSP+2*MMU_BASE]��Bank��ʼ ��ַ
//      2.M[RSP+1*MMU_BASE]��Bank���� (DwordΪ��λ)
//      3.M[RSP+0*MMU_BASE]��ʱ�ӷ�Ƶ
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_I2S;
    RD0 = RN_PRAM_START+DMA_ParaNum_I2S*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+0*MMU_BASE];   //ʱ�ӷ�Ƶ
    M[RA0+0*MMU_BASE] = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //Bank��ʼ��ַ
    RF_ShiftR2(RD0);//           //��ΪDword��ַ
    RF_Not(RD0);               //Ӳ��Ҫ��
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
//  ����:
//      _DMA_ParaCfg_MAC
//  ����:
//      Ϊ˫�������.���ۼӲ�������DMA_Ctrl����
//  ����:
//      1.M[RSP+3*MMU_BASE]��X(n) �׵�ַ���ֽڵ�ַ��
//      2.M[RSP+2*MMU_BASE]��Y(n) �׵�ַ
//      3.M[RSP+1*MMU_BASE]��Z(n) �׵�ַ
//      4.M[RSP+0*MMU_BASE]��TimerNumֵ����Ӧ(����+1)*3 (DwordΪ��λ)
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_MAC;
    RD0 = RN_PRAM_START+DMA_ParaNum_MAC*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //Y(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD0 = M[RSP+3*MMU_BASE];  //X(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0_ClrByteH8;
    RD1 = 0x7a000000;          //CntW is 3
    RD0 += RD1;  //X(n)�׵�ַ
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
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
//  ����:
//      _DMA_IIRBANK_Analyze
//  ����:
//      ΪIIR�˲������������DMA_Ctrl�������������Ӵ�����
//  ����:
//      1.M[RSP+2*MMU_BASE]��XD(n) �׵�ַ
//      2.M[RSP+1*MMU_BASE]��SQ(n) �׵�ַ
//      3.M[RSP+0*MMU_BASE]������ (DwordΪ��λ)
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _DMA_IIRBANK_Analyze;
    //G4����
    RD0 = RN_PRAM_START+DMA_ParaNum_IIRBANK*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //X(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 -= 2;                  //��ˮ��ǰ����д��Ч
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

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH4;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_IIRBANK;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    Return_AutoField(3*MMU_BASE);



////////////////////////////////////////////////////////
//  ����:
//      _DMA_IIRBANK_Synthesis
//  ����:
//      ΪIIR�˲������������DMA_Ctrl�������������Ӵ��ۺ�
//  ����:
//      1.M[RSP+2*MMU_BASE]��XD(n) �׵�ַ
//      2.M[RSP+1*MMU_BASE]��SQ(n) �׵�ַ
//      3.M[RSP+0*MMU_BASE]������ (DwordΪ��λ)
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _DMA_IIRBANK_Synthesis;
    //G4����
    RD0 = RN_PRAM_START+DMA_ParaNum_IIRBANK*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //X(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 -= 2;                  //��ˮ��ǰ����д��Ч
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

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH4;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_IIRBANK;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    Return_AutoField(3*MMU_BASE);    



////////////////////////////////////////////////////////
//  ����:
//      _DMA_ParaCfg_FFT512_Revs
//  ����:
//      ����512���FFT������������ַ����ת��
//  ����:
//      1.M[RSP+1*MMU_BASE]��X(n) �׵�ַ
//      2.M[RSP+0*MMU_BASE]��Z(n) �׵�ַ
//  ����ֵ:
//      ��
//  ע�ͣ�
//      �����ڲ��������ã���ڽ����ϲ㺯��ջ��
//      ����ʱ����ջ
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_FFT512_Revs;
    RD0 = RN_PRAM_START+DMA_ParaNum_FFTRevs*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+1*MMU_BASE];   //X(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 --;
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;   //CntF is 0
    RD1 = 0x75000000;          //CntW is 3
    RD0 = M[RSP+0*MMU_BASE];   //Z(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
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
//  ����:
//      _DMA_ParaCfg_FFT512
//  ����:
//      ����512�㸴�����ݽ���FFT���㣬���һ���ֽ�
//  ����:
//      1.M[RSP+2*MMU_BASE]��W(n) �׵�ַ
//      2.M[RSP+1*MMU_BASE]��X(n) �׵�ַ
//      3.M[RSP+0*MMU_BASE]
//  ����ֵ:
//      ��
//  ע�ͣ�
//      �����ԭַ������ԭ����
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_FFT512;
    RD0 = RN_PRAM_START+DMA_ParaNum_FFT*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //X(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;   //CntF is 0
    RD1 = 0x55000000;          //CntW is 5
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0_ClrByteH8;
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x7e000000;          //CntB is 1
    M[RA0+2*MMU_BASE] = RD0;
    RD1 = 0x0C840001;//Step0   //0CC40001(1024) 0C840001(512) 0C440001(256)
    RD0 = M[RSP+0*MMU_BASE];   //0 ���ϴηֽ����û����λ��������������
    if(RD0_Zero) goto L_FFT512_L0;
    RD0 = 0x00080000;          //!0: ����λ����ǰ�ηֽ��������������
    RD1 += RD0;
L_FFT512_L0:
    M[RA0+3*MMU_BASE] = RD1;
    RD0 = 0x07200001;//Step1   //ѡ��Mode7 A R W A X W A R A R
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = 256*6;  //N/2�ε������㣬ÿ����Ҫ4��ʱ������
    RD0 += 3;     //�Ӳ���ˮ��
//  send_para(RD0);
//  call _Timer_Number;
//  RF_Not(RD0);
    RD0 = 0x7a7162c7;
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num    //0x0B162C0A
    Return_AutoField(3*MMU_BASE);


////////////////////////////////////////////////////////
//  ��������:
//      _DMA_ParaCfg_FFT128_Revs
//  ��������:
//      ����128���FFT������������ַ����ת��
//  ��ڲ���:
//      M[RSP+1*MMU_BASE]��X(n) �׵�ַ
//      M[RSP+0*MMU_BASE]��Z(n) �׵�ַ
//  ���ڲ���:
//      ��
//  ˵����
//      �����ڲ��������ã���ڽ����ϲ㺯��ջ��
//      ����ʱ����ջ
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_FFT128_Revs;
    RD0 = RN_PRAM_START+DMA_ParaNum_FFTRevs*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+1*MMU_BASE];   //X(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 --;
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;   //CntF is 0
    RD1 = 0x75000000;          //CntW is 3
    RD0 = M[RSP+0*MMU_BASE];   //Z(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
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
//  ����:
//      _DMA_ParaCfg_FFT128
//  ����:
//      ����128�㸴�����ݽ���FFT���㣬���һ���ֽ�
//  ����:
//      1.M[RSP+2*MMU_BASE]��W(n) �׵�ַ
//      2.M[RSP+1*MMU_BASE]��X(n) �׵�ַ
//      3.M[RSP+0*MMU_BASE]
//  ����ֵ:
//      ��
//  ע�ͣ�
//      �����ԭַ������ԭ����
//////////////////////////////////////////////////////////

Sub_AutoField _DMA_ParaCfg_FFT128;
    RD0 = RN_PRAM_START+DMA_ParaNum_FFT*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //X(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;   //CntF is 0
    RD1 = 0x55000000;          //CntW is 5
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0_ClrByteH8;
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x7e000000;          //CntB is 1
    M[RA0+2*MMU_BASE] = RD0;
    RD1 = 0x0CC40001;//Step0   //0CC40001(128) 0C840001(64)
    RD0 = M[RSP+0*MMU_BASE];   //0 ���ϴηֽ����û����λ��������������
    if(RD0_Zero) goto L_FFT128_L0;
    RD0 = 0x00080000;          //!0: ����λ����ǰ�ηֽ��������������
    RD1 += RD0;
L_FFT128_L0:
    M[RA0+3*MMU_BASE] = RD1;
    RD0 = 0x07200001;//Step1   //ѡ��Mode7 A R W A X W A R A R
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = 64*6;  //N/2�ε������㣬ÿ����Ҫ4��ʱ������
    RD0 += 3;     //�Ӳ���ˮ��
//  send_para(RD0);
//  call _Timer_Number;
//  RF_Not(RD0);
    RD0 = 0x549f2ec6;
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num    //0x0B162C0A
    Return_AutoField(3*MMU_BASE);
    
    
    
////////////////////////////////////////////////////////
//  ����:
//      _DMA_ParaCfg_FFT64_Revs
//  ����:
//      ����64���FFT������������ַ����ת��
//  ����:
//      1.M[RSP+1*MMU_BASE]��X(n) �׵�ַ
//      2.M[RSP+0*MMU_BASE]��Z(n) �׵�ַ
//  ����ֵ:
//      ��
//  ע�ͣ�
//      �����ڲ��������ã���ڽ����ϲ㺯��ջ��
//      ����ʱ����ջ
////////////////////////////////////////////////////////

Sub_AutoField _DMA_ParaCfg_FFT64_Revs;
    RD0 = RN_PRAM_START+DMA_ParaNum_FFTRevs*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+1*MMU_BASE];   //X(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 --;
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;   //CntF is 0
    RD1 = 0x75000000;          //CntW is 3
    RD0 = M[RSP+0*MMU_BASE];   //Z(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
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
//  ����:
//      _DMA_ParaCfg_FFT64
//  ����:
//      ����64�㸴�����ݽ���FFT���㣬���һ���ֽ�
//  ����:
//      M[RSP+2*MMU_BASE]��W(n) �׵�ַ
//      M[RSP+1*MMU_BASE]��X(n) �׵�ַ
//      M[RSP+0*MMU_BASE]
//  ����ֵ:
//      ��
//  ע�ͣ�
//      �����ԭַ������ԭ����
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_FFT64;
    RD0 = RN_PRAM_START+DMA_ParaNum_FFT*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //X(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;   //CntF is 0
    RD1 = 0x55000000;          //CntW is 5
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0_ClrByteH8;
    RD0 += RD1;
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = 0x7e000000;          //CntB is 1
    M[RA0+2*MMU_BASE] = RD0;
    RD1 = 0x0C840001;//Step0   //0CC40001(64) 0C840001(64)
    RD0 = M[RSP+0*MMU_BASE];   //0 ���ϴηֽ����û����λ��������������
    if(RD0_Zero) goto L_FFT64_L0;
    RD0 = 0x00080000;          //!0: ����λ����ǰ�ηֽ��������������
    RD1 += RD0;
L_FFT64_L0:
    M[RA0+3*MMU_BASE] = RD1;
    RD0 = 0x07200001;//Step1   //ѡ��Mode7 A R W A X W A R A R
    M[RA0+4*MMU_BASE] = RD0;
    RD0 = 0x00000001;//Step2
    M[RA0+5*MMU_BASE] = RD0;
    RD0 = -1;
    M[RA0+7*MMU_BASE] = RD0;
    RD0 = 64*6;  //N/2�ε������㣬ÿ����Ҫ4��ʱ������
    RD0 += 3;     //�Ӳ���ˮ��
//  send_para(RD0);
//  call _Timer_Number;
//  RF_Not(RD0);
    RD0 = 0x7aa16f3a;
    M[RA0+6*MMU_BASE] = RD0;  //Loop_Num    //0x0B162C0A
    Return_AutoField(3*MMU_BASE);
    
    


////////////////////////////////////////////////////////
//  ����:
//      _DMA_ParaCfg_Real2Complex
//  ����:
//      ʵ����������ɸ�����ʽ_�鲿��0
//      ע�⣺�����ε��ã�д��ַ����Ϊ2
//            һ�ν���ֻ���ż����Ż��������
//  ����:
//      1.M[RSP+2*MMU_BASE]��X(n) �׵�ַ
//      2.M[RSP+1*MMU_BASE]��Z(n) �׵�ַ
//      3.M[RSP+0*MMU_BASE]������ (DwordΪ��λ)
//  ����ֵ:
//      ��
//  ע�ͣ�
//      �����ڲ��������ã���ڽ����ϲ㺯��ջ��
//      ����ʱ����ջ
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_Real2Complex;
    RD0 = RN_PRAM_START+DMA_ParaNum_Format*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //X(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD1 = 0x7a000000;          //CntW is 3
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
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
//  ����:
//      _DMA_ParaCfg_GetH16L16
//  ����:
//      ��ȡ�����е�ʵ�������鲿������ɱ�׼����
//  ����:
//      1.M[RSP+2*MMU_BASE]��X(n) �׵�ַ���ֽڵ�ַ��
//      2.M[RSP+1*MMU_BASE]��Z(n) �׵�ַ
//      3.M[RSP+0*MMU_BASE]��TimerNumֵ����Ӧ(����/2+1)*3 (DwordΪ��λ)
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_GetH16L16;
    RD0 = RN_PRAM_START+DMA_ParaNum_Format*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //Y(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 -= 1;                    //������Ӧ��ˮ��
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD0 ++;
    RD0_ClrByteH8;
    RD1 = 0x7a000000;          //CntW is 3
    RD0 += RD1;  //X(n)�׵�ַ
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
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
//  ����:
//      _DMA_ParaCfg_FiltIIR
//  ����:
//      ΪIIR�˲�����������DMA_Ctrl����
//  ����:
//      1.M[RSP+2*MMU_BASE]��X(n) �׵�ַ
//      2.M[RSP+1*MMU_BASE]��Z(n) �׵�ַ
//      3.M[RSP+0*MMU_BASE]����Dword����*48+1��
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_FiltIIR;
    RD0 = RN_PRAM_START+DMA_ParaNum_IIR*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //X(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 -= 2;                  //��ˮ��ǰ����д��Ч
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
//  ����:
//      _DMA_ParaCfg_Rff_Step2
//  ����:
//      Ϊ˫���в�������DMA_Ctrl��������ַ����Ϊ2Dword
//  ����:
//      1.M[RSP+3*MMU_BASE]��X(n) �׵�ַ���ֽڵ�ַ��
//      2.M[RSP+2*MMU_BASE]��Y(n) �׵�ַ
//      3.M[RSP+1*MMU_BASE]��Z(n) �׵�ַ
//      4.M[RSP+0*MMU_BASE]��TimerNumֵ����Ӧ(Dword����*3)+4
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_Rff_Step2;
    RD0 = RN_PRAM_START+DMA_ParaNum_ALU*8*MMU_BASE;
    RA0 = RD0;
    RD0 = M[RSP+2*MMU_BASE];   //Y(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 -= 2;                  //������Ӧ��ˮ��
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD0 = M[RSP+3*MMU_BASE];  //X(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0_ClrByteH8;
    RD1 = 0x7a000000;          //CntW is 3
    RD0 += RD1;  //X(n)�׵�ַ
    M[RA0+1*MMU_BASE] = RD0;
    RD0 = M[RSP+1*MMU_BASE];   //Z(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
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
//  ����:
//      _DMA_ParaCfg_FFT128_Write
//  ����:
//      Ϊ��GRAM��FFT128ר�û��濽��������
//     ��Ŀ���ַ����Ϊ1������DMA_Ctrl����
//  ����:
//      M[RSP+0*MMU_BASE]��X(n) �׵�ַ
//  ����ֵ:
//      ��
//  ע�ͣ�
//      �����ڲ��������ã���ڽ����ϲ㺯��ջ��
//      ����ʱ����ջ
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_FFT128_Write;
    RD0 = RN_PRAM_START+DMA_ParaNum_FFT*MMU_BASE*8;
    RA0 = RD0;
    RD0 = M[RSP+0*MMU_BASE];   //X(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 --;
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD1 = 0x75000000;          //CntW is 3
    RD0 = FFT128RAM_Addr0;   //Z(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
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
    Return_AutoField(1*MMU_BASE);//      M[RSP+0*MMU_BASE]��TimerNumֵ����Ӧ(Dword����*2)+4



////////////////////////////////////////////////////////
//  ����:
//      _DMA_ParaCfg_FFT128_Read
//  ����:
//      Ϊ��FFT128ר�û��濽����GRAM
//     ��Ŀ���ַ����Ϊ1������DMA_Ctrl����
//  ����:
//      M[RSP+0*MMU_BASE]��Z(n) Ŀ���ַ
//  ����ֵ:
//      ��
//  ע�ͣ�
//      �����ڲ��������ã���ڽ����ϲ㺯��ջ��
//      ����ʱ����ջ
////////////////////////////////////////////////////////
Sub_AutoField _DMA_ParaCfg_FFT128_Read;
    RD0 = RN_PRAM_START+DMA_ParaNum_FFT*MMU_BASE*8;
    RA0 = RD0;
    RD0 = FFT128RAM_Addr0;   //X(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
    RD0 --;
    RD0_ClrByteH8;
    M[RA0+0*MMU_BASE] = RD0;            //CntF is 0
    RD1 = 0x75000000;          //CntW is 3
    RD0 = M[RSP+0*MMU_BASE];   //Z(n)�׵�ַ
    RF_ShiftR2(RD0);           //��ΪDword��ַ
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
    Return_AutoField(1*MMU_BASE);//      M[RSP+0*MMU_BASE]��TimerNumֵ����Ӧ(Dword����*2)+4



END SEGMENT

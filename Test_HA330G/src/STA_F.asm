#define _STA_F_

#include <CPU11.def>
#include <resource_allocation.def>
#include <RN_DSP_Cfg.def>
#include <DMA_ParaCfg.def>
#include <DMA_ALU.def>
#include <STA.def>

CODE SEGMENT STA_F;
////////////////////////////////////////////////////////
//  ����:
//      FindMaxMin
//  ����:
//      �����м�ֵ��STA1��
//  ����:
//      1.RD0:���ݵ�ַ
//      2.RD1:���ݳ��ȶ�Ӧ��TimerNumֵ(Dword����+2)*2+1
//  ����ֵ:
//      1.RD0:���ֵ
//      2.RD1:��Сֵ
////////////////////////////////////////////////////////
Sub_AutoField FindMaxMin;
    RA0 = RD0;
    RD2 = RD1;
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��

    //������ص�4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;

    //����ALU����
    RD0 = Op32Bit;      //ALU����λ��ѡ��Ϊ32λ
    RD0 += RffC_Add;     //�ӷ�ָ��
    M[RA6+0*MMU_BASE] = RD0;     //ALU1дָ��˿�
    RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1дConst�˿�
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    send_para(RA0);//Դ��ַ0
    send_para(RA0);//Ŀ���ַ
    send_para(RD2);
    RD0 = 0x0C130001;
    send_para(RD0);
    call _DMA_ParaCfg_RffC_Rf;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
//Set_LevelL10;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
//Set_LevelH10;

    //��ȡֱ��ͼͳ�ƽ��
    MemSetRAM4K_Enable;  //������չ�˿�ʱ��ʹ��
    RD0 = M[RA6+0*MMU_BASE]; //DW0
    //RD0 = M[RA6+2*MMU_BASE]; //DW1
    //RD0 = M[RA6+2*MMU_BASE]; //DW2
    MemSet_Disable;  //Set_All
    RD1 = RD0;
    RF_GetH16(RD0);
    RF_GetL16(RD1);
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      AbsSum
//  ����:
//      �����еľ���ֵ�ۼӺͣ�STA1��
//  ����:
//      1.RD0:���ݵ�ַ
//      2.RD1:���ݳ��ȶ�Ӧ��TimerNumֵ(Dword����*2+4+1)
//  ����ֵ:
//      1.RD0:����ֵ�ۼӺ�
////////////////////////////////////////////////////////
Sub_AutoField AbsSum;
    RA0 = RD0;
    RD2 = RD1;
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��

    //������ص�4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;

    //����ALU����
    RD0 = Op32Bit;      //ALU����λ��ѡ��Ϊ32λ
    RD0 += RffC_Add;     //�ӷ�ָ��
    M[RA6+0*MMU_BASE] = RD0;     //ALU1дָ��˿�
    RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1дConst�˿�
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    send_para(RA0);//Դ��ַ0
    send_para(RA0);//Ŀ���ַ
    RD0 = RD2;
    send_para(RD0);
    call _DMA_ParaCfg_RffC;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
//Set_LevelL10;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
//Set_LevelH10;

    //��ȡֱ��ͼͳ�ƽ��
    MemSetRAM4K_Enable;  //������չ�˿�ʱ��ʹ��
    RD0 = M[RA6+0*MMU_BASE]; //DW0
    RD0 = M[RA6+0*MMU_BASE]; //DW1
    //RD0 = M[RA6+2*MMU_BASE]; //DW2
    MemSet_Disable;  //Set_All
    RD0_ClrByteH8;
    //RF_ShiftL1(RD0);
    //RF_ShiftL3(RD0);

    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      nAbsSum
//  ����:
//      �����е��ۼӺͣ�STA1��
//  ����:
//      1.RD0:���ݵ�ַ
//      2.RD1:���ݳ��ȶ�Ӧ��TimerNumֵ(Dword����+2)*2+1
//  ����ֵ:
//      1.RD0:�ۼӺ�
////////////////////////////////////////////////////////
Sub_AutoField nAbsSum;
    RA0 = RD0;
    RD2 = RD1;
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��

    //������ص�4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;

    //����ALU����
    RD0 = Op16Bit;      //ALU����λ��ѡ��Ϊ16λ
    RD0 += RffC_Add;     //�ӷ�ָ��
    M[RA6+0*MMU_BASE] = RD0;     //ALU1дָ��˿�
    RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1дConst�˿�
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    send_para(RA0);//Դ��ַ0
    send_para(RA0);//Ŀ���ַ
    RD0 = RD2;
    send_para(RD0);
    call _DMA_ParaCfg_RffC_nAbs;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
//Set_LevelL10;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
//Set_LevelH10;

    //��ȡֱ��ͼͳ�ƽ��
    MemSetRAM4K_Enable;  //������չ�˿�ʱ��ʹ��
    RD0 = M[RA6+0*MMU_BASE]; //DW0
    RD0 = M[RA6+0*MMU_BASE]; //DW1
    //RD0 = M[RA6+2*MMU_BASE]; //DW2
    MemSet_Disable;  //Set_All
    RD0_ClrByteH8;
    //RF_ShiftL1(RD0);
    //RF_ShiftL3(RD0);

    Return_AutoField(0);




////////////////////////////////////////////////////////
//  ����:
//      MeanSquareAverage
//  ����:
//      �����еľ�����STA1������ֵ��ĸΪ32
//  ����:
//      1.RD0:���ݵ�ַ
//      2.RD1:���ݳ��ȶ�Ӧ��TimerNumֵ(Dword����+2)*2+2
//  ����ֵ:
//      1.RD0:����ֵ
////////////////////////////////////////////////////////
Sub_AutoField MeanSquareAverage;
    RA0 = RD0;
    RD2 = RD1;
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��

    //������ص�4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;

    //����ALU����
    RD0 = Op32Bit;      //ALU����λ��ѡ��Ϊ32λ
    RD0 += RffC_Add;     //�ӷ�ָ��
    M[RA6+0*MMU_BASE] = RD0;     //ALU1дָ��˿�
    RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1дConst�˿�
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    send_para(RA0);//Դ��ַ0
    send_para(RA0);//Ŀ���ַ
    RD0 = RD2;
    send_para(RD0);
    call _DMA_ParaCfg_RffC;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    //��ȡֱ��ͼͳ�ƽ��
    MemSetRAM4K_Enable;  //������չ�˿�ʱ��ʹ��
    RD0 = M[RA6+0*MMU_BASE]; //DW0
    RD0 = M[RA6+0*MMU_BASE]; //DW1
    RD0 = M[RA6+0*MMU_BASE]; //DW2
    MemSet_Disable;  //Set_All
    RF_ShiftL1(RD0);
    RF_ShiftL2(RD0);

    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      FindMaxIndex
//  ����:
//      �����о���ֵ�����ֵ��Index��STA2��
//  ����:
//      1.RD0:���ݵ�ַ
//      2.RD1:���ݳ��ȶ�Ӧ��TimerNumֵ(Dword����+2)*2
//  ����ֵ:
//      1.RD0:���ֵ��Index
////////////////////////////////////////////////////////
Sub_AutoField FindMaxIndex;
    RA0 = RD0;
    RD2 = RD1;
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH2] = RD0;//ѡ��PATH2��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��

    //������ص�4KRAM
    RD0 = DMA_PATH2;
    M[RA0] = RD0;

    //����ALU����
    RD0 = Op32Bit;      //ALU����λ��ѡ��Ϊ32λ
    RD0 += RffC_Add;     //�ӷ�ָ��
    M[RA6+2*MMU_BASE] = RD0;     //ALU1дָ��˿�
    RD0 = 0;
    M[RA6+3*MMU_BASE] = RD0;     //ALU1дConst�˿�
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    send_para(RA0);//Դ��ַ0
    send_para(RA0);//Ŀ���ַ
    RD0 = RD2;
    send_para(RD0);
    call _DMA_ParaCfg_RffC;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH2;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    //��ȡֱ��ͼͳ�ƽ��
    MemSetRAM4K_Enable;  //������չ�˿�ʱ��ʹ��
    RD0 = M[RA6+1*MMU_BASE];//Maxֵ | ~(Index)
    RF_Not(RD0);
    RF_GetL16(RD0);
    RF_ShiftR1(RD0);
    MemSet_Disable;  //Set_All

    Return_AutoField(0);


////////////////////////////////////////////////////////
//  ��������:
//      STA1_Run
//  ��������:
//      ����STA1ͳ�������ȴ�ͳ�����
//  ��ڲ���:
//      RD0:���ݵ�ַ
//      RD1:���ݳ��ȶ�Ӧ��TimerNumֵ
//  ���ڲ���:
//      ��
////////////////////////////////////////////////////////
sub_autofield STA1_Run;
    RA0 = RD0;
    RD2 = RD1;
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��

    //������ص�4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;

    //����ALU����
    RD0 = Op32Bit;      //ALU����λ��ѡ��Ϊ32λ
    RD0 += RffC_Add;     //�ӷ�ָ��
    M[RA6+0*MMU_BASE] = RD0;     //ALU1дָ��˿�
    RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1дConst�˿�
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ������
    send_para(RA0);//Դ��ַ0
    send_para(RA0);//Ŀ���ַ
    RD0 = RD2;
    send_para(RD0);
    call _DMA_ParaCfg_RffC;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    return_autofield(0);



////////////////////////////////////////////////////////
//  ��������:
//      STA2_Run
//  ��������:
//      ����STA2ͳ�������ȴ�ͳ�����
//  ��ڲ���:
//      RD0:���ݵ�ַ
//      RD1:���ݳ��ȶ�Ӧ��TimerNumֵ
//  ���ڲ���:
//      ��
////////////////////////////////////////////////////////
sub_autofield STA2_Run;
    RA0 = RD0;
    RD2 = RD1;
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH2] = RD0;//ѡ��PATH2��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��

    //������ص�4KRAM
    RD0 = DMA_PATH2;
    M[RA0] = RD0;

    //����ALU����
    RD0 = Op32Bit;      //ALU����λ��ѡ��Ϊ32λ
    RD0 += RffC_Add;     //�ӷ�ָ��
    M[RA6+2*MMU_BASE] = RD0;     //ALU1дָ��˿�
    RD0 = 0;
    M[RA6+3*MMU_BASE] = RD0;     //ALU1дConst�˿�
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ������
    send_para(RA0);//Դ��ַ0
    send_para(RA0);//Ŀ���ַ
    RD0 = RD2;
    send_para(RD0);
    call _DMA_ParaCfg_RffC;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH2;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    return_autofield(0);



////////////////////////////////////////////////////////
//  ��������:
//      STA3_Run
//  ��������:
//      ����STA3ͳ�������ȴ�ͳ�����
//  ��ڲ���:
//      RD0:���ݵ�ַ
//      RD1:���ݳ��ȶ�Ӧ��TimerNumֵ
//  ���ڲ���:
//      ��
////////////////////////////////////////////////////////
sub_autofield STA3_Run;
    RA0 = RD0;
    RD2 = RD1;
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH3] = RD0;//ѡ��PATH3��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��

    //������ص�4KRAM
    RD0 = DMA_PATH3;
    M[RA0] = RD0;

    //����ALU����
    RD0 = Op32Bit;      //ALU����λ��ѡ��Ϊ32λ
    RD0 += RffC_Add;     //�ӷ�ָ��
    M[RA6+4*MMU_BASE] = RD0;     //ALU1дָ��˿�
    RD0 = 0;
    M[RA6+5*MMU_BASE] = RD0;     //ALU1дConst�˿�
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ������
    send_para(RA0);//Դ��ַ0
    send_para(RA0);//Ŀ���ַ
    RD0 = RD2;
    send_para(RD0);
    call _DMA_ParaCfg_RffC;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH3;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    return_autofield(0);



////////////////////////////////////////////////////////
//  ��������:
//      STA1_Rst
//  ��������:
//      ��ȡSTA1ͳ�����Ľ��
//  ��ڲ���:
//      ��
//  ���ڲ���:
//      RD0:Max<31:16> | Min<15:0>
//      RD1:������_L<31:24> | �ۼӺ�<23:0>
//      RD4:������_H<31:29> | ƽ����/256<28:0>
////////////////////////////////////////////////////////
sub_autofield STA1_Rst;
    MemSetRAM4K_Enable;
    RD0 = M[RA6+0*MMU_BASE];
    RD1 = M[RA6+0*MMU_BASE];
    RD4 = M[RA6+0*MMU_BASE];
    MemSet_Disable;
    return_autofield(0);



////////////////////////////////////////////////////////
//  ��������:
//      STA2_Rst
//  ��������:
//      ��ȡSTA2ͳ�����Ľ��
//  ��ڲ���:
//      ��
//  ���ڲ���:
//      RD0:Max<31:16> | ~(Index)<11:0>
//      RD1:������_L<31:24> | �ۼӺ�<23:0>
//      RD4:������_H<31:29> | ƽ����/256<28:0>
////////////////////////////////////////////////////////
sub_autofield STA2_Rst;
    MemSetRAM4K_Enable;
    RD0 = M[RA6+1*MMU_BASE];
    RD1 = M[RA6+1*MMU_BASE];
    RD4 = M[RA6+1*MMU_BASE];
    MemSet_Disable;
    return_autofield(0);



////////////////////////////////////////////////////////
//  ��������:
//      STA3_Rst
//  ��������:
//      ��ȡSTA3ͳ�����Ľ��
//  ��ڲ���:
//      ��
//  ���ڲ���:
//      RD0:Max<31:16> | Min<15:0>
//      RD1:�ۼӺ�<31:0>
//      RD4:ƽ����/256<31:0>
////////////////////////////////////////////////////////
sub_autofield STA3_Rst;
    MemSetRAM4K_Enable;
    RD0 = M[RA6+2*MMU_BASE];
    RD1 = M[RA6+2*MMU_BASE];
    RD4 = M[RA6+2*MMU_BASE];
    MemSet_Disable;
    return_autofield(0);



END SEGMENT

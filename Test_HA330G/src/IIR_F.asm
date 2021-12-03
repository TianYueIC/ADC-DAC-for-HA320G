#define _IIR_F_

#include <CPU11.def>
#include <resource_allocation.def>
#include <RN_DSP_Cfg.def>
#include <DMA_ParaCfg.def>
#include <DMA_ALU.def>
#include <IIR.def>

extern _Debug_Memory_File_Bank;



CODE SEGMENT IIR_F;
////////////////////////////////////////////////////////
//  ����:
//      _IIR_PATH1_FiltLP32
//  ����:
//      ʹ��IIR1_1ִ�е�ͨ�˲���Para0, Data00
//  ����:
//      1.RA0:��������ָ�룬16bit���ո�ʽ����
//      2.RA1:�������ָ�룬16bit���ո�ʽ����(out)
//      3.RD0:TimerNumֵ = (����Dword����*48)+1
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _IIR_PATH1_FiltLP32;
    RD2 = RD0;
    //--------------------------------------------------
    //����GRAM����ΪDMA_Ctrl1������GroupΪ��λ
    MemSetPath_Enable;  //����ͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    //����ALU����
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //������ص�4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;

    IIR_PATH1_Enable;
    RD0 = 0x0;
    IIR_PATH1_BANK = RD0;

    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    RD0 = RA0;//Դ��ַ
    send_para(RD0);
    RD0 = RA1;//Ŀ���ַ
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_FiltIIR;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_IIR;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
	IIR_PATH1_CLRADDR;
    //IIR_PATH1_Disable;
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  ����:
//      _IIR_PATH1_FiltLP4Class
//  ����:
//      ʹ��IIR1_1ִ�е�ͨ�˲���Para1, Data01
//  ����:
//      1.RA0:��������ָ�룬16bit���ո�ʽ����
//      2.RA1:�������ָ�룬16bit���ո�ʽ����(out)
//      3.RD0:TimerNumֵ = (�������Dword����*28)+1
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _IIR_PATH1_FiltLP4Class;
    RD2 = RD0;
    //--------------------------------------------------
    //����GRAM����ΪDMA_Ctrl1������GroupΪ��λ
    MemSetPath_Enable;  //����ͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    //����ALU����
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //������ص�4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;
    IIR_PATH1_Enable;
    RD0 = 0x5;// Para1, Data01
    IIR_PATH1_BANK = RD0;
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    RD0 = RA0;//Դ��ַ
    send_para(RD0);
    RD0 = RA1;//Ŀ���ַ
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_FiltIIR;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_IIR;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
	IIR_PATH1_CLRADDR;
    IIR_PATH1_Disable;
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  ����:
//      _IIR_PATH1_FiltHP4Class
//  ����:
//      ʹ��IIR1_1ִ�и�ͨ�˲���Para1, Data11
//  ����:
//      1.RA0:��������ָ�룬16bit���ո�ʽ����
//      2.RA1:�������ָ�룬16bit���ո�ʽ����(out)
//      3.RD0:TimerNumֵ = (�������Dword����*48)+1
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _IIR_PATH1_FiltHP4Class;
    RD2 = RD0;
    //--------------------------------------------------
    //����GRAM����ΪDMA_Ctrl1������GroupΪ��λ
    MemSetPath_Enable;  //����ͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    //����ALU����
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //������ص�4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;
    IIR_PATH1_Enable;
    RD0 = 0x7;// Para1, Data11
    IIR_PATH1_BANK = RD0;
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    RD0 = RA0;//Դ��ַ
    send_para(RD0);
    RD0 = RA1;//Ŀ���ַ
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_FiltIIR;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_IIR;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
	IIR_PATH1_CLRADDR;
    IIR_PATH1_Disable;
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  ����:
//      _IIR_PATH1_HawlClr
//  ����:
//      ʹ��IIR1_1ִ���ݲ���Para1, Data10
//  ����:
//      1.RA0:��������ָ�룬16bit���ո�ʽ����
//      2.RA1:�������ָ�룬16bit���ո�ʽ����(out)
//      3.RD0:TimerNumֵ = (�������Dword����*48)+1
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _IIR_PATH1_HawlClr;
    RD2 = RD0;
    //--------------------------------------------------
    //����GRAM����ΪDMA_Ctrl1������GroupΪ��λ
    MemSetPath_Enable;  //����ͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    //����ALU����
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //������ص�4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;
    //IIR_PATH1_Enable;
    RD0 = 0x6;
    IIR_PATH1_BANK = RD0;
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    RD0 = RA0;//Դ��ַ
    send_para(RD0);
    RD0 = RA1;//Ŀ���ַ
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_FiltIIR;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_IIR;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
	IIR_PATH1_CLRADDR;
    //IIR_PATH1_Disable;
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  ����:
//      _IIR_PATH3_HP
//  ����:
//      ʹ��IIR2_3ִ�и�ͨ�˲�����ͨ��ʼƵ��170Hz��Para0, Data00
//  ����:
//      1.RA0:��������ָ�룬16bit���ո�ʽ����
//      2.RA1:�������ָ�룬16bit���ո�ʽ����(out)
//      3.RD0:TimerNumֵ = (����Dword����*88)+1
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _IIR_PATH3_HP;
    RD2 = RD0;
    //--------------------------------------------------
    //����GRAM����ΪDMA_Ctrl1������GroupΪ��λ
    MemSetPath_Enable;  //����ͨ��ʹ��
    M[RA0+MGRP_PATH3] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    //����ALU����
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //������ص�4KRAM
    RD0 = DMA_PATH3;
    M[RA0] = RD0;
    M[RA1] = RD0;

    IIR_PATH3_Enable;
    RD0 = 0x0;
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
	IIR_PATH3_CLRADDR;
//    IIR_PATH3_Disable;
    Return_AutoField(0*MMU_BASE);

////////////////////////////////////////////////////////
//  ����:
//      _IIR_PATH3_HB
//  ����:
//      ʹ��IIR2_3ִ���ڲ�0��İ���˲���Para1, Data01
//  ����:
//      1.RA0:��������ָ�룬16bit���ո�ʽ����
//      2.RA1:�������ָ�룬16bit���ո�ʽ����(out)
//      3.RD0:TimerNumֵ = (����Dword����*88)+1
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _IIR_PATH3_HB;
    RD2 = RD0;
    //--------------------------------------------------
    //����GRAM����ΪDMA_Ctrl1������GroupΪ��λ
    MemSetPath_Enable;  //����ͨ��ʹ��
    M[RA0+MGRP_PATH3] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    //����ALU����
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //������ص�4KRAM
    RD0 = DMA_PATH3;
    M[RA0] = RD0;
    M[RA1] = RD0;

    IIR_PATH3_Enable;
    RD0 = 0b0101;
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

//    IIR_PATH3_Disable;
	IIR_PATH3_CLRADDR;
    Return_AutoField(0*MMU_BASE);

////////////////////////////////////////////////////////
//  ����:
//      _IIR_PATH3_FSFT
//  ����:
//      ʹ��IIR2_3ִ��1/4����ͨ�˲���Para1, Data01/Data10/Data11
//  ����:
//      1.RA0:��������ָ�룬16bit���ո�ʽ����
//      2.RA1:�������ָ�룬16bit���ո�ʽ����(out)
//      3.RD0:TimerNumֵ = (����Dword����*88)+1
//      4.RD1:Data Bank�� 1/2/3
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _IIR_PATH3_FSFT;
    RD2 = RD0;
    RD3 = RD1;
    //--------------------------------------------------
    //����GRAM����ΪDMA_Ctrl1������GroupΪ��λ
    MemSetPath_Enable;  //����ͨ��ʹ��
    M[RA0+MGRP_PATH3] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    //����ALU����
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //������ص�4KRAM
    RD0 = DMA_PATH3;
    M[RA0] = RD0;
    M[RA1] = RD0;

    IIR_PATH3_Enable;
    RD0 = 4;
    RD0 += RD3;
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
	IIR_PATH3_CLRADDR;
//    IIR_PATH3_Disable;
    Return_AutoField(0*MMU_BASE);


END SEGMENT

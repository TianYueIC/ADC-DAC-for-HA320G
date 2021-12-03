#define _FMT_F_

#include <CPU11.def>
#include <resource_allocation.def>
#include <RN_DSP_Cfg.def>
#include <DMA_ParaCfg.def>
#include <DMA_ALU.def>
#include <FMT.def>
#include <Global.def>

CODE SEGMENT FMT_F;
////////////////////////////////////////////////////////
//  ����:
//      Get_Real
//  ����:
//      ��ȡʵ��
//  ����:
//      1.RA0:��������ָ�룬��ʽ[Re | Im]
//      2.RA1:�������ָ�룬��ʽ[Re(n+1) | Re(n)](out)
//      3.RD0:TimerNumֵ = (�������Dword����*3)+3
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField Get_Real;
    RD2 = RD0;
    //����Ϊ˫Ŀ����ʾ������
    //--------------------------------------------------
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //���ò���
    RD0 = 0x4141;//ȡ�鲿0x8282;//ȡʵ��0x4141
    M[RA6+11*MMU_BASE] = RD0;     //ALU1дָ��˿�
    //������ص�4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    RD0 = RA0;//Դ��ַ0
    send_para(RD0);
    RD0 = RA1;//Ŀ���ַ
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_GetH16L16;//��Ŀ��������ר�ú���

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_Format;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      Get_Imag
//  ����:
//      ��ȡ�鲿
//  ����:
//      1.RA0:��������ָ�룬��ʽ[Re | Im]
//      2.RA1:�������ָ�룬��ʽ[Im(n+1) | Im(n)](out)
//      3.RD0:TimerNumֵ = (�������Dword����*3)+3
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField Get_Imag;
    RD2 = RD0;
    //����Ϊ˫Ŀ����ʾ������
    //--------------------------------------------------
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //���ò���
    RD0 = 0x8282;//ȡ�鲿0x8282;//ȡʵ��0x4141
    M[RA6+11*MMU_BASE] = RD0;     //ALU1дָ��˿�
    //������ص�4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    RD0 = RA0;//Դ��ַ0
    send_para(RD0);
    RD0 = RA1;//Ŀ���ַ
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_GetH16L16;//��Ŀ��������ר�ú���

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_Format;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    Return_AutoField(0);



//////////////////////////////////////////////////////////
////  ����:
////      Real_To_Complex
////  ����:
////      ����16bit��ʽת��Ϊ������ʽ���鲿����
////  ����:
////      1.RA0:��������ָ�룬��ʽ[Re(n+1) | Re(n)]
////      2.RA1:�������ָ�룬��ʽ[Re | 0](out)
////  ����ֵ:
////      ��
//////////////////////////////////////////////////////////
//Sub_AutoField Real_To_Complex;
//    RA0 = RD0;
//    RA1 = RD1;
//
//    //����Ϊʵ������ת���ɸ�������ʾ������
//    //�洢��ַ��չΪ�������鲿��0
//    ////ż����ַ
//    //--------------------------------------------------
//    MemSetPath_Enable;  //����Groupͨ��ʹ��
//    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
//
//    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
//    //���ò���
//    RD0 = 0x2020;  //ż�����0x2020  //�������0x1010
//    M[RA6+11*MMU_BASE] = RD0;     //ALU1дָ��˿�
//    //������ص�4KRAM
//    RD0 = DMA_PATH1;
//    M[RA0] = RD0;
//    M[RA1] = RD0;
//    MemSet_Disable;     //���ý���
//
//    //����DMA_Ctrl������������ַ.����
//    RD0 = RA0;//Դ��ַ0
//    send_para(RD0);
//    RD0 = RA1;//Ŀ���ַ
//    send_para(RD0);
//    RD0 = FL_M2_A2;
//    send_para(RD0);
//    call _DMA_ParaCfg_Real2Complex;
//
//    //ѡ��DMA_Ctrlͨ��������������
//    RD0 = DMA_PATH1;
//    ParaMem_Num = RD0;
//    RD0 = DMA_nParaNum_Format;
//    ParaMem_Addr = RD0;
//    Wait_While(Flag_DMAWork==1);
//    nop; nop;
//    Wait_While(Flag_DMAWork==0);
//    //---------------------------------------------------
//
//    //������ַ
//    //--------------------------------------------------
//    MemSetPath_Enable;  //����Groupͨ��ʹ��
//    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
//
//    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
//    //���ò���
//    RD0 = 0x1010;  //ż�����0x2020  //�������0x1010
//    M[RA6+11*MMU_BASE] = RD0;     //ALU1дָ��˿�
//    //������ص�4KRAM
//    RD0 = DMA_PATH1;
//    M[RA0] = RD0;
//    M[RA1] = RD0;
//    RD1 = 1024;
//    M[RA1+RD1] = RD0;
//    MemSet_Disable;     //���ý���
//
//    //����DMA_Ctrl������������ַ.����
//    RD0 = RA0;//Դ��ַ0
//    send_para(RD0);
//    RD0 = RA1;//Ŀ���ַ
//    RD0 += MMU_BASE;//������ַ��1��ʼ
//    send_para(RD0);
//    RD0 = FL_M2_A2;
//    send_para(RD0);
//    call _DMA_ParaCfg_Real2Complex;
//
//    //ѡ��DMA_Ctrlͨ��������������
//    RD0 = DMA_PATH1;
//    ParaMem_Num = RD0;
//    RD0 = DMA_nParaNum_Format;
//    ParaMem_Addr = RD0;
//    Wait_While(Flag_DMAWork==1);
//    nop; nop;
//    Wait_While(Flag_DMAWork==0);
//    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      Real_To_Complex2
//  ����:
//      ����16bit��ʽת��Ϊ������ʽ���鲿����
//  ����:
//      1.RA0:��������ָ�룬��ʽ[Re(n+1) | Re(n)]
//      2.RA1:�������ָ�룬��ʽ[Re | 0](out)
//      3.RD0:TimerNumֵ = (��������Dword����*2)+2
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField Real_To_Complex2;
    RD2 = RD0;
    //����Ϊʵ������ת���ɸ�������ʾ������
    //�洢��ַ��չΪ�������鲿��0
    ////ż����ַ
    //--------------------------------------------------
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //���ò���
    RD0 = 0x2020;  //ż�����0x2020  //�������0x1010
    M[RA6+11*MMU_BASE] = RD0;     //ALU1дָ��˿�
    //������ص�4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //���ý���
    //����DMA_Ctrl������������ַ.����
    RD0 = RA0;//Դ��ַ0
    send_para(RD0);
    RD0 = RA1;//Ŀ���ַ
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_Real2Complex;
    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_Format;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    //---------------------------------------------------
    //������ַ
    //--------------------------------------------------
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //���ò���
    RD0 = 0x1010;  //ż�����0x2020  //�������0x1010
    M[RA6+11*MMU_BASE] = RD0;     //ALU1дָ��˿�
    //������ص�4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;
    RD1 = 1024;
    M[RA1+RD1] = RD0;
    MemSet_Disable;     //���ý���
    //����DMA_Ctrl������������ַ.����
    RD0 = RA0;//Դ��ַ0
    send_para(RD0);
    RD0 = RA1;//Ŀ���ַ
    RD0 += MMU_BASE;//������ַ��1��ʼ
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_Real2Complex;
    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_Format;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    Return_AutoField(0);



END SEGMENT

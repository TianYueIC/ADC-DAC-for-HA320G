#define _FFT_F_

#include <CPU11.def>
#include <resource_allocation.def>
#include <RN_DSP_Cfg.def>
#include <DMA_ParaCfg.def>
#include <DMA_ALU.def>
#include <Global.def>
#include <FFT.def>

CODE SEGMENT FFT_F;
////////////////////////////////////////////////////////
//  ����:
//      FFT_fix
//  ����:
//      FFT����
//      ������ڣ�RN_FFT_COFF_GRAM_ADDR
//  ����:
//      1.RD0:��������ָ�룬��λ16bit��ʽ����
//      2.RD1:�������ָ�룬������ʽ(out)
//  ����ֵ:
//      1.RD0:����ϵ��
////////////////////////////////////////////////////////
Sub_AutoField FFT_fix;
    push RD4;
    push RA2;

    RA0 = RD0;
    RA1 = RD1;
//FFT ��ַ����
    //��ʼ�� FFT,512��
    //--------------------------------------------------
    //����GRAM����ΪDMA_Ctrl3������GroupΪ��λ
    MemSetPath_Enable;  //����ͨ��ʹ��
    M[RA0+MGRP_PATH3] = RD0;//ѡ��PATH3��ͨ����Ϣ��ƫַ��

    //����LMT����
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    RD0 = 0x4;          //���ݴ���ָ��
    M[RA6+4*MMU_BASE] = RD0;     //LMTдָ��˿�
    //������ص�RAM��512�㸴��ռ��2K�ֽڿռ�
    RD0 = DMA_PATH3;
    RD1 = RN_GRAM_BANK_SIZE;
    M[RA0] = RD0;
    M[RA0+RD1] = RD0;
    M[RA1] = RD0;
    M[RA1+RD1] = RD0;
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    RD0 = RA0;//Դ��ַ
    send_para(RD0);
    RD0 = RA1;//Ŀ���ַ
    send_para(RD0);
    call _DMA_ParaCfg_FFT512_Revs;//��Ŀ��������ר�ú���

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH3;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_FFTRevs;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    //---------------------------------------------------

//Ӳ����ʼ��

    //RAMָ���趨
    RD0 = RN_FFT_COFF_GRAM_ADDR;
    RA2 = RD0;          //FFTϵ����ַ

    RD3 = 0;            //��¼���ű���
    RD4 = -1;            //�������  0������λ
    RD2 = 9;           //�ֽ����  1024:10  512:9

    Sel_PATH3_FFT;
    //�ֽ�ѭ��
L_FFT_Loop_L0:
    //����GRAM����ΪDMA_Ctrl3������GroupΪ��λ
    MemSetPath_Enable;         //����ͨ��ʹ��
    M[RA1+MGRP_PATH3] = RD0;   //ѡ��PATH3��ͨ����Ϣ��ƫַ��

    //����4KRAMͨ��
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    RD0 = DMA_PATH3;
    RD1 = RN_GRAM_BANK_SIZE;
    M[RA1] = RD0;       //�����ĵ�ַ
    M[RA1+RD1] = RD0;
    M[RA2] = RD0;       //FFTϵ����ַ
M[RA2+RD1] = RD0;
RD1 = RN_GRAM_BANK_SIZE*2;
M[RA2+RD1] = RD0;
RD1 = RN_GRAM_BANK_SIZE*3;
M[RA2+RD1] = RD0;
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl����
    send_para(RA2);     //FFTϵ����ַ
    send_para(RA1);     //���ݵ�ַ
    send_para(RD4);     //�Ƿ���λ 0������λ
    call _DMA_ParaCfg_FFT512;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH3;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_FFT;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    //---------------------------------------------------

    //�жϲ������������
    RD4 = 0;
    if(RFlag_OverFlowFFT==0) goto L_FFT_Loop_L1;
    RD3 ++;
    RD4 = -1;
L_FFT_Loop_L1:

    //���Ʒֽ�ڴ�
    FFT_Next_Round;
    RD2 --;
    if(RQ_nZero) goto L_FFT_Loop_L0;

    Dis_PATH3_FFT;

    RD0 = RD3;

    pop RA2;
    pop RD4;

    Return_AutoField(0);


////////////////////////////////////////////////////////
//  ����:
//      FFT_fix128
//  ����:
//      FFT����
//      ������ڣ�RN_FFT_COFF_GRAM_ADDR
//  ����:
//      1.RD0:��������ָ�룬��λ16bit��ʽ����
//      2.RD1:�������ָ�룬������ʽ
//  ����ֵ:
//      RD0:����ϵ��
////////////////////////////////////////////////////////
Sub_autofield FFT_fix128;
    push RD4;
    push RA2;

    RA0 = RD0;
    RA1 = RD1;
//FFT ��ַ����
    //��ʼ�� FFT,128��
    //--------------------------------------------------
    //����GRAM����ΪDMA_Ctrl3������GroupΪ��λ
    MemSetPath_Enable;  //����ͨ��ʹ��
    M[RA0+MGRP_PATH3] = RD0;//ѡ��PATH3��ͨ����Ϣ��ƫַ��

    //����LMT����
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    RD0 = 0x4;          //���ݴ���ָ��
    M[RA6+4*MMU_BASE] = RD0;     //LMTдָ��˿�
    //������ص�RAM��128�㸴��ռ��512�ֽڿռ�
    RD0 = DMA_PATH3;
    RD1 = RN_GRAM_BANK_SIZE;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //���ý���

	Sel_SE256FFT;

    //����DMA_Ctrl������������ַ������
    RD0 = RA0;//Դ��ַ
    send_para(RD0);
    RD0 = RA1;//Ŀ���ַ
    send_para(RD0);
    call _DMA_ParaCfg_FFT128_Revs;//��Ŀ��������ר�ú���

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH3;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_FFTRevs;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    //---------------------------------------------------

//Ӳ����ʼ��

    //RAMָ���趨
    RD0 = RN_FFT_COFF_GRAM_ADDR;
    RA2 = RD0;          //FFTϵ����ַ

    RD3 = 0;            //��¼���ű���
    RD4 = -1;            //�������  0������λ
    RD2 = 7;           //�ֽ����  1024:10  512:9

    Sel_PATH3_FFT;
    //�ֽ�ѭ��
L_FFT128_Loop_L0:
    //����GRAM����ΪDMA_Ctrl3������GroupΪ��λ
    MemSetPath_Enable;         //����ͨ��ʹ��
    M[RA1+MGRP_PATH3] = RD0;   //ѡ��PATH3��ͨ����Ϣ��ƫַ��

    //����4KRAMͨ��
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    RD0 = DMA_PATH3;
    RD1 = RN_GRAM_BANK_SIZE;
    M[RA1] = RD0;       //�����ĵ�ַ
    M[RA2] = RD0;       //FFTϵ����ַ
M[RA2+RD1] = RD0;
RD1 = RN_GRAM_BANK_SIZE*2;
M[RA2+RD1] = RD0;
RD1 = RN_GRAM_BANK_SIZE*3;
M[RA2+RD1] = RD0;
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl����
    send_para(RA2);     //FFTϵ����ַ
    send_para(RA1);     //���ݵ�ַ
    send_para(RD4);     //�Ƿ���λ 0������λ
    call _DMA_ParaCfg_FFT128;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH3;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_FFT;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    //---------------------------------------------------

    //�жϲ������������
    RD4 = 0;
    if(RFlag_OverFlowFFT==0) goto L_FFT128_Loop_L1;
    RD3 ++;
    RD4 = -1;
L_FFT128_Loop_L1:

    //���Ʒֽ�ڴ�
    FFT_Next_Round;
    RD2 --;
    if(RQ_nZero) goto L_FFT128_Loop_L0;
	Sel_LE256FFT;
    Dis_PATH3_FFT;

    RD0 = RD3;

    pop RA2;
    pop RD4;

    Return_autofield(0);





////////////////////////////////////////////////////////
//  ����:
//      FFT_fix64
//  ����:
//      64��FFT����
//      ������ڣ�RN_FFT_COFF_GRAM_ADDR
//  ����:
//      1.RD0:��������ָ�룬��λ16bit��ʽ����
//      2.RD1:�������ָ�룬������ʽ
//  ����ֵ:
//      RD0:����ϵ��
////////////////////////////////////////////////////////
sub_autofield FFT_fix64;
    push RD4;
    push RA2;

    RA0 = RD0;
    RA1 = RD1;
//FFT ��ַ����
    //��ʼ�� FFT,128��
    //--------------------------------------------------
    //����GRAM����ΪDMA_Ctrl3������GroupΪ��λ
    MemSetPath_Enable;  //����ͨ��ʹ��
    M[RA0+MGRP_PATH3] = RD0;//ѡ��PATH3��ͨ����Ϣ��ƫַ��

    //����LMT����
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    RD0 = 0x4;          //���ݴ���ָ��
    M[RA6+4*MMU_BASE] = RD0;     //LMTдָ��˿�
    //������ص�RAM��128�㸴��ռ��512�ֽڿռ�
    RD0 = DMA_PATH3;
    RD1 = RN_GRAM_BANK_SIZE;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //���ý���

	Sel_SE256FFT;

    //����DMA_Ctrl������������ַ������
    RD0 = RA0;//Դ��ַ
    send_para(RD0);
    RD0 = RA1;//Ŀ���ַ
    send_para(RD0);
    call _DMA_ParaCfg_FFT64_Revs;//��Ŀ��������ר�ú���

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH3;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_FFTRevs;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    //---------------------------------------------------

//Ӳ����ʼ��

    //RAMָ���趨
    RD0 = RN_FFT_COFF_GRAM_ADDR;
    RA2 = RD0;          //FFTϵ����ַ

    RD3 = 0;            //��¼���ű���
    RD4 = -1;            //�������  0������λ
    RD2 = 6;           //�ֽ����  1024:10  512:9

    Sel_PATH3_FFT;
    //�ֽ�ѭ��
L_FFT64_Loop_L0:
    //����GRAM����ΪDMA_Ctrl3������GroupΪ��λ
    MemSetPath_Enable;         //����ͨ��ʹ��
    M[RA1+MGRP_PATH3] = RD0;   //ѡ��PATH3��ͨ����Ϣ��ƫַ��

    //����4KRAMͨ��
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    RD0 = DMA_PATH3;
    RD1 = RN_GRAM_BANK_SIZE;
    M[RA1] = RD0;       //�����ĵ�ַ
    M[RA2] = RD0;       //FFTϵ����ַ
M[RA2+RD1] = RD0;
RD1 = RN_GRAM_BANK_SIZE*2;
M[RA2+RD1] = RD0;
RD1 = RN_GRAM_BANK_SIZE*3;
M[RA2+RD1] = RD0;
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl����
    send_para(RA2);     //FFTϵ����ַ
    send_para(RA1);     //���ݵ�ַ
    send_para(RD4);     //�Ƿ���λ 0������λ
    call _DMA_ParaCfg_FFT128;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH3;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_FFT;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    //---------------------------------------------------

    //�жϲ������������
    RD4 = 0;
    if(RFlag_OverFlowFFT==0) goto L_FFT64_Loop_L1;
    RD3 ++;
    RD4 = -1;
L_FFT64_Loop_L1:

    //���Ʒֽ�ڴ�
    FFT_Next_Round;
    RD2 --;
    if(RQ_nZero) goto L_FFT64_Loop_L0;
	Sel_LE256FFT;
    Dis_PATH3_FFT;

    RD0 = RD3;

    pop RA2;
    pop RD4;

    return_autofield(0);


////////////////////////////////////////////////////////
//  ��������:
//      FFT_Fast128
//  ��������:
//      128��FFT���㣬����128��ר�ü�����
//  �β�:
//      1.RD0:��������ָ�룬��λ16bit��ʽ����
//      2.RD1:�������ָ�룬������ʽ
//  ����ֵ:
//      RD0:����ϵ��
//  ��ڣ�
//      1.�β�1
//      2.RN_FFT_COFF_GRAM_ADDR
//  ���ڣ�
//      1.�β�2
////////////////////////////////////////////////////////
sub_autofield FFT_Fast128;
    push RD4;
    push RA2;

    RA0 = RD0;
    RA1 = RD1;
    RD0 = FFT128RAM_Addr0;
    RA2 = RD0;

//FFT���ݿ�����ר�û��棬ͬʱ���е�ַ����
    //--------------------------------------------------
    //����GRAM����ΪDMA_Ctrl1������GroupΪ��λ
    MemSetPath_Enable;  //����ͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
	M[RA2+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
    //����ALU1����
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    RD0 = RffC_Add;          //���ݴ���ָ��
    M[RA6+0*MMU_BASE] = RD0;     //ALU1дָ��˿�
    RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1дָ��˿�
    //������ص�RAM��512�㸴��ռ��2K�ֽڿռ�
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA2] = RD0;
	RD1 = 1024;
	M[RA2+RD1] = RD0;
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ������
    RD0 = RA0;//Դ��ַ
    send_para(RD0);
    call _DMA_ParaCfg_FFT128_Write;//��Ŀ��������ר�ú���

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_FFT;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    //---------------------------------------------------

    MemSetRAM4K_Enable;;   //Memory ����ʹ��
	RD0 = DMA_PATH5;
	M[RA2] = RD0;    //                                                               ͨ��ѡ��FFTģ��ˣ�
	RD1 = 1024;
	M[RA2+RD1] = RD0;
	MemSet_Disable;   //���ùر�

	Enable_FFT_Fast128;
	Start_FFT128W;   //FFT��ʼ
	nop; nop;
	Wait_While(RFlag_FFT128End==0);

	//����ͨ��ʹ��
    MemSetPath_Enable;  
    M[RA1+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
	M[RA2+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //������ص�RAM
    RD0 = DMA_PATH1;
    RD1 = RN_GRAM_BANK_SIZE;
    M[RA1] = RD0;
    M[RA2] = RD0;
	RD1 = 1024;
	M[RA2+RD1] = RD0;
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ������
    RD0 = RA1;//Ŀ���ַ
    send_para(RD0);
    call _DMA_ParaCfg_FFT128_Read;//��Ŀ��������ר�ú���

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_FFT;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    //����λ��Ч����λ��0(��HA350B�����ӵ��Ż�����)
    MemSetRAM4K_Enable;
    RD0 = 0b0111;
    RD0 &= FFT128_GAIN;
    RD0 ++;
    MemSet_Disable;
	Disable_FFT_Fast128;
    pop RA2;
    pop RD4;

    Return_autofield(0);




END SEGMENT

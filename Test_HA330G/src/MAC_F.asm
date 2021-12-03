#define _MAC_F_

#include <CPU11.def>
#include <resource_allocation.def>
#include <RN_DSP_Cfg.def>
#include <DMA_ParaCfg.def>
#include <DMA_ALU.def>
#include <Global.def>
#include <MAC.def>

extern _Debug_Memory_File_Bank;

CODE SEGMENT MAC_F;
////////////////////////////////////////////////////////
//  ����:
//      SingleSerSquare
//  ����:
//      ������ƽ������
//  ����:
//      1.RD0:��������ָ�룬����16bit��ʽ
//      2.RD1:�������ָ�룬����16bit��ʽ(out)
//      3.RD2:TimerNumber = (Dword����*3)+3
//  ����ֵֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField SingleSerSquare;
    RA0 = RD0;
    RA1 = RD1;

    //����Ϊ������ƽ������ʾ������
    //--------------------------------------------------
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH2] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //����ALU����
    RD0 = RN_CFG_MAC_TYPE0;//       RN_CFG_MAC_HDMUL+RN_CFG_MAC_QM1M0H16;     //�ӷ�ָ��
    M[RA6+9*MMU_BASE] = RD0;     //ALU1дָ��˿�
    RD0 = 0;
    M[RA6+10*MMU_BASE] = RD0;     //ALU1дConst�˿�
    //������ص�4KRAM
    RD0 = DMA_PATH2;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    RD0 = RA0;//Դ��ַ0
    send_para(RD0);
    RD0 = RA0;//Դ��ַ1
    send_para(RD0);
    RD0 = RA1;//Ŀ���ַ
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_MAC;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH2;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_MAC;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      MultiSum_Init
//  ����:
//      ˫���г��ۼ����㣨����ȡ�ۼӽ����
//  ����:
//      1.RA0:��������1ָ�룬����16bit��ʽ����
//      2.RA1:��������2ָ�룬����16bit��ʽ����
//      3.RD1:�������ָ�룬����16bit��ʽ����(out)
//      4.RD0:TimerNumֵ = (Len*3)+3
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField MultiSum_Init;
    push RA2;
    RD2 = RD0;
    RA2 = RD1;
    //--------------------------------------------------
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH2] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //����ALU����
    RD0 = RN_CFG_MAC_TYPE0ACC;//       RN_CFG_MAC_HDMUL+RN_CFG_MAC_QM1M0M16;     //�ӷ�ָ��
    M[RA6+9*MMU_BASE] = RD0;     //MACдָ��˿�
    RD0 = 0;
    M[RA6+10*MMU_BASE] = RD0;    //MACдConst�˿�
    //������ص�4KRAM
    RD0 = DMA_PATH2;
    M[RA0] = RD0;
    M[RA1] = RD0;
    M[RA2] = RD0;
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    RD0 = RA0;//Դ��ַ0
    send_para(RD0);
    RD0 = RA1;//Դ��ַ1
    send_para(RD0);
    RD0 = RA2;//Ŀ���ַ
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_MAC;//��Ŀ��������ר�ú���

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH2;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_MAC;
    ParaMem_Addr = RD0;

    pop RA2;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      MAC_MultiConst16
//  ����:
//      Ϊ�����г˳�����������DMA_Ctrl����
//  ����:
//      1.M[RSP+3*MMU_BASE]��X(n) �׵�ַ���ֽڵ�ַ��
//      2.M[RSP+2*MMU_BASE]��Const ע��Ҫ���16λ���16λ��ͬ
//      3.M[RSP+1*MMU_BASE]��Z(n) �׵�ַ
//      4.M[RSP+0*MMU_BASE]�����ݳ��ȶ�Ӧ��TimerNumֵ����Ӧ(Len*3)+3
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField MAC_MultiConst16;
    RA0 = M[RSP+3*MMU_BASE];
    RA1 = M[RSP+1*MMU_BASE];
    //--------------------------------------------------
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH2] = RD0;//ѡ��PATH2��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //����MAC����
    RD0 = RN_CFG_MAC_TYPE2;//    //X[n]*CONST/32767
    M[RA6+9*MMU_BASE] = RD0;     //MACдָ��˿�
    RD0 = M[RSP+2*MMU_BASE];     //CONSTΪ16λ���ߵ�16λд��ͬ����
    M[RA6+10*MMU_BASE] = RD0;    //MACдConst�˿�
    //������ص�4KRAM
    RD0 = DMA_PATH2;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    RD1 = M[RSP+0*MMU_BASE];
    RD0 = RA0;//Դ��ַ0
    send_para(RD0);
    RD0 = RA0;//Դ��ַ1
    send_para(RD0);
    RD0 = RA1;//Ŀ���ַ
    send_para(RD0);
    send_para(RD1);//����
    call _DMA_ParaCfg_MAC;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH2;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_MAC;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    Return_AutoField(4*MMU_BASE);


////////////////////////////////////////////////////////
//  ����:
//      MAC_MultiConst24_DivQ7
//  ����:
//      Ϊ�����г˳�����������DMA_Ctrl����������Զ�����Q7������32bit
//  ����:
//      1.M[RSP+3*MMU_BASE]��X(n) �׵�ַ���ֽڵ�ַ��
//      2.M[RSP+2*MMU_BASE]��Const ע��Ҫ���24λ��Const���ݣ���8λ�뱣��ȫ0
//      3.M[RSP+1*MMU_BASE]��Z(n) �׵�ַ
//      4.M[RSP+0*MMU_BASE]�����ݳ��ȶ�Ӧ��TimerNumֵ����Ӧ(Len*3)+3
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField MAC_MultiConst24_DivQ7;
    RA0 = M[RSP+3*MMU_BASE];
    RA1 = M[RSP+1*MMU_BASE];
    //--------------------------------------------------
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH2] = RD0;//ѡ��PATH2��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //����MAC����
    RD0 = RN_CFG_MAC_HDCONST24+RN_CFG_MAC_QM1L32;    //X[n]*CONST/Q7
    M[RA6+9*MMU_BASE] = RD0;     //MACдָ��˿�
    RD0 = M[RSP+2*MMU_BASE];     //CONST
    M[RA6+10*MMU_BASE] = RD0;    //MACдConst�˿�

    //������ص�4KRAM
    RD0 = DMA_PATH2;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    RD1 = M[RSP+0*MMU_BASE];
    RD0 = RA0;//Դ��ַ0
    send_para(RD0);
    RD0 = RA0;//Դ��ַ1
    send_para(RD0);
    RD0 = RA1;//Ŀ���ַ
    send_para(RD0);
    send_para(RD1);//����
    call _DMA_ParaCfg_MAC;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH2;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_MAC;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    Return_AutoField(4*MMU_BASE);



////////////////////////////////////////////////////////
//  ����:
//      MAC_MultiConst16_Q2207
//  ����:
//      Ϊ�����г˳�����������DMA_Ctrl����
//  ����:
//      1.M[RSP+3*MMU_BASE]��X(n) �׵�ַ���ֽڵ�ַ��
//      2.M[RSP+2*MMU_BASE]��Const ע��Ҫ���16λ���16λ��ͬ
//      3.M[RSP+1*MMU_BASE]��Z(n) �׵�ַ
//      4.M[RSP+0*MMU_BASE]�����ݳ��ȶ�Ӧ��TimerNumֵ����Ӧ(Len*3)+3
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField MAC_MultiConst16_Q2207;
    RA0 = M[RSP+3*MMU_BASE];
    RA1 = M[RSP+1*MMU_BASE];
    //--------------------------------------------------
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH2] = RD0;//ѡ��PATH2��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //����MAC����
    RD0 = RN_CFG_MAC_TYPE3L;//    //X[n]*CONST/32767
    M[RA6+9*MMU_BASE] = RD0;     //MACдָ��˿�
    RD0 = M[RSP+2*MMU_BASE];     //CONSTΪ16λ���ߵ�16λд��ͬ����
    M[RA6+10*MMU_BASE] = RD0;    //MACдConst�˿�
    //������ص�4KRAM
    RD0 = DMA_PATH2;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    RD1 = M[RSP+0*MMU_BASE];
    RD0 = RA0;//Դ��ַ0
    send_para(RD0);
    RD0 = RA0;//Դ��ַ1
    send_para(RD0);
    RD0 = RA1;//Ŀ���ַ
    send_para(RD0);
    send_para(RD1);//����
    call _DMA_ParaCfg_MAC;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH2;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_MAC;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    Return_AutoField(4*MMU_BASE);



////////////////////////////////////////////////////////
//  ����:
//      ModulationToZero
//  ����:
//      ����
//  ����:
//      1.RA0:���ַ
//      2.RA1:��������ַ
//      3.RD1:Ŀ���ַ
//      4.RD0:���ݳ��ȶ�Ӧ��TimerNumֵ(Dword����*3+3)
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField ModulationToZero;
    push RA2;
    RA2 = RD1;
    RD2 = RD0;
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH2] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //����ALU����
    RD0 = RN_CFG_MAC_TYPE1;//       RN_CFG_MAC_HDMODU+RN_CFG_MAC_QM1M0H16
    M[RA6+9*MMU_BASE] = RD0;     //ALU1дָ��˿�
    RD0 = 0;
    M[RA6+10*MMU_BASE] = RD0;     //ALU1дConst�˿�
    //������ص�4KRAM
    RD0 = DMA_PATH2;
    M[RA0] = RD0;
    M[RA1] = RD0;
    M[RA2] = RD0;
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    RD0 = RA0;//Դ��ַ0
    send_para(RD0);
    RD0 = RA1;//Դ��ַ1
    send_para(RD0);
    RD0 = RA2;//Ŀ���ַ
    send_para(RD0);
    send_para(RD2);//����
    call _DMA_ParaCfg_MAC;//��Ŀ��������ר�ú���

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH2;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_MAC;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    pop RA2;
    Return_AutoField(0);


////////////////////////////////////////////////////////
//  ����:
//      MultiConstH16L16
//  ����:
//      ������Const�������
//  ����:
//      RA0:��������1ָ�룬����16bit��ʽ����
//      RA1:�������ָ�룬����16bit��ʽ����(out)
//      RD1:Constֵ
//      RD0:TimerNumֵ = (Len*3)+3
//  ����ֵ:
//      RD0:���ۼӽ��
////////////////////////////////////////////////////////
Sub_AutoField MultiConstH16L16;
    RD2 = RD0;
    RD3 = RD1;
    //--------------------------------------------------
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH2] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //����ALU����
    RD0 = RN_CFG_MAC_TYPE2;//RN_CFG_MAC_HDCONST16+RN_CFG_MAC_QM1M0H16//X[n]*CONST
    M[RA6+9*MMU_BASE] = RD0;     //MACдָ��˿�
    RD0 = RD3;
    M[RA6+10*MMU_BASE] = RD0;     //MACдConst�˿�
    //������ص�4KRAM
    RD0 = DMA_PATH2;
    M[RA0] = RD0;
    M[RA1] = RD0;
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    send_para(RA0);//Դ��ַ0
    send_para(RA0);//Դ��ַ1���ղ���
    send_para(RA1);//Ŀ���ַ
    send_para(RD2);//����ֵ
    call _DMA_ParaCfg_MAC;//��Ŀ��������ר�ú���

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH2;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_MAC;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    //---------------------------------------------------
    Return_AutoField(0);


END SEGMENT

#define _ALU_F_

#include <CPU11.def>
#include <resource_allocation.def>
#include <RN_DSP_Cfg.def>
#include <DMA_ParaCfg.def>
#include <DMA_ALU.def>
#include <ALU.def>
#include <Global.def>

CODE SEGMENT ALU_F;
////////////////////////////////////////////////////////
//  ����:
//      DMA_Trans_AD
//  ����:
//      ��ADC��������ȡ������
//  ����:
//      1.RD0:Դָ��
//      2.RD1:Ŀ��ָ��(out)
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField DMA_Trans_AD;
    // ��AD_Buf���ӵ�PATH1
    // ����Group��PATH������
    RA0 = RD0;
    RA1 = RD1;
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
    M[RA1+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    // ��AD_Buf0���ӵ�PATH1
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;

    //����ALU����
    RD0 = Op32Bit;      //ALU����λ��ѡ��Ϊ32λ
    RD0 += RffC_Add;    //�ӷ�ָ��
    M[RA6+0*MMU_BASE] = RD0;     //ALU1дָ��˿�
    RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1дConst�˿�
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    send_para(RA0);//Դ��ַ0
    send_para(RA1);//Ŀ���ַ
    RD0 = FL_M2_A4;
    send_para(RD0);
    call _DMA_ParaCfg_AD_Copy;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    Return_AutoField(0);





////////////////////////////////////////////////////////
//  ����:
//      Ram_Clr
//  ����:
//      ���ָ����GRAM��
//  ����:
//      1.RA1:ָ����GRAM���ַ(out)
//      2.RA0:���õĵ�ַ������ָ����һ��Group
//      3.RD1:TimerNumֵ = (Dword����*1)+2
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField Ram_Clr;
    RD2 = RD1;

    MemSetPath_Enable;      //Դ��ַ����ͨ��ʹ��
    M[RA0+DMA_PATH1] = RD0;

    MemSetAutoAddr_Enable;  //Ŀ���ַ����Autoʹ�ܣ�ͬʱGroupͨ��ʹ��
    RD0 = RA1;              //Ŀ���ַ
    RF_ShiftR2(RD0);        //Dword ��ַ
    RF_Not(RD0);            //Ӳ����λԭ��Ҫ��Ե�ַȡ��д��
    M[RA1] = RD0;           //����Auto��ַ��ֻ����ΪĿ���ַ
    MemSet_Disable;         //����Autoʱ�������д˾䣬����set_addr�ź�

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //����ALU����
    RD0 = Op32Bit;      //ALU����λ��ѡ��Ϊ32λ
    RD0 += Rf_Const; //Rf_PassFast; //
    M[RA6+0*MMU_BASE] = RD0;     //ALU1дָ��˿�
    RD0 = 0x1122aabb;            //д�볣������Ч��������ɾ����δʵ�飩
    M[RA6+1*MMU_BASE] = RD0;     //ALU1дConst�˿ڣ���Ч��������ɾ����δʵ�飩
    //������ص�4KRAM
    RD0 = DMA_PATH1;
    M[RA1] = RD0;
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    RD0 = RA0;//Դ��ַ
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_Clear;//Auto��������ר�ú���

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;

    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    Return_AutoField(0);


////////////////////////////////////////////////////////
//  ����:
//      Dual_Ser_Add32
//  ����:
//      ˫���мӷ����㣬32bit����
//  ����:
//      1.RA0:��������1ָ�룬32bit��ʽ����(out)
//      2.RA1:��������2ָ�룬32bit��ʽ����
//      3.RD0:TimerNumֵ = (����Dword����*3)+4
//  ����ֵ:
//      1.RD0:��
////////////////////////////////////////////////////////
Sub_AutoField Dual_Ser_Add32;
    RD2 = RD0;
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH2��ͨ����Ϣ��ƫַ��
    M[RA1+MGRP_PATH1] = RD0;//ѡ��PATH2��ͨ����Ϣ��ƫַ��
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //������ص�4KRAM
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;
    //����ALU����
    RD0 = Op32Bit;      //ALU����λ��ѡ��Ϊ32λ
    RD0 += Rff_Add;
    M[RA6+0*MMU_BASE] = RD0;     //ALU1дָ��˿�
    RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1дConst�˿�
    MemSet_Disable;     //���ý���
    //����DMA_Ctrl������������ַ.����
    send_para(RA0);//Դ��ַ0
    send_para(RA1);//Դ��ַ1
    send_para(RA0);//Ŀ���ַ
    send_para(RD2);
    call _DMA_ParaCfg_Rff;
    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
    Return_AutoField(0);

////////////////////////////////////////////////////////
//  ����:
//      Dual_Ser_Sub32
//  ����:
//      ˫���м������㣬32bit����
//  ����:
//      1.RA0:��������1ָ�룬32bit��ʽ����
//      2.RA1:��������2ָ�룬32bit��ʽ����
//      3.RD1:�������ָ�룬32bit��ʽ����(out)
//      4.RD0:TimerNumֵ = (����Dword����*3)+4
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField Dual_Ser_Sub32;
    push RA2;
    RD2 = RD0;
    RA2 = RD1;
    //--------------------------------------------------
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
    M[RA1+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
    M[RA2+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //����ALU����
    RD0 = Op32Bit;      //ALU����λ��ѡ��Ϊ32λ
    RD0 += Rff_Sub;     //����ָ��
    M[RA6+0*MMU_BASE] = RD0;     //ALU1дָ��˿�
    RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1дConst�˿�

    //������ص�4KRAM
    RD0 = DMA_PATH1;
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
    call _DMA_ParaCfg_Rff;//��Ŀ��������ר�ú���

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    pop RA2;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      Cal_Single_Shift
//  ����:
//      ��������λ���㣬���ÿ�ѡ
//  ����:
//      1.RD0:����λ��+��λ���� (��:Op32bit+Rf_SftR1)
//      2.RD1:TimerNumֵ = (��������Dword����*2)+4
//      3.RA0:��������ָ��(out)
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField Cal_Single_Shift;
    RD3 = RD0;
    RD2 = RD1;
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH2] = RD0;//ѡ��PATH2��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //������ص�4KRAM
    RD0 = DMA_PATH2;
    M[RA0] = RD0;

    //����ALU����
    M[RA6+2*MMU_BASE] = RD3;     //ALU1дָ��˿�
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

    Return_AutoField(0);









////////////////////////////////////////////////////////
//  ����:
//      Add_LMT
//  ����:
//      ˫���мӷ����㣨�޷���16bit����32bit����
//  ����:
//      1.RA0:��������1ָ�룬32bit��ʽ����
//      2.RA1:��������2ָ�룬32bit��ʽ����
//      3.RD1:�������ָ�룬32bit��ʽ����(out)
//      4.RD0:TimerNumֵ = (����Dword����*3)+4
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField Add_LMT;
    push RA2;
    RD2 = RD0;
    RA2 = RD1;
    //--------------------------------------------------
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH3] = RD0;//ѡ��PATH3��ͨ����Ϣ��ƫַ��
    M[RA1+MGRP_PATH3] = RD0;//ѡ��PATH3��ͨ����Ϣ��ƫַ��
    M[RA2+MGRP_PATH3] = RD0;//ѡ��PATH3��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //������ص�4KRAM
    RD0 = DMA_PATH3;
    M[RA0] = RD0;
    M[RA1] = RD0;
    M[RA2] = RD0;

    //����ALU����
    RD0 = 0;
    M[RA6+4*MMU_BASE] = RD0;     //ALU3дָ��˿�
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    RD0 = RA0;//Դ��ַ0
    send_para(RD0);
    RD0 = RA1;//Դ��ַ1
    send_para(RD0);
    RD0 = RA2;//Ŀ���ַ
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_Rff;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH3;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    pop RA2;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      Sub_LMT
//  ����:
//      ˫���м������㣨�޷���16bit����32bit����
//  ����:
//      1.RA0:��������1ָ�룬32bit��ʽ����
//      2.RA1:��������2ָ�룬32bit��ʽ����
//      3.RD1:�������ָ�룬32bit��ʽ����(out)
//      4.RD0:TimerNumֵ = (����Dword����*3)+4
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField Sub_LMT;
    push RA2;
    RD2 = RD0;
    RA2 = RD1;
    //--------------------------------------------------
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH3] = RD0;//ѡ��PATH3��ͨ����Ϣ��ƫַ��
    M[RA1+MGRP_PATH3] = RD0;//ѡ��PATH3��ͨ����Ϣ��ƫַ��
    M[RA2+MGRP_PATH3] = RD0;//ѡ��PATH3��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    //������ص�4KRAM
    RD0 = DMA_PATH3;
    M[RA0] = RD0;
    M[RA1] = RD0;
    M[RA2] = RD0;

    //����ALU����
    RD0 = 1;
    M[RA6+4*MMU_BASE] = RD0;     //ALU3дָ��˿�
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    RD0 = RA0;//Դ��ַ0
    send_para(RD0);
    RD0 = RA1;//Դ��ַ1
    send_para(RD0);
    RD0 = RA2;//Ŀ���ַ
    send_para(RD0);
    send_para(RD2);
    call _DMA_ParaCfg_Rff;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH3;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);

    pop RA2;
    Return_AutoField(0);




////////////////////////////////////////////////////////
//  ����:
//      DMA_Trans
//  ����:
//      DMA��������
//  ����:
//      1.RA0:Դ��ַ
//      2.RA1:Ŀ���ַ(out)
//      3.RD0:���ݳ��ȶ�Ӧ��TimerNumֵ����Ӧ(Dword����*2)+4
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField DMA_Trans;
    // ��AD_Buf���ӵ�PATH1
    // ����Group��PATH������
    RD2 = RD0;
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
    M[RA1+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    // ��AD_Buf0���ӵ�PATH1
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;

    //����ALU����
    RD0 = Op32Bit;      //ALU����λ��ѡ��Ϊ32λ
    RD0 += RffC_Add;    //�ӷ�ָ��
    M[RA6+0*MMU_BASE] = RD0;     //ALU1дָ��˿�
    RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1дConst�˿�
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    send_para(RA0);//Դ��ַ0
    send_para(RA1);//Ŀ���ַ
    send_para(RD2);
    call _DMA_ParaCfg_RffC;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
//Set_LevelL8;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
//Set_LevelH8;

    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      Cal_Single_Add_Const
//  ����:
//      �����мӳ���
//  ����:
//      1.RD1:Const
//      2.RA0:Դ��ַ
//      3.RA1:Ŀ���ַ(out)
//      4.RD0:���ݳ��ȶ�Ӧ��TimerNumֵ����Ӧ(Dword����*2)+4
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField Cal_Single_Add_Const;
    // ��AD_Buf���ӵ�PATH1
    // ����Group��PATH������
    RD2 = RD0;
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
    M[RA1+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    // ��AD_Buf0���ӵ�PATH1
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;

    //����ALU����
    RD0 = Op16Bit;      //ALU����λ��ѡ��Ϊ16λ
    RD0 += RffC_Add;    //�ӷ�ָ��
    M[RA6+0*MMU_BASE] = RD0;     //ALU1дָ��˿�
    RD0 = RD1;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1дConst�˿�
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ.����
    send_para(RA0);//Դ��ַ0
    send_para(RA1);//Ŀ���ַ
    send_para(RD2);
    call _DMA_ParaCfg_RffC;

    //ѡ��DMA_Ctrlͨ��������������
    RD0 = DMA_PATH1;
    ParaMem_Num = RD0;
    RD0 = DMA_nParaNum_ALU;
    ParaMem_Addr = RD0;
//Set_LevelL8;
    Wait_While(Flag_DMAWork==1);
    nop; nop;
    Wait_While(Flag_DMAWork==0);
//Set_LevelH8;

    Return_AutoField(0);

////////////////////////////////////////////////////////
//  ��������:
//      DMA_Trans_PATH1
//  ��������:
//      DMA��������
//  ��ڲ���:
//      RA0:Դ��ַ
//      RA1:Ŀ���ַ
//      RD0:���ݳ��ȶ�Ӧ��TimerNumֵ����Ӧ(Dword����*2)+4
//  ���ڲ���:
//      ��
////////////////////////////////////////////////////////
sub_autofield DMA_Trans_PATH1;
    // ��AD_Buf���ӵ�PATH1
    // ����Group��PATH������
    RD2 = RD0;
    MemSetPath_Enable;  //����Groupͨ��ʹ��
    M[RA0+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��
    M[RA1+MGRP_PATH1] = RD0;//ѡ��PATH1��ͨ����Ϣ��ƫַ��

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    // ��AD_Buf0���ӵ�PATH1
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    M[RA1] = RD0;

    //����ALU����
    RD0 = Op32Bit;      //ALU����λ��ѡ��Ϊ32λ
    RD0 += RffC_Add;    //�ӷ�ָ��
    M[RA6+0*MMU_BASE] = RD0;     //ALU1дָ��˿�
    RD0 = 0;
    M[RA6+1*MMU_BASE] = RD0;     //ALU1дConst�˿�
    MemSet_Disable;     //���ý���

    //����DMA_Ctrl������������ַ������
    send_para(RA0);//Դ��ַ0
    send_para(RA1);//Ŀ���ַ
    send_para(RD2);
    //call _DMA_ParaCfg_AD_Copy;
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


END SEGMENT

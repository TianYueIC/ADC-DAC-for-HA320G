#define _GLOBAL_F_

#include <CPU11.def>
#include <resource_allocation.def>
#include <RN_DSP_Cfg.def>
#include <DMA_ParaCfg.def>
#include <DMA_ALU.def>
#include <Global.def>
#include <SOC_Common.def>
#include <Global.def>
#include <ALU.def>
#include <USI.def>
#include <SPI_Master.def>

CODE SEGMENT GLOBAL_F;
////////////////////////////////////////////////////////
//  ����:
//      RAM_Read_Word
//  ����:
//      ���ڶ�ȡ16�������ݣ�����MMU����
//  ����:
//      1.RD0:���ݵ�ַ
//  ����ֵ:
//      1.RD0:16��������
////////////////////////////////////////////////////////
Sub RAM_Read_Word;
    push RA0;
    RA0 = RD0;
    if(RD0_Bit1==1) goto L_RAM_Read_Word_1;
    RD0 = M[RA0];
    RF_GetL16(RD0);
    goto L_RAM_Read_Word_End;

L_RAM_Read_Word_1:
    RD0 = M[RA0];
    RF_GetH16(RD0);

L_RAM_Read_Word_End:
    RD0_SignExtL16;
    pop RA0;
    Return(0);



////////////////////////////////////////////////////////
//  ����:
//      BaseROM_Read_Word
//  ����:
//      ��ConstROM���ڶ�ȡ16�������ݣ�����MMU����
//  ����:
//      1.RD0:���ݵ�ַ(�ֽڵ�ַ)
//  ����ֵ:
//      1.RD0:16��������
////////////////////////////////////////////////////////
Sub ConstROM_Read_Word;
    push RA0;

    push RD0;
    RD0_ClrByteH8;
    RF_ShiftR2(RD0);
    RD0 += 0xD0000000;
    RA0 = RD0;
    RD1 = M[RA0];
    pop RD0;
    if(RD0_Bit1==1) goto L_ConstROM_Read_Word_1;
    RF_GetL16(RD1);
    goto L_ConstROM_Read_Word_End;

L_ConstROM_Read_Word_1:
    RF_GetH16(RD1);

L_ConstROM_Read_Word_End:
    RD0 = RD1;
    RD0_SignExtL16;
    pop RA0;
    Return(0);



////////////////////////////////////////////////////////
//  ����:
//      SetADBuf0_Flow
//  ����:
//      ��AD_Buf0�л�Flowͨ��
//  ����:
//      ��
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField SetADBuf0_Flow;
    //����Flow_RAMΪDMA_Flow����
    MemSetRAM4K_Enable;  //Set_All
    RD0 = FlowRAM_Addr0;
    RA0 = RD0;
    RD0 = DMA_PATH5;
    M[RA0] = RD0;
    MemSet_Disable; //Set_All
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      SetADBuf1_Flow
//  ����:
//      ��AD_Buf0�л�Flowͨ��
//  ����:
//      ��
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField SetADBuf1_Flow;
    //����Flow_RAMΪDMA_Flow����
    MemSetRAM4K_Enable;  //Set_All
    RD0 = FlowRAM_Addr1;
    RA0 = RD0;
    RD0 = DMA_PATH5;
    M[RA0] = RD0;
    MemSet_Disable; //Set_All
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      En_GRAM_To_CPU
//  ����:
//      ��GRAM����ΪCPU����ģʽ
//  ����:
//      1.RD0:��Ҫ���õ�GRAM��ַ
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField En_GRAM_To_CPU;
    RA0 = RD0;

    // RD1 = ����λ����
    RD1 = 0xF0;
    RF_RotateR8(RD1);
    
    // �жϵ�ַ�����Ƿ�Ϸ���Ƭѡ��ַ����=2�����Ƿ�ʱ�Թ�������
    RD1 &= RD0;
    RD0 = 0x20000000;
    RD1 ^= RD0;
    if(RQ_nZero) goto L_En_GRAM_To_CPU_End;

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
    RD0 = DMA_PATH0;
    M[RA0] = RD0;
    MemSet_Disable;     //���ý���
    CPU_WorkEnable;
    
L_En_GRAM_To_CPU_End:    
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      En_AllRAM_To_CPU
//  ����:
//      ������GRAM��XRAM����ΪCPU����ģʽ
//  ����:
//      ��
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField En_AllRAM_To_CPU;
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
    RD0 = DMA_PATH0;

    RD1 = RN_GRAM0;
    RA0 = RD1;
    RD1 = RN_GRAM_BANK_SIZE;
    RD2 = 24;
L_En_AllRAM_To_CPU_Loop:
    M[RA0] = RD0;
    RA0 += RD1;
    RD2 --;
    if(RQ_nZero) goto L_En_AllRAM_To_CPU_Loop;

//  RD1 = FlowRAM_Addr0;
//  RA0 = RD1;
//  M[RA0] = RD0;
//  RD1 = FlowRAM_Addr1;
//  RA0 = RD1;
//  M[RA0] = RD0;

    MemSet_Disable;     //���ý���
    CPU_WorkEnable;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      En_AllFlowRAM_To_CPU
//  ����:
//      ������FlowRAM����ΪCPU����ģʽ
//  ����:
//      ��
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField En_AllFlowRAM_To_CPU;
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
    RD0 = DMA_PATH0;

	RD1 = FlowRAM_Addr0;
    RA0 = RD1;
    M[RA0] = RD0;
    RD1 = FlowRAM_Addr1;
    RA0 = RD1;
    M[RA0] = RD0;

    MemSet_Disable;     //���ý���
    CPU_WorkEnable;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      En_AllGRAM_To_CPU
//  ����:
//      ������GRAM����ΪCPU����ģʽ
//  ����:
//      ��
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField En_AllGRAM_To_CPU;
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
    RD0 = DMA_PATH0;

    RD1 = RN_GRAM0;
    RA0 = RD1;
    RD1 = RN_GRAM_BANK_SIZE;
    RD2 = 16;
L_En_AllGRAM_To_CPU_Loop:
    M[RA0] = RD0;
    RA0 += RD1;
    RD2 --;
    if(RQ_nZero) goto L_En_AllGRAM_To_CPU_Loop;

    MemSet_Disable;     //���ý���
    CPU_WorkEnable;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      En_AllXRAM_To_CPU
//  ����:
//      ������XRAM����ΪCPU����ģʽ
//  ����:
//      ��
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField En_AllXRAM_To_CPU;
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
    RD0 = DMA_PATH0;

    RD1 = RN_XRAM0;
    RA0 = RD1;
    RD1 = RN_XRAM_BANK_SIZE;
    RD2 = 8;
L_En_AllXRAM_To_CPU_Loop:
    M[RA0] = RD0;
    RA0 += RD1;
    RD2 --;
    if(RQ_nZero) goto L_En_AllXRAM_To_CPU_Loop;

    MemSet_Disable;     //���ý���
    CPU_WorkEnable;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      En_RAM_To_PATHx
//  ����:
//      ������GRAM��XRAM����Ϊָ����PATH(��PATH0����)
//  ����:
//      1.RA0:������ʼ��
//      2.RD0:���ÿ�����
//      3.RD1:DMA_PATH1~4
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField En_RAM_To_PATHx;

    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
    RD2 = RD0;
    RD0 = RN_GRAM_BANK_SIZE;
L_En_RAM_To_PATHx_Loop:
    M[RA0] = RD1;
    RA0 += RD0;
    RD2 --;
    if(RQ_nZero) goto L_En_RAM_To_PATHx_Loop;

    MemSet_Disable;     //���ý���
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      En_RAM_To_PATH1
//  ����:
//      ��ָ����GRAM��XRAM����PATH1
//  ����:
//      1.RD0:���õ�ַ
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField En_RAM_To_PATH1;
    RA0 = RD0;
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    MemSet_Disable;     //���ý���
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      En_RAM_To_PATH2
//  ����:
//      ��ָ����GRAM��XRAM����PATH2
//  ����:
//      1.RD0:���õ�ַ
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField En_RAM_To_PATH2;
    RA0 = RD0;
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    RD0 = DMA_PATH2;
    M[RA0] = RD0;
    MemSet_Disable;     //���ý���
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      En_RAM_To_PATH3
//  ����:
//      ��ָ����GRAM��XRAM����PATH3
//  ����:
//      1.RD0:���õ�ַ
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField En_RAM_To_PATH3;
    RA0 = RD0;
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
    RD0 = DMA_PATH3;
    M[RA0] = RD0;
    MemSet_Disable;     //���ý���
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      Dis_GRAM_To_CPU
//  ����:
//      ��GRAM��CPU�Ͽ�
//  ����:
//      ��
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField Dis_GRAM_To_CPU;
    CPU_WorkDisable;
    Clr_CfgGRAM;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      CPU_Copy
//  ����:
//      CPU��������
//  ����:
//      1.RA0:Դ��ַ
//      2.RA1:Ŀ���ַ
//      3.RD0:Dword����
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField CPU_Copy;

    RD2 = RD0;
L_CPU_Copy_Loop:
    RD0 = M[RA0++];
    M[RA1++] = RD0;
    RD2 --;
    if(RQ_nZero) goto L_CPU_Copy_Loop;

    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  ����:
//      Clr_RAM
//  ����:
//      ��GRam��XDRam����
//  ����:
//      ��
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField Clr_RAM;
    RD2 = 16;
    RD0 = RN_GRAM0;
    RA1 = RD0;
L_Clr_RAM_Loop:
    RD0 = RN_XRAM0;
    RA0 = RD0;
    //RD1 = 0xb14e9d1;// 1024*1+2
    RD1 = 0x48635339;// 256*1+2
    call Ram_Clr;
    RD0 = RN_GRAM_BANK_SIZE;
    RA1 += RD0;
    RD2 --;
    if(RQ_nZero) goto L_Clr_RAM_Loop;

    RD2 = 8;
    RD0 = RN_XRAM0;
    RA1 = RD0;
L_Clr_XRAM_Loop:
    RD0 = RN_GRAM0;
    RA0 = RD0;
    //RD1 = 0xb14e9d1;// 1024*1+2
    RD1 = 0x48635339;// 256*1+2
    call Ram_Clr;
    RD0 = RN_XRAM_BANK_SIZE;
    RA1 += RD0;
    RD2 --;
    if(RQ_nZero) goto L_Clr_XRAM_Loop;

    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      Import_Sound_16bit
//  ����:
//      ��16bit��ʽ����������Ƶ
//  ����:
//      1.RD0:�����׵�ַ(out)
//      2.RD1:���ݳ���(��λ���ֽڣ�����4��������)
//  ����ֵ��
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Import_Sound_16bit;
    RD2 = RD1;
    RA0 = RD0;
    call En_GRAM_To_CPU;
    RD0 = COM1;
    RD1 = RD2;
    call SPI_Master_Gets_Prot;
    call Dis_GRAM_To_CPU;
    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      Export_Sound_16bit
//  ����:
//      ��16bit��ʽ����������Ƶ
//  ����:
//      1.RD0:�����׵�ַ
//      2.RD1:���ݳ���(��λ���ֽڣ�����4��������)
//  ����ֵ��
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Export_Sound_16bit;
    RD2 = RD1;
    RD3 = RD0;

    // ���Ͱ�ͷ
    RSP -= 2*MMU_BASE;
    RD0 = 0x80017fff;
    M[RSP] = RD0;
    RD0 = 0x00020000;
    RD0 += RD2;
    M[RSP+1*MMU_BASE] = RD0;
    RD0 = COM1;
    RD1 = 2*MMU_BASE;
    RA0 = RSP;
    call SPI_Master_Puts;
    RSP += 2*MMU_BASE;


    RD0 = RD3;
    RA0 = RD0;
    call En_GRAM_To_CPU;
    RD0 = COM1;
    RD1 = RD2;
    call SPI_Master_Puts_Prot;
    call Dis_GRAM_To_CPU;
    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      Export_Data_32bit
//  ����:
//      ��32bit��ʽ�����ؼ����ݣ�Ϊ�����ܹ���������Ƶ������ȡ�ؼ����ݣ�
//      ÿ������ǰ��������Dword��Ϊ��ͷ���̶�ֵ0x80017fff(��16KHz�������£�������Ƶ������ִ�ֵ)�ͳ���(��λ���ֽڣ�����4��������)
//  ����:
//      1.RD0:�����׵�ַ
//      2.RD1:���ݳ���(��λ���ֽڣ�����4��������)
//  ����ֵ��
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Export_Data_32bit;
    RD2 = RD1;
    RD3 = RD0;

    // ���Ͱ�ͷ
    RSP -= 2*MMU_BASE;
    RD0 = 0x80017fff;
    M[RSP] = RD0;
    M[RSP+1*MMU_BASE] = RD2;
    RD0 = COM1;
    RD1 = 2*MMU_BASE;
    RA0 = RSP;
    call SPI_Master_Puts;
    RSP += 2*MMU_BASE;

    // ���͹ؼ�����
    RD0 = RD3;
    call En_GRAM_To_CPU;
    RD0 = RD3;
    RA0 = RD0;
    RD0 = COM1;
    RD1 = RD2;
    call SPI_Master_Puts;
    call Dis_GRAM_To_CPU;
    Return_AutoField(0);


//////////////////////////////////////////////////////////////////////////
//  ����:
//      Export_Vector_32bit
//  ����:
//      ��32bit��ʽ�����ؼ�����(����)��Ϊ�����ܹ���������Ƶ������ȡ�ؼ����ݣ�
//      ÿ������ǰ��������Dword��Ϊ��ͷ���̶�ֵ0x80017fff(��16KHz�������£�������Ƶ������ִ�ֵ)�ͳ���(��λ���ֽڣ�����4��������)
//  ����:
//      1.RD0:�����׵�ַ
//      2.RD1:���ݳ���(��λ���ֽڣ�����4��������)
//  ����ֵ��
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Export_Vector_32bit;
    RD2 = RD1;
    RD3 = RD0;

    // ���Ͱ�ͷ
    RSP -= 2*MMU_BASE;
    RD0 = 0x80017fff;
    M[RSP] = RD0;
    RD0 = 0x00010000;
    RD0 += RD2;
    M[RSP+1*MMU_BASE] = RD0;
    RD0 = COM1;
    RD1 = 2*MMU_BASE;
    RA0 = RSP;
    call SPI_Master_Puts;
    RSP += 2*MMU_BASE;

    // ���͹ؼ�����
    RD0 = RD3;
    call En_GRAM_To_CPU;
    RD0 = RD3;
    RA0 = RD0;
    RD0 = COM1;
    RD1 = RD2;
    call SPI_Master_Puts;
    call Dis_GRAM_To_CPU;
    Return_AutoField(0);

END SEGMENT

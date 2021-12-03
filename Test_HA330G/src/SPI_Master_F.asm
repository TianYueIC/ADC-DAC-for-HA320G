#define _SPI_MASTER_F_

#include <CPU11.def>
#include <SOC_Common.def>
#include <USI.def>
#include <gpio.def>

CODE SEGMENT SPI_MASTER_F;
//////////////////////////////////////////////////////////////////////////
//  ����:
//      SPI_Master_Init
//  ����:
//      ��USI����ΪSPI����
//  ����:
//      1.RD0:�˿ں�COM0/COM1
//      2.RD1:ʱ�ӷ�Ƶ����ֵ = F(��Ƶ/SCKƵ��/2)
//  ����ֵ��
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField SPI_Master_Init;
    Set_IntASM_Dis;
    USI_Num = RD0;
    USI_Disable;
    USI_SelPort = Config_Port;
    RD0 = 0b100010100000010; // ����������������������������
    USI_Data = RD0;
    USI_Enable;
    USI_SelPort = Counter1_Port;
    
RF_Not(RD1);    
    
    USI_Data = RD1; // ����ʱ�Ӽ���ֵ
    USI_SelPort = Data_Port;
    USI_SelPort = Counter2_Port;
    RD0 = 0x80000000;
    USI_Data = RD0; // ������������Ϊ32λģʽ
    USI_SelPort = Data_Port;
    Set_IntASM_En;
    Return_AutoField(0*MMU_BASE);
    
    
    
//////////////////////////////////////////////////////////////////////////
//  ����:
//      SPI_Master_Puts
//  ����:
//      ��������ָ�����ȵ����ݣ�Ϊ����ؼ����ݣ���16bit���з���
//  ����:
//      1.RD0:�˿ں�COM0/COM1
//      2.RD1:����(��λ���ֽڣ�����4��������)
//      3.RA0:�����׵�ַ
//  ����ֵ��
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField SPI_Master_Puts;
    Set_IntASM_Dis;
    USI_Num = RD0;
    USI_EnableTx;
    RF_ShiftR2(RD1);
    RD2 = RD1;                          // DW����

//// cs ����
//RD0 = GP0_4;
//GPIO_WEn0 = RD0;
//RD0 = 0;
//GPIO_Data0 = RD0;

    RD0 = M[RA0++];
    RF_Reverse(RD0);
    USI_Data = RD0;
    RD2 -= 1;                           // дX
    if(RQ_Zero) goto L_SPI_Master_Puts_End;

L_SPI_Master_Puts_Loop:
    RD0 = M[RA0++];
    RF_Reverse(RD0);
    USI_Data = RD0;                     // дX+1

L_SPI_Master_Puts_Loop_Wait:            // ��X
    if(USI_Flag==0) goto L_SPI_Master_Puts_Loop_Wait;
    RD2 -= 1;
    if(RQ_nZero) goto L_SPI_Master_Puts_Loop;
    RD0 = USI_Data;                     // ��������ڶ����ı�־

L_SPI_Master_Puts_End:                  // ��X+1
    if(USI_Flag==0) goto L_SPI_Master_Puts_End;


//// cs ����
//RD0 = GP0_4;
//GPIO_WEn0 = RD0;
//RD0 = GP0_4;
//GPIO_Data0 = RD0;

    USI_DisTxRx;
    Set_IntASM_En;
    Return_AutoField(0*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      SPI_Master_Puts_Prot
//  ����:
//      ��������ָ�����ȵ����ݣ�Ϊ���������Ƶ����16bit���з���
//  ����:
//      1.RD0:�˿ں�COM0/COM1
//      2.RD1:����(��λ���ֽڣ�����4��������)
//      3.RA0:�����׵�ַ
//  ����ֵ��
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField SPI_Master_Puts_Prot;
    Set_IntASM_Dis;
    USI_Num = RD0;
    USI_EnableTx;
    RF_ShiftR2(RD1);
    RD2 = RD1;                          // DW����

//// cs ����
//RD0 = GP0_4;
//GPIO_WEn0 = RD0;
//RD0 = 0;
//GPIO_Data0 = RD0;

    RD0 = M[RA0++];
    RF_Reverse(RD0);
    RF_RotateL16(RD0);
    USI_Data = RD0;
    RD2 -= 1;                           // дX
    if(RQ_Zero) goto L_SPI_Master_Puts_Prot_End;

L_SPI_Master_Puts_Prot_Loop:
    RD0 = M[RA0++];
    RF_Reverse(RD0);
    RF_RotateL16(RD0);
    USI_Data = RD0;                     // дX+1

L_SPI_Master_Puts_Prot_Loop_Wait:            // ��X
    if(USI_Flag==0) goto L_SPI_Master_Puts_Prot_Loop_Wait;
    RD2 -= 1;
    if(RQ_nZero) goto L_SPI_Master_Puts_Prot_Loop;
    RD0 = USI_Data;                     // ��������ڶ����ı�־

L_SPI_Master_Puts_Prot_End:                  // ��X+1
    if(USI_Flag==0) goto L_SPI_Master_Puts_Prot_End;


//// cs ����
//RD0 = GP0_4;
//GPIO_WEn0 = RD0;
//RD0 = GP0_4;
//GPIO_Data0 = RD0;

    USI_DisTxRx;
    Set_IntASM_En;
    Return_AutoField(0*MMU_BASE);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      SPI_Master_Gets_Prot
//  ����:
//      ��������ָ�����ȵ����ݣ�Ϊ����������Ƶ����16bit���н���
//  ����:
//      1.RD0:�˿ں�COM0/COM1
//      2.RD1:����(��λ���ֽڣ�����4��������)
//      3.RA0:�����׵�ַ(out)
//  ����ֵ��
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField SPI_Master_Gets_Prot;
    Set_IntASM_Dis;
    USI_Num = RD0;
    USI_EnableRx;
    RF_ShiftR2(RD1);
    RD2 = RD1;

//// cs ����
//RD0 = GP0_4;
//GPIO_WEn0 = RD0;
//RD0 = 0;
//GPIO_Data0 = RD0;

    USI_Data = RD0;
    RD2 -= 1;                           // ��д������
    if(RQ_Zero) goto L_SPI_Master_Gets_Prot_End;

L_SPI_Master_Gets_Prot_Loop:
    USI_Data = RD0;                     // дX+1
L_SPI_Master_Gets_Prot_Wait:                 // ��
    if(USI_Flag==0) goto  L_SPI_Master_Gets_Prot_Wait;
    RD0 = USI_Data;
    RF_Reverse(RD0);
    RF_RotateL16(RD0);
    M[RA0++] = RD0;
    RD2 -= 1;
    if(RQ_nZero) goto L_SPI_Master_Gets_Prot_Loop;

L_SPI_Master_Gets_Prot_End:
    if(USI_Flag==0) goto L_SPI_Master_Gets_Prot_End;
    RD0 = USI_Data;
    RF_Reverse(RD0);
    RF_RotateL16(RD0);
    M[RA0++] = RD0;

//// cs ����
//RD0 = GP0_4;
//GPIO_WEn0 = RD0;
//RD0 = GP0_4;
//GPIO_Data0 = RD0;

    USI_DisTxRx;
    Set_IntASM_En;
    Return_AutoField(0*MMU_BASE);

END SEGMENT
#define _Debug_Mode_F_

#include <CPU11.def>
#include <Global.def>
#include <RN_DSP_Cfg.def>
#include <DMA_ParaCfg.def>
#include <Download.def>
#include <GPIO.def>
#include <BL_SPI.def>
#include <MarchC.def>
#include <ALU.def>
#include <Random.def>
#include <string.def>
#include <init.def>
#include <STA.def>
#include <FMT.def>
#include <I2C.def>
#include <USI.def>
#include <UART.def>
#include <FuncTest.def>

CODE SEGMENT Debug_Mode_F;
//ֱ������Cache1(����Flash) 4K*16
_Download_Function:
	//CP ����ģʽ���
	call CKT_Mode_Check;
	if(RD0_nZero) goto L_Boot_Mode_Start;
	call CP_Test;
	RD2 = 6000*30;
	call _Delay_RD2;
	goto _Download_Function;

L_Boot_Mode_Start:
	RD3 = 3; //����У׼����
L_Mode_Check0:
	//GP0_1  UART_COM0_Tx
    RD0 = GP0_1;   //OC״̬��֧�ֵ���UART
    GPIO_WEn0 = RD0;
    RD0 = GPIO_IN|GPIO_OUT|GPIO_OC|GPIO_PULL;   //ͬʱ����ͨ·Ҳ��
    GPIO_Set0 = RD0;
    //GP0_2  UART_COM0_Rx
    RD0 = GP0_2;
    GPIO_WEn0 = RD0;
    RD0 = GPIO_IN|GPIO_PULL;
    GPIO_Set0 = RD0;

	//ģʽ�жϣ�UART���أ�GP01+GP02�͵�ƽ����I2C���أ�GP02�͵�ƽ����USERģʽ��������
	call BootMode_Check;
	Set_BDI2C;  //Ӳ�����,��Ӧ RFlag_BDUART==0;
	if(RD0_Zero) goto L_Download;
	Set_BDUART; //Ӳ�����,��Ӧ RFlag_BDUART==1;
	RD0 --;
	if(RD0_Zero) goto L_Download;

//  =================== GD25_Boot User ģʽ ===================
	//�û�ģʽ
L_User_Mode:  //L_Boot_GD25:����GD25������
	//RSP��ʼ��
    RD0 = RN_RSP_START;
    RSP = RD0;
    //����Flash������2��Cache
    call SPI_Init;
    call Load_Data;

    Set_CPUSpeed3;
    goto RN_Cache_StartAddr_Program;

//  =================== Download ģʽ =========================
L_Download:
	// ��ʼ��
    RD0 = RN_RSP_START;
    RSP = RD0;
    // 10ms�ӳ�
    RD2 = 60000;
    call _Delay_RD2;

	// UART_COM0��ʼ����CFG�˿�
    RD0 = COM0;
    send_para(RD0);
    RD0 = 0x2829674e;//32.000MHz��Ӧ28800bps�Ĳ���   32000000/28800/2 = 556
    send_para(RD0);
    RD0 = 2;
    send_para(RD0);
    RD0 = 0;
    send_para(RD0);
    call UART_Init;

	// ���������ֽ�0x00,28800bps
	RD0 = 0x00;
    send_para(RD0);
    call UART_Putchar;

	RD0 = 0x00;
    send_para(RD0);
    call UART_Putchar;

	// �����I2Cģʽ��ֱ�ӵ���ַɨ��׶�
	if(RFlag_BDUART==0) goto L_I2C_Boot;
	// �����UARTģʽ������bps�趨ָ��
	RD0 = 600*5;   //5ms��ʱ
	call UART_Getchar_TO;
	RD2 = RD0;
	RD0 ++;  //0xffffffff ��ʾ��ʱ
	if(RD0_Zero) goto L_CalBPS_Fail; //��ʱ��������׼

L_BPS_Judge:
	RD0 = 0x55; //115200
	RD0 -= RD2;
	if(RD0_Zero) goto L_BPS_115200;
	RD0 = 0xaa; //28800
	RD0 -= RD2;
	if(RD0_Zero) goto L_UART_Boot; //Ĭ��Ϊ28800

	//�����ʶ�׼ʧ�ܣ����¿���
L_CalBPS_Fail:
	USI_Num = COM0;
    USI_Disable;
	// GPIO��ʼ��
    RD0 = 0xff;
    GPIO_WEn0 = RD0;
    GPIO_Data0 = RD0;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;

	RD3 --;
	if(RQ_nZero) goto L_Mode_Check0;

	//3�ζ�׼ʧ�ܣ�����User_Mode;
	goto L_User_Mode;

L_BPS_115200:
	// UART_COM0��ʼ����Cfg�˿�
    RD0 = COM0;
    send_para(RD0);
    RD0 = 0x52faa192;//32.000MHz��Ӧ115200bps�Ĳ���   32000000/115200/2 = 139
    send_para(RD0);
    RD0 = 2;
    send_para(RD0);
    RD0 = 0;
    send_para(RD0);
    call UART_Init;

	//UART ���ع���
L_UART_Boot:
	RD2 = 12000; //�ӳ�2ms����
	call _Delay_RD2;

	//��ѡ���Ĳ����ʻظ�ACK
	RD0 = 0x90;
	send_para(RD0);
	call UART_Putchar;
	RD0 = 0x00;
	send_para(RD0);
	call UART_Putchar;

	//���뻺��ռ�4�ֽ�+1024�ֽ�
    RD0 = 2048;
    RSP -= RD0;
    RA0 = RSP;

	//��ʼѭ����������֡��ֱ���յ����ؽ���ָ��
L_UART_Download_Frame_Loop:
	//RA0 ƫ�Ƶ�ַ
	//����1֡���ݣ�������У�飬����ָ����
	call UART_Gets_Frame;
	RD0 = RD1;           //�жϽ���״̬
	RD1 = 0x31415926;    //��ʱ��־��
	if(RD0_Zero) goto L_Send_Verify_UART;
	//�������+������Cache+У�����
	call Frame_Operate;
	if(RD0_Zero) goto L_Send_Verify_UART;
	//���ؽ�������
	goto L_Download_End;
L_Send_Verify_UART:
//MODIFY------------------------------
	RD2 = 6000*2; //2ms�ӳ�
	call _Delay_RD2;
//-----------------------------------   
    // ����У��ֵ
    send_para(RD1);
    call UART_PutDword;
    goto L_UART_Download_Frame_Loop;


// =============== Download for I2C ===============
//                   I2C ���ع���
L_I2C_Boot:
//#define I2C_SDA         GP0_1
//#define I2C_SCL         GP0_2
    // ��ʼ��GPIO
    RD0 = I2C_SDA | I2C_SCL;
    GPIO_WEn0 = RD0;
    RD0 = GPIO_IN|GPIO_PULL;
    GPIO_Set0 = RD0;

	//���뻺��ռ�4+1024�ֽ�
    RD0 = 2048;
    RSP -= RD0;
    RA0 = RSP;

	//��ʼѭ����������֡��ֱ���յ����ؽ���ָ��
L_I2C_Download_Frame_Loop:
	//RA0 ƫ�Ƶ�ַ
	//����1֡���ݣ�������У�飬����ָ����
	//I2C_Gets_Frame
	call I2C_Scan_Addr;
    RD0 = 1028;
    call I2C_Gets;
    call I2C_Wait_Stop;

	//�������+������Cache+У�����
	call Frame_Operate;
	if(RD0_Zero) goto L_Send_Verify_I2C;
	goto L_Download_End;
L_Send_Verify_I2C:
	call I2C_Scan_Addr;
    // ����У��ֵ
    push RD1;
    RA0 = RSP;
    RD0 = 4;
    call I2C_Puts;
    call I2C_Wait_Stop;
	pop RD1;
	RA0 = RSP;  //�ָ�RA0
    goto L_I2C_Download_Frame_Loop;

	//���ؽ������ָ��ֳ�������ת��Cache����
L_Download_End:
	USI_Num = COM0;
    USI_Disable;
	// GPIO��ʼ��
    RD0 = 0xff;
    GPIO_WEn0 = RD0;
    GPIO_Data0 = RD0;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;
    // �ָ���λ����
    RD0 = GP0_1|GP0_2;
    GPIO_WEn0 = RD0;
    RD0 = GPIO_IN|GPIO_PULL;
    GPIO_Set0 = RD0;
    // �ָ�RSP����
    RD0 = RN_RSP_START;
    RSP = RD0;
	// ����ΪSpeed3����ת��Cacheִ��
    Set_CPUSpeed3;
    goto RN_Cache_StartAddr_Program;


//////////////////////////////////////////////////////////////////////////
//  ��������:
//    Frame_Operate
//  ��������:
//    ���1֡���ݰ�����Buffer֮��Ĵ��������������+������Cache+У�����
//  �������:
//    RA0: Buffer��ַ
//  ��������:
//    RD0: 0:Cache�������� �� ȫ��У����� -1:������������
//    RD1��У����
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Frame_Operate;
	//��ͷ����
	RA1 = M[RA0++];
	RD0 = RA1;
	RF_GetH8(RD0);
	RD3 = RD0;
	//0x00xxxxxx:�����������ݰ�
	if(RD0_Zero) goto L_Copy_Buf2Cache;
	RD0 = 0xAA;  //Cache����У��
	RD0 -= RD3;
	if(RD0_Zero) goto L_Verify_CacheAll;
	//���ؽ�������
	RD0 = -1;
	Return_AutoField(0);

	//�������Կ�������У��
L_Copy_Buf2Cache:
	//����������Cache
	RD0 = RN_Cache_StartAddr;
	RA1 += RD0;         //Ŀ���ַ
	//RA0 �����ݵ�ַ  32λ�ָ�ʽ = {I0[15:0],I1[15:0]}
	call Copy_Buf2Cache;

    //У�������
    RD0 = 0x123456;
    send_para(RD0);// Temp
    send_para(RD0);// Rst
    send_para(RA1);
    RD0 = 1024;
    send_para(RD0);
    call VerifySum_BootLoader;
	RD1 = RD0;
	RD0 = 0;
	Return_AutoField(0);
	
	//У������Cache
L_Verify_CacheAll:
    RD0 = 0x123456;
    send_para(RD0);// Temp
    send_para(RD0);// Rst
    RD0 = RN_Cache_StartAddr;
    send_para(RD0);
    RD0 = RN_Cache_SIZE;
    send_para(RD0);
    call VerifySum_BootLoader;
	RD1 = RD0;
	RD0 = 0;
	Return_AutoField(0);




////////////////////////////////////////////////////////
//  ����:
//      UART_Getchar
//  ����:
//      UART_COM0����1�ֽ�����
//  ����:
//      RD0:��ʱʱ�������1��ʾ10��ָ��ʱ�䳤��
//  ����ֵ:
//      RD0�����ݻ�ʱ��־ 
//      -1����ʱ   0x000000xx������
////////////////////////////////////////////////////////
Sub_AutoField UART_Getchar_TO;
	RD3 = RD0;
    USI_Num = COM0;
L_UART_Getchar_TO_Wait1:
    nop;nop;nop;nop;
    RD3--;
    if(RQ_Zero) goto L_UART_Getchar_TO;
    if(USI_Flag==0) goto L_UART_Getchar_TO_Wait1;

    RD0 = USI_Data;
    RF_ShiftR2(RD0);
    RF_ShiftR1(RD0);
    RF_GetL8(RD0);
    Return_AutoField(0*MMU_BASE);

L_UART_Getchar_TO:
    RD0 = -1;
    Return_AutoField(0*MMU_BASE);

//////////////////////////////////////////////////////////////////////////
//  ��������:
//    UART_Gets_Frame
//  ��������:
//    ���UART (4+1024)Byte���ݰ����ع��ܡ���ַ+����д��+У�鷢�͡�
//    ��ʱʱ���Լ50ms
//  �������:
//    RA0 ��Ŀ���ַ��������32λ���RAM��
//  ��������:
//    RD1 :  0 ��ʱ
//          !0 ����
//////////////////////////////////////////////////////////////////////////
Sub_AutoField UART_Gets_Frame;
	RD2 = 257;
	RD3 = 600*50;//��Լ50ms
L_UG_Frame_Loop:
	RD0 = RD3;   //��ʱ����
	call UART_GetDword_TO;
	M[RA0++] = RD0;
	RD0 = RD1;
	if(RD0_Zero) goto L_UG_Frame_Loop_End;
	RD2 --;
	if(RQ_nZero) goto L_UG_Frame_Loop;
L_UG_Frame_Loop_End:
	nop;
  	Return_AutoField(0);


//////////////////////////////////////////////////////////////////////////
//  ��������:
//    Copy_Buf2Cache
//  ��������:
//    ���1024Byte���ݴ�BaseRAM������Cache����
//  �������:
//    RA0 ��Դ��ַ��������32λ���RAM��
//    RA1 ��Ŀ���ַ��������16λ���RAM��
//  ��������:
//    ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Copy_Buf2Cache;
    Sel_Cache4Data;
	RD2 = 256;
L_Copy_Buf2Cache_L0:
	RD0 = M[RA0++];
	M[RA1+2] = RD0;
	RF_GetH16(RD0);
	M[RA1++] = RD0;
	RD2 --;
	if(RQ_nZero) goto L_Copy_Buf2Cache_L0;
    Sel_Cache4Inst;
  	Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  ��������:
//    CKT_Mode_Check
//  ��������:
//    CKTģʽ���
//  �������:
//    ��
//  ��������:
//    RD0��0: ��CKTģʽ
//        !0: ��CKTģʽ
//////////////////////////////////////////////////////////////////////////
Sub_AutoField CKT_Mode_Check;
	//CP_TEST IO ��ʼ��
    //Rx:GP1_5 + GP1_6
    RD0 = CKT_CP+CKT_RX;
    GPIO_WEn1 = RD0;
    RD0 = GPIO_IN | GPIO_PULL;
    GPIO_Set1 = RD0;
	RD2 = 6000;  //1ms�ӳ�
	call _Delay_RD2;
	RD0 = GPIO_Data1;
	if(RD0_Bit5==1) goto L_Not_CKT_Mode;
	if(RD0_Bit6==1) goto L_Not_CKT_Mode;
	//���1ms�ٴ��ж�
	RD2 = 6000;  //1ms
	call _Delay_RD2;
	RD0 = GPIO_Data1;
	if(RD0_Bit5==1) goto L_Not_CKT_Mode;
	if(RD0_Bit6==1) goto L_Not_CKT_Mode;
    //Tx:GP1_7�����壬Լ1ms
    RD0 = CKT_TX;
    GPIO_WEn1 = RD0;
    RD0 = GPIO_OUT;
    GPIO_Set1 = RD0;
    RD0 = 0;
	GPIO_Data1 = RD0;

	//1ms������GP1_5��GP1_6
	RD2 = 600;
	RD3 = 0b01100000;
L_Check_CKT_Ready_L0:
	RD0 = GPIO_Data1;
	RD0 &= RD3;
	RD0 -= RD3;
	if(RD0_Zero) goto L_Check_CKT_Confirm;
	nop; nop;
	RD2 --;
	if(RQ_nZero) goto L_Check_CKT_Ready_L0;

L_Not_CKT_Mode:
    RD0 = CKT_TX;
    GPIO_WEn1 = RD0;
    RD0 = GPIO_IN | GPIO_PULL;
    GPIO_Set1 = RD0;
    RD0 = -1;     //��CKT ģʽ
	Return_AutoField(0);

L_Check_CKT_Confirm:
	RD0 = 0;     //CKT ģʽ
	Return_AutoField(0);
	




//////////////////////////////////////////////////////////////////////////
//  ��������:
//    BootMode_Check
//  ��������:
//    ���GP01��GP02�Ƿ���ֵ͵�ƽ
//  �������:
//    ��
//  ��������:
//    RD0��0: ��GP02�͵�ƽģʽ
//         1: GP01+GP02 �͵�ƽģʽ
//     other: ��ʱ�˳�������δ��ѯ���͵�ƽ���ƽά��ʱ��Ƿ���������6MIPS��ʱ30ms��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField BootMode_Check;
	//��ѯGP02
	RD2 = 600*30;
L_BMC_GP02_L0:
	nop; nop; nop; nop; nop;
	if(RFlag_COM0_Rx==0) goto L_BMC_GP01_L00;
	RD2 --;
	if(RQ_nZero) goto L_BMC_GP02_L0;  		
	RD0 = -1;
	goto L_BMC_End;  //30msδ��ѯ���͵�ƽ����ʱ�˳�
L_BMC_GP01_L00:
	call Glitch_Cancel_GP02L;
	if(RFlag_COM0_Rx==1) goto L_BMC_GP02_L0;

	//��ѯ��GP02Ϊ�͵�ƽ���ȴ��ߵ�ƽ��50ms��ʱ�˳�
	//�ڼ��ѯGP01�Ƿ��е͵�ƽ����
	RD0 = 0;
	RD2 = 600*50;
L_BMC_GP01_L1:
	nop; nop;
	if(RFlag_COM0_Tx==0) goto L_BMC_GP01_L20;
	nop;
	if(RFlag_COM0_Rx==1) goto L_BMC_End;   //�ɹ��ж�ΪGP01�����͵�ƽģʽ
	RD2 --;
	if(RQ_nZero) goto L_BMC_GP01_L1;
	RD0 = -1;
	goto L_BMC_End;   //�͵�ƽ����ʱ�䳬��50ms���ж�Ϊ�Ƿ�

	//�鵽GP01Ϊ�͵�ƽ
L_BMC_GP01_L20:
	//������
	call Glitch_Cancel_GP01L;
	RD0 = 0;
	if(RFlag_COM0_Tx==1) goto L_BMC_GP01_L1;

	//��Ч�ж�GP01Ϊ�͵�ƽ����ѯ�ȴ�GP02Ϊ�ߵ�ƽ
	RD0 = 1;
L_BMC_GP01_L21:
	nop; nop; nop; nop; nop;
	if(RFlag_COM0_Rx==0) goto L_BMC_GP01_L22;  //�ɹ��ж�ΪGP01+GP02�͵�ƽģʽ
	call Glitch_Cancel_GP02H;
	if(RFlag_COM0_Rx==1) goto L_BMC_End;
L_BMC_GP01_L22:
	RD2 --;
	if(RQ_nZero) goto L_BMC_GP01_L21;
	//�͵�ƽ����ʱ�䳬��50ms���ж�Ϊ�Ƿ�
	RD0 = -1;         
L_BMC_End:
	Return_AutoField(0);



////////////////////////////////////////////////////////
//  ��������:
//      Glitch_Cancel_GP01L
//  ��������:
//      GP01�͵�ƽ�ж�ȥë��
////////////////////////////////////////////////////////
Sub_AutoField Glitch_Cancel_GP01L;
	RD2 = 100;
L_Glitch_GP01L:
	RD2 --;
	if(RQ_Zero) goto L_Glitch_GP01L_End;
	if(RFlag_COM0_Tx==1) goto L_Glitch_GP01L;
	nop; nop; nop; nop; nop; nop;
	if(RFlag_COM0_Tx==1) goto L_Glitch_GP01L;
	nop; nop; nop; nop; nop; nop;
	if(RFlag_COM0_Tx==1) goto L_Glitch_GP01L;
L_Glitch_GP01L_End:
	nop;
	Return_AutoField(0);


////////////////////////////////////////////////////////
//  ��������:
//      Glitch_Cancel_GP01H
//  ��������:
//      GP01�ߵ�ƽ�ж�ȥë��
////////////////////////////////////////////////////////
Sub_AutoField Glitch_Cancel_GP01H;
	RD2 = 100;
L_Glitch_GP01H:
	RD2 --;
	if(RQ_Zero) goto L_Glitch_GP01H_End;
	nop; nop; nop; nop; nop; nop;
	if(RFlag_COM0_Tx==0) goto L_Glitch_GP01H;
	nop; nop; nop; nop; nop; nop;
	if(RFlag_COM0_Tx==0) goto L_Glitch_GP01H;
	nop; nop; nop; nop; nop; nop;
	if(RFlag_COM0_Tx==0) goto L_Glitch_GP01H;
L_Glitch_GP01H_End:
	nop;
	Return_AutoField(0);


////////////////////////////////////////////////////////
//  ��������:
//      Glitch_Cancel_GP02L
//  ��������:
//      GP02�͵�ƽ�ж�ȥë��
////////////////////////////////////////////////////////
Sub_AutoField Glitch_Cancel_GP02L;
	RD2 = 100;
L_Glitch_GP02L:
	RD2 --;
	if(RQ_Zero) goto L_Glitch_GP02L_End;
	if(RFlag_COM0_Rx==1) goto L_Glitch_GP02L;
	nop; nop; nop; nop; nop; nop;
	if(RFlag_COM0_Rx==1) goto L_Glitch_GP02L;
	nop; nop; nop; nop; nop; nop;
	if(RFlag_COM0_Rx==1) goto L_Glitch_GP02L;
L_Glitch_GP02L_End:
	nop;
	Return_AutoField(0);


////////////////////////////////////////////////////////
//  ��������:
//      Glitch_Cancel_GP02H
//  ��������:
//      GP02�ߵ�ƽ�ж�ȥë��
////////////////////////////////////////////////////////
Sub_AutoField Glitch_Cancel_GP02H;
	RD2 = 100;
L_Glitch_GP02H:
	RD2 --;
	if(RQ_Zero) goto L_Glitch_GP02H_End;
	if(RFlag_COM0_Rx==0) goto L_Glitch_GP02H;
	nop; nop; nop; nop; nop; nop;
	if(RFlag_COM0_Rx==0) goto L_Glitch_GP02H;
	nop; nop; nop; nop; nop; nop;
	if(RFlag_COM0_Rx==0) goto L_Glitch_GP02H;
L_Glitch_GP02H_End:
	nop;
	Return_AutoField(0);


////////////////////////////////////////////////////////
//  ��������:
//      VerifySum_BootLoader
//  ��������:
//      ���16λCache�洢�����������ֽ��ۼӺ�У��ֵ
//  ��ڲ���:
//      1:Temp
//      2:Rst
//      3:����ָ��
//      4:���ȣ���λ��Byte��
//  ���ڲ���:
//      RD0:У��ֵ
//      RD1:Temp
////////////////////////////////////////////////////////
Sub_AutoField VerifySum_BootLoader;
	Sel_Cache4Data;
    RD1 = M[RSP+3*MMU_BASE];// Temp
    RD0 = M[RSP+2*MMU_BASE];// Rst
    RA0 = M[RSP+1*MMU_BASE];
    RD2 = M[RSP+0*MMU_BASE];
    RF_ShiftR2(RD2);
L_VerifySum_BootLoader_Loop:
	RD3 = M[RA0];
	RF_RotateL16(RD3);
	RD3 += M[RA0+2];
    RD1 += RD3;
    RD0 += RD1;
    RA0 += 4;
    RD2 --;
    if(RQ_nZero) goto L_VerifySum_BootLoader_Loop;
    Sel_Cache4Inst;
    Return_AutoField(4*MMU_BASE);


////////////////////////////////////////////////////////
//  ����:
//      UART_GetDword_TO
//  ����:
//      UART_COM0����4�ֽ�����
//  ����:
//      RD0:��ʱ����
//  ����ֵ:
//      RD0�����յ���Dword����
//      RD1: 0 ���ճ�ʱ
//          !0 ��������
////////////////////////////////////////////////////////
Sub_AutoField UART_GetDword_TO;
    USI_Num = COM0;
	RD3 = RD0;
_UART_GetDword_Wait1:
    RD3--;
    if(RQ_Zero) goto L_UART_GetDword_End;
    nop;nop;nop;nop;nop;
    if(USI_Flag==0) goto _UART_GetDword_Wait1;
    RD0 = USI_Data;
    RF_ShiftR2(RD0);
    RF_ShiftR1(RD0);
    RF_GetL8(RD0);
    RD2 = RD0;
    RF_RotateL8(RD2);

_UART_GetDword_Wait2:
    RD3--;
    if(RQ_Zero) goto L_UART_GetDword_End;
    nop;nop;nop;nop;nop;
    if(USI_Flag==0) goto _UART_GetDword_Wait2;
    RD0 = USI_Data;
    RF_ShiftR2(RD0);
    RF_ShiftR1(RD0);
    RF_GetL8(RD0);
    RD2 |= RD0;
    RF_RotateL8(RD2);

_UART_GetDword_Wait3:
    RD3--;
    if(RQ_Zero) goto L_UART_GetDword_End;
    nop;nop;nop;nop;nop;
    if(USI_Flag==0) goto _UART_GetDword_Wait3;
    RD0 = USI_Data;
    RF_ShiftR2(RD0);
    RF_ShiftR1(RD0);
    RF_GetL8(RD0);
    RD2 |= RD0;
    RF_RotateL8(RD2);

_UART_GetDword_Wait4:
    RD3--;
    if(RQ_Zero) goto L_UART_GetDword_End;
    nop;nop;nop;nop;nop;
    if(USI_Flag==0) goto _UART_GetDword_Wait4;
    RD0 = USI_Data;
    RF_ShiftR2(RD0);
    RF_ShiftR1(RD0);
    RF_GetL8(RD0);
    RD2 |= RD0;
    RD0 = RD2;

L_UART_GetDword_End:    
    RD1 = RD3;
    Return_AutoField(0*MMU_BASE);


END SEGMENT
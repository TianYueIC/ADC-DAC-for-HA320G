#define _Test_MultiArray_F_

#include <cpu11.def>
#include <resource_allocation.def>
#include <DMA_ALU.def>
#include <DMA_ParaCfg.def>
#include <RN_DSP_Cfg.def>
#include <USI.def>
#include <GPIO.def>
#include <Global.def>
#include <string.def>
#include <MAC.def>
#include <ALU.def>
#include <GPIO.def>
#include <Debug.def>
#include <usi.def>
#include <SOC_Common.def>
#include <SPI_Master.def>
#include <IIR.def>
#include <MATH.def>
#include <Init.def>
#include <Debug.def>
#include <Trimming.def>
#include <AD_DA_330G.def>
#include <DspHotLine_330G.def>

extern _DMA_ParaCfg_Flow;
extern UART_PutDword_COM1;
extern UART_Init;
extern UART_Putchar_COM1;
//========================================
//����&Ӳ��ѡ��
//========================================
#define OnBoardChip_test  //Ӳ��ʵ��
//#define Calibration_byHand  //�����ֶ�У׼
//#define Simulation_byCadence  //����
#define         RN_SPI_CLK_CFG                  0x7ffffffc;//32000000/8000000/2 = 2


///////////////////////////////////////
//Rom �����׼ͷ
///////////////////////////////////////
CODE SEGMENT Test_Main_F;
//�ж�������
//-------------------------
//�ж�0~6ֻ�ܵ�ROM
// ... ...
//
L_Test_Main0:
		CPU_SimpleLevel_L;

	
	
	Set_CPUSpeed5;
	//Set_CPUSpeed2;
	//Set_CPUSpeed1;
	
    //��ַ��ʼ��
    RD0 = RN_RSP_START;
    RD1 = RN_PARA_TOTAL_LEN_B;
    RD0 -= RD1;
    RSP = RD0;
    RA4 = RD0;
    RD0 = RN_Const_StartAddr;
    RA5 = RD0;
    RD0 = PortExt_Addr;
    RA6 = RD0;
    
L_Calibration:
	//(a)��׼��ѹVref\Vcore����׼Ƶ�ʵĳ�ʼ����
	//---Speed3������
	RD1 = RN_SP3;
    RP_B15;
    Set_Pulse_Ext8;
    nop;nop;
    
	//---Set Vref
    RD0 = RN_VREF_VAL;
    RF_Not(RD0);
    StandBy_WRCfg = RD0;
    
    //---Set OSC
    RD0 = 0;
    RD0_SetBit19;
    StandBy_WRSel = RD0;
    RD0 = RN_FREQ_VAL;
    StandBy_WRCfg = RD0;
    RD2 = 2000;     //�ӳ�1ms�ȴ�Ƶ���ȶ�
    call _Delay_RD2;
    
	  //---CPU������ѹ����1.2V
	RD0 = 0;
	RD0_SetBit22;
	StandBy_WRSel = RD0;
	//RD0 = 0b110000;  //��׼��ѹ����ֵ
	RD0 = 0b111011;  //��׼��ѹ����ֵ,�̶�ֵ��
	RF_Not(RD0);
	StandBy_WRCfg = RD0;
	//---//������
	//L_TEST_FREQ:			
	//	CPU_SimpleLevel_H;
	//	nop;
	//	CPU_SimpleLevel_L;
	//	goto L_TEST_FREQ;	
	
	//5ms�ȴ��ȶ�ʱ��
	#ifdef OnBoardChip_test  //������
	RD2 = 2000*5;
	call _Delay_RD2;
	#endif  //������    
    
#ifdef Simulation_byCadence
    RD0 = 0x11171016;
    Debug_Reg32 = RD0;
#endif


    //GP0_3  ������
    RD0 = GP0_3;
    GPIO_WEn0 = RD0;
    RD0 = GPIO_IN|GPIO_PULL;
    GPIO_Set0 = RD0;
    RD0 = GP0_4;
    GPIO_WEn0 = RD0;
    RD0 = GPIO_IN|GPIO_PULL;
    GPIO_Set0 = RD0;
    RD0 = GP0_7;
    GPIO_WEn0 = RD0;
    RD0 = GPIO_IN|GPIO_PULL;
    GPIO_Set0 = RD0;

    //RD0 = 0b11;//ʹ��˫MIC
    //RD0 = 0b10;//ʹ��MIC1
	//RD0 = 0b01;//ʹ��MIC0
	RD0 = 0b01;//ʹ��MIC0
	call AD_DA_INIT_330G;
    RD2 = 4000*2000;
    call _Delay_RD2;// ��ʱ10ms�ȴ��ź��ȶ����л�ͨ�����źŽ���ʱ��<1ms��


#ifdef OnBoardChip_test  
L_UART_init:
		call UART1_Initial;
		
		RD0 = 0xABCDEF5A;
		send_para(RD0);
		call UART_PutDword_COM1;
		RD0 = 0xABCDEF5A;
		send_para(RD0);
		call UART_PutDword_COM1;
#endif
		
		
			//��ʼ���ԣ��ȴ�����GP0-3
L_Wait_Key0:
	
	CPU_SimpleLevel_L;
	nop; nop; nop; nop;
	RD0 = GPIO_Data0;
#ifdef OnBoardChip_test
	//if(RD0_Bit3 == 1) goto L_Wait_Key0;
#endif
   
    
    CPU_SimpleLevel_H;
    
    //goto L_Wait_Key0;


    RD0 = 0;
    g_Vol = RD0;    //��������ֵ
Loop:   //main
    
    call Get_ADC;
    nop;nop;nop;nop;
    if(RD0_nZero) goto Loop;

//ʹ�ò����������ADC����
    RD0 = RN_GRAM_IN;
    RA1 = RD0;
	//д��������
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
    RD0 = DMA_PATH0;
    M[RA1] = RD0;
    MemSet_Disable;     //���ý���
    
    CPU_WorkEnable;
    CPU_SimpleLevel_H;

//    //1kHz�����ź�
//    RD0 = 0x30fb0000;
//    M[RA1++] = RD0;
//    RD0 = 0x76415a82;
//    M[RA1++] = RD0;
//    RD0 = 0x76417ffe;//
//    M[RA1++] = RD0;
//    RD0 = 0x30fb5a82;
//    M[RA1++] = RD0;
//    RD0 = 0xcf050000;
//    M[RA1++] = RD0;
//    RD0 = 0x89bfa57e;
//    M[RA1++] = RD0;
//    RD0 = 0x89bf8001;
//    M[RA1++] = RD0;
//    RD0 = 0xcf05a57e;
//    M[RA1++] = RD0;
//    RD0 = 0x30fb0000;
//    M[RA1++] = RD0;
//    RD0 = 0x76415a82;
//    M[RA1++] = RD0;
//    RD0 = 0x76417ffe;//
//    M[RA1++] = RD0;
//    RD0 = 0x30fb5a82;
//    M[RA1++] = RD0;
//    RD0 = 0xcf050000;
//    M[RA1++] = RD0;
//    RD0 = 0x89bfa57e;
//    M[RA1++] = RD0;
//    RD0 = 0x89bf8001;
//    M[RA1++] = RD0;
//    RD0 = 0xcf05a57e;
//    M[RA1++] = RD0;


    RD0 = 0x0C3E0000;
    M[RA1++] = RD0;
    RD0 = 0x1D9016A0;
    M[RA1++] = RD0;
    RD0 = 0x1D901FFF;//
    M[RA1++] = RD0;
    RD0 = 0x0C3E16A0;
    M[RA1++] = RD0;
    RD0 = 0xF3C10000;
    M[RA1++] = RD0;
    RD0 = 0xE26FE95F;
    M[RA1++] = RD0;
    RD0 = 0xE26FE000;
    M[RA1++] = RD0;
    RD0 = 0xF3C1E95F;
    M[RA1++] = RD0;
    RD0 = 0x0C3E0000;
    M[RA1++] = RD0;
    RD0 = 0x1D9016A0;
    M[RA1++] = RD0;
    RD0 = 0x1D901FFF;//
    M[RA1++] = RD0;
    RD0 = 0x0C3E16A0;
    M[RA1++] = RD0;
    RD0 = 0xF3C10000;
    M[RA1++] = RD0;
    RD0 = 0xE26FE95F;
    M[RA1++] = RD0;
    RD0 = 0xE26FE000;
    M[RA1++] = RD0;
    RD0 = 0xF3C1E95F;
    M[RA1++] = RD0;



    CPU_WorkDisable; 
//�˴����޸��㷨����Ƶ����RN_GRAM_IN


//�������� ������
//    RD0 = RD6;////////////////////2021/12/9 19:54:52 С��ר��
//    g_Vol = RD0;

//GPIO7���¼�С������GPIO3������������
	RD0 = GPIO_Data0;
	if(RD0_Bit3 == 0) goto L_TEST_1;
	goto  L_TEST_END1;   
L_TEST_1:
    nop;nop;
	RD0 = GPIO_Data0;
	if(RD0_Bit3 == 0) goto L_TEST_1;
    RD0 = g_Vol;
    RD0 += 1;
    g_Vol = RD0;
    RD2 = 2000*100;     
    call _Delay_RD2;
L_TEST_END1:
    
	RD0 = GPIO_Data0;
	if(RD0_Bit7 == 0) goto L_TEST_2;
	goto  L_TEST_END2;   
L_TEST_2:
    nop;nop;
	RD0 = GPIO_Data0;
	if(RD0_Bit7 == 0) goto L_TEST_2;
    RD0 = g_Vol;
    RD0 -= 1;
    g_Vol = RD0;
    RD2 = 2000*100;     
    call _Delay_RD2;
L_TEST_END2:
    
	RD0 = GPIO_Data0;
	if(RD0_Bit4 == 0) goto L_TEST_3;
	goto  L_TEST_END3;   
L_TEST_3:
    nop;nop;
	RD0 = GPIO_Data0;
	if(RD0_Bit4 == 0) goto L_TEST_3;
    RD0 = g_Vol;
    if(RD0_nZero) goto L_TEST_3_0;
    RD0 = -100;
    goto L_TEST_3_1;
L_TEST_3_0:        
    RD0 = 0;
L_TEST_3_1:
    g_Vol = RD0;
    RD2 = 2000*100;     
    call _Delay_RD2;
L_TEST_END3:

  
/////////������������
/*    
    //2021/12/9 19:14:40 С��Ҫ����Vol>0���֣���������Ŵ󣬽����㷨ʹ��
    RD0 = g_Vol;
    RD6 = RD0;
    RD0 -= 40;
    if(RD0_Bit31 == 1) goto L_TEST0_2;
    g_Vol = 40; //��������
L_TEST0_2:    
    RD0 = g_Vol;
    if(RD0_Bit31 == 1) goto L_TEST0_END;
    RD0 = RN_GRAM_IN;
    RA1 = RD0;
	//д��������
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
    RD0 = DMA_PATH0;
    M[RA1] = RD0;
    MemSet_Disable;     //���ý���    
    CPU_WorkEnable;
L_TEST0_1:    
    RD2 = 16;
    RD0 = RN_GRAM_IN;
    RA1 = RD0;    
L_TEST0_0:
    RD0 = M[RA1];
    RD1 = RD0;
    RD0_SignExtL16; 
    RF_ShiftL1(RD0);
	RD0_ClrByteH16;
    RD3 = RD0;
    RD0 = RD1;
	RD0_ClrByteL16;
    RF_ShiftL1(RD0);
    RD0 += RD3;
    M[RA1++] = RD0;
    RD2 --;
    if(RQ_nZero) goto L_TEST0_0;    
        
    RD0 = g_Vol;            
    RD0 -= 6;
    g_Vol = RD0;
    if(RD0_Bit31 == 0) goto L_TEST0_1;        
    CPU_WorkDisable; 

L_TEST0_END:
*/

    call Send_DAC;        
    goto Loop;


    




////////////////////////////
//		L_Data_Err
////////////////////////////
L_Data_Err:
	    CPU_SimpleLevel_L;
	    CPU_SimpleLevel_H;    
	    CPU_SimpleLevel_L;
	    nop;
	    CPU_SimpleLevel_H;  
	    CPU_SimpleLevel_L;
	    nop;nop;
	    CPU_SimpleLevel_H;  
	    goto L_Data_Err;
	



////////////////////////////////////////////////////////
//  ��������:
//      _Mem_Copy1F
//  ��������:
//      ����1֡��64�ֽڣ�����
//  ��ڲ���:
//      RD0:Դ��ַ
//      RA2:Ŀ��
//  ���ڲ���:
//      �ޣ��ƻ�RA2
//2021/11/6 16:29:49 FOR SIMULATION
////////////////////////////////////////////////////////
Sub_AutoField _Mem_Copy1F;
	RA0 = RD0;
	RD2 = 16;
L_Mem_Copy1F_L0:
	RD0 = M[RA0++];
	RA0 += MMU_BASE;
	M[RA2++] = RD0;
	RD2 --;
	if(RQ_nZero) goto L_Mem_Copy1F_L0;
	Return_AutoField(0*MMU_BASE);

////////////////////////////////////////////////////////
//  ��������:
//      UART1_Initial
//  ��������:
//      ��ʼ��UART_COM1
//      GP05 : Tx    GP06 : Rx
//  ��ڲ���:
//      ��
//  ���ڲ���:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField UART1_Initial;
	//GP0_5  UART_COM1_Tx
    RD0 = GP0_5;
    GPIO_WEn0 = RD0;
    RD0 = GPIO_OUT|GPIO_PULL;
    GPIO_Set0 = RD0;
    //GP0_6  UART_COM1_Rx
    RD0 = GP0_6;
    GPIO_WEn0 = RD0;
    RD0 = GPIO_IN|GPIO_PULL;
    GPIO_Set0 = RD0;

	RD0 = COM1;
	send_para(RD0);
	RD0 = 0x52faa192;  //��Ƶ32M,115200 bps
	send_para(RD0);
	RD0 = 2;
	send_para(RD0);
	RD0 = 0;
	send_para(RD0);
	call UART_Init;

	Return_AutoField(0*MMU_BASE);

//=========================================
//���ܣ�PWM����
//��ڣ�1���˿���
//      2��������
//      3������
//���ڣ� ��
//�ƻ���RD0
//=========================================
Sub_AutoField _PWM_Config;

    RD0 = M[RSP+2*MMU_BASE];
    USI_Num = RD0;

    USI_Disable;

    RD0 = M[RSP+0*MMU_BASE];
    send_para(RD0);
    call _Timer_Number;

    USI_Enable;
    USI_SelPort = Config_Port;
    RD1 = 0b110010000000010;
    USI_Data = RD1;

    USI_SelPort = Counter1_Port;    //д����
    USI_Data = RD0;

    USI_SelPort = Counter0_Port;    //д����
    RD0 = M[RSP+1*MMU_BASE];
    USI_Data = RD0;

    RD0 = 0;
    USI_SelPort = Counter2_Port|Data_Port;
    USI_Data = RD0; //��ʼ���Ĵ���״̬���������ڼ�����
    USI_StartCnt0;  //�������������

    Return_AutoField(3*MMU_BASE);


    
//////////////////////////////////////////////////////////////////////////
//  ����:
//      SPI_Export_IO_Init;
//  ����:
//      SPI�������IO��ʼ��
//  ����:
//      ��
//  ����ֵ��
//      ��
//  ע�ͣ�
//      Speed3������
//////////////////////////////////////////////////////////////////////////
Sub SPI_Export_IO_Init;
    // GP0_5 SPI_MOSI
    // GP0_7 SPI_CLK
    RD0 = GP0_4;
    GPIO_WEn0 = RD0;
    RD0 = GPIO_IN;
    GPIO_Set0 = RD0;
    RD0 = GP0_5|GP0_7;
    GPIO_WEn0 = RD0;
    RD0 = GPIO_OUT;
    GPIO_Set0 = RD0;
    RD0 = COM1;
    RD1 = RN_SPI_CLK_CFG;
    call SPI_Master_Init;
    return(0);    
    

END SEGMENT


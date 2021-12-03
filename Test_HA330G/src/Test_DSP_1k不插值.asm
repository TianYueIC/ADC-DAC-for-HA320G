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

    RD0 = RN_GRAM3;
    RA1 = RD0;
	//д��������
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
    RD0 = DMA_PATH0;
    M[RA1] = RD0;
    MemSet_Disable;     //���ý���
    
    CPU_WorkEnable;
    CPU_SimpleLevel_H;
    RD0 = 0x30fb0000;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0x76415a82;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0x76417fff;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0x30fb5a82;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0xcf050000;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0x89bfa57e;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0x89bf8001;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0xcf05a57e;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0x30fb0000;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0x76415a82;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0x76417fff;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0x30fb5a82;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0xcf050000;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0x89bfa57e;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0x89bf8001;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    RD0 = 0xcf05a57e;
    M[RA1++] = RD0;
    RD0 = 0;
    M[RA1++] = RD0;
    CPU_WorkDisable;
		
		
			//��ʼ���ԣ��ȴ�����GP0-3
L_Wait_Key0:
	
	CPU_SimpleLevel_L;
	nop; nop; nop; nop;
	RD0 = GPIO_Data0;
#ifdef OnBoardChip_test
	//if(RD0_Bit3 == 1) goto L_Wait_Key0;
#endif
   
//    RD0 = RN_ADCPORT_AGC0;
//    RD1 = 0xFF;
//    ////Try ADC
//    ADC_CPUCtrl_Enable;
//    //����ADC0    
//    ADC_PortSel = RD0;
//    //RD0 = 0x7F;
//    ADC_Cfg = RD1;
//    RD0 = 0;
//    ADC_PortSel = RD0;
//    ADC_CPUCtrl_Disable;  
    
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

    //1kHz�����ź�
    RD0 = 0x30fb0000;
    M[RA1++] = RD0;
    RD0 = 0x76415a82;
    M[RA1++] = RD0;
    RD0 = 0x76417ffe;//
    M[RA1++] = RD0;
    RD0 = 0x30fb5a82;
    M[RA1++] = RD0;
    RD0 = 0xcf050000;
    M[RA1++] = RD0;
    RD0 = 0x89bfa57e;
    M[RA1++] = RD0;
    RD0 = 0x89bf8001;
    M[RA1++] = RD0;
    RD0 = 0xcf05a57e;
    M[RA1++] = RD0;
    RD0 = 0x30fb0000;
    M[RA1++] = RD0;
    RD0 = 0x76415a82;
    M[RA1++] = RD0;
    RD0 = 0x76417ffe;//
    M[RA1++] = RD0;
    RD0 = 0x30fb5a82;
    M[RA1++] = RD0;
    RD0 = 0xcf050000;
    M[RA1++] = RD0;
    RD0 = 0x89bfa57e;
    M[RA1++] = RD0;
    RD0 = 0x89bf8001;
    M[RA1++] = RD0;
    RD0 = 0xcf05a57e;
    M[RA1++] = RD0;
    CPU_WorkDisable;   


//�˴����޸��㷨����Ƶ����RN_GRAM_IN
//RD1 = 0xffff8888;
//send_para(RD1);
//call UART_PutDword_COM1;
//RD1 = 0xffff8888;
//send_para(RD1);
//call UART_PutDword_COM1;
//RD1 = 0xffff8888;
//send_para(RD1);
//call UART_PutDword_COM1;




//	RD0 = RN_GRAM3;
//    RA0 = RD0;
//	RD0 = RN_GRAM0;
//    RA1 = RD0;
//    RD0 = 0;
//    call _GetADC_Ave_Max_Min;



//�������� ������
//GPIO7���¼�С������GPIO3������������
//ÿ�ε���ʱ����ӡ��ǰ֡g_DAC_Cfg����ӡ��һ֡����
	RD0 = GPIO_Data0;
	if(RD0_Bit7 == 0) goto L_TEST_1;
	goto  L_TEST_END;   
L_TEST_1:
    nop;nop;
	RD0 = GPIO_Data0;
	if(RD0_Bit7 == 0) goto L_TEST_1;

RD1 = g_DAC_Cfg;
send_para(RD1);
call UART_PutDword_COM1;
    RD0 = g_Vol;
    RD0 -= 1;
    g_Vol = RD0;
send_para(RD0);
call UART_PutDword_COM1;
L_TEST_END:
	RD0 = GPIO_Data0;
	if(RD0_Bit3 == 0) goto L_TEST_2;
	goto  L_TEST_END1;   
L_TEST_2:
    nop;nop;
	RD0 = GPIO_Data0;
	if(RD0_Bit3 == 0) goto L_TEST_2;
RD1 = g_DAC_Cfg;
send_para(RD1);
call UART_PutDword_COM1;
    RD0 = g_Vol;
    RD0 += 1;
    g_Vol = RD0;
send_para(RD0);
call UART_PutDword_COM1;

L_TEST_END1:
/////////������������

//    RD0 = RN_GRAM0;
//    RA0 = RD0;
//    RD0 = RN_GRAM0;
//    RA1 = RD0;
//    RD0 = FL_M88_A1;
//    call _IIR_PATH3_HP;

/*
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

    //1kHz�����ź�
    if(RFlag_Flow2Bank0==1) goto L_halfSin;
RD0 = 0x7d877d87; M[RA1++] = RD0;
RD0 = 0x763f763f; M[RA1++] = RD0;
RD0 = 0x6a6b6a6b; M[RA1++] = RD0;
RD0 = 0x5a805a80; M[RA1++] = RD0;
RD0 = 0x471b471b; M[RA1++] = RD0;
RD0 = 0x30fb30fb; M[RA1++] = RD0;
RD0 = 0x18f818f8; M[RA1++] = RD0;
RD0 = 0x00000000; M[RA1++] = RD0;
RD0 = 0xe708e708; M[RA1++] = RD0;
RD0 = 0xcf05cf05; M[RA1++] = RD0;
RD0 = 0xb8e5b8e5; M[RA1++] = RD0;
RD0 = 0xa580a580; M[RA1++] = RD0;
RD0 = 0x95959595; M[RA1++] = RD0;
RD0 = 0x89c189c1; M[RA1++] = RD0;
RD0 = 0x82798279; M[RA1++] = RD0;
RD0 = 0x80038003; M[RA1++] = RD0;

goto L_DATA_pre_finish;
L_halfSin:
RD0 = 0x82798279; M[RA1++] = RD0;
RD0 = 0x89c189c1; M[RA1++] = RD0;
RD0 = 0x95959595; M[RA1++] = RD0;
RD0 = 0xa580a580; M[RA1++] = RD0;
RD0 = 0xb8e5b8e5; M[RA1++] = RD0;
RD0 = 0xcf05cf05; M[RA1++] = RD0;
RD0 = 0xe708e708; M[RA1++] = RD0;
RD0 = 0x00000000; M[RA1++] = RD0;
RD0 = 0x18f818f8; M[RA1++] = RD0;
RD0 = 0x30fb30fb; M[RA1++] = RD0;
RD0 = 0x471b471b; M[RA1++] = RD0;
RD0 = 0x5a805a80; M[RA1++] = RD0;
RD0 = 0x6a6b6a6b; M[RA1++] = RD0;
RD0 = 0x763f763f; M[RA1++] = RD0;
RD0 = 0x7d877d87; M[RA1++] = RD0;
RD0 = 0x7ffd7ffd; M[RA1++] = RD0;

L_DATA_pre_finish:
    CPU_WorkDisable;  

//    RD0 = RN_GRAM_IN; 
//    call DATA_XX;   //��ԭֵ    
//    
//    RD0 = RN_GRAM_IN;
//    RA0 = RD0;
//    RD0 = FlowRAM_Addr0;
//    RA1 = RD0;   
//    if(RFlag_Flow2Bank0==0) goto L_Send;
//    CPU_SimpleLevel_L;    
//    RD0 = FlowRAM_Addr1;
//    RA1 = RD0;   
//L_Send:    
//    RD0 = 0;
//    call _Send_DAC_SignSftR_RndOff;
//    
//    //֡�������ۼ�
//    g_Cnt_Frame ++;  
*/    
    
    
    
    
    call Send_DAC;
    
//RD1 = RN_SP3;
//RP_B15;
//Set_Pulse_Ext8;
//nop;nop;    
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
//      Get_ADC
//  ����:
//      ��ADC���1֡����
//  ����:
//      ��
//  ����ֵ��
//			RD0 == 0 :�����һ֡����
//			RD0 != 0 :δ�ܻ������
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Get_ADC;
		
    //�������������
    RD0 = g_Cnt_Frame;
    if(RD0_Bit0==0) goto L_Get_ADC_AD_Even;
    // ��ѯ����֡����
    RD1 = FlowRAM_Addr1;	//Դ��ַΪFlowRAM_Addr1������֡��
    if(RFlag_Flow2Bank0==1) goto L_Get_ADC_DATA;
    Return_AutoField(0*MMU_BASE);	//û�������ݣ����أ�RD0Ϊ֡����ֵ������
L_Get_ADC_AD_Even:
    // ��ѯż��֡����
    RD1 = FlowRAM_Addr0;	//Դ��ַΪFlowRAM_Addr0��ż��֡��
    if(RFlag_Flow2Bank0==0) goto L_Get_ADC_DATA;
    Return_AutoField(0*MMU_BASE);	//û�������ݣ����أ�RD0Ϊ֡����ֵ������
    
    //��������
L_Get_ADC_DATA:
////�鵽���ݣ��л�S5
//RD2 = RD1;
//RD1 = RN_SP5;
//RP_B15;
//Set_Pulse_Ext8;
//nop;nop;
//RD1 = RD2

    RA0 = RD1;
//
    //����DAC_CFG
    RD0 = g_DAC_Cfg; 
    CPU_WorkEnable;
    DAC_CFG = RD0;
    CPU_WorkDisable;
        
    call Get_ADC_Function;

	RD0 = 0;
    Return_AutoField(0*MMU_BASE);

//////////////////////////////////////////////////////////////////////////
//  ����:
//      Find_n_k
//  ����:
//      ͨ�����������n��k��������=6*n+k��0<=k<6
//  ����:
//      RD0:��������32bit�з�����
//  ����ֵ��
//		RD0:k
//      RD1:-n
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Find_n_k;
    if(RD0_Bit31 ==1) goto L_Find_n_k_0;
    if(RD0_nZero) goto L_Find_n_k_1;
    //0dB
    RD0 = 0;
    RD1 = 0;
    goto L_Find_n_k_End;    
L_Find_n_k_1:        
    // ������0-12dB    
    RD0 -= 6;
    if(RD0_nZero) goto L_Find_n_k_2;
    // 6dB
    RD0 = 0;
    RD1 = -1;
    goto L_Find_n_k_End;        
L_Find_n_k_2:
    if(RD0_Bit31 == 0) goto L_Find_n_k_3;
    // 1-5dB
    RF_Neg(RD0);    //-(n-6)
    RD1 = -1;   //n
    goto L_Find_n_k_End;
L_Find_n_k_3:
    // >=7dB
    RD0 = 0;
    RD1 = -2;    
    goto L_Find_n_k_End;
  
//2021/11/28 15:18:59 ������������ʱ����΢��    
//    RD0 -= 6;
//    if(RQ_nBorrow) goto L_Find_n_k_4;
//    // 7-11dB
//    RF_Neg(RD0);    //-(n-12)
//    RD1 = -2;   //n
//    goto L_Find_n_k_End;
//L_Find_n_k_4:
//    // >=12dB  
//    RD0 = 0;
//    RD1 = -2;
//    goto L_Find_n_k_End;    
    
L_Find_n_k_0:  
    //������Ϊ����
    RF_Neg(RD0);    // �������󸺱����㷨���
    RD2 = RD0;
    RD0 -= 72;  /////////////////////////////�ݶ���С��������ֵ
    if(RQ_Borrow) goto L_Find_n_k_6;
    //С�����ض�
    RD0 = 0;
    RD1 = 12;   /////////////////////////////С��������ֵ/6������С��������ֵһ������  
    goto L_Find_n_k_End;    
    
L_Find_n_k_6:       //������Χ��
    RD0 = RD2;
    RD1 = -1;       //n
L_Find_n_k_5:
    RD1 ++;  
    RD0 -= 6;
    if(RD0_Bit31 == 0) goto L_Find_n_k_5;   
    RD0 += 6;       //����k��������=6*n+k��k<6  
      
L_Find_n_k_End:
    Return_AutoField(0*MMU_BASE);

//////////////////////////////////////////////////////////////////////////
//  ����:
//      DAC_Tab
//  ����:
//      ͨ��k���ó��˷�������c
//  ����:
//      RD0:k
//  ����ֵ��
//		RD0:c
//////////////////////////////////////////////////////////////////////////
Sub_AutoField DAC_Tab;
     
    if(RD0_Zero) goto L_DAC_Tab_0;
    RD0 --;
    if(RQ_Zero) goto L_DAC_Tab_1;
    RD0 --;
    if(RQ_Zero) goto L_DAC_Tab_2;
    RD0 --;
    if(RQ_Zero) goto L_DAC_Tab_3;
    RD0 --;
    if(RQ_Zero) goto L_DAC_Tab_4;
    //����k=5
    RD0 = 0x47FA47FA;   
    goto L_DAC_Tab_End;
L_DAC_Tab_0:
    //����k=0    
    RD0 = 0;   //          
    goto L_DAC_Tab_End;
L_DAC_Tab_1:
    //����k=1,RD0=1/10^(1/20),q15
    RD0 = 0x72147214;    
    goto L_DAC_Tab_End;
L_DAC_Tab_2:
    //����k=2,RD0=1/10^(2/20),q15    
    RD0 = 0x65AC65AC;    
    goto L_DAC_Tab_End;
L_DAC_Tab_3:
    //����k=3   
    RD0 = 0x5A9D5A9D; 
    goto L_DAC_Tab_End;
L_DAC_Tab_4:
    //����k=4    
    RD0 = 0x50C350C3;   
       
L_DAC_Tab_End:
    Return_AutoField(0*MMU_BASE);


//////////////////////////////////////////////////////////////////////////
//  ����:
//      DAC_UpdateCfg
//  ����:
//      ͨ����λ��n��ȷ��DAC_Cfg��IIR��CIC�������Լ�CPU��λ��
//  ����:
//      RD0:-n
//  ����ֵ��
//      RD1: CPU��λ��
//      RD0: DAC_Cfg��IIR��CIC����
//////////////////////////////////////////////////////////////////////////
Sub_AutoField DAC_UpdateCfg;
    
    RD2 = RD0;
    RD0 -= 5;
    if(RD0_Bit31 == 1) goto L_DAC_UpdateCfg_0;   
    //n>=5������n-5λ��IIR��λ-3��Mult��λ-2
    RD1 = RD0;  //�ݴ���λֵ
    RD0 = 0x1000;
    goto L_DAC_UpdateCfg_End;

L_DAC_UpdateCfg_0:
    RD0 = RD2;
    RD0 -= 4;
    if(RD0_nZero) goto L_DAC_UpdateCfg_1;   
    //n=4������0λ��IIR��λ-3��Mult��λ-1
    RD0 = 0x1040;
    RD1 = 0;    //����0λ
    goto L_DAC_UpdateCfg_End;
    
L_DAC_UpdateCfg_1:
    RD0 = RD2;
    RD0 -= 3;
    if(RD0_nZero) goto L_DAC_UpdateCfg_2;   
    //n=3������0λ��IIR��λ-3��Mult��λ0
    RD0 = 0x1080;
    RD1 = 0;    //����0λ
    goto L_DAC_UpdateCfg_End;
        
L_DAC_UpdateCfg_2:
    RD0 = RD2;
    RD0 -= 2;
    if(RD0_nZero) goto L_DAC_UpdateCfg_3;   
    //n=2������0λ��IIR��λ-2��Mult��λ0
    RD0 = 0x2080;
    RD1 = 0;    //����0λ
    goto L_DAC_UpdateCfg_End;    
    
L_DAC_UpdateCfg_3:
    RD0 = RD2;
    RD0 -= 1;
    if(RD0_nZero) goto L_DAC_UpdateCfg_4;   
    //n=1������0λ��IIR��λ-1��Mult��λ0
    RD0 = 0x4080;
    RD1 = 0;    //����0λ
    goto L_DAC_UpdateCfg_End;      
        
L_DAC_UpdateCfg_4:
    RD0 = RD2;
    if(RD0_nZero) goto L_DAC_UpdateCfg_5;   
    //n=0������0λ��IIR��λ0��Mult��λ0
    RD0 = 0x8080;
    RD1 = 0;    //����0λ
    goto L_DAC_UpdateCfg_End;      

L_DAC_UpdateCfg_5:
    RD0 = RD2;
    RD0 ++;
    if(RD0_nZero) goto L_DAC_UpdateCfg_6;   
    //n=-1������0λ��IIR��λ0��Mult��λ1
    RD0 = 0x80C0;
    RD1 = 0;    //����0λ
    goto L_DAC_UpdateCfg_End;      
    
L_DAC_UpdateCfg_6:
    //n=-2������0λ��IIR��λ1��Mult��λ1
    RD0 = 0xF0C0;
    RD1 = 0;    //����0λ
    
L_DAC_UpdateCfg_End:    
    Return_AutoField(0*MMU_BASE);

//////////////////////////////////////////////////////////////////////////
//  ����:
//      Send_DAC
//  ����:
//      ��DAC����1֡����
//  ����:
//      ��
//  ����ֵ��
//		��
//  ˵����
//      g_DAC_Cfg: bit15-12:IIR������棻bit7 6��CIC������档1000 10��Ĭ��ֵ����ʱ0dB
//      g_Vol��������λ��dB�����ݶ�32bit������
//      g_Weight_Frame_0����8λΪ��ǰ֡Ȩλ(*2)��С������bit1�ϡ�����0b1111��ʾ-0.5
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Send_DAC;
	
    RD0 = g_Weight_Frame_0;   //��8λΪ��ǰ֡Ȩλ(*2)
    RF_GetH8(RD0);
    RD0_SignExtL8;
    RD1 = RD0;
    RD0 += RD1;
    RD0 += RD1;     //RD0*3,�൱��ȨλE*6
    RD0 += 6;       //2021/11/28 15:11:58�޸ģ�CIC��ʼ��λ0b10��Ϊ0b11
    RD0 += g_Vol;   //������=6*E+����ֵ
    
    call Find_n_k;
    RD2 = RD1;  //n

    call DAC_Tab;
    RD3 = RD0;  // �����c��RD3��        
    RD0 = RD2;
    call DAC_UpdateCfg;

    RD2 = RD0;  // DAC_Cfg��IIR��CIC����
	RD0 = g_DAC_Cfg;
    RD0_ClrBit6;
    RD0_ClrBit7;
    RD0_ClrBit12;
    RD0_ClrBit13;
    RD0_ClrBit14;
    RD0_ClrBit15;   //g_DAC_Cfg��ʼ������������λ
    RD0 += RD2;
    g_DAC_Cfg = RD0;

    //�Ƚ��г˷�
    RD0 = RD3;  //c��RD3��
    RD3 = RD1;  //��λ����

    if(RD0_Zero) goto L_Send_DAC_Odd;   //6��������������˷�
    RD1 = RD0;    
	RD0 = RN_GRAM_IN; 
    RA0 = RD0;
	RD0 = RN_GRAM_IN; 
    RA1 = RD0;
    RD0 = RD1;
    call _MAC_RffC;          

L_Send_DAC_Odd:
    
    RD0 = RN_GRAM_IN; 
    call DATA_XX;   //��ԭֵ    
        
	RD1 = FlowRAM_Addr1;	
    RD0 = g_Cnt_Frame;
    if(RD0_Bit0==1) goto L_Send_DAC_Even;
	RD1 = FlowRAM_Addr0;	
L_Send_DAC_Even:
    
    //��λ
	RD0 = RN_GRAM_IN;
    RA0 = RD0;
    RA1 = RD1;
    RD0 = RD3;
    call _Send_DAC_SignSftR_RndOff;
    
    //����g_Weight_Frame_0
    RD1 = g_Weight_Frame_0;   //��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������ 
    RF_GetMH8(RD1);
    RF_RotateR8(RD1);
    RD0 = g_Weight_Frame_0;   //��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������ 
    RD0_ClrByteH8;
    RD0 += RD1;
    g_Weight_Frame_0 = RD0;

    //֡�������ۼ�
    g_Cnt_Frame ++;    
     
    Return_AutoField(0*MMU_BASE);    
    
    
//////////////////////////////////////////////////////////////////////////
//  ����:
//      DATA_XX 
//  ����:
//      ��ԭֵ
//  ����:
//      RD0 : Դ��ַ
//  ����ֵ��
//		��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField DATA_XX;

    push RA2;
    
    RA2 = RD0;
    RA0 = RD0;
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
    RD0 = DMA_PATH0;
    M[RA0] = RD0;
    MemSet_Disable;     //���ý���

    //����128�ֽڻ�����
    RD0 = 32*MMU_BASE;
    RSP -= RD0;
    RA1 = RSP;   

    CPU_WorkEnable;
    //�������ڲ�,��������
    RD2 = 16;
L_DATA_XX_L0:
    RD3 = M[RA0++];
    RD0 = RD3;
    RF_GetL16(RD0);
    RD1 = RD0;
    RF_RotateR16(RD1);
    RD0 += RD1;
    
    M[RA1++] = RD0;
    RD0 = RD3;
    RF_GetH16(RD0);
    RD1 = RD0;
    RF_RotateR16(RD1);
    RD0 += RD1;
    
    M[RA1++] = RD0;
    
    RD2 --;
    if(RQ_nZero) goto L_DATA_XX_L0;

    //������ԭ��ַ
    RD0 = RA2;
    RA0 = RD0;
    RA1 = RSP;
    RD2 = 16;
L_DATA_XX_L1:
    RD0 = M[RA1++];
    M[RA0++] = RD0;
    RD0 = M[RA1++];
    M[RA0++] = RD0;
    RD2 --;
    if(RQ_nZero) goto L_DATA_XX_L1;
    CPU_WorkDisable;

    //�ͷ�128�ֽڻ�����
    RD0 = 32*MMU_BASE;
    RSP += RD0;
    
    pop RA2;
    Return_AutoField(0);

//////////////////////////////////////////////////////////////////////////
//  ����:
//      ADC0_Weight
//  ����:
//      �����ۼӺͼ�����
//  ����:
//      RD0 : ��ǰ֡�ۼӺͣ���Ȩλ��
//  ����ֵ��
//		��
//  ȫ�ֱ�����
//      g_Weight_Frame_0��  ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
//      g_ADC_DC_0:         �ۼӺͼ�������Ȩλ0��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField ADC0_Weight;

    // ����֡Ȩλ�������ۼӺͣ�ʹȨλ��0
    RD1 = RD0;
    RD0 = g_Weight_Frame_0;     // ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
    RF_GetH8(RD0);              // ��ǰ֡Ȩλ
    if(RD0_Zero) goto L_ADC_Weight_End; 
    RD0_SignExtL8;   
    if(RD0_Bit3 == 0) goto L_ADC_Weight_0;
    // ȨλΪ����
    if(RD0_Bit0 == 0) goto L_ADC_Weight_1;
    RD0 --; //-2.5����-3���㣬-3.5����-4����
L_ADC_Weight_1:
    RF_Sft32SR1(RD1);
    RD0 ++;
    RD0 ++;
    if(RD0_nZero) goto L_ADC_Weight_1;
    goto L_ADC_Weight_End;
L_ADC_Weight_0:
    // ȨλΪ2
    RF_ShiftL2(RD1);     
L_ADC_Weight_End:   // ��ǰ֡�ۼӺ���RD1�ϣ�Ȩλ0��            
        
    //ƽ��ֵ�ۼ��� += ��ǰ֡�ۼӺͣ�Ȩλ0��
    RD0 = g_ADC_DC_0;
    RD0 += RD1;
    g_ADC_DC_0 = RD0;   
    
    Return_AutoField(0);
        
//////////////////////////////////////////////////////////////////////////
//  ����:
//      ADC0_C0
//  ����:
//      ��ǰ512֡ƽ��ֵ��Ȩλ0��������ǰ֡Ȩλ
//  ����:
//      ��
//  ����ֵ��
//		RD0:�����͸�ʽ����Ҫ��ȥ��ֱ��ֵ���ⲿ����Ȩ�ض��룬��ƴ��ΪH16��L16��ʽ������ǰ512֡ƽ��ֵ��Ȩλͬ����
//  ȫ�ֱ�����
//      g_Weight_Frame_0��      ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
//		g_LastBank_Average_0    ��8λΪֱ������ֵ����16λΪǰ512֡ƽ��ֵ��ȨλΪ0��bit16Ϊ��ǰ�飨512֡���Ƿ�Ĺ���λ�ı�־λ��1���Ĺ���0��δ�Ĺ� 
//////////////////////////////////////////////////////////////////////////
Sub_AutoField ADC0_C0;
    
    RD0 = g_LastBank_Average_0;
    RD0_SignExtL16;     //ǰ512֡ƽ��ֵ��Ȩλ0��

    // ����֡Ȩλ������ƽ��ֵ��ʹȨλ��0
    RD1 = RD0;
    RD0 = g_Weight_Frame_0;     // ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
    RF_GetH8(RD0);              // ��ǰ֡Ȩλ
    if(RD0_Zero) goto L_ADC0_C0_End; 
    RD0_SignExtL8;   
    if(RD0_Bit3 == 0) goto L_ADC0_C0_0;
    // ȨλΪ����
    if(RD0_Bit0 == 0) goto L_ADC0_C0_1;
    RD0 --; //-2.5����-3���㣬-3.5����-4����
L_ADC0_C0_1:
    RF_ShiftL1(RD1);     
    RD0 ++;
    RD0 ++;
    if(RD0_nZero) goto L_ADC0_C0_1;
    goto L_ADC0_C0_End;
L_ADC0_C0_0:
    // ȨλΪ2
    RF_Sft32SR2(RD1);
L_ADC0_C0_End:             
    //RD1:ǰ512֡ƽ��ֵ��Ȩλͬ����
    RD0 = RD1;
	RD0_ClrByteH16;
	RD1 = RD0;
	RF_RotateL16(RD0);
	RD0 += RD1; //RD0:��Ҫ��RA0�м�ȥ��ֱ��ֵ���ⲿ����Ȩ�ض��룬��ƴ��ΪH16��L16��ʽ��      
    
    Return_AutoField(0);
//////////////////////////////////////////////////////////////////////////
//  ����:
//      ADC0_SmallSignal
//  ����:
//      ADC0С�źŴ���
//  ����:
//      RD0:Vpp
//  ����ֵ��
//		RD0:    0:��ǰ����С�ź�֡��1:��ǰ������С�ź�֡
//  ȫ�ֱ�����
//      g_Weight_Frame_0��      ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
//		g_ADC_CFG_0;            ��16λADCǰ�÷Ŵ�������ֵ����16λADC_CFG�˿�����ֵ
//////////////////////////////////////////////////////////////////////////
Sub_AutoField ADC0_SmallSignal;

    RD0_ClrBit8;
    RD0_ClrBit9;
    RD0_ClrBit10;
    RD0_ClrByteL8;
    if(RD0_Zero) goto L_ADC0_SmallSignal_0;  //Vpp<2^11
    //δ��⵽С�źţ����������������
    RD0 = g_Weight_Frame_0;         // ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
    RD0_ClrByteL16;
    g_Weight_Frame_0 = RD0;         // С�ź�֡����������
    goto L_ADC0_SmallSignal_End;     

L_ADC0_SmallSignal_0:
    //��⵽С�ź�
    RD0 = g_Weight_Frame_0;         // ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
    RD0_ClrByteH16;
    RD1 = 512;  //С�ź�֡������
    RD0 -= RD1;
    if(RD0_Zero) goto L_ADC0_SmallSignal_1; 
    //����������x֡С�źţ�������++������
    g_Weight_Frame_0 ++;
    goto L_ADC0_SmallSignal_6;  // ��ǰ֡����С�ź�֡���������źŴ���
        
L_ADC0_SmallSignal_1:           // С�źż�������꣬��������Ŵ���
    RD0 = g_Weight_Frame_0;     // ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
    RD0_ClrByteL16;             // ����������
    g_Weight_Frame_0 = RD0;
    
    RD0 = g_ADC_CFG_0;      // ��16λADCǰ�÷Ŵ�������ֵ����16λADC_CFG�˿�����ֵ
    RF_GetH16(RD0);         // ��16λADCǰ�÷Ŵ�������ֵ
    if(RD0_Bit10 == 1) goto L_ADC0_SmallSignal_6; // 27dB��λ���ѵ�����������   
    if(RD0_Bit9 == 0) goto L_ADC0_SmallSignal_2;
    // 24dB��λ������27dB��E-0.5
    RD0_SetBit10;
    RD1 = RD0;                  // �ݴ�ADCǰ�÷Ŵ�������ֵ
    RD0 = g_Weight_Frame_0;     // ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
    RF_GetH8(RD0);              // ��ǰ֡Ȩλ��*2��
    RD0 --;
    RD0_ClrByteH24;            
    RF_RotateL16(RD0);
    RD2 = RD0;    
    RD0 = g_Weight_Frame_0;     // ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
    RD0_ClrByteMH8;    
    RD0 += RD2;
    g_Weight_Frame_0 = RD0;
    goto L_ADC0_SmallSignal_5;    
L_ADC0_SmallSignal_2:
    if(RD0_Bit1 == 1) goto L_ADC0_SmallSignal_3;
    //��ǰΪ-6dB,����6dB,Ȩλ��0��E-2
    RD0_SetBit1;
    RD0_SetBit2;
    RD0_SetBit3;
    RD1 = RD0;                  // �ݴ�ADCǰ�÷Ŵ�������ֵ
    RD0 = g_Weight_Frame_0;     // ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
    RD0_ClrByteMH8;    
    g_Weight_Frame_0 = RD0;     // ��һ֡ȨλΪ0        
    goto L_ADC0_SmallSignal_5;    
L_ADC0_SmallSignal_3:
    RD0 = g_Weight_Frame_0;     // ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
    RF_GetH8(RD0);              // ��ǰ֡Ȩλ��*2��
    RD0 -= 4;
    if(RD0_nZero) goto L_ADC0_SmallSignal_4;
    //��ǰ֡ȨλΪ2��Ȩλ��0,E-2    
    RD0 = g_ADC_CFG_0;      // ��16λADCǰ�÷Ŵ�������ֵ����16λADC_CFG�˿�����ֵ
    RF_GetH16(RD0);         // ��16λADCǰ�÷Ŵ�������ֵ
    RF_ShiftL2(RD0);
    RF_ShiftL2(RD0);
    RD0 += 15;  
    RD1 = RD0;                  // �ݴ�ADCǰ�÷Ŵ�������ֵ
    RD0 = g_Weight_Frame_0;     // ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
    RD0_ClrByteMH8;    
    g_Weight_Frame_0 = RD0;     // ��һ֡ȨλΪ0        
    goto L_ADC0_SmallSignal_5;    
L_ADC0_SmallSignal_4:    
    //��������������6dB,E-1
    RD0 = g_ADC_CFG_0;      // ��16λADCǰ�÷Ŵ�������ֵ����16λADC_CFG�˿�����ֵ
    RF_GetH16(RD0);         // ��16λADCǰ�÷Ŵ�������ֵ
    RF_ShiftL2(RD0);
    RD0 += 3;  
    RD1 = RD0;                  // �ݴ�ADCǰ�÷Ŵ�������ֵ
    RD0 = g_Weight_Frame_0;     // ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
    RF_GetH8(RD0);              // ��ǰ֡Ȩλ��*2��
    RD0 --;
    RD0 --;
    RD0_ClrByteH24;            
    RF_RotateL16(RD0);
    RD2 = RD0;    
    RD0 = g_Weight_Frame_0;     // ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
    RD0_ClrByteMH8;    
    RD0 += RD2;
    g_Weight_Frame_0 = RD0;

L_ADC0_SmallSignal_5:
    RD0 = g_LastBank_Average_0;   //bit16Ϊ��ǰ�飨512֡���Ƿ�Ĺ���λ�ı�־λ
    RD0_SetBit16;        
    g_LastBank_Average_0 = RD0;
    RD0 = g_ADC_CFG_0;        // ��16λADCǰ�÷Ŵ�������ֵ����16λADC_CFG�˿�����ֵ 
    RD0_ClrByteH16;       
    RF_RotateL16(RD1);
    RD0 += RD1;    
    g_ADC_CFG_0 = RD0;

    //ADC_Cfg����
    RD0 = g_ADC_CFG_0;
    RF_GetH16(RD0);
    RD1 = RD0;     
    RD0 = RN_ADCPORT_AGC0;
    ////Try ADC
    ADC_CPUCtrl_Enable;
    //����ADC0    
    ADC_PortSel = RD0;
    ADC_Cfg = RD1;
    RD0 = 0;
    ADC_PortSel = RD0;
    ADC_CPUCtrl_Disable;

    //����DAC_CFG
    RD0 = g_DAC_Cfg; 
    CPU_WorkEnable;
    DAC_CFG = RD0;
    CPU_WorkDisable;
L_ADC0_SmallSignal_6:    
    RD0 = 0;       
    Return_AutoField(0);

L_ADC0_SmallSignal_End: 
    RD0 = 1; 
    Return_AutoField(0);


//////////////////////////////////////////////////////////////////////////
//  ����:
//      ADC0_StrongSignal
//  ����:
//      ADC0���źŴ���
//  ����:
//      RD0:Vpp
//  ����ֵ��
//		��
//  ȫ�ֱ�����
//      g_Weight_Frame_0��      ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
//		g_ADC_CFG_0;            ��16λADCǰ�÷Ŵ�������ֵ����16λADC_CFG�˿�����ֵ
//////////////////////////////////////////////////////////////////////////
Sub_AutoField ADC0_StrongSignal;

    if(RD0_Bit15 == 0) goto L_ADC0_StrongSignal_End; 
    if(RD0_Bit14 == 0) goto L_ADC0_StrongSignal_End; 
    //bit14 15��Ϊ1����������
    
    RD0 = g_Weight_Frame_0;     // ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
    RF_GetH8(RD0);             
    RD0 -= 4;
    if(RD0_Zero) goto L_ADC0_StrongSignal_End;  //��ǰȨλΪ2���޷���С������
    RD0 = g_Weight_Frame_0;     // ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������        
    if(RD0_Bit24 == 0) goto L_ADC0_StrongSignal_0;
    //��ǰ֡Ϊ.5Ȩλ������24dB,E+0.5
    RD0 = g_ADC_CFG_0;          // ��16λADCǰ�÷Ŵ�������ֵ����16λADC_CFG�˿�����ֵ
    RF_GetH16(RD0);             // ��16λADCǰ�÷Ŵ�������ֵ
    RD0_ClrBit10;
    RD1 = RD0;                  // �ݴ�ADCǰ�÷Ŵ�������ֵ
    RD0 = g_Weight_Frame_0;     // ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
    RF_GetH8(RD0);              // ��ǰ֡Ȩλ��*2��
    RD0 ++;
    RF_RotateL16(RD0);
    RD2 = RD0;    
    RD0 = g_Weight_Frame_0;     // ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
    RD0_ClrByteMH8;    
    RD0 += RD2;
    g_Weight_Frame_0 = RD0;
    goto L_ADC0_StrongSignal_3;       
L_ADC0_StrongSignal_0:
    //��.5Ȩλ
    RD0 = g_ADC_CFG_0;          // ��16λADCǰ�÷Ŵ�������ֵ����16λADC_CFG�˿�����ֵ
    RF_GetH16(RD0);             // ��16λADCǰ�÷Ŵ����Ŵ���
    if(RD0_Bit4 == 1) goto L_ADC0_StrongSignal_1;
    //��ǰ6dB,�����Ϊ-6dB,E=2
//2021/12/2 9:29:29 ���ɣ���ǰ6dBȨλ2�Ŀ���û����
    RD0_ClrBit1;    
    RD0_ClrBit2;    
    RD0_ClrBit3;    
    RD1 = RD0;                  // �ݴ�ADCǰ�÷Ŵ�������ֵ
    RD0 = g_Weight_Frame_0;     // ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
    RD0_ClrByteMH8;
    RD0_SetBit18;        
    g_Weight_Frame_0 = RD0;     // ��һ֡ȨλΪ2        
    goto L_ADC0_StrongSignal_3;          
L_ADC0_StrongSignal_1:    
    RD0 = g_Weight_Frame_0;     // ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
    RF_GetH8(RD0);              // ��ǰ֡Ȩλ��*2��
    if(RD0_nZero) goto L_ADC0_StrongSignal_2;

//2021/12/2 11:35:51����E=2
goto L_ADC0_StrongSignal_End;

    //��ǰ֡ȨλΪ0������-12dB,E=2
    RD0 = g_ADC_CFG_0;          // ��16λADCǰ�÷Ŵ�������ֵ����16λADC_CFG�˿�����ֵ
    RF_GetH16(RD0);             // ��16λADCǰ�÷Ŵ�������ֵ
    RF_ShiftR2(RD0);
    RF_ShiftR2(RD0);            // �������ñ�������λ
    RD1 = RD0;                  // �ݴ�ADCǰ�÷Ŵ�������ֵ
    RD0 = g_Weight_Frame_0;     // ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
    RD0_ClrByteMH8;
    RD0_SetBit18;        
    g_Weight_Frame_0 = RD0;     // ��һ֡ȨλΪ2        
    goto L_ADC0_StrongSignal_3;
L_ADC0_StrongSignal_2:
    //�������������-6dB,E+1
    RD0 = g_ADC_CFG_0;          // ��16λADCǰ�÷Ŵ�������ֵ����16λADC_CFG�˿�����ֵ
    RF_GetH16(RD0);         // ��16λADCǰ�÷Ŵ�������ֵ
    RF_ShiftR2(RD0);        // �������ñ�����2λ
    RD1 = RD0;              // �ݴ�ADCǰ�÷Ŵ�������ֵ
    RD0 = g_Weight_Frame_0; // ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
    RF_GetH8(RD0);          // ��ǰ֡Ȩλ��*2��
    RD0 ++;
    RD0 ++;
    RF_RotateL16(RD0);
    RD2 = RD0;    
    RD0 = g_Weight_Frame_0;   // ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
    RD0_ClrByteMH8;    
    RD0 += RD2;
    g_Weight_Frame_0 = RD0;
    
L_ADC0_StrongSignal_3:
    //���ݵ�λ���õ�ǰ֡Ȩλ��ADCǰ�÷Ŵ�������ֵ
    RD0 = g_LastBank_Average_0;   //bit16Ϊ��ǰ�飨512֡���Ƿ�Ĺ���λ�ı�־λ
    RD0_SetBit16;        
    g_LastBank_Average_0 = RD0;
    RD0 = g_ADC_CFG_0;        // ��16λADCǰ�÷Ŵ�������ֵ����16λADC_CFG�˿�����ֵ 
    RD0_ClrByteH16;       
    RF_RotateL16(RD1);
    RD0 += RD1;    
    g_ADC_CFG_0 = RD0;

    //ADC_Cfg����
    RD0 = g_ADC_CFG_0;
    RF_GetH16(RD0);
    RD1 = RD0;     
    RD0 = RN_ADCPORT_AGC0;
    ////Try ADC
    ADC_CPUCtrl_Enable;
    //����ADC0    
    ADC_PortSel = RD0;
    ADC_Cfg = RD1;
    RD0 = 0;
    ADC_PortSel = RD0;
    ADC_CPUCtrl_Disable;



    //����DAC_CFG
    RD0 = g_DAC_Cfg; 
    CPU_WorkEnable;
    DAC_CFG = RD0;
    CPU_WorkDisable;    
L_ADC0_StrongSignal_End: 
     Return_AutoField(0);
       
//////////////////////////////////////////////////////////////////////////
//  ����:
//      Get_ADC_Function 
//  ����:
//      ��ADC��õ�����ͳ�ƣ��Դ�Ϊ��ȥֱ����������
//  ����:
//      ��
//  ����ֵ��
//		��
//  ˵����
//      (a)֡������,                    g_Cnt_Frame
//		(b)ÿһ·MIC��Ҫ4��ȫ�ֱ���
//			(1)֡Ȩλ                   g_Weight_Frame_0 : ��8λΪ��ǰ֡Ȩλ��*2�����и�8λΪ��һ֡Ȩλ��*2������16λΪ����С�ź�֡������
//			(2)ǰһ�飨512֡��ƽ��ֵ    g_LastBank_Average_0 : ��8λΪֱ������ֵ����16λΪǰ512֡ƽ��ֵ��ȨλΪ0��bit16Ϊ��ǰ�飨512֡?��Ƿ�Ĺ���λ�ı�־λ�?���Ĺ���0��δ�Ĺ� 
//			(3)ƽ��ֵ�ۼ���             g_ADC_DC_0 ��ƽ��ֵ�ۼ���,ȨλΪ0
//			(4)����ֵ�Ĵ���             g_ADC_CFG_0 ����16λADCǰ�÷Ŵ�������ֵ����16λADC_CFG�˿�����ֵ
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Get_ADC_Function;

    //////1������ͳ��    
	//ALU����xi-g_LastBank_Average_0��g_LastBank_Average_0��ǰһ�飨512֡�����ݵľ�ֵ
	RD0 = RN_GRAM_IN;
	RA1 = RD0;
	call ADC0_C0;   //RD0:�����͸�ʽ����Ҫ��ȥ��ֱ��ֵ���ⲿ����Ȩ�ض��룬��ƴ��ΪH16��L16��ʽ������ǰ512֡ƽ��ֵ��Ȩλͬ����
	call _GetADC_Ave_Max_Min;   //1.RD0��������ۼӺͣ���SUM(Xi-C),32bit�з����� 2.RD1�����ֵ��Vpp=Max-Min��32bit�з�����
    RD3 = RD1;  
    call ADC0_Weight;     //�����ۼӺ�     
goto L_ADC_Bias_Adj_Start;        
    //////2��AGC�������
    // 2.1С�źŴ���
    RD0 = RD3;  // Vpp
    call ADC0_SmallSignal;
    
    if(RD0_Zero) goto L_ADC_Bias_Adj_Start; //��ǰ����С�ź�֡���������źŴ���
    // 2.2���źŴ���
    RD0 = RD3;  // Vpp
    call ADC0_StrongSignal;

    //////3��ȥֱ��
L_ADC_Bias_Adj_Start:
/*
//test    
RD0 = g_Cnt_Frame;  //֡������                              
if(RD0_L8 != 0) goto L_ADC_TEST_End; 
if(RD0_Bit8 == 1) goto L_ADC_TEST_End;  //���Ƿ���512֡����������                 
if(RD0_Bit9 == 1) goto L_ADC_TEST;  //���Ƿ���512֡����������                 
//ADC_Cfg����
RD0 = 0x3;
RD1 = RD0;     
//RD0 = RN_ADCPORT_AGC0;
//////Try ADC
//ADC_CPUCtrl_Enable;
////����ADC0    
//ADC_PortSel = RD0;
//ADC_Cfg = RD1;
//RD0 = 0;
//ADC_PortSel = RD0;
//ADC_CPUCtrl_Disable;        
goto L_ADC_TEST_End;        
L_ADC_TEST:
//ADC_Cfg����
RD0 = 0xF;
RD1 = RD0;     
//RD0 = RN_ADCPORT_AGC0;
//////Try ADC
//ADC_CPUCtrl_Enable;
////����ADC0    
//ADC_PortSel = RD0;
//ADC_Cfg = RD1;
//RD0 = 0;
//ADC_PortSel = RD0;
//ADC_CPUCtrl_Disable;    
L_ADC_TEST_End:    

RD0 = 2;
L_223:
nop;
RD0 --;
if(RQ_nZero) goto L_223; 
      
RD0 = g_Cnt_Frame;  //֡������
RD0 -= 2;                              
if(RD0_L8 != 0) goto L_ADC_TEST_End1; 
if(RD0_Bit8 == 1) goto L_ADC_TEST_End1;  //���Ƿ���512֡����������                 
if(RD0_Bit9 == 1) goto L_ADC_TEST1;  
//����DAC_CFG
RD0 = 0x8083C0; 
CPU_WorkEnable;
DAC_CFG = RD0;
CPU_WorkDisable;           
goto L_ADC_TEST_End1;        
L_ADC_TEST1:
//����DAC_CFG
RD0 = 0x8043C0; 
CPU_WorkEnable;
DAC_CFG = RD0;
CPU_WorkDisable;      
L_ADC_TEST_End1:     
*/             
    RD0 = g_Cnt_Frame;  //֡������
    if(RD0_Zero) goto L_ADC_Bias_Adj_End;                      
    if(RD0_L8 != 0) goto L_ADC_Bias_Adj_End; 
    if(RD0_Bit8 == 1) goto L_ADC_Bias_Adj_End;  //���Ƿ���512֡����������                 
    call ADC0_Step;
    RD2 = RD0;          //��ǰ512֡ƽ��ֵ
//RD0 = g_Cnt_Frame;
//send_para(RD0);
//call UART_PutDword_COM1;
//send_para(RD3);
//call UART_PutDword_COM1;
//RD0 = g_Weight_Frame_0;
//send_para(RD0);
//call UART_PutDword_COM1;
//RD0 = g_LastBank_Average_0;
//send_para(RD0);
//call UART_PutDword_COM1;               

    RD0 = g_Cnt_Frame;  //֡������                              
    if(RD0_Bit9 == 1) goto L_ADC_Bias_Adj_End;  // ���Ƿ���1024֡���������߲�������         
    RD0 = g_LastBank_Average_0;                 // ��8λΪֱ������ֵ����16λΪǰ512֡ƽ��ֵ��ȨλΪ0��bit16Ϊ��ǰ�飨512֡���Ƿ�Ĺ���λ�ı�־λ��1���Ĺ���0��δ�Ĺ� 
    if(RD0_Bit16 == 0) goto L_ADC_Bias_Adj_0;   // ���Ƿ�Ĺ�AGC��λ�ı�־λ
    // ��ǰ֡�Ĺ�AGC��λ
    RD0_ClrBit16;
    g_LastBank_Average_0 = RD0;                 // �����־λ
    goto L_ADC_Bias_Adj_End;
    
L_ADC_Bias_Adj_0:   //δ�ĵ�λ
    RD0 = RD2;
    call ADC0_Bias_Adj;

L_ADC_Bias_Adj_End:    


    Return_AutoField(0*MMU_BASE);


//////////////////////////////////////////////////////////////////////////
//  ����:
//      ADC0_Bias_Adj;
//  ����:
//      ֱ������ֵ����
//  ����:
//      RD0:��ǰ512֡ƽ��ֵ
//  ����ֵ��
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField ADC0_Bias_Adj;

    RD2 = RD0;
    
    RF_Abs(RD0);
    RD0 -= 255; //ȥֱ��������ֵ
    if(RQ_Borrow) goto L_ADC0_Bias_Adj_End;     // Vpp<xʱ�����ٵ���
    RD0 = RD2;
    if(RD0_Bit15 == 0) goto L_ADC0_Bias_Adj_1;  // ��ƽ��ֵ����
    //��ֵΪ��
    RD0 = g_LastBank_Average_0;                 // ��8λΪֱ������ֵ����16λΪǰ512֡ƽ��ֵ��ȨλΪ0��bit16Ϊ��ǰ�飨512֡���Ƿ�Ĺ���λ�ı�־λ��1���Ĺ���0��δ�Ĺ�  
    RF_GetH8(RD0);  //ֱ������ֵ
    RD1 = 15;
    RD1 -= RD0;
    if(RQ == 0) goto L_ADC0_Bias_Adj_End; //�����
    //δ���
    RD0 ++;
    Volt_Vref2 = RD0;   //������λ
	RD0 = g_LastBank_Average_0;
	RD1 = 0x1000000;
	RD0 += RD1;  
    g_LastBank_Average_0 = RD0;
    goto L_ADC0_Bias_Adj_End;    
L_ADC0_Bias_Adj_1:  //��ֵΪ��
    RD0 = g_LastBank_Average_0;                   // ��8λΪֱ������ֵ����16λΪǰ512֡ƽ��ֵ��ȨλΪ0��bit16Ϊ��ǰ�飨512֡���Ƿ�Ĺ���λ�ı�־λ��1���Ĺ���0��δ�Ĺ�  
    RF_GetH8(RD0);  //ֱ������ֵ
    if(RD0 == 0) goto L_ADC0_Bias_Adj_End; //�����
    RD0 --;
    Volt_Vref2 = RD0;   //������λ        
	RD0 = g_LastBank_Average_0;
	RD1 = 0x1000000;
	RD0 -= RD1;  
    g_LastBank_Average_0 = RD0;
    
L_ADC0_Bias_Adj_End:
    
    Return_AutoField(0*MMU_BASE);

//////////////////////////////////////////////////////////////////////////
//  ����:
//      ADC0_Step;
//  ����:
//      ÿ512֡������һ��ƽ��ֵ��������ƽ��ֵ�ۼ���
//  ����:
//      ��
//  ����ֵ��
//      RD0:��ǰ512֡����ʵ��ƽ��ֵ����ԭ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField ADC0_Step;

    RD0 = g_ADC_DC_0;   //ƽ��ֵ�ۼ�����512֡�����ۼӺͣ�ÿ֡32����     
    RF_Sft32SR8(RD0); 
    RF_Sft32SR4(RD0); 
    RF_Sft32SR2(RD0);   //2^14������ƽ��ֵ X-C0 
    RD1 = RD0;  //Y=X-C0
    RF_Sft32SR2(RD1);   //1/4*Y
    RD2 = RD0;  //Y
    RD0 = g_LastBank_Average_0;   //��8λΪֱ������ֵ����16λΪǰ512֡ƽ��ֵ��ȨλΪ0�� 
    RD0_SignExtL16; //C0
    RD1 += RD0;     //1/4*Y+C0=1/4*(C1-C0)+C0,C1=X=Y+C0,��һ��ƽ��ֵӦΪC1�����Ͳ���Ϊ1/4����������
    RD0 += RD2;     //X=Y+C0
    RD2 = RD0;
    RD0 = RD1;
    RD0_ClrByteH16;    
    RD1 = RD0;
    RD0 = g_LastBank_Average_0;   //��8λΪֱ������ֵ����16λΪǰ512֡ƽ��ֵ��ȨλΪ0��    
    RD0_ClrByteL16;
    RD0 += RD1;
    g_LastBank_Average_0 = RD0;
    g_ADC_DC_0 = 0;   //ƽ��ֵ�ۼ�������
    
    RD0 = RD2;
    Return_AutoField(0*MMU_BASE);
    
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


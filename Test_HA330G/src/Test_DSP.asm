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
/*
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
*/		
		
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
*/
//�˴����޸��㷨����Ƶ����RN_GRAM_IN


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
    RA0 = RD1;        
    call Get_ADC_Function;

	RD0 = 0;
    Return_AutoField(0*MMU_BASE);

//////////////////////////////////////////////////////////////////////////
//  ����:
//      Find_k
//  ����:
//      ͨ�����������DAC��λ����ֵ���Լ�k����λ������������=-6*n-k��0<=k<6��n�ʷǸ����� 
//  ����:
//      RD0:�����棬32bit�з�����,��λdB
//  ����ֵ��
//		RD0:k
//		RD1:����λ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Find_k;

    RD2 = 0;

    if(RD0_Bit31 == 1) goto L_Find_k_0;
    if(RD0_nZero) goto L_Find_k_1;
    //0dB
    RD0 = 0x8080;
    RD1 = 0;
    goto L_Find_k_End;
        
L_Find_k_1:        
    // ������>0
    RD0 = 0xF0C0;
    RD1 = 0;
    goto L_Find_k_End;           
    
L_Find_k_0:  
    //������Ϊ����
    RD0 += 5;
    if(RD0_Bit31 == 1) goto L_Find_k_2;
    //-1~-5dB
    RD1 = 5;
    RD1 -= RD0;
    RD0 = 0x8080;
    goto L_Find_k_End;
                      
L_Find_k_2:
    RD0 += 6;
    if(RD0_Bit31 == 1) goto L_Find_k_3;
    //-6~-11dB
    RD1 = 5;
    RD1 -= RD0;
    RD0 = 0x8040;
    goto L_Find_k_End;
    
L_Find_k_3:    
    RD0 += 6;
    if(RD0_Bit31 == 1) goto L_Find_k_4;
    //-12~-17dB
    RD1 = 5;
    RD1 -= RD0;
    RD0 = 0x8000;
    goto L_Find_k_End;
    
L_Find_k_4:    
    RD0 += 6;
    if(RD0_Bit31 == 1) goto L_Find_k_5;
    //-18~-23dB
    RD1 = 5;
    RD1 -= RD0;
    RD0 = 0x4000;
    goto L_Find_k_End;

L_Find_k_5:    
    RD0 += 6;
    if(RD0_Bit31 == 1) goto L_Find_k_6;
    //-24~-29dB
    RD1 = 5;
    RD1 -= RD0;
    RD0 = 0x2000;
    goto L_Find_k_End;

L_Find_k_6:    
    RD0 += 6;
    if(RD0_Bit31 == 1) goto L_Find_k_7;
    //-30~-35dB
    RD1 = 5;
    RD1 -= RD0;
    RD0 = 0x1000;
    goto L_Find_k_End;

L_Find_k_7:
    RD0 += 6;
    RD2 ++;
    if(RD0_Bit31 == 1) goto L_Find_k_7;
    //<-35dB
    RD1 = 5;
    RD1 -= RD0;
    RD0 = 0x1000;
    
L_Find_k_End:
    RD3 = RD0;    
	RD0 = g_DAC_Cfg;
    RD0_ClrBit6;
    RD0_ClrBit7;
    RD0_ClrBit12;
    RD0_ClrBit13;
    RD0_ClrBit14;
    RD0_ClrBit15;   //g_DAC_Cfg��ʼ������������λ
    RD0 += RD3;
    g_DAC_Cfg = RD0;    
    
    RD0 = RD1;
    RD1 = RD2;

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
    RD0 = 0x0FF60FF6;   
    goto L_DAC_Tab_End;
L_DAC_Tab_0:
    //����k=0    
    RD0 = 0;        
    goto L_DAC_Tab_End;
L_DAC_Tab_1:
    //����k=1
    RD0 = 0x64296429;    
    goto L_DAC_Tab_End;
L_DAC_Tab_2:
    //����k=2,
    RD0 = 0x4B594B59;    
    goto L_DAC_Tab_End;
L_DAC_Tab_3:
    //����k=3   
    RD0 = 0x353B353B; 
    goto L_DAC_Tab_End;
L_DAC_Tab_4:
    //����k=4    
    RD0 = 0x21862186;   
       
L_DAC_Tab_End:
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
//      g_DAC_Cfg               bit15-12:IIR������棻bit7 6��CIC������档1000 10��Ĭ��ֵ����ʱ0dB
//      g_Vol                   ������λ��dB�����ݶ�32bit������
//      g_WeightFrame_Now_0     ��ǰ֡Ȩλ
//      g_WeightFrame_Next_0    ��һ֡Ȩλ
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Send_DAC;
	
    RD0 = g_WeightFrame_Now_0;
    RF_ShiftL1(RD0);//E*2       
    RD1 = RD0;
    RD0 += RD1;
    RD0 += RD1;     //E*6
    RD0 += g_Vol;   //������=6*E+����ֵ
    call Find_k;   
    RD2 = RD1;  //����λ�� 
    call DAC_Tab;
    //�Ƚ��г˷�
    if(RD0_Zero) goto L_Send_DAC_xx;
    //��6������������kx   
    RD1 = RD0;    
	RD0 = RN_GRAM_IN; 
    RA0 = RD0;
	RD0 = RN_GRAM1; ///////////////////////�������������������ݶ��Ĵ��� ������������
    RA1 = RD0;
    RD0 = RD1;
    call _MAC_RffC;          

    RD0 = RN_GRAM_IN; 
    RD1 = RN_GRAM1;
    call DATA_kX;
    goto L_Send_DAC_Odd;
L_Send_DAC_xx:
    //6������������ԭֵ
    RD0 = RN_GRAM_IN; 
    call DATA_XX;   

L_Send_DAC_Odd:        
	RD1 = FlowRAM_Addr1;	
    RD0 = g_Cnt_Frame;
    if(RD0_Bit0==1) goto L_Send_DAC_Even;
	RD1 = FlowRAM_Addr0;	
L_Send_DAC_Even:
    
    //��λ
	RD0 = RN_GRAM_IN;
    RA0 = RD0;
    RA1 = RD1;
    RD0 = RD2;
    call _Send_DAC_SignSftR_RndOff;
    //����Ȩλ
    RD0 = g_WeightFrame_Next_0;    
    g_WeightFrame_Now_0 = RD0;
    

    //֡�������ۼ�
    g_Cnt_Frame ++;    

    Return_AutoField(0*MMU_BASE);    
    
    
//////////////////////////////////////////////////////////////////////////
//  ����:
//      DATA_kX 
//  ����:
//      ��kX
//  ����:
//      RD0 Դ����x��ַ 
//      RD1 kx��ַ
//  ����ֵ��
//		��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField DATA_kX;

    push RA2;
    
    RA0 = RD0;
    RA2 = RD1;
    RD3 = RD0;
    MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
    RD0 = DMA_PATH0;
    M[RA0] = RD0;
    M[RA2] = RD0;
    MemSet_Disable;     //���ý���

    //����128�ֽڻ�����
    RD0 = 32*MMU_BASE;
    RSP -= RD0;
    RA1 = RSP;   

    CPU_WorkEnable;
    //�������ڲ�,��������
    RD2 = 16;
L_DATA_kX_L0:
    RD0 = M[RA0]; //Դ����x
    RD1 = M[RA2]; //kx
    RF_GetL16(RD0);
    RF_GetL16(RD1);
    RF_RotateR16(RD1);
    RD0 += RD1;
    M[RA1++] = RD0;
     
    RD0 = M[RA0++]; //Դ����x
    RD1 = M[RA2++]; //kx
    RF_GetH16(RD0);
    RF_GetH16(RD1);
    RF_RotateR16(RD1);
    RD0 += RD1;
    M[RA1++] = RD0; 
    
    RD2 --;
    if(RQ_nZero) goto L_DATA_kX_L0;
    //������ԭ��ַ
    RD0 = RD3;
    RA0 = RD0;
    RA1 = RSP;
    RD2 = 16;
L_DATA_kX_L1:
    RD0 = M[RA1++];
    M[RA0++] = RD0;
    RD0 = M[RA1++];
    M[RA0++] = RD0;
    RD2 --;
    if(RQ_nZero) goto L_DATA_kX_L1;
    CPU_WorkDisable;

    //�ͷ�128�ֽڻ�����
    RD0 = 32*MMU_BASE;
    RSP += RD0;
    
    pop RA2;
    Return_AutoField(0);
//////////////////////////////////////////////////////////////////////////
//  ����:
//      DATA_XX 
//  ����:
//      ��ԭֵ
//  ����:
//      RD0 Դ���ݵ�ַ
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
//      g_WeightFrame_Now_0 ��ǰ֡Ȩλ
//      g_ADC_DC_0:         �ۼӺͼ�������Ȩλ0��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField ADC0_Weight;

    // ����֡Ȩλ�������ۼӺͣ�ʹȨλ��0
    RD1 = RD0;
    RD0 = g_WeightFrame_Now_0;
    if(RD0_Zero) goto L_ADC_Weight_End; 
    if(RD0_Bit31 == 0) goto L_ADC_Weight_0;
    // ȨλΪ����
L_ADC_Weight_1:
    RF_Sft32SR1(RD1);
    RD0 ++;
    if(RD0_nZero) goto L_ADC_Weight_1;
    goto L_ADC_Weight_End;
L_ADC_Weight_0:
    // ȨλΪ����
    RF_ShiftL1(RD1);     
    RD0 --;
    if(RD0_nZero) goto L_ADC_Weight_0;
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
//      g_WeightFrame_Now_0     ��ǰ֡Ȩλ
//		g_LastBank_Average_0    ��8λΪֱ������ֵ����16λΪǰ512֡ƽ��ֵ��ȨλΪ0��bit16Ϊ��ǰ�飨512֡���Ƿ�Ĺ���λ�ı�־λ��1���Ĺ���0��δ�Ĺ� 
//////////////////////////////////////////////////////////////////////////
Sub_AutoField ADC0_C0;
    
    RD0 = g_LastBank_Average_0;
    RD0_SignExtL16;     //ǰ512֡ƽ��ֵ��Ȩλ0��

    // ����֡Ȩλ������ƽ��ֵ��ʹȨλ��0
    RD1 = RD0;
    RD0 = g_WeightFrame_Now_0;  // ��ǰ֡Ȩλ
    if(RD0_Zero) goto L_ADC0_C0_End; 
    if(RD0_Bit31 == 0) goto L_ADC0_C0_0;
    // ȨλΪ����
L_ADC0_C0_1:
    RF_ShiftL1(RD1);     
    RD0 ++;
    if(RD0_nZero) goto L_ADC0_C0_1;
    goto L_ADC0_C0_End;
L_ADC0_C0_0:
    // ȨλΪ����
    RF_Sft32SR1(RD1);
    RD0 --;
    if(RD0_nZero) goto L_ADC0_C0_0;
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
//      ��
//  ����ֵ��
//		RD0:    0:��ǰ����С�ź�֡��1:��ǰ������С�ź�֡
//  ȫ�ֱ�����
//		g_Vpp_0                 ��ǰ֡Vpp
//		g_SmallSignal_Count_0   ����С�ź�֡������
//		g_WeightFrame_Now_0     ��ǰ֡Ȩλ                
//		g_WeightFrame_Next_0    ��һ֡Ȩλ               
//		g_ADC_CFG_0;            ��16λADCǰ�÷Ŵ�������ֵ����16λADC_CFG�˿�����ֵ
//////////////////////////////////////////////////////////////////////////
Sub_AutoField ADC0_SmallSignal;
    
    RD0 = g_Vpp_0;
    RD0_ClrBit8;
    RD0_ClrBit9;
    RD0_ClrBit10;
    RD0_ClrBit11;
    RD0_ClrByteL8;
    if(RD0_Zero) goto L_ADC0_SmallSignal_0;  //Vpp<2^12
    //δ��⵽С�źţ����������������
    g_SmallSignal_Count_0 = 0;        
    goto L_ADC0_SmallSignal_End;     

L_ADC0_SmallSignal_0:
    //��⵽С�ź�
    RD0 = g_SmallSignal_Count_0;
    RD1 = 128;  //С�ź�֡������
    RD0 -= RD1;
    if(RD0_Zero) goto L_ADC0_SmallSignal_1; 
    //����������x֡С�źţ�������++������
    g_SmallSignal_Count_0 ++;
    goto L_ADC0_SmallSignal_5;  // ��ǰ֡����С�ź�֡���������źŴ���
        
L_ADC0_SmallSignal_1:           // С�źż�������꣬��������Ŵ���
    g_SmallSignal_Count_0 = 0;                // ����������
    
    RD0 = g_WeightFrame_Now_0;
    if(RD0_nZero) goto L_ADC0_SmallSignal_2;
    //��ǰE=0����һ֡��Ϊ-2
    RD0 = -2;
	g_WeightFrame_Next_0 = RD0;
    RD0 = g_ADC_CFG_0;
    RD0_ClrByteH16;
    RD1 = 0x3ff0000;
    RD0 += RD1;
    g_ADC_CFG_0 = RD0;
    goto L_ADC0_SmallSignal_4;
L_ADC0_SmallSignal_2:        
    if(RD0_Bit31 == 0) goto L_ADC0_SmallSignal_3;
    //��ǰE=-2������������
    goto L_ADC0_SmallSignal_5;
L_ADC0_SmallSignal_3:
    //��ǰE=2����һ֡��Ϊ0
    g_WeightFrame_Next_0 = 0;
    RD0 = g_ADC_CFG_0;
    RD0_ClrByteH16;
    RD1 = 0x3f0000;
    RD0 += RD1;
    g_ADC_CFG_0 = RD0;  

L_ADC0_SmallSignal_4:
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

L_ADC0_SmallSignal_5:    
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
//      ��
//  ����ֵ��
//		��
//  ȫ�ֱ�����
//		g_Vpp_0                 ��ǰ֡Vpp
//		g_WeightFrame_Now_0     ��ǰ֡Ȩλ                
//		g_WeightFrame_Next_0    ��һ֡Ȩλ               
//		g_ADC_CFG_0;            ��16λADCǰ�÷Ŵ�������ֵ����16λADC_CFG�˿�����ֵ
//////////////////////////////////////////////////////////////////////////
Sub_AutoField ADC0_StrongSignal;
    
    RD0 = g_Vpp_0;
    if(RD0_Bit15 == 0) goto L_ADC0_StrongSignal_End; 
//    if(RD0_Bit14 == 0) goto L_ADC0_StrongSignal_End; 
    //bit14 15��Ϊ1����������    
    RD0 = g_WeightFrame_Now_0;
    if(RD0_nZero) goto L_ADC0_StrongSignal_0;  
    //E=0,����Ϊ2
    RD0 = 2;
    g_WeightFrame_Next_0 = RD0;
    RD1 = 0x70000; 
    goto L_ADC0_StrongSignal_3;
L_ADC0_StrongSignal_0:
    if(RD0_Bit31 == 1) goto L_ADC0_StrongSignal_2;
    //E=2,�޷�����
    goto L_ADC0_StrongSignal_End;
L_ADC0_StrongSignal_2:    
    //E=-2,����Ϊ0
    RD0 = 0;
    g_WeightFrame_Next_0 = RD0;
    RD1 = 0x3ff0000;
      
L_ADC0_StrongSignal_3:
    //ADC_Cfg����
    RD0 = g_ADC_CFG_0;
    RD0_ClrByteH16;
    RD0 += RD1;
    g_ADC_CFG_0 = RD0;
    RF_RotateR16(RD1);

    RD0 = RN_ADCPORT_AGC0;
    ////Try ADC
    ADC_CPUCtrl_Enable;
    //����ADC0    
    ADC_PortSel = RD0;
    ADC_Cfg = RD1;
    RD0 = 0;
    ADC_PortSel = RD0;
    ADC_CPUCtrl_Disable;
  
L_ADC0_StrongSignal_End: 
     Return_AutoField(0);
       
//////////////////////////////////////////////////////////////////////////
//  ����:
//      Get_ADC_Function 
//  ����:
//      ��ADC��õ�����ͳ�ƣ��Դ�Ϊ��ȥֱ����������
//  ����:
//      RA0     AD_buf����ָ��
//  ����ֵ��
//		��
//  ˵����
//      (a)֡������,                    g_Cnt_Frame
//		(b)ÿһ·MIC��Ҫ4��ȫ�ֱ���
//			(1)��ǰ֡Ȩλ               g_WeightFrame_Now_0 
//			(2)��һ֡Ȩλ               g_WeightFrame_Next_0 
//			(3)��ǰ֡Vpp                g_Vpp_0
//			(4)ǰһ�飨512֡��ƽ��ֵ    g_LastBank_Average_0 : ��8λΪֱ������ֵ����16λΪȥֱ������ֵ��ȨλΪ0��bit16Ϊ��ǰ�飨512֡���Ƿ�Ĺ���λ�ı�־λ��1���Ĺ���0��δ�Ĺ� 
//			(5)ƽ��ֵ�ۼ���             g_ADC_DC_0 ��ƽ��ֵ�ۼ���,ȨλΪ0
//			(6)����ֵ�Ĵ���             g_ADC_CFG_0 ����16λADCǰ�÷Ŵ�������ֵ����16λADC_CFG�˿�����ֵ
//			(7)����С�ź�֡������       g_SmallSignal_Count_0      
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Get_ADC_Function;
    
    RD0 = RA0;
    RD2 = RD0;
    //////1������ͳ��
    //Ȩλ������Ӳ�����������������Ҫ�������
    RD0 = g_WeightFrame_Now_0;
    if(RD0_Zero) goto L_ExpFix_End;
    if(RD0_Bit31 == 1) goto L_ExpFix_1;
    //E=2
    RD1 = 0x60006000;   //����ֵ
    goto L_ExpFix_0;
L_ExpFix_1:
    //E=-2
    RD1 = 0x68B968B9;   //����ֵ
    goto L_ExpFix_0;
L_ExpFix_0:
    //RA0@ADBUFF
    //��ʱ�޸�ParaMEM
    //����DMA_Ctrl������������ַ.����
	RD0 = RN_PRAM_START+DMA_ParaNum_MAC_RffC*MMU_BASE*8;
	RA2 = RD0;
	// 4*MMU_BASE: Step1  
	RD0 = 0x06040002;//Step1
	M[RA2+4*MMU_BASE] = RD0;
	// 5*MMU_BASE: Null
	RD0 = 0x00000002;//Step2
	M[RA2+5*MMU_BASE] = RD0;
    //////MAC_RFFC
    	// ����Group��PATH������
		MemSetPath_Enable;  //����Groupͨ��ʹ��
		M[RA0+MGRP_PATH2] = RD0;//ѡ��PATH2��ͨ����Ϣ��ƫַ��

		MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
		// ���ӵ�PATH1
		M[RA0] = DMA_PATH2;

		//����MAC����
		MAC_CFG = RN_CFG_MAC_TYPE2;     //MACдָ��˿� //X[n]*CONST/32768
		MAC_Const = RD1;    //MACдConst�˿�//CONSTΪ16λ���ߵ�16λд��ͬ����
		MemSet_Disable;     //���ý���

		//����DMA_Ctrl������������ַ.����
		RD0 = RN_PRAM_START+DMA_ParaNum_MAC_RffC*MMU_BASE*8;
		RA2 = RD0;
		// 1*MMU_BASE: CntW+Դ��ַDW
		RD0 = RA0;//Դ��ַ0
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0_ClrByteH8;
		RD1 = CntFWB4_32b;          //CntW is 4
		RD0 += RD1;
		M[RA2+1*MMU_BASE] = RD0;
		// 2*MMU_BASE:
		RD0 = RA0;//Ŀ���ַ
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RD0 -= 2;                  //��ˮ��ǰ1��д��Ч
		RD0_ClrByteH8;
		RD1 = CntFWB2_32b;          //CntB is 2
		RD0 += RD1;
		M[RA2+2*MMU_BASE] = RD0;            //CntF is 0
	
		//ѡ��DMA_Ctrlͨ��������������
		//�˶δ��޸�2021/11/19 9:36:43
		ParaMem_Num = DMA_PATH2;
		ParaMem_Addr = DMA_nParaNum_MAC_RffC;
		nop;nop;nop;nop;nop;nop;
		Wait_While(Flag_DMAWork==0);//�˶δ��޸�2021/11/19 9:36:38
		
			//�黹bank
		MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM����ʱʹ��
		M[RA0] = DMA_PATH5;
		MemSet_Disable;     //���ý���

    //�黹ParaMem
    // 4*MMU_BASE: Step1  
	RD0 = 0x06040001;//Step1
	M[RA2+4*MMU_BASE] = RD0;
	// 5*MMU_BASE: Null
	RD0 = 0x00000001;//Step2
	M[RA2+5*MMU_BASE] = RD0;

L_ExpFix_End:    

	//ALU����xi-g_LastBank_Average_0��g_LastBank_Average_0��ǰһ�飨512֡�����ݵľ�ֵ
    RD0 = RD2;
    RA0 = RD0;
	RD0 = RN_GRAM_IN;
	RA1 = RD0;
	call ADC0_C0;   //RD0:�����͸�ʽ����Ҫ��ȥ��ֱ��ֵ���ⲿ����Ȩ�ض��룬��ƴ��ΪH16��L16��ʽ������ǰ512֡ƽ��ֵ��Ȩλͬ����
	call _GetADC_Ave_Max_Min;   //1.RD0��������ۼӺͣ���SUM(Xi-C),32bit�з����� 2.RD1�����ֵ��Vpp=Max-Min��32bit�з�����
    g_Vpp_0 = RD1;  
    call ADC0_Weight;     //�����ۼӺ�  

//goto L_ADC_Bias_Adj_Start;//////////////!!!!!!!!!!!!������
           
    //////2��AGC�������
    // 2.1С�źŴ���
    call ADC0_SmallSignal;
    
    if(RD0_Zero) goto L_ADC_Bias_Adj_Start; //��ǰ����С�ź�֡���������źŴ���
    // 2.2���źŴ���
    call ADC0_StrongSignal;

    //////3��ȥֱ��
L_ADC_Bias_Adj_Start:
    //����DAC_CFG
    RD0 = g_DAC_Cfg; 
    CPU_WorkEnable;
    DAC_CFG = RD0;
    CPU_WorkDisable;
/*
//test    
RD0 = g_Cnt_Frame;  //֡������                              
if(RD0_L8 != 0) goto L_ADC_TEST_End; 
if(RD0_Bit8 == 1) goto L_ADC_TEST_End;  //���Ƿ���512֡����������                 
if(RD0_Bit9 == 1) goto L_ADC_TEST;  //���Ƿ���512֡����������                 
//ADC_Cfg����
RD0 = 0x3;
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
goto L_ADC_TEST_End;        
L_ADC_TEST:
//ADC_Cfg����
RD0 = 0xF;
RD1 = RD0;     
RD0 = RN_ADCPORT_AGC0;
//Try ADC
ADC_CPUCtrl_Enable;
//����ADC0    
ADC_PortSel = RD0;
ADC_Cfg = RD1;
RD0 = 0;
ADC_PortSel = RD0;
ADC_CPUCtrl_Disable;    
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
RD0 = 0x808380; 
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
RD0 = g_Cnt_Frame;
send_para(RD0);
call UART_PutDword_COM1;
RD0 = g_Vpp_0;
send_para(RD0);
call UART_PutDword_COM1;
RD0 = g_WeightFrame_Now_0;
send_para(RD0);
call UART_PutDword_COM1;
RD0 = g_DAC_Cfg;
send_para(RD0);
call UART_PutDword_COM1;                             
RD0 = g_ADC_CFG_0;
send_para(RD0);
call UART_PutDword_COM1;   
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


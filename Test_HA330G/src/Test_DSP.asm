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
#include <IIR.def>
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
#define	        SPI_Master_Init                             0x00003fb6


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


				
	RD0 = 0b11;//ʹ��MIC0
	call AD_DA_INIT_330G;
	
//	L_TEST_FREQ:			
//		CPU_SimpleLevel_H;
//		nop;
//		CPU_SimpleLevel_L;
//		goto L_TEST_FREQ;			
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
CPU_SimpleLevel_H;nop;

    
    call Get_ADC;
    nop;nop;nop;nop;
    if(RD0_nZero) goto Loop;
CPU_SimpleLevel_L;
        
        
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
//	RD0 = GPIO_Data0;
//	if(RD0_Bit3 == 0) goto L_TEST_1;
//	goto  L_TEST_END1;   
//L_TEST_1:
//    nop;nop;
//	RD0 = GPIO_Data0;
//	if(RD0_Bit3 == 0) goto L_TEST_1;
//    RD0 = g_Vol;
//    RD0 += 1;
//    g_Vol = RD0;
//    RD2 = 2000*100;     
//    call _Delay_RD2;
//L_TEST_END1:
//    
//	RD0 = GPIO_Data0;
//	if(RD0_Bit7 == 0) goto L_TEST_2;
//	goto  L_TEST_END2;   
//L_TEST_2:
//    nop;nop;
//	RD0 = GPIO_Data0;
//	if(RD0_Bit7 == 0) goto L_TEST_2;
//    RD0 = g_Vol;
//    RD0 -= 1;
//    g_Vol = RD0;
//    RD2 = 2000*100;     
//    call _Delay_RD2;
//L_TEST_END2:
//    
//	RD0 = GPIO_Data0;
//	if(RD0_Bit4 == 0) goto L_TEST_3;
//	goto  L_TEST_END3;   
//L_TEST_3:
//    nop;nop;
//	RD0 = GPIO_Data0;
//	if(RD0_Bit4 == 0) goto L_TEST_3;
//    RD0 = g_Vol;
//    if(RD0_nZero) goto L_TEST_3_0;
//    RD0 = -100;
//    goto L_TEST_3_1;
//L_TEST_3_0:        
//    RD0 = 0;
//L_TEST_3_1:
//    g_Vol = RD0;
//    RD2 = 2000*100;     
//    call _Delay_RD2;
//L_TEST_END3:  
/////////������������


//���ӹ���������
	//Step1: 1���ڲ�0��ռ�õ�ַ(RN_SAMPLES_STREAM_OUT+512)��Ϊ����������128�ֽ�
    RD0 = RN_SAMPLES_STREAM_0;
    RA0 = RD0;
    RD0 = RN_SAMPLES_STREAM_OUT;
    RA1 = RD0;
    RD0 = FL_M2_A2;
    call Real_To_Complex2;
	//Step2: ����˲�����������Ƶ��
	RD0 = RN_SAMPLES_STREAM_OUT;
    RA1 = RD0;
    RA0 = RD0;
    RD0 = FL2_M88_A1;// DWord����*88+1
    call _IIR_PATH3_HB;



//�������� ������
//GPIO7���¼�С������GPIO3������������
	RD0 = GPIO_Data0;
	if(RD0_Bit7 == 0) goto L_TEST_1;
	goto  L_TEST_END1;   
L_TEST_1:
    nop;nop;
	RD0 = GPIO_Data0;
	if(RD0_Bit7 == 0) goto L_TEST_1;
    RD0 = g_Vol;
    RD1 = 6*256;
    RD0 += RD1;
    g_Vol = RD0;
    RD2 = 2000*100;     
    call _Delay_RD2;
L_TEST_END1:
    
	RD0 = GPIO_Data0;
	if(RD0_Bit4 == 0) goto L_TEST_2;
	goto  L_TEST_END2;   
L_TEST_2:
    nop;nop;
	RD0 = GPIO_Data0;
	if(RD0_Bit4 == 0) goto L_TEST_2;
    RD0 = g_Vol;
    RD1 = 6*256;
    RD0 -= RD1;
    g_Vol = RD0;
    RD2 = 2000*100;     
    call _Delay_RD2;
L_TEST_END2:    
   
    // ��������
    RD0 = g_Vol;
    send_para(RD0);
    RD0 = RN_SAMPLES_STREAM_0;
    send_para(RD0);
    RD0 = FL2_M3_A3;
    send_para(RD0);
    call Adj_Vol;
    

    call Send_Data_To_DAC_16bit_FSX2;

    g_Cnt_Frame ++;
    
    
//    RD0 = RN_GRAM_IN;
//    call Send_DAC;        
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
//  ����:
//      Adj_Vol
//  ����:
//      ��������, ��������ֵ��ΧΪ��-90dB~+90dB��
//  ����:
//      1.M[RSP+2*MMU_BASE]: ����ֵ��������q8��
//      2.M[RSP+1*MMU_BASE]: ���ݵ�ַ
//      3.M[RSP+0*MMU_BASE]: ���ݳ��ȶ�Ӧ��TimerNumֵ����Ӧ(Len*3)+3 FL_M3_A3
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_Autofield Adj_Vol;
// �Ƚ�dB����ת����LOG2����
// ���ж�������������ּ�����ȷ����ʹ�õ�MAC�˷���

    RD2 = M[RSP+0*MMU_BASE];   // ����
    RD3 = M[RSP+1*MMU_BASE];   // ��ַ
#define    LEN_REG               RD2
#define    ADDR_REG              RD3

    // ת����LOG2���к�������
    RD0 = RN_Pow2_Table_ADDR;  // 2^n ROM���ַ, �����巽ʽ�ɲο�ROM��power_fix����
    RA0 = RD0;

    RD0 = M[RSP+2*MMU_BASE];   // ����
    RD1 = 10885;               // 0.33219 Q16
    call _Rs_Multi;
    RF_Sft32SR8(RD0);
    RF_Sft32SR8(RD0);
    // ���һλ�������
    if(RD0_Bit31 == 1) goto L_Adj_Vol_0;
    // ������������
    RD0 ++;
L_Adj_Vol_0:

    push RD0;                                     // ��������������
    // ��ȡ����С�����ֽ��в�����
    RF_GetL8(RD0);                                // ȡ������С������
    RD1 = RD0;
    RF_ShiftR2(RD1);                              // ROM��DWORD��λѰַ
    RD1 = M[RA0 + RD1];
    if (RD0_Bit1 == 0) goto L_Adj_Vol_1;          // �ж�ȡ���λ���λ
    RF_RotateL16(RD1);
L_Adj_Vol_1:
    RF_GetL16(RD1);

    // �ж�������������, ѡ������ʹ�õ�MAC����
    pop RD0;
    RF_Sft32SR8(RD0);                             // ȡ��������������
    if(RD0_Bit31 == 0) goto L_Adj_Vol_2;          // ���������ж�
    // ������ʹ��Q15MAC
    RD0 += 24;                                    // Ԥ��24Bit��������ֵ����
    RF_Exp(RD0);
    call _Rs_Multi;
    RF_Sft32SR8(RD0);                             // ��������ֵ
    RF_Sft32SR8(RD0);                             // ��������ֵ
    RD1 = RD0;
    RF_RotateL16(RD0);
    RD1 += RD0;

    RD0 = ADDR_REG;
    RA0 = RD0;
    RA1 = RD0;
    RD0 = LEN_REG;
    call MultiConstH16L16;             // Q15��������
    
    goto L_Adj_Vol_End;

L_Adj_Vol_2:                           // ���������Q7MAC
    RD0 -= 7;
    if(RD0_Bit31 == 1) goto L_Adj_Vol_3;   // �������������� > 7 ��Ҫ�������һ�ηŴ�
    push RD0;
    push RD1;
    send_para(ADDR_REG);
    RD0 = 0x40004000;                  // �Ŵ�128��
    send_para(RD0);
    send_para(ADDR_REG);
    send_para(LEN_REG);
    call MAC_MultiConst16_Q2207;
    pop RD1;
    pop RD0;
    RD0 -= 7;

L_Adj_Vol_3:
    RD0 += 7;
    RF_Exp(RD0);
    call _Rs_Multi;                    // ����ʣ�������ֵ
    RD1 = RD0;
    RF_RotateL16(RD0);
    RD0 += RD1;

    send_para(ADDR_REG);
    send_para(RD0);
    send_para(ADDR_REG);
    send_para(LEN_REG);
    call MAC_MultiConst16_Q2207;
    
L_Adj_Vol_End:

#undef    LEN_REG
#undef    ADDR_REG
    Return_Autofield(3*MMU_BASE);
////////////////////////////////////////////////////////
//  ����:
//      Send_Data_To_DAC_16bit_FSX2
//  ����:
//      ����Ƶ���㿽����DAC������
//      ��CPUִ�п������̣�ͬʱ��������������������[-32768,32767]
//      ������ڣ�RN_SAMPLES_STREAM_OUT(ȫ��)
//  ����:
//      ��
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField Send_Data_To_DAC_16bit_FSX2;
    push RA2;
    RD0 = g_Cnt_Frame;
    if(RD0_Bit0==0) goto L_Send_Data_To_DAC_16bit_0;

    RD0 = FlowRAM_Addr1;
    call En_GRAM_To_CPU;
    RD0 = FlowRAM_Addr1;
    RA1 = RD0;
    goto L_Send_Data_To_DAC_16bit_1;

L_Send_Data_To_DAC_16bit_0:
    RD0 = FlowRAM_Addr0;
    call En_GRAM_To_CPU;
    RD0 = FlowRAM_Addr0;
    RA1 = RD0;
L_Send_Data_To_DAC_16bit_1:

    // ��GRAM������DAC_Buf1��������
    RD0 = RN_SAMPLES_STREAM_OUT;
    call En_GRAM_To_CPU;

    RD2 = 32/2;
    RD0 = RN_SAMPLES_STREAM_OUT;
    RA0 = RD0;

L_Send_Data_To_DAC_16bit_Loop1:
Set_Opcode_Dis;nop;nop;
    RD0 = M[RA0++];
    M[RA1++] = RD0;
    RD0 = M[RA0++];
    M[RA1++] = RD0;
    RD2 --;
    if(RQ_nZero) goto L_Send_Data_To_DAC_16bit_Loop1;
    call Dis_GRAM_To_CPU;

    RD0 = g_Cnt_Frame;
    if(RD0_Bit0==0) goto L_Send_Data_To_DAC_16bit_2;
    // 6.��AD_Buf1�л�Flowͨ��
    call SetADBuf1_Flow;
    goto L_Send_Data_To_DAC_16bit_End;

L_Send_Data_To_DAC_16bit_2:
    // 6.��AD_Buf0�л�Flowͨ��
    call SetADBuf0_Flow;

L_Send_Data_To_DAC_16bit_End:

Set_Opcode_Dis;nop;nop;

    pop RA2;
    Return_AutoField(0);
    
    
Sub_AutoField Wait_Flag_DMAWork;
L_Wait_Flag_DMAWork0:
    nop;nop;
    if(Flag_DMAWork==0) goto L_Wait_Flag_DMAWork0;
Return_AutoField(0); 
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
Set_Opcode_Dis;nop;nop;
    call Wait_Flag_DMAWork;
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
Set_Opcode_Dis;nop;nop;
    call Wait_Flag_DMAWork;
    Return_AutoField(0);
    
    
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


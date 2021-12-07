////////////////////////////
// AD_DA_330G.asm for HA330G (Chip Core:HA320G)
// WENDI YANG 2021/12/7
////////////////////////////
//      Modified Notes
//      1.  DAC��ֱͨ��Ϊ�Ȳ�ֵ����sendDAC������ʵ�ֲ�ֵ��
//      2.  У׼��������ADDA init�С�
//      3.  ����DAC IIRϵ����
//      4. 
////////////////////////////

#define _AD_DA_330G_F_

#include <CPU11.def>
#include <resource_allocation.def>
#include <RN_DSP_Cfg.def>
#include <Global.def>
#include <DMA_ParaCfg.def>
#include <DspHotLine_330G.def>
#include <AD_DA_330G.def>
#include <Trimming.def> //��Ƭ������



CODE SEGMENT AD_DA_330G_code;
////////////////////////////////////////////////////////
//  ����:
//      AD_DA_INIT_330G
//  ����:
//      HA330G оƬУ׼��ADC��DAC��DSP�ĳ�ʼ����
//  ����:
//      RD0:  0b00000001:MIC0    0b00000010:MIC1
//  ����ֵ:
//      ��
//  ˵����
//      1.��������оƬ�����Ļ������ã�������
//        (a)ADC�ĳ�ʼ����ģ����������ã���
//        (b)DAC�ĳ�ʼ����ģ����������ã���
//        (c)DSP��ʼ��������ʹ��DSP������ָ���ʼ����
//      2.ADCʹ�õ�ȫ�ֱ���-----------------------------��ȫ�ֱ������޸ĸ��£�
//      (a)֡������,                    g_Cnt_Frame
//		(b)ÿһ·MIC��Ҫ4��ȫ�ֱ���
//			(1)��ǰ֡Ȩλ               g_WeightFrame_Now_0 
//			(2)��һ֡Ȩλ               g_WeightFrame_Next_0 
//			(3)��ǰ֡Vpp                g_Vpp_0
//			(4)ǰһ�飨512֡��ƽ��ֵ    g_LastBank_Average_0 : ��8λΪֱ������ֵ����16λΪȥֱ������ֵ��ȨλΪ0��bit16Ϊ��ǰ�飨512֡���Ƿ�Ĺ���λ�ı�־λ��1���Ĺ���0��δ�Ĺ� 
//			(5)ƽ��ֵ�ۼ���             g_ADC_DC_0 ��ƽ��ֵ�ۼ���,ȨλΪ0
//			(6)����ֵ�Ĵ���             g_ADC_CFG_0 ����16λADCǰ�÷Ŵ�������ֵ����16λADC_CFG�˿�����ֵ
//			(7)����С�ź�֡������       g_SmallSignal_Count_0      
//      3.DACʹ�õ�ȫ�ֱ���-----------------------------��ȫ�ֱ������޸ĸ��£�
//          g_DAC_Cfg               bit15-12:IIR������棻bit7 6��CIC������档1000 10��Ĭ��ֵ����ʱ0dB
//          g_Vol                   ������λ��dB�����ݶ�32bit������
//          g_WeightFrame_Now_0     ��ǰ֡Ȩλ
//          g_WeightFrame_Next_0    ��һ֡Ȩλ
////////////////////////////////////////////////////////
Sub_AutoField AD_DA_INIT_330G;

		RD3 = RD0; //�ݴ�MIC����
	
		//---------------------------------------
		//(a)DSP�ĳ�ʼ����
		//����DSP����ʱ��
		RD0 = RN_CFG_DSP48M+RN_CFG_FLOW_DIV4;  //Slow = 8MHz 1/8��������DAC������OSR = 2
		DSP_FreqDiv = RD0;
		nop; nop; nop; nop;
		//ʹ��DSP����
		DSP_Disable;
		DSP_Enable;
		Pull_Enable;

		//---------------------------------------
		//(b)ADC��ʼ����RD1����MICʹ��
		//RD0 = 0b11;//ʹ��˫MIC
		//RD0 = 0b10;//ʹ��MIC1
		//RD0 = 0b01;//ʹ��MIC0
		RD0 = RD3;
		call ADC_INIT_330G;
	
		//---------------------------------------
		//(c)DAC��ʼ��
		call DAC_INIT_330G;
	
		//---Speed5����������·
		RD1 = RN_SP5;
		RP_B15;
		Set_Pulse_Ext8;
		nop;nop;

		//(d)DSP���߳�ʼ��
		call DSP_HotLine_init;

//		//��ʼ��IIR_PATH3�˲��������ڶ�ԭʼ�źŽ��и�ͨ�˲�(����ȥ��ADDA�����е�500Hz���)
//    IIR_PATH3_Enable;
//    MemSetRAM4K_Enable;
//    RD0 = 0x0;// Para0, Data00
//    IIR_PATH3_BANK = RD0;
//		call IIR_PATH3_HP500Init;
//    IIR_PATH3_Disable;
//    MemSet_Disable;

		Return_AutoField(0*MMU_BASE);


////////////////////////////////////////////////////////
//  ����:
//      ADC_INIT_330G
//  ����:
//      HA330G ADC��ʼ������������128������4bit
//  ����:
//      RD0:  0b00000001:MIC0    0b00000010:MIC1
//  ����ֵ:
//      ��
//  ˵����
//      1.��������ADC��ģ�����������
//      2.ADCʹ�õ�ȫ�ֱ���
//      (a)֡������,                    g_Cnt_Frame
//		(b)ÿһ·MIC��Ҫ4��ȫ�ֱ���
//			(1)��ǰ֡Ȩλ               g_WeightFrame_Now_0 
//			(2)��һ֡Ȩλ               g_WeightFrame_Next_0 
//			(3)��ǰ֡Vpp                g_Vpp_0
//			(4)ǰһ�飨512֡��ƽ��ֵ    g_LastBank_Average_0 : ��8λΪֱ������ֵ����16λΪȥֱ������ֵ��ȨλΪ0��bit16Ϊ��ǰ�飨512֡���Ƿ�Ĺ���λ�ı�־λ��1���Ĺ���0��δ�Ĺ� 
//			(5)ƽ��ֵ�ۼ���             g_ADC_DC_0 ��ƽ��ֵ�ۼ���,ȨλΪ0
//			(6)����ֵ�Ĵ���             g_ADC_CFG_0 ����16λADCǰ�÷Ŵ�������ֵ����16λADC_CFG�˿�����ֵ
//			(7)����С�ź�֡������       g_SmallSignal_Count_0      
//
////////////////////////////////////////////////////////
Sub_AutoField ADC_INIT_330G;
		//ADCȫ�ֱ�����ʼ��
		g_Cnt_Frame = 0;        
		//MIC0ȫ�ֱ�����ʼ��
		g_WeightFrame_Now_0 = 0;
		g_WeightFrame_Next_0 = 0;
		g_Vpp_0 = 0;
		g_SmallSignal_Count_0 = 0;
		RD1 = 0x07000000;
		g_LastBank_Average_0 = RD1;
		g_ADC_DC_0 = 0; //g_ADC_DC ��ƽ��ֵ�ۼ���,ȨλΪ0
		RD1 = 0x3f07C7;
		g_ADC_CFG_0 = RD1; //g_ADC_CFG ����16λADCǰ�÷Ŵ����Ŵ���,��16λADC_CFG�˿�����ֵ
		//MIC1ȫ�ֱ�����ʼ��
//		g_Weight_Frame_1 = 0;
//		RD1 = 0x07000000;
//		g_LastBank_Average_1 = RD1;
//		g_ADC_DC_1 = 0; //g_ADC_DC ��ƽ��ֵ�ۼ���,ȨλΪ0
//		RD1 = 0x003F07C7;
//		g_ADC_CFG_1 = RD1; //g_ADC_CFG ����16λADCǰ�÷Ŵ����Ŵ���,��16λADC_CFG�˿�����ֵ

    //ģ��������
    ADC_Disable;// ADC��ʼ��֮ǰ����ر�ADC
    ADC_Enable;
    ADC_CPUCtrl_Enable;
    
    //����MICͨ·ʹ�ܣ�RD0���
    RD1 = RN_ADCPORT_ANAPARA;
    ADC_PortSel = RD1;
    ADC_Cfg = RD0;
    
		// ǰ�÷Ŵ������Ŵ���ѡ�񷽷��������������Ŵ�󣬷��ֵ��6~128mV֮�䡣
    RD0 = RN_ADCPORT_AGC0+RN_ADCPORT_AGC1;
    ADC_PortSel = RD0;
    RD0 = g_ADC_CFG_0;    //����ֵ�Ĵ���, g_ADC_CFG_0 ����16λADCǰ�÷Ŵ����Ŵ���
    RF_GetH16(RD0);
		//RD0 = 0b00000111111;//������   12dB
    ADC_Cfg = RD0;
    
    //ֱ��ֵĬ��Ϊ7
    //MIC0
    RD0 = g_LastBank_Average_0;			//g_LastBank_Average_0 ����8λΪֱ������ֵ
    RF_GetH8(RD0);

		//RD0 = RN_ADDC_VAL;//������ RN_ADDC_VAL
		Volt_Vref2 = RD0;
		//MIC1
		Volt_Vref3 = RD0;
    
    //����ADC����·һ������
    RD0 = RN_ADCPORT_ADC0CFG+RN_ADCPORT_ADC1CFG;
    ADC_PortSel = RD0;
    
    //�趨ת����
    RD0 = RN_ADC_TABLE_ADDR;
    call _ADC_Table_330G;       //Table for 330G
    
    //����ADC_CFG
    RD0 = g_ADC_CFG_0;//����ֵ�Ĵ���, g_ADC_CFG ��16λADC_CFG�˿�����ֵ
    RF_GetL16(RD0);
    //RD0 = 0x7C7;//������
    ADC_Cfg = RD0;
    
    //����IIR for ADC
    call IIR_SetLP_89DB_ADC330G;
    
		//�黹�˿�
    RD0 = 0;
    ADC_PortSel = RD0;
    ADC_CPUCtrl_Disable;
    //ADC_TestView_Enable;        //������
    Return_AutoField(0*MMU_BASE);
    
//===============================
//���ܣ�����HA330G ADC��6-16ת����
//��ڣ���
//���ڣ���
//===============================
Sub_AutoField _ADC_Table_330G;
    RD0 = RN_ADDR_ADC_TABLE;
    RA1 = RD0;  //����ַ

    //���ı���16 X 16bit    
    RD0 = -7168;//Norm0,-7168
    RD1 = 0x400;    //Table step 1024
    RD2 = 16;
L_ADC_Table_330G:         //Set Norm 0:15
    M[RA1] = RD0;   
    RA1 += 2;
    RD0 += RD1;     
    RD2--;
    if(RQ_nZero) goto L_ADC_Table_330G;
    
    //����6�����ֵ��
    RD0 = RN_ADDR_ADC_TABLE;
RD0_SetBit5;
    RA1 = RD0;
    RD0 = 0;    //ƫַ
    RD0_SetBit6;
    
    RD1 = -32767;         M[RA1+RD0] = RD1;//Sel_L2
    RF_ShiftL1(RD0);
    RD1 = -16384;         M[RA1+RD0] = RD1;//Sel_L1
    RF_ShiftL1(RD0);

    RD1 = -12288;         M[RA1+RD0] = RD1;//Sel_L0
    RF_ShiftL1(RD0);
    RD1 = 13312;M[RA1+RD0] = RD1;//Sel_H0
    RF_ShiftL1(RD0);
    
    RD1 = 17408;M[RA1+RD0] = RD1;//Sel_H1
    RF_ShiftL1(RD0);

    RD1 = 32767;M[RA1+RD0] = RD1;//Sel_H2
    RF_ShiftL1(RD0);
    
    //����һ����ͷ���ֶԳ�
    RD1 = -8192;M[RA1+RD0] = RD1;//Sel_N1
    Return_AutoField(0*MMU_BASE);
    


////////////////////////////////////////////////////////
//  ����:
//      IIR_SetLP_89DB_ADC330G
//  ����:
//      ��ʼ������1/8����ADC330G����12�׵�ͨ�˲���
//  ����:
//      ��
//  ����ֵ:
//      ��
//  ע��:
//      Set_IIRSftL2XY;
//          ABϵ��������һ����A2B2)����2��ţ���ϵ�����ȴ���4ʱ���á�
//      Set_IIRSftR2X;
//          �������4,���������256ʱ���á�
//      ʱ���˲���ʽ��y(n) = (-a1)y(n-1) + (-a2)y(n-2) + ... + b0 *x(n) + b1 *x(n-1) + ...;
//          ai bi ��matlab������z�任��ʽϵ����Ӳ���涨 a0 = 8192��������ϵ��ai��bi������8192(2^13)����������ȡ��
//          Ӳ��Ҫ�����ݸ�ʽ:����λ��BIT15) + ����ֵ��BIT14-BIT0)
//          ���ݹ�ʽ������ʱʹ�ã�-ai���루bi��
//        	aϵ��Ϊ��ʱ����
//        	aϵ��Ϊ��ʱ������λȡ��
//        	bϵ��Ϊ��ʱ������
//        	bϵ��Ϊ��ʱ���󲹣�Ȼ�����λ��1
//      IIRָ��
//          HA330G_ADC_Downsampling_1_8_iir_ellip_7400_8400_12800_0.60_89.75_rsc8000_48.00_G1_recip_15495_to_91.txt
//          [7400,8400,0.04,90], fs=128000, G1_recip = 15495, iir_seg = 3, N = 12;
//          gain =0.13dB, rpc = 0.61dB,rsc = -89.44dB, rsc8000 = -47.82dB����׼��;
//          gain =-44.55dB, rpc = 0.60dB,rsc = -89.75dB, rsc8000 = -48.00dB, G1_recip=91�������棩
//          b1/3.884901548453264, b2/5.681591488336551, b3/7.678203617152247;
//          ���ε������Ŵ���: [16,2,2.86], G1_recip_exp = 16*2*2.86 = 91;
//          �˲���ϵ��ת��ʱ,�̶�G1_recip=1000;
//          ���-89.05dB, ����0.60dB, ���ȴ�(-600/400)/8000Hz, ����1/G0 = 91
//          2021/11/18 13:39:32
//
//      IIRϵ��
//      // IIR0
//      ԭʼ����    
//        	2000, CCD7, 3229, CCD7, 2000    //bϵ��
//   		      8CA8, 0A015, 9B09, 1850    //aϵ��
//      bϵ������ͳһ��λ���Ե������档����1λ���������һ�롣
//        	083D, F2D5, 0CE9, F2D5, 083D    //bϵ������3.884901548453264
//   		      8CA8, 0A015, 9B09, 1850
//      Set_IIRSftL2XY��Ч��A2��B2����2��ţ���ϵ�����ȴ���4ʱ���á�
//        	083D, F2D5, 0675, F2D5, 083D
//   		      8CA8, 500B, 9B09, 1850
//      Ӳ������
//        	083D, 8D2B, 0674, 8D2B, 083D    //bϵ��Ϊ��ʱ�����䣻Ϊ��ʱ���󲹣�Ȼ�����λ��1
//    		      7358, D00A, 64F7, 9850    //aϵ��Ϊ��ʱ���󲹣�Ϊ��ʱ������λȡ��
//
//      // IIR1
//      ԭʼ����
//        	2000, 8FBF, 0A265, 8FBF, 2000
//   		      8C05, 0A323, 96D1, 1A4F
//      bϵ������ͳһ��λ���Ե������档����1λ���������һ�롣
//        	05A2, EC3E, 1C95, EC3E, 05A2    //bϵ������5.681591488336551
//    		      8C05, 0A323, 96D1, 1A4F
//      Set_IIRSftL2XY��Ч��A2��B2����2��ţ���ϵ�����ȴ���4ʱ���á�
//        	05A2, EC3E, 0E4B, EC3E, 05A2
//    		      8C05, 5192, 96D1, 1A4F
//      Ӳ������
//        	05A2, 93C2, 0E4A, 93C2, 05A2    //bϵ��Ϊ��ʱ�����䣻Ϊ��ʱ���󲹣�Ȼ�����λ��1
//    		      73FB, D191, 692F, 9A4F    //aϵ��Ϊ��ʱ���󲹣�Ϊ��ʱ������λȡ��
//
//      // IIR2
//      ԭʼ����
//        	2000, 97B1, 093CD, 97B1, 2000
//   		      8C67, 0A173, 990D, 1949
//      bϵ������ͳһ��λ���Ե������档����1λ���������һ�롣
//        	042B, F26A, 1340, F26A, 042B    //bϵ������7.678203617152247
//   		      8C67, 0A173, 990D, 1949
//      Set_IIRSftL2XY��Ч��A2��B2����2��ţ���ϵ�����ȴ���4ʱ���á�
//        	042B, F26A, 09A0, F26A, 042B
//   		      8C67, 50BA, 990D, 1949
//      Ӳ������
//        	042B, 8D96, 09A0, 8D96, 042B    //bϵ��Ϊ��ʱ�����䣻Ϊ��ʱ���󲹣�Ȼ�����λ��1
//    		      7399, D0B9, 66F3, 9949    //aϵ��Ϊ��ʱ���󲹣�Ϊ��ʱ������λȡ��
////////////////////////////////////////////////////////
Sub_AutoField IIR_SetLP_89DB_ADC330G;
		//  IIR0
		//  083D, 8D2B, 0674, 8D2B, 083D
		//        7358, D00A, 64F7, 9850
		RD0 = 0x083D;
		ADC_FiltHD = RD0;  //b0
		RD0 = 0x8D2B;
		ADC_FiltHD = RD0;  //b1
		RD0 = 0x0674;
		ADC_FiltHD = RD0;  //b2
		RD0 = 0x8D2B;
		ADC_FiltHD = RD0;  //b3
		RD0 = 0x083D;
		ADC_FiltHD = RD0;  //b4
		RD0 = 0x7358;
		ADC_FiltHD = RD0;  //a1
		RD0 = 0xD00A;
		ADC_FiltHD = RD0;  //a2
		RD0 = 0x64F7;
		ADC_FiltHD = RD0;  //a3
		RD0 = 0x9850;
		ADC_FiltHD = RD0;  //a4
		ADC_FiltHD = RD0;  //��дһ��
	
		//  IIR1
		//  05A2, 93C2, 0E4A, 93C2, 05A2
		//        73FB, D191, 692F, 9A4F
		RD0 = 0x05A2;
		ADC_FiltHD = RD0;  //b0
		RD0 = 0x93C2;
		ADC_FiltHD = RD0;  //b1
		RD0 = 0x0E4A;
		ADC_FiltHD = RD0;  //b2
		RD0 = 0x93C2;
		ADC_FiltHD = RD0;  //b3
		RD0 = 0x05A2;
		ADC_FiltHD = RD0;  //b4
		RD0 = 0x73FB;
		ADC_FiltHD = RD0;  //a1
		RD0 = 0xD191;
		ADC_FiltHD = RD0;  //a2
		RD0 = 0x692F;
		ADC_FiltHD = RD0;  //a3
		RD0 = 0x9A4F;
		ADC_FiltHD = RD0;  //a4
		ADC_FiltHD = RD0;  //��дһ��
	
		//  IIR2
		//  042B, 8D96, 09A0, 8D96, 042B
		//        7399, D0B9, 66F3, 9949
		RD0 = 0x042B;
		ADC_FiltHD = RD0;  //b0
		RD0 = 0x8D96;
		ADC_FiltHD = RD0;  //b1
		RD0 = 0x09A0;
		ADC_FiltHD = RD0;  //b2
		RD0 = 0x8D96;
		ADC_FiltHD = RD0;  //b3
		RD0 = 0x042B;
		ADC_FiltHD = RD0;  //b4
		RD0 = 0x7399;
		ADC_FiltHD = RD0;  //a1
		RD0 = 0xD0B9;
		ADC_FiltHD = RD0;  //a2
		RD0 = 0x66F3;
		ADC_FiltHD = RD0;  //a3
		RD0 = 0x9949;
		ADC_FiltHD = RD0;  //a4
		ADC_FiltHD = RD0;  //��дһ��
	
		Return_AutoField(0*MMU_BASE);




////////////////////////////////////////////////////////
//  ����:
//      ADC_En_nDis_330G
//  ����:
//      HA330G ADC ʹ�ܺ͹رգ�ͬʱ��������
//  ����:
//      1.RD0:MIC��ʹ�ܡ��ر�����
//						0b00000001:MIC1�رա�MIC0ʹ��
//						0b00000010:MIC1ʹ�ܡ�MIC0�ر�
//						0b00000011:MIC1ʹ�ܡ�MIC0ʹ��
//      2.RD1:MIC�ĳ�ʼ����������
//						��ʼ�Ŵ���ѡ�񷽷��������������Ŵ�󣬷��ֵ��6~128mV֮�䡣
//						bit15:0��Ӧ����MIC0,bit31:16��ӦMIC1.
//  ����ֵ:
//      ��
//  ˵����
//		1.��������ADC��ģ�����������
////////////////////////////////////////////////////////
Sub_AutoField ADC_En_nDis_330G;
		//push RD4;
			
		RD2 = RD0;		//�ݴ�MICʹ������
		RD3 = RD1;		//�ݴ�MIC�ĳ�ʼ����������
			
		if(RD0_nZero) goto L_ADC_En_nDis_330G;
			
L_ADC330G_AllDis://MICȫ���رգ�ֱ�ӹر�ADC���˳�
		ADC_Disable;
		g_Cnt_Frame = 0;
		Return_AutoField(0*MMU_BASE);
		
L_ADC_En_nDis_330G://MICʹ��
		ADC_Enable;
		RD1 = RN_ADCPORT_ANAPARA;
		ADC_CPUCtrl_Enable;	
		//����MICͨ·ʹ��
    ADC_PortSel = RD1;
    ADC_Cfg = RD0;//MIC��ʹ�ܺ͹ر�	
    //�黹�˿�
    RD0 = 0;
    ADC_PortSel = RD0;
    ADC_CPUCtrl_Disable;//��ʱ�رգ�����ADC�������ж�
    
		RD0=RD2;
		if( RD0_Bit0 == 0) goto L_ADC_En_nDis_330G_MIC1;
		
L_ADC_En_nDis_330G_MIC0:		//MIC0 ����
	//����MIC0 ֱ��ֵ
	RD0 = g_LastBank_Average_0;			//g_LastBank_Average_0 : ��8λΪֱ������ֵ
	RF_GetH8(RD0);
	Volt_Vref2 = RD0;
		
    //����MIC0 AGC����
		RD0 = RN_ADCPORT_AGC0;
		RD1 = RD3;
		RF_GetL16(RD1);
		ADC_CPUCtrl_Enable;	
    ADC_PortSel = RD0;    
    ADC_Cfg = RD1;
    
    //����MIC0 ADC_CFG
    RD0 = RN_ADCPORT_ADC0CFG;
 		RD1 = ADC_CFG_Init;
    ADC_PortSel = RD0;    
    ADC_Cfg = RD1;
    
    //�黹�˿�
    RD0 = 0;
    ADC_PortSel = RD0;
    ADC_CPUCtrl_Disable;
    
    RD1 = RD3;
    RF_GetL16(RD1);
		RF_RotateL16(RD1);//����ֵ�Ĵ���, g_ADC_CFG ����16λADCǰ�÷Ŵ����Ŵ���
		RD0 = ADC_CFG_Init;
    RD1 += RD0;
    g_ADC_CFG_0 = RD1;//����ֵ�Ĵ���д��
    
		RD0 = RD2;
		if(RD0_Bit1 == 0) goto L_ADC_En_nDis_330G_END;//MIC1δ����������
		
L_ADC_En_nDis_330G_MIC1:			//MIC1 ����	
		//����MIC1 ֱ��ֵ
//		RD0 = g_LastBank_Average_1;			//g_LastBank_Average_1 : ��8λΪֱ������ֵ
//		RF_GetH8(RD0);
//		Volt_Vref3 = RD0;
//		
//    //����MIC1 AGC����
//		RD0 = RN_ADCPORT_AGC1;
//		RD1 = RD3;
//		RF_GetH16(RD1);
//		ADC_CPUCtrl_Enable;	
//    ADC_PortSel = RD0;    
//    ADC_Cfg = RD1;
//    
//    //����MIC1 ADC_CFG
//    RD0 = RN_ADCPORT_ADC1CFG;
// 		RD1 = ADC_CFG_Init;
//    ADC_PortSel = RD0;    
//    ADC_Cfg = RD1;
    
    //�黹�˿�
//    RD0 = 0;
//    ADC_PortSel = RD0;
//    ADC_CPUCtrl_Disable;
//    
//    RD1 = RD3;
//    RF_GetH16(RD1);
//		RF_RotateL16(RD1);//����ֵ�Ĵ���, g_ADC_CFG ����16λADCǰ�÷Ŵ����Ŵ���
//		RD0 = ADC_CFG_Init;
//    RD1 += RD0;
//    g_ADC_CFG_1 = RD1;//����ֵ�Ĵ���д��
L_ADC_En_nDis_330G_END:    
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  ����:
//      DAC_INIT_330G
//  ����:
//      HA330G DAC��ʼ��
//  ����:
//      ��
//  ����ֵ:
//      ��
//  ˵����
//      1.��������DAC��ģ�����������
//      2.DACʹ�õ�ȫ�ֱ���
//          g_DAC_Cfg               bit15-12:IIR������棻bit7 6��CIC������档1000 10��Ĭ��ֵ����ʱ0dB
//          g_Vol                   ������λ��dB�����ݶ�32bit������
////////////////////////////////////////////////////////
Sub_AutoField DAC_INIT_330G;

		//DACȫ�ֱ�����ʼ����ʼ��
		//RD0 = 0x802300;   //�����ã�7.5X ,16bit���������������!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		RD0 = 0x808380;   //E=0
		//RD0 = 0x808380;   //�����ã�E=-6
		g_DAC_Cfg = RD0;
		g_Vol = 0;
		//--------------------------------------------------
		//(1)��ʼ��Bank0&1����0
		RD0 = FlowRAM_Addr0;
		RA0 = RD0;      //Bank0��ַ
		RD0 = FlowRAM_Addr1;
		RA1 = RD0;      //Bank1��ַ

		//����4KRAM_PATH
		MemSetRAM4K_Enable; //ʹ����չ�˿ڻ�RAM��������ʱʹ��
		RD0 = DMA_PATH0;
		M[RA0] = RD0;
		M[RA1] = RD0;
		MemSet_Disable;     //���ý���
		CPU_WorkEnable;

		//Bank0 &1����0(��ʱ��CPU��������������DSP��)
		RD0 = 255;
		RF_ShiftL2(RD0);
		M[RA0] = 0;
		M[RA1] = 0;
L_InitADCFlowBank:
		M[RA0+RD0] = 0;
		M[RA1+RD0] = 0;
		RD0-=4;
		if(RQ_nZero) goto L_InitADCFlowBank;

		//--------------------------------------------------
		//����Flow_RAMΪDMA_Flow����
		MemSetRAM4K_Enable;  //Set_All
		RD0 = DMA_PATH5;
		M[RA0] = RD0;
		M[RA1] = RD0;
		MemSet_Disable; //Set_All

		MemSetRAM4K_Enable;
		DAC_Enable;

		//����DACϵ��
		call IIR_SetLP_99DB_DAC330G;//1/8 ���˲���

		//����DAC����
		RD0 = g_DAC_Cfg ;
		//RD0 = 0x80F380;   //������//
		//RD0 = 0x8083C0;   //������//E=0
		//RD0 = 0x808380;   //�����ã�E=-6
		DAC_CFG = RD0;
		MemSet_Disable;     //���ý���

		//ADC-->DAC����
		//׼������Flow����ӳ��
//    RD0 = 0;//Bankƫ�Ƶ�ַ���ֽ�
//    send_para(RD0);
//		RD0 = AD_Buf_Len;//4MHz
//    send_para(RD0);
//    RD0 = RN_CFG_FLOW_TYPE3;//Slow = 8MHz
//    send_para(RD0);
//    call _DMA_ParaCfg_Flow2;
		RD0 = RN_PRAM_START+DMA_ParaNum_ADDA_Flow*MMU_BASE*8;
		RA0 = RD0;
		RD0=RN_CFG_DAC_DIV1+RN_CFG_MEM_DIV512+RN_CFG_ADC_DIV2;
		M[RA0+0*MMU_BASE] = RD0;
		RD0 = 0;   //Bank��ʼ��ַ
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RF_Not(RD0);               //Ӳ��Ҫ��
		M[RA0+2*MMU_BASE] = RD0;
		RD0 = 0x1e01fffd; //0x70ff0001;
		M[RA0+1*MMU_BASE] = RD0;  //Loop_Num

		//ѡ��DMA_Flowͨ��������������
		RD0 = 0x80;
		ParaMem_Num = RD0;
		RD0 = DMA_nParaNum_ADDA_Flow;
		ParaMem_Addr = RD0;

		// ʹ��DAC Class-D ���
		SDM_DRV0_ENABLE;    //1��������Ĭ��ֵ�����޸�
		//SDM_DRV1_ENABLE;    //2������
		//SDM_DRV0_ENABLE;SDM_DRV1_ENABLE;    //3������

		Return_AutoField(0*MMU_BASE);

////////////////////////////////////////////////////////
//  ����:
//      DAC_En_nDis_330G
//  ����:
//      HA330G DAC�رպ��ؿ�
//  ����:
//      RD0: 0�ر�DAC��1����DAC
//  ����ֵ:
//      ��
//  ˵����
//      1.��������DAC��ģ�����������
//      2.DACʹ�õ�ȫ�ֱ���
//        (a)����ֵ�Ĵ���, g_DAC_Cfg ����16λDAC_CFG�˿�����ֵ bit15-12:IIR������棻bit7 6��CIC������档1000 01��Ĭ��ֵ����ʱ0dB
//        (b)g_Vol��������λ��dB�����ݶ�32bit������
//
////////////////////////////////////////////////////////
Sub_AutoField DAC_En_nDis_330G;
		if(RD0_nZero) goto L_DAC_En_330G;
L_DAC_nDis_330G://�ر�DAC��Class-D���
		SDM_DRV0_DISABLE;
		SDM_DRV1_DISABLE;
		DAC_Disable;
		Return_AutoField(0*MMU_BASE);
L_DAC_En_330G://�ݶ���������DACʱ��Bank����FWά���ã���������
		RD0 = FlowRAM_Addr0;
		RA0 = RD0;      //Bank0��ַ
		RD0 = FlowRAM_Addr1;
		RA1 = RD0;      //Bank1��ַ
		//����Flow_RAMΪDMA_Flow����
		MemSetRAM4K_Enable;  //Set_All
		RD0 = DMA_PATH5;
		M[RA0] = RD0;
		M[RA1] = RD0;
		MemSet_Disable; //Set_All

		MemSetRAM4K_Enable;
		DAC_Enable;

		//����DAC����
		RD0 = g_DAC_Cfg ;
		//RD0 = 0x80F380;   //������//
		//RD0 = 0x8083C0;   //������//E=0
		//RD0 = 0x808380;   //�����ã�E=-6
		DAC_CFG = RD0;
		MemSet_Disable;     //���ý���

		//ADC-->DAC����
		//׼������Flow����ӳ��
		RD0 = RN_PRAM_START+DMA_ParaNum_ADDA_Flow*MMU_BASE*8;
		RA0 = RD0;
		RD0=RN_CFG_DAC_DIV1+RN_CFG_MEM_DIV512+RN_CFG_ADC_DIV2;
		M[RA0+0*MMU_BASE] = RD0;
		RD0 = 0;   //Bank��ʼ��ַ
		RF_ShiftR2(RD0);           //��ΪDword��ַ
		RF_Not(RD0);               //Ӳ��Ҫ��
		M[RA0+2*MMU_BASE] = RD0;
		RD0 = 0x1e01fffd; //0x70ff0001;
		M[RA0+1*MMU_BASE] = RD0;  //Loop_Nums

		//ѡ��DMA_Flowͨ��������������
		RD0 = 0x80;
		ParaMem_Num = RD0;
		RD0 = DMA_nParaNum_ADDA_Flow;
		ParaMem_Addr = RD0;


		// ʹ��DAC Class-D ���
		SDM_DRV0_ENABLE;    //1��������Ĭ��ֵ�����޸�
		//SDM_DRV1_ENABLE;    //2������
		//SDM_DRV0_ENABLE;SDM_DRV1_ENABLE;    //3������

		Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  ����:
//      IIR_SetLP_99DB_DAC330G
//  ����:
//      ��ʼ������1/8����DAC330G�Ķ�14�׵�ͨ�˲���
//  ����:
//      ��
//  ����ֵ:
//      ��
//  ע��:
//      Set_IIRSftL2XY;
//          ABϵ��������һ����A2B2)����2��ţ���ϵ�����ȴ���4ʱ���á�
//      Set_IIRSftR2X;
//          �������4,���������256ʱ���á�
//      ʱ���˲���ʽ��y(n) = (-a1)y(n-1) + (-a2)y(n-2) + ... + b0 *x(n) + b1 *x(n-1) + ...;
//          ai bi ��matlab������z�任��ʽϵ����Ӳ���涨 a0 = 8192��������ϵ��ai��bi������8192(2^13)����������ȡ��
//          Ӳ��Ҫ�����ݸ�ʽ:����λ��BIT15) + ����ֵ��BIT14-BIT0)
//          ���ݹ�ʽ������ʱʹ�ã�-ai���루bi��
//              aϵ��Ϊ��ʱ����
//              aϵ��Ϊ��ʱ������λȡ��
//              bϵ��Ϊ��ʱ������
//              bϵ��Ϊ��ʱ���󲹣�Ȼ�����λ��1
//      IIRָ��
//          HA330G_DAC_Upsampling_1_8_iir_ellip_7200_8200_128000_0.36_99.11_rsc8000_83.34_G1_recip_44713_to_256.txt
//          [7200,8200,0.005,100], fs=128000, iir_seg = 4, N = 14, G1_recip = 44713 to 256;
//          gain=-0.002dB, rpc=0.39dB, rsc=-99.75dB, rsc8000=-83.36dB, G1_recip=44713����׼��;
//          gain2=-44.83dB, rpc=0.36dB, rsc=-99.11dB, rsc8000=-83.34dB, G1_recip=256�������棩;
//          �ĶεķŴ���: [16,2,2,4], G1_recip_exp = 16*2*2*4 = 256;
//          �ĶεĽ��ͱ���: dsc = [5.076501101413800   7.521791640349150   0.728491447494969   6.278090742602100]
//          gain_seg0 = [38.193689348040017, 23.547025892242225,  3.269089063469961,  27.997751599320949]����׼��
//          gain_seg2 = [24.094138795835576,  5.958783905151940,  6.015049518999269,  12.111050198676283]�������棩;
//          �˲���ϵ��ת��ʱ,�̶�G1_recip=1000;
//          ���-99.11dB, ����0.36dB, ���ɴ�(-800/200)/8000Hz, ����1/G0 = 256
//          2021/12/6 15:08:54
//
//      IIRϵ��
//      // IIR0
//      ԭʼ����
//              2000, D3A9, 2566, D3A9, 2000    //bϵ��
//                    8E04, 09BFF, 9F32, 16E3   //aϵ��
//      bϵ������ͳһ��λ���Ե������档����1λ���������һ�롣
//              064E, F744, 075E, F744, 064E    //bϵ������5.076501101413800
//                    8E04, 09BFF, 9F32, 16E3
//      Set_IIRSftL2XY��Ч��A2��B2����2��ţ���ϵ�����ȴ���4ʱ���á�
//              064E, F744, 03AF, F744, 064E
//                    8E04, 4E00, 9F32, 16E3
//      Ӳ������
//              064E, 88BC, 03AF, 88BC, 064E    //bϵ��Ϊ��ʱ�����䣻Ϊ��ʱ���󲹣�Ȼ�����λ��1
//                    71FC, CDFF, 60CE, 96E3    //aϵ��Ϊ��ʱ���󲹣�Ϊ��ʱ������λȡ��
//
//      // IIR1
//      ԭʼ����
//              2000, 9161, 09F84, 9161, 2000   //bϵ��
//                    8D6A, 09E6A, 9C0B, 1857   //aϵ��
//      bϵ������ͳһ��λ���Ե������档����1λ���������һ�롣
//              0441, F14B, 1535, F14B, 0441    //bϵ������7.521791640349150
//                    8D6A, 09E6A, 9C0B, 1857
//      Set_IIRSftL2XY��Ч��A2��B2����2��ţ���ϵ�����ȴ���4ʱ���á�
//              0441, F14B, 0A9B, F14B, 0441    //bϵ������7.521791640349150
//                    8D6A, 4F35, 9C0B, 1857
//      Ӳ������
//              0441, 8EB5, 0A9A, 8EB5, 0441    //bϵ��Ϊ��ʱ�����䣻Ϊ��ʱ���󲹣�Ȼ�����λ��1
//                    7296, CF35, 63F5, 9857    //aϵ��Ϊ��ʱ���󲹣�Ϊ��ʱ������λȡ��
//
//      // IIR2
//      ԭʼ����
//              2000, C4F7, 2000, 0000, 0000    //bϵ��
//                    C455, 1FB9, 0000, 0000    //aϵ��
//      bϵ������ͳһ��λ���Ե������档����1λ���������һ�롣
//              2BED, AEF6, 2BED, 0000, 0000    //bϵ������0.728491447494969
//                    C455, 1FB9, 0000, 0000
//      Set_IIRSftL2XY��Ч��A2��B2����2��ţ���ϵ�����ȴ���4ʱ���á�
//              2BED, AEF6, 15F7, 0000, 0000
//                    C455, 0FDD, 0000, 0000
//      Ӳ������
//              2BED, D10A, 15F6, 0000, 0000    //bϵ��Ϊ��ʱ�����䣻Ϊ��ʱ���󲹣�Ȼ�����λ��1
//                    3BAB, 8FDC, 8000, 8000    //aϵ��Ϊ��ʱ���󲹣�Ϊ��ʱ������λȡ��
//
//      // IIR3
//      ԭʼ����
//              2000, 9AE7, 08E00, 9AE7, 2000   //bϵ��
//                    8DC3, 09D0F, 9DC2, 1793   //aϵ��
//      bϵ������ͳһ��λ���Ե������档����1λ���������һ�롣
//              0519, EFE6, 169E, EFE6, 0519    //bϵ������6.278090742602100
//                    8DC3, 09D0F, 9DC2, 1793
//      Set_IIRSftL2XY��Ч��A2��B2����2��ţ���ϵ�����ȴ���4ʱ���á�
//              0519, EFE6, 0B4F, EFE6, 0519
//                    8DC3, 4E88, 9DC2, 1793
//      Ӳ������
//              0519, 901A, 0B4F, 901A, 0519    //bϵ��Ϊ��ʱ�����䣻Ϊ��ʱ���󲹣�Ȼ�����λ��1
//                    723D, CE87, 623E, 9793    //aϵ��Ϊ��ʱ���󲹣�Ϊ��ʱ������λȡ��
////////////////////////////////////////////////////////
//��3�Σ�S18����ȱ1bit��
//1-2�Σ�S19������
//4�Σ�S20������
Sub_AutoField IIR_SetLP_99DB_DAC330G;
		// RD0 = 0x01A1;        // CFG
	
		//  IIR0
		//  064E, 88BC, 03AF, 88BC, 064E
		//        71FC, CDFF, 60CE, 96E3
		RD0 = 0x064E;
		DAC_IIR1_HD = RD0;  //b0
		RD0 = 0x88BC;
		DAC_IIR1_HD = RD0;  //b1
		RD0 = 0x03AF;
		DAC_IIR1_HD = RD0;  //b2
		RD0 = 0x88BC;
		DAC_IIR1_HD = RD0;  //b3
		RD0 = 0x064E;
		DAC_IIR1_HD = RD0;  //b4
		RD0 = 0x71FC;
		DAC_IIR1_HD = RD0;  //a1
		RD0 = 0xCDFF;
		DAC_IIR1_HD = RD0;  //a2
		RD0 = 0x60CE;
		DAC_IIR1_HD = RD0;  //a3
		RD0 = 0x96E3;
		DAC_IIR1_HD = RD0;  //a4
		DAC_IIR1_HD = RD0;  //��дһ��
	
		//  IIR1
		//  0441, 8EB5, 0A9A, 8EB5, 0441
		//        7296, CF35, 63F5, 9857
		RD0 = 0x0441;
		DAC_IIR1_HD = RD0;  //b0
		RD0 = 0x8EB5;
		DAC_IIR1_HD = RD0;  //b1
		RD0 = 0x0A9A;
		DAC_IIR1_HD = RD0;  //b2
		RD0 = 0x8EB5;
		DAC_IIR1_HD = RD0;  //b3
		RD0 = 0x0441;
		DAC_IIR1_HD = RD0;  //b4
		RD0 = 0x7296;
		DAC_IIR1_HD = RD0;  //a1
		RD0 = 0xCF35;
		DAC_IIR1_HD = RD0;  //a2
		RD0 = 0x63F5;
		DAC_IIR1_HD = RD0;  //a3
		RD0 = 0x9857;
		DAC_IIR1_HD = RD0;  //a4
		DAC_IIR1_HD = RD0;  //��дһ��
	
		//  IIR2
		//  2BED, D10A, 15F6, 0000, 0000
		//        3BAB, 8FDC, 8000, 8000
		RD0 = 0x2BED;
		DAC_IIR1_HD = RD0;  //b0
		RD0 = 0xD10A;
		DAC_IIR1_HD = RD0;  //b1
		RD0 = 0x15F6;
		DAC_IIR1_HD = RD0;  //b2
		RD0 = 0x0000;
		DAC_IIR1_HD = RD0;  //b3
		RD0 = 0x0000;
		DAC_IIR1_HD = RD0;  //b4
		RD0 = 0x3BAB;
		DAC_IIR1_HD = RD0;  //a1
		RD0 = 0x8FDC;
		DAC_IIR1_HD = RD0;  //a2
		RD0 = 0x8000;
		DAC_IIR1_HD = RD0;  //a3
		RD0 = 0x8000;
		DAC_IIR1_HD = RD0;  //a4
		DAC_IIR1_HD = RD0;  //��дһ��
	
		//  IIR3
		//  0519, 901A, 0B4F, 901A, 0519
		//        723D, CE87, 623E, 9793
		RD0 = 0x0519;
		DAC_IIR1_HD = RD0;  //b0
		RD0 = 0x901A;
		DAC_IIR1_HD = RD0;  //b1
		RD0 = 0x0B4F;
		DAC_IIR1_HD = RD0;  //b2
		RD0 = 0x901A;
		DAC_IIR1_HD = RD0;  //b3
		RD0 = 0x0519;
		DAC_IIR1_HD = RD0;  //b4
		RD0 = 0x723D;
		DAC_IIR1_HD = RD0;  //a1
		RD0 = 0xCE87;
		DAC_IIR1_HD = RD0;  //a2
		RD0 = 0x623E;
		DAC_IIR1_HD = RD0;  //a3
		RD0 = 0x9793;
		DAC_IIR1_HD = RD0;  //a4
		DAC_IIR1_HD = RD0;  //��дһ��
	
		Return_AutoField(0*MMU_BASE);





//////////////////////////////////////////////////////////
////  ����:
////      IIR_PATH3_HP500Init
////  ����:
////      ���ø�ͨ�˲���ϵ��
////  ����:
////      �ޣ�����
////  ����ֵ:
////      ��
////  ע��:
////      [50,500,0.1,40], fs=16000, G1_recip=1, iir_seg = 1
////      gain = 0.00dB, rpc = 0.23dB, rsc = -40.07dB
////      G1_recip =
////           1
////      b11 =
////              8192      -24557       24557       -8192
////      a11 =
////              8192      -22116       20013       -6058
//////////////////////////////////////////////////////////
//    Sub_AutoField IIR_PATH3_HP500Init;
//
//    // HA330G_FW_HP_iir_ellip_16000_50_500_0.1_40.txt
//    //ת���ɹ�
//    //����ֵ	0x0042
//    //��������	1
//    //���ն���	4
//    //û�о���ֵ����32767����
//
//    RD0 = 0x7FFF;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0042;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x7FFF;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0042;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x7FFF;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x0042;
//    IIR_PATH3_HD = RD0;
//    RD0 = 0x2000;
//    IIR_PATH3_HD = RD0;     // b0
//    RD0 = 0xDFED;
//    IIR_PATH3_HD = RD0;     // b1
//    RD0 = 0x5FED;
//    IIR_PATH3_HD = RD0;     // b2
//    RD0 = 0xA000;
//    IIR_PATH3_HD = RD0;     // b3
//    RD0 = 0x0000;
//    IIR_PATH3_HD = RD0;     // b4
//    RD0 = 0x5664;
//    IIR_PATH3_HD = RD0;     // a1
//    RD0 = 0xCE2D;
//    IIR_PATH3_HD = RD0;     // a2
//    RD0 = 0x17AA;
//    IIR_PATH3_HD = RD0;     // a3
//    RD0 = 0x8000;
//    IIR_PATH3_HD = RD0;     // a4
//    RD0 = 0x0042;
//    IIR_PATH3_HD = RD0;     // CFG
//
//    //�Ĵ�����ַ��λ
//    IIR_PATH3_CLRADDR;
//    Return_AutoField(0*MMU_BASE);
END SEGMENT
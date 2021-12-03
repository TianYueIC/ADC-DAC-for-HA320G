#define _CALCULATION_F_

#include <cpu11.def>
#include <resource_allocation.def>
#include <RN_DSP_Cfg.def>
#include <gpio.def>
#include <global.def>
#include <GD25.def>

#define RN_DELAY_VREF_STABLE    (10*2000)
#define RN_VREF_VAL_STD         249 //��ӦVCK0==972mV��VREF==1V
#define RN_IO_MAP_FREQ_CAL              GP0_7   // У׼Ƶ������
#define Flag_PORT_GP07                  RD0_Bit7
#define Flag_Cal_Pin_Out                Flag_PORT_GP01
#define Flag_Cal_Pin_In                 Flag_PORT_GP02
#define Flag_Freq_Cal                   Flag_PORT_GP07    

extern Delay_RD0;

CODE SEGMENT CALCULATION_F;
////////////////////////////////////////////////////////
//  ����:
//      VrefSetCfg_HA320G
//  ����:
//      ����У׼��¼���û�׼��ѹ
//      ע�ͣ�����������һ���Ա��Bit0==0ʱִ�У�POR��һ���Ա�־λBit0==0,��λ��Ϊ1,ֻ��POR��λ��
//  ����:
//      1.RD0: У׼�����룬b10~b0��Ч
//             b10~b8 ����ƫ������ֵ��PORֵΪ3'b000�����ֶ�Ϊϵͳ����ֵ��У׼ʱ������
//             b7 :   ����
//             b6~b0  ��׼��ѹ����ֵ��PORֵΪ7'b1000011��У׼ʱ�������ֶ�
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField VrefSetCfg_HA320G;
    RA0 = RD0;
    RD0 = StandBy_RDCfg;
    if(RD0_Bit0==1) goto L_VrefSetCfg_OK;
    RD0 = 0x77F;
    RA0 &= RD0;         //�����Чλ

    RD0 = 0;
    RD0_SetBit16;
    StandBy_WRSel = RD0;//�����ö˿�
    RD0 = RA0;
    RF_Not(RD0);        //У׼��Ĵ洢ֵΪ����
    StandBy_WRCfg = RD0;

	//�ȴ�10msʱ��
    RD2 = RN_DELAY_VREF_STABLE;
    call _Delay_RD2;
L_VrefSetCfg_OK:
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      POR_Set_Flag
//  ����:
//      ��λPOR��һ���Ա��Bit0Ϊ1��POR��һ���Ա�־λBit0==0,��λ��Ϊ1,ֻ��POR��λ��
//  ����:
//      ��
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField POR_Set_Flag;
    Push_Set_CPUSpeed(RN_SP3);
    RD0 = 0;
    RD0_SetBit17;
    StandBy_WRSel = RD0;
    RD0 = 1;
    StandBy_WRCfg = RD0;
    RD0 = 0;
    RD0_SetBit18;
    StandBy_WRSel = RD0;
    StandBy_WRCfg = RD0;
    Pop_CPUSpeed;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      VrefInit_BySAR_HA320G;
//  ����:
//      ͨ��SAR_ADCУ׼Vref�������У׼������
//      ע�ͣ�ִ�б�����ʱ����972mV��ѹ��V_CHK0��������
//  ����:
//      ��
//  ����ֵ:
//      1.RD0 :  0~OK  1~У׼��Χ����  2~У׼��Χ����
//      2.RD1 :  У׼������
////////////////////////////////////////////////////////
Sub_AutoField VrefInit_BySAR_HA320G;

    RD0 = StandBy_RDCfg;
    if(RD0_Bit0==1) goto L_VrefInit_BySAR_End2;

    //����DSP����ʱ��
    DSP_Disable;
    RD0 = RN_CFG_DSP48M+RN_CFG_FLOW_DIV8;  //Slow = 4MHz
    DSP_FreqDiv = RD0;
    //ʹ��DSP����
    DSP_Enable;
    Pull_Enable;
    // ��ʼ��SAR,ѡ��ͨ��ΪVCHK0����
    RD0 = 0;
    RD0_SetBit7;
    RD0_SetBit8;
    StandBy_WRSel = RD0;
    RD0 = 0;
    StandBy_WRCfg = RD0;
    SAR_Enable;
    RD0 = 0b0100;// 4KHz����
    SAR_Cfg = RD0;
    RD2 = 10*2000;
    call _Delay_RD2;// ��ʱ10ms�ȴ��ź��ȶ����л�ͨ�����źŽ���ʱ��<1ms��

    // ����Vref
    RD0 = RN_VREF_VAL_STD;
    RA0 = RD0;
    RD0 = 0;
    RD0_SetBit16;
    StandBy_WRSel = RD0;
    RD3 = 0b00111100;// ��ֵ(0x3c)
    RD0 = RD3;
    RF_Not(RD0);
    StandBy_WRCfg = RD0;
    RD2 = RN_DELAY_VREF_STABLE;
    call _Delay_RD2;

    // ����SAR_ADC����ֵ
    Start_SAR;
    Wait_While(RFlag_SAR==1);
    RD0 = SAR_Data;
	RD0_ClrByteL8;
    RD0 -= RA0;
    if(RD0_Zero) goto L_VrefInit_BySAR_OK;// �ж϶�ֵ�Ƿ��Ӧ972mV��Val=50��
    if(RD0_Bit31==0) goto L_VrefInit_BySAR_H0;// ��ֵƫ��˵��Vrefƫ��

    //Vrefƫ�ߣ���������Ȼ�ƫ��
    RD1 = 0x3D;
L_VrefInit_BySAR_L0:
    RD3 --;
    RD0 = RD3;
    RF_Not(RD0);
    StandBy_WRCfg = RD0;

    RD2 = RN_DELAY_VREF_STABLE;
    call _Delay_RD2;

    Start_SAR;
    Wait_While(RFlag_SAR==1);
    RD0 = SAR_Data;
    RD0 -= RA0;
    if(RD0_Bit31==0) goto L_VrefInit_BySAR_OK;
    RD1 --;
    if(RQ_nZero) goto L_VrefInit_BySAR_L0;
    RD0 = 1;  //��ͻ�ƫ�ߣ�����
    goto L_VrefInit_BySAR_End;

    //Vrefƫ�ͣ��������Vref����ֵ�𽥼�С
L_VrefInit_BySAR_H0:
    RD1 = 0x42;
L_VrefInit_BySAR_H1:
    RD3 ++;
    RD0 = RD3;
    RF_Not(RD0);
    StandBy_WRCfg = RD0;

    RD2 = RN_DELAY_VREF_STABLE;
    call _Delay_RD2;

    Start_SAR;
    Wait_While(RFlag_SAR==1);
    RD0 = SAR_Data;
    RD0 -= RA0;
    if(RD0_Zero) goto L_VrefInit_BySAR_OK;
    if(RD0_Bit31==1) goto L_VrefInit_BySAR_OK;
    RD1 --;
    if(RQ_nZero) goto L_VrefInit_BySAR_H1;
    RD0 = 2;  //��߻�ƫ�ͣ�����
    goto L_VrefInit_BySAR_End;

L_VrefInit_BySAR_OK:
    RD0 = 0;
L_VrefInit_BySAR_End:
    RD1 = RD3;

    //����DSP����
    DSP_Disable;
    Pull_Disable;
L_VrefInit_BySAR_End2:
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      ClkCal_HA320G
//  ����:
//      У׼��Ƶ��32MHz�������У׼������
//      ע�ͣ�ִ�б�����ʱ����1KHz 50%ռ�ձȻ�׼������DEBUG_EN��������
//  ����:
//      ��
//  ����ֵ:
//      1.RD0 ��0 У׼�������
//            : 1 δ�ɹ����ڲ�Ƶ��ƫ��
//            : 2 δ�ɹ����ڲ�Ƶ��ƫ��
//      2.RD1 ��У׼������,
//             b6~b0:7λֵ��Ƶ��Ϊ������������
//             PORֵ��7'b0111111
//             ��7'b0000000ΪƵ�����
//               7'b1111111ΪƵ�����
//      ������Ƶʱ���ú��� ClkSetCfg_HA320G;
////////////////////////////////////////////////////////
Sub_AutoField ClkCal_HA320G;
    push RD4;
    Set_CPUSpeed(RN_SP3);   //2MIPS

    // ��׼ʱ������ˣ���ʼ��Ϊ��������
    RD0 = RN_IO_MAP_FREQ_CAL;
    GPIO_WEn0 = RD0;
    RD0 = GPIO_IN;
    GPIO_Set0 = RD0;

    // ����ʱ������ֵΪ��λֵ
    RD3 = 0b0111111;
    call ClkInit_WBL7;
    call ClkInit_FreqCheck_Confirm; //RD0 = 0:�ڲ�Ƶ��ƫ��
    if(RD0_Zero) goto L_OSC_Cal_Sub_Loop;// ��ǰƫ�죬��Ҫ��������

    // ��ǰƫ������Ҫ������
L_OSC_Cal_Add_Loop:
    RD3 ++;
    RD0 = RD3;
    if(RD0_Bit7 == 1) goto L_OSC_Cal_ErrL;// ���������Ȼƫ��
    call ClkInit_WBL7;
    call ClkInit_FreqCheck_Confirm; //0~�ڲ�Ƶ��ƫ�� -1~�ڲ�Ƶ��ƫ��
    if(RD0_Zero) goto L_OSC_Cal_OK;
    goto L_OSC_Cal_Add_Loop;

    //��ǰƫ�죬��Ҫ��������
L_OSC_Cal_Sub_Loop:
    RD3 --;
    if(RQ_Borrow) goto L_OSC_Cal_ErrH;// ����������Ȼƫ��
    call ClkInit_WBL7;
    call ClkInit_FreqCheck_Confirm; //0~�ڲ�Ƶ��ƫ�� -1~�ڲ�Ƶ��ƫ��
    RD0 ++;
    if(RD0_Zero) goto L_OSC_Cal_OK;
    goto L_OSC_Cal_Sub_Loop;

L_OSC_Cal_ErrL:
    RD0 = 2;
    RD1 = 0b1111111;
    goto L_OSC_Cal_End;
L_OSC_Cal_ErrH:
    RD0 = 1;
    RD1 = 0b0000000;
    goto L_OSC_Cal_End;
L_OSC_Cal_OK:
    RD0 = 0;
    RD1 = RD3;
L_OSC_Cal_End:
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      ClkSetCfg_HA320G
//  ����:
//      ����У׼��¼������Ƶ
//  ����:
//      1.RD0��У׼������
//             b7~b0:  ��λ������ֱ��д��
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField ClkSetCfg_HA320G;
    RD3 = RD0;
    RD0 = StandBy_RDCfg;
    if(RD0_Bit0==1) goto L_ClkSetCfg_End;
    RF_GetL8(RD3);
    call ClkInit_WBL7;
    RD2 = 2000;
    call _Delay_RD2; //�ӳ�1ms�ȴ�Ƶ���ȶ�
L_ClkSetCfg_End:
    Return_AutoField(0);


////////////////////////////////////////////////////////
//  ����:
//      ClkInit_WBL7
//  ����:
//      ʱ��У׼д���7λ����ֵ
//  ����:
//      1.RD3:����ֵ
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField ClkInit_WBL7;
    RD0 = 0;
    RD0_SetBit19;
    StandBy_WRSel = RD0;
    RD0 = RD3;
    StandBy_WRCfg = RD0;
    RD2 = 2000;     //�ӳ�1ms�ȴ�Ƶ���ȶ�
    call _Delay_RD2;
    Return_AutoField(0);


////////////////////////////////////////////////////////
//  ����:
//      ClkInit_FreqCheck_Confirm
//  ����:
//      ���ȷ�ϵ�ǰ��Ƶ�Ƿ��ѽӽ�Ŀ��ֵ
//  ����:
//      ��
//  ����ֵ:
//      1.RD0: 0~�ڲ�Ƶ��ƫ�� -1~�ڲ�Ƶ��ƫ��
//      2.RD1: �ȶ�ǰȷ�ϴ���
////////////////////////////////////////////////////////
Sub_AutoField ClkInit_FreqCheck_Confirm;
    push RD4;

    RD2 = 1;// RD2:�ܼ�����������
    // ���μ��Ƶ��
    call ClkInit_FreqCheck;
    RD4 = RD1;
    goto L_ClkInit_FreqCheck_Confirm_0;
    // ��μ��Ƶ��ֱ��Ƶ���ȶ�
L_ClkInit_FreqCheck_Confirm_Loop:
    // ����RD4Ϊ�ϴμ��ļ���ֵ
    RD0 = RD3;
    RD4 = RD0;
L_ClkInit_FreqCheck_Confirm_0:
    // ����������Ҫ������ʱ����������������������
    RD2 ++;
    call ClkInit_FreqCheck;
    RD3 = RD1;// �Ĵ浱ǰ������ֵ
    RD1 -= RD4;// ���㱾�μ���ֵ���ϴμ���ֵ����
    RF_Abs(RD1);
    RD1 -= 10;// �����������ֵʱ���������
    if(RQ_nBorrow) goto L_ClkInit_FreqCheck_Confirm_Loop;

    // ����С����ֵ�����̽���
    RD1 = RD2;

    pop RD4;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:ʱ��У׼����
//           2MIPS(Speed3)����Debug_En�͵�ƽ500us
//  ����ֵ:
//      RD0 ��0 �ڲ�Ƶ��ƫ��
//          : -1 �ڲ�Ƶ��ƫ��
//          RD1 : �ڲ�����ֵ����ʱ���ڵ��ԣ�
////////////////////////////////////////////////////////
Sub_AutoField ClkInit_FreqCheck;
    RD2 = 200;
    RD3 = 0;//������

//MODI 2020/5/28 15:52:24

    //ͬ��������
//    Wait_While(Flag_DebugEn==0);
//    nop; nop;
//    Wait_While(Flag_DebugEn==1);
    RD0 = RN_IO_MAP_FREQ_CAL;
    GPIO_WEn0 = RD0;
L_ClkInit_FreqCheck_Sync0:
    RD0 = GPIO_Data0;
    if(Flag_Freq_Cal==0) goto L_ClkInit_FreqCheck_Sync0;
    nop;nop;
L_ClkInit_FreqCheck_Sync1:
    RD0 = GPIO_Data0;
    if(Flag_Freq_Cal==1) goto L_ClkInit_FreqCheck_Sync1;

    //һ��ѭ��4��ָ��궨Ŀ��RD0 = 250
L_ClkInit_FreqCheck_L0:
    nop;
    RD3 ++;
    RD0 = GPIO_Data0;
    if(Flag_Freq_Cal==0) goto L_ClkInit_FreqCheck_L0;
    //if(Flag_DebugEn==0) goto L_ClkInit_FreqCheck_L0;

    RD1 = RD3;
    RD0 = RD3;
    RD0 -= RD2;
    if(RQ_nBorrow) goto L_ClkInit_FreqCheck_Fast;
L_ClkInit_FreqCheck_Slow:
    RD0 = -1;
    Return_AutoField(0);
L_ClkInit_FreqCheck_Fast:
    RD0 = 0;
    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  ����:
//      Set_Vref_SysClk
//  ����:
//      ��GD25�ж�ȡ��ѹУ׼ֵ��Ƶ��У׼ֵ��д���׼ϵͳ
//      ��Ӧƽ̨PrimoU600_V110
//  ����:
//      ��
//  ����ֵ��
//      ��
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Set_Vref_SysClk;
    RD0 = StandBy_RDCfg;
    if(RD0_Bit0==1) goto L_Set_Vref_SysClk_End;
    RSP -= 3*MMU_BASE;
    RA0 = RSP;

#define GD25_VOLT    M[RA0+0*MMU_BASE]
#define GD25_FREQ    M[RA0+1*MMU_BASE]
#define GD25_Scene   M[RA0+0*MMU_BASE]
#define GD25_Vol     M[RA0+1*MMU_BASE]
#define GD25_Flag    M[RA0+2*MMU_BASE]

    // ��ȡУ׼ֵ
    RD0 = RN_GD25_VOLT_ADDR;
    send_para(RD0);// Դ��ַ
    send_para(RA0);// Ŀ���ַ
    RD0 = 2*MMU_BASE;
    send_para(RD0);// �������ȣ���λ���ֽڣ�����Ϊ4��������
    call GD25_Read_Data;

    // ����У׼ֵ���õ�ѹ��Ƶ��
    RD0 = GD25_FREQ;
    call ClkSetCfg_HA320G;
    RD0 = GD25_VOLT;
    call VrefSetCfg_HA320G;

#undef GD25_VOLT
#undef GD25_FREQ
#undef GD25_Scene
#undef GD25_Vol
#undef GD25_Flag

    RSP += 3*MMU_BASE;
L_Set_Vref_SysClk_End:
    Return_AutoField(0);

END SEGMENT
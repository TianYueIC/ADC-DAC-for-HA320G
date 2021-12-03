////////////////////////////////////////////////////////
//  ����:
//      VrefInit_ByComp_HA320G;
//  ����:
//      ͨ��ר�ñȽ���У׼Vref�������У׼������
//      ע�ͣ�ִ�б�����ʱ����972mV��ѹ��V_CHK0��������
//  ����:
//      ��
//  ����ֵ:
//      1.RD0 :  0~OK  1~У׼��Χ����  2~У׼��Χ����
//      2.RD1 :  У׼������
////////////////////////////////////////////////////////
Sub_AutoField VrefInit_ByComp_HA320G;

    RD0 = StandBy_RDCfg;
    if(RD0_Bit0==1) goto L_VrefInit_ByComp_End2;

    // ����Vref
    RD0 = 0;
    RD0_SetBit16;
    StandBy_WRSel = RD0;
    RD3 = 0b011100111100;// ��ֵ(0x73c)
    RD0 = RD3;
    RF_Not(RD0);
    StandBy_WRCfg = RD0;
	RD2 = RN_DELAY_VREF_STABLE;
    call _Delay_RD2;

	//Flag == 1���ڲ�СL_VrefInit_ByComp_H0
    if(RFlag_AD3DC==1) goto L_VrefInit_ByComp_H0;// ��ֵƫ��˵��Vrefƫ��

    //Vrefƫ�ߣ���������Ȼ�ƫ��
L_VrefInit_ByComp_L0:
    RD1 = 0x700;
    RD1 -= RD3;
    if(RQ_nZero) goto L_VrefInit_ByComp_L1;
    RD0 = 1;  //��ͻ�ƫ�ߣ�����
    goto L_VrefInit_ByComp_End;
L_VrefInit_ByComp_L1:
    RD3 --;
    RD0 = RD3;
    RF_Not(RD0);
    StandBy_WRCfg = RD0;
    RD2 = RN_DELAY_VREF_STABLE;
    call _Delay_RD2;
    if(RFlag_AD3DC==0) goto L_VrefInit_ByComp_L0;
	//�ص�1��
	RD3 ++;
    RD0 = RD3;
    RF_Not(RD0);
    StandBy_WRCfg = RD0;
    RD2 = RN_DELAY_VREF_STABLE;
    call _Delay_RD2;
	goto L_VrefInit_ByComp_OK;

    //Vrefƫ�ͣ��������Vref����ֵ�𽥼�С
L_VrefInit_ByComp_H0:
    RD1 = 0x77F;
    RD1 -= RD3;
    if(RQ_nZero) goto L_VrefInit_ByComp_H1;
    RD0 = 2;  //��߻�ƫ�ͣ�����
    goto L_VrefInit_ByComp_End;
L_VrefInit_ByComp_H1:
    RD3 ++;
    RD0 = RD3;
    RF_Not(RD0);
    StandBy_WRCfg = RD0;
    RD2 = RN_DELAY_VREF_STABLE;
    call _Delay_RD2;

    if(RFlag_AD3DC==1) goto L_VrefInit_ByComp_H0;

L_VrefInit_ByComp_OK:
    RD0 = 0;
L_VrefInit_ByComp_End:
    RD1 = RD3;
L_VrefInit_ByComp_End2:
	nop;
    Return_AutoField(0);
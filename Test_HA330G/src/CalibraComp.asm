////////////////////////////////////////////////////////
//  名称:
//      VrefInit_ByComp_HA320G;
//  功能:
//      通过专用比较器校准Vref，并输出校准控制码
//      注释：执行本函数时需有972mV电压从V_CHK0引脚输入
//  参数:
//      无
//  返回值:
//      1.RD0 :  0~OK  1~校准范围过高  2~校准范围过低
//      2.RD1 :  校准控制码
////////////////////////////////////////////////////////
Sub_AutoField VrefInit_ByComp_HA320G;

    RD0 = StandBy_RDCfg;
    if(RD0_Bit0==1) goto L_VrefInit_ByComp_End2;

    // 设置Vref
    RD0 = 0;
    RD0_SetBit16;
    StandBy_WRSel = RD0;
    RD3 = 0b011100111100;// 初值(0x73c)
    RD0 = RD3;
    RF_Not(RD0);
    StandBy_WRCfg = RD0;
	RD2 = RN_DELAY_VREF_STABLE;
    call _Delay_RD2;

	//Flag == 1，内部小L_VrefInit_ByComp_H0
    if(RFlag_AD3DC==1) goto L_VrefInit_ByComp_H0;// 读值偏大，说明Vref偏低

    //Vref偏高，调整至相等或偏低
L_VrefInit_ByComp_L0:
    RD1 = 0x700;
    RD1 -= RD3;
    if(RQ_nZero) goto L_VrefInit_ByComp_L1;
    RD0 = 1;  //最低还偏高，报错
    goto L_VrefInit_ByComp_End;
L_VrefInit_ByComp_L1:
    RD3 --;
    RD0 = RD3;
    RF_Not(RD0);
    StandBy_WRCfg = RD0;
    RD2 = RN_DELAY_VREF_STABLE;
    call _Delay_RD2;
    if(RFlag_AD3DC==0) goto L_VrefInit_ByComp_L0;
	//回调1步
	RD3 ++;
    RD0 = RD3;
    RF_Not(RD0);
    StandBy_WRCfg = RD0;
    RD2 = RN_DELAY_VREF_STABLE;
    call _Delay_RD2;
	goto L_VrefInit_ByComp_OK;

    //Vref偏低，往大调整Vref，读值逐渐减小
L_VrefInit_ByComp_H0:
    RD1 = 0x77F;
    RD1 -= RD3;
    if(RQ_nZero) goto L_VrefInit_ByComp_H1;
    RD0 = 2;  //最高还偏低，报错
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
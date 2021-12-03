#define _Main_F_

#include <CPU11.def>
#include <USI.def>
#include <SOC_Common.def>
#include <Download.def>
#include <resource_allocation.def>

extern _Download_Function;
extern L_Test_Main0;
extern BaseROM_Test;
CODE SEGMENT HA320F_Main_F = 0x00;
//�ж�������
//-------------------------
//�ж�0~6ֻ�ܵ�ROM
CPU_SimpleLevel_L;CPU_SimpleLevel_H;//goto far Main;
goto far Main;
goto far Main;
goto far Main;
goto far Main;
goto far Main;
goto far Main;
nop;nop;//goto far _Int_unMask2ROM_Flag;

//�ж�7~14ֻ�ܵ�Flash,λ�ñ���
nop; nop;   //Null
nop; nop;   //Null
nop; nop;   //Null
nop; nop;   //Null
nop; nop;   //Null
nop; nop;   //Null
nop; nop;   //Null
nop; nop;   //Null

//�ж�15~30   Default��Flash "Set_IntUser2Rom" ��ROM
goto RN_Cache_StartAddr_Program;       //Watch Dog
goto RN_Cache_StartAddr_Program+2;     //_Int_Timer_Op0
goto RN_Cache_StartAddr_Program+4;     //_Int_Timer_Op1
goto RN_Cache_StartAddr_Program+6;     //_Int_Timer_Op2
goto RN_Cache_StartAddr_Program+8;     //GP0_0
goto RN_Cache_StartAddr_Program+10;    //GP0_3
goto RN_Cache_StartAddr_Program+12;    //GP1_0
goto RN_Cache_StartAddr_Program+14;    //Debug_En
goto RN_Cache_StartAddr_Program+16;    //Debug_SPIRx
goto RN_Cache_StartAddr_Program+18;    //GPIO_Share0
goto RN_Cache_StartAddr_Program+20;    //GPIO_Share1
goto RN_Cache_StartAddr_Program+22;    //GPIO_All0
goto RN_Cache_StartAddr_Program+24;    //GPIO_All1
goto RN_Cache_StartAddr_Program+26;    //USI
goto RN_Cache_StartAddr_Program+28;    //_Int_ReadTime_Counter;
goto RN_Cache_StartAddr_Program+30;    //_Int_SingleStep;


Main:
	//Set_LevelL25;//FOR 320F
    CPU_SimpleLevel_L;

	// GPIO��ʼ��
    RD0 = 0xff;
    GPIO_WEn0 = RD0;
    GPIO_Data0 = RD0;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;

    //�ȴ�IO�ϵ����
/////////////////////////////
    RD0 = 0x8;
_Wait_PowerOK:
    CPU_SimpleLevel_L;
    nop;nop;nop;
    nop;nop;nop;nop;nop;
    CPU_SimpleLevel_H;
    nop;nop;nop;nop;nop;
    nop;nop;nop;nop;nop;
    RD0 --;
    if(RD0_Zero) goto _Check_PowerOK_Timeout;
    if(RFlag_VDDIO==0) goto _Wait_PowerOK;

_Check_PowerOK_Timeout:
	CPU_SimpleLevel_H;
//*********************************
//����ʱ��ע�͵��¾��������ع���
//call _Clock_Init;  //����ʱ�ӿ�ʱ��

//	goto _Download_Function;
//*********************************
//    call _Clock_Init;
    goto L_Test_Main0;

//--------------------------------
//       MMU �жϴ���
//--------------------------------
/*
//MMU �� Char
_MMU_Const_CharOp:
    Sel_Flash4Data;
    RD0 = RP_MMUAddr;           //����ַ
    RA0 = RD0;
    RD0 = M[RA0];
    if(RFlag240) goto _MMU_Const_CharOp_L0;   //�жϵ�Ϊ0
    goto _MMU_Const_CharOp_L1;
_MMU_Const_CharOp_L0:
    RF_RotateR8(RD0);           //ML8��Ч
_MMU_Const_CharOp_L1:
    RF_GetL8(RD0);
    if(RD0_Bit7==0) goto _MMU_Const_CharOp_End;
    RD0_SetByteH24;
_MMU_Const_CharOp_End:
    Sel_Flash4Inst;
    Set_Opcode_Dis;
    Set_Int_Dis1;               //���ж�
    Set_Int_Dis5;
    Set_Int_En1;
    Set_Int_En5;
    Set_IntFunc_En;
    Return_AutoField(0);

    //MMU �� uChar
_MMU_Const_uCharOp:
    Sel_Flash4Data;
    RD0 = RP_MMUAddr;           //����ַ
    RA0 = RD0;
    RD0 = M[RA0];
    if(RFlag240) goto _MMU_Const_uCharOp_L0;
    RF_GetL8(RD0);              //L8��Ч
    goto _MMU_Const_uCharOp_End;
_MMU_Const_uCharOp_L0:
    RF_GetML8(RD0);             //ML8��Ч
_MMU_Const_uCharOp_End:
    Sel_Flash4Inst;
    Set_Opcode_Dis;
    Set_Int_Dis2;
    Set_Int_Dis5;
    Set_Int_En2;
    Set_Int_En5;
    Set_IntFunc_En;
    Return_AutoField(0);

    //MMU �� word
_MMU_Const_WordOp:
    Sel_Flash4Data;
    RD0 = RP_MMUAddr;           //����ַ
    RA0 = RD0;
    RD0 = M[RA0];
    if(RFlag240) goto _MMU_Const_WordOp_L1;
    RF_GetL8(RD0);              //ML8��Ч
    RD2 = M[RA0+2];
    RF_GetML8(RD2);
    RF_RotateL8(RD0);
    RD0 += RD2;
_MMU_Const_WordOp_L1:
    if(RD0_Bit15==0) goto _MMU_Const_WordOp_End;
    RD0_SetByteH16;
_MMU_Const_WordOp_End:
    Sel_Flash4Inst;
    Set_Opcode_Dis;
    Set_Int_Dis3;
    Set_Int_Dis5;
    Set_Int_En3;
    Set_Int_En5;
    Set_IntFunc_En;
    Return_AutoField(0);

    //MMU �� uword
_MMU_Const_uWordOp:
    Sel_Flash4Data;
    RD0 = RP_MMUAddr;           //����ַ
    RA0 = RD0;
    RD0 = M[RA0];
    if(RFlag240) goto _MMU_Const_uWordOp_End;
    RF_GetL8(RD0);              //ML8��Ч
    RD2 = M[RA0+2];
    RF_GetML8(RD2);
    RF_RotateL8(RD0);
    RD0 += RD2;
_MMU_Const_uWordOp_End:
    Sel_Flash4Inst;
    Set_Opcode_Dis;
    Set_Int_Dis4;
    Set_Int_Dis5;
    Set_Int_En4;
    Set_Int_En5;
    Set_IntFunc_En;
    Return_AutoField(0);

    //MMU �� Dword
_MMU_Const_DWordOp:
    Sel_Flash4Data;
    RD0 = RP_MMUAddr;           //����ַ
    RA0 = RD0;
    RD0 = M[RA0];
    RF_RotateR16(RD0);
    RD0 += M[RA0+2];            //ReadDword
    if(RFlag240) goto _MMU_Const_DWordOp_End;
    RD2 = M[RA0+4];
    RF_GetML8(RD2);
    RF_RotateL8(RD0);           //ȡ��24λ������8λ
    RD0_ClrByteL8;
    RD0 += RD2;
_MMU_Const_DWordOp_End:
    Sel_Flash4Inst;
    Set_Opcode_Dis;
    Set_Int_Dis5;
    Set_Int_En5;
    Set_IntFunc_En;
    Return_AutoField(0);
*/

//========================
//����ʱ����======
Sub_AutoField _Clock_Init;
	RD0 = 0;
	RD0_SetBit19;
	StandBy_WRSel = RD0;
	RD0 = 0b01011011;
	StandBy_WRCfg = RD0;

	Return_AutoField(0*MMU_BASE);

//========================

END SEGMENT
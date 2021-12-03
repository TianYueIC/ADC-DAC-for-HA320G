#define _SOC_COMMON_F_

#include <CPU11.def>
#include <resource_allocation.def>
#include <Barrel.def>

CODE SEGMENT SOC_COMMON_F;
////////////////////////////////////////////////////////
//  ����:
//      _Rf_ShiftL_Reg
//  ����:
//      RD0����RD1�Σ��Ҳ�0
//  ����:
//      1.RD0�����ƶ�����
//      2.RD1��Ҫ�ƵĴ���
//  ����ֵ:
//      1.RD0: ��λ���
////////////////////////////////////////////////////////
Sub_AutoField _Rf_ShiftL_Reg;
    RD2 = RD0;
    RD0 = 0x1F;
    RF_Not(RD0);
    RD0 &= RD1;
    if(RD0_nZero) goto L_Rf_ShiftL_Reg_End0;
    RD0 = BRL_SFT + BRL_L;
    RD0 += RD1;
      
    Barrel0_Ctrl = RD0;
    Barrel0_Op(RD2);

    RD0 = RD2;
    Return_AutoField(0);
L_Rf_ShiftL_Reg_End0:
    RD0 = 0;
    Return_AutoField(0);
    


////////////////////////////////////////////////////////
//  ����:
//      _Rf_ShiftR_Reg
//  ����:
//      RD0����RD1�Σ���0
//  ����:
//      1.RD0�����ƶ�����
//      2.RD1��Ҫ�ƵĴ���
//  ����ֵ:
//      1.RD0: ��λ���
////////////////////////////////////////////////////////
Sub_AutoField _Rf_ShiftR_Reg;
	RD2 = RD0;
    RD0 = 0x1F;
    RF_Not(RD0);
    RD0 &= RD1;
    if(RD0_nZero) goto L_Rf_ShiftR_Reg_End0;
    RD0 = BRL_SFT + BRL_R;
    RD0 += RD1;
    Barrel0_Ctrl = RD0;
    Barrel0_Op(RD2);
    RD0 = RD2;
    Return_AutoField(0);
L_Rf_ShiftR_Reg_End0:
    RD0 = 0;
    Return_AutoField (0);



////////////////////////////////////////////////////////
//  ����:
//      _Rf_ShiftR_Signed_Reg
//  ����:
//      RD0����RD1�Σ��󲹷���λ
//  ����:
//      1.RD0�����ƶ�����
//      2.RD1��Ҫ�ƵĴ���
//  ����ֵ:
//      1.RD0: ��λ���
////////////////////////////////////////////////////////
Sub_AutoField _Rf_ShiftR_Signed_Reg;
	RD2 = RD0;
	//RF_Abs(RD0);		
	call _Rf_ShiftR_Reg;
	RD1 = 1;
	RF_RotateR1(RD1);
	RD1 &= RD2;
	if(RQ_nZero) goto L_Rf_ShiftR_Signed_Reg_N;
	Return_AutoField(0);
	
L_Rf_ShiftR_Signed_Reg_N:
	RD3 = RD0;
	RF_Log(RD0);
	RD0 ++;
	RF_Exp(RD0);
	RD0 --;
	RF_Not(RD0);
	RD0 += RD3;
	Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      _Rf_ShiftL
//  ����:
//      RD0����RD1�Σ��Ҳ�0
//  ����:
//      1.RD0�����ƶ�����
//      2.RD1��Ҫ�ƵĴ���
//  ����ֵ:
//      1.RD0: ��λ���
////////////////////////////////////////////////////////
Sub_AutoField _Rf_ShiftL;

    RD1 -= 8;
    if(RQ_Borrow) goto _ShiftL_Little_8;
    RD1 -= 8;
    if(RQ_Borrow) goto _ShiftL_Little_16;
    RD1 -= 8;
    if(RQ_Borrow) goto _ShiftL_Little_24;
    RD1 -= 8;
    RF_GetL8(RD0);
    RF_RotateL24(RD0);
    goto _ShiftL_Little_8;

_ShiftL_Little_24:
    RF_GetL16(RD0);
    RF_RotateL16(RD0);
    goto _ShiftL_Little_8;

_ShiftL_Little_16:
    RF_RotateL8(RD0);
    RD0_CLRBYTEL8;

_ShiftL_Little_8:
    RD1 += 8;
_ShiftL_Little_8_loop:
    if(RQ_Zero) goto _ShiftL_End;
    RF_ShiftL1(RD0);
    RD1 --;
    if(RQ_nZero) goto _ShiftL_Little_8_loop;

_ShiftL_End:
    Return_AutoField (0);



////////////////////////////////////////////////////////
//  ����:
//      _Rf_ShiftR
//  ����:
//      RD0����RD1�Σ���0
//  ����:
//      1.RD0�����ƶ�����
//      2.RD1��Ҫ�ƵĴ���
//  ����ֵ:
//      1.RD0: ��λ���
////////////////////////////////////////////////////////
Sub_AutoField _Rf_ShiftR;
//  ����:  RD0����RD1��;
//  ���:  RD0��RD1;
//  ����:  RD0;

    RD1 -= 8;
    if(RQ_Borrow) goto _ShiftR_Little_8;
    RD1 -= 8;
    if(RQ_Borrow) goto _ShiftR_Little_16;
    RD1 -= 8;
    if(RQ_Borrow) goto _ShiftR_Little_24;
    RD1 -= 8;
    RF_GetH8(RD0);
    goto _ShiftR_Little_8;

_ShiftR_Little_24:
    RF_GetH16(RD0);
    goto _ShiftR_Little_8;

_ShiftR_Little_16:
    RF_RotateR8(RD0);
    RD0_CLRBYTEH8;

_ShiftR_Little_8:
    RD1 += 8;
_ShiftR_Little_8_loop:
    if(RQ_Zero) goto _ShiftR_End;
    RF_ShiftR1(RD0);
    RD1 --;
    if(RQ_nZero) goto _ShiftR_Little_8_loop;

_ShiftR_End:
    Return_AutoField (0);



////////////////////////////////////////////////////////
//  ����:
//      _Rf_ShiftR_Signed
//  ����:
//      RD0����RD1�Σ��󲹷���λ
//  ����:
//      1.RD0�����ƶ�����
//      2.RD1��Ҫ�ƵĴ���
//  ����ֵ:
//      1.RD0: ��λ���
////////////////////////////////////////////////////////
Sub_AutoField _Rf_ShiftR_Signed;

    RD2 = 0;
    if(RD0_Bit31==0) goto _ShiftR_Signed_L1;
    RD2 = 1;                                      //������־

_ShiftR_Signed_L1:
    RD1 -= 8;
    if(RQ_Borrow) goto _ShiftR_Signed_Little_8;
    RD1 -= 8;
    if(RQ_Borrow) goto _ShiftR_Signed_Little_16;
    RD1 -= 8;
    if(RQ_Borrow) goto _ShiftR_Signed_Little_24;
    RD1 -= 8;
    RF_GetH8(RD0);
    RD2 += 0;
    if(RQ_Zero) goto _ShiftR_Signed_Little_8;
    RD0_SetByteH24;
    goto _ShiftR_Signed_Little_8;

_ShiftR_Signed_Little_24:
    RF_GetH16(RD0);
    RD2 += 0;
    if(RQ_Zero) goto _ShiftR_Signed_Little_8;
    RD0_SetByteH16;
    goto _ShiftR_Signed_Little_8;

_ShiftR_Signed_Little_16:
    RF_RotateR8(RD0);
    RD0_CLRBYTEH8;
    RD2 += 0;
    if(RQ_Zero) goto _ShiftR_Signed_Little_8;
    RD0_SetByteH8;
    goto _ShiftR_Signed_Little_8;

_ShiftR_Signed_Little_8:
    RD1 += 8;
    if(RQ_Zero) goto _ShiftR_Signed_End;

_ShiftR_Signed_Little_8_loop:
    RF_ShiftR1(RD0);
    RD2 += 0;
    if(RQ_Zero) goto _ShiftR_Signed_Little_8_loop_in;
    RD0_SetBit31;

_ShiftR_Signed_Little_8_loop_in:
    RD1 --;
    if(RQ_nZero) goto _ShiftR_Signed_Little_8_loop;

_ShiftR_Signed_End:
    Return_AutoField (0);


/////////////////////////////////////////////////////////////
//  ģ������: _Ru_Multi;
//  ģ�鹦��: �޷��ų˷�
//    ����[zh,zl]=x*y; x,y,zh,zl��Ϊ32���ص�����,zh,zl�ֱ�
//    Ϊ����ĸ߲�.�Ͳ�;
//  ģ�����:
//    RD0:����x;
//    RD1:����y;
//  ģ�����:
//    RD0:zl-�˻��Ͳ�;
//    RD1:zh-�˻��߲�;
//2012/3/20 11:23:40
////////////////////////////////////////////////////////////
Sub_AutoField _Ru_Multi;

    RD2 = 0;                    // Sum_L
    RD3 = 0;                    // Sum_H

    if(RD0==0) goto _Ru_Multi_Reg_End;  // ����x
    RA0 = RD1;                          // ����y
    if(RQ==0) goto _Ru_Multi_Reg_End;
    RD1 -= RD0;                         // ��y��x�󣬽���x��y
    if(RQ<=0) goto _Ru_Multi_Reg_L0;
    RD1 = RA0;
    RA0 = RD0;
    RD0 = RD1;

_Ru_Multi_Reg_L0:
    RD1 = 0;                    // RD1 = X_H=0

_Ru_Multi_Reg_L1:
    RA0 += 0;
    if(RQ_Bit0==0) goto _Ru_Multi_Reg_L2;
    RD2 += RD0;
    RD3 ^+= RD1;

_Ru_Multi_Reg_L2:
    RD0 += RD0;
    RD1 ^+= RD1;
    RF_ShiftR1(RA0);
    if(RQ!=0) goto _Ru_Multi_Reg_L1;

_Ru_Multi_Reg_End:
    RD0 = RD2;                  // Sum_L
    RD1 = RD3;                  // Sum_H

    Return_AutoField(0);



/////////////////////////////////////////////////////////////
//  ģ������: _Rs_Multi;
//  ģ�鹦��: �з��ų˷�
//    ����[zh,zl]=x*y; x,y,zh,zl��Ϊ32���ص�����,zh,zl�ֱ�
//    Ϊ����ĸ߲�.�Ͳ�;
//  ģ�����:
//    RD0:������x;
//    RD1:����y;
//  ģ�����:
//    RD0:zl-�˻��Ͳ�;
//    RD1:zh-�˻��߲�;
//2012/3/20 11:23:59
////////////////////////////////////////////////////////////
Sub_AutoField _Rs_Multi;
	Multi64_X = RD0;
	Multi64_Y = RD1;
	nop;nop;nop;
	RD0 = Multi64_XYL;
	RD1 = Multi64_XYH;
    Return_AutoField(0);



///////////////////////////////////////
//��������_Ru_Div
//���ܣ�������(�����㷨)
//��ڣ�
//    RD1:����
//    RD0:������
//���ڣ�
//    RD0:��
//    RD1:����
//2010-6-22 9:52:01
///////////////////////////////////////
Sub_AutoField _Ru_Div;

    //RD2:������
    //RD3:����
    //RA0:�������ƴ���

    RD3 = RD1;
    if(RQ_nZero) goto _Ru_Div_Reg_L0;       //�г����Ƿ�Ϊ��
    RF_Not(RD1);                            //��������Ϊȫf
    RD0 = RD1;
    goto _Ru_Div_Reg_End;

_Ru_Div_Reg_L0:
    if(RD0_nZero) goto _Ru_Div_Reg_L1;      //�б������Ƿ�Ϊ��
    RD1 = RD0;
    goto _Ru_Div_Reg_End;

_Ru_Div_Reg_L1:
    RD2 = RD0;
    RF_Log(RD1);
    RF_Log(RD0);
    RD0 -= RD1;                             //�������������λ��
    if(RD0>=0) goto _Ru_Div_Reg_L2;
    RD0 = 0;                                //������С�ڳ���
    RD1 = RD2;
    goto _Ru_Div_Reg_End;

_Ru_Div_Reg_L2:
    RA0 = 0;
    RD1 = 8;
_Ru_Div_Reg_L2A:
    RD0 -= RD1;
    if(RD0<0) goto _Ru_Div_Reg_L3;
    RA0 += RD1;
    RF_RotateL8(RD3);
    goto _Ru_Div_Reg_L2A;
_Ru_Div_Reg_L3:
    RD0 += RD1;
    if(RD0_Zero) goto _Ru_Div_Reg_L4;
_Ru_Div_Reg_L3A:
    RA0 += 1;
    RF_ShiftL1(RD3);
    RD0 --;
    if(RD0_nZero) goto _Ru_Div_Reg_L3A;
_Ru_Div_Reg_L4:
    RA0 += 1;
    RD0 = 0;                                //��
    RD1 = RD2;
_Ru_Div_Reg_L4A:
    RD1 -= RD3;
    if(RQ<0) goto _Ru_Div_Reg_L5;
    RD0 ++;
    goto _Ru_Div_Reg_L6;
_Ru_Div_Reg_L5:
    RD1 += RD3;
_Ru_Div_Reg_L6:
    RA0 -= 1;
    if(RQ_Zero) goto _Ru_Div_Reg_End;
    RF_RotateR1(RD3);
    RF_ShiftL1(RD0);
    goto _Ru_Div_Reg_L4A;

_Ru_Div_Reg_End:
    Return_AutoField(0);



///////////////////////////////////////
//��������_Ru_Mod
//���ܣ�������
//��ڣ�
//    RD1:����
//    RD0:������
//���ڣ�
//    RD0:����
//2010-6-22 15:25:39
///////////////////////////////////////
Sub _Ru_Mod;
    call _Ru_Div;
    RD0 = RD1;
    Return(0);



///////////////////////////////////////
//��������_Rs_Div
//���ܣ��з�������
//��ڣ�
//    RD1:����
//    RD0:������
//���ڣ�
//    RD0:��
//    RD1:����
//2009-4-22 17:57:40
///////////////////////////////////////
Sub_AutoField _Rs_Div;

    RD1 += 0;
    if(RQ_nZero) goto _Rs_Div_Reg_L0;       //����
    RF_Not(RD1);
    RD0 = RD1;
    goto _Rs_Div_Reg_End;

_Rs_Div_Reg_L0:
    RD2 = RD0;                              //������
    RD3 = RD0;
    if(RD0_Bit31==0) goto _Rs_Div_Reg_L1;   //�жϱ������ķ���
    RF_Neg(RD0);                            //����������

_Rs_Div_Reg_L1:
    RD2 ^= RD1;                             //RD2�����뱻������������ϵ
    RD1 += 0;
    if(RQ_Bit31==0) goto _Rs_Div_Reg_L2;    //�жϳ����ķ���
    RF_Neg(RD1);                            //����������

_Rs_Div_Reg_L2:
    call _Ru_Div;                       //���� RD0 ������ RD1 ����

    RD2 += 0;                               //�жϳ����뱻������������ϵ
    if(RQ_Bit31==0) goto _Rs_Div_Reg_L4;    //bit31!=0���  bit31==0ͬ��
    RF_Neg(RD0);                            //�ı��̵ķ���

_Rs_Div_Reg_L4:
    RD3 += 0;
    if(RQ_Bit31==0) goto _Rs_Div_Reg_End;   //bit31!=0���  bit31==0ͬ��
    RF_Neg(RD1);                            //�ı������ķ���

_Rs_Div_Reg_End:
    Return_AutoField(0);



///////////////////////////////////////
//��������_Rs_Mod
//���ܣ�������
//��ڣ�
//    RD1:����
//    RD0:������
//���ڣ�
//    RD0:����
//2010-6-22 15:37:24
///////////////////////////////////////
Sub _Rs_Mod;
    call _Rs_Div;
    RD0 = RD1;
    Return(0);



///////////////////////////////////////////////////////////////////
//  ģ������:
//      DIV_64;
//  ģ�鹦��:
//      ����32λ��������64λ������;
//  ģ�����:
//      RD0:    ������X��32λ.
//      RD1:    ������X��32λ.
//      RD4:    ����32λ. ���Ϊ0��60����.
//  ģ�����:
//      RD0:    �̸�32λ.
//      RD1:    �̵�32λ.
//      RD4:    ��������.
//  ģ��˵��:
//      ��������T = T0/Tc, ���������TcΪ0��60����.
//      ԭ���ĳ��ڣ�RD3:��������.
///////////////////////////////////////////////////////////////////
Sub_AutoField DIV_64;
    push RD5;
    push RD6;
    push RD7;
    push RD8;
    push RD9;

    // ������X
    RD8 = RD0;                                          // X.H32
    RD7 = RD1;                                          // X.L32

    // �������, ���Ϊ0��60����.
    RD0 = RD4;
    if(RD0_nZero) goto L_DIV_64_1;
    RD4 = 60;

    // Sum
L_DIV_64_1:
    RD2 = 0;                                           // sum.L32
    RD3 = 0;                                            // sum.H32
    // U = (Y << (63 - Y.MSBPOS))
    RD9 = 0;
    RD0 = RD4;
L_DIV_64_2:
    if(RD0_Bit31 == 1) goto L_DIV_64_3;
    RD0 <<;
    RD9 ++;
    goto L_DIV_64_2;
L_DIV_64_3:
    RD9 += 32;                                          // U = Tc<<RD9
    RD5 = 0;                                            // U.L32
    RD6 = RD0;                                          // U.H32

L_DIV_64_Loop:
    // �ж�X�Ƿ���ڵ���U
    RD0 = RD8;                                          // X.H32
    RD0 -= RD6;                                         // X.H32 -= U.H32
    if(RQ_Borrow) goto L_DIV_64_4;
    if(RD0_nZero) goto L_DIV_64_5;
    // x.H32 == u.H32, ��L32.
    RD0 = RD7;                                          // X.L32
    RD0 -= RD5;                                         // X.L32 -= U.L32
    if(RQ_Borrow) goto L_DIV_64_4;

    // X >= U
L_DIV_64_5:
    // X -= U
    RD0 = RD5;                                          // U.L32
    RD1 = RD6;                                          // U.H32
    RD7 -= RD0;                                         // X.L32 -= U.L32

    RF_Not(RD1);  RD8 ^+= RD1;//RD8 ^-= RD1;                                        // X.H32 ^-= U.H32

    // Sum ++
    RD2 ++;                                            // sum.L32
    goto L_DIV_64_Loop;

    // X < U
L_DIV_64_4:
    // U >>= 1
    RD5 >>;                                             // U.L32 >>= 1
    RD0 = RD6;                                          // U.H32
    if(RD0_Bit0 == 0) goto L_DIV_64_6;
    RD0 = RD5;
    RD0_SetBit31;
    RD5 = RD0;
L_DIV_64_6:
    RD6 >>;                                             // U.H32 >>= 1

    // sum <<= 1
    RD3 <<;                                             // sum.H32 <<= 1
    RD0 = RD2;                                         // sum.L32
    if(RD0_Bit31 == 0) goto L_DIV_64_7;
    RD3 ++;
L_DIV_64_7:
    RD2 <<;                                            // sum.L32 <<= 1
    RD9 --;
    if(RQ_nZero) goto L_DIV_64_Loop;

    // ��Ϊ����ʱ���У��.
    // ���X >= Y, ��sum ++, X -= Y.
    RD0 = RD7;                                          // X.L32
    RD0 -= RD4;
    if(RQ_Borrow) goto L_DIV_64_End;
    RD7 = RD0;                                          // X = X - Y
    RD2 ++;                                            // sum ++

L_DIV_64_End:
    // ���ؽ��:
    RD0 = RD7;
    RD4 = RD0;                                          // RD4��������
    RD1 = RD2;                                          // X.L32
    RD0 = RD3;                                          // X.H32

    // �ָ��ֳ�:
    pop RD9;
    pop RD8;
    pop RD7;
    pop RD6;
    pop RD5;
    Return_AutoField(0*MMU_BASE);


///////////////////////////////////////////////
//  ģ������:
//      HEXtoBCD
//  ģ�鹦��:
//      ʮ������Ȼ��ת����BCD����;
//  ģ�����:
//      RD0: N��
//      RD1: HEX;
//  ģ�����:
//      RD0: BCD;
///////////////////////////////////////////////
Sub_AutoField HEXtoBCD;
    push RD4;

    RA0 = RD0;
    RD3 = 0;
    RD2 = RD0;
Loop:
    RD0 = 0;
    // RD1 = HEX
    RD4 = 10;
    call DIV_64;                                        // [RD0,RD1,RD4]=DIV_64(RD0,RD1,RD4);
    RD0 = RD4;
    RF_RotateR4(RD0);
    RF_RotateR4(RD3);
    RD3 += RD0;
    RD2 --;
    if(RQ_nZero) goto Loop;

    RA0 -= 8;
    if(RQ_Zero) goto End;
    RF_RotateR8(RD3);

End:
    RD0 = RD3;
    pop RD4;
    Return_AutoField(0);


///////////////////////////////////////////////////////////////////
//  ģ������:
//      MFGetDwordNum_Hash;
//  ģ�鹦��:
//      ��ȡklen���س�����ϢM���ܿ���,�鳤32����;
//  ģ�����:
//      RD0: ��ϢM�ı��س���klen;
//  ģ�����:
//      RD0: ��ϢM���ܿ���;
///////////////////////////////////////////////////////////////////
Sub_AutoField MFGetDwordNum_Hash;
    RD2=RD0;                                            // RD2=klen
    RF_ShiftR2(RD0);
    RF_ShiftR2(RD0);
    RF_ShiftR1(RD0);
    RD1=0x1f;
    RD1&=RD2;
    if(RQ_Zero) goto L_MFGetDwordNum_Hash_1;
    RD0++;
L_MFGetDwordNum_Hash_1:
    Return_AutoField(0*MMU_BASE);

///////////////////////////////////////////////////////////////////
//  ģ������:
//      MFProcessTail_Hash;
//  ģ�鹦��:
//      ������ϢM��β��;
//  ģ�����:
//      RD0:    ��ϢM��ַ Addr_Msg;
//      RD1:    ��ϢM�ı��س���  Msg_BitLen;
//  ģ�����:
//      RD0:    ��Ϣβ���ַ;
//      RD1:    ��Ϣβλ��Ŀ(tail_bits);
///////////////////////////////////////////////////////////////////
Sub_AutoField MFProcessTail_Hash;
    RA0 = RD0;
    RD2 = RD1;
    RF_ShiftR2(RD2);
    RF_ShiftR2(RD2);
    RF_ShiftR1(RD2);                                    // RD2=��ϢM����DWORD��Ŀ
    RD0=0x1f;
    RD0&=RD1;
    if(RD0_Zero) goto MFProcessTail_Hash_Loop;
    // �ж���bits���:
    RD1=RD2;
    RF_ShiftL2(RD1);
    RA0+=RD1;                                           // RA0=β����ַ
    RD1 = 32;
    RD1 -= RD0;
    RF_Exp(RD1);
    RD1 --;
    RF_Not(RD1);
    M[RA0]&=RD1;
    RD1 = RD0;
    RD0 = RA0;
    goto MFProcessTail_Hash_End;

MFProcessTail_Hash_Loop:
    // ��DWORD���:
    RF_ShiftL2(RD2);
    RD0 = RA0;
    RD0 += RD2;
    RD1 = 0;

MFProcessTail_Hash_End:
    Return_AutoField(0*MMU_BASE);

////////////////////////////////////////////
//  ����:
//      MFROMtoRAM2_Hash:
//  ����:
//      ��ROM�е�2n�����ֺϲ�ΪRAM�е�n���֣�
//  ������
//      addr_rom: ROM������ַ;
//      num_rom:  ROM���ݶ��ֵĸ���(2n);
//      addr_ram: RAM����Ŀַ;
//  ����ֵ��
//      none;
////////////////////////////////////////////
Sub_AutoField MFROMtoRAM2_Hash;
    // 1. �����ֳ�:
    push RD0;
    push RD1;
    // ������ַ:
    // M[RSP+2*MMU_BASE]: addr_ram
    // M[RSP+3*MMU_BASE]: num_rom
    // M[RSP+4*MMU_BASE]: addr_rom
#define   addr_ram    M[RSP+2*MMU_BASE]
#define   num_rom     M[RSP+3*MMU_BASE]
#define   addr_rom    M[RSP+4*MMU_BASE]

    // 2. ��ʼ��:
    RD2=0xffff;                                         // const=0xffff
    RF_ShiftR1(num_rom);                                // 2n=>n
    RA0=addr_rom;                                       // src
    RA1=addr_ram;                                       // dest

    // 3. ��16λ��ROM�������ӳ�32λ��RAM����:
L_MFROMtoRAM2_Hash_1:
    RD0=M[RA0];
    RA0+=1*ROM_BASE;
    RD0&=RD2;                                           // RD0=low_16λ
    RD1=M[RA0];
    RA0+=1*ROM_BASE;
    RD1&=RD2;                                           // RD3=high_16λ
    RF_RotateL16(RD1);
    RD0^=RD1;
    M[RA1++]=RD0;
    num_rom--;
    if(RQ_nZero) goto L_MFROMtoRAM2_Hash_1;

    // 4. �ָ��ֳ�:
    pop RD1;
    pop RD0;
    Return_AutoField(3*MMU_BASE);


//////////////////////////////////////////////////////////////////////////
//  ����:
//      _Timer_Number_ms
//  ����:
//      �����������Ԥ��ֵ
//  ����:
//      1.ʱ��ֵ����λ��ms��
//      2.��ǰ��Ƶ����λ��KHz��
//  ����ֵ:
//      1.RD0: Ԥ��ֵ
//  ע��:
//      �ƻ� RD4\5\6\7
//////////////////////////////////////////////////////////////////////////
Sub _Timer_Number_ms;
    RD1 = M[RSP+1*MMU_BASE];    // ��ǰ��Ƶ
    RD0 = M[RSP+2*MMU_BASE];    // ʱ��ֵ
    call _Ru_Multi;
    send_para(RD0);
    call _Timer_Number;
    Return(2*MMU_BASE);



////////////////////////////////////
//��������_Duration_DIV
//���룺������RD0������RD1
//������� RD1 ;ģRD0;
////////////////////////////////////
Sub_AutoField _Duration_DIV;
    RD2 = 0;
L_Duration_DIV_Loop:
    RD0 -= RD1;
    if(RQ_Borrow) goto L_Duration_DIV_End;
    RD2 ++;
    goto L_Duration_DIV_Loop;
L_Duration_DIV_End:
    RD0 += RD1;
    RD1 = RD2;
    Return_AutoField(0);

END SEGMENT

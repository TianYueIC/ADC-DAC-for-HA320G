#define _CPU11_F_

#include <CPU11.def>

//====================================================================
//  ϵͳ��������(�������ʹ��RA6Ѱַ�ĳ����ڴ˶���)
//====================================================================
//DATA SEGMENT Const_RA6 = RN_Const_StartAddr;
//    DEFINEWORD
//    0x0000;
//END SEGMENT

CODE SEGMENT CPU09_F;

Sub _Goto_IPaddRD1;

Sub Guaiyi;
    M[RSP] += RD1;
    Return(0);

Sub GuaiyiA;
    RD1 --;
    M[RSP] = RD1;
    Return(0);


//===============================
//��������_Delay
//��  �ܣ���ʱ
//��  �ڣ�RD0:�ӳٵ�ָ��������
//��  �ڣ���
//2012/3/16 13:46:52
//===============================
Sub_AutoField _Delay;
    RD2 = RD0;
    goto L_Delay_RD2_Begin;

//===============================
//��������_Delay_RD2
//��  �ܣ���ʱ
//��  �ڣ�RD2:�ӳٵ�ָ��������
//��  �ڣ���
//˵����RD0 RD1�����ƻ������ƻ��κ��ֳ�
//===============================
Sub_AutoField _Delay_RD2;

L_Delay_RD2_Begin:
    RF_ShiftR2(RD2);
    RF_ShiftR1(RD2);
    if(RQ_Zero) goto L_Delay_RD2_End;

L_Delay_RD2_Loop:
    nop;nop;nop;nop;nop;
    RD2 --;
    if(RQ_nZero) goto L_Delay_RD2_Loop;

L_Delay_RD2_End:
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////////////////////////
////  ����:
////    _Verify_Sum_16_Reg:
////  ����:
////    �����ۼӺ�У���룻
////  ����:
////    RD0:Length�����ݳ��ȣ���Word��16bit��Ϊ��λ
////    RD1:����ָ����ַ
////  ����ֵ:
////    RD0: У����
////////////////////////////////////////////////////////////////////////////
//Sub_AutoField _Verify_Sum_16_Reg;
//
//    //Set_ConstInt_Dis;
//
//    RA0 = RD1;    //����ָ����ַ
//    RD2 = RD0;    //Length
//
//    RD3 = 0x12345678;
//    RD1 = RD3;
//Verify_Sum_16_Reg_L:
//    RD0 = M[RA0];
//    RD1 += RD0;
//    RA0 += 2;
//    RD3 += RD1;
//    RD2 --;
//    if(RQ_nZero) goto Verify_Sum_16_Reg_L;
//    RD0 = RD3;
//
//    //Set_ConstInt_En;
//
//    Return_AutoField(0*MMU_BASE);



//////////////////////////////////////////////////////////
////���ƣ�
////      _Aone_Hash_no_sbox_Reg
////���ܣ�
////      ָ�����ȼ���ɢ
////��ڣ�
////     RD0�����ȣ���λ��Dword����Сֵ1��
////     RA0��������ַ
////���ڣ�
////     RD0��32λHashֵ
//////////////////////////////////////////////////////////
//Sub_AutoField _Aone_Hash_no_sbox_Reg;
//    RD2 = RD0;                                          // ����
//    RD3 = 0x616f6e65;                                   // Hash��ֵ
//
//L_Aone_Hash_no_sbox_Reg_Loop:
//    RD0 = M[RA0++];
//    call _Aone_Hash_no_sbox_1Dword_Reg;
//    RD3 ^= RD0;
//    RD2 --;
//    if(RQ_nZero) goto L_Aone_Hash_no_sbox_Reg_Loop;
//
//    RD0 = RD3;
//    Return_AutoField(0*MMU_BASE);



/////////////////////////////////////////
////���ƣ�
////      _Aone_Hash_no_sbox_1Dword_Reg
////���ܣ�
////      ����ɢ
////��ڣ�
////      RD0
////���ڣ�
////      RD0
/////////////////////////////////////////
//Sub_AutoField _Aone_Hash_no_sbox_1Dword_Reg;
//
//    RD2 = 0xff;
//    RD2 += RD0;
//
//    RD3 = 4;
//L_Aone_Hash_no_sbox_1Dword_Reg_Loop:
//    RF_Disorder(RD2);
//    RD2 ^= RD0;
//    RF_Reverse(RD0);
//    RD0 += RD2;
//    RD3 --;
//    if(RQ_nZero) goto L_Aone_Hash_no_sbox_1Dword_Reg_Loop;
//
//    Return_AutoField(0*MMU_BASE);

/////////////////////////////////////////
////��������_Aone_Hash
////���ܣ�32λ����ɢ
////��ڣ�RD0
////���ڣ�
////    RD0
/////////////////////////////////////////
//Sub_AutoField _Aone_Hash;
//    AES_En;
//
//    AES_Port_Sbox = RD0;
//    RD0 = AES_RDSbox;
//    RD2 = RD0;
//    RF_Disorder(RD0);
//    RD0 ^= RD2;
//
//    AES_Port_Sbox = RD0;
//    RD0 = AES_RDSbox;
//    RD2 = RD0;
//    RF_Reverse(RD0);
//    RD0 += RD2;
//
//    AES_Dis;
//Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////////////////
////  ģ�����ƣ�
////    _Push_Field;
////  ģ�鹦��:
////    �����ֳ�:
////  ģ�����:
////    Null
////  ģ�����:
////    Null
////  ע�ͣ�  RSP ����9*MMU_BASE
///////////////////////////////////////////////////////////////////
//Sub_AutoField _Push_Field;
//    push RA0;
//    push RA1;
//    push RA2;
//    push RD2;
//    push RD3;
//    push RD4;
//    push RD5;
//    push RD6;
//    push RD7;
//    Return_AutoField(0);
//
////////////////////////////////////////////////////////////////////
////  ģ�����ƣ�
////    _Pop_Field;
////  ģ�鹦��:
////    �ָ��ֳ�;
////  ģ�����:
////    Null
////  ģ�����:
////    Null
///////////////////////////////////////////////////////////////////
//Sub _Pop_Field;
//
//    RD7 = M[RSP+1*MMU_BASE];
//    RD6 = M[RSP+2*MMU_BASE];
//    RD5 = M[RSP+3*MMU_BASE];
//    RD4 = M[RSP+4*MMU_BASE];
//    RD3 = M[RSP+5*MMU_BASE];
//    RD2 = M[RSP+6*MMU_BASE];
//    RA2 = M[RSP+7*MMU_BASE];
//    RA1 = M[RSP+8*MMU_BASE];
//    RA0 = M[RSP+9*MMU_BASE];
//
//    Return(9*MMU_BASE);



////////////////////////////////////////////////////////////////////////////
////  ����:
////    _Set_IntEn4DrvProg:
////  ����:
////    �������򿪷��ж����
////  ����:
////    ��
////  ����ֵ:
////    ��
////////////////////////////////////////////////////////////////////////////
//Sub _Set_IntEn4DrvProg;
//    Set_IntASM_En;
//    nop; nop; nop;
//    Set_IntASM_Dis;
//    Return(0*MMU_BASE);

//���ж�ģ��������С�FuncName��Ϊ��ǰ������
/*
    if(RFlag_NoInt) goto _FuncName_NoInt;
    call _Set_IntEn4DrvProg;
_FuncName_NoInt:
*/



//////////////////////////////////////////////////////////
////���ܣ�
////      ���������ڴ浥Ԫ
////��ڣ�
////      ���ȣ���λ��Dword
////      Դ��ַ
////      Ŀ���ַ
////���أ�
////      Ŀ���ַ
//////////////////////////////////////////////////////////
//Sub_AutoField _MemcpyDword;
//
//    RD1 = M[RSP+2*MMU_BASE];            // ����
//    if(RQ_Zero) goto _MemcpyDword_End;
//    RA1 = M[RSP+0*MMU_BASE];            // Ŀ���ַ
//    RA0 = M[RSP+1*MMU_BASE];            // Դ��ַ
//
//_MemcpyDword_Loop:
//    RD0 = M[RA0++];
//    M[RA1++] = RD0;
//    RD1 --;
//    if(RQ_nZero) goto _MemcpyDword_Loop;
//
//_MemcpyDword_End:
//    Return_AutoField(3*MMU_BASE);



//////////////////////////////////////////////////////////
////���ܣ�
////      ��WordΪ��λ�����������ڴ浥Ԫ
////��ڣ�
////      ���ȣ���λ��Word
////      Դ��ַ
////      Ŀ���ַ
////���أ�
////      Ŀ���ַ
//////////////////////////////////////////////////////////
//Sub_AutoField _MemcpyWord;
//
//    RD1 = M[RSP+2*MMU_BASE];            // ����
//    if(RQ_Zero) goto _MemcpyWord_End;
//    RA1 = M[RSP+0*MMU_BASE];            // Ŀ���ַ
//    RA0 = M[RSP+1*MMU_BASE];            // Դ��ַ
//
//_MemcpyWord_Loop:
//    uWord_RD0 = M[RA0];
//    M[RA1] = uWord_RD0;
//    RA0 += 2;
//    RA1 += 2;
//    RD1 --;
//    if(RQ_nZero) goto _MemcpyWord_Loop;
//
//_MemcpyWord_End:
//    Return_AutoField(3*MMU_BASE);


//////////////////////////////////////////////////////////
////���ƣ�
////      _MemcmpDword
////���ܣ�
////      �����Ƚ��ڴ浥Ԫ
////��ڣ�
////      ���ȣ���λ��Dword
////      ��ַ1
////      ��ַ2
////���أ�
////      Ŀ���ַ
//////////////////////////////////////////////////////////
//Sub_AutoField _MemcmpDword;
//
//    RD1 = M[RSP+2*MMU_BASE];            // ����
//    if(RQ_Zero) goto _MemcmpDword_End;
//
//    RA1 = M[RSP+0*MMU_BASE];            // ��ַ2
//    RA0 = M[RSP+1*MMU_BASE];            // ��ַ1
//
//_MemcmpDword_Loop:
//    RD0 = M[RA0++];
//    RD0 ^= M[RA1++];
//    if(RD0_nZero) goto _MemcmpDword_End;
//    RD1 --;
//    if(RQ_nZero) goto _MemcmpDword_Loop;
//
//_MemcmpDword_End:
//    Return_AutoField(3*MMU_BASE);




//////////////////////////////////////////////////////////////////////////
//  ����:
//      _Timer_Number
//  ����:
//      �����������Ԥ��ֵ��
//  ����:
//      1.��Ƶ����ָ��Ƶ�ʵķ�Ƶ��
//  ����ֵ:
//      RD0: Ԥ��ֵ
//  ע��:
//      �ƻ� RD4\5\6\7
//2009-4-24 14:07:03
//////////////////////////////////////////////////////////////////////////
Sub_AutoField _Timer_Number;
    push RD8;
    push RD9;
    push RD10;
    push RD11;

    //RD4:�˷���λ
    //RD5:����Y
    //RD6:һ�γ˷�ѭ������
    //RD7:��������ֵ
    //RD8:ģ��
    //RD9:����������
    //RD10:�ݳ���
    //RD11:��������

    //�������Ӳ���ṹ�йص�ֱ�Ӹ�ֵ
    //ģ������ԭ����ʽG(x) = x**31 + x**3 + 1;��x**3���𣬼�Ϊ0x90000001��
    //������ʱ��������
    RD8 = 0x90000001;
    RD4 = 0x80000000;             //�˷���λ��ģ�������λ
    RD9 = 31;                     //����������
    RD7 = 0x7fffffff;             //��������ֵΪȫ1

//�����������Ƶ���λ
    RD0 = M[RSP+4*MMU_BASE];
    RD11 = RD0;
    RF_Log(RD0);
    RD0 ++;
    RD10 = RD0;                     //�ݳ���

    RD0 = RD11;
_Counter_Convert_L0:
    RD0 += RD0;
    if(RQ_nCarry) goto _Counter_Convert_L0;
    RD11 = RD0;

    //����ó�ֵ=2
    RD2 = 0x02;
_Counter_Convert_L3:
    RD10 --;
    if(RQ_Zero) goto _Counter_Convert_L5;
    RD1 = RD2;
    RD5 = RD1;
    RD2 = 0;
    RD3 = 1;
    RD0 = RD9;
    RD6 = RD0;

_Counter_Convert_L3A:
    //����ƽ��
    //RD1:����X   RD5:����Y   RD2:��   RD3:ɨ��λ
    RD0 = RD3;
    RD0 &= RD5;
    if(RD0_Zero) goto _Counter_Convert_L4;
    RD2 ^= RD1;
_Counter_Convert_L4:
    RD6 --;
    if(RQ_Zero) goto _Counter_Convert_L3B;
    RD3 <<;
    RD1 <<;
    RD0 = RD1;
    RD0 &= RD4;
    if(RD0_Zero) goto _Counter_Convert_L3A;
    RD1 ^= RD8;
    goto _Counter_Convert_L3A;

_Counter_Convert_L3B:
    //����������
    RD0 = RD11;
    RD11 += RD0;
    if(RQ_nCarry) goto _Counter_Convert_L3;
    //���������Ƴ�Ϊ1�������2
    RD2 <<;
    RD0 = RD2;
    RD0 &= RD4;
    if(RD0_Zero) goto _Counter_Convert_L3;
    RD1 = RD8;
    RD2 ^= RD1;
    goto _Counter_Convert_L3;

_Counter_Convert_L5:
    //�����ֵ��RD2
    //RD1:����X   RD5:����Y   RD2:��   RD3:ɨ��λ
    RD1 = RD2;
    RD5 = RD1;
    RD1 = RD7;
    RD2 = 0;
    RD3 = 1;
    RD0 = RD9;
    RD6 = RD0;
_Counter_Convert_L5A:
    RD0 = RD3;
    RD0 &= RD5;
    if(RD0_Zero) goto _Counter_Convert_L5B;
    RD2 ^= RD1;
_Counter_Convert_L5B:
    RD6 --;
    if(RQ_Zero) goto _Counter_Convert_L6;
    RD3 <<;
    RD1 <<;
    RD0 = RD1;
    RD0 &= RD4;
    if(RD0_Zero) goto _Counter_Convert_L5A;
    RD1 ^= RD8;
    goto _Counter_Convert_L5A;

    //�������Ӳ���ṹ�йص�ֱ�Ӹ�ֵ
_Counter_Convert_L6:
    RF_RotateL4(RD2);
    RF_RotateR1(RD2);
    RD1 = RD2;
    RF_RotateL1(RD1);
    RD0 = 7;
    RD1 &= RD0;

    RD0 = 0x7ffffff8;
    RD0 &= RD2;
    RD0 += RD1;      //���
    RF_Not(RD0);

    pop RD11;
    pop RD10;
    pop RD9;
    pop RD8;
    Return_AutoField(1*MMU_BASE);



/////////////////////////////////////////////////////////
////  ����:
////      _Debug_Memory_File:
////  ����:
////      ���ļ��м�¼Memory�����ݣ�
////  ����:
////      1.ID�ţ�Debugʶ��
////      2.�洢����ַ
////      3.�洢������(DWordΪ��λ)
////  ����ֵ:
////      ��
/////////////////////////////////////////////////////////
//Sub _Debug_Memory_File;
//    push RD0;
//    push RD1;
//    push RA0;
//    //M[RSP+4*MMU_BASE]:�洢������
//    //M[RSP+5*MMU_BASE]:�洢����ַ
//    //M[RSP+6*MMU_BASE]:ID��
//
//    RD1 = M[RSP+4*MMU_BASE];
//    RA0 = M[RSP+5*MMU_BASE];
//    
//    Debug_Start;
//    nop;
//    RD0 = M[RSP+6*MMU_BASE];    //Read Flag
//_Debug_Multi_L0:
//    RD0 = M[RA0++];             //Read Data
//
//
//    RD1 --;
//    if(RQ_nZero) goto _Debug_Multi_L0;
//    Debug_End;
//    
//    pop RA0;
//    pop RD1;
//    pop RD0;
//    Return(3*MMU_BASE);



/////////////////////////////////////////////////////////
////  ����:
////      _Debug_Memory_File:
////  ����:
////      ���ļ��м�¼Memory�����ݣ�
////  ����:
////      1.ID�ţ�Debugʶ��
////      2.�洢����ַ
////      3.�洢������(DWordΪ��λ)
////  ����ֵ:
////      ��
/////////////////////////////////////////////////////////
//Sub _Debug_Memory_File_Bank;
//    push RD0;
//    push RD1;
//    push RA0;
//    //M[RSP+4*MMU_BASE]:�洢������
//    //M[RSP+5*MMU_BASE]:�洢����ַ
//    //M[RSP+6*MMU_BASE]:ID��
//
//    RD1 = M[RSP+4*MMU_BASE];
//    RA0 = M[RSP+5*MMU_BASE];
//    RD0 = M[RSP+6*MMU_BASE];    //Read Flag
//    
//    if(RD0_Zero) goto L_Debug_Memory_File_Bank_0;
//    RD0 --;
//    if(RD0_Zero) goto L_Debug_Memory_File_Bank_1;
//    RD0 --;
//    if(RD0_Zero) goto L_Debug_Memory_File_Bank_2;
//    RD0 --;
//    if(RD0_Zero) goto L_Debug_Memory_File_Bank_3;
//    RD0 --;
//    if(RD0_Zero) goto L_Debug_Memory_File_Bank_4;
//    RD0 --;
//    if(RD0_Zero) goto L_Debug_Memory_File_Bank_5;
//    RD0 --;
//    if(RD0_Zero) goto L_Debug_Memory_File_Bank_6;
//    RD0 --;
//    if(RD0_Zero) goto L_Debug_Memory_File_Bank_7;
//    
//L_Debug_Memory_File_Bank_0:
//	Set_LevelL0;
//	goto L_Debug_Memory_File_Bank_Start;
//L_Debug_Memory_File_Bank_1:    
//	Set_LevelL1;
//	goto L_Debug_Memory_File_Bank_Start;
//L_Debug_Memory_File_Bank_2:  
//	Set_LevelL2;
//	goto L_Debug_Memory_File_Bank_Start;  
//L_Debug_Memory_File_Bank_3:    
//	Set_LevelL3;
//	goto L_Debug_Memory_File_Bank_Start;
//L_Debug_Memory_File_Bank_4:    
//	Set_LevelL4;
//	goto L_Debug_Memory_File_Bank_Start;
//L_Debug_Memory_File_Bank_5:    
//	Set_LevelL5;
//	goto L_Debug_Memory_File_Bank_Start;
//L_Debug_Memory_File_Bank_6:    
//	Set_LevelL6;
//	goto L_Debug_Memory_File_Bank_Start;
//L_Debug_Memory_File_Bank_7:
//	Set_LevelL7;
//
//L_Debug_Memory_File_Bank_Start:
//	
//L_Debug_Memory_File_Bank_L0:
//    RD0 = M[RA0++];             //Read Data
//    RD1 --;
//    if(RQ_nZero) goto L_Debug_Memory_File_Bank_L0;
//
//    Set_LevelH0;
//    Set_LevelH1;
//    Set_LevelH2;
//    Set_LevelH3;
//    Set_LevelH4;
//    Set_LevelH5;
//    Set_LevelH6;    
//	Set_LevelH7;
//    
//    pop RA0;
//    pop RD1;
//    pop RD0;
//    Return(3*MMU_BASE);
    


/////////////////////////////////////////////////////////
////  ����:
////      _Debug_Memory_File_DWAddr:
////  ����:
////      ���ļ��м�¼Memory�����ݣ�
////      �洢����ַ��Ӳ���ӷ�ΪDword����:RA0+=1��ʾ��ַ����һ��Dword��
////  ����:
////      1.ID�ţ�Debugʶ��
////      2.�洢����ַ(��ַΪDword��ַ)
////      3.�洢������(DWordΪ��λ)
////  ����ֵ:
////      ��
/////////////////////////////////////////////////////////
//Sub _Debug_Memory_File_DWAddr;
//    push RD0;
//    push RD1;
//    push RA0;
//    //M[RSP+4*MMU_BASE]:�洢������
//    //M[RSP+5*MMU_BASE]:�洢����ַ
//    //M[RSP+6*MMU_BASE]:ID��
//
//    RD1 = M[RSP+4*MMU_BASE];
//    RA0 = M[RSP+5*MMU_BASE];
//    
//    Debug_Start;
//    nop;
//    RD0 = M[RSP+6*MMU_BASE];    //Read Flag
//_Debug_Memory_File_DWAddr_L0:
//    RD0 = M[RA0];             //Read Data
//    RA0 += 1;
//    RD1 --;
//    if(RQ_nZero) goto _Debug_Memory_File_DWAddr_L0;
//    Debug_End;
//    
//    pop RA0;
//    pop RD1;
//    pop RD0;
//    Return(3*MMU_BASE);
//

//////////////////////////////////////////////////////////////////////////
//  ��������:
//    _Verify_Sum_16_Reg:
//  ��������:
//    �����ۼӺ�У���룻
//  �������:
//    RD0:Length�����ݳ��ȣ���Word��16bit��Ϊ��λ
//    RD1:����ָ����ַ
//  ��������:
//    RD0: У����
//////////////////////////////////////////////////////////////////////////


END SEGMENT

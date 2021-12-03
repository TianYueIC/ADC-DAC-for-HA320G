#define _MEMORY_F_

#include <CPU11.def>
#include <Memory.def>

CODE SEGMENT Memory_F;

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
//////////////      XL����            //////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////

//�Ĵ������η�ʽ,���÷�ʽ��ʾ��
////////////////////////////
//_Mem_Clear_Reg
//����:Memory ָ��������0
//���÷�ʽ:��ʾ��
//�ƻ� RD0
//���:����,�׵�ַ
//ʹ��ʾ��
/*
    Set_LoopNum = 32;                                   // ������������
    Maddr_WriteAuto = RA0;                              // ���������׵�ַ,�Ⱥ��ұ߿���Ϊ����Ѱַ��ʽ;
    call _Mem_Clear_Reg;                                // 0 => dest; �ƻ�RD0; destΪָ��ģ��;[]=_Mem_Clear_Reg(Set_LoopNum,Maddr_WriteAuto);in:Set_LoopNum,Maddr_WriteAuto; out:none;
*/
////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_Clear_Reg;
    RD0 = 0;
_Mem_Clear_Reg_Loop:
    Mx = RD0;
    goto _Mem_Clear_Reg_Loop;



////////////////////////////
//_Mem_Copy_Reg
//����:Memory ��Դ������Ŀ��
//���÷�ʽ:��ʾ��
//�ƻ� RD0
//���:����,Դ��ַ,Ŀ���ַ
// ʹ��ʾ��
/*
    Set_LoopNum = 32;                                   // ������������
    Set_AutoMemAlt;                                     // ������
    Maddr_ReadAuto = RA0++;                             // ��������Դ��ַ
    Maddr_WriteAuto = RA0;                              // ��������Ŀ���ַ
    call _Mem_Copy_Reg;                                 // src => dest; �ƻ�RD0; dest,srcΪָ��ģ��;[]=_Mem_Copy_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
//////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_Copy_Reg;
_Mem_Copy_Reg_Loop:
    RD0 = Mx;
    Mx = RD0;
    goto _Mem_Copy_Reg_Loop;



/////////////////////////////
//_Mem_Add_AB_Reg
//����:Memory ��Դ����Ŀ��
//���÷�ʽ:��ʾ��
//�ƻ� RD0
//���:����,Դ��ַ,Ŀ���ַ
//ʹ��ʾ��
/*
    Set_LoopNum = 32;                                   // ������������
    Set_AutoMemAlt;                                     // ������
    Maddr_ReadAuto = RA0;                               // ��������Դ��ַ
    Maddr_WriteAuto = RA1;                              // ��������Ŀ���ַ
    call _Mem_Add_AB_Reg;                               // dest+=src,�ƻ�RD0;src,destΪָ��ģ��;[]=_Mem_Add_AB_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_Add_AB_Reg;
    RD0 = 0;
    RD0 += RD0;
_Mem_Add_AB_Reg_Loop:
    RD0 = Mx;
    Mxx ^+= RD0;
    goto _Mem_Add_AB_Reg_Loop;

/////////////////////////////
//_Mem_Aequ2B_Reg
//����:Memory ��Դ����Ŀ��
//���÷�ʽ:��ʾ��
//�ƻ� RD0
//���:����,Դ��ַ,Ŀ���ַ
//ʹ��ʾ��
/*
    Set_LoopNum = 32;                                   // ������������
    Set_AutoMemAlt;                                     // ������
    Maddr_ReadAuto = RA0;                               // ��������Դ��ַ
    Maddr_WriteAuto = RA1;                              // ��������Ŀ���ַ
    call _Mem_Add_AB_Reg;                               // dest+=src,�ƻ�RD0;src,destΪָ��ģ��;[]=_Mem_Add_AB_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_Aequ2B_Reg;
    RD0 = 0;
    RD0 += RD0;
_Mem_Aequ2B_Reg_Loop:
    RD0 = Mx;
    RD0 ^+= RD0;
    Mx = RD0;
    goto _Mem_Aequ2B_Reg_Loop;


/////////////////////////////
//_Mem_Sub_AB_Reg
//����:Memory Ŀ���Դ��Ŀ��
//���÷�ʽ:��ʾ��
//�ƻ� RD0
//���:����,Դ��ַ,Ŀ���ַ
//ʹ��ʾ��
/*
    Set_LoopNum = 32;                                   // ������������
    Set_AutoMemAlt;                                     // ������
    Maddr_ReadAuto = RA0;                               // ��������Դ��ַ
    Maddr_WriteAuto = RA1;                              // ��������Ŀ���ַ
    call _Mem_Sub_AB_Reg;                               // dest-=src,�ƻ�RD0;src,destΪָ��ģ��;[]=_Mem_Sub_AB_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_Sub_AB_Reg;
    RD0 = Mx;
    RF_Neg(RD0);
    Mxx += RD0;
    nop;
_Mem_Sub_AB_Loop:
    RD0 = Mx;
    RF_Not(RD0);
    Mxx ^+= RD0;
    goto _Mem_Sub_AB_Loop;


//=======================================
//������ A (+/-) n*B ����,�Ĵ������η�ʽ
//=======================================

/////////////////////////////////////////
//_Mem_Sub_A2B_Reg
//���ܣ�Memory  A -= 2B;
//���÷�ʽ��call _Mem_Sub_A2B_Reg; ��ʾ��
//�ƻ���RD0
//��ڣ�����.Դ��ַ(B).Ŀ����ַ(A)
//ʹ��ʾ��
/*
    Set_LoopNum = 32;                                   // ������������
    Set_AutoMemAlt;                                     // ������
    Maddr_ReadAuto = RA0;                               // ��������Դ��ַ
    Maddr_WriteAuto = RA1;                              // ��������Ŀ���ַ
    call _Mem_Sub_A2B_Reg;                               // dest-=2src,�ƻ�RD0;src,destΪָ��ģ��;[]=_Mem_Sub_A2B_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_Sub_A2B_Reg;
    RD1 = 0;
    RD2 = 0;
    RD3 = 0;
_Mem_Sub_A2B_Loop:
    RD0 = Mx;
    RD2 = RD0;
    RD0 += RD3;
    RD3 = 0;
    RD3 ^+= RD1;
    RD0  += RD2;
    RD3 ^+= RD1;
    Mxx -= RD0;
    if(RQ_nBorrow) goto _Mem_Sub_A2B_Loop;
    RD3 += 1;
    goto _Mem_Sub_A2B_Loop;


/////////////////////////////////////////
//_Mem_Sub_A3B_Reg
//���ܣ�Memory  A -= 3B;
//���÷�ʽ��call _Mem_Sub_A3B_Reg; ��ʾ��
//�ƻ���RD0.RD1
//��ڣ�����.Դ��ַ(B).Ŀ����ַ(A)
//ʹ��ʾ��
/*
    Set_LoopNum = 32;                                   // ������������
    Set_AutoMemAlt;                                     // ������
    Maddr_ReadAuto = RA0;                               // ��������Դ��ַ
    Maddr_WriteAuto = RA1;                              // ��������Ŀ���ַ
    call _Mem_Sub_A3B_Reg;                              // dest-=3src,�ƻ�RD0,RD1;src,destΪָ��ģ��;[]=_Mem_Sub_A3B_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_Sub_A3B_Reg;
    RD1 = 0;
    RD2 = 0;
    RD3 = 0;
_Mem_Sub_A3B_Loop:
    RD0 = Mx;
    RD2 = RD0;        //���ϴ�ѭ��CarryOut
    RD0 += RD3;
    RD3 = 0;
    RD3 ^+= RD1;
    RD0  += RD2;
    RD3 ^+= RD1;
    RD0  += RD2;        //3*B
    RD3 ^+= RD1;
    Mxx -= RD0;
    if(RQ_nBorrow) goto _Mem_Sub_A3B_Loop;
    RD3 += 1;
    goto _Mem_Sub_A3B_Loop;

/////////////////////////////////////////
//_Mem_Sub_A4B
//���ܣ�Memory  A -= 4B;
//���÷�ʽ��call _Mem_Sub_A4B_Reg; ��ʾ��
//�ƻ���RD0.RD1
//��ڣ�RA0��Դ��ַ(B).
//      RA1��Ŀ����ַ(A)
//���÷�ʽ��
/////////////////////////////////////////
Sub _Mem_Sub_A4B;
    Set_AutoMemAlt;                                     // ������
    Maddr_ReadAuto = RA0;                               // ��������Դ��ַ
    Maddr_WriteAuto = RA1;    
    call _Mem_Sub_A2B_Reg;
    Set_AutoMemAlt;                                     // ������
    Maddr_ReadAuto = RA0;                               // ��������Դ��ַ
    Maddr_WriteAuto = RA1;    
    call _Mem_Sub_A2B_Reg;    
Return(0*MMU_BASE);



/////////////////////////////////////////
//_Mem_Sub_A5B
//���ܣ�Memory  A -= 5B;
//���÷�ʽ��call _Mem_Sub_A5B; ��ʾ��
//�ƻ���RD0.RD1
//��ڣ�RA0��Դ��ַ(B).
//      RA1��Ŀ����ַ(A)
//���÷�ʽ��
/////////////////////////////////////////
Sub _Mem_Sub_A5B;
    Set_AutoMemAlt;                                     // ������
    Maddr_ReadAuto = RA0;                               // ��������Դ��ַ
    Maddr_WriteAuto = RA1;
    call _Mem_Sub_A3B_Reg;
    Set_AutoMemAlt;                                     // ������
    Maddr_ReadAuto = RA0;                               // ��������Դ��ַ
    Maddr_WriteAuto = RA1;    
    call _Mem_Sub_A2B_Reg;    
Return(0*MMU_BASE);


/////////////////////////////////////////
//_Mem_Sub_A6B
//���ܣ�Memory  A -= 6B;
//���÷�ʽ��call _Mem_Sub_A6B; ��ʾ��
//�ƻ���RD0.RD1
//��ڣ�RA0��Դ��ַ(B).
//      RA1��Ŀ����ַ(A)
//      ������ǰ��Set_LoopNum�˿�д��
//ʾ����Set_LoopNum = 32;
//      call _Mem_Sub_A6B;
/////////////////////////////////////////
Sub _Mem_Sub_A6B;
    Set_AutoMemAlt;                                     // ������
    Maddr_ReadAuto = RA0;                               // ��������Դ��ַ
    Maddr_WriteAuto = RA1;    
    call _Mem_Sub_A3B_Reg;
    Set_AutoMemAlt;                                     // ������
    Maddr_ReadAuto = RA0;                               // ��������Դ��ַ
    Maddr_WriteAuto = RA1;    
    call _Mem_Sub_A3B_Reg;    
Return(0*MMU_BASE);


/////////////////////////////////////////
//_Mem_Sub_A7B
//���ܣ�Memory  A -= 7B;
//���÷�ʽ��call _Mem_Sub_A7B; ��ʾ��
//�ƻ���RD0.RD1
//��ڣ�RA0��Դ��ַ(B).
//      RA1��Ŀ����ַ(A)
//      ������ǰ��Set_LoopNum�˿�д��
//ʾ����Set_LoopNum = 32;
//      call _Mem_Sub_A6B;
/////////////////////////////////////////
Sub _Mem_Sub_A7B;
    Set_AutoMemAlt;                                     // ������
    Maddr_ReadAuto = RA0;                               // ��������Դ��ַ
    Maddr_WriteAuto = RA1;    
    call _Mem_Sub_A3B_Reg;
    Set_AutoMemAlt;                                     // ������
    Maddr_ReadAuto = RA0;                               // ��������Դ��ַ
    Maddr_WriteAuto = RA1;    
    call _Mem_Sub_A2B_Reg; 
    Set_AutoMemAlt;                                     // ������
    Maddr_ReadAuto = RA0;                               // ��������Դ��ַ
    Maddr_WriteAuto = RA1;    
    call _Mem_Sub_A2B_Reg;    
Return(0*MMU_BASE);



//=======================================
//������ Shift ����,�Ĵ������η�ʽ
//=======================================

/////////////////////////////////////////
//_Mem_ShiftL1_Reg
//���ܣ�Memoryָ����������1λ
//���÷�ʽ��call _Mem_ShiftL1_Reg;��ʾ��
//�ƻ���RD0.RD1
//��ڣ�����.Դ��ַ.Ŀ����ַ��Դ��Ŀ�꣩
/////////////////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_ShiftL1_Reg;
    RD1 = 0;
    RD3 = 1;
_Mem_ShiftL1_Loop:
    RD0 = Mx;
    RD2 = RD0;
    RF_ShiftL1(RD0);
    RD0 += RD1;
    Mx = RD0;
    RD1 = RD2;
    RF_RotateL1(RD1);
    RD1 &= RD3;
    goto _Mem_ShiftL1_Loop;

/////////////////////////////////////////
//_Mem_ShiftL2_Reg
//���ܣ�Memoryָ����������2λ
//���÷�ʽ��call _Mem_ShiftL2_Reg; ��ʾ��
//�ƻ���RD0.RD1
//��ڣ�����.Դ��ַ.Ŀ���ַ��Դ��Ŀ�꣩
//ʹ��ʾ��
/*
    Set_LoopNum = 32;                                   // ������������
    Set_AutoMemAlt;                                     // ������
    Maddr_ReadAuto = RA0;                               // ��������Դ��ַ
    Maddr_WriteAuto = RA0;                              // ��������Ŀ���ַ
    call _Mem_ShiftL2_Reg;                              // dest=src<<2,�ƻ�RD0,RD1;src,destΪָ��ģ��;[]=_Mem_ShiftL2_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_ShiftL2_Reg;
    RD1 = 0;
    RD3 = 3;
_Mem_ShiftL2_Loop:
    RD0 = Mx;
    RD2 = RD0;
    RF_ShiftL2(RD0);
    RD0 += RD1;
    Mx = RD0;
    RD1 = RD2;
    RF_RotateL2(RD1);
    RD1 &= RD3;
    goto _Mem_ShiftL2_Loop;


/////////////////////////////////////////
//_Mem_ShiftL3_Reg
//���ܣ�Memoryָ����������3λ
//���÷�ʽ��call _Mem_ShiftL3_Reg; ��ʾ��
//�ƻ���RD0.RD1
//��ڣ�����.Դ��ַ.Ŀ���ַ��Դ��Ŀ�꣩
//ʹ��ʾ��
/*
    Set_LoopNum = 32;                                   // ������������
    Set_AutoMemAlt;                                     // ������
    Maddr_ReadAuto = RA0;                               // ��������Դ��ַ
    Maddr_WriteAuto = RA0;                              // ��������Ŀ���ַ
    call _Mem_ShiftL3_Reg;                              // dest=src<<3,�ƻ�RD0,RD1;src,destΪָ��ģ��;[]=_Mem_ShiftL3_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_ShiftL3_Reg;
    RD1 = 0;
    RD3 = 7;
_Mem_ShiftL3_Loop:
    RD0 = Mx;
    RD2 = RD0;
    RF_ShiftL2(RD0);
    RF_ShiftL1(RD0);
    RD0 += RD1;
    Mx = RD0;
    RD1 = RD2;
    RF_RotateL2(RD1);
    RF_RotateL1(RD1);
    RD1 &= RD3;
    goto _Mem_ShiftL3_Loop;


/////////////////////////////////////////
//_Mem_ShiftL4_Reg
//���ܣ�Memoryָ����������4λ
//���÷�ʽ��call _Mem_ShiftL4_Reg; ��ʾ��
//�ƻ���RD0.RD1
//��ڣ�����.Դ��ַ.Ŀ���ַ��Դ��Ŀ�꣩
//ʹ��ʾ��
/*
    Set_LoopNum = 32;                                   // ������������
    Set_AutoMemAlt;                                     // ������
    Maddr_ReadAuto = RA0;                               // ��������Դ��ַ
    Maddr_WriteAuto = RA0;                              // ��������Ŀ���ַ
    call _Mem_ShiftL4_Reg;                              // dest=src<<4,�ƻ�RD0,RD1;src,destΪָ��ģ��;[]=_Mem_ShiftL4_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_ShiftL4_Reg;
    RD1 = 0;
    RD3 = 0xf;
_Mem_ShiftL4_Loop:
    RD0 = Mx;
    RD2 = RD0;
    RF_ShiftL2(RD0);
    RF_ShiftL2(RD0);
    RD0 += RD1;
    Mx = RD0;
    RD1 = RD2;
    RF_RotateL4(RD1);
    RD1 &= RD3;
    goto _Mem_ShiftL4_Loop;


/////////////////////////////////////////
//_Mem_ShiftL8_Reg
//���ܣ�Memoryָ����������8λ
//���÷�ʽ��call _Mem_ShiftL8_Reg; ��ʾ��
//�ƻ���RD0.RD1
//��ڣ�����.Դ��ַ.Ŀ���ַ��Դ��Ŀ�꣩
//ʹ��ʾ��
/*
    Set_LoopNum = 32;                                   // ������������
    Set_AutoMemAlt;                                     // ������
    Maddr_ReadAuto = RA0;                               // ��������Դ��ַ
    Maddr_WriteAuto = RA0;                              // ��������Ŀ���ַ
    call _Mem_ShiftL8_Reg;                              // dest=src<<8,�ƻ�RD0,RD1;src,destΪָ��ģ��;[]=_Mem_ShiftL8_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_ShiftL8_Reg;
    RD1 = 0;
    RD3 = 0xff;
_Mem_ShiftL8_Loop:
    RD0 = Mx;
    RD2 = RD0;
    RF_RotateL8(RD0);
    RD0_ClrByteL8;
    RD0 += RD1;
    Mx = RD0;
    RD1 = RD2;
    RF_RotateL8(RD1);
    RD1 &= RD3;
    goto _Mem_ShiftL8_Loop;


/////////////////////////////////////////
//_Mem_ShiftL16_Reg
//���ܣ�Memoryָ����������16λ
//���÷�ʽ��call _Mem_ShiftL8_Reg; ��ʾ��
//�ƻ���RD0.RD1
//��ڣ�����.Դ��ַ.Ŀ���ַ��Դ��Ŀ�꣩
//ʹ��ʾ��
/*
    Set_LoopNum = 32;                                   // ������������
    Set_AutoMemAlt;                                     // ������
    Maddr_ReadAuto = RA0;                               // ��������Դ��ַ
    Maddr_WriteAuto = RA0;                              // ��������Ŀ���ַ
    call _Mem_ShiftL16_Reg;                             // dest=src<<16,�ƻ�RD0,RD1;src,destΪָ��ģ��;[]=_Mem_ShiftL16_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_ShiftL16_Reg;
    RD1 = 0;
    RD3 = 0xffff;
_Mem_ShiftL16_Loop:
    RD0 = Mx;
    RD2 = RD0;
    RF_RotateL16(RD0);
    RD0_ClrByteL16;
    RD0 += RD1;
    Mx = RD0;
    RD1 = RD2;
    RF_RotateL16(RD1);
    RD1 &= RD3;
    goto _Mem_ShiftL16_Loop;

/////////////////////////////////////////
//_Mem_ShiftR1_Reg
//���ܣ�Memoryָ����������1λ
//���÷�ʽ��call _Mem_ShiftR1_Reg;
//         ��ʾ��  _Mem_ShiftL1_Reg��ͬ
//�ƻ���RD0.RD1
//��ڣ�����.Դ��ַ.Ŀ����ַ��Դ��Ŀ��+MMU_BASE��
//ע��: ����MAX=M_OperModLen-1,M[M_OperModLen]=>M[M_OperModLen-1]
//ʹ��ʾ��
/*
    Set_LoopNum = 32;                                   // ������������,����MAX=M_OperModLen-1,M[M_OperModLen]=>M[M_OperModLen-1]
    Set_AutoMemAlt;                                     // ������
    Maddr_ReadAuto = RA0+1*MMU_B ASE;                   // ��������Դ��ַ,Դ��Ŀ��+MMU_BASE
    Maddr_WriteAuto = RA0;                              // ��������Ŀ���ַ
    call _Mem_ShiftR1_Reg;                              // dest=src>>1,�ƻ�RD0,RD1;src,destΪָ��ģ��;[]=_Mem_ShiftL1_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////////////////

sub(Para_Normal,Para_MemWrite) _Mem_ShiftR1_Reg;
    RD0 = 0;
    RD0_SetBit31;
    RD3 = RD0;
_Mem_ShiftR1_Loop:
    RD0 = Mx;             //Դ
    RF_RotateR1(RD0);
    RD0 &= RD3;           //Ŀ�����λ
    RD1 = Mx;             //Ŀ��
    RF_ShiftR1(RD1);
    RD0 |= RD1;
    Mx = RD0;
    goto _Mem_ShiftR1_Loop;






/////////////////////////////////////////
//_Mem_Zero_Reg
//���ܣ��ж�Memoryָ�������Ƿ�Ϊ0
//���÷�ʽ��call _Mem_Zero_Reg; ��ʾ��
//�ƻ���RD0.RD1
//��ڣ�����+1.Դ��ַ
//���ڣ�RD1
//ʹ��ʾ��
/*
    RD0=M_BufQ0;
    RA0=RD0;
    RD0=M_OperModLen;
    RD0++;
    Set_LoopNum = RD0;                                  // ������������,RD0=M_OperModLen+1
    Maddr_ReadAuto = RA0;                               // ��������Դ��ַ
    call _Mem_Zero_Reg;                                 // src==0,�ƻ�RD0,RD1;destΪָ��ģ��; [RD1]=_Mem_Zero_Reg(Set_LoopNum,Maddr_ReadAuto);in:Set_LoopNum,Maddr_ReadAuto;out:RD1=0/none_0-X=0/none_0;
    RD0=RD1;
    if(RD0_Zero) goto L_MFGenRSAPrime_End;              // z-1==0 => z==1 => prime generated OK
*/
/////////////////////////////////////////
sub(Para_Normal,Para_MemRead) _Mem_Zero_Reg;
    RD1 = 0;
_Mem_Zero_Loop:
    RD0 = Mx;
    if(RD0_Zero) goto _Mem_Zero_Loop;
    RD1 = RD0;
    goto _Mem_Zero_Loop;



/*
/////////////////////////////////////////
//_Mem_3A_Regʹ��ʾ��
/////////////////////////////////////////
    Set_LoopNum = 32;                                   // ������������
    Set_AutoMemAlt;                                     // ������
    Maddr_ReadAuto = RA0;                               // ��������Դ��ַ
    Maddr_WriteAuto = RA0;                              // ��������Ŀ�꼴Դ
    call _Mem_3A_Reg;                                   // dest=3*src,�ƻ�RD0,RD1,RD2,RD3;src,destΪָ��ģ��;[]=_Mem_3A_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////
//_Mem_3A_Reg
//����:����3A=>A;
//���÷�ʽ:��ʾ��
//�ƻ� RD0,RD1,RD2,RD3;
//���:����,Դ��ַ,Ŀ���ַ
/////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_3A_Reg;
    RD0 = 0;
    RD1 = 0;
    RD2 = 0;
    RD0 += RD0;     //ensure carry is 0
_Mem_3A_Reg_Loop:
    RD0 = Mx;
    RD3 = RD0;
    RD0 ^+= RD1;
    RD1 = 0;
    RD1 ^+=RD2; //RD2 must be 0
    RD0 += RD3;
    RD1 ^+=RD2; //RD2 must be 0
    Mxx += RD0;
    goto _Mem_3A_Reg_Loop;



/////////////////////////////
//_Mem_Add_A1_Reg
//����:Memory   A+=1����ɺ���� Carry
//���÷�ʽ:��ʾ��
//�ƻ� RD0
//���:����,Դ��ַ,Ŀ���ַ
//ʹ��ʾ��
/*
    Set_LoopNum = 32;
    Set_AutoMemAlt;
    Maddr_ReadAuto = RA0;
    Maddr_WriteAuto = RA0;
    call _Mem_Add_A1_Reg;
*/
/////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_Add_A1_Reg;
    RD0 = 0;
    RD0 += RD0;
    RD0 = 1;
_Mem_Add_A1_Reg_Loop:
    RD1 = Mx;
    Mxx ^+= RD0;
    goto _Mem_Add_A1_Reg_Loop;


/////////////////////////////
//_Mem_Sub_A2_Reg
//����:Memory A-=2����ɺ���� Borrow
//���÷�ʽ:��ʾ��
//�ƻ� RD0.RD1
//���:����,Դ��ַ,Ŀ���ַ
//ʹ��ʾ��
/*
    Set_LoopNum = 32;
    Set_AutoMemAlt;
    Maddr_ReadAuto = RA0;
    Maddr_WriteAuto = RA0;
    call _Mem_Sub_A2_Reg;
*/
/////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_Sub_A2_Reg;
    RD0 = -1;
    RD0 --;
    RD1 = Mx;
    Mxx += RD0;
    RD0 = -1;    
_Mem_Sub_A2_Reg_Loop:
    RD1 = Mx;
    Mxx ^+= RD0;
    goto _Mem_Sub_A2_Reg_Loop;


/////////////////////////////
//_Mem_Sub_A1_Reg
//����:Memory A-=1����ɺ���� Borrow
//���÷�ʽ:��ʾ��
//�ƻ� RD0.RD1
//���:����,Դ��ַ,Ŀ���ַ
//ʹ��ʾ��
/*
    Set_LoopNum = 32;
    Set_AutoMemAlt;
    Maddr_ReadAuto = RA0;
    Maddr_WriteAuto = RA0;
    call _Mem_Sub_A2_Reg;
*/
/////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_Sub_A1_Reg;
    RD1 = -1;
    RD0 = 0;
    RD0 += RD0;
_Mem_Sub_A1_Reg_Loop: 
    RD0 = Mx;
    Mxx ^+= RD1;
    goto _Mem_Sub_A1_Reg_Loop;


/////////////////////////////
//_Mem_Madd_AB_Reg
//����:Memory Ŀ�����Դ��Ŀ��
//���÷�ʽ:��ʾ��
//�ƻ� RD0
//���:����,Դ��ַ,Ŀ���ַ
//ʹ��ʾ��
/*
    Set_LoopNum = 32;                                   // ������������
    Set_AutoMemAlt;                                     // ������
    Maddr_ReadAuto = RA0;                               // ��������Դ��ַ
    Maddr_WriteAuto = RA1;                              // ��������Ŀ���ַ
    call _Mem_Madd_AB_Reg;                              // dest^=src,�ƻ�RD0;src,destΪָ��ģ��;[]=_Mem_Sub_AB_Reg(Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto);in:Set_LoopNum,Set_AutoMemAlt,Maddr_ReadAuto,Maddr_WriteAuto; out:none;
*/
/////////////////////////////
sub(Para_Normal,Para_MemWrite) _Mem_Madd_AB_Reg;
_Mem_Madd_AB_Reg_Loop:
    RD0 = Mx;
    Mxx ^= RD0;
    goto _Mem_Madd_AB_Reg_Loop;


//=======================================================================
//         End  XL
//=======================================================================


END SEGMENT

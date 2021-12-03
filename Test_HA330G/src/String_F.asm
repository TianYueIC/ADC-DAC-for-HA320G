#define _STRING_F_

#include <CPU11.def>

CODE SEGMENT STRING_F;
////////////////////////////////////////////////////////
//  ����:
//      memcpy
//  ����:
//      ���������ڴ浥Ԫ
//  ����:
//      1.len
//      2.src
//      3.dest(out)
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub memcpy;
    push RA1;
    push RA0;
    push RD2;

    RA1 = M[RSP+4*MMU_BASE];//Ŀ��
    RA0 = M[RSP+5*MMU_BASE];//Դ
    RD2 = M[RSP+6*MMU_BASE];//����
    RF_ShiftR2(RD2);

    RD0 = RD2;
    if(RD0==0) goto L_memcpy_End;

L_memcpy_Intloop:
    RD0 = M[RA0++];
    M[RA1++] = RD0;
    RD2 --;
    if(RQ_nZero) goto L_memcpy_Intloop;


L_memcpy_End:
    pop RD2;
    pop RA0;
    pop RA1;
    Return(3*MMU_BASE);



////////////////////////////////////////////////////////
//  ����:
//      memcpy2
//  ����:
//      ���������ڴ浥Ԫ
//  ����:
//      1.RD0:len
//      2.RA0:srcָ��DW��ַ�洢��
//      3.RA1:destָ��Byte��ַ�洢��(out)
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField memcpy2;
    RF_ShiftR2(RD0);
    RD2 = RD0;
L_memcpy2_loop:
    RD0 = M[RA0];
    RA0++;
    M[RA1++] = RD0;
    RD2 --;
    if(RQ_nZero) goto L_memcpy2_loop;
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  ����:
//      memset
//  ����:
//      �����ڴ浥Ԫ����
//  ����:
//      1.���ȣ�����4��������(��λ���ֽ�)
//      2.��ֵ
//      3.��ַ(out)
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub memset;
    push RA1;

    RA1 = M[RSP+2*MMU_BASE];//Ŀ��
    RD1 = M[RSP+4*MMU_BASE];//����
    RF_ShiftR2(RD1);//������
    RD0 = M[RSP+3*MMU_BASE];
L_memset_Intloop:
    M[RA1++] = RD0;
    RD1--;
    if(RQ_nZero) goto L_memset_Intloop;

    pop RA1;
    Return(3*MMU_BASE);



////////////////////////////////////////////////////////
//  ����:
//      memcmp
//  ����:
//      ��ָ�������ڶԱ��ڴ浥Ԫ
//  ����:
//      1.RD0:���ȣ�����4��������(��λ���ֽ�)
//      2.RA1:�ڴ���ַ2
//      3.RA0:�ڴ���ַ1
//  ����ֵ:
//      1.RD0��==0 ��ȣ���������Ϊ0ʱ��
//              <0 str1<str2
//              >0 str1>str2
////////////////////////////////////////////////////////
Sub_AutoField memcmp;
    RD3 = RD0;//����
    RF_ShiftR2(RD3);

L_memcmp_Intloop:
    RD2 = M[RA1++];
    RD0 = M[RA0++];
    RD0 -= RD2;
    if(RD0_nZero) goto L_memcmp_End;
    RD3 --;
    if(RQ_nZero) goto L_memcmp_Intloop;

L_memcmp_End:
    //RD0 = RA0;
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  ����:
//      memcmp2
//  ����:
//      ��ָ�������ڶԱ��ڴ浥Ԫ
//  ����:
//      1.RD0:���ȣ�����4��������(��λ���ֽ�)
//      2.RA1:�ڴ���ַ2��ָ��Byte��ַ�洢��
//      3.RA0:�ڴ���ַ1��ָ��DW��ַ�洢��
//  ����ֵ:
//      1.RD0��==0 ��ȣ���������Ϊ0ʱ��
//              <0 str1<str2
//              >0 str1>str2
////////////////////////////////////////////////////////
Sub_AutoField memcmp2;
    RD3 = RD0;//����
    RF_ShiftR2(RD3);

L_memcmp_Intloop2:
    RD2 = M[RA1++];
    RD0 = M[RA0];
    RA0++;
    RD0 -= RD2;
    if(RD0_nZero) goto L_memcmp_End2;
    RD3 --;
    if(RQ_nZero) goto L_memcmp_Intloop2;

L_memcmp_End2:
    //RD0 = RA0;
    Return_AutoField(0*MMU_BASE);

END SEGMENT
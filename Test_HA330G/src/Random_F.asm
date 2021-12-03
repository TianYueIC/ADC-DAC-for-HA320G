#define _RANDOM_F_

#include <CPU11.def>
#include <Random.def>
#include <resource_allocation.def>

CODE SEGMENT RANDOM_F;
//////////////////////////////////////////////////////////////////////////
//  �����ʹ�����̣�
//  1.�ϵ�֮�����������Ԥ�ȣ�
//    1.1 ������� RandomEnable��
//    1.2 ��ʱʱ�����1ms���ϣ�
//    1.3 Ԥ����ɺ���Թص��������
//        ������� RandomDisable��
//////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////
//  ����:
//      _RandomGet
//  ����:
//      ��ָ�����Ȼ�ȡ�����
//  ����:
//      1.RD0:����ָ��(out)
//      2.RD1:��������ȣ���ByteΪ��λ������4����������
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField _RandomGet;
    Random_Enable;
    RA0 = RD0;
    RF_ShiftR2(RD1);
    RD2 = RD1;
RandomGet_L1:
    RD0 = RandomData;
    RD0 ^= RandomData;
    RF_Disorder(RD0);
    RD0 += RandomData;
    RF_Reverse(RD0);
    RD0 ^= RandomData;
    RF_Disorder(RD0);
    M[RA0++] = RD0;               //RA0+=4
    RD2--;
    if(RQ_nZero) goto RandomGet_L1;
    Random_Disable;
    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  ����:
//      Random_Gets1
//  ����:
//      ��ָ�����Ȼ�ȡ�����
//  ����:
//      1.��������ȣ���ByteΪ��λ������4����������
//      2.����ָ��(out)
//  ����ֵ:
//      ��
////////////////////////////////////////////////////////
Sub_AutoField Random_Gets1;
    //M[RSP+0*MMU_BASE]:�������ָ����ַ
    //M[RSP+1*MMU_BASE]:Length
    Random_Enable;
    RA0 = M[RSP+0*MMU_BASE];
    RD2 = M[RSP+1*MMU_BASE];
    RF_ShiftR2(RD2);

L_Random_Gets_0:
    RD0 = RandomData;
    RD0 ^= RandomData;
    RF_Disorder(RD0);
    RD0 += RandomData;
    RF_Reverse(RD0);
    RD0 ^= RandomData;
    RF_Disorder(RD0);
    M[RA0++] = RD0;               //RA0+=4
    RD2--;
    if(RQ_nZero) goto L_Random_Gets_0;
    Random_Disable;
    Return_AutoField(2*MMU_BASE);



////////////////////////////////////////////////////////
//  ����:
//      _Random_Get1
//  ����:
//      ��ȡһ��DWord���ȵ������
//  ����:
//      ��
//  ����ֵ:
//      1.RD0: ��ȡ�������
////////////////////////////////////////////////////////
Sub_AutoField _Random_Get1;
    Random_Enable;
    RD0 = RandomData;
    RD0 ^= RandomData;
    RF_Disorder(RD0);
    RD0 += RandomData;
    RF_Reverse(RD0);
    RD0 ^= RandomData;
    RF_Disorder(RD0);
    Random_Disable;
    Return_AutoField(0*MMU_BASE);

END SEGMENT

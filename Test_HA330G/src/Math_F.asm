#include <cpu11.def>
#include <Math.def>
#include <SOC_Common.def>
#include <resource_allocation.def>
#include <Global.def>
#include <USI.def>

CODE SEGMENT Math_F;
////////////////////////////////////////////////////////
//  ����:
//      Float_From_Int
//  ����:
//      32λ��������ת��Ϊ 24Bit Float��ʽ
//  ����:
//      1.RD0: ��������
//  ����ֵ:
//      1.RD0: 24Bit Float��ʽ
////////////////////////////////////////////////////////
Sub_AutoField Float_From_Int;
    push RD4;

    if(RD0 == 0) goto L_Float_From_Int_End;
    RD2 = RD0;//����ԭ��

    //������λ����
    RF_Abs(RD0);
    RD4 = RD0;
    RF_Log(RD0);
    RD1 = 22;
    RD0 -= RD1;
    RD3 = RD0;// ����λ��

    //ȡ����ֵ���һ��
    RD1 = RD3;
    if(RD0_Bit31==0) goto L_Float_From_Int_0;
    //����Ϊ��ʱ���Ƶ���
    RF_Abs(RD1);
    RD0 = RD4;
    call _Rf_ShiftL_Reg;
    goto L_Float_From_Int_1;
L_Float_From_Int_0:
  //����Ϊ��ʱ���Ƶ���
    RD0 = RD4;
    call _Rf_ShiftR_Reg;
L_Float_From_Int_1:

    //�ָ�����������
    RD1 = RD0;
    RD0 = RD2;
    if(RD0_Bit31==0) goto L_Float_From_Int_2;
    RF_Neg(RD1);
L_Float_From_Int_2:
    RD0 = RD1;
    RD3 += 22;

    //ƴ�ӽ���
    RD0_ClrByteH8;
    RF_GetL8(RD3);
    RF_RotateR8(RD3);
    RD0 += RD3;
L_Float_From_Int_End:
    pop RD4;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      Float_To_Int
//  ����:
//      24Bit Float��ʽת��Ϊ32λ��������
//  ����:
//      1.RD0: 24Bit Float��ʽ
//  ����ֵ:
//      1.RD0: ��������
////////////////////////////////////////////////////////
Sub_AutoField Float_To_Int;
    //��������ֵ��RD2
    RD2 = RD0;

    //ȡ����->RD1
    RF_GetH8(RD0);
    RD1 = RD0;
    RD1 -= 22;

    //ȡ����->RD3
    RD0 = RD2;
    RD0_ClrByteH8;
    RD0_SignExtL24;
    RD3 = RD0;

    RD0 = RD1;
    RF_Abs(RD1);
    if(RD0_Bit31==1) goto L_Float_To_Int_ShiftR;
    //����Ϊ����������
    RD0 = RD3;
    call _Rf_ShiftL_Reg;
    goto L_Float_To_Int_1;

L_Float_To_Int_ShiftR:
    //����Ϊ����������
    RD0 = RD3;
    call _Rf_ShiftR_Signed_Reg;


L_Float_To_Int_1:
    RD1 = RD2;
    if(RQ_Bit31==0) goto L_Float_To_Int_End;
    RF_Neg(RD0);

L_Float_To_Int_End:

  Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      _Float_Add
//  ����:
//      �����
//  ����:
//      1.RD0:x
//      2.RD1:y
//  ����ֵ:
//      1.RD0: x+y;
////////////////////////////////////////////////////////
Sub_AutoField _Float_Add;
    push RD4;
    push RD6;
    push RD7;

    RD2 = RD0;
    RD3 = RD1;
    RD4 = 0;// ��һ�������������ֵ������Ӻ����������RD4++

    // x����
    RD0_ClrByteH8;
    RF_ShiftR1(RD0); // Ϊ���������������������һλ�������
    if(RD0_Bit22==0) goto L_Float_Add_2;
    RD0_SetBit23;
L_Float_Add_2:
    RD0_SignExtL24;
    RD6 = RD0;// �Ĵ�x�ĵ���

    // y����
    RD0 = RD1;
    RD0_ClrByteH8;
    RF_ShiftR1(RD0);// Ϊ���������������������һλ�������
    if(RD0_Bit22==0) goto L_Float_Add_3;
    RD0_SetBit23;
L_Float_Add_3:
    RD0_SignExtL24;
    RD7 = RD0;      // �Ĵ�y�ĵ���

    // ��������ȴ�С
    RD0 = RD3;
    RF_GetH8(RD0);
    RD0_SignExtL8;
    RD1 = RD0;      // y�Ľ��루��չ����λ��32bit��
    RD0 = RD2;
    RF_GetH8(RD0);
    RD0_SignExtL8;  // x�Ľ��루��չ����λ��32bit��
    RD0 -= RD1;
    if(SRQ>0) goto L_Float_Add_xBig;

// y��xС��x�������ƺ����
    RD1 = RD0;
    RF_Abs(RD1);
    RD0 = RD6;
    call _Rf_ShiftR_Signed_Reg;
    RD0 += RD7;

    // �ж�bit22��bit23�Ƿ���ȣ�����������һ����RD4++
    RD1 = RD0;
    RF_ShiftR1(RD1);
    RD1 ^= RD0;
    if(RQ_Bit22==1) goto L_Float_Add_0;
    RF_ShiftL1(RD0);
    goto L_Float_Add_4;

L_Float_Add_0:
    RD4 ++;
L_Float_Add_4:
    // ƴ�ӽ���
    RD1 = RD3;
    RF_GetH8(RD1);
    RD1 += RD4;         // ��һ������
    RF_RotateR8(RD1);
    RD0_ClrByteH8;
    RD0 += RD1;

    goto L_Float_Add_End;

// x��yС��y�������ƺ����
L_Float_Add_xBig:
    RD1 = RD0;
    RF_Abs(RD1);
    RD0 = RD7;
    call _Rf_ShiftR_Signed_Reg;
    RD0 += RD6;

    // �ж�bit22��bit23�Ƿ���ȣ�����������һ����RD4++
    RD1 = RD0;
    RF_ShiftR1(RD1);
    RD1 ^= RD0;
    if(RQ_Bit22==1) goto L_Float_Add_1;
    RF_ShiftL1(RD0);
    goto L_Float_Add_5;

L_Float_Add_1:
    RD4 ++;

L_Float_Add_5:
    // ƴ�ӽ���
    RD1 = RD2;
    RF_GetH8(RD1);
    RD1 += RD4;         // ��һ������
    RF_RotateR8(RD1);
    RD0_ClrByteH8;
    RD0 += RD1;

L_Float_Add_End:
    call _Stan;
    pop RD7;
    pop RD6;
    pop RD4;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      _Float_Sub
//  ����:
//      �����
//  ����:
//      1.RD0:x
//      2.RD1:y
//  ����ֵ:
//      1.RD0: x-y;
////////////////////////////////////////////////////////
Sub_AutoField _Float_Sub;
    push RD4;
    push RD6;
    push RD7;

    RD2 = RD0;
    RD3 = RD1;
    RD4 = 0;// ��һ�������������ֵ������������������RD4++

    // x����
    RD0_ClrByteH8;
    RF_ShiftR1(RD0); // Ϊ���������������������һλ�������
    if(RD0_Bit22==0) goto L_Float_Sub_2;
    RD0_SetBit23;
L_Float_Sub_2:
    RD0_SignExtL24;
    RD6 = RD0;// �Ĵ�x�ĵ���

    // y����
    RD0 = RD1;
    RD0_ClrByteH8;
    RF_ShiftR1(RD0);// Ϊ���������������������һλ�������
    if(RD0_Bit22==0) goto L_Float_Sub_3;
    RD0_SetBit23;
L_Float_Sub_3:
    RD0_SignExtL24;
    RD7 = RD0;      // �Ĵ�y�ĵ���

    // ��������ȴ�С
    RD0 = RD3;
    RF_GetH8(RD0);
    RD0_SignExtL8;
    RD1 = RD0;      // y�Ľ��루��չ����λ��32bit��
    RD0 = RD2;
    RF_GetH8(RD0);
    RD0_SignExtL8;  // x�Ľ��루��չ����λ��32bit��
    RD0 -= RD1;
    if(SRQ>0) goto L_Float_Sub_xBig;

// y��xС��x�������ƺ����
    RD1 = RD0;
    RF_Abs(RD1);
    RD0 = RD6;
    call _Rf_ShiftR_Signed_Reg;
    RD0 -= RD7;

    // �ж�bit22��bit23�Ƿ���ȣ�����������һ����RD4++
    RD1 = RD0;
    RF_ShiftR1(RD1);
    RD1 ^= RD0;
    if(RQ_Bit22==1) goto L_Float_Sub_0;

    RF_ShiftL1(RD0);
    goto L_Float_Sub_4;

L_Float_Sub_0:
    RD4 ++;
L_Float_Sub_4:
    // ƴ�ӽ���
    RD1 = RD3;
    RF_GetH8(RD1);
    RD1 += RD4;         // ��һ������

    RF_RotateR8(RD1);
    RD0_ClrByteH8;
    RD0 += RD1;
    goto L_Float_Sub_End;

// x��yС��y�������ƺ����
L_Float_Sub_xBig:
    RD1 = RD0;
    RF_Abs(RD1);
    RD0 = RD7;
    call _Rf_ShiftR_Signed_Reg;
    RD6 -= RD0;
    RD0 = RD6;

    // �ж�bit22��bit23�Ƿ���ȣ�����������һ����RD4++
    RD1 = RD0;
    RF_ShiftR1(RD1);
    RD1 ^= RD0;
    if(RQ_Bit22==1) goto L_Float_Sub_1;
    RF_ShiftL1(RD0);
    goto L_Float_Sub_5;

L_Float_Sub_1:
    RD4 ++;
L_Float_Sub_5:
    // ƴ�ӽ���
    RD1 = RD2;
    RF_GetH8(RD1);
    RD1 += RD4;         // ��һ������
    RF_RotateR8(RD1);
    RD0_ClrByteH8;
    RD0 += RD1;

L_Float_Sub_End:
    call _Stan;

    pop RD7;
    pop RD6;
    pop RD4;
    Return_AutoField(0);



////////////////////////////////////////////////////////////
////  ����:
////      _Float_Div
////  ����:
////      �������
////  ����:
////      1.RD0:x
////      2.RD1:y
////  ����ֵ:
////      1.RD0: x/y;
////////////////////////////////////////////////////////////
//Sub_AutoField _Float_Div;
//
//    RD2=RD0;
//    RD0=RD1;
//    call _Float_Recip;
//    RD1 =RD2;
//    call _Float_Multi;
//
//    Return_AutoField (0);


////////////////////////////////////////////////////////////
////  ����:
////      _Float_Recip
////  ����:
////      ��������(������)
////  ����:
////      1.RD0:x;
////  ����ֵ:
////      1.RD0: 1/x;
////  ע��:
////      1.1/(x*2^y)=1/x*2^(-y)
////////////////////////////////////////////////////////////
//Sub_AutoField _Float_Recip;
//
//    RD1=RD0;
//    RF_GetH8(RD0);
//    RD2=RD0;                                          // x��orderλy������RD2��
//    RD0=RD1;
//    RD0_ClrByteH8;                                        //  RD0��8λ��0
//    RD1=RD0;
//    call _Recip;                                      //  1/x=RD0*order(-1)
//    RD1=RD0;
//
//    RD0=RD2;
//    RF_Neg(RD0);
//        RD0 -= 1;                                                                                    //order��0
//    RD0_ClrByteH24;                                   //-Y
//    RF_RotateR8(RD0);
//    RD0 += RD1;
//
//    call _Stan;
//
//    Return_AutoField (0);

////////////////////////////////////////////////////////
//  ����:
//      _Float_Multi
//  ����:
//      ��˷�����(������)
//  ����:
//      1.RD0:x
//      2.RD1:y
//  ����ֵ:
//      1.RD0: x*y;
//  ע��:
//      1.(2^n*x)*(2^m*y)=2^(n+m)xy
////////////////////////////////////////////////////////
Sub_AutoField _Float_Multi;
    push RD4;
    push RD5;

    // ȡx����->RD3
    RD5=RD0;
    RF_GetH8(RD0);
    RD2=RD0;// x��orderλy������RD2��
    RD0=RD5;
    RD0_ClrByteH8;
    RD0_SignExtL24;
    RD3 = RD0;

    // ȡy����->RD0
    RD5=RD1;
    RD0=RD1;
    RF_GetH8(RD0);
    RD4=RD0;// x��orderλy������RD4��
    RD0=RD5;
    RD0_ClrByteH8;
    RD0_SignExtL24;

    // �������
    Multi24_X=RD0;
    RD0=RD3;
    Multi24_Y=RD0;
    nop;
    RD0=Multi24_XY;
    RD0_ClrByteH8;

    // �������
    RD1 = RD2;
    RD1 += RD4;
    RD1 ++;
    RF_GetL8(RD1);

    // ƴ�ӽ���
    RF_RotateR8(RD1);
    RD0 += RD1;

L_Float_Multi_End:
    // ��һ��
    call _Stan;

    pop RD5;
    pop RD4;
    Return_AutoField (0);



////////////////////////////////////////////////////////
//  ����:
//      _Float_Lg
//  ����:
//      ����10Ϊ�׵Ķ�������(������)
//  ����:
//      1.RD0:x
//  ����ֵ:
//      1.RD0: lg(x);
//  ע��:
//      1.lg(x*2^y)=lgx+y*lg2
////////////////////////////////////////////////////////
Sub_AutoField _Float_Lg;

    //32λ��������
    RD1=RD0;
    RF_GetH8(RD0);
    RD2=RD0;                                          // x��orderλy������RD2��
    RD0=RD1;
    RD0_ClrByteH8;                                        //  RD0��8λ��0
    RD1 = RD0;
    call _Lg;                                         //  lgx=RD0*order(-1)
    RF_ShiftR2(RD0);
    RF_ShiftR2(RD0);
    RF_ShiftR2(RD0);
    RF_ShiftR2(RD0);                                //  lgx=RD0*order(7)
    RD3 = RD0;

    RD0 = RD2;
    RF_RotateR16(RD0);                                //  y=RD0*order��6��
    if(RD0_Bit23 == 0) goto L_Float_Lg_0;
    RD0_SetByteH8;
L_Float_Lg_0:
    Multi24_X=RD0;
    RD0=0;
    RD0_SetBit20;
    RD0_SetBit17;
    RD0_SetBit16;
    RD0_SetBit14;
    RD0_SetBit10;
    RD0_SetBit4;
    RD0_SetBit1;
    RD0_SetBit0;                                      // lg2 =(1 0011 0100 0100 0001 0011)2=RD0*order(0)

    Multi24_Y=RD0;
    nop;
    nop;
    nop;
    RD0=Multi24_XY;                                   //  y*lg2= RD0*order(7)
    RD0_ClrByteH8;

    RD0 += RD3;//32λ��С������22λ��
    RD1=RD0;
    RD0=7;
    RF_RotateR8(RD0);
    RD0+=RD1;
    call _Stan;

    Return_AutoField (0);

//////////////////////////////////////////////////////////////
//////  ����:
//////      _Stan
//////  ����:
//////      ��32λ�ǹ�һ�����ݣ��߰�λ���룬22λС��λ����һ��
//////  ����:
//////      1.RD0:ԭ����;
//////  ����ֵ:
//////      1.RD0: ��һ�����;
//////  ע��:
//////      1.����Ϊ��һ����ʽ������: x������,b23=0,b22=1;x�Ǹ���,b23=1,b22=0;;x��0,b23=0,b22=0;
//////////////////////////////////////////////////////////////
//Sub_AutoField _Stan2;
//    push RD4;
//    push RD5;
//
//    RD2 = RD0;
//    RD0_ClrByteH8;
//    if(RD0_Zero) goto L_Stan_Zero;
//    RD0 = RD2;
//
//    //��һ��
//    RD5=RD0;
//    RF_GetH8(RD0);
//    RD4=RD0;                                          // x��orderλy������RD4��
//    RD0=RD5;
//    RD0_ClrByteH8;                                    //  RD0��8λ��0
//    RD3 = RD0;                                        //  ��24λ
//    RD2 = 0;
//
//    if(RD0_Bit23 == 0) goto L_Stan_2;
//L_Stan_10:
//    RF_ShiftL1(RD0);
//    RD2++;
//    if(RD0_Bit23 == 1) goto L_Stan_10;
//    RF_ShiftR1(RD0);
//    RD0_SetBit23;
//    RD0_ClrByteH8;                                        //  RD0��8λ��0 ��24λ��һ��
//    RD1 = RD0;
//    RD0 = RD4;
//    RD0-=RD2;
//    RD0 ++;
//    RD0_ClrByteH24;
//    RF_RotateR8(RD0);
//    RD0 += RD1;
//    goto L_End;
//L_Stan_2:
//    if(RD0 == 0) goto L_Stan_1;
//    RD2++;
//    RF_ShiftR1(RD0);
//    goto L_Stan_2;
//L_Stan_1:
//    RD0 = RD2;
//    RD0 +=9; //����-23+32
//    RD1 = RD0;
//    RD0 = RD3;
//L_Stan_3:
//    RF_RotateR1(RD0);
//    RD1 -- ;
//    if(RQ!=0) goto L_Stan_3;
//    RD0_ClrByteH8;                                        //  RD0��8λ��0 ��24λ��һ��
//    RD1 = RD0;
//
//    RD0 = RD2;
//    RD0+=RD4;
//    RD0 -= 23;
//    RD0_ClrByteH24;
//    RF_RotateR8(RD0);
//    RD0 += RD1;
//L_End:
//    pop RD5;
//    pop RD4;
//    Return_AutoField (0);
//
//L_Stan_Zero:
//    RD0 = 0;
//    pop RD5;
//    pop RD4;
//    Return_AutoField (0);
//
////////////////////////////////////////////////////////
//  ����:
//      _Stan
//  ����:
//      ��32λ�ǹ�һ�����ݣ��߰�λ���룬22λС��λ����һ��
//  ����:
//      1.RD0:ԭ����;
//  ����ֵ:
//      1.RD0: ��һ�����;
//  ע��:
//      1.����Ϊ��һ����ʽ������: x������,b23=0,b22=1;x�Ǹ���,b23=1,b22=0;;x��0,b23=0,b22=0;
////////////////////////////////////////////////////////
Sub_AutoField _Stan;
    if(RD0_Bit23==0) goto L_Stan_Pos;
    RD2 = RD0;
    RD3 = RD0;
    RF_GetH8(RD2);// ����
    RF_Not(RD0);
    RD0_ClrByteH8;// ��������
    RF_Log(RD0);
    RD1 = 22;
    RD1 -= RD0;
    RD2 -= RD1;// ��������
    RF_GetL8(RD2);
    RD0 = RD3;
    RD0_ClrByteH8;
    call _Rf_ShiftL_Reg;
    RD0_ClrByteH8;
    RF_RotateR8(RD2);
    RD0 += RD2;
    goto L_Stan_End;

L_Stan_Pos:
    RD2 = RD0;
    RF_GetH8(RD2);// ����
    RD0_ClrByteH8;// ����
    RD3 = RD0;
    RF_Log(RD0);
    RD1 = 22;
    RD1 -= RD0;
    RD2 -= RD1;// ��������
    RF_GetL8(RD2);
    RD0 = RD3;
    call _Rf_ShiftL_Reg;
    RF_RotateR8(RD2);
    RD0 += RD2;

L_Stan_End:
    Return_AutoField (0);

//Sub_AutoField _Stan;
//      //��һ��
//      RD5=RD0;
//      RF_GetH8(RD0);
//      RD4=RD0;                                                                                    // x��orderλy������RD4��
//
//      RD0=RD5;
//      if(RD0_Bit23 == 0) goto L_Stan_1;
//      RF_Neg(RD0);
//L_Stan_1:
//      RD0_ClrByteH8;                                                                      //  RD0��8λ��0
//      RD2 = RD0;
//      RF_Log(RD0);
//      RD1 = 22;
//      RD1 -= RD0;
//      RD3 = RD1;
//      RD0 = RD2;
//      call _Rf_ShiftL_Reg;
//
//      RD0_ClrByteH8;                                                                      //  RD0��8λ��0
//      RD1 = RD0;
//      RD0 = RD5;
//      if(RD0_Bit23 == 0) goto L_Stan_2;
//      RD0=RD1;
//      RF_Neg(RD0);
//      RD0_ClrByteH8;                                                                      //  RD0��8λ��0
//      RD1 = RD0;
//L_Stan_2:
//
//      RD0 = RD4;
//      RD0 -= RD3;
//      RD0_ClrByteH24;
//      RF_RotateR8(RD0);
//      RD0 += RD1;
//
//      Return_AutoField (0);

//////////////////////////////////////////////////////////
////  ����:
////      _Recip
////  ����:
////      ����; 1/x=a*(1-b)(1+b^2)=a*(1-b+b^2-b^3),x=xh+xl,a=1/xh,b=xl*(1/xh);
////  ����:
////      1.RD1:x,24BIT FLOAT,����Ϊ��һ����ʽ,��x��0;
////  ����ֵ:
////      1.RD0: 1/x = RD0*order(-1) ;
////  ע��:
////      1. ����Ϊ��һ����ʽ������: x������,b23=0,b22=1;x�Ǹ���,b23=1,b22=0;
////      2. ���������Ϊ��һ����ʽ,���øú���ǰ,���x���е�����һ��;
////      3. �ú������������,���ⲿ���м���;
//////////////////////////////////////////////////////////
//Sub_AutoField _Recip;
//    push RD4;
//    RD4 = 0xFFFFFF;
//
//    RD0 = RN_Addr_Float;
//    RA1 = RD0;                                                       // ��������ʽ��������ַ
//    RD0 = RN_Addr_Recip;
//    RA0 = RD0;                                                             // ����ROM��ַ
//
//    // �ж�x������
//    RD0 = RD1;
//    RD3 = RD1;
//    if(RD0_Bit23==0) goto L_Recip_0;
//    RF_Neg(RD0);
//L_Recip_0:
//    // ��x�ֽ�ɸߵ�������:
//
//
//    M[RA1+L24Bit_ToFloat]=RD0;
//    RF_ShiftL1(RD0);
//    RD1 = 0X7FFFF;
//    RD1 &= RD0;
//    //RD1=M[RA1+Read_Float_L];                                              // xl=RD1*order(-1)
//    RD0=M[RA1+Read_Float_H];                                                // RD0=x�ĸ���λ���м���λ,D21,D20,D19.D22Ϊ1,����;D18?���Flag_XH_LSB��.
//
//    // x�ĸ�λ���:
//    RD0=M[RA0+RD0];
//
//    // ����xh��LSBλ,ȡ�������L16,H16:
//    if(Flag_XH_LSB==1) goto L_Recip_1;
//    M[RA1+L16Bit_ToFloat]=RD0;
//    goto L_Recip_2;
//L_Recip_1:
//    M[RA1+H16Bit_ToFloat]=RD0;
//L_Recip_2:
//    RD0=M[RA1+Read_Float];                                                  // a=1/xh=RD0*order(-1)
//    RD2=RD0;                                                                                // a=1/xh=RD2*order(-1)
//
//    // ����b=xl*(1/xh):
//    RF_ShiftL2(RD1);                                                                // ��xl������λ,�Ա������˷�����ʱ��������
//    RF_ShiftL2(RD1);                                                                // xl=RD1*order(-5)
//    Multi24_X=RD1;
//    Multi24_Y=RD0;
//    nop;
//    RD0=Multi24_XY;                                                              // b=xl*(1/xh)=RD1*order(-5) (�˷����order+=1)
//    RD0_ClrByteH8;
//    RD1 = RD0;
//
//    // ����b^2:
//    Multi24_X=RD0;
//    Multi24_Y=RD0;
//
//    // ����1-b:
//    RD0=0;
//    RD0_SetBit30;                                                                       // 1=RD0*order(-8)
//    RF_ShiftL2(RD1);                                                                // b=RD1*order(-7)
//    RF_ShiftL1(RD1);                                                                // b=RD1*order(-8)
//    RD0-=RD1;                                                                               // (1-b)=RD0*order(-8)
//
//    // ����b^3:
//    RD1=Multi24_XY;                                                                 // b^2=RD1*order(-9)
//    RD1 &= RD4;
//    RF_ShiftR1(RD1);                                                                // b^2=RD1*order(-8)
//    Multi24_Y=RD1;                                                                  // Multi24_X=b*order(-5),���ֲ���;
//
//    // ����(1-b)+b^2
//    RD0 += RD1;                                                                         // (1-b)+b^2=RD0*order(-8)
//
//    // ����[(1-b)+b^2]-b^3
//    RD1=Multi24_XY;                                                                 // b^3=RD0*order(-12)
//    RD1 &= RD4;
//    RF_ShiftR2(RD1);
//    RF_ShiftR2(RD1);                                                                // b^3=RD0*order(-8)
//    RD0 -= RD1;                                                                         // [(1-b)+b^2]-b^3=RD0*order(-8)
//    RF_ShiftR2(RD0);                                                                // ���˷���ǰ��Ҫ��֤D23������λΪ����λ.
//    RF_ShiftR2(RD0);
//    RF_ShiftR2(RD0);
//    RF_ShiftR2(RD0);                                                                // [(1-b)+b^2]-b^3=RD0*order(0)
//
//    // ����a*[(1-b)+b^2-b^3]
//    Multi24_X=RD0;
//    RD0 = RD2;                                                                          // a=1/xh=RD2*order(-1)
//    Multi24_Y=RD0;
//
//    // �ж�x������
//    RD0 = RD3;
//    if(RD0_Bit23==0) goto L_Recip_3;
//    RD0 = Multi24_XY;
//    RF_ShiftL1(RD0);                                                                // 1/x = RD0*order(-1)
//    RF_Neg(RD0);
//    RD0_ClrByteH8;//RD0 &= RD20;
//    goto L_Recip_End;
//L_Recip_3:
//    RD0 = Multi24_XY;
//    RF_ShiftL1(RD0);                                                                // 1/x = RD0*order(-1)
//    RD0_ClrByteH8;//RD0 &= RD20;
//
//L_Recip_End:
//    pop RD4;
//    Return_AutoField(0);


/*
////////////////////////////////////////////////////////
//  ����:
//      _Recip
//  ����:
//      ����; 1/x=a*(1-b)(1+b^2)=a*(1-b+b^2-b^3),x=xh+xl,a=1/xh,b=xl*(1/xh);
//  ����:
//      1.RD1:x,24BIT FLOAT,����Ϊ��һ����ʽ,��x��0;
//  ����ֵ:
//      1.RD0: 1/x = RD0*order(-1) ;
//  ע��:
//      1. ����Ϊ��һ����ʽ������: x������,b23=0,b22=1;x�Ǹ���,b23=1,b22=0;
//      2. ���������Ϊ��һ����ʽ,���øú���ǰ,���x���е�����һ��;
//      3. �ú������������,���ⲿ���м���;
////////////////////////////////////////////////////////
Sub_AutoField _Recip;
    push RD4;
    RD4 = 0xFFFFFF;

    RA1=RN_Addr_Float;                              // ��������ʽ��������ַ
    RA0=RN_Addr_Recip;                              // ����ROM��ַ

    // �ж�x������
    RD0 = RD1;
    RD3 = RD1;
    if(RD0_Bit23==0) goto L_Recip_0;
    RF_Neg(RD0);
L_Recip_0:
    // ��x�ֽ�ɸߵ�������:
    M[RA1+L24Bit_ToFloat]=RD0;
    RF_ShiftL1(RD0);
    RD1 = 0X7FFFF;
    RD1 &= RD0;
    //RD1=M[RA1+Read_Float_L];                                              // xl=RD1*order(-1)
    RD0=M[RA1+Read_Float_H];                        // RD0=x�ĸ���λ���м���λ,D21,D20,D19.D22Ϊ1,����;D18����Flag_XH_LSB��.
    //RF_ShiftL2(RD0);

    // x�ĸ�λ���:
    RD0=M[RA0+RD0];

    // ����xh��LSBλ,ȡ�������L16,H16:
    if(Flag_XH_LSB==1) goto L_Recip_1;
    M[RA1+L16Bit_ToFloat]=RD0;
    goto L_Recip_2;
L_Recip_1:
    M[RA1+H16Bit_ToFloat]=RD0;
L_Recip_2:
    RD0=M[RA1+Read_Float];                          // a=1/xh=RD0*order(-1)
    RD2=RD0;                                        // a=1/xh=RD2*order(-1)

    // ����b=xl*(1/xh):
    RF_ShiftL2(RD1);                                // ��xl������λ,�Ա������˷�����ʱ��������
    RF_ShiftL2(RD1);                                // a=1/xh=RD0*order(-5)
    Multi24_X=RD1;
    Multi24_Y=RD0;
    nop;
    RD0=Multi24_XY;                                 // b=xl*(1/xh)=RD1*order(-5) (�˷����order+=1)
  RD0_ClrByteH8;

    // ����b^2:
    Multi24_X=RD0;
    Multi24_Y=RD0;                                  // b=RD1*order(-5)

    // ����1-b:
    RD0=0;
    RD0_SetBit30;                                   // 1=RD0*order(-8)
    RF_ShiftL2(RD1);                                // b=RD1*order(-7)
    RF_ShiftL1(RD1);                                // b=RD1*order(-8)
    RD0-=RD1;                                       // (1-b)=RD0*order(-8)

    // ����b^3:
    RD1=Multi24_XY;                                 // b^2=RD1*order(-9)
  RD1 &= RD4;
    RF_ShiftR1(RD1);                                // b^2=RD1*order(-8)
    Multi24_Y=RD1;                                  // Multi24_X=b*order(-5),���ֲ���;

    // ����(1-b)+b^2
    RD0 += RD1;                                     // (1-b)+b^2=RD0*order(-8)

    // ����[(1-b)+b^2]-b^3
    RD1=Multi24_XY;                                 // b^3=RD0*order(-12)
  RD1 &= RD4;
    RF_ShiftR2(RD1);
    RF_ShiftR2(RD1);                                // b^3=RD0*order(-8)
    RD0 -= RD1;                                     // [(1-b)+b^2]-b^3=RD0*order(-8)
    RF_ShiftR2(RD0);                                // ���˷���ǰ��Ҫ��֤D23������λΪ����λ.
    RF_ShiftR2(RD0);
    RF_ShiftR2(RD0);
    RF_ShiftR1(RD0);                                // [(1-b)+b^2]-b^3=RD0*order(-1)

    // ����a*[(1-b)+b^2-b^3]
    Multi24_X=RD0;
    RD0 = RD2;                                      // a=1/xh=RD2*order(-1)
    Multi24_Y=RD0;

    // �ж�x������
    RD0 = RD3;
    if(RD0_Bit23==0) goto L_Recip_3;
    RD0 = Multi24_XY;                                // 1/x = RD0*order(-1)
  RD0_ClrByteH8;//RD0 &= RD20;
    RF_Neg(RD0);
    goto L_Recip_End;
L_Recip_3:
    RD0 = Multi24_XY;                                // 1/x = RD0*order(-1)
  RD0_ClrByteH8;//RD0 &= RD20;

L_Recip_End:
  pop RD4;
    Return_AutoField(0);
*/

////////////////////////////////////////////////////////////
////  ����:
////      _Sqrt
////  ����:
////      ��ƽ����; z=sqrt(x),x=xh+xl,a=sqrt(xh),b=xl/xh,z=a*(8+b*4-b^2)/8;
////  ����:
////      1.RD1:x,24BIT FLOAT,����Ϊ��һ����ʽ�Ǹ���;
////  ����ֵ:
////      1.RD0: 1/x;
////  ע��:
////      1.����b֮ǰ��Ҫ��xl������λ,�Ա�֤����˷�����ľ���;
////      2.����Ӽ���ʱ��Ҫ���������ݵ�orderͳһ,���㷨����ʱ��orderͳһΪ-5;
////      3.�˷�����ʱ�豣֤D23λ������λΪ����λ,�˷�ǰ�轫����������λ1����D22λ,������order.
////      4.����Ϊ��һ����ʽ������: x������,b23=0,b22=1;x�Ǹ���,b23=1,b22=0;;x��0,b23=0,b22=0;
////      5.���������Ϊ��һ����ʽ,���øú���ǰ,���x���е�����һ��;
////      6.�ú������������,���ⲿ���м���.
////////////////////////////////////////////////////////////
//Sub_AutoField _Sqrt;
//
//    RD0=RN_Addr_Float;
//    RA1 = RD0;                                 // ��������ʽ��������ַ
//    RD0=RN_Addr_Sqrt;
//    RA0 = RD0;                                  // ƽ����ROM��ַ
//
////////////////////////////////////////////////////////////
//////����sqrt(Xh)
//    // ��x�ֽ�ɸߵ�������:
//    M[RA1+L24Bit_ToFloat]=RD1;
//    RD0=M[RA1+Read_Float_H];                        // RD0=x�ĸ���λ���м���λ,D21,D20,D19.D22Ϊ1,����;D18����Flag_XH_LSB��.
//    //RF_ShiftL2(RD0);
//    // x�ĸ�λ���:
//    RD0=M[RA0+RD0];
//
//
//    // ����x��D18,ȡ�������L16,H16
//    if(Flag_XH_LSB==1) goto L_Sqrt_1;               // FLAG_FLOAT��D18
//    M[RA1+L16Bit_ToFloat]=RD0;
//    goto L_Sqrt_2;
//L_Sqrt_1:
//    M[RA1+H16Bit_ToFloat]=RD0;
//L_Sqrt_2:
//    RD0=M[RA1+Read_Float];                          // a=sqrt(xh)=RD0*order(0)
//    RD3=RD0;                                        // a=sqrt(Xh)=RD0*order(0)
//
//////////////////////////////////////////////////////////////
//////����1/xh
//    RD0 = RN_Addr_Recip;
//    RA0 = RD0;                                // ����ROM��ַ
//    M[RA1+L24Bit_ToFloat]=RD1;
//    RD1=M[RA1+Read_Float_L];                        // xl=RD1*order(-1),xl��x�ĵ�18λ
//    RD0=M[RA1+Read_Float_H];                        // RD0=x�ĸ���λ���м���λ,D21,D20,D19.D22Ϊ1,����;D18����Flag_XH_LSB��.
//    //RF_ShiftL2(RD0);
//    // x�ĸ�λ���:
//    RD0=M[RA0+RD0];
//
//    // ����xh��LSBλ,ȡ�������L16,H16:
//    if(Flag_XH_LSB==1) goto L_Sqrt2_1;
//    M[RA1+L16Bit_ToFloat]=RD0;
//    goto L_Sqrt2_2;
//L_Sqrt2_1:
//    M[RA1+H16Bit_ToFloat]=RD0;
//L_Sqrt2_2:
//    RD0=M[RA1+Read_Float];                          // 1/xh=RD0*order(-1)
//
//////////////////////////////////////////////////////////////
//    // ����b=Xl*(1/Xh):
//    RF_ShiftL2(RD1);                                // ��xl������λ,�Ա������˷�����ʱ��������
//    RF_ShiftL2(RD1);                                // a=1/xh=RD0*order(-5)
//    Multi24_X=RD1;
//    Multi24_Y=RD0;
//    nop;
//    RD1=Multi24_XY;                                      // b=Xl*(1/Xh)=RD1*order(-5)
//    RD2=RD1;                                        // b=Xl*(1/Xh)=RD4*order(-5)
//
//    // ����b*4,����b������λ:
//    RF_ShiftL2(RD1);                                // b*4=RD1*order(-5)
//
//    // ����8+b*4:
//    RD0=0;
//    RD0_SetBit30;                                   // 1=RD0*order(-5)
//    RD0+=RD1;                                       // (8+b*4)=RD0*order(-5)
//
//    // ����b^2:
//    RD1=RD2;
//    Multi24_X=RD1;
//    Multi24_Y=RD1;
//    nop;
//    RD1=Multi24_XY;                                      // b^2=RD0*order(-9)=RD0*2^(-4)*order(-5)
//
//    // ��b^2������λ:
//    RF_ShiftR2(RD1);
//    RF_ShiftR2(RD1);                                // (b^2)=RD0*order(-5)
//
//
//    //����(8+b*4-b^2):
//    RD0-=RD1;                                       // (8+b*4-b^2)=RD0*order(-5)
//
//    //��Ϊ(8+b*4-b^2)��D30λ��1,�˷����޷�����,������8λ.
//    RF_ShiftR2(RD0);
//    RF_ShiftR2(RD0);
//    RF_ShiftR2(RD0);
//    RF_ShiftR2(RD0);                                // (8+b*4-b^2)=RD0*order(3)
//
//    //����a*(8+b*4-b^2):
//    RD1=RD3;
//    Multi24_X=RD1;
//    Multi24_Y=RD0;
//    nop;
//    RD0=Multi24_XY;                                      // a*(8+b*4-b^2)=RD0*order(4),��ΪSqrt(x)=a*(8+b*4-b^2)/8,����Sqrt(x)=RD0*order(1).
//    RF_ShiftL2(RD0);                                // Sqrt(x)=RD0*order(-1)
//
//    Return_AutoField (0);
//

////////////////////////////////////////////////////////
//  ����:
//      _Ln
//  ����:
//      ��ln; z=ln(x),x=xh+xl,a=ln(xh),b=xl/xh,z=a+b-b^2/2+b^3/3;
//  ����:
//      1.RD1:x,24BIT FLOAT,����Ϊ��һ����ʽ����;
//  ����ֵ:
//      1.RD0:ln(x);
//  ע��:
//      1.����b֮ǰ��Ҫ��xl������λ,�Ա�֤����˷�����ľ���;
//      2.����Ӽ���ʱ��Ҫ���������ݵ�orderͳһ,���㷨����ʱ��orderͳһΪ-9;
//      3.�˷�����ʱ�豣֤D23λ������λΪ����λ,�˷�ǰ�轫����������λ1����D22λ,������order.
//      4.����Ϊ��һ����ʽ������: x������,b23=0,b22=1;
//      5.���������Ϊ��һ����ʽ,���øú���ǰ,���x���е�����һ��;
//      6.�ú������������,���ⲿ���м���.
////////////////////////////////////////////////////////
Sub_AutoField _Ln;
    push RD4;

L_aaa:
    RD0 = RN_Addr_Float;
    RA1 = RD0;                                 // ��������ʽ��������ַ
    RD0 = RN_Addr_Ln;
    RA0 = RD0;                                   // Ln��ROM��ַ

//////////////////////////////////////////////////////////
////����ln(Xh)
    // ��x�ֽ�ɸߵ�������:
    M[RA1+L24Bit_ToFloat]=RD1;
    RD0=M[RA1+Read_Float_H];                        // RD0=x�ĸ���λ���м���λ,D21,D20,D19.D22Ϊ1,����;D18����Flag_XH_LSB��.
    //RF_ShiftL2(RD0);
    // x�ĸ�λ���:
    RD0=M[RA0+RD0];

    // ����x��D18,ȡ�������L16,H16
    if(Flag_XH_LSB==1) goto L_Ln_1;                 // FLAG_FLOAT��D18
    M[RA1+L16Bit_ToFloat]=RD0;
    goto L_Ln_2;
L_Ln_1:
    M[RA1+H16Bit_ToFloat]=RD0;
L_Ln_2:
    RD0=M[RA1+Read_Float];                          // a=ln(xh)=RD0*order(-1)
    RD3=RD0;                                        // a=ln(Xh)=RD3*order(-1)

////////////////////////////////////////////////////////////
////����1/xh
    RD0 = RN_Addr_Recip;
    RA0 = RD0;                              // ����ROM��ַ
    M[RA1+L24Bit_ToFloat]=RD1;
    RD1=M[RA1+Read_Float_L];                        // xl=RD1*order(-1),xl��x�ĵ�18λ
    RD0=M[RA1+Read_Float_H];                        // RD0=x�ĸ���λ���м���λ,D21,D20,D19.D22Ϊ1,����;D18����Flag_XH_LSB��.
    //RF_ShiftL2(RD0);

    // x�ĸ�λ���:
    RD0=M[RA0+RD0];
    // ����xh��LSBλ,ȡ�������L16,H16:
    if(Flag_XH_LSB==1) goto L_Ln2_1;
    M[RA1+L16Bit_ToFloat]=RD0;
    goto L_Ln2_2;
L_Ln2_1:
    M[RA1+H16Bit_ToFloat]=RD0;
L_Ln2_2:
    RD0=M[RA1+Read_Float];                          // 1/xh=RD0*order(-1)

////////////////////////////////////////////////////////////
    // ����b=Xl*(1/Xh):
    RF_ShiftL2(RD1);                                // ��xl������λ,�Ա������˷�����ʱ��������
    RF_ShiftL2(RD1);                                // 1/xh=RD0*order(-5)

    Multi24_X=RD1;
    Multi24_Y=RD0;
    nop;
    RD1=Multi24_XY;                                      // b=Xl*(1/Xh)=RD1*order(-5)
    RD2=RD1;                                        // b=Xl*(1/Xh)=RD2*order(-5)

    // ����a+b
    RD0=RD3;
    RF_ShiftL2(RD1);
    RF_ShiftL2(RD1);                                // b=Xl*(1/Xh)=RD1*order(-9)
    RF_ShiftL2(RD0);
    RF_ShiftL2(RD0);
    RF_ShiftL2(RD0);
    RF_ShiftL2(RD0);                                // a=ln(Xh)=RD0*order(-9)
    RD0+=RD1;                                       // a+b=RD0*order(-9)

    // ����b^2:
    RD1=RD2;
    Multi24_X=RD1;
    Multi24_Y=RD1;
    nop;
    RD1=Multi24_XY;                                      // b^2=RD1*order(-9)
    RD3=RD1;                                        // b^2=RD3*order(-9)

    // ����b^2/2:
    RF_ShiftR1(RD1);                                // b^2/2=RD1*order(-9)

    // ����(a+b)-b^2/2:
    RD0-=RD1;                                       // (a+b)-b^2/2=RD0*order(-9)
    RD4=RD0;

    // ����b^3:
    RD1=RD2;                                        // b=RD2*order(-5)
    RD0=RD3;                                        // b^2=RD3*order(-9)
    Multi24_X=RD1;
    Multi24_Y=RD1;
    nop;
    RD1=Multi24_XY;                                      // b^3=RD1*order(-13)

    // ����b^3/3:
    RD0=0;
    RD0_SetBit21;
    RD0_SetBit19;
    RD0_SetBit17;
    RD0_SetBit15;
    RD0_SetBit13;
    RD0_SetBit11;
    RD0_SetBit9;                                    // 1/3=RD0*order(-1)
    Multi24_X=RD1;
    Multi24_Y=RD0;
    nop;
    RD1=Multi24_XY;                                      // b^3/3=RD1*order(-13)

    // ����(a+b-b^2/2)+b^3/3
    RF_ShiftR2(RD1);
    RF_ShiftR2(RD1);                                // b^3/3=RD1*order(-9)
    RD0=RD4;
    RD0+=RD1;                                       // Ln(x)=a+b-b^2/2+b^3/3=RD0*order(-9)
    RF_ShiftR2(RD0);
    RF_ShiftR2(RD0);
    RF_ShiftR2(RD0);
    RF_ShiftR2(RD0);                                // Ln(x)=a+b-b^2/2+b^3/3=RD0*order(-1)

    pop RD4;
    Return_AutoField (0);



////////////////////////////////////////////////////////
//  ����:
//      _Lg
//  ����:
//      ����10Ϊ�׵Ķ�������; z=lg(x),z=ln(x)/ln(10),z=ln(x)*1/ln(10);
//  ����:
//      1.RD1:x,24BIT FLOAT,����Ϊ��һ����ʽ����;
//  ����ֵ:
//      1.RD0: lg(x);
//  ע��:
//      1.����Ϊ��һ����ʽ������: x������,b23=0,b22=1;
//      2.���������Ϊ��һ����ʽ,���øú���ǰ,���x���е�����һ��;
//      3.�ú������������,���ⲿ���м���;
////////////////////////////////////////////////////////
Sub_AutoField _Lg;

    // ����ln(x):
    call _Ln;                                       // ln(x) = RD0*order(-1)
    RD2=RD0;

    // ����1/ln(10)
    RD0=0;
    RD0_SetBit21;
    RD0_SetBit20;
    RD0_SetBit18;
    RD0_SetBit17;
    RD0_SetBit16;
    RD0_SetBit15;
    RD0_SetBit12;
    RD0_SetBit10;
    RD0_SetBit9;
    RD0_SetBit8;                                    // 1/ln(10)=(0.011011110010111)2=RD0*order(-1)

    // ����z=ln(x)*1/ln(10):
    Multi24_X=RD0;
    RD0=RD2;
    Multi24_Y=RD0;
    nop;
    RD0=Multi24_XY;                                      // z=z=ln(x)*1/ln(10)=RD0*order(-1)

    Return_AutoField(0);

////////////////////////////////////////////////////////////
////  ����:
////      _Log2
////  ����:
////      ����2Ϊ�׵Ķ�������; z=log2(x),z=ln(x)/ln(2),z=ln(x)*1/ln(2);
////  ����:
////      1.RD1:x,24BIT FLOAT,����Ϊ��һ����ʽ����;
////  ����ֵ:
////      1.RD0: log2(x);
////  ע��:
////      1.����Ϊ��һ����ʽ������: x������,b23=0,b22=1;
////      2.���������Ϊ��һ����ʽ,���øú���ǰ,���x���е�����һ��;
////      3.�ú������������,���ⲿ���м���;
////////////////////////////////////////////////////////////
//Sub_AutoField _Log2;
//
//    // ����ln(x):
//    call _Ln;                                       // ln(x) = RD0*order(-1)
//    RD2=RD0;
//
//    // ����1/ln(2)
//    RD0=0;
//    RD0_SetBit22;
//    RD0_SetBit20;
//    RD0_SetBit19;
//    RD0_SetBit18;
//    RD0_SetBit14;
//    RD0_SetBit12;
//    RD0_SetBit10;
//    RD0_SetBit8;                                    // 1/ln(2)=(1.01110001010101)2=RD0*order(0)
//
//    // ����z=ln(x)*1/ln(10):
//    Multi24_X=RD0;
//    RD0=RD2;
//    Multi24_Y=RD0;
//    nop;
//    RD0=Multi24_XY;                                      // z=z=ln(x)*1/ln(10)=RD0*order(0)
//    RF_ShiftL1(RD0);                                // z=z=ln(x)*1/ln(10)=RD0*order(-1)
//
//    Return_AutoField(0);



////////////////////////////////////////////////////////////
////  ����:
////      _2Power
////  ����:
////      ��2���ݺ���; z=2^x,x=xh+xl,a=2^xh,b=xl,z=a+a*b*ln2+a*b^2*(ln2)^2/2+a*b^3*(ln2)^3/6;
////  ����:
////      1.RD1:x,24BIT FLOAT,����Ϊ��һ����ʽ;
////  ����ֵ:
////      1.RD0: 2^x,order=1;
////  ע��:
////      1.�˷�����ʱ�豣֤D23λ������λΪ����λ,�˷�ǰ�轫����������λ1����D22λ,������order.
////      2.����Ϊ��һ����ʽ������: x������,b23=0,b22=1;x�Ǹ���,b23=1,b22=0;;x��0,b23=0,b22=0;
////      3.���������Ϊ��һ����ʽ,���øú���ǰ,���x���е�����һ��;
////      4.�ú������������,���ⲿ���м���.
////////////////////////////////////////////////////////////
//Sub_AutoField _2Power;
//
//    RD0 = RN_Addr_Float;
//    RA1 = RD0;                                                             // ��������ʽ��������ַ
//    RD0 = RN_Addr_2Power;
//    RA0 = RD0;                                                            // ƽ����ROM��ַ
//
//    RD5=0x58B90B;                                                                   //  ln2 = RD5*order(-1)
//
//    // �ж�x������
//    RD0 = RD1;
//    RD3 = RD1;
//    if(RD0_Bit23==0) goto L_2Power_0;
//    RF_Neg(RD0);
//    RD1=RD0;
//L_2Power_0:
////////////////////////////////////////////////////////////
//////����2^(Xh)
//    // ��x�ֽ�ɸߵ�������:
//    M[RA1+L24Bit_ToFloat]=RD1;
//    RF_ShiftL1(RD0);
//    RD1 = 0X7FFFF;
//    RD1 &= RD0;
//    //RD1=M[RA1+Read_Float_L];                                              // b=xl=RD1*order(-1)
//    RD2 = RD1;
//    RD0=M[RA1+Read_Float_H];                                                // RD0=x�ĸ���λ���м���λ,D21,D20,D19.D22Ϊ1,����;D18?���Flag_XH_LSB��.
//    //RF_ShiftL2(RD0);
//    // x�ĸ�λ���:
//    RD0=M[RA0+RD0];
//
//    // ����x��D18,ȡ�������L16,H16
//    if(Flag_XH_LSB==1) goto L_2Power_1;                          // FLAG_FLOAT��D18
//    M[RA1+L16Bit_ToFloat]=RD0;
//    goto L_2Power_2;
//L_2Power_1:
//    M[RA1+H16Bit_ToFloat]=RD0;
//L_2Power_2:
//    RD0=M[RA1+Read_Float];                                                  // a=2^(xh)=RD0*order(1)
//    RD4=RD0;                                                                                // a=2^(Xh)=RD0*order(1)
//
//    //����a*b*ln2
//    Multi24_X=RD0;
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                  // a*b=RD0*order(1)
//    Multi24_X=RD0;
//    RD1 = RD5;
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                  // a*b*ln2=RD0*order(1)
//    RD1 = RD4;
//    RD0 += RD1;
//    RD6 = RD0;                                                                              //a+a*b*ln2=RD0*order(1)
//
//    //����a*b^2*(ln2)^2/2
//    RD0 = RD4;                                                                              //  a=2^(xh)=RD0*order(1)
//    Multi24_X=RD0;
//    RD1 = RD2;
//    Multi24_Y=RD1;                                                                      //  b=RD1*order(-1)
//    nop;
//    RD0=Multi24_XY;                                                                  // a*b=RD0*order(1)
//    Multi24_X=RD0;
//    RD1 = RD2;
//    Multi24_Y=RD1;                                                                      //  b=RD1*order(-1)
//    nop;
//    RD0=Multi24_XY;                                                                  // a*b*b=RD0*order(1)
//    Multi24_X=RD0;
//    RD1 = RD5;                                                                              //  ln2=RD1*order(-1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                  // a*b*b*ln2=RD0*order(1)
//    Multi24_X=RD0;
//    RD1 = RD5;                                                                              //  ln2=RD1*order(-1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                  // a*b*b*ln2*ln2=RD0*order(1)
//    RF_ShiftR1(RD0);                                                                    //  a*b*b*ln2*ln2/2=RD0*order(1)
//    RD1 = RD6;
//    RD0 += RD1;                                                                             //  a+a*b*ln2+a*b*b*ln2*ln2/2=RD0*order(1)
//    RD6 = RD0;
//
//    //����a*b^3*(ln2)^3/6
//    RD0 = RD4;                                                                              //  a=2^(xh)=RD0*order(1)
//    Multi24_X=RD0;
//    RD1 = RD2;
//    Multi24_Y=RD1;                                                                      //  b=RD1*order(-1)
//    nop;
//    RD0=Multi24_XY;                                                                  // a*b=RD0*order(1)
//    Multi24_X=RD0;
//    RD1 = RD2;
//    Multi24_Y=RD1;                                                                      //  b=RD1*order(-1)
//    nop;
//    RD0=Multi24_XY;                                                                  // a*b*b=RD0*order(1)
//    Multi24_X=RD0;
//    RD1 = RD2;
//    Multi24_Y=RD1;                                                                      //  b=RD1*order(-1)
//    nop;
//    RD0=Multi24_XY;                                                                  // a*b*b*b=RD0*order(1)
//    Multi24_X=RD0;
//    RD1 = RD5;                                                                              //  ln2=RD1*order(-1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b*b*ln2=RD0*order(1)
//    Multi24_X=RD0;
//    RD1 = RD5;                                                                              //  ln2=RD1*order(-1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b*b*ln2*ln2=RD0*order(1)
//    Multi24_X=RD0;
//    RD1 = RD5;                                                                              //  ln2=RD1*order(-1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b*b*ln2*ln2*ln2=RD0*order(1)
//    Multi24_X=RD0;
//    RD0 = 0x155555;                                                                     //  1/6=RD1*order(-1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b*b*ln2*ln2*ln2/6=RD0*order(1)
//    RD1 = RD6;
//    RD0 += RD1;                                                                             //  a+a*b*ln2+a*b*b*ln2*ln2/2+a*b*b*b*ln2*ln2*ln2/6=RD0*order(1)
//    RD2 = RD0;
//
//    // �ж�x������
//    RD0 = RD3;
//    if(RD0_Bit23==0) goto L_2Power_End;
//    RD1 = RD2;
//    call _Recip;
//    RF_ShiftR2(RD0);
//    RF_ShiftR1(RD0);
//    RD2 = RD0;
//L_2Power_End:
//    RD0 = RD2;
//    Return_AutoField (0);


////////////////////////////////////////////////////////////
////  ����:
////      _10Power
////  ����:
////      ��10���ݺ���; z=2^x,x=xh+xl,a=2^xh,b=xl,z=a+a*b*ln10+a*b^2*(ln10)^2/2+a*b^3*(ln10)^3/6;
////  ����:
////      1.RD0:x,24BIT FLOAT������Ϊ����ֵС��1�Ĺ�һ����ʽ;
////  ����ֵ:
////      1.RD0: 10^x,������;
////  ע��:
////      1.�˷�����ʱ�豣֤D23λ������λΪ����λ,�˷�ǰ�轫����������λ1����D22λ,������order.
////      2.����Ϊ����ֵС��1�Ĺ�һ����ʽ������:-1<x<1;x������,b23=0,b22=0;x�Ǹ���,b23=1,b22=1;
////      3.���������Ϊ��һ����ʽ,���øú���ǰ,���x���е�����һ��;
////      4.����2^-14;
////////////////////////////////////////////////////////////
//Sub_AutoField _10Power;
//    RD1=RN_Addr_Float;
//    RA1 = RD1;                                                               // ��������ʽ��������ַ
//    RD1 = RN_Addr_10Power;
//    RA0 = RD1;                                                          // ƽ����ROM��ַ
//
//    RD5=0x49AEC6;                                                                   //  ln10 = RD5*order(1)
//
//    // �ж�x������
//    RD1 = RD0;
//    RD3 = RD1;
//    if(RD0_Bit23==0) goto L_10Power_0;
//    RF_Neg(RD0);
//    RD1=RD0;
//    RD0 = RD3;
//    RF_GetH8(RD0);
//    RD0-=0X80;
//    if(RQ>=0)  goto L_10Power_0;
//    RD0 = 0XFC666666;
//    RD2 = RD0;
//    goto L_10Power_End;
//
//L_10Power_0:
//    RD0 = RD3;
//    RF_GetH8(RD0);
//    RD2 = RD0;
//    RD0 = 0x100;
//    RD0 -= RD2;
//    RD2 = RD0;
//    RD0 = RD1;
//    RD0_ClrByteH8;                                                                              //  RD0��8λ��0
//    RD1 = RD0;
//    RD0 = RD2;
//L_10Power_10:
//    RD0--;
//    RF_ShiftR1(RD1);
//    if(RD0!=0) goto L_10Power_10;
//    RD4 = RD1;
////////////////////////////////////////////////////////////
//////����10^(Xh)
//    // ��x�ֽ�ɸߵ�������:
//    RD0 = RD1;
//    RF_ShiftL1(RD0);
//    RD1 = 0X7FFFF;
//    RD0 &= RD1;                                                                         // b=xl=RD1*order(-1)
//    RF_ShiftL2(RD0);                                                                // ��xl������λ,�Ա������˷�����ʱ��������
//    RF_ShiftL2(RD0);                                                                // b=xl=RD1*order(-5)
//    RD1 = RD0;
//    RD2 = RD1;
//
//    // ʹ���ֽڱ���ROMʱ�������¶γ���
//    //RD0 = RD4;
//    //RD0_ClrByteH8;                                                                              //  RD0��8λ��0
//    //RF_RotateR16(RD0);
//    //RD0_ClrByteH16;
//
//    // ʹ��Dword����ROMʱ�������¶γ���                                                                          //  RD0��8λ��0
//    RD0 = RD4;
//    RF_RotateL8(RD0);
//    RF_GetH8(RD0);
//    RF_ShiftR2(RD0);
//    RD0_ClrBit19;
//
//    RD0=M[RA0+RD0];                                                                 // a=10^(xh)=RD0*order(3)
//    RD4=RD0;                                                                                // a=10^(Xh)=RD0*order(3)
//
//    //����a*b*ln10
//    Multi24_X=RD0;
//    Multi24_Y=RD1;                                                                      //  b=xl=RD1*order(-5)
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b=RD0*order(-1)
//    Multi24_X=RD0;
//    RD1 = RD5;                                                                              //  ln10 = RD5*order(1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*ln10=RD0*order(1)
//    RF_ShiftR2(RD0);                                                                    //  a*b*ln10=RD0*order(3)
//    RD1 = RD4;
//    RD0 += RD1;
//    RD6 = RD0;                                                                              //  a+a*b*ln10=RD0*order(3)
//
//    //����a*b^2*(ln2)^2/2
//    RD0 = RD4;                                                                              //  a=10^(xh)=RD0*order(3)
//    Multi24_X=RD0;
//    RD1 = RD2;
//    Multi24_Y=RD1;                                                                      //  b=xl=RD1*order(-5)
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b=RD0*order(-1)
//    Multi24_X=RD0;
//    RD1 = RD2;
//    Multi24_Y=RD1;                                                                      //  b=xl=RD1*order(-5)
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b=RD0*order(-5)
//    Multi24_X=RD0;
//    RD1 = RD5;                                                                              //  ln10=RD1*order(1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b*ln2=RD0*order(-3)
//    Multi24_X=RD0;
//    RD1 = RD5;                                                                              //  ln10=RD1*order(1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b*ln10*ln10=RD0*order(-1)
//    RF_ShiftR1(RD0);
//    RF_ShiftR2(RD0);
//    RF_ShiftR2(RD0);                                                                    //  a*b*b*ln10*ln10/2=RD0*order(3)
//    RD1 = RD6;
//    RD0 += RD1;                                                                             //  a+a*b*ln10+a*b*b*ln10*ln10/2=RD0*order(3)
//    RD6 = RD0;
//
//    //����a*b^3*(ln2)^3/6
//    RD0 = RD4;                                                                              //  a=10^(xh)=RD0*order(3)
//    Multi24_X=RD0;
//    RD1 = RD2;
//    Multi24_Y=RD1;                                                                      //  b=xl=RD1*order(-5)
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b=RD0*order(-1)
//    Multi24_X=RD0;
//    RD1 = RD2;
//    Multi24_Y=RD1;                                                                      //  b=xl=RD1*order(-5)
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b=RD0*order(-5)
//    Multi24_X=RD0;
//    RD1 = RD2;
//    Multi24_Y=RD1;                                                                      //  b=xl=RD1*order(-5)
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b*b=RD0*order(-9)
//    Multi24_X=RD0;
//    RD1 = RD5;                                                                              //  ln10=RD1*order(1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b*b*ln2=RD0*order(-7)
//    Multi24_X=RD0;
//    RD1 = RD5;                                                                              //  ln10=RD1*order(1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b*b*ln10*ln10=RD0*order(-5)
//    Multi24_X=RD0;
//    RD1 = RD5;                                                                              //  ln10=RD1*order(1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b*b*ln10*ln10*ln10=RD0*order(-3)
//    Multi24_X=RD0;
//    RD0 = 0x155555;                                                                     //  1/6=RD0*order(-1)
//    Multi24_Y=RD1;
//    nop;
//    RD0=Multi24_XY;                                                                     //  a*b*b*b*ln2*ln2*ln2/6=RD0*order(-3)
//    RF_ShiftR2(RD0);
//    RF_ShiftR2(RD0);
//    RF_ShiftR2(RD0);                                                                    //  a*b*b*b*ln2*ln2*ln2/6=RD0*order(3)
//    RD1 = RD6;
//    RD0 += RD1;                                                                             //  a+a*b*ln10+a*b*b*ln10*ln10/2+a*b*b*b*ln10*ln10*ln10/6=RD0*order(3)
//    RD2 = RD0;
//
//    RD0=3;
//    RF_RotateR8(RD0);
//    RD0+=RD2;
//    call _Stan;
//    RD2 = RD0;
//    // �ж�x������
//    RD0 = RD3;
//    if(RD0_Bit23==0) goto L_10Power_End;
//    RD0=RD2;
//    call _Float_Recip;
//    RD2 = RD0;
//L_10Power_End:
//    RD0 = RD2;
//    Return_AutoField (0);




////////////////////////////////////////////////////////
//  ����:
//      sqrt_fix
//  ����:
//      ���㿪����
//  ����:
//      1.RD0: ����
//  ����ֵ:
//      1.RD0: ���
////////////////////////////////////////////////////////
Sub_AutoField sqrt_fix;
    push RD4;
    push RD5;
    push RD6;

#define E  RD4
#define MM RD5
#define x  RD6

    x = RD0;

    // E = log2_cpu(x) + 1;
    RF_Log(RD0);
    RD0 ++;
    E = RD0;

    // if ((E - 1) > index)
    RD1 = 8;
    RD1 -= RD0;
    if(RQ<0) goto L_sqrt_fix_0;

    // else if ((E - 1) < index)
    RD1 = 8;
    RD1 -= RD0;
    if(RQ>0) goto L_sqrt_fix_1;

    // M = x;
    RD0 = x;
    MM = RD0;
    goto L_sqrt_fix_2;

L_sqrt_fix_0:
    // M = x >> (E - 1 - index);
    RD0 = x;
    RD1 = E;
    RD1 -= 8;
    call _Rf_ShiftR_Reg;
    MM = RD0;
    goto L_sqrt_fix_2;

L_sqrt_fix_1:
    // M = x << (index + 1 - E);
    RD0 = x;
    RD1 = 8;
    RD1 -= E;
    call _Rf_ShiftL_Reg;
    MM = RD0;

    // if ((M & 0x1) == 1)
L_sqrt_fix_2:
    RD0 = MM;

    if(RD0_Bit0 == 0) goto L_sqrt_fix_3;
    // M += 2;
    MM += 2;

L_sqrt_fix_3:


    // M = M >> 1;
    RD0 = MM;
    RF_ShiftR1(RD0);
    MM = RD0;
    goto L_sqrt_fix_4;


L_sqrt_fix_4:


    // if (E & 0x1 == 1)
    RD0 = E;
    if(RD0_Bit0 == 0) goto L_sqrt_fix_5;
    // E = E + 1;
    E ++;
    // M = M >> 1;
    RF_ShiftR1(MM);

L_sqrt_fix_5:
    // E = E >> 1;
    RF_ShiftR1(E);


    // if (M == N)
    RD1 = MM;
    RD1 -= 128;
    if(RQ_nZero) goto L_sqrt_fix_6;
    // M -= 1;
    MM --;

L_sqrt_fix_6:
    RD0 = MM;


    RF_ShiftL1(RD0);
    RD1 = RN_Sqrt_Table_ADDR;
    RF_GetL16(RD1);
    RF_ShiftL2(RD1);
    RD0 += RD1;
    call ConstROM_Read_Word;

    RD1 = E;
    call _Rf_ShiftL_Reg;

#undef E
#undef MM
#undef x

    pop RD6;
    pop RD5;
    pop RD4;

    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      log2_fix
//  ����:
//      ������log2
//  ����:
//      1.RD0: ����
//  ����ֵ:
//      1.RD0: �����q15��
////////////////////////////////////////////////////////
Sub_AutoField log2_fix;

    push RD4;
    push RD5;
    push RD6;

#define E  RD4
#define MM RD5
#define x  RD6

    x = RD0;

    // 1. ����E��M�����ݹ�ʽ x = 2^E * M,  EΪ������ �� MΪ[0.5~1]����
    // E = log2(x) + 1;             // �����CPUָ��֧��
    RF_Log(RD0);
    RD0 ++;
    E = RD0;

    // if (E > index)
    RD1 = 8;
    RD1 -= RD0;
    if(RQ<0) goto L_log2_fix_0;

    // else if (E < index)
    RD1 = 8;
    RD1 -= RD0;
    if(RQ>0) goto L_log2_fix_1;

    // M = x - N;
    RD0 = x;
    RD0 -= 128;
    MM = RD0;
    goto L_log2_fix_2;

L_log2_fix_0:
    // M = (x >> (E-index)) - N;
    RD0 = x;
    RD1 = E;
    RD1 -= 8;
    call _Rf_ShiftR_Reg;
    RD0 -= 128;
    MM = RD0;
    goto L_log2_fix_2;

L_log2_fix_1:
    // M = (x << (index - E)) - N;
    RD0 = x;
    RD1 = 8;
    RD1 -= E;
    call _Rf_ShiftL_Reg;
    RD0 -= 128;
    MM = RD0;

L_log2_fix_2:
    // 2. ��MΪ��ַ��ȡ���
    //rst = (E<<15) + log2_table[M];
    RD0 = E;
    RD1 = 15;
    call _Rf_ShiftL_Reg;
    RD2 = RD0;

    RD0 = MM;
    RF_ShiftL1(RD0);
    RD1 = RN_Log2_Table_ADDR;
    RF_GetL16(RD1);
    RF_ShiftL2(RD1);
    RD0 += RD1;
    call ConstROM_Read_Word;
    RD0 += RD2;

#undef E
#undef MM
#undef x

    pop RD6;
    pop RD5;
    pop RD4;

    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      power_fix
//  ����:
//      ������Power = 10^(RD0/10)
//  ����:
//      1.RD0: ����
//  ����ֵ:
//      1.RD0: �����32q8��
////////////////////////////////////////////////////////
Sub_AutoField power_fix;

    push RD4;
    push RD5;
    push RD6;
    push RD7;

#define E  RD4
#define MM RD5
#define x  RD6
#define r  RD7

    x = RD0;

    // 1. ����x = Level*0.33219 = (Level*10885)/Q15
    // x = level * 10885;
//    RD0 = 10885;
//    Multi24_X=RD0;
//    RD0 = x;
//    Multi24_Y=RD0;
//    nop;
//    RD0=Multi24_XY;
//    RD0_ClrByteH8;
    //x = RD0;

    RD1 = 10885;
    call _Rs_Multi;

    //x >>= 15;
    RD1 = 15;
    call _Rf_ShiftR_Reg;
    x = RD0;

    // 2. ����E��r�����ݹ�ʽ x = (E+1) + (r-1),  EΪ������ �� rΪ[0,1)����
    // E = (x >> 8) + 1;               // x��16q8����8λΪС��
    //RD0 = x;
    RD1 = 8;
    call _Rf_ShiftR_Reg;
    RD0 ++;
    E = RD0;

    // r = x & 0xFF;
    RD0 = x;
    RF_GetL8(RD0);
    r = RD0;

    //  if ((r & 0x1) == 1)         // ��bit0�Ƿ�Ϊ1
    if(RD0_Bit0 == 0) goto L_power_fix_0;
    //r += 2;
    r += 2;

L_power_fix_0:
    //r = r >> 1;                   // ��ʣ�µ�1
    RF_ShiftR1(r);

    // ���r==N,r-=1
    // if (r == N)
    RD1 = 128;
    RD1 -= r;
    if(RQ_nZero) goto L_power_fix_1;
    // r -= 1;
    r --;
L_power_fix_1:

    // 2. ��MΪ��ַ��ȡ���
    //rst = (1 << E) * exp2_table[r];
    RD0 = E;
    RF_Exp(RD0);
    RD2 = RD0;

    RD0 = r;
    RF_ShiftL1(RD0);
    RD1 = RN_Pow2_Table_ADDR;
    RF_GetL16(RD1);
    RF_ShiftL2(RD1);
    RD0 += RD1;
    call ConstROM_Read_Word;
    RD1 = RD2;

    call _Rs_Multi;
//    Multi24_X=RD1;
//    //RD0 = x;
//    Multi24_Y=RD0;
//    nop;
//    RD0=Multi24_XY;
//    RD0_ClrByteH8;

#undef E
#undef MM
#undef x
#undef r

    pop RD7;
    pop RD6;
    pop RD5;
    pop RD4;

    Return_AutoField(0);



////////////////////////////////////////////////////////
//  ����:
//      recip_fix_Q7
//  ����:
//      ��������
//  ����:
//      1.RD0: ����(q7)
//  ����ֵ:
//      1.RD0: �����q7��
////////////////////////////////////////////////////////
Sub_AutoField recip_fix_Q7;
    call recip_fix;
    RF_ShiftR2(RD0);
    RF_ShiftR2(RD0);
    RF_ShiftR2(RD0);
    RF_ShiftR2(RD0);
    RF_ShiftR1(RD0);
    Return_AutoField(0);
////////////////////////////////////////////////////////
//  ����:
//      recip_fix
//  ����:
//      ��������
//  ����:
//      1.RD0: ����(q0)
//  ����ֵ:
//      1.RD0: �����q23��
////////////////////////////////////////////////////////
Sub_AutoField recip_fix;

    push RD4;
    push RD5;
    push RD6;

#define E  RD4
#define MM RD5
#define x  RD6

    RD2 = 0;
    if(RD0_Bit31 == 0) goto L_recip_fix_2;
    RD2 = 1;
    RF_Not(RD0);
    RD0 ++;
L_recip_fix_2:
    // 1. ����E��M�����ݹ�ʽ x = 2^E * M,  EΪ������ �� MΪ[0.5~1)����
    // E = log2(x);                 // �����CPUָ��֧��
    x = RD0;
    RF_Log(RD0);
    E = RD0;

    // M = x << index;                 // �����Ż�����λ
    RD0 = x;
    RD1 = 8;
    call _Rf_ShiftL_Reg;
    MM = RD0;

    // M = M >> (E);                   // ����log2(x)-1    Ŀ������������
    RD0 = MM;
    RD1 = E;
    call _Rf_ShiftR_Reg;
    MM = RD0;

    // if ((M & 0x1) == 1)             // ��bit0�Ƿ�Ϊ1
    if(RD0_Bit0 == 0) goto L_recip_fix_0;
    // M += 2;
    MM += 2;

L_recip_fix_0:
    // M = (M >> 1) - 128;                 // ��ʣ�µ�1
    RD0 = MM;
    RF_ShiftR1(RD0);
    RD0 -= 128;
    MM = RD0;

    // 2. ��MΪ��ַ��ȡ���
    // ���M==N,M-=1
    // if (M == N)
    RD1 = 128;
    RD0 = MM;
    RD1 -= RD0;
    if(RQ_nZero) goto L_recip_fix_1;
    // M -= 1;
    MM --;

L_recip_fix_1:
    // rst = recip_table[M] >> (E);
    RD0 = MM;
    RD1 = RN_Recip_Table_ADDR;
    RA0 = RD1;
    RD0 = M[RA0+RD0];

    RD1 = E;
    call _Rf_ShiftR_Reg;

#undef E
#undef MM
#undef x
    RD1 = 1;
    RD1 ^= RD2;
    if(RQ_nZero) goto L_recip_fix_End;
    RF_Not(RD0);
    RD0 ++;
L_recip_fix_End:

    pop RD6;
    pop RD5;
    pop RD4;

    Return_AutoField(0);

END SEGMENT
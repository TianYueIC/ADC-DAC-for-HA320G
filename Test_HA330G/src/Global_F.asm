#define _GLOBAL_F_

#include <CPU11.def>
#include <resource_allocation.def>
#include <RN_DSP_Cfg.def>
#include <DMA_ParaCfg.def>
#include <DMA_ALU.def>
#include <Global.def>
#include <SOC_Common.def>
#include <Global.def>
#include <ALU.def>
#include <USI.def>
#include <SPI_Master.def>

CODE SEGMENT GLOBAL_F;
////////////////////////////////////////////////////////
//  名称:
//      RAM_Read_Word
//  功能:
//      用于读取16比特数据，代替MMU功能
//  参数:
//      1.RD0:数据地址
//  返回值:
//      1.RD0:16比特数据
////////////////////////////////////////////////////////
Sub RAM_Read_Word;
    push RA0;
    RA0 = RD0;
    if(RD0_Bit1==1) goto L_RAM_Read_Word_1;
    RD0 = M[RA0];
    RF_GetL16(RD0);
    goto L_RAM_Read_Word_End;

L_RAM_Read_Word_1:
    RD0 = M[RA0];
    RF_GetH16(RD0);

L_RAM_Read_Word_End:
    RD0_SignExtL16;
    pop RA0;
    Return(0);



////////////////////////////////////////////////////////
//  名称:
//      BaseROM_Read_Word
//  功能:
//      从ConstROM用于读取16比特数据，代替MMU功能
//  参数:
//      1.RD0:数据地址(字节地址)
//  返回值:
//      1.RD0:16比特数据
////////////////////////////////////////////////////////
Sub ConstROM_Read_Word;
    push RA0;

    push RD0;
    RD0_ClrByteH8;
    RF_ShiftR2(RD0);
    RD0 += 0xD0000000;
    RA0 = RD0;
    RD1 = M[RA0];
    pop RD0;
    if(RD0_Bit1==1) goto L_ConstROM_Read_Word_1;
    RF_GetL16(RD1);
    goto L_ConstROM_Read_Word_End;

L_ConstROM_Read_Word_1:
    RF_GetH16(RD1);

L_ConstROM_Read_Word_End:
    RD0 = RD1;
    RD0_SignExtL16;
    pop RA0;
    Return(0);



////////////////////////////////////////////////////////
//  名称:
//      SetADBuf0_Flow
//  功能:
//      将AD_Buf0切回Flow通道
//  参数:
//      无
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField SetADBuf0_Flow;
    //配置Flow_RAM为DMA_Flow操作
    MemSetRAM4K_Enable;  //Set_All
    RD0 = FlowRAM_Addr0;
    RA0 = RD0;
    RD0 = DMA_PATH5;
    M[RA0] = RD0;
    MemSet_Disable; //Set_All
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      SetADBuf1_Flow
//  功能:
//      将AD_Buf0切回Flow通道
//  参数:
//      无
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField SetADBuf1_Flow;
    //配置Flow_RAM为DMA_Flow操作
    MemSetRAM4K_Enable;  //Set_All
    RD0 = FlowRAM_Addr1;
    RA0 = RD0;
    RD0 = DMA_PATH5;
    M[RA0] = RD0;
    MemSet_Disable; //Set_All
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      En_GRAM_To_CPU
//  功能:
//      将GRAM配置为CPU控制模式
//  参数:
//      1.RD0:需要配置的GRAM地址
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField En_GRAM_To_CPU;
    RA0 = RD0;

    // RD1 = 高四位掩码
    RD1 = 0xF0;
    RF_RotateR8(RD1);
    
    // 判断地址参数是否合法（片选地址必须=2），非法时略过本函数
    RD1 &= RD0;
    RD0 = 0x20000000;
    RD1 ^= RD0;
    if(RQ_nZero) goto L_En_GRAM_To_CPU_End;

    MemSetRAM4K_Enable; //使用扩展端口或RAM特殊配置时使能
    RD0 = DMA_PATH0;
    M[RA0] = RD0;
    MemSet_Disable;     //配置结束
    CPU_WorkEnable;
    
L_En_GRAM_To_CPU_End:    
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      En_AllRAM_To_CPU
//  功能:
//      将所有GRAM和XRAM配置为CPU控制模式
//  参数:
//      无
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField En_AllRAM_To_CPU;
    MemSetRAM4K_Enable; //使用扩展端口或RAM特殊配置时使能
    RD0 = DMA_PATH0;

    RD1 = RN_GRAM0;
    RA0 = RD1;
    RD1 = RN_GRAM_BANK_SIZE;
    RD2 = 24;
L_En_AllRAM_To_CPU_Loop:
    M[RA0] = RD0;
    RA0 += RD1;
    RD2 --;
    if(RQ_nZero) goto L_En_AllRAM_To_CPU_Loop;

//  RD1 = FlowRAM_Addr0;
//  RA0 = RD1;
//  M[RA0] = RD0;
//  RD1 = FlowRAM_Addr1;
//  RA0 = RD1;
//  M[RA0] = RD0;

    MemSet_Disable;     //配置结束
    CPU_WorkEnable;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      En_AllFlowRAM_To_CPU
//  功能:
//      将所有FlowRAM配置为CPU控制模式
//  参数:
//      无
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField En_AllFlowRAM_To_CPU;
    MemSetRAM4K_Enable; //使用扩展端口或RAM特殊配置时使能
    RD0 = DMA_PATH0;

	RD1 = FlowRAM_Addr0;
    RA0 = RD1;
    M[RA0] = RD0;
    RD1 = FlowRAM_Addr1;
    RA0 = RD1;
    M[RA0] = RD0;

    MemSet_Disable;     //配置结束
    CPU_WorkEnable;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      En_AllGRAM_To_CPU
//  功能:
//      将所有GRAM配置为CPU控制模式
//  参数:
//      无
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField En_AllGRAM_To_CPU;
    MemSetRAM4K_Enable; //使用扩展端口或RAM特殊配置时使能
    RD0 = DMA_PATH0;

    RD1 = RN_GRAM0;
    RA0 = RD1;
    RD1 = RN_GRAM_BANK_SIZE;
    RD2 = 16;
L_En_AllGRAM_To_CPU_Loop:
    M[RA0] = RD0;
    RA0 += RD1;
    RD2 --;
    if(RQ_nZero) goto L_En_AllGRAM_To_CPU_Loop;

    MemSet_Disable;     //配置结束
    CPU_WorkEnable;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      En_AllXRAM_To_CPU
//  功能:
//      将所有XRAM配置为CPU控制模式
//  参数:
//      无
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField En_AllXRAM_To_CPU;
    MemSetRAM4K_Enable; //使用扩展端口或RAM特殊配置时使能
    RD0 = DMA_PATH0;

    RD1 = RN_XRAM0;
    RA0 = RD1;
    RD1 = RN_XRAM_BANK_SIZE;
    RD2 = 8;
L_En_AllXRAM_To_CPU_Loop:
    M[RA0] = RD0;
    RA0 += RD1;
    RD2 --;
    if(RQ_nZero) goto L_En_AllXRAM_To_CPU_Loop;

    MemSet_Disable;     //配置结束
    CPU_WorkEnable;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      En_RAM_To_PATHx
//  功能:
//      将所有GRAM和XRAM配置为指定的PATH(除PATH0以外)
//  参数:
//      1.RA0:配置起始点
//      2.RD0:配置块数量
//      3.RD1:DMA_PATH1~4
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField En_RAM_To_PATHx;

    MemSetRAM4K_Enable; //使用扩展端口或RAM特殊配置时使能
    RD2 = RD0;
    RD0 = RN_GRAM_BANK_SIZE;
L_En_RAM_To_PATHx_Loop:
    M[RA0] = RD1;
    RA0 += RD0;
    RD2 --;
    if(RQ_nZero) goto L_En_RAM_To_PATHx_Loop;

    MemSet_Disable;     //配置结束
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      En_RAM_To_PATH1
//  功能:
//      将指定的GRAM或XRAM配置PATH1
//  参数:
//      1.RD0:配置地址
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField En_RAM_To_PATH1;
    RA0 = RD0;
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    RD0 = DMA_PATH1;
    M[RA0] = RD0;
    MemSet_Disable;     //配置结束
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      En_RAM_To_PATH2
//  功能:
//      将指定的GRAM或XRAM配置PATH2
//  参数:
//      1.RD0:配置地址
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField En_RAM_To_PATH2;
    RA0 = RD0;
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    RD0 = DMA_PATH2;
    M[RA0] = RD0;
    MemSet_Disable;     //配置结束
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      En_RAM_To_PATH3
//  功能:
//      将指定的GRAM或XRAM配置PATH3
//  参数:
//      1.RD0:配置地址
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField En_RAM_To_PATH3;
    RA0 = RD0;
    MemSetRAM4K_Enable; //使用扩展端口或RAM配置时使能
    RD0 = DMA_PATH3;
    M[RA0] = RD0;
    MemSet_Disable;     //配置结束
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      Dis_GRAM_To_CPU
//  功能:
//      将GRAM与CPU断开
//  参数:
//      无
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField Dis_GRAM_To_CPU;
    CPU_WorkDisable;
    Clr_CfgGRAM;
    Return_AutoField(0);



////////////////////////////////////////////////////////
//  名称:
//      CPU_Copy
//  功能:
//      CPU拷贝数据
//  参数:
//      1.RA0:源地址
//      2.RA1:目标地址
//      3.RD0:Dword长度
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField CPU_Copy;

    RD2 = RD0;
L_CPU_Copy_Loop:
    RD0 = M[RA0++];
    M[RA1++] = RD0;
    RD2 --;
    if(RQ_nZero) goto L_CPU_Copy_Loop;

    Return_AutoField(0*MMU_BASE);



////////////////////////////////////////////////////////
//  名称:
//      Clr_RAM
//  功能:
//      对GRam和XDRam清零
//  参数:
//      无
//  返回值:
//      无
////////////////////////////////////////////////////////
Sub_AutoField Clr_RAM;
    RD2 = 16;
    RD0 = RN_GRAM0;
    RA1 = RD0;
L_Clr_RAM_Loop:
    RD0 = RN_XRAM0;
    RA0 = RD0;
    //RD1 = 0xb14e9d1;// 1024*1+2
    RD1 = 0x48635339;// 256*1+2
    call Ram_Clr;
    RD0 = RN_GRAM_BANK_SIZE;
    RA1 += RD0;
    RD2 --;
    if(RQ_nZero) goto L_Clr_RAM_Loop;

    RD2 = 8;
    RD0 = RN_XRAM0;
    RA1 = RD0;
L_Clr_XRAM_Loop:
    RD0 = RN_GRAM0;
    RA0 = RD0;
    //RD1 = 0xb14e9d1;// 1024*1+2
    RD1 = 0x48635339;// 256*1+2
    call Ram_Clr;
    RD0 = RN_XRAM_BANK_SIZE;
    RA1 += RD0;
    RD2 --;
    if(RQ_nZero) goto L_Clr_XRAM_Loop;

    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      Import_Sound_16bit
//  功能:
//      按16bit格式导入数字音频
//  参数:
//      1.RD0:数据首地址(out)
//      2.RD1:数据长度(单位：字节，满足4的整倍数)
//  返回值：
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Import_Sound_16bit;
    RD2 = RD1;
    RA0 = RD0;
    call En_GRAM_To_CPU;
    RD0 = COM1;
    RD1 = RD2;
    call SPI_Master_Gets_Prot;
    call Dis_GRAM_To_CPU;
    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      Export_Sound_16bit
//  功能:
//      按16bit格式导出数字音频
//  参数:
//      1.RD0:数据首地址
//      2.RD1:数据长度(单位：字节，满足4的整倍数)
//  返回值：
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Export_Sound_16bit;
    RD2 = RD1;
    RD3 = RD0;

    // 发送包头
    RSP -= 2*MMU_BASE;
    RD0 = 0x80017fff;
    M[RSP] = RD0;
    RD0 = 0x00020000;
    RD0 += RD2;
    M[RSP+1*MMU_BASE] = RD0;
    RD0 = COM1;
    RD1 = 2*MMU_BASE;
    RA0 = RSP;
    call SPI_Master_Puts;
    RSP += 2*MMU_BASE;


    RD0 = RD3;
    RA0 = RD0;
    call En_GRAM_To_CPU;
    RD0 = COM1;
    RD1 = RD2;
    call SPI_Master_Puts_Prot;
    call Dis_GRAM_To_CPU;
    Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  名称:
//      Export_Data_32bit
//  功能:
//      按32bit格式导出关键数据，为主机能够从数字音频流中提取关键数据，
//      每包数据前附加两个Dword作为包头：固定值0x80017fff(在16KHz采样率下，数字音频不会出现此值)和长度(单位：字节，满足4的整倍数)
//  参数:
//      1.RD0:数据首地址
//      2.RD1:数据长度(单位：字节，满足4的整倍数)
//  返回值：
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Export_Data_32bit;
    RD2 = RD1;
    RD3 = RD0;

    // 发送包头
    RSP -= 2*MMU_BASE;
    RD0 = 0x80017fff;
    M[RSP] = RD0;
    M[RSP+1*MMU_BASE] = RD2;
    RD0 = COM1;
    RD1 = 2*MMU_BASE;
    RA0 = RSP;
    call SPI_Master_Puts;
    RSP += 2*MMU_BASE;

    // 发送关键数据
    RD0 = RD3;
    call En_GRAM_To_CPU;
    RD0 = RD3;
    RA0 = RD0;
    RD0 = COM1;
    RD1 = RD2;
    call SPI_Master_Puts;
    call Dis_GRAM_To_CPU;
    Return_AutoField(0);


//////////////////////////////////////////////////////////////////////////
//  名称:
//      Export_Vector_32bit
//  功能:
//      按32bit格式导出关键数据(向量)，为主机能够从数字音频流中提取关键数据，
//      每包数据前附加两个Dword作为包头：固定值0x80017fff(在16KHz采样率下，数字音频不会出现此值)和长度(单位：字节，满足4的整倍数)
//  参数:
//      1.RD0:数据首地址
//      2.RD1:数据长度(单位：字节，满足4的整倍数)
//  返回值：
//      无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Export_Vector_32bit;
    RD2 = RD1;
    RD3 = RD0;

    // 发送包头
    RSP -= 2*MMU_BASE;
    RD0 = 0x80017fff;
    M[RSP] = RD0;
    RD0 = 0x00010000;
    RD0 += RD2;
    M[RSP+1*MMU_BASE] = RD0;
    RD0 = COM1;
    RD1 = 2*MMU_BASE;
    RA0 = RSP;
    call SPI_Master_Puts;
    RSP += 2*MMU_BASE;

    // 发送关键数据
    RD0 = RD3;
    call En_GRAM_To_CPU;
    RD0 = RD3;
    RA0 = RD0;
    RD0 = COM1;
    RD1 = RD2;
    call SPI_Master_Puts;
    call Dis_GRAM_To_CPU;
    Return_AutoField(0);

END SEGMENT

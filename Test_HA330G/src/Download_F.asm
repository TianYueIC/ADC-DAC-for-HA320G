#define _Debug_Mode_F_

#include <CPU11.def>
#include <Global.def>
#include <RN_DSP_Cfg.def>
#include <DMA_ParaCfg.def>
#include <Download.def>
#include <GPIO.def>
#include <BL_SPI.def>
#include <MarchC.def>
#include <ALU.def>
#include <Random.def>
#include <string.def>
#include <init.def>
#include <STA.def>
#include <FMT.def>
#include <I2C.def>
#include <USI.def>
#include <UART.def>
#include <FuncTest.def>

CODE SEGMENT Debug_Mode_F;
//直接下载Cache1(代替Flash) 4K*16
_Download_Function:
	//CP 测试模式检查
	call CKT_Mode_Check;
	if(RD0_nZero) goto L_Boot_Mode_Start;
	call CP_Test;
	RD2 = 6000*30;
	call _Delay_RD2;
	goto _Download_Function;

L_Boot_Mode_Start:
	RD3 = 3; //三次校准机会
L_Mode_Check0:
	//GP0_1  UART_COM0_Tx
    RD0 = GP0_1;   //OC状态，支持单线UART
    GPIO_WEn0 = RD0;
    RD0 = GPIO_IN|GPIO_OUT|GPIO_OC|GPIO_PULL;   //同时输入通路也打开
    GPIO_Set0 = RD0;
    //GP0_2  UART_COM0_Rx
    RD0 = GP0_2;
    GPIO_WEn0 = RD0;
    RD0 = GPIO_IN|GPIO_PULL;
    GPIO_Set0 = RD0;

	//模式判断，UART下载（GP01+GP02低电平）、I2C下载（GP02低电平）、USER模式（其他）
	call BootMode_Check;
	Set_BDI2C;  //硬件标记,对应 RFlag_BDUART==0;
	if(RD0_Zero) goto L_Download;
	Set_BDUART; //硬件标记,对应 RFlag_BDUART==1;
	RD0 --;
	if(RD0_Zero) goto L_Download;

//  =================== GD25_Boot User 模式 ===================
	//用户模式
L_User_Mode:  //L_Boot_GD25:加载GD25，运行
	//RSP初始化
    RD0 = RN_RSP_START;
    RSP = RD0;
    //加载Flash数据至2块Cache
    call SPI_Init;
    call Load_Data;

    Set_CPUSpeed3;
    goto RN_Cache_StartAddr_Program;

//  =================== Download 模式 =========================
L_Download:
	// 初始化
    RD0 = RN_RSP_START;
    RSP = RD0;
    // 10ms延迟
    RD2 = 60000;
    call _Delay_RD2;

	// UART_COM0初始化，CFG端口
    RD0 = COM0;
    send_para(RD0);
    RD0 = 0x2829674e;//32.000MHz对应28800bps的参数   32000000/28800/2 = 556
    send_para(RD0);
    RD0 = 2;
    send_para(RD0);
    RD0 = 0;
    send_para(RD0);
    call UART_Init;

	// 发送两个字节0x00,28800bps
	RD0 = 0x00;
    send_para(RD0);
    call UART_Putchar;

	RD0 = 0x00;
    send_para(RD0);
    call UART_Putchar;

	// 如果是I2C模式，直接到地址扫描阶段
	if(RFlag_BDUART==0) goto L_I2C_Boot;
	// 如果是UART模式，接收bps设定指令
	RD0 = 600*5;   //5ms超时
	call UART_Getchar_TO;
	RD2 = RD0;
	RD0 ++;  //0xffffffff 表示超时
	if(RD0_Zero) goto L_CalBPS_Fail; //超时，重启对准

L_BPS_Judge:
	RD0 = 0x55; //115200
	RD0 -= RD2;
	if(RD0_Zero) goto L_BPS_115200;
	RD0 = 0xaa; //28800
	RD0 -= RD2;
	if(RD0_Zero) goto L_UART_Boot; //默认为28800

	//波特率对准失败，重新开启
L_CalBPS_Fail:
	USI_Num = COM0;
    USI_Disable;
	// GPIO初始化
    RD0 = 0xff;
    GPIO_WEn0 = RD0;
    GPIO_Data0 = RD0;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;

	RD3 --;
	if(RQ_nZero) goto L_Mode_Check0;

	//3次对准失败，进入User_Mode;
	goto L_User_Mode;

L_BPS_115200:
	// UART_COM0初始化，Cfg端口
    RD0 = COM0;
    send_para(RD0);
    RD0 = 0x52faa192;//32.000MHz对应115200bps的参数   32000000/115200/2 = 139
    send_para(RD0);
    RD0 = 2;
    send_para(RD0);
    RD0 = 0;
    send_para(RD0);
    call UART_Init;

	//UART 下载过程
L_UART_Boot:
	RD2 = 12000; //延迟2ms左右
	call _Delay_RD2;

	//以选定的波特率回复ACK
	RD0 = 0x90;
	send_para(RD0);
	call UART_Putchar;
	RD0 = 0x00;
	send_para(RD0);
	call UART_Putchar;

	//申请缓存空间4字节+1024字节
    RD0 = 2048;
    RSP -= RD0;
    RA0 = RSP;

	//开始循环接收数据帧，直至收到下载结束指令
L_UART_Download_Frame_Loop:
	//RA0 偏移地址
	//下载1帧数据，并发送校验，接收指令码
	call UART_Gets_Frame;
	RD0 = RD1;           //判断接收状态
	RD1 = 0x31415926;    //超时标志字
	if(RD0_Zero) goto L_Send_Verify_UART;
	//命令解析+拷贝至Cache+校验计算
	call Frame_Operate;
	if(RD0_Zero) goto L_Send_Verify_UART;
	//下载结束命令
	goto L_Download_End;
L_Send_Verify_UART:
//MODIFY------------------------------
	RD2 = 6000*2; //2ms延迟
	call _Delay_RD2;
//-----------------------------------   
    // 发送校验值
    send_para(RD1);
    call UART_PutDword;
    goto L_UART_Download_Frame_Loop;


// =============== Download for I2C ===============
//                   I2C 下载过程
L_I2C_Boot:
//#define I2C_SDA         GP0_1
//#define I2C_SCL         GP0_2
    // 初始化GPIO
    RD0 = I2C_SDA | I2C_SCL;
    GPIO_WEn0 = RD0;
    RD0 = GPIO_IN|GPIO_PULL;
    GPIO_Set0 = RD0;

	//申请缓存空间4+1024字节
    RD0 = 2048;
    RSP -= RD0;
    RA0 = RSP;

	//开始循环接收数据帧，直至收到下载结束指令
L_I2C_Download_Frame_Loop:
	//RA0 偏移地址
	//下载1帧数据，并发送校验，接收指令码
	//I2C_Gets_Frame
	call I2C_Scan_Addr;
    RD0 = 1028;
    call I2C_Gets;
    call I2C_Wait_Stop;

	//命令解析+拷贝至Cache+校验计算
	call Frame_Operate;
	if(RD0_Zero) goto L_Send_Verify_I2C;
	goto L_Download_End;
L_Send_Verify_I2C:
	call I2C_Scan_Addr;
    // 发送校验值
    push RD1;
    RA0 = RSP;
    RD0 = 4;
    call I2C_Puts;
    call I2C_Wait_Stop;
	pop RD1;
	RA0 = RSP;  //恢复RA0
    goto L_I2C_Download_Frame_Loop;

	//下载结束，恢复现场，并跳转至Cache运行
L_Download_End:
	USI_Num = COM0;
    USI_Disable;
	// GPIO初始化
    RD0 = 0xff;
    GPIO_WEn0 = RD0;
    GPIO_Data0 = RD0;
    GPIO_WEn1 = RD0;
    GPIO_Data1 = RD0;
    // 恢复复位设置
    RD0 = GP0_1|GP0_2;
    GPIO_WEn0 = RD0;
    RD0 = GPIO_IN|GPIO_PULL;
    GPIO_Set0 = RD0;
    // 恢复RSP设置
    RD0 = RN_RSP_START;
    RSP = RD0;
	// 调速为Speed3，跳转至Cache执行
    Set_CPUSpeed3;
    goto RN_Cache_StartAddr_Program;


//////////////////////////////////////////////////////////////////////////
//  函数名称:
//    Frame_Operate
//  函数功能:
//    完成1帧数据包存入Buffer之后的处理，包括命令解析+拷贝至Cache+校验计算
//  函数入口:
//    RA0: Buffer地址
//  函数出口:
//    RD0: 0:Cache下载命令 或 全局校验命令， -1:结束下载命令
//    RD1：校验码
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Frame_Operate;
	//包头解析
	RA1 = M[RA0++];
	RD0 = RA1;
	RF_GetH8(RD0);
	RD3 = RD0;
	//0x00xxxxxx:正常下载数据包
	if(RD0_Zero) goto L_Copy_Buf2Cache;
	RD0 = 0xAA;  //Cache整体校验
	RD0 -= RD3;
	if(RD0_Zero) goto L_Verify_CacheAll;
	//下载结束命令
	RD0 = -1;
	Return_AutoField(0);

	//拷贝并对拷贝后结果校验
L_Copy_Buf2Cache:
	//拷贝数据至Cache
	RD0 = RN_Cache_StartAddr;
	RA1 += RD0;         //目标地址
	//RA0 ：数据地址  32位字格式 = {I0[15:0],I1[15:0]}
	call Copy_Buf2Cache;

    //校验码计算
    RD0 = 0x123456;
    send_para(RD0);// Temp
    send_para(RD0);// Rst
    send_para(RA1);
    RD0 = 1024;
    send_para(RD0);
    call VerifySum_BootLoader;
	RD1 = RD0;
	RD0 = 0;
	Return_AutoField(0);
	
	//校验整个Cache
L_Verify_CacheAll:
    RD0 = 0x123456;
    send_para(RD0);// Temp
    send_para(RD0);// Rst
    RD0 = RN_Cache_StartAddr;
    send_para(RD0);
    RD0 = RN_Cache_SIZE;
    send_para(RD0);
    call VerifySum_BootLoader;
	RD1 = RD0;
	RD0 = 0;
	Return_AutoField(0);




////////////////////////////////////////////////////////
//  名称:
//      UART_Getchar
//  功能:
//      UART_COM0接收1字节数据
//  参数:
//      RD0:超时时间参数，1表示10条指令时间长度
//  返回值:
//      RD0：数据或超时标志 
//      -1：超时   0x000000xx：数据
////////////////////////////////////////////////////////
Sub_AutoField UART_Getchar_TO;
	RD3 = RD0;
    USI_Num = COM0;
L_UART_Getchar_TO_Wait1:
    nop;nop;nop;nop;
    RD3--;
    if(RQ_Zero) goto L_UART_Getchar_TO;
    if(USI_Flag==0) goto L_UART_Getchar_TO_Wait1;

    RD0 = USI_Data;
    RF_ShiftR2(RD0);
    RF_ShiftR1(RD0);
    RF_GetL8(RD0);
    Return_AutoField(0*MMU_BASE);

L_UART_Getchar_TO:
    RD0 = -1;
    Return_AutoField(0*MMU_BASE);

//////////////////////////////////////////////////////////////////////////
//  函数名称:
//    UART_Gets_Frame
//  函数功能:
//    完成UART (4+1024)Byte数据包下载功能。地址+数据写入+校验发送。
//    超时时间大约50ms
//  函数入口:
//    RA0 ：目标地址（必须是32位宽度RAM）
//  函数出口:
//    RD1 :  0 超时
//          !0 正常
//////////////////////////////////////////////////////////////////////////
Sub_AutoField UART_Gets_Frame;
	RD2 = 257;
	RD3 = 600*50;//大约50ms
L_UG_Frame_Loop:
	RD0 = RD3;   //超时参数
	call UART_GetDword_TO;
	M[RA0++] = RD0;
	RD0 = RD1;
	if(RD0_Zero) goto L_UG_Frame_Loop_End;
	RD2 --;
	if(RQ_nZero) goto L_UG_Frame_Loop;
L_UG_Frame_Loop_End:
	nop;
  	Return_AutoField(0);


//////////////////////////////////////////////////////////////////////////
//  函数名称:
//    Copy_Buf2Cache
//  函数功能:
//    完成1024Byte数据从BaseRAM拷贝至Cache过程
//  函数入口:
//    RA0 ：源地址（必须是32位宽度RAM）
//    RA1 ：目标地址（必须是16位宽度RAM）
//  函数出口:
//    无
//////////////////////////////////////////////////////////////////////////
Sub_AutoField Copy_Buf2Cache;
    Sel_Cache4Data;
	RD2 = 256;
L_Copy_Buf2Cache_L0:
	RD0 = M[RA0++];
	M[RA1+2] = RD0;
	RF_GetH16(RD0);
	M[RA1++] = RD0;
	RD2 --;
	if(RQ_nZero) goto L_Copy_Buf2Cache_L0;
    Sel_Cache4Inst;
  	Return_AutoField(0);



//////////////////////////////////////////////////////////////////////////
//  函数名称:
//    CKT_Mode_Check
//  函数功能:
//    CKT模式检查
//  函数入口:
//    无
//  函数出口:
//    RD0：0: 是CKT模式
//        !0: 非CKT模式
//////////////////////////////////////////////////////////////////////////
Sub_AutoField CKT_Mode_Check;
	//CP_TEST IO 初始化
    //Rx:GP1_5 + GP1_6
    RD0 = CKT_CP+CKT_RX;
    GPIO_WEn1 = RD0;
    RD0 = GPIO_IN | GPIO_PULL;
    GPIO_Set1 = RD0;
	RD2 = 6000;  //1ms延迟
	call _Delay_RD2;
	RD0 = GPIO_Data1;
	if(RD0_Bit5==1) goto L_Not_CKT_Mode;
	if(RD0_Bit6==1) goto L_Not_CKT_Mode;
	//间隔1ms再次判断
	RD2 = 6000;  //1ms
	call _Delay_RD2;
	RD0 = GPIO_Data1;
	if(RD0_Bit5==1) goto L_Not_CKT_Mode;
	if(RD0_Bit6==1) goto L_Not_CKT_Mode;
    //Tx:GP1_7低脉冲，约1ms
    RD0 = CKT_TX;
    GPIO_WEn1 = RD0;
    RD0 = GPIO_OUT;
    GPIO_Set1 = RD0;
    RD0 = 0;
	GPIO_Data1 = RD0;

	//1ms内拉高GP1_5和GP1_6
	RD2 = 600;
	RD3 = 0b01100000;
L_Check_CKT_Ready_L0:
	RD0 = GPIO_Data1;
	RD0 &= RD3;
	RD0 -= RD3;
	if(RD0_Zero) goto L_Check_CKT_Confirm;
	nop; nop;
	RD2 --;
	if(RQ_nZero) goto L_Check_CKT_Ready_L0;

L_Not_CKT_Mode:
    RD0 = CKT_TX;
    GPIO_WEn1 = RD0;
    RD0 = GPIO_IN | GPIO_PULL;
    GPIO_Set1 = RD0;
    RD0 = -1;     //非CKT 模式
	Return_AutoField(0);

L_Check_CKT_Confirm:
	RD0 = 0;     //CKT 模式
	Return_AutoField(0);
	




//////////////////////////////////////////////////////////////////////////
//  函数名称:
//    BootMode_Check
//  函数功能:
//    检查GP01和GP02是否出现低电平
//  函数入口:
//    无
//  函数出口:
//    RD0：0: 仅GP02低电平模式
//         1: GP01+GP02 低电平模式
//     other: 超时退出（包括未查询到低电平或电平维持时间非法）（按照6MIPS定时30ms）
//////////////////////////////////////////////////////////////////////////
Sub_AutoField BootMode_Check;
	//查询GP02
	RD2 = 600*30;
L_BMC_GP02_L0:
	nop; nop; nop; nop; nop;
	if(RFlag_COM0_Rx==0) goto L_BMC_GP01_L00;
	RD2 --;
	if(RQ_nZero) goto L_BMC_GP02_L0;  		
	RD0 = -1;
	goto L_BMC_End;  //30ms未查询到低电平，超时退出
L_BMC_GP01_L00:
	call Glitch_Cancel_GP02L;
	if(RFlag_COM0_Rx==1) goto L_BMC_GP02_L0;

	//查询到GP02为低电平，等待高电平，50ms超时退出
	//期间查询GP01是否有低电平出现
	RD0 = 0;
	RD2 = 600*50;
L_BMC_GP01_L1:
	nop; nop;
	if(RFlag_COM0_Tx==0) goto L_BMC_GP01_L20;
	nop;
	if(RFlag_COM0_Rx==1) goto L_BMC_End;   //成功判断为GP01单根低电平模式
	RD2 --;
	if(RQ_nZero) goto L_BMC_GP01_L1;
	RD0 = -1;
	goto L_BMC_End;   //低电平持续时间超过50ms，判断为非法

	//查到GP01为低电平
L_BMC_GP01_L20:
	//防抖动
	call Glitch_Cancel_GP01L;
	RD0 = 0;
	if(RFlag_COM0_Tx==1) goto L_BMC_GP01_L1;

	//有效判断GP01为低电平，查询等待GP02为高电平
	RD0 = 1;
L_BMC_GP01_L21:
	nop; nop; nop; nop; nop;
	if(RFlag_COM0_Rx==0) goto L_BMC_GP01_L22;  //成功判断为GP01+GP02低电平模式
	call Glitch_Cancel_GP02H;
	if(RFlag_COM0_Rx==1) goto L_BMC_End;
L_BMC_GP01_L22:
	RD2 --;
	if(RQ_nZero) goto L_BMC_GP01_L21;
	//低电平持续时间超过50ms，判断为非法
	RD0 = -1;         
L_BMC_End:
	Return_AutoField(0);



////////////////////////////////////////////////////////
//  函数名称:
//      Glitch_Cancel_GP01L
//  函数功能:
//      GP01低电平判断去毛刺
////////////////////////////////////////////////////////
Sub_AutoField Glitch_Cancel_GP01L;
	RD2 = 100;
L_Glitch_GP01L:
	RD2 --;
	if(RQ_Zero) goto L_Glitch_GP01L_End;
	if(RFlag_COM0_Tx==1) goto L_Glitch_GP01L;
	nop; nop; nop; nop; nop; nop;
	if(RFlag_COM0_Tx==1) goto L_Glitch_GP01L;
	nop; nop; nop; nop; nop; nop;
	if(RFlag_COM0_Tx==1) goto L_Glitch_GP01L;
L_Glitch_GP01L_End:
	nop;
	Return_AutoField(0);


////////////////////////////////////////////////////////
//  函数名称:
//      Glitch_Cancel_GP01H
//  函数功能:
//      GP01高电平判断去毛刺
////////////////////////////////////////////////////////
Sub_AutoField Glitch_Cancel_GP01H;
	RD2 = 100;
L_Glitch_GP01H:
	RD2 --;
	if(RQ_Zero) goto L_Glitch_GP01H_End;
	nop; nop; nop; nop; nop; nop;
	if(RFlag_COM0_Tx==0) goto L_Glitch_GP01H;
	nop; nop; nop; nop; nop; nop;
	if(RFlag_COM0_Tx==0) goto L_Glitch_GP01H;
	nop; nop; nop; nop; nop; nop;
	if(RFlag_COM0_Tx==0) goto L_Glitch_GP01H;
L_Glitch_GP01H_End:
	nop;
	Return_AutoField(0);


////////////////////////////////////////////////////////
//  函数名称:
//      Glitch_Cancel_GP02L
//  函数功能:
//      GP02低电平判断去毛刺
////////////////////////////////////////////////////////
Sub_AutoField Glitch_Cancel_GP02L;
	RD2 = 100;
L_Glitch_GP02L:
	RD2 --;
	if(RQ_Zero) goto L_Glitch_GP02L_End;
	if(RFlag_COM0_Rx==1) goto L_Glitch_GP02L;
	nop; nop; nop; nop; nop; nop;
	if(RFlag_COM0_Rx==1) goto L_Glitch_GP02L;
	nop; nop; nop; nop; nop; nop;
	if(RFlag_COM0_Rx==1) goto L_Glitch_GP02L;
L_Glitch_GP02L_End:
	nop;
	Return_AutoField(0);


////////////////////////////////////////////////////////
//  函数名称:
//      Glitch_Cancel_GP02H
//  函数功能:
//      GP02高电平判断去毛刺
////////////////////////////////////////////////////////
Sub_AutoField Glitch_Cancel_GP02H;
	RD2 = 100;
L_Glitch_GP02H:
	RD2 --;
	if(RQ_Zero) goto L_Glitch_GP02H_End;
	if(RFlag_COM0_Rx==0) goto L_Glitch_GP02H;
	nop; nop; nop; nop; nop; nop;
	if(RFlag_COM0_Rx==0) goto L_Glitch_GP02H;
	nop; nop; nop; nop; nop; nop;
	if(RFlag_COM0_Rx==0) goto L_Glitch_GP02H;
L_Glitch_GP02H_End:
	nop;
	Return_AutoField(0);


////////////////////////////////////////////////////////
//  函数名称:
//      VerifySum_BootLoader
//  函数功能:
//      针对16位Cache存储器，计算四字节累加和校验值
//  入口参数:
//      1:Temp
//      2:Rst
//      3:数据指针
//      4:长度（单位：Byte）
//  出口参数:
//      RD0:校验值
//      RD1:Temp
////////////////////////////////////////////////////////
Sub_AutoField VerifySum_BootLoader;
	Sel_Cache4Data;
    RD1 = M[RSP+3*MMU_BASE];// Temp
    RD0 = M[RSP+2*MMU_BASE];// Rst
    RA0 = M[RSP+1*MMU_BASE];
    RD2 = M[RSP+0*MMU_BASE];
    RF_ShiftR2(RD2);
L_VerifySum_BootLoader_Loop:
	RD3 = M[RA0];
	RF_RotateL16(RD3);
	RD3 += M[RA0+2];
    RD1 += RD3;
    RD0 += RD1;
    RA0 += 4;
    RD2 --;
    if(RQ_nZero) goto L_VerifySum_BootLoader_Loop;
    Sel_Cache4Inst;
    Return_AutoField(4*MMU_BASE);


////////////////////////////////////////////////////////
//  名称:
//      UART_GetDword_TO
//  功能:
//      UART_COM0接收4字节数据
//  参数:
//      RD0:超时参数
//  返回值:
//      RD0：接收到的Dword数据
//      RD1: 0 接收超时
//          !0 接收正常
////////////////////////////////////////////////////////
Sub_AutoField UART_GetDword_TO;
    USI_Num = COM0;
	RD3 = RD0;
_UART_GetDword_Wait1:
    RD3--;
    if(RQ_Zero) goto L_UART_GetDword_End;
    nop;nop;nop;nop;nop;
    if(USI_Flag==0) goto _UART_GetDword_Wait1;
    RD0 = USI_Data;
    RF_ShiftR2(RD0);
    RF_ShiftR1(RD0);
    RF_GetL8(RD0);
    RD2 = RD0;
    RF_RotateL8(RD2);

_UART_GetDword_Wait2:
    RD3--;
    if(RQ_Zero) goto L_UART_GetDword_End;
    nop;nop;nop;nop;nop;
    if(USI_Flag==0) goto _UART_GetDword_Wait2;
    RD0 = USI_Data;
    RF_ShiftR2(RD0);
    RF_ShiftR1(RD0);
    RF_GetL8(RD0);
    RD2 |= RD0;
    RF_RotateL8(RD2);

_UART_GetDword_Wait3:
    RD3--;
    if(RQ_Zero) goto L_UART_GetDword_End;
    nop;nop;nop;nop;nop;
    if(USI_Flag==0) goto _UART_GetDword_Wait3;
    RD0 = USI_Data;
    RF_ShiftR2(RD0);
    RF_ShiftR1(RD0);
    RF_GetL8(RD0);
    RD2 |= RD0;
    RF_RotateL8(RD2);

_UART_GetDword_Wait4:
    RD3--;
    if(RQ_Zero) goto L_UART_GetDword_End;
    nop;nop;nop;nop;nop;
    if(USI_Flag==0) goto _UART_GetDword_Wait4;
    RD0 = USI_Data;
    RF_ShiftR2(RD0);
    RF_ShiftR1(RD0);
    RF_GetL8(RD0);
    RD2 |= RD0;
    RD0 = RD2;

L_UART_GetDword_End:    
    RD1 = RD3;
    Return_AutoField(0*MMU_BASE);


END SEGMENT
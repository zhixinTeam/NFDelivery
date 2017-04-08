//----------------------------------- 通用 -------------------------------------
{.$DEFINE DEBUG}
//调试模式

{.$DEFINE TrialVersion}
//试用版本

{$DEFINE UseReport}
//报表支持

{.$DEFINE RandomID}
//使用随机编号

{$DEFINE cxLibrary42}
//Ver4.2编译环境

{$DEFINE EnableBackupDB}
//备用数据库支持
{$DEFINE EnableDoubleDB}
//双数据库支持

//---------------------------------- 中间件 ------------------------------------
{.$DEFINE ClientMon}
//进程守护客户端

{.$DEFINE HardMon}
//编译硬件守护

{.$DEFINE GenRODL}
//生成RODL资源

{$DEFINE COM_MIT}
//定义系统模式

//通用中间件
{$IFDEF COM_MIT}
  {$DEFINE DBPool}
  //启用数据库支持
  {.$DEFINE ChannelPool}
  //启用通道支持
  {.$DEFINE AutoChannel}
  //启用通道平衡
  {.$DEFINE SAP}
  //启用SAP支持
  {.$DEFINE ClientMon}
  //支持守护服务
{$ENDIF}

//--------------------------------- 特定系统 -----------------------------------
{.$DEFINE COMMON}
//通用版本

{$DEFINE JSNF}
//特定系统

{$IFDEF JDNF}
  {$DEFINE AutoSan}
  //散装允许自动过磅
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE BatchVerifyValue}
  //批次控制发货量
{$ENDIF}
//建德南方

{$IFDEF FYNF}
  {$DEFINE AutoSan}
  //散装允许自动过磅
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE RFIDOPENDOOR}
  //电子标签读卡器打开道闸
  {$DEFINE BatchVerifyValue}
  //批次控制发货量
  {$DEFINE FORCEOPENDOOR}
  //强制抬杆
  {$DEFINE HKVDVR}
  //服务器抓拍
{$ENDIF}
//富阳南方

{$IFDEF JSNF}
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {.$DEFINE MicroMsg}
  //微信支持
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {$DEFINE VerfiyAutoWeight}
  //校验过磅方式
  {$DEFINE ORDERVALUE}
  //显示大票量发货量
{$ENDIF}
//江山南方

{$IFDEF YFNF}
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE AutoSan}
  //散装允许自动过磅
  {$DEFINE ORDERVALUE}
  //显示大票量发货量
{$ENDIF}
//永丰南方(永丰、安抚)

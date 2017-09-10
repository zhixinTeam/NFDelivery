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

{$DEFINE HardMon}
//编译硬件守护

{.$DEFINE GenRODL}
//生成RODL资源

{$DEFINE COM_MIT}
//定义系统模式

//通用中间件
{$IFDEF COM_MIT}
  {$DEFINE DBPool}
  //启用数据库支持
  {$DEFINE ChannelPool}
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

{$DEFINE GXNF}
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
  {$DEFINE FORCEREADER}
  //出厂读卡器
{$ENDIF}
//富阳南方

{$IFDEF JSNF}
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {$DEFINE VerfiyAutoWeight}
  //校验过磅方式
  {$DEFINE ORDERVALUE}
  //显示大票量发货量
  {$DEFINE MultiReplay}
  //计数器应答模式
  {.$DEFINE JSTruck}
  //格式化计数器车牌
  {.$DEFINE JSTruckNone}
  //不格式化计数器车牌
  {$DEFINE JSTruckPackStyle}
  //格式化计数器车牌(包装类型)
  {$DEFINE StockTypeByPackStyle}
  //预刷卡品种类型(包装类型)
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
  {$DEFINE BatchVerifyValue}
  //批次控制发货量
{$ENDIF}
//永丰南方(永丰、安抚、上高)

{$IFDEF SMNF}
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
{$ENDIF}
//三明南方

{$IFDEF NCNF}
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
  {$DEFINE MITTruckProber}
  //中间件控制车检
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE ShowDaiWC}
  //显示袋装误差提示
{$ENDIF}
//南城南方

{$IFDEF TLNF}
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
  {$DEFINE MITTruckProber}
  //中间件控制车检
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE LineGroup}
  //通道进行分组
  {$DEFINE CombinePrintBill}
  //销售尾单合单后合并打印
{$ENDIF}
//桐庐南方

{$IFDEF SYNF}
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
  {$DEFINE MITTruckProber}
  //中间件控制车检
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE CardProvide}
  //采用复磅模式
  {.$DEFINE LineGroup}
  //通道进行分组
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {$DEFINE DaiForceQueue}
  //包装发货强制队列
  {$DEFINE CombinePrintBill}
  //销售尾单合单后合并打印
  {$DEFINE StockPriorityInQueue}
  //排队时使用物料优先级
  {$DEFINE PrepareShowTruck}
  //预刷卡显示车牌
  {$DEFINE PrepareShowOnLading}
  //刷卡装车时控制预刷卡(不使用预刷卡读卡器)
{$ENDIF}
//山亚南方

{$IFDEF ZGNF}
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
  {$DEFINE MITTruckProber}
  //中间件控制车检
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE LineGroup}
  //通道进行分组
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE GROUPBYBRAND}
  //根据品牌分组
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
{$ENDIF}
//诸葛南方

{$IFDEF GXNF}
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
  {$DEFINE MITTruckProber}
  //中间件控制车检
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE LineGroup}
  //通道进行分组
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE FORCEPSTATION}
  //强制地磅磅站
  {$DEFINE ERROPENONEDOOR}
  //过磅失败倒车下磅
  {$DEFINE VerifyInTimeWhenP}
  //过皮重验证进厂时间
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {$DEFINE DaiForceQueue}
  //包装发货强制队列
{$ENDIF}
//广西南方

//临桂,荔浦
{$IFDEF LPNF}
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
  {$DEFINE MITTruckProber}
  //中间件控制车检
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE LineGroup}
  //通道进行分组
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE FORCEPSTATION}
  //强制地磅磅站
  {$DEFINE ERROPENONEDOOR}
  //过磅失败倒车下磅
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
{$ENDIF}

//金鲤南方
{$IFDEF JLNF}
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
  {$DEFINE MITTruckProber}
  //中间件控制车检
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE LineGroup}
  //通道进行分组
  {$DEFINE JSTruckSimple}
  //格式化计数器车牌
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {$DEFINE PrintShipReport}
  //船运开单时强制打单
  {$DEFINE NoVerifyTruckNo}
  //不校验车牌号(船号不符合规则)
{$ENDIF}

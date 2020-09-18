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

{$DEFINE ZJJNF}
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
  {$DEFINE PrePTruckYs}
  //采购预制皮重车辆验收
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE WarnPValue}
  //皮重预警
  {$DEFINE LinkSaleOrder}
  //固定卡关联销售订单
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
  {$DEFINE WarnPValue}
  //皮重预警
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
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {.$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE PrintHuaYanDan}
  //打印化验单
  {.$DEFINE PrintHeGeZheng}
  //打印合格证
  {$DEFINE BatCodeByLine}
  //现场获取批次
  {$DEFINE SaveOrderNo}
  //保存订单编号
  {$DEFINE HdFilterTruck}
  //合单只获取同车号订单
  {$DEFINE SaveAllSnapInfo}
  //保存停车场抓拍原始记录
  {$DEFINE RemoteSnap}
  //车牌识别
  {$DEFINE GetLastHYInfo}
  //获取最近一次化验记录(当批次号对应化验记录不存在时)
  {$DEFINE AutoSan}
  //散装允许自动过磅
  {$DEFINE DaiNoWeight}
  //包装不报重量
  {$DEFINE PrePTruckYs}
  //采购预制皮重车辆验收
  {.$DEFINE AutoOutByStokNo}
  //根据物料号虚拟出厂
  {$DEFINE SanAutoHD}
  //散装自动合单
  {$DEFINE WarnPValue}
  //皮重预警
  {$DEFINE FixLoad}
  //转子秤定制装车
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
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE TruckMValueMaxControl}
  //车辆毛重上限控制
  {$DEFINE MITTruckProber}
  //中间件控制车检
  {$DEFINE RFIDOPENDOOR}
  //电子标签读卡器打开道闸
  {$DEFINE FORCEOPENDOOR}
  //强制抬杆
  {$DEFINE BlueReader}
  //蓝卡读卡器
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {.$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE PrintHuaYanDan}
  //打印化验单
  {$DEFINE ManuPack}
  //人工选择包装类型
  {$DEFINE AICMPackFromDict}
  //自助机从DICT读取包装类型(同品种不同品牌)
{$ENDIF}
//永丰南方(永丰)

{$IFDEF SGNF}
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
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE TruckMValueMaxControl}
  //车辆毛重上限控制
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {.$DEFINE MITTruckProber}
  //中间件控制车检
  {$DEFINE RFIDOPENDOOR}
  //电子标签读卡器打开道闸
  {$DEFINE FORCEOPENDOOR}
  //强制抬杆
  {$DEFINE BlueReader}
  //蓝卡读卡器
{$ENDIF}
//上高南方(上高)

{$IFDEF AFNF}
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
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE TruckMValueMaxControl}
  //车辆毛重上限控制
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {$DEFINE MITTruckProber}
  //中间件控制车检(旧版驱动)
{$ENDIF}
//安福南方

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
  {$DEFINE MITTruckProber}
  //中间件控制车检
  {.$DEFINE TruckProberEx}
  //车检光栅状态判断扩展(此开关启用时建议同时启用MITTruckProber开关)
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {.$DEFINE DaiForceQueue}
  //包装发货强制队列
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {.$DEFINE JudgeOrder}
  //验证订单是否出厂
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {.$DEFINE LEDShowTruckEx}
  //大屏显示格式化车牌
  {.$DEFINE OneTruckMulCard}
  //一车多卡
  {.$DEFINE FilterTunnel}
  //过滤无关通道
  {$DEFINE AutoGetLineGroup}
  //自动获取装车线分组
  {$DEFINE NoPointLine}
  //开单不强制指定装车线(此开关为AutoGetLineGroup下子开关)
  {$DEFINE PrepareShowTruck}
  //预刷卡显示车牌
  {$DEFINE PreShowEx}
  //预刷卡特殊显示
  {.$DEFINE PrepareShowOnLading}
  //刷卡装车时控制预刷卡(不使用预刷卡读卡器)
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {$DEFINE ManuPack}
  //人工选择包装类型
  {$DEFINE RemoteSnap}
  //车牌识别
  {$DEFINE HKVDVR}
  //服务器抓拍
  {$DEFINE FORCEOPENDOOR}
  //强制抬杆
  {$DEFINE InfoConfirm}
  //刷卡信息确认
  {$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE PrintHuaYanDan}
  //打印化验单
  {$DEFINE PrintHeGeZheng}
  //打印合格证
  {$DEFINE AICMVerifyGPS}
  //自助机开单GPS校验
  {$DEFINE WarnPValue}
  //皮重预警
  {$DEFINE FixLoad}
  //转子秤定制装车
  {$DEFINE FixLoadNoControlValue}
  //转子秤定制装车(不控制开单量)
  {$DEFINE TruckTypeOnlyPound}
  //车轴类型(只在地磅校验)
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
  {$DEFINE PrintHYEach}
  //随车开化验单
  {.$DEFINE HeGeZhengOnly}
  //随车开单时只打合格证
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE PrePTruckYs}
  //采购预制皮重车辆验收
  {$DEFINE BasisWeight}
  //启用定量装车
  {$DEFINE BasisWeightWithPM}
  //库底计量: 定量装车时过皮毛中
  {$DEFINE BasisWeight}
  //库底计量: 定量装车
  {$DEFINE HKVDVR}
  //服务器抓拍
  {$DEFINE FixLoad}
  //转子秤定制装车
  {$DEFINE FixLoadNoControlValue}
  //转子秤定制装车(不控制开单量)
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
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {.$DEFINE PurAICMFromNC}
  //采购自助办卡
  {$DEFINE FixLoad}
  //转子秤定制装车
  {$DEFINE CapturePictureEx}
  //抓拍EX模式
  {$DEFINE WarnPValue}
  //皮重预警
  {.$DEFINE TruckMValueMaxControl}
  //车辆毛重上限控制
  {$DEFINE TruckHZValueMax}
  //车辆核载上限控制
  {$DEFINE TLXzSync}
  //销售数据同步
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
  {.$DEFINE DaiQuickSync}
  //包装开单及推单
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
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {$DEFINE FixLoad}
  //转子秤定制装车
  {.$DEFINE CapturePictureEx}
  //抓拍EX模式
  {$DEFINE PoundVerfyOrder}
  //过磅校验订单(销售)
  {$DEFINE EnableAlivision}
  {$DEFINE AlivisionInClient}
  //启用阿里图像识别
  {$DEFINE WarnPValue}
  //皮重预警
  {.$DEFINE SanAutoHD}
  //散装自动合单
  {$DEFINE BusinessOnly}
  //业务唯一
  {$DEFINE PreQueueLed}
  //预排队大屏
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
  {$DEFINE GROUPBYAREA}
  //根据区域流向分组(若此分组不启用,则继续使用品牌分组)
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {$DEFINE YanShouByCard}
  //刷卡验收并进行连锁控制
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {.$DEFINE PurAICMFromNC}
  //采购自助办卡
  {$DEFINE PrintHyOnSaveBill}
  //开单打印化验单
  {$DEFINE AICMSafeInfo}
  //自助机入厂安全须知
  {$DEFINE WarnPValue}
  //皮重预警
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
  {$DEFINE RemoteSnap}
  //车牌识别
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {.$DEFINE PurAICMFromNC}
  //采购自助办卡
  {$DEFINE VerifyGPSByPost}
  //远程GPS校验
{$ENDIF}
//广西南方

//荔浦
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
  {$DEFINE LEDShowTruckEx}
  //大屏显示格式化车牌
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {.$DEFINE PurAICMFromNC}
  //采购自助办卡
{$ENDIF}

//临桂
{$IFDEF LGNF}
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
  {.$DEFINE LEDShowTruckEx}
  //大屏显示格式化车牌
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {.$DEFINE PurAICMFromNC}
  //采购自助办卡
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
  {$DEFINE DaiForceQueue}
  //包装发货强制队列
  {$DEFINE PrintShipReport}
  //船运开单时强制打单
  {$DEFINE NoVerifyTruckNo}
  //不校验车牌号(船号不符合规则)
  {$DEFINE NoShipTruckOut}
  //不处理船运在门岗的出厂业务
  {$DEFINE FixLoad}
  //转子秤定制装车
  {$DEFINE SanForceQueue}
  //散装发货强制队列
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {.$DEFINE PurAICMFromNC}
  //采购自助办卡
  {$DEFINE HdFilterTruck}
  //合单只获取同车号订单
  {$DEFINE PrintHeGeZheng}
  //打印合格证
  {$DEFINE HeGeZhengSimpleData}
  //打印合格证(只取提货信息)
{$ENDIF}

//崇左南方
{$IFDEF CZNF}
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
  {.$DEFINE JSTruck}
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
  {$DEFINE JSLED}
  //计数显示屏
  {$DEFINE JSDoubleChannel}
  //计数双通道
  {$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE PrintHuaYanDan}
  //打印化验单
  {$DEFINE PrintHeGeZheng}
  //打印合格证
  {$DEFINE HeGeZhengSimpleData}
  //打印合格证(只取提货信息)
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {$DEFINE AutoPreTruckP}
  //根据重量自动预制皮重
  {$DEFINE FixLoad}
  //转子秤定制装车
  {$DEFINE FixLoadNoControlValue}
  //转子秤定制装车(不控制开单量)
{$ENDIF}

//黄山
{$IFDEF HSNF}
  {$DEFINE AutoSan}
  //散装允许自动过磅
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE BatchVerifyValue}
  //批次控制发货量
  {$DEFINE MITTruckProber}
  //中间件控制车检
  {.$DEFINE TruckProberEx}
  //车检光栅状态判断扩展(此开关启用时建议同时启用MITTruckProber开关)
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {$DEFINE DaiForceQueue}
  //包装发货强制队列
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE RFIDOPENDOOR}
  //电子标签读卡器打开道闸
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {$DEFINE BMPrintCode}
  //采用NC编码组合喷码
  {$DEFINE JudgeOrder}
  //验证订单是否出厂
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {$DEFINE LEDShowTruckEx}
  //大屏显示格式化车牌
  {$DEFINE OneTruckMulCard}
  //一车多卡
  {$DEFINE FilterTunnel}
  //过滤无关通道
  {$DEFINE BusinessOnly}
  //业务唯一
  {$DEFINE WarnPValue}
  //皮重预警
{$ENDIF}

//衢州
{$IFDEF QZNF}
  {$DEFINE AutoSan}
  //散装允许自动过磅
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE BatchVerifyValue}
  //批次控制发货量
  {$DEFINE MITTruckProber}
  //中间件控制车检
  {.$DEFINE TruckProberEx}
  //车检光栅状态判断扩展(此开关启用时建议同时启用MITTruckProber开关)
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE FORCEOPENDOOR}
  //强制抬杆
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {.$DEFINE DaiForceQueue}
  //包装发货强制队列
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE RFIDOPENDOOR}
  //电子标签读卡器打开道闸
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {$DEFINE JudgeOrder}
  //验证订单是否出厂
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {$DEFINE LEDShowTruckEx}
  //大屏显示格式化车牌
  {.$DEFINE OneTruckMulCard}
  //一车多卡
  {.$DEFINE FilterTunnel}
  //过滤无关通道
  {$DEFINE AutoGetLineGroup}
  //自动获取装车线分组
  {$DEFINE PrepareShowTruck}
  //预刷卡显示车牌
  {.$DEFINE PrepareShowOnLading}
  //刷卡装车时控制预刷卡(不使用预刷卡读卡器)
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {$DEFINE WarnPValue}
  //皮重预警
{$ENDIF}


//胥口
{$IFDEF XKNF}
  {$DEFINE AutoSan}
  //散装允许自动过磅
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE BatchVerifyValue}
  //批次控制发货量
  {$DEFINE MITTruckProber}
  //中间件控制车检
  {.$DEFINE TruckProberEx}
  //车检光栅状态判断扩展(此开关启用时建议同时启用MITTruckProber开关)
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {.$DEFINE DaiForceQueue}
  //包装发货强制队列
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE RFIDOPENDOOR}
  //电子标签读卡器打开道闸
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {.$DEFINE JudgeOrder}
  //验证订单是否出厂
  {.$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {.$DEFINE PurAICMFromNC}
  //采购自助办卡
  {.$DEFINE LEDShowTruckEx}
  //大屏显示格式化车牌
  {.$DEFINE OneTruckMulCard}
  //一车多卡
  {.$DEFINE FilterTunnel}
  //过滤无关通道
  {.$DEFINE AutoGetLineGroup}
  //自动获取装车线分组
  {$DEFINE PrepareShowTruck}
  //预刷卡显示车牌
  {.$DEFINE PrepareShowOnLading}
  //刷卡装车时控制预刷卡(不使用预刷卡读卡器)
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {$DEFINE ManuPack}
  //人工选择包装类型
  {$DEFINE CombinePrintBill}
  //销售尾单合单后合并打印
  {$DEFINE SaveOrderNo}
  //保存订单编号
  {$DEFINE MValueMaxControlTotal}
  //毛重上限总控制
  {$DEFINE TruckTypeOnlyPound}
  //车轴类型(只在地磅校验)
{$ENDIF}

//常山
{$IFDEF CSNF}
  {$DEFINE AutoSan}
  //散装允许自动过磅
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE BatchVerifyValue}
  //批次控制发货量
  {$DEFINE MITTruckProber}
  //中间件控制车检
  {.$DEFINE TruckProberEx}
  //车检光栅状态判断扩展(此开关启用时建议同时启用MITTruckProber开关)
  {$DEFINE MultiReplay}
  //计数器应答模式
  {.$DEFINE FORCEOPENDOOR}
  //强制抬杆
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {.$DEFINE DaiForceQueue}
  //包装发货强制队列
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE RFIDOPENDOOR}
  //电子标签读卡器打开道闸
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {$DEFINE JudgeOrder}
  //验证订单是否出厂
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {.$DEFINE PurAICMFromNC}
  //采购自助办卡
  {$DEFINE LEDShowTruckEx}
  //大屏显示格式化车牌
  {.$DEFINE OneTruckMulCard}
  //一车多卡
  {.$DEFINE FilterTunnel}
  //过滤无关通道
  {$DEFINE AutoGetLineGroup}
  //自动获取装车线分组
  {$DEFINE PrepareShowTruck}
  //预刷卡显示车牌
  {.$DEFINE PrepareShowOnLading}
  //刷卡装车时控制预刷卡(不使用预刷卡读卡器)
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {$DEFINE ERROPENONEDOOR}
  //过磅失败倒车下磅
  {$DEFINE PoundVerfyOrder}
  //过磅校验订单(销售)
  {$DEFINE SaveOrderNo}
  //保存订单编号
  {$DEFINE ValueLimit}
  //限制开单上限
  {$DEFINE WarnPValue}
  //皮重预警
  {$DEFINE FixLoad}
  //转子秤定制装车
  {$DEFINE FixLoadNoControlValue}
  //转子秤定制装车(不控制开单量)
{$ENDIF}

//兴国
{$IFDEF XGNF}
  {$DEFINE AutoSan}
  //散装允许自动过磅
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE BatchVerifyValue}
  //批次控制发货量
  {$DEFINE MITTruckProber}
  //中间件控制车检
  {.$DEFINE TruckProberEx}
  //车检光栅状态判断扩展(此开关启用时建议同时启用MITTruckProber开关)
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE FORCEOPENDOOR}
  //强制抬杆
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {.$DEFINE DaiForceQueue}
  //包装发货强制队列
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE RFIDOPENDOOR}
  //电子标签读卡器打开道闸
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {$DEFINE JudgeOrder}
  //验证订单是否出厂
  {.$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {$DEFINE LEDShowTruckEx}
  //大屏显示格式化车牌
  {.$DEFINE OneTruckMulCard}
  //一车多卡
  {.$DEFINE FilterTunnel}
  //过滤无关通道
  {$DEFINE AutoGetLineGroup}
  //自动获取装车线分组
  {$DEFINE PrepareShowTruck}
  //预刷卡显示车牌
  {.$DEFINE PrepareShowOnLading}
  //刷卡装车时控制预刷卡(不使用预刷卡读卡器)
  {.$DEFINE PrintChinese}
  //汉字喷码支持
  {.$DEFINE ERROPENONEDOOR}
  //过磅失败倒车下磅
  {$DEFINE PoundVerfyOrder}
  //过磅校验订单(销售)
  {$DEFINE SaveOrderNo}
  //保存订单编号
  {$DEFINE SanNoAutoBD}
  //散装不自动并单
  {$DEFINE ValueLimit}
  //限制开单上限
  {$DEFINE RemoteSnap}
  //车牌识别
{$ENDIF}

//吉安
{$IFDEF JANF}
  {$DEFINE AutoSan}
  //散装允许自动过磅
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE BatchVerifyValue}
  //批次控制发货量
  {$DEFINE MITTruckProber}
  //中间件控制车检
  {.$DEFINE TruckProberEx}
  //车检光栅状态判断扩展(此开关启用时建议同时启用MITTruckProber开关)
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {.$DEFINE DaiForceQueue}
  //包装发货强制队列
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE RFIDOPENDOOR}
  //电子标签读卡器打开道闸
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {.$DEFINE JudgeOrder}
  //验证订单是否出厂
  {.$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {.$DEFINE PurAICMFromNC}
  //采购自助办卡
  {.$DEFINE LEDShowTruckEx}
  //大屏显示格式化车牌
  {.$DEFINE OneTruckMulCard}
  //一车多卡
  {.$DEFINE FilterTunnel}
  //过滤无关通道
  {.$DEFINE AutoGetLineGroup}
  //自动获取装车线分组
  {$DEFINE PrepareShowTruck}
  //预刷卡显示车牌
  {.$DEFINE PrepareShowOnLading}
  //刷卡装车时控制预刷卡(不使用预刷卡读卡器)
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {$DEFINE ManuPack}
  //人工选择包装类型
  {$DEFINE CombinePrintBill}
  //销售尾单合单后合并打印
  {$DEFINE SaveOrderNo}
  //保存订单编号
  {$DEFINE SanCardUseCount}
  //散装现场刷卡次数
  {$DEFINE YanShouByCard}
  //刷卡验收并进行连锁控制
  {$DEFINE YanShouOnlyShow}
  //刷卡验收只通过网口小屏显示信息(此开关为YanShouByCard下子开关)
  {$DEFINE YanShouTunnelByDict}
  //刷卡验收通道从DICT获取(此开关为YanShouByCard下子开关)
{$ENDIF}

//芦溪
{$IFDEF LUXNF}
  {$DEFINE AutoSan}
  //散装允许自动过磅
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE BatchVerifyValue}
  //批次控制发货量
  {$DEFINE MITTruckProber}
  //中间件控制车检
  {.$DEFINE TruckProberEx}
  //车检光栅状态判断扩展(此开关启用时建议同时启用MITTruckProber开关)
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE FORCEOPENDOOR}
  //强制抬杆
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {.$DEFINE DaiForceQueue}
  //包装发货强制队列
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE RFIDOPENDOOR}
  //电子标签读卡器打开道闸
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {$DEFINE JudgeOrder}
  //验证订单是否出厂
  {.$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {$DEFINE LEDShowTruckEx}
  //大屏显示格式化车牌
  {.$DEFINE OneTruckMulCard}
  //一车多卡
  {.$DEFINE FilterTunnel}
  //过滤无关通道
  {$DEFINE AutoGetLineGroup}
  //自动获取装车线分组
  {$DEFINE PrepareShowTruck}
  //预刷卡显示车牌
  {.$DEFINE PrepareShowOnLading}
  //刷卡装车时控制预刷卡(不使用预刷卡读卡器)
  {.$DEFINE PrintChinese}
  //汉字喷码支持
  {$DEFINE ERROPENONEDOOR}
  //过磅失败倒车下磅
  {$DEFINE PoundVerfyOrder}
  //过磅校验订单(销售)
  {$DEFINE SaveOrderNo}
  //保存订单编号
  {$DEFINE SanNoAutoBD}
  //散装不自动并单
  {$DEFINE ValueLimit}
  //限制开单上限
{$ENDIF}

//玉山
{$IFDEF YSNF}
  {$DEFINE AutoSan}
  //散装允许自动过磅
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE BatchVerifyValue}
  //批次控制发货量
  {$DEFINE MITTruckProber}
  //中间件控制车检
  {.$DEFINE TruckProberEx}
  //车检光栅状态判断扩展(此开关启用时建议同时启用MITTruckProber开关)
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE FORCEOPENDOOR}
  //强制抬杆
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {.$DEFINE DaiForceQueue}
  //包装发货强制队列
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE RFIDOPENDOOR}
  //电子标签读卡器打开道闸
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {$DEFINE JudgeOrder}
  //验证订单是否出厂
  {.$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {$DEFINE LEDShowTruckEx}
  //大屏显示格式化车牌
  {.$DEFINE OneTruckMulCard}
  //一车多卡
  {.$DEFINE FilterTunnel}
  //过滤无关通道
  {$DEFINE AutoGetLineGroup}
  //自动获取装车线分组
  {$DEFINE ForceLineGroup}
  //强制使用授权工厂编号作为生产线(此开关为AutoGetLineGroup下子开关)与ManuLineGroup互斥
  {.$DEFINE ManuLineGroup}
  //人工选择生产线(此开关为AutoGetLineGroup下子开关)与ForceLineGroup互斥
  {$DEFINE PrepareShowTruck}
  //预刷卡显示车牌
  {.$DEFINE PrepareShowOnLading}
  //刷卡装车时控制预刷卡(不使用预刷卡读卡器)
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {$DEFINE ERROPENONEDOOR}
  //过磅失败倒车下磅
  {$DEFINE PoundVerfyOrder}
  //过磅校验订单(销售)
  {$DEFINE SaveOrderNo}
  //保存订单编号
  {$DEFINE ValueLimit}
  //限制开单上限
  {$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE PrintHuaYanDan}
  //打印化验单
  {$DEFINE PrintHeGeZheng}
  //打印合格证
  {$DEFINE AutoOutByStokNo}
  //根据物料号虚拟出厂
{$ENDIF}

//尖峰南方
{$IFDEF JFNF}
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
  {.$DEFINE TruckProberEx}
  //车检光栅状态判断扩展(此开关启用时建议同时启用MITTruckProber开关)
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {.$DEFINE DaiForceQueue}
  //包装发货强制队列
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {.$DEFINE JudgeOrder}
  //验证订单是否出厂
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {.$DEFINE LEDShowTruckEx}
  //大屏显示格式化车牌
  {.$DEFINE OneTruckMulCard}
  //一车多卡
  {.$DEFINE FilterTunnel}
  //过滤无关通道
  {$DEFINE AutoGetLineGroup}
  //自动获取装车线分组
  {$DEFINE NoPointLine}
  //开单不强制指定装车线(此开关为AutoGetLineGroup下子开关)
  {$DEFINE PrepareShowTruck}
  //预刷卡显示车牌
  {$DEFINE PreShowEx}
  //预刷卡特殊显示
  {.$DEFINE PrepareShowOnLading}
  //刷卡装车时控制预刷卡(不使用预刷卡读卡器)
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {$DEFINE ManuPack}
  //人工选择包装类型
  {.$DEFINE RemoteSnap}
  //车牌识别
  {$DEFINE HKVDVR}
  //服务器抓拍
  {$DEFINE FORCEOPENDOOR}
  //强制抬杆
  {$DEFINE InfoConfirm}
  //刷卡信息确认
  {$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE PrintHuaYanDan}
  //打印化验单
  {$DEFINE PrintHeGeZheng}
  //打印合格证
  {.$DEFINE AICMVerifyGPS}
  //自助机开单GPS校验
  {.$DEFINE ManuSeal}
  //人工选择批次(手动批次)
  {$DEFINE DaiNoWeight}
  //包装不报重量
  {$DEFINE SyncDataByBFM}
  //称完毛重即推单
  {$DEFINE DaiQuickSync}
  //包装开单及推单
  {$DEFINE VerifyHYRecord}
  //化验记录不存在无法开单
  {$DEFINE SaveOrderNo}
  //保存订单编号
  {$DEFINE WarnPValue}
  //皮重预警
{$ENDIF}

//龙游南方,大慈岩
{$IFDEF LYNF}
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
  {.$DEFINE TruckProberEx}
  //车检光栅状态判断扩展(此开关启用时建议同时启用MITTruckProber开关)
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {.$DEFINE DaiForceQueue}
  //包装发货强制队列
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {.$DEFINE JudgeOrder}
  //验证订单是否出厂
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {.$DEFINE LEDShowTruckEx}
  //大屏显示格式化车牌
  {.$DEFINE OneTruckMulCard}
  //一车多卡
  {.$DEFINE FilterTunnel}
  //过滤无关通道
  {$DEFINE AutoGetLineGroup}
  //自动获取装车线分组
  {$DEFINE NoPointLine}
  //开单不强制指定装车线(此开关为AutoGetLineGroup下子开关)
  {$DEFINE PrepareShowTruck}
  //预刷卡显示车牌
  {$DEFINE PreShowEx}
  //预刷卡特殊显示
  {.$DEFINE PrepareShowOnLading}
  //刷卡装车时控制预刷卡(不使用预刷卡读卡器)
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {$DEFINE ManuPack}
  //人工选择包装类型
  {.$DEFINE RemoteSnap}
  //车牌识别
  {.$DEFINE HKVDVR}
  //服务器抓拍
  {$DEFINE FORCEOPENDOOR}
  //强制抬杆
  {$DEFINE InfoConfirm}
  //刷卡信息确认
  {$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE PrintHuaYanDan}
  //打印化验单
  {$DEFINE PrintHeGeZheng}
  //打印合格证
  {$DEFINE DaiNoWeight}
  //包装不报重量
  {.$DEFINE VerifyHYRecord}
  //化验记录不存在无法开单
  {$DEFINE PrePTruckYs}
  //采购预制皮重车辆验收
  {$DEFINE SaveOrderNo}
  //保存订单编号
  {$DEFINE SaveAreaName}
  //保存区域流向名称
  {$DEFINE ValueLimit}
  //限制开单上限
  {$DEFINE WarnPValue}
  //皮重预警
{$ENDIF}

//兰溪
{$IFDEF LANXNF}
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
  {.$DEFINE TruckProberEx}
  //车检光栅状态判断扩展(此开关启用时建议同时启用MITTruckProber开关)
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {.$DEFINE DaiForceQueue}
  //包装发货强制队列
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {.$DEFINE JudgeOrder}
  //验证订单是否出厂
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {.$DEFINE LEDShowTruckEx}
  //大屏显示格式化车牌
  {.$DEFINE OneTruckMulCard}
  //一车多卡
  {.$DEFINE FilterTunnel}
  //过滤无关通道
  {$DEFINE AutoGetLineGroup}
  //自动获取装车线分组
  {$DEFINE NoPointLine}
  //开单不强制指定装车线(此开关为AutoGetLineGroup下子开关)
  {$DEFINE PrepareShowTruck}
  //预刷卡显示车牌
  {$DEFINE PreShowEx}
  //预刷卡特殊显示
  {.$DEFINE PrepareShowOnLading}
  //刷卡装车时控制预刷卡(不使用预刷卡读卡器)
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {$DEFINE ManuPack}
  //人工选择包装类型
  {.$DEFINE RemoteSnap}
  //车牌识别
  {.$DEFINE HKVDVR}
  //服务器抓拍
  {$DEFINE FORCEOPENDOOR}
  //强制抬杆
  {$DEFINE InfoConfirm}
  //刷卡信息确认
  {$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE PrintHuaYanDan}
  //打印化验单
  {$DEFINE PrintHeGeZheng}
  //打印合格证
  {$DEFINE DaiNoWeight}
  //包装不报重量
  {.$DEFINE VerifyHYRecord}
  //化验记录不存在无法开单
  {$DEFINE PrePTruckYs}
  //采购预制皮重车辆验收
  {$DEFINE SaveOrderNo}
  //保存订单编号
  {$DEFINE SaveAreaName}
  //保存区域流向名称
  {$DEFINE ValueLimit}
  //限制开单上限
  {$DEFINE GetReportByBrand}
  //化验单模板按品牌区分
  {$DEFINE WarnPValue}
  //皮重预警
{$ENDIF}

//虎鹰南方
{$IFDEF HYNF}
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
  {.$DEFINE TruckProberEx}
  //车检光栅状态判断扩展(此开关启用时建议同时启用MITTruckProber开关)
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {.$DEFINE DaiForceQueue}
  //包装发货强制队列
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {.$DEFINE JudgeOrder}
  //验证订单是否出厂
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {.$DEFINE LEDShowTruckEx}
  //大屏显示格式化车牌
  {.$DEFINE OneTruckMulCard}
  //一车多卡
  {.$DEFINE FilterTunnel}
  //过滤无关通道
  {$DEFINE AutoGetLineGroup}
  //自动获取装车线分组
  {$DEFINE NoPointLine}
  //开单不强制指定装车线(此开关为AutoGetLineGroup下子开关)
  {$DEFINE PrepareShowTruck}
  //预刷卡显示车牌
  {$DEFINE PreShowEx}
  //预刷卡特殊显示
  {.$DEFINE PrepareShowOnLading}
  //刷卡装车时控制预刷卡(不使用预刷卡读卡器)
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {$DEFINE ManuPack}
  //人工选择包装类型
  {.$DEFINE RemoteSnap}
  //车牌识别
  {.$DEFINE HKVDVR}
  //服务器抓拍
  {$DEFINE FORCEOPENDOOR}
  //强制抬杆
  {$DEFINE InfoConfirm}
  //刷卡信息确认
  {$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE PrintHuaYanDan}
  //打印化验单
  {$DEFINE PrintHeGeZheng}
  //打印合格证
  {$DEFINE DaiNoWeight}
  //包装不报重量
  {.$DEFINE VerifyHYRecord}
  //化验记录不存在无法开单
  {$DEFINE PrePTruckYs}
  //采购预制皮重车辆验收
  {$DEFINE SaveOrderNo}
  //保存订单编号
  {$DEFINE DaiNoPrint}
  //包装出厂不打印
  {$DEFINE DaiQuickSync}
  //包装开单及推单
  {$DEFINE ValueLimit}
  //限制开单上限
  {$DEFINE PTruckCount}
  //限制原材料车辆数量
  {$DEFINE PTimeControl}
  //限制原材料入厂时间
  {$DEFINE GetReportByBrand}
  //化验单模板按品牌区分
  {$DEFINE AICMNoVerifyTruck}
  //自助开单不校验车牌号
  {$DEFINE WarnPValue}
  //皮重预警
{$ENDIF}

//古丈南方
{$IFDEF GZNF}
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
  {.$DEFINE TruckProberEx}
  //车检光栅状态判断扩展(此开关启用时建议同时启用MITTruckProber开关)
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {.$DEFINE DaiForceQueue}
  //包装发货强制队列
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {.$DEFINE JSTruck}
  //格式化计数器车牌
  {.$DEFINE JudgeOrder}
  //验证订单是否出厂
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {.$DEFINE LEDShowTruckEx}
  //大屏显示格式化车牌
  {.$DEFINE OneTruckMulCard}
  //一车多卡
  {.$DEFINE FilterTunnel}
  //过滤无关通道
  {.$DEFINE AutoGetLineGroup}
  //自动获取装车线分组
  {.$DEFINE NoPointLine}
  //开单不强制指定装车线(此开关为AutoGetLineGroup下子开关)
  {$DEFINE PrepareShowTruck}
  //预刷卡显示车牌
  {$DEFINE PreShowEx}
  //预刷卡特殊显示
  {.$DEFINE PrepareShowOnLading}
  //刷卡装车时控制预刷卡(不使用预刷卡读卡器)
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {.$DEFINE ManuPack}
  //人工选择包装类型
  {.$DEFINE RemoteSnap}
  //车牌识别
  {.$DEFINE HKVDVR}
  //服务器抓拍
  {$DEFINE FORCEOPENDOOR}
  //强制抬杆
  {$DEFINE InfoConfirm}
  //刷卡信息确认
  {$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE PrintHuaYanDan}
  //打印化验单
  {$DEFINE PrintHeGeZheng}
  //打印合格证
  {$DEFINE DaiNoWeight}
  //包装不报重量
  {.$DEFINE VerifyHYRecord}
  //化验记录不存在无法开单
  {$DEFINE PrePTruckYs}
  //采购预制皮重车辆验收
  {$DEFINE SaveOrderNo}
  //保存订单编号
  {.$DEFINE DaiNoPrint}
  //包装出厂不打印
  {.$DEFINE DaiQuickSync}
  //包装开单及推单
  {$DEFINE ValueLimit}
  //限制开单上限
  {.$DEFINE PTruckCount}
  //限制原材料车辆数量
  {.$DEFINE PTimeControl}
  //限制原材料入厂时间
  {.$DEFINE GetReportByBrand}
  //化验单模板按品牌区分
  {.$DEFINE AICMNoVerifyTruck}
  //自助开单不校验车牌号
  {$DEFINE WarnPValue}
  //皮重预警
  {$DEFINE FixLoad}
  //转子秤定制装车
  {$DEFINE DaiSyncByZT}
  //包装刷卡推单
  {$DEFINE SyncSanByBFM}
  //称完毛重即推单(散装)
  {$DEFINE SanCardUseCount}
  //散装现场刷卡次数
  {$DEFINE FixLoadNoControlValue}
  //转子秤定制装车(不控制开单量)
  {$DEFINE RemoteSnap}
  //车牌识别
  {$DEFINE DaiForceQueue}
  //包装发货强制队列
{$ENDIF}

//常德南方
{$IFDEF CDNF}
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
  {.$DEFINE TruckProberEx}
  //车检光栅状态判断扩展(此开关启用时建议同时启用MITTruckProber开关)
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {.$DEFINE DaiForceQueue}
  //包装发货强制队列
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {.$DEFINE JSTruck}
  //格式化计数器车牌
  {.$DEFINE JudgeOrder}
  //验证订单是否出厂
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {.$DEFINE LEDShowTruckEx}
  //大屏显示格式化车牌
  {.$DEFINE OneTruckMulCard}
  //一车多卡
  {.$DEFINE FilterTunnel}
  //过滤无关通道
  {.$DEFINE AutoGetLineGroup}
  //自动获取装车线分组
  {.$DEFINE NoPointLine}
  //开单不强制指定装车线(此开关为AutoGetLineGroup下子开关)
  {$DEFINE PrepareShowTruck}
  //预刷卡显示车牌
  {$DEFINE PreShowEx}
  //预刷卡特殊显示
  {.$DEFINE PrepareShowOnLading}
  //刷卡装车时控制预刷卡(不使用预刷卡读卡器)
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {.$DEFINE ManuPack}
  //人工选择包装类型
  {.$DEFINE RemoteSnap}
  //车牌识别
  {.$DEFINE HKVDVR}
  //服务器抓拍
  {$DEFINE FORCEOPENDOOR}
  //强制抬杆
  {$DEFINE InfoConfirm}
  //刷卡信息确认
  {$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE PrintHuaYanDan}
  //打印化验单
  {$DEFINE PrintHeGeZheng}
  //打印合格证
  {$DEFINE DaiNoWeight}
  //包装不报重量
  {.$DEFINE VerifyHYRecord}
  //化验记录不存在无法开单
  {$DEFINE PrePTruckYs}
  //采购预制皮重车辆验收
  {$DEFINE SaveOrderNo}
  //保存订单编号
  {.$DEFINE DaiNoPrint}
  //包装出厂不打印
  {.$DEFINE DaiQuickSync}
  //包装开单及推单
  {$DEFINE ValueLimit}
  //限制开单上限
  {.$DEFINE PTruckCount}
  //限制原材料车辆数量
  {.$DEFINE PTimeControl}
  //限制原材料入厂时间
  {.$DEFINE GetReportByBrand}
  //化验单模板按品牌区分
  {.$DEFINE AICMNoVerifyTruck}
  //自助开单不校验车牌号
  {$DEFINE WarnPValue}
  //皮重预警
  {$DEFINE FixLoad}
  //转子秤定制装车
  {.$DEFINE SanCardUseCount}
  //散装现场刷卡次数
  {$DEFINE FixLoadNoControlValue}
  //转子秤定制装车(不控制开单量)
  {$DEFINE YanShouByCard}
  //刷卡验收并进行连锁控制
  {$DEFINE YanShouOnlyShow}
  //刷卡验收只通过网口小屏显示信息(此开关为YanShouByCard下子开关)
  {$DEFINE YanShouTunnelByDict}
  //刷卡验收通道从DICT获取(此开关为YanShouByCard下子开关)
  {$DEFINE LedNew}
  //网口小屏新驱动
  {$DEFINE BasisWeightWithPM}
  //库底计量: 定量装车时过皮毛中
  {$DEFINE BasisWeight}
  //库底计量: 定量装车
  {$DEFINE SNLX}
  //水泥流向
  {$DEFINE TruckType}
  //车轴类型
  {$DEFINE ProShip}
  //采购船号
{$ENDIF}

//安仁南方
{$IFDEF ARNF}
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
  {.$DEFINE TruckProberEx}
  //车检光栅状态判断扩展(此开关启用时建议同时启用MITTruckProber开关)
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {.$DEFINE DaiForceQueue}
  //包装发货强制队列
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {.$DEFINE JudgeOrder}
  //验证订单是否出厂
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {.$DEFINE LEDShowTruckEx}
  //大屏显示格式化车牌
  {.$DEFINE OneTruckMulCard}
  //一车多卡
  {.$DEFINE FilterTunnel}
  //过滤无关通道
  {.$DEFINE AutoGetLineGroup}
  //自动获取装车线分组
  {.$DEFINE NoPointLine}
  //开单不强制指定装车线(此开关为AutoGetLineGroup下子开关)
  {$DEFINE PrepareShowTruck}
  //预刷卡显示车牌
  {$DEFINE PreShowEx}
  //预刷卡特殊显示
  {.$DEFINE PrepareShowOnLading}
  //刷卡装车时控制预刷卡(不使用预刷卡读卡器)
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {.$DEFINE ManuPack}
  //人工选择包装类型
  {.$DEFINE RemoteSnap}
  //车牌识别
  {.$DEFINE HKVDVR}
  //服务器抓拍
  {$DEFINE FORCEOPENDOOR}
  //强制抬杆
  {$DEFINE InfoConfirm}
  //刷卡信息确认
  {$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE PrintHuaYanDan}
  //打印化验单
  {$DEFINE PrintHeGeZheng}
  //打印合格证
  {$DEFINE PrintHeGeZhengByHYDan}
  //打印合格证(使用化验单模式,该开关启用后不再打合格证)
  {$DEFINE DaiNoWeight}
  //包装不报重量
  {.$DEFINE VerifyHYRecord}
  //化验记录不存在无法开单
  {$DEFINE PrePTruckYs}
  //采购预制皮重车辆验收
  {$DEFINE SaveOrderNo}
  //保存订单编号
  {.$DEFINE DaiNoPrint}
  //包装出厂不打印
  {.$DEFINE DaiQuickSync}
  //包装开单及推单
  {$DEFINE ValueLimit}
  //限制开单上限
  {.$DEFINE PTruckCount}
  //限制原材料车辆数量
  {.$DEFINE PTimeControl}
  //限制原材料入厂时间
  {.$DEFINE GetReportByBrand}
  //化验单模板按品牌区分
  {.$DEFINE AICMNoVerifyTruck}
  //自助开单不校验车牌号
  {$DEFINE WarnPValue}
  //皮重预警
  {$DEFINE FixLoad}
  //转子秤定制装车
  {.$DEFINE SanCardUseCount}
  //散装现场刷卡次数
  {$DEFINE FixLoadNoControlValue}
  //转子秤定制装车(不控制开单量)
  {$DEFINE YanShouByCard}
  //刷卡验收并进行连锁控制
  {$DEFINE YanShouOnlyShow}
  //刷卡验收只通过网口小屏显示信息(此开关为YanShouByCard下子开关)
  {$DEFINE YanShouTunnelByDict}
  //刷卡验收通道从DICT获取(此开关为YanShouByCard下子开关)
  {$DEFINE LedNew}
  //网口小屏新驱动
  {$DEFINE BasisWeightWithPM}
  //库底计量: 定量装车时过皮毛中
  {$DEFINE BasisWeight}
  //库底计量: 定量装车
  {$DEFINE SNLX}
  //水泥流向
  {$DEFINE TruckType}
  //车轴类型
  {$DEFINE ProShip}
  //采购船号
  {$DEFINE P011CEX}
  //喷码地址发FF
  {$DEFINE ERROPENONEDOOR}
  //过磅失败倒车下磅
  {$DEFINE AICMSmallFont}
  //自助机小字体
  {$DEFINE DaiSyncWithNow}
  //包装不过磅情况下,因上传在前，出厂在后，上传时间使用开单时间，此开关启用强制使用当前时间
  {$DEFINE AICMPDSearch}
  //自助机拼单全部显示
{$ENDIF}

//张家界南方
{$IFDEF ZJJNF}
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
  {.$DEFINE TruckProberEx}
  //车检光栅状态判断扩展(此开关启用时建议同时启用MITTruckProber开关)
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {.$DEFINE DaiForceQueue}
  //包装发货强制队列
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {.$DEFINE JudgeOrder}
  //验证订单是否出厂
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {.$DEFINE LEDShowTruckEx}
  //大屏显示格式化车牌
  {.$DEFINE OneTruckMulCard}
  //一车多卡
  {.$DEFINE FilterTunnel}
  //过滤无关通道
  {.$DEFINE AutoGetLineGroup}
  //自动获取装车线分组
  {.$DEFINE NoPointLine}
  //开单不强制指定装车线(此开关为AutoGetLineGroup下子开关)
  {$DEFINE PrepareShowTruck}
  //预刷卡显示车牌
  {$DEFINE PreShowEx}
  //预刷卡特殊显示
  {.$DEFINE PrepareShowOnLading}
  //刷卡装车时控制预刷卡(不使用预刷卡读卡器)
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {.$DEFINE ManuPack}
  //人工选择包装类型
  {.$DEFINE RemoteSnap}
  //车牌识别
  {.$DEFINE HKVDVR}
  //服务器抓拍
  {$DEFINE FORCEOPENDOOR}
  //强制抬杆
  {$DEFINE InfoConfirm}
  //刷卡信息确认
  {$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE PrintHuaYanDan}
  //打印化验单
  {$DEFINE PrintHeGeZheng}
  //打印合格证
  {$DEFINE DaiNoWeight}
  //包装不报重量
  {.$DEFINE VerifyHYRecord}
  //化验记录不存在无法开单
  {$DEFINE PrePTruckYs}
  //采购预制皮重车辆验收
  {$DEFINE SaveOrderNo}
  //保存订单编号
  {.$DEFINE DaiNoPrint}
  //包装出厂不打印
  {.$DEFINE DaiQuickSync}
  //包装开单及推单
  {$DEFINE ValueLimit}
  //限制开单上限
  {.$DEFINE PTruckCount}
  //限制原材料车辆数量
  {$DEFINE PTimeControl}
  //限制原材料入厂时间
  {.$DEFINE GetReportByBrand}
  //化验单模板按品牌区分
  {.$DEFINE AICMNoVerifyTruck}
  //自助开单不校验车牌号
  {$DEFINE WarnPValue}
  //皮重预警
  {$DEFINE FixLoad}
  //转子秤定制装车
  {.$DEFINE SanCardUseCount}
  //散装现场刷卡次数
  {$DEFINE FixLoadNoControlValue}
  //转子秤定制装车(不控制开单量)
  {$DEFINE YanShouByCard}
  //刷卡验收并进行连锁控制
  {$DEFINE YanShouOnlyShow}
  //刷卡验收只通过网口小屏显示信息(此开关为YanShouByCard下子开关)
  {$DEFINE YanShouTunnelByDict}
  //刷卡验收通道从DICT获取(此开关为YanShouByCard下子开关)
  {$DEFINE LedNew}
  //网口小屏新驱动
  {.$DEFINE BasisWeightWithPM}
  //库底计量: 定量装车时过皮毛中
  {.$DEFINE BasisWeight}
  //库底计量: 定量装车
  {$DEFINE SNLX}
  //水泥流向
  {$DEFINE TruckType}
  //车轴类型
  {$DEFINE ProShip}
  //采购船号
  {$DEFINE PurQueue}
  //采购船号
  {$DEFINE DaiSyncByZT}
  //包装刷卡推单
  {$DEFINE SyncSanByBFM}
  //过毛推单(散装)
  {$DEFINE BFLedEx}
  //过磅小屏增加品种缩写
  {$DEFINE InFactOnlyOne}
  //只允许进厂一次
  {$DEFINE RemoteSnap}
  //车牌识别
  {$DEFINE OrderUsedOne}
  //销售订单只使用一次
  {$DEFINE PoundVocieValue}
  //过磅播报重量
{$ENDIF}

//金磊南方
{$IFDEF JINLEINF}
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
  {.$DEFINE TruckProberEx}
  //车检光栅状态判断扩展(此开关启用时建议同时启用MITTruckProber开关)
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {.$DEFINE DaiForceQueue}
  //包装发货强制队列
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {.$DEFINE JudgeOrder}
  //验证订单是否出厂
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {.$DEFINE LEDShowTruckEx}
  //大屏显示格式化车牌
  {.$DEFINE OneTruckMulCard}
  //一车多卡
  {.$DEFINE FilterTunnel}
  //过滤无关通道
  {.$DEFINE AutoGetLineGroup}
  //自动获取装车线分组
  {.$DEFINE NoPointLine}
  //开单不强制指定装车线(此开关为AutoGetLineGroup下子开关)
  {$DEFINE PrepareShowTruck}
  //预刷卡显示车牌
  {$DEFINE PreShowEx}
  //预刷卡特殊显示
  {.$DEFINE PrepareShowOnLading}
  //刷卡装车时控制预刷卡(不使用预刷卡读卡器)
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {.$DEFINE ManuPack}
  //人工选择包装类型
  {.$DEFINE RemoteSnap}
  //车牌识别
  {.$DEFINE HKVDVR}
  //服务器抓拍
  {$DEFINE FORCEOPENDOOR}
  //强制抬杆
  {$DEFINE InfoConfirm}
  //刷卡信息确认
  {$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE PrintHuaYanDan}
  //打印化验单
  {$DEFINE PrintHeGeZheng}
  //打印合格证
  {$DEFINE DaiNoWeight}
  //包装不报重量
  {.$DEFINE VerifyHYRecord}
  //化验记录不存在无法开单
  {$DEFINE PrePTruckYs}
  //采购预制皮重车辆验收
  {$DEFINE SaveOrderNo}
  //保存订单编号
  {.$DEFINE DaiNoPrint}
  //包装出厂不打印
  {.$DEFINE DaiQuickSync}
  //包装开单及推单
  {$DEFINE ValueLimit}
  //限制开单上限
  {.$DEFINE PTruckCount}
  //限制原材料车辆数量
  {$DEFINE PTimeControl}
  //限制原材料入厂时间
  {.$DEFINE GetReportByBrand}
  //化验单模板按品牌区分
  {.$DEFINE AICMNoVerifyTruck}
  //自助开单不校验车牌号
  {$DEFINE WarnPValue}
  //皮重预警
  {$DEFINE FixLoad}
  //转子秤定制装车
  {.$DEFINE SanCardUseCount}
  //散装现场刷卡次数
  {$DEFINE FixLoadNoControlValue}
  //转子秤定制装车(不控制开单量)
  {$DEFINE YanShouByCard}
  //刷卡验收并进行连锁控制
  {$DEFINE YanShouOnlyShow}
  //刷卡验收只通过网口小屏显示信息(此开关为YanShouByCard下子开关)
  {$DEFINE YanShouTunnelByDict}
  //刷卡验收通道从DICT获取(此开关为YanShouByCard下子开关)
  {$DEFINE LedNew}
  //网口小屏新驱动
  {.$DEFINE BasisWeightWithPM}
  //库底计量: 定量装车时过皮毛中
  {.$DEFINE BasisWeight}
  //库底计量: 定量装车
  {$DEFINE SNLX}
  //水泥流向
  {$DEFINE TruckType}
  //车轴类型
  {$DEFINE ProShip}
  //采购船号
  {.$DEFINE PurQueue}
  //采购船号
  {$DEFINE DaiSyncByZT}
  //包装刷卡推单
  {$DEFINE SyncSanByOut}
  //出厂推单(散装)
  {$DEFINE BFLedEx}
  //过磅小屏增加品种缩写
  {.$DEFINE InFactOnlyOne}
  //只允许进厂一次
  {$DEFINE RemoteSnap}
  //车牌识别
  {$DEFINE OrderUsedOne}
  //销售订单只使用一次
  {$DEFINE BatCodeByLine}
  //现场获取批次
  {$DEFINE AutoOutByStokNo}
  //根据物料号虚拟出厂
  {$DEFINE PoundVocieValue}
  //过磅成功播报重量
  {$DEFINE AICMSmallFont}
  //自助机小字体
  {$DEFINE PrintHyOnSaveBill}
  //开单打印化验单
  {$DEFINE ShipTmpReturnG}
  //临时业务固定卡出厂回收
  {$DEFINE AskUnLoad}
  //询问是否输入卸货地点
{$ENDIF}

//邵阳南方
{$IFDEF SHAOYANGNF}
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
  {.$DEFINE TruckProberEx}
  //车检光栅状态判断扩展(此开关启用时建议同时启用MITTruckProber开关)
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {$DEFINE DaiForceQueue}
  //包装发货强制队列
  {$DEFINE SanForceQueue}
  //散装发货强制队列
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {.$DEFINE JudgeOrder}
  //验证订单是否出厂
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {.$DEFINE LEDShowTruckEx}
  //大屏显示格式化车牌
  {.$DEFINE OneTruckMulCard}
  //一车多卡
  {.$DEFINE FilterTunnel}
  //过滤无关通道
  {.$DEFINE AutoGetLineGroup}
  //自动获取装车线分组
  {.$DEFINE NoPointLine}
  //开单不强制指定装车线(此开关为AutoGetLineGroup下子开关)
  {$DEFINE PrepareShowTruck}
  //预刷卡显示车牌
  {$DEFINE PreShowEx}
  //预刷卡特殊显示
  {.$DEFINE PrepareShowOnLading}
  //刷卡装车时控制预刷卡(不使用预刷卡读卡器)
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {.$DEFINE ManuPack}
  //人工选择包装类型
  {.$DEFINE HKVDVR}
  //服务器抓拍
  {$DEFINE FORCEOPENDOOR}
  //强制抬杆
  {$DEFINE InfoConfirm}
  //刷卡信息确认
  {$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE PrintHuaYanDan}
  //打印化验单
  {$DEFINE PrintHeGeZheng}
  //打印合格证
  {$DEFINE DaiNoWeight}
  //包装不报重量
  {.$DEFINE VerifyHYRecord}
  //化验记录不存在无法开单
  {$DEFINE PrePTruckYs}
  //采购预制皮重车辆验收
  {$DEFINE SaveOrderNo}
  //保存订单编号
  {.$DEFINE DaiNoPrint}
  //包装出厂不打印
  {$DEFINE ValueLimit}
  //限制开单上限
  {.$DEFINE PTruckCount}
  //限制原材料车辆数量
  {$DEFINE PTimeControl}
  //限制原材料入厂时间
  {.$DEFINE GetReportByBrand}
  //化验单模板按品牌区分
  {.$DEFINE AICMNoVerifyTruck}
  //自助开单不校验车牌号
  {$DEFINE WarnPValue}
  //皮重预警
  {$DEFINE FixLoad}
  //转子秤定制装车
  {.$DEFINE SanCardUseCount}
  //散装现场刷卡次数
  {$DEFINE FixLoadNoControlValue}
  //转子秤定制装车(不控制开单量)
  {$DEFINE YanShouByCard}
  //刷卡验收并进行连锁控制
  {$DEFINE YanShouOnlyShow}
  //刷卡验收只通过网口小屏显示信息(此开关为YanShouByCard下子开关)
  {$DEFINE YanShouTunnelByDict}
  //刷卡验收通道从DICT获取(此开关为YanShouByCard下子开关)
  {$DEFINE LedNew}
  //网口小屏新驱动
  {$DEFINE BasisWeightWithPM}
  //库底计量: 定量装车时过皮毛中
  {$DEFINE BasisWeight}
  //库底计量: 定量装车
  {$DEFINE SNLX}
  //水泥流向
  {$DEFINE TruckType}
  //车轴类型
  {$DEFINE ProShip}
  //采购船号
  {$DEFINE PurQueue}
  //采购船号
  {$DEFINE BFLedEx}
  //过磅小屏增加品种缩写
  {.$DEFINE InFactOnlyOne}
  //只允许进厂一次
  {$DEFINE RemoteSnap}
  //车牌识别
  {$DEFINE OrderUsedOne}
  //销售订单只使用一次
  {.$DEFINE BatCodeByLine}
  //现场获取批次
  {$DEFINE AutoOutByStokNo}
  //根据物料号虚拟出厂
  {$DEFINE PoundVocieValue}
  //过磅成功播报重量
  {$DEFINE AICMSmallFont}
  //自助机小字体
  {.$DEFINE PrintHyOnSaveBill}
  //开单打印化验单
  {$DEFINE ShipTmpReturnG}
  //临时业务固定卡出厂回收
  //========推单开关=========全部不启用为出厂推单，启用任意开关需注意避免数据重复推送
  {.$DEFINE DaiQuickSync}
  //包装开单及推单
  {.$DEFINE DaiSyncByZT}
  //包装刷卡推单
  {.$DEFINE SyncSanByOut}
  //出厂推单(散装)
  {.$DEFINE SyncSanByBFM}
  //过毛推单(散装)
  {.$DEFINE SyncDataByBFM}
  //称完毛重即推单
  //========推单开关=========
{$ENDIF}

//苏仙南方
{$IFDEF SUXIANNF}
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
  {.$DEFINE TruckProberEx}
  //车检光栅状态判断扩展(此开关启用时建议同时启用MITTruckProber开关)
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {$DEFINE DaiForceQueue}
  //包装发货强制队列
  {$DEFINE SanForceQueue}
  //散装发货强制队列
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {.$DEFINE JudgeOrder}
  //验证订单是否出厂
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {.$DEFINE LEDShowTruckEx}
  //大屏显示格式化车牌
  {.$DEFINE OneTruckMulCard}
  //一车多卡
  {.$DEFINE FilterTunnel}
  //过滤无关通道
  {.$DEFINE AutoGetLineGroup}
  //自动获取装车线分组
  {.$DEFINE NoPointLine}
  //开单不强制指定装车线(此开关为AutoGetLineGroup下子开关)
  {$DEFINE PrepareShowTruck}
  //预刷卡显示车牌
  {$DEFINE PreShowEx}
  //预刷卡特殊显示
  {.$DEFINE PrepareShowOnLading}
  //刷卡装车时控制预刷卡(不使用预刷卡读卡器)
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {.$DEFINE ManuPack}
  //人工选择包装类型
  {.$DEFINE HKVDVR}
  //服务器抓拍
  {$DEFINE FORCEOPENDOOR}
  //强制抬杆
  {$DEFINE InfoConfirm}
  //刷卡信息确认
  {$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE PrintHuaYanDan}
  //打印化验单
  {$DEFINE PrintHeGeZheng}
  //打印合格证
  {$DEFINE DaiNoWeight}
  //包装不报重量
  {.$DEFINE VerifyHYRecord}
  //化验记录不存在无法开单
  {$DEFINE PrePTruckYs}
  //采购预制皮重车辆验收
  {$DEFINE SaveOrderNo}
  //保存订单编号
  {.$DEFINE DaiNoPrint}
  //包装出厂不打印
  {$DEFINE ValueLimit}
  //限制开单上限
  {.$DEFINE PTruckCount}
  //限制原材料车辆数量
  {$DEFINE PTimeControl}
  //限制原材料入厂时间
  {.$DEFINE GetReportByBrand}
  //化验单模板按品牌区分
  {.$DEFINE AICMNoVerifyTruck}
  //自助开单不校验车牌号
  {$DEFINE WarnPValue}
  //皮重预警
  {$DEFINE FixLoad}
  //转子秤定制装车
  {.$DEFINE SanCardUseCount}
  //散装现场刷卡次数
  {$DEFINE FixLoadNoControlValue}
  //转子秤定制装车(不控制开单量)
  {$DEFINE YanShouByCard}
  //刷卡验收并进行连锁控制
  {$DEFINE YanShouOnlyShow}
  //刷卡验收只通过网口小屏显示信息(此开关为YanShouByCard下子开关)
  {$DEFINE YanShouTunnelByDict}
  //刷卡验收通道从DICT获取(此开关为YanShouByCard下子开关)
  {$DEFINE LedNew}
  //网口小屏新驱动
  {$DEFINE BasisWeightWithPM}
  //库底计量: 定量装车时过皮毛中
  {$DEFINE BasisWeight}
  //库底计量: 定量装车
  {$DEFINE SNLX}
  //水泥流向
  {$DEFINE TruckType}
  //车轴类型
  {$DEFINE ProShip}
  //采购船号
  {$DEFINE PurQueue}
  //采购船号
  {$DEFINE BFLedEx}
  //过磅小屏增加品种缩写
  {.$DEFINE InFactOnlyOne}
  //只允许进厂一次
  {$DEFINE RemoteSnap}
  //车牌识别
  {$DEFINE OrderUsedOne}
  //销售订单只使用一次
  {.$DEFINE BatCodeByLine}
  //现场获取批次
  {$DEFINE AutoOutByStokNo}
  //根据物料号虚拟出厂
  {$DEFINE PoundVocieValue}
  //过磅成功播报重量
  {$DEFINE AICMSmallFont}
  //自助机小字体
  {.$DEFINE PrintHyOnSaveBill}
  //开单打印化验单
  {$DEFINE ShipTmpReturnG}
  //临时业务固定卡出厂回收
  //========推单开关=========全部不启用为出厂推单，启用任意开关需注意避免数据重复推送
  {.$DEFINE DaiQuickSync}
  //包装开单及推单
  {.$DEFINE DaiSyncByZT}
  //包装刷卡推单
  {.$DEFINE SyncSanByOut}
  //出厂推单(散装)
  {.$DEFINE SyncSanByBFM}
  //过毛推单(散装)
  {.$DEFINE SyncDataByBFM}
  //称完毛重即推单
  //========推单开关=========
  {$DEFINE PurTruckType}
  //采购车轴类型
{$ENDIF}

//祁东南方
{$IFDEF QIDONGNF}
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
  {.$DEFINE TruckProberEx}
  //车检光栅状态判断扩展(此开关启用时建议同时启用MITTruckProber开关)
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {.$DEFINE DaiForceQueue}
  //包装发货强制队列
  {.$DEFINE SanForceQueue}
  //散装发货强制队列
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {.$DEFINE JudgeOrder}
  //验证订单是否出厂
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {.$DEFINE LEDShowTruckEx}
  //大屏显示格式化车牌
  {.$DEFINE OneTruckMulCard}
  //一车多卡
  {.$DEFINE FilterTunnel}
  //过滤无关通道
  {.$DEFINE AutoGetLineGroup}
  //自动获取装车线分组
  {.$DEFINE NoPointLine}
  //开单不强制指定装车线(此开关为AutoGetLineGroup下子开关)
  {$DEFINE PrepareShowTruck}
  //预刷卡显示车牌
  {$DEFINE PreShowEx}
  //预刷卡特殊显示
  {.$DEFINE PrepareShowOnLading}
  //刷卡装车时控制预刷卡(不使用预刷卡读卡器)
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {.$DEFINE ManuPack}
  //人工选择包装类型
  {.$DEFINE HKVDVR}
  //服务器抓拍
  {$DEFINE FORCEOPENDOOR}
  //强制抬杆
  {$DEFINE InfoConfirm}
  //刷卡信息确认
  {$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE PrintHuaYanDan}
  //打印化验单
  {$DEFINE PrintHeGeZheng}
  //打印合格证
  {$DEFINE DaiNoWeight}
  //包装不报重量
  {.$DEFINE VerifyHYRecord}
  //化验记录不存在无法开单
  {$DEFINE PrePTruckYs}
  //采购预制皮重车辆验收
  {$DEFINE SaveOrderNo}
  //保存订单编号
  {.$DEFINE DaiNoPrint}
  //包装出厂不打印
  {$DEFINE ValueLimit}
  //限制开单上限
  {.$DEFINE PTruckCount}
  //限制原材料车辆数量
  {$DEFINE PTimeControl}
  //限制原材料入厂时间
  {.$DEFINE GetReportByBrand}
  //化验单模板按品牌区分
  {.$DEFINE AICMNoVerifyTruck}
  //自助开单不校验车牌号
  {$DEFINE WarnPValue}
  //皮重预警
  {.$DEFINE FixLoad}
  //转子秤定制装车
  {.$DEFINE SanCardUseCount}
  //散装现场刷卡次数
  {.$DEFINE FixLoadNoControlValue}
  //转子秤定制装车(不控制开单量)
  {$DEFINE YanShouByCard}
  //刷卡验收并进行连锁控制
  {$DEFINE YanShouOnlyShow}
  //刷卡验收只通过网口小屏显示信息(此开关为YanShouByCard下子开关)
  {$DEFINE YanShouTunnelByDict}
  //刷卡验收通道从DICT获取(此开关为YanShouByCard下子开关)
  {$DEFINE LedNew}
  //网口小屏新驱动
  {.$DEFINE BasisWeightWithPM}
  //库底计量: 定量装车时过皮毛中
  {.$DEFINE BasisWeight}
  //库底计量: 定量装车
  {$DEFINE SNLX}
  //水泥流向
  {$DEFINE TruckType}
  //车轴类型
  {$DEFINE TruckTypeOnlyPound}
  //车轴类型(只在地磅校验)
  {$DEFINE ProShip}
  //采购船号
  {.$DEFINE PurQueue}
  //采购船号
  {$DEFINE BFLedEx}
  //过磅小屏增加品种缩写
  {.$DEFINE InFactOnlyOne}
  //只允许进厂一次
  {$DEFINE RemoteSnap}
  //车牌识别
  {$DEFINE OrderUsedOne}
  //销售订单只使用一次
  {.$DEFINE BatCodeByLine}
  //现场获取批次
  {$DEFINE AutoOutByStokNo}
  //根据物料号虚拟出厂
  {$DEFINE PoundVocieValue}
  //过磅成功播报重量
  {$DEFINE AICMSmallFont}
  //自助机小字体
  {.$DEFINE PrintHyOnSaveBill}
  //开单打印化验单
  {$DEFINE ShipTmpReturnG}
  //临时业务固定卡出厂回收
  //========推单开关=========全部不启用为出厂推单，启用任意开关需注意避免数据重复推送
  {.$DEFINE DaiQuickSync}
  //包装开单及推单
  {.$DEFINE DaiSyncByZT}
  //包装刷卡推单
  {.$DEFINE SyncSanByOut}
  //出厂推单(散装)
  {.$DEFINE SyncSanByBFM}
  //过毛推单(散装)
  {.$DEFINE SyncDataByBFM}
  //称完毛重即推单
  //========推单开关=========
  {.$DEFINE PurTruckType}
  //采购车轴类型
{$ENDIF}

//隆回南方
{$IFDEF LONGHUINF}
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
  {.$DEFINE TruckProberEx}
  //车检光栅状态判断扩展(此开关启用时建议同时启用MITTruckProber开关)
  {$DEFINE MultiReplay}
  //计数器应答模式
  {$DEFINE CardProvide}
  //采用复磅模式
  {$DEFINE ORDERVALUE}
  //显示订单量
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {.$DEFINE DaiForceQueue}
  //包装发货强制队列
  {.$DEFINE SanForceQueue}
  //散装发货强制队列
  {$DEFINE AllowMultiM}
  //散装允许多次过重车
  {$DEFINE JSTruck}
  //格式化计数器车牌
  {.$DEFINE JudgeOrder}
  //验证订单是否出厂
  {$DEFINE SaleAICMFromNC}
  //销售自助办卡
  {$DEFINE PurAICMFromNC}
  //采购自助办卡
  {.$DEFINE LEDShowTruckEx}
  //大屏显示格式化车牌
  {.$DEFINE OneTruckMulCard}
  //一车多卡
  {.$DEFINE FilterTunnel}
  //过滤无关通道
  {.$DEFINE AutoGetLineGroup}
  //自动获取装车线分组
  {.$DEFINE NoPointLine}
  //开单不强制指定装车线(此开关为AutoGetLineGroup下子开关)
  {$DEFINE PrepareShowTruck}
  //预刷卡显示车牌
  {$DEFINE PreShowEx}
  //预刷卡特殊显示
  {.$DEFINE PrepareShowOnLading}
  //刷卡装车时控制预刷卡(不使用预刷卡读卡器)
  {$DEFINE PrintChinese}
  //汉字喷码支持
  {.$DEFINE ManuPack}
  //人工选择包装类型
  {.$DEFINE HKVDVR}
  //服务器抓拍
  {$DEFINE FORCEOPENDOOR}
  //强制抬杆
  {$DEFINE InfoConfirm}
  //刷卡信息确认
  {$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE PrintHuaYanDan}
  //打印化验单
  {$DEFINE PrintHeGeZheng}
  //打印合格证
  {$DEFINE DaiNoWeight}
  //包装不报重量
  {.$DEFINE VerifyHYRecord}
  //化验记录不存在无法开单
  {$DEFINE PrePTruckYs}
  //采购预制皮重车辆验收
  {$DEFINE SaveOrderNo}
  //保存订单编号
  {.$DEFINE DaiNoPrint}
  //包装出厂不打印
  {$DEFINE ValueLimit}
  //限制开单上限
  {.$DEFINE PTruckCount}
  //限制原材料车辆数量
  {$DEFINE PTimeControl}
  //限制原材料入厂时间
  {.$DEFINE GetReportByBrand}
  //化验单模板按品牌区分
  {.$DEFINE AICMNoVerifyTruck}
  //自助开单不校验车牌号
  {$DEFINE WarnPValue}
  //皮重预警
  {.$DEFINE FixLoad}
  //转子秤定制装车
  {.$DEFINE SanCardUseCount}
  //散装现场刷卡次数
  {.$DEFINE FixLoadNoControlValue}
  //转子秤定制装车(不控制开单量)
  {$DEFINE YanShouByCard}
  //刷卡验收并进行连锁控制
  {$DEFINE YanShouOnlyShow}
  //刷卡验收只通过网口小屏显示信息(此开关为YanShouByCard下子开关)
  {$DEFINE YanShouTunnelByDict}
  //刷卡验收通道从DICT获取(此开关为YanShouByCard下子开关)
  {$DEFINE LedNew}
  //网口小屏新驱动
  {.$DEFINE BasisWeightWithPM}
  //库底计量: 定量装车时过皮毛中
  {.$DEFINE BasisWeight}
  //库底计量: 定量装车
  {$DEFINE SNLX}
  //水泥流向
  {$DEFINE TruckType}
  //车轴类型
  {$DEFINE TruckTypeOnlyPound}
  //车轴类型(只在地磅校验)
  {$DEFINE ProShip}
  //采购船号
  {.$DEFINE PurQueue}
  //采购船号
  {$DEFINE BFLedEx}
  //过磅小屏增加品种缩写
  {.$DEFINE InFactOnlyOne}
  //只允许进厂一次
  {$DEFINE RemoteSnap}
  //车牌识别
  {$DEFINE OrderUsedOne}
  //销售订单只使用一次
  {.$DEFINE BatCodeByLine}
  //现场获取批次
  {$DEFINE AutoOutByStokNo}
  //根据物料号虚拟出厂
  {$DEFINE PoundVocieValue}
  //过磅成功播报重量
  {$DEFINE AICMSmallFont}
  //自助机小字体
  {.$DEFINE PrintHyOnSaveBill}
  //开单打印化验单
  {$DEFINE ShipTmpReturnG}
  //临时业务固定卡出厂回收
  //========推单开关=========全部不启用为出厂推单，启用任意开关需注意避免数据重复推送
  {.$DEFINE DaiQuickSync}
  //包装开单及推单
  {.$DEFINE DaiSyncByZT}
  //包装刷卡推单
  {.$DEFINE SyncSanByOut}
  //出厂推单(散装)
  {.$DEFINE SyncSanByBFM}
  //过毛推单(散装)
  {.$DEFINE SyncDataByBFM}
  //称完毛重即推单
  //========推单开关=========
  {.$DEFINE PurTruckType}
  //采购车轴类型
  {$DEFINE SaveKDValue}
  //保存开单量
{$ENDIF}
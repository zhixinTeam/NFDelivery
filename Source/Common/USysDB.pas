{*******************************************************************************
  作者: dmzn@163.com 2008-08-07
  描述: 系统数据库常量定义

  备注:
  *.自动创建SQL语句,支持变量:$Inc,自增;$Float,浮点;$Integer=sFlag_Integer;
    $Decimal=sFlag_Decimal;$Image,二进制流
*******************************************************************************}
unit USysDB;

{$I Link.inc}
interface

uses
  SysUtils, Classes;

const
  cSysDatabaseName: array[0..4] of String = (
     'Access', 'SQL', 'MySQL', 'Oracle', 'DB2');
  //db names

  cPrecision            = 100;
  {-----------------------------------------------------------------------------
   描述: 计算精度
   *.重量为吨的计算中,小数值比较或者相减运算时会有误差,所以会先放大,去掉
     小数位后按照整数计算.放大倍数由精度值确定.
  -----------------------------------------------------------------------------}

type
  TSysDatabaseType = (dtAccess, dtSQLServer, dtMySQL, dtOracle, dtDB2);
  //db types

  PSysTableItem = ^TSysTableItem;
  TSysTableItem = record
    FTable: string;
    FNewSQL: string;
  end;
  //系统表项

var
  gSysTableList: TList = nil;                        //系统表数组
  gSysDBType: TSysDatabaseType = dtSQLServer;        //系统数据类型

//------------------------------------------------------------------------------
const
  //自增字段
  sField_Access_AutoInc          = 'Counter';
  sField_SQLServer_AutoInc       = 'Integer IDENTITY (1,1) PRIMARY KEY';

  //小数字段
  sField_Access_Decimal          = 'Float';
  sField_SQLServer_Decimal       = 'Decimal(15, 5)';

  //图片字段
  sField_Access_Image            = 'OLEObject';
  sField_SQLServer_Image         = 'Image';

  //日期相关
  sField_SQLServer_Now           = 'getDate()';

ResourceString     
  {*权限项*}
  sPopedom_Read       = 'A';                         //浏览
  sPopedom_Add        = 'B';                         //添加
  sPopedom_Edit       = 'C';                         //修改
  sPopedom_Delete     = 'D';                         //删除
  sPopedom_Preview    = 'E';                         //预览
  sPopedom_Print      = 'F';                         //打印
  sPopedom_Export     = 'G';                         //导出
  sPopedom_ViewPrice  = 'H';                         //查看单价
  sPopedom_FullReport = 'I';                         //原始报表
  sPopedom_ViewDai    = 'J';                         //查看袋装

  {*数据库标识*}
  sFlag_DB_K3         = 'King_K3';                   //金蝶数据库
  sFlag_DB_NC         = 'YonYou_NC';                 //用友数据库
  sFlag_DB_WX         = 'WeiXin_Serv';               //微信数据库
  
  {*相关标记*}
  sFlag_Yes           = 'Y';                         //是
  sFlag_No            = 'N';                         //否
  sFlag_Unknow        = 'U';                         //未知 
  sFlag_Enabled       = 'Y';                         //启用
  sFlag_Disabled      = 'N';                         //禁用
  sFlag_SHaulback     = 'P';                         //回空
  sFlag_OK            = 'O';                         //OK

  sFlag_Integer       = 'I';                         //整数
  sFlag_Decimal       = 'D';                         //小数

  sFlag_ManualNo      = '%';                         //手动指定(非系统自动)
  sFlag_NotMatter     = '@';                         //无关编号(任意编号都可)
  sFlag_ForceDone     = '#';                         //强制完成(未完成前不换)
  sFlag_FixedNo       = '$';                         //指定编号(使用相同编号)

  sFlag_Provide       = 'P';                         //供应
  sFlag_Sale          = 'S';                         //销售
  sFlag_Returns       = 'R';                         //退货
  sFlag_Other         = 'O';                         //其它

  sFlag_DuanDao       = 'D';                         //短倒
  sFlag_SaleNew       = 'N';                         //固定卡销售

  sFlag_ShipPro       = 'A';                         //复磅采购
  sFlag_ShipTmp       = 'B';                         //复磅临时
  sFlag_Haulback      = 'C';                         //回空磅单

  sFlag_TiHuo         = 'T';                         //自提
  sFlag_SongH         = 'S';                         //送货
  sFlag_XieH          = 'X';                         //运卸

  sFlag_Dai           = 'D';                         //袋装水泥
  sFlag_San           = 'S';                         //散装水泥

  sFlag_BillNew       = 'N';                         //新单
  sFlag_BillEdit      = 'E';                         //修改
  sFlag_BillDel       = 'D';                         //删除
  sFlag_BillLading    = 'L';                         //提货中
  sFlag_BillPick      = 'P';                         //拣配
  sFlag_BillPost      = 'G';                         //过账
  sFlag_BillDone      = 'O';                         //完成

  sFlag_TypeShip      = 'S';                         //船运
  sFlag_TypeZT        = 'Z';                         //栈台
  sFlag_TypeVIP       = 'V';                         //VIP
  sFlag_TypeCommon    = 'C';                         //普通
  sFlag_TypeStation   = 'H';                         //火车,订单类型

  sFlag_CardIdle      = 'I';                         //空闲卡
  sFlag_CardUsed      = 'U';                         //使用中
  sFlag_CardLoss      = 'L';                         //挂失卡
  sFlag_CardInvalid   = 'N';                         //注销卡
  sFlag_ProvCardL     = 'L';                         //临时
  sFlag_ProvCardG     = 'G';                         //固定

  sFlag_TruckNone     = 'N';                         //无状态车辆
  sFlag_TruckIn       = 'I';                         //进厂车辆
  sFlag_TruckOut      = 'O';                         //出厂车辆
  sFlag_TruckBFP      = 'P';                         //磅房皮重车辆
  sFlag_TruckBFM      = 'M';                         //磅房毛重车辆
  sFlag_TruckSH       = 'S';                         //送货车辆
  sFlag_TruckFH       = 'F';                         //放灰车辆
  sFlag_TruckZT       = 'Z';                         //栈台车辆
  sFlag_TruckXH       = 'X';                         //验收车辆
  sFlag_TruckWT       = 'W';                         //加水车辆                           

  sFlag_PoundBZ       = 'B';                         //标准
  sFlag_PoundPZ       = 'Z';                         //皮重
  sFlag_PoundPD       = 'P';                         //配对
  sFlag_PoundHK       = 'K';                         //回空
  sFlag_PoundCC       = 'C';                         //出厂(过磅模式)
  sFlag_PoundLS       = 'L';                         //临时

  sFlag_DeductFix     = 'F';                         //固定值扣减
  sFlag_DeductPer     = 'P';                         //百分比扣减

  sFlag_AttentionSale = 'S';                         //业务员类型
  sFlag_AttentionCust = 'C';                         //客户类型
  sFlag_AttentionAdmin= 'G';                         //管理员类型

  sFlag_BatchInUse    = 'Y';                         //批次号有效
  sFlag_BatchOutUse   = 'N';                         //批次号已封存
  sFlag_BatchDel      = 'D';                         //批次号已删除

  sFlag_ManualA       = 'A';                         //皮重预警(错误事件类型)
  sFlag_ManualB       = 'B';                         //皮重超出范围
  sFlag_ManualC       = 'C';                         //净重超出误差范围
  sFlag_ManualE       = 'E';                         //车牌识别
  sFlag_ManualF       = 'F';                         //喷码发送
  sFlag_ManualP       = 'P';                         //自动预制皮重
  sFlag_ManualH       = 'H';                         //核载量

  sFlag_SysParam      = 'SysParam';                  //系统参数
  sFlag_EnableBakdb   = 'Uses_BackDB';               //备用库
  sFlag_ValidDate     = 'SysValidDate';              //有效期
  sFlag_PrintBill     = 'PrintStockBill';            //需打印品种
  sFlag_NOPrintBill   = 'NOPrintStock';              //无需打印品种
  sFlag_NFStock       = 'NoFaHuoStock';              //现场无需发货
  sFlag_StockIfYS     = 'StockIfYS';                 //现场是否验收
  sFlag_ViaBillCard   = 'ViaBillCard';               //直接制卡
  sFlag_DispatchPound = 'PoundDispatch';             //磅站调度
  sFlag_PSanWuChaStop = 'PoundSanWuChaStop';         //超出误差停止业务
  sFlag_ForceAddWater = 'ForceAddWater';             //强制加水品种
  sFlag_ShadowWeight  = 'ShadowWeight';              //影子重量
  sFlag_SanMaxLadeValue= 'SanMaxLadeValue';          //散装最大开单量限制
  sFlag_OutByPreYs    = 'TruckOutByPreYs';           //验收后自动出厂物料
  sFlag_ForceTruckSanMaxLade= 'ForceTruckSanMaxLade';//车辆散装最大开单量限制
  sFlag_AICMPurMinValue= 'AICMPurMinValue';          //自助机采购订单最小剩余量
  sFlag_CusBmFromDict = 'CusBmFromDict';             //从DICT获取客户喷码编码

  sFlag_AICMPurStock  = 'AICMPurStock';              //自助机允许办卡物料
  sFlag_PrintPur      = 'PrintStockPur';             //需打印品种(采购)

  sFlag_StationAutoP  = 'StationAutoP';              //火车衡自动获取皮重

  sFlag_PrinterBill   = 'PrinterBill';               //小票打印机
  sFlag_PrinterHYDan  = 'PrinterHYDan';              //化验单打印机
  
  sFlag_PoundIfDai    = 'PoundIFDai';                //袋装是否过磅
  sFlag_PoundWuCha    = 'PoundWuCha';                //过磅误差分组
  sFlag_PoundPWuChaZ  = 'PoundPWuChaZ';              //皮重正误差
  sFlag_PoundPWuChaF  = 'PoundPWuChaF';              //皮重负误差
  sFlag_ForceVPoundP  = 'ForceVPoundP';              //强制校验皮重D/S
  sFlag_PDaiWuChaZ    = 'PoundDaiWuChaZ';            //袋装正误差
  sFlag_PDaiWuChaF    = 'PoundDaiWuChaF';            //袋装负误差
  sFlag_PDaiPercent   = 'PoundDaiPercent';           //按比例计算误差
  sFlag_PDaiWuChaStop = 'PoundDaiWuChaStop';         //误差时停止业务
  sFlag_PSanWuChaF    = 'PoundSanWuChaF';            //散装负误差
  sFlag_PTruckPWuCha  = 'PoundTruckPValue';          //空车皮误差
  sFlag_PEmpTWuCha    = 'EmpTruckWuCha';             //空车出厂误差
  
  sFlag_CommonItem    = 'CommonItem';                //公共信息
  sFlag_CardItem      = 'CardItem';                  //磁卡信息项
  sFlag_TruckItem     = 'TruckItem';                 //车辆信息项
  sFlag_StockItem     = 'StockItem';                 //水泥信息项
  sFlag_BillItem      = 'BillItem';                  //提单信息项
  sFlag_TruckQueue    = 'TruckQueue';                //车辆队列
  sFlag_LadingItem    = 'LadingItem';                //提货方式信息项
  sFlag_OrderInFact   = 'OrderInFact';               //工厂可发货订单
  sFlag_FactoryItem   = 'FactoryItem';               //工厂信息项
  sFlag_DuctTimeItem  = 'DuctTimeItem';              //暗扣时间段项
  sFlag_TiHuoTypeItem = 'TiHuoTypeItem';             //提货类型
  sFlag_ZTLineGroup   = 'ZTLineGroup';               //栈台分组
  sFlag_BatBrandGroup = 'BatBrandGroup';             //批次品牌分组
  sFlag_BatStockGroup = 'BatStockGroup';             //批次物料分组
  sFlag_AutoBatBrand  = 'AutoBatch_Brand';           //自动批次区分品牌
  sFlag_StockBrandShow= 'StockBrandShow';            //预刷卡品种显示
  sFlag_PoundStation  = 'PoundStation';              //地磅可用磅站,用于指定过磅
  sFlag_OrderFilterH  = 'OrderFilterH';              //工厂订单过滤
  sFlag_OrderBegin    = 'OrderBegin';                //读取订单日期过滤
  sFlag_IDField       = 'IDField';                   //自助机身份证字段
  sFlag_InFactGroup   = 'InFactGroup';               //进厂业务分组

  sFlag_InWHouse      = 'Warehouse';                 //库存可发(收)货订单
  sFlag_InWHID        = 'WarehouseID';               //仓库可发(收)货订单
  sFlag_InFact        = 'Factory';                   //工厂可发(收)货订单
  sFlag_InDepot       = 'Depot';                     //库存编号

  sFlag_CustomerItem  = 'CustomerItem';              //客户信息项
  sFlag_ProviderItem  = 'ProviderItem';              //供应商信息项
  sFlag_MaterailsItem = 'MaterailsItem';             //原材料信息项   
  sFlag_BankItem      = 'BankItem';                  //银行信息项

  sFlag_HardSrvURL    = 'HardMonURL';
  sFlag_MITSrvURL     = 'MITServiceURL';             //服务地址
            
  sFlag_AutoIn        = 'Truck_AutoIn';              //自动进厂
  sFlag_AutoOut       = 'Truck_AutoOut';             //自动出厂
  sFlag_OtherAutoIn   = 'Truck_OtherAutoIn';         //自动进厂(非销售)
  sFlag_OtherAutoOut  = 'Truck_OtherAutoOut';        //自动出厂(非销售)
  sFlag_InTimeout     = 'InFactTimeOut';             //进厂超时(队列)
  sFlag_InAndBill     = 'InFactAndBill';             //进厂开单间隔
  sFlag_InAndPound    = 'InFactAndPound';            //进厂过皮间隔(分钟)
  sFlag_SanMultiBill  = 'SanMultiBill';              //散装预开多单
  sFlag_NoDaiQueue    = 'NoDaiQueue';                //袋装禁用队列
  sFlag_NoSanQueue    = 'NoSanQueue';                //散装禁用队列
  sFlag_DelayQueue    = 'DelayQueue';                //延迟排队(厂内)
  sFlag_PoundQueue    = 'PoundQueue';                //延迟排队(厂内依据过皮时间)
  sFlag_BatchAuto     = 'Batch_Auto';                //自动生成批次号
  sFlag_BatchBrand    = 'Batch_Brand';               //批次区分品牌
  sFlag_BatchValid    = 'Batch_Valid';               //启用批次管理
  sFlag_BatchStockGroup = 'Batch_StockGroup';        //启用批次物料分组
  sFlag_NoBatGroupStock = 'NoBatGroupStock';         //存在通道分组单批次独立物料
  sFlag_PoundBaseValue= 'PoundBaseValue';            //磅房跳动基数
  sFlag_OutOfHaulBack = 'OutOfHaulBack';             //退货(回空)时限
  sFlag_DefaultBrand  = 'DefaultBrand';              //默认品牌
  sFlag_Brands        = 'StockBrands';               //品牌列表
  sFlag_NetPlayVoice  = 'NetPlayVoice';              //使用网络语音卡
  sFlag_PoundCorrections  = 'PoundCorrections';      //磅单勘误
  sFlag_ShowReportStockBill  = 'ShowReportStockBill'; //需打印单品种打印前是否预览
  sFlag_AskPrintStockBill  = 'AskPrintStockBill';     //需打印单品种打印前是否询问
  sFlag_ProvoideCorrections  = 'ProvideCorrections';  //供应勘误
  sFlag_BatcodeDefaultValidDays  = 'BatcodeDefaultValidDays';  //出厂编号默认有限期天数
  sFlag_LineKw        = 'LineKw';                     //装车线所属库位
  sFlag_TransType     = 'TransType';                  //运输方式
  sFlag_DefaultPValue = 'DefaultPValue';             //默认皮重
  sFlag_PValueWuCha   = 'PValueWuCha';               //皮重浮动范围
  sFlag_DaiJudgeTunnel= 'DaiJudgeTunnel';            //袋装禁用队列
  sFlag_SanJudgeTunnel= 'SanJudgeTunnel';            //散装禁用队列
  sFlag_AutoPD        = 'AutoPD';                    //默认袋装全部允许拼单
  sFlag_GPSUrl        = 'GPSUrl';                    //GPS配置

  sFlag_OrderCardID   = 'OrderCardID';               //原材料开单语音播报
  sFlag_NoPlayVoiceStock= 'NoPlayVoiceStock';        //原材料无需语音播报物料

  sFlag_BusGroup      = 'BusFunction';               //业务编码组
  sFlag_BillNo        = 'Bus_Bill';                  //交货单号
  sFlag_PoundID       = 'Bus_Pound';                 //称重记录
  sFlag_WeiXin        = 'Bus_WeiXin';                //微信映射编号
  sFlag_ForceHint     = 'Bus_HintMsg';               //强制提示
  sFlag_Customer      = 'Bus_Customer';              //客户编号
  sFlag_DuctTime      = 'Bus_DuctTime';              //暗扣时间段编号
  sFlag_ProvideBase   = 'Bus_ProvBase';              //采购入厂基础
  sFlag_ProvideDtl    = 'Bus_ProvDtl';               //采购入厂明细
  sFlag_Transfer      = 'Bus_Transfer';              //短倒单号
  sFlag_BillNewNO     = 'Bus_BillNew';
  sFlag_PStationNo    = 'Bus_PStation';              //火车衡称重记录
  sFlag_BillHaulBack  = 'Bus_BillHaulBack';          //回空单号
  sFlag_TruckInNeedManu = 'TruckInNeedManu';         //车牌识别需要人工干预
  sFlag_SnapInfoPost  = 'SnapInfoPost';              //车牌识别消息推送岗位
  sFlag_NeedInfoConfirm = 'NeedInfoConfirm';         //需要进行现场刷卡确认
  sFlag_SanPreKD      = 'SanPreKD';                  //散装定制装车扣吨

  sFlag_WXFactory     = 'WXFactoryID';               //微信标识
  sFlag_WXServiceMIT  = 'WXServiceMIT';              //微信工厂服务
  sFlag_WXSrvRemote   = 'WXServiceRemote';           //微信远程服务

  sFlag_ESBSrv        = 'ESBSrv';                    //微信远程服务
  sFlag_ESBDB         = 'ESBDB';                     //微信远程服务
  sFlag_ESBLog        = 'ESBLog';                    //微信远程服务
  sFlag_ESBPass       = 'ESBPass';                   //微信远程服务

  sFlag_HYDan         = 'Bus_HYDan';                 //化验单号
  sFlag_HYValue       = 'HYMaxValue';                //化验批次量
  sFlag_AICMPDCount   = 'AICMPDCount';               //自助拼单个数
  sFlag_PoundStock    = 'PoundStock';                //地磅允许过磅物料
  sFlag_AutoVipByLine = 'AutoVIPByLine';             //根据通道类型自动调整提货单类型
  sFlag_UnLodingPlace = 'UnLodingPlace';             //卸货地点
  sFlag_ForceUPStock  = 'ForceUPStock';              //强制卸货地点物料
  sFlag_SanUseCardCount= 'SanCardUseCount';          //散装现场刷卡次数
  sFlag_MaterailTunnel= 'MaterailTunnel';            //原材料卸货通道
  sFlag_CusGroup      = 'CusGroup';                  //客户分组
  sFlag_PTruckControl = 'PTruckControl';             //原材料进厂车辆数量总控制
  sFlag_PTimeControlTotal = 'PTimeControl';          //原材料进厂时间总控制
  sFlag_PoundControl  = 'PoundControlTotal';         //允许过磅物料总控制
  sFlag_AICMHYDanPCount= 'AICMHYDanPCount';          //自助机化验单打印次数
  sFlag_DaiQuickSync  = 'DaiQuickSync';              //袋装开单即推单
  sFlag_SetPValue     = 'SetPValue';                 //预设皮重阀值
  sFlag_AICMFP        = 'AICMFP';                    //自助机禁止密码取卡
  sFlag_ReportFileMap = 'ReportFileMap';             //化验单模板匹配
  sFlag_NoPrintHeGe   = 'NoPrintHeGeStock';          //无需打印合格证物料
  sFlag_VIPForceLine  = 'VIPForceLine';              //VIP强制定道
  sFlag_MaxMValueTotal= 'MaxMValueTotal';            //毛重上限总控制
  sFlag_WarnPBegDate  = 'WarnPBegDate';              //预警皮重取值日期
  sFlag_AICMBillPCount= 'AICMBillPCount';            //自助机补打小票次数
  sFlag_TTControl     = 'TruckTypeControl';          //车轴总控制
  sFlag_TruckType     = 'TruckType';                 //车轴
  sFlag_BrandBindPack = 'BrandBindPack';             //自助机同品种不同品牌包装类型
  sFlag_WPValueByStock= 'WarnPValueBYStock';         //根据物料校验皮重
  sFlag_EmptyTruckSync= 'EmptyTruckSync';            //空车出厂上传NC
  sFlag_SoundPost     = 'SoundPost';                 //装车播报语音卡
  sFlag_InFactStock   = 'InFactStock';               //进厂物料
  sFlag_InFactControl = 'InFactControlTotal';        //允许进厂物料总控制
  sFlag_InFactStation = 'InFactStation';             //进厂读卡器
  sFlag_BillXzSync    = 'BillXzSync';                //桐庐用
  sFlag_PreLine       = 'PreLine';                   //预排队
  {*数据表*}
  sTable_Group        = 'Sys_Group';                 //用户组
  sTable_User         = 'Sys_User';                  //用户表
  sTable_Menu         = 'Sys_Menu';                  //菜单表
  sTable_Popedom      = 'Sys_Popedom';               //权限表
  sTable_PopItem      = 'Sys_PopItem';               //权限项
  sTable_Entity       = 'Sys_Entity';                //字典实体
  sTable_DictItem     = 'Sys_DataDict';              //字典明细

  sTable_SysDict      = 'Sys_Dict';                  //系统字典
  sTable_ExtInfo      = 'Sys_ExtInfo';               //附加信息
  sTable_SysLog       = 'Sys_EventLog';              //系统日志
  sTable_BaseInfo     = 'Sys_BaseInfo';              //基础信息
  sTable_SerialBase   = 'Sys_SerialBase';            //编码种子
  sTable_SerialStatus = 'Sys_SerialStatus';          //编号状态
  sTable_WorkePC      = 'Sys_WorkePC';               //验证授权
  sTable_ManualEvent  = 'Sys_ManualEvent';           //人工干预

  sTable_Order        = 'S_Order';                   //销售订单
  sTable_Card         = 'S_Card';                    //销售磁卡
  sTable_Bill         = 'S_Bill';                    //提货单
  sTable_BillBak      = 'S_BillBak';                 //已删交货单
  sTable_BillNew      = 'S_BillNew';                 //交货单基础表
  sTable_BillNewBak   = 'S_BillNewBak';              //已删除表
  sTable_BillHaulBack = 'S_BillHaulBack';            //回空业务表
  sTable_BillHaulBak  = 'S_BillHaulBak';            //回空业务表

  sTable_Mine         = 'S_Mine';                    //矿点表
  sTable_Truck        = 'S_Truck';                   //车辆表
  sTable_TruckSnap    = 'S_TruckSnap';               //停车场车辆抓拍原始数据表
  sTable_Batcode      = 'S_Batcode';                 //批次号
  sTable_ZTLines      = 'S_ZTLines';                 //装车道
  sTable_ZTTrucks     = 'S_ZTTrucks';                //车辆队列
  sTable_Deduct       = 'S_PoundDeduct';             //过磅暗扣
  sTable_PoundShip    = 'S_PoundShip';               //船运离岸单
  sTable_BatcodeDoc   = 'S_BatcodeDoc';              //批次号
  sTable_StationTruck = 'S_StationTruck';            //火车厢
  sTable_Customer     = 'S_Customer';                //客户信息

  sTable_StockMatch   = 'S_StockMatch';              //品种映射
  sTable_StockParam   = 'S_StockParam';              //品种参数
  sTable_StockParamExt= 'S_StockParamExt';           //参数扩展
  sTable_StockRecord  = 'S_StockRecord';             //检验记录
  sTable_StockHuaYan  = 'S_StockHuaYan';             //开化验单

  sTable_PoundLog     = 'Sys_PoundLog';              //过磅数据
  sTable_PoundBak     = 'Sys_PoundBak';              //过磅作废
  sTable_Picture      = 'Sys_Picture';               //存放图片
  sTable_Alivision    = 'Sys_Alivision';             //图像识别
  sTable_PoundDaiWC   = 'Sys_PoundDaiWuCha';         //包装误差
  
  sTable_PoundStation = 'Sys_PoundStation';          //火车衡过磅数据
  sTable_PoundStatBak = 'Sys_PoundStatBak';          //火车衡作废数据
  sTable_PoundStatIMP = 'Sys_PoundStatIMP';          //火车衡过磅数据
  sTable_PoundStatIMPBak = 'Sys_PoundStatIMPBak';    //火车衡作废数据

  sTable_PoundLogKs   = 'Sys_PoundLogKS';            //矿山过磅数据

  sTable_Provider     = 'P_Provider';                //客户表
  sTable_Materails    = 'P_Materails';               //物料表
  sTable_ProvBase     = 'P_ProvideBase';             //采购申请订单
  sTable_ProvBaseBak  = 'P_ProvideBaseBak';          //已删除采购申请订单
  sTable_ProvDtl      = 'P_ProvideDtl';              //采购订单明细
  sTable_ProvDtlBak   = 'P_ProvideDtlBak';           //采购订单明细
  sTable_Transfer     = 'P_Transfer';                //短倒明细单
  sTable_TransferBak  = 'P_TransferBak';             //短倒明细单

  sTable_CardProvide  = 'P_CardProvide';             //供应卡记录
  sTable_CardOther    = 'P_CardOther';               //临时称重
  sTable_CardProvideBak  = 'P_CardProvideBak';       //供应卡记录
  sTable_CardOtherBak    = 'P_CardOtherBak';         //临时称重

  sTable_ChineseBase  = 'Sys_ChineseBase';           //汉字喷码表
  sTable_ChineseDict  = 'Sys_ChineseDict';           //汉字编码字典

  sTable_WebOrderInfo = 'S_WebOrderInfo';            //微信订单信息
  sTable_WebSyncStatus= 'S_WebSyncStatus';           //订单状态同步
  sTable_WebSendMsgInfo = 'S_WebSendMsgInfo';        //发送模板消息

  sTable_CardGrab     = 'P_CardGrab';                //抓斗秤刷卡记录表
  sTable_Grab         = 'P_Grab';                    //抓斗秤称重记录表
  sTable_GrabBak      = 'P_GrabBak';                 //抓斗秤称重记录表
  sTable_SnapTruck    = 'Sys_SnapTruck';             //车辆抓拍记录
  sTable_WebOrderMatch   = 'S_WebOrderMatch';        //商城订单映射
  sTable_PTruckControl = 'Sys_PTruckControl';        //供应商进厂车辆数量控制表
  sTable_PTimeControl = 'Sys_PTimeControl';          //原材料进厂时间控制表
const
  sFlag_Departments   = 'Departments';               //部门列表
  sFlag_DepDaTing     = '大厅';                      //服务大厅
  sFlag_DepJianZhuang = '监装';                      //监装
  sFlag_DepBangFang   = '磅房';                      //磅房
  sFlag_DepMenGang    = '门岗';                      //门岗
  sFlag_Solution_YN   = 'Y=通过;N=禁止';
  sFlag_Solution_YNI  = 'Y=通过;N=禁止;I=忽略';
  sFlag_Solution_OK   = 'O=知道了';
  sFlag_Solution_NP   = 'P=回空;N=禁止';
  sFlag_Solution_YNP  = 'Y=通过;P=回空;N=禁止';

  {*新建表*}
  sSQL_NewSysDict = 'Create Table $Table(D_ID $Inc, D_Name varChar(32),' +
       'D_Desc varChar(64), D_Value varChar(50), D_Memo varChar(128),' +
       'D_ParamA $Float, D_ParamB varChar(50), D_ParamC VarChar(50),' +
       'D_Index Integer Default 0)';
  {-----------------------------------------------------------------------------
   系统字典: SysDict
   *.D_ID: 编号
   *.D_Name: 名称
   *.D_Desc: 描述
   *.D_Value: 取值
   *.D_Memo: 相关信息
   *.D_ParamA: 浮点参数
   *.D_ParamB: 字符参数
   *.D_ParamC: 字符参数
   *.D_Index: 显示索引
  -----------------------------------------------------------------------------}
  
  sSQL_NewExtInfo = 'Create Table $Table(I_ID $Inc, I_Group varChar(20),' +
       'I_ItemID varChar(20), I_Item varChar(30), I_Info varChar(500),' +
       'I_ParamA $Float, I_ParamB varChar(50), I_Index Integer Default 0)';
  {-----------------------------------------------------------------------------
   扩展信息表: ExtInfo
   *.I_ID: 编号
   *.I_Group: 信息分组
   *.I_ItemID: 信息标识
   *.I_Item: 信息项
   *.I_Info: 信息内容
   *.I_ParamA: 浮点参数
   *.I_ParamB: 字符参数
   *.I_Memo: 备注信息
   *.I_Index: 显示索引
  -----------------------------------------------------------------------------}

  sSQL_NewSysLog = 'Create Table $Table(L_ID $Inc, L_Date DateTime,' +
       'L_Man varChar(32),L_Group varChar(20), L_ItemID varChar(20),' +
       'L_KeyID varChar(20), L_Event varChar(220))';
  {-----------------------------------------------------------------------------
   系统日志: SysLog
   *.L_ID: 编号
   *.L_Date: 操作日期
   *.L_Man: 操作人
   *.L_Group: 信息分组
   *.L_ItemID: 信息标识
   *.L_KeyID: 辅助标识
   *.L_Event: 事件
  -----------------------------------------------------------------------------}

  sSQL_NewBaseInfo = 'Create Table $Table(B_ID $Inc, B_Group varChar(15),' +
       'B_Text varChar(100), B_Py varChar(25), B_Memo varChar(50),' +
       'B_PID Integer, B_Index Float)';
  {-----------------------------------------------------------------------------
   基本信息表: BaseInfo
   *.B_ID: 编号
   *.B_Group: 分组
   *.B_Text: 内容
   *.B_Py: 拼音简写
   *.B_Memo: 备注信息
   *.B_PID: 上级节点
   *.B_Index: 创建顺序
  -----------------------------------------------------------------------------}

  sSQL_NewSerialBase = 'Create Table $Table(R_ID $Inc, B_Group varChar(15),' +
       'B_Object varChar(32), B_Prefix varChar(25), B_IDLen Integer,' +
       'B_Base Integer, B_Date DateTime)';
  {-----------------------------------------------------------------------------
   串行编号基数表: SerialBase
   *.R_ID: 编号
   *.B_Group: 分组
   *.B_Object: 对象
   *.B_Prefix: 前缀
   *.B_IDLen: 编号长
   *.B_Base: 基数
   *.B_Date: 参考日期
  -----------------------------------------------------------------------------}

  sSQL_NewSerialStatus = 'Create Table $Table(R_ID $Inc, S_Object varChar(32),' +
       'S_SerailID varChar(32), S_PairID varChar(32), S_Status Char(1),' +
       'S_Date DateTime)';
  {-----------------------------------------------------------------------------
   串行状态表: SerialStatus
   *.R_ID: 编号
   *.S_Object: 对象
   *.S_SerailID: 串行编号
   *.S_PairID: 配对编号
   *.S_Status: 状态(Y,N)
   *.S_Date: 创建时间
  -----------------------------------------------------------------------------}

  sSQL_NewWorkePC = 'Create Table $Table(R_ID $Inc, W_Name varChar(100),' +
       'W_MAC varChar(32), W_Factory varChar(32), W_Serial varChar(32),' +
       'W_Departmen varChar(32), W_ReqMan varChar(32), W_ReqTime DateTime,' +
       'W_RatifyMan varChar(32), W_RatifyTime DateTime,' +
       'W_PoundID varChar(50), W_MITUrl varChar(128), W_HardUrl varChar(128),' +
       'W_Valid Char(1))';
  {-----------------------------------------------------------------------------
   工作授权: WorkPC
   *.R_ID: 编号
   *.W_Name: 电脑名称
   *.W_MAC: MAC地址
   *.W_Factory: 工厂编号
   *.W_Departmen: 部门
   *.W_Serial: 编号
   *.W_ReqMan,W_ReqTime: 接入申请
   *.W_RatifyMan,W_RatifyTime: 批准
   *.W_PoundID:磅站编号
   *.W_MITUrl:业务服务
   *.W_HardUrl:硬件服务
   *.W_Valid: 有效(Y/N)
  -----------------------------------------------------------------------------}

  sSQL_NewManualEvent = 'Create Table $Table(R_ID $Inc, E_ID varChar(32),' +
       'E_From varChar(32), E_Key varChar(32), E_Event varChar(200), ' +
       'E_Solution varChar(100), E_Result varChar(12),E_Departmen varChar(32),' +
       'E_Date DateTime, E_ManDeal varChar(32), E_DateDeal DateTime, ' +
       'E_ParamA Integer, E_ParamB varChar(128), E_Memo varChar(512))';
  {-----------------------------------------------------------------------------
   人工干预事件: ManualEvent
   *.R_ID: 编号
   *.E_ID: 流水号
   *.E_From: 来源
   *.E_Key: 记录标识
   *.E_Event: 事件
   *.E_Solution: 处理方案(格式如: Y=通过;N=禁止) 
   *.E_Result: 处理结果(Y/N)
   *.E_Departmen: 处理部门
   *.E_Date: 发生时间
   *.E_ManDeal,E_DateDeal: 处理人
   *.E_ParamA: 附加参数, 整型
   *.E_ParamB: 附加参数, 字符串
   *.E_Memo: 备注信息
  -----------------------------------------------------------------------------}

  sSQL_NewCustomer = 'Create Table $Table(R_ID $Inc, C_ID varChar(15), ' +
       'C_Name varChar(80), C_PY varChar(80), C_Addr varChar(100), ' +
       'C_FaRen varChar(50), C_LiXiRen varChar(50), C_WeiXin varChar(15),' +
       'C_Phone varChar(15), C_Fax varChar(15), C_Tax varChar(32),' +
       'C_Bank varChar(35), C_Account varChar(18), C_SaleMan varChar(15),' +
       'C_Param varChar(32), C_Memo varChar(50), C_XuNi Char(1))';
  {-----------------------------------------------------------------------------
   客户信息表: Customer
   *.R_ID: 记录号
   *.C_ID: 编号
   *.C_Name: 名称
   *.C_PY: 拼音简写
   *.C_Addr: 地址
   *.C_FaRen: 法人
   *.C_LiXiRen: 联系人
   *.C_Phone: 电话
   *.C_WeiXin: 微信
   *.C_Fax: 传真
   *.C_Tax: 税号
   *.C_Bank: 开户行
   *.C_Account: 帐号
   *.C_SaleMan: 业务员
   *.C_Param: 备用参数
   *.C_Memo: 备注信息
   *.C_XuNi: 虚拟(临时)客户
  -----------------------------------------------------------------------------}

  sSQL_NewStockMatch = 'Create Table $Table(R_ID $Inc, M_Group varChar(8),' +
       'M_ID varChar(20), M_Name varChar(80), M_Status Char(1), ' +
       'M_LineNo varChar(20), M_Priority Integer Default 0)';
  {-----------------------------------------------------------------------------
   相似品种映射: StockMatch
   *.R_ID: 记录编号
   *.M_Group: 分组
   *.M_ID: 物料号
   *.M_Name: 物料名称
   *.M_Status: 状态
   *.M_LineNo: 通道专用分组
   *.M_Priority: 物料优先级(若优先级高,则使用高级别的排队,忽略低级别物料)
  -----------------------------------------------------------------------------}

  sSQL_NewOrder = 'Create Table $Table(R_ID $Inc, B_ID varChar(20),' +
       'B_Freeze $Float Default 0, B_HasDone $Float Default 0)';
  {-----------------------------------------------------------------------------
   订单表: Order
   *.R_ID: 记录编号
   *.B_ID: 订单号
   *.B_Freeze: 冻结量
   *.B_HasDone: 完成量
  -----------------------------------------------------------------------------}

  sSQB_NewBillNew = 'Create Table $Table(R_ID $Inc, B_ID varChar(20),' +
       'B_Card varChar(32), B_CType Char(1), B_CardSerial varChar(16),' +
       'B_CusID varChar(20), B_CusName varChar(80),' +
       'B_CusPY varChar(80), B_CusCode varChar(15),' +
       'B_SaleID varChar(20), B_SaleMan varChar(32),B_SalePY varChar(32),' +
       'B_Type Char(1), B_StockNo varChar(20), B_StockName varChar(80),' +
       'B_Value $Float, B_Price $Float,' +
       'B_Truck varChar(15), B_IsUsed Char(1), B_LID varChar(20),' +
       'B_Man varChar(32), B_Date DateTime,' +
       'B_Lading Char(1), B_PackStyle Char(1), B_IsVIP Char(1),' +
       'B_DelMan varChar(32), B_DelDate DateTime, B_Memo varChar(500))';
  {-----------------------------------------------------------------------------
   交货单基础表: BillNew
   *.R_ID: 编号
   *.B_ID: 基本编号
   *.B_Card, B_CardSerial: 磁卡号，卡序列号
   *.B_CusID,B_CusName,B_CusPY:客户
   *.B_CusCode:客户代码
   *.B_SaleID,B_SaleMan:业务员
   *.B_Type: 类型(袋,散)
   *.B_StockNo: 物料编号
   *.B_StockName: 物料描述 
   *.B_Value: 提货量
   *.B_Truck: 车船号
   *.B_Lading: 提货方式(自提,送货)
   *.B_IsUsed,B_LID: 已占用(Y,是;N,否),当前明细
   *.B_Man:操作人
   *.B_Date:创建时间
   *.B_DelMan: 交货单删除人员
   *.B_DelDate: 交货单删除时间
   *.B_Memo: 动作备注
  -----------------------------------------------------------------------------}

  sSQL_NewBill = 'Create Table $Table(R_ID $Inc, L_ID varChar(20),' +
       'L_Card varChar(16), L_ZhiKa varChar(20), L_Project varChar(100),' +
       'L_Area varChar(50), L_CusID varChar(20), L_CusName varChar(80),' +
       'L_CusPY varChar(80), L_CusCode varChar(15),' +
       'L_SaleID varChar(20), L_SaleMan varChar(32),' +
       'L_Type Char(1), L_StockNo varChar(20), L_StockName varChar(80),' +
       'L_StockArea varChar(120), L_StockBrand varChar(120),' +
       'L_Value $Float, L_Price $Float, L_PackStyle Char(1),' +
       'L_Truck varChar(15), L_Status Char(1), L_NextStatus Char(1),' +
       'L_InTime DateTime, L_InMan varChar(32),' +
       'L_PValue $Float, L_PDate DateTime, L_PMan varChar(32),' +
       'L_MValue $Float, L_MDate DateTime, L_MMan varChar(32),' +
       'L_LadeTime DateTime, L_LadeMan varChar(32), ' +
       'L_LadeLine varChar(15), L_LineName varChar(32), L_LineGroup varChar(15),' +
       'L_WTMan varChar(32), L_WTTime DateTime, L_WTLine varChar(50),' +
       'L_DaiTotal Integer , L_DaiNormal Integer, L_DaiBuCha Integer,' +
       'L_OutFact DateTime, L_OutMan varChar(32), ' +
       'L_PoundStation varChar(32), L_PoundName varChar(32), ' +
       'L_Lading Char(1), L_IsVIP varChar(1), ' +
       'L_Seal varChar(100), L_HYDan varChar(15),' +
       'L_HYFirst DateTime, L_PrintHY Char(1), L_SnapTruck Char(1),' +
       'L_MValueView $Float, L_ValueView $Float,' +
       'L_Man varChar(32), L_Date DateTime, L_Bm varChar(64),' +
       'L_WxZhuId varChar(32), L_WxZiId varChar(32), L_OrderNo varChar(20), ' +
       'L_EmptyOut Char(1) Default ''N'', L_CardCount Integer Default 0,' +
       'L_DelMan varChar(32), L_DelDate DateTime, L_Memo VarChar(500))';
  {-----------------------------------------------------------------------------
   交货单表: Bill
   *.R_ID: 编号
   *.L_ID: 提单号
   *.L_Card: 磁卡号
   *.L_ZhiKa: 纸卡号
   *.L_Area: 区域
   *.L_CusID,L_CusName,L_CusPY:客户
   *.L_CusCode:客户代码                                           匈牙利命名法
   *.L_SaleID,L_SaleMan:业务员
   *.L_Type: 类型(袋,散)
   *.L_StockNo: 物料编号
   *.L_StockName: 物料描述
   *.L_Value: 提货量
   *.L_Price: 提货单价
   *.L_PackStyle: 包装类型(纸袋等)
   *.L_Truck: 车船号
   *.L_Status,L_NextStatus:状态控制
   *.L_InTime,L_InMan: 进厂放行
   *.L_PValue,L_PDate,L_PMan: 称皮重
   *.L_MValue,L_MDate,L_MMan: 称毛重
   *.L_LadeTime,L_LadeMan: 发货时间,发货人
   *.L_LadeLine,L_LineName, L_LineGroup: 发货通道
   *.L_DaiTotal,L_DaiNormal,L_DaiBuCha:总装,正常,补差
   *.L_WTMan:加水人
   *.L_WTTime:加水时间
   *.L_WTLine:加水点
   *.L_OutFact,L_OutMan: 出厂放行
   *.L_PoundStation, L_PoundName：指定磅站和地磅名
   *.L_Lading: 提货方式(自提,送货)
   *.L_IsVIP:VIP单
   *.L_Seal: 封签号
   *.L_HYDan: 化验单
   *.L_HYFirst:编号首次使用日期
   *.L_PrintHY:自动打印化验单
   *.L_Man:操作人
   *.L_Date:创建时间
   *.L_DelMan: 交货单删除人员
   *.L_DelDate: 交货单删除时间
   *.L_Memo: 动作备注
   *.L_Bm: 中文编码
   *.L_SnapTruck: 车牌识别
   *.L_WxZhuId,L_WxZiId: 网上自助办卡
   *.L_MValueView,L_ValueView: 毛重(修改后),净重(修改后)
   *.L_OrderNo: 订单编号
   *.L_EmptyOut: 空车出厂
   *.L_CardCount: 刷卡次数
  -----------------------------------------------------------------------------}

  sSQL_NewBillHaulback = 'Create Table $Table(R_ID $Inc, H_ID varChar(20),' +
       'H_Card varChar(20),H_LID varChar(20),H_LPID varChar(20),H_LOutFact DateTime,' +
       'H_CusID varChar(15),H_CusName varChar(80),H_CusPY varChar(80),' +
       'H_SaleID varChar(15),H_SaleMan varChar(32),' +
       'H_ZKType Char(1),H_ZhiKa varChar(20),H_CusType Char(1),' +
       'H_Type Char(1),H_StockNo varChar(20),H_StockName varChar(80),' +
       'H_LimValue $Float,H_Value $Float,H_Price $Float,' +
       'H_Truck varChar(15),H_Status Char(1),H_NextStatus Char(1),' +
       'H_InTime DateTime,H_InMan varChar(32),' +
       'H_PValue $Float,H_PDate DateTime,H_PMan varChar(32),' +
       'H_MValue $Float,H_MDate DateTime,H_MMan varChar(32),' +
       'H_LadeTime DateTime,H_LadeMan varChar(32), ' +
       'H_LadeLine varChar(15),H_LineName varChar(32),' +
       'H_OutFact DateTime,H_OutMan varChar(32),' +
       'H_PoundStation varChar(32), H_PoundName varChar(32), ' +
       'H_Man varChar(32),H_Date DateTime,' +
       'H_DelMan varChar(32),H_DelDate DateTime)';
  {-----------------------------------------------------------------------------
   退货单(回空)表: NewBillHaulback
   *.R_ID: 编号
   *.H_ID: 退货单号
   *.H_Card: 磁卡号
   *.H_LID: 退货单对应提货单号
   *.H_LPID: 退货单对应的原始磅单
   *.H_LOutFact: 提货出厂时间
   *.H_CusID,H_CusName,H_CusPY,H_CusType:客户
   *.H_SaleID,H_SaleMan:业务员
   *.H_ZhiKa: 订单编号
   *.H_ZKType: 订单类型
   *.H_Type: 类型(袋,散)
   *.H_StockNo: 物料编号
   *.H_StockName: 物料描述
   *.H_LimValue: 提货单原始提货量
   *.H_Value: 退货量
   *.H_Price: 退货单价
   *.H_Truck: 车船号
   *.H_Status,H_NextStatus:状态控制
   *.H_InTime,H_InMan: 进厂放行
   *.H_PValue,H_PDate,H_PMan: 称皮重
   *.H_MValue,H_MDate,H_MMan: 称毛重
   *.H_LadeTime,H_LadeMan: 卸货时间,卸货人
   *.H_LadeLine,H_LineName: 卸货通道
   *.H_OutFact,H_OutMan: 出厂放行
   *.H_Man:操作人
   *.H_Date:创建时间
   *.H_DelMan: 退货单删除人员
   *.H_DelDate: 退货单删除时间
  -----------------------------------------------------------------------------}

  sSQL_NewCard = 'Create Table $Table(R_ID $Inc, C_Card varChar(16),' +
       'C_Card2 varChar(32), C_Card3 varChar(32), C_Group varChar(32), ' +
       'C_Owner varChar(15), C_TruckNo varChar(15), C_Status Char(1),' +
       'C_Freeze Char(1), C_Used Char(1), C_UseTime Integer Default 0,' +
       'C_Man varChar(32), C_Date DateTime, C_Memo varChar(500))';
  {-----------------------------------------------------------------------------
   磁卡表:Card
   *.R_ID:记录编号
   *.C_Card:主卡号
   *.C_Card2,C_Card3:副卡号
   *.C_Owner:持有人标识
   *.C_TruckNo:提货车牌
   *.C_Group:卡片分组
   *.C_Used:用途(供应,销售)
   *.C_UseTime:使用次数
   *.C_Status:状态(空闲,使用,注销,挂失)
   *.C_Freeze:是否冻结
   *.C_Man:办理人
   *.C_Date:办理时间
   *.C_Memo:备注信息
  -----------------------------------------------------------------------------}

  sSQL_NewTruck = 'Create Table $Table(R_ID $Inc, T_Truck varChar(15), ' +
       'T_PY varChar(15), T_Owner varChar(32), T_Phone varChar(15), ' +
       'T_PrePValue $Float, T_PrePMan varChar(32), T_PrePTime DateTime, ' +
       'T_PrePUse Char(1), T_MinPVal $Float, T_MaxPVal $Float, ' +
       'T_PValue $Float Default 0, T_PTime Integer Default 0,' +
       'T_PlateColor varChar(12),T_Type varChar(12), T_LastTime DateTime, ' +
       'T_PoundLastTime DateTime, T_PoundValue $Float Default 0,' +
       'T_Card varChar(32), T_CardUse Char(1), T_NoVerify Char(1),' +
       'T_MatePID varChar(32), T_MateID varChar(32), T_MateName varChar(80),' +
       'T_SrcAddr varChar(150), T_DestAddr varChar(150),' +
       'T_HisValueMax $Float Default 0, T_HisMValueMax $Float Default 0,' +
       'T_MValueMax $Float Default 0,' +
       'T_Valid Char(1), T_VIPTruck Char(1), T_HasGPS Char(1))';
  {-----------------------------------------------------------------------------
   车辆信息:Truck
   *.R_ID: 记录号
   *.T_Truck: 车牌号
   *.T_PY: 车牌拼音
   *.T_Owner: 车主
   *.T_Phone: 联系方式
   *.T_PrePValue: 预置皮重
   *.T_PrePMan: 预置司磅
   *.T_PrePTime: 预置时间
   *.T_PrePUse: 使用预置
   *.T_MinPVal: 历史最小皮重
   *.T_MaxPVal: 历史最大皮重
   *.T_PValue: 有效皮重
   *.T_PTime: 过皮次数
   *.T_PlateColor: 车牌颜色
   *.T_Type: 车型
   *.T_LastTime: 上次活动
   *.T_Card: 电子标签
   *.T_CardUse: 使用电子签(Y/N)
   *.T_NoVerify: 不校验时间
   *.T_Valid: 是否有效
   *.T_VIPTruck:是否VIP
   *.T_HasGPS:安装GPS(Y/N)
   *.T_HisValueMax:历史最大净重
   *.T_HisMValueMax:历史最大毛重
   *.T_MValueMax:毛重上限

   //---------------------------短倒业务数据信息--------------------------------
   *.T_MatePID:上个物料编号
   *.T_MateID:物料编号
   *.T_MateName: 物料名称
   *.T_SrcAddr:倒出地址
   *.T_DestAddr:倒入地址
   ---------------------------------------------------------------------------//

   有效平均皮重算法:
   T_PValue = (T_PValue * T_PTime + 新皮重) / (T_PTime + 1) 
  -----------------------------------------------------------------------------}

  sSQL_NewStationTruck = 'Create Table $Table(R_ID $Inc, S_Stock varChar(32),' +
       'S_StockName varChar(80), S_CusID varChar(32), S_CusName varChar(80),' +
       'S_Value $Float, S_TruckPreFix varChar(20), S_Valid Char(1))';
  {-----------------------------------------------------------------------------
   火车厢档案表: StationTruck
   *.R_ID: 编号
   *.S_Stock: 物料号
   *.S_StockName: 物料名
   *.S_CusID: 客户号
   *.S_CusName: 客户名
   *.S_Value: 取值
   *.S_TruckPreFix: 车厢前缀
   *.S_Valid: 是否有效(Y/N)
  -----------------------------------------------------------------------------}

  sSQL_NewPoundLog = 'Create Table $Table(R_ID $Inc, P_ID varChar(15),' +
       'P_Type varChar(1), P_Order varChar(20), P_Card varChar(16),' +
       'P_Bill varChar(20), P_Truck varChar(15), P_CusID varChar(32),' +
       'P_CusName varChar(80), P_MID varChar(32),P_MName varChar(80),' +
       'P_MType varChar(10), P_LimValue $Float, P_KZValue $Float Default 0,' +
       'P_PValue $Float, P_PDate DateTime, P_PMan varChar(32), ' +
       'P_MValue $Float, P_MDate DateTime, P_MMan varChar(32), ' +
       'P_PValue2 $Float, P_PDate2 DateTime, P_PMan2 varChar(32), ' +
       'P_MValue2 $Float, P_MDate2 DateTime, P_MMan2 varChar(32), ' +
       'P_FactID varChar(32), P_Origin varChar(80),' +
       'P_PStation varChar(10), P_MStation varChar(10),' +
       'P_PStation2 varChar(10), P_MStation2 varChar(10),' +
       'P_YMan varChar(32), P_YTime DateTime, ' +
       'P_MValueView $Float, P_ValueView $Float,' +
       'P_YSResult Char(1), P_YLineName varChar(50), P_KZComment varChar(128),' +
       'P_WTMan varChar(32), P_WTTime DateTime, P_WTLine varChar(50),' +
       'P_Direction varChar(10), P_PModel varChar(10), P_Status Char(1),' +
       'P_Valid Char(1), P_PrintNum Integer Default 1, P_Memo varChar(128),' +
       'P_DelMan varChar(32), P_DelDate DateTime)';
  {-----------------------------------------------------------------------------
   过磅记录: PoundLog
   *.P_ID: 编号
   *.P_Type: 类型(销售,供应,临时)
   *.P_Order: 订单号,火车衡过磅时保存仓库编号
   *.P_Bill: 交货单,火车衡过磅时保存批次号
   *.P_Truck: 车牌
   *.P_CusID: 客户号
   *.P_CusName: 物料名
   *.P_MID: 物料号
   *.P_MName: 物料名
   *.P_MType: 包,散等
   *.P_LimValue: 票重
   *.P_PValue,P_PDate,P_PMan: 皮重
   *.P_MValue,P_MDate,P_MMan: 毛重
   *.P_FactID: 工厂编号
   *.P_Origin: 来源,产地,火车衡过磅时保存仓库名称
   *.P_PStation,P_MStation: 称重磅站
   *.P_Direction: 物料流向(进,出)
   *.P_PModel: 过磅模式(标准,配对等)
   *.P_YMan:验收人
   *.P_YTime:验收时间
   *.P_YSResult: 验收结果
   *.P_YLineName: 验收点
   *.P_KZComment: 验收备注
   *.P_WTMan:加水人
   *.P_WTTime:加水时间
   *.P_WTLine:加水点
   *.P_Status: 记录状态
   *.P_Valid: 是否有效
   *.P_PrintNum: 打印次数
   *.P_DelMan,P_DelDate: 删除记录
   *.P_MValueView,P_ValueView: 毛重(修改后),净重(修改后)
  -----------------------------------------------------------------------------}

  sSQL_NewPicture = 'Create Table $Table(R_ID $Inc, P_ID varChar(15),' +
       'P_Name varChar(32), P_Mate varChar(80), P_Date DateTime, P_Picture Image)';
  {-----------------------------------------------------------------------------
   图片: Picture
   *.P_ID: 编号
   *.P_Name: 名称
   *.P_Mate: 物料
   *.P_Date: 时间
   *.P_Picture: 图片
  -----------------------------------------------------------------------------}

  sSQL_NewAlivision = 'Create Table $Table(R_ID $Inc, V_ID varChar(15),' +
       'V_Pound varChar(10), V_Truck varChar(15), V_Camera varChar(15),' +
       'V_Status Char(1), V_Date DateTime)';
  {-----------------------------------------------------------------------------
   图像识别: Alivision
   *.V_ID: 业务编号
   *.V_Pound: 磅站号
   *.V_Truck: 业务车牌
   *.V_Camera: 识别车牌
   *.V_Status: 识别状态
   *.V_Date: 时间
  -----------------------------------------------------------------------------}

  sSQL_NewPoundDaiWC = 'Create Table $Table(R_ID $Inc,' +
       'P_DaiWuChaZ $Float, P_DaiWuChaF $Float, P_Start $Float, P_End $Float,' +
       'P_Percent Char(1), P_Station varChar(32))';
  {-----------------------------------------------------------------------------
   袋装误差范围: PoundDaiWuCha
   *.P_DaiWuChaZ: 正误差
   *.P_DaiWuChaF: 负误差
   *.P_Start: 起始范围
   *.P_End: 结束范围
   *.P_Percent: 按比例计算误差(Y、是;其它、否)
   *.P_Station: 磅站编号
  -----------------------------------------------------------------------------}

  sSQL_NewZTLines = 'Create Table $Table(R_ID $Inc, Z_ID varChar(15),' +
       'Z_Name varChar(32), Z_StockNo varChar(20), Z_Stock varChar(80),' +
       'Z_StockType Char(1), Z_PeerWeight Integer, Z_Group varChar(15),' +
       'Z_QueueMax Integer, Z_VIPLine Char(1), Z_Valid Char(1), Z_Index Integer)';
  {-----------------------------------------------------------------------------
   装车线配置: ZTLines
   *.R_ID: 记录号
   *.Z_ID: 编号
   *.Z_Name: 名称
   *.Z_StockNo: 品种编号
   *.Z_Stock: 品名
   *.Z_StockType: 类型(袋,散)
   *.Z_PeerWeight: 袋重
   *.Z_QueueMax: 队列大小
   *.Z_VIPLine: VIP通道
   *.Z_Valid: 是否有效
   *.Z_Index: 顺序索引
  -----------------------------------------------------------------------------}

  sSQL_NewZTTrucks = 'Create Table $Table(R_ID $Inc, T_Truck varChar(15),' +
       'T_StockNo varChar(20), T_Stock varChar(80), T_Type Char(1),' +
       'T_Line varChar(15), T_LineGroup varChar(15), T_Index Integer, ' +
       'T_InTime DateTime, T_InFact DateTime, T_InQueue DateTime,' +
       'T_InLade DateTime, T_VIP Char(1), T_Valid Char(1), T_Bill varChar(15),' +
       'T_Value $Float, T_PeerWeight Integer, T_Total Integer Default 0,' +
       'T_Normal Integer Default 0, T_BuCha Integer Default 0,' +
       'T_PDate DateTime, T_IsPound Char(1),T_HKBills varChar(200))';
  {-----------------------------------------------------------------------------
   待装车队列: ZTTrucks
   *.R_ID: 记录号
   *.T_Truck: 车牌号
   *.T_StockNo: 品种编号
   *.T_Stock: 品种名称
   *.T_Type: 品种类型(D,S)
   *.T_Line: 所在道
   *.T_LineGroup: 通道分组
   *.T_Index: 顺序索引
   *.T_InTime: 入队时间
   *.T_InFact: 进厂时间
   *.T_InQueue: 上屏时间
   *.T_InLade: 提货时间
   *.T_VIP: 特权
   *.T_Bill: 提单号
   *.T_Valid: 是否有效
   *.T_Value: 提货量
   *.T_PeerWeight: 袋重
   *.T_Total: 总装袋数
   *.T_Normal: 正常袋数
   *.T_BuCha: 补差袋数
   *.T_PDate: 过磅时间
   *.T_IsPound: 需过磅(Y/N)
   *.T_HKBills: 合卡交货单列表
  -----------------------------------------------------------------------------}

  sSQL_NewProvider = 'Create Table $Table(R_ID $Inc, P_ID varChar(32),' +
       'P_Name varChar(80),P_PY varChar(80), P_Phone varChar(20),' +
       'P_WeiXin varChar(32), P_Saler varChar(32),P_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   供应商: Provider
   *.P_ID: 编号
   *.P_Name: 名称
   *.P_PY: 拼音简写
   *.P_Phone: 联系方式
   *.P_Weixin: 商城账号
   *.P_Saler: 业务员
   *.P_Memo: 备注
  -----------------------------------------------------------------------------}

  sSQL_NewMaterails = 'Create Table $Table(R_ID $Inc, M_ID varChar(32),' +
       'M_Name varChar(80),M_PY varChar(80),M_Unit varChar(20),M_Price $Float,' +
       'M_PrePValue Char(1), M_PrePTime Integer, M_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   物料表: Materails
   *.M_ID: 编号
   *.M_Name: 名称
   *.M_PY: 拼音简写
   *.M_Unit: 单位
   *.M_PrePValue: 预置皮重
   *.M_PrePTime: 皮重时长(天)
   *.M_Memo: 备注
  -----------------------------------------------------------------------------}

  sSQL_NewProvBase = 'Create Table $Table(R_ID $Inc, P_ID varChar(20),' +
       'P_BID varChar(20),P_DID varChar(20),' +
       'P_Card varChar(32), P_CType varChar(1),P_UsePre Char(1),' +
       'P_Value $Float,P_Area varChar(50), P_Project varChar(100),' +
       'P_Factory varChar(100), P_Origin varChar(100),' +
       'P_ProType Char(1), P_ProID varChar(32), ' +
       'P_ProName varChar(80), P_ProPY varChar(80),' +
       'P_SaleID varChar(32), P_SaleMan varChar(80), P_SalePY varChar(80),' +
       'P_Type Char(1), P_StockNo varChar(32), P_StockName varChar(80),' +
       'P_PValue $Float, P_PDate DateTime, P_PMan varChar(32),' +
       'P_MValue $Float, P_MDate DateTime, P_MMan varChar(32),' +
       'P_Status Char(1), P_NextStatus Char(1), P_IsUsed Char(1),' +
       'P_Truck varChar(15), P_Man varChar(32), P_Date DateTime,' +
       'P_DelMan varChar(32), P_DelDate DateTime, P_Memo varChar(500))';
  {-----------------------------------------------------------------------------
   采购订单表: NewProvBase
   *.R_ID: 编号
   *.P_ID: 订单单号
   *.P_BID: 采购申请单据号
   *.P_DID: 入厂明细单号
   *.P_Card,P_CType: 磁卡号,磁卡类型(L、临时卡;G、固定卡)
   *.P_UsePre: 使用预置皮重
   *.P_Value:订单量，
   *.P_OStatus: 订单状态
   *.P_Area,P_Project: 区域,项目
   *.P_ProType,P_ProID,P_ProName,P_ProPY:供应商
   *.P_SaleID,P_SaleMan:业务员
   *.P_Type: 类型(袋,散)
   *.P_StockNo: 原材料编号
   *.P_StockName: 原材料名称
   *.P_PValue,P_PDate,P_PMan: 称皮重
   *.P_MValue,P_MDate,P_MMan: 称毛重
   *.P_Status: 当前车辆状态
   *.P_NextStus: 下一状态
   *.P_IsUsed: 订单是否占用(Y、正在使用;N、未占用)
   *.P_Truck: 车船号
   *.P_Man:操作人
   *.P_Date:创建时间
   *.P_DelMan: 采购单删除人员
   *.P_DelDate: 采购单删除时间
   *.P_Memo: 动作备注
  -----------------------------------------------------------------------------}

  sSQL_NewProvDtl = 'Create Table $Table(R_ID $Inc, D_ID varChar(20),' +
       'D_OID varChar(20), D_PID varChar(20), D_Card varChar(32), ' +
       'D_Area varChar(50), D_Project varChar(100),D_Truck varChar(15), ' +
       'D_ProType Char(1), D_ProID varChar(32), D_XuNi Char(1),' +
       'D_ProName varChar(80), D_ProPY varChar(80),' +
       'D_SaleID varChar(32), D_SaleMan varChar(80), D_SalePY varChar(80),' +
       'D_Type Char(1), D_StockNo varChar(32), D_StockName varChar(80),' +
       'D_DStatus Char(1), D_Status Char(1), D_NextStatus Char(1),' +
       'D_InTime DateTime, D_InMan varChar(32),' +
       'D_PValue $Float, D_PDate DateTime, D_PMan varChar(32),' +
       'D_MValue $Float, D_MDate DateTime, D_MMan varChar(32),' +
       'D_YTime DateTime, D_YMan varChar(32), ' +
       'D_Value $Float,D_KZValue $Float, D_AKValue $Float,' +
       'D_YLine varChar(15), D_YLineName varChar(32), ' +
       'D_DelMan varChar(32), D_DelDate DateTime, D_YSResult Char(1), ' +
       'D_OutFact DateTime, D_OutMan varChar(32), D_Memo varChar(500))';
  {-----------------------------------------------------------------------------
   采购订单明细表: ProvDetail
   *.R_ID: 编号
   *.D_ID: 采购明细号
   *.D_OID: 采购单号
   *.D_PID: 磅单号
   *.D_Card: 采购磁卡号
   *.D_DStatus: 订单状态
   *.D_Area,D_Project: 区域,项目
   *.D_ProType,D_ProID,D_ProName,D_ProPY:供应商
   *.D_XuNi: 虚拟明细
   *.D_SaleID,D_SaleMan:业务员
   *.D_Type: 类型(袋,散)
   *.D_StockNo: 原材料编号
   *.D_StockName: 原材料名称
   *.D_Truck: 车船号
   *.D_Status,D_NextStatus: 状态
   *.D_InTime,D_InMan: 进厂放行
   *.D_PValue,D_PDate,D_PMan: 称皮重
   *.D_MValue,D_MDate,D_MMan: 称毛重
   *.D_YTime,D_YMan: 收货时间,验收人,
   *.D_Value,D_KZValue,D_AKValue: 收货量,验收扣除(明扣),暗扣
   *.D_YLine,D_YLineName: 收货通道
   *.D_YSResult: 验收结果
   *.D_OutFact,D_OutMan: 出厂放行
  -----------------------------------------------------------------------------}

  sSQL_NewTransfer = 'Create Table $Table(R_ID $Inc, T_ID varChar(20),' +
       'T_Card varChar(16), T_Truck varChar(15), T_PID varChar(15),' +
       'T_SrcAddr varChar(160), T_DestAddr varChar(160),' +
       'T_Type Char(1), T_StockNo varChar(32), T_StockName varChar(160),' +
       'T_PValue $Float, T_PDate DateTime, T_PMan varChar(32),' +
       'T_MValue $Float, T_MDate DateTime, T_MMan varChar(32),' +
       'T_Value $Float, T_Man varChar(32), T_Date DateTime,' +
       'T_DelMan varChar(32), T_DelDate DateTime, T_Memo varChar(500),' +
       'T_SyncNum Integer Default 0, T_SyncDate DateTime, T_SyncMemo varChar(500))';
  {-----------------------------------------------------------------------------
   入厂表: Transfer
   *.R_ID: 编号
   *.T_ID: 短倒业务号
   *.T_PID: 磅单编号
   *.T_Card: 磁卡号
   *.T_Truck: 车牌号
   *.T_SrcAddr:倒出地点
   *.T_DestAddr:倒入地点
   *.T_Type: 类型(袋,散)
   *.T_StockNo: 物料编号
   *.T_StockName: 物料描述
   *.T_PValue,T_PDate,T_PMan: 称皮重
   *.T_MValue,T_MDate,T_MMan: 称毛重
   *.T_Value: 收货量
   *.T_Man,T_Date: 单据信息
   *.T_DelMan,T_DelDate: 删除信息
   *.T_SyncNum, T_SyncDate, T_SyncMemo: 同步次数; 同步完成时间; 同步信息
  -----------------------------------------------------------------------------}

  sSQL_NewCardProvide = 'Create Table $Table(R_ID $Inc, P_Card varChar(16),' +
       'P_Order varChar(20), P_Truck varChar(15),' +
       'P_CusID varChar(32), P_CusPY varChar(120), P_CusName varChar(120), ' +
       'P_Origin varChar(128), P_MID varChar(32), P_MName varChar(80), ' +
       'P_MType varChar(10), P_LimVal $Float, P_Pound varChar(20),' +
       'P_Status Char(1), P_NextStatus Char(1),' +
       'P_InTime DateTime, P_InMan varChar(32),' +
       'P_OutTime DateTime, P_OutMan varChar(32),' +
       'P_BFPTime DateTime, P_BFPMan varChar(32), P_BFPValue $Float Default 0,' +
       'P_BFMTime DateTime, P_BFMMan varChar(32), P_BFMValue $Float Default 0,' +
       'P_BFPTime2 DateTime, P_BFPMan2 varChar(32), P_BFPValue2 $Float Default 0,' +
       'P_BFMTime2 DateTime, P_BFMMan2 varChar(32), P_BFMValue2 $Float Default 0,' +
       'P_KeepCard varChar(1), P_OneDoor Char(1), P_MuiltiPound Char(1), ' +
       'P_PoundStation varChar(32), P_PoundName varChar(32), ' +
       'P_Man varChar(32), P_Date DateTime, P_UsePre Char(1), P_SnapTruck Char(1),' +
       'P_DelMan varChar(32), P_DelDate DateTime, P_Memo varChar(128))';
  {-----------------------------------------------------------------------------
   供应磁卡:CardProvide
   *.R_ID:记录编号
   *.P_Card:卡号
   *.P_Truck: 车辆
   *.P_Order:采购单号
   *.P_Origin: 矿点
   *.P_CusID,P_CusName:供应商
   *.P_MID,P_MName:物料
   *.P_MType:包,散等
   *.P_LimVal:票重
   *.P_Pound: 榜单编号
   *.P_Status,P_NextStatus: 行车状态
   *.P_InTime,P_InMan:进厂时间,放行人
   *.P_OutTime,P_OutMan:出厂时间,放行人
   *.P_BFPTime,P_BFPMan,P_BFPValue:皮重时间,操作人,皮重
   *.P_BFMTime,P_BFMMan,P_BFMValue:毛重时间,操作人,毛重
   *.P_KeepCard: 司机卡(Y/N),出厂时不清理
   *.P_OneDoor: 单向过磅
   *.P_MuiltiPound: 系统复磅
   *.P_UsePre: 预置皮重
   *.P_Man,P_Date:制卡人
   *.P_SnapTruck: 车牌识别
   *.P_DelMan,P_DelDate: 删除人
  -----------------------------------------------------------------------------}

  sSQL_NewCardOther = 'Create Table $Table(R_ID $Inc, O_Card varChar(16),' +
       'O_Truck varChar(15), O_CusID varChar(32), O_CusName varChar(80),' +
       'O_CusPY varChar(80), O_MID varChar(32), O_MName varChar(80), ' +
       'O_MType varChar(10), O_Origin varChar(80), O_LimVal $Float, ' +
       'O_Status Char(1), O_NextStatus Char(1),O_Pound varChar(20),' +
       'O_InTime DateTime, O_InMan varChar(32),' +
       'O_OutTime DateTime, O_OutMan varChar(32),' +
       'O_BFPTime DateTime, O_BFPMan varChar(32), O_BFPValue $Float Default 0,' +
       'O_BFMTime DateTime, O_BFMMan varChar(32), O_BFMValue $Float Default 0,' +
       'O_BFPTime2 DateTime, O_BFPMan2 varChar(32), O_BFPValue2 $Float Default 0,' +
       'O_BFMTime2 DateTime, O_BFMMan2 varChar(32), O_BFMValue2 $Float Default 0,' +
       'O_KeepCard varChar(1), O_MuiltiPound Char(1), O_Man varChar(32), O_Date DateTime,' +
       'O_UsePValue Char(1) Default ''N'', O_OneDoor Char(1) Default ''N'', ' +
       'O_PoundStation varChar(32), O_PoundName varChar(32), ' +
       'O_UsePre Char(1), O_OutDoor Char(1) Default ''Y'',' +
       'O_DelMan varChar(32), O_DelDate DateTime, O_Memo varChar(128))';
  {-----------------------------------------------------------------------------
   临时磁卡:CardOther
   *.R_ID:记录编号
   *.O_Card:卡号
   *.O_Truck: 车辆
   *.O_CusID,O_CusName:供应商
   *.O_Orgin: 矿点
   *.O_MID,O_MName:物料
   *.O_MType:包,散等
   *.O_LimVal:票重
   *.O_Status,O_NextStatus: 行车状态
   *.O_InTime,O_InMan:进厂时间,放行人
   *.O_OutTime,O_OutMan:出厂时间,放行人
   *.O_BFPTime,O_BFPMan,T_BFPValue:皮重时间,操作人,皮重
   *.O_BFMTime,O_BFMMan,T_BFMValue:毛重时间,操作人,毛重
   *.O_KeepCard: 司机卡(Y/N),出厂时不清理
   *.O_Man,O_Date:制卡人
   *.O_UsePValue: 以空车为皮重
   *.O_OneDoor: 单向过磅
   *.O_OutDoor: 出厂转运
   *.O_MuiltiPound: 系统复磅
   *.O_UsePre: 预置皮重
   *.O_DelMan,O_DelDate: 删除人
  -----------------------------------------------------------------------------}

  sSQL_NewBatcode = 'Create Table $Table(R_ID $Inc, B_Stock varChar(32),' +
       'B_Name varChar(80), B_Prefix varChar(15), B_Base Integer,' +
       'B_Incement Integer, B_Length Integer, B_Type Char(1),' +
       'B_Value $Float, B_Low $Float, B_High $Float, B_Interval Integer,' +
       'B_AutoNew Char(1), B_UseDate Char(1), B_FirstDate DateTime,' +
       'B_LastDate DateTime, B_HasUse $Float Default 0, B_Batcode varChar(32))';
  {-----------------------------------------------------------------------------
   批次编码表: Batcode
   *.R_ID: 编号
   *.B_Stock: 物料号
   *.B_Name: 物料名
   *.B_Prefix: 前缀
   *.B_Base: 起始编码(基数)
   *.B_Incement: 编号增量
   *.B_Length: 编号长度
   *.B_Type: 提货类型(H、火车;S、船运;C、普通)
   *.B_Value:检测量
   *.B_Low,B_High:上下限(%)
   *.B_Interval: 编号周期(天)
   *.B_AutoNew: 元旦重置(Y/N)
   *.B_UseDate: 使用日期编码
   *.B_FirstDate: 首次使用时间
   *.B_LastDate: 上次基数更新时间
   *.B_HasUse: 已使用
   *.B_Batcode: 当前批次号
  -----------------------------------------------------------------------------}
  
  sSQL_NewBatcodeDoc = 'Create Table $Table(R_ID $Inc, D_ID varChar(32),' +
       'D_Stock varChar(32),D_Name varChar(80), D_Brand varChar(32), ' +
       'D_Type Char(1), D_Plan $Float, D_Sent $Float Default 0, ' +
       'D_Rund $Float, D_Init $Float, D_Warn $Float, D_ValidDays Integer,' +
       'D_CusID varChar(20), D_CusName varChar(80),' +
       'D_Man varChar(32), D_Date DateTime, ' +
       'D_DelMan varChar(32), D_DelDate DateTime, ' +
       'D_UseDate DateTime, D_LastDate DateTime, D_Valid char(1))';
  {-----------------------------------------------------------------------------
   批次编码表: Batcode
   *.R_ID: 编号
   *.D_ID: 批次号
   *.D_Stock: 物料号
   *.D_Name: 物料名
   *.D_Brand: 水泥品牌
   *.D_Type: 提货类型(H、火车;S、船运;C、普通)
   *.D_Plan: 计划总量
   *.D_Sent: 已发量
   *.D_Rund: 退货量
   *.D_Init: 初始量
   *.D_Warn: 预警量
   *.D_ValidDays: 有效天数
   *.D_Man:  操作人
   *.D_Date: 生成时间
   *.D_DelMan: 删除人
   *.D_DelDate: 删除时间
   *.D_UseDate: 启用时间
   *.D_LastDate: 终止时间
   *.D_Valid: 是否启用(N、封存;Y、启用；D、删除)
  -----------------------------------------------------------------------------}

  sSQL_NewDeduct = 'Create Table $Table(R_ID $Inc, D_Stock varChar(32),' +
       'D_Name varChar(80), D_CusID varChar(32), D_CusName varChar(80),' +
       'D_Value $Float, D_Type Char(1), D_Valid Char(1))';
  {-----------------------------------------------------------------------------
   批次编码表: Batcode
   *.R_ID: 编号
   *.D_Stock: 物料号
   *.D_Name: 物料名
   *.D_CusID: 客户号
   *.D_CusName: 客户名
   *.D_Value: 取值
   *.D_Type: 类型(F,固定值;P,百分比)
   *.D_Valid: 是否有效(Y/N)
  -----------------------------------------------------------------------------}

  sSQL_NewPoundShip = 'Create Table $Table(R_ID $Inc, S_Bill varChar(20),' +
       'S_YunShu varChar(100), S_Value $Float, S_Plan $Float, ' +
       'S_PiCi varChar(80), S_FengQian varChar(100),S_Memo varChar(500),' +
       'S_KW varChar(15), S_KZ varChar(15),S_KT varChar(15),' +
       'S_ZLW varChar(15), S_ZLZ varChar(15), S_ZLT varChar(15),' +
       'S_ZRW varChar(15), S_ZRZ varChar(15), S_ZRT varChar(15),' +
       'S_Man varChar(32), S_Date DateTime,' +
       'S_LeaveMan varChar(32), S_LeaveDate DateTime)';
  {-----------------------------------------------------------------------------
   船运发货单: PoundShip
   *.R_ID: 编号
   *.S_Bill: 提货单
   *.S_YunShu: 运输单位
   *.S_Value: 净重
   *.S_Plan: 计划量
   *.S_PiCi: 批次号
   *.S_FengQian: 封签号
   *.S_Memo: 备注
   *.S_KW,S_KZ,S_KT: 空船尾,中,头
   *.S_ZLW,S_ZLZ,S_ZLT: 重船左(Left)尾,中,头
   *.S_ZRW,S_ZRZ,S_ZRT: 重船右(Right)尾,中,头
   *.S_Man,S_Date: 开单人
   *.S_LeaveMan,S_LeaveDate: 离港
  -----------------------------------------------------------------------------}

  sSQL_NewMine = 'Create Table $Table(R_ID $Inc, M_Mine varChar(30), ' +
       'M_PY varChar(15), M_Owner varChar(32), M_Phone varChar(15), ' +
       'M_Stock varChar(32), M_StockName varChar(80), ' +
       'M_CusID varChar(32), M_CusName varChar(80), M_Area varChar(80), ' +
       'M_Valid Char(1))';
  {-----------------------------------------------------------------------------
   矿点信息:Mine
   *.R_ID: 记录号
   *.M_Mine: 矿点名称
   *.M_PY: 矿点拼音
   *.M_Owner: 矿点主
   *.M_Phone: 联系方式
   *.M_Stock: 物料编号
   *.M_StockName: 物料名称
   *.M_CusID: 客户ID
   *.M_CusName: 客户名称
   *.M_Area: 区域名
   *.M_Valid: 是否有效(Y/N)
  -----------------------------------------------------------------------------}

  sSQL_NewChineseBase = 'Create Table $Table(R_ID $Inc, B_Name varChar(15), ' +
       'B_PY varChar(15), B_Source varChar(50), B_Value varChar(15), ' +
       'B_PrintCode varChar(50), B_Valid Char(1), B_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   汉字喷码信息:ChineseBase
   *.R_ID: 记录号
   *.B_Name: 名称
   *.B_PY: 拼音
   *.B_Source：喷码来源
   *.B_Value：喷码内容
   *.B_PrintCode：喷码值
   *.B_Valid：是否有效(Y/N)
   *.B_Memo：备注
  -----------------------------------------------------------------------------}

  sSQL_NewChineseDict = 'Create Table $Table(R_ID $Inc, D_Name varChar(15), ' +
       'D_PY varChar(15), D_Prefix varChar(32), D_Code varChar(15), ' +
       'D_Value varChar(32), D_Valid Char(1), D_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   汉字喷码字典信息:NewChineseDict
   *.R_ID: 记录号
   *.D_Name: 汉字
   *.D_PY: 拼音
   *.D_Prefix：喷码前缀
   *.D_Code：喷码编号
   *.D_Value：喷码值
   *.D_Valid：是否有效(Y/N)
   *.D_Memo：备注
  -----------------------------------------------------------------------------}

  sSQL_NewWebOrderInfo = 'Create Table $Table(R_ID $Inc, W_WebID varChar(32),' +
       'W_DLID varChar(15), W_Date DateTime, W_Man varChar(80),' +
       'W_Memo varChar(80))';
  {-----------------------------------------------------------------------------
   商城订单映射表: WebOrderInfo
   *.R_ID: 编号
   *.W_WebID: 商城订单ID
   *.W_DLID: DL系统ID
   *.W_Date: 开单时间
   *.W_Man: 开单人
   *.W_Memo: 备注
  -----------------------------------------------------------------------------}

  sSQL_NewWebSyncStatus = 'Create Table $Table(R_ID $Inc, ' +
       'S_ID varChar(15), S_Status Integer, S_Value $Float, S_Type Char(1),' +
       'S_Upload Char(1), S_UpCount Integer Default 0, ' +
       'S_Date DateTime, S_Man varChar(80), S_Memo varChar(80))';
  {-----------------------------------------------------------------------------
   商城订单状态同步表: WebSyncStatus
   *.R_ID: 编号
   *.S_ID: DL系统ID
   *.S_Status: 订单状态
   *.S_Value: 订单量
   *.S_Type: 订单类型
   *.S_Upload: 订单同步状态
   *.S_Date: 开单时间
   *.S_Man: 开单人
   *.S_Memo: 备注
  -----------------------------------------------------------------------------}

  sSQL_NewWebSendMsgInfo = 'Create Table $Table(R_ID $Inc, ' +
       'E_Value $Float, E_DLID varChar(20), E_MsgType Integer, ' +
       'E_Card varChar(32), E_Truck varChar(15), E_StockNO varChar(20),' +
       'E_StockName varChar(128), E_CusID varChar(20), E_CusName varChar(128),'+
       'E_Upload Char(1), E_UpCount Integer Default 0, ' +
       'E_Date DateTime, E_Man varChar(80), E_Memo varChar(80))';
  {-----------------------------------------------------------------------------
   商城发送模板消息表: WebSendMsgInfo
   *.R_ID: 编号
   *.E_ID: DL系统ID
   *.E_MsgType: 订单状态
   *.E_Value: 订单量
   *.E_Type: 订单类型
   *.E_Upload: 订单同步状态
   *.E_UpCount: 同步次数
   *.E_Date: 开单时间
   *.E_Man: 开单人
   *.E_Memo: 备注
  -----------------------------------------------------------------------------}

  sSQL_CardGrab = 'Create Table $Table(R_ID $Inc,P_Ls varChar(32), P_Card varChar(32),' +
       'P_Tunnel varChar(50))';
  {-----------------------------------------------------------------------------
   抓斗秤刷卡记录:
   *.P_Card: 磁卡编号
   *.P_Ls: 刷卡流水号
   *.P_Tunnel: 抓斗秤通道
  -----------------------------------------------------------------------------}

  sSQL_Grab = 'Create Table $Table(R_ID $Inc, ' +
       'Rec_Id varChar(32), Card varChar(32), Num Integer, ' +
       'Truck varChar(60), CusName varChar(128), ' +
       'StockName varChar(128), EachWeight $Float, TotalWeight varChar(20),'+
       'WeightTime DateTime, P_DelMan varChar(32), P_DelDate DateTime)';
  {-----------------------------------------------------------------------------
   商城发送模板消息表: WebSendMsgInfo
   *.R_ID: 编号
   *.Rec_ID: 每条船流水号
   *.Card: 卡号
   *.Num: 第Num次称重
   *.Truck: 车船号
   *.CusName: 客户名称
   *.StockName: 物料名称
   *.EachWeight: 第Num次称重重量
   *.TotalWeight: 总累计重量
   *.WeightTime: 第Num次称重时间
   *.P_DelMan,P_DelDate: 删除记录
  -----------------------------------------------------------------------------}
  
  sSQL_NewStockParam = 'Create Table $Table(P_ID varChar(15), P_Stock varChar(50),' +
       'P_Type Char(1), P_Name varChar(50), P_QLevel varChar(20), P_Memo varChar(50),' +
       'P_MgO varChar(20), P_SO3 varChar(20), P_ShaoShi varChar(20),' +
       'P_CL varChar(20), P_BiBiao varChar(20), P_ChuNing varChar(20),' +
       'P_ZhongNing varChar(20), P_AnDing varChar(20), P_XiDu varChar(20),' +
       'P_Jian varChar(20), P_ChouDu varChar(20), P_BuRong varChar(20),' +
       'P_YLiGai varChar(20), P_Water varChar(20), P_KuangWu varChar(20),' +
       'P_GaiGui varChar(20), P_3DZhe varChar(20), P_28Zhe varChar(20),' +
       'P_3DYa varChar(20), P_28Ya varChar(20))';
  {-----------------------------------------------------------------------------
   品种参数:StockParam
   *.P_ID:记录编号
   *.P_Stock:品名
   *.P_Type:类型(袋,散)
   *.P_Name:等级名
   *.P_QLevel:强度等级
   *.P_Memo:备注
   *.P_MgO:氧化镁
   *.P_SO3:三氧化硫
   *.P_ShaoShi:烧失量
   *.P_CL:氯离子
   *.P_BiBiao:比表面积
   *.P_ChuNing:初凝时间
   *.P_ZhongNing:终凝时间
   *.P_AnDing:安定性
   *.P_XiDu:细度
   *.P_Jian:碱含量
   *.P_ChouDu:稠度
   *.P_BuRong:不溶物
   *.P_YLiGai:游离钙
   *.P_Water:保水率
   *.P_KuangWu:硅酸盐矿物
   *.P_GaiGui:钙硅比
   *.P_3DZhe:3天抗折强度
   *.P_28DZhe:28抗折强度
   *.P_3DYa:3天抗压强度
   *.P_28DYa:28抗压强度
  -----------------------------------------------------------------------------}

  sSQL_NewStockRecord = 'Create Table $Table(R_ID $Inc, R_SerialNo varChar(15),' +
       'R_PID varChar(15),' +
       'R_SGType varChar(20), R_SGValue varChar(20),' +
       'R_HHCType varChar(20), R_HHCValue varChar(20),' +
       'R_MgO varChar(20), R_SO3 varChar(20), R_ShaoShi varChar(20),' +
       'R_CL varChar(20), R_BiBiao varChar(20), R_ChuNing varChar(20),' +
       'R_ZhongNing varChar(20), R_AnDing varChar(20), R_XiDu varChar(20),' +
       'R_Jian varChar(20), R_ChouDu varChar(20), R_BuRong varChar(20),' +
       'R_YLiGai varChar(20), R_Water varChar(20), R_KuangWu varChar(20),' +
       'R_GaiGui varChar(20),' +
       'R_3DZhe1 varChar(20), R_3DZhe2 varChar(20), R_3DZhe3 varChar(20),' +
       'R_28Zhe1 varChar(20), R_28Zhe2 varChar(20), R_28Zhe3 varChar(20),' +
       'R_3DYa1 varChar(20), R_3DYa2 varChar(20), R_3DYa3 varChar(20),' +
       'R_3DYa4 varChar(20), R_3DYa5 varChar(20), R_3DYa6 varChar(20),' +
       'R_28Ya1 varChar(20), R_28Ya2 varChar(20), R_28Ya3 varChar(20),' +
       'R_28Ya4 varChar(20), R_28Ya5 varChar(20), R_28Ya6 varChar(20),' +
       'R_Date DateTime, R_Man varChar(32))';
  {-----------------------------------------------------------------------------
   检验记录:StockRecord
   *.R_ID:记录编号
   *.R_SerialNo:水泥编号
   *.R_PID:品种参数
   *.R_SGType: 石膏种类
   *.R_SGValue: 石膏掺入量
   *.R_HHCType: 混合材料类
   *.R_HHCValue: 混合材掺入量
   *.R_MgO:氧化镁
   *.R_SO3:三氧化硫
   *.R_ShaoShi:烧失量
   *.R_CL:氯离子
   *.R_BiBiao:比表面积
   *.R_ChuNing:初凝时间
   *.R_ZhongNing:终凝时间
   *.R_AnDing:安定性
   *.R_XiDu:细度
   *.R_Jian:碱含量
   *.R_ChouDu:稠度
   *.R_BuRong:不溶物
   *.R_YLiGai:游离钙
   *.R_Water:保水率
   *.R_KuangWu:硅酸盐矿物
   *.R_GaiGui:钙硅比
   *.R_3DZhe1:3天抗折强度1
   *.R_3DZhe2:3天抗折强度2
   *.R_3DZhe3:3天抗折强度3
   *.R_28Zhe1:28抗折强度1
   *.R_28Zhe2:28抗折强度2
   *.R_28Zhe3:28抗折强度3
   *.R_3DYa1:3天抗压强度1
   *.R_3DYa2:3天抗压强度2
   *.R_3DYa3:3天抗压强度3
   *.R_3DYa4:3天抗压强度4
   *.R_3DYa5:3天抗压强度5
   *.R_3DYa6:3天抗压强度6
   *.R_28Ya1:28抗压强度1
   *.R_28Ya2:28抗压强度2
   *.R_28Ya3:28抗压强度3
   *.R_28Ya4:28抗压强度4
   *.R_28Ya5:28抗压强度5
   *.R_28Ya6:28抗压强度6
   *.R_Date:取样日期
   *.R_Man:录入人
  -----------------------------------------------------------------------------}

  sSQL_NewStockHuaYan = 'Create Table $Table(H_ID $Inc, H_No varChar(15),' +
       'H_Custom varChar(15), H_CusName varChar(80), H_SerialNo varChar(15),' +
       'H_Truck varChar(15), H_Value $Float,' +
       'H_Bill varchar(20), H_BillDate DateTime,' +
       'H_EachTruck Char(1), H_ReportDate DateTime, H_Reporter varChar(32))';
  {-----------------------------------------------------------------------------
   开化验单:StockHuaYan
   *.H_ID:记录编号
   *.H_No:化验单号
   *.H_Custom:客户编号
   *.H_CusName:客户名称
   *.H_SerialNo:水泥编号
   *.H_Truck:提货车辆
   *.H_Value:提货量
   *.H_Bill:提货单号
   *.H_BillDate:提货日期
   *.H_EachTruck: 随车开单
   *.H_ReportDate:报告日期
   *.H_Reporter:报告人
  -----------------------------------------------------------------------------}

//------------------------------------------------------------------------------
// 数据查询
//------------------------------------------------------------------------------
  sQuery_SysDict = 'Select D_ID, D_Value, D_Memo, D_ParamA, ' +
         'D_ParamB From $Table Where D_Name=''$Name'' Order By D_Index ASC';
  {-----------------------------------------------------------------------------
   从数据字典读取数据
   *.$Table:数据字典表
   *.$Name:字典项名称
  -----------------------------------------------------------------------------}

  sQuery_ExtInfo = 'Select I_ID, I_Item, I_Info From $Table Where ' +
         'I_Group=''$Group'' and I_ItemID=''$ID'' Order By I_Index Desc';
  {-----------------------------------------------------------------------------
   从扩展信息表读取数据
   *.$Table:扩展信息表
   *.$Group:分组名称
   *.$ID:信息标识
  -----------------------------------------------------------------------------}

  sSQL_SnapTruck = 'Create Table $Table(R_ID $Inc, S_ID varChar(20), ' +
       'S_Truck varChar(20), S_Date DateTime, S_PicName varChar(80))';
  {-----------------------------------------------------------------------------
   车牌识别:
   *.R_ID:记录编号
   *.S_ID: 抓拍岗位
   *.S_Truck:抓拍车牌号
   *.S_Date: 抓拍时间
   *.S_PicName: 抓拍图片路径
  -----------------------------------------------------------------------------}

  sSQL_NewWebOrderMatch = 'Create Table $Table(R_ID $Inc,'
      +'WOM_WebOrderID varchar(32) null,'
      +'WOM_LID varchar(20) null,'
      +'WOM_StatusType Integer,'
      +'WOM_MsgType Integer,'
      +'WOM_BillType char(1),'
      +'WOM_SyncNum Integer default 0,'
      +'WOM_QueueMsg varchar(100),'
      +'WOM_QueueTime datetime,'
      +'WOM_deleted char(1) default ''N'')';
  {-----------------------------------------------------------------------------
   商城订单与提货单对照表: WebOrderMatch
   *.R_ID: 记录编号
   *.WOM_WebOrderID: 商城订单
   *.WOM_LID: 提货单
   *.WOM_StatusType: 订单状态 0.开卡  1.完成
   *.WOM_MsgType: 消息类型 开单  出厂  报表 删单
   *.WOM_SyncNum: 发送次数
   *.WOM_QueueMsg: 入队信息
   *.WOM_QueueTime: 入队时间
   *.WOM_BillType: 业务类型  采购 销售
  -----------------------------------------------------------------------------}

  sSQL_NewPTruckControlInfo = 'Create Table $Table(R_ID $Inc, C_CusID varChar(32),' +
       'C_CusName varChar(150), C_StockNo varChar(32), C_StockName varChar(150), C_Count Integer,' +
       'C_Valid char(1) default ''Y'', C_Memo varchar(200))';
  {-----------------------------------------------------------------------------
   原材料进厂控制表:
   *.R_ID: 编号
   *.C_CusID: 客户编号
   *.C_CusName: 客户名称
   *.C_StockNo: 物料编号
   *.C_StockName: 物料名称
   *.C_Count: 数量
   *.C_Valid: 是否有效
   *.C_Memo: 备注
  -----------------------------------------------------------------------------}

  sSQL_NewPTimeControlInfo = 'Create Table $Table(R_ID $Inc, X_StockNo varChar(32),' +
       'X_StockName varChar(150), X_BeginTime varChar(10),' +
       'X_EndTime varChar(10), X_Valid char(1) default ''Y'', X_Memo varchar(200))';
  {-----------------------------------------------------------------------------
   基本信息表: BaseInfo
   *.R_ID: 编号
   *.X_StockNo: 物料编号
   *.X_StockName: 物料名称
   *.X_BeginTime: 起始时间
   *.X_EndTime: 结束时间
   *.X_Valid: 是否有效
   *.X_Memo: 备注
  -----------------------------------------------------------------------------}

function CardStatusToStr(const nStatus: string): string;
//磁卡状态
function TruckStatusToStr(const nStatus: string): string;
//车辆状态
function BillTypeToStr(const nType: string): string;
//订单类型
function PostTypeToStr(const nPost: string): string;
//岗位类型
function BusinessToStr(const nBus: string): string;
//业务类型

implementation

//Desc: 将nStatus转为可读内容
function CardStatusToStr(const nStatus: string): string;
begin
  if nStatus = sFlag_CardIdle then Result := '空闲' else
  if nStatus = sFlag_CardUsed then Result := '正常' else
  if nStatus = sFlag_CardLoss then Result := '挂失' else
  if nStatus = sFlag_CardInvalid then Result := '注销' else Result := '未知';
end;

//Desc: 将nStatus转为可识别的内容
function TruckStatusToStr(const nStatus: string): string;
begin
  if nStatus = sFlag_TruckIn then Result := '进厂' else
  if nStatus = sFlag_TruckOut then Result := '出厂' else
  if nStatus = sFlag_TruckBFP then Result := '称皮重' else
  if nStatus = sFlag_TruckBFM then Result := '称毛重' else
  if nStatus = sFlag_TruckSH then Result := '送货中' else
  if nStatus = sFlag_TruckXH then Result := '验收处' else
  if nStatus = sFlag_TruckFH then Result := '放灰处' else
  if nStatus = sFlag_TruckWT then Result := '加水' else
  if nStatus = sFlag_TruckZT then Result := '栈台' else Result := '未进厂';
end;

//Desc: 交货单类型转为可识别内容
function BillTypeToStr(const nType: string): string;
begin
  if nType = sFlag_TypeShip then Result := '船运' else
  if nType = sFlag_TypeZT   then Result := '栈台' else
  if nType = sFlag_TypeVIP  then Result := 'VIP' else Result := '普通';
end;

//Desc: 将岗位转为可识别内容
function PostTypeToStr(const nPost: string): string;
begin
  if nPost = sFlag_TruckIn   then Result := '门卫进厂' else
  if nPost = sFlag_TruckOut  then Result := '门卫出厂' else
  if nPost = sFlag_TruckBFP  then Result := '磅房称皮' else
  if nPost = sFlag_TruckBFM  then Result := '磅房称重' else
  if nPost = sFlag_TruckFH   then Result := '散装放灰' else
  if nPost = sFlag_TruckZT   then Result := '袋装栈台' else Result := '厂外';
end;

//Desc: 业务类型转为可识别内容
function BusinessToStr(const nBus: string): string;
begin
  if nBus = sFlag_Sale       then Result := '销售' else
  if nBus = sFlag_Provide    then Result := '供应' else
  if nBus = sFlag_DuanDao    then Result := '内倒' else
  if nBus = sFlag_Returns    then Result := '退货' else
  if nBus = sFlag_ShipPro    then Result := '供应' else
  if nBus = sFlag_ShipTmp    then Result := '转运' else
  if nBus = sFlag_HaulBack   then Result := '回空' else
  if nBus = sFlag_Other      then Result := '其它';
end;

//------------------------------------------------------------------------------
//Desc: 添加系统表项
procedure AddSysTableItem(const nTable,nNewSQL: string);
var nP: PSysTableItem;
begin
  New(nP);
  gSysTableList.Add(nP);

  nP.FTable := nTable;
  nP.FNewSQL := nNewSQL;
end;

//Desc: 系统表
procedure InitSysTableList;
begin
  gSysTableList := TList.Create;

  AddSysTableItem(sTable_SysDict, sSQL_NewSysDict);
  AddSysTableItem(sTable_ExtInfo, sSQL_NewExtInfo);
  AddSysTableItem(sTable_SysLog, sSQL_NewSysLog);

  AddSysTableItem(sTable_BaseInfo, sSQL_NewBaseInfo);
  AddSysTableItem(sTable_SerialBase, sSQL_NewSerialBase);
  AddSysTableItem(sTable_SerialStatus, sSQL_NewSerialStatus);
  AddSysTableItem(sTable_StockMatch, sSQL_NewStockMatch);
  AddSysTableItem(sTable_WorkePC, sSQL_NewWorkePC);
  AddSysTableItem(sTable_ManualEvent, sSQL_NewManualEvent);

  AddSysTableItem(sTable_Order, sSQL_NewOrder);
  AddSysTableItem(sTable_Customer, sSQL_NewCustomer);

  AddSysTableItem(sTable_Card, sSQL_NewCard);
  AddSysTableItem(sTable_Bill, sSQL_NewBill);
  AddSysTableItem(sTable_BillBak, sSQL_NewBill);
  AddSysTableItem(sTable_BillNew, sSQB_NewBillNew);
  AddSysTableItem(sTable_BillNewBak, sSQB_NewBillNew);
  AddSysTableItem(sTable_BillHaulBak, sSQL_NewBillHaulback);
  AddSysTableItem(sTable_BillHaulBack, sSQL_NewBillHaulback);

  AddSysTableItem(sTable_Truck, sSQL_NewTruck);
  AddSysTableItem(sTable_ZTLines, sSQL_NewZTLines);
  AddSysTableItem(sTable_ZTTrucks, sSQL_NewZTTrucks);
  AddSysTableItem(sTable_Batcode, sSQL_NewBatcode);
  AddSysTableItem(sTable_BatcodeDoc, sSQL_NewBatcodeDoc);
  AddSysTableItem(sTable_Deduct, sSQL_NewDeduct);
  AddSysTableItem(sTable_PoundShip, sSQL_NewPoundShip);
  AddSysTableItem(sTable_Mine, sSQL_NewMine);
  AddSysTableItem(sTable_StationTruck, sSQL_NewStationTruck);

  AddSysTableItem(sTable_PoundLog, sSQL_NewPoundLog);
  AddSysTableItem(sTable_PoundBak, sSQL_NewPoundLog);
  AddSysTableItem(sTable_Picture, sSQL_NewPicture);
  AddSysTableItem(sTable_Alivision, sSQL_NewAlivision);
  AddSysTableItem(sTable_PoundDaiWC, sSQL_NewPoundDaiWC);

  AddSysTableItem(sTable_PoundStation, sSQL_NewPoundLog);
  AddSysTableItem(sTable_PoundStatBak, sSQL_NewPoundLog);
  AddSysTableItem(sTable_PoundStatIMP, sSQL_NewPoundLog);
  AddSysTableItem(sTable_PoundStatIMPBak, sSQL_NewPoundLog);

  AddSysTableItem(sTable_PoundLogKs, sSQL_NewPoundLog);

  AddSysTableItem(sTable_Provider, ssql_NewProvider);
  AddSysTableItem(sTable_Materails, sSQL_NewMaterails);
  AddSysTableItem(sTable_ProvBase, sSQL_NewProvBase);
  AddSysTableItem(sTable_ProvBaseBak, sSQL_NewProvBase);
  AddSysTableItem(sTable_ProvDtl, sSQL_NewProvDtl);
  AddSysTableItem(sTable_ProvDtlBak, sSQL_NewProvDtl);
  AddSysTableItem(sTable_Transfer, sSQL_NewTransfer);
  AddSysTableItem(sTable_TransferBak, sSQL_NewTransfer);

  AddSysTableItem(sTable_CardProvideBak, sSQL_NewCardProvide);
  AddSysTableItem(sTable_CardOtherBak, sSQL_NewCardOther);
  AddSysTableItem(sTable_CardProvide, sSQL_NewCardProvide);
  AddSysTableItem(sTable_CardOther, sSQL_NewCardOther);

  AddSysTableItem(sTable_ChineseBase, sSQL_NewChineseBase);
  AddSysTableItem(sTable_ChineseDict, sSQL_NewChineseDict);
  AddSysTableItem(sTable_WebOrderInfo, sSQL_NewWebOrderInfo);
  AddSysTableItem(sTable_WebSyncStatus, sSQL_NewWebSyncStatus);
  AddSysTableItem(sTable_WebSendMsgInfo, sSQL_NewWebSendMsgInfo);

  AddSysTableItem(sTable_CardGrab, sSQL_CardGrab);
  AddSysTableItem(sTable_Grab, sSQL_Grab);
  AddSysTableItem(sTable_GrabBak, sSQL_Grab);

  AddSysTableItem(sTable_SnapTruck,sSQL_SnapTruck);
  AddSysTableItem(sTable_WebOrderMatch,sSQL_NewWebOrderMatch);

  AddSysTableItem(sTable_StockParam, sSQL_NewStockParam);
  AddSysTableItem(sTable_StockParamExt, sSQL_NewStockRecord);
  AddSysTableItem(sTable_StockRecord, sSQL_NewStockRecord);
  AddSysTableItem(sTable_StockHuaYan, sSQL_NewStockHuaYan);

  AddSysTableItem(sTable_TruckSnap, sSQL_NewTruck);
  AddSysTableItem(sTable_PTruckControl,sSQL_NewPTruckControlInfo);
  AddSysTableItem(sTable_PTimeControl,sSQL_NewPTimeControlInfo);
end;

//Desc: 清理系统表
procedure ClearSysTableList;
var nIdx: integer;
begin
  for nIdx:= gSysTableList.Count - 1 downto 0 do
  begin
    Dispose(PSysTableItem(gSysTableList[nIdx]));
    gSysTableList.Delete(nIdx);
  end;

  FreeAndNil(gSysTableList);
end;

initialization
  InitSysTableList;
finalization
  ClearSysTableList;
end.




{*******************************************************************************
  作者: dmzn@163.com 2010-3-8
  描述: 系统业务处理
*******************************************************************************}
unit USysBusiness;

{$I Link.Inc} 
interface

uses
  Windows, DB, Classes, Controls, SysUtils, UBusinessPacker, UBusinessWorker,
  UBusinessConst, ULibFun, UAdjustForm, UFormCtrl, UDataModule, UDataReport,
  UFormBase, cxMCListBox, UMgrPoundTunnels, HKVNetSDK, USysConst, USysDB,
  USysLoger, UBase64, UFormWait, Graphics, ShellAPI, DateUtils, StrUtils;

type
  TLadingStockItem = record
    FID: string;         //编号
    FType: string;       //类型
    FName: string;       //名称
    FParam: string;      //扩展
  end;

  TDynamicStockItemArray = array of TLadingStockItem;
  //系统可用的品种列表

  PZTLineItem = ^TZTLineItem;
  TZTLineItem = record
    FID       : string;      //编号
    FName     : string;      //名称
    FStock    : string;      //品名
    FIsVip    : string;      //类型
    FWeight   : Integer;     //袋重
    FValid    : Boolean;     //是否有效
    FPrinterOK: Boolean;     //喷码机
    FLineGroup: string;      //通道分组
  end;

  PZTTruckItem = ^TZTTruckItem;
  TZTTruckItem = record
    FTruck    : string;      //车牌号
    FLine     : string;      //通道
    FBill     : string;      //提货单
    FValue    : Double;      //提货量
    FDai      : Integer;     //袋数
    FTotal    : Integer;     //总数
    FInFact   : Boolean;     //是否进厂
    FIsRun    : Boolean;     //是否运行
    FTruckEx  : string;      //格式化车牌号
  end;

  TZTLineItems = array of TZTLineItem;
  TZTTruckItems = array of TZTTruckItem;

  TOrderItemInfo = record
    FCusID: string;       //客户号
    FCusName: string;     //客户名
    FSaleMan: string;     //业务员
    FStockID: string;     //物料号
    FStockName: string;   //物料名

    FStockBrand: string;  //物料品牌
    FStockArea : string;  //产地，矿点
    FAreaTo    : string;

    FTruck: string;       //车牌号
    FBatchCode: string;   //批次号
    FOrders: string;      //订单号(可多张)
    FValue: Double;       //可用量
    FBm: string;          //喷码发送的中文编码
    FSpecialCus: string;  //是否为特殊客户
  end;

  TOrderItem = record
    FOrderID: string;       //订单编号
    FStockID: string;       //物料编号
    FStockName: string;     //物料名称
    FStockBrand: string;    //水泥品牌
    FCusName: string;       //客户名称
    FSaleMan: string;       //业务员
    FTruck: string;         //车牌号码
    FBatchCode: string;     //批次号
    FAreaName: string;      //到货地点
    FAreaTo: string;        //区域流向
    FValue: Double;         //订单可用
    FPlanNum: Double;       //计划量
  end;

//------------------------------------------------------------------------------
function AdjustHintToRead(const nHint: string): string;
//调整提示内容
function WorkPCHasPopedom: Boolean;
//验证主机是否已授权
function GetSysValidDate: Integer;
//获取系统有效期
function GetSerialNo(const nGroup,nObject: string;
 nUseDate: Boolean = True): string;
//获取串行编号
function GetStockBatcode(const nStock: string; const nExt: string): string;
//获取批次号
function GetLadingStockItems(var nItems: TDynamicStockItemArray): Boolean;
//可用品种列表
function GetQueryOrderSQL(const nType,nWhere: string): string;
//订单查询SQL语句
function GetQueryDispatchSQL(const nWhere: string): string;
//调拨订单SQL语句
function GetQueryCustomerSQL(const nCusID,nCusName: string): string;
//客户查询SQL语句

function LoadSysDictItem(const nItem: string; const nList: TStrings): TDataSet;
//读取系统字典项
function LoadCustomerInfo(const nCID: string; const nList: TcxMCListBox;
 var nHint: string): TDataSet;
//载入客户信息
function BuildOrderInfo(const nItem: TOrderItemInfo): string;
procedure AnalyzeOrderInfo(const nOrder: string; var nItem: TOrderItemInfo);
procedure LoadOrderInfo(const nOrder: TOrderItemInfo; const nList: TcxMCListBox);
//处理订单信息
function GetOrderFHValue(const nOrders: TStrings;
  const nQueryFreeze: Boolean=True): Boolean;
//获取订单发货量
function GetOrderGYValue(const nOrders: TStrings): Boolean;
//获取订单已供应量
function GetCardUsed(const nCard: string): string;
function SaveBillNew(const nBillData: string): string;
//保存销售订单
function DeleteBillNew(const nBill: string): Boolean;
//删除长期凭证(必须为未使用)
function SaveBillFromNew(const nBill: string): string;
//根据销售订单生成交货单
function SaveBillNewCard(const nBill, nCard: string): Boolean;
//办理磁卡
function SaveBill(const nBillData: string): string;
//保存交货单
function DeleteBill(const nBill: string): Boolean;
//删除交货单
function ChangeLadingTruckNo(const nBill,nTruck: string): Boolean;
//更改提货车辆
function BillSaleAdjust(const nBill, nNewZK: string): Boolean;
//交货单调拨
function SetBillCard(const nBill,nTruck: string; nVerify: Boolean;
  nLongFlag: Boolean=False): Boolean;
//为交货单办理磁卡
function SaveBillCard(const nBill, nCard: string): Boolean;
//保存交货单磁卡
function LogoutBillCard(const nCard: string): Boolean;
//注销指定磁卡

function SaveOrder(const nOrderData: string): string;
//保存采购单
function DeleteOrder(const nOrder: string): Boolean;
//删除采购单
function DeleteOrderDtl(const nOrder: string): Boolean;
//删除采购明细
function SetOrderCard(const nOrder,nTruck: string): Boolean;
//为采购单办理磁卡
function SaveOrderCard(const nOrderCard: string): Boolean;
//保存采购单磁卡
function LogoutOrderCard(const nCard: string): Boolean;
//注销指定磁卡

function SaveDuanDaoCard(const nTruck, nCard: string): Boolean;
//保存短倒磁卡
function LogoutDuanDaoCard(const nCard: string): Boolean;
//注销指定磁卡
function SaveTransferInfo(nTruck, nMateID, nMate, nSrcAddr, nDstAddr:string):Boolean;
//办理短倒磁卡

function GetLadingBills(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
//获取指定岗位的交货单列表
procedure LoadBillItemToMC(const nItem: TLadingBillItem; const nMC: TStrings;
 const nDelimiter: string);
//载入单据信息到列表
function SaveLadingBills(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem = nil;const nLogin: Integer = -1): Boolean;
//保存指定岗位的交货单

function GetTruckPoundItem(const nTruck: string;
 var nPoundData: TLadingBillItems): Boolean;
//获取指定车辆的已称皮重信息
function SaveTruckPoundItem(const nTunnel: PPTTunnelItem;
 const nData: TLadingBillItems; var nPoundID: string;const nLogin: Integer = -1): Boolean;
//保存车辆过磅记录
function ReadPoundCard(var nReader: string;
  const nTunnel: string; nReadOnly: String = ''): string;
//读取指定磅站读头上的卡号
procedure CapturePicture(const nTunnel: PPTTunnelItem; const nList: TStrings);
//抓拍指定通道

procedure GetPoundAutoWuCha(var nWCValZ,nWCValF: Double; const nVal: Double;
 const nStation: string = '');
//获取误差范围

function GetStationPoundItem(const nTruck: string;
 var nPoundData: TLadingBillItems): Boolean;
function SaveStationPoundItem(const nTunnel: PPTTunnelItem;
 const nData: TLadingBillItems; var nPoundID: string;const nLogin: Integer = -1): Boolean;
//存取火车衡过磅记录

function LoadTruckQueue(var nLines: TZTLineItems; var nTrucks: TZTTruckItems;
 const nRefreshLine: Boolean = False): Boolean;
//读取车辆队列
procedure PrinterEnable(const nTunnel: string; const nEnable: Boolean);
//启停喷码机
function ChangeDispatchMode(const nMode: Byte): Boolean;
//切换调度模式
function LoadZTLineGroup(const nList: TStrings; const nWhere: string = ''): Boolean;
//栈台分组
function LoadPoundStation(const nList: TStrings; const nWhere: string = ''): Boolean;
//指定磅站

function LoadPoundStock(const nList: TStrings; const nWhere: string = ''): Boolean;
//读取可用地磅物料列表到nList中,包含附加数据
function LoadLine(const nList: TStrings; const nWhere: string = ''): Boolean;
//读取通道列表到nList中,包含附加数据
function PrintBillReport(nBill: string; const nAsk: Boolean): Boolean;
//打印提货单
function PrintPoundReport(const nPound: string; nAsk: Boolean): Boolean;
//打印榜单
function PrintSalePoundReport(const nPound: string; nAsk: Boolean): Boolean;
//打印销售磅单
function PrintOrderReport(nOrder: string; const nAsk: Boolean): Boolean;
//打印采购单
function PrintDuanDaoReport(nID: string; const nAsk: Boolean): Boolean;
//打印短倒单
function PrintShipLeaveReport(nID: string; const nAsk: Boolean): Boolean;
//船运离岗销售通知单
function PrintShipLeaveCGReport(nID: string; const nAsk: Boolean): Boolean;
//船运离岗采购通知单
function PrintShipProReport(nRID: string; const nAsk: Boolean): Boolean;
//打印复磅采购单

//保存电子标签
function SetTruckRFIDCard(nTruck: string; var nRFIDCard: string;
  var nIsUse: string; nOldCard: string=''): Boolean;
//指定道装车
function SelectTruckTunnel(var nNewTunnel, nStockNo: string; const nLineGroup: string): Boolean;

function SaveWeiXinAccount(const nItem:TWeiXinAccount; var nWXID:string): Boolean;
function DelWeiXinAccount(const nWXID:string): Boolean;

function GetTruckPValue(var nItem:TPreTruckPItem; const nTruck: string):Boolean;
//获取车辆预置皮重
function TruckInFact(nTruck: string):Boolean;
//验证车辆是否出厂
function GetPoundSanWuChaStop(const nStock: string): Boolean;
//超出误差停止业务

function GetTruckNO(const nTruck: String): string;
function GetOrigin(const nOrigin: String): string;
function GetValue(const nValue: Double): string;
//显示格式化

procedure ShowCapturePicture(const nID: string);
//查看抓拍

function GetTruckLastTime(const nTruck: string; var nLast: Integer): Boolean;
//获取车辆活动间隔

function IsTunnelOK(const nTunnel: string): Boolean;
//查询通道光栅是否正常
procedure TunnelOC(const nTunnel: string; const nOpen: Boolean);
//控制通道红绿灯开合
procedure ProberShowTxt(const nTunnel, nText: string);
//车检发送小屏
function PlayNetVoice(const nText,nCard,nContent: string): Boolean;
//经中间件播发语音
function OpenDoorByReader(const nReader: string; nType: string = 'Y'): Boolean;
//打开道闸

function SaveCardProvie(const nCardData: string): string;
//保存采购卡
function DeleteCardProvide(const nID: string): Boolean;
//删除采购卡

function SaveCardOther(const nCardData: string): string;
//保存临时卡
function DeleteCardOther(const nID: string): Boolean;
//删除临时卡

function SaveBillHaulBack(const nCardData: string): string;
//Desc: 保存回空业务单据信息
function DeleteBillHaulBack(const nID: string): Boolean;
//删除回空业务单据

function WebChatGetCustomerInfo: string;
//获取网上商城客户信息
function WebChatEditShopCustom(const nData: string; nSale: string = 'Y'): Boolean;
//修改绑定关系

function AddManualEventRecord(nEID, nKey, nEvent:string;
    nFrom: string = '磅房'; nSolution: string=sFlag_Solution_YN;
    nDepartmen: string=sFlag_DepDaTing; nReset: Boolean = False;
    nMemo: string=''): Boolean;
//添加待处理事项记录
function VerifyManualEventRecord(const nEID: string; var nHint: string;
    const nWant: string = 'Y'; const nUpdateHint: Boolean = True): Boolean;
//检查事件是否通过处理
function DealManualEvent(const nEID, nResult: string; nMemo: string=''): Boolean;
//处理待处理事项


function GetTruckEmptyValue(nTruck, nType: string): Double;
//车辆有效皮重
function GetStockTruckSort(nID: string=''): string;
//车辆排队序列

function PrintHuaYanReport(const nHID: string; const nAsk: Boolean): Boolean;
//打印标识为nHID的化验单
function PrintHuaYanReportEx(const nHID, nSeal: string; const nAsk: Boolean): Boolean;
//打印标识为nHID的化验单
function PrintHeGeReport(const nHID: string; const nAsk: Boolean): Boolean;
//化验单,合格证
function IsOrderCanLade(nOrderID: string): Boolean;
//查询此订单是否可以开卡
function InitViewData: Boolean;
function MakeSaleViewData(nID: string; nMValue: Double): Boolean;
function GetStockType(nBill: string):string;

function IsStationAutoP(const nTruck: string; var nPValue: Double;
                        nMsg: string): Boolean;
//火车衡自动获取最近5条历史皮重
function GetStationTruckStock(const nTruck: string; var nStockNo,
                        nStockName: string): Boolean;
//火车衡自动获取最近一次过磅物料
function VeriFySnapTruck(const nReader: string; nBill: TLadingBillItem;
                         var nMsg, nPos: string): Boolean;
function SaveSnapTruckInfo(const nReader: string; nBill: TLadingBillItem;
                         var nMsg, nPos: string): Boolean;
function ReadPoundReaderInfo(const nReader: string; var nDept: string): string;
//读取nReader岗位、部门
procedure RemoteSnapDisPlay(const nPost, nText, nSucc: string);

function InfoConfirmDone(const nID, nStockNo: string): Boolean;
//现场信息确认
function IsTruckAutoIn: Boolean;
//车辆自动进厂
function GetTruckHisValueMax(const nTruck: string): Double;
//获取车辆历史最大提货量
function GetTruckHisMValueMax(const nTruck: string): Double;
//获取车辆历史最大毛重
function GetMaxMValue(const nTruck: string): Double;
//获取毛重限值
function SyncSaleDetail(const nStr: string): Boolean;
//同步提货单
function SyncPoundDetail(const nStr: string): Boolean;
//同步磅单

function GetHYMaxValue: Double;
function GetHYValueByStockNo(const nNo: string): Double;
//获取化验单已开量
function ZTDispatchByLine(const nRID: Integer; nBill, nOldLine, nNewLine,
                           nTruckStockNo: string): Boolean;
function GetBatCodeByLine(const nLID, nStockNo, nTunnel: string;
                          var nSeal: string): Boolean;
function VerifyStockCanPound(const nStockNo, nTunnel: string;
                             var nHint: string): Boolean;
//校验物料是否可以在nTunnel过磅
procedure CapturePictureEx(const nTunnel: PPTTunnelItem;
                         const nLogin: Integer; nList: TStrings);
//抓拍nTunnel的图像Ex
function InitCapture(const nTunnel: PPTTunnelItem; var nLogin: Integer): Boolean;
//初始化抓拍，与CapturePictureEx配套使用
function FreeCapture(nLogin: Integer): Boolean;
//释放抓拍
function GetSanMaxLadeValue: Double;
//散装最大开单量限制
function AutoGetSanHDOrder(nCusID,nStockID,nTruck:string;
                           nHDValue: Double; var nOrderStr: string): Boolean;
//散装自动获取合单订单
procedure SaveTruckPrePValue(const nTruck, nValue: string);
//保存预制皮重
function GetPrePValueSet: Double;
//获取系统设定皮重
function SaveTruckPrePicture(const nTruck: string;const nTunnel: PPTTunnelItem;
                             const nLogin: Integer = -1): Boolean;
//保存nTruck的预制皮重照片
function SaveSnapStatus(const nBill: TLadingBillItem; nStatus: string): Boolean;
implementation

//Desc: 记录日志
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(nEvent);
end;

//------------------------------------------------------------------------------
//Desc: 调整nHint为易读的格式
function AdjustHintToRead(const nHint: string): string;
var nIdx: Integer;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    nList.Text := nHint;
    for nIdx:=0 to nList.Count - 1 do
      nList[nIdx] := '※.' + nList[nIdx];
    Result := nList.Text;
  finally
    nList.Free;
  end;
end;

//Desc: 验证主机是否已授权接入系统
function WorkPCHasPopedom: Boolean;
begin
  Result := gSysParam.FSerialID <> '';
  if not Result then
  begin
    ShowDlg('该功能需要更高权限,请向管理员申请.', sHint);
  end;
end;

function GetTruckNO(const nTruck: String): string;
var nStrTmp: string;
begin
  nStrTmp := '      ' + nTruck;
  Result := Copy(nStrTmp, Length(nStrTmp)-6 + 1, 6) + '      ';
end;

function GetOrigin(const nOrigin: String): string;
var nStrTmp: string;
begin
  nStrTmp := '      ' + Copy(nOrigin, 1, 4);
  Result := Copy(nStrTmp, Length(nStrTmp)-6 + 1, 6);
end;

function GetValue(const nValue: Double): string;
var nStrTmp: string;
begin
  nStrTmp := Format('      %.2f', [nValue]);
  Result := Copy(nStrTmp, Length(nStrTmp)-6 + 1, 6);
end;

//Date: 2014-09-05
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的业务命令对象
function CallBusinessCommand(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //自动称重时不提示

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessCommand);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-05
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的销售单据对象
function CallBusinessSaleBill(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //自动称重时不提示

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessSaleBill);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-05
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的销售单据对象
function CallBusinessProvideItems(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //自动称重时不提示

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessProvide);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-05
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的短倒单据对象
function CallBusinessDuanDao(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //自动称重时不提示

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessDuanDao);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-10-01
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的销售单据对象
function CallBusinessHardware(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //自动称重时不提示
    
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareCommand);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2017/6/2
//Parm: 命令;数据;参数;输出
//Desc: 船运采购业务
function CallBusinessShipProItems(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //自动称重时不提示

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessShipPro);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2017/6/2
//Parm: 命令;数据;参数;输出
//Desc: 船运临时业务
function CallBusinessShipTmpItems(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //自动称重时不提示

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessShipTmp);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2017/6/2
//Parm: 命令;数据;参数;输出
//Desc: 回空业务
function CallBusinessHaulBackItems(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //自动称重时不提示

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessHaulback);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-04
//Parm: 分组;对象;使用日期编码模式
//Desc: 依据nGroup.nObject生成串行编号
function GetSerialNo(const nGroup,nObject: string; nUseDate: Boolean): string;
var nStr: string;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  Result := '';
  nList := nil;
  try
    nList := TStringList.Create;
    nList.Values['Group'] := nGroup;
    nList.Values['Object'] := nObject;

    if nUseDate then
         nStr := sFlag_Yes
    else nStr := sFlag_No;

    if CallBusinessCommand(cBC_GetSerialNO, nList.Text, nStr, @nOut) then
      Result := nOut.FData;
    //xxxxx
  finally
    nList.Free;
  end;   
end;

//Date: 2015-01-16
//Parm: 物料号;其他信息
//Desc: 生产nStock的批次号
function GetStockBatcode(const nStock: string; const nExt: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_GetStockBatcode, nStock, nExt, @nOut, False) then
       Result := nOut.FData
  else
  begin
    Result := '';
    WriteLog('获取批次号失败:' + nOut.FData);
  end;
end;

//Desc: 获取系统有效期
function GetSysValidDate: Integer;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_IsSystemExpired, '', '', @nOut) then
       Result := StrToInt(nOut.FData)
  else Result := 0;
end;

//Desc: 获取卡片类型
function GetCardUsed(const nCard: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := sFlag_Sale;
  if CallBusinessCommand(cBC_GetCardUsed, nCard, '', @nOut) then
    Result := nOut.FData;
  //xxxxx
end;

//Date: 2014-12-16
//Parm: 订单类型;查询条件
//Desc: 获取nType类型的订单查询语句
function GetQueryOrderSQL(const nType,nWhere: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_GetSQLQueryOrder, nType, nWhere, @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2014-12-16
//Parm: 查询条件
//Desc: 获取调拨订单查询语句
function GetQueryDispatchSQL(const nWhere: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_GetSQLQueryDispatch, '', nWhere, @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2014-12-18
//Parm: 客户编号;客户名称
//Desc: 获取nCusName的模糊查询SQL语句
function GetQueryCustomerSQL(const nCusID,nCusName: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_GetSQLQueryCustomer, nCusID, nCusName, @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Desc: 获取当前系统可用的水泥品种列表
function GetLadingStockItems(var nItems: TDynamicStockItemArray): Boolean;
var nStr: string;
    nIdx: Integer;
begin
  nStr := 'Select D_Value,D_Memo,D_ParamB From $Table ' +
          'Where D_Name=''$Name'' Order By D_Index ASC';
  nStr := MacroValue(nStr, [MI('$Table', sTable_SysDict),
                            MI('$Name', sFlag_StockItem)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    SetLength(nItems, RecordCount);
    if RecordCount > 0 then
    begin
      nIdx := 0;
      First;

      while not Eof do
      begin
        nItems[nIdx].FType := FieldByName('D_Memo').AsString;
        nItems[nIdx].FName := FieldByName('D_Value').AsString;
        nItems[nIdx].FID := FieldByName('D_ParamB').AsString;

        Next;
        Inc(nIdx);
      end;
    end;
  end;

  Result := Length(nItems) > 0;
end;

//------------------------------------------------------------------------------
//Date: 2014-06-19
//Parm: 记录标识;车牌号;图片文件
//Desc: 将nFile存入数据库
procedure SavePicture(const nID, nTruck, nMate, nFile: string);
var nStr: string;
    nRID: Integer;
begin
  FDM.ADOConn.BeginTrans;
  try
    nStr := MakeSQLByStr([
            SF('P_ID', nID),
            SF('P_Name', nTruck),
            SF('P_Mate', nMate),
            SF('P_Date', sField_SQLServer_Now, sfVal)
            ], sTable_Picture, '', True);
    //xxxxx

    if FDM.ExecuteSQL(nStr) < 1 then Exit;
    nRID := FDM.GetFieldMax(sTable_Picture, 'R_ID');

    nStr := 'Select P_Picture From %s Where R_ID=%d';
    nStr := Format(nStr, [sTable_Picture, nRID]);
    FDM.SaveDBImage(FDM.QueryTemp(nStr), 'P_Picture', nFile);

    FDM.ADOConn.CommitTrans;
  except
    FDM.ADOConn.RollbackTrans;
  end;
end;

//Desc: 构建图片路径
function MakePicName: string;
begin
  while True do
  begin
    Result := gSysParam.FPicPath + IntToStr(gSysParam.FPicBase) + '.jpg';
    if not FileExists(Result) then
    begin
      Inc(gSysParam.FPicBase);
      Exit;
    end;

    DeleteFile(Result);
    if FileExists(Result) then Inc(gSysParam.FPicBase)
  end;
end;

//Date: 2014-06-19
//Parm: 通道;列表
//Desc: 抓拍nTunnel的图像
procedure CapturePicture(const nTunnel: PPTTunnelItem; const nList: TStrings);
const
  cRetry = 2;
  //重试次数
var nStr: string;
    nIdx,nInt: Integer;
    nLogin,nErr: Integer;
    nPic: NET_DVR_JPEGPARA;
    nInfo: TNET_DVR_DEVICEINFO;
begin
  nList.Clear;
  if not Assigned(nTunnel.FCamera) then Exit;
  //not camera

  if not DirectoryExists(gSysParam.FPicPath) then
    ForceDirectories(gSysParam.FPicPath);
  //new dir

  if gSysParam.FPicBase >= 100 then
    gSysParam.FPicBase := 0;
  //clear buffer

  nLogin := -1;
  NET_DVR_Init();
  try
    for nIdx:=1 to cRetry do
    begin
      nLogin := NET_DVR_Login(PChar(nTunnel.FCamera.FHost),
                   nTunnel.FCamera.FPort,
                   PChar(nTunnel.FCamera.FUser),
                   PChar(nTunnel.FCamera.FPwd), @nInfo);
      //to login

      nErr := NET_DVR_GetLastError;
      if nErr = 0 then break;

      if nIdx = cRetry then
      begin
        nStr := '登录摄像机[ %s.%d ]失败,错误码: %d';
        nStr := Format(nStr, [nTunnel.FCamera.FHost, nTunnel.FCamera.FPort, nErr]);
        WriteLog(nStr);
        Exit;
      end;
    end;

    nPic.wPicSize := nTunnel.FCamera.FPicSize;
    nPic.wPicQuality := nTunnel.FCamera.FPicQuality;

    for nIdx:=Low(nTunnel.FCameraTunnels) to High(nTunnel.FCameraTunnels) do
    begin
      if nTunnel.FCameraTunnels[nIdx] = MaxByte then continue;
      //invalid

      for nInt:=1 to cRetry do
      begin
        nStr := MakePicName();
        //file path

        NET_DVR_CaptureJPEGPicture(nLogin, nTunnel.FCameraTunnels[nIdx],
                                   @nPic, PChar(nStr));
        //capture pic

        nErr := NET_DVR_GetLastError;
        if nErr = 0 then
        begin
          nList.Add(nStr);
          Break;
        end;

        if nIdx = cRetry then
        begin
          nStr := '抓拍图像[ %s.%d ]失败,错误码: %d';
          nStr := Format(nStr, [nTunnel.FCamera.FHost,
                   nTunnel.FCameraTunnels[nIdx], nErr]);
          WriteLog(nStr);
        end;
      end;
    end;
  finally
    if nLogin > -1 then
      NET_DVR_Logout(nLogin);
    NET_DVR_Cleanup();
  end;
end;

//------------------------------------------------------------------------------
//Date: 2017-07-09
//Parm: 包装正负误差;票重;磅站号
//Desc: 计算nVal的误差范围
procedure GetPoundAutoWuCha(var nWCValZ,nWCValF: Double; const nVal: Double;
 const nStation: string);
var nStr: string;
begin
  nWCValZ := 0;
  nWCValF := 0;
  if nVal <= 0 then Exit;

  nStr := 'Select * From %s Where P_Start<=%.2f and P_End>%.2f';
  nStr := Format(nStr, [sTable_PoundDaiWC, nVal, nVal]);

  if Length(nStation) > 0 then
    nStr := nStr + ' And P_Station=''' + nStation + '''';
  //xxxxx

  with FDM.QuerySQL(nStr) do
  if RecordCount > 0 then
  begin
    if FieldByName('P_Percent').AsString = sFlag_Yes then 
    begin
      nWCValZ := nVal * 1000 * FieldByName('P_DaiWuChaZ').AsFloat;
      nWCValF := nVal * 1000 * FieldByName('P_DaiWuChaF').AsFloat;
      //按比例计算误差
    end else
    begin     
      nWCValZ := FieldByName('P_DaiWuChaZ').AsFloat;
      nWCValF := FieldByName('P_DaiWuChaF').AsFloat;
      //按固定值计算误差
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2010-4-13
//Parm: 字典项;列表
//Desc: 从SysDict中读取nItem项的内容,存入nList中
function LoadSysDictItem(const nItem: string; const nList: TStrings): TDataSet;
var nStr: string;
begin
  nList.Clear;
  nStr := MacroValue(sQuery_SysDict, [MI('$Table', sTable_SysDict),
                                      MI('$Name', nItem)]);
  Result := FDM.QueryTemp(nStr);

  if Result.RecordCount > 0 then
  with Result do
  begin
    First;

    while not Eof do
    begin
      nList.Add(FieldByName('D_Value').AsString);
      Next;
    end;
  end else Result := nil;
end;

//Desc: 载入nCID客户的信息到nList中,并返回数据集
function LoadCustomerInfo(const nCID: string; const nList: TcxMCListBox;
 var nHint: string): TDataSet;
var nStr: string;
begin
  nStr := 'select custcode,t2.pk_cubasdoc,custname,user_name,' +
          't1.createtime from Bd_cumandoc t1' +
          '  left join bd_cubasdoc t2 on t2.pk_cubasdoc=t1.pk_cubasdoc' +
          '  left join sm_user t_su on t_su.cuserid=t1.creator ' +
          ' where custcode=''%s''';
  nStr := Format(nStr, [nCID]);

  nList.Clear;
  Result := FDM.QueryTemp(nStr, True);

  if Result.RecordCount > 0 then
  with nList.Items,Result do
  begin
    Add('客户编号:' + nList.Delimiter + FieldByName('custcode').AsString);
    Add('客户名称:' + nList.Delimiter + FieldByName('custname').AsString + ' ');
    Add('创 建 人:' + nList.Delimiter + FieldByName('user_name').AsString + ' ');
    Add('创建时间:' + nList.Delimiter + FieldByName('createtime').AsString + ' ');
  end else
  begin
    Result := nil;
    nHint := '客户信息已丢失';
  end;
end;

//Date: 2014-12-23
//Parm: 订单项
//Desc: 将nItem数据打包
function BuildOrderInfo(const nItem: TOrderItemInfo): string;
var nList: TStrings;
begin
  nList := TStringList.Create;
  try
    with nList,nItem do
    begin
      Clear;
      Values['CusID']     := FCusID;
      Values['CusName']   := FCusName;
      Values['SaleMan']   := FSaleMan;

      Values['StockID']   := FStockID;
      Values['StockName'] := FStockName;
      Values['StockBrand']:= FStockBrand;

      Values['StockArea'] := FStockArea;
      Values['AreaTo']    := FAreaTo;

      Values['Truck']     := FTruck;
      Values['BatchCode'] := FBatchCode;
      Values['Orders']    := PackerEncodeStr(FOrders);
      Values['Value']     := FloatToStr(FValue);
      Values['bm']        := FBm;
    end;

    Result := EncodeBase64(nList.Text);
    //编码
  finally
    nList.Free;
  end;
end;

//Date: 2014-12-23
//Parm: 待解析;订单数据
//Desc: 解析nOrder,存入nItem
procedure AnalyzeOrderInfo(const nOrder: string; var nItem: TOrderItemInfo);
var nList: TStrings;
begin
  nList := TStringList.Create;
  try
    with nList,nItem do
    begin
      Text := DecodeBase64(nOrder);
      //解码

      FCusID := Values['CusID'];
      FCusName := Values['CusName'];
      FSaleMan := Values['SaleMan'];

      FStockID := Values['StockID'];
      FStockName := Values['StockName'];
      FStockBrand:= Values['StockBrand'];

      FStockArea := Values['StockArea'];
      FAreaTo    := Values['AreaTo'];

      FTruck := Values['Truck'];
      FBatchCode := Values['BatchCode'];
      FOrders := PackerDecodeStr(Values['Orders']);
      FValue := StrToFloat(Values['Value']);
      FBm := Values['bm'];
    end;
  finally
    nList.Free;
  end;
end;

//Date: 2014-12-23
//Parm: 订单;列表
//Desc: 将nOrder现实到nList中
procedure LoadOrderInfo(const nOrder: TOrderItemInfo; const nList: TcxMCListBox);
var nStr: string;
begin
  with nList.Items, nOrder do
  begin
    Clear;
    nStr := StringReplace(FOrders, #13#10, ',', [rfReplaceAll]);

    Add('客户编号:' + nList.Delimiter + FCusID + ' ');
    Add('客户名称:' + nList.Delimiter + FCusName + ' ');
    Add('业务类型:' + nList.Delimiter + FSaleMan + ' ');
    Add('物料编号:' + nList.Delimiter + FStockID + ' ');
    Add('物料名称:' + nList.Delimiter + FStockName + ' ');
    Add('订单编号:' + nList.Delimiter + nStr + ' ');
    Add('可提货量:' + nList.Delimiter + Format('%.2f',[FValue]) + ' 吨');
  end;
end;

//Date: 2014-12-24
//Parm: 订单列表
//Desc: 获取指定的发货量
function GetOrderFHValue(const nOrders: TStrings;
  const nQueryFreeze: Boolean=True): Boolean;
var nOut: TWorkerBusinessCommand;
    nFlag: string;
begin
  if nQueryFreeze then
       nFlag := sFlag_Yes
  else nFlag := sFlag_No;

  Result := CallBusinessCommand(cBC_GetOrderFHValue,
             EncodeBase64(nOrders.Text), nFlag, @nOut);
  //xxxxx

  if Result then
    nOrders.Text := DecodeBase64(nOut.FData);
  //xxxxx
end;

//Date: 2015-01-08
//Parm: 订单列表
//Desc: 获取指定的发货量
function GetOrderGYValue(const nOrders: TStrings): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetOrderGYValue,
             EncodeBase64(nOrders.Text), '', @nOut);
  //xxxxx

  if Result then
    nOrders.Text := DecodeBase64(nOut.FData);
  //xxxxx
end;

//Date: 2014-09-25
//Parm: 车牌号
//Desc: 获取nTruck的称皮记录
function GetTruckPoundItem(const nTruck: string;
 var nPoundData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetTruckPoundData, nTruck, '', @nOut);
  if Result then
    AnalyseBillItems(nOut.FData, nPoundData);
  //xxxxx
end;

//Date: 2014-09-25
//Parm: 称重数据
//Desc: 保存nData称重数据
function SaveTruckPoundItem(const nTunnel: PPTTunnelItem;
 const nData: TLadingBillItems; var nPoundID: string;const nLogin: Integer): Boolean;
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nPoundID := '';
  nStr := CombineBillItmes(nData);
  Result := CallBusinessCommand(cBC_SaveTruckPoundData, nStr, '', @nOut);
  if (not Result) or (nOut.FData = '') then Exit;
  nPoundID := nOut.FData;

  nList := TStringList.Create;
  try
    {$IFDEF CapturePictureEx}
    if nLogin < 0 then
      CapturePicture(nTunnel, nList)
    else
      CapturePictureEx(nTunnel, nLogin, nList);
    {$ELSE}
    CapturePicture(nTunnel, nList);
    //capture file
    {$ENDIF}

    for nIdx:=0 to nList.Count - 1 do
      SavePicture(nOut.FData, nData[0].FTruck,
                              nData[0].FStockName, nList[nIdx]);
    //save file
  finally
    nList.Free;
  end;
end;

//Date: 2014-10-02
//Parm: 通道号
//Desc: 读取nTunnel读头上的卡号
function ReadPoundCard(var nReader: string;
    const nTunnel: string; nReadOnly: String = ''): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  nReader:= '';
  //卡号

  if CallBusinessHardware(cBC_GetPoundCard, nTunnel, nReadOnly, @nOut)  then
  begin
    Result := Trim(nOut.FData);
    nReader:= Trim(nOut.FExtParam);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2014-10-01
//Parm: 通道;车辆
//Desc: 读取车辆队列数据
function LoadTruckQueue(var nLines: TZTLineItems; var nTrucks: TZTTruckItems;
 const nRefreshLine: Boolean): Boolean;
var nIdx: Integer;
    nSLine,nSTruck: string;
    nListA,nListB: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    if nRefreshLine then
         nSLine := sFlag_Yes
    else nSLine := sFlag_No;

    Result := CallBusinessHardware(cBC_GetQueueData, nSLine, '', @nOut);
    if not Result then Exit;

    nListA.Text := PackerDecodeStr(nOut.FData);
    nSLine := nListA.Values['Lines'];
    nSTruck := nListA.Values['Trucks'];

    nListA.Text := PackerDecodeStr(nSLine);
    SetLength(nLines, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    with nLines[nIdx],nListB do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      FID       := Values['ID'];
      FName     := Values['Name'];
      FStock    := Values['Stock'];
      FIsVip    := Values['VIP'];
      FValid    := Values['Valid'] <> sFlag_No;
      FPrinterOK:= Values['Printer'] <> sFlag_No;

      if IsNumber(Values['Weight'], False) then
           FWeight := StrToInt(Values['Weight'])
      else FWeight := 1;

      FLineGroup:= Values['LineGroup'];
    end;

    nListA.Text := PackerDecodeStr(nSTruck);
    SetLength(nTrucks, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    with nTrucks[nIdx],nListB do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      FTruck    := Values['Truck'];
      FLine     := Values['Line'];
      FBill     := Values['Bill'];

      FTruckEx  := GetStockType(Values['Bill']) + Values['Truck'];

      if IsNumber(Values['Value'], True) then
           FValue := StrToFloat(Values['Value'])
      else FValue := 0;

      FInFact   := Values['InFact'] = sFlag_Yes;
      FIsRun    := Values['IsRun'] = sFlag_Yes;
           
      if IsNumber(Values['Dai'], False) then
           FDai := StrToInt(Values['Dai'])
      else FDai := 0;

      if IsNumber(Values['Total'], False) then
           FTotal := StrToInt(Values['Total'])
      else FTotal := 0;
    end;
  finally
    nListA.Free;
    nListB.Free;
  end;
end;

//Date: 2014-10-01
//Parm: 通道号;启停标识
//Desc: 启停nTunnel通道的喷码机
procedure PrinterEnable(const nTunnel: string; const nEnable: Boolean);
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  if nEnable then
       nStr := sFlag_Yes
  else nStr := sFlag_No;

  CallBusinessHardware(cBC_PrinterEnable, nTunnel, nStr, @nOut);
end;

//Date: 2014-10-07
//Parm: 调度模式
//Desc: 切换系统调度模式为nMode
function ChangeDispatchMode(const nMode: Byte): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessHardware(cBC_ChangeDispatchMode, IntToStr(nMode), '',
            @nOut);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Date: 2016/7/4
//Parm: 开单数据
//Desc: 办理散装长期卡
function SaveBillNew(const nBillData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessSaleBill(cBC_SaveBillNew, nBillData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2016/7/4
//Parm: 单据号
//Desc: 删除长期卡凭证
function DeleteBillNew(const nBill: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_DeleteBillNew, nBill, '', @nOut);
end;

//Date: 2016/7/4
//Parm: 销售订单号
//Desc: 根据销售订单生成交货单
function SaveBillFromNew(const nBill: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessSaleBill(cBC_SaveBillFromNew, nBill, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2016/7/4
//Parm: 单据号;磁卡号
//Desc: 办理散装长期卡
function SaveBillNewCard(const nBill, nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_SaveBillNewCard, nBill, nCard, @nOut);
end;

//Date: 2014-09-15
//Parm: 开单数据
//Desc: 保存交货单,返回交货单号列表
function SaveBill(const nBillData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessSaleBill(cBC_SaveBills, nBillData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2014-09-15
//Parm: 交货单号
//Desc: 删除nBillID单据
function DeleteBill(const nBill: string): Boolean;
var nOut: TWorkerBusinessCommand;
    nIsAdmin: string;
begin
  if gSysParam.FIsAdmin then
       nIsAdmin := sFlag_Yes
  else nIsAdmin := sFlag_No;
  Result := CallBusinessSaleBill(cBC_DeleteBill, nBill, nIsAdmin, @nOut);
end;

//Date: 2014-09-15
//Parm: 交货单;新车牌
//Desc: 修改nBill的车牌为nTruck.
function ChangeLadingTruckNo(const nBill,nTruck: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_ModifyBillTruck, nBill, nTruck, @nOut);
end;

//Date: 2014-09-30
//Parm: 交货单;纸卡
//Desc: 将nBill调拨给nNewZK的客户
function BillSaleAdjust(const nBill, nNewZK: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_SaleAdjust, nBill, nNewZK, @nOut);
end;

//Date: 2014-09-17
//Parm: 交货单;车牌号;校验制卡开关
//Desc: 为nBill交货单制卡
function SetBillCard(const nBill,nTruck: string; nVerify: Boolean;
    nLongFlag: Boolean): Boolean;
var nStr: string;
    nP: TFormCommandParam;
begin
  Result := True;
  if nVerify then
  begin
    nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_ViaBillCard]);

    with FDM.QueryTemp(nStr) do
     if (RecordCount < 1) or (Fields[0].AsString <> sFlag_Yes) then Exit;
    //no need do card
  end;

  nP.FParamA := nBill;
  nP.FParamB := nTruck;
  nP.FParamC := nLongFlag;
  CreateBaseFormItem(cFI_FormMakeCard, '', @nP);
  Result := (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK);
end;

//Date: 2014-09-17
//Parm: 交货单号;磁卡
//Desc: 绑定nBill.nCard
function SaveBillCard(const nBill, nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_SaveBillCard, nBill, nCard, @nOut);
end;

//Date: 2014-09-17
//Parm: 磁卡号
//Desc: 注销nCard
function LogoutBillCard(const nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_LogoffCard, nCard, '', @nOut);
end;

//Date: 2014-09-17
//Parm: 磁卡号;岗位;交货单列表
//Desc: 获取nPost岗位上磁卡为nCard的交货单列表
function GetLadingBills(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
var nStr: string;
    nIdx: Integer;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  SetLength(nBills, 0);
  nStr := GetCardUsed(nCard);

  if (nStr = sFlag_Sale) or (nStr = sFlag_SaleNew) then //销售
  begin
    Result := CallBusinessSaleBill(cBC_GetPostBills, nCard, nPost, @nOut);
  end else

  if nStr = sFlag_Provide then
  begin
    Result := CallBusinessProvideItems(cBC_GetPostBills, nCard, nPost, @nOut);
  end else

  if nStr = sFlag_DuanDao then
  begin
    Result := CallBusinessDuanDao(cBC_GetPostBills, nCard, nPost, @nOut);
  end else

  if nStr = sFlag_ShipPro then
  begin
    Result := CallBusinessShipProItems(cBC_GetPostBills, nCard, nPost, @nOut);
  end else

  if nStr = sFlag_ShipTmp then
  begin
    Result := CallBusinessShipTmpItems(cBC_GetPostBills, nCard, nPost, @nOut);
  end else

  if nStr = sFlag_HaulBack then
  begin
    Result := CallBusinessHaulBackItems(cBC_GetPostBills, nCard, nPost, @nOut);
  end;

  if Result then
    AnalyseBillItems(nOut.FData, nBills);
    //xxxxx

  for nIdx:=Low(nBills) to High(nBills) do
    nBills[nIdx].FCardUse := nStr;
  //xxxxx
end;

//Date: 2014-09-18
//Parm: 岗位;交货单列表;磅站通道
//Desc: 保存nPost岗位上的交货单数据
function SaveLadingBills(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem;const nLogin: Integer): Boolean;
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  if Length(nData) < 1 then Exit;
  nStr := nData[0].FCardUse;

  if (nStr = sFlag_Sale) or (nStr = sFlag_SaleNew) then //销售
  begin
    nStr := CombineBillItmes(nData);
    Result := CallBusinessSaleBill(cBC_SavePostBills, nStr, nPost, @nOut);
    if (not Result) or (nOut.FData = '') then Exit;
  end else

  if nStr = sFlag_Provide then
  begin
    nStr := CombineBillItmes(nData);
    Result := CallBusinessProvideItems(cBC_SavePostBills, nStr, nPost, @nOut);
    if (not Result) or (nOut.FData = '') then Exit;
  end else

  if nStr = sFlag_DuanDao then
  begin
    nStr := CombineBillItmes(nData);
    Result := CallBusinessDuanDao(cBC_SavePostBills, nStr, nPost, @nOut);
	  if (not Result) or (nOut.FData = '') then Exit;
  end else

  if nStr = sFlag_ShipPro then
  begin
    nStr := CombineBillItmes(nData);
    Result := CallBusinessShipProItems(cBC_SavePostBills, nStr, nPost, @nOut);
	  if (not Result) or (nOut.FData = '') then Exit;
  end else

  if nStr = sFlag_ShipTmp then
  begin
    nStr := CombineBillItmes(nData);
    Result := CallBusinessShipTmpItems(cBC_SavePostBills, nStr, nPost, @nOut);
	  if (not Result) or (nOut.FData = '') then Exit;
  end else

  if nStr = sFlag_HaulBack then
  begin
    nStr := CombineBillItmes(nData);
    Result := CallBusinessHaulBackItems(cBC_SavePostBills, nStr, nPost, @nOut);
	  if (not Result) or (nOut.FData = '') then Exit;
  end;

  if Assigned(nTunnel) then //过磅称重
  begin
    nList := TStringList.Create;
    try
      {$IFDEF CapturePictureEx}
      if nLogin < 0 then
        CapturePicture(nTunnel, nList)
      else
        CapturePictureEx(nTunnel, nLogin, nList);
      {$ELSE}
      CapturePicture(nTunnel, nList);
      //capture file
      {$ENDIF}

      for nIdx:=0 to nList.Count - 1 do
        SavePicture(nOut.FData, nData[0].FTruck,
                                nData[0].FStockName, nList[nIdx]);
      //save file
    finally
      nList.Free;
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2014-09-15
//Parm: 开单数据
//Desc: 保存采购单,返回采购单号列表
function SaveOrder(const nOrderData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessProvideItems(cBC_SaveBills, nOrderData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2014-09-15
//Parm: 交货单号
//Desc: 删除nOrder单据
function DeleteOrder(const nOrder: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessProvideItems(cBC_DeleteBill, nOrder, '', @nOut);
end;

//Date: 2014-09-15
//Parm: 交货单号
//Desc: 删除nOrder单据明细
function DeleteOrderDtl(const nOrder: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessProvideItems(cBC_DeleteOrder, nOrder, '', @nOut);
end;

//Date: 2014-09-17
//Parm: 交货单;车牌号;校验制卡开关
//Desc: 为nBill交货单制卡
function SetOrderCard(const nOrder,nTruck: string): Boolean;
var nP: TFormCommandParam;
begin
  nP.FParamA := nOrder;
  nP.FParamB := nTruck;
  CreateBaseFormItem(cFI_FormMakeProvCard, '', @nP);
  Result := (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK);
end;

//Date: 2014-09-17
//Parm: 交货单号;磁卡
//Desc: 绑定nBill.nCard
function SaveOrderCard(const nOrderCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessProvideItems(cBC_SaveBillCard, PackerEncodeStr(nOrderCard), '', @nOut);
end;

//Date: 2014-09-17
//Parm: 磁卡号
//Desc: 注销nCard
function LogoutOrderCard(const nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessProvideItems(cBC_LogOffCard, nCard, '', @nOut);
end;

//------------------------------------------------------------------------------
//保存短倒磁卡
function SaveDuanDaoCard(const nTruck, nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessDuanDao(cBC_SaveBillCard, nTruck, nCard, @nOut);
end;

//注销指定磁卡
function LogoutDuanDaoCard(const nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessDuanDao(cBC_LogOffCard, nCard, '', @nOut);
end;

function SaveTransferInfo(nTruck, nMateID, nMate, nSrcAddr, nDstAddr:string):Boolean;
var nP: TFormCommandParam;
begin
  with nP do
  begin
    FParamA := nTruck;
    FParamB := nMateID;
    FParamC := nMate;
    FParamD := nSrcAddr;
    FParamE := nDstAddr;

    CreateBaseFormItem(cFI_FormTransfer, '', @nP);
    Result  := (FCommand = cCmd_ModalResult) and (FParamA = mrOK);
  end;
end;

//微信
function SaveWeiXinAccount(const nItem:TWeiXinAccount; var nWXID:string): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineWXAccountItem(nItem);
  Result := CallBusinessCommand(cBC_SaveWeixinAccount, nStr, '', @nOut);
  if not Result or (nOut.FData='') then Exit;

  nWXID := nOut.FData;
end;

function DelWeiXinAccount(const nWXID:string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_DelWeixinAccount, nWXID, '', @nOut);
  if not Result or (nOut.FData='') then Exit;
end;


//Date: 2014-09-17
//Parm: 交货单项; MCListBox;分隔符
//Desc: 将nItem载入nMC
procedure LoadBillItemToMC(const nItem: TLadingBillItem; const nMC: TStrings;
 const nDelimiter: string);
var nStr: string;
begin
  with nItem,nMC do
  begin
    Clear;
    Add(Format('车牌号码:%s %s', [nDelimiter, FTruck]));
    Add(Format('当前状态:%s %s', [nDelimiter, TruckStatusToStr(FStatus)]));

    Add(Format('%s ', [nDelimiter]));
    Add(Format('单据编号:%s %s', [nDelimiter, FId]));
    Add(Format('提/供量 :%s %.3f 吨', [nDelimiter, FValue]));
    if FType = sFlag_Dai then nStr := '袋装' else nStr := '散装';

    Add(Format('品种类型:%s %s', [nDelimiter, nStr]));
    Add(Format('品种名称:%s %s', [nDelimiter, FStockName]));

    Add(Format('%s ', [nDelimiter]));
    Add(Format('提货磁卡:%s %s', [nDelimiter, FCard]));
    Add(Format('单据类型:%s %s', [nDelimiter, BillTypeToStr(FIsVIP)]));
    Add(Format('客户名称:%s %s', [nDelimiter, FCusName]));
  end;
end;

//Desc: 打印提货单
function PrintBillReport(nBill: string; const nAsk: Boolean): Boolean;
var nStr, nSort: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '是否要打印提货单?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nSort := GetStockTruckSort(nBill);
  //获取车辆排队顺序

  nBill := AdjustListStrFormat(nBill, '''', True, ',', False);
  //添加引号

  {$IFDEF PrintShipReport}
  nStr := 'Select * From %s b ' +
          '  Left Join %s p on b.L_ID=p.P_Bill ' +
          '  Left Join %s s on s.S_Bill=b.L_ID ' +
          'Where L_ID In(%s)';
  nStr := Format(nStr, [sTable_Bill, sTable_PoundLog, sTable_PoundShip, nBill]);
  {$ELSE}
  nStr := 'Select * From %s b ' +
          '  Left Join %s p on b.L_ID=p.P_Bill ' +
          'Where L_ID In(%s)';
  nStr := Format(nStr, [sTable_Bill, sTable_PoundLog, nBill]);
  {$ENDIF}

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '编号为[ %s ] 的记录已无效!!';
    nStr := Format(nStr, [nBill]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := '';
  {$IFDEF PrintShipReport}
  with FDM.SqlTemp do
  if FieldByName('L_IsVIP').AsString = sFlag_TypeShip then
  begin
    if FieldByName('S_Bill').AsString = '' then
         nStr := gPath + sReportDir + 'ShipReqBill.fr3'
    else nStr := gPath + sReportDir + 'ShipBill.fr3';
    //船运未出厂时打印装船计划单,出厂时打印船运交互单
  end;
  {$ENDIF}

  if nStr = '' then
    nStr := gPath + sReportDir + 'LadingBill.fr3';
  //default
  
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  nParam.FName := 'TruckSort';
  nParam.FValue := nSort;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Date: 2017-07-20
//Parm: 交货单号;询问
//Desc: 打印船运离岸通知单
function PrintShipLeaveReport(nID: string; const nAsk: Boolean): Boolean;
var nStr: string; 
    nParam: TReportParamItem;
    nBills: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  nStr := 'Update %s Set S_LeaveMan=''%s'',S_LeaveDate=%s ' +
          'Where S_Bill=''%s''';
  nStr := Format(nStr, [sTable_PoundShip, gSysParam.FUserID,
          sField_SQLServer_Now, nID]);
  FDM.ExecuteSQL(nStr);

  nStr := 'Select * From %s b ' +
          '  Left Join %s s on s.S_Bill=b.L_ID ' +
          'Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, sTable_PoundShip, nID]);

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '编号为[ %s ] 的提货记录已无效!!';
    nStr := Format(nStr, [nID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  if FDM.SqlTemp.FieldByName('L_OutFact').AsString = '' then
  begin
    if not CallBusinessSaleBill(cBC_GetPostBills, nID, sFlag_TruckOut,
      @nOut) then Exit;
    //读取交货单
    
    AnalyseBillItems(nOut.FData, nBills);
    nBills[0].FCardUse := sFlag_Sale;
    nStr := CombineBillItmes(nBills);

    if not CallBusinessSaleBill(cBC_SavePostBills, nStr, sFlag_TruckOut,
      @nOut) then Exit;
    //自动出厂
  end;

  nStr := gPath + sReportDir + 'ShipLeave.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Date: 2017-09-17
//Parm: 船运单记录号;询问
//Desc: 打印采购离岸通知单
function PrintShipLeaveCGReport(nID: string; const nAsk: Boolean): Boolean;
var nStr: string; 
    nParam: TReportParamItem;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  nStr := 'Select * From %s s ' +
          '  Left Join %s p on p.P_ID=s.S_Bill ' +
          'Where s.S_Bill=''%s''';
  nStr := Format(nStr, [sTable_PoundShip, sTable_PoundLog, nID]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then
    begin
      nStr := '编号为[ %s ] 的船运记录已无效!!';
      nStr := Format(nStr, [nID]);
      ShowMsg(nStr, sHint); Exit;
    end;

    nStr := FieldByName('P_ID').AsString; 
    CallBusinessCommand(cBC_SyncME03, nStr, '', @nOut);
    //自动推送原料单
  end;

  nStr := gPath + sReportDir + 'ShipLeaveCG.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Date: 2018-12-03
//Parm: 采购单RID;提示;数据对象;打印机
//Desc: 打印复磅采购单
function PrintShipProReport(nRID: string; const nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '是否要打印采购单?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s Where R_ID=''%s''';
  nStr := Format(nStr, [sTable_CardProvide, nRID]);

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '编号为[ %s ] 的记录已无效!!';
    nStr := Format(nStr, [nRID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir +'CardProvide.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Date: 2012-4-1
//Parm: 采购单号;提示;数据对象;打印机
//Desc: 打印nOrder采购单号
function PrintOrderReport(nOrder: string; const nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;
  nStr := 'Select * From %s Where D_ID=''%s''';
  nStr := Format(nStr, [sTable_ProvDtl, nOrder]);

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '编号为[ %s ] 的记录已无效!!';
    nStr := Format(nStr, [nOrder]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir +'PurchaseOrder.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Date: 2012-4-15
//Parm: 过磅单号;是否询问
//Desc: 打印nPound过磅记录
function PrintPoundReport(const nPound: string; nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '是否要打印过磅单?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s Where P_ID=''%s''';
  nStr := Format(nStr, [sTable_PoundLog, nPound]);

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '称重记录[ %s ] 已无效!!';
    nStr := Format(nStr, [nPound]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'Pound.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  {$IFDEF ShowReport}
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
  {$ELSE}
  Result := FDR.PrintReport;
  {$ENDIF}

  if Result  then
  begin
    nStr := 'Update %s Set P_PrintNum=P_PrintNum+1 Where P_ID=''%s''';
    nStr := Format(nStr, [sTable_PoundLog, nPound]);
    FDM.ExecuteSQL(nStr);
  end;
end;

//Date: 2015-8-6
//Parm: 过磅单号;是否询问
//Desc: 打印销售nPound过磅记录
function PrintSalePoundReport(const nPound: string; nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '是否要打印过磅单?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s sp ' +
          'left join %s sbill on sp.P_Bill=sbill.L_ID ' + //
          'Where P_ID=''%s''';
  nStr := Format(nStr, [sTable_PoundLog, sTable_Bill, nPound]);

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '称重记录[ %s ] 已无效!!';
    nStr := Format(nStr, [nPound]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'SalePound.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;

  if Result  then
  begin
    nStr := 'Update %s Set P_PrintNum=P_PrintNum+1 Where P_ID=''%s''';
    nStr := Format(nStr, [sTable_PoundLog, nPound]);
    FDM.ExecuteSQL(nStr);
  end;
end;

//Desc: 打印nID对应的短倒单据
function PrintDuanDaoReport(nID: string; const nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '是否要打印短倒业务称重磅单?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s b Where T_ID=''%s''';
  nStr := Format(nStr, [sTable_Transfer, nID]);
  //xxxxx

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '编号为[ %s ] 的记录已无效!!';
    nStr := Format(nStr, [nID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'DuanDao.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Date: 2016/8/7
//Parm: 记录编号
//Desc: 查看抓拍
procedure ShowCapturePicture(const nID: string);
var nStr,nDir: string;
    nPic: TPicture;
begin
  nDir := gSysParam.FPicPath + nID + '\';

  if DirectoryExists(nDir) then
  begin
    ShellExecute(GetDesktopWindow, 'open', PChar(nDir), nil, nil, SW_SHOWNORMAL);
    Exit;
  end else ForceDirectories(nDir);

  nPic := nil;
  nStr := 'Select * From %s Where P_ID=''%s''';
  nStr := Format(nStr, [sTable_Picture, nID]);

  ShowWaitForm('读取图片', True);
  try
    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
      begin
        ShowMsg('本条记录无抓拍', sHint);
        Exit;
      end;

      nPic := TPicture.Create;
      First;

      While not eof do
      begin
        nStr := nDir + Format('%s_%s.jpg', [FieldByName('P_ID').AsString,
                FieldByName('R_ID').AsString]);
        //xxxxx

        FDM.LoadDBImage(FDM.SqlTemp, 'P_Picture', nPic);
        nPic.SaveToFile(nStr);
        Next;
      end;
    end;

    ShellExecute(GetDesktopWindow, 'open', PChar(nDir), nil, nil, SW_SHOWNORMAL);
    //open dir
  finally
    nPic.Free;
    CloseWaitForm;
    FDM.SqlTemp.Close;
  end;
end;

//Date: 2016/8/7
//Parm: 车牌号;时间间隔
//Desc: 查看车辆保存时间
function GetTruckLastTime(const nTruck: string; var nLast: Integer): Boolean;
var nStr: string;
begin
  Result := False;
  nStr := 'Select %s as T_Now,T_LastTime From %s ' +
          'Where T_Truck=''%s''';
  nStr := Format(nStr, [sField_SQLServer_Now, sTable_Truck, nTruck]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nLast := Trunc((FieldByName('T_Now').AsDateTime -
                    FieldByName('T_LastTime').AsDateTime) * 24 * 60 * 60);
    Result := True;                
  end;
end;  

//Date: 2015/1/18
//Parm: 车牌号；电子标签；是否启用；旧电子标签
//Desc: 读标签是否成功；新的电子标签
function SetTruckRFIDCard(nTruck: string; var nRFIDCard: string;
  var nIsUse: string; nOldCard: string=''): Boolean;
var nP: TFormCommandParam;
begin
  nP.FParamA := nTruck;
  nP.FParamB := nOldCard;
  nP.FParamC := nIsUse;
  CreateBaseFormItem(cFI_FormMakeRFIDCard, '', @nP);

  nRFIDCard := nP.FParamB;
  nIsUse    := nP.FParamC;
  Result    := (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK);
end;
//Date: 2015/1/18
//Parm: 装车通道
//Desc: 选择的新通道
function SelectTruckTunnel(var nNewTunnel, nStockNo: string; const nLineGroup: string): Boolean;
var nP: TFormCommandParam;
begin
  nP.FParamA := nNewTunnel;
  nP.FParamB := nStockNo;
  nP.FParamC := nLineGroup;
  CreateBaseFormItem(cFI_FormChangeTunnel, '', @nP);

  nNewTunnel := nP.FParamB;
  Result    := (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK);
end;
//Date: 2015/4/20
//Parm: 皮重;车牌号
//Desc: 获取车牌预置皮重
function GetTruckPValue(var nItem:TPreTruckPItem; const nTruck: string):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetTruckPValue, nTruck, '', @nOut);
  if Result then
   AnalysePreTruckItem(nOut.FData, nItem);
end;

//Date: 2015/4/11
//Parm: 车牌号
//Desc: 车辆是否已进厂
function TruckInFact(nTruck: string):Boolean;
var nStr: string;
begin
  Result := True;
  if nTruck='' then Exit;

  nStr := 'Select P_ID from %s where P_Truck=''%s'' and P_MValue is NULL' +
          ' and P_MDate is NULL and P_PModel<>''%s''';
  nStr := Format(nStr, [sTable_PoundLog, nTruck, sFlag_PoundLS]);
  //xxxxxx

  with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      nStr := '车辆%s已进厂';
      nStr := Format(nStr, [nTruck]);

      ShowDlg(nStr, sHint);
      Exit;
    end;
  //车辆回毛前不能使用

  Result := False;
end;

//Date: 2017/5/13
//Parm: 物料编号
//Desc: 确认是否强制不允许超发
function GetPoundSanWuChaStop(const nStock: string): Boolean;
var nSQL: string;
begin
  Result := False;
  if nStock = '' then Exit;

  nSQL := 'Select * From %s Where D_Name=''%s'' And D_Value=''%s''';
  nSQL := Format(nSQL, [sTable_SysDict, sFlag_PSanWuChaStop, nStock]);
  Result := FDM.QueryTemp(nSQL).RecordCount > 0;
end;  

//Date: 2017/2/28
//Parm: 车厢号[nTruck];过磅数据[nPoundData]
//Desc: 获取火车衡过磅数据
function GetStationPoundItem(const nTruck: string;
 var nPoundData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetStationPoundData, nTruck, '', @nOut);
  if Result then
    AnalyseBillItems(nOut.FData, nPoundData);
  //xxxxx
end;

//Date: 2017/2/28
//Parm: 磅站信息[nTunnel];保存数据[nData];磅单号[nPoundID,Out]
//Desc: 获取火车衡过磅数据
function SaveStationPoundItem(const nTunnel: PPTTunnelItem;
 const nData: TLadingBillItems; var nPoundID: string;const nLogin: Integer): Boolean;
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nPoundID := '';
  nStr := CombineBillItmes(nData);
  Result := CallBusinessCommand(cBC_SaveStationPoundData, nStr, '', @nOut);
  if (not Result) or (nOut.FData = '') then Exit;
  nPoundID := nOut.FData;

  nList := TStringList.Create;
  try
    {$IFDEF CapturePictureEx}
    if nLogin < 0 then
      CapturePicture(nTunnel, nList)
    else
      CapturePictureEx(nTunnel, nLogin, nList);
    {$ELSE}
    CapturePicture(nTunnel, nList);
    //capture file
    {$ENDIF}

    for nIdx:=0 to nList.Count - 1 do
      SavePicture(nOut.FData, nData[0].FTruck,
                              nData[0].FStockName, nList[nIdx]);
    //save file
  finally
    nList.Free;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2014-07-03
//Parm: 通道号
//Desc: 查询nTunnel的光栅状态是否正常
function IsTunnelOK(const nTunnel: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  {$IFNDEF HardMon}
  Result := True;
  Exit;
  {$ENDIF}
  if CallBusinessHardware(cBC_IsTunnelOK, nTunnel, '', @nOut) then
       Result := nOut.FData = sFlag_Yes
  else Result := False;
end;

procedure TunnelOC(const nTunnel: string; const nOpen: Boolean);
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  {$IFNDEF HardMon}
  Exit;
  {$ENDIF}

  if nOpen then
       nStr := sFlag_Yes
  else nStr := sFlag_No;

  CallBusinessHardware(cBC_TunnelOC, nTunnel, nStr, @nOut);
end;

procedure ProberShowTxt(const nTunnel, nText: string);
var nOut: TWorkerBusinessCommand;
begin
  {$IFNDEF HardMon}
  Exit;
  {$ENDIF}
  CallBusinessHardware(cBC_ShowTxt, nTunnel, nText, @nOut);
end;

//Date: 2016-01-06
//Parm: 文本;语音卡;内容
//Desc: 用nCard播发nContent模式的nText文本.
function PlayNetVoice(const nText,nCard,nContent: string): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  {$IFNDEF HardMon}
  Result := True;
  Exit;
  {$ENDIF}
  nStr := 'Card=' + nCard + #13#10 +
          'Content=' + nContent + #13#10 + 'Truck=' + nText;
  //xxxxxx

  Result := CallBusinessHardware(cBC_PlayVoice, nStr, '', @nOut);
  if not Result then
    WriteLog(nOut.FBase.FErrDesc);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Date: 2017/5/12
//Parm: 读卡器编号
//Desc: 打开道闸
function OpenDoorByReader(const nReader: string; nType: string = 'Y'): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessHardware(cBC_OpenDoorByReader, nReader, nType,
            @nOut, False);
end;  

//Date: 2017/6/4
//Parm: 订单数据
//Desc: 复磅采购业务
function SaveCardProvie(const nCardData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessShipProItems(cBC_SaveBills, nCardData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2017/6/4
//Parm: 订单ID
//Desc: 删除复磅采购业务订单
function DeleteCardProvide(const nID: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessShipProItems(cBC_DeleteBill, nID, '', @nOut);
end;

//Date: 2017/6/4
//Parm: 订单数据
//Desc: 复磅临时业务
function SaveCardOther(const nCardData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessShipTmpItems(cBC_SaveBills, nCardData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2017/6/4
//Parm: 订单ID
//Desc: 删除复磅临时业务订单
function DeleteCardOther(const nID: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessShipTmpItems(cBC_DeleteBill, nID, '', @nOut);
end;

//Date: 2017/6/20
//Parm: 无
//Desc: 保存回空业务单据信息
function SaveBillHaulBack(const nCardData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessHaulBackItems(cBC_SaveBills, nCardData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2017/6/20
//Parm: 无
//Desc: 删除回空业务单据信息
function DeleteBillHaulBack(const nID: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessHaulBackItems(cBC_DeleteBill, nID, '', @nOut);
end;

//获取客户注册信息
function WebChatGetCustomerInfo: string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_WebChat_getCustomerInfo, '', '', @nOut) then
    Result := nOut.FData;
end;

function WebChatEditShopCustom(const nData: string; nSale: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_WebChat_EditShopCustom,
            PackerEncodeStr(nData), nSale, @nOut);
end;

//Date: 2016/11/27
//Parm: 参数描述
//Desc: 添加异常事件处理
function AddManualEventRecord(nEID, nKey, nEvent:string;
    nFrom: string; nSolution: string; nDepartmen: string;
    nReset: Boolean; nMemo: string): Boolean;
var nSQL, nStr: string;
    nUpdate: Boolean;
begin
  Result := False;
  //init

  if Trim(nSolution) = '' then
  begin
    WriteLog('请选择处理方案.');
    Exit;
  end;

  nSQL := 'Select * From %s Where E_ID=''%s''';
  nSQL := Format(nSQL, [sTable_ManualEvent, nEID]);
  with FDM.QuerySQL(nSQL) do
  if RecordCount > 0 then
  begin
    nStr := '事件记录:[ %s ]已存在';
    nStr := Format(nStr, [nEID]);
    WriteLog(nStr);

    if not nReset then Exit;

    nUpdate := True;
  end else nUpdate := False;

  nStr := SF('E_ID', nEID);
  nSQL := MakeSQLByStr([
          SF('E_ID', nEID),
          SF('E_Key', nKey),
          SF('E_Result', 'NULL', sfVal),
          SF('E_From', nFrom),
          SF('E_Memo', nMemo),
          
          SF('E_Event', nEvent), 
          SF('E_Solution', nSolution),
          SF('E_Departmen', nDepartmen),
          SF('E_Date', sField_SQLServer_Now, sfVal)
          ], sTable_ManualEvent, nStr, (not nUpdate));
  FDM.ExecuteSQL(nSQL);
end;

//Date: 2016/11/27
//Parm: 事件ID;预期结果;错误返回
//Desc: 判断事件是否处理
function VerifyManualEventRecord(const nEID: string; var nHint: string;
    const nWant: string; const nUpdateHint: Boolean): Boolean;
var nSQL, nStr: string;
begin
  Result := False;
  //init

  nSQL := 'Select E_Result, E_Event, E_ParamB  From %s Where E_ID=''%s''';
  nSQL := Format(nSQL, [sTable_ManualEvent, nEID]);

  with FDM.QuerySQL(nSQL) do
  if RecordCount > 0 then
  begin
    nStr := Trim(FieldByName('E_Result').AsString);
    if nStr = '' then
    begin
      if nUpdateHint then
        nHint := FieldByName('E_Event').AsString;
      Exit;
    end;

    if nStr <> nWant then
    begin
      if nUpdateHint then
        nHint := '请联系管理员，做换票处理';
      Exit;
    end;

    if nUpdateHint then
      nHint  := FieldByName('E_ParamB').AsString;
    Result := True;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2017/4/1
//Parm: 待处理事件ID;处理结果
//Desc: 处理待处理时间信息
function DealManualEvent(const nEID, nResult: string; nMemo: string): Boolean;
var nP: TFormCommandParam;
begin
  Result := True;

  if (Copy(nEID, Length(nEID), 1) = sFlag_ManualB) and (nResult = sFlag_SHaulback) then
  begin //皮重预警,回空业务处理
    nP.FCommand := cCmd_AddData;
    nP.FParamA  := Copy(nEID, 1, Length(nEID)-1);
    nP.FParamB  := nMemo;

    CreateBaseFormItem(cFI_FormBillHaulback, '', @nP);
    Result := nP.FCommand = cCmd_ModalResult; 
  end;
end;

//Desc: 车辆有效皮重
function GetTruckEmptyValue(nTruck, nType: string): Double;
var nStr: string;
begin
//  Result := 0;
//
//  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo=''%s'' ' +
//          ' and D_ParamB=''%s''' ;
//  nStr := Format(nStr, [sTable_SysDict, sFlag_PoundWuCha,
//                                        sFlag_ForceVPoundP,
//                                        nType]);
//
//  with FDM.QueryTemp(nStr) do
//  begin
//    if RecordCount <= 0 then
//      Exit;
//    if Fields[0].AsString <> sFlag_Yes then
//      Exit;
//  end;

  nStr := 'Select T_PValue From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, nTruck]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[0].AsFloat
  else Result := 0;
end;

//Desc: 读取栈台分组列表到nList中,包含附加数据
function LoadZTLineGroup(const nList: TStrings; const nWhere: string = ''): Boolean;
var nStr,nW: string;
begin
  if nWhere = '' then
       nW := ''
  else nW := Format(' And (%s)', [nWhere]);

  nStr := 'D_Value=Select D_Value,D_Memo,D_ParamB From %s ' +
          'Where D_Name=''%s'' %s Order By D_ID';
  nStr := Format(nStr, [sTable_SysDict, sFlag_ZTLineGroup, nW]);

  AdjustStringsItem(nList, True);
  FDM.FillStringsData(nList, nStr, -1, '.', DSA(['D_Value']));

  AdjustStringsItem(nList, False);
  Result := nList.Count > 0;
end;

//Desc: 读取可用地磅列表到nList中,包含附加数据
function LoadPoundStation(const nList: TStrings; const nWhere: string = ''): Boolean;
var nStr,nW: string;
begin
  if nWhere = '' then
       nW := ''
  else nW := Format(' And (%s)', [nWhere]);

  nStr := 'D_Value=Select D_Value,D_Memo From %s ' +
          'Where D_Name=''%s'' %s Order By D_ID';
  nStr := Format(nStr, [sTable_SysDict, sFlag_PoundStation, nW]);

  AdjustStringsItem(nList, True);
  FDM.FillStringsData(nList, nStr, -1, '.', DSA(['D_Value']));

  AdjustStringsItem(nList, False);
  Result := nList.Count > 0;
end;

//Desc: 读取可用地磅物料列表到nList中,包含附加数据
function LoadPoundStock(const nList: TStrings; const nWhere: string = ''): Boolean;
var nStr,nW: string;
begin
  if nWhere = '' then
       nW := ''
  else nW := Format(' And (%s)', [nWhere]);

  nStr := 'M_ID=Select M_ID,M_Name From %s ' +
          'Where 1=1 %s Order By R_ID';
  nStr := Format(nStr, [sTable_Materails, nW]);

  AdjustStringsItem(nList, True);
  FDM.FillStringsData(nList, nStr, -1, '.', DSA(['M_ID']));

  AdjustStringsItem(nList, False);
  Result := nList.Count > 0;
end;

//Desc: 读取通道列表到nList中,包含附加数据
function LoadLine(const nList: TStrings; const nWhere: string = ''): Boolean;
var nStr,nW: string;
begin
  if nWhere = '' then
       nW := ''
  else nW := Format(' And (%s)', [nWhere]);

  nStr := 'Z_ID=Select Z_ID,Z_Name From %s ' +
          'Where 1=1 %s Order By R_ID';
  nStr := Format(nStr, [sTable_ZTLines, nW]);

  AdjustStringsItem(nList, True);
  FDM.FillStringsData(nList, nStr, -1, '.', DSA(['M_ID']));

  AdjustStringsItem(nList, False);
  Result := nList.Count > 0;
end;

//Date: 2017/7/10
//Parm: 销售提货单号
//Desc: 获取销售提货单号的排队顺序
function GetStockTruckSort(nID: string=''): string;
var nStr, nVip, nStock, nPoundQueue: string;
    nDate: TDateTime;
begin
  Result := '';
  if nID = '' then Exit;

  nStr := 'Select * From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, nID]);
  with FDM.QuerySQL(nStr) do
  begin
    if RecordCount < 1 then Exit;
    //交货单已无效

    if FieldByName('L_OutFact').AsString <> '' then Exit;
    //交货单已完成

    nStock := FieldByName('L_StockNO').AsString;
    nDate  := FieldByName('L_Date').AsDateTime;
    nVip   := FieldByName('L_IsVip').AsString;
  end;

  nStr := 'Select D_Value From $DT Where D_Memo = ''$PQ''';
  nStr := MacroValue(nStr, [MI('$DT', sTable_SysDict),
          MI('$PQ', sFlag_PoundQueue)]);

  with FDM.QuerySQL(nStr) do
  begin
    if FieldByName('D_Value').AsString = 'Y' then
    nPoundQueue := 'Y';
  end;

  nStr := 'Select D_Value From $DT Where D_Memo = ''$DQ''';
  nStr := MacroValue(nStr, [MI('$DT', sTable_SysDict),
          MI('$DQ', sFlag_DelayQueue)]);

  with FDM.QuerySQL(nStr) do
  begin
  if  FieldByName('D_Value').AsString = 'Y' then
    begin
      if nPoundQueue <> 'Y' then
      begin
        nStr := 'Select Count(*) From $TB Where T_InQueue Is Null And ' +
                'T_Valid=''$Yes'' And T_StockNo=''$SN'' And T_InFact<''$IT'' And T_Vip=''$VIP''';
      end else
      begin
        nStr := ' Select Count(*) From $TB left join Sys_PoundLog on Sys_PoundLog.P_Bill=S_ZTTrucks.T_Bill ' +
                ' Where T_InQueue Is Null And ' +
                ' T_Valid=''$Yes'' And T_StockNo=''$SN'' And P_PDate<''$IT'' And T_Vip=''$VIP''';
      end;
    end else
    begin
      nStr := 'Select Count(*) From $TB Where T_InQueue Is Null And ' +
              'T_Valid=''$Yes'' And T_StockNo=''$SN'' And T_InTime<''$IT'' And T_Vip=''$VIP''';
    end;

    nStr := MacroValue(nStr, [MI('$TB', sTable_ZTTrucks),
          MI('$Yes', sFlag_Yes), MI('$SN', nStock),
          MI('$IT', DateTime2Str(nDate)),MI('$VIP', nVip)]);
  end;
  //xxxxx

  with FDM.QuerySQL(nStr) do
  begin
    if Fields[0].AsInteger < 1 then
    begin
      nStr := '当前还有【 0 】辆车排队,请关注大屏.';
      Result := nStr;
    end else
    begin
      nStr := '当前还有【 %d 】辆车等待进厂';
      Result := Format(nStr, [Fields[0].AsInteger]);
    end;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 获取nStock品种的报表文件
function GetReportFileByStock(const nStock, nBrand: string): string;
begin
  Result := GetPinYinOfStr(nStock);

  {$IFDEF GetReportByBrand}
  if nBrand = '' then
  begin
    if Pos('dj', Result) > 0 then
      Result := gPath + 'Report\HuaYan42_DJ.fr3'
    else if Pos('gsysl', Result) > 0 then
      Result := gPath + 'Report\HuaYan_gsl.fr3'
    else if Pos('kzf', Result) > 0 then
      Result := gPath + 'Report\HuaYan_kzf.fr3'
    else if Pos('qz', Result) > 0 then
      Result := gPath + 'Report\HuaYan_qz.fr3'
    else if Pos('32', Result) > 0 then
      Result := gPath + 'Report\HuaYan32.fr3'
    else if Pos('42', Result) > 0 then
      Result := gPath + 'Report\HuaYan42.fr3'
    else if Pos('52', Result) > 0 then
      Result := gPath + 'Report\HuaYan42.fr3'
    else Result := '';
  end
  else
  begin
    if Pos('dj', Result) > 0 then
      Result := gPath + 'Report\HuaYan42_DJ' + nBrand +'.fr3'
    else if Pos('gsysl', Result) > 0 then
      Result := gPath + 'Report\HuaYan_gsl' + nBrand +'.fr3'
    else if Pos('kzf', Result) > 0 then
      Result := gPath + 'Report\HuaYan_kzf' + nBrand +'.fr3'
    else if Pos('qz', Result) > 0 then
      Result := gPath + 'Report\HuaYan_qz' + nBrand +'.fr3'
    else if Pos('32', Result) > 0 then
      Result := gPath + 'Report\HuaYan32' + nBrand +'.fr3'
    else if Pos('42', Result) > 0 then
      Result := gPath + 'Report\HuaYan42' + nBrand +'.fr3'
    else if Pos('52', Result) > 0 then
      Result := gPath + 'Report\HuaYan42' + nBrand +'.fr3'
    else Result := '';
  end;
  {$ELSE}
  if Pos('dj', Result) > 0 then
    Result := gPath + 'Report\HuaYan42_DJ.fr3'
  else if Pos('gsysl', Result) > 0 then
    Result := gPath + 'Report\HuaYan_gsl.fr3'
  else if Pos('kzf', Result) > 0 then
    Result := gPath + 'Report\HuaYan_kzf.fr3'
  else if Pos('qz', Result) > 0 then
    Result := gPath + 'Report\HuaYan_qz.fr3'
  else if Pos('32', Result) > 0 then
    Result := gPath + 'Report\HuaYan32.fr3'
  else if Pos('42', Result) > 0 then
    Result := gPath + 'Report\HuaYan42.fr3'
  else if Pos('52', Result) > 0 then
    Result := gPath + 'Report\HuaYan42.fr3'
  else Result := '';
  {$ENDIF}
end;

//Desc: 打印标识为nHID的化验单
function PrintHuaYanReport(const nHID: string; const nAsk: Boolean): Boolean;
var nStr,nSeal,nDate3D,nDate28D,n28Ya1,nBD,nLID,nBrand: string;
    nDate: TDateTime;
begin
  if nAsk then
  begin
    Result := True;
    nStr := '是否要打印化验单?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end else Result := False;

  nSeal := '';
  nBD := '';
  nLID := '';
  nStr := 'Select hy.H_SerialNo,sr.R_28Ya1,b.L_HyPrintCount,b.L_ID,b.L_StockBrand From %s hy ' +
          ' Left Join %s b On b.L_ID=hy.H_Bill ' +
          ' Left Join %s sr on sr.R_SerialNo=hy.H_SerialNo ' +
          ' Where hy.H_ID = ''%s''';
  nStr := Format(nStr, [sTable_StockHuaYan, sTable_Bill, sTable_StockRecord, nHID]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nSeal := Fields[0].AsString;
      n28Ya1 := Fields[1].AsString;
      nLID := Fields[3].AsString;
      nBrand := Fields[4].AsString;
      if Fields[2].AsInteger >= 1 then
        nBD := '补';
    end;
  end;

  nDate3D := FormatDateTime('YYYY-MM-DD HH:MM:SS', Now);
  nDate28D := nDate3D;
  if nSeal <> '' then
  begin
    nStr := 'Select top 1 L_Date From %s Where L_Seal = ''%s'' order by L_Date';
    nStr := Format(nStr, [sTable_Bill, nSeal]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount > 0 then
      begin
        nDate3D := Fields[0].AsString;

        try
          nDate := StrToDateTime(nDate3D);
          if n28Ya1 <> '' then
            nDate := IncDay(nDate,29);
          nDate28D := FormatDateTime('YYYY-MM-DD HH:MM:SS', nDate);
        except
        end;
      end;
    end;
  end;

  nStr := 'Select hy.*,b.*,sp.*,sr.*,''$DD'' as R_Date3D,''$BD'' as L_HyBd,''$TD'' as R_Date28D From $HY hy ' +
          ' Left Join $Bill b On b.L_ID=hy.H_Bill ' +
          ' Left Join $SR sr on sr.R_SerialNo=H_SerialNo ' +
          ' Left Join $SP sp on sp.P_ID=sr.R_PID ' +
          'Where H_ID in ($ID)';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$DD', nDate3D), MI('$BD', nBD), MI('$TD', nDate28D),
          MI('$HY', sTable_StockHuaYan),
          MI('$Bill', sTable_Bill), MI('$SP', sTable_StockParam),
          MI('$SR', sTable_StockRecord), MI('$ID', nHID)]);
  //xxxxx

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '编号为[ %s ] 的化验单记录已无效!!';
    nStr := Format(nStr, [nHID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := FDM.SqlTemp.FieldByName('P_Stock').AsString;
  nStr := GetReportFileByStock(nStr, nBrand);

  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  if gSysParam.FPrinterHYDan = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_HYPrinter'
  else FDR.Report1.PrintOptions.Printer := gSysParam.FPrinterHYDan;

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;

  if Result then
  begin
    nStr := 'Update %s Set L_HyPrintCount=L_HyPrintCount + 1 ' +
            'Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, nLID]);
    FDM.ExecuteSQL(nStr);
  end;
end;

//Desc: 打印标识为nHID的化验单
function PrintHuaYanReportEx(const nHID, nSeal: string; const nAsk: Boolean): Boolean;
var nStr,nDate3D,nDate28D,n28Ya1,nBD,nLID,nBrand: string;
    nDate: TDateTime;
begin
  if nAsk then
  begin
    Result := True;
    nStr := '是否要打印化验单?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end else Result := False;

  nBD := '';
  nLID := '';
  nStr := 'Select hy.H_SerialNo,sr.R_28Ya1,b.L_HyPrintCount,b.L_ID,b.L_StockBrand From %s hy ' +
          ' Left Join %s b On b.L_ID=hy.H_Bill ' +
          ' Left Join %s sr on sr.R_SerialNo=''%s'' ' +
          ' Where hy.H_ID = ''%s''';
  nStr := Format(nStr, [sTable_StockHuaYan, sTable_Bill, sTable_StockRecord, nSeal, nHID]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      n28Ya1 := Fields[1].AsString;
      nLID := Fields[3].AsString;
      nBrand := Fields[4].AsString;
      if Fields[2].AsInteger >= 1 then
        nBD := '补';
    end;
  end;

  nDate3D := FormatDateTime('YYYY-MM-DD HH:MM:SS', Now);
  nDate28D := nDate3D;
  if nSeal <> '' then
  begin
    nStr := 'Select top 1 L_Date From %s Where L_Seal = ''%s'' order by L_Date';
    nStr := Format(nStr, [sTable_Bill, nSeal]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount > 0 then
      begin
        nDate3D := Fields[0].AsString;

        try
          nDate := StrToDateTime(nDate3D);
          if n28Ya1 <> '' then
            nDate := IncDay(nDate,29);
          nDate28D := FormatDateTime('YYYY-MM-DD HH:MM:SS', nDate);
        except
        end;
      end;
    end;
  end;

  nStr := 'Select hy.*,b.*,sp.*,sr.*,''$DD'' as R_Date3D,''$BD'' as L_HyBd,''$TD'' as R_Date28D From $HY hy ' +
          ' Left Join $Bill b On b.L_ID=hy.H_Bill ' +
          ' Left Join $SR sr on sr.R_SerialNo=''$SE'' ' +
          ' Left Join $SP sp on sp.P_ID=sr.R_PID ' +
          'Where H_ID in ($ID)';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$DD', nDate3D), MI('$BD', nBD), MI('$TD', nDate28D),
          MI('$HY', sTable_StockHuaYan), MI('$SE', nSeal),
          MI('$Bill', sTable_Bill), MI('$SP', sTable_StockParam),
          MI('$SR', sTable_StockRecord), MI('$ID', nHID)]);
  //xxxxx

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '编号为[ %s ] 的化验单记录已无效!!';
    nStr := Format(nStr, [nHID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := FDM.SqlTemp.FieldByName('P_Stock').AsString;
  nStr := GetReportFileByStock(nStr, nBrand);

  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  if gSysParam.FPrinterHYDan = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_HYPrinter'
  else FDR.Report1.PrintOptions.Printer := gSysParam.FPrinterHYDan;

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;

  if Result then
  begin
    nStr := 'Update %s Set L_HyPrintCount=L_HyPrintCount + 1 ' +
            'Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, nLID]);
    FDM.ExecuteSQL(nStr);
  end;
end;

//Desc: 打印标识为nID的合格证
function PrintHeGeReport(const nHID: string; const nAsk: Boolean): Boolean;
var nStr,nSeal,nDate3D: string;
begin
  if nAsk then
  begin
    Result := True;
    nStr := '是否要打印合格证?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end else Result := False;

  nSeal := '';
  nStr := 'Select hy.H_SerialNo,sr.R_28Ya1 From %s hy ' +
          ' Left Join %s sr on sr.R_SerialNo=hy.H_SerialNo ' +
          ' Where hy.H_ID = ''%s''';
  nStr := Format(nStr, [sTable_StockHuaYan, sTable_StockRecord, nHID]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nSeal := Fields[0].AsString;
    end;
  end;
  nDate3D := FormatDateTime('YYYY-MM-DD HH:MM:SS', Now);
  if nSeal <> '' then
  begin
    nStr := 'Select top 1 L_Date From %s Where L_Seal = ''%s'' order by L_Date';
    nStr := Format(nStr, [sTable_Bill, nSeal]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount > 0 then
      begin
        nDate3D := Fields[0].AsString;
      end;
    end;
  end;

  nStr := 'Select *,''$DD'' as R_Date3D From $HY hy ' +
          '  Left Join $Bill b On b.L_ID=hy.H_Bill ' +
          '  Left Join $SP sp On sp.P_Stock=b.L_StockName ' +
          'Where H_ID in ($ID)';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$DD', nDate3D),MI('$HY', sTable_StockHuaYan),
          MI('$SP', sTable_StockParam), MI('$SR', sTable_StockRecord),
          MI('$Bill', sTable_Bill), MI('$ID', nHID)]);
  //xxxxx

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '编号为[ %s ] 的化验单记录已无效!!';
    nStr := Format(nStr, [nHID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'HeGeZheng.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  if gSysParam.FPrinterHYDan = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_HYPrinter'
  else FDR.Report1.PrintOptions.Printer := gSysParam.FPrinterHYDan;

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Date: 2018-07-10
//Parm: 销售订单号
//Desc: 查询此订单是否可以开卡
function IsOrderCanLade(nOrderID: string): Boolean;
var nStr: string;
begin
  Result := True;
  nStr := 'Select L_ID From %s Where L_ZhiKa in (''%s'')';
  nStr := nStr + ' And (L_OutFact is null or L_Status <> ''%s'') ';
  nStr := Format(nStr, [sTable_Bill, nOrderID, sFlag_TruckOut]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount >0 then
    begin
      WriteLog('销售订单验证Sql:'+ nStr);
      Result := False;
    end;
  end;
end;

//Desc: 生成销售特定字段数据(特定使用)
function MakeSaleViewData(nID: string; nMValue: Double): Boolean;
var nStr: string;
    nList : TStrings;
    nIdx: Integer;
begin
  Result := False;
  nList := TStringList.Create;
  try
    nStr := 'Update %s Set L_MValueview = %.2f Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, nMValue, nID]);
    nList.Add(nStr);

    nStr := 'Update %s Set L_Valueview = L_MValueView - L_PValue Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, nID]);
    nList.Add(nStr);

    nStr := 'Update a set a.P_MValueView = b.L_MValueView,'+
            ' a.P_ValueView = b.L_ValueView from %s a, %s b'+
            ' where  a.P_Bill = b.L_ID and b.L_ID=''%s''';
    nStr := Format(nStr, [sTable_PoundLog, sTable_Bill, nID]);
    nList.Add(nStr);

    FDM.ADOConn.BeginTrans;
    try
      for nIdx:=0 to nList.Count - 1 do
      begin
        FDM.ExecuteSQL(nList[nIdx]);
      end;
      FDM.ADOConn.CommitTrans;
    except
      On E: Exception do
      begin
        Result := False;
        FDM.ADOConn.RollbackTrans;
        WriteLog(E.Message);
      end;
    end;
    Result := True;
  finally
    nList.Free;
  end;
end;

//Desc: 特定字段初始化(特定使用)
function InitViewData: Boolean;
var nID: string;
    nStr: string;
    nList : TStrings;
    nIdx: Integer;
begin
  nList := TStringList.Create;
  try
    nStr := 'Select top 10000 L_ID , L_MValue From %s ' +
            'Where L_MValueView is null';
    nStr := Format(nStr, [sTable_Bill]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nID := Fields[0].AsString;

        if Fields[1].AsString = '' then
        begin
          Next;
          Continue;
        end;

        nStr := 'Update %s Set L_MValueview = L_MValue Where L_ID=''%s''';
        nStr := Format(nStr, [sTable_Bill, nID]);
        nList.Add(nStr);

        nStr := 'Update %s Set L_Valueview = L_Value Where L_ID=''%s''';
        nStr := Format(nStr, [sTable_Bill, nID]);
        nList.Add(nStr);

        nStr := 'Update a set a.P_MValueView = b.L_MValueView,'+
                ' a.P_ValueView = b.L_ValueView from %s a, %s b'+
                ' where  a.P_Bill = b.L_ID and b.L_ID=''%s''';
        nStr := Format(nStr, [sTable_PoundLog, sTable_Bill, nID]);
        nList.Add(nStr);

        Next;
      end;
    end;

    nStr := 'Update %s set P_MValueView = P_MValue,'+
            ' P_ValueView = P_MValue - P_PValue where P_MValueView is Null'+
            ' and P_MValue is not null and P_PValue is not null ';
    nStr := Format(nStr, [sTable_PoundLog]);
    nList.Add(nStr);

    FDM.ADOConn.BeginTrans;
    try
      for nIdx:=0 to nList.Count - 1 do
      begin
        FDM.ExecuteSQL(nList[nIdx]);
      end;
      FDM.ADOConn.CommitTrans;
    except
      On E: Exception do
      begin
        Result := False;
        FDM.ADOConn.RollbackTrans;
        WriteLog(E.Message);
      end;
    end;
  finally
    nList.Free;
  end;
end;

function GetStockType(nBill: string):string;
var nStr, nStockMap: string;
begin
  {$IFDEF StockTypeByPackStyle}
  Result := '普通';
  nStr := 'Select L_PackStyle From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, nBill]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nStr := Trim(Fields[0].AsString);
    if nStr = 'Z' then Result := '纸袋';
    if nStr = 'R' then Result := '早强';
  end;

  Exit;
  {$ENDIF}

  Result := 'C';
  nStr := 'Select L_PackStyle, L_StockBrand, L_StockNO From %s ' +
          'Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, nBill]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    Result := UpperCase(GetPinYinOfStr(Fields[0].AsString + Fields[1].AsString));
    nStockMap := Fields[2].AsString + Fields[0].AsString + Fields[1].AsString;

    nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_StockBrandShow, nStockMap]);
    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      Result := Fields[0].AsString;
    end;
  end;

  Result := Copy(Result, 1, 2);
end;

//Date: 2018/07/31
//Parm: 车牌号
//Desc: 火车衡自动获取最近5条历史皮重
function IsStationAutoP(const nTruck: string; var nPValue: Double;
                        nMsg: string): Boolean;
var nSQL, nStr: string;
    nCount, nPos: Integer;
begin
  Result := False;
  nPValue := 0;
  nMsg := '';
  if nTruck = '' then Exit;

  nSQL := 'Select D_Value From %s Where D_Name=''%s''';
  nSQL := Format(nSQL, [sTable_SysDict, sFlag_StationAutoP]);

  with FDM.QueryTemp(nSQL) do
  begin
    if RecordCount > 0 then
    begin
      Result := Fields[0].AsString = sFlag_Yes;
    end;
  end;

  if Result then
  begin
    nSQL := 'Select top 5 P_PValue From %s ' +
        'Where P_Truck=''%s'' And P_PValue Is Not Null order by P_PDate desc';
    nSQL := Format(nSQL, [sTable_PoundStation, nTruck]);

    with FDM.QueryTemp(nSQL) do
    begin
      if RecordCount > 0 then
      begin
        First;

        nCount := 0;
        while not Eof do
        begin
          nPValue := nPValue + Fields[0].AsFloat;
          nMsg := nMsg + Fields[0].AsString + ',';
          Inc(nCount);
          Next;
        end;
        nPValue := nPValue / nCount;
        nPValue := Float2PInt(nPValue, cPrecision, False) / cPrecision;

        try
          nStr := Format('%.2f',[nPValue]);
          nPos := StrToInt(Copy(nStr,Length(nStr),1));
          if nPos mod 2 = 1 then
          begin
            nPValue := Float2PInt(StrToFloat(nStr) + 0.01, cPrecision, False) / cPrecision;
          end;
        except
        end;
        nMsg := '共查询到' + IntToStr(nCount) + '个历史皮重:'
                + nMsg + '平均值:' + FloatToStr(nPValue);
        WriteLog('火车衡:'+ nTruck + nMsg);
      end
      else
        Result := False;
    end;
  end;
end;

//Date: 2018/08/30
//Parm: 车牌号
//Desc: 火车衡自动获取最近一次过磅物料
function GetStationTruckStock(const nTruck: string; var nStockNo,
                        nStockName: string): Boolean;
var nSQL, nStr: string;
    nCount, nPos: Integer;
begin
  Result := False;
  nStockNo:= '';
  nStockName := '';
  if nTruck = '' then Exit;

  nSQL := 'Select top 1 P_MID, P_MName From %s Where P_Truck=''%s'' Order by R_ID desc';
  nSQL := Format(nSQL, [sTable_PoundStation, nTruck]);

  with FDM.QueryTemp(nSQL) do
  begin
    if RecordCount > 0 then
    begin
      nStockNo := Fields[0].AsString;
      nStockName := Fields[1].AsString;
      Result := True;
    end;
  end;
end;

function VerifySnapTruck(const nReader: string; nBill: TLadingBillItem;
                         var nMsg, nPos: string): Boolean;
var nStr, nDept: string;
    nNeedManu, nUpdate, nST, nSuccess, nSaveALL: Boolean;
    nSnapTruck, nTruck, nEvent, nPicName: string;
    nLen: Integer;
begin
  Result := False;
  nPos := '';
  nNeedManu := False;
  nSnapTruck := '';
  nDept := '';
  nMsg := '';
  nLen := 0;
  nSuccess := False;
  nSaveALL := False;
  nTruck := nBill.Ftruck;

  nPos := ReadPoundReaderInfo(nReader,nDept);

  if nPos = '' then
  begin
    Result := True;
    nStr := '读卡器[ %s ]绑定岗位为空,无法进行抓拍识别.';
    nStr := Format(nStr, [nReader]);
    WriteLog(nStr);
    Exit;
  end;

  nST := True;

  nStr := 'Select T_SnapTruck From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, nTruck]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nST := FieldByName('T_SnapTruck').AsString = sFlag_Yes;
    end;
  end;

  if not nST then
  begin
    Result := True;
    nMsg := '车辆[ %s ]无需进行车牌识别';
    nMsg := Format(nMsg, [nTruck]);
    Exit;
  end;

  nStr := 'Select D_Value,D_Index,D_ParamB From %s Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_TruckInNeedManu,nPos]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nNeedManu := FieldByName('D_Value').AsString = sFlag_Yes;
      nLen := FieldByName('D_Index').AsInteger;
      nSaveALL := FieldByName('D_ParamB').AsString = sFlag_Yes;
      if nNeedManu then
      begin
        nStr := '读卡器[ %s ]绑定岗位[ %s ]干预规则:人工干预已启用.';
        nStr := Format(nStr, [nReader, nPos]);
        WriteLog(nStr);
      end
      else
      begin
        nStr := '读卡器[ %s ]绑定岗位[ %s ]干预规则:人工干预已关闭.';
        nStr := Format(nStr, [nReader, nPos]);
        WriteLog(nStr);
        Result := True;
      end;
    end
    else
    begin
      Result := True;
      nStr := '读卡器[ %s ]绑定岗位[ %s ]未配置干预规则,无法进行抓拍识别.';
      nStr := Format(nStr, [nReader, nPos]);
      WriteLog(nStr);
      Exit;
    end;
  end;

  if not nNeedManu then//不干预 校验识别记录并保存用以统计失败率
  begin
    nStr := 'Select * From %s order by R_ID desc ';
    nStr := Format(nStr, [sTable_SnapTruck]);
    //xxxxx

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
      begin
        Exit;
      end;

      nPicName := '';

      First;

      while not Eof do
      begin
        nSnapTruck := FieldByName('S_Truck').AsString;
        if nPicName = '' then//默认取最新一次抓拍
          nPicName := FieldByName('S_PicName').AsString;
        if Pos(nTruck,nSnapTruck) > 0 then
        begin
          nSuccess := True;
          nPicName := FieldByName('S_PicName').AsString;
          //取得匹配成功的图片路径
          nMsg := '车辆[ %s ]车牌识别成功,抓拍车牌号:[ %s ]';
          nMsg := Format(nMsg, [nTruck,nSnapTruck]);
        end
        else
        if nLen > 0 then//模糊匹配
        begin
          if RightStr(nTruck,nLen) = RightStr(nSnapTruck,nLen) then
          begin
            nSuccess := True;
            nPicName := FieldByName('S_PicName').AsString;
            //取得匹配成功的图片路径
            nMsg := '车辆[ %s ]车牌识别成功,抓拍车牌号:[ %s ]';
            nMsg := Format(nMsg, [nTruck,nTruck]);
          end;
          //车牌识别成功
        end;

        if nSuccess then
          Break;
        Next;
      end;
    end;

    if nSuccess then
    begin
      if nSaveALL then
      begin
        nStr := 'Select * From %s Where E_ID=''%s'' and E_From=''%s''';
        nStr := Format(nStr, [sTable_ManualEvent, nBill.FID+sFlag_ManualE, nPos]);

        with FDM.QueryTemp(nStr) do
        begin
          if RecordCount > 0 then
          begin
            nUpdate := True;
          end
          else
          begin
            nUpdate := False;
          end;
        end;

        nEvent := nMsg;

        nStr := SF('E_ID', nBill.FID+sFlag_ManualE);
        nStr := MakeSQLByStr([
                SF('E_ID', nBill.FID+sFlag_ManualE),
                SF('E_Key', nPicName),
                SF('E_From', nPos),
                SF('E_Result', 'O'),

                SF('E_Event', nEvent),
                SF('E_Solution', sFlag_Solution_OK),
                SF('E_Departmen', nDept),
                SF('E_Date', sField_SQLServer_Now, sfVal)
                ], sTable_ManualEvent, nStr, (not nUpdate));
        //xxxxx
        FDM.ExecuteSQL(nStr);
      end;
    end
    else
    begin
      nStr := 'Select * From %s Where E_ID=''%s''';
      nStr := Format(nStr, [sTable_ManualEvent, nBill.FID+sFlag_ManualE]);

      with FDM.QueryTemp(nStr) do
      begin
        if RecordCount > 0 then
        begin
          nUpdate := True;
        end
        else
        begin
          nUpdate := False;
        end;
      end;

      nEvent := '车辆[ %s ]车牌识别失败,请移动车辆并在夜间关闭车灯';
      nEvent := Format(nEvent, [nTruck]);

      nStr := SF('E_ID', nBill.FID+sFlag_ManualE);
      nStr := MakeSQLByStr([
              SF('E_ID', nBill.FID+sFlag_ManualE),
              SF('E_Key', nPicName),
              SF('E_From', nPos),
              SF('E_Result', 'O'),

              SF('E_Event', nEvent),
              SF('E_Solution', sFlag_Solution_OK),
              SF('E_Departmen', nDept),
              SF('E_Date', sField_SQLServer_Now, sfVal)
              ], sTable_ManualEvent, nStr, (not nUpdate));
      //xxxxx
      FDM.ExecuteSQL(nStr);
    end;
    Exit;
  end;

  nStr := 'Select * From %s order by R_ID desc ';
  nStr := Format(nStr, [sTable_SnapTruck]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then
    begin
      if not nNeedManu then
        Result := True;
      Exit;
    end;

    nPicName := '';

    First;

    while not Eof do
    begin
      nSnapTruck := FieldByName('S_Truck').AsString;
      if nPicName = '' then//默认取最新一次抓拍
        nPicName := FieldByName('S_PicName').AsString;
      if Pos(nTruck,nSnapTruck) > 0 then
      begin
        Result := True;
        nPicName := FieldByName('S_PicName').AsString;
        //取得匹配成功的图片路径
        nMsg := '车辆[ %s ]车牌识别成功,抓拍车牌号:[ %s ]';
        nMsg := Format(nMsg, [nTruck,nSnapTruck]);
        Exit;
      end
      else
      if nLen > 0 then//模糊匹配
      begin
        if RightStr(nTruck,nLen) = RightStr(nSnapTruck,nLen) then
        begin
          Result := True;
          nPicName := FieldByName('S_PicName').AsString;
          //取得匹配成功的图片路径
          nMsg := '车辆[ %s ]车牌识别成功,抓拍车牌号:[ %s ]';
          nMsg := Format(nMsg, [nTruck,nTruck]);
          Exit;
        end;
        //车牌识别成功
      end;
      Next;
    end;
  end;

  nStr := 'Select * From %s Where E_ID=''%s''';
  nStr := Format(nStr, [sTable_ManualEvent, nBill.FID+sFlag_ManualE]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      if FieldByName('E_Result').AsString = 'N' then
      begin
        nMsg := '车辆[ %s ]车牌识别失败,管理员禁止';
        nMsg := Format(nMsg, [nTruck]);
        Exit;
      end;
      if FieldByName('E_Result').AsString = 'Y' then
      begin
        Result := True;
        nMsg := '车辆[ %s ]车牌识别失败,管理员允许';
        nMsg := Format(nMsg, [nTruck]);
        Exit;
      end;
      nUpdate := True;
    end
    else
    begin
      nUpdate := False;
      if not nNeedManu then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;

  nEvent := '车辆[ %s ]车牌识别失败,请移动车辆并在夜间关闭车灯';
  nEvent := Format(nEvent, [nTruck]);

  nMsg := nEvent;

  nStr := SF('E_ID', nBill.FID+sFlag_ManualE);
  nStr := MakeSQLByStr([
          SF('E_ID', nBill.FID+sFlag_ManualE),
          SF('E_Key', nPicName),
          SF('E_From', nPos),
          SF('E_Result', 'Null', sfVal),

          SF('E_Event', nEvent),
          SF('E_Solution', sFlag_Solution_YN),
          SF('E_Departmen', nDept),
          SF('E_Date', sField_SQLServer_Now, sfVal)
          ], sTable_ManualEvent, nStr, (not nUpdate));
  //xxxxx
  FDM.ExecuteSQL(nStr);
end;

function SaveSnapTruckInfo(const nReader: string; nBill: TLadingBillItem;
                         var nMsg, nPos: string): Boolean;
var nStr, nDept: string;
    nUpdate: Boolean;
    nSnapTruck, nTruck, nEvent, nPicName: string;
begin
  Result := False;
  nPos := '';
  nSnapTruck := '';
  nDept := '';
  nTruck := nBill.Ftruck;

  nPos := ReadPoundReaderInfo(nReader,nDept);

  if nPos = '' then
  begin
    Result := True;
    nMsg := '读卡器[ %s ]绑定岗位为空,无法进行抓拍识别.';
    nMsg := Format(nMsg, [nReader]);
    Exit;
  end;

  nStr := 'Select * From %s Where S_ID=''%s'' order by R_ID desc ';
  nStr := Format(nStr, [sTable_SnapTruck, nPos]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then
    begin
      Exit;
    end;

    nPicName := '';

    First;

    while not Eof do
    begin
      nSnapTruck := FieldByName('S_Truck').AsString;
      if nPicName = '' then//默认取最新一次抓拍
        nPicName := FieldByName('S_PicName').AsString;
      if Pos(nTruck,nSnapTruck) > 0 then
      begin
        Result := True;
        nPicName := FieldByName('S_PicName').AsString;
        //取得匹配成功的图片路径
        Break;
      end;
      //车牌识别成功
      Next;
    end;
  end;

  nStr := 'Select * From %s Where E_ID=''%s''';
  nStr := Format(nStr, [sTable_ManualEvent, nBill.FID+nPos+sFlag_ManualE]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nUpdate := True;
    end
    else
    begin
      nUpdate := False;
    end;
  end;

  if Result then
  begin
    nEvent := '车辆[ %s ]车牌识别成功,抓拍车牌号:[ %s ]';
    nEvent := Format(nEvent, [nTruck,nSnapTruck]);
  end
  else
  begin
    nEvent := '车辆[ %s ]车牌识别失败,抓拍车牌号:[ %s ]';
    nEvent := Format(nEvent, [nTruck,nSnapTruck]);
  end;

  nMsg := nEvent;

  nStr := SF('E_ID', nBill.FID+nPos+sFlag_ManualE);
  nStr := MakeSQLByStr([
          SF('E_ID', nBill.FID+nPos+sFlag_ManualE),
          SF('E_Key', nPicName),
          SF('E_From', nPos),
          SF('E_Result', sFlag_Yes),

          SF('E_Event', nEvent),
          SF('E_Solution', sFlag_Solution_YN),
          SF('E_Departmen', nDept),
          SF('E_Date', sField_SQLServer_Now, sfVal)
          ], sTable_ManualEvent, nStr, (not nUpdate));
  //xxxxx
  FDM.ExecuteSQL(nStr);
end;

//Date: 2018-08-03
//Parm: 读卡器ID
//Desc: 读取nReader岗位、部门
function ReadPoundReaderInfo(const nReader: string; var nDept: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  nDept:= '';
  //卡号

  if CallBusinessHardware(cBC_GetPoundReaderInfo, nReader, '', @nOut)  then
  begin
    Result := Trim(nOut.FData);
    nDept:= Trim(nOut.FExtParam);
  end;
end;

procedure RemoteSnapDisPlay(const nPost, nText, nSucc: string);
var nOut: TWorkerBusinessCommand;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    nList.Values['text'] := nText;
    nList.Values['succ'] := nSucc;

    CallBusinessHardware(cBC_RemoteSnapDisPlay, nPost, PackerEncodeStr(nList.Text), @nOut);
  finally
    nList.Free;
  end;
end;

//Date: 2018/09/11
//Parm: ID
//Desc: 现场信息确认
function InfoConfirmDone(const nID, nStockNo: string): Boolean;
var nSQL: string;
begin
  Result := False;

  if Trim(nStockNo) = '' then
  begin
    Result := True;
    Exit;
  end;

  nSQL := 'Select D_Value From %s Where D_Name=''%s'' and D_Value=''%s''';
  nSQL := Format(nSQL, [sTable_SysDict, sFlag_NeedInfoConfirm,nStockNo]);
  //xxxxx

  with FDM.QueryTemp(nSQL) do
  begin
    if RecordCount <= 0 then
    begin
      Result := True;
      Exit;
    end;
  end;

  nSQL := 'Select top 1 P_ID From %s Where P_ID=''%s'' Order by R_ID desc';
  nSQL := Format(nSQL, [sTable_Picture, nID]);

  with FDM.QueryTemp(nSQL) do
  begin
    if RecordCount > 0 then
    begin
      Result := True;
    end;
  end;
end;

//Date: 2018/09/17
//Desc: 车辆自动进厂
function IsTruckAutoIn: Boolean;
var nSQL: string;
begin
  Result := False;

  nSQL := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo=''%s''';
  nSQL := Format(nSQL, [sTable_SysDict, sFlag_SysParam,sFlag_AutoIn]);
  //xxxxx

  with FDM.QueryTemp(nSQL) do
  begin
    if RecordCount > 0 then
    begin
      if Fields[0].AsString = sFlag_Yes then
        Result := True;
    end;
  end;
end;

//Date: 2018/10/17
//Parm: truck
//Desc: 获取车辆历史最大提货量
function GetTruckHisValueMax(const nTruck: string): Double;
var nSQL: string;
begin
  Result := 0;

  if Trim(nTruck) = '' then
  begin
    Exit;
  end;

  nSQL := 'Select top 1 T_HisValueMax From %s Where T_Truck=''%s'' ';
  nSQL := Format(nSQL, [sTable_Truck, nTruck]);

  with FDM.QueryTemp(nSQL) do
  if RecordCount > 0 then
    Result := Fields[0].AsFloat;

  if Result > 0 then
    Exit;

  nSQL := 'Select Max(L_Value) From %s Where L_Truck=''%s'' ';
  nSQL := Format(nSQL, [sTable_Bill, nTruck]);

  with FDM.QueryTemp(nSQL) do
  if RecordCount > 0 then
    Result := Fields[0].AsFloat;
end;

//Date: 2018/10/17
//Parm: truck
//Desc: 获取车辆历史最大毛重
function GetTruckHisMValueMax(const nTruck: string): Double;
var nSQL: string;
begin
  Result := 0;

  if Trim(nTruck) = '' then
  begin
    Exit;
  end;

  nSQL := 'Select top 1 T_HisMValueMax From %s Where T_Truck=''%s'' ';
  nSQL := Format(nSQL, [sTable_Truck, nTruck]);

  with FDM.QueryTemp(nSQL) do
  if RecordCount > 0 then
    Result := Fields[0].AsFloat;

  if Result > 0 then
    Exit;

  nSQL := 'Select Max(L_MValue) From %s Where L_Truck=''%s'' ';
  nSQL := Format(nSQL, [sTable_Bill, nTruck]);

  with FDM.QueryTemp(nSQL) do
  if RecordCount > 0 then
    Result := Fields[0].AsFloat;
end;

//Desc: 获取毛重限值
function GetMaxMValue(const nTruck: string): Double;
var nStr: string;
begin
  Result := 0;

  nStr := 'Select T_MValueMax From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, nTruck]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
    Result := Fields[0].AsFloat;
  //xxxxx
end;

//Date: 2018-12-14
//Parm: ID
//Desc: 同步提货单
function SyncSaleDetail(const nStr: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_SyncME25, nStr, '', @nOut) then
       Result := True
  else
  begin
    Result := False;
  end;
end;

//Date: 2018-12-14
//Parm: ID
//Desc: 同步磅单
function SyncPoundDetail(const nStr: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_SyncME03, nStr, '', @nOut) then
       Result := True
  else
  begin
    Result := False;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 每批次最大量
function GetHYMaxValue: Double;
var nStr: string;
begin
  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_HYValue]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[0].AsFloat
  else Result := 0;
end;

//Desc: 获取nNo水泥编号的已开量
function GetHYValueByStockNo(const nNo: string): Double;
var nStr: string;
begin
  nStr := 'Select R_SerialNo,Sum(H_Value) From %s ' +
          ' Left Join %s on H_SerialNo= R_SerialNo ' +
          'Where R_SerialNo=''%s'' Group By R_SerialNo';
  nStr := Format(nStr, [sTable_StockRecord, sTable_StockHuaYan, nNo]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[1].AsFloat
  else Result := -1;
end;

function ZTDispatchByLine(const nRID: Integer; nBill, nOldLine, nNewLine,
                           nTruckStockNo: string): Boolean;
var nStr,nTmp,nTruck: string;
    nOldGroup, nOldBatCode, nNewGroup, nNewBatCode, nType: string;
    nList: TStrings;
    nValue: Double;
begin
  Result := False;
  nList := Tstringlist.Create;
  try
    nList.Clear;
    nStr := 'Select M_ID From %s Where M_LineNo=''%s'' and M_Status=''%s''';
    nStr := Format(nStr, [sTable_StockMatch, nNewLine, sFlag_Yes]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount > 0 then
      begin
        First;

        while not Eof do
        begin
          nList.Add(Fields[0].AsString);
          Next;
        end;
      end;
    end;

    nStr := 'Select Z_StockNo,Z_Stock,Z_Group From %s Where Z_ID=''%s''';
    nStr := Format(nStr, [sTable_ZTLines, nNewLine]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
      begin
        ShowMsg('无效的通道编号', sHint);
        Exit;
      end;

      if (Fields[0].AsString <> nTruckStockNo) and
         (nList.IndexOf(nTruckStockNo) < 0)  then
      begin
        nStr := '通道[ %s ]的水泥品种与待装品种不一致或不属于同一分组,详情如下:' + #13#10#13#10 +
                '※.通道品种: %s' + #13#10 +
                '※.待装品种: %s' + #13#10#13#10 +
                '确定要定道操作吗?';
        nStr := Format(nStr, [nNewLine, Fields[0].AsString, nTruckStockNo]);
        if not QueryDlg(nStr,sAsk) then Exit;
      end;
      nNewGroup := Fields[2].AsString;
    end;
  finally
    nList.Free;
  end;

  nOldGroup := '';
  nStr := 'Select D_ParamB From %s Where D_Name=''%s'' and D_Value=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_LineKw, nOldLine]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nOldGroup := Fields[0].AsString;
    end;
  end;

  nNewGroup := '';
  nStr := 'Select D_ParamB From %s Where D_Name=''%s'' and D_Value=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_LineKw, nNewLine]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nNewGroup := Fields[0].AsString;
    end;
  end;

  nStr := 'Select * From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, nBill]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then
    begin
      ShowMsg('无效的提货单号', sHint);
      Exit;
    end;
    nValue   := FieldByName('L_Value').AsFloat;
    nTruck   := FieldByName('L_Truck').AsString;
    if FieldByName('L_IsVIP').AsString = '' then
      nType := sFlag_TypeCommon
    else
      nType := FieldByName('L_IsVIP').AsString;
    nOldBatCode := FieldByName('L_Seal').AsString;
    nNewBatCode := '';
    if (nOldBatCode = '') or (nOldGroup <> nNewGroup) then//未获取批次号或库号不一致
    begin
     if not GetBatCodeByLine(nBill, nTruckStockNo, nNewLine, nNewBatCode) then
      begin
        ShowMsg('获取批次号失败,无法换道',sHint);
        Exit;
      end;
    end;
  end;

  nStr := 'Update %s Set T_Line=''%s'' Where R_ID=%d';
  nStr := Format(nStr, [sTable_ZTTrucks, nNewLine,
          nRID]);
  FDM.ExecuteSQL(nStr);


  nTmp := nOldLine;
  if nTmp = '' then nTmp := '空';

  nStr := '指定装车道[ %s ]->[ %s ]';
  nStr := Format(nStr, [nTmp, nNewLine]);

  if nNewBatCode <> '' then
  begin
    nStr := '指定装车道[ %s ]->[ %s ],批次号[ %s ]->[ %s ]';
    nStr := Format(nStr, [nTmp, nNewLine, nOldBatCode, nNewBatCode]);
  end;

  FDM.WriteSysLog(sFlag_TruckQueue, nTruck, nStr);
  Result := True;
end;

//Date: 2019-01-09
//Parm: 提货单号、通道号
//Desc: 现场刷卡获取批次号
function GetBatCodeByLine(const nLID, nStockNo, nTunnel: string;
                          var nSeal: string): Boolean;
var nOut: TWorkerBusinessCommand;
    nSendEvent: Boolean;
    nStr,nEvent,nEID: string;
begin
  nSendEvent := False;
  nSeal := '';
  Result := CallBusinessCommand(cBC_GetStockBatcodeByLine, nLID, nTunnel, @nOut);

  if Result then
  begin
    nSeal := nOut.FData;
    if nOut.FExtParam <> '' then
    begin
      nSendEvent := True;
      nEvent := nOut.FExtParam;
    end;
  end
  else
  begin
    nSendEvent := True;
    nEvent := nOut.FData;
  end;

  if nSendEvent then
  begin
    CallBusinessCommand(cBC_SaveBatEvent, nStockNo, nEvent, @nOut);
  end;
end;

//Desc: 校验物料是否可以在nTunnel过磅
function VerifyStockCanPound(const nStockNo, nTunnel: string;
                             var nHint: string): Boolean;
var nStr: string;
begin
  Result := False;
  nHint := '';

  if (Trim(nStockNo) = '') or (Trim(nTunnel) = '') then
  begin
    Result := True;
    Exit;
  end;

  nStr := 'Select D_Memo From %s Where D_Name=''%s'' and D_Value=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_PoundStock, nStockNo, nTunnel]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then//符合
    begin
      Result := True;
      Exit;
    end;
  end;
  
  nStr := 'Select D_Memo From %s Where D_Name=''%s'' and D_Value=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_PoundStock, nStockNo]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount <= 0 then//不限制
    begin
      Result := True;
      Exit;
    end;

    First;

    while not Eof do
    begin
      nHint := nHint + Fields[0].AsString + ',';
      Next;
    end;
    if Copy(nHint, Length(nHint), 1) = ',' then
      System.Delete(nHint, Length(nHint), 1);
  end;
end;

//Date: 2018-09-25
//Parm: 通道;登陆ID;列表
//Desc: 抓拍nTunnel的图像
procedure CapturePictureEx(const nTunnel: PPTTunnelItem;
                         const nLogin: Integer; nList: TStrings);
const
  cRetry = 2;
  //重试次数
var nStr: string;
    nIdx,nInt: Integer;
    nErr: Integer;
    nPic: NET_DVR_JPEGPARA;
    nInfo: TNET_DVR_DEVICEINFO;
begin
  nList.Clear;
  if not Assigned(nTunnel.FCamera) then Exit;
  //not camera
  if nLogin <= -1 then Exit;

  WriteLog(nTunneL.FID + '开始抓拍');
  if not DirectoryExists(gSysParam.FPicPath) then
    ForceDirectories(gSysParam.FPicPath);
  //new dir

  if gSysParam.FPicBase >= 100 then
    gSysParam.FPicBase := 0;
  //clear buffer

  try

    nPic.wPicSize := nTunnel.FCamera.FPicSize;
    nPic.wPicQuality := nTunnel.FCamera.FPicQuality;

    for nIdx:=Low(nTunnel.FCameraTunnels) to High(nTunnel.FCameraTunnels) do
    begin
      if nTunnel.FCameraTunnels[nIdx] = MaxByte then continue;
      //invalid

      for nInt:=1 to cRetry do
      begin
        nStr := MakePicName();
        //file path

        NET_DVR_CaptureJPEGPicture(nLogin,
                                   nTunnel.FCameraTunnels[nIdx],
                                   @nPic, PChar(nStr));
        //capture pic

        nErr := NET_DVR_GetLastError;

        if nErr = 0 then
        begin
          WriteLog('通道'+IntToStr(nTunnel.FCameraTunnels[nIdx])+'抓拍成功');
          nList.Add(nStr);
          Break;
        end;

        if nIdx = cRetry then
        begin
          nStr := '抓拍图像[ %s.%d ]失败,错误码: %d';
          nStr := Format(nStr, [nTunnel.FCamera.FHost,
                   nTunnel.FCameraTunnels[nIdx], nErr]);
          WriteLog(nStr);
        end;
      end;
    end;
  except
  end;
end;

function InitCapture(const nTunnel: PPTTunnelItem; var nLogin: Integer): Boolean;
const
  cRetry = 2;
  //重试次数
var nStr: string;
    nIdx,nInt: Integer;
    nErr: Integer;
    nInfo: TNET_DVR_DEVICEINFO;
begin
  Result := False;
  if not Assigned(nTunnel.FCamera) then Exit;
  //not camera

  try
    nLogin := -1;

    NET_DVR_Init;
    //xxxxx

    for nIdx:=1 to cRetry do
    begin
      nLogin := NET_DVR_Login(PChar(nTunnel.FCamera.FHost),
                   nTunnel.FCamera.FPort,
                   PChar(nTunnel.FCamera.FUser),
                   PChar(nTunnel.FCamera.FPwd), @nInfo);
      //to login

      nErr := NET_DVR_GetLastError;
      if nErr = 0 then break;

      if nIdx = cRetry then
      begin
        nStr := '登录摄像机[ %s.%d ]失败,错误码: %d';
        nStr := Format(nStr, [nTunnel.FCamera.FHost, nTunnel.FCamera.FPort, nErr]);
        WriteLog(nStr);
        if nLogin > -1 then
         NET_DVR_Logout(nLogin);
        NET_DVR_Cleanup();
        Exit;
      end;
    end;
    Result := True;
  except

  end;
end;

function FreeCapture(nLogin: Integer): Boolean;
begin
  Result := False;
  try
    if nLogin > -1 then
     NET_DVR_Logout(nLogin);
    NET_DVR_Cleanup();

    Result := True;
  except

  end;
end;

//Date: 2019/5/14
//Desc: 散装最大开单量限制
function GetSanMaxLadeValue: Double;
var nSQL: string;
begin
  Result := 0;

  nSQL := 'Select D_Value From %s Where D_Name=''%s''';
  nSQL := Format(nSQL, [sTable_SysDict, sFlag_SanMaxLadeValue]);
  with FDM.QueryTemp(nSQL) do
  begin
    if RecordCount > 0 then
    begin
      Result := Fields[0].AsFloat;
    end;
  end;
end;

function AutoGetSanHDOrder(nCusID,nStockID,nTruck:string;
                           nHDValue: Double; var nOrderStr: string): Boolean;
var nList: TStrings;
    nItems: array of TOrderItem;
    //订单列表
    nIdx, nInt: Integer;
    nStr: string;
    nVal: Double;
begin
  Result := False;

  nList := TStringList.Create;
  try
    nList.Clear;

    nList.Values['NoDate'] := sFlag_Yes;
    nList.Values['CustomerID'] := nCusID;
    nList.Values['StockNo'] := nStockID;

    if nTruck <> '' then
      nList.Values['Truck'] := nTruck;

    nList.Values['Order'] := 'invtype,NPLANNUM ASC';

    nStr := GetQueryOrderSQL('103', EncodeBase64(nList.Text));

    WriteLog('车辆' + nTruck + '自动合单读取可用订单SQL:' + nStr);

    with FDM.QueryTemp(nStr, True) do
    begin
      if RecordCount < 1 then
      begin
        nOrderStr := '车辆' + nTruck + '自动合单无可用订单,请联系客户下单';
        WriteLog(nOrderStr);
        Exit;
      end;

      SetLength(nItems, RecordCount);
      nIdx := 0;

      nList.Clear;
      First;

      while not Eof do
      begin
        with nItems[nIdx] do
        begin
          FOrderID := FieldByName('PK_MEAMBILL').AsString;
          FStockID := FieldByName('invcode').AsString;
          FStockName := FieldByName('invname').AsString;
          FSaleMan := FieldByName('VBILLTYPE').AsString;
          FStockBrand:= FieldByName('vdef5').AsString;
          FCusName := FieldByName('custname').AsString;
          FTruck := FieldByName('cvehicle').AsString;
          FBatchCode := FieldByName('vbatchcode').AsString;

          FAreaTo := FieldByName('docname').AsString;

          FAreaName := FieldByName('areaclname').AsString;

          FValue := 0;
          FPlanNum := FieldByName('NPLANNUM').AsFloat;
          nList.Add(FOrderID);
        end;

        Inc(nIdx);
        Next;
      end;

      if nList.Count > 0 then
      begin
        if not GetOrderFHValue(nList) then Exit;
        //获取已发货量

        nInt := 0;
        nVal := 0;
        for nIdx:=Low(nItems) to High(nItems) do
        begin
          nStr := nList.Values[nItems[nIdx].FOrderID];
          if not IsNumber(nStr, True) then Continue;


          nItems[nIdx].FValue := nItems[nIdx].FPlanNum -
                                 Float2Float(StrToFloat(nStr), cPrecision, True);

          if nItems[nIdx].FValue < nHDValue then Continue;

          //可用量 = 计划量 - 已发量
          WriteLog('车辆' + nTruck + '当前可用订单' + nItems[nIdx].FOrderID
                   + '可用量' + FloatToStr(nItems[nIdx].FValue));
          if nItems[nIdx].FValue > nVal then
          begin
            nInt := nIdx;
            nVal := nItems[nIdx].FValue;
          end;
        end;

        if nVal <= 0 then
        begin
          nOrderStr := '车辆' + nTruck + '自动合单失败,需合单量'
                       + FloatToStr(nHDValue) + '吨,当前无满足要求订单,请联系客户补量';
          WriteLog(nOrderStr);
          Exit;
        end;
          
        WriteLog('车辆' + nTruck + '确认使用合单订单' + nItems[nInt].FOrderID
                   + '可用量' + FloatToStr(nItems[nInt].FValue) + '序号' + IntToStr(nInt));

        with nList,nItems[nInt] do
        begin
          Clear;
          Values['CusID']     := nCusID;
          Values['CusName']   := FCusName;
          Values['SaleMan']   := FSaleMan;

          Values['StockID']   := FStockID;
          Values['StockName'] := FStockName;
          Values['StockBrand']:= FStockBrand;

          Values['StockArea'] := FAreaName;
          Values['AreaTo']    := FAreaTo;

          Values['Truck']     := FTruck;
          Values['BatchCode'] := FBatchCode;
          Values['Orders']    := FOrderID;
          Values['Value']     := FloatToStr(FValue);
        end;

        nOrderStr := nList.Text;
        WriteLog('可用订单Str:' + nOrderStr);
        Result := True;
      end;
    end;
  finally
    nList.Free;
  end;
end;

procedure SaveTruckPrePValue(const nTruck, nValue: string);
var nStr, nOldPValue, nOldPTime, nDept,nEvent: string;
begin
  nStr := 'Select D_ParamB From $Table ' +
          'Where D_Name=''$Name'' and D_Memo=''$Memo''';
  nStr := MacroValue(nStr, [MI('$Table', sTable_SysDict),
                            MI('$Name', sFlag_SysParam),
                            MI('$Memo', sFlag_SetPValue)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
      nDept := Fields[0].AsString;
  end;

  nStr := 'Select T_PrePValue,T_PrePTime From %s Where T_Truck =''%s'' ';
  nStr := Format(nStr, [sTable_Truck, nTruck]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nOldPValue := Fields[0].AsString;
      nOldPTime := Fields[1].AsString;
    end;
  end;

  nStr := 'update %s set T_PrePValue=%s,T_PrePMan=''%s'',T_PrePTime=%s '
          + ' where t_truck=''%s''';
  nStr := format(nStr,[sTable_Truck,nValue,gSysParam.FUserName
                      ,sField_SQLServer_Now,nTruck]);
  FDM.ExecuteSQL(nStr);

  nEvent := '车辆[ %s ]重新进行预制皮重,上次预制皮重[ %s ],预制时间[ %s ];本次预制皮重[ %s ],预制时间[ %s ];';
  nEvent := Format(nEvent, [nTruck,nOldPValue,nOldPTime,nValue,sField_SQLServer_Now]);

  nStr := SF('E_ID', nTruck+sFlag_ManualP);
  nStr := MakeSQLByStr([
          SF('E_ID', nTruck+sFlag_ManualP),
          SF('E_Key', nTruck),
          SF('E_From', sFlag_DepBangFang),
          SF('E_Result', 'Null', sfVal),

          SF('E_Event', nEvent),
          SF('E_Solution', sFlag_Solution_OK),
          SF('E_Departmen', nDept),
          SF('E_Date', sField_SQLServer_Now, sfVal)
          ], sTable_ManualEvent, '', True);
  //xxxxx
  FDM.ExecuteSQL(nStr);
end;

function GetPrePValueSet: Double;
var nStr: string;
begin
  Result := 30;//init

  nStr := 'Select D_Value From $Table ' +
          'Where D_Name=''$Name'' and D_Memo=''$Memo''';
  nStr := MacroValue(nStr, [MI('$Table', sTable_SysDict),
                            MI('$Name', sFlag_SysParam),
                            MI('$Memo', sFlag_SetPValue)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
      nStr := Fields[0].AsString;
    if IsNumber(nStr,True) then
      Result := StrToFloatDef(nStr,30);
  end;
end;

//Date: 2014-09-18
//Parm: 车牌号;磅站通道
//Desc: 保存nTruck的预制皮重照片
function SaveTruckPrePicture(const nTruck: string;const nTunnel: PPTTunnelItem;
                            const nLogin: Integer): Boolean;
var nStr,nRID: string;
    nIdx: Integer;
    nList: TStrings;
begin
  Result := False;
  nRID := '';
  nStr := 'Select R_ID From %s Where T_Truck =''%s'' order by R_ID desc ';
  nStr := Format(nStr, [sTable_Truck, nTruck]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount <= 0 then
      Exit;
    nRID := Fields[0].AsString;
  end;

  nStr := 'Delete from %s where P_ID=''%s'' ';
  nStr := format(nStr,[sTable_Picture, nRID]);
  FDM.ExecuteSQL(nStr);

  if Assigned(nTunnel) then //过磅称重
  begin
    nList := TStringList.Create;
    try
      CapturePictureEx(nTunnel, nLogin, nList);
      //capture file

      for nIdx:=0 to nList.Count - 1 do
        SavePicture(nRID, nTruck, '', nList[nIdx]);
      //save file
    finally
      nList.Free;
    end;
  end;
end;

function SaveSnapStatus(const nBill: TLadingBillItem; nStatus: string): Boolean;
var nStr: string;
begin
  Result := True;

  if nStatus = sFlag_No then
  begin
  end
  else
  begin
    nStr := 'Select * From %s Where E_ID=''%s''';
    nStr := Format(nStr, [sTable_ManualEvent, nBill.FID+sFlag_ManualE]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount > 0 then
      begin
        if Trim(FieldByName('E_Result').AsString) <> '' then //被干预过，即使成功也不再更新
        begin
          Exit;
        end;

        nStr := 'Delete From %s Where E_ID=''%s''';
        nStr := Format(nStr, [sTable_ManualEvent, nBill.FID+sFlag_ManualE]);
        FDM.ExecuteSQL(nStr);
      end;
    end;
  end;
end;

end.

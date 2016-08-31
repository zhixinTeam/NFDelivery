{*******************************************************************************
  作者: dmzn@163.com 2012-4-22
  描述: 硬件动作业务
*******************************************************************************}
unit UHardBusiness;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, SysUtils, UMgrDBConn, UMgrParam,
  UBusinessWorker, UBusinessConst, UBusinessPacker, UMgrQueue,
  UMgrHardHelper, U02NReader, UMgrERelay, UMultiJS, UMgrRemotePrint,
  UMgrLEDDisp, UMgrRFID102, {$IFDEF HKVDVR}UMgrCamera, {$ENDIF}Graphics, DB;

procedure WhenReaderCardArrived(const nReader: THHReaderItem);
procedure WhenHYReaderCardArrived(const nReader: PHYReaderItem);
//有新卡号到达读头
procedure WhenReaderCardIn(nHost: TReaderHost; nCard: TReaderCard);
//现场读头有新卡号
procedure WhenReaderCardOut(nHost: TReaderHost; nCard: TReaderCard);
//现场读头卡号超时
procedure WhenBusinessMITSharedDataIn(const nData: string);
//业务中间件共享数据
function GetJSTruck(const nTruck,nBill: string): string;
//获取计数器显示车牌
procedure WhenSaveJS(const nTunnel: PMultiJSTunnel);
//保存计数结果

function PrepareShowInfo(const nCard: string; nTunnel: string=''):string;
//计数器显示预装信息
function GetCardUsed(const nCard: string; var nCardType: string): Boolean;
//获取卡号类型

procedure HardOpenDoor(const nReader: String);
//打开道闸
{$IFDEF HKVDVR}
procedure WhenCaptureFinished(const nPtr: Pointer);
//保存图片
{$ENDIF}

implementation

uses
  ULibFun, USysDB, USysLoger, UTaskMonitor, UFormCtrl;

const
  sPost_In   = 'in';
  sPost_Out  = 'out';

//Date: 2014-09-15
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
function CallBusinessCommand(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessCommand);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-05
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的销售单据对象
function CallBusinessSaleBill(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessSaleBill);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2016-06-15
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的销售单据对象
function CallBusinessProvide(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessProvide);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-10-16
//Parm: 命令;数据;参数;输出
//Desc: 调用硬件守护上的业务对象
function CallHardwareCommand(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_HardwareCommand);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2016-06-15
//Parm: 磁卡号
//Desc: 获取磁卡使用类型
function GetCardUsed(const nCard: string; var nCardType: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetCardUsed, nCard, '', @nOut);

  if Result then
       nCardType := nOut.FData
  else gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
  //xxxxx
end;

//Date: 2012-3-23
//Parm: 磁卡号;岗位;交货单列表
//Desc: 获取nPost岗位上磁卡为nCard的交货单列表
function GetLadingBills(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
end;

//Date: 2014-09-18
//Parm: 岗位;交货单列表
//Desc: 保存nPost岗位上的交货单数据
function SaveLadingBills(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessSaleBill(cBC_SavePostBills, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
  //xxxxx
end;

function VerifyLadingBill(const nCard: string; const nDB: PDBWorker): Boolean;
var nSQL, nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  nSQL := 'Select * From %s Where B_Card=''%s''';
  nSQL := Format(nSQL, [sTable_BillNew, nCard]);

  with gDBConnManager.WorkerQuery(nDB, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nStr := '磁卡[ %s ]关联的订单已丢失.';
      nStr := Format(nStr, [nCard]);
      gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
      Exit;
    end;

    if FieldByName('B_IsUsed').AsString = sFlag_No then
    begin
      nStr := FieldByName('B_ID').AsString;
      Result := CallBusinessSaleBill(cBC_SaveBillFromNew, nStr, '', @nOut);
    end else Result := True;
  end;  
end;

//Date: 2016-06-15
//Parm: 磁卡号;岗位;采购入厂单列表
//Desc: 获取nPost岗位上磁卡为nCard的采购入厂单列表
function GetProvideItems(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessProvide(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
end;

//Date: 2016-06-15
//Parm: 岗位;采购入厂单列表
//Desc: 保存nPost岗位上的采购入厂单数据
function SaveProvideItems(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessProvide(cBC_SavePostBills, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, '业务对象', nOut.FData);
  //xxxxx
end;
                                                             
//------------------------------------------------------------------------------
//Date: 2013-07-21
//Parm: 事件描述;岗位标识
//Desc:
procedure WriteHardHelperLog(const nEvent: string; nPost: string = '');
begin
  gDisplayManager.Display(nPost, nEvent);
  gSysLoger.AddLog(THardwareHelper, '硬件守护辅助', nEvent);
end;

//Date: 2012-4-22
//Parm: 卡号
//Desc: 对nCard放行进厂
procedure MakeTruckIn(const nCard,nReader: string; const nDB: PDBWorker);
var nStr,nTruck,nCardType: string;
    nIdx,nInt: Integer;
    nPLine: PLineItem;
    nRet: Boolean;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;
begin
  if not GetCardUsed(nCard, nCardType) then nCardType := sFlag_Sale;

  if gTruckQueueManager.IsTruckAutoIn(nCardType=sFlag_Sale) and (GetTickCount -
     gHardwareHelper.GetCardLastDone(nCard, nReader) < 2 * 60 * 1000) then
  begin
    gHardwareHelper.SetReaderCard(nReader, nCard);
    {$IFDEF FORCEOPENDOOR}
    HardOpenDoor(nReader);
    {$ENDIF}
    Exit;
  end; //同读头同卡,在2分钟内不做二次进厂业务.

  if nCardType = sFlag_SaleNew then
  if not VerifyLadingBill(nCard, nDB) then Exit;
  //如果首次刷卡，则生成明细

  if (nCardType = sFlag_Sale) or (nCardType = sFlag_SaleNew) then
    nRet := GetLadingBills(nCard, sFlag_TruckIn, nTrucks) else
  if nCardType = sFlag_Provide then
    nRet := GetProvideItems(nCard, sFlag_TruckIn, nTrucks) else nRet := False;

  if not nRet then
  begin
    nStr := '读取磁卡[ %s ]订单信息失败.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要进厂车辆.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    FCardUse := nCardType;
    if (FStatus = sFlag_TruckNone) or (FStatus = sFlag_TruckIn) then Continue;
    //未进长,或已进厂

    nStr := '车辆[ %s ]下一状态为:[ %s ],进厂刷卡无效.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);

    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  if nTrucks[0].FStatus = sFlag_TruckIn then
  begin
    if gTruckQueueManager.IsTruckAutoIn(nCardType=sFlag_Sale) then
    begin
      gHardwareHelper.SetCardLastDone(nCard, nReader);
      gHardwareHelper.SetReaderCard(nReader, nCard);
      {$IFDEF FORCEOPENDOOR}
      HardOpenDoor(nReader);
      {$ENDIF}
    end else
    begin
      if gTruckQueueManager.TruckReInfactFobidden(nTrucks[0].FTruck) then
      begin
        HardOpenDoor(nReader);
        //抬杆

        nStr := '车辆[ %s ]再次抬杆操作.';
        nStr := Format(nStr, [nTrucks[0].FTruck]);
        WriteHardHelperLog(nStr, sPost_In);
      end;
    end;

    Exit;
  end;

  //----------------------------------------------------------------------------
  if nCardType = sFlag_Provide then //非销售业务,不使用队列
  begin
    nRet := SaveProvideItems(sFlag_TruckIn, nTrucks);

    if not nRet then
    begin
      nStr := '车辆[ %s ]进厂放行失败.';
      nStr := Format(nStr, [nTrucks[0].FTruck]);

      WriteHardHelperLog(nStr, sPost_In);
      Exit;
    end;

    if gTruckQueueManager.IsTruckAutoIn(nCardType=sFlag_Sale) then
    begin
      gHardwareHelper.SetCardLastDone(nCard, nReader);
      gHardwareHelper.SetReaderCard(nReader, nCard);
      {$IFDEF FORCEOPENDOOR}
      HardOpenDoor(nReader);
      {$ENDIF}
    end else
    begin
      HardOpenDoor(nReader);
      //抬杆
    end;

    nStr := '%s磁卡[%s]进厂抬杆成功';
    nStr := Format(nStr, [BusinessToStr(nCardType), nCard]);
    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  //----------------------------------------------------------------------------
  nPLine := nil;
  //nPTruck := nil;

  with gTruckQueueManager do
  if not IsDelayQueue then //非延时队列(厂内模式)
  try
    SyncLock.Enter;
    nStr := nTrucks[0].FTruck;

    for nIdx:=Lines.Count - 1 downto 0 do
    begin
      nInt := TruckInLine(nStr, PLineItem(Lines[nIdx]).FTrucks);
      if nInt >= 0 then
      begin
        nPLine := Lines[nIdx];
        //nPTruck := nPLine.FTrucks[nInt];
        Break;
      end;
    end;

    if not Assigned(nPLine) then
    begin
      nStr := '车辆[ %s ]没有在调度队列中.';
      nStr := Format(nStr, [nTrucks[0].FTruck]);

      WriteHardHelperLog(nStr, sPost_In);
      Exit;
    end;
  finally
    SyncLock.Leave;
  end;

  if not SaveLadingBills(sFlag_TruckIn, nTrucks) then
  begin
    nStr := '车辆[ %s ]进厂放行失败.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  if gTruckQueueManager.IsTruckAutoIn(nCardType=sFlag_Sale) then
  begin
    gHardwareHelper.SetCardLastDone(nCard, nReader);
    gHardwareHelper.SetReaderCard(nReader, nCard);
    {$IFDEF FORCEOPENDOOR}
    HardOpenDoor(nReader);
    {$ENDIF}
  end else
  begin
    HardOpenDoor(nReader);
    //抬杆
  end;

  with gTruckQueueManager do
  if not IsDelayQueue then //厂外模式,进厂时绑定道号(一车多单)
  try
    SyncLock.Enter;
    nTruck := nTrucks[0].FTruck;

    for nIdx:=Lines.Count - 1 downto 0 do
    begin
      nPLine := Lines[nIdx];
      nInt := TruckInLine(nTruck, PLineItem(Lines[nIdx]).FTrucks);

      if nInt < 0 then Continue;
      nPTruck := nPLine.FTrucks[nInt];

      nStr := 'Update %s Set T_Line=''%s'',T_PeerWeight=%d Where T_Bill=''%s''';
      nStr := Format(nStr, [sTable_ZTTrucks, nPLine.FLineID, nPLine.FPeerWeight,
              nPTruck.FBill]);
      //xxxxx

      gDBConnManager.WorkerExec(nDB, nStr);
      //绑定通道
    end;
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2012-4-22
//Parm: 卡号;读头;打印机
//Desc: 对nCard放行出厂
procedure MakeTruckOut(const nCard,nReader,nPrinter: string);
var nStr, nCardType, nPrint: string;
    nIdx: Integer;
    nRet: Boolean;
    nReaderItem: THHReaderItem;
    nTrucks: TLadingBillItems;
    {$IFDEF PrintBillMoney}
    nOut: TWorkerBusinessCommand;
    {$ENDIF}
begin
  if not GetCardUsed(nCard, nCardType) then nCardType := sFlag_Sale;

  if (nCardType = sFlag_Sale) or (nCardType = sFlag_SaleNew) then
    nRet := GetLadingBills(nCard, sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_Provide then
    nRet := GetProvideItems(nCard, sFlag_TruckOut, nTrucks) else nRet := False;
  //xxxxx

  if not nRet then
  begin
    nStr := '读取磁卡[ %s ]交货单信息失败.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要出厂车辆.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    FCardUse := nCardType;
    if FNextStatus = sFlag_TruckOut then Continue;
    nStr := '车辆[ %s ]下一状态为:[ %s ],无法出厂.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
    
    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  if (nCardType = sFlag_Sale) or (nCardType = sFlag_SaleNew) then
    nRet := SaveLadingBills(sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_Provide then
    nRet := SaveProvideItems(sFlag_TruckOut, nTrucks) else nRet := False;
  //xxxxx

  if not nRet then
  begin
    nStr := '车辆[ %s ]出厂放行失败.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  if nReader <> '' then
    HardOpenDoor(nReader);
  //抬杆

  nStr := '车辆%s已出厂';
  nStr := Format(nStr, [nTrucks[0].FTruck]);
  gDisplayManager.Display(nReader, nStr);
  //LED显示

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  begin
    {$IFDEF HKVDVR}
    gCameraManager.CapturePicture(nReader, nTrucks[nIdx].FID);
    //抓拍
    {$ENDIF}

    {$IFDEF PrintBillMoney}
    if CallBusinessCommand(cBC_GetZhiKaMoney,nTrucks[nIdx].FZhiKa,'',@nOut) then
         nStr := #8 + nOut.FData
    else nStr := #8 + '0';
    {$ELSE}
    nStr := '';
    {$ENDIF}

    nStr := nStr + #7 + nCardType;
    //磁卡类型

    if nPrinter = '' then
    begin
      gHardwareHelper.GetReaderLastOn(nCard, nReaderItem);
      nPrint := nReaderItem.FPrinter;
    end else nPrint := nPrinter;

    if nPrint = '' then
         gRemotePrinter.PrintBill(nTrucks[nIdx].FID + nStr)
    else gRemotePrinter.PrintBill(nTrucks[nIdx].FID + #9 + nPrint + nStr);
  end; //打印报表
end;

//Date: 2012-10-19
//Parm: 卡号;读头
//Desc: 检测车辆是否在队列中,决定是否抬杆
procedure MakeTruckPassGate(const nCard,nReader: string; const nDB: PDBWorker);
var nStr: string;
    nIdx: Integer;
    nTrucks: TLadingBillItems;
begin
  if not GetLadingBills(nCard, sFlag_TruckOut, nTrucks) then
  begin
    nStr := '读取磁卡[ %s ]交货单信息失败.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要通过道闸的车辆.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  if gTruckQueueManager.TruckInQueue(nTrucks[0].FTruck) < 0 then
  begin
    nStr := '车辆[ %s ]不在队列,禁止通过道闸.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  HardOpenDoor(nReader);
  //抬杆

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  begin
    nStr := 'Update %s Set T_InLade=%s Where T_Bill=''%s'' And T_InLade Is Null';
    nStr := Format(nStr, [sTable_ZTTrucks, sField_SQLServer_Now, nTrucks[nIdx].FID]);

    gDBConnManager.WorkerExec(nDB, nStr);
    //更新提货时间,语音程序将不再叫号.
  end;
end;

//Date: 2012-4-22
//Parm: 读头数据
//Desc: 对nReader读到的卡号做具体动作
procedure WhenReaderCardArrived(const nReader: THHReaderItem);
var nStr, nGroup: string;
    nErrNum: Integer;
    nDBConn: PDBWorker;
begin
  nDBConn := nil;
  {$IFDEF DEBUG}
  WriteHardHelperLog('WhenReaderCardArrived进入.');
  {$ENDIF}

  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
    if not Assigned(nDBConn) then
    begin
      WriteHardHelperLog('连接HM数据库失败(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nStr := 'Select C_Card,C_Group From $TB Where C_Card=''$CD'' or ' +
            'C_Card2=''$CD'' or C_Card3=''$CD''';
    nStr := MacroValue(nStr, [MI('$TB', sTable_Card), MI('$CD', nReader.FCard)]);

    with gDBConnManager.WorkerQuery(nDBConn, nStr) do
    if RecordCount > 0 then
    begin
      nStr := Fields[0].AsString;
      nGroup := UpperCase(Fields[1].AsString);
    end else
    begin
      nStr := Format('磁卡号[ %s ]匹配失败.', [nReader.FCard]);
      WriteHardHelperLog(nStr);
      Exit;
    end;

    if (nReader.FGroup <> '') and (UpperCase(nReader.FGroup) <> nGroup) then
    begin
      nStr := Format('磁卡号[ %s:::%s ]与读卡器[ %s:::%s ]分组匹配失败.',
              [nReader.FCard, nGroup, nReader.FID, nReader.FGroup]);
      WriteHardHelperLog(nStr);
      Exit;
    end;
    //读卡器分组与卡片分组不匹配 

    try
      if nReader.FType = rtIn then
      begin
        MakeTruckIn(nStr, nReader.FID, nDBConn);
      end else

      if nReader.FType = rtOut then
      begin
        MakeTruckOut(nStr, nReader.FID, nReader.FPrinter);
      end else

      if nReader.FType = rtGate then
      begin
        if nReader.FID <> '' then
          HardOpenDoor(nReader.FID);
        //抬杆
      end else

      if nReader.FType = rtQueueGate then
      begin
        if nReader.FID <> '' then
          MakeTruckPassGate(nStr, nReader.FID, nDBConn);
        //抬杆
      end;
    except
      On E:Exception do
      begin
        WriteHardHelperLog(E.Message);
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

//------------------------------------------------------------------------------
procedure WriteNearReaderLog(const nEvent: string);
begin
  gSysLoger.AddLog(T02NReader, '现场近距读卡器', nEvent);
end;

//Date: 2012-4-24
//Parm: 车牌;通道;是否检查先后顺序;提示信息
//Desc: 检查nTuck是否可以在nTunnel装车
function IsTruckInQueue(const nTruck,nTunnel: string; const nQueued: Boolean;
 var nHint: string; var nPTruck: PTruckItem; var nPLine: PLineItem;
 const nStockType: string = ''): Boolean;
var i,nIdx,nInt: Integer;
    nLineItem: PLineItem;
begin
  with gTruckQueueManager do
  try
    Result := False;
    SyncLock.Enter;
    nIdx := GetLine(nTunnel);

    if nIdx < 0 then
    begin
      nHint := Format('通道[ %s ]无效.', [nTunnel]);
      Exit;
    end;

    nPLine := Lines[nIdx];
    nIdx := TruckInLine(nTruck, nPLine.FTrucks);

    if (nIdx < 0) and (nStockType <> '') and (
       ((nStockType = sFlag_Dai) and IsDaiQueueClosed) or
       ((nStockType = sFlag_San) and IsSanQueueClosed)) then
    begin
      for i:=Lines.Count - 1 downto 0 do
      begin
        if Lines[i] = nPLine then Continue;
        nLineItem := Lines[i];
        nInt := TruckInLine(nTruck, nLineItem.FTrucks);

        if nInt < 0 then Continue;
        //不在当前队列
        if not StockMatch(nPLine.FStockNo, nLineItem) then Continue;
        //刷卡道与队列道品种不匹配

        nIdx := nPLine.FTrucks.Add(nLineItem.FTrucks[nInt]);
        nLineItem.FTrucks.Delete(nInt);
        //挪动车辆到新道

        nHint := 'Update %s Set T_Line=''%s'' ' +
                 'Where T_Truck=''%s'' And T_Line=''%s''';
        nHint := Format(nHint, [sTable_ZTTrucks, nPLine.FLineID, nTruck,
                nLineItem.FLineID]);
        gTruckQueueManager.AddExecuteSQL(nHint);

        nHint := '车辆[ %s ]自主换道[ %s->%s ]';
        nHint := Format(nHint, [nTruck, nLineItem.FName, nPLine.FName]);
        WriteNearReaderLog(nHint);
        Break;
      end;
    end;
    //袋装重调队列

    if nIdx < 0 then
    begin
      nHint := Format('车辆[ %s ]不在[ %s ]队列中.', [nTruck, nPLine.FName]);
      Exit;
    end;

    nPTruck := nPLine.FTrucks[nIdx];
    nPTruck.FStockName := nPLine.FName;
    //同步物料名
    Result := True;
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2013-1-21
//Parm: 通道号;交货单;
//Desc: 在nTunnel上打印nBill防伪码
function PrintBillCode(const nTunnel,nBill: string; var nHint: string): Boolean;
var nStr: string;
    nTask: Int64;
    nOut: TWorkerBusinessCommand;
begin
  Result := True;
  if not gMultiJSManager.CountEnable then Exit;

  nTask := gTaskMonitor.AddTask('UHardBusiness.PrintBillCode', cTaskTimeoutLong);
  //to mon
  
  if not CallHardwareCommand(cBC_PrintCode, nBill, nTunnel, @nOut) then
  begin
    nStr := '向通道[ %s ]发送防违流码失败,描述: %s';
    nStr := Format(nStr, [nTunnel, nOut.FData]);  
    WriteNearReaderLog(nStr);
  end;

  gTaskMonitor.DelTask(nTask, True);
  //task done
end;

//Date: 2012-4-24
//Parm: 车牌;通道;交货单;启动计数
//Desc: 对在nTunnel的车辆开启计数器
function TruckStartJS(const nTruck,nTunnel,nBill: string;
  var nHint: string; const nAddJS: Boolean = True): Boolean;
var nIdx: Integer;
    nTask: Int64;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
begin
  with gTruckQueueManager do
  try
    Result := False;
    SyncLock.Enter;
    nIdx := GetLine(nTunnel);

    if nIdx < 0 then
    begin
      nHint := Format('通道[ %s ]无效.', [nTunnel]);
      Exit;
    end;

    nPLine := Lines[nIdx];
    nIdx := TruckInLine(nTruck, nPLine.FTrucks);

    if nIdx < 0 then
    begin
      nHint := Format('车辆[ %s ]已不再队列.', [nTruck]);
      Exit;
    end;

    Result := True;
    nPTruck := nPLine.FTrucks[nIdx];

    for nIdx:=nPLine.FTrucks.Count - 1 downto 0 do
      PTruckItem(nPLine.FTrucks[nIdx]).FStarted := False;
    nPTruck.FStarted := True;

    if PrintBillCode(nTunnel, nBill, nHint) and nAddJS then
    begin
      nTask := gTaskMonitor.AddTask('UHardBusiness.AddJS', cTaskTimeoutLong);
      //to mon
      
      gMultiJSManager.AddJS(nTunnel, nTruck, nBill, nPTruck.FDai, True);
      gTaskMonitor.DelTask(nTask);
    end;
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2013-07-17
//Parm: 交货单号
//Desc: 查询nBill上的已装量
function GetHasDai(const nBill: string): Integer;
var nStr: string;
    nIdx: Integer;
    nDBConn: PDBWorker;
begin
  if not gMultiJSManager.ChainEnable then
  begin
    Result := 0;
    Exit;
  end;

  Result := gMultiJSManager.GetJSDai(nBill);
  if Result > 0 then Exit;

  nDBConn := nil;
  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nIdx);
    if not Assigned(nDBConn) then
    begin
      WriteNearReaderLog('连接HM数据库失败(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nStr := 'Select T_Total From %s Where T_Bill=''%s''';
    nStr := Format(nStr, [sTable_ZTTrucks, nBill]);

    with gDBConnManager.WorkerQuery(nDBConn, nStr) do
    if RecordCount > 0 then
    begin
      Result := Fields[0].AsInteger;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

//Date: 2012-4-24
//Parm: 磁卡号;通道号
//Desc: 对nCard执行袋装装车操作
procedure MakeTruckLadingDai(const nCard: string; nTunnel: string);
var nStr: string;
    nIdx,nInt: Integer;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;

    function IsJSRun: Boolean;
    begin
      Result := False;
      if nTunnel = '' then Exit;
      Result := gMultiJSManager.IsJSRun(nTunnel);

      if Result then
      begin
        nStr := '通道[ %s ]装车中,业务无效.';
        nStr := Format(nStr, [nTunnel]);
        WriteNearReaderLog(nStr);
      end;
    end;
begin
  {$IFDEF DEBUG}
  WriteNearReaderLog('MakeTruckLadingDai进入.');
  {$ENDIF}

  if IsJSRun then Exit;
  //tunnel is busy

  if not GetLadingBills(nCard, sFlag_TruckZT, nTrucks) then
  begin
    nStr := '读取磁卡[ %s ]交货单信息失败.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要栈台提货车辆.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if nTunnel = '' then
  begin
    nTunnel := gTruckQueueManager.GetTruckTunnel(nTrucks[0].FTruck);
    //重新定位车辆所在车道
    if IsJSRun then Exit;
  end;
  
  if not IsTruckInQueue(nTrucks[0].FTruck, nTunnel, False, nStr,
         nPTruck, nPLine, sFlag_Dai) then
  begin
    WriteNearReaderLog(nStr);
    Exit;
  end; //检查通道

  nStr := '';
  nInt := 0;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    nStr := Format('单据匹配: %s in %s', [FID, nPTruck.FHKBills]);
    WriteNearReaderLog(nStr);
    //for log

    if (FStatus = sFlag_TruckZT) or (FNextStatus = sFlag_TruckZT) then
    begin
      FSelected := Pos(FID, nPTruck.FHKBills) > 0;
      if FSelected then Inc(nInt); //刷卡通道对应的交货单
      Continue;
    end;

    FSelected := False;
    nStr := '车辆[ %s ]下一状态为:[ %s ],无法栈台提货.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
  end;

  if nInt < 1 then
  begin
    WriteHardHelperLog(nStr);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if not FSelected then Continue;
    if FStatus <> sFlag_TruckZT then Continue;

    nStr := '袋装车辆[ %s ]再次刷卡装车.';
    nStr := Format(nStr, [nPTruck.FTruck]);
    WriteNearReaderLog(nStr);

    if not TruckStartJS(nPTruck.FTruck, nTunnel, nPTruck.FBill, nStr,
       GetHasDai(nPTruck.FBill) < 1) then
      WriteNearReaderLog(nStr);
    Exit;
  end;

  if not SaveLadingBills(sFlag_TruckZT, nTrucks) then
  begin
    nStr := '车辆[ %s ]栈台提货失败.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if not TruckStartJS(nPTruck.FTruck, nTunnel, nPTruck.FBill, nStr) then
    WriteNearReaderLog(nStr);
  Exit;
end;

//Date: 2012-4-25
//Parm: 车辆;通道
//Desc: 授权nTruck在nTunnel车道放灰
procedure TruckStartFH(const nTruck: PTruckItem; const nTunnel: string);
var nStr,nTmp: string;
    nWorker: PDBWorker;
begin
  nWorker := nil;
  try
    nTmp := '';
    nStr := 'Select T_Card,T_CardUse From %s Where T_Truck=''%s''';
    nStr := Format(nStr, [sTable_Truck, nTruck.FTruck]);

    with gDBConnManager.SQLQuery(nStr, nWorker) do
    if RecordCount > 0 then
    begin
      nTmp := Trim(Fields[0].AsString);
      if Fields[1].AsString = sFlag_No then
        nTmp := '';
      //xxxxx
    end;

    g02NReader.SetRealELabel(nTunnel, nTmp);
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;

  nStr := nTruck.FTruck + StringOfChar(' ', 12 - Length(nTruck.FTruck));
  nTmp := nTruck.FStockName + FloatToStr(nTruck.FValue);
  nStr := nStr + nTruck.FStockName + StringOfChar(' ', 12 - Length(nTmp)) +
          FloatToStr(nTruck.FValue);
  //xxxxx

  {$IFDEF JDNF}
  gDisplayManager.Display(nTunnel, nStr);
  //显示内容
  {$ELSE}
  gERelayManager.LineOpen(nTunnel);
  //打开放灰
  gERelayManager.ShowTxt(nTunnel, nStr);
  //显示内容
  {$ENDIF}
end;

//Date: 2012-4-24
//Parm: 磁卡号;通道号
//Desc: 对nCard执行袋装装车操作
procedure MakeTruckLadingSan(const nCard,nTunnel: string);
var nStr: string;
    nIdx: Integer;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;
begin
  {$IFDEF DEBUG}
  WriteNearReaderLog('MakeTruckLadingSan进入.');
  {$ENDIF}

  if not GetLadingBills(nCard, sFlag_TruckFH, nTrucks) then
  begin
    nStr := '读取磁卡[ %s ]交货单信息失败.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '磁卡[ %s ]没有需要放灰车辆.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if (FStatus = sFlag_TruckFH) or (FNextStatus = sFlag_TruckFH) then Continue;
    //未装或已装

    nStr := '车辆[ %s ]下一状态为:[ %s ],无法放灰.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
    
    WriteHardHelperLog(nStr);
    Exit;
  end;

  if not IsTruckInQueue(nTrucks[0].FTruck, nTunnel, False, nStr,
         nPTruck, nPLine, sFlag_San) then
  begin 
    WriteNearReaderLog(nStr);
    //loged

    nIdx := Length(nTrucks[0].FTruck);
    nStr := nTrucks[0].FTruck + StringOfChar(' ',12 - nIdx) + '请换库装车';

    {$IFDEF JDNF}
    gDisplayManager.Display(nTunnel, nStr);
    {$ELSE}
    gERelayManager.ShowTxt(nTunnel, nStr);
    {$ENDIF}
    Exit;
  end; //检查通道

  if nTrucks[0].FStatus = sFlag_TruckFH then
  begin
    nStr := '散装车辆[ %s ]再次刷卡装车.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);
    WriteNearReaderLog(nStr);
    
    TruckStartFH(nPTruck, nTunnel);
    Exit;
  end;

  if not SaveLadingBills(sFlag_TruckFH, nTrucks) then
  begin
    nStr := '车辆[ %s ]放灰处提货失败.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  TruckStartFH(nPTruck, nTunnel);
  //执行放灰
end;

//Date: 2012-4-24
//Parm: 主机;卡号
//Desc: 对nHost.nCard新到卡号作出动作
procedure WhenReaderCardIn(nHost: TReaderHost; nCard: TReaderCard);
var nTxt: string;
begin 
  if nHost.FType = rtOnce then
  begin
    if nHost.FFun = rfOut then
         MakeTruckOut(nCard.FCard, nHost.FID, nHost.FPrinter)
    else MakeTruckLadingDai(nCard.FCard, nHost.FTunnel);
  end else

  if nHost.FType = rtKeep then
  begin
    if nHost.FPrepare then
    begin
      nTxt := PrepareShowInfo(nCard.FCard, nHost.FTunnel);
      WriteHardHelperLog(nTxt, nHost.FID);
    end
    else MakeTruckLadingSan(nCard.FCard, nHost.FTunnel);
  end;
end;

//Date: 2012-4-24
//Parm: 主机;卡号
//Desc: 对nHost.nCard超时卡作出动作
procedure WhenReaderCardOut(nHost: TReaderHost; nCard: TReaderCard);
begin
  {$IFDEF DEBUG}
  WriteHardHelperLog('WhenReaderCardOut退出.');
  {$ENDIF}

  if nHost.FPrepare then
  begin
    WriteHardHelperLog(nHost.FLEDText, nHost.FID);
    Sleep(100);
    Exit;
  end;

  if nHost.FETimeOut and (not nCard.FOldOne) then
  begin
    {$IFDEF JDNF}
    gDisplayManager.Display(nHost.FTunnel, '电子标签超出范围');
    {$ELSE}
    gERelayManager.LineClose(nHost.FTunnel);
    Sleep(100);
    gERelayManager.ShowTxt(nHost.FTunnel, '电子标签超出范围');
    Sleep(100);
    {$ENDIF}
    Exit;
  end;

  {$IFDEF JDNF}
  gDisplayManager.Display(nHost.FTunnel, nHost.FLEDText);
  {$ELSE}
  gERelayManager.LineClose(nHost.FTunnel);
  Sleep(100);
  gERelayManager.ShowTxt(nHost.FTunnel, nHost.FLEDText);
  Sleep(100);
  {$ENDIF}
end;

//Date: 2014-10-25
//Parm: 读头数据
//Desc: 华益读头磁卡动作
procedure WhenHYReaderCardArrived(const nReader: PHYReaderItem);
begin
  {$IFDEF DEBUG}
  WriteHardHelperLog(Format('华益标签 %s:%s', [nReader.FTunnel, nReader.FCard]));
  {$ENDIF}

  if nReader.FVirtual then
  begin
    case nReader.FVType of
    rt900 : gHardwareHelper.SetReaderCard(nReader.FVReader, 'H' + nReader.FCard, False);
    rt02n : g02NReader.SetReaderCard(nReader.FVReader, nReader.FCard);
    end;
  end
  else g02NReader.ActiveELabel(nReader.FTunnel, nReader.FCard);
end;

//------------------------------------------------------------------------------
//Date: 2012-12-16
//Parm: 磁卡号
//Desc: 对nCardNo做自动出厂(模拟读头刷卡)
procedure MakeTruckAutoOut(const nCardNo: string);
var nReader, nCardType: string;
begin
  if not GetCardUsed(nCardNo, nCardType) then nCardType := sFlag_Sale;

  if gTruckQueueManager.IsTruckAutoOut(nCardType=sFlag_Sale) then
  begin
    nReader := gHardwareHelper.GetReaderLastOn(nCardNo);
    if nReader <> '' then
      gHardwareHelper.SetReaderCard(nReader, nCardNo);
    //模拟刷卡
  end;
end;

//Date: 2012-12-16
//Parm: 磁卡号
//Desc: 对nCardNo做自动出厂(模拟读头刷卡),用于仅有一个读卡器模拟所有流程
procedure MakeTruckSHAutoOut(const nCardNo: string);
var nReader, nCardType: string;
begin
  if not GetCardUsed(nCardNo, nCardType) then nCardType := sFlag_Sale;

  if gTruckQueueManager.IsTruckAutoOut(nCardType=sFlag_Sale) then
  begin
    nReader := gHardwareHelper.GetReaderLastOn(nCardNo);
    if nReader <> '' then
      gHardwareHelper.SetReaderCard(nReader + 'SH', nCardNo);
    //模拟刷卡
  end;
end;  

//Date: 2012-12-16
//Parm: 共享数据
//Desc: 处理业务中间件与硬件守护的交互数据
procedure WhenBusinessMITSharedDataIn(const nData: string);
begin
  WriteHardHelperLog('收到Bus_MIT业务请求:::' + nData);
  //log data

  if Pos('TruckOut', nData) = 1 then
    MakeTruckAutoOut(Copy(nData, Pos(':', nData) + 1, MaxInt));
  //auto out

  if Pos('TruckSH', nData) = 1 then
    MakeTruckSHAutoOut(Copy(nData, Pos(':', nData) + 1, MaxInt));
  //auto out
end;

//Date: 2015-01-14
//Parm: 车牌号;交货单
//Desc: 格式化nBill交货单需要显示的车牌号
function GetJSTruck(const nTruck,nBill: string): string;
var nStr: string;
    nLen: Integer;
    nWorker: PDBWorker;
begin
  Result := nTruck;
  if nBill = '' then Exit;

  {$IFDEF JSTruck}
  nWorker := nil;
  try
    nStr := 'Select L_PackStyle From %s Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, nBill]);

    with gDBConnManager.SQLQuery(nStr, nWorker) do
    if RecordCount > 0 then
    begin
      nStr := Trim(Fields[0].AsString);
      if (nStr = '') or (nStr = 'C') then Exit;
      //普通模式,车牌全显

      nLen := cMultiJS_Truck - 2;
      Result := nStr + '-' + Copy(nTruck, Length(nTruck) - nLen + 1, nLen);
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;   
  {$ENDIF}
end;

//Date: 2013-07-17
//Parm: 计数器通道
//Desc: 保存nTunnel计数结果
procedure WhenSaveJS(const nTunnel: PMultiJSTunnel);
var nStr: string;
    nDai: Word;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nDai := nTunnel.FHasDone - nTunnel.FLastSaveDai;
  if nDai <= 0 then Exit;
  //invalid dai num

  if nTunnel.FLastBill = '' then Exit;
  //invalid bill

  nList := nil;
  try
    nList := TStringList.Create;
    nList.Values['Bill'] := nTunnel.FLastBill;
    nList.Values['Dai'] := IntToStr(nDai);

    nStr := PackerEncodeStr(nList.Text);
    CallHardwareCommand(cBC_SaveCountData, nStr, '', @nOut)
  finally
    nList.Free;
  end;
end;

function GetStockType(nBill: string):string;
var nStr: string;
    nWorker: PDBWorker;
begin
  Result := '普通';
  nStr := 'Select L_PackStyle From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, nBill]);

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nStr, nWorker) do
    if RecordCount > 0 then
    begin
      nStr := Trim(Fields[0].AsString);
      if nStr = 'Z' then Result := '纸袋';
      if nStr = 'R' then Result := '早强';
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;

function PrepareShowInfo(const nCard:string; nTunnel: string=''):string;
var nStr: string;
    nDai: Double;
    nIdx,nInt: Integer;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;
begin
  if not GetLadingBills(nCard, sFlag_TruckZT, nTrucks) then
  begin
    Result := '读取磁卡[ %s ]交货单信息失败.';
    Result := Format(Result, [nCard]);

    WriteNearReaderLog(Result);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    Result := '磁卡[ %s ]没有需要栈台提货车辆.';
    Result := Format(Result, [nCard]);

    WriteNearReaderLog(Result);
    Exit;
  end;

  if nTunnel = '' then
  begin
    nTunnel := gTruckQueueManager.GetTruckTunnel(nTrucks[0].FTruck);
    //重新定位车辆所在车道
  end;

  nInt := 0;
  Result := '';
  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
     if not IsTruckInQueue(FTruck, nTunnel, False, Result,
         nPTruck, nPLine, sFlag_Dai) then
     begin
        WriteNearReaderLog(Result);
        Continue;
     end; //检查通道

     if ((FStatus = sFlag_TruckZT) or
      (FNextStatus= sFlag_TruckZT)) then
     begin
        nDai := Int(FValue * 1000) / nPLine.FPeerWeight;

        nStr := GetStockType(FID);
        Result := Result + nStr + StringOfChar(' ' , 7 - Length(nStr));

        nStr := FormatFloat('00000' , nDai);
        Result := Result + StringOfChar('0' , 5 - Length(nStr)) + nStr;

        Inc(nInt);
     end;
  end;

  if nInt<1 then Result := '车辆不在队列中';
end;

procedure HardOpenDoor(const nReader: String);
var nIdx: Integer;
begin
  for nIdx := 0 to 3 do
  begin
    {$IFDEF RFIDOPENDOOR}
    gHYReaderManager.OpenDoor(nReader);
    {$ELSE}
    gHardwareHelper.OpenDoor(nReader);
    {$ENDIF}
  end;  
end;

//Date: 2009-7-4
//Parm: 数据集;字段名;图像数据
//Desc: 将nImage图像存入nDS.nField字段
function SaveDBImage(const nDS: TDataSet; const nFieldName: string;
  const nImage: TGraphic): Boolean;
var nField: TField;
    nStream: TMemoryStream;
    nBuf: array[1..MAX_PATH] of Char;
begin
  Result := False;
  nField := nDS.FindField(nFieldName);
  if not (Assigned(nField) and (nField is TBlobField)) then Exit;

  nStream := nil;
  try
    if not Assigned(nImage) then
    begin
      nDS.Edit;
      TBlobField(nField).Clear;
      nDS.Post; Result := True; Exit;
    end;
    
    nStream := TMemoryStream.Create;
    nImage.SaveToStream(nStream);
    nStream.Seek(0, soFromEnd);

    FillChar(nBuf, MAX_PATH, #0);
    StrPCopy(@nBuf[1], nImage.ClassName);
    nStream.WriteBuffer(nBuf, MAX_PATH);

    nDS.Edit;
    nStream.Position := 0;
    TBlobField(nField).LoadFromStream(nStream);

    nDS.Post;
    FreeAndNil(nStream);
    Result := True;
  except
    if Assigned(nStream) then nStream.Free;
    if nDS.State = dsEdit then nDS.Cancel;
  end;
end;

{$IFDEF HKVDVR}
procedure WhenCaptureFinished(const nPtr: Pointer);
var nStr: string;
    nDS: TDataSet;
    nPic: TPicture;
    nDBConn: PDBWorker;
    nErrNum, nRID: Integer;
    nCapture: PCameraFrameCapture;
begin
  nDBConn := nil;
  {$IFDEF DEBUG}
  WriteHardHelperLog('WhenCaptureFinished进入.');
  {$ENDIF}

  nCapture :=  PCameraFrameCapture(nPtr);
  if not FileExists(nCapture.FCaptureName) then Exit;

  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
    if not Assigned(nDBConn) then
    begin
      WriteHardHelperLog('连接HM数据库失败(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nDBConn.FConn.BeginTrans;
    try
      nStr := MakeSQLByStr([
              SF('P_ID', nCapture.FCaptureFix),
              //SF('P_Name', nCapture.FCaptureName),
              SF('P_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Picture, '', True);
      //xxxxx

      if gDBConnManager.WorkerExec(nDBConn, nStr) < 1 then Exit;

      nStr := 'Select Max(%s) From %s';
      nStr := Format(nStr, ['R_ID', sTable_Picture]);
      with gDBConnManager.WorkerQuery(nDBConn, nStr) do
        nRID := Fields[0].AsInteger;

      nStr := 'Select P_Picture From %s Where R_ID=%d';
      nStr := Format(nStr, [sTable_Picture, nRID]);
      nDS := gDBConnManager.WorkerQuery(nDBConn, nStr);

      nPic := nil;
      try
        nPic := TPicture.Create;
        nPic.LoadFromFile(nCapture.FCaptureName);

        SaveDBImage(nDS, 'P_Picture', nPic.Graphic);
        FreeAndNil(nPic);
      except
        if Assigned(nPic) then nPic.Free;
      end;

      DeleteFile(nCapture.FCaptureName);
      nDBConn.FConn.CommitTrans;
    except
      nDBConn.FConn.RollbackTrans;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;
{$ENDIF}
end.

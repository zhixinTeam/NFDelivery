{*******************************************************************************
  作者: juner11212436@163.com 2020-6-17
  描述: 车辆预排队
*******************************************************************************}
unit UMgrPreQueue;

{$I Link.Inc}
interface

uses
  Windows, Classes, DB, SysUtils, SyncObjs, UMgrDBConn, UWaitItem, ULibFun,
  USysLoger, USysDB, UMgrRemoteVoice, UMgrVoiceNet, UMITConst, UFormCtrl;

type
  PLineItem = ^TLineItem;
  TLineItem = record
    FEnable     : Boolean;
    FLineID     : string;
    FLineGroup  : string;
    FName       : string;
    FStockNo    : string;
    FStockName  : string;
    FStockType  : string;
    FStockGroup : string;
    FPeerWeight : Integer;

    FQueueMax   : Integer;
    FIsVIP      : string;
    FIsValid    : Boolean;
    FIndex      : Integer;
    FTrucks     : TList;
    FRealCount  : Integer;     //实位车数
  end;//装车线

  PTruckItem = ^TTruckItem;
  TTruckItem = record
    FEnable     : Boolean;
    FTruck      : string;      //车牌号
    FStockNo    : string;      //物料号
    FStockName  : string;      //品种名
    FStockGroup : string;      //品种分组
    FLine       : string;      //装车线
    FLineGroup  : string;      //装车线分组
    FBill       : string;      //交货单
    FHKBills    : string;      //合卡单
    FInTime     : Int64;       //进队时间
    FInFact     : Boolean;     //是否进厂
    FInLade     : Boolean;     //是否提货
    FIsVIP      : string;      //特权车
    FIndex      : Integer;     //队列索引
    FIsReal     : Boolean;     //非虚位

    FQueueNum   : Integer;     //队列中车数
    FQueueStock : string;      //优先排队品种
    FQueueBills : string;      //有限排队单据
    FQueueCard  : string;      //当前车磁卡号
    FQueueNext  : string;      //后车牌号

    FValue      : Double;      //提货量
    FDai        : Integer;     //袋数
    FIsBuCha    : Boolean;     //是否补差
    FNormal     : Integer;     //正常总装
    FBuCha      : Integer;     //补差总装
    FStarted    : Boolean;     //是否启动
    FTruckEx    : string;      //格式化车牌
    FCusName    : string;
  end;

  TQueueParam = record
    FLoaded     : Boolean;     //载入标记
    FSaleAutoIn : Boolean;     //自动进厂
    FSaleAutoOut: Boolean;     //自动出厂
    FOtherAutoIn : Boolean;     //自动进厂
    FOtherAutoOut: Boolean;     //自动出厂
    FInTimeout  : Integer;     //进厂超时
    FNoDaiQueue : Boolean;     //袋装禁用队列
    FNoSanQueue : Boolean;     //散装禁用队列
    FDelayQueue : Boolean;     //延时排队(厂内)
    FPoundQueue : Boolean;     //延时排队(厂内依据过皮时间)
    FNetVoice   : Boolean;     //网络播放语音
    FDaiJudgeTunnel : Boolean; //袋装校验通道是否有效
    FSanJudgeTunnel : Boolean; //散装校验通道是否有效
  end;

  TStockMatchItem = record
    FGroup      : string;      //分组名称
    FMate       : string;      //物料号
    FName       : string;      //物料名
    FLineNo     : string;      //通道专用分组
    FPriority   : Integer;     //优先级,拼单时低级别物料不参与排队
  end;

  TTruckQueueManager = class;
  TTruckQueueDBReader = class(TThread)
  private
    FOwner: TTruckQueueManager;
    //拥有者
    FDBConn: PDBWorker;
    //数据对象
    FWaiter: TWaitObject;
    //等待对象
    FParam: TQueueParam;
    //队列参数
    FTruckChanged: Boolean;
    FTruckPool: array of TTruckItem;
    //车辆缓存
    FMatchItems: array of TStockMatchItem;
    //品种映射
  protected
    procedure Execute; override;
    //执行线程
    procedure ExecuteSQL(const nList: TStrings);
    //执行SQL语句
    procedure LoadStockMatck;
    function GetStockMatchGroup(const nStockNo: string;
      const nLineNo: string = ''; const nStockInLine: Boolean = True): string;
    function IsStockMatch(const nStockA, nStockB: string): Boolean; overload;
    function IsStockMatch(nTruck: PTruckItem; nLine: PLineItem): Boolean; overload;
    function IsStockMatch(const nStock: string; nLine: PLineItem): Boolean; overload;
    //品种分组映射
    function GetHighPriorityStock(const nStocks: TDynamicStrArray): string;
    //品种优先级
    procedure LoadQueueParam;
    //载入排队参数
    procedure LoadLines;
    //载入装车线
    procedure LoadTruckPool;
    procedure LoadTrucks;
    //载入车辆
    function MakeTruckInLine(const nTimes: Integer): Boolean;
    procedure MakePoolTruckIn(const nIdx: Integer; const nLine: PLineItem);
    //车辆入队
    procedure InvalidTruckOutofQueue;
    function IsLineTruckLeast(const nLine: PLineItem; nIsReal: Boolean;
      const nQueueStock: string = ''): Boolean;
    procedure SortTruckList(const nList: TList);
    //队列处理
    function RealTruckInQueue(const nTruck: string): Boolean;
    //队列有实位车辆
    function BillInPool(const nBill: string): Integer;
    function TruckFirst(const nTruck: string; const nValue: Double): Boolean;
    //车辆判定
    procedure TruckOutofQueue(const nTruck: string);
    //车辆出队
  public
    constructor Create(AOwner: TTruckQueueManager);
    destructor Destroy; override;
    //创建释放
    procedure Wakup;
    procedure StopMe;
    //启停线程
  end;

  TQueueChanged = procedure (const nManager: TTruckQueueManager);
  //队列变动事件

  TTruckQueueManager = class(TObject)
  private
    FDBName: string;
    //数据标识
    FLines: TList;
    //装车线
    FLineLoaded: Boolean;
    //是否已载入
    FLineChanged: Int64;
    //队列变动
    FSyncLock: TCriticalSection;
    //同步锁
    FDBReader: TTruckQueueDBReader;
    //数据读写
    FSQLList: TStrings;
    //SQL语句
    FLastQueueVoice: string;
    //队列内容
    FOnQueueChanged: TQueueChanged;
    //队列变动
  protected
    procedure FreeLine(nItem: PLineItem; nIdx: Integer = -1);
    procedure ClearLines(const nFree: Boolean);
    //释放资源
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure AddExecuteSQL(const nSQL: string);
    //添加SQL
    procedure StartQueue(const nDB: string);
    procedure StopQueue;
    //启停队列
    function IsTruckAutoIn(nIsSale: Boolean=True): Boolean;
    function IsTruckAutoOut(nIsSale: Boolean=True): Boolean;
    function IsDaiQueueClosed: Boolean;
    function IsSanQueueClosed: Boolean;
    function IsDelayQueue: Boolean;
    function IsNetPlayVoice: Boolean;
    function IsDaiJudgeTunnel: Boolean;
    function IsSanJudgeTunnel: Boolean;
    //队列参数
    procedure RefreshParam;
    procedure RefreshTrucks(const nLoadLine: Boolean);
    //刷新队列
    function GetLine(const nLineID: string): Integer;
    //装车线
    function TruckInQueue(const nTruck: string): Integer;
    function TruckInLine(const nTruck: string; const nList: TList): Integer;
    function BillInLine(const nBill: string; const nList: TList;
     const nSetStatus: Boolean = False; const nStatus: Boolean = False): Integer;
    //车辆检索
    procedure SendTruckQueueVoice(const nLocked: Boolean);
    //语音播发
    function GetVoiceTruck(const nSeparator: string;
     const nLocked: Boolean): string;
    //语音车辆
    function GetTruckTunnel(const nTruck: string): string;
    //车辆通道
    function TruckReInfactFobidden(const nTruck: string): Boolean;
    //禁止进厂
    function StockMatch(const nStockA, nStockB: string): Boolean; overload;
    function StockMatch(nTruck: PTruckItem; nLine: PLineItem): Boolean; overload;
    function StockMatch(const nStock: string; nLine: PLineItem): Boolean; overload;
    //品种分组映射
    property Lines: TList read FLines;
    property LineChanged: Int64 read FLineChanged;
    property SyncLock: TCriticalSection read FSyncLock;
    //属性相关
    property OnChanged: TQueueChanged read FOnQueueChanged write FOnQueueChanged;
    //事件相关

  end;

var
  gTruckPreQueueManager: TTruckQueueManager = nil;
  //全局使用

implementation

//Desc: 记录日志
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TTruckQueueManager, '装车预排队', nEvent);
end;

constructor TTruckQueueManager.Create;
begin
  FDBReader := nil;
  FLineLoaded := False;
  FLineChanged := GetTickCount;

  FLastQueueVoice := '';
  FSQLList := TStringList.Create;

  FLines := TList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor TTruckQueueManager.Destroy;
begin
  StopQueue;
  ClearLines(True);

  FSyncLock.Free;
  FSQLList.Free;
  inherited;
end;

//Desc: 释放装车线
procedure TTruckQueueManager.FreeLine(nItem: PLineItem; nIdx: Integer);
var i: Integer;
begin
  if Assigned(nItem) then
    nIdx := FLines.IndexOf(nItem);
  if nIdx < 0 then Exit;

  if (not Assigned(nItem)) and (nIdx > -1) then
    nItem := FLines[nIdx];
  if not Assigned(nItem) then Exit;

  for i:=nItem.FTrucks.Count - 1 downto 0 do
  begin
    Dispose(PTruckItem(nItem.FTrucks[i]));
    nItem.FTrucks.Delete(i);
  end;

  nItem.FTrucks.Free;
  Dispose(PLineItem(nItem));
  FLines.Delete(nIdx);
end;

procedure TTruckQueueManager.ClearLines(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FLines.Count - 1 downto 0 do
    FreeLine(nil, nIdx);
  if nFree then FreeAndNil(FLines);
end;

procedure TTruckQueueManager.StartQueue(const nDB: string);
begin
  FDBName := nDB;
  if not Assigned(FDBReader) then
    FDBReader := TTruckQueueDBReader.Create(Self);
  FDBReader.Wakup;
end;

procedure TTruckQueueManager.StopQueue;
begin
  if Assigned(FDBReader) then
  try
    FSyncLock.Enter;
    FDBReader.StopMe;
  finally
    FSyncLock.Leave;
  end;

  FDBReader := nil;
end;

//Desc: 车辆自动进厂
function TTruckQueueManager.IsTruckAutoIn(nIsSale: Boolean): Boolean;
begin
  Result := False;

  if Assigned(FDBReader) then
  try
    FSyncLock.Enter;
    case nIsSale of
    True:   Result := FDBReader.FParam.FSaleAutoIn;
    False:  Result := FDBReader.FParam.FOtherAutoIn;
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: 车辆自动出厂
function TTruckQueueManager.IsTruckAutoOut(nIsSale: Boolean): Boolean;
begin
  Result := False;

  if Assigned(FDBReader) then
  try
    FSyncLock.Enter;
    case nIsSale of
    True:   Result := FDBReader.FParam.FSaleAutoOut;
    False:  Result := FDBReader.FParam.FOtherAutoOut;
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: 关闭袋装队列
function TTruckQueueManager.IsDaiQueueClosed: Boolean;
begin
  Result := False;

  if Assigned(FDBReader) then
  try
    FSyncLock.Enter;
    Result := FDBReader.FParam.FNoDaiQueue;
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: 关闭散装队列
function TTruckQueueManager.IsSanQueueClosed: Boolean;
begin
  Result := False;

  if Assigned(FDBReader) then
  try
    FSyncLock.Enter;
    Result := FDBReader.FParam.FNoSanQueue;
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: 是否启用延迟队列(厂内模式)
function TTruckQueueManager.IsDelayQueue: Boolean;
begin
  Result := False;

  if Assigned(FDBReader) then
  try
    FSyncLock.Enter;
    Result := FDBReader.FParam.FDelayQueue;
  finally
    FSyncLock.Leave;
  end;
end;

function TTruckQueueManager.IsNetPlayVoice: Boolean;
begin
  Result := False;

  if Assigned(FDBReader) then
  try
    FSyncLock.Enter;
    Result := FDBReader.FParam.FNetVoice;
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: 袋装校验通道
function TTruckQueueManager.IsDaiJudgeTunnel: Boolean;
begin
  Result := False;

  if Assigned(FDBReader) then
  try
    FSyncLock.Enter;
    Result := FDBReader.FParam.FDaiJudgeTunnel;
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: 散装校验通道
function TTruckQueueManager.IsSanJudgeTunnel: Boolean;
begin
  Result := False;

  if Assigned(FDBReader) then
  try
    FSyncLock.Enter;
    Result := FDBReader.FParam.FSanJudgeTunnel;
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: 添加nSQL语句
procedure TTruckQueueManager.AddExecuteSQL(const nSQL: string);
begin
  FSyncLock.Enter;
  try
    FSQLList.Add(nSQL);
  finally
    FSyncLock.Leave;
  end;
end;

procedure TTruckQueueManager.RefreshParam;
begin
  if Assigned(FDBReader) then
  begin
    FDBReader.FParam.FLoaded := False;
    //修改载入标记
    FDBReader.Wakup;
  end;
end;

procedure TTruckQueueManager.RefreshTrucks(const nLoadLine: Boolean);
begin
  if Assigned(FDBReader) then
  begin
    if nLoadLine then
      FLineLoaded := False;
    FDBReader.Wakup;
  end;
end;

//Date: 2012-4-15
//Parm: 装车线表示
//Desc: 检索标识为nLineID的装车线(需加锁调用)
function TTruckQueueManager.GetLine(const nLineID: string): Integer;
var nIdx: Integer;
begin
  Result := -1;
              
  for nIdx:=FLines.Count - 1 downto 0 do
  if CompareText(nLineID, PLineItem(FLines[nIdx]).FLineID) = 0 then
  begin
    Result := nIdx;
    Break;
  end;
end;

//Date: 2012-4-14
//Parm: 车牌号;列表
//Desc: 判定nTruck是否在nList单道队列中(需加锁调用)
function TTruckQueueManager.TruckInLine(const nTruck: string;
  const nList: TList): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=nList.Count - 1 downto 0 do
  if CompareText(nTruck, PTruckItem(nList[nIdx]).FTruck) = 0 then
  begin
    Result := nIdx;
    Break;
  end;
end;

//Date: 2014-4-01
//Parm: 交货单;列表;设置状态;新状态
//Desc: 判定nBill是否在nList单道队列中(需加锁调用)
function TTruckQueueManager.BillInLine(const nBill: string;
  const nList: TList; const nSetStatus, nStatus: Boolean): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=nList.Count - 1 downto 0 do
  if CompareText(nBill, PTruckItem(nList[nIdx]).FBill) = 0 then
  begin
    Result := nIdx;
    if nSetStatus then
      PTruckItem(nList[nIdx]).FEnable := nStatus;
    Break;
  end;
end;

//Date: 2012-4-14
//Parm: 车牌号
//Desc: 判断nTruck是否在队列中(需加锁调用)
function TTruckQueueManager.TruckInQueue(const nTruck: string): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=FLines.Count - 1 downto 0 do
  if TruckInLine(nTruck, PLineItem(FLines[nIdx]).FTrucks) > -1 then
  begin
    Result := nIdx;
    Break;
  end;
end;

//Desc: 语音播发未进厂车辆
procedure TTruckQueueManager.SendTruckQueueVoice(const nLocked: Boolean);
var nStr: string;
begin
  if nLocked then SyncLock.Enter;
  try
    nStr := GetVoiceTruck(#9, False);
    if nStr = '' then Exit;
    
    nStr := #9 + nStr + #9;
    //truck flag

    if nStr <> FLastQueueVoice then
    begin
      if IsNetPlayVoice and Assigned(gNetVoiceHelper) then
           gNetVoiceHelper.PlayVoice(nStr)
      else gVoiceHelper.PlayVoice(nStr);
      FLastQueueVoice := nStr;
    end;
  finally
    if nLocked then SyncLock.Leave;
  end;
end;

//Date: 2012-8-24
//Parm: 分隔符;是否锁定
//Desc: 获取语音播发的车辆列表
function TTruckQueueManager.GetVoiceTruck(const nSeparator: string;
  const nLocked: Boolean): string;
var i,nIdx: Integer;
    nList: TStrings;
    nLine: PLineItem;
    nTruck: PTruckItem;
begin
  nList := nil;
  if nLocked then SyncLock.Enter;
  try
    Result := '';
    nList := TStringList.Create;

    for nIdx:=0 to Lines.Count - 1 do
    begin
      nLine := Lines[nIdx];
      for i:=0 to nLine.FTrucks.Count - 1 do
      begin
        nTruck := nLine.FTrucks[i];
        if (not nTruck.FInFact) or (IsDelayQueue and (not nTruck.FInLade)) then
        begin
          if nList.IndexOf(nTruck.FTruck) < 0 then //一车多单时避免重复
          begin
            nList.Add(UpperCase(nTruck.FTruck));
            Result := Result + nTruck.FTruck + nSeparator;
          end;
        end;
      end;
    end;

    i := Length(Result);
    if i > 0 then
    begin
      nIdx := Length(nSeparator);
      Result := Copy(Result, 1, i - nIdx);
    end;
  finally
    nList.Free;
    if nLocked then SyncLock.Leave;
  end;
end;

//Date: 2012-9-1
//Parm: 车牌号
//Desc: 获取nTruck所在的通道号
function TTruckQueueManager.GetTruckTunnel(const nTruck: string): string;
var nIdx: Integer;
begin
  SyncLock.Enter;
  try
    nIdx := TruckInQueue(nTruck);
    if nIdx < 0 then
         Result := ''
    else Result := PLineItem(FLines[nIdx]).FLineID;

    WriteLog(Format('车辆[ %s ]选择通道[ %d:%s ]', [nTruck, nIdx, Result]));
    //display log
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2013-1-22
//Parm: 车牌号
//Desc: 判断nTruck是否允许二次进厂
function TTruckQueueManager.TruckReInfactFobidden(const nTruck: string): Boolean;
var i,nIdx: Integer;
    nPTruck: PTruckItem;
begin
  Result := True;
  if Assigned(FDBReader) then
  try
    SyncLock.Enter;
    //locked

    for i:=FLines.Count - 1 downto 0 do
    begin
      nIdx := TruckInLine(nTruck, PLineItem(FLines[i]).FTrucks);
      if nIdx < 0 then Continue;

      nPTruck := PLineItem(FLines[i]).FTrucks[nIdx];
      Result := (GetTickCount - nPTruck.FInTime) <
                (FDBReader.FParam.FInTimeout * 60 * 1000);
      //车辆未超时

      if not Result then
        WriteLog(Format('车辆[ %s ]进厂超时,已阻止.', [nTruck]));
      Exit;
    end;
  finally
    SyncLock.Leave;
  end;
end;

//Desc: 判定nStockA是否与nStockB物料号匹配
function TTruckQueueManager.StockMatch(const nStockA,nStockB: string): Boolean;
begin
  Result := False;

  if Assigned(FDBReader) then
  try
    FSyncLock.Enter;
    Result := FDBReader.IsStockMatch(nStockA, nStockB);
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: 判定nTruck是否与nLine物料匹配
function TTruckQueueManager.StockMatch(nTruck: PTruckItem;
  nLine: PLineItem): Boolean;
begin
  Result := False;

  if Assigned(FDBReader) then
  try
    FSyncLock.Enter;
    Result := FDBReader.IsStockMatch(nTruck, nLine);
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: 判定nStock是否与nLine物料匹配
function TTruckQueueManager.StockMatch(const nStock: string;
  nLine: PLineItem): Boolean;
begin
  Result := False;

  if Assigned(FDBReader) then
  try
    FSyncLock.Enter;
    Result := FDBReader.IsStockMatch(nStock, nLine);
  finally
    FSyncLock.Leave;
  end;
end;

//------------------------------------------------------------------------------
constructor TTruckQueueDBReader.Create(AOwner: TTruckQueueManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  with FParam do
  begin
    FLoaded := False;
    FInTimeout := 10;
    FSaleAutoIn := False;
    FSaleAutoOut:= False;
    FOtherAutoIn := False;
    FOtherAutoOut:= False;
    
    FNoDaiQueue := False;
    FNoSanQueue := False;
    FDelayQueue := False;

    FNetVoice   := False;

    FDaiJudgeTunnel := False;
    FSanJudgeTunnel := False;
  end;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 20 * 1000;
end;

destructor TTruckQueueDBReader.Destroy;
begin
  FWaiter.Free;
  inherited;
end;

procedure TTruckQueueDBReader.Wakup;
begin
  FWaiter.Wakeup;
end;

procedure TTruckQueueDBReader.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TTruckQueueDBReader.Execute;
var nErr: Integer;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    FDBConn := gDBConnManager.GetConnection(FOwner.FDBName, nErr);
    try
      if not Assigned(FDBConn) then
      begin
        WriteLog('DB connection is null.');
        Continue;
      end;

      if not FDBConn.FConn.Connected then
        FDBConn.FConn.Connected := True;
      //conn db

      FOwner.FSyncLock.Enter;
      try
        ExecuteSQL(FOwner.FSQLList);
        LoadStockMatck;
        //match itme list

        LoadQueueParam;
        FTruckChanged := False;

        LoadLines;
        LoadTrucks;

        if FTruckChanged then
          FOwner.SendTruckQueueVoice(False);
        //voice
      finally
        FOwner.FSyncLock.Leave;
      end;
    finally
      gDBConnManager.ReleaseConnection(FDBConn);
    end;

    if FTruckChanged and Assigned(FOwner.FOnQueueChanged) then
      FOwner.FOnQueueChanged(FOwner);
    //event
  except
    on E: Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//Desc: 执行SQL语句
procedure TTruckQueueDBReader.ExecuteSQL(const nList: TStrings);
var nIdx: Integer;
begin
  for nIdx:=nList.Count - 1 downto 0 do
  begin
    gDBConnManager.WorkerExec(FDBConn, nList[nIdx]);
    nList.Delete(nIdx);
  end;
end;

//Date: 2012-10-21
//Desc: 载入品种分组映射表
procedure TTruckQueueDBReader.LoadStockMatck;
var nStr: string;
    nIdx: Integer;
    nUseLine,nUsePriority: Boolean;
begin
  if FOwner.FLineLoaded then Exit;
  {$IFDEF DEBUG}
  WriteLog('刷新品种映射关系.');
  {$ENDIF}

  SetLength(FMatchItems, 0);
  nStr := 'Select * From %s Where M_Status=''%s''';
  nStr := Format(nStr, [sTable_StockMatch, sFlag_Enabled]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nUseLine := Assigned(FindField('M_LineNo'));
    //是否使用通道分组

    nUsePriority := Assigned(FindField('M_Priority'));
    //是否使用物料优先级

    SetLength(FMatchItems, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    begin
      with FMatchItems[nIdx] do
      begin
        FGroup := FieldByName('M_Group').AsString;
        FMate  := FieldByName('M_ID').AsString;
        FName  := FieldByName('M_Name').AsString;

        if nUseLine then
             FLineNo := FieldByName('M_LineNo').AsString
        else FLineNo := '';

        if nUsePriority then
             FPriority := FieldByName('M_Priority').AsInteger
        else FPriority := 0;
      end;

      Inc(nIdx);
      Next;
    end;
  end;
end;

//Date: 2012-10-21
//Parm: 品种编号;装车线;装车线包含该物料
//Desc: 获取nStockNo在品种映射关系中所在的分组
function TTruckQueueDBReader.GetStockMatchGroup(const nStockNo: string;
  const nLineNo: string; const nStockInLine: Boolean): string;
var nIdx: Integer;
begin
  Result := '';
  if nLineNo <> '' then
  begin
    if nStockInLine then
    begin
      for nIdx:=Low(FMatchItems) to High(FMatchItems) do
       with FMatchItems[nIdx] do
        if (FLineNo = nLineNo) and (FMate = nStockNo) then
        begin
          Result := FGroup;
          Exit;
        end;
      //装车线支持该品种
    end else
    begin
      for nIdx:=Low(FMatchItems) to High(FMatchItems) do
       with FMatchItems[nIdx] do
        if FLineNo = nLineNo then
        begin
          Result := FGroup;
          Exit;
        end;
      //装车线专用分组
    end;
  end;

  for nIdx:=Low(FMatchItems) to High(FMatchItems) do
   with FMatchItems[nIdx] do
    if (FLineNo = '') and (FMate = nStockNo) then
    begin
      Result := FGroup;
      Exit;
    end;
  //普通物料分组
end;

//Date: 2012-10-21
//Parm: 品种1;品种2
//Desc: 检测nStockA是否与nStockB的品种匹配
function TTruckQueueDBReader.IsStockMatch(const nStockA, nStockB: string): Boolean;
var nStr: string;
begin
  Result := nStockA = nStockB;
  if not Result then
  begin
    nStr := GetStockMatchGroup(nStockA);
    Result := (nStr <> '') and (nStr = GetStockMatchGroup(nStockB));
  end;
end;

//Date: 2012-10-21
//Parm: 车辆;装车线
//Desc: 检测nTruck是否与nLine的品种匹配
function TTruckQueueDBReader.IsStockMatch(nTruck: PTruckItem;
  nLine: PLineItem): Boolean;
begin
  Result := nTruck.FStockNo = nLine.FStockNo;
  if not Result then
  begin
    Result := (nTruck.FStockGroup <> '') and
              (nTruck.FStockGroup = nLine.FStockGroup);
    //xxxxx

    if not Result then
    begin
      Result := (nLine.FStockGroup <> '') and
        (nLine.FStockGroup = GetStockMatchGroup(nTruck.FStockNo, nLine.FLineID));
      //xxxxx
    end;
  end;
end;

//Date: 2012-10-21
//Parm: 品种;装车线
//Desc: 检测nStock是否与nLine的品种匹配
function TTruckQueueDBReader.IsStockMatch(const nStock: string;
  nLine: PLineItem): Boolean;
begin
  Result := nStock = nLine.FStockNo;
  if not Result then
  begin
    Result := (nLine.FStockGroup <> '') and
              (nLine.FStockGroup = GetStockMatchGroup(nStock, nLine.FLineID));
    //xxxxx
  end;
end;

//Date: 2017-08-11
//Parm: 品种组
//Desc: 获取能同时装nStocks分组中,级别最高的物料号
function TTruckQueueDBReader.GetHighPriorityStock(
  const nStocks: TDynamicStrArray): string;
var i,j,nIdx,nInt: Integer;
begin
  Result := '';
  //default

  for i:=Low(FMatchItems) to High(FMatchItems) do
  begin
    if FMatchItems[i].FMate <> nStocks[0] then Continue;
    //品种不匹配

    nInt := 1;
    //第一个品种已匹配

    for nIdx:=Length(nStocks)-1 downto 1 do
    begin
      for j:=Low(FMatchItems) to High(FMatchItems) do
      begin
        if FMatchItems[j].FGroup <> FMatchItems[i].FGroup then Continue;
        //当前分组(i)不匹配

        if FMatchItems[j].FMate = nStocks[nIdx] then
        begin
          Inc(nInt);
          Break;
        end; //该分组(i)支持当前品种(nIdx)
      end;
    end;

    if nInt <> Length(nStocks) then Continue;
    //当前分组(i)不支持全部品种

    nInt   := FMatchItems[i].FPriority;
    Result := FMatchItems[i].FMate;

    for j:=Low(FMatchItems) to High(FMatchItems) do
    begin
      if Length(nStocks) < 2 then Break;
      //单品种无需判断同组优先级

      if FMatchItems[j].FGroup <> FMatchItems[i].FGroup then Continue;
      //当前分组(i)不匹配

      if (FMatchItems[j].FPriority = nInt) and (nInt > 0) then
      begin
        if Pos(FMatchItems[j].FMate, Result) < 1 then
          Result := Result + ',' + FMatchItems[j].FMate;
        //同优先级
      end;

      if FMatchItems[j].FPriority > nInt then
      begin
        nInt   := FMatchItems[j].FPriority;
        Result := FMatchItems[j].FMate;
      end; //当前分组(i)优先级最高品种
    end;

    if nInt = 0 then
      Result := '';
    //品种优先级一样,则不予处理
  end;
end;

//Desc: 载入排队参数
procedure TTruckQueueDBReader.LoadQueueParam;
var nStr: string;
begin
  if FParam.FLoaded then Exit;
  nStr := 'Select D_Value,D_Memo From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    FParam.FLoaded := True;
    First;

    while not Eof do
    begin
      if CompareText(Fields[1].AsString, sFlag_AutoIn) = 0 then
        FParam.FSaleAutoIn := Fields[0].AsString = sFlag_Yes;
      //xxxxx

      if CompareText(Fields[1].AsString, sFlag_AutoOut) = 0 then
        FParam.FSaleAutoOut := Fields[0].AsString = sFlag_Yes;
      //xxxxx

      if CompareText(Fields[1].AsString, sFlag_OtherAutoIn) = 0 then
        FParam.FOtherAutoIn := Fields[0].AsString = sFlag_Yes;
      //xxxxx

      if CompareText(Fields[1].AsString, sFlag_OtherAutoOut) = 0 then
        FParam.FOtherAutoOut := Fields[0].AsString = sFlag_Yes;
      //xxxxx

      if CompareText(Fields[1].AsString, sFlag_InTimeout) = 0 then
        FParam.FInTimeout := Fields[0].AsInteger;
      //xxxxx

      if CompareText(Fields[1].AsString, sFlag_NoDaiQueue) = 0 then
        FParam.FNoDaiQueue := Fields[0].AsString = sFlag_Yes;
      //xxxxx

      if CompareText(Fields[1].AsString, sFlag_NoSanQueue) = 0 then
        FParam.FNoSanQueue := Fields[0].AsString = sFlag_Yes;
      //xxxxx

      if CompareText(Fields[1].AsString, sFlag_DelayQueue) = 0 then
        FParam.FDelayQueue := Fields[0].AsString = sFlag_Yes;

      if CompareText(Fields[1].AsString, sFlag_PoundQueue) = 0 then
        FParam.FPoundQueue := Fields[0].AsString = sFlag_Yes;

      if CompareText(Fields[1].AsString, sFlag_NetPlayVoice) = 0 then
        FParam.FNetVoice := Fields[0].AsString = sFlag_Yes;
      //NetVoice

      if CompareText(Fields[1].AsString, sFlag_DaiJudgeTunnel) = 0 then
        FParam.FDaiJudgeTunnel := Fields[0].AsString = sFlag_Yes;
      //xxxxx

      if CompareText(Fields[1].AsString, sFlag_SanJudgeTunnel) = 0 then
        FParam.FSanJudgeTunnel := Fields[0].AsString = sFlag_Yes;
      //xxxxx
      Next;
    end;
  end;
end;

//Desc: 载入装车线列表
procedure TTruckQueueDBReader.LoadLines;
var nStr: string;
    nLine: PLineItem;
    i,nIdx,nInt: Integer;
begin
  nStr := 'Select * From %s where D_Name =''%s'' Order By D_Index ASC';
  nStr := Format(nStr, [sTable_SysDict, sFlag_PreLine]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr),FOwner do
  begin
    FLineLoaded := True;
    if RecordCount < 1 then Exit;

    for nIdx:=FLines.Count - 1 downto 0 do
      PLineItem(FLines[nIdx]).FEnable := False;
    //xxxxx

    FLineChanged := GetTickCount;
    First;

    while not Eof do
    begin
      nStr := FieldByName('D_Memo').AsString;
      nIdx := GetLine(nStr);

      if nIdx < 0 then
      begin
        New(nLine);
        FLines.Add(nLine);
        nLine.FTrucks := TList.Create;
      end else nLine := FLines[nIdx];

      with nLine^ do
      begin
        FEnable     := True;
        FLineID     := FieldByName('D_Memo').AsString;
        FName       := FieldByName('D_Desc').AsString;

        FLineGroup  := '';

        FStockNo    := FieldByName('D_ParamB').AsString;
        FStockName  := '';
        FStockType  := '';
        FStockGroup := '';
        FPeerWeight := 50;

        FQueueMax   := 200;
        FIsVIP      := 'C';
        FIsValid    := FieldByName('D_Value').AsString <> sFlag_No;
        FIndex      := FieldByName('D_Index').AsInteger;
      end;

      Next;
    end;

    for nIdx:=FLines.Count - 1 downto 0 do
    begin
      if not PLineItem(FLines[nIdx]).FEnable then
        FreeLine(nil, nIdx);
      //xxxxx
    end;

    for nIdx:=0 to FLines.Count - 1 do
    begin
      nLine := FLines[nIdx];
      nInt := -1;

      for i:=nIdx+1 to FLines.Count - 1 do
      if PLineItem(FLines[i]).FIndex < nLine.FIndex then
      begin
        nInt := i;
        nLine := FLines[i];
        //find the mininum
      end;

      if nInt > -1 then
      begin
        FLines[nInt] := FLines[nIdx];
        FLines[nIdx] := nLine;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2014-03-31
//Parm: 车牌号
//Desc: 检索当前车辆队列中是否有nTruck,且占实位
function TTruckQueueDBReader.RealTruckInQueue(const nTruck: string): Boolean;
var i,j: Integer;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
begin
  Result := False;

  for i:=FOwner.FLines.Count - 1 downto 0 do
  begin
    nPLine := FOwner.FLines[i];
    //line item

    for j:=nPLine.FTrucks.Count - 1 downto 0 do
    begin
      nPTruck := nPLine.FTrucks[j];
      //truck item

      if nPTruck.FIsReal and (CompareText(nTruck, nPTruck.FTruck) = 0) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

//Desc: 读取车辆队列到缓存列表
procedure TTruckQueueDBReader.LoadTruckPool;
var nStr: string;
    nIdx: Integer;
    nTruckEx: string;
begin
//  if (FParam.FPoundQueue) and (FParam.FDelayQueue) then
//  begin                                      //增加厂内依据过皮时间排队 20131114
//    nStr := 'Select * From %s  ' +
//            'Where (IsNull(T_Valid,''%s'')<>''%s'' And ' +
//            ' IsNull(T_PDate,'''')<>'''') Or (T_VIP=''%s'') ' +
//            'Order By T_Index ASC,T_PDate ASC,T_InTime ASC';
//    nStr := Format(nStr, [sTable_ZTTrucks, sFlag_Yes, sFlag_No, sFlag_TypeShip]);
//  end else
  begin
    nStr := 'Select * From %s Where ( (IsNull(T_Valid,''%s'')<>''%s'') Or ' +
            ' (T_VIP=''%s'') ) and T_InQueue is Null ' +
            'Order By T_Index ASC,T_InTime ASC';
    nStr := Format(nStr, [sTable_ZTTrucks, sFlag_Yes, sFlag_No, sFlag_TypeShip]);
  end;

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      SetLength(FTruckPool, 0);
      Exit;
    end;

    SetLength(FTruckPool, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    begin
      with FTruckPool[nIdx] do
      begin
        FEnable     := True;
        FTruck      := FieldByName('T_Truck').AsString;
        FStockNo    := FieldByName('T_StockNo').AsString;
        FStockGroup := GetStockMatchGroup(FStockNo);

        FLine       := FieldByName('T_Line').AsString;

        FLineGroup  := '';
        {$IFDEF LineGroup}
        FLineGroup  := FieldByName('T_LineGroup').AsString;
        {$ELSE}
          {$IFDEF AutoGetLineGroup}
          FLineGroup  := FieldByName('T_LineGroup').AsString;
          {$ENDIF}
        {$ENDIF}

        FBill       := FieldByName('T_Bill').AsString;
        FHKBills    := FieldByName('T_HKBills').AsString;
        FIsVIP      := FieldByName('T_VIP').AsString;

        FInFact     := FieldByName('T_InFact').AsString <> '';
        FInLade     := FieldByName('T_InLade').AsString <> '';

        FIndex      := FieldByName('T_Index').AsInteger;
        if FIndex < 1 then FIndex := MaxInt;

        FValue      := Float2Float(FieldByName('T_Value').AsFloat, cPrecision);
        FNormal     := FieldByName('T_Normal').AsInteger;
        FBuCha      := FieldByName('T_BuCha').AsInteger;

        FIsBuCha    := FNormal > 0;
        FDai        := 0;

        FQueueNum   := 0;
        FQueueStock := '';
        FQueueBills := AdjustListStrFormat(FHKBills, '''', True, '.');
        FQueueBills := StringReplace(FQueueBills, '.', ',', [rfReplaceAll]);
        //参与并单的订单列表

        FQueueCard  := '';
        FQueueNext  := '';

        nTruckEx := '';

        FTruckEx := nTruckEx + FieldByName('T_Truck').AsString;
      end;

      Inc(nIdx);
      Next;
    end; //可进厂和已在队列车辆缓冲池
  end;
end;

//Desc: Desc: 载入装车队列
procedure TTruckQueueDBReader.LoadTrucks;
var i,nIdx: Integer;
begin
  LoadTruckPool;
  //1.载入车辆到缓存

  InvalidTruckOutofQueue;
  //2.将无效车辆移出队列

  nIdx := 0;
  for i:=Low(FTruckPool) to High(FTruckPool) do
  begin
    if FTruckPool[i].FEnable then
    begin
      Inc(nIdx); Break;
    end;
  end;

  if nIdx < 1 then Exit;
  //3.缓冲内无新车辆处理

  for nIdx:=Low(FTruckPool) to High(FTruckPool) do
  with FTruckPool[nIdx] do
  begin
    FIsReal := False;
    if not FEnable then continue;

    FIsReal := TruckFirst(FTruck, FValue);
    //大吨原则设置设置车辆实位、虚位

    if FIsReal then
      FIsReal := not RealTruckInQueue(FTruck);
    //车辆已进队且为实位,则缓冲中全为虚位,避免重复占位
  end;
  //4.设定缓冲内车辆虚位标记

  nIdx := 2;
  //第二轮扫描已进厂车辆

  while True do
  begin
    if not MakeTruckInLine(nIdx) then
    begin
      if nIdx = 2 then
           Inc(nIdx)
      else Break;
    end;
  end;
  //5.将缓冲车辆加入符合条件的队列

  //for nIdx:=FOwner.FLines.Count - 1 downto 0 do
  //  SortTruckList(PLineItem(FOwner.FLines[nIdx]).FTrucks);
  //6.车辆排序
end;

//Date: 2014-04-01
//Parm: 调用次数
//Desc: 将TruckPool中车辆按业务逻辑进队
function TTruckQueueDBReader.MakeTruckInLine(const nTimes: Integer): Boolean;
var i,nIdx: Integer; nStr: string;
    B : Boolean;
begin
  Result := False;

  //有通道号的车辆优先进队,不检查通道状态、队容、品种匹配.
  if nTimes = 1 then
  begin
    for nIdx:=0 to FOwner.FLines.Count - 1 do
    with PLineItem(FOwner.Lines[nIdx])^,FOwner do
    begin
      for i:=Low(FTruckPool) to High(FTruckPool) do
      begin
        if not FTruckPool[i].FEnable then Continue;
        //0.车辆无需处理

        {$IFDEF AutoGetLineGroup}
        {$IFNDEF NoPointLine}
        if FTruckPool[i].FIsReal and (FRealCount >= FQueueMax) then Continue;
        //实位车辆,队列已满
        {$ENDIF}
        {$ENDIF}

        if FTruckPool[i].FLine <> FLineID then Continue;
        //1.车辆和通道标识号不匹配

        if BillInLine(FTruckPool[i].FBill, FTrucks, True) >= 0 then Continue;
        //2.交货单已经在队列中

        MakePoolTruckIn(i, FOwner.Lines[nIdx]);
        //本队列车辆优先,全部进队
        Result := True;
      end;
    end;
  end;

  //普通车辆进队,已进厂的交货单优先
  for nIdx:=0 to FOwner.FLines.Count - 1 do
  with PLineItem(FOwner.Lines[nIdx])^,FOwner do
  begin
    if not FIsValid then Continue;
    //队列关闭

    for i:=Low(FTruckPool) to High(FTruckPool) do
    begin
      if not FTruckPool[i].FEnable then Continue;
      //0.车辆无需处理

      if FTruckPool[i].FIsReal and (FRealCount >= FQueueMax) then Continue;
      //2.实位车辆,队列已满

      if Pos(FTruckPool[i].FStockNo, FStockNo) <= 0 then Continue;
      //3.交货单与通道品种不匹配

      if (FTruckPool[i].FLineGroup <> '') and (FTruckPool[i].FLineGroup <> 'Z') then
      begin
        nStr := FLineGroup;
        if (nStr <> '') and (nStr <> 'Z') and
           (nStr <> FTruckPool[i].FLineGroup) then Continue;
      end;
      //7.车辆指定通道类型不匹配
      WriteLog('预排队车辆进队成功:'+FTruckPool[i].FTruck+','+FTruckPool[i].FStockNo+
               ',当前装车线:'+FLineID);
      MakePoolTruckIn(i, FOwner.Lines[nIdx]);
      //车辆进队列

      Result := True;
      Break;
    end;
  end;
end;

//Date: 2012-4-24
//Parm: 待入队车辆索引;队列
//Desc: 将车辆缓冲nIdx车辆排入nLine道
procedure TTruckQueueDBReader.MakePoolTruckIn(const nIdx: Integer;
 const nLine: PLineItem);
var nStr: string;
    nTruck: PTruckItem;
    nWXZhuID, nOrder, nMsg: string;
    nExit: Boolean;
begin
  New(nTruck);
  nLine.FTrucks.Add(nTruck);
  nTruck^ := FTruckPool[nIdx];

  nTruck.FInTime := GetTickCount;
  nTruck.FStarted := False;

  FTruckPool[nIdx].FEnable := False;
  FTruckChanged := True;
  FOwner.FLineChanged := GetTickCount;

  if nTruck.FIsReal then
    nLine.FRealCount := nLine.FRealCount + 1;
  //实位车辆计数

  {$IFDEF DEBUG}
  WriteLog(Format('车辆[ %s ]进[ %s ]队.', [nTruck.FTruck, nLine.FName]));
  {$ENDIF}
end;

//Date: 2012-4-15
//Parm: 车牌号;提货量
//Desc: nTruck车辆是否可以进厂提交货量为nValue的品种
function TTruckQueueDBReader.TruckFirst(const nTruck: string;
  const nValue: Double): Boolean;
var nIdx: Integer;
begin
  Result := True;

  for nIdx:=Low(FTruckPool) to High(FTruckPool) do
  with FTruckPool[nIdx] do
  begin
    if FEnable and (CompareText(nTruck, FTruck) = 0) and
       FloatRelation(FValue, nValue, rtGreater, 1000) then
    begin
      Result := False;
      Exit;
    end; //有其它单提货量更大     
  end;
end;

//Date: 2012-4-15
//Parm: 车牌号
//Desc: 设置nTruck的出队标记
procedure TTruckQueueDBReader.TruckOutofQueue(const nTruck: string);
var nStr: string;
begin
  nStr := 'Update %s Set T_Valid=''%s'' Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_ZTTrucks, sFlag_No, nTruck]);
  gDBConnManager.WorkerExec(FDBConn, nStr);
end;

//Date: 2014-04-01
//Parm: 交货单
//Desc: 检索nBill在车辆缓冲池中的索引
function TTruckQueueDBReader.BillInPool(const nBill: string): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=Low(FTruckPool) to High(FTruckPool) do
  if CompareText(nBill, FTruckPool[nIdx].FBill) = 0 then
  begin
    if FTruckPool[nIdx].FEnable then
      Result := nIdx;
    Break;
  end;
end;

//Date: 2012-4-15
//Desc: 将无效车辆(已出厂,进厂超时)移出队列
procedure TTruckQueueDBReader.InvalidTruckOutofQueue;
var i,j,nIdx: Integer;
    nLine: PLineItem;
    nTruck: PTruckItem;
    nStocks: TDynamicStrArray;

    procedure AddStockList(const nStock: string);
    var nLen: Integer;
    begin
      for nLen:=Low(nStocks) to High(nStocks) do
        if nStocks[nLen] = nStock then Exit;
      //has exists
      
      nLen := Length(nStocks);
      SetLength(nStocks, nLen + 1);
      nStocks[nLen] := nStock;
    end;
begin
  {$IFDEF StockPriorityInQueue}
  for i:=Low(FTruckPool) to High(FTruckPool) do
  with FTruckPool[i] do
  begin
    if FQueueNum > 0 then Continue;
    //已处理

    SetLength(nStocks, 0);
    AddStockList(FStockNo);
    FQueueNum := 1;

    for j:=i+1 to High(FTruckPool) do
    if CompareText(FTruck, FTruckPool[j].FTruck) = 0 then
    begin
      Inc(FQueueNum);
      AddStockList(FTruckPool[j].FStockNo);
      FQueueBills := FQueueBills + ',' +  FTruckPool[j].FQueueBills;
    end; //同车牌交货单个数

    //if FQueueNum < 2 then Continue;
    //单张交货单,无需处理物料优先级

    FQueueStock := GetHighPriorityStock(nStocks);
    if FQueueStock <> '' then
      FEnable := (FLine <> '') or (Pos(FStockNo, FQueueStock) > 0);
    //启用高优先级物料

    for j:=i+1 to High(FTruckPool) do
    if CompareText(FTruck, FTruckPool[j].FTruck) = 0 then
    begin
      FTruckPool[j].FQueueNum := FQueueNum;
      FTruckPool[j].FQueueStock := FQueueStock;
      FTruckPool[j].FQueueBills := FQueueBills;
      
      if FQueueStock <> '' then
        FTruckPool[j].FEnable := (FTruckPool[j].FLine <> '') or
                                 (Pos(FTruckPool[j].FStockNo, FQueueStock) > 0);
      //启用高优先级物料
    end;
  end;
  {+++++++++++++++++++++++++++++++++++++ 注意 ++++++++++++++++++++++++++++++++++
     品种优先级排队的逻辑,有以下4点:
     1.调度队列里,同一辆车有多个品种(混装),单一品种不存在优先级问题.
     2.该车的多个品种,可以在同一道混装.即:某个分组可以支持该车的所有品种.
     3.该车的多个品种,优先级不同.即: 某个品种优先级最高,该车按该品种排队.
     4.按最高优先级排队时,严格匹配物料号.即: 只匹配当前物料,不考虑通道分组.
  -----------------------------------------------------------------------------}
  {$ENDIF}
  
  with FOwner do
  begin
    for nIdx:=FLines.Count - 1 downto 0 do
     with PLineItem(FLines[nIdx])^ do
      for i:=FTrucks.Count - 1 downto 0 do
       PTruckItem(FTrucks[i]).FEnable := False;
    //xxxxx
  end;

  for nIdx:=FOwner.FLines.Count - 1 downto 0 do
  begin
    nLine := FOwner.FLines[nIdx];
    for i:=nLine.FTrucks.Count - 1 downto 0 do
    begin
      nTruck := nLine.FTrucks[i];
      j := BillInPool(nTruck.FBill);
      if j < 0 then Continue;

      if (FTruckPool[j].FLine <> '') and
         (FTruckPool[j].FLine <> nLine.FLineID) then Continue;
      //车辆被定道到其它位置

      if CompareText(nTruck.FTruck, FTruckPool[j].FTruck) <> 0 then Continue;
      //交货单改车牌号

      with FTruckPool[j] do
      begin
        if (FInFact or ((GetTickCount - nTruck.FInTime) <
           FParam.FInTimeout * 60 * 1000)) or (FIsVIP = sFlag_TypeShip) then
        begin
          if FInFact and (not nTruck.FInFact) then
            FTruckChanged := True;
          //xxxxx

          nTruck.FEnable := True;
          nTruck.FInFact := FInFact;
          nTruck.FInLade := FInLade;

          nTruck.FIsVIP := FIsVIP;
          nTruck.FIndex := FIndex;

          nTruck.FValue := FValue;
          if nLine.FPeerWeight > 0 then
          begin
            if IsNumber(FloatToStr(FValue), False) then
              nTruck.FDai := Trunc(FValue * 1000 / nLine.FPeerWeight)
            else
              nTruck.FDai := Round(FValue * 1000 / nLine.FPeerWeight);
          //xxxxx
          end;

          nTruck.FBill  := FBill;
          nTruck.FHKBills := FHKBills;

          if FIsVIP = sFlag_TypeShip then
            nTruck.FInFact := True;
          //进队视为进厂

          nTruck.FQueueNum   := FQueueNum;
          nTruck.FQueueStock := FQueueStock;
          nTruck.FQueueBills := FQueueBills;
          //更新物料优先排队参数
        end else
        begin
          {$IFDEF DEBUG}
          WriteLog(Format('车辆[ %s ]出队.', [nTruck.FTruck]));
          {$ENDIF}

          TruckOutofQueue(nTruck.FTruck);
          //未进厂车辆超时
        end;

        FTruckPool[j].FEnable := False;
      end;
    end;
  end;
  //判断队列车辆是否有效

  for nIdx:=FOwner.FLines.Count - 1 downto 0 do
  begin
    nLine := FOwner.FLines[nIdx];
    nLine.FRealCount := 0;

    for i:=nLine.FTrucks.Count - 1 downto 0 do
    begin
      nTruck := nLine.FTrucks[i];
      if nTruck.FEnable then Continue;

      {$IFDEF DEBUG}
      WriteLog(Format('车辆[ %s ]无效出队.', [nTruck.FTruck]));
      {$ENDIF}
      
      Dispose(nTruck);
      nLine.FTrucks.Delete(i);

      FTruckChanged := True;
      FOwner.FLineChanged := GetTickCount;
    end; //清理无效车辆

    for i:=nLine.FTrucks.Count - 1 downto 0 do
    begin
      nTruck := nLine.FTrucks[i];
      if nTruck.FIsReal then
        nLine.FRealCount := nLine.FRealCount + 1;
      //重新计算队列中的实位车辆
    end;
  end;
end;

//Date: 2012-4-25
//Parm: 装车线;实位车辆;排队时高优先级品种
//Desc: 判断nLine的队列车辆否为同品种通道中最少
function TTruckQueueDBReader.IsLineTruckLeast(const nLine: PLineItem;
  nIsReal: Boolean; const nQueueStock: string = ''): Boolean;
var nIdx: Integer;
begin
  Result := True;

  for nIdx:=FOwner.Lines.Count - 1 downto 0 do
  with PLineItem(FOwner.Lines[nIdx])^ do
  begin
    if FLineID = nLine.FLineID then Continue;
    //0.排除待对比通道

    if (not FIsValid) or (FIsVIP <> nLine.FIsVIP) then Continue;
    //1.通道无效,或通道类型不匹配

    if FRealCount >= FQueueMax then Continue;
    //2.通道车辆已满

    if nIsReal and (FRealCount >= nLine.FRealCount) then Continue;
    //3.实位车辆,对比实位车辆个数

    if (not nIsReal) and (FTrucks.Count >= nLine.FTrucks.Count) then Continue;
    //4.虚位车辆,对比车辆列表大小

    if (nQueueStock <> '') and (Pos(FStockNo, nQueueStock) < 1) then Continue;
    //5.高优先级品种,强制匹配品种

    if not IsStockMatch(FStockNo, nLine) then Continue;
    //5.两个通道品种不匹配

    if (nLine.FLineGroup <> '') and (nLine.FLineGroup <> 'Z') then
    begin
      if ((FLineGroup <> '') And (FLineGroup <> 'Z')) And
         (nLine.FLineGroup <> FLineGroup) then Continue;
    end;
    //6.分组不同
    WriteLog('当前最小负载装车线:'+ FLineID + '数量:' + IntToStr(FRealCount));
    Result := False;
    Break;
  end;
end;

//Desc: 对nList队列车辆做先后排序
procedure TTruckQueueDBReader.SortTruckList(const nList: TList);
var nTruck: PTruckItem;
    i,nIdx,nInt: Integer;
begin
  for nIdx:=0 to nList.Count - 1 do
  begin
    nTruck := nList[nIdx];
    nInt := -1;

    for i:=nIdx+1 to nList.Count - 1 do
    if PTruckItem(nList[i]).FIndex < nTruck.FIndex then
    begin
      nInt := i;
      nTruck := nList[i];
      //find the mininum
    end;

    if nInt > -1 then
    begin
      nList[nInt] := nList[nIdx];
      nList[nIdx] := nTruck;
    end;
  end;
end;

initialization
  gTruckPreQueueManager := TTruckQueueManager.Create
finalization
  FreeAndNil(gTruckPreQueueManager);
end.

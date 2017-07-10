{*******************************************************************************
  作者: dmzn@163.com 2013-12-04
  描述: 模块业务对象
*******************************************************************************}
unit UWorkerBusinessCommand;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, UBase64, UWorkerClientWebChat, UMgrQueue;

type
  TBusWorkerQueryField = class(TBusinessWorkerBase)
  private
    FIn: TWorkerQueryFieldData;
    FOut: TWorkerQueryFieldData;
  public
    class function FunctionName: string; override;
    function GetFlagStr(const nFlag: Integer): string; override;
    function DoWork(var nData: string): Boolean; override;
    //执行业务
  end;

  TMITDBWorker = class(TBusinessWorkerBase)
  protected
    FErrNum: Integer;
    //错误码
    FDBConn: PDBWorker;
    //数据通道
    FDataIn,FDataOut: PBWDataBase;
    //入参出参
    FDataOutNeedUnPack: Boolean;
    //需要解包
    procedure GetInOutData(var nIn,nOut: PBWDataBase); virtual; abstract;
    //出入参数
    function VerifyParamIn(var nData: string): Boolean; virtual;
    //验证入参
    function DoDBWork(var nData: string): Boolean; virtual; abstract;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; virtual;
    //数据业务
  public
    function DoWork(var nData: string): Boolean; override;
    //执行业务
    procedure WriteLog(const nEvent: string);
    //记录日志
  end;

  TWorkerBusinessCommander = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function GetServerNow(var nData: string): Boolean;
    //获取服务器时间
    function GetSerailID(var nData: string): Boolean;
    //获取串号
    function VerifyTruckNO(var nData: string): Boolean;
    //验证车牌是否有效
    function GetCardUsed(var nData: string): Boolean;
    //获取卡片类型
    function IsSystemExpired(var nData: string): Boolean;
    //系统是否已过期
    function SaveTruck(var nData: string): Boolean;
    //保存车辆到Truck表
    function Login(var nData: string):Boolean;
    function LogOut(var nData: string): Boolean;
    //登录注销，用于移动终端 
    function GetStockBatcode(var nData: string): Boolean;
    //批次编号管理

    function GetSQLQueryOrder(var nData: string): Boolean;
    //获取订单查询语句
    function GetSQLQueryDispatch(var nData: string): Boolean;
    //获取调拨查询语句
    function GetSQLQueryCustomer(var nData: string): Boolean;
    //获取客户查询语句
    function GetTruckPoundData(var nData: string): Boolean;
    function SaveTruckPoundData(var nData: string): Boolean;
    //存取车辆称重数据
    function GetStationPoundData(var nData: string): Boolean;
    function SaveStationPoundData(var nData: string): Boolean;
    function GetStationTruckValue(var nData: string): Boolean;
    //存取火车衡称重数据
    function GetTruckPValue(var nData: string): Boolean;
    //获取车辆预置皮重
    function SaveTruckPValue(var nData: string): Boolean;
    //保存车辆预置皮重
    function GetOrderFHValue(var nData: string): Boolean;
    //获取订单已发货量
    function GetOrderGYValue(var nData: string): Boolean;
    //获取订单已发货量
    function SyncNC_ME25(var nData: string): Boolean;
    //发货单到榜单
    function SyncNC_ME03(var nData: string): Boolean;
    //供应订单到榜单
    function SyncNC_HaulBack(var nData: string): Boolean;
    //回空业务到磅单
    function GetPoundBaseValue(var nData: string): Boolean;
    function IsDeDuctValid:Boolean;
    //使用暗扣规则

    //-------------------由DL向Web商城发起查询----------------------------------
    function SendEventMsg(var nData:string):boolean;
    //发送模板消息
    function GetCustomerInfo(var nData:string):boolean;
    //获取客户注册信息
    function EditShopCustom(var nData:string):boolean;
    //关联(解除关联)商城用户
    function GetShopOrdersByID(var nData:string):boolean;
    //根据司机身份证获取订单信息
    function GetShopOrderByNO(var nData:string):boolean;
    //根据订单号获取订单信息
    function EditShopOrderInfo(var nData:string):Boolean;
    //修改订单信息

    //-------------------由Web商城向DL发起查询----------------------------------
    function GetOrderList(var nData:string):Boolean;
    //获取销售订单列表
    function GetPurchaseList(var nData:string):Boolean;
    //获取采购订单列表
    function VerifyPrintCode(var nData: string): Boolean;
    //验证喷码信息
    function GetWaitingForloading(var nData:string):Boolean;
    //工厂待装查询

    //-------------------由DL向DL发起查询---------------------------------------
    function DLSaveShopInfo(var nData:string):Boolean;
    //保存同步信息
  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
    class function CallMe(const nCmd: Integer; const nData,nExt: string;
      const nOut: PWorkerBusinessCommand): Boolean;
    //local call
  end;

function FormatValue(const nSrcValue, nWCValue: Extended): Extended;
implementation

class function TBusWorkerQueryField.FunctionName: string;
begin
  Result := sBus_GetQueryField;
end;

function TBusWorkerQueryField.GetFlagStr(const nFlag: Integer): string;
begin
  inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_GetQueryField;
  end;
end;

function TBusWorkerQueryField.DoWork(var nData: string): Boolean;
begin
  FOut.FData := '*';
  FPacker.UnPackIn(nData, @FIn);

  case FIn.FType of
   cQF_Bill: 
    FOut.FData := '*';
  end;

  Result := True;
  FOut.FBase.FResult := True;
  nData := FPacker.PackOut(@FOut);
end;

//------------------------------------------------------------------------------
//Date: 2012-3-13
//Parm: 如参数护具
//Desc: 获取连接数据库所需的资源
function TMITDBWorker.DoWork(var nData: string): Boolean;
begin
  Result := False;
  FDBConn := nil;

  with gParamManager.ActiveParam^ do
  try
    FDBConn := gDBConnManager.GetConnection(FDB.FID, FErrNum);
    if not Assigned(FDBConn) then
    begin
      nData := '连接数据库失败(DBConn Is Null).';
      Exit;
    end;

    if not FDBConn.FConn.Connected then
      FDBConn.FConn.Connected := True;
    //conn db

    FDataOutNeedUnPack := True;
    GetInOutData(FDataIn, FDataOut);
    FPacker.UnPackIn(nData, FDataIn);

    with FDataIn.FVia do
    begin
      FUser   := gSysParam.FAppFlag;
      FIP     := gSysParam.FLocalIP;
      FMAC    := gSysParam.FLocalMAC;
      FTime   := FWorkTime;
      FKpLong := FWorkTimeInit;
    end;

    {$IFDEF DEBUG}
    WriteLog('Fun: '+FunctionName+' InData:'+ FPacker.PackIn(FDataIn, False));
    {$ENDIF}
    if not VerifyParamIn(nData) then Exit;
    //invalid input parameter

    FPacker.InitData(FDataOut, False, True, False);
    //init exclude base
    FDataOut^ := FDataIn^;

    Result := DoDBWork(nData);
    //execute worker

    if Result then
    begin
      if FDataOutNeedUnPack then
        FPacker.UnPackOut(nData, FDataOut);
      //xxxxx

      Result := DoAfterDBWork(nData, True);
      if not Result then Exit;

      with FDataOut.FVia do
        FKpLong := GetTickCount - FWorkTimeInit;
      nData := FPacker.PackOut(FDataOut);

      {$IFDEF DEBUG}
      WriteLog('Fun: '+FunctionName+' OutData:'+ FPacker.PackOut(FDataOut, False));
      {$ENDIF}
    end else DoAfterDBWork(nData, False);
  finally
    gDBConnManager.ReleaseConnection(FDBConn);
  end;
end;

//Date: 2012-3-22
//Parm: 输出数据;结果
//Desc: 数据业务执行完毕后的收尾操作
function TMITDBWorker.DoAfterDBWork(var nData: string; nResult: Boolean): Boolean;
begin
  Result := True;
end;

//Date: 2012-3-18
//Parm: 入参数据
//Desc: 验证入参数据是否有效
function TMITDBWorker.VerifyParamIn(var nData: string): Boolean;
begin
  Result := True;
end;

//Desc: 记录nEvent日志
procedure TMITDBWorker.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TMITDBWorker, FunctionName, nEvent);
end;

//------------------------------------------------------------------------------
class function TWorkerBusinessCommander.FunctionName: string;
begin
  Result := sBus_BusinessCommand;
end;

constructor TWorkerBusinessCommander.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessCommander.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TWorkerBusinessCommander.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessCommander.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2014-09-15
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
class function TWorkerBusinessCommander.CallMe(const nCmd: Integer;
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
    nPacker.InitData(@nIn, True, False);
    //init
    
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(FunctionName);
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

//Date: 2012-3-22
//Parm: 输入数据
//Desc: 执行nData业务指令
function TWorkerBusinessCommander.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;

  case FIn.FCommand of
   cBC_ServerNow           : Result := GetServerNow(nData);
   cBC_GetSerialNO         : Result := GetSerailID(nData);
   cBC_IsSystemExpired     : Result := IsSystemExpired(nData);
   cBC_IsTruckValid        : Result := VerifyTruckNO(nData);
   cBC_GetCardUsed         : Result := GetCardUsed(nData);
   cBC_UserLogin           : Result := Login(nData);
   cBC_UserLogOut          : Result := LogOut(nData);

   cBC_SaveTruckInfo       : Result := SaveTruck(nData);
   cBC_GetStockBatcode     : Result := GetStockBatcode(nData);
   
   cBC_GetSQLQueryOrder    : Result := GetSQLQueryOrder(nData);
   cBC_GetSQLQueryDispatch : Result := GetSQLQueryDispatch(nData);
   cBC_GetSQLQueryCustomer : Result := GetSQLQueryCustomer(nData);
   cBC_SyncME25            : Result := SyncNC_ME25(nData);
   cBC_SyncME03            : Result := SyncNC_ME03(nData);
   cBC_SyncHaulBack        : Result := SyncNC_HaulBack(nData);

   cBC_GetOrderFHValue     : Result := GetOrderFHValue(nData);
   cBC_GetOrderGYValue     : Result := GetOrderGYValue(nData);
   cBC_GetTruckPoundData   : Result := GetTruckPoundData(nData);
   cBC_SaveTruckPoundData  : Result := SaveTruckPoundData(nData);
   cBC_GetTruckPValue      : Result := GetTruckPValue(nData);
   cBC_SaveTruckPValue     : Result := SaveTruckPValue(nData);
   cBC_GetPoundBaseValue   : Result := GetPoundBaseValue(nData);
   cBC_GetStationPoundData : Result := GetStationPoundData(nData);
   cBC_SaveStationPoundData: Result := SaveStationPoundData(nData);

   cBC_WebChat_SendEventMsg     :Result := SendEventMsg(nData);                //微信平台接口：发送模板消息
    cBC_WebChat_GetCustomerInfo  :Result := GetCustomerInfo(nData);             //微信平台接口：获取商城账户注册信息
    cBC_WebChat_EditShopCustom   :Result := EditShopCustom(nData);              //微信平台接口：新增商城用户

    cBC_WebChat_GetShopOrdersByID:Result := GetShopOrdersByID(nData);           //微信平台接口：通过司机身份证号获取商城订单信息
    cBC_WebChat_GetShopOrderByNO :Result := GetShopOrderByNO(nData);            //微信平台接口：通过二维码获取商城订单信息
    cBC_WebChat_EditShopOrderInfo:Result := EditShopOrderInfo(nData);           //微信平台接口：修改商城订单信息

    cBC_WebChat_GetOrderList     :Result := GetOrderList(nData);                //微信平台接口：获取销售订单列表
    cBC_WebChat_GetPurchaseList  :Result := GetPurchaseList(nData);             //微信平台接口：获取采购订单列表
    cBC_WebChat_VerifPrintCode   :Result := VerifyPrintCode(nData);             //微信平台接口：获取防伪码信息
    cBC_WebChat_WaitingForloading:Result := GetWaitingForloading(nData);        //微信平台接口：获取排队信息

    cBC_WebChat_DLSaveShopInfo   :Result := DLSaveShopInfo(nData);              //微信平台
   else
    begin
      Result := False;
      nData := '无效的业务代码(Invalid Command).';
    end;
  end;
end;

//Date: 2014-09-05
//Desc: 获取服务器当前时间
function TWorkerBusinessCommander.GetServerNow(var nData: string): Boolean;
var nStr: string;
begin
  nStr := 'Select ' + sField_SQLServer_Now;
  //sql

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    FOut.FData := DateTime2Str(Fields[0].AsDateTime);
    Result := True;
  end;
end;

//Date: 2012-3-25
//Desc: 按规则生成序列编号
function TWorkerBusinessCommander.GetSerailID(var nData: string): Boolean;
var nInt: Integer;
    nStr,nP,nB: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    Result := False;
    FListA.Text := FIn.FData;
    //param list

    nStr := 'Update %s Set B_Base=B_Base+1 ' +
            'Where B_Group=''%s'' And B_Object=''%s''';
    nStr := Format(nStr, [sTable_SerialBase, FListA.Values['Group'],
            FListA.Values['Object']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Select B_Prefix,B_IDLen,B_Base,B_Date,%s as B_Now From %s ' +
            'Where B_Group=''%s'' And B_Object=''%s''';
    nStr := Format(nStr, [sField_SQLServer_Now, sTable_SerialBase,
            FListA.Values['Group'], FListA.Values['Object']]);
    //xxxxx

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := '没有[ %s.%s ]的编码配置.';
        nData := Format(nData, [FListA.Values['Group'], FListA.Values['Object']]);

        FDBConn.FConn.RollbackTrans;
        Exit;
      end;

      nP := FieldByName('B_Prefix').AsString;
      nB := FieldByName('B_Base').AsString;
      nInt := FieldByName('B_IDLen').AsInteger;

      if FIn.FExtParam = sFlag_Yes then //按日期编码
      begin
        nStr := Date2Str(FieldByName('B_Date').AsDateTime, False);
        //old date

        if (nStr <> Date2Str(FieldByName('B_Now').AsDateTime, False)) and
           (FieldByName('B_Now').AsDateTime > FieldByName('B_Date').AsDateTime) then
        begin
          nStr := 'Update %s Set B_Base=1,B_Date=%s ' +
                  'Where B_Group=''%s'' And B_Object=''%s''';
          nStr := Format(nStr, [sTable_SerialBase, sField_SQLServer_Now,
                  FListA.Values['Group'], FListA.Values['Object']]);
          gDBConnManager.WorkerExec(FDBConn, nStr);

          nB := '1';
          nStr := Date2Str(FieldByName('B_Now').AsDateTime, False);
          //now date
        end;

        System.Delete(nStr, 1, 2);
        //yymmdd
        nInt := nInt - Length(nP) - Length(nStr) - Length(nB);
        FOut.FData := nP + nStr + StringOfChar('0', nInt) + nB;
      end else
      begin
        nInt := nInt - Length(nP) - Length(nB);
        nStr := StringOfChar('0', nInt);
        FOut.FData := nP + nStr + nB;
      end;
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-05
//Desc: 验证系统是否已过期
function TWorkerBusinessCommander.IsSystemExpired(var nData: string): Boolean;
var nStr: string;
    nDate: TDate;
    nInt: Integer;
begin
  nDate := Date();
  //server now

  nStr := 'Select D_Value,D_ParamB From %s ' +
          'Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_ValidDate]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nStr := 'dmzn_stock_' + Fields[0].AsString;
    nStr := MD5Print(MD5String(nStr));

    if nStr = Fields[1].AsString then
      nDate := Str2Date(Fields[0].AsString);
    //xxxxx
  end;

  nInt := Trunc(nDate - Date());
  Result := nInt > 0;

  if nInt <= 0 then
  begin
    nStr := '系统已过期 %d 天,请联系管理员!!';
    nData := Format(nStr, [-nInt]);
    Exit;
  end;

  FOut.FData := IntToStr(nInt);
  //last days

  if nInt <= 7 then
  begin
    nStr := Format('系统在 %d 天后过期', [nInt]);
    FOut.FBase.FErrDesc := nStr;
    FOut.FBase.FErrCode := sFlag_ForceHint;
  end;
end;

//Date: 2014-09-16
//Parm: 车牌号;
//Desc: 验证nTruck是否有效
function TWorkerBusinessCommander.VerifyTruckNO(var nData: string): Boolean;
var nIdx: Integer;
    nStr, nTruck: string;
    nWStr: WideString;
begin
  Result := False;
  nTruck := FIn.FData;
  //init

  nIdx := Length(nTruck);
  if (nIdx < 3) or (nIdx > 10) then
  begin
    nData := '有效的车牌号长度为3-10.';
    Exit;
  end;

  nWStr := LowerCase(nTruck);
  //lower

  for nIdx:=1 to Length(nWStr) do
  begin
    case Ord(nWStr[nIdx]) of
     Ord('-'): Continue;
     Ord('0')..Ord('9'): Continue;
     Ord('a')..Ord('z'): Continue;
    end;

    if nIdx > 1 then
    begin
      nData := Format('车牌号[ %s ]无效.', [nTruck]);
      Exit;
    end;
  end;

  nStr := 'Select T_Valid From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, nTruck]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  if FieldByName('T_Valid').AsString = sFlag_No then
  begin
    nData := '车辆[ %s ]已被管理员列入黑名单.';
    nData := Format(nData, [nTruck]);
    Exit;
  end;

  Result := True;
end;

//Date: 2014-09-05
//Desc: 获取卡片类型：销售S;采购P;其他O
function TWorkerBusinessCommander.GetCardUsed(var nData: string): Boolean;
var nStr: string;
begin
  Result := False;

  nStr := 'Select C_Used From %s Where C_Card=''%s'' ' +
          'or C_Card3=''%s'' or C_Card2=''%s''';
  nStr := Format(nStr, [sTable_Card, FIn.FData, FIn.FData, FIn.FData]);
  //card status

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount<1 then Exit;

    FOut.FData := Fields[0].AsString;
    Result := True;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/9/15
//Parm:
//Desc: 是否使用暗扣
function TWorkerBusinessCommander.IsDeDuctValid:Boolean;
var nStr, nStrTime: string;
    nOut: TWorkerBusinessCommand;
begin
  Result := True;
  //init

  nStr := 'Select Top 1 D_Memo From $DB Where D_Name=''$PM''';
  nStr := MacroValue(nStr, [MI('$DB', sTable_SysDict),
          MI('$PM', sFlag_DuctTimeItem)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount<1 then Exit;
  //无需通过时间段进行扣吨限制

  if CallMe(cBC_ServerNow, '', '', @nOut) then
        nStrTime := Time2Str(Str2DateTime(nOut.FData))
  else  nStrTime := Time2Str(Now);

  nStr := 'Select D_Memo From $DB Where D_Value<=''$NT'' and D_ParamB>=''$NT'''+
          ' and D_Name=''$PM''';
  nStr := MacroValue(nStr, [MI('$DB', sTable_SysDict), MI('$NT', nStrTime),
          MI('$PM', sFlag_DuctTimeItem)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount<1 then Result:=False;
  //不满足扣吨时间段，不允许扣吨
end;


//Date: 2014-10-02
//Parm: 车牌号[FIn.FData];
//Desc: 保存车辆到sTable_Truck表
function TWorkerBusinessCommander.SaveTruck(var nData: string): Boolean;
var nStr: string;
begin
  Result := True;
  FIn.FData := UpperCase(FIn.FData);

  nStr := 'Select Count(*) From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, FIn.FData]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if Fields[0].AsInteger < 1 then
  begin
    nStr := 'Insert Into %s(T_Truck, T_PY) Values(''%s'', ''%s'')';
    nStr := Format(nStr, [sTable_Truck, FIn.FData, GetPinYinOfStr(FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
  end;
end;

//Date: 2015-01-16
//Parm: 物料编号[FIn.FData]
//Desc: 获取指定物料号的编号
function TWorkerBusinessCommander.GetStockBatcode(var nData: string): Boolean;
var nStr,nP,nUBrand,nUBatchAuto, nUBatcode, nType: string;
    nBatchNew, nSelect: string;
    nVal, nPer: Double;
    nInt, nInc: Integer;
    nNew: Boolean;

    //生成新批次号
    function NewBatCode(const nBtype:string = 'C'): string;
    var nSQL, nTmp: string;
    begin
      nSQL := 'Select * From %s Where B_Stock=''%s'' And B_Type=''%s''';
      nSQL := Format(nSQL, [sTable_Batcode, FIn.FData, nBtype]);

      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      begin
        nP := FieldByName('B_Prefix').AsString;
        nTmp := FieldByName('B_Base').AsString;
        nInt := FieldByName('B_Length').AsInteger;

        nInt := nInt - Length(nP + nTmp);
        if nInt > 0 then
             Result := nP + StringOfChar('0', nInt) + nTmp
        else Result := nP + nTmp;
      end;

      nTmp := Format('B_Stock=''%s'' And B_Type=''%s''', [FIn.FData, nBtype]);
      nSQL := MakeSQLByStr([SF('B_Batcode', Result),
                SF('B_FirstDate', sField_SQLServer_Now, sfVal),
                SF('B_HasUse', 0, sfVal),
                SF('B_LastDate', sField_SQLServer_Now, sfVal)
                ], sTable_Batcode, nTmp, False);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;
begin
  Result := False;

  nStr := 'Select D_Memo, D_Value from %s Where D_Name=''%s'' and ' +
          '(D_Memo=''%s'' or D_Memo=''%s'' or D_Memo=''%s'')';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam,
                        sFlag_BatchAuto, sFlag_BatchBrand, sFlag_BatchValid]);
  //xxxxxx

  nUBatchAuto := sFlag_Yes;
  nUBatcode := sFlag_No;
  nUBrand := sFlag_No;
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      if Fields[0].AsString = sFlag_BatchAuto then
        nUBatchAuto := Fields[1].AsString;

      if Fields[0].AsString = sFlag_BatchBrand then
        nUBrand  := Fields[1].AsString;

      if Fields[0].AsString = sFlag_BatchValid then
        nUBatcode  := Fields[1].AsString;

      Next;
    end;
  end;

  if nUBatcode <> sFlag_Yes then
  begin
    FOut.FData := '';
    Result := True;
    Exit;
  end;

  FListA.Clear;
  FListA.Text:= PackerDecodeStr(FIn.FExtParam);

  if nUBatchAuto = sFlag_Yes then
  begin
    if FListA.Values['Type'] ='' then
          nType := sFlag_TypeCommon
    else  nType := FListA.Values['Type'];

    nStr := 'Select *,%s as ServerNow From %s Where B_Stock=''%s'' ' +
            'And B_Type=''%s''';
    nStr := Format(nStr, [sField_SQLServer_Now,sTable_Batcode,FIn.FData,nType]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := '物料[ %s.%s ]未配置批次号规则.';
        nData := Format(nData, [FIn.FData, nType]);
        Exit;
      end;

      if FieldByName('B_UseDate').AsString = sFlag_Yes then  //使用日期编码
      begin
        nP := FieldByName('B_Prefix').AsString;
        nStr := Date2Str(FieldByName('ServerNow').AsDateTime, False);

        nInt := FieldByName('B_Length').AsInteger;
        nInc := Length(nP + nStr) - nInt;

        if nInc > 0 then
        begin
          System.Delete(nStr, 1, nInc);
          FOut.FData := nP + nStr;
        end else
        begin
          nStr := StringOfChar('0', -nInc) + nStr;
          FOut.FData := nP + nStr;
        end;

        Result := True;
        Exit;
      end;

      FOut.FData := FieldByName('B_Batcode').AsString;
      nInc := FieldByName('B_Incement').AsInteger;
      nNew := False;

      if FieldByName('B_AutoNew').AsString = sFlag_Yes then //元旦重置
      begin
        nStr := Date2Str(FieldByName('ServerNow').AsDateTime);
        nStr := Copy(nStr, 1, 4);
        nP := Date2Str(FieldByName('B_LastDate').AsDateTime);
        nP := Copy(nP, 1, 4);

        if nStr <> nP then
        begin
          nStr := 'Update %s Set B_Base=1 Where B_Stock=''%s'' And B_Type=''%s''';
          nStr := Format(nStr, [sTable_Batcode, FIn.FData, nType]);

          gDBConnManager.WorkerExec(FDBConn, nStr);
          FOut.FData := NewBatCode(nType);
          nNew := True;
        end;
      end;

      if not nNew then //编号超期
      begin
        nStr := Date2Str(FieldByName('ServerNow').AsDateTime);
        nP := Date2Str(FieldByName('B_FirstDate').AsDateTime);

        if (Str2Date(nP) > Str2Date('2000-01-01')) and
           (Str2Date(nStr) - Str2Date(nP) > FieldByName('B_Interval').AsInteger) then
        begin
          nStr := 'Update %s Set B_Base=B_Base+%d Where B_Stock=''%s''' +
                  'And B_Type=''%s''';
          nStr := Format(nStr, [sTable_Batcode, nInc, FIn.FData, nType]);

          gDBConnManager.WorkerExec(FDBConn, nStr);
          FOut.FData := NewBatCode(nType);
          nNew := True;
        end;
      end;

      if not nNew then //编号超发
      begin
        nVal := FieldByName('B_HasUse').AsFloat + StrToFloat(FListA.Values['Value']);
        //已使用+预使用
        nPer := FieldByName('B_Value').AsFloat * FieldByName('B_High').AsFloat / 100;
        //可用上限

        if nVal >= nPer then //超发
        begin
          nStr := 'Update %s Set B_Base=B_Base+%d Where B_Stock=''%s'' ' +
                  'And B_Type=''%s''';
          nStr := Format(nStr, [sTable_Batcode, nInc, FIn.FData, nType]);

          gDBConnManager.WorkerExec(FDBConn, nStr);
          FOut.FData := NewBatCode(nType);
        end else
        begin
          nPer := FieldByName('B_Value').AsFloat * FieldByName('B_Low').AsFloat / 100;
          //提醒

          if nVal >= nPer then //超发提醒
          begin
            nStr := '物料[ %s.%s ]即将更换批次号,请通知化验室准备取样.';
            nStr := Format(nStr, [FieldByName('B_Stock').AsString,
                                  FieldByName('B_Name').AsString]);
            //xxxxx

            FOut.FBase.FErrCode := sFlag_ForceHint;
            FOut.FBase.FErrDesc := nStr;
          end;
        end;
      end;
    end;

    if FOut.FData = '' then
      FOut.FData := NewBatCode(nType);
    //xxxxx

    Result := True;
    FOut.FBase.FResult := True;

    Exit;
  end;
  //自动获取批次号

  nStr := 'Select * from %s Where D_Stock=''%s'' and D_Valid=''%s'' '+
          'Order By D_UseDate';
  nStr := Format(nStr, [sTable_BatcodeDoc, FIn.FData, sFlag_BatchInUse]);
  //xxxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '物料[ %s ]批次不存在.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    First;
    nVal := 0;
    nBatchNew:='';
    nSelect:=sFlag_No;

    while not Eof do
    try
      if (nUBrand=sFlag_Yes) and
         (FieldByName('D_Brand').AsString<>FListA.Values['Brand']) then
         Continue;
      //使用品牌时，品牌不对

      nVal := FieldByName('D_Plan').AsFloat - FieldByName('D_Sent').AsFloat +
              FieldByName('D_Rund').AsFloat - FieldByName('D_Init').AsFloat -
              StrToFloat(FListA.Values['Value']);

      if FloatRelation(nVal, 0, rtLE) then Continue;
      //超发

      nSelect   := sFlag_Yes;
      nBatchNew := FieldByName('D_ID').AsString;
      Break;
    finally
      Next;
    end;

    if nSelect <> sFlag_Yes then
    begin
      nData := '满足条件的物料[ %s.%s ]批次不存在.';
      nData := Format(nData, [FIn.FData, FListA.Values['Brand']]);
      Exit;
    end;

    if nVal <= FieldByName('D_Warn').AsFloat then //超发提醒
    begin
      nStr := '物料[ %s.%s ]即将更换批次号,请通知化验室准备取样.';
      nStr := Format(nStr, [FIn.FData,
                            FListA.Values['Brand']]);
      //xxxxx

      nStr := 'Update %s Set D_Valid=''%s'' Where D_ID=''%s''';
      nStr := Format(nStr, [sTable_BatcodeDoc, sFlag_BatchOutUse, nBatchNew]);
      gDBConnManager.WorkerExec(FDBConn, nStr);

      FOut.FBase.FErrCode := sFlag_ForceHint;
      FOut.FBase.FErrDesc := nStr;
    end;

    nStr := 'Update %s Set D_LastDate=null Where D_Valid=''%s'' ' +
            'And D_LastDate is not NULL';
    nStr := Format(nStr, [sTable_BatcodeDoc, sFlag_BatchInUse]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //启用状态的批次号，去掉终止时间

    FOut.FData := nBatchNew;
    Result := True;
  end;
  //根据品牌号获取批次号
end;

//Date: 2014-12-16
//Parm: 查询类型[FIn.FData];查询条件[FIn.FExtParam]
//Desc: 依据查询条件,构建指定类型订单的SQL查询语句
function TWorkerBusinessCommander.GetSQLQueryOrder(var nData: string): Boolean;
var nStr,nType,nPB,nFactNum: string;
    nCorp,nWHGroup,nWHID:string;
begin
  Result := False;
  FListA.Text := DecodeBase64(FIn.FExtParam);

  nStr := 'Select D_Value,D_Memo,D_ParamB From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_OrderInFact]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '请先配置[ OrderInFact ]字典项';
      Exit;
    end;

    First;
    nFactNum := UpperCase(FListA.Values['FactoryID']);
    while not Eof do
    begin
      nStr := Fields[1].AsString;
      nPB  := UpperCase(Fields[2].AsString);

      if (nFactNum = '') or (nPB = nFactNum) then
      begin
        if (nStr = sFlag_InFact) then
          nCorp := Fields[0].AsString;
        //xxxxx

        if nStr = sFlag_InWHouse then
          nWHGroup := Fields[0].AsString;
        //xxxxx

        if nStr = sFlag_InWHID then
          nWHID := Fields[0].AsString;
        //xxxxx
      end;

      Next;
    end;
  end;

  if FIn.FData = '101' then           //销售订单
    nType := SF('VBILLTYPE', 'ME25')
  else if FIn.FData = '102' then      //销售申请单
    nType := SF('VBILLTYPE', 'ME25')
  else if FIn.FData = '103' then      //销售订单和申请单
    nType := SF('VBILLTYPE', 'ME25')

  else if FIn.FData = '201' then      //采购订单
    nType := SF('VBILLTYPE', 'ME03')
  else if FIn.FData = '202' then      //采购申请单
    nType := SF('VBILLTYPE', 'ME03')
  else if FIn.FData = '203' then      //采购订单和申请单
       nType := SF('VBILLTYPE', 'ME03')
  else nType := '';

  if nType = '' then
  begin
    nData := Format('无效的订单查询类型( %s ).', [FIn.FData]);
    Exit;
  end;

  FOut.FData := 'select ' +
     'pk_meambill_b as pk_meambill,VBILLCODE,VBILLTYPE,COPERATOR,user_name,' +  //订单表头
     'TMAKETIME,NPLANNUM,cvehicle,vbatchcode,unitname,areaclname,t1.vdef10,' +  //订单表体(t1.vdef10:矿点)
     't1.vdef5,t1.pk_cumandoc,custcode,cmnecode,custname,t_cd.def30,'+          //客商信息(t1.vdef5:品牌)
     't1.vdef2,t_def.docname,' +                                                //客商2(t1.vdef2:区域流向PK;docname:区域流向名)
     'invcode,invname,invtype ' +                                               //物料
     'from meam_bill t1 ' +
     '  left join sm_user t_su on t_su.cuserid=t1.coperator ' +
     '  left join meam_bill_b t2 on t2.PK_MEAMBILL=t1.PK_MEAMBILL' +
     '  left join Bd_cumandoc t_cd on t_cd.pk_cumandoc=t1.pk_cumandoc' +
     '  left join bd_cubasdoc t_cb on t_cb.pk_cubasdoc=t_cd.pk_cubasdoc' +
     '  left join Bd_invbasdoc t_ib on t_ib.pk_invbasdoc=t2.PK_INVBASDOC' +
     '  left join bd_corp t_cp on t_cp.pk_corp=t1.pk_corp' +
     '  left join bd_areacl t_al on t_al.pk_areacl=t1.vdef1' +
     '  left join bd_defdoc t_def on t_def.pk_defdoc=t1.vdef2' +
     ' Where ';
  //xxxxx

  Result := True;
  //xxxxx

  if Pos('10', FIn.FData) = 1 then   //销售控制发货工厂和库存组织
  begin
    nStr := AdjustListStrFormat(nWHGroup, '''', True, ',');
    if nStr<>'' then
      FOut.FData := FOut.FData + '(t2.pk_callbody_from In (' + nStr + ')) And ';
    //库存组织控制

    nStr := AdjustListStrFormat(nWHID, '''', True, ',');
    if nStr<>'' then
      FOut.FData := FOut.FData + '(t2.pk_warehouse_from In (' + nStr + ')) And ';
    //仓库发货控制

    nStr := AdjustListStrFormat(nCorp, '''', True, ',');
    if nStr<>'' then
      FOut.FData := FOut.FData + '(t2.pk_corp_from In (' + nStr + ')) And ';
    //销售控制发货工厂
  end else
  if Pos('20', FIn.FData) = 1 then //采购控制收货工厂和库存组织
  begin
    nStr := AdjustListStrFormat(nWHGroup, '''', True, ',');
    if nStr<>'' then
      FOut.FData := FOut.FData + '(t2.pk_callbody_main In (' + nStr + ')) And ';
    //库存组织控制

    nStr := AdjustListStrFormat(nWHID, '''', True, ',');
    if nStr<>'' then
      FOut.FData := FOut.FData + '(t2.pk_warehouse_main In (' + nStr + ')) And ';
    //仓库收货控制

    nStr := AdjustListStrFormat(nCorp, '''', True, ',');
    if nStr<>'' then
      FOut.FData := FOut.FData + '(t2.pk_corp_main In (' + nStr + ')) And ';
    //控制收货工厂
  end;

  nStr := FListA.Values['QueryAll'];
  if nStr = '' then
  begin
    FOut.FData := FOut.FData + ' (crowstatus=0 And VBILLSTATUS=1 ' +
                  'And t1.dr=0 And t2.dr=0) And ';
    //当前有效单据
  end;

  nStr := FListA.Values['BillCode'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format('VBILLCODE Like ''%%%s%%''', [nStr]);

    nData := Format('GetSQLQueryOrder BillCode -> [ %s ]', [FOut.FData]);
    WriteLog(nData);
    Exit; //按单号模糊查询
  end;

  nStr := FListA.Values['BillCodes'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format('VBILLCODE In (%s)', [nStr]);

    nData := Format('GetSQLQueryOrder BillCodes -> [ %s ]', [FOut.FData]);
    WriteLog(nData);
    Exit; //按单号批量查询
  end;

  nStr := FListA.Values['MeamKeys'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format('pk_meambill_b In (%s)', [nStr]);

    nData := Format('GetSQLQueryOrder MeamKeys -> [ %s ]', [FOut.FData]);
    WriteLog(nData);
    Exit; //按单号查询
  end;

  nStr := FListA.Values['NoDate'];
  if nStr = '' then
  begin
    nStr := '(t1.dbilldate>=''%s'' And t1.dbilldate<''%s'')';
    FOut.FData := FOut.FData + Format(nStr, [
                  FListA.Values['DateStart'],
                  FListA.Values['DateEnd']]);
    //日期限制

    FOut.FData := FOut.FData + ' And ';
    //拼接以下条件
  end;

  FOut.FData := FOut.FData + ' (' + nType + ')';
  //单据类型

  nStr := FListA.Values['CustomerID'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format(' And custcode=''%s''', [nStr]);
    //按客户编号
  end;

  nStr := FListA.Values['StockNo'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format(' And invcode=''%s''', [nStr]);
    //按物料编号
  end;

  nStr := FListA.Values['Filter'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + ' And (' + DecodeBase64(nStr) + ')';
    //查询条件
  end;

  nStr := FListA.Values['Order'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + ' Order By ' + nStr;
    //排序条件
  end;

  nData := Format('GetSQLQueryOrder End -> [ %s ]', [FOut.FData]);
  WriteLog(nData);
end;

//Date: 2015-01-08
//Parm: 查询条件[FIn.FExtParam]
//Desc: 依据查询条件调拨订单的SQL查询语句
function TWorkerBusinessCommander.GetSQLQueryDispatch(var nData: string): Boolean;
var nStr: string;
begin
  FOut.FData := 'select ' +
     'pk_meambill_b as pk_meambill,VBILLCODE,VBILLTYPE,COPERATOR,user_name,' + //订单表头
     'TMAKETIME,NPLANNUM,cvehicle,vbatchcode,t1.pk_corp_main,unitname,' +      //订单表体
     'invcode,invname,invtype ' +                                              //物料
     'from meam_bill t1 ' +
     '  left join sm_user t_su on t_su.cuserid=t1.coperator ' +
     '  left join meam_bill_b t2 on t2.PK_MEAMBILL=t1.PK_MEAMBILL' +
     '  left join Bd_invbasdoc t_ib on t_ib.pk_invbasdoc=t2.PK_INVBASDOC' +
     '  left join bd_corp t_cp on t_cp.pk_corp=t1.pk_corp_main' +
     ' Where ' ;
  FOut.FData := FOut.FData + SF('VBILLTYPE', 'ME09');

  Result := True;
  FListA.Text := DecodeBase64(FIn.FExtParam);

  nStr := FListA.Values['BillCode'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format(' And VBILLCODE Like ''%%%s%%''', [nStr]);

    nData := Format('GetSQLQueryDispatch BillCode -> [ %s ]', [FOut.FData]);
    WriteLog(nData);
    Exit; //按单号查询
  end;

  nStr := FListA.Values['MeamKeys'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format(' And pk_meambill_b In (%s)', [nStr]);

    nData := Format('GetSQLQueryDispatch MeamKeys -> [ %s ]', [FOut.FData]);
    WriteLog(nData);
    Exit; //按单号查询
  end;

  nStr := FListA.Values['NoDate'];
  if nStr = '' then
  begin
    nStr := ' And (TMAKETIME>=''%s'' And TMAKETIME<''%s'')';
    FOut.FData := FOut.FData + Format(nStr, [
                  FListA.Values['DateStart'],
                  FListA.Values['DateEnd']]);
    //日期限制
  end;

  nStr := FListA.Values['QueryAll'];
  if nStr = '' then
  begin
    FOut.FData := FOut.FData + ' And (crowstatus=0 And VBILLSTATUS=1 ' +
                  'And t1.dr=0 And t2.dr=0)';
    //当前有效单据
  end;

  nStr := FListA.Values['Customer'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format(' And unitname = ''%s''', [nStr]);
    //按客户编号
  end;
  
  nStr := FListA.Values['StockNo'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format(' And invcode=''%s''', [nStr]);
    //按物料编号
  end;

  nStr := FListA.Values['Filter'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + ' And (' + DecodeBase64(nStr) + ')';
    //查询条件
  end;

  nStr := FListA.Values['Order'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + ' Order By ' + nStr;
    //排序条件
  end;

  nData := Format('GetSQLQueryDispatch End -> [ %s ]', [FOut.FData]);
  WriteLog(nData);
end;

//Date: 2014-12-18
//Parm: 客户编号[FIn.FData];客户名称[FIn.FExtParam];
//Desc: 构建模糊查询客户的SQL语句
function TWorkerBusinessCommander.GetSQLQueryCustomer(var nData: string): Boolean;
var nStr: string;
begin
  Result := True;
  FOut.FData := 'Select DISTINCT on (custcode) custcode,custname,' +
      'cmnecode from Bd_cumandoc t1 ' +
      '  left join bd_cubasdoc t2 on t2.pk_cubasdoc=t1.pk_cubasdoc' +
      ' where ';
  //xxxxx

  if FIn.FData <> '' then
  begin
    nStr := '(cmnecode=''%s'')';
    FOut.FData := FOut.FData + Format(nStr, [FIn.FData]);
    //客户编号模糊
  end;

  if FIn.FExtParam <> '' then
  begin
    nStr := '(custname like ''%%%s%%'')';
    if FIn.FData <> '' then
      nStr := ' or ' + nStr;
    FOut.FData := FOut.FData + Format(nStr, [FIn.FExtParam]);
    //客户名称模糊
  end;

  FOut.FData := FOut.FData + ' Group By custcode,custname,cmnecode';

  nData := Format('GetSQLQueryCustomer -> [ %s ]', [FOut.FData]);
  WriteLog(nData);
end;

//Date: 2014-12-24
//Parm: 订单号(多个)[FIn.FData]
//Desc: 获取订单的已发货量
function TWorkerBusinessCommander.GetOrderFHValue(var nData: string): Boolean;
var nStr,nSQL,nID,nOrder: string;
    nInt: Integer;
    nVal: Double;
    nWorker: PDBWorker;
begin
  nSQL := 'select distinct poundb.pk_sourcebill_b norder,sum(COALESCE(poundb.nnet,0)) nnet,' +
     'sum(COALESCE(poundb.nassnum,0)) nassnum from meam_poundbill_b poundb ' +
     '  inner join meam_poundbill poundh on poundb.pk_poundbill = poundh.pk_poundbill' +
     ' where COALESCE(poundb.dr,0)=0' +
     '  and poundh.nstatus = 100' +
     '  and COALESCE(poundh.dr,0)=0' +
     '  and poundh.bnowreturn=''N''' +
     '  and COALESCE(poundh.bbillreturn,''N'')=''N''';
  //nnet:主数量;nassnum:副数量

  FListB.Clear;
  nWorker := nil;
  try
    FListA.Text := DecodeBase64(FIn.FData);
    for nInt:=0 to FListA.Count - 1 do
      FListB.Values[FListA[nInt]] := '0';
    //默认已发数量为0

    nID := AdjustListStrFormat2(FListA, '''', True, ',', False);
    nStr := ' and pk_sourcebill_b in (%s) group by poundb.pk_sourcebill_b';
    nStr := nSQL + Format(nStr, [nID]);
    //执行数

    nData := Format('GetOrderFHValue -> [ %s ] => [ %s ]', [
             '发货量', nStr]);
    WriteLog(nData);

    with gDBConnManager.SQLQuery(nStr, nWorker, sFlag_DB_NC) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nOrder := FieldByName('norder').AsString;
        FListB.Values[nOrder] := FieldByName('nnet').AsString;
        //订单已发量

        Next;
      end;
    end;

    nStr := ' and ( poundh.bbillreturn = ''Y'') and pk_sourcebill_b in (%s) ' +
            'group by poundb.pk_sourcebill_b';
    nStr := nSQL + Format(nStr, [nID]);
    //退货量

    nData := Format('GetOrderFHValue -> [ %s ] => [ %s ]', [
             '退货量', nStr]);
    WriteLog(nData);

    with gDBConnManager.WorkerQuery(nWorker, nStr) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nOrder := FieldByName('norder').AsString;
        nStr := FListB.Values[nOrder];

        if not IsNumber(nStr, True) then
          nStr := '0';
        nVal := StrToFloat(nStr);
        //取已发货量

        nVal := nVal - FieldByName('nnet').AsFloat;
        //已发货数=已发货量 - 原单退货量

        FListB.Values[nOrder] := FloatToStr(nVal);
        //订单已发量

        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;

  if FIn.FExtParam <> sFlag_No then
  begin
    FListB.Values['QueryFreeze'] := sFlag_Yes;

    nStr := 'Select B_ID,B_Freeze From %s Where B_ID In (%s)';
    nStr := Format(nStr, [sTable_Order, nID]);
    //冻结量

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nOrder := FieldByName('B_ID').AsString;
        nStr := FListB.Values[nOrder];

        if not IsNumber(nStr, True) then
          nStr := '0';
        nVal := StrToFloat(nStr);
        //取已发货量

        nVal := nVal + FieldByName('B_Freeze').AsFloat;
        //已发货数=已发货量 + 冻结量

        FListB.Values[nOrder] := FloatToStr(nVal);
        //订单已发量

        Next;
      end;
    end;
  end else FListB.Values['QueryFreeze'] := sFlag_No;

  FOut.FData := PackerEncodeStr(FListB.Text);
  Result := True;
end;

//Date: 2015-01-08
//Parm: 订单号(多个)[FIn.FData]
//Desc: 获取订单的已发货量
function TWorkerBusinessCommander.GetOrderGYValue(var nData: string): Boolean;
var nStr,nSQL,nID,nOrder: string;
    nInt: Integer;
    nWorker: PDBWorker;
begin
  nSQL := 'select distinct poundb.pk_sourcebill_b norder,sum(COALESCE(poundb.nnet,0)) nnet,' +
     'sum(COALESCE(poundb.nassnum,0)) nassnum from meam_poundbill_b poundb ' +
     '  inner join meam_poundbill poundh on poundb.pk_poundbill = poundh.pk_poundbill' +
     ' where COALESCE(poundb.dr,0)=0' +
     '  and poundh.nstatus = 100' +
     '  and COALESCE(poundh.dr,0)=0';
  //nnet:主数量;nassnum:副数量

  FListB.Clear;
  nWorker := nil;
  try
    FListA.Text := DecodeBase64(FIn.FData);
    for nInt:=0 to FListA.Count - 1 do
      FListB.Values[FListA[nInt]] := '0';
    //默认已发数量为0

    nID := AdjustListStrFormat2(FListA, '''', True, ',', False);
    nStr := ' and pk_sourcebill_b in (%s) group by poundb.pk_sourcebill_b';
    nStr := nSQL + Format(nStr, [nID]);
    //执行数

    nData := Format('GetOrderGYValue -> [ %s ]', [nStr]);
    WriteLog(nData);

    with gDBConnManager.SQLQuery(nStr, nWorker, sFlag_DB_NC) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nOrder := FieldByName('norder').AsString;
        FListB.Values[nOrder] := FieldByName('nnet').AsString;
        //订单已发量

        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;

  FOut.FData := PackerEncodeStr(FListB.Text);
  Result := True;
end;

//Date: 2014-09-25
//Parm: 车牌号[FIn.FData]
//Desc: 获取指定车牌号的称皮数据(使用配对模式,未称重)
function TWorkerBusinessCommander.GetTruckPoundData(var nData: string): Boolean;
var nStr: string;
    nPound: TLadingBillItems;
begin
  SetLength(nPound, 1);
  FillChar(nPound[0], SizeOf(TLadingBillItem), #0);

  nStr := 'Select * From %s Where P_Truck=''%s'' And ' +
          'P_MValue Is Null And P_PModel=''%s''';
  nStr := Format(nStr, [sTable_PoundLog, FIn.FData, sFlag_PoundPD]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr),nPound[0] do
  begin
    if RecordCount > 0 then
    begin
      FZhiKa      := FieldByName('P_Order').AsString;
      FID         := FZhiKa;
      
      FCusID      := FieldByName('P_CusID').AsString;
      FCusName    := FieldByName('P_CusName').AsString;
      FTruck      := FieldByName('P_Truck').AsString;

      FType       := FieldByName('P_MType').AsString;
      FStockNo    := FieldByName('P_MID').AsString;
      FStockName  := FieldByName('P_MName').AsString;

      with FPData do
      begin
        FStation  := FieldByName('P_PStation').AsString;
        FValue    := FieldByName('P_PValue').AsFloat;
        FDate     := FieldByName('P_PDate').AsDateTime;
        FOperator := FieldByName('P_PMan').AsString;
      end;  

      FFactory    := FieldByName('P_FactID').AsString;
      FOrigin     := FieldByName('P_Origin').AsString;
      FPModel     := FieldByName('P_PModel').AsString;
      FPType      := FieldByName('P_Type').AsString;
      FPoundID    := FieldByName('P_ID').AsString;

      FStatus     := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckBFM;
      FSelected   := True;
    end else
    begin
      FTruck      := FIn.FData;
      FPModel     := sFlag_PoundPD;

      FStatus     := '';
      FNextStatus := sFlag_TruckBFP;
      FSelected   := True;
    end;
  end;

  FOut.FData := CombineBillItmes(nPound);
  Result := True;
end;

//Date: 2014-09-25
//Parm: 称重数据[FIn.FData]
//Desc: 获取指定车牌号的称皮数据(使用配对模式,未称重)
function TWorkerBusinessCommander.SaveTruckPoundData(var nData: string): Boolean;
var nStr,nSQL: string;
    nVal,nNet,nBaseValue: Double;
    nProvide: Boolean;
    nTItem: TPreTruckPItem;
    nPound: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
    nMData,nPData: TPoundStationData;
begin
  Result := False;
  AnalyseBillItems(FIn.FData, nPound);
  //解析数据

  CallMe(cBC_GetPoundBaseValue, '', '' , @nOut);
  nBaseValue := StrToFloat(nOut.FData);
  //获取地磅跳动基数

  with nPound[0] do
  begin
    if not CallMe(cBC_IsTruckValid, FTruck, '', @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    nProvide := (FID <> '') and (FID = FZhiKa);
    //是否供应

    if FPreTruckP then
    begin
      if FPData.FValue>FMData.FValue then
      begin
        nMData := FPData;
        nPData := FMData;
      end  else
      begin
        nMData := FMData;
        nPData := FPData;
      end;
    end else nMData := FPData;

    nMData.FValue := FormatValue(nMData.FValue*1000, nBaseValue) / 1000;
    nPData.FValue := FormatValue(nPData.FValue*1000, nBaseValue) / 1000;
    //矫正保存数据

    if FPoundID = '' then
    begin
      TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, FTruck, '', @nOut);
      //保存车牌号

      FListC.Clear;
      FListC.Values['Group'] := sFlag_BusGroup;
      FListC.Values['Object'] := sFlag_PoundID;

      if not CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      //xxxxx

      FPoundID := nOut.FData;
      //new id

      if FPModel = sFlag_PoundLS then
           nStr := sFlag_Other
      else nStr := sFlag_Provide;

      nSQL := MakeSQLByStr([
              SF('P_ID', FPoundID),
              SF('P_Type', nStr),
              SF('P_Order', FZhiKa),
              SF('P_Truck', FTruck),
              SF('P_CusID', FCusID),
              SF('P_CusName', FCusName),
              SF('P_MID', FStockNo),
              SF('P_MName', FStockName),
              SF('P_MType', sFlag_San),
              SF('P_PValue', nMData.FValue, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_FactID', FFactory),
              SF('P_Origin', FOrigin),
              SF('P_PStation', nMData.FStation),
              SF('P_Direction', '进厂'),
              SF('P_PModel', FPModel),
              SF('P_Status', sFlag_TruckBFP),
              SF('P_Valid', sFlag_Yes),
              SF('P_PrintNum', 1, sfVal)
              ], sTable_PoundLog, '', True);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    if FLocked then
    begin
      with nTItem do
      begin
        FPreTruck := FTruck;
        //xxxxxx

        FPrePValue := nMData.FValue;
        FPrePTime  := nMData.FDate;
        FPrePMan   := nMData.FOperator;
      end;

      nStr := CombinePreTruckItem(nTItem);
      CallMe(cBC_SaveTruckPValue, nStr, '', @nOut);
    end;
    //更新预置皮重

    if (FPData.FValue > 0) and (FMData.FValue > 0) then
    begin
      nStr := 'Select D_CusID,D_Value,D_Type From %s ' +
              'Where D_Stock=''%s'' And D_Valid=''%s''';
      nStr := Format(nStr, [sTable_Deduct, FStockNo, sFlag_Yes]);

      if IsDeDuctValid then                         //首先验证是否允许暗扣
      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      if RecordCount > 0 then
      begin
        First;

        while not Eof do
        begin
          if FieldByName('D_CusID').AsString = FCusID then
            Break;
          //客户+物料参数优先

          Next;
        end;

        if Eof then First;
        //使用第一条规则

        if FMData.FValue > FPData.FValue then
             nNet := FMData.FValue - FPData.FValue
        else nNet := FPData.FValue - FMData.FValue;

        nVal := 0;
        //待扣减量
        nStr := FieldByName('D_Type').AsString;

        if nStr = sFlag_DeductFix then
          nVal := FieldByName('D_Value').AsFloat;
        //定值扣减

        if nStr = sFlag_DeductPer then
        begin
          nVal := FieldByName('D_Value').AsFloat;
          nVal := nNet * nVal;
        end; //比例扣减

        if (nVal > 0) and (nNet > nVal) then
        begin
          nVal := Float2Float(nVal, cPrecision, False);
          //将暗扣量扣减为2位小数;

          nMData.FValue := (FMData.FValue*1000 - nVal*1000) / 1000;
          if FMData.FValue > FPData.FValue then
               FMData.FValue := (FMData.FValue*1000 - nVal*1000) / 1000
          else FPData.FValue := (FPData.FValue*1000 - nVal*1000) / 1000;

          nMData.FValue := FormatValue(nMData.FValue*1000, nBaseValue) / 1000;
          FMData.FValue := FormatValue(FMData.FValue*1000, nBaseValue) / 1000;
          FPData.FValue := FormatValue(FPData.FValue*1000, nBaseValue) / 1000;
          //再次矫正数据
        end;
      end;

      try
        if FPreTruckP then
        begin
          nSQL := MakeSQLByStr([
                  SF('P_PValue', nPData.FValue, sfVal),
                  SF('P_PDate', sField_SQLServer_Now, sfVal),
                  SF('P_PMan', FIn.FBase.FFrom.FUser),
                  SF('P_PStation', nPData.FStation),
                  SF('P_MValue', nMData.FValue, sfVal),
                  SF('P_MDate', sField_SQLServer_Now, sfVal),
                  SF('P_MMan', nMData.FOperator),
                  SF('P_MStation', nMData.FStation)
                  ], sTable_PoundLog, SF('P_ID', FPoundID), False);
          //称重时，取预置皮重
        end
        else if FNextStatus = sFlag_TruckBFP then
        begin
          nSQL := MakeSQLByStr([
                  SF('P_PValue', FPData.FValue, sfVal),
                  SF('P_PDate', sField_SQLServer_Now, sfVal),
                  SF('P_PMan', FIn.FBase.FFrom.FUser),
                  SF('P_PStation', FPData.FStation),
                  SF('P_MValue', FMData.FValue, sfVal),
                  SF('P_MDate', DateTime2Str(FMData.FDate)),
                  SF('P_MMan', FMData.FOperator),
                  SF('P_MStation', FMData.FStation),
                  SF('P_Origin', FOrigin)
                  ], sTable_PoundLog, SF('P_ID', FPoundID), False);
          //称重时,由于皮重大,交换皮毛重数据
        end else
        begin
          nSQL := MakeSQLByStr([
                  SF('P_MValue', FMData.FValue, sfVal),
                  SF('P_MDate', sField_SQLServer_Now, sfVal),
                  SF('P_MMan', FIn.FBase.FFrom.FUser),
                  SF('P_MStation', FMData.FStation),
                  SF('P_Origin', FOrigin)
                  ], sTable_PoundLog, SF('P_ID', FPoundID), False);
          //xxxxx
        end;

        gDBConnManager.WorkerExec(FDBConn, nSQL);
        if nProvide and (not CallMe(cBC_SyncME03, FPoundID, '', @nOut)) then
          raise Exception.Create(nOut.FData);
        //同步供应到NC
      except
        on nErr: Exception do
        begin
          nSQL := 'Update %s Set P_PValue=P_MValue,P_MValue=Null Where P_ID=''%s''';
          nSQL := Format(nSQL, [sTable_PoundLog, FPoundID]);
          gDBConnManager.WorkerExec(FDBConn, nSQL);

          nData := nErr.Message;
          Exit;
        end;
      end;
    end;

    FOut.FData := FPoundID;
    Result := True;
  end;
end;

function TWorkerBusinessCommander.GetTruckPValue(var nData: string): Boolean;
var nStr: string;
    nItem: TPreTruckPItem;
begin
  nStr := 'Select * From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr), nItem do
  begin
    if RecordCount > 0 then
    begin
      FPreUse    := FieldByName('T_PrePUse').AsString = sFlag_Yes;
      FPrePMan   := FieldByName('T_PrePMan').AsString;
      FPrePTime  := FieldByName('T_PrePTime').AsDateTime;

      FPrePValue := FieldByName('T_PrePValue').AsFloat;
      FMinPVal   := FieldByName('T_MinPVal').AsFloat;
      FMaxPVal   := FieldByName('T_MaxPVal').AsFloat;
      FPValue    := FieldByName('T_PValue').AsFloat;

      FPreTruck  := FieldByName('T_Truck').AsString;
    end else
    begin
      FPreUse    := False;
      FPrePMan   := '';
      FPrePTime  := Now;

      FPrePValue := 0;
      FPreTruck  := '';
    end;  
  end;

  FOut.FData := CombinePreTruckItem(nItem);
  Result := True;
end;

function TWorkerBusinessCommander.SaveTruckPValue(var nData: string): Boolean;
var nStr: string;
    nItem: TPreTruckPItem;
begin
  Result := True;
  AnalysePreTruckItem(FIn.FData, nItem);

  nStr := 'Select T_PrePUse,T_PrePValue from %s where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, nItem.FPreTruck]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if (RecordCount<1) or (Fields[0].AsString <> sFlag_Yes) then Exit;
  end;
  //车牌记录不存在，不使用预置皮重，或者新的皮重等于老的预置，则不更新

  nStr := MakeSQLByStr([SF('T_PrePValue', nItem.FPrePValue, sfVal),
          SF('T_PrePTime', sField_SQLServer_Now, sfVal),
          SF('T_PrePMan', nItem.FPrePMan)],
          sTable_Truck, SF('T_Truck', nItem.FPreTruck), False);

  gDBConnManager.WorkerExec(FDBConn, nStr);
end;

//------------------------------------------------------------------------------
//Desc: 构建字段内容
function MakeField(const nDS: TDataSet; const nName: string; nPos: Integer;
 nField: string = ''): string;
var nStr: string;
begin
  if nPos > 0 then
       nStr := Format('%s_%d', [nName, nPos])
  else nStr := nName;

  if nField = '' then
    nField := nName;
  //xxxxx

  Result := Trim(nDS.FieldByName(nStr).AsString);
  Result := SF(nField, Result);
end;

//Date: 2014-12-29
//Parm: 交货单(多个)[FIn.FData]
//Desc: 同步交货单发货数据到NC计量榜单表中
function TWorkerBusinessCommander.SyncNC_ME25(var nData: string): Boolean;
var nStr,nSQL: string;
    nIdx: Integer;
    nDS: TDataSet;
    nDateMin: TDateTime;
    nWorker: PDBWorker;
    nBills: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  FListA.Text := FIn.FData;
  nStr := AdjustListStrFormat2(FListA, '''', True, ',', False, False);

  nSQL := 'Select L_ID,L_ZhiKa,L_SaleMan,L_Truck,L_Value,L_PValue,L_PDate,' +
          {$IFDEF LineGroup}
          'dict.D_ParamC As ncLineID, '      +    //NC生产线编号
          {$ENDIF}
          'L_PMan,L_MValue,L_MDate,L_MMan,L_OutFact,L_Date,L_Seal,P_ID From $Bill ' +
          '  Left Join $PLOG On P_Bill=L_ID ' +
          {$IFDEF LineGroup}
          '  Left Join $Dict dict On D_Value=L_LineGroup ' +
          '       And dict.D_Name=''$GROUP'' ' +
          {$ENDIF}
          'Where L_ID In ($ID)';
  nSQL := MacroValue(nSQL, [MI('$BILL', sTable_Bill),
          MI('$PLOG', sTable_PoundLog), MI('$ID', nStr),
          MI('$Dict', sTable_SysDict),MI('$GROUP', sFlag_ZTLineGroup)]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := '发货单[ %s ]信息已丢失.';
      nData := Format(nData, [CombinStr(FListA, ',', False)]);
      Exit;
    end;

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    SetLength(nBills, RecordCount);
    nIdx := 0;

    FListA.Clear;
    First;

    while not Eof do
    begin
      with nBills[nIdx] do
      begin
        FID         := FieldByName('L_ID').AsString;
        FZhiKa      := FieldByName('L_ZhiKa').AsString;
        FType       := FieldByName('L_SaleMan').AsString;
        FTruck      := FieldByName('L_Truck').AsString;
        FValue      := FieldByName('L_Value').AsFloat;
        FMemo       := FieldByName('L_Seal').AsString;

        if FListA.IndexOf(FZhiKa) < 0 then
          FListA.Add(FZhiKa);
        //订单项

        FPoundID := FieldByName('P_ID').AsString;
        //榜单编号
        if FPoundID = '' then
        begin
          if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
            raise Exception.Create(nOut.FData);
          FPoundID := nOut.FData;
        end;

        nDateMin := Str2Date('2000-01-01');
        //最小日期参考

        with FPData do
        begin
          FValue    := FieldByName('L_PValue').AsFloat;
          FDate     := FieldByName('L_PDate').AsDateTime;
          FOperator := FieldByName('L_PMan').AsString;

          if FDate < nDateMin then
            FDate := FieldByName('L_Date').AsDateTime;
          //xxxxx

          if FDate < nDateMin then
            FDate := Date();
          //xxxxx
        end;

        with FMData do
        begin
          FValue    := FieldByName('L_MValue').AsFloat;
          FDate     := FieldByName('L_MDate').AsDateTime;
          FOperator := FieldByName('L_MMan').AsString;

          if FDate < nDateMin then
            FDate := FieldByName('L_OutFact').AsDateTime;
          //xxxxx

          if FDate < nDateMin then
            FDate := Date();
          //xxxxx
        end;

        {$IFDEF LineGroup}
        FLineGroup := FieldByName('ncLineID').AsString;
        {$ENDIF}
      end;

      Inc(nIdx);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  nStr := AdjustListStrFormat2(FListA, '''', True, ',', False, False);
  //订单列表

  nSQL := 'select t1.*,t2.* from meam_bill t1 ' +
          '  left join meam_bill_b t2 on t2.PK_MEAMBILL=t1.PK_MEAMBILL ' +
          'where pk_meambill_b in (%s)';
  nSQL := Format(nSQL, [nStr]);

  nWorker := nil;
  try
    nDS := gDBConnManager.SQLQuery(nSQL, nWorker, sFlag_DB_NC);
    with nDS do
    begin
      if RecordCount < 1 then
      begin
        nData := '发货单[ %s ]信息已丢失.';
        nData := Format(nData, [CombinStr(FListA, ',', False)]);
        Exit;
      end;

      FListA.Clear;
      //init sql list

      for nIdx:=Low(nBills) to High(nBills) do
      begin
        First;
        //init cursor

        while not Eof do
        begin
          nStr := FieldByName('pk_meambill_b').AsString;
          if nStr = nBills[nIdx].FZhiKa then Break;
          Next;
        end;

        if Eof then Continue;
        //订单丢失则不予处理

        if nBills[nIdx].FType = 'ME09' then
             nBills[nIdx].FType := '0001ZA1000000001VYRH'
        else nBills[nIdx].FType := '0001AA10000000009NEY';
        //业务类型转业务模式

        nSQL := MakeSQLByStr([SF('bbillreturn', 'N'),
                SF('bneedcheckgross', 'N'),
                SF('bneedchecktare', 'N'),
                SF('bnowreturn', 'N'),
                SF('bpackage', 'N'),
                SF('bpushbillstatus', 'N'),
                SF('breturn', 'N'),
                SF('bsame_ew', 'N'),

                SF('cmainunit', FieldByName('cmainunit').AsString),
                SF('coperatorid', FieldByName('coperator').AsString),

                MakeField(nDS, 'pk_corp_from', 1, 'coutcorpid'),
                MakeField(nDS, 'pk_callbody_from', 1, 'coutcalbodyid'),
                MakeField(nDS, 'pk_warehouse_from', 1, 'coutwarehouseid'),
                MakeField(nDS, 'pk_warehouse_main', 0, 'cinwarehouseid'),
                MakeField(nDS, 'pk_callbody_main', 0, 'cincalbodyid'),
                MakeField(nDS, 'pk_corp_main', 0, 'cincorpid'),

                SF('cvehicle', nBills[nIdx].FTruck),
                SF('dbizdate', Date2Str(nBills[nIdx].FMData.FDate)),
                SF('dconfirmdate', Date2Str(nBills[nIdx].FPData.FDate)),
                SF('dconfirmtime', DateTime2Str(nBills[nIdx].FPData.FDate)),
                SF('ddelivmaketime', DateTime2Str(nBills[nIdx].FPData.FDate)),
                SF('dgrossdate', Date2Str(nBills[nIdx].FMData.FDate)),
                SF('dgrosstime', DateTime2Str(nBills[nIdx].FMData.FDate)),
                SF('dlastmoditime', DateTime2Str(nBills[nIdx].FPData.FDate)),
                SF('dmaketime', DateTime2Str(nBills[nIdx].FPData.FDate)),
                SF('dr', 0, sfVal),
                SF('dtaredate', Date2Str(nBills[nIdx].FPData.FDate)),
                SF('dtaretime', DateTime2Str(nBills[nIdx].FPData.FDate)),
                SF('ncreatetype', 1, sfVal),
                SF('ndelivbillprintcount', 1, sfVal),
                SF('ngross', nBills[nIdx].FMData.FValue, sfVal),
                SF('nmeammodel', 0, sfVal),
                SF('nnet', nBills[nIdx].FValue, sfVal),
                SF('nplannum', FieldByName('nplannum').AsFloat, sfVal),
                SF('nstatus', '100', sfVal),
                SF('ntare', nBills[nIdx].FPData.FValue, sfVal),
                SF('ntareauditstatus', 1, sfVal),
                SF('nweighmodel', '0', sfVal),

                SF('pk_bsmodel', nBills[nIdx].FType),
                //SF('pk_corp', FieldByName('pk_corp').AsString),
                MakeField(nDS, 'pk_corp_from', 1, 'pk_corp'),

                SF('pk_cumandoc', FieldByName('pk_cumandoc').AsString),
                SF('pk_invbasdoc', FieldByName('pk_invbasdoc').AsString),
                SF('pk_invmandoc', FieldByName('pk_invmandoc').AsString),
                SF('pk_poundbill', nBills[nIdx].FPoundID),
                SF('ts', DateTime2Str(nBills[nIdx].FMData.FDate)),
                SF('vbillcode', nBills[nIdx].FPoundID),
                SF('vdef7', nBills[nIdx].FLineGroup),
                MakeField(nDS, 'vdef1', 0),
                MakeField(nDS, 'vdef10', 0),
                MakeField(nDS, 'vdef11', 0),
                MakeField(nDS, 'vdef12', 0),
                MakeField(nDS, 'vdef13', 0),
                MakeField(nDS, 'vdef14', 0),
                MakeField(nDS, 'vdef15', 0),
                MakeField(nDS, 'vdef16', 0),
                MakeField(nDS, 'vdef17', 0),
                MakeField(nDS, 'vdef18', 0),
                MakeField(nDS, 'vdef19', 0),
                MakeField(nDS, 'vdef2', 0),
                MakeField(nDS, 'vdef20', 0),
                MakeField(nDS, 'vdef3', 0),
                MakeField(nDS, 'vdef4', 0),
                MakeField(nDS, 'vdef5', 0),
                MakeField(nDS, 'vdef6', 0),
                MakeField(nDS, 'vdef8', 0),
                MakeField(nDS, 'vdef9', 0),
                SF('vsourcebillcode', FieldByName('vbillcode').AsString),
                SF('wayofpoundcorrent', '1')
                ], 'meam_poundbill', '', True);
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([SF('cassunit', FieldByName('cassunit').AsString),
                SF('dbizdate', Date2Str(nBills[nIdx].FMData.FDate)),
                SF('dr', 0, sfVal),
                SF('nassrate', FieldByName('nassrate').AsString, sfVal),
                SF('nconfirmnum', nBills[nIdx].FValue, sfVal),
                SF('ndelivplannum', nBills[nIdx].FValue, sfVal),
                SF('nexecnum', FieldByName('nexecnum').AsFloat, sfVal),
                SF('nnet', nBills[nIdx].FValue, sfVal),
                SF('nplannum', FieldByName('nplannum').AsFloat, sfVal),

                MakeField(nDS, 'pk_corp_from', 1, 'pk_corp'),

                SF('pk_poundbill', nBills[nIdx].FPoundID),
                SF('pk_poundbill_b', nBills[nIdx].FPoundID + '_2'),
                SF('pk_sourcebill', FieldByName('pk_meambill').AsString),
                SF('pk_sourcebill_b', FieldByName('pk_meambill_b').AsString),
                SF('ts', DateTime2Str(nBills[nIdx].FMData.FDate)),
                SF('vbatchcode', nBills[nIdx].FMemo),
                SF('vdef7', nBills[nIdx].FLineGroup),
                MakeField(nDS, 'vdef1', 1),
                MakeField(nDS, 'vdef10', 1),
                MakeField(nDS, 'vdef11', 1),
                MakeField(nDS, 'vdef12', 1),
                MakeField(nDS, 'vdef13', 1),
                MakeField(nDS, 'vdef14', 1),
                MakeField(nDS, 'vdef15', 1),
                MakeField(nDS, 'vdef16', 1),
                MakeField(nDS, 'vdef17', 1),
                MakeField(nDS, 'vdef18', 1),
                MakeField(nDS, 'vdef19', 1),
                MakeField(nDS, 'vdef2', 1),
                MakeField(nDS, 'vdef20', 1),
                MakeField(nDS, 'vdef3', 1),
                MakeField(nDS, 'vdef4', 1),
                MakeField(nDS, 'vdef5', 1),
                MakeField(nDS, 'vdef6', 1),
                MakeField(nDS, 'vdef8', 1),
                MakeField(nDS, 'vdef9', 1),
                SF('vsourcebillcode', FieldByName('vbillcode').AsString)
                ], 'meam_poundbill_b', '', True);
        FListA.Add(nSQL);
      end;

      nWorker.FConn.BeginTrans;
      try
        for nIdx:=0 to FListA.Count - 1 do
          gDBConnManager.WorkerExec(nWorker, FListA[nIdx]);
        //xxxxx
        
        nWorker.FConn.CommitTrans;
        Result := True;
      except
        on E:Exception do
        begin
          nWorker.FConn.RollbackTrans;
          nData := '同步NC计量榜单错误,描述: ' + E.Message;
          Exit;
        end;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;

//Date: 2015-01-08
//Parm: 榜单号(单个)[FIn.FData]
//Desc: 同步原料过磅数据到NC计量榜单表中
function TWorkerBusinessCommander.SyncNC_ME03(var nData: string): Boolean;
var nStr,nSQL: string;
    nIdx: Integer;
    nDS: TDataSet;
    nWorker: PDBWorker;
    nBills: TLadingBillItems;
begin
  Result := False;
  nStr := 'Select * From %s Where P_ID=''%s''';
  nStr := Format(nStr, [sTable_PoundLog, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '称重单据[ %s ]信息已丢失.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    SetLength(nBills, 1);
    First;

    with nBills[0] do
    begin
      FID      := FieldByName('P_Order').AsString;
      FZhiKa   := FieldByName('P_Order').AsString;
      FTruck   := FieldByName('P_Truck').AsString;
      FPoundID := FieldByName('P_ID').AsString;
      FMemo    := FieldByName('P_Memo').AsString;

      if FZhiKa = '' then
      begin
        nData := '称重单据[ %s ]信订单号为空.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;

      if FIn.FExtParam <> '' then
        FZhiKa := FIn.FExtParam;
      //xxxxx

      with FPData do
      begin
        FValue    := FieldByName('P_PValue').AsFloat;
        FDate     := FieldByName('P_PDate').AsDateTime;
        FOperator := FieldByName('P_PMan').AsString;
      end;

      with FMData do
      begin
        FValue    := FieldByName('P_MValue').AsFloat;
        FDate     := FieldByName('P_MDate').AsDateTime;
        FOperator := FieldByName('P_MMan').AsString;
      end;

      FKZValue := FieldByName('P_KZValue').AsFloat;

      if Assigned(FindField('P_PDValue')) then
           FPDValue := FieldByName('P_PDValue').AsFloat
      else FPDValue := 0;

      FValue := Float2Float(FMData.FValue - FPData.FValue - FKZValue,
                cPrecision, False);
      //供应量
    end;
  end;

  //----------------------------------------------------------------------------
  nStr := 'select t1.*,t2.* from meam_bill t1 ' +
          '  left join meam_bill_b t2 on t2.PK_MEAMBILL=t1.PK_MEAMBILL ' +
          'where pk_meambill_b=''%s''';
  nStr := Format(nStr, [nBills[0].FZhiKa]);

  nWorker := nil;
  try
    nDS := gDBConnManager.SQLQuery(nStr, nWorker, sFlag_DB_NC);
    with nDS do
    begin
      if RecordCount < 1 then
      begin
        nData := 'NC订单[ %s ]信息已丢失.';
        nData := Format(nData, [nBills[0].FZhiKa]);
        Exit;
      end;

      FListA.Clear;
      nIdx := 0;
      First;

      nSQL := MakeSQLByStr([SF('bbillreturn', 'N'),
              SF('bneedcheckgross', 'N'),
              SF('bneedchecktare', 'N'),
              SF('bnowreturn', 'N'),
              SF('bpackage', 'N'),
              SF('bpushbillstatus', 'N'),
              SF('bsame_ew', 'N'),

              SF('nabatenum', nBills[nIdx].FKZValue, sfVal),
              SF('nclientabatenum', nBills[nIdx].FPDValue, sfVal),
              SF('breturn', FieldByName('breplenishflag').AsString),
              SF('cmainunit', FieldByName('cmainunit').AsString),
              SF('coperatorid', FieldByName('coperator').AsString),

              MakeField(nDS, 'pk_callbody_main', 1, 'cincalbodyid'),
              MakeField(nDS, 'pk_corp_main', 1, 'cincorpid'),
              MakeField(nDS, 'pk_warehouse_main', 1, 'cinwarehouseid'),

              SF('cvehicle', nBills[nIdx].FTruck),
              SF('dbizdate', Date2Str(nBills[nIdx].FPData.FDate)),
              SF('dconfirmdate', Date2Str(nBills[nIdx].FPData.FDate)),
              SF('dconfirmtime', DateTime2Str(nBills[nIdx].FPData.FDate)),
              SF('ddelivmaketime', DateTime2Str(nBills[nIdx].FPData.FDate)),
              SF('dgrossdate', Date2Str(nBills[nIdx].FMData.FDate)),
              SF('dgrosstime', DateTime2Str(nBills[nIdx].FMData.FDate)),
              SF('dlastmoditime', DateTime2Str(nBills[nIdx].FPData.FDate)),
              SF('dmaketime', DateTime2Str(nBills[nIdx].FPData.FDate)),
              SF('dr', 0, sfVal),
              SF('dtaredate', Date2Str(nBills[nIdx].FPData.FDate)),
              SF('dtaretime', DateTime2Str(nBills[nIdx].FPData.FDate)),
              SF('ncreatetype', FieldByName('icreatetype').AsInteger, sfVal),
              SF('ndelivbillprintcount', 1, sfVal),
              SF('ngross', nBills[nIdx].FMData.FValue, sfVal),
              SF('nmeammodel', FieldByName('nmeammodel').AsInteger, sfVal),
              SF('nnet', nBills[nIdx].FValue, sfVal),
              SF('nplannum', FieldByName('nplannum').AsFloat, sfVal),
              SF('nstatus', '100', sfVal),
              SF('ntare', nBills[nIdx].FPData.FValue, sfVal),
              SF('ntareauditstatus', 1, sfVal),
              SF('nweighmodel', '1', sfVal),

              SF('pk_bsmodel', '0001ZA1000000001SIJ7'),
              MakeField(nDS, 'pk_corp_main', 1, 'pk_corp'),
              //SF('pk_corp', FieldByName('pk_corp').AsString),

              SF('pk_cumandoc', FieldByName('pk_cumandoc').AsString),
              SF('pk_invbasdoc', FieldByName('pk_invbasdoc').AsString),
              SF('pk_invmandoc', FieldByName('pk_invmandoc').AsString),
              SF('pk_poundbill', nBills[nIdx].FPoundID),
              SF('ts', DateTime2Str(nBills[nIdx].FMData.FDate)),
              SF('vbillcode', nBills[nIdx].FPoundID),
              SF('vdef11', nBills[nIdx].FMemo),                                 //备注;堆场
              MakeField(nDS, 'vdef1', 0),
              MakeField(nDS, 'vdef10', 0),
              MakeField(nDS, 'vdef12', 0),
              MakeField(nDS, 'vdef13', 0),
              MakeField(nDS, 'vdef14', 0),
              MakeField(nDS, 'vdef15', 0),
              MakeField(nDS, 'vdef16', 0),
              MakeField(nDS, 'vdef17', 0),
              MakeField(nDS, 'vdef18', 0),
              MakeField(nDS, 'vdef19', 0),
              MakeField(nDS, 'vdef2', 0),
              MakeField(nDS, 'vdef20', 0),
              MakeField(nDS, 'vdef3', 0),
              MakeField(nDS, 'vdef4', 0),
              MakeField(nDS, 'vdef5', 0),
              MakeField(nDS, 'vdef6', 0),
              MakeField(nDS, 'vdef7', 0),
              MakeField(nDS, 'vdef8', 0),
              MakeField(nDS, 'vdef9', 0),
              SF('vsourcebillcode', FieldByName('vbillcode').AsString),
              SF('wayofpoundcorrent', '1')
              ], 'meam_poundbill', '', True);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([SF('cassunit', FieldByName('cassunit').AsString),
              SF('dbizdate', Date2Str(nBills[nIdx].FPData.FDate)),
              SF('dr', 0, sfVal),
              SF('nassrate', FieldByName('nassrate').AsFloat, sfVal),
              SF('nassnum', FieldByName('nplanassnum').AsFloat, sfVal),
              SF('nexecnum', FieldByName('nexecnum').AsFloat, sfVal),
              SF('nnet', nBills[nIdx].FValue, sfVal),
              SF('nplannum', FieldByName('nplannum').AsFloat, sfVal),

              SF('pk_poundbill', nBills[nIdx].FPoundID),
              SF('pk_poundbill_b', nBills[nIdx].FPoundID + '_2'),
              SF('pk_sourcebill', FieldByName('pk_meambill').AsString),
              SF('pk_sourcebill_b', FieldByName('pk_meambill_b').AsString),
              SF('ts', DateTime2Str(nBills[nIdx].FMData.FDate)),
              SF('vbatchcode', FieldByName('vbatchcode').AsString),
              SF('vdef11', nBills[nIdx].FMemo),                                 //备注;堆场
              MakeField(nDS, 'vdef1', 1),
              MakeField(nDS, 'vdef10', 1),
              //MakeField(nDS, 'vdef11', 1),
              MakeField(nDS, 'vdef12', 1),
              MakeField(nDS, 'vdef13', 1),
              MakeField(nDS, 'vdef14', 1),
              MakeField(nDS, 'vdef15', 1),
              MakeField(nDS, 'vdef16', 1),
              MakeField(nDS, 'vdef17', 1),
              MakeField(nDS, 'vdef18', 1),
              MakeField(nDS, 'vdef19', 1),
              MakeField(nDS, 'vdef2', 1),
              MakeField(nDS, 'vdef20', 1),
              MakeField(nDS, 'vdef3', 1),
              MakeField(nDS, 'vdef4', 1),
              MakeField(nDS, 'vdef5', 1),
              MakeField(nDS, 'vdef6', 1),
              MakeField(nDS, 'vdef7', 1),
              MakeField(nDS, 'vdef8', 1),
              MakeField(nDS, 'vdef9', 1),
              SF('vsourcebillcode', FieldByName('vbillcode').AsString)
              ], 'meam_poundbill_b', '', True);
      FListA.Add(nSQL);

      nWorker.FConn.BeginTrans;
      try
        for nIdx:=0 to FListA.Count - 1 do
          gDBConnManager.WorkerExec(nWorker, FListA[nIdx]);
        //xxxxx

        nWorker.FConn.CommitTrans;
        Result := True;
      except
        on E:Exception do
        begin
          nWorker.FConn.RollbackTrans;
          nData := '同步NC计量榜单错误,描述: ' + E.Message;
          Exit;
        end;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;

//Date: 2017/6/25
//Parm: 回空单据号
//Desc: 同步回空单过磅数据到NC计量榜单表中
function TWorkerBusinessCommander.SyncNC_HaulBack(var nData: string): Boolean;
var nSQL, nStr: string;
    nIdx: Integer;
    nNet, nRetnet: Double;
    nDS: TDataSet;
    nWorker: PDBWorker;
    nBills: TLadingBillItems;
begin
  Result := False;

  nSQL := 'Select P_ID, H_ID, H_LPID, H_PValue, H_PDate, H_MValue, H_MDate ' +
          'From $BillHaul ' +
          '  Left Join $PLOG On P_Bill=H_ID ' +
          'Where H_ID=''$ID''';
  nSQL := MacroValue(nSQL, [MI('$BillHaul', sTable_BillHaulBack),
          MI('$PLOG', sTable_PoundLog), MI('$ID', FIn.FData)]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := '回空单[ %s ]信息已丢失.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    SetLength(nBills, RecordCount);
    nIdx := 0;

    FListA.Clear;
    First;

    while not Eof do
    begin
      with nBills[nIdx] do
      begin
        FID         := FieldByName('H_ID').AsString;
        FPoundID    := FieldByName('P_ID').AsString;                  //回空磅单
        if FPoundID = '' then
          FPoundID  := FID;

        with FPData do
        begin
          FValue    := FieldByName('H_PValue').AsFloat;
          FDate     := FieldByName('H_PDate').AsDateTime;
        end;

        with FMData do
        begin
          FValue    := FieldByName('H_MValue').AsFloat;
          FDate     := FieldByName('H_MDate').AsDateTime;
        end;

        FMuiltiPound := FieldByName('H_LPID').AsString;
        //原始磅单号
      end;

      Inc(nIdx);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  nSQL := 'select p1.*,p2.* from meam_poundbill p1 ' +
          '  left join meam_poundbill_b p2 on p2.PK_poundBILL=p1.PK_poundBILL ' +
          'where vbillcode = ''%s''';
  nSQL := Format(nSQL, [nBills[0].FMuiltiPound]);

  nWorker := nil;
  try
    nDS := gDBConnManager.SQLQuery(nSQL, nWorker, sFlag_DB_NC);
    with nDS do
    begin
      if RecordCount < 1 then
      begin
        nData := '原始磅单[ %s ]信息已丢失.';
        nData := Format(nData, [nBills[0].FMuiltiPound]);
        Exit;
      end;

      FListA.Clear;
      //init sql list

      for nIdx:=Low(nBills) to High(nBills) do
      begin
        First;
        //init cursor

        while not Eof do
        begin
          nStr := FieldByName('vbillcode').AsString;
          if nStr = nBills[nIdx].FMuiltiPound then Break;
          Next;
        end;

        if Eof then Continue;
        //磅单丢失则不予处理

        nNet := FieldByName('nnet').AsFloat;
        nRetnet := FieldByName('ngross').AsFloat - nBills[nIdx].FMData.FValue;
        nRetnet := Float2Float(nRetnet, cPrecision, False);

        nSQL := MakeSQLByStr([
                SF('dbizdate', Date2Str(nBills[nIdx].FMData.FDate)),            //回空日期
                SF('dreturntaretime', DateTime2Str(nBills[nIdx].FMData.FDate)), //回空时间
                SF('nreturntare', nBills[nIdx].FMData.FValue, sfVal),
                SF('nreturnnet', nRetnet, sfVal)
                ], 'meam_poundbill', SF('vbillcode', nBills[nIdx].FPoundID), False);
        FListA.Add(nSQL);
        //更新回空信息

        nSQL := MakeSQLByStr([SF('cassunit', FieldByName('cassunit').AsString),
                SF('dbizdate', Date2Str(nBills[nIdx].FMData.FDate)),
                SF('dr', 0, sfVal),
                SF('nassrate', FieldByName('nassrate').AsString, sfVal),
                SF('nconfirmnum', FieldByName('nconfirmnum').AsString, sfVal),
                SF('ndelivplannum', FieldByName('ndelivplannum').AsString, sfVal),
                SF('nexecnum', FieldByName('nexecnum').AsFloat, sfVal),
                SF('nnet', Float2Float(nRetnet - nNet, cPrecision, False), sfVal),
                SF('nplannum', FieldByName('nplannum').AsFloat, sfVal),
                SF('pk_corp', FieldByName('pk_corp').AsString),

                SF('pk_poundbill', nBills[nIdx].FMuiltiPound),
                SF('pk_poundbill_b', nBills[nIdx].FPoundID + '_2'),
                SF('pk_sourcebill', FieldByName('pk_sourcebill').AsString),
                SF('pk_sourcebill_b', FieldByName('pk_sourcebill_b').AsString),
                SF('ts', DateTime2Str(nBills[nIdx].FMData.FDate)),
                SF('vbatchcode', FieldByName('vbatchcode').AsString),
                MakeField(nDS, 'vdef1', 1),
                MakeField(nDS, 'vdef10', 1),
                MakeField(nDS, 'vdef11', 1),
                MakeField(nDS, 'vdef12', 1),
                MakeField(nDS, 'vdef13', 1),
                MakeField(nDS, 'vdef14', 1),
                MakeField(nDS, 'vdef15', 1),
                MakeField(nDS, 'vdef16', 1),
                MakeField(nDS, 'vdef17', 1),
                MakeField(nDS, 'vdef18', 1),
                MakeField(nDS, 'vdef19', 1),
                MakeField(nDS, 'vdef2', 1),
                MakeField(nDS, 'vdef20', 1),
                MakeField(nDS, 'vdef3', 1),
                MakeField(nDS, 'vdef4', 1),
                MakeField(nDS, 'vdef5', 1),
                MakeField(nDS, 'vdef6', 1),
                MakeField(nDS, 'vdef7', 1),
                MakeField(nDS, 'vdef8', 1),
                MakeField(nDS, 'vdef9', 1),
                SF('vsourcebillcode', FieldByName('vsourcebillcode').AsString)
                ], 'meam_poundbill_b', '', True);
        FListA.Add(nSQL);
      end;

      nWorker.FConn.BeginTrans;
      try
        for nIdx:=0 to FListA.Count - 1 do
          gDBConnManager.WorkerExec(nWorker, FListA[nIdx]);
        //xxxxx
        
        nWorker.FConn.CommitTrans;
        Result := True;
      except
        on E:Exception do
        begin
          nWorker.FConn.RollbackTrans;
          nData := '同步NC计量榜单错误,描述: ' + E.Message;
          Exit;
        end;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/6/18
//Parm: 
//Desc: 获取磅表跳动基数
function TWorkerBusinessCommander.GetPoundBaseValue(var nData: string): Boolean;
var nStr: string;
    nWCValue: Double;
begin
  nWCValue := 0;
  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_PoundBaseValue]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nWCValue := Fields[0].AsFloat;
  end;

  FOut.FData := FloatToStr(nWCValue * 1000 / 1000);
  Result := True;
end;

//------------------------------------------------------------------------------
//Date: 2015/6/18
//Parm: 原始数据，数据跳动范围
//Desc: 格式化数据
function FormatValue(const nSrcValue, nWCValue: Extended): Extended;
begin
  if nWCValue = 0 then
  begin
    Result := nSrcValue;
    Exit;
  end;

  Result := Trunc(nSrcValue) div 100 * 100;
  Result := Result + Trunc(nSrcValue) mod 100
            div Trunc(nWCValue) * Trunc(nWCValue);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Date: 2015/9/9
//Parm: 用户名，密码；返回用户数据
//Desc: 用户登录
function TWorkerBusinessCommander.Login(var nData: string): Boolean;
var nStr: string;
begin
  Result := False;

  FListA.Clear;
  FListA.Text := PackerDecodeStr(FIn.FData);
  if FListA.Values['User']='' then Exit;
  //未传递用户名

  nStr := 'Select U_Password From %s Where U_Name=''%s''';
  nStr := Format(nStr, [sTable_User, FListA.Values['User']]);
  //card status

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount<1 then Exit;

    nStr := Fields[0].AsString;
    if nStr<>FListA.Values['Password'] then Exit;
    {
    if CallMe(cBC_ServerNow, '', '', @nOut) then
         nStr := PackerEncodeStr(nOut.FData)
    else nStr := IntToStr(Random(999999));

    nInfo := FListA.Values['User'] + nStr;
    //xxxxx

    nStr := 'Insert into $EI(I_Group, I_ItemID, I_Item, I_Info) ' +
            'Values(''$Group'', ''$ItemID'', ''$Item'', ''$Info'')';
    nStr := MacroValue(nStr, [MI('$EI', sTable_ExtInfo),
            MI('$Group', sFlag_UserLogItem), MI('$ItemID', FListA.Values['User']),
            MI('$Item', PackerEncodeStr(FListA.Values['Password'])),
            MI('$Info', nInfo)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);  }

    Result := True;
  end;
end;
//------------------------------------------------------------------------------
//Date: 2015/9/9
//Parm: 用户名；验证数据
//Desc: 用户注销
function TWorkerBusinessCommander.LogOut(var nData: string): Boolean;
//var nStr: string;
begin
  {nStr := 'delete From %s Where I_ItemID=''%s''';
  nStr := Format(nStr, [sTable_ExtInfo, PackerDecodeStr(FIn.FData)]);
  //card status


  if gDBConnManager.WorkerExec(FDBConn, nStr)<1 then
       Result := False
  else Result := True;     }

  Result := True;
end;

//Date: 2017/3/1
//Parm: 车厢编号[FIn.FData]
//Desc: 获取火车衡过磅数据(使用配对模式,未称重)
function TWorkerBusinessCommander.GetStationPoundData(var nData: string): Boolean;
var nStr: string;
    nPound: TLadingBillItems;
begin
  SetLength(nPound, 1);
  FillChar(nPound[0], SizeOf(TLadingBillItem), #0);

  nStr := 'Select * From %s ' +
          'Where P_Truck=''%s'' And P_PModel=''%s'' And ' +
          '((P_MValue Is Null) or (P_MValue Is not null And P_MDate > %s - 2)) ';
  nStr := Format(nStr, [sTable_PoundStation, FIn.FData, sFlag_PoundPD,
          sField_SQLServer_Now]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr),nPound[0] do
  begin
    if RecordCount > 0 then
    begin
      FID         := FieldByName('P_Bill').AsString;
      FZhiKa      := FieldByName('P_Order').AsString;
      
      FCusID      := FieldByName('P_CusID').AsString;
      FCusName    := FieldByName('P_CusName').AsString;
      FTruck      := FieldByName('P_Truck').AsString;
      FValue      := FieldByName('P_LimValue').AsFloat;

      FType       := FieldByName('P_MType').AsString;
      FStockNo    := FieldByName('P_MID').AsString;
      FStockName  := FieldByName('P_MName').AsString;

      with FPData do
      begin
        FStation  := FieldByName('P_PStation').AsString;
        FValue    := FieldByName('P_PValue').AsFloat;
        FDate     := FieldByName('P_PDate').AsDateTime;
        FOperator := FieldByName('P_PMan').AsString;
      end;  

      FFactory    := FieldByName('P_FactID').AsString;
      FOrigin     := FieldByName('P_Origin').AsString;
      FPModel     := FieldByName('P_PModel').AsString;
      FPType      := FieldByName('P_Type').AsString;
      FPoundID    := FieldByName('P_ID').AsString;

      FStatus     := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckBFM;
      FSelected   := True;
    end else
    begin
      FTruck      := FIn.FData;
      FPModel     := sFlag_PoundPD;

      FStatus     := '';
      FNextStatus := sFlag_TruckBFP;
      FSelected   := True;
    end;
  end;

  FOut.FData := CombineBillItmes(nPound);
  Result := True;
end;

//Date: 2017/3/1
//Parm: 称重数据[FIn.FData]
//Desc: 保存火车衡称重数据
function TWorkerBusinessCommander.SaveStationPoundData(var nData: string): Boolean;
var nAdd: Double;
    nStr,nSQL: string;
    nPound: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  AnalyseBillItems(FIn.FData, nPound);
  //解析数据

  with nPound[0] do
  begin
    TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, FTruck, '', @nOut);
    //保存车牌号

    if FPoundID = '' then
    begin
      if not GetStationTruckValue(nData) then Exit;

      FListC.Clear;
      FListC.Values['Group'] := sFlag_BusGroup;
      FListC.Values['Object'] := sFlag_PStationNo;

      if not CallMe(cBC_GetSerialNO, FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      //xxxxx

      FPoundID := nOut.FData;
      //new id

      if FPModel = sFlag_PoundLS then
           nStr := sFlag_Other
      else nStr := sFlag_Sale;

      nSQL := MakeSQLByStr([
              SF('P_ID', FPoundID),
              SF('P_Type', nStr),
              SF('P_Truck', FTruck),
              SF('P_CusID', FCusID),
              SF('P_CusName', FCusName),
              SF('P_MID', FStockNo),
              SF('P_MName', FStockName),
              SF('P_MType', sFlag_San),
              SF('P_PValue', FPData.FValue, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_FactID', FFactory),
              SF('P_PStation', FPData.FStation),
              SF('P_Direction', '出厂'),
              SF('P_PModel', FPModel),
              SF('P_Status', sFlag_TruckBFP),
              SF('P_Valid', sFlag_Yes),
              SF('P_Order', FZhiKa),              //仓库编号
              SF('P_Origin', FOrigin),            //仓库名称
              SF('P_LimValue', StrToFloat(FOut.FData), sfVal),
              SF('P_PrintNum', 1, sfVal)
              ], sTable_PoundStation, '', True);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    if (FPData.FValue > 0) and (FMData.FValue > 0) then
    begin
      nSQL := 'Select P_PValue, P_MValue, P_Bill From %s ' +
              'Where P_ID=''%s'' And P_MValue Is not NULL';
      nSQL := Format(nSQL, [sTable_PoundStation, FPoundID]);
      //重复2次过磅

      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if RecordCount > 0 then
      begin
        FID := Fields[2].AsString;
        nAdd := (FMData.FValue - FPData.FValue) -
                (Fields[1].AsFloat - Fields[0].AsFloat);
        nAdd := Float2Float(nAdd, 100);
      end else

      begin
        with FListC do
        begin
          Clear;
          Values['Type']  := sFlag_TypeStation;
          Values['Value'] := FloatToStr(FMData.FValue - FPData.FValue);
        end;

        if not CallMe(cBC_GetStockBatcode, FStockNo,
          PackerEncodeStr(FListC.Text), @nOut) then
          raise Exception.Create(nOut.FData);
        //xxxxx

        FOut.FBase.FErrCode := nOut.FBase.FErrCode;
        FOut.FBase.FErrDesc := nOut.FBase.FErrDesc;
        FID := nOut.FData;
        //保存批次号

        nAdd := Float2Float(FMData.FValue - FPData.FValue, 100);
      end;

      try
        if FNextStatus = sFlag_TruckBFP then
        begin
          nSQL := MakeSQLByStr([
                  SF('P_PValue', FPData.FValue, sfVal),
                  SF('P_PDate', sField_SQLServer_Now, sfVal),
                  SF('P_PMan', FIn.FBase.FFrom.FUser),
                  SF('P_PStation', FPData.FStation),
                  SF('P_MValue', FMData.FValue, sfVal),
                  SF('P_MDate', DateTime2Str(FMData.FDate)),
                  SF('P_MMan', FMData.FOperator),
                  SF('P_MStation', FMData.FStation),

                  SF('P_Bill', FID),                  //批次号
                  SF('P_Order', FZhiKa),              //仓库编号
                  SF('P_Origin', FOrigin)             //仓库名称
                  ], sTable_PoundStation, SF('P_ID', FPoundID), False);
          //称重时,由于皮重大,交换皮毛重数据
        end else
        begin
          nSQL := MakeSQLByStr([
                  SF('P_MValue', FMData.FValue, sfVal),
                  SF('P_MDate', sField_SQLServer_Now, sfVal),
                  SF('P_MMan', FIn.FBase.FFrom.FUser),
                  SF('P_MStation', FMData.FStation),

                  SF('P_Bill', FID),                  //批次号
                  SF('P_Order', FZhiKa),              //仓库编号
                  SF('P_Origin', FOrigin)             //仓库名称
                  ], sTable_PoundStation, SF('P_ID', FPoundID), False);
          //xxxxx
        end;
        gDBConnManager.WorkerExec(FDBConn, nSQL);

        nSQL := 'Update %s Set B_HasUse=B_HasUse+(%s),B_LastDate=%s ' +
                'Where B_Stock=''%s'' and B_Type=''%s'' ';
        nSQL := Format(nSQL, [sTable_Batcode, FloatToStr(nAdd),
                sField_SQLServer_Now, FStockNo, sFlag_TypeStation]);
        gDBConnManager.WorkerExec(FDBConn, nSQL); //更新批次号使用量
      except
        on nErr: Exception do
        begin
          nSQL := 'Update %s Set P_PValue=P_MValue,P_MValue=Null Where P_ID=''%s''';
          nSQL := Format(nSQL, [sTable_PoundStation, FPoundID]);
          gDBConnManager.WorkerExec(FDBConn, nSQL);

          nData := nErr.Message;
          Exit;
        end;
      end;
    end;

    FOut.FData := FPoundID;
    Result := True;
  end;
end;

type
  TStationTruck = record
    FPrefix: string;
    FCusID : string;
    FStock : string;
    FValue : Double;
  end;

  TStationTrucks = array of TStationTruck;

  //------------------------------------------------------------------------------
//Date: 2017/3/23
//Parm: 过磅记录[FIn.FData];
//Desc: 获取车厢对应的标准信息
function TWorkerBusinessCommander.GetStationTruckValue(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nTrucks: TStationTrucks;
    nPound: TLadingBillItems;
begin
  Result := False;
  nData := '未配置车厢标重信息,请先配置标重信息';

  AnalyseBillItems(FIn.FData, nPound);
  //解析数据

  nStr := 'Select * From %s Where S_Valid=''%s''';
  nStr := Format(nStr, [sTable_StationTruck, sFlag_Yes]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    SetLength(nTrucks, RecordCount);
    if RecordCount < 1 then Exit;

    First;
    nIdx := 0;

    while not Eof do
    begin
      with nTrucks[nIdx] do
      begin
        FPrefix := FieldByName('S_TruckPreFix').AsString;
        FStock  := FieldByName('S_Stock').AsString;
        FCusID  := FieldByName('S_CusID').AsString;
        FValue  := FieldByName('S_Value').AsFloat;
      end;  

      Inc(nIdx);
      Next;
    end;
  end;

  for nIdx := Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx], nPound[0] do
  begin
    nStr := Copy(FTruck, 1, Length(FPrefix));

    if CompareStr(UpperCase(nStr), UpperCase(FPrefix)) <> 0 then Continue;
    if CompareStr(UpperCase(FStock), UpperCase(FStockNo)) <> 0 then Continue;
    if CompareStr(UpperCase(nTrucks[nIdx].FCusID), UpperCase(nPound[0].FCusID))
       <> 0 then Continue;

    FOut.FData := FloatToStr(nTrucks[nIdx].FValue);
    Result := True;
    Exit;
  end;
  //前缀+物料+客户优先

  for nIdx := Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx], nPound[0] do
  begin
    nStr := Copy(FTruck, 1, Length(FPrefix));

    if CompareStr(UpperCase(nStr), UpperCase(FPrefix)) <> 0 then Continue;
    if CompareStr(UpperCase(FStock), UpperCase(FStockNo)) <> 0 then Continue;
    if CompareStr(UpperCase(nTrucks[nIdx].FCusID), UpperCase(nPound[0].FCusID))
       <> 0 then Continue;

    FOut.FData := FloatToStr(nTrucks[nIdx].FValue);
    Result := True;
    Exit;
  end;
  //前缀+物料+客户优先

  for nIdx := Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx], nPound[0] do
  begin
    nStr := Copy(FTruck, 1, Length(FPrefix));

    if CompareStr(UpperCase(nStr), UpperCase(FPrefix)) <> 0 then Continue;
    if CompareStr(UpperCase(FStock), UpperCase(FStockNo)) <> 0 then Continue;

    FOut.FData := FloatToStr(nTrucks[nIdx].FValue);
    Result := True;
    Exit;
  end;
  //前缀+物料优先

  for nIdx := Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx], nPound[0] do
  begin
    nStr := Copy(FTruck, 1, Length(FPrefix));

    if CompareStr(UpperCase(nStr), UpperCase(FPrefix)) <> 0 then Continue;
    if CompareStr(UpperCase(nTrucks[nIdx].FCusID), UpperCase(nPound[0].FCusID))
       <> 0 then Continue;

    FOut.FData := FloatToStr(nTrucks[nIdx].FValue);
    Result := True;
    Exit;
  end;
  //前缀+客户优先

  for nIdx := Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx], nPound[0] do
  begin
    nStr := Copy(FTruck, 1, Length(FPrefix));

    if CompareStr(UpperCase(nStr), UpperCase(FPrefix)) <> 0 then Continue;

    FOut.FData := FloatToStr(nTrucks[nIdx].FValue);
    Result := True;
    Exit;
  end;
  //前缀优先
end;

//Date: 2017/6/7
//Parm: NULL
//Desc: 获取商城账号信息
function TWorkerBusinessCommander.GetCustomerInfo(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
    nXmlStr: string;
begin
  nXmlStr:= '<?xml version="1.0" encoding="UTF-8"?>' +
            '<DATA>'                                 +
            '  <head>'                               +
            '    <Factory>$Factory</Factory>'        +
            '  </head>'                              +
            '</DATA>';
  nXmlStr:= MacroValue(nXmlStr,[
            MI('$Factory', gSysParam.FFactory)]);
  //xxxxx

  Result := CallRemoteWorker(sCLI_BusinessWebchat, PackerEncodeStr(nXmlStr), '', @nOut,
            cBC_WebChat_GetCustomerInfo);
  if Result then
       FOut.FData := nOut.FData
  else nData := nOut.FData;
end;

//发送消息
function TWorkerBusinessCommander.SendEventMsg(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
    nXmlStr: string;
begin
  FListA.Text := PackerDecodeStr(FIn.FData);
  nXmlStr :='<?xml version="1.0" encoding="UTF-8"?>'	+
            '<DATA>'                                  +
            '<head>'                                  +
            '  <Factory>$Factory</Factory>'           +
            '  <ToUser>$User</ToUser>'                +
            '  <MsgType>$MsgType</MsgType>'           +
            '</head>'                                 +
            '<Items>'                                 +
            '	  <Item>'                               +
            '	      <BillID>$BillID</BillID>'         +
            '	      <Card>$Card</Card>'               +
            '	      <Truck>$Truck</Truck>'            +
            '	      <StockNo>$StockNO</StockNo>'      +
            '	      <StockName>$StockName</StockName>'+
            '	      <CusID>$CusID</CusID>'            +
            '	      <CusName>$CusName</CusName>'      +
            '	      <CusAccount>0</CusAccount>'       +
            '	      <MakeDate></MakeDate>'            +
            '	      <MakeMan></MakeMan>'              +
            '	      <TransID></TransID>'              +
            '	      <TransName></TransName>'          +
            '	      <NetWeight>$Value</NetWeight>'    +
            '	      <Searial></Searial>'              +
            '	      <OutFact></OutFact>'              +
            '	      <OutMan></OutMan>'                +
            '	  </Item>	'                             +
            '</Items>'                                +
            '   <remark/>'                            +
            '</DATA>';
  nXmlStr:= MacroValue(nXmlStr, [MI('$Factory', gSysParam.FFactory),
            MI('$User', FListA.Values['CusID']),
            MI('$MsgType', FListA.Values['MsgType']),
            MI('$BillID', FListA.Values['BillID']),
            MI('$Card', FListA.Values['Card']),
            MI('$Truck', FListA.Values['Truck']),
            MI('$StockNO', FListA.Values['StockNO']),
            MI('$StockName', FListA.Values['StockName']),
            MI('$CusID', FListA.Values['CusID']),
            MI('$CusName', FListA.Values['CusName']),
            MI('$Value', FListA.Values['Value'])]);
  Result := CallRemoteWorker(sCLI_BusinessWebchat, PackerEncodeStr(nXmlStr), '',
            @nOut,cBC_WebChat_SendEventMsg);
  if Result then
       FOut.FData := sFlag_Yes
  else nData := nOut.FData;
end;

//Date: 2017/6/7
//Parm: NULL
//Desc: 关联(解除关联)商城账号信息
function TWorkerBusinessCommander.EditShopCustom(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
    nXmlStr, nSQL: string;
begin
  FListA.Text := PackerDecodeStr(FIn.FData);
  //xxxxx

  nXmlStr:= '<?xml version="1.0" encoding="UTF-8" ?>'  +
            '<DATA>'                                   +
            '<head>'                                   +
            '  <type>$Type</type>'                     +
            '  <Factory>$Factory</Factory>'            +
            '  <Customer>$WebCusID</Customer>'         +                        //商城账号
            '  <Provider>$WebProID</Provider>'         +                        //商城账号
            '</head>'                                  +
            '<Items>'                                  +
            '  <Item>'                                 +
            '    <cash>0</cash>'                       +
            '    <clientname>$DLCusName</clientname>'  +                        //DL系统客户名称
            '    <clientnumber>$DLCusID</clientnumber>'+                        //DL系统客户编号
            '    <providername>$DLPName</providername>'+                        //DL供应商名
            '    <providernumber>$DLPID</providernumber>' +                     //DL供应商编号
            '  </Item>'                                +
            '</Items>'                                 +
            '<remark>$Remark</remark>'                 +
            '</DATA>';
  nXmlStr:= MacroValue(nXmlStr,[
            MI('$Type', FListA.Values['Type']),
            MI('$Factory', gSysParam.FFactory),
            MI('$WebCusID', FListA.Values['WebCusID']),
            MI('$WebProID', FListA.Values['WebProID']),
            MI('$DLCusName', FListA.Values['DLCusName']),
            MI('$DLCusID', FListA.Values['DLCusID']),
            MI('$DLPName', FListA.Values['DLPName']),
            MI('$DLPID', FListA.Values['DLPID']),
            MI('$Remark', FListA.Values['Remark'])]);
  //去掉空格

  Result := CallRemoteWorker(sCLI_BusinessWebchat, PackerEncodeStr(nXmlStr), '', @nOut,
            cBC_WebChat_EditShopCustom);
  if Result then
  begin


    if FIn.FExtParam = sFlag_Yes then      //销售客户
    begin
      nSQL := 'Update %s Set C_WeiXin=''%s'' Where C_ID=''%s''';
      nSQL := Format(nSQL, [sTable_Customer, FListA.Values['WebUserName'],
              FListA.Values['DLCusID']]);
    end else

    begin
      nSQL := 'Update %s Set P_WeiXin=''%s'' Where P_ID=''%s''';
      nSQL := Format(nSQL, [sTable_Provider, FListA.Values['WebUserName'],
              FListA.Values['DLPID']]); //供应商
    end;

    gDBConnManager.WorkerExec(FDBConn, nSQL);
  end;
end;

//Date: 2017/6/12
//Parm: 客户ID
//Desc: 获取可用订单列表
function TWorkerBusinessCommander.GetOrderList(var nData:string):Boolean;
var nSQL: string;
    nVal: Double;
    nIdx: Integer;
    nWorker: PDBWorker;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  if Trim(FIn.FData) = '' then Exit;

  FListA.Clear;
  FListA.Values['NoDate'] := sFlag_Yes;
  FListA.Values['CustomerID'] := FIn.FData;
  if not CallMe(cBC_GetSQLQueryOrder, '101', PackerEncodeStr(FListA.Text), @nOut) then
  begin
    nData := 'GetOrderList获取NC销售订单语句失败';
    Exit;
  end;

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nOut.FData, nWorker, sFlag_DB_NC) do
    begin
      if RecordCount < 1 then
      begin
        nData := Format('未查询到客户编号[ %s ]对应的订单信息1.', [FIn.FData]);
        Exit;
      end;

      First;
      FListA.Clear;
      FListC.Clear;
      //剩余量信息

      while not Eof do
      try
        with FListB do
        begin
          Values['CusID'] := FieldByName('custcode').AsString;
          Values['CusName'] := FieldByName('custname').AsString;
          Values['PK']    := FieldByName('pk_meambill').AsString;

          Values['ZhiKa'] := FieldByName('VBILLCODE').AsString;
          Values['ZKDate']:= FieldByName('TMakeTime').AsString;

          Values['StockNo']   := FieldByName('invcode').AsString;
          Values['StockName'] := FieldByName('invname').AsString;
          Values['Maxnumber'] := FieldBYName('NPLANNUM').AsString;

          Values['SaleArea']  := FieldByName('areaclname').AsString;
        end;

        FListC.Add(FListB.Values['PK']);
        FListA.Add(PackerEncodeStr(FListB.Text));
      finally
        Next;
      end;
    end;

    if not CallMe(cBC_GetOrderFHValue, PackerEncodeStr(FListC.Text),
       sFlag_Yes, @nOut) then
    begin
      nData := '获取订单[ %s ]已发量失败.';
      nData := Format(nData, [FListC.Text]);
      Exit;
    end;

    FListC.Clear;
    FListC.Text := PackerDecodeStr(nOut.FData);
    //订单已发货量

    for nIdx := FListA.Count - 1 downto 0 do
    begin
      FListB.Text := PackerDecodeStr(FListA[nIdx]);
      nSQL := FListC.Values[FListB.Values['PK']];
      if not IsNumber(nSQL, True) then Continue;

      nVal := Float2Float(StrToFloat(FListB.Values['Maxnumber']) -
              StrToFloat(nSQL), cPrecision, False);
      FListB.Values['Maxnumber'] := FloatToStr(nVal);
      if FloatRelation(nVal, 0, rtLE) then
            FListA.Delete(nIdx)
      else  FListA[nIdx] := PackerEncodeStr(FListB.Text);
    end;

    FOut.FData := PackerEncodeStr(FListA.Text);
    Result := True;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;

function TWorkerBusinessCommander.GetPurchaseList(var nData:string):Boolean;
var nSQL: string;
    nVal: Double;
    nIdx: Integer;
    nWorker: PDBWorker;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  if Trim(FIn.FData) = '' then Exit;

  FListA.Clear;
  FListA.Values['NoDate'] := sFlag_Yes;
  FListA.Values['CustomerID'] := FIn.FData;
  if not CallMe(cBC_GetSQLQueryOrder, '201', PackerEncodeStr(FListA.Text), @nOut) then
  begin
    nData := 'GetOrderList获取NC采购订单语句失败';
    Exit;
  end;

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nOut.FData, nWorker, sFlag_DB_NC) do
    begin
      if RecordCount < 1 then
      begin
        nData := Format('未查询到客户编号[ %s ]对应的采购订单信息.', [FIn.FData]);
        Exit;
      end;

      First;
      FListA.Clear;
      FListC.Clear;
      //剩余量信息

      while not Eof do
      try
        with FListB do
        begin
          Values['ProvID'] := FieldByName('custcode').AsString;
          Values['ProvName'] := FieldByName('custname').AsString;
          Values['PK']    := FieldByName('pk_meambill').AsString;

          Values['ZhiKa'] := FieldByName('VBILLCODE').AsString;
          Values['ZKDate']:= FieldByName('TMakeTime').AsString;

          Values['StockNo']   := FieldByName('invcode').AsString;
          Values['StockName'] := FieldByName('invname').AsString;
          Values['Maxnumber'] := FieldBYName('NPLANNUM').AsString;

          Values['SaleArea']  := FieldByName('vdef10').AsString;
        end;

        FListC.Add(FListB.Values['PK']);
        FListA.Add(PackerEncodeStr(FListB.Text));
      finally
        Next;
      end;
    end;

    if not CallMe(cBC_GetOrderGYValue, PackerEncodeStr(FListC.Text),
       sFlag_Yes, @nOut) then
    begin
      nData := '获取订单[ %s ]已收量失败.';
      nData := Format(nData, [FListC.Text]);
      Exit;
    end;

    FListC.Clear;
    FListC.Text := PackerDecodeStr(nOut.FData);
    //订单已发货量

    for nIdx := FListA.Count - 1 downto 0 do
    begin
      FListB.Text := PackerDecodeStr(FListA[nIdx]);
      nSQL := FListC.Values[FListB.Values['PK']];
      if not IsNumber(nSQL, True) then Continue;

      nVal := Float2Float(StrToFloat(FListB.Values['Maxnumber']) -
              StrToFloat(nSQL), cPrecision, False);
      FListB.Values['Maxnumber'] := FloatToStr(nVal);
      if FloatRelation(nVal, 0, rtLE) then
            FListA.Delete(nIdx)
      else  FListA[nIdx] := PackerEncodeStr(FListB.Text);
    end;

    FOut.FData := PackerEncodeStr(FListA.Text);
    Result := True;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;

function TWorkerBusinessCommander.GetShopOrdersByID(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallRemoteWorker(sCLI_BusinessWebchat, FIn.FData, FIn.FExtParam, @nOut,
            cBC_WebChat_GetShopOrdersByID);
  if Result then
       FOut.FData := nOut.FData
  else nData := nOut.FData;
end;

function TWorkerBusinessCommander.GetShopOrderByNO(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
    nXmlStr, nSQL: string;
    nWorker: PDBWorker;
    nIdx: Integer;
begin
  Result := False;
  nXmlStr:= '<?xml version="1.0" encoding="UTF-8"?>' +
            '<DATA>'                                 +
            '  <head>'                               +
            '    <Factory>$Factory</Factory>'        +
            '    <NO>$No</NO>'        +
            '  </head>'                              +
            '</DATA>';
  nXmlStr:= MacroValue(nXmlStr,[
            MI('$Factory', gSysParam.FFactory),
            MI('$No', FIn.FData)]);
  //xxxxx

  if (not CallRemoteWorker(sCLI_BusinessWebchat, PackerEncodeStr(nXmlStr), '', @nOut,
      cBC_WebChat_GetShopOrderByNO)) or (nOut.FData = '') then
  begin
    nData := '未获取到对应的订单信息.';
    Exit;
  end;

  nWorker := nil;
  try
    nWorker := gDBConnManager.GetConnection(sFlag_DB_NC, nIdx);

    if not Assigned(nWorker) then
    begin
      nData := Format('连接[ %s ]数据库失败(ErrCode: %d).', [sFlag_DB_NC, nIdx]);
      WriteLog(nData);
      Exit;
    end;

    if not nWorker.FConn.Connected then
      nWorker.FConn.Connected := True;
    //conn db

    FListA.Clear;
    FListB.Clear;
    FListC.Clear;

    FListA.Text := PackerDecodeStr(nOut.FData);
    for nIdx := 0 to FListA.Count - 1 do
    begin
      FListB.Text := PackerDecodeStr(FListA[nIdx]);

      if FListB.Values['OrderNO'] = '' then Continue;

      if FListB.Values['OrderType'] = sFlag_Sale then
      if FListC.IndexOf(FListB.Values['OrderNO']) < 0 then
        FListC.Add(FListB.Values['OrderNO']);
    end;
    //查看销售订单

    if FListC.Count > 0 then
    begin
      FListB.Clear;
      FListB.Values['BillCodes'] := AdjustListStrFormat2(FListC, '''', True, ',', False, False);
      if (not CallMe(cBC_GetSQLQueryOrder, '103', PackerEncodeStr(FListB.Text),
          @nOut)) or (nOut.FData = '') then
      begin
        nData := '未获取到[ %s ]对应的数据库查询语句.';
        nData := Format(nData, [FListC.Text]);
        Exit;
      end;

      nSQL := nOut.FData;
      with gDBConnManager.WorkerQuery(nWorker, nSQL) do
      begin
        if RecordCount < 1 then
        begin
          nData := '订单号[ %s ]已无效,请联系管理员重新开单.';
          nData := Format(nData, [FListC.Text]);
          Exit;
        end;

        First;

        while not Eof do
        try
          nSQL := Trim(FieldByName('VBillCode').AsString);
          if nSQL = '' then Continue;

          for nIdx := 0 to FListA.Count - 1 do
          begin
            FListB.Text := PackerDecodeStr(FListA[nIdx]);

            if CompareStr(FListB.Values['OrderNo'], nSQL) = 0 then
            begin
              FListB.Values['Orders']:= FieldByName('pk_meambill').AsString;
              FListB.Values['CusID'] := FieldByName('custcode').AsString;
              FListB.Values['CusName'] := FieldByName('custname').AsString;
              FListB.Values['SendArea']:= FieldByName('areaclname').AsString;
              FListB.Values['Brand'] := FieldByName('vdef5').AsString;
              FListB.Values['StockArea'] := FieldByName('areaclname').AsString;
            end;

            FListA[nIdx] := PackerEncodeStr(FListB.Text);
          end;
        finally
          Next;
        end;
      end;
    end;

    FListC.Clear;
    for nIdx := 0 to FListA.Count - 1 do
    begin
      FListB.Text := PackerDecodeStr(FListA[nIdx]);

      if FListB.Values['OrderNO'] = '' then Continue;

      if FListB.Values['OrderType'] = sFlag_Provide then
      if FListC.IndexOf(FListB.Values['OrderNO']) < 0 then
        FListC.Add(FListB.Values['OrderNO']);
    end;
    //查看采购订单

    if FListC.Count > 0 then
    begin
      FListB.Clear;
      FListB.Values['BillCodes'] := AdjustListStrFormat2(FListC, '''', True, ',', False, False);
      if (not CallMe(cBC_GetSQLQueryOrder, '203', PackerEncodeStr(FListB.Text),
          @nOut)) or (nOut.FData = '') then
      begin
        nData := '未获取到[ %s ]对应的数据库查询语句.';
        nData := Format(nData, [FListC.Text]);
        Exit;
      end;

      nSQL := nOut.FData;
      with gDBConnManager.WorkerQuery(nWorker, nSQL) do
      begin
        if RecordCount < 1 then
        begin
          nData := '订单号[ %s ]已无效,请联系管理员重新开单.';
          nData := Format(nData, [FListC.Text]);
          Exit;
        end;

        First;

        while not Eof do
        try
          nSQL := Trim(FieldByName('VBillCode').AsString);
          if nSQL = '' then Continue;

          for nIdx := 0 to FListA.Count - 1 do
          begin
            FListB.Text := PackerDecodeStr(FListA[nIdx]);

            if CompareStr(FListB.Values['OrderNo'], nSQL) = 0 then
            begin
              FListB.Values['Orders']:= FieldByName('pk_meambill').AsString;
              FListB.Values['CusID'] := FieldByName('custcode').AsString;
              FListB.Values['CusName'] := FieldByName('custname').AsString;
              FListB.Values['SendArea']:= FieldByName('vdef10').AsString;
            end;

            FListA[nIdx] := PackerEncodeStr(FListB.Text);
          end;
        finally
          Next;
        end;
      end;
    end;

    FOut.FData := PackerEncodeStr(FListA.Text);
    Result := True;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;

function TWorkerBusinessCommander.EditShopOrderInfo(var nData:string):Boolean;
var nOut: TWorkerBusinessCommand;
    nXmlStr: string;
begin
  FListA.Text := PackerDecodeStr(FIn.FData);
  //解析信息
  nXmlStr:= '<?xml version="1.0" encoding="UTF-8"?>'  +
            '<DATA>'                                  +
            '  <head>'                                +
            '    <ordernumber>$WebID</ordernumber>'   +
            '    <status>$Status</status>'            +
            '    <NetWeight>$Value</NetWeight>'       +
            '  </head>'                               +
            '</DATA>';
  nXmlStr:= MacroValue(nXmlStr,[
            MI('$WebID', FListA.Values['WebID']),
            MI('$Value', FListA.Values['Value']),
            MI('$Status', FListA.Values['Status'])]);
  //xxxxx

  Result := CallRemoteWorker(sCLI_BusinessWebchat, PackerEncodeStr(nXmlStr), '',
            @nOut, cBC_WebChat_EditShopOrderInfo);
  if Result then
       FOut.FData := sFlag_Yes
  else nData := nOut.FData;
end;

function TWorkerBusinessCommander.GetWaitingForloading(var nData:string):Boolean;
var nFind: Boolean;
    nLine: PLineItem;
    nIdx,nInt, i: Integer;
    nQueues: TQueueListItems;
begin
  gTruckQueueManager.RefreshTrucks(True);
  Sleep(320);
  //刷新数据

  with gTruckQueueManager do
  try
    SyncLock.Enter;
    Result := True;

    FListB.Clear;
    FListC.Clear;

    i := 0;
    SetLength(nQueues, 0);
    //保存查询记录

    for nIdx:=0 to Lines.Count - 1 do
    begin
      nLine := Lines[nIdx];
      if not nLine.FIsValid then Continue;
      //通道无效

      nFind := False;
      for nInt:=Low(nQueues) to High(nQueues) do
      begin
        with nQueues[nInt] do
        if FStockNo = nLine.FStockNo then
        begin
          Inc(FLineCount);
          FTruckCount := FTruckCount + nLine.FRealCount;

          nFind := True;
          Break;
        end;
      end;

      if not nFind then
      begin
        SetLength(nQueues, i+1);
        with nQueues[i] do
        begin
          FStockNO    := nLine.FStockNo;
          FStockName  := nLine.FStockName;

          FLineCount  := 1;
          FTruckCount := nLine.FRealCount;
        end;

        Inc(i);
      end;
    end;

    for nIdx:=Low(nQueues) to High(nQueues) do
    begin
      with FListB, nQueues[nIdx] do
      begin
        Clear;

        Values['StockName'] := FStockName;
        Values['LineCount'] := IntToStr(FLineCount);
        Values['TruckCount']:= IntToStr(FTruckCount);
      end;

      FListC.Add(PackerEncodeStr(FListB.Text));
    end;

    FOut.FData := PackerEncodeStr(FListC.Text);
  finally
    SyncLock.Leave;
  end;
end;

function TWorkerBusinessCommander.VerifyPrintCode(var nData:string):Boolean;
begin
  Result := True;
end;

function TWorkerBusinessCommander.DLSaveShopInfo(var nData:string):Boolean;
var nSQL, nStr: string;
    nIdx, nStatusCmd, nBillCmd: Integer;
begin
  Result := True;
  FListA.Text := PackerDecodeStr(FIn.FData);

  nBillCmd := StrToIntDef(FListA.Values['BillType'], cMsg_WebChat_BillNew);
  case nBillCmd of
  cMsg_WebChat_BillNew: nStatusCmd := cStatus_WeChat_CreateCard;
  cMsg_WebChat_BillFinished: nStatusCmd := cStatus_WeChat_Finished;
  else
    nStatusCmd := -1;
  end;

  if FListA.Values['DLEncode'] = sFlag_No then
       nStr := FListA.Values['DLID']
  else nStr := AdjustListStrFormat(FListA.Values['DLID'], '''', True, ',', False);

  if FListA.Values['MType'] = sFlag_Sale then
  begin
    nSQL := 'Select * From %s Where L_ID In (%s)';
    nSQL := Format(nSQL, [sTable_Bill, nStr]);

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    begin
      if RecordCount < 1 then Exit;

      First;
      FListC.Clear;

      while not Eof do
      try
        nSQL := MakeSQLByStr([
                SF('E_DLID', FieldByName('L_ID').AsString),
                SF('E_MsgType', nBillCmd, sfVal),
                SF('E_Card', FieldByName('L_ID').AsString),
                SF('E_Truck', FieldByName('L_Truck').AsString),
                SF('E_StockNO', FieldByName('L_StockNo').AsString),
                SF('E_StockName', FieldByName('L_StockName').AsString),
                SF('E_CusID', FieldByName('L_CusID').AsString),
                SF('E_CusName', FieldByName('L_CusName').AsString),
                SF('E_Upload', sFlag_No),
                SF('E_Value', FieldByName('L_Value').AsFloat, sfVal),
                SF('E_Date', sField_SQLServer_Now, sfVal),
                SF('E_Man', FIn.FBase.FFrom.FUser)
                ], sTable_WebSendMsgInfo, '', True);
        FListC.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('S_ID', FieldByName('L_ID').AsString),
                SF('S_Status', nStatusCmd, sfVal),
                SF('S_Value', FieldByName('L_Value').AsFloat, sfVal),
                SF('S_Upload', sFlag_No),
                SF('S_Type', sFlag_Sale),

                SF('S_Date', sField_SQLServer_Now, sfVal),
                SF('S_Man', FIn.FBase.FFrom.FUser)
                ], sTable_WebSyncStatus, '', True);
         FListC.Add(nSQL);
      finally
        Next;
      end;
    end;
  end else

  if FListA.Values['MType'] = sFlag_Provide then
  begin
    nSQL := 'Select * From %s Where P_ID In (%s)';
    nSQL := Format(nSQL, [sTable_PoundLog, nStr]);

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    begin
      if RecordCount < 1 then Exit;

      First;
      FListC.Clear;

      while not Eof do
      try
        nSQL := MakeSQLByStr([
                SF('E_DLID', FieldByName('P_ID').AsString),
                SF('E_MsgType', nBillCmd, sfVal),
                SF('E_Card', FieldByName('P_Card').AsString),
                SF('E_Truck', FieldByName('P_Truck').AsString),
                SF('E_StockNO', FieldByName('P_MID').AsString),
                SF('E_StockName', FieldByName('P_MName').AsString),
                SF('E_CusID', FieldByName('P_CusID').AsString),
                SF('E_CusName', FieldByName('P_CusName').AsString),
                SF('E_Upload', sFlag_No),
                SF('E_Value', Float2Float(FieldByName('P_MValue').AsFloat -
                  FieldByName('P_PValue').AsFloat - FieldByName('P_KZValue').AsFloat,
                  cPrecision, False), sfVal),
                SF('E_Date', sField_SQLServer_Now, sfVal),
                SF('E_Man', FIn.FBase.FFrom.FUser)
                ], sTable_WebSendMsgInfo, '', True);
        FListC.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('S_ID', FieldByName('P_ID').AsString),
                SF('S_Status', nStatusCmd, sfVal),
                SF('S_Value', Float2Float(FieldByName('P_MValue').AsFloat -
                  FieldByName('P_PValue').AsFloat - FieldByName('P_KZValue').AsFloat,
                  cPrecision, False), sfVal),
                SF('S_Upload', sFlag_No),
                SF('S_Type', sFlag_Provide),

                SF('S_Date', sField_SQLServer_Now, sfVal),
                SF('S_Man', FIn.FBase.FFrom.FUser)
                ], sTable_WebSyncStatus, '', True);
         FListC.Add(nSQL);
      finally
        Next;
      end;
    end;
  end;

  FDBConn.FConn.BeginTrans;
  try
    for nIdx := 0 to FListC.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListC[nIdx]);

    FDBConn.FConn.CommitTrans;
  except
    FDBConn.FConn.RollbackTrans;
  end;
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TBusWorkerQueryField, sPlug_ModuleBus);
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessCommander, sPlug_ModuleBus);
end.

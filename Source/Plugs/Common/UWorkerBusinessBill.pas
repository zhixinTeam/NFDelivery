{*******************************************************************************
  作者: dmzn@163.com 2013-12-04
  描述: 模块业务对象
*******************************************************************************}
unit UWorkerBusinessBill;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, UWorkerBusinessCommand, ZnMD5, ULibFun,
  UFormCtrl, USysLoger, USysDB, UMITConst, UBase64
  {$IFDEF HardMon}, UMgrHardHelper, UWorkerHardware{$ENDIF};

type
  TStockInfoItem = record
    FID: string;            //编号
    FName: string;          //名称
    FType: string;          //类型
    FPackStyle: string;     //包装类型
  end;

  TStockMatchItem = record
    FStock: string;         //品种
    FGroup: string;         //分组
    FPriority: Integer;     //级别
    FRecord: string;        //记录
  end;

  TBillLadingLine = record
    FBill: string;          //交货单
    FLine: string;          //装车线
    FName: string;          //线名称
    FPerW: Integer;         //袋重
    FTotal: Integer;        //总袋数
    FNormal: Integer;       //正常
    FBuCha: Integer;        //补差
    FHKBills: string;       //合卡单
    FLineGroup: string;     //通道分组
  end;

  TOrderItem = record
    FOrder: string;         //订单号
    FCusID: string;         //客户号
    FCusName: string;       //客户名
    FCusCode: string;       //客户代码
    FAreaTo: string;        //区域流向
    FAreaToName: string;    //区域流向名称
    FStockID: string;       //品种号
    FStockName: string;     //品种名
    FStockType: string;     //类型
    FPackStyle: string;     //包装类型
    FSaleID: string;        //业务号
    FSaleName: string;      //业务名
    FMaxValue: Double;      //最大可用
    FKDValue: Double;       //开单量
    FOrderNo: string;       //订单编号
    FCompany: string;       //公司ID
    FSpecialCus: string;    //是否为特殊客户
    FSnlx: string;          //水泥流向
    FTruck: string;         //车牌号
  end;

  TOrderItems = array of TOrderItem;
  //订单列表

  TWorkerBusinessBills = class(TMITDBWorker)
  private
    FListA,FListB,FListC,FListD: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
    //io
    FSanMultiBill: Boolean;
    //散装多单
    FDefaultBrand: string;
    //默认品牌
    FAutoBatBrand: Boolean;
    //自动批次使用品牌
    FStockInfo: array of TStockInfoItem;
    //品种信息
    FStockItems: array of TStockMatchItem;
    FMatchItems: array of TStockMatchItem;
    //分组匹配
    FOrderItems: TOrderItems;
    //订单列表
    FBillLines: array of TBillLadingLine;
    //装车线
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function LoadStockInfo(var nData: string): Boolean;
    function GetStockInfo(const nID: string): Integer;
    //物料信息
    function GetStockGroup(const nStock: string; var nPriority: Integer): string;
    function GetMatchRecord(const nStock: string): string;
    //物料分组
    function DefaultBrand: string;
    //默认品牌
    function VerifyTruckTimeWhenP(const nTruck: string;
      var nData: string): Boolean;
    //车辆过皮超时
    function GetInBillInterval: Integer;
    function AllowedSanMultiBill: Boolean;
    function AutoVipByLine(const nStockNo: string; nValue: Double): Boolean;
    //根据通道类型自动变为VIP提货单
    function GetCusGroup(const nCusID, nDefaultGroup, nStockNo: string): string;
    //读取特殊客户分组
    function VerifyHYRecord(const nSeal: string): Boolean;
    //检查检定记录是否存在
    function VerifyBeforSave(var nData: string): Boolean;
    function VerifyBeforSaveMulCard(var nData: string): Boolean;
    function SaveBills(var nData: string): Boolean;
    //保存交货单
    function DeleteBill(var nData: string): Boolean;
    //删除交货单
    function ChangeBillTruck(var nData: string): Boolean;
    //修改车牌号
    function SaveBillCard(var nData: string): Boolean;
    //绑定磁卡
    function SaveBillMulCard(var nData: string): Boolean;
    //绑定磁卡(一车多卡)
    function LogoffCard(var nData: string): Boolean;
    //注销磁卡
    function GetPostBillItems(var nData: string): Boolean;
    //获取岗位交货单
    function SavePostBillItems(var nData: string): Boolean;
    //保存岗位交货单

    function LinkToNCSystem(var nData: string; nBill: TLadingBillItem): Boolean;
    //关联NC订单
    function LinkToNCSystemBySaleOrder(var nData: string; nBill: TLadingBillItem): Boolean;
    //关联NC订单
    function SaveBillNew(var nData: string): Boolean;
    //保存交货单
    function DeleteBillNew(var nData: string): Boolean;
    //删除交货单
    function SaveBillNewCard(var nData: string): Boolean;
    //绑定磁卡
    //function LogoffCardNew(var nData: string): Boolean;
    //注销磁卡
    function SaveBillFromNew(var nData: string): Boolean;
    //保存交货单
  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
    class function VerifyTruckNO(nTruck: string; var nData: string): Boolean;
    //验证车牌是否有效
  end;

implementation

class function TWorkerBusinessBills.FunctionName: string;
begin
  Result := sBus_BusinessSaleBill;
end;

constructor TWorkerBusinessBills.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  FListD := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessBills.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  FreeAndNil(FListD);
  inherited;
end;

function TWorkerBusinessBills.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessBills.GetInOutData(var nIn, nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2014-09-15
//Parm: 输入数据
//Desc: 执行nData业务指令
function TWorkerBusinessBills.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;

  case FIn.FCommand of
   cBC_SaveBills           : Result := SaveBills(nData);
   cBC_DeleteBill          : Result := DeleteBill(nData);
   cBC_ModifyBillTruck     : Result := ChangeBillTruck(nData);
   cBC_SaveBillCard        :
   begin
     {$IFDEF OneTruckMulCard}
                             Result := SaveBillMulCard(nData);
     {$ELSE}
                             Result := SaveBillCard(nData);
     {$ENDIF}
   end;
   cBC_LogoffCard          : Result := LogoffCard(nData);
   cBC_GetPostBills        : Result := GetPostBillItems(nData);
   cBC_SavePostBills       : Result := SavePostBillItems(nData);

   cBC_SaveBillNew         : Result := SaveBillNew(nData);
   cBC_DeleteBillNew       : Result := DeleteBillNew(nData);
   cBC_SaveBillNewCard     : Result := SaveBillNewCard(nData);
   cBC_SaveBillFromNew     : Result := SaveBillFromNew(nData);
   else
    begin
      Result := False;
      nData := '无效的业务代码(Invalid Command).';
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2014/7/30
//Parm: 品种编号;优先级
//Desc: 检索nStock对应的物料分组
function TWorkerBusinessBills.GetStockGroup(const nStock: string;
 var nPriority: Integer): string;
var nIdx: Integer;
begin
  Result := '';
  //init

  for nIdx:=Low(FStockItems) to High(FStockItems) do
  if FStockItems[nIdx].FStock = nStock then
  begin
    Result := FStockItems[nIdx].FGroup;
    nPriority := FStockItems[nIdx].FPriority;
    Exit;
  end;
end;

//Date: 2014/7/30
//Parm: 品种编号
//Desc: 检索车辆队列中与nStock同品种,或同组的记录
function TWorkerBusinessBills.GetMatchRecord(const nStock: string): string;
var nStr: string;
    nIdx,nInt: Integer;
begin
  Result := '';
  //init

  for nIdx:=Low(FMatchItems) to High(FMatchItems) do
  if FMatchItems[nIdx].FStock = nStock then
  begin
    Result := FMatchItems[nIdx].FRecord;
    Exit;
  end;

  nStr := GetStockGroup(nStock, nInt);
  if nStr = '' then Exit;

  for nIdx:=Low(FMatchItems) to High(FMatchItems) do
  if (FMatchItems[nIdx].FGroup = nStr) and
     (FMatchItems[nIdx].FPriority = nInt) then
  begin
    Result := FMatchItems[nIdx].FRecord;
    Exit;
  end;
end;

//Date: 2014-10-07
//Desc: 允许散装多单
function TWorkerBusinessBills.AllowedSanMultiBill: Boolean;
var nStr: string;
begin
  Result := False;
  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_SanMultiBill]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsString = sFlag_Yes;
  end;
end;

//Date: 2019-01-15
//Desc: 根据通道类型自动变为VIP提货单
function TWorkerBusinessBills.AutoVipByLine(const nStockNo: string; nValue: Double): Boolean;
var nStr: string;
    nVipLine: Boolean;
begin
  Result := False;
  nVipLine := False;

  nStr := 'Select Z_VIPLine From %s Where Z_StockNo=''%s'' And Z_Valid=''%s''';
  nStr := Format(nStr, [sTable_ZTLines, nStockNo, sFlag_Yes]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <= 0 then
      Exit;

    First;

    while not Eof do
    begin
      if Fields[0].AsString = sFlag_TypeVIP then
      begin
        nVipLine := True;
        Break;
      end;
      Next;
    end;
  end;

  if not nVipLine then
    Exit;

  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s'' and D_ParamA > %.2f';
  nStr := Format(nStr, [sTable_SysDict, sFlag_AutoVipByLine, nStockNo, nValue]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsString = sFlag_Yes;
  end;
end;

//Date: 2019-05-09
//Desc: 读取特殊客户分组
function TWorkerBusinessBills.GetCusGroup(const nCusID, nDefaultGroup,nStockNo: string): string;
var nStr: string;
begin
  Result := nDefaultGroup;

  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s'' And D_ParamB=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_CusGroup, nCusID, nStockNo]);

  WriteLog('读取特殊客户分组sql:' + nStr);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsString;
    WriteLog('特殊客户所在分组:' + Result);
  end;
end;

//Date: 2019-05-09
//Desc: 检查检定记录是否存在
function TWorkerBusinessBills.VerifyHYRecord(const nSeal: string): Boolean;
var nStr: string;
begin
  Result := False;

  nStr := 'Select R_SerialNo From %s Where R_SerialNo=''%s''';
  nStr := Format(nStr, [sTable_StockRecord, nSeal]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    Result := True;
  end;
end;

//Date: 2017/6/21
//Parm: 无
//Desc: 获取默认的品牌名称
function TWorkerBusinessBills.DefaultBrand: string;
var nStr: string;
begin
  Result := '';
  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_DefaultBrand]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsString;
  end;
end;

//Date: 2015-01-09
//Desc: 车辆进厂后在指定时间内必须开单,过期无效
function TWorkerBusinessBills.GetInBillInterval: Integer;
var nStr: string;
    nBegTime, nEndTime: TDateTime;
begin
  Result := 0;
  nStr := 'Select * From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_InAndBill]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    if Assigned(FindField('D_ParamB')) and Assigned(FindField('D_ParamC')) then
    begin
      if (FieldByName('D_ParamB').AsString <> '') and (FieldByName('D_ParamC').AsString <> '') then
      begin
        nBegTime := Str2DateTime(FormatDateTime('YYYY-MM-DD', Now) + ' ' + FieldByName('D_ParamB').AsString);
        nEndTime := Str2DateTime(FormatDateTime('YYYY-MM-DD', Now) + ' ' + FieldByName('D_ParamC').AsString);
        WriteLog('车辆签到功能运行起始时间:' + DateTime2Str(nBegTime) + '结束时间:' + DateTime2Str(nEndTime));

        if (Now < nBegTime) or (Now > nEndTime) then
        begin
          Result := 0;
          Exit;
        end;
      end;
    end;
    Result := FieldByName('D_Value').AsInteger;
  end;
end;

//Date: 2014-12-26
//Desc: 载入物料信息
function TWorkerBusinessBills.LoadStockInfo(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
begin
  Result := Length(FStockInfo) > 0;
  if Result then Exit;

  nStr := 'Select D_Value,D_Memo,D_ParamB,D_ParamC From %s Where D_Name=''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem]);
  //物料列表
    
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    SetLength(FStockInfo, RecordCount);
    //xxxxx
    
    if RecordCount < 1 then
    begin
      nData := '请先初始化StockItem字典项.';
      Exit;
    end;

    Result := True;
    nIdx := 0;
    First;

    while not Eof do
    begin
      with FStockInfo[nIdx] do
      begin
        FID := FieldByName('D_ParamB').AsString;
        FName := FieldByName('D_Value').AsString;
        FType := FieldByName('D_Memo').AsString;
        FPackStyle := FieldByName('D_ParamC').AsString;
      end;

      Inc(nIdx);
      Next;
    end;
  end;
end;

//Date: 2014-12-26
//Parm: 物料编号
//Desc: 检索nID物料所在的索引
function TWorkerBusinessBills.GetStockInfo(const nID: string): Integer;
var nIdx: Integer;
begin
  Result := - 1;

  for nIdx:=Low(FStockInfo) to High(FStockInfo) do
  if FStockInfo[nIdx].FID = nID then
  begin
    Result := nIdx;
    Exit;
  end;
end;

//Date: 2014-12-26
//Parm: 订单列表
//Desc: 将nOrders按可用量从小到大排序
procedure SortOrderByValue(var nOrders: TOrderItems);
var i,j,nInt: Integer;
    nItem: TOrderItem;
begin
  nInt := High(nOrders);
  //xxxxx

  for i:=Low(nOrders) to nInt do
   for j:=i+1 to nInt do
    if nOrders[j].FMaxValue < nOrders[i].FMaxValue then
    begin
      nItem := nOrders[i];
      nOrders[i] := nOrders[j];
      nOrders[j] := nItem;
    end;
  //冒泡排序
end;


//Date: 2014-09-16
//Parm: 车牌号;
//Desc: 验证nTruck是否有效
class function TWorkerBusinessBills.VerifyTruckNO(nTruck: string;
  var nData: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := TWorkerBusinessCommander.CallMe(cBC_IsTruckValid, nTruck, '', @nOut);
  if not Result then nData := nOut.FData;
end;

//Date: 2017-09-10
//Parm: 车牌号
//Desc: 车辆过皮时,验证是否进厂超时
function TWorkerBusinessBills.VerifyTruckTimeWhenP(const nTruck: string;
 var nData: string): Boolean;
var nStr: string;
    nMin: Integer;
begin
  Result := True;
  nStr := 'Select getDate() as S_Now,Max(T_InFact) as T_InFact From %s ' +
          'Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_ZTTrucks, nTruck]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if (RecordCount < 1) or (Fields[1].AsFloat < 1) then Exit;
    //进厂时间无效

    nMin := Trunc((Fields[0].AsFloat - Fields[1].AsFloat) / (1 / (24 * 60)));
    //距离进厂分钟数
  end;

  nStr := 'Select D_Value From %s ' +
          'Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_InAndPound]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if (RecordCount > 0) and (Fields[0].AsInteger < nMin) then
  begin
    nData := '车辆[ %s ]进厂后[ %d ]分钟未过磅,超时[ %d ]分钟.';
    nData := Format(nData, [nTruck, Fields[0].AsInteger, nMin]);
    Result := False;
  end;
end;

//Date: 2014-09-15
//Desc: 验证能否开单
function TWorkerBusinessBills.VerifyBeforSave(var nData: string): Boolean;
var nIdx,nInt: Integer;
    nVal,nDec: Double;
    nWorker: PDBWorker;
    nQItem: TLadingBillItem;
    nOut: TWorkerBusinessCommand;
    nStr,nTruck, nType, nQBill: string;
begin
  Result := False;
  nTruck := FListA.Values['Truck'];
  if not VerifyTruckNO(nTruck, nData) then Exit;

  nStr := 'Select %s as T_Now,* From %s ' +
          'Where T_Truck=''%s''';
  nStr := Format(nStr, [sField_SQLServer_Now, sTable_Truck, nTruck]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    {$IFDEF ZGNF}
    if RecordCount < 1 then
    begin
      nData := '没有车辆[ %s ]的档案,无法开单.';
      nData := Format(nData, [nTruck]);
      Exit;
    end;
    {$ENDIF}

    if FieldByName('T_Valid').AsString = sFlag_No then
    begin
      nData := '车辆[ %s ]被管理员禁止开单.';
      nData := Format(nData, [nTruck]);
      Exit;
    end;
  end;

  nInt := GetInBillInterval;
  if nInt > 0 then
  begin
    nStr := 'Select %s as T_Now,T_LastTime,T_NoVerify,T_Valid From %s ' +
            'Where T_Truck=''%s''';
    nStr := Format(nStr, [sField_SQLServer_Now, sTable_Truck, nTruck]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if FListA.Values['Post'] = '' then //补单不验证
      if FieldByName('T_NoVerify').AsString <> sFlag_Yes then
      begin
        nIdx := Trunc((FieldByName('T_Now').AsDateTime -
                       FieldByName('T_LastTime').AsDateTime) * 24 * 60);
        //上次活动分钟数

        if nIdx >= nInt then
        begin
          nData := '车辆[ %s ]可能不在停车场,禁止开单.';
          nData := Format(nData, [nTruck]);
          Exit;
        end;
      end;
    end;
  end;

  //----------------------------------------------------------------------------
  SetLength(FStockItems, 0);
  SetLength(FMatchItems, 0);
  //init

  FSanMultiBill := AllowedSanMultiBill;
  //散装允许开多单

  FDefaultBrand := DefaultBrand;
  //选择批次号时默认品牌

  {$IFDEF StockPriorityInQueue}
  nStr := 'Select M_ID,M_Group,M_Priority From %s Where M_Status=''%s'' ';
  {$ELSE}
  nStr := 'Select M_ID,M_Group From %s Where M_Status=''%s'' ';
  {$ENDIF}

  nStr := Format(nStr, [sTable_StockMatch, sFlag_Yes]);
  //品种分组匹配

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    SetLength(FStockItems, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    begin
      FStockItems[nIdx].FStock := Fields[0].AsString;
      FStockItems[nIdx].FGroup := Fields[1].AsString;

      {$IFDEF StockPriorityInQueue}
      FStockItems[nIdx].FPriority := Fields[2].AsInteger;
      {$ELSE}
      FStockItems[nIdx].FPriority := 0;
      {$ENDIF}

      Inc(nIdx);
      Next;
    end;
  end;

  nType := '';
  nQBill:= '';
  //车辆在队列中的信息

  nStr := 'Select R_ID,T_Bill,T_StockNo,T_Type,T_InFact,T_Valid From %s ' +
          'Where T_Truck=''%s'' ';
  nStr := Format(nStr, [sTable_ZTTrucks, nTruck]);
  //还在队列中车辆

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    SetLength(FMatchItems, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    begin
      if nType = '' then
        nType := FieldByName('T_Type').AsString;
      //获取车辆在队列中的类型

      if nType = sFlag_San then
      begin
        if not FSanMultiBill then
        begin
          nStr := '车辆[ %s ]在未完成[ %s ]交货单之前禁止开单.';
          nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
          Exit;
        end;

        nQBill := FieldByName('T_Bill').AsString;
      end else

      if (nType = sFlag_Dai) and
         (FieldByName('T_InFact').AsString <> '') then
      begin
        nStr := '车辆[ %s ]在未完成[ %s ]交货单之前禁止开单.';
        nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
        Exit;
      end;

      if FieldByName('T_Valid').AsString = sFlag_No then
      begin
        nStr := '车辆[ %s ]有已出队的交货单[ %s ],需先处理.';
        nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
        Exit;
      end;

      with FMatchItems[nIdx] do
      begin
        FStock := FieldByName('T_StockNo').AsString;
        FGroup := GetStockGroup(FStock, nInt);

        FPriority := nInt;
        FRecord := FieldByName('R_ID').AsString;
      end;

      Inc(nIdx);
      Next;
    end;
  end;

  if (nType = sFlag_San) and (nQBill <> '') and FSanMultiBill then
  begin
    nStr := 'Select * From %s Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, nQBill]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := Format('提货单[ %s ]信息已丢失.', [nQBill]);
        Exit;
      end;

      with nQItem do
      begin
        FID := FieldByName('L_ID').AsString;
        FStockNo := FieldByName('L_StockNO').AsString;
        FStockName := FieldByName('L_StockName').AsString;

        FCusID := FieldByName('L_CusID').AsString;
        FCusName := FieldByName('L_CusName').AsString;

        FOrigin := FieldByName('L_Area').AsString;      //区域流向
        FExtID_1:= FieldByName('L_StockArea').AsString; //到货地点
      end;
    end;
  end;
  //获取队列中的散装车辆提货单信息

  TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, nTruck, '', @nOut);
  //保存车牌号

  //----------------------------------------------------------------------------
  nStr := FListA.Values['Orders'];
  FListB.Text := PackerDecodeStr(nStr);
  nStr := AdjustListStrFormat2(FListB, '''', True, ',', False, False);

  FListC.Clear;
  FListC.Values['MeamKeys'] := nStr;
  nStr := PackerEncodeStr(FListC.Text);

  if not TWorkerBusinessCommander.CallMe(cBC_GetSQLQueryOrder, '103', nStr,
         @nOut) then
  begin
    nStr := StringReplace(FListB.Text, #13#10, ',', [rfReplaceAll]);
    nData := Format('获取[ %s ]订单信息失败', [nStr]);
    Exit;
  end;

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nOut.FData, nWorker, sFlag_DB_NC), FListA do
    begin
      if RecordCount < 1 then
      begin
        nStr := StringReplace(FListB.Text, #13#10, ',', [rfReplaceAll]);
        nData := Format('订单[ %s ]信息已丢失.', [nStr]);
        Exit;
      end;

      if (nType = sFlag_San)  and (nQBill <> '') and FSanMultiBill then
      with nQItem do
      begin
        if FieldByName('invcode').AsString <> FStockNo then
        begin
          nStr := '车辆[ %s ]已有交货单[ %s ]品种[ %s ]与 新增交货单品种[ %s ]'+
                  '不同,禁止合单.';
          nData := Format(nStr, [nTruck, nQBill, FStockName,
                   FieldByName('invname').AsString]);
          Exit;
        end;

        if FieldByName('custcode').AsString <> FCusID then
        begin
          nStr := '车辆[ %s ]已有交货单[ %s ]客户[ %s ]与 新增交货单客户[ %s ]'+
                  '不同,禁止合单.';
          nData := Format(nStr, [nTruck, nQBill, FCusName,
                   FieldByName('custname').AsString]);
          Exit;
        end;

        if FieldByName('vdef2').AsString <> FOrigin then
        begin
          nStr := '车辆[ %s ]已有交货单[ %s ]区域流向[ %s ]与 新增交货单区域流向[ %s ]'+
                  '不同,禁止合单.';
          nData := Format(nStr, [nTruck, nQBill, FOrigin,
                   FieldByName('vdef2').AsString]);
          Exit;
        end;

        if FieldByName('areaclname').AsString <> FExtID_1 then
        begin
          nStr := '车辆[ %s ]已有交货单[ %s ]到货地点[ %s ]与 新增交货单到货地点[ %s ]'+
                  '不同,禁止合单.';
          nData := Format(nStr, [nTruck, nQBill, FExtID_1,
                   FieldByName('areaclname').AsString]);
          Exit;
        end;
      end;

      {$IFDEF SaleAICMFromNC}
      if FListA.Values['wxzhuid'] = '' then
      begin
        FListA.Values['wxzhuid'] := FieldByName('wxzhuid').AsString;
        FListA.Values['wxziid'] := FieldByName('wxziid').AsString;
      end;
      {$ENDIF}

      if not LoadStockInfo(nData) then Exit;
      //载入物料

      SetLength(FOrderItems, RecordCount);
      nInt := 0;
      First;

      while not Eof do
      begin
        with FOrderItems[nInt] do
        begin
          FOrder := FieldByName('pk_meambill').AsString;
          FOrderNo := FieldByName('VBILLCODE').AsString;
          if FListA.Values['CusID']='' then
               FCusID := FieldByName('custcode').AsString
          else FCusID := FListA.Values['CusID'];

          if FListA.Values['CusName']='' then
               FCusName := FieldByName('custname').AsString
          else FCusName := FListA.Values['CusName'];

          FCusCode := FieldByName('def30').AsString;
          if FCusCode = '' then FCusCode := '00';

          FStockID := FieldByName('invcode').AsString;
          FStockName := FieldByName('invname').AsString;
          FMaxValue := FieldByName('NPLANNUM').AsFloat;
          FKDValue := 0;

          FSaleID := '001';
          FSaleName := FieldByName('VBILLTYPE').AsString;
          FTruck:= FieldByName('cvehicle').AsString;
          FAreaTo := FieldByName('vdef2').AsString;
          FAreaToName := FieldByName('docname').AsString;
          //区域流向
          FCompany := FieldByName('company').AsString;
          FSpecialCus := FieldByName('specialcus').AsString;
          FSnlx    := FieldByName('vdef10').AsString;
          nIdx := GetStockInfo(FStockID);
          if nIdx < 0 then
          begin
            nData := '品种[ %s ]在字典中的信息丢失.';
            nData := Format(nData, [FStockName]);
            Exit;
          end else

          begin
            FStockType := FStockInfo[nIdx].FType;
            FPackStyle := FStockInfo[nIdx].FPackStyle;
          end;
        end;

        Inc(nInt);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;

  //----------------------------------------------------------------------------
  nStr := PackerEncodeStr(FListB.Text);
  //订单列表

  if not TWorkerBusinessCommander.CallMe(cBC_GetOrderFHValue, nStr, '', @nOut) then
  begin
    nStr := StringReplace(FListB.Text, #13#10, ',', [rfReplaceAll]);
    nData := Format('获取[ %s ]订单发货量失败', [nStr]);
    Exit;
  end;

  FListC.Text := PackerDecodeStr(nOut.FData);
  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  begin
    nStr := FListC.Values[FOrderItems[nIdx].FOrder];
    if not IsNumber(nStr, True) then Continue;

    with FOrderItems[nIdx] do
      FMaxValue := FMaxValue - StrToFloat(nStr);
    //可用量 = 计划量 - 已发量
  end;

  SortOrderByValue(FOrderItems);
  //按可用量由小到大排序

  //----------------------------------------------------------------------------
  nStr := FListA.Values['Value'];
  nVal := Float2Float(StrToFloat(nStr), cPrecision, True);

  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  begin
    if nVal <= 0 then Break;
    //开单量已处理完毕

    nDec := Float2Float(FOrderItems[nIdx].FMaxValue, cPrecision, False);
    //订单可用量

    if nDec >= nVal then
      nDec := nVal;
    //订单够用则直接扣除开单量

    with FOrderItems[nIdx] do
    begin
      //FMaxValue := Float2Float(FMaxValue, cPrecision, False) - nDec;
      FKDValue := nDec;
    end;

    nVal := Float2Float(nVal - nDec, cPrecision, True);
    //开单剩余量

    if FOrderItems[nIdx].FTruck <> '' then
    begin
      WriteLog('订单' + FOrderItems[nIdx].FOrder + '车牌号' + FOrderItems[nIdx].FTruck
               + '为一车一单,不再校验订单量...'  );
      nVal := 0;
    end;
  end;

  if nVal > 0 then
  begin
    nData := '提货量超出订单可用量[ %.2f ]吨,开单失败.';
    nData := Format(nData, [nVal]);
    Exit;
  end;

  {$IFNDEF TruckTypeOnlyPound}
  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  begin
    if FOrderItems[nIdx].FKDValue <= 0 then Continue;
    //无开单量
    if FOrderItems[nIdx].FStockType = sFlag_San then
    begin
      nStr := 'Select %s as T_Now,* From %s ' +
              'Where T_Truck=''%s''';
      nStr := Format(nStr, [sField_SQLServer_Now, sTable_Truck, FListA.Values['Truck']]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      begin
        if RecordCount < 1 then
        begin
          nData := '没有车辆[ %s ]的档案,无法开单.';
          nData := Format(nData, [FListA.Values['Truck']]);
          Exit;
        end;

        if FieldByName('T_CzType').AsString = '' then
        begin
          nData := '车辆[ %s ]未维护车轴类型,无法开单.';
          nData := Format(nData, [FListA.Values['Truck']]);
          Exit;
        end;
      end;
    end;
  end;
  {$ENDIF}

  Result := True;
  //verify done
end;

//Date: 2018-07-21
//Desc: 验证能否开单(一车多卡)
function TWorkerBusinessBills.VerifyBeforSaveMulCard(var nData: string): Boolean;
var nIdx,nInt: Integer;
    nVal,nDec: Double;
    nWorker: PDBWorker;
    nQItem: TLadingBillItem;
    nOut: TWorkerBusinessCommand;
    nStr,nTruck, nType, nQBill: string;
begin
  Result := False;
  nTruck := FListA.Values['Truck'];
  if not VerifyTruckNO(nTruck, nData) then Exit;

  nInt := GetInBillInterval;
  if nInt > 0 then
  begin
    nStr := 'Select %s as T_Now,T_LastTime,T_NoVerify,T_Valid From %s ' +
            'Where T_Truck=''%s''';
    nStr := Format(nStr, [sField_SQLServer_Now, sTable_Truck, nTruck]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := '没有车辆[ %s ]的档案,无法开单.';
        nData := Format(nData, [nTruck]);
        Exit;
      end;

      if FieldByName('T_Valid').AsString = sFlag_No then
      begin
        nData := '车辆[ %s ]被管理员禁止开单.';
        nData := Format(nData, [nTruck]);
        Exit;
      end;

      if FListA.Values['Post'] = '' then //补单不验证
      if FieldByName('T_NoVerify').AsString <> sFlag_Yes then
      begin
        nIdx := Trunc((FieldByName('T_Now').AsDateTime -
                       FieldByName('T_LastTime').AsDateTime) * 24 * 60);
        //上次活动分钟数

        if nIdx >= nInt then
        begin
          nData := '车辆[ %s ]可能不在停车场,禁止开单.';
          nData := Format(nData, [nTruck]);
          Exit;
        end;
      end;
    end;
  end;

  //----------------------------------------------------------------------------
  SetLength(FStockItems, 0);
  SetLength(FMatchItems, 0);
  //init

  FSanMultiBill := AllowedSanMultiBill;
  //散装允许开多单

  FDefaultBrand := DefaultBrand;
  //选择批次号时默认品牌

  {$IFDEF StockPriorityInQueue}
  nStr := 'Select M_ID,M_Group,M_Priority From %s Where M_Status=''%s'' ';
  {$ELSE}
  nStr := 'Select M_ID,M_Group From %s Where M_Status=''%s'' ';
  {$ENDIF}

  nStr := Format(nStr, [sTable_StockMatch, sFlag_Yes]);
  //品种分组匹配

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    SetLength(FStockItems, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    begin
      FStockItems[nIdx].FStock := Fields[0].AsString;
      FStockItems[nIdx].FGroup := Fields[1].AsString;

      {$IFDEF StockPriorityInQueue}
      FStockItems[nIdx].FPriority := Fields[2].AsInteger;
      {$ELSE}
      FStockItems[nIdx].FPriority := 0;
      {$ENDIF}

      Inc(nIdx);
      Next;
    end;
  end;

  TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, nTruck, '', @nOut);
  //保存车牌号

  //----------------------------------------------------------------------------
  nStr := FListA.Values['Orders'];
  FListB.Text := PackerDecodeStr(nStr);
  nStr := AdjustListStrFormat2(FListB, '''', True, ',', False, False);

  FListC.Clear;
  FListC.Values['MeamKeys'] := nStr;
  nStr := PackerEncodeStr(FListC.Text);

  if not TWorkerBusinessCommander.CallMe(cBC_GetSQLQueryOrder, '103', nStr,
         @nOut) then
  begin
    nStr := StringReplace(FListB.Text, #13#10, ',', [rfReplaceAll]);
    nData := Format('获取[ %s ]订单信息失败', [nStr]);
    Exit;
  end;

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nOut.FData, nWorker, sFlag_DB_NC), FListA do
    begin
      if RecordCount < 1 then
      begin
        nStr := StringReplace(FListB.Text, #13#10, ',', [rfReplaceAll]);
        nData := Format('订单[ %s ]信息已丢失.', [nStr]);
        Exit;
      end;

      {$IFDEF SaleAICMFromNC}
      if FListA.Values['wxzhuid'] = '' then
      begin
        FListA.Values['wxzhuid'] := FieldByName('wxzhuid').AsString;
        FListA.Values['wxziid'] := FieldByName('wxziid').AsString;
      end;
      {$ENDIF}

      if not LoadStockInfo(nData) then Exit;
      //载入物料

      SetLength(FOrderItems, RecordCount);
      nInt := 0;
      First;

      while not Eof do
      begin
        with FOrderItems[nInt] do
        begin
          FOrder := FieldByName('pk_meambill').AsString;
          FOrderNo := FieldByName('VBILLCODE').AsString;
          if FListA.Values['CusID']='' then
               FCusID := FieldByName('custcode').AsString
          else FCusID := FListA.Values['CusID'];

          if FListA.Values['CusName']='' then
               FCusName := FieldByName('custname').AsString
          else FCusName := FListA.Values['CusName'];

          FCusCode := FieldByName('def30').AsString;
          if FCusCode = '' then FCusCode := '00';

          FStockID := FieldByName('invcode').AsString;
          FStockName := FieldByName('invname').AsString;
          FMaxValue := FieldByName('NPLANNUM').AsFloat;
          FKDValue := 0;

          FSaleID := '001';
          FSaleName := FieldByName('VBILLTYPE').AsString;

          FAreaTo := FieldByName('vdef2').AsString;
          //区域流向

          nIdx := GetStockInfo(FStockID);
          if nIdx < 0 then
          begin
            nData := '品种[ %s ]在字典中的信息丢失.';
            nData := Format(nData, [FStockName]);
            Exit;
          end else

          begin
            FStockType := FStockInfo[nIdx].FType;
            FPackStyle := FStockInfo[nIdx].FPackStyle;
          end;
        end;

        Inc(nInt);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;

  //----------------------------------------------------------------------------
  nStr := PackerEncodeStr(FListB.Text);
  //订单列表

  if not TWorkerBusinessCommander.CallMe(cBC_GetOrderFHValue, nStr, '', @nOut) then
  begin
    nStr := StringReplace(FListB.Text, #13#10, ',', [rfReplaceAll]);
    nData := Format('获取[ %s ]订单发货量失败', [nStr]);
    Exit;
  end;

  FListC.Text := PackerDecodeStr(nOut.FData);
  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  begin
    nStr := FListC.Values[FOrderItems[nIdx].FOrder];
    if not IsNumber(nStr, True) then Continue;

    with FOrderItems[nIdx] do
      FMaxValue := FMaxValue - StrToFloat(nStr);
    //可用量 = 计划量 - 已发量
  end;

  SortOrderByValue(FOrderItems);
  //按可用量由小到大排序

  //----------------------------------------------------------------------------
  nStr := FListA.Values['Value'];
  nVal := Float2Float(StrToFloat(nStr), cPrecision, True);

  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  begin
    if nVal <= 0 then Break;
    //开单量已处理完毕

    nDec := Float2Float(FOrderItems[nIdx].FMaxValue, cPrecision, False);
    //订单可用量

    if nDec >= nVal then
      nDec := nVal;
    //订单够用则直接扣除开单量

    with FOrderItems[nIdx] do
    begin
      //FMaxValue := Float2Float(FMaxValue, cPrecision, False) - nDec;
      FKDValue := nDec;
    end;

    nVal := Float2Float(nVal - nDec, cPrecision, True);
    //开单剩余量
  end;

  if nVal > 0 then
  begin
    nData := '提货量超出订单可用量[ %.2f ]吨,开单失败.';
    nData := Format(nData, [nVal]);
    Exit;
  end;

  Result := True;
  //verify done
end;

//Date: 2014-09-15
//Desc: 保存交货单
function TWorkerBusinessBills.SaveBills(var nData: string): Boolean;
var nStr,nSQL,nBill,nBrand: string;
    nIdx,nInt,nErrCode: Integer;
    nDaiQuickSync: Boolean;
    nDBWorker: PDBWorker;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);

  FAutoBatBrand := False;
  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_AutoBatBrand]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    FAutoBatBrand := Fields[0].AsString = sFlag_Yes;
  end;

  {$IFDEF OneTruckMulCard}
  if not VerifyBeforSaveMulCard(nData) then Exit;
  {$ELSE}
  if not VerifyBeforSave(nData) then Exit;
  {$ENDIF}

  nDaiQuickSync := False;
  //不使用袋装开单即推单业务

  nDBWorker := FDBConn;
  FDBConn := nil;
  //备份旧链路

  try
    with gParamManager.ActiveParam^ do
    begin
      FDBConn := gDBConnManager.GetConnection(FDB.FID, nErrCode, True);

      if not Assigned(FDBConn) then
      begin
        nData := Format('连接[ %s ]数据库失败(ErrCode: %d).', [FDB.FID, nErrCode]);
        Exit;
      end;

      if not FDBConn.FConn.Connected then
        FDBConn.FConn.Connected := True;
      //conn db
    end;

    FDBConn.FConn.BeginTrans;
    //开启事务
    FOut.FData := '';
    //bill list

    if FListA.Values['Brand'] <> '' then
      nBrand := Trim(FListA.Values['Brand']);
    //客户端指定品牌时,选择品牌

    if nBrand = '' then
      nBrand := FDefaultBrand;
    //使用默认品牌

    for nIdx:=Low(FOrderItems) to High(FOrderItems) do
    begin
      if FOrderItems[nIdx].FKDValue <= 0 then Continue;
      //无开单量

      {$IFDEF GROUPBYAREA}
      if TWorkerBusinessCommander.CallMe(cBC_GetGroupByArea,
          FOrderItems[nIdx].FAreaToName, FOrderItems[nIdx].FStockID, @nOut) then
      begin
        if nOut.FData <> '' then
        begin
          FListA.Values['LineGroup'] := nOut.FData;

          nStr := '物料[ %s ]区域流向[ %s ]匹配通道分组:[ %s ]';
          nStr := Format(nStr, [FOrderItems[nIdx].FStockID,
                                FOrderItems[nIdx].FAreaToName,
                                nOut.FData]);
          WriteLog(nStr);
        end;
      end;
      {$ENDIF}

      {$IFNDEF ManuPack}
      FListA.Values['Pack'] := FOrderItems[nIdx].FPackStyle;
      //包装类型
      {$ENDIF}

      FListA.Values['PointLineID'] := '';

      {$IFDEF AutoGetLineGroup}
      FListC.Clear;
      FListC.Values['Type']  := FListA.Values['IsVIP'];
      FListC.Values['Brand'] := nBrand;
      FListC.Values['LineGroup']  := FListA.Values['LineGroup'];
      if not TWorkerBusinessCommander.CallMe(cBC_AutoGetLineGroup,
          FOrderItems[nIdx].FStockID, PackerEncodeStr(FListC.Text), @nOut) then
      raise Exception.Create(nOut.FData);

      if nOut.FData <> '' then
      begin
        FListA.Values['LineGroup'] := nOut.FData;
      end;
      if nOut.FExtParam <> '' then
      begin
        FListA.Values['PointLineID'] := nOut.FExtParam;
      end;

      {$IFDEF NoPointLine}
      FListA.Values['PointLineID'] := '';
      {$ENDIF}
      {$ENDIF}

      {$IFNDEF BatCodeByLine}
      FListC.Clear;
      FListC.Values['CusID'] := FOrderItems[nIdx].FCusID;
      FListC.Values['Type']  := FListA.Values['IsVIP'];
      FListC.Values['Brand'] := nBrand;
      FListC.Values['Value'] := FloatToStr(FOrderItems[nIdx].FKDValue);

      if FOrderItems[nIdx].FSpecialCus <> '' then
        FListC.Values['LineGroup'] := GetCusGroup(FOrderItems[nIdx].FCusID,
                                                  FListA.Values['LineGroup'],
                                                  FOrderItems[nIdx].FStockID)
      else
        FListC.Values['LineGroup'] := FListA.Values['LineGroup'];
      FListC.Values['Seal']  := FListA.Values['Seal'];

      if not TWorkerBusinessCommander.CallMe(cBC_GetStockBatcode,
          FOrderItems[nIdx].FStockID, PackerEncodeStr(FListC.Text), @nOut) then
      raise Exception.Create(nOut.FData);

      if nOut.FData <> '' then
      begin
        FListA.Values['Seal'] := nOut.FData;
        //获取新的批次

        if PBWDataBase(@nOut).FErrCode = sFlag_ForceHint then
        begin
          FOut.FBase.FErrCode := sFlag_ForceHint;
          FOut.FBase.FErrDesc := PBWDataBase(@nOut).FErrDesc;
        end;

        {$IFDEF VerifyHYRecord}
        if not VerifyHYRecord(FListA.Values['Seal']) then
        raise Exception.Create('批次号[' +
                      FListA.Values['Seal'] +']检定记录不存在,开单失败');
        {$ENDIF}
      end;
      {$ENDIF}

      if FListA.Values['IsVIP'] <> sFlag_TypeVIP then
      begin
        if AutoVipByLine(FOrderItems[nIdx].FStockID, FOrderItems[nIdx].FKDValue) then
          FListA.Values['IsVIP'] := sFlag_TypeVIP;
      end;

      FListC.Clear;
      FListC.Values['Group'] :=sFlag_BusGroup;
      FListC.Values['Object'] := sFlag_BillNo;
      //to get serial no

      if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      //xxxxx

      FOut.FData := FOut.FData + nOut.FData + ',';
      //combine bill

      nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
      nStr := Format(nStr, [sTable_SysDict, sFlag_CusBmFromDict, FOrderItems[nIdx].FCusID]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      if RecordCount > 0 then
      begin
        FListA.Values['bm'] := Fields[0].AsString;
      end;

      nStr := MakeSQLByStr([SF('L_ID', nOut.FData),
              SF('L_ZhiKa', FOrderItems[nIdx].FOrder),
              SF('L_CusID', FOrderItems[nIdx].FCusID),
              SF('L_CusName', FOrderItems[nIdx].FCusName),
              SF('L_CusPY', GetPinYinOfStr(FOrderItems[nIdx].FCusName)),
              SF('L_CusCode', FOrderItems[nIdx].FCusCode),
              SF('L_SaleID', FOrderItems[nIdx].FSaleID),
              SF('L_SaleMan', FOrderItems[nIdx].FSaleName),
              SF('L_Area', FOrderItems[nIdx].FAreaTo),
              SF('L_StockArea', FListA.Values['StockArea']),
              SF('L_StockBrand', FListA.Values['Brand']),
              {$IFDEF LineGroup}
              SF('L_LineGroup', FListA.Values['LineGroup']),
              {$ELSE}
                {$IFDEF AutoGetLineGroup}
                SF('L_LineGroup', FListA.Values['LineGroup']),
                {$ENDIF}
              {$ENDIF}

              SF('L_Type', FOrderItems[nIdx].FStockType),
              SF('L_StockNo', FOrderItems[nIdx].FStockID),
              SF('L_StockName', FOrderItems[nIdx].FStockName),
              SF('L_PackStyle', FListA.Values['Pack']),
              SF('L_Value', FOrderItems[nIdx].FKDValue, sfVal),
              {$IFDEF SaveKDValue}
              SF('L_PreValue', FOrderItems[nIdx].FKDValue, sfVal),
              {$ENDIF}
              SF('L_Price', 0, sfVal),

              {$IFDEF PrintHYEach}
              SF('L_PrintHY',     FListA.Values['PrintHY']),
              {$ENDIF} //随车打印化验单

              {$IFDEF RemoteSnap}
              SF('L_SnapTruck',   FListA.Values['SnapTruck']),
              {$ENDIF}

              {$IFDEF BMPrintCode}
              SF('L_Bm',   FListA.Values['bm']),
              {$ENDIF}

              {$IFDEF SaveAreaName}
              SF('L_AreaName',   FOrderItems[nIdx].FAreaToName),
              {$ENDIF}

              {$IFDEF SaleAICMFromNC}
              SF('L_WxZhuId',   FListA.Values['wxzhuid']),
              SF('L_WxZiId',   FListA.Values['wxziid']),
              SF('L_Company',   FOrderItems[nIdx].FCompany),
              {$ENDIF}

              {$IFDEF SaveOrderNo}
              SF('L_OrderNo',     FOrderItems[nIdx].FOrderNo),
              {$ENDIF} //随车打印化验单

              {$IFDEF SNLX}
              SF('L_Snlx',     FOrderItems[nIdx].FSnlx),
              {$ENDIF} //水泥流向

              SF('L_Truck', FListA.Values['Truck']),
              SF('L_Status', sFlag_BillNew),
              SF('L_Lading', FListA.Values['Lading']),
              SF('L_IsVIP', FListA.Values['IsVIP']),
              SF('L_Seal', FListA.Values['Seal']),
              SF('L_Memo', FListA.Values['Memo']),
              {$IFDEF FORCEPSTATION}
              SF('L_PoundStation', FListA.Values['PoundStation']),
              SF('L_PoundName', FListA.Values['PoundName']),
              {$ENDIF}

              SF('L_Man', FIn.FBase.FFrom.FUser),
              SF('L_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Bill, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);

      {$IFDEF DaiQuickSync}
      if (not nDaiQuickSync) and (FOrderItems[nIdx].FStockType = sFlag_Dai) then
        nDaiQuickSync := True;
      //袋装开单及推单,影响出厂推单和冻结业务

      if nDaiQuickSync then
      with FOrderItems[nIdx] do
      begin
        nStr := '订单[ %s.%s ]使用开单即推单业务.';
        nStr := Format(nStr, [FOrder, FStockName]);
        WriteLog(nStr);
      end;
      {$ENDIF}

      if FListA.Values['Post'] = sFlag_TruckBFM then //散装称重时并单
      begin
        nStr := FListA.Values['PValue'];
        if not IsNumber(nStr, True) then
          nStr := '0';
        //xxxxx

        nStr := MakeSQLByStr([SF('L_Status', sFlag_TruckFH),
                SF('L_NextStatus', sFlag_TruckBFM),
                SF('L_InTime', sField_SQLServer_Now, sfVal),
                SF('L_PValue', nStr, sfVal),
                SF('L_PDate', sField_SQLServer_Now, sfVal),
                SF('L_PMan', FIn.FBase.FFrom.FUser),
                SF('L_LadeTime', sField_SQLServer_Now, sfVal),
                SF('L_LadeMan', FIn.FBase.FFrom.FUser),
                SF('L_Card', FListA.Values['Card'])
                ], sTable_Bill, SF('L_ID', nOut.FData), False);
        gDBConnManager.WorkerExec(FDBConn, nStr);

        nBill := nOut.FData;
        //保存订单

        FListC.Clear;
        FListC.Values['Group'] := sFlag_BusGroup;
        FListC.Values['Object'] := sFlag_PoundID;

        if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
          raise Exception.Create(nOut.FData);
        //xxxxx

        nStr := FListA.Values['PValue'];
        if not IsNumber(nStr, True) then
          nStr := '0';

        nStr := MakeSQLByStr([
                SF('P_ID', nOut.FData),
                SF('P_Type', sFlag_Sale),
                SF('P_Bill', nBill),

                SF('P_Truck', FListA.Values['Truck']),
                SF('P_CusID', FOrderItems[nIdx].FCusID),
                SF('P_CusName', FOrderItems[nIdx].FCusName),
                SF('P_MID', FOrderItems[nIdx].FStockID),
                SF('P_MName', FOrderItems[nIdx].FStockName),
                SF('P_MType', FOrderItems[nIdx].FStockType),
                SF('P_LimValue', FOrderItems[nIdx].FKDValue, sfVal),

                SF('P_PValue', nStr, sfVal),
                SF('P_PDate', sField_SQLServer_Now, sfVal),
                SF('P_PMan', FIn.FBase.FFrom.FUser),
                SF('P_PStation', 'SZBDBF'),

                SF('P_Direction', '出厂'),
                SF('P_PModel', sFlag_PoundPD),
                SF('P_Status', sFlag_TruckBFP),
                SF('P_Valid', sFlag_Yes),
                SF('P_PrintNum', 1, sfVal)
                ], sTable_PoundLog, '', True);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end else

      if FListA.Values['BuDan'] = sFlag_Yes then //补单
      begin
        nStr := MakeSQLByStr([SF('L_Status', sFlag_TruckOut),
                SF('L_InTime', sField_SQLServer_Now, sfVal),
                SF('L_PValue', 0, sfVal),
                SF('L_PDate', sField_SQLServer_Now, sfVal),
                SF('L_PMan', FIn.FBase.FFrom.FUser),
                SF('L_MValue', FOrderItems[nIdx].FKDValue, sfVal),
                SF('L_MDate', sField_SQLServer_Now, sfVal),
                SF('L_MMan', FIn.FBase.FFrom.FUser),
                SF('L_OutFact', sField_SQLServer_Now, sfVal),
                SF('L_OutMan', FIn.FBase.FFrom.FUser),
                SF('L_Card', '')
                ], sTable_Bill, SF('L_ID', nOut.FData), False);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end else
      begin
        nStr := FOrderItems[nIdx].FStockID;
        nStr := GetMatchRecord(nStr);
        //该品种在装车队列中的记录号

        if nStr <> '' then
        begin
          nSQL := 'Update $TK Set T_Value=T_Value + $Val,' +
                  'T_HKBills=T_HKBills+''$BL.'' Where R_ID=$RD';
          nSQL := MacroValue(nSQL, [MI('$TK', sTable_ZTTrucks),
                  MI('$RD', nStr),
                  MI('$Val', FloatToStr(FOrderItems[nIdx].FKDValue)),
                  MI('$BL', nOut.FData)]);
          gDBConnManager.WorkerExec(FDBConn, nSQL);
        end else
        begin
          if FListA.Values['PointLineID'] <> '' then
          begin
            nSQL := MakeSQLByStr([
              SF('T_Truck'   , FListA.Values['Truck']),
              SF('T_StockNo' , FOrderItems[nIdx].FStockID),
              SF('T_Stock'   , FOrderItems[nIdx].FStockName),
              SF('T_Type'    , FOrderItems[nIdx].FStockType),
              SF('T_InTime'  , sField_SQLServer_Now, sfVal),
              SF('T_Bill'    , nOut.FData),
              SF('T_Valid'   , sFlag_Yes),
              SF('T_Value'   , FOrderItems[nIdx].FKDValue, sfVal),
              SF('T_VIP'     , FListA.Values['IsVIP']),
              {$IFDEF LineGroup}
              SF('T_LineGroup', FListA.Values['LineGroup']),
                {$ELSE}
                {$IFDEF AutoGetLineGroup}
                SF('T_LineGroup', FListA.Values['LineGroup']),
                SF('T_Line', FListA.Values['PointLineID']),
                SF('T_InQueue'  , sField_SQLServer_Now, sfVal),
                {$ENDIF}
              {$ENDIF}
              SF('T_HKBills' , nOut.FData + '.')
              ], sTable_ZTTrucks, '', True);
          end
          else
          begin
            nSQL := MakeSQLByStr([
              SF('T_Truck'   , FListA.Values['Truck']),
              SF('T_StockNo' , FOrderItems[nIdx].FStockID),
              SF('T_Stock'   , FOrderItems[nIdx].FStockName),
              SF('T_Type'    , FOrderItems[nIdx].FStockType),
              SF('T_InTime'  , sField_SQLServer_Now, sfVal),
              SF('T_Bill'    , nOut.FData),
              SF('T_Valid'   , sFlag_Yes),
              SF('T_Value'   , FOrderItems[nIdx].FKDValue, sfVal),
              SF('T_VIP'     , FListA.Values['IsVIP']),
              {$IFDEF LineGroup}
              SF('T_LineGroup', FListA.Values['LineGroup']),
                {$ELSE}
                {$IFDEF AutoGetLineGroup}
                SF('T_LineGroup', FListA.Values['LineGroup']),
                {$ENDIF}
              {$ENDIF}
              SF('T_HKBills' , nOut.FData + '.')
              ], sTable_ZTTrucks, '', True);
          end;
          gDBConnManager.WorkerExec(FDBConn, nSQL);

          nStr := 'Select Max(R_ID) From ' + sTable_ZTTrucks;
          with gDBConnManager.WorkerQuery(FDBConn, nStr) do
            nStr := Fields[0].AsString;
          //插入记录号

          nInt := Length(FMatchItems);
          SetLength(FMatchItems, nInt + 1);
          with FMatchItems[nInt] do
          begin
            FStock := FOrderItems[nIdx].FStockID;
            FGroup := GetStockGroup(FStock, nInt);

            FPriority := nInt;
            FRecord := nStr;
          end;
        end;
      end;

      //补单 or 包装提前推单
      if nDaiQuickSync or (FListA.Values['BuDan'] = sFlag_Yes) then
      begin
        nStr := 'Update %s Set B_HasDone=B_HasDone+%.2f Where B_ID=''%s''';
        nStr := Format(nStr, [sTable_Order, FOrderItems[nIdx].FKDValue,
                FOrderItems[nIdx].FOrder]);
        nInt := gDBConnManager.WorkerExec(FDBConn, nStr);

        if nInt < 1 then
        begin
          nSQL := MakeSQLByStr([
            SF('B_ID', FOrderItems[nIdx].FOrder),
            SF('B_Freeze', '0', sfVal),
            SF('B_HasDone', FOrderItems[nIdx].FKDValue, sfVal)
            ], sTable_Order, '', True);
          gDBConnManager.WorkerExec(FDBConn, nSQL);
        end;
      end else
      begin
        nStr := 'Update %s Set B_Freeze=B_Freeze+%.2f Where B_ID=''%s''';
        nStr := Format(nStr, [sTable_Order, FOrderItems[nIdx].FKDValue,
                FOrderItems[nIdx].FOrder]);
        nInt := gDBConnManager.WorkerExec(FDBConn, nStr);

        if nInt < 1 then
        begin
          nStr := MakeSQLByStr([
            SF('B_ID', FOrderItems[nIdx].FOrder),
            SF('B_HasDone', '0', sfVal),
            SF('B_Freeze', FOrderItems[nIdx].FKDValue, sfVal)
            ], sTable_Order, '', True);
          gDBConnManager.WorkerExec(FDBConn, nStr);
        end;
      end;

      {$IFNDEF BatCodeByLine}
      {$IFDEF AutoGetLineGroup}
      nSQL := 'Update %s Set B_HasUse=B_HasUse+(%s),B_LastDate=%s ' +
              'Where B_Batcode=''%s'' ';
      nSQL := Format(nSQL, [sTable_Batcode, FloatToStr(FOrderItems[nIdx].FKDValue),
              sField_SQLServer_Now, FListA.Values['Seal']]);
      gDBConnManager.WorkerExec(FDBConn, nSQL); //更新批次号使用量
      {$ELSE}
      if FAutoBatBrand then
      begin
        nSQL := 'Update %s Set B_HasUse=B_HasUse+(%s),B_LastDate=%s ' +
                'Where B_Batcode=''%s'' ';
        nSQL := Format(nSQL, [sTable_Batcode, FloatToStr(FOrderItems[nIdx].FKDValue),
                sField_SQLServer_Now, FListA.Values['Seal']]);
        gDBConnManager.WorkerExec(FDBConn, nSQL); //更新批次号使用量
      end
      else
      begin
        if FListA.Values['IsVIP'] = '' then
          nStr := sFlag_TypeCommon
        else
          nStr := FListA.Values['IsVIP'];
        nSQL := 'Update %s Set B_HasUse=B_HasUse+(%s),B_LastDate=%s ' +
                'Where B_Stock=''%s'' and B_Type=''%s'' ';
        nSQL := Format(nSQL, [sTable_Batcode, FloatToStr(FOrderItems[nIdx].FKDValue),
                sField_SQLServer_Now, FOrderItems[nIdx].FStockID, nStr]);
        gDBConnManager.WorkerExec(FDBConn, nSQL); //更新批次号使用量
      end;
      {$ENDIF}

      nSQL := 'Update %s Set D_Sent=D_Sent+(%s) Where D_ID=''%s''';
      nSQL := Format(nSQL, [sTable_BatcodeDoc, FloatToStr(FOrderItems[nIdx].FKDValue),
              FListA.Values['Seal']]);
      gDBConnManager.WorkerExec(FDBConn, nSQL); //更新批次号使用量
      {$ENDIF}

      {$IFDEF SaleAICMFromNC}
      if Trim(FListA.Values['wxzhuid']) <> '' then//过滤非微信下单
      begin
        if FListA.Values['Post'] = sFlag_TruckBFM then //散装称重时并单
        begin
          nStr := MakeSQLByStr([
                  SF('WOM_WebOrderID'   , FOrderItems[nIdx].FOrder),
                  SF('WOM_LID'          , nBill),
                  SF('WOM_StatusType'   , c_WeChatStatusCreateCard),
                  SF('WOM_MsgType'      , cSendWeChatMsgType_AddBill),
                  SF('WOM_BillType'     , sFlag_Sale),
                  SF('WOM_deleted'     , sFlag_No)
                  ], sTable_WebOrderMatch, '', True);
        end
        else
        begin
          nStr := MakeSQLByStr([
                  SF('WOM_WebOrderID'   , FOrderItems[nIdx].FOrder),
                  SF('WOM_LID'          , nOut.FData),
                  SF('WOM_StatusType'   , c_WeChatStatusCreateCard),
                  SF('WOM_MsgType'      , cSendWeChatMsgType_AddBill),
                  SF('WOM_BillType'     , sFlag_Sale),
                  SF('WOM_deleted'     , sFlag_No)
                  ], sTable_WebOrderMatch, '', True);
        end;
        gDBConnManager.WorkerExec(FDBConn, nStr);
      //微信推送
      end;
      {$ENDIF}
    end;

    nIdx := Length(FOut.FData);
    if Copy(FOut.FData, nIdx, 1) = ',' then
      System.Delete(FOut.FData, nIdx, 1);
    //xxxxx

    FDBConn.FConn.CommitTrans;
    Result := True;

    gDBConnManager.ReleaseConnection(FDBConn);
    FDBConn := nDBWorker;
    //还原链路
  except
    FDBConn.FConn.RollbackTrans;
    gDBConnManager.ReleaseConnection(FDBConn);
    FDBConn := nDBWorker;
    //还原链路
    raise;
  end;

  {$IFDEF DaiQuickSync}
  if nDaiQuickSync then
  begin
    SplitStr(FOut.FData, FListC, 0, ',');
    if not TWorkerBusinessCommander.CallMe(cBC_SyncME25,
          FListC.Text, '', @nOut) then
      raise Exception.Create(nOut.FData);
    //袋装开单及推单,同步到NC榜单
  end;
  {$ENDIF}

  FListC.Clear;
  FListC.Values['DLID']  := FOut.FData;
  FListC.Values['MType'] := sFlag_Sale;
  if FListA.Values['BuDan'] = sFlag_Yes then
       FListC.Values['BillType'] := IntToStr(cMsg_WebChat_BillFinished)
  else FListC.Values['BillType'] := IntToStr(cMsg_WebChat_BillNew);
  TWorkerBusinessCommander.CallMe(cBC_WebChat_DLSaveShopInfo,
   PackerEncodeStr(FListC.Text), '', @nOut);
  //保存同步信息

  {$IFDEF HardMon}
  if Length(FListA.Values['PoundStation']) > 0 then
  begin
    FListC.Clear;
    FListC.Values['Card'] := 'dt';
    FListC.Values['Text'] := #9 + FListA.Values['Truck'] + #9;
    FListC.Values['Content'] := FListA.Values['PoundStation'];
    THardwareCommander.CallMe(cBC_PlayVoice, PackerEncodeStr(FListC.Text), '', @nOut);

    FListC.Clear;
    FListC.Values['Card'] := 'dt1';
    FListC.Values['Text'] := #9 + FListA.Values['Truck'] + #9;
    FListC.Values['Content'] := FListA.Values['PoundStation'];
    THardwareCommander.CallMe(cBC_PlayVoice, PackerEncodeStr(FListC.Text), '', @nOut);
  end;
  {$ENDIF}
end;

//------------------------------------------------------------------------------
//Date: 2014-09-16
//Parm: 交货单[FIn.FData];车牌号[FIn.FExtParam]
//Desc: 修改指定交货单的车牌号
function TWorkerBusinessBills.ChangeBillTruck(var nData: string): Boolean;
var nIdx: Integer;
    nStr,nTruck: string;
begin
  Result := False;
  if not VerifyTruckNO(FIn.FExtParam, nData) then Exit;

  nStr := 'Select L_Truck,L_InTime From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <> 1 then
    begin
      nData := '交货单[ %s ]已无效.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    if Fields[1].AsString <> '' then
    begin
      nData := '交货单[ %s ]已提货,无法修改车牌号.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;


    nTruck := Fields[0].AsString;
  end;

  nStr := 'Select R_ID,T_HKBills From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_ZTTrucks, nTruck]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    FListA.Clear;
    FListB.Clear;
    First;

    while not Eof do
    begin
      SplitStr(Fields[1].AsString, FListC, 0, '.');
      FListA.AddStrings(FListC);
      FListB.Add(Fields[0].AsString);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set L_Truck=''%s'' Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FExtParam, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //更新修改信息

    if (FListA.Count > 0) and (CompareText(nTruck, FIn.FExtParam) <> 0) then
    begin
      for nIdx:=FListA.Count - 1 downto 0 do
      if CompareText(FIn.FData, FListA[nIdx]) <> 0 then
      begin
        nStr := 'Update %s Set L_Truck=''%s'' Where L_ID=''%s''';
        nStr := Format(nStr, [sTable_Bill, FIn.FExtParam, FListA[nIdx]]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        //同步合单车牌号
      end;
    end;

    if (FListB.Count > 0) and (CompareText(nTruck, FIn.FExtParam) <> 0) then
    begin
      for nIdx:=FListB.Count - 1 downto 0 do
      begin
        nStr := 'Update %s Set T_Truck=''%s'' Where R_ID=%s';
        nStr := Format(nStr, [sTable_ZTTrucks, FIn.FExtParam, FListB[nIdx]]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        //同步合单车牌号
      end;
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-16
//Parm: 交货单号[FIn.FData]
//Desc: 删除指定交货单
function TWorkerBusinessBills.DeleteBill(var nData: string): Boolean;
var nVal: Double;
    nIdx: Integer;
    nHasOut, nIsAdmin: Boolean;
    nOut: TWorkerBusinessCommand;
    nStr,nP,nRID,nBill,nZK,nSN,nHY,nTP, nLineGroup,nVip: string;
begin
  Result := False;
  nIsAdmin := FIn.FExtParam = 'Y';
  //init

  FAutoBatBrand := False;
  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_AutoBatBrand]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    FAutoBatBrand := Fields[0].AsString = sFlag_Yes;
  end;

  nStr := 'Select L_ZhiKa,L_Value,L_Seal,L_StockNO,L_Type,L_OutFact,L_LineGroup,L_IsVIP From %s ' +
          'Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '交货单[ %s ]已无效.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nHasOut := FieldByName('L_OutFact').AsString <> '';
    //已出厂

    if nHasOut and (not nIsAdmin) then       //管理员可以删除
    begin
      nData := '交货单[ %s ]已出厂,不允许删除.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nTP  := FieldByName('L_Type').AsString;
    nSN  := FieldByName('L_StockNO').AsString;
    nZK  := FieldByName('L_ZhiKa').AsString;
    nHY  := FieldByName('L_Seal').AsString;
    nVal := FieldByName('L_Value').AsFloat;
    nLineGroup  := FieldByName('L_LineGroup').AsString;
    nVip := FieldByName('L_IsVIP').AsString;
  end;

  nStr := 'Select R_ID,T_HKBills,T_Bill From %s ' +
          'Where T_HKBills Like ''%%%s%%''';
  nStr := Format(nStr, [sTable_ZTTrucks, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    if RecordCount <> 1 then
    begin
      nData := '交货单[ %s ]出现在多条记录上,异常终止!';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nRID := Fields[0].AsString;
    nBill := Fields[2].AsString;
    SplitStr(Fields[1].AsString, FListA, 0, '.')
  end else
  begin
    nRID := '';
    FListA.Clear;
  end;

  FDBConn.FConn.BeginTrans;
  try
    if FListA.Count = 1 then
    begin
      nStr := 'Delete From %s Where R_ID=%s';
      nStr := Format(nStr, [sTable_ZTTrucks, nRID]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end else

    if FListA.Count > 1 then
    begin
      nIdx := FListA.IndexOf(FIn.FData);
      if nIdx >= 0 then
        FListA.Delete(nIdx);
      //移出合单列表

      if nBill = FIn.FData then
        nBill := FListA[0];
      //更换交货单

      nStr := 'Update %s Set T_Bill=''%s'',T_Value=T_Value-(%.2f),' +
              'T_HKBills=''%s'' Where R_ID=%s';
      nStr := Format(nStr, [sTable_ZTTrucks, nBill, nVal,
              CombinStr(FListA, '.'), nRID]);
      //xxxxx

      gDBConnManager.WorkerExec(FDBConn, nStr);
      //更新合单信息
    end;

    //--------------------------------------------------------------------------
    nStr := '';
    {$IFDEF DaiQuickSync}
    if nTP = sFlag_Dai then
      nStr := sFlag_Yes;
    //xxxxx
    {$ENDIF}

    if nHasOut or (nStr = sFlag_Yes) then
    begin
      nStr := 'Update %s Set B_HasDone=B_HasDone-(%.2f) Where B_ID=''%s''';
      nStr := Format(nStr, [sTable_Order, nVal, nZK]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //释放发货量
    end else
    begin
      nStr := 'Update %s Set B_Freeze=B_Freeze-(%.2f) Where B_ID=''%s''';
      nStr := Format(nStr, [sTable_Order, nVal, nZK]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //释放冻结量
    end;

    //--------------------------------------------------------------------------
    nStr := Format('Select * From %s Where 1<>1', [sTable_Bill]);
    //only for fields
    nP := '';

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      for nIdx:=0 to FieldCount - 1 do
       if (Fields[nIdx].DataType <> ftAutoInc) and
          (Pos('L_Del', Fields[nIdx].FieldName) < 1) then
        nP := nP + Fields[nIdx].FieldName + ',';
      //所有字段,不包括删除

      System.Delete(nP, Length(nP), 1);
    end;

    nStr := 'Insert Into $BB($FL,L_DelMan,L_DelDate) ' +
            'Select $FL,''$User'',$Now From $BI Where L_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$BB', sTable_BillBak),
            MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
            MI('$Now', sField_SQLServer_Now),
            MI('$BI', sTable_Bill), MI('$ID', FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    {$IFDEF BatCodeByLine}
    if nHY <> '' then
    begin
      nStr := 'Update %s Set B_HasUse=B_HasUse-(%.2f),B_LastDate=%s ' +
              'Where B_Batcode=''%s''';
      nStr := Format(nStr, [sTable_Batcode, nVal,
              sField_SQLServer_Now, nHY]);
      gDBConnManager.WorkerExec(FDBConn, nStr); //更新批次号使用量

      nStr := 'Update %s Set D_Sent=D_Sent-(%.2f) Where D_ID=''%s''';
      nStr := Format(nStr, [sTable_BatcodeDoc, nVal, nHY]);
      gDBConnManager.WorkerExec(FDBConn, nStr); //更新批次号使用量
    end;
    {$ELSE}
      {$IFDEF AutoGetLineGroup}
      nStr := 'Update %s Set B_HasUse=B_HasUse-(%.2f),B_LastDate=%s ' +
              'Where B_Batcode=''%s''';
      nStr := Format(nStr, [sTable_Batcode, nVal,
              sField_SQLServer_Now, nHY]);
      gDBConnManager.WorkerExec(FDBConn, nStr); //更新批次号使用量
      {$ELSE}
      if FAutoBatBrand then
      begin
        nStr := 'Update %s Set B_HasUse=B_HasUse-(%.2f),B_LastDate=%s ' +
                'Where B_Batcode=''%s''';
        nStr := Format(nStr, [sTable_Batcode, nVal,
                sField_SQLServer_Now, nHY]);
        gDBConnManager.WorkerExec(FDBConn, nStr); //更新批次号使用量
      end
      else
      begin
        if nVip = '' then
         nVip := sFlag_TypeCommon;
        nStr := 'Update %s Set B_HasUse=B_HasUse-(%.2f),B_LastDate=%s ' +
                'Where B_Stock=''%s'' and B_Type=''%s''';
        nStr := Format(nStr, [sTable_Batcode, nVal,
                sField_SQLServer_Now, nSN, nVip]);
        gDBConnManager.WorkerExec(FDBConn, nStr); //更新批次号使用量
      end;
      {$ENDIF}

      nStr := 'Update %s Set D_Sent=D_Sent-(%.2f) Where D_ID=''%s''';
      nStr := Format(nStr, [sTable_BatcodeDoc, nVal, nHY]);
      gDBConnManager.WorkerExec(FDBConn, nStr); //更新批次号使用量
    {$ENDIF}

    nStr := 'Delete From %s Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Update %s Set B_IsUsed=''%s'', B_LID=NULL Where B_LID=''%s''';
    nStr := Format(nStr, [sTable_BillNew, sFlag_No, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;

  FListC.Clear;
  FListC.Values['DLID']  := FIn.FData;
  FListC.Values['MType'] := sFlag_Sale;
  FListC.Values['BillType'] := IntToStr(cMsg_WebChat_BillDel);
  TWorkerBusinessCommander.CallMe(cBC_WebChat_DLSaveShopInfo,
   PackerEncodeStr(FListC.Text), '', @nOut);
  //保存同步信息
end;

//Date: 2014-09-17
//Parm: 交货单[FIn.FData];磁卡号[FIn.FExtParam]
//Desc: 为交货单绑定磁卡
function TWorkerBusinessBills.SaveBillCard(var nData: string): Boolean;
var nStr,nSQL,nTruck,nType: string;
begin
  nType := '';
  nTruck := '';
  Result := False;

  FListB.Text := FIn.FExtParam;
  //磁卡列表
  nStr := AdjustListStrFormat(FIn.FData, '''', True, ',', False);
  //交货单列表

  nSQL := 'Select L_ID,L_Card,L_Type,L_Truck,L_OutFact From %s ' +
          'Where L_ID In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('交货单[ %s ]已丢失.', [FIn.FData]);
      Exit;
    end;

    First;
    while not Eof do
    begin
      if FieldByName('L_OutFact').AsString <> '' then
      begin
        nData := '交货单[ %s ]已出厂,禁止办卡.';
        nData := Format(nData, [FieldByName('L_ID').AsString]);
        Exit;
      end;

      nStr := FieldByName('L_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '交货单[ %s ]的车牌号不一致,不能并单.' + #13#10#13#10 +
                 '*.本单车牌: %s' + #13#10 +
                 '*.其它车牌: %s' + #13#10#13#10 +
                 '相同牌号才能并单,请修改车牌号,或者单独办卡.';
        nData := Format(nData, [FieldByName('L_ID').AsString, nStr, nTruck]);
        Exit;
      end;

      if nTruck = '' then
        nTruck := nStr;
      //xxxxx

      nStr := FieldByName('L_Type').AsString;
      //if (nType <> '') and ((nStr <> nType) or (nStr = sFlag_San)) then

      if (nType <> '') and ((nStr <> nType)) then
      begin
        if nStr = sFlag_San then
             nData := '交货单[ %s ]同为散装,不能并单.'
        else nData := '交货单[ %s ]的水泥类型不一致,不能并单.';

        nData := Format(nData, [FieldByName('L_ID').AsString]);
        Exit;
      end;

      if nType = '' then
        nType := nStr;
      //xxxxx

      nStr := FieldByName('L_Card').AsString;
      //正在使用的磁卡

      if (nStr <> '') and (FListB.IndexOf(nStr) < 0) then
        FListB.Add(nStr);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  if nTruck = '' then
  begin
    nData := '交货单[ %s ]车牌号无效(Truck Is Blank).';
    nData := Format(nData, [FIn.FData]);
    Exit;
  end;

  SplitStr(FIn.FData, FListA, 0, ',');
  //交货单列表
  nStr := AdjustListStrFormat2(FListB, '''', True, ',', False);
  //磁卡列表

  nSQL := 'Select L_ID,L_Type,L_Truck From %s Where L_Card In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      nStr := FieldByName('L_Type').AsString;
      //if (nStr <> sFlag_Dai) or ((nType <> '') and (nStr <> nType)) then
      if ((nType <> '') and (nStr <> nType)) then
      begin
        nData := '车辆[ %s ]正在使用该卡,无法并单.';
        nData := Format(nData, [FieldByName('L_Truck').AsString]);
        Exit;
      end;

      nStr := FieldByName('L_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '车辆[ %s ]正在使用该卡,相同牌号才能并单.';
        nData := Format(nData, [nStr]);
        Exit;
      end;

      nStr := FieldByName('L_ID').AsString;
      if FListA.IndexOf(nStr) < 0 then
        FListA.Add(nStr);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  nSQL := 'Select L_ID,L_Type From %s ' +
          'Where L_OutFact Is Null And L_Truck=''%s''';
  nSQL := Format(nSQL, [sTable_Bill, nTruck]); //该车其它交货单

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      nStr := FieldByName('L_Type').AsString;
      if ((nType <> '') and (nStr <> nType)) then
      begin
        nData := '交货单[ %s ]水泥品种不符,无法并单.';
        nData := Format(nData, [FieldByName('L_ID').AsString]);
        Exit;
      end;

      nStr := FieldByName('L_ID').AsString;
      if FListA.IndexOf(nStr) < 0 then
        FListA.Add(nStr);
      Next;
    end;
  end;

  FDBConn.FConn.BeginTrans;
  try
    if FIn.FData <> '' then
    begin
      nStr := AdjustListStrFormat2(FListA, '''', True, ',', False);
      //重新计算列表

      nSQL := 'Update %s Set L_Card=''%s'' Where L_ID In(%s)';
      nSQL := Format(nSQL, [sTable_Bill, FIn.FExtParam, nStr]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
      WriteLog('交货单绑定磁卡SQL:' + nSQL);
    end;

    nStr := 'Select Count(*) From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FIn.FExtParam]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if Fields[0].AsInteger < 1 then
    begin
      nStr := MakeSQLByStr([SF('C_Card', FIn.FExtParam),
              SF('C_Status', sFlag_CardUsed),
              SF('C_Group', sFlag_ProvCardL),
              SF('C_Used', sFlag_Sale),
              SF('C_Freeze', sFlag_No),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      WriteLog('更改磁卡状态SQL:' + nStr);
    end else
    begin
      nStr := Format('C_Card=''%s''', [FIn.FExtParam]);
      nStr := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
              SF('C_Group', sFlag_ProvCardL),
              SF('C_Freeze', sFlag_No),
              SF('C_Used', sFlag_Sale),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, nStr, False);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      WriteLog('更改磁卡状态SQL:' + nStr);
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2018-07-20
//Parm: 交货单[FIn.FData];磁卡号[FIn.FExtParam]
//Desc: 为交货单绑定磁卡(一车多卡)
function TWorkerBusinessBills.SaveBillMulCard(var nData: string): Boolean;
var nStr,nSQL,nTruck,nType: string;
begin
  nType := '';
  nTruck := '';
  Result := False;

  FListB.Text := FIn.FExtParam;
  //磁卡列表
  nStr := AdjustListStrFormat(FIn.FData, '''', True, ',', False);
  //交货单列表

  nSQL := 'Select L_ID,L_Card,L_Type,L_Truck,L_OutFact From %s ' +
          'Where L_ID In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('交货单[ %s ]已丢失.', [FIn.FData]);
      Exit;
    end;

    First;
    while not Eof do
    begin
      if FieldByName('L_OutFact').AsString <> '' then
      begin
        nData := '交货单[ %s ]已出厂,禁止办卡.';
        nData := Format(nData, [FieldByName('L_ID').AsString]);
        Exit;
      end;

      nStr := FieldByName('L_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '交货单[ %s ]的车牌号不一致,不能并单.' + #13#10#13#10 +
                 '*.本单车牌: %s' + #13#10 +
                 '*.其它车牌: %s' + #13#10#13#10 +
                 '相同牌号才能并单,请修改车牌号,或者单独办卡.';
        nData := Format(nData, [FieldByName('L_ID').AsString, nStr, nTruck]);
        Exit;
      end;

      if nTruck = '' then
        nTruck := nStr;
      //xxxxx

      nStr := FieldByName('L_Type').AsString;
      //if (nType <> '') and ((nStr <> nType) or (nStr = sFlag_San)) then

      if (nType <> '') and ((nStr <> nType)) then
      begin
        if nStr = sFlag_San then
             nData := '交货单[ %s ]同为散装,不能并单.'
        else nData := '交货单[ %s ]的水泥类型不一致,不能并单.';

        nData := Format(nData, [FieldByName('L_ID').AsString]);
        Exit;
      end;

      if nType = '' then
        nType := nStr;
      //xxxxx

      nStr := FieldByName('L_Card').AsString;
      //正在使用的磁卡

      if (nStr <> '') and (FListB.IndexOf(nStr) < 0) then
        FListB.Add(nStr);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  if nTruck = '' then
  begin
    nData := '交货单[ %s ]车牌号无效(Truck Is Blank).';
    nData := Format(nData, [FIn.FData]);
    Exit;
  end;

  SplitStr(FIn.FData, FListA, 0, ',');
  //交货单列表
  nStr := AdjustListStrFormat2(FListB, '''', True, ',', False);
  //磁卡列表

  nSQL := 'Select L_ID,L_Type,L_Truck From %s Where L_Card In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    nData := '车辆[ %s ]正在使用该卡,无法办卡.';
    nData := Format(nData, [FieldByName('L_Truck').AsString]);
    Exit;
  end;

  FDBConn.FConn.BeginTrans;
  try
    if FIn.FData <> '' then
    begin
      nStr := AdjustListStrFormat2(FListA, '''', True, ',', False);
      //重新计算列表

      nSQL := 'Update %s Set L_Card=''%s'' Where L_ID In(%s)';
      nSQL := Format(nSQL, [sTable_Bill, FIn.FExtParam, nStr]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    nStr := 'Select Count(*) From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FIn.FExtParam]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if Fields[0].AsInteger < 1 then
    begin
      nStr := MakeSQLByStr([SF('C_Card', FIn.FExtParam),
              SF('C_Status', sFlag_CardUsed),
              SF('C_Group', sFlag_ProvCardL),
              SF('C_Used', sFlag_Sale),
              SF('C_Freeze', sFlag_No),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end else
    begin
      nStr := Format('C_Card=''%s''', [FIn.FExtParam]);
      nStr := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
              SF('C_Group', sFlag_ProvCardL),
              SF('C_Freeze', sFlag_No),
              SF('C_Used', sFlag_Sale),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, nStr, False);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: 磁卡号[FIn.FData]
//Desc: 注销磁卡
function TWorkerBusinessBills.LogoffCard(var nData: string): Boolean;
var nStr: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set L_Card=Null Where L_Card=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Update %s Set C_Status=''%s'' Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, sFlag_CardInvalid, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: 磁卡号[FIn.FData];岗位[FIn.FExtParam]
//Desc: 获取特定岗位所需要的交货单列表
function TWorkerBusinessBills.GetPostBillItems(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nIsBill: Boolean;
    nBills: TLadingBillItems;
begin
  Result := False;
  nIsBill := False;

  nStr := 'Select B_Prefix, B_IDLen From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_BillNo]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nIsBill := (Pos(Fields[0].AsString, FIn.FData) = 1) and
               (Length(FIn.FData) = Fields[1].AsInteger);
    //前缀和长度都满足交货单编码规则,则视为交货单号
  end;

  if not nIsBill then
  begin
    nStr := 'Select C_Status,C_Freeze From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FIn.FData]);
    //card status

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := Format('磁卡[ %s ]信息已丢失.', [FIn.FData]);
        Exit;
      end;

      if Fields[0].AsString <> sFlag_CardUsed then
      begin
        nData := '磁卡[ %s ]当前状态为[ %s ],无法提货.';
        nData := Format(nData, [FIn.FData, CardStatusToStr(Fields[0].AsString)]);
        Exit;
      end;

      if Fields[1].AsString = sFlag_Yes then
      begin
        nData := '磁卡[ %s ]已被冻结,无法提货.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;
    end;
  end;

  nStr := 'Select * From $Bill b ';
  //xxxxx

  if nIsBill then
       nStr := nStr + 'Where L_ID=''$CD'''
  else nStr := nStr + 'Where L_Card=''$CD''';

  nStr := MacroValue(nStr, [MI('$Bill', sTable_Bill), MI('$CD', FIn.FData)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      if nIsBill then
           nData := '交货单[ %s ]已无效.'
      else nData := '磁卡号[ %s ]没有交货单.';

      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    SetLength(nBills, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    with nBills[nIdx] do
    begin
      FID         := FieldByName('L_ID').AsString;
      FZhiKa      := FieldByName('L_ZhiKa').AsString;
      FCusID      := FieldByName('L_CusID').AsString;
      FCusName    := FieldByName('L_CusName').AsString;
      FTruck      := FieldByName('L_Truck').AsString;

      FType       := FieldByName('L_Type').AsString;
      FStockNo    := FieldByName('L_StockNo').AsString;
      FStockName  := FieldByName('L_StockName').AsString;
      FValue      := FieldByName('L_Value').AsFloat;
      FPrice      := FieldByName('L_Price').AsFloat;

      FCard       := FieldByName('L_Card').AsString;
      FIsVIP      := FieldByName('L_IsVIP').AsString;
      FStatus     := FieldByName('L_Status').AsString;
      FNextStatus := FieldByName('L_NextStatus').AsString;

      FHYDan      := FieldByName('L_Seal').AsString;
      {$IFDEF PrintHYEach}
      FPrintHY    := FieldByName('L_PrintHY').AsString = sFlag_Yes;
      {$ENDIF}

      {$IFDEF RemoteSnap}
      FSnapTruck  := FieldByName('L_SnapTruck').AsString = sFlag_Yes;
      {$ENDIF}

      {$IFNDEF CZNF}
      if FIsVIP = sFlag_TypeShip then
      begin
        FStatus    := sFlag_TruckZT;
        FNextStatus := sFlag_TruckOut;
      end;
      {$ENDIF}

      if FStatus = sFlag_BillNew then
      begin
        FStatus     := sFlag_TruckNone;
        FNextStatus := sFlag_TruckNone;
      end;

      if Assigned(FindField('L_LineGroup')) then
        FLineGroup    := FieldByName('L_LineGroup').AsString;

      if Assigned(FindField('L_PoundStation')) then
      begin
        FPoundStation := FieldByName('L_PoundStation').AsString;
        FPoundSName   := FieldByName('L_PoundName').AsString;
      end;

      if Assigned(FindField('L_PreValue')) then
        FPreValue    := FieldByName('L_PreValue').AsFloat;

      FPData.FValue := FieldByName('L_PValue').AsFloat;
      FMData.FValue := FieldByName('L_MValue').AsFloat;
      FSeal     := FieldByName('L_Seal').AsString;
      FMemo     := FieldByName('L_Memo').AsString;
      FYSValid      := FieldByName('L_EmptyOut').AsString;
      if FYSValid = sFlag_Yes then
        FPrintHY := False;
      FSelected := True;

      Inc(nIdx);
      Next;
    end;
  end;

  FOut.FData := CombineBillItmes(nBills);
  Result := True;
end;

//Date: 2017/7/15
//Parm: 排队顺序
//Desc: 从小到大排序
procedure SortBillItemsByValue(var nItems: TLadingBillItems);
var i,j,nInt: Integer;
    nItem: TLadingBillItem;
begin
  nInt := High(nItems);
  //xxxxx

  for i:=Low(nItems) to nInt do
   for j:=i+1 to nInt do
    if nItems[j].FValue < nItems[i].FValue then
    begin
      nItem := nItems[i];
      nItems[i] := nItems[j];
      nItems[j] := nItem;
    end;
  //冒泡排序
end;

//Date: 2014-09-18
//Parm: 交货单[FIn.FData];岗位[FIn.FExtParam]
//Desc: 保存指定岗位提交的交货单列表
function TWorkerBusinessBills.SavePostBillItems(var nData: string): Boolean;
var nStr,nSQL,nTmp: string;
    nVal,nMVal,nTotal,nDec,nNet: Double;
    i,nIdx,nInt: Integer;
    nDaiQuickSync: Boolean;
    {$IFDEF HardMon}
    nReader: THHReaderItem;
    {$ENDIF}
    nBills: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  AnalyseBillItems(FIn.FData, nBills);
  nInt := Length(nBills);

  if nInt < 1 then
  begin
    nData := '岗位[ %s ]提交的单据为空.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  {$IFDEF HardMon}
  if (FIn.FExtParam = sFlag_TruckBFP) or (FIn.FExtParam = sFlag_TruckBFM) then
  begin
    nTmp := gHardwareHelper.GetReaderLastOn(nBills[0].FCard, nReader);

    if (nTmp <> '') and (nReader.FGroup <> '') then
    begin
      nSQL := 'Select C_Group From %s Where C_Card=''%s''';
      nSQL := Format(nSQL, [sTable_Card, nBills[0].FCard]);
      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      begin
        if RecordCount < 1 then
        begin
          nData := '磁卡编号[ %s ]不匹配.';
          nData := Format(nData, [nBills[0].FCard]);
          Exit;
        end;

        nStr := UpperCase(Fields[0].AsString);
      end;

      if UpperCase(nReader.FGroup) <> nStr then
      begin
        nData := '磁卡号[ %s:::%s ]与读卡器[ %s:::%s ]分组匹配失败.';
        nData := Format(nData,[nBills[0].FCard, nStr, nReader.FID,
                 nReader.FGroup]);
        Exit;
      end;
    end;
  end;
  //过磅时，验证读卡器与卡片分组
  {$ENDIF}

  nDaiQuickSync := False;
  {$IFDEF DaiQuickSync}
  if nBills[0].FType = sFlag_Dai then
    nDaiQuickSync := True;
  //袋装开单及推单,影响出厂推单和冻结业务
  {$ENDIF}

  FListA.Clear;
  //用于存储SQL列表

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckIn then //进厂
  begin
    with nBills[0] do
    begin
      FStatus := sFlag_TruckIn;
      FNextStatus := sFlag_TruckBFP;
    end;

    if nBills[0].FType = sFlag_Dai then
    begin
      nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
      nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_PoundIfDai]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
       if (RecordCount > 0) and (Fields[0].AsString = sFlag_No) then
        nBills[0].FNextStatus := sFlag_TruckZT;
      //袋装不过磅
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    begin
      nStr := SF('L_ID', nBills[nIdx].FID);
      nSQL := MakeSQLByStr([
              SF('L_Status', nBills[0].FStatus),
              SF('L_NextStatus', nBills[0].FNextStatus),
              SF('L_InTime', sField_SQLServer_Now, sfVal),
              SF('L_InMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, nStr, False);
      FListA.Add(nSQL);

      nSQL := 'Update %s Set T_InFact=%s Where T_HKBills Like ''%%%s%%''';
      nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now,
              nBills[nIdx].FID]);
      FListA.Add(nSQL);
      //更新队列车辆进厂状态
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFP then //称量皮重
  begin
    {$IFDEF VerifyInTimeWhenP}
    if not VerifyTruckTimeWhenP(nBills[0].FTruck, nData) then Exit;
    //验证车辆进厂时间是否超时,避免代刷进厂
    {$ENDIF}

    FListB.Clear;
    nStr := 'Select D_Value From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_NFStock]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        FListB.Add(Fields[0].AsString);
        Next;
      end;
    end;

    nInt := -1;
    for nIdx:=Low(nBills) to High(nBills) do
    if nBills[nIdx].FPoundID = sFlag_Yes then
    begin
      nInt := nIdx;
      Break;
    end;

    if nInt < 0 then
    begin
      nData := '岗位[ %s ]提交的皮重数据为0.';
      nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
      Exit;
    end;

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FStatus := sFlag_TruckBFP;
      if FType = sFlag_Dai then
           FNextStatus := sFlag_TruckZT
      else FNextStatus := sFlag_TruckFH;

      if FListB.IndexOf(FStockNo) >= 0 then
        FNextStatus := sFlag_TruckBFM;
      //现场不发货直接过重

      nSQL := MakeSQLByStr([
              SF('L_Status', FStatus),
              SF('L_NextStatus', FNextStatus),
              SF('L_PValue', nBills[nInt].FPData.FValue, sfVal),
              SF('L_PDate', sField_SQLServer_Now, sfVal),
              SF('L_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL);

      if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      //xxxxx

      FOut.FData := nOut.FData;
      //返回榜单号,用于拍照绑定

      nSQL := MakeSQLByStr([
              SF('P_ID', nOut.FData),
              SF('P_Type', sFlag_Sale),
              SF('P_Bill', FID),
              SF('P_Truck', FTruck),
              SF('P_CusID', FCusID),
              SF('P_CusName', FCusName),
              SF('P_MID', FStockNo),
              SF('P_MName', FStockName),
              SF('P_MType', FType),
              SF('P_LimValue', FValue),
              SF('P_PValue', nBills[nInt].FPData.FValue, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_FactID', nBills[nInt].FFactory),
              SF('P_PStation', nBills[nInt].FPData.FStation),
              SF('P_Direction', '出厂'),
              SF('P_PModel', FPModel),
              SF('P_Status', sFlag_TruckBFP),
              SF('P_Valid', sFlag_Yes),
              SF('P_PrintNum', 1, sfVal)
              ], sTable_PoundLog, '', True);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('T_PValue', FPData.FValue, sfVal),
              SF('T_LastTime',sField_SQLServer_Now, sfVal)
              ], sTable_Truck, SF('T_Truck', FTruck), False);
      FListA.Add(nSQL);
      //更新车辆活动时间

      nSQL := Format('T_HKBills Like ''%%%s%%''', [FID]);
      nSQL := MakeSQLByStr([SF('T_PDate', sField_SQLServer_Now,sfVal)],
              sTable_ZTTrucks, nSQL, False);
      FListA.Add(nSQL);
      //更新队列中的过皮时间        
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckZT then //栈台现场
  begin
    nInt := -1;
    for nIdx:=Low(nBills) to High(nBills) do
    if nBills[nIdx].FPData.FValue > 0 then
    begin
      nInt := nIdx;
      Break;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      nStr := 'Select L_Status From %s Where L_ID=''%s''';
      nStr := Format(nStr, [sTable_Bill, FID]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      if RecordCount > 0 then
      begin
        if Fields[0].AsString = sFlag_TruckOut then
        begin
          nData := '提货单[ %s ]已出厂';
          nData := Format(nData, [FID]);
          Exit;
        end;
      end;

      FStatus := sFlag_TruckZT;
      if nInt >= 0 then //已称皮
           FNextStatus := sFlag_TruckBFM
      else FNextStatus := sFlag_TruckOut;

      nSQL := MakeSQLByStr([SF('L_Status', FStatus),
              SF('L_NextStatus', FNextStatus),
              {$IFDEF LineGroup}
              SF('L_LineGroup', FLineGroup),
              {$ENDIF}
              SF('L_LadeTime', sField_SQLServer_Now, sfVal),
              SF('L_EmptyOut', FYSValid),
              SF('L_LadeMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL);

      nSQL := 'Update %s Set T_InLade=%s Where T_HKBills Like ''%%%s%%''';
      nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now, FID]);
      FListA.Add(nSQL);
      //更新队列车辆提货状态
    end;
  end else

  if FIn.FExtParam = sFlag_TruckFH then //放灰现场
  begin
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FStatus := sFlag_TruckFH;
      FNextStatus := sFlag_TruckBFM;

      nStr := 'Select L_Status From %s Where L_ID=''%s''';
      nStr := Format(nStr, [sTable_Bill, FID]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      if RecordCount > 0 then
      begin
        if Fields[0].AsString = sFlag_TruckOut then
        begin
          nData := '提货单[ %s ]已出厂';
          nData := Format(nData, [FID]);
          Exit;
        end;
      end;

      nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
      nStr := Format(nStr, [sTable_SysDict, sFlag_ForceAddWater, FStockNo]);
      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      if RecordCount > 0 then
           nTmp := Fields[0].AsString
      else nTmp := sFlag_No;

      if (FYSValid <> sFlag_Yes) and (nTmp = sFlag_Yes) then
        FNextStatus := sFlag_TruckWT;
      //强制加水

      nSQL := MakeSQLByStr([SF('L_Status', FStatus),
              SF('L_NextStatus', FNextStatus),
              {$IFDEF LineGroup}
              SF('L_LineGroup', FLineGroup),
              {$ENDIF}
              SF('L_LadeTime', sField_SQLServer_Now, sfVal),
              SF('L_EmptyOut', FYSValid),
              SF('L_LadeMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL);

      nSQL := 'Update %s Set T_InLade=%s Where T_HKBills Like ''%%%s%%''';
      nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now, FID]);
      FListA.Add(nSQL);
      //更新队列车辆提货状态
    end;
  end else

  if FIn.FExtParam = sFlag_TruckWT then //验收现场
  begin
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      nSQL := MakeSQLByStr([SF('L_Status', sFlag_TruckWT),
              SF('L_NextStatus', sFlag_TruckBFM),
              SF('L_WTTime', sField_SQLServer_Now, sfVal),
              SF('L_WTMan', FIn.FBase.FFrom.FUser),
              SF('L_WTLine', FMemo)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL);
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFM then //称量毛重
  begin
    SortBillItemsByValue(nBills);
    //从小到大排序

    nInt := -1;
    nMVal := 0;
    for nIdx:=Low(nBills) to High(nBills) do
    if nBills[nIdx].FPoundID = sFlag_Yes then
    begin
      nMVal := nBills[nIdx].FMData.FValue;
      nInt := nIdx;
      Break;
    end;

    if nInt < 0 then
    begin
      nData := '岗位[ %s ]提交的毛重数据为0.';
      nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
      Exit;
    end;

    nNet := nMVal - nBills[nInt].FPData.FValue;
    //车辆净重

    //销售固定卡，在二次过磅时，自动选择可用订单
    if nBills[nInt].FCardUse = sFlag_SaleNew then
    begin
      {$IFDEF LinkSaleOrder}
      for nIdx:=Low(nBills) to High(nBills) do
      if not LinkToNCSystemBySaleOrder(nData, nBills[nIdx]) then
        Exit;
      {$ELSE}
      for nIdx:=Low(nBills) to High(nBills) do
      if not LinkToNCSystem(nData, nBills[nIdx]) then
        Exit;
      {$ENDIF}
    end else

    if nBills[nInt].FType = sFlag_San then
    begin
      nVal := 0;
      for nIdx:=Low(nBills) to High(nBills) do
        nVal := nBills[nIdx].FValue + nVal;
      //开票量

      nVal := nVal - nNet;
      //调整量

      if nVal>0 then
      for nIdx:=High(nBills) downto Low(nBills) do
      with nBills[nIdx] do
      begin
        if FValue > nVal then
             nDec := nVal
        else nDec := FValue;

        if nDec <= 0 then Continue;
        //已处理完
        nVal := nVal - nDec;

        nSQL := 'Update %s Set B_Freeze=B_Freeze-%.2f Where B_ID=''%s''';
        nSQL := Format(nSQL, [sTable_Order, nDec, FZhiKa]);
        FListA.Add(nSQL);

        {$IFDEF AutoGetLineGroup}
        nSQL := 'Update %s Set B_HasUse=B_HasUse-(%.2f),B_LastDate=%s ' +
                'Where B_Batcode=''%s'' and B_Type=''%s'' and B_LineGroup=''%s''';
        nSQL := Format(nSQL, [sTable_Batcode, nDec,
                sField_SQLServer_Now, FSeal, sFlag_TypeCommon, FLineGroup]);
        FListA.Add(nSQL); //更新批次号使用量
        {$ELSE}
        nSQL := 'Update %s Set B_HasUse=B_HasUse-(%.2f),B_LastDate=%s ' +
                'Where B_Batcode=''%s'' ';
        nSQL := Format(nSQL, [sTable_Batcode, nDec,
                sField_SQLServer_Now, FSeal]);
        FListA.Add(nSQL); //更新批次号使用量
        {$ENDIF}

        nSQL := 'Update %s Set D_Sent=D_Sent-(%.2f) Where D_ID=''%s''';
        nSQL := Format(nSQL, [sTable_BatcodeDoc, nDec, FSeal]);
        FListA.Add(nSQL); //更新批次号使用量
      end;
    end;
    //AjustSanValue;

    nVal := 0;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      if nIdx < High(nBills) then
      begin
         if nNet < FValue then
              nDec := nNet
         else nDec := FValue;

        FMData.FValue := FPData.FValue + nDec;
        nVal := nVal + nDec;
        nNet := nNet - nDec;
        //累计净重

        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', nBills[nInt].FMData.FStation)
                ], sTable_PoundLog, SF('P_Bill', FID), False);
        FListA.Add(nSQL);
      end else
      begin
        FMData.FValue := nMVal - nVal;
        //扣减已累计的净重

        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', nBills[nInt].FMData.FStation)
                ], sTable_PoundLog, SF('P_Bill', FID), False);
        FListA.Add(nSQL);
      end;
    end;

    FListB.Clear;
    if nBills[nInt].FPModel <> sFlag_PoundCC then //出厂模式,毛重不生效
    begin  
      nSQL := 'Select L_ID From %s Where L_Card=''%s'' And L_MValue Is Null';
      nSQL := Format(nSQL, [sTable_Bill, nBills[nInt].FCard]);
      //未称毛重记录

      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if RecordCount > 0 then
      begin
        First;

        while not Eof do
        begin
          FListB.Add(Fields[0].AsString);
          Next;
        end;
      end;
    end;

    nTotal := 0;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      if nBills[nInt].FPModel = sFlag_PoundCC then Continue;
      //出厂模式,不更新状态

      i := FListB.IndexOf(FID);
      if i >= 0 then
        FListB.Delete(i);
      //排除本次称重

      if FloatRelation(FMData.FValue, FPData.FValue, rtLE, cPrecision) then
        FMData.FValue := FPData.FValue;
      //毛重不能小与皮重

      if FType = sFlag_San then
           nVal:=FMData.FValue-FPData.FValue
      else nVal:=FValue;

      nTotal := nTotal + nVal;
      //发货总量

      nSQL := MakeSQLByStr([SF('L_Value', nVal, sfVal),
              SF('L_Status', sFlag_TruckBFM),
              SF('L_NextStatus', sFlag_TruckOut),
              SF('L_MValue', FMData.FValue , sfVal),
              SF('L_MDate', sField_SQLServer_Now, sfVal),
              SF('L_MMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('T_LastTime',sField_SQLServer_Now, sfVal)
              ], sTable_Truck, SF('T_Truck', FTruck), False);
      FListA.Add(nSQL);
      //更新车辆活动时间
    end;

    if FListB.Count > 0 then
    begin
      nTmp := AdjustListStrFormat2(FListB, '''', True, ',', False);
      //未过重交货单列表

      nStr := Format('L_ID In (%s)', [nTmp]);
      nSQL := MakeSQLByStr([
              SF('L_PValue', nMVal, sfVal),
              SF('L_PDate', sField_SQLServer_Now, sfVal),
              SF('L_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, nStr, False);
      FListA.Add(nSQL);
      //没有称毛重的提货记录的皮重,等于本次的毛重

      nStr := Format('P_Bill In (%s)', [nTmp]);
      nSQL := MakeSQLByStr([
              SF('P_PValue', nMVal, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_PStation', nBills[nInt].FMData.FStation)
              ], sTable_PoundLog, nStr, False);
      FListA.Add(nSQL);
      //没有称毛重的过磅记录的皮重,等于本次的毛重
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      if FYSValid <> sFlag_Yes then Continue;
      //非空车出厂模式

      nSQL := MakeSQLByStr([SF('L_Value', 0, sfVal)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL);
    end;

    nSQL := 'Select P_ID From %s Where P_Bill=''%s'' And P_MValue Is Null';
    nSQL := Format(nSQL, [sTable_PoundLog, nBills[nInt].FID]);
    //未称毛重记录

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      FOut.FData := Fields[0].AsString;
    end;
    //返回榜单号,用于拍照绑定
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckOut then
  begin
    FListB.Clear;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FListB.Add(FID);
      //交货单列表

      nSQL := MakeSQLByStr([SF('L_Status', sFlag_TruckOut),
              SF('L_NextStatus', ''),
              SF('L_Card', ''),
              SF('L_OutFact', sField_SQLServer_Now, sfVal),
              SF('L_OutMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL); //更新交货单

      if not nDaiQuickSync then
      begin
        nSQL := 'Update %s Set B_HasDone=B_HasDone+(%.2f),' +
                'B_Freeze=B_Freeze-(%.2f) Where B_ID=''%s''';
        nSQL := Format(nSQL, [sTable_Order, FValue, FValue, FZhiKa]);
        FListA.Add(nSQL);
      end; //更新订单

      //if FPrintHY then
      begin
        FListC.Values['Group'] :=sFlag_BusGroup;
        FListC.Values['Object'] := sFlag_HYDan;
        //to get serial no

        if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
          raise Exception.Create(nOut.FData);
        //xxxxx

        nSQL := MakeSQLByStr([SF('H_No', nOut.FData),
                SF('H_Custom', FCusID),
                SF('H_CusName', FCusName),
                SF('H_SerialNo', FHYDan),
                SF('H_Truck', FTruck),
                SF('H_Value', FValue, sfVal),
                SF('H_Bill', FID),
                SF('H_BillDate', sField_SQLServer_Now, sfVal),
                SF('H_ReportDate', sField_SQLServer_Now, sfVal),
                //SF('H_EachTruck', sFlag_Yes),
                SF('H_Reporter', 'NFDelivery')], sTable_StockHuaYan, '', True);
        FListA.Add(nSQL); //自动生成化验单
      end;
    end;

    {$IFNDEF SyncDataByBFM}
    {$IFNDEF DaiSyncByZT}
    {$IFNDEF SyncSanByBFM}
    if not nDaiQuickSync then
     if not TWorkerBusinessCommander.CallMe(cBC_SyncME25,
          FListB.Text, '', @nOut) then
      raise Exception.Create(nOut.FData);
    //同步销售到NC榜单
    {$ENDIF}
    {$ENDIF}
    {$ENDIF}
    if nBills[0].FCardUse = sFlag_Sale then
    begin
      nSQL := 'Update %s Set C_Status=''%s'' Where C_Card=''%s''';
      nSQL := Format(nSQL, [sTable_Card, sFlag_CardIdle, nBills[0].FCard]);
      FListA.Add(nSQL);
    end else
    if nBills[0].FCardUse = sFlag_SaleNew then
    begin
      nSQL := 'Update %s Set B_IsUsed=''%s'', B_LID=NULL Where B_Card=''%s''';
      nSQL := Format(nSQL, [sTable_BillNew, sFlag_No, nBills[0].FCard]);
      FListA.Add(nSQL);
    end;    
    //销售临时卡,更新磁卡状态

    nStr := AdjustListStrFormat2(FListB, '''', True, ',', False);
    //交货单列表

    nSQL := 'Select T_Line,Z_Name as T_Name,T_Bill,T_PeerWeight,T_Total,' +
            {$IFDEF LineGroup}
            'Z_Group As T_Group, ' +
            {$ENDIF}
            'T_Normal,T_BuCha,T_HKBills From %s ' +
            ' Left Join %s On Z_ID = T_Line ' +
            'Where T_Bill In (%s)';
    nSQL := Format(nSQL, [sTable_ZTTrucks, sTable_ZTLines, nStr]);

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    begin
      SetLength(FBillLines, RecordCount);
      //init

      if RecordCount > 0 then
      begin
        nIdx := 0;
        First;

        while not Eof do
        begin
          with FBillLines[nIdx] do
          begin
            FBill    := FieldByName('T_Bill').AsString;
            FLine    := FieldByName('T_Line').AsString;
            FName    := FieldByName('T_Name').AsString;
            FPerW    := FieldByName('T_PeerWeight').AsInteger;
            FTotal   := FieldByName('T_Total').AsInteger;
            FNormal  := FieldByName('T_Normal').AsInteger;
            FBuCha   := FieldByName('T_BuCha').AsInteger;
            FHKBills := FieldByName('T_HKBills').AsString;
            {$IFDEF LineGroup}
            FLineGroup := FieldByName('T_Group').AsString;
            {$ENDIF}
          end;

          Inc(nIdx);
          Next;
        end;
      end;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      nInt := -1;
      for i:=Low(FBillLines) to High(FBillLines) do
       if (Pos(FID, FBillLines[i].FHKBills) > 0) and
          (FID <> FBillLines[i].FBill) then
       begin
          nInt := i;
          Break;
       end;
      //合卡,但非主单

      if nInt < 0 then Continue;
      //检索装车信息

      with FBillLines[nInt] do
      begin
        if FPerW < 1 then Continue;
        //袋重无效

        i := Trunc(FValue * 1000 / FPerW);
        //袋数

        nSQL := MakeSQLByStr([SF('L_LadeLine', FLine),
                SF('L_LineName', FName),
                {$IFDEF LineGroup}
                SF('L_LineGroup', FLineGroup),
                {$ENDIF}
                SF('L_DaiTotal', i, sfVal),
                SF('L_DaiNormal', i, sfVal),
                SF('L_DaiBuCha', 0, sfVal)
                ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL); //更新装车信息

        FTotal := FTotal - i;
        FNormal := FNormal - i;
        //扣减合卡副单的装车量
      end;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      nInt := -1;
      for i:=Low(FBillLines) to High(FBillLines) do
       if FID = FBillLines[i].FBill then
       begin
          nInt := i;
          Break;
       end;
      //合卡主单

      if nInt < 0 then Continue;
      //检索装车信息

      with FBillLines[nInt] do
      begin
        nSQL := MakeSQLByStr([SF('L_LadeLine', FLine),
                SF('L_LineName', FName),
                {$IFDEF LineGroup}
                SF('L_LineGroup', FLineGroup),
                {$ENDIF}
                SF('L_DaiTotal', FTotal, sfVal),
                SF('L_DaiNormal', FNormal, sfVal),
                SF('L_DaiBuCha', FBuCha, sfVal)
                ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL); //更新装车信息
      end;
    end;

    nSQL := 'Delete From %s Where T_Bill In (%s)';
    nSQL := Format(nSQL, [sTable_ZTTrucks, nStr]);
    FListA.Add(nSQL); //清理装车队列

    FListC.Clear;
    FListC.Values['DLEncode'] := sFlag_No;
    FListC.Values['DLID']  := nStr;
    FListC.Values['MType'] := sFlag_Sale;
    FListC.Values['BillType'] := IntToStr(cMsg_WebChat_BillFinished);
    TWorkerBusinessCommander.CallMe(cBC_WebChat_DLSaveShopInfo,
     PackerEncodeStr(FListC.Text), '', @nOut);
    //保存同步信息
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    //xxxxx

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;

  if FIn.FExtParam = sFlag_TruckBFM then
  begin
    if Assigned(gHardShareData) then
      gHardShareData('TruckOut:' + nBills[0].FCard);
    //单次过磅自动出厂
  end;

  {$IFDEF SyncDataByBFM}
  if FIn.FExtParam = sFlag_TruckBFM then
  begin
    FListB.Clear;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FListB.Add(FID);
      //交货单列表
    end;

    if not nDaiQuickSync then
      TWorkerBusinessCommander.CallMe(cBC_SyncME25,
          FListB.Text, '', @nOut);
    //同步销售到NC榜单
  end;
  {$ENDIF}

  {$IFDEF DaiSyncByZT}//与DayQuickSync互斥
  if FIn.FExtParam = sFlag_TruckZT then
  begin
    FListB.Clear;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FListB.Add(FID);
      //交货单列表
    end;

    if not nDaiQuickSync then
      TWorkerBusinessCommander.CallMe(cBC_SyncME25,
          FListB.Text, '', @nOut);
    //同步销售到NC榜单
  end;
  {$ENDIF}

  {$IFDEF SyncSanByBFM}//与SyncDataByBFM互斥
  if FIn.FExtParam = sFlag_TruckBFM then
  begin
    FListB.Clear;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FListB.Add(FID);
      //交货单列表
    end;

    if nBills[0].FType = sFlag_San then
      TWorkerBusinessCommander.CallMe(cBC_SyncME25,
          FListB.Text, '', @nOut);
    //同步销售到NC榜单
  end;
  {$ENDIF}

  {$IFDEF SyncSanByOut}//与SyncDataByBFM互斥
  if FIn.FExtParam = sFlag_TruckOut then
  begin
    FListB.Clear;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FListB.Add(FID);
      //交货单列表
    end;

    if nBills[0].FType = sFlag_San then
      TWorkerBusinessCommander.CallMe(cBC_SyncME25,
          FListB.Text, '', @nOut);
    //同步销售到NC榜单
  end;
  {$ENDIF}
end;

function TWorkerBusinessBills.LinkToNCSystem(var nData: string;
  nBill: TLadingBillItem): Boolean;
var nSQL: string;
    nInt, nIdx: Integer;
    nVal, nDec: Double;
    nWorker: PDBWorker;
    nOut: TWorkerBusinessCommand;
    nDs: TDataSet;
begin
  FListB.Clear;
  FListC.Clear;
  Result := False;
  //Init

  FListC.Values['NoDate'] := sFlag_Yes;
  FListC.Values['Customer'] := nBill.FCusName;
  FListC.Values['StockNo'] := nBill.FStockNo;
  FListC.Values['Order']   := 'TMAKETIME DESC';

  if not TWorkerBusinessCommander.CallMe(cBC_GetSQLQueryDispatch, '',
         PackerEncodeStr(FListC.Text), @nOut) then
  begin
    nData := '获取读NC调拨订单语句失败，条件为[ %s ]';
    nData := Format(nData, [FListC.Text]);
    Exit;
  end;

  nWorker := nil;
  try
    nDs := gDBConnManager.SQLQuery(nOut.FData, nWorker, sFlag_DB_NC);

    with nDs do
    begin
      if RecordCount < 1 then
      begin
        nData := '无满足如下条件的订单: ' + #13#10#13#10 +
                 '物料信息:[ %s.%s ]' + #13#10 +
                 '客户信息:[ %s.%s ]' + #13#10#13#10 +
                 '请在NC中补订单.';
        nData := Format(nData, [nBill.FStockNo, nBill.FStockName,
                 nBill.FCusID, nBill.FCusName]);
        Exit;
      end;

      if not LoadStockInfo(nData) then Exit;
      //载入物料

      SetLength(FOrderItems, RecordCount);
      nInt := 0;
      First;

      while not Eof do
      begin
        with FOrderItems[nInt] do
        begin
          FOrder := FieldByName('pk_meambill').AsString;

          FStockID := FieldByName('invcode').AsString;
          FStockName := FieldByName('invname').AsString;
          FMaxValue := FieldByName('NPLANNUM').AsFloat;
          FKDValue := 0;

          FSaleID := '001';
          FSaleName := FieldByName('VBILLTYPE').AsString;

          nIdx := GetStockInfo(FStockID);
          if nIdx < 0 then
          begin
            nData := '品种[ %s ]在字典中的信息丢失.';
            nData := Format(nData, [FStockName]);
            Exit;
          end else

          begin
            FStockType := FStockInfo[nIdx].FType;
            FPackStyle := FStockInfo[nIdx].FPackStyle;
          end;

          FListB.Add(FOrder);
        end;

        Inc(nInt);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;

  //----------------------------------------------------------------------------
  if not TWorkerBusinessCommander.CallMe(cBC_GetOrderFHValue,
         PackerEncodeStr(FListB.Text), '', @nOut) then
  begin
    nSQL := StringReplace(FListB.Text, #13#10, ',', [rfReplaceAll]);
    nData := Format('获取[ %s ]订单发货量失败', [nSQL]);
    Exit;
  end;

  FListC.Text := PackerDecodeStr(nOut.FData);
  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  begin
    nSQL := FListC.Values[FOrderItems[nIdx].FOrder];
    if not IsNumber(nSQL, True) then Continue;

    with FOrderItems[nIdx] do
      FMaxValue := FMaxValue - StrToFloat(nSQL);
    //可用量 = 计划量 - 已发量
  end;

  SortOrderByValue(FOrderItems);
  //按可用量由小到大排序

  //----------------------------------------------------------------------------
  if nBill.FType = sFlag_Dai then
       nVal := nBill.FValue
  else nVal := nBill.FMData.FValue - nBill.FPData.FValue;

  if nVal <= 0 then
  begin
    nData := '调拨单[ %s ]提交的数据出错.';
    nData := Format(nData, [nBill.FID]);
    Exit;
  end;

  {$IFDEF BatchVerifyValue}
  FListD.Clear;
  FListD.Values['Value'] := FloatToStr(nVal);
  FListD.Values['LineGroup'] := nBill.FLineGroup;

  if not TWorkerBusinessCommander.CallMe(cBC_GetStockBatcode,
      nBill.FStockNo, PackerEncodeStr(FListD.Text), @nOut) then
  begin
    nData := '获取读NC订单语句失败，错误信息为[ %s ]';
    nData := Format(nData, [nOut.FData]);
    Exit;
  end;

  nSQL := 'Update %s Set B_HasUse=B_HasUse+(%s),B_LastDate=%s ' +
          'Where B_Stock=''%s'' and B_Batcode=''%s''';
  nSQL := Format(nSQL, [sTable_Batcode, FloatToStr(nVal),
          sField_SQLServer_Now, nBill.FStockNo, nOut.FData]);
  FListA.Add(nSQL);//更新批次号使用量

  nSQL := MakeSQLByStr([
            SF('L_Seal', nOut.FData)
            ], sTable_Bill, SF('L_ID', nBill.FID), False);
    FListA.Add(nSQL);
  {$ENDIF}

  nInt := -1;
  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  begin
    nDec := Float2Float(FOrderItems[nIdx].FMaxValue, cPrecision, False);
    //订单可用量

    if nDec >= nVal then
    begin
      FOrderItems[nIdx].FKDValue := nVal;
      nInt := nIdx;
      Break;
    end;
    //订单够用则直接扣除开单量
  end;

  if nInt < 0 then
  begin
    nData := '当前无可用订单，请重新开单.';
    nData := Format(nData, [nVal]);
    Exit;
  end;

  with FOrderItems[nInt] do
  begin
    nSQL := MakeSQLByStr([
            SF('L_ZhiKa', FOrder),
            SF('L_CusCode', FCusCode),
            SF('L_SaleID', FSaleID),
            SF('L_SaleMan', FSaleName),
            SF('L_Area', FAreaTo)
            ], sTable_Bill, SF('L_ID', nBill.FID), False);
    FListA.Add(nSQL);
    WriteLog('调拨固定卡更新提货单SQL:' + nSQL);
    
    nSQL := 'Select * From %s Where B_ID=''%s''';
    nSQL := Format(nSQL, [sTable_Order, FOrder]);
    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount < 1 then
    begin
      nSQL := MakeSQLByStr([SF('B_ID', FOrder),SF('B_Freeze', FKDValue, sfVal)
              ], sTable_Order, '', True);
    end else

    begin
      nSQL := 'Update %s Set B_Freeze=B_Freeze+%.2f Where B_ID=''%s''';
      nSQL := Format(nSQL, [sTable_Order, FKDValue, FOrder])
    end;

    FListA.Add(nSQL);
  end;

  Result := True;
end;

function TWorkerBusinessBills.LinkToNCSystemBySaleOrder(var nData: string;
  nBill: TLadingBillItem): Boolean;
var nSQL: string;
    nInt, nIdx: Integer;
    nVal, nDec: Double;
    nWorker: PDBWorker;
    nOut: TWorkerBusinessCommand;
    nDs: TDataSet;
begin
  FListB.Clear;
  FListC.Clear;
  Result := False;
  //Init

  FListC.Values['NoDate'] := sFlag_Yes;
  FListC.Values['Customer'] := nBill.FCusName;
  FListC.Values['StockNo'] := nBill.FStockNo;
  FListC.Values['Order']   := 'TMAKETIME DESC';
  WriteLog('销售固定卡查询订单入参:' + FListC.Text);
  if not TWorkerBusinessCommander.CallMe(cBC_GetSQLQueryOrder, '103',
         PackerEncodeStr(FListC.Text), @nOut) then
  begin
    nData := '获取读NC销售订单语句失败，条件为[ %s ]';
    nData := Format(nData, [FListC.Text]);
    Exit;
  end;

  nWorker := nil;
  try
    nDs := gDBConnManager.SQLQuery(nOut.FData, nWorker, sFlag_DB_NC);

    with nDs do
    begin
      if RecordCount < 1 then
      begin
        nData := '无满足如下条件的销售订单: ' + #13#10#13#10 +
                 '物料信息:[ %s.%s ]' + #13#10 +
                 '客户信息:[ %s.%s ]' + #13#10#13#10 +
                 '请在NC中补订单.';
        nData := Format(nData, [nBill.FStockNo, nBill.FStockName,
                 nBill.FCusID, nBill.FCusName]);
        Exit;
      end;

      if not LoadStockInfo(nData) then Exit;
      //载入物料

      SetLength(FOrderItems, RecordCount);
      nInt := 0;
      First;

      while not Eof do
      begin
        with FOrderItems[nInt] do
        begin
          FOrder := FieldByName('pk_meambill').AsString;

          FStockID := FieldByName('invcode').AsString;
          FStockName := FieldByName('invname').AsString;
          FMaxValue := FieldByName('NPLANNUM').AsFloat;
          FKDValue := 0;

          FSaleID := '001';
          FSaleName := FieldByName('VBILLTYPE').AsString;

          nIdx := GetStockInfo(FStockID);
          if nIdx < 0 then
          begin
            nData := '品种[ %s ]在字典中的信息丢失.';
            nData := Format(nData, [FStockName]);
            Exit;
          end else

          begin
            FStockType := FStockInfo[nIdx].FType;
            FPackStyle := FStockInfo[nIdx].FPackStyle;
          end;

          FListB.Add(FOrder);
        end;

        Inc(nInt);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;

  //----------------------------------------------------------------------------
  if not TWorkerBusinessCommander.CallMe(cBC_GetOrderFHValue,
         PackerEncodeStr(FListB.Text), '', @nOut) then
  begin
    nSQL := StringReplace(FListB.Text, #13#10, ',', [rfReplaceAll]);
    nData := Format('获取[ %s ]订单发货量失败', [nSQL]);
    Exit;
  end;

  FListC.Text := PackerDecodeStr(nOut.FData);
  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  begin
    nSQL := FListC.Values[FOrderItems[nIdx].FOrder];
    if not IsNumber(nSQL, True) then Continue;

    with FOrderItems[nIdx] do
      FMaxValue := FMaxValue - StrToFloat(nSQL);
    //可用量 = 计划量 - 已发量
  end;

  SortOrderByValue(FOrderItems);
  //按可用量由小到大排序

  //----------------------------------------------------------------------------
  if nBill.FType = sFlag_Dai then
       nVal := nBill.FValue
  else nVal := nBill.FMData.FValue - nBill.FPData.FValue;

  if nVal <= 0 then
  begin
    nData := '提货单[ %s ]提交的数据出错.';
    nData := Format(nData, [nBill.FID]);
    Exit;
  end;

  {$IFDEF BatchVerifyValue}
  FListD.Clear;
  FListD.Values['Value'] := FloatToStr(nVal);
  FListD.Values['LineGroup'] := nBill.FLineGroup;

  if not TWorkerBusinessCommander.CallMe(cBC_GetStockBatcode,
      nBill.FStockNo, PackerEncodeStr(FListD.Text), @nOut) then
  begin
    nData := '获取读NC订单语句失败，错误信息为[ %s ]';
    nData := Format(nData, [nOut.FData]);
    Exit;
  end;

  nSQL := 'Update %s Set B_HasUse=B_HasUse+(%s),B_LastDate=%s ' +
          'Where B_Stock=''%s'' and B_Batcode=''%s''';
  nSQL := Format(nSQL, [sTable_Batcode, FloatToStr(nVal),
          sField_SQLServer_Now, nBill.FStockNo, nOut.FData]);
  FListA.Add(nSQL);//更新批次号使用量

  nSQL := MakeSQLByStr([
            SF('L_Seal', nOut.FData)
            ], sTable_Bill, SF('L_ID', nBill.FID), False);
    FListA.Add(nSQL);
  {$ENDIF}

  nInt := -1;
  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  begin
    nDec := Float2Float(FOrderItems[nIdx].FMaxValue, cPrecision, False);
    //订单可用量

    if nDec >= nVal then
    begin
      FOrderItems[nIdx].FKDValue := nVal;
      nInt := nIdx;
      Break;
    end;
    //订单够用则直接扣除开单量
  end;

  if nInt < 0 then
  begin
    nData := '当前无可用订单，请重新开单.';
    nData := Format(nData, [nVal]);
    Exit;
  end;

  with FOrderItems[nInt] do
  begin
    nSQL := MakeSQLByStr([
            SF('L_ZhiKa', FOrder),
            SF('L_CusCode', FCusCode),
            SF('L_SaleID', FSaleID),
            SF('L_SaleMan', FSaleName),
            SF('L_Area', FAreaTo)
            ], sTable_Bill, SF('L_ID', nBill.FID), False);
    FListA.Add(nSQL);
    WriteLog('销售订单固定卡更新提货单SQL:' + nSQL);
    
    nSQL := 'Select * From %s Where B_ID=''%s''';
    nSQL := Format(nSQL, [sTable_Order, FOrder]);
    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount < 1 then
    begin
      nSQL := MakeSQLByStr([SF('B_ID', FOrder),SF('B_Freeze', FKDValue, sfVal)
              ], sTable_Order, '', True);
    end else

    begin
      nSQL := 'Update %s Set B_Freeze=B_Freeze+%.2f Where B_ID=''%s''';
      nSQL := Format(nSQL, [sTable_Order, FKDValue, FOrder])
    end;

    FListA.Add(nSQL);
  end;

  Result := True;
end;

function TWorkerBusinessBills.SaveBillNew(var nData: string): Boolean;
var nOut: TWorkerBusinessCommand;
    nStr, nTruck: string;
    nIdx: Integer;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);
  nTruck := FListA.Values['Truck'];
  //init card

  if not LoadStockInfo(nData) then Exit;

  nIdx :=  GetStockInfo(FListA.Values['StockNO']);

  if nIdx < 0 then
  begin
    nData := '品种[ %s ]在字典中的信息丢失.';
    nData := Format(nData, [FListA.Values['StockName']]);
    Exit;
  end else

  begin
    FListA.Values['Type'] := FStockInfo[nIdx].FType;
    if FListA.Values['Pack'] = '' then
      FListA.Values['Pack'] := FStockInfo[nIdx].FPackStyle;
  end;

  TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, nTruck, '', @nOut);
  //保存车牌号

  FDBConn.FConn.BeginTrans;
  try
    FListC.Clear;
    FListC.Values['Group'] :=sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_BillNewNO;
    //to get serial no

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
          FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    nStr := MakeSQLByStr([
            SF('B_ID', nOut.FData),

            SF('B_CusID', FListA.Values['CusID']),       //NC客户ID
            SF('B_CusName', FListA.Values['CusName']),   //NC客户名称
            SF('B_CusPY', GetPinYinOfStr(FListA.Values['CusName'])),

            SF('B_SaleID', FListA.Values['SaleID']),     //NC业务员ID
            SF('B_SaleMan', FListA.Values['SaleName']), //NC业务员名称
            SF('B_SalePY', GetPinYinOfStr(FListA.Values['SaleName'])),

            SF('B_Type', FListA.Values['Type']),
            SF('B_StockNo', FListA.Values['StockNo']),
            SF('B_StockName', FListA.Values['StockName']),

            SF('B_IsVip', FListA.Values['IsVip']),
            SF('B_Lading', FListA.Values['Lading']),
            SF('B_PackStyle', FListA.Values['Pack']),

            SF('B_Truck', nTruck),
            SF('B_IsUsed', sFlag_No),
            SF('B_Value', StrToFloatDef(FListA.Values['Value'],50), sfVal),
            //默认50吨

            SF('B_Man', FIn.FBase.FFrom.FUser),
            SF('B_Date', sField_SQLServer_Now, sfVal)
            ], sTable_BillNew, '', True);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;

    FOut.FData := nOut.FData;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;


//Date: 2015/9/19
//Parm:
//Desc: 删除采购入厂申请单
function TWorkerBusinessBills.DeleteBillNew(var nData: string): Boolean;
var nStr,nP: string;
    nIdx: Integer;
begin
  Result := False;
  //init

  nStr := 'Select Count(*) From %s Where L_Memo=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if Fields[0].AsInteger > 0 then
    begin
      nData := '订单[ %s ]已使用，禁止删除.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
  end;

  FDBConn.FConn.BeginTrans;
  try
    //--------------------------------------------------------------------------
    nStr := Format('Select * From %s Where 1<>1', [sTable_BillNew]);
    //only for fields
    nP := '';

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      for nIdx:=0 to FieldCount - 1 do
       if (Fields[nIdx].DataType <> ftAutoInc) and
          (Pos('B_Del', Fields[nIdx].FieldName) < 1) then
        nP := nP + Fields[nIdx].FieldName + ',';
      //所有字段,不包括删除

      System.Delete(nP, Length(nP), 1);
    end;

    nStr := 'Insert Into $OB($FL,B_DelMan,B_DelDate) ' +
            'Select $FL,''$User'',$Now From $OO Where B_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$OB', sTable_BillNewBak),
            MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
            MI('$Now', sField_SQLServer_Now),
            MI('$OO', sTable_BillNew), MI('$ID', FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Delete From %s Where B_ID=''%s''';
    nStr := Format(nStr, [sTable_BillNew, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

function TWorkerBusinessBills.SaveBillNewCard(var nData: string): Boolean;
var nSQL, nTruck: string;
    nIdx: Integer;
begin
  Result := False;
  //init card

  nSQL := 'Select B_Card,B_Truck From %s Where B_ID=''%s''';
  nSQL := Format(nSQL, [sTable_BillNew, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := '销售单据[ %s ]已丢失.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    FListC.Clear;
    nTruck := Fields[1].AsString;
    
    if Fields[0].AsString <> '' then
    begin
      nSQL := 'Update %s set C_TruckNo=Null,C_Status=''%s'' Where C_Card=''%s''';
      nSQL := Format(nSQL, [sTable_Card, sFlag_CardIdle, Fields[0].AsString]);
      FListC.Add(nSQL); //磁卡状态
    end;
  end;

  nSQL := 'Update %s Set P_Card=NULL, P_CType=NULL Where P_Card=''%s''';
  nSQL := Format(nSQL, [sTable_ProvBase, FIn.FExtParam]);
  FListC.Add(nSQL);
  //注销正在使用该卡的原材料

  nSQL := 'Update %s Set B_Card=NULL, B_CardSerial=NULL Where B_Card=''%s''';
  nSQL := Format(nSQL, [sTable_BillNew, FIn.FExtParam]);
  FListC.Add(nSQL);
  //注销正在使用该卡的销售订单

  nSQL := 'Update %s Set L_Card=NULL Where L_Card=''%s''';
  nSQL := Format(nSQL, [sTable_Bill, FIn.FExtParam]);
  FListC.Add(nSQL);
  //注销正在使用该卡的交货单

  nSQL := MakeSQLByStr([
          SF('B_Card', FIn.FExtParam)
          ], sTable_BillNew, SF('B_ID', FIn.FData), False);
  FListC.Add(nSQL);
  //更新磁卡

  nSQL := 'Update %s Set L_Card=''%s'' Where L_Memo =''%s'' And L_OutFact Is NULL';
  nSQL := Format(nSQL, [sTable_Bill,
          FIn.FExtParam, FIn.FData]);
  FListC.Add(nSQL);
  //更新未出厂明细磁卡

  nSQL := 'Select Count(*) From %s Where C_Card=''%s''';
  nSQL := Format(nSQL, [sTable_Card, FIn.FExtParam]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if Fields[0].AsInteger < 1 then
  begin
    nSQL := MakeSQLByStr([SF('C_Card', FIn.FExtParam),
            SF('C_Status', sFlag_CardUsed),
            SF('C_Group', sFlag_ProvCardG),
            SF('C_Used', sFlag_SaleNew),
            SF('C_Freeze', sFlag_No),

            SF('C_TruckNo', nTruck),
            SF('C_Man', FIn.FBase.FFrom.FUser),
            SF('C_Date', sField_SQLServer_Now, sfVal)
            ], sTable_Card, '', True);
    FListC.Add(nSQL);
  end else
  begin
    nSQL := Format('C_Card=''%s''', [FIn.FExtParam]);
    nSQL := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
            SF('C_Group', sFlag_ProvCardG),
            SF('C_Used', sFlag_SaleNew),
            SF('C_Freeze', sFlag_No),
            SF('C_TruckNo', nTruck),
            SF('C_Man', FIn.FBase.FFrom.FUser),
            SF('C_Date', sField_SQLServer_Now, sfVal)
            ], sTable_Card, nSQL, False);
    FListC.Add(nSQL);
  end;
  //更新磁卡状态

  FDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListC.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListC[nIdx]);
    //xxxxx

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    on E: Exception do
    begin
      FDBConn.FConn.RollbackTrans;
      nData := E.Message;
    end;
  end;
end;

function TWorkerBusinessBills.SaveBillFromNew(var nData: string): Boolean;
var nIdx,nInt: Integer;
    nStr,nSQL, nTruck: string;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  //Init

  nSQL := 'Select * From %s Where B_ID=''%s''';
  nSQL := Format(nSQL, [sTable_BillNew, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := '销售订单[ %s ]信息已丢失.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    if FieldByName('B_IsUsed').AsString = sFlag_Yes then
    begin
      nData := '销售订单[ %s ]信息正在被[ %s ]使用.';
      nData := Format(nData, [FIn.FData, FieldByName('B_LID').AsString]);
      Exit;
    end;

    with FListA do
    begin
      Clear;

      Values['BID']   := FieldByName('B_ID').AsString;
      Values['CusID'] := FieldByName('B_CusID').AsString;
      Values['CusName'] := FieldByName('B_CusName').AsString;
      Values['CusCode'] := FieldByName('B_CusCode').AsString;

      Values['SaleID'] := FieldByName('B_SaleID').AsString;
      Values['SaleMan'] := FieldByName('B_SaleMan').AsString;

      Values['Type'] := FieldByName('B_Type').AsString;
      Values['StockNO'] := FieldByName('B_StockNO').AsString;
      Values['StockName'] := FieldByName('B_StockName').AsString;

      Values['Pack'] := FieldByName('B_PackStyle').AsString;
      Values['Lading'] := FieldByName('B_Lading').AsString;
      Values['IsVIP'] := FieldByName('B_IsVIP').AsString;

      Values['Value'] := FieldByName('B_Value').AsString;
      Values['Truck'] := FieldByName('B_Truck').AsString;
      Values['Card']  := FieldByName('B_Card').AsString;
    end;
  end;

  //----------------------------------------------------------------------------
  SetLength(FStockItems, 0);
  SetLength(FMatchItems, 0);
  //init

  nTruck := FListA.Values['Truck'];
  FSanMultiBill := AllowedSanMultiBill;
  //散装允许开多单
  
  nStr := 'Select M_ID,M_Group From %s Where M_Status=''%s'' ';
  nStr := Format(nStr, [sTable_StockMatch, sFlag_Yes]);
  //品种分组匹配

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    SetLength(FStockItems, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    begin
      FStockItems[nIdx].FStock := Fields[0].AsString;
      FStockItems[nIdx].FGroup := Fields[1].AsString;

      Inc(nIdx);
      Next;
    end;
  end;

  nStr := 'Select R_ID,T_Bill,T_StockNo,T_Type,T_InFact,T_Valid From %s ' +
          'Where T_Truck=''%s'' ';
  nStr := Format(nStr, [sTable_ZTTrucks, nTruck]);
  //还在队列中车辆

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    SetLength(FMatchItems, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    begin
      if (FieldByName('T_Type').AsString = sFlag_San) and (not FSanMultiBill) then
      begin
        nStr := '车辆[ %s ]在未完成[ %s ]交货单之前禁止开单.';
        nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
        Exit;
      end else

      if (FieldByName('T_Type').AsString = sFlag_Dai) and
         (FieldByName('T_InFact').AsString <> '') then
      begin
        nStr := '车辆[ %s ]在未完成[ %s ]交货单之前禁止开单.';
        nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
        Exit;
      end else

      if FieldByName('T_Valid').AsString = sFlag_No then
      begin
        nStr := '车辆[ %s ]有已出队的交货单[ %s ],需先处理.';
        nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
        Exit;
      end; 

      with FMatchItems[nIdx] do
      begin
        FStock := FieldByName('T_StockNo').AsString;
        FGroup := GetStockGroup(FStock, nInt);

        FPriority := nInt;
        FRecord := FieldByName('R_ID').AsString;
      end;

      Inc(nIdx);
      Next;
    end;
  end;

  FDBConn.FConn.BeginTrans;
  try
    FOut.FData := '';
    //bill list

    FListC.Clear;
    FListC.Values['Group'] :=sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_BillNo;
    //to get serial no

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
          FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := FOut.FData + nOut.FData + ',';
    //combine bill

    nStr := MakeSQLByStr([SF('L_ID', nOut.FData),
            SF('L_CusID', FListA.Values['CusID']),
            SF('L_CusName', FListA.Values['CusName']),
            SF('L_CusPY', GetPinYinOfStr(FListA.Values['CusName'])),
            SF('L_CusCode', FListA.Values['CusCode']),
            SF('L_SaleID', FListA.Values['SaleID']),
            SF('L_SaleMan', FListA.Values['SaleMan']),

            SF('L_Type', FListA.Values['Type']),
            SF('L_StockNo', FListA.Values['StockNO']),
            SF('L_StockName', FListA.Values['StockName']),

            SF('L_Price', 0, sfVal),
            SF('L_Card', FListA.Values['Card']),
            SF('L_PackStyle', FListA.Values['Pack']),
            SF('L_Value', StrToFloat(FListA.Values['Value']), sfVal), 

            SF('L_Truck', FListA.Values['Truck']),
            SF('L_Status', sFlag_BillNew),
            SF('L_Lading', FListA.Values['Lading']),
            SF('L_IsVIP', FListA.Values['IsVIP']),
            SF('L_Man', FIn.FBase.FFrom.FUser),
            SF('L_Memo', FListA.Values['BID']),
            SF('L_Date', sField_SQLServer_Now, sfVal)
            ], sTable_Bill, '', True);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nSQL := 'Update %s Set B_IsUsed=''%s'', B_LID=''%s'' Where B_ID=''%s''';
    nSQL := Format(nSQL, [sTable_BillNew, sFlag_Yes, nOut.FData, FListA.Values['BID']]);
    gDBConnManager.WorkerExec(FDBConn, nSQL);

    //更新销售订单状态

    nStr := FListA.Values['StockNO'];
    nStr := GetMatchRecord(nStr);
    //该品种在装车队列中的记录号

    if nStr <> '' then
    begin
      nSQL := 'Update $TK Set T_Value=T_Value + $Val,' +
              'T_HKBills=T_HKBills+''$BL.'' Where R_ID=$RD';
      nSQL := MacroValue(nSQL, [MI('$TK', sTable_ZTTrucks),
              MI('$RD', nStr),
              MI('$Val', FListA.Values['Value']),
              MI('$BL', nOut.FData)]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end else
    begin
      nSQL := MakeSQLByStr([
        SF('T_Truck'   , FListA.Values['Truck']),
        SF('T_StockNo' , FListA.Values['StockNO']),
        SF('T_Stock'   , FListA.Values['StockName']),
        SF('T_Type'    , FListA.Values['Type']),
        SF('T_InTime'  , sField_SQLServer_Now, sfVal),
        SF('T_Bill'    , nOut.FData),
        SF('T_Valid'   , sFlag_Yes),
        SF('T_Value'   , StrToFloat(FListA.Values['Value']), sfVal),
        SF('T_VIP'     , FListA.Values['IsVIP']),
        SF('T_HKBills' , nOut.FData + '.')
        ], sTable_ZTTrucks, '', True);
      gDBConnManager.WorkerExec(FDBConn, nSQL);

      nStr := 'Select Max(R_ID) From ' + sTable_ZTTrucks;
      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
        nStr := Fields[0].AsString;
      //插入记录号

      nInt := Length(FMatchItems);
      SetLength(FMatchItems, nInt + 1);
      with FMatchItems[nInt] do
      begin
        FStock := FListA.Values['StockNO'];
        FGroup := GetStockGroup(FStock, nInt);

        FPriority := nInt;
        FRecord := nStr;
      end;
    end;

    nIdx := Length(FOut.FData);
    if Copy(FOut.FData, nIdx, 1) = ',' then
      System.Delete(FOut.FData, nIdx, 1);
    //xxxxx

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessBills, sPlug_ModuleBus);
end.

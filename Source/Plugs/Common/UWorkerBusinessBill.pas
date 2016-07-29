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
  UFormCtrl, USysLoger, USysDB, {$IFDEF MicroMsg}UMgrRemoteWXMsg,{$ENDIF}
  UMITConst, UBase64;

type
  TStockInfoItem = record
    FID: string;            //编号
    FName: string;          //名称
    FType: string;          //类型
  end;

  TStockMatchItem = record
    FStock: string;         //品种
    FGroup: string;         //分组
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
  end;

  TOrderItem = record
    FOrder: string;         //订单号
    FCusID: string;         //客户号
    FCusName: string;       //客户名
    FCusCode: string;       //客户代码
    FAreaTo: string;        //区域流向
    FStockID: string;       //品种号
    FStockName: string;     //品种名
    FStockType: string;     //类型
    FSaleID: string;        //业务号
    FSaleName: string;      //业务名
    FMaxValue: Double;      //最大可用
    FKDValue: Double;       //开单量
  end;

  TOrderItems = array of TOrderItem;
  //订单列表

  TWorkerBusinessBills = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
    //io
    FSanMultiBill: Boolean;
    //散装多单
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
    function GetStockGroup(const nStock: string): string;
    function GetMatchRecord(const nStock: string): string;
    //物料分组
    function GetInBillInterval: Integer;
    function AllowedSanMultiBill: Boolean;
    function VerifyBeforSave(var nData: string): Boolean;
    function SaveBills(var nData: string): Boolean;
    //保存交货单
    function DeleteBill(var nData: string): Boolean;
    //删除交货单
    function ChangeBillTruck(var nData: string): Boolean;
    //修改车牌号
    function SaveBillCard(var nData: string): Boolean;
    //绑定磁卡
    function LogoffCard(var nData: string): Boolean;
    //注销磁卡
    function GetPostBillItems(var nData: string): Boolean;
    //获取岗位交货单
    function SavePostBillItems(var nData: string): Boolean;
    //保存岗位交货单

    function LinkToNCSystem(var nData: string; nBill: TLadingBillItem): Boolean;
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
  inherited;
end;

destructor TWorkerBusinessBills.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
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
   cBC_SaveBillCard        : Result := SaveBillCard(nData);
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
//Parm: 品种编号
//Desc: 检索nStock对应的物料分组
function TWorkerBusinessBills.GetStockGroup(const nStock: string): string;
var nIdx: Integer;
begin
  Result := '';
  //init

  for nIdx:=Low(FStockItems) to High(FStockItems) do
  if FStockItems[nIdx].FStock = nStock then
  begin
    Result := FStockItems[nIdx].FGroup;
    Exit;
  end;
end;

//Date: 2014/7/30
//Parm: 品种编号
//Desc: 检索车辆队列中与nStock同品种,或同组的记录
function TWorkerBusinessBills.GetMatchRecord(const nStock: string): string;
var nStr: string;
    nIdx: Integer;
begin
  Result := '';
  //init

  for nIdx:=Low(FMatchItems) to High(FMatchItems) do
  if FMatchItems[nIdx].FStock = nStock then
  begin
    Result := FMatchItems[nIdx].FRecord;
    Exit;
  end;

  nStr := GetStockGroup(nStock);
  if nStr = '' then Exit;  

  for nIdx:=Low(FMatchItems) to High(FMatchItems) do
  if FMatchItems[nIdx].FGroup = nStr then
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

//Date: 2015-01-09
//Desc: 车辆进厂后在指定时间内必须开单,过期无效
function TWorkerBusinessBills.GetInBillInterval: Integer;
var nStr: string;
begin
  Result := 0;
  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_InAndBill]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsInteger;
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

  nStr := 'Select D_Value,D_Memo,D_ParamB From %s Where D_Name=''%s'' ';
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

//Date: 2014-09-15
//Desc: 验证能否开单
function TWorkerBusinessBills.VerifyBeforSave(var nData: string): Boolean;
var nIdx,nInt: Integer;
    nVal,nDec: Double;
    nStr,nTruck: string;
    nWorker: PDBWorker;
    nOut: TWorkerBusinessCommand;
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
        FGroup := GetStockGroup(FStock);
        FRecord := FieldByName('R_ID').AsString;
      end;

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
          end else FStockType := FStockInfo[nIdx].FType;
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
var nStr,nSQL,nBill: string;
    nIdx,nInt: Integer;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);
  if not VerifyBeforSave(nData) then Exit;

  FDBConn.FConn.BeginTrans;
  try       
    FOut.FData := '';
    //bill list

    for nIdx:=Low(FOrderItems) to High(FOrderItems) do
    begin
      if FOrderItems[nIdx].FKDValue <= 0 then Continue;
      //无开单量

      {$IFNDEF BatchVerifyValue}
      if FOrderItems[nIdx].FStockType = sFlag_Dai then
      begin
        FListC.Clear;
        FListC.Values['Batch'] := FListA.Values['Seal'];
        FListC.Values['Brand'] := FListA.Values['Brand'];
        FListC.Values['Value'] := FloatToStr(FOrderItems[nIdx].FKDValue);

        if not TWorkerBusinessCommander.CallMe(cBC_GetStockBatcode,
            FOrderItems[nIdx].FStockID, FListC.Text, @nOut) then
        raise Exception.Create(nOut.FData);
        //获取新的批次

        FListA.Values['Seal'] := nOut.FData;
        FListC.Values['Batch'] := nOut.FData;
        if not TWorkerBusinessCommander.CallMe(cBC_SaveStockBatcode,
            FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      end;
      //如果是袋装，则更新批次信息 
      {$ENDIF}

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
              SF('L_ZhiKa', FOrderItems[nIdx].FOrder),
              SF('L_CusID', FOrderItems[nIdx].FCusID),
              SF('L_CusName', FOrderItems[nIdx].FCusName),
              SF('L_CusPY', GetPinYinOfStr(FOrderItems[nIdx].FCusName)),
              SF('L_CusCode', FOrderItems[nIdx].FCusCode),
              SF('L_SaleID', FOrderItems[nIdx].FSaleID),
              SF('L_SaleMan', FOrderItems[nIdx].FSaleName),
              SF('L_Area', FOrderItems[nIdx].FAreaTo),

              SF('L_Type', FOrderItems[nIdx].FStockType),
              SF('L_StockNo', FOrderItems[nIdx].FStockID),
              SF('L_StockName', FOrderItems[nIdx].FStockName),
              SF('L_PackStyle', FListA.Values['Pack']),
              SF('L_Value', FOrderItems[nIdx].FKDValue, sfVal),
              SF('L_Price', 0, sfVal),

              SF('L_Truck', FListA.Values['Truck']),
              SF('L_Status', sFlag_BillNew),
              SF('L_Lading', FListA.Values['Lading']),
              SF('L_IsVIP', FListA.Values['IsVIP']),
              SF('L_Seal', FListA.Values['Seal']),
              SF('L_Man', FIn.FBase.FFrom.FUser),
              SF('L_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Bill, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);

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
            FStock := FOrderItems[nIdx].FStockID;
            FGroup := GetStockGroup(FStock);
            FRecord := nStr;
          end;
        end;
      end;

      if FListA.Values['BuDan'] = sFlag_Yes then //补单
      begin
        nStr := 'Update %s Set B_HasDone=B_HasDone+%.2f Where B_ID=''%s''';
        nStr := Format(nStr, [sTable_Order, FOrderItems[nIdx].FKDValue,
                FOrderItems[nIdx].FOrder]);
        nInt := gDBConnManager.WorkerExec(FDBConn, nStr);

        if nInt < 1 then
        begin
          nSQL := MakeSQLByStr([
            SF('B_ID', FOrderItems[nIdx].FOrder),
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
            SF('B_Freeze', FOrderItems[nIdx].FKDValue, sfVal)
            ], sTable_Order, '', True);
          gDBConnManager.WorkerExec(FDBConn, nStr);
        end;
      end;

      {$IFDEF BatchVerifyValue}
      nSQL := 'Update %s Set B_HasUse=B_HasUse+(%s),B_LastDate=%s ' +
              'Where B_Stock=''%s'' and B_Batcode=''%s''';
      nSQL := Format(nSQL, [sTable_Batcode, FloatToStr(FOrderItems[nIdx].FKDValue),
              sField_SQLServer_Now, FOrderItems[nIdx].FStockID,
              FListA.Values['Seal']]);
      gDBConnManager.WorkerExec(FDBConn, nSQL); //更新批次号使用量
      {$ENDIF}
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
  
  {$IFDEF MicroMsg}
  with FListC do
  begin
    Clear;
    Values['bill'] := FOut.FData;
    Values['company'] := gSysParam.FHintText;
  end;

  if FListA.Values['BuDan'] = sFlag_Yes then
       nStr := cWXBus_OutFact
  else nStr := cWXBus_MakeCard;

  gWXPlatFormHelper.WXSendMsg(nStr, FListC.Text);
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
    nStr,nP,nRID,nBill,nZK,nSN,nHY: string;
begin
  Result := False;
  nIsAdmin := FIn.FExtParam = 'Y';
  //init

  nStr := 'Select L_ZhiKa,L_Value,L_Seal,L_StockNO,L_OutFact From %s ' +
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

    nSN  := FieldByName('L_StockNO').AsString;
    nZK  := FieldByName('L_ZhiKa').AsString;
    nHY  := FieldByName('L_Seal').AsString;
    nVal := FieldByName('L_Value').AsFloat;
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
    if nHasOut then
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

    {$IFDEF BatchVerifyValue}
    nStr := 'Update %s Set B_HasUse=B_HasUse-(%.2f),B_LastDate=%s ' +
            'Where B_Stock=''%s'' and B_Batcode=''%s''';
    nStr := Format(nStr, [sTable_Batcode, nVal,
            sField_SQLServer_Now, nSN, nHY]);
    gDBConnManager.WorkerExec(FDBConn, nStr); //更新批次号使用量
    {$ELSE}
    nStr := 'Select L_Type,L_MValue,L_Seal,L_Value,D_Brand from $BL bl ' +
            'Left join $BC bc on bl.L_Seal=bc.D_ID ' +
            'Where L_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$BL', sTable_Bill),
            MI('$BC', sTable_BatcodeDoc),MI('$ID', FIn.FData)]);
    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount>0 then
    begin
      FListC.Clear;
      FListC.Values['Brand'] := FieldByName('D_Brand').AsString;
      FListC.Values['Batch'] := FieldByName('L_Seal').AsString;

      nStr := FieldByName('L_Type').AsString;
      if (nStr=sFlag_San) and (FieldByName('L_MValue').AsFloat<=0) then
           FListC.Values['Value'] := '0.00'
      else FListC.Values['Value'] := FieldByName('L_Value').AsString;

      if Length(FListC.Values['Batch']) > 0 then
      if not TWorkerBusinessCommander.CallMe(cBC_SaveStockBatcode,
            FListC.Text, sFlag_No, @FOut) then
        raise Exception.Create(FOut.FData);
    end;
    {$ENDIF}
    //批次管理

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

  nStr := 'Select L_ID,L_ZhiKa,L_CusID,L_CusName,L_Type,L_StockNo,' +
          'L_StockName,L_Truck,L_Value,L_Price,L_Status,' +
          'L_NextStatus,L_Card,L_IsVIP,L_PValue,L_MValue,' +
          'L_Seal,L_Memo From $Bill b ';
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

      if FIsVIP = sFlag_TypeShip then
      begin
        FStatus    := sFlag_TruckZT;
        FNextStatus := sFlag_TruckOut;
      end;

      if FStatus = sFlag_BillNew then
      begin
        FStatus     := sFlag_TruckNone;
        FNextStatus := sFlag_TruckNone;
      end;

      FPData.FValue := FieldByName('L_PValue').AsFloat;
      FMData.FValue := FieldByName('L_MValue').AsFloat;
      FSeal     := FieldByName('L_Seal').AsString;
      FMemo     := FieldByName('L_Memo').AsString;
      FSelected := True;

      Inc(nIdx);
      Next;
    end;
  end;

  FOut.FData := CombineBillItmes(nBills);
  Result := True;
end;

//Date: 2014-09-18
//Parm: 交货单[FIn.FData];岗位[FIn.FExtParam]
//Desc: 保存指定岗位提交的交货单列表
function TWorkerBusinessBills.SavePostBillItems(var nData: string): Boolean;
var nStr,nSQL,nTmp: string;
    f,m,nVal,nMVal,nTotal,nDec,nNet: Double;
    i,nIdx,nInt: Integer;
    nBills: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  nTotal := 0.00;
  AnalyseBillItems(FIn.FData, nBills);
  nInt := Length(nBills);

  if nInt < 1 then
  begin
    nData := '岗位[ %s ]提交的单据为空.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;
{
  if (nBills[0].FType = sFlag_San) and (nInt > 1) then
  begin
    nData := '岗位[ %s ]提交了散装合单,该业务系统暂时不支持.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;
}  
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
      FStatus := sFlag_TruckZT;
      if nInt >= 0 then //已称皮
           FNextStatus := sFlag_TruckBFM
      else FNextStatus := sFlag_TruckOut;

      nSQL := MakeSQLByStr([SF('L_Status', FStatus),
              SF('L_NextStatus', FNextStatus),
              SF('L_LadeTime', sField_SQLServer_Now, sfVal),
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
      nSQL := MakeSQLByStr([SF('L_Status', sFlag_TruckFH),
              SF('L_NextStatus', sFlag_TruckBFM),
              SF('L_LadeTime', sField_SQLServer_Now, sfVal),
              SF('L_LadeMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL);

      nSQL := 'Update %s Set T_InLade=%s Where T_HKBills Like ''%%%s%%''';
      nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now, FID]);
      FListA.Add(nSQL);
      //更新队列车辆提货状态
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFM then //称量毛重
  begin
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

    //销售规定卡，在二次过磅时，自动选择可用订单
    if nBills[nInt].FCardUse = sFlag_SaleNew then
    begin
      for nIdx:=Low(nBills) to High(nBills) do
      if not LinkToNCSystem(nData, nBills[nIdx]) then
        Exit;
    end else

    if nBills[nInt].FType = sFlag_San then
    begin
      for nIdx:=Low(nBills) to High(nBills) do
      with nBills[nIdx] do
      begin
        if not FNCChanged then Continue;

        nSQL := 'Update %s Set B_Freeze=B_Freeze-%.2f Where B_ID=''%s''';
        nSQL := Format(nSQL, [sTable_Order, FChangeValue, FZhiKa]);
        FListA.Add(nSQL);
      end;
      //NC可用量减少

      nNet := nMVal - nBills[nInt].FPData.FValue;

      nVal := 0;
      for nIdx:=Low(nBills) to High(nBills) do
        nVal := nBills[nIdx].FValue + nVal;
      //开票量

      nVal := nVal - nNet;
      //调整量

      if nVal>0 then
      for nIdx:=Low(nBills) to High(nBills) do
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

        {$IFDEF BatchVerifyValue}
        nSQL := 'Update %s Set B_HasUse=B_HasUse-(%.2f),B_LastDate=%s ' +
                'Where B_Stock=''%s'' and B_Batcode=''%s''';
        nSQL := Format(nSQL, [sTable_Batcode, nDec,
                sField_SQLServer_Now, FStockNo, FSeal]);
        FListA.Add(nSQL); //更新批次号使用量
        {$ENDIF}
      end;
    end;
    //AjustSanValue;
  
    nVal := 0;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      if nIdx < High(nBills) then
      begin
        FMData.FValue := FPData.FValue + FValue;
        nVal := nVal + FValue;
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

      nSQL := 'Update %s Set B_HasDone=B_HasDone+(%.2f),' +
              'B_Freeze=B_Freeze-(%.2f) Where B_ID=''%s''';
      nSQL := Format(nSQL, [sTable_Order, FValue, FValue, FZhiKa]);
      FListA.Add(nSQL); //更新订单
    end;

    if not TWorkerBusinessCommander.CallMe(cBC_SyncME25,
          FListB.Text, '', @nOut) then
      raise Exception.Create(nOut.FData);
    //同步销售到NC榜单

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
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    {$IFNDEF BatchVerifyValue}
    if (FIn.FExtParam=sFlag_TruckBFM) and (nBills[nInt].FType=sFlag_San) then
    begin
      nStr := 'Select L_Seal,L_Value,D_Brand from $BL bl ' +
            'Left join $BC bc on bl.L_Seal=bc.D_ID ' +
            'Where L_ID=''$ID''';
      nStr := MacroValue(nStr, [MI('$BL', sTable_Bill),
              MI('$BC', sTable_BatcodeDoc),MI('$ID', nBills[nInt].FID)]);
      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      if RecordCount>0 then
      begin
        FListC.Clear;
        FListC.Values['Brand'] := FieldByName('D_Brand').AsString;
        FListC.Values['Batch'] := FieldByName('L_Seal').AsString;
        FListC.Values['Value'] := FloatToStr(nTotal);
      end;

      if not TWorkerBusinessCommander.CallMe(cBC_GetStockBatcode,
          nBills[nInt].FStockNo, FListC.Text, @nOut) then
      raise Exception.Create(nOut.FData);

      for nIdx:=Low(nBills) to High(nBills) do
      with nBills[nIdx] do
      begin
        if nBills[nInt].FPModel = sFlag_PoundCC then Continue;
        //出厂模式,不更新状态

        nSQL := MakeSQLByStr([SF('L_Seal', nOut.FData)
                ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL);
      end;

      FListC.Values['Batch'] := nOut.FData;
      if not TWorkerBusinessCommander.CallMe(cBC_SaveStockBatcode,
          FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    end;
    {$ENDIF}

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
  
  {$IFDEF MicroMsg}
  nStr := '';
  for nIdx:=Low(nBills) to High(nBills) do
    nStr := nStr + nBills[nIdx].FID + ',';
  //xxxxx

  if FIn.FExtParam = sFlag_TruckOut then
  begin
    with FListA do
    begin
      Clear;
      Values['bill'] := nStr;
      Values['company'] := gSysParam.FHintText;
    end;

    gWXPlatFormHelper.WXSendMsg(cWXBus_OutFact, FListA.Text);
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
    nData := '获取读NC订单语句失败，条件为[ %s ]';
    nData := Format(nData, [FListC.Text]);
    Exit;
  end;

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nOut.FData, nWorker, sFlag_DB_NC) do
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
          end else FStockType := FStockInfo[nIdx].FType;

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
  if not TWorkerBusinessCommander.CallMe(cBC_GetStockBatcode,
      nBill.FStockNo, FloatToStr(nVal), @nOut) then
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
var nStr, nTruck, nType: string;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);
  nTruck := FListA.Values['Truck'];
  //init card

  nStr := 'Select D_Memo From %s Where D_Name=''%s'' And D_ParamB=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem, FListA.Values['StockNO']]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '物料信息[ %s.%s ]不存在!';
      nData := Format(nData, [FListA.Values['StockNO'], FListA.Values['StockName']]);
      Exit;
    end;

    nType := Fields[0].AsString;
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

            SF('B_Type', nType),
            SF('B_StockNo', FListA.Values['StockNo']),
            SF('B_StockName', FListA.Values['StockName']),

            SF('B_IsVip', FListA.Values['IsVip']),
            SF('B_Lading', FListA.Values['Lading']),
            SF('B_PackStyle', FListA.Values['IsVip']),

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
        FGroup := GetStockGroup(FStock);
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
        FGroup := GetStockGroup(FStock);
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

  {$IFDEF MicroMsg}
  with FListC do
  begin
    Clear;
    Values['bill'] := FOut.FData;
    Values['company'] := gSysParam.FHintText;
  end;

  if FListA.Values['BuDan'] = sFlag_Yes then
       nStr := cWXBus_OutFact
  else nStr := cWXBus_MakeCard;

  gWXPlatFormHelper.WXSendMsg(nStr, FListC.Text);
  {$ENDIF}
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessBills, sPlug_ModuleBus);
end.

{*******************************************************************************
  作者: fendou116688@163.com 2016/3/25
  描述: 销售退货(回空)称重业务对象
*******************************************************************************}
unit UWorkerBusinessHaulBack;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, DateUtils, UWorkerBusinessCommand;

type
  TWorkerBusinessHaulback = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function SaveHaulback(var nData: string): Boolean;
    //保存销售回空单
    function SaveHaulbackCard(var nData: string): Boolean;
    //保存销售回空磁卡
    function DeleteHaulback(var nData: string): Boolean;
    //删除销售回空单
    function GetPostItems(var nData: string): Boolean;
    //获取岗位单据
    function SavePostItems(var nData: string): Boolean;
    //保存岗位单据
    function VerifyBeforSave(var nData: string): Boolean;
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

implementation

//Date: 2014-09-15
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
class function TWorkerBusinessHaulback.CallMe(const nCmd: Integer;
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

//------------------------------------------------------------------------------
class function TWorkerBusinessHaulback.FunctionName: string;
begin
  Result := sBus_BusinessHaulback;
end;

constructor TWorkerBusinessHaulback.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessHaulback.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TWorkerBusinessHaulback.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessHaulback.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2015-8-5
//Parm: 输入数据
//Desc: 执行nData业务指令
function TWorkerBusinessHaulback.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;

  case FIn.FCommand of
   cBC_SaveBills          : Result := SaveHaulback(nData);
   cBC_DeleteBill         : Result := DeleteHaulback(nData);
   cBC_SaveBillCard       : Result := SaveHaulbackCard(nData);

   cBC_GetPostBills       : Result := GetPostItems(nData);
   cBC_SavePostBills      : Result := SavePostItems(nData);
   else
    begin
      Result := False;
      nData := '无效的业务代码(Invalid Command).';
    end;
  end;
end;

function TWorkerBusinessHaulback.VerifyBeforSave(var nData: string): Boolean;
var nInt: Integer;
    nStr: string;
    nOutFact, nToday: TDateTime;
begin
  Result := False;

  nStr := 'Select H_ID From %s Where H_Truck=''%s'' And H_OutFact Is Null';
  nStr := Format(nStr, [sTable_BillHaulback, FListA.Values['Truck']]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nData := '车辆[ %s ]有未完成的销售回空单据[ %s ],请先处理.';
    nData := Format(nData, [FListA.Values['Truck'], Fields[0].AsString]);
    Exit;
  end;

  nStr := 'Select H_ID From %s Where H_LID=''%s''';
  nStr := Format(nStr, [sTable_BillHaulback, FListA.Values['BillNO']]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nData := '提货单[ %s ]已完成的销售回空单据[ %s ],不允许重复回空.';
    nData := Format(nData, [FListA.Values['BillNO'], Fields[0].AsString]);
    Exit;
  end;

  nStr := 'Select b1.*, p1.P_ID From %s b1 Left Join %s p1 on p1.P_Bill=b1.L_ID' +
          ' Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, sTable_PoundLog, FListA.Values['BillNO']]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr),FListA do
  begin
    Values['BillNO']   := FieldByName('L_ID').AsString;
    Values['BillPound']:= FieldByName('P_ID').AsString;
    Values['BOutFact'] := FieldByName('L_OutFact').AsString;

    Values['CusID']    := FieldByName('L_CusID').AsString;
    Values['CusPY']    := FieldByName('L_CusPY').AsString;
    Values['CusName']  := FieldByName('L_CusName').AsString;

    Values['SaleID']   := FieldByName('L_SaleID').AsString;
    Values['SaleMan']  := FieldByName('L_SaleMan').AsString;
    
    Values['Type']     := FieldByName('L_Type').AsString;
    Values['StockNo']  := FieldByName('L_StockNo').AsString;
    Values['StockName']:= FieldByName('L_StockName').AsString;

    Values['LimValue'] := FieldByName('L_Value').AsString;
  end;

  if Length(FListA.Values['BOutFact']) < 1 then
  begin
    nData := '提货单[ %s ]车辆未出厂, 禁止回空.';
    nData := Format(nData, [FListA.Values['BillNO']]);
    Exit;
  end;

  if FloatRelation(StrToFloat(FListA.Values['Value']),
    StrToFloat(FListA.Values['LimValue']), rtGreater) then
  begin
    nData := '禁止提货单[ %s ]回空量超出原提货量[ %s ]吨.';
    nData := Format(nData, [FListA.Values['BillNO'], FListA.Values['LimValue']]);
    Exit;
  end;    

  nToday   := Today;
  nOutFact := Str2DateTime(FListA.Values['BOutFact']);

  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_OutOfHaulBack]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
       nInt := Fields[0].AsInteger
  else nInt := 3;
  //默认30天

  if DaysBetween(nOutFact, nToday) > nInt then
  begin
    nData := '提货单[ %s ]出厂时间已超出回空时间限制[ %d ]天,不允许回空.';
    nData := Format(nData, [FListA.Values['BillNO'], nInt]);
    Exit;
  end;

  Result := True;
  //verify done
end;

//Date: 2016-02-27
//Desc: 生成销售回空单
function TWorkerBusinessHaulback.SaveHaulback(var nData: string): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);
  if not VerifyBeforSave(nData) then Exit;

  with FListC do
  begin
    Clear;
    Values['Group'] :=sFlag_BusGroup;
    Values['Object'] := sFlag_BillHaulBack;
  end;

  if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
        FListC.Text, sFlag_Yes, @nOut) then  //to get serial no
  begin
    nData := nOut.FData;
    Exit;
  end;

  FOut.FData := nOut.FData;
  //id

  FDBConn.FConn.BeginTrans;
  with FListA do
  try
    nStr := MakeSQLByStr([SF('H_ID', nOut.FData),
            SF('H_LID', Values['BillNO']),
            SF('H_LPID', Values['BillPound']),
            SF('H_Card', Values['Card']),
            SF('H_LOutFact', Values['BOutFact']),

            SF('H_Truck', Values['Truck']),
            SF('H_CusID', Values['CusID']),
            SF('H_CusPY', Values['CusPY']),
            SF('H_CusName', Values['CusName']),

            SF('H_SaleID', Values['SaleID']),
            SF('H_SaleMan', Values['SaleMan']),

            SF('H_Type', Values['Type']),
            SF('H_StockNo', Values['StockNo']),
            SF('H_StockName', Values['StockName']),
            SF('H_Value', StrToFloat(Values['Value']), sfVal),
            SF('H_LimValue', StrToFloat(Values['LimValue']), sfVal),

            SF('H_Status', sFlag_BillNew),
            SF('H_Man', FIn.FBase.FFrom.FUser),
            SF('H_Date', sField_SQLServer_Now, sfVal)
            ], sTable_BillHaulback, '', True);
    //xxxxx
    gDBConnManager.WorkerExec(FDBConn, nStr);

    if Values['Type'] = sFlag_Dai then
    begin
      nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
      nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_PoundIfDai]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
       if (RecordCount > 0) and (Fields[0].AsString = sFlag_No) then
       begin
         nStr := MakeSQLByStr([SF('H_Status', sFlag_TruckOut),
                  SF('H_InTime', sField_SQLServer_Now, sfVal),
                  SF('H_PValue', 1, sfVal),
                  SF('H_PDate', sField_SQLServer_Now, sfVal),
                  SF('H_PMan', FIn.FBase.FFrom.FUser),
                  SF('H_MValue', StrToFloat(Values['Value']) + 1, sfVal),
                  SF('H_MDate', sField_SQLServer_Now, sfVal),
                  SF('H_MMan', FIn.FBase.FFrom.FUser),
                  SF('H_LadeTime', sField_SQLServer_Now, sfVal),
                  SF('H_LadeMan', FIn.FBase.FFrom.FUser),
                  SF('H_OutFact', sField_SQLServer_Now, sfVal),
                  SF('H_OutMan', FIn.FBase.FFrom.FUser),
                  SF('H_Card', '')
                  ], sTable_BillHaulback, SF('H_ID', nOut.FData), False);
          gDBConnManager.WorkerExec(FDBConn, nStr);
       end;
    end;

    if FListA.Values['DelBill'] <> '' then
    begin
      nStr := 'Delete From %s Where L_Card=''%s''';
      nStr := Format(nStr, [sTable_Bill, FListA.Values['Card']]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //删除原始开票单据
    end;

    nStr := 'Select Count(*) From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FListA.Values['Card']]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if Fields[0].AsInteger < 1 then
    begin
      nStr := MakeSQLByStr([SF('C_Card', FListA.Values['Card']),
              SF('C_Group', FListA.Values['CardType']),
              SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Haulback),
              SF('C_Freeze', sFlag_No),
              SF('C_TruckNo', FListA.Values['Truck']),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end else
    begin
      nStr := Format('C_Card=''%s''', [FListA.Values['Card']]);
      nStr := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
              SF('C_Group', FListA.Values['CardType']),
              SF('C_Used', sFlag_Haulback),
              SF('C_Freeze', sFlag_No),
              SF('C_TruckNo', FListA.Values['Truck']),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, nStr, False);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;
    //更新磁卡状态

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end; 
end;

//Date: 2016-02-27
//Parm: 单据[FIn.FData];磁卡[FIn.FExtParam]
//Desc: 保存销售回空单磁卡
function TWorkerBusinessHaulback.SaveHaulbackCard(var nData: string): Boolean;
var nStr,nTruck: string;
    nIdx: Integer;
begin
  Result := False;

  nStr := 'Select H_Card,H_Truck From %s Where H_ID=''%s''';
  nStr := Format(nStr, [sTable_BillHaulback, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '销售回空单据[ %s ]已丢失.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    FListA.Clear;
    nTruck := Fields[1].AsString;
    
    if Fields[0].AsString <> '' then
    begin
      nStr := 'Update %s set C_TruckNo=Null,C_Status=''%s'' Where C_Card=''%s''';
      nStr := Format(nStr, [sTable_Card, sFlag_CardIdle, Fields[0].AsString]);
      FListA.Add(nStr); //磁卡状态
    end;
  end;

  nStr := 'Update %s Set H_Card=''%s'' Where H_ID=''%s''';
  nStr := Format(nStr, [sTable_BillHaulback, FIn.FExtParam, FIn.FData]);
  FListA.Add(nStr);

  nStr := 'Select Count(*) From %s Where C_Card=''%s''';
  nStr := Format(nStr, [sTable_Card, FIn.FExtParam]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if Fields[0].AsInteger < 1 then
  begin
    nStr := MakeSQLByStr([SF('C_Card', FIn.FExtParam),
            SF('C_Status', sFlag_CardUsed),
            SF('C_Used', sFlag_Haulback),
            SF('C_TruckNo', nTruck),
            SF('C_Freeze', sFlag_No),
            SF('C_Man', FIn.FBase.FFrom.FUser),
            SF('C_Date', sField_SQLServer_Now, sfVal)
            ], sTable_Card, '', True);
    FListA.Add(nStr);
  end else
  begin
    nStr := Format('C_Card=''%s''', [FIn.FExtParam]);
    nStr := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
            SF('C_Used', sFlag_Haulback),
            SF('C_TruckNo', nTruck),
            SF('C_Freeze', sFlag_No),
            SF('C_Man', FIn.FBase.FFrom.FUser),
            SF('C_Date', sField_SQLServer_Now, sfVal)
            ], sTable_Card, nStr, False);
    FListA.Add(nStr);
  end;

  FDBConn.FConn.BeginTrans;
  try
    for nIdx:=FListA.Count - 1 downto 0 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
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

//Date: 2016-02-27
//Parm: 销售回空单[FIn.FData]
//Desc: 删除销售回空单
function TWorkerBusinessHaulback.DeleteHaulback(var nData: string): Boolean;
var nStr,nP: string;
    nIdx: Integer;
begin
  Result := False;
  FListA.Clear;

  nStr := 'Select * From %s Where H_ID=''%s''';
  nStr := Format(nStr, [sTable_BillHaulback, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '销售回空单据[ %s ]已丢失.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    if FieldByName('H_Card').AsString <> '' then
    begin
      nStr := 'Update %s set C_TruckNo=Null,C_Status=''%s'' Where C_Card=''%s''';
      nStr := Format(nStr, [sTable_Card, sFlag_CardIdle, Fields[0].AsString]);
      FListA.Add(nStr); //磁卡状态
    end;
  end;

  //--------------------------------------------------------------------------
  nStr := Format('Select * From %s Where 1<>1', [sTable_BillHaulback]);
  //only for fields
  nP := '';

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    for nIdx:=0 to FieldCount - 1 do
     if (Fields[nIdx].DataType <> ftAutoInc) and
        (Pos('H_Del', Fields[nIdx].FieldName) < 1) then
      nP := nP + Fields[nIdx].FieldName + ',';
    //所有字段,不包括删除

    System.Delete(nP, Length(nP), 1);
  end;

  nStr := 'Insert Into $RB($FL,H_DelMan,H_DelDate) ' +
          'Select $FL,''$User'',$Now From $RF Where H_ID=''$ID''';
  nStr := MacroValue(nStr, [MI('$RB', sTable_BillHaulBak),
          MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
          MI('$Now', sField_SQLServer_Now),
          MI('$RF', sTable_BillHaulback), MI('$ID', FIn.FData)]);
  FListA.Add(nStr);

  nStr := 'Delete From %s Where H_ID=''%s''';
  nStr := Format(nStr, [sTable_BillHaulback, FIn.FData]);
  FListA.Add(nStr);

  FDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
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

//Date: 2016-02-28
//Parm: 磁卡号[FIn.FData];岗位[FIn.FExtParam]
//Desc: 获取特定岗位所需要的交货单列表
function TWorkerBusinessHaulback.GetPostItems(var nData: string): Boolean;
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

  nStr := 'Select b.*,p.P_ID,p.P_PStation ' +
          'From $Bill b ' +
          '  Left Join $Pound p on p.P_Bill=b.H_ID ';
  //xxxxx

  if nIsBill then
       nStr := nStr + 'Where H_ID=''$CD'''
  else nStr := nStr + 'Where H_Card=''$CD''';

  nStr := MacroValue(nStr, [MI('$Bill', sTable_BillHaulback),
          MI('$Pound', sTable_PoundLog),MI('$CD', FIn.FData)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      if nIsBill then
           nData := '回空单[ %s ]已无效.'
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
      FID         := FieldByName('H_ID').AsString;
      FCusID      := FieldByName('H_CusID').AsString;
      FCusName    := FieldByName('H_CusName').AsString;
      FTruck      := FieldByName('H_Truck').AsString;
      FPoundID    := FieldByName('P_ID').AsString;

      FValue      := FieldByName('H_Value').AsFloat;
      FPrice      := FieldByName('H_Price').AsFloat;
      FType       := FieldByName('H_Type').AsString;
      FStockNo    := FieldByName('H_StockNo').AsString;
      FStockName  := FieldByName('H_StockName').AsString;

      FCard       := FieldByName('H_Card').AsString;
      FStatus     := FieldByName('H_Status').AsString;
      FNextStatus := FieldByName('H_NextStatus').AsString;

      if FStatus = sFlag_BillNew then
      begin
        FStatus := sFlag_TruckIn;
        FNextStatus := sFlag_TruckBFP;
      end;

      with FPData do
      begin
        FDate   := FieldByName('H_PDate').AsDateTime;
        FValue  := FieldByName('H_PValue').AsFloat;
        FStation:= FieldByName('P_PStation').AsString;
        FOperator := FieldByName('H_PMan').AsString;
      end;

      FSelected := True; 
      Inc(nIdx);
      Next;
    end;
  end;

  FOut.FData := CombineBillItmes(nBills);
  Result := True;
end;

//Date: 2016-02-28
//Parm: 销售回空单[FIn.FData];岗位[FIn.FExtParam]
//Desc: 保存指定岗位提交的交货单列表
function TWorkerBusinessHaulback.SavePostItems(var nData: string): Boolean;
var nOut: TWorkerBusinessCommand;
    nBills: TLadingBillItems;
    nInt,nIdx: Integer;
    nSQL: string;
    nVal: Double;
begin
  Result := False;
  AnalyseBillItems(FIn.FData, nBills);
  nInt := Length(nBills);
  //解析数据

  if nInt < 1 then
  begin
    nData := '岗位[ %s ]提交的单据为空.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  if nInt > 1 then
  begin
    nData := '岗位[ %s ]提交了销售回空合单,该业务系统暂时不支持.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  FListA.Clear;
  //用于存储SQL列表
  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckIn then //进厂
  with nBills[0] do
  begin
    FStatus := sFlag_TruckIn;
    FNextStatus := sFlag_TruckBFP;

    nSQL := MakeSQLByStr([
            SF('H_Status', sFlag_TruckIn),
            SF('H_NextStatus', sFlag_TruckBFP),
            SF('H_InTime', sField_SQLServer_Now, sfVal),
            SF('H_InMan', FIn.FBase.FFrom.FUser)
            ], sTable_BillHaulback, SF('H_ID', FID), False);
    FListA.Add(nSQL);
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFP then //称量皮重
  begin
    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := nOut.FData;
    //返回榜单号,用于拍照绑定
    with nBills[0] do
    begin
      FStatus := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckBFM;

      nSQL := MakeSQLByStr([
            SF('P_ID', nOut.FData),
            SF('P_Type', sFlag_Haulback),
            SF('P_Bill', FID),
            SF('P_Truck', FTruck),
            SF('P_CusID', FCusID),
            SF('P_CusName', FCusName),
            SF('P_MID', FStockNo),
            SF('P_MName', FStockName),
            SF('P_MType', FType),
            SF('P_LimValue', FValue),
            SF('P_PValue', FPData.FValue, sfVal),
            SF('P_PDate', sField_SQLServer_Now, sfVal),
            SF('P_PMan', FIn.FBase.FFrom.FUser),
            SF('P_FactID', FFactory),
            SF('P_PStation', FPData.FStation),
            SF('P_Direction', '回空'),
            SF('P_PModel', FPModel),
            SF('P_Status', sFlag_TruckBFP),
            SF('P_Valid', sFlag_Yes),
            SF('P_PrintNum', 1, sfVal)
            ], sTable_PoundLog, '', True);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('H_Status', FStatus),
              SF('H_NextStatus', FNextStatus),
              SF('H_PValue', FPData.FValue, sfVal),
              SF('H_PDate', sField_SQLServer_Now, sfVal),
              SF('H_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_BillHaulback, SF('H_ID', FID), False);
      FListA.Add(nSQL);
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFM then //称量毛重
  begin
    with nBills[0] do
    begin
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
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, SF('P_Bill', FID), False);
        FListA.Add(nSQL);
        //称重时,由于皮重大,交换皮毛重数据

        nSQL := MakeSQLByStr([
                SF('H_Status', sFlag_TruckBFM),
                SF('H_NextStatus', sFlag_TruckOut),
                SF('H_PValue', FPData.FValue, sfVal),
                SF('H_PDate', sField_SQLServer_Now, sfVal),
                SF('H_PMan', FIn.FBase.FFrom.FUser),
                SF('H_MValue', FMData.FValue, sfVal),
                SF('H_MDate', DateTime2Str(FMData.FDate)),
                SF('H_MMan', FMData.FOperator)
                ], sTable_BillHaulback, SF('H_ID', FID), False);
        FListA.Add(nSQL);

      end else
      begin
        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, SF('P_Bill', FID), False);
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('H_Status', sFlag_TruckBFM),
                SF('H_NextStatus', sFlag_TruckOut),
                SF('H_MValue', FMData.FValue, sfVal),
                SF('H_MDate', sField_SQLServer_Now, sfVal),
                SF('H_MMan', FIn.FBase.FFrom.FUser)
                ], sTable_BillHaulback, SF('H_ID', FID), False);
        FListA.Add(nSQL);
      end;

      if FType = sFlag_San then
      begin
        nVal := Float2Float(FMData.FValue-FPData.FValue, cPrecision, False);
        nSQL := 'Select H_LimValue, H_LID From %s Where H_ID=''%s''';
        nSQL := Format(nSQL, [sTable_BillHaulback, FID]);

        with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
        begin
          if RecordCount < 1 then
          begin
            nData := '退购单据[ %s ]已丢失.';
            nData := Format(nData, [FID]);
            Exit;
          end;

          if FloatRelation(nVal, Fields[0].AsFloat, rtGreater) then
          begin
            nData := '退购净重大于原提货单据[ %s ]实际提货量[ %.2f ]，请查证.';
            nData := Format(nData, [Fields[1].AsString, Fields[0].AsString]);
            Exit;
          end;  
        end;

        nSQL := MakeSQLByStr([
                SF('H_Value', nVal, sfVal)
                ], sTable_BillHaulback, SF('H_ID', FID), False);
        FListA.Add(nSQL);
      end;   
    end;

    FOut.FData := nBills[0].FPoundID;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckOut then
  with nBills[0] do
  begin
    nSQL := MakeSQLByStr([SF('H_Status', sFlag_TruckOut),
            SF('H_NextStatus', ''),
            SF('H_Card', ''),
            SF('H_OutFact', sField_SQLServer_Now, sfVal),
            SF('H_OutMan', FIn.FBase.FFrom.FUser)
            ], sTable_BillHaulback, SF('H_ID', FID), False);
    FListA.Add(nSQL);

    nSQL := 'Update %s Set C_Status=''%s'',C_TruckNo=Null Where C_Card=''%s''';
    nSQL := Format(nSQL, [sTable_Card, sFlag_CardIdle, FCard]);
    FListA.Add(nSQL); //磁卡

    if not TWorkerBusinessCommander.CallMe(cBC_SyncHaulBack,
          FID, '', @nOut) then
      raise Exception.Create(nOut.FData);
    //同步回空业务到NC榜单
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
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessHaulback, sPlug_ModuleBus);
end.

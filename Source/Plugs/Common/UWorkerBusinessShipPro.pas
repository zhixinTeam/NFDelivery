{*******************************************************************************
  作者: fendou116688@163.com 2017/6/2
  描述: 码头采购
*******************************************************************************}
unit UWorkerBusinessShipPro;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, UWorkerBusinessCommand
  {$IFDEF HardMon}, UMgrHardHelper, UWorkerHardware{$ENDIF};

type
  TWorkerBusinessShipPro = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function VerifyPTruckCount(const nPID, nStockNo: string; var nHint: string): Boolean;
    function VerifyPTime(const nStockNo: string; var nHint: string): Boolean;

    function SaveCardProvide(var nData: string): Boolean;
    function DeleteCardProvide(var nData: string): Boolean;
    //采购入厂磁卡办理及删除

    function GetPostProvideItems(var nData: string): Boolean;
    //获取岗位采购入厂单
    function SavePostProvideItems(var nData: string): Boolean;
    //保存岗位采购入厂单
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

//------------------------------------------------------------------------------
class function TWorkerBusinessShipPro.FunctionName: string;
begin
  Result := sBus_BusinessShipPro;
end;

constructor TWorkerBusinessShipPro.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessShipPro.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TWorkerBusinessShipPro.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessShipPro.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2015-8-5
//Parm: 输入数据
//Desc: 执行nData业务指令
function TWorkerBusinessShipPro.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;

  case FIn.FCommand of
   cBC_SaveBills         : Result := SaveCardProvide(nData);
   cBC_DeleteBill        : Result := DeleteCardProvide(nData);
   cBC_GetPostBills      : Result := GetPostProvideItems(nData);
   cBC_SavePostBills     : Result := SavePostProvideItems(nData);
   else
    begin
      Result := False;
      nData := '无效的业务代码(Invalid Command).';
    end;
  end;
end;

function TWorkerBusinessShipPro.SaveCardProvide(var nData: string): Boolean;
var nStr, nTruck: string;
    nOut: TWorkerBusinessCommand;
    nHint : string;
begin
  FListA.Text := PackerDecodeStr(FIn.FData);
  nTruck := FListA.Values['Truck'];
  //init card
  if Trim(FListA.Values['Card']) = '' then
    raise Exception.Create('卡号异常,请尝试重新办理或联系管理员');

  {$IFDEF PTruckCount}
  if not VerifyPTruckCount(FListA.Values['ProID'],FListA.Values['StockNo'], nHint) then
    raise Exception.Create(nHint);
  {$ENDIF}

  {$IFDEF PTimeControl}
  if not VerifyPTime(FListA.Values['StockNo'], nHint) then
    raise Exception.Create(nHint);
  {$ENDIF}

  TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, nTruck, '', @nOut);
  //保存车牌号

  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set P_Card=NULL, P_CType=NULL Where P_Card=''%s''';
    nStr := Format(nStr, [sTable_ProvBase, FListA.Values['Card']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //正在使用的采购订单

    nStr := 'Update %s Set L_Card=NULL Where L_Card=''%s''';
    nStr := Format(nStr, [sTable_Bill, FListA.Values['Card']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //正在使用的销售提货单

    nStr := 'Update %s Set P_Card=NULL Where P_Card=''%s''';
    nStr := Format(nStr, [sTable_CardProvide, FListA.Values['Card']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //正在使用的采购业务卡

    nStr := MakeSQLByStr([
            SF('P_Order', FListA.Values['Order']),       //NC订单编号
            SF('P_Origin', FListA.Values['Origin']),     //NC来源,矿点
            SF('P_CusID', FListA.Values['ProID']),       //NC供应商ID
            SF('P_CusName', FListA.Values['ProName']),   //NC供应商名称
            SF('P_CusPY', GetPinYinOfStr(FListA.Values['ProName'])),

            SF('P_MType', sFlag_San),
            SF('P_MID', FListA.Values['StockNo']),
            SF('P_MName', FListA.Values['StockName']),

            SF('P_Memo', FListA.Values['Memo']),
            SF('P_Card', FListA.Values['Card']),
            SF('P_KeepCard', FListA.Values['CardType']),

            SF('P_MuiltiPound', FListA.Values['Muilti']),
            SF('P_OneDoor', FListA.Values['TruckBack']),
            SF('P_UsePre', FListA.Values['TruckPre']),
            {$IFDEF FORCEPSTATION}
            SF('P_PoundStation', FListA.Values['PoundStation']),
            SF('P_PoundName', FListA.Values['PoundName']),
            {$ENDIF}

            {$IFDEF RemoteSnap}
            SF('P_SnapTruck',   FListA.Values['SnapTruck']),
            {$ENDIF}

            {$IFDEF ProShip}
            SF('P_Ship', FListA.Values['Ship']),
            {$ENDIF}

            SF('P_Truck', nTruck),
            SF('P_Status', sFlag_TruckNone),
            SF('P_Man', FIn.FBase.FFrom.FUser),
            SF('P_Date', sField_SQLServer_Now, sfVal)
            ], sTable_CardProvide, '', True);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Select Count(*) From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FListA.Values['Card']]);


    if FListA.Values['UseELabel'] = sFlag_Yes then
    begin
      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      if Fields[0].AsInteger < 1 then
      begin
        nStr := MakeSQLByStr([SF('C_Card', FListA.Values['Card']),
                SF('C_Card2', FListA.Values['Card']),
                SF('C_Card3', 'H' + FListA.Values['Card']),
                SF('C_Group', FListA.Values['CardType']),
                SF('C_Status', sFlag_CardUsed),
                SF('C_Used', sFlag_ShipPro),
                SF('C_Freeze', sFlag_No),
                SF('C_TruckNo', nTruck),
                SF('C_Man', FIn.FBase.FFrom.FUser),
                SF('C_Date', sField_SQLServer_Now, sfVal)
                ], sTable_Card, '', True);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end else
      begin
        nStr := Format('C_Card=''%s''', [FListA.Values['Card']]);
        nStr := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
                SF('C_Group', FListA.Values['CardType']),
                SF('C_Used', sFlag_ShipPro),
                SF('C_Freeze', sFlag_No),
                SF('C_TruckNo', nTruck),
                SF('C_Man', FIn.FBase.FFrom.FUser),
                SF('C_Date', sField_SQLServer_Now, sfVal)
                ], sTable_Card, nStr, False);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end;
      //更新磁卡状态
    end
    else
    begin
      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      if Fields[0].AsInteger < 1 then
      begin
        nStr := MakeSQLByStr([SF('C_Card', FListA.Values['Card']),
                SF('C_Group', FListA.Values['CardType']),
                SF('C_Status', sFlag_CardUsed),
                SF('C_Used', sFlag_ShipPro),
                SF('C_Freeze', sFlag_No),
                SF('C_TruckNo', nTruck),
                SF('C_Man', FIn.FBase.FFrom.FUser),
                SF('C_Date', sField_SQLServer_Now, sfVal)
                ], sTable_Card, '', True);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end else
      begin
        nStr := Format('C_Card=''%s''', [FListA.Values['Card']]);
        nStr := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
                SF('C_Group', FListA.Values['CardType']),
                SF('C_Used', sFlag_ShipPro),
                SF('C_Freeze', sFlag_No),
                SF('C_TruckNo', nTruck),
                SF('C_Man', FIn.FBase.FFrom.FUser),
                SF('C_Date', sField_SQLServer_Now, sfVal)
                ], sTable_Card, nStr, False);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end;
      //更新磁卡状态
    end;
    {$IFDEF PurQueue}
    nStr := MakeSQLByStr([
    SF('T_Truck'   , FListA.Values['Truck']),
    SF('T_StockNo' , FListA.Values['StockNo']),
    SF('T_Stock'   , FListA.Values['StockName']),
    SF('T_Type'    , sFlag_San),
    SF('T_InTime'  , sField_SQLServer_Now, sfVal),
    SF('T_Bill'    , FListA.Values['Card']),
    SF('T_Valid'   , sFlag_Yes),
    SF('T_Value'   , 50, sfVal),
    SF('T_VIP'     , 'C'),
    SF('T_HKBills' , FListA.Values['Card'] + '.')
    ], sTable_ZTTrucks, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    {$ENDIF}

    FDBConn.FConn.CommitTrans;
    FOut.FData := sFlag_Yes;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;

  {$IFDEF HardMon}
  if Length(FListA.Values['PoundStation']) > 0 then
  begin
    FListC.Clear;
    FListC.Values['Card'] := 'dt';
    FListC.Values['Text'] := #9 + FListA.Values['Truck'] + #9;
    FListC.Values['Content'] := FListA.Values['PoundStation'];
    THardwareCommander.CallMe(cBC_PlayVoice, PackerEncodeStr(FListC.Text), '', @nOut);
  end;
  {$ENDIF}
end;

//Date: 2015/9/19
//Parm: 
//Desc: 删除采购入厂申请单
function TWorkerBusinessShipPro.DeleteCardProvide(var nData: string): Boolean;
var nStr,nP: string;
    nIdx: Integer;
begin
  FDBConn.FConn.BeginTrans;
  try
    //--------------------------------------------------------------------------
    nStr := 'Select P_Card From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_CardProvide, FIn.FData]);
    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if (RecordCount > 0) And (Fields[0].AsString <> '') then
    begin
      nStr := 'Update %s set C_TruckNo=Null,C_Status=''%s'' Where C_Card=''%s''';
      nStr := Format(nStr, [sTable_Card, sFlag_CardIdle, Fields[0].AsString]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;
    //注销磁卡

    nStr := Format('Select * From %s Where 1<>1', [sTable_CardProvide]);
    //only for fields
    nP := '';

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      for nIdx:=0 to FieldCount - 1 do
       if (Fields[nIdx].DataType <> ftAutoInc) and
          (Pos('P_Del', Fields[nIdx].FieldName) < 1) then
        nP := nP + Fields[nIdx].FieldName + ',';
      //所有字段,不包括删除

      System.Delete(nP, Length(nP), 1);
    end;

    nStr := 'Insert Into $OB($FL,P_DelMan,P_DelDate) ' +
            'Select $FL,''$User'',$Now From $OO Where R_ID=$ID';
    nStr := MacroValue(nStr, [MI('$OB', sTable_CardProvideBak),
            MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
            MI('$Now', sField_SQLServer_Now),
            MI('$OO', sTable_CardProvide), MI('$ID', FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Delete From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_CardProvide, FIn.FData]);
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
function TWorkerBusinessShipPro.GetPostProvideItems(var nData: string): Boolean;
var nStr: string;
    nBills: TLadingBillItems;
begin
  Result := False;

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
      nData := '磁卡[ %s ]当前状态为[ %s ],无法使用.';
      nData := Format(nData, [FIn.FData, CardStatusToStr(Fields[0].AsString)]);
      Exit;
    end;

    if Fields[1].AsString = sFlag_Yes then
    begin
      nData := '磁卡[ %s ]已被冻结,无法使用.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
  end;

  nStr := 'Select * From $CardProvide b Where P_Card=''$CD''';
  nStr := MacroValue(nStr, [MI('$CardProvide', sTable_CardProvide),
          MI('$CD', FIn.FData)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '磁卡号[ %s ]没有绑定车辆.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    SetLength(nBills, 1);
    with nBills[0] do
    begin
      FID         := FieldByName('R_ID').AsString;
      FZhiKa      := FieldByName('P_Order').AsString;
      FCusID      := FieldByName('P_CusID').AsString;
      FCusName    := FieldByName('P_CusName').AsString;
      FOrigin     := FieldByName('P_Origin').AsString;

      FType       := FieldByName('P_MType').AsString;
      FStockNo    := FieldByName('P_MID').AsString;
      FStockName  := FieldByName('P_MName').AsString;
      FValue      := FieldByName('P_LimVal').AsFloat;

      FCard       := FieldByName('P_Card').AsString;
      FTruck      := FieldByName('P_Truck').AsString;
      FCardKeep   := FieldByName('P_KeepCard').AsString;

      FMuiltiPound:= FieldByName('P_MuiltiPound').AsString;
      FOneDoor    := FieldByName('P_OneDoor').AsString;
      FMuiltiType := sFlag_No;
      //默认为首次过磅

      {$IFDEF RemoteSnap}
      FSnapTruck  := FieldByName('P_SnapTruck').AsString = sFlag_Yes;
      {$ENDIF}

      FStatus     := FieldByName('P_Status').AsString;
      FNextStatus := FieldByName('P_NextStatus').AsString;

      {$IFNDEF InFactOnlyOne}
      if (FStatus = sFlag_TruckNone) or (FNextStatus = sFlag_TruckIn) then      //原材料不进厂也可刷卡过磅
      begin
        FStatus := sFlag_TruckIn;
        FNextStatus := sFlag_TruckBFP;
      end;
      {$ENDIF}

      with FPData do
      begin
        FValue    := FieldByName('P_BFPValue').AsFloat;
        FDate     := FieldByName('P_BFPTime').AsDateTime;
        FOperator := FieldByName('P_BFPMan').AsString;
      end;

      with FMData do
      begin
        FValue    := FieldByName('P_BFMValue').AsFloat;
        FDate     := FieldByName('P_BFMTime').AsDateTime;
        FOperator := FieldByName('P_BFMMan').AsString;
      end;

      if (FMuiltiPound = sFlag_Yes) and
         FloatRelation(FMData.FValue, 0, rtGreater) then
      begin
        FMuiltiType := sFlag_Yes;
        //触发复磅业务

        with FPData do
        begin
          FValue    := FieldByName('P_BFPValue2').AsFloat;
          FDate     := FieldByName('P_BFPTime2').AsDateTime;
          FOperator := FieldByName('P_BFPMan2').AsString;
        end;

        with FMData do
        begin
          FValue    := FieldByName('P_BFMValue2').AsFloat;
          FDate     := FieldByName('P_BFMTime2').AsDateTime;
          FOperator := FieldByName('P_BFMMan2').AsString;
        end;
      end;

      FPoundID    := FieldByName('P_Pound').AsString;
      FExtID_2    := FieldByName('P_Order').AsString;
      FMemo       := FieldByName('P_Memo').AsString;

      if Assigned(FindField('P_Ship')) then
        FShip := FieldByName('P_Ship').AsString;

      if Assigned(FindField('P_PoundStation')) then
      begin
        FPoundStation := FieldByName('P_PoundStation').AsString;
        FPoundSName   := FieldByName('P_PoundName').AsString;
      end;

      FPreTruckP := FieldByName('P_UsePre').AsString = sFlag_Yes;
      if FPreTruckP then
      begin
        nStr := 'Select * From %s Where T_Truck=''%s''';
        nStr := Format(nStr, [sTable_Truck, FTruck]);

        with gDBConnManager.WorkerQuery(FDBConn, nStr) do
        if RecordCount > 0 then
        with FPData do
        begin
          FDate  := FieldByName('T_PrePTime').AsDateTime;
          FValue := FieldByName('T_PrePValue').AsFloat;
          FOperator  := FieldByName('T_PrePMan').AsString;

          if FValue < 0 then FPreTruckP := False;
        end;
      end;

      FPModel     := sFlag_PoundPD;
      FSelected   := True;
      //选中
    end;
  end;

  FOut.FData := CombineBillItmes(nBills);
  Result := True;
end;

//Date: 2014-09-18
//Parm: 交货单[FIn.FData];岗位[FIn.FExtParam]
//Desc: 保存指定岗位提交的交货单列表
function TWorkerBusinessShipPro.SavePostProvideItems(var nData: string): Boolean;
var nSQL,nStr,nYS,nNS,nWT,nPreYs: string;
    nInt, nIdx: Integer;
    nNet, nVal,nMValue,nMValueReal,nMValControl: Double;
    {$IFDEF HardMon}
    nReader: THHReaderItem;
    {$ENDIF}
    nPound: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  AnalyseBillItems(FIn.FData, nPound);
  nInt := Length(nPound);
  //解析数据
  nPreYs := '';

  if nInt < 1 then
  begin
    nData := '岗位[ %s ]提交的单据为空.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  if nInt > 1 then
  begin
    nData := '岗位[ %s ]提交了采购合单业务,该业务系统暂时不支持.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  {$IFDEF HardMon}
  if (FIn.FExtParam = sFlag_TruckBFP) or (FIn.FExtParam = sFlag_TruckBFM) then
  begin
    nYS := gHardwareHelper.GetReaderLastOn(nPound[0].FCard, nReader);

    if (nYS <> '') and (nReader.FGroup <> '') then
    begin
      nSQL := 'Select C_Group From %s Where C_Card=''%s''';
      nSQL := Format(nSQL, [sTable_Card, nPound[0].FCard]);
      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      begin
        if RecordCount < 1 then
        begin
          nData := '磁卡编号[ %s ]不匹配.';
          nData := Format(nData, [nPound[0].FCard]);
          Exit;
        end;

        nStr := UpperCase(Fields[0].AsString);
      end;

      if UpperCase(nReader.FGroup) <> nStr then
      begin
        nData := '磁卡号[ %s:::%s ]与读卡器[ %s:::%s ]分组匹配失败.';
        nData := Format(nData,[nPound[0].FCard, nStr, nReader.FID,
                 nReader.FGroup]);
        Exit;
      end;
    end;
  end;
  //过磅时，验证读卡器与卡片分组
  {$ENDIF}

  nStr := 'Select D_Value From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_StockIfYS]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
       nYS := Fields[0].AsString
  else nYS := sFlag_No;

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

  FListA.Clear;
  //用于存储SQL列表

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckIn then //进厂
  begin
    nSQL := MakeSQLByStr([
            SF('P_InTime', sField_SQLServer_Now, sfVal),
            SF('P_InMan', FIn.FBase.FFrom.FUser),
            SF('P_Status', sFlag_TruckIn),
            SF('P_NextStatus', sFlag_TruckBFP)
            ], sTable_CardProvide, SF('P_Card', nPound[0].FCard), False);
    FListA.Add(nSQL);
    {$IFDEF PurQueue}
    nSQL := 'Update %s Set T_InFact=%s Where T_Truck Like ''%%%s%%''';
    nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now,
            nPound[0].FTruck]);
    FListA.Add(nSQL);
    //更新队列车辆进厂状态
    {$ENDIF}
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFP then //称量皮重
  begin
    with nPound[0] do
    begin
      FStatus := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckXH;

      if (FListB.IndexOf(FStockNo) >= 0) or (nYS <> sFlag_Yes) then
        FNextStatus := sFlag_TruckBFM;
      //现场不发货直接过重

      if (FMuiltiPound = sFlag_Yes) and (FMuiltiType = sFlag_Yes) then
      begin  //复磅业务低第一次过磅
        FOut.FData := FPoundID;
        FNextStatus:= sFlag_TruckBFM;

        nSQL := MakeSQLByStr([
                SF('P_PValue2', FPData.FValue, sfVal),
                SF('P_PDate2', sField_SQLServer_Now, sfVal),
                SF('P_PMan2', FIn.FBase.FFrom.FUser),
                SF('P_PStation2', FPData.FStation),
                SF('P_Status', sFlag_TruckBFP)
                ], sTable_PoundLog, SF('P_ID', FPoundID), False);
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('P_Status', FStatus),
                SF('P_NextStatus', FNextStatus),

                SF('P_BFPValue2', FPData.FValue, sfVal),
                SF('P_BFPTime2', sField_SQLServer_Now, sfVal),
                SF('P_BFPMan2', FIn.FBase.FFrom.FUser)
                ], sTable_CardProvide, SF('P_Card', FCard), False);
        FListA.Add(nSQL);
      end else

      begin  //其他情况需要重新获取磅单号
        FListC.Clear;
        FListC.Values['Group'] := sFlag_BusGroup;
        FListC.Values['Object'] := sFlag_PoundID;

        if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
                FListC.Text, sFlag_Yes, @nOut) then
          raise Exception.Create(nOut.FData);
        //xxxxx

        FOut.FData := nOut.FData;
        //返回榜单号,用于拍照绑定

        nSQL := MakeSQLByStr([
                SF('P_ID', nOut.FData),
                SF('P_Type', sFlag_ShipPro),
                SF('P_Order', FZhiKa),
                SF('P_Truck', FTruck),
                SF('P_CusID', FCusID),
                SF('P_CusName', FCusName),
                SF('P_MID', FStockNo),
                SF('P_MName', FStockName),
                SF('P_MType', FType),
                SF('P_LimValue', 0),
                SF('P_PValue', FPData.FValue, sfVal),
                SF('P_PDate', sField_SQLServer_Now, sfVal),
                SF('P_PMan', FIn.FBase.FFrom.FUser),
                SF('P_FactID', FFactory),
                SF('P_Origin', FOrigin),
                SF('P_PStation', FPData.FStation),
                SF('P_Direction', '进厂'),
                SF('P_PModel', FPModel),
                SF('P_Status', sFlag_TruckBFP),
                SF('P_Valid', sFlag_Yes),
                SF('P_Memo', FMemo),
                {$IFDEF ProShip}
                SF('P_Ship', FShip),
                {$ENDIF}
                SF('P_PrintNum', 1, sfVal)
                ], sTable_PoundLog, '', True);
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('P_Status', FStatus),
                SF('P_NextStatus', FNextStatus),

                SF('P_Pound', nOut.FData),                    //磅单编号保存
                SF('P_BFPValue', FPData.FValue, sfVal),
                SF('P_BFPTime', sField_SQLServer_Now, sfVal),
                SF('P_BFPMan', FIn.FBase.FFrom.FUser)
                ], sTable_CardProvide, SF('P_Card', FCard), False);
        FListA.Add(nSQL);
      end;

      nSQL := MakeSQLByStr([
              SF('T_LastTime',sField_SQLServer_Now, sfVal)
              ], sTable_Truck, SF('T_Truck', FTruck), False);
      FListA.Add(nSQL);
      //更新车辆活动时间

      {$IFDEF PurQueue}
      nSQL := 'Update %s Set T_PDate=%s Where T_Truck Like ''%%%s%%''';
      nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now,
              nPound[0].FTruck]);
      FListA.Add(nSQL);
      //更新队列车辆进厂状态
      {$ENDIF}
    end;

  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckSH then //预置皮重
  begin
    with nPound[0] do
    begin
      FStatus := sFlag_TruckSH;
      FNextStatus := sFlag_TruckOut;

      {$IFDEF PrePTruckYs}
      FNextStatus := sFlag_TruckXH;
      if (FListB.IndexOf(FStockNo) >= 0) or (nYS <> sFlag_Yes) then
        FNextStatus := sFlag_TruckOut;
      {$ENDIF}

      if (FMuiltiPound = sFlag_Yes) and (FMuiltiType = sFlag_Yes) then
      begin  //复磅业务低第一次过磅
        FOut.FData := FPoundID;

        nSQL := MakeSQLByStr([
                SF('P_PValue2', FPData.FValue, sfVal),
                SF('P_PDate2', sField_SQLServer_Now, sfVal),
                SF('P_PMan2', FIn.FBase.FFrom.FUser),
                SF('P_PStation2', FPData.FStation),

                SF('P_MValue2', FMData.FValue, sfVal),
                SF('P_MDate2', sField_SQLServer_Now, sfVal),
                SF('P_MMan2', FIn.FBase.FFrom.FUser),
                SF('P_MStation2', FMData.FStation),
                SF('P_Status', sFlag_TruckBFP)
                ], sTable_PoundLog, SF('P_ID', FPoundID), False);
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('P_Status', FStatus),
                SF('P_NextStatus', FNextStatus),

                SF('P_BFPValue2', FPData.FValue, sfVal),
                SF('P_BFPTime2', sField_SQLServer_Now, sfVal),
                SF('P_BFPMan2', FIn.FBase.FFrom.FUser),
                SF('P_BFMValue2', FMData.FValue, sfVal),
                SF('P_BFMTime2', sField_SQLServer_Now, sfVal),
                SF('P_BFMMan2', FIn.FBase.FFrom.FUser)
                ], sTable_CardProvide, SF('P_Card', FCard), False);
        FListA.Add(nSQL);
      end else

      begin
        if FMuiltiPound = sFlag_Yes then
          FNextStatus := sFlag_TruckIn;

        FListC.Clear;
        FListC.Values['Group'] := sFlag_BusGroup;
        FListC.Values['Object'] := sFlag_PoundID;

        if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
                FListC.Text, sFlag_Yes, @nOut) then
          raise Exception.Create(nOut.FData);
        //xxxxx

        FOut.FData := nOut.FData;
        //返回榜单号,用于拍照绑定

        nSQL := MakeSQLByStr([
                SF('P_ID', nOut.FData),
                SF('P_Type', sFlag_ShipPro),
                SF('P_Order', FZhiKa),
                SF('P_Truck', FTruck),
                SF('P_CusID', FCusID),
                SF('P_CusName', FCusName),
                SF('P_MID', FStockNo),
                SF('P_MName', FStockName),
                SF('P_MType', FType),
                SF('P_LimValue', 0),

                SF('P_PValue', FPData.FValue, sfVal),
                SF('P_PDate', sField_SQLServer_Now, sfVal),
                SF('P_PMan', FIn.FBase.FFrom.FUser),
                SF('P_PStation', FPData.FStation),

                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', FMData.FStation),

                SF('P_FactID', FFactory),
                SF('P_Origin', FOrigin),
                SF('P_Direction', '进厂'),

                SF('P_PModel', FPModel),
                SF('P_Status', sFlag_TruckBFP),
                SF('P_Valid', sFlag_Yes),
                SF('P_PrintNum', 1, sfVal)
                ], sTable_PoundLog, '', True);
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('P_Status', FStatus),
                SF('P_NextStatus', FNextStatus),

                SF('P_Pound', nOut.FData),                    //磅单编号保存
                SF('P_BFPValue', FPData.FValue, sfVal),
                SF('P_BFPTime', sField_SQLServer_Now, sfVal),
                SF('P_BFPMan', FIn.FBase.FFrom.FUser),

                SF('P_BFMValue', FMData.FValue, sfVal),
                SF('P_BFMTime', sField_SQLServer_Now, sfVal),
                SF('P_BFMMan', FIn.FBase.FFrom.FUser)
                ], sTable_CardProvide, SF('P_Card', FCard), False);
        FListA.Add(nSQL);
      end;

      nSQL := MakeSQLByStr([
              SF('T_LastTime',sField_SQLServer_Now, sfVal)
              ], sTable_Truck, SF('T_Truck', FTruck), False);
      FListA.Add(nSQL);
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckXH then //验收现场
  begin
    with nPound[0] do
    begin
      if FPreTruckP then
      begin
        FStatus := sFlag_TruckXH;
        FNextStatus := sFlag_TruckOut;

        nStr := 'Select D_CusID,D_Value,D_Type From %s ' +
                'Where D_Stock=''%s'' And D_Valid=''%s''';
        nStr := Format(nStr, [sTable_Deduct, FStockNo, sFlag_Yes]);

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
            WriteLog('暗扣规则存在,暗扣量:' + FloatToStr(nVal) + '暗扣前毛重:' +
                     FloatToStr(FMData.FValue) + '暗扣前皮重:' + FloatToStr(FPData.FValue));
            if FMData.FValue > FPData.FValue then
                 FMData.FValue := (FMData.FValue*1000 - nVal*1000) / 1000
            else FPData.FValue := (FPData.FValue*1000 - nVal*1000) / 1000;
            WriteLog('暗扣后毛重:' + FloatToStr(FMData.FValue) +
                     '暗扣后皮重:' + FloatToStr(FPData.FValue));
          end;
        end;

        nStr := SF('P_ID', FPoundID);
        //where
        nSQL := MakeSQLByStr([
                SF('P_YTime', sField_SQLServer_Now, sfVal),
                SF('P_YMan', FIn.FBase.FFrom.FUser),
                SF('P_YSResult', FYSValid),
                SF('P_YLineName', FSeal),    //保存批次号
                SF('P_KZComment', FKZComment), //扣杂原因
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_KZValue', FKZValue, sfVal)
                ], sTable_PoundLog, nStr, False);
        //验收扣杂
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('P_Status', FStatus),
                SF('P_NextStatus', FNextStatus)
                ], sTable_CardProvide,  SF('P_Card', FCard), False);
        FListA.Add(nSQL);

        nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
        nStr := Format(nStr, [sTable_SysDict, sFlag_OutByPreYs, FStockNo]);
        with gDBConnManager.WorkerQuery(FDBConn, nStr) do
        if RecordCount > 0 then
             nPreYs := Fields[0].AsString
        else nPreYs := sFlag_No;

        if nPreYs = sFlag_Yes then//验收后直接出厂
        begin
          with nPound[0] do
          begin
            if FCardKeep = sFlag_ProvCardG then
            begin
              nSQL := 'Update %s Set P_Pound=NULL,' +
                      'P_BFPTime=NULL,P_BFPMan=NULL,P_BFPValue=0,' +
                      'P_BFMTime=NULL,P_BFMMan=NULL,P_BFMValue=0,' +
                      'P_BFPTime2=NULL,P_BFPMan2=NULL,P_BFPValue2=0,' +
                      'P_BFMTime2=NULL,P_BFMMan2=NULL,P_BFMValue2=0,' +
                      'P_Status=''%s'', P_NextStatus=''%s'' ' +
                      'Where P_Card=''%s''';
              nSQL := Format(nSQL, [sTable_CardProvide, sFlag_TruckNone,
                      sFlag_TruckNone, FCard]);
              FListA.Add(nSQL);
            end else

            begin
              nSQL := 'Update %s Set C_Status=''%s'', C_TruckNo=NULL Where C_Card=''%s''';
              nSQL := Format(nSQL, [sTable_Card, sFlag_CardIdle, FCard]);
              FListA.Add(nSQL);

              nSQL := 'Update %s Set P_Pound=NULL, P_Card=NULL, ' +
                      'P_Status=''%s'', P_NextStatus=NULL ' +
                      'Where P_Card=''%s''';
              nSQL := Format(nSQL, [sTable_CardProvide, sFlag_TruckOut,
                      FCard]);
              FListA.Add(nSQL);
            end;

            FListC.Clear;
            FListC.Values['DLID']  := FPoundID;
            FListC.Values['MType'] := sFlag_Provide;
            FListC.Values['BillType'] := IntToStr(cMsg_WebChat_BillFinished);
            TWorkerBusinessCommander.CallMe(cBC_WebChat_DLSaveShopInfo,
             PackerEncodeStr(FListC.Text), '', @nOut);
            //保存同步信息
          end;
        end;
        {$IFDEF PurQueue}
        nSQL := 'Delete from %s Where T_Truck Like ''%%%s%%''';
        nSQL := Format(nSQL, [sTable_ZTTrucks, nPound[0].FTruck]);
        FListA.Add(nSQL);
        {$ENDIF}
      end
      else
      begin
        FStatus := sFlag_TruckXH;
        FNextStatus := sFlag_TruckBFM;

        nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
        nStr := Format(nStr, [sTable_SysDict, sFlag_ForceAddWater, FStockNo]);
        with gDBConnManager.WorkerQuery(FDBConn, nStr) do
        if RecordCount > 0 then
             nWT := Fields[0].AsString
        else nWT := sFlag_No;

        if nWT = sFlag_Yes then
          FNextStatus := sFlag_TruckWT;
        //强制加水业务  

        nStr := SF('P_ID', FPoundID);
        //where
        nSQL := MakeSQLByStr([
                SF('P_YTime', sField_SQLServer_Now, sfVal),
                SF('P_YMan', FIn.FBase.FFrom.FUser),
                SF('P_YSResult', FYSValid),
                SF('P_YLineName', FSeal),    //保存批次号
                SF('P_KZComment', FKZComment), //扣杂原因
                SF('P_KZValue', FKZValue, sfVal)
                ], sTable_PoundLog, nStr, False);
        //验收扣杂
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('P_Status', FStatus),
                SF('P_NextStatus', FNextStatus)
                ], sTable_CardProvide,  SF('P_Card', FCard), False);
        FListA.Add(nSQL);
      end;
    end;
  end else

  if FIn.FExtParam = sFlag_TruckWT then //验收现场
  begin
    with nPound[0] do
    begin
      FStatus := sFlag_TruckWT;
      FNextStatus := sFlag_TruckBFM;

      nStr := SF('P_ID', FPoundID);
      //where
      nSQL := MakeSQLByStr([
              SF('P_WTTime', sField_SQLServer_Now, sfVal),
              SF('P_WTMan', FIn.FBase.FFrom.FUser),
              SF('P_WTLine', FMemo)
              ], sTable_PoundLog, nStr, False);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('P_Status', FStatus),
              SF('P_NextStatus', FNextStatus)
              ], sTable_CardProvide,  SF('P_Card', FCard), False);
      FListA.Add(nSQL);
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFM then //称量毛重
  begin
    with nPound[0] do
    begin
      FOut.FData := FPoundID;

      nStr := 'Select D_CusID,D_Value,D_Type From %s ' +
              'Where D_Stock=''%s'' And D_Valid=''%s''';
      nStr := Format(nStr, [sTable_Deduct, FStockNo, sFlag_Yes]);

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

          if FMData.FValue > FPData.FValue then
               FMData.FValue := (FMData.FValue*1000 - nVal*1000) / 1000
          else FPData.FValue := (FPData.FValue*1000 - nVal*1000) / 1000;
        end;
      end;

      {$IFDEF AutoSaveTruckP}
      nStr := MakeSQLByStr([SF('T_PrePValue', FPData.FValue, sfVal),
              SF('T_PrePTime', sField_SQLServer_Now, sfVal),
              SF('T_PrePMan', FIn.FBase.FFrom.FUser)],
              sTable_Truck, SF('T_Truck', FTruck), False);
      FListA.Add(nSQL);
      //预置皮重
      {$ENDIF}

       nStr := SF('P_ID', FPoundID);
      //磅单编号

      if (FMuiltiPound = sFlag_Yes) and (FMuiltiType = sFlag_Yes) then
      begin //复磅业务的第二次过磅
        if FNextStatus = sFlag_TruckBFP then
        begin
          nSQL := MakeSQLByStr([
                  SF('P_PValue2', FPData.FValue, sfVal),
                  SF('P_PDate2', sField_SQLServer_Now, sfVal),
                  SF('P_PMan2', FIn.FBase.FFrom.FUser),
                  SF('P_PStation2', FPData.FStation),
                  SF('P_MValue2', FMData.FValue, sfVal),
                  SF('P_MDate2', DateTime2Str(FMData.FDate)),
                  SF('P_MMan2', FMData.FOperator),
                  SF('P_MStation2', FMData.FStation)
                  ], sTable_PoundLog, nStr, False);
          //称重时,由于皮重大,交换皮毛重数据
          FListA.Add(nSQL);

          nSQL := MakeSQLByStr([
                  SF('P_Status', sFlag_TruckBFM),
                  SF('P_NextStatus', sFlag_TruckOut),
                  SF('P_BFPValue2', FPData.FValue, sfVal),
                  SF('P_BFPTime2', sField_SQLServer_Now, sfVal),
                  SF('P_BFPMan2', FIn.FBase.FFrom.FUser),
                  SF('P_BFMValue2', FMData.FValue, sfVal),
                  SF('P_BFMTime2', DateTime2Str(FMData.FDate)),
                  SF('P_BFMMan2', FMData.FOperator)
                ], sTable_CardProvide, SF('P_Card', FCard), False);
          FListA.Add(nSQL);

        end else
        begin
          nSQL := MakeSQLByStr([
                  SF('P_MValue2', FMData.FValue, sfVal),
                  SF('P_MDate2', sField_SQLServer_Now, sfVal),
                  SF('P_MMan2', FIn.FBase.FFrom.FUser),
                  SF('P_MStation2', FMData.FStation)
                  ], sTable_PoundLog, nStr, False);
          //xxxxx
          FListA.Add(nSQL);
        
          nSQL := MakeSQLByStr([
                SF('P_Status', sFlag_TruckBFM),
                SF('P_NextStatus', sFlag_TruckOut),
                SF('P_BFMValue2', FMData.FValue, sfVal),
                SF('P_BFMTime2', sField_SQLServer_Now, sfVal),
                SF('P_BFMMan2', FIn.FBase.FFrom.FUser)
                ], sTable_CardProvide, SF('P_Card', FCard), False);
          FListA.Add(nSQL);
        end;
      end else

      begin
        nNS := sFlag_TruckOut;
        if (FMuiltiPound = sFlag_Yes) and (FMuiltiType <> sFlag_Yes) then
          nNS := sFlag_TruckIn;
        //必须再次进厂过磅  

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
                  ], sTable_PoundLog, nStr, False);
          //称重时,由于皮重大,交换皮毛重数据
          FListA.Add(nSQL);

          nSQL := MakeSQLByStr([
                  SF('P_Status', sFlag_TruckBFM),
                  SF('P_NextStatus', nNS),
                  SF('P_BFPValue', FPData.FValue, sfVal),
                  SF('P_BFPTime', sField_SQLServer_Now, sfVal),
                  SF('P_BFPMan', FIn.FBase.FFrom.FUser),
                  SF('P_BFMValue', FMData.FValue, sfVal),
                  SF('P_BFMTime', DateTime2Str(FMData.FDate)),
                  SF('P_BFMMan', FMData.FOperator)
                  ], sTable_CardProvide, SF('P_Card', FCard), False);
          FListA.Add(nSQL);

        end else
        begin
          nSQL := MakeSQLByStr([
                  SF('P_MValue', FMData.FValue, sfVal),
                  SF('P_MDate', sField_SQLServer_Now, sfVal),
                  SF('P_MMan', FIn.FBase.FFrom.FUser),
                  SF('P_MStation', FMData.FStation)
                  ], sTable_PoundLog, nStr, False);
          //xxxxx
          FListA.Add(nSQL);
        
          nSQL := MakeSQLByStr([
                SF('P_Status', sFlag_TruckBFM),
                SF('P_NextStatus', nNS),
                SF('P_BFMValue', FMData.FValue, sfVal),
                SF('P_BFMTime', sField_SQLServer_Now, sfVal),
                SF('P_BFMMan', FIn.FBase.FFrom.FUser)
                ], sTable_CardProvide, SF('P_Card', FCard), False);
          FListA.Add(nSQL);
        end;
      end;

      nSQL := MakeSQLByStr([
              SF('T_LastTime',sField_SQLServer_Now, sfVal)
              ], sTable_Truck, SF('T_Truck', FTruck), False);
      FListA.Add(nSQL);
      //更新车辆活动时间
      {$IFDEF PurQueue}
      nSQL := 'Delete from %s Where T_Truck Like ''%%%s%%''';
      nSQL := Format(nSQL, [sTable_ZTTrucks, nPound[0].FTruck]);
      FListA.Add(nSQL);
      {$ENDIF}

      {$IFDEF JINLEINF}
      begin
        nMValueReal := 0;
        nMValue := 0;
        nMValControl := 0;

        nMValueReal := FMData.FValue;

        if nMValueReal > 0 then
        begin
          nSQL := 'Select T_CzType, D_ParamA,D_ParamB From %s left join %s on T_CzType = D_Value ' +
                  ' where D_Name = ''%s'' and T_Truck=''%s'' ';
          nSQL := Format(nSQL, [sTable_Truck, sTable_SysDict, sFlag_TruckType, FTruck]);

          WriteLog('查询限载重量SQL:' + nSQL);
          with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
          if RecordCount > 0 then
          begin
            if FieldByName('T_CzType').AsString <> '' then
            begin
              nMValControl := Fields[1].AsFloat;
              nMValue := Fields[2].AsFloat;
            end;
          end;

          if (nMValControl > 0) and (nMValue > 0) and (nMValueReal >= nMValControl) then
          begin
            nSQL := 'update %s set P_MValue=%.2f, P_MValueReal=%.2f where P_ID=''%s''';
            nSQL := format(nSQL,[sTable_PoundLog, nMValue, nMValueReal, FPoundID]);
            WriteLog('更新限载毛重SQL:' + nSQL);
            WriteLog('磅单[ ' + FPoundID + ' ]毛重调整:实际毛重[ ' + FloatToStr(nMValueReal) + ']' + '--' + '调整为[ '
                     + FloatToStr(nMValue) + ' ]');
            FListA.Add(nSQL);
          end;
        end;
      end;
      {$ENDIF}
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckOut then //出厂
  begin
    with nPound[0] do
    begin
      if FCardKeep = sFlag_ProvCardG then
      begin
        nSQL := 'Update %s Set P_Pound=NULL,' +
                'P_BFPTime=NULL,P_BFPMan=NULL,P_BFPValue=0,' +
                'P_BFMTime=NULL,P_BFMMan=NULL,P_BFMValue=0,' +
                'P_BFPTime2=NULL,P_BFPMan2=NULL,P_BFPValue2=0,' +
                'P_BFMTime2=NULL,P_BFMMan2=NULL,P_BFMValue2=0,' +
                'P_Status=''%s'', P_NextStatus=''%s'' ' +
                'Where P_Card=''%s''';
        nSQL := Format(nSQL, [sTable_CardProvide, sFlag_TruckNone,
                sFlag_TruckNone, FCard]);
        FListA.Add(nSQL);
      end else

      begin
        nSQL := 'Update %s Set C_Status=''%s'', C_TruckNo=NULL Where C_Card=''%s''';
        nSQL := Format(nSQL, [sTable_Card, sFlag_CardIdle, FCard]);
        FListA.Add(nSQL);

        nSQL := 'Update %s Set P_Pound=NULL, P_Card=NULL, ' +
                'P_Status=''%s'', P_NextStatus=NULL ' +
                'Where P_Card=''%s''';
        nSQL := Format(nSQL, [sTable_CardProvide, sFlag_TruckOut,
                FCard]);
        FListA.Add(nSQL);
      end;

      {$IFNDEF SyncDataByBFM}
      if not TWorkerBusinessCommander.CallMe(cBC_SyncME03,
          FPoundID, '', @nOut) then
        raise Exception.Create(nOut.FData);
      //同步供应到NC榜单
      {$ENDIF}

      FListC.Clear;
      FListC.Values['DLID']  := FPoundID;
      FListC.Values['MType'] := sFlag_Provide;
      FListC.Values['BillType'] := IntToStr(cMsg_WebChat_BillFinished);
      TWorkerBusinessCommander.CallMe(cBC_WebChat_DLSaveShopInfo,
       PackerEncodeStr(FListC.Text), '', @nOut);
      //保存同步信息
    end;
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

  if nPreYs = sFlag_Yes then
  begin
    {$IFNDEF SyncDataByBFM}
    if not TWorkerBusinessCommander.CallMe(cBC_SyncME03,
        nPound[0].FPoundID, '', @nOut) then
      raise Exception.Create(nOut.FData);
    //同步供应到NC榜单
    {$ENDIF}
  end
  else
  begin
    if (FIn.FExtParam = sFlag_TruckSH)
    and (nPound[0].FNextStatus = sFlag_TruckOut) then
    begin
      if Assigned(gHardShareData) then
      begin
        {$IFDEF AutoOutByStokNo}
        nSQL := 'Select D_Value From %s Where D_Name=''AutoOutStock'' and D_Value=''%s''';
        nSQL := Format(nSQL, [sTable_SysDict, nPound[0].FStockNo]);

        with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
        if RecordCount > 0 then
        begin
          gHardShareData('TruckSH:' + nPound[0].FCard);
          //磅房处理自动出厂
          WriteLog('磅房根据物料号处理自动出厂');
        end;
        {$ELSE}
          gHardShareData('TruckSH:' + nPound[0].FCard);
          //单次过磅自动出厂
          WriteLog('磅房处理自动出厂');
        {$ENDIF}
      end;
    end;

    if (FIn.FExtParam = sFlag_TruckXH)
    and (nPound[0].FNextStatus = sFlag_TruckOut) then
    begin
      if Assigned(gHardShareData) then
      begin
        {$IFDEF AutoOutByStokNo}
        nSQL := 'Select D_Value From %s Where D_Name=''AutoOutStock'' and D_Value=''%s''';
        nSQL := Format(nSQL, [sTable_SysDict, nPound[0].FStockNo]);

        with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
        if RecordCount > 0 then
        begin
          gHardShareData('TruckSH:' + nPound[0].FCard);
          //磅房处理自动出厂
          WriteLog('磅房根据物料号处理自动出厂');
        end;
        {$ELSE}
          gHardShareData('TruckSH:' + nPound[0].FCard);
          //单次过磅自动出厂
          WriteLog('磅房处理自动出厂');
        {$ENDIF}
      end;
    end;
  end;

  if FIn.FExtParam = sFlag_TruckBFM then
  begin
    if Assigned(gHardShareData) then
    begin
      {$IFDEF AutoOutByStokNo}
      nSQL := 'Select D_Value From %s Where D_Name=''AutoOutStock'' and D_Value=''%s''';
      nSQL := Format(nSQL, [sTable_SysDict, nPound[0].FStockNo]);

      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if RecordCount > 0 then
      begin
        gHardShareData('TruckOut:' + nPound[0].FCard);
        //磅房处理自动出厂
        WriteLog('磅房根据物料号处理自动出厂');
      end;
      {$ELSE}
        gHardShareData('TruckOut:' + nPound[0].FCard);
        //磅房处理自动出厂
        WriteLog('磅房处理自动出厂');
      {$ENDIF}
    end;
  end;

  {$IFDEF SyncDataByBFM}
  if FIn.FExtParam = sFlag_TruckBFM then
  begin
    with nPound[0] do
    begin
      TWorkerBusinessCommander.CallMe(cBC_SyncME03,
          FPoundID, '', @nOut);
      //同步供应到NC榜单
    end;
  end;
  {$ENDIF}
end;

//Date: 2014-09-15
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
class function TWorkerBusinessShipPro.CallMe(const nCmd: Integer;
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

function TWorkerBusinessShipPro.VerifyPTruckCount(const nPID,
  nStockNo: string; var nHint: string): Boolean;
var nStr: string;
    nCount, nCountSet : Integer;
    nBDate, nEDate: string;
begin
  Result := True;
  nHint := '';
  nStr := 'Select * From %s Where C_CusName=''%s''';
  nStr := Format(nStr, [sTable_PTruckControl, sFlag_PTruckControl]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <= 0 then
      Exit;
    WriteLog('原材料进厂车辆数量总控制:' + FieldByName('C_Valid').AsString);
    if FieldByName('C_Valid').AsString <> sFlag_Yes then
      Exit;
  end;

  nCount := 0;
  nCountSet := 0;

  nStr := 'Select * From %s Where C_CusID=''%s'' and C_StockNo=''%s'' and C_Valid=''%s''';
  nStr := Format(nStr, [sTable_PTruckControl, nPID, nStockNo, sFlag_Yes]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <= 0 then
    begin
      WriteLog('供应商' + nPID + '原材料'+ nStockNo + '未配置限定规则或规则未启用');
      Exit;
    end;
    nCountSet := FieldByName('C_Count').AsInteger;
    WriteLog('原材料进厂车辆数量控制:' + FieldByName('C_Count').AsString);
  end;

  nBDate := FormatDateTime('YYYY-MM-DD', Now) + ' 00:00:00';
  nEDate := FormatDateTime('YYYY-MM-DD', Now) + ' 23:59:59';

  nStr := 'Select Count(*) as P_Count From %s Where P_CusID=''%s'' and P_MID=''%s'' '
         +'And (P_Date>=''%s'' and P_Date <=''%s'')';
  nStr := Format(nStr, [sTable_CardProvide, nPID, nStockNo, nBDate, nEDate]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <= 0 then
    begin
      Exit;
    end;
    nCount := FieldByName('P_Count').AsInteger;

    if (nCount > 0) and (nCount >= nCountSet) then
    begin
      nHint := '供应商' + nPID + '原材料'+ nStockNo
               + '当前已开单数量' + IntToStr(nCount)
               + '超出日进厂设定数量' + IntToStr(nCountSet) + '无法开单';
      WriteLog(nHint);
      Result := False;
    end;
  end;
end;

function TWorkerBusinessShipPro.VerifyPTime(const nStockNo: string; var nHint: string): Boolean;
var nStr: string;
    nBDate, nEDate: string;
begin
  Result := True;
  nHint := '';
  nStr := 'Select * From %s Where X_StockName=''%s''';
  nStr := Format(nStr, [sTable_PTimeControl, sFlag_PTimeControlTotal]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <= 0 then
      Exit;
    WriteLog('原材料进厂时间总控制:' + FieldByName('X_Valid').AsString);
    if FieldByName('X_Valid').AsString <> sFlag_Yes then
      Exit;
  end;

  nStr := 'Select * From %s Where X_StockNo=''%s'' and X_Valid=''%s''';
  nStr := Format(nStr, [sTable_PTimeControl, nStockNo, sFlag_Yes]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <= 0 then
    begin
      WriteLog('原材料'+ nStockNo + '未配置限定规则或规则未启用');
      Exit;
    end;
    WriteLog('原材料进厂时间控制:' + FieldByName('X_BeginTime').AsString
            + '-->' + FieldByName('X_EndTime').AsString);
    nBDate := FormatDateTime('YYYY-MM-DD', Now) + ' ' + FieldByName('X_BeginTime').AsString;
    nEDate := FormatDateTime('YYYY-MM-DD', Now) + ' ' + FieldByName('X_EndTime').AsString;

    try
      if (Now < StrToDateTime(nBDate)) or (Now > StrToDateTime(nEDate)) then
      begin
        nHint := '原材料'+ nStockNo
                 + '允许办卡时间段:' + FieldByName('X_BeginTime').AsString
                 + '-->' + FieldByName('X_EndTime').AsString + '当前时间无法开单';
        WriteLog(nHint);
        Result := False;
      end;
    except
    end;
  end;
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessShipPro, sPlug_ModuleBus);
end.

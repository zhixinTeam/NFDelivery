{*******************************************************************************
  作者: fendou116688@163.com 2017/6/2
  描述: 复磅临时业务
*******************************************************************************}
unit UWorkerBusinessShipTmp;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, UWorkerBusinessCommand
  {$IFDEF HardMon}, UMgrHardHelper, UWorkerHardware{$ENDIF};

type
  TWorkerBusinessShipTmp = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton

    function SaveCardOther(var nData: string): Boolean;
    function DeleteCardOther(var nData: string): Boolean;
    //倒运磁卡办理及删除

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
class function TWorkerBusinessShipTmp.FunctionName: string;
begin
  Result := sBus_BusinessShipTmp;
end;

constructor TWorkerBusinessShipTmp.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessShipTmp.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TWorkerBusinessShipTmp.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessShipTmp.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2015-8-5
//Parm: 输入数据
//Desc: 执行nData业务指令
function TWorkerBusinessShipTmp.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;

  case FIn.FCommand of
   cBC_SaveBills         : Result := SaveCardOther(nData);
   cBC_DeleteBill        : Result := DeleteCardOther(nData);
   cBC_GetPostBills      : Result := GetPostProvideItems(nData);
   cBC_SavePostBills     : Result := SavePostProvideItems(nData);
   else
    begin
      Result := False;
      nData := '无效的业务代码(Invalid Command).';
    end;
  end;
end;

function TWorkerBusinessShipTmp.SaveCardOther(var nData: string): Boolean;
var nStr, nTruck: string;
    nOut: TWorkerBusinessCommand;
begin
  FListA.Text := PackerDecodeStr(FIn.FData);
  nTruck := FListA.Values['Truck'];
  //init card

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

    nStr := 'Update %s Set O_Card=NULL Where O_Card=''%s''';
    nStr := Format(nStr, [sTable_CardOther, FListA.Values['Card']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //正在使用的临时业务卡

    nStr := MakeSQLByStr([
            SF('O_Origin', FListA.Values['Origin']),     //NC来源,矿点
            SF('O_CusID', FListA.Values['ProID']),       //NC供应商ID
            SF('O_CusName', FListA.Values['ProName']),   //NC供应商名称
            SF('O_CusPY', GetPinYinOfStr(FListA.Values['ProName'])),

            SF('O_MType', sFlag_San),
            SF('O_MID', FListA.Values['StockNo']),
            SF('O_MName', FListA.Values['StockName']),

            SF('O_Memo', FListA.Values['Memo']),
            SF('O_Card', FListA.Values['Card']),
            SF('O_KeepCard', FListA.Values['CardType']),

            SF('O_MuiltiPound', FListA.Values['Muilti']),
            SF('O_OneDoor', FListA.Values['TruckBack']),
            SF('O_OutDoor', FListA.Values['TruckOut']),
            SF('O_UsePre', FListA.Values['TruckPre']),
            {$IFDEF FORCEPSTATION}
            SF('O_PoundStation', FListA.Values['PoundStation']),
            SF('O_PoundName', FListA.Values['PoundName']),
            {$ENDIF}

            SF('O_Truck', nTruck),
            SF('O_Status', sFlag_TruckNone),
            SF('O_Man', FIn.FBase.FFrom.FUser),
            SF('O_Date', sField_SQLServer_Now, sfVal)
            ], sTable_CardOther, '', True);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Select Count(*) From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FListA.Values['Card']]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if Fields[0].AsInteger < 1 then
    begin
      nStr := MakeSQLByStr([SF('C_Card', FListA.Values['Card']),
              SF('C_Group', FListA.Values['CardType']),
              SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_ShipTmp),
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
              SF('C_Used', sFlag_ShipTmp),
              SF('C_Freeze', sFlag_No),
              SF('C_TruckNo', nTruck),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, nStr, False);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;
    //更新磁卡状态

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
function TWorkerBusinessShipTmp.DeleteCardOther(var nData: string): Boolean;
var nStr,nP: string;
    nIdx: Integer;
begin
  FDBConn.FConn.BeginTrans;
  try
    //--------------------------------------------------------------------------
    nStr := 'Select O_Card From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_CardOther, FIn.FData]);
    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if (RecordCount > 0) And (Fields[0].AsString <> '') then
    begin
      nStr := 'Update %s set C_TruckNo=Null,C_Status=''%s'' Where C_Card=''%s''';
      nStr := Format(nStr, [sTable_Card, sFlag_CardIdle, Fields[0].AsString]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;
    //注销磁卡

    nStr := Format('Select * From %s Where 1<>1', [sTable_CardOther]);
    //only for fields
    nP := '';

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      for nIdx:=0 to FieldCount - 1 do
       if (Fields[nIdx].DataType <> ftAutoInc) and
          (Pos('O_Del', Fields[nIdx].FieldName) < 1) then
        nP := nP + Fields[nIdx].FieldName + ',';
      //所有字段,不包括删除

      System.Delete(nP, Length(nP), 1);
    end;

    nStr := 'Insert Into $OB($FL,O_DelMan,O_DelDate) ' +
            'Select $FL,''$User'',$Now From $OO Where R_ID=$ID';
    nStr := MacroValue(nStr, [MI('$OB', sTable_CardOtherBak),
            MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
            MI('$Now', sField_SQLServer_Now),
            MI('$OO', sTable_CardOther), MI('$ID', FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Delete From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_CardOther, FIn.FData]);
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
function TWorkerBusinessShipTmp.GetPostProvideItems(var nData: string): Boolean;
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

  nStr := 'Select * From $CardOther b Where O_Card=''$CD''';
  nStr := MacroValue(nStr, [MI('$CardOther', sTable_CardOther),
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
      FCusID      := FieldByName('O_CusID').AsString;
      FCusName    := FieldByName('O_CusName').AsString;
      FOrigin     := FieldByName('O_Origin').AsString;

      FType       := FieldByName('O_MType').AsString;
      FStockNo    := FieldByName('O_MID').AsString;
      FStockName  := FieldByName('O_MName').AsString;
      FValue      := 0;

      FCard       := FieldByName('O_Card').AsString;
      FTruck      := FieldByName('O_Truck').AsString;
      FCardKeep   := FieldByName('O_KeepCard').AsString;

      FMuiltiPound:= FieldByName('O_MuiltiPound').AsString;
      FOneDoor    := FieldByName('O_OneDoor').AsString;
      FOutDoor    := FieldByName('O_OutDoor').AsString;
      FMuiltiType := sFlag_No;
      //默认为首次过磅

      FStatus     := FieldByName('O_Status').AsString;
      FNextStatus := FieldByName('O_NextStatus').AsString;
      if (FStatus = sFlag_TruckNone) or (FNextStatus = sFlag_TruckIn) then      //临时业务不进厂也可刷卡过磅
      begin
        FStatus := sFlag_TruckIn;
        FNextStatus := sFlag_TruckBFP;
      end;

      with FPData do
      begin
        FValue    := FieldByName('O_BFPValue').AsFloat;
        FDate     := FieldByName('O_BFPTime').AsDateTime;
        FOperator := FieldByName('O_BFPMan').AsString;
      end;

      with FMData do
      begin
        FValue    := FieldByName('O_BFMValue').AsFloat;
        FDate     := FieldByName('O_BFMTime').AsDateTime;
        FOperator := FieldByName('O_BFMMan').AsString;
      end;

      if (FMuiltiPound = sFlag_Yes) and
         FloatRelation(FMData.FValue, 0, rtGreater) then
      begin
        FMuiltiType := sFlag_Yes;
        //触发复磅业务
        
        with FPData do
        begin
          FValue    := FieldByName('O_BFPValue2').AsFloat;
          FDate     := FieldByName('O_BFPTime2').AsDateTime;
          FOperator := FieldByName('O_BFPMan2').AsString;
        end;

        with FMData do
        begin
          FValue    := FieldByName('O_BFMValue2').AsFloat;
          FDate     := FieldByName('O_BFMTime2').AsDateTime;
          FOperator := FieldByName('O_BFMMan2').AsString;
        end;
      end;

      FPoundID    := FieldByName('O_Pound').AsString;
      FMemo       := FieldByName('O_Memo').AsString;

      if Assigned(FindField('O_PoundStation')) then
      begin
        FPoundStation := FieldByName('O_PoundStation').AsString;
        FPoundSName   := FieldByName('O_PoundName').AsString;
      end;  

      FPreTruckP := FieldByName('O_UsePre').AsString = sFlag_Yes;
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
function TWorkerBusinessShipTmp.SavePostProvideItems(var nData: string): Boolean;
var nSQL,nStr,nYS,nNS: string;
    nInt, nIdx: Integer;
    nNet, nVal: Double;
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

  if nInt < 1 then
  begin
    nData := '岗位[ %s ]提交的单据为空.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  if nInt > 1 then
  begin
    nData := '岗位[ %s ]提交了临时合单业务,该业务系统暂时不支持.';
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

  FListA.Clear;
  //用于存储SQL列表

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckIn then //进厂
  begin
    nSQL := MakeSQLByStr([
            SF('O_InTime', sField_SQLServer_Now, sfVal),
            SF('O_InMan', FIn.FBase.FFrom.FUser),
            SF('O_Status', sFlag_TruckIn),
            SF('O_NextStatus', sFlag_TruckBFP)
            ], sTable_CardOther, SF('O_Card', nPound[0].FCard), False);
    FListA.Add(nSQL);
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFP then //称量皮重
  begin
    with nPound[0] do
    begin
      FStatus := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckBFM;

      if (FMuiltiPound = sFlag_Yes) and (FMuiltiType = sFlag_Yes) then
      begin  //复磅业务低第一次过磅
        FOut.FData := FPoundID;

        nSQL := MakeSQLByStr([
                SF('P_PValue2', FPData.FValue, sfVal),
                SF('P_PDate2', sField_SQLServer_Now, sfVal),
                SF('P_PMan2', FIn.FBase.FFrom.FUser),
                SF('P_PStation2', FPData.FStation),
                SF('P_Status', sFlag_TruckBFP)
                ], sTable_PoundLog, SF('P_ID', FPoundID), False);
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('O_Status', FStatus),
                SF('O_NextStatus', FNextStatus),

                SF('O_BFPValue2', FPData.FValue, sfVal),
                SF('O_BFPTime2', sField_SQLServer_Now, sfVal),
                SF('O_BFPMan2', FIn.FBase.FFrom.FUser)
                ], sTable_CardOther, SF('O_Card', FCard), False);
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
                SF('P_Type', sFlag_ShipTmp),
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
                SF('P_Direction', '临时'),
                SF('P_PModel', FPModel),
                SF('P_Status', sFlag_TruckBFP),
                SF('P_Valid', sFlag_Yes),
                SF('P_Memo', FMemo),
                SF('P_PrintNum', 1, sfVal)
                ], sTable_PoundLog, '', True);
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('O_Status', FStatus),
                SF('O_NextStatus', FNextStatus),

                SF('O_Pound', nOut.FData),                    //磅单编号保存
                SF('O_BFPValue', FPData.FValue, sfVal),
                SF('O_BFPTime', sField_SQLServer_Now, sfVal),
                SF('O_BFPMan', FIn.FBase.FFrom.FUser)
                ], sTable_CardOther, SF('O_Card', FCard), False);
        FListA.Add(nSQL);
      end;

      nSQL := MakeSQLByStr([
              SF('T_LastTime',sField_SQLServer_Now, sfVal)
              ], sTable_Truck, SF('T_Truck', FTruck), False);
      FListA.Add(nSQL);
      //更新车辆活动时间
    end;

  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckSH then //预置皮重
  begin
    with nPound[0] do
    begin
      FStatus := sFlag_TruckSH;
      FNextStatus := sFlag_TruckOut;

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
                SF('O_Status', FStatus),
                SF('O_NextStatus', FNextStatus),

                SF('O_BFPValue2', FPData.FValue, sfVal),
                SF('O_BFPTime2', sField_SQLServer_Now, sfVal),
                SF('O_BFPMan2', FIn.FBase.FFrom.FUser),
                SF('O_BFMValue2', FMData.FValue, sfVal),
                SF('O_BFMTime2', sField_SQLServer_Now, sfVal),
                SF('O_BFMMan2', FIn.FBase.FFrom.FUser)
                ], sTable_CardOther, SF('O_Card', FCard), False);
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
                SF('P_Type', sFlag_ShipTmp),
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
                SF('O_Status', FStatus),
                SF('O_NextStatus', FNextStatus),

                SF('O_Pound', nOut.FData),                    //磅单编号保存
                SF('O_BFPValue', FPData.FValue, sfVal),
                SF('O_BFPTime', sField_SQLServer_Now, sfVal),
                SF('O_BFPMan', FIn.FBase.FFrom.FUser),

                SF('O_BFMValue', FMData.FValue, sfVal),
                SF('O_BFMTime', sField_SQLServer_Now, sfVal),
                SF('O_BFMMan', FIn.FBase.FFrom.FUser)
                ], sTable_CardOther, SF('O_Card', FCard), False);
        FListA.Add(nSQL);
      end;

      nSQL := MakeSQLByStr([
              SF('T_LastTime',sField_SQLServer_Now, sfVal)
              ], sTable_Truck, SF('T_Truck', FTruck), False);
      FListA.Add(nSQL);

      if (FOutDoor = sFlag_No) and (FMuiltiPound <> sFlag_Yes) then
      begin
        if FCardKeep = sFlag_ProvCardG then
        begin
          nSQL := 'Update %s Set O_Pound=NULL,' +
                  'O_BFPTime=NULL,O_BFPMan=NULL,O_BFPValue=0,' +
                  'O_BFMTime=NULL,O_BFMMan=NULL,O_BFMValue=0,' +
                  'O_BFPTime2=NULL,O_BFPMan2=NULL,O_BFPValue2=0,' +
                  'O_BFMTime2=NULL,O_BFMMan2=NULL,O_BFMValue2=0,' +
                  'O_Status=''%s'', O_NextStatus=''%s'' ' +
                  'Where O_Card=''%s''';
          nSQL := Format(nSQL, [sTable_CardOther, sFlag_TruckNone,
                  sFlag_TruckNone, FCard]);
          FListA.Add(nSQL);
        end else

        begin
          nSQL := 'Update %s Set C_Status=''%s'', C_TruckNo=NULL Where C_Card=''%s''';
          nSQL := Format(nSQL, [sTable_Card, sFlag_CardIdle, FCard]);
          FListA.Add(nSQL);

          nSQL := 'Update %s Set O_Pound=NULL, O_Card=NULL, ' +
                  'O_Status=''%s'', O_NextStatus=NULL ' +
                  'Where O_Card=''%s''';
          nSQL := Format(nSQL, [sTable_CardOther, sFlag_TruckOut,
                  FCard]);
          FListA.Add(nSQL);
        end;
      end;
      //非复磅业务的厂内临时过磅业务
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
                  SF('O_Status', sFlag_TruckBFM),
                  SF('O_NextStatus', sFlag_TruckOut),
                  SF('O_BFPValue2', FPData.FValue, sfVal),
                  SF('O_BFPTime2', sField_SQLServer_Now, sfVal),
                  SF('O_BFPMan2', FIn.FBase.FFrom.FUser),
                  SF('O_BFMValue2', FMData.FValue, sfVal),
                  SF('O_BFMTime2', DateTime2Str(FMData.FDate)),
                  SF('O_BFMMan2', FMData.FOperator)
                ], sTable_CardOther, SF('O_Card', FCard), False);
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
                SF('O_Status', sFlag_TruckBFM),
                SF('O_NextStatus', sFlag_TruckOut),
                SF('O_BFMValue2', FMData.FValue, sfVal),
                SF('O_BFMTime2', sField_SQLServer_Now, sfVal),
                SF('O_BFMMan2', FIn.FBase.FFrom.FUser)
                ], sTable_CardOther, SF('O_Card', FCard), False);
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
                  SF('O_Status', sFlag_TruckBFM),
                  SF('O_NextStatus', nNS),
                  SF('O_BFPValue', FPData.FValue, sfVal),
                  SF('O_BFPTime', sField_SQLServer_Now, sfVal),
                  SF('O_BFPMan', FIn.FBase.FFrom.FUser),
                  SF('O_BFMValue', FMData.FValue, sfVal),
                  SF('O_BFMTime', DateTime2Str(FMData.FDate)),
                  SF('O_BFMMan', FMData.FOperator)
                  ], sTable_CardOther, SF('O_Card', FCard), False);
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
                SF('O_Status', sFlag_TruckBFM),
                SF('O_NextStatus', nNS),
                SF('O_BFMValue', FMData.FValue, sfVal),
                SF('O_BFMTime', sField_SQLServer_Now, sfVal),
                SF('O_BFMMan', FIn.FBase.FFrom.FUser)
                ], sTable_CardOther, SF('O_Card', FCard), False);
          FListA.Add(nSQL);
        end;
      end;

      nSQL := MakeSQLByStr([
              SF('T_LastTime',sField_SQLServer_Now, sfVal)
              ], sTable_Truck, SF('T_Truck', FTruck), False);
      FListA.Add(nSQL);
      //更新车辆活动时间

      if (FOutDoor = sFlag_No) and (FMuiltiPound <> sFlag_Yes) then
      begin
        if FCardKeep = sFlag_ProvCardG then
        begin
          nSQL := 'Update %s Set O_Pound=NULL,' +
                  'O_BFPTime=NULL,O_BFPMan=NULL,O_BFPValue=0,' +
                  'O_BFMTime=NULL,O_BFMMan=NULL,O_BFMValue=0,' +
                  'O_BFPTime2=NULL,O_BFPMan2=NULL,O_BFPValue2=0,' +
                  'O_BFMTime2=NULL,O_BFMMan2=NULL,O_BFMValue2=0,' +
                  'O_Status=''%s'', O_NextStatus=''%s'' ' +
                  'Where O_Card=''%s''';
          nSQL := Format(nSQL, [sTable_CardOther, sFlag_TruckNone,
                  sFlag_TruckNone, FCard]);
          FListA.Add(nSQL);
        end else

        begin
          nSQL := 'Update %s Set C_Status=''%s'', C_TruckNo=NULL Where C_Card=''%s''';
          nSQL := Format(nSQL, [sTable_Card, sFlag_CardIdle, FCard]);
          FListA.Add(nSQL);

          nSQL := 'Update %s Set O_Pound=NULL, O_Card=NULL, ' +
                  'O_Status=''%s'', O_NextStatus=NULL ' +
                  'Where O_Card=''%s''';
          nSQL := Format(nSQL, [sTable_CardOther, sFlag_TruckOut,
                  FCard]);
          FListA.Add(nSQL);
        end;
      end;
      //厂内临时过磅业务
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckOut then //出厂
  begin
    with nPound[0] do
    begin
      if FCardKeep = sFlag_ProvCardG then
      begin
        nSQL := 'Update %s Set O_Pound=NULL,' +
                'O_BFPTime=NULL,O_BFPMan=NULL,O_BFPValue=0,' +
                'O_BFMTime=NULL,O_BFMMan=NULL,O_BFMValue=0,' +
                'O_BFPTime2=NULL,O_BFPMan2=NULL,O_BFPValue2=0,' +
                'O_BFMTime2=NULL,O_BFMMan2=NULL,O_BFMValue2=0,' +
                'O_Status=''%s'', O_NextStatus=''%s'' ' +
                'Where O_Card=''%s''';
        nSQL := Format(nSQL, [sTable_CardOther, sFlag_TruckNone,
                sFlag_TruckNone, FCard]);
        FListA.Add(nSQL);
      end else

      begin
        nSQL := 'Update %s Set C_Status=''%s'', C_TruckNo=NULL Where C_Card=''%s''';
        nSQL := Format(nSQL, [sTable_Card, sFlag_CardIdle, FCard]);
        FListA.Add(nSQL);

        nSQL := 'Update %s Set O_Pound=NULL, O_Card=NULL, ' +
                'O_Status=''%s'', O_NextStatus=NULL ' +
                'Where O_Card=''%s''';
        nSQL := Format(nSQL, [sTable_CardOther, sFlag_TruckOut,
                FCard]);
        FListA.Add(nSQL);
      end;
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

  if (FIn.FExtParam = sFlag_TruckBFM) or (FIn.FExtParam = sFlag_TruckSH) then
  begin
    if Assigned(gHardShareData) then
      gHardShareData('TruckOut:' + nPound[0].FCard);
    //磅房处理自动出厂
  end;
end;

//Date: 2014-09-15
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
class function TWorkerBusinessShipTmp.CallMe(const nCmd: Integer;
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

initialization
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessShipTmp, sPlug_ModuleBus);
end.

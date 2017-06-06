{*******************************************************************************
  作者: fendou116688@163.com 2016-06-15
  描述: 模块业务对象
*******************************************************************************}
unit UWorkerBusinessProvide;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, UWorkerBusinessCommand{$IFDEF HardMon},UMgrHardHelper{$ENDIF};

type
  TWorkerBusinessProvide = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton

    function SaveProvideCard(var nData: string): Boolean;
    function LogoffProvideCard(var nData: string): Boolean;

    function SaveProvideBase(var nData: string): Boolean;
    function DeleteProvideBase(var nData: string): Boolean;
    //采购入厂磁卡办理及删除

    function DeleteProvide(var nData: string): Boolean;
    //采购入厂明细删除

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
class function TWorkerBusinessProvide.FunctionName: string;
begin
  Result := sBus_BusinessProvide;
end;

constructor TWorkerBusinessProvide.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessProvide.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TWorkerBusinessProvide.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessProvide.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2015-8-5
//Parm: 输入数据
//Desc: 执行nData业务指令
function TWorkerBusinessProvide.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;

  case FIn.FCommand of
   cBC_SaveBills         : Result := SaveProvideBase(nData);
   cBC_DeleteBill        : Result := DeleteProvideBase(nData);
   cBC_DeleteOrder       : Result := DeleteProvide(nData);
   cBC_SaveBillCard      : Result := SaveProvideCard(nData);
   cBC_LogoffCard        : Result := LogoffProvideCard(nData);
   cBC_GetPostBills      : Result := GetPostProvideItems(nData);
   cBC_SavePostBills     : Result := SavePostProvideItems(nData);
   else
    begin
      Result := False;
      nData := '无效的业务代码(Invalid Command).';
    end;
  end;
end;

function TWorkerBusinessProvide.SaveProvideBase(var nData: string): Boolean;
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
    FListC.Clear;
    FListC.Values['Group'] :=sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_ProvideBase;
    //to get serial no

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
          FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    nStr := MakeSQLByStr([
            SF('P_ID', nOut.FData),
            SF('P_BID', FListA.Values['Order']),         //NC订单编号
            SF('P_Area', FListA.Values['Area']),         //NC区域
            //SF('P_Project', FListA.Values['Project']),   //NC项目
            SF('P_Factory', FListA.Values['Factory']),   //NC工厂编号
            SF('P_Origin', FListA.Values['Origin']),     //NC来源,矿点

            SF('P_ProType', FListA.Values['ProType']),   //NC供应商类型
            SF('P_ProID', FListA.Values['ProID']),       //NC供应商ID
            SF('P_ProName', FListA.Values['ProName']),   //NC供应商名称
            SF('P_ProPY', GetPinYinOfStr(FListA.Values['ProName'])),

            SF('P_SaleID', FListA.Values['SaleID']),     //NC业务员ID
            SF('P_SaleMan', FListA.Values['SaleName']), //NC业务员名称
            SF('P_SalePY', GetPinYinOfStr(FListA.Values['SaleName'])),

            SF('P_Type', sFlag_San),
            SF('P_StockNo', FListA.Values['StockNo']),
            SF('P_StockName', FListA.Values['StockName']),

            SF('P_Truck', nTruck),
            SF('P_Status', sFlag_BillNew),
            SF('P_IsUsed', sFlag_No),

            SF('P_Man', FIn.FBase.FFrom.FUser),
            SF('P_Date', sField_SQLServer_Now, sfVal)
            ], sTable_ProvBase, '', True);
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
function TWorkerBusinessProvide.DeleteProvideBase(var nData: string): Boolean;
var nStr,nP: string;
    nIdx: Integer;
begin
  Result := False;
  //init

  nStr := 'Select Count(*) From %s Where D_OID=''%s''';
  nStr := Format(nStr, [sTable_ProvDtl, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if Fields[0].AsInteger > 0 then
    begin
      nData := '采购入厂申请单[ %s ]已使用，禁止删除.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
  end;

  FDBConn.FConn.BeginTrans;
  try
    //--------------------------------------------------------------------------
    nStr := Format('Select * From %s Where 1<>1', [sTable_ProvBase]);
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
            'Select $FL,''$User'',$Now From $OO Where P_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$OB', sTable_ProvBaseBak),
            MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
            MI('$Now', sField_SQLServer_Now),
            MI('$OO', sTable_ProvBase), MI('$ID', FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Delete From %s Where P_ID=''%s''';
    nStr := Format(nStr, [sTable_ProvBase, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2015/9/19
//Parm: 
//Desc: 删除采购入厂申请单
function TWorkerBusinessProvide.DeleteProvide(var nData: string): Boolean;
var nStr,nP, nBID: string;
    nIdx: Integer;
begin
  nStr := 'Select D_OID From %s Where D_ID=''%s''';
  nStr := Format(nStr, [sTable_ProvDtl, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
       nBID := Fields[0].AsString
  else nBID := '';

  FDBConn.FConn.BeginTrans;
  try
    //--------------------------------------------------------------------------
    nStr := Format('Select * From %s Where 1<>1', [sTable_ProvDtl]);
    //only for fields
    nP := '';

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      for nIdx:=0 to FieldCount - 1 do
       if (Fields[nIdx].DataType <> ftAutoInc) and
          (Pos('D_Del', Fields[nIdx].FieldName) < 1) then
        nP := nP + Fields[nIdx].FieldName + ',';
      //所有字段,不包括删除

      System.Delete(nP, Length(nP), 1);
    end;

    nStr := 'Insert Into $OB($FL,D_DelMan,D_DelDate) ' +
            'Select $FL,''$User'',$Now From $OO Where D_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$OB', sTable_ProvDtlBak),
            MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
            MI('$Now', sField_SQLServer_Now),
            MI('$OO', sTable_ProvDtl), MI('$ID', FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Delete From %s Where D_ID=''%s''';
    nStr := Format(nStr, [sTable_ProvDtl, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := MakeSQLByStr([
            SF('P_DID', ''),
            SF('P_IsUsed', sFlag_No),
            SF('P_Status', sFlag_TruckNone),
            SF('P_NextStatus', sFlag_TruckNone)
            ], sTable_ProvBase, SF('P_ID', nBID), False);
    gDBConnManager.WorkerExec(FDBConn, nStr);        

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;


//Date: 2016/2/27
//Parm: 
//Desc: 采购入厂业务办理磁卡
function TWorkerBusinessProvide.SaveProvideCard(var nData: string): Boolean;
var nSQL, nTruck: string;
    nIdx: Integer;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);
  //init card

  nSQL := 'Select P_Card,P_Truck From %s Where P_ID=''%s''';
  nSQL := Format(nSQL, [sTable_ProvBase, FListA.Values['ID']]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := '采购单据[ %s ]已丢失.';
      nData := Format(nData, [FListA.Values['ID']]);
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
  nSQL := Format(nSQL, [sTable_ProvBase, FListA.Values['Card']]);
  FListC.Add(nSQL);
  //注销正在使用该卡的原材料

  nSQL := 'Update %s Set L_Card=NULL Where L_Card=''%s''';
  nSQL := Format(nSQL, [sTable_Bill, FListA.Values['Card']]);
  FListC.Add(nSQL);
  //注销正在使用该卡的销售订单

  nSQL := MakeSQLByStr([
          SF('P_Card', FListA.Values['Card']),
          SF('P_CType', FListA.Values['CardType']),
          SF('P_Project', FListA.Values['CardSerial']),
          SF('P_UsePre', FListA.Values['UsePre'])
          ], sTable_ProvBase, SF('P_ID', FListA.Values['ID']), False);
  FListC.Add(nSQL);
  //更新磁卡

  nSQL := 'Update %s Set D_Card=''%s'' Where D_OID =''%s'' And D_OutFact Is NULL';
  nSQL := Format(nSQL, [sTable_ProvDtl,
          FListA.Values['Card'], FListA.Values['ID']]);
  FListC.Add(nSQL);
  //更新未出厂明细磁卡

  nSQL := 'Select Count(*) From %s Where C_Card=''%s''';
  nSQL := Format(nSQL, [sTable_Card, FListA.Values['Card']]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if Fields[0].AsInteger < 1 then
  begin
    nSQL := MakeSQLByStr([SF('C_Card', FListA.Values['Card']),
            SF('C_Group', FListA.Values['CardType']),
            SF('C_Status', sFlag_CardUsed),
            SF('C_Used', sFlag_Provide),
            SF('C_Freeze', sFlag_No),
            SF('C_TruckNo', nTruck),
            SF('C_Man', FIn.FBase.FFrom.FUser),
            SF('C_Date', sField_SQLServer_Now, sfVal)
            ], sTable_Card, '', True);
    FListC.Add(nSQL);
  end else
  begin
    nSQL := Format('C_Card=''%s''', [FListA.Values['Card']]);
    nSQL := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
            SF('C_Group', FListA.Values['CardType']),
            SF('C_Used', sFlag_Provide),
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

//Date: 2016/2/27
//Parm: 
//Desc: 采购入厂业务注销磁卡
function TWorkerBusinessProvide.LogoffProvideCard(var nData: string): Boolean;
var nStr: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set P_Card=NULL, P_CType=NULL, P_Project=NULL ' +
            'Where P_Card=''%s''';
    nStr := Format(nStr, [sTable_ProvBase, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Update %s Set C_Status=''%s'', C_Used=Null, C_TruckNo=Null ' +
            'Where C_Card=''%s''';
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
function TWorkerBusinessProvide.GetPostProvideItems(var nData: string): Boolean;
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

  nStr := 'Select * From $ProvBase b Where P_Card=''$CD''';
  nStr := MacroValue(nStr, [MI('$ProvBase', sTable_ProvBase),
          MI('$CD', FIn.FData)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '磁卡号[ %s ]没有绑定采购车辆.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    SetLength(nBills, 1);
    with nBills[0] do
    begin
      FID         := FieldByName('P_DID').AsString;             //主要显示明细编号
      if FID = '' then
        FID       := FieldByName('P_ID').AsString;

      FZhiKa      := FieldByName('P_ID').AsString;             //采购订单编号
      FExtID_1    := FieldByName('P_DID').AsString;            //采购明细编号
      FExtID_2    := FieldByName('P_BID').AsString;            //申请单编号

      FCusID      := FieldByName('P_ProID').AsString;
      FCusName    := FieldByName('P_ProName').AsString;
      FTruck      := FieldByName('P_Truck').AsString;

      FType       := SFlag_San;
      FStockNo    := FieldByName('P_StockNo').AsString;
      FStockName  := FieldByName('P_StockName').AsString;

      FCard       := FieldByName('P_Card').AsString;
      FStatus     := FieldByName('P_Status').AsString;
      FNextStatus := FieldByName('P_NextStatus').AsString;

      FFactory    := FieldByName('P_Factory').AsString;
      FOrigin     := FieldByName('P_Origin').AsString;
      FKZValue    := 0;

      FIsVIP      := FieldByName('P_IsUsed').AsString;
      if FIsVIP <> sFlag_Yes then
      begin
        FStatus     := sFlag_TruckNone;
        FNextStatus := sFlag_TruckNone;
      end;
      //如果订单非占用状态

      FPreTruckP := FieldByName('P_UsePre').AsString = sFlag_Yes;
      with FPData do
      begin
        FDate   := FieldByName('P_PDate').AsDateTime;
        FValue  := FieldByName('P_PValue').AsFloat;
        FOperator := FieldByName('P_PMan').AsString;
      end;

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

      FSelected := True;
    end;
  end;

  FOut.FData := CombineBillItmes(nBills);
  Result := True;
end;

//Date: 2014-09-18
//Parm: 交货单[FIn.FData];岗位[FIn.FExtParam]
//Desc: 保存指定岗位提交的交货单列表
function TWorkerBusinessProvide.SavePostProvideItems(var nData: string): Boolean;
var nSQL,nStr,nS,nN,nYS: string;
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
    nData := '岗位[ %s ]提交了采购入厂业务合单,该业务系统暂时不支持.';
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

  nSQL := 'Select P_Status, P_NextStatus From %s Where P_ID=''%s''';
  nSQL := Format(nSQL, [sTable_ProvBase, nPound[0].FZhiKa]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := '采购订单编号[ %s ]不存在,请重新办理.';
      nData := Format(nData, [nPound[0].FZhiKa]);
      Exit;
    end;

    nS := Fields[0].AsString;
    nN := Fields[1].AsString;
    //申请单当前状态和下一状态
  end;

  FListA.Clear;
  //用于存储SQL列表

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckIn then //进厂
  begin
    if nS = sFlag_TruckIn then
    begin
      Result := True;
      Exit;
    end;
    //入厂记录未配对完成

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_ProvideDtl;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := nOut.FData;
    //返回生成的信息编号
    with nPound[0] do
    begin
      nSQL := MakeSQLByStr([
              SF('D_ID', nOut.FData),
              SF('D_Card', FCard),
              SF('D_Truck', FTruck),
              SF('D_OID', FZhiKa),

              SF('D_ProID', FCusID),
              SF('D_ProName', FCusName),
              SF('D_ProPY', GetPinYinOfStr(FCusName)),

              SF('D_Type', FType),
              SF('D_StockNo', FStockNo),
              SF('D_StockName', FStockName),

              SF('D_Status', sFlag_TruckIn),
              SF('D_NextStatus', sFlag_TruckBFP),

              SF('D_InTime', sField_SQLServer_Now, sfVal),
              SF('D_InMan', FIn.FBase.FFrom.FUser)
              ], sTable_ProvDtl, '', True);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('P_DID', nOut.FData),
              SF('P_IsUsed', sFlag_Yes),
              SF('P_Status', sFlag_TruckIn),
              SF('P_NextStatus', sFlag_TruckBFP)
              ], sTable_ProvBase, SF('P_ID', FZhiKa), False);
      FListA.Add(nSQL);
    end;

  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFP then //称量皮重
  begin
    if nS = sFlag_TruckBFP then
    begin
      Result := True;
      Exit;
    end;
    //同一状态重复保存

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

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := nOut.FData;
    //返回榜单号,用于拍照绑定
    with nPound[0] do
    begin
      FStatus := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckXH;

      if (FListB.IndexOf(FStockNo) >= 0) or (nYS <> sFlag_Yes) then
        FNextStatus := sFlag_TruckBFM;
      //现场不发货直接过重

      nSQL := MakeSQLByStr([
            SF('P_ID', nOut.FData),
            SF('P_Type', sFlag_Provide),
            SF('P_Order', FID),
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
            SF('P_PrintNum', 1, sfVal)
            ], sTable_PoundLog, '', True);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('D_Status', FStatus),
              SF('D_NextStatus', FNextStatus),

              SF('D_PID', nOut.FData),
              SF('D_PValue', FPData.FValue, sfVal),
              SF('D_PDate', sField_SQLServer_Now, sfVal),
              SF('D_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_ProvDtl, SF('D_ID', FExtID_1), False);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('P_Status', FStatus),
              SF('P_NextStatus', FNextStatus),

              SF('P_PValue', FPData.FValue, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_ProvBase, SF('P_ID', FZhiKa), False);
      FListA.Add(nSQL);

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
    if nS = sFlag_TruckSH then
    begin
      Result := True;
      Exit;
    end;
    //同一状态重复保存

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := nOut.FData;
    //返回榜单号,用于拍照绑定
    with nPound[0] do
    begin
      FStatus := sFlag_TruckSH;
      FNextStatus := sFlag_TruckOut;

      nSQL := MakeSQLByStr([
              SF('P_ID', nOut.FData),
              SF('P_Type', sFlag_Provide),
              SF('P_Order', FID),
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
              SF('P_Status', sFlag_TruckBFM),
              SF('P_Valid', sFlag_Yes),
              SF('P_PrintNum', 1, sfVal)
              ], sTable_PoundLog, '', True);
      FListA.Add(nSQL);

      nVal := FMData.FValue - FPData.FValue;
      nSQL := MakeSQLByStr([
              SF('D_Status', FStatus),
              SF('D_NextStatus', FNextStatus),

              SF('D_PValue', FPData.FValue, sfVal),
              SF('D_PDate', sField_SQLServer_Now, sfVal),
              SF('D_PMan', FIn.FBase.FFrom.FUser),
              SF('D_MValue', FMData.FValue, sfVal),
              SF('D_MDate', sField_SQLServer_Now, sfVal),
              SF('D_MMan', FIn.FBase.FFrom.FUser),
              SF('D_Value', nVal, sfVal),

              SF('D_PID', nOut.FData)
              ], sTable_ProvDtl, SF('D_ID', FExtID_1), False);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('P_Status', FStatus),
              SF('P_NextStatus', FNextStatus)
              ], sTable_ProvBase, SF('P_ID', FZhiKa), False);
      FListA.Add(nSQL);

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
      FStatus := sFlag_TruckXH;
      FNextStatus := sFlag_TruckBFM;

      nStr := SF('P_Order', FExtID_1);
      //where
      nSQL := MakeSQLByStr([
                SF('P_KZValue', FKZValue, sfVal)
                ], sTable_PoundLog, nStr, False);
      //验收扣杂
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('D_Status', FStatus),
              SF('D_NextStatus', FNextStatus),
              SF('D_YTime', sField_SQLServer_Now, sfVal),
              SF('D_YMan', FIn.FBase.FFrom.FUser),
              SF('D_KZValue', FKZValue, sfVal),
              SF('D_YSResult', FYSValid),
              SF('D_YLineName', FSeal),    //保存批次号
              SF('D_Memo', FMemo)
              ], sTable_ProvDtl, SF('D_ID', FExtID_1), False);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('P_Status', FStatus),
              SF('P_NextStatus', FNextStatus)
              ], sTable_ProvBase, SF('P_ID', FZhiKa), False);
      FListA.Add(nSQL);
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFM then //称量毛重
  begin
    if nS = sFlag_TruckBFM then
    begin
      Result := True;
      Exit;
    end;

    with nPound[0] do
    begin
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

      nVal := FMData.FValue - FPData.FValue -FKZValue;
      nVal := Float2Float(nVal, cPrecision, False);
      //净重

      {$IFDEF AutoSaveTruckP}
      nStr := MakeSQLByStr([SF('T_PrePValue', FPData.FValue, sfVal),
              SF('T_PrePTime', sField_SQLServer_Now, sfVal),
              SF('T_PrePMan', FIn.FBase.FFrom.FUser)],
              sTable_Truck, SF('T_Truck', FTruck), False);
      FListA.Add(nSQL);
      //预置皮重
      {$ENDIF}

      nStr := SF('P_Order', FID);
      //where

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
                SF('D_Status', sFlag_TruckBFM),
                SF('D_NextStatus', sFlag_TruckOut),
                SF('D_PValue', FPData.FValue, sfVal),
                SF('D_PDate', sField_SQLServer_Now, sfVal),
                SF('D_PMan', FIn.FBase.FFrom.FUser),
                SF('D_MValue', FMData.FValue, sfVal),
                SF('D_MDate', DateTime2Str(FMData.FDate)),
                SF('D_MMan', FMData.FOperator),
                SF('D_Value', nVal, sfVal)
                ], sTable_ProvDtl, SF('D_ID', FExtID_1), False);
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('P_Status', sFlag_TruckBFM),
                SF('P_NextStatus', sFlag_TruckOut),
                SF('P_PValue', FPData.FValue, sfVal),
                SF('P_PDate', sField_SQLServer_Now, sfVal),
                SF('P_PMan', FIn.FBase.FFrom.FUser),
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', DateTime2Str(FMData.FDate)),
                SF('P_MMan', FMData.FOperator)
              ], sTable_ProvBase, SF('P_ID', FZhiKa), False);
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
                SF('D_Status', sFlag_TruckBFM),
                SF('D_NextStatus', sFlag_TruckOut),
                SF('D_MValue', FMData.FValue, sfVal),
                SF('D_MDate', sField_SQLServer_Now, sfVal),
                SF('D_MMan', FMData.FOperator),
                SF('D_Value', nVal, sfVal)
                ], sTable_ProvDtl, SF('D_ID', FExtID_1), False);
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
              SF('P_Status', sFlag_TruckBFM),
              SF('P_NextStatus', sFlag_TruckOut),
              SF('P_MValue', FMData.FValue, sfVal),
              SF('P_MDate', sField_SQLServer_Now, sfVal),
              SF('P_MMan', FMData.FOperator)
              ], sTable_ProvBase, SF('P_ID', FZhiKa), False);
        FListA.Add(nSQL);
      end;

      nSQL := MakeSQLByStr([
              SF('T_LastTime',sField_SQLServer_Now, sfVal)
              ], sTable_Truck, SF('T_Truck', FTruck), False);
      FListA.Add(nSQL);
      //更新车辆活动时间
    end;

    nSQL := 'Select P_ID From %s Where P_Order=''%s''';
    nSQL := Format(nSQL, [sTable_PoundLog, nPound[0].FExtID_1]);
    //未称毛重记录

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      FOut.FData := Fields[0].AsString;
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckOut then //出厂
  begin
    if nN = sFlag_TruckOut then
    with nPound[0] do
    begin
      nSQL := MakeSQLByStr([
              SF('D_Status', sFlag_TruckOut),
              SF('D_NextStatus', ''),
              SF('D_OutFact', sField_SQLServer_Now, sfVal),
              SF('D_OutMan', FIn.FBase.FFrom.FUser)
              ], sTable_ProvDtl, SF('D_ID', FExtID_1), False);
      FListA.Add(nSQL);

      nSQL := 'Update %s Set P_DID=NULL,' +
              'P_PDate=NULL,P_PMan=NULL,P_PValue=0,' +
              'P_MDate=NULL,P_MMan=NULL,P_MValue=0,' +
              'P_IsUsed=''%s'', P_Status=''%s'', P_NextStatus=''%s'' ' +
              'Where P_ID=''%s''';
      nSQL := Format(nSQL, [sTable_ProvBase, sFlag_No, sFlag_TruckNone,
              sFlag_TruckNone, FZhiKa]);
      FListA.Add(nSQL);

      nSQL := 'Select P_ID From %s Where P_Order=''%s''';
      nSQL := Format(nSQL, [sTable_PoundLog, FExtID_1]);
      //未称毛重记录

      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if RecordCount > 0 then
      begin
        FPoundID := Fields[0].AsString;
      end;

      if not TWorkerBusinessCommander.CallMe(cBC_SyncME03,
          FPoundID, FExtID_2, @nOut) then
        raise Exception.Create(nOut.FData);
      //同步供应到NC榜单

      nSQL := 'Select P_CType, P_Card From %s Where P_ID=''%s''';
      nSQL := Format(nSQL, [sTable_ProvBase, FZhiKa]);
      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if (RecordCount > 0) And (Fields[0].AsString <> sFlag_ProvCardG) then
        CallMe(cBC_LogoffCard, Fields[1].AsString, '', @nOut);
      //如果是临时卡，注销卡片
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

  if FIn.FExtParam = sFlag_TruckSH then
  begin
    if Assigned(gHardShareData) then
      gHardShareData('TruckSH:' + nPound[0].FCard);
    //单次过磅自动出厂
  end;

  if FIn.FExtParam = sFlag_TruckBFM then
  begin
    if Assigned(gHardShareData) then
      gHardShareData('TruckOut:' + nPound[0].FCard);
    //磅房处理自动出厂
  end;
end;

//Date: 2014-09-15
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
class function TWorkerBusinessProvide.CallMe(const nCmd: Integer;
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
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessProvide, sPlug_ModuleBus);
end.

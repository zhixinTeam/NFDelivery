{*******************************************************************************
  ����: fendou116688@163.com 2016-06-15
  ����: ģ��ҵ�����
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
    //�ɹ��볧�ſ�����ɾ��

    function DeleteProvide(var nData: string): Boolean;
    //�ɹ��볧��ϸɾ��

    function GetPostProvideItems(var nData: string): Boolean;
    //��ȡ��λ�ɹ��볧��
    function SavePostProvideItems(var nData: string): Boolean;
    //�����λ�ɹ��볧��
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
//Parm: ��������
//Desc: ִ��nDataҵ��ָ��
function TWorkerBusinessProvide.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
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
      nData := '��Ч��ҵ�����(Invalid Command).';
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
  //���泵�ƺ�

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
            SF('P_BID', FListA.Values['Order']),         //NC�������
            SF('P_Area', FListA.Values['Area']),         //NC����
            //SF('P_Project', FListA.Values['Project']),   //NC��Ŀ
            SF('P_Factory', FListA.Values['Factory']),   //NC�������
            SF('P_Origin', FListA.Values['Origin']),     //NC��Դ,���

            SF('P_ProType', FListA.Values['ProType']),   //NC��Ӧ������
            SF('P_ProID', FListA.Values['ProID']),       //NC��Ӧ��ID
            SF('P_ProName', FListA.Values['ProName']),   //NC��Ӧ������
            SF('P_ProPY', GetPinYinOfStr(FListA.Values['ProName'])),

            SF('P_SaleID', FListA.Values['SaleID']),     //NCҵ��ԱID
            SF('P_SaleMan', FListA.Values['SaleName']), //NCҵ��Ա����
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
//Desc: ɾ���ɹ��볧���뵥
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
      nData := '�ɹ��볧���뵥[ %s ]��ʹ�ã���ֹɾ��.';
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
      //�����ֶ�,������ɾ��

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
//Desc: ɾ���ɹ��볧���뵥
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
      //�����ֶ�,������ɾ��

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
//Desc: �ɹ��볧ҵ�����ſ�
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
      nData := '�ɹ�����[ %s ]�Ѷ�ʧ.';
      nData := Format(nData, [FListA.Values['ID']]);
      Exit;
    end;

    FListC.Clear;
    nTruck := Fields[1].AsString;
    
    if Fields[0].AsString <> '' then
    begin
      nSQL := 'Update %s set C_TruckNo=Null,C_Status=''%s'' Where C_Card=''%s''';
      nSQL := Format(nSQL, [sTable_Card, sFlag_CardIdle, Fields[0].AsString]);
      FListC.Add(nSQL); //�ſ�״̬
    end;
  end;

  nSQL := 'Update %s Set P_Card=NULL, P_CType=NULL Where P_Card=''%s''';
  nSQL := Format(nSQL, [sTable_ProvBase, FListA.Values['Card']]);
  FListC.Add(nSQL);
  //ע������ʹ�øÿ���ԭ����

  nSQL := 'Update %s Set L_Card=NULL Where L_Card=''%s''';
  nSQL := Format(nSQL, [sTable_Bill, FListA.Values['Card']]);
  FListC.Add(nSQL);
  //ע������ʹ�øÿ������۶���

  nSQL := MakeSQLByStr([
          SF('P_Card', FListA.Values['Card']),
          SF('P_CType', FListA.Values['CardType']),
          SF('P_Project', FListA.Values['CardSerial']),
          SF('P_UsePre', FListA.Values['UsePre'])
          ], sTable_ProvBase, SF('P_ID', FListA.Values['ID']), False);
  FListC.Add(nSQL);
  //���´ſ�

  nSQL := 'Update %s Set D_Card=''%s'' Where D_OID =''%s'' And D_OutFact Is NULL';
  nSQL := Format(nSQL, [sTable_ProvDtl,
          FListA.Values['Card'], FListA.Values['ID']]);
  FListC.Add(nSQL);
  //����δ������ϸ�ſ�

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
  //���´ſ�״̬

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
//Desc: �ɹ��볧ҵ��ע���ſ�
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
//Parm: �ſ���[FIn.FData];��λ[FIn.FExtParam]
//Desc: ��ȡ�ض���λ����Ҫ�Ľ������б�
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
      nData := Format('�ſ�[ %s ]��Ϣ�Ѷ�ʧ.', [FIn.FData]);
      Exit;
    end;

    if Fields[0].AsString <> sFlag_CardUsed then
    begin
      nData := '�ſ�[ %s ]��ǰ״̬Ϊ[ %s ],�޷�ʹ��.';
      nData := Format(nData, [FIn.FData, CardStatusToStr(Fields[0].AsString)]);
      Exit;
    end;

    if Fields[1].AsString = sFlag_Yes then
    begin
      nData := '�ſ�[ %s ]�ѱ�����,�޷�ʹ��.';
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
      nData := '�ſ���[ %s ]û�а󶨲ɹ�����.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    SetLength(nBills, 1);
    with nBills[0] do
    begin
      FID         := FieldByName('P_DID').AsString;             //��Ҫ��ʾ��ϸ���
      if FID = '' then
        FID       := FieldByName('P_ID').AsString;

      FZhiKa      := FieldByName('P_ID').AsString;             //�ɹ��������
      FExtID_1    := FieldByName('P_DID').AsString;            //�ɹ���ϸ���
      FExtID_2    := FieldByName('P_BID').AsString;            //���뵥���

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
      //���������ռ��״̬

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
//Parm: ������[FIn.FData];��λ[FIn.FExtParam]
//Desc: ����ָ����λ�ύ�Ľ������б�
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
  //��������

  if nInt < 1 then
  begin
    nData := '��λ[ %s ]�ύ�ĵ���Ϊ��.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  if nInt > 1 then
  begin
    nData := '��λ[ %s ]�ύ�˲ɹ��볧ҵ��ϵ�,��ҵ��ϵͳ��ʱ��֧��.';
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
          nData := '�ſ����[ %s ]��ƥ��.';
          nData := Format(nData, [nPound[0].FCard]);
          Exit;
        end;

        nStr := UpperCase(Fields[0].AsString);
      end;

      if UpperCase(nReader.FGroup) <> nStr then
      begin
        nData := '�ſ���[ %s:::%s ]�������[ %s:::%s ]����ƥ��ʧ��.';
        nData := Format(nData,[nPound[0].FCard, nStr, nReader.FID,
                 nReader.FGroup]);
        Exit;
      end;
    end;
  end;
  //����ʱ����֤�������뿨Ƭ����
  {$ENDIF}

  nSQL := 'Select P_Status, P_NextStatus From %s Where P_ID=''%s''';
  nSQL := Format(nSQL, [sTable_ProvBase, nPound[0].FZhiKa]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := '�ɹ��������[ %s ]������,�����°���.';
      nData := Format(nData, [nPound[0].FZhiKa]);
      Exit;
    end;

    nS := Fields[0].AsString;
    nN := Fields[1].AsString;
    //���뵥��ǰ״̬����һ״̬
  end;

  FListA.Clear;
  //���ڴ洢SQL�б�

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckIn then //����
  begin
    if nS = sFlag_TruckIn then
    begin
      Result := True;
      Exit;
    end;
    //�볧��¼δ������

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_ProvideDtl;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := nOut.FData;
    //�������ɵ���Ϣ���
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
  if FIn.FExtParam = sFlag_TruckBFP then //����Ƥ��
  begin
    if nS = sFlag_TruckBFP then
    begin
      Result := True;
      Exit;
    end;
    //ͬһ״̬�ظ�����

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
    //���ذ񵥺�,�������հ�
    with nPound[0] do
    begin
      FStatus := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckXH;

      if (FListB.IndexOf(FStockNo) >= 0) or (nYS <> sFlag_Yes) then
        FNextStatus := sFlag_TruckBFM;
      //�ֳ�������ֱ�ӹ���

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
            SF('P_Direction', '����'),
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
      //���³����ʱ��
    end;

  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckSH then //Ԥ��Ƥ��
  begin
    if nS = sFlag_TruckSH then
    begin
      Result := True;
      Exit;
    end;
    //ͬһ״̬�ظ�����

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := nOut.FData;
    //���ذ񵥺�,�������հ�
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
              SF('P_Direction', '����'),
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
  if FIn.FExtParam = sFlag_TruckXH then //�����ֳ�
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
      //���տ���
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('D_Status', FStatus),
              SF('D_NextStatus', FNextStatus),
              SF('D_YTime', sField_SQLServer_Now, sfVal),
              SF('D_YMan', FIn.FBase.FFrom.FUser),
              SF('D_KZValue', FKZValue, sfVal),
              SF('D_YSResult', FYSValid),
              SF('D_YLineName', FSeal),    //�������κ�
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
  if FIn.FExtParam = sFlag_TruckBFM then //����ë��
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
          //�ͻ�+���ϲ�������

          Next;
        end;

        if Eof then First;
        //ʹ�õ�һ������

        if FMData.FValue > FPData.FValue then
             nNet := FMData.FValue - FPData.FValue
        else nNet := FPData.FValue - FMData.FValue;

        nVal := 0;
        //���ۼ���
        nStr := FieldByName('D_Type').AsString;

        if nStr = sFlag_DeductFix then
          nVal := FieldByName('D_Value').AsFloat;
        //��ֵ�ۼ�

        if nStr = sFlag_DeductPer then
        begin
          nVal := FieldByName('D_Value').AsFloat;
          nVal := nNet * nVal;
        end; //�����ۼ�

        if (nVal > 0) and (nNet > nVal) then
        begin
          nVal := Float2Float(nVal, cPrecision, False);
          //���������ۼ�Ϊ2λС��;

          if FMData.FValue > FPData.FValue then
               FMData.FValue := (FMData.FValue*1000 - nVal*1000) / 1000
          else FPData.FValue := (FPData.FValue*1000 - nVal*1000) / 1000;
        end;
      end;

      nVal := FMData.FValue - FPData.FValue -FKZValue;
      nVal := Float2Float(nVal, cPrecision, False);
      //����

      {$IFDEF AutoSaveTruckP}
      nStr := MakeSQLByStr([SF('T_PrePValue', FPData.FValue, sfVal),
              SF('T_PrePTime', sField_SQLServer_Now, sfVal),
              SF('T_PrePMan', FIn.FBase.FFrom.FUser)],
              sTable_Truck, SF('T_Truck', FTruck), False);
      FListA.Add(nSQL);
      //Ԥ��Ƥ��
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
        //����ʱ,����Ƥ�ش�,����Ƥë������
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
      //���³����ʱ��
    end;

    nSQL := 'Select P_ID From %s Where P_Order=''%s''';
    nSQL := Format(nSQL, [sTable_PoundLog, nPound[0].FExtID_1]);
    //δ��ë�ؼ�¼

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      FOut.FData := Fields[0].AsString;
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckOut then //����
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
      //δ��ë�ؼ�¼

      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if RecordCount > 0 then
      begin
        FPoundID := Fields[0].AsString;
      end;

      if not TWorkerBusinessCommander.CallMe(cBC_SyncME03,
          FPoundID, FExtID_2, @nOut) then
        raise Exception.Create(nOut.FData);
      //ͬ����Ӧ��NC��

      nSQL := 'Select P_CType, P_Card From %s Where P_ID=''%s''';
      nSQL := Format(nSQL, [sTable_ProvBase, FZhiKa]);
      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if (RecordCount > 0) And (Fields[0].AsString <> sFlag_ProvCardG) then
        CallMe(cBC_LogoffCard, Fields[1].AsString, '', @nOut);
      //�������ʱ����ע����Ƭ
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
    //���ι����Զ�����
  end;

  if FIn.FExtParam = sFlag_TruckBFM then
  begin
    if Assigned(gHardShareData) then
      gHardShareData('TruckOut:' + nPound[0].FCard);
    //���������Զ�����
  end;
end;

//Date: 2014-09-15
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
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

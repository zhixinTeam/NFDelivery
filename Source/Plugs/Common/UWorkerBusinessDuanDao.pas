{*******************************************************************************
  ����: fendou116688@163.com 2016-02-27
  ����: ģ��ҵ�����
*******************************************************************************}
unit UWorkerBusinessDuanDao;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, UWorkerBusinessCommand;

type
  TWorkerBusinessDuanDao = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton

    function SaveDDCard(var nData: string): Boolean;
    function LogoffDDCard(var nData: string): Boolean;

    function GetPostDDItems(var nData: string): Boolean;
    //��ȡ��λ�̵���
    function SavePostDDItems(var nData: string): Boolean;
    //�����λ�̵���
    function AXSyncDuanDao(var nData: string): Boolean;
    //ͬ������
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
class function TWorkerBusinessDuanDao.FunctionName: string;
begin
  Result := sBus_BusinessDuanDao;
end;

constructor TWorkerBusinessDuanDao.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessDuanDao.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TWorkerBusinessDuanDao.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessDuanDao.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2015-8-5
//Parm: ��������
//Desc: ִ��nDataҵ��ָ��
function TWorkerBusinessDuanDao.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
  end;

  case FIn.FCommand of
   cBC_SaveBillCard      : Result := SaveDDCard(nData);
   cBC_LogoffCard        : Result := LogoffDDCard(nData);
   cBC_GetPostBills      : Result := GetPostDDItems(nData);
   cBC_SavePostBills     : Result := SavePostDDItems(nData);
   cBC_SyncDuanDao       : Result := AXSyncDuanDao(nData);
   else
    begin
      Result := False;
      nData := '��Ч��ҵ�����(Invalid Command).';
    end;
  end;
end;

//------------------------------------------------------------------------------ 
//Date: 2016-02-27
//Parm: �̵�����[FIn.FData]
//Desc: ͬ���̵�����AX
function TWorkerBusinessDuanDao.AXSyncDuanDao(var nData: string): Boolean;
begin
  Result := True;
end;

//Date: 2016/2/27
//Parm: 
//Desc: �̵�ҵ�����ſ�
function TWorkerBusinessDuanDao.SaveDDCard(var nData: string): Boolean;
var nSQL: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    if FIn.FData <> '' then
    begin
      nSQL := 'Update %s Set T_Card=''%s'' Where T_Truck =''%s''';
      nSQL := Format(nSQL, [sTable_Truck, FIn.FExtParam, FIn.FData]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    nSQL := 'Select Count(*) From %s Where C_Card=''%s''';
    nSQL := Format(nSQL, [sTable_Card, FIn.FExtParam]);

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if Fields[0].AsInteger < 1 then
    begin
      nSQL := MakeSQLByStr([SF('C_Card', FIn.FExtParam),
              SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_DuanDao),
              SF('C_Freeze', sFlag_No),
              SF('C_TruckNo', FIn.FData),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, '', True);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end else
    begin
      nSQL := Format('C_Card=''%s''', [FIn.FExtParam]);
      nSQL := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_DuanDao),
              SF('C_Freeze', sFlag_No),
              SF('C_TruckNo', FIn.FData),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, nSQL, False);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2016/2/27
//Parm: 
//Desc: �̵�ҵ��ע���ſ�
function TWorkerBusinessDuanDao.LogoffDDCard(var nData: string): Boolean;
var nStr: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set T_Card=Null Where T_Card=''%s''';
    nStr := Format(nStr, [sTable_Truck, FIn.FData]);
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
function TWorkerBusinessDuanDao.GetPostDDItems(var nData: string): Boolean;
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

  nStr := 'Select T_Truck, T_MatePID, T_MateID, T_MateName, T_Card,' +
          'T_PrePValue, T_PrePMan, T_PrePTime, ' +
          'T_SrcAddr, T_DestAddr From $Truck b ';
  nStr := nStr + 'Where T_Card=''$CD''';
  nStr := MacroValue(nStr, [MI('$Truck', sTable_Truck),MI('$CD', FIn.FData)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '�ſ���[ %s ]û�е��˳���.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    SetLength(nBills, 1);
    with nBills[0] do
    begin
      FID         := FieldByName('T_MateID').AsString;
      FCusName    := FieldByName('T_SrcAddr').AsString + '-->' +
                     FieldByName('T_DestAddr').AsString;
      FTruck      := FieldByName('T_Truck').AsString;

      FType       := SFlag_San;
      FStockNo    := FieldByName('T_MateID').AsString;
      FStockName  := FieldByName('T_MateName').AsString;

      FCard       := FieldByName('T_Card').AsString;
      FStatus     := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckBFM;

      with FPData do
      begin
        FDate   := FieldByName('T_PrePTime').AsDateTime;
        FValue  := FieldByName('T_PrePValue').AsFloat;
        FOperator := FieldByName('T_PrePMan').AsString;

        if FValue <=0 then FNextStatus := sFlag_TruckBFP;
      end;

      FMemo         := FieldByName('T_SrcAddr').AsString;
      FYSValid      := FieldByName('T_DestAddr').AsString;
      FSelected := True;
    end;
  end;

  FOut.FData := CombineBillItmes(nBills);
  Result := True;
end;

//Date: 2014-09-18
//Parm: ������[FIn.FData];��λ[FIn.FExtParam]
//Desc: ����ָ����λ�ύ�Ľ������б�
function TWorkerBusinessDuanDao.SavePostDDItems(var nData: string): Boolean;
var nSQL: string;
    nInt, nIdx: Integer;
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
    nData := '��λ[ %s ]�ύ�˶̵�ҵ��ϵ�,��ҵ��ϵͳ��ʱ��֧��.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  FListA.Clear;
  //���ڴ洢SQL�б�

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFP then //Ԥ��Ƥ��
  begin
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
      nSQL := MakeSQLByStr([
            SF('P_ID', nOut.FData),
            SF('P_Type', sFlag_Other),
            SF('P_Truck', FTruck),
            SF('P_CusName', FCusName),
            SF('P_MID', FStockNo),
            SF('P_MName', FStockName),
            SF('P_MType', FType),
            SF('P_PValue', FPData.FValue, sfVal),
            SF('P_PDate', sField_SQLServer_Now, sfVal),
            SF('P_PMan', FIn.FBase.FFrom.FUser),
            SF('P_FactID', FFactory),
            SF('P_PStation', FPData.FStation),
            SF('P_Direction', '��ʱ'),
            SF('P_PModel', sFlag_PoundLS),
            SF('P_Status', ''),
            SF('P_Valid', sFlag_Yes),
            SF('P_PrintNum', 1, sfVal)
            ], sTable_PoundLog, '', True);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('T_PrePValue', FPData.FValue, sfVal),
              SF('T_PrePTime', sField_SQLServer_Now, sfVal),
              SF('T_PrePMan', FIn.FBase.FFrom.FUser)
              ], sTable_Truck, SF('T_Truck', FTruck), False);
      FListA.Add(nSQL);
    end;  

  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFM then //����ë��
  begin
    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := nOut.FData;

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_Transfer;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    with nPound[0] do
    begin
      nSQL := MakeSQLByStr([
              SF('P_ID', FOut.FData),
              SF('P_Type', sFlag_DuanDao),
              SF('P_Truck', FTruck),
              SF('P_CusName', FCusName),
              SF('P_MID', FStockNo),
              SF('P_MName', FStockName),
              SF('P_MType', FType),
              SF('P_PValue', FPData.FValue, sfVal),
              SF('P_PDate', DateTime2Str(FPData.FDate)),
              SF('P_PMan', FPData.FOperator),
              SF('P_PStation', FPData.FStation),
              SF('P_MValue', FMData.FValue, sfVal),
              SF('P_MDate', sField_SQLServer_Now, sfVal),
              SF('P_MMan', FIn.FBase.FFrom.FUser),
              SF('P_MStation', FMData.FStation),

              SF('P_FactID', FFactory),
              SF('P_Direction', '�̵�'),
              SF('P_PModel', sFlag_PoundPD),
              SF('P_Status', ''),
              SF('P_Valid', sFlag_Yes),
              SF('P_PrintNum', 1, sfVal)
              ], sTable_PoundLog, '', True);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('T_ID', nOut.FData),
              SF('T_Card', FCard),
              SF('T_Truck', FTruck),
              SF('T_PID', FOut.FData),
              SF('T_SrcAddr', FMemo),
              SF('T_DestAddr', FYSValid),

              SF('T_PValue', FPData.FValue, sfVal),
              SF('T_PDate', DateTime2Str(FPData.FDate)),
              SF('T_PMan', FPData.FOperator),
              SF('T_MValue', FMData.FValue, sfVal),
              SF('T_MDate', sField_SQLServer_Now, sfVal),
              SF('T_MMan', FIn.FBase.FFrom.FUser),

              SF('T_Type', FType),
              SF('T_StockNo', FStockNo),
              SF('T_StockName', FStockName),
              SF('T_Man', FIn.FBase.FFrom.FUser),
              SF('T_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Transfer, '', True);
      FListA.Add(nSQL);
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
end;

//Date: 2014-09-15
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
class function TWorkerBusinessDuanDao.CallMe(const nCmd: Integer;
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
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessDuanDao, sPlug_ModuleBus);
end.

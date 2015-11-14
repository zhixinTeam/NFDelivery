{*******************************************************************************
  ����: dmzn@163.com 2013-12-04
  ����: ģ��ҵ�����
*******************************************************************************}
unit UWorkerBusinessCommand;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, UBase64;

type
  TBusWorkerQueryField = class(TBusinessWorkerBase)
  private
    FIn: TWorkerQueryFieldData;
    FOut: TWorkerQueryFieldData;
  public
    class function FunctionName: string; override;
    function GetFlagStr(const nFlag: Integer): string; override;
    function DoWork(var nData: string): Boolean; override;
    //ִ��ҵ��
  end;

  TMITDBWorker = class(TBusinessWorkerBase)
  protected
    FErrNum: Integer;
    //������
    FDBConn: PDBWorker;
    //����ͨ��
    FDataIn,FDataOut: PBWDataBase;
    //��γ���
    FDataOutNeedUnPack: Boolean;
    //��Ҫ���
    procedure GetInOutData(var nIn,nOut: PBWDataBase); virtual; abstract;
    //�������
    function VerifyParamIn(var nData: string): Boolean; virtual;
    //��֤���
    function DoDBWork(var nData: string): Boolean; virtual; abstract;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; virtual;
    //����ҵ��
  public
    function DoWork(var nData: string): Boolean; override;
    //ִ��ҵ��
    procedure WriteLog(const nEvent: string);
    //��¼��־
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
    //��ȡ������ʱ��
    function GetSerailID(var nData: string): Boolean;
    //��ȡ����
    function VerifyTruckNO(var nData: string): Boolean;
    //��֤�����Ƿ���Ч
    function IsSystemExpired(var nData: string): Boolean;
    //ϵͳ�Ƿ��ѹ���
    function SaveTruck(var nData: string): Boolean;
    //���泵����Truck��

    function GetStockBatcode(var nData: string): Boolean;
    function SaveStockBatcode(var nData: string): Boolean;
    //���α�Ź���

    function GetSQLQueryOrder(var nData: string): Boolean;
    //��ȡ������ѯ���
    function GetSQLQueryDispatch(var nData: string): Boolean;
    //��ȡ������ѯ���
    function GetSQLQueryCustomer(var nData: string): Boolean;
    //��ȡ�ͻ���ѯ���
    function GetTruckPoundData(var nData: string): Boolean;
    function SaveTruckPoundData(var nData: string): Boolean;
    //��ȡ������������
    function GetTruckPValue(var nData: string): Boolean;
    //��ȡ����Ԥ��Ƥ��
    function SaveTruckPValue(var nData: string): Boolean;
    //���泵��Ԥ��Ƥ��
    function GetOrderFHValue(var nData: string): Boolean;
    //��ȡ�����ѷ�����
    function GetOrderGYValue(var nData: string): Boolean;
    //��ȡ�����ѷ�����
    function SyncNC_ME25(var nData: string): Boolean;
    //����������
    function SyncNC_ME03(var nData: string): Boolean;
    //��Ӧ��������
    {$IFDEF MicroMsg}
    function SaveWeixinAccount(var nData: string): Boolean;
    //���������޸�΢���˻���Ϣ
    function DelWeixinAccount(var nData: string): Boolean;
    //ɾ��΢���˻���Ϣ
    function GetSQLQueryWeixin(var nData: string): Boolean;
    //��ȡ΢����Ϣ��ѯ���
    function GetWeixinReport(var nData: string): Boolean;
    //��ȡ΢�ű���
    {$ENDIF}
    function GetPoundBaseValue(var nData: string): Boolean;
    function IsDeDuctValid:Boolean;
    //ʹ�ð��۹���
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
//Parm: ���������
//Desc: ��ȡ�������ݿ��������Դ
function TMITDBWorker.DoWork(var nData: string): Boolean;
begin
  Result := False;
  FDBConn := nil;

  with gParamManager.ActiveParam^ do
  try
    FDBConn := gDBConnManager.GetConnection(FDB.FID, FErrNum);
    if not Assigned(FDBConn) then
    begin
      nData := '�������ݿ�ʧ��(DBConn Is Null).';
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
//Parm: �������;���
//Desc: ����ҵ��ִ����Ϻ����β����
function TMITDBWorker.DoAfterDBWork(var nData: string; nResult: Boolean): Boolean;
begin
  Result := True;
end;

//Date: 2012-3-18
//Parm: �������
//Desc: ��֤��������Ƿ���Ч
function TMITDBWorker.VerifyParamIn(var nData: string): Boolean;
begin
  Result := True;
end;

//Desc: ��¼nEvent��־
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
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
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
//Parm: ��������
//Desc: ִ��nDataҵ��ָ��
function TWorkerBusinessCommander.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
  end;

  case FIn.FCommand of
   cBC_ServerNow           : Result := GetServerNow(nData);
   cBC_GetSerialNO         : Result := GetSerailID(nData);
   cBC_IsSystemExpired     : Result := IsSystemExpired(nData);
   cBC_IsTruckValid        : Result := VerifyTruckNO(nData);

   cBC_SaveTruckInfo       : Result := SaveTruck(nData);
   cBC_GetStockBatcode     : Result := GetStockBatcode(nData);
   cBC_SaveStockBatcode    : Result := SaveStockBatcode(nData);
   
   cBC_GetSQLQueryOrder    : Result := GetSQLQueryOrder(nData);
   cBC_GetSQLQueryDispatch : Result := GetSQLQueryDispatch(nData);
   cBC_GetSQLQueryCustomer : Result := GetSQLQueryCustomer(nData);
   cBC_SyncME25            : Result := SyncNC_ME25(nData);
   cBC_SyncME03            : Result := SyncNC_ME03(nData);

   cBC_GetOrderFHValue     : Result := GetOrderFHValue(nData);
   cBC_GetOrderGYValue     : Result := GetOrderGYValue(nData);
   cBC_GetTruckPoundData   : Result := GetTruckPoundData(nData);
   cBC_SaveTruckPoundData  : Result := SaveTruckPoundData(nData);
   cBC_GetTruckPValue      : Result := GetTruckPValue(nData);
   cBC_SaveTruckPValue     : Result := SaveTruckPValue(nData);
   cBC_GetPoundBaseValue   : Result := GetPoundBaseValue(nData);


   {$IFDEF MicroMsg}
   cBC_GetSQLQueryWeixin   : Result := GetSQLQueryWeixin(nData);
   cBC_SaveWeixinAccount   : Result := SaveWeixinAccount(nData);
   cBC_DelWeixinAccount    : Result := DelWeixinAccount(nData);
   cBC_GetWeixinReport     : Result := GetWeixinReport(nData);
   {$ENDIF}
   else
    begin
      Result := False;
      nData := '��Ч��ҵ�����(Invalid Command).';
    end;
  end;
end;

//Date: 2014-09-05
//Desc: ��ȡ��������ǰʱ��
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
//Desc: �������������б��
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
        nData := 'û��[ %s.%s ]�ı�������.';
        nData := Format(nData, [FListA.Values['Group'], FListA.Values['Object']]);

        FDBConn.FConn.RollbackTrans;
        Exit;
      end;

      nP := FieldByName('B_Prefix').AsString;
      nB := FieldByName('B_Base').AsString;
      nInt := FieldByName('B_IDLen').AsInteger;

      if FIn.FExtParam = sFlag_Yes then //�����ڱ���
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
//Desc: ��֤ϵͳ�Ƿ��ѹ���
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
    nStr := 'ϵͳ�ѹ��� %d ��,����ϵ����Ա!!';
    nData := Format(nStr, [-nInt]);
    Exit;
  end;

  FOut.FData := IntToStr(nInt);
  //last days

  if nInt <= 7 then
  begin
    nStr := Format('ϵͳ�� %d ������', [nInt]);
    FOut.FBase.FErrDesc := nStr;
    FOut.FBase.FErrCode := sFlag_ForceHint;
  end;
end;

//Date: 2014-09-16
//Parm: ���ƺ�;
//Desc: ��֤nTruck�Ƿ���Ч
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
    nData := '��Ч�ĳ��ƺų���Ϊ3-10.';
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
      nData := Format('���ƺ�[ %s ]��Ч.', [nTruck]);
      Exit;
    end;
  end;

  nStr := 'Select T_Valid From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, nTruck]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  if FieldByName('T_Valid').AsString = sFlag_No then
  begin
    nData := '����[ %s ]�ѱ�����Ա���������.';
    nData := Format(nData, [nTruck]);
    Exit;
  end;

  Result := True;
end;

//------------------------------------------------------------------------------
//Date: 2015/9/15
//Parm:
//Desc: �Ƿ�ʹ�ð���
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
  //����ͨ��ʱ��ν��п۶�����

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
  //������۶�ʱ��Σ�������۶�
end;


//Date: 2014-10-02
//Parm: ���ƺ�[FIn.FData];
//Desc: ���泵����sTable_Truck��
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
//Parm: ���ϱ��[FIn.FData]
//Desc: ��ȡָ�����Ϻŵı��
function TWorkerBusinessCommander.GetStockBatcode(var nData: string): Boolean;
var nStr,nP,nUBrand,nUBatchAuto, nUBatcode: string;
    nBrand, nBatchOld, nBatchNew, nSelect: string;
    nKDValue, nValue: Double;
    nInt,nVal: Integer;
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

  if nUBatchAuto = sFlag_Yes then
  begin
    nStr := 'Select *,%s as B_Now From %s Where B_Stock=''%s''';
    nStr := Format(nStr, [sField_SQLServer_Now, sTable_Batcode, FIn.FData]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := '����[ %s ]�������ò�����.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;

      nStr := FieldByName('B_UseDate').AsString;
      if nStr = sFlag_Yes then
      begin
        nP := FieldByName('B_Prefix').AsString;
        nStr := Date2Str(FieldByName('B_Now').AsDateTime, False);

        nInt := FieldByName('B_Length').AsInteger;
        nVal := Length(nP + nStr) - nInt;

        if nVal > 0 then
        begin
          System.Delete(nStr, 1, nVal);
          FOut.FData := nP + nStr;
        end else
        begin
          nStr := StringOfChar('0', -nVal) + nStr;
          FOut.FData := nP + nStr;
        end;

        Result := True;
        Exit;
      end;

      nVal := Trunc(FieldByName('B_Now').AsDateTime) -
              Trunc(FieldByName('B_LastDate').AsDateTime);
      //ʱ���(����)

      nInt := FieldByName('B_Interval').AsInteger;
      if nInt < 1 then nInt := 1;
      nInt := Trunc(nVal / nInt);

      nVal := FieldByName('B_Incement').AsInteger;
      nInt := nInt * nVal;
      nVal := FieldByName('B_Base').AsInteger + nInt;

      nStr := FieldByName('B_Prefix').AsString + IntToStr(nVal);
      nStr := StringOfChar('0', FieldByName('B_Length').AsInteger - Length(nStr));

      FOut.FData := FieldByName('B_Prefix').AsString + nStr + IntToStr(nVal);
      Result := True;
      if nInt < 1 then Exit;

      nStr := 'Update %s Set B_Base=%d,B_LastDate=%s Where B_Stock=''%s''';
      nStr := Format(nStr, [sTable_Batcode, nVal, sField_SQLServer_Now, FIn.FData]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;

    Exit;
  end;
  //�Զ���ȡ���κ�

  FListA.Clear;
  FListA.Text := FIn.FExtParam;
  nBrand     := FListA.Values['Brand'];
  nBatchOld  := FListA.Values['Batch'];
  nKDValue   := StrToFloat(FListA.Values['Value']);

  nStr := 'Select * from %s Where D_Stock=''%s'' and D_Valid=''%s'' '+
          'Order By D_UseDate';
  nStr := Format(nStr, [sTable_BatcodeDoc, FIn.FData, sFlag_BatchInUse]);
  //xxxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '����[ %s ]���β�����.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    First;
    nBatchNew:='';
    nSelect:=sFlag_No;

    while not Eof do
    begin
      nStr := FieldByName('D_Brand').AsString;
      if (nUBrand=sFlag_Yes) and (nStr<>nBrand) then
      begin
        Next;
        Continue;
      end;
      //ʹ��Ʒ��ʱ��Ʒ�Ʋ���

      nValue := FieldByName('D_Plan').AsFloat - FieldByName('D_Sent').AsFloat +
                FieldByName('D_Rund').AsFloat - FieldByName('D_Init').AsFloat;
      if (nValue<=0) or ((nValue>0) and(nValue<nKDValue)) then
      begin
        Next;
        Continue;
      end;
      //ʣ����С�ڵ����㣬����ʣ����С�ڿ�����

      nStr := FieldByName('D_ID').AsString;
      if (nBatchOld<>'') and (nBatchOld=nStr) then
      begin
        nBatchNew := nStr;
        nSelect   := sFlag_Yes; 

        Break;
      end;
      //�ж�����봫��������ͬ���򽫸����λش�

      if nSelect <> sFlag_Yes then
      begin
        nBatchNew := nStr;
        nSelect   := sFlag_Yes;
      end;
      //ÿ��ѡ���һ����Ч�����κ�

      Next;
    end;

    if nSelect <> sFlag_Yes then
    begin
      nData := '��������������[ %s ]���β�����.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;  

    FOut.FData := nBatchNew;
    Result := True;
  end;
  //����Ʒ�ƺŻ�ȡ���κ�   
end;

//------------------------------------------------------------------------------
//Date: 2015/5/14
//Parm: 
//Desc: ��������������Ϣ
function TWorkerBusinessCommander.SaveStockBatcode(var nData: string): Boolean;
var nStr,nUBrand,nUBatchAuto,nBrand, nBatch, nUBatcode: string;
    nKDValue,nSentValue: Double;
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

  if (nUBatcode <> sFlag_Yes) or (nUBatchAuto = sFlag_Yes) then
  begin
    FOut.FData := '';
    Result := True;
    Exit;
  end;
  //�Զ���ȡ���κţ��������

  FListA.Clear;
  FListA.Text := FIn.FData;

  nBatch     := FListA.Values['Batch'];
  nBrand     := FListA.Values['Brand'];
  nKDValue   := StrToFloat(FListA.Values['Value']);

  nStr := 'Select * from %s Where D_ID=''%s'' and D_Valid=''%s'' ';
  nStr := Format(nStr, [sTable_BatcodeDoc, nBatch, sFlag_BatchInUse]);
  //xxxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '����[ %s ]������.';
      nData := Format(nData, [nBatch]);
      Exit;
    end;

    nStr := FieldByName('D_Brand').AsString;
    if (nUBrand=sFlag_Yes) and (nBrand <> nStr) then
    begin
      nData := '����[ %s ]��Ʒ��[ %s ]����Ӧ.';
      nData := Format(nData, [nBatch,nStr]);
      Exit;
    end;
    //Ʒ�ƴ���

    nSentValue := FieldByName('D_Sent').AsFloat;
    if FIn.FExtParam = sFlag_Yes then      //�����ѿ���
      nSentValue := nSentValue + nKDValue
    else if FIn.FExtParam = sFlag_No then  //ɾ���ѿ���
      nSentValue := nSentValue - nKDValue;
  end;
  //����Ʒ�ƺŻ�ȡ���κ�

  if nSentValue>=0 then
  begin
    nStr := 'Update %s Set D_Sent=%f Where D_ID=''%s'' ';
    nStr := Format(nStr, [sTable_BatcodeDoc, nSentValue, nBatch]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //�������κ��ѷ�������
  end;

  nStr := 'Update %s Set D_Valid=''%s'' ' +
          'Where (D_ID=''%s'') and (D_Plan-D_Sent+D_Rund+D_Init) < D_Warn';
  nStr := Format(nStr, [sTable_BatcodeDoc, sFlag_BatchOutUse, nBatch]);
  gDBConnManager.WorkerExec(FDBConn, nStr);
  //����Ԥ���������κ�

  nStr := 'Update %s Set D_LastDate=null Where D_Valid=''%s'' ' +
          'And D_LastDate is not NULL';
  nStr := Format(nStr, [sTable_BatcodeDoc, sFlag_BatchInUse]);
  gDBConnManager.WorkerExec(FDBConn, nStr);
  //����״̬�����κţ�ȥ����ֹʱ��

  Result := True;
end;

//Date: 2014-12-16
//Parm: ��ѯ����[FIn.FData];��ѯ����[FIn.FExtParam]
//Desc: ���ݲ�ѯ����,����ָ�����Ͷ�����SQL��ѯ���
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
      nData := '��������[ OrderInFact ]�ֵ���';
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

  if FIn.FData = '101' then           //���۶���
    nType := SF('VBILLTYPE', 'ME25')
  else if FIn.FData = '102' then      //�������뵥
    nType := SF('VBILLTYPE', 'ME25')
  else if FIn.FData = '103' then      //���۶��������뵥
    nType := SF('VBILLTYPE', 'ME25')

  else if FIn.FData = '201' then      //�ɹ�����
    nType := SF('VBILLTYPE', 'ME03')
  else if FIn.FData = '202' then      //�ɹ����뵥
    nType := SF('VBILLTYPE', 'ME03')
  else if FIn.FData = '203' then      //�ɹ����������뵥
       nType := SF('VBILLTYPE', 'ME03')
  else nType := '';

  if nType = '' then
  begin
    nData := Format('��Ч�Ķ�����ѯ����( %s ).', [FIn.FData]);
    Exit;
  end;

  FOut.FData := 'select ' +
     'pk_meambill_b as pk_meambill,VBILLCODE,VBILLTYPE,COPERATOR,user_name,' +  //������ͷ
     'TMAKETIME,NPLANNUM,cvehicle,vbatchcode,unitname,areaclname,t1.vdef10,' +  //��������(t1.vdef10:���)
     't1.vdef2,t1.vdef5,t1.pk_cumandoc,custcode,cmnecode,custname,t_cd.def30,'+ //������Ϣ(t1.vdef5:Ʒ��;t1.vdef2:��������)
     'invcode,invname,invtype ' +                                               //����
     'from meam_bill t1 ' +
     '  left join sm_user t_su on t_su.cuserid=t1.coperator ' +
     '  left join meam_bill_b t2 on t2.PK_MEAMBILL=t1.PK_MEAMBILL' +
     '  left join Bd_cumandoc t_cd on t_cd.pk_cumandoc=t1.pk_cumandoc' +
     '  left join bd_cubasdoc t_cb on t_cb.pk_cubasdoc=t_cd.pk_cubasdoc' +
     '  left join Bd_invbasdoc t_ib on t_ib.pk_invbasdoc=t2.PK_INVBASDOC' +
     '  left join bd_corp t_cp on t_cp.pk_corp=t1.pk_corp' +
     '  left join bd_areacl t_al on t_al.pk_areacl=t1.vdef1' +
     ' Where ';
  //xxxxx

  Result := True;
  //xxxxx

  nStr := FListA.Values['BillCode'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format('VBILLCODE Like ''%%%s%%''', [nStr]);
    Exit; //�����Ų�ѯ
  end;

  nStr := FListA.Values['MeamKeys'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format('pk_meambill_b In (%s)', [nStr]);
    Exit; //�����Ų�ѯ
  end;

  nStr := FListA.Values['NoDate'];
  if nStr = '' then
  begin
    nStr := '(TMAKETIME>=''%s'' And TMAKETIME<''%s'')';
    FOut.FData := FOut.FData + Format(nStr, [
                  FListA.Values['DateStart'],
                  FListA.Values['DateEnd']]);
    //��������

    FOut.FData := FOut.FData + ' And ';
    //ƴ����������
  end;

  if Pos('10', FIn.FData) = 1 then   //���ۿ��Ʒ��������Ϳ����֯
  begin
    nStr := AdjustListStrFormat(nWHGroup, '''', True, ',');
    if nStr<>'' then
      FOut.FData := FOut.FData + '(t2.pk_callbody_from In (' + nStr + ')) And ';
    //�����֯����

    nStr := AdjustListStrFormat(nWHID, '''', True, ',');
    if nStr<>'' then
      FOut.FData := FOut.FData + '(t2.pk_warehouse_from In (' + nStr + ')) And ';
    //�ֿⷢ������

    nStr := AdjustListStrFormat(nCorp, '''', True, ',');
    if nStr<>'' then
      FOut.FData := FOut.FData + '(t2.pk_corp_from In (' + nStr + ')) And ';
    //���ۿ��Ʒ�������
  end else
  if Pos('20', FIn.FData) = 1 then //�ɹ������ջ������Ϳ����֯
  begin
    nStr := AdjustListStrFormat(nWHGroup, '''', True, ',');
    if nStr<>'' then
      FOut.FData := FOut.FData + '(t2.pk_callbody_main In (' + nStr + ')) And ';
    //�����֯����

    nStr := AdjustListStrFormat(nWHID, '''', True, ',');
    if nStr<>'' then
      FOut.FData := FOut.FData + '(t2.pk_warehouse_main In (' + nStr + ')) And ';
    //�ֿ��ջ�����

    nStr := AdjustListStrFormat(nCorp, '''', True, ',');
    if nStr<>'' then
      FOut.FData := FOut.FData + '(t2.pk_corp_main In (' + nStr + ')) And ';
    //�����ջ�����
  end;

  FOut.FData := FOut.FData + ' (' + nType + ')';
  //��������

  nStr := FListA.Values['QueryAll'];
  if nStr = '' then
  begin
    FOut.FData := FOut.FData + ' And (crowstatus=0 And VBILLSTATUS=1 ' +
                  'And t1.dr=0 And t2.dr=0)';
    //��ǰ��Ч����
  end;

  nStr := FListA.Values['CustomerID'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format(' And custcode=''%s''', [nStr]);
    //���ͻ����
  end;

  nStr := FListA.Values['Filter'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + ' And (' + DecodeBase64(nStr) + ')';
    //��ѯ����
  end;

  nStr := FListA.Values['Order'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + ' Order By ' + nStr;
    //��������
  end;
end;

//Date: 2015-01-08
//Parm: ��ѯ����[FIn.FExtParam]
//Desc: ���ݲ�ѯ��������������SQL��ѯ���
function TWorkerBusinessCommander.GetSQLQueryDispatch(var nData: string): Boolean;
var nStr: string;
begin
  FOut.FData := 'select ' +
     'pk_meambill_b as pk_meambill,VBILLCODE,VBILLTYPE,COPERATOR,user_name,' + //������ͷ
     'TMAKETIME,NPLANNUM,cvehicle,vbatchcode,t1.pk_corp_main,unitname,' +      //��������
     'invcode,invname,invtype ' +                                              //����
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
    Exit; //�����Ų�ѯ
  end;

  nStr := FListA.Values['MeamKeys'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format(' And pk_meambill_b In (%s)', [nStr]);
    Exit; //�����Ų�ѯ
  end;

  nStr := FListA.Values['NoDate'];
  if nStr = '' then
  begin
    nStr := ' And (TMAKETIME>=''%s'' And TMAKETIME<''%s'')';
    FOut.FData := FOut.FData + Format(nStr, [
                  FListA.Values['DateStart'],
                  FListA.Values['DateEnd']]);
    //��������
  end;

  nStr := FListA.Values['QueryAll'];
  if nStr = '' then
  begin
    FOut.FData := FOut.FData + ' And (crowstatus=0 And VBILLSTATUS=1)';
    //��ǰ��Ч����
  end;

  nStr := FListA.Values['Customer'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format(' And unitname Like ''%%%s%%''', [nStr]);
    //���ͻ����
  end;

  nStr := FListA.Values['Filter'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + ' And (' + DecodeBase64(nStr) + ')';
    //��ѯ����
  end;

  nStr := FListA.Values['Order'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + ' Order By ' + nStr;
    //��������
  end;
end;

//Date: 2014-12-18
//Parm: �ͻ����[FIn.FData];�ͻ�����[FIn.FExtParam];
//Desc: ����ģ����ѯ�ͻ���SQL���
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
    //�ͻ����ģ��
  end;

  if FIn.FExtParam <> '' then
  begin
    nStr := '(custname like ''%%%s%%'')';
    if FIn.FData <> '' then
      nStr := ' or ' + nStr;
    FOut.FData := FOut.FData + Format(nStr, [FIn.FExtParam]);
    //�ͻ�����ģ��
  end;

  FOut.FData := FOut.FData + ' Group By custcode,custname,cmnecode';
end;

//Date: 2014-12-24
//Parm: ������(���)[FIn.FData]
//Desc: ��ȡ�������ѷ�����
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
  //nnet:������;nassnum:������

  FListB.Clear;
  nWorker := nil;
  try
    FListA.Text := DecodeBase64(FIn.FData);
    for nInt:=0 to FListA.Count - 1 do
      FListB.Values[FListA[nInt]] := '0';
    //Ĭ���ѷ�����Ϊ0

    nID := AdjustListStrFormat2(FListA, '''', True, ',', False);
    nStr := ' and pk_sourcebill_b in (%s) group by poundb.pk_sourcebill_b';
    nStr := nSQL + Format(nStr, [nID]);
    //ִ����     

    with gDBConnManager.SQLQuery(nStr, nWorker, sFlag_DB_NC) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nOrder := FieldByName('norder').AsString;
        FListB.Values[nOrder] := FieldByName('nnet').AsString;
        //�����ѷ���

        Next;
      end;
    end;

    nStr := ' and ( poundh.bbillreturn = ''Y'') and pk_sourcebill_b in (%s) ' +
            'group by poundb.pk_sourcebill_b';
    nStr := nSQL + Format(nStr, [nID]);
    //�˻���

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
        //ȡ�ѷ�����

        nVal := nVal - FieldByName('nnet').AsFloat;
        //�ѷ�����=�ѷ����� - ԭ���˻���

        FListB.Values[nOrder] := FloatToStr(nVal);
        //�����ѷ���

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
    //������

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
        //ȡ�ѷ�����

        nVal := nVal + FieldByName('B_Freeze').AsFloat;
        //�ѷ�����=�ѷ����� + ������

        FListB.Values[nOrder] := FloatToStr(nVal);
        //�����ѷ���

        Next;
      end;
    end;
  end else FListB.Values['QueryFreeze'] := sFlag_No;

  FOut.FData := PackerEncodeStr(FListB.Text);
  Result := True;
end;

//Date: 2015-01-08
//Parm: ������(���)[FIn.FData]
//Desc: ��ȡ�������ѷ�����
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
  //nnet:������;nassnum:������

  FListB.Clear;
  nWorker := nil;
  try
    FListA.Text := DecodeBase64(FIn.FData);
    for nInt:=0 to FListA.Count - 1 do
      FListB.Values[FListA[nInt]] := '0';
    //Ĭ���ѷ�����Ϊ0

    nID := AdjustListStrFormat2(FListA, '''', True, ',', False);
    nStr := ' and pk_sourcebill_b in (%s) group by poundb.pk_sourcebill_b';
    nStr := nSQL + Format(nStr, [nID]);
    //ִ����     

    with gDBConnManager.SQLQuery(nStr, nWorker, sFlag_DB_NC) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nOrder := FieldByName('norder').AsString;
        FListB.Values[nOrder] := FieldByName('nnet').AsString;
        //�����ѷ���

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
//Parm: ���ƺ�[FIn.FData]
//Desc: ��ȡָ�����ƺŵĳ�Ƥ����(ʹ�����ģʽ,δ����)
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
//Parm: ��������[FIn.FData]
//Desc: ��ȡָ�����ƺŵĳ�Ƥ����(ʹ�����ģʽ,δ����)
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
  //��������

  CallMe(cBC_GetPoundBaseValue, '', '' , @nOut);
  nBaseValue := StrToFloat(nOut.FData);
  //��ȡ�ذ���������

  with nPound[0] do
  begin
    if not CallMe(cBC_IsTruckValid, FTruck, '', @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    nProvide := (FID <> '') and (FID = FZhiKa);
    //�Ƿ�Ӧ

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
    //������������

    if FPoundID = '' then
    begin
      TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, FTruck, '', @nOut);
      //���泵�ƺ�

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
              SF('P_Direction', '����'),
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
    //����Ԥ��Ƥ��

    if (FPData.FValue > 0) and (FMData.FValue > 0) then
    begin
      nStr := 'Select D_CusID,D_Value,D_Type From %s ' +
              'Where D_Stock=''%s'' And D_Valid=''%s''';
      nStr := Format(nStr, [sTable_Deduct, FStockNo, sFlag_Yes]);

      if IsDeDuctValid then                         //������֤�Ƿ�������
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

          nMData.FValue := (FMData.FValue*1000 - nVal*1000) / 1000;
          if FMData.FValue > FPData.FValue then
               FMData.FValue := (FMData.FValue*1000 - nVal*1000) / 1000
          else FPData.FValue := (FPData.FValue*1000 - nVal*1000) / 1000;

          nMData.FValue := FormatValue(nMData.FValue*1000, nBaseValue) / 1000;
          FMData.FValue := FormatValue(FMData.FValue*1000, nBaseValue) / 1000;
          FPData.FValue := FormatValue(FPData.FValue*1000, nBaseValue) / 1000;
          //�ٴν�������
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
          //����ʱ��ȡԤ��Ƥ��
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
          //����ʱ,����Ƥ�ش�,����Ƥë������
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
        //ͬ����Ӧ��NC
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
  //���Ƽ�¼�����ڣ���ʹ��Ԥ��Ƥ�أ������µ�Ƥ�ص����ϵ�Ԥ�ã��򲻸���

  nStr := MakeSQLByStr([SF('T_PrePValue', nItem.FPrePValue, sfVal),
          SF('T_PrePTime', sField_SQLServer_Now, sfVal),
          SF('T_PrePMan', nItem.FPrePMan)],
          sTable_Truck, SF('T_Truck', nItem.FPreTruck), False);

  gDBConnManager.WorkerExec(FDBConn, nStr);
end;

//------------------------------------------------------------------------------
//Desc: �����ֶ�����
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
//Parm: ������(���)[FIn.FData]
//Desc: ͬ���������������ݵ�NC�����񵥱���
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
          'L_PMan,L_MValue,L_MDate,L_MMan,L_OutFact,L_Date,P_ID From %s ' +
          '  Left Join %s On P_Bill=L_ID ' +
          'Where L_ID In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, sTable_PoundLog, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := '������[ %s ]��Ϣ�Ѷ�ʧ.';
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

        if FListA.IndexOf(FZhiKa) < 0 then
          FListA.Add(FZhiKa);
        //������

        FPoundID := FieldByName('P_ID').AsString;
        //�񵥱��
        if FPoundID = '' then
        begin
          if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
            raise Exception.Create(nOut.FData);
          FPoundID := nOut.FData;
        end;

        nDateMin := Str2Date('2000-01-01');
        //��С���ڲο�

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
      end;

      Inc(nIdx);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  nStr := AdjustListStrFormat2(FListA, '''', True, ',', False, False);
  //�����б�

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
        nData := '������[ %s ]��Ϣ�Ѷ�ʧ.';
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
        //������ʧ���账��

        if nBills[nIdx].FType = 'ME09' then
             nBills[nIdx].FType := '0001ZA1000000001VYRH'
        else nBills[nIdx].FType := '0001AA10000000009NEY';
        //ҵ������תҵ��ģʽ

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
                MakeField(nDS, 'vdef7', 0),
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
          nData := 'ͬ��NC�����񵥴���,����: ' + E.Message;
          Exit;
        end;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;

//Date: 2015-01-08
//Parm: �񵥺�(����)[FIn.FData]
//Desc: ͬ��ԭ�Ϲ������ݵ�NC�����񵥱���
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
      nData := '���ص���[ %s ]��Ϣ�Ѷ�ʧ.';
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

      if FZhiKa = '' then
      begin
        nData := '���ص���[ %s ]�Ŷ�����Ϊ��.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end; 

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

      FValue := Float2Float(FMData.FValue - FPData.FValue, cPrecision, False);
      //��Ӧ��
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
        nData := 'NC����[ %s ]��Ϣ�Ѷ�ʧ.';
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
          nData := 'ͬ��NC�����񵥴���,����: ' + E.Message;
          Exit;
        end;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;
{$IFDEF MicroMsg}
//Date: 2015/4/17
//Parm:
//Desc: ����΢���˻���Ϣ
function TWorkerBusinessCommander.SaveWeixinAccount(var nData: string): Boolean;
var nSQL: string;
    nErr: Integer;
    nWorker: PDBWorker;
    nItem: TWeiXinAccount;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  nWorker := gDBConnManager.GetConnection(sFlag_DB_WX, nErr);
  try
    if not Assigned(nWorker) then
    begin
      WriteLog('����WX���ݿ�ʧ��(DBConn Is Null).');
      Exit;
    end;

    if not nWorker.FConn.Connected then
      nWorker.FConn.Connected := True;
    //conn db

    AnalyseWXAccountItem(FIn.FData, nItem);
    with nItem do
    begin
      if FID = '' then
      begin
        FListC.Clear;
        FListC.Values['Group'] := sFlag_BusGroup;
        FListC.Values['Object'] := sFlag_WeiXin;

        if not CallMe(cBC_GetSerialNO,
              FListC.Text, sFlag_No, @nOut) then
          raise Exception.Create(nOut.FData);
        //xxxxx

        FID := nOut.FData;
        nSQL := MakeSQLByStr([SF('M_ID', FID),
            SF('M_WXName', FWXName),
            SF('M_WXFactory', FWXFact),

            SF('M_Comment', FComment),
            SF('M_IsValid', FIsValid),

            SF('M_AttentionID', FAttention),
            SF('M_AttentionType', FAttenType)], sTable_WeixinMatch, '', True);
      end
      else
      begin
        nSQL := MakeSQLByStr([SF('M_WXName', FWXName),
            SF('M_WXFactory', FWXFact),

            SF('M_Comment', FComment),
            SF('M_IsValid', FIsValid),

            SF('M_AttentionID', FAttention),
            SF('M_AttentionType', FAttenType)
            ], sTable_WeixinMatch, SF('M_ID', FID), False);
        //xxxxx
      end;
    end;

    gDBConnManager.WorkerExec(nWorker, nSQL);
    FOut.FData := nItem.FID;  //����
    Result := True;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;

//Date: 2015/4/17
//Parm:
//Desc: ɾ��΢���˻�
function TWorkerBusinessCommander.DelWeixinAccount(var nData: string): Boolean;
var nSQL: string;
    nErr: Integer;
    nWorker: PDBWorker;
begin
  Result := False;
  nWorker := gDBConnManager.GetConnection(sFlag_DB_WX, nErr);
  try
    if not Assigned(nWorker) then
    begin
      WriteLog('����WX���ݿ�ʧ��(DBConn Is Null).');
      Exit;
    end;

    if not nWorker.FConn.Connected then
      nWorker.FConn.Connected := True;
    //conn db

    FIn.FData := UpperCase(FIn.FData);
    nSQL := 'Delete From %s Where M_ID=''%s''';
    nSQL := Format(nSQL, [sTable_WeixinMatch, FIn.FData]);
    gDBConnManager.WorkerExec(nWorker, nSQL);
    Result := True;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;
//Date: 2015/4/17
//Parm: ��ѯ��������(FIn.FData):��ѯָ��(FIn.FExtParam);
//Desc: ��ȡ΢�Ų�ѯ���
function TWorkerBusinessCommander.GetSQLQueryWeixin(var nData: string): Boolean;
var nStr,nCmd: string;
    nCmdIType: Integer;
begin
  Result := False;

  FListA.Clear;
  FListA.Text := DecodeBase64(FIn.FData);

  nCmd := FListA.Values['Command'];
  if nCmd = '' then
  begin
    WriteLog('΢�Ų�ѯָ���Ϊ��[Command is NULL].');
    Exit;
  end;

  nCmdIType := StrToIntDef(nCmd, 0);
  case nCmdIType of
  0: FOut.FData := 'Select Count(1) as TCount, P_MName, '+             //����,����
    'Sum(P_MValue) as TMValue, Sum(P_PValue) as TPValue, ' +           //Ƥë��
    'Sum(P_LimValue) as TLimValue, Sum(P_MValue-P_PValue) as TSent ' + //����,����
    'From Sys_PoundLog ' +
    'Where 1=1 ';  //�����ѯ
  else
    WriteLog('��δ��ͨ�ù��ܣ�');
    Exit;
  end;

  nStr := FListA.Values['NoDate'];
  if nStr = '' then
  begin
    nStr := ' And (P_MDate>=''%s'' And P_MDate<''%s'')';
    FOut.FData := FOut.FData + Format(nStr, [
                  FListA.Values['DateStart'],
                  FListA.Values['DateEnd']]);
    //��������
  end;
  //����ͳ��ë��ʱ��β�ѯ

  nStr := FListA.Values['Filter'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + ' And (' + DecodeBase64(nStr) + ')';
  end; //��ѯ����

  nStr := FListA.Values['Group'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + 'Group By ' + nStr;
  end; //�����ѯ
end;

function TWorkerBusinessCommander.GetWeixinReport(var nData: string): Boolean;
var nStr,nSQL: string;
begin
  FListA.Clear;
  FListA.Text := PackerDecodeStr(FIn.FData);

  nStr := 'Select Count(1) as TCount, P_MName, '+                      //����,����
    'Sum(P_MValue) as TMValue, Sum(P_PValue) as TPValue, ' +           //Ƥë��
    'Sum(P_LimValue) as TLimValue, Sum(P_MValue-P_PValue) as TSent ' + //����,����
    'From %s Where P_MType=''%s'' ';                                              //
    //ɢװ����ͳ��
  nSQL := Format(nStr, [sTable_PoundLog, sFlag_San]);

  if FListA.Values['AttentionType'] = sFlag_AttentionCust then
  begin
    nStr := Format('And P_CusID=''%s'' ', [FListA.Values['AttentionID']]);
    nSQL := nSQL + nStr;
  end;
  //�ͻ���ѯ

  nStr := FListA.Values['NoDate'];
  if nStr = '' then
  begin
    nStr := 'And P_MDate>=''%s'' and P_MDate<''%s'' ';
    nStr := Format(nStr, [FListA.Values['DateStart'],
      FListA.Values['DateEnd']]);

    nSQL := nSQL + nStr;
  end;

  nStr := FListA.Values['Factory'];
  if nStr <> '' then
  begin
    nStr := Format('And P_FactID=''%s''', [nStr]);
    nSQL := nSQL + nStr;
  end;

  nSQL := nSQL + 'Group by P_MName';
  //xxxxxx

  FListC.Clear;
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount>0 then
    begin
      First;

      while not Eof do
      begin
        with FListB do
        begin
          Clear;

          Values['Count'] := IntToStr(FieldByName('TCount').AsInteger);
          Values['Value'] := FloatToStr(FieldByName('TSent').AsFloat);
          Values['StockName'] := FieldByName('P_MName').AsString;
        end;

        FListC.Add(PackerEncodeStr(FListB.Text));
        Next;
      end;
    end;
  end;
//------------------------------------------------------------------------------

  nStr := 'Select Count(1) as TCount, L_StockName, '+                  //����,����
    'Sum(L_MValue) as TMValue, Sum(L_PValue) as TPValue, ' +           //Ƥë��
    'Sum(L_Value) as TLimValue, Sum(L_MValue-L_PValue) as TSent ' +    //����,����
    'From %s Where L_Type=''%s'' ';                                    //
  //��װ����ͳ��
  nSQL := Format(nStr, [sTable_Bill, sFlag_Dai]);

  if FListA.Values['AttentionType'] = sFlag_AttentionCust then
  begin
    nStr := Format('And L_CusID=''%s'' ', [FListA.Values['AttentionID']]);
    nSQL := nSQL + nStr;
  end;
  //�ͻ���ѯ

  nStr := FListA.Values['NoDate'];
  if nStr = '' then
  begin
    nStr := 'And L_OutFact>=''%s'' and L_OutFact<''%s'' ';
    nStr := Format(nStr, [FListA.Values['DateStart'],
      FListA.Values['DateEnd']]);

    nSQL := nSQL + nStr;
  end;

  nSQL := nSQL + 'Group By L_StockName';
  //xxxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount>0 then
    begin
      First;

      while not Eof do
      begin
        with FListB do
        begin
          Clear;

          Values['Count'] := IntToStr(FieldByName('TCount').AsInteger);
          Values['Value'] := FloatToStr(FieldByName('TLimValue').AsFloat);
          Values['StockName'] := FieldByName('L_StockName').AsString;
        end;

        FListC.Add(PackerEncodeStr(FListB.Text));
        Next;
      end;
    end;
  end;

  FOut.FData := PackerEncodeStr(FListC.Text);
  Result := True;
end;
{$ENDIF}
//------------------------------------------------------------------------------
//Date: 2015/6/18
//Parm: 
//Desc: ��ȡ������������
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
//Parm: ԭʼ���ݣ�����������Χ
//Desc: ��ʽ������
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

initialization
  gBusinessWorkerManager.RegisteWorker(TBusWorkerQueryField, sPlug_ModuleBus);
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessCommander, sPlug_ModuleBus);
end.

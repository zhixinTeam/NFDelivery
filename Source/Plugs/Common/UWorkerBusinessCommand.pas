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
  USysDB, UMITConst, UBase64, UWorkerClientWebChat, UMgrQueue, DateUtils
  {$IFDEF HardMon}, UMgrHardHelper, UWorkerHardware{$ENDIF};

type

  TLineItem = record
      FID: string;//ͨ����
      FGroupID: string;//��������
      FTruckCount: Integer;//ͨ����������
      FMaxCount: Integer;//ͨ���������
      FValid: Boolean;//�Ƿ�����
    end;

  TLineItems = array of TLineItem;
  //װ�����б�

  PZTLineItem = ^TZTLineItem;
  TZTLineItem = record
    FID       : string;      //���
    FName     : string;      //����
    FStock    : string;      //Ʒ��
    FWeight   : Integer;     //����
    FValid    : Boolean;     //�Ƿ���Ч
    FPrinterOK: Boolean;     //�����
  end;

  PZTTruckItem = ^TZTTruckItem;
  TZTTruckItem = record
    FTruck    : string;      //���ƺ�
    FLine     : string;      //ͨ��
    FBill     : string;      //�����
    FValue    : Double;      //�����
    FDai      : Integer;     //����
    FTotal    : Integer;     //����
    FInFact   : Boolean;     //�Ƿ����
    FIsRun    : Boolean;     //�Ƿ�����
  end;

  TZTLineItems = array of TZTLineItem;
  TZTTruckItems = array of TZTTruckItem;

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
    FLineItems: TLineItems;
    //�����б�
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
    function GetCardUsed(var nData: string): Boolean;
    //��ȡ��Ƭ����
    function IsSystemExpired(var nData: string): Boolean;
    //ϵͳ�Ƿ��ѹ���
    function SaveTruck(var nData: string): Boolean;
    //���泵����Truck��
    function Login(var nData: string):Boolean;
    function LogOut(var nData: string): Boolean;
    //��¼ע���������ƶ��ն�
    function GetStockBatcode(var nData: string): Boolean;
    //���α�Ź���
    function GetStockBatcodeByLine(var nData: string): Boolean;
    //���α�Ź���(�ֳ���ȡ����)
    function SaveBatEvent(var nData: string): Boolean;
    //���α�Ź���(�ֳ���ȡ����)
    function GetSQLQueryOrder(var nData: string): Boolean;
    //��ȡ������ѯ���
    function GetSQLQueryDispatch(var nData: string): Boolean;
    //��ȡ������ѯ���
    function GetSQLQueryCustomer(var nData: string): Boolean;
    //��ȡ�ͻ���ѯ���
    function GetTruckPoundData(var nData: string): Boolean;
    function SaveTruckPoundData(var nData: string): Boolean;
    //��ȡ������������
    function GetStationPoundData(var nData: string): Boolean;
    function SaveStationPoundData(var nData: string): Boolean;
    function GetStationTruckValue(var nData: string): Boolean;
    //��ȡ�𳵺��������
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
    function SyncNC_HaulBack(var nData: string): Boolean;
    //�ؿ�ҵ�񵽰���
    function GetPoundBaseValue(var nData: string): Boolean;
    function IsDeDuctValid:Boolean;
    //ʹ�ð��۹���
    function VerifySnapTruck(var nData: string): Boolean;
    //���Ʊȶ�
    function AutoGetLineGroup(var nData: string): Boolean;
    //��ȡװ���߷���
    function GetTruckList(var nData: string): Boolean;
    //��ȡ������Ϣ
    function TruckManulSign(var nData: string): Boolean;
    //��ȡ������Ϣ
    function GetGroupByArea(var nData: string): Boolean;
    //��ȡ�����������
    function GetUnLoadingPlace(var nData: string): Boolean;
    //��ȡж���ص㼰ǿ������ж���ص�����
    function VerifySanCardUseCount(var nData: string): Boolean;
    //��ȡɢװˢ���������ü�У��

    //-------------------��DL��Web�̳Ƿ����ѯ----------------------------------
    function SendEventMsg(var nData:string):boolean;
    //����ģ����Ϣ
    function GetCustomerInfo(var nData:string):boolean;
    //��ȡ�ͻ�ע����Ϣ
    function EditShopCustom(var nData:string):boolean;
    //����(�������)�̳��û�
    function GetShopOrdersByID(var nData:string):boolean;
    //����˾�����֤��ȡ������Ϣ
    function GetShopOrderByNO(var nData:string):boolean;
    //���ݶ����Ż�ȡ������Ϣ
    function EditShopOrderInfo(var nData:string):Boolean;
    //�޸Ķ�����Ϣ

    //-------------------��Web�̳���DL�����ѯ----------------------------------
    function GetOrderList(var nData:string):Boolean;
    //��ȡ���۶����б�
    function GetOrderListNC(var nData:string):Boolean;
    //��ȡ���۶����б�
    function GetPurchaseList(var nData:string):Boolean;
    function GetPurchaseListNC(var nData:string):Boolean;
    //��ȡ�ɹ������б�
    function VerifyPrintCode(var nData: string): Boolean;
    //��֤������Ϣ
    function GetWaitingForloading(var nData:string):Boolean;
    //������װ��ѯ

    //-------------------��DL��DL�����ѯ---------------------------------------
    function DLSaveShopInfo(var nData:string):Boolean;
    //����ͬ����Ϣ
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
   cBC_GetCardUsed         : Result := GetCardUsed(nData);
   cBC_UserLogin           : Result := Login(nData);
   cBC_UserLogOut          : Result := LogOut(nData);

   cBC_SaveTruckInfo       : Result := SaveTruck(nData);
   cBC_GetStockBatcode     : Result := GetStockBatcode(nData);
   cBC_GetStockBatcodeByLine: Result := GetStockBatcodeByLine(nData);
   cBC_SaveBatEvent        : Result := SaveBatEvent(nData);

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
   cBC_VerifySnapTruck     : Result := VerifySnapTruck(nData);
   cBC_AutoGetLineGroup    : Result := AutoGetLineGroup(nData);

   cBC_GetTruckList        : Result := GetTruckList(nData);
   cBC_TruckManulSign      : Result := TruckManulSign(nData);

   cBC_GetGroupByArea      : Result := GetGroupByArea(nData);

   cBC_GetUnLodingPlace    : Result := GetUnLoadingPlace(nData);
   cBC_VerifySanCardUseCount: Result := VerifySanCardUseCount(nData);

   cBC_WebChat_SendEventMsg     :Result := SendEventMsg(nData);                //΢��ƽ̨�ӿڣ�����ģ����Ϣ
   cBC_WebChat_GetCustomerInfo  :Result := GetCustomerInfo(nData);             //΢��ƽ̨�ӿڣ���ȡ�̳��˻�ע����Ϣ
   cBC_WebChat_EditShopCustom   :Result := EditShopCustom(nData);              //΢��ƽ̨�ӿڣ������̳��û�

   cBC_WebChat_GetShopOrdersByID:Result := GetShopOrdersByID(nData);           //΢��ƽ̨�ӿڣ�ͨ��˾�����֤�Ż�ȡ�̳Ƕ�����Ϣ
   cBC_WebChat_GetShopOrderByNO :Result := GetShopOrderByNO(nData);            //΢��ƽ̨�ӿڣ�ͨ����ά���ȡ�̳Ƕ�����Ϣ
   cBC_WebChat_EditShopOrderInfo:Result := EditShopOrderInfo(nData);           //΢��ƽ̨�ӿڣ��޸��̳Ƕ�����Ϣ

   cBC_WebChat_GetOrderList     :Result := GetOrderList(nData);                //΢��ƽ̨�ӿڣ���ȡ���۶����б�
   cBC_WebChat_GetPurchaseList  :Result := GetPurchaseList(nData);             //΢��ƽ̨�ӿڣ���ȡ�ɹ������б�
   cBC_WebChat_VerifPrintCode   :Result := VerifyPrintCode(nData);             //΢��ƽ̨�ӿڣ���ȡ��α����Ϣ
   cBC_WebChat_WaitingForloading:Result := GetWaitingForloading(nData);        //΢��ƽ̨�ӿڣ���ȡ�Ŷ���Ϣ

   cBC_WebChat_DLSaveShopInfo   :Result := DLSaveShopInfo(nData);              //΢��ƽ̨
   cBC_GetPurchaseList          :Result := GetPurchaseListNC(nData);           //��ȡ�ɹ������б�
   cBC_GetOrderList             :Result := GetOrderListNC(nData);              //��ȡ���۶����б�
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
    nIsTrans: Boolean;
    nStr,nP,nB: string;
begin
  nIsTrans := FDBConn.FConn.InTransaction;
  if not nIsTrans then FDBConn.FConn.BeginTrans;
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

        if not nIsTrans then
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

    if not nIsTrans then
      FDBConn.FConn.CommitTrans;
    Result := True;
  except
    if not nIsTrans then
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
  if (nIdx < 3) or (nIdx > 20) then
  begin
    nData := '��Ч�ĳ��ƺų���Ϊ3-20.';
    Exit;
  end;

  {$IFNDEF NoVerifyTruckNo}
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
  {$ENDIF}

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

//Date: 2014-09-05
//Desc: ��ȡ��Ƭ���ͣ�����S;�ɹ�P;����O
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
    if RecordCount < 1 then
    begin
      nStr := '�ſ���[ %s ]������.';
      nData := Format(nStr, [FIn.FData]);
      Exit;
    end;

    FOut.FData := Fields[0].AsString;
    Result := True;
  end;
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
var nStr,nP,nUBrand,nUBatchAuto, nUBatcode, nType, nLineGroup, nBatStockNo: string;
    nBatchNew, nSelect, nUBatStockGroup, nUAutoBrand, nSeal, nNoBatGroupStock: string;
    nVal, nPer: Double;
    nInt, nInc, nRID: Integer;
    nNew: Boolean;

    //���������κ�
    function NewBatCode(const nBtype:string = 'C'): string;
    var nSQL, nTmp: string;
    begin
      {$IFDEF AutoGetLineGroup}
      nSQL := 'Select * From %s Where B_Stock=''%s'' And B_Type=''%s'' ' +
              'And B_LineGroup = ''%s'' And B_Valid=''%s'' And B_BrandGroup=''%s''';
      nSQL := Format(nSQL, [sTable_Batcode, nBatStockNo, nBtype, nLineGroup,
                            sFlag_Yes, FListA.Values['Brand']]);
      {$ELSE}
      if nUAutoBrand = sFlag_Yes then
      begin
        nSQL := 'Select * From %s Where B_Stock=''%s'' And B_Type=''%s'' And B_BrandGroup=''%s''';
        nSQL := Format(nSQL, [sTable_Batcode, FIn.FData, nBtype, FListA.Values['Brand']]);
      end
      else
      begin
        nSQL := 'Select * From %s Where B_Stock=''%s'' And B_Type=''%s''';
        nSQL := Format(nSQL, [sTable_Batcode, FIn.FData, nBtype]);
      end;
      {$ENDIF}

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

      {$IFDEF AutoGetLineGroup}
      nTmp := Format('B_Stock=''%s'' And B_Type=''%s'' And B_LineGroup=''%s'' And B_Valid=''%s'' And B_BrandGroup=''%s''',
                     [nBatStockNo, nBtype, nLineGroup, sFlag_Yes, FListA.Values['Brand']]);
      {$ELSE}
      if nUAutoBrand = sFlag_Yes then
        nTmp := Format('B_Stock=''%s'' And B_Type=''%s'' And B_BrandGroup=''%s''', [FIn.FData, nBtype, FListA.Values['Brand']])
      else
        nTmp := Format('B_Stock=''%s'' And B_Type=''%s''', [FIn.FData, nBtype]);
      {$ENDIF}
      nSQL := MakeSQLByStr([SF('B_Batcode', Result),
                SF('B_FirstDate', sField_SQLServer_Now, sfVal),
                SF('B_HasUse', 0, sfVal),
                SF('B_LastDate', sField_SQLServer_Now, sfVal)
                ], sTable_Batcode, nTmp, False);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    //Desc: ����¼
    procedure OutuseCode(const nID: string);
    begin
      nStr := 'Update %s Set D_Valid=''%s'',D_LastDate=%s Where D_ID=''%s''';
      nStr := Format(nStr, [sTable_BatcodeDoc, sFlag_BatchOutUse,
              sField_SQLServer_Now, nID]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;
begin
  Result := False;

  nStr := 'Select D_Memo, D_Value from %s Where D_Name=''%s'' and ' +
          '(D_Memo=''%s'' or D_Memo=''%s'' or D_Memo=''%s'' or D_Memo=''%s'' or D_Memo=''%s'')';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam,
                        sFlag_BatchAuto, sFlag_BatchBrand,
                        sFlag_BatchValid, sFlag_BatchStockGroup, sFlag_AutoBatBrand]);
  //xxxxxx

  nUBatchAuto := sFlag_Yes;
  nUBatcode := sFlag_No;
  nUBrand := sFlag_No;
  nUBatStockGroup := sFlag_Yes;
  nUAutoBrand := sFlag_No;//�Զ�����ʹ��Ʒ��
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

      if Fields[0].AsString = sFlag_BatchStockGroup then
        nUBatStockGroup  := Fields[1].AsString;

      if Fields[0].AsString = sFlag_AutoBatBrand then
        nUAutoBrand  := Fields[1].AsString;

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

  WriteLog('���λ�ȡ(�����):' + FListA.Values['Value']);

  if nUBatchAuto = sFlag_Yes then
  begin
    if FListA.Values['Type'] ='' then
          nType := sFlag_TypeCommon
    else  nType := FListA.Values['Type'];

    if (nType <> '') and (nType <> sFlag_TypeCommon) and
       (nType <> sFlag_TypeShip) and (nType <> sFlag_TypeStation) then
      nType := sFlag_TypeCommon;
    //default

    {$IFDEF AutoGetLineGroup}
    nStr := 'Select D_ParamB From %s Where D_Name=''%s'' and D_Value=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_BatBrandGroup, FListA.Values['Brand']]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount > 0 then
      begin
        FListA.Values['Brand'] := Fields[0].AsString;
      end;
    end;

    nNoBatGroupStock := sFlag_No;
    nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Value = ''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_NoBatGroupStock, FIn.FData]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount > 0 then
      begin
        nNoBatGroupStock := sFlag_Yes;
      end;
    end;

    nBatStockNo := FIn.FData;

    if (nNoBatGroupStock = sFlag_No) and (nUBatStockGroup = sFlag_Yes) then
    begin
      nStr := 'Select D_ParamB From %s Where D_Name=''%s'' and D_Value=''%s''';
      nStr := Format(nStr, [sTable_SysDict, sFlag_BatStockGroup, nBatStockNo]);
      WriteLog('��ѯ�����������κ����Ϸ���sql:'+nStr);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      begin
        if RecordCount > 0 then
        begin
          nBatStockNo := Fields[0].AsString;
          WriteLog('�������Ϻŷ���ƥ��:'+ FIn.FData + '-->' + nBatStockNo);
        end;
      end;
    end;

    if FListA.Values['LineGroup'] = '' then
          nLineGroup := sFlag_TypeZT
    else  nLineGroup := FListA.Values['LineGroup'];
    nStr := 'Select *,%s as ServerNow From %s Where B_Stock=''%s'' ' +
            'And B_Type=''%s'' And B_LineGroup = ''%s'' And B_Valid=''%s'' And B_BrandGroup=''%s''';
    nStr := Format(nStr, [sField_SQLServer_Now,sTable_Batcode,nBatStockNo,nType,
                          nLineGroup, sFlag_Yes, FListA.Values['Brand']]);
    {$ELSE}
    if nUAutoBrand = sFlag_Yes then
    begin
      nStr := 'Select *,%s as ServerNow From %s Where B_Stock=''%s'' ' +
              'And B_Type=''%s'' And B_BrandGroup=''%s''';
      nStr := Format(nStr, [sField_SQLServer_Now,sTable_Batcode,FIn.FData,
                            nType,FListA.Values['Brand']]);
    end
    else
    begin
      nStr := 'Select *,%s as ServerNow From %s Where B_Stock=''%s'' ' +
              'And B_Type=''%s''';
      nStr := Format(nStr, [sField_SQLServer_Now,sTable_Batcode,FIn.FData,nType]);
    end;
    {$ENDIF}

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := '����[ %s.%s ]δ�������κŹ�������δ����.';
        nData := Format(nData, [FIn.FData, nType]);
        Exit;
      end;

      nRID := FieldByName('R_ID').AsInteger;

      if FieldByName('B_UseDate').AsString = sFlag_Yes then  //ʹ�����ڱ���
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

      if FieldByName('B_AutoNew').AsString = sFlag_Yes then //Ԫ������
      begin
        nStr := Date2Str(FieldByName('ServerNow').AsDateTime);
        nStr := Copy(nStr, 1, 4);
        nP := Date2Str(FieldByName('B_LastDate').AsDateTime);
        nP := Copy(nP, 1, 4);

        if nStr <> nP then
        begin
          {$IFDEF AutoGetLineGroup}
          nStr := 'Update %s Set B_Base=1 Where R_ID=%d';
          nStr := Format(nStr, [sTable_Batcode, nRID]);
          {$ELSE}
          if nUAutoBrand = sFlag_Yes then
          begin
            nStr := 'Update %s Set B_Base=1 Where B_Stock=''%s'' And B_Type=''%s'' And B_BrandGroup=''%s''';
            nStr := Format(nStr, [sTable_Batcode, FIn.FData, nType,FListA.Values['Brand']]);
          end
          else
          begin
            nStr := 'Update %s Set B_Base=1 Where B_Stock=''%s'' And B_Type=''%s''';
            nStr := Format(nStr, [sTable_Batcode, FIn.FData, nType]);
          end;
          {$ENDIF}

          gDBConnManager.WorkerExec(FDBConn, nStr);
          FOut.FData := NewBatCode(nType);
          nNew := True;
        end;
      end;

      if not nNew then //��ų���
      begin
        nStr := Date2Str(FieldByName('ServerNow').AsDateTime);
        nP := Date2Str(FieldByName('B_FirstDate').AsDateTime);

        if (Str2Date(nP) > Str2Date('2000-01-01')) and
           (Str2Date(nStr) - Str2Date(nP) > FieldByName('B_Interval').AsInteger) then
        begin
          {$IFDEF AutoGetLineGroup}
          nStr := 'Update %s Set B_Base=B_Base+%d Where R_ID=%d';
          nStr := Format(nStr, [sTable_Batcode, nInc, nRID]);
          {$ELSE}
          if nUAutoBrand = sFlag_Yes then
          begin
            nStr := 'Update %s Set B_Base=B_Base+%d Where B_Stock=''%s'' And B_Type=''%s'' And B_BrandGroup=''%s''';
            nStr := Format(nStr, [sTable_Batcode, nInc, FIn.FData, nType,FListA.Values['Brand']]);
          end
          else
          begin
            nStr := 'Update %s Set B_Base=B_Base+%d Where B_Stock=''%s''' +
                    'And B_Type=''%s''';
            nStr := Format(nStr, [sTable_Batcode, nInc, FIn.FData, nType]);
          end;
          {$ENDIF}

          gDBConnManager.WorkerExec(FDBConn, nStr);
          FOut.FData := NewBatCode(nType);
          nNew := True;
        end;
      end;

      if not nNew then //��ų���
      begin
        nVal := FieldByName('B_HasUse').AsFloat + StrToFloat(FListA.Values['Value']);
        //��ʹ��+Ԥʹ��
        nPer := FieldByName('B_Value').AsFloat * FieldByName('B_High').AsFloat / 100;
        //��������

        if nVal >= nPer then //����
        begin
          {$IFDEF AutoGetLineGroup}
          nStr := 'Update %s Set B_Base=B_Base+%d Where R_ID=%d';
          nStr := Format(nStr, [sTable_Batcode, nInc, nRID]);
          {$ELSE}
          if nUAutoBrand = sFlag_Yes then
          begin
            nStr := 'Update %s Set B_Base=B_Base+%d Where B_Stock=''%s'' And B_Type=''%s'' And B_BrandGroup=''%s''';
            nStr := Format(nStr, [sTable_Batcode, nInc, FIn.FData, nType,FListA.Values['Brand']]);
          end
          else
          begin
            nStr := 'Update %s Set B_Base=B_Base+%d Where B_Stock=''%s''' +
                    'And B_Type=''%s''';
            nStr := Format(nStr, [sTable_Batcode, nInc, FIn.FData, nType]);
          end;
          {$ENDIF}

          gDBConnManager.WorkerExec(FDBConn, nStr);
          FOut.FData := NewBatCode(nType);
        end else
        begin
          nPer := FieldByName('B_Value').AsFloat * FieldByName('B_Low').AsFloat / 100;
          //����

          if nVal >= nPer then //��������
          begin
            nStr := '����[ %s.%s ]�����������κ�,��֪ͨ������׼��ȡ��.';
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
  //�Զ���ȡ���κ�

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

    {$IFDEF ManuSeal}
    nSeal := Trim(FListA.Values['Seal']);
    WriteLog('�ֶ�����(ʹ���˹�ѡ������):' + nSeal);
    {$ENDIF}

    First;
    nVal := 0;
    nInc := 1;

    nBatchNew := '';
    nSelect := sFlag_No;

    while not Eof do
    try
      {$IFDEF ManuSeal}
      if (nSeal <> '') and
         (FieldByName('D_ID').AsString <> nSeal) then Continue;
      //���˹�ѡ�����β���
      {$ENDIF}
      nStr := Trim(FListA.Values['Brand']);
      if (nUBrand=sFlag_Yes) and (nStr <> '') and
         (FieldByName('D_Brand').AsString <> nStr) then Continue;
      //ʹ��Ʒ��ʱ��Ʒ�Ʋ���

      nType := Trim(FListA.Values['Type']);
      if (nType <> '') and (nType <> sFlag_TypeCommon) and
         (nType <> sFlag_TypeShip) and (nType <> sFlag_TypeStation) then
        nType := sFlag_TypeCommon;
      //Ĭ����ͨ����

      if (nType <> '') and
         (nType <> FieldByName('D_Type').AsString) then Continue;
      //ʹ���������ʱ,��ƥ��

      nVal := FieldByName('D_Plan').AsFloat - FieldByName('D_Sent').AsFloat +
              FieldByName('D_Rund').AsFloat - FieldByName('D_Init').AsFloat -
              StrToFloat(FListA.Values['Value']);

      if FloatRelation(nVal, 0, rtLE) then
      begin
        OutuseCode(FieldByName('D_ID').AsString);
        Continue;
      end; //����

      nInt := FieldByName('D_ValidDays').AsInteger;
      if (nInt > 0) and (Now() - FieldByName('D_UseDate').AsDateTime >= nInt) then
      begin
        OutuseCode(FieldByName('D_ID').AsString);
        Continue;
      end; //��Ź���

      if nInc = 1 then
      begin
        nStr := Trim(FListA.Values['CusID']);
        if (nStr <> '') and
           (nStr <> FieldByName('D_CusID').AsString) then Continue;
        //���ּ����ͻ�ר��
      end;

      nSelect   := sFlag_Yes;
      nBatchNew := FieldByName('D_ID').AsString;
      Break;
    finally
      Next;
      if Eof and (nInc = 1) and (nSelect <> sFlag_Yes) then
      begin
        Inc(nInc);
        First;
      end;
    end;

    if nSelect <> sFlag_Yes then
    begin
      nData := '��������������[ %s.%s ]���β�����.';
      nData := Format(nData, [FIn.FData, FListA.Values['Brand']]);
      Exit;
    end;

    if nVal <= FieldByName('D_Warn').AsFloat then //��������
    begin
      nStr := '����[ %s.%s ]�����������κ�,��֪ͨ������׼��ȡ��.';
      nStr := Format(nStr, [FIn.FData,
                            FListA.Values['Brand']]);
      //xxxxx
      
      FOut.FBase.FErrCode := sFlag_ForceHint;
      FOut.FBase.FErrDesc := nStr;
      OutuseCode(nBatchNew);
    end;

    nStr := 'Update %s Set D_LastDate=null Where D_Valid=''%s'' ' +
            'And D_LastDate is not NULL';
    nStr := Format(nStr, [sTable_BatcodeDoc, sFlag_BatchInUse]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //����״̬�����κţ�ȥ����ֹʱ��

    FOut.FData := nBatchNew;
    Result := True;
  end;
  //����Ʒ�ƺŻ�ȡ���κ�
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
     't1.vdef5,t1.pk_cumandoc,custcode,cmnecode,custname,t_cd.def30,'+          //������Ϣ(t1.vdef5:Ʒ��)
     't1.vdef2,t_def.docname,t1.vdef9 as bm,t1.vdef15 as isphy,' +              //����2(t1.vdef2:��������PK;docname:����������)
     't1.vdef17 as ispd,t1.vdef18 as wxzhuid,t2.vdef15 as wxziid,' +
     't_cb.engname as specialcus,' +                                            //����ͻ�  ����Ϸ�ʹ��
     'invcode,invname,invtype,t1.pk_corp as company,t1.vdef12 as transtype ' +                         //����
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

  nStr := FListA.Values['QueryAll'];
  if nStr = '' then
  begin
    FOut.FData := FOut.FData + ' (crowstatus=0 And VBILLSTATUS=1 ' +
                  'And t1.dr=0 And t2.dr=0) And ';
    //��ǰ��Ч����
  end;

  nStr := FListA.Values['BillCode'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format('VBILLCODE Like ''%%%s%%''', [nStr]);

    nData := Format('GetSQLQueryOrder BillCode -> [ %s ]', [FOut.FData]);
    WriteLog(nData);
    Exit; //������ģ����ѯ
  end;

  nStr := FListA.Values['BillCodes'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format('VBILLCODE In (%s)', [nStr]);

    nData := Format('GetSQLQueryOrder BillCodes -> [ %s ]', [FOut.FData]);
    WriteLog(nData);
    Exit; //������������ѯ
  end;

  nStr := FListA.Values['MeamKeys'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format('pk_meambill_b In (%s)', [nStr]);

    nData := Format('GetSQLQueryOrder MeamKeys -> [ %s ]', [FOut.FData]);
    WriteLog(nData);
    Exit; //�����Ų�ѯ
  end;

  nStr := FListA.Values['NoDate'];
  if nStr = '' then
  begin
    nStr := '(t1.dbilldate>=''%s'' And t1.dbilldate<''%s'')';
    FOut.FData := FOut.FData + Format(nStr, [
                  FListA.Values['DateStart'],
                  FListA.Values['DateEnd']]);
    //��������

    FOut.FData := FOut.FData + ' And ';
    //ƴ����������
  end;

  FOut.FData := FOut.FData + ' (' + nType + ')';
  //��������

  nStr := FListA.Values['CustomerID'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format(' And custcode=''%s''', [nStr]);
    //���ͻ����
  end;

  nStr := FListA.Values['StockNo'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format(' And invcode=''%s''', [nStr]);
    //�����ϱ��
  end;

  nStr := FListA.Values['SDTID'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format(' And t1.vdef8=''%s''', [nStr]);
    //�����֤��
  end;

  nStr := FListA.Values['Password'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format(' And t1.vdef19=''%s''', [nStr]);
    //��ȡ������
  end;

  nStr := FListA.Values['AICMID'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format(' And t1.vdef9=''%s''', [nStr]);
    //�������쿨����
  end;

  nStr := FListA.Values['Truck'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format(' And t2.cvehicle=''%s''', [nStr]);
    //������
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

  nData := Format('GetSQLQueryOrder End -> [ %s ]', [FOut.FData]);
  WriteLog(nData);
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

    nData := Format('GetSQLQueryDispatch BillCode -> [ %s ]', [FOut.FData]);
    WriteLog(nData);
    Exit; //�����Ų�ѯ
  end;

  nStr := FListA.Values['MeamKeys'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format(' And pk_meambill_b In (%s)', [nStr]);

    nData := Format('GetSQLQueryDispatch MeamKeys -> [ %s ]', [FOut.FData]);
    WriteLog(nData);
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
    FOut.FData := FOut.FData + ' And (crowstatus=0 And VBILLSTATUS=1 ' +
                  'And t1.dr=0 And t2.dr=0)';
    //��ǰ��Ч����
  end;

  nStr := FListA.Values['Customer'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format(' And unitname = ''%s''', [nStr]);
    //���ͻ����
  end;
  
  nStr := FListA.Values['StockNo'];
  if nStr <> '' then
  begin
    FOut.FData := FOut.FData + Format(' And invcode=''%s''', [nStr]);
    //�����ϱ��
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

  nData := Format('GetSQLQueryDispatch End -> [ %s ]', [FOut.FData]);
  WriteLog(nData);
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

  nData := Format('GetSQLQueryCustomer -> [ %s ]', [FOut.FData]);
  WriteLog(nData);
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

    nData := Format('GetOrderFHValue -> [ %s ] => [ %s ]', [
             '������', nStr]);
    WriteLog(nData);

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

    nData := Format('GetOrderFHValue -> [ %s ] => [ %s ]', [
             '�˻���', nStr]);
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

  nSQL := 'Select L_ID,L_ZhiKa,L_SaleMan,L_Truck,L_Value,L_PValue,L_PDate,L_IsVIP,' +
          {$IFDEF LineGroup}
          'dict.D_ParamC As ncLineID, '      +    //NC�����߱��
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
        FMemo       := FieldByName('L_Seal').AsString;

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

          if FieldByName('L_IsVip').AsString <> sFlag_TypeShip then
          begin
            if FDate < nDateMin then
              FDate := FieldByName('L_Date').AsDateTime;
            //xxxxx
          end;

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
        if FloatRelation(nBills[nIdx].FValue, 0, rtLE) then Continue;
        //������Ϊ0,���ش�����

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
      FMemo    := FieldByName('P_Memo').AsString;

      if FZhiKa = '' then
      begin
        nData := '���ص���[ %s ]�Ŷ�����Ϊ��.';
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
              SF('vdef11', nBills[nIdx].FMemo),                                 //��ע;�ѳ�
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
              SF('vdef11', nBills[nIdx].FMemo),                                 //��ע;�ѳ�
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
          nData := 'ͬ��NC�����񵥴���,����: ' + E.Message;
          Exit;
        end;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;

//Date: 2017/6/25
//Parm: �ؿյ��ݺ�
//Desc: ͬ���ؿյ��������ݵ�NC�����񵥱���
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
      nData := '�ؿյ�[ %s ]��Ϣ�Ѷ�ʧ.';
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
        FPoundID    := FieldByName('P_ID').AsString;                  //�ؿհ���
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
        //ԭʼ������
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
        nData := 'ԭʼ����[ %s ]��Ϣ�Ѷ�ʧ.';
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
        //������ʧ���账��

        nNet := FieldByName('nnet').AsFloat;
        nRetnet := FieldByName('ngross').AsFloat - nBills[nIdx].FMData.FValue;
        nRetnet := Float2Float(nRetnet, cPrecision, False);

        nSQL := MakeSQLByStr([
                SF('dbizdate', Date2Str(nBills[nIdx].FMData.FDate)),            //�ؿ�����
                SF('dreturntaretime', DateTime2Str(nBills[nIdx].FMData.FDate)), //�ؿ�ʱ��
                SF('nreturntare', nBills[nIdx].FMData.FValue, sfVal),
                SF('nreturnnet', nRetnet, sfVal)
                ], 'meam_poundbill', SF('vbillcode', nBills[nIdx].FPoundID), False);
        FListA.Add(nSQL);
        //���»ؿ���Ϣ

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
          nData := 'ͬ��NC�����񵥴���,����: ' + E.Message;
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

//------------------------------------------------------------------------------
//Date: 2015/9/9
//Parm: �û��������룻�����û�����
//Desc: �û���¼
function TWorkerBusinessCommander.Login(var nData: string): Boolean;
var nStr: string;
begin
  Result := False;

  FListA.Clear;
  FListA.Text := PackerDecodeStr(FIn.FData);
  if FListA.Values['User']='' then Exit;
  //δ�����û���

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
//Parm: �û�������֤����
//Desc: �û�ע��
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
//Parm: ������[FIn.FData]
//Desc: ��ȡ�𳵺��������(ʹ�����ģʽ,δ����)
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
//Parm: ��������[FIn.FData]
//Desc: ����𳵺��������
function TWorkerBusinessCommander.SaveStationPoundData(var nData: string): Boolean;
var nAdd: Double;
    nStr,nSQL: string;
    nPound: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  AnalyseBillItems(FIn.FData, nPound);
  //��������

  with nPound[0] do
  begin
    TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, FTruck, '', @nOut);
    //���泵�ƺ�

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
              SF('P_Direction', '����'),
              SF('P_PModel', FPModel),
              SF('P_Status', sFlag_TruckBFP),
              SF('P_Valid', sFlag_Yes),
              SF('P_Order', FZhiKa),              //�ֿ���
              SF('P_Origin', FOrigin),            //�ֿ�����
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
      //�ظ�2�ι���

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
        //�������κ�

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

                  SF('P_Bill', FID),                  //���κ�
                  SF('P_Order', FZhiKa),              //�ֿ���
                  SF('P_Origin', FOrigin)             //�ֿ�����
                  ], sTable_PoundStation, SF('P_ID', FPoundID), False);
          //����ʱ,����Ƥ�ش�,����Ƥë������
        end else
        begin
          nSQL := MakeSQLByStr([
                  SF('P_MValue', FMData.FValue, sfVal),
                  SF('P_MDate', sField_SQLServer_Now, sfVal),
                  SF('P_MMan', FIn.FBase.FFrom.FUser),
                  SF('P_MStation', FMData.FStation),

                  SF('P_Bill', FID),                  //���κ�
                  SF('P_Order', FZhiKa),              //�ֿ���
                  SF('P_Origin', FOrigin)             //�ֿ�����
                  ], sTable_PoundStation, SF('P_ID', FPoundID), False);
          //xxxxx
        end;
        gDBConnManager.WorkerExec(FDBConn, nSQL);

        nSQL := 'Update %s Set B_HasUse=B_HasUse+(%s),B_LastDate=%s ' +
                'Where B_Stock=''%s'' and B_Type=''%s'' ';
        nSQL := Format(nSQL, [sTable_Batcode, FloatToStr(nAdd),
                sField_SQLServer_Now, FStockNo, sFlag_TypeStation]);
        gDBConnManager.WorkerExec(FDBConn, nSQL); //�������κ�ʹ����
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
//Parm: ������¼[FIn.FData];
//Desc: ��ȡ�����Ӧ�ı�׼��Ϣ
function TWorkerBusinessCommander.GetStationTruckValue(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nTrucks: TStationTrucks;
    nPound: TLadingBillItems;
begin
  Result := False;
  nData := 'δ���ó��������Ϣ,�������ñ�����Ϣ';

  AnalyseBillItems(FIn.FData, nPound);
  //��������

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
  //ǰ׺+����+�ͻ�����

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
  //ǰ׺+����+�ͻ�����

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
  //ǰ׺+��������

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
  //ǰ׺+�ͻ�����

  for nIdx := Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx], nPound[0] do
  begin
    nStr := Copy(FTruck, 1, Length(FPrefix));

    if CompareStr(UpperCase(nStr), UpperCase(FPrefix)) <> 0 then Continue;

    FOut.FData := FloatToStr(nTrucks[nIdx].FValue);
    Result := True;
    Exit;
  end;
  //ǰ׺����
end;

//Date: 2017/6/7
//Parm: NULL
//Desc: ��ȡ�̳��˺���Ϣ
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

//������Ϣ
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
//Desc: ����(�������)�̳��˺���Ϣ
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
            '  <Customer>$WebCusID</Customer>'         +                        //�̳��˺�
            '  <Provider>$WebProID</Provider>'         +                        //�̳��˺�
            '</head>'                                  +
            '<Items>'                                  +
            '  <Item>'                                 +
            '    <cash>0</cash>'                       +
            '    <clientname>$DLCusName</clientname>'  +                        //DLϵͳ�ͻ�����
            '    <clientnumber>$DLCusID</clientnumber>'+                        //DLϵͳ�ͻ����
            '    <providername>$DLPName</providername>'+                        //DL��Ӧ����
            '    <providernumber>$DLPID</providernumber>' +                     //DL��Ӧ�̱��
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
  //ȥ���ո�

  Result := CallRemoteWorker(sCLI_BusinessWebchat, PackerEncodeStr(nXmlStr), '', @nOut,
            cBC_WebChat_EditShopCustom);
  if Result then
  begin


    if FIn.FExtParam = sFlag_Yes then      //���ۿͻ�
    begin
      nSQL := 'Update %s Set C_WeiXin=''%s'' Where C_ID=''%s''';
      nSQL := Format(nSQL, [sTable_Customer, FListA.Values['WebUserName'],
              FListA.Values['DLCusID']]);
    end else

    begin
      nSQL := 'Update %s Set P_WeiXin=''%s'' Where P_ID=''%s''';
      nSQL := Format(nSQL, [sTable_Provider, FListA.Values['WebUserName'],
              FListA.Values['DLPID']]); //��Ӧ��
    end;

    gDBConnManager.WorkerExec(FDBConn, nSQL);
  end else nData := nOut.FData;
end;

//Date: 2017/6/12
//Parm: �ͻ�ID
//Desc: ��ȡ���ö����б�
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
    nData := 'GetOrderList��ȡNC���۶������ʧ��';
    Exit;
  end;

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nOut.FData, nWorker, sFlag_DB_NC) do
    begin
      if RecordCount < 1 then
      begin
        nData := Format('δ��ѯ���ͻ����[ %s ]��Ӧ�Ķ�����Ϣ1.', [FIn.FData]);
        Exit;
      end;

      First;
      FListA.Clear;
      FListC.Clear;
      //ʣ������Ϣ

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
          Values['SpecialCus']:= FieldByName('specialcus').AsString;
          Values['BM']  := FieldByName('bm').AsString;
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
      nData := '��ȡ����[ %s ]�ѷ���ʧ��.';
      nData := Format(nData, [FListC.Text]);
      Exit;
    end;

    FListC.Clear;
    FListC.Text := PackerDecodeStr(nOut.FData);
    //�����ѷ�����

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
    nData := 'GetOrderList��ȡNC�ɹ��������ʧ��';
    Exit;
  end;

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nOut.FData, nWorker, sFlag_DB_NC) do
    begin
      if RecordCount < 1 then
      begin
        nData := Format('δ��ѯ���ͻ����[ %s ]��Ӧ�Ĳɹ�������Ϣ.', [FIn.FData]);
        Exit;
      end;

      First;
      FListA.Clear;
      FListC.Clear;
      //ʣ������Ϣ

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
      nData := '��ȡ����[ %s ]������ʧ��.';
      nData := Format(nData, [FListC.Text]);
      Exit;
    end;

    FListC.Clear;
    FListC.Text := PackerDecodeStr(nOut.FData);
    //�����ѷ�����

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

function TWorkerBusinessCommander.GetPurchaseListNC(var nData:string):Boolean;
var nSQL: string;
    nVal: Double;
    nIdx: Integer;
    nWorker: PDBWorker;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;

  FListA.Clear;
  FListA.Values['NoDate'] := sFlag_Yes;
  FListA.Values['AICMID'] := FIn.FData;
  FListA.Values['order']  := 'invcode';
  if not CallMe(cBC_GetSQLQueryOrder, '201', PackerEncodeStr(FListA.Text), @nOut) then
  begin
    nData := 'GetOrderList��ȡNC�ɹ��������ʧ��';
    Exit;
  end;

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nOut.FData, nWorker, sFlag_DB_NC) do
    begin
      if RecordCount < 1 then
      begin
        nData := Format('δ��ѯ���ͻ����[ %s ]��Ӧ�Ĳɹ�������Ϣ.', [FIn.FData]);
        Exit;
      end;

      First;
      FListA.Clear;
      FListC.Clear;
      //ʣ������Ϣ

      while not Eof do
      try
        with FListB do
        begin
          Values['ProvID']   := FieldByName('custcode').AsString;
          Values['ProvName'] := FieldByName('custname').AsString;
          Values['PK']       := FieldByName('pk_meambill').AsString;

          Values['ZhiKa']    := FieldByName('VBILLCODE').AsString;
          Values['ZKDate']   := FieldByName('TMakeTime').AsString;

          Values['StockNo']  := FieldByName('invcode').AsString;
          Values['StockName']:= FieldByName('invname').AsString;
          Values['Maxnumber']:= FieldBYName('NPLANNUM').AsString;

          Values['SaleArea'] := FieldByName('vdef10').AsString;
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
      nData := '��ȡ����[ %s ]������ʧ��.';
      nData := Format(nData, [FListC.Text]);
      Exit;
    end;

    FListC.Clear;
    FListC.Text := PackerDecodeStr(nOut.FData);
    //�����ѷ�����

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

//Date: 2018/7/11
//Parm: ���֤ID,ȡ������
//Desc: ��ȡ���ö����б�
function TWorkerBusinessCommander.GetOrderListNC(var nData:string):Boolean;
var nSQL, nStr: string;
    nVal: Double;
    nIdx: Integer;
    nWorker: PDBWorker;
    nOut: TWorkerBusinessCommand;
    nDate: TDateTime;
begin
  Result := False;
  if (Trim(FIn.FData) = '') and (Trim(FIn.FExtParam) = '') then Exit;

  FListA.Clear;
  FListA.Values['NoDate'] := sFlag_Yes;
  FListA.Values['SDTID'] := FIn.FData;
  FListA.Values['Password'] := FIn.FExtParam;

  try
    nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_OrderInFact, sFlag_OrderFilterH]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount > 0 then
      begin
        nDate := StrToDateTime(FormatDateTime('YYYY-MM-DD', Now) + ' ' + Fields[0].AsString);

        if Now < nDate then
        begin
          FListA.Values['NoDate'] := '';
          FListA.Values['DateStart'] := FormatDateTime('YYYY-MM-DD',IncDay(Now, -10));
          FListA.Values['DateEnd'] := FormatDateTime('YYYY-MM-DD',IncDay(Now, 1));
        end;
      end;
    end;
  except
  end;

  if not CallMe(cBC_GetSQLQueryOrder, '101', PackerEncodeStr(FListA.Text), @nOut) then
  begin
    nData := 'GetOrderList��ȡNC���۶������ʧ��';
    Exit;
  end;

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nOut.FData, nWorker, sFlag_DB_NC) do
    begin
      if RecordCount < 1 then
      begin
        nData := Format('δ��ѯ���ͻ����[ %s ]��Ӧ�Ķ�����Ϣ1.', [FIn.FData]);
        Exit;
      end;

      First;
      FListA.Clear;
      FListC.Clear;
      //ʣ������Ϣ

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
          Values['Truck']  := FieldByName('cvehicle').AsString;
          Values['SaleArea']  := FieldByName('areaclname').AsString;
          Values['Brand']  := FieldByName('vdef5').AsString;
          Values['BM']  := FieldByName('bm').AsString;

          Values['ispd']  := FieldByName('ispd').AsString;
          Values['wxzhuid']  := FieldByName('wxzhuid').AsString;
          Values['wxziid']  := FieldByName('wxziid').AsString;
          Values['isphy']  := FieldByName('isphy').AsString;
          Values['transtype']  := FieldByName('transtype').AsString;
          Values['SpecialCus']:= FieldByName('specialcus').AsString;
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
      nData := '��ȡ����[ %s ]�ѷ���ʧ��.';
      nData := Format(nData, [FListC.Text]);
      Exit;
    end;

    FListC.Clear;
    FListC.Text := PackerDecodeStr(nOut.FData);
    //�����ѷ�����

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
    nData := 'δ��ȡ����Ӧ�Ķ�����Ϣ.';
    Exit;
  end;

  nWorker := nil;
  try
    nWorker := gDBConnManager.GetConnection(sFlag_DB_NC, nIdx);

    if not Assigned(nWorker) then
    begin
      nData := Format('����[ %s ]���ݿ�ʧ��(ErrCode: %d).', [sFlag_DB_NC, nIdx]);
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
    //�鿴���۶���

    if FListC.Count > 0 then
    begin
      FListB.Clear;
      FListB.Values['BillCodes'] := AdjustListStrFormat2(FListC, '''', True, ',', False, False);
      if (not CallMe(cBC_GetSQLQueryOrder, '103', PackerEncodeStr(FListB.Text),
          @nOut)) or (nOut.FData = '') then
      begin
        nData := 'δ��ȡ��[ %s ]��Ӧ�����ݿ��ѯ���.';
        nData := Format(nData, [FListC.Text]);
        Exit;
      end;

      nSQL := nOut.FData;
      with gDBConnManager.WorkerQuery(nWorker, nSQL) do
      begin
        if RecordCount < 1 then
        begin
          nData := '������[ %s ]����Ч,����ϵ����Ա���¿���.';
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
    //�鿴�ɹ�����

    if FListC.Count > 0 then
    begin
      FListB.Clear;
      FListB.Values['BillCodes'] := AdjustListStrFormat2(FListC, '''', True, ',', False, False);
      if (not CallMe(cBC_GetSQLQueryOrder, '203', PackerEncodeStr(FListB.Text),
          @nOut)) or (nOut.FData = '') then
      begin
        nData := 'δ��ȡ��[ %s ]��Ӧ�����ݿ��ѯ���.';
        nData := Format(nData, [FListC.Text]);
        Exit;
      end;

      nSQL := nOut.FData;
      with gDBConnManager.WorkerQuery(nWorker, nSQL) do
      begin
        if RecordCount < 1 then
        begin
          nData := '������[ %s ]����Ч,����ϵ����Ա���¿���.';
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
  //������Ϣ
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
  //ˢ������

  with gTruckQueueManager do
  try
    SyncLock.Enter;
    Result := True;

    FListB.Clear;
    FListC.Clear;

    i := 0;
    SetLength(nQueues, 0);
    //�����ѯ��¼

    for nIdx:=0 to Lines.Count - 1 do
    begin
      nLine := Lines[nIdx];
      if not nLine.FIsValid then Continue;
      //ͨ����Ч

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

//Date: 2017-12-2
//Parm: ���ƺ�(Truck); ��������(Bill);��λ(Pos)
//Desc: ץ�ıȶ�
function TWorkerBusinessCommander.VerifySnapTruck(var nData: string): Boolean;
var nStr: string;
    nTruck, nBill, nPos, nSnapTruck, nEvent, nDept, nPicName: string;
    nUpdate, nNeedManu: Boolean;
begin
  Result := False;
  FListA.Text := FIn.FData;
  nSnapTruck:= '';
  nEvent:= '' ;
  nNeedManu := False;

  nTruck := FListA.Values['Truck'];
  nBill  := FListA.Values['Bill'];
  nPos   := FListA.Values['Pos'];
  nDept  := FListA.Values['Dept'];

  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_TruckInNeedManu,nPos]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
    begin
      nNeedManu := FieldByName('D_Value').AsString = sFlag_Yes;
    end;
  end;

  if not nNeedManu then
  begin
    WriteLog('����ʶ��:'+'��λ:'+nPos+'�¼����ղ���:'+nDept+'�˹���Ԥ:��');
    Result := True;
    Exit;
  end
  else
    WriteLog('����ʶ��:'+'��λ:'+nPos+'�¼����ղ���:'+nDept+'�˹���Ԥ:��');
  {$IFDEF SaveAllSnap}
  nStr := 'Select * From %s Where S_ID=''%s''';
  nStr := Format(nStr, [sTable_SnapTruck, nPos]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
      nSnapTruck := FieldByName('S_Truck').AsString;
  end;

  nStr := 'Select * From %s Where E_ID=''%s''';
  nStr := Format(nStr, [sTable_ManualEvent, nBill+sFlag_ManualE]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
      nUpdate := True
    else
      nUpdate := False;
  end;

  nEvent := '����[ %s ]����ʶ��ɹ�,ץ�ĳ��ƺ�:[ %s ]';
  nEvent := Format(nEvent, [nTruck,nSnapTruck]);

  nStr := SF('E_ID', nBill+sFlag_ManualE);
  nStr := MakeSQLByStr([
          SF('E_ID', nBill+sFlag_ManualE),
          SF('E_Key', nTruck),
          SF('E_From', nDept),
          SF('E_Result', 'I'),
          SF('E_ManDeal', 'Auto'),
          SF('E_DateDeal', sField_SQLServer_Now, sfVal),
          SF('E_Event', nEvent),
          SF('E_Solution', sFlag_Solution_YN),
          SF('E_Departmen', nDept),
          SF('E_Date', sField_SQLServer_Now, sfVal)
          ], sTable_ManualEvent, nStr, (not nUpdate));
  //xxxxx
  gDBConnManager.WorkerExec(FDBConn, nStr);
  {$ENDIF}

  nData := '����[ %s ]����ʶ��ʧ��';
  nData := Format(nData, [nTruck]);
  FOut.FData := nData;
  //default

  nStr := 'Select * From %s Where S_ID=''%s'' order by R_ID desc ';
  nStr := Format(nStr, [sTable_SnapTruck, nPos]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      if not nNeedManu then
        Result := True;
      nData := '����[ %s ]ץ���쳣';
      nData := Format(nData, [nTruck]);
      FOut.FData := nData;
      Exit;
    end;

    nPicName := '';

    First;

    while not Eof do
    begin
      nSnapTruck := FieldByName('S_Truck').AsString;
      if nPicName = '' then//Ĭ��ȡ����һ��ץ��
        nPicName := FieldByName('S_PicName').AsString;
      if Pos(nTruck,nSnapTruck) > 0 then
      begin
        Result := True;
        nPicName := FieldByName('S_PicName').AsString;
        //ȡ��ƥ��ɹ���ͼƬ·��
        nData := '����[ %s ]����ʶ��ɹ�,ץ�ĳ��ƺ�:[ %s ]';
        nData := Format(nData, [nTruck,nSnapTruck]);
        FOut.FData := nData;
        Exit;
      end;
      //����ʶ��ɹ�
      Next;
    end;
  end;

  nStr := 'Select * From %s Where E_ID=''%s''';
  nStr := Format(nStr, [sTable_ManualEvent, nBill+sFlag_ManualE]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
    begin
      if FieldByName('E_Result').AsString = 'N' then
      begin
        nData := '����[ %s ]����ʶ��ʧ��,ץ�ĳ��ƺ�:[ %s ],����Ա��ֹ����';
        nData := Format(nData, [nTruck,nSnapTruck]);
        FOut.FData := nData;
        Exit;
      end;
      if FieldByName('E_Result').AsString = 'Y' then
      begin
        Result := True;
        nData := '����[ %s ]����ʶ��ʧ��,ץ�ĳ��ƺ�:[ %s ],����Ա����';
        nData := Format(nData, [nTruck,nSnapTruck]);
        FOut.FData := nData;
        Exit;
      end;
      nUpdate := True;
    end
    else
    begin
      nData := '����[ %s ]����ʶ��ʧ��,ץ�ĳ��ƺ�:[ %s ]';
      nData := Format(nData, [nTruck,nSnapTruck]);
      FOut.FData := nData;
      nUpdate := False;
      if not nNeedManu then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;

  nEvent := '����[ %s ]����ʶ��ʧ��,ץ�ĳ��ƺ�:[ %s ]';
  nEvent := Format(nEvent, [nTruck,nSnapTruck]);

  nStr := SF('E_ID', nBill+sFlag_ManualE);
  nStr := MakeSQLByStr([
          SF('E_ID', nBill+sFlag_ManualE),
          SF('E_Key', nPicName),
          SF('E_From', nPos),
          SF('E_Result', 'Null', sfVal),

          SF('E_Event', nEvent),
          SF('E_Solution', sFlag_Solution_YN),
          SF('E_Departmen', nDept),
          SF('E_Date', sField_SQLServer_Now, sfVal)
          ], sTable_ManualEvent, nStr, (not nUpdate));
  //xxxxx
  gDBConnManager.WorkerExec(FDBConn, nStr);
end;

//Date: 2018-07-31
//Desc: ��ȡװ���߷���
function TWorkerBusinessCommander.AutoGetLineGroup(var nData: string): Boolean;
var nStr, nStrAdj: string;
    nIdx, nI: Integer;
    nSLine,nSTruck, nType, nBatBrand, nBatStockNo, nStockMatch: string;
    nOut: TWorkerBusinessCommand;
    nLines: TZTLineItems;
    nTrucks: TZTTruckItems;
    nHideStock: Boolean;
begin
  Result := False;
  FListC.Clear;
  FListA.Clear;
  FListA.Text:= PackerDecodeStr(FIn.FExtParam);
  WriteLog('��ʼ�Զ�ƥ�����...');

  nBatBrand := FListA.Values['Brand'];
  nStr := 'Select D_ParamB From %s Where D_Name=''%s'' and D_Value=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_BatBrandGroup, nBatBrand]);
  WriteLog('��ѯ�����������κ�Ʒ�Ʒ���sql:'+nStr);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
    begin
      nBatBrand := Fields[0].AsString;
    end;
  end;

  nHideStock := False;
  nBatStockNo := FIn.FData;
  nStr := 'Select D_ParamB From %s Where D_Name=''%s'' and D_Value=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_BatStockGroup, nBatStockNo]);
  WriteLog('��ѯ�����������κ����Ϸ���sql:'+nStr);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
    begin
      nBatStockNo := Fields[0].AsString;
      if FIn.FData <> nBatStockNo then
        nHideStock := True;//����Ʒ�ַ���  ��Ҫ��һ������װ����
      WriteLog('�������Ϻŷ���ƥ��:'+ FIn.FData + '-->' + nBatStockNo);
    end;
  end;

  if FListA.Values['Type'] ='' then
        nType := sFlag_TypeCommon
  else  nType := FIn.FExtParam;

  if (nType <> '') and (nType <> sFlag_TypeCommon) and
     (nType <> sFlag_TypeShip) and (nType <> sFlag_TypeStation) then
    nType := sFlag_TypeCommon;
  //default

  nStr := 'Select B_LineGroup From %s Where B_Stock=''%s'' and B_Type=''%s'' '+
          'and B_Valid=''%s'' and B_BrandGroup=''%s'' order by R_ID ';
  nStr := Format(nStr, [sTable_Batcode, nBatStockNo, nType, sFlag_Yes, nBatBrand]);
  WriteLog('��ѯ�����������κ������߷���sql:'+nStr);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '����[ %s.%s ]û�з��������������߷���.';
      nData := Format(nData, [nBatStockNo, nType]);

      WriteLog('����'+ nBatStockNo +'û�з��������������߷���.');
      Exit;
    end;
    FListC.Clear;
    First;

    while not Eof do
    begin
      FListC.Add(Fields[0].AsString);
      Next;
    end;
  end;

  {$IFDEF ForceLineGroup}
  if FListA.Values['LineGroup'] <> '' then
  begin
    FListC.Clear;
    FListC.Add(FListA.Values['LineGroup']);
    WriteLog('ǿ��������ģʽ:ǿ��������Ϊ' + FListA.Values['LineGroup']);
  end;
  {$ENDIF}

  {$IFDEF ManuLineGroup}
  if FListA.Values['LineGroup'] <> '' then
  begin
    FListC.Clear;
    FListC.Add(FListA.Values['LineGroup']);
    WriteLog('�˹�ָ��������ģʽ:ָ��������Ϊ' + FListA.Values['LineGroup']);
  end;
  {$ENDIF}

  nStrAdj := AdjustListStrFormat2(FListC, '''', True, ',', False);

  if nHideStock then
  begin
    nStr := 'Select M_LineNo From %s Where M_ID=''%s'' '+
            'and M_Status=''%s'' order by R_ID ';
    nStr := Format(nStr, [sTable_StockMatch, FIn.FData, sFlag_Yes]);
    WriteLog('��ѯ��������Ʒ�ַ���װ����sql:'+nStr);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := '����[ %s.%s ]û�з���������Ʒ�ַ���.';
        nData := Format(nData, [FIn.FData]);

        WriteLog('����'+ FIn.FData +'û�з���������Ʒ�ַ���.');
        Exit;
      end;
      FListC.Clear;

      First;

      while not Eof do
      begin
        FListC.Add(Fields[0].AsString);
        Next;
      end;
    end;
    nStockMatch := AdjustListStrFormat2(FListC, '''', True, ',', False);
  end;

  SetLength(FLineItems, 0);
  if nHideStock then
  begin
    nStr := 'Select Z_ID, Z_Group, Z_QueueMax From %s Where Z_StockNo=''%s'' '+
            'and Z_Valid=''%s'' and Z_Group In (%s) and Z_ID In (%s) order by R_ID ';
    nStr := Format(nStr, [sTable_ZTLines, nBatStockNo, sFlag_Yes, nStrAdj, nStockMatch]);
  end
  else
  begin
    nStr := 'Select Z_ID, Z_Group, Z_QueueMax From %s Where Z_StockNo=''%s'' '+
            'and Z_Valid=''%s'' and Z_Group In (%s) order by R_ID ';
    nStr := Format(nStr, [sTable_ZTLines, nBatStockNo, sFlag_Yes, nStrAdj]);
  end;
  WriteLog('��ѯ��������ͨ��sql:'+nStr);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '����[ %s ]û�з���������ͨ��.';
      nData := Format(nData, [nBatStockNo]);
      WriteLog('����'+ nBatStockNo +'û�з���������ͨ��.');
      Exit;
    end;

    SetLength(FLineItems,RecordCount);

    nIdx := 0;
    First;

    while not Eof do
    begin
      with FLineItems[nIdx] do
      begin
        FID := Fields[0].AsString;
        FGroupID := Fields[1].AsString;
        FTruckCount := 0;
        FMaxCount := Fields[2].AsInteger;
        FValid := False;
      end;

      Inc(nIdx);
      Next;
    end;
  end;
  {$IFDEF HardMon}
  if not THardwareCommander.CallMe(cBC_GetQueueData, sFlag_No, '', @nOut) then
  begin
    begin
      WriteLog('��ȡ������Ϣʧ��');
      nData := '��ȡ������Ϣʧ��.';
      Exit;
    end;
  end;

  FListA.Clear;
  FListB.Clear;

  FListA.Text := PackerDecodeStr(nOut.FData);
  nSLine := FListA.Values['Lines'];
  nSTruck := FListA.Values['Trucks'];

  FListA.Text := PackerDecodeStr(nSLine);
  SetLength(nLines, FListA.Count);

  for nIdx:=0 to FListA.Count - 1 do
  with nLines[nIdx],FListB do
  begin
    FListB.Text := PackerDecodeStr(FListA[nIdx]);
    FID       := Values['ID'];
    FName     := Values['Name'];
    FStock    := Values['Stock'];
    FValid    := Values['Valid'] <> sFlag_No;
    FPrinterOK:= Values['Printer'] <> sFlag_No;

    if IsNumber(Values['Weight'], False) then
         FWeight := StrToInt(Values['Weight'])
    else FWeight := 1;
  end;

  FListA.Text := PackerDecodeStr(nSTruck);
  SetLength(nTrucks, FListA.Count);

  for nIdx:=0 to FListA.Count - 1 do
  with nTrucks[nIdx],FListB do
  begin
    FListB.Text := PackerDecodeStr(FListA[nIdx]);
    FTruck    := Values['Truck'];
    FLine     := Values['Line'];
    FBill     := Values['Bill'];

    if IsNumber(Values['Value'], True) then
         FValue := StrToFloat(Values['Value'])
    else FValue := 0;

    FInFact   := Values['InFact'] = sFlag_Yes;
    FIsRun    := Values['IsRun'] = sFlag_Yes;

    if IsNumber(Values['Dai'], False) then
         FDai := StrToInt(Values['Dai'])
    else FDai := 0;

    if IsNumber(Values['Total'], False) then
         FTotal := StrToInt(Values['Total'])
    else FTotal := 0;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  begin
    for nI:=Low(FLineItems) to High(FLineItems) do
      if nTrucks[nIdx].FLine = FLineItems[nI].FID then
      begin
        Inc(FLineItems[nI].FTruckCount);
      end;
  end;

  nI :=0;
  for nIdx := Low(FLineItems) to High(FLineItems) do
  begin
    WriteLog('ͨ��'+FLineItems[nIdx].FID +
             '��������Ϊ:'+IntToStr(FLineItems[nIdx].FTruckCount) +
             'ͨ�������Ϊ:'+IntToStr(FLineItems[nIdx].FMaxCount) +
             '��������:'+FLineItems[nIdx].FGroupID);
//    if FLineItems[nIdx].FTruckCount < FLineItems[nIdx].FMaxCount then
//    begin
//      Inc(nI);
//      FLineItems[nIdx].FValid := True;
//    end;
  end;

//  if nI = 0 then
//  begin
//    nData := '����[ %s ]����������ͨ������.';
//    nData := Format(nData, [nBatStockNo]);
//    WriteLog('����'+ nBatStockNo +'����������ͨ������.');
//    Exit;
//  end;

  nI := 0;
  FOut.FData := '';
  for nIdx := Low(FLineItems) to High(FLineItems) do
  begin
//    if FLineItems[nIdx].FValid = False then
//      Continue;
    try
      if FOut.FData = '' then
      begin
       nI:= FLineItems[nIdx].FTruckCount;
       FOut.FData := FLineItems[nIdx].FGroupID;
       FOut.FExtParam := FLineItems[nIdx].FID;
      end
      else
      begin
        if FLineItems[nIdx].FTruckCount < nI then
        begin
          FOut.FData := FLineItems[nIdx].FGroupID;
          FOut.FExtParam := FLineItems[nIdx].FID;
        end;
      end;
    except
    end;
  end;
  WriteLog('ָ��װ����:' + FOut.FExtParam + '����:' + FOut.FData);
  Result := True;
  //��ѯ������С������
  {$ELSE}
  FOut.FData := '';
  FOut.FExtParam := '';
  Result := True;
  {$ENDIF}
  WriteLog('�����Զ�ƥ�����...');
end;

function TWorkerBusinessCommander.GetTruckList(var nData: string): Boolean;
var nStr: string;
begin
  Result := False;

  nStr := 'Select T_Truck From %s Where (T_Valid = ''%s'' or T_Valid is null)';
  nStr := Format(nStr, [sTable_Truck, sFlag_Yes]);

  if FIn.FData <> '' then
  begin
    nStr := nStr + ' And T_Truck like ''%%%s%%''';
    nStr := Format(nStr, [FIn.FData]);
  end;

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <= 0 then
      Exit;

    FListC.Clear;

    First;

    while not Eof do
    begin
      FListC.Add(Fields[0].AsString);
      Next;
    end;
  end;

  FOut.FData := FListC.Text;
  Result := True;
end;

function TWorkerBusinessCommander.TruckManulSign(var nData: string): Boolean;
var nStr: string;
begin
  Result := False;

  if FIn.FData = '' then
    Exit;

  nStr := 'Update %s Set T_LastTime=getDate() Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, FIn.FData]);

  gDBConnManager.WorkerExec(FDBConn, nStr);

  Result := True;
end;

//Date: 2019-01-09
//Parm: ������š�ͨ�����
//Desc: �ֳ���ȡָ�����Ϻŵı��
function TWorkerBusinessCommander.GetStockBatcodeByLine(var nData: string): Boolean;
var nStr,nP,nUBrand,nUBatchAuto, nUBatcode, nType, nLineGroup, nBatStockNo: string;
    nBatchNew, nSelect, nUBatStockGroup, nKw: string;
    nVal, nPer: Double;
    nInt, nInc, nRID: Integer;
    nNew: Boolean;

    //���������κ�
    function NewBatCode(const nBtype:string = 'C'): string;
    var nSQL, nTmp: string;
    begin
      nSQL := 'Select *,%s as ServerNow From %s Where B_Stock=''%s'' ' +
              'And B_Type=''%s'' And B_Kw=''%s''';
      nSQL := Format(nSQL, [sField_SQLServer_Now,sTable_Batcode,nBatStockNo,
                            nBtype, nKw]);

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

      nTmp := Format('R_ID=%d', [nRID]);

      nSQL := MakeSQLByStr([SF('B_Batcode', Result),
                SF('B_FirstDate', sField_SQLServer_Now, sfVal),
                SF('B_HasUse', 0, sfVal),
                SF('B_LastDate', sField_SQLServer_Now, sfVal)
                ], sTable_Batcode, nTmp, False);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    //Desc: ����¼
    procedure OutuseCode(const nID: string);
    begin
      nStr := 'Update %s Set D_Valid=''%s'',D_LastDate=%s Where D_ID=''%s''';
      nStr := Format(nStr, [sTable_BatcodeDoc, sFlag_BatchOutUse,
              sField_SQLServer_Now, nID]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;
begin
  Result := False;

  nStr := 'Select D_Memo, D_Value from %s Where D_Name=''%s'' and ' +
          '(D_Memo=''%s'' or D_Memo=''%s'' or D_Memo=''%s'' or D_Memo=''%s'')';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam,
                        sFlag_BatchAuto, sFlag_BatchBrand,
                        sFlag_BatchValid, sFlag_BatchStockGroup]);
  //xxxxxx

  nUBatchAuto := sFlag_Yes;
  nUBatcode := sFlag_No;
  nUBrand := sFlag_No;
  nUBatStockGroup := sFlag_Yes;
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

      if Fields[0].AsString = sFlag_BatchStockGroup then
        nUBatStockGroup  := Fields[1].AsString;

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
  nStr := 'Select L_StockNo,L_Seal,L_Value,L_IsVIP From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <= 0 then
    begin
      WriteLog('���λ�ȡ(�����):' + FIn.FData + '������');
      Exit;
    end;
    FListA.Values['StockNo'] := Fields[0].AsString;
    FListA.Values['Seal']    := Fields[1].AsString;
    FListA.Values['Value']   := Fields[2].AsString;
    FListA.Values['Type']    := sFlag_TypeCommon;//�ݲ�����
  end;

  WriteLog('���λ�ȡ(�����):' + FListA.Values['Value']);

  if nUBatchAuto = sFlag_Yes then
  begin
    if FListA.Values['Type'] ='' then
          nType := sFlag_TypeCommon
    else  nType := FListA.Values['Type'];

    if (nType <> '') and (nType <> sFlag_TypeCommon) and
       (nType <> sFlag_TypeShip) and (nType <> sFlag_TypeStation) then
      nType := sFlag_TypeCommon;
    //default

    nBatStockNo := FListA.Values['StockNo'];

    if nUBatStockGroup = sFlag_Yes then
    begin
      nStr := 'Select D_ParamB From %s Where D_Name=''%s'' and D_Value=''%s''';
      nStr := Format(nStr, [sTable_SysDict, sFlag_BatStockGroup, nBatStockNo]);
      WriteLog('��ѯ�����������κ����Ϸ���sql:'+nStr);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      begin
        if RecordCount > 0 then
        begin
          nBatStockNo := Fields[0].AsString;
          WriteLog('�������Ϻŷ���ƥ��:'+ FListA.Values['StockNo'] + '-->' + nBatStockNo);
        end;
      end;
    end;

    nKw := '';

    nStr := 'Select D_ParamB From %s Where D_Name=''%s'' and D_Value=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_LineKw, FIn.FExtParam]);
    WriteLog('��ѯװ����������λsql:'+nStr);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount <= 0 then
      begin
        nData := '����[ %s.%s ]װ����[ %s ]δ���ÿ�λ.';
        nData := Format(nData, [nBatStockNo, nType, FIn.FExtParam]);
        WriteLog(nData);
        Exit;
      end;
      nKw := Fields[0].AsString;
    end;

    FOut.FExtParam := '';

    nStr := 'Select *,%s as ServerNow From %s Where B_Stock=''%s'' ' +
            'And B_Type=''%s'' And B_Kw=''%s''';
    nStr := Format(nStr, [sField_SQLServer_Now,sTable_Batcode,nBatStockNo,
                          nType, nKw]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := '����[ %s.%s.%s ]δ�������κŹ�������δ����.';
        nData := Format(nData, [nBatStockNo, nType, nKw]);
        Exit;
      end;

      if FListA.Values['Seal'] <> '' then//�ѻ�ȡ�ҵ�ǰˢ��ͨ��ƥ�����κ�ǰ׺һ��
      begin
        if Pos(FieldByName('B_Prefix').AsString,FListA.Values['Seal']) > 0 then
        begin
          FOut.FData := '';
          Result := True;
          Exit;
        end;
      end;

      nRID := FieldByName('R_ID').AsInteger;

      if FieldByName('B_UseDate').AsString = sFlag_Yes then  //ʹ�����ڱ���
      begin
        nP := FieldByName('B_Prefix').AsString;
        nStr := FormatDateTime('YYMMDD',FieldByName('ServerNow').AsDateTime);

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

        nP := Format('R_ID=%d', [nRID]);

        nStr := MakeSQLByStr([SF('B_Batcode', FOut.FData),
                  SF('B_FirstDate', sField_SQLServer_Now, sfVal),
                  SF('B_HasUse', 0, sfVal),
                  SF('B_LastDate', sField_SQLServer_Now, sfVal)
                  ], sTable_Batcode, nP, False);
        gDBConnManager.WorkerExec(FDBConn, nStr);

        Result := True;
        Exit;
      end;

      FOut.FData := FieldByName('B_Batcode').AsString;
      nInc := FieldByName('B_Incement').AsInteger;
      nNew := False;

      if FieldByName('B_AutoNew').AsString = sFlag_Yes then //Ԫ������
      begin
        nStr := Date2Str(FieldByName('ServerNow').AsDateTime);
        nStr := Copy(nStr, 1, 4);
        nP := Date2Str(FieldByName('B_LastDate').AsDateTime);
        nP := Copy(nP, 1, 4);

        if nStr <> nP then
        begin
          nStr := 'Update %s Set B_Base=1 Where R_ID=%d';
          nStr := Format(nStr, [sTable_Batcode, nRID]);

          gDBConnManager.WorkerExec(FDBConn, nStr);
          FOut.FData := NewBatCode(nType);
          nNew := True;
        end;
      end;

      if not nNew then //��ų���
      begin
        nStr := Date2Str(FieldByName('ServerNow').AsDateTime);
        nP := Date2Str(FieldByName('B_FirstDate').AsDateTime);

        if (Str2Date(nP) > Str2Date('2000-01-01')) and
           (Str2Date(nStr) - Str2Date(nP) > FieldByName('B_Interval').AsInteger) then
        begin
          nStr := 'Update %s Set B_Base=B_Base+%d Where R_ID=%d';
          nStr := Format(nStr, [sTable_Batcode, nInc, nRID]);

          gDBConnManager.WorkerExec(FDBConn, nStr);
          FOut.FData := NewBatCode(nType);
          FOut.FExtParam := '����[ %s.%s.%s ]�����κ��Ѿ�����,�����������κ�,�뻯���Ҿ���ȡ��.';
          FOut.FExtParam := Format(FOut.FExtParam, [FieldByName('B_Stock').AsString,
                                FieldByName('B_Name').AsString, nKw]);
          nNew := True;
        end;
      end;

      if not nNew then //��ų���
      begin
        nVal := FieldByName('B_HasUse').AsFloat + StrToFloat(FListA.Values['Value']);
        //��ʹ��+Ԥʹ��
        nPer := FieldByName('B_Value').AsFloat * FieldByName('B_High').AsFloat / 100;
        //��������

        if nVal >= nPer then //����
        begin
          nStr := 'Update %s Set B_Base=B_Base+%d Where R_ID=%d';
          nStr := Format(nStr, [sTable_Batcode, nInc, nRID]);

          gDBConnManager.WorkerExec(FDBConn, nStr);
          FOut.FData := NewBatCode(nType);

          FOut.FExtParam := '����[ %s.%s.%s ]�Ѿ��������κ�,�뻯���Ҿ���ȡ��.';
          FOut.FExtParam := Format(FOut.FExtParam, [FieldByName('B_Stock').AsString,
                                FieldByName('B_Name').AsString, nKw]);
          //xxxxx
        end else
        begin
          nPer := FieldByName('B_Value').AsFloat * FieldByName('B_Low').AsFloat / 100;
          //����

          if nVal >= nPer then //��������
          begin
            FOut.FExtParam := '����[ %s.%s.%s ]�����������κ�,�뻯����׼��ȡ��.';
            FOut.FExtParam := Format(FOut.FExtParam, [FieldByName('B_Stock').AsString,
                                  FieldByName('B_Name').AsString, nKw]);
            //xxxxx
          end;
        end;
      end;
    end;

    if FOut.FData = '' then
      FOut.FData := NewBatCode(nType);
    //xxxxx
    nVal := StrToFloatDef(FListA.Values['Value'],0);

    nStr := 'Update %s Set L_Seal=''%s'' Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, FOut.FData, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr); //�������κ�

    nStr := 'Update %s Set B_HasUse=B_HasUse+(%s),B_LastDate=%s ' +
            'Where R_ID=%d';
    nStr := Format(nStr, [sTable_Batcode, FloatToStr(nVal),
            sField_SQLServer_Now, nRID]);
    gDBConnManager.WorkerExec(FDBConn, nStr); //�������κ�ʹ����

    if FListA.Values['Seal'] <> '' then//�ͷž�����
    begin
      nStr := 'Update %s Set B_HasUse=B_HasUse-(%s) ' +
              'Where B_BatCode=''%s''';
      nStr := Format(nStr, [sTable_Batcode, FloatToStr(nVal),
              FListA.Values['Seal']]);
      gDBConnManager.WorkerExec(FDBConn, nStr); //�������κ�ʹ����
    end;

    Result := True;
    FOut.FBase.FResult := True;

    Exit;
  end
  else
  begin
    WriteLog('δ�����Զ�����,�޷���ȡ����');
    Exit;
  end;
  //�Զ���ȡ���κ�
end;

function TWorkerBusinessCommander.SaveBatEvent(var nData: string): Boolean;
var nStr,nEvent,nEID,nBatStockNo: string;
begin
  nBatStockNo := FIn.FData;
  nEvent := FIn.FExtParam;
  if (nBatStockNo = '') or (nEvent = '') then
    Exit;

  nStr := 'Select D_ParamB From %s Where D_Name=''%s'' and D_Value=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_BatStockGroup, nBatStockNo]);
  WriteLog('��ѯ�����������κ����Ϸ���sql:'+nStr);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
    begin
      nBatStockNo := Fields[0].AsString;
    end;
  end;

  nEID := nBatStockNo + sFlag_ManualF;

  nStr := 'Delete From %s Where E_ID=''%s''';
  nStr := Format(nStr, [sTable_ManualEvent, nEID]);

  gDBConnManager.WorkerExec(FDBConn, nStr);

  nStr := MakeSQLByStr([
      SF('E_ID', nEID),
      SF('E_Key', ''),
      SF('E_From', ''),
      SF('E_Event', nEvent),
      SF('E_Solution', sFlag_Solution_OK),
      SF('E_Departmen', '������'),
      SF('E_Date', sField_SQLServer_Now, sfVal)
      ], sTable_ManualEvent, '', True);
  gDBConnManager.WorkerExec(FDBConn, nStr);
end;

//Date: 2019-02-13
//Desc: ��ȡ�����������
function TWorkerBusinessCommander.GetGroupByArea(var nData: string): Boolean;
var nStr: string;
begin
  Result := True;
  FOut.FData := '';//default

  nStr := 'Select D_Value From %s Where D_Name=''%s'' ' +
          ' and D_Memo=''%s'' and D_ParamB=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_ZTLineGroup,
                        FIn.FData, FIn.FExtParam]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      Exit;
    end;

    FOut.FData := Fields[0].AsString;
  end;
end;

function TWorkerBusinessCommander.GetUnLoadingPlace(var nData: string): Boolean;
var nStr: string;
begin
  Result := False;

  if FIn.FData = '' then Exit;

  nStr := 'Select D_Value From %s Where D_Name=''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <= 0 then
      Exit;

    FListC.Clear;

    First;

    while not Eof do
    begin
      FListC.Add(Fields[0].AsString);
      Next;
    end;
  end;

  FOut.FData := FListC.Text;
  Result := True;
end;

//Date: 2019-04-04
//Desc: ��ȡɢװˢ���������ü�У��
function TWorkerBusinessCommander.VerifySanCardUseCount(var nData: string): Boolean;
var nStr: string;
    nSetCount, nNowCount: Integer;
begin
  Result := False;
  FOut.FData := '';//default

  nSetCount := 5;
  nNowCount := 0;

  nStr := 'Select D_Value From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SanUseCardCount]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      Result := True;//������
      Exit;
    end;

    nSetCount := Fields[0].AsInteger;
  end;

  nStr := 'Select L_CardCount From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      Result := True;//������
      Exit;
    end;

    nNowCount := Fields[0].AsInteger;
  end;
  WriteLog('ɢװˢ�������趨:' + IntToStr(nSetCount) + '�����' + FIn.FData
           + '��ǰˢ������:' + IntToStr(nNowCount));
  if nNowCount > nSetCount then
    Exit;

  nStr := 'Update %s Set L_CardCount=L_CardCount + 1 where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);
  gDBConnManager.WorkerExec(FDBConn, nStr);
  
  Result := True;
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TBusWorkerQueryField, sPlug_ModuleBus);
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessCommander, sPlug_ModuleBus);
end.

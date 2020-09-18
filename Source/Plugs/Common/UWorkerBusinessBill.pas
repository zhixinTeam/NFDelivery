{*******************************************************************************
  ����: dmzn@163.com 2013-12-04
  ����: ģ��ҵ�����
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
    FID: string;            //���
    FName: string;          //����
    FType: string;          //����
    FPackStyle: string;     //��װ����
  end;

  TStockMatchItem = record
    FStock: string;         //Ʒ��
    FGroup: string;         //����
    FPriority: Integer;     //����
    FRecord: string;        //��¼
  end;

  TBillLadingLine = record
    FBill: string;          //������
    FLine: string;          //װ����
    FName: string;          //������
    FPerW: Integer;         //����
    FTotal: Integer;        //�ܴ���
    FNormal: Integer;       //����
    FBuCha: Integer;        //����
    FHKBills: string;       //�Ͽ���
    FLineGroup: string;     //ͨ������
  end;

  TOrderItem = record
    FOrder: string;         //������
    FCusID: string;         //�ͻ���
    FCusName: string;       //�ͻ���
    FCusCode: string;       //�ͻ�����
    FAreaTo: string;        //��������
    FAreaToName: string;    //������������
    FStockID: string;       //Ʒ�ֺ�
    FStockName: string;     //Ʒ����
    FStockType: string;     //����
    FPackStyle: string;     //��װ����
    FSaleID: string;        //ҵ���
    FSaleName: string;      //ҵ����
    FMaxValue: Double;      //������
    FKDValue: Double;       //������
    FOrderNo: string;       //�������
    FCompany: string;       //��˾ID
    FSpecialCus: string;    //�Ƿ�Ϊ����ͻ�
    FSnlx: string;          //ˮ������
    FTruck: string;         //���ƺ�
  end;

  TOrderItems = array of TOrderItem;
  //�����б�

  TWorkerBusinessBills = class(TMITDBWorker)
  private
    FListA,FListB,FListC,FListD: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
    //io
    FSanMultiBill: Boolean;
    //ɢװ�൥
    FDefaultBrand: string;
    //Ĭ��Ʒ��
    FAutoBatBrand: Boolean;
    //�Զ�����ʹ��Ʒ��
    FStockInfo: array of TStockInfoItem;
    //Ʒ����Ϣ
    FStockItems: array of TStockMatchItem;
    FMatchItems: array of TStockMatchItem;
    //����ƥ��
    FOrderItems: TOrderItems;
    //�����б�
    FBillLines: array of TBillLadingLine;
    //װ����
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function LoadStockInfo(var nData: string): Boolean;
    function GetStockInfo(const nID: string): Integer;
    //������Ϣ
    function GetStockGroup(const nStock: string; var nPriority: Integer): string;
    function GetMatchRecord(const nStock: string): string;
    //���Ϸ���
    function DefaultBrand: string;
    //Ĭ��Ʒ��
    function VerifyTruckTimeWhenP(const nTruck: string;
      var nData: string): Boolean;
    //������Ƥ��ʱ
    function GetInBillInterval: Integer;
    function AllowedSanMultiBill: Boolean;
    function AutoVipByLine(const nStockNo: string; nValue: Double): Boolean;
    //����ͨ�������Զ���ΪVIP�����
    function GetCusGroup(const nCusID, nDefaultGroup, nStockNo: string): string;
    //��ȡ����ͻ�����
    function VerifyHYRecord(const nSeal: string): Boolean;
    //���춨��¼�Ƿ����
    function VerifyBeforSave(var nData: string): Boolean;
    function VerifyBeforSaveMulCard(var nData: string): Boolean;
    function SaveBills(var nData: string): Boolean;
    //���潻����
    function DeleteBill(var nData: string): Boolean;
    //ɾ��������
    function ChangeBillTruck(var nData: string): Boolean;
    //�޸ĳ��ƺ�
    function SaveBillCard(var nData: string): Boolean;
    //�󶨴ſ�
    function SaveBillMulCard(var nData: string): Boolean;
    //�󶨴ſ�(һ���࿨)
    function LogoffCard(var nData: string): Boolean;
    //ע���ſ�
    function GetPostBillItems(var nData: string): Boolean;
    //��ȡ��λ������
    function SavePostBillItems(var nData: string): Boolean;
    //�����λ������

    function LinkToNCSystem(var nData: string; nBill: TLadingBillItem): Boolean;
    //����NC����
    function LinkToNCSystemBySaleOrder(var nData: string; nBill: TLadingBillItem): Boolean;
    //����NC����
    function SaveBillNew(var nData: string): Boolean;
    //���潻����
    function DeleteBillNew(var nData: string): Boolean;
    //ɾ��������
    function SaveBillNewCard(var nData: string): Boolean;
    //�󶨴ſ�
    //function LogoffCardNew(var nData: string): Boolean;
    //ע���ſ�
    function SaveBillFromNew(var nData: string): Boolean;
    //���潻����
  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
    class function VerifyTruckNO(nTruck: string; var nData: string): Boolean;
    //��֤�����Ƿ���Ч
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
//Parm: ��������
//Desc: ִ��nDataҵ��ָ��
function TWorkerBusinessBills.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
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
      nData := '��Ч��ҵ�����(Invalid Command).';
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2014/7/30
//Parm: Ʒ�ֱ��;���ȼ�
//Desc: ����nStock��Ӧ�����Ϸ���
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
//Parm: Ʒ�ֱ��
//Desc: ����������������nStockͬƷ��,��ͬ��ļ�¼
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
//Desc: ����ɢװ�൥
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
//Desc: ����ͨ�������Զ���ΪVIP�����
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
//Desc: ��ȡ����ͻ�����
function TWorkerBusinessBills.GetCusGroup(const nCusID, nDefaultGroup,nStockNo: string): string;
var nStr: string;
begin
  Result := nDefaultGroup;

  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s'' And D_ParamB=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_CusGroup, nCusID, nStockNo]);

  WriteLog('��ȡ����ͻ�����sql:' + nStr);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsString;
    WriteLog('����ͻ����ڷ���:' + Result);
  end;
end;

//Date: 2019-05-09
//Desc: ���춨��¼�Ƿ����
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
//Parm: ��
//Desc: ��ȡĬ�ϵ�Ʒ������
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
//Desc: ������������ָ��ʱ���ڱ��뿪��,������Ч
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
        WriteLog('����ǩ������������ʼʱ��:' + DateTime2Str(nBegTime) + '����ʱ��:' + DateTime2Str(nEndTime));

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
//Desc: ����������Ϣ
function TWorkerBusinessBills.LoadStockInfo(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
begin
  Result := Length(FStockInfo) > 0;
  if Result then Exit;

  nStr := 'Select D_Value,D_Memo,D_ParamB,D_ParamC From %s Where D_Name=''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem]);
  //�����б�
    
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    SetLength(FStockInfo, RecordCount);
    //xxxxx
    
    if RecordCount < 1 then
    begin
      nData := '���ȳ�ʼ��StockItem�ֵ���.';
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
//Parm: ���ϱ��
//Desc: ����nID�������ڵ�����
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
//Parm: �����б�
//Desc: ��nOrders����������С��������
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
  //ð������
end;


//Date: 2014-09-16
//Parm: ���ƺ�;
//Desc: ��֤nTruck�Ƿ���Ч
class function TWorkerBusinessBills.VerifyTruckNO(nTruck: string;
  var nData: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := TWorkerBusinessCommander.CallMe(cBC_IsTruckValid, nTruck, '', @nOut);
  if not Result then nData := nOut.FData;
end;

//Date: 2017-09-10
//Parm: ���ƺ�
//Desc: ������Ƥʱ,��֤�Ƿ������ʱ
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
    //����ʱ����Ч

    nMin := Trunc((Fields[0].AsFloat - Fields[1].AsFloat) / (1 / (24 * 60)));
    //�������������
  end;

  nStr := 'Select D_Value From %s ' +
          'Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_InAndPound]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if (RecordCount > 0) and (Fields[0].AsInteger < nMin) then
  begin
    nData := '����[ %s ]������[ %d ]����δ����,��ʱ[ %d ]����.';
    nData := Format(nData, [nTruck, Fields[0].AsInteger, nMin]);
    Result := False;
  end;
end;

//Date: 2014-09-15
//Desc: ��֤�ܷ񿪵�
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
      nData := 'û�г���[ %s ]�ĵ���,�޷�����.';
      nData := Format(nData, [nTruck]);
      Exit;
    end;
    {$ENDIF}

    if FieldByName('T_Valid').AsString = sFlag_No then
    begin
      nData := '����[ %s ]������Ա��ֹ����.';
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
      if FListA.Values['Post'] = '' then //��������֤
      if FieldByName('T_NoVerify').AsString <> sFlag_Yes then
      begin
        nIdx := Trunc((FieldByName('T_Now').AsDateTime -
                       FieldByName('T_LastTime').AsDateTime) * 24 * 60);
        //�ϴλ������

        if nIdx >= nInt then
        begin
          nData := '����[ %s ]���ܲ���ͣ����,��ֹ����.';
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
  //ɢװ�����൥

  FDefaultBrand := DefaultBrand;
  //ѡ�����κ�ʱĬ��Ʒ��

  {$IFDEF StockPriorityInQueue}
  nStr := 'Select M_ID,M_Group,M_Priority From %s Where M_Status=''%s'' ';
  {$ELSE}
  nStr := 'Select M_ID,M_Group From %s Where M_Status=''%s'' ';
  {$ENDIF}

  nStr := Format(nStr, [sTable_StockMatch, sFlag_Yes]);
  //Ʒ�ַ���ƥ��

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
  //�����ڶ����е���Ϣ

  nStr := 'Select R_ID,T_Bill,T_StockNo,T_Type,T_InFact,T_Valid From %s ' +
          'Where T_Truck=''%s'' ';
  nStr := Format(nStr, [sTable_ZTTrucks, nTruck]);
  //���ڶ����г���

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
      //��ȡ�����ڶ����е�����

      if nType = sFlag_San then
      begin
        if not FSanMultiBill then
        begin
          nStr := '����[ %s ]��δ���[ %s ]������֮ǰ��ֹ����.';
          nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
          Exit;
        end;

        nQBill := FieldByName('T_Bill').AsString;
      end else

      if (nType = sFlag_Dai) and
         (FieldByName('T_InFact').AsString <> '') then
      begin
        nStr := '����[ %s ]��δ���[ %s ]������֮ǰ��ֹ����.';
        nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
        Exit;
      end;

      if FieldByName('T_Valid').AsString = sFlag_No then
      begin
        nStr := '����[ %s ]���ѳ��ӵĽ�����[ %s ],���ȴ���.';
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
        nData := Format('�����[ %s ]��Ϣ�Ѷ�ʧ.', [nQBill]);
        Exit;
      end;

      with nQItem do
      begin
        FID := FieldByName('L_ID').AsString;
        FStockNo := FieldByName('L_StockNO').AsString;
        FStockName := FieldByName('L_StockName').AsString;

        FCusID := FieldByName('L_CusID').AsString;
        FCusName := FieldByName('L_CusName').AsString;

        FOrigin := FieldByName('L_Area').AsString;      //��������
        FExtID_1:= FieldByName('L_StockArea').AsString; //�����ص�
      end;
    end;
  end;
  //��ȡ�����е�ɢװ�����������Ϣ

  TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, nTruck, '', @nOut);
  //���泵�ƺ�

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
    nData := Format('��ȡ[ %s ]������Ϣʧ��', [nStr]);
    Exit;
  end;

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nOut.FData, nWorker, sFlag_DB_NC), FListA do
    begin
      if RecordCount < 1 then
      begin
        nStr := StringReplace(FListB.Text, #13#10, ',', [rfReplaceAll]);
        nData := Format('����[ %s ]��Ϣ�Ѷ�ʧ.', [nStr]);
        Exit;
      end;

      if (nType = sFlag_San)  and (nQBill <> '') and FSanMultiBill then
      with nQItem do
      begin
        if FieldByName('invcode').AsString <> FStockNo then
        begin
          nStr := '����[ %s ]���н�����[ %s ]Ʒ��[ %s ]�� ����������Ʒ��[ %s ]'+
                  '��ͬ,��ֹ�ϵ�.';
          nData := Format(nStr, [nTruck, nQBill, FStockName,
                   FieldByName('invname').AsString]);
          Exit;
        end;

        if FieldByName('custcode').AsString <> FCusID then
        begin
          nStr := '����[ %s ]���н�����[ %s ]�ͻ�[ %s ]�� �����������ͻ�[ %s ]'+
                  '��ͬ,��ֹ�ϵ�.';
          nData := Format(nStr, [nTruck, nQBill, FCusName,
                   FieldByName('custname').AsString]);
          Exit;
        end;

        if FieldByName('vdef2').AsString <> FOrigin then
        begin
          nStr := '����[ %s ]���н�����[ %s ]��������[ %s ]�� ������������������[ %s ]'+
                  '��ͬ,��ֹ�ϵ�.';
          nData := Format(nStr, [nTruck, nQBill, FOrigin,
                   FieldByName('vdef2').AsString]);
          Exit;
        end;

        if FieldByName('areaclname').AsString <> FExtID_1 then
        begin
          nStr := '����[ %s ]���н�����[ %s ]�����ص�[ %s ]�� ���������������ص�[ %s ]'+
                  '��ͬ,��ֹ�ϵ�.';
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
      //��������

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
          //��������
          FCompany := FieldByName('company').AsString;
          FSpecialCus := FieldByName('specialcus').AsString;
          FSnlx    := FieldByName('vdef10').AsString;
          nIdx := GetStockInfo(FStockID);
          if nIdx < 0 then
          begin
            nData := 'Ʒ��[ %s ]���ֵ��е���Ϣ��ʧ.';
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
  //�����б�

  if not TWorkerBusinessCommander.CallMe(cBC_GetOrderFHValue, nStr, '', @nOut) then
  begin
    nStr := StringReplace(FListB.Text, #13#10, ',', [rfReplaceAll]);
    nData := Format('��ȡ[ %s ]����������ʧ��', [nStr]);
    Exit;
  end;

  FListC.Text := PackerDecodeStr(nOut.FData);
  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  begin
    nStr := FListC.Values[FOrderItems[nIdx].FOrder];
    if not IsNumber(nStr, True) then Continue;

    with FOrderItems[nIdx] do
      FMaxValue := FMaxValue - StrToFloat(nStr);
    //������ = �ƻ��� - �ѷ���
  end;

  SortOrderByValue(FOrderItems);
  //����������С��������

  //----------------------------------------------------------------------------
  nStr := FListA.Values['Value'];
  nVal := Float2Float(StrToFloat(nStr), cPrecision, True);

  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  begin
    if nVal <= 0 then Break;
    //�������Ѵ������

    nDec := Float2Float(FOrderItems[nIdx].FMaxValue, cPrecision, False);
    //����������

    if nDec >= nVal then
      nDec := nVal;
    //����������ֱ�ӿ۳�������

    with FOrderItems[nIdx] do
    begin
      //FMaxValue := Float2Float(FMaxValue, cPrecision, False) - nDec;
      FKDValue := nDec;
    end;

    nVal := Float2Float(nVal - nDec, cPrecision, True);
    //����ʣ����

    if FOrderItems[nIdx].FTruck <> '' then
    begin
      WriteLog('����' + FOrderItems[nIdx].FOrder + '���ƺ�' + FOrderItems[nIdx].FTruck
               + 'Ϊһ��һ��,����У�鶩����...'  );
      nVal := 0;
    end;
  end;

  if nVal > 0 then
  begin
    nData := '�������������������[ %.2f ]��,����ʧ��.';
    nData := Format(nData, [nVal]);
    Exit;
  end;

  {$IFNDEF TruckTypeOnlyPound}
  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  begin
    if FOrderItems[nIdx].FKDValue <= 0 then Continue;
    //�޿�����
    if FOrderItems[nIdx].FStockType = sFlag_San then
    begin
      nStr := 'Select %s as T_Now,* From %s ' +
              'Where T_Truck=''%s''';
      nStr := Format(nStr, [sField_SQLServer_Now, sTable_Truck, FListA.Values['Truck']]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      begin
        if RecordCount < 1 then
        begin
          nData := 'û�г���[ %s ]�ĵ���,�޷�����.';
          nData := Format(nData, [FListA.Values['Truck']]);
          Exit;
        end;

        if FieldByName('T_CzType').AsString = '' then
        begin
          nData := '����[ %s ]δά����������,�޷�����.';
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
//Desc: ��֤�ܷ񿪵�(һ���࿨)
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
        nData := 'û�г���[ %s ]�ĵ���,�޷�����.';
        nData := Format(nData, [nTruck]);
        Exit;
      end;

      if FieldByName('T_Valid').AsString = sFlag_No then
      begin
        nData := '����[ %s ]������Ա��ֹ����.';
        nData := Format(nData, [nTruck]);
        Exit;
      end;

      if FListA.Values['Post'] = '' then //��������֤
      if FieldByName('T_NoVerify').AsString <> sFlag_Yes then
      begin
        nIdx := Trunc((FieldByName('T_Now').AsDateTime -
                       FieldByName('T_LastTime').AsDateTime) * 24 * 60);
        //�ϴλ������

        if nIdx >= nInt then
        begin
          nData := '����[ %s ]���ܲ���ͣ����,��ֹ����.';
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
  //ɢװ�����൥

  FDefaultBrand := DefaultBrand;
  //ѡ�����κ�ʱĬ��Ʒ��

  {$IFDEF StockPriorityInQueue}
  nStr := 'Select M_ID,M_Group,M_Priority From %s Where M_Status=''%s'' ';
  {$ELSE}
  nStr := 'Select M_ID,M_Group From %s Where M_Status=''%s'' ';
  {$ENDIF}

  nStr := Format(nStr, [sTable_StockMatch, sFlag_Yes]);
  //Ʒ�ַ���ƥ��

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
  //���泵�ƺ�

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
    nData := Format('��ȡ[ %s ]������Ϣʧ��', [nStr]);
    Exit;
  end;

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nOut.FData, nWorker, sFlag_DB_NC), FListA do
    begin
      if RecordCount < 1 then
      begin
        nStr := StringReplace(FListB.Text, #13#10, ',', [rfReplaceAll]);
        nData := Format('����[ %s ]��Ϣ�Ѷ�ʧ.', [nStr]);
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
      //��������

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
          //��������

          nIdx := GetStockInfo(FStockID);
          if nIdx < 0 then
          begin
            nData := 'Ʒ��[ %s ]���ֵ��е���Ϣ��ʧ.';
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
  //�����б�

  if not TWorkerBusinessCommander.CallMe(cBC_GetOrderFHValue, nStr, '', @nOut) then
  begin
    nStr := StringReplace(FListB.Text, #13#10, ',', [rfReplaceAll]);
    nData := Format('��ȡ[ %s ]����������ʧ��', [nStr]);
    Exit;
  end;

  FListC.Text := PackerDecodeStr(nOut.FData);
  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  begin
    nStr := FListC.Values[FOrderItems[nIdx].FOrder];
    if not IsNumber(nStr, True) then Continue;

    with FOrderItems[nIdx] do
      FMaxValue := FMaxValue - StrToFloat(nStr);
    //������ = �ƻ��� - �ѷ���
  end;

  SortOrderByValue(FOrderItems);
  //����������С��������

  //----------------------------------------------------------------------------
  nStr := FListA.Values['Value'];
  nVal := Float2Float(StrToFloat(nStr), cPrecision, True);

  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  begin
    if nVal <= 0 then Break;
    //�������Ѵ������

    nDec := Float2Float(FOrderItems[nIdx].FMaxValue, cPrecision, False);
    //����������

    if nDec >= nVal then
      nDec := nVal;
    //����������ֱ�ӿ۳�������

    with FOrderItems[nIdx] do
    begin
      //FMaxValue := Float2Float(FMaxValue, cPrecision, False) - nDec;
      FKDValue := nDec;
    end;

    nVal := Float2Float(nVal - nDec, cPrecision, True);
    //����ʣ����
  end;

  if nVal > 0 then
  begin
    nData := '�������������������[ %.2f ]��,����ʧ��.';
    nData := Format(nData, [nVal]);
    Exit;
  end;

  Result := True;
  //verify done
end;

//Date: 2014-09-15
//Desc: ���潻����
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
  //��ʹ�ô�װ�������Ƶ�ҵ��

  nDBWorker := FDBConn;
  FDBConn := nil;
  //���ݾ���·

  try
    with gParamManager.ActiveParam^ do
    begin
      FDBConn := gDBConnManager.GetConnection(FDB.FID, nErrCode, True);

      if not Assigned(FDBConn) then
      begin
        nData := Format('����[ %s ]���ݿ�ʧ��(ErrCode: %d).', [FDB.FID, nErrCode]);
        Exit;
      end;

      if not FDBConn.FConn.Connected then
        FDBConn.FConn.Connected := True;
      //conn db
    end;

    FDBConn.FConn.BeginTrans;
    //��������
    FOut.FData := '';
    //bill list

    if FListA.Values['Brand'] <> '' then
      nBrand := Trim(FListA.Values['Brand']);
    //�ͻ���ָ��Ʒ��ʱ,ѡ��Ʒ��

    if nBrand = '' then
      nBrand := FDefaultBrand;
    //ʹ��Ĭ��Ʒ��

    for nIdx:=Low(FOrderItems) to High(FOrderItems) do
    begin
      if FOrderItems[nIdx].FKDValue <= 0 then Continue;
      //�޿�����

      {$IFDEF GROUPBYAREA}
      if TWorkerBusinessCommander.CallMe(cBC_GetGroupByArea,
          FOrderItems[nIdx].FAreaToName, FOrderItems[nIdx].FStockID, @nOut) then
      begin
        if nOut.FData <> '' then
        begin
          FListA.Values['LineGroup'] := nOut.FData;

          nStr := '����[ %s ]��������[ %s ]ƥ��ͨ������:[ %s ]';
          nStr := Format(nStr, [FOrderItems[nIdx].FStockID,
                                FOrderItems[nIdx].FAreaToName,
                                nOut.FData]);
          WriteLog(nStr);
        end;
      end;
      {$ENDIF}

      {$IFNDEF ManuPack}
      FListA.Values['Pack'] := FOrderItems[nIdx].FPackStyle;
      //��װ����
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
        //��ȡ�µ�����

        if PBWDataBase(@nOut).FErrCode = sFlag_ForceHint then
        begin
          FOut.FBase.FErrCode := sFlag_ForceHint;
          FOut.FBase.FErrDesc := PBWDataBase(@nOut).FErrDesc;
        end;

        {$IFDEF VerifyHYRecord}
        if not VerifyHYRecord(FListA.Values['Seal']) then
        raise Exception.Create('���κ�[' +
                      FListA.Values['Seal'] +']�춨��¼������,����ʧ��');
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
              {$ENDIF} //�泵��ӡ���鵥

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
              {$ENDIF} //�泵��ӡ���鵥

              {$IFDEF SNLX}
              SF('L_Snlx',     FOrderItems[nIdx].FSnlx),
              {$ENDIF} //ˮ������

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
      //��װ�������Ƶ�,Ӱ������Ƶ��Ͷ���ҵ��

      if nDaiQuickSync then
      with FOrderItems[nIdx] do
      begin
        nStr := '����[ %s.%s ]ʹ�ÿ������Ƶ�ҵ��.';
        nStr := Format(nStr, [FOrder, FStockName]);
        WriteLog(nStr);
      end;
      {$ENDIF}

      if FListA.Values['Post'] = sFlag_TruckBFM then //ɢװ����ʱ����
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
        //���涩��

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

                SF('P_Direction', '����'),
                SF('P_PModel', sFlag_PoundPD),
                SF('P_Status', sFlag_TruckBFP),
                SF('P_Valid', sFlag_Yes),
                SF('P_PrintNum', 1, sfVal)
                ], sTable_PoundLog, '', True);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end else

      if FListA.Values['BuDan'] = sFlag_Yes then //����
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
        //��Ʒ����װ�������еļ�¼��

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
          //�����¼��

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

      //���� or ��װ��ǰ�Ƶ�
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
      gDBConnManager.WorkerExec(FDBConn, nSQL); //�������κ�ʹ����
      {$ELSE}
      if FAutoBatBrand then
      begin
        nSQL := 'Update %s Set B_HasUse=B_HasUse+(%s),B_LastDate=%s ' +
                'Where B_Batcode=''%s'' ';
        nSQL := Format(nSQL, [sTable_Batcode, FloatToStr(FOrderItems[nIdx].FKDValue),
                sField_SQLServer_Now, FListA.Values['Seal']]);
        gDBConnManager.WorkerExec(FDBConn, nSQL); //�������κ�ʹ����
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
        gDBConnManager.WorkerExec(FDBConn, nSQL); //�������κ�ʹ����
      end;
      {$ENDIF}

      nSQL := 'Update %s Set D_Sent=D_Sent+(%s) Where D_ID=''%s''';
      nSQL := Format(nSQL, [sTable_BatcodeDoc, FloatToStr(FOrderItems[nIdx].FKDValue),
              FListA.Values['Seal']]);
      gDBConnManager.WorkerExec(FDBConn, nSQL); //�������κ�ʹ����
      {$ENDIF}

      {$IFDEF SaleAICMFromNC}
      if Trim(FListA.Values['wxzhuid']) <> '' then//���˷�΢���µ�
      begin
        if FListA.Values['Post'] = sFlag_TruckBFM then //ɢװ����ʱ����
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
      //΢������
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
    //��ԭ��·
  except
    FDBConn.FConn.RollbackTrans;
    gDBConnManager.ReleaseConnection(FDBConn);
    FDBConn := nDBWorker;
    //��ԭ��·
    raise;
  end;

  {$IFDEF DaiQuickSync}
  if nDaiQuickSync then
  begin
    SplitStr(FOut.FData, FListC, 0, ',');
    if not TWorkerBusinessCommander.CallMe(cBC_SyncME25,
          FListC.Text, '', @nOut) then
      raise Exception.Create(nOut.FData);
    //��װ�������Ƶ�,ͬ����NC��
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
  //����ͬ����Ϣ

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
//Parm: ������[FIn.FData];���ƺ�[FIn.FExtParam]
//Desc: �޸�ָ���������ĳ��ƺ�
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
      nData := '������[ %s ]����Ч.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    if Fields[1].AsString <> '' then
    begin
      nData := '������[ %s ]�����,�޷��޸ĳ��ƺ�.';
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
    //�����޸���Ϣ

    if (FListA.Count > 0) and (CompareText(nTruck, FIn.FExtParam) <> 0) then
    begin
      for nIdx:=FListA.Count - 1 downto 0 do
      if CompareText(FIn.FData, FListA[nIdx]) <> 0 then
      begin
        nStr := 'Update %s Set L_Truck=''%s'' Where L_ID=''%s''';
        nStr := Format(nStr, [sTable_Bill, FIn.FExtParam, FListA[nIdx]]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        //ͬ���ϵ����ƺ�
      end;
    end;

    if (FListB.Count > 0) and (CompareText(nTruck, FIn.FExtParam) <> 0) then
    begin
      for nIdx:=FListB.Count - 1 downto 0 do
      begin
        nStr := 'Update %s Set T_Truck=''%s'' Where R_ID=%s';
        nStr := Format(nStr, [sTable_ZTTrucks, FIn.FExtParam, FListB[nIdx]]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        //ͬ���ϵ����ƺ�
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
//Parm: ��������[FIn.FData]
//Desc: ɾ��ָ��������
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
      nData := '������[ %s ]����Ч.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nHasOut := FieldByName('L_OutFact').AsString <> '';
    //�ѳ���

    if nHasOut and (not nIsAdmin) then       //����Ա����ɾ��
    begin
      nData := '������[ %s ]�ѳ���,������ɾ��.';
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
      nData := '������[ %s ]�����ڶ�����¼��,�쳣��ֹ!';
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
      //�Ƴ��ϵ��б�

      if nBill = FIn.FData then
        nBill := FListA[0];
      //����������

      nStr := 'Update %s Set T_Bill=''%s'',T_Value=T_Value-(%.2f),' +
              'T_HKBills=''%s'' Where R_ID=%s';
      nStr := Format(nStr, [sTable_ZTTrucks, nBill, nVal,
              CombinStr(FListA, '.'), nRID]);
      //xxxxx

      gDBConnManager.WorkerExec(FDBConn, nStr);
      //���ºϵ���Ϣ
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
      //�ͷŷ�����
    end else
    begin
      nStr := 'Update %s Set B_Freeze=B_Freeze-(%.2f) Where B_ID=''%s''';
      nStr := Format(nStr, [sTable_Order, nVal, nZK]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //�ͷŶ�����
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
      //�����ֶ�,������ɾ��

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
      gDBConnManager.WorkerExec(FDBConn, nStr); //�������κ�ʹ����

      nStr := 'Update %s Set D_Sent=D_Sent-(%.2f) Where D_ID=''%s''';
      nStr := Format(nStr, [sTable_BatcodeDoc, nVal, nHY]);
      gDBConnManager.WorkerExec(FDBConn, nStr); //�������κ�ʹ����
    end;
    {$ELSE}
      {$IFDEF AutoGetLineGroup}
      nStr := 'Update %s Set B_HasUse=B_HasUse-(%.2f),B_LastDate=%s ' +
              'Where B_Batcode=''%s''';
      nStr := Format(nStr, [sTable_Batcode, nVal,
              sField_SQLServer_Now, nHY]);
      gDBConnManager.WorkerExec(FDBConn, nStr); //�������κ�ʹ����
      {$ELSE}
      if FAutoBatBrand then
      begin
        nStr := 'Update %s Set B_HasUse=B_HasUse-(%.2f),B_LastDate=%s ' +
                'Where B_Batcode=''%s''';
        nStr := Format(nStr, [sTable_Batcode, nVal,
                sField_SQLServer_Now, nHY]);
        gDBConnManager.WorkerExec(FDBConn, nStr); //�������κ�ʹ����
      end
      else
      begin
        if nVip = '' then
         nVip := sFlag_TypeCommon;
        nStr := 'Update %s Set B_HasUse=B_HasUse-(%.2f),B_LastDate=%s ' +
                'Where B_Stock=''%s'' and B_Type=''%s''';
        nStr := Format(nStr, [sTable_Batcode, nVal,
                sField_SQLServer_Now, nSN, nVip]);
        gDBConnManager.WorkerExec(FDBConn, nStr); //�������κ�ʹ����
      end;
      {$ENDIF}

      nStr := 'Update %s Set D_Sent=D_Sent-(%.2f) Where D_ID=''%s''';
      nStr := Format(nStr, [sTable_BatcodeDoc, nVal, nHY]);
      gDBConnManager.WorkerExec(FDBConn, nStr); //�������κ�ʹ����
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
  //����ͬ����Ϣ
end;

//Date: 2014-09-17
//Parm: ������[FIn.FData];�ſ���[FIn.FExtParam]
//Desc: Ϊ�������󶨴ſ�
function TWorkerBusinessBills.SaveBillCard(var nData: string): Boolean;
var nStr,nSQL,nTruck,nType: string;
begin
  nType := '';
  nTruck := '';
  Result := False;

  FListB.Text := FIn.FExtParam;
  //�ſ��б�
  nStr := AdjustListStrFormat(FIn.FData, '''', True, ',', False);
  //�������б�

  nSQL := 'Select L_ID,L_Card,L_Type,L_Truck,L_OutFact From %s ' +
          'Where L_ID In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('������[ %s ]�Ѷ�ʧ.', [FIn.FData]);
      Exit;
    end;

    First;
    while not Eof do
    begin
      if FieldByName('L_OutFact').AsString <> '' then
      begin
        nData := '������[ %s ]�ѳ���,��ֹ�쿨.';
        nData := Format(nData, [FieldByName('L_ID').AsString]);
        Exit;
      end;

      nStr := FieldByName('L_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '������[ %s ]�ĳ��ƺŲ�һ��,���ܲ���.' + #13#10#13#10 +
                 '*.��������: %s' + #13#10 +
                 '*.��������: %s' + #13#10#13#10 +
                 '��ͬ�ƺŲ��ܲ���,���޸ĳ��ƺ�,���ߵ����쿨.';
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
             nData := '������[ %s ]ͬΪɢװ,���ܲ���.'
        else nData := '������[ %s ]��ˮ�����Ͳ�һ��,���ܲ���.';

        nData := Format(nData, [FieldByName('L_ID').AsString]);
        Exit;
      end;

      if nType = '' then
        nType := nStr;
      //xxxxx

      nStr := FieldByName('L_Card').AsString;
      //����ʹ�õĴſ�

      if (nStr <> '') and (FListB.IndexOf(nStr) < 0) then
        FListB.Add(nStr);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  if nTruck = '' then
  begin
    nData := '������[ %s ]���ƺ���Ч(Truck Is Blank).';
    nData := Format(nData, [FIn.FData]);
    Exit;
  end;

  SplitStr(FIn.FData, FListA, 0, ',');
  //�������б�
  nStr := AdjustListStrFormat2(FListB, '''', True, ',', False);
  //�ſ��б�

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
        nData := '����[ %s ]����ʹ�øÿ�,�޷�����.';
        nData := Format(nData, [FieldByName('L_Truck').AsString]);
        Exit;
      end;

      nStr := FieldByName('L_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '����[ %s ]����ʹ�øÿ�,��ͬ�ƺŲ��ܲ���.';
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
  nSQL := Format(nSQL, [sTable_Bill, nTruck]); //�ó�����������

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      nStr := FieldByName('L_Type').AsString;
      if ((nType <> '') and (nStr <> nType)) then
      begin
        nData := '������[ %s ]ˮ��Ʒ�ֲ���,�޷�����.';
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
      //���¼����б�

      nSQL := 'Update %s Set L_Card=''%s'' Where L_ID In(%s)';
      nSQL := Format(nSQL, [sTable_Bill, FIn.FExtParam, nStr]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
      WriteLog('�������󶨴ſ�SQL:' + nSQL);
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
      WriteLog('���Ĵſ�״̬SQL:' + nStr);
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
      WriteLog('���Ĵſ�״̬SQL:' + nStr);
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2018-07-20
//Parm: ������[FIn.FData];�ſ���[FIn.FExtParam]
//Desc: Ϊ�������󶨴ſ�(һ���࿨)
function TWorkerBusinessBills.SaveBillMulCard(var nData: string): Boolean;
var nStr,nSQL,nTruck,nType: string;
begin
  nType := '';
  nTruck := '';
  Result := False;

  FListB.Text := FIn.FExtParam;
  //�ſ��б�
  nStr := AdjustListStrFormat(FIn.FData, '''', True, ',', False);
  //�������б�

  nSQL := 'Select L_ID,L_Card,L_Type,L_Truck,L_OutFact From %s ' +
          'Where L_ID In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('������[ %s ]�Ѷ�ʧ.', [FIn.FData]);
      Exit;
    end;

    First;
    while not Eof do
    begin
      if FieldByName('L_OutFact').AsString <> '' then
      begin
        nData := '������[ %s ]�ѳ���,��ֹ�쿨.';
        nData := Format(nData, [FieldByName('L_ID').AsString]);
        Exit;
      end;

      nStr := FieldByName('L_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '������[ %s ]�ĳ��ƺŲ�һ��,���ܲ���.' + #13#10#13#10 +
                 '*.��������: %s' + #13#10 +
                 '*.��������: %s' + #13#10#13#10 +
                 '��ͬ�ƺŲ��ܲ���,���޸ĳ��ƺ�,���ߵ����쿨.';
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
             nData := '������[ %s ]ͬΪɢװ,���ܲ���.'
        else nData := '������[ %s ]��ˮ�����Ͳ�һ��,���ܲ���.';

        nData := Format(nData, [FieldByName('L_ID').AsString]);
        Exit;
      end;

      if nType = '' then
        nType := nStr;
      //xxxxx

      nStr := FieldByName('L_Card').AsString;
      //����ʹ�õĴſ�

      if (nStr <> '') and (FListB.IndexOf(nStr) < 0) then
        FListB.Add(nStr);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  if nTruck = '' then
  begin
    nData := '������[ %s ]���ƺ���Ч(Truck Is Blank).';
    nData := Format(nData, [FIn.FData]);
    Exit;
  end;

  SplitStr(FIn.FData, FListA, 0, ',');
  //�������б�
  nStr := AdjustListStrFormat2(FListB, '''', True, ',', False);
  //�ſ��б�

  nSQL := 'Select L_ID,L_Type,L_Truck From %s Where L_Card In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    nData := '����[ %s ]����ʹ�øÿ�,�޷��쿨.';
    nData := Format(nData, [FieldByName('L_Truck').AsString]);
    Exit;
  end;

  FDBConn.FConn.BeginTrans;
  try
    if FIn.FData <> '' then
    begin
      nStr := AdjustListStrFormat2(FListA, '''', True, ',', False);
      //���¼����б�

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
//Parm: �ſ���[FIn.FData]
//Desc: ע���ſ�
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
//Parm: �ſ���[FIn.FData];��λ[FIn.FExtParam]
//Desc: ��ȡ�ض���λ����Ҫ�Ľ������б�
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
    //ǰ׺�ͳ��ȶ����㽻�����������,����Ϊ��������
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
        nData := Format('�ſ�[ %s ]��Ϣ�Ѷ�ʧ.', [FIn.FData]);
        Exit;
      end;

      if Fields[0].AsString <> sFlag_CardUsed then
      begin
        nData := '�ſ�[ %s ]��ǰ״̬Ϊ[ %s ],�޷����.';
        nData := Format(nData, [FIn.FData, CardStatusToStr(Fields[0].AsString)]);
        Exit;
      end;

      if Fields[1].AsString = sFlag_Yes then
      begin
        nData := '�ſ�[ %s ]�ѱ�����,�޷����.';
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
           nData := '������[ %s ]����Ч.'
      else nData := '�ſ���[ %s ]û�н�����.';

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
//Parm: �Ŷ�˳��
//Desc: ��С��������
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
  //ð������
end;

//Date: 2014-09-18
//Parm: ������[FIn.FData];��λ[FIn.FExtParam]
//Desc: ����ָ����λ�ύ�Ľ������б�
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
    nData := '��λ[ %s ]�ύ�ĵ���Ϊ��.';
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
          nData := '�ſ����[ %s ]��ƥ��.';
          nData := Format(nData, [nBills[0].FCard]);
          Exit;
        end;

        nStr := UpperCase(Fields[0].AsString);
      end;

      if UpperCase(nReader.FGroup) <> nStr then
      begin
        nData := '�ſ���[ %s:::%s ]�������[ %s:::%s ]����ƥ��ʧ��.';
        nData := Format(nData,[nBills[0].FCard, nStr, nReader.FID,
                 nReader.FGroup]);
        Exit;
      end;
    end;
  end;
  //����ʱ����֤�������뿨Ƭ����
  {$ENDIF}

  nDaiQuickSync := False;
  {$IFDEF DaiQuickSync}
  if nBills[0].FType = sFlag_Dai then
    nDaiQuickSync := True;
  //��װ�������Ƶ�,Ӱ������Ƶ��Ͷ���ҵ��
  {$ENDIF}

  FListA.Clear;
  //���ڴ洢SQL�б�

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckIn then //����
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
      //��װ������
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
      //���¶��г�������״̬
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFP then //����Ƥ��
  begin
    {$IFDEF VerifyInTimeWhenP}
    if not VerifyTruckTimeWhenP(nBills[0].FTruck, nData) then Exit;
    //��֤��������ʱ���Ƿ�ʱ,�����ˢ����
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
      nData := '��λ[ %s ]�ύ��Ƥ������Ϊ0.';
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
      //�ֳ�������ֱ�ӹ���

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
      //���ذ񵥺�,�������հ�

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
              SF('P_Direction', '����'),
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
      //���³����ʱ��

      nSQL := Format('T_HKBills Like ''%%%s%%''', [FID]);
      nSQL := MakeSQLByStr([SF('T_PDate', sField_SQLServer_Now,sfVal)],
              sTable_ZTTrucks, nSQL, False);
      FListA.Add(nSQL);
      //���¶����еĹ�Ƥʱ��        
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckZT then //ջ̨�ֳ�
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
          nData := '�����[ %s ]�ѳ���';
          nData := Format(nData, [FID]);
          Exit;
        end;
      end;

      FStatus := sFlag_TruckZT;
      if nInt >= 0 then //�ѳ�Ƥ
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
      //���¶��г������״̬
    end;
  end else

  if FIn.FExtParam = sFlag_TruckFH then //�Ż��ֳ�
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
          nData := '�����[ %s ]�ѳ���';
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
      //ǿ�Ƽ�ˮ

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
      //���¶��г������״̬
    end;
  end else

  if FIn.FExtParam = sFlag_TruckWT then //�����ֳ�
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
  if FIn.FExtParam = sFlag_TruckBFM then //����ë��
  begin
    SortBillItemsByValue(nBills);
    //��С��������

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
      nData := '��λ[ %s ]�ύ��ë������Ϊ0.';
      nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
      Exit;
    end;

    nNet := nMVal - nBills[nInt].FPData.FValue;
    //��������

    //���۹̶������ڶ��ι���ʱ���Զ�ѡ����ö���
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
      //��Ʊ��

      nVal := nVal - nNet;
      //������

      if nVal>0 then
      for nIdx:=High(nBills) downto Low(nBills) do
      with nBills[nIdx] do
      begin
        if FValue > nVal then
             nDec := nVal
        else nDec := FValue;

        if nDec <= 0 then Continue;
        //�Ѵ�����
        nVal := nVal - nDec;

        nSQL := 'Update %s Set B_Freeze=B_Freeze-%.2f Where B_ID=''%s''';
        nSQL := Format(nSQL, [sTable_Order, nDec, FZhiKa]);
        FListA.Add(nSQL);

        {$IFDEF AutoGetLineGroup}
        nSQL := 'Update %s Set B_HasUse=B_HasUse-(%.2f),B_LastDate=%s ' +
                'Where B_Batcode=''%s'' and B_Type=''%s'' and B_LineGroup=''%s''';
        nSQL := Format(nSQL, [sTable_Batcode, nDec,
                sField_SQLServer_Now, FSeal, sFlag_TypeCommon, FLineGroup]);
        FListA.Add(nSQL); //�������κ�ʹ����
        {$ELSE}
        nSQL := 'Update %s Set B_HasUse=B_HasUse-(%.2f),B_LastDate=%s ' +
                'Where B_Batcode=''%s'' ';
        nSQL := Format(nSQL, [sTable_Batcode, nDec,
                sField_SQLServer_Now, FSeal]);
        FListA.Add(nSQL); //�������κ�ʹ����
        {$ENDIF}

        nSQL := 'Update %s Set D_Sent=D_Sent-(%.2f) Where D_ID=''%s''';
        nSQL := Format(nSQL, [sTable_BatcodeDoc, nDec, FSeal]);
        FListA.Add(nSQL); //�������κ�ʹ����
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
        //�ۼƾ���

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
        //�ۼ����ۼƵľ���

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
    if nBills[nInt].FPModel <> sFlag_PoundCC then //����ģʽ,ë�ز���Ч
    begin  
      nSQL := 'Select L_ID From %s Where L_Card=''%s'' And L_MValue Is Null';
      nSQL := Format(nSQL, [sTable_Bill, nBills[nInt].FCard]);
      //δ��ë�ؼ�¼

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
      //����ģʽ,������״̬

      i := FListB.IndexOf(FID);
      if i >= 0 then
        FListB.Delete(i);
      //�ų����γ���

      if FloatRelation(FMData.FValue, FPData.FValue, rtLE, cPrecision) then
        FMData.FValue := FPData.FValue;
      //ë�ز���С��Ƥ��

      if FType = sFlag_San then
           nVal:=FMData.FValue-FPData.FValue
      else nVal:=FValue;

      nTotal := nTotal + nVal;
      //��������

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
      //���³����ʱ��
    end;

    if FListB.Count > 0 then
    begin
      nTmp := AdjustListStrFormat2(FListB, '''', True, ',', False);
      //δ���ؽ������б�

      nStr := Format('L_ID In (%s)', [nTmp]);
      nSQL := MakeSQLByStr([
              SF('L_PValue', nMVal, sfVal),
              SF('L_PDate', sField_SQLServer_Now, sfVal),
              SF('L_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, nStr, False);
      FListA.Add(nSQL);
      //û�г�ë�ص������¼��Ƥ��,���ڱ��ε�ë��

      nStr := Format('P_Bill In (%s)', [nTmp]);
      nSQL := MakeSQLByStr([
              SF('P_PValue', nMVal, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_PStation', nBills[nInt].FMData.FStation)
              ], sTable_PoundLog, nStr, False);
      FListA.Add(nSQL);
      //û�г�ë�صĹ�����¼��Ƥ��,���ڱ��ε�ë��
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      if FYSValid <> sFlag_Yes then Continue;
      //�ǿճ�����ģʽ

      nSQL := MakeSQLByStr([SF('L_Value', 0, sfVal)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL);
    end;

    nSQL := 'Select P_ID From %s Where P_Bill=''%s'' And P_MValue Is Null';
    nSQL := Format(nSQL, [sTable_PoundLog, nBills[nInt].FID]);
    //δ��ë�ؼ�¼

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      FOut.FData := Fields[0].AsString;
    end;
    //���ذ񵥺�,�������հ�
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckOut then
  begin
    FListB.Clear;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FListB.Add(FID);
      //�������б�

      nSQL := MakeSQLByStr([SF('L_Status', sFlag_TruckOut),
              SF('L_NextStatus', ''),
              SF('L_Card', ''),
              SF('L_OutFact', sField_SQLServer_Now, sfVal),
              SF('L_OutMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL); //���½�����

      if not nDaiQuickSync then
      begin
        nSQL := 'Update %s Set B_HasDone=B_HasDone+(%.2f),' +
                'B_Freeze=B_Freeze-(%.2f) Where B_ID=''%s''';
        nSQL := Format(nSQL, [sTable_Order, FValue, FValue, FZhiKa]);
        FListA.Add(nSQL);
      end; //���¶���

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
        FListA.Add(nSQL); //�Զ����ɻ��鵥
      end;
    end;

    {$IFNDEF SyncDataByBFM}
    {$IFNDEF DaiSyncByZT}
    {$IFNDEF SyncSanByBFM}
    if not nDaiQuickSync then
     if not TWorkerBusinessCommander.CallMe(cBC_SyncME25,
          FListB.Text, '', @nOut) then
      raise Exception.Create(nOut.FData);
    //ͬ�����۵�NC��
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
    //������ʱ��,���´ſ�״̬

    nStr := AdjustListStrFormat2(FListB, '''', True, ',', False);
    //�������б�

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
      //�Ͽ�,��������

      if nInt < 0 then Continue;
      //����װ����Ϣ

      with FBillLines[nInt] do
      begin
        if FPerW < 1 then Continue;
        //������Ч

        i := Trunc(FValue * 1000 / FPerW);
        //����

        nSQL := MakeSQLByStr([SF('L_LadeLine', FLine),
                SF('L_LineName', FName),
                {$IFDEF LineGroup}
                SF('L_LineGroup', FLineGroup),
                {$ENDIF}
                SF('L_DaiTotal', i, sfVal),
                SF('L_DaiNormal', i, sfVal),
                SF('L_DaiBuCha', 0, sfVal)
                ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL); //����װ����Ϣ

        FTotal := FTotal - i;
        FNormal := FNormal - i;
        //�ۼ��Ͽ�������װ����
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
      //�Ͽ�����

      if nInt < 0 then Continue;
      //����װ����Ϣ

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
        FListA.Add(nSQL); //����װ����Ϣ
      end;
    end;

    nSQL := 'Delete From %s Where T_Bill In (%s)';
    nSQL := Format(nSQL, [sTable_ZTTrucks, nStr]);
    FListA.Add(nSQL); //����װ������

    FListC.Clear;
    FListC.Values['DLEncode'] := sFlag_No;
    FListC.Values['DLID']  := nStr;
    FListC.Values['MType'] := sFlag_Sale;
    FListC.Values['BillType'] := IntToStr(cMsg_WebChat_BillFinished);
    TWorkerBusinessCommander.CallMe(cBC_WebChat_DLSaveShopInfo,
     PackerEncodeStr(FListC.Text), '', @nOut);
    //����ͬ����Ϣ
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
    //���ι����Զ�����
  end;

  {$IFDEF SyncDataByBFM}
  if FIn.FExtParam = sFlag_TruckBFM then
  begin
    FListB.Clear;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FListB.Add(FID);
      //�������б�
    end;

    if not nDaiQuickSync then
      TWorkerBusinessCommander.CallMe(cBC_SyncME25,
          FListB.Text, '', @nOut);
    //ͬ�����۵�NC��
  end;
  {$ENDIF}

  {$IFDEF DaiSyncByZT}//��DayQuickSync����
  if FIn.FExtParam = sFlag_TruckZT then
  begin
    FListB.Clear;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FListB.Add(FID);
      //�������б�
    end;

    if not nDaiQuickSync then
      TWorkerBusinessCommander.CallMe(cBC_SyncME25,
          FListB.Text, '', @nOut);
    //ͬ�����۵�NC��
  end;
  {$ENDIF}

  {$IFDEF SyncSanByBFM}//��SyncDataByBFM����
  if FIn.FExtParam = sFlag_TruckBFM then
  begin
    FListB.Clear;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FListB.Add(FID);
      //�������б�
    end;

    if nBills[0].FType = sFlag_San then
      TWorkerBusinessCommander.CallMe(cBC_SyncME25,
          FListB.Text, '', @nOut);
    //ͬ�����۵�NC��
  end;
  {$ENDIF}

  {$IFDEF SyncSanByOut}//��SyncDataByBFM����
  if FIn.FExtParam = sFlag_TruckOut then
  begin
    FListB.Clear;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FListB.Add(FID);
      //�������б�
    end;

    if nBills[0].FType = sFlag_San then
      TWorkerBusinessCommander.CallMe(cBC_SyncME25,
          FListB.Text, '', @nOut);
    //ͬ�����۵�NC��
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
    nData := '��ȡ��NC�����������ʧ�ܣ�����Ϊ[ %s ]';
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
        nData := '���������������Ķ���: ' + #13#10#13#10 +
                 '������Ϣ:[ %s.%s ]' + #13#10 +
                 '�ͻ���Ϣ:[ %s.%s ]' + #13#10#13#10 +
                 '����NC�в�����.';
        nData := Format(nData, [nBill.FStockNo, nBill.FStockName,
                 nBill.FCusID, nBill.FCusName]);
        Exit;
      end;

      if not LoadStockInfo(nData) then Exit;
      //��������

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
            nData := 'Ʒ��[ %s ]���ֵ��е���Ϣ��ʧ.';
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
    nData := Format('��ȡ[ %s ]����������ʧ��', [nSQL]);
    Exit;
  end;

  FListC.Text := PackerDecodeStr(nOut.FData);
  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  begin
    nSQL := FListC.Values[FOrderItems[nIdx].FOrder];
    if not IsNumber(nSQL, True) then Continue;

    with FOrderItems[nIdx] do
      FMaxValue := FMaxValue - StrToFloat(nSQL);
    //������ = �ƻ��� - �ѷ���
  end;

  SortOrderByValue(FOrderItems);
  //����������С��������

  //----------------------------------------------------------------------------
  if nBill.FType = sFlag_Dai then
       nVal := nBill.FValue
  else nVal := nBill.FMData.FValue - nBill.FPData.FValue;

  if nVal <= 0 then
  begin
    nData := '������[ %s ]�ύ�����ݳ���.';
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
    nData := '��ȡ��NC�������ʧ�ܣ�������ϢΪ[ %s ]';
    nData := Format(nData, [nOut.FData]);
    Exit;
  end;

  nSQL := 'Update %s Set B_HasUse=B_HasUse+(%s),B_LastDate=%s ' +
          'Where B_Stock=''%s'' and B_Batcode=''%s''';
  nSQL := Format(nSQL, [sTable_Batcode, FloatToStr(nVal),
          sField_SQLServer_Now, nBill.FStockNo, nOut.FData]);
  FListA.Add(nSQL);//�������κ�ʹ����

  nSQL := MakeSQLByStr([
            SF('L_Seal', nOut.FData)
            ], sTable_Bill, SF('L_ID', nBill.FID), False);
    FListA.Add(nSQL);
  {$ENDIF}

  nInt := -1;
  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  begin
    nDec := Float2Float(FOrderItems[nIdx].FMaxValue, cPrecision, False);
    //����������

    if nDec >= nVal then
    begin
      FOrderItems[nIdx].FKDValue := nVal;
      nInt := nIdx;
      Break;
    end;
    //����������ֱ�ӿ۳�������
  end;

  if nInt < 0 then
  begin
    nData := '��ǰ�޿��ö����������¿���.';
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
    WriteLog('�����̶������������SQL:' + nSQL);
    
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
  WriteLog('���۹̶�����ѯ�������:' + FListC.Text);
  if not TWorkerBusinessCommander.CallMe(cBC_GetSQLQueryOrder, '103',
         PackerEncodeStr(FListC.Text), @nOut) then
  begin
    nData := '��ȡ��NC���۶������ʧ�ܣ�����Ϊ[ %s ]';
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
        nData := '�������������������۶���: ' + #13#10#13#10 +
                 '������Ϣ:[ %s.%s ]' + #13#10 +
                 '�ͻ���Ϣ:[ %s.%s ]' + #13#10#13#10 +
                 '����NC�в�����.';
        nData := Format(nData, [nBill.FStockNo, nBill.FStockName,
                 nBill.FCusID, nBill.FCusName]);
        Exit;
      end;

      if not LoadStockInfo(nData) then Exit;
      //��������

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
            nData := 'Ʒ��[ %s ]���ֵ��е���Ϣ��ʧ.';
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
    nData := Format('��ȡ[ %s ]����������ʧ��', [nSQL]);
    Exit;
  end;

  FListC.Text := PackerDecodeStr(nOut.FData);
  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  begin
    nSQL := FListC.Values[FOrderItems[nIdx].FOrder];
    if not IsNumber(nSQL, True) then Continue;

    with FOrderItems[nIdx] do
      FMaxValue := FMaxValue - StrToFloat(nSQL);
    //������ = �ƻ��� - �ѷ���
  end;

  SortOrderByValue(FOrderItems);
  //����������С��������

  //----------------------------------------------------------------------------
  if nBill.FType = sFlag_Dai then
       nVal := nBill.FValue
  else nVal := nBill.FMData.FValue - nBill.FPData.FValue;

  if nVal <= 0 then
  begin
    nData := '�����[ %s ]�ύ�����ݳ���.';
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
    nData := '��ȡ��NC�������ʧ�ܣ�������ϢΪ[ %s ]';
    nData := Format(nData, [nOut.FData]);
    Exit;
  end;

  nSQL := 'Update %s Set B_HasUse=B_HasUse+(%s),B_LastDate=%s ' +
          'Where B_Stock=''%s'' and B_Batcode=''%s''';
  nSQL := Format(nSQL, [sTable_Batcode, FloatToStr(nVal),
          sField_SQLServer_Now, nBill.FStockNo, nOut.FData]);
  FListA.Add(nSQL);//�������κ�ʹ����

  nSQL := MakeSQLByStr([
            SF('L_Seal', nOut.FData)
            ], sTable_Bill, SF('L_ID', nBill.FID), False);
    FListA.Add(nSQL);
  {$ENDIF}

  nInt := -1;
  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  begin
    nDec := Float2Float(FOrderItems[nIdx].FMaxValue, cPrecision, False);
    //����������

    if nDec >= nVal then
    begin
      FOrderItems[nIdx].FKDValue := nVal;
      nInt := nIdx;
      Break;
    end;
    //����������ֱ�ӿ۳�������
  end;

  if nInt < 0 then
  begin
    nData := '��ǰ�޿��ö����������¿���.';
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
    WriteLog('���۶����̶������������SQL:' + nSQL);
    
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
    nData := 'Ʒ��[ %s ]���ֵ��е���Ϣ��ʧ.';
    nData := Format(nData, [FListA.Values['StockName']]);
    Exit;
  end else

  begin
    FListA.Values['Type'] := FStockInfo[nIdx].FType;
    if FListA.Values['Pack'] = '' then
      FListA.Values['Pack'] := FStockInfo[nIdx].FPackStyle;
  end;

  TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, nTruck, '', @nOut);
  //���泵�ƺ�

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

            SF('B_CusID', FListA.Values['CusID']),       //NC�ͻ�ID
            SF('B_CusName', FListA.Values['CusName']),   //NC�ͻ�����
            SF('B_CusPY', GetPinYinOfStr(FListA.Values['CusName'])),

            SF('B_SaleID', FListA.Values['SaleID']),     //NCҵ��ԱID
            SF('B_SaleMan', FListA.Values['SaleName']), //NCҵ��Ա����
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
            //Ĭ��50��

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
//Desc: ɾ���ɹ��볧���뵥
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
      nData := '����[ %s ]��ʹ�ã���ֹɾ��.';
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
      //�����ֶ�,������ɾ��

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
      nData := '���۵���[ %s ]�Ѷ�ʧ.';
      nData := Format(nData, [FIn.FData]);
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
  nSQL := Format(nSQL, [sTable_ProvBase, FIn.FExtParam]);
  FListC.Add(nSQL);
  //ע������ʹ�øÿ���ԭ����

  nSQL := 'Update %s Set B_Card=NULL, B_CardSerial=NULL Where B_Card=''%s''';
  nSQL := Format(nSQL, [sTable_BillNew, FIn.FExtParam]);
  FListC.Add(nSQL);
  //ע������ʹ�øÿ������۶���

  nSQL := 'Update %s Set L_Card=NULL Where L_Card=''%s''';
  nSQL := Format(nSQL, [sTable_Bill, FIn.FExtParam]);
  FListC.Add(nSQL);
  //ע������ʹ�øÿ��Ľ�����

  nSQL := MakeSQLByStr([
          SF('B_Card', FIn.FExtParam)
          ], sTable_BillNew, SF('B_ID', FIn.FData), False);
  FListC.Add(nSQL);
  //���´ſ�

  nSQL := 'Update %s Set L_Card=''%s'' Where L_Memo =''%s'' And L_OutFact Is NULL';
  nSQL := Format(nSQL, [sTable_Bill,
          FIn.FExtParam, FIn.FData]);
  FListC.Add(nSQL);
  //����δ������ϸ�ſ�

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
      nData := '���۶���[ %s ]��Ϣ�Ѷ�ʧ.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    if FieldByName('B_IsUsed').AsString = sFlag_Yes then
    begin
      nData := '���۶���[ %s ]��Ϣ���ڱ�[ %s ]ʹ��.';
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
  //ɢװ�����൥
  
  nStr := 'Select M_ID,M_Group From %s Where M_Status=''%s'' ';
  nStr := Format(nStr, [sTable_StockMatch, sFlag_Yes]);
  //Ʒ�ַ���ƥ��

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
  //���ڶ����г���

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
        nStr := '����[ %s ]��δ���[ %s ]������֮ǰ��ֹ����.';
        nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
        Exit;
      end else

      if (FieldByName('T_Type').AsString = sFlag_Dai) and
         (FieldByName('T_InFact').AsString <> '') then
      begin
        nStr := '����[ %s ]��δ���[ %s ]������֮ǰ��ֹ����.';
        nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
        Exit;
      end else

      if FieldByName('T_Valid').AsString = sFlag_No then
      begin
        nStr := '����[ %s ]���ѳ��ӵĽ�����[ %s ],���ȴ���.';
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

    //�������۶���״̬

    nStr := FListA.Values['StockNO'];
    nStr := GetMatchRecord(nStr);
    //��Ʒ����װ�������еļ�¼��

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
      //�����¼��

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

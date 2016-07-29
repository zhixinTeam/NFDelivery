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
  UFormCtrl, USysLoger, USysDB, {$IFDEF MicroMsg}UMgrRemoteWXMsg,{$ENDIF}
  UMITConst, UBase64;

type
  TStockInfoItem = record
    FID: string;            //���
    FName: string;          //����
    FType: string;          //����
  end;

  TStockMatchItem = record
    FStock: string;         //Ʒ��
    FGroup: string;         //����
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
  end;

  TOrderItem = record
    FOrder: string;         //������
    FCusID: string;         //�ͻ���
    FCusName: string;       //�ͻ���
    FCusCode: string;       //�ͻ�����
    FAreaTo: string;        //��������
    FStockID: string;       //Ʒ�ֺ�
    FStockName: string;     //Ʒ����
    FStockType: string;     //����
    FSaleID: string;        //ҵ���
    FSaleName: string;      //ҵ����
    FMaxValue: Double;      //������
    FKDValue: Double;       //������
  end;

  TOrderItems = array of TOrderItem;
  //�����б�

  TWorkerBusinessBills = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
    //io
    FSanMultiBill: Boolean;
    //ɢװ�൥
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
    function GetStockGroup(const nStock: string): string;
    function GetMatchRecord(const nStock: string): string;
    //���Ϸ���
    function GetInBillInterval: Integer;
    function AllowedSanMultiBill: Boolean;
    function VerifyBeforSave(var nData: string): Boolean;
    function SaveBills(var nData: string): Boolean;
    //���潻����
    function DeleteBill(var nData: string): Boolean;
    //ɾ��������
    function ChangeBillTruck(var nData: string): Boolean;
    //�޸ĳ��ƺ�
    function SaveBillCard(var nData: string): Boolean;
    //�󶨴ſ�
    function LogoffCard(var nData: string): Boolean;
    //ע���ſ�
    function GetPostBillItems(var nData: string): Boolean;
    //��ȡ��λ������
    function SavePostBillItems(var nData: string): Boolean;
    //�����λ������

    function LinkToNCSystem(var nData: string; nBill: TLadingBillItem): Boolean;
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
      nData := '��Ч��ҵ�����(Invalid Command).';
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2014/7/30
//Parm: Ʒ�ֱ��
//Desc: ����nStock��Ӧ�����Ϸ���
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
//Parm: Ʒ�ֱ��
//Desc: ����������������nStockͬƷ��,��ͬ��ļ�¼
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

//Date: 2015-01-09
//Desc: ������������ָ��ʱ���ڱ��뿪��,������Ч
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
//Desc: ����������Ϣ
function TWorkerBusinessBills.LoadStockInfo(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
begin
  Result := Length(FStockInfo) > 0;
  if Result then Exit;

  nStr := 'Select D_Value,D_Memo,D_ParamB From %s Where D_Name=''%s'' ';
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

//Date: 2014-09-15
//Desc: ��֤�ܷ񿪵�
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
        FGroup := GetStockGroup(FStock);
        FRecord := FieldByName('R_ID').AsString;
      end;

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
      //�޿�����

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
        //��ȡ�µ�����

        FListA.Values['Seal'] := nOut.FData;
        FListC.Values['Batch'] := nOut.FData;
        if not TWorkerBusinessCommander.CallMe(cBC_SaveStockBatcode,
            FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      end;
      //����Ǵ�װ�������������Ϣ 
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
          //�����¼��

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

      if FListA.Values['BuDan'] = sFlag_Yes then //����
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
      gDBConnManager.WorkerExec(FDBConn, nSQL); //�������κ�ʹ����
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
    if nHasOut then
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

    {$IFDEF BatchVerifyValue}
    nStr := 'Update %s Set B_HasUse=B_HasUse-(%.2f),B_LastDate=%s ' +
            'Where B_Stock=''%s'' and B_Batcode=''%s''';
    nStr := Format(nStr, [sTable_Batcode, nVal,
            sField_SQLServer_Now, nSN, nHY]);
    gDBConnManager.WorkerExec(FDBConn, nStr); //�������κ�ʹ����
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
    //���ι���

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
//Parm: ������[FIn.FData];��λ[FIn.FExtParam]
//Desc: ����ָ����λ�ύ�Ľ������б�
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
    nData := '��λ[ %s ]�ύ�ĵ���Ϊ��.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;
{
  if (nBills[0].FType = sFlag_San) and (nInt > 1) then
  begin
    nData := '��λ[ %s ]�ύ��ɢװ�ϵ�,��ҵ��ϵͳ��ʱ��֧��.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;
}  
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
      FStatus := sFlag_TruckZT;
      if nInt >= 0 then //�ѳ�Ƥ
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
      //���¶��г������״̬
    end;
  end else

  if FIn.FExtParam = sFlag_TruckFH then //�Ż��ֳ�
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
      //���¶��г������״̬
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFM then //����ë��
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
      nData := '��λ[ %s ]�ύ��ë������Ϊ0.';
      nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
      Exit;
    end;

    //���۹涨�����ڶ��ι���ʱ���Զ�ѡ����ö���
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
      //NC����������

      nNet := nMVal - nBills[nInt].FPData.FValue;

      nVal := 0;
      for nIdx:=Low(nBills) to High(nBills) do
        nVal := nBills[nIdx].FValue + nVal;
      //��Ʊ��

      nVal := nVal - nNet;
      //������

      if nVal>0 then
      for nIdx:=Low(nBills) to High(nBills) do
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

        {$IFDEF BatchVerifyValue}
        nSQL := 'Update %s Set B_HasUse=B_HasUse-(%.2f),B_LastDate=%s ' +
                'Where B_Stock=''%s'' and B_Batcode=''%s''';
        nSQL := Format(nSQL, [sTable_Batcode, nDec,
                sField_SQLServer_Now, FStockNo, FSeal]);
        FListA.Add(nSQL); //�������κ�ʹ����
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

      nSQL := 'Update %s Set B_HasDone=B_HasDone+(%.2f),' +
              'B_Freeze=B_Freeze-(%.2f) Where B_ID=''%s''';
      nSQL := Format(nSQL, [sTable_Order, FValue, FValue, FZhiKa]);
      FListA.Add(nSQL); //���¶���
    end;

    if not TWorkerBusinessCommander.CallMe(cBC_SyncME25,
          FListB.Text, '', @nOut) then
      raise Exception.Create(nOut.FData);
    //ͬ�����۵�NC��

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
        //����ģʽ,������״̬

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
    //���ι����Զ�����
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
    nData := '��ȡ��NC�������ʧ�ܣ�����Ϊ[ %s ]';
    nData := Format(nData, [FListC.Text]);
    Exit;
  end;

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nOut.FData, nWorker, sFlag_DB_NC) do
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
  if not TWorkerBusinessCommander.CallMe(cBC_GetStockBatcode,
      nBill.FStockNo, FloatToStr(nVal), @nOut) then
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
      nData := '������Ϣ[ %s.%s ]������!';
      nData := Format(nData, [FListA.Values['StockNO'], FListA.Values['StockName']]);
      Exit;
    end;

    nType := Fields[0].AsString;
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

            SF('B_Type', nType),
            SF('B_StockNo', FListA.Values['StockNo']),
            SF('B_StockName', FListA.Values['StockName']),

            SF('B_IsVip', FListA.Values['IsVip']),
            SF('B_Lading', FListA.Values['Lading']),
            SF('B_PackStyle', FListA.Values['IsVip']),

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

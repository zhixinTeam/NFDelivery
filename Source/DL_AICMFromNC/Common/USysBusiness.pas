{*******************************************************************************
  ����: dmzn@163.com 2010-3-8
  ����: ϵͳҵ����
*******************************************************************************}
unit USysBusiness;

{$I Link.Inc} 
interface

uses
  Windows, DB, Classes, Controls, SysUtils, UBusinessPacker, UBusinessWorker,
  UBusinessConst, ULibFun, UAdjustForm, UFormCtrl, UDataModule, USelfHelpConst,
  USysDB, USysLoger, UBase64, UFormWait, Graphics, ShellAPI, UDataReport, DateUtils,
  HTTPApp;

type
  TLadingStockItem = record
    FID: string;         //���
    FType: string;       //����
    FName: string;       //����
    FParam: string;      //��չ
  end;

  TDynamicStockItemArray = array of TLadingStockItem;
  //ϵͳ���õ�Ʒ���б�

  PZTLineItem = ^TZTLineItem;
  TZTLineItem = record
    FID       : string;      //���
    FName     : string;      //����
    FStock    : string;      //Ʒ��
    FIsVip    : string;      //����
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

//------------------------------------------------------------------------------
function AdjustHintToRead(const nHint: string): string;
//������ʾ����
function ShopOrderHasUsed(nID: string): Boolean;
//�����Ƿ���ʹ��
procedure SaveShopOrderIn(nWebID, nID: string);
//������ʹ�õ��̳Ƕ���
function GetCardUsed(const nCard: string): string;
//��Ƭ����

function GetSysValidDate: Integer;
//��ȡϵͳ��Ч��
function GetSerialNo(const nGroup,nObject: string;
 nUseDate: Boolean = True): string;
//��ȡ���б��
function GetLadingStockItems(var nItems: TDynamicStockItemArray): Boolean;
//����Ʒ���б�
function GetQueryOrderSQL(const nType,nWhere: string): string;
//������ѯSQL���
function GetQueryDispatchSQL(const nWhere: string): string;
//��������SQL���
function GetQueryCustomerSQL(const nCusID,nCusName: string): string;
//�ͻ���ѯSQL���

function BuildOrderInfo(const nItem: TOrderInfoItem): string;
procedure AnalyzeOrderInfo(const nOrder: string; var nItem: TOrderInfoItem);
function GetOrderFHValue(const nOrders: TStrings;
  const nQueryFreeze: Boolean=True): Boolean;
//��ȡ����������
function GetOrderGYValue(const nOrders: TStrings): Boolean;
//��ȡ�����ѹ�Ӧ��

function SaveBill(const nBillData: string): string;
//���潻����
function SaveBillCard(const nBill, nCard: string): Boolean;
//���潻�����ſ�
function LogoutBillCard(const nCard: string): Boolean;
//ע��ָ���ſ�


function SaveCardProvie(const nCardData: string): string;
//����ɹ���
function SaveCardOther(const nCardData: string): string;
//������ʱ��

function GetShopOrderInfoByNo(nNO: string): string;
//���ݶ����Ż�ȡ�̳Ƕ�����Ϣ
function GetShopOrderInfoByID(nID: string): string;
//����˾�����֤�Ż�ȡ�̳Ƕ�����Ϣ

function GetNcOrderList(): string;
//��ȡNC �ɹ����б�
function GetNcSaleList(nSTDID, nPassword: string): string;

function IsOrderCanLade(nOrderID: string): Boolean;
//��ѯ�˶����Ƿ���Կ���
function GetStockPackStyle(const nStockID: string): string;
function SaveWebOrderMatch(const nBillID,
  nWebOrderID,nBillType: string):Boolean;

function PrintShipProReport(nRID: string; const nAsk: Boolean): Boolean;
//��ӡ�����ɹ���
function PrintBillReport(nBill: string; const nAsk: Boolean): Boolean;
//��ӡ�����
function PrintHuaYanReport(const nBill: string; var nHint: string;
 const nPrinter: string = ''): Boolean;
//��ӡ��ʶΪnHID�Ļ��鵥
function PrintHuaYanReportEx(const nBill, nSeal: string; var nHint: string;
 const nPrinter: string = ''): Boolean;
//��ӡ��ʶΪnHID�Ļ��鵥Ex
function PrintHuaYanReportWhenSaveBill(const nBill: string; var nHint: string;
 const nPrinter: string = ''): Boolean;
function LoadSysDictItem(const nItem: string; const nList: TStrings): TDataSet;
//��ȡϵͳ�ֵ���
function IfHasLine(const nStockNo, nType, nBrand: string; var nHint: string): Boolean;
//����Ƿ��п���ͨ��
function IsTruckGPSValid(const nTruckNo: string): Boolean;
function IsCardValid(const nCard: string): Boolean;
function IsPurTruckReady(const nTruck: string; var nHint: string): Boolean;
function IFHasBill(const nTruck: string): Boolean;
function GetTransType(const nID: string): string;
function GetTruckSanMaxLadeValue(const nTruck: string; var nForce: Boolean): Double;
function GetAICMPurMinValue: Double;
function GetStockPackStyleEx(const nStockID,nBrand: string): string;
function GetPDModelFromDB: string;
function GetGPSUrl(const nTruck: string; var nHint: string): string;
function GetBillCard(const nLID: string): string;
function HasDriverCard(const nTruck: string; var nCard: string): Boolean;
implementation

//Desc: ��¼��־
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(nEvent);
end;

//------------------------------------------------------------------------------
//Desc: ����nHintΪ�׶��ĸ�ʽ
function AdjustHintToRead(const nHint: string): string;
var nIdx: Integer;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    nList.Text := nHint;
    for nIdx:=0 to nList.Count - 1 do
      nList[nIdx] := '��.' + nList[nIdx];
    Result := nList.Text;
  finally
    nList.Free;
  end;
end;

function ShopOrderHasUsed(nID: string): Boolean;
var nSQL: string;
begin
  Result := False;
  nSQL := 'Select W_DLID From %s Where W_WebID=''%s'' Order By R_ID Desc';
  nSQL := Format(nSQL, [sTable_WebOrderInfo, nID]);
  with FDM.SQLQuery(nSQL) do
  if RecordCount > 0 then
  begin
    nSQL := '������[ %s ]�Ѿ���[ %s ]ʹ��,���������';
    nSQL := Format(nSQL, [nID, Fields[0].AsString]);
    ShowMsg(nSQL, sWarn);
    Result := True;
  end;  
end;

procedure SaveShopOrderIn(nWebID, nID: string);
var nSQL: string;
begin
  nSQL := MakeSQLByStr([SF('W_WebID', nWebID),
          SF('W_DLID', nID),
          SF('W_Date', sField_SQLServer_Now, sfVal),
          SF('W_Man', 'AICM')], sTable_WebOrderInfo, '', True);
  FDM.ExecuteSQL(nSQL);        
end;

//Date: 2014-09-05
//Parm: ����;����;����;���
//Desc: �����м���ϵ�ҵ���������
function CallBusinessCommand(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;
    nIn.FBase.FParam := sParam_NoHintOnError;

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessCommand);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-05
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessSaleBill(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;
    //nIn.FBase.FParam := sParam_NoHintOnError;

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessSaleBill);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-05
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessProvideItems(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;
    nIn.FBase.FParam := sParam_NoHintOnError;

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessProvide);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-05
//Parm: ����;����;����;���
//Desc: �����м���ϵĶ̵����ݶ���
function CallBusinessDuanDao(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;
    nIn.FBase.FParam := sParam_NoHintOnError;

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessDuanDao);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2017/6/2
//Parm: ����;����;����;���
//Desc: ���˲ɹ�ҵ��
function CallBusinessShipProItems(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;
    nIn.FBase.FParam := sParam_NoHintOnError;

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessShipPro);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2017/6/2
//Parm: ����;����;����;���
//Desc: ������ʱҵ��
function CallBusinessShipTmpItems(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;
    nIn.FBase.FParam := sParam_NoHintOnError;

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessShipTmp);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-04
//Parm: ����;����;ʹ�����ڱ���ģʽ
//Desc: ����nGroup.nObject���ɴ��б��
function GetSerialNo(const nGroup,nObject: string; nUseDate: Boolean): string;
var nStr: string;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  Result := '';
  nList := nil;
  try
    nList := TStringList.Create;
    nList.Values['Group'] := nGroup;
    nList.Values['Object'] := nObject;

    if nUseDate then
         nStr := sFlag_Yes
    else nStr := sFlag_No;

    if CallBusinessCommand(cBC_GetSerialNO, nList.Text, nStr, @nOut) then
      Result := nOut.FData;
    //xxxxx
  finally
    nList.Free;
  end;   
end;

//Desc: ��ȡϵͳ��Ч��
function GetSysValidDate: Integer;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_IsSystemExpired, '', '', @nOut) then
       Result := StrToInt(nOut.FData)
  else Result := 0;
end;

//Desc: ��ȡ��Ƭ����
function GetCardUsed(const nCard: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := sFlag_Sale;
  if CallBusinessCommand(cBC_GetCardUsed, nCard, '', @nOut) then
    Result := nOut.FData;
  //xxxxx
end;

//Date: 2014-12-16
//Parm: ��������;��ѯ����
//Desc: ��ȡnType���͵Ķ�����ѯ���
function GetQueryOrderSQL(const nType,nWhere: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_GetSQLQueryOrder, nType, nWhere, @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2014-12-16
//Parm: ��ѯ����
//Desc: ��ȡ����������ѯ���
function GetQueryDispatchSQL(const nWhere: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_GetSQLQueryDispatch, '', nWhere, @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2014-12-18
//Parm: �ͻ����;�ͻ�����
//Desc: ��ȡnCusName��ģ����ѯSQL���
function GetQueryCustomerSQL(const nCusID,nCusName: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_GetSQLQueryCustomer, nCusID, nCusName, @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Desc: ��ȡ��ǰϵͳ���õ�ˮ��Ʒ���б�
function GetLadingStockItems(var nItems: TDynamicStockItemArray): Boolean;
var nStr: string;
    nIdx: Integer;
begin
  nStr := 'Select D_Value,D_Memo,D_ParamB From $Table ' +
          'Where D_Name=''$Name'' Order By D_Index ASC';
  nStr := MacroValue(nStr, [MI('$Table', sTable_SysDict),
                            MI('$Name', sFlag_StockItem)]);
  //xxxxx

  with FDM.SQLQuery(nStr) do
  begin
    SetLength(nItems, RecordCount);
    if RecordCount > 0 then
    begin
      nIdx := 0;
      First;

      while not Eof do
      begin
        nItems[nIdx].FType := FieldByName('D_Memo').AsString;
        nItems[nIdx].FName := FieldByName('D_Value').AsString;
        nItems[nIdx].FID := FieldByName('D_ParamB').AsString;

        Next;
        Inc(nIdx);
      end;
    end;
  end;

  Result := Length(nItems) > 0;
end;

//Date: 2014-12-23
//Parm: ������
//Desc: ��nItem���ݴ��
function BuildOrderInfo(const nItem: TOrderInfoItem): string;
var nList: TStrings;
begin
  nList := TStringList.Create;
  try
    with nList,nItem do
    begin
      Clear;
      Values['CusID']     := FCusID;
      Values['CusName']   := FCusName;
      Values['SaleMan']   := FSaleMan;

      Values['StockID']   := FStockID;
      Values['StockName'] := FStockName;
      Values['StockArea'] := FStockArea;
      Values['StockBrand']:= FStockBrand;

      Values['Truck']     := FTruck;
      Values['BatchCode'] := FBatchCode;
      Values['Orders']    := PackerEncodeStr(FOrders);
      Values['Value']     := FloatToStr(FValue);
    end;

    Result := EncodeBase64(nList.Text);
    //����
  finally
    nList.Free;
  end;   
end;

//Date: 2014-12-23
//Parm: ������;��������
//Desc: ����nOrder,����nItem
procedure AnalyzeOrderInfo(const nOrder: string; var nItem: TOrderInfoItem);
var nList: TStrings;
begin
  nList := TStringList.Create;
  try
    with nList,nItem do
    begin
      Text := DecodeBase64(nOrder);
      //����

      FCusID := Values['CusID'];
      FCusName := Values['CusName'];
      FSaleMan := Values['SaleMan'];

      FStockID := Values['StockID'];
      FStockName := Values['StockName'];
      FStockArea := Values['StockArea'];
      FStockBrand:= Values['StockBrand'];

      FTruck := Values['Truck'];
      FBatchCode := Values['BatchCode'];
      FOrders := PackerDecodeStr(Values['Orders']);
      FValue := StrToFloat(Values['Value']);
    end;
  finally
    nList.Free;
  end;
end;

//Date: 2014-12-24
//Parm: �����б�
//Desc: ��ȡָ���ķ�����
function GetOrderFHValue(const nOrders: TStrings;
  const nQueryFreeze: Boolean=True): Boolean;
var nOut: TWorkerBusinessCommand;
    nFlag: string;
begin
  if nQueryFreeze then
       nFlag := sFlag_Yes
  else nFlag := sFlag_No;

  Result := CallBusinessCommand(cBC_GetOrderFHValue,
             EncodeBase64(nOrders.Text), nFlag, @nOut);
  //xxxxx

  if Result then
    nOrders.Text := DecodeBase64(nOut.FData);
  //xxxxx
end;

//Date: 2015-01-08
//Parm: �����б�
//Desc: ��ȡָ���ķ�����
function GetOrderGYValue(const nOrders: TStrings): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetOrderGYValue,
             EncodeBase64(nOrders.Text), '', @nOut);
  //xxxxx

  if Result then
    nOrders.Text := DecodeBase64(nOut.FData);
  //xxxxx
end;

//Date: 2014-09-15
//Parm: ��������
//Desc: ���潻����,���ؽ��������б�
function SaveBill(const nBillData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessSaleBill(cBC_SaveBills, nBillData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2014-09-17
//Parm: ��������;�ſ�
//Desc: ��nBill.nCard
function SaveBillCard(const nBill, nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_SaveBillCard, nBill, nCard, @nOut);
end;

//Date: 2014-09-17
//Parm: �ſ���
//Desc: ע��nCard
function LogoutBillCard(const nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_LogoffCard, nCard, '', @nOut);
end;

//Date: 2017/6/4
//Parm: ��������
//Desc: �����ɹ�ҵ��
function SaveCardProvie(const nCardData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessShipProItems(cBC_SaveBills, nCardData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2017/6/4
//Parm: ��������
//Desc: ������ʱҵ��
function SaveCardOther(const nCardData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessShipTmpItems(cBC_SaveBills, nCardData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

function GetShopOrderInfoByNo(nNO: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_WebChat_GetShopOrderByNO, nNO, '', @nOut) then
    Result := nOut.FData;
end;

function GetShopOrderInfoByID(nID: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_WebChat_GetShopOrdersByID, nID, '', @nOut) then
    Result := nOut.FData;
end;

function GetNcOrderList(): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_GetPurchaseList, '', '', @nOut) then
    Result := nOut.FData;
end;

function GetNcSaleList(nSTDID, nPassword: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_GetOrderList, nSTDID, nPassword, @nOut) then
    Result := nOut.FData;
end;

//Date: 2018-07-10
//Parm: ���۶�����
//Desc: ��ѯ�˶����Ƿ���Կ���
function IsOrderCanLade(nOrderID: string): Boolean;
var nStr: string;
begin
  Result := True;
  nStr := 'Select L_ID From %s Where L_ZhiKa in (''%s'')';
  nStr := Format(nStr, [sTable_Bill, nOrderID]);

//  nStr := nStr + ' And (L_OutFact is null or L_Status <> ''%s'') ';
//  nStr := Format(nStr, [sTable_Bill, nOrderID, sFlag_TruckOut]);

  with FDM.SQLQuery(nStr) do
  begin
    if RecordCount >0 then
    begin
      WriteLog('���۶�����֤Sql:'+ nStr);
      Result := False;
    end;
  end;
end;

function GetStockPackStyle(const nStockID: string): string;
var nStr: string;
begin
  nStr := 'Select D_ParamC From %s Where (D_Name=''StockItem''' +
          ' and D_ParamB=''%s'')';
  nStr := Format(nStr, [sTable_SysDict, Trim(nStockID)]);

  Result := '';
  with FDM.SQLQuery(nStr) do
  if RecordCount > 0 then
     Result := Fields[0].AsString;

  if Result = '' then Result := 'C';
end;

function GetStockPackStyleEx(const nStockID, nBrand: string): string;
var nStr: string;
begin
  nStr := 'Select D_Value From %s Where (D_Name=''%s''' +
          ' and D_Memo=''%s'' and D_ParamB=''%s'')';
  nStr := Format(nStr, [sTable_SysDict, sFlag_BrandBindPack, Trim(nStockID), nBrand]);

  Result := '';
  with FDM.SQLQuery(nStr) do
  if RecordCount > 0 then
     Result := Fields[0].AsString;

  if Result = '' then Result := 'C';
end;

function SaveWebOrderMatch(const nBillID,
  nWebOrderID,nBillType: string):Boolean;
var
  nStr:string;
begin
  Result := False;
  nStr := MakeSQLByStr([
  SF('WOM_WebOrderID'   , nWebOrderID),
  SF('WOM_LID'          , nBillID),
  SF('WOM_StatusType'   , c_WeChatStatusCreateCard),
  SF('WOM_MsgType'      , cSendWeChatMsgType_AddBill),
  SF('WOM_BillType'     , nBillType),
  SF('WOM_deleted'     , sFlag_No)
  ], sTable_WebOrderMatch, '', True);
  fdm.ADOConn.BeginTrans;
  try
    fdm.ExecuteSQL(nStr);
    fdm.ADOConn.CommitTrans;
    Result := True;
  except
    fdm.ADOConn.RollbackTrans;
  end;
end;

//Date: 2018-12-03
//Parm: �ɹ���RID;��ʾ;���ݶ���;��ӡ��
//Desc: ��ӡ�����ɹ���
function PrintShipProReport(nRID: string; const nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '�Ƿ�Ҫ��ӡ�ɹ���?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s Where R_ID=''%s''';
  nStr := Format(nStr, [sTable_CardProvide, nRID]);

  if FDM.SQLQuery(nStr).RecordCount < 1 then
  begin
    nStr := '���Ϊ[ %s ] �ļ�¼����Ч!!';
    nStr := Format(nStr, [nRID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir +'CardProvide.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '�޷���ȷ���ر����ļ�';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := 'AICM';
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := '';
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SQLQuery1;
  FDR.Report1.PrintOptions.Printer := 'My_Default_Printer';
  FDR.PrintReport;
  Result := FDR.PrintSuccess;
end;

//Desc: ��ӡ�����
function PrintBillReport(nBill: string; const nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '�Ƿ�Ҫ��ӡ�����?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s b ' +
          '  Left Join %s p on b.L_ID=p.P_Bill ' +
          'Where L_ID = ''%s'' ';
  nStr := Format(nStr, [sTable_Bill, sTable_PoundLog, nBill]);

  if FDM.SQLQuery(nStr).RecordCount < 1 then
  begin
    nStr := '���Ϊ[ %s ] �ļ�¼����Ч!!';
    nStr := Format(nStr, [nBill]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'LadingBill.fr3';
  //default
  
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '�޷���ȷ���ر����ļ�';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := 'AICM';
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := '';
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SQLQuery1;
  if gSysParam.FCardPrinter = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_HYPrinter'
  else FDR.Report1.PrintOptions.Printer := gSysParam.FCardPrinter;
  FDR.PrintReport;
  Result := FDR.PrintSuccess;
end;

//Desc: ��ȡnStockƷ�ֵı����ļ�
function GetReportFileByStock(const nStock, nBrand: string): string;
begin
  Result := GetPinYinOfStr(nStock);

  {$IFDEF GetReportByBrand}
  if nBrand = '' then
  begin
    if Pos('dj', Result) > 0 then
      Result := gPath + 'Report\HuaYan42_DJ.fr3'
    else if Pos('gsysl', Result) > 0 then
      Result := gPath + 'Report\HuaYan_gsl.fr3'
    else if Pos('kzf', Result) > 0 then
      Result := gPath + 'Report\HuaYan_kzf.fr3'
    else if Pos('qz', Result) > 0 then
      Result := gPath + 'Report\HuaYan_qz.fr3'
    else if Pos('32', Result) > 0 then
      Result := gPath + 'Report\HuaYan32.fr3'
    else if Pos('42', Result) > 0 then
      Result := gPath + 'Report\HuaYan42.fr3'
    else if Pos('52', Result) > 0 then
      Result := gPath + 'Report\HuaYan42.fr3'
    else Result := '';
  end
  else
  begin
    if Pos('dj', Result) > 0 then
      Result := gPath + 'Report\HuaYan42_DJ' + nBrand +'.fr3'
    else if Pos('gsysl', Result) > 0 then
      Result := gPath + 'Report\HuaYan_gsl' + nBrand +'.fr3'
    else if Pos('kzf', Result) > 0 then
      Result := gPath + 'Report\HuaYan_kzf' + nBrand +'.fr3'
    else if Pos('qz', Result) > 0 then
      Result := gPath + 'Report\HuaYan_qz' + nBrand +'.fr3'
    else if Pos('32', Result) > 0 then
      Result := gPath + 'Report\HuaYan32' + nBrand +'.fr3'
    else if Pos('42', Result) > 0 then
      Result := gPath + 'Report\HuaYan42' + nBrand +'.fr3'
    else if Pos('52', Result) > 0 then
      Result := gPath + 'Report\HuaYan42' + nBrand +'.fr3'
    else Result := '';
  end;
  {$ELSE}
  if Pos('dj', Result) > 0 then
    Result := gPath + 'Report\HuaYan42_DJ.fr3'
  else if Pos('gsysl', Result) > 0 then
    Result := gPath + 'Report\HuaYan_gsl.fr3'
  else if Pos('kzf', Result) > 0 then
    Result := gPath + 'Report\HuaYan_kzf.fr3'
  else if Pos('qz', Result) > 0 then
    Result := gPath + 'Report\HuaYan_qz.fr3'
  else if Pos('32', Result) > 0 then
    Result := gPath + 'Report\HuaYan32.fr3'
  else if Pos('42', Result) > 0 then
    Result := gPath + 'Report\HuaYan42.fr3'
  else if Pos('52', Result) > 0 then
    Result := gPath + 'Report\HuaYan42.fr3'
  else Result := '';
  {$ENDIF}
end;

//Desc: ��ȡnStockƷ�ֵı����ļ�(�����ݿ��ȡģ������)
function GetReportFileByStockFromDB(const nStock, nBrand: string): string;
var nStr, nWhere: string;
begin
  Result := '';
  if nBrand <> '' then
  begin
    nWhere := ' and D_ParamB = ''%s'' ';
    nWhere := Format(nWhere, [nBrand]);
  end
  else
    nWhere := '';

  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo = ''%s'' %s order by D_ID desc';
  nStr := Format(nStr, [sTable_SysDict, sFlag_ReportFileMap, nStock, nWhere]);

  with FDM.SQLQuery(nStr) do
  begin
    if RecordCount > 0 then
    begin
      Result := gPath + 'Report\' + Fields[0].AsString;
    end;
  end;
end;

//Desc: ��ӡ��ʶΪnHID�Ļ��鵥
function PrintHuaYanReport(const nBill: string; var nHint: string;
 const nPrinter: string = ''): Boolean;
var nStr,nSR, nSeal,nDate3D,nDate28D,n28Ya1,nBD,nBrand,nStock,nReport: string;
    nDate: TDateTime;
    nPCount: Integer;
begin
  nHint := '';
  Result := False;

  nPCount := 5;
  nStr := 'Select D_Value From %s ' +
          ' Where D_Name = ''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_AICMHYDanPCount]);

  with FDM.SQLQuery(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nPCount := Fields[0].AsInteger;
    end;
  end;

  nSeal := '';
  nBD := '';
  nStr := 'Select sb.L_Seal,sr.R_28Ya1,sb.L_HyPrintCount,sb.L_StockBrand,sb.L_StockName From %s sb ' +
          ' Left Join %s sr on sr.R_SerialNo=sb.L_Seal ' +
          ' Where sb.L_ID = ''%s''';
  nStr := Format(nStr, [sTable_Bill, sTable_StockRecord, nBill]);

  with FDM.SQLQuery(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nSeal := Fields[0].AsString;
      n28Ya1 := Fields[1].AsString;
      nBrand := Fields[3].AsString;
      nStock := Fields[4].AsString;
      if Fields[2].AsInteger > nPCount then
      begin
        nHint :='�����趨��ӡ����,����ϵ����Ա';
        Exit
      end;

      if Fields[2].AsInteger >= 1 then
        nBD := '��';
    end;
  end;

  nReport := GetReportFileByStockFromDB(nStock, nBrand);

  nDate3D := FormatDateTime('YYYY-MM-DD HH:MM:SS', Now);
  nDate28D := nDate3D;
  nStr := 'Select top 1 L_Date From %s Where L_Seal = ''%s'' order by L_Date';
  nStr := Format(nStr, [sTable_Bill, nSeal]);

  with FDM.SQLQuery(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nDate3D := Fields[0].AsString;
      try
        nDate := StrToDateTime(nDate3D);
        if n28Ya1 <> '' then
          nDate := IncDay(nDate,29);
        nDate28D := FormatDateTime('YYYY-MM-DD HH:MM:SS', nDate);
      except
      end;
    end;
  end;
  
  nSR := 'Select * From %s sr ' +
         ' Left Join %s sp on sp.P_ID=sr.R_PID';
  nSR := Format(nSR, [sTable_StockRecord, sTable_StockParam]);

  nStr := 'Select hy.*,sr.*,b.*,C_Name,''$DD'' as R_Date3D ,''$BD'' as L_HyBd,''$TD'' as R_Date28D From $HY hy ' +
          ' Left Join $Bill b On b.L_ID=hy.H_Bill ' +
          ' Left Join $Cus cus on cus.C_ID=hy.H_Custom' +
          ' Left Join ($SR) sr on sr.R_SerialNo=H_SerialNo ' +
          'Where H_Bill=''$ID''';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$DD', nDate3D), MI('$BD', nBD), MI('$TD', nDate28D),
          MI('$HY', sTable_StockHuaYan), MI('$Bill', sTable_Bill),
          MI('$Cus', sTable_Customer), MI('$SR', nSR), MI('$ID', nBill)]);
  //xxxxx
  WriteLog('���鵥��ѯ:'+nStr);
  if FDM.SQLQuery(nStr).RecordCount < 1 then
  begin
    nHint := '�����[ %s ]û�ж�Ӧ�Ļ��鵥';
    nHint := Format(nHint, [nBill]);
    Exit;
  end;

//  nStr := FDM.SQLQuery1.FieldByName('P_Stock').AsString;
//  nStr := GetReportFileByStock(nStr, nBrand);

  if (nReport = '') or (not FDR.LoadReportFile(nReport)) then
  begin
    nHint := '�޷���ȷ���ر����ļ�: ' + nReport;
    Exit;
  end;

  if nPrinter = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_HYPrinter'
  else FDR.Report1.PrintOptions.Printer := nPrinter;

  FDR.Dataset1.DataSet := FDM.SQLQuery1;
  FDR.PrintReport;
  Result := FDR.PrintSuccess;

  if Result then
  begin
    nStr := 'Update %s Set L_HyPrintCount=L_HyPrintCount + 1 ' +
            'Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, nBill]);
    FDM.ExecuteSQL(nStr);
  end;
end;

//Desc: ��ӡ��ʶΪnHID�Ļ��鵥
function PrintHuaYanReportEx(const nBill, nSeal: string; var nHint: string;
 const nPrinter: string = ''): Boolean;
var nStr,nSR,nDate3D,nDate28D,n28Ya1,nBD,nBrand,nStock,nReport: string;
    nDate: TDateTime;
    nPCount: Integer;
begin
  nHint := '';
  Result := False;

  nPCount := 5;
  nStr := 'Select D_Value From %s ' +
          ' Where D_Name = ''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_AICMHYDanPCount]);

  with FDM.SQLQuery(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nPCount := Fields[0].AsInteger;
    end;
  end;

  nBD := '';
  nStr := 'Select sb.L_Seal,sr.R_28Ya1,sb.L_HyPrintCount,sb.L_StockBrand,sb.L_StockName From %s sb ' +
          ' Left Join %s sr on sr.R_SerialNo=''%s'' ' +
          ' Where sb.L_ID = ''%s''';
  nStr := Format(nStr, [sTable_Bill, sTable_StockRecord, nSeal, nBill]);

  with FDM.SQLQuery(nStr) do
  begin
    if RecordCount > 0 then
    begin
      n28Ya1 := Fields[1].AsString;
      nBrand := Fields[3].AsString;
      nStock := Fields[4].AsString;
      if Fields[2].AsInteger > nPCount then
      begin
        nHint :='�����趨��ӡ����,����ϵ����Ա';
        Exit
      end;

      if Fields[2].AsInteger >= 1 then
        nBD := '��';
    end;
  end;
  nReport := GetReportFileByStockFromDB(nStock, nBrand);

  nDate3D := FormatDateTime('YYYY-MM-DD HH:MM:SS', Now);
  nDate28D := nDate3D;
  nStr := 'Select top 1 L_Date From %s Where L_Seal = ''%s'' order by L_Date';
  nStr := Format(nStr, [sTable_Bill, nSeal]);

  with FDM.SQLQuery(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nDate3D := Fields[0].AsString;
      try
        nDate := StrToDateTime(nDate3D);
        if n28Ya1 <> '' then
          nDate := IncDay(nDate,29);
        nDate28D := FormatDateTime('YYYY-MM-DD HH:MM:SS', nDate);
      except
      end;
    end;
  end;
  
  nSR := 'Select * From %s sr ' +
         ' Left Join %s sp on sp.P_ID=sr.R_PID';
  nSR := Format(nSR, [sTable_StockRecord, sTable_StockParam]);

  nStr := 'Select hy.*,sr.*,b.*,C_Name,''$DD'' as R_Date3D ,''$BD'' as L_HyBd,''$TD'' as R_Date28D From $HY hy ' +
          ' Left Join $Bill b On b.L_ID=hy.H_Bill ' +
          ' Left Join $Cus cus on cus.C_ID=hy.H_Custom' +
          ' Left Join ($SR) sr on sr.R_SerialNo=''$SE'' ' +
          'Where H_Bill=''$ID''';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$DD', nDate3D), MI('$BD', nBD), MI('$TD', nDate28D),
          MI('$HY', sTable_StockHuaYan), MI('$Bill', sTable_Bill), MI('$SE', nSeal),
          MI('$Cus', sTable_Customer), MI('$SR', nSR), MI('$ID', nBill)]);
  //xxxxx
  WriteLog('���鵥��ѯ:'+nStr);
  if FDM.SQLQuery(nStr).RecordCount < 1 then
  begin
    nHint := '�����[ %s ]û�ж�Ӧ�Ļ��鵥';
    nHint := Format(nHint, [nBill]);
    Exit;
  end;

//  nStr := FDM.SQLQuery1.FieldByName('P_Stock').AsString;
//  nStr := GetReportFileByStock(nStr, nBrand);

  if (nReport = '') or (not FDR.LoadReportFile(nReport)) then
  begin
    nHint := '�޷���ȷ���ر����ļ�: ' + nReport;
    Exit;
  end;

  if nPrinter = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_HYPrinter'
  else FDR.Report1.PrintOptions.Printer := nPrinter;

  FDR.Dataset1.DataSet := FDM.SQLQuery1;
  FDR.PrintReport;
  Result := FDR.PrintSuccess;

  if Result then
  begin
    nStr := 'Update %s Set L_HyPrintCount=L_HyPrintCount + 1 ' +
            'Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, nBill]);
    FDM.ExecuteSQL(nStr);
  end;
end;

//Desc: ��ӡ��ʶΪnHID�Ļ��鵥
function PrintHuaYanReportWhenSaveBill(const nBill: string; var nHint: string;
 const nPrinter: string = ''): Boolean;
var nStr,nSR, nSeal,nDate3D,nDate28D,n28Ya1,nBD,nBrand,nStock,nReport: string;
    nDate: TDateTime;
    nPCount: Integer;
begin
  nHint := '';
  Result := False;

  nPCount := 5;
  nStr := 'Select D_Value From %s ' +
          ' Where D_Name = ''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_AICMHYDanPCount]);

  with FDM.SQLQuery(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nPCount := Fields[0].AsInteger;
    end;
  end;

  nSeal := '';
  nBD := '';
  nStr := 'Select sb.L_Seal,sr.R_28Ya1,sb.L_HyPrintCount,sb.L_StockBrand,sb.L_StockName From %s sb ' +
          ' Left Join %s sr on sr.R_SerialNo=sb.L_Seal ' +
          ' Where sb.L_ID = ''%s''';
  nStr := Format(nStr, [sTable_Bill, sTable_StockRecord, nBill]);

  with FDM.SQLQuery(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nSeal := Fields[0].AsString;
      n28Ya1 := Fields[1].AsString;
      nBrand := Fields[3].AsString;
      nStock := Fields[4].AsString;
      if Fields[2].AsInteger > nPCount then
      begin
        nHint :='�����趨��ӡ����,����ϵ����Ա';
        Exit
      end;

      if Fields[2].AsInteger >= 1 then
        nBD := '��';
    end;
  end;

  nReport := GetReportFileByStockFromDB(nStock, nBrand);

  nDate3D := FormatDateTime('YYYY-MM-DD HH:MM:SS', Now);
  nDate28D := nDate3D;
  nStr := 'Select top 1 L_Date From %s Where L_Seal = ''%s'' order by L_Date';
  nStr := Format(nStr, [sTable_Bill, nSeal]);

  with FDM.SQLQuery(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nDate3D := Fields[0].AsString;
      try
        nDate := StrToDateTime(nDate3D);
        if n28Ya1 <> '' then
          nDate := IncDay(nDate,29);
        nDate28D := FormatDateTime('YYYY-MM-DD HH:MM:SS', nDate);
      except
      end;
    end;
  end;
  
  nSR := 'Select * From %s sr ' +
         ' Left Join %s sp on sp.P_ID=sr.R_PID';
  nSR := Format(nSR, [sTable_StockRecord, sTable_StockParam]);

  nStr := 'Select sr.*,b.*,''$DD'' as R_Date3D ,''$BD'' as L_HyBd,''$TD'' as R_Date28D From $Bill b ' +
          ' Left Join ($SR) sr on sr.R_SerialNo=L_Seal ' +
          'Where L_ID=''$ID''';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$DD', nDate3D), MI('$BD', nBD), MI('$TD', nDate28D),
          MI('$HY', sTable_StockHuaYan), MI('$Bill', sTable_Bill),
          MI('$Cus', sTable_Customer), MI('$SR', nSR), MI('$ID', nBill)]);
  //xxxxx
  WriteLog('���鵥��ѯ:'+nStr);
  if FDM.SQLQuery(nStr).RecordCount < 1 then
  begin
    nHint := '�����[ %s ]û�ж�Ӧ�Ļ��鵥';
    nHint := Format(nHint, [nBill]);
    Exit;
  end;

//  nStr := FDM.SQLQuery1.FieldByName('P_Stock').AsString;
//  nStr := GetReportFileByStock(nStr, nBrand);

  if (nReport = '') or (not FDR.LoadReportFile(nReport)) then
  begin
    nHint := '�޷���ȷ���ر����ļ�: ' + nReport;
    Exit;
  end;

  if nPrinter = '' then
       FDR.Report1.PrintOptions.Printer := 'My_Default_HYPrinter'
  else FDR.Report1.PrintOptions.Printer := nPrinter;

  FDR.Dataset1.DataSet := FDM.SQLQuery1;
  FDR.PrintReport;
  Result := FDR.PrintSuccess;

  if Result then
  begin
    nStr := 'Update %s Set L_HyPrintCount=L_HyPrintCount + 1 ' +
            'Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, nBill]);
    FDM.ExecuteSQL(nStr);
  end;
end;

//Date: 2010-4-13
//Parm: �ֵ���;�б�
//Desc: ��SysDict�ж�ȡnItem�������,����nList��
function LoadSysDictItem(const nItem: string; const nList: TStrings): TDataSet;
var nStr: string;
begin
  nList.Clear;
  nStr := MacroValue(sQuery_SysDict, [MI('$Table', sTable_SysDict),
                                      MI('$Name', nItem)]);
  Result := FDM.SQLQuery(nStr);

  if Result.RecordCount > 0 then
  with Result do
  begin
    First;

    while not Eof do
    begin
      nList.Add(FieldByName('D_Value').AsString);
      Next;
    end;
  end else Result := nil;
end;

function IfHasLine(const nStockNo, nType, nBrand: string; var nHint: string): Boolean;
var nStr: string;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;

  nList := TStringList.Create;

  try
    nList.Values['Type'] := nType;
    if nBrand = '' then
    begin
      nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
      nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_DefaultBrand]);

      with FDM.SQLQuery(nStr) do
      begin
        if RecordCount >0 then
        begin
          nList.Values['Brand'] := Fields[0].AsString;
        end;
      end;
    end
    else
      nList.Values['Brand'] := nBrand;

    if not CallBusinessCommand(cBC_AutoGetLineGroup,
          nStockNo, PackerEncodeStr(nList.Text), @nOut) then
    begin
      nHint := '��ѯ����ͨ��ʧ��:' + nOut.FData;
      Exit;
    end;
    Result := True;
  finally
    nList.Free;
  end;
end;

function IsTruckGPSValid(const nTruckNo: string): Boolean;
var
  nSql:string;
begin
  Result := False;

  nSql := 'select * from %s where T_Truck = ''%s'' ';
  nSql := Format(nSql,[sTable_Truck,nTruckNo]);

  with FDM.SQLQuery(nSql) do
  begin
    if recordcount>0 then
    begin
      if FieldByName('T_HasGPS').AsString = sFlag_Yes then//����
      begin
        Result := True;
      end;
    end;
  end;
end;

function IsCardValid(const nCard: string): Boolean;
var
  nSql:string;
begin
  Result := False;

  nSql := 'select C_Card2,C_Card3 from %s where C_Card = ''%s'' ';
  nSql := Format(nSql,[sTable_Card,nCard]);

  with FDM.SQLQuery(nSql) do
  begin
    if recordcount>0 then
    begin
      if (Trim(Fields[0].AsString) <> '') or (Trim(Fields[1].AsString) <> '')then
      begin
        Result := True;
      end;
    end;
  end;
end;

function IsPurTruckReady(const nTruck: string; var nHint: string): Boolean;
var
  nSql:string;
begin
  Result := True;
  nHint := '';

  nSql := 'select R_ID from %s where P_Truck = ''%s'' and P_Status <>''%s'' ';
  nSql := Format(nSql,[sTable_CardProvide,nTruck,sFlag_TruckOut]);

  with FDM.SQLQuery(nSql) do
  begin
    if recordcount>0 then
    begin
      Result := False;
      nHint := Fields[0].AsString;
    end;
  end;
end;

//�����Ƿ����δ��������
function IFHasBill(const nTruck: string): Boolean;
var nStr: string;
begin
  Result := False;

  nStr :='select L_ID from %s where L_Status <> ''%s'' and L_Truck =''%s'' ';
  nStr := Format(nStr, [sTable_Bill, sFlag_TruckOut, nTruck]);
  with FDM.SQLQuery(nStr) do
  if RecordCount > 0 then
  begin
    Result := True;
  end;
end;

function GetTransType(const nID: string): string;
var
  nSql:string;
begin
  Result := sFlag_TypeCommon;

  if Trim(nID) = '' then
    Exit;

  nSql := 'select D_Value from %s where D_Name = ''%s'' and D_Memo=''%s''';
  nSql := Format(nSql,[sTable_SysDict,sFlag_TransType, nID]);

  WriteLog('��ѯ���䷽ʽSQL:' + nSql);
  with FDM.SQLQuery(nSql) do
  begin
    if recordcount>0 then
    begin
      if Fields[0].AsString <> '' then
        Result := Fields[0].AsString;
    end;
  end;
end;

//Date: 2019/5/14
//Desc: ɢװ��󿪵�������
function GetTruckSanMaxLadeValue(const nTruck: string; var nForce: Boolean): Double;
var nSQL: string;
begin
  Result := 0;
  nForce := False;
  nSQL := 'Select D_Value From %s Where D_Name=''%s''';
  nSQL := Format(nSQL, [sTable_SysDict, sFlag_ForceTruckSanMaxLade]);
  with FDM.SQLQuery(nSql) do
  begin
    if RecordCount <= 0 then
    begin
      Exit;
    end;

    if Fields[0].AsString <> sFlag_Yes then
      Exit;
    nForce := True;
  end;

  if Trim(nTruck) = '' then
  begin
    Exit;
  end;

  nSQL := 'Select top 1 T_HZValueMax From %s Where T_Truck=''%s'' ';
  nSQL := Format(nSQL, [sTable_Truck, nTruck]);

  with FDM.SQLQuery(nSql) do
  if RecordCount > 0 then
    Result := Fields[0].AsFloat;
end;

function GetAICMPurMinValue: Double;
var nSQL: string;
begin
  Result := 0;
  nSQL := 'Select D_Value From %s Where D_Name=''%s''';
  nSQL := Format(nSQL, [sTable_SysDict, sFlag_AICMPurMinValue]);

  with FDM.SQLQuery(nSql) do
  if RecordCount > 0 then
    Result := Fields[0].AsFloat;
end;

function GetPDModelFromDB: string;
var
  nSql:string;
begin
  Result := '';

  nSql := 'select D_Value from %s where D_Name = ''%s''';
  nSql := Format(nSql,[sTable_SysDict,sFlag_AutoPD]);

  with FDM.SQLQuery(nSql) do
  begin
    if recordcount>0 then
    begin
        Result := Fields[0].AsString;
    end;
  end;
end;

function GetGPSUrl(const nTruck: string; var nHint: string): string;
var
  nSql:string;
begin
  Result := '';
  nHint := sFlag_No;
  WriteLog('GPSУ��:��ʼƴ��' + nTruck + 'Url');
  nSql := 'select D_Value,D_ParamB from %s where D_Name = ''%s''';
  nSql := Format(nSql,[sTable_SysDict,sFlag_GPSUrl]);

  with FDM.SQLQuery(nSql) do
  begin
    if recordcount>0 then
    begin
      nHint := Fields[1].AsString;
      Result := Fields[0].AsString;
      Result := Format(Result, [HttpEncode(AnsiToUtf8(nTruck))]);
      WriteLog('GPSУ��:�������' + Result);
    end;
  end;

  if nHint = sFlag_Yes then
  begin
    if not IsTruckGPSValid(nTruck) then
    begin
      nHint := sFlag_No;
      Exit;
    end;
  end;
end;

function GetBillCard(const nLID: string): string;
var nStr: string;
begin
  Result := '';

  nStr :='select L_Card from %s where L_ID =''%s'' ';
  nStr := Format(nStr, [sTable_Bill, nLID]);
  WriteLog('��ȡ������󶨿���sql' + nStr);
  with FDM.SQLQuery(nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsString;
  end;
end;

function HasDriverCard(const nTruck: string; var nCard: string): Boolean;
var nStr: string;
begin
  Result := False;
  nCard := '';

  nStr := 'Select * From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, nTruck]);

  with FDM.SQLQuery(nStr) do
  if RecordCount > 0 then
  begin
    if Assigned(FindField('T_DriverCard')) then
      nCard := FieldByName('T_DriverCard').AsString;
    //xxxxx
  end;
  Result := nCard <> '';
end;

end.

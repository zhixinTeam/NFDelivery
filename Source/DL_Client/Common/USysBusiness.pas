{*******************************************************************************
  ����: dmzn@163.com 2010-3-8
  ����: ϵͳҵ����
*******************************************************************************}
unit USysBusiness;

interface

uses
  Windows, DB, Classes, Controls, SysUtils, UBusinessPacker, UBusinessWorker,
  UBusinessConst, ULibFun, UAdjustForm, UFormCtrl, UDataModule, UDataReport,
  UFormBase, cxMCListBox, UMgrPoundTunnels, HKVNetSDK, USysConst, USysDB,
  USysLoger, UBase64;

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

  TOrderItemInfo = record
    FCusID: string;       //�ͻ���
    FCusName: string;     //�ͻ���
    FSaleMan: string;     //ҵ��Ա
    FStockID: string;     //���Ϻ�
    FStockName: string;   //������

    FStockBrand: string;  //����Ʒ��
    FStockArea : string;  //���أ����

    FTruck: string;       //���ƺ�
    FBatchCode: string;   //���κ�
    FOrders: string;      //������(�ɶ���)
    FValue: Double;       //������
  end;

//------------------------------------------------------------------------------
function AdjustHintToRead(const nHint: string): string;
//������ʾ����
function WorkPCHasPopedom: Boolean;
//��֤�����Ƿ�����Ȩ
function GetSysValidDate: Integer;
//��ȡϵͳ��Ч��
function GetSerialNo(const nGroup,nObject: string;
 nUseDate: Boolean = True): string;
//��ȡ���б��
function GetStockBatcode(const nStock: string;
  const nBrand: string=''; const nValue: Double=0; const nBatch: string=''): string;
//��ȡ���κ�
function GetLadingStockItems(var nItems: TDynamicStockItemArray): Boolean;
//����Ʒ���б�
function GetQueryOrderSQL(const nType,nWhere: string): string;
//������ѯSQL���
function GetQueryDispatchSQL(const nWhere: string): string;
//��������SQL���
function GetQueryCustomerSQL(const nCusID,nCusName: string): string;
//�ͻ���ѯSQL���

function LoadSysDictItem(const nItem: string; const nList: TStrings): TDataSet;
//��ȡϵͳ�ֵ���
function LoadCustomerInfo(const nCID: string; const nList: TcxMCListBox;
 var nHint: string): TDataSet;
//����ͻ���Ϣ
function BuildOrderInfo(const nItem: TOrderItemInfo): string;
procedure AnalyzeOrderInfo(const nOrder: string; var nItem: TOrderItemInfo);
procedure LoadOrderInfo(const nOrder: TOrderItemInfo; const nList: TcxMCListBox);
//��������Ϣ
function GetOrderFHValue(const nOrders: TStrings;
  const nQueryFreeze: Boolean=True): Boolean;
//��ȡ����������
function GetOrderGYValue(const nOrders: TStrings): Boolean;
//��ȡ�����ѹ�Ӧ��

function SaveBill(const nBillData: string): string;
//���潻����
function DeleteBill(const nBill: string): Boolean;
//ɾ��������
function ChangeLadingTruckNo(const nBill,nTruck: string): Boolean;
//�����������
function BillSaleAdjust(const nBill, nNewZK: string): Boolean;
//����������
function SetBillCard(const nBill,nTruck: string; nVerify: Boolean): Boolean;
//Ϊ����������ſ�
function SaveBillCard(const nBill, nCard: string): Boolean;
//���潻�����ſ�
function LogoutBillCard(const nCard: string): Boolean;
//ע��ָ���ſ�

function GetLadingBills(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
//��ȡָ����λ�Ľ������б�
procedure LoadBillItemToMC(const nItem: TLadingBillItem; const nMC: TStrings;
 const nDelimiter: string);
//���뵥����Ϣ���б�
function SaveLadingBills(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem = nil): Boolean;
//����ָ����λ�Ľ�����

function GetTruckPoundItem(const nTruck: string;
 var nPoundData: TLadingBillItems): Boolean;
//��ȡָ���������ѳ�Ƥ����Ϣ
function SaveTruckPoundItem(const nTunnel: PPTTunnelItem;
 const nData: TLadingBillItems; var nPoundID: string): Boolean;
//���泵��������¼
function ReadPoundCard(const nTunnel: string; nReadOnly: string=''): string;
//��ȡָ����վ��ͷ�ϵĿ���
procedure CapturePicture(const nTunnel: PPTTunnelItem; const nList: TStrings);
//ץ��ָ��ͨ��

function LoadTruckQueue(var nLines: TZTLineItems; var nTrucks: TZTTruckItems;
 const nRefreshLine: Boolean = False): Boolean;
//��ȡ��������
procedure PrinterEnable(const nTunnel: string; const nEnable: Boolean);
//��ͣ�����
function ChangeDispatchMode(const nMode: Byte): Boolean;
//�л�����ģʽ

function PrintBillReport(nBill: string; const nAsk: Boolean): Boolean;
//��ӡ�����
function PrintPoundReport(const nPound: string; nAsk: Boolean): Boolean;
//��ӡ��
function PrintSalePoundReport(const nPound: string; nAsk: Boolean): Boolean;
//��ӡ���۰���

//������ӱ�ǩ
function SetTruckRFIDCard(nTruck: string; var nRFIDCard: string;
  var nIsUse: string; nOldCard: string=''): Boolean;
//ָ����װ��
function SelectTruckTunnel(var nNewTunnel: string): Boolean;

function SaveWeiXinAccount(const nItem:TWeiXinAccount; var nWXID:string): Boolean;
function DelWeiXinAccount(const nWXID:string): Boolean;

function GetTruckPValue(var nItem:TPreTruckPItem; const nTruck: string):Boolean;
//��ȡ����Ԥ��Ƥ��
function TruckInFact(nTruck: string):Boolean;
//��֤�����Ƿ����
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

//Desc: ��֤�����Ƿ�����Ȩ����ϵͳ
function WorkPCHasPopedom: Boolean;
begin
  Result := gSysParam.FSerialID <> '';
  if not Result then
  begin
    ShowDlg('�ù�����Ҫ����Ȩ��,�������Ա����.', sHint);
  end;
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

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //�Զ�����ʱ����ʾ

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

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //�Զ�����ʱ����ʾ

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

//Date: 2014-10-01
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessHardware(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //�Զ�����ʱ����ʾ
    
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareCommand);
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

//Date: 2015-01-16
//Parm: ���Ϻ�;Ʒ����;������;ԭʼ����
//Desc: ����nStock�����κ�
function GetStockBatcode(const nStock: string;
 const nBrand: string=''; const nValue: Double=0; const nBatch: string=''): string;
var nOut: TWorkerBusinessCommand;
    nList: TStrings;
begin
  nList := TStringList.Create;

  try
    nList.Clear;
    nList.Values['Batch'] := nBatch;
    nList.Values['Brand'] := nBrand;
    nList.Values['Value'] := FloatToStr(nValue);

    if CallBusinessCommand(cBC_GetStockBatcode, nStock, nList.Text, @nOut, False) then
         Result := nOut.FData
    else Result := '';
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

  with FDM.QueryTemp(nStr) do
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

//------------------------------------------------------------------------------
//Date: 2014-06-19
//Parm: ��¼��ʶ;���ƺ�;ͼƬ�ļ�
//Desc: ��nFile�������ݿ�
procedure SavePicture(const nID, nTruck, nMate, nFile: string);
var nStr: string;
    nRID: Integer;
begin
  FDM.ADOConn.BeginTrans;
  try
    nStr := MakeSQLByStr([
            SF('P_ID', nID),
            SF('P_Name', nTruck),
            SF('P_Mate', nMate),
            SF('P_Date', sField_SQLServer_Now, sfVal)
            ], sTable_Picture, '', True);
    //xxxxx

    if FDM.ExecuteSQL(nStr) < 1 then Exit;
    nRID := FDM.GetFieldMax(sTable_Picture, 'R_ID');

    nStr := 'Select P_Picture From %s Where R_ID=%d';
    nStr := Format(nStr, [sTable_Picture, nRID]);
    FDM.SaveDBImage(FDM.QueryTemp(nStr), 'P_Picture', nFile);

    FDM.ADOConn.CommitTrans;
  except
    FDM.ADOConn.RollbackTrans;
  end;
end;

//Desc: ����ͼƬ·��
function MakePicName: string;
begin
  while True do
  begin
    Result := gSysParam.FPicPath + IntToStr(gSysParam.FPicBase) + '.jpg';
    if not FileExists(Result) then
    begin
      Inc(gSysParam.FPicBase);
      Exit;
    end;

    DeleteFile(Result);
    if FileExists(Result) then Inc(gSysParam.FPicBase)
  end;
end;

//Date: 2014-06-19
//Parm: ͨ��;�б�
//Desc: ץ��nTunnel��ͼ��
procedure CapturePicture(const nTunnel: PPTTunnelItem; const nList: TStrings);
const
  cRetry = 2;
  //���Դ���
var nStr: string;
    nIdx,nInt: Integer;
    nLogin,nErr: Integer;
    nPic: NET_DVR_JPEGPARA;
    nInfo: TNET_DVR_DEVICEINFO;
begin
  nList.Clear;
  if not Assigned(nTunnel.FCamera) then Exit;
  //not camera

  if not DirectoryExists(gSysParam.FPicPath) then
    ForceDirectories(gSysParam.FPicPath);
  //new dir

  if gSysParam.FPicBase >= 100 then
    gSysParam.FPicBase := 0;
  //clear buffer

  nLogin := -1;
  NET_DVR_Init();
  try
    for nIdx:=1 to cRetry do
    begin
      nLogin := NET_DVR_Login(PChar(nTunnel.FCamera.FHost),
                   nTunnel.FCamera.FPort,
                   PChar(nTunnel.FCamera.FUser),
                   PChar(nTunnel.FCamera.FPwd), @nInfo);
      //to login

      nErr := NET_DVR_GetLastError;
      if nErr = 0 then break;

      if nIdx = cRetry then
      begin
        nStr := '��¼�����[ %s.%d ]ʧ��,������: %d';
        nStr := Format(nStr, [nTunnel.FCamera.FHost, nTunnel.FCamera.FPort, nErr]);
        WriteLog(nStr);
        Exit;
      end;
    end;

    nPic.wPicSize := nTunnel.FCamera.FPicSize;
    nPic.wPicQuality := nTunnel.FCamera.FPicQuality;

    for nIdx:=Low(nTunnel.FCameraTunnels) to High(nTunnel.FCameraTunnels) do
    begin
      if nTunnel.FCameraTunnels[nIdx] = MaxByte then continue;
      //invalid

      for nInt:=1 to cRetry do
      begin
        nStr := MakePicName();
        //file path

        NET_DVR_CaptureJPEGPicture(nLogin, nTunnel.FCameraTunnels[nIdx],
                                   @nPic, PChar(nStr));
        //capture pic

        nErr := NET_DVR_GetLastError;
        if nErr = 0 then
        begin
          nList.Add(nStr);
          Break;
        end;

        if nIdx = cRetry then
        begin
          nStr := 'ץ��ͼ��[ %s.%d ]ʧ��,������: %d';
          nStr := Format(nStr, [nTunnel.FCamera.FHost,
                   nTunnel.FCameraTunnels[nIdx], nErr]);
          WriteLog(nStr);
        end;
      end;
    end;
  finally
    if nLogin > -1 then
      NET_DVR_Logout(nLogin);
    NET_DVR_Cleanup();
  end;
end;

//------------------------------------------------------------------------------
//Date: 2010-4-13
//Parm: �ֵ���;�б�
//Desc: ��SysDict�ж�ȡnItem�������,����nList��
function LoadSysDictItem(const nItem: string; const nList: TStrings): TDataSet;
var nStr: string;
begin
  nList.Clear;
  nStr := MacroValue(sQuery_SysDict, [MI('$Table', sTable_SysDict),
                                      MI('$Name', nItem)]);
  Result := FDM.QueryTemp(nStr);

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

//Desc: ����nCID�ͻ�����Ϣ��nList��,���������ݼ�
function LoadCustomerInfo(const nCID: string; const nList: TcxMCListBox;
 var nHint: string): TDataSet;
var nStr: string;
begin
  nStr := 'select custcode,t2.pk_cubasdoc,custname,user_name,' +
          't1.createtime from Bd_cumandoc t1' +
          '  left join bd_cubasdoc t2 on t2.pk_cubasdoc=t1.pk_cubasdoc' +
          '  left join sm_user t_su on t_su.cuserid=t1.creator ' +
          ' where custcode=''%s''';
  nStr := Format(nStr, [nCID]);

  nList.Clear;
  Result := FDM.QueryTemp(nStr, True);

  if Result.RecordCount > 0 then
  with nList.Items,Result do
  begin
    Add('�ͻ����:' + nList.Delimiter + FieldByName('custcode').AsString);
    Add('�ͻ�����:' + nList.Delimiter + FieldByName('custname').AsString + ' ');
    Add('�� �� ��:' + nList.Delimiter + FieldByName('user_name').AsString + ' ');
    Add('����ʱ��:' + nList.Delimiter + FieldByName('createtime').AsString + ' ');
  end else
  begin
    Result := nil;
    nHint := '�ͻ���Ϣ�Ѷ�ʧ';
  end;
end;

//Date: 2014-12-23
//Parm: ������
//Desc: ��nItem���ݴ��
function BuildOrderInfo(const nItem: TOrderItemInfo): string;
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
procedure AnalyzeOrderInfo(const nOrder: string; var nItem: TOrderItemInfo);
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

//Date: 2014-12-23
//Parm: ����;�б�
//Desc: ��nOrder��ʵ��nList��
procedure LoadOrderInfo(const nOrder: TOrderItemInfo; const nList: TcxMCListBox);
var nStr: string;
begin
  with nList.Items, nOrder do
  begin
    Clear;
    nStr := StringReplace(FOrders, #13#10, ',', [rfReplaceAll]);

    Add('�ͻ����:' + nList.Delimiter + FCusID + ' ');
    Add('�ͻ�����:' + nList.Delimiter + FCusName + ' ');
    Add('ҵ������:' + nList.Delimiter + FSaleMan + ' ');
    Add('���ϱ��:' + nList.Delimiter + FStockID + ' ');
    Add('��������:' + nList.Delimiter + FStockName + ' ');
    Add('�������:' + nList.Delimiter + nStr + ' ');
    Add('�������:' + nList.Delimiter + Format('%.2f',[FValue]) + ' ��');
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

//Date: 2014-09-25
//Parm: ���ƺ�
//Desc: ��ȡnTruck�ĳ�Ƥ��¼
function GetTruckPoundItem(const nTruck: string;
 var nPoundData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetTruckPoundData, nTruck, '', @nOut);
  if Result then
    AnalyseBillItems(nOut.FData, nPoundData);
  //xxxxx
end;

//Date: 2014-09-25
//Parm: ��������
//Desc: ����nData��������
function SaveTruckPoundItem(const nTunnel: PPTTunnelItem;
 const nData: TLadingBillItems; var nPoundID: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nPoundID := '';
  nStr := CombineBillItmes(nData);
  Result := CallBusinessCommand(cBC_SaveTruckPoundData, nStr, '', @nOut);
  if (not Result) or (nOut.FData = '') then Exit;
  nPoundID := nOut.FData;

  nList := TStringList.Create;
  try
    CapturePicture(nTunnel, nList);
    //capture file

    for nIdx:=0 to nList.Count - 1 do
      SavePicture(nOut.FData, nData[0].FTruck,
                              nData[0].FStockName, nList[nIdx]);
    //save file
  finally
    nList.Free;
  end;
end;

//Date: 2014-10-02
//Parm: ͨ����
//Desc: ��ȡnTunnel��ͷ�ϵĿ���
function ReadPoundCard(const nTunnel: string; nReadOnly: String = ''): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessHardware(cBC_GetPoundCard, nTunnel, nReadOnly, @nOut, False) then
       Result := nOut.FData
  else Result := '';
end;

//------------------------------------------------------------------------------
//Date: 2014-10-01
//Parm: ͨ��;����
//Desc: ��ȡ������������
function LoadTruckQueue(var nLines: TZTLineItems; var nTrucks: TZTTruckItems;
 const nRefreshLine: Boolean): Boolean;
var nIdx: Integer;
    nSLine,nSTruck: string;
    nListA,nListB: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    if nRefreshLine then
         nSLine := sFlag_Yes
    else nSLine := sFlag_No;

    Result := CallBusinessHardware(cBC_GetQueueData, nSLine, '', @nOut);
    if not Result then Exit;

    nListA.Text := PackerDecodeStr(nOut.FData);
    nSLine := nListA.Values['Lines'];
    nSTruck := nListA.Values['Trucks'];

    nListA.Text := PackerDecodeStr(nSLine);
    SetLength(nLines, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    with nLines[nIdx],nListB do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      FID       := Values['ID'];
      FName     := Values['Name'];
      FStock    := Values['Stock'];
      FIsVip    := Values['VIP'];
      FValid    := Values['Valid'] <> sFlag_No;
      FPrinterOK:= Values['Printer'] <> sFlag_No;

      if IsNumber(Values['Weight'], False) then
           FWeight := StrToInt(Values['Weight'])
      else FWeight := 1;
    end;

    nListA.Text := PackerDecodeStr(nSTruck);
    SetLength(nTrucks, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    with nTrucks[nIdx],nListB do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
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
  finally
    nListA.Free;
    nListB.Free;
  end;
end;

//Date: 2014-10-01
//Parm: ͨ����;��ͣ��ʶ
//Desc: ��ͣnTunnelͨ���������
procedure PrinterEnable(const nTunnel: string; const nEnable: Boolean);
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  if nEnable then
       nStr := sFlag_Yes
  else nStr := sFlag_No;

  CallBusinessHardware(cBC_PrinterEnable, nTunnel, nStr, @nOut);
end;

//Date: 2014-10-07
//Parm: ����ģʽ
//Desc: �л�ϵͳ����ģʽΪnMode
function ChangeDispatchMode(const nMode: Byte): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessHardware(cBC_ChangeDispatchMode, IntToStr(nMode), '',
            @nOut);
  //xxxxx
end;

//------------------------------------------------------------------------------
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

//Date: 2014-09-15
//Parm: ��������
//Desc: ɾ��nBillID����
function DeleteBill(const nBill: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_DeleteBill, nBill, '', @nOut);
end;

//Date: 2014-09-15
//Parm: ������;�³���
//Desc: �޸�nBill�ĳ���ΪnTruck.
function ChangeLadingTruckNo(const nBill,nTruck: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_ModifyBillTruck, nBill, nTruck, @nOut);
end;

//Date: 2014-09-30
//Parm: ������;ֽ��
//Desc: ��nBill������nNewZK�Ŀͻ�
function BillSaleAdjust(const nBill, nNewZK: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_SaleAdjust, nBill, nNewZK, @nOut);
end;

//Date: 2014-09-17
//Parm: ������;���ƺ�;У���ƿ�����
//Desc: ΪnBill�������ƿ�
function SetBillCard(const nBill,nTruck: string; nVerify: Boolean): Boolean;
var nStr: string;
    nP: TFormCommandParam;
begin
  Result := True;
  if nVerify then
  begin
    nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_ViaBillCard]);

    with FDM.QueryTemp(nStr) do
     if (RecordCount < 1) or (Fields[0].AsString <> sFlag_Yes) then Exit;
    //no need do card
  end;

  nP.FParamA := nBill;
  nP.FParamB := nTruck;
  CreateBaseFormItem(cFI_FormMakeCard, '', @nP);
  Result := (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK);
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

//Date: 2014-09-17
//Parm: �ſ���;��λ;�������б�
//Desc: ��ȡnPost��λ�ϴſ�ΪnCard�Ľ������б�
function GetLadingBills(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
    AnalyseBillItems(nOut.FData, nBills);
  //xxxxx
end;

//Date: 2014-09-18
//Parm: ��λ;�������б�;��վͨ��
//Desc: ����nPost��λ�ϵĽ���������
function SaveLadingBills(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem): Boolean;
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessSaleBill(cBC_SavePostBills, nStr, nPost, @nOut);
  if (not Result) or (nOut.FData = '') then Exit;

  if Assigned(nTunnel) then //��������
  begin
    nList := TStringList.Create;
    try
      CapturePicture(nTunnel, nList);
      //capture file

      for nIdx:=0 to nList.Count - 1 do
        SavePicture(nOut.FData, nData[0].FTruck,
                                nData[0].FStockName, nList[nIdx]);
      //save file
    finally
      nList.Free;
    end;
  end;
end;

function SaveWeiXinAccount(const nItem:TWeiXinAccount; var nWXID:string): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineWXAccountItem(nItem);
  Result := CallBusinessCommand(cBC_SaveWeixinAccount, nStr, '', @nOut);
  if not Result or (nOut.FData='') then Exit;

  nWXID := nOut.FData;
end;

function DelWeiXinAccount(const nWXID:string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_DelWeixinAccount, nWXID, '', @nOut);
  if not Result or (nOut.FData='') then Exit;
end;


//Date: 2014-09-17
//Parm: ��������; MCListBox;�ָ���
//Desc: ��nItem����nMC
procedure LoadBillItemToMC(const nItem: TLadingBillItem; const nMC: TStrings;
 const nDelimiter: string);
var nStr: string;
begin
  with nItem,nMC do
  begin
    Clear;
    Add(Format('���ƺ���:%s %s', [nDelimiter, FTruck]));
    Add(Format('��ǰ״̬:%s %s', [nDelimiter, TruckStatusToStr(FStatus)]));

    Add(Format('%s ', [nDelimiter]));
    Add(Format('��������:%s %s', [nDelimiter, FId]));
    Add(Format('��������:%s %.3f ��', [nDelimiter, FValue]));
    if FType = sFlag_Dai then nStr := '��װ' else nStr := 'ɢװ';

    Add(Format('Ʒ������:%s %s', [nDelimiter, nStr]));
    Add(Format('Ʒ������:%s %s', [nDelimiter, FStockName]));

    Add(Format('%s ', [nDelimiter]));
    Add(Format('����ſ�:%s %s', [nDelimiter, FCard]));
    Add(Format('��������:%s %s', [nDelimiter, BillTypeToStr(FIsVIP)]));
    Add(Format('�ͻ�����:%s %s', [nDelimiter, FCusName]));
  end;
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

  nBill := AdjustListStrFormat(nBill, '''', True, ',', False);
  //�������

  nStr := 'Select * From %s b Where L_ID In(%s)';
  nStr := Format(nStr, [sTable_Bill, nBill]);
  //xxxxx

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '���Ϊ[ %s ] �ļ�¼����Ч!!';
    nStr := Format(nStr, [nBill]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'LadingBill.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '�޷���ȷ���ر����ļ�';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Date: 2012-4-15
//Parm: ��������;�Ƿ�ѯ��
//Desc: ��ӡnPound������¼
function PrintPoundReport(const nPound: string; nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '�Ƿ�Ҫ��ӡ������?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s Where P_ID=''%s''';
  nStr := Format(nStr, [sTable_PoundLog, nPound]);

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '���ؼ�¼[ %s ] ����Ч!!';
    nStr := Format(nStr, [nPound]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'Pound.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '�޷���ȷ���ر����ļ�';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  //FDR.ShowReport;
  //Result := FDR.PrintSuccess;
  Result := FDR.PrintReport;

  if Result  then
  begin
    nStr := 'Update %s Set P_PrintNum=P_PrintNum+1 Where P_ID=''%s''';
    nStr := Format(nStr, [sTable_PoundLog, nPound]);
    FDM.ExecuteSQL(nStr);
  end;
end;

//Date: 2015-8-6
//Parm: ��������;�Ƿ�ѯ��
//Desc: ��ӡ����nPound������¼
function PrintSalePoundReport(const nPound: string; nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '�Ƿ�Ҫ��ӡ������?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s sp ' +
          'left join %s sbill on sp.P_Bill=sbill.L_ID ' + //
          'Where P_ID=''%s''';
  nStr := Format(nStr, [sTable_PoundLog, sTable_Bill, nPound]);

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '���ؼ�¼[ %s ] ����Ч!!';
    nStr := Format(nStr, [nPound]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'SalePound.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '�޷���ȷ���ر����ļ�';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;

  if Result  then
  begin
    nStr := 'Update %s Set P_PrintNum=P_PrintNum+1 Where P_ID=''%s''';
    nStr := Format(nStr, [sTable_PoundLog, nPound]);
    FDM.ExecuteSQL(nStr);
  end;
end;

//Date: 2015/1/18
//Parm: ���ƺţ����ӱ�ǩ���Ƿ����ã��ɵ��ӱ�ǩ
//Desc: ����ǩ�Ƿ�ɹ����µĵ��ӱ�ǩ
function SetTruckRFIDCard(nTruck: string; var nRFIDCard: string;
  var nIsUse: string; nOldCard: string=''): Boolean;
var nP: TFormCommandParam;
begin
  nP.FParamA := nTruck;
  nP.FParamB := nOldCard;
  nP.FParamC := nIsUse;
  CreateBaseFormItem(cFI_FormMakeRFIDCard, '', @nP);

  nRFIDCard := nP.FParamB;
  nIsUse    := nP.FParamC;
  Result    := (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK);
end;
//Date: 2015/1/18
//Parm: װ��ͨ��
//Desc: ѡ�����ͨ��
function SelectTruckTunnel(var nNewTunnel: string): Boolean;
var nP: TFormCommandParam;
begin
  nP.FParamA := nNewTunnel;
  CreateBaseFormItem(cFI_FormChangeTunnel, '', @nP);

  nNewTunnel := nP.FParamB;
  Result    := (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK);
end;
//Date: 2015/4/20
//Parm: Ƥ��;���ƺ�
//Desc: ��ȡ����Ԥ��Ƥ��
function GetTruckPValue(var nItem:TPreTruckPItem; const nTruck: string):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetTruckPValue, nTruck, '', @nOut);
  if Result then
   AnalysePreTruckItem(nOut.FData, nItem);
end;

//Date: 2015/4/11
//Parm: ���ƺ�
//Desc: �����Ƿ��ѽ���
function TruckInFact(nTruck: string):Boolean;
var nStr: string;
begin
  Result := True;
  if nTruck='' then Exit;

  nStr := 'Select P_ID from %s where P_Truck=''%s'' and P_MValue is NULL' +
          ' and P_MDate is NULL and P_PModel<>''%s''';
  nStr := Format(nStr, [sTable_PoundLog, nTruck, sFlag_PoundLS]);
  //xxxxxx

  with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      nStr := '����%s�ѽ���';
      nStr := Format(nStr, [nTruck]);

      ShowDlg(nStr, sHint);
      Exit;
    end;
  //������ëǰ����ʹ��

  Result := False;
end;

end.

{*******************************************************************************
  ����: dmzn@163.com 2010-3-8
  ����: ϵͳҵ����
*******************************************************************************}
unit USysBusiness;

interface
{$I Link.inc}
uses
  Windows, DB, Classes, Controls, SysUtils, UBusinessPacker, UBusinessWorker,
  UBusinessConst, ULibFun, UAdjustForm, UFormCtrl, UDataModule, //UDataReport,
  UFormBase, cxMCListBox, UMgrPoundTunnels,  UBase64, USysConst,//UMgrCamera,
  USysDB, USysLoger, UMgrTTCEDispenser, UMgrLEDDisp, UMgrBXFontCard, UMgrVoiceNet;

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

  PSalePlanItem = ^TSalePlanItem;
  TSalePlanItem = record
    FOrderNo: string;        //������
    FInterID: string;        //������
    FEntryID: string;        //������
    FStockID: string;        //���ϱ��
    FStockName: string;      //��������

    FTruck: string;          //���ƺ���
    FValue: Double;          //������
    FSelected: Boolean;      //״̬
  end;
  TSalePlanItems = array of TSalePlanItem;

  PPurchaseItem = ^stPurchaseItem;
  stPurchaseItem = record
    FOrder_Id : string;      //�̳�ID
    FProvID   : string;      //��Ӧ��ID
    FProvName : string;      //��Ӧ������
    FGoodsID  : string;      //���ϱ��
    FGoodsname: string;      //��������
    FData     : string;      //����
    FMaxMum   : string;      //���Ӧ��
    FZhiKaNo  : string;      //��ͬ���
    FTrackNo  : string;      //���ƺ�
    FArea     : string;
    FCanSave  : Boolean;
    FTunnelID : string;
    FMsg      : string;
  end;
  // �ɹ���
var gPurOrderItems : array of stPurchaseItem; //��������
//------------------------------------------------------------------------------
function AdjustHintToRead(const nHint: string): string;
//������ʾ����
function WorkPCHasPopedom: Boolean;
//��֤�����Ƿ�����Ȩ
function GetSysValidDate: Integer;
//��ȡϵͳ��Ч��
function GetSerialNo(const nGroup,nObject: string; nUseDate: Boolean = True): string;
//��ȡ���б��
function GetLadingStockItems(var nItems: TDynamicStockItemArray): Boolean;
//����Ʒ���б�
function GetCardUsed(const nCard: string): string;
//��ȡ��Ƭ����

function LoadSysDictItem(const nItem: string; const nList: TStrings): TDataSet;
//��ȡϵͳ�ֵ���
function LoadCustomer(const nList: TStrings; const nWhere: string = ''): Boolean;
//��ȡ�ͻ��б�

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
function SetTruckRFIDCard(nTruck: string; var nRFIDCard: string;
  var nIsUse: string; nOldCard: string=''): Boolean;

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
 const nData: TLadingBillItems): Boolean;
//���泵��������¼
function ReadPoundCard(const nTunnel: string; var nReader: string): string;
//��ȡָ����վ��ͷ�ϵĿ���
//procedure CapturePicture(const nTunnel: PPTTunnelItem; const nList: TStrings);
//ץ��ָ��ͨ��

procedure GetPoundAutoWuCha(var nWCValZ,nWCValF: Double; const nVal: Double;
 const nStation: string = '');
//��ȡ��Χ
function AddManualEventRecord(const nEID,nKey,nEvent:string;
 const nFrom: string = sFlag_DepBangFang ;
 const nSolution: string = sFlag_Solution_YN;
 const nDepartmen: string = sFlag_DepDaTing;
 const nReset: Boolean = False; const nMemo: string = ''): Boolean;
//��Ӵ����������¼

function IsTunnelOK(const nTunnel: string): Boolean;
//��ѯͨ����դ�Ƿ�����
procedure TunnelOC(const nTunnel: string; const nOpen: Boolean);
//����ͨ�����̵ƿ���
function PlayNetVoice(const nText,nCard,nContent: string): Boolean;
//���м����������
procedure LoadOrderItemToMC(const nItem: TLadingBillItem; const nMC: TStrings;
 const nDelimiter: string);

function LoadTruckQueue(var nLines: TZTLineItems; var nTrucks: TZTTruckItems;
 const nRefreshLine: Boolean = False): Boolean;
//��ȡ��������
procedure PrinterEnable(const nTunnel: string; const nEnable: Boolean);
//��ͣ�����
function ChangeDispatchMode(const nMode: Byte): Boolean;
//�л�����ģʽ
function OpenDoorByReader(const nReader: string; nType: string = 'Y'): Boolean;
//�������򿪵�բ

//------------------------------------------------------------------------------


function GetTruckLastTime(const nTruck: string): Integer;
//���һ�ι���ʱ��

function GetFQValueByStockNo(const nStock: string): Double;
//��ȡ��ǩ���ѷ���
procedure DoSaveWork(const nTTCEID: string; nInt: Integer);
procedure LEDDisplay(const nTunnel: string; nContent: string = '';
                     nTitle: string = '');

procedure PlayVoice(const nTunnel, nStrtext: string);
function CheckCardOK(const nCard:string; var nMsg:string):Boolean;
//���ſ��Ƿ�ռ��
function GetNcOrderList(const nID: string): string;
function AICMSaveOrder(const nPurchaseItem : stPurchaseItem; nCard,nTTCEID: string;
                       var nMsg:string):Boolean;
function SaveCardProvie(const nCardData: string): string;
//����ɹ���
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

function GetCardUsed(const nCard: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_GetCardUsed, nCard, '', @nOut) then
    Result := nOut.FData;
  //xxxxx
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
//procedure CapturePicture(const nTunnel: PPTTunnelItem; const nList: TStrings);
//const
//  cRetry = 2;
//  //���Դ���
//var nStr: string;
//    nIdx,nInt: Integer;
//    nLogin,nErr: Integer;
//    nPic: NET_DVR_JPEGPARA;
//    nInfo: TNET_DVR_DEVICEINFO;
//begin
//  nList.Clear;
//  if not Assigned(nTunnel.FCamera) then Exit;
//  //not camera
//
//  if not DirectoryExists(gSysParam.FPicPath) then
//    ForceDirectories(gSysParam.FPicPath);
//  //new dir
//
//  if gSysParam.FPicBase >= 100 then
//    gSysParam.FPicBase := 0;
//  //clear buffer
//
//  nLogin := -1;
//  gCameraNetSDKMgr.NET_DVR_SetDevType(nTunnel.FCamera.FType);
//  //xxxxx
//
//  gCameraNetSDKMgr.NET_DVR_Init;
//  //xxxxx
//
//  try
//    for nIdx:=1 to cRetry do
//    begin
//      nLogin := gCameraNetSDKMgr.NET_DVR_Login(nTunnel.FCamera.FHost,
//                   nTunnel.FCamera.FPort,
//                   nTunnel.FCamera.FUser,
//                   nTunnel.FCamera.FPwd, nInfo);
//      //to login
//
//      nErr := gCameraNetSDKMgr.NET_DVR_GetLastError;
//      if nErr = 0 then break;
//
//      if nIdx = cRetry then
//      begin
//        nStr := '��¼�����[ %s.%d ]ʧ��,������: %d';
//        nStr := Format(nStr, [nTunnel.FCamera.FHost, nTunnel.FCamera.FPort, nErr]);
//        WriteLog(nStr);
//        Exit;
//      end;
//    end;
//
//    nPic.wPicSize := nTunnel.FCamera.FPicSize;
//    nPic.wPicQuality := nTunnel.FCamera.FPicQuality;
//
//    for nIdx:=Low(nTunnel.FCameraTunnels) to High(nTunnel.FCameraTunnels) do
//    begin
//      if nTunnel.FCameraTunnels[nIdx] = MaxByte then continue;
//      //invalid
//
//      for nInt:=1 to cRetry do
//      begin
//        nStr := MakePicName();
//        //file path
//
//        gCameraNetSDKMgr.NET_DVR_CaptureJPEGPicture(nLogin,
//                                   nTunnel.FCameraTunnels[nIdx],
//                                   nPic, nStr);
//        //capture pic
//
//        nErr := gCameraNetSDKMgr.NET_DVR_GetLastError;
//
//        if nErr = 0 then
//        begin
//          nList.Add(nStr);
//          Break;
//        end;
//
//        if nIdx = cRetry then
//        begin
//          nStr := 'ץ��ͼ��[ %s.%d ]ʧ��,������: %d';
//          nStr := Format(nStr, [nTunnel.FCamera.FHost,
//                   nTunnel.FCameraTunnels[nIdx], nErr]);
//          WriteLog(nStr);
//        end;
//      end;
//    end;
//  finally
//    if nLogin > -1 then
//     gCameraNetSDKMgr.NET_DVR_Logout(nLogin);
//    gCameraNetSDKMgr.NET_DVR_Cleanup();
//  end;
//end;

//------------------------------------------------------------------------------
//Date: 2017-07-09
//Parm: ��װ�������;Ʊ��;��վ��
//Desc: ����nVal����Χ
procedure GetPoundAutoWuCha(var nWCValZ,nWCValF: Double; const nVal: Double;
 const nStation: string);
var nStr: string;
begin
  nWCValZ := 0;
  nWCValF := 0;
  if nVal <= 0 then Exit;

  nStr := 'Select * From %s Where P_Start<=%.2f and P_End>%.2f';
  nStr := Format(nStr, [sTable_PoundDaiWC, nVal, nVal]);

  if Length(nStation) > 0 then
    nStr := nStr + ' And P_Station=''' + nStation + '''';
  //xxxxx

  with FDM.QuerySQL(nStr) do
  if RecordCount > 0 then
  begin
    if FieldByName('P_Percent').AsString = sFlag_Yes then 
    begin
      nWCValZ := nVal * 1000 * FieldByName('P_DaiWuChaZ').AsFloat;
      nWCValF := nVal * 1000 * FieldByName('P_DaiWuChaF').AsFloat;
      //�������������
    end else
    begin     
      nWCValZ := FieldByName('P_DaiWuChaZ').AsFloat;
      nWCValF := FieldByName('P_DaiWuChaF').AsFloat;
      //���̶�ֵ�������
    end;
  end;
end;

//Date: 2017-07-09
//Parm: ��������
//Desc: ����쳣�¼�����
function AddManualEventRecord(const nEID,nKey,nEvent:string;
 const nFrom,nSolution,nDepartmen: string;
 const nReset: Boolean; const nMemo: string): Boolean;
var nStr: string;
    nUpdate: Boolean;
begin
  Result := False;
  if Trim(nSolution) = '' then
  begin
    WriteLog('��ѡ������.');
    Exit;
  end;

  nStr := 'Select * From %s Where E_ID=''%s''';
  nStr := Format(nStr, [sTable_ManualEvent, nEID]);
  
  with FDM.QuerySQL(nStr) do
  if RecordCount > 0 then
  begin
    nStr := '�¼���¼:[ %s ]�Ѵ���';
    WriteLog(Format(nStr, [nEID]));

    if not nReset then Exit;
    nUpdate := True;
  end else nUpdate := False;

  nStr := SF('E_ID', nEID);
  nStr := MakeSQLByStr([
          SF('E_ID', nEID),
          SF('E_Key', nKey),
          SF('E_From', nFrom),
          SF('E_Memo', nMemo),
          SF('E_Result', 'Null', sfVal),
          
          SF('E_Event', nEvent),
          SF('E_Solution', nSolution),
          SF('E_Departmen', nDepartmen),
          SF('E_Date', sField_SQLServer_Now, sfVal)
          ], sTable_ManualEvent, nStr, (not nUpdate));
  //xxxxx

  FDM.ExecuteSQL(nStr);
  Result := True;
end;

//------------------------------------------------------------------------------
//Date: 2014-07-03
//Parm: ͨ����
//Desc: ��ѯnTunnel�Ĺ�դ״̬�Ƿ�����
function IsTunnelOK(const nTunnel: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessHardware(cBC_IsTunnelOK, nTunnel, '', @nOut) then
       Result := nOut.FData = sFlag_Yes
  else Result := False;
end;

procedure TunnelOC(const nTunnel: string; const nOpen: Boolean);
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  if nOpen then
       nStr := sFlag_Yes
  else nStr := sFlag_No;

  CallBusinessHardware(cBC_TunnelOC, nTunnel, nStr, @nOut);
end;

//Date: 2016-01-06
//Parm: �ı�;������;����
//Desc: ��nCard����nContentģʽ��nText�ı�.
function PlayNetVoice(const nText,nCard,nContent: string): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := 'Card=' + nCard + #13#10 +
          'Content=' + nContent + #13#10 + 'Truck=' + nText;
  //xxxxxx

  Result := CallBusinessHardware(cBC_PlayVoice, nStr, '', @nOut);
  if not Result then
    WriteLog(nOut.FBase.FErrDesc);
  //xxxxx
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

//Desc: ��ȡ�ͻ��б�nList��,������������
function LoadCustomer(const nList: TStrings; const nWhere: string = ''): Boolean;
var nStr,nW: string;
begin
  if nWhere = '' then
       nW := ''
  else nW := Format(' And (%s)', [nWhere]);

  nStr := 'C_ID=Select C_ID,C_Name From %s ' +
          'Where IsNull(C_XuNi, '''')<>''%s'' %s Order By C_PY';
  nStr := Format(nStr, [sTable_Customer, sFlag_Yes, nW]);

  AdjustStringsItem(nList, True);
  FDM.FillStringsData(nList, nStr, -1, '.');

  AdjustStringsItem(nList, False);
  Result := nList.Count > 0;
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
 const nData: TLadingBillItems): Boolean;
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessCommand(cBC_SaveTruckPoundData, nStr, '', @nOut);
  if (not Result) or (nOut.FData = '') then Exit;

  nList := TStringList.Create;
  try
    //CapturePicture(nTunnel, nList);
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
function ReadPoundCard(const nTunnel: string; var nReader: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  nReader:= '';
  //����

  if CallBusinessHardware(cBC_GetPoundCard, nTunnel, '', @nOut) then
  begin
    Result := Trim(nOut.FData);
    nReader:= Trim(nOut.FExtParam);
  end;
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

//Desc: ��ȡnCID�û��Ŀ��ý��,�������ö�򾻶�
function GetCustomerValidMoney(nCID: string; const nLimit: Boolean;
 const nCredit: PDouble): Double;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  if nLimit then
       nStr := sFlag_Yes
  else nStr := sFlag_No;

  if CallBusinessCommand(cBC_GetCustomerMoney, nCID, nStr, @nOut) then
  begin
    Result := StrToFloat(nOut.FData);
    if Assigned(nCredit) then
      nCredit^ := StrToFloat(nOut.FExtParam);
    //xxxxx
  end else
  begin
    Result := 0;
    if Assigned(nCredit) then
      nCredit^ := 0;
    //xxxxx
  end;
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
  nP.FParamC := sFlag_Sale;
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
      //CapturePicture(nTunnel, nList);
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

//Date: 2014-09-17
//Parm: ������;���ƺ�;У���ƿ�����
//Desc: ΪnBill�������ƿ�
function SetOrderCard(const nOrder,nTruck: string; nVerify: Boolean): Boolean;
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

  nP.FParamA := nOrder;
  nP.FParamB := nTruck;
  nP.FParamC := sFlag_Provide;
  CreateBaseFormItem(cFI_FormMakeCard, '', @nP);
  Result := (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK);
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

//Date: 2014-09-17
//Parm: ��������; MCListBox;�ָ���
//Desc: ��nItem����nMC
procedure LoadOrderItemToMC(const nItem: TLadingBillItem; const nMC: TStrings;
 const nDelimiter: string);
var nStr: string;
begin
  with nItem,nMC do
  begin
    Clear;
    Add(Format('���ƺ���:%s %s', [nDelimiter, FTruck]));
    Add(Format('��ǰ״̬:%s %s', [nDelimiter, TruckStatusToStr(FStatus)]));

    Add(Format('%s ', [nDelimiter]));
    Add(Format('�ɹ�����:%s %s', [nDelimiter, FZhiKa]));
//    Add(Format('��������:%s %.3f ��', [nDelimiter, FValue]));
    if FType = sFlag_Dai then nStr := '��װ' else nStr := 'ɢװ';

    Add(Format('Ʒ������:%s %s', [nDelimiter, nStr]));
    Add(Format('Ʒ������:%s %s', [nDelimiter, FStockName]));
    
    Add(Format('%s ', [nDelimiter]));
    Add(Format('�ͻ��ſ�:%s %s', [nDelimiter, FCard]));
    Add(Format('��������:%s %s', [nDelimiter, BillTypeToStr(FIsVIP)]));
    Add(Format('�� Ӧ ��:%s %s', [nDelimiter, FCusName]));
  end;
end;

//Desc: ��ȡnNoˮ���ŵ��ѿ���
function GetHYValueByStockNo(const nNo: string): Double;
var nStr: string;
begin
  nStr := 'Select R_SerialNo,Sum(H_Value) From %s ' +
          ' Left Join %s on H_SerialNo= R_SerialNo ' +
          'Where R_SerialNo=''%s'' Group By R_SerialNo';
  nStr := Format(nStr, [sTable_StockRecord, sTable_StockHuaYan, nNo]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[1].AsFloat
  else Result := -1;
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

//Date: 2016/8/7
//Parm: ���ƺ�
//Desc: �鿴�����ϴι���ʱ����
function GetTruckLastTime(const nTruck: string): Integer;
var nStr: string;
    nNow, nPDate, nMDate: TDateTime;
begin
  Result := -1;
  //Ĭ������

  nStr := 'Select Top 1 %s as T_Now,P_PDate,P_MDate ' +
          'From %s Where P_Truck=''%s'' Order By P_ID Desc';
  nStr := Format(nStr, [sField_SQLServer_Now, sTable_PoundLog, nTruck]);
  //ѡ�����һ�ι���

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nNow   := FieldByName('T_Now').AsDateTime;
    nPDate := FieldByName('P_PDate').AsDateTime;
    nMDate := FieldByName('P_MDate').AsDateTime;

    if nPDate > nMDate then
         Result := Trunc((nNow - nPDate) * 24 * 60 * 60)
    else Result := Trunc((nNow - nMDate) * 24 * 60 * 60);
  end;
end;

function GetFQValueByStockNo(const nStock: string): Double;
var nSQL: string;
begin
  Result := 0;
  if nStock = '' then Exit;

  nSQL := 'Select Sum(L_Value) From %s Where L_Seal=''%s'' ' +
          'and L_Date > GetDate() - 30';   //һ�����ڵ��ܼ�
  nSQL := Format(nSQL, [sTable_Bill, nStock]);
  with FDM.QueryTemp(nSQL) do
  if RecordCount > 0 then
    Result := Fields[0].AsFloat;
end;

function OpenDoorByReader(const nReader: string; nType: string = 'Y'): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessHardware(cBC_OpenDoorByReader, nReader, nType,
            @nOut, False);
end;

procedure LEDDisplay(const nTunnel: string; nContent: string = '';
                     nTitle: string = '');
begin
  gSysLoger.AddLog(Format('LEDDisplay:%s.Content:%s.Title:%s',
                          [nTunnel, nContent, nTitle]));
  if Trim(nTitle) = '' then
    nTitle := cBXDataNull;
  if Trim(nContent) = '' then
    nContent := cBXDataNull;
  gBXFontCardManager.Display(nTitle, nContent, nTunnel);
end;

procedure PlayVoice(const nTunnel, nStrtext: string);
begin
  gSysLoger.AddLog(Format('PlayVoice:%s.%s', [nTunnel, nStrtext]));
  gNetVoiceHelper.PlayVoice(nStrtext, nTunnel);
end;

//��ȡ���Ų����浥��
procedure DoSaveWork(const nTTCEID: string; nInt: Integer);
var
  nStr, nCard, nHint: string;
  nLast: Int64;
  nIdx: Integer;
begin
  for nIdx:=0 to 3 do
  begin
    nCard := gDispenserManager.GetCardNo(nTTCEID, nHint, False);
    if nCard <> '' then
      Break;
    Sleep(200);
  end;

  if nCard = '' then
  begin
    nStr := '����������,����ϵ����Ա';
    PlayVoice(gPurOrderItems[nInt].FTunnelID, nStr);
    gPurOrderItems[nInt].FCanSave := False;
    Exit;
  end;

  nStr := '������'  + nTTCEID + ' ::: ' + nCard;
  WriteLog(nStr);

  if not CheckCardOK(nCard, nStr) then
  begin
    WriteLog('������'  + nTTCEID +' ::: ' + nStr);
    PlayVoice(gPurOrderItems[nInt].FTunnelID, nStr);
    gDispenserManager.RecoveryCard(nTTCEID, nHint);
    Exit;
  end;

  with gPurOrderItems[nInt] do
  begin
    if not FCanSave then
      Exit;

    AICMSaveOrder(gPurOrderItems[nInt], nCard, nTTCEID, nStr);
    if nStr <> '' then
    begin
      FMsg := nStr;
      PlayVoice(FTunnelID, nStr);
    end;
    FCanSave := False;
  end;
end;

//���ſ��Ƿ�ռ��
function CheckCardOK(const nCard:string; var nMsg:string):Boolean;
var
  nSQL: string;
  nValid: Boolean;
begin
  Result := False;
  nValid := False;

  nSql := 'select C_Card2,C_Card3 from %s where C_Card = ''%s'' ';
  nSql := Format(nSql,[sTable_Card,nCard]);

  with FDM.QueryTemp(nSQL) do
  begin
    if recordcount>0 then
    begin
      if (Trim(Fields[0].AsString) <> '') or (Trim(Fields[1].AsString) <> '')then
      begin
        nValid := True;
      end;
    end;
  end;

  if not nValid then
  begin
    nMsg := '�ſ�%s���ŷǷ�,���ڻ���,���Ժ�����';
    nMsg := Format(nMsg, [nCard]);
    Exit;
  end;

  nSQL := 'select P_Card from %s where P_Card =''%s'' ';
  nSQL := Format(nSQL, [sTable_CardProvide, nCard]);
  with FDM.QueryTemp(nSQL) do
  begin
    if RecordCount>0 then
    begin
      nMsg := '�ſ�%sʹ����,�޷��쿨,���ڻ���,���Ժ�����';
      nMsg := Format(nMsg, [nCard]);
      Exit;
    end;
  end;

  Result := True;
end;

function GetNcOrderList(const nID: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_GetPurchaseList, nID, '', @nOut, False) then
    Result := nOut.FData;
end;

function AICMSaveOrder(const nPurchaseItem : stPurchaseItem; nCard,nTTCEID: string;
                       var nMsg:string):Boolean;
var
  nSQL, nStr: string;
  nOnlyIss, nRet: Boolean;
  nlist : TStrings;
  nID: string;
begin
  Result := False;
  nOnlyIss := False;
  nRet := False;

  nSQL := 'select R_ID from %s where P_Truck =''%s'' and P_OutTime is null';
  nSQL := nSQL + ' and (P_Card is null or P_Card='''') and P_Status = ''%s''';
  nSQL := Format(nSQL, [sTable_CardProvide, nPurchaseItem.FTrackNo,
                                            sFlag_TruckNone]);
  with FDM.QueryTemp(nSQL) do
  begin
    if RecordCount>0 then
    begin
      nID := Fields[0].AsString;
      nMsg := '����%s�Ѱ�����Ч�ɹ�����%s,��ʼ���´ſ��Ų�����';
      nMsg := Format(nMsg, [nPurchaseItem.FTrackNo, nID]);
      WriteLog(nMsg);
      nOnlyIss := True;
    end;
  end;
  if nOnlyIss then
  begin
    nSQL := 'Update %s Set P_Card = ''%s'' where P_Truck =''%s''';
    nSQL := nSQL + ' and R_ID = ''%s''';
    nSQL := Format(nSQL, [sTable_CardProvide, nCard, nPurchaseItem.FTrackNo, nID]);
    try
     FDM.ExecuteSQL(nSQL);
     nRet := True;
    except
      on E: Exception do
      begin
        nMsg := '���´ſ���ʧ��:'+ E.Message;
        WriteLog(nMsg);
        Exit;
      end;
    end;
  end
  else
  begin
    nlist := TStringList.Create;
    try
      with nlist do
      begin
        Clear;

        Values['Order']     := nPurchaseItem.FOrder_Id;
        Values['Origin']    := nPurchaseItem.FArea;
        Values['Truck']     := nPurchaseItem.FTrackNo;
        //Values['Factory']   := gSysParam.FFactNum;

        Values['ProID']     := nPurchaseItem.FProvID;
        Values['ProName']   := nPurchaseItem.FProvName;

        Values['StockNO']   := nPurchaseItem.FGoodsID;
        Values['StockName'] := nPurchaseItem.FGoodsname;
        Values['Value']     := '';

        Values['Card']      := nCard;
        Values['Memo']      := '';

        Values['CardType']  := sFlag_ProvCardL;
        Values['TruckBack'] := sFlag_No;
        Values['TruckPre']  := sFlag_No;
        Values['Muilti']    := sFlag_No;
      end;

      nStr := SaveCardProvie(EncodeBase64(nlist.Text));
      //call mit bus
      nRet := nStr <> '';
    finally
      nlist.Free;
    end;
  end;
  if nRet then
  begin
    WriteLog(nPurchaseItem.FTrackNo +':::' + nCard + '׼������');
    if not gDispenserManager.SendCardOut(nTTCEID, nMsg) then
    begin
      nMsg := '����%s�Զ�����ʧ��';
      nMsg := Format(nMsg, [nPurchaseItem.FTrackNo]);
      WriteLog(nMsg);
      Exit;
    end;
    nMsg := '����%s�����ɹ�,����ȡ��';
    nMsg := Format(nMsg, [nPurchaseItem.FTrackNo]);
    WriteLog(nMsg);
    Result := True;
  end
  else
  begin
    nMsg := '����%s�ɹ�������ʧ��';
    nMsg := Format(nMsg, [nPurchaseItem.FTrackNo]);
    WriteLog(nMsg);
  end;
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

end.

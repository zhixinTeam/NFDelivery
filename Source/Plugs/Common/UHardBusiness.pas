{*******************************************************************************
  ����: dmzn@163.com 2012-4-22
  ����: Ӳ������ҵ��
*******************************************************************************}
unit UHardBusiness;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, SysUtils, UMgrDBConn, UMgrParam,
  UBusinessWorker, UBusinessConst, UBusinessPacker, UMgrQueue,
  UMgrHardHelper, U02NReader, UMgrERelay, UMgrTTCEM100,
  {$IFDEF MultiReplay}UMultiJS_Reply, {$ELSE}UMultiJS, {$ENDIF}UMgrRemotePrint,
  UMgrLEDDisp, UMgrRFID102, {$IFDEF HKVDVR}UMgrCamera, {$ENDIF}Graphics, DB,
  UMgrLEDDispCounter, UJSDoubleChannel,
  UMgrremoteSnap,UMgrVoiceNet, DateUtils;

procedure WhenReaderCardArrived(const nReader: THHReaderItem);
procedure WhenTTCE_M100_ReadCard(const nItem: PM100ReaderItem);
procedure WhenHYReaderCardArrived(const nReader: PHYReaderItem);
//���¿��ŵ����ͷ
procedure WhenReaderCardIn(const nCard: string; const nHost: PReaderHost);
//�ֳ���ͷ���¿���
procedure WhenReaderCardOut(const nCard: string; const nHost: PReaderHost);
//�ֳ���ͷ���ų�ʱ
procedure WhenBusinessMITSharedDataIn(const nData: string);
//ҵ���м����������
function GetJSTruck(const nTruck,nBill: string): string;
//��ȡ��������ʾ����
procedure WhenSaveJS(const nTunnel: PMultiJSTunnel);
//����������

procedure WhenQueueTruckChanged(const nManager: TTruckQueueManager);
//���г������
function PrepareShowInfo(const nCard: string; nTunnel: string=''; nTunnelEx: string='';
 nLevel: Integer = 0):string;
//��������ʾԤװ��Ϣ
function GetCardUsed(const nCard: string; var nCardType: string): Boolean;
//��ȡ��������

procedure MakeTruckShowPreInfo(const nCard: string; nTunnel: string='';nTunnelEx: string='');
//��ʾԤˢ����Ϣ
procedure MakeTruckAddWater(const nCard: string; nTunnel: string='');
//ɢװ����ˮ

procedure HardOpenDoor(const nReader: String);
//�򿪵�բ
{$IFDEF HKVDVR}
procedure WhenCaptureFinished(const nPtr: Pointer);
//����ͼƬ
{$ENDIF}
procedure SaveGrabCard(const nCard: string; nTunnel: string='');
//����������ץ���ӹ�������
function VerifySnapTruck(const nTruck,nBill,nPos,nDept: string;var nResult: string): Boolean;
//����ʶ��

procedure UpdateDoubleChannel(const nTunnel: PMultiJSTunnel);
//����ͨ����Ϣ

implementation

uses
  ULibFun, USysDB, USysLoger, UTaskMonitor, UFormCtrl;

const
  sPost_In   = 'in';
  sPost_Out  = 'out';

  sPost_SIn   = 'Sin';
  sPost_SOut  = 'Sout';
  sPost_PIn   = 'Pin';
  sPost_POut  = 'Pout';
  sPost_SW    = 'StartWaiting';
  sPost_EW    = 'EndWaiting';

//Date: 2014-09-15
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
function CallBusinessCommand(const nCmd: Integer;
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
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessCommand);
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

//Date: 2014-09-05
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessSaleBill(const nCmd: Integer;
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
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessSaleBill);
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

//Date: 2016-06-15
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessProvide(const nCmd: Integer;
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
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessProvide);
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

//Date: 2017-06-04
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessShipPro(const nCmd: Integer;
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
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessShipPro);
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

//Date: 2017-06-04
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessShipTmp(const nCmd: Integer;
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
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessShipTmp);
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

//Date: 2017-06-04
//Parm: ����;����;����;���
//Desc: �����м���ϵĻؿյ��ݶ���
function CallBusinessHaulBack(const nCmd: Integer;
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
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessHaulback);
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

//Date: 2014-10-16
//Parm: ����;����;����;���
//Desc: ����Ӳ���ػ��ϵ�ҵ�����
function CallHardwareCommand(const nCmd: Integer;
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
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_HardwareCommand);
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

//------------------------------------------------------------------------------
//Date: 2016-06-15
//Parm: �ſ���
//Desc: ��ȡ�ſ�ʹ������
function GetCardUsed(const nCard: string; var nCardType: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetCardUsed, nCard, '', @nOut);

  if Result then
       nCardType := nOut.FData
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

//Date: 2012-3-23
//Parm: �ſ���;��λ;�������б�
//Desc: ��ȡnPost��λ�ϴſ�ΪnCard�Ľ������б�
function GetLadingBills(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
end;

//Date: 2014-09-18
//Parm: ��λ;�������б�
//Desc: ����nPost��λ�ϵĽ���������
function SaveLadingBills(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessSaleBill(cBC_SavePostBills, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

function VerifyLadingBill(const nCard: string; const nDB: PDBWorker): Boolean;
var nSQL, nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  nSQL := 'Select * From %s Where B_Card=''%s''';
  nSQL := Format(nSQL, [sTable_BillNew, nCard]);

  with gDBConnManager.WorkerQuery(nDB, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nStr := '�ſ�[ %s ]�����Ķ����Ѷ�ʧ.';
      nStr := Format(nStr, [nCard]);
      gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
      Exit;
    end;

    if FieldByName('B_IsUsed').AsString = sFlag_No then
    begin
      nStr := FieldByName('B_ID').AsString;
      Result := CallBusinessSaleBill(cBC_SaveBillFromNew, nStr, '', @nOut);
    end else Result := True;
  end;
end;

//Date: 2016-06-15
//Parm: �ſ���;��λ;�ɹ��볧���б�
//Desc: ��ȡnPost��λ�ϴſ�ΪnCard�Ĳɹ��볧���б�
function GetProvideItems(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessProvide(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
end;

//Date: 2016-06-15
//Parm: ��λ;�ɹ��볧���б�
//Desc: ����nPost��λ�ϵĲɹ��볧������
function SaveProvideItems(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessProvide(cBC_SavePostBills, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

//Date: 2017-06-04
//Parm: ��λ;��ͷ�ɹ����б�
//Desc: ����nPost��λ�ϵĲɹ��볧������
function GetShipProItems(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessShipPro(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
end;

//Date: 2017-06-04
//Parm: ��λ;��ͷ�ɹ����б�
//Desc: ����nPost��λ�ϵĲɹ��볧������
function SaveShipProItems(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessShipPro(cBC_SavePostBills, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

//Date: 2017-06-04
//Parm: ��λ;��ͷ�ɹ����б�
//Desc: ����nPost��λ�ϵĲɹ��볧������
function GetShipTmpItems(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessShipTmp(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
end;

//Date: 2017-06-04
//Parm: ��λ;��ͷ�ɹ����б�
//Desc: ����nPost��λ�ϵĲɹ��볧������
function SaveShipTmpItems(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessShipTmp(cBC_SavePostBills, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

//Date: 2017-06-04
//Parm: ��λ;�ؿ�ҵ�񵥾��б�
//Desc: ����nPost��λ�ϵĻؿյ�����
function GetHaulBackItems(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessHaulBack(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
end;

//Date: 2017-06-04
//Parm: ��λ;��ͷ�ɹ����б�
//Desc: ����nPost��λ�ϵĲɹ��볧������
function SaveHaulBackItems(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessHaulBack(cBC_SavePostBills, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Date: 2013-07-21
//Parm: �¼�����;��λ��ʶ
//Desc:
procedure WriteHardHelperLog(const nEvent: string; nPost: string = '');
begin
  gDisplayManager.Display(nPost, nEvent);
  gSysLoger.AddLog(THardwareHelper, 'Ӳ���ػ�����', nEvent);
end;

//Date: 2018-03-28
//Parm: ��λ
//Desc: ��ѯDICT�����λ�Ƿ��䱸������
function GetHasVoice(const nPost: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBConn: PDBWorker;
begin
  Result := False;
  nDBConn := nil;
  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nIdx);
    if not Assigned(nDBConn) then
    begin
      WriteHardHelperLog('����HM���ݿ�ʧ��(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nStr := 'Select * From %s Where D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, nPost]);

    with gDBConnManager.WorkerQuery(nDBConn, nStr) do
    if RecordCount > 0 then
    begin
      if FieldByName('D_ParamB').AsString = sFlag_Yes then
        Result := True;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

//Date: 2017-10-16
//Parm: ����;��λ;ҵ��ɹ�
//Desc: �����Ÿ�����
procedure MakeGateSound(const nText,nPost: string; const nSucc: Boolean);
var nStr: string;
    nInt: Integer;
begin
  try
    if nSucc then
         nInt := 2
    else nInt := 3;

    gHKSnapHelper.Display(nPost, nText, nInt);
    //С����ʾ

    if GetHasVoice(nPost) then
      gNetVoiceHelper.PlayVoice(nText, nPost);
    //��������
    WriteHardHelperLog(nText);
  except
    on nErr: Exception do
    begin
      nStr := '����[ %s ]����ʧ��,����: %s';
      nStr := Format(nStr, [nPost, nErr.Message]);
      WriteHardHelperLog(nStr);
    end;
  end;
end;

//Date: 2012-4-22
//Parm: ����
//Desc: ��nCard���н���
procedure MakeTruckIn(const nCard,nReader,nPost,nDept: string; const nDB: PDBWorker);
var nStr,nTruck,nCardType,nSnapStr,nPos: string;
    nIdx,nInt: Integer;
    nPLine: PLineItem;
    nRet: Boolean;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;
begin
  if not GetCardUsed(nCard, nCardType) then nCardType := sFlag_Sale;

  if nPost = '' then
    nPos := sPost_SIn
  else
    nPos := nPost;

  if gTruckQueueManager.IsTruckAutoIn(nCardType=sFlag_Sale) and (GetTickCount -
     gHardwareHelper.GetCardLastDone(nCard, nReader) < 2 * 60 * 1000) then
  begin
    gHardwareHelper.SetReaderCard(nReader, nCard);
    {$IFDEF FORCEOPENDOOR}
    HardOpenDoor(nReader);
    {$ENDIF}
    Exit;
  end; //ͬ��ͷͬ��,��2�����ڲ������ν���ҵ��.

  if nCardType = sFlag_SaleNew then
  if not VerifyLadingBill(nCard, nDB) then Exit;
  //����״�ˢ������������ϸ

  nRet := False;
  if (nCardType = sFlag_Sale) or (nCardType = sFlag_SaleNew) then
    nRet := GetLadingBills(nCard, sFlag_TruckIn, nTrucks) else
  if nCardType = sFlag_Provide then
    nRet := GetProvideItems(nCard, sFlag_TruckIn, nTrucks) else
  if nCardType = sFlag_ShipPro then
    nRet := GetShipProItems(nCard, sFlag_TruckIn, nTrucks) else
  if nCardType = sFlag_ShipTmp then
    nRet := GetShipTmpItems(nCard, sFlag_TruckIn, nTrucks) else
  if nCardType = sFlag_HaulBack then
    nRet := GetHaulBackItems(nCard, sFlag_TruckIn, nTrucks);

  if not nRet then
  begin
    if gTruckQueueManager.IsTruckAutoIn(nCardType=sFlag_Sale) then
      gHardwareHelper.SetReaderCard(nReader, nCard);
    //��ȡ������Ƭ��Ϣ

    nStr := '��ȡ�ſ�[ %s ]������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_In);

    {$IFDEF RemoteSnap}
    nStr := '��ȡ�ſ���Ϣʧ��';
    MakeGateSound(nStr, nPos, False);
    {$ENDIF}

    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫ��������.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_In);

    {$IFDEF RemoteSnap}
    nStr := '���ȵ���Ʊ�Ұ���ҵ��';
    MakeGateSound(nStr, nPos, False);
    {$ENDIF}

    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    FCardUse := nCardType;
    if (FStatus = sFlag_TruckNone) or (FStatus = sFlag_TruckIn) then Continue;
    //δ����,���ѽ���

    nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],����ˢ����Ч.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);

    if gTruckQueueManager.IsTruckAutoIn(nCardType=sFlag_Sale) then
      gHardwareHelper.SetReaderCard(nReader, nCard);
    //��ǰ�ǽ���״̬

    WriteHardHelperLog(nStr, sPost_In);

    {$IFDEF RemoteSnap}
    nStr := '����[ %s ]���ܽ���,Ӧ��ȥ[ %s ]';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
    MakeGateSound(nStr, nPos, False);
    {$ENDIF}
    Exit;
  end;

  {$IFDEF RemoteSnap}
  if nTrucks[0].FSnapTruck then
  if not VerifySnapTruck(nTrucks[0].FTruck,nTrucks[0].FID,nPos,nDept,nSnapStr) then
  begin
    MakeGateSound(nSnapStr, nPos, False);
    Exit;
  end;
  nStr := nSnapStr + ',�����';
  MakeGateSound(nStr, nPos, True);
  {$ENDIF}

  if nTrucks[0].FStatus = sFlag_TruckIn then
  begin
    if gTruckQueueManager.IsTruckAutoIn(nCardType=sFlag_Sale) then
    begin
      gHardwareHelper.SetCardLastDone(nCard, nReader);
      gHardwareHelper.SetReaderCard(nReader, nCard);
      {$IFDEF FORCEOPENDOOR}
      HardOpenDoor(nReader);
      {$ENDIF}
    end else
    begin
      if gTruckQueueManager.TruckReInfactFobidden(nTrucks[0].FTruck) then
      begin
        HardOpenDoor(nReader);
        //̧��

        nStr := '����[ %s ]�ٴ�̧�˲���.';
        nStr := Format(nStr, [nTrucks[0].FTruck]);
        WriteHardHelperLog(nStr, sPost_In);
      end;
    end;

    Exit;
  end;

  //----------------------------------------------------------------------------
  if (nCardType <> sFlag_Sale) and (nCardType <> sFlag_SaleNew) then            //������ҵ��,��ʹ�ö���
  begin
    if nCardType = sFlag_Provide then
      nRet := SaveProvideItems(sFlag_TruckIn, nTrucks)  else
    if nCardType = sFlag_ShipPro then
      nRet := SaveShipProItems(sFlag_TruckIn, nTrucks)  else
    if nCardType = sFlag_ShipTmp then
      nRet := SaveShipTmpItems(sFlag_TruckIn, nTrucks) else
  if nCardType = sFlag_HaulBack then
    nRet := SaveHaulBackItems(sFlag_TruckIn, nTrucks);

    if not nRet then
    begin
      nStr := '����[ %s ]��������ʧ��.';
      nStr := Format(nStr, [nTrucks[0].FTruck]);

      WriteHardHelperLog(nStr, sPost_In);
      Exit;
    end;

    if gTruckQueueManager.IsTruckAutoIn(nCardType=sFlag_Sale) then
    begin
      gHardwareHelper.SetCardLastDone(nCard, nReader);
      gHardwareHelper.SetReaderCard(nReader, nCard);
      {$IFDEF FORCEOPENDOOR}
      HardOpenDoor(nReader);
      {$ENDIF}
    end else
    begin
      HardOpenDoor(nReader);
      //̧��
    end;

    nStr := '%s�ſ�[%s]����̧�˳ɹ�';
    nStr := Format(nStr, [BusinessToStr(nCardType), nCard]);
    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  //----------------------------------------------------------------------------
  nPLine := nil;
  //nPTruck := nil;

  with gTruckQueueManager do
  if not IsDelayQueue then //����ʱ����(����ģʽ)
  try
    SyncLock.Enter;
    nStr := nTrucks[0].FTruck;

    for nIdx:=Lines.Count - 1 downto 0 do
    begin
      nInt := TruckInLine(nStr, PLineItem(Lines[nIdx]).FTrucks);
      if nInt >= 0 then
      begin
        nPLine := Lines[nIdx];
        //nPTruck := nPLine.FTrucks[nInt];
        Break;
      end;
    end;

    if not Assigned(nPLine) then
    begin
      nStr := '����[ %s ]û���ڵ��ȶ�����.';
      nStr := Format(nStr, [nTrucks[0].FTruck]);

      WriteHardHelperLog(nStr, sPost_In);
      Exit;
    end;
  finally
    SyncLock.Leave;
  end;

  if not SaveLadingBills(sFlag_TruckIn, nTrucks) then
  begin
    nStr := '����[ %s ]��������ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  if gTruckQueueManager.IsTruckAutoIn(nCardType=sFlag_Sale) then
  begin
    gHardwareHelper.SetCardLastDone(nCard, nReader);
    gHardwareHelper.SetReaderCard(nReader, nCard);
    {$IFDEF FORCEOPENDOOR}
    HardOpenDoor(nReader);
    {$ENDIF}
  end else
  begin
    HardOpenDoor(nReader);
    //̧��
  end;

  with gTruckQueueManager do
  if not IsDelayQueue then //����ģʽ,����ʱ�󶨵���(һ���൥)
  try
    SyncLock.Enter;
    nTruck := nTrucks[0].FTruck;

    for nIdx:=Lines.Count - 1 downto 0 do
    begin
      nPLine := Lines[nIdx];
      nInt := TruckInLine(nTruck, PLineItem(Lines[nIdx]).FTrucks);

      if nInt < 0 then Continue;
      nPTruck := nPLine.FTrucks[nInt];

      if nPTruck.FQueueStock = '' then
      begin
        nStr := 'Update %s Set T_Line=''%s'',T_PeerWeight=%d Where T_Bill=''%s''';
        nStr := Format(nStr, [sTable_ZTTrucks, nPLine.FLineID, nPLine.FPeerWeight,
                nPTruck.FBill]);
        //xxxxx
      end else
      begin
        nStr := 'Update %s Set T_Line=''%s'',T_PeerWeight=%d Where T_Bill In (%s)';
        nStr := Format(nStr, [sTable_ZTTrucks, nPLine.FLineID, nPLine.FPeerWeight,
                nPTruck.FQueueBills]);
        //��Ʒ�����ȼ��Ŷ�ʱ,һ����Ӧ���Ž�����
      end;

      gDBConnManager.WorkerExec(nDB, nStr);
      //��ͨ��
    end;
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2012-4-22
//Parm: ����;��ͷ;��ӡ��;���Ӳ���
//Desc: ��nCard���г���
procedure MakeTruckOut(const nCard,nReader,nPrinter,nPost,nDept: string;
 const nOptions: string = '');
var nStr, nCardType,nPrint,nID,nSnapStr,nPos: string;
    nIdx: Integer;
    nRet: Boolean;
    nReaderItem: THHReaderItem;
    nTrucks: TLadingBillItems;
    {$IFDEF PrintBillMoney}
    nOut: TWorkerBusinessCommand;
    {$ENDIF}
begin
  if not GetCardUsed(nCard, nCardType) then nCardType := sFlag_Sale;

  if nPost = '' then
    nPos := sPost_SIn
  else
    nPos := nPost;

  nRet := False;
  if (nCardType = sFlag_Sale) or (nCardType = sFlag_SaleNew) then
    nRet := GetLadingBills(nCard, sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_Provide then
    nRet := GetProvideItems(nCard, sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_ShipPro then
    nRet := GetShipProItems(nCard, sFlag_TruckOut, nTrucks)  else
  if nCardType = sFlag_ShipTmp then
    nRet := GetShipTmpItems(nCard, sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_HaulBack then
    nRet := GetHaulBackItems(nCard, sFlag_TruckOut, nTrucks);
  //xxxxx

  if not nRet then
  begin
    nStr := '��ȡ�ſ�[ %s ]��������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_Out);

    {$IFDEF RemoteSnap}
    nStr := '��ȡ�ſ���Ϣʧ��';
    MakeGateSound(nStr, nPos, False);
    {$ENDIF}

    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫ��������.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_Out);

    {$IFDEF RemoteSnap}
    nStr := 'û����Ҫ��������';
    MakeGateSound(nStr, nPos, False);
    {$ENDIF}

    Exit;
  end;

  {$IFDEF NoShipTruckOut}
  if nTrucks[0].FIsVIP = sFlag_TypeShip then
  begin
    nStr := '����[ %s ]���Ÿڳ���ҵ����Ч.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;
  {$ENDIF}

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    FCardUse := nCardType;
    if FNextStatus = sFlag_TruckOut then Continue;
    nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],�޷�����.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);

    WriteHardHelperLog(nStr, sPost_Out);

    {$IFDEF RemoteSnap}
    nStr := '����[ %s ]���ܳ���,Ӧ��ȥ[ %s ]';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
    MakeGateSound(nStr, nPos, False);
    {$ENDIF}

    Exit;
  end;

  nRet := False;
  if (nCardType = sFlag_Sale) or (nCardType = sFlag_SaleNew) then
    nRet := SaveLadingBills(sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_Provide then
    nRet := SaveProvideItems(sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_ShipPro then
    nRet := SaveShipProItems(sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_ShipTmp then
    nRet := SaveShipTmpItems(sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_HaulBack then
    nRet := SaveHaulBackItems(sFlag_TruckOut, nTrucks);
  //xxxxx

  if not nRet then
  begin
    nStr := '����[ %s ]��������ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr, sPost_Out);

    {$IFDEF RemoteSnap}
    nStr := '����[ %s ]��������ʧ��';
    nStr := Format(nStr, [nTrucks[0].FTruck]);
    MakeGateSound(nStr, nPos, False);
    {$ENDIF}

    Exit;
  end;

  {$IFDEF RemoteSnap}
  if nTrucks[0].FSnapTruck then
  if not VerifySnapTruck(nTrucks[0].FTruck,nTrucks[0].FID,nPos,nDept,nSnapStr) then
  begin
    MakeGateSound(nSnapStr, nPos, False);
    Exit;
  end;
  nStr := nSnapStr + ',�����';
  MakeGateSound(nStr, nPos, True);
  {$ENDIF}


  if (nReader <> '') and (Pos('nodoor', LowerCase(nOptions)) < 1) then
    HardOpenDoor(nReader);
  //̧��

  nStr := '����%s�ѳ���';
  nStr := Format(nStr, [nTrucks[0].FTruck]);
  gDisplayManager.Display(nReader, nStr);
  //LED��ʾ

  {$IFDEF CombinePrintBill}
  //����β���ϵ���ϲ���ӡ,ֻ�������ɢװ
  if ((nCardType = sFlag_Sale) or (nCardType = sFlag_SaleNew)) and
     (nTrucks[0].FType = sFlag_San) then
  begin
    nID := '';
    for nIdx:=Low(nTrucks) to High(nTrucks) do
    begin
      nID := nID + '''' + nTrucks[nIdx].FID + '''';
      if nIdx <> High(nTrucks) then
        nID := nID + ',';
      //split flag
    end;

    nStr := #7 + nCardType;
    //�ſ�����

    if nPrinter = '' then
    begin
      gHardwareHelper.GetReaderLastOn(nCard, nReaderItem);
      nPrint := nReaderItem.FPrinter;
    end else nPrint := nPrinter;

    if nPrint = '' then
         nStr := nID + nStr
    else nStr := nID + #9 + nPrint + nStr;

    gRemotePrinter.PrintBill(nStr);
    Exit;
  end;
  {$ENDIF}

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  begin
    {$IFDEF HKVDVR}
    gCameraManager.CapturePicture(nReader, nTrucks[nIdx].FID);
    //ץ��
    {$ENDIF}

    {$IFDEF PrintBillMoney}
    if CallBusinessCommand(cBC_GetZhiKaMoney,nTrucks[nIdx].FZhiKa,'',@nOut) then
         nStr := #8 + nOut.FData
    else nStr := #8 + '0';
    {$ELSE}
    nStr := '';
    {$ENDIF}

    nStr := nStr + #7 + nCardType;
    //�ſ�����

    if nPrinter = '' then
    begin
      gHardwareHelper.GetReaderLastOn(nCard, nReaderItem);
      nPrint := nReaderItem.FPrinter;
    end else nPrint := nPrinter;

    if (nCardType = sFlag_ShipPro) or (nCardType = sFlag_ShipTmp) or
       (nCardType = sFlag_HaulBack)
    then
         nID := nTrucks[nIdx].FPoundID
    else nID := nTrucks[nIdx].FID;

    if nPrint = '' then
         nStr := nID + nStr
    else nStr := nID + #9 + nPrint + nStr;

    gRemotePrinter.PrintBill(nStr);
  end; //��ӡ����
end;

//Date: 2016-5-4
//Parm: ����;��ͷ;��ӡ��
//Desc: ��nCard���г�
function MakeTruckOutM100(const nCard,nReader,nPrinter,
                          nPost,nDept: string): Boolean;
var nStr,nCardType, nID,nSnapStr,nPos: string;
    nIdx: Integer;
    nRet: Boolean;
    nTrucks: TLadingBillItems;
    {$IFDEF PrintBillMoney}
    nOut: TWorkerBusinessCommand;
    {$ENDIF}
begin
  Result := False;
  if not GetCardUsed(nCard, nCardType) then nCardType := sFlag_Sale;

  if nPost = '' then
    nPos := sPost_SIn
  else
    nPos := nPost;

  nRet := False;
  if (nCardType = sFlag_Sale) or (nCardType = sFlag_SaleNew) then
    nRet := GetLadingBills(nCard, sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_Provide then
    nRet := GetProvideItems(nCard, sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_ShipPro then
    nRet := GetShipProItems(nCard, sFlag_TruckOut, nTrucks)  else
  if nCardType = sFlag_ShipTmp then
    nRet := GetShipTmpItems(nCard, sFlag_TruckOut, nTrucks)  else
  if nCardType = sFlag_HaulBack then
    nRet := GetHaulBackItems(nCard, sFlag_TruckOut, nTrucks);
  //xxxxx

  if not nRet then
  begin
    nStr := '��ȡ�ſ�[ %s ]������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);
    Result := True;
    //�ſ�����Ч

    WriteHardHelperLog(nStr, sPost_Out);

    {$IFDEF RemoteSnap}
    nStr := '��ȡ�ſ���Ϣʧ��';
    MakeGateSound(nStr, nPos, False);
    {$ENDIF}

    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫ��������.';
    nStr := Format(nStr, [nCard]);
    Result := True;
    //�ſ�����Ч

    WriteHardHelperLog(nStr, sPost_Out);

    {$IFDEF RemoteSnap}
    nStr := 'û����Ҫ��������';
    MakeGateSound(nStr, nPos, False);
    {$ENDIF}

    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if FNextStatus = sFlag_TruckOut then Continue;
    nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],�޷�����.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);

    WriteHardHelperLog(nStr, sPost_Out);

    {$IFDEF RemoteSnap}
    nStr := '����[ %s ]���ܳ���,Ӧ��ȥ[ %s ]';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
    MakeGateSound(nStr, nPos, False);
    {$ENDIF}

    Exit;
  end;

  nRet := False;
  if (nCardType = sFlag_Sale) or (nCardType = sFlag_SaleNew) then
    nRet := SaveLadingBills(sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_Provide then
    nRet := SaveProvideItems(sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_ShipPro then
    nRet := SaveShipProItems(sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_ShipTmp then
    nRet := SaveShipTmpItems(sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_HaulBack then
    nRet := SaveHaulBackItems(sFlag_TruckOut, nTrucks);

  if not nRet then
  begin
    nStr := '����[ %s ]��������ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr, sPost_Out);

    {$IFDEF RemoteSnap}
    nStr := '����[ %s ]��������ʧ��';
    nStr := Format(nStr, [nTrucks[0].FTruck]);
    MakeGateSound(nStr, nPos, False);
    {$ENDIF}

    Exit;
  end;

  {$IFDEF RemoteSnap}
  if nTrucks[0].FSnapTruck then
  if not VerifySnapTruck(nTrucks[0].FTruck,nTrucks[0].FID,nPos,nDept,nSnapStr) then
  begin
    MakeGateSound(nSnapStr, nPos, False);
    Exit;
  end;
  nStr := nSnapStr + ',�����';
  MakeGateSound(nStr, nPos, True);
  {$ENDIF}

  HardOpenDoor(nReader);
  //̧��

  nStr := '����%s�ѳ���';
  nStr := Format(nStr, [nTrucks[0].FTruck]);
  gDisplayManager.Display(nReader, nStr);
  //LED��ʾ

  {$IFDEF CombinePrintBill}
  //����β���ϵ���ϲ���ӡ,ֻ�������ɢװ
  if ((nCardType = sFlag_Sale) or (nCardType = sFlag_SaleNew)) and
     (nTrucks[0].FType = sFlag_San) then
  begin
    nID := '';
    for nIdx:=Low(nTrucks) to High(nTrucks) do
    begin
      nID := nID + '''' + nTrucks[nIdx].FID + '''';
      if nIdx <> High(nTrucks) then
        nID := nID + ',';
      //split flag
    end;

    nStr := #7 + nCardType;
    //�ſ�����

    if nPrinter = '' then
         nStr := nID + nStr
    else nStr := nID + #9 + nPrinter + nStr;

    gRemotePrinter.PrintBill(nStr);
  if (nTrucks[0].FCardKeep = sFlag_Yes) or
     (nTrucks[0].FCardKeep = sFlag_ProvCardG) then Exit;
    //���ڿ�,���̿�

    Result := True;
    Exit;
  end;
  {$ENDIF}

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  begin
    {$IFDEF HKVDVR}
    gCameraManager.CapturePicture(nReader, nTrucks[nIdx].FID);
    //ץ��
    {$ENDIF}

    {$IFDEF PrintBillMoney}
    if CallBusinessCommand(cBC_GetZhiKaMoney,nTrucks[nIdx].FZhiKa,'',@nOut) then
         nStr := #8 + nOut.FData
    else nStr := #8 + '0';
    {$ELSE}
    nStr := '';
    {$ENDIF}

    nStr := nStr + #7 + nCardType;
    //�ſ�����

    if (nCardType = sFlag_ShipPro) or (nCardType = sFlag_ShipTmp) or
       (nCardType = sFlag_HaulBack) then
         nID := nTrucks[nIdx].FPoundID
    else nID := nTrucks[nIdx].FID;

    if nPrinter = '' then
         nStr := nID + nStr
    else nStr := nID + #9 + nPrinter + nStr;

    gRemotePrinter.PrintBill(nStr);
  end; //��ӡ����

  if (nTrucks[0].FCardKeep = sFlag_Yes) or
     (nTrucks[0].FCardKeep = sFlag_ProvCardG) then Exit;
  //���ڿ�,���̿�

  Result := True;
end;

//Date: 2012-10-19
//Parm: ����;��ͷ
//Desc: ��⳵���Ƿ��ڶ�����,�����Ƿ�̧��
procedure MakeTruckPassGate(const nCard,nReader: string; const nDB: PDBWorker);
var nStr: string;
    nIdx: Integer;
    nTrucks: TLadingBillItems;
begin
  if not GetLadingBills(nCard, sFlag_TruckOut, nTrucks) then
  begin
    nStr := '��ȡ�ſ�[ %s ]��������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫͨ����բ�ĳ���.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  if gTruckQueueManager.TruckInQueue(nTrucks[0].FTruck) < 0 then
  begin
    nStr := '����[ %s ]���ڶ���,��ֹͨ����բ.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  HardOpenDoor(nReader);
  //̧��

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  begin
    nStr := 'Update %s Set T_InLade=%s Where T_Bill=''%s'' And T_InLade Is Null';
    nStr := Format(nStr, [sTable_ZTTrucks, sField_SQLServer_Now, nTrucks[nIdx].FID]);

    gDBConnManager.WorkerExec(nDB, nStr);
    //�������ʱ��,�������򽫲��ٽк�.
  end;
end;

//Date: 2018-08-06
//Parm: ����;��ͷ
//Desc: ��¼����ˢ��ʱ�������ȴ���̧��
procedure MakeTruckCross(const nCard,nReader,nPost, nMemo: string; const nDB: PDBWorker;
                                const nStart: TDateTime; const nKeep: Integer);
var nStr: string;
    nIdx: Integer;
begin
  nStr := '�ſ�[ %s ]��ʼ�ȴ�ʱ��[ %s ],��ǰʱ��[ %s ],��ǰˢ��״̬[ %s ].';
  nStr := Format(nStr, [nCard, FormatDateTime('YYYY-MM-DD HH:MM:SS', nStart),
                               FormatDateTime('YYYY-MM-DD HH:MM:SS', Now),nMemo]);

  WriteHardHelperLog(nStr);
  if MinutesBetween(Now, nStart) < nKeep then
  begin
    nStr := '�ſ�[ %s ]ˢ���������,��ȴ�.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  if nPost = sPost_SW then
  begin
    nStr := 'Update %s Set C_Date=%s, C_Memo=''%s'' Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, sField_SQLServer_Now, sPost_SW, nCard]);

    gDBConnManager.WorkerExec(nDB, nStr);
  end
  else
  if nPost = sPost_EW then
  begin
    if nMemo = sPost_SW then//���ڵȴ���ˢ��
    begin
      nStr := 'Update %s Set C_Memo=''%s'' Where C_Card=''%s''';
      nStr := Format(nStr, [sTable_Card, sPost_EW, nCard]);

      gDBConnManager.WorkerExec(nDB, nStr);
      HardOpenDoor(nReader);
      //̧��
    end
    else
    begin
      nStr := '�ſ�[ %s ]δ��[ %s ]ˢ��,�޷�����.';
      nStr := Format(nStr, [nCard, sPost_SW]);

      WriteHardHelperLog(nStr);
    end;
  end
end;

//Date: 2012-4-22
//Parm: ��ͷ����
//Desc: ��nReader�����Ŀ��������嶯��
procedure WhenReaderCardArrived(const nReader: THHReaderItem);
var nStr, nGroup, nMemo: string;
    nErrNum: Integer;
    nDBConn: PDBWorker;
    nStart: TDateTime;
begin
  nDBConn := nil;
  {$IFDEF DEBUG}
  WriteHardHelperLog('WhenReaderCardArrived����.');
  {$ENDIF}

  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
    if not Assigned(nDBConn) then
    begin
      WriteHardHelperLog('����HM���ݿ�ʧ��(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nStr := 'Select C_Card,C_Group,C_Date,C_Memo From $TB Where C_Card=''$CD'' or ' +
            'C_Card2=''$CD'' or C_Card3=''$CD''';
    nStr := MacroValue(nStr, [MI('$TB', sTable_Card), MI('$CD', nReader.FCard)]);

    with gDBConnManager.WorkerQuery(nDBConn, nStr) do
    if RecordCount > 0 then
    begin
      nStr := Fields[0].AsString;
      nGroup := UpperCase(Fields[1].AsString);
      nStart := Fields[2].AsDateTime;
      nMemo := Fields[3].AsString;
    end else
    begin
      nStr := Format('�ſ���[ %s ]ƥ��ʧ��.', [nReader.FCard]);
      WriteHardHelperLog(nStr);
      Exit;
    end;

    if (nReader.FGroup <> '') and (UpperCase(nReader.FGroup) <> nGroup) then
    begin
      nStr := Format('�ſ���[ %s:::%s ]�������[ %s:::%s ]����ƥ��ʧ��.',
              [nReader.FCard, nGroup, nReader.FID, nReader.FGroup]);
      WriteHardHelperLog(nStr);
      Exit;
    end;
    //�����������뿨Ƭ���鲻ƥ��

    try
      if nReader.FType = rtIn then
      begin
        MakeTruckIn(nStr, nReader.FID, nReader.FPost, nReader.FDept, nDBConn);
      end else

      if nReader.FType = rtOut then
      begin
        MakeTruckOut(nStr, nReader.FID, nReader.FPrinter,
                     nReader.FPost, nReader.FDept, nReader.FPound);
      end else

      if nReader.FType = rtGate then
      begin
        if (nReader.FPost = sPost_SW) or (nReader.FPost = sPost_EW) then
        begin
          MakeTruckCross(nStr, nReader.FID, nReader.FPost, nMemo, nDBConn,
                         nStart, nReader.FKeep);
        end
        else
        begin
          if nReader.FID <> '' then
            HardOpenDoor(nReader.FID);
          //̧��
        end;
      end else

      if nReader.FType = rtQueueGate then
      begin
        if nReader.FID <> '' then
          MakeTruckPassGate(nStr, nReader.FID, nDBConn);
        //̧��
      end;
    except
      On E:Exception do
      begin
        WriteHardHelperLog(E.Message);
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

//------------------------------------------------------------------------------
procedure WriteNearReaderLog(const nEvent: string);
begin
  gSysLoger.AddLog(T02NReader, '�ֳ����������', nEvent);
end;

//Date: 2012-4-24
//Parm: ����;ͨ��;�Ƿ����Ⱥ�˳��;��ʾ��Ϣ
//Desc: ���nTuck�Ƿ������nTunnelװ��
function IsTruckInQueue(const nTruck,nTunnel: string; const nQueued: Boolean;
 var nHint: string; var nPTruck: PTruckItem; var nPLine: PLineItem;
 const nStockType: string = ''): Boolean;
var i,nIdx,nInt: Integer;
    nLineItem: PLineItem;
    nEarlyTruck: PTruckItem;
begin
  with gTruckQueueManager do
  try
    Result := False;
    SyncLock.Enter;
    nIdx := GetLine(nTunnel);

    if nIdx < 0 then
    begin
      nHint := Format('ͨ��[ %s ]��Ч.', [nTunnel]);
      Exit;
    end;

    nPLine := Lines[nIdx];
    nIdx := TruckInLine(nTruck, nPLine.FTrucks);

    if (nIdx < 0) and (nStockType <> '') and (
       ((nStockType = sFlag_Dai) and IsDaiQueueClosed) or
       ((nStockType = sFlag_San) and IsSanQueueClosed)) then
    begin
      for i:=Lines.Count - 1 downto 0 do
      begin
        if Lines[i] = nPLine then Continue;
        nLineItem := Lines[i];
        nInt := TruckInLine(nTruck, nLineItem.FTrucks);

        if nInt < 0 then Continue;
        //���ڵ�ǰ����
        if not StockMatch(nPLine.FStockNo, nLineItem) then Continue;
        //ˢ��������е�Ʒ�ֲ�ƥ��

        nIdx := nPLine.FTrucks.Add(nLineItem.FTrucks[nInt]);
        nLineItem.FTrucks.Delete(nInt);
        //Ų���������µ�

        nHint := 'Update %s Set T_Line=''%s'' ' +
                 'Where T_Truck=''%s'' And T_Line=''%s''';
        nHint := Format(nHint, [sTable_ZTTrucks, nPLine.FLineID, nTruck,
                nLineItem.FLineID]);
        gTruckQueueManager.AddExecuteSQL(nHint);

        nHint := '����[ %s ]��������[ %s->%s ]';
        nHint := Format(nHint, [nTruck, nLineItem.FName, nPLine.FName]);
        WriteNearReaderLog(nHint);
        Break;
      end;
    end;
    //��װ�ص�����

    if nIdx < 0 then
    begin
      nHint := Format('����[ %s ]����[ %s ]������.', [nTruck, nPLine.FName]);
      Exit;
    end;

    nPTruck := nPLine.FTrucks[nIdx];
    nPTruck.FStockName := nPLine.FName;
    //ͬ��������

    Result := True;
    if (not nQueued) or (nIdx < 1) then Exit;
    //��������,��ͷ��

    //--------------------------------------------------------------------------
    if nQueued then
    begin
      WriteNearReaderLog('��ʼ������..');
      if nIdx >= 1 then
      begin
        nEarlyTruck := nPLine.FTrucks[nIdx - 1];
        if nEarlyTruck.FInLade then
        begin
          nHint := '����[ %s ]����λ��Ϊ[ %d ],����װ��.';
          nHint := Format(nHint, [nPTruck.FTruck, nIdx + 1]);

          Exit;
        end
        else
        begin
          nHint := '����[ %s ]����λ��Ϊ[ %d ],��Ҫ��[ %s ]�ŶӵȺ�.';
          nHint := Format(nHint, [nPTruck.FTruck, nIdx + 1, nPLine.FName]);

          Result := False;
          Exit;
        end;
      end;
    end;

    nInt := -1;
    //init

    for i:=nPline.FTrucks.Count-1 downto 0 do
    if PTruckItem(nPLine.FTrucks[i]).FStarted then
    begin
      nInt := i;
      Break;
    end;
    if nInt < 0 then Exit;
    //û����װ������,�����Ŷ�

    if nIdx - nInt <> 1 then
    begin
      nHint := '����[ %s ]��Ҫ��[ %s ]�ŶӵȺ�.';
      nHint := Format(nHint, [nPTruck.FTruck, nPLine.FName]);

      Result := False;
      Exit;
    end;
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2013-1-21
//Parm: ͨ����;������;
//Desc: ��nTunnel�ϴ�ӡnBill��α��
function PrintBillCode(const nTunnel,nBill: string; var nHint: string): Boolean;
var nStr: string;
    nTask: Int64;
    nOut: TWorkerBusinessCommand;
begin
  Result := True;
  if not (gMultiJSManager.CountEnable and gMultiJSManager.ChainEnable) then Exit;

  nTask := gTaskMonitor.AddTask('UHardBusiness.PrintBillCode', cTaskTimeoutLong);
  //to mon
  
  if not CallHardwareCommand(cBC_PrintCode, nBill, nTunnel, @nOut) then
  begin
    nStr := '��ͨ��[ %s ]���ͷ�Υ����ʧ��,����: %s';
    nStr := Format(nStr, [nTunnel, nOut.FData]);  
    WriteNearReaderLog(nStr);
  end;

  gTaskMonitor.DelTask(nTask, True);
  //task done
end;

//Date: 2017-08-13
//Parm: ��������;����
//Desc: ��ȡ�������ɷ�������
function BillValue2Dai(const nBill: string; const nPeer: Integer): Integer;
var nStr,nBills: string;
    nWorker: PDBWorker;
begin
  Result := 0;
  if nPeer < 1 then Exit;
  nBills := '';
  
  nWorker := nil;
  try
    nStr := 'Select T_Value,T_HKBills From %s Where T_HKBills Like ''%%%s%%''';
    nStr := Format(nStr, [sTable_ZTTrucks, nBill]);

    with gDBConnManager.SQLQuery(nStr, nWorker) do
    begin
      if RecordCount < 1 then
      begin
        nStr := '��ȡ����ʧ��,������[ %s ]������.';
        nStr := Format(nStr, [nBill]);
        WriteNearReaderLog(nStr);
      end;

      Result := Trunc(Fields[0].AsFloat * 1000 / nPeer);
      nBills := AdjustListStrFormat(Fields[1].AsString, '''', True, '.');
      nBills := StringReplace(nBills, '.', ',', [rfReplaceAll]);
    end;

    if (nBill = '') or (Pos(',', nBills) < 1) then Exit;
    //���Ž�����,���账��

    nStr := 'Select L_ID,L_Value,L_StockNo From %s Where L_ID In (%s)';
    nStr := Format(nStr, [sTable_Bill, nBills]);

    with gDBConnManager.WorkerQuery(nWorker, nStr) do
    if RecordCount > 0 then
    begin
      First;
      nStr := Fields[2].AsString;

      while not Eof do
      begin
        if Fields[2].AsString <> nStr then
        begin
          nStr := '';
          Break;
        end; //Ʒ�ֲ�һ��

        Next;
      end;

      if nStr <> '' then Exit;
      //Ʒ��һ��,ʹ�ò�������

      First;
      while not Eof do
      begin
        if Fields[0].AsString = nBill then
        begin
          Result := Trunc(Fields[1].AsFloat * 1000 / nPeer);
          Exit;
        end; //Ʒ�ֲ�һ��ʱ,ʹ�ÿ�����

        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;

//Date: 2012-4-24
//Parm: ����;ͨ��;������;��������
//Desc: ����nTunnel�ĳ�������������
function TruckStartJS(const nTruck,nTunnel,nBill: string;
  var nHint: string; const nAddJS: Boolean = True): Boolean;
var nIdx: Integer;
    nTask: Int64;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
begin
  with gTruckQueueManager do
  try
    Result := False;
    SyncLock.Enter;
    nIdx := GetLine(nTunnel);

    if nIdx < 0 then
    begin
      nHint := Format('ͨ��[ %s ]��Ч.', [nTunnel]);
      Exit;
    end;

    nPLine := Lines[nIdx];
    nIdx := TruckInLine(nTruck, nPLine.FTrucks);

    if nIdx < 0 then
    begin
      nHint := Format('����[ %s ]�Ѳ��ٶ���.', [nTruck]);
      Exit;
    end;

    Result := True;
    nPTruck := nPLine.FTrucks[nIdx];

    for nIdx:=nPLine.FTrucks.Count - 1 downto 0 do
      PTruckItem(nPLine.FTrucks[nIdx]).FStarted := False;
    nPTruck.FStarted := True;

    if PrintBillCode(nTunnel, nBill, nHint) and nAddJS then
    begin
      nTask := gTaskMonitor.AddTask('UHardBusiness.AddJS', cTaskTimeoutLong);
      //to mon
                   
      {$IFDEF StockPriorityInQueue}
      nIdx := BillValue2Dai(nBill, nPLine.FPeerWeight);
      //��Ʒ�����ȼ��Ŷ�ʱ,��ǰװ���Ĵ��������ǲ�ͬƷ��ƴ��,�����¼���.
      {$ELSE}
      nIdx := nPTruck.FDai;
      {$ENDIF}

      gMultiJSManager.AddJS(nTunnel, nTruck, nBill, nIdx, True);
      gTaskMonitor.DelTask(nTask);
    end;
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2017-12-07
//Parm: ����;ͨ��;������;��������
//lih: ����nTunnel�ĳ�������������
function TruckStartJSDouble(const nTruck,nTunnel,nMutexTunnel,nBill,nStockName: string;
  var nHint: string; const nAddJS: Boolean = True): Boolean;
var nIdx: Integer;
    nTask: Int64;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nStr: string;
    
    function IsMutexJSRun: Boolean;
    begin
      Result := False;
      if nMutexTunnel = '' then Exit;
      Result := gMultiJSManager.IsJSRun(nMutexTunnel);

      if Result then
      begin
        nHint := '����ͨ��[ %s ]װ����,ҵ����Ч.';
        nHint := Format(nHint, [nMutexTunnel]);
        WriteNearReaderLog(nHint);
      end;
    end;
begin
  with gTruckQueueManager do
  try
    Result := False;
    SyncLock.Enter;
    nIdx := GetLine(nTunnel);

    if nIdx < 0 then
    begin
      nHint := Format('ͨ��[ %s ]��Ч.', [nTunnel]);
      Exit;
    end;

    nPLine := Lines[nIdx];
    nIdx := TruckInLine(nTruck, nPLine.FTrucks);

    if nIdx < 0 then
    begin
      nHint := Format('����[ %s ]�Ѳ��ٶ���.', [nTruck]);
      Exit;
    end;

    Result := True;
    nPTruck := nPLine.FTrucks[nIdx];

    for nIdx:=nPLine.FTrucks.Count - 1 downto 0 do
      PTruckItem(nPLine.FTrucks[nIdx]).FStarted := False;
    nPTruck.FStarted := True;
    
    if IsMutexJSRun then
    begin
      nTask := gTaskMonitor.AddTask('UHardBusiness.AddJS', cTaskTimeoutLong);
      //to mon

      {$IFDEF StockPriorityInQueue}
      nIdx := BillValue2Dai(nBill, nPLine.FPeerWeight);
      //��Ʒ�����ȼ��Ŷ�ʱ,��ǰװ���Ĵ��������ǲ�ͬƷ��ƴ��,�����¼���.
      {$ELSE}
      nIdx := nPTruck.FDai;
      {$ENDIF}

      if gMultiJSManager.AddJS(nTunnel, nTruck, nBill, nIdx, True) then
      begin
        nStr := '%s ��ȴ�';
        nStr := Format(nstr,[nPTruck.FTruck]);
        gCounterDisplayManager.Display(nTunnel, cCounterDisp_CardID_tdk, nStr);
      end;
      gTaskMonitor.DelTask(nTask);
    end else
    if PrintBillCode(nTunnel, nBill, nHint) and nAddJS then
    begin
      nTask := gTaskMonitor.AddTask('UHardBusiness.AddJS', cTaskTimeoutLong);
      //to mon

      {$IFDEF StockPriorityInQueue}
      nIdx := BillValue2Dai(nBill, nPLine.FPeerWeight);
      //��Ʒ�����ȼ��Ŷ�ʱ,��ǰװ���Ĵ��������ǲ�ͬƷ��ƴ��,�����¼���.
      {$ELSE}
      nIdx := nPTruck.FDai;
      {$ENDIF}

      if gMultiJSManager.AddJS(nTunnel, nTruck, nBill, nIdx, True) then
      begin
        gCounterDisplayManager.SendCounterLedDispInfo(nTruck, nTunnel, nIdx, nStockName);
      end;
      gTaskMonitor.DelTask(nTask);
    end;
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2013-07-17
//Parm: ��������
//Desc: ��ѯnBill�ϵ���װ��
function GetHasDai(const nBill: string): Integer;
var nStr: string;
    nIdx: Integer;
    nDBConn: PDBWorker;
begin
  if not gMultiJSManager.ChainEnable then
  begin
    Result := 0;
    Exit;
  end;

  Result := gMultiJSManager.GetJSDai(nBill);
  if Result > 0 then Exit;

  nDBConn := nil;
  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nIdx);
    if not Assigned(nDBConn) then
    begin
      WriteNearReaderLog('����HM���ݿ�ʧ��(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nStr := 'Select T_Total From %s Where T_Bill=''%s''';
    nStr := Format(nStr, [sTable_ZTTrucks, nBill]);

    with gDBConnManager.WorkerQuery(nDBConn, nStr) do
    if RecordCount > 0 then
    begin
      Result := Fields[0].AsInteger;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

//Date: 2012-4-24
//Parm: �ſ���;ͨ����
//Desc: ��nCardִ�д�װװ������
procedure MakeTruckLadingDai(const nCard: string; nTunnel: string);
var nStr: string;
    nBool: Boolean;
    nIdx,nInt: Integer;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;

    function IsJSRun: Boolean;
    begin
      Result := False;
      if nTunnel = '' then Exit;
      Result := gMultiJSManager.IsJSRun(nTunnel);

      if Result then
      begin
        nStr := 'ͨ��[ %s ]װ����,ҵ����Ч.';
        nStr := Format(nStr, [nTunnel]);
        WriteNearReaderLog(nStr);
      end;
    end;
begin
  {$IFDEF DEBUG}
  WriteNearReaderLog('MakeTruckLadingDai����.');
  {$ENDIF}

  if IsJSRun then Exit;
  //tunnel is busy

  if not GetLadingBills(nCard, sFlag_TruckZT, nTrucks) then
  begin
    nStr := '��ȡ�ſ�[ %s ]��������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫջ̨�������.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if nTunnel = '' then
  begin
    nTunnel := gTruckQueueManager.GetTruckTunnel(nTrucks[0].FTruck);
    //���¶�λ�������ڳ���
    if IsJSRun then Exit;
  end;

  {$IFDEF DaiForceQueue}
  nBool := True;
  for nIdx:=Low(nTrucks) to High(nTrucks) do
  begin
    nBool := nTrucks[nIdx].FNextStatus = sFlag_TruckZT;
    //δװ��,����Ŷ�˳��
    if not nBool then Break;
  end;
  {$ELSE}
  nBool := False;
  {$ENDIF}

  if not IsTruckInQueue(nTrucks[0].FTruck, nTunnel, nBool, nStr,
         nPTruck, nPLine, sFlag_Dai) then
  begin
    WriteNearReaderLog(nStr);
    Exit;
  end; //���ͨ��

  nStr := '';
  nInt := 0;

  //----------------------------------------------------------------------------
  {$IFDEF StockPriorityInQueue}
  //ʹ��Ʒ�����ȼ��Ŷ�
  nStr := Format('QueueBills: %s', [nPTruck.FQueueBills]);
  WriteNearReaderLog(nStr); //for log
  nStr := '';

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    FSelected := False;

    if FNextStatus = sFlag_TruckZT then
    begin
      if (nInt > 0) and (FStockNo = nStr) then
      begin
        FSelected := True;
        //ͬƷ��ƴ��
        Inc(nInt);
      end;

      if (Pos(FID, nPTruck.FQueueBills) > 0) and (nInt = 0) then
      begin
        FSelected := True;
        FLineGroup := nPLine.FLineGroup;
        nStr := FStockNo;

        Inc(nInt);
        //����ѡ��δˢ��װ���ĵ�һ�ŵ���
      end; 
    end;
  end;

  if nInt < 1 then
  begin
    for nIdx:=Low(nTrucks) to High(nTrucks) do
    with nTrucks[nIdx] do
    begin
      if FStatus = sFlag_TruckZT then
      begin
        FSelected := Pos(FID, nPTruck.FQueueBills) > 0;
        if FSelected then
        begin
          FLineGroup := nPLine.FLineGroup;
          Inc(nInt);
        end;
        //ˢ��ͨ����Ӧ�Ľ�����
        Continue;
      end;
      
      FSelected := False;
      nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],�޷�ջ̨���.';
      nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
    end;
  end;
  {$ELSE}
  //----------------------------------------------------------------------------
  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    nStr := Format('����ƥ��: %s in %s', [FID, nPTruck.FHKBills]);
    WriteNearReaderLog(nStr);
    //for log

    if (FStatus = sFlag_TruckZT) or (FNextStatus = sFlag_TruckZT) then
    begin
      FSelected := Pos(FID, nPTruck.FHKBills) > 0;
      if FSelected then
      begin
        FLineGroup := nPLine.FLineGroup;
        Inc(nInt);
      end;
      //ˢ��ͨ����Ӧ�Ľ�����
      Continue;
    end;

    FSelected := False;
    nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],�޷�ջ̨���.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
  end;
  {$ENDIF}

  if nInt < 1 then
  begin
    WriteHardHelperLog(nStr);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if not FSelected then Continue;
    if FStatus <> sFlag_TruckZT then Continue;

    nStr := '��װ����[ %s ]�ٴ�ˢ��װ��.';
    nStr := Format(nStr, [nPTruck.FTruck]);
    WriteNearReaderLog(nStr);

    {$IFDEF PrepareShowOnLading}
    MakeTruckShowPreInfo(nTrucks[0].FCard, nTunnel);
    //��ʾ��ˢ����Ϣ
    {$ENDIF}

    {$IFDEF StockPriorityInQueue}
    if not TruckStartJS(nPTruck.FTruck, nTunnel, FID, nStr,
       GetHasDai(FID) < 1) then
      WriteNearReaderLog(nStr);
    {$ELSE}
    if not TruckStartJS(nPTruck.FTruck, nTunnel, nPTruck.FBill, nStr,
       GetHasDai(nPTruck.FBill) < 1) then
      WriteNearReaderLog(nStr);
    {$ENDIF}
    Exit;
  end;

  if not SaveLadingBills(sFlag_TruckZT, nTrucks) then
  begin
    nStr := '����[ %s ]ջ̨���ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  {$IFDEF PrepareShowOnLading}
  MakeTruckShowPreInfo(nTrucks[0].FCard, nTunnel);
  //��ʾ��ˢ����Ϣ
  {$ENDIF}

  {$IFDEF StockPriorityInQueue}
  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if not FSelected then Continue;
    //xxxxxx
    
    if not TruckStartJS(nPTruck.FTruck, nTunnel, FID, nStr) then
      WriteNearReaderLog(nStr);
    Break;
  end;  

  {$ELSE}
  if not TruckStartJS(nPTruck.FTruck, nTunnel, nPTruck.FBill, nStr) then
    WriteNearReaderLog(nStr);
  {$ENDIF}
  Exit;
end;

//Date: 2017-12-07
//Parm: �ſ���;ͨ����
//lih: ��nCardִ�д�װװ������
procedure MakeTruckLadingDaiDouble(const nCard: string; nTunnel,nMutexTunnel: string);
var nStr: string;
    nBool: Boolean;
    nIdx,nInt: Integer;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;
    nLen, i: Integer;
    nAlready: Boolean;

    function IsJSRun: Boolean;
    begin
      Result := False;
      if nTunnel = '' then Exit;
      Result := gMultiJSManager.IsJSRun(nTunnel);

      if Result then
      begin
        nStr := 'ͨ��[ %s ]װ����,ҵ����Ч.';
        nStr := Format(nStr, [nTunnel]);
        WriteNearReaderLog(nStr);
      end;
    end;
begin
  {$IFDEF DEBUG}
  WriteNearReaderLog('MakeTruckLadingDaiDouble����.');
  {$ENDIF}

  if IsJSRun then Exit;
  //tunnel is busy

  if not GetLadingBills(nCard, sFlag_TruckZT, nTrucks) then
  begin
    nStr := '��ȡ�ſ�[ %s ]��������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫջ̨�������.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if nTunnel = '' then
  begin
    nTunnel := gTruckQueueManager.GetTruckTunnel(nTrucks[0].FTruck);
    //���¶�λ�������ڳ���
    if IsJSRun then Exit;
  end;

  {$IFDEF DaiForceQueue}
  nBool := True;
  for nIdx:=Low(nTrucks) to High(nTrucks) do
  begin
    nBool := nTrucks[nIdx].FNextStatus = sFlag_TruckZT;
    //δװ��,����Ŷ�˳��
    if not nBool then Break;
  end;
  {$ELSE}
  nBool := False;
  {$ENDIF}

  if not IsTruckInQueue(nTrucks[0].FTruck, nTunnel, nBool, nStr,
         nPTruck, nPLine, sFlag_Dai) then
  begin
    WriteNearReaderLog(nStr);
    Exit;
  end; //���ͨ��

  nStr := '';
  nInt := 0;

  //----------------------------------------------------------------------------
  {$IFDEF StockPriorityInQueue}
  //ʹ��Ʒ�����ȼ��Ŷ�
  nStr := Format('QueueBills: %s', [nPTruck.FQueueBills]);
  WriteNearReaderLog(nStr); //for log
  nStr := '';

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    FSelected := False;

    if FNextStatus = sFlag_TruckZT then
    begin
      if (nInt > 0) and (FStockNo = nStr) then
      begin
        FSelected := True;
        //ͬƷ��ƴ��
        Inc(nInt);
      end;

      if (Pos(FID, nPTruck.FQueueBills) > 0) and (nInt = 0) then
      begin
        FSelected := True;
        FLineGroup := nPLine.FLineGroup;
        nStr := FStockNo;

        Inc(nInt);
        //����ѡ��δˢ��װ���ĵ�һ�ŵ���
      end; 
    end;
  end;

  if nInt < 1 then
  begin
    for nIdx:=Low(nTrucks) to High(nTrucks) do
    with nTrucks[nIdx] do
    begin
      if FStatus = sFlag_TruckZT then
      begin
        FSelected := Pos(FID, nPTruck.FQueueBills) > 0;
        if FSelected then
        begin
          FLineGroup := nPLine.FLineGroup;
          Inc(nInt);
        end;
        //ˢ��ͨ����Ӧ�Ľ�����
        Continue;
      end;
      
      FSelected := False;
      nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],�޷�ջ̨���.';
      nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
    end;
  end;
  {$ELSE}
  //----------------------------------------------------------------------------
  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    nStr := Format('����ƥ��: %s in %s', [FID, nPTruck.FHKBills]);
    WriteNearReaderLog(nStr);
    //for log

    if (FStatus = sFlag_TruckZT) or (FNextStatus = sFlag_TruckZT) then
    begin
      FSelected := Pos(FID, nPTruck.FHKBills) > 0;
      if FSelected then
      begin
        FLineGroup := nPLine.FLineGroup;
        Inc(nInt);
      end;
      //ˢ��ͨ����Ӧ�Ľ�����
      Continue;
    end;

    FSelected := False;
    nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],�޷�ջ̨���.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
  end;
  {$ENDIF}

  if nInt < 1 then
  begin
    WriteHardHelperLog(nStr);
    Exit;
  end;

  nAlready := False;
  nLen:= Length(gDoubleChannel);
  if nLen > 0 then
  for i := 0 to nLen - 1 do
  with gDoubleChannel[i] do
  begin
    if FTunnel = nTunnel  then
    begin
      FMutexTunnel := nMutexTunnel;
      FBill := nPTruck.FBill;
      FTruck := nPTruck.FTruck;
      FStockNo := nPTruck.FStockNo;
      FStockName := nPTruck.FStockName;
      FDaiNum := nPTruck.FDai;

      nAlready := True;
      Break;
    end;
  end;
  if not nAlready then
  begin
    SetLength(gDoubleChannel, nLen+1);
    with gDoubleChannel[High(gDoubleChannel)] do
    begin
      FTunnel := nTunnel;
      FMutexTunnel := nMutexTunnel;
      FBill := nPTruck.FBill;
      FTruck := nPTruck.FTruck;
      FStockNo := nPTruck.FStockNo;
      FStockName := nPTruck.FStockName;
      FDaiNum := nPTruck.FDai;
    end;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if not FSelected then Continue;
    if FStatus <> sFlag_TruckZT then Continue;

    nStr := '��װ����[ %s ]�ٴ�ˢ��װ��.';
    nStr := Format(nStr, [nPTruck.FTruck]);
    WriteNearReaderLog(nStr);

    {$IFDEF PrepareShowOnLading}
    MakeTruckShowPreInfo(nTrucks[0].FCard, nTunnel);
    //��ʾ��ˢ����Ϣ
    {$ENDIF}

    {$IFDEF StockPriorityInQueue}
    if not TruckStartJSDouble(nPTruck.FTruck, nTunnel, nMutexTunnel, FID, FStockName, nStr,
       GetHasDai(FID) < 1) then
      WriteNearReaderLog(nStr);
    {$ELSE}
    if not TruckStartJSDouble(nPTruck.FTruck, nTunnel, nMutexTunnel, nPTruck.FBill, nPTruck.FStockName, nStr,
       GetHasDai(nPTruck.FBill) < 1) then
      WriteNearReaderLog(nStr);
    {$ENDIF}
    Exit;
  end;

  if not SaveLadingBills(sFlag_TruckZT, nTrucks) then
  begin
    nStr := '����[ %s ]ջ̨���ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  {$IFDEF PrepareShowOnLading}
  MakeTruckShowPreInfo(nTrucks[0].FCard, nTunnel);
  //��ʾ��ˢ����Ϣ
  {$ENDIF}

  {$IFDEF StockPriorityInQueue}
  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if not FSelected then Continue;
    //xxxxxx
    
    if not TruckStartJSDouble(nPTruck.FTruck, nTunnel, nMutexTunnel, FID, FStockName, nStr) then
      WriteNearReaderLog(nStr);
    Break;
  end;

  {$ELSE}
  if not TruckStartJSDouble(nPTruck.FTruck, nTunnel, nMutexTunnel, nPTruck.FBill, nPTruck.FStockName, nStr) then
    WriteNearReaderLog(nStr);
  {$ENDIF}
end;

//Date: 2012-4-25
//Parm: ����;ͨ��
//Desc: ��ȨnTruck��nTunnel�����Ż�
procedure TruckStartFH(const nTruck: PTruckItem; const nTunnel: string);
var nStr,nTmp: string;
    nWorker: PDBWorker;
    nValue: Double;
begin
  nWorker := nil;
  try
    nTmp := '';
    nStr := 'Select T_Card,T_CardUse From %s Where T_Truck=''%s''';
    nStr := Format(nStr, [sTable_Truck, nTruck.FTruck]);

    with gDBConnManager.SQLQuery(nStr, nWorker) do
    if RecordCount > 0 then
    begin
      nTmp := Trim(Fields[0].AsString);
      if Fields[1].AsString = sFlag_No then
        nTmp := '';
      //xxxxx
    end;

    g02NReader.SetRealELabel(nTunnel, nTmp);
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;

  nValue := nTruck.FValue;
  {$IFDEF QZNF}
  if nValue = 110 then
    nValue := 111;
  {$ENDIF}

  nStr := nTruck.FTruck + StringOfChar(' ', 12 - Length(nTruck.FTruck));
  nTmp := nTruck.FStockName + FloatToStr(nValue);
  nStr := nStr + nTruck.FStockName + StringOfChar(' ', 12 - Length(nTmp)) +
          FloatToStr(nValue);
  //xxxxx

  gERelayManager.LineOpen(nTunnel);
  //�򿪷Ż�
  gERelayManager.ShowTxt(nTunnel, nStr);
  //��ʾ����
end;

//Date: 2012-4-24
//Parm: �ſ���;ͨ����
//Desc: ��nCardִ�д�װװ������
procedure MakeTruckLadingSan(const nCard,nTunnel: string);
var nStr: string;
    nIdx: Integer;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;
begin
  {$IFDEF DEBUG}
  WriteNearReaderLog('MakeTruckLadingSan����.');
  {$ENDIF}

  if not GetLadingBills(nCard, sFlag_TruckFH, nTrucks) then
  begin
    nStr := '��ȡ�ſ�[ %s ]��������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫ�Żҳ���.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    {$IFNDEF CZNF}
    if FIsVIP = sFlag_TypeShip then Continue;
    //���˲����
    {$ENDIF}
    if (FStatus = sFlag_TruckFH) or (FNextStatus = sFlag_TruckFH) then Continue;
    //δװ����װ

    {$IFDEF AllowMultiM}
    if FStatus = sFlag_TRuckBFM then
      FStatus := sFlag_TruckFH;
    //���غ�������
    {$ENDIF}

    nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],�޷��Ż�.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  if not IsTruckInQueue(nTrucks[0].FTruck, nTunnel, False, nStr,
         nPTruck, nPLine, sFlag_San) then
  begin
    WriteNearReaderLog(nStr);
    //loged

    nIdx := Length(nTrucks[0].FTruck);
    nStr := nTrucks[0].FTruck + StringOfChar(' ',12 - nIdx) + '�뻻��װ��';

    gERelayManager.ShowTxt(nTunnel, nStr);
    Exit;
  end; //���ͨ��

  {$IFNDEF CZNF}
  if nTrucks[0].FIsVIP = sFlag_TypeShip then
  begin
    nStr := '����[ %s ]����ͷˢ��װ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);
    WriteNearReaderLog(nStr);

    TruckStartFH(nPTruck, nTunnel);
    Exit;
  end;
  {$ENDIF}
  
  if nTrucks[0].FStatus = sFlag_TruckFH then
  begin
    nStr := 'ɢװ����[ %s ]�ٴ�ˢ��װ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);
    WriteNearReaderLog(nStr);

    TruckStartFH(nPTruck, nTunnel);
    Exit;
  end;

  nTrucks[0].FLineGroup := nPLine.FLineGroup;
  if not SaveLadingBills(sFlag_TruckFH, nTrucks) then
  begin
    nStr := '����[ %s ]�ŻҴ����ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  TruckStartFH(nPTruck, nTunnel);
  //ִ�зŻ�
end;

//Date: 2012-4-24
//Parm: ����;����
//Desc: ��nHost.nCard�µ�������������
procedure WhenReaderCardIn(const nCard: string; const nHost: PReaderHost);
var nReader: string;
    nMutexTunnel: string;
begin
  if nHost.FType = rtOnce then
  begin
    {$IFDEF ForceReader}
    nReader := nHost.FID;
    {$ELSE}
    nReader := '';
    {$ENDIF}

    if Assigned(nHost.FOptions) then
    begin
      if nHost.FOptions.Values['IsGrab'] = 'Y' then
      begin
        SaveGrabCard(nCard, nHost.FTunnel);
        Exit;
      end;
      nMutexTunnel := nHost.FOptions.Values['mutextunnel'];
    end;

    if nHost.FFun = rfOut then
         MakeTruckOut(nCard, nReader, nHost.FPrinter,
                      nHost.FOptions.Values['Post'],
                      nHost.FOptions.Values['Dept'])
    else
    {$IFDEF JSDoubleChannel}
    MakeTruckLadingDaiDouble(nCard, nHost.FTunnel, nMutexTunnel);
    {$ELSE}
    MakeTruckLadingDai(nCard, nHost.FTunnel);
    {$ENDIF}
  end else

  if nHost.FType = rtKeep then
  begin
    if Assigned(nHost.FOptions) then
    begin
      if nHost.FOptions.Values['DaiShowPre'] = sFlag_Yes then
      begin
        MakeTruckShowPreInfo(nCard, nHost.FTunnel,
        nHost.FOptions.Values['TunnelEx']);
        Exit;
      end else

      if nHost.FOptions.Values['SanWater'] = sFlag_Yes then
      begin
        MakeTruckAddWater(nCard, nHost.FTunnel);
        Exit;
      end;
    end;

    MakeTruckLadingSan(nCard, nHost.FTunnel);
  end;
end;

//Date: 2012-4-24
//Parm: ����;����
//Desc: ��nHost.nCard��ʱ����������
procedure WhenReaderCardOut(const nCard: string; const nHost: PReaderHost);
begin
  {$IFDEF DEBUG}
  WriteHardHelperLog('WhenReaderCardOut�˳�.');
  {$ENDIF}

  if Assigned(nHost.FOptions) then
  begin
    if nHost.FOptions.Values['DaiShowPre'] = sFlag_Yes then
    begin
      gDisplayManager.Display(nHost.FTunnel, nHost.FLEDText);
      Exit;
    end else

    if nHost.FOptions.Values['SanWater'] = sFlag_Yes then
    begin
      gDisplayManager.Display(nHost.FTunnel, nHost.FLEDText);
      Exit;
    end;   
  end;

  if nHost.FETimeOut then
  begin
    gERelayManager.LineClose(nHost.FTunnel);
    Sleep(100);
    gERelayManager.ShowTxt(nHost.FTunnel, '���ӱ�ǩ������Χ');
    Sleep(100);
    Exit;
  end;
  //���ӱ�ǩ������Χ

  gERelayManager.LineClose(nHost.FTunnel);
  Sleep(100);
  gERelayManager.ShowTxt(nHost.FTunnel, nHost.FLEDText);
  Sleep(100);
end;

//Date: 2014-10-25
//Parm: ��ͷ����
//Desc: �����ͷ�ſ�����
procedure WhenHYReaderCardArrived(const nReader: PHYReaderItem);
begin
  {$IFDEF DEBUG}
  WriteHardHelperLog(Format('�����ǩ %s:%s', [nReader.FTunnel, nReader.FCard]));
  {$ENDIF}

  if nReader.FVirtual then
  begin
    case nReader.FVType of
    rt900 : gHardwareHelper.SetReaderCard(nReader.FVReader, 'H' + nReader.FCard, False);
    rt02n : g02NReader.SetReaderCard(nReader.FVReader, nReader.FCard);
    end;
  end
  else g02NReader.ActiveELabel(nReader.FTunnel, nReader.FCard);
end;

//------------------------------------------------------------------------------
//Date: 2017/3/29
//Parm: ����һ������
//Desc: ��������һ��������Ϣ
procedure WhenTTCE_M100_ReadCard(const nItem: PM100ReaderItem);
var nStr: string;
    nRetain: Boolean;
begin
  nRetain := False;
  //init

  {$IFDEF DEBUG}
  nStr := '����һ����������'  + nItem.FID + ' ::: ' + nItem.FCard;
  WriteHardHelperLog(nStr);
  {$ENDIF}

  try
    if not nItem.FVirtual then Exit;
    case nItem.FVType of
    rtOutM100 :
    begin
      nRetain := MakeTruckOutM100(nItem.FCard, nItem.FVReader, nItem.FVPrinter,
                                  nItem.FPost, nItem.FDept);
      if nRetain then
        WriteHardHelperLog('�̿���ִ�ж���:�̿�')
      else
        WriteHardHelperLog('�̿���ִ�ж���:�̿����¿�');
    end
    else
      gHardwareHelper.SetReaderCard(nItem.FVReader, nItem.FCard, False);
    end;
  finally
    gM100ReaderManager.DealtWithCard(nItem, nRetain)
  end;
end;


//------------------------------------------------------------------------------
//Date: 2012-12-16
//Parm: �ſ���
//Desc: ��nCardNo���Զ�����(ģ���ͷˢ��)
procedure MakeTruckAutoOut(const nCardNo: string);
var nReader, nCardType: string;
begin
  if not GetCardUsed(nCardNo, nCardType) then nCardType := sFlag_Sale;

  if gTruckQueueManager.IsTruckAutoOut(nCardType=sFlag_Sale) then
  begin
    nReader := gHardwareHelper.GetReaderLastOn(nCardNo);
    if nReader <> '' then
      gHardwareHelper.SetReaderCard(nReader, nCardNo);
    //ģ��ˢ��
  end;
end;

//Date: 2012-12-16
//Parm: �ſ���
//Desc: ��nCardNo���Զ�����(ģ���ͷˢ��),���ڽ���һ��������ģ����������
procedure MakeTruckSHAutoOut(const nCardNo: string);
var nReader, nCardType: string;
begin
  if not GetCardUsed(nCardNo, nCardType) then nCardType := sFlag_Sale;

  if gTruckQueueManager.IsTruckAutoOut(nCardType=sFlag_Sale) then
  begin
    nReader := gHardwareHelper.GetReaderLastOn(nCardNo);
    if nReader <> '' then
      gHardwareHelper.SetReaderCard(nReader + 'SH', nCardNo);
    //ģ��ˢ��
  end;
end;  

//Date: 2012-12-16
//Parm: ��������
//Desc: ����ҵ���м����Ӳ���ػ��Ľ�������
procedure WhenBusinessMITSharedDataIn(const nData: string);
begin
  WriteHardHelperLog('�յ�Bus_MITҵ������:::' + nData);
  //log data

  if Pos('TruckOut', nData) = 1 then
    MakeTruckAutoOut(Copy(nData, Pos(':', nData) + 1, MaxInt));
  //auto out

  if Pos('TruckSH', nData) = 1 then
    MakeTruckSHAutoOut(Copy(nData, Pos(':', nData) + 1, MaxInt));
  //auto out
end;

function GetStockType(nBill: string):string;
var nStr, nStockMap: string;
    nWorker: PDBWorker;
begin
  {$IFDEF StockTypeByPackStyle}
  Result := '��ͨ';
  nStr := 'Select L_PackStyle From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, nBill]);

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nStr, nWorker) do
    if RecordCount > 0 then
    begin
      nStr := Trim(Fields[0].AsString);
      if nStr = 'Z' then Result := 'ֽ��';
      if nStr = 'R' then Result := '��ǿ';
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;

  Exit;
  {$ENDIF}

  Result := 'C';
  nStr := 'Select L_PackStyle, L_StockBrand, L_StockNO From %s ' +
          'Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, nBill]);

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nStr, nWorker) do
    if RecordCount > 0 then
    begin
      Result := UpperCase(GetPinYinOfStr(Fields[0].AsString + Fields[1].AsString));
      nStockMap := Fields[2].AsString + Fields[0].AsString + Fields[1].AsString;

      nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
      nStr := Format(nStr, [sTable_SysDict, sFlag_StockBrandShow, nStockMap]);
      with gDBConnManager.WorkerQuery(nWorker, nStr) do
      if RecordCount > 0 then
      begin
        Result := Fields[0].AsString;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;

  Result := Copy(Result, 1, 4);
end;

//Date: 2015-01-14
//Parm: ���ƺ�;������
//Desc: ��ʽ��nBill��������Ҫ��ʾ�ĳ��ƺ�
function GetJSTruck(const nTruck,nBill: string): string;
var nStr: string;
    nLen: Integer;
    nWorker: PDBWorker;
begin
  Result := nTruck;
  if nBill = '' then Exit;

  {$IFDEF JSTruckPackStyle}
  nWorker := nil;
  try
    nStr := 'Select L_PackStyle From %s Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, nBill]);

    with gDBConnManager.SQLQuery(nStr, nWorker) do
    if RecordCount > 0 then
    begin
      nStr := Trim(Fields[0].AsString);
      if (nStr = '') or (nStr = 'C') then Exit;
      //��ͨģʽ,����ȫ��

      nLen := cMultiJS_Truck - 2;
      Result := nStr + '-' + Copy(nTruck, Length(nTruck) - nLen + 1, nLen);
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;

  Exit;  
  {$ENDIF}

  {$IFDEF JSTruckSimple}
  nWorker := nil;
  try
    nStr := 'Select D_ParamC From %s b' +
            ' Left Join %s d On d.D_Name=''%s'' and d.D_ParamB=b.L_StockNo ' +
            'Where b.L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, sTable_SysDict, sFlag_StockItem, nBill]);

    with gDBConnManager.SQLQuery(nStr, nWorker) do
    if RecordCount > 0 then
    begin
      nStr := Trim(Fields[0].AsString);
      if (nStr = '') or (nStr = 'C') then Exit;
      //common,��ͨ�������ʽ��

      Result := Copy(Fields[0].AsString + '-', 1, 2) +
                Copy(Result, 3, cMultiJS_Truck - 2);
      //format
      nStr := Result;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;

  Exit;
  {$ENDIF}

  {$IFDEF JSTruck}
  nStr := GetStockType(nBill);
  if nStr = '' then Exit;

  nLen := cMultiJS_Truck - 2;
  Result := Copy(nStr, 1, 2) +    //ȡǰ��λ
            Copy(nTruck, Length(nTruck) - nLen + 1, nLen);
  Exit;
  {$ENDIF}
end;

//lih 2017-12-07  ����ͨ����Ϣ
procedure UpdateDoubleChannel(const nTunnel: PMultiJSTunnel);
var
  nIdx: Integer;
  nStr, nHint: string;
  nMutexTunnel: string;
  
  function IsMutexJSRun: Boolean;
  begin
    Result := False;
    if nMutexTunnel = '' then Exit;
    Result := gMultiJSManager.IsJSRun(nMutexTunnel);

    if Result then
    begin
      nHint := '����ͨ��[ %s ]װ����,ҵ����Ч.';
      nHint := Format(nHint, [nMutexTunnel]);
      WriteNearReaderLog(nHint);
    end;
  end;
begin
  for nIdx := Low(gDoubleChannel) to High(gDoubleChannel) do
  with gDoubleChannel[nIdx] do
  begin
    if FTunnel = nTunnel.FID then
    begin
      nMutexTunnel := FMutexTunnel;
      FHasDone := nTunnel.FHasDone;
      FIsRun := nTunnel.FIsRun;
      FLastTime := GetTickCount;
      WriteHardHelperLog('����ͨ����' + FTunnel + '  �����' + IntToStr(FBanDaoNum) + '/' + IntToStr(nTunnel.FBanDaoNum) + '  ��װ������' + IntToStr(FHasDone) +'  ����״̬��'+ BoolToStr(FIsRun, True));
      if FBanDaoNum <> nTunnel.FBanDaoNum then
      begin
        FBanDaoNum := nTunnel.FBanDaoNum;
        if FBanDaoNum <> 0 then
        begin
          if not PrintBillCode(FTunnel, FBill, nStr) then
            WriteHardHelperLog(nStr);
        end;
      end;
      if FBanDaoNum = 0 then
      begin
        if not IsMutexJSRun then
          gCounterDisplayManager.OnSyncChange(nTunnel)
        else
          gCounterDisplayManager.SendFreeToLedDispInfo(FTunnel, FTruck, FIsRun);
      end else
        gCounterDisplayManager.OnSyncChange(nTunnel);
      Break;
    end; {else
    begin
      WriteHardHelperLog('����ͨ����' + FTunnel + '  �����' + IntToStr(FBanDaoNum) + '  ��װ������' + IntToStr(FHasDone) +'  ����״̬��'+ BoolToStr(FIsRun, True));
      if FBanDaoNum = 0 then
      begin
        if not IsMutexJSRun then gCounterDisplayManager.OnSyncChange(nTunnel);
        gCounterDisplayManager.SendFreeToLedDispInfo(FTunnel, FTruck, FIsRun);
      end; 
    end; }
  end;
end;

//Date: 2013-07-17
//Parm: ������ͨ��
//Desc: ����nTunnel�������
procedure WhenSaveJS(const nTunnel: PMultiJSTunnel);
var nStr: string;
    nDai: Word;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nDai := nTunnel.FHasDone - nTunnel.FLastSaveDai;
  if nDai <= 0 then Exit;
  //invalid dai num

  if nTunnel.FLastBill = '' then Exit;
  //invalid bill

  nList := nil;
  try
    nList := TStringList.Create;
    nList.Values['Bill'] := nTunnel.FLastBill;
    nList.Values['Dai'] := IntToStr(nDai);

    nStr := PackerEncodeStr(nList.Text);
    CallHardwareCommand(cBC_SaveCountData, nStr, '', @nOut)
  finally
    nList.Free;
  end;
end;

//Date: 2017-08-18
//Parm: ���й�����
//Desc: �������ʱ,�������ҵ��
procedure WhenQueueTruckChanged(const nManager: TTruckQueueManager);
var i,nIdx,nInt,nLen: Integer;
    nLine: PLineItem;
    nTruck: PTruckItem;
begin
  {$IFDEF PrepareShowOnLading}
  //ͨ��ˢ��ʱ��ʾԤˢ��,���г����б�ʱ,����Ԥˢ����Ϣ
  nManager.SyncLock.Enter;
  try
    for nIdx:=0 to nManager.Lines.Count - 1 do
    begin
      nLine := nManager.Lines[nIdx];
      //line item
      nLen := nLine.FTrucks.Count - 1;

      for i:=0 to nLen do
      begin
        nTruck := nLine.FTrucks[i];
        if not nTruck.FStarted then Continue;
        //����δ����,Ԥˢ����Ϣ�͸ó��޹�

        if (nTruck.FQueueCard = '') then Continue;
        //�ſ�Ϊ��,��ʶδʹ���Զ�Ԥˢ��

        //if (nTruck.FQueueNext = '') and (i = nLen) then
        //  Continue;
        //�ó���ĩβ,�Һ���ȷʵû��,�������

        //if (i < nLen) and (nTruck.FQueueNext <> '') and
        //   (nTruck.FQueueNext = PTruckItem(nLine.FTrucks[i+1]).FTruck) then
        //  Continue;
        //���ں���ĳ�������,δ�ƶ�λ��,�������

        MakeTruckShowPreInfo(nTruck.FQueueCard, nLine.FLineID);
        //����Ԥˢ��
      end;
    end;
  finally
    nManager.SyncLock.Leave;
  end;
  {$ENDIF}
end;

//Date: 2017-08-13
//Parm: �ſ���;ͨ����;�������
//Desc: ��nTunnelͨ������ʾnCard��Ԥˢ����Ϣ
function PrepareShowInfo(const nCard:string; nTunnel: string='';nTunnelEx: string='';
 nLevel: Integer = 0):string;
var nStr,nNewCard: string;
    nDai: Double;
    nIdx,nInt: Integer;
    nWorker: PDBWorker;

    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;
    nTunnelReal: string;
begin
  if not GetLadingBills(nCard, sFlag_TruckZT, nTrucks) then
  begin
    Result := '��ȡ�ſ�[ %s ]��������Ϣʧ��.';
    Result := Format(Result, [nCard]);
    WriteNearReaderLog(Result);

    Result := '�ſ���Ч1.';
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    Result := '�ſ�[ %s ]û����Ҫջ̨�������.';
    Result := Format(Result, [nCard]);

    WriteNearReaderLog(Result);
    Result := '�ſ���Ч2.';
    Exit;
  end;

  if (nTunnel <> '') and (nTunnelEx <> '') then//Ԥˢ��������ͬʱ֧��2��ͨ��
  begin
    nTunnelReal := gTruckQueueManager.GetTruckTunnel(nTrucks[0].FTruck);
    //���¶�λ�������ڳ���
    WriteHardHelperLog('Ԥˢ��ͨ��Ϊ˫ͨ��:'+nTunnel+';'+nTunnelEx+
                       ';��ǰ��������ͨ��:'+nTunnelReal);
    if (nTunnelReal = nTunnel) or (nTunnelReal = nTunnelEx) then
    begin
      nTunnel := nTunnelReal;
    end;
    //�ж��Ƿ�����ͨ����Χ,���˷�Χ��ͨ��
  end;

  if nTunnel = '' then
  begin
    nTunnel := gTruckQueueManager.GetTruckTunnel(nTrucks[0].FTruck);
    //���¶�λ�������ڳ���
  end;

  nInt := 0;
  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
     if not IsTruckInQueue(FTruck, nTunnel, False, nStr,
         nPTruck, nPLine, sFlag_Dai) then
     begin
        WriteNearReaderLog(nStr);
        Continue;
     end; //���ͨ��

     Inc(nInt);
  end;

  if nInt < 1 then
  begin
    nIdx := Length(nTrucks[0].FTruck);
    nStr := nTrucks[0].FTruck + StringOfChar(' ',12 - nIdx) + '�뻻��װ��';
    Result := nStr;
    Exit;
  end;
  //ͨ������

  nPTruck.FQueueCard := nCard;
  nPTruck.FQueueNext := '';
  Result := '';

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    nStr := '';
    if (FNextStatus = sFlag_TruckZT) or ((nLevel > 0) and
       (FStatus = sFlag_TruckIn)) then //��װ��,��󳵸ս���
    begin
      nDai := Int(FValue * 1000) / nPLine.FPeerWeight;

      nStr := GetStockType(FID);
      Result := Result + nStr + StringOfChar(' ' , 7 - Length(nStr));

      nStr := FormatFloat('00000' , nDai);
      Result := Result + StringOfChar('0' , 5 - Length(nStr)) + nStr;

      {$IFDEF PrepareShowTruck}
      Result := Result + nTrucks[0].FTruck;
      {$ENDIF}
      Break;
    end;
  end;

  if Result = '' then
  begin
    with nTrucks[0] do
    begin
      {$IFDEF PrepareShowTruck}
      Result := Format('����: %s %s', [FTruck, TruckStatusToStr(FNextStatus)]);
      {$ELSE}
      Result := Format('��һ״̬ %s', [TruckStatusToStr(FNextStatus)]);
      {$ENDIF}

      {$IFDEF PrepareShowOnLading}
      if nLevel < 1 then
      begin
        nStr := 'Ԥˢ��: ����[ %s.%s -> %s ]����������,׼���л����泵��.';
        nStr := Format(nStr, [FTruck, FID, TruckStatusToStr(FNextStatus)]);

        WriteNearReaderLog(nStr);
        Result := '';
      end;
      {$ENDIF}
    end;
  end;

  {$IFDEF PrepareShowOnLading}
  if (Result = '') and (nLevel < 1) then
  begin
    Inc(nLevel);
    nIdx := nPLine.FTrucks.IndexOf(nPTruck);
    
    if (nIdx >= 0) and (nIdx < nPLine.FTrucks.Count - 1) then
    begin
      nPTruck := nPLine.FTrucks[nIdx+1];
      //���泵��

      nStr := 'Select L_Card,L_Truck From %s Where L_ID=''%s''';
      nStr := Format(nStr, [sTable_Bill, nPTruck.FBill]);

      nNewCard := '';
      nWorker := nil;
      
      with gDBConnManager.SQLQuery(nStr, nWorker) do
      try
        if RecordCount > 0 then
        begin
          nNewCard := Fields[0].AsString;
          //�󳵴ſ�
          nPTruck.FQueueNext := Fields[1].AsString;
          //�󳵳���
        end else
        begin
          nStr := 'Ԥˢ��: ���泵��[ %s.%s ]������������.';
          nStr := Format(nStr, [nPTruck.FTruck, nPTruck.FBill]);
          WriteNearReaderLog(nStr);
        end;
      finally
        gDBConnManager.ReleaseConnection(nWorker); 
      end;

      if nNewCard = '' then
      begin
        nStr := 'Ԥˢ��: ���泵��[ %s.%s ]�ſ���Ϊ��.';
        nStr := Format(nStr, [nPTruck.FTruck, nPTruck.FBill]);
        WriteNearReaderLog(nStr);

        Result := '%s �󳵴ſ�����';
        Result := Format(Result, [nTrucks[0].FTruck]);
      end else
      begin
        Result := PrepareShowInfo(nNewCard, nPLine.FLineID, nLevel);
        //��Ԥˢ����Ϣ
      end;
    end else
    begin
      Result := '%s ����û��';
      Result := Format(Result, [nTrucks[0].FTruck]);
    end;
  end;
  //��ǰ��û�п�װƷ��ʱ,��ʾ��һ����
  {$ENDIF}

  WriteNearReaderLog('PrepareShowInfo: [' + Result + ']');
end;

//Date: 2017/6/21
//Parm: �ſ���;ͨ�����
//Desc: ��ʾԤˢ��������Ϣ
procedure MakeTruckShowPreInfo(const nCard: string; nTunnel: string='';nTunnelEx: string='');
var nMsgStr: string;
begin
  nMsgStr := PrepareShowInfo(nCard, nTunnel,nTunnelEx);
  WriteHardHelperLog('Ԥˢ��С������:ͨ��:'+nTunnel+'��չͨ��:'+nTunnelEx+'��Ϣ:'+nMsgStr);
  gDisplayManager.Display(nTunnel, nMsgStr);
end;

//Date: 2017/6/21
//Parm: �ſ���;ͨ�����
//Desc: ɢװ������ˮ
procedure MakeTruckAddWater(const nCard: string; nTunnel: string='');
var nTrucks: TLadingBillItems;
    nCardType, nStr: string;
    nRet: Boolean;
    nIdx: Integer;
begin
  if not GetCardUsed(nCard, nCardType) then nCardType := sFlag_Sale;

  nRet := False;
  if (nCardType = sFlag_Sale) or (nCardType = sFlag_SaleNew) then
    nRet := GetLadingBills(nCard, sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_Provide then
    nRet := GetProvideItems(nCard, sFlag_TruckOut, nTrucks) else
  if nCardType = sFlag_ShipPro then
    nRet := GetShipProItems(nCard, sFlag_TruckOut, nTrucks)  else
  if nCardType = sFlag_ShipTmp then
    nRet := GetShipTmpItems(nCard, sFlag_TruckOut, nTrucks);
  //xxxxx

  if not nRet then
  begin
    nStr := '��ȡ�ſ�[ %s ]��������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫ��ˮ����.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    FCardUse := nCardType;
    if (FNextStatus = sFlag_TruckWT) or (FStatus = sFlag_TruckWT) then Continue;
    nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],�޷���ˮ.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  nRet := False;
  if (nCardType = sFlag_Sale) or (nCardType = sFlag_SaleNew) then
    nRet := SaveLadingBills(sFlag_TruckWT, nTrucks) else
  if nCardType = sFlag_Provide then
    nRet := SaveProvideItems(sFlag_TruckWT, nTrucks) else
  if nCardType = sFlag_ShipPro then
    nRet := SaveShipProItems(sFlag_TruckWT, nTrucks) else
  if nCardType = sFlag_ShipTmp then
    nRet := SaveShipTmpItems(sFlag_TruckWT, nTrucks);
  //xxxxx

  if not nRet then
  begin
    nStr := '����[ %s ]��ˮ����ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  nStr := nTrucks[0].FTruck + '���ˮ';
  WriteNearReaderLog(nStr);
  gDisplayManager.Display(nTunnel, nStr);
end;

procedure HardOpenDoor(const nReader: String);
var nIdx: Integer;
    nStr: string;
begin
  for nIdx := 0 to 3 do
  try
    {$IFDEF RFIDOPENDOOR}
    nStr := StringReplace(nReader, 'V', 'H', [rfReplaceAll]);
    gHYReaderManager.OpenDoor(nStr);
    {$ELSE}
    nStr := StringReplace(nReader, 'V', '1', [rfReplaceAll]);
    gHardwareHelper.OpenDoor(nStr);
    {$ENDIF}
  except
    Continue;
  end;
end;

//Date: 2009-7-4
//Parm: ���ݼ�;�ֶ���;ͼ������
//Desc: ��nImageͼ�����nDS.nField�ֶ�
function SaveDBImage(const nDS: TDataSet; const nFieldName: string;
  const nImage: TGraphic): Boolean;
var nField: TField;
    nStream: TMemoryStream;
    nBuf: array[1..MAX_PATH] of Char;
begin
  Result := False;
  nField := nDS.FindField(nFieldName);
  if not (Assigned(nField) and (nField is TBlobField)) then Exit;

  nStream := nil;
  try
    if not Assigned(nImage) then
    begin
      nDS.Edit;
      TBlobField(nField).Clear;
      nDS.Post; Result := True; Exit;
    end;
    
    nStream := TMemoryStream.Create;
    nImage.SaveToStream(nStream);
    nStream.Seek(0, soFromEnd);

    FillChar(nBuf, MAX_PATH, #0);
    StrPCopy(@nBuf[1], nImage.ClassName);
    nStream.WriteBuffer(nBuf, MAX_PATH);

    nDS.Edit;
    nStream.Position := 0;
    TBlobField(nField).LoadFromStream(nStream);

    nDS.Post;
    FreeAndNil(nStream);
    Result := True;
  except
    if Assigned(nStream) then nStream.Free;
    if nDS.State = dsEdit then nDS.Cancel;
  end;
end;

{$IFDEF HKVDVR}
procedure WhenCaptureFinished(const nPtr: Pointer);
var nStr: string;
    nDS: TDataSet;
    nPic: TPicture;
    nDBConn: PDBWorker;
    nErrNum, nRID: Integer;
    nCapture: PCameraFrameCapture;
begin
  nDBConn := nil;
  {$IFDEF DEBUG}
  WriteHardHelperLog('WhenCaptureFinished����.');
  {$ENDIF}

  nCapture :=  PCameraFrameCapture(nPtr);
  if not FileExists(nCapture.FCaptureName) then Exit;

  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
    if not Assigned(nDBConn) then
    begin
      WriteHardHelperLog('����HM���ݿ�ʧ��(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nDBConn.FConn.BeginTrans;
    try
      nStr := MakeSQLByStr([
              SF('P_ID', nCapture.FCaptureFix),
              //SF('P_Name', nCapture.FCaptureName),
              SF('P_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Picture, '', True);
      //xxxxx

      if gDBConnManager.WorkerExec(nDBConn, nStr) < 1 then Exit;

      nStr := 'Select Max(%s) From %s';
      nStr := Format(nStr, ['R_ID', sTable_Picture]);
      with gDBConnManager.WorkerQuery(nDBConn, nStr) do
        nRID := Fields[0].AsInteger;

      nStr := 'Select P_Picture From %s Where R_ID=%d';
      nStr := Format(nStr, [sTable_Picture, nRID]);
      nDS := gDBConnManager.WorkerQuery(nDBConn, nStr);

      nPic := nil;
      try
        nPic := TPicture.Create;
        nPic.LoadFromFile(nCapture.FCaptureName);

        SaveDBImage(nDS, 'P_Picture', nPic.Graphic);
        FreeAndNil(nPic);
      except
        if Assigned(nPic) then nPic.Free;
      end;

      DeleteFile(nCapture.FCaptureName);
      nDBConn.FConn.CommitTrans;
    except
      nDBConn.FConn.RollbackTrans;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;
{$ENDIF}

//Date: 2017-8-17
//Parm: ����;ͨ����
//Desc: ����nReader�����Ŀ��Ų�������Ӧ����
procedure SaveGrabCard(const nCard: string; nTunnel: string);
var nStr, nGroup,nLs: string;
    nErrNum: Integer;
    nDBConn: PDBWorker;
begin
  nDBConn := nil;

  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
    if not Assigned(nDBConn) then
    begin
      WriteHardHelperLog('�������ݿ�ʧ��(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nStr := 'Select * From $TB Where P_Tunnel=''$T''';
    nStr := MacroValue(nStr, [MI('$TB', sTable_CardGrab), MI('$T', nTunnel)]);

    with gDBConnManager.WorkerQuery(nDBConn, nStr) do
    if RecordCount <= 0 then
    begin
      nLs := Date2Str(Now,False) + Time2Str(Now,False);
      //���ɴ˴�ˢ����ˮ��
      nStr := 'Insert Into %s(P_Ls, P_Card, P_Tunnel) Values(''%s'', ''%s'', ''%s'')';
      nStr := Format(nStr, [sTable_CardGrab, nLs, nCard, nTunnel]);
      gDBConnManager.WorkerExec(nDBConn, nStr);
    end else
    begin
      nStr := Format('ͨ����[ %s ]���ڳ��أ������ظ�ˢ��.', [nTunnel]);
      WriteHardHelperLog(nStr);
      Exit;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end ;

function VerifySnapTruck(const nTruck,nBill,nPos,nDept: string;var nResult: string): Boolean;
var nList: TStrings;
    nOut: TWorkerBusinessCommand;
    nID,nDefDept: string;
begin
  nDefDept := '�Ÿ�';

  if nBill = '' then
    nID := nTruck + FormatDateTime('YYMMDD',Now)
  else
    nID := nBill;
  nList := nil;
  try
    nList := TStringList.Create;
    nList.Values['Truck'] := nTruck;
    nList.Values['Bill'] := nID;
    nList.Values['Pos'] := nPos;
    if nDept = '' then
      nList.Values['Dept'] := nDefDept
    else
      nList.Values['Dept'] := nDept;

    Result := CallBusinessCommand(cBC_VerifySnapTruck, nList.Text, '', @nOut);
    nResult := nOut.FData;
  finally
    nList.Free;
  end;
end;

end.

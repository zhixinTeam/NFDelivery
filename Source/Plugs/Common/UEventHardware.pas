{*******************************************************************************
  ����: dmzn@163.com 2013-11-23
  ����: ģ�鹤������,������Ӧ����¼�
*******************************************************************************}
unit UEventHardware;

{$I Link.Inc}
interface

uses
  Windows, Classes, UMgrPlug, UBusinessConst, ULibFun, UPlugConst;

type
  THardwareWorker = class(TPlugEventWorker)
  public
    class function ModuleInfo: TPlugModuleInfo; override;
    procedure RunSystemObject(const nParam: PPlugRunParameter); override;
    procedure InitSystemObject; override;
    //����������ʱ��ʼ��
    procedure BeforeStartServer; override;
    //��������֮ǰ����
    procedure AfterStopServer; override;
    //����ر�֮�����
    {$IFDEF DEBUG}
    procedure GetExtendMenu(const nList: TList); override;
    {$ENDIF}
  end;

var
  gPlugRunParam: TPlugRunParameter;
  //���в���

implementation

uses
  SysUtils, USysLoger, UHardBusiness, UMgrTruckProbe, UMgrParam, UMITConst,
  UMgrQueue, UMgrLEDCard, UMgrHardHelper, UMgrRemotePrint, U02NReader,
  UMgrERelay,   {$IFDEF MultiReplay}UMultiJS_Reply, {$ELSE}UMultiJS, {$ENDIF}
  UMgrRemoteVoice, UMgrVoiceNet, UMgrCodePrinter, UMgrLEDDisp, UMgrTTCEM100,
  UMgrRemoteSnap,
  UMgrRFID102{$IFDEF HKVDVR}, UMgrCamera{$ENDIF}, UMgrLEDDispCounter,
  UJSDoubleChannel, UMgrSendCardNo, UMgrBasisWeight, UMgrBXFontCard;

class function THardwareWorker.ModuleInfo: TPlugModuleInfo;
begin
  Result := inherited ModuleInfo;
  with Result do
  begin
    FModuleID := sPlug_ModuleHD;
    FModuleName := 'Ӳ���ػ�';
    FModuleVersion := '2014-09-30';
    FModuleDesc := '�ṩˮ��һ��ͨ������Ӳ���������';
    FModuleBuildTime:= Str2DateTime('2014-09-30 15:01:01');
  end;
end;

procedure THardwareWorker.RunSystemObject(const nParam: PPlugRunParameter);
var nStr,nCfg: string;
begin
  gPlugRunParam := nParam^;
  nCfg := gPlugRunParam.FAppPath + 'Hardware\';

  try
    nStr := 'LED';
    gCardManager.TempDir := nCfg + 'Temp\';
    gCardManager.FileName := nCfg + 'LED.xml';

    nStr := 'Զ���ͷ';
    gHardwareHelper.LoadConfig(nCfg + '900MK.xml');
    
    nStr := '�����ͷ';
    if not Assigned(g02NReader) then
    begin
      g02NReader := T02NReader.Create;
      g02NReader.LoadConfig(nCfg + 'Readers.xml');
    end;

    nStr := '������';
    gMultiJSManager.LoadFile(nCfg + 'JSQ.xml');

    nStr := '�̵���';
    gERelayManager.LoadConfig(nCfg + 'ERelay.xml');

    nStr := 'Զ�̴�ӡ';
    gRemotePrinter.LoadConfig(nCfg + 'Printer.xml');

    nStr := '��������';
    gVoiceHelper.LoadConfig(nCfg + 'Voice.xml');

    nStr := '�����';
    gCodePrinterManager.LoadConfig(nCfg + 'CodePrinter.xml');

    nStr := 'С����ʾ';
    gDisplayManager.LoadConfig(nCfg + 'LEDDisp.xml');

    {$IFDEF HKVDVR}
    nStr := 'Ӳ��¼���';
    gCameraManager.LoadConfig(nCfg + cCameraXML);
    {$ENDIF}

    {$IFDEF HYRFID201}
    nStr := '����RFID102';
    if not Assigned(gHYReaderManager) then
    begin
      gHYReaderManager := THYReaderManager.Create;
      gHYReaderManager.LoadConfig(nCfg + 'RFID102.xml');
    end;
    {$ENDIF}

    nStr := '����һ������';
    if not Assigned(gM100ReaderManager) then
    begin
      gM100ReaderManager := TM100ReaderManager.Create;
      gM100ReaderManager.LoadConfig(nCfg + cTTCE_M100_Config);
    end;

    nStr := '���������';
    if FileExists(nCfg + 'TruckProber.xml') then
    begin
      gProberManager := TProberManager.Create;
      gProberManager.LoadConfig(nCfg + 'TruckProber.xml');
    end;

    nStr := '������������';
    if FileExists(nCfg + 'NetVoice.xml') then
    begin
      gNetVoiceHelper := TNetVoiceManager.Create;
      gNetVoiceHelper.LoadConfig(nCfg + 'NetVoice.xml');
    end;

    {$IFDEF JSLED}
    nStr := '��������ʾ';
    if not Assigned(gCounterDisplayManager) then
    begin
      gCounterDisplayManager := TMgrLEDDispCounterManager.Create;
      if FileExists(nCfg + 'LEDDispCounter.xml') then
      begin
        gCounterDisplayManager.LoadConfig(nCfg + 'LEDDispCounter.xml');
      end;
    end;
    {$ENDIF}
    {$IFDEF RemoteSnap}
    nStr := '��������Զ��ץ��';
    if FileExists(nCfg + 'RemoteSnap.xml') then
    begin
      //gHKSnapHelper := THKSnapHelper.Create;
      gHKSnapHelper.LoadConfig(nCfg + 'RemoteSnap.xml');
    end;
    {$ELSE}
      {$IFDEF PoundSaveSnapInfo}
      nStr := '��������Զ��ץ��';
      if FileExists(nCfg + 'RemoteSnap.xml') then
      begin
        //gHKSnapHelper := THKSnapHelper.Create;
        gHKSnapHelper.LoadConfig(nCfg + 'RemoteSnap.xml');
      end;
      {$ENDIF}
    {$ENDIF}
    {$IFDEF FixLoad}
    nStr := '����װ��';
    gSendCardNo.LoadConfig(nCfg + 'PLCController.xml');
    {$ENDIF}
    {$IFDEF BasisWeight}
    nStr := '����װ��ҵ��';
    gBasisWeightManager := TBasisWeightManager.Create;
    gBasisWeightManager.LoadConfig(nCfg + 'Tunnels.xml');
    {$ENDIF}

    {$IFDEF LedNew}
    nStr := 'ɢװ����С��(������)';
    if not Assigned(gBXFontCardManager) then
    begin
      gBXFontCardManager := TBXFontCardManager.Create;
      gBXFontCardManager.LoadConfig(nCfg + 'BXFontLED.xml');
    end;
    {$ENDIF}
  except
    on E:Exception do
    begin
      nStr := Format('����[ %s ]�����ļ�ʧ��: %s', [nStr, E.Message]);
      gSysLoger.AddLog(nStr);
    end;
  end;
end;

{$IFDEF DEBUG}
procedure THardwareWorker.GetExtendMenu(const nList: TList);
var nItem: PPlugMenuItem;
begin
  New(nItem);
  nList.Add(nItem);
  nItem.FName := 'Menu_Param_2';

  nItem.FModule := ModuleInfo.FModuleID;
  nItem.FCaption := 'Ӳ������';
  nItem.FFormID := cFI_FormTest2;
  nItem.FDefault := False;
end;
{$ENDIF}

procedure THardwareWorker.InitSystemObject;
begin
  gHardwareHelper := THardwareHelper.Create;
  //Զ���ͷ

  if not Assigned(gMultiJSManager) then
    gMultiJSManager := TMultiJSManager.Create;
  //������ 

  gHardShareData := WhenBusinessMITSharedDataIn;
  //hard monitor share
  {$IFDEF FixLoad}
  gSendCardNo := TReaderHelper.Create;
  {$ENDIF}
end;

procedure THardwareWorker.BeforeStartServer;
begin
  gTruckQueueManager.OnChanged := WhenQueueTruckChanged;
  gTruckQueueManager.StartQueue(gParamManager.ActiveParam.FDB.FID);
  //truck queue

  gHardwareHelper.OnProce := WhenReaderCardArrived;
  gHardwareHelper.StartRead;
  //long reader

  {$IFDEF HYRFID201}
  if Assigned(gHYReaderManager) then
  begin
    gHYReaderManager.OnCardProc := WhenHYReaderCardArrived;
    gHYReaderManager.StartReader;
  end;
  {$ENDIF}

  {$IFDEF HKVDVR}
  gCameraManager.OnCameraProc := WhenCaptureFinished;
  gCameraManager.ControlStart;
  //Ӳ��¼���
  {$ENDIF}

  g02NReader.OnCardIn := WhenReaderCardIn;
  g02NReader.OnCardOut := WhenReaderCardOut;
  g02NReader.StartReader;
  //near reader

  {$IFDEF JSLED}
  //��������ʾ��
  gCounterDisplayManager.StartDisplay;
  {$ENDIF}

  gMultiJSManager.SaveDataProc := WhenSaveJS;
  {$IFNDEF JSTruckNone}
  gMultiJSManager.GetTruckProc := GetJSTruck;
  {$ENDIF}
  
  {$IFDEF JSDoubleChannel}
  gMultiJSManager.ChangeThreadProc := UpdateDoubleChannel;
  {$ENDIF}
  gMultiJSManager.StartJS;
  //counter
  gERelayManager.ControlStart;
  //erelay

  gRemotePrinter.StartPrinter;
  //printer
  gVoiceHelper.StartVoice;
  //voice

  gCardManager.StartSender;
  //led display
  gDisplayManager.StartDisplay;
  //small led

  {$IFDEF MITTruckProber}
  gProberManager.StartProber;
  {$ENDIF}

  if Assigned(gM100ReaderManager) then
  begin
    gM100ReaderManager.OnCardProc := WhenTTCE_M100_ReadCard;
    gM100ReaderManager.StartReader;
  end;
  //����һ������

  if Assigned(gNetVoiceHelper) then
  begin
    gNetVoiceHelper.StartVoice;
  end;
  //��������

  {$IFDEF RemoteSnap}
  gHKSnapHelper.StartSnap;
  //remote snap
  {$ELSE}
    {$IFDEF PoundSaveSnapInfo}
    gHKSnapHelper.StartSnap;
    //remote snap
    {$ENDIF}
  {$ENDIF}

  {$IFDEF FixLoad}
  if Assigned(gSendCardNo) then
  gSendCardNo.StartPrinter;
  //sendcard
  {$ENDIF}

  {$IFDEF BasisWeight}
  //gBasisWeightManager.TunnelManager.OnUserParseWeight := WhenParsePoundWeight;
  gBasisWeightManager.OnStatusChange := WhenBasisWeightStatusChange;
  gBasisWeightManager.StartService;
  {$ENDIF}

  if Assigned(gBXFontCardManager) then
    gBXFontCardManager.StartService;
end;

procedure THardwareWorker.AfterStopServer;
begin
  gVoiceHelper.StopVoice;
  //voice
  gRemotePrinter.StopPrinter;
  //printer

  gERelayManager.ControlStop;
  //erelay
  {$IFDEF JSLED}
  gCounterDisplayManager.StopDisplay;
  {$ENDIF}
  
  gMultiJSManager.StopJS;
  //counter

  g02NReader.StopReader;
  g02NReader.OnCardIn := nil;
  g02NReader.OnCardOut := nil;

  gHardwareHelper.StopRead;
  gHardwareHelper.OnProce := nil;
  //reader

  {$IFDEF HYRFID201}
  if Assigned(gHYReaderManager) then
  begin
    gHYReaderManager.StopReader;
    gHYReaderManager.OnCardProc := nil;
  end;
  {$ENDIF}

  {$IFDEF HKVDVR}
  gCameraManager.OnCameraProc := nil;
  gCameraManager.ControlStop;
  //Ӳ��¼���
  {$ENDIF}

  gDisplayManager.StopDisplay;
  //small led
  gCardManager.StopSender;
  //led

  gTruckQueueManager.StopQueue;
  //queue

  {$IFDEF MITTruckProber}
  gProberManager.StopProber;
  {$ENDIF}

  if Assigned(gM100ReaderManager) then
  begin
    gM100ReaderManager.StopReader;
    gM100ReaderManager.OnCardProc := nil;
  end;
  //����һ������

  if Assigned(gNetVoiceHelper) then
  begin
    gNetVoiceHelper.StopVoice;
  end;
  //��������

  {$IFDEF RemoteSnap}
  gHKSnapHelper.StopSnap;
  //remote snap
  {$ELSE}
    {$IFDEF PoundSaveSnapInfo}
    gHKSnapHelper.StopSnap;
    //remote snap
    {$ENDIF}
  {$ENDIF}

  {$IFDEF FixLoad}
  if Assigned(gSendCardNo) then
  gSendCardNo.StopPrinter;
  //sendcard
  {$ENDIF}

  {$IFDEF BasisWeight}
  gBasisWeightManager.StopService;
  gBasisWeightManager.OnStatusChange := nil;
  {$ENDIF}

  if Assigned(gBXFontCardManager) then
    gBXFontCardManager.StopService;
end;

end.

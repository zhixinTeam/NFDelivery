{*******************************************************************************
  作者: dmzn@163.com 2013-11-23
  描述: 模块工作对象,用于响应框架事件
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
    //主程序启动时初始化
    procedure BeforeStartServer; override;
    //服务启动之前调用
    procedure AfterStopServer; override;
    //服务关闭之后调用
    {$IFDEF DEBUG}
    procedure GetExtendMenu(const nList: TList); override;
    {$ENDIF}
  end;

var
  gPlugRunParam: TPlugRunParameter;
  //运行参数

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
    FModuleName := '硬件守护';
    FModuleVersion := '2014-09-30';
    FModuleDesc := '提供水泥一卡通发货的硬件处理对象';
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

    nStr := '远距读头';
    gHardwareHelper.LoadConfig(nCfg + '900MK.xml');
    
    nStr := '近距读头';
    if not Assigned(g02NReader) then
    begin
      g02NReader := T02NReader.Create;
      g02NReader.LoadConfig(nCfg + 'Readers.xml');
    end;

    nStr := '计数器';
    gMultiJSManager.LoadFile(nCfg + 'JSQ.xml');

    nStr := '继电器';
    gERelayManager.LoadConfig(nCfg + 'ERelay.xml');

    nStr := '远程打印';
    gRemotePrinter.LoadConfig(nCfg + 'Printer.xml');

    nStr := '语音服务';
    gVoiceHelper.LoadConfig(nCfg + 'Voice.xml');

    nStr := '喷码机';
    gCodePrinterManager.LoadConfig(nCfg + 'CodePrinter.xml');

    nStr := '小屏显示';
    gDisplayManager.LoadConfig(nCfg + 'LEDDisp.xml');

    {$IFDEF HKVDVR}
    nStr := '硬盘录像机';
    gCameraManager.LoadConfig(nCfg + cCameraXML);
    {$ENDIF}

    {$IFDEF HYRFID201}
    nStr := '华益RFID102';
    if not Assigned(gHYReaderManager) then
    begin
      gHYReaderManager := THYReaderManager.Create;
      gHYReaderManager.LoadConfig(nCfg + 'RFID102.xml');
    end;
    {$ENDIF}

    nStr := '三合一读卡器';
    if not Assigned(gM100ReaderManager) then
    begin
      gM100ReaderManager := TM100ReaderManager.Create;
      gM100ReaderManager.LoadConfig(nCfg + cTTCE_M100_Config);
    end;

    nStr := '车辆检测器';
    if FileExists(nCfg + 'TruckProber.xml') then
    begin
      gProberManager := TProberManager.Create;
      gProberManager.LoadConfig(nCfg + 'TruckProber.xml');
    end;

    nStr := '网络语音服务';
    if FileExists(nCfg + 'NetVoice.xml') then
    begin
      gNetVoiceHelper := TNetVoiceManager.Create;
      gNetVoiceHelper.LoadConfig(nCfg + 'NetVoice.xml');
    end;

    {$IFDEF JSLED}
    nStr := '计数器显示';
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
    nStr := '海康威视远程抓拍';
    if FileExists(nCfg + 'RemoteSnap.xml') then
    begin
      //gHKSnapHelper := THKSnapHelper.Create;
      gHKSnapHelper.LoadConfig(nCfg + 'RemoteSnap.xml');
    end;
    {$ELSE}
      {$IFDEF PoundSaveSnapInfo}
      nStr := '海康威视远程抓拍';
      if FileExists(nCfg + 'RemoteSnap.xml') then
      begin
        //gHKSnapHelper := THKSnapHelper.Create;
        gHKSnapHelper.LoadConfig(nCfg + 'RemoteSnap.xml');
      end;
      {$ENDIF}
    {$ENDIF}
    {$IFDEF FixLoad}
    nStr := '定置装车';
    gSendCardNo.LoadConfig(nCfg + 'PLCController.xml');
    {$ENDIF}
    {$IFDEF BasisWeight}
    nStr := '定量装车业务';
    gBasisWeightManager := TBasisWeightManager.Create;
    gBasisWeightManager.LoadConfig(nCfg + 'Tunnels.xml');
    {$ENDIF}

    {$IFDEF LedNew}
    nStr := '散装网口小屏(新驱动)';
    if not Assigned(gBXFontCardManager) then
    begin
      gBXFontCardManager := TBXFontCardManager.Create;
      gBXFontCardManager.LoadConfig(nCfg + 'BXFontLED.xml');
    end;
    {$ENDIF}
  except
    on E:Exception do
    begin
      nStr := Format('加载[ %s ]配置文件失败: %s', [nStr, E.Message]);
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
  nItem.FCaption := '硬件测试';
  nItem.FFormID := cFI_FormTest2;
  nItem.FDefault := False;
end;
{$ENDIF}

procedure THardwareWorker.InitSystemObject;
begin
  gHardwareHelper := THardwareHelper.Create;
  //远距读头

  if not Assigned(gMultiJSManager) then
    gMultiJSManager := TMultiJSManager.Create;
  //计数器 

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
  //硬盘录像机
  {$ENDIF}

  g02NReader.OnCardIn := WhenReaderCardIn;
  g02NReader.OnCardOut := WhenReaderCardOut;
  g02NReader.StartReader;
  //near reader

  {$IFDEF JSLED}
  //计数器显示屏
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
  //三合一读卡器

  if Assigned(gNetVoiceHelper) then
  begin
    gNetVoiceHelper.StartVoice;
  end;
  //启动语音

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
  //硬盘录像机
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
  //三合一读卡器

  if Assigned(gNetVoiceHelper) then
  begin
    gNetVoiceHelper.StopVoice;
  end;
  //启动语音

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

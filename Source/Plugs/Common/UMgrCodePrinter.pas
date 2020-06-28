{*******************************************************************************
  ����: dmzn@163.com 2012-09-07
  ����: �����(����)������
*******************************************************************************}
unit UMgrCodePrinter;

{$I Link.inc}
interface

uses
  Windows, Classes, SysUtils, SyncObjs, UWaitItem, IdComponent, IdGlobal,
  IdTCPConnection, IdTCPClient, NativeXml, ULibFun, USysLoger;

const
  cCP_KeepOnLine = 3 * 1000;     //���߱���ʱ��
  //CP=code printer

type
  GZWM = record
    fname: string;
    fValue: string;
end;

TarrGZWM = array of GZWM;
  
type
  PCodePrinter = ^TCodePrinter;
  TCodePrinter = record
    FID     : string;            //��ʶ
    FIP     : string;            //��ַ
    FPort   : Integer;           //�˿�
    FTunnel : string;            //ͨ��

    FDriver : string;            //����
    FVersoin: Integer;           //�汾
    FResponse  : Boolean;        //��Ӧ��
    FOnline : Boolean;           //����
    FLastOn : Int64;             //�ϴ�����
    FEnable : Boolean;           //����
    FChinaEnable : Boolean;        //���ú�������
    FOptions   : TStrings;          //����ѡ��
  end;

  TCodePrinterManager = class;
  //define manager object
  
  TCodePrinterBase = class(TObject)
  protected
    FPrinter: PCodePrinter;
    //�����
    FClient: TIdTCPClient;
    //�ͻ���
    FFlagLock: Boolean;
    //�������
    function PrintCode(const nCode: string;
     var nHint: string; const nVersion: Integer=0): Boolean; virtual; abstract;
    //��ӡ����
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    class function DriverName: string; virtual; abstract;
    //��������
    function Print(const nPrinter: PCodePrinter; const nCode: string;
     var nHint: string): Boolean;
    //��ӡ����
    function IsOnline(const nPrinter: PCodePrinter): Boolean;
    //�Ƿ�����
    procedure LockMe;
    procedure UnlockMe;
    function IsLocked: Boolean;
    //����״̬
  end;

  TCodePrinterMonitor = class(TThread)
  private
    FOwner: TCodePrinterManager;
    //ӵ����
    FWaiter: TWaitObject;
    //�ȴ�����
  protected
    procedure Execute; override;
    //ִ���߳�
  public
    constructor Create(AOwner: TCodePrinterManager);
    destructor Destroy; override;
    //�����ͷ�
    procedure StopMe;
    //ֹͣ�߳�
  end;

  TCodePrinterDriverClass = class of TCodePrinterBase;
  //the driver class define

  TCodePrinterManager = class(TObject)
  private
    FDriverClass: array of TCodePrinterDriverClass;
    FDrivers: array of TCodePrinterBase;
    //�����б�
    FPrinters: TList;
    //������б�
    FMonIdx: Integer;
    FMonitor: array[0..1]of TCodePrinterMonitor;
    //����߳�
    FTunnelCode: TStrings;
    //ͨ������
    FSyncLock: TCriticalSection;
    //ͬ������
    FEnablePrinter: Boolean;
    FEnableJSQ: Boolean;
    //ϵͳ����
  protected
    procedure ClearDrivers;
    procedure ClearPrinters(const nFree: Boolean);
    //�ͷ���Դ
    function GetPrinter(const nTunnel: string): PCodePrinter;
    //���������
  public
    gValue:TarrGZWM;
    gValueEx:TarrGZWM;
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure LoadConfig(const nFile: string);
    //��������
    procedure StartMon;
    procedure StopMon;
    //��ͣ���
    procedure RegDriver(const nDriver: TCodePrinterDriverClass);
    //ע������
    function LockDriver(const nName: string): TCodePrinterBase;
    procedure UnlockDriver(const nDriver: TCodePrinterBase);
    //��ȡ����
    function PrintCode(const nTunnel,nCode: string; var nHint: string): Boolean;
    //��ӡ����
    function IsPrinterOnline(const nTunnel: string): Boolean;
    //�Ƿ�����
    function IsPrinterEnable(const nTunnel: string): Boolean;
    procedure PrinterEnable(const nTunnel: string; const nEnable: Boolean);
    //��ͣ�����
    function IsPrinterChinaEnable(const nTunnel: string): Boolean;
    procedure PrinterChinaEnable(const nTunnel: string; const nEnable: Boolean);
    //��ͣ�����
    property EnablePrinter: Boolean read FEnablePrinter;
    //�������
  end;

var
  gCodePrinterManager: TCodePrinterManager = nil;
  //ȫ��ʹ��

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TCodePrinterManager, '�����������', nEvent);
end;

//------------------------------------------------------------------------------
constructor TCodePrinterMonitor.Create(AOwner: TCodePrinterManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 2 * 1000;
end;

destructor TCodePrinterMonitor.Destroy;
begin
  FWaiter.Free;
  inherited;
end;

procedure TCodePrinterMonitor.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TCodePrinterMonitor.Execute;
var nPrinter: PCodePrinter;
    nDriver: TCodePrinterBase;
begin
  while not Terminated do
  with FOwner do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    FSyncLock.Enter;
    try
      if FMonIdx >= FPrinters.Count then
        FMonIdx := 0;
      //xxxxx
    finally
      FSyncLock.Leave;
    end;

    while True do
    begin
      FSyncLock.Enter;
      try
        nPrinter := nil;
        if FMonIdx >= FPrinters.Count then Break;
        
        nPrinter := FPrinters[FMonIdx];
        Inc(FMonIdx);

        if not nPrinter.FEnable then Continue;
        if GetTickCount - nPrinter.FLastOn < cCP_KeepOnLine then Continue;
      finally
        FSyncLock.Leave;
      end;

      if not Assigned(nPrinter) then Break;
      nDriver := LockDriver(nPrinter.FDriver);
      try
        nDriver.IsOnline(nPrinter);
      finally
        UnlockDriver(nDriver);
      end;
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//------------------------------------------------------------------------------
constructor TCodePrinterManager.Create;
begin
  FEnablePrinter := False;
  FEnableJSQ := False;

  FPrinters := TList.Create;
  FTunnelCode := TStringList.Create;
  FSyncLock := TCriticalSection.Create;

  //������ī
  SetLength(gValue,38);
  gValue[0].fname := '0';
  gValue[0].fValue:= '708898A8C88870000000000000000000';
  gValue[1].fname := '1';
  gValue[1].fValue:= '20602020202070000000000000000000';
  gValue[2].fname := '2';
  gValue[2].fValue:= '708808304080F8000000000000000000';
  gValue[3].fname := '3';
  gValue[3].fValue:= 'F8102010088870000000000000000000';
  gValue[4].fname := '4';
  gValue[4].fValue:= '10305090F81010000000000000000000';
  gValue[5].fname := '5';
  gValue[5].fValue:= 'F880F008088870000000000000000000';
  gValue[6].fname := '6';
  gValue[6].fValue:= '304080F0888870000000000000000000';
  gValue[7].fname := '7';
  gValue[7].fValue:= 'F8081020404040000000000000000000';
  gValue[8].fname := '8';
  gValue[8].fValue:= '70888870888870000000000000000000';
  gValue[9].fname := '9';
  gValue[9].fValue:= '70888878081060000000000000000000';
  gValue[10].fname := 'A';
  gValue[10].fValue:= '70888888F88888000000000000000000';
  gValue[11].fname := 'B';
  gValue[11].fValue:= 'F08888F08888F0000000000000000000';
  gValue[12].fname := 'C';
  gValue[12].fValue:= '70888080808870000000000000000000';
  gValue[13].fname := 'D';
  gValue[13].fValue:= 'F08888888888F0000000000000000000';
  gValue[14].fname := 'E';
  gValue[14].fValue:= 'F88080F08080F8000000000000000000';
  gValue[15].fname := 'F';
  gValue[15].fValue:= 'F88080F0808080000000000000000000';
  gValue[16].fname := 'G';
  gValue[16].fValue:= '70888098888878000000000000000000';
  gValue[17].fname := 'H';
  gValue[17].fValue:= '888888F8888888000000000000000000';
  gValue[18].fname := 'I';
  gValue[18].fValue:= 'F82020202020F8000000000000000000';
  gValue[19].fname := 'J';
  gValue[19].fValue:= '38101010109060000000000000000000';
  gValue[20].fname := 'K';
  gValue[20].fValue:= '8890A0C0A09088000000000000000000';
  gValue[21].fname := 'L';
  gValue[21].fValue:= '808080808080F8000000000000000000';
  gValue[22].fname := 'M';
  gValue[22].fValue:= '88D8A8A8888888000000000000000000';
  gValue[23].fname := 'N';
  gValue[23].fValue:= '8888C8A8988888000000000000000000';
  gValue[24].fname := 'O';
  gValue[24].fValue:= '70888888888870000000000000000000';
  gValue[25].fname := 'P';
  gValue[25].fValue:= 'F08888F0808080000000000000000000';
  gValue[26].fname := 'Q';
  gValue[26].fValue:= '70888888A89068000000000000000000';
  gValue[27].fname := 'R';
  gValue[27].fValue:= 'F08888F0A09088000000000000000000';
  gValue[28].fname := 'S';
  gValue[28].fValue:= '70888070088870000000000000000000';
  gValue[29].fname := 'T';
  gValue[29].fValue:= 'F8202020202020000000000000000000';
  gValue[30].fname := 'U';
  gValue[30].fValue:= '88888888888870000000000000000000';
  gValue[31].fname := 'V';
  gValue[31].fValue:= '88888888885020000000000000000000';
  gValue[32].fname := 'W';
  gValue[32].fValue:= '888888A8A8A850000000000000000000';
  gValue[33].fname := 'X';
  gValue[33].fValue:= '88885020508888000000000000000000';
  gValue[34].fname := 'Y';
  gValue[34].fValue:= '88888850202020000000000000000000';
  gValue[35].fname := 'Z';
  gValue[35].fValue:= 'F80810204080F8000000000000000000';
  gValue[36].fname := '_';
  gValue[36].fValue:= '000000000000FF000000000000000000';
  gValue[37].fname := '-';
  gValue[37].fValue:= '0000007F000000000000000000000000';

  //������ī����
  SetLength(gValueEx,38);
  gValueEx[0].fname := '0';
  gValueEx[0].fValue:= '708898A8C8887000';
  gValueEx[1].fname := '1';
  gValueEx[1].fValue:= '2060202020207000';
  gValueEx[2].fname := '2';
  gValueEx[2].fValue:= '708808304080F800';
  gValueEx[3].fname := '3';
  gValueEx[3].fValue:= 'F810201008887000';
  gValueEx[4].fname := '4';
  gValueEx[4].fValue:= '10305090F8101000';
  gValueEx[5].fname := '5';
  gValueEx[5].fValue:= 'F880F00808887000';
  gValueEx[6].fname := '6';
  gValueEx[6].fValue:= '304080F088887000';
  gValueEx[7].fname := '7';
  gValueEx[7].fValue:= 'F808102040404000';
  gValueEx[8].fname := '8';
  gValueEx[8].fValue:= '7088887088887000';
  gValueEx[9].fname := '9';
  gValueEx[9].fValue:= '7088887808106000';
  gValueEx[10].fname := 'A';
  gValueEx[10].fValue:= '70888888F8888800';
  gValueEx[11].fname := 'B';
  gValueEx[11].fValue:= 'F08888F08888F000';
  gValueEx[12].fname := 'C';
  gValueEx[12].fValue:= '7088808080887000';
  gValueEx[13].fname := 'D';
  gValueEx[13].fValue:= 'F08888888888F000';
  gValueEx[14].fname := 'E';
  gValueEx[14].fValue:= 'F88080F08080F800';
  gValueEx[15].fname := 'F';
  gValueEx[15].fValue:= 'F88080F080808000';
  gValueEx[16].fname := 'G';
  gValueEx[16].fValue:= '7088809888887800';
  gValueEx[17].fname := 'H';
  gValueEx[17].fValue:= '888888F888888800';
  gValueEx[18].fname := 'I';
  gValueEx[18].fValue:= 'F82020202020F800';
  gValueEx[19].fname := 'J';
  gValueEx[19].fValue:= '3810101010906000';
  gValueEx[20].fname := 'K';
  gValueEx[20].fValue:= '8890A0C0A0908800';
  gValueEx[21].fname := 'L';
  gValueEx[21].fValue:= '808080808080F800';
  gValueEx[22].fname := 'M';
  gValueEx[22].fValue:= '88D8A8A888888800';
  gValueEx[23].fname := 'N';
  gValueEx[23].fValue:= '8888C8A898888800';
  gValueEx[24].fname := 'O';
  gValueEx[24].fValue:= '7088888888887000';
  gValueEx[25].fname := 'P';
  gValueEx[25].fValue:= 'F08888F080808000';
  gValueEx[26].fname := 'Q';
  gValueEx[26].fValue:= '70888888A8906800';
  gValueEx[27].fname := 'R';
  gValueEx[27].fValue:= 'F08888F0A0908800';
  gValueEx[28].fname := 'S';
  gValueEx[28].fValue:= '7088807008887000';
  gValueEx[29].fname := 'T';
  gValueEx[29].fValue:= 'F820202020202000';
  gValueEx[30].fname := 'U';
  gValueEx[30].fValue:= '8888888888887000';
  gValueEx[31].fname := 'V';
  gValueEx[31].fValue:= '8888888888502000';
  gValueEx[32].fname := 'W';
  gValueEx[32].fValue:= '888888A8A8A85000';
  gValueEx[33].fname := 'X';
  gValueEx[33].fValue:= '8888502050888800';
  gValueEx[34].fname := 'Y';
  gValueEx[34].fValue:= '8888885020202000';
  gValueEx[35].fname := 'Z';
  gValueEx[35].fValue:= 'F80810204080F800';
  gValueEx[36].fname := '_';
  gValueEx[36].fValue:= '000000000000FF00';
  gValueEx[37].fname := '-';
  gValueEx[37].fValue:= '0000007F00000000';
end;

destructor TCodePrinterManager.Destroy;
begin
  StopMon;
  ClearDrivers;
  ClearPrinters(True);

  FTunnelCode.Free;
  FSyncLock.Free;
  SetLength(gValue, 0);
  SetLength(gValueEx, 0);
  inherited;
end;

procedure TCodePrinterManager.ClearPrinters(const nFree: Boolean);
var nIdx: Integer;
    nPrinter: PCodePrinter;
begin
  FSyncLock.Enter;
  try
    for nIdx:=FPrinters.Count - 1 downto 0 do
    begin
      nPrinter := FPrinters[nIdx];
      if Assigned(nPrinter.FOptions) then
        FreeAndNil(nPrinter.FOptions);
      Dispose(nPrinter);
    end;
    //xxxxx

    if nFree then
         FPrinters.Free
    else FPrinters.Clear;
  finally
    FSyncLock.Leave;
  end;
end;

procedure TCodePrinterManager.ClearDrivers;
var nIdx: Integer;
begin
  for nIdx:=Low(FDrivers) to High(FDrivers) do
    FDrivers[nIdx].Free;
  SetLength(FDrivers, 0);
end;

procedure TCodePrinterManager.StartMon;
var nIdx: Integer;
begin
  if FEnablePrinter then
  begin
    if FPrinters.Count > 0 then
         FMonIdx := 0
    else Exit;

    for nIdx:=Low(FMonitor) to High(FMonitor) do
    begin
      FMonitor[nIdx] := nil;
      Exit; //�ر���������߼��

      if nIdx >= FPrinters.Count then Break;
      //̽���̲߳��������������

      if not Assigned(FMonitor[nIdx]) then
        FMonitor[nIdx] := TCodePrinterMonitor.Create(Self);
      //xxxxx
    end;
  end;
end;

procedure TCodePrinterManager.StopMon;
var nIdx: Integer;
begin
  for nIdx:=Low(FMonitor) to High(FMonitor) do
   if Assigned(FMonitor[nIdx]) then
   begin
     FMonitor[nIdx].StopMe;
     FMonitor[nIdx] := nil;
   end;
end;

procedure TCodePrinterManager.RegDriver(const nDriver: TCodePrinterDriverClass);
var nIdx: Integer;
begin
  for nIdx:=Low(FDriverClass) to High(FDriverClass) do
   if FDriverClass[nIdx].DriverName = nDriver.DriverName then Exit;
  //driver exists

  nIdx := Length(FDriverClass);
  SetLength(FDriverClass, nIdx + 1);
  FDriverClass[nIdx] := nDriver;
end;

//Date: 2012-9-7
//Parm: ��������
//Desc: ����nName��������
function TCodePrinterManager.LockDriver(const nName: string): TCodePrinterBase;
var nIdx,nInt: Integer;
begin
  Result := nil;
  FSyncLock.Enter;
  try
    for nIdx:=Low(FDrivers) to High(FDrivers) do
    if (not FDrivers[nIdx].IsLocked) and
       (CompareText(FDrivers[nIdx].DriverName, nName) = 0) then
    begin
      Result := FDrivers[nIdx];
      Exit;
    end;

    for nIdx:=Low(FDriverClass) to High(FDriverClass) do
    if CompareText(FDriverClass[nIdx].DriverName, nName) = 0 then
    begin
      nInt := Length(FDrivers);
      SetLength(FDrivers, nInt + 1);

      Result := FDriverClass[nIdx].Create;
      FDrivers[nInt] := Result;
      Exit;
    end;

    WriteLog(Format('�޷���������Ϊ[ %s ]���������.', [nName]));
  finally
    if Assigned(Result) then
      Result.LockMe;
    FSyncLock.Leave;
  end;
end;

//Date: 2012-9-7
//Parm: ��������
//Desc: ��nDriver����
procedure TCodePrinterManager.UnlockDriver(const nDriver: TCodePrinterBase);
begin
  if Assigned(nDriver) then
  begin
    FSyncLock.Enter;
    nDriver.UnlockMe;
    FSyncLock.Leave;
  end;
end;

//Date: 2012-9-7
//Parm: ͨ��
//Desc: ����nTunnelͨ���ϵ������
function TCodePrinterManager.GetPrinter(const nTunnel: string): PCodePrinter;
var nIdx: Integer;
begin
  Result := nil;

  for nIdx:=FPrinters.Count - 1 downto 0 do
  begin
    Result := FPrinters[nIdx];
    if CompareText(Result.FTunnel, nTunnel) = 0 then
         Break
    else Result := nil;
  end;
end;

//Date: 2012-9-7
//Parm: ͨ��
//Desc: �ж�nTunnel��������Ƿ�����
function TCodePrinterManager.IsPrinterOnline(const nTunnel: string): Boolean;
var nPrinter: PCodePrinter;
    nDriver: TCodePrinterBase;
begin
  if not FEnablePrinter then
  begin
    Result := True;
    Exit;
  end;

  Result := False;
  nPrinter := GetPrinter(nTunnel);

  if not Assigned(nPrinter) then
  begin
    WriteLog(Format('ͨ��[ %s ]û�����������.', [nTunnel]));
    Exit;
  end;
  
  nDriver := nil;
  try
    nDriver := LockDriver(nPrinter.FDriver);
    if Assigned(nDriver) then
      Result := nDriver.IsOnline(nPrinter);
    //xxxxx
  finally
    UnlockDriver(nDriver);
  end;
end;

//Date: 2013-07-23
//Parm: ͨ����
//Desc: ��ѯnTunnelͨ���ϵ������״̬
function TCodePrinterManager.IsPrinterEnable(const nTunnel: string): Boolean;
var nPrinter: PCodePrinter;
begin
  Result := False;

  if FEnablePrinter then
  begin
    nPrinter := GetPrinter(nTunnel);
    if Assigned(nPrinter) then
      Result := nPrinter.FEnable;
    //xxxxx
  end;
end;

//Date: 2012-9-7
//Parm: ͨ��;��ͣ��ʶ
//Desc: ��ͣnTunnelͨ���ϵ������
procedure TCodePrinterManager.PrinterEnable(const nTunnel: string;
  const nEnable: Boolean);
var nPrinter: PCodePrinter;
begin
  if FEnablePrinter then
  begin
    nPrinter := GetPrinter(nTunnel);
    if Assigned(nPrinter) then
      nPrinter.FEnable := nEnable;
    //xxxxx
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/10/16
//Parm: ͨ����
//Desc: ��ѯnTunnelͨ���ϵ������״̬(����)
function TCodePrinterManager.IsPrinterChinaEnable(const nTunnel: string): Boolean;
var nPrinter: PCodePrinter;
begin
  Result := False;

  if FEnablePrinter then
  begin
    nPrinter := GetPrinter(nTunnel);
    if Assigned(nPrinter) then
      Result := nPrinter.FEnable and nPrinter.FChinaEnable;
    //xxxxx
  end;
end;

//Date: 2015/10/16
//Parm: ͨ��;��ͣ��ʶ
//Desc: ��ͣnTunnelͨ���ϵ������
procedure TCodePrinterManager.PrinterChinaEnable(const nTunnel: string;
  const nEnable: Boolean);
var nPrinter: PCodePrinter;
begin
  if FEnablePrinter then
  begin
    nPrinter := GetPrinter(nTunnel);
    if Assigned(nPrinter) then
      nPrinter.FChinaEnable := nEnable and nPrinter.FEnable;
    //xxxxx
  end;
end;

//Date: 2012-9-7
//Parm: ͨ��;����
//Desc: ��nTunnelͨ����������ϴ�ӡnCode
function TCodePrinterManager.PrintCode(const nTunnel, nCode: string;
  var nHint: string): Boolean;
var nPrinter: PCodePrinter;
    nDriver: TCodePrinterBase;
begin
  if not FEnablePrinter then
  begin
    Result := True;
    Exit;
  end;

  if Length(nCode) < 1 then
  begin
    Result := True;
    Exit;
  end; //ͨ�������ѷ���
  
  Result := False;
  nPrinter := GetPrinter(nTunnel);

  if not Assigned(nPrinter) then
  begin
    nHint := Format('ͨ��[ %s ]û�����������.', [nTunnel]);
    Exit;
  end;
  
  nDriver := nil;
  try
    nDriver := LockDriver(nPrinter.FDriver);
    if Assigned(nDriver) then
         Result := nDriver.Print(nPrinter, nCode, nHint)
    else nHint := Format('��������Ϊ[ %s ]�������ʧ��.', [nPrinter.FDriver]);
  finally
    UnlockDriver(nDriver);
  end;

  if Result then
    FTunnelCode.Values[nTunnel] := nCode;
  //�����ϴ���Ч����
end;

//Desc: ��ȡnFile����������ļ�
procedure TCodePrinterManager.LoadConfig(const nFile: string);
var nIdx: Integer;
    nResponse: Boolean;
    nXML: TNativeXml;
    nNode,nTmp,nPNode: TXmlNode;
    nPrinter: PCodePrinter;
begin
  nXML := TNativeXml.Create;
  try
    ClearPrinters(False);
    nXML.LoadFromFile(nFile);

    nResponse := False;
    nTmp := nXML.Root.FindNode('config');

    if Assigned(nTmp) then
    begin
      nIdx := nTmp.NodeByName('enableprinter').ValueAsInteger;
      FEnablePrinter := nIdx = 1;

      nIdx := nTmp.NodeByName('enablejsq').ValueAsInteger;
      FEnableJSQ := nIdx = 1;

      nNode := nTmp.FindNode('response');
      if Assigned(nNode) then
        nResponse := nNode.ValueAsInteger = 1;
      //ȫ������: �Ƿ��Ӧ����
    end;

    nTmp := nXML.Root.FindNode('printers');
    if Assigned(nTmp) then
    begin
      for nIdx:=0 to nTmp.NodeCount - 1 do
      begin
        New(nPrinter);
        FPrinters.Add(nPrinter);

        nNode := nTmp.Nodes[nIdx];
        with nPrinter^ do
        begin
          FID := nNode.AttributeByName['id'];
          FIP := nNode.NodeByName('ip').ValueAsString;
          FPort := nNode.NodeByName('port').ValueAsInteger;

          FTunnel := nNode.NodeByName('tunnel').ValueAsString;
          FDriver := nNode.NodeByName('driver').ValueAsString;
          FVersoin:= StrToIntDef(nNode.NodeByName('driver').AttributeByName['Version'],0);
          FEnable := nNode.NodeByName('enable').ValueAsInteger = 1;

          FResponse := nResponse;
          if Assigned(nNode.FindNode('response')) then
            FResponse := nNode.NodeByName('response').ValueAsInteger = 1;
          //xxxxx
          
          nPNode  := nNode.FindNode('chinaenable');
          if not Assigned(nPNode) then
                FChinaEnable := False
          else  FChinaEnable := nPNode.ValueAsString = '1';

          if Assigned(nNode.FindNode('options')) then
          begin
            FOptions := TStringList.Create;
            SplitStr(nNode.FindNode('options').ValueAsString, FOptions, 0, ';');
          end else FOptions := nil;

          FOnline := False;
          FLastOn := 0;
        end;
      end;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TCodePrinterBase.Create;
begin
  FFlagLock := False;
  FClient := TIdTCPClient.Create;
  FClient.ConnectTimeout := 5 * 1000;
  FClient.ReadTimeout := 3 * 1000;
end;

destructor TCodePrinterBase.Destroy;
begin
  FClient.Disconnect;
  FClient.Free;
  inherited;
end;

procedure TCodePrinterBase.LockMe;
begin
  FFlagLock := True;
end;

procedure TCodePrinterBase.UnlockMe;
begin
  FFlagLock := False;
end;

function TCodePrinterBase.IsLocked: Boolean;
begin
  Result := FFlagLock;
end;

//Desc: �ж�nPrinter�Ƿ�����
function TCodePrinterBase.IsOnline(const nPrinter: PCodePrinter): Boolean;
begin
  if (not nPrinter.FEnable) or
     (GetTickCount - nPrinter.FLastOn < cCP_KeepOnLine) then
  begin
    Result := True;
    Exit;
  end else Result := False;

  try
    if (FClient.Host <> nPrinter.FIP) or (FClient.Port <> nPrinter.FPort) then
    begin
      FClient.Disconnect;
      if Assigned(FClient.IOHandler) then
        FClient.IOHandler.InputBuffer.Clear;
      //xxxxx

      FClient.Host := nPrinter.FIP;
      FClient.Port := nPrinter.FPort;
    end;

    if not FClient.Connected then
      FClient.Connect;
    Result := FClient.Connected;

    nPrinter.FOnline := Result;
    if Result then
      nPrinter.FLastOn := GetTickCount;
    //xxxxx
  except
    FClient.Disconnect;
    if Assigned(FClient.IOHandler) then
      FClient.IOHandler.InputBuffer.Clear;
    //xxxxx
  end;
end;

//Date: 2012-9-7
//Parm: �����;����
//Desc: ��nPrinter����nCode����.
function TCodePrinterBase.Print(const nPrinter: PCodePrinter;
  const nCode: string; var nHint: string): Boolean;
begin
  if not nPrinter.FEnable then
  begin
    Result := True;
    Exit;
  end else Result := False;

  if not IsOnline(nPrinter) then
  begin
    nHint := Format('�����[ %s ]����ͨѶ�쳣.', [nPrinter.FID]);
    Exit;
  end;

  try
    if Assigned(FClient.IOHandler) then
    begin
      FClient.IOHandler.InputBuffer.Clear;
      FClient.IOHandler.WriteBufferClear;
    end;

    FPrinter := nPrinter;
    Result := PrintCode(nCode, nHint, nPrinter.FVersoin);
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
      nHint := Format('�������[ %s ]��������ʧ��.', [nPrinter.FID]);

      FClient.Disconnect;
      if Assigned(FClient.IOHandler) then
        FClient.IOHandler.InputBuffer.Clear;
      //xxxxx
    end;
  end;
end;

//------------------------------------------------------------------------------
type
  TByteWord = record
    FH: Byte;
    FL: Byte;
  end;

function CalCRC16(data, crc, genpoly: Word): Word;
var i: Word;
begin
  data := data shl 8;                       // �Ƶ����ֽ�
  for i:=7 downto 0 do
  begin
    if ((data xor crc) and $8000) <> 0 then //ֻ�������λ
         crc := (crc shl 1) xor genpoly     // ���λΪ1����λ�������
    else crc := crc shl 1;                  // ����ֻ��λ����2��
    data := data shl 1;                     // ������һλ
  end;

  Result := crc;
end;

function CRC16(const nStr: string; const nStart,nEnd: Integer): Word;
var nIdx: Integer;
begin
  Result := 0;
  if (nStart > nEnd) or (nEnd < 1) then Exit;

  for nIdx:=nStart to nEnd do
  begin
    Result := CalCRC16(Ord(nStr[nIdx]), Result, $1021);
  end;
end;

function ModbusCRC(const nData: string): Word;
const
  cPoly = $A001; //����ʽ��A001(1010 0000 0000 0001)
var i,nIdx,nLen: Integer;
    nNoZero: Boolean;
begin
  Result := $FFFF;
  nLen := Length(nData);

  for nIdx:=1 to nLen do
  begin
    Result := Ord(nData[nIdx]) xor Result;
    for i:=1 to 8 do
    begin
      nNoZero := Result and $0001 <> 0;
      Result := Result shr 1;

      if nNoZero then
        Result := Result xor cPoly;
      //xxxxx
    end;
  end;
end;

function strtoascii(const inputAnsi:string): integer;
//�ַ���ת��Ϊasciiֵ,ת��ֵ��һ��������ֵ��Ӻ�Ľ��
var
  Ansitemp,i,OutPutAnsi :integer;
begin
  OutPutAnsi:=0;
  For i:=0 To Length(inputAnsi) Do
    begin
      Ansitemp := ord(inputAnsi[i]);
      outputansi := OutPutAnsi+Ansitemp;
    end;
  Result:= OutPutAnsi;
end;

function CRC12(const Lenth: integer; const RXBUFFER: TByteArray): Integer;
var
  crc12out : Integer;
  i,j : Integer;
begin
  Result := 0;
  crc12out :=0;

	for j:=0 to Lenth-1 do
  begin
	   for i:=0 to 7 do
     begin
	  	if (Ord(RXBUFFER[j]) and ($80 shr i)) <> 0 then
         crc12out := crc12out or $1;
	  	if(crc12out>=$1000) then
        crc12out := crc12out xor $180d;
      crc12out :=	crc12out shl 1;
     end;
	 end;
	 for i :=0 to 11 do
	 begin
	 	if(crc12out>=$1000) then
      crc12out := crc12out xor $180d;
	  crc12out :=	crc12out shl 1;
	 end;
   crc12out := crc12out shr 1;
   Result := crc12out;
end;

//------------------------------------------------------------------------------
type
  TPrinterZero = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string; const nVersion: Integer=0): Boolean; override;
  public
    class function DriverName: string; override;
  end;
  
class function TPrinterZero.DriverName: string;
begin
  Result := 'zero';
end;

//Desc: ��ӡ����
function TPrinterZero.PrintCode(const nCode: string;
  var nHint: string; const nVersion: Integer=0): Boolean;
var nStr,nData: string;
    nCrc: TByteWord;
    nBuf: TIdBytes;
    nDatatemp: string;
begin
  //protocol: 55 7F len order datas crc16 AA
  nData := Char($55) + Char($7F) + Char(Length(nCode) + 1);
  nData := nData + Char($54) + Char($01);
  nData := nData + nCode;

  nCrc := TByteWord(CRC16(nData, 5, Length(nData)));
  nData := nData + Char(nCrc.FH) + Char(nCrc.FL) + Char($AA);

  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(200);
  
  if FPrinter.FResponse then
  begin
    SetLength(nBuf, 0);
    FClient.Socket.ReadBytes(nBuf, 9, False);
    nStr := BytesToString(nBuf,Indy8BitEncoding);

    nData :=  Char($55) + Char($FF) + Char($02)+ Char($54)+ Char($4F);
    nData :=  nData + Char($4B)+ Char($5D) + Char($E4) + Char($AA);

    if nstr <> nData then
    begin
      nHint := '�����Ӧ�����!';
      Result := False;
      Exit;
    end;
  end;

  Result := True;
end;

//-----------------------------------------------------------------------
type
  TPrinterJY = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string; const nVersion: Integer=0): Boolean; override;
  public
    class function DriverName: string; override;
  end;

class function TPrinterJY.DriverName: string;
begin
  Result := 'JY';
end;

function TPrinterJY.PrintCode(const nCode: string;
  var nHint: string; const nVersion: Integer=0): Boolean;
var nStr,nData: string;
  nBuf: TIdBytes;
begin

  //���������
  //1B 41 len(start 38) channel(start 31) 40 37 datas 40 39 0D
  // 1B 41 29 Ϊ��ͷ����
  // 27 ��ʾ������ֵĸ��� ��27��ʾΪ1���� �����ķ�ʽΪ16����
  // 20 ��ʾͨ���ı���      ��20Ϊͨ��1��  �����ķ�ʽΪ16����
  // 40 37 ��ʾ�������ݵĿ�ʼ
  // ***  ���������        ���͵ķ�ʽΪASCII��
  // 40 39 ��ʾ�������ݵĽ�β
  // 0D   ��ʾ���崫�͵Ľ�β

  nData := Char($1B) + Char($41) + Char($29)+ Char(Length(nCode) + 38);
  nData := nData + Char(2 + 31) + Char($40) + Char($37);
  nData := nData + nCode + Char($40) + Char($39)+ Char($0D);

  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(200);

  if FPrinter.FResponse then
  begin
    SetLength(nBuf, 0);
    FClient.Socket.ReadBytes(nBuf, Length(nData), False);

    nStr := BytesToString(nBuf, Indy8BitEncoding);
    if nStr <> nData then
    begin
      nHint := '�����Ӧ�����!';
      Result := False;
      Exit;
    end;
  end;

  Result := True;
end;


//-----------------------------------------------------------------------
type
  TPrinterWSD = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string; const nVersion: Integer=0): Boolean; override;
  public
    class function DriverName: string; override;
  end;

class function TPrinterWSD.DriverName: string;
begin
  Result := 'WSD';
end;

function TPrinterWSD.PrintCode(const nCode: string;
  var nHint: string; const nVersion: Integer=0): Boolean;
var nStr,nData: string;
  nBuf: TIdBytes;
begin
  //��ʿ�������
  //1B 41 29 2A 20 40 37 32 33 34 35 40 39 0D

  //1B 41 29 ��ʼλ
  //2A ��ʾ����ָ�������ֽڳ���+20����ɫ���ɫ�ֵĳ��ȣ��������ķ�ʽΪ16����
  //20  ��ʾͨ���ı��루20Ϊͨ��1��21Ϊͨ��2���Դ����ƣ�  �����ķ�ʽΪ16����
  //40 37 ��ʾ�������ݵĿ�ʼ
  //40 39 ��ʾ�������ݵĽ�β
  //0D   ��ʾ���崫�͵Ľ�β

  nData := Char($1B) + Char($41) + Char($29)+ Char(Length(nCode) + 32 + 6);
  nData := nData+Char(2 + 31 )+Char($40)+Char($37);
  nData := nData+nCode;
  nData := nData+Char($40)+Char($39)+Char($0D);

  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(200);

  if FPrinter.FResponse then
  begin
    SetLength(nBuf, 0);
    FClient.Socket.ReadBytes(nBuf, Length(nData), False);

    nStr := BytesToString(nBuf, Indy8BitEncoding);
    if nStr <> nData then
    begin
      nHint := '�����Ӧ�����!';
      Result := False;
      Exit;
    end;
  end;

  Result := True;
end;

//-----------------------------------------------------------------------
type
  TPrinterSGB = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string; const nVersion: Integer=0): Boolean; override;
  public
    class function DriverName: string; override;
  end;

class function TPrinterSGB.DriverName: string;
begin
  Result := 'SGB';
end;

function TPrinterSGB.PrintCode(const nCode: string;
  var nHint: string; const nVersion: Integer=0): Boolean;
var nData: string;
    nBuf: TIdBytes;
begin
  //�˹������
  //1B 41 len(start 38) channel(start 31) 40 37 datas 40 39 0D
  //1B 41 2C 22 channel(start 31) 0D;
  nData := Char($1B) + Char($41) + Char($29)+ Char(Length(nCode) + 38);
  if nVersion=16 then                                        //16���ӡ����@6
       nData := nData + Char(2 + 31) + Char($40) + Char($36)
  else nData := nData + Char(2 + 31) + Char($40) + Char($37);//7 ���ӡ����@7
  nData := nData + nCode + Char($40) + Char($39)+ Char($0D);

  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(200);

  nData := Char($1B) + Char($41) + Char($2C) +Char($22);
  nData := nData + Char(2 + 31) + Char($0D);
  
  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(200);

  if FPrinter.FResponse then
  begin
    SetLength(nBuf, 0);
    FClient.Socket.ReadBytes(nBuf, Length(nData), False);
  end;

  Result := True;
end;

//------------------------------------------------------------------------------
type
  TPrinterWSDP011C = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string; const nVersion: Integer=0): Boolean; override;
  public
    class function DriverName: string; override;
  end;

class function TPrinterWSDP011C.DriverName: string;
begin
  Result := 'WSDP011C';
end;

//Desc: ��ӡ����
function TPrinterWSDP011C.PrintCode(const nCode: string;
  var nHint: string; const nVersion: Integer=0): Boolean;
var nStr,nData,nDataVerify: string;
    nCrc: TByteWord;
    nBuf: TIdBytes;
begin
  //protocol: 55 len order datas ModbusCRC AA
  nData := Char($55) + Char($00) + Char(Length(nCode) + 17);
  nData := nData + Char($53) + Char($4E);
  nData := nData + Char($03) + Char($00) + Char($00);

  {$IFDEF P011CEX}
  nData := nData + Char($FF);
  {$ELSE}
  nData := nData + Char($01);
  {$ENDIF}

  nDataVerify := Char($01) + Char($00) + Char($01) + Char($00) + Char(Length(nCode));
  nDataVerify := nDataVerify + nCode;

  nCrc := TByteWord(ModbusCRC(nDataVerify));
  nDataVerify := nDataVerify + Char(nCrc.FH) + Char(nCrc.FL) + Char($AA);

  nData := nData + nDataVerify;

  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(200);

  if FPrinter.FResponse then
  begin
    SetLength(nBuf, 0);
    FClient.Socket.ReadBytes(nBuf, 12, False);
    nStr := BytesToString(nBuf,Indy8BitEncoding);

    nData :=  Char($55) + Char($00) + Char($0C)+ Char($4F)+ Char($4B);
    nData :=  nData + Char($03)+ Char($00) + Char($00) + Char($01);
    nData :=  nData + Char($FF)+ Char($FF) + Char($AA);
    if nstr <> nData then
    begin
      nHint := '�����Ӧ�����!';
      Result := False;
      Exit;
    end;
  end;

  Result := True;
end;

//------------------------------------------------------------------------------
type
  TPrinterSL = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string;const nVersion: Integer=0): Boolean; override;
  public
    class function DriverName: string; override;
  end;

class function TPrinterSL.DriverName: string;
begin
  Result := 'SL';
end;

//Desc: ��ӡ����
function TPrinterSL.PrintCode(const nCode: string;
  var nHint: string;const nVersion: Integer=0): Boolean;
var nStr,nData,nDataVerify: string;
    nCrc: TByteWord;
    nBuf: TIdBytes;
    nList: TStrings;
    nIdx: Integer;
begin
  nList := TStringList.Create;
  try
    nList.Text := nCode;
    for nIdx := 1 to 2 do
    begin
      if nList.Values['Num'] <> '' then
      begin
        nData :=  Char($53) + Char($4d) + Char($5b)+ Char($35)+ Char($5d);
        nData := nData + Char($3d) + Char($28);
        nData := nData + Char($28) + Char($47) + Char($5b)+ nList.Values['Num'] + Char($5d);
        nData := nData + Char($40) + Char($30) + Char($3a)+ Char($30)+ Char($29)+ Char($2c);

        nData := nData + Char($28) + Char($54) + Char($5b)+ Char($31) + Char($5d);
        nData := nData + Char($40) + nList.Values['Pos'] + Char($3a)+ Char($30)+ Char($2c);

        nData := nData + Char($66) + Char($6f)+ Char($6e)+ Char($74)+ Char($3d) + Char($30);
        nData := nData + Char($2c);

        nData := nData + Char($73) + Char($69)+ Char($7a)+ Char($65)+ Char($3d) + nList.Values['Font'];
        nData := nData + Char($2c);

        nData := nData + Char($62) + Char($6f)+ Char($6c)+ Char($64)+ Char($3d) + Char($30);
        nData := nData + Char($2c);

        nData := nData + Char($78) + Char($73)+ Char($70)+ Char($3d) + Char($30);
        nData := nData + Char($2c);

        nData := nData + Char($6d) + Char($6f)+ Char($64)+ Char($65)+ Char($3d) + Char($30);
        nData := nData + Char($29) + Char($29)+ Char($2c);

        nData := nData + Char($4e) + Char($41) + Char($4d)+ Char($45)+ Char($3d)+ Char($22);
        nData := nData + Char($59) + Char($4b) + Char($54)+ Char($22)+ Char($0d)+ Char($0a);


//        nData := nData + Char($53) + Char($54) + Char($5b)+ Char($31)+ Char($5d);
//        nData := nData + Char($3d) + Char($22);
//        nData := nData + nList.Values['PrintCode'] + Char($22)+ Char($0d)+ Char($0a);

        WriteLog('���������:' + nData);

        FClient.Socket.Write(nData, Indy8BitEncoding);
        Sleep(100);
      end;
    end;

    for nIdx := 1 to 2 do
    begin
      nData :=  Char($53) + Char($54) + Char($5b)+ Char($31)+ Char($5d);
      nData := nData + Char($3d) + Char($22);
      nData := nData + nList.Values['PrintCode'] + Char($22)+ Char($0d)+ Char($0a);

      WriteLog('���������:' + nData);

      FClient.Socket.Write(nData, Indy8BitEncoding);
      Sleep(100);
    end;
  finally
    nList.Free;
  end;

//  if FPrinter.FResponse then
//  begin
//    SetLength(nBuf, 0);
//    FClient.Socket.ReadBytes(nBuf, 12, False);
//    nStr := BytesToString(nBuf,Indy8BitEncoding);
//    WriteLog('�����Ӧ��:' + nStr);
//    nData := 'ok';
//    if Pos(nData, nStr) <= 0 then
//    begin
//      nHint := '�����Ӧ�����!';
//      Result := False;
//      Exit;
//    end;
//  end;

  Result := True;
end;

//------------------------------------------------------------------------------
type
  TPrinterHYPM = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string;const nVersion: Integer=0): Boolean; override;
  public
    class function DriverName: string; override;
  end;

class function TPrinterHYPM.DriverName: string;
begin
  Result := 'HYPM';
end;

//Desc: ��ӡ����
function TPrinterHYPM.PrintCode(const nCode: string;
  var nHint: string;const nVersion: Integer=0): Boolean;
var nStr,nData: string;
    nCrc: TByteWord;
    nBuf: TIdBytes;
    crc:  Integer;
    Finstructions : TByteArray;
    i, nLength,nTmp,k,nTmp1 : Integer;
    str,sYY,nValue: string;
begin
  Finstructions[0]:=$02;

  str     := Trim(nCode);
  nLength := Length(str);
  Finstructions[1]:=(6+nlength);
  Finstructions[2]:=$01;
  Finstructions[3]:=$00;
  Finstructions[4]:=$00;
  Finstructions[5]:=$00;
  Finstructions[6]:=$00;
  Finstructions[7]:=$02;
  for i:=0 to nLength - 1 do
  begin
    nTmp := strtoascii(str[i+1]);
    k:=8+i;
    Finstructions[k] := nTmp  ;
  end;
  nData := Char($FE) + Char($FE);
  for i := 0 to (nLength + 8)-1 do
  nData := nData + Char(Finstructions[i]) ;
  crc := CRC12(8+nlength,Finstructions);
 // nData := nData + Copy(crc,1,2)+' '+Copy(crc,3,2) +Char($FA)+Char($FA);
  nData := nData + Char(crc) + Char($FA)+Char($FA);

  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(100);
  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(200);

//  if FPrinter.FResponse then
//  begin
//    SetLength(nBuf, 0);
//    FClient.Socket.ReadBytes(nBuf, 12, False);
//    nStr := BytesToString(nBuf,Indy8BitEncoding);
//
//    nData :=  Char($55) + Char($00) + Char($0C)+ Char($4F)+ Char($4B);
//    nData :=  nData + Char($03)+ Char($00) + Char($00) + Char($01);
//    nData :=  nData + Char($FF)+ Char($FF) + Char($AA);
//    if nstr <> nData then
//    begin
//      nHint := '�����Ӧ�����!';
//      Result := False;
//      Exit;
//    end;
//  end;

  Result := True;
end;

//������ī����һ����ʾ----------------------
type
  TPrinterWMPM = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string;const nVersion: Integer=0): Boolean; override;
  public
    class function DriverName: string; override;
  end;

class function TPrinterWMPM.DriverName: string;
begin
  Result := 'WMPM';
end;

//Desc: ��ӡ����
function TPrinterWMPM.PrintCode(const nCode: string;
  var nHint: string;const nVersion: Integer=0): Boolean;
var nStr,nData: string;
    nCrc,nCrcTmp: Word;
    nBuf: TIdBytes;
    crc:  Integer;
    Finstructions : TByteArray;
    i, nLength,nTmp,k,nTmp1 : Integer;
    str,sYY,nValue: string;
    nDataTmp:string;
  function strtoascii(const inputAnsi:string): integer;
  //�ַ���ת��Ϊasciiֵ,ת��ֵ��һ��������ֵ��Ӻ�Ľ��
  var
    Ansitemp,i,OutPutAnsi :integer;
  begin
    OutPutAnsi:=0;
    For i:=0 To Length(inputAnsi) Do
      begin
        Ansitemp := ord(inputAnsi[i]);
        outputansi := OutPutAnsi+Ansitemp;
      end;
    Result:= OutPutAnsi;
  end;
begin
  str := nCode;
  nDataTmp:='';
  for i:=1 to Length(str) do
  begin
    for k:=0 to High(gCodePrinterManager.gValue)  do
    begin
      if gCodePrinterManager.gValue[k].fname = str[i] then
      begin
        nDataTmp := nDataTmp + gCodePrinterManager.gValue[k].fValue;
        Break;
      end;

    end;
  end;
  nCrc := $46 xor $31;
  for i:=1 to Length(nDataTmp) do
  begin
    nCrcTmp:=strtoascii(nDataTmp[i]);
    nCrc := nCrc xor nCrcTmp;
  end;
  nData := Char($24)+ Char($46)+Char($31)+ndataTmp+char($2A)+IntToHex(nCrc,2)+Char($0D)+Char($0A);

  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(100);
  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(200);

  Result := True;
end;

//������ī���������ʾ,#�ŷָ�,#��ǰ�ǵ�һ�У�#���ǵڶ���----------------------
type
  TPrinterWMPMEx = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string;const nVersion: Integer=0): Boolean; override;
  public
    class function DriverName: string; override;
  end;


{ TPrinterWMPMEx }

class function TPrinterWMPMEx.DriverName: string;
begin
  Result := 'WMPM2';
end;

function TPrinterWMPMEx.PrintCode(const nCode: string;
  var nHint: string;const nVersion: Integer=0): Boolean;
var nStr,nData: string;
    nCrc,nCrcTmp: Word;
    nBuf: TIdBytes;
    crc:  Integer;
    Finstructions : TByteArray;
    i, nLength,nTmp,k, k2, nTmp1 : Integer;
    sYY,nValue,str1,str2: string;
    nDataTmp:string;
  function strtoascii(const inputAnsi:string): integer;
  //�ַ���ת��Ϊasciiֵ,ת��ֵ��һ��������ֵ��Ӻ�Ľ��
  var
    Ansitemp,i,OutPutAnsi :integer;
  begin
    OutPutAnsi:=0;
    For i:=0 To Length(inputAnsi) Do
      begin
        Ansitemp := ord(inputAnsi[i]);
        outputansi := OutPutAnsi+Ansitemp;
      end;
    Result:= OutPutAnsi;
  end;
begin
  str1:= Copy(nCode,1,Pos('#',nCode)-1);
  str2:= Copy(nCode,Pos('#',nCode)+1,MaxInt);

  nDataTmp:='';
  if Length(str1) >= Length(str2) then
  begin
    for i:=1 to Length(str1) do
    begin
      for k:=0 to High(gCodePrinterManager.gValueEx)  do
      begin
        if gCodePrinterManager.gValueEx[k].fname = str1[i] then
        begin
          nDataTmp := nDataTmp + gCodePrinterManager.gValueEx[k].fValue;
          Break;
        end;
      end;

      if i <= Length(str2) then
      begin
        for k2:=0 to High(gCodePrinterManager.gValueEx)  do
        begin
          if gCodePrinterManager.gValueEx[k2].fname = str2[i] then
          begin
            nDataTmp := nDataTmp + gCodePrinterManager.gValueEx[k2].fValue;
            Break;
          end;
        end;
      end
      else
      begin
        nDataTmp := nDataTmp + '0000000000000000';
      end;
    end;
  end
  else
  begin
    for i:=1 to Length(str2) do
    begin
      if i <= Length(str1) then
      begin
        for k:=0 to High(gCodePrinterManager.gValueEx)  do
        begin
          if gCodePrinterManager.gValueEx[k].fname = str1[i] then
          begin
            nDataTmp := nDataTmp + gCodePrinterManager.gValueEx[k].fValue;
            Break;
          end;
        end;
      end
      else
      begin
        nDataTmp := nDataTmp + '0000000000000000';
      end;

      for k2:=0 to High(gCodePrinterManager.gValueEx)  do
      begin
        if gCodePrinterManager.gValueEx[k2].fname = str2[i] then
        begin
          nDataTmp := nDataTmp + gCodePrinterManager.gValueEx[k2].fValue;
          Break;
        end;
      end;
    end;
  end;
  nCrc := $46 xor $31;
  for i:=1 to Length(nDataTmp) do
  begin
    nCrcTmp:=strtoascii(nDataTmp[i]);
    nCrc := nCrc xor nCrcTmp;
  end;
  nData := Char($24)+ Char($46)+Char($31)+ndataTmp+char($2A)+IntToHex(nCrc,2)+Char($0D)+Char($0A);

  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(100);
  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(200);

  Result := True;
end;

//-----------------------------------------------------------------------
type
  TPrinterDWA = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string; const nVersion: Integer=0): Boolean; override;
  public
    class function DriverName: string; override;
  end;

class function TPrinterDWA.DriverName: string;
begin
  Result := 'DWA';
end;

function TPrinterDWA.PrintCode(const nCode: string;
  var nHint: string; const nVersion: Integer=0): Boolean;
var nStr,nData: string;
  nBuf: TIdBytes;
begin

  //��΢A�������
  //1B 41 len(start 34) channel(start 32) 40 37 datas 40 39 0D
  // 1B 41 29 Ϊ��ͷ����
  // 23 ��ʾ������ֵĸ��� ��23��ʾΪ1���� �����ķ�ʽΪ16����
  // 20 ��ʾͨ���ı���      ��20Ϊͨ��0��  �����ķ�ʽΪ16����
  // 40 37 ��ʾ�������ݵĿ�ʼ
  // ***  ���������        ���͵ķ�ʽΪASCII��
  // 40 39 ��ʾ�������ݵĽ�β
  // 0D   ��ʾ���崫�͵Ľ�β

  nData := Char($1B) + Char($41) + Char($29)+ Char(Length(nCode) + 34);
  nData := nData + Char(2 + 31) + Char($40) + Char($37);
  nData := nData + nCode + Char($40) + Char($39)+ Char($0D);

  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(200);

  if FPrinter.FResponse then
  begin
    SetLength(nBuf, 0);
    FClient.Socket.ReadBytes(nBuf, Length(nData), False);

    nStr := BytesToString(nBuf, Indy8BitEncoding);
    if nStr <> nData then
    begin
      nHint := '�����Ӧ�����!';
      Result := False;
      Exit;
    end;
  end;

  Result := True;
end;

initialization
  gCodePrinterManager := TCodePrinterManager.Create;
  gCodePrinterManager.RegDriver(TPrinterZero);
  gCodePrinterManager.RegDriver(TPrinterJY);
  gCodePrinterManager.RegDriver(TPrinterWSD);
  gCodePrinterManager.RegDriver(TPrinterSGB);
  gCodePrinterManager.RegDriver(TPrinterWSDP011C);
  gCodePrinterManager.RegDriver(TPrinterSL);
  gCodePrinterManager.RegDriver(TPrinterHYPM);
  gCodePrinterManager.RegDriver(TPrinterWMPM);
  gCodePrinterManager.RegDriver(TPrinterWMPMEx);
  gCodePrinterManager.RegDriver(TPrinterDWA);
finalization
  FreeAndNil(gCodePrinterManager);
end.

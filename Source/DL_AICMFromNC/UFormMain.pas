unit UFormMain;

{$I Link.Inc}
{$DEFINE DEBUG}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, cxLabel, Buttons, jpeg, ExtCtrls, CPort, UFrameBase,
  StdCtrls, dxSkinsCore, dxSkinsDefaultPainters;

type
  TfFormMain = class(TForm)
    PanelTop: TPanel;
    PanelRight: TPanel;
    PanelWork: TPanel;
    ImageWork: TImage;
    Panel1: TPanel;
    LabelDec: TcxLabel;
    TimerDec: TTimer;
    ComReader: TComPort;
    LabelTop: TLabel;
    PanelLogo: TPanel;
    Image2: TImage;
    PanelPurch: TPanel;
    btnPurOrderCard: TImage;
    PanelSale: TPanel;
    BtnSCard: TImage;
    PanelPrint: TPanel;
    BtnPrint: TImage;
    PanelReturn: TPanel;
    BtnReturn: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComReaderRxChar(Sender: TObject; Count: Integer);
    procedure TimerDecTimer(Sender: TObject);
    procedure ButtonClick(Sender: TObject);
    procedure BtnReturnClick(Sender: TObject);
    procedure LabelTopDblClick(Sender: TObject);
    procedure InitButton;
    procedure Panel1DblClick(Sender: TObject);
  private
    { Private declarations }
    FBuffer: string;
    //���ջ���
    procedure ActionComPort(const nStop: Boolean);
    //���ڴ���
    function CreateBaseFrame(const nFrameID: Integer; const nParent: TWinControl;
      const nPopedom: string = ''; const nAlign: TAlign = alClient): TfFrameBase;
    //������������  
  public
    { Public declarations }
  end;

var
  fFormMain: TfFormMain;

implementation

{$R *.dfm}

uses
  IniFiles, ULibFun, USelfHelpConst, USysModule, UDataModule, USysLoger,
  UFormConn, CPortTypes, USmallFunc, UFormInputbox, uDataReport;

type
  TReaderItem = record
    FPort: string;
    FBaud: string;
    FDataBit: Integer;
    FStopBit: Integer;
    FCheckMode: Integer;
  end;

var
  gReaderItem: TReaderItem;
  //ȫ��ʹ��

//------------------------------------------------------------------------------
//Desc: ��¼��־
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFormMain, '����������', nEvent);
end;

//Desc: ����nConnStr�Ƿ���Ч
function ConnCallBack(const nConnStr: string): Boolean;
begin
  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := nConnStr;
  FDM.ADOConn.Open;
  Result := FDM.ADOConn.Connected;
end;

procedure TfFormMain.FormCreate(Sender: TObject);
begin
  PanelPrint.Visible := False;

  gPath := ExtractFilePath(ParamStr(0));  gNeedSearchPurOrder:= False;

  InitSystemObject;
  //��ʼ��ϵͳ����

  ShowConnectDBSetupForm(ConnCallBack);
  {$IFNDEF DEBUG}
  ShowCursor(False);
  {$ENDIF}

  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := BuildConnectDBStr;
  //���ݿ�����

  //PanelTop.Height := Screen.DesktopHeight div 6;
  //����ͷ��ռ��Ļ�߶ȵ�4��֮1
  //RightPanel.Width := Screen.DesktopWidth div 5;
  //������ռ��Ļ��ȵ�5��֮1
  if not Assigned(FDR) then
  begin
    FDR := TFDR.Create(Application);
  end;

  PanelTop.DoubleBuffered := True;
  PanelWork.DoubleBuffered:= True;
  PanelRight.DoubleBuffered := True;

  gTimeCounter := 0;
  ActionComPort(False);
  RunSystemObject;
  //����ϵͳ����
  InitButton;
end;

procedure TfFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ActionComPort(True);
end;

//Desc: ���ڲ���
procedure TfFormMain.ActionComPort(const nStop: Boolean);
var nIni: TIniFile;
begin
  if nStop then
  begin
    ComReader.Close;
    Exit;
  end;

  with ComReader do
  begin
    with Timeouts do
    begin
      ReadTotalConstant := 100;
      ReadTotalMultiplier := 10;
    end;

    nIni := TIniFile.Create(gPath + 'Reader.Ini');
    with gReaderItem do
    try
      FPort := nIni.ReadString('Param', 'Port', '');
      FBaud := nIni.ReadString('Param', 'Rate', '4800');
      FDataBit := nIni.ReadInteger('Param', 'DataBit', 8);
      FStopBit := nIni.ReadInteger('Param', 'StopBit', 0);
      FCheckMode := nIni.ReadInteger('Param', 'CheckMode', 0);

      Port := FPort;
      BaudRate := StrToBaudRate(FBaud);

      case FDataBit of
       5: DataBits := dbFive;
       6: DataBits := dbSix;
       7: DataBits :=  dbSeven else DataBits := dbEight;
      end;

      case FStopBit of
       2: StopBits := sbTwoStopBits;
       15: StopBits := sbOne5StopBits
       else StopBits := sbOneStopBit;
      end;

      if FPort <> '' then
        ComReader.Open;
    finally
      nIni.Free;
    end;
  end;
end;                            

procedure TfFormMain.ComReaderRxChar(Sender: TObject; Count: Integer);
var nStr: string;
    nIdx,nLen: Integer;
    nParam:TFrameCommandParam;
begin
  ComReader.ReadStr(nStr, Count);
  FBuffer := FBuffer + nStr;

  nLen := Length(FBuffer);
  if nLen < 7 then Exit;

  for nIdx:=1 to nLen do
  begin
    if (FBuffer[nIdx] <> #$AA) or (nLen - nIdx < 6) then Continue;
    if (FBuffer[nIdx+1] <> #$FF) or (FBuffer[nIdx+2] <> #$00) then Continue;

    nStr := Copy(FBuffer, nIdx+3, 4);
    FBuffer := '';

    with nParam do
    begin
      FCommand := cCmd_QueryCard;
      FParamA  := ParseCardNO(nStr, True);
    end;
    //��ѯ��Ƭ��Ϣ

    CreateBaseFrame(cFI_FrameQueryCard, PanelWork);
    BroadcastFrameCommand(nil, cCmd_QueryCard, @nParam);

    gTimeCounter := 20;
    TimerDec.Enabled := True;
    Exit;
  end;
end;

procedure TfFormMain.TimerDecTimer(Sender: TObject);
begin
  if gTimeCounter <= 0 then
  begin
    TimerDec.Enabled := False;
    LabelDec.Caption := '';

    CreateBaseFrame(cFI_FrameMain, PanelWork);
    BroadcastFrameCommand(nil, cCmd_FrameQuit);

    BtnPrint.Enabled:= True;
    BtnSCard.Enabled := True;
    BtnPurOrderCard.Enabled:= True;

    PanelPurch.Visible := True;
    PanelSale.Visible := True;
  end else
  begin
    LabelDec.Caption := IntToStr(gTimeCounter) + ' ';
  end;

  Dec(gTimeCounter);
end;

function TfFormMain.CreateBaseFrame(const nFrameID: Integer;
 const nParent: TWinControl;const nPopedom: string;const nAlign: TAlign): TfFrameBase;
begin
  LockWindowUpdate(PanelWork.Handle);
  try
    Result := CreateBaseFrameItem(nFrameID, nParent, nPopedom, nAlign);
  finally
    LockWindowUpdate(0);
  end;
end;

procedure TfFormMain.ButtonClick(Sender: TObject);
begin
  if Sender = BtnSCard then
  begin
    {$IFDEF SaleAICMFromNC}
    CreateBaseFrame(cFI_FrameInputCertificate, PanelWork);
    {$ELSE}
    ShowMsg('ҵ����δ��ͨ', sHint);
    Exit;
    {$ENDIF}
  end;

  if Sender = BtnPrint then
    CreateBaseFrame(cFI_FramePrint, PanelWork);

  if Sender = btnPurOrderCard then
  begin
    {$IFDEF PurAICMFromNC}
    gNeedSearchPurOrder:= True;
    CreateBaseFrame(cFI_FramePurERPMakeCard, PanelWork);
    {$ELSE}
    ShowMsg('ҵ����δ��ͨ', sHint);
    Exit;
    {$ENDIF}
  end;

  BtnSCard.Enabled := False;
  BtnPrint.Enabled:= False;
  BtnPurOrderCard.Enabled:= False;

  PanelPurch.Visible := False;
  PanelSale.Visible := False;

  gTimeCounter := 120;
  TimerDec.Enabled := True;
  //Ĭ��30��
end;

procedure TfFormMain.BtnReturnClick(Sender: TObject);
begin
  gTimeCounter := 0;
  //ֱ�ӷ���
end;

procedure TfFormMain.LabelTopDblClick(Sender: TObject);
var nPwd: string;
begin
  Exit;
  {$IFNDEF DEBUG}
  ShowCursor(True);
  {$ENDIF}

  if not ShowInputBox('����������:', sHint, nPwd) then Exit;
  if nPwd <> '5689' then Exit;


  if QueryDlg('ȷ��Ҫ�˳�ϵͳ��?', sHint) then
    Close;

  {$IFNDEF DEBUG}
  ShowCursor(False);
  {$ENDIF}
end;

procedure TfFormMain.InitButton;
var nHeight, nHeightPanel: Integer;
begin
  nHeightPanel := PanelPurch.Height;
  nHeight := nHeightPanel;
  PanelPurch.Top := nHeight;
  PanelSale.Top := nHeight * 2 + nHeightPanel * 1;
  PanelPrint.Top := nHeight * 3 + nHeightPanel * 2;
  PanelReturn.Top := nHeight * 4 + nHeightPanel * 3;
end;


procedure TfFormMain.Panel1DblClick(Sender: TObject);
var nPwd: string;
begin
  {$IFNDEF DEBUG}
  ShowCursor(True);
  {$ENDIF}

  if not ShowInputBox('����������:', sHint, nPwd) then Exit;
  if nPwd <> '5689' then Exit;


  if QueryDlg('ȷ��Ҫ�˳�ϵͳ��?', sHint) then
    Close;

  {$IFNDEF DEBUG}
  ShowCursor(False);
  {$ENDIF}
end;

end.

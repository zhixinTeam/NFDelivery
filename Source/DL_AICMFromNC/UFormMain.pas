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
    PanelPrintBill: TPanel;
    BtnPrintBill: TImage;
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
    //接收缓冲
    procedure ActionComPort(const nStop: Boolean);
    //串口处理
    function CreateBaseFrame(const nFrameID: Integer; const nParent: TWinControl;
      const nPopedom: string = ''; const nAlign: TAlign = alClient): TfFrameBase;
    //创建基本窗体  
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
  //全局使用

//------------------------------------------------------------------------------
//Desc: 记录日志
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFormMain, '自助主窗体', nEvent);
end;

//Desc: 测试nConnStr是否有效
function ConnCallBack(const nConnStr: string): Boolean;
begin
  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := nConnStr;
  FDM.ADOConn.Open;
  Result := FDM.ADOConn.Connected;
end;

procedure TfFormMain.FormCreate(Sender: TObject);
begin
  gPath := ExtractFilePath(ParamStr(0));  gNeedSearchPurOrder:= False;

  InitSystemObject;
  //初始化系统对象

  ShowConnectDBSetupForm(ConnCallBack);
  {$IFNDEF DEBUG}
  ShowCursor(False);
  {$ENDIF}

  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := BuildConnectDBStr;
  //数据库连接

  //PanelTop.Height := Screen.DesktopHeight div 6;
  //标题头部占屏幕高度的4分之1
  //RightPanel.Width := Screen.DesktopWidth div 5;
  //功能区占屏幕宽度的5分之1
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
  //运行系统对象
  InitButton;
end;

procedure TfFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ActionComPort(True);
end;

//Desc: 串口操作
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
    //查询卡片信息

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
    BtnPrintBill.Enabled:= True;

    PanelPurch.Visible := True;
    PanelSale.Visible := True;
    PanelPrint.Visible := True;
    PanelPrintBill.Visible := True;
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
  if gSysParam.FTTCEK720ID = '' then
  begin
    ShowMsg('未配置发卡机,请联系管理员', sHint);
    Exit;
  end;

  if (Sender = BtnSCard) or (Sender = btnPurOrderCard) then
  begin
    {$IFDEF AICMSafeInfo}
    gAgree := False;
    CreateBaseFrame(cFI_FrameSafeInfo, PanelWork);
    gTimeCounter := 30;
    TimerDec.Enabled := True;
    //默认30秒
    while gTimeCounter > 0 do
    begin
      Application.ProcessMessages;
      if gAgree then
        Break;
    end;
    if not gAgree then
      Exit;
    {$ENDIF}
  end;

  if Sender = BtnSCard then
  begin
    {$IFDEF SaleAICMFromNC}
    CreateBaseFrame(cFI_FrameInputCertificate, PanelWork);
    {$ELSE}
    ShowMsg('业务暂未开通', sHint);
    Exit;
    {$ENDIF}
  end;

  if Sender = BtnPrint then
  begin
    {$IFDEF PrintHuaYanDan}
    CreateBaseFrame(cFI_FramePrint, PanelWork);
    {$ELSE}
    ShowMsg('业务暂未开通', sHint);
    Exit;
    {$ENDIF}
  end;

  if Sender = BtnPrintBill then
  begin
    gNeedClear:= True;
    CreateBaseFrame(cFI_FramePrintBill, PanelWork);
  end;

  if Sender = btnPurOrderCard then
  begin
    {$IFDEF PurAICMFromNC}
    gNeedSearchPurOrder:= True;
    CreateBaseFrame(cFI_FramePurERPMakeCard, PanelWork);
    {$ELSE}
    ShowMsg('业务暂未开通', sHint);
    Exit;
    {$ENDIF}
  end;

  BtnSCard.Enabled := False;
  BtnPrint.Enabled:= False;
  BtnPurOrderCard.Enabled:= False;
  BtnPrintBill.Enabled:= False;

  PanelPurch.Visible := False;
  PanelSale.Visible := False;
  PanelPrint.Visible := False;
  PanelPrintBill.Visible := False;

  gTimeCounter := 120;
  TimerDec.Enabled := True;
  //默认30秒
end;

procedure TfFormMain.BtnReturnClick(Sender: TObject);
begin
  gTimeCounter := 0;
  //直接返回
end;

procedure TfFormMain.LabelTopDblClick(Sender: TObject);
var nPwd: string;
begin
  Exit;
  {$IFNDEF DEBUG}
  ShowCursor(True);
  {$ENDIF}

  if not ShowInputBox('请输入密码:', sHint, nPwd) then Exit;
  if nPwd <> '5689' then Exit;


  if QueryDlg('确定要退出系统吗?', sHint) then
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
  PanelPurch.Top := PanelRight.Top + 2;
  PanelSale.Top := nHeight * 2 + nHeightPanel * 1;
  PanelPrintBill.Top := nHeight * 3 + nHeightPanel * 2;
  PanelPrint.Top := nHeight * 4 + nHeightPanel * 3;
  PanelReturn.Top := nHeight * 5 + nHeightPanel * 4;
end;


procedure TfFormMain.Panel1DblClick(Sender: TObject);
var nPwd: string;
begin
  {$IFNDEF DEBUG}
  ShowCursor(True);
  {$ENDIF}

  if not ShowInputBox('请输入密码:', sHint, nPwd) then Exit;
  if nPwd <> '5689' then Exit;


  if QueryDlg('确定要退出系统吗?', sHint) then
    Close;

  {$IFNDEF DEBUG}
  ShowCursor(False);
  {$ENDIF}
end;

end.

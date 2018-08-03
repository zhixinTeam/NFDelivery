unit main;
{$I Link.inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient,PLCController, ExtCtrls, IdContext, IdCustomTCPServer,
  IdTCPServer, IniFiles, IdGlobal, UMgrSendCardNo;

type
  TFormMain = class(TForm)
    IdTCPServer1: TIdTCPServer;
    Memo1: TMemo;
    wPanel: TScrollBox;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure IdTCPServer1Execute(AContext: TIdContext);
    function IdBytesToAnsiString(ParamBytes: TIdBytes): AnsiString;
  private
    { Private declarations }
    procedure LoadKeyBoardItems;
    procedure ResetPanelPosition;
    //重置位置
    procedure RunSysObject;
  public
    { Public declarations }
    procedure DoExecute(const nContext: TIdContext);
    procedure OnGetCardNo(var nBase: TSendDataBase;var nBuf: TIdBytes;nCtx: TIdContext);
    //接收磁卡号
  end;

var
  FormMain: TFormMain;
  AppPath: string;
  gMitUrl:string;

resourcestring
  sConfig             = 'Config.Ini';
  sForm               = 'FormInfo.Ini';
  sDB                 = 'DBConn.Ini';

implementation

uses
  UFrame, UMgrKeyBoardTunnels, USysLoger, UClientWorker, UMemDataPool, UFormConn,
  UMgrChannel, UChannelChooser, UMITPacker, ULibFun, UDataModule, UMgrLEDDisp,
  UMgrTTCEK720, UMgrVoiceNet, USysBusiness;

{$R *.dfm}

procedure TFormMain.FormShow(Sender: TObject);
var
  nFrame:TFrame1;
begin
  if not Assigned(gKeyBoardTunnelManager) then
  begin
    gKeyBoardTunnelManager := TKeyBoardTunnelManager.Create;
    gKeyBoardTunnelManager.LoadConfig('Tunnels.xml');
  end;
  LoadKeyBoardItems;
  ResetPanelPosition;
  Memo1.Clear;
end;

procedure TFormMain.LoadKeyBoardItems;
var nIdx: Integer;
    nT: PPTTunnelItem;
begin
  with gKeyBoardTunnelManager do
  begin
    SetLength(gPurOrderItems, Tunnels.Count);
    for nIdx:= 0 to Tunnels.Count-1 do
    begin
      if nIdx > 5 then
      begin
        ShowMsg('超出最大通道', '警告');
        Exit;
      end;
      nT := Tunnels[nIdx];
      //tunnel
      gPurOrderItems[nIdx].FCanSave := False;
      gPurOrderItems[nIdx].FTunnelID := nT.FID;
      if Assigned(nT.FOptions) And
         (UpperCase(nT.FOptions.Values['Enable']) <> 'Y') then
      begin
        Continue;
      end;

      with TFrame1.Create(Self) do
      begin
        Name := 'fFramePlcCtrl' + IntToStr(nIdx);
        Parent := wPanel;

        FrameId := nIdx+1;

        GroupBox1.Caption := nT.FName;
        KeyBoardTunnel := nT;
        FTCPSer := IdTCPServer1;
        IdTCPServer1.Active := True;

        FSysLoger:= gSysLoger;
        StartRead;
      end;
    end;
  end;
end;

//Desc: 重置计数面板位置
procedure TFormMain.ResetPanelPosition;
var nIdx: Integer;
    nL,nT,nNum: Integer;
    nCtrl: TFrame1;
begin
  nT := 0;
  nL := 0;
  nNum := 0;

  for nIdx:=0 to wPanel.ControlCount - 1 do
  if wPanel.Controls[nIdx] is TFrame1 then
  begin
    nCtrl := wPanel.Controls[nIdx] as TFrame1;

    if ((nL + nCtrl.Width) > wPanel.ClientWidth) and (nNum > 0) then
    begin
      nL := 0;
      nNum := 0;
      nT := nT + nCtrl.Height;
    end;

    nCtrl.Top := nT;
    nCtrl.Left := nL;

    Inc(nNum);
    nL := nL + nCtrl.Width;
  end;
end;

//Desc: 测试nConnStr是否有效
function ConnCallBack(const nConnStr: string): Boolean;
begin
  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := nConnStr;
  FDM.ADOConn.Open;
  Result := FDM.ADOConn.Connected;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  MyFile : TIniFile;
  LocalPort: Integer;
begin
  AppPath := ExtractFilePath(Application.ExeName);
  InitGlobalVariant(AppPath, AppPath+sConfig, AppPath+sForm, AppPath+sDB);

  MyFile := TIniFile.Create(AppPath + 'sysconfig.ini');

  LocalPort := MyFile.ReadInteger('FixLoading','localPort',5050);

  gMitUrl := MyFile.ReadString('Mit','MitUrl','');
  MyFile.Free;

  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := BuildConnectDBStr;
  FDM.ADOConn.Open;
  //数据库连接

  RunSysObject;

  IdTCPServer1.DefaultPort := LocalPort;
end;



procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  IdTCPServer1.Active := False;
  if Assigned(gDisplayManager) then
    gDisplayManager.StopDisplay;

  if Assigned(gK720ReaderManager) then
    gK720ReaderManager.StopReader;

  if Assigned(gNetVoiceHelper) then
    gNetVoiceHelper.StopVoice;
end;

procedure TFormMain.RunSysObject;
begin
  gSysLoger := TSysLoger.Create(AppPath + 'Logs\');
  //Sysloger
  if not Assigned(gMemDataManager) then
    gMemDataManager := TMemDataManager.Create;
  //mem pool

  gChannelManager := TChannelManager.Create;
  gChannelManager.ChannelMax := 20;
  gChannelChoolser := TChannelChoolser.Create('');
  gChannelChoolser.AutoUpdateLocal := False;
  //channel
  gChannelChoolser.AddChannelURL(gMitUrl);

  if FileExists(AppPath + cDisp_Config) then
  begin
    gDisplayManager.LoadConfig(AppPath + cDisp_Config);
    gDisplayManager.StartDisplay;
  end;

  if FileExists(AppPath + cTTCE_K720_Config) then
  begin
    if not Assigned(gK720ReaderManager) then
      gK720ReaderManager := TK720ReaderManager.Create;
    gK720ReaderManager.LoadConfig(AppPath + cTTCE_K720_Config);
    gK720ReaderManager.OnCardProc := WhenTTCE_K720_ReadCard;
    gK720ReaderManager.StartReader;
  end;

  if FileExists(AppPath + 'NetVoice.xml') then
  begin
    gNetVoiceHelper := TNetVoiceManager.Create;
    gNetVoiceHelper.LoadConfig(AppPath + 'NetVoice.xml');
    gNetVoiceHelper.StartVoice;
  end;
end;

procedure TFormMain.IdTCPServer1Execute(AContext: TIdContext);
begin
  try
    DoExecute(AContext);
  except
    on E:Exception do
    begin
      //Frame1.WriteLog(E.Message);
      AContext.Connection.Socket.InputBuffer.Clear;
    end;
  end;
end;

procedure TFormMain.DoExecute(const nContext: TIdContext);
var nBuf: TIdBytes;
    nBase: TSendDataBase;
begin
  with nContext.Connection do
  begin
    Socket.ReadBytes(nBuf, cSizeSendBase, False);
    BytesToRaw(nBuf, nBase, cSizeSendBase);

    case nBase.FCommand of
     cCmd_SendCard :
      begin
        OnGetCardNo(nBase,nBuf,nContext);
      end;
    end;
  end;
end;

procedure TFormMain.OnGetCardNo(var nBase: TSendDataBase;
  var nBuf: TIdBytes; nCtx: TIdContext);
var
  nTunnel, nCardNo, nStr: string;
  i: Integer;
  nT: PPTTunnelItem;
begin
  nCtx.Connection.Socket.ReadBytes(nBuf, nBase.FDataLen, False);
  nStr := Trim(BytesToString(nBuf));
  i := Pos('@',nStr);
  if i < 0 then Exit;

  nTunnel:= Copy(nStr,0,i-1);
  nCardNo := Copy(nStr,i+1,Length(nStr));
  Memo1.Lines.Add('接收到数据:'+ nTunnel + ',' + nCardNo);
  for i := 0 to gKeyBoardTunnelManager.Tunnels.Count - 1 do
  begin
    if i > 5 then
      Continue;

    nT := gKeyBoardTunnelManager.Tunnels[i];
    //tunnel

    if Assigned(nT.FOptions) And
       (UpperCase(nT.FOptions.Values['Enable']) <> 'Y') then
    begin
      Continue;
    end;

    with  TFrame1(FindComponent('fFramePlcCtrl'+inttostr(i))) do
    begin
      //if FIsBusy then Continue;
      if KeyBoardTunnel.FID = nTunnel then
      begin
        if Pos('Close', nCardNo) > 0 then
        begin
          Exit;
        end;
      end;
    end;
  end;
end;

function TFormMain.IdBytesToAnsiString(ParamBytes: TIdBytes): AnsiString;
var
  i: Integer;
  S: AnsiString;
begin
  S := '';
  for i := 0 to Length(ParamBytes) - 1 do
  begin
    S := S + AnsiChar(ParamBytes[i]);
  end;
  //ShowMessage(s);
  Result := S;
end;

end.

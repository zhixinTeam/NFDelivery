{*******************************************************************************
  作者: dmzn@163.com 2014-06-10
  描述: 自动称重
*******************************************************************************}
unit UFramePoundAuto;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameBase, cxGraphics, cxControls, cxLookAndFeels, UMgrAliVision,
  cxLookAndFeelPainters, StdCtrls, ComCtrls, ExtCtrls, cxSplitter;

type
  TfFramePoundAuto = class(TBaseFrame)
    WorkPanel: TScrollBox;
    Timer1: TTimer;
    cxSplitter1: TcxSplitter;
    RichEdit1: TRichEdit;
    procedure WorkPanelMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    FReceiver: Integer;
    //事件标识
    procedure OnLog(const nStr: string);
    //记录日志
    procedure LoadPoundItems;
    //载入通道
    procedure DoTruckStatusChange(const nPound: PPoundItem);
    //状态变更
  public
    { Public declarations }
    class function FrameID: integer; override;
    function FrameTitle: string; override;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    //子类继承
    procedure WriteLog(const nEvent: string; const nColor: TColor = clGreen;
      const nBold: Boolean = False; const nAdjust: Boolean = True);
    //记录日志
  end;

implementation

{$R *.dfm}

uses
  IniFiles, UlibFun, UMgrControl, UMgrPoundTunnels, UFramePoundAutoItem,
  UMgrTruckProbe, UMgrRemoteVoice, UMgrVoiceNet, UDataModule, USysDB,
  USysBusiness, USysGrid, USysLoger, USysConst;

class function TfFramePoundAuto.FrameID: integer;
begin
  Result := cFI_FramePoundAuto;
end;

function TfFramePoundAuto.FrameTitle: string;
begin
  Result := '称重 - 自动';
end;

procedure TfFramePoundAuto.OnCreateFrame;
var nInt: Integer;
    nIni: TIniFile;
begin
  inherited;
  gSysParam.FAutoPound := True;

  gSysLoger.LogSync := True;
  FReceiver := gSysLoger.AddReceiver(OnLog);

  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    nInt := nIni.ReadInteger(Name, 'MemoLog', 0);
    if nInt > 20 then
      RichEdit1.Height := nInt;
    //xxxxx
  finally
    nIni.Free;
  end;

  if not Assigned(gPoundTunnelManager) then
  begin
    gPoundTunnelManager := TPoundTunnelManager.Create;
    gPoundTunnelManager.LoadConfig(gPath + 'Tunnels.xml');
  end;

  {$IFNDEF MITTruckProber}
  if not Assigned(gProberManager) then
  begin
    gProberManager := TProberManager.Create;
    gProberManager.LoadConfig(gPath + 'TruckProber.xml');
  end;

  Inc(gSysParam.FProberUser);
  {$IFNDEF DEBUG}
  gProberManager.StartProber;
  {$ENDIF}
  {$ENDIF}

  {$IFDEF AlivisionInClient}
  if not Assigned(gVisionManager) then
  begin
    gVisionManager := TTruckManager.Create;
    gVisionManager.LoadConfig(gPath + 'AliVision.xml');
    gVisionManager.EventMode := emMain;
    gVisionManager.OnStatusChangeEvent := DoTruckStatusChange;
  end;
  gVisionManager.StartService;
  {$ENDIF}

  if gSysParam.FVoiceUser < 1 then
  begin
    Inc(gSysParam.FVoiceUser);
    gVoiceHelper.LoadConfig(gPath + 'Voice.xml');
    {$IFNDEF DEBUG}
    gVoiceHelper.StartVoice;
    {$ENDIF}

    {$IFNDEF DEBUG}
    if FileExists(gPath + 'NetVoice.xml') then
    begin
      if not Assigned(gNetVoiceHelper) then
        gNetVoiceHelper := TNetVoiceManager.Create;
      gNetVoiceHelper.LoadConfig(gPath + 'NetVoice.xml');
      gNetVoiceHelper.StartVoice;
    end;
    {$ENDIF}
  end;
end;

procedure TfFramePoundAuto.OnDestroyFrame;
var nIni: TIniFile;
begin
  gSysParam.FAutoPound := False;
  //关闭自动称重

  Dec(gSysParam.FVoiceUser);
  if gSysParam.FVoiceUser < 1 then
  begin
    if Assigned(gNetVoiceHelper) then gNetVoiceHelper.StopVoice;

    gVoiceHelper.StopVoice;
    //xxxxx
  end;

  {$IFNDEF MITTruckProber}
  Dec(gSysParam.FProberUser);
  if gSysParam.FProberUser < 1 then
    gProberManager.StopProber;
  //xxxxx
  {$ENDIF}

  {$IFDEF AlivisionInClient}
  gVisionManager.StopService;
  {$ENDIF}

  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    nIni.WriteInteger(Name, 'MemoLog', RichEdit1.Height);
  finally
    nIni.Free;
  end;

  if Assigned(gSysLoger) then
    gSysLoger.DelReceiver(FReceiver);
  inherited;
end;

procedure TfFramePoundAuto.OnLog(const nStr: string);
begin
  if Pos('FUN:', nStr) < 1 then
    WriteLog(nStr, clBlue, False, False);
  //不记录调用日志
end;

procedure TfFramePoundAuto.WriteLog(const nEvent: string; const nColor: TColor;
  const nBold: Boolean; const nAdjust: Boolean);
var nInt: Integer;
begin
  with RichEdit1 do
  try
    Lines.BeginUpdate;
    if Lines.Count > 200 then
     for nInt:=1 to 50 do
      Lines.Delete(0);
    //清理多余

    if nBold then
         SelAttributes.Style := SelAttributes.Style + [fsBold]
    else SelAttributes.Style := SelAttributes.Style - [fsBold];

    SelStart := GetTextLen;
    SelAttributes.Color := nColor;

    if nAdjust then
         Lines.Add(DateTime2Str(Now) + #9 + nEvent)
    else Lines.Add(nEvent);
  finally
    Lines.EndUpdate;
    Perform(EM_SCROLLCARET,0,0);
    Application.ProcessMessages;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 延时载入通道
procedure TfFramePoundAuto.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  if gSysParam.FFactNum = '' then
  begin
    ShowDlg('系统需要授权才能称重,请联系管理员.', sHint);
    Exit;
  end;

  LoadPoundItems;
end;

//Desc: 支持滚轮
procedure TfFramePoundAuto.WorkPanelMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
  with WorkPanel do
    VertScrollBar.Position := VertScrollBar.Position - WheelDelta;
  //xxxxx
end;

//Desc: 载入通道
procedure TfFramePoundAuto.LoadPoundItems;
var nIdx: Integer;
    nT: PPTTunnelItem;
begin
  with gPoundTunnelManager do
  begin
    for nIdx:=0 to Tunnels.Count - 1 do
    begin
      nT := Tunnels[nIdx];
      //tunnel
      
      if Assigned(nT.FOptions) and (nT.FOptions.Values['IsGrab'] = 'Y') then
        Continue;
      //码头通道

      {$IFDEF VerfiyAutoWeight}
      if nT.FAutoWeight then
      {$ENDIF}
      with TfFrameAutoPoundItem.Create(Self) do
      begin
        Name := 'fFrameAutoPoundItem' + IntToStr(nIdx);
        Parent := WorkPanel;

        Align := alTop;
        HintLabel.Caption := nT.FName;
        PoundTunnel := nT;
      end;
    end;
  end;
end;

//Desc: 图像识别的车辆状态
procedure TfFramePoundAuto.DoTruckStatusChange(const nPound: PPoundItem);
var nStr,nID,nTruck: string;
    nPos: Integer;
begin
  case nPound.FStateNow of
   tsNewOn   : nStr := Format('新车牌[ %s ]上磅', [nPound.FTruck]);
   tsLeave   : nStr := Format('车辆[ %s ]离开地磅', [nPound.FTruckPrev]);
   tsNormal  : nStr := Format('车辆[ %s ]状态正常', [nPound.FTruck]);
   tsOut     : nStr := Format('车辆[ %s ]未完全上磅', [nPound.FTruck])
   else        nStr := '';
  end;

  if nStr <> '' then
    gSysLoger.AddLog(nStr);
  //xxxxx

  if (nPound.FStateNow = tsLeave) and (nPound.FValStr <> '') then //车辆下磅后,尝试补全车牌号
  begin
    nTruck := nPound.FValStr;
    //data: id|truck

    nPos := Pos('|', nTruck);
    nID := Copy(nTruck, 1, nPos - 1);
    System.Delete(nTruck, 1, nPos);

    nStr := 'Update %s Set V_Camera=''%s'',V_Match=''%s'' ' +
            'Where V_ID=''%s'' And V_Camera=''''';
    nStr := Format(nStr, [sTable_Alivision, nPound.FTruckPrev,
            TruckFuzzyMatch(nTruck, nPound.FTruckPrev), nID]);
    FDM.ExecuteSQL(nStr);

    nPound.FValStr := '';
    //重置单据号
  end;
end;

initialization
  gControlManager.RegCtrl(TfFramePoundAuto, TfFramePoundAuto.FrameID);
end.

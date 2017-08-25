{*******************************************************************************
  ����: juner11212436@163.com 2017-08-17
  ����: ��ͷץ���ӳ���
*******************************************************************************}
unit UFramePoundMtAuto;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameBase, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, StdCtrls, ComCtrls, ExtCtrls, cxSplitter;

type
  TfFramePoundMtAuto = class(TBaseFrame)
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
    //�¼���ʶ
    procedure OnLog(const nStr: string);
    //��¼��־
    procedure LoadPoundItems;
    //����ͨ��
  public
    { Public declarations }
    class function FrameID: integer; override;
    function FrameTitle: string; override;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    //����̳�
    procedure WriteLog(const nEvent: string; const nColor: TColor = clGreen;
      const nBold: Boolean = False; const nAdjust: Boolean = True);
    //��¼��־
  end;

implementation

{$R *.dfm}

uses
  IniFiles, UlibFun, UMgrControl, UMgrPoundTunnels, UFramePoundMtAutoItem,
  UMgrTruckProbe, UMgrRemoteVoice, UMgrVoiceNet,USysGrid, USysLoger, USysConst, USysDB;

class function TfFramePoundMtAuto.FrameID: integer;
begin
  Result := cFI_FramePoundMtAuto;
end;

function TfFramePoundMtAuto.FrameTitle: string;
begin
  Result := '���� - ץ����';
end;

procedure TfFramePoundMtAuto.OnCreateFrame;
var nInt: Integer;
    nIni: TIniFile;
begin
  inherited;

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
end;

procedure TfFramePoundMtAuto.OnDestroyFrame;
var nIni: TIniFile;
begin
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

procedure TfFramePoundMtAuto.OnLog(const nStr: string);
begin
  if Pos('FUN:', nStr) < 1 then
    WriteLog(nStr, clBlue, False, False);
  //����¼������־
end;

procedure TfFramePoundMtAuto.WriteLog(const nEvent: string; const nColor: TColor;
  const nBold: Boolean; const nAdjust: Boolean);
var nInt: Integer;
begin
  with RichEdit1 do
  try
    Lines.BeginUpdate;
    if Lines.Count > 200 then
     for nInt:=1 to 50 do
      Lines.Delete(0);
    //�������

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
//Desc: ��ʱ����ͨ��
procedure TfFramePoundMtAuto.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  LoadPoundItems;
end;

//Desc: ֧�ֹ���
procedure TfFramePoundMtAuto.WorkPanelMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
  with WorkPanel do
    VertScrollBar.Position := VertScrollBar.Position - WheelDelta;
  //xxxxx
end;

//Desc: ����ͨ��
procedure TfFramePoundMtAuto.LoadPoundItems;
var nIdx: Integer;
    nT: PPTTunnelItem;
begin
  with gPoundTunnelManager do
  begin
    for nIdx:=0 to Tunnels.Count - 1 do
    begin
      nT := Tunnels[nIdx];
      //tunnel
      if not (nT.FOptions.Values['IsGrab'] = sFlag_Yes) then
        Continue;
      with TfFrameAutoPoundMtItem.Create(Self) do
      begin
        Name := 'fFrameAutoPoundMtItem' + IntToStr(nIdx);
        Parent := WorkPanel;

        Align := alTop;
        HintLabel.Caption := nT.FName;
        PoundTunnel := nT;
      end;
    end;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFramePoundMtAuto, TfFramePoundMtAuto.FrameID);
end.

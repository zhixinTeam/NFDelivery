unit UFrameInputCertificate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameBase, ExtCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, jpeg, Buttons,
  StdCtrls, UMgrSDTReader;

type
  TfFrameInputCertificate = class(TfFrameBase)
    PanelClient: TPanel;
    Btn1: TSpeedButton;
    Btn2: TSpeedButton;
    Btn3: TSpeedButton;
    Btn4: TSpeedButton;
    Btn5: TSpeedButton;
    Btn6: TSpeedButton;
    Btn7: TSpeedButton;
    Btn8: TSpeedButton;
    Btn9: TSpeedButton;
    BtnEnter: TSpeedButton;
    Btn0: TSpeedButton;
    BtnDel: TSpeedButton;
    EditID: TEdit;
    Label1: TLabel;
    procedure BtnNumClick(Sender: TObject);
    procedure EditIDChange(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure EditIDKeyPress(Sender: TObject; var Key: Char);
    procedure BtnEnterClick(Sender: TObject);
  private
    { Private declarations }
    FListA, FListB, FListC: TStrings;
    //列表信息
    FID: string;
    FAICMFP: string;
    procedure LoadOrderInfo(nID: string);
    //加载订单信息
    procedure SyncCard(const nCard: TIdCardInfoStr;const nReader: TSDTReaderItem);
  public
    { Public declarations }
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    procedure OnShowFrame; override;

    class function FrameID: integer; override;
    function DealCommand(Sender: TObject; const nCmd: Integer;
      const nParamA: Pointer; const nParamB: Integer): Integer; override;
    {*处理命令*}
  end;

var
  fFrameInputCertificate: TfFrameInputCertificate;

implementation

{$R *.dfm}

uses
  ULibFun, USysLoger, UDataModule, UMgrControl, USelfHelpConst, UBase64,
  USysBusiness, UFrameMakeCard, UFormBase, USysDB;

//------------------------------------------------------------------------------
//Desc: 记录日志
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFrameInputCertificate, '输入凭证信息', nEvent);
end;

class function TfFrameInputCertificate.FrameID: Integer;
begin
  Result := cFI_FrameInputCertificate;
end;

function TfFrameInputCertificate.DealCommand(Sender: TObject; const nCmd: Integer;
  const nParamA: Pointer; const nParamB: Integer): Integer;
begin
  Result := 0;
  if nCmd = cCmd_FrameQuit then
  begin
    Close;
  end;
end;

procedure TfFrameInputCertificate.OnCreateFrame;
var nStr: string;
begin
  nStr := 'Select D_Value From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_AICMFP]);

  with FDM.SQLQuery(nStr) do
  begin
    if RecordCount > 0 then
    begin
      FAICMFP := Fields[0].AsString;
    end;
  end;

  DoubleBuffered := True;
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  FID := '';
end;

procedure TfFrameInputCertificate.OnDestroyFrame;
begin
  FListA.Free;
  FListB.Free;
  FListC.Free;

  gSDTReaderManager.OnSDTEvent := nil;
end;

procedure TfFrameInputCertificate.OnShowFrame;
begin
  EditID.Text := '';
  EditID.SetFocus;
  gSDTReaderManager.OnSDTEvent := SyncCard;
end;

procedure TfFrameInputCertificate.BtnNumClick(Sender: TObject);
var nStr: string;
    nIdx, nLen: Integer;
begin
  inherited;
  nStr := EditID.Text;
  nIdx := EditID.SelStart;
  nLen := EditID.SelLength;

  nStr := Copy(nStr, 1, nIdx) + TSpeedButton(Sender).Caption +
          Copy(nStr, nIdx + nLen + 1, Length(EditID.Text) - (nIdx + nLen));
  EditID.Text := nStr;
  EditID.SelStart := nIdx+1;

  gTimeCounter := 30;
end;

procedure TfFrameInputCertificate.EditIDChange(Sender: TObject);
var nIdx: Integer;
begin
  inherited;
  nIdx := EditID.SelStart;
  EditID.Text := Trim(EditID.Text);
  EditID.SelStart := nIdx;
  if Length(EditID.Text) = 18 then
  begin
    if EditID.Text = FID then
    begin
      FID := '';
      BtnEnterClick(nil);
    end
    else
     EditID.Text := '';
  end;
end;

procedure TfFrameInputCertificate.BtnDelClick(Sender: TObject);
var nIdx, nLen: Integer;
    nStr: string;
begin
  inherited;
  nStr := EditID.Text;
  nIdx := EditID.SelStart;
  nLen := EditID.SelLength;

  if nLen < 1 then
  begin
    nIdx := nIdx - 1;
    nLen := 1;
  end;

  nStr := Copy(nStr, 1, nIdx) +
          Copy(nStr, nIdx + nLen + 1, Length(EditID.Text) - (nIdx + nLen));
  EditID.Text := nStr;
  EditID.SelStart := nIdx;

  gTimeCounter := 30;
end;

procedure TfFrameInputCertificate.EditIDKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if Key = #13 then
  begin
    Key := #0;

    if Sender = EditID then
    begin
      BtnEnterClick(nil);
    end;
  end;
end;


procedure TfFrameInputCertificate.BtnEnterClick(Sender: TObject);
begin
  inherited;
  BtnEnter.Enabled := False;

  try
    LoadOrderInfo(EditID.Text);
  finally
    BtnEnter.Enabled := True;
  end;
end;

procedure TfFrameInputCertificate.SyncCard(const nCard: TIdCardInfoStr;
  const nReader: TSDTReaderItem);
var nStr: string;
begin
  nStr := '读取到身份证信息: [ %s ]=>[ %s.%s ]';
  nStr := Format(nStr, [nReader.FID, nCard.FName, nCard.FIdSN]);
  WriteLog(nStr);
  FID := nCard.FIdSN;
  EditID.Text := nCard.FIdSN;
  //BtnEnterClick(nil);
end;

procedure TfFrameInputCertificate.LoadOrderInfo(nID: string);
var nStr: string;
    nP: TFormCommandParam;
begin
  nStr := Trim(EditID.Text);

  if Length(nStr) = 18 then //身份证号
  begin
    if UpperCase(Copy(nStr, 18, 1))<>GetIDCardNumCheckCode(Copy(nStr, 1, 17)) then
    begin
      ShowMsg('输入的身份证号非法,请重新输入.', sHint);
      Exit;
    end;

    nP.FParamA  := nStr;
    nP.FParamB  := '';
    CreateBaseFrameItem(cFI_FrameSaleMakeCard, Self.Parent);
    BroadcastFrameCommand(nil, cCmd_MakeNCSaleCard, @nP);
    //宣传订单
  end else
  begin
    if FAICMFP = sFlag_Yes then
    begin
      ShowMsg('禁止密码取卡.', sHint);
      Exit;
    end;
    nP.FParamA  := '';
    nP.FParamB  := nStr;
    CreateBaseFrameItem(cFI_FrameSaleMakeCard, Self.Parent);
    BroadcastFrameCommand(nil, cCmd_MakeNCSaleCard, @nP);
    //宣传订单
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameInputCertificate, TfFrameInputCertificate.FrameID);
end.

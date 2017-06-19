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
    procedure BtnNumClick(Sender: TObject);
    procedure EditIDChange(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure EditIDKeyPress(Sender: TObject; var Key: Char);
    procedure BtnEnterClick(Sender: TObject);
  private
    { Private declarations }
    FListA, FListB, FListC: TStrings;
    //�б���Ϣ
    procedure LoadOrderInfo(nID: string);
    //���ض�����Ϣ
    procedure SyncCard(const nCard: TIdCardInfoStr;const nReader: TSDTReaderItem);
  public
    { Public declarations }
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    procedure OnShowFrame; override;

    class function FrameID: integer; override;
    function DealCommand(Sender: TObject; const nCmd: Integer;
      const nParamA: Pointer; const nParamB: Integer): Integer; override;
    {*��������*}
  end;

var
  fFrameInputCertificate: TfFrameInputCertificate;

implementation

{$R *.dfm}

uses
  ULibFun, USysLoger, UDataModule, UMgrControl, USelfHelpConst, UBase64,
  USysBusiness, UFrameMakeCard, UFormBase;

//------------------------------------------------------------------------------
//Desc: ��¼��־
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFrameInputCertificate, '����ƾ֤��Ϣ', nEvent);
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
begin
  DoubleBuffered := True;
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
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
  nStr := '��ȡ�����֤��Ϣ: [ %s ]=>[ %s.%s ]';
  nStr := Format(nStr, [nReader.FID, nCard.FName, nCard.FIdSN]);
  WriteLog(nStr);
  
  EditID.Text := nCard.FIdSN;
  //BtnEnterClick(nil);
end;

procedure TfFrameInputCertificate.LoadOrderInfo(nID: string);
var nStr: string;
    nP: TFormCommandParam;
begin
  nStr := Trim(EditID.Text);

  if Length(nStr) = 18 then //���֤��
  begin
    if UpperCase(Copy(nStr, 18, 1))<>GetIDCardNumCheckCode(Copy(nStr, 1, 17)) then
    begin
      ShowMsg('��������֤�ŷǷ�,����������.', sHint);
      Exit;
    end;

    nStr := GetShopOrderInfoByID(nStr);
    if nStr = '' then
    begin
      nStr := 'δ��ѯ�����֤��[ %s ]΢�Ŷ�����Ϣ�������Ƿ�����ض�����.';
      nStr := Format(nStr, [EditID.Text]);
      ShowMsg(nStr, sHint);
      Writelog(nStr);
      Exit;
    end;

    CreateBaseFrameItem(cFI_FrameReadCardID, Self.Parent)
  end else

  if Length(nStr) >= 20 then //�̳ǵ���
  begin
    if ShopOrderHasUsed(nStr) then Exit;

    nStr := GetShopOrderInfoByNo(nStr);
    if nStr = '' then
    begin
      nStr := 'δ��ѯ�������̳Ƕ���[ %s ]��ϸ��Ϣ�����鶩�����Ƿ���ȷ';
      nStr := Format(nStr, [EditID.Text]);
      ShowMsg(nStr, sHint);
      Exit;
    end;

    FListA.Clear;
    FListB.Clear;

    FListA.Text := DecodeBase64(nStr);
    FListB.Text := DecodeBase64(FListA[0]);
    if FListB.Text = '' then
    begin
      nStr := 'ϵͳδ���������̳Ƕ���[ %s ]��ϸ��Ϣ,����ϵ����Ա���';
      nStr := Format(nStr, [EditID.Text]);
      ShowMsg(nStr, sHint);
      Exit;
    end;

    nP.FParamA  := FListB.Text;
    CreateBaseFrameItem(cFI_FrameMakeCard, Self.Parent);
    BroadcastFrameCommand(nil, cCmd_MakeCard, @nP);
    //��������
  end else

  begin
    ShowMsg('������Ϣ��ȫ,����������.', sHint);
    Exit;
  end;      
end;

initialization
  gControlManager.RegCtrl(TfFrameInputCertificate, TfFrameInputCertificate.FrameID);
end.

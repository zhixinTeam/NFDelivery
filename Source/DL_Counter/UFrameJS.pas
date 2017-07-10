{*******************************************************************************
  ����: dmzn@163.com 2012-4-29
  ����: ��������
*******************************************************************************}
unit UFrameJS;

{$I Link.Inc}
{$I js_inc.inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  {$IFDEF MultiReplay}UMultiJS_Reply, {$ELSE}UMultiJS, {$ENDIF}
  UMgrCodePrinter, ULibFun, USysConst, UFormWait, UFormInputbox, UDataModule,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, StdCtrls,
  ExtCtrls, cxLabel, cxGraphics, cxControls;

type
  TfFrameCounter = class(TFrame)
    GroupBox1: TGroupBox;
    LabelHint: TcxLabel;
    EditTruck: TLabeledEdit;
    EditDai: TLabeledEdit;
    BtnStart: TButton;
    BtnClear: TButton;
    EditTon: TLabeledEdit;
    Timer1: TTimer;
    BtnPause: TButton;
    EditCode: TLabeledEdit;
    EditID: TComboBox;
    EditPrinter: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    EditStock: TLabeledEdit;
    procedure BtnClearClick(Sender: TObject);
    procedure BtnStartClick(Sender: TObject);
    procedure EditTonChange(Sender: TObject);
    procedure EditTonDblClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure BtnPauseClick(Sender: TObject);
    procedure EditIDSelect(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FBill: string;
    //������
    FDaiNum: Integer;
    //װ����
    FPeerWeight: Integer;
    //����
    FTunnel: PMultiJSTunnel;
    //����ͨ��
    procedure SaveCountResult(const nProcess: Boolean);
    //�������
    constructor Create(AOwner: TComponent); override;
    //��ʼ��
  end;

implementation

{$R *.dfm}

constructor TfFrameCounter.Create(AOwner: TComponent);
begin
  inherited;
  FBill := '';
  BtnPause.Enabled := True;
  
  {$IFDEF USE_MIT}
  EditTruck.ReadOnly := True;
  {$ELSE}
  EditTruck.ReadOnly := False;
  {$ENDIF}
end;

procedure TfFrameCounter.SaveCountResult(const nProcess: Boolean);
var nDai: Integer;
begin
  if IsNumber(LabelHint.Caption, False) then
       nDai := StrToInt(LabelHint.Caption)
  else nDai := 0;

  if (FBill <> '') and (nDai > 0) then
  try
    BtnClear.Enabled := False;
    if nProcess then
      ShowWaitForm(Application.MainForm, '�������');
    SaveTruckCountData(FBill, nDai);
  finally
    BtnClear.Enabled := True;
    if nProcess then CloseWaitForm;
  end;
end;

procedure TfFrameCounter.BtnClearClick(Sender: TObject);
begin
  BtnClear.Enabled := False;
  try
    if Assigned(Sender) then
    begin
      {$IFDEF USE_MIT}
      if not StopJS(FTunnel.FID) then Exit;
      {$ELSE}
      if not gMultiJSManager.DelJS(FTunnel.FID) then Exit;
      if not BtnStart.Enabled then
        SaveCountResult(True);
      //��������
      {$ENDIF}

      Sleep(500);
      //for delay
      FBill := '' ;
      LabelHint.Caption := '0';

      EditTruck.Text := '';
      EditDai.Text := '';
      EditTon.Text := '';
      EditID.Clear;

      EditDai.Enabled := True;
      EditTon.Enabled := True;
      BtnStart.Enabled := True;
      BtnPause.Enabled := True;
    end;
  finally 
    BtnClear.Enabled := True;
  end;
end;

procedure TfFrameCounter.BtnStartClick(Sender: TObject);
var nHint, nPrinter, nBill: string;
    nInt: Integer;
begin
  if EditID.ItemIndex >=0 then
       nBill := EditID.Text
  else nBill := FBill;

  if EditPrinter.ItemIndex >=0 then
       nPrinter := EditPrinter.Text
  else nPrinter := FTunnel.FID;

  EditTruck.Text := Trim(EditTruck.Text);
  if EditTruck.Text = '' then
  begin
    ShowDlg('��ˢ�¶��л�ȡ������Ϣ', sHint);
    Exit;
  end;

  if (not IsNumber(EditDai.Text, False)) or (StrToInt(EditDai.Text) <= 0) then
  begin
    ShowDlg('���������', sHint);
    Exit;
  end;

  BtnStart.Enabled := False;
  //disabled
  ShowWaitForm(Application.MainForm, '���������', True);
  try
    Sleep(200);
    //for delay
    
    {$IFDEF USE_MIT}
    if not PrintBillCode(nPrinter, nBill, nHint) then
    begin
      CloseWaitForm;
      Application.ProcessMessages;

      ShowDlg(nHint, sWarn);
      Exit;
    end;
    {$ELSE}
    if not gCodePrinterManager.PrintCode(nPrinter, Trim(EditCode.Text), nHint) then
    begin
      CloseWaitForm;
      Application.ProcessMessages;

      ShowDlg(nHint, sWarn);
      Exit;
    end;  
    {$ENDIF}

    nInt := StrToInt(EditDai.Text);
    {$IFDEF USE_MIT}
    ShowWaitForm(nil, '���Ӽ�����');
    StartJS(FTunnel.FID, EditTruck.Text, nBill, nInt);
    {$ELSE}
    if not gMultiJSManager.AddJS(FTunnel.FID, EditTruck.Text, '', nInt) then
      Exit;
    {$ENDIF}

    Timer1.Enabled := True;
    //����
  finally
    CloseWaitForm;
    BtnStart.Enabled := True;
  end;

  EditDai.Enabled := False;
  EditTon.Enabled := False;
  BtnStart.Enabled := False;

  {$IFNDEF USE_MIT}
  BtnPause.Enabled := True;
  {$ENDIF}
end;

procedure TfFrameCounter.EditTonDblClick(Sender: TObject);
var nStr: string;
begin
  nStr := IntToStr(FPeerWeight);
  if not ShowInputBox('���������: ', sHint, nStr) then Exit;

  if IsNumber(nStr, False) and (StrToInt(nStr) > 0) then
       FPeerWeight := StrToInt(nStr)
  else ShowMsg('����Ϊ����0������', sHint);
end;

procedure TfFrameCounter.EditTonChange(Sender: TObject);
var nVal: Double;
begin
  if not EditTon.Focused then Exit;
  if FPeerWeight < 1 then FPeerWeight := 50;
  if not IsNumber(EditTon.Text, True) then Exit;

  nVal := StrToFloat(EditTon.Text) * 1000 / FPeerWeight;
  EditDai.Text := IntToStr(Trunc(nVal));
end;

procedure TfFrameCounter.Timer1Timer(Sender: TObject);
begin
  if (not BtnStart.Enabled) and IsNumber(LabelHint.Caption, False) then
  begin
    FDaiNum := StrToInt(LabelHint.Caption);
    if StrToInt(EditDai.Text) <> FDaiNum then Exit;

    Timer1.Enabled := False;
    {$IFDEF USE_MIT}
    BtnClearClick(nil);
    {$ELSE}
    BtnClear.Click;
    {$ENDIF}
    ShowMsg('װ�����', sHint);
  end;
end;

procedure TfFrameCounter.BtnPauseClick(Sender: TObject);
begin
  {$IFDEF USE_MIT}
  PauseJS(FTunnel.FID);
  {$ELSE}
  gMultiJSManager.PauseJS(FTunnel.FID);
  {$ENDIF}

  Sleep(500);
  //for delay
  //BtnStart.Enabled := True;
end;

//Date: 2015/1/22
//Parm: Դ�ַ�����ָ�����ȣ����ַ�;���䷽ʽ
//Desc: ��Դ�ַ���(nStr)"��(Fasle)/��(True)"��(Length(nStr)-nLen)���ַ�(nFillStr),
function FillString(const nStr: string; nLen: Integer;
  nFillStr: Char; nRight: Boolean=False): string;
var nTmp: string;
begin
  nTmp := Trim(nStr);
  if Length(nTmp) > nLen then
  begin
    Result:=nTmp;
    Exit;
  end;

  case nRight of
  True:Result:= nTmp + StringOfChar(nFillStr, nLen - Length(nTmp));
  False:Result:= StringOfChar(nFillStr, nLen - Length(nTmp)) + nTmp;
  end;
end;


procedure TfFrameCounter.EditIDSelect(Sender: TObject);
var nStr, nCode, nBill, nArea, nSeal, nCusCode: string;
    nPrefixLen, nIDLen: Integer;
begin
  {$IFNDEF USE_MIT}
  Exit;
  {$ENDIF}

  nStr := 'Select B_Prefix,B_IDLen From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, ['Sys_SerialBase','BusFunction', 'Bus_Bill']);
  //xxxxx
  with FDM.SQLQuery(nStr, FDM.SQLQuery1) do
  if RecordCount>0 then
  begin
    nPrefixLen := Length(Fields[0].AsString);
    nIDLen     := Fields[1].AsInteger;
  end else begin
    nPrefixLen := -1;
    nIDLen     := -1;
  end;
  //xxxxx

  nStr := 'Select * From S_Bill Where L_ID=''%s''';
  nStr := Format(nStr, [EditID.Text]);
  with FDM.SQLQuery(nStr, FDM.SQLQuery1) do
  if RecordCount > 0 then
  begin
    nStr := FieldByName('L_StockName').AsString;
    if Assigned(FindField('L_StockBrand')) then
      nStr := nStr + '-' +FieldByName('L_StockBrand').AsString;

    EditStock.Text := nStr;
    EditTon.Text := Format('%.3f', [FieldByName('L_Value').AsFloat]);

    nCode     := '';
    nBill     := FieldByName('L_ID').AsString;
    nArea     := FieldByName('L_Area').AsString;
    nSeal     := FieldByName('L_Seal').AsString;
    nCusCode  := FieldByName('L_CusCode').AsString;
    //xxxxx

    {$IFDEF PrintChinese}
    //protocol: ��������+�ͻ�����(������) + ��������(ĩ3λ) + ���κ�;
    if (nArea <> '') then
    begin
      nStr := 'Select B_Value From Sys_ChineseBase Where B_Source=''%s'' and ' +
              'B_Valid=''Y''';
      nStr := Format(nStr, [nArea]);
      //xxxxx

      with FDM.SQLQuery(nStr, FDM.SQLTemp) do
      if RecordCount>0 then
      begin
        nCode := nCode + Fields[0].AsString +
                 Copy(nBill, nPrefixLen + 1, nIDLen - nPrefixLen); //����
        //����к���,���д���
      end;
    end;

    if nCode = '' then
      nCode := Copy(nBill, nPrefixLen + 1, nIDLen - nPrefixLen);
    //���Ϊ��,������ˮ��

    nCode := nCode + FillString(nCusCode, 2, ' ');
    nCode := nCode + FillString(nSeal, 6, '0');
    {$ELSE}
    //protocol: yymmdd(����ʱ��) + ���κ� + �ͻ�����(������) + ��������(ĩ3λ);
    nCode := nCode + Copy(nBill, nPrefixLen + 1, 6);
    nCode := nCode + FillString(nSeal, 6, '0');
    nCode := nCode + FillString(nCusCode, 2, ' ');
    nCode := nCode + Copy(nBill, nPrefixLen + 7, nIDLen-nPreFixLen-6);
    {$ENDIF}

    EditCode.Text := nCode;
  end;
end;

end.

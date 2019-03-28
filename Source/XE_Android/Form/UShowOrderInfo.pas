unit UShowOrderInfo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  UAndroidFormBase, FMX.Edit, FMX.Controls.Presentation, FMX.Layouts,
  UMITPacker,UClientWorker,UBusinessConst,USysBusiness,UMainFrom, FMX.ListBox,
  FMX.ComboEdit;

type
  TFrmShowOrderInfo = class(TfrmFormBase)
    Label6: TLabel;
    tmrGetOrder: TTimer;
    BtnCancel: TSpeedButton;
    BtnOK: TSpeedButton;
    EditKZValue: TEdit;
    Label10: TLabel;
    Label8: TLabel;
    lblTruck: TLabel;
    lblMate: TLabel;
    Label4: TLabel;
    lblProvider: TLabel;
    lblID: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    LabelNext: TLabel;
    LabelMValue: TLabel;
    Label7: TLabel;
    Label3: TLabel;
    EditKZComment: TComboEdit;
    Label5: TLabel;
    EditArea: TComboEdit;
    Label9: TLabel;
    lblKD: TLabel;
    Label11: TLabel;
    EditResult: TComboEdit;
    Label12: TLabel;
    EditJS: TEdit;
    procedure tmrGetOrderTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gCardNO: string;
  gList: TStrings;
  FrmShowOrderInfo: TFrmShowOrderInfo;

implementation
var
  gOrders: TLadingBillItems;

{$R *.fmx}

procedure TFrmShowOrderInfo.BtnCancelClick(Sender: TObject);
begin
  inherited;
  MainForm.Show;
  Self.Hide;
end;

procedure TFrmShowOrderInfo.BtnOKClick(Sender: TObject);
var nStr : string;
    nForceUnLoadPlace: Boolean;
begin
  inherited;
  gList.Clear;
  nForceUnLoadPlace := False;
  if GetUnLoadList('ForceUPStock', nStr) then
  begin
    gList.Text := nStr;
    if gList.IndexOf(gOrders[0].FStockNo) >= 0 then
      nForceUnLoadPlace := True;

  end;

  nStr := Trim(EditJS.Text);
  if EditResult.ItemIndex = 1 then
  begin
    if nStr = '' then
    begin
      ShowMessage('请输入拒收原因');
      Exit;
    end;
  end;

  if nForceUnLoadPlace then
  begin
    if EditArea.Text = '' then
    begin
      ShowMessage('请选择卸货地点');
      Exit;
    end;
  end;

  if Length(gOrders)>0 then
  with gOrders[0] do
  begin
    FSeal := EditArea.Text;
    FKZComment := EditKZComment.Text;
    FKZValue := StrToFloatDef(EditKZValue.Text, 0);
    if EditResult.ItemIndex = 1 then
      FYSValid := 'N'
    else
    begin
      FYSValid := 'Y';
      nStr := '';
    end;
    FMemo := nStr;

    if SavePurchaseOrders('X', gOrders) then
         ShowMessage('验收成功')
    else ShowMessage('验收失败');

    MainForm.Show;
  end;
end;

procedure TFrmShowOrderInfo.FormActivate(Sender: TObject);
begin
  inherited;
  lblID.Text       := '';
  lblProvider.Text := '';
  lblMate.Text     := '';
  lblTruck.Text    := '';
  EditKZValue.Text := '0.00';
  lblKD.Text       := '';
  tmrGetOrder.Enabled := True;
  SetLength(gOrders, 0);
  if not Assigned(gList) then
    gList := TStringList.Create;
end;

procedure TFrmShowOrderInfo.FormKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  inherited;
  {if Key = vkHardwareBack then//如果按下物理返回键
  begin
    MessageDlg('确认退出吗？', System.UITypes.TMsgDlgType.mtConfirmation,
      [System.UITypes.TMsgDlgBtn.mbOK, System.UITypes.TMsgDlgBtn.mbCancel], -1,

      procedure(const AResult: TModalResult)
      begin
        if AResult = mrOK then BtnCancelClick(Self);
      end
      );
      //退出程序

    Key := 0;//必须的，不然按否也会退出
    Exit;
  end;    }
end;

procedure TFrmShowOrderInfo.FormShow(Sender: TObject);
begin
  inherited;
  lblID.Text       := '';
  lblProvider.Text := '';
  lblMate.Text     := '';
  lblTruck.Text    := '';
  EditKZValue.Text := '0.00';

  EditArea.ItemIndex := 0;
  EditKZComment.ItemIndex := 0;
  lblKD.Text       := '';
  BtnOK.Enabled := False;
  tmrGetOrder.Enabled := True;
  SetLength(gOrders, 0);
  if not Assigned(gList) then
    gList := TStringList.Create;
end;

procedure TFrmShowOrderInfo.tmrGetOrderTimer(Sender: TObject);
var nIdx, nInt: Integer;
    nStr : string;
begin
  tmrGetOrder.Enabled := False;

  if not GetPurchaseOrders(gCardNO, 'X', gOrders) then
  begin
    BtnCancelClick(Self);
    Exit;
  end;

  nInt := 0;
  for nIdx := Low(gOrders) to High(gOrders) do
  with gOrders[nIdx] do
  begin
    FSelected := (FNextStatus='X') or (FNextStatus='M');
    if FSelected then Inc(nInt);
  end;

  if nInt<1 then
  begin
    nStr := '磁卡[%s]无需要验收车辆';
    nStr := Format(nStr, [gCardNo]);

    ShowMessage(nStr);
    Exit;
  end;

  with gOrders[0] do
  begin
    lblID.Text       := FID;
    lblProvider.Text := FCusName;
    lblMate.Text     := FStockName;
    lblTruck.Text    := FTruck;
    LabelNext.Text   := TruckStatusToStr(FNextStatus);
    LabelMValue.Text := FloatToStr(FPData.FValue);
    EditKZComment.Text := FKZComment;
    EditArea.Text      := FSeal;
    lblKD.Text       := FOrigin;

    EditKZValue.Text := FloatToStr(FKZValue);

    if FYSValid = 'N' then
    begin
      EditResult.ItemIndex := 1;
      EditJs.Text := FMemo;
    end
    else
    begin
      EditResult.ItemIndex := 0;
      EditJs.Text := '';
    end;

  end;

  gList.Clear;

  if not GetUnLoadList('UnLodingPlace', nStr) then
  begin
    nStr := '读取卸货地点失败';

    ShowMessage(nStr);
    Exit;
  end;

  if nStr = '' then
  begin
    nStr := '读取卸货地点失败';

    ShowMessage(nStr);
    Exit;
  end;

  gList.Text := nStr;

  EditArea.Items.Clear;
  for nIdx := 0 to gList.Count - 1 do
  begin
    EditArea.Items.Add(gList.Strings[nIdx]);
  end;

  BtnOK.Enabled := True;
end;

end.

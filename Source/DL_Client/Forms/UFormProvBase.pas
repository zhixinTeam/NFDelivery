{*******************************************************************************
  作者: fendou116688@163.com 2015/9/19
  描述: 办理采购入厂单绑定磁卡
*******************************************************************************}
unit UFormProvBase;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxButtonEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxDropDownEdit, cxLabel,
  USysBusiness;

type
  TfFormProvBase = class(TfFormNormal)
    dxGroup2: TdxLayoutGroup;
    EditMate: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditProvider: TcxTextEdit;
    dxlytmLayout1Item3: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxlytmLayout1Item12: TdxLayoutItem;
    EditMateID: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditProID: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    dxLayout1Group4: TdxLayoutGroup;
    EditOrder: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditOrign: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    EditValue: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure EditLadingKeyPress(Sender: TObject; var Key: Char);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  protected
    { Protected declarations }
    FListA: TStrings;
    //卡片数据
    FCardData: TOrderItemInfo;
    FNewBillID: string;
    //新提单号
    FBuDanFlag: string;
    //补单标记
    procedure InitFormData;
    //初始化界面
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, DB, IniFiles, UMgrControl, UAdjustForm, UFormBase, UBusinessPacker,
  UDataModule, USysDB, USysGrid, USysConst;

class function TfFormProvBase.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nStr, nFilter, nCusID: string;
    nP: PFormCommandParam;
begin
  Result := nil;
  if not Assigned(nParam) then
  begin
    New(nP);
    FillChar(nP^, SizeOf(TFormCommandParam), #0);
  end else
  begin
    nP := nParam;
    nStr := nP.FParamA;
  end;

  if nStr = '' then
  try
    CreateBaseFormItem(cFI_FormGetCustom, nPopedom, nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
    nCusID := nP.FParamB;

    nFilter    := '';
    nP.FParamA := nCusID;
    CreateBaseFormItem(cFI_FormGetMine, '', nP);
    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK)
      and (nP.FParamB<>'') then nFilter:=nP.FParamB;
    //选择矿点

    nP.FParamA := nCusID;
    nP.FParamB := '';
    nP.FParamC := sFlag_Provide;
    if nFilter<>'' then nP.FParamD:=nFilter;

    CreateBaseFormItem(cFI_FormGetOrder, '', nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
    nStr := nP.FParamB;
  finally
    if not Assigned(nParam) then Dispose(nP);
  end;

  with TfFormProvBase.Create(Application) do
  try
    Caption := '开采购入厂单';
    ActiveControl := EditTruck;
    AnalyzeOrderInfo(nStr, FCardData);

    InitFormData;
    //xxxx

    if Assigned(nParam) then
    with PFormCommandParam(nParam)^ do
    begin
      FCommand := cCmd_ModalResult;
      FParamA := ShowModal;

      if FParamA = mrOK then
           FParamB := FNewBillID
      else FParamB := '';
    end else ShowModal;
  finally
    Free;
  end;
end;

class function TfFormProvBase.FormID: integer;
begin
  Result := cFI_FormProvBase;
end;

procedure TfFormProvBase.FormCreate(Sender: TObject);
begin
  FListA    := TStringList.Create;
  AdjustCtrlData(Self);
  LoadFormConfig(Self);
end;

procedure TfFormProvBase.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveFormConfig(Self);
  ReleaseCtrlData(Self);

  FListA.Free;
end;

//Desc: 回车键
procedure TfFormProvBase.EditLadingKeyPress(Sender: TObject; var Key: Char);
var nP: TFormCommandParam;
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;

    if Sender = EditValue then
         BtnOK.Click
    else Perform(WM_NEXTDLGCTL, 0, 0);
  end;

  if (Sender = EditTruck) and (Key = Char(VK_SPACE)) then
  begin
    Key := #0;
    nP.FParamA := EditTruck.Text;
    CreateBaseFormItem(cFI_FormGetTruck, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
      EditTruck.Text := nP.FParamB;
    EditTruck.SelectAll;
  end;
end;

procedure TfFormProvBase.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nChar: Char;
begin
  nChar := Char(VK_SPACE);
  EditLadingKeyPress(EditTruck, nChar);
end;

//------------------------------------------------------------------------------
procedure TfFormProvBase.InitFormData;
begin
  with FCardData do
  begin
    EditOrder.Text    := FOrders;
    EditProID.Text    := FCusID;
    EditProvider.Text := FCusName;

    EditMateID.Text   := FStockID;
    EditMate.Text     := FStockName;
    EditOrign.Text    := FStockArea;

    EditValue.Text    := FloatToStr(FValue);
  end;
end;

function TfFormProvBase.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
begin
  Result := True;

  if Sender = EditTruck then
  begin
    Result := Length(EditTruck.Text) > 2;
    nHint := '车牌号长度应大于2位';
  end;
end;

//Desc: 保存
procedure TfFormProvBase.BtnOKClick(Sender: TObject);
var nOrder: string;
begin
  if not IsDataValid then Exit;
  //check valid

  with FListA, FCardData do
  begin
    Clear;
    Values['Order']     := FOrders;
    Values['Origin']    := FStockArea;
    Values['Factory']   := gSysParam.FFactNum;
    Values['Truck']     := Trim(EditTruck.Text);

    Values['ProID']     := FCusID;
    Values['ProName']   := FCusName;

    Values['StockNO']   := FStockID;
    Values['StockName'] := FStockName;
    Values['Value']     := Trim(EditValue.Text);
  end;

  nOrder := SaveOrder(PackerEncodeStr(FListA.Text));
  if nOrder='' then Exit;
  SetOrderCard(nOrder, FListA.Values['Truck']);

  ModalResult := mrOK;
  ShowMsg('采购入厂单保存成功', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormProvBase, TfFormProvBase.FormID);
end.

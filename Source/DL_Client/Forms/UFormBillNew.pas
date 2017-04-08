{*******************************************************************************
  作者: dmzn@163.com 2014-09-01
  描述: 开提货单
*******************************************************************************}
unit UFormBillNew;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxButtonEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxDropDownEdit;

type
  TfFormBillNew = class(TfFormNormal)
    dxGroup2: TdxLayoutGroup;
    EditValue: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditCus: TcxTextEdit;
    dxlytmLayout1Item3: TdxLayoutItem;
    EditCName: TcxTextEdit;
    dxlytmLayout1Item4: TdxLayoutItem;
    EditStock: TcxTextEdit;
    dxlytmLayout1Item9: TdxLayoutItem;
    EditSName: TcxTextEdit;
    dxlytmLayout1Item10: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxlytmLayout1Item12: TdxLayoutItem;
    dxlytmLayout1Item13: TdxLayoutItem;
    EditType: TcxComboBox;
    dxGroupLayout1Group6: TdxLayoutGroup;
    dxGroupLayout1Group7: TdxLayoutGroup;
    ListStock: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    EditPack: TcxComboBox;
    dxLayout1Item3: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure EditLadingKeyPress(Sender: TObject; var Key: Char);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure ListStockPropertiesChange(Sender: TObject);
  protected
    { Protected declarations }
    FCardData,FListA: TStrings;
    //卡片数据
    FNewBillID: string;
    //新提单号
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
  UDataModule, USysBusiness, USysDB, USysGrid, USysConst;

class function TfFormBillNew.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if GetSysValidDate < 1 then Exit;

  if not Assigned(nParam) then
  begin
    New(nP);
    FillChar(nP^, SizeOf(TFormCommandParam), #0);
  end else nP := nParam;

  with TfFormBillNew.Create(Application) do
  try
    Caption := '开单';
    ActiveControl := EditCus;

    InitFormData;

    if Assigned(nP) then
    with PFormCommandParam(nP)^ do
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

class function TfFormBillNew.FormID: integer;
begin
  Result := cFI_FormBillNew;
end;

procedure TfFormBillNew.FormCreate(Sender: TObject);
begin
  FCardData := TStringList.Create;
  FListA := TStringList.Create;

  AdjustCtrlData(Self);
  LoadFormConfig(Self);
end;

procedure TfFormBillNew.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveFormConfig(Self);
  ReleaseCtrlData(Self);

  FCardData.Free;
  FListA.Free;
end;

//Desc: 回车键
procedure TfFormBillNew.EditLadingKeyPress(Sender: TObject; var Key: Char);
var nP: TFormCommandParam;
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;

    if Sender = EditCus then
    begin
      nP.FParamA := EditCus.Text;
      CreateBaseFormItem(cFI_FormGetCustom, '', @nP);

      if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
      begin
        EditCus.Text := nP.FParamB;
        EditCName.Text := nP.FParamC;
      end;
    end else
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

procedure TfFormBillNew.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nChar: Char;
begin
  nChar := Char(VK_SPACE);
  EditLadingKeyPress(EditTruck, nChar);
end;

//------------------------------------------------------------------------------
procedure TfFormBillNew.InitFormData;
var nStr: string;
    nEx: TDynamicStrArray;
begin
  SetLength(nEx, 1);
  nStr := 'D_ParamB=Select D_ParamB,D_Value From $Table ' +
          'Where D_Name=''$Name'' Order By D_Index ASC';
  nStr := MacroValue(nStr, [MI('$Table', sTable_SysDict),
          MI('$Name', sFlag_StockItem)]);

  nEx[0] := 'D_ParamB';
  FDM.FillStringsData(ListStock.Properties.Items, nStr, 0, '.', nEx);
  AdjustCXComboBoxItem(ListStock, False);
end;

function TfFormBillNew.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
begin
  Result := True;

  if Sender = ListStock then
  begin
    Result := ListStock.ItemIndex >= 0;
    nHint := '请先选择物料';
  end else

  if Sender = EditCName then
  begin
    Result := Length(EditCName.Text) > 0;
    nHint := '请先选择客户';
  end else

  if Sender = EditTruck then
  begin
    Result := Length(EditTruck.Text) > 2;
    nHint := '车牌号长度应大于2位';
  end else

  if Sender = EditValue then
  begin
    Result := IsNumber(EditValue.Text, True) and (StrToFloat(EditValue.Text)>0);
    nHint := '请填写有效的办理量';
  end;
end;

//Desc: 保存
procedure TfFormBillNew.BtnOKClick(Sender: TObject);
begin
  if not IsDataValid then Exit;
  //check valid

  with FListA do
  begin
    Values['CusID']   := Trim(EditCus.Text);
    Values['CusName'] := Trim(EditCName.Text);

    Values['StockNO'] := Trim(EditStock.Text);
    Values['StockName'] := Trim(EditSName.Text);
    Values['Value'] := EditValue.Text;

    Values['Truck'] := EditTruck.Text;
    Values['Lading'] := sFlag_TiHuo;
    Values['IsVIP'] := GetCtrlData(EditType);
  end;

  FNewBillID := SaveBillNew(PackerEncodeStr(FListA.Text));
  //call mit bus
  if FNewBillID = '' then Exit;

  SetBillCard(FNewBillID, EditTruck.Text, True, True);
  //办理磁卡

  ModalResult := mrOk;
  ShowMsg('销售订单保存成功', sHint);
end;

procedure TfFormBillNew.ListStockPropertiesChange(Sender: TObject);
begin
  inherited;
  EditStock.Text := GetCtrlData(ListStock);
  EditSName.Text := ListStock.Text;
end;

initialization
  gControlManager.RegCtrl(TfFormBillNew, TfFormBillNew.FormID);
end.

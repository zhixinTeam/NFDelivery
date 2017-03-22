{*******************************************************************************
  作者: fendou116688@163.com 2017/3/22
  描述: 火车厢档案
*******************************************************************************}
unit UFormStationStandard;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxCheckBox, cxButtonEdit;

type
  TfFormStationStandard = class(TfFormNormal)
    EditValue: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    CheckValid: TcxCheckBox;
    dxLayout1Item4: TdxLayoutItem;
    EditPreFix: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditStockID: TcxComboBox;
    dxLayout1Item6: TdxLayoutItem;
    EditStockName: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditCusID: TcxComboBox;
    dxLayout1Item8: TdxLayoutItem;
    EditCusName: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditStockIDPropertiesEditValueChanged(Sender: TObject);
  protected
    { Protected declarations }
    FRecord: string;
    //记录编号
    procedure LoadFormData(const nID: string);
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
  ULibFun, UMgrControl, UDataModule, USysDB, USysConst, UFormCtrl, UAdjustForm;

class function TfFormStationStandard.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormStationStandard.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '车厢标重 - 添加';
      FRecord := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '车厢标重 - 修改';
      FRecord := nP.FParamA;
    end;

    LoadFormData(FRecord); 
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormStationStandard.FormID: integer;
begin
  Result := cFI_FormStationStandard;
end;

procedure TfFormStationStandard.LoadFormData(const nID: string);
var nStr: string;
begin
  nStr := 'D_ParamB=Select D_ParamB,D_Value From %s Where D_Name=''%s'' ' +
          'And D_Index>=0 Order By D_Index DESC';
  nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem]);

  FDM.FillStringsData(EditStockID.Properties.Items, nStr, 0, '.');
  AdjustCXComboBoxItem(EditStockID, False);
  EditStockID.ItemIndex := -1;

  nStr := 'P_ID=Select P_ID,P_Name From %s Order By P_ID ASC';
  nStr := Format(nStr, [sTable_Provider]);

  FDM.FillStringsData(EditCusID.Properties.Items, nStr, 0, '.');
  AdjustCXComboBoxItem(EditCusID, False);
  EditCusID.ItemIndex := -1;  

  if nID <> '' then
  begin
    nStr := 'Select * From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_StationTruck, nID]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      SetCtrlData(EditCusID, FieldByName('S_CusID').AsString);
      SetCtrlData(EditStockID, FieldByName('S_Stock').AsString);

      EditValue.Text := FieldByName('S_Value').AsString;
      EditPreFix.Text:= FieldByName('S_TruckPreFix').AsString;
      CheckValid.Checked := FieldByName('S_Valid').AsString = sFlag_Yes;
    end;
  end;  

  ActiveControl := EditPrefix;
end;

function TfFormStationStandard.OnVerifyCtrl(Sender: TObject;
  var nHint: string): Boolean;
begin
  Result := True;
  if Sender = EditValue then
  begin
    Result := IsNumber(EditValue.Text, True) And (StrToFloat(EditValue.Text)>0);
    nHint  := '请填写有效的车厢标重';
  end else

  if Sender = EditPreFix then
  begin
    Result := EditPreFix.Text <> '';
    nHint  := '请填写有效的车厢前缀';
  end;  
end;  

//Desc: 保存
procedure TfFormStationStandard.BtnOKClick(Sender: TObject);
var nStr,nV: string;
begin
  if not IsDataValid then Exit;

  if CheckValid.Checked then
       nV := sFlag_Yes
  else nV := sFlag_No;

  if FRecord = '' then
       nStr := ''
  else nStr := SF('R_ID', FRecord, sfVal);

  nStr := MakeSQLByStr([SF('S_Stock', GetCtrlData(EditStockID)),
          SF('S_StockName', EditStockName.Text),
          SF('S_CusID', GetCtrlData(EditCusID)),
          SF('S_CusName', EditCusName.Text),
          SF('S_Value', EditValue.Text, sfVal),
          SF('S_TruckPreFix', EditPreFix.Text),
          SF('S_Valid', nV)
          ], sTable_StationTruck, nStr, FRecord = '');
  FDM.ExecuteSQL(nStr);

  ModalResult := mrOk;
  ShowMsg('车厢标重保存成功', sHint);
end;

procedure TfFormStationStandard.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  ReleaseCtrlData(Self);
end;

procedure TfFormStationStandard.EditStockIDPropertiesEditValueChanged(
  Sender: TObject);
var nStr: string;
    nPos: Integer;
begin
  inherited;

  nStr := TcxComboBox(Sender).Text;
  nPos := Pos('.', nStr);
  System.Delete(nStr, 1, nPos);

  if Sender = EditStockID then
  begin
    EditStockName.Text := nStr;
  end else

  if Sender = EditCusID then
  begin
    EditCusName.Text := nStr;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormStationStandard, TfFormStationStandard.FormID);
end.

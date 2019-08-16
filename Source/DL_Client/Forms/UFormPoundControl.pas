{*******************************************************************************
  作者: juner11212436@163.com 2019-05-21
  描述: 过磅物料控制
*******************************************************************************}
unit UFormPoundControl;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxCheckBox, cxSpinEdit, cxTimeEdit;

type
  TfFormPoundControl = class(TfFormNormal)
    CheckValid: TcxCheckBox;
    dxLayout1Item4: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    ChkUseControl: TcxCheckBox;
    dxLayout1Item3: TdxLayoutItem;
    EditStock: TcxComboBox;
    dxLayout1Item6: TdxLayoutItem;
    EditPoundStation: TcxComboBox;
    dxLayout1Item5: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure EditStockPropertiesChange(Sender: TObject);
  protected
    { Protected declarations }
    FTruckID: string;
    procedure LoadFormData(const nID: string);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormCtrl, USysDB, USysConst, UAdjustForm,
  USysBusiness;

type
  TCusItem = record
    FID   : string;
    FName : string;
  end;

var
  gStockItems: array of TCusItem;
  //客户列表

class function TfFormPoundControl.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormPoundControl.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '过磅物料控制 - 添加';
      FTruckID := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '过磅物料控制 - 修改';
      FTruckID := nP.FParamA;
    end;

    LoadFormData(FTruckID); 
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormPoundControl.FormID: integer;
begin
  Result := cFI_FormPoundControl;
end;

procedure TfFormPoundControl.LoadFormData(const nID: string);
var nStr: string;
    nIdx: Integer;
begin
  LoadPoundStation(EditPoundStation.Properties.Items);
  LoadPoundStock(EditStock.Properties.Items);

  nStr := 'Select * From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_PoundControl]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      if FieldByName('D_Value').AsString = sFlag_Yes then
        ChkUseControl.Checked := True;
    end;
  end;

  if nID <> '' then
  begin
    nStr := 'Select * From %s Where D_ID=%s';
    nStr := Format(nStr, [sTable_SysDict, nID]);
    FDM.QueryTemp(nStr);
  end;

  with FDM.SqlTemp do
  begin
    if (nID = '') or (RecordCount < 1) then
    begin
      CheckValid.Checked := True;
      Exit;
    end;

    SetCtrlData(EditPoundStation, FieldByName('D_Memo').AsString);
    SetCtrlData(EditStock, FieldByName('D_ParamC').AsString);
    CheckValid.Checked := FieldByName('D_ParamB').AsString = sFlag_Yes;
  end;
end;

//Desc: 保存
procedure TfFormPoundControl.BtnOKClick(Sender: TObject);
var nStr,nCID,nV,nVTotal: string;
begin
  if Trim(EditPoundStation.Text) = '' then
  begin
    ActiveControl := EditPoundStation;
    ShowMsg('请选择地磅', sHint);
    Exit;
  end;

  if Trim(EditStock.Text) = '' then
  begin
    ActiveControl := EditStock;
    ShowMsg('请选择原材料', sHint);
    Exit;
  end;

  if ChkUseControl.Checked then
       nVTotal := sFlag_Yes
  else nVTotal := sFlag_No;

  nStr := SF('D_Name', sFlag_PoundControl);
  nStr := MakeSQLByStr([
          SF('D_Name', sFlag_PoundControl),
          SF('D_Value', nVTotal)
          ], sTable_SysDict, nStr, False);

  if FDM.ExecuteSQL(nStr) <= 0 then
  begin
    nStr := MakeSQLByStr([
        SF('D_Name', sFlag_PoundControl),
        SF('D_Value', nVTotal)
        ], sTable_SysDict, '', True);
    FDM.ExecuteSQL(nStr);
  end;

  if CheckValid.Checked then
       nV := sFlag_Yes
  else nV := sFlag_No;

  if FTruckID = '' then
       nStr := ''
  else nStr := SF('D_ID', FTruckID, sfVal);

  nStr := MakeSQLByStr([SF('D_Memo', GetCtrlData(EditPoundStation)),
          SF('D_ParamB', nV),
          SF('D_Value', GetCtrlData(EditStock)),
          SF('D_Name', sFlag_PoundStock),
          SF('D_ParamC', EditStock.Text)
          ], sTable_SysDict, nStr, FTruckID = '');
  FDM.ExecuteSQL(nStr);

  ModalResult := mrOk;
  ShowMsg('指定地磅物料控制信息保存成功', sHint);
end;

procedure TfFormPoundControl.EditStockPropertiesChange(
  Sender: TObject);
var nIdx : Integer;
    nStr: string;
begin
  for nIdx := 0 to EditStock.Properties.Items.Count - 1 do
  begin;
    if Pos(EditStock.Text,EditStock.Properties.Items.Strings[nIdx]) > 0 then
    begin
      EditStock.SelectedItem := nIdx;
      Break;
    end;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormPoundControl, TfFormPoundControl.FormID);
end.

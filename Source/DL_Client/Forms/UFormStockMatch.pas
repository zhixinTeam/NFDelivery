{*******************************************************************************
  作者: juner11212436@163.com 2019-04-16
  描述: 销售量控制
*******************************************************************************}
unit UFormStockMatch;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxCheckBox, cxSpinEdit, cxTimeEdit;

type
  TfFormStockMatch = class(TfFormNormal)
    CheckValid: TcxCheckBox;
    dxLayout1Item4: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    EditStock: TcxComboBox;
    dxLayout1Item6: TdxLayoutItem;
    EditID: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
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
  ULibFun, UMgrControl, UDataModule, UFormCtrl, USysDB, USysConst;

type
  TCusItem = record
    FID   : string;
    FName : string;
  end;

var
  gCusItems: array of TCusItem;
  gStockItems: array of TCusItem;
  //客户列表

class function TfFormStockMatch.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormStockMatch.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '品种分组 - 添加';
      FTruckID := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '品种分组 - 修改';
      FTruckID := nP.FParamA;
    end;

    LoadFormData(FTruckID);
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormStockMatch.FormID: integer;
begin
  Result := cFI_FormStockMatch;
end;

procedure TfFormStockMatch.LoadFormData(const nID: string);
var nStr: string;
    nIdx: Integer;
begin
  EditStock.Properties.Items.Clear;
  nStr := 'Select D_ParamB, D_Value From %s where D_Name=''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      SetLength(gStockItems, RecordCount);

      nIdx := 0;
      try
        EditStock.Properties.BeginUpdate;

        First;

        while not Eof do
        begin
          if (Fields[0].AsString = '') or (Fields[1].AsString = '') then
          begin
            Next;
            Continue;
          end;
          with gStockItems[nIdx] do
          begin
            FID := Fields[0].AsString;
            FName := Fields[1].AsString;
          end;

          Inc(nIdx);
          EditStock.Properties.Items.Add(Fields[1].AsString);
          Next;
        end;
      finally
        EditStock.Properties.EndUpdate;
      end;
    end;
  end;

  if nID <> '' then
  begin
    nStr := 'Select * From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_StockMatch, nID]);
    FDM.QueryTemp(nStr);
  end;

  with FDM.SqlTemp do
  begin
    if (nID = '') or (RecordCount < 1) then
    begin
      CheckValid.Checked := True;
      Exit;
    end;

    EditID.Text := FieldByName('M_Group').AsString;
    EditStock.Text := FieldByName('M_Name').AsString;
    EditStock.ItemIndex := EditStock.SelectedItem;
    CheckValid.Checked := FieldByName('M_Status').AsString = sFlag_Yes;
  end;
end;

//Desc: 保存
procedure TfFormStockMatch.BtnOKClick(Sender: TObject);
var nStr,nCID,nV: string;
begin
  if Trim(EditID.Text) = '' then
  begin
    ActiveControl := EditID;
    ShowMsg('请输入分组', sHint);
    Exit;
  end;

  if Trim(EditStock.Text) = '' then
  begin
    ActiveControl := EditStock;
    ShowMsg('请选择物料', sHint);
    Exit;
  end;

  if CheckValid.Checked then
       nV := sFlag_Yes
  else nV := sFlag_No;

  if FTruckID = '' then
       nStr := ''
  else nStr := SF('R_ID', FTruckID, sfVal);

  nStr := MakeSQLByStr([
          SF('M_Status', nV),
          SF('M_ID', gStockItems[EditStock.ItemIndex].FID),
          SF('M_Name', gStockItems[EditStock.ItemIndex].FName),
          SF('M_Group', EditID.Text)
          ], sTable_StockMatch, nStr, FTruckID = '');
  FDM.ExecuteSQL(nStr);

  ModalResult := mrOk;
  ShowMsg('保存成功', sHint);
end;

procedure TfFormStockMatch.EditStockPropertiesChange(
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
  gControlManager.RegCtrl(TfFormStockMatch, TfFormStockMatch.FormID);
end.

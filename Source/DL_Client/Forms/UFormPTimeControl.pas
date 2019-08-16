{*******************************************************************************
  作者: juner11212436@163.com 2019-02-21
  描述: 车辆限载管理
*******************************************************************************}
unit UFormPTimeControl;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxCheckBox, cxSpinEdit, cxTimeEdit;

type
  TfFormPTimeControl = class(TfFormNormal)
    CheckValid: TcxCheckBox;
    dxLayout1Item4: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    ChkUseXz: TcxCheckBox;
    dxLayout1Item3: TdxLayoutItem;
    EditStock: TcxComboBox;
    dxLayout1Item5: TdxLayoutItem;
    EditBegin: TcxTimeEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditEnd: TcxTimeEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditMemo: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
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
  gStockItems: array of TCusItem;
  //物料列表

class function TfFormPTimeControl.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormPTimeControl.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '原材料进厂时间控制 - 添加';
      FTruckID := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '原材料进厂时间控制 - 修改';
      FTruckID := nP.FParamA;
    end;

    LoadFormData(FTruckID); 
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormPTimeControl.FormID: integer;
begin
  Result := cFI_FormPTimeControl;
end;

procedure TfFormPTimeControl.LoadFormData(const nID: string);
var nStr: string;
    nIdx: Integer;
begin
  nStr := 'Select * From %s Where X_StockName=''%s''';
  nStr := Format(nStr, [sTable_PTimeControl, sFlag_PTimeControlTotal]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      if FieldByName('X_Valid').AsString = sFlag_Yes then
        ChkUseXz.Checked := True;
    end;
  end;

  EditStock.Properties.Items.Clear;
  nStr := 'Select M_ID, M_Name From %s  ';
  nStr := Format(nStr, [sTable_Materails]);

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
    nStr := Format(nStr, [sTable_PTimeControl, nID]);
    FDM.QueryTemp(nStr);
  end;

  with FDM.SqlTemp do
  begin
    if (nID = '') or (RecordCount < 1) then
    begin
      CheckValid.Checked := True;
      Exit;
    end;

    EditStock.Text := FieldByName('X_StockName').AsString;

    EditStock.ItemIndex := EditStock.SelectedItem;
    EditBegin.Text := FieldByName('X_BeginTime').AsString;
    EditEnd.Text := FieldByName('X_EndTime').AsString;
    EditMemo.Text := FieldByName('X_Memo').AsString;
    CheckValid.Checked := FieldByName('X_Valid').AsString = sFlag_Yes;
  end;
end;

//Desc: 保存
procedure TfFormPTimeControl.BtnOKClick(Sender: TObject);
var nStr,nCID,nV,nVTotal: string;
    nVal, nValDefXz: Double;
begin

  if Trim(EditStock.Text) = '' then
  begin
    ActiveControl := EditStock;
    ShowMsg('请选择物料', sHint);
    Exit;
  end;

  if Trim(EditBegin.Text) = '' then
  begin
    ActiveControl := EditBegin;
    ShowMsg('请输入有效起始时间', sHint);
    Exit;
  end;

  if Trim(EditEnd.Text) = '' then
  begin
    ActiveControl := EditEnd;
    ShowMsg('请输入有效结束时间', sHint);
    Exit;
  end;

  if ChkUseXz.Checked then
       nVTotal := sFlag_Yes
  else nVTotal := sFlag_No;

  nStr := SF('X_StockName', sFlag_PTimeControlTotal);
  nStr := MakeSQLByStr([
          SF('X_StockName', sFlag_PTimeControlTotal),
          SF('X_Valid', nVTotal)
          ], sTable_PTimeControl, nStr, False);

  if FDM.ExecuteSQL(nStr) <= 0 then
  begin
    nStr := MakeSQLByStr([
        SF('X_StockName', sFlag_PTimeControlTotal),
        SF('X_Valid', nVTotal)
        ], sTable_PTimeControl, '', True);
    FDM.ExecuteSQL(nStr);
  end;

  if CheckValid.Checked then
       nV := sFlag_Yes
  else nV := sFlag_No;

  if FTruckID = '' then
       nStr := ''
  else nStr := SF('R_ID', FTruckID, sfVal);

  nStr := MakeSQLByStr([SF('X_StockNo', gStockItems[EditStock.ItemIndex].FID),
          SF('X_StockName', gStockItems[EditStock.ItemIndex].FName),
          SF('X_Valid', nV),
          SF('X_BeginTime', EditBegin.Text),
          SF('X_EndTime', EditEnd.Text),
          SF('X_Memo', EditMemo.Text)
          ], sTable_PTimeControl, nStr, FTruckID = '');
  FDM.ExecuteSQL(nStr);

  ModalResult := mrOk;
  ShowMsg('原材料进厂时间控制信息保存成功', sHint);
end;

procedure TfFormPTimeControl.EditStockPropertiesChange(
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
  gControlManager.RegCtrl(TfFormPTimeControl, TfFormPTimeControl.FormID);
end.

{*******************************************************************************
  ����: juner11212436@163.com 2019-05-21
  ����: �������Ͽ���
*******************************************************************************}
unit UFormInFactControl;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxCheckBox, cxSpinEdit, cxTimeEdit;

type
  TfFormInFactControl = class(TfFormNormal)
    CheckValid: TcxCheckBox;
    dxLayout1Item4: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    ChkUseControl: TcxCheckBox;
    dxLayout1Item3: TdxLayoutItem;
    EditStock: TcxComboBox;
    dxLayout1Item6: TdxLayoutItem;
    EditInFactStation: TcxComboBox;
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
  //�ͻ��б�

class function TfFormInFactControl.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormInFactControl.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '�������Ͽ��� - ���';
      FTruckID := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '�������Ͽ��� - �޸�';
      FTruckID := nP.FParamA;
    end;

    LoadFormData(FTruckID); 
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormInFactControl.FormID: integer;
begin
  Result := cFI_FormInFactControl;
end;

procedure TfFormInFactControl.LoadFormData(const nID: string);
var nStr: string;
    nIdx: Integer;
begin
  LoadInFactStation(EditInFactStation.Properties.Items);
  EditStock.Properties.Items.Clear;
  nStr := 'Select D_ParamB, D_Value From %s where D_Name =''%s'' Union All Select M_ID, M_Name From %s  ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem, sTable_Materails]);

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

  nStr := 'Select * From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_InFactControl]);

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
    EditStock.Text := FieldByName('D_ParamC').AsString;
    SetCtrlData(EditInFactStation, FieldByName('D_Memo').AsString);
    EditStock.ItemIndex := EditStock.SelectedItem;
    CheckValid.Checked := FieldByName('D_ParamB').AsString = sFlag_Yes;
  end;
end;

//Desc: ����
procedure TfFormInFactControl.BtnOKClick(Sender: TObject);
var nStr,nCID,nV,nVTotal: string;
begin
  if Trim(EditInFactStation.Text) = '' then
  begin
    ActiveControl := EditInFactStation;
    ShowMsg('��ѡ�������', sHint);
    Exit;
  end;

  if Trim(EditStock.Text) = '' then
  begin
    ActiveControl := EditStock;
    ShowMsg('��ѡ������', sHint);
    Exit;
  end;

  if ChkUseControl.Checked then
       nVTotal := sFlag_Yes
  else nVTotal := sFlag_No;

  nStr := SF('D_Name', sFlag_InFactControl);
  nStr := MakeSQLByStr([
          SF('D_Name', sFlag_InFactControl),
          SF('D_Value', nVTotal)
          ], sTable_SysDict, nStr, False);

  if FDM.ExecuteSQL(nStr) <= 0 then
  begin
    nStr := MakeSQLByStr([
        SF('D_Name', sFlag_InFactControl),
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

  nStr := MakeSQLByStr([SF('D_Memo', GetCtrlData(EditInFactStation)),
          SF('D_ParamB', nV),
          SF('D_Value', gStockItems[EditStock.ItemIndex].FID),
          SF('D_Desc', gStockItems[EditStock.ItemIndex].FName),
          SF('D_Name', sFlag_InFactStock),
          SF('D_ParamC', EditStock.Text)
          ], sTable_SysDict, nStr, FTruckID = '');
  FDM.ExecuteSQL(nStr);

  ModalResult := mrOk;
  ShowMsg('ָ���������Ͽ�����Ϣ����ɹ�', sHint);
end;

procedure TfFormInFactControl.EditStockPropertiesChange(
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
  gControlManager.RegCtrl(TfFormInFactControl, TfFormInFactControl.FormID);
end.

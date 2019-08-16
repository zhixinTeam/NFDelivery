{*******************************************************************************
  ����: juner11212436@163.com 2019-05-21
  ����: ��Ӧ�̽���������������
*******************************************************************************}
unit UFormPTruckControl;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxCheckBox, cxSpinEdit, cxTimeEdit;

type
  TfFormPTruckControl = class(TfFormNormal)
    CheckValid: TcxCheckBox;
    dxLayout1Item4: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    ChkUseControl: TcxCheckBox;
    dxLayout1Item3: TdxLayoutItem;
    EditCus: TcxComboBox;
    dxLayout1Item5: TdxLayoutItem;
    EditMemo: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditStock: TcxComboBox;
    dxLayout1Item6: TdxLayoutItem;
    EditCount: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure EditCusPropertiesChange(Sender: TObject);
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
  //�ͻ��б�

class function TfFormPTruckControl.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormPTruckControl.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '��Ӧ�̽��������������� - ���';
      FTruckID := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '��Ӧ�̽��������������� - �޸�';
      FTruckID := nP.FParamA;
    end;

    LoadFormData(FTruckID); 
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormPTruckControl.FormID: integer;
begin
  Result := cFI_FormPTruckControl;
end;

procedure TfFormPTruckControl.LoadFormData(const nID: string);
var nStr: string;
    nIdx: Integer;
begin
  nStr := 'Select * From %s Where C_CusName=''%s''';
  nStr := Format(nStr, [sTable_PTruckControl, sFlag_PTruckControl]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      if FieldByName('C_Valid').AsString = sFlag_Yes then
        ChkUseControl.Checked := True;
    end;
  end;

  EditCus.Properties.Items.Clear;
  nStr := 'Select P_ID, P_Name From %s  ';
  nStr := Format(nStr, [sTable_Provider]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      SetLength(gCusItems, RecordCount);

      nIdx := 0;
      try
        EditCus.Properties.BeginUpdate;

        First;

        while not Eof do
        begin
          if (Fields[0].AsString = '') or (Fields[1].AsString = '') then
          begin
            Next;
            Continue;
          end;
          with gCusItems[nIdx] do
          begin
            FID := Fields[0].AsString;
            FName := Fields[1].AsString;
          end;

          Inc(nIdx);
          EditCus.Properties.Items.Add(Fields[1].AsString);
          Next;
        end;
      finally
        EditCus.Properties.EndUpdate;
      end;
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
    nStr := Format(nStr, [sTable_PTruckControl, nID]);
    FDM.QueryTemp(nStr);
  end;

  with FDM.SqlTemp do
  begin
    if (nID = '') or (RecordCount < 1) then
    begin
      CheckValid.Checked := True;
      Exit;
    end;

    EditCus.Text := FieldByName('C_CusName').AsString;
    EditCus.ItemIndex := EditCus.SelectedItem;
    EditStock.Text := FieldByName('C_StockName').AsString;
    EditStock.ItemIndex := EditStock.SelectedItem;
    EditMemo.Text := FieldByName('C_Memo').AsString;
    EditCount.Text := FieldByName('C_Count').AsString;
    CheckValid.Checked := FieldByName('C_Valid').AsString = sFlag_Yes;
  end;
end;

//Desc: ����
procedure TfFormPTruckControl.BtnOKClick(Sender: TObject);
var nStr,nCID,nV,nVTotal: string;
begin
  if Trim(EditCus.Text) = '' then
  begin
    ActiveControl := EditCus;
    ShowMsg('��ѡ��ͻ�', sHint);
    Exit;
  end;

  if Trim(EditStock.Text) = '' then
  begin
    ActiveControl := EditStock;
    ShowMsg('��ѡ��ԭ����', sHint);
    Exit;
  end;

  if not IsNumber(EditCount.Text, False) then
  begin
    ActiveControl := EditCount;
    ShowMsg('������Ϸ�����', sHint);
    Exit;
  end;

  if ChkUseControl.Checked then
       nVTotal := sFlag_Yes
  else nVTotal := sFlag_No;

  nStr := SF('C_CusName', sFlag_PTruckControl);
  nStr := MakeSQLByStr([
          SF('C_CusName', sFlag_PTruckControl),
          SF('C_Valid', nVTotal)
          ], sTable_PTruckControl, nStr, False);

  if FDM.ExecuteSQL(nStr) <= 0 then
  begin
    nStr := MakeSQLByStr([
        SF('C_CusName', sFlag_PTruckControl),
        SF('C_Valid', nVTotal)
        ], sTable_PTruckControl, '', True);
    FDM.ExecuteSQL(nStr);
  end;

  if CheckValid.Checked then
       nV := sFlag_Yes
  else nV := sFlag_No;

  if FTruckID = '' then
       nStr := ''
  else nStr := SF('R_ID', FTruckID, sfVal);

  nStr := MakeSQLByStr([SF('C_CusID', gCusItems[EditCus.ItemIndex].FID),
          SF('C_CusName', gCusItems[EditCus.ItemIndex].FName),
          SF('C_Valid', nV),
          SF('C_StockNo', gStockItems[EditStock.ItemIndex].FID),
          SF('C_StockName', gStockItems[EditStock.ItemIndex].FName),
          SF('C_Count', StrToInt(EditCount.Text), sfVal),
          SF('C_Memo', EditMemo.Text)
          ], sTable_PTruckControl, nStr, FTruckID = '');
  FDM.ExecuteSQL(nStr);

  ModalResult := mrOk;
  ShowMsg('��Ӧ�̽�����������������Ϣ����ɹ�', sHint);
end;

procedure TfFormPTruckControl.EditCusPropertiesChange(Sender: TObject);
var nIdx : Integer;
    nStr: string;
begin
  for nIdx := 0 to EditCus.Properties.Items.Count - 1 do
  begin;
    if Pos(EditCus.Text,EditCus.Properties.Items.Strings[nIdx]) > 0 then
    begin
      EditCus.SelectedItem := nIdx;
      Break;
    end;
  end;
end;

procedure TfFormPTruckControl.EditStockPropertiesChange(
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
  gControlManager.RegCtrl(TfFormPTruckControl, TfFormPTruckControl.FormID);
end.

{*******************************************************************************
  作者: fendou116688@163.com 2015-5-5
  描述: 矿点档案管理
*******************************************************************************}
unit UFormMine;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxCheckBox;

type
  TfFormMine = class(TfFormNormal)
    EditMine: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditOwner: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditPhone: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    dxGroup2: TdxLayoutGroup;
    cxCheckValid: TcxCheckBox;
    dxLayout1Item4: TdxLayoutItem;
    EditCusID: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditCusName: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditStock: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditStockName: TcxTextEdit;
    dxLayout1Item10: TdxLayoutItem;
    EditArea: TcxTextEdit;
    dxLayout1Item11: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure EditCusNameKeyPress(Sender: TObject; var Key: Char);
    procedure EditStockKeyPress(Sender: TObject; var Key: Char);
    procedure EditMineKeyPress(Sender: TObject; var Key: Char);
  protected
    { Protected declarations }
    FMineID: string;
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

class function TfFormMine.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormMine.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '矿点 - 添加';
      FMineID := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '矿点 - 修改';
      FMineID := nP.FParamA;
    end;

    LoadFormData(FMineID); 
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormMine.FormID: integer;
begin
  Result := cFI_FormMine;
end;

procedure TfFormMine.LoadFormData(const nID: string);
var nStr: string;
begin
  if nID <> '' then
  begin
    nStr := 'Select * From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_Mine, nID]);
    FDM.QueryTemp(nStr);
  end;

  with FDM.SqlTemp do
  begin
    if (nID = '') or (RecordCount < 1) then
      Exit;

    EditMine.Text        := FieldByName('M_Mine').AsString;
    EditOwner.Text       := FieldByName('M_Owner').AsString;
    EditPhone.Text       := FieldByName('M_Phone').AsString;

    EditStock.Text       := FieldByName('M_Stock').AsString;
    EditStockName.Text   := FieldByName('M_StockName').AsString;

    EditCusID.Text       := FieldByName('M_CusID').AsString;
    EditCusName.Text     := FieldByName('M_CusName').AsString;

    EditArea.Text        := FieldByName('M_Area').AsString;
    cxCheckValid.Checked := FieldByName('M_Valid').AsString <> sFlag_No;
  end;
end;

//Desc: 保存
procedure TfFormMine.BtnOKClick(Sender: TObject);
var nStr,nMine,nV,nPY: string;
begin
  nMine := UpperCase(Trim(EditMine.Text));
  if nMine = '' then
  begin
    ActiveControl := EditMine;
    ShowMsg('请输入矿点名称', sHint);
    Exit;
  end;
  nPY := GetPinYinOfStr(nMine);

  if cxCheckValid.Checked then
       nV := sFlag_Yes
  else nV := sFlag_No;

  if FMineID = '' then
       nStr := ''
  else nStr := SF('R_ID', FMineID, sfVal);

  nStr := MakeSQLByStr([SF('M_PY', nPY),
          SF('M_Mine', nMine),

          SF('M_Owner', Trim(EditOwner.Text)),
          SF('M_Phone', Trim(EditPhone.Text)),

          SF('M_Stock', Trim(EditStock.Text)),
          SF('M_StockName', Trim(EditStockName.Text)),

          SF('M_CusID', Trim(EditCusID.Text)),
          SF('M_CusName', Trim(EditCusName.Text)),

          SF('M_Area', Trim(EditArea.Text)),
          SF('M_Valid', nV)
          ], sTable_Mine, nStr, FMineID = '');
  FDM.ExecuteSQL(nStr);

  ModalResult := mrOk;
  ShowMsg('矿点信息保存成功', sHint);
end;

procedure TfFormMine.EditCusNameKeyPress(Sender: TObject; var Key: Char);
var nP: TFormCommandParam;
begin
  inherited;

  if Key = #13 then
  begin
    Key := #0;

    nP.FParamA := (Sender as TcxTextEdit).Text;
    CreateBaseFormItem(cFI_FormGetCustom, '', @nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

    EditCusID.Text := nP.FParamB;
    EditCusName.Text := nP.FParamC;
  end;
end;

procedure TfFormMine.EditStockKeyPress(Sender: TObject; var Key: Char);
var nP: TFormCommandParam;
begin
  inherited;

  if Key = #13 then
  begin
    Key := #0;

    nP.FParamA := '';
    CreateBaseFormItem(cFI_FormGetNCStock, '', @nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

    EditStock.Text := nP.FParamB;
    EditStockName.Text := nP.FParamC;
  end;
end;

procedure TfFormMine.EditMineKeyPress(Sender: TObject; var Key: Char);
var nP: TFormCommandParam;
begin
  inherited;

  if Key = #13 then
  begin
    Key := #0;

    nP.FParamA := '2';
    CreateBaseFormItem(cFI_FormGetNCStock, '', @nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

    EditCusID.Text := nP.FParamB;
    EditCusName.Text := nP.FParamC;
    EditMine.Text  := nP.FParamD;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormMine, TfFormMine.FormID);
end.

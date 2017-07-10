{*******************************************************************************
  ×÷Õß: fendou116688@163.com 2015/9/23
  ÃèÊö: Ìí¼Óºº×ÖÅçÂë
*******************************************************************************}
unit UFormChineseBase;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxCheckBox, cxButtonEdit;

type
  TfFormChineseBase = class(TfFormNormal)
    EditSource: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditPrintCode: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditValue: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    cxCheckValid: TcxCheckBox;
    dxLayout1Item4: TdxLayoutItem;
    EditMemo: TcxTextEdit;
    dxLayout1Item11: TdxLayoutItem;
    EditName: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure EditNamePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditNameKeyPress(Sender: TObject; var Key: Char);
  protected
    { Protected declarations }
    FChineseID: string;
    procedure GetAreaTo(nName: string='');
    procedure LoadFormData(const nID: string);
    function HaveSaved(nStr: string): Boolean;
    function GetPrintCodeOfStr(nStr: string): string;
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

class function TfFormChineseBase.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormChineseBase.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := 'ºº×ÖÅçÂë - Ìí¼Ó';
      FChineseID := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := 'ºº×ÖÅçÂë - ÐÞ¸Ä';
      FChineseID := nP.FParamA;
    end;

    LoadFormData(FChineseID);
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormChineseBase.FormID: integer;
begin
  Result := cFI_FormChineseBase;
end;

procedure TfFormChineseBase.LoadFormData(const nID: string);
var nStr: string;
begin
  if nID <> '' then
  begin
    nStr := 'Select * From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_ChineseBase, nID]);
    FDM.QueryTemp(nStr);
  end;

  with FDM.SqlTemp do
  begin
    if (nID = '') or (RecordCount < 1) then
      Exit;

    EditName.Text        := FieldByName('B_Name').AsString;
    EditValue.Text       := FieldByName('B_Value').AsString;
    EditSource.Text      := FieldByName('B_Source').AsString;

    EditMemo.Text        := FieldByName('B_Memo').AsString;
    EditPrintCode.Text   := FieldByName('B_PrintCode').AsString;
    cxCheckValid.Checked := FieldByName('B_Valid').AsString <> sFlag_No;
  end;
end;

function TfFormChineseBase.HaveSaved(nStr: string): Boolean;
var nSQL, nMsg: string;
begin
  Result := True;
  //init

  nSQL := 'Select B_Name From %s Where B_Source=''%s'' and B_Valid=''%s''';
  nSQL := Format(nSQL, [sTable_ChineseBase, nStr, sFlag_Yes]);

  with FDM.QuerySQL(nSQL) do
  begin
    if RecordCount>0 then
    begin
      nMsg := 'ÐÅÏ¢[%s]¶ÔÓ¦µÄÅçÂëÐÅÏ¢ÒÑ´æÔÚ£¬ÅçÂëÎª[%s]';
      nMsg := Format(nMsg, [nStr, Fields[0].AsString]);
      ShowDlg(nMsg, sHint);
      Exit;
    end;  
  end;

  Result := False;
end;

//------------------------------------------------------------------------------
//Date: 2015/10/9
//Parm: ºº×Ö×Ö·û´®
//Desc: »ñÈ¡ºº×Ö±àÂë
function TfFormChineseBase.GetPrintCodeOfStr(nStr: string): string;
var nSQL, nTmp, nStrTmp: string;
    nLen: Integer;
begin
  Result := '';
  //init

  nStrTmp := nStr;
  while Length(nStrTmp)>0 do
  begin
    if ByteType(nStrTmp, 1) = mbLeadByte then
         nLen := 2
    else nLen := 1;

    nTmp := Copy(nStrTmp, 1, nLen);
    System.Delete(nStrTmp, 1, nLen);

    if nLen = 2 then
    begin
      nSQL := 'Select D_Value From %s Where D_Name=''%s''';
      nSQL := Format(nSQL, [sTable_ChineseDict, nTmp]);

      nTmp := '';
      with FDM.QuerySQL(nSQL) do
      if RecordCount>0 then nTmp := Fields[0].AsString;
    end;

    Result := Result + nTmp;
  end;
end;  

//Desc: ±£´æ
procedure TfFormChineseBase.BtnOKClick(Sender: TObject);
var nStr,nName,nValue,nV,nPY,nPC: string;
begin
  nName := UpperCase(Trim(EditName.Text));
  nPY := GetPinYinOfStr(nName);

  if cxCheckValid.Checked then
       nV := sFlag_Yes
  else nV := sFlag_No;

  nValue := Trim(EditValue.Text);
  nPC    := GetPrintCodeOfStr(nValue);

  if (FChineseID = '') and HaveSaved(Trim(EditSource.Text)) then Exit;

  if FChineseID = '' then
       nStr := ''
  else nStr := SF('R_ID', FChineseID, sfVal);

  nStr := MakeSQLByStr([SF('B_PY', nPY),
          SF('B_Name', nName),
          SF('B_Value', nValue),
          SF('B_PrintCode', nPC),

          SF('B_Source', Trim(EditSource.Text)),
          SF('B_Memo', Trim(EditMemo.Text)),
          SF('B_Valid', nV)
          ], sTable_ChineseBase, nStr, FChineseID = '');
  FDM.ExecuteSQL(nStr);

  ModalResult := mrOk;
  ShowMsg('ºº×ÖÅçÂëÓ³Éä±£´æ³É¹¦', sHint);
end;

procedure TfFormChineseBase.GetAreaTo(nName: string);
var nP: TFormCommandParam;
begin
  nP.FParamA := nName;
  CreateBaseFormItem(cFI_FormGetAreaTo, '', @nP);
  if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

  EditName.Text := nP.FParamC;
  EditSource.Text := nP.FParamB;
end;

procedure TfFormChineseBase.EditNamePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  inherited;
  GetAreaTo(EditName.Text);
end;

procedure TfFormChineseBase.EditNameKeyPress(Sender: TObject;
  var Key: Char);
begin
  inherited;
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    GetAreaTo(EditName.Text);
  end;  
end;

initialization
  gControlManager.RegCtrl(TfFormChineseBase, TfFormChineseBase.FormID);
end.

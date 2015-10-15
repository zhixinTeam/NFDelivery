{*******************************************************************************
  ×÷Õß: fendou116688@163.com 2015/9/28
  ÃèÊö: ºº×Ö±àÂë×Öµä±í
*******************************************************************************}
unit UFormChineseDict;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxCheckBox;

type
  TfFormChineseDict = class(TfFormNormal)
    EditName: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditPrefix: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    cxCheckValid: TcxCheckBox;
    dxLayout1Item4: TdxLayoutItem;
    EditValue: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditMemo: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditCode: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure EditNamePropertiesChange(Sender: TObject);
  protected
    { Protected declarations }
    FChineseID: string;
    procedure LoadFormData(const nID: string);
    function HaveSaved(nStr: string): Boolean;
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

class function TfFormChineseDict.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormChineseDict.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := 'ÅçÂë×Öµä - Ìí¼Ó';
      FChineseID := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := 'ÅçÂë×Öµä - ÐÞ¸Ä';
      FChineseID := nP.FParamA;
    end;

    LoadFormData(FChineseID);
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormChineseDict.FormID: integer;
begin
  Result := cFI_FormChineseDict;
end;

procedure TfFormChineseDict.LoadFormData(const nID: string);
var nStr: string;
begin
  if nID <> '' then
  begin
    nStr := 'Select * From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_ChineseDict, nID]);
    FDM.QueryTemp(nStr);
  end;

  with FDM.SqlTemp do
  begin
    if (nID = '') or (RecordCount < 1) then
      Exit;

    EditName.Text        := FieldByName('D_Name').AsString;
    EditCode.Text        := FieldByName('D_Code').AsString;
    EditPrefix.Text      := FieldByName('D_Prefix').AsString;

    EditMemo.Text        := FieldByName('D_Memo').AsString;
    EditValue.Text       := FieldByName('D_Value').AsString;
    cxCheckValid.Checked := FieldByName('D_Valid').AsString <> sFlag_No;
  end;
end;

function TfFormChineseDict.HaveSaved(nStr: string): Boolean;
var nSQL, nMsg: string;
begin
  Result := True;
  //init

  nSQL := 'Select D_Code From %s Where D_Name=''%s'' and D_Valid=''%s''';
  nSQL := Format(nSQL, [sTable_ChineseDict, nStr, sFlag_Yes]);

  with FDM.QuerySQL(nSQL) do
  begin
    if RecordCount>0 then
    begin
      nMsg := 'ºº×Ö[%s]¶ÔÓ¦µÄ×ÖµäÒÑ´æÔÚ£¬±àÂëÎª[%s]';
      nMsg := Format(nMsg, [nStr, Fields[0].AsString]);
      ShowDlg(nMsg, sHint);
      Exit;
    end;  
  end;

  Result := False;
end;

//Desc: ±£´æ
procedure TfFormChineseDict.BtnOKClick(Sender: TObject);
var nStr,nName,nV,nPY: string;
begin
  nName := UpperCase(Trim(EditName.Text));
  if nName = '' then
  begin
    ActiveControl := EditName;
    ShowMsg('ÇëÊäÈëºº×Ö', sHint);
    Exit;
  end;
  nPY := GetPinYinOfStr(nName);

  if cxCheckValid.Checked then
       nV := sFlag_Yes
  else nV := sFlag_No;

  if (FChineseID = '') and HaveSaved(nName) then Exit;

  if FChineseID = '' then
       nStr := ''
  else nStr := SF('R_ID', FChineseID, sfVal);

  nStr := MakeSQLByStr([SF('D_PY', nPY),
          SF('D_Name', nName),

          SF('D_Prefix', Trim(EditPrefix.Text)),
          SF('D_Code', Trim(EditCode.Text)),

          SF('D_Value', Trim(EditValue.Text)),
          SF('D_Memo', Trim(EditMemo.Text)),
          SF('D_Valid', nV)
          ], sTable_ChineseDict, nStr, FChineseID = '');
  FDM.ExecuteSQL(nStr);

  ModalResult := mrOk;
  ShowMsg('ºº×Ö×Öµä¿â±£´æ³É¹¦', sHint);
end;

procedure TfFormChineseDict.EditNamePropertiesChange(Sender: TObject);
var nName, nCode: string;
begin
  inherited;
  nName := Trim(EditName.Text);
  if nName='' then Exit;

  if ByteType(nName, 1)=mbLeadByte then
       nCode := Trim(EditPrefix.Text) + Trim(EditCode.Text)
  else nCode := nName;

  EditValue.Text := nCode;
end;

initialization
  gControlManager.RegCtrl(TfFormChineseDict, TfFormChineseDict.FormID);
end.

{*******************************************************************************
  作者: dmzn@163.com 2014-12-01
  描述: 微信账户
*******************************************************************************}
unit UFormWeiXinAccount;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  CPort, CPortTypes, UFormNormal, UFormBase, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, cxTextEdit,
  dxLayoutControl, StdCtrls, cxGraphics, cxCheckBox;

type
  TfFormWXAccount = class(TfFormNormal)
    EditName: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditMemo: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    Check1: TcxCheckBox;
    dxLayout1Item5: TdxLayoutItem;
    EditCusID: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    Check2: TcxCheckBox;
    dxLayout1Item7: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure EditNameKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FAccount: string;
    procedure InitFormData;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormCtrl, USysBusiness, USysDB, USysConst,
  UBusinessConst;

class function TfFormWXAccount.FormID: integer;
begin
  Result := cFI_FormWXAccount;
end;

class function TfFormWXAccount.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormWXAccount.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
         Caption := '微信 - 添加'
    else Caption := '微信 - 修改';

    FAccount := nP.FParamA;
    InitFormData();

    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

procedure TfFormWXAccount.InitFormData;
var nStr: string;
begin
  if FAccount = '' then
  begin
    Check1.Checked := True;
    Check2.Checked := True;
  end else
  begin
    nStr := 'Select * from %s Where M_ID=''%s''';
    nStr := Format(nStr, [sTable_WeixinMatch, FAccount]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
      begin
        ShowMsg('账户已丢失', sHint);
        Exit;
      end;

      EditName.Text := FieldByName('M_WXName').AsString;
      EditMemo.Text := FieldByName('M_Comment').AsString;
      Check1.Checked := FieldByName('M_IsValid').AsString = sFlag_Yes;
    end;
  end;
end;

procedure TfFormWXAccount.BtnOKClick(Sender: TObject);
var nID,nFlag,nSQL, nType: string;
    nItem: TWeiXinAccount;
begin
  EditName.Text := Trim(EditName.Text);
  if EditName.Text = '' then
  begin
    ActiveControl := EditName;
    ShowMsg('请输入账户名称', sHint); Exit;
  end;

  if Check1.Checked then
       nFlag := sFlag_Yes
  else nFlag := sFlag_No;

  if Check2.Checked then
       nType := sFlag_AttentionCust
  else nType := sFlag_AttentionAdmin;

  with nItem do
  begin
    FID := FAccount;

    FWXName := EditName.Text;
    FComment:= EditMemo.Text;


    FAttention := EditCusID.Text;
    FAttenType := nType;

    FIsValid:= nFlag;
    FWXFact := gSysParam.FFactNum;
  end;

  if (not SaveWeiXinAccount(nItem, nID)) or (nID='') then Exit;
  if FAccount = '' then
  begin
    nSQL := MakeSQLByStr([SF('M_ID', nID),
            SF('M_WXName', EditName.Text),
            SF('M_Comment', EditMemo.Text),
            SF('M_IsValid', nFlag)], sTable_WeixinMatch, '', True);
    //xxxxx
  end else
  begin

    nSQL := MakeSQLByStr([SF('M_WXName', EditName.Text),
            SF('M_Comment', EditMemo.Text),
            SF('M_IsValid', nFlag)
            ], sTable_WeixinMatch, SF('M_ID', FAccount), False);
    //xxxxx
  end;

  FDM.ExecuteSQL(nSQL);
  ModalResult := mrOk;
  ShowMsg('保存成功', sHint);
end;

procedure TfFormWXAccount.EditNameKeyPress(Sender: TObject; var Key: Char);
var nP: TFormCommandParam;
begin
  inherited;
  if Key = #13 then
  begin
    Key := #0;
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    nP.FParamA := EditName.Text;
    CreateBaseFormItem(cFI_FormGetCustom, '', @nP);
    if (nP.FCommand=cCmd_ModalResult) and (nP.FParamA=mrOK) then
    begin
      EditCusID.Text := nP.FParamB;
      EditName.Text  := nP.FParamC;
    end;  
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormWXAccount, TfFormWXAccount.FormID);
end.

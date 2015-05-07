unit UFormTemplate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, UDataModule, ULibFun, USysLoger, ADODB;

type
  TfFormTemplate = class(TForm)
    mmoTemplate: TMemo;
    BtnCreate: TButton;
    BtnDel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    edtID: TEdit;
    BtnExit: TButton;
    edtType: TEdit;
    Label3: TLabel;
    edtComment: TEdit;
    procedure BtnCreateClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
  private
    { Private declarations }
    FHint :string;
  public
    { Public declarations }
  end;
var
  fFormTemplate: TfFormTemplate;

function ShowTemplateForm(nFlag: Boolean = True): Boolean;
implementation

uses
  UMgrWeixin;

{$R *.dfm}

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFormTemplate, '微信模板消息管理', nEvent);
end;

//Desc:

function ShowTemplateForm(nFlag: Boolean = True): Boolean;
begin
  with TfFormTemplate.Create(Application) do
  begin
    if nFlag then
    begin
      Height := 428;
      Caption := '添加模板';
      BtnDel.Visible := False;
    end  else
    begin
      Height := 200;
      Caption := '删除模板';
      BtnDel.Left := BtnCreate.Left;
      BtnCreate.Visible := False;
    end;
    FHint := '';
    Result := ShowModal = mrOk;
    Free
  end;
end;

procedure TfFormTemplate.BtnCreateClick(Sender: TObject);
begin
  gWXMessgeMgr.WXSaveTemplate(edtID.Text, edtType.Text, mmoTemplate.Text,
                              edtComment.Text);
  ModalResult := mrOK;
end;

procedure TfFormTemplate.BtnDelClick(Sender: TObject);
begin
  gWXMessgeMgr.WXDeleteTemplate(edtID.Text, edtType.Text);
  ModalResult := mrOK;
end;

procedure TfFormTemplate.BtnExitClick(Sender: TObject);
begin
  Close;
end;
end.


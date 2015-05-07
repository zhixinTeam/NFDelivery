unit UFormSetAppData;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfFormSetApp = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    edtAppID: TEdit;
    edtAppSecret: TEdit;
    BtnOK: TButton;
    BtnCancel: TButton;
    Label3: TLabel;
    edtAppToken: TEdit;
    procedure BtnOKClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fFormSetApp: TfFormSetApp;

function ShowSetAppForm: Boolean;
//入口函数
implementation
uses UMgrWeixin;

{$R *.dfm}

//Desc:
function ShowSetAppForm: Boolean;
begin
  with TfFormSetApp.Create(Application) do
  begin
    Caption := '微信参数设置';
    edtAppID.Text := gWXMessgeMgr.appid;
    edtAppToken.Text := gWXMessgeMgr.apptoken;
    edtAppSecret.Text := gWXMessgeMgr.appsecret;

    Result := ShowModal = mrOk;
    Free
  end;
end;

procedure TfFormSetApp.BtnOKClick(Sender: TObject);
begin
  gWXMessgeMgr.appid    := edtAppID.Text;
  gWXMessgeMgr.apptoken := edtAppToken.Text;
  gWXMessgeMgr.appsecret:= edtAppSecret.Text;

  ModalResult := mrOk;
end;

procedure TfFormSetApp.BtnCancelClick(Sender: TObject);
begin
  Close;
end;
   
end.

unit uFormGetWechartAccount;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, dxLayoutcxEditAdapters,
  cxContainer, cxEdit, ComCtrls, cxListView, cxLabel, cxTextEdit;

type
  //�ͻ�ע����Ϣ
  PWechartCustomerInfo = ^TWechartCustomerInfo;
  TWechartCustomerInfo = record
    FBindcustomerid:string;//�󶨿ͻ�id  
    FNamepinyin:string;//��¼�˺�
    FEmail:string;//����
    Fphone:string;//�ֻ�����
  end;

  TfFormGetWechartAccount = class(TfFormNormal)
    edtinput: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item4: TdxLayoutItem;
    ListQuery: TcxListView;
    dxLayout1Item5: TdxLayoutItem;
    procedure edtinputKeyPress(Sender: TObject; var Key: Char);
    procedure BtnOKClick(Sender: TObject);
    procedure ListQueryDblClick(Sender: TObject);
    procedure edtinputPropertiesChange(Sender: TObject);
  private
    { Private declarations }
    //΢��ע���û���Ϣ�б�
    FCustomerInfos:TList;
    FSelectedStr:string;
    FNamepinyin:string;
    //��ѯ����
    procedure GetResult;
    procedure FilterFunc(const nInputStr:string);
    function DownloadAllCustomerInfos:Boolean;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation
uses
  Contnrs,UFormBase,USysConst,UBusinessPacker,ULibFun,UMgrControl,USysBusiness;
{$R *.dfm}

{ TfFormNormal1 }

class function TfFormGetWechartAccount.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormGetWechartAccount.Create(Application) do
  try
    FCustomerInfos := TList.Create;
    FSelectedStr := '';
    FNamepinyin := '';
    Caption := 'ѡ���˺�';

    nP.FCommand := cCmd_ModalResult;

    DownloadAllCustomerInfos;
    
    nP.FParamA := ShowModal;

    if nP.FParamA = mrOK then
    begin
      nP.FParamB := FSelectedStr;
      nP.FParamC := FNamepinyin;
    end;
  finally
    FCustomerInfos.Clear;
    FCustomerInfos.Free;
    Free;
  end;
end;

class function TfFormGetWechartAccount.FormID: integer;
begin
  Result := cFI_FormGetWechartAccount;
end;

procedure TfFormGetWechartAccount.edtinputKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    if ListQuery.Items.Count=1 then
    begin
      ListQuery.ItemIndex := 0;
      GetResult;
      ModalResult := mrOk;
    end;
  end
  else begin
    FilterFunc(edtinput.Text);
  end;
end;

procedure TfFormGetWechartAccount.GetResult;
begin
  with ListQuery.Selected do
  begin
    FSelectedStr := SubItems[2];
    FNamepinyin := Caption;
  end;
end;

procedure TfFormGetWechartAccount.FilterFunc(const nInputStr: string);
var
  i:Integer;
  nRec:PWechartCustomerInfo;
begin
  ListQuery.Clear;
  if nInputStr='' then
  begin
    for i := 0 to FCustomerInfos.Count-1 do
    begin
      nRec := PWechartCustomerInfo(FCustomerInfos.Items[i]);
      with ListQuery.Items.Add do
      begin
        Caption := nRec.FNamepinyin;
        SubItems.Add(nRec.FEmail);
        SubItems.Add(nRec.Fphone);
        SubItems.Add(nRec.FBindcustomerid);
        ImageIndex := cItemIconIndex;
      end;
    end;
  end
  else begin
    for i := 0 to FCustomerInfos.Count-1 do
    begin
      nRec := PWechartCustomerInfo(FCustomerInfos.Items[i]);
      if (LowerCase(nInputStr)=LowerCase(nRec.FNamepinyin))
        or (LowerCase(nInputStr)=LowerCase(nrec.Fphone))
        or (Pos(LowerCase(nInputStr),LowerCase(nRec.FNamepinyin))>0)
        or (Pos(LowerCase(nInputStr),LowerCase(nrec.Fphone))>0) then
      begin
        with ListQuery.Items.Add do
        begin
          Caption := nRec.FNamepinyin;
          SubItems.Add(nRec.FEmail);
          SubItems.Add(nRec.Fphone);
          SubItems.Add(nRec.FBindcustomerid);
          ImageIndex := cItemIconIndex;
        end;
      end;
    end;  
  end;
end;

function TfFormGetWechartAccount.DownloadAllCustomerInfos: Boolean;
var
  nData:string;
  i:Integer;
  nList,nListsub:TStrings;
  nRec:PWechartCustomerInfo;
begin
  Result := False;
  nData := WebChatGetCustomerInfo;
  if nData='' then
  begin
    ShowMsg('δ��ѯ����ǰ������ע���û���Ϣ', sHint);
    Exit;
  end;

  //�����ͻ�ע����Ϣ
  nData := PackerDecodeStr(nData);
  nList := TStringList.Create;
  nListsub := TStringList.Create;
  try
    nList.Text := nData;
    for i := 0 to nList.Count-1 do
    begin
      New(nRec);
      nListsub.CommaText := nList.Strings[i];
      nRec.Fphone := nListsub.Values['phone'];
      nRec.FBindcustomerid := nListsub.Values['Bindcustomerid'];
      nRec.FNamepinyin := nListsub.Values['Namepinyin'];
      nRec.FEmail := nListsub.Values['Email'];
      FCustomerInfos.Add(nRec);
    end;
    FilterFunc('');
  finally
    nListsub.Free;
    nList.Free;
  end;
end;

procedure TfFormGetWechartAccount.BtnOKClick(Sender: TObject);
begin
  if ListQuery.ItemIndex > -1 then
  begin
    GetResult;
    ModalResult := mrOk;
  end else ShowMsg('���ڲ�ѯ�����ѡ��', sHint);
end;

procedure TfFormGetWechartAccount.ListQueryDblClick(Sender: TObject);
begin
  BtnOK.Click;
end;

procedure TfFormGetWechartAccount.edtinputPropertiesChange(
  Sender: TObject);
begin
  FilterFunc(edtinput.Text);
end;

initialization
  gControlManager.RegCtrl(TfFormGetWechartAccount, TfFormGetWechartAccount.FormID);

end.

{*******************************************************************************
  ����: fendou116688@163.com 2017/6/22
  ����: ��ȡ�Զ��嵵��
*******************************************************************************}
unit UFormGetAreaTo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxContainer, cxEdit, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, dxLayoutControl, StdCtrls, cxControls,
  ComCtrls, cxListView, cxButtonEdit, cxLabel, cxLookAndFeels,
  cxLookAndFeelPainters;

type
  TfFormGetAreaTo = class(TfFormNormal)
    EditCus: TcxButtonEdit;
    dxLayout1Item5: TdxLayoutItem;
    ListCustom: TcxListView;
    dxLayout1Item6: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item7: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure ListCustomKeyPress(Sender: TObject; var Key: Char);
    procedure EditCIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure ListCustomDblClick(Sender: TObject);
  private
    { Private declarations }
    FID,FName,FCode: string;
    //����������Ϣ
    procedure InitFormData(const nID: string);
    //��ʼ������
    function QueryAreaTo(const nType: Byte): Boolean;
    //��ѯ��������
    procedure GetResult;
    //��ȡ���
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}

uses
  IniFiles, ULibFun, UMgrControl, UAdjustForm, UFormCtrl, UFormBase, USysGrid,
  USysDB, USysConst, USysBusiness, UDataModule;

class function TfFormGetAreaTo.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormGetAreaTo.Create(Application) do
  begin
    Caption := 'ѡ����������';
    InitFormData(nP.FParamA);

    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;

    if nP.FParamA = mrOK then
    begin
      nP.FParamB := FID;
      nP.FParamC := FName;
      nP.FParamD := FCode;
    end;
    Free;
  end;
end;

class function TfFormGetAreaTo.FormID: integer;
begin
  Result := cFI_FormGetAreaTo;
end;

procedure TfFormGetAreaTo.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadcxListViewConfig(Name, ListCustom, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormGetAreaTo.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SavecxListViewConfig(Name, ListCustom, nIni);
  finally
    nIni.Free;
  end;

  ReleaseCtrlData(Self);
end;

//------------------------------------------------------------------------------
//Desc: ��ʼ����������
procedure TfFormGetAreaTo.InitFormData(const nID: string);
begin
  if nID <> '' then
  begin
    EditCus.Text := nID;
    if QueryAreaTo(10) then ActiveControl := ListCustom;
  end else ActiveControl := EditCus;
end;

//Date: 2010-3-9
//Parm: ��ѯ����(10: ������)
//Desc: ��ָ�����Ͳ�ѯ��ͬ
function TfFormGetAreaTo.QueryAreaTo(const nType: Byte): Boolean;
var nStr: string;
begin
  Result := False;
  EditCus.Text := Trim(EditCus.Text);
  if EditCus.Text = '' then Exit;

  nStr := 'Select * From bd_defdoc Where dr=0 and ' +
          'doccode like ''%%%s%%'' or docname like ''%%%s%%''';
  nStr := Format(nStr, [Trim(EditCus.Text), Trim(EditCus.Text)]);

  ListCustom.Items.Clear;
  with FDM.QueryTemp(nStr, True) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    with ListCustom.Items.Add do
    begin
      Caption := FieldByName('pk_defdoc').AsString;
      SubItems.Add(FieldByName('docname').AsString);
      SubItems.Add(FieldByName('doccode').AsString);

      ImageIndex := cItemIconIndex;
      Next;
    end;

    ListCustom.ItemIndex := 0;
    Result := True;
  end;
end;

procedure TfFormGetAreaTo.EditCIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  EditCus.Text := Trim(EditCus.Text);
  if (EditCus.Text <> '') and QueryAreaTo(10) then ListCustom.SetFocus;
end;

//Desc: ��ȡ���
procedure TfFormGetAreaTo.GetResult;
begin
  with ListCustom.Selected do
  begin
    FID := Caption;
    FName := SubItems[0];
    FCode := SubItems[1];
  end;
end;

procedure TfFormGetAreaTo.ListCustomKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    if ListCustom.ItemIndex > -1 then
    begin
      GetResult;
      ModalResult := mrOk;
    end;
  end;
end;

procedure TfFormGetAreaTo.ListCustomDblClick(Sender: TObject);
begin
  if ListCustom.ItemIndex > -1 then
  begin
    GetResult;
    ModalResult := mrOk;
  end;
end;

procedure TfFormGetAreaTo.BtnOKClick(Sender: TObject);
begin
  if ListCustom.ItemIndex > -1 then
  begin
    GetResult;
    ModalResult := mrOk;
  end else ShowMsg('���ڲ�ѯ�����ѡ��', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormGetAreaTo, TfFormGetAreaTo.FormID);
end.

{*******************************************************************************
  ����: dmzn@163.com 2009-7-2
  ����: ��Ӧ��
*******************************************************************************}
unit UFramePProvider;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, dxLayoutControl, cxMaskEdit,
  cxButtonEdit, cxTextEdit, ADODB, cxContainer, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsDefaultPainters, Menus;

type
  TfFrameProvider = class(TfFrameNormal)
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    procedure EditNamePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
  private
    { Private declarations }
  protected
    function InitFormDataSQL(const nWhere: string): string; override;
    {*��ѯSQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysDB, UDataModule, UFormBase, USysBusiness;

class function TfFrameProvider.FrameID: integer;
begin
  Result := cFI_FrameProvider;
end;

function TfFrameProvider.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select * From ' + sTable_Provider;
  if nWhere <> '' then
    Result := Result + ' Where (' + nWhere + ')';
  Result := Result + ' Order By P_Name';
end;

//Desc: ���
procedure TfFrameProvider.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormProvider, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: �޸�
procedure TfFrameProvider.BtnEditClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nP.FCommand := cCmd_EditData;
    nP.FParamA := SQLQuery.FieldByName('P_ID').AsString;
    CreateBaseFormItem(cFI_FormProvider, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;
  end;
end;

//Desc: ɾ��
procedure TfFrameProvider.BtnDelClick(Sender: TObject);
var nStr: string;
    nList: TStrings;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('P_Name').AsString;
    nStr := Format('ȷ��Ҫɾ����Ӧ��[ %s ]��?', [nStr]);
    if not QueryDlg(nStr, sAsk) then Exit;

    nList := TStringList.Create;
    //init

    if SQLQuery.FieldByName('P_WeiXin').AsString <> '' then
    try
      nList.Values['Type']     := 'del';
      nList.Values['WebProID'] := SQLQuery.FieldByName('P_WeiXin').AsString;
      if not WebChatEditShopCustom(nList.Text, sFlag_No) then Exit;
    finally
      nList.Free;
    end;

    nStr := 'Delete From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_Provider, SQLQuery.FieldByName('R_ID').AsString]);

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
  end;
end;

//Desc: ��ѯ
procedure TfFrameProvider.EditNamePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := Format('P_Name Like ''%%%s%%''', [EditName.Text]);
    InitFormData(FWhere);
  end;
end;

procedure TfFrameProvider.N1Click(Sender: TObject);
var nP: TFormCommandParam;
    nList: TStrings;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�����ļ�¼', sHint);
    Exit;
  end;

  nList := TStringList.Create;
  try
    nList.Clear;

    nList.Values['DLPID'] := SQLQuery.FieldByName('P_ID').AsString;
    nList.Values['DLPName'] := SQLQuery.FieldByName('P_Name').AsString;

    case TMenuItem(Sender).Tag of
    4: //�����̳��˺�
    begin
      nP.FCommand := cCmd_AddData;
      CreateBaseFormItem(cFI_FormGetWechartAccount, PopedomItem, @nP);

      if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
      begin
        nList.Values['Type']     := 'add';
        nList.Values['WebProID'] := nP.FParamB;
        nList.Values['WebUserName'] := nP.FParamC;

        if not WebChatEditShopCustom(nList.Text, sFlag_No) then Exit;

        ShowMsg('�����̳��˺ųɹ�', sHint);
      end;
    end;
    5: //ȡ�������˺�
    begin
      nList.Values['Type']     := 'del';
      nList.Values['WebProID'] := SQLQuery.FieldByName('P_WeiXin').AsString;

      if not WebChatEditShopCustom(nList.Text, sFlag_No) then Exit;

      ShowMsg('����̳��˺ųɹ�', sHint);
    end;
    end
  finally
    InitFormData;
    nList.Free;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameProvider, TfFrameProvider.FrameID);
end.

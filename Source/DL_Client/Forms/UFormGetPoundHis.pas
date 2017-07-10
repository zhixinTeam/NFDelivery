{*******************************************************************************
  作者: fendou116688@163.com 2017/6/22
  描述: 获取历史磅单信息
*******************************************************************************}
unit UFormGetPoundHis;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxContainer, cxEdit, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, dxLayoutControl, StdCtrls, cxControls,
  ComCtrls, cxListView, cxButtonEdit, cxLabel, cxLookAndFeels,
  cxLookAndFeelPainters;

type
  TfFormGetPoundHis = class(TfFormNormal)
    EditID: TcxButtonEdit;
    dxLayout1Item5: TdxLayoutItem;
    ListPoundHis: TcxListView;
    dxLayout1Item6: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item7: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure ListPoundHisKeyPress(Sender: TObject; var Key: Char);
    procedure EditCIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure ListPoundHisDblClick(Sender: TObject);
  private
    { Private declarations }
    FListA: TStrings;
    //保存临时信息
    FOrderInfo: string;
    //订单信息
    procedure InitFormData(const nID: string; nType: Integer=0);
    //初始化数据
    function QueryAreaTo(const nType: Byte): Boolean;
    //查询区域流向
    procedure GetResult;
    //获取结果
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

class function TfFormGetPoundHis.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormGetPoundHis.Create(Application) do
  begin
    Caption := '选择已出厂磅单';
    InitFormData(nP.FParamA, nP.FCommand);

    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;

    if nP.FParamA = mrOK then
    begin
      nP.FParamB := FOrderInfo;
    end;
    Free;
  end;
end;

class function TfFormGetPoundHis.FormID: integer;
begin
  Result := cFI_FormGetPoundHis;
end;

procedure TfFormGetPoundHis.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadcxListViewConfig(Name, ListPoundHis, nIni);
  finally
    nIni.Free;
  end;

  FOrderInfo := '';
  FListA := TStringList.Create;
end;

procedure TfFormGetPoundHis.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SavecxListViewConfig(Name, ListPoundHis, nIni);
  finally
    nIni.Free;
  end;

  FListA.Free;
  ReleaseCtrlData(Self);
end;

//------------------------------------------------------------------------------
//Desc: 初始化界面数据
procedure TfFormGetPoundHis.InitFormData(const nID: string; nType: Integer=0);
begin
  if nID <> '' then
  begin
    EditID.Text := nID;
    if QueryAreaTo(nType) then ActiveControl := ListPoundHis;
  end else ActiveControl := EditID;
end;

//Date: 2010-3-9
//Parm: 查询类型(10: 按名称)
//Desc: 按指定类型查询合同
function TfFormGetPoundHis.QueryAreaTo(const nType: Byte): Boolean;
var nStr: string;
begin
  Result := False;
  FOrderInfo := '';
  EditID.Text := Trim(EditID.Text);
  if EditID.Text = '' then Exit;

  ListPoundHis.Items.Clear;

  if nType = 0 then
  begin //车牌号查询近2天信息
    nStr := 'Select * From $Bill Where L_OutFact >= $Date - 1 And ' +
            'L_Truck=''$ID'' Order By L_ID Desc';
  end else

  if nType = 1 then
  begin
    if Length(EditID.Text) <= 3 then
    begin
      nStr := 'Select * From $Bill Where L_OutFact >= $Date - 1 And ' +
              'L_ID Like ''%%$ID%%''';
    end else

    begin
      nStr := 'Select * From $Bill Where L_ID Like ''%%$ID%%'' And ' +
              'L_OutFact Is Not NULL  Order By L_ID Desc';
    end;
  end;

  nStr := MacroValue(nStr, [MI('$Bill', sTable_Bill),
          MI('$Date', sField_SQLServer_Now),
          MI('$ID', EditID.Text)]);

  if nStr = '' then Exit;

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    with ListPoundHis.Items.Add do
    begin
      Caption := FieldByName('L_ID').AsString;
      SubItems.Add(FieldByName('L_CusName').AsString);
      SubItems.Add(FieldByName('L_StockName').AsString);
      SubItems.Add(Format('%.2f', [FieldByName('L_Value').AsFloat]));
      SubItems.Add(FieldByName('L_Truck').AsString);

      ImageIndex := cItemIconIndex;
      Next;
    end;

    ListPoundHis.ItemIndex := 0;
    Result := True;
  end;
end;

procedure TfFormGetPoundHis.EditCIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  EditID.Text := Trim(EditID.Text);
  if (EditID.Text <> '') and QueryAreaTo(1) then ListPoundHis.SetFocus;
end;

//Desc: 获取结果
procedure TfFormGetPoundHis.GetResult;
begin

  with ListPoundHis.Selected do
  begin
    FListA.Clear;

    FListA.Values['BillNO'] := Caption;
    FListA.Values['CusName'] := SubItems[0];
    FListA.Values['Stock']   := SubItems[1];
    FListA.Values['Value']   := SubItems[2];
    FListA.Values['Truck']   := SubItems[3];

    FOrderInfo := FListA.Text;
  end;
end;

procedure TfFormGetPoundHis.ListPoundHisKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    if ListPoundHis.ItemIndex > -1 then
    begin
      GetResult;
      ModalResult := mrOk;
    end;
  end;
end;

procedure TfFormGetPoundHis.ListPoundHisDblClick(Sender: TObject);
begin
  if ListPoundHis.ItemIndex > -1 then
  begin
    GetResult;
    ModalResult := mrOk;
  end;
end;

procedure TfFormGetPoundHis.BtnOKClick(Sender: TObject);
begin
  if ListPoundHis.ItemIndex > -1 then
  begin
    GetResult;
    ModalResult := mrOk;
  end else ShowMsg('请在查询结果中选择', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormGetPoundHis, TfFormGetPoundHis.FormID);
end.

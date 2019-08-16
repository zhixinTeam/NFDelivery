{*******************************************************************************
  作者: juner11212436@163.com 2019-04-26
  描述: 选择手工录入批次号
*******************************************************************************}
unit UFormGetBatCode;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ComCtrls, cxCheckBox, Menus,
  cxLabel, cxListView, cxTextEdit, cxMaskEdit, cxButtonEdit,
  dxLayoutControl, StdCtrls;

type
  TfFormGetBatCode = class(TfFormNormal)
    ListBatCode: TcxListView;
    dxLayout1Item6: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure ListBatCodeKeyPress(Sender: TObject; var Key: Char);
    procedure ListBatCodeDblClick(Sender: TObject);
  private
    { Private declarations }
    FStockNo: string;
    function QueryBatCode(const nStockNo: string): Boolean;
    //查询车辆
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}

uses
  IniFiles, ULibFun, UMgrControl, UFormBase, USysGrid, USysDB, USysConst,
  USysBusiness, UDataModule, UFormInputbox;

class function TfFormGetBatCode.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormGetBatCode.Create(Application) do
  begin
    Caption := '选择批次';

    FStockNo := nP.FParamA;
    QueryBatCode(FStockNo);

    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;

    if nP.FParamA = mrOK then
      nP.FParamB := ListBatCode.Items[ListBatCode.ItemIndex].Caption;
    Free;
  end;
end;

class function TfFormGetBatCode.FormID: integer;
begin
  Result := cFI_FormGetBatCode;
end;

procedure TfFormGetBatCode.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadcxListViewConfig(Name, ListBatCode, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormGetBatCode.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SavecxListViewConfig(Name, ListBatCode, nIni);
  finally
    nIni.Free;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 查询批次
function TfFormGetBatCode.QueryBatCode(const nStockNo: string): Boolean;
var nStr, nType: string;
begin
  Result := False;
  ListBatCode.Items.Clear;

  nStr := 'Select * from %s Where D_Stock=''%s'' and D_Valid=''%s'' '+
          'Order By D_UseDate';
  nStr := Format(nStr, [sTable_BatcodeDoc, nStockNo, sFlag_BatchInUse]);
  //xxxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      with ListBatCode.Items.Add do
      begin
        Caption := FieldByName('D_ID').AsString;
        SubItems.Add(FieldByName('D_Name').AsString);

        ImageIndex := 11;
        StateIndex := ImageIndex;
      end;

      Next;
    end;
  end;

  Result := ListBatCode.Items.Count > 0;
  if Result then
  begin
    ActiveControl := ListBatCode;
    ListBatCode.ItemIndex := 0;
    ListBatCode.ItemFocused := ListBatCode.TopItem;
  end;
end;


procedure TfFormGetBatCode.ListBatCodeKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;

    if ListBatCode.ItemIndex > -1 then
      ModalResult := mrOk;
    //xxxxx
  end;
end;

procedure TfFormGetBatCode.ListBatCodeDblClick(Sender: TObject);
begin
  if ListBatCode.ItemIndex > -1 then
    ModalResult := mrOk;
  //xxxxx
end;

procedure TfFormGetBatCode.BtnOKClick(Sender: TObject);
begin
  if ListBatCode.ItemIndex > -1 then
       ModalResult := mrOk
  else ShowMsg('请在查询结果中选择', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormGetBatCode, TfFormGetBatCode.FormID);
end.

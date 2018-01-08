{*******************************************************************************
  作者: 289525016@163.com 2017-08-14
  描述: 选择物料
*******************************************************************************}
unit UFormGetStock;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ComCtrls, cxCheckBox, Menus,
  cxLabel, cxListView, cxTextEdit, cxMaskEdit, cxButtonEdit,
  dxLayoutControl, StdCtrls;

type
  TfFormGetStock = class(TfFormNormal)
    ListStock: TcxListView;
    dxLayout1Item6: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure ListStockKeyPress(Sender: TObject; var Key: Char);
    procedure ListStockDblClick(Sender: TObject);
  private
    { Private declarations }
    FType:string;
    function QueryStock: Boolean;
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

class function TfFormGetStock.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormGetStock.Create(Application) do
  begin
    Caption := '选择品种';

    FType := nP.FParamA;

    QueryStock;

    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;

    if nP.FParamA = mrOK then
    begin
      nP.FParamB := ListStock.Items[ListStock.ItemIndex].Caption;
      nP.FParamC := ListStock.Items[ListStock.ItemIndex].SubItems.Strings[0];
    end;
    Free;
  end;
end;

class function TfFormGetStock.FormID: integer;
begin
  Result := cFI_FormGetStock;
end;

//------------------------------------------------------------------------------
//Desc: 查询车牌号
function TfFormGetStock.QueryStock: Boolean;
var nStr, nType: string;
begin
  Result := False;
  ListStock.Items.Clear;

  if FType=sFlag_Provide then
  begin
    nStr := 'select distinct p_mid as id,p_mname as name from %s  order by p_mid';
    nStr := Format(nStr,[sTable_CardProvide]);
  end
  else if FType=sFlag_Sale then
  begin
    nStr := 'select d_paramB as id,d_value as name from %s where d_name=''%s'' order by d_paramB';
    nStr := Format(nStr,[sTable_SysDict,sFlag_StockItem]);
  end
  else if FType=sFlag_Other then
  begin
    nStr := 'select distinct o_mid as id,o_mname as name from %s order by o_mid';
    nStr := Format(nStr,[sTable_CardOther]);
  end;
  
  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      with ListStock.Items.Add do
      begin
        Caption := FieldByName('id').AsString;
        SubItems.Add(FieldByName('name').AsString);
        ImageIndex := 11;
        StateIndex := ImageIndex;
      end;

      Next;
    end;
  end;

  Result := ListStock.Items.Count > 0;
  if Result then
  begin
    ActiveControl := ListStock;
    ListStock.ItemIndex := 0;
    ListStock.ItemFocused := ListStock.TopItem;
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormGetStock.ListStockKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;

    if ListStock.ItemIndex > -1 then
      ModalResult := mrOk;
    //xxxxx
  end;
end;

procedure TfFormGetStock.ListStockDblClick(Sender: TObject);
begin
  if ListStock.ItemIndex > -1 then
    ModalResult := mrOk;
  //xxxxx
end;

procedure TfFormGetStock.BtnOKClick(Sender: TObject);
begin
  if ListStock.ItemIndex > -1 then
       ModalResult := mrOk
  else ShowMsg('请在查询结果中选择', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormGetStock, TfFormGetStock.FormID);
end.

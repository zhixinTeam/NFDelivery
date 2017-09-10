{*******************************************************************************
  作者: dmzn@163.com 2017-09-10
  描述: 关联磁卡
*******************************************************************************}
unit UFormCardInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, cxTextEdit,
  dxLayoutControl, StdCtrls;

type
  TfFormCardInfo = class(TfFormNormal)
    EditBill: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditTruck: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditCard: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    dxLayout1Item5: TdxLayoutItem;
    cxLabel1: TcxLabel;
    EditCus: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditStock: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
  private
    { Private declarations }
    procedure InitFormData(const nCard: string);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UFormBase, UBusinessConst, UMgrControl, USysBusiness, USmallFunc,
  USysConst;

class function TfFormCardInfo.FormID: integer;
begin
  Result := cFI_FormCardInfo;
end;

class function TfFormCardInfo.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: TFormCommandParam;
begin
  Result := nil;
  CreateBaseFormItem(cFI_FormReadCard, '', @nP);
  if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

  with TfFormCardInfo.Create(Application) do
  try
    InitFormData(nP.FParamB);
    ShowModal;
  finally
    Free;
  end;
end;

procedure TfFormCardInfo.InitFormData(const nCard: string);
var nIdx: Integer;
    nBills: TLadingBillItems;
begin
  BtnOK.Visible := False;
  EditCard.Text := nCard;
  GetLadingBills(nCard, '', nBills);

  for nIdx:=Low(nBills) to High(nBills) do
  with nBills[nIdx] do
  begin
    EditBill.Text := EditBill.Text + FID + ' ';
    if Pos(FCusName, EditCus.Text) < 1 then
      EditCus.Text  := EditCus.Text + FCusName + ' ';
    //xxxxx

    if Pos(FTruck, EditTruck.Text) < 1 then
      EditTruck.Text := EditTruck.Text + FTruck + ' ';
    //xxxxx

    if Pos(FStockName, EditStock.Text) < 1 then
      EditStock.Text := EditStock.Text + FStockName + ' ';
    //xxxxx
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormCardInfo, TfFormCardInfo.FormID);
end.

{*******************************************************************************
  作者: dmzn@163.com 2014-12-15
  描述: 销售订单申请单
*******************************************************************************}
unit UFrameReqSale;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  cxContainer, dxLayoutControl, cxMaskEdit, cxButtonEdit, cxTextEdit,
  ADODB, cxLabel, UBitmapPanel, cxSplitter, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, cxCheckBox;

type
  TfFrameReqSale = class(TfFrameNormal)
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    dxLayout1Item5: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditID: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    procedure EditNamePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    //时间间隔
    FListA: TStrings;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormBase, UFormDateFilter, UBase64,
  USysConst, USysDB, USysBusiness;

class function TfFrameReqSale.FrameID: integer;
begin
  Result := cFI_FrameReqSale;
end;

procedure TfFrameReqSale.OnCreateFrame;
begin
  inherited;
  FEnableBackDB := True;

  FListA := TStringList.Create;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameReqSale.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  FListA.Free;
  inherited;
end;

function TfFrameReqSale.InitFormDataSQL(const nWhere: string): string;
begin
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  with FListA do
  begin
    Values['DateStart'] := Date2Str(FStart);
    Values['DateEnd'] := Date2Str(FEnd + 1);
  end;

  Result := GetQueryOrderSQL('103', EncodeBase64(FListA.Text));
  FListA.Clear;
end;

procedure TfFrameReqSale.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

//Desc: 查询
procedure TfFrameReqSale.EditNamePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := Format('custname Like ''%%%s%%''', [EditName.Text]);
    FListA.Text := 'Filter=' + EncodeBase64(FWhere);
    InitFormData('');
  end else

  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if Length(EditID.Text) <= 3 then Exit;

    FListA.Text := 'BillCode=' + EditID.Text;
    InitFormData('');
  end;
end;

procedure TfFrameReqSale.BtnAddClick(Sender: TObject);
var nStr: string;
    nP: TFormCommandParam;
    nOrder: TOrderItemInfo;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择订单', sHint);
    Exit;
  end;

  with nOrder,SQLQuery do
  begin
    FOrders := FieldByName('PK_MEAMBILL').AsString;
    FCusID  := FieldByName('custcode').AsString;
    FCusName:= FieldByName('custname').AsString;
    FSaleMan:= FieldByName('VBILLTYPE').AsString;
    FStockID:= FieldByName('invcode').AsString;
    FStockName:= FieldByName('invname').AsString;
    FTruck:= FieldByName('cvehicle').AsString;
    FBatchCode:= FieldByName('vbatchcode').AsString;
    FValue:= FieldByName('NPLANNUM').AsFloat;
    FStockArea := FieldByName('areaclname').AsString;
    FStockBrand:= FieldByName('vdef5').AsString;

    FListA.Text := nOrder.FOrders;
    if not GetOrderFHValue(FListA) then
    begin
      ShowMsg('读取已发量失败', sHint);
      Exit;
    end;

    nStr := FListA.Values[FOrders];
    if not IsNumber(nStr, True) then nStr := '0';

    FValue := FValue - Float2Float(StrToFloat(nStr), cPrecision, True);
    //可用量 = 计划量 - 已发量
  end;

  nP.FParamA := BuildOrderInfo(nOrder);
  CreateBaseFormItem(cFI_FormMakeBill, PopedomItem, @nP);
end;

initialization
  gControlManager.RegCtrl(TfFrameReqSale, TfFrameReqSale.FrameID);
end.

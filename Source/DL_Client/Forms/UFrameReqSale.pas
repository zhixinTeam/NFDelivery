{*******************************************************************************
  ����: dmzn@163.com 2014-12-15
  ����: ���۶������뵥
*******************************************************************************}
unit UFrameReqSale;

{$I Link.inc}
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
    EditTruck: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    procedure EditNamePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure cxView1CustomDrawCell(Sender: TcxCustomGridTableView;
      ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo;
      var ADone: Boolean);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    //ʱ����
    FListA: TStrings;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    {*��ѯSQL*}
    function GetVal(const nRow: Integer; const nField: string): string;
    //��ȡָ���ֶ�
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
  EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);
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

//Desc: ��ѯ
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
  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := Format('t2.cvehicle Like ''%%%s%%''', [EditTruck.Text]);
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
    ShowMsg('��ѡ�񶩵�', sHint);
    Exit;
  end;

  {$IFDEF JudgeOrder}
  if Trim(SQLQuery.FieldByName('cvehicle').AsString) <> '' then//���ƺ�Ϊ��Ĭ��Ϊ�󶩵�
  if not IsOrderCanLade(SQLQuery.FieldByName('PK_MEAMBILL').AsString) then
  begin
    ShowMsg('��������ʹ��,�޷�����', sHint);
    Exit;
  end;
  {$ELSE}
    {$IFDEF OrderUsedOne}
    if Trim(SQLQuery.FieldByName('cvehicle').AsString) <> '' then//���ƺ�Ϊ��Ĭ��Ϊ�󶩵�
    if not IsOrderUsed(SQLQuery.FieldByName('PK_MEAMBILL').AsString) then
    begin
      ShowMsg('������ʹ��,�޷�����', sHint);
      Exit;
    end;
    {$ENDIF}
  {$ENDIF}

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
    FBm:= FieldByName('bm').AsString;

    if Assigned(FindField('specialcus')) then
      FSpecialCus:= FieldByName('specialcus').AsString
    else
      FSpecialCus := '';

    FListA.Text := nOrder.FOrders;
    if not GetOrderFHValue(FListA) then
    begin
      ShowMsg('��ȡ�ѷ���ʧ��', sHint);
      Exit;
    end;

    nStr := FListA.Values[FOrders];
    if not IsNumber(nStr, True) then nStr := '0';

    FValue := FValue - Float2Float(StrToFloat(nStr), cPrecision, True);
    //������ = �ƻ��� - �ѷ���
  end;

  nP.FParamA := BuildOrderInfo(nOrder);
  CreateBaseFormItem(cFI_FormMakeBill, PopedomItem, @nP);
end;

procedure TfFrameReqSale.cxView1CustomDrawCell(
  Sender: TcxCustomGridTableView; ACanvas: TcxCanvas;
  AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
begin
  inherited;
  {$IFDEF JudgeOrder}
  if Trim(AViewInfo.GridRecord.Values[TcxGridDBTableView(Sender).GetColumnByFieldName('cvehicle').Index]) <> '' then//���ƺ�Ϊ��Ĭ��Ϊ�󶩵�
  if not IsOrderCanLade(AViewInfo.GridRecord.Values[TcxGridDBTableView(Sender).GetColumnByFieldName('PK_MEAMBILL').Index]) then
  begin
    ACanvas.Canvas.Font.Color := clRed;
  end;
  {$ELSE}
    {$IFDEF OrderUsedOne}
    if Trim(AViewInfo.GridRecord.Values[TcxGridDBTableView(Sender).GetColumnByFieldName('cvehicle').Index]) <> '' then//���ƺ�Ϊ��Ĭ��Ϊ�󶩵�
    if not IsOrderUsed(AViewInfo.GridRecord.Values[TcxGridDBTableView(Sender).GetColumnByFieldName('PK_MEAMBILL').Index]) then
    begin
      ACanvas.Canvas.Font.Color := clRed;
    end;
    {$ENDIF}
  {$ENDIF}
end;

//Desc: ��ȡnRow��nField�ֶε�����
function TfFrameReqSale.GetVal(const nRow: Integer;
 const nField: string): string;
var nVal: Variant;
begin
  nVal := cxView1.ViewData.Rows[nRow].Values[
            cxView1.GetColumnByFieldName(nField).Index];
  //xxxxx

  if VarIsNull(nVal) then
       Result := ''
  else Result := nVal;
end;

initialization
  gControlManager.RegCtrl(TfFrameReqSale, TfFrameReqSale.FrameID);
end.

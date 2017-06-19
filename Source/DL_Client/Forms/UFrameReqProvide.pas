{*******************************************************************************
  ����: dmzn@163.com 2015-01-07
  ����: ��Ӧ�������뵥
*******************************************************************************}
unit UFrameReqProvide;

{$I Link.Inc}
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
  TfFrameReqProvide = class(TfFrameNormal)
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
    //ʱ����
    FListA: TStrings;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    {*��ѯSQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormBase, UFormDateFilter, UBase64,
  USysConst, USysDB, USysBusiness;

class function TfFrameReqProvide.FrameID: integer;
begin
  Result := cFI_FrameReqProvide;
end;

procedure TfFrameReqProvide.OnCreateFrame;
begin
  inherited;
  FEnableBackDB := True;

  FListA := TStringList.Create;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameReqProvide.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  FListA.Free;
  inherited;
end;

function TfFrameReqProvide.InitFormDataSQL(const nWhere: string): string;
begin
  EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);
  with FListA do
  begin
    Values['DateStart'] := Date2Str(FStart);
    Values['DateEnd'] := Date2Str(FEnd + 1);
  end;

  Result := GetQueryOrderSQL('203', EncodeBase64(FListA.Text));
  FListA.Clear;
end;

//Desc: ɾ��
procedure TfFrameReqProvide.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

//Desc: ��ѯ
procedure TfFrameReqProvide.EditNamePropertiesButtonClick(Sender: TObject;
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

procedure TfFrameReqProvide.BtnAddClick(Sender: TObject);
var nStr: string;
    nP: TFormCommandParam;
    nOrder: TOrderItemInfo;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ�񶩵�', sHint);
    Exit;
  end;

  with nOrder,SQLQuery do
  begin
    FOrders := FieldByName('PK_MEAMBILL').AsString;
    FCusID  := FieldByName('custcode').AsString;
    FCusName:= FieldByName('custname').AsString;
    FStockID:= FieldByName('invcode').AsString;
    FStockName:= FieldByName('invname').AsString;
    FStockArea:= FieldByName('vdef10').AsString;
    FValue:= FieldByName('NPLANNUM').AsFloat;

    FListA.Text := nOrder.FOrders;
    if not GetOrderGYValue(FListA) then
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
  {$IFDEF CardProvide}
  CreateBaseFormItem(cFI_FormCardProvide, PopedomItem, @nP);
  {$ELSE}
  CreateBaseFormItem(cFI_FormProvBase, PopedomItem, @nP);
  {$ENDIF}
end;

initialization
  gControlManager.RegCtrl(TfFrameReqProvide, TfFrameReqProvide.FrameID);
end.

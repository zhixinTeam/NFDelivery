{*******************************************************************************
  作者: fendou116688@163.com 2016/7/4
  描述: 开散装固定卡订单
*******************************************************************************}
unit UFrameBillNew;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, ADODB, cxContainer, cxLabel,
  dxLayoutControl, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxTextEdit, cxMaskEdit, cxButtonEdit, Menus,
  UBitmapPanel, cxSplitter, cxLookAndFeels, cxLookAndFeelPainters,
  cxCheckBox;

type
  TfFrameBillNew = class(TfFrameNormal)
    EditCus: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    PMenu1: TPopupMenu;
    EditLID: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    N5: TMenuItem;
    Edit1: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    CheckDelButton: TcxCheckBox;
    dxLayout1Item10: TdxLayoutItem;
    N1: TMenuItem;
    N2: TMenuItem;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure N5Click(Sender: TObject);
    procedure CheckDelButtonClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
  protected
    FStart,FEnd: TDate;
    //时间区间
    FUseDate: Boolean;
    //使用区间
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function FilterColumnField: string; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    procedure AfterInitFormData; override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormBase, UFormInputbox, USysPopedom,
  USysConst, USysDB, USysBusiness, UFormDateFilter;

//------------------------------------------------------------------------------
class function TfFrameBillNew.FrameID: integer;
begin
  Result := cFI_FrameBillNew;
end;

procedure TfFrameBillNew.OnCreateFrame;
begin
  inherited;
  FUseDate := True;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameBillNew.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

//Desc: 数据查询SQL
function TfFrameBillNew.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);

  Result := 'Select * From $Bill ';
  //提货单

  if (nWhere = '') or FUseDate then
  begin
    Result := Result + 'Where (B_Date>=''$ST'' and B_Date <''$End'')';
    nStr := ' And ';
  end else nStr := ' Where ';

  if nWhere <> '' then
    Result := Result + nStr + '(' + nWhere + ')';
  //xxxxx

  if CheckDelButton.Checked then
  Result := MacroValue(Result, [MI('$Bill', sTable_BillNewBak),
            MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))])
  else
  Result := MacroValue(Result, [MI('$Bill', sTable_BillNew),
            MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx
end;

procedure TfFrameBillNew.AfterInitFormData;
begin
  FUseDate := True;
end;

function TfFrameBillNew.FilterColumnField: string;
begin
  if gPopedomManager.HasPopedom(PopedomItem, sPopedom_ViewPrice) then
       Result := ''
  else Result := 'B_Price';
end;

//Desc: 执行查询
procedure TfFrameBillNew.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditLID then
  begin
    EditLID.Text := Trim(EditLID.Text);
    if EditLID.Text = '' then Exit;

    FUseDate := Length(EditLID.Text) <= 3;
    FWhere := 'B_ID like ''%' + EditLID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditCus then
  begin
    EditCus.Text := Trim(EditCus.Text);
    if EditCus.Text = '' then Exit;

    FWhere := 'B_CusPY like ''%%%s%%'' Or B_CusName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCus.Text, EditCus.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := Format('B_Truck like ''%%%s%%''', [EditTruck.Text]);
    InitFormData(FWhere);
  end;
end;

//Desc: 日期筛选
procedure TfFrameBillNew.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

//------------------------------------------------------------------------------
//Desc: 开提货单
procedure TfFrameBillNew.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FParamA := '';
  CreateBaseFormItem(cFI_FormBillNew, PopedomItem, @nP);
  
  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: 删除
procedure TfFrameBillNew.BtnDelClick(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要删除的记录', sHint); Exit;
  end;

  nStr := '确定要删除编号为[ %s ]的单据吗?';
  nStr := Format(nStr, [SQLQuery.FieldByName('B_ID').AsString]);
  if not QueryDlg(nStr, sAsk) then Exit;

  if DeleteBillNew(SQLQuery.FieldByName('B_ID').AsString) then
  begin
    InitFormData(FWhere);
    ShowMsg('销售订单已删除', sHint);
  end;
end;

//Desc: 修改未进厂车牌号
procedure TfFrameBillNew.N5Click(Sender: TObject);
var nStr,nTruck: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('B_Truck').AsString;
    nTruck := nStr;
    if not ShowInputBox('请输入新的车牌号码:', '修改', nTruck, 15) then Exit;

    if (nTruck = '') or (nStr = nTruck) then Exit;
    //无效或一致

    nStr := SQLQuery.FieldByName('B_ID').AsString;
    if ChangeLadingTruckNo(nStr, nTruck) then
    begin
      InitFormData(FWhere);
      ShowMsg('车牌号修改成功', sHint);
    end;
  end;
end;

procedure TfFrameBillNew.CheckDelButtonClick(Sender: TObject);
begin
  inherited;
  BtnRefresh.Click;
end;

procedure TfFrameBillNew.N1Click(Sender: TObject);
var nLID :String;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nLID := SaveBillFromNew(SQLQuery.FieldByName('B_ID').AsString);
    if nLID <> '' then
    begin
      InitFormData(FWhere);
      ShowMsg('生成明细' +nLID+ '成功', sHint);
    end;
  end;
end;

procedure TfFrameBillNew.N2Click(Sender: TObject);
begin
  inherited;
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    if SetBillCard(SQLQuery.FieldByName('B_ID').AsString,
      SQLQuery.FieldByName('B_Truck').AsString, True, True) then
    begin
      InitFormData(FWhere);
      ShowMsg('关联磁卡成功', sHint);
    end;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameBillNew, TfFrameBillNew.FrameID);
end.

{*******************************************************************************
  作者: dmzn@163.com 2012-03-26
  描述: 发货明细
*******************************************************************************}
unit UFrameQuerySaleDetail;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  cxMaskEdit, cxButtonEdit, cxTextEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin;

type
  TfFrameSaleDetailQuery = class(TfFrameNormal)
    cxtxtdt1: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditCustomer: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    cxtxtdt2: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    pmPMenu1: TPopupMenu;
    mniN1: TMenuItem;
    cxtxtdt3: TcxTextEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxtxtdt4: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditBill: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    EditPoundD: TcxButtonEdit;
    dxLayout1Item9: TdxLayoutItem;
    N4: TMenuItem;
    N5: TMenuItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure mniN1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure cxButtonEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure N5Click(Sender: TObject);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    FTimeS,FTimeE: TDate;
    FPoundS, FPoundE: TDate;
    //时间区间
    FJBWhere: string;
    //交班条件
    FShadowWeight: Double;
    //影子重量 
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function FilterColumnField: string; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //查询SQL
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, UDataModule, UFormDateFilter, USysPopedom,
  USysBusiness, UBusinessConst, USysConst, USysDB;

class function TfFrameSaleDetailQuery.FrameID: integer;
begin
  Result := cFI_FrameSaleDetailQuery;
end;

procedure TfFrameSaleDetailQuery.OnCreateFrame;
begin
  inherited;
  FTimeS := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  FTimeE := Str2DateTime(Date2Str(Now+1) + ' 00:00:00');

  FPoundS := Date;
  FPoundE := Date;

  FJBWhere := '';
  FShadowWeight := -1;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameSaleDetailQuery.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

function TfFrameSaleDetailQuery.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  EditPoundD.Text := Format('%s 至 %s', [Date2Str(FPoundS), Date2Str(FPoundE)]);
  //Result := 'Select * From $Bill b Left Join $PoundLog p on b.L_ID=p.P_Bill ';
  Result := 'Select *,L_MValue-L_PValue as L_NetValue,L_MValue-L_PValue-L_Value as L_DiffValue From $Bill b Left Join $PoundLog p on b.L_ID=p.P_Bill ';

  if FJBWhere = '' then
  begin
    Result := Result + 'Where (L_OutFact>=''$S'' and L_OutFact <''$End'')';

    if nWhere <> '' then
      Result := Result + ' And (' + nWhere + ')';
    //xxxxx
  end else
  begin
    Result := Result + ' Where (' + FJBWhere + ')';
  end;

  if not gPopedomManager.HasPopedom('MAIN_L06', sPopedom_ViewDai) then
    Result := Result + ' And ( L_Type=''' + sFlag_San + ''')';

  Result := MacroValue(Result, [MI('$Bill', sTable_Bill),
            MI('$PoundLog', sTable_PoundLog),
            MI('$S', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx

  if not gPopedomManager.HasPopedom(PopedomItem, sPopedom_FullReport) then
  begin
    if FShadowWeight < 0 then
    begin
      FShadowWeight := 0;
      nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
      nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_ShadowWeight]);

      with FDM.QueryTemp(nStr) do
      if RecordCount > 0 then
      begin
        FShadowWeight := Fields[0].AsFloat;
      end;
    end;

    if FShadowWeight > 0 then
    begin
      nStr := ' And L_Value<%f';
      Result := Result +  Format(nStr, [FShadowWeight]);
    end;
  end;
end;

//Desc: 过滤字段
function TfFrameSaleDetailQuery.FilterColumnField: string;
begin
  if gPopedomManager.HasPopedom(PopedomItem, sPopedom_ViewPrice) then
       Result := ''
  else Result := 'L_Price;L_Money';
end;

//Desc: 日期筛选
procedure TfFrameSaleDetailQuery.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

//Desc: 执行查询
procedure TfFrameSaleDetailQuery.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := 'L_CusPY like ''%%%s%%'' Or L_CusName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text,EditBill.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := 'b.L_Truck like ''%%%s%%''';
    FWhere := Format(FWhere, [EditTruck.Text]);
    InitFormData(FWhere);
  end;

  if Sender = EditBill then
  begin
    EditBill.Text := Trim(EditBill.Text);
    if EditBill.Text = '' then Exit;

    FWhere := 'b.L_ID like ''%%%s%%''';
    FWhere := Format(FWhere, [EditBill.Text]);
    InitFormData(FWhere);
  end;
end;

//Desc: 交接班查询
procedure TfFrameSaleDetailQuery.mniN1Click(Sender: TObject);
begin
  if ShowDateFilterForm(FTimeS, FTimeE, True) then
  try
    FJBWhere := '(L_OutFact>=''%s'' and L_OutFact <''%s'')';
    FJBWhere := Format(FJBWhere, [DateTime2Str(FTimeS), DateTime2Str(FTimeE)]);
    InitFormData('');
  finally
    FJBWhere := '';
  end;
end;

//Desc: 按过重时间统计
procedure TfFrameSaleDetailQuery.N2Click(Sender: TObject);
begin
  if ShowDateFilterForm(FTimeS, FTimeE, True) then
  try
    FJBWhere := '(L_MDate>=''%s'' and L_MDate <''%s'' And L_OutFact Is Not Null)';
    FJBWhere := Format(FJBWhere, [DateTime2Str(FTimeS), DateTime2Str(FTimeE)]);
    InitFormData('');
  finally
    FJBWhere := '';
  end;
end;

//Desc: 按发货时间统计
procedure TfFrameSaleDetailQuery.N3Click(Sender: TObject);
begin
  if ShowDateFilterForm(FTimeS, FTimeE, True) then
  try
    FJBWhere := '(L_LadeTime>=''%s'' and L_LadeTime <''%s'' And L_OutFact Is Not Null)';
    FJBWhere := Format(FJBWhere, [DateTime2Str(FTimeS), DateTime2Str(FTimeE)]);
    InitFormData('');
  finally
    FJBWhere := '';
  end;
end;

procedure TfFrameSaleDetailQuery.cxButtonEdit1PropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  inherited;
  if ShowDateFilterForm(FPoundS, FPoundE) then
  try
    FJBWhere := '(L_MDate>=''%s'' and L_MDate <''%s'')';
    FJBWhere := Format(FJBWhere, [DateTime2Str(FPoundS), DateTime2Str(FPoundE + 1)]);
    InitFormData('');
  finally
    FJBWhere := '';
  end;
end;

procedure TfFrameSaleDetailQuery.N5Click(Sender: TObject);
var nPID, nStr: string;
    nList: TStrings;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    if SQLQuery.FieldByName('L_OutFact').AsString = '' then
    begin
      nStr := Format('提货单[ %s ]未出厂,无法上传', [nPID]);
      ShowMsg(nStr, sHint);
      Exit;
    end;

    nPID := SQLQuery.FieldByName('L_ID').AsString;

    nStr := Format('确认上传提货单[ %s ]吗?', [nPID]);
    if not QueryDlg(nStr, sHint) then Exit;

    nList := TStringList.Create;

    try
      nList.Add(nPID);
      if not SyncSaleDetail(nList.Text) then
      begin
        ShowMsg('提货单上传失败',sHint);
        Exit;
      end;
    finally
      nList.Free;
    end;

    ShowMsg('上传成功',sHint);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameSaleDetailQuery, TfFrameSaleDetailQuery.FrameID);
end.

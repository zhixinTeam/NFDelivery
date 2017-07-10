{*******************************************************************************
  作者: fendou116688@163.com 2017/6/2
  描述: 回空业务办卡
*******************************************************************************}
unit UFrameBillHaulBack;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  cxCheckBox, cxTextEdit, cxMaskEdit, cxButtonEdit, ADODB, cxLabel,
  UBitmapPanel, cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin;

type
  TfFrameBillHaulBack = class(TfFrameNormal)
    EditTruck: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    PMenu1: TPopupMenu;
    Edit1: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    dxLayout1Item10: TdxLayoutItem;
    CheckDelete: TcxCheckBox;
    N2: TMenuItem;
    N1: TMenuItem;
    EditCusName: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure CheckDeleteClick(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
  protected
    FStart,FEnd: TDate;
    //时间区间
    FUseDate: Boolean;
    //使用区间
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
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
  ULibFun, UMgrControl, UDataModule, UFormBase, UFormWait, UFormInputbox,
  UFormDateFilter, USysPopedom, USysConst, USysDB, USysBusiness, UFormCtrl;

//------------------------------------------------------------------------------
class function TfFrameBillHaulBack.FrameID: integer;
begin
  Result := cFI_FrameBillHaulback;
end;

procedure TfFrameBillHaulBack.OnCreateFrame;
begin
  inherited;
  FUseDate := True;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameBillHaulBack.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

//Desc: 数据查询SQL
function TfFrameBillHaulBack.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  Result := 'Select * From $HK ';

  if (nWhere = '') or FUseDate then
  begin
    if CheckDelete.Checked then
         Result := Result + 'Where (H_DelDate>=''$ST'' and H_DelDate <''$End'')'
    else Result := Result + 'Where (H_Date>=''$ST'' and H_Date <''$End'')';
    nStr := ' And ';
  end else nStr := ' Where ';

  if nWhere <> '' then
    Result := Result + nStr + '(' + nWhere + ')';
  //xxxxx

  Result := MacroValue(Result, [
            MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx

  if CheckDelete.Checked then
       Result := MacroValue(Result, [MI('$HK', sTable_BillHaulBak)])
  else Result := MacroValue(Result, [MI('$HK', sTable_BillHaulBack)]);
end;

procedure TfFrameBillHaulBack.AfterInitFormData;
begin
  FUseDate := True;
end;

//Desc: 执行查询
procedure TfFrameBillHaulBack.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FUseDate := Length(EditTruck.Text) <= 3;
    FWhere := Format('H_Truck like ''%%%s%%''', [EditTruck.Text]);
    InitFormData(FWhere);

  end else

  if Sender = EditCusName then
  begin
    EditCusName.Text := Trim(EditCusName.Text);
    if EditCusName.Text = '' then Exit;

    FWhere := Format('H_CusPY like ''%%%s%%'' or H_CusName Like''%%%s%%''',
              [EditTruck.Text, EditTruck.Text]);
    InitFormData(FWhere);
  end;
end;

//Desc: 日期筛选
procedure TfFrameBillHaulBack.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

//Desc: 查询删除
procedure TfFrameBillHaulBack.CheckDeleteClick(Sender: TObject);
begin
  InitFormData('');
end;

//------------------------------------------------------------------------------
//Desc: 开提货单
procedure TfFrameBillHaulBack.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormBillHaulback, PopedomItem, @nP);
  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: 删除
procedure TfFrameBillHaulBack.BtnDelClick(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要删除的记录', sHint); Exit;
  end;

  nStr := '确定要删除编号为[ %s ]的单据吗?';
  nStr := Format(nStr, [SQLQuery.FieldByName('H_ID').AsString]);
  if not QueryDlg(nStr, sAsk) then Exit;

  if DeleteBillHaulBack(SQLQuery.FieldByName('H_ID').AsString) then
  begin
    InitFormData(FWhere);
    ShowMsg('回空单据已删除', sHint);
  end;
end;

//注销磁卡
procedure TfFrameBillHaulBack.N1Click(Sender: TObject);
var nStr,nCard: string;
begin
  nCard := SQLQuery.FieldByName('H_Card').AsString;
  nStr := Format('确定要对卡[ %s ]执行销卡操作吗?', [nCard]);
  if not QueryDlg(nStr, sAsk) then Exit;

  FDM.ADOConn.BeginTrans;
  try
    nStr := 'Update %s Set H_Card=NULL Where H_ID=''%s''';
    nStr := Format(nStr, [sTable_BillHaulBack, SQLQuery.FieldByName('H_ID').AsString]);
    FDM.ExecuteSQL(nStr);

    nStr := 'Update %s Set C_Status=''%s'' Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, sFlag_CardInvalid, nCard]);
    FDM.ExecuteSQL(nStr);

    FDM.ADOConn.CommitTrans;
    InitFormData(FWhere);
    ShowMsg('注销操作成功', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    raise;
  end;
end;

//办理磁卡
procedure TfFrameBillHaulBack.N2Click(Sender: TObject);
var nP: TFormCommandParam;
    nSQL, nStr, nCard, nTruck: string;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount < 1 then Exit;

  nStr := SQLQuery.FieldByName('H_Card').AsString;
  if nStr <> '' then
  begin
    ShowMsg('请先注销磁卡', sHint);
    Exit;
  end;

  CreateBaseFormItem(cFI_FormReadCard, '', @nP);
  if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
  nCard := nP.FParamB;

  nStr := SQLQuery.FieldByName('H_ID').AsString;
  nTruck := SQLQuery.FieldByName('H_Truck').AsString;

  FDM.ADOConn.BeginTrans;
  try
    nSQL := 'Update %s Set P_Card=NULL Where P_Card=''%s''';
    nSQL := Format(nSQL, [sTable_ProvBase, nCard]);
    FDM.ExecuteSQL(nSQL);
    //正在使用的采购订单

    nSQL := 'Update %s Set L_Card=NULL Where L_Card=''%s''';
    nSQL := Format(nSQL, [sTable_Bill, nCard]);
    FDM.ExecuteSQL(nSQL);
    //正在使用的销售提货单

    nSQL := 'Update %s Set O_Card=NULL Where O_Card=''%s''';
    nSQL := Format(nSQL, [sTable_CardOther, nCard]);
    FDM.ExecuteSQL(nSQL);
    //正在使用的临时业务卡

    nSQL := 'Update %s Set P_Card=NULL Where P_Card=''%s''';
    nSQL := Format(nSQL, [sTable_CardProvide, nCard]);
    FDM.ExecuteSQL(nSQL);
    //正在使用的采购业务卡

    nSQL := 'Update %s Set H_Card=''%s'' Where H_ID=%s';
    nSQL := Format(nSQL, [sTable_BillHaulBack, nCard, nStr]);
    FDM.ExecuteSQL(nSQL);
    //正在使用的采购业务卡

    nSQL := 'Select Count(*) From %s Where C_Card=''%s''';
    nSQL := Format(nSQL, [sTable_Card, nCard]);

    with FDM.QuerySQL(nSQL) do
    if Fields[0].AsInteger < 1 then
    begin
      nSQL := MakeSQLByStr([SF('C_Card', nCard),
              SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Haulback),
              SF('C_Freeze', sFlag_No),
              SF('C_TruckNo', nTruck),
              SF('C_Man', gSysParam.FUserID),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, '', True);
      FDM.ExecuteSQL(nSQL);
    end else
    begin
      nSQL := Format('C_Card=''%s''', [nCard]);
      nSQL := MakeSQLByStr([
              SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Haulback),
              SF('C_Freeze', sFlag_No),
              SF('C_TruckNo', nTruck),
              SF('C_Man', gSysParam.FUserID),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, nSQL, False);
      FDM.ExecuteSQL(nSQL);
    end;
    //更新磁卡状态

    FDM.ADOConn.CommitTrans;
    InitFormData(FWhere);
    ShowMsg('补办磁卡成功', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    raise;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameBillHaulBack, TfFrameBillHaulBack.FrameID);
end.

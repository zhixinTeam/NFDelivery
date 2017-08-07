{*******************************************************************************
  作者: dmzn@163.com 2017-08-06
  描述: 待处理事项
*******************************************************************************}
unit UFrameTodo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, dxLayoutControl,
  cxTextEdit, cxMaskEdit, cxButtonEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin;

type
  TfFrameTodo = class(TfFrameNormal)
    EditSMemo: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    procedure BtnAddClick(Sender: TObject);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    {*时间区间*}
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    {*基类函数*}
    function InitFormDataSQL(const nWhere: string): string; override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysDB, UDataModule, UFormBase,
  UFormDateFilter;

class function TfFrameTodo.FrameID: integer;
begin
  Result := cFI_FrameTodo;
end;

procedure TfFrameTodo.OnCreateFrame;
begin
  inherited;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameTodo.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

//------------------------------------------------------------------------------
//Desc: 数据查询SQL
function TfFrameTodo.InitFormDataSQL(const nWhere: string): string;
begin
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  Result := 'Select * From $ME ';

  if nWhere = '' then
       Result := Result + 'Where (E_Date>=''$S'' and E_Date <''$E'')'
  else Result := Result + 'Where (' + nWhere + ')';
  //xxxxx
  
  Result := MacroValue(Result, [MI('$ME', sTable_ManualEvent),
            MI('$S', Date2Str(FStart)), MI('$E', Date2Str(FEnd + 1))]);
  //xxxxx                                                                        )
end;

//Desc: 发送
procedure TfFrameTodo.BtnAddClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  nParam.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormTodoSend, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: 日期筛选
procedure TfFrameTodo.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

procedure TfFrameTodo.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := '(E_Event Like ''%' + EditTruck.Text + '%'')';
    if Length(EditTruck.Text) < 5 then
      FWhere := '(E_Date>=''$S'' and E_Date <''$E'') And ' + FWhere;
    InitFormData(FWhere);
  end
end;

initialization
  gControlManager.RegCtrl(TfFrameTodo, TfFrameTodo.FrameID);
end.

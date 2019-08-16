{*******************************************************************************
  作者: juner11212436@163.com 2019-05-21
  描述: 装车线库位控制
*******************************************************************************}
unit UFormLineKwControl;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxCheckBox, cxSpinEdit, cxTimeEdit,
  cxLabel;

type
  TfFormLineKwControl = class(TfFormNormal)
    dxGroup2: TdxLayoutGroup;
    EditLine: TcxComboBox;
    dxLayout1Item5: TdxLayoutItem;
    EditKw: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item4: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    procedure BtnOKClick(Sender: TObject);
  protected
    { Protected declarations }
    FTruckID: string;
    procedure LoadFormData(const nID: string);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormCtrl, USysDB, USysConst, UAdjustForm,
  USysBusiness;

type
  TCusItem = record
    FID   : string;
    FName : string;
  end;

var
  gStockItems: array of TCusItem;
  //客户列表

class function TfFormLineKwControl.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormLineKwControl.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '装车线库位控制 - 添加';
      FTruckID := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '装车线库位控制 - 修改';
      FTruckID := nP.FParamA;
    end;

    LoadFormData(FTruckID); 
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormLineKwControl.FormID: integer;
begin
  Result := cFI_FormLineKwControl;
end;

procedure TfFormLineKwControl.LoadFormData(const nID: string);
var nStr: string;
    nIdx: Integer;
begin
  LoadLine(EditLine.Properties.Items);

  if nID <> '' then
  begin
    nStr := 'Select * From %s Where D_ID=%s';
    nStr := Format(nStr, [sTable_SysDict, nID]);
    FDM.QueryTemp(nStr);
  end;

  with FDM.SqlTemp do
  begin
    if (nID = '') or (RecordCount < 1) then
    begin
      Exit;
    end;

    SetCtrlData(EditLine, FieldByName('D_Value').AsString);
    EditKw.Text := FieldByName('D_ParamB').AsString;
  end;
end;

//Desc: 保存
procedure TfFormLineKwControl.BtnOKClick(Sender: TObject);
var nStr,nCID: string;
begin
  if Trim(EditLine.Text) = '' then
  begin
    ActiveControl := EditLine;
    ShowMsg('请选择通道', sHint);
    Exit;
  end;

  if Trim(EditKw.Text) = '' then
  begin
    ActiveControl := EditKw;
    ShowMsg('请输入库位', sHint);
    Exit;
  end;

  if FTruckID = '' then
       nStr := ''
  else nStr := SF('D_ID', FTruckID, sfVal);

  nStr := MakeSQLByStr([
          SF('D_ParamB', Trim(EditKw.Text)),
          SF('D_Value', GetCtrlData(EditLine)),
          SF('D_Name', sFlag_LineKw)
          ], sTable_SysDict, nStr, FTruckID = '');
  FDM.ExecuteSQL(nStr);

  ModalResult := mrOk;
  ShowMsg('装车线库位分组控制信息保存成功', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormLineKwControl, TfFormLineKwControl.FormID);
end.

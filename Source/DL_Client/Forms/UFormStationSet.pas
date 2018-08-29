{*******************************************************************************
  作者: juner11212436@163.com 2018-08-24
  描述: 火车衡设置
*******************************************************************************}
unit UFormStationSet;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, StdCtrls, ExtCtrls, dxLayoutControl, cxControls,
  cxContainer, cxEdit, cxTextEdit, UFormBase, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters, cxMaskEdit,
  cxDropDownEdit;

type
  TfFormStationSet = class(TBaseForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    dxLayoutControl1Group1: TdxLayoutGroup;
    BtnOK: TButton;
    dxLayoutControl1Item4: TdxLayoutItem;
    BtnExit: TButton;
    dxLayoutControl1Item5: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    cxComboBox1: TcxComboBox;
    dxLayoutControl1Item2: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysDB, USysPopedom;

//------------------------------------------------------------------------------
class function TfFormStationSet.CreateForm;
var nStr: string;
begin
  Result := nil;

  with TfFormStationSet.Create(Application) do
  begin
    nStr := 'select D_Value from %s where D_Name=''%s'' ';
    nStr := Format(nStr, [sTable_SysDict, sFlag_StationAutoP]);

    with FDM.QuerySQL(nStr) do
    if RecordCount > 0 then
    begin
      nStr:=Fields[0].AsString;
      if nStr = sFlag_No then
        cxComboBox1.ItemIndex := 1
      else
        cxComboBox1.ItemIndex := 0;
    end;
    BtnOK.Enabled := gPopedomManager.HasPopedom(nPopedom, sPopedom_Edit);
    ShowModal;
    Free;
  end;
end;

class function TfFormStationSet.FormID: integer;
begin
  Result := cFI_FormStationSet;
end;

//------------------------------------------------------------------------------
//Desc: 保存
procedure TfFormStationSet.BtnOKClick(Sender: TObject);
var nStr: string;
begin
  if cxComboBox1.ItemIndex = 0 then
  begin
    nStr:='Update Sys_Dict set D_Value=''Y'' where D_Name=''StationAutoP'' ';
  end else
  begin
    nStr:='Update Sys_Dict set D_Value=''N'' where D_Name=''StationAutoP'' ';
  end;

  if FDM.ExecuteSQL(nStr, False) > 0 then
  begin
    ModalResult := mrOK;
    ShowMsg('模式切换成功', sHint);
  end else ShowMsg('切换模式时发生未知错误', '保存失败');
end;

initialization
  gControlManager.RegCtrl(TfFormStationSet, TfFormStationSet.FormID);
end.

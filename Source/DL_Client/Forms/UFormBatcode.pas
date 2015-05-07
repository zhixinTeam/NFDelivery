{*******************************************************************************
  作者: dmzn@163.com 2015-01-16
  描述: 批次档案管理
*******************************************************************************}
unit UFormBatcode;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxCheckBox, cxTextEdit,
  dxLayoutControl, StdCtrls, cxMaskEdit, cxDropDownEdit;

type
  TfFormBatcode = class(TfFormNormal)
    EditName: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditPrefix: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditInter: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    EditStock: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    dxLayout1Item6: TdxLayoutItem;
    EditInc: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditBase: TcxTextEdit;
    dxLayout1Group2: TdxLayoutGroup;
    dxLayout1Item8: TdxLayoutItem;
    EditLen: TcxTextEdit;
    dxLayout1Group4: TdxLayoutGroup;
    Check1: TcxCheckBox;
    dxLayout1Item10: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  protected
    { Protected declarations }
    FRecordID: string;
    //记录编号
    procedure LoadFormData(const nID: string);
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
    //验证数据
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UAdjustForm, UFormCtrl, USysDB, USysConst;

class function TfFormBatcode.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormBatcode.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '批次 - 添加';
      FRecordID := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '批次 - 修改';
      FRecordID := nP.FParamA;
    end;

    LoadFormData(FRecordID); 
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormBatcode.FormID: integer;
begin
  Result := cFI_FormBatch;
end;

procedure TfFormBatcode.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ReleaseCtrlData(Self);
end;

procedure TfFormBatcode.LoadFormData(const nID: string);
var nStr: string;
begin
  nStr := 'D_ParamB=Select D_ParamB,D_Value From %s Where D_Name=''%s'' ' +
          'And D_Index>=0 Order By D_Index DESC';
  nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem]);

  FDM.FillStringsData(EditStock.Properties.Items, nStr, 0, '.');
  AdjustCXComboBoxItem(EditStock, False);

  if nID <> '' then
  begin
    nStr := 'Select * From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_Batcode, nID]);
    FDM.QueryTemp(nStr);

    with FDM.SqlTemp do
    begin
      nStr := FieldByName('B_Stock').AsString;
      SetCtrlData(EditStock, nStr);

      EditName.Text := FieldByName('B_Name').AsString;
      EditBase.Text := FieldByName('B_Base').AsString;
      EditLen.Text := FieldByName('B_Length').AsString;

      EditPrefix.Text := FieldByName('B_Prefix').AsString;
      EditInc.Text := FieldByName('B_Incement').AsString;
      EditInter.Text := FieldByName('B_Interval').AsString;
      Check1.Checked := FieldByName('B_UseDate').AsString = sFlag_Yes;
    end;
  end;
end;

function TfFormBatcode.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
begin
  Result := True;

  if Sender = EditBase then
  begin
    Result := IsNumber(EditBase.Text, False);
    nHint := '请输入基数';
  end else

  if Sender = EditInc then
  begin
    Result := IsNumber(EditInc.Text, False);
    nHint := '请输入增量';
  end else

  if Sender = EditLen then
  begin
    Result := IsNumber(EditLen.Text, False);
    nHint := '请输入长度';
  end else

  if Sender = EditInter then
  begin
    Result := IsNumber(EditInter.Text, False);
    nHint := '请输入时长';
  end;
end;

//Desc: 保存
procedure TfFormBatcode.BtnOKClick(Sender: TObject);
var nStr,nU: string;
begin
  if not IsDataValid then Exit;
  //验证不通过

  if Check1.Checked then
       nU := sFlag_Yes
  else nU := sFlag_No;

  if FRecordID = '' then
       nStr := ''
  else nStr := SF('R_ID', FRecordID, sfVal);

  nStr := MakeSQLByStr([SF('B_Stock', GetCtrlData(EditStock)),
          SF('B_Name', EditName.Text),
          SF('B_Prefix', EditPrefix.Text),
          SF('B_Base', EditBase.Text, sfVal),
          SF('B_Length', EditLen.Text, sfVal),

          SF('B_Interval', EditInter.Text, sfVal),
          SF('B_Incement', EditInc.Text, sfVal),
          SF('B_UseDate', nU),
          SF('B_LastDate', sField_SQLServer_Now, sfVal)
          ], sTable_Batcode, nStr, FRecordID = '');
  FDM.ExecuteSQL(nStr);

  ModalResult := mrOk;
  ShowMsg('批次保存成功', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormBatcode, TfFormBatcode.FormID);
end.

{*******************************************************************************
  作者: fendou116688@163.com 2015-05-13
  描述: 批次档案查询
*******************************************************************************}
unit UFrameBatcodeQuery;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  cxMaskEdit, cxButtonEdit, cxTextEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, UFormCtrl, cxCheckBox;

type
  TfFrameBatcodeQuery = class(TfFrameNormal)
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    ckDel: TcxCheckBox;
    dxLayout1Item5: TdxLayoutItem;
    procedure EditNamePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure ckDelClick(Sender: TObject);
  private
    { Private declarations }
  protected
    function InitFormDataSQL(const nWhere: string): string; override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysBusiness, USysConst, USysDB, UDataModule, UFormBase;

class function TfFrameBatcodeQuery.FrameID: integer;
begin
  Result := cFI_FrameBatchQuery;
end;

function TfFrameBatcodeQuery.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select * From ' + sTable_BatcodeDoc;
  if nWhere <> '' then
        Result := Result + ' Where (' + nWhere + ')'
  else  Result := Result + ' Where (D_Valid <> ''D'')';
  Result := Result + ' Order By D_ID';
end;

//Desc: 添加
procedure TfFrameBatcodeQuery.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormBatchEdit, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: 修改
procedure TfFrameBatcodeQuery.BtnEditClick(Sender: TObject);
var nP: TFormCommandParam;
    nStr : string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    if SQLQuery.FieldByName('D_Valid').AsString = sFlag_BatchDel then
    begin
      nStr := '禁止修改已删除批次号';
      ShowMsg(nStr, sHint);
      Exit;
    end;  

    nP.FCommand := cCmd_EditData;
    nP.FParamA := SQLQuery.FieldByName('R_ID').AsString;
    CreateBaseFormItem(cFI_FormBatchEdit, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;
  end;
end;

//Desc: 删除
procedure TfFrameBatcodeQuery.BtnDelClick(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('D_Name').AsString;
    nStr := Format('确定要删除物料[ %s ]的当前批次吗?', [nStr]);
    if not QueryDlg(nStr, sAsk) then Exit;

    nStr := SF('R_ID', SQLQuery.FieldByName('R_ID').AsString);
    nStr := MakeSQLByStr([SF('D_DelMan', gSysParam.FUserID),
            SF('D_DelDate', sField_SQLServer_Now, sfVal),
            SF('D_Valid', sFlag_BatchDel)
            ], sTable_BatcodeDoc, nStr, False);

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
  end;
end;

//Desc: 查询
procedure TfFrameBatcodeQuery.EditNamePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := Format('D_Name Like ''%%%s%%''', [EditName.Text]);
    InitFormData(FWhere);
  end;
end;

procedure TfFrameBatcodeQuery.ckDelClick(Sender: TObject);
var nStr :string;
begin
  inherited;
  nStr := '';
  if ckDel.Checked then nStr := Format('D_Valid=''%s''', [sFlag_BatchDel]);

  InitFormData(nStr)
end;

initialization
  gControlManager.RegCtrl(TfFrameBatcodeQuery, TfFrameBatcodeQuery.FrameID);
end.

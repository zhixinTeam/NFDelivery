{*******************************************************************************
  作者: dmzn@163.com 2017-07-20
  描述: 磅单勘误
*******************************************************************************}
unit UFormPoundAdjust;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxCheckBox, cxLabel, cxCalendar;

type
  TfFormPoundAdjust = class(TfFormNormal)
    EditCusName: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditTruck: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item8: TdxLayoutItem;
    EditPValue: TcxTextEdit;
    dxLayout1Item10: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    dxLayout1Item13: TdxLayoutItem;
    cxLabel2: TcxLabel;
    dxLayout1Group4: TdxLayoutGroup;
    dxLayout1Item14: TdxLayoutItem;
    EditMValue: TcxTextEdit;
    dxLayout1Group5: TdxLayoutGroup;
    dxLayout1Group6: TdxLayoutGroup;
    dxLayout1Group7: TdxLayoutGroup;
    dxLayout1Item20: TdxLayoutItem;
    cxLabel3: TcxLabel;
    EditID: TcxTextEdit;
    dxLayout1Item21: TdxLayoutItem;
    dxLayout1Group9: TdxLayoutGroup;
    EditStock: TcxTextEdit;
    dxLayout1Item22: TdxLayoutItem;
    dxLayout1Group10: TdxLayoutGroup;
    EditStatus: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    EditNext: TcxComboBox;
    dxLayout1Item23: TdxLayoutItem;
    EditMDate: TcxDateEdit;
    dxLayout1Item7: TdxLayoutItem;
    dxLayout1Item15: TdxLayoutItem;
    EditPDate: TcxDateEdit;
    dxLayout1Group3: TdxLayoutGroup;
    dxLayout1Group8: TdxLayoutGroup;
    EditMemo: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
  protected
    { Protected declarations }
    FPoundID: string;
    //磅单号
    FPoundType: string;
    //磅单类型
    FBillID: string;
    //交货单
    procedure LoadFormData(const nID: string);
    //初始化界面
    function SaveProvide: Boolean;
    function SaveTemp: Boolean;
    function SaveSale: Boolean;
    //保存数据
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormCtrl, USysDB, USysConst,
  USysBusiness, UAdjustForm;
  
class function TfFormPoundAdjust.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormPoundAdjust.Create(Application) do
  try
    Caption := '磅单 - 勘误';
    FPoundID := nP.FParamA;

    LoadFormData(FPoundID);
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;

    AdjustCXComboBoxItem(EditStatus, True);
    AdjustCXComboBoxItem(EditNext, True);
  finally
    Free;
  end;
end;

class function TfFormPoundAdjust.FormID: integer;
begin
  Result := cFI_FormPoundAjdust;
end;

procedure TfFormPoundAdjust.LoadFormData(const nID: string);
var nStr: string;
begin     
  AdjustCXComboBoxItem(EditStatus, False);
  AdjustCXComboBoxItem(EditNext, False);

  EditStatus.ItemIndex := -1;
  EditNext.ItemIndex := -1;
  BtnOK.Enabled := False;

  nStr := 'Select * From %s Where P_ID=''%s''';
  nStr := Format(nStr, [sTable_PoundLog, nID]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then
    begin
      ShowMsg('磅单已无效', sHint);
      Exit;
    end;

    FPoundType := FieldByName('P_Type').AsString;
    //销售,供应等
    FBillID := FieldByName('P_Bill').AsString;
    //交货单,销售用

    EditID.Text := FieldByName('P_ID').AsString;
    EditCusName.Text := FieldByName('P_CusName').AsString;
    EditStock.Text := FieldByName('P_MName').AsString;
    EditTruck.Text := FieldByName('P_Truck').AsString;

    EditPValue.Text := FieldByName('P_PValue').AsString;
    EditPDate.Date := FieldByName('P_PDate').AsDateTime;
    EditMValue.Text := FieldByName('P_MValue').AsString;
    EditMDate.Date := FieldByName('P_MDate').AsDateTime;
  end;

  if FPoundType = sFlag_ShipPro then //供应
  begin
    nStr := 'Select P_Status,P_NextStatus From %s Where P_Pound=''%s''';
    nStr := Format(nStr, [sTable_CardProvide, FPoundID]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
      begin
        SetCtrlData(EditStatus, sFlag_TruckOut);
        EditMemo.Text := '采购业务已出厂,请在NC勘误.';
        Exit;
      end;

      SetCtrlData(EditStatus, FieldByName('P_Status').AsString);
      SetCtrlData(EditNext, FieldByName('P_NextStatus').AsString);
      EditMemo.Text := '采购业务,车辆在厂内';
    end;
  end;

  if FPoundType = sFlag_Sale then //销售
  begin
    nStr := 'Select L_Status,L_NextStatus From %s Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, FBillID]);

    with FDM.QueryTemp(nStr) do
    begin
      if (RecordCount < 1) or
         (FieldByName('L_Status').AsString = sFlag_TruckOut) then
      begin
        SetCtrlData(EditStatus, sFlag_TruckOut);
        EditMemo.Text := '销售业务已出厂,请在NC勘误.';
        Exit;
      end;

      SetCtrlData(EditStatus, FieldByName('L_Status').AsString);
      SetCtrlData(EditNext, FieldByName('L_NextStatus').AsString);
      EditMemo.Text := '销售业务,车辆在厂内,只可修改状态';
    end;
  end;

  if not IsNumber(EditPValue.Text, True) then
  begin
    EditPValue.Text := '0';
    EditPDate.Date := Now;
  end;

  if not IsNumber(EditMValue.Text, True) then
  begin
    EditMValue.Text := '0';
    EditMDate.Date := Now;
  end;

  BtnOK.Enabled := True;
end;

//Desc: 供应
function TfFormPoundAdjust.SaveProvide: Boolean;
var nStr,nPV,nPD,nMV,nMD: string;
begin
  Result := False;
  if not IsNumber(EditPValue.Text, True) then
  begin
    EditPValue.SetFocus;
    ShowMsg('请输入皮重', sHint); Exit;
  end;

  if not IsNumber(EditMValue.Text, True) then
  begin
    EditMValue.SetFocus;
    ShowMsg('请输入毛重', sHint); Exit;
  end;

  if StrToFloat(EditPValue.Text) <= 0 then
  begin
    nPV := 'Null';
    nPD := 'Null';
  end else
  begin
    nPV := EditPValue.Text;
    nPD := '''' + DateTime2Str(EditPDate.Date) + '''';
  end;

  if StrToFloat(EditMValue.Text) <= 0 then
  begin
    nMV := 'Null';
    nMD := 'Null';
  end else
  begin
    nMV := EditMValue.Text;
    nMD := '''' + DateTime2Str(EditMDate.Date) + '''';
  end;

  nStr := MakeSQLByStr([SF('P_CusName', EditCusName.Text),
          SF('P_Truck', EditTruck.Text),
          SF('P_MName', EditStock.Text),
          SF('P_PValue', nPV, sfVal),
          SF('P_PDate', nPD, sfVal),
          SF('P_MValue', nMV, sfVal),
          SF('P_MDate', nMD, sfVal)
          ], sTable_PoundLog, SF('P_ID', FPoundID), False);
  FDM.ExecuteSQL(nStr);

  nStr := MakeSQLByStr([SF('P_Status', GetCtrlData(EditStatus)),
          SF('P_NextStatus', GetCtrlData(EditNext))
          ], sTable_CardProvide, SF('P_Pound', FPoundID), False);
  FDM.ExecuteSQL(nStr);

  Result := True;
  //xxxxx
end;

//Desc: 临时
function TfFormPoundAdjust.SaveTemp: Boolean;
var nStr,nPV,nPD,nMV,nMD: string;
begin
  Result := False;
  if not IsNumber(EditPValue.Text, True) then
  begin
    EditPValue.SetFocus;
    ShowMsg('请输入皮重', sHint); Exit;
  end;

  if not IsNumber(EditMValue.Text, True) then
  begin
    EditMValue.SetFocus;
    ShowMsg('请输入毛重', sHint); Exit;
  end;

  if StrToFloat(EditPValue.Text) <= 0 then
  begin
    nPV := 'Null';
    nPD := 'Null';
  end else
  begin
    nPV := EditPValue.Text;
    nPD := '''' + DateTime2Str(EditPDate.Date) + '''';
  end;

  if StrToFloat(EditMValue.Text) <= 0 then
  begin
    nMV := 'Null';
    nMD := 'Null';
  end else
  begin
    nMV := EditMValue.Text;
    nMD := '''' + DateTime2Str(EditMDate.Date) + '''';
  end;

  nStr := MakeSQLByStr([SF('P_CusName', EditCusName.Text),
          SF('P_Truck', EditTruck.Text),
          SF('P_MName', EditStock.Text),
          SF('P_PValue', nPV, sfVal),
          SF('P_PDate', nPD, sfVal),
          SF('P_MValue', nMV, sfVal),
          SF('P_MDate', nMD, sfVal)
          ], sTable_PoundLog, SF('P_ID', FPoundID), False);
  FDM.ExecuteSQL(nStr);
  
  Result := True;
  //xxxxx
end;

//Desc: 销售
function TfFormPoundAdjust.SaveSale: Boolean;
var nStr: string;
begin
  nStr := MakeSQLByStr([SF('L_Status', GetCtrlData(EditStatus)),
          SF('L_NextStatus', GetCtrlData(EditNext))
          ], sTable_Bill, SF('L_ID', FBillID), False);
  FDM.ExecuteSQL(nStr);

  Result := True;
  //xxxxx
end;

procedure TfFormPoundAdjust.BtnOKClick(Sender: TObject);
var nRet: Boolean;
begin
  if FPoundType = sFlag_ShipPro then //供应
    nRet := SaveProvide
  else if FPoundType = sFlag_ShipTmp then //临时
    nRet := SaveTemp
  else if FPoundType = sFlag_Sale then //销售
       nRet := SaveSale
  else nRet := False;

  if nRet then
  begin
    ModalResult := mrOk;
    ShowMsg('勘误成功', sHint);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormPoundAdjust, TfFormPoundAdjust.FormID);
end.

{*******************************************************************************
  作者: dmzn@163.com 2014-11-25
  描述: 车辆档案管理
*******************************************************************************}
unit UFormTruck;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxCheckBox;

type
  TfFormTruck = class(TfFormNormal)
    EditTruck: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditOwner: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditPhone: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    CheckValid: TcxCheckBox;
    dxLayout1Item4: TdxLayoutItem;
    CheckVerify: TcxCheckBox;
    dxLayout1Item7: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    dxLayout1Item6: TdxLayoutItem;
    CheckUserP: TcxCheckBox;
    CheckVip: TcxCheckBox;
    dxLayout1Item8: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    CheckGPS: TcxCheckBox;
    dxLayout1Item10: TdxLayoutItem;
    dxLayout1Group4: TdxLayoutGroup;
    EditValue: TcxTextEdit;
    dxLayout1Item11: TdxLayoutItem;
    EditMValueMax: TcxTextEdit;
    dxLayout1Item12: TdxLayoutItem;
    EditWarnPValue: TcxTextEdit;
    dxLayout1Item13: TdxLayoutItem;
    EditHz: TcxTextEdit;
    dxLayout1Item14: TdxLayoutItem;
    EditType: TcxComboBox;
    dxLayout1Item15: TdxLayoutItem;
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
  ULibFun, UMgrControl, UDataModule, UFormCtrl, USysDB, USysConst;

class function TfFormTruck.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormTruck.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '车辆 - 添加';
      FTruckID := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '车辆 - 修改';
      FTruckID := nP.FParamA;
    end;

    LoadFormData(FTruckID); 
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormTruck.FormID: integer;
begin
  Result := cFI_FormTrucks;
end;

procedure TfFormTruck.LoadFormData(const nID: string);
var nStr: string;
begin
  {$IFDEF TruckType}
  EditType.Properties.Items.Clear;

  nStr := 'Select * From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_TruckType]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        EditType.Properties.Items.Add(FieldByName('D_Value').AsString);
        Next;
      end;
    end;
  end;
  {$ELSE}
  dxLayout1Item15.Visible := False;
  {$ENDIF}

  if nID <> '' then
  begin
    nStr := 'Select * From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_Truck, nID]);
    FDM.QueryTemp(nStr);
  end;

  with FDM.SqlTemp do
  begin
    if (nID = '') or (RecordCount < 1) then
    begin
      CheckVerify.Checked := True;
      CheckValid.Checked := True;
      Exit;
    end;

    EditTruck.Text := FieldByName('T_Truck').AsString;
    EditOwner.Text := FieldByName('T_Owner').AsString;
    EditPhone.Text := FieldByName('T_Phone').AsString;

    EditValue.Enabled := gSysParam.FIsAdmin;
    EditValue.Text := FieldByName('T_PrePValue').AsString;
    {$IFDEF TruckMValueMaxControl}
    EditMValueMax.Text := FieldByName('T_MValueMax').AsString;
    {$ELSE}
    dxLayout1Item12.Visible := False;
    {$ENDIF}

    {$IFDEF WarnPValue}
    EditWarnPValue.Text := FieldByName('T_WarnPValue').AsString;
    {$ELSE}
    dxLayout1Item13.Visible := False;
    {$ENDIF}

    {$IFDEF TruckHZValueMax}
    EditHz.Text := FieldByName('T_HZValueMax').AsString;
    {$ELSE}
    dxLayout1Item14.Visible := False;
    {$ENDIF}

    {$IFDEF TruckType}
    EditType.Text := FieldByName('T_CzType').AsString;
    {$ENDIF}

    CheckVerify.Checked := FieldByName('T_NoVerify').AsString = sFlag_No;
    CheckValid.Checked := FieldByName('T_Valid').AsString = sFlag_Yes;
    CheckUserP.Checked := FieldByName('T_PrePUse').AsString = sFlag_Yes;

    CheckVip.Checked   := FieldByName('T_VIPTruck').AsString = sFlag_TypeVIP;
    CheckGPS.Checked   := FieldByName('T_HasGPS').AsString = sFlag_Yes;
  end;
end;

//Desc: 保存
procedure TfFormTruck.BtnOKClick(Sender: TObject);
var nStr,nTruck,nU,nV,nP,nVip,nGps,nEvent: string;
    nVal, nMValMax,nWarnPVal: Double;
begin
  nTruck := UpperCase(Trim(EditTruck.Text));
  if nTruck = '' then
  begin
    ActiveControl := EditTruck;
    ShowMsg('请输入车牌号码', sHint);
    Exit;
  end;

  if FTruckID = '' then
  begin
    nStr := 'Select * From %s where T_Truck=''%s'' ';
    nStr := Format(nStr, [sTable_Truck, nTruck]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount > 0 then
      begin
        ActiveControl := EditTruck;
        ShowMsg('车牌号码已存在', sHint);
        Exit;
      end;
    end;
  end;

  {$IFDEF TruckMValueMaxControl}
  if not IsNumber(EditMValueMax.Text, True) then
  begin
    ActiveControl := EditMValueMax;
    ShowMsg('请输入有效毛重上限', sHint);
    Exit;
  end;
  {$ENDIF}

  {$IFDEF WarnPValue}
  if not IsNumber(EditWarnPValue.Text, True) then
  begin
    ActiveControl := EditWarnPValue;
    ShowMsg('请输入预警皮重', sHint);
    Exit;
  end;
  {$ENDIF}

  {$IFDEF TruckHZValueMax}
  if not IsNumber(EditHz.Text, True) then
  begin
    ActiveControl := EditHz;
    ShowMsg('请输入核载重量', sHint);
    Exit;
  end;
  {$ENDIF}

  if CheckValid.Checked then
       nV := sFlag_Yes
  else nV := sFlag_No;

  if CheckVerify.Checked then
       nU := sFlag_No
  else nU := sFlag_Yes;

  if CheckUserP.Checked then
       nP := sFlag_Yes
  else nP := sFlag_No;

  if CheckVip.Checked then
       nVip:=sFlag_TypeVIP
  else nVip:=sFlag_TypeCommon;

  if CheckGPS.Checked then
       nGps := sFlag_Yes
  else nGps := sFlag_No;

  if FTruckID = '' then
       nStr := ''
  else nStr := SF('R_ID', FTruckID, sfVal);

  nVal := StrToFloatDef(Trim(EditValue.Text), 0);
  nMValMax := StrToFloatDef(Trim(EditMValueMax.Text), 0);
  nWarnPVal := StrToFloatDef(Trim(EditWarnPValue.Text), 0);

  nStr := MakeSQLByStr([SF('T_Truck', nTruck),
          SF('T_Owner', EditOwner.Text),
          SF('T_Phone', EditPhone.Text),
          SF('T_NoVerify', nU),
          SF('T_Valid', nV),
          SF('T_PrePUse', nP),
          SF('T_VIPTruck', nVip),
          SF('T_HasGPS', nGps),
          SF('T_PrePValue', nVal, sfVal),
          {$IFDEF TruckMValueMaxControl}
          SF('T_MValueMax', nMValMax, sfVal),
          {$ENDIF}
          {$IFDEF WarnPValue}
          SF('T_WarnPValue', nWarnPVal, sfVal),
          {$ENDIF}
          {$IFDEF TruckHZValueMax}
          SF('T_HZValueMax', StrToFloatDef(Trim(EditHz.Text), 0), sfVal),
          {$ENDIF}
          {$IFDEF TruckType}
          SF('T_CzType', EditType.Text),
          {$ENDIF}
          SF('T_LastTime', sField_SQLServer_Now, sfVal)
          ], sTable_Truck, nStr, FTruckID = '');
  FDM.ExecuteSQL(nStr);

  if FTruckID='' then
        nEvent := '添加[ %s ]档案信息.'
  else  nEvent := '修改[ %s ]档案信息.';
  nEvent := Format(nEvent, [nTruck]);
  FDM.WriteSysLog(sFlag_CommonItem, nTruck, nEvent);


  ModalResult := mrOk;
  ShowMsg('车辆信息保存成功', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormTruck, TfFormTruck.FormID);
end.

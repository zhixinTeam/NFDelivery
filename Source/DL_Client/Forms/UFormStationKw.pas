{*******************************************************************************
  作者: juner11212436@163.com 2018/03/15
  描述: 火车衡勘误、补录
*******************************************************************************}
unit UFormStationKw;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels, UBusinessConst,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxButtonEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxDropDownEdit, cxLabel,
  dxLayoutcxEditAdapters, cxCheckBox, cxCalendar, ComCtrls, cxListView;

type
  TfFormStationKw = class(TfFormNormal)
    EditKID: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditPValue: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditMValue: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditTruck: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditMID: TcxComboBox;
    dxLayout1Item3: TdxLayoutItem;
    EditPID: TcxComboBox;
    dxLayout1Item5: TdxLayoutItem;
    EditPDate: TcxDateEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditMDate: TcxDateEdit;
    dxLayout1Item11: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
  protected
    { Protected declarations }
    FCardData, FListA: TStrings;
    FPID : string;
    FStation: TLadingBillItems;
    procedure InitFormData;
    //初始化界面
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, DB, IniFiles, UMgrControl, UAdjustForm, UFormBase, UBusinessPacker,
  UDataModule, USysBusiness, USysDB, USysGrid, USysConst,DateUtils, UFormCtrl;


class function TfFormStationKw.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nStr, nPID: string;
    nP: PFormCommandParam;
    nList: TStrings;
    nKw: Boolean;
begin
  Result := nil;
  if GetSysValidDate < 1 then Exit;

  if Assigned(nParam) then
       nP := nParam
  else Exit;

  nPID := nP.FParamA;

  with TfFormStationKw.Create(Application) do
  try
    Caption := '火车衡勘误(补录)';

    FPID := nPID;

    InitFormData;

    if Assigned(nParam) then
    with PFormCommandParam(nParam)^ do
    begin
      FCommand := cCmd_ModalResult;
      FParamA := ShowModal;

      if FParamA = mrOK then
           FParamB := ''
      else FParamB := '';
    end else ShowModal;
  finally
    Free;
  end;
end;

class function TfFormStationKw.FormID: integer;
begin
  Result := cFI_FormStationKw;
end;

procedure TfFormStationKw.FormCreate(Sender: TObject);
begin
  FListA    := TStringList.Create;
  FCardData := TStringList.Create;
  AdjustCtrlData(Self);
  LoadFormConfig(Self);
  dxGroup1.AlignHorz := ahClient;
end;

procedure TfFormStationKw.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveFormConfig(Self);
  ReleaseCtrlData(Self);

  FListA.Free;
  FCardData.Free;
end;

//------------------------------------------------------------------------------
procedure TfFormStationKw.InitFormData;
var nStr: string;
    nIdx: Integer;
    nEx: TDynamicStrArray;
begin
  SetLength(nEx, 1);
  nStr := 'D_ParamB=Select D_ParamB,D_Value From %s Where D_Name=''%s'' ' +
          'And D_Index>=2 Order By D_Index DESC';
  nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem]);

  nEx[0] := 'D_ParamB';
  FDM.FillStringsData(EditMID.Properties.Items, nStr, 0, '', nEx);
  AdjustCXComboBoxItem(EditMID, False);

  nStr := 'P_ID=Select P_ID,P_Name From %s Order By P_ID ASC';
  nStr := Format(nStr, [sTable_Provider]);
  
  nEx[0] := 'P_ID';
  FDM.FillStringsData(EditPID.Properties.Items, nStr, 0, '', nEx);
  AdjustCXComboBoxItem(EditPID, False);

  SetLength(FStation, 1);
  FillChar(FStation[0], SizeOf(TLadingBillItem), #0);

  nStr := 'Select * From %s Where P_ID=''%s''';
  nStr := Format(nStr, [sTable_PoundStation, FPID]);

  with FDM.QueryTemp(nStr),FStation[0] do
  begin
    if RecordCount > 0 then
    begin
      FID         := FieldByName('P_Bill').AsString;
      FZhiKa      := FieldByName('P_Order').AsString;

      FCusID      := FieldByName('P_CusID').AsString;
      FCusName    := FieldByName('P_CusName').AsString;
      FTruck      := FieldByName('P_Truck').AsString;
      FValue      := FieldByName('P_LimValue').AsFloat;

      FType       := FieldByName('P_MType').AsString;
      FStockNo    := FieldByName('P_MID').AsString;
      FStockName  := FieldByName('P_MName').AsString;

      with FPData do
      begin
        FStation  := FieldByName('P_PStation').AsString;
        FValue    := FieldByName('P_PValue').AsFloat;
        FDate     := FieldByName('P_PDate').AsDateTime;
        FOperator := FieldByName('P_PMan').AsString;
      end;

      with FMData do
      begin
        FStation  := FieldByName('P_MStation').AsString;
        FValue    := FieldByName('P_MValue').AsFloat;
        FDate     := FieldByName('P_MDate').AsDateTime;
        FOperator := FieldByName('P_MMan').AsString;
      end;

      FFactory    := FieldByName('P_FactID').AsString;
      FOrigin     := FieldByName('P_Origin').AsString;
      FPModel     := FieldByName('P_PModel').AsString;
      FPType      := FieldByName('P_Type').AsString;
      FPoundID    := FieldByName('P_ID').AsString;

      FStatus     := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckBFP;
      FSelected   := True;

      EditTruck.Text := FTruck;

      EditMID.Text := FStockName;
      EditPID.Text := FCusName;

      EditKID.Text := FOrigin;

      EditPValue.Text := FloatToStr(FPData.FValue);
      EditPDate.Date := FPData.FDate;
      EditMValue.Text := FloatToStr(FMData.FValue);
      EditMDate.Date := FMData.FDate;

      BtnOK.Enabled := True;
    end;
  end;
end;

//Desc: 保存
procedure TfFormStationKw.BtnOKClick(Sender: TObject);
var nStr,nSQL,nPID: string;
    nIdx: Integer;
    nAdd: Double;
begin
  if not QueryDlg('确定要保存数据吗?', sHint) then Exit;

  if not IsNumber(EditPValue.Text,True) then
  begin
    EditPValue.SetFocus;
    nStr := '请输入有效皮重';
    ShowMsg(nStr,sHint);
    Exit;
  end;

  if not IsNumber(EditMValue.Text,True) then
  begin
    EditMValue.SetFocus;
    nStr := '请输入有效毛重';
    ShowMsg(nStr,sHint);
    Exit;
  end;

  if StrToFloat(EditMValue.Text) <= StrToFloat(EditPValue.Text) then
  begin
    EditMValue.SetFocus;
    nStr := '毛重不能小于皮重';
    ShowMsg(nStr,sHint);
    Exit;
  end;

  with FStation[0] do
  begin
    FPData.FValue := StrToFloat(EditPValue.Text);
    FPData.FDate  := EditPDate.Date;
    FPData.FOperator := gSysparam.FUserID;

    FMData.FValue := StrToFloat(EditMValue.Text);
    FMData.FDate  := EditMDate.Date;
    FMData.FOperator := gSysparam.FUserID;

    FTruck := EditTruck.Text;
    FOrigin := EditKID.Text;

    EditMID.Text := Trim(EditMID.Text);
    if EditMID.ItemIndex < 0 then
    begin
      FStockNo := '';
      FStockName := EditMID.Text;
    end else
    begin
      FStockNo := GetCtrlData(EditMID);
      FStockName := EditMID.Text;
    end;

    EditPID.Text := Trim(EditPID.Text);

    if EditPID.ItemIndex < 0 then
    begin
      FCusID := '';
      FCusName := EditPID.Text;
    end else
    begin
      FCusID := GetCtrlData(EditPID);
      FCusName := EditPID.Text;
    end;

    FID := '';
    with FListA do
    begin
      Clear;
      Values['Type']  := sFlag_TypeStation;
      Values['Value'] := FloatToStr(FMData.FValue - FPData.FValue);
    end;
    FID := GetStockBatcode(FStockNo, PackerEncodeStr(FListA.Text));
    if FID = '' then
    begin
      ShowMsg('批次号获取失败',sHint);
      Exit;
    end;
    nAdd := Float2Float(FMData.FValue - FPData.FValue, 100);

    nPID := GetSerialNo(sFlag_BusGroup, sFlag_PStationNo, True);
    if nPID = '' then
    begin
      ShowMsg('磅单号生成失败',sHint);
      Exit;
    end;

    FDM.ADOConn.BeginTrans;
    try
      nStr := MakeSQLByStr([
              SF('P_ID', nPID),
              SF('P_Type', FPType),
              SF('P_Truck', FTruck),
              SF('P_CusID', FCusID),
              SF('P_CusName', FCusName),
              SF('P_MID', FStockNo),
              SF('P_MName', FStockName),
              SF('P_MType', sFlag_San),
              SF('P_PValue', FPData.FValue, sfVal),
              SF('P_PDate', EditPDate.Text),
              SF('P_PMan', FPData.FOperator),
              SF('P_FactID', FFactory),
              SF('P_PStation', FPData.FStation),
              SF('P_MValue', FMData.FValue, sfVal),
              SF('P_MDate', EditMDate.Text),
              SF('P_MMan', FMData.FOperator),
              SF('P_MStation', FMData.FStation),
              SF('P_Direction', '出厂'),
              SF('P_PModel', FPModel),
              SF('P_Status', sFlag_TruckBFP),
              SF('P_Valid', sFlag_Yes),
              SF('P_Order', FZhiKa),              //仓库编号
              SF('P_Origin', FOrigin),            //仓库名称
              SF('P_LimValue', FValue, sfVal),
              SF('P_Bill', FID),                  //批次号
              SF('P_PrintNum', 1, sfVal)
              ], sTable_PoundStation, '', True);
      FDM.ExecuteSQL(nStr);

      nStr := 'Update %s Set B_HasUse=B_HasUse+(%s),B_LastDate=%s ' +
              'Where B_Stock=''%s'' and B_Type=''%s'' ';
      nStr := Format(nStr, [sTable_Batcode, FloatToStr(nAdd),
              sField_SQLServer_Now, FStockNo, sFlag_TypeStation]);
      FDM.ExecuteSQL(nStr); //更新新批次号使用量

      FDM.ADOConn.CommitTrans;
    except
      FDM.ADOConn.RollbackTrans;
      ShowMsg('保存失败', sHint);
      Exit;
    end;
  end;

  ModalResult := mrOK;

  ShowMsg('保存成功', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormStationKw, TfFormStationKw.FormID);
end.

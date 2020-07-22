{*******************************************************************************
  作者: dmzn@163.com 2014-11-25
  描述: 车辆档案管理
*******************************************************************************}
unit UFrameTrucks;

{$I Link.inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  cxContainer, dxLayoutControl, cxMaskEdit, cxButtonEdit, cxTextEdit,
  ADODB, cxLabel, UBitmapPanel, cxSplitter, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, Menus, cxCheckBox;

type
  TfFrameTrucks = class(TfFrameNormal)
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    VIP1: TMenuItem;
    VIP2: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    ChkSnap: TcxCheckBox;
    dxLayout1Item5: TdxLayoutItem;
    N12: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    N15: TMenuItem;
    procedure EditNamePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure PMenu1Popup(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure VIP1Click(Sender: TObject);
    procedure VIP2Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure N11Click(Sender: TObject);
    procedure N12Click(Sender: TObject);
    procedure N14Click(Sender: TObject);
    procedure N15Click(Sender: TObject);
  private
    { Private declarations }
  protected
    function InitFormDataSQL(const nWhere: string): string; override;
    {*查询SQL*}
    function DeleteDirectory(nDir :String): boolean;
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysBusiness, USysConst, USysDB, UDataModule, UFormBase,
  UFormInputbox, ShellAPI, UFormWait;

class function TfFrameTrucks.FrameID: integer;
begin
  Result := cFI_FrameTrucks;
end;

function TfFrameTrucks.InitFormDataSQL(const nWhere: string): string;
begin
  {$IFDEF FixLoad}
  N10.Visible := True;
  N11.Visible := True;
  {$ENDIF}
  if ChkSnap.Checked then
    Result := 'Select * From ' + sTable_TruckSnap
  else
    Result := 'Select * From ' + sTable_Truck;
  if nWhere <> '' then
    Result := Result + ' Where (' + nWhere + ')';
  Result := Result + ' Order By T_PY';
end;

//Desc: 添加
procedure TfFrameTrucks.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormTrucks, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: 修改
procedure TfFrameTrucks.BtnEditClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nP.FCommand := cCmd_EditData;
    nP.FParamA := SQLQuery.FieldByName('R_ID').AsString;
    CreateBaseFormItem(cFI_FormTrucks, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;
  end;
end;

//Desc: 删除
procedure TfFrameTrucks.BtnDelClick(Sender: TObject);
var nStr,nTruck,nEvent: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nTruck := SQLQuery.FieldByName('T_Truck').AsString;
    nStr   := Format('确定要删除车辆[ %s ]吗?', [nTruck]);
    if not QueryDlg(nStr, sAsk) then Exit;

    nStr := 'Delete From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_Truck, SQLQuery.FieldByName('R_ID').AsString]);

    FDM.ExecuteSQL(nStr);

    nEvent := '删除[ %s ]档案信息.';
    nEvent := Format(nEvent, [nTruck]);
    FDM.WriteSysLog(sFlag_CommonItem, nTruck, nEvent);

    InitFormData(FWhere);
  end;
end;

procedure TfFrameTrucks.PMenu1Popup(Sender: TObject);
begin
  N2.Enabled := BtnEdit.Enabled;
end;

//Desc: 车辆签到
procedure TfFrameTrucks.N2Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := 'Update %s Set T_LastTime=getDate() Where R_ID=%s';
    nStr := Format(nStr, [sTable_Truck, SQLQuery.FieldByName('R_ID').AsString]);

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
    ShowMsg('签到成功', sHint);
  end;
end;

//Desc: 查询
procedure TfFrameTrucks.EditNamePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := Format('T_Truck Like ''%%%s%%''', [EditName.Text]);
    InitFormData(FWhere);
  end;
end;

//办理电子标签
procedure TfFrameTrucks.N4Click(Sender: TObject);
var nStr, nRFIDCard, nFlag: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('T_Truck').AsString;
    nRFIDCard := SQLQuery.FieldByName('T_Card').AsString;
    nFlag := SQLQuery.FieldByName('T_CardUse').AsString;
    
    if SetTruckRFIDCard(nStr, nRFIDCard, nFlag, nRFIDCard) then
    begin
      nStr := 'Update %s Set T_Card=null,T_CardUse=''%s''  Where T_Card=''%s''';
      nStr := Format(nStr, [sTable_Truck, {nRFIDCard,} nFlag,
        nRFIDCard]);
      //xxxxxx

      FDM.ExecuteSQL(nStr);//将已经绑定该标签的电子签清除

      nStr := 'Update %s Set T_Card=''%s'',T_CardUse=''%s''  Where R_ID=%s';
      nStr := Format(nStr, [sTable_Truck, nRFIDCard, nFlag,
        SQLQuery.FieldByName('R_ID').AsString]);
      //xxxxxx

      FDM.ExecuteSQL(nStr);
      InitFormData(FWhere);
      ShowMsg('办理电子标签成功', sHint);
    end;
  end;
end;


//启用电子标签
procedure TfFrameTrucks.N5Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := 'Update %s Set T_CardUse=''%s'' Where R_ID=%s';
    nStr := Format(nStr, [sTable_Truck, sFlag_Yes,
      SQLQuery.FieldByName('R_ID').AsString]);
    //xxxxxx

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
    ShowMsg('启用电子标签成功', sHint);
  end;
end;

procedure TfFrameTrucks.N7Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := 'Update %s Set T_CardUse=''%s'' Where R_ID=%s';
    nStr := Format(nStr, [sTable_Truck, sFlag_No,
      SQLQuery.FieldByName('R_ID').AsString]);
    //xxxxxx

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
    ShowMsg('停用电子标签成功', sHint);
  end;
end;

procedure TfFrameTrucks.VIP1Click(Sender: TObject);
var nStr: string;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := 'Update %s Set T_VIPTruck=''%s'' Where R_ID=%s';
    nStr := Format(nStr, [sTable_Truck, sFlag_TypeVIP,
      SQLQuery.FieldByName('R_ID').AsString]);
    //xxxxxx

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
    ShowMsg('设置车辆VIP成功', sHint);
  end;
end;

procedure TfFrameTrucks.VIP2Click(Sender: TObject);
var nStr: string;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := 'Update %s Set T_VIPTruck=''%s'' Where R_ID=%s';
    nStr := Format(nStr, [sTable_Truck, sFlag_TypeCommon,
      SQLQuery.FieldByName('R_ID').AsString]);
    //xxxxxx

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
    ShowMsg('关闭车辆VIP成功', sHint);
  end;
end;

procedure TfFrameTrucks.N8Click(Sender: TObject);
var nTruck,nMID,nMate,nSrc,nDst: string;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nSrc := SQLQuery.FieldByName('T_SrcAddr').AsString;
    nDst := SQLQuery.FieldByName('T_DestAddr').AsString;
    nTruck:= SQLQuery.FieldByName('T_Truck').AsString;

    nMID  := SQLQuery.FieldByName('T_MateID').AsString;
    nMate := SQLQuery.FieldByName('T_MateName').AsString;

    if SaveTransferInfo(nTruck, nMID, nMate, nSrc, nDst) then
      ShowMsg('短倒业务磁卡保存成功', sHint);

    InitFormData(FWhere);
  end;
end;

procedure TfFrameTrucks.N10Click(Sender: TObject);
var nStr,nTruck: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('T_HisValueMax').AsString;

    if StrToFloatDef(nStr, 0) <= 0 then
      nStr := Format('%.2f', [GetTruckHisValueMax(SQLQuery.FieldByName('T_Truck').AsString)]);

    nTruck := nStr;
    if not ShowInputBox('请输入新的历史最大提货量:', '修改', nTruck, 15) then Exit;

    if (nTruck = '') or (nStr = nTruck) then Exit;
    //无效或一致
    if not IsNumber(nTruck, True) then  Exit;

    nStr := 'Update %s Set T_HisValueMax=''%s'' Where R_ID=%s';
    nStr := Format(nStr, [sTable_Truck, nTruck,
      SQLQuery.FieldByName('R_ID').AsString]);
    //xxxxxx

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
    ShowMsg('修改历史最大提货量成功', sHint);
  end;
end;

procedure TfFrameTrucks.N11Click(Sender: TObject);
var nStr,nTruck: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('T_HisMValueMax').AsString;

    if StrToFloatDef(nStr, 0) <= 0 then
      nStr := Format('%.2f', [GetTruckHisMValueMax(SQLQuery.FieldByName('T_Truck').AsString)]);

    nTruck := nStr;
    if not ShowInputBox('请输入新的历史最大毛重:', '修改', nTruck, 15) then Exit;

    if (nTruck = '') or (nStr = nTruck) then Exit;
    //无效或一致
    if not IsNumber(nTruck, True) then  Exit;

    nStr := 'Update %s Set T_HisMValueMax=''%s'' Where R_ID=%s';
    nStr := Format(nStr, [sTable_Truck, nTruck,
      SQLQuery.FieldByName('R_ID').AsString]);
    //xxxxxx

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
    ShowMsg('修改历史最大毛重成功', sHint);
  end;
end;

procedure TfFrameTrucks.N12Click(Sender: TObject);
var nStr,nID,nDir: string;
    nPic: TPicture;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要查看的记录', sHint);
    Exit;
  end;

  nID := SQLQuery.FieldByName('R_ID').AsString;
  nDir := gSysParam.FPicPath + nID + '\';

  DeleteDirectory(gSysParam.FPicPath + nID);
  if DirectoryExists(nDir) then
  begin
    ShellExecute(GetDesktopWindow, 'open', PChar(nDir), nil, nil, SW_SHOWNORMAL);
    Exit;
  end else ForceDirectories(nDir);

  nPic := nil;
  nStr := 'Select * From %s Where P_ID=''%s''';
  nStr := Format(nStr, [sTable_Picture, nID]);

  ShowWaitForm(ParentForm, '读取图片', True);
  try
    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
      begin
        ShowMsg('本次预制无抓拍', sHint);
        Exit;
      end;

      nPic := TPicture.Create;
      First;

      While not eof do
      begin
        nStr := nDir + Format('%s_%s.jpg', [FieldByName('P_ID').AsString,
                FieldByName('R_ID').AsString]);
        //xxxxx

        FDM.LoadDBImage(FDM.SqlTemp, 'P_Picture', nPic);
        nPic.SaveToFile(nStr);
        Next;
      end;
    end;

    ShellExecute(GetDesktopWindow, 'open', PChar(nDir), nil, nil, SW_SHOWNORMAL);
    //open dir
  finally
    nPic.Free;
    CloseWaitForm;
    FDM.SqlTemp.Close;
  end;
end;

function TfFrameTrucks.DeleteDirectory(nDir :String): boolean;
var
f: TSHFILEOPSTRUCT;
begin
  FillChar(f, SizeOf(f), 0);
  with f do
  begin
    Wnd := 0;
    wFunc := FO_DELETE;
    pFrom := PChar(nDir+#0);
    pTo := PChar(nDir+#0);
    fFlags := FOF_ALLOWUNDO+FOF_NOCONFIRMATION+FOF_NOERRORUI;
  end;
  Result := (SHFileOperation(f) = 0);
end;

procedure TfFrameTrucks.N14Click(Sender: TObject);
var
  nP: TFormCommandParam;
  nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := Trim(SQLQuery.FieldByName('T_DriverCard').AsString);
    if nStr <> '' then
    begin
      ShowMsg('该车已经绑定过磁卡,请勿重复绑定.',sHint);
      Exit;
    end;
    
    //nP.FCommand := cCmd_EditData;
    nP.FParamA := SQLQuery.FieldByName('T_Truck').AsString;
    CreateBaseFormItem(cFI_FormTruckCard, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;
  end;
end;

procedure TfFrameTrucks.N15Click(Sender: TObject);
var
  nStr, nSQL, nTruck: string;
  nList: TStrings;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nTruck := Trim(SQLQuery.FieldByName('T_Truck').AsString);
    nStr := Trim(SQLQuery.FieldByName('T_DriverCard').AsString);

    if nStr = '' then exit;
    if not QueryDlg('确定要取消车辆 ['+nTruck+'] 的关联的长期卡吗？', sAsk) then Exit;

    try
      FDM.ADOConn.BeginTrans;

      nSQL := 'update %s set T_DriverCard=''%s'' where t_truck=''%s''';
      nSQL := Format(nSQL,[sTable_Truck,'',nTruck]);
      FDM.ExecuteSQL(nSQL);

      FDM.ADOConn.CommitTrans;

      nStr := '取消车辆 [ '+ nTruck +' ]与磁卡[ '+nStr+' ]的关联';
      FDM.WriteSysLog(sFlag_TruckItem,nTruck,nStr);
      ShowMsg(nStr, sHint);

      InitFormData(FWhere);
    except
      FDM.ADOConn.RollbackTrans;
      ShowMsg('取消关联失败.', sHint);
    end;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameTrucks, TfFrameTrucks.FrameID);
end.

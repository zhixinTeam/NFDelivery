{*******************************************************************************
  ����: fendou116688@163.com 2017/6/2
  ����: ��ʱҵ��쿨(����ģʽ)
*******************************************************************************}
unit UFrameCardTemp;

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
  TfFrameCardTemp = class(TfFrameNormal)
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
    //ʱ������
    FUseDate: Boolean;
    //ʹ������
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    procedure AfterInitFormData; override;
    {*��ѯSQL*}
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
class function TfFrameCardTemp.FrameID: integer;
begin
  Result := cFI_FrameCardTemp;
end;

procedure TfFrameCardTemp.OnCreateFrame;
begin
  inherited;
  FUseDate := True;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameCardTemp.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

//Desc: ���ݲ�ѯSQL
function TfFrameCardTemp.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);
  Result := 'Select * From $DD ';

  if (nWhere = '') or FUseDate then
  begin
    if CheckDelete.Checked then
         Result := Result + 'Where (O_DelDate>=''$ST'' and O_DelDate <''$End'')'
    else Result := Result + 'Where (O_Date>=''$ST'' and O_Date <''$End'')';
    nStr := ' And ';
  end else nStr := ' Where ';

  if nWhere <> '' then
    Result := Result + nStr + '(' + nWhere + ')';
  //xxxxx

  Result := MacroValue(Result, [
            MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx

  if CheckDelete.Checked then
       Result := MacroValue(Result, [MI('$DD', sTable_CardOtherBak)])
  else Result := MacroValue(Result, [MI('$DD', sTable_CardOther)]);
end;

procedure TfFrameCardTemp.AfterInitFormData;
begin
  FUseDate := True;
end;

//Desc: ִ�в�ѯ
procedure TfFrameCardTemp.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FUseDate := Length(EditTruck.Text) <= 3;
    FWhere := Format('O_Truck like ''%%%s%%''', [EditTruck.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditCusName then
  begin
    EditCusName.Text := Trim(EditCusName.Text);
    if EditCusName.Text = '' then Exit;

    FWhere := Format('O_CusPY like ''%%%s%%'' or O_CusName Like''%%%s%%''',
              [EditTruck.Text, EditTruck.Text]);
    InitFormData(FWhere);
  end;
end;

//Desc: ����ɸѡ
procedure TfFrameCardTemp.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

//Desc: ��ѯɾ��
procedure TfFrameCardTemp.CheckDeleteClick(Sender: TObject);
begin
  InitFormData('');
end;

//------------------------------------------------------------------------------
//Desc: �������
procedure TfFrameCardTemp.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormCardTemp, PopedomItem, @nP);
  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: ɾ��
procedure TfFrameCardTemp.BtnDelClick(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫɾ���ļ�¼', sHint); Exit;
  end;

  nStr := 'ȷ��Ҫɾ�����Ϊ[ %s ]�ĵ�����?';
  nStr := Format(nStr, [SQLQuery.FieldByName('R_ID').AsString]);
  if not QueryDlg(nStr, sAsk) then Exit;

  if DeleteCardOther(SQLQuery.FieldByName('R_ID').AsString) then
  begin
    InitFormData(FWhere);
    ShowMsg('������ɾ��', sHint);
  end;
end;

//ע���ſ�
procedure TfFrameCardTemp.N1Click(Sender: TObject);
var nStr,nCard: string;
begin
  nCard := SQLQuery.FieldByName('O_Card').AsString;
  nStr := Format('ȷ��Ҫ�Կ�[ %s ]ִ������������?', [nCard]);
  if not QueryDlg(nStr, sAsk) then Exit;

  FDM.ADOConn.BeginTrans;
  try
    nStr := 'Update %s Set O_Card=NULL Where R_ID=%s';
    nStr := Format(nStr, [sTable_CardOther, SQLQuery.FieldByName('R_ID').AsString]);
    FDM.ExecuteSQL(nStr);

    nStr := 'Update %s Set C_Status=''%s'' Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, sFlag_CardInvalid, nCard]);
    FDM.ExecuteSQL(nStr);

    FDM.ADOConn.CommitTrans;
    InitFormData(FWhere);
    ShowMsg('ע�������ɹ�', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    raise;
  end;
end;

//����ſ�
procedure TfFrameCardTemp.N2Click(Sender: TObject);
var nP: TFormCommandParam;
    nSQL, nStr, nCard, nCardKeep, nTruck: string;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount < 1 then Exit;

  nStr := SQLQuery.FieldByName('O_Card').AsString;
  if nStr <> '' then
  begin
    ShowMsg('����ע���ſ�', sHint);
    Exit;
  end;

  CreateBaseFormItem(cFI_FormReadCard, '', @nP);
  if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
  nCard := nP.FParamB;

  nStr := SQLQuery.FieldByName('R_ID').AsString;
  nTruck := SQLQuery.FieldByName('O_Truck').AsString;
  nCardKeep := SQLQuery.FieldByName('O_KeepCard').AsString;

  FDM.ADOConn.BeginTrans;
  try
    nSQL := 'Update %s Set P_Card=NULL, P_CType=NULL Where P_Card=''%s''';
    nSQL := Format(nSQL, [sTable_ProvBase, nCard]);
    FDM.ExecuteSQL(nSQL);
    //����ʹ�õĲɹ�����

    nSQL := 'Update %s Set L_Card=NULL Where L_Card=''%s''';
    nSQL := Format(nSQL, [sTable_Bill, nCard]);
    FDM.ExecuteSQL(nSQL);
    //����ʹ�õ����������

    nSQL := 'Update %s Set P_Card=NULL Where P_Card=''%s''';
    nSQL := Format(nSQL, [sTable_CardProvide, nCard]);
    FDM.ExecuteSQL(nSQL);
    //����ʹ�õĲɹ�ҵ��

    nSQL := 'Update %s Set O_Card=NULL Where O_Card=''%s''';
    nSQL := Format(nSQL, [sTable_CardOther, nCard]);
    FDM.ExecuteSQL(nSQL);
    //����ʹ�õ���ʱҵ��

    nSQL := 'Update %s Set O_Card=''%s'' Where R_ID=%s';
    nSQL := Format(nSQL, [sTable_CardOther, nCard, nStr]);
    FDM.ExecuteSQL(nSQL);
    //����ʹ�õ���ʱҵ��

    nSQL := 'Select Count(*) From %s Where C_Card=''%s''';
    nSQL := Format(nSQL, [sTable_Card, nCard]);

    with FDM.QuerySQL(nSQL) do
    if Fields[0].AsInteger < 1 then
    begin
      nSQL := MakeSQLByStr([SF('C_Card', nCard),
              SF('C_Group', nCardKeep),
              SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_ShipTmp),
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
              SF('C_Group', nCardKeep),
              SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_ShipTmp),
              SF('C_Freeze', sFlag_No),
              SF('C_TruckNo', nTruck),
              SF('C_Man', gSysParam.FUserID),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, nSQL, False);
      FDM.ExecuteSQL(nSQL);
    end;
    //���´ſ�״̬

    FDM.ADOConn.CommitTrans;
    InitFormData(FWhere);
    ShowMsg('����ſ��ɹ�', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    raise;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameCardTemp, TfFrameCardTemp.FrameID);
end.

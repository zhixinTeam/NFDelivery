{*******************************************************************************
  ����: dmzn@163.com 2017-07-20
  ����: ��������
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
    //������
    FPoundType: string;
    //��������
    FBillID: string;
    //������
    procedure LoadFormData(const nID: string);
    //��ʼ������
    function SaveProvide: Boolean;
    function SaveTemp: Boolean;
    function SaveSale: Boolean;
    //��������
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
    Caption := '���� - ����';
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
      ShowMsg('��������Ч', sHint);
      Exit;
    end;

    FPoundType := FieldByName('P_Type').AsString;
    //����,��Ӧ��
    FBillID := FieldByName('P_Bill').AsString;
    //������,������

    EditID.Text := FieldByName('P_ID').AsString;
    EditCusName.Text := FieldByName('P_CusName').AsString;
    EditStock.Text := FieldByName('P_MName').AsString;
    EditTruck.Text := FieldByName('P_Truck').AsString;

    EditPValue.Text := FieldByName('P_PValue').AsString;
    EditPDate.Date := FieldByName('P_PDate').AsDateTime;
    EditMValue.Text := FieldByName('P_MValue').AsString;
    EditMDate.Date := FieldByName('P_MDate').AsDateTime;
  end;

  if FPoundType = sFlag_ShipPro then //��Ӧ
  begin
    nStr := 'Select P_Status,P_NextStatus From %s Where P_Pound=''%s''';
    nStr := Format(nStr, [sTable_CardProvide, FPoundID]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
      begin
        SetCtrlData(EditStatus, sFlag_TruckOut);
        EditMemo.Text := '�ɹ�ҵ���ѳ���,����NC����.';
        Exit;
      end;

      SetCtrlData(EditStatus, FieldByName('P_Status').AsString);
      SetCtrlData(EditNext, FieldByName('P_NextStatus').AsString);
      EditMemo.Text := '�ɹ�ҵ��,�����ڳ���';
    end;
  end;

  if FPoundType = sFlag_Sale then //����
  begin
    nStr := 'Select L_Status,L_NextStatus From %s Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, FBillID]);

    with FDM.QueryTemp(nStr) do
    begin
      if (RecordCount < 1) or
         (FieldByName('L_Status').AsString = sFlag_TruckOut) then
      begin
        SetCtrlData(EditStatus, sFlag_TruckOut);
        EditMemo.Text := '����ҵ���ѳ���,����NC����.';
        Exit;
      end;

      SetCtrlData(EditStatus, FieldByName('L_Status').AsString);
      SetCtrlData(EditNext, FieldByName('L_NextStatus').AsString);
      EditMemo.Text := '����ҵ��,�����ڳ���,ֻ���޸�״̬';
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

//Desc: ��Ӧ
function TfFormPoundAdjust.SaveProvide: Boolean;
var nStr,nPV,nPD,nMV,nMD: string;
begin
  Result := False;
  if not IsNumber(EditPValue.Text, True) then
  begin
    EditPValue.SetFocus;
    ShowMsg('������Ƥ��', sHint); Exit;
  end;

  if not IsNumber(EditMValue.Text, True) then
  begin
    EditMValue.SetFocus;
    ShowMsg('������ë��', sHint); Exit;
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

//Desc: ��ʱ
function TfFormPoundAdjust.SaveTemp: Boolean;
var nStr,nPV,nPD,nMV,nMD: string;
begin
  Result := False;
  if not IsNumber(EditPValue.Text, True) then
  begin
    EditPValue.SetFocus;
    ShowMsg('������Ƥ��', sHint); Exit;
  end;

  if not IsNumber(EditMValue.Text, True) then
  begin
    EditMValue.SetFocus;
    ShowMsg('������ë��', sHint); Exit;
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

//Desc: ����
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
  if FPoundType = sFlag_ShipPro then //��Ӧ
    nRet := SaveProvide
  else if FPoundType = sFlag_ShipTmp then //��ʱ
    nRet := SaveTemp
  else if FPoundType = sFlag_Sale then //����
       nRet := SaveSale
  else nRet := False;

  if nRet then
  begin
    ModalResult := mrOk;
    ShowMsg('����ɹ�', sHint);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormPoundAdjust, TfFormPoundAdjust.FormID);
end.

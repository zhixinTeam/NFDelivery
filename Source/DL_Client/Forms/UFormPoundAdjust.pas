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
  TPoundInfo = record
    FPoundId:string;
    FPBill:string;
    FPOrder:string;
    FCusId:String;
    FCusName:String;
    FStockno:String;
    FStock:String;
    FTruck:String;
    FPValue:Double;
    FPDate:TDateTime;
    FMValue:Double;
    FMDate:TDateTime;
    FStatus:string;
    FNextStatus:string;
    FMType:string;
  end;

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
    EditCusID: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditStockno: TcxTextEdit;
    dxLayout1Item11: TdxLayoutItem;
    BtnSelect: TButton;
    EditRID: TcxTextEdit;
    dxLayout1Item12: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure BtnSelectClick(Sender: TObject);
    procedure EditRIDPropertiesChange(Sender: TObject);
  protected
    { Protected declarations }
    FPoundID: string;
    //������
    FPoundType: string;
    //��������
    FBillID: string;
    //������
    FOrderId:string;//�ɹ�����

    FOldInfo:TPoundInfo;

    procedure LoadFormData(const nID: string);
    //��ʼ������
    function SaveProvide: Boolean;
    function SaveTemp: Boolean;
    function SaveSale: Boolean;
    //��������
    procedure WriteSysLog(const nID:string);
    //��¼������־
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
    dxLayout1Item12.Visible := False;
    Caption := '���� - ����';
    FPoundID := nP.FParamA;

    ZeroMemory(@Foldinfo,SizeOf(TPoundInfo));

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
    FOrderId := FieldByName('P_Order').AsString;
    
    EditID.Text := FieldByName('P_ID').AsString;
    EditCusId.Text := FieldByName('p_cusid').AsString;
    EditCusName.Text := FieldByName('P_CusName').AsString;
    EditStockno.Text := FieldByName('P_MID').AsString;
    EditStock.Text := FieldByName('P_MName').AsString;
    EditTruck.Text := FieldByName('P_Truck').AsString;

    EditPValue.Text := FieldByName('P_PValue').AsString;
    EditPDate.Date := FieldByName('P_PDate').AsDateTime;
    EditMValue.Text := FieldByName('P_MValue').AsString;
    EditMDate.Date := FieldByName('P_MDate').AsDateTime;
    with FOldInfo do
    begin
      FPoundId := EditID.Text;
      FPBill := FBillID;
      FPOrder := FOrderId;
      FCusId := EditCusId.Text;
      FCusName := EditCusName.Text;
      FStockno := EditStockno.Text;
      FStock := EditStock.Text;
      FTruck := EditTruck.Text;
      FPValue := FieldByName('P_PValue').AsFloat;
      FPDate := FieldByName('P_PDate').AsDateTime;
      FMValue := FieldByName('P_MValue').AsFloat;
      FMDate := FieldByName('P_MDate').AsDateTime;
      FMType := FieldByName('P_MType').AsString;
    end;
  end;

  if FPoundType = sFlag_ShipPro then //��Ӧ
  begin
    dxLayout1Item12.Visible := True;
    nStr := 'Select P_Status,P_NextStatus From %s Where P_Pound=''%s''';
    nStr := Format(nStr, [sTable_CardProvide, FPoundID]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
      begin
        FOldInfo.FStatus := sFlag_TruckOut;
        SetCtrlData(EditStatus, sFlag_TruckOut);
        EditMemo.Text := '�ɹ�ҵ���ѳ���,����NC����.';
        EditPValue.Enabled := False;
        EditPDate.Enabled := False;
        EditMValue.Enabled := False;
        EditMDate.Enabled := False;
        EditStatus.Enabled := False;
        EditNext.Enabled := False;
        BtnOK.Enabled := True;
        Exit;
      end;

      SetCtrlData(EditStatus, FieldByName('P_Status').AsString);
      SetCtrlData(EditNext, FieldByName('P_NextStatus').AsString);
      EditMemo.Text := '�ɹ�ҵ��,�����ڳ���';
      FOldInfo.FStatus := FieldByName('P_Status').AsString;
      FOldInfo.FNextStatus := FieldByName('P_NextStatus').AsString;
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
        FOldInfo.FStatus := sFlag_TruckOut;
        BtnOK.Enabled := True;
        Exit;
      end;

      SetCtrlData(EditStatus, FieldByName('L_Status').AsString);
      SetCtrlData(EditNext, FieldByName('L_NextStatus').AsString);
      EditMemo.Text := '����ҵ��,�����ڳ���,ֻ���޸�״̬';
      FOldInfo.FStatus := FieldByName('L_Status').AsString;
      FOldInfo.FNextStatus := FieldByName('L_NextStatus').AsString;      
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
  nEvent:string;
  nRid,nporder:string;
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
  
  if FOldInfo.FStatus=sFlag_TruckOut then
  begin
    nRid := Trim(EditRID.Text);
    if nRid='' then
    begin
      EditRID.SetFocus;
      ShowMsg('�������¼��ţ���Ӧ��ѯ�еļ�¼��ţ�', sHint); Exit;
    end;
  end;

  if nRid<>'' then
  begin
    nStr := 'select * from %s where r_id=%s';
    nStr := Format(nStr,[sTable_CardProvide,nRid]);
    with FDM.QuerySQL(nStr) do
    begin
      if RecordCount<=0 then
      begin
        EditRID.SetFocus;
        ShowMsg('������ļ�¼��Ų�����',sError); Exit;
      end;
      nporder := FieldByName('p_order').AsString;
      if nporder<>FOldInfo.FPOrder then
      begin
        EditRID.SetFocus;
        ShowMsg('������ļ�¼��Ų�����',sError); Exit;      
      end;
    end;
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

  FDM.ADOConn.BeginTrans;
  try
    nStr := MakeSQLByStr([SF('P_CusName', EditCusName.Text),
            SF('P_CusId', EditCusID.Text),
            SF('P_Truck', EditTruck.Text),
            SF('P_MID', EditStockno.Text),
            SF('P_MName', EditStock.Text),
            SF('P_PValue', nPV, sfVal),
            SF('P_PDate', nPD, sfVal),
            SF('P_MValue', nMV, sfVal),
            SF('P_MDate', nMD, sfVal)
            ], sTable_PoundLog, SF('P_ID', FPoundID), False);
    FDM.ExecuteSQL(nStr);
    //δ����
    if FOldInfo.FStatus<>sFlag_TruckOut then
    begin
      nStr := MakeSQLByStr([SF('P_Status', GetCtrlData(EditStatus)),
              SF('P_NextStatus', GetCtrlData(EditNext)),
              SF('p_cusid', GetCtrlData(EditCusID)),
              SF('p_cusname', GetCtrlData(EditCusName)),
              SF('p_MID', GetCtrlData(EditStockno)),
              SF('p_Mname', GetCtrlData(EditStock)),
              SF('p_Truck', GetCtrlData(Edittruck)),
              SF('p_bfpvalue', nPV, sfVal),
              SF('p_bfptime', nPD, sfVal),
              SF('p_bfmvalue', nMV, sfVal),
              SF('p_bfmtime', nMD, sfVal)
              ], sTable_CardProvide, SF('p_pound', FpoundId), False);
    end
    else begin
      nStr := MakeSQLByStr([SF('P_Status', GetCtrlData(EditStatus)),
              SF('P_NextStatus', GetCtrlData(EditNext)),
              SF('p_cusid', GetCtrlData(EditCusID)),
              SF('p_cusname', GetCtrlData(EditCusName)),
              SF('p_MID', GetCtrlData(EditStockno)),
              SF('p_Mname', GetCtrlData(EditStock)),
              SF('p_Truck', GetCtrlData(Edittruck)),
              SF('p_bfpvalue', nPV, sfVal),
              SF('p_bfptime', nPD, sfVal),
              SF('p_bfmvalue', nMV, sfVal),
              SF('p_bfmtime', nMD, sfVal)
              ], sTable_CardProvide, SF('r_id', nRid), False);    
    end;

    FDM.ExecuteSQL(nStr);

    WriteSysLog(FPoundID);
        
    fdm.ADOConn.CommitTrans;
    Result := True;
    //xxxxx
  except
    FDM.ADOConn.RollbackTrans;
  end;
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
          SF('P_MID', EditStockno.Text),
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
var nStr,nPV,nPD,nMV,nMD: string;
  nEvent:string;
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
  
  FDM.ADOConn.BeginTrans;
  try
    nStr := MakeSQLByStr([SF('P_CusName', EditCusName.Text),
            SF('p_cusid', EditCusID.Text),
            SF('P_Truck', EditTruck.Text),
            SF('P_MID', EditStockno.Text),
            SF('P_MName', EditStock.Text),
            SF('P_PValue', nPV, sfVal),
            SF('P_PDate', nPD, sfVal),
            SF('P_MValue', nMV, sfVal),
            SF('P_MDate', nMD, sfVal)
            ], sTable_PoundLog, SF('P_ID', FPoundID), False);
    FDM.ExecuteSQL(nStr);

    if (nPV='Null') or (nMV='Null') then
    begin
      nStr := MakeSQLByStr([SF('L_Status', GetCtrlData(EditStatus)),
              SF('L_NextStatus', GetCtrlData(EditNext)),
              SF('l_cusid',GetCtrlData(EditCusID)),
              SF('L_CusName', GetCtrlData(EditCusName)),
              SF('L_StockNo', GetCtrlData(EditStockno)),
              SF('L_StockName', GetCtrlData(EditStock)),
              SF('L_Truck', GetCtrlData(EditTruck)),
              SF('l_pvalue', nPV, sfVal),
              SF('l_pdate', nPD, sfVal),
              SF('l_mvalue', nMV, sfVal),
              SF('l_mdate', nMD, sfVal)
              ], sTable_Bill, SF('L_ID', FBillID), False);
    end
    else if FOldInfo.FMType=sFlag_San then
    begin
      nStr := MakeSQLByStr([SF('L_Status', GetCtrlData(EditStatus)),
              SF('L_NextStatus', GetCtrlData(EditNext)),
              SF('l_cusid',GetCtrlData(EditCusID)),
              SF('L_CusName', GetCtrlData(EditCusName)),
              SF('L_StockNo', GetCtrlData(EditStockno)),
              SF('L_StockName', GetCtrlData(EditStock)),
              SF('L_Truck', GetCtrlData(EditTruck)),
              SF('l_pvalue', nPV, sfVal),
              SF('l_pdate', nPD, sfVal),
              SF('l_mvalue', nMV, sfVal),
              SF('l_mdate', nMD, sfVal),
              SF('l_value', FloatToStr(StrToFloat(nMV)-StrToFloat(nPV)), sfVal)
              ], sTable_Bill, SF('L_ID', FBillID), False);    
    end else if FOldInfo.FMType=sFlag_Dai then
    begin
      nStr := MakeSQLByStr([SF('L_Status', GetCtrlData(EditStatus)),
              SF('L_NextStatus', GetCtrlData(EditNext)),
              SF('l_cusid',GetCtrlData(EditCusID)),
              SF('L_CusName', GetCtrlData(EditCusName)),
              SF('L_StockNo', GetCtrlData(EditStockno)),
              SF('L_StockName', GetCtrlData(EditStock)),
              SF('L_Truck', GetCtrlData(EditTruck)),
              SF('l_pvalue', nPV, sfVal),
              SF('l_pdate', nPD, sfVal),
              SF('l_mvalue', nMV, sfVal),
              SF('l_mdate', nMD, sfVal)
              ], sTable_Bill, SF('L_ID', FBillID), False);
    end;
    FDM.ExecuteSQL(nStr);

    nStr := MakeSQLByStr([SF('T_Truck', EditTruck.Text),
            SF('T_StockNo', EditStockno.Text),
            SF('T_Stock', EditStock.Text)
            ], sTable_ZTTrucks, SF('T_Bill', FBillID), False);
    FDM.ExecuteSQL(nStr);

    WriteSysLog(FPoundID);

    Result := True;
    fdm.ADOConn.CommitTrans;
  except
    Fdm.ADOConn.RollbackTrans;
  end;
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

procedure TfFormPoundAdjust.WriteSysLog(const nID: string);
var nEvent: string;
begin
  if nID='' then Exit;
  nEvent := '���� [%s]��¼���[%s] ��Ϣ�� [�ͻ�:%s-%s,Ʒ��:%s-%s,����:%s,Ƥ��:%f,Ƥ��ʱ��:%s,'
    +'ë��:%f,ë��ʱ��:%s,״̬:%s,��һ״̬:%s] ���Ϊ [�ͻ�:%s-%s,Ʒ��:%s-%s,'
    +'����:%s,Ƥ��:%f,Ƥ��ʱ��:%s,ë��:%f,ë��ʱ��:%s,״̬:%s,��һ״̬:%s] ';
  nEvent := Format(nEvent,[FOldInfo.FPoundId,EditRID.Text,FOldInfo.FCusId,FOldInfo.FCusName,FOldInfo.FStockno,FOldInfo.FStock,
    FOldInfo.FTruck,FOldInfo.FPValue,DateTime2Str(FOldInfo.FPDate),FOldInfo.FMValue,
    DateTime2Str(FOldInfo.FMDate),FOldInfo.FStatus,FOldInfo.FNextStatus,
    EditCusID.Text,EditCusName.Text,EditStockno.Text,EditStock.Text,EditTruck.Text,StrToFloatDef(EditPValue.Text,0),
    DateTime2Str(EditPDate.Date),StrToFloatDef(EditMValue.Text,0),
    DateTime2Str(EditMDate.Date),GetCtrlData(EditStatus),GetCtrlData(EditNext)]);
  FDM.WriteSysLog(sFlag_PoundCorrections, 'UFormPoundAdjust',nEvent);
end;

procedure TfFormPoundAdjust.BtnSelectClick(Sender: TObject);
var
  nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_EditData;
  if FPoundType = sFlag_ShipPro then
  begin
    nP.FParamA := sFlag_Provide;
  end
  else if FPoundType = sFlag_Sale then
  begin
    nP.FParamA := sFlag_Sale;
  end
  else if FPoundType = sFlag_ShipTmp then
  begin
    nP.FParamA := sFlag_Other;
  end;
  CreateBaseFormItem(cFI_FormGetStock, PopedomItem, @nP);
  if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
  editStockno.Text := np.FParamB;
  EditStock.Text := nP.FParamC;
end;

procedure TfFormPoundAdjust.EditRIDPropertiesChange(Sender: TObject);
begin
  EditPValue.Enabled := True;
  EditPDate.Enabled := True;
  EditMValue.Enabled := True;
  EditMDate.Enabled := True;
end;

initialization
  gControlManager.RegCtrl(TfFormPoundAdjust, TfFormPoundAdjust.FormID);
end.

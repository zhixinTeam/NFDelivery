{*******************************************************************************
  ����: dmzn@163.com 2014-06-10
  ����: �ֶ�����ͨ����
*******************************************************************************}
unit UFramePoundManualItem;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UMgrPoundTunnels, UBusinessConst, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, Menus, ExtCtrls, cxCheckBox,
  StdCtrls, cxButtons, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxLabel,
  ULEDFont, cxRadioGroup, UFrameBase;

type
  TOrderItem = record
    FOrder: string;         //������
    FMaxValue: Double;      //������
    FKDValue: Double;       //������
  end;

  TOrderItems = array of TOrderItem;
  //�����б�

  TfFrameManualPoundItem = class(TBaseFrame)
    GroupBox1: TGroupBox;
    EditValue: TLEDFontNum;
    GroupBox3: TGroupBox;
    ImageGS: TImage;
    Label16: TLabel;
    Label17: TLabel;
    ImageBT: TImage;
    Label18: TLabel;
    ImageBQ: TImage;
    ImageOff: TImage;
    ImageOn: TImage;
    HintLabel: TcxLabel;
    EditTruck: TcxComboBox;
    EditMID: TcxComboBox;
    EditPID: TcxComboBox;
    EditMValue: TcxTextEdit;
    EditPValue: TcxTextEdit;
    EditJValue: TcxTextEdit;
    BtnReadNumber: TcxButton;
    BtnReadCard: TcxButton;
    BtnSave: TcxButton;
    BtnNext: TcxButton;
    Timer1: TTimer;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    EditBill: TcxComboBox;
    EditZValue: TcxTextEdit;
    GroupBox2: TGroupBox;
    RadioPD: TcxRadioButton;
    RadioCC: TcxRadioButton;
    EditMemo: TcxTextEdit;
    EditWValue: TcxTextEdit;
    RadioLS: TcxRadioButton;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    cxLabel6: TcxLabel;
    cxLabel7: TcxLabel;
    cxLabel8: TcxLabel;
    cxLabel9: TcxLabel;
    cxLabel10: TcxLabel;
    Timer2: TTimer;
    CheckLock: TcxCheckBox;
    CheckZD: TcxCheckBox;
    CheckSound: TcxCheckBox;
    Timer_Savefail: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure BtnNextClick(Sender: TObject);
    procedure EditBillKeyPress(Sender: TObject; var Key: Char);
    procedure EditBillPropertiesEditValueChanged(Sender: TObject);
    procedure BtnReadNumberClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure RadioPDClick(Sender: TObject);
    procedure EditTruckKeyPress(Sender: TObject; var Key: Char);
    procedure EditMValuePropertiesEditValueChanged(Sender: TObject);
    procedure EditMIDPropertiesChange(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure BtnReadCardClick(Sender: TObject);
    procedure EditPIDKeyPress(Sender: TObject; var Key: Char);
    procedure CheckLockClick(Sender: TObject);
    procedure HintLabelClick(Sender: TObject);
    procedure CheckZDClick(Sender: TObject);
    procedure Timer_SavefailTimer(Sender: TObject);
  private
    { Private declarations }
    FPoundTunnel: PPTTunnelItem;
    //��վͨ��
    FLastGS,FLastBT,FLastBQ: Int64;
    //�ϴλ
    FCardNo, FCardNOSync: string;
    //�ſ����
    FOrderItems: TOrderItems;
    //�����б�
    FBillItems: TLadingBillItems;
    FUIData,FInnerData: TLadingBillItem;
    //��������
    FPreTruckPFlag: Boolean;
    //Ԥ��Ƥ�ر��
    FListA,FListB: TStrings;
    //�����б�
    FTitleHeight: Integer;
    FPanelHeight: Integer;
    //�۵�����
    FCardReader: Integer;
    //xxxxx
    procedure InitUIData;
    procedure SetUIData(const nReset: Boolean; const nOnlyData: Boolean = False);
    //��������
    procedure SetImageStatus(const nImage: TImage; const nOff: Boolean);
    //����״̬
    procedure SetTunnel(const nTunnel: PPTTunnelItem);
    //����ͨ��
    procedure OnPoundData(const nValue: Double);
    //��ȡ����
    procedure LoadBillItems(const nCard: string; nUpdateUI: Boolean = True);
    //��ȡ������
    procedure LoadTruckPoundItem(const nTruck: string);
    //��ȡ��������
    procedure LoadOrderPoundItem(const nOrderData: string);
    //��ȡ��������
    function MakeNewSanBill(nBillValue: Double): Boolean;
    //ɢװ���µ�
    procedure AdjustSanValue(const nBillValue: Double);
    //ɢװУ����
    function SavePoundSale: Boolean;
    function SavePoundProvide: Boolean;
    function SavePoundData(var nPoundID: string): Boolean;
    function SavePoundDuanDao: Boolean;
    function SavePoundHaulBack: Boolean;
    //�������
    procedure PlayVoice(const nStrtext: string);
    //��������
    procedure LEDDisplay(const nStrtext: string);
    //LED��ʾ
    procedure PlaySoundWhenCardArrived;
    //��������
    procedure CollapsePanel(const nCollapse: Boolean; const nAuto: Boolean = True);
    //�۵����
  public
    { Public declarations }
    class function FrameID: integer; override;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    //����̳�
    function ReDrawReadCardButton: Boolean;
    procedure ReadCardSync(const nCardNO: string;
      var nResult: Boolean);
    //�첽����
    procedure LoadCollapseConfig(const nCollapse: Boolean);
    //�۵�����
    property CardReader: Integer read FCardReader write FCardReader;
    property PoundTunnel: PPTTunnelItem read FPoundTunnel write SetTunnel;
    //�������
  end;

implementation

{$R *.dfm}

uses
  ULibFun, UAdjustForm, UFormBase, UMgrTruckProbe, UMgrRemoteVoice, UDataModule,
  UFormWait, USysBusiness, UBase64, USysConst, USysDB, UPoundCardReader,
  UMgrVoiceNet, IniFiles, UMgrSndPlay, UMgrLEDDisp;

const
  cFlag_ON    = 10;
  cFlag_OFF   = 20;

class function TfFrameManualPoundItem.FrameID: integer;
begin
  Result := 0;
end;

procedure TfFrameManualPoundItem.OnCreateFrame;
begin
  inherited;
  FPanelHeight := Height;
  FTitleHeight := HintLabel.Height + 1;

  FListA := TStringList.Create;
  FListB := TStringList.Create;

  FPoundTunnel := nil;
  InitUIData;
end;

procedure TfFrameManualPoundItem.OnDestroyFrame;
begin
  gPoundTunnelManager.ClosePort(FPoundTunnel.FID);
  //�رձ�ͷ�˿�

  with gPoundCardReader do
  begin
    DelCardReader(FCardReader);
    if CardReaderUser<1 then StopCardReader;
  end;
  //�ر��Զ�����

  AdjustStringsItem(EditMID.Properties.Items, True);
  AdjustStringsItem(EditPID.Properties.Items, True);

  FListA.Free;
  FListB.Free;
  inherited;
end;

//Desc: ��������״̬ͼ��
procedure TfFrameManualPoundItem.SetImageStatus(const nImage: TImage;
  const nOff: Boolean);
begin
  if nOff then
  begin
    if nImage.Tag <> cFlag_OFF then
    begin
      nImage.Tag := cFlag_OFF;
      nImage.Picture.Bitmap := ImageOff.Picture.Bitmap;
    end;
  end else
  begin
    if nImage.Tag <> cFlag_ON then
    begin
      nImage.Tag := cFlag_ON;
      nImage.Picture.Bitmap := ImageOn.Picture.Bitmap;
    end;
  end;
end;

//Desc: �۵���չ�����
procedure TfFrameManualPoundItem.CollapsePanel(const nCollapse,nAuto: Boolean);
var nCol: Boolean;
begin
  if nAuto then
       nCol := Height > FTitleHeight
  else nCol := nCollapse;

  if nCol then
       Height := FTitleHeight
  else Height := FPanelHeight;
end;

//------------------------------------------------------------------------------
//Desc: ��ʼ������
procedure TfFrameManualPoundItem.InitUIData;
var nStr: string;
    nEx: TDynamicStrArray;
begin
  SetLength(nEx, 1);
  nStr := 'M_ID=Select M_ID,M_Name From %s Order By M_ID ASC';
  nStr := Format(nStr, [sTable_Materails]);

  nEx[0] := 'M_ID';
  FDM.FillStringsData(EditMID.Properties.Items, nStr, 0, '', nEx);
  AdjustCXComboBoxItem(EditMID, False);

  nStr := 'P_ID=Select P_ID,P_Name From %s Order By P_ID ASC';
  nStr := Format(nStr, [sTable_Provider]);
  
  nEx[0] := 'P_ID';
  FDM.FillStringsData(EditPID.Properties.Items, nStr, 0, '', nEx);
  AdjustCXComboBoxItem(EditPID, False);
end;

//Desc: ���ý�������
procedure TfFrameManualPoundItem.SetUIData(const nReset,nOnlyData: Boolean);
var nStr: string;
    nInt: Integer;
    nVal: Double;
    nProvide: Boolean;
    nItem: TLadingBillItem;
begin
  if nReset then
  begin
    FCardNo := '';
    FillChar(nItem, SizeOf(nItem), #0);
    //init

    with nItem do
    begin
      FPModel := sFlag_PoundPD;
      FFactory := gSysParam.FFactNum;
    end;

    FUIData := nItem;
    FInnerData := nItem;
    if nOnlyData then Exit;

    SetLength(FBillItems, 0);
    EditValue.Text := '0.00';
    EditBill.Properties.Items.Clear;

    FPreTruckPFlag := False;
    CheckLock.Checked := False;
    CheckLock.Visible := False;
    gPoundTunnelManager.ClosePort(FPoundTunnel.FID);
    //�رձ�ͷ�˿�
  end;

  with FUIData do
  begin
    nProvide := (FID <> '') and (FID = FZhiKa);
    //������Ӧģʽ

    EditBill.Text := FID;
    EditTruck.Text := FTruck;
    EditMID.Text := FStockName;
    EditPID.Text := FCusName;

    EditMValue.Text := Format('%.2f', [FMData.FValue]);
    EditPValue.Text := Format('%.2f', [FPData.FValue]);
    EditZValue.Text := Format('%.2f', [FValue]);

    if (not nProvide) and
       (FValue > 0) and (FMData.FValue > 0) and (FPData.FValue > 0) then
    begin
      nVal := FMData.FValue - FPData.FValue;
      EditJValue.Text := Format('%.2f', [nVal]);
      EditWValue.Text := Format('%.2f', [FValue - nVal]);
    end else
    begin
      EditJValue.Text := '0.00';
      EditWValue.Text := '0.00';
    end;

    RadioPD.Checked := FPModel = sFlag_PoundPD;
    RadioCC.Checked := FPModel = sFlag_PoundCC;
    RadioLS.Checked := FPModel = sFlag_PoundLS;

    BtnSave.Enabled := (FTruck <> '') or nProvide;
    BtnReadCard.Enabled := (FTruck = '') and (not nProvide);
    BtnReadNumber.Enabled := (FTruck <> '') or nProvide;

    RadioLS.Enabled := (FPoundID = '') and (FID = '');
    //�ѳƹ�����������,������ʱģʽ
    RadioCC.Enabled := (FID <> '') and (not nProvide);
    //ֻ�������г���ģʽ

    EditBill.Properties.ReadOnly := (FID = '') and (FTruck <> '');
    EditTruck.Properties.ReadOnly := FTruck <> '';
    EditMID.Properties.ReadOnly := (FID <> '') or (FPoundID <> '');
    EditPID.Properties.ReadOnly := (FID <> '') or (FPoundID <> '');
    //�����������

    EditMemo.Properties.ReadOnly := True;
    EditMValue.Properties.ReadOnly := not FPoundTunnel.FUserInput;
    EditPValue.Properties.ReadOnly := not FPoundTunnel.FUserInput;
    EditJValue.Properties.ReadOnly := True;
    EditZValue.Properties.ReadOnly := True;
    EditWValue.Properties.ReadOnly := True;
    //������������

    if FTruck = '' then
    begin
      EditMemo.Text := '';
      Exit;
    end;
  end;

  nInt := Length(FBillItems);
  if nInt > 0 then
  begin
    if (FBillItems[0].FCardUse = sFlag_Sale) or
       (FBillItems[0].FCardUse = sFlag_SaleNew) then
    begin
      if nInt > 1 then
           nStr := '���۲���'
      else nStr := '����';
    end else nStr := BusinessToStr(FBillItems[0].FCardUse);

    if FUIData.FNextStatus = sFlag_TruckBFP then
    begin
      RadioCC.Enabled := False;
      //EditMemo.Text := nStr + '��Ƥ��';
      if CheckLock.Checked then
           EditMemo.Text := nStr + 'Ԥ��Ƥ��'
      else EditMemo.Text := nStr + '��Ƥ��';
    end else
    begin
      RadioCC.Enabled := True;
      EditMemo.Text := nStr + '��ë��';
    end;
  end else
  begin
    if RadioLS.Checked then
      EditMemo.Text := '������ʱ����';
    //xxxxx

    if RadioPD.Checked then
      EditMemo.Text := '������Գ���';
    //xxxxx
  end;
end;

//Date: 2014-09-19
//Parm: �ſ��򽻻�����
//Desc: ��ȡnCard��Ӧ�Ľ�����
procedure TfFrameManualPoundItem.LoadBillItems(const nCard: string;
 nUpdateUI: Boolean);
var nStr,nHint: string;
    nIdx,nInt: Integer;
    nBills: TLadingBillItems;
begin
  if nCard = '' then
  begin
    EditBill.SetFocus;
    EditBill.SelectAll;
    ShowMsg('������ſ���', sHint); Exit;
  end;

  if not GetLadingBills(nCard, sFlag_TruckBFP, nBills) then
  begin
    ShowMsg('�޶�����Ϣ', sHint);
    SetUIData(True);
    Exit;
  end;

  FCardNo := nCard;
  nHint := '';
  nInt := 0;

  for nIdx:=Low(nBills) to High(nBills) do
  with nBills[nIdx] do
  begin
    if (FStatus <> sFlag_TruckBFP) and (FNextStatus = sFlag_TruckZT) then
      FNextStatus := sFlag_TruckBFP;
    //״̬У��

    FSelected := (FNextStatus = sFlag_TruckBFP) or
                 (FNextStatus = sFlag_TruckBFM);
    //�ɳ���״̬�ж�

    if FSelected then
    begin
      Inc(nInt);
      Continue;
    end;

    nStr := '��.����:[ %s ] ״̬:[ %-6s -> %-6s ]   ';
    if nIdx < High(nBills) then nStr := nStr + #13#10;

    nStr := Format(nStr, [FID,
            TruckStatusToStr(FStatus), TruckStatusToStr(FNextStatus)]);
    nHint := nHint + nStr;
  end;

  if nInt = 0 then
  begin
    nHint := '�ó�����ǰ���ܹ���,��������: ' + #13#10#13#10 + nHint;

    ShowDlg(nHint, sHint);
    Exit;
  end;

  EditBill.Properties.Items.Clear;
  SetLength(FBillItems, nInt);
  nInt := 0;

  for nIdx:=Low(nBills) to High(nBills) do
  with nBills[nIdx] do
  begin
    if FSelected then
    begin
      if (FCardUse = sFlag_Sale) or (FCardUse = sFLag_SaleNew) then
        FPoundID := '';
      //����ˮ��ñ����������;

      if nInt = 0 then
           FInnerData := nBills[nIdx]
      else FInnerData.FValue := FInnerData.FValue + FValue;
      //�ۼ���

      EditBill.Properties.Items.Add(FID);
      FBillItems[nInt] := nBills[nIdx];
      Inc(nInt);
    end;
  end;

  if not nUpdateUI then
  begin
    FUIData.FValue := FInnerData.FValue;
    SetUIData(False);
    Exit;
  end;
  //����������

  FInnerData.FPModel := sFlag_PoundPD;
  FUIData := FInnerData; 
  SetUIData(False);

  if not FPoundTunnel.FUserInput then
    gPoundTunnelManager.ActivePort(FPoundTunnel.FID, OnPoundData, True);
  //xxxxx
end;

//Date: 2014-09-25
//Parm: ���ƺ�
//Desc: ��ȡnTruck�ĳ�����Ϣ
procedure TfFrameManualPoundItem.LoadTruckPoundItem(const nTruck: string);
var nData: TLadingBillItems;
    nPItem: TPreTruckPItem;
begin
  if nTruck = '' then
  begin
    EditTruck.SetFocus;
    EditTruck.SelectAll;
    ShowMsg('�����복�ƺ�', sHint); Exit;
  end;

  with FUIData do
  begin
    if not ((FID <> '') and (FID = FZhiKa)) then //�ǹ�Ӧ����
    begin
      if not GetTruckPoundItem(nTruck, nData) then
      begin
        SetUIData(True);
        Exit;
      end;

      FInnerData := nData[0];
      FUIData := FInnerData;
    end else
    begin
      if TruckInFact(nTruck) then
      begin
        EditTruck.Text:='';
        EditTruck.SetFocus;
        EditTruck.SelectAll;
        Exit;
      end;
    end; //��Ӧ��֤�����Ƿ����
  end;

  if (FUIData.FNextStatus<>sFlag_TruckBFM) and GetTruckPValue(nPItem, nTruck) then
  begin
    if nPItem.FPreUse then
    begin
      if (FInnerData.FID = '') and (FInnerData.FPoundID = '') then //��ʱ����
      begin
        CheckLock.Visible := True;
      end;

      with nPItem, FInnerData do
      begin
        FPData.FOperator := FPrePMan;
        FPData.FValue    := FPrePValue;
        FPData.FDate     := FPrePTime;
        FTruck           := FPreTruck;

        FPreTruckPFlag   := True; //ʹ��Ԥ��Ƥ��
        FUIData          := FInnerData;
      end;                 //��Ӧ
    end;
  end;
  //��ȡԤ��Ƥ�ر��

  SetUIData(False);
  if not FPoundTunnel.FUserInput then
    gPoundTunnelManager.ActivePort(FPoundTunnel.FID, OnPoundData, True);
  //xxxxx
end;

//Date: 2015-01-07
//Parm: ��������
//Desc: ��ʼһ��nOrder�Ĺ�Ӧҵ��
procedure TfFrameManualPoundItem.LoadOrderPoundItem(const nOrderData: string);
var nOrder: TOrderItemInfo;
begin
  AnalyzeOrderInfo(nOrderData, nOrder);
  with FInnerData do
  begin
    FID         := nOrder.FOrders;
    FZhiKa      := nOrder.FOrders;
    FCusID      := nOrder.FCusID;
    FCusName    := nOrder.FCusName;

    FStockNo    := nOrder.FStockID;
    FStockName  := nOrder.FStockName;
    FOrigin     := nOrder.FStockArea;

    FValue      := nOrder.FValue;
    FSelected   := True;
  end;

  FUIData := FInnerData;
  SetUIData(False);
  EditTruck.SetFocus;

  if not FPoundTunnel.FUserInput then
    gPoundTunnelManager.ActivePort(FPoundTunnel.FID, OnPoundData, True);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Desc: ��������״̬
procedure TfFrameManualPoundItem.Timer1Timer(Sender: TObject);
begin
  SetImageStatus(ImageGS, GetTickCount - FLastGS > 5 * 1000);
  SetImageStatus(ImageBT, GetTickCount - FLastBT > 5 * 1000);
  SetImageStatus(ImageBQ, GetTickCount - FLastBQ > 5 * 1000);
end;

//Desc: �رպ��̵�
procedure TfFrameManualPoundItem.Timer2Timer(Sender: TObject);
begin
  Timer2.Tag := Timer2.Tag + 1;
  if Timer2.Tag < 10 then Exit;

  Timer2.Tag := 0;
  Timer2.Enabled := False;
  {$IFNDEF MITTruckProber}
    gProberManager.TunnelOC(FPoundTunnel.FID,False);
  {$ENDIF} //�м�����������Դ��رչ���
end;

//Desc: �۵����
procedure TfFrameManualPoundItem.HintLabelClick(Sender: TObject);
begin
  CollapsePanel(True);
end;

//Desc: ��������
procedure TfFrameManualPoundItem.CheckZDClick(Sender: TObject);
var nIni: TIniFile;
begin
  if not (CheckZD.Focused or CheckSound.Focused) then Exit;
  //ֻ�����û�����

  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    if CheckZD.Checked then
         nIni.WriteString(Name, 'AutoCollapse', 'Y')
    else nIni.WriteString(Name, 'AutoCollapse', 'N');

    if CheckSound.Checked then
         nIni.WriteString(Name, 'PlaySound', 'Y')
    else nIni.WriteString(Name, 'PlaySound', 'N');
  finally
    nIni.Free;
  end;
end;

//Desc: ��ȡ�۵�����
procedure TfFrameManualPoundItem.LoadCollapseConfig(const nCollapse: Boolean);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    CheckSound.Checked := nIni.ReadString(Name, 'PlaySound', 'Y') = 'Y';
    CheckZD.Checked := nIni.ReadString(Name, 'AutoCollapse', 'N') = 'Y';

    if nCollapse and CheckZD.Checked then
      CollapsePanel(True);
    //�۵����
  finally
    nIni.Free;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ��ͷ����
procedure TfFrameManualPoundItem.OnPoundData(const nValue: Double);
begin
  FLastBT := GetTickCount;
  EditValue.Text := Format('%.2f', [nValue]);
end;

//Desc: ����ͨ��
procedure TfFrameManualPoundItem.SetTunnel(const nTunnel: PPTTunnelItem);
begin
  FPoundTunnel := nTunnel;
  SetUIData(True);
end;

//Desc: ���ƺ��̵�
procedure TfFrameManualPoundItem.N1Click(Sender: TObject);
begin
  N1.Checked := not N1.Checked;
  //status change
  {$IFDEF MITTruckProber}
    TunnelOC(FPoundTunnel.FID, N1.Checked);
  {$ELSE}
    gProberManager.TunnelOC(FPoundTunnel.FID, N1.Checked);
  {$ENDIF}
end;

//Desc: �رճ���ҳ��
procedure TfFrameManualPoundItem.N3Click(Sender: TObject);
var nP: TWinControl;
begin
  nP := Parent;
  while Assigned(nP) do
  begin
    if (nP is TBaseFrame) and
       (TBaseFrame(nP).FrameID = cFI_FramePoundManual) then
    begin
      TBaseFrame(nP).Close();
      Exit;
    end;

    nP := nP.Parent;
  end;
end;

//Desc: ������ť
procedure TfFrameManualPoundItem.BtnNextClick(Sender: TObject);
begin
  SetUIData(True);
end;

procedure TfFrameManualPoundItem.EditBillKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    if EditBill.Properties.ReadOnly then Exit;

    EditBill.Text := Trim(EditBill.Text);
    LoadBillItems(EditBill.Text);
  end;
end;

//Desc: ѡ��ͻ�
procedure TfFrameManualPoundItem.EditPIDKeyPress(Sender: TObject;
  var Key: Char);
var nStr: string;
    nP: TFormCommandParam;
begin
  if Key = #13 then
  begin
    Key := #0;
    if EditPID.Properties.ReadOnly then Exit;

    if EditPID.ItemIndex >= 0 then
    begin
      nStr := EditPID.Properties.Items[EditPID.ItemIndex];
      if nStr = EditPID.Text then
      begin
        EditMIDPropertiesChange(EditPID);
        Exit; //���¼��ع�Ӧ����
      end;
    end;

    nP.FParamA := EditPID.Text;
    CreateBaseFormItem(cFI_FormGetCustom, FPopedom, @nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

    SetCtrlData(EditPID, nP.FParamB);
    if EditPID.ItemIndex < 0 then
    begin
      nStr := Format('%s=%s', [nP.FParamB, nP.FParamC]);
      InsertStringsItem(EditPID.Properties.Items, nStr);
      SetCtrlData(EditPID, nP.FParamB);
    end;
  end;
end;

procedure TfFrameManualPoundItem.EditTruckKeyPress(Sender: TObject;
  var Key: Char);
var nP: TFormCommandParam;
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    if EditTruck.Properties.ReadOnly then Exit;
    EditTruck.Text := Trim(EditTruck.Text);

    LoadTruckPoundItem(EditTruck.Text);
  end;

  if Key = Char(VK_SPACE) then
  begin
    Key := #0;
    if EditTruck.Properties.ReadOnly then Exit;

    nP.FParamA := EditTruck.Text;
    CreateBaseFormItem(cFI_FormGetTruck, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
      EditTruck.Text := nP.FParamB;
    EditTruck.SelectAll;
  end;
end;

procedure TfFrameManualPoundItem.EditBillPropertiesEditValueChanged(
  Sender: TObject);
begin
  if EditBill.Properties.Items.Count > 0 then
  begin
    if EditBill.ItemIndex < 0 then
    begin
      EditBill.Text := FUIData.FID;
      Exit;
    end;

    with FBillItems[EditBill.ItemIndex] do
    begin
      if FUIData.FID = FID then Exit;
      //ͬ����

      FUIData.FID := FID;
      FUIData.FCusName := FCusName;
      FUIData.FStockName := FStockName;
    end;

    SetUIData(False);
    //ui
  end;
end;

//Desc: ����
procedure TfFrameManualPoundItem.BtnReadNumberClick(Sender: TObject);
var nVal: Double;
    nStr: string;
begin
  if not IsNumber(EditValue.Text, True) then Exit;
  nVal := StrToFloat(EditValue.Text);
  if FloatRelation(nVal, FPoundTunnel.FPort.FMinValue, rtLE, 1000) then Exit;
  //����С�ڹ������ֵʱ,�˳�

  {$IFDEF MITTruckProber}
    if not IsTunnelOK(FPoundTunnel.FID) then
  {$ELSE}
    if not gProberManager.IsTunnelOK(FPoundTunnel.FID) then
  {$ENDIF}
  begin
    nStr := '����δվ��,���Ժ�';
    ShowMsg(nStr, sHint);
    LEDDisplay(nStr);
    Exit;
  end;

  if (Length(FBillItems) > 0) and
  ((FUIData.FCardUse=sFlag_Sale) or (FUIData.FCardUse = sFlag_SaleNew) or
   (FUIData.FCardUse = sFlag_DuanDao)) then
  begin
    if FBillItems[0].FNextStatus = sFlag_TruckBFP then
         FUIData.FPData.FValue := nVal
    else FUIData.FMData.FValue := nVal;
  end else
  begin
    if CheckLock.Checked then FUIData.FPData.FValue := nVal  //����Ԥ��Ƥ��
    else if FInnerData.FPData.FValue > 0 then
    begin
      if nVal <= FInnerData.FPData.FValue then
      begin
        FUIData.FPData := FInnerData.FMData;
        FUIData.FMData := FInnerData.FPData;

        FUIData.FPData.FValue := nVal;
        FUIData.FNextStatus := sFlag_TruckBFP;
        //�л�Ϊ��Ƥ��
      end else
      begin
        FUIData.FPData := FInnerData.FPData;
        FUIData.FMData := FInnerData.FMData;

        FUIData.FMData.FValue := nVal;
        FUIData.FNextStatus := sFlag_TruckBFM;
        //�л�Ϊ��ë��
      end;
    end else FUIData.FPData.FValue := nVal;
  end;

  SetUIData(False);
end;

//Desc: �ɶ�ͷָ��������
procedure TfFrameManualPoundItem.BtnReadCardClick(Sender: TObject);
var nStr: string;
    nInit: Int64;
    nChar: Char;
    nCard: string;
begin
  nCard := '';
  try
    BtnReadCard.Enabled := False;

    nInit := GetTickCount;
    while GetTickCount - nInit < 5 * 1000 do
    begin
      ShowWaitForm(ParentForm, '���ڶ���', False);
      FCardNOSync := gPoundCardReader.GetCardNOSync(FCardReader);
      if FCardNOSync='' then Continue;

      nStr := 'Select C_Card From $TB Where C_Card=''$CD'' or ' +
          'C_Card2=''$CD'' or C_Card3=''$CD''';
      nStr := MacroValue(nStr, [MI('$TB', sTable_Card), MI('$CD', FCardNOSync)]);

      with FDM.QueryTemp(nStr) do
      if RecordCount > 0 then
      begin
        nCard := Fields[0].AsString;
        Break;
      end;
    end;

    if nCard = '' then Exit;
    EditBill.Text := nCard;

    nChar := #13;
    FCardNOSync := '';
    EditBillKeyPress(nil, nChar);
  finally
    CloseWaitForm;
    if nCard = '' then
    begin
      BtnReadCard.Enabled := True;
      ShowMsg('û�ж�ȡ�ɹ�,������', sHint);
    end;
  end;
end;

procedure TfFrameManualPoundItem.RadioPDClick(Sender: TObject);
begin
  if RadioPD.Checked then
    FUIData.FPModel := sFlag_PoundPD;
  if RadioCC.Checked then
    FUIData.FPModel := sFlag_PoundCC;
  if RadioLS.Checked then
    FUIData.FPModel := sFlag_PoundLS;
  //�л�ģʽ

  SetUIData(False);
end;

procedure TfFrameManualPoundItem.EditMValuePropertiesEditValueChanged(
  Sender: TObject);
var nVal: Double;
    nEdit: TcxTextEdit;
begin
  nEdit := Sender as TcxTextEdit;
  if not IsNumber(nEdit.Text, True) then Exit;
  nVal := StrToFloat(nEdit.Text);

  if Sender = EditPValue then
    FUIData.FPData.FValue := nVal;
  //xxxxx

  if Sender = EditMValue then
    FUIData.FMData.FValue := nVal;
  SetUIData(False);
end;

procedure TfFrameManualPoundItem.EditMIDPropertiesChange(Sender: TObject);
var nP: TFormCommandParam;
    nFilter: string;
begin
  if Sender = EditTruck then
  begin
    if not EditTruck.Focused then Exit;
    //�ǲ�����Ա����
    EditTruck.Text := Trim(EditTruck.Text);
    FUIData.FTruck := EditTruck.Text;
  end else

  if Sender = EditMID then
  begin
    if not EditMID.Focused then Exit;
    //�ǲ�����Ա����
    EditMID.Text := Trim(EditMID.Text);

    if EditMID.ItemIndex < 0 then
    begin
      FUIData.FStockNo := '';
      FUIData.FStockName := EditMID.Text;
    end else
    begin
      FUIData.FStockNo := GetCtrlData(EditMID);
      FUIData.FStockName := EditMID.Text;
    end;
  end else

  if Sender = EditPID then
  begin
    if not EditPID.Focused then Exit;
    //�ǲ�����Ա����
    EditPID.Text := Trim(EditPID.Text);

    if EditPID.ItemIndex < 0 then
    begin
      FUIData.FCusID := '';
      FUIData.FCusName := EditPID.Text;
    end else
    begin
      FUIData.FCusID := GetCtrlData(EditPID);
      FUIData.FCusName := EditPID.Text;
    end;

    if FUIData.FCusID = '' then Exit;
    if BtnSave.Enabled then Exit;
    //ҵ���ѿ�ʼ

    if FUIData.FCusName <> EditPID.Properties.Items[EditPID.ItemIndex] then
      Exit;
    //�û��ֹ�����

    nFilter    := '';
    nP.FParamA := FUIData.FCusID;
    CreateBaseFormItem(cFI_FormGetMine, FPopedom, @nP);
    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK)
      and (nP.FParamB<>'') then nFilter:=nP.FParamB;
    //ѡ����

    nP.FParamA := FUIData.FCusID;
    nP.FParamB := '';
    nP.FParamC := sFlag_Provide;
    if nFilter<>'' then nP.FParamD:=nFilter;

    CreateBaseFormItem(cFI_FormGetOrder, FPopedom, @nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
    LoadOrderPoundItem(nP.FParamB);
  end;
end;

//------------------------------------------------------------------------------
//Desc: ԭ���ϻ���ʱ
function TfFrameManualPoundItem.SavePoundData(var nPoundID: string): Boolean;
var nPreItem: TPreTruckPItem;
    nVal : Double;
    nStr : string;
begin
  Result := False;
  //init

  if (FUIData.FPData.FValue <= 0) and (FUIData.FMData.FValue <= 0) then
  begin
    ShowMsg('���ȳ���', sHint);
    Exit;
  end;

  if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) then
  begin
    if FUIData.FPData.FValue > FUIData.FMData.FValue then
    begin
      ShowMsg('Ƥ��ӦС��ë��', sHint);
      Exit;
    end;
  end;

  if FPreTruckPFlag then
  begin
    if (FUIData.FPData.FValue<=0) or (FUIData.FMData.FValue<=0) then
     FPreTruckPFlag := False;
  end;
  //Ԥ��Ƥ��ʱ��Ƥ�ػ�ë�ز���Ϊ0

  SetLength(FBillItems, 1);
  FBillItems[0] := FUIData;
  //�����û���������

  with FBillItems[0] do
  begin
    FFactory := gSysParam.FFactNum;
    //xxxxx

    FLocked    := CheckLock.Checked;
    if FLocked then
    begin
      FPData.FOperator := gSysParam.FUserID;
      FPreTruckP := False;

      if GetTruckPValue(nPreItem, FTruck) then
      begin
        if nPreItem.FPreUse then
        begin
          nVal := Abs(nPreItem.FPrePValue * 1000-FPData.FValue * 1000);
          if nVal > gSysParam.FPoundTruck then
          begin
            nStr := '����Ƥ������ʷƤ���нϴ����:' + #13#10 +
                    '��ʷƤ��:[%.2f]��' + #13#10 +
                    '��ǰƤ��:[%.2f]��' + #13#10 +
                    '��[%.2f]ǧ��'  + #13#10 +
                    '�Ƿ񱣴�?';
            nStr := Format(nStr, [nPreItem.FPrePValue, FPData.FValue,
                                  nVal]);

            if not QueryDlg(nStr, sHint) then  Exit;
          end;
        end;
      end;
      //�жϳ���Ƥ����Ԥ��Ƥ���Ƿ񳬳����
    end;
    //True������Ԥ��Ƥ��;False����������ʱ����
    FPreTruckP := FPreTruckPFlag;
    //True,ʹ��Ԥ��Ƥ��

    if FNextStatus = sFlag_TruckBFM then
         FMData.FStation := FPoundTunnel.FID
    else FPData.FStation := FPoundTunnel.FID;
  end;

  Result := SaveTruckPoundItem(FPoundTunnel, FBillItems, nPoundID);
  //�������
end;

//Desc: �ֿ�ԭ����
function TfFrameManualPoundItem.SavePoundProvide: Boolean;
var nVal, nNet, nPlan: Double;
    nStr, nNextStatus: string;
begin
  Result := False;
  //init

  if (FUIData.FPData.FValue <= 0) and (FUIData.FMData.FValue <= 0) then
  begin
    ShowMsg('���ȳ���', sHint);
    Exit;
  end;

  if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) then
  begin
    if FUIData.FPData.FValue > FUIData.FMData.FValue then
    begin
      ShowMsg('Ƥ��ӦС��ë��', sHint);
      Exit;
    end;

    if (FUIData.FCardUse <> sFlag_ShipTmp) and (FUIData.FMuiltiType <> sFlag_Yes) then
    begin
      FListA.Clear;
      FListA.Add(FUIData.FExtID_2);
      nStr := AdjustListStrFormat2(FListA, '''', True, ',', False, False);

      FListB.Clear;
      FListB.Values['MeamKeys'] := nStr;
      nStr := EncodeBase64(FListB.Text);
      nStr := GetQueryOrderSQL('203', nStr);
      if nStr = '' then Exit;

      with FDM.QueryTemp(nStr, True) do
      begin
        if RecordCount < 1 then
        begin
          nStr := StringReplace(FListA.Text, #13#10, ',', [rfReplaceAll]);
          nStr := Format('����[ %s ]��Ϣ�Ѷ�ʧ.', [nStr]);

          ShowDlg(nStr, sHint);
          Exit;
        end;

        nPlan := FieldByName('NPLANNUM').AsFloat;
      end;

      FListB.Clear;
      FListB.Add(FUIData.FExtID_2);
      if not GetOrderGYValue(FListB) then Exit;

      nVal := nPlan - StrToFloat(FListB.Values[FUIData.FExtID_2]);
      if FUIData.FPData.FValue > FUIData.FMData.FValue then
           nNet := FUIData.FPData.FValue - FUIData.FMData.FValue
      else nNet := FUIData.FMData.FValue - FUIData.FPData.FValue;

      if FloatRelation(nVal, nNet, rtLE) then
      begin
        nStr := 'NC�������������㣬�����°쿨';
        ShowMsg(nStr, sHint);
        LEDDisplay(nStr);
        Exit;
      end;
    end;
    //�Ƕ��θ���
  end;  

  if FBillItems[0].FPreTruckP then
       nNextStatus := sFlag_TruckSH
  else nNextStatus := FBillItems[0].FNextStatus;

  SetLength(FBillItems, 1);
  FBillItems[0] := FUIData;
  //�����û���������

  with FBillItems[0] do
  begin
    FFactory := gSysParam.FFactNum;
    //xxxxx

    if FNextStatus = sFlag_TruckBFP then
         FPData.FStation := FPoundTunnel.FID
    else FMData.FStation := FPoundTunnel.FID;
  end;

  Result := SaveLadingBills(nNextStatus, FBillItems, FPoundTunnel);
  //�������
end;

//Desc: �̵�ҵ��
function TfFrameManualPoundItem.SavePoundDuanDao: Boolean;
begin
  Result := False;
  //init

  if FUIData.FNextStatus = sFlag_TruckBFP then
  begin
    if FUIData.FPData.FValue <= 0 then
    begin
      ShowMsg('���ȳ���Ƥ��', sHint);
      Exit;
    end;
  end else
  begin
    if FUIData.FMData.FValue <= 0 then
    begin
      ShowMsg('���ȳ���ë��', sHint);
      Exit;
    end;
  end;

  if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) then
  begin
    if FUIData.FPData.FValue > FUIData.FMData.FValue then
    begin
      ShowMsg('Ƥ��ӦС��ë��', sHint);
      Exit;
    end;
  end;

  SetLength(FBillItems, 1);
  FBillItems[0] := FUIData;
  //�����û���������

  with FBillItems[0] do
  begin
    FFactory := gSysParam.FFactNum;
    //xxxxx
    
    if FNextStatus = sFlag_TruckBFP then
         FPData.FStation := FPoundTunnel.FID
    else FMData.FStation := FPoundTunnel.FID;
  end;

  Result := SaveLadingBills(FBillItems[0].FNextStatus, FBillItems, FPoundTunnel);
  //�������
end;

//Desc: �ؿ�ҵ��
function TfFrameManualPoundItem.SavePoundHaulBack: Boolean;
begin
  Result := False;
  //init

  if FUIData.FNextStatus = sFlag_TruckBFP then
  begin
    if FUIData.FPData.FValue <= 0 then
    begin
      ShowMsg('���ȳ���Ƥ��', sHint);
      Exit;
    end;
  end else
  begin
    if FUIData.FMData.FValue <= 0 then
    begin
      ShowMsg('���ȳ���ë��', sHint);
      Exit;
    end;
  end;

  if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) then
  begin
    if FUIData.FPData.FValue > FUIData.FMData.FValue then
    begin
      ShowMsg('Ƥ��ӦС��ë��', sHint);
      Exit;
    end;
  end;

  SetLength(FBillItems, 1);
  FBillItems[0] := FUIData;
  //�����û���������

  with FBillItems[0] do
  begin
    FFactory := gSysParam.FFactNum;
    //xxxxx
    
    if FNextStatus = sFlag_TruckBFP then
         FPData.FStation := FPoundTunnel.FID
    else FMData.FStation := FPoundTunnel.FID;
  end;

  Result := SaveLadingBills(FBillItems[0].FNextStatus, FBillItems, FPoundTunnel);
  //�������
end;

//Date: 2014-12-26
//Parm: �����б�
//Desc: ��nOrders����������С��������
procedure SortOrderByValue(var nOrders: TOrderItems);
var i,j,nInt: Integer;
    nItem: TOrderItem;
begin
  nInt := High(nOrders);
  //xxxxx

  for i:=Low(nOrders) to nInt do
   for j:=i+1 to nInt do
    if nOrders[j].FMaxValue < nOrders[i].FMaxValue then
    begin
      nItem := nOrders[i];
      nOrders[i] := nOrders[j];
      nOrders[j] := nItem;
    end;
  //ð������
end;

//Date: 2014-12-28
//Parm: �貢����
//Desc: �ӵ�ǰ�ͻ����ö����п���ָ�������µ�
function TfFrameManualPoundItem.MakeNewSanBill(nBillValue: Double): Boolean;
var nStr: string;
    nDec: Double;
    nIdx,nInt: Integer;
    nP: TFormCommandParam;
    nOrder: TOrderItemInfo;
begin
  FListA.Clear;
  Result := False;

  for nIdx:=Low(FBillItems) to High(FBillItems) do
    FListA.Add(FBillItems[nIdx].FZhiKa);
  nStr := AdjustListStrFormat2(FListA, '''', True, ',', False, False);

  FListB.Clear;
  FListB.Values['MeamKeys'] := nStr;

  nStr := EncodeBase64(FListB.Text);
  nStr := GetQueryOrderSQL('103', nStr);
  if nStr = '' then Exit;

  with FDM.QueryTemp(nStr, True) do
  begin
    if RecordCount < 1 then
    begin
      nStr := StringReplace(FListA.Text, #13#10, ',', [rfReplaceAll]);
      nStr := Format('����[ %s ]��Ϣ�Ѷ�ʧ.', [nStr]);

      ShowDlg(nStr, sHint);
      Exit;
    end;

    SetLength(FOrderItems, RecordCount);
    nInt := 0;
    First;

    while not Eof do
    begin
      with FOrderItems[nInt] do
      begin
        FOrder := FieldByName('pk_meambill').AsString;
        FMaxValue := FieldByName('NPLANNUM').AsFloat;
        FKDValue := 0;
      end;

      Inc(nInt);
      Next;
    end;
  end;

  if not GetOrderFHValue(FListA) then Exit;
  //��ȡ�ѷ�����

  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  with FOrderItems[nIdx] do
  begin
    nStr := FListA.Values[FOrder];
    if not IsNumber(nStr, True) then Continue;

    FMaxValue := FMaxValue - Float2Float(StrToFloat(nStr), cPrecision, False);
    //������ = �ƻ��� - �ѷ���
  end;

  SortOrderByValue(FOrderItems);
  //����������С��������

  //----------------------------------------------------------------------------
  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  begin
    if nBillValue <= 0 then Break;
    //�ѿ������

    if FOrderItems[nIdx].FMaxValue<=0 then Continue;
    //NC����������Ϊ��

    nDec := FOrderItems[nIdx].FMaxValue;
    if nDec >= nBillValue then
      nDec := nBillValue;
    //����������

    FOrderItems[nIdx].FKDValue := nDec;
    nBillValue := Float2Float(nBillValue - nDec, cPrecision, True);
  end;

  FDM.ADOConn.BeginTrans;
  try
    for nIdx:=Low(FOrderItems) to High(FOrderItems) do
    with FOrderItems[nIdx] do
    begin
      if FKDValue <= 0 then Continue;
      //�޿�����

      nStr := 'Update %s Set B_Freeze=B_Freeze+%.2f Where B_ID=''%s''';
      nStr := Format(nStr, [sTable_Order, FKDValue, FOrder]);
      FDM.ExecuteSQL(nStr);

      for nInt:=Low(FBillItems) to High(FBillItems) do
      begin
        if FBillItems[nInt].FZhiKa <> FOrder then Continue;
        //xxxxx

        nStr := 'Update %s Set L_Value=L_Value+%.2f Where L_ID=''%s''';
        nStr := Format(nStr, [sTable_Bill, FKDValue, FBillItems[nInt].FID]);
        FDM.ExecuteSQL(nStr);
      end;
    end;

    FDM.ADOConn.CommitTrans;
    //���������
  except
    on E: Exception do
    begin
      FDM.ADOConn.RollbackTrans;
      ShowDlg(E.Message, sHint);
      Exit;
    end;
  end;

  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  with FOrderItems[nIdx] do
  begin
    if FKDValue <= 0 then Continue;
    //�޿�����

    for nInt:=Low(FBillItems) to High(FBillItems) do
    begin
      if FBillItems[nInt].FZhiKa <> FOrder then Continue;
      //xxxxx

      FBillItems[nInt].FValue := FBillItems[nInt].FValue + FKDValue;
      //���¿�����

      FInnerData.FValue := FInnerData.FValue + FKDValue;
      FUIData.FValue := FInnerData.FValue;
    end;
  end;

  if nBillValue <= 0 then
  begin
    Result := True;
    Exit;
  end;
  //�ѿ������

  //----------------------------------------------------------------------------
  nStr := '���η���������[ %.2f ]��,��ѡ���µĶ���.';
  nStr := Format(nStr, [nBillValue]);
  ShowDlg(nStr, sHint);

  while True do
  begin
    nP.FParamA := FBillItems[0].FCusID;
    nP.FParamB := FBillItems[0].FStockNo;
    nP.FParamC := sFlag_Sale;
    CreateBaseFormItem(cFI_FormGetOrder, PopedomItem, @nP);

    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
    nStr := nP.FParamB;

    AnalyzeOrderInfo(nStr, nOrder);
    if nOrder.FValue >= nBillValue then Break;

    nStr := '��������������,��������: ' + #13#10#13#10 +
            '��.������: %.2f ��'  + #13#10 +
            '��.������: %.2f ��'  + #13#10 +
            '��.��  ��: %.2f ��'  + #13#10#13#10 +
            '������ѡ�񶩵�.';
    nStr := Format(nStr, [nOrder.FValue, nBillValue, nBillValue - nOrder.FValue]);
    ShowDlg(nStr, sHint);
  end;

  nStr := 'Select L_Lading,L_IsVIP,L_Seal From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FBillItems[0].FID]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then
    begin
      nStr := '������[ %s ]�Ѷ�ʧ,����ϵ����Ա.';
      nStr := Format(nStr, [FBillItems[0].FID]);

      ShowDlg(nStr, sHint);
      Exit;
    end;

    with FListA do
    begin
      Clear;
      Values['Orders'] := EncodeBase64(nOrder.FOrders);
      Values['Value'] := FloatToStr(nBillValue);
      Values['Truck'] := FBillItems[0].FTruck;
      Values['Lading'] := FieldByName('L_Lading').AsString;
      Values['IsVIP'] := FieldByName('L_IsVIP').AsString;
      Values['Seal'] := FieldByName('L_Seal').AsString;

      Values['Card'] := FBillItems[0].FCard;
      Values['Post'] := sFlag_TruckBFM;
      Values['PValue'] := FloatToStr(FBillItems[0].FPData.FValue);
    end;

    nStr := SaveBill(EncodeBase64(FListA.Text));
    //call mit bus
    if nStr = '' then Exit;

    LoadBillItems(FCardNo, False);
    //�������뽻����
  end;

  Result := True;
end;

//Date: 2014-12-29
//Parm: ��У����
//Desc: �����п������пۼ�nBillValue.
procedure TfFrameManualPoundItem.AdjustSanValue(const nBillValue: Double);
begin
  Exit;
end;

//Desc: ��������
function TfFrameManualPoundItem.SavePoundSale: Boolean;
var nStr: string;
    nVal,nNet: Double;
begin
  Result := False;
  //init

  if FBillItems[0].FNextStatus = sFlag_TruckBFP then
  begin
    if FUIData.FPData.FValue <= 0 then
    begin
      ShowMsg('���ȳ���Ƥ��', sHint);
      Exit;
    end;
  end else
  begin
    if FUIData.FMData.FValue <= 0 then
    begin
      ShowMsg('���ȳ���ë��', sHint);
      Exit;
    end;
  end;

  if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) then
  begin
    if FUIData.FPData.FValue > FUIData.FMData.FValue then
    begin
      ShowMsg('Ƥ��ӦС��ë��', sHint);
      Exit;
    end;

    nNet := FUIData.FMData.FValue - FUIData.FPData.FValue;
    //����
    nVal := nNet * 1000 - FInnerData.FValue * 1000;
    //�뿪Ʊ�����(����)

    with gSysParam,FBillItems[0] do
    begin
      if FDaiPercent and (FType = sFlag_Dai) then
      begin
        if nVal > 0 then
             FPoundDaiZ := Float2Float(FInnerData.FValue * FPoundDaiZ_1 * 1000,
                                       cPrecision, False)
        else FPoundDaiF := Float2Float(FInnerData.FValue * FPoundDaiF_1 * 1000,
                                       cPrecision, False);
      end;

      if ((FType = sFlag_Dai) and (
          ((nVal > 0) and (FPoundDaiZ > 0) and (nVal > FPoundDaiZ)) or
          ((nVal < 0) and (FPoundDaiF > 0) and (-nVal > FPoundDaiF)))) or
         ((FType = sFlag_San) and (
          (nVal < 0) and (FPoundSanF > 0) and (-nVal > FPoundSanF))) then
      begin
        nStr := '����[ %s ]ʵ��װ�������ϴ�,��������:' + #13#10#13#10 +
                '��.������: %.2f��' + #13#10 +
                '��.װ����: %.2f��' + #13#10 +
                '��.�����: %.2f����';

        if FDaiWCStop and (FType = sFlag_Dai) then
        begin
          nStr := nStr + #13#10#13#10 + '��֪ͨ˾���������.';
          nStr := Format(nStr, [FTruck, FInnerData.FValue, nNet, nVal]);

          ShowDlg(nStr, sHint);
          Exit;
        end else
        begin
          nStr := nStr + #13#10#13#10 + '�Ƿ��������?';
          nStr := Format(nStr, [FTruck, FInnerData.FValue, nNet, nVal]);
          if not QueryDlg(nStr, sAsk) then Exit;
        end;
      end;

      if (FType = sFlag_San) And (FCardUse = sFlag_Sale) then
      begin
        if nVal > 0 then
        begin
          nVal := Float2Float(nNet - FInnerData.FValue, cPrecision, True);
          if not MakeNewSanBill(nVal) then Exit;
          //ɢװ����ʱ���µ�
        end else

        if nVal < 0 then
        begin
          nVal := Float2Float(FInnerData.FValue - nNet, cPrecision, True);
          AdjustSanValue(nVal);
          //У��
        end;
      end;
    end;
  end;

  with FBillItems[0] do
  begin
    FPModel := FUIData.FPModel;
    FFactory := gSysParam.FFactNum;

    with FPData do
    begin
      FStation := FPoundTunnel.FID;
      FValue := FUIData.FPData.FValue;
      FOperator := gSysParam.FUserID;
    end;

    with FMData do
    begin
      FStation := FPoundTunnel.FID;
      FValue := FUIData.FMData.FValue;
      FOperator := gSysParam.FUserID;
    end;

    FPoundID := sFlag_Yes;
    //��Ǹ����г�������
    Result := SaveLadingBills(FNextStatus, FBillItems, FPoundTunnel);
    //�������
  end;
end;

//Desc: �������
procedure TfFrameManualPoundItem.BtnSaveClick(Sender: TObject);
var nBool: Boolean;
    nPoundID, nStr: string;
begin
  {$IFDEF MITTruckProber}
    if not IsTunnelOK(FPoundTunnel.FID) then
  {$ELSE}
    if not gProberManager.IsTunnelOK(FPoundTunnel.FID) then
  {$ENDIF}
  begin
    ShowMsg('����δվ��,���Ժ�', sHint);
    Exit;
  end;

  nBool := False;
  try
    BtnSave.Enabled := False;
    ShowWaitForm(ParentForm, '���ڱ������', True);

    if FUIData.FCardUse = sFlag_Sale then      nBool := SavePoundSale
    else if FUIData.FCardUse = sFlag_SaleNew then nBool := SavePoundSale
    else if FUIData.FCardUse = sFlag_Provide then nBool := SavePoundProvide
    else if FUIData.FCardUse = sFlag_DuanDao then nBool := SavePoundDuanDao
    else if FUIData.FCardUse = sFlag_Haulback then nBool:= SavePoundHaulBack
    else if FUIData.FCardUse = sFlag_ShipPro then nBool := SavePoundProvide
    else if FUIData.FCardUse = sFlag_ShipTmp then nBool := SavePoundProvide
    else nBool := SavePoundData(nPoundID);

    if nBool then
    begin
      PlayVoice(#9 + FUIData.FTruck);
      //��������

      Timer2.Enabled := True;
      {$IFDEF MITTruckProber}
      TunnelOC(FPoundTunnel.FID, True);
      {$ELSE}
      gProberManager.TunnelOC(FPoundTunnel.FID, True);
      {$ENDIF}
      //�����̵�
      gPoundTunnelManager.ClosePort(FPoundTunnel.FID);
      //�رձ�ͷ

      if (FUIData.FMData.FValue > 0) and (FUIData.FPData.FValue > 0) then
      begin
        nStr := GetTruckNO(FUIData.FTruck) + GetOrigin(FUIData.FOrigin) +
              '����: ' + GetValue(FUIData.FMData.FValue-FUIData.FPData.FValue);
      end else

      if FUIData.FPData.FValue > 0 then
      begin
        nStr := GetTruckNO(FUIData.FTruck) + GetOrigin(FUIData.FOrigin) +
              'ë��: ' + GetValue(FUIData.FPData.FValue);
      end;
      LEDDisplay(nStr);

      if ((FUIData.FID='') and (FUIData.FPoundID <> '')) or
         ((FUIData.FID <> '') and (FUIData.FID = FUIData.FZhiKa) and (FUIData.FPoundID <> '')) or
         RadioCC.Checked or FPreTruckPFlag then
        PrintPoundReport(nPoundID, True);
      //ԭ�ϻ����ģʽ

      SetUIData(True);
      BroadcastFrameCommand(Self, cCmd_RefreshData);

      if CheckZD.Checked then
        CollapsePanel(True, False);
      ShowMsg('���ر������', sHint);
    end else Timer_Savefail.Enabled := True;
  finally
    BtnSave.Enabled := not nBool;
    CloseWaitForm;
  end;
end;

procedure TfFrameManualPoundItem.PlaySoundWhenCardArrived;
begin
  if CheckSound.Checked and (Height = FTitleHeight) then
    gSoundPlayManager.PlaySound(gPath + 'sound.wav');
  //xxxxx
end;

function TfFrameManualPoundItem.ReDrawReadCardButton: Boolean;
var
  nRect: TRect;
  nCanvas: TCanvas;
begin
  Result := False;
  if not BtnReadCard.Enabled then Exit;

  PlaySoundWhenCardArrived;
  //��������
  CollapsePanel(False, False);
  //չ�����

  nCanvas := TCanvas.Create;
  try
    nRect := GetControlRect(BtnReadCard);
    nCanvas.Handle := GetDC(BtnReadCard.Handle);

    nCanvas.Pen.Color := clRed;
    nCanvas.Pen.Width := 10;
    nCanvas.Brush.Style := bsClear;
    nCanvas.Rectangle(nRect);
  finally
    nCanvas.Free;
  end;

  Result := True;
end;

procedure TfFrameManualPoundItem.ReadCardSync(const nCardNO: string;
  var nResult: Boolean);
begin
  nResult := ReDrawReadCardButton;
end;


procedure TfFrameManualPoundItem.CheckLockClick(Sender: TObject);
begin
  inherited;
  if CheckLock.Checked then
  begin
    with FInnerData.FMData do
    begin
      FValue := 0;
      FStation := '';
      FOperator := '';
    end;
    FInnerData.FNextStatus := sFlag_TruckBFP;
    FUIData := FInnerData;
    //ɾ��ë����Ϣ

    RadioPD.Enabled := False;
    RadioLS.Checked := True;
  end
  else
  begin
    RadioPD.Enabled := True;
    RadioPD.Checked := True;
  end;
end;

procedure TfFrameManualPoundItem.PlayVoice(const nStrtext: string);
begin
  //{$IFNDEF DEBUG}
  if Assigned(FPoundTunnel.FOptions) And
     (UpperCase(FPoundTunnel.FOptions.Values['Voice'])='NET') then
       gNetVoiceHelper.PlayVoice(nStrtext, FPoundTunnel.FID, 'pound')
  else gVoiceHelper.PlayVoice(nStrtext);
end;

procedure TfFrameManualPoundItem.LEDDisplay(const nStrtext: string);
begin
  if Assigned(FPoundTunnel.FOptions) And
     (UpperCase(FPoundTunnel.FOptions.Values['LEDEnable'])='Y') then
    gDisplayManager.Display(FPoundTunnel.FID, nStrtext);
end;

procedure TfFrameManualPoundItem.Timer_SavefailTimer(Sender: TObject);
begin
  inherited;
  try
    Timer_SaveFail.Enabled := False;

    gPoundTunnelManager.ClosePort(FPoundTunnel.FID);
    //�رձ�ͷ
    SetUIData(True);
  except
    raise;
  end;
end;

end.

{*******************************************************************************
  ����: dmzn@163.com 2014-10-20
  ����: �Զ�����ͨ����
*******************************************************************************}
unit UFramePoundAutoItem;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UMgrPoundTunnels, UBusinessConst, UFrameBase, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, StdCtrls,
  UTransEdit, ExtCtrls, cxRadioGroup, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxLabel, ULEDFont;

type
  TOrderItem = record
    FOrder: string;         //������
    FMaxValue: Double;      //������
    FKDValue: Double;       //������
  end;

  TOrderItems = array of TOrderItem;
  //�����б�

  TfFrameAutoPoundItem = class(TBaseFrame)
    GroupBox1: TGroupBox;
    EditValue: TLEDFontNum;
    GroupBox3: TGroupBox;
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
    Timer1: TTimer;
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
    Timer_ReadCard: TTimer;
    TimerDelay: TTimer;
    MemoLog: TZnTransMemo;
    Timer_SaveFail: TTimer;
    ckCloseAll: TCheckBox;
    CheckGS: TCheckBox;
    Button1: TButton;
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer_ReadCardTimer(Sender: TObject);
    procedure TimerDelayTimer(Sender: TObject);
    procedure Timer_SaveFailTimer(Sender: TObject);
    procedure ckCloseAllClick(Sender: TObject);
    procedure EditBillKeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FIsWeighting, FIsSaving: Boolean;
    //���ر�ʶ,�����ʶ
    FPoundTunnel: PPTTunnelItem;
    //��վͨ��
    FLastBT,FLastBQ: Int64;
    //�ϴλ
    FOrderItems: TOrderItems;
    //�����б�
    FBillItems: TLadingBillItems;  
    FUIData,FInnerData: TLadingBillItem;
    //��������
    FLastCardDone: Int64;
    FLastCard, FCardTmp, FLastReader: string;
    //�ϴο���, ��ʱ����, ���������
    FListA, FListB: TStrings;
    FSampleIndex: Integer;
    FValueSamples: array of Double;
    //���ݲ���
    FBarrierGate: Boolean;
    //�Ƿ���õ�բ
    FEmptyPoundInit, FDoneEmptyPoundInit: Int64;
    //�հ���ʱ,���������հ�
    FEmptyPoundIdleLong, FEmptyPoundIdleShort: Int64;
    //�ϰ�ǰ�հ���ʱ,�°���հ���ʱ
    procedure SetUIData(const nReset: Boolean; const nOnlyData: Boolean = False);
    //��������
    procedure SetImageStatus(const nImage: TImage; const nOff: Boolean);
    //����״̬
    procedure SetTunnel(const nTunnel: PPTTunnelItem);
    //����ͨ��
    procedure OnPoundDataEvent(const nValue: Double);
    procedure OnPoundData(const nValue: Double);
    //��ȡ����
    procedure LoadBillItems(const nCard: string; nUpdateUI: Boolean = True);
    //��ȡ������
    procedure InitSamples;
    procedure AddSample(const nValue: Double);
    function IsValidSamaple: Boolean;
    //�������
    function SavePoundSale: Boolean;
    function SavePoundProvide: Boolean;
    function SavePoundDuanDao: Boolean;
    function SavePoundHaulBack: Boolean;
    //�������
    procedure WriteLog(nEvent: string);
    //��¼��־
    procedure PlayVoice(const nStrtext: string);
    //��������
    procedure LEDDisplay(const nStrtext: string);
    //LED��ʾ
    function MakeNewSanBill(nBillValue: Double): Boolean;
    //ɢװ���µ�
  public
    { Public declarations }
    class function FrameID: integer; override;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    //����̳�
    property PoundTunnel: PPTTunnelItem read FPoundTunnel write SetTunnel;
    //�������
  end;

implementation

{$R *.dfm}

uses
  ULibFun, UFormBase, UMgrTruckProbe,
  UMgrRemoteVoice, UMgrVoiceNet, UDataModule, USysBusiness, UMgrLEDDisp,
  USysLoger, USysConst, USysDB, UBase64;

const
  cFlag_ON    = 10;
  cFlag_OFF   = 20;

class function TfFrameAutoPoundItem.FrameID: integer;
begin
  Result := 0;
end;

procedure TfFrameAutoPoundItem.OnCreateFrame;
begin
  inherited;
  FPoundTunnel := nil;
  FIsWeighting := False;

  FListA := TStringList.Create;
  FListB := TStringList.Create;

  FEmptyPoundInit := 0;
  FLastCardDone   := GetTickCount;
  if gSysParam.FIsAdmin then
    Button1.Visible := True;
end;

procedure TfFrameAutoPoundItem.OnDestroyFrame;
begin
  gPoundTunnelManager.ClosePort(FPoundTunnel.FID);
  //�رձ�ͷ�˿�
  FListA.Free;
  FListB.Free;
  inherited;
end;

//Desc: ��������״̬ͼ��
procedure TfFrameAutoPoundItem.SetImageStatus(const nImage: TImage;
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

procedure TfFrameAutoPoundItem.WriteLog(nEvent: string);
var nInt: Integer;
begin
  with MemoLog do
  try
    Lines.BeginUpdate;
    if Lines.Count > 20 then
     for nInt:=1 to 10 do
      Lines.Delete(0);
    //�������

    Lines.Add(DateTime2Str(Now) + #9 + nEvent);
  finally
    Lines.EndUpdate;
    Perform(EM_SCROLLCARET,0,0);
    Application.ProcessMessages;
  end;
end;

procedure WriteSysLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFrameAutoPoundItem, '�Զ�����ҵ��', nEvent);
end;

//------------------------------------------------------------------------------
//Desc: ��������״̬
procedure TfFrameAutoPoundItem.Timer1Timer(Sender: TObject);
begin
  SetImageStatus(ImageBT, GetTickCount - FLastBT > 5 * 1000);
  SetImageStatus(ImageBQ, GetTickCount - FLastBQ > 5 * 1000);
end;

//Desc: �رպ��̵�
procedure TfFrameAutoPoundItem.Timer2Timer(Sender: TObject);
begin
  Timer2.Tag := Timer2.Tag + 1;
  if Timer2.Tag < 10 then Exit;

  Timer2.Tag := 0;
  Timer2.Enabled := False;

  {$IFNDEF MITTruckProber}
  gProberManager.TunnelOC(FPoundTunnel.FID,False);
  {$ENDIF}
end;

//Desc: ����ͨ��
procedure TfFrameAutoPoundItem.SetTunnel(const nTunnel: PPTTunnelItem);
begin
  FBarrierGate := False;
  FEmptyPoundIdleLong := -1;
  FEmptyPoundIdleShort:= -1;

  FPoundTunnel := nTunnel;
  SetUIData(True);

  if Assigned(FPoundTunnel.FOptions) then
  with FPoundTunnel.FOptions do
  begin
    FBarrierGate := Values['BarrierGate'] = sFlag_Yes;
    FEmptyPoundIdleLong := StrToInt64Def(Values['EmptyIdleLong'], 60);
    FEmptyPoundIdleShort:= StrToInt64Def(Values['EmptyIdleShort'], 5);
  end;
end;

//Desc: ���ý�������
procedure TfFrameAutoPoundItem.SetUIData(const nReset,nOnlyData: Boolean);
var nStr: string;
    nInt: Integer;
    nVal: Double;
    nItem: TLadingBillItem;
begin
  if nReset then
  begin
    FillChar(nItem, SizeOf(nItem), #0);
    //init

    with nItem do
    begin
      FPModel := sFlag_PoundPD;
      FFactory := gSysParam.FFactNum;
    end;

    FUIData := nItem;
    FInnerData := nItem;
    CheckGS.Checked := False;
    if nOnlyData then Exit;

    SetLength(FBillItems, 0);
    EditValue.Text := '0.00';
    EditBill.Properties.Items.Clear;

    FIsSaving    := False;
    FEmptyPoundInit := 0;
    if FLastCardDone = 0 then
      FLastCardDone   := GetTickCount;
    //��ֹ49.71���ϵͳ����Ϊ0

    if not FIsWeighting then
    begin
      gPoundTunnelManager.ClosePort(FPoundTunnel.FID);
      //�رձ�ͷ�˿�

      Timer_ReadCard.Enabled := True;
      //��������
    end;
  end;

  with FUIData do
  begin
    EditBill.Text := FID;
    EditTruck.Text := FTruck;
    EditMID.Text := FStockName;
    EditPID.Text := FCusName;

    EditMValue.Text := Format('%.2f', [FMData.FValue]);
    EditPValue.Text := Format('%.2f', [FPData.FValue]);
    EditZValue.Text := Format('%.2f', [FValue]);

    if (FValue > 0) and (FMData.FValue > 0) and (FPData.FValue > 0) then
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

    RadioLS.Enabled := (FPoundID = '') and (FID = '');
    //�ѳƹ�����������,������ʱģʽ
    RadioCC.Enabled := FID <> '';
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
      EditMemo.Text := nStr + '��Ƥ��';
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
procedure TfFrameAutoPoundItem.LoadBillItems(const nCard: string;
 nUpdateUI: Boolean);
var nStr,nHint,nVoice,nPos: string;
    nIdx,nInt,nLast: Integer;
    nBills: TLadingBillItems;
    nCardUsed: string;
begin
  nStr := Format('��ȡ������[ %s ],��ʼִ��ҵ��.', [nCard]);
  WriteLog(nStr);

  if (not GetLadingBills(nCard, sFlag_TruckBFP, nBills)) or
     (Length(nBills) < 1) then
  begin
    nVoice := '��ȡ�ſ���Ϣʧ��,����ϵ����Ա';
    PlayVoice(nVoice);
    WriteLog(nVoice);
    SetUIData(True);
    Exit;
  end;

  if (nBills[0].FPoundStation <> '') and
     (nBills[0].FPoundStation <> FPoundTunnel.FID) then
  begin
    nVoice := '%s�뵽%s����';
    nVoice := Format(nVoice, [nBills[0].FTruck, nBills[0].FPoundSName]);
    PlayVoice(nVoice);
    WriteLog(nVoice);
    SetUIData(True);
    Exit;
  end;

  {$IFDEF RemoteSnap}
  if not VerifySnapTruck(FLastReader, nBills[0], nHint, nPos) then
  begin
    nVoice := '%s����ʶ��ʧ��,���ƶ���������ϵ����Ա';
    nVoice := Format(nVoice, [nBills[0].FTruck]);
    PlayVoice(nHint);
    RemoteSnapDisPlay(nPos, nHint,sFlag_No);
    WriteSysLog(nHint);
    SetUIData(True);
    Exit;
  end
  else
  begin
    if nHint <> '' then
    begin
      RemoteSnapDisPlay(nPos, nHint,sFlag_Yes);
      WriteSysLog(nHint);
    end;
  end;
  {$ENDIF}

  nLast := -1;
  if GetTruckLastTime(nBills[0].FTruck, nLast) and (nLast > 0) and
     (nLast < FPoundTunnel.FCardInterval) then
  begin
    nStr := '����[ %s ]��ȴ� %d �����ܹ���';
    nStr := Format(nStr, [nBills[0].FTruck, FPoundTunnel.FCardInterval - nLast]);
    WriteLog(nStr);

    nStr := Format('��վ[ %s.%s ]: ',[FPoundTunnel.FID,
            FPoundTunnel.FName]) + nStr;
    WriteSysLog(nStr);

    SetUIData(True);
    Exit;
  end;

  nHint := '';
  nInt := 0;

  nCardUsed := GetCardUsed(nCard);

  for nIdx:=Low(nBills) to High(nBills) do
  with nBills[nIdx] do
  begin
    if (FStatus <> sFlag_TruckBFP) and (FNextStatus = sFlag_TruckZT) then
      FNextStatus := sFlag_TruckBFP;
    //״̬У��
    {$IFDEF AllowMultiM}
    if (nCardUsed = sFlag_Sale) and (nBills[nIdx].FType = sFlag_San) then
    begin
      if (FStatus = sFlag_TruckBFM) then
        FNextStatus := sFlag_TruckBFM;
      //�����ι���
    end;
    {$ENDIF}

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

    nVoice := '���� %s ���ܹ���,Ӧ��ȥ %s ';
    nVoice := Format(nVoice, [FTruck, TruckStatusToStr(FNextStatus)]);
  end;

  if nInt = 0 then
  begin
    PlayVoice(nVoice);
    //����״̬�쳣

    nHint := '�ó�����ǰ���ܹ���,��������: ' + #13#10#13#10 + nHint;
    WriteSysLog(nStr);
    SetUIData(True);
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
      if (FCardUse = sFlag_Sale) or (FCardUse = sFlag_SaleNew) then
        FPoundID := '';
      //�ñ����������;
      
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

  InitSamples;
  //��ʼ������

  if not FPoundTunnel.FUserInput then
  if not gPoundTunnelManager.ActivePort(FPoundTunnel.FID,
         OnPoundDataEvent, True) then
  begin
    nHint := '���ӵذ���ͷʧ�ܣ�����ϵ����Ա���Ӳ������';
    WriteSysLog(nHint);
    PlayVoice(nHint);

    SetUIData(True);
    Exit;
  end;

  Timer_ReadCard.Enabled := False;
  FDoneEmptyPoundInit := 0;
  FIsWeighting := True;
  //ֹͣ����,��ʼ����

  if FBarrierGate then
  begin
    nStr := '[n1]%sˢ���ɹ����ϰ�,��Ϩ��ͣ��';
    nStr := Format(nStr, [FUIData.FTruck]);
    PlayVoice(nStr);
    //�����ɹ���������ʾ

    {$IFNDEF DEBUG}
    OpenDoorByReader(FLastReader);
    //������բ
    {$ENDIF}
  end;
  //�����ϰ�
end;

//------------------------------------------------------------------------------
//Desc: �ɶ�ʱ��ȡ������
procedure TfFrameAutoPoundItem.Timer_ReadCardTimer(Sender: TObject);
var nStr,nCard: string;
    nLast, nDoneTmp: Int64;
begin
  {$IFNDEF VerfiyAutoWeight}
  if gSysParam.FIsManual then Exit;
  {$ENDIF}
  Timer_ReadCard.Tag := Timer_ReadCard.Tag + 1;
  if Timer_ReadCard.Tag < 5 then Exit;

  Timer_ReadCard.Tag := 0;
  if FIsWeighting then Exit;

  //ǰ��δ�°����󳵽�ֹˢ��
  if ImageBT.Tag = cFlag_ON then Exit;

  try
    WriteLog('���ڶ�ȡ�ſ���.');
    nCard := Trim(ReadPoundCard(FLastReader, FPoundTunnel.FID));
    if nCard = '' then Exit;

    if nCard <> FLastCard then
         nDoneTmp := 0
    else nDoneTmp := FLastCardDone;
    //�¿�ʱ����

    WriteSysLog('��ȡ���¿���:::' + nCard + '=>�ɿ���:::' + FLastCard);
    nLast := Trunc((GetTickCount - nDoneTmp) / 1000);
    if (nLast < FPoundTunnel.FCardInterval) And (nDoneTmp <> 0) then
    begin
      nStr := '�ſ�[ %s ]��ȴ� %d �����ܹ���';
      nStr := Format(nStr, [nCard, FPoundTunnel.FCardInterval - nLast]);
      WriteLog(nStr);

      nStr := Format('��վ[ %s.%s ]: ',[FPoundTunnel.FID,
              FPoundTunnel.FName]) + nStr;
      WriteSysLog(nStr);

      SetUIData(True);
      Exit;
    end;

    FCardTmp := nCard;
    EditBill.Text := nCard;
    LoadBillItems(EditBill.Text);
  except
    on E: Exception do
    begin
      nStr := Format('��վ[ %s.%s ]: ',[FPoundTunnel.FID,
              FPoundTunnel.FName]) + E.Message;
      WriteSysLog(nStr);

      SetUIData(True);
      //����������
    end;
  end;
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
function TfFrameAutoPoundItem.MakeNewSanBill(nBillValue: Double): Boolean;
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

  if nStr = '' then
  begin
    nStr := '��ȡ������Ϣʧ��,����ϵ����Ա';
    WriteSysLog(nStr);
    PlayVoice(nStr);
    Exit;
  end;

  with FDM.QueryTemp(nStr, True) do
  begin
    if RecordCount < 1 then
    begin
      nStr := StringReplace(FListA.Text, #13#10, ',', [rfReplaceAll]);
      nStr := Format('����[ %s ]��Ϣ�Ѷ�ʧ.', [nStr]);
      WriteSysLog(nStr);

      PlayVoice('������Ϣ�Ѷ�ʧ');
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

  if not GetOrderFHValue(FListA) then
  begin
    nStr := '��ȡ����ʣ����ʧ��,����ϵ����Ա';
    WriteSysLog(nStr);
    PlayVoice(nStr);
    Exit;
  end;  
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
      WriteSysLog(E.Message);
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

  nStr := 'Select L_Lading,L_IsVIP,L_Seal,L_StockBrand From %s Where L_ID=''%s''';
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

      Values['Brand'] := FieldByName('L_StockBrand').AsString;
    end;

    nStr := SaveBill(EncodeBase64(FListA.Text));
    //call mit bus
    if nStr = '' then Exit;

    LoadBillItems(FCardTmp, False);
    //�������뽻����
  end;

  Result := True;
end;

//Desc: ��������
function TfFrameAutoPoundItem.SavePoundSale: Boolean;
var nVal,nNet: Double;
    nStr, nHint, nMemo: string;
begin
  Result := False;
  //init

  {$IFNDEF AutoSan}
  if FUIData.FType = sFlag_San then
  begin
    nStr := 'ɢװ����[%s]�������ڴ˹���';
    nStr := Format(nStr, [FBillItems[0].FTruck]);
    PlayVoice(nStr);
    WriteLog(nStr);
    Exit;
  end;
  {$ENDIF}

  with FUIData, gSysParam do
  if (FType = sFlag_San) and (FNextStatus = sFlag_TruckBFP) then
  begin
    nNet := GetTruckEmptyValue(FTruck);
    nVal := FPData.FValue * 1000 - nNet * 1000;

    if (nNet > 0) and
       (((nVal > 0) and (FPoundPZ > 0) and (nVal > FPoundPZ)) or
        ((nVal < 0) and (FPoundPF > 0) and (-nVal > FPoundPF))) then
    begin
      nHint := '����[ %s ]ʵʱƤ�����ϴ�,��������:' + #13#10 +
              '��.ʵʱƤ��: %.2f��' + #13#10 +
              '��.��ʷƤ��: %.2f��' + #13#10 +
              '��.�����: %.2f����' + #13#10 +
              '�������,��ѡ��;��ֹ����,��ѡ��;���ûؿ�ҵ��,��ѡ�ؿ�.';
      nHint := Format(nHint, [FTruck, FPData.FValue, nNet, nVal]);

      if not VerifyManualEventRecord(FID + sFlag_ManualB, nHint) then
      begin
        nMemo := 'Truck=%s;PStation=%s;Pound_PValue=%.2f;Pound_Card=%s';
        nMemo := Format(nMemo, [FTruck, FPoundTunnel.FID, FPData.FValue, FCard]);
        
        AddManualEventRecord(FID + sFlag_ManualB, FTruck, nHint,
            sFlag_DepBangFang, sFlag_Solution_YNP, sFlag_DepDaTing, True, nMemo);
        WriteSysLog(nHint);

        nHint := '[n1]%sƤ�س���Ԥ��,���°���ϵ��ƱԱ������ٴι���';
        nHint := Format(nHint, [FTruck]);
        PlayVoice(nHint);
        Exit;
      end;
      //�ж�Ƥ���Ƿ񳬲�
    end;
  end;

  if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) and
     (FUIData.FYSValid <> sFlag_Yes) then //�ǿճ�����
  begin
    if FUIData.FPData.FValue > FUIData.FMData.FValue then
    begin
      nStr := 'Ƥ��%.2f��ӦС��ë��%.2f��,����ϵ����Ա����';
      nStr := Format(nStr, [FUIData.FPData.FValue, FUIData.FMData.FValue]);
      WriteSysLog(nStr);
      PlayVoice(nStr);
      Exit;
    end;

    nNet := FUIData.FMData.FValue - FUIData.FPData.FValue;
    //����
    nVal := nNet * 1000 - FInnerData.FValue * 1000;
    //�뿪Ʊ�����(����)

    with gSysParam,FBillItems[0] do
    begin
      {$IFDEF DaiStepWuCha}
      if FType = sFlag_Dai then
      begin
        GetPoundAutoWuCha(FPoundDaiZ, FPoundDaiF, FInnerData.FValue);
        //�������
      end;
      {$ELSE}
      if FDaiPercent and (FType = sFlag_Dai) then
      begin
        if nVal > 0 then
             FPoundDaiZ := Float2Float(FInnerData.FValue * FPoundDaiZ_1 * 1000,
                                       cPrecision, False)
        else FPoundDaiF := Float2Float(FInnerData.FValue * FPoundDaiF_1 * 1000,
                                       cPrecision, False);
      end;
      {$ENDIF}

      if ((FType = sFlag_Dai) and (
          ((nVal > 0) and (FPoundDaiZ > 0) and (nVal > FPoundDaiZ)) or
          ((nVal < 0) and (FPoundDaiF > 0) and (-nVal > FPoundDaiF)))) then
      begin
        nHint := '����[ %s ]ʵ��װ�������ϴ�,��������:' + #13#10 +
                '��.������: %.2f��' + #13#10 +
                '��.װ����: %.2f��' + #13#10 +
                '��.�����: %.2f����' + #13#10 +
                '�����Ϻ�,���ȷ�����¹���.';
        nHint := Format(nHint, [FTruck, FInnerData.FValue, nNet, nVal]);

        if not VerifyManualEventRecord(FID + sFlag_ManualC, nHint, sFlag_Yes,
          False) then
        begin
          AddManualEventRecord(FID + sFlag_ManualC, FTruck, nHint,
            sFlag_DepBangFang, sFlag_Solution_YN, sFlag_DepJianZhuang, True);
          WriteSysLog(nHint);

          nHint := '����[n1]%s����[n2]%.2f��,��Ʊ��[n2]%.2f��,'+
                   '�����[n2]%.2f����,��ȥ��װ���';
          nHint := Format(nHint, [FTruck,nNet,FInnerData.FValue,nVal]);
          PlayVoice(nHint);
          Exit;
        end;
      end;

      if (FType = sFlag_San) and FloatRelation(nNet, FValue, rtGreater) and
         GetPoundSanWuChaStop(FStockNo) then
      begin
        nStr := '���� %s ���� %.2f �ֳ��� %.2f ��,��ȥ�ֳ�ж��';
        nStr := Format(nStr, [FTruck, nNet, nNet - FValue]);
        PlayVoice(nStr);

        WriteSysLog(nStr);
        Exit;
      end;

      {$IFNDEF CZNF}
      if (FType = sFlag_San) And (FCardUse = sFlag_Sale) then
      begin
        if nVal > 0 then
        begin
          nStr := '���� %s ���� %.2f �ֳ��� %.2f ��,����ϵ����Ա';
          nStr := Format(nStr, [FTruck, nNet, nNet - FValue]);
          PlayVoice(nStr);

          WriteSysLog(nStr);
          nVal := Float2Float(nNet - FInnerData.FValue, cPrecision, True);
          if not MakeNewSanBill(nVal) then Exit;
          //ɢװ����ʱ���µ�
        end;
      end;
      {$ENDIF}
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

function TfFrameAutoPoundItem.SavePoundProvide: Boolean;
var nVal, nNet, nPlan: Double;
    nStr,nNextStatus: string;
begin
  Result := False;
  //init

  if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) and
     (FUIData.FCardUse <> sFlag_ShipTmp) and (FUIData.FMuiltiType <> sFlag_Yes) then
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
        WriteSysLog(nStr);

        PlayVoice('�ɹ���������Ч');
        Exit;
      end;

      nPlan := FieldByName('NPLANNUM').AsFloat;
    end;

    FListB.Clear;
    FListB.Add(FUIData.FExtID_2);
    if not GetOrderGYValue(FListB) then Exit;

    nVal := nPlan - StrToFloat(FListB.Values[FUIData.FExtID_2]); 
    nNet := FUIData.FMData.FValue - FUIData.FPData.FValue;

    if FloatRelation(nVal, nNet, rtLE) then
    begin
      nStr := 'NC�������������㣬����ϵ����Ա���°쿨';
      WriteSysLog(nStr);

      PlayVoice(nStr);
      LEDDisplay(nStr);
      Exit;
    end;
  end;

  if FUIData.FPreTruckP then
  begin
    if (FUIData.FPData.FValue <= 0) or (FUIData.FMData.FValue <= 0) then
    begin
      nStr := '�ó�����ҪԤ��Ƥ�أ�������ϵ����ԱԤ��Ƥ��';
      WriteSysLog(nStr);

      PlayVoice(nStr);
      LEDDisplay(nStr);
      Exit;
    end;
  end;

  if FUIData.FPreTruckP then
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
function TfFrameAutoPoundItem.SavePoundDuanDao: Boolean;
begin
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
function TfFrameAutoPoundItem.SavePoundHaulBack: Boolean;
var nNextStatus, nHint: string;
    nNet, nVal: Double;
begin
  Result := False;
  //init

  with FUIData, gSysParam do
  if (FPData.FValue > 0) and (FMData.FValue > 0) then
  begin
    nNet := GetTruckEmptyValue(FTruck);
    nVal := FPData.FValue * 1000 - nNet * 1000;

    if (nNet > 0) and
       (((nVal > 0) and (FPoundPZ > 0) and (nVal > FPoundPZ)) or
        ((nVal < 0) and (FPoundPF > 0) and (-nVal > FPoundPF))) then
    begin
      nHint := '[n1]%sƤ�س���Ԥ��%.2f����,���°�ж�����ٴι���';
      nHint := Format(nHint, [FTruck, nVal]);
      WriteSysLog(nHint);
      PlayVoice(nHint);
      Exit;
      //�ж�Ƥ���Ƿ񳬲�
    end;
  end;

  nNextStatus := FBillItems[0].FNextStatus;
  //�������ʱ��һ״̬

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


//Desc: ��ȡ��ͷ����
procedure TfFrameAutoPoundItem.OnPoundDataEvent(const nValue: Double);
begin
  try
    if FIsSaving then Exit;
    //���ڱ��档����

    OnPoundData(nValue);
  except
    on E: Exception do
    begin
      WriteSysLog(Format('��վ[ %s.%s ]: %s', [FPoundTunnel.FID,
                                               FPoundTunnel.FName, E.Message]));
      SetUIData(True);
    end;
  end;
end;

//Desc: �����ͷ����
procedure TfFrameAutoPoundItem.OnPoundData(const nValue: Double);
var nRet: Boolean;
    nStr: string;
    nInt: Int64;
begin
  FLastBT := GetTickCount;
  EditValue.Text := Format('%.2f', [nValue]);

  if not FIsWeighting then Exit;
  //���ڳ�����

  {$IFNDEF VerfiyAutoWeight}
  if gSysParam.FIsManual then Exit;
  //�ֶ�ʱ��Ч
  {$ENDIF}

  if (nValue < 0.02) or
    FloatRelation(nValue, FPoundTunnel.FPort.FMinValue, rtLE, 1000) then //�հ�
  begin
    if FEmptyPoundInit = 0 then
      FEmptyPoundInit := GetTickCount;
    nInt := GetTickCount - FEmptyPoundInit;

    if (nInt > FEmptyPoundIdleLong * 1000) then
    begin
      FIsWeighting :=False;
      Timer_SaveFail.Enabled := True;

      WriteSysLog('ˢ����˾������Ӧ,�˳�����.');
      Exit;
    end;
    //�ϰ�ʱ��,�ӳ�����

    if (nInt > FEmptyPoundIdleShort * 1000) and   //��֤�հ�
       (FDoneEmptyPoundInit>0) and (GetTickCount-FDoneEmptyPoundInit>nInt) then
    begin
      FIsWeighting :=False;
      Timer_SaveFail.Enabled := True;

      WriteSysLog('˾�����°�,�˳�����.');
      Exit;
    end;
    //�ϴα���ɹ���,�հ���ʱ,��Ϊ�����°�

    Exit;
  end else
  begin
    FEmptyPoundInit := 0;
    if FDoneEmptyPoundInit > 0 then
      FDoneEmptyPoundInit := GetTickCount;
    //����������Ϻ�δ�°�
  end;

  AddSample(nValue);
  if not IsValidSamaple then Exit;
  //������֤��ͨ��

  if Length(FBillItems) <= 0 then Exit;
  //�˳�����

  if (FUIData.FCardUse=sFlag_Sale) or (FUIData.FCardUse = sFlag_SaleNew) or
     (FUIData.FCardUse=sFlag_DuanDao) then
  begin
    if FUIData.FNextStatus = sFlag_TruckBFP then
         FUIData.FPData.FValue := nValue
    else FUIData.FMData.FValue := nValue;
  end else
  begin
    if FInnerData.FPData.FValue > 0 then
    begin
      if nValue <= FInnerData.FPData.FValue then
      begin
        FUIData.FPData := FInnerData.FMData;
        FUIData.FMData := FInnerData.FPData;

        FUIData.FPData.FValue := nValue;
        FUIData.FNextStatus := sFlag_TruckBFP;
        //�л�Ϊ��Ƥ��
      end else
      begin
        FUIData.FPData := FInnerData.FPData;
        FUIData.FMData := FInnerData.FMData;

        FUIData.FMData.FValue := nValue;
        FUIData.FNextStatus := sFlag_TruckBFM;
        //�л�Ϊ��ë��
      end;
    end else FUIData.FPData.FValue := nValue;
  end;
  SetUIData(False);
  //������ʾ��Ϣ

  {$IFDEF MITTruckProber}
    if (not CheckGS.Checked) and (not IsTunnelOK(FPoundTunnel.FID)) then
  {$ELSE}
    {$IFNDEF TruckProberEx}
    if (not CheckGS.Checked) and (not gProberManager.IsTunnelOK(FPoundTunnel.FID)) then
    {$ELSE}
    if (not CheckGS.Checked) and (not gProberManager.IsTunnelOKEx(FPoundTunnel.FID)) then
    {$ENDIF}
  {$ENDIF}
  begin
    nStr := '����δͣ��λ,���ƶ�����.';
    PlayVoice(nStr);
    WriteSysLog(nStr);
    InitSamples;
    //LEDDisplay(nStr);
    Exit;
  end;

  FIsSaving := True;
  if FUIData.FCardUse = sFlag_Sale then      nRet := SavePoundSale
  else if FUIData.FCardUse = sFlag_SaleNew then nRet := SavePoundSale
  else if FUIData.FCardUse = sFlag_DuanDao then nRet := SavePoundDuanDao
  else if FUIData.FCardUse = sFlag_Haulback then nRet:= SavePoundHaulBack
  else if FUIData.FCardUse = sFlag_Provide then nRet := SavePoundProvide
  else if FUIData.FCardUse = sFlag_ShipPro then nRet := SavePoundProvide
  else if FUIData.FCardUse = sFlag_ShipTmp then nRet := SavePoundProvide
  else nRet := False;

  if nRet then
  begin
    nStr := GetTruckNO(FUIData.FTruck) + '����  ' + GetValue(nValue);
    LEDDisplay(nStr);
    
    TimerDelay.Enabled := True;
  end else Timer_SaveFail.Enabled := True;

  if FBarrierGate then
  begin
    {$IFDEF ERROPENONEDOOR}
    if not nRet then
    begin
      OpenDoorByReader(FLastReader, sFlag_Yes);
      Exit;
    end;
    {$ENDIF}

    if FUIData.FOneDoor = sFlag_Yes then
         OpenDoorByReader(FLastReader, sFlag_Yes)
    else OpenDoorByReader(FLastReader, sFlag_No);
  end;
  //�򿪸���բ
end;

procedure TfFrameAutoPoundItem.TimerDelayTimer(Sender: TObject);
begin
  try
    TimerDelay.Enabled := False;
    FLastCardDone := GetTickCount;
    FDoneEmptyPoundInit := GetTickCount;
    WriteLog(Format('�Գ���[ %s ]�������.', [FUIData.FTruck]));

    PlayVoice(#9 + FUIData.FTruck);
    //��������

    FLastCard := FCardTmp;
    Timer2.Enabled := True;

    if not FBarrierGate then
      FIsWeighting := False;
    //�����޵�բʱ����ʱ�������

    {$IFDEF MITTruckProber}
    TunnelOC(FPoundTunnel.FID, True);
    {$ELSE}
    gProberManager.TunnelOC(FPoundTunnel.FID, True);
    {$ENDIF} //�����̵�
    SetUIData(True);
  except
    on E: Exception do
    begin
      WriteSysLog(Format('��վ[ %s.%s ]: %s', [FPoundTunnel.FID,
                                               FPoundTunnel.FName, E.Message]));
      //loged
    end;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ��ʼ������
procedure TfFrameAutoPoundItem.InitSamples;
var nIdx: Integer;
begin
  SetLength(FValueSamples, FPoundTunnel.FSampleNum);
  FSampleIndex := Low(FValueSamples);

  for nIdx:=High(FValueSamples) downto FSampleIndex do
    FValueSamples[nIdx] := 0;
  //xxxxx
end;

//Desc: ��Ӳ���
procedure TfFrameAutoPoundItem.AddSample(const nValue: Double);
begin
  FValueSamples[FSampleIndex] := nValue;
  Inc(FSampleIndex);

  if FSampleIndex >= FPoundTunnel.FSampleNum then
    FSampleIndex := Low(FValueSamples);
  //ѭ������
end;

//Desc: ��֤�����Ƿ��ȶ�
function TfFrameAutoPoundItem.IsValidSamaple: Boolean;
var nIdx: Integer;
    nVal: Integer;
begin
  Result := False;

  for nIdx:=FPoundTunnel.FSampleNum-1 downto 1 do
  begin
    if FValueSamples[nIdx] < FPoundTunnel.FPort.FMinValue then Exit;
    //����������

    nVal := Trunc(FValueSamples[nIdx] * 1000 - FValueSamples[nIdx-1] * 1000);
    if Abs(nVal) >= FPoundTunnel.FSampleFloat then Exit;
    //����ֵ����
  end;

  Result := True;
end;

procedure TfFrameAutoPoundItem.PlayVoice(const nStrtext: string);
begin
  if Assigned(FPoundTunnel.FOptions) And
     (UpperCase(FPoundTunnel.FOptions.Values['Voice'])='NET') then
       gNetVoiceHelper.PlayVoice(nStrtext, FPoundTunnel.FID, 'pound')
  else gVoiceHelper.PlayVoice(nStrtext);
end;

procedure TfFrameAutoPoundItem.LEDDisplay(const nStrtext: string);
var nIdx: Integer;
begin
  WriteSysLog(Format('LEDDisplay:%s.%s', [FPoundTunnel.FID, nStrtext]));
  for nIdx := 1 to 1 do
  begin
    {$IFDEF MITTruckProber}
    ProberShowTxt(FPoundTunnel.FID, nStrtext);
    {$ELSE}
    gProberManager.ShowTxt(FPoundTunnel.FID, nStrtext);
    {$ENDIF}
  end;
  if Assigned(FPoundTunnel.FOptions) And
     (UpperCase(FPoundTunnel.FOptions.Values['LEDEnable'])='Y') then
    gDisplayManager.Display(FPoundTunnel.FID, nStrtext);
end;

procedure TfFrameAutoPoundItem.Timer_SaveFailTimer(Sender: TObject);
begin
  inherited;
  try
    FDoneEmptyPoundInit := GetTickCount;
    Timer_SaveFail.Enabled := False;
    SetUIData(True);
  except
    on E: Exception do
    begin
      WriteSysLog(Format('��վ[ %s.%s ]: %s', [FPoundTunnel.FID,
                                               FPoundTunnel.FName, E.Message]));
      //loged
    end;
  end;
end;

procedure TfFrameAutoPoundItem.ckCloseAllClick(Sender: TObject);
var nP: TWinControl;
begin
  nP := Parent;

  if ckCloseAll.Checked then
  while Assigned(nP) do
  begin
    if (nP is TBaseFrame) and
       (TBaseFrame(nP).FrameID = cFI_FramePoundAuto) then
    begin
      TBaseFrame(nP).Close();
      Exit;
    end;

    nP := nP.Parent;
  end;
end;

procedure TfFrameAutoPoundItem.EditBillKeyPress(Sender: TObject;
  var Key: Char);
begin
  inherited;
  if Key = #13 then
  begin
    Key := #0;
    if EditBill.Properties.ReadOnly then Exit;

    EditBill.Text := Trim(EditBill.Text);
    LoadBillItems(EditBill.Text);
  end;
end;

procedure TfFrameAutoPoundItem.Button1Click(Sender: TObject);
begin
  LEDDisplay('12345');
end;

end.

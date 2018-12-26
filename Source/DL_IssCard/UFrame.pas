unit UFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, StdCtrls, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient,PLCController, ULEDFont, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit,
  cxTextEdit, cxLabel, cxMaskEdit, cxDropDownEdit, UMgrBXFontCard,
  ExtCtrls, IdTCPServer, IdContext, IdGlobal, UBusinessConst, ULibFun,
  Menus, cxButtons, UMgrSendCardNo, USysLoger, cxCurrencyEdit, dxSkinsCore,
  dxSkinsDefaultPainters, cxSpinEdit, DateUtils,UMgrKeyboardTunnels,
  UMgrTTCEDispenser, USysBusiness;

type
  TFrame1 = class(TFrame)
    ToolBar1: TToolBar;
    ToolButton2: TToolButton;
    btnPause: TToolButton;
    ToolButton6: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton1: TToolButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    EditValue: TcxTextEdit;
    MemoLog: TMemo;
    InitTimer: TTimer;
    GetTruckTimer: TTimer;
    procedure InitTimerTimer(Sender: TObject);
    procedure GetTruckTimerTimer(Sender: TObject);
  private
    { Private declarations }
    FKeyBoardTunnel: PPTTunnelItem;  //��վͨ��
    FSnapPost: string;//ץ�ĸ�λ
    FLastTruck, FTruck: string;//��ͨ��ʵʱ��ȡ�����³��ƺ�
    FIdx  : Integer;
    FSaveMsg: string;//����ʱ��������Ϣ
    FTTCEK720ID: string;//��Ӧ������ID
    procedure OnKeyBoardDataEvent(const nKey: string);
    procedure OnKeyBoardData(const nKey: string);
    //��ȡ����
    procedure SetTunnel(const Value: PPTTunnelItem);
    procedure WriteLog(const nEvent: string);
    function IfCanSaveOrder(const nID, nTruck:string; var nMsg:string):Boolean;
  public
    FrameId:Integer;              //PLCͨ��
    FSysLoger : TSysLoger;
    FTCPSer:TIdTCPServer;
    property KeyBoardTunnel: PPTTunnelItem read FKeyBoardTunnel write SetTunnel;
    procedure StartRead;
    //����
  end;

implementation

{$R *.dfm}

uses
   USysDB, USysConst, UDataModule, UFormInputbox, UBase64;

//Parm: �ſ��򽻻�����
//Desc: ��ȡnCard��Ӧ�Ľ�����
procedure TFrame1.StartRead;
var
  nStr, nHint, nTmp: string;
  nIdx : Integer;
begin
  EditValue.Text := '';
  FLastTruck := '';
  FTruck := '';
  FIdx := 0;

  if Assigned(FKeyBoardTunnel.FOptions) And
     (FKeyBoardTunnel.FOptions.Values['SnapPost'] <> '') then
  begin
    FSnapPost := FKeyBoardTunnel.FOptions.Values['SnapPost'];
    FTTCEK720ID := FKeyBoardTunnel.FOptions.Values['TTCEK720ID'];
  end
  else
  begin
    FSnapPost := 'SIn';
    FTTCEK720ID := 'FK001';
  end;

  for nIdx := Low(gPurOrderItems) to High(gPurOrderItems) do
  begin
    if FKeyBoardTunnel.FID = gPurOrderItems[nIdx].FTunnelID then
    begin
      FIdx := nIdx;
      Break;
    end;
  end;
  if not gKeyBoardTunnelManager.ActivePort(FKeyBoardTunnel.FID,
         OnKeyBoardDataEvent, True) then
  begin
    nHint := '���Ӽ���ʧ�ܣ�����ϵ����Ա���Ӳ������';
    WriteLog(nHint);
    Exit;
  end;
end;

procedure TFrame1.OnKeyBoardDataEvent(const nKey: string);
begin
  try
    OnKeyBoardData(nKey);
  except
    on E: Exception do
    begin
      WriteLog(Format('����[ %s.%s ]: %s', [FKeyBoardTunnel.FID,
                                               FKeyBoardTunnel.FName, E.Message]));
    end;
  end;
end;

procedure TFrame1.OnKeyBoardData(const nKey: string);
var
  nStr, nHint: string;
  nIdx: Integer;
  nClear: Boolean;
begin
  if FTruck = '' then
  begin
    nStr := 'δʶ�𵽳��ƺ�';
    PlayVoice(FKeyBoardTunnel.FID, nStr);
    LEDDisplay(FKeyBoardTunnel.FID, nStr);
    WriteLog(nStr);
    Exit;
  end;
  if InitTimer.Enabled then
  begin
    WriteLog(FKeyBoardTunnel.FID + '�쿨��,������Ч...');
    Exit;
  end;
  nClear := False;
  if not IsNumber(nKey,False) then
  begin
    for nIdx := 0 to Length(nKey) do
      nStr := nStr + IntToStr(ord(nKey[nIdx]));
    if Pos('08',nStr) > 0 then//���
    begin
      nClear := True;
      PlayVoice(FKeyBoardTunnel.FID, '���');
    end
    else
    if Pos('013',nStr) > 0 then//ȷ��
    begin
      nStr := EditValue.Text;
      nHint := '';
      EditValue.Text := '';
      gPurOrderItems[FIdx].FMsg := '';
      LEDDisplay(FKeyBoardTunnel.FID, '��ʼ�쿨,���Ժ�...');
      PlayVoice(FKeyBoardTunnel.FID, '��ʼ�쿨,���Ժ�');

      InitTimer.Tag := 20;
      FSaveMsg := '';
      InitTimer.Enabled := True;
      if not IfCanSaveOrder(nStr,FTruck,nHint) then
      begin
        gPurOrderItems[FIdx].FCanSave := False;
        if nHint <> '' then
        begin
          LEDDisplay(FKeyBoardTunnel.FID, nHint);
          PlayVoice(FKeyBoardTunnel.FID, nHint);
        end;
      end;
      Exit;
    end;
  end
  else
  begin
    nStr := nKey;
    PlayVoice(FKeyBoardTunnel.FID, nStr);
  end;

  if MemoLog.Lines.Count > 100 then
    MemoLog.Lines.Clear;
  MemoLog.Lines.Add('��������:'+ nStr);
  WriteLog(FKeyBoardTunnel.FID + '��������:'+ nStr);
  if nClear then//���
  begin
    EditValue.Text := '';
    LEDDisplay(FKeyBoardTunnel.FID, '������쿨����...');
    Exit;
  end;
  EditValue.Text := EditValue.Text + nStr;
  LEDDisplay(FKeyBoardTunnel.FID, EditValue.Text);
end;

procedure TFrame1.WriteLog(const nEvent: string);
begin
  FSysLoger.AddLog(TFrame, '�ɹ��쿨', nEvent);
end;

procedure TFrame1.SetTunnel(const Value: PPTTunnelItem);
begin
  FKeyBoardTunnel := Value;
end;

function TFrame1.IfCanSaveOrder(const nID, nTruck:string; var nMsg:string):Boolean;
var
  nSQL: string;
  nListA, nListB: TStrings;
  nCount: Integer;
begin
  Result := False;

  nSQL := 'select P_Card from %s where P_Truck =''%s'' and P_Status <>''%s''';
  nSQL := Format(nSQL, [sTable_CardProvide, nTruck, sFlag_TruckOut]);
  with FDM.QueryTemp(nSQL) do
  begin
    if RecordCount>0 then
    begin
      if Fields[0].AsString <> '' then
      begin
        nMsg := '����%s����δ��ɵĲɹ�����,�޷��쿨';
        nMsg := Format(nMsg, [nTruck]);
        Exit;
      end;
    end;
  end;

  gPurOrderItems[FIdx].FOrder_id := '';
  gPurOrderItems[FIdx].FZhiKaNo  := '';
  gPurOrderItems[FIdx].FProvID   := '';
  gPurOrderItems[FIdx].FProvName := '';

  gPurOrderItems[FIdx].FgoodsID  := '';
  gPurOrderItems[FIdx].FGoodsname:= '';
  gPurOrderItems[FIdx].FMaxMum   := '';

  gPurOrderItems[FIdx].FData := '';
  gPurOrderItems[FIdx].FTrackNo := '';
  gPurOrderItems[FIdx].FArea    := '';
  gPurOrderItems[FIdx].FCanSave := False;

  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    nListA.Clear;
    nListA.Text:= DecodeBase64(GetNcOrderList(nID));

    if nListA.Text='' then
    begin
      nMsg := 'ҵ�����%sû�ж�Ӧ�Ĳɹ�����,�޷��쿨';
      nMsg := Format(nMsg, [nID]);
      Exit;
    end;

    nCount := nListA.Count;
    if nCount <> 1 then
    begin
      nMsg := 'ҵ�����%sƥ�䵽%d���ɹ�����,�޷��쿨';
      nMsg := Format(nMsg, [nID, nCount]);
      Exit;
    end;

    nListB.Text := DecodeBase64(nListA.Strings[0]);
    //***********************
    gPurOrderItems[FIdx].FOrder_id := nListB.Values['PK'];
    gPurOrderItems[FIdx].FZhiKaNo  := nListB.Values['ZhiKa'];
    gPurOrderItems[FIdx].FProvID   := nListB.Values['ProvID'];
    gPurOrderItems[FIdx].FProvName := nListB.Values['ProvName'];

    gPurOrderItems[FIdx].FgoodsID  := nListB.Values['StockNo'];
    gPurOrderItems[FIdx].FGoodsname:= nListB.Values['StockName'];
    gPurOrderItems[FIdx].FMaxMum   := nListB.Values['Maxnumber'];

    gPurOrderItems[FIdx].FData := nListB.Values['ZKDate'];
    gPurOrderItems[FIdx].FTrackNo := nTruck;
    gPurOrderItems[FIdx].FArea    := nListB.Values['SaleArea'];
    gPurOrderItems[FIdx].FCanSave := True;

    DoSaveWork(FTTCEK720ID,FIdx);
  finally
    nListA.Free;
    nListB.Free;
  end;
  Result := True;
end;

procedure TFrame1.InitTimerTimer(Sender: TObject);
begin
  InitTimer.Tag := InitTimer.Tag - 1;
  if MemoLog.Lines.Count > 100 then
    MemoLog.Lines.Clear;
  MemoLog.Lines.Add(FKeyBoardTunnel.FID + '�쿨����ʱ:'+ IntToStr(InitTimer.Tag));
  WriteLog(FKeyBoardTunnel.FID + '�쿨����ʱ:'+ IntToStr(InitTimer.Tag));

  if gPurOrderItems[FIdx].FMsg <> '' then
  begin
    if FSaveMsg <> gPurOrderItems[FIdx].FMsg then
    begin
      FSaveMsg := gPurOrderItems[FIdx].FMsg;
      InitTimer.Enabled := False;
      LEDDisplay(FKeyBoardTunnel.FID, gPurOrderItems[FIdx].FMsg);
      InitTimer.Enabled := True;
    end;
  end;

  if (InitTimer.Tag <= 0) then
  begin
    InitTimer.Enabled := False;
    FSaveMsg := '';
    LEDDisplay(FKeyBoardTunnel.FID, '������쿨����...');//
  end;
  //����
end;

procedure TFrame1.GetTruckTimerTimer(Sender: TObject);
var nStr: string;
begin
  nStr := 'Select top 1 S_Truck From %s Where S_ID=''%s'' order by R_ID desc';
  nStr := Format(nStr, [sTable_SnapTruck, FSnapPost]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount>0 then
    begin
      if Fields[0].AsString <> '' then
      begin
        if Pos('�޳���',Fields[0].AsString) <= 0 then
        begin
          nStr:= Copy(Fields[0].AsString,3,Length(Fields[0].AsString) - 2);
          if Length(nStr) < 3 then
            Exit;
          FTruck := nStr;
          if FLastTruck <> FTruck then
          begin
            FLastTruck := FTruck;
            LEDDisplay(FKeyBoardTunnel.FID,'','��ǰ���ƺ�:' + FTruck);
          end;
        end;
      end;
    end;
  end;
end;

end.

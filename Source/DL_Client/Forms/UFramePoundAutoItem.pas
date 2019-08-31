{*******************************************************************************
  作者: dmzn@163.com 2014-10-20
  描述: 自动称重通道项
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
    FOrder: string;         //订单号
    FMaxValue: Double;      //最大可用
    FKDValue: Double;       //开单量
  end;

  TOrderItems = array of TOrderItem;
  //订单列表

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
    //称重标识,保存标识
    FPoundTunnel: PPTTunnelItem;
    //磅站通道
    FLastBT,FLastBQ: Int64;
    //上次活动
    FOrderItems: TOrderItems;
    //订单列表
    FBillItems: TLadingBillItems;  
    FUIData,FInnerData: TLadingBillItem;
    //称重数据
    FLastCardDone: Int64;
    FLastCard, FCardTmp, FLastReader: string;
    //上次卡号, 临时卡号, 读卡器编号
    FListA, FListB: TStrings;
    FSampleIndex: Integer;
    FValueSamples: array of Double;
    //数据采样
    FBarrierGate: Boolean;
    //是否采用道闸
    FEmptyPoundInit, FDoneEmptyPoundInit: Int64;
    //空磅计时,过磅保存后空磅
    FEmptyPoundIdleLong, FEmptyPoundIdleShort: Int64;
    //上磅前空磅超时,下磅后空磅超时
    FLogin: Integer;
    //摄像机登陆
    FIsChkPoundStatus : Boolean;
    FOnPound: Boolean;
    //是否为磅上刷卡
    FMaxPoundValue: Double;
    procedure SetUIData(const nReset: Boolean; const nOnlyData: Boolean = False);
    //界面数据
    procedure SetImageStatus(const nImage: TImage; const nOff: Boolean);
    //设置状态
    procedure SetTunnel(const nTunnel: PPTTunnelItem);
    //关联通道
    procedure OnPoundDataEvent(const nValue: Double);
    procedure OnPoundData(const nValue: Double);
    //读取磅重
    procedure LoadBillItems(const nCard: string; nUpdateUI: Boolean = True);
    //读取交货单
    procedure InitSamples;
    procedure AddSample(const nValue: Double);
    function IsValidSamaple: Boolean;
    //处理采样
    function SavePoundSale: Boolean;
    function SavePoundProvide: Boolean;
    function SavePoundDuanDao: Boolean;
    function SavePoundHaulBack: Boolean;
    //保存称重
    procedure WriteLog(nEvent: string);
    //记录日志
    procedure PlayVoice(const nStrtext: string);
    //播放语音
    procedure LEDDisplay(const nStrtext: string);
    //LED显示
    function MakeNewSanBill(nBillValue: Double): Boolean;
    //散装并新单
    function MakeNewSanBillEx(nBillValue: Double): Boolean;
    //散装并新单(不自动并单)
    function MakeNewSanBillAutoHD(nBillValue: Double): Boolean;
    //散装并新单
    function ChkPoundStatus:Boolean;
  public
    { Public declarations }
    class function FrameID: integer; override;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    //子类继承
    property PoundTunnel: PPTTunnelItem read FPoundTunnel write SetTunnel;
    //属性相关
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
  FLogin := -1;
  FOnPound := False;
end;

procedure TfFrameAutoPoundItem.OnDestroyFrame;
begin
  gPoundTunnelManager.ClosePort(FPoundTunnel.FID);
  //关闭表头端口
  FListA.Free;
  FListB.Free;
  {$IFDEF CapturePictureEx}
  FreeCapture(FLogin);
  {$ENDIF}
  inherited;
end;

//Desc: 设置运行状态图标
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
    //清理多余

    Lines.Add(DateTime2Str(Now) + #9 + nEvent);
  finally
    Lines.EndUpdate;
    Perform(EM_SCROLLCARET,0,0);
    Application.ProcessMessages;
  end;
end;

procedure WriteSysLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFrameAutoPoundItem, '自动称重业务', nEvent);
end;

//------------------------------------------------------------------------------
//Desc: 更新运行状态
procedure TfFrameAutoPoundItem.Timer1Timer(Sender: TObject);
begin
  SetImageStatus(ImageBT, GetTickCount - FLastBT > 5 * 1000);
  SetImageStatus(ImageBQ, GetTickCount - FLastBQ > 5 * 1000);
end;

//Desc: 关闭红绿灯
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

//Desc: 设置通道
procedure TfFrameAutoPoundItem.SetTunnel(const nTunnel: PPTTunnelItem);
begin
  FBarrierGate := False;
  FEmptyPoundIdleLong := -1;
  FEmptyPoundIdleShort:= -1;
  FMaxPoundValue := 0;

  FPoundTunnel := nTunnel;
  SetUIData(True);

  {$IFDEF CapturePictureEx}
  if not InitCapture(FPoundTunnel,FLogin) then
    WriteSysLog('通道:'+ FPoundTunnel.FID+'初始化失败,错误码:'+IntToStr(FLogin))
  else
    WriteSysLog('通道:'+ FPoundTunnel.FID+'初始化成功,登陆ID:'+IntToStr(FLogin));
  {$ENDIF}

  if Assigned(FPoundTunnel.FOptions) then
  with FPoundTunnel.FOptions do
  begin
    FBarrierGate := Values['BarrierGate'] = sFlag_Yes;
    FEmptyPoundIdleLong := StrToInt64Def(Values['EmptyIdleLong'], 60);
    FEmptyPoundIdleShort:= StrToInt64Def(Values['EmptyIdleShort'], 5);
    FMaxPoundValue:= StrToInt64Def(Values['MaxPoundValue'], 200);
  end;
end;

//Desc: 重置界面数据
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
    //防止49.71天后，系统更新为0

    if not FIsWeighting then
    begin
      gPoundTunnelManager.ClosePort(FPoundTunnel.FID);
      //关闭表头端口

      Timer_ReadCard.Enabled := True;
      //启动读卡
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
    //已称过重量或销售,禁用临时模式
    RadioCC.Enabled := FID <> '';
    //只有销售有出厂模式

    EditBill.Properties.ReadOnly := (FID = '') and (FTruck <> '');
    EditTruck.Properties.ReadOnly := FTruck <> '';
    EditMID.Properties.ReadOnly := (FID <> '') or (FPoundID <> '');
    EditPID.Properties.ReadOnly := (FID <> '') or (FPoundID <> '');
    //可输入项调整

    EditMemo.Properties.ReadOnly := True;
    EditMValue.Properties.ReadOnly := not FPoundTunnel.FUserInput;
    EditPValue.Properties.ReadOnly := not FPoundTunnel.FUserInput;
    EditJValue.Properties.ReadOnly := True;
    EditZValue.Properties.ReadOnly := True;
    EditWValue.Properties.ReadOnly := True;
    //可输入量调整

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
           nStr := '销售并单'
      else nStr := '销售';
    end else nStr := BusinessToStr(FBillItems[0].FCardUse);

    if FUIData.FNextStatus = sFlag_TruckBFP then
    begin
      RadioCC.Enabled := False;
      EditMemo.Text := nStr + '称皮重';
    end else
    begin
      RadioCC.Enabled := True;
      EditMemo.Text := nStr + '称毛重';
    end;
  end else
  begin
    if RadioLS.Checked then
      EditMemo.Text := '车辆临时称重';
    //xxxxx

    if RadioPD.Checked then
      EditMemo.Text := '车辆配对称重';
    //xxxxx
  end;
end;

//Date: 2014-09-19
//Parm: 磁卡或交货单号
//Desc: 读取nCard对应的交货单
procedure TfFrameAutoPoundItem.LoadBillItems(const nCard: string;
 nUpdateUI: Boolean);
var nStr,nHint,nVoice,nPos: string;
    nIdx,nInt,nLast: Integer;
    nBills: TLadingBillItems;
    nCardUsed: string;
begin
  nStr := Format('读取到卡号[ %s ],开始执行业务.', [nCard]);
  WriteLog(nStr);

  if (not GetLadingBills(nCard, sFlag_TruckBFP, nBills)) or
     (Length(nBills) < 1) then
  begin
    nVoice := '读取磁卡信息失败,请联系管理员';
    PlayVoice(nVoice);
    WriteLog(nVoice);
    SetUIData(True);
    Exit;
  end;

  if IsTruckAutoIn then
  begin
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      if FStatus=sFlag_TruckNone then
      begin
        if SaveLadingBills(sFlag_TruckIn, nBills) then
        begin
          ShowMsg('车辆进厂成功', sHint);
          LoadBillItems(FCardTmp);
          Exit;
        end else
        begin
          ShowMsg('车辆进厂失败', sHint);
        end;
      end;
    end;
  end;

  if (nBills[0].FPoundStation <> '') and
     (nBills[0].FPoundStation <> FPoundTunnel.FID) then
  begin
    nVoice := '%s请到%s过磅';
    nVoice := Format(nVoice, [nBills[0].FTruck, nBills[0].FPoundSName]);
    PlayVoice(nVoice);
    WriteLog(nVoice);
    SetUIData(True);
    Exit;
  end;

  if (nBills[0].FPoundStation = '') and
     (not VerifyStockCanPound(nBills[0].FStockNo, FPoundTunnel.FID, nHint)) then
  begin
    nVoice := '%s请到%s过磅';
    nVoice := Format(nVoice, [nBills[0].FTruck, nHint]);
    PlayVoice(nVoice);
    WriteLog(nVoice);
    SetUIData(True);
    Exit;
  end;

  {$IFDEF RemoteSnap}
  if not VerifySnapTruck(FLastReader, nBills[0], nHint, nPos) then
  begin
    SaveSnapStatus(nBills[0], sFlag_No);
    PlayVoice(nHint);
    RemoteSnapDisPlay(nPos, nHint,sFlag_No);
    WriteSysLog(nHint);
    SetUIData(True);
    Exit;
  end
  else
  begin
    SaveSnapStatus(nBills[0], sFlag_Yes);
    if nHint <> '' then
    begin
      RemoteSnapDisPlay(nPos, nHint,sFlag_Yes);
      WriteSysLog(nHint);
    end;
  end;
  {$ENDIF}

  {$IFDEF InfoConfirm}
  if not InfoConfirmDone(nBills[0].FID, nBills[0].FStockNo) then
  begin
    nVoice := '%s未进行现场刷卡信息确认,无法过磅';
    nVoice := Format(nVoice, [nBills[0].FTruck]);
    PlayVoice(nHint);
    WriteSysLog(nHint);
    SetUIData(True);
    Exit;
  end;
  {$ENDIF}

  nLast := -1;
  if GetTruckLastTime(nBills[0].FTruck, nLast) and (nLast > 0) and
     (nLast < FPoundTunnel.FCardInterval) then
  begin
    nStr := '车辆[ %s ]需等待 %d 秒后才能过磅';
    nStr := Format(nStr, [nBills[0].FTruck, FPoundTunnel.FCardInterval - nLast]);
    WriteLog(nStr);

    nStr := Format('磅站[ %s.%s ]: ',[FPoundTunnel.FID,
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
    //状态校正
    {$IFDEF AllowMultiM}
    if (nCardUsed = sFlag_Sale) and (nBills[nIdx].FType = sFlag_San) then
    begin
      if (FStatus = sFlag_TruckBFM) then
        FNextStatus := sFlag_TruckBFM;
      //允许多次过重
    end;
    {$ENDIF}

    {$IFDEF PrePTruckYs}
    if (nCardUsed = sFlag_ShipPro) and (nBills[nIdx].FPreTruckP) then
    begin
      if (FNextStatus = sFlag_TruckOut) then
      begin
        nStr := '预制皮重车辆[ %s ]请过磅通行';
        nStr := Format(nStr, [nBills[0].FTruck]);
        PlayVoice(nStr);
        WriteSysLog(nStr);
        OpenDoorByReader(FLastReader);
        //打开主道闸
        OpenDoorByReader(FLastReader, sFlag_No);
        SetUIData(True);
        Exit;
      end;
    end;
    {$ENDIF}

    FSelected := (FNextStatus = sFlag_TruckBFP) or
                 (FNextStatus = sFlag_TruckBFM);
    //可称重状态判定

    if FSelected then
    begin
      Inc(nInt);
      Continue;
    end;

    nStr := '※.单号:[ %s ] 状态:[ %-6s -> %-6s ]   ';
    if nIdx < High(nBills) then nStr := nStr + #13#10;

    nStr := Format(nStr, [FID,
            TruckStatusToStr(FStatus), TruckStatusToStr(FNextStatus)]);
    nHint := nHint + nStr;

    nVoice := '车辆 %s 不能过磅,应该去 %s ';
    nVoice := Format(nVoice, [FTruck, TruckStatusToStr(FNextStatus)]);
  end;

  if nInt = 0 then
  begin
    PlayVoice(nVoice);
    //车辆状态异常

    nHint := '该车辆当前不能过磅,详情如下: ' + #13#10#13#10 + nHint;
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
      //该标记有特殊用途
      
      if nInt = 0 then
           FInnerData := nBills[nIdx]
      else FInnerData.FValue := FInnerData.FValue + FValue;
      //累计量

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
  //不更新数据

  FInnerData.FPModel := sFlag_PoundPD;
  FUIData := FInnerData;
  SetUIData(False);

  InitSamples;
  //初始化样本

  if not FPoundTunnel.FUserInput then
  if not gPoundTunnelManager.ActivePort(FPoundTunnel.FID,
         OnPoundDataEvent, True) then
  begin
    nHint := '连接地磅表头失败，请联系管理员检查硬件连接';
    WriteSysLog(nHint);
    PlayVoice(nHint);

    SetUIData(True);
    Exit;
  end;

  Timer_ReadCard.Enabled := False;
  FDoneEmptyPoundInit := 0;
  FIsWeighting := True;
  //停止读卡,开始称重

  if FBarrierGate then
  begin
    nStr := '[n1]%s刷卡成功请上磅,并熄火停车';
    nStr := Format(nStr, [FUIData.FTruck]);
    PlayVoice(nStr);
    //读卡成功，语音提示

    {$IFNDEF DEBUG}
    OpenDoorByReader(FLastReader);
    //打开主道闸
    {$ENDIF}
  end;
  //车辆上磅
end;

//------------------------------------------------------------------------------
//Desc: 由定时读取交货单
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

  //前车未下磅，后车禁止刷卡
  if ImageBT.Tag = cFlag_ON then Exit;

  try
    WriteLog('正在读取磁卡号.');
    nCard := Trim(ReadPoundCard(FLastReader, FPoundTunnel.FID));
    if nCard = '' then Exit;

    if nCard <> FLastCard then
         nDoneTmp := 0
    else nDoneTmp := FLastCardDone;
    //新卡时重置

    WriteSysLog('读取到新卡号:::' + nCard + '=>旧卡号:::' + FLastCard);
    nLast := Trunc((GetTickCount - nDoneTmp) / 1000);
    if (nLast < FPoundTunnel.FCardInterval) And (nDoneTmp <> 0) then
    begin
      nStr := '磁卡[ %s ]需等待 %d 秒后才能过磅';
      nStr := Format(nStr, [nCard, FPoundTunnel.FCardInterval - nLast]);
      WriteLog(nStr);

      nStr := Format('磅站[ %s.%s ]: ',[FPoundTunnel.FID,
              FPoundTunnel.FName]) + nStr;
      WriteSysLog(nStr);

      SetUIData(True);
      Exit;
    end;

    FOnPound := False;
    if Assigned(FPoundTunnel.FOptions) then
    with FPoundTunnel.FOptions do
    begin
      if FLastReader <> '' then
        FOnPound := Values[FLastReader] = sFlag_Yes;
    end;
    //检查该读卡器是磅前读卡器还是磅上读卡器

    if not FOnPound then
    begin
      WriteSysLog('读卡器' + FLastReader + '为磅前读卡器,开始校验地磅重量...');
      if Not ChkPoundStatus then Exit;
      //检查地磅状态 如不为空磅，则喊话 退出称重
    end;

    FCardTmp := nCard;
    EditBill.Text := nCard;
    LoadBillItems(EditBill.Text);
  except
    on E: Exception do
    begin
      nStr := Format('磅站[ %s.%s ]: ',[FPoundTunnel.FID,
              FPoundTunnel.FName]) + E.Message;
      WriteSysLog(nStr);

      SetUIData(True);
      //错误则重置
    end;
  end;
end;

//Date: 2014-12-26
//Parm: 订单列表
//Desc: 将nOrders按可用量从小到大排序
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
  //冒泡排序
end;

//Date: 2014-12-28
//Parm: 需并单量
//Desc: 从当前客户可用订单中开出指定量的新单
function TfFrameAutoPoundItem.MakeNewSanBill(nBillValue: Double): Boolean;
var nStr,nHint,nOrderStr: string;
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
    nStr := '获取订单信息失败,请联系管理员';
    WriteSysLog(nStr);
    PlayVoice(nStr);
    Exit;
  end;

  with FDM.QueryTemp(nStr, True) do
  begin
    if RecordCount < 1 then
    begin
      nStr := StringReplace(FListA.Text, #13#10, ',', [rfReplaceAll]);
      nStr := Format('订单[ %s ]信息已丢失.', [nStr]);
      WriteSysLog(nStr);

      PlayVoice('订单信息已丢失');
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
    nStr := '获取订单剩余量失败,请联系管理员';
    WriteSysLog(nStr);
    PlayVoice(nStr);
    Exit;
  end;  
  //获取已发货量

  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  with FOrderItems[nIdx] do
  begin
    nStr := FListA.Values[FOrder];
    if not IsNumber(nStr, True) then Continue;

    FMaxValue := FMaxValue - Float2Float(StrToFloat(nStr), cPrecision, False);
    //可用量 = 计划量 - 已发量
  end;

  SortOrderByValue(FOrderItems);
  //按可用量由小到大排序

  //----------------------------------------------------------------------------
  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  begin
    if nBillValue <= 0 then Break;
    //已开单完毕

    if FOrderItems[nIdx].FMaxValue<=0 then Continue;
    //NC可用量不能为负

    nDec := FOrderItems[nIdx].FMaxValue;
    if nDec >= nBillValue then
      nDec := nBillValue;
    //订单量够用

    FOrderItems[nIdx].FKDValue := nDec;
    nBillValue := Float2Float(nBillValue - nDec, cPrecision, True);
  end;

  FDM.ADOConn.BeginTrans;
  try
    for nIdx:=Low(FOrderItems) to High(FOrderItems) do
    with FOrderItems[nIdx] do
    begin
      if FKDValue <= 0 then Continue;
      //无开单量

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
    //提货冻结量
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
    //无开单量

    for nInt:=Low(FBillItems) to High(FBillItems) do
    begin
      if FBillItems[nInt].FZhiKa <> FOrder then Continue;
      //xxxxx

      FBillItems[nInt].FValue := FBillItems[nInt].FValue + FKDValue;
      //更新开单量

      FInnerData.FValue := FInnerData.FValue + FKDValue;
      FUIData.FValue := FInnerData.FValue;
    end;
  end;

  if nBillValue <= 0 then
  begin
    Result := True;
    Exit;
  end;
  //已开单完毕

  with FUIData do
  begin
    nHint := '地磅[ %s ]车辆[ %s ]实际装车量超出订单量,详情如下:' + #13#10 +
            '※.提货单号: %s' + #13#10 +
            '※.开单量: %.2f吨' + #13#10 +
            '※.超发量: %.2f吨' + #13#10 +
            '请等待开票室进行补单操作.';
    nHint := Format(nHint, [FPoundTunnel.FName, FTruck, FID, FInnerData.FValue, nBillValue]);

    if not VerifyManualEventRecord(FID + sFlag_ManualC, nHint, sFlag_OK,
      False) then
    begin
      AddManualEventRecord(FID + sFlag_ManualC, FTruck, nHint,
        sFlag_DepBangFang, sFlag_Solution_OK, sFlag_DepDaTing, True);
      WriteSysLog(nHint);

      PlayVoice(nHint);
    end;
  end;
  //----------------------------------------------------------------------------
  nStr := '本次发货量超出[ %.2f ]吨,请选择新的订单.';
  nStr := Format(nStr, [nBillValue]);
  ShowDlg(nStr, sHint);

  while True do
  begin
    nP.FParamA := FBillItems[0].FCusID;
    nP.FParamB := FBillItems[0].FStockNo;
    nP.FParamC := sFlag_Sale;
    nP.FParamE := FBillItems[0].FTruck;
    CreateBaseFormItem(cFI_FormGetOrder, PopedomItem, @nP);

    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
    nStr := nP.FParamB;

    AnalyzeOrderInfo(nStr, nOrder);
    if nOrder.FValue >= nBillValue then Break;

    nStr := '订单可用量不足,详情如下: ' + #13#10#13#10 +
            '※.订单量: %.2f 吨'  + #13#10 +
            '※.待开量: %.2f 吨'  + #13#10 +
            '※.相  差: %.2f 吨'  + #13#10#13#10 +
            '请重新选择订单.';
    nStr := Format(nStr, [nOrder.FValue, nBillValue, nBillValue - nOrder.FValue]);
    ShowDlg(nStr, sHint);
  end;

  nStr := 'Select L_Lading,L_IsVIP,L_Seal,L_StockBrand From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FBillItems[0].FID]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then
    begin
      nStr := '交货单[ %s ]已丢失,请联系管理员.';
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
    //重新载入交货单
  end;

  Result := True;
end;

//Date: 2018-10-22
//Parm: 需并单量
//Desc: 从当前客户可用订单中开出指定量的新单(不自动并单)
function TfFrameAutoPoundItem.MakeNewSanBillEx(nBillValue: Double): Boolean;
var nStr,nHint: string;
    nDec: Double;
    nIdx,nInt: Integer;
    nP: TFormCommandParam;
    nOrder: TOrderItemInfo;
begin
  FListA.Clear;
  Result := False;

  if nBillValue <= 0 then
  begin
    Result := True;
    Exit;
  end;
  //已开单完毕

  with FUIData do
  begin
    nHint := '地磅[ %s ]车辆[ %s ]实际装车量超出订单量,详情如下:' + #13#10 +
            '※.提货单号: %s' + #13#10 +
            '※.开单量: %.2f吨' + #13#10 +
            '※.超发量: %.2f吨' + #13#10 +
            '请等待开票室进行补单操作.';
    nHint := Format(nHint, [FPoundTunnel.FName, FTruck, FID, FInnerData.FValue, nBillValue]);

    if not VerifyManualEventRecord(FID + sFlag_ManualC, nHint, sFlag_OK,
      False) then
    begin
      AddManualEventRecord(FID + sFlag_ManualC, FTruck, nHint,
        sFlag_DepBangFang, sFlag_Solution_OK, sFlag_DepDaTing, True);
      WriteSysLog(nHint);

      PlayVoice(nHint);
    end;
  end;
  //----------------------------------------------------------------------------
  nStr := '本次发货量超出[ %.2f ]吨,请选择新的订单.';
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

    nStr := '订单可用量不足,详情如下: ' + #13#10#13#10 +
            '※.订单量: %.2f 吨'  + #13#10 +
            '※.待开量: %.2f 吨'  + #13#10 +
            '※.相  差: %.2f 吨'  + #13#10#13#10 +
            '请重新选择订单.';
    nStr := Format(nStr, [nOrder.FValue, nBillValue, nBillValue - nOrder.FValue]);
    ShowDlg(nStr, sHint);
  end;

  nStr := 'Select L_Lading,L_IsVIP,L_Seal,L_StockBrand From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FBillItems[0].FID]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then
    begin
      nStr := '交货单[ %s ]已丢失,请联系管理员.';
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
    //重新载入交货单
  end;

  Result := True;
end;

//Desc: 保存销售
function TfFrameAutoPoundItem.SavePoundSale: Boolean;
var nVal,nNet,nValSanMax: Double;
    nStr, nHint, nMemo: string;
begin
  Result := False;
  //init

  {$IFDEF PoundVerfyOrder}
  if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) and
      (FUIData.FYSValid <> sFlag_Yes) then //非空车出厂
  begin
    FListA.Clear;
    FListA.Add(FUIData.FZhiKa);
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
        nStr := Format('订单[ %s ]信息已丢失.', [nStr]);
        WriteSysLog(nStr);

        PlayVoice('销售订单已无效');
        Exit;
      end;
    end;
  end;
  {$ENDIF}

  {$IFNDEF AutoSan}
  if FUIData.FType = sFlag_San then
  begin
    nStr := '散装车辆[%s]不允许在此过磅';
    nStr := Format(nStr, [FBillItems[0].FTruck]);
    PlayVoice(nStr);
    WriteLog(nStr);
    Exit;
  end;
  {$ENDIF}

  with FUIData, gSysParam do
  if (FType = sFlag_San) and (FNextStatus = sFlag_TruckBFP) then
  begin
    nNet := GetTruckEmptyValue(FTruck, FType);
    nVal := FPData.FValue * 1000 - nNet * 1000;

    if (nNet > 0) and
       (((nVal > 0) and (FPoundPZ > 0) and (nVal > FPoundPZ)) or
        ((nVal < 0) and (FPoundPF > 0) and (-nVal > FPoundPF))) then
    begin
      nHint := '车辆[ %s ]实时皮重误差较大,详情如下:' + #13#10 +
              '※.实时皮重: %.2f吨' + #13#10 +
              '※.历史皮重: %.2f吨' + #13#10 +
              '※.误差量: %.2f公斤' + #13#10 +
              '允许过磅,请选是;禁止过磅,请选否;启用回空业务,请选回空.';
      nHint := Format(nHint, [FTruck, FPData.FValue, nNet, nVal]);

      if not VerifyManualEventRecord(FID + sFlag_ManualB, nHint) then
      begin
        nMemo := 'Truck=%s;PStation=%s;Pound_PValue=%.2f;Pound_Card=%s';
        nMemo := Format(nMemo, [FTruck, FPoundTunnel.FID, FPData.FValue, FCard]);
        
        AddManualEventRecord(FID + sFlag_ManualB, FTruck, nHint,
            sFlag_DepBangFang, sFlag_Solution_YNP, sFlag_DepDaTing, True, nMemo);
        WriteSysLog(nHint);

        nHint := '[n1]%s皮重超出预警,请下磅联系开票员处理后再次过磅';
        nHint := Format(nHint, [FTruck]);
        PlayVoice(nHint);
        Exit;
      end;
      //判断皮重是否超差
    end;
  end;

  if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) then
  begin
    if FUIData.FYSValid <> sFlag_Yes then //非空车出厂
    begin
      if FUIData.FPData.FValue > FUIData.FMData.FValue then
      begin
        nStr := '皮重%.2f吨应小于毛重%.2f吨,请联系管理员处理';
        nStr := Format(nStr, [FUIData.FPData.FValue, FUIData.FMData.FValue]);
        WriteSysLog(nStr);
        PlayVoice(nStr);
        Exit;
      end;

      {$IFDEF TruckMValueMaxControl}
      nNet := GetMaxMValue(FUIData.FTruck);

      if (nNet > 0) and (nNet < FUIData.FMData.FValue) then
      with FUIData do
      begin
        nStr := '车辆[ %s ]毛重超出设定毛重限值,详情如下:' + #13#10 +
                '※.物料名称: [ %s ]' + #13#10 +
                '※.车辆毛重: %.2f吨' + #13#10 +
                '※.毛重限值: %.2f吨' + #13#10 +
                '允许过磅,请选是;禁止过磅,请选否.';
        nStr := Format(nStr, [FTruck, FStockName, FMData.FValue, nNet]);

        if not VerifyManualEventRecord(FID + sFlag_ManualB, nStr) then
        begin
          AddManualEventRecord(FID + sFlag_ManualB, FTruck, nStr,
              sFlag_DepBangFang, sFlag_Solution_YN, sFlag_DepDaTing, True);
          WriteSysLog(nStr);

          nStr := '[n1]%s毛重超出设定限值,请下磅联系开票员处理后再次过磅';
          nStr := Format(nStr, [FTruck]);
          PlayVoice(nStr);

          Exit;
        end;
      end;
      {$ENDIF}

      nNet := FUIData.FMData.FValue - FUIData.FPData.FValue;
      //净重
      nVal := nNet * 1000 - FInnerData.FValue * 1000;
      //与开票量误差(公斤)

      with gSysParam,FBillItems[0] do
      begin
        {$IFDEF DaiStepWuCha}
        if FType = sFlag_Dai then
        begin
          GetPoundAutoWuCha(FPoundDaiZ, FPoundDaiF, FInnerData.FValue);
          //计算误差
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
          nHint := '车辆[ %s ]实际装车量误差较大,详情如下:' + #13#10 +
                  '※.开单量: %.2f吨' + #13#10 +
                  '※.装车量: %.2f吨' + #13#10 +
                  '※.误差量: %.2f公斤' + #13#10 +
                  '检测完毕后,请点确认重新过磅.';
          nHint := Format(nHint, [FTruck, FInnerData.FValue, nNet, nVal]);

          if not VerifyManualEventRecord(FID + sFlag_ManualC, nHint, sFlag_Yes,
            False) then
          begin
            AddManualEventRecord(FID + sFlag_ManualC, FTruck, nHint,
              sFlag_DepBangFang, sFlag_Solution_YN, sFlag_DepJianZhuang, True);
            WriteSysLog(nHint);

            {$IFDEF DaiNoWeight}
            nHint := '车辆[n1]%s实际装车量误差较大,请去包装点包';
            nHint := Format(nHint, [FTruck]);
            {$ELSE}
            nHint := '车辆[n1]%s净重[n2]%.2f吨,开票量[n2]%.2f吨,'+
                     '误差量[n2]%.2f公斤,请去包装点包';
            nHint := Format(nHint, [FTruck,nNet,FInnerData.FValue,nVal]);
            {$ENDIF}
            PlayVoice(nHint);
            Exit;
          end;
        end;

        if (FType = sFlag_San) and FloatRelation(nNet, FValue, rtGreater) and
           GetPoundSanWuChaStop(FStockNo) then
        begin
          nStr := '车辆 %s 净重 %.2f 吨超出 %.2f 吨,请去现场卸货';
          nStr := Format(nStr, [FTruck, nNet, nNet - FValue]);
          PlayVoice(nStr);

          WriteSysLog(nStr);
          Exit;
        end;

        if FType = sFlag_San then
        begin
          nValSanMax := GetSanMaxLadeValue;
          if (nValSanMax > 0) and FloatRelation(nNet, nValSanMax, rtGreater) then
          begin
            nStr := '车辆 %s 净重 %.2f 吨超出 %.2f 吨,请去现场卸货';
            nStr := Format(nStr, [FTruck, nNet, nNet - nValSanMax]);
            PlayVoice(nStr);

            nStr := '车辆 %s 净重 %.2f 吨,散装最大提货量设定 %.2f 吨超出 %.2f 吨,请去现场卸货';
            nStr := Format(nStr, [FTruck, nNet, nValSanMax, nNet - nValSanMax]);
            WriteSysLog(nStr);
            Exit;
          end;
        end;

        {$IFNDEF CZNF}
        if (FType = sFlag_San) And (FCardUse = sFlag_Sale) then
        begin
          if nVal > 0 then
          begin
            nStr := '车辆 %s 净重 %.2f 吨超出 %.2f 吨,请联系管理员';
            nStr := Format(nStr, [FTruck, nNet, nNet - FValue]);
            PlayVoice(nStr);

            WriteSysLog(nStr);
            nVal := Float2Float(nNet - FInnerData.FValue, cPrecision, True);
            {$IFDEF SanNoAutoBD}
            if not MakeNewSanBillEx(nVal) then Exit;
            //散装发超时并新单(不自动并单)
            {$ELSE}
              {$IFDEF SanAutoHD}
               if not MakeNewSanBillAutoHD(nVal) then Exit;
                  //散装发超时并新单
              {$ELSE}
              if not MakeNewSanBill(nVal) then Exit;
              //散装发超时并新单
              {$ENDIF}
            {$ENDIF}
          end;
        end;
        {$ENDIF}
      end;
    end
    else
    begin//空车出厂
      nNet := FUIData.FMData.FValue;
      nVal := nNet * 1000 - FUIData.FPData.FValue * 1000;

      if (nNet > 0) and (nVal > 0) and (nVal > gSysParam.FEmpTruckWc) then
      begin
        nStr := '车辆[%s]空车出厂误差较大,请司机联系司磅管理员检查车厢';
        nStr := Format(nStr, [FUIData.FTruck]);
        PlayVoice(nStr);

        nStr := '车辆[%s]空车出厂误差较大,毛重[%.2f],皮重[%.2f]';
        nStr := Format(nStr, [FUIData.FTruck, FUIData.FMData.FValue,
                                              FUIData.FPData.FValue]);
        WriteSysLog(nStr);
        Exit;
      end
      else
      begin
        FUIData.FMData.FValue := FUIData.FPData.FValue;
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
    //标记该项有称重数据
    Result := SaveLadingBills(FNextStatus, FBillItems, FPoundTunnel,FLogin);
    //保存称重
  end;
end;

function TfFrameAutoPoundItem.SavePoundProvide: Boolean;
var nVal, nNet, nPlan: Double;
    nStr,nNextStatus: string;
    nHint, nMemo: string;
begin
  Result := False;
  //init
  nVal := 0;

  {$IFDEF AutoPreTruckP}
  if FUIData.FPreTruckP then
  begin
    with FUIData do
    begin
      //重量小于设定，则重新保存皮重
      if (StrToFloatDef(EditValue.Text,0) < GetPrePValueSet) then
      begin
        SaveTruckPrePValue(FTruck,EditValue.Text);
        SaveTruckPrePicture(FTruck,FPoundTunnel,FLogin);

        Result := True;
        Exit;
      end;
    end;
  end;
  {$ENDIF}

  if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) then
  begin
    nVal := FUIData.FPData.FValue - FUIData.FMData.FValue;
    if nVal > 0 then
      nVal := FUIData.FMData.FValue
    else
      nVal := FUIData.FPData.FValue;
  end;

  with FUIData, gSysParam do
  if nVal > 0 then
  begin
    nNet := GetTruckEmptyValue(FTruck, FType);
    nVal := nVal * 1000 - nNet * 1000;

    if (nNet > 0) and
       (((nVal > 0) and (FPoundPZ > 0) and (nVal > FPoundPZ)) or
        ((nVal < 0) and (FPoundPF > 0) and (-nVal > FPoundPF))) then
    begin
      nHint := '车辆[ %s ]实时皮重误差较大,详情如下:' + #13#10 +
              '※.实时皮重: %.2f吨' + #13#10 +
              '※.历史皮重: %.2f吨' + #13#10 +
              '※.误差量: %.2f公斤' + #13#10 +
              '允许过磅,请选是;禁止过磅,请选否.';
      nHint := Format(nHint, [FTruck, FPData.FValue, nNet, nVal]);

      if not VerifyManualEventRecord(FID + sFlag_ManualB, nHint) then
      begin
        nMemo := 'Truck=%s;PStation=%s;Pound_PValue=%.2f;Pound_Card=%s';
        nMemo := Format(nMemo, [FTruck, FPoundTunnel.FID, FPData.FValue, FCard]);

        AddManualEventRecord(FID + sFlag_ManualB, FTruck, nHint,
            sFlag_DepBangFang, sFlag_Solution_YN, sFlag_DepDaTing, True, nMemo);
        WriteSysLog(nHint);

        nHint := '[n1]%s皮重超出预警,请下磅联系开票员处理后再次过磅';
        nHint := Format(nHint, [FTruck]);
        PlayVoice(nHint);
        Exit;
      end;
      //判断皮重是否超差
    end;
  end;

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
        nStr := Format('订单[ %s ]信息已丢失.', [nStr]);
        WriteSysLog(nStr);

        PlayVoice('采购订单已无效');
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
      nStr := 'NC订单可用量不足，请联系管理员重新办卡';
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
      nStr := '该车辆需要预置皮重，请先联系管理员预置皮重';
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
  //复制用户界面数据

  with FBillItems[0] do
  begin
    FFactory := gSysParam.FFactNum;
    //xxxxx

    if FNextStatus = sFlag_TruckBFP then
         FPData.FStation := FPoundTunnel.FID
    else FMData.FStation := FPoundTunnel.FID;
  end;

  Result := SaveLadingBills(nNextStatus, FBillItems, FPoundTunnel,FLogin);
  //保存称重
end;

//Desc: 短倒业务
function TfFrameAutoPoundItem.SavePoundDuanDao: Boolean;
begin
  SetLength(FBillItems, 1);
  FBillItems[0] := FUIData;
  //复制用户界面数据

  with FBillItems[0] do
  begin
    FFactory := gSysParam.FFactNum;
    //xxxxx

    if FNextStatus = sFlag_TruckBFP then
         FPData.FStation := FPoundTunnel.FID
    else FMData.FStation := FPoundTunnel.FID;
  end;

  Result := SaveLadingBills(FBillItems[0].FNextStatus, FBillItems, FPoundTunnel,FLogin);
  //保存称重
end;

//Desc: 回空业务
function TfFrameAutoPoundItem.SavePoundHaulBack: Boolean;
var nNextStatus, nHint: string;
    nNet, nVal: Double;
begin
  Result := False;
  //init

  with FUIData, gSysParam do
  if (FPData.FValue > 0) and (FMData.FValue > 0) then
  begin
    nNet := GetTruckEmptyValue(FTruck, FType);
    nVal := FPData.FValue * 1000 - nNet * 1000;

    if (nNet > 0) and
       (((nVal > 0) and (FPoundPZ > 0) and (nVal > FPoundPZ)) or
        ((nVal < 0) and (FPoundPF > 0) and (-nVal > FPoundPF))) then
    begin
      nHint := '[n1]%s皮重超出预警%.2f公斤,请下磅卸货后再次过磅';
      nHint := Format(nHint, [FTruck, nVal]);
      WriteSysLog(nHint);
      PlayVoice(nHint);
      Exit;
      //判断皮重是否超差
    end;
  end;

  nNextStatus := FBillItems[0].FNextStatus;
  //保存读卡时下一状态

  SetLength(FBillItems, 1);
  FBillItems[0] := FUIData;
  //复制用户界面数据

  with FBillItems[0] do
  begin
    FFactory := gSysParam.FFactNum;
    //xxxxx
    
    if FNextStatus = sFlag_TruckBFP then
         FPData.FStation := FPoundTunnel.FID
    else FMData.FStation := FPoundTunnel.FID;
  end;

  Result := SaveLadingBills(nNextStatus, FBillItems, FPoundTunnel,FLogin);
  //保存称重
end;


//Desc: 读取表头数据
procedure TfFrameAutoPoundItem.OnPoundDataEvent(const nValue: Double);
begin
  try
    if FIsSaving then Exit;
    //正在保存。。。

    OnPoundData(nValue);
  except
    on E: Exception do
    begin
      WriteSysLog(Format('磅站[ %s.%s ]: %s', [FPoundTunnel.FID,
                                               FPoundTunnel.FName, E.Message]));
      SetUIData(True);
    end;
  end;
end;

//Desc: 处理表头数据
procedure TfFrameAutoPoundItem.OnPoundData(const nValue: Double);
var nRet: Boolean;
    nStr: string;
    nInt: Int64;
begin
  FLastBT := GetTickCount;
  EditValue.Text := Format('%.2f', [nValue]);

  if not FIsWeighting then Exit;
  //不在称重中

  {$IFNDEF VerfiyAutoWeight}
  if gSysParam.FIsManual then Exit;
  //手动时无效
  {$ENDIF}

  if (nValue < 0.04) or
    FloatRelation(nValue, FPoundTunnel.FPort.FMinValue, rtLE, 1000) then //空磅
  begin
    if FEmptyPoundInit = 0 then
      FEmptyPoundInit := GetTickCount;
    nInt := GetTickCount - FEmptyPoundInit;

    if (nInt > FEmptyPoundIdleLong * 1000) then
    begin
      FIsWeighting :=False;
      Timer_SaveFail.Enabled := True;

      WriteSysLog('刷卡后司机无响应,退出称重.');
      Exit;
    end;
    //上磅时间,延迟重置

    if (nInt > FEmptyPoundIdleShort * 1000) and   //保证空磅
       (FDoneEmptyPoundInit>0) and (GetTickCount-FDoneEmptyPoundInit>nInt) then
    begin
      FIsWeighting :=False;
      Timer_SaveFail.Enabled := True;

      WriteSysLog('司机已下磅,退出称重.');
      Exit;
    end;
    //上次保存成功后,空磅超时,认为车辆下磅

    Exit;
  end else
  begin
    FEmptyPoundInit := 0;
    if FDoneEmptyPoundInit > 0 then
      FDoneEmptyPoundInit := GetTickCount;
    //车辆称重完毕后，未下磅
  end;

  AddSample(nValue);
  if not IsValidSamaple then Exit;
  //样本验证不通过

  if Length(FBillItems) <= 0 then Exit;
  //退出称重

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
        //切换为称皮重
      end else
      begin
        FUIData.FPData := FInnerData.FPData;
        FUIData.FMData := FInnerData.FMData;

        FUIData.FMData.FValue := nValue;
        FUIData.FNextStatus := sFlag_TruckBFM;
        //切换为称毛重
      end;
    end else FUIData.FPData.FValue := nValue;
  end;
  SetUIData(False);
  //更新显示信息

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
    nStr := '车辆未停到位,请移动车辆.';
    PlayVoice(nStr);
    WriteSysLog(nStr);
    InitSamples;
    //LEDDisplay(nStr);
    Exit;
  end;

  if (FMaxPoundValue > 0) and (nValue > FMaxPoundValue) then
  begin
    nRet := False;
    nStr := GetTruckNO(FUIData.FTruck) + '重量  ' + GetValue(nValue);
    LEDDisplay(nStr);
    nStr := '车辆%s毛重%.2f吨超出地磅最大设定%.2f吨,禁止过磅,请联系管理员处理';
    nStr := Format(nStr, [FUIData.FTruck, nValue, FPoundTunnel.FPort.FMaxValue]);
    WriteSysLog(nStr);
    PlayVoice(nStr);
  end
  else
  begin
    FIsSaving := True;
    if FUIData.FCardUse = sFlag_Sale then      nRet := SavePoundSale
    else if FUIData.FCardUse = sFlag_SaleNew then nRet := SavePoundSale
    else if FUIData.FCardUse = sFlag_DuanDao then nRet := SavePoundDuanDao
    else if FUIData.FCardUse = sFlag_Haulback then nRet:= SavePoundHaulBack
    else if FUIData.FCardUse = sFlag_Provide then nRet := SavePoundProvide
    else if FUIData.FCardUse = sFlag_ShipPro then nRet := SavePoundProvide
    else if FUIData.FCardUse = sFlag_ShipTmp then nRet := SavePoundProvide
    else nRet := False;
  end;
  
  if nRet then
  begin
    nStr := GetTruckNO(FUIData.FTruck) + '重量  ' + GetValue(nValue);
    {$IFDEF HSNF}
    nStr := GetTruckNO(FUIData.FTruck) + ',请下磅';
    {$ENDIF}
    {$IFDEF DaiNoWeight}
    if (FUIData.FType = sFlag_Dai) and (FUIData.FCardUse = sFlag_Sale) then
    begin
      if FUIData.FMData.FValue <= 0 then
        nStr := GetTruckNO(FUIData.FTruck) + ',皮重称重完毕'
      else
        nStr := GetTruckNO(FUIData.FTruck) + ',毛重称重完毕';
    end;

    if FUIData.FPreTruckP then
    begin
      if (FUIData.FMData.FValue > 0) and (FUIData.FPData.FValue > 0) then
      begin
        nStr := Copy(FUIData.FTruck,1,8) + Copy(FUIData.FOrigin,1,4) +
              '净重: ' + GetValue(Abs(FUIData.FMData.FValue-FUIData.FPData.FValue));
      end;
    end;
    {$ENDIF}
    LEDDisplay(nStr);
    
    TimerDelay.Enabled := True;
  end else Timer_SaveFail.Enabled := True;

  if FBarrierGate then
  begin
    {$IFDEF ERROPENONEDOOR}
      {$IFDEF CSNF}
      if nRet and (FUIData.FYSValid = sFlag_Yes) then//空车出厂模式且数据保存成功
      begin
        OpenDoorByReader(FLastReader, sFlag_No);
        Exit;
      end;
      if not nRet then
      begin
        OpenDoorByReader(FLastReader, sFlag_Yes);
        Exit;
      end;
      {$ELSE}
      if not nRet then
      begin
        OpenDoorByReader(FLastReader, sFlag_Yes);
        Exit;
      end;
      {$ENDIF}
      if FUIData.FOneDoor = sFlag_Yes then
           OpenDoorByReader(FLastReader, sFlag_Yes)
      else OpenDoorByReader(FLastReader, sFlag_No);
    {$ELSE}
    if FUIData.FOneDoor = sFlag_Yes then
         OpenDoorByReader(FLastReader, sFlag_Yes)
    else OpenDoorByReader(FLastReader, sFlag_No);
    {$ENDIF}
  end;
  //打开副道闸
end;

procedure TfFrameAutoPoundItem.TimerDelayTimer(Sender: TObject);
begin
  try
    TimerDelay.Enabled := False;
    FLastCardDone := GetTickCount;
    FDoneEmptyPoundInit := GetTickCount;
    WriteLog(Format('对车辆[ %s ]称重完毕.', [FUIData.FTruck]));

    PlayVoice(#9 + FUIData.FTruck);
    //播放语音

    FLastCard := FCardTmp;
    Timer2.Enabled := True;

    if not FBarrierGate then
      FIsWeighting := False;
    //磅上无道闸时，即时过磅完毕

    {$IFDEF MITTruckProber}
    TunnelOC(FPoundTunnel.FID, True);
    {$ELSE}
    gProberManager.TunnelOC(FPoundTunnel.FID, True);
    {$ENDIF} //开红绿灯
    SetUIData(True);
  except
    on E: Exception do
    begin
      WriteSysLog(Format('磅站[ %s.%s ]: %s', [FPoundTunnel.FID,
                                               FPoundTunnel.FName, E.Message]));
      //loged
    end;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 初始化样本
procedure TfFrameAutoPoundItem.InitSamples;
var nIdx: Integer;
begin
  SetLength(FValueSamples, FPoundTunnel.FSampleNum);
  FSampleIndex := Low(FValueSamples);

  for nIdx:=High(FValueSamples) downto FSampleIndex do
    FValueSamples[nIdx] := 0;
  //xxxxx
end;

//Desc: 添加采样
procedure TfFrameAutoPoundItem.AddSample(const nValue: Double);
begin
  FValueSamples[FSampleIndex] := nValue;
  Inc(FSampleIndex);

  if FSampleIndex >= FPoundTunnel.FSampleNum then
    FSampleIndex := Low(FValueSamples);
  //循环索引
end;

//Desc: 验证采样是否稳定
function TfFrameAutoPoundItem.IsValidSamaple: Boolean;
var nIdx: Integer;
    nVal: Integer;
begin
  Result := False;

  for nIdx:=FPoundTunnel.FSampleNum-1 downto 1 do
  begin
    if FValueSamples[nIdx] < FPoundTunnel.FPort.FMinValue then Exit;
    //样本不完整

    nVal := Trunc(FValueSamples[nIdx] * 1000 - FValueSamples[nIdx-1] * 1000);
    if Abs(nVal) >= FPoundTunnel.FSampleFloat then Exit;
    //浮动值过大
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
      WriteSysLog(Format('磅站[ %s.%s ]: %s', [FPoundTunnel.FID,
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

function TfFrameAutoPoundItem.ChkPoundStatus:Boolean;
var nIdx:Integer;
    nHint : string;
begin
  Result:= True;
  try
    FIsChkPoundStatus:= True;
    if not FPoundTunnel.FUserInput then
    if not gPoundTunnelManager.ActivePort(FPoundTunnel.FID,
           OnPoundDataEvent, True) then
    begin
      nHint := '检查地磅：连接地磅表头失败，请联系管理员检查硬件连接';
      WriteSysLog(nHint);
      PlayVoice(nHint);
    end;

    for nIdx:= 0 to 5 do
    begin
      Sleep(500);  Application.ProcessMessages;
      if StrToFloatDef(Trim(EditValue.Text), -1) > FPoundTunnel.FPort.FMinValue then
      begin
        Result:= False;
        nHint := '检查地磅：地磅称重重量 %s ,不能进行称重作业';
        nhint := Format(nHint, [EditValue.Text]);
        WriteSysLog(nHint);

        PlayVoice('不能进行称重作业,相关车辆或人员请下榜');
        Break;
      end;
    end;
  finally
    FIsChkPoundStatus:= False;
    SetUIData(True);
  end;
end;

//Date: 2019-06-04
//Parm: 需并单量
//Desc: 从当前客户可用订单中开出指定量的新单
function TfFrameAutoPoundItem.MakeNewSanBillAutoHD(nBillValue: Double): Boolean;
var nStr,nHint,nOrderStr: string;
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
    nStr := '获取订单信息失败,请联系管理员';
    WriteSysLog(nStr);
    PlayVoice(nStr);
    Exit;
  end;

  with FDM.QueryTemp(nStr, True) do
  begin
    if RecordCount < 1 then
    begin
      nStr := StringReplace(FListA.Text, #13#10, ',', [rfReplaceAll]);
      nStr := Format('订单[ %s ]信息已丢失.', [nStr]);
      WriteSysLog(nStr);

      PlayVoice('订单信息已丢失');
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
    nStr := '获取订单剩余量失败,请联系管理员';
    WriteSysLog(nStr);
    PlayVoice(nStr);
    Exit;
  end;  
  //获取已发货量

  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  with FOrderItems[nIdx] do
  begin
    nStr := FListA.Values[FOrder];
    if not IsNumber(nStr, True) then Continue;

    FMaxValue := FMaxValue - Float2Float(StrToFloat(nStr), cPrecision, False);
    //可用量 = 计划量 - 已发量
  end;

  SortOrderByValue(FOrderItems);
  //按可用量由小到大排序

  for nIdx:=Low(FOrderItems) to High(FOrderItems) do//处理大订单模式
  begin
    if nIdx > 0 then
      Continue;

    WriteLog('车辆' + FUIData.FTruck + '实际净重' + FloatToStr(FInnerData.FValue + nBillValue)
             + '已关联订单' + FOrderItems[nIdx].FOrder
             + '当前可用量:' + FloatToStr(FOrderItems[nIdx].FMaxValue));

    if FOrderItems[nIdx].FMaxValue<=0 then Continue;
    //NC可用量不能为负

    if FOrderItems[nIdx].FMaxValue >= (FInnerData.FValue + nBillValue) then
    with FOrderItems[nIdx] do
    begin
      FDM.ADOConn.BeginTrans;
      try
        nStr := 'Update %s Set B_Freeze=B_Freeze+%.2f Where B_ID=''%s''';
        nStr := Format(nStr, [sTable_Order, nBillValue, FOrder]);
        FDM.ExecuteSQL(nStr);

        for nInt:=Low(FBillItems) to High(FBillItems) do
        begin
          if FBillItems[nInt].FZhiKa <> FOrder then Continue;
          //xxxxx

          nStr := 'Update %s Set L_Value=L_Value+%.2f Where L_ID=''%s''';
          nStr := Format(nStr, [sTable_Bill, nBillValue, FBillItems[nInt].FID]);
          FDM.ExecuteSQL(nStr);
        end;

        FDM.ADOConn.CommitTrans;
        //提货冻结量

        Result := True;
        Exit;
      except
        on E: Exception do
        begin
          FDM.ADOConn.RollbackTrans;
          WriteSysLog(E.Message);
          Exit;
        end;
      end;
    end;
  end;

  //----------------------------------------------------------------------------
  nDec := 0;
  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  begin
    WriteLog('车辆' + FUIData.FTruck + '实际净重' + FloatToStr(FInnerData.FValue + nBillValue)
             + '已关联订单' + FOrderItems[nIdx].FOrder
             + '当前可用量:' + FloatToStr(FOrderItems[nIdx].FMaxValue));

    if FOrderItems[nIdx].FMaxValue<=0 then Continue;
    //NC可用量不能为负

    nDec := nDec + FOrderItems[nIdx].FMaxValue;
  end;

  WriteLog('车辆' + FUIData.FTruck + '实际净重' + FloatToStr(FInnerData.FValue + nBillValue)
             + '当前可用订单总量:' + FloatToStr(nDec));

  if nDec >= (FInnerData.FValue + nBillValue) then
  begin
    Result := True;
    Exit;
  end;
  //已开单完毕

  if AutoGetSanHDOrder(FUIData.FCusID, FUIData.FStockNo, FUIData.FTruck,
                       nBillValue, nOrderStr) then
  begin
    FListB.Clear;
    FListB.Text := nOrderStr;

    nStr := 'Select L_Lading,L_IsVIP,L_Seal,L_StockBrand From %s Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, FBillItems[0].FID]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
      begin
        nStr := '交货单[ %s ]已丢失,请联系管理员.';
        nStr := Format(nStr, [FBillItems[0].FID]);

        ShowDlg(nStr, sHint);
        Exit;
      end;

      with FListA do
      begin
        Clear;
        Values['Orders'] := EncodeBase64(FListB.Values['Orders']);
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

      with FUIData do
      begin
        nHint := '地磅[ %s ]车辆[ %s ]自动合单成功,详情如下:' + #13#10 +
                '※.提货单号: %s' + #13#10 +
                '※.开单量: %.2f吨' + #13#10 +
                '※.超发量: %.2f吨' + #13#10 +
                '※.合单订单号: %s' + #13#10 +
                '※.合单提货单号: %s' + #13#10 +
                '请知悉.';
        nHint := Format(nHint, [FPoundTunnel.FName, FTruck, FID, FInnerData.FValue, nBillValue,
                                FListB.Values['Orders'], nStr]);

        if not VerifyManualEventRecord(FID + sFlag_ManualC, nHint, sFlag_OK,
          False) then
        begin
          AddManualEventRecord(FID + sFlag_ManualC, FTruck, nHint,
            sFlag_DepBangFang, sFlag_Solution_OK, sFlag_DepDaTing, True);
          WriteSysLog(nHint);

          nHint := '车辆' + FTruck + '自动合单完成';
          PlayVoice(nHint);
        end;
      end;
      Result := True;
      LoadBillItems(FCardTmp, False);
      //重新载入交货单
    end;
  end
  else
  begin
    with FUIData do
    begin
      nHint := '地磅[ %s ]车辆[ %s ]自动合单失败,详情如下:' + #13#10 +
              '※.提货单号: %s' + #13#10 +
              '※.开单量: %.2f吨' + #13#10 +
              '※.超发量: %.2f吨' + #13#10 +
              nOrderStr;
      nHint := Format(nHint, [FPoundTunnel.FName, FTruck, FID, FInnerData.FValue, nBillValue]);

      if not VerifyManualEventRecord(FID + sFlag_ManualC, nHint, sFlag_OK,
        False) then
      begin
        AddManualEventRecord(FID + sFlag_ManualC, FTruck, nHint,
          sFlag_DepBangFang, sFlag_Solution_OK, sFlag_DepDaTing, True);
        WriteSysLog(nHint);

        nHint := '车辆' + FTruck + '自动合单失败,请联系管理员';
        PlayVoice(nHint);
      end;
    end;
  end;
end;

end.

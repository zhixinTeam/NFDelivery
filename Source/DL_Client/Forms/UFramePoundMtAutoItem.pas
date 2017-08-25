{*******************************************************************************
  作者: juner11212436@163.com 2017-08-17
  描述: 码头抓斗秤通道项
*******************************************************************************}
unit UFramePoundMtAutoItem;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UMgrPoundTunnels, UBusinessConst, UFrameBase, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, StdCtrls,
  UTransEdit, ExtCtrls, cxRadioGroup, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxLabel, ULEDFont, Menus;

type

  TfFrameAutoPoundMtItem = class(TBaseFrame)
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
    Timer1: TTimer;
    EditBill: TcxComboBox;
    cxLabel1: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    Timer_ReadCard: TTimer;
    MemoLog: TZnTransMemo;
    ckCloseAll: TCheckBox;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    procedure Timer1Timer(Sender: TObject);
    procedure Timer_ReadCardTimer(Sender: TObject);
    procedure ckCloseAllClick(Sender: TObject);
    procedure EditBillKeyPress(Sender: TObject; var Key: Char);
    procedure N1Click(Sender: TObject);
  private
    { Private declarations }
    FIsWeighting, FIsSaving: Boolean;
    //称重标识,保存标识
    FPoundTunnel: PPTTunnelItem;
    //磅站通道
    FLastBT,FLastBQ: Int64;
    //上次活动
    FValueLast: Double;
    //上次称重数据
    FNum: Integer;
    //已累计记录数
    FRecId : string;
    //每条船流水号
    FBillItems: TLadingBillItems;
    FLastCardDone: Int64;
    FLastCard: string;
    //上次卡号, 临时卡号, 读卡器编号
    procedure SetUIData(const nReset: Boolean);
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
    function SaveGrabData(nValue: Double): Boolean;
    procedure WriteLog(nEvent: string);
    //记录日志
    procedure ResetGrab;
    //恢复读卡
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

class function TfFrameAutoPoundMtItem.FrameID: integer;
begin
  Result := 0;
end;

procedure TfFrameAutoPoundMtItem.OnCreateFrame;
begin
  inherited;
  GroupBox1.Caption := '单位:Kg';
  FPoundTunnel := nil;
  FIsWeighting := False;
  FValueLast := 0;
  FNum := 0;
  FLastCardDone   := GetTickCount;
end;

procedure TfFrameAutoPoundMtItem.OnDestroyFrame;
begin
  gPoundTunnelManager.ClosePort(FPoundTunnel.FID);
  //关闭表头端口
  inherited;
end;

//Desc: 设置运行状态图标
procedure TfFrameAutoPoundMtItem.SetImageStatus(const nImage: TImage;
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

procedure TfFrameAutoPoundMtItem.WriteLog(nEvent: string);
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
  gSysLoger.AddLog(TfFrameAutoPoundMtItem, '抓斗秤称重业务', nEvent);
end;

//------------------------------------------------------------------------------
//Desc: 更新运行状态
procedure TfFrameAutoPoundMtItem.Timer1Timer(Sender: TObject);
begin
  SetImageStatus(ImageBT, GetTickCount - FLastBT > 5 * 1000);
  SetImageStatus(ImageBQ, GetTickCount - FLastBQ > 5 * 1000);
end;

//Desc: 设置通道
procedure TfFrameAutoPoundMtItem.SetTunnel(const nTunnel: PPTTunnelItem);
begin

  FPoundTunnel := nTunnel;
  EditValue.Text := '0.00';
end;

//Desc: 重置界面数据
procedure TfFrameAutoPoundMtItem.SetUIData(const nReset: Boolean);
begin
  if nReset then
  begin
    EditValue.Text := '0.00';
    EditBill.Properties.Items.Clear;

    FIsSaving    := False;
    if FLastCardDone = 0 then
      FLastCardDone   := GetTickCount;
    //防止49.71天后，系统更新为0
    EditBill.Text := '';
    EditTruck.Text := '';
    EditMID.Text := '';
    EditPID.Text := '';
    EditBill.Properties.ReadOnly := False;
    EditTruck.Properties.ReadOnly := False;
    EditMID.Properties.ReadOnly := False;
    EditPID.Properties.ReadOnly := False;
    ResetGrab;
    Exit;
  end;
  with FBillItems[0] do
  begin
    EditTruck.Text := FTruck;
    EditMID.Text := FStockName;
    EditPID.Text := FCusName;

    EditBill.Properties.ReadOnly := (FID = '') and (FTruck <> '');
    EditTruck.Properties.ReadOnly := FTruck <> '';
    EditMID.Properties.ReadOnly := (FID <> '') or (FPoundID <> '');
    EditPID.Properties.ReadOnly := (FID <> '') or (FPoundID <> '');
    //可输入项调整
  end;
end;

//Date: 2014-09-19
//Parm: 磁卡或交货单号
//Desc: 读取nCard对应的交货单
procedure TfFrameAutoPoundMtItem.LoadBillItems(const nCard: string;
 nUpdateUI: Boolean);
var nStr,nHint,nVoice: string;
begin
  nStr := Format('读取到卡号[ %s ],开始执行业务.', [nCard]);
  WriteLog(nStr);

  if (not GetLadingBills(nCard, sTable_CardProvide, FBillItems)) or 
     (Length(FBillItems) < 1) then
  begin
    nVoice := '读取磁卡信息失败,请联系管理员';
    WriteLog(nVoice);
    SetUIData(True);
    Exit;
  end;
  SetUIData(False);//界面载入
  if not FPoundTunnel.FUserInput then
  if not gPoundTunnelManager.ActivePort(FPoundTunnel.FID,
         OnPoundDataEvent, True) then
  begin
    nHint := '连接抓斗秤表头失败，请联系管理员检查硬件连接';
    WriteSysLog(nHint);

    SetUIData(True);
    Exit;
  end;

  Timer_ReadCard.Enabled := False;
  FIsWeighting := True;
  //停止读卡,开始称重
end;

//------------------------------------------------------------------------------
//Desc: 由定时读取交货单
procedure TfFrameAutoPoundMtItem.Timer_ReadCardTimer(Sender: TObject);
var nStr,nCard: string;
begin
  Timer_ReadCard.Tag := Timer_ReadCard.Tag + 1;
  if Timer_ReadCard.Tag < 5 then Exit;

  Timer_ReadCard.Tag := 0;
  if FIsWeighting then Exit;

  try
    WriteLog('正在读取磁卡号.');
    nStr := 'Select P_Card, P_Ls From %s Where P_Tunnel=''%s''';
    nStr := Format(nStr, [sTable_CardGrab, FPoundTunnel.FID]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
      begin
        Exit;
      end;
      nCard := FieldByName('P_Card').AsString;
      FRecId := FieldByName('P_Ls').AsString;
    end;
    if nCard = '' then Exit;
    nStr := 'Select Num , TotalWeight From %s Where Num = (Select  Max(Num)' +
            ' From %s Where Card=''%s'' And Rec_Id=''%s'')';
    nStr := Format(nStr, [sTable_Grab,sTable_Grab, nCard, FRecId]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount >= 1 then
      begin
        FNum := FieldByName('Num').AsInteger;
        FValueLast := FieldByName('TotalWeight').AsFloat;
      end;
    end;
    //查找累计记录数和累计重量，用于窗体关闭再打开
    WriteSysLog('读取到新卡号:::' + nCard + '=>旧卡号:::' + FLastCard);

    EditBill.Text := nCard;
    LoadBillItems(EditBill.Text);
  except
    on E: Exception do
    begin
      nStr := Format('抓斗秤[ %s.%s ]: ',[FPoundTunnel.FID,
              FPoundTunnel.FName]) + E.Message;
      WriteSysLog(nStr);

      SetUIData(True);
      //错误则重置
    end;
  end;
end;

//Desc:存储一次抓斗秤重量
function TfFrameAutoPoundMtItem.SaveGrabData(nValue: Double): Boolean;
var nStr: string;
begin
  Result := False;
  FDM.ADOConn.BeginTrans;
  try
    nStr := 'Insert Into $PB(Rec_Id,Card,Truck,CusName,StockName,Num,EachWeight,TotalWeight,WeightTime) ' +
            'Values(''$R'',''$C'',''$T'',''$U'',''$S'',$N,$E,''$A'',$W)';
    nStr := MacroValue(nStr, [MI('$PB', sTable_Grab),MI('$R', FRecId), MI('$C', EditBill.Text), MI('$T', EditTruck.Text),
                              MI('$U', EditPID.Text), MI('$S', EditMID.Text),
                              MI('$N', Format('%d',[FNum])), MI('$E', Format('%.2f',[nValue-FValueLast])),
                              MI('$A', Format('%.2f',[nValue])), MI('$W', FDM.SQLServerNow)]);
    FDM.ExecuteSQL(nStr);
    FDM.ADOConn.CommitTrans;
    FIsSaving := False;
    Result := True;
  except
    on E: Exception do
    begin
      FDM.ADOConn.RollbackTrans;
      WriteSysLog(E.Message);
      Exit;
    end;
  end;
end;

//Desc: 读取表头数据
procedure TfFrameAutoPoundMtItem.OnPoundDataEvent(const nValue: Double);
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
procedure TfFrameAutoPoundMtItem.OnPoundData(const nValue: Double);
var nRet: Boolean;
    nStr: string;
    EachValue: string;
begin
  FLastBT := GetTickCount;
  EditValue.Text := Format('%.2f', [nValue]);

  if not FIsWeighting then Exit;
  //不在称重中
  if Length(FBillItems) <= 0 then Exit;
  //退出称重
  if nValue = FValueLast then Exit;
  //重复数据
  if nValue < FValueLast then
  begin
    SetUIData(True);
    Exit;
  end;
  //仪表清除累计
  FIsSaving := True;
  Inc(FNum);
  nRet := SaveGrabData(nValue);
  EachValue := Format('%.2f',[nValue - FValueLast]);
  FValueLast := nValue;
  if nRet then
  begin
    nStr := EditTruck.Text + '第' + IntToStr(FNum) + '次重量  ' + EachValue + 'Kg';
    WriteLog(nStr);
  end;
end;

procedure TfFrameAutoPoundMtItem.ckCloseAllClick(Sender: TObject);
var nP: TWinControl;
begin
  nP := Parent;

  if ckCloseAll.Checked then
  while Assigned(nP) do
  begin
    if (nP is TBaseFrame) and
       (TBaseFrame(nP).FrameID = cFI_FramePoundMtAuto) then
    begin
      TBaseFrame(nP).Close();
      Exit;
    end;

    nP := nP.Parent;
  end;
end;

procedure TfFrameAutoPoundMtItem.EditBillKeyPress(Sender: TObject;
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

procedure TfFrameAutoPoundMtItem.ResetGrab;
var nStr: string;
begin
  gPoundTunnelManager.ClosePort(FPoundTunnel.FID);
  //关闭表头端口
  nStr := 'Delete From %s Where P_Tunnel=''%s''';
  nStr := Format(nStr, [sTable_CardGrab, FPoundTunnel.FID]);

  FDM.ExecuteSQL(nStr);
  //删除工作卡
  FIsWeighting := False;
  FValueLast := 0;
  FNum := 0;
  EditValue.Text := '0.00';
  Timer_ReadCard.Enabled := True;
  //启动读卡
end;

procedure TfFrameAutoPoundMtItem.N1Click(Sender: TObject);
begin
  inherited;
  SetUIData(True);
end;

end.

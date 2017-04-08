{*******************************************************************************
  ����: fendou116688@163.com 2017/2/17
  ����: �𳵺����ͨ����
*******************************************************************************}
unit UFramePoundStationItem;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UMgrPoundTunnels, UBusinessConst, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, Menus, ExtCtrls, cxCheckBox,
  StdCtrls, cxButtons, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxLabel,
  ULEDFont, cxRadioGroup, UFrameBase;

type
  TfFramePoundStationItem = class(TBaseFrame)
    GroupBox1: TGroupBox;
    EditValue: TLEDFontNum;
    GroupBox3: TGroupBox;
    Label17: TLabel;
    ImageBT: TImage;
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
    BtnSave: TcxButton;
    BtnNext: TcxButton;
    Timer1: TTimer;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    EditKID: TcxComboBox;
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
    CheckZD: TcxCheckBox;
    CheckSound: TcxCheckBox;
    Timer_Savefail: TTimer;
    EditPrefix: TcxTextEdit;
    procedure Timer1Timer(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure BtnNextClick(Sender: TObject);
    procedure BtnReadNumberClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure RadioPDClick(Sender: TObject);
    procedure EditTruckKeyPress(Sender: TObject; var Key: Char);
    procedure EditMValuePropertiesEditValueChanged(Sender: TObject);
    procedure EditMIDPropertiesChange(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure EditPIDKeyPress(Sender: TObject; var Key: Char);
    procedure HintLabelClick(Sender: TObject);
    procedure CheckZDClick(Sender: TObject);
    procedure Timer_SavefailTimer(Sender: TObject);
  private
    { Private declarations }
    FPoundTunnel: PPTTunnelItem;
    //��վͨ��
    FLastBT: Int64;
    //�ϴλ
    FBillItems: TLadingBillItems;
    FUIData,FInnerData: TLadingBillItem;
    //��������
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
    procedure LoadTruckPoundItem(const nTruck: string);
    //��ȡ��������
    function SavePoundData(var nPoundID: string): Boolean;
    //�������
    procedure PlayVoice(const nStrtext: string);
    //��������
    procedure CollapsePanel(const nCollapse: Boolean; const nAuto: Boolean = True);
    //�۵����
  public
    { Public declarations }
    class function FrameID: integer; override;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    //����̳�
    procedure LoadCollapseConfig(const nCollapse: Boolean);
    //�۵�����
    property CardReader: Integer read FCardReader write FCardReader;
    property PoundTunnel: PPTTunnelItem read FPoundTunnel write SetTunnel;
    //�������
  end;

implementation

{$R *.dfm}

uses
  ULibFun, UAdjustForm, UFormBase, UDataModule,
  UFormWait, USysBusiness, UBase64, USysConst, USysDB, IniFiles;

const
  cFlag_ON    = 10;
  cFlag_OFF   = 20;

class function TfFramePoundStationItem.FrameID: integer;
begin
  Result := 0;
end;

procedure TfFramePoundStationItem.OnCreateFrame;
begin
  inherited;
  FPanelHeight := Height;
  FTitleHeight := HintLabel.Height + 1;

  FListA := TStringList.Create;
  FListB := TStringList.Create;

  FPoundTunnel := nil;
  InitUIData;
end;

procedure TfFramePoundStationItem.OnDestroyFrame;
begin
  gPoundTunnelManager.ClosePort(FPoundTunnel.FID);
  //�رձ�ͷ�˿�

  AdjustStringsItem(EditKID.Properties.Items, True);
  AdjustStringsItem(EditMID.Properties.Items, True);
  AdjustStringsItem(EditPID.Properties.Items, True);
  
  FListA.Free;
  FListB.Free;
  inherited;
end;

//Desc: ��������״̬ͼ��
procedure TfFramePoundStationItem.SetImageStatus(const nImage: TImage;
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
procedure TfFramePoundStationItem.CollapsePanel(const nCollapse,nAuto: Boolean);
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
procedure TfFramePoundStationItem.InitUIData;
var nStr: string;
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
end;

//Desc: ���ý�������
procedure TfFramePoundStationItem.SetUIData(const nReset,nOnlyData: Boolean);
var nVal: Double;
    nTruck: string;
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
    if nOnlyData then Exit;

    SetLength(FBillItems, 0);
    EditValue.Text := '0.00';
    gPoundTunnelManager.ClosePort(FPoundTunnel.FID);
    //�رձ�ͷ�˿�
  end;

  with FUIData do
  begin
    nTruck := FTruck; 
    Delete(nTruck, 1, Length(EditPrefix.Text));
    EditTruck.Text := nTruck;

    EditMID.Text := FStockName;
    EditPID.Text := FCusName;
    if FOrigin <> '' then
      EditKID.Text := FOrigin;

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

    BtnSave.Enabled := FTruck <> '';
    BtnReadNumber.Enabled := FTruck <> '';

    RadioLS.Enabled := FPoundID = '';
    //�ѳƹ�����������,������ʱģʽ
    RadioCC.Enabled := FPoundID <> '';
    //ֻ�ж��ι����г���ģʽ

    EditTruck.Properties.ReadOnly := FTruck <> '';
    EditMID.Properties.ReadOnly := FPoundID <> '';
    EditPID.Properties.ReadOnly := FPoundID <> '';
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


  if RadioLS.Checked then
    EditMemo.Text := '������ʱ����';
  //xxxxx

  if RadioPD.Checked then
    EditMemo.Text := '������Գ���';
  //xxxxx
end;

//Date: 2014-09-25
//Parm: ���ƺ�
//Desc: ��ȡnTruck�ĳ�����Ϣ
procedure TfFramePoundStationItem.LoadTruckPoundItem(const nTruck: string);
var nData: TLadingBillItems;
begin
  if nTruck = '' then
  begin
    EditTruck.SetFocus;
    EditTruck.SelectAll;
    ShowMsg('�����복�ƺ�', sHint); Exit;
  end;

  if not GetStationPoundItem(nTruck, nData) then
  begin
    SetUIData(True);
    Exit;
  end;

  FInnerData := nData[0];
  FUIData := FInnerData;
  SetUIData(False);

  if not FPoundTunnel.FUserInput then
    gPoundTunnelManager.ActivePort(FPoundTunnel.FID, OnPoundData, True);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Desc: ��������״̬
procedure TfFramePoundStationItem.Timer1Timer(Sender: TObject);
begin
  SetImageStatus(ImageBT, GetTickCount - FLastBT > 5 * 1000);
end;

//Desc: �رպ��̵�
procedure TfFramePoundStationItem.Timer2Timer(Sender: TObject);
begin
  Timer2.Tag := Timer2.Tag + 1;
  if Timer2.Tag < 10 then Exit;

  Timer2.Tag := 0;
  Timer2.Enabled := False;
end;

//Desc: �۵����
procedure TfFramePoundStationItem.HintLabelClick(Sender: TObject);
begin
  CollapsePanel(True);
end;

//Desc: ��������
procedure TfFramePoundStationItem.CheckZDClick(Sender: TObject);
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
procedure TfFramePoundStationItem.LoadCollapseConfig(const nCollapse: Boolean);
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
procedure TfFramePoundStationItem.OnPoundData(const nValue: Double);
begin
  FLastBT := GetTickCount;
  EditValue.Text := Format('%.2f', [nValue]);
end;

//Desc: ����ͨ��
procedure TfFramePoundStationItem.SetTunnel(const nTunnel: PPTTunnelItem);
begin
  FPoundTunnel := nTunnel;
  SetUIData(True);
end;

//Desc: ���ƺ��̵�
procedure TfFramePoundStationItem.N1Click(Sender: TObject);
begin
  N1.Checked := not N1.Checked;
  //status change
end;

//Desc: �رճ���ҳ��
procedure TfFramePoundStationItem.N3Click(Sender: TObject);
var nP: TWinControl;
begin
  nP := Parent;
  while Assigned(nP) do
  begin
    if (nP is TBaseFrame) and
       (TBaseFrame(nP).FrameID = cFI_FrameStationPound) then
    begin
      TBaseFrame(nP).Close();
      Exit;
    end;

    nP := nP.Parent;
  end;
end;

//Desc: ������ť
procedure TfFramePoundStationItem.BtnNextClick(Sender: TObject);
begin
  SetUIData(True);
end;

//Desc: ѡ��ͻ�
procedure TfFramePoundStationItem.EditPIDKeyPress(Sender: TObject;
  var Key: Char);
var nStr: string;
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
  end;
end;

procedure TfFramePoundStationItem.EditTruckKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    if EditTruck.Properties.ReadOnly then Exit;
    EditTruck.Text := Trim(EditTruck.Text);
    EditPrefix.Text:= Trim(EditPrefix.Text);

    LoadTruckPoundItem(EditPrefix.Text + EditTruck.Text);
  end;
end;

//Desc: ����
procedure TfFramePoundStationItem.BtnReadNumberClick(Sender: TObject);
var nVal: Double;
begin
  if not IsNumber(EditValue.Text, True) then Exit;
  nVal := StrToFloat(EditValue.Text);
  if FloatRelation(nVal, FPoundTunnel.FPort.FMinValue, rtLE, 1000) then Exit;
  //����С�ڹ������ֵʱ,�˳�

  if FInnerData.FPData.FValue > 0 then
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

  SetUIData(False);
end;

procedure TfFramePoundStationItem.RadioPDClick(Sender: TObject);
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

procedure TfFramePoundStationItem.EditMValuePropertiesEditValueChanged(
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

procedure TfFramePoundStationItem.EditMIDPropertiesChange(Sender: TObject);
begin
  if Sender = EditTruck then
  begin
    if not EditTruck.Focused then Exit;
    //�ǲ�����Ա����
    EditTruck.Text := Trim(EditTruck.Text);
    EditPrefix.Text:= Trim(EditPrefix.Text);

    FUIData.FTruck := EditPrefix.Text + EditTruck.Text;
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
  end else

  if Sender = EditKID then
  begin
    if not EditKID.Focused then Exit;
    //�ǲ�����Ա����
    EditKID.Text := Trim(EditKID.Text);
  end;
end;

//------------------------------------------------------------------------------
//Desc: ԭ���ϻ���ʱ
function TfFramePoundStationItem.SavePoundData(var nPoundID: string): Boolean;
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

  SetLength(FBillItems, 1);
  FBillItems[0] := FUIData;
  //�����û���������

  with FBillItems[0] do
  begin
    FFactory := gSysParam.FFactNum;
    //xxxxx

    if FNextStatus = sFlag_TruckBFM then
         FMData.FStation := FPoundTunnel.FID
    else FPData.FStation := FPoundTunnel.FID;

    if EditKID.ItemIndex < 0 then
    begin
      FZhiKa := '';
      FOrigin := EditKID.Text;
    end else
    begin
      FZhiKa := GetCtrlData(EditKID);
      FOrigin := EditKID.Text;
    end;
  end;

  Result := SaveStationPoundItem(FPoundTunnel, FBillItems, nPoundID);
  //�������
end;

//Desc: �������
procedure TfFramePoundStationItem.BtnSaveClick(Sender: TObject);
var nBool: Boolean;
    nPoundID: string;
begin
  nBool := False;
  try
    BtnSave.Enabled := False;
    ShowWaitForm(ParentForm, '���ڱ������', True);

    nBool := SavePoundData(nPoundID);

    if nBool then
    begin
      PlayVoice(#9 + FUIData.FTruck);
      //��������

      Timer2.Enabled := True;
      gPoundTunnelManager.ClosePort(FPoundTunnel.FID);
      //�رձ�ͷ

      {if (FUIData.FPoundID <> '') or RadioCC.Checked then
        PrintPoundReport(nPoundID, True);
      //ԭ�ϻ����ģʽ        }

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

procedure TfFramePoundStationItem.PlayVoice(const nStrtext: string);
begin
  {if UpperCase(Additional.Values['Voice'])='NET' then
       gNetVoiceHelper.PlayVoice(nStrtext, FPoundTunnel.FID, 'pound')
  else gVoiceHelper.PlayVoice(nStrtext);       }
end;

procedure TfFramePoundStationItem.Timer_SavefailTimer(Sender: TObject);
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

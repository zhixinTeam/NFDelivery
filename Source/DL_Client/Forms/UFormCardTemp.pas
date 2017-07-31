{*******************************************************************************
  作者: fendou116688@163.com 2017/6/2
  描述: 临时业务办卡(复磅模式)
*******************************************************************************}
unit UFormCardTemp;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  CPort, CPortTypes, UFormNormal, UFormBase, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, cxTextEdit,
  dxLayoutControl, StdCtrls, cxGraphics, cxMaskEdit, cxDropDownEdit,
  cxCheckBox;

type
  TfFormCardTemp = class(TfFormNormal)
    EditTruck: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item5: TdxLayoutItem;
    EditCard: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    ComPort1: TComPort;
    EditCusID: TcxComboBox;
    dxLayout1Item3: TdxLayoutItem;
    EditCusName: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditOrgin: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditMID: TcxComboBox;
    dxLayout1Item9: TdxLayoutItem;
    EditMName: TcxTextEdit;
    dxLayout1Item10: TdxLayoutItem;
    EditMemo: TcxTextEdit;
    dxLayout1Item11: TdxLayoutItem;
    EditMuilti: TcxCheckBox;
    dxLayout1Item13: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    EditCardType: TcxCheckBox;
    dxLayout1Item12: TdxLayoutItem;
    EditBack: TcxCheckBox;
    dxLayout1Item14: TdxLayoutItem;
    EditPre: TcxCheckBox;
    dxLayout1Item15: TdxLayoutItem;
    EditPoundStation: TcxComboBox;
    dxLayout1Item16: TdxLayoutItem;
    EditTruckOut: TcxCheckBox;
    dxLayout1Item17: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    procedure BtnOKClick(Sender: TObject);
    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditCardKeyPress(Sender: TObject; var Key: Char);
    procedure EditTruckKeyPress(Sender: TObject; var Key: Char);
    procedure EditMIDPropertiesChange(Sender: TObject);
    procedure EditCusIDPropertiesChange(Sender: TObject);
  private
    { Private declarations }
    FBuffer: string;
    //接收缓冲
    FListA: TStrings;
    //数据传输
    FParam: PFormCommandParam;
    procedure InitFormData;
    procedure ActionComPort(const nStop: Boolean);

    procedure LoadStockItems;
    procedure LoadCustomerItems;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, USysBusiness, USmallFunc, USysConst,
  USysDB, UBusinessPacker, UDataModule, UAdjustForm;

type
  TReaderType = (ptT800, pt8142);
  //表头类型

  TReaderItem = record
    FType: TReaderType;
    FPort: string;
    FBaud: string;
    FDataBit: Integer;
    FStopBit: Integer;
    FCheckMode: Integer;
  end;

  TSelectItem = record
    FID   : string;
    FName : string;
  end;

var
  gReaderItem: TReaderItem;
  //读卡器配置
  gStockItems: array of TSelectItem;
  //品种列表
  gCustomerItems: array of TSelectItem;
  //供应商列表

class function TfFormCardTemp.FormID: integer;
begin
  Result := cFI_FormCardTemp;
end;

class function TfFormCardTemp.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if not Assigned(nParam) then
  begin
    New(nP);
    FillChar(nP^, SizeOf(TFormCommandParam), #0);
  end else
  begin
    nP := nParam;
  end;

  with TfFormCardTemp.Create(Application) do
  try
    FListA := TStringList.Create;
    //init
    
    FParam := nP;
    InitFormData;
    ActionComPort(False);

    FParam.FCommand := cCmd_ModalResult;
    FParam.FParamA := ShowModal;
  finally
    if not Assigned(nParam) then Dispose(nP);
    Free;
  end;
end;

procedure TfFormCardTemp.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ActionComPort(True);
  FListA.Free;
end;

procedure TfFormCardTemp.InitFormData;
begin
  LoadStockItems;
  LoadCustomerItems;
  LoadPoundStation(EditPoundStation.Properties.Items);

  ActiveControl := EditTruck;
end;

//Desc: 串口操作
procedure TfFormCardTemp.ActionComPort(const nStop: Boolean);
var nInt: Integer;
    nIni: TIniFile;
begin
  if nStop then
  begin
    ComPort1.Close;
    Exit;
  end;

  with ComPort1 do
  begin
    with Timeouts do
    begin
      ReadTotalConstant := 100;
      ReadTotalMultiplier := 10;
    end;

    nIni := TIniFile.Create(gPath + 'Reader.Ini');
    with gReaderItem do
    try
      nInt := nIni.ReadInteger('Param', 'Type', 1);
      FType := TReaderType(nInt - 1);

      FPort := nIni.ReadString('Param', 'Port', '');
      FBaud := nIni.ReadString('Param', 'Rate', '4800');
      FDataBit := nIni.ReadInteger('Param', 'DataBit', 8);
      FStopBit := nIni.ReadInteger('Param', 'StopBit', 0);
      FCheckMode := nIni.ReadInteger('Param', 'CheckMode', 0);

      Port := FPort;
      BaudRate := StrToBaudRate(FBaud);

      case FDataBit of
       5: DataBits := dbFive;
       6: DataBits := dbSix;
       7: DataBits :=  dbSeven else DataBits := dbEight;
      end;

      case FStopBit of
       2: StopBits := sbTwoStopBits;
       15: StopBits := sbOne5StopBits
       else StopBits := sbOneStopBit;
      end;
    finally
      nIni.Free;
    end;

    if ComPort1.Port <> '' then
      ComPort1.Open;
    //xxxxx
  end;
end;

procedure TfFormCardTemp.ComPort1RxChar(Sender: TObject; Count: Integer);
var nStr: string;
    nIdx,nLen: Integer;
begin
  ComPort1.ReadStr(nStr, Count);
  FBuffer := FBuffer + nStr;

  nLen := Length(FBuffer);
  if nLen < 7 then Exit;

  for nIdx:=1 to nLen do
  begin
    if (FBuffer[nIdx] <> #$AA) or (nLen - nIdx < 6) then Continue;
    if (FBuffer[nIdx+1] <> #$FF) or (FBuffer[nIdx+2] <> #$00) then Continue;

    nStr := Copy(FBuffer, nIdx+3, 4);
    EditCard.Text := ParseCardNO(nStr, True); 

    FBuffer := '';
    Exit;
  end;
end;

procedure TfFormCardTemp.EditCardKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    BtnOK.Click;
  end else OnCtrlKeyPress(Sender, Key);
end;

function TfFormCardTemp.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
begin
  Result := True;

  if Sender = EditTruck then
  begin
    Result := Length(EditTruck.Text) > 2;
    nHint := '车牌号长度应大于2位';
  end else

  if Sender = EditCard then
  begin
    Result := Length(EditCard.Text) > 0;
    nHint := '请输入有效卡号';
  end;
end;

//Desc: 保存磁卡
procedure TfFormCardTemp.BtnOKClick(Sender: TObject);
var nID, nMID, nCusID: string;
begin
  if not IsDataValid then Exit;

  if EditMID.ItemIndex < 0 then
       nMID := Trim(EditMID.Text)
  else nMID := gStockItems[Integer(EditMID.Properties.Items.Objects[EditMID.ItemIndex])].FID;

  if EditCusID.ItemIndex < 0 then
       nCusID := Trim(EditCusID.Text)
  else nCusID := gCustomerItems[Integer(EditCusID.Properties.Items.Objects[EditCusID.ItemIndex])].FID;

  with FListA do
  begin
    Clear;

    Values['Origin']    := Trim(EditOrgin.Text);
    Values['Truck']     := Trim(EditTruck.Text);

    Values['ProID']     := nCusID;
    Values['ProName']   := Trim(EditCusName.Text);

    Values['StockNO']   := nMID;
    Values['StockName'] := Trim(EditMName.Text);

    Values['Card']      := Trim(EditCard.Text);
    Values['Memo']      := Trim(EditMemo.Text);

    if EditCardType.Checked then
         Values['CardType']:= sFlag_ProvCardG
    else Values['CardType']:= sFlag_ProvCardL;

    if EditMuilti.Checked then
         Values['Muilti']:= sFlag_Yes
    else Values['Muilti']:= sFlag_No;

    if EditBack.Checked then
         Values['TruckBack']:= sFlag_Yes
    else Values['TruckBack']:= sFlag_No;

    if EditPre.Checked then
         Values['TruckPre']:= sFlag_Yes
    else Values['TruckPre']:= sFlag_No;

    if EditTruckOut.Checked then
         Values['TruckOut']:= sFlag_Yes
    else Values['TruckOut']:= sFlag_No;

    Values['PoundStation'] := GetCtrlData(EditPoundStation);
    Values['PoundName']    := EditPoundStation.Text;
  end;

  nID := SaveCardOther(PackerEncodeStr(FListA.Text));
  if nID = '' then Exit;

  ModalResult := mrOk;
  ShowMsg('临时业务办卡成功', sHint);
end;

procedure TfFormCardTemp.EditTruckKeyPress(Sender: TObject; var Key: Char);
var nP: TFormCommandParam;  
begin
  inherited;
  if (Sender = EditTruck) and (Key = Char(VK_SPACE)) then
  begin
    Key := #0;
    nP.FParamA := EditTruck.Text;
    CreateBaseFormItem(cFI_FormGetTruck, '', @nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOk) then Exit;

    EditTruck.Text := nP.FParamB;
    EditTruck.SelectAll;
  end;
end;

procedure TfFormCardTemp.LoadStockItems;
var nStr: string;
    nIdx: Integer;
begin
  nStr := 'Select M_ID,M_Name From ' + sTable_Materails;

  EditMID.Properties.Items.Clear;
  SetLength(gStockItems, 0);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then Exit;
    SetLength(gStockItems, RecordCount);

    nIdx := 0;
    First;

    while not Eof do
    begin
      with gStockItems[nIdx] do
      begin
        FID := Fields[0].AsString;
        FName := Fields[1].AsString;
        EditMID.Properties.Items.AddObject(FID + '.' + FName, Pointer(nIdx));
      end;

      Inc(nIdx);
      Next;
    end;
  end;
end;

procedure TfFormCardTemp.LoadCustomerItems;
var nStr: string;
    nIdx: Integer;
begin
  nStr := 'Select P_ID,P_Name From ' + sTable_Provider;

  EditCusID.Properties.Items.Clear;
  SetLength(gCustomerItems, 0);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then Exit;
    SetLength(gCustomerItems, RecordCount);

    nIdx := 0;
    First;

    while not Eof do
    begin
      with gCustomerItems[nIdx] do
      begin
        FID := Fields[0].AsString;
        FName := Fields[1].AsString;
        EditCusID.Properties.Items.AddObject(FID + '.' + FName, Pointer(nIdx));
      end;

      Inc(nIdx);
      Next;
    end;
  end;
end;  

procedure TfFormCardTemp.EditMIDPropertiesChange(Sender: TObject);
var nIdx: Integer;
begin
  if (not EditMID.Focused) or (EditMID.ItemIndex < 0) then Exit;
  nIdx := Integer(EditMID.Properties.Items.Objects[EditMID.ItemIndex]);

  if nIdx < 0 then Exit;
  EditMName.Text := gStockItems[nIdx].FName;
end;

procedure TfFormCardTemp.EditCusIDPropertiesChange(Sender: TObject);
var nIdx: Integer;
begin
  if (not EditCusID.Focused) or (EditCusID.ItemIndex < 0) then Exit;
  nIdx := Integer(EditCusID.Properties.Items.Objects[EditCusID.ItemIndex]);

  if nIdx < 0 then Exit;
  EditCusName.Text := gCustomerItems[nIdx].FName;
end;

initialization
  gControlManager.RegCtrl(TfFormCardTemp, TfFormCardTemp.FormID);
end.

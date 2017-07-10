{*******************************************************************************
  作者: fendou116688@163.com 2017/6/2
  描述: 回空业务办卡
*******************************************************************************}
unit UFormBillHaulBack;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  CPort, CPortTypes, UFormNormal, UFormBase, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, cxTextEdit,
  dxLayoutControl, StdCtrls, cxGraphics, cxMaskEdit, cxDropDownEdit,
  cxCheckBox, cxButtonEdit;

type
  TfFormBillHaulBack = class(TfFormNormal)
    EditTruck: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item5: TdxLayoutItem;
    EditCard: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    ComPort1: TComPort;
    EditMemo: TcxTextEdit;
    dxLayout1Item11: TdxLayoutItem;
    EditSrcID: TcxButtonEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditCusName: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditStockName: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditValue: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditCardKeyPress(Sender: TObject; var Key: Char);
    procedure EditTruckKeyPress(Sender: TObject; var Key: Char);
    procedure EditSrcIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
    FBuffer: string;
    //接收缓冲
    FListA, FListB: TStrings;
    //数据传输
    FParam: PFormCommandParam;

    procedure InitFormData(const nOrderInfo: string='');
    procedure ActionComPort(const nStop: Boolean);

    procedure GetPoundHistory(const nSrc: string; const nQueryType: Integer=0);
    //获取历史磅单
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
  USysDB, UBusinessPacker, UDataModule;

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

class function TfFormBillHaulBack.FormID: integer;
begin
  Result := cFI_FormBillHaulback;
end;

class function TfFormBillHaulBack.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
    nListIn: TStrings;
    nStr, nMemo, nTmp: string;
begin
  Result := nil;
  nStr := '';
  nMemo:= '';

  if not Assigned(nParam) then
  begin
    New(nP);
    FillChar(nP^, SizeOf(TFormCommandParam), #0);
  end else
  begin
    nP := nParam;
    nStr := nP.FParamA; //需要作废的单号
    nMemo:= nP.FParamB; //过磅错误信息
    //回空数据
  end;

  nListIn := TStringList.Create;
  try
    if nMemo <> '' then
    try
      SplitStr(nMemo, nListIn, 0, ';');

      nP.FCommand  := 0;            //车牌号查询
      nP.FParamA   := nListIn.Values['Truck'];

      CreateBaseFormItem(cFI_FormGetPoundHis, nPopedom, nP);
      if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
      nTmp := nP.FParamB;
    finally
      if not Assigned(nParam) then Dispose(nP);
    end;
  finally
    nListIn.Free;
  end;

  with TfFormBillHaulBack.Create(Application) do
  try
    FListA := TStringList.Create;
    FListB := TStringList.Create;
    //init

    SplitStr(nMemo, FListB, 0, ';');
    FListB.Values['DelID'] := nStr;

    FParam := nP;
    InitFormData(nTmp);
    ActionComPort(False);

    FParam.FCommand := cCmd_ModalResult;
    FParam.FParamA := ShowModal;
  finally
    if not Assigned(nParam) then Dispose(nP);
    Free;
  end;
end;

procedure TfFormBillHaulBack.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ActionComPort(True);
  FListA.Free;
  FListB.Free;
end;

procedure TfFormBillHaulBack.InitFormData(const nOrderInfo: string);
begin
  ActiveControl := EditTruck;

  if nOrderInfo = '' then Exit;

  FListA.Text := nOrderInfo;
  with FListA do
  begin
    EditSrcID.Text := Values['BillNO'];
    EditCusName.Text := Values['CusName'];
    EditStockName.Text := Values['Stock'];

    EditTruck.Text := Values['Truck'];
    EditValue.Text := Values['Value'];
    EditCard.Text  := FListB.Values['Pound_Card'];
  end;
end;

//Desc: 串口操作
procedure TfFormBillHaulBack.ActionComPort(const nStop: Boolean);
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

procedure TfFormBillHaulBack.ComPort1RxChar(Sender: TObject; Count: Integer);
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

procedure TfFormBillHaulBack.EditCardKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    BtnOK.Click;
  end else OnCtrlKeyPress(Sender, Key);
end;

function TfFormBillHaulBack.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
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
procedure TfFormBillHaulBack.BtnOKClick(Sender: TObject);
var nID: string;
begin
  if not IsDataValid then Exit;

  with FListA do
  begin
    Values['DelBill']  := FListB.Values['DelID'];
    Values['PStation'] := FListB.Values['PStation'];
    Values['PValue']   := FListB.Values['Pound_PValue'];
    Values['Card'] := Trim(EditCard.Text);
  end;

  nID := SaveBillHaulBack(PackerEncodeStr(FListA.Text));
  if nID = '' then Exit;

  ModalResult := mrOk;
  ShowMsg('回空业务办理完毕', sHint);
end;

procedure TfFormBillHaulBack.EditTruckKeyPress(Sender: TObject; var Key: Char);
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
  end else

  if (Sender = EditSrcID) and (Key = Char(VK_RETURN)) then
  begin
    Key := #0;
    GetPoundHistory(EditSrcID.Text, 1);
  end;  
end;

procedure TfFormBillHaulBack.EditSrcIDPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  inherited;
  GetPoundHistory(EditSrcID.Text, 1);
end;

procedure TfFormBillHaulBack.GetPoundHistory(const nSrc: string;
  const nQueryType: Integer=0);
var nP: TFormCommandParam;
begin
  nP.FCommand := nQueryType;
  nP.FParamA  := nSrc;

  CreateBaseFormItem(cFI_FormGetPoundHis, '', @nP);
  if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

  InitFormData(nP.FParamB);
end;    

initialization
  gControlManager.RegCtrl(TfFormBillHaulBack, TfFormBillHaulBack.FormID);
end.

{*******************************************************************************
  作者: fendou116688@163.com 2016/6/15
  描述: 关联供应磁卡
*******************************************************************************}
unit UFormProvCard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  CPort, CPortTypes, UFormNormal, UFormBase, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, cxTextEdit,
  dxLayoutControl, StdCtrls, cxGraphics, cxCheckBox;

type
  TfFormProvCard = class(TfFormNormal)
    EditBill: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditTruck: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item5: TdxLayoutItem;
    EditCard: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    ComPort1: TComPort;
    BtnTruckPre: TcxCheckBox;
    dxLayout1Item7: TdxLayoutItem;
    BtnLongUse: TcxCheckBox;
    dxLayout1Item8: TdxLayoutItem;
    EditMemo: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditCardKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FBuffer: string;
    //接收缓冲
    FListA: TStrings;
    FParam: PFormCommandParam;
    procedure InitFormData;
    procedure ActionComPort(const nStop: Boolean);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, USysBusiness, USmallFunc, USysConst,
  USysDB;

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

var
  gReaderItem: TReaderItem;
  //全局使用

class function TfFormProvCard.FormID: integer;
begin
  Result := cFI_FormMakeProvCard;
end;

class function TfFormProvCard.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;
  if not Assigned(nParam) then Exit;

  with TfFormProvCard.Create(Application) do
  try
    FParam := nParam;
    FListA := TStringList.Create;

    InitFormData;
    ActionComPort(False);

    FParam.FCommand := cCmd_ModalResult;
    FParam.FParamA := ShowModal;
  finally
    Free;
  end;
end;

procedure TfFormProvCard.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ActionComPort(True);
  FreeAndNil(FListA);
end;

procedure TfFormProvCard.InitFormData;
begin
  ActiveControl := EditCard;
  EditTruck.Text := FParam.FParamB;
  EditBill.Text := AdjustListStrFormat(FParam.FParamA, '''', False, ',', False);
end;

//Desc: 串口操作
procedure TfFormProvCard.ActionComPort(const nStop: Boolean);
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

procedure TfFormProvCard.ComPort1RxChar(Sender: TObject; Count: Integer);
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

procedure TfFormProvCard.EditCardKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    BtnOK.Click;
  end else OnCtrlKeyPress(Sender, Key);
end;

//Desc: 保存磁卡
procedure TfFormProvCard.BtnOKClick(Sender: TObject);
begin
  EditCard.Text := Trim(EditCard.Text);
  if EditCard.Text = '' then
  begin
    ActiveControl := EditCard;
    EditCard.SelectAll;

    ShowMsg('请输入有效卡号', sHint);
    Exit;
  end;

  FListA.Clear;
  FListA.Values['ID'] := Trim(EditBill.Text);
  FListA.Values['Card']:= Trim(EditCard.Text);
  FListA.Values['CardSerial'] := Trim(EditMemo.Text);

  if BtnTruckPre.Checked then
       FListA.Values['UsePre'] := sFlag_Yes
  else FListA.Values['UsePre'] := sFlag_No;

  if BtnLongUse.Checked then
       FListA.Values['CardType'] := sFlag_ProvCardG
  else FListA.Values['CardType'] := sFlag_ProvCardL;

  if SaveOrderCard(FListA.Text) then
    ModalResult := mrOk;
  //done
end;

initialization
  gControlManager.RegCtrl(TfFormProvCard, TfFormProvCard.FormID);
end.

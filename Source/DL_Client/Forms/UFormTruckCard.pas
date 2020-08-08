unit UFormTruckCard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels, UFormBase,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, dxLayoutcxEditAdapters,
  cxContainer, cxEdit, cxTextEdit, CPort, CPortTypes, ExtCtrls;

type
  TfFormTruckCard = class(TfFormNormal)
    editCard: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    editTruck: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    ComPort1: TComPort;
    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    procedure ActionComPort(const nStop: Boolean);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

var
  fFormTruckCard: TfFormTruckCard;

implementation

{$R *.dfm}

uses
  IniFiles, USysConst, USmallFunc, UMgrControl, ULibFun, USysDB, UDataModule,
  USysBusiness, UBusinessPacker;

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

procedure TfFormTruckCard.ActionComPort(const nStop: Boolean);
var nInt: Integer;
    nIni: TIniFile;
begin
  if nStop then
  begin
    ComPort1.Close;
    Exit;
  end;

  try
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
  except
    on Ex : Exception do
    begin
      ShowMsg('请检查刷卡器设备是否连接正确：'+Ex.Message, '提示');
    end;
  end;
end;

procedure TfFormTruckCard.ComPort1RxChar(Sender: TObject; Count: Integer);
var nStr: string;
    nIdx,nLen: Integer;
    FBuffer: string;
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

procedure TfFormTruckCard.BtnOKClick(Sender: TObject);
var
  nStr: string;
  nList: TStrings;
begin
  if Trim(editCard.Text) = '' then
  begin
    ShowMsg('磁卡编号不能为空！',sHint);
    editCard.SetFocus;
    Exit;
  end;
  if Trim(editTruck.Text) = '' then
  begin
    ShowMsg('车牌号码不能为空！',sHint);
    Exit;
  end;                   

  nStr := 'select * from %s where T_DriverCard=''%s''';
  nStr := Format(nStr,[sTable_Truck,editCard.Text]);
  with fdm.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      ShowMsg('该磁卡已经绑定有车辆信息,请勿重复绑定.', sHint);
      editCard.SetFocus;
      exit;
    end;
  end;

  //业务逻辑
  try
    FDM.ADOConn.BeginTrans;

    nStr := 'Update %s set T_DriverCard=''%s'' where T_Truck=''%s''';
    nStr := Format(nStr,[sTable_Truck,editCard.Text,editTruck.Text]);
    FDM.ExecuteSQL(nStr);

    //日志
    nStr := '为车辆 [ '+editTruck.Text+' ] 绑定磁卡  [ '+editCard.Text+' ]';
    fdm.WriteSysLog(sFlag_TruckItem,editTruck.Text,nStr);

    FDM.ADOConn.CommitTrans;
    ShowMsg('成功' + nStr,sHint);
    ModalResult := mrOk;
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('为车辆 [ '+edittruck.Text+' ] 绑定磁卡失败！',sHint);
  end;
end;

class function TfFormTruckCard.FormID: integer;
begin
  Result := cFI_FormTruckCard;
end;

class function TfFormTruckCard.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormTruckCard.Create(Application) do
  begin
    edittruck.Text := nP.FParamA;
    ActiveControl := EditCard;

    ActionComPort(False);
    //ShowModal;
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
    Free;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormTruckCard, TfFormTruckCard.FormID);
end.

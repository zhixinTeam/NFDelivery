{*******************************************************************************
  作者: fendou116688@163.com 2017/2/17
  描述: 火车衡过磅
*******************************************************************************}
unit UFramePoundStation;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameBase, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, ADODB, ExtCtrls, cxGridLevel,
  cxClasses, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, cxSplitter, Menus;

type
  TfFramePoundStation = class(TBaseFrame)
    WorkPanel: TScrollBox;
    Timer1: TTimer;
    cxSplitter1: TcxSplitter;
    SQLQuery: TADOQuery;
    DataSource1: TDataSource;
    cxGrid1: TcxGrid;
    cxView1: TcxGridDBTableView;
    cxLevel1: TcxGridLevel;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    procedure WorkPanelMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure Timer1Timer(Sender: TObject);
    procedure N1Click(Sender: TObject);
  private
    { Private declarations }
    FListA : TStrings;
    //通道附加参数
    procedure LoadPoundItems;
    //载入通道
    procedure LoadPoundData(const nWhere: string = '');
    //载入数据
  public
    { Public declarations }
    class function FrameID: integer; override;
    function FrameTitle: string; override;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function DealCommand(Sender: TObject; const nCmd: integer): integer; override;
    //子类继承
  end;

implementation

{$R *.dfm}

uses
  IniFiles, UlibFun, UMgrControl, UMgrPoundTunnels, UFramePoundStationItem,
  UDataModule, UFormWait, USysDataDict, USysGrid,
  USysLoger, USysConst, USysDB;

class function TfFramePoundStation.FrameID: integer;
begin
  Result := cFI_FrameStationPound;
end;

function TfFramePoundStation.FrameTitle: string;
begin
  Result := '称重 - 临时';
end;

procedure TfFramePoundStation.OnCreateFrame;
var nInt: Integer;
    nIni: TIniFile;
begin
  inherited;
  FListA := TStringList.Create;

  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    nInt := nIni.ReadInteger(Name, 'GridHeight', 0);
    if nInt > 20 then
      cxGrid1.Height := nInt;
    //xxxxx

    gSysEntityManager.BuildViewColumn(cxView1, 'MAIN_C02');
    InitTableView(Name, cxView1, nIni);
  finally
    nIni.Free;
  end;

  if not Assigned(gPoundTunnelManager) then
  begin
    gPoundTunnelManager := TPoundTunnelManager.Create;
    gPoundTunnelManager.LoadConfig(gPath + 'Tunnels.xml');
  end;
end;

procedure TfFramePoundStation.OnDestroyFrame;
var nIni: TIniFile;
begin
  FListA.Free;
  //xxxxxx

  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    nIni.WriteInteger(Name, 'GridHeight', cxGrid1.Height);
    SaveUserDefineTableView(Name, cxView1, nIni);
  finally
    nIni.Free;
  end;

  inherited;
end;

function TfFramePoundStation.DealCommand(Sender: TObject;
  const nCmd: integer): integer;
begin
  if (Sender is TfFramePoundStationItem) and (nCmd = cCmd_RefreshData) then
    LoadPoundData;
  Result := 0;
end;

//------------------------------------------------------------------------------
//Desc: 延时载入通道
procedure TfFramePoundStation.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  if gSysParam.FFactNum = '' then
  begin
    ShowDlg('系统需要授权才能称重,请联系管理员.', sHint);
    Exit;
  end;

  LoadPoundItems;
  LoadPoundData;
end;

//Desc: 支持滚轮
procedure TfFramePoundStation.WorkPanelMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
  with WorkPanel do
    VertScrollBar.Position := VertScrollBar.Position - WheelDelta;
  //xxxxx
end;

//Desc: 载入通道
procedure TfFramePoundStation.LoadPoundItems;
var nStr: string;
    nList: TStrings;
    nIdx,nInt: Integer;
    nT: PPTTunnelItem;
begin
  nList := nil;

  with gPoundTunnelManager do
  try
    nList := TStringList.Create;
    nStr := 'Select D_Value,D_Memo From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_DispatchPound]);

    with FDM.QuerySQL(nStr) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nList.Add(Fields[0].AsString + ':' + Fields[1].AsString);
        //JS01:6C-71-D9-56-9C-60
        Next;
      end;
    end;

    for nIdx:=0 to Tunnels.Count - 1 do
    begin
      nT := Tunnels[nIdx];
      //tunnel

      if Assigned(nT.FOptions) and (nT.FOptions.Values['IsGrab'] = 'Y') then
        Continue;
      //码头通道
      
      nStr := '';
      for nInt:=nList.Count - 1 downto 0 do
      begin
        nStr := nT.FID + ':';
        if Pos(nStr, nList[nInt]) < 1 then Continue;

        nStr := nList[nInt];
        System.Delete(nStr, 1, Pos(':', nStr));

        if CompareText(nStr, gSysParam.FLocalMAC) = 0 then
             nStr := ''
        else nStr := sFlag_No;
        Break;
      end;

      if nStr = sFlag_No then Continue;
      //不在本机加载

      with TfFramePoundStationItem.Create(Self) do
      begin
        Name := 'fFramePoundStationItem' + IntToStr(nIdx);
        Parent := WorkPanel;

        Align := alTop;
        HintLabel.Caption := nT.FName;
        PoundTunnel := nT;

        LoadCollapseConfig(nIdx <> 0);
        //折叠面板
      end;
    end;
  finally
    nList.Free;
  end;
end;

//Desc: 载入数据
procedure TfFramePoundStation.LoadPoundData(const nWhere: string);
var nStr: string;
begin
  ShowWaitForm(ParentForm, '读取数据');
  try
    nStr := 'Select * From $TB Where (P_PDate Is Null Or P_MDate Is Null)' +
            ' And (P_PDate > $Now-2 Or P_MDate > $Now-2) And (P_PModel<>''$Tmp'')';
    nStr := MacroValue(nStr, [MI('$TB', sTable_PoundStation),
            MI('$Now', sField_SQLServer_Now), MI('$Tmp', sFlag_PoundLS)]);
    //xxxxx

    if nWhere <> '' then
      nStr := nStr + ' And (' + nWhere + ')';
    FDM.QueryData(SQLQuery, nStr, False);
  finally
    CloseWaitForm;
  end;
end;

procedure TfFramePoundStation.N1Click(Sender: TObject);
begin
  LoadPoundData('');
end;

initialization
  gControlManager.RegCtrl(TfFramePoundStation, TfFramePoundStation.FrameID);
end.

{*******************************************************************************
  ����: dmzn@163.com 2012-4-21
  ����: Զ�̴�ӡ�������
*******************************************************************************}
unit UFormMain;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UTrayIcon, ComCtrls, StdCtrls, ExtCtrls, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, cxCalendar, cxLabel;

type
  TfFormMain = class(TForm)
    MemoLog: TMemo;
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    Group1: TGroupBox;
    BtnConn: TButton;
    Group2: TGroupBox;
    cxLabel1: TcxLabel;
    EditStart: TcxDateEdit;
    cxLabel2: TcxLabel;
    EditEnd: TcxDateEdit;
    Group3: TGroupBox;
    EditMax: TcxTextEdit;
    GroupBox1: TGroupBox;
    BtnTotal: TButton;
    BtnAdjust: TButton;
    Button3: TButton;
    procedure FormCreate(Sender: TObject);
    procedure BtnConnClick(Sender: TObject);
    procedure BtnTotalClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnAdjustClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
    FTrayIcon: TTrayIcon;
    {*״̬��ͼ��*}
    FList: TStrings;
    procedure ShowLog(const nStr: string);
    //��ʾ��־
  public
    { Public declarations }
  end;

var
  fFormMain: TfFormMain;

implementation

{$R *.dfm}
uses
  IniFiles, Registry, ULibFun, UDataModule, USysLoger, UFormConn, UFormWait,
  DB, USysDB;

var
  gPath: string;               //����·��

resourcestring
  sHint               = '��ʾ';
  sConfig             = 'Config.Ini';
  sForm               = 'FormInfo.Ini';
  sDB                 = 'DBConn.Ini';
  sAutoStartKey       = 'RemotePrinter';

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFormMain, '����У��ҵ��', nEvent);
end;

//------------------------------------------------------------------------------
procedure TfFormMain.FormCreate(Sender: TObject);
begin
  Randomize;
  gPath := ExtractFilePath(Application.ExeName);
  InitGlobalVariant(gPath, gPath+sConfig, gPath+sForm, gPath+sDB);
  
  gSysLoger := TSysLoger.Create(gPath + 'Logs\');
  gSysLoger.LogSync := True;
  gSysLoger.LogEvent := ShowLog;

  FTrayIcon := TTrayIcon.Create(Self);
  FTrayIcon.Hint := Caption;
  FTrayIcon.Visible := True;

  FList := TStringList.Create;
  LoadFormConfig(Self);
  
  EditStart.Date := Now();
  EditEnd.Date := Now();

  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := BuildConnectDBStr;
  //���ݿ�����
end;

procedure TfFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveFormConfig(Self);
  FList.Free;
end;

procedure TfFormMain.ShowLog(const nStr: string);
var nIdx: Integer;
begin
  MemoLog.Lines.BeginUpdate;
  try
    MemoLog.Lines.Insert(0, nStr);
    if MemoLog.Lines.Count > 100 then
     for nIdx:=MemoLog.Lines.Count - 1 downto 50 do
      MemoLog.Lines.Delete(nIdx);
  finally
    MemoLog.Lines.EndUpdate;
  end;
end;

//Desc: ����nConnStr�Ƿ���Ч
function ConnCallBack(const nConnStr: string): Boolean;
begin
  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := nConnStr;
  FDM.ADOConn.Open;
  Result := FDM.ADOConn.Connected;
end;

//Desc: ���ݿ�����
procedure TfFormMain.BtnConnClick(Sender: TObject);
begin
  if ShowConnectDBSetupForm(ConnCallBack) then
  begin
    FDM.ADOConn.Close;
    FDM.ADOConn.ConnectionString := BuildConnectDBStr;
    //���ݿ�����
  end;
end;

procedure TfFormMain.BtnTotalClick(Sender: TObject);
var nStr: string;
begin
  ShowWaitForm(Self, '����ͳ��');
  try
    nStr := '��ʼͳ�ƽ�����: ';
    WriteLog(nStr + #13#10);

    nStr := '����: ����[ %s -> %s ] ������ >= %s ��.';
    nStr := Format(nStr, [Date2Str(EditStart.Date),
            Date2Str(EditEnd.Date + 1), EditMax.Text]);
    WriteLog(nStr);

    nStr := 'Select Count(*) From %s ' +
            'Where L_Date>=''%s'' And L_Date<''%s'' And L_Value>=%s';
    nStr := Format(nStr, [sTable_Bill, Date2Str(EditStart.Date),
            Date2Str(EditEnd.Date + 1), EditMax.Text]);
    //xxxxx

    with FDM.SQLQuery(nStr, FDM.SQLTemp) do
    begin
      nStr := '���: %d �ʼ�¼.';
      nStr := Format(nStr, [Fields[0].AsInteger]);
      WriteLog(nStr);
    end;

    //--------------------------------------------------------------------------
    nStr := '��ʼͳ�ƹ�����: ';
    WriteLog(nStr + #13#10);

    nStr := '����: ����[ %s -> %s ] ������ >= %s ��.';
    nStr := Format(nStr, [Date2Str(EditStart.Date),
            Date2Str(EditEnd.Date + 1), EditMax.Text]);
    WriteLog(nStr);

    nStr := 'Select Count(*) From %s ' +
            'Where P_PDate>=''%s'' And P_PDate<''%s'' And ' +
            '(P_MValue-P_PValue)>=%s';
    nStr := Format(nStr, [sTable_PoundLog, Date2Str(EditStart.Date),
            Date2Str(EditEnd.Date + 1), EditMax.Text]);
    //xxxxx

    with FDM.SQLQuery(nStr, FDM.SQLTemp) do
    begin
      nStr := '���: %d �ʼ�¼.';
      nStr := Format(nStr, [Fields[0].AsInteger]);
      WriteLog(nStr);
    end;
  finally
    CloseWaitForm;
  end;
end;

function RandomDai(const nMax: Integer): Integer;
var nDai,nNum: Integer;
begin
  nNum := 0;
  Result := 0;
  
  while True do
  try
    nDai := Random(nMax + 1);
    if (nDai < 100) or (nDai >= nMax) then Continue;

    if Result = 0 then
      Result := nDai;
    //xxxxx

    if nDai mod 20 = 0 then
    begin
      Result := nDai;
      Break;
    end; //��������

    if nDai mod 10 = 0 then
      Result := nDai;
    //xxxxx

    if nNum > 20 then Break;
  finally
    Inc(nNum);
  end;
end;

function RandomSan(const nMax: Integer; nMin: Integer = 5000): Double;
var nVal,nNum: Integer;
begin
  nNum := 0;
  Result := 0;
  
  while True do
  try
    nVal := Random(nMax + 1);
    if (nVal < nMin) or (nVal >= nMax) then Continue;
                      
    if Result = 0 then
      Result := nVal;
    //xxxxx

    if nVal mod 1000 = 0 then
    begin
      Result := nVal;
      Break;
    end; //��������

    if nVal mod 500 = 0 then
      Result := nVal;
    //xxxxx

    if nNum > 10 then Break;
  finally
    Inc(nNum);
  end;

  Result := Trunc(Result / 20) * 20 / 1000;
  //��С����20����
end;

procedure TfFormMain.BtnAdjustClick(Sender: TObject);
var nStr: string;
    nVal,nMaxVal: Double;
    nIdx,nMaxDai: Integer;
begin
  ShowWaitForm(Self, '����У��');
  try
    FList.Clear;
    nMaxVal := StrToFloat(EditMax.Text);
    nMaxDai := Trunc(nMaxVal * 1000 / 50);

    nStr := '��ʼУ��������: ';
    WriteLog(nStr + #13#10);

    nStr := '����: ����[ %s -> %s ] ������ >= %s ��.';
    nStr := Format(nStr, [Date2Str(EditStart.Date),
            Date2Str(EditEnd.Date + 1), EditMax.Text]);
    WriteLog(nStr);

    nStr := 'Select L_ID,L_Type,L_Value,BK_Value From %s ' +
            'Where L_Date>=''%s'' And L_Date<''%s'' And ' +
            'L_Value>=%s And L_MValue Is Not Null';
    nStr := Format(nStr, [sTable_Bill, Date2Str(EditStart.Date),
            Date2Str(EditEnd.Date + 1), EditMax.Text]);
    //xxxxx

    with FDM.SQLQuery(nStr, FDM.SQLTemp) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        if FieldByName('BK_Value').AsFloat = 0 then
        begin
          nStr := 'Update %s Set BK_Value=L_Value,BK_MValue=L_MValue ' +
                  'Where L_ID=''%s''';
          nStr := Format(nStr, [sTable_Bill, FieldByName('L_ID').AsString]);
          FList.Add(nStr);
        end;

        if FieldByName('L_Type').AsString = sFlag_Dai then
        begin
          nVal := RandomDai(nMaxDai) * 50 / 1000;
          nVal := Float2Float(nVal, 100);
        end else
        begin
          nVal := RandomSan(Trunc(nMaxVal * 1000), Trunc(nMaxVal * 0.8 * 1000));
          nVal := Float2Float(nVal, 100);
        end;

        nStr := 'Update %s Set L_Value=%.2f,L_MValue=L_PValue+%.2f ' +
                'Where L_ID=''%s''';
        nStr := Format(nStr, [sTable_Bill, nVal, nVal,
                FieldByName('L_ID').AsString]);
        FList.Add(nStr);

        Next;
      end;
    end;

    nStr := 'У��������: %d ��';
    nStr := Format(nStr, [FDM.SQLTemp.RecordCount]);
    WriteLog(nStr);

    //--------------------------------------------------------------------------
    nStr := '��ʼУ��������: ';
    WriteLog(nStr + #13#10);

    nStr := '����: ����[ %s -> %s ] ������ >= %s ��.';
    nStr := Format(nStr, [Date2Str(EditStart.Date),
            Date2Str(EditEnd.Date + 1), EditMax.Text]);
    WriteLog(nStr);

    nStr := 'Select P_ID,P_MType,BK_Value From %s ' +
            'Where P_PDate>=''%s'' And P_PDate<''%s'' And ' +
            '(P_MValue-P_PValue)>=%s';
    nStr := Format(nStr, [sTable_PoundLog, Date2Str(EditStart.Date),
            Date2Str(EditEnd.Date + 1), EditMax.Text]);
    //xxxxx

    with FDM.SQLQuery(nStr, FDM.SQLTemp) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        if FieldByName('BK_Value').AsFloat = 0 then
        begin
          nStr := 'Update %s Set BK_Value=P_LimValue,BK_MValue=P_MValue ' +
                  'Where P_ID=''%s''';
          nStr := Format(nStr, [sTable_PoundLog, FieldByName('P_ID').AsString]);
          FList.Add(nStr);
        end;

        if FieldByName('P_MType').AsString = sFlag_Dai then
        begin
          nVal := RandomDai(nMaxDai) * 50 / 1000;
          nVal := Float2Float(nVal, 100);
        end else
        begin
          nVal := RandomSan(Trunc(nMaxVal * 1000), Trunc(nMaxVal * 0.8 * 1000));
          nVal := Float2Float(nVal, 100);
        end;

        nStr := 'Update %s Set P_LimValue=%d,P_MValue=P_PValue+%.2f ' +
                'Where P_ID=''%s''';
        nStr := Format(nStr, [sTable_PoundLog, Round(nVal), nVal,
                FieldByName('P_ID').AsString]);
        FList.Add(nStr);

        Next;
      end;
    end;

    nStr := 'У��������: %d ��';
    nStr := Format(nStr, [FDM.SQLTemp.RecordCount]);
    WriteLog(nStr);

    //--------------------------------------------------------------------------
    FDM.ADOConn.BeginTrans;
    try
      for nIdx:=0 to FList.Count - 1 do
      begin
        FDM.SQLQuery1.Close;
        FDM.SQLQuery1.SQL.Text := FList[nIdx];
        FDM.SQLQuery1.ExecSQL;

        nStr := Format('����У��: %d/%d', [nIdx, FList.Count]);
        ShowWaitForm(Self, nStr);
      end;

      FDM.ADOConn.CommitTrans;
      ShowMsg('У�����', sHint);
    except
      On E: Exception do
      begin
        FDM.ADOConn.RollbackTrans;
        WriteLog(E.Message);
        ShowMsg('У��ʧ��', sHint);
      end;
    end;  
  finally
    CloseWaitForm;
  end;
end;

procedure TfFormMain.Button3Click(Sender: TObject);
var nStr: string;
    nIdx: Integer;
begin
  ShowWaitForm(Self, '��ʼ��ԭ');
  try
    FList.Clear;
    nStr := '��ʼ��ԭ������: ';
    WriteLog(nStr + #13#10);

    nStr := '����: ����[ %s -> %s ] ������ >= %s ��.';
    nStr := Format(nStr, [Date2Str(EditStart.Date),
            Date2Str(EditEnd.Date + 1), EditMax.Text]);
    WriteLog(nStr);

    nStr := 'Update %s Set L_Value=BK_Value,L_MValue=BK_MValue ' +
            'Where L_Date>=''%s'' And L_Date<''%s'' And BK_Value Is Not Null';
    nStr := Format(nStr, [sTable_Bill, Date2Str(EditStart.Date),
            Date2Str(EditEnd.Date + 1)]);
    FList.Add(nStr);

    //--------------------------------------------------------------------------
    nStr := '��ʼ��ԭ������: ';
    WriteLog(nStr + #13#10);

    nStr := '����: ����[ %s -> %s ] ������ >= %s ��.';
    nStr := Format(nStr, [Date2Str(EditStart.Date),
            Date2Str(EditEnd.Date + 1), EditMax.Text]);
    WriteLog(nStr);

    nStr := 'Update %s Set P_LimValue=BK_Value,P_MValue=BK_MValue ' +
            'Where P_PDate>=''%s'' And P_PDate<''%s'' And BK_Value Is Not Null';
    nStr := Format(nStr, [sTable_PoundLog, Date2Str(EditStart.Date),
            Date2Str(EditEnd.Date + 1)]);
    FList.Add(nStr);

    //--------------------------------------------------------------------------
    FDM.ADOConn.BeginTrans;
    try
      for nIdx:=0 to FList.Count - 1 do
      begin
        FDM.SQLQuery1.Close;
        FDM.SQLQuery1.SQL.Text := FList[nIdx];
        FDM.SQLQuery1.ExecSQL;
      end;

      FDM.ADOConn.CommitTrans;
      ShowMsg('��ԭ���', sHint);
    except
      On E: Exception do
      begin
        FDM.ADOConn.RollbackTrans;
        WriteLog(E.Message);
        ShowMsg('��ԭʧ��', sHint);
      end;
    end;
  finally
    CloseWaitForm;
  end;
end;

end.

{*******************************************************************************
  作者: dmzn@163.com 2012-5-3
  描述: 数据模块
*******************************************************************************}
unit UDataModule;

interface

uses
  SysUtils, Classes, DB, ADODB, USysLoger;

type
  TFDM = class(TDataModule)
    ADOConn: TADOConnection;
    SQLQuery1: TADOQuery;
    SQLTemp: TADOQuery;
  private
    { Private declarations }
  public
    { Public declarations }
    function SQLQuery(const nSQL: string; const nQuery: TADOQuery): TDataSet;
    //查询数据库
    function SQLExec(const nSQL: string; const nQuery: TADOQuery):Integer;
    procedure ExecSQLs(const nSQLs: TStrings);
  end;

var
  FDM: TFDM;

implementation

{$R *.dfm}

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TFDM, '数据模块', nEvent);
end;

//Date: 2012-5-3
//Parm: SQL;是否保持连接
//Desc: 执行SQL数据库查询
function TFDM.SQLQuery(const nSQL: string; const nQuery: TADOQuery): TDataSet;
var nInt: Integer;
begin
  Result := nil;
  nInt := 0;

  while nInt < 2 do
  try
    if not ADOConn.Connected then
      ADOConn.Connected := True;
    //xxxxx

    with nQuery do
    begin
      Close;
      SQL.Text := nSQL;
      Open;
    end;

    Result := nQuery;
    Exit;
  except
    on E:Exception do
    begin
      ADOConn.Connected := False;
      Inc(nInt);
      WriteLog(E.Message);
    end;
  end;
end;


procedure TFDM.ExecSQLs(const nSQLs: TStrings);
var nCount:Integer;
begin
  ADOConn.BeginTrans;
  try
    for nCount:=0 to nSQLs.Count-1 do
     ADOConn.Execute(nSQLs[nCount]);

    ADOConn.CommitTrans;
  except
    ADOConn.RollbackTrans;
  end;
end;

function TFDM.SQLExec(const nSQL: string;
  const nQuery: TADOQuery):Integer;
var nInt: Integer;
begin
  nInt := 0;
  while nInt < 2 do
  try
    if not ADOConn.Connected then
      ADOConn.Connected := True;
    //xxxxx

    with nQuery do
    begin
      Close;
      SQL.Text := nSQL;
      Result := ExecSQL;
    end;

    Exit;
  except
    on E:Exception do
    begin
      ADOConn.Connected := False;
      WriteLog(E.Message);
      Inc(nInt);
    end;
  end;
end;

end.

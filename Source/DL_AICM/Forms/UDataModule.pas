{*******************************************************************************
  ����: dmzn@163.com 2012-5-3
  ����: ����ģ��
*******************************************************************************}
unit UDataModule;

interface

uses
  SysUtils, Classes, DB, ADODB;

type
  TFDM = class(TDataModule)
    ADOConn: TADOConnection;
    SQLQuery1: TADOQuery;
    ExecCommand: TADOQuery;
  private
    { Private declarations }
  public
    { Public declarations }
    function SQLQuery(const nSQL: string): TDataSet;
    //��ѯ���ݿ�
    function ExecuteSQL(const nSQL: string): integer;
    //ִ���������
  end;

var
  FDM: TFDM;

implementation

{$R *.dfm}

//Date: 2012-5-3
//Parm: SQL;�Ƿ񱣳�����
//Desc: ִ��SQL���ݿ��ѯ
function TFDM.SQLQuery(const nSQL: string): TDataSet;
var nInt: Integer;
begin
  Result := nil;
  nInt := 0;

  while nInt < 2 do
  try
    if not ADOConn.Connected then
      ADOConn.Connected := True;
    //xxxxx

    SQLQuery1.Close;
    SQLQuery1.SQL.Text := nSQL;
    SQLQuery1.Open;

    Result := SQLQuery1;
    Exit;
  except
    ADOConn.Connected := False;
    Inc(nInt);
  end;
end;

function TFDM.ExecuteSQL(const nSQL: string): integer;
var nInt: Integer;
begin
  Result := -1;
  nInt := 0;

  while nInt < 2 do
  try
    if not ADOConn.Connected then
      ADOConn.Connected := True;
    //xxxxx

    ExecCommand.Close;
    ExecCommand.SQL.Text := nSQL;
    Result := ExecCommand.ExecSQL;
    Exit;
  except
    ADOConn.Connected := False;
    Inc(nInt);
  end;
end;

end.

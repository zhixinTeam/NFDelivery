{*******************************************************************************
  ����: dmzn@163.com 2012-5-3
  ����: ����ģ��
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
    QueryLocal: TADOQuery;
    ADOLocal: TADOConnection;
  private
    { Private declarations }
  public
    { Public declarations }
    function QueryData(const nSQL: string; nQuery: TADOQuery = nil;
     const nLocal: Boolean = False): TDataSet;
    //��ѯ���ݿ�
  end;

var
  FDM: TFDM;

implementation

{$R *.dfm}

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TFDM, '����ģ��', nEvent);
end;

//Date: 2012-5-3
//Parm: SQL;�Ƿ񱣳�����;��ѯ����
//Desc: ִ��SQL���ݿ��ѯ
function TFDM.QueryData(const nSQL: string; nQuery: TADOQuery;
 const nLocal: Boolean): TDataSet;
begin
  Result := nil;
  try
    if nLocal then
    begin
      if not ADOLocal.Connected then
        ADOLocal.Connected := True;
      //xxxxx

      if not Assigned(nQuery) then
        nQuery := QueryLocal;
      //xxxxx
    end else
    begin
      if not ADOConn.Connected then
        ADOConn.Connected := True;
      //xxxxx

      if not Assigned(nQuery) then
        nQuery := SQLQuery1;
      //xxxxx
    end;

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
      WriteLog(E.Message);
    end;
  end;
end;

end.

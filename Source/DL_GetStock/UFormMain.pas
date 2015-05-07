unit UFormMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Memo1: TMemo;
    Memo2: TMemo;
    Button1: TButton;
    procedure FormResize(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
uses
  ULibFun, UFormCtrl;

procedure TForm1.FormResize(Sender: TObject);
begin
  Memo1.Height := Trunc( (ClientHeight - Panel1.Height) / 2 );
end;

function AdjustStr(const nStr: string): string;
begin
  Result := StringReplace(nStr, '"', '', [rfReplaceAll]);
end;

procedure TForm1.Button1Click(Sender: TObject);
var nStr,nType: string;
    nIdx: Integer;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    Memo2.Text := 'Delete From Sys_Dict Where D_Name=''StockItem''';
    //xxxxx

    for nIdx:=0 to Memo1.Lines.Count - 1 do
    begin
      if not SplitStr(Memo1.Lines[nIdx], nList, 3, ';') then Continue;
      //xxxxx

      if (Pos('´ü×°', nList[1]) > 0) or (Pos('°ü×°', nList[1]) > 0) then
           nType := 'D'
      else nType := 'S';

      nStr := MakeSQLByStr([SF('D_Name', 'StockItem'),
               SF('D_Desc', AdjustStr(nList[2])),
               SF('D_Value', AdjustStr(nList[1])),
               SF('D_Memo', nType),
               SF('D_ParamB', AdjustStr(nList[0]))
              ], 'Sys_Dict', '', True);
      Memo2.Lines.Add(nStr);
    end;
  finally

  end;   
end;

end.

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
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    Memo2.Text := 'Delete From S_Truck Where T_PrePUse=''Y''';
    //xxxxx

    for nIdx:=0 to Memo1.Lines.Count - 1 do
    begin
      if not SplitStr(Memo1.Lines[nIdx], nList, 0, #09) then Continue;
      //xxxxx

      nStr := MakeSQLByStr([
               SF('T_Truck', AdjustStr(nList[0])),
               SF('T_PrePValue', AdjustStr(nList[1])),
               SF('T_PrePUse', 'Y')
              ], 'S_Truck', '', True);
      Memo2.Lines.Add(nStr);
    end;
  finally

  end;
end;

end.

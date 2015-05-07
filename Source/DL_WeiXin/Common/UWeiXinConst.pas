{*******************************************************************************
  作者: dmzn@163.com 2011-10-22
  描述: 常量定义
*******************************************************************************}
unit UWeiXinConst;

{$I Link.Inc}
interface

uses
  Windows, SysUtils, Classes, ComCtrls, Forms, IniFiles, USysMAC, UMgrDBConn,
  UMgrDB, ULibFun, UBase64, USysDB;

const
  {*Frame ID*}

  {*Form ID*}
  cFI_FormDB          = $0051;                       //数据库

  {*Command*}
  cCmd_AdminChanged   = $0001;                       //管理切换
  cCmd_RefreshData    = $0002;                       //刷新数据
  cCmd_ViewSysLog     = $0003;                       //系统日志

  cCmd_ModalResult    = $1001;                       //Modal窗体
  cCmd_FormClose      = $1002;                       //关闭窗口
  cCmd_AddData        = $1003;                       //添加数据
  cCmd_EditData       = $1005;                       //修改数据
  cCmd_ViewData       = $1006;                       //查看数据

  {*常用参数*}
  cParamIDCharacters = ['a'..'z','A'..'Z','0'..'9','_',Char(VK_BACK)];
  //ID标识可用字符

type
  TDBParams = array of TDBParam;

var
  gWeiXinPath: string;                                     //程序所在路径

procedure InitSystemEnvironment;
//初始化系统运行环境的变量
procedure LoadDBParamFromDB(var nDBParams: TDBParams);
procedure LoadDBParamFromFile(nConf: String; var nDBParams: TDBParams);
//加载参数

//------------------------------------------------------------------------------
ResourceString
  sProgID             = 'WeiXin';                   //默认标识
  sAppTitle           = 'WeiXin';                   //程序标题
  sMainCaption        = '微信中间件';                //主窗口标题
  sHintText           = '微信中间件服务';            //提示内容

  sHint               = '提示';                      //对话框标题
  sWarn               = '警告';                      //==
  sAsk                = '询问';                      //询问对话框
  sError              = '错误';                      //错误对话框

  sDate               = '日期:【%s】';               //任务栏日期
  sTime               = '时间:【%s】';               //任务栏时间
  sUser               = '用户:【%s】';               //任务栏用户

  sConfigFile         = 'Config.Ini';                //主配置文件
  sConfigSec          = 'Config';                    //主配置小节

  sDBConfigFile       = 'DBConn.Ini';                //数据库配置
  
  sFormConfig         = 'FormInfo.ini';              //窗体配置
  sLogDir             = 'Logs\';                     //日志目录
  sLogSyncLock        = 'SyncLock_Weixin_CommonMIT';    //日志同步锁

  sInvalidConfig      = '配置文件无效或已经损坏';    //配置文件无效
  sCloseQuery         = '确定要退出程序吗?';         //主窗口退出
  
implementation

procedure InitSystemEnvironment;
begin
  Randomize;
  ShortDateFormat := 'YYYY-MM-DD';
  gWeiXinPath := ExtractFilePath(Application.ExeName);
end;

procedure LoadDBParamFromFile(nConf: String; var nDBParams: TDBParams);
var nIdx: Integer;
    nIni: TIniFile;
    nList: TStrings;
    nDBItem: TDBParam;
    nDBList, nDBName, nStr: string;
begin
  SetLength(nDBParams, 0);
  if not FileExists(nConf) then Exit;

  nList := TStringList.Create;
  nIni  := TIniFile.Create(nConf);
  try
     nStr := nIni.ReadString('DBConn', 'Splitter', '');
     if nStr='' then nStr := ' ';

     nDBList := nIni.ReadString('DBConn', 'DBList', '');
     if not SplitStr(nDBList, nList, 0, nStr, False) then Exit;

     SetLength(nDBParams, nList.Count);

     for nIdx:=0 to nList.Count-1 do
     begin
       nDBName := nList[nIdx];

       FillChar(nDBItem, SizeOf(TDBParam), 0);
       with nDBItem do
       begin
         FName := nDBName;
         FID   := nIni.ReadString(nDBName, 'DBID', '');
         //数据库标识名称,参数标识

         FHost := nIni.ReadString(nDBName, 'DBHost', '');
         FPort := nIni.ReadInteger(nDBName, 'DBPort', 0);
         //服务器地址，端口

         FDB   := nIni.ReadString(nDBName, 'DBCatalog', '');
         FUser := nIni.ReadString(nDBName, 'DBUser', '');
         FPwd  := Trim(DecodeBase64(nIni.ReadString(nDBName, 'DBPwd', '')));
         //数据库名称,用户名,密码

         FConn := nIni.ReadString(nDBName, 'DBConnStr', '');
         //数据库连接字符串

         FNumWorker:= nIni.ReadInteger(nDBName, 'DBWorker', 3);
         //对象数

         FEnable := nIni.ReadBool(nDBName, 'Active', False);
       end;

       nDBParams[nIdx] := nDBItem;
     end;
  finally
    nList.Free;
    nIni.Free;
  end;
end;

procedure LoadDBParamFromDB(var nDBParams: TDBParams);
var nStr: string;
    nInt: Integer;
    nDBItem: TDBParam;
    nDBWorker: PDBWorker;
begin
  SetLength(nDBParams, 0);

  //{$IFDEF SQLPARAM}
  nStr := 'Select * from %s where F_Valid<>''%s''';
  nStr := Format(nStr, ['Sys_FactServer', sFlag_No]);
  try
    with gDBConnManager.SQLQuery(nStr, nDBWorker) do
    begin
      if RecordCount<1 then Exit;

      SetLength(nDBParams, RecordCount);
      nInt := Low(nDBParams);
      //xxxxxx

      First;
      while not Eof do
      begin
        FillChar(nDBItem, SizeOf(TDBParam), 0);

        with nDBItem do
        begin
          FName := FieldByName('F_ServName').AsString;
          FID   := FieldByName('F_ServID').AsString;
          //数据库标识名称,参数标识

          FHost := FieldByName('F_ServIP').AsString;
          FPort := FieldByName('F_ServPort').AsInteger;
          //服务器地址，端口

          FDB   := FieldByName('F_ServDataSource').AsString;
          FUser := Trim(DecodeBase64(FieldByName('F_ServUser').AsString));
          FPwd  := Trim(DecodeBase64(FieldByName('F_ServPsw').AsString));
          //数据库名称,用户名,密码

          FConn := Trim(DecodeBase64(FieldByName('F_ServConn').AsString));
          //数据库连接字符串

          FNumWorker:= FieldByName('F_ServPort').AsInteger;
          //对象数

          FEnable := FieldByName('F_Valid').AsString = sFlag_No;
        end;

        nDBParams[nInt] := nDBItem;
        Inc(nInt);
        Next;
      end;  
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
  //{$ENDIF}
end;  

end.

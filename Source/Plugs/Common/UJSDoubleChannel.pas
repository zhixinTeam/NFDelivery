unit UJSDoubleChannel;

interface

type
  PDoubleChannel = ^TDoubleChannel;
  TDoubleChannel  = record
    FTunnel     : string;      //装车通道
    FMutexTunnel: string;      //互斥通道
    FBill       : string;      //交货单号
    FTruck      : string;      //车牌号
    FStockNo    : string;      //物料号
    FStockName  : string;      //品种名
    FDaiNum     : Word;        //需装袋数
    FHasDone    : Word;        //已装袋数
    FIsRun      : Boolean;     //运行标记
    FLastTime   : Int64;       //时间戳
    FBanDaoNum  : Integer;     //扳道号
  end;

var
  gDoubleChannel: array of TDoubleChannel;
  //双通道缓存

implementation

end.

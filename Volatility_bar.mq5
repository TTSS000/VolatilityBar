//+------------------------------------------------------------------+
//|                                               Volatility_bar.mq4 |
//|                                                          ttss000 |
//|                                      https://twitter.com/ttss000 |
//+------------------------------------------------------------------+
#property copyright "ttss000"
#property link      "https://twitter.com/ttss000"
#property version   "1.0"                         // 2021/12/28

#property indicator_chart_window

#define WM_MDIGETACTIVE 0x00000229
#import "user32.dll"
  int GetParent(int hWnd);
  int SendMessageW(int hWnd,int Msg,int wParam,int lParam);
#import

string indicator_sname = "valatility bar";
input int VolabarPoints = 200;
extern int LocationX = 230; // x location
//input string memo="- means center";
extern int LocationY = -1; // y location
input int Width = 3; // width
extern color BarColor = Green;
//extern ENUM_BASE_CORNER AncorCorner = CORNER_RIGHT_LOWER;   // CORNER_RIGHT_Upper

int chart_height;
int chart_width;

/*-- 変数の宣言 ----------------------------------------------------*/
int ClientHandle = 0; //クライアントウィンドウハンドル保持用
int ThisWinHandle = 0; //Thisウィンドウハンドル保持用
int ParentWinHandle = 0; //Parentウィンドウハンドル保持用

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
  chart_height=ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
  chart_width=ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);

  ClientHandle = (int)ChartGetInteger(0,CHART_WINDOW_HANDLE);
  //          Print ("SyncMain OnTimer ClientHandle0: "+ClientHandle);
  if (ClientHandle != 0) ThisWinHandle = GetParent(ClientHandle);
  //          Print ("SyncMain OnTimer ClientHandle1: "+ClientHandle);
  if (ThisWinHandle != 0) ParentWinHandle = GetParent(ThisWinHandle);

  EventSetTimer(2);
  return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
  //if(reason == REASON_REMOVE || reason == REASON_PARAMETERS ||  reason == REASON_CHARTCHANGE  ||  reason == REASON_RECOMPILE){
  if(reason == REASON_REMOVE || reason == REASON_PARAMETERS ||  reason == REASON_RECOMPILE){
    ObjectDelete(0, indicator_sname);
  }
  // 不要になったら削除
}
//+------------------------------------------------------------------+
void display_vola_bar()
{
  int LocationX_abs;
  int LocationY_abs;
  datetime dt0,dt1;
  double price0,price1;
  int window_num= 0;

  int chart_id=0;
  string obj_name=indicator_sname;

  int wHandle = SendMessageW(ParentWinHandle,WM_MDIGETACTIVE,0,0);
  //Print ("main ce cli wHandle "+wHandle);
  if(wHandle != ThisWinHandle){
    // if not activated
    return;
  }

  double chart_price_max=ChartGetDouble(0,CHART_PRICE_MAX,0);
  double chart_price_min=ChartGetDouble(0,CHART_PRICE_MIN,0);
  chart_height=ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
  chart_width=ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);

  if(0 < LocationX){
    LocationX_abs = LocationX;
  }else{
    LocationX_abs = 0;
  }

  if(0 < LocationY){
    LocationY_abs = LocationY;
  }else{
    LocationY_abs = chart_height/2;
  }

  //if(AncorCorner == CORNER_RIGHT_LOWER){
  //  LocationX_abs=chart_width - LocationX;
  //  LocationY_abs=chart_height - LocationY;
  //}else if(AncorCorner == CORNER_RIGHT_UPPER){
  //  LocationX_abs=chart_width - LocationX;
  //}else if(AncorCorner == CORNER_LEFT_LOWER){
  //  LocationY_abs=chart_height - LocationY;
  // }

  if(LocationX_abs < 0 || chart_width < LocationX_abs){
    LocationX_abs = chart_width/2;
  }

  if(LocationY_abs < 0 || chart_height < LocationY_abs){
    LocationY_abs = chart_height/2;
  }
  //Print("LocationX_abs="+LocationX_abs);
  //Print("LocationY_abs="+LocationY_abs);

  ChartXYToTimePrice(0, chart_width-LocationX,LocationY_abs , window_num, dt0, price0);
  ChartXYToTimePrice(0, LocationX_abs, LocationY_abs, window_num, dt1, price1);
  //Print("0 dt0,1,price0,1="+TimeToString(dt0,TIME_DATE|TIME_SECONDS)+"     "+TimeToString(dt1,TIME_DATE|TIME_SECONDS)+"     "+price0+"     "+price1);

  if(LocationY < 0){
    price0=(chart_price_max+chart_price_min)/2+Point()*VolabarPoints/2;
    price1=(chart_price_max+chart_price_min)/2-Point()*VolabarPoints/2;
    //Print("1 dt0,1,price0,1="+dt0+"     "+dt1+"     "+price0+"     "+price1);

  }else{
    price0=price1+Point()*VolabarPoints/2;
    price1=price0-Point()*VolabarPoints;
  }

  // get price max price min
  // オブジェクトを作成
  if (ObjectFind(0,indicator_sname) < 0){
    //ObjectCreate(0,indicator_sname, OBJ_RECTANGLE,0, dt0,price1, dt1,price0);
    ObjectCreate(0,indicator_sname, OBJ_TREND,0, dt0,price1, dt0,price0);
  }else{
    ObjectMove(0, indicator_sname, 0, dt0,price1);
    ObjectMove(0, indicator_sname, 1, dt0,price0);
  }
  //ObjectSet(indicator_sname, OBJPROP_BACK, true);
  ObjectSetInteger(chart_id,indicator_sname,OBJPROP_BACK,true);

  //ObjectSet(indicator_sname, OBJPROP_CORNER, AncorCorner);
  // カラーを変更する
  ObjectSetInteger(chart_id,obj_name,OBJPROP_COLOR,BarColor);    // ラインの色設定
  ObjectSetInteger(chart_id,obj_name,OBJPROP_STYLE,STYLE_SOLID);  // ラインのスタイル設定
  ObjectSetInteger(chart_id,obj_name,OBJPROP_WIDTH,Width);              // ラインの幅設定
  ObjectSetInteger(chart_id,obj_name,OBJPROP_BACK,true);           // オブジェクトの背景表示設定
  ObjectSetInteger(chart_id,obj_name,OBJPROP_SELECTABLE,true);     // オブジェクトの選択可否設定
  ObjectSetInteger(chart_id,obj_name,OBJPROP_SELECTED,false);       // オブジェクトの選択状態
  ObjectSetInteger(chart_id,obj_name,OBJPROP_HIDDEN,false);         // オブジェクトリスト表示設定
  ObjectSetInteger(chart_id,obj_name,OBJPROP_ZORDER,0);     // オブジェクトのチャートクリックイベント優先順位
  ObjectSetInteger(chart_id,obj_name,OBJPROP_RAY_RIGHT,false);      // ラインの延長線(右)
  //ObjectSetInteger(chart_id,obj_name,OBJPROP_FILL,true);          // 埋め(塗りつぶし)設定
  //ChartRedraw(NULL);
}
//+------------------------------------------------------------------+
void OnTimer()
{
  display_vola_bar();

  //draw_remaining_time();
}
//+------------------------------------------------------------------+

//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
  //display_vola_bar();
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//+-------------------------------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
  if(id == CHARTEVENT_CHART_CHANGE){
    int wHandle = SendMessageW(ParentWinHandle,WM_MDIGETACTIVE,0,0);
    //Print ("main ce cli wHandle "+wHandle);
    if(wHandle != ThisWinHandle){
      // if not activated
      return;
    }else{
      chart_height=ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
      chart_width=ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
    }
  }
}
//++//


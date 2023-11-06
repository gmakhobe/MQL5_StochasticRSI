//+------------------------------------------------------------------+
//|                                                StochasticRSI.mq5 |
//|                                                           GivenM |
//|                   https://github.com/gmakhobe/MQL5_StochasticRSI |
//+------------------------------------------------------------------+
#property copyright "GivenM"
#property link      "https://github.com/gmakhobe/MQL5_StochasticRSI"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//---- plot TSI
#property indicator_label1  "StochasticRSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrYellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input int               lookBack=14;
input ENUM_TIMEFRAMES   TimeFrame=PERIOD_CURRENT;
//--- indicator buffers
double         StochasticRSIBuffer[];
double         RSIBuffer[];
//-- RSI Variables
int            RSIHandler;
//-- Import Files
#include <MyLibrary.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,StochasticRSIBuffer,INDICATOR_DATA);
   SetIndexBuffer(1, RSIBuffer, INDICATOR_CALCULATIONS);

   RSIHandler = iRSI(Symbol(), TimeFrame, lookBack, PRICE_CLOSE);

   if(RSIHandler == INVALID_HANDLE)
     {
      return INIT_FAILED;
     }

//--- bar, starting from which the indicator is drawn
//PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,lookBack-1);
   string shortname;
   StringConcatenate(shortname,"stochasticRSI(",lookBack,")");
//--- set a label do display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//--- set a name to show in a separate sub-window or a pop-up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- set accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,2);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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

   if(prev_calculated==0)
     {
      //--- set zero values to zero indexes
      StochasticRSIBuffer[0] = 0.0;
     }

   if(!CopyBuffer(RSIHandler, 0, 0, rates_total, RSIBuffer))
     {
      return rates_total;
     }

//--- calculate values of mtm and |mtm|
   int start;

   if(prev_calculated == 0)
     {
      start = 1;  // start filling from the 1st index
     }
   else
     {
      start = prev_calculated - 1;    // set start equal to the last index in the arrays
     }

   for(int i = start; i < rates_total; i++)
     {
      double tempArray[];

      if(i < lookBack + 1)
        {
         StochasticRSIBuffer[i] = 0;
         continue;
        }

      arraySlice(RSIBuffer, tempArray, i - lookBack, i);

      double minRSIValue = arrayMathMinValue(tempArray);
      double maxRSIValue = arrayMathMaxValue(tempArray);

      double stochastiRSIValue = ((RSIBuffer[i] - minRSIValue) / (maxRSIValue - minRSIValue)) * 100;

      if(stochastiRSIValue > 100)
        {
         StochasticRSIBuffer[i] = 100;
        }

      if(stochastiRSIValue < 0)
        {
         StochasticRSIBuffer[i] = 0;
        }
      if (stochastiRSIValue <= 100 && stochastiRSIValue > 0)
        {
         StochasticRSIBuffer[i] = stochastiRSIValue;
        }

     }

   return(rates_total);
  }
//+------------------------------------------------------------------+

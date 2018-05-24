
#ifndef WP_TRADE_ICE
#define WP_TRADE_ICE

module WpQuoteServer
{
	//日K线行情结构 20180416 wuhaining
	struct DayKLineCodeInfo
  {
  	string sCode;
  	string sDate;
  	string sOpenPrice;
  	string sLastPrice;
  	string sHighPrice;
  	string sLowPrice;
  	string sPreSettlementPrice;
    string sVolume;
    string sOi;
    string sSettlementPrice;
    string sExchangeID;
  };
  ["clr:generic:List"] sequence<DayKLineCodeInfo> DayKLineList;

	interface CallbackReceiver
	{
		void SendMsg(int itype, string strMessage);
	};
	interface ClientApi
	{
		int Login(string strCmdType, string strCmd, out string strOut, out string strErrInfo);
		int Logout(string strCmdType, string strCmd, out string strOut, out string strErrInfo);
		int SubscribeQuote(string strCmdType, string strCmd, out string strOut, out string strErrInfo);
		int UnSubscribeQuote(string strCmdType, string strCmd, out string strOut, out string strErrInfo);
		int	HeartBeat(string strCmdType, string strCmd, out string strOut, out string strErrInfo);
		int SendCmd(string strCmdType, string strCmd, out string strOut, out string strErrInfo);
		// 客户端获取历史K线行情 20180416 wuhaining
		int GetKLine(string strCmdType, string strCmd, out string strOut, out string strErrInfo);
		// 获取历史日K线数据
		int GetDayKLine(string sExchangeID, out DayKLineList DKLL, out string strErrInfo);
		void initiateCallback(string strFundAcc, CallbackReceiver* proxy);//主推时初始化
	};

};

#endif

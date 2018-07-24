
#ifndef AUTO_TRADE_ICE
#define AUTO_TRADE_ICE

module AutoTradeCtp
{
	interface CallbackReceiver
	{
		void SendMsg(int itype, string strMessage);
	};
	interface ClientApi
	{
		int Login(string strCmdType, string strCmd, out string strOut, out string strErrInfo);
		int Logout(string strCmdType, string strCmd, out string strOut, out string strErrInfo);
		int SendOrder(string strCmdType, string strCmd, out string strOut, out string strErrInfo);
		int QueryOrder(string strCmdType, string strCmd, out string strOut, out string strErrInfo);
		int ClearOrder(string strCmdType, string strCmd, out string strOut, out string strErrInfo);
		int QueryFund(string strCmdType, string strCmd, out string strOut, out string strErrInfo);
		int QueryCode(string strCmdType, string strCmd, out string strOut, out string strErrInfo);
		int	HeartBeat(string strCmdType, string strCmd, out string strOut, out string strErrInfo);

		//主推回报时初始化
		void initiateCallback(string strFundAcc, CallbackReceiver* proxy);
	};

	interface QuoteApi
	{
		int	HeartBeat(string strCmdType, string strCmd, out string strOut, out string strErrInfo);
		int	ServerManage(string strCmdType, string strCmd, out string strOut, out string strErrInfo);
		int OnPrice(string strCode, double dLastPrice, double dBuyPrice, int iBuyAmount, double dSellPrice, int iSellAmount, double dUpPrice, double dDownPrice, string strCmd, out string strErrInfo);
	};
};

#endif //AUTO_TRADE_ICE


#ifndef WP_TRADE_ICE
#define WP_TRADE_ICE

module WpTradeAPIServer
{
	["clr:generic:List"] sequence<string> STRLIST;
	
	interface CallbackReceiver
	{
		void SendMsg(string stype, string strMessage);
	};
	interface ClientApi
	{
		int Login(string strCmdType, string strCmd, out string strOut, out string strErrInfo);
		int Logout(string strCmdType, string strCmd, out string strOut, out string strErrInfo);
		int QueryOrder(string strCmdType, string strCmd, out STRLIST ListEntrust, out string strOut, out string strErrInfo);
		int QueryFund(string strCmdType, string strCmd, out STRLIST ListFund, out string strOut, out string strErrInfo);
		int QueryHold(string strCmdType, string strCmd, out STRLIST ListHold, out string strOut, out string strErrInfo);
		int QueryBusi(string strCmdType, string strCmd, out STRLIST ListBusi, out string strOut, out string strErrInfo);
		int	SendOrder(string strCmdType, string strCmd, out string strOut, out string strErrInfo);
		int	CancelOrder(string strCmdType, string strCmd, out string strOut, out string strErrInfo);
		int	SendCmd(string strCmdType, string strCmd, out string strOut, out string strErrInfo);//其它指令
		int	SendCmd2(string strCmdType, string strCmd, out STRLIST ListOut, out string strOut, out string strErrInfo);//其它指令
		
		int	HeartBeat(string strCmdType, string strCmd, out string strOut, out string strErrInfo);
		void initiateCallback(string strFundAcc, CallbackReceiver* proxy);//主推回报时初始化
	};

};

#endif

#ifndef SQLSERVER_ICE
#define SQLSERVER_ICE

module SqlServer
{
    //enum SqlDbType{Integer, Float, String, Char, Boolean};
    enum ParameterDirection{Input, InputOutput, Output, ReturnValue};
    
    struct SqlParameter
    {
    	string strParameterName;
    	//SqlDbType ParameterType;
    	ParameterDirection PD;
    	string strParameterValue;    	
    };
    
    ["clr:generic:List"] sequence<SqlParameter> SQLPARAMETERSEQUENCE;
    //sequence<SqlParameter> SQLPARAMETERSEQUENCE;
    
    interface Publisher
    {    
        int ExecProc(string StoredProcName, SQLPARAMETERSEQUENCE SQLPQS, out string strErrInfo, out string XMLSqlData);        
        void HeartBeat();
    };
};

#endif
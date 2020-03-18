public without sharing class LoginHistoryInstance {

	//[Select Status, SourceIp, LoginTime, Id, Platform, Browser From LoginHistory Where UserId =: Userinfo.getUserId()];
	public String Status {get; set;}
	public String SourceIp {get; set;}
	public String Platform {get; set;}
	public String Browser {get; set;}
	public DateTime LoginTime {get; set;}


	public LoginHistoryInstance() {

	}

}

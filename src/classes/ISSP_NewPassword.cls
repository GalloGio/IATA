public with sharing class ISSP_NewPassword {

	 public string userId{get;set;}

	 public string getpassword(){
		if(ISSP_Registration.password!='')
		return ISSP_Registration.password;
		else return ISSP_Registration.passwordMap.get(userId);
	}
}

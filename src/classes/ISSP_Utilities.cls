public without sharing class ISSP_Utilities {

	public virtual class  ApplicationException extends Exception {
	} 
	 
	 @Future
	 public static void SendErrorNotificationEMail(String EmailBody){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(Label.ISSP_EmailsFailure.split(';'));
        String Subject = 'ISSP Error!';
        mail.setSubject(Subject);
		mail.setPlainTextBody(EmailBody);
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
    
    @Future
    public static void sendEmailToAdmins(string ConId){
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(Label.ISSP_EmailsFailure.split(';'));
        String Subject = 'ISSP Error!';
        mail.setSubject(Subject);
		mail.setPlainTextBody('Test');
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
    
    @future 
    public static void DMLOpt(set<string> casesIds){
		List<Case> cases = [select id from Case where id IN :casesIds];
	    if(cases!=null && cases.size()>0){
	      Database.DMLOptions dmo = new Database.DMLOptions();
	      dmo.assignmentRuleHeader.useDefaultRule = true;
	      for(Case cs : cases){
	        //dmo.emailHeader.triggerUserEmail = true;
	        cs.setOptions(dmo);
	      }
	      update cases;
	    }
	}
    
    public static string getContactTypeById(string conId){
    	Contact con = [select Id, Account.RecordType.DeveloperName, Account.Sector__c, Account.Category__c from Contact where Id =:conId];
    	string userType = ISSP_Constant.userTypeByAccountRtDeveloperNameMap.get(con.Account.RecordType.DeveloperName);
    	if(userType!=null){
    		return userType;
    	}
    	else{
    		userType = ISSP_Constant.accountSectorType.get(con.Account.Sector__c);
    		if(userType!=null){
				return userType;
			}
    		userType = ISSP_Constant.accountCategoryType.get(con.Account.Category__c);
    		if(userType!=null){
				return userType;
			}
    	}
    	return 'Other';
    }

	public static void log(Object obj) {
		system.debug('\n\n\n' + obj + '\n\n\n');
	}
	//AEF:
	public static String buildPortalUserName(String email) {
		String sufix = '@partner.iata.org';
		String portalUserName = String.isNotBlank(email) ? email : '';   
		if(String.isNotBlank(email) && !portalUserName.contains(sufix))
			portalUserName = portalUserName.replace('@', '.') + sufix;
		
			
		return portalUserName;  
	}
	
	public static Boolean isEmpty(list<object> oneList) {
		return null == oneList || oneList.isEmpty();
	}
	
	public static Boolean isNotEmpty(list<object> oneList) {
		return !isEmpty(oneList);
	}
	
	public static String exceptionTrace(Exception exp) {
		return exp.getStackTraceString() + '\n' + exp.getMessage() + '\n' + exp.getTypeName();
	}
	
	public static String exceptionDump(Exception exp) {
		String msg = '\n'+exceptionTrace(exp);
		system.debug(system.LoggingLevel.ERROR, msg);
		return msg;
	}
	
	public static void addErrorMessage(Exception exp) {
		exceptionDump(exp);
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, exp.getMessage()));
	}

	public static Boolean isNumeric(String value) {
		return Pattern.matches('^[-+]?[0-9]*\\.?[0-9]+$', value);
	}

	public static Boolean isCNS() {
		User u = [
			SELECT Id, Contact.Account.CNS_Agency__c, Contact.Account.CNS_Account__c, Contact.Account.RecordType.DeveloperName, Contact.Account.IATA_ISO_Country__r.CNS_Country__c,Contact.Account.Sector__c
			FROM User WHERE Id =:UserInfo.getUserId()];
		Boolean isCNS = false;

		if(u.Contact.Account.CNS_Account__c && u.Contact.Account.IATA_ISO_Country__r.CNS_Country__c &&
			((u.Contact.Account.RecordType.DeveloperName == 'IATA_Agency' && u.Contact.Account.CNS_Agency__c ) ||
			(u.Contact.Account.RecordType.DeveloperName == 'Standard_Account' && u.Contact.Account.Sector__c == 'Cargo Agent'))) {
				isCNS = true;
		}

		return isCNS;

      }

	public static boolean isIFGUser(){

		boolean isIFG = false;
		User u = DAL_ISSP.getUser(UserInfo.getUserId());

		if((u.contact.IFG_Production__c != null && u.contact.IFG_Production__c>0 )||
				(u.contact.IFG_PreProduction__c != null && u.contact.IFG_PreProduction__c>0 )
		){
			isIFG = true;
			System.debug('basto1p - IS IFG USER');
		}

		return isIFG;

	}
}

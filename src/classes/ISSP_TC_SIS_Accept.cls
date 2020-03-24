public without sharing class ISSP_TC_SIS_Accept {

	public boolean accept {get; set;}
	public list<String> errorMessage {get; set;}

	public ISSP_TC_SIS_Accept(){

	}

	public PageReference pageLoad(){
		errorMessage = new list<string>();
		//check if user has access to SIS service
		PageReference pr = new PageReference('/ISSP_Homepage');
		String userId = UserInfo.getUserId();
		if (userId != null && userId != ''){
			List <User> userList = [SELECT Id, ContactId FROM User WHERE Id = :userId];
			if(!userList.isEmpty()){
				String contactId = userList[0].ContactId;
				if (contactId != null && contactId != ''){
					List <Portal_Application_Right__c> appList =
											[SELECT Id FROM Portal_Application_Right__c
											WHERE Portal_Application__r.Name = 'SIS'
											AND Right__c = 'Access Granted'
											AND Contact__c = :contactId];
					if (appList.isEmpty()){
						return pr;
					}
					else{
						List <Contact> contactList = [SELECT Id, AccountId, Account.Top_Parent__c FROM Contact WHERE Id = :contactId];
						if (!contactList.isEmpty()){
							string topParentId = contactList[0].Account.Top_Parent__c==null?contactList[0].AccountId:contactList[0].Account.Top_Parent__c;
							List <Account> accountList = [SELECT Id, ISS_SIS_TC_Accepted__c, ISS_SIS_TC_Accepted_Date__c,
													ISS_SIS_TC_Accepted_User__c, Sector__c
													FROM Account WHERE Id = :topParentId];
							if (!accountList.isEmpty()){
								if (accountList[0].ISS_SIS_TC_Accepted__c || (accountList[0].Sector__c != 'Travel Agent' && accountList[0].Sector__c != 'Cargo Agent')){
									String theURL = String.valueOf(ISSP_CS__c.getInstance('SIS_URL').Value__c);
									pr = new PageReference(theURL);
									pr.setRedirect(true);
									return pr;
								}
								else{
									return null;
								}
							}
						}
					}
				}
			}
		}
		return pr;
	}

	public PageReference docontinue(){
		if(!accept){
			system.debug('not accept');
			errorMessage = new list<string>();
			errorMessage.add(Label.ISSP_accept_General_Conditions);
			return null;
		}
		else{
			system.debug('user id:' + UserInfo.getUserId());
			List <User> userList = [SELECT Id, ContactId FROM User WHERE Id =:UserInfo.getUserId()];
			system.debug('userList:' + userList);
			if (!userList.isEmpty()){
				String contactId = userList[0].ContactId;
				system.debug('contactId: ' + contactId);
				if (contactId != null && contactId != ''){
					List <Contact> contactList = [SELECT Id, AccountId, Account.Top_Parent__c FROM Contact WHERE Id = :contactId];
					if (!contactList.isEmpty()){
						string topParentId = contactList[0].Account.Top_Parent__c==null?contactList[0].AccountId:contactList[0].Account.Top_Parent__c;
						system.debug('topParentId: ' + topParentId);
						List <Account> accountList = [SELECT Id, ISS_SIS_TC_Accepted__c, ISS_SIS_TC_Accepted_Date__c,
												ISS_SIS_TC_Accepted_User__c
												FROM Account WHERE Id = :topParentId];
						if (!accountList.isEmpty()){
							system.debug('ISS_SIS_TC_Accepted__c: ' + accountList[0].ISS_SIS_TC_Accepted__c);
							if (!accountList[0].ISS_SIS_TC_Accepted__c){
								accountList[0].ISS_SIS_TC_Accepted__c = true;
								accountList[0].ISS_SIS_TC_Accepted_Date__c = system.now();
								accountList[0].ISS_SIS_TC_Accepted_User__c = UserInfo.getUserId();
								update accountList[0];
								String theURL2 = String.valueOf(ISSP_CS__c.getInstance('SIS_URL').Value__c);
								PageReference pr2 = new PageReference(theURL2);
								pr2.setRedirect(true);
								return pr2;
							}
						}
					}
				}
			}
			PageReference pr = new PageReference('/ISSP_Homepage');
			pr.setRedirect(true);
			return pr;
		}
	}

}

public without sharing class ISSP_WS_Utilities {

    public static Portal_Application_Right__c createApp(Id appId, Id contactId){
    	Portal_Application_Right__c appRight = new Portal_Application_Right__c();
		appRight.Portal_Application__c = appId;
		appRight.Contact__c = contactId;
		appRight.Right__c = 'Access Granted';
		return appRight;
    }

    public static Contact createContact(String firstName, String lastName, String email, String accountId, Boolean isCNS){
    	Contact con = new Contact();
		con.User_Portal_Status__c = ISSP_Constant.APPROVED_CONTACT_STATUS;
		con.FirstName = firstName;
		con.LastName = lastName;
		con.Email = email;
		con.AccountId = accountId;
		con.RecordTypeId = ISSP_Constant.Standard_Contact_Record_Type;
		con.Community__c = 'ISS Customer Portal';
        if(isCNS) {
            con.CNS_Contact__c = true;
            con.Community__c = 'CNS Customer Portal';
        }else{
        	con.Community__c = 'ISS Customer Portal';
        }
		return con;
    }

    public static User createUser(String firstName, String lastName, String email, String accountType, String contactId, Boolean isCNS){
    	User u = new User();
        u.Username = ISSP_Utilities.buildPortalUserName(email);
        u.Email = email;
        u.FirstName = firstName;
        u.LastName = lastName;
        if(isCNS){
		u.Community__c = 'CNS';
        }else{
        u.Community__c = 'ISSP';
        }
        if (lastName.length() > 3)
            u.CommunityNickname = lastName.substring(0,3)+Datetime.now().formatLong();
        else
            u.CommunityNickname = lastName+Datetime.now().formatLong();
        String profileName = ISSP_Constant.profilNameByUserTypeMap.get('User').get('OtherCompany');
        if (ISSP_Constant.userTypeByAccountRtDeveloperNameMap.containsKey(accountType)){
        	profileName = ISSP_Constant.profilNameByUserTypeMap.get('User').get(ISSP_Constant.userTypeByAccountRtDeveloperNameMap.get(accountType));
        }
        String profileId = ISSP_Constant.profileIdByProfileNameMap.get(profileName);
        u.ProfileId = profileId;
        u.IsActive = true;
        //u.IsPortalEnabled = true;
        u.alias = createAlias(firstName, lastName);
        u.emailencodingkey = 'UTF-8';
        u.languagelocalekey = 'en_US';
        u.localesidkey = 'en_US';
        u.contactId = contactId;
        u.timezonesidkey = 'Asia/Dubai';
        u.UID__c = Comm_User_Helper.NewGuid();
        return u;
    }

    public static void sendUserEmail(User newUser, Contact con){
    	String password = Comm_User_Helper.generateRandomString(6)+'1a';
        System.setPassword(newUser.Id, password);
        String cleanUsername = ISSP_Utilities.buildPortalUserName(con.email);
        cleanUsername = cleanUsername.replace('+', Comm_User_Helper.plusReplacer);
        string encodedPart = EncodingUtil.urlEncode(Comm_User_Helper.EncryptString(cleanUsername+Comm_User_Helper.SEPARATOR+password+Comm_User_Helper.SEPARATOR+newUser.UID__c), 'UTF-8');
        String link = 'https://' + String.ValueOF(ISSP_CS__c.getValues('Host').value__c)+ '/ISSP_First_Login?c='+encodedPart;
    	String template = 'ISSP_New_Member_Welcome_Email_2';
		Map<String,String> emailWrap = Comm_User_Helper.ISSP_PassWordBuilMessageWrapper( con ,  password ,  link, 'ISSP');
		Comm_User_Helper.sendEmail( template ,emailWrap, con, 'ISSP');
		Comm_User_Helper.permissionASS(new list<Id>{newUser.Id});
    }

    public static String createAlias(String pFirstName, String pLastName) {
        if(pFirstName==null)
            pFirstName='-';
        if(pLastName==null)
            pLastName='';

        if (pLastName.length() > 7)
            return pLastName.substring(0, 7) + pFirstName.substring(0,1);
        else
            return pLastName + pFirstName.substring(0,1);
    }

    @Future(callout=true)
	public static void invokeAsdDisableUser(String contactId){
		ISSP_WS_ASD_DeactivateUser.AsdIssPortalServicePort ws = new ISSP_WS_ASD_DeactivateUser.AsdIssPortalServicePort();
    	ISSP_WS_ASD_DeactivateUser.disablePortalUserResult res = ws.disablePortalUser(contactId);
    	system.debug('webservice result: ' + res);
    }

    @Future(callout=true)
	public static void invokeSisModifyUser(Map<Id, String> sisFedIdMap, Map<Id, String> sisEmailMap, Map<Id, String> sisFirstNameMap, Map<Id, String> sisLastNameMap){
		String fullMessage;
		List <ISSP_Web_Service_Log__c> logList = new List <ISSP_Web_Service_Log__c>();
		Boolean isSandbox = [select Id, IsSandbox from Organization limit 1].IsSandbox;
		for (Id thisId : sisFedIdMap.keySet()){
			ISSP_Web_Service_Log__c newLog = new ISSP_Web_Service_Log__c();
			newLog.Web_Service__c = 'UpdateSisUser_Outbound';
			newLog.Method__c = 'UpdateSisUser';
			newLog.System__c = 'SIS';
			fullMessage = '<IcpRequestMessage>';
			if (isSandbox){
				system.debug('THIS IS SANDBOX');
				fullMessage += '<IcpUserName>ICPUser_UAT</IcpUserName>';
	        	fullMessage += '<IcpPassword>IcpPass#UAT</IcpPassword>';
			}
			else{
				system.debug('THIS IS PROD');
				fullMessage += '<IcpUserName>ICPUser_S1SProd</IcpUserName>';
	        	fullMessage += '<IcpPassword>IcpPass#S1SProd</IcpPassword>';
			}
	        fullMessage += '<FederationID>'+sisFedIdMap.get(thisId)+'</FederationID>';
	        fullMessage += '<FirstName>'+sisFirstNameMap.get(thisId)+'</FirstName>';
	        fullMessage += '<LastName>'+sisLastNameMap.get(thisId)+' </LastName>';
	        fullMessage += '<EmailAddress>'+sisEmailMap.get(thisId)+'</EmailAddress>';
	        fullMessage += '</IcpRequestMessage>';
	        system.debug('fullMessage: ' + fullMessage);
	        newLog.Input_Description__c = fullMessage;
			ISSP_WS_SIS_ModifyUser.IcpWsInterfaceSoap ws = new ISSP_WS_SIS_ModifyUser.IcpWsInterfaceSoap();
	    	String res = ws.UpdateSisUser(fullMessage, isSandbox);
	    	system.debug('webservice result: ' + res);

	    	String isSuccess = 'false';
	    	if (res.contains('<IsSuccess>')){
	    		isSuccess = res.split('<IsSuccess>')[1];
	    		isSuccess = isSuccess.split('</IsSuccess>')[0];
	    	}
	    	system.debug('isSuccess: ' + isSuccess);

	    	String errorCode = '';
	    	if (res.contains('<ErrorCode>')){
	    		errorCode = res.split('<ErrorCode>')[1];
	    		errorCode = errorCode.split('</ErrorCode>')[0];
	    	}
	    	system.debug('errorCode: ' + errorCode);

	    	String errorMsg = '';
	    	if (res.contains('<ErrorDescription>')){
	    		errorMsg = res.split('<ErrorDescription>')[1];
	    		errorMsg = errorMsg.split('</ErrorDescription>')[0];
	    	}
	    	system.debug('errorMsg: ' + errorMsg);

	    	if (isSuccess == 'false'){
	    		newLog.Success__c = false;
	    	}
	    	else{
	    		newLog.Success__c = true;
	    	}
	    	newLog.Error_Code__c = errorCode.left(255);
	    	newLog.Error_Message__c = errorMsg.left(255);
	    	newLog.Finished__c = system.now();
	    	logList.add(newLog);
		}
		system.debug('logList: ' + logList);
		if (!logList.isEmpty()){
			system.debug('insert logList');
			insert logList;
		}
    }
}

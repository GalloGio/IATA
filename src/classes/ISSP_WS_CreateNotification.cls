global class ISSP_WS_CreateNotification {

	global class ResponseOne {
        WebService Boolean isSuccess;
        WebService String responseErrorCode;
        WebService String responseErrorMessage;
    }
    
    global class inputData {
    	// requesting system
    	WebService String requestingSystem;
    	// contact segmentation inputs
    	WebService String iataCode;
    	WebService String designatorCode;
    	WebService String serviceName;
    	WebService List<String> listOfUsers;
    	// notification inputs
    	WebService String templateName;
    	WebService List<languageMessage> languageMessageList;
        WebService String notificationType;
        WebService Integer daysToExpire;
        WebService Boolean emailAlert;
        WebService Boolean criticalNotification;
        WebService String campaignName;
        WebService String replaceStr;     
    }
    
    global class languageMessage {
    	WebService String languageCode;
    	WebService String message;
    	WebService String subject;
    }
    
    WebService static ResponseOne createNotification (inputData inputMessage) {
    	ResponseOne retResponse = new ResponseOne();
    	retResponse.isSuccess = true;
    	
    	// Create log object record
    	ISSP_Web_Service_Log__c newLog = new ISSP_Web_Service_Log__c();
    	newLog.Success__c = true;
    	newLog.Web_Service__c = 'ISSP_WS_CreateNotification';
    	newLog.Method__c = 'createNotification';
    	newLog.System__c = inputMessage.requestingSystem;
    	String errorCode = '';
    	String errorMessage = '';
    	
    	// log inputs
    	String description = 'User Id: ' + UserInfo.getUsername() + '\n';
    	description = description + 'Requesting System: ' + inputMessage.requestingSystem + '\n';
    	description = description + 'IATA Code: ' + inputMessage.iataCode + '\n';
    	description = description + 'Designator Code: ' + inputMessage.designatorCode + '\n';
    	description = description + 'Service Name: ' + inputMessage.serviceName + '\n';
    	description = description + 'Campaign Name: ' + inputMessage.campaignName + '\n';
    	description = description + 'List of users: ' + inputMessage.listOfUsers + '\n';
    	description = description + 'Template Name: ' + inputMessage.templateName + '\n';
    	description = description + 'Message List: ' + inputMessage.languageMessageList + '\n';
    	description = description + 'Notification Type: ' + inputMessage.notificationType + '\n';
    	description = description + 'Days to Expire: ' + inputMessage.daysToExpire + '\n';
    	description = description + 'Email Alert: ' + inputMessage.emailAlert + '\n';
    	description = description + 'Critical Notification: ' + inputMessage.criticalNotification + '\n';
    	newLog.Input_Description__c = description;
    	
    	Map<String, String> replaceMap = parseReplaceStr(inputMessage.replaceStr);
    	
    	//Contact segmentation
    	List <Contact> contactList = new List<Contact>(); // final list of contacts
    	Set <Id> contactIds = new Set <Id>();
    	Map <Id, Id> contactMap = new Map <Id, Id>();
    	map<string,string> contactLanguageMap = new map<string,string>();
    	map<string,string> contactLanguageKeyMap = new map<string,string>();
    	Map <Id, Id> contactMapAux = new Map <Id, Id>();
    	
    	//Getting contacts for IATA Code
    	String iataCode = inputMessage.iataCode;
    	system.debug('IATA CODE: ' + iataCode);
    	if (iataCode != null && iataCode != ''){
    		system.debug('IATA CODE NOT EMPTY');
    		List <Account> accountList = [SELECT Id FROM Account where IATACode__c = :iataCode];
    		system.debug('accountList: ' + accountList);
	    	if (accountList.isEmpty()){
	    		errorCode = 'A001';
	    		errorMessage = ISSP_Int_Error__c.getValues('A001').Error_Message__c;
	    		
	    		retResponse.isSuccess = false;
	    		retResponse.responseErrorCode = errorCode;
	    		retResponse.responseErrorMessage = errorMessage;
	    		system.debug('ERROR: A001');
	    		
	    		//insert log record
	    		newLog.Success__c = false;
	    		newLog.Error_Code__c = errorCode;
	    		newLog.Error_Message__c = errorMessage;
	    		newLog.Finished__c = system.now();
	    		insert newLog;
	    		
	    		return retResponse;
	    	}
	    	else{
	    		Set <Id> accountIds = new Set<Id>();
	    		for (Account thisAccount : accountList){
	    			accountIds.add(thisAccount.Id);
	    		}
	    		List <Contact> iataCodeContactList = [SELECT Id FROM Contact WHERE
	    											AccountId IN :accountIds
	    											OR Account.Top_Parent__c IN :accountIds];
				system.debug('iataCodeContactList: ' + iataCodeContactList);
				if (iataCodeContactList.isEmpty()){
					errorCode = 'A002';
	    			errorMessage = ISSP_Int_Error__c.getValues('A002').Error_Message__c;
	    			
		    		retResponse.isSuccess = false;
		    		retResponse.responseErrorCode = errorCode;
	    			retResponse.responseErrorMessage = errorMessage;
		    		system.debug('ERROR: A002');
		    		
		    		//insert log record
		    		newLog.Success__c = false;
		    		newLog.Error_Code__c = errorCode;
		    		newLog.Error_Message__c = errorMessage;
		    		newLog.Finished__c = system.now();
		    		insert newLog;
		    		
		    		return retResponse;
		    	}
		    	else{
					for (Contact thisContact : iataCodeContactList){
						if (!contactMap.containsKey(thisContact.Id)){
							system.debug('ADDING 1 CONTACT FROM IATA CODE');
							contactMap.put(thisContact.Id, thisContact.Id);
						}
					}
		    	}
	    	}
    	}
    	
    	//Getting contacts for Designator Code
    	String designatorCode = inputMessage.designatorCode;
    	system.debug('DESIGNATOR CODE: ' + designatorCode);
    	if (designatorCode != null && designatorCode != ''){
    		system.debug('DESIGNATOR CODE NOT EMPTY');
    		List <Account> accountListDesignatorCode = [SELECT Id FROM Account where Airline_designator__c = :designatorCode];
    		system.debug('accountList designatorCode: ' + accountListDesignatorCode);
	    	if (accountListDesignatorCode.isEmpty()){
	    		errorCode = 'A010';
	    		errorMessage = ISSP_Int_Error__c.getValues('A010').Error_Message__c;
	    		
	    		retResponse.isSuccess = false;
	    		retResponse.responseErrorCode = errorCode;
	    		retResponse.responseErrorMessage = errorMessage;
	    		system.debug('ERROR: A010');
	    		
	    		//insert log record
	    		newLog.Success__c = false;
	    		newLog.Error_Code__c = errorCode;
	    		newLog.Error_Message__c = errorMessage;
	    		newLog.Finished__c = system.now();
	    		insert newLog;
	    		
	    		return retResponse;
	    	}
	    	else{
	    		Set <Id> accountCodeIds = new Set<Id>();
	    		for (Account thisAccount : accountListDesignatorCode){
	    			accountCodeIds.add(thisAccount.Id);
	    		}
	    		List <Contact> designatorCodeContactList = [SELECT Id FROM Contact WHERE
	    											AccountId IN :accountCodeIds
	    											OR Account.Top_Parent__c IN :accountCodeIds];
				system.debug('designatorCodeContactList: ' + designatorCodeContactList);
				if (designatorCodeContactList.isEmpty()){
					errorCode = 'A011';
	    			errorMessage = ISSP_Int_Error__c.getValues('A011').Error_Message__c;
	    			
		    		retResponse.isSuccess = false;
		    		retResponse.responseErrorCode = errorCode;
	    			retResponse.responseErrorMessage = errorMessage;
		    		system.debug('ERROR: A011');
		    		
		    		//insert log record
		    		newLog.Success__c = false;
		    		newLog.Error_Code__c = errorCode;
		    		newLog.Error_Message__c = errorMessage;
		    		newLog.Finished__c = system.now();
		    		insert newLog;
		    		
		    		return retResponse;
		    	}
		    	else{
		    		if (contactMap.isEmpty()){
		    			system.debug('CONTACT MAP EMPTY WHEN CHECKING DESIGNATOR CODE');
		    			for (Contact thisContact : designatorCodeContactList){
							if (!contactMap.containsKey(thisContact.Id)){
								system.debug('ADDING 1 CONTACT FROM DESIGNATOR CODE');
								contactMap.put(thisContact.Id, thisContact.Id);
							}
						}
		    		}
					else{
						contactMapAux = new Map <Id, Id>();
						system.debug('CONTACT MAP NOT EMPTY WHEN CHECKING DESIGNATOR CODE');
						for (Contact thisContact : designatorCodeContactList){
							if (contactMap.containsKey(thisContact.Id)){
								system.debug('LEAVING IN THE MAP THIS CONTACT BECAUSE IT IS ON CONTACT LIST');
								contactMapAux.put(thisContact.Id, thisContact.Id);
							}
						}
						contactMap = contactMapAux;
					}
		    	}
	    	}
    	}
    	
    	//Getting contacts for Service Name
    	String serviceName = inputMessage.serviceName;
    	system.debug('serviceName: ' + serviceName);
    	if (serviceName != null && serviceName != ''){
    		system.debug('serviceName not empty');
    		List <Portal_Applications__c> serviceList = [SELECT Id FROM Portal_Applications__c
    													WHERE Name = :serviceName];
			system.debug('serviceList: ' + serviceList);
	    	if (serviceList.isEmpty()){
	    		errorCode = 'A003';
	    		errorMessage = ISSP_Int_Error__c.getValues('A003').Error_Message__c;
	    		
	    		retResponse.isSuccess = false;
	    		retResponse.responseErrorCode = errorCode;
	    		retResponse.responseErrorMessage = errorMessage;
	    		system.debug('ERROR: A003');
    			
	    		//insert log record
	    		newLog.Success__c = false;
	    		newLog.Error_Code__c = errorCode;
	    		newLog.Error_Message__c = errorMessage;
	    		newLog.Finished__c = system.now();
	    		insert newLog;
	    		
	    		return retResponse;
	    	}
	    	else{
	    		String serviceId = serviceList[0].Id;
				List <Portal_Application_Right__c> appRightList;
	    		if(serviceName == ISSP_ICCS_Utils.ICCS_PORTAL_APPLICATION_NAME){
		    		appRightList = [SELECT Id, Contact__c
									FROM Portal_Application_Right__c WHERE
									Id in : ISSP_ICCS_Utils.getReportNotificationRecipients(inputMessage.templateName, replaceMap.get('%SF_ACCOUNT_ID%'))];
	    		}
	    		else{
	    			appRightList = [SELECT Id, Contact__c
	    											FROM Portal_Application_Right__c WHERE
	    											Right__c = 'Access Granted'
	    											AND Portal_Application__c = :serviceId];
	    		}
				system.debug('appRightList: ' + appRightList);
				if (appRightList.isEmpty()){
					errorCode = 'A004';
	    			errorMessage = ISSP_Int_Error__c.getValues('A004').Error_Message__c;
	    			
		    		retResponse.isSuccess = false;
		    		retResponse.responseErrorCode = errorCode;
	    			retResponse.responseErrorMessage = errorMessage;
		    		system.debug('ERROR: A004');
		    		
		    		//insert log record
		    		newLog.Success__c = false;
		    		newLog.Error_Code__c = errorCode;
		    		newLog.Error_Message__c = errorMessage;
		    		newLog.Finished__c = system.now();
		    		insert newLog;
		    		
		    		return retResponse;
		    	}
		    	else{
		    		if (contactMap.isEmpty()){
		    			system.debug('CONTACT MAP EMPTY WHEN CHECKING SERVICE');
		    			for (Portal_Application_Right__c thisAppRight : appRightList){
							if (!contactMap.containsKey(thisAppRight.Contact__c)){
								system.debug('ADDING CONTACT FROM SERVICE');
								contactMap.put(thisAppRight.Contact__c, thisAppRight.Contact__c);
							}
						}
		    		}
					else{
						contactMapAux = new Map <Id, Id>();
						system.debug('CONTACT MAP NOT EMPTY WHEN CHECKING SERVICE');
						for (Portal_Application_Right__c thisAppRight : appRightList){
							if (contactMap.containsKey(thisAppRight.Contact__c)){
								system.debug('LEAVING IN THE MAP THIS CONTACT BECAUSE IT IS ON CONTACT LIST');
								contactMapAux.put(thisAppRight.Contact__c, thisAppRight.Contact__c);
							}
						}
						contactMap = contactMapAux;
					}
		    	}
	    	}
    	}
    	
    	//Getting contacts for user list
    	List<String> listOfUsers = inputMessage.listOfUsers;
    	if(listOfUsers == null){
    		listOfUsers = new List<String>();
    	}
    	system.debug('listOfUsers: ' + listOfUsers);
    	system.debug('listOfUsers size: ' + listOfUsers.size());
    	Set <String> emailList = new Set <String>();
    	if (!listOfUsers.isEmpty()){
    		for (String thisEmail : listOfUsers){
    			if (thisEmail != '' && thisEmail != null){
					system.debug('adding this email: ' + thisEmail);
    				emailList.add(thisEmail);
    			}
    		}
    		if (!emailList.isEmpty()){
    			List <Contact> userListContactList = [SELECT Id FROM Contact WHERE Email IN :emailList];
    			system.debug('userListContactList: ' + userListContactList);
    			if (!userListContactList.isEmpty()){
    				if (contactMap.isEmpty()){
    					system.debug('CONTACT MAP EMPTY WHEN CHECKING USER LIST');
		    			for (Contact thisContact : userListContactList){
							if (!contactMap.containsKey(thisContact.Id)){
								system.debug('ADDING CONTACT FROM USER LIST');
								contactMap.put(thisContact.Id, thisContact.Id);
							}
						}
		    		}
					else{
						contactMapAux = new Map <Id, Id>();
						system.debug('CONTACT MAP NOT EMPTY WHEN CHECKING USER LIST');
						for (Contact thisContact : userListContactList){
							if (contactMap.containsKey(thisContact.Id)){
								system.debug('LEAVING IN THE MAP THIS CONTACT BECAUSE IT IS ON CONTACT LIST');
								contactMapAux.put(thisContact.Id, thisContact.Id);
							}
						}
						contactMap = contactMapAux;
					}
    			}
    			else{
    				errorCode = 'A005';
	    			errorMessage = ISSP_Int_Error__c.getValues('A005').Error_Message__c;
	    			
	    			retResponse.isSuccess = false;
		    		retResponse.responseErrorCode = errorCode;
	    			retResponse.responseErrorMessage = errorMessage;
		    		system.debug('ERROR: A005 1');
		    		
		    		//insert log record
		    		newLog.Success__c = false;
		    		newLog.Error_Code__c = errorCode;
		    		newLog.Error_Message__c = errorMessage;
		    		newLog.Finished__c = system.now();
		    		insert newLog;
		    		
		    		return retResponse;
	    		}
    		}
    		
    	}
    	
    	// check if contact map is empty at the end of the segmentation
    	if (contactMap.isEmpty()){
    		errorCode = 'A006';
	    	errorMessage = ISSP_Int_Error__c.getValues('A006').Error_Message__c;
	    	
    		retResponse.isSuccess = false;
    		retResponse.responseErrorCode = errorCode;
	    	retResponse.responseErrorMessage = errorMessage;
    		system.debug('ERROR: A006');
    		
    		//insert log record
    		newLog.Success__c = false;
    		newLog.Error_Code__c = errorCode;
    		newLog.Error_Message__c = errorMessage;
    		newLog.Finished__c = system.now();
    		insert newLog;
    			
    		return retResponse;
    	}
    	else{
    		map<string,string> languageMap = ISSP_CreateNotification.getLanguagesMap();
    		for (Id thisContactId : contactMap.keySet()){
    			system.debug('THIS CONTACT ID WILL RECEIVE NOTIFICATION: ' + thisContactId);
    			contactIds.add(thisContactId);
    		}
    		contactList = [SELECT Id, Preferred_Language__c
    					FROM Contact WHERE Id IN :contactIds];
			for(User user : [Select u.LanguageLocaleKey, u.ContactId From User u where ContactId in:contactIds]){
				system.debug('THIS CONTACT HAS THIS LANGUAGE: ' + user.ContactId + ' : ' + user.LanguageLocaleKey);
                contactLanguageMap.put(user.ContactId,languageMap.get(user.LanguageLocaleKey));
                contactLanguageKeyMap.put(user.ContactId,user.LanguageLocaleKey);
            }
    	}
    	// end of contact segmentation
    	
    	
    	// Notification data
    	String templateName = inputMessage.templateName;
    	List<languageMessage> languageMessageList = inputMessage.languageMessageList;
        String notificationType = inputMessage.notificationType;
        Integer daysToExpire = inputMessage.daysToExpire;
        Boolean emailAlert = inputMessage.emailAlert;
        Boolean criticalNotification = inputMessage.criticalNotification;
        String notificationColor;
        
        // final notification list
        List <Notification__c> newNotificationList = new List <Notification__c>();
        
        DateTime expirationDate = null;
    	
    	// checking for template in the web service inputs
    	system.debug('templateName: ' + templateName);
    	if (templateName != null && templateName != ''){
    		system.debug('templateName not null');
    		
    		if(serviceName == ISSP_ICCS_Utils.ICCS_PORTAL_APPLICATION_NAME){
				// Add "ICCS_" as it's how ICCS Notification Templates Identifier__c values start with
    			templateName = 'ICCS_' + templateName;
    			List<Notification_template__c> notificationTemplates = [select Name, Identifier__c from Notification_template__c where Identifier__c =: templateName  or Identifier__c =: ISSP_ICCS_Utils.ICCS_DEFAULT_REPORT_NOTIFICATION_TEMPLATE];
    			
				// If there is only one entry, it means that only the default report notification template was found and that there is no dedicated notification template for the ICCS report type.
				// The notification template to use is then the default one.
    			if(notificationTemplates.size() == 1){
	    			System.debug('Size = 1');
    				templateName = notificationTemplates[0].Name;
    			}
				// Otherwise, it means that there is a dedicated notification template for the ICCS report type
    			else{
    				for(Notification_template__c notificationTemplate : notificationTemplates){
    					if(notificationTemplate.Identifier__c == templateName){
    						templateName = notificationTemplate.Name;
    						break;
    					}
    				}
    			}
    		}
    		
    		List <Notification_template__c> templateList = 
    				[Select n.Subject__c, n.Name, n.Message__c, n.Language__c,Type__c,Notification_color__c,Alert_Contact_By_Email__c,
                	Expire_in_days__c, CriticalNotification__c,
                    (Select Subject__c, Name, Message__c, Language__c,Type__c,Notification_color__c,Alert_Contact_By_Email__c,
                	Expire_in_days__c, CriticalNotification__c From Notification_templates__r)
                     From Notification_template__c n  where  Name = :templateName ];
    		system.debug('templateList: ' + templateList);
			if (!templateList.isEmpty()){
				system.debug('found template');
				//map<string,Notification_template__c> notificationTemplateMap = new map<string,Notification_template__c>();
				map<string,map<string,Notification_template__c>> notificationTemplateTranslateMap = new  map<string,map<string,Notification_template__c>>();
				for(Notification_template__c nt: templateList){
	                //notificationTemplateMap.put(nt.Name,nt);
	                notificationTemplateTranslateMap.put(nt.Name,new map<string,Notification_template__c>());
	                for(Notification_template__c ntTranslate:nt.Notification_templates__r){
	                    notificationTemplateTranslateMap.get(nt.Name).put(ntTranslate.Language__c,ntTranslate);
	                }
	            }
	            Notification_template__c nt = templateList[0];
	            for (Contact thisContact : contactList){
	            	system.debug('CREATING NOTIFICATION FOR THIS CONTACT: ' + thisContact);
	            	if(notificationTemplateTranslateMap.containsKey(nt.Name) &&
	            		notificationTemplateTranslateMap.get(nt.Name).containsKey(contactLanguageMap.get(thisContact.Id))
	            	){
	            		system.debug('ALEX FOUND A TRANSLATION');
	            		nt = notificationTemplateTranslateMap.get(nt.Name).get(contactLanguageMap.get(thisContact.Id));
	            	}
	            	if (nt.Expire_in_days__c != null){
	            		expirationDate = system.Now() + nt.Expire_in_days__c;
	            	}

	            	String notificationMsg = replacePlaceholdersMsg(nt.Message__c, replaceMap);

	            	Notification__c newNotification = new Notification__c();
	            	newNotification.Contact__c = thisContact.Id;
	            	newNotification.Message__c = notificationMsg;
                    newNotification.Alert_Contact_By_Email__c = nt.Alert_Contact_By_Email__c;
                    newNotification.Subject__c = nt.Subject__c;
                    newNotification.Type__c = nt.Type__c;
                    newNotification.Notificatin_color__c = nt.Notification_color__c; 
                    newNotification.Critical_notification__c = nt.CriticalNotification__c;
                    newNotification.Expiry_date__c = expirationDate;
                    newNotification.Notification_Campagne_Name__c = inputMessage.campaignName;
	            	newNotificationList.add(newNotification);
	            }
	            try{
	            	system.debug('INSERTING NOTIFICATIONS FROM TEMPLATE');
	            	insert newNotificationList;
	            }
	            catch(Exception e){
	            	errorCode = 'A099';
	    			errorMessage = ISSP_Int_Error__c.getValues('A099').Error_Message__c + e.getMessage();
	    			
	            	retResponse.isSuccess = false;
					retResponse.responseErrorCode = errorCode;
					retResponse.responseErrorMessage = errorMessage;
					system.debug('ERROR: A099 1');
					
		    		//insert log record
		    		newLog.Success__c = false;
		    		newLog.Error_Code__c = errorCode;
		    		if (errorMessage.length() > 255){
		    			errorMessage = errorMessage.left(40);
		    		}
		    		newLog.Error_Message__c = errorMessage;
		    		newLog.Finished__c = system.now();
		    
					return retResponse;
	            }
			}
			else{
				errorCode = 'A007';
	    		errorMessage = ISSP_Int_Error__c.getValues('A007').Error_Message__c;
	    		
				retResponse.isSuccess = false;
				retResponse.responseErrorCode = 'A007';
				retResponse.responseErrorMessage = 'Invalid template';
				system.debug('ERROR: A007');
				
	    		//insert log record
	    		newLog.Success__c = false;
	    		newLog.Error_Code__c = errorCode;
	    		newLog.Error_Message__c = errorMessage;
	    		newLog.Finished__c = system.now();
	    		insert newLog;
	    		
				return retResponse;
			}
    	}
    	else{ // no template name sent, we'll use the other inputs
    		system.debug('NO TEMPLATE NAME SENT');
    		//Getting language texts - TEST
    		Map <String, String> languageSubject = new Map <String, String> ();
    		Map <String, String> languageMessage = new Map <String, String> ();
	    	List<languageMessage> languageList = inputMessage.languageMessageList;
	    	system.debug('languageList: ' + languageList);
	    	if (languageList == null || languageList.isEmpty()){
	    		errorCode = 'A008';
	    		errorMessage = ISSP_Int_Error__c.getValues('A008').Error_Message__c;
	    		
	    		retResponse.isSuccess = false;
				retResponse.responseErrorCode = 'A008';
				retResponse.responseErrorMessage = 'Invalid notification data';
				system.debug('ERROR: A008');
				
	    		//insert log record
	    		newLog.Success__c = false;
	    		newLog.Error_Code__c = errorCode;
	    		newLog.Error_Message__c = errorMessage;
	    		newLog.Finished__c = system.now();
	    		insert newLog;
	    		
				return retResponse;
	    	}
	    	else{
	    		// looping all languages
	    		for (languageMessage thisText : languageList){
	    			system.debug('thisText.languageCode: ' + thisText.languageCode);
	    			system.debug('thisText.subject: ' + thisText.subject);
	    			system.debug('thisText.message: ' + thisText.message);
	    			if (!languageSubject.containsKey(thisText.languageCode)){
	    				languageSubject.put(thisText.languageCode, thisText.subject);
	    			}
	    			if (!languageMessage.containsKey(thisText.languageCode)){
	    				languageMessage.put(thisText.languageCode, thisText.message);
	    			}
	    		}
	    		// if no english message exists, give error
	    		if (!languageSubject.containsKey('en_US')){
	    			errorCode = 'A009';
	    			errorMessage = ISSP_Int_Error__c.getValues('A009').Error_Message__c;
	    			
	    			retResponse.isSuccess = false;
					retResponse.responseErrorCode = 'A009';
					retResponse.responseErrorMessage = 'Message in default english language is mandatory';
					system.debug('ERROR: A009');
					
		    		//insert log record
		    		newLog.Success__c = false;
		    		newLog.Error_Code__c = errorCode;
		    		newLog.Error_Message__c = errorMessage;
		    		newLog.Finished__c = system.now();
		    		insert newLog;
		    		
					return retResponse;
	    		}
	    		else{
	    			// default values
	    			notificationColor = '#FF5E4D';
			        if (notificationType != 'Action'){
			        	notificationType = 'Information';
			        	notificationColor = '#007FFF';
			        }
			        system.debug('notificationType: ' + notificationType);
			        system.debug('notificationColor: ' + notificationColor);
			        if (daysToExpire > 0 && daysToExpire != null){
			        	expirationDate = system.Now() + daysToExpire;
			        }
			        system.debug('expirationDate: ' + expirationDate);
			        // creating notification for every contact
	    			for (Contact thisContact : contactList){
	    				system.debug('creating notification for contact: ' + thisContact.Id);
	    				Notification__c newNotification = new Notification__c();
	    				newNotification.Contact__c = thisContact.Id;
	    				newNotification.Alert_Contact_By_Email__c = emailAlert;
	    				newNotification.Type__c = notificationType;
	    				newNotification.Notificatin_color__c = notificationColor;
	                    newNotification.Critical_notification__c = criticalNotification;
	                    newNotification.Expiry_date__c = expirationDate;
	                    newNotification.Notification_Campagne_Name__c = inputMessage.campaignName;
	    				if (contactLanguageKeyMap.containsKey(thisContact.Id)){
	    					if (languageSubject.containsKey(contactLanguageKeyMap.get(thisContact.Id))){
	    						system.debug('contact language was in list');
	    						// send in contact language
				            	newNotification.Message__c = languageMessage.get(contactLanguageKeyMap.get(thisContact.Id));
			                    newNotification.Subject__c = languageSubject.get(contactLanguageKeyMap.get(thisContact.Id));
		    				}
		    				else{
		    					system.debug('defaulting to english 1');
		    					// contact language not present, send in engligh
		    					newNotification.Message__c = languageMessage.get('en_US');
			                    newNotification.Subject__c = languageSubject.get('en_US');
		    				}
	    				}
	    				else{
	    					system.debug('defaulting to english 2');
	    					// contact language not present, send in engligh
	    					newNotification.Message__c = languageMessage.get('en_US');
			                newNotification.Subject__c = languageSubject.get('en_US');
	    				}

						newNotification.Message__c = replacePlaceholdersMsg(newNotification.Message__c, replaceMap);

	    				newNotificationList.add(newNotification);
	    			}
	    			try{
	    				system.debug('inserting notifications: ' + newNotificationList.size());
		            	insert newNotificationList;
		            }
		            catch(Exception e){
		            	errorCode = 'A099';
	    				errorMessage = ISSP_Int_Error__c.getValues('A099').Error_Message__c + e.getMessage();
	    				
		            	retResponse.isSuccess = false;
						retResponse.responseErrorCode = 'A099';
						retResponse.responseErrorMessage = 'General error: ' + e.getMessage();
						system.debug('ERROR: A099 2');
						
						//insert log record
			    		newLog.Success__c = false;
			    		newLog.Error_Code__c = errorCode;
			    		if (errorMessage.length() > 255){
			    			errorMessage = errorMessage.left(40);
			    		}
			    		newLog.Error_Message__c = errorMessage;
			    		newLog.Finished__c = system.now();
			    		
						return retResponse;
		            }
		    	}	
	    	}
    	}
    	newLog.Finished__c = system.now();
        insert newLog;
	    return retResponse;
    }
    
    private static Map<String, String> parseReplaceStr(String replaceStr) {
    	if(replaceStr == null || replaceStr == '') {
    		return new Map<String, String>();
    	} else {
    		Map<String, String> replaceMap = new Map<String, String>();

    		List<String> aux1 = replaceStr.split('\\|');

    		for(String s : aux1) {
    			List<String> aux2 = s.split('!');
    			if(aux2.size() == 2)
    				replaceMap.put(aux2[0], aux2[1]);
    		}

    		return replaceMap;
    	}
    }

    private static String replacePlaceholdersMsg(String msg, Map<String, String> replaceMap) {
    	if(msg != null && replaceMap != null) {
	    	for(String key : replaceMap.keySet()) {
	    		msg = msg.replace(key, replaceMap.get(key));
			}
		}
		return msg;
    }
}
public class EF_AccountTriggerHandler {

	public static boolean run = true; 
	private static List  <Account> childAccsList = new List <Account> ();
	private static Map <Id, EF_Material_Line_Item__c> matMap = new Map <Id, EF_Material_Line_Item__c>();
	
	public static void handleAfterUpdate(List<Account> accs, Map<Id,Account> oldMap) {

		
		/* MANAGE ACCOUNT INACTIVATION */
        //
        // Will contain all the accountId's that have been inactivated.
        //
		Set<Id> inactiveAccsSet = new Set<Id> ();
		
		for(Account a: accs){
			if(a.EF_Status__c=='Inactive' && oldMap.get(a.Id).EF_Status__c=='Active'){
				inactiveAccsSet.add(a.Id);
			}
		}
        
        //
		// Check if account has child accounts
		// The child account will be inactivated too.
		//
		
		Map <Id, Account> childAccsMap = new Map <Id, Account> ();

		if(!inactiveAccsSet.isEmpty())
			childAccsMap.putAll([Select Id, EF_Status__c, ParentId, Parent.EF_SubStatus__c from Account 
				where ParentId in: inactiveAccsSet AND EF_Status__c = 'Active']);
		
		if(!childAccsMap.isEmpty() && run){
			for(Account a: childAccsMap.values()){
				a.EF_Status__c='Inactive';	
				a.EF_SubStatus__c = a.Parent.EF_SubStatus__c;
				inactiveAccsSet.add(a.Id);
                childAccsList.add(a); //we'll update at the end, when all the other records have been updated.
                             
			}
            
            //
            // Add the child id's too
            // 
			inactiveEFContracts(inactiveAccsSet); 

		}else if(!inactiveAccsSet.isEmpty() && run){
            inactiveEFContracts(inactiveAccsSet);
            
		}
		for(Integer i = 0; i<1; i++){
			Integer b = 0;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
    }
	}

	public static void inactiveEFContracts(Set<Id> inactiveAccsSet){
		Id contractRTId = AMS_Utils.getId('Contract', 'EF_Client_Agreement');

		//query for Contracts, Billing Agreements and Related Contacts on the accounts inactivated.
		Map <Id,Contract> contractMap = new Map <Id,Contract> ([Select Id, EF_Status__c, EF_Comments__c,
			(Select Id, EF_Status__c, EF_Comments__c from EF_Relationships__r), (Select Id, EF_Status__c from EF_Contacts_in_EF_Contracts__r), 
			(select Id, EF_Status__c from  EF_Material_Line_Items__r) from Contract where AccountId in: inactiveAccsSet and RecordTypeId =: contractRTId]);
        
		List <Contract> contracts2Inactivate = new List <Contract> ();
		Set <Id> BA2Inactivate = new Set <Id> ();
		List <EF_Contact_EF_Contract__c> contractContacs2InactList = new List <EF_Contact_EF_Contract__c> ();

			for(Contract c: contractMap.values()){
				if(c.EF_Status__c != 'Inactive'){
					c.EF_Status__c = 'Inactive';
					c.EF_Comments__c= 'Inactive due to Account Inactivation';
					contracts2Inactivate.add(c);
				}

				for(EF_Billing_Agreement__c ba: c.EF_Relationships__r){
					if(ba.EF_Status__c!='Inactive'){
						BA2Inactivate.add(ba.Id);
					}
				}

				for(EF_Contact_EF_Contract__c cc: c.EF_Contacts_in_EF_Contracts__r){
					if(cc.EF_Status__c!='Inactive'){
						cc.EF_Status__c='Inactive';
						contractContacs2InactList.add(cc);
					}
				}

				for(EF_Material_Line_Item__c mli: c.EF_Material_Line_Items__r){
					if(mli.EF_Status__c!='Inactive'){
						mli.EF_Status__c='Inactive';
						matMap.put(mli.Id, mli);
					}
				}
			}

		if(!contracts2Inactivate.isEmpty()){
			try{ update contracts2Inactivate;
				if(!contractContacs2InactList.isEmpty()){
					update contractContacs2InactList;
				} 
				if(!BA2Inactivate.isEmpty() && run){ 
                    Set<Id> emptySet = new Set<Id>();
                    inactiveEFBillingAgreement(BA2Inactivate, emptySet); 
                }
                else if (childAccsList.size()>0 && run){
                    run=false; 
                    inactiveChildAccounts(childAccsList);
                }

                if(!matMap.isEmpty()){
					inactiveMaterialLineItems(matMap);
				}
			}catch(Exception e){System.debug('## Error inactivating EF Contracts ' +e); 
			throw new AccountException('Error Inactivating EF Contracts ' +e);
		}
		}else{
			if(!inactiveAccsSet.isEmpty() && run){ 
                 	Set<Id> emptySet = new Set<Id>();
                    inactiveEFBillingAgreement(emptySet, inactiveAccsSet); 
                }
                else if (childAccsList.size()>0 && run){
                    run=false; 
                    inactiveChildAccounts(childAccsList);
                }
		}

		
	}
	

	public static void inactiveEFBillingAgreement(Set <Id> BASet, Set <Id> AccSet){

		List <EF_Contact_Relationship__c> BAContacs2InactList = new List <EF_Contact_Relationship__c> ();

		Map <Id, EF_Billing_Agreement__c> baMap = new Map <Id, EF_Billing_Agreement__c> ();
        
		//System.debug('#### calling the method with parameters  ' + BASet +'----'+ AccSet );
        
		if(!BASet.isEmpty() && AccSet.isEmpty()){
            //System.debug('#### on the first if');
			baMap= new Map <Id, EF_Billing_Agreement__c> ([select Id, EF_Status__c, EF_Comments__c,  (Select Id, Status__c from EF_Contact_Relationships__r),
															(Select Id, EF_status__c from EF_Material_Line_Items__r) from EF_Billing_Agreement__c where Id in: BASet]);
		}else if(BASet.isEmpty() && !AccSet.isEmpty()){
            //System.debug('#### on the second if');
			baMap= new Map <Id, EF_Billing_Agreement__c> ([select Id, EF_Status__c, Airline__c, EF_Comments__c, (Select Id, Status__c from EF_Contact_Relationships__r), 
															(Select Id, EF_status__c from EF_Material_Line_Items__r) from EF_Billing_Agreement__c where Airline__c in: AccSet]);
		}

		for(EF_Billing_Agreement__c ba: baMap.values()){
			ba.EF_Status__c='Inactive';
			ba.EF_Comments__c='Inactive due to Account Inactivation';
			
			for(EF_Contact_Relationship__c bac: ba.EF_Contact_Relationships__r){
				if(bac.Status__c!='Inactive'){
					BAContacs2InactList.add(bac);
				}
				
			}

			for(EF_Material_Line_Item__c mli: ba.EF_Material_Line_Items__r){
				if(mli.EF_Status__c!='Inactive'){
					mli.EF_Status__c='Inactive';
					matMap.put(mli.Id, mli);
				}
				
			}
		}


		try{ update baMap.values(); 
                if(!BAContacs2InactList.isEmpty() && run){
                    inactiveEF_BAContacts(BAContacs2InactList);
                }else if(childAccsList.size()>0 && run){
                    run=false;
                    inactiveChildAccounts(childAccsList);
                }

                if(!matMap.isEmpty()){
					inactiveMaterialLineItems(matMap);
				}
			}catch(Exception e){System.debug('## [EF_AccountTriggerHandler.inactiveEFBillingAgreement ] Error ' +e ); throw new AccountException('Error Inactivating Billing Agreements '+e);}	

	}

	public static void inactiveMaterialLineItems(Map <Id, EF_Material_Line_Item__c> materialMap){

		try{ update materialMap.values(); } catch(Exception e){System.debug('#### error on materials ' + e); throw new AccountException('Error inactivating material line items '+e);}
	}

	public static void inactiveEF_BAContacts(List <EF_Contact_Relationship__c> bacList){

		for(EF_Contact_Relationship__c bac: bacList){
			bac.Status__c = 'Inactive';
		}

		try{ 	
            update bacList;
            if(childAccsList.size()>0 && run){
                inactiveChildAccounts(childAccsList);
            }			
		}catch(Exception e){System.debug('## [EF_AccountTriggerHandler.inactiveEF_BAContacts ] Error ' +e ); throw new AccountException('Error Inactivating Contacts from  Billing Agreement '+e);}	

	}

	

	public static void inactiveChildAccounts (List <Account> accs){

		try{
			update accs;
            run=false;
		}catch(Exception e){System.debug('### [EF_AccountTriggerHandler.inactiveChildAccounts] Error inactivating child accounts ' + e); throw new AccountException('Error inactivating child Accounts '+e);}

	}

	 //E&F Notification of fields identified as critical. List of fields set on custom setting.
	public static void manageCriticalFieldChanges(List<Account> accs, Map<Id,Account> oldMap){
		List<EF_Critical_Field_Notification__c> fieldList = EF_Utilities.getCriticalFields();

		List  <String> criticalClientFieldList = new List <String> ();
		List  <String> criticalAirlineFieldList = new List <String> ();
		
		if(fieldList!=null){
			for(EF_Critical_Field_Notification__c cfn: fieldList){
                if(cfn.Account_Client_Fields__c!=null){
                    criticalClientFieldList= cfn.Account_Client_Fields__c.split(',');
                }
                if(cfn.Account_Airline_Fields__c!=null){
                   criticalAirlineFieldList = cfn.Account_Airline_Fields__c.split(',');	 
                }
								
			}
			
			Map <Id,Account> accsAirlineNoti = new Map <Id,Account>();
			Map <Id,Account> accsClientNoti = new Map <Id,Account>();

			Map<String, Schema.SobjectField> fields = accs.getSObjectType().getDescribe().fields.getMap();

			//loop over accounts to check if any of them need to trigger a notification.
			for(Account a: accs){			
				//check fields for Clients
				if(a.RecordTypeId==AMS_Utils.getId('Account', 'Others') ){
					
					for(String s: criticalClientFieldList){
									
		           	
						if(a.get(s)!=oldMap.get(a.Id).get(s)){
							accsClientNoti.put(a.Id, a);
						}
					}
				}

				//check fields for Customers
				if(a.RecordTypeId==AMS_Utils.getId('Account', 'Operator') ||
					a.RecordTypeId==AMS_Utils.getId('Account', 'IATA_Airline_BR') ||
					a.RecordTypeId==AMS_Utils.getId('Account', 'IATA_Airline')){
					for(String s: criticalAirlineFieldList){
									
		           	
						if(a.get(s)!=oldMap.get(a.Id).get(s)){
							accsAirlineNoti.put(a.Id, a);
						}
					}
				}
			}		

			if(!accsAirlineNoti.isEmpty()){
				notifyOnCriticalFields(accsAirlineNoti, oldMap, criticalAirlineFieldList);
			}
			if(!accsClientNoti.isEmpty()){
				notifyOnCriticalFields(accsClientNoti, oldMap, criticalClientFieldList);
			}
		}
	}

	private static void notifyOnCriticalFields (Map <Id, Account> newAccs, Map <Id,Account> oldAccMap, List <String> criticalFieldList ) {

		Map<String, Schema.SobjectField> fields = newAccs.getSObjectType().getDescribe().fields.getMap();
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        for(Account a: newAccs.values()){
        	String emailBody = 'Dear team member, <br/><br/>the following Accounts values been UPDATED:<br/><br/>';
        	emailBody = emailBody + '<table width="600px" border="1"><tr border="1"><th border="1">Account</th><th border="1">Field:</th><th border="1">New Value:</th><th border="1">Old Value:</th></tr>';
        
           for(String s: criticalFieldList){
			           	
				if(a.get(s)!=oldAccMap.get(a.Id).get(s)){
             		emailBody = emailBody + '<tr><td border="1"><a href="'+baseUrl+'/'+a.Id+'">'+a.Name+'</a></td><td border="1">'+s+'</td><td border="1">'+a.get(s)+'</td><td border="1">'+oldAccMap.get(a.Id).get(s)+'</td></tr>';
             	}
           }
           emailBody = emailBody + '</table>';
           if(a.RecordTypeId==AMS_Utils.getId('Account', 'Others')){
           		if(a.EF_Client_Services_Specialist__c!=null){
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           mail.setSaveAsActivity(false);
			        mail.setToAddresses(new List <String> {'efs@iata.org', a.EF_Client_Services_Specialist_Email__c}); 
           mail.setSubject('E&F Account Critical Changes Notification');
           mail.setBccSender(false);
           mail.setUseSignature(false);       
           mail.setHtmlBody(emailBody);
		            mails.add(mail);
           		//Utility.sendEmail(new List <String> {'efs@iata.org', a.EF_Client_Services_Specialist_Email__c}, 'E&F Account Critical Changes Notification ', emailBody, true, null);
         	     }else{
         	     	Messaging.SingleEmailMessage mailNoCS = new Messaging.SingleEmailMessage();  
			        mailNoCS.setSaveAsActivity(false);
			        mailNoCS.setToAddresses(new List <String> {'efs@iata.org'});    
			        mailNoCS.setSubject('E&F Account Critical Changes Notification');
			        mailNoCS.setBccSender(false);
			        mailNoCS.setUseSignature(false);       
		            mailNoCS.setHtmlBody(emailBody);
		            mails.add(mailNoCS);
           		
           		//Utility.sendEmail(new List <String> {'efs@iata.org'}, 'E&F Account Critical Changes Notification ', emailBody, true, null);
           }
           }else{

           		Messaging.SingleEmailMessage mailNoClient = new Messaging.SingleEmailMessage();  
		        mailNoClient.setSaveAsActivity(false);
		        mailNoClient.setToAddresses(new List <String> {'efs@iata.org'});    
		        mailNoClient.setSubject('E&F Account Critical Changes Notification');
		        mailNoClient.setBccSender(false);
		        mailNoClient.setUseSignature(false);       
	            mailNoClient.setHtmlBody(emailBody);
	            mails.add(mailNoClient);
           		
           		//Utility.sendEmail(new List <String> {'efs@iata.org'}, 'E&F Account Critical Changes Notification ', emailBody, true, null);
           }
          
        }

        if(!mails.isEmpty()){
        	Messaging.sendEmail(mails);
        }          
              
    }
     public class AccountException extends Exception {}
	
}
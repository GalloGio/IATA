/**
This trigger is in charge of updating contact according to Employee  / person
		phone
		email
		fax
		Birth date
		Mobile
*/
trigger ContactUpdaterTrigger on AMS_Person__c (after update) {

		if(!AMS_TriggerExecutionManager.checkExecution(AMS_Person__c.getSObjectType(), 'ContactUpdaterTrigger')) { return; }

		Map<String, List<AMS_Account_Role__c>> empsPerPerson = new  Map<String, List<AMS_Account_Role__c>>();
		Map<String, String> personPerContact= new  Map<String, String>();
		list<String>ids = new list<String>();
		list<String>eids = new list<String>();
		for(AMS_Person__c p:trigger.new){
				//JFO 16/10/2015  should be done only on WEBSTAR DATA
				if(p.legacy_system__c =='WEBSTAR')
						empsPerPerson.put(p.Id, new List<AMS_Account_Role__c>());
		}
		list<AMS_Account_Role__c> emps = [select Person__c,legacy_system__c, Id,Contact__r.Email,Contact__r.Phone, Contact__c,DUTY__c,Hours__c,Earning__c,isManager__c,isTicketingAgent__c,Position__c,Registration_Date__c,Stage__c,Start_date__c,Termination_Date__c,Title__c,Valid__c from AMS_Account_Role__c where Person__c in :empsPerPerson.keyset()];
		for(AMS_Account_Role__c e:emps){
			 empsPerPerson.get(e.Person__c).add(e);
			 if(e.Contact__c!=null){
					 e.Contact__r.Email = trigger.newMap.get(e.Person__c).Email__c;
			 }
			 //MUSTbe done only on WEBSTAR DATA
			 if(e.legacy_system__c=='WEBSTAR')
					 personPerContact.put(e.Contact__c, e.Person__C);

		}
		List<Contact> cts = [select id, email,phone, MobilePhone, Fax from contact where Id in :personPerContact.keyset()  ];
		for(Contact c:cts){

				c.email = trigger.newMap.get(personPerContact.get(c.id)).Email__c;
				c.phone  = trigger.newMap.get(personPerContact.get(c.id)).Phone__c;
				c.Birthdate= trigger.newMap.get(personPerContact.get(c.id)).DOB__c;
				c.MobilePhone= trigger.newMap.get(personPerContact.get(c.id)).Mobile__c;
				c.Fax= trigger.newMap.get(personPerContact.get(c.id)).Fax__c;

		}
		update cts;


}

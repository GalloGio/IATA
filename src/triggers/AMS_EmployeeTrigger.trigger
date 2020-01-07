trigger AMS_EmployeeTrigger on AMS_Employee__c (before insert,after insert, before update, after update) {

	/*#AMSFTS moved it into AMS_AccountRoleTrigger

	//bind employee to contact
	if(Trigger.isBefore){
		list<AMS_Employee__c> bindToContact = new list<AMS_Employee__c>();

		if(Trigger.isInsert || Trigger.isUpdate){
			for(AMS_Employee__c emp :trigger.new){
				if(emp.Contact__c == null && emp.Person__c != null)
					bindToContact.add(emp);
			}
		}

		if(bindToContact.size()>0)
			AMS_EmployeeHelper.addContactIfEmpty(bindToContact);
	}
	#AMSFTS*/

   /*#AMSFTS
	Map<String , AMS_Employee__c > accountIds2UpdateWithQTAEmployee = new Map<String , AMS_Employee__c >();
	if(Trigger.isAfter){
		for(AMS_Employee__c  e:trigger.new){
			if(e.isTicketingAgent__c && (trigger.isInsert || !trigger.oldMap.get(e.Id).isTicketingAgent__c )){
				//agenciesIds2UpdateWithQTAEmployee.put(e.agency__c,e);#AMSFTS
				accountIds2UpdateWithQTAEmployee.put(e.Account__c,e);
			}
		}

		if(accountIds2UpdateWithQTAEmployee.size()>0){
			AMS_EmployeeHelper.updateAccountQTAemployee(accountIds2UpdateWithQTAEmployee);
		}

		if(Trigger.isUpdate){
			AMS_AgencyUpdateHelper.agencyUpdate(Trigger.new);
		}
	}
	//if needed we update agencies ticketing contact
	if(agenciesIds2UpdateWithQTAEmployee .size()>0){
		List<AMS_Agency__c> agencies2update =[select id,Qualified_ticketing_agent2__c from AMS_Agency__c where Id in:agenciesIds2UpdateWithQTAEmployee.keySet()];
		for(AMS_Agency__c a:agencies2update )
			a.Qualified_ticketing_agent2__c  = agenciesIds2UpdateWithQTAEmployee.get(a.Id).Id;
		update agencies2update;
	}#AMSFTS*/





/*
Example of the Person Trigger that has been removed!!!
------------------------------------------------------
trigger AMS_PersonTrigger on AMS_Person__c (before insert, before update) {

	list<AMS_Person__c> checkContacts = new list<AMS_Person__c>();
	list<AMS_Person__c> bindToContact = new list<AMS_Person__c>();
	list<AMS_Person__c> checkAgencies = new list<AMS_Person__c>();

	if(Trigger.isInsert){
		for(AMS_Person__c p : trigger.new){
			if(p.Contact__c!=null)
				checkContacts.add(p);
			else if(p.Contact__c==null)
				bindToContact.add(p);
			if(Trigger.isBefore && p.Agency__c!=null && p.isManager__c==true)
				checkAgencies.add(p);
		}

	}else if(Trigger.isUpdate){
		for(AMS_Person__c p : trigger.new){
			if(trigger.oldMap.get(p.Id).Contact__c != p.Contact__c && p.Contact__c!=null)
				checkContacts.add(p);
			else if(trigger.oldMap.get(p.Id).Contact__c != p.Contact__c && p.Contact__c==null)
				bindToContact.add(p);
			if(Trigger.isBefore && p.Agency__c!=null && p.isManager__c==true &&
			   (trigger.oldMap.get(p.Id).Agency__c != p.Agency__c ||
				trigger.oldMap.get(p.Id).isManager__c != p.isManager__c))
				checkAgencies.add(p);
		}
	}

	if(checkContacts.size()>0)
		AMS_PersonHelper.Ensure0to1ContactLookup(checkContacts);
	if(bindToContact.size()>0)
		AMS_PersonHelper.addContactIfEmpty(bindToContact);

	if(checkAgencies.size()>0)
		AMS_PersonHelper.EnsureMax1ManagerPerAgency(checkAgencies);


*/
   /* if(Trigger.isBefore){
		list<AMS_Employee__c> checkContacts = new list<AMS_Employee__c>();
		list<AMS_Employee__c> bindToContact = new list<AMS_Employee__c>();
		list<AMS_Employee__c> checkAgencies = new list<AMS_Employee__c>();
		AMS_Person__c person = new AMS_Person__c();


		if(Trigger.isInsert || Trigger.isUpdate){
			for(AMS_Employee__c emp : trigger.new){

				AMS_Person__c p = [SELECT Id, Contact__c, Name, Firstname__c FROM AMS_Person__c WHERE id = :emp.Person__c];

				System.debug('--------------------------AMS_Employee__c: ' + emp);
				System.debug('--------------------------emp.Person__r: ' + emp.Person__r);
				System.debug('--------------------------AMS_Person__c: ' + p);
				System.debug('--------------------------p.Contact__c: ' + p.Contact__c);


				person.Id = p.Id;
				person.Contact__c = p.Contact__c != null ? p.Contact__c : null;
				person.Name = p.Name != null ? p.Name : null;
				person.Firstname__c = p.Firstname__c != null ? p.Firstname__c : null;

				emp.Person__r = person;

				if(p.Contact__c!=null)
					checkContacts.add(emp);
				else if(p.Contact__c==null)
					bindToContact.add(emp);
				if(Trigger.isBefore && emp.Agency__c!=null && emp.isManager__c==true)
					checkAgencies.add(emp);
			}

		}

	  /*  if(checkContacts.size()>0)
			AMS_EmployeeHelper.Ensure0to1ContactLookup(checkContacts);
			*/
	/*    if(bindToContact.size()>0)
			AMS_EmployeeHelper.addContactIfEmpty(bindToContact);

		System.debug('--------------------------checkContacts: ' + checkContacts);
		System.debug('--------------------------bindToContact: ' + bindToContact);


	   /* if(checkAgencies.size()>0)
			AMS_EmployeeHelper.EnsureMax1ManagerPerAgency(checkAgencies);
		*/
//    }
}

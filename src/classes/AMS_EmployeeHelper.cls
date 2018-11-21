global class AMS_EmployeeHelper {
	public static void addContactIfEmpty(List<AMS_Account_Role__c> employees){
		Map<String,Contact> mapContacts = new Map<String,Contact>();
		Set<String> LastNames = new Set<String>();
		//Set<ID> AgencyIDs = new Set<ID>();#AMSFTS
		Set<ID> AccountIDs = new Set<ID>();
		Set<ID> PersonIDs = new Set<ID>();
		Set<Date> DoBs = new Set<Date>();
		Set<String> emails = new Set<String>();
		//Map<ID,ID> AgencyToAccount = new Map<ID,ID>();#AMSFTS
		List<AMS_Person__c> listOfPersonsToUpdate = new List<AMS_Person__c>();
		
		//jfo 2015-10-27 adding the IDCARD <> new contact mnanagment
		Map<String,AMS_Account_Role__c > employeeBySimplex = new Map<String,AMS_Account_Role__c >();
		//List<AMS_Employee__c> listOfEmployees = [select id, Contact__c, Agency__c, Person__c, Person__r.Name, Person__r.DOB__c, Person__r.Email__c from AMS_Employee__c where id IN :employees];
		Map<String,Contact> contactPerEmail = new Map<String,Contact>();
		
		for(AMS_Account_Role__c emp: employees){
			PersonIDs.add(emp.Person__c);
		}
		
		Map<ID, AMS_Person__c> mapOfPersons = new Map<ID, AMS_Person__c>([select id,legacy_system__c, Contact__c, Name, DOB__c, Phone__c, Email__c,Lastname__c, First_Name__c, Mobile__c, Fax__c from AMS_Person__c where id IN: PersonIDs]);
		//jfo 2015-11-13: add vernum to crieteia
		Map<String,AMS_Account_Role__c> empSimplexes = new Map<String,AMS_Account_Role__c>();
		for(AMS_Account_Role__c emp : employees){
			if(emp.Simplex__c !=null)
				empSimplexes.put(emp.Simplex__c,emp);
			
			//AgencyIDs.add(emp.Agency__c);#AMSFTS
			AccountIDs.add(emp.Account__c);
			LastNames.add(mapOfPersons.get(emp.Person__c).Lastname__c);
			DoBs.add(mapOfPersons.get(emp.Person__c).DOB__c);
			emails.add(mapOfPersons.get(emp.Person__c).Email__c); 
		}

		List<String> iataCodeList = new list<String>();
		
		for(Account acc:[select Id, IATACode__c  from Account where Id in :AccountIDs])
			iataCodeList .add(acc.IATACode__c  );

		for(Contact c : [SELECT AccountId, FirstName, LastName, Name, Birthdate, Email, Person__c,VER_Number_2__c
						 FROM Contact 
						 WHERE (AccountId IN : AccountIDs
								AND LastName IN :LastNames
								AND Birthdate IN :DoBs
								AND Email IN :emails) 
								or
								(VER_Number_2__c in :empSimplexes.keyset() 
								AND AccountId IN : AccountIDs)]){
			mapContacts.put(c.AccountId+'-'+c.FirstName+'-'+c.LastName+'-'+c.Birthdate, c);
			//jfo 2015-11-13 from LSB
			// add vernum to crieteia
			if(c.VER_Number_2__c !=null)
			mapContacts.put(c.VER_Number_2__c,c);
			system.debug('contact: ' + c.AccountId+'-'+c.FirstName+'-'+c.LastName+'-'+'-'+c.Birthdate);
		}

		Map<Id, Contact> newContacts = new Map<Id,Contact>();
		List<Contact> oldContacts = new List<Contact>();
		for(AMS_Account_Role__c emp : employees){
			ID myAccount = emp.Account__c;//AgencyToAccount.get(emp.Agency__c);#AMSFTS
			system.debug('getting: ' + myAccount+'-'+mapOfPersons.get(emp.Person__c).First_name__c +'-'+mapOfPersons.get(emp.Person__c).Lastname__c+'-'+    '-'+mapOfPersons.get(emp.Person__c).DOB__c);
			//jfo 2015-11-13 from LSB
			// add vernum to crieteia
			Contact theContact  = null;
			if(emp.Simplex__c !=null)
			theContact = mapContacts.get(emp.Simplex__c );
			if(theContact==null)
			theContact = mapContacts.get(myAccount+'-'+mapOfPersons.get(emp.Person__c).First_name__c +'-'+mapOfPersons.get(emp.Person__c).Lastname__c+'-'+mapOfPersons.get(emp.Person__c).DOB__c);
			system.debug('thecontact: ' + theContact);
			if(theContact != null){
				emp.Contact__c = theContact.ID;
				
				//RP 6/11/2016 add the contact to the person
				mapOfPersons.get(emp.Person__c).Contact__c = theContact.ID;
				listOfPersonsToUpdate.add(mapOfPersons.get(emp.Person__c));
				
				if(theContact.Person__c == null){
					theContact.Person__c = emp.Person__c;
					//we only update WEBSTAR DATA
					if(mapOfPersons.get(emp.Person__c).legacy_system__c =='WEBSTAR'){
						theContact.FirstName=mapOfPersons.get(emp.Person__c).First_Name__c;
						theContact.LastName=mapOfPersons.get(emp.Person__c).Lastname__c;
						theContact.Birthdate=mapOfPersons.get(emp.Person__c).DOB__c;
						theContact.Phone=mapOfPersons.get(emp.Person__c).Phone__c;
						theContact.MobilePhone=mapOfPersons.get(emp.Person__c).Mobile__c;
						theContact.Fax=mapOfPersons.get(emp.Person__c).Fax__c;
					}
					oldContacts.add(theContact);
				}
			}else if(theContact == null && mapOfPersons.get(emp.Person__c).Email__c!=null){
				//we can create contact for Both
				system.debug('creating new contact');
				newContacts.put(emp.Id,new Contact(AccountId=myAccount,
				FirstName=mapOfPersons.get(emp.Person__c).First_Name__c,
				LastName=mapOfPersons.get(emp.Person__c).Lastname__c,
				recordtypeId =RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact'),
				Email=mapOfPersons.get(emp.Person__c).Email__c,
				Birthdate=mapOfPersons.get(emp.Person__c).DOB__c,
				Phone=mapOfPersons.get(emp.Person__c).Phone__c,
				MobilePhone=mapOfPersons.get(emp.Person__c).Mobile__c,
				Fax=mapOfPersons.get(emp.Person__c).Fax__c,
				VER_Number_2__c = emp.SIMPLEX__c,
				Person__c = emp.Person__c));
				//jfo 2015-10-27 adding the IDCARD <> new contact mnanagment
				if(emp.SIMPLEX__c!=null&& emp.SIMPLEX__c!=''){
					employeeBySimplex.put(emp.SIMPLEX__c,emp);
				}
			}
		}
		system.debug('[employeeBySimplex]  Id card to find ' + employeeBySimplex.size());
		system.debug('size: ' + newContacts.size());
		if(newContacts.size()>0){
			Map<String, ID_Card__c> idcardsPervernum  = new Map<String, ID_Card__c>();
			system.debug('[employeeBySimplex]  try to find IdCard from  ' + iataCodeList +'  NA dverNum '+employeeBySimplex.keySet() );
			List<String> simplexList = new list<String>();
			for(String s:employeeBySimplex.keySet())
			simplexList.add(s);
			List<Id> idCardsids = AMS_EmployeeHelper.retreiveIdCards(iataCodeList ,simplexList);
			for( ID_Card__c  idc : [select id, Related_Contact__c,VER_Number__c from ID_Card__c where   Id in :idCardsids   ]){
				idcardsPervernum.put(idc.VER_Number__c,idc);
			}
	
			contactPerEmail.clear();
			for(Contact ac:newContacts.values()){
			contactPerEmail.put(ac.Email, ac);
			}
			
			//jfo won't work if several new contact has the same email
			Map<String, Contact>  contactEmail2remove = new Map<String, Contact> ();
			for(Contact ac:[select ID,  Email from Contact where Email in:contactPerEmail.keySet() ])
			if(contactPerEmail.get(ac.Email)!=null){
				contactEmail2remove.put(ac.Email,contactPerEmail.get(ac.Email));
				//contactPerEmail.get(ac.Email).Email = null;
			}
			
			/* creating final list */
			Map<Id, Contact> cleanNewContact = new Map<Id,Contact>();
			for(ID akey:newContacts.keySet()){
				if(contactEmail2remove.get(newContacts.get(akey).Email)==null)
					cleanNewContact.put(akey,newContacts.get(akey));
			}
	
			newContacts = cleanNewContact;
			insert newContacts.values();
	
			//jfo 2015-10-27 adding the IDCARD <> new contact mnanagment
			List<ID_Card__c> idCards2update = new List<ID_Card__c>();
			
			
			for(AMS_Account_Role__c emp : employees){
				if(emp.Contact__c == null && newContacts.get(emp.ID) != null ){
					//this method is called from a trigger. no need to save data here.
					emp.Contact__c = newContacts.get(emp.ID).ID;
					
					//RP 6/11/2015 add the contact to the person
					mapOfPersons.get(emp.Person__c).Contact__c = newContacts.get(emp.ID).ID;
					listOfPersonsToUpdate.add(mapOfPersons.get(emp.Person__c));
					
					//jfo 2015-10-27 adding the IDCARD <> new contact mnanagment
					ID_Card__c idc  = idcardsPervernum.get(emp.Simplex__c);
					if(idc !=null ){
						idc.Related_Contact__c  = newContacts.get(emp.ID).ID;
						idCards2update .add(idc);
					}
				}
			}
			
			if(idCards2update.size()>0)
				update idCards2update;
		}

		if(oldContacts.size()>0){
			contactPerEmail.clear();
			List<Contact> contact2remove = new List<Contact>();
			for(Contact ac:oldContacts){
				if(ac.Email != null)
					contactPerEmail.put(ac.Email, ac);
			}
			//jfo won't owrk if several new contact has the same email
			
			for(Contact ac:[select ID,  Email from Contact where Email in:contactPerEmail.keySet() ])
				if(contactPerEmail.get(ac.Email)!=null && contactPerEmail.get(ac.Email).ID !=ac.Id  ){
					contactPerEmail.get(ac.Email).Email = null;
			}
			update oldContacts;
		}

		if(listOfPersonsToUpdate.size() > 0)
		update listOfPersonsToUpdate;
	}


	@ReadOnly
	webservice static List<Id> retreiveIdCards(list<String> iataCodes, List<String> vernums){
		List<Id> r = new  List<Id>();
		system.debug('[employeeBySimplex]  try to find IdCard from  ' + iataCodes+'  NA dverNum '+vernums);
		try{
			Map<Id,ID_Card__c > idCardsMap = new Map<Id,ID_Card__c >( [select id, Related_Contact__c,VER_Number__c from ID_Card__c where   Agency_IATA_Code__c in :iataCodes and Related_Contact__c = null and VER_Number__c  in :vernums ]);//  
			for(Id idc:idCardsMap.keySet())
				r.add(idc);
		}catch(Exception e){
			system.debug('[employeeBySimplex] Failed to find exisitng ID Card because of too many IDCards in system without index  ' +e.getMessage());
		}
		return r;
	}

}
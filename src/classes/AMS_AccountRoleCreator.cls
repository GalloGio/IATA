/** This class handles the AMS Account Role creation and Account linking for both Portal and Wizard.
 *  It utilizes AMS Accreditation Online and AMS Accreditation Contact objects and tries to pair
 *  Accreditation Contacts with standard Person (AMS) and Contacts in the system and update the roles according to selections.
 *  
 *  The process starts by deleting all existing AMS Account Roles related to the Persons or Contacts linked earlier to the 
 *  Agency (roles related to other Agencies are of course not affected).
 *  During the Accreditation Contact updates on Ownership setup page (AMSAccreditationContact.page), the end-user can link his selection to a Contact 
 *  or Person (AMS), and based on this selection, the processing is slightly different. If a Person (AMS) is linked, it is deleted and a new Contact with 
 *  data based on Accreditation Contact fields is created to replace it, and the AC record is updated to contain a link to the new Contact instead 
 *  of having a link to the now deleted Person.
 *  If the AC record already contains a link to a Contact, the Contact is updated based on values on AC. If no linking either to a Person (AMS) or 
 *  Contact exist on AC, a new Contact is created and the AC is updated to contain the link to the Contact record.
 *
 *  For Account ownership values, either new Accounts or linked Accounts are given new AMS Account Roles to reflect the Agency Ownership values set 
 *  on the Ownership setup page.
 */
public with sharing class AMS_AccountRoleCreator
{
	public static Set<String> aoaIdSet;

	private static final String recordTypesPerson = createContactRecordTypes(new List<String>{'Person','Current_Owner'});
	private static final String recordTypesCompany = createContactRecordTypes(new List<String>{'Company','Current_Company_Owner'});
	
	public static final Map<String,String> personDeveloperName = new Map<String,String>{'Person' => 'Person','Current_Owner' => 'Current_Owner'};
	public static final Map<String,String> companyDeveloperName = new Map<String,String>{'Company' => 'Company','Current_Company_Owner' => 'Current_Company_Owner'};
	
	// This funny looking method is a workaround to be able to use a variable (Set<Id>) in a dynamic query
	public static List<AMS_Accreditation_Contact__c> retrieveACsDynamically(String soqlString, String setName)
	{
		system.debug('retrieveACsDynamically() -> final = '+soqlString.replace('ABC', setName));
        return Database.query(soqlString.replace('ABC', setName));
    }

    public static void runRoleCreatorForOnlineAccreditations(List<AMS_Pax_Accreditation_Form__c> aoaList){
    	runRoleCreatorForOnlineAccreditations(aoaList, false);
    }
    	
	public static void runRoleCreatorForOnlineAccreditations(List<AMS_Pax_Accreditation_Form__c> aoaList, boolean isCorrection)
    {


 		throw new AMS_ApplicationException('This is not to be used !');

    	System.debug(LoggingLevel.ERROR, '[LF] runRoleCreatorForOnlineAccreditations() '+aoaList);
    	set<id> setAddedRoles = new set<id>();
    	AMS_AccountRoleCreator.aoaIdSet = new Set<String>();
    	for(AMS_Pax_Accreditation_Form__c aoa : aoaList)
    	{
    		aoaIdSet.add(aoa.Id);
    	}
    	
    	Set<Id> allAcPersonContactIds = new Set<Id>();
    	
    	List<AMS_Account_Role__c> oldRolesToUpdate = new List<AMS_Account_Role__c>();
    	List<AMS_Account_Role__c> newRolesToInsert = new List<AMS_Account_Role__c>();
    	
    	Set<Id> oldRolesToUpdateSet = new Set<Id>();
    	Set<Id> oldPersonsToDeleteSet = new Set<Id>();
    	Set<String> newRolesToInsertEmailSet = new Set<String>();
    	
    	Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
    	Map<String, Contact> newContactsToInsert = new Map<String, Contact>();
    	
    	
    	Set<Id> acPersonIdSet = new Set<Id>();
    	Set<String> acPersonEmailSet = new Set<String>();
    	Set<String> currentAcEmails = new Set<String>();
    	
    	String accountId;

    	String commaSeparatedFields = AMS_AccreditationContactHelper.loadFieldsDynamically('AMS_Accreditation_Contact__c');
        
        String query = 'select ' + commaSeparatedFields + ', AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c, Person_AMS__r.Contact__c ';
        query = query + ' from AMS_Accreditation_Contact__c where AMS_Pax_Accreditation_Form__c in :ABC and RecordTypeId in ';
        query = query + '(' + recordTypesPerson + ')';

        List<AMS_Accreditation_Contact__c> acList = retrieveACsDynamically(query, 'aoaIdSet');

        System.debug(LoggingLevel.ERROR, '[LF] retrieveACsDynamically() '+acList);
		
        if(acList.size() > 0)
        {
        	accountId = acList.get(0).AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c;
        	
        	for(AMS_Accreditation_Contact__c ac : acList)
        	{
        		//TD: Removed Employee from Role. Keep them on Contact object only
        		//if(ac.AMS_Employee_Role__c == null && ac.AMS_Ownership_Role__c == null)
        		if(ac.AMS_Ownership_Role__c == null)
        		{
	        		if(ac.Person_AMS__c != null)
	        		{
	        			allAcPersonContactIds.add(ac.Person_AMS__c);
	        		}
	        		if(ac.Contact__c != null)
	        		{
	        			allAcPersonContactIds.add(ac.Contact__c);
	        		}
	        		if(ac.Company__c == null)
	        		{
	        			ac.Company__c = accountId;
	        		}
        		}
        	}
        	
        	if(allAcPersonContactIds.size() > 0)
        	{
        		List<AMS_Account_Role__c> oldRoles = [select id, Termination_Date__c, Person__c, Contact__c, Contact__r.Name, Person__r.Name from AMS_Account_Role__c where (Person__c in :allAcPersonContactIds or Contact__c in :allAcPersonContactIds) and Account__c = :accountId];
        		
        		for(AMS_Account_Role__c oldRole : oldRoles)
        		{
        			oldRole.Termination_Date__c = Date.today();
        		}
        		update oldRoles;
        	}
        }
        
        
        /** !! NOTE: This first step handles People (Person or Contact) only! !! */
        // 1) Find if the AC has a link to a AMS Person or Contact
        List<AMS_Accreditation_Contact__c> acPersons = getPersonLinkingOnly(acList);
        List<AMS_Accreditation_Contact__c> acContacts = getContactLinking(acList);
        List<AMS_Accreditation_Contact__c> acNoLink = getNoPersonNorContactLing(acList);
        Map<AMS_Accreditation_Contact__c, List<AMS_Account_Role__c>> acRoleMap = new Map<AMS_Accreditation_Contact__c, List<AMS_Account_Role__c>>();
		
		System.debug(LoggingLevel.ERROR, '[LF] *********** acPersons: '+acPersons);
		System.debug(LoggingLevel.ERROR, '[LF] *********** acContacts: '+acContacts);
		System.debug(LoggingLevel.ERROR, '[LF] *********** acNoLinks: '+acNoLink);
		
        // PERSON__C LINKING EXISTS => Create Contacts and update the existing Roles to link to the Contact, delete Person records
        if(acPersons.size() > 0)
        {
	        for(AMS_Accreditation_Contact__c acPerson : acPersons)
	        {
	        	Contact temp = AMS_AccreditationContactHelper.populateNewContactFields(new Contact(), acPerson);
	        	newContactsToInsert.put(temp.Email, temp);
	        }
	        
	        if(newContactsToInsert.size() > 0 && !isCorrection)
	   		{
	   			List<Contact> conListToInsert = verifyNoDuplicateIFAPcontactExists(newContactsToInsert.values());
	   			System.debug(LoggingLevel.ERROR, '[LF] insert 1 : '+conListToInsert);

	   			insert conListToInsert;
	   		}
	        
	        for(string s:newContactsToInsert.keyset()){
	        	system.debug('DTULLO 124 --> ' + s + '; id: ' + newContactsToInsert.get(s).Id);
	        }
	        
	        Set<Id> roleIdsToLoad = new Set<Id>();
	        for(AMS_Accreditation_Contact__c acPerson : acPersons)
	        {
	        	Contact insertedContact = newContactsToInsert.get(acPerson.Email__c);
	        	acPersonIdSet.add(acPerson.Id);
	        	acPersonEmailSet.add(acPerson.Email__c);
	        	system.debug('DTULLO 133 --> ' + acPerson.Email__c);
	        	if(insertedContact != null)
	        	{
					acPerson.Contact__c = insertedContact.Id;
				}
				
				AMS_Account_Role__c newRole;
				//TD: Removed Employee from Role. Keep them on Contact object only
        		//if(acPerson.AMS_Employee_Role__c == null && acPerson.AMS_Ownership_Role__c == null)
        		if(acPerson.AMS_Ownership_Role__c == null)
        		{
        			// create a new AMS Account Role for the AC
	        		newRole = AMS_AccreditationContactHelper.createAmsAccountRole(acPerson);
        			newRolesToInsert.add(newRole);
        			newRolesToInsertEmailSet.add(newRole.Contact__r.Email);
        		} else
        		{
        			// preparation for role update
        			//TD: Removed Employee from Role. Keep them on Contact object only
        			//roleIdstoLoad.add(acPerson.AMS_Employee_Role__c);
        			roleIdstoLoad.add(acPerson.AMS_Ownership_Role__c);
        		}
        		if (acRoleMap.containsKey(acPerson))
	            {
					acRoleMap.get(acPerson).add(newRole);
				} else
				{
					acRoleMap.put(acPerson, new List<AMS_Account_Role__c>{newRole});
				}
	        }
	        
	        Map<Id, AMS_Account_Role__c> idRoleMap = new Map<Id, AMS_Account_Role__c>();
	        if(roleIdsToLoad.size() > 0)
	        {
	        	idRoleMap = new Map<Id, AMS_Account_Role__c>([select Account__c, Duty__c, Employee_Name__c, Hours__c, IsManager__c, Owner_Account__c, Percentage__c, Position__c, Owner_Name__c, RecordTypeId from AMS_Account_Role__c where Id in :roleIdsToLoad]);
	        }
	        
	        if(idRoleMap.size() > 0)
	        {
	        	AMS_Account_Role__c toUpdateRole;
	        	for(AMS_Accreditation_Contact__c acPerson : acPersons)
	        	{
	        		//TD: Removed Employee from Role. Keep them on Contact object only
	        		/*
	        		if(acPerson.AMS_Employee_Role__c != null)
	        		{
	        			toUpdateRole = AMS_AccreditationContactHelper.updateAmsAccountRole(idRoleMap.get(acPerson.AMS_Employee_Role__c), acPerson);
	        			oldRolesToUpdate.add(toUpdateRole);
	        		}*/
	        		if(acPerson.AMS_Ownership_Role__c != null && !isCorrection)
	        		{
	        			if(!setAddedRoles.contains(acPerson.AMS_Ownership_Role__c)){
		        			toUpdateRole = AMS_AccreditationContactHelper.updateAmsAccountRole(idRoleMap.get(acPerson.AMS_Ownership_Role__c), acPerson);
		        			oldRolesToUpdate.add(toUpdateRole);
		        			setAddedRoles.add(toUpdateRole.Id);
	        			}
	        		}
	        	}
	        }
        }
        
        
        
        // CONTACT LINKING EXISTS
        system.debug('DTULLO 196 --> ' + acContacts.size());
        if(acContacts.size() > 0)
        {
        	Set<Id> acContactIdSet = new Set<Id>();
	    	Set<String> acContactEmailSet = new Set<String>();
        	
        	for(AMS_Accreditation_Contact__c acContact : acContacts)
	        {
	        	acContactIdSet.add(acContact.Contact__c);
	        	acContactEmailSet.add(acContact.Email__c);
	        }
	        
        	Map<String, Contact> emailContactMap = new Map<String, Contact>();
        	for(Contact c : [SELECT FirstName, LastName, Title, AccountId, Membership_Main_Contact__c, Training_dangerous_goods_completed__c, list_Dangerous_Goods_Awareness__c, Phone, MobilePhone, Fax, BirthDate, Email, ISO_Country__c, RecordTypeId, Id, Name, Financial_Assessment_Contact__c FROM Contact WHERE Id IN :acContactIdSet])
        	{
        		emailContactMap.put(c.id, c);
        	}
        	
        	Set<Id> roleIdsToLoad = new Set<Id>();
        	for(AMS_Accreditation_Contact__c acContact : acContacts)
	        {
	        	system.debug('DTULLO 216 --> ' + acContact.Email__c);
	        	if(acContact.Email__c != null)
	        	{
	        		// update the Contact with AC's data
	        		contactsToUpdate.put(emailContactMap.get(acContact.Contact__c).Id, AMS_AccreditationContactHelper.populateNewContactFields(emailContactMap.get(acContact.Contact__c), acContact));
	        		
	        		AMS_Account_Role__c newRole;
	        		//TD: added check on owner only.
	        		system.debug('DTULLO 223 --> ' + acContact.Agency_owner__c);
	        		if(acContact.Agency_owner__c){
	        			//TD: Removed Employee from Role. Keep them on Contact object only
		        		//if(acContact.AMS_Employee_Role__c == null && acContact.AMS_Ownership_Role__c == null)
		        		system.debug('DTULLO 227 --> ' + acContact.AMS_Ownership_Role__c);
		        		if(acContact.AMS_Ownership_Role__c == null && acContact.Agency_owner__c)
		        		{
		        			// create a new AMS Account Role for the AC
			        		newRole = AMS_AccreditationContactHelper.createAmsAccountRole(acContact);
		        			newRolesToInsert.add(newRole);
		        			newRolesToInsertEmailSet.add(newRole.Contact__r.Email);
		        		} else
		        		{
		        			//roleIdstoLoad.add(acContact.AMS_Employee_Role__c);
		        			roleIdstoLoad.add(acContact.AMS_Ownership_Role__c);
		        		}
		        		
		        		if(acRoleMap.containsKey(acContact))
			            {
							acRoleMap.get(acContact).add(newRole);
						} else
						{
							acRoleMap.put(acContact, new List<AMS_Account_Role__c>{newRole});
						}
	        		}
	        	}
	        }
	        
	        Map<Id, AMS_Account_Role__c> idRoleMap = new Map<Id, AMS_Account_Role__c>();
	        if(roleIdsToLoad.size() > 0)
	        {
	        	idRoleMap = new Map<Id, AMS_Account_Role__c>([select Account__c, Duty__c, Employee_Name__c, Hours__c, IsManager__c, Owner_Account__c, Percentage__c, Position__c, Owner_Name__c, RecordTypeId from AMS_Account_Role__c where Id in :roleIdsToLoad]);
	        }
	        
	        if(idRoleMap.size() > 0)
	        {
	        	AMS_Account_Role__c toUpdateRole;
	        	for(AMS_Accreditation_Contact__c acContact : acContacts)
	        	{
	        		//TD: Removed Employee from Role. Keep them on Contact object only
	        		/*
	        			toUpdateRole = AMS_AccreditationContactHelper.updateAmsAccountRole(idRoleMap.get(acContact.AMS_Employee_Role__c), acContact);
	        			oldRolesToUpdate.add(toUpdateRole);
	        		}*/
	        		if(acContact.AMS_Ownership_Role__c != null  && !isCorrection)
	        		{
	        			if(!setAddedRoles.contains(acContact.AMS_Ownership_Role__c)){
	        				toUpdateRole = AMS_AccreditationContactHelper.updateAmsAccountRole(idRoleMap.get(acContact.AMS_Ownership_Role__c), acContact);
	        				oldRolesToUpdate.add(toUpdateRole);
	        				setAddedRoles.add(toUpdateRole.Id);
	        			}
	        		}
	        	}
	        }
	        
        }
        
        
        
        // NO LINKING TO PERSON NOR CONTACT
        if(acNoLink.size() > 0)
        {
        	newContactsToInsert.clear();
        	for(AMS_Accreditation_Contact__c ac : acNoLink)
            {
                Contact temp = AMS_AccreditationContactHelper.populateNewContactFields(new Contact(), ac);
                newContactsToInsert.put(temp.Email, temp);
            }
            
            if(newContactsToInsert.size() > 0 && !isCorrection)
	   		{
	   			List<Contact> conListToInsert = verifyNoDuplicateIFAPcontactExists(newContactsToInsert.values());
	   			System.debug(LoggingLevel.ERROR, '[LF] insert 2 : '+conListToInsert);
	   			insert conListToInsert;
	   		}
            Set<Id> roleIdsToLoad = new Set<Id>();
            for(string s:newContactsToInsert.keyset()){
	        	system.debug('DTULLO 290 --> ' + s + '; id: ' + newContactsToInsert.get(s).Id);
	        }
	        
            for(AMS_Accreditation_Contact__c ac : acNoLink)
            {
                Contact insertedContact = newContactsToInsert.get(ac.Email__c);
                system.debug('DTULLO 296 --> ' + ac.Email__c);
                acPersonIdSet.add(ac.Id);
                acPersonEmailSet.add(ac.Email__c);
                if(insertedContact != null)
                {
                    ac.Contact__c = insertedContact.Id;
                }
                
                AMS_Account_Role__c newRole;
                //TD: Removed Employee from Role. Keep them on Contact object only
        		//if(ac.AMS_Employee_Role__c == null && ac.AMS_Ownership_Role__c == null)
        		if(ac.AMS_Ownership_Role__c == null && ac.Agency_owner__c)
        		{
        			// create a new AMS Account Role for the AC
	        		newRole = AMS_AccreditationContactHelper.createAmsAccountRole(ac);
        			newRolesToInsert.add(newRole);
        			newRolesToInsertEmailSet.add(newRole.Contact__r.Email);
        		} else
        		{
        			//roleIdstoLoad.add(ac.AMS_Employee_Role__c);
        			roleIdstoLoad.add(ac.AMS_Ownership_Role__c);
        		}
        		
        		if(acRoleMap.containsKey(ac))
	            {
					acRoleMap.get(ac).add(newRole);
				} else
				{
					acRoleMap.put(ac, new List<AMS_Account_Role__c>{newRole});
				}
	        }
	        
	        Map<Id, AMS_Account_Role__c> idRoleMap = new Map<Id, AMS_Account_Role__c>();
	        if(roleIdsToLoad.size() > 0)
	        {
	        	idRoleMap = new Map<Id, AMS_Account_Role__c>([select Account__c, Duty__c, Employee_Name__c, Hours__c, IsManager__c, Owner_Account__c, Percentage__c, Position__c, Owner_Name__c, RecordTypeId from AMS_Account_Role__c where Id in :roleIdsToLoad]);
	        }
	        
	        if(idRoleMap.size() > 0)
	        {
	        	AMS_Account_Role__c toUpdateRole;
	        	for(AMS_Accreditation_Contact__c ac : acNoLink)
	        	{
	        		//TD: Removed Employee from Role. Keep them on Contact object only
	        		/*if(ac.AMS_Employee_Role__c != null)
	        		{
	        			toUpdateRole = AMS_AccreditationContactHelper.updateAmsAccountRole(idRoleMap.get(ac.AMS_Employee_Role__c), ac);
	        			oldRolesToUpdate.add(toUpdateRole);
	        		}*/
	        		if(ac.AMS_Ownership_Role__c != null && !isCorrection)
	        		{
	        			if(!setAddedRoles.contains(ac.AMS_Ownership_Role__c)){
	 		       			toUpdateRole = AMS_AccreditationContactHelper.updateAmsAccountRole(idRoleMap.get(ac.AMS_Ownership_Role__c), ac);
	        				oldRolesToUpdate.add(toUpdateRole);
	        				setAddedRoles.add(toUpdateRole.Id);
	        			}
	        		}
	        	}
	        }
		}
        
		List<AMS_Person__c> personDeletionList = [select id, Name from AMS_Person__c where id in :oldPersonsToDeleteSet];
	    if(personDeletionList.size() > 0)
	    {
	    	delete personDeletionList;
	    }
	    
	    System.debug('********** newRolesToInsert: '+newRolesToInsert);


	    for(AMS_Account_Role__c role : newRolesToInsert)
	    {
	    	//System.debug('********** before insert: '+role.Contact__c + ' - '+role.Person__c);
	    	System.debug('DTULLO 366: '+role);
	    	system.debug('DTULLO 367: role.Account__c: ' + role.Account__c + ';Owner_Account__c: ' + role.Owner_Account__c + ';Person__c: ' + role.Person__c + ';Legacy_External_ID__c: ' + role.Legacy_External_ID__c);
	    }

	    if(!isCorrection)
	    	upsert newRolesToInsert;
        
        Id ownershipRecordTypeId = AMS_Utils.getId('AMS_Account_Role__c', 'Ownership');
   		List<AMS_Accreditation_Contact__c> acToUpdateList = new List<AMS_Accreditation_Contact__c>();
   		for(AMS_Accreditation_Contact__c ac : acRoleMap.keySet())
   		{
   			//TD: Removed Employee from Role. Keep them on Contact object only
   			//if(ac.AMS_Ownership_Role__c == null && ac.AMS_Employee_Role__c == null)
   			if(ac.AMS_Ownership_Role__c == null && !isCorrection)
   			{
	   			boolean toUpdate = false;
	   			List<AMS_Account_Role__c> roleList = acRoleMap.get(ac);
	   			//TD: Removed Employee from Role. Keep them on Contact object only
	   			system.debug('DTULLO roleList.size() --> ' + roleList.size());
	   			system.debug('DTULLO ownershipRecordTypeId --> ' + ownershipRecordTypeId);
	   			if(!roleList.isEmpty())
	   			{
		   			for(AMS_Account_Role__c role : roleList)
		   			{
		   				//dunno why, but if the size was 1, was trying to access the 2nd item... added this check to avoid nullpointer exception
		   				if(role != null)
		   				{
			   				system.debug('DTULLO role --> ' + role);
			   				system.debug('DTULLO role.RecordTypeId --> ' + role.RecordTypeId);
			   				if(role.RecordTypeId == ownershipRecordTypeId)
				   			{
				   				ac.AMS_Ownership_Role__c = role.Id;
				   				toUpdate = true;
				   			}
				   			//TD: Removed Employee from Role. Keep them on Contact object only
				   			 /*else
				   			{
				   				ac.AMS_Employee_Role__c = role.Id;
				   				toUpdate = true;
				   			}*/
				   		}
		   			}
		   		}
		   		
		   		//TD: Added because we moved the employee from the account role object. We need to update the accrediation contact to save the contact id just created
		   		if(!ac.Agency_owner__c || ac.Agency_owner__c==null){
		   			toUpdate = true;
		   		}
		   		system.debug('DTULLO 403. toUpdate? ' + toUpdate);
	   			if(toUpdate)
	   			{
	   				acToUpdateList.add(ac);
	   			}
   			}
   			
   			
   		}
   		
   		System.debug('*********** acToUpdateList: '+acToUpdateList);
   		if(acToUpdateList.size() > 0)
   		{
   			update acToUpdateList;
   		}
   		
   		System.debug('*********** contactUpdateList: '+contactsToUpdate.values());
   		System.debug('*********** oldRolesToUpdate: '+oldRolesToUpdate);
   		if(oldRolesToUpdate.size() > 0)
   		{
   			update oldRolesToUpdate;
   		}
   		
    	/** !! NOTE: This second step handles Account Ownership only! !! */
    	if(!isCorrection)
    		insertAccountOwnershipsForAccreditationOnline(aoaList);
    	
    	
    	// Because Contact's might have validation rules that prevent Contact updates, and the business requirement
    	// is to push everything that can be pushed, we should update the Contacts last.
    	if(contactsToUpdate.size() > 0)
   		{
   			List<Contact> conListToUpdate = verifyNoDuplicateIFAPcontactExists(contactsToUpdate.values());
   			update conListToUpdate;
   		}
    }

    private static String createContactRecordTypes(List<String> types){
    	String toReturn = '';

    	for(String tp: types)
    		toReturn += '\'' + AMS_Utils.getId('AMS_Accreditation_Contact__c', tp) + '\'' + ',';
    
    	return toReturn.removeEnd(',');
    }
    
    private static List<Contact> verifyNoDuplicateIFAPcontactExists(List<Contact> conList)
    {
    	Set<Id> accountIds = new Set<Id>();
    	Set<Id> contactIds = new Set<Id>();
    	
		for(Contact con : conList)
    	{
    		accountIds.add(con.AccountId);
    		contactIds.add(con.Id);
    	}
    	system.debug('verifyNoDuplicateIFAPcontactExists() --> accountIds'+accountIds);
    			
    	Set<Id> accsWithExistingIFAPcontact = new Set<Id>();
    	Set<Id> accsWithNotAllowedLocationClass = new Set<Id>();
    	List<Contact> accountContacts = [select Name, Financial_Assessment_Contact__c, AccountId, Account.Location_Class__c 
    	from Contact 
    	where AccountId in :accountIds /*and Id not in :contactIds*/];
    	for(Contact otherCon : accountContacts)
    	{
    		system.debug('verifyNoDuplicateIFAPcontactExists() --> otherCon = '+otherCon);
    		if(!AMS_Utils.LocationClassIFAPAllowed.contains(otherCon.Account.Location_Class__c))
			{
				accsWithNotAllowedLocationClass.add(otherCon.AccountId);
				system.debug('verifyNoDuplicateIFAPcontactExists() --> '+otherCon.Name+' belongs to a '+otherCon.Account.Location_Class__c);
			}
			else if(otherCon.Financial_Assessment_Contact__c)
    		{
    			accsWithExistingIFAPcontact.add(otherCon.AccountId);
    		}
    	}
    	system.debug('verifyNoDuplicateIFAPcontactExists() --> accsWithExistingIFAPcontact = '+accsWithExistingIFAPcontact+' accsWithNotAllowedLocationClass '+accsWithNotAllowedLocationClass);
    	if(accsWithExistingIFAPcontact.size() > 0 || accsWithNotAllowedLocationClass.size()>0)
    	{
    		for(Contact con : conList)
    		{
    			// LF: if this contact is the one to be pushed to MD I check the location class of his account. If it does not support IFAP contacts, I'll reset the flag
    			system.debug('verifyNoDuplicateIFAPcontactExists() --> contactIds.contains('+con.Name+') = '+contactIds.contains(con.Id)+' IFAP Contact = '+con.Financial_Assessment_Contact__c+'- Location Class = '+con.Account.Location_Class__c);
    			if(accsWithExistingIFAPcontact.contains(con.AccountId) || accsWithNotAllowedLocationClass.contains(con.AccountId))
    			{
    				con.Financial_Assessment_Contact__c = false;
    			}
    		}
    	}
    	system.debug('verifyNoDuplicateIFAPcontactExists() --> conList = '+conList);
    	return conList;
    }
    

	public static void insertAccountOwnershipsForAccreditationOnline(List<AMS_Pax_Accreditation_Form__c> aoaList)
    {
    	AMS_AccountRoleCreator.aoaIdSet = new Set<String>();
    	for(AMS_Pax_Accreditation_Form__c aoa : aoaList)
    	{
    		aoaIdSet.add(aoa.Id);
    	}
    	insertAccountOwnershipsForAccreditationOnline(aoaIdSet);
    }
    public static void insertAccountOwnershipsForAccreditationOnline(Set<String> aoaIds)
    {
    	/** !! NOTE: This second step handles Account Ownership only! !! */
    	
    	List<AMS_Account_Role__c> oldRolesToUpdate = new List<AMS_Account_Role__c>();
    	Map<Id, AMS_Account_Role__c> acNewRoleMap = new Map<Id, AMS_Account_Role__c>(); 
    	AMS_AccountRoleCreator.aoaIdSet = aoaIds;

    	String commaSeparatedFields = AMS_AccreditationContactHelper.loadFieldsDynamically('AMS_Accreditation_Contact__c');

        String query = 'select ' + commaSeparatedFields + ', AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c, Company__r.Id, Company__r.Name ';
        query = query + ' from AMS_Accreditation_Contact__c where AMS_Pax_Accreditation_Form__c in :ABC and RecordTypeId in ';
        query = query + '(' + recordTypesCompany +')';

		List<AMS_Accreditation_Contact__c> acList = retrieveACsDynamically(query, 'aoaIdSet');
		
		String accountId = '';
		if(acList.size() > 0)
		{
			accountId = acList.get(0).AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c;
		}
		
		Map<Id, AMS_Account_Role__c> idRoleMap = new Map<Id, AMS_Account_Role__c>();
        if(accountId != '')
        {
        	idRoleMap = new Map<Id, AMS_Account_Role__c>();
        	List<AMS_Account_Role__c> roleListing = [select Account__c, Owner_Account__c, Percentage__c, RecordTypeId from AMS_Account_Role__c where Account__c = :accountId and RecordTypeId = :AMS_Utils.getId('AMS_Account_Role__c', 'Ownership')];
        	for(AMS_Account_Role__c role : roleListing)
        	{
        		idRoleMap.put(role.Owner_Account__c, role);
        	}
        }
		else
		{
        	return;
        }
        
        
    	AMS_Account_Role__c toUpdateRole;
    	for(AMS_Accreditation_Contact__c ac : acList)
    	{
    		if(ac.AMS_Ownership_Role__c != null)
    		{
    			if(idRoleMap.get(ac.Company__c) != null)
    			{
    				toUpdateRole = AMS_AccreditationContactHelper.updateAmsRoleForAccount(idRoleMap.get(ac.Company__c), ac);
    				oldRolesToUpdate.add(toUpdateRole);
    				System.debug('CHECK ROLE 1: ' + toUpdateRole);
    			}
    		}
    		else
    		{
    			System.debug('ACCREDITATION CONTACT COMPANY: ' + ac.Company__c);
    			AMS_Account_Role__c newRole = AMS_AccreditationContactHelper.createAmsRoleForAccount(ac);
    			if(newRole != null){
	    			oldRolesToUpdate.add(newRole);
	    			acNewRoleMap.put(ac.Id, newRole);
	    			System.debug('CHECK ROLE 2: ' + newRole);
    			}
    		}
    	}

		if(oldRolesToUpdate.size() > 0)
   		{
   			for(AMS_Account_Role__c role: oldRolesToUpdate){
   				System.debug('CHECK ROLE 3: ' + role);
   			}
   			upsert oldRolesToUpdate;
   		}
		
		
		List<AMS_Accreditation_Contact__c> acsToUpdate = new List<AMS_Accreditation_Contact__c>();
		if(acNewRoleMap.size() > 0)
		{
			for(AMS_Accreditation_Contact__c ac : acList)
			{
				if(acNewRoleMap.get(ac.Id) != null)
				{
					ac.AMS_Ownership_Role__c = acNewRoleMap.get(ac.Id).Id;
					acsToUpdate.add(ac);
				}
			}
			
			update acsToUpdate;
		}
    }

    public static void insertAccountOwnershipsForAccreditationOnlineCorrections(Map<Id,Set<Id>> aoMap, Map<Id,List<AMS_Accreditation_Contact__c>> aoToAcList, Map<Id, Set<AMS_Account_Role__c>> rolesPerAccount)
    {
    	/** !! NOTE: This second step handles Account Ownership only! !! */
    	
    	List<AMS_Account_Role__c> oldRolesToUpdate = new List<AMS_Account_Role__c>();
    	Map<Id, AMS_Account_Role__c> acNewRoleMap = new Map<Id, AMS_Account_Role__c>();

        AMS_Account_Role__c toUpdateRole;
		for(Id aoId : aoToAcList.keySet()){
     		for(AMS_Accreditation_Contact__c ac: aoToAcList.get(aoId)){
     			//Process only account owners
     			if(ac.RecordTypeId == AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Company') || ac.RecordTypeId == AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Current_Company_Owner')){

     				System.debug('MACDEBUG ACCREDITATION CONTACT COMPANY: ' + ac.Company__c);
			    	if(ac.AMS_Ownership_Role__c != null){
			    		System.debug('MACDEBUG OWNERSHIP FILLED');
			    		for(Id accountId : aoMap.get(ac.AMS_Pax_Accreditation_Form__c)){
				    		//need to update existing owners related to this company
				    		//find matching role in account
					    	Set<AMS_Account_Role__c> rolesToSearch = rolesPerAccount.get(accountId);
					    	if(rolesToSearch != null){

					    		System.debug('MACDEBUG COR ROLES TO SEARCH: ' +  rolesToSearch);
						    	for(AMS_Account_Role__c compareRole: rolesToSearch){
						    		if(ac.Company__c == compareRole.Owner_Account__c)
						    		{
						    			Id oldAccountId = compareRole.Account__c;
						    			toUpdateRole = AMS_AccreditationContactHelper.updateAmsRoleForAccount(compareRole, ac);
						    			toUpdateRole.Account__c = oldAccountId;
						    			oldRolesToUpdate.add(toUpdateRole);
						    			System.debug('CHECK ROLE 1: ' + toUpdateRole);
					    			}
						    	}
			    			}
	    				}

			    	}
			    	else{
			    		System.debug('MACDEBUG OWNERSHIP NOT FILLED');
			    		for(Id accountId : aoMap.get(ac.AMS_Pax_Accreditation_Form__c)){
				    		//need to create new owners for all hierarchy
				    		System.debug('ACCREDITATION CONTACT COMPANY: ' + ac.Company__c);
		    				AMS_Account_Role__c newRole = AMS_AccreditationContactHelper.createAmsRoleForAccount(ac);
		    				if(newRole != null){
		    					newRole.Account__c = accountId;
				    			oldRolesToUpdate.add(newRole);
				    			//acNewRoleMap.put(ac.Id, newRole);
				    			System.debug('CHECK ROLE 2: ' + newRole);
		    				}
		    			}

			    	}
			    }
		    }
		}

		if(oldRolesToUpdate.size() > 0)
   		{
   			for(AMS_Account_Role__c role: oldRolesToUpdate){
   				System.debug('CHECK ROLE 3: ' + role);
   			}
   			upsert oldRolesToUpdate;
   		}
		
		
		/*List<AMS_Accreditation_Contact__c> acsToUpdate = new List<AMS_Accreditation_Contact__c>();
		if(acNewRoleMap.size() > 0)
		{
			for(AMS_Accreditation_Contact__c ac : acList)
			{
				if(acNewRoleMap.get(ac.Id) != null)
				{
					ac.AMS_Ownership_Role__c = acNewRoleMap.get(ac.Id).Id;
					acsToUpdate.add(ac);
				}
			}
			
			update acsToUpdate;
		}*/
    }
    
    public static List<AMS_Accreditation_Contact__c> getPersonLinkingOnly(List<AMS_Accreditation_Contact__c> acListing)
    {
    	List<AMS_Accreditation_Contact__c> returnList = new List<AMS_Accreditation_Contact__c>();
    	for(AMS_Accreditation_Contact__c ac : acListing)
    	{
    		if(ac.Person_AMS__c != null && ac.Person_AMS__r.Contact__c == null)
    		{
    			returnList.add(ac);
    		}
    	}
    	return returnList;
    }
    
    public static List<AMS_Accreditation_Contact__c> getContactLinking(List<AMS_Accreditation_Contact__c> acListing)
    {
    	List<AMS_Accreditation_Contact__c> returnList = new List<AMS_Accreditation_Contact__c>();
    	for(AMS_Accreditation_Contact__c ac : acListing)
    	{
    		if(ac.Contact__c != null || (ac.Person_AMS__c != null && ac.Person_AMS__r.Contact__c != null))
    		{
    			returnList.add(ac);
    		}
    	}
    	return returnList;
    }
    
    public static List<AMS_Accreditation_Contact__c> getNoPersonNorContactLing(List<AMS_Accreditation_Contact__c> acListing)
    {
    	List<AMS_Accreditation_Contact__c> returnList = new List<AMS_Accreditation_Contact__c>();
    	for(AMS_Accreditation_Contact__c ac : acListing)
    	{
    		if(ac.Person_AMS__c == null && ac.Contact__c == null)
    		{
    			returnList.add(ac);
    		}
    	}
    	return returnList;
    }
    
    // For all the current Accreditation Contacts, assume the email uniqueness will provide either
    // one or zero AMS Account Role records.
    public static Map<String, AMS_Account_Role__c> findRoleAndPersonRecords(List<AMS_Accreditation_Contact__c> acList)
    {
        Set<String> acEmailSet = new Set<String>();
        Set<Id> acPersonSet = new Set<Id>();
        
        for(AMS_Accreditation_Contact__c ac : acList)
        {
            if(ac.Person_AMS__c != null)
            {
                acPersonSet.add(ac.Person_AMS__c);
            }
            acEmailSet.add(ac.Email__c);
        }
        
        return AMS_AccreditationContactHelper.findRolesAndPersonsByEmail(acEmailSet, acPersonSet);
    }
    
    // Find Role and Contact records without the Person linking
    public static Map<String, AMS_Account_Role__c> findRoleAndContactRecords(List<AMS_Accreditation_Contact__c> acList)
    {
        Set<String> acEmailSet = new Set<String>();
        Set<Id> acContactSet = new Set<Id>();
        
        for(AMS_Accreditation_Contact__c ac : acList)
        {
            if(ac.Contact__c != null)
            {
                acContactSet.add(ac.Contact__c);
            }
            acEmailSet.add(ac.Email__c);
        }
        
        system.debug('DTULLO 669 --> ' + acEmailSet);
        system.debug('DTULLO 669 --> ' + acContactSet);
        return AMS_AccreditationContactHelper.findRolesAndContactsByEmail(acEmailSet, acContactSet);
    }
    
    
    public static List<Contact> transformACsWithPersonLinking_createContactList(List<AMS_Accreditation_Contact__c> acList, Map<String, AMS_Account_Role__c> emailAccountRoleMap)
    {
    	if(emailAccountRoleMap == null)
    	{
    		emailAccountRoleMap = new Map<String, AMS_Account_Role__c>();
    	}
    	
    	List<AMS_Accreditation_Contact__c> ACsToContactsList = new List<AMS_Accreditation_Contact__c>();
    	for(AMS_Accreditation_Contact__c ac : acList)
        {
            // if the map contains the email, we know Account Role and AMS Person exists and the values should be converted into Contact records
            if(emailAccountRoleMap.get(ac.Email__c) != null)
            {
                ACsToContactsList.add(ac);
            }
        }
        
        if(ACsToContactsList.size() > 0)
        {
        	return transformAClist_intoContactList(ACsToContactsList, new Map<Id, Contact>());
        }
        
        return null;
    }
	
    public static List<Contact> transformAClist_intoContactList(List<AMS_Accreditation_Contact__c> ACsToContactsList, Map<Id, Contact> acIdContactMap)
    {
        List<Contact> newContacts = new List<Contact>();
        Contact newCon;
        for(AMS_Accreditation_Contact__c ac : ACsToContactsList)
        {
            if(acIdContactMap.size() == 0)
            {
            	newCon = new Contact();
            } else
            {
            	newCon = acIdContactMap.get(ac.Id);
            }

            newCon.FirstName = ac.First_name__c;
            newCon.LastName = ac.Last_name__c;
            newCon.Title = ac.Job_title__c;
            newCon.AccountId = ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c;
            newCon.Membership_Main_Contact__c = ac.Membership_Main_Contact__c;
            newCon.MailingCountry = ac.AddressCountry__c;
            newCon.MailingState = ac.Mailing_State__c;
            newCon.MailingStreet = ac.AddressStreet__c;
            newCon.MailingCity = ac.AddressCity__c;
            newCon.MailingPostalCode = ac.AddressPostcode__c;
            newCon.Phone = ac.Phone__c;
            newCon.MobilePhone = ac.Mobile__c;
            newCon.Fax = ac.FAX__c;
            newCon.Birthdate = ac.Birthdate__c;
            newCon.Email = ac.Email__c;
            newCon.ISO_Country__c = ac.ISO_Country__c;
            //newCon.Authorized Signatory = ac.Authorised_signatory__c;
            newCon.Financial_Assessment_Contact__c = ac.Financial_Assessment_Contact__c;
            //newCon.Designated Portal Admin = ac. ???
            newCon.Training_dangerous_goods_completed__c = ac.Training_dangerous_goods_completed__c;
  		  	newCon.list_Dangerous_Goods_Awareness__c = ac.list_Dangerous_Goods_Awareness__c;
            
            newCon.RecordTypeId = AMS_Utils.getId('Contact', 'Standard_Contact');
            newContacts.add(newCon);
        }
        return newContacts;
    }
    
    public static List<Contact> transformACsWithContactLinkingToUpdatedList(List<AMS_Accreditation_Contact__c> acList, Map<String, AMS_Account_Role__c> emailAccountRoleContactsOnlyMap)
    {
        List<AMS_Accreditation_Contact__c> contactsToUpdateWithAcDataList = new List<AMS_Accreditation_Contact__c>();
        
        // This map is used to pass the accreditationContact and Contact map to mapAndInsertContactsToBeCreatedWithACdetails,
        // so that the method knows to update an existing record instead of simply creating new Contacts
        Map<Id, Contact> acIdContactMap = new Map<Id, Contact>();
        Map<Id, Id> contactIdAcIdMap = new Map<Id, Id>();
        
        for(AMS_Accreditation_Contact__c ac : acList)
        {
            // if the map contains the email, we know Account Role and Person linking does not exist, but Contact does, so the 
            // Contact should be updated with AC data
            if(emailAccountRoleContactsOnlyMap.get(ac.Email__c) != null)
            {
            	contactsToUpdateWithAcDataList.add(ac);
            	contactIdAcIdMap.put(ac.Contact__c, ac.Id);
            }
        }
        
        List<Contact> contactList = [select Id, FirstName, LastName, Title, AccountId, Membership_Main_Contact__c, MailingCountry, MailingState,
    					MailingStreet, MailingCity, MailingPostalCode, Phone, list_Dangerous_Goods_Awareness__c, Training_dangerous_goods_completed__c, Mobilephone, Fax, Birthdate, Email, ISO_Country__c, RecordTypeId, Financial_Assessment_Contact__c
    					from Contact where Id in :contactIdAcIdMap.keySet()];
    	
    	for(Contact con : contactList)
    	{
    		acIdContactMap.put(contactIdAcIdMap.get(con.Id), con);
    	}
    	
        if(contactsToUpdateWithAcDataList.size() > 0)
        {
        	return transformAClist_intoContactList(contactsToUpdateWithAcDataList, acIdContactMap);
        }
        
        return null;
    }
    
    
    public static List<AMS_Account_Role__c> retrieveContactAgencyLinking_updateIfNecessary(List<Contact> newContacts, Map<String, AMS_Account_Role__c> emailAccountRoleMap)
    {
        List<AMS_Account_Role__c> arUpdateList = new List<AMS_Account_Role__c>();
        
        for(Contact con : newContacts)
        {
            AMS_Account_Role__c ar = emailAccountRoleMap.get(con.Email);
            if(ar.Person__c != null)
            {
                ar.Contact__c = con.Id;
                emailAccountRoleMap.remove(con.Email);
                arUpdateList.add(ar);
            }
        }
        update arUpdateList;

        return arUpdateList;
    }

    public static void runRoleCreatorForOnlineAccreditations(Map<Id,Set<Id>> aoMap){
    	runRoleCreatorForOnlineAccreditations(aoMap, false);
    }

    // This is a clone of the method runRoleCreatorForOnlineAccreditations(List<AMS_Pax_Accreditation_Form__c> aoaList)
    // This version will apply an online accreditation to several accounts
    public static void runRoleCreatorForOnlineAccreditations(Map<Id,Set<Id>> aoMap, boolean isCorrectionProcess){

    	if(true){
    		System.debug('DNG: here goes nothing...');

    		//throw new AMS_ApplicationException('entering with isCorrection:' + isCorrectionProcess);

    		runRoleCreatorForOnlineAccreditationsDNG(aoMap,isCorrectionProcess);
    		System.debug('DNG: all done...');
    		return;
    	}

    	Set<Id> acContactIdSet = new Set<Id>();
    	
    	// STEP 1) I have to build a map: accreditation online -> acs
    	Map<Id,List<AMS_Accreditation_Contact__c>> aoToAcList = new Map<Id,List<AMS_Accreditation_Contact__c>>();
    	Map<Id,AMS_Accreditation_Contact__c> idToAc = new Map<Id,AMS_Accreditation_Contact__c>();
    	Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();

    	Set<Id> aoIds = aoMap.keyset();
    	system.debug('runRoleCreatorForOnlineAccreditations() -> STEP 1) aoMap '+aoMap);

    	
    	String commaSeparatedFields = AMS_AccreditationContactHelper.loadFieldsDynamically('AMS_Accreditation_Contact__c');
        String query = 'SELECT ' + commaSeparatedFields + ', AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c, AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Process__c, Person_AMS__r.Contact__c, RecordType.DeveloperName, AMS_Ownership_Role__r.Duty__c, AMS_Ownership_Role__r.Hours__c, AMS_Ownership_Role__r.IsManager__c, AMS_Ownership_Role__r.Percentage__c, AMS_Ownership_Role__r.Position__c, AMS_Ownership_Role__r.Owner_Account__c';
        query = query + ' FROM AMS_Accreditation_Contact__c WHERE AMS_Pax_Accreditation_Form__c IN :aoIds AND (RecordTypeId in ';
        query = query + '(' + recordTypesPerson +' ) ';
        query = query + ' OR RecordTypeId in ';
        query = query + '(' + recordTypesCompany+' ) ' + ')';
        

    	system.debug('DTULLO 826 --> Query: ' + Query);
    	system.debug('DTULLO 826 --> aoMap.keyset() : ' + aoMap.keyset());
        String rolequery = '';

		Set<AMS_AccountRoleCreator.RoleBundle> contactsAndPersons = new Set<AMS_AccountRoleCreator.RoleBundle>();

        List<AMS_Accreditation_Contact__c> acsInAos = database.query(query);
        for(AMS_Accreditation_Contact__c ac :acsInAos){

        	if(ac.Contact__c!=null)
        		acContactIdSet.add(ac.Contact__c);

        	idToAc.put(ac.Id,ac);

        	if(!aoToAcList.containsKey(ac.AMS_Pax_Accreditation_Form__c))
        		aoToAcList.put(ac.AMS_Pax_Accreditation_Form__c, new List<AMS_Accreditation_Contact__c>());
        	aoToAcList.get(ac.AMS_Pax_Accreditation_Form__c).add(ac);

        	Id aoId = ac.AMS_Pax_Accreditation_Form__c;

        	if(aoMap.get(aoId)!=null){
 	        	for(Id accId : aoMap.get(aoId)){
 	        		
 	        		if(personDeveloperName.containsKey(ac.RecordType.DeveloperName) && ac.Contact__c != null){
						
						contactsAndPersons.add(new AMS_AccountRoleCreator.RoleBundle(accId, ac.Contact__c, 'C'));

	        		}
	        		else if(personDeveloperName.containsKey(ac.RecordType.DeveloperName) && ac.Person_AMS__c != null){

	        			contactsAndPersons.add(new AMS_AccountRoleCreator.RoleBundle(accId, ac.Person_AMS__c, 'P'));

	        		}
	        		else if(companyDeveloperName.containsKey(ac.RecordType.DeveloperName) && ac.Company__c != null){

						contactsAndPersons.add(new AMS_AccountRoleCreator.RoleBundle(accId, ac.Company__c, 'A'));

	        		}
	        	}
			}

        }

        Map<String, Contact> emailContactMap = new Map<String, Contact>();
        for(Contact c : [SELECT FirstName, LastName, Title, AccountId, Membership_Main_Contact__c, Training_dangerous_goods_completed__c, list_Dangerous_Goods_Awareness__c, Phone, MobilePhone, Fax, BirthDate, Email, ISO_Country__c, RecordTypeId, Id, Name, Financial_Assessment_Contact__c FROM Contact WHERE Id IN :acContactIdSet])
        	emailContactMap.put(c.id, c);

        system.debug('runRoleCreatorForOnlineAccreditations() -> STEP 1) aoToAcList '+aoToAcList);

    	// STEP 2) I have to build a map accreditation contact -> roles
    	Map<Id, List<AMS_Account_Role__c>> acToRoles = new Map<Id, List<AMS_Account_Role__c>>();

    	Map<Id, Set<AMS_Account_Role__c>> rolesPerAccount = new Map<Id, Set<AMS_Account_Role__c>>();

    	for(AMS_Accreditation_Contact__c ac : idToAc.values()){
    		acToRoles.put(ac.Id, new List<AMS_Account_Role__c>());
    	}

		List<AMS_Account_Role__c> rolesToQuery = new List<AMS_Account_Role__c>();

    	rolesToQuery = fetchAccountRolesToQuery(aoIds,contactsAndPersons);

    	for(AMS_Account_Role__c r : rolesToQuery){
    		
    		system.debug('CORRECTION PROCESS ROLE START: '+ r);

    		for(AMS_Accreditation_Contact__c ac : idToAc.values()){

    			Set<Id> myAccounts = aoMap.get(ac.AMS_Pax_Accreditation_Form__c);
    			system.debug('CORRECTION PROCESS ACCOUNT TO PROCESS: ' + myAccounts);
    			system.debug('ROLE DEBUG AC: ' + ac);
    			if(myAccounts.contains(r.Account__c)){
    				system.debug('ROLE DEBUG ROLE: ' + r);
	    			if((personDeveloperName.containsKey(ac.RecordType.DeveloperName) && r.Contact__c==ac.Contact__c && r.Person__c==ac.Person_AMS__c ) || 
	    				(companyDeveloperName.containsKey(ac.RecordType.DeveloperName)  && r.Owner_Account__c==ac.Company__c)){
		    			if(acToRoles.get(ac.Id)==null)
		    				acToRoles.put(ac.Id, new List<AMS_Account_Role__c>());
		    			acToRoles.get(ac.Id).add(r);
		    		}
	    		}

	    		if(isCorrectionProcess){
					system.debug('CORRECTION PROCESS  FILL ROLES PER ACCOUNT MAP');
					system.debug('CORRECTION PROCESSING ROLE: ' + r);
			    	
			    	if(rolesPerAccount.get(r.Account__c)==null)
			    		rolesPerAccount.put(r.Account__c, new Set<AMS_Account_Role__c>());
			    	rolesPerAccount.get(r.Account__c).add(r);
		    	}	
    		}	    				

    		system.debug('CORRECTION PROCESS  ROLES PER ACCOUNT MAP: ' + rolesPerAccount);

    	}
    	
    	system.debug('runRoleCreatorForOnlineAccreditations() -> STEP 2) acToRoles '+acToRoles);
    	

    	// STEP 3) go through all the acs
    	// if they have not a contact
    	// --> create a contact
    	// --> update the accreditation contacts with the link to the contacts
    	// --> delete the person


    	Map<String, Contact> newContactsToInsert = new Map<String, Contact>();

    	Map<Id, String> personsToContactEmail = new Map<Id, String>();

    	for(Id aoId : aoToAcList.keySet()){
     		for(AMS_Accreditation_Contact__c ac: aoToAcList.get(aoId)){
     			system.debug('runRoleCreatorForOnlineAccreditations() -> STEP 3) check ac '+ac.First_name__c+' '+ ac.Last_name__c);
				if( personDeveloperName.containsKey(ac.RecordType.DeveloperName) &&
				   ((ac.Person_AMS__c != null && ac.Person_AMS__r.Contact__c == null) ||
				   (ac.Person_AMS__c == null && ac.Contact__c == null))){
		        	
		        	system.debug('runRoleCreatorForOnlineAccreditations() -> STEP 3) ac '+ac.First_name__c+' '+ ac.Last_name__c+' --> Need to create a contact');
		        	
		        	Contact temp = AMS_AccreditationContactHelper.populateNewContactFields(new Contact(), ac);
		        	newContactsToInsert.put(temp.Email, temp);

		        	if(ac.Person_AMS__c != null)
		        		personsToContactEmail.put(ac.Person_AMS__c, temp.email);
	        	
	        	}else if(personDeveloperName.containsKey(ac.RecordType.DeveloperName) &&
	        		 ((ac.Person_AMS__c != null && ac.Person_AMS__r.Contact__c != null) ||
				     (ac.Person_AMS__c == null && ac.Contact__c != null))){
	        	
	        		system.debug('runRoleCreatorForOnlineAccreditations() -> STEP 3) ac '+ac.First_name__c+' '+ ac.Last_name__c +'--> Will update existing contact');

	        		Id existingContactId = ac.Person_AMS__c==null ? ac.Contact__c : ac.Person_AMS__r.Contact__c;

		        	contactsToUpdate.put(existingContactId, AMS_AccreditationContactHelper.populateNewContactFields(emailContactMap.get(ac.Contact__c), ac));

		        	system.debug('MACDEBUG: Contacts to update '+ contactsToUpdate);
		        }
	        
    		}
    	}

    	system.debug('runRoleCreatorForOnlineAccreditations() -> STEP 3) insert contacts  '+newContactsToInsert);

    	if(newContactsToInsert.size() > 0){
   			insert verifyNoDuplicateIFAPcontactExists(newContactsToInsert.values());
   		}

   		for(Id aoId : aoToAcList.keySet()){
     		for(AMS_Accreditation_Contact__c ac: aoToAcList.get(aoId)){
     			if(personDeveloperName.containsKey(ac.RecordType.DeveloperName) && ac.Contact__c == null){
     				String myContactEmail = ac.Email__c;//personsToContactEmail.get(ac.Person_AMS__c);
     				Id myContactId = newContactsToInsert.get(myContactEmail).Id;
     				ac.Contact__c = myContactId;
     				ac.Person_AMS__c = null;

     				system.debug('runRoleCreatorForOnlineAccreditations() -> STEP 3) ac.Name = '+ac.First_name__c+' --> annullo il person e scrivo contact = '+ac.Contact__c);

     			}
 			}
     	}


     	system.debug('runRoleCreatorForOnlineAccreditations() -> STEP 3) delete persons  '+personsToContactEmail);
   		if(personsToContactEmail.size() > 0)
   			database.delete([SELECT id FROM AMS_Person__c WHERE id in :personsToContactEmail.keySet()]);


    	// STEP 4) process the account roles
    	// --> if the ac has a link to a role it means the roles are already the new ones so I just update them
    	// --> otherwise I deactivate the old roles, create the new ones and update the ac
    	List<AMS_Account_Role__c> rolesToUpdate = new List<AMS_Account_Role__c>();
    	Map<String,AMS_Account_Role__c> rolesToInsert = new Map<String,AMS_Account_Role__c>();
    	Set<Id> accountIdsToDeactivateRoles = new Set<Id>();

    	if(isCorrectionProcess){
    		for(Id aoId : aoToAcList.keySet()){
     			for(AMS_Accreditation_Contact__c ac: aoToAcList.get(aoId)){
     				//process contact owners only
     				if(ac.Agency_owner__c == true && ac.RecordTypeId != AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Company') && ac.RecordTypeId != AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Current_Company_Owner')){
			    		if(ac.AMS_Ownership_Role__c != null){
				    		system.debug('COR ac '+ac.First_name__c+' '+ac.Last_name__c+' (Owner ? '+ac.Agency_owner__c+')---> CASE B');
						 	system.debug('COR ac has account owner = '+ac.Company__c+' ---> CASE B');

						    //if(ac.Agency_owner__c == true && ac.RecordTypeId != AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Company') && ac.RecordTypeId != AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Current_Company_Owner')){
						    	//find matching roles in all hierarchy accounts and update them
						    	for(Id accountId : aoMap.get(ac.AMS_Pax_Accreditation_Form__c)){
						    		System.debug('COR sweeping accounts... current id: ' + accountId);
						    		//find matching role in account
						    		Set<AMS_Account_Role__c> rolesToSearch = rolesPerAccount.get(accountId);
						    		if(rolesToSearch != null){

						    			System.debug('COR ROLES TO SEARCH: ' +  rolesToSearch);
							    		for(AMS_Account_Role__c compareRole: rolesToSearch){
							    					
							    			/*if(compareRole.Duty__c 		== ac.AMS_Ownership_Role__r.Duty__c &&
											compareRole.Hours__c 		== ac.AMS_Ownership_Role__r.Hours__c &&
											compareRole.IsManager__c 	== ac.AMS_Ownership_Role__r.IsManager__c &&
											compareRole.Percentage__c 	== ac.AMS_Ownership_Role__r.Percentage__c &&
											compareRole.Position__c 	== ac.AMS_Ownership_Role__r.Position__c &&
											compareRole.Owner_Account__c 	== null){*/
											if(compareRole.Contact__c == ac.Contact__c){
												System.debug('COR FOUND A MATCHING ROLE!!!');
												Id oldAccountId = compareRole.Account__c;
												compareRole = AMS_AccreditationContactHelper.updateAmsAccountRole(compareRole, ac);
												compareRole.Account__c = oldAccountId;
												System.debug('COR ADDING ROLE TO LIST ' + compareRole);
												System.debug('COR ADDING ROLE TO LIST ac '+ac.First_name__c+' '+ac.Last_name__c+' (Owner ? '+ac.Agency_owner__c);
												System.debug('COR ADDING ROLE TO LIST account ' + accountId);
												rolesToUpdate.add(compareRole);
											}
							    		}
							   		}
							  	}
					   		//}
			    		}
			    		else{
			    			system.debug('runRoleCreatorForOnlineAccreditations() -> STEP 4) ac '+ac.First_name__c+' '+ac.Last_name__c+' (Owner ? '+ac.Agency_owner__c+')---> CASE B');
				    		system.debug('runRoleCreatorForOnlineAccreditations() -> STEP 4) ac has account owner = '+ac.Company__c+' ---> CASE B');

			    			for(Id accountId : aoMap.get(ac.AMS_Pax_Accreditation_Form__c)){
			    				System.debug('runRoleCreatorForOnlineAccreditations() sweeping accounts... current id: ' + accountId);
				    			AMS_Account_Role__c newRole = AMS_AccreditationContactHelper.createAmsAccountRole(ac);
				    			newRole.Account__c = accountId;
				    			System.debug('runRoleCreatorForOnlineAccreditations() new role: ' + newRole);
				    			rolesToInsert.put(newRole.Account__c+'-'+newRole.Contact__c+'-'+newRole.Owner_Account__c,newRole);
				    		}
			    		}
			    	}
		    	}
		    }
    	}else{
	    	for(Id acId : acToRoles.keySet()){
	    		AMS_Accreditation_Contact__c ac = idToAc.get(acId);
	    		system.debug('CHECK runRoleCreatorForOnlineAccreditations() -> STEP 4) ac '+ac.First_name__c+' '+ac.Last_name__c+' ---> TO DECIDE BASED ON '+ac.AMS_Ownership_Role__c);


	    		// CASE A) update existing roles
	    		if(ac.AMS_Ownership_Role__c != null){
	    			
		    		system.debug('runRoleCreatorForOnlineAccreditations() -> STEP 4) ac '+ac.First_name__c+' '+ac.Last_name__c+' ---> CASE A');
		    		system.debug('CHECKPOINT: Accreditation Contact HAS a link to an existing account role-> ' + ac);
		    		for(AMS_Account_Role__c role : acToRoles.get(acId)){
		    			Id oldAccountId = role.Account__c;
		    			role = AMS_AccreditationContactHelper.updateAmsAccountRole(role, ac);
		    			role.Account__c = oldAccountId;
		        		rolesToUpdate.add(role);

			    	}
		    	
		    	// CASE B) get the account for which I need to deactivate all the roles. Create new roles
		    	}else if(ac.AMS_Ownership_Role__c == null){
		    		system.debug('runRoleCreatorForOnlineAccreditations() -> STEP 4) ac '+ac.First_name__c+' '+ac.Last_name__c+' (Owner ? '+ac.Agency_owner__c+')---> CASE B');
		    		system.debug('runRoleCreatorForOnlineAccreditations() -> STEP 4) ac has account owner = '+ac.Company__c+' ---> CASE B');
		    		system.debug('runRoleCreatorForOnlineAccreditations() -> STEP 4) acToRoles.get('+acId+') '+acToRoles.get(acId));

		    		system.debug('CHECKPOINT: Accreditation Contact has no link to an existing account role-> ' + ac);

		    		if(ac.Agency_owner__c == true){
	    				for(Id accountId : aoMap.get(ac.AMS_Pax_Accreditation_Form__c)){
	    					System.debug('runRoleCreatorForOnlineAccreditations() sweeping accounts... current id: ' + accountId);
		    				AMS_Account_Role__c newRole = AMS_AccreditationContactHelper.createAmsAccountRole(ac);
		    				newRole.Account__c = accountId;
		    				System.debug('runRoleCreatorForOnlineAccreditations() new role: ' + newRole);
		    				rolesToInsert.put(newRole.Account__c+'-'+newRole.Contact__c/*+'-'+newRole.Owner_Account__c*/,newRole);
		    				System.debug('runRoleCreatorForOnlineAccreditations() roles to insert list: ' + rolesToInsert);
		    				accountIdsToDeactivateRoles.add(accountId);
		    			}
	    			}

		    	}
	    	}
	    }
    	
    	if(accountIdsToDeactivateRoles.size()>0){
    		for(AMS_Account_Role__c role : [SELECT Id, Termination_Date__c FROM AMS_Account_Role__c WHERE Account__c IN :accountIdsToDeactivateRoles]){
    			role.Termination_Date__c = Date.today();
    			rolesToUpdate.add(role);
    		}
    	}
    	
    	system.debug('runRoleCreatorForOnlineAccreditations() -> STEP 4) rolesToUpdate = '+rolesToUpdate);
    	system.debug('runRoleCreatorForOnlineAccreditations() -> STEP 4) rolesToInsert = '+rolesToInsert);
   		
		if(rolesToUpdate.size() > 0)
			update rolesToUpdate;

    	if(rolesToInsert.size() > 0)
    		insert rolesToInsert.values();

    	// update the acs with the link of the new role created for the main account
    	for(Id acId : acToRoles.keySet()){
    		AMS_Accreditation_Contact__c ac = idToAc.get(acId);
    		if(ac.AMS_Ownership_Role__c == null){
    			system.debug('CHECKPOINT: Searching key -> ' + ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c+'-'+ac.Contact__c/*+'-'+ac.Company__c*/);
    			AMS_Account_Role__c mainRole = rolesToInsert.get(ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c+'-'+ac.Contact__c/*+'-'+ac.Company__c*/);
    			system.debug('CHECKPOINT: Found role-> ' + mainRole);
    			if(mainRole!=null){
    				ac.AMS_Ownership_Role__c = mainRole.Id;
    				system.debug('CHECKPOINT: Asssigning link to Account role-> ' + ac);
    			}
    			else
    				system.debug('runRoleCreatorForOnlineAccreditations() --> for some strange reason cannot update ac '+ac.First_name__c +' '+ac.Last_name__c+' ID = '+ac.Id+' with the role stored with key '+ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c/*+'-'+ac.Contact__c*/);
    		}
    	}

    	update idToAc.values();

    	// !! NOTE: This second step handles Account Ownership only! !! 
    	system.debug('runRoleCreatorForOnlineAccreditations() -> STEP 4) START insertAccountOwnershipsForAccreditationOnline()');
    	if(!isCorrectionProcess){
	    	Set<String> setString = new Set<String>();
	    	for(Id id : aoMap.keyset())
	    		setString.add((String) id);
	    	insertAccountOwnershipsForAccreditationOnline(setString);
	    }
	    else{
	    	insertAccountOwnershipsForAccreditationOnlineCorrections(aoMap, aoToAcList, rolesPerAccount);
	    }
    	system.debug('runRoleCreatorForOnlineAccreditations() -> STEP 4) FINISH insertAccountOwnershipsForAccreditationOnline()');

    	// Because Contact's might have validation rules that prevent Contact updates, and the business requirement
    	// is to push everything that can be pushed, we should update the Contacts last.
    	
    	if(contactsToUpdate!=null && contactsToUpdate.size() > 0)
   		{
   			List<Contact> conListToUpdate = verifyNoDuplicateIFAPcontactExists(contactsToUpdate.values());
   			update conListToUpdate;
   		}

    }


    /**
    This method processes the staging area owners and contacts into the AMS Account roles in the affected agencies.
    If an Accreditation Contact has a direct link to the AMS_Account_role, it tries to update.
    If an Accreditation Contact does not have a direct link, it will deactivate the AMS Account Role and creates a new one.

    The aoMap parameter has a map between the Accreditation Area and the Agencies (accounts) involved in the process.
    */
    public static void runRoleCreatorForOnlineAccreditationsDNG(Map<Id,Set<Id>> aoMap, boolean isCorrectionProcess){

    	// First, lets get all the data we need from Accreditation Contacts and AMS Account Roles

    	Set<Id> accreditationAreaIds = aoMap.keyset();
    	List<Id> accreditationAreaIdsLst= new List<Id>(accreditationAreaIds);

    	List<AMS_Oscar__c> oscars = [SELECT Id, RecordType.DeveloperName,Account__c, AMS_Online_Accreditation__c from AMS_Oscar__c where AMS_Online_Accreditation__c in :accreditationAreaIdsLst];

    	Map<Id,String> accreditationAndOscars = new Map<Id,String>();

    	Id accountId; 	// this is a hack to get the Account from the Oscar. As we are supposed to only work one
    					// OSCAR at a time, let's "assume" that there is only one Account involved.
    	for(AMS_Oscar__c oscar: oscars){
    		accreditationAndOscars.put(oscar.AMS_Online_Accreditation__c, oscar.RecordType.DeveloperName);
    		accountId = oscar.Account__c;
    	}


    	for(Id accreditationId : accreditationAreaIdsLst){

	    	Set<Id> accounts = aoMap.get(accreditationId);

	    	String commaSeparatedFields = AMS_AccreditationContactHelper.loadFieldsDynamically('AMS_Accreditation_Contact__c');

	    	String query = 'SELECT ' + commaSeparatedFields + ', AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c, AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Process__c, Person_AMS__r.Contact__c, RecordType.DeveloperName, AMS_Ownership_Role__r.Id, AMS_Ownership_Role__r.Duty__c,  AMS_Ownership_Role__r.Hours__c, AMS_Ownership_Role__r.IsManager__c, AMS_Ownership_Role__r.Percentage__c, AMS_Ownership_Role__r.Position__c, AMS_Ownership_Role__r.Owner_Account__c';
	        query = query + ' FROM AMS_Accreditation_Contact__c WHERE AMS_Pax_Accreditation_Form__c = :accreditationId AND (RecordTypeId in ';
	        query = query + '(' + recordTypesPerson +' ) ';
	        query = query + ' OR RecordTypeId in ';
	        query = query + '(' + recordTypesCompany+' ) ' + ')';

	        List<AMS_Accreditation_Contact__c> accreditationContactsToProcess = database.query(query);

	        // need to get all the contacts in case I need later on to update them...
	        Map<String, Contact> emailContactMap = new Map<String, Contact>();
        	Set<Id> acContactIdSet = new Set<Id>();
        	for(AMS_Accreditation_Contact__c ac : accreditationContactsToProcess)
        		acContactIdSet.add(ac.Contact__c);

        	List<Contact> allContactsFromAccreditation = [SELECT FirstName, LastName, Title, AccountId, Membership_Main_Contact__c, Training_dangerous_goods_completed__c, list_Dangerous_Goods_Awareness__c, Phone, MobilePhone, Fax, BirthDate, Email, ISO_Country__c, RecordTypeId, Id, Name, Financial_Assessment_Contact__c FROM Contact WHERE Id IN :acContactIdSet];

        	for(Contact c :allContactsFromAccreditation)
        		emailContactMap.put(c.id, c);


	        //get all the roles
	        List<AMS_Account_Role__c> allAccountRoles = new List<AMS_Account_Role__c>();
	        allAccountRoles = [SELECT Id, RecordTypeId, Termination_Date__c, Duty__c, Hours__c, IsManager__c, Percentage__c, Position__c, Account__c, Owner_Account__c, Contact__c, Person__c, Person__r.Contact__c, Legacy_External_ID__c, Legacy_System__c from AMS_Account_role__c where Account__c in: accounts and Active__c = true];

	        // just to further ahead in the process have a way to link Accreditation Contacts and AMS Account Roles
	        Map<Id,AMS_Account_Role__c> rolesMap = new Map<Id,AMS_Account_Role__c>();

			for(AMS_Account_Role__c role : allAccountRoles){
				rolesMap.put(role.Id,role);
			}

	        Set<Id> rolesToDeactivateSet = new Set<Id>();

	        List<AMS_Account_Role__c> rolestoDeactivate = new List<AMS_Account_Role__c>();
	        List<AMS_Account_Role__c> rolestoUpdate = new List<AMS_Account_Role__c>();
	        List<AMS_Account_Role__c> rolestoInsert = new List<AMS_Account_Role__c>();
	        List<AMS_Accreditation_Contact__c>  accreditationContactsToUpdate = new List<AMS_Accreditation_Contact__c>();
	        List<AMS_Accreditation_Contact__c>  accreditationContactsToInsert = new List<AMS_Accreditation_Contact__c>();
	        List<AMS_Accreditation_Contact__c> accreditationContactsToInsertOnlyContacts = new List<AMS_Accreditation_Contact__c>();

	        // let's find out which AMS_Account_roles are to deactivate.

	        for(AMS_Accreditation_Contact__c aContact :accreditationContactsToProcess){

	        	//does is have a link to an AMS_Account_role ? If so, let's deactivate the Role and add it to the list of new Accreditation to Create.
	        	if(aContact.AMS_Ownership_Role__c != null && !isCorrectionProcess){
	        		accreditationContactsToInsert.add(aContact);
	        		continue;
	        	}
	        	
	        	//does is have a link to an AMS_Account_role and is a correction or is
	        	// second time this process runs for an Accreditation Contact ? let's mark for update.
	        	if(aContact.AMS_Ownership_Role__c != null && isCorrectionProcess){
	        		accreditationContactsToUpdate.add(aContact);
	        		continue;
	        	}

	        	// does not have any Account role linked (is new) - it does not matter if it's a correction or not.
				if(aContact.AMS_Ownership_Role__c == null && aContact.Agency_owner__c){
	        		accreditationContactsToInsert.add(aContact);
	        		continue;
	        	}else{
	        		accreditationContactsToInsertOnlyContacts.add(aContact);
	        		continue;
	        	}

	
	        }




	        // to change all the AMS Account Roles in all hierarchies, we have to create a map from a single Accreditation contact
	        // to all AMS Acccount Roles that will be updated.
	        // for that, we search the AMS Account Role from the Accreditation Contact and try to find it's sinblings.

	        Map<AMS_Accreditation_Contact__c,List<AMS_Account_Role__c>> aContactsAndRoles = syncAccreditationsWithRoles(accreditationContactsToProcess,allAccountRoles); 

	        Set<AMS_Accreditation_Contact__c> contactsToDeactivate = aContactsAndRoles.keySet();
			
			for(AMS_Accreditation_Contact__c acon: contactsToDeactivate){

				if(acon.AMS_Ownership_Role__c != null && !isCorrectionProcess){
					
					for(AMS_Account_Role__c role: aContactsAndRoles.get(acon)){
		        		
		        		role.Termination_Date__c = Date.Today();
		        		rolestoDeactivate.add(role);
		        		
		        	}


				}

			}


	        if(aContactsAndRoles == null) // opps
		        throw new AMS_ApplicationException('Sync Accreditations With Roles went wrong !');

			// now for the new Acreditation Contact, we have to create new AMS Account roles based on the accreditationContactsToInsert list !
			System.debug('Accreditation contacts to insert:'+accreditationContactsToInsert);
			AMS_AccountRoleCreator.RoleCreatorEntitiesBucket bucket1 = insertAMSAccountRoles(accreditationContactsToInsert,emailContactMap, accounts, accreditationAndOscars.get(accreditationId) == 'NEW',accountId);
			
			// for accreditation contacts that only have contact connectd (not owners), let's update the data
			System.debug('Single contacts to insert:'+accreditationContactsToInsertOnlyContacts);
			AMS_AccountRoleCreator.RoleCreatorEntitiesBucket bucket2 = insertOrUpdateContactsAlone(accreditationContactsToInsertOnlyContacts,emailContactMap);


	        // now that the old Roles are deactivated, we have to update the ones on the accreditationContactsToUpdate list !
	        System.debug('Accreditation Contacts to update:'+accreditationContactsToUpdate);	        
	        AMS_AccountRoleCreator.RoleCreatorEntitiesBucket bucket3 = updateAMSAccountRoles(accreditationContactsToUpdate,emailContactMap,rolesMap,aContactsAndRoles);


			List<AMS_Account_Role__c> amsRolesToInsert = bucket1.rolesToInsert;
			amsRolesToInsert.addAll(bucket2.rolesToInsert);
			amsRolesToInsert.addAll(bucket3.rolesToInsert);
			amsRolesToInsert.addAll(rolestoDeactivate);

			upsert amsRolesToInsert;
		
			List<Contact> contactsToUpdate = bucket1.contactsToUpdate.values();
			contactsToUpdate.addAll(bucket2.contactsToUpdate.values());
			contactsToUpdate.addAll(bucket3.contactsToUpdate.values());

			update contactsToUpdate;

			List<AMS_Accreditation_Contact__c> aContactsToUpdate = new List<AMS_Accreditation_Contact__c>();
			aContactsToUpdate.addAll(bucket1.accreditationsToUpdate.keySet());

			for(AMS_Accreditation_Contact__c ac : aContactsToUpdate){

				if(bucket1.accreditationsToUpdate.get(ac) != null)
					ac.AMS_Ownership_Role__c = bucket1.accreditationsToUpdate.get(ac).Id;

			}

			aContactsToUpdate.addAll(bucket2.accreditationsToUpdate.keySet());
			aContactsToUpdate.addAll(bucket3.accreditationsToUpdate.keySet());

			update aContactsToUpdate;


        }

    }

    public static Map<AMS_Accreditation_Contact__c,List<AMS_Account_Role__c>> syncAccreditationsWithRoles(List<AMS_Accreditation_Contact__c> accreditationContactsToProcess, List<AMS_Account_Role__c> allAccountRoles){

    	Map<AMS_Accreditation_Contact__c,List<AMS_Account_Role__c>> toReturn = new Map<AMS_Accreditation_Contact__c,List<AMS_Account_Role__c>>();

    	for(AMS_Accreditation_Contact__c ac: accreditationContactsToProcess){

    		if(ac.AMS_Ownership_Role__c == null) // it's new ...
    			continue;

    		List<AMS_Account_Role__c> rolesToAdd = new List<AMS_Account_Role__c>();

			AMS_Account_Role__c orginal = null;
    		
    		for(AMS_Account_Role__c role: allAccountRoles){
    			if(ac.AMS_Ownership_Role__c == role.Id){
    				orginal = role;
    				break;
    			}
    		}

    		if(orginal == null)
    			return null; // ooppss....
    	
    		// now let's find his siblings 
    		for(AMS_Account_Role__c role: allAccountRoles){

    			if(role.RecordTypeId == orginal.RecordTypeId && role.Percentage__c == orginal.Percentage__c && 
    			  (role.Contact__c == orginal.Contact__c && role.Person__c == orginal.Person__c && role.Owner_Account__c == orginal.Owner_Account__c && role.Legacy_External_ID__c == orginal.Legacy_External_ID__c))
    			rolesToAdd.add(role);
    		}

    		toReturn.put(ac, rolesToAdd);
    	}

    	return toReturn;

    }





    public static AMS_AccountRoleCreator.RoleCreatorEntitiesBucket updateAMSAccountRoles(List<AMS_Accreditation_Contact__c> contacts,Map<String, Contact> emailContactMap,Map<Id,AMS_Account_Role__c> rolesMap,Map<AMS_Accreditation_Contact__c,List<AMS_Account_Role__c>> aContactsAndRoles){

    	Map<String, Contact> newContactsToInsert = new Map<String, Contact>();
    	Map<String,Contact> contactsToUpdate = new Map<String,Contact>();
		List<AMS_Account_Role__c> rolesToUpdate = new List<AMS_Account_Role__c>();

		Map<AMS_Accreditation_Contact__c,AMS_Account_Role__c> accreditationsToUpdate = new Map<AMS_Accreditation_Contact__c,AMS_Account_Role__c>();

    	for(AMS_Accreditation_Contact__c ac: contacts){

    		List<AMS_Account_Role__c> roles = aContactsAndRoles.get(ac);

    		if(roles == null){
    			System.debug('Could not find any roles...');
    			continue;
    		}

    		for(AMS_Account_Role__c role: roles){

	    		AMS_Account_Role__c roleToUpdate = updateAmsAccountRole(role, ac);
	    		rolesToUpdate.add(roleToUpdate);

	    		if(ac.Contact__c != null && rolesMap.get(ac.AMS_Ownership_Role__c).Id == role.Id){ // has a contact, let's update the contact as well
	    		
	    			Contact contactToUpdate = AMS_AccreditationContactHelper.populateNewContactFields(emailContactMap.get(ac.Contact__c), ac);
					contactsToUpdate.put(contactToUpdate.email, contactToUpdate);

				}else{

					if(ac.Contact__c == null && roleToUpdate.Contact__c != null && rolesMap.get(ac.AMS_Ownership_Role__c).Id == role.Id){
						ac.Contact__c = roleToUpdate.Contact__c;
						accreditationsToUpdate.put(ac,null);
					}

					if(ac.Contact__c == null && (ac.Email__c != null || (ac.Phone__c != null && ac.Phone__c != '-')) && roleToUpdate.Contact__c == null && rolesMap.get(ac.AMS_Ownership_Role__c).Id == role.Id){

						if(newContactsToInsert.get(ac.email__c) == null){ // this is only for new created contacts, not updates.

							Contact con = new Contact();

							con = AMS_AccreditationContactHelper.populateNewContactFields(con, ac);
			    			newContactsToInsert.put(con.Email, con);
						}

					}
				}

			}

    	}

    	if(!newContactsToInsert.isEmpty()){
   			insert verifyNoDuplicateIFAPcontactExists(newContactsToInsert.values());
   		}

		for(AMS_Accreditation_Contact__c ac: contacts){

			Contact newContact = newContactsToInsert.get(ac.Email__c);
			
			if(newContact != null){

				List<AMS_Account_Role__c> roles = aContactsAndRoles.get(ac);

				for(AMS_Account_Role__c role: roles){

					if(role.Contact__c == null){

						role.Contact__c = newContact.Id;
						rolesToUpdate = updateRoleList(role,rolesToUpdate);

					}
				}

				ac.Contact__c = newContact.Id;
				
				accreditationsToUpdate.put(ac,null);
			
			}
		}

		return new AMS_AccountRoleCreator.RoleCreatorEntitiesBucket(accreditationsToUpdate, rolesToUpdate,contactsToUpdate);
    }

    private static List<AMS_Account_Role__c> updateRoleList(AMS_Account_role__c role, List<AMS_Account_role__c> roles){
    	Integer i = 0;

    	for(AMS_Account_Role__c elem:roles){
    		if(elem.Id == role.Id){
    			roles.remove(i);
    			roles.add(role);
    			return roles;
    		}
    	
			i++;
    	
    	}

    	return roles;
    }

    public static AMS_Account_Role__c updateAmsAccountRole(AMS_Account_role__c role, AMS_Accreditation_Contact__c ac)
    {
    	if(ac.Contact__c != null)
        {
			role.Contact__c = ac.Contact__c;
        }
        else if(ac.Person_AMS__c != null)
        {
        	role.Person__c = ac.Person_AMS__c;
        }
       
        
		role.Duty__c 			= ac.Job_Title__c;
		role.Hours__c 			= String.valueOf(ac.Time_devoted_to_Agency_business__c);
		role.IsManager__c 		= ac.Agency_role__c;
		role.Percentage__c 		= ac.Financial_Interest__c;
		role.Position__c 		= ac.Job_title__c;
		role.Legacy_External_Id__c = ac.Legacy_External_Id__c;

		if(ac.Agency_owner__c)
		{
			role.RecordTypeId = AMS_Utils.getId('AMS_Account_Role__c', 'Ownership');
            role.Owner_Name__c      = (ac.First_Name__c == null ? '' : ac.First_Name__c  ) + (ac.Last_Name__c == null ? '' : ( ' ' + ac.Last_Name__c));
		}
		
		return role;
    }

    public static AMS_AccountRoleCreator.RoleCreatorEntitiesBucket insertOrUpdateContactsAlone(List<AMS_Accreditation_Contact__c> contacts,Map<String, Contact> emailContactMap){

		Map<String, Contact> newContactsToInsert = new Map<String, Contact>();
		Map<String,Contact> contactsToUpdate = new Map<String,Contact>();
		Map<AMS_Accreditation_Contact__c,AMS_Account_Role__c> accreditationsToUpdate = new Map<AMS_Accreditation_Contact__c,AMS_Account_Role__c>();

    	for(AMS_Accreditation_Contact__c ac: contacts){
    		
    		// has the user changed anything on the contact ? well, let's update them.
			if(ac.Contact__c != null && emailContactMap.get(ac.Contact__c) != null) {
			
				Contact contactToUpdate = AMS_AccreditationContactHelper.populateNewContactFields(emailContactMap.get(ac.Contact__c), ac);

				contactsToUpdate.put(contactToUpdate.email, contactToUpdate);
			}else{



	    		if(newContactsToInsert.get(ac.email__c) == null && (ac.Email__c != null || (ac.Phone__c != null && ac.Phone__c != '-'))){ // this is only for new created contacts, not updates.

					Contact con = new Contact();

					con = AMS_AccreditationContactHelper.populateNewContactFields(con, ac);
			    	newContactsToInsert.put(con.Email, con);

				}
			}
				
		}


		if(!newContactsToInsert.isEmpty()){
   			insert verifyNoDuplicateIFAPcontactExists(newContactsToInsert.values());
   		}

		for(AMS_Accreditation_Contact__c ac: contacts){

			if(newContactsToInsert.get(ac.Email__c) != null){

				ac.Contact__c = newContactsToInsert.get(ac.Email__c).Id;
				accreditationsToUpdate.put(ac,null);
			
			}
		}
   				    	
		return new AMS_AccountRoleCreator.RoleCreatorEntitiesBucket(accreditationsToUpdate, new List<AMS_Account_Role__c>(),contactsToUpdate);
    }


    public static AMS_AccountRoleCreator.RoleCreatorEntitiesBucket insertAMSAccountRoles(List<AMS_Accreditation_Contact__c> acList,Map<String, Contact> emailContactMap, Set<Id> accounts, Boolean isNewProcess, Id singleAccount)
    {

    	// here we have to create a AMS Account Role based on the Accreditation Contact
    	// we can have a link to a Contact, a link to a person or a link to an Account
    	// if we have any of the above link, we have to link it to the AMS Account Role
    	// if no link is provided, we have to create a Contact at least (no person needs to be created and the Account has to already been created.)

    	List<AMS_Account_Role__c> rolesToInsert = new List<AMS_Account_Role__c>();

		List<AMS_Accreditation_Contact__c> migrateEntities = new List<AMS_Accreditation_Contact__c>();
		List<AMS_Accreditation_Contact__c> toCreateEntities = new List<AMS_Accreditation_Contact__c>();

		Map<String,Contact> contactsToUpdate = new Map<String,Contact>();

    	for(AMS_Accreditation_Contact__c ac: acList){

	        if(ac.Contact__c != null || (ac.Person_AMS__c != null && ac.Person_AMS__r.Contact__c != null) || (ac.Company__c != null && ac.Company__c != ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c))
	        {
	        	System.debug('Adding a new AC to migrate as it already has something:'+ ac);
	        	migrateEntities.add(ac); // we just have to prepopulate the new AMS Account Role
	        }
	        else{
	        	System.debug('Adding a new AC to create as it has nothing to update:'+ ac);
	        	toCreateEntities.add(ac);  // we need to create at least a new contact before prepopulate the new AMS Account Role
	        }
		
		}

		Map<AMS_Accreditation_Contact__c,AMS_Account_Role__c> accreditationsToUpdate = new Map<AMS_Accreditation_Contact__c,AMS_Account_Role__c>();

		if(isNewProcess){ // if it's a New HO, BR, GSA, etc, we don't want broacast the changes, only for the main Account involved.
			accounts.clear();
			accounts.add(singleAccount);
		}

		for(Id accountId: accounts) {

			for(AMS_Accreditation_Contact__c ac: migrateEntities){

		    	AMS_Account_Role__c role = new AMS_Account_Role__c();

				role.RecordTypeId 		= AMS_Utils.getId('AMS_Account_Role__c', 'Ownership');

	        	role.Account__c         = accountId;
				role.Duty__c 			= ac.Job_Title__c;
				role.Employee_Name__c 	= ac.First_Name__c + ' ' + ac.Last_Name__c;
				role.Hours__c 			= String.valueOf(ac.Time_devoted_to_Agency_business__c);
				role.IsManager__c 		= ac.Agency_role__c;
				role.Percentage__c 		= ac.Financial_Interest__c;
				role.Position__c 		= ac.Job_title__c;
				role.Owner_Name__c 		= (ac.First_Name__c == null ? '' : ac.First_Name__c  ) + (ac.Last_Name__c == null ? '' : ( ' ' + ac.Last_Name__c));
				role.Legacy_External_Id__c = ac.Legacy_External_Id__c;

				if(ac.Contact__c == null && (ac.Person_AMS__c == null || (ac.Person_AMS__c != null && ac.Person_AMS__r.Contact__c == null))) // meaning it's a company.
					role.Owner_Account__c = ac.Company__c;
				else
					role.Contact__c = ac.Contact__c == null ? ac.Person_AMS__r.Contact__c : ac.Contact__c;


				// has the user changed anything on the contact ? well, let's update them.
				if(emailContactMap.get(ac.Contact__c) != null && ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c == accountId) {

					Contact contactToUpdate = AMS_AccreditationContactHelper.populateNewContactFields(emailContactMap.get(ac.Contact__c), ac);

					contactsToUpdate.put(contactToUpdate.email, contactToUpdate);
				}

				rolesToInsert.add(role);

				if(ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c == accountId)
					accreditationsToUpdate.put(ac,role); // adding now to update the Accreditation Contact with the new ID from the AMS Account Role.

			}
		}

		Map<String, Contact> newContactsToInsert = new Map<String, Contact>();

		// for bulk reasons, we need to first create all contacts and then create the AMS Account Roles with the Id from the contacts created.
		for(AMS_Accreditation_Contact__c ac: toCreateEntities){ 

			if(newContactsToInsert.get(ac.email__c) == null && (ac.Email__c != null ||(ac.Phone__c != null && ac.Phone__c != '-'))){

				Contact con = new Contact();

				con = AMS_AccreditationContactHelper.populateNewContactFields(con, ac);
		    	newContactsToInsert.put(con.Email, con);

			}

		}

		if(!newContactsToInsert.isEmpty()){
   			insert verifyNoDuplicateIFAPcontactExists(newContactsToInsert.values());
   		}

   		// now that we have the contacts inserted, let's create the roles with this contacts.

		for(Id accountId: accounts) {

	   		for(AMS_Accreditation_Contact__c ac: toCreateEntities){

	   			AMS_Account_Role__c role;

		    	role = new AMS_Account_Role__c();

				role.RecordTypeId 		= AMS_Utils.getId('AMS_Account_Role__c', 'Ownership');
				role.Account__c 		= accountId;
				role.Duty__c 			= ac.Job_Title__c;
				role.Employee_Name__c 	= ac.First_Name__c + ' ' + ac.Last_Name__c;
				role.Hours__c 			= String.valueOf(ac.Time_devoted_to_Agency_business__c);
				role.IsManager__c 		= ac.Agency_role__c;
				role.Percentage__c 		= ac.Financial_Interest__c;
				role.Position__c 		= ac.Job_title__c;
				role.Owner_Name__c 		= (ac.First_Name__c == null ? '' : ac.First_Name__c  ) + (ac.Last_Name__c == null ? '' : ( ' ' + ac.Last_Name__c));
				if(newContactsToInsert.get(ac.Email__c) != null)
					role.Contact__c = newContactsToInsert.get(ac.Email__c).Id;
				role.Legacy_External_Id__c = ac.Legacy_External_Id__c;
				rolesToInsert.add(role);

				if(newContactsToInsert.get(ac.Email__c) != null  && ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c == accountId)
					ac.Contact__c = newContactsToInsert.get(ac.Email__c).Id;
				
				if(ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c == accountId)
					accreditationsToUpdate.put(ac,role); // adding now to update the Accreditation Contact with the new ID from the AMS Account Role.


	   		}
		}

   		// contactsToUpdate having all the contacts to update
   		// rolesToInsert having all the new roles to insert
   		// accreditationsToUpdate having all the new mappings from Accreditation to AMS Account Roles

		return new AMS_AccountRoleCreator.RoleCreatorEntitiesBucket(accreditationsToUpdate,rolesToInsert,contactsToUpdate);
    }

    private static List<AMS_Account_Role__c> fetchAccountRolesToQuery(Set<Id> accountsToSearch, Set<AMS_AccountRoleCreator.RoleBundle> contactsAndPersons){

		List<AMS_Account_Role__c> rolesToReturn = new List<AMS_Account_Role__c>();

    	List<AMS_Account_Role__c> roles = new List<AMS_Account_Role__c>();


    	roles = [SELECT Id, recordtype.DeveloperName, Account__c, Termination_Date__c, Person__c, Contact__c, Contact__r.Name, Person__r.Name, Owner_Account__c, 
    						Owner_Account__r.Name, Duty__c,Hours__c,IsManager__c,Percentage__c,Position__c
							FROM AMS_Account_Role__c WHERE Account__c in :accountsToSearch and Termination_Date__c = NULL AND RecordType.DeveloperName = 'Ownership'];


		List<AMS_AccountRoleCreator.RoleBundle> contactsAndPersonsLst= new List<AMS_AccountRoleCreator.RoleBundle>(contactsAndPersons);

		for(AMS_Account_Role__c role : roles){

			for(AMS_AccountRoleCreator.RoleBundle bundle : contactsAndPersonsLst){

				if(bundle.type == 'C' && role.Account__c == bundle.accountId && role.Contact__c == bundle.contactOrPersonOrAccount){
					rolesToReturn.add(role);
				}

				if(bundle.type == 'P' && role.Account__c == bundle.accountId && role.Person__c == bundle.contactOrPersonOrAccount){
					rolesToReturn.add(role);
				}

				if(bundle.type == 'A' && role.Account__c == bundle.accountId && role.Owner_Account__c == bundle.contactOrPersonOrAccount){
					rolesToReturn.add(role);
				}
			}

		}

		return rolesToReturn;
    }

    public class RoleBundle {

    	private Id accountId{get;set;}

    	private Id contactOrPersonOrAccount{get;set;}

    	private String type{get;set;}

    	public RoleBundle(Id accountId, Id contactOrPersonOrAccount, String type){



    		this.accountId = accountId;
    		this.contactOrPersonOrAccount = contactOrPersonOrAccount;
    		this.type = type;




    	}

    }

    public class RoleCreatorEntitiesBucket {

		private Map<AMS_Accreditation_Contact__c,AMS_Account_Role__c> accreditationsToUpdate {get;set;}
		
		private List<AMS_Account_Role__c> rolesToInsert {get;set;}
		
		private Map<String,Contact> contactsToUpdate {get;set;}

    	public RoleCreatorEntitiesBucket(Map<AMS_Accreditation_Contact__c,AMS_Account_Role__c> accreditationsToUpdate,List<AMS_Account_Role__c> rolesToInsert,Map<String,Contact> contactsToUpdate){

    		this.accreditationsToUpdate = accreditationsToUpdate;
    		this.rolesToInsert = rolesToInsert;
    		this.contactsToUpdate = contactsToUpdate;

    	}

    }
    
}
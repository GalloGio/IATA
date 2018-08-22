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

    public static final Set<String> processesBlockedToMigrateOwners = new Set<String>{'NEW.BR' ,'NEW.BR.ABROAD','NEW.TIDS.1.0','NEW.MSO.1.0','NEW.GSA.1.0','NEW.GSSA.1.0','NEW.AHA.1.0','NEW.SA.1.0','NEW.AHA.1.0.BSP','NEW.GSA.1.0.BSP'};

    public static final Set<String> allowedLocationTypesForNewProcesses = new Set<String>{'HO','AO'};
    
    // This funny looking method is a workaround to be able to use a variable (Set<Id>) in a dynamic query
    public static List<AMS_Accreditation_Contact__c> retrieveACsDynamically(String soqlString, String setName)
    {
        system.debug('retrieveACsDynamically() -> final = '+soqlString.replace('ABC', setName));
        return Database.query(soqlString.replace('ABC', setName));
    }

    private static String createContactRecordTypes(List<String> types){
        String toReturn = '';

        for(String tp: types)
            toReturn += '\'' + RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', tp) + '\'' + ',';
    
        return toReturn.removeEnd(',');
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
            
            newCon.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
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

    /**
    This method processes the staging area owners and contacts into the AMS Account roles in the affected agencies.
    If an Accreditation Contact has a direct link to the AMS_Account_role, it tries to update.
    If an Accreditation Contact does not have a direct link, it will deactivate the AMS Account Role and creates a new one.

    The aoMap parameter has a map between the Accreditation Area and the Agencies (accounts) involved in the process.
    */
    public static Map<Id,OldAndNewOwners> runRoleCreatorForOnlineAccreditations(Map<Id,Set<Id>> aoMap, Boolean isCorrectionProcess, Map<Id,AMS_OSCAR__c> oscars, Map<Id,String> locationTypeByOscar, Map<Id,Id> topParentByOscar) {

        Map<Id,OldAndNewOwners> oldAndNewOwnersMap = new Map<Id,OldAndNewOwners>();
        Set<Id> accountsToCloneOwnersFromHO = new Set<Id>(); //accounts from new br/sa processes
        Set<Id> accountsToCopyOwners = new Set<Id>(); //top parent accounts to get the roles to copy to new br/sa
        Set<Id> accountsToCreateNewOwners = new Set<Id>(); //accounts from new ho/ao processes
        Set<Id> accountsToChangeOwners = new Set<Id>(); //accounts from changes/correction processes
        Set<Id> accountIds = new Set<Id>();
        Set<Id> personsIds = new Set<Id>();                                         
        Set<Id> rolesWithPersonsId = new Set<Id>();
        Map<Id,AMS_Account_Role__c> rolesToUpsert = new Map<Id,AMS_Account_Role__c>(); //key is Id for Roles already existant and the accreditation contact id for the new ones        
        Map<String,Contact> contactsToUpsert = new Map<String,Contact>(); //key is Id for Contacts already existant and the accreditation contact id for the new ones        
        Map<Id,Account> companiesToInsert = new Map<Id,Account>(); //key is the accreditation contact id as they don't have a id yet        
        Map<Id,AMS_Accreditation_Contact__c> accreditationContactsToUpdate = new Map<Id,AMS_Accreditation_Contact__c>();    
        Map<Id,Id> accreditationContactWithRole = new Map<Id,Id>();
        Map<Id,Set<Id>> accountsToCloneRoles = new Map<Id,Set<Id>>(); //oscar account with the other accounts in the hierarchy
        List<AMS_Accreditation_Contact__c> accConToProcessAfterRoles = new List<AMS_Accreditation_Contact__c>();

        //check if the process should create new owners or if it's just to clone the owners from the HO
        for(AMS_OSCAR__c osc: oscars.values()) {

            if(processesBlockedToMigrateOwners.contains(osc.Process__c) && !allowedLocationTypesForNewProcesses.contains(locationTypeByOscar.get(osc.Id)) && isCorrectionProcess && osc.STEP10__c == 'Passed' && osc.STEP6__c == 'Passed') {
                
                accountsToCloneOwnersFromHO.add(osc.Account__c);
                accountsToCopyOwners.add(topParentByOscar.get(osc.Id));

            } else if(!processesBlockedToMigrateOwners.contains(osc.Process__c) && allowedLocationTypesForNewProcesses.contains(locationTypeByOscar.get(osc.Id))) {
                
                accountsToCreateNewOwners.add(osc.Account__c);

            } else {
                accountsToChangeOwners.addAll(aoMap.get(osc.AMS_Online_Accreditation__c));

                if(!accountsToCloneRoles.containsKey(osc.Account__c))
                    accountsToCloneRoles.put(osc.Account__c, new Set<Id>());
                accountsToCloneRoles.get(osc.Account__c).addAll(accountsToChangeOwners);
            }
        }

        for(Id accId : aoMap.keySet())
            accountIds.addAll(aoMap.get(accId));

        String commaSeparatedFields = AMS_AccreditationContactHelper.loadFieldsDynamically('AMS_Accreditation_Contact__c');
        Set<Id> accreditationFormIds = aoMap.keySet();

        String query = 'SELECT ' + commaSeparatedFields + ', AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__c, AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c, AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Process__c, Person_AMS__r.Contact__c, RecordType.DeveloperName, AMS_Ownership_Role__r.Id, AMS_Ownership_Role__r.Duty__c,  AMS_Ownership_Role__r.Hours__c, AMS_Ownership_Role__r.IsManager__c, AMS_Ownership_Role__r.Percentage__c, AMS_Ownership_Role__r.Position__c, AMS_Ownership_Role__r.Owner_Account__c,Company__r.name, AMS_Pax_Accreditation_Form__r.ANG_IsNewGenAgency__c ';
        query = query + ' FROM AMS_Accreditation_Contact__c WHERE AMS_Pax_Accreditation_Form__c IN :accreditationFormIds AND (RecordTypeId in ';
        query = query + '(' + recordTypesPerson +' ) ';
        query = query + ' OR RecordTypeId in ';
        query = query + '(' + recordTypesCompany+' ) ' + ')';

        //get all the accreditation contacts to create the new owners
        Map<Id,AMS_Accreditation_Contact__c> accreditationContactsToProcess = new Map<Id,AMS_Accreditation_Contact__c>((List<AMS_Accreditation_Contact__c>)Database.query(query));

        Map<Id,List<AMS_Accreditation_Contact__c>> accreditationContactsPerAccount = new Map<Id,List<AMS_Accreditation_Contact__c>>();

        for(AMS_Accreditation_Contact__c accCon : accreditationContactsToProcess.values()) {

            if(!accreditationContactsPerAccount.containsKey(accCon.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c))
                accreditationContactsPerAccount.put(accCon.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c, new List<AMS_Accreditation_Contact__c>());

            accreditationContactsPerAccount.get(accCon.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c).add(accCon);
        }

        //get all the contacts from the affected accounts
        Map<Id,Contact> allContactsFromAccount = new Map<Id,Contact>([SELECT FirstName, LastName, Title, AccountId, Account.Location_Class__c, Membership_Main_Contact__c, Training_dangerous_goods_completed__c, list_Dangerous_Goods_Awareness__c, Phone, MobilePhone, Fax, BirthDate, Email, ISO_Country__c, RecordTypeId, Id, Name, Financial_Assessment_Contact__c, Authorized_Signatory__c 
            FROM Contact 
            WHERE AccountId IN :accountIds]);

        Map<Id,List<Contact>> contactsPerAccount = new Map<Id,List<Contact>>();

        for(Contact con : allContactsFromAccount.values()) {

            if(!contactsPerAccount.containsKey(con.AccountId))
                contactsPerAccount.put(con.AccountId, new List<Contact>());

            contactsPerAccount.get(con.AccountId).add(con);
        }

        //create a new bucket for each accreditation contact
        Map<Id,AccreditationContactBucket> accConBucketList = new Map<Id,AccreditationContactBucket>(); 
        Map<Id,List<AccreditationContactBucket>> accConBucketPerAccount = new Map<Id,List<AccreditationContactBucket>>();

        for(AMS_Accreditation_Contact__c accreditationContact : accreditationContactsToProcess.values()) {

            AccreditationContactBucket bucket = new AccreditationContactBucket(accreditationContact, 
                                                                                oscars.get(accreditationContact.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__c), 
                                                                                accountsToCloneOwnersFromHO.contains(accreditationContact.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c));

            //fill the top parent for the bucket to clone only
            if(bucket.isJustToClone)
                bucket.topParent = topParentByOscar.get(bucket.oscar.Id);
            
            //select the contact or company for each accreditation contact
            if(bucket.isCompany) {

                if(bucket.isLinkedWithContactOrCompany) {

                    bucket.companyId = accreditationContact.Company__c;

                } else {

                    bucket.createNewCompany();
                    companiesToInsert.put(bucket.accreditationContact.Id, bucket.newCompany);
                }

            } else {

                if(bucket.isLinkedWithContactOrCompany) {

                    bucket.contact = allContactsFromAccount.get(accreditationContact.Contact__c == null ? accreditationContact.Person_AMS__r.Contact__c : accreditationContact.Contact__c);
                    bucket.updateTheContact(bucket.contact.Id);
                    contactsToUpsert.put(bucket.accreditationContact.Email__c, bucket.contact);

                } else {

                    bucket.createNewContact();
                    contactsToUpsert.put(bucket.accreditationContact.Email__c, bucket.contact);
                }                
            }

            //create the newRoles for each accreditation contact
            if(bucket.isOwner && !accountsToCloneOwnersFromHO.contains(bucket.accountId)) {

                bucket.createNewRole();
                rolesToUpsert.put(accreditationContact.Id, bucket.newRole);
            } 
            
            if(accreditationContact.AMS_Ownership_Role__c != null)
                accreditationContactWithRole.put(accreditationContact.Id, accreditationContact.AMS_Ownership_Role__c);
            
            //check if there are persons to delete
            if(accreditationContact.Person_AMS__c != null) {
                bucket.personId = accreditationContact.Person_AMS__c;
                personsIds.add(accreditationContact.Person_AMS__c);
            }

            accConBucketList.put(bucket.accreditationContact.Id,bucket);

            if(!accConBucketPerAccount.containsKey(bucket.accountId))
                accConBucketPerAccount.put(bucket.accountId, new List<AccreditationContactBucket>());

            accConBucketPerAccount.get(bucket.accountId).add(bucket);
        }

        //upsert contacts
        upsert contactsToUpsert.values();

        //insert companies
        insert companiesToInsert.values();

        //get all the roles from the affected accounts that there are active or the roles with persons to delete
        Map<Id,AMS_Account_Role__c> activeRoles = new Map<Id,AMS_Account_Role__c>([SELECT Id, RecordTypeId, Termination_Date__c, Duty__c, Hours__c, IsManager__c, Percentage__c, Position__c, Account__c, Owner_Account__c, Contact__c, Person__c, Person__r.Contact__c, Legacy_External_ID__c, Legacy_System__c, Owner_Name__c,Owner_Account__r.Name, Active__c FROM AMS_Account_role__c WHERE ((Account__c IN :accountIds OR Account__c IN :accountsToCopyOwners) AND Active__c = true) OR Id IN :personsIds]);

        Map<Id,List<AMS_Account_Role__c>> oldRolesPerAccount = new Map<Id,List<AMS_Account_Role__c>>();

        for(AMS_Account_Role__c role : activeRoles.values()) {

            if(!oldRolesPerAccount.containsKey(role.Account__c))
                oldRolesPerAccount.put(role.Account__c, new List<AMS_Account_Role__c>());

            oldRolesPerAccount.get(role.Account__c).add(role);

            if(role.Person__c != null && role.Person__r.Contact__c != null && !personsIds.isEmpty() && personsIds.contains(role.Person__c))
                rolesWithPersonsId.add(role.Id);
        }

        //correct the roles with persons to delete
        if(!rolesWithPersonsId.isEmpty())
            rolesToUpsert.putAll(updateAMSRolesBeforePersonDeletion(activeRoles, rolesWithPersonsId, rolesToUpsert));

        //delete persons
        if(!personsIds.isEmpty())
            delete [SELECT Id FROM AMS_Person__c WHERE Id IN :personsIds];

        //link the accreditation contact old role with the bucket
        for(Id accContId : accreditationContactWithRole.keySet()) {

            if(activeRoles.containsKey(accreditationContactWithRole.get(accContId)) && activeRoles.get(accreditationContactWithRole.get(accContId)).Active__c)
                accConBucketList.get(accContId).oldRole = activeRoles.get(accreditationContactWithRole.get(accContId));
            else
                throw new AMS_ApplicationException('Sync Accreditations With Roles went wrong !' + accreditationContactsToProcess.get(accContId));
        }

        Map<Id,List<AMS_Account_Role__c>> newRolesPerAccount = new Map<Id,List<AMS_Account_Role__c>>();
        
        for(AccreditationContactBucket accConBucket : accConBucketList.values()) {

            //Register New and Old Owners for EBulletion Report purposes
            oldAndNewOwnersMap.put(accConBucket.accreditationId,getNewAndOldOwnersForChangeCodeCreation(activeRoles.values(),accreditationContactsToProcess.values(),accountIds));

            //fill the new roles with the respective contact or company ids for the new ones
            if(accConBucket.isOwner && !accConBucket.isLinkedWithContactOrCompany && !accConBucket.isJustToClone) {

                if(accConBucket.isCompany) {

                    rolesToUpsert.get(accConBucket.accreditationContact.Id).Owner_Account__c    = accConBucket.newRole.Owner_Account__c 
                                                                                                = accConBucket.accreditationContact.Company__c 
                                                                                                = companiesToInsert.get(accConBucket.accreditationContact.Id).Id;
                } else {

                    rolesToUpsert.get(accConBucket.accreditationContact.Id).Contact__c  = accConBucket.newRole.Contact__c 
                                                                                        = accConBucket.accreditationContact.Contact__c 
                                                                                        = contactsToUpsert.get(accConBucket.accreditationContact.Email__c).Id;
                }

                accreditationContactsToUpdate.put(accConBucket.accreditationContact.Id, accConBucket.accreditationContact);
                accConBucket.isLinkedWithContactOrCompany = true;

                if(!newRolesPerAccount.containsKey(accConBucket.accountId))
                    newRolesPerAccount.put(accConBucket.accountId, new List<AMS_Account_Role__c>());

                newRolesPerAccount.get(accConBucket.accountId).add(accConBucket.newRole);
            }

        }

        //clone the roles for each account in the hierarchy
        List<AMS_Account_Role__c> listClonesRoles = new List<AMS_Account_Role__c>();

        for(Id acc : accountsToCloneRoles.keySet()) {

            for(Id accToClone : accountsToCloneRoles.get(acc)) {

                if(acc == accToClone)
                    continue;

                listClonesRoles.addAll(assignOwners(accToClone, newRolesPerAccount.get(acc)));
            }
        }

        //clone the roles for the new BRs
        for(Id brAcc : accountsToCloneOwnersFromHO)
            listClonesRoles.addAll(assignOwners(brAcc, oldRolesPerAccount.get(accConBucketPerAccount.get(brAcc).get(0).topParent)));
        
        //add a termination date to the previous roles
        rolesToUpsert.putAll(updateRolesTerminationDate(rolesToUpsert, oldRolesPerAccount, accountsToChangeOwners));

        //upsert roles
        listClonesRoles.addAll(rolesToUpsert.values());
        upsert listClonesRoles;

        // fill the accreditation contacts with the new roles ids
        for(AMS_Account_Role__c roleAfterUpsert : listClonesRoles) {

            if(accConBucketPerAccount.containsKey(roleAfterUpsert.Account__c)) {

                for(AccreditationContactBucket acBucket : accConBucketPerAccount.get(roleAfterUpsert.Account__c)) {

                    if(acBucket.isOwner && ((acBucket.isCompany && roleAfterUpsert.Owner_Account__c == acBucket.newRole.Owner_Account__c) || (!acBucket.isCompany && roleAfterUpsert.Contact__c == acBucket.newRole.Contact__c))) {
                        
                        acBucket.accreditationContact.AMS_Ownership_Role__c = roleAfterUpsert.Id;
                        accConToProcessAfterRoles.add(acBucket.accreditationContact);
                    }
                }
            }
        }
        
        //update accreditation contacts
        update accConToProcessAfterRoles;

        return oldAndNewOwnersMap;

    }

    public static List<AMS_Account_Role__c> assignOwners(Id accountId, List<AMS_Account_role__c> rolesToClone){

        System.debug('Assigning roles '+ rolesToClone+' to new account ' + accountId);

        List<AMS_Account_role__c> toReturn = new List<AMS_Account_role__c>();

        for(AMS_Account_Role__c role: rolesToClone){

            AMS_Account_Role__c newRole = role.clone(false,true,false,false);
            newRole.Account__c = accountId;
            toReturn.add(newRole);
        }

        return toReturn;

    }

    public static Map<Id,AMS_Account_Role__c> updateRolesTerminationDate(Map<Id,AMS_Account_Role__c> rolesToUpsert, Map<Id,List<AMS_Account_Role__c>> oldRolesPerAccount, Set<Id> accountsToChangeOwners) {
        
        for(Id accToTerminate : oldRolesPerAccount.keySet()) {

            if(accountsToChangeOwners.contains(accToTerminate)) {

                for(AMS_Account_Role__c roleToTerminate : oldRolesPerAccount.get(accToTerminate)) {

                    if(rolesToUpsert.containsKey(roleToTerminate.Id) && rolesToUpsert.get(roleToTerminate.Id).Active__c) {

                        rolesToUpsert.get(roleToTerminate.Id).Termination_Date__c = Date.today();

                    } else if(roleToTerminate.Active__c) {

                        roleToTerminate.Termination_Date__c = Date.today();
                        rolesToUpsert.put(roleToTerminate.Id, roleToTerminate);
                    }
                }
            }
        }

        return rolesToUpsert;
    }

    public static Map<Id,AMS_Account_Role__c> updateAMSRolesBeforePersonDeletion(Map<Id,AMS_Account_Role__c> activeRoles, Set<Id> rolesWithPersonsId, Map<Id,AMS_Account_Role__c> rolesToUpsert) {

        for(Id roleId : rolesWithPersonsId) {

            AMS_Account_Role__c role = activeRoles.get(roleId);

            if(role.Contact__c == null) {

                if(rolesToUpsert.containsKey(roleId)) {

                    rolesToUpsert.get(roleId).Contact__c = rolesToUpsert.get(roleId).Person__r.Contact__c;

                } else {

                    role.Contact__c = role.Person__r.Contact__c;
                    rolesToUpsert.put(roleId, role);

                }
            }
        }

        return rolesToUpsert;

    }


    public class AccreditationContactBucket {

        private AMS_OSCAR__c oscar {get;set;}
        private Id accountId {get;set;}
        private Id topParent {get;set;}
        private Id accreditationId {get;set;}
        private AMS_Account_Role__c oldRole {get;set;}
        private AMS_Account_Role__c newRole {get;set;}
        private Contact contact {get;set;}
        private Id personId {get;set;}
        private Id companyId {get;set;}
        private Account newCompany {get;set;}
        private AMS_Accreditation_Contact__c accreditationContact {get;set;}
        private Boolean isCompany {get;set;}
        private Boolean isLinkedWithContactOrCompany {get;set;}
        private Boolean isJustToClone {get;set;}
        private Boolean isOwner {get;set;}

        public AccreditationContactBucket(AMS_Accreditation_Contact__c accreditationContact, AMS_OSCAR__c oscar, Boolean isJustToClone) {
            this.accreditationContact = accreditationContact;
            this.oscar = oscar;
            this.accountId = oscar.Account__c;
            this.accreditationId = oscar.AMS_Online_Accreditation__c;
            this.isCompany = AMS_AccountRoleCreator.recordTypesCompany.contains(accreditationContact.RecordTypeId);
            if(this.isCompany) 
                this.isLinkedWithContactOrCompany = accreditationContact.Company__c != null;
            else
                this.isLinkedWithContactOrCompany = accreditationContact.Contact__c != null 
                                                || (accreditationContact.Person_AMS__c != null && accreditationContact.Person_AMS__r.Contact__c != null);
            this.isJustToClone = isJustToClone;
            this.isOwner = accreditationContact.Agency_owner__c;
        }

        public void createNewContact() {

            contact = AMS_AccreditationContactHelper.populateNewContactFields(new Contact(), accreditationContact);
        }

        public void updateTheContact(Id conId) {

            contact = AMS_AccreditationContactHelper.populateNewContactFields(new Contact(Id = conId), accreditationContact);
        }

        public void createNewCompany() {

            newCompany = AMS_AccreditationContactHelper.populateNewAccountFields(new Account(), accreditationContact);
        }

        public void createNewRole() {

            newRole = new AMS_Account_Role__c();
            newRole.RecordTypeId            = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
            newRole.Account__c              = accountId;
            newRole.Duty__c                 = accreditationContact.Job_Title__c;
            newRole.Employee_Name__c        = accreditationContact.First_Name__c + ' ' + accreditationContact.Last_Name__c;
            newRole.Hours__c                = String.valueOf(accreditationContact.Time_devoted_to_Agency_business__c);
            newRole.IsManager__c            = accreditationContact.Agency_role__c;
            newRole.Percentage__c           = accreditationContact.Financial_Interest__c;
            newRole.Position__c             = accreditationContact.Job_title__c;
            newRole.Owner_Name__c           = (accreditationContact.First_Name__c == null ? '' : accreditationContact.First_Name__c  ) 
                                              + (accreditationContact.Last_Name__c == null ? '' : ( ' ' + accreditationContact.Last_Name__c));
            newRole.Legacy_External_Id__c   = accreditationContact.Legacy_External_Id__c;

            if(isLinkedWithContactOrCompany) {

                if(isCompany)
                    newRole.Owner_Account__c = accreditationContact.Company__c;
                else
                    newRole.Contact__c = accreditationContact.Contact__c == null ? accreditationContact.Person_AMS__r.Contact__c : accreditationContact.Contact__c;
            }
        }

        /*public Boolean isSimilarToRole(AMS_Account_Role__c roleTopParent) {

            return accreditationContact.Job_Title__c                                                == roleTopParent.Duty__c
                && (accreditationContact.First_Name__c + ' ' + accreditationContact.Last_Name__c)   == roleTopParent.Employee_Name__c
                && String.valueOf(accreditationContact.Time_devoted_to_Agency_business__c)          == roleTopParent.Hours__c
                && accreditationContact.Agency_role__c                                              == roleTopParent.IsManager__c
                && accreditationContact.Financial_Interest__c                                       == roleTopParent.Percentage__c
                && accreditationContact.Job_title__c                                                == roleTopParent.Position__c
                && ((accreditationContact.First_Name__c == null 
                    ? '' 
                    : accreditationContact.First_Name__c  ) 
                    + (accreditationContact.Last_Name__c == null 
                    ? '' 
                    : ( ' ' + accreditationContact.Last_Name__c)))                                  == roleTopParent.Owner_Name__c
                && accreditationContact.Legacy_External_Id__c                                       == roleTopParent.Legacy_External_Id__c
                && accreditationContact.Company__c                                                  == roleTopParent.Owner_Account__c
                && (accreditationContact.Contact__c == null 
                    ? accreditationContact.Person_AMS__r.Contact__c 
                    : accreditationContact.Contact__c)                                              == roleTopParent.Contact__c;
        }*/ 
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

/**
 Used for AMS EBulletin:

 Gets the new and old Owners values and saves it in a structure.

*/
    public static OldAndNewOwners getNewAndOldOwnersForChangeCodeCreation( List<AMS_Account_Role__c> allAccountRoles , List<AMS_Accreditation_Contact__c> accreditationContactsToProcess , Set<Id> accounts){

        List<OwnersByAccountWrapper> oldOwnersWrapperList = new List<OwnersByAccountWrapper>();

        List<OwnersByAccountWrapper> newOwnersWrapperList = new List<OwnersByAccountWrapper>();

        for(Id acctId : accounts)
        {
       
            List<OwnerFieldsEntity> oldOwnersList = new List <OwnerFieldsEntity>();

            for (AMS_Account_Role__c acctRole : allAccountRoles)
            {
                if(acctId == acctRole.Account__c)
                    oldOwnersList.add(new OwnerFieldsEntity ((acctRole.Owner_Account__r.Name != null ? acctRole.Owner_Account__r.Name:acctRole.Owner_Name__c) , String.valueOf(acctRole.Percentage__c)));            
            }
            
            OwnersByAccountWrapper oldOwnersWrapper = new OwnersByAccountWrapper(acctId , oldOwnersList);

            oldOwnersWrapperList.add(oldOwnersWrapper);
            

            List<OwnerFieldsEntity> newOwnersList = new List <OwnerFieldsEntity>();

            for (AMS_Accreditation_Contact__c accrtContact : accreditationContactsToProcess)
            {
                if (accrtContact.Agency_owner__c) {
                        String name = (accrtContact.Company__r.name == null ?
                                ((accrtContact.First_Name__c == null ? '' : accrtContact.First_Name__c + ' ') + (accrtContact.Last_Name__c == null ? '' : (accrtContact.Last_Name__c)))
                                : accrtContact.Company__r.name);

                        newOwnersList.add(new OwnerFieldsEntity(name, String.valueOf(accrtContact.Financial_interest__c)));
                }
            }
            
            OwnersByAccountWrapper newOwnersWrapper = new OwnersByAccountWrapper(acctId , newOwnersList);

            newOwnersWrapperList.add(newOwnersWrapper);
            
        }


        return new OldAndNewOwners(oldOwnersWrapperList,newOwnersWrapperList);
                

    }

    public static List<Id> removeFromList(List<Id> listToRemove, Id form ){

        Integer index = -1;

        for(Integer i = 0; i < listToRemove.size() ; i++ ){

            if(listToRemove.get(i) == form)
                index = i;
        }

        if(index != -1 )
            listToRemove.remove(index);

            return listToRemove;
    }

/**

Object used to store the shareholding Information regarding the Ownership

The info of the New and Old Owners is then used in the Change Codes History objects

 */
    public class OldAndNewOwners {
        
        public List<OwnersByAccountWrapper> oldOwnersWrapperList;
        public List<OwnersByAccountWrapper> newOwnersWrapperList;

        public OldAndNewOwners(List<OwnersByAccountWrapper> oldOwnersWrapperList, List<OwnersByAccountWrapper> newOwnersWrapperList){
            this.oldOwnersWrapperList = oldOwnersWrapperList;
            this.newOwnersWrapperList = newOwnersWrapperList;
        }

        public OwnersByAccountWrapper getNewOwnersByAccountId(Id acctId)
        {
            return getOwnersByAccountId( acctId, this.newOwnersWrapperList);
        }

        public OwnersByAccountWrapper getOldOwnersByAccountId(Id acctId)
        {
            return getOwnersByAccountId( acctId, this.oldOwnersWrapperList);
        }

        private OwnersByAccountWrapper getOwnersByAccountId(Id acctId, List<OwnersByAccountWrapper> ownersWrapperList)
        {
             if(ownersWrapperList != null && !ownersWrapperList.isEmpty())
            {
                for(OwnersByAccountWrapper newOwners: ownersWrapperList)
                {
                    if(newOwners.acctId == acctId)
                        return newOwners;

                }
            }
            return null;
        }
        
    }

/**
Groups the Owners by account (in the accont the owners are in the object AMS_Account_Role__c)
 */

    public class OwnersByAccountWrapper {
        
        public Id acctId;
        public List<OwnerFieldsEntity> owners;
        public String allOwnersCSV; 

        public OwnersByAccountWrapper(Id acctId, List<OwnerFieldsEntity> owners){
            this.acctId = acctId;
            this.owners = owners;
            this.allOwnersCSV = processCSVfromOwners();
        }
        public String processCSVfromOwners ()
        {
            String toCSV = 'Name,Percentage\n';


            for(OwnerFieldsEntity owner : this.owners)
                toCSV = toCSV + owner.convertToCSV(',') + '\n';

            return toCSV;


        }
        
    }

/**
 Object to store the Shareholding information of an Owner (Owner Name, Percentage of Ownership)
 */
   
    public class OwnerFieldsEntity implements Comparable {
        
        public String name;
        public String financialInterest;
        
        public OwnerFieldsEntity(){}

        public OwnerFieldsEntity( String name, String financialInterest){
            this.name = name;
            this.financialInterest = financialInterest;
        }

        public String convertToCSV (String csvFormat)
        {
            return name + csvFormat + financialInterest;

        }

        public void decodeFromCSV (String row)
        {
            List<String> onwerValues = row.split(',');

            this.name = onwerValues.get(0);
            this.financialInterest = onwerValues.get(1);
        
        }
        public Integer compareTo(Object compareTo) {
       
            OwnerFieldsEntity compareToOE = (OwnerFieldsEntity)compareTo;
             
            Double order = double.valueOf(financialInterest);
            Double orderCompareTo =  double.valueOf(compareToOE.financialInterest);

            if (order == orderCompareTo) return 0;
            if (order > orderCompareTo) return -1;
            return 1;        
        }
    
    }


    
}
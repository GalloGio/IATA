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

    public static Map<Id,OldAndNewOwners> runRoleCreatorForOnlineAccreditations(Map<Id,Set<Id>> aoMap){
        return runRoleCreatorForOnlineAccreditations(aoMap, false);
    }

    public static Map<Id,OldAndNewOwners> runRoleCreatorForOnlineAccreditations(Map<Id,Set<Id>> aoMap, boolean isCorrectionProcess){

        return runRoleCreatorForOnlineAccreditations(aoMap,isCorrectionProcess, null);

    }

    /**
    This method processes the staging area owners and contacts into the AMS Account roles in the affected agencies.
    If an Accreditation Contact has a direct link to the AMS_Account_role, it tries to update.
    If an Accreditation Contact does not have a direct link, it will deactivate the AMS Account Role and creates a new one.

    The aoMap parameter has a map between the Accreditation Area and the Agencies (accounts) involved in the process.
    */
    public static Map<Id,OldAndNewOwners> runRoleCreatorForOnlineAccreditations(Map<Id,Set<Id>> aoMap, boolean isCorrectionProcess, List<AMS_OSCAR__c> oscars){

        System.debug('Starting to ajust the Owners in the selected hierarchies. isCorrectionProcess variable value is '+ isCorrectionProcess);

        // First, lets get all the data we need from Accreditation Contacts and AMS Account Roles

        Set<Account> accountsToFillOwners = new Set<Account>();

        Set<Id> accreditationAreaIds = aoMap.keyset();
        List<Id> accreditationAreaIdsLst= new List<Id>(accreditationAreaIds);

        if(oscars == null)
            oscars = [SELECT Id, STEP10__c, STEP6__c, RecordType.DeveloperName,Account__c,Account__r.Location_Type__c, Account__r.Top_Parent__r.Id, AMS_Online_Accreditation__c, AMS_Online_Accreditation__r.Id, Process__c from AMS_Oscar__c where AMS_Online_Accreditation__c in :accreditationAreaIdsLst];
        
        system.debug('### su' + oscars.size());
        Map<Id,String> accreditationAndOscars = new Map<Id,String>();

        String oscarProcess;
        Id accountId;   // this is a hack to get the Account from the Oscar. As we are supposed to only work one
                        // OSCAR at a time, let's "assume" that there is only one Account involved.
        for(AMS_Oscar__c oscar: oscars){

            if(processesBlockedToMigrateOwners.contains(oscar.Process__c) && !allowedLocationTypesForNewProcesses.contains(oscar.Account__r.Location_Type__c)){


                accreditationAreaIdsLst = removeFromList(accreditationAreaIdsLst,oscar.AMS_Online_Accreditation__r.Id);

                if(isCorrectionProcess && oscar.STEP10__c == 'Passed' && oscar.STEP6__c == 'Passed'){ // it's the last process to move the owners, so let's select the oscar's account to process.
                    System.debug('Adding the oscar ' + oscar + ' to the list to do migration.');
                    accountsToFillOwners.add(oscar.Account__r);
                }

            }else{
                accreditationAndOscars.put(oscar.AMS_Online_Accreditation__c, oscar.RecordType.DeveloperName);
                accountId = oscar.Account__c;
                oscarProcess = oscar.Process__c;
            }
        }

        //Map by accreditation Id
        Map<Id,OldAndNewOwners> oldAndNewOwnersMap = new Map<Id,OldAndNewOwners>();

        for(Id accreditationId : accreditationAreaIdsLst){

            Set<Id> accounts = aoMap.get(accreditationId);

            String commaSeparatedFields = AMS_AccreditationContactHelper.loadFieldsDynamically('AMS_Accreditation_Contact__c');

            String query = 'SELECT ' + commaSeparatedFields + ', AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c, AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Process__c, Person_AMS__r.Contact__c, RecordType.DeveloperName, AMS_Ownership_Role__r.Id, AMS_Ownership_Role__r.Duty__c,  AMS_Ownership_Role__r.Hours__c, AMS_Ownership_Role__r.IsManager__c, AMS_Ownership_Role__r.Percentage__c, AMS_Ownership_Role__r.Position__c, AMS_Ownership_Role__r.Owner_Account__c,Company__r.name, AMS_Pax_Accreditation_Form__r.ANG_IsNewGenAgency__c ';
            query = query + ' FROM AMS_Accreditation_Contact__c WHERE AMS_Pax_Accreditation_Form__c = :accreditationId AND (RecordTypeId in ';
            query = query + '(' + recordTypesPerson +' ) ';
            query = query + ' OR RecordTypeId in ';
            query = query + '(' + recordTypesCompany+' ) ' + ')';

            List<AMS_Accreditation_Contact__c> accreditationContactsToProcess = database.query(query);

            // Maças, se tiveres que comentar isto desulpa :P
            accreditationContactsToProcess = cleanPersons(accreditationContactsToProcess);

            // need to get all the contacts in case I need later on to update them...
            Map<String, Contact> emailContactMap = new Map<String, Contact>();
            Set<Id> acContactIdSet = new Set<Id>();
            for(AMS_Accreditation_Contact__c ac : accreditationContactsToProcess)
                acContactIdSet.add(ac.Contact__c);

            List<Contact> allContactsFromAccreditation = [SELECT FirstName, LastName, Title, AccountId, Membership_Main_Contact__c, Training_dangerous_goods_completed__c, list_Dangerous_Goods_Awareness__c, Phone, MobilePhone, Fax, BirthDate, Email, ISO_Country__c, RecordTypeId, Id, Name, Financial_Assessment_Contact__c, Authorized_Signatory__c, Designated_portal_admin__c,Invoicing_contact__c  FROM Contact WHERE Id IN :acContactIdSet];

            for(Contact c :allContactsFromAccreditation)
                emailContactMap.put(c.id, c);


            //get all the roles
            List<AMS_Account_Role__c> allAccountRoles = new List<AMS_Account_Role__c>();
            allAccountRoles = [SELECT Id, RecordTypeId, Termination_Date__c, Duty__c, Hours__c, IsManager__c, Percentage__c, Position__c, Account__c, Owner_Account__c, Contact__c, Person__c, Person__r.Contact__c, Legacy_External_ID__c, Legacy_System__c, Owner_Name__c,Owner_Account__r.Name from AMS_Account_role__c where Account__c in: accounts and Active__c = true];

            //Register New and Old Owners for EBulletion Report purposes

            oldAndNewOwnersMap.put(accreditationId,getNewAndOldOwnersForChangeCodeCreation(allAccountRoles,accreditationContactsToProcess,accounts));

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
            system.debug('### su' + accreditationContactsToProcess.size());
            for(AMS_Accreditation_Contact__c aContact :accreditationContactsToProcess){
                

                //does is have a link to an AMS_Account_role ? If so, let's deactivate the Role and add it to the list of new Accreditation to Create.
                if(aContact.AMS_Ownership_Role__c != null && !isCorrectionProcess){
                    accreditationContactsToInsert.add(aContact);
                    continue;
                }
                
                //does is have a link to an AMS_Account_role and is a correction or is
                // second time this process runs for an Accreditation Contact ? let's mark for update.
                //INC304974: verifies if the record type of AMS Accreditation Contact is not a Company (another account)
                if(aContact.AMS_Ownership_Role__c != null && isCorrectionProcess && !recordTypesCompany.contains(aContact.RecordTypeId)){  
                    system.debug('## SU runRoleCreatorForOnlineAccreditations : ' + aContact.AMS_Ownership_Role__c + ' ; '  +isCorrectionProcess+ ' ; ' + aContact.RecordTypeId);   
                    accreditationContactsToUpdate.add(aContact);
                    continue;
                }

                // does not have any Account role linked (is new) - it does not matter if it's a correction or not.
                if(aContact.AMS_Ownership_Role__c == null && aContact.Agency_owner__c){
                    accreditationContactsToInsert.add(aContact);
                    continue;
                }else if(!recordTypesCompany.contains(aContact.RecordTypeId)){
                    accreditationContactsToInsertOnlyContacts.add(aContact);
                    continue;
                }

    
            }


            // to change all the AMS Account Roles in all hierarchies, we have to create a map from a single Accreditation contact
            // to all AMS Acccount Roles that will be updated.
            // for that, we search the AMS Account Role from the Accreditation Contact and try to find it's sinblings.

            Map<AMS_Accreditation_Contact__c,List<AMS_Account_Role__c>> aContactsAndRoles = syncAccreditationsWithRoles(accreditationContactsToProcess,allAccountRoles); 


            if(accreditationAndOscars.get(accreditationId) != 'NEW' || oscarProcess == 'NEW.HO.1.0'){ // this validation is to prevent any deactivations to the hierarchy 

                // In theory, when you remove an Accreditation Contact from the page Manage Owners, that Role has to be deactivated.
                // To find those lost roles, lets subtract the ones fonund by the syncAccreditationsWithRoles from the original list and deactivate them.
                List<AMS_Account_Role__c> lostRoles = findDeletedRoles(aContactsAndRoles,allAccountRoles);

                if(!lostRoles.isEmpty()){

                    for(AMS_Account_Role__c role : lostRoles){

                        if(role.Termination_Date__c == null){
                            
                            role.Termination_Date__c = Date.Today();
                            rolestoDeactivate.add(role);
                        }
                    }

                }

            }

                Set<AMS_Accreditation_Contact__c> contactsToDeactivate = aContactsAndRoles.keySet();
                
                for(AMS_Accreditation_Contact__c acon: contactsToDeactivate){

                    if(acon.AMS_Ownership_Role__c != null && !isCorrectionProcess){

                        for(AMS_Account_Role__c role: aContactsAndRoles.get(acon)){
                            
                            if(role.Termination_Date__c == null){
                                role.Termination_Date__c = Date.Today();
                                rolestoDeactivate.add(role);
                            }
                            
                        }


                    }

                }
            

            if(aContactsAndRoles == null) // opps
                throw new AMS_ApplicationException('Sync Accreditations With Roles went wrong !');

            // now for the new Acreditation Contact, we have to create new AMS Account roles based on the accreditationContactsToInsert list !
            System.debug('Accreditation contacts to insert:'+accreditationContactsToInsert);
            AMS_AccountRoleCreator.RoleCreatorEntitiesBucket bucket1 = insertAMSAccountRoles(accreditationContactsToInsert,emailContactMap, accounts, accreditationAndOscars.get(accreditationId) == 'NEW' || accreditationAndOscars.get(accreditationId) == 'ANG_Agency_Changes',accountId);
            
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
            System.debug(' #### rolestoDeactivate ' + rolestoDeactivate);
            System.debug(' #### amsRolesToInsert ' + amsRolesToInsert);

            upsert amsRolesToInsert;
        
            List<Contact> contactsToUpdate = bucket1.contactsToUpdate.values();
            contactsToUpdate.addAll(bucket2.contactsToUpdate.values());
            contactsToUpdate.addAll(bucket3.contactsToUpdate.values());

            AMS_Utils.runningContactInsertUpdateFromOSCAR = true;
            update contactsToUpdate;
            AMS_Utils.runningContactInsertUpdateFromOSCAR = false;


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

        if(!accountsToFillOwners.isEmpty()){
            System.debug('Cloning Roles from parent using this accounts:' + accountsToFillOwners);
            cloneOwnersFromHo(accountsToFillOwners);

        }

        return oldAndNewOwnersMap;

    }

    public static void cloneOwnersFromHo(Set<Account> accounts){

        Map<Id,List<AMS_Account_role__c>> rolesInAccounts = new Map<Id,List<AMS_Account_role__c>>();

        Set<Id> topParents = new Set<Id>();

        for(Account acct : accounts){

            if(acct.Top_Parent__c != null)
                topParents.add(acct.Top_Parent__r.Id);

        }

         List<AMS_Account_role__c> allRoles =  Database.query(AMS_QueryUtils.getAllFieldQuery('AMS_Account_role__c',null, + 'Account__c in:topParents', false) );

         for(AMS_Account_Role__c role: allRoles){

            if(!role.Active__c)
                continue;
                
            if(rolesInAccounts.containsKey(role.Account__c)){

                rolesInAccounts.get(role.Account__c).add(role);

            }
            else{

                rolesInAccounts.put(role.Account__c, new List<AMS_Account_Role__c>{role});
            }

         }

        List<AMS_Account_Role__c> rolesToInsert = new List<AMS_Account_role__c>();

        List<AMS_Account_role__c> rolesToDeactivate = new List<AMS_Account_role__c>();

        List<AMS_Account_role__c> oldRoles =  Database.query(AMS_QueryUtils.getAllFieldQuery('AMS_Account_role__c',null, + 'Account__c in:accounts', false) );

        for(AMS_Account_Role__c role: oldRoles){
            if(role.Active__c){
                role.Termination_Date__c = Date.Today();
                rolesToDeactivate.add(role);
            }
        }

        for(Account acct : accounts){

            if(rolesInAccounts.get(acct.Top_Parent__c) != null)
                rolesToInsert.addAll(assignOwners(acct.Id,rolesInAccounts.get(acct.Top_Parent__c)));

        }

        if(!rolesToDeactivate.isEmpty()){
            System.debug('Roles to deactivate:'+rolesToDeactivate);
            update rolestoDeactivate;
        }

        if(!rolesToInsert.isEmpty()){
            System.debug('Roles to insert:'+rolesToInsert);
            insert rolesToInsert;
        }

        
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

    //when we have an accreditation contact without any link to a contact but with a link to a person
    //then we create the contact and delete the person but before deleting the person we should check:
    //if the person was linked to any account role, we need to update those account roles with the lookup to the new contact
    public static List<AMS_Accreditation_Contact__c> cleanPersons(List<AMS_Accreditation_Contact__c> contacts){

        List<AMS_Accreditation_Contact__c> aContactsToUpdate = new List<AMS_Accreditation_Contact__c>();

        Set<Id> personsToDelete = new Set<Id>();

        Map<AMS_Accreditation_Contact__c, Id> accreditationsAndContacts = new Map<AMS_Accreditation_Contact__c, Id>();

        Map<Id, Id> personsAndContacts = new Map<Id, Id>();

        Map<Id, Contact> personsAndContactsObj = new Map<Id, Contact>();

        Map<String, Contact> newContactsToInsert = new Map<String, Contact>();

        for(AMS_Accreditation_Contact__c ac: contacts){

            if(ac.Person_AMS__c != null && ac.Person_AMS__r.Contact__c == null && ac.Contact__c == null){ // we have to create a new contact
        
                if(newContactsToInsert.get(ac.email__c) == null){ // this is only for new created contacts, not updates.

                    Contact con = new Contact();

                    con = AMS_AccreditationContactHelper.populateNewContactFields(con, ac);
                    newContactsToInsert.put(con.Email, con);

                    //accreditationsAndContacts.put(ac,con);
                    personsToDelete.add(ac.Person_AMS__c);
                    personsAndContactsObj.put(ac.Person_AMS__r.Id,con);
                }

                continue;
            }

            if(ac.Person_AMS__c != null && ac.Person_AMS__r.Contact__c == null && ac.Contact__c != null){ // we dont have to create a new contact, just update the AC

                accreditationsAndContacts.put(ac,ac.Contact__c);

                personsToDelete.add(ac.Person_AMS__c);

                personsAndContacts.put(ac.Person_AMS__r.Id,ac.Contact__c);

                continue;
            }


            if(ac.Person_AMS__c != null && ac.Person_AMS__r.Contact__c != null && ac.Contact__c == null){ // we dont have to create a new contact, just update the AC

                accreditationsAndContacts.put(ac,ac.Person_AMS__r.Contact__c);

                personsToDelete.add(ac.Person_AMS__c);

                personsAndContacts.put(ac.Person_AMS__r.Id,ac.Person_AMS__r.Contact__c);

                continue;
            }

            if(ac.Person_AMS__c != null && ac.Person_AMS__r.Contact__c != null && ac.Contact__c != null){ // we dont have to create a new contact, just update the AC

                accreditationsAndContacts.put(ac,ac.Contact__c);

                personsToDelete.add(ac.Person_AMS__c);

                personsAndContacts.put(ac.Person_AMS__r.Id,ac.Person_AMS__r.Contact__c);

                continue;
            }

        }


        if(!newContactsToInsert.isEmpty()){
            AMS_Utils.runningContactInsertUpdateFromOSCAR = true;
            system.debug('ANG INSERT 1');
            insert verifyNoDuplicateIFAPcontactExists(newContactsToInsert.values());
            AMS_Utils.runningContactInsertUpdateFromOSCAR = false;
        }




        for(AMS_Accreditation_Contact__c ac: contacts){

            if(accreditationsAndContacts.get(ac) != null){
                ac.Contact__c = accreditationsAndContacts.get(ac);
                ac.Person_AMS__c = null;
                aContactsToUpdate.add(ac);
            }
            else
                if(newContactsToInsert.get(ac.email__c) != null){
                    ac.Contact__c = newContactsToInsert.get(ac.email__c).Id;
                    ac.Person_AMS__c = null;
                    aContactsToUpdate.add(ac);
                }
        }

        System.debug('List of persons to delete:' + personsToDelete);

        // before deleting the persons, let's update any AMS Account Roles that have those persons associated ...

        updateAMSRolesBeforePersonDeletion(personsToDelete,personsAndContacts,personsAndContactsObj);

        if(!personsToDelete.isEmpty()){
        
            List<AMS_Person__c> personDeletionList = [select id, Name from AMS_Person__c where id in :personsToDelete];

            if(personDeletionList.size() > 0){
                delete personDeletionList;
            }
        }

        if(!aContactsToUpdate.isEmpty())
            update aContactsToUpdate;

        return contacts;


    }

    public static void updateAMSRolesBeforePersonDeletion(Set<Id> personsToDelete, Map<Id, Id> personsAndContacts , Map<Id, Contact> personsAndContactsObj){

        // first lets find the AMS Account Roles to Update

        if(personsToDelete.isEmpty() || ( personsAndContacts.values().isEmpty() && personsAndContactsObj.values().isEmpty() ) ) // nothing to do here ...
            return;

        List<AMS_Account_Role__c> rolesToUpdate = new List<AMS_Account_Role__c>();

        List<AMS_Account_Role__c> roles = [SELECT ID , Contact__c, Person__c from AMS_Account_Role__c where Person__c in :personsToDelete];

        for(AMS_Account_Role__c role: roles){

            if(role.Contact__c == null && ( personsAndContacts.get(role.Person__c) != null || personsAndContactsObj.get(role.Person__c) != null) ){

                role.Contact__c = personsAndContacts.get(role.Person__c) != null ? personsAndContacts.get(role.Person__c) : personsAndContactsObj.get(role.Person__c).Id;

                rolesToUpdate.add(role);

            }

        }

        if(!rolesToUpdate.isEmpty())
            update rolesToUpdate;

    }

    public static List<AMS_Account_Role__c> findDeletedRoles(Map<AMS_Accreditation_Contact__c,List<AMS_Account_Role__c>> accreditationsAndRoles, List<AMS_Account_Role__c> allRoles){
        
        List<AMS_Account_Role__c> toDeleteRoles = new List<AMS_Account_Role__c>();
        Set<AMS_Accreditation_Contact__c> contactsToDeactivate = accreditationsAndRoles.keySet();

        Set<Id> rolesInMap = new Set<Id>();

        for(AMS_Accreditation_Contact__c aCon : contactsToDeactivate){

            List<AMS_Account_Role__c> tmp = accreditationsAndRoles.get(aCon);

            for(AMS_Account_Role__c role : tmp)
                rolesInMap.add(role.Id);

        }

        for(AMS_Account_Role__c role : allRoles){

            if(!rolesInMap.contains(role.Id))
                toDeleteRoles.add(role);

        }


        return toDeleteRoles;

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

            if(orginal == null){ // this shouldn't be happening, because we have find somehow one AMS Account Role if ac.AMS_Ownership_Role__c != null ...
                throw new AMS_ApplicationException('Sync Accreditations With Roles went wrong !'+ac);
                return null; // ooppss....
            }
        
            // now let's find his siblings 
            for(AMS_Account_Role__c role: allAccountRoles){

                if(role.RecordTypeId == orginal.RecordTypeId && role.Percentage__c == orginal.Percentage__c && 
                  (role.Contact__c == orginal.Contact__c && role.Person__c == orginal.Person__c && role.Owner_Account__c == orginal.Owner_Account__c &&  role.Owner_Name__c == orginal.Owner_Name__c/*&& role.Legacy_External_ID__c == orginal.Legacy_External_ID__c*/))
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
                
                    Contact contactToUpdate = AMS_AccreditationContactHelper.updateNewContactFields(emailContactMap.get(ac.Contact__c), ac);

                    if(contactToUpdate != null) // has a change to be updated
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
            AMS_Utils.runningContactInsertUpdateFromOSCAR = true;
            system.debug('ANG INSERT 2');
            insert verifyNoDuplicateIFAPcontactExists(newContactsToInsert.values());
            AMS_Utils.runningContactInsertUpdateFromOSCAR = false;
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

        
        role.Duty__c            = ac.Job_Title__c;
        role.Hours__c           = String.valueOf(ac.Time_devoted_to_Agency_business__c);
        role.IsManager__c       = ac.Agency_role__c;
        role.Percentage__c      = ac.Financial_Interest__c;
        role.Position__c        = ac.Job_title__c;
        role.Legacy_External_Id__c = ac.Legacy_External_Id__c;

        if(ac.Agency_owner__c)
        {
            role.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
            role.Owner_Name__c      = (ac.First_Name__c == null ? '' : ac.First_Name__c  ) + (ac.Last_Name__c == null ? '' : ( ' ' + ac.Last_Name__c));
        }else
        {
            system.debug('updateAmsAccountRole -> Terminating role which is no longer an owner: ' + role);
            role.Termination_Date__c = Date.today();
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
            
                Contact contactToUpdate = AMS_AccreditationContactHelper.UpdateNewContactFields(emailContactMap.get(ac.Contact__c), ac);

                if(contactToUpdate != null) // has a change to be updated
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
            AMS_Utils.runningContactInsertUpdateFromOSCAR = true;
            insert verifyNoDuplicateIFAPcontactExists(newContactsToInsert.values());
            AMS_Utils.runningContactInsertUpdateFromOSCAR = false;
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

                role.RecordTypeId       = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');

                role.Account__c         = accountId;
                role.Duty__c            = ac.Job_Title__c;
                role.Employee_Name__c   = ac.First_Name__c + ' ' + ac.Last_Name__c;
                role.Hours__c           = String.valueOf(ac.Time_devoted_to_Agency_business__c);
                role.IsManager__c       = ac.Agency_role__c;
                role.Percentage__c      = ac.Financial_Interest__c;
                role.Position__c        = ac.Job_title__c;
                role.Owner_Name__c      = (ac.First_Name__c == null ? '' : ac.First_Name__c  ) + (ac.Last_Name__c == null ? '' : ( ' ' + ac.Last_Name__c));
                role.Legacy_External_Id__c = ac.Legacy_External_Id__c;

                if(ac.Contact__c == null && (ac.Person_AMS__c == null || (ac.Person_AMS__c != null && ac.Person_AMS__r.Contact__c == null))) // meaning it's a company.
                    role.Owner_Account__c = ac.Company__c;
                else
                    role.Contact__c = ac.Contact__c == null ? ac.Person_AMS__r.Contact__c : ac.Contact__c;


                // has the user changed anything on the contact ? well, let's update them.
                if(emailContactMap.get(ac.Contact__c) != null && ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c == accountId) {

                    Contact contactToUpdate = AMS_AccreditationContactHelper.updateNewContactFields(emailContactMap.get(ac.Contact__c), ac);
    
                    if(contactToUpdate != null) // has a change to be updated
                        contactsToUpdate.put(contactToUpdate.email, contactToUpdate);
                }

                rolesToInsert.add(role);

                if(ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c == accountId)
                    accreditationsToUpdate.put(ac,role); // adding now to update the Accreditation Contact with the new ID from the AMS Account Role.

            }
        }

        Map<String, Contact> newContactsToInsert = new Map<String, Contact>();
        Map<String, Account> newAccountsToInsert = new Map<String, Account>();

        // for bulk reasons, we need to first create all contacts and then create the AMS Account Roles with the Id from the contacts created.
        for(AMS_Accreditation_Contact__c ac: toCreateEntities){ 


            if(AMS_AccreditationContactController.accreditationContactRT.get(ac.RecordTypeId) != 'Company' && newContactsToInsert.get(ac.email__c) == null && (ac.Email__c != null ||(ac.Phone__c != null && ac.Phone__c != '-'))){

                Contact con = new Contact();
                con = AMS_AccreditationContactHelper.populateNewContactFields(con, ac);
                
                newContactsToInsert.put(con.Email, con);

            }else if(AMS_AccreditationContactController.accreditationContactRT.get(ac.RecordTypeId) == 'Company' && newContactsToInsert.get(ac.Registration_number__c) == null && String.isNotEmpty(ac.Registration_number__c)){

                Account acc = new Account();
                acc = AMS_AccreditationContactHelper.populateNewAccountFields(acc, ac);

                newAccountsToInsert.put(acc.Registration_number__c, acc);

            }

        }

        if(!newContactsToInsert.isEmpty()){
            AMS_Utils.runningContactInsertUpdateFromOSCAR = true;
            system.debug('ANG INSERT 4');
            insert verifyNoDuplicateIFAPcontactExists(newContactsToInsert.values());
            AMS_Utils.runningContactInsertUpdateFromOSCAR = false;
        }

        if(!newAccountsToInsert.isEmpty()) insert newAccountsToInsert.values();


        // now that we have the contacts and accounts inserted, let's create the roles with this contacts.

        for(Id accountId: accounts) {
            for(AMS_Accreditation_Contact__c ac: toCreateEntities){

                Contact con = newContactsToInsert.get(ac.Email__c);
                Account acc = newAccountsToInsert.get(ac.Registration_number__c);

                AMS_Account_Role__c role = new AMS_Account_Role__c();

                role.RecordTypeId       = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
                role.Account__c         = accountId;
                role.Duty__c            = ac.Job_Title__c;
                role.Employee_Name__c   = ac.First_Name__c + ' ' + ac.Last_Name__c;
                role.Hours__c           = String.valueOf(ac.Time_devoted_to_Agency_business__c);
                role.IsManager__c       = ac.Agency_role__c;
                role.Percentage__c      = ac.Financial_Interest__c;
                role.Position__c        = ac.Job_title__c;
                role.Owner_Name__c      = (ac.First_Name__c == null ? '' : ac.First_Name__c  ) + (ac.Last_Name__c == null ? '' : ( ' ' + ac.Last_Name__c));

                if(con != null) role.Contact__c = con.Id;
                if(acc != null) role.Owner_Account__c = acc.Id;

                role.Legacy_External_Id__c = ac.Legacy_External_Id__c;
                rolesToInsert.add(role);

                if(ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c == accountId){
                    
                    if(con != null) ac.Contact__c = con.Id;
                    if(acc != null) ac.Company__c = acc.Id;

                    accreditationsToUpdate.put(ac,role); // adding now to update the Accreditation Contact with the new ID from the AMS Account Role.
                }
            }
        }

        // contactsToUpdate having all the contacts to update
        // rolesToInsert having all the new roles to insert
        // accreditationsToUpdate having all the new mappings from Accreditation to AMS Account Roles

        return new AMS_AccountRoleCreator.RoleCreatorEntitiesBucket(accreditationsToUpdate,rolesToInsert,contactsToUpdate);
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

            //****process allAccountRoles (Old Owners recovered from Account)
       
            List<OwnerFieldsEntity> oldOwnersList = new List <OwnerFieldsEntity>();

            for (AMS_Account_Role__c acctRole : allAccountRoles)
            {
                if(acctId == acctRole.Account__c)
                    oldOwnersList.add(new OwnerFieldsEntity ((acctRole.Owner_Account__r.Name != null ? acctRole.Owner_Account__r.Name:acctRole.Owner_Name__c) , String.valueOf(acctRole.Percentage__c)));            
            }
            
            OwnersByAccountWrapper oldOwnersWrapper = new OwnersByAccountWrapper(acctId , oldOwnersList);

            system.debug('oldOwnersWrapper: ' + oldOwnersWrapper);

            oldOwnersWrapperList.add(oldOwnersWrapper);

            

            //****process accreditationContactsToProcess (new Owners Recovered from Staging Area)
            

            List<OwnerFieldsEntity> newOwnersList = new List <OwnerFieldsEntity>();

            for (AMS_Accreditation_Contact__c accrtContact : accreditationContactsToProcess)
            {
                if (accrtContact.Agency_owner__c) {
                    if (!accrtContact.AMS_Pax_Accreditation_Form__r.ANG_IsNewGenAgency__c) {

                        String name = (accrtContact.Company__r.name == null ?
                                ((accrtContact.First_Name__c == null ? '' : accrtContact.First_Name__c + ' ') + (accrtContact.Last_Name__c == null ? '' : (accrtContact.Last_Name__c)))
                                : accrtContact.Company__r.name);

                        newOwnersList.add(new OwnerFieldsEntity(name, String.valueOf(accrtContact.Financial_interest__c)));

                    } else {

                        String name = (accrtContact.First_Name__c == null && accrtContact.Last_Name__c == null)
                                ? accrtContact.Company__r.name
                                : (accrtContact.First_Name__c == null ? '' : accrtContact.First_Name__c + ' ') + (accrtContact.Last_Name__c == null ? '' : accrtContact.Last_Name__c);

                        newOwnersList.add(new OwnerFieldsEntity(name, String.valueOf(accrtContact.Financial_interest__c)));

                    }
                }
            }
            
            OwnersByAccountWrapper newOwnersWrapper = new OwnersByAccountWrapper(acctId , newOwnersList);

            system.debug('newOwnersWrapper: ' + newOwnersWrapper.allOwnersCSV);

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
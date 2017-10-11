public with sharing class AMS_AccreditationContactHelper
{
    
    public static Map<String, AMS_Account_Role__c> findRolesAndPersonsByEmail(Set<String> emailSet, Set<Id> acPersonSet)
    {
        String commaSeparatedFields = AMS_AccreditationContactHelper.loadFieldsDynamically('AMS_Account_Role__c');
        String query = 'select ' + commaSeparatedFields;
        query = query + ', Person__r.Email__c, Person__r.Contact__r.Id, Person__r.First_Name__c, Person__r.LastName__c, Person__r.Phone__c, ' + 
                        'Person__r.Contact__r.Email, Contact__r.Id, Contact__r.AccountId ';
        query = query + ' from AMS_Account_Role__c where RecordTypeId = \'' + AMS_Utils.getId('AMS_Account_Role__c', 'Employee') + '\' and (Person__r.Email__c in :emailSet or Person__r.Id in :acPersonSet)';
        List<AMS_Account_Role__c> roleList = Database.query(query);
        Map<String, AMS_Account_Role__c> rolePersonMap = new Map<String, AMS_Account_Role__c>();
        for(AMS_Account_Role__c ar : roleList)
        {
            if(rolePersonMap.get(ar.Person__r.Email__c) == null){
                rolePersonMap.put(ar.Person__r.Email__c, ar);
            } else {
                // TODO at a later stage. Right now we are safe to assume that emails are unique and there should not be Persons using the same email.
            }
        }
        return rolePersonMap;
    }
    
    public static Map<String, AMS_Account_Role__c> findRolesAndContactsByEmail(Set<String> emailSet, Set<Id> acContactSet)
    {
        String commaSeparatedFields = AMS_AccreditationContactHelper.loadFieldsDynamically('AMS_Account_Role__c');
        String query = 'select ' + commaSeparatedFields;
        query = query + ', Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact__r.Phone, Contact__r.Title, Contact__r.Membership_Main_Contact__c ';
        //query = query + ' from AMS_Account_Role__c where RecordTypeId = \'' + AMS_Utils.getId('AMS_Account_Role__c', 'Employee') + '\' and Person__c = null and (Contact__r.Email in :emailSet or Contact__r.Id in :acContactSet)';
        query = query + ' from AMS_Account_Role__c where RecordTypeId = \'' + AMS_Utils.getId('AMS_Account_Role__c', 'Ownership') + '\' and Person__c = null and (Contact__r.Email in :emailSet or Contact__r.Id in :acContactSet)';
        List<AMS_Account_Role__c> roleList = Database.query(query);
        Map<String, AMS_Account_Role__c> roleContactMap = new Map<String, AMS_Account_Role__c>();
        for(AMS_Account_Role__c ar : roleList)
        {
            if(roleContactMap.get(ar.Contact__r.Email) == null){
                roleContactMap.put(ar.Contact__r.Email, ar);
            } else {
                // TODO at a later stage. Right now we are safe to assume that emails are unique and there should not be Persons using the same email.
            }
        }
        return roleContactMap;
    }
    
    /* DNG - not being used 
    public static List<AMS_Account_Role__c> findAllRolesForAccount(String accountId)
    {
        String commaSeparatedFields = AMS_AccreditationContactHelper.loadFieldsDynamically('AMS_Account_Role__c');
        String query = 'select ' + commaSeparatedFields;
        query = query + ', Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact__r.Phone, Contact__r.Title, Contact__r.Membership_Main_Contact__c ';
        query = query + ' Person_AMS__r.Email__c from AMS_Account_Role__c where RecordTypeId = \'' + AMS_Utils.getId('AMS_Account_Role__c', 'Employee') + '\' and Account = :accountId';
        List<AMS_Account_Role__c> roleList = Database.query(query);
        return roleList;
    }
    */
    
    
    public static Map<Id, Contact> findContactsByEmail(Set<String> emailSet)
    {
        Map<ID, Contact> contactMap = new Map<Id, Contact>([select Id, Email from Contact where Email in :emailSet limit 49999]);
        return contactMap;
    }
    
    public static Map<ID, AMS_Person__c> findPersonsByEmail(Set<String> emailSet)
    {
        Map<ID, AMS_Person__c> personMap = new Map<Id, AMS_Person__c>([select Id, Email__c from AMS_Person__c where Email__c in :emailSet limit 49999]);
        return personMap;
    }
    
    
    public static void insertAmsRolesForAccreditationContacts(List<AMS_AccreditationContactController.AccreditationContactWrapper> wrapperList)
    {
        // remember to check whether the Contact__c linking on Person has a value. If it does, utilize that Contact instead of the Person
        List<AMS_Account_Role__c> roleList = new List<AMS_Account_Role__c>();
        List<AMS_Accreditation_Contact__c> acList = new List<AMS_Accreditation_Contact__c>();
        Set<Id> idSet = new Set<Id>();
        for(AMS_AccreditationContactController.AccreditationContactWrapper wrapped : wrapperList)
        {
            idSet.add(wrapped.recordId);
            acList.add(wrapped.ac);
        }
        Map<Id, AMS_Person__c> idPersonMap = new Map<Id, AMS_Person__c>([select id, Contact__c, Email__c from AMS_Person__c where id in :idSet]);
        for(AMS_AccreditationContactController.AccreditationContactWrapper wrapped : wrapperList)
        {
            if(idPersonMap.get(wrapped.recordId) != null) // check if the AMS_Person__c record has a link to a Contact
            {
                if(IdPersonMap.get(wrapped.recordId).Contact__c != null) // linked, so update ac.Contact__c so it gets handled properly in the next step
                {
                    wrapped.ac.Contact__c = IdPersonMap.get(wrapped.recordId).Contact__c;
                    roleList.add(createAmsAccountRole(wrapped.ac));
                } else // no linking to Contact
                {
                    roleList.add(createAmsAccountRole(wrapped.ac));
                }
            } else // handle the ones with no linking at all
            {
                roleList.add(createAmsAccountRole(wrapped.ac));
            }
        }
        System.debug('**** new Roles: '+roleList);
        
        insert roleList;
    }
    
    public static AMS_Account_Role__c createAmsAccountRole(AMS_Accreditation_Contact__c ac)
    {
        AMS_Account_Role__c role = new AMS_Account_Role__c();
        if(ac.Contact__c != null)
        {
            role.Contact__c = ac.Contact__c;
            role.Person__c = null;
        }
        else if(ac.Person_AMS__c != null)
        {
            role.Person__c = ac.Person_AMS__c;
        }
        else // no linking, contact already created before calling this method
        {}
        
         
        role.Account__c         = ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c;
        role.Duty__c            = ac.Job_Title__c;
        role.Employee_Name__c   = ac.First_Name__c + ' ' + ac.Last_Name__c;
        role.Hours__c           = String.valueOf(ac.Time_devoted_to_Agency_business__c);
        role.IsManager__c       = ac.Agency_role__c;
        role.Percentage__c      = ac.Financial_Interest__c;
        role.Position__c        = ac.Job_title__c;
        // role.Registration_Date__c = ac.AMS_Pax_Accreditation_Form__r.CreatedDate.date(); TODO: confirm this
        
        if(ac.Agency_owner__c)
        {
            role.Owner_Name__c      = (ac.First_Name__c != null) ? ac.First_Name__c + ' ' + ac.Last_Name__c : ac.Last_Name__c;
            role.RecordTypeId = AMS_Utils.getId('AMS_Account_Role__c', 'Ownership');
            
            // This is actually not needed for person owners
            //if(ac.RecordTypeId == AMS_Utils.AccreditationContactCompanyRT)
            if(AMS_AccountRoleCreator.companyDeveloperName.containsKey(ac.RecordType.DeveloperName)){
                role.Owner_Name__c = createCompanyName(ac.First_Name__c,ac.Last_Name__c);
                 role.Owner_Account__c = ac.Company__c;

            }
        }
        //TD: Removed Employee from Role. Keep them on Contact object only
        /* else
        {
            // DANI: remove this! role.RecordTypeId = AMS_Utils.getId('AMS_Account_Role__c', 'Employee');
            role.RecordTypeId = AMS_Utils.getId('AMS_Account_Role__c', 'Employee');
        }*/
        return role;
    }
    
    private static String createCompanyName(String firstName, String lastName){
        String toReturn = '';

        if(firstName != null && firstName.trim() != '')
            toReturn = firstName;

        if(lastName != null && lastName.trim() != '')
            toReturn+= ' ' + lastName;


        return toReturn;
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
        else // no linking, contact already created before calling this method
        {}
        
        role.Account__c         = ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c;
        role.Duty__c            = ac.Job_Title__c;
        //role.Employee_Name__c     = ac.First_Name__c + ' ' + ac.Last_Name__c;
        role.Hours__c           = String.valueOf(ac.Time_devoted_to_Agency_business__c);
        role.IsManager__c       = ac.Agency_role__c;
        role.Percentage__c      = ac.Financial_Interest__c;
        role.Position__c        = ac.Job_title__c;
        
        if(ac.Agency_owner__c)
        {
            // role.Owner_Account__c    = ac.Company__c;
            //role.Owner_Name__c        = ac.First_Name__c + ' ' + ac.Last_Name__c;
            role.RecordTypeId = AMS_Utils.getId('AMS_Account_Role__c', 'Ownership');
            role.Owner_Name__c      = (ac.First_Name__c == null ? '' : ac.First_Name__c  ) + (ac.Last_Name__c == null ? '' : ( ' ' + ac.Last_Name__c));
        }
        //TD: Removed Employee from Role. Keep them on Contact object only
        /*
         else
        {
            role.RecordTypeId = AMS_Utils.getId('AMS_Account_Role__c', 'Employee');
        }*/
        return role;
    }
    
    public static AMS_Account_Role__c createAmsRoleForAccount(AMS_Accreditation_Contact__c ac)
    {
        AMS_Account_Role__c role;// = new AMS_Account_Role__c();
        if(ac.Company__c != null)
        {
            role = new AMS_Account_Role__c();
            role.Account__c         = ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c;
            role.Owner_Account__c   = ac.Company__c;
            role.Percentage__c      = ac.Financial_Interest__c;
            role.RecordTypeId = AMS_Utils.getId('AMS_Account_Role__c', 'Ownership');
        }
        return role;
    }
    
    public static AMS_Account_Role__c updateAmsRoleForAccount(AMS_Account_Role__c role, AMS_Accreditation_Contact__c ac)
    {
        if(role != null && ac.Company__c != null)
        {
            role.Account__c         = ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c;
            role.Owner_Account__c   = ac.Company__c;
            role.Percentage__c      = ac.Financial_Interest__c;
            role.RecordTypeId = AMS_Utils.getId('AMS_Account_Role__c', 'Ownership');
        }
        return role;
    }
    
    public static Contact populateNewContactFields(Contact con, AMS_Accreditation_Contact__c ac)
    {
        con.FirstName = ac.First_Name__c;
        con.LastName = ac.Last_Name__c;
        con.Title = ac.Job_Title__c;
        if(con.AccountId==null)
           con.AccountId = ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c;
        con.Membership_Main_Contact__c = ac.Membership_Main_Contact__c;
        con.Financial_Assessment_Contact__c = ac.Financial_Assessment_Contact__c;
        con.Phone = ac.Phone__c;
        con.Mobilephone = ac.Mobile__c;
        con.Fax = ac.FAX__c;
        con.Birthdate = ac.Birthdate__c;
        con.Email = ac.Email__c;
        con.ISO_Country__c = ac.ISO_Country__c;
        con.RecordTypeId = AMS_Utils.getId('Contact', 'Standard_Contact');
        con.Training_dangerous_goods_completed__c = ac.Training_dangerous_goods_completed__c;
        con.list_Dangerous_Goods_Awareness__c = ac.list_Dangerous_Goods_Awareness__c;
        con.Authorized_Signatory__c = ac.Authorised_signatory__c;
        con.Designated_Portal_Admin__c = ac.Portal_administrator__c;
        con.Invoicing_Contact__c = ac.Invoicing_Contact__c;
        if (ac.AddressStreet__c != null) con.OtherStreet =  ac.AddressStreet__c;
        if (ac.AddressCity__c != null) con.OtherCity =  ac.AddressCity__c;
        if (ac.AddressPostcode__c != null) con.OtherPostalCode =  ac.AddressPostcode__c;
        if (ac.AddressCountry__c != null) con.OtherCountry =  ac.AddressCountry__c;
        return con;
    }

    public static Account populateNewAccountFields(Account acc, AMS_Accreditation_Contact__c ac)
    {
        acc.Name = ac.Name;
        acc.Legal_Name__c = ac.Name;
        acc.Registration_Number__c = ac.Registration_Number__c;
        acc.RecordTypeId = AMS_Utils.getId('Account', 'Standard_Account');

        return acc;
    }
    
    public static String loadFieldsDynamically(String SobjectApiName)
    {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        String commaSeparatedFields = '';
        for(String fieldName : fieldMap.keyset())
        {
            if(commaSeparatedFields == null || commaSeparatedFields == '')
            {
                commaSeparatedFields = fieldName;
            } else
            {
                commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
            }
        }
        return commaSeparatedFields;
    }
    
    public static List<Contact> findContactsByNameOrEmail(String firstName, String lastName, String email)
    {
        String standardContactRtId = AMS_Utils.getId('Contact', 'Standard_Contact');

        String query = 'select Id, FirstName, LastName, Title, AccountId, Membership_Main_Contact__c, MailingCountry, MailingState, ' + 
                        'MailingStreet, MailingCity, MailingPostalCode, Phone, Mobilephone, Fax, Financial_Assessment_Contact__c, Birthdate, Email, ISO_Country__c, RecordTypeId ' +
                        'from Contact where Status__c = \'Active\' and RecordTypeId = \'' +standardContactRtId + '\' ';

        if(firstName != '' && lastName != '' && email != '')
        {
            query = query + ' and ((firstName like \'%' + firstName + '%\' and lastName like \'%' + lastName + '%\') or email = \'' + email + '\')'; 
        } else if (firstName != '' && lastName != '' && email == '')
        {
            query = query + ' and (firstName like \'%' + firstName + '%\' and lastName like \'%' + lastName + '%\')';
        } else if((firstName == '' || lastName == '') && email != '')
        {
            query = query + ' and email = \'' + email + '\'';
        }
        System.debug('**** query: '+query);
        return Database.query(query);
        
    }
    
    public static List<AMS_Person__c> findPersonsByNameOrEmail(String firstName, String lastName, String email)
    {
        String query = 'select Id, First_Name__c, LastName__c, Contact__c, Fax__c, Mobile__c, Phone__c, Email__c, Industry_start_date__c from AMS_Person__c where';
        if(firstName != '' && lastName != '' && email != '')
        {
            query = query + ' ((First_Name__c like \'%' + firstName + '%\' and LastName__c like \'%' + lastName + '%\') or email__c = \'' + email + '\')'; 
        } else if (firstName != '' && lastName != '' && email == '')
        {
            query = query + ' (First_Name__c like \'%' + firstName + '%\' and LastName__c like \'%' + lastName + '%\')';
        } else if((firstName == '' || lastName == '') && email != '')
        {
            query = query + ' email__c = \'' + email + '\'';
        }
        
        return Database.query(query);
    }

    public static AMS_Accreditation_Contact__c createAccreditationContactFromAccountRole(AMS_Account_Role__c role, Id onlineAccreditationId)
    {
        AMS_Accreditation_Contact__c accreditationContact = new AMS_Accreditation_Contact__c();

        accreditationContact.Agency_owner__c = true;
        accreditationContact.AMS_Pax_Accreditation_Form__c = onlineAccreditationId;
        accreditationContact.Financial_Interest__c = role.Percentage__c;
        accreditationContact.Last_Name__c = '_';

        //contact/person owners
        if(role.Contact__c != null || role.Person__c != null)
        {
            accreditationContact.Contact__c = role.Contact__c;
            accreditationContact.Person_AMS__c = role.Person__c;

            accreditationContact.Job_Title__c = role.Position__c;
            accreditationContact.Agency_role__c = role.IsManager__c;

            //accreditationContact.Company__c = role.Owner_Account__c;
            if(role.Hours__c != null)
                accreditationContact.Time_devoted_to_Agency_business__c = Double.valueOf(role.Hours__c);
            accreditationContact.RecordTypeId = AMS_Utils.AccreditationContactPersonRT;

            //get remaining data from the contact or person
            if(role.Contact__c != null){
                accreditationContact.First_Name__c = role.Contact__r.FirstName;
                accreditationContact.Last_Name__c = role.Contact__r.LastName;
                accreditationContact.Membership_Main_Contact__c = role.Contact__r.Membership_Main_Contact__c;
                accreditationContact.Financial_Assessment_Contact__c = role.Contact__r.Financial_Assessment_Contact__c;
                accreditationContact.Phone__c = role.Contact__r.Phone;
                accreditationContact.Mobile__c = role.Contact__r.Mobilephone;
                accreditationContact.FAX__c = role.Contact__r.Fax;
                accreditationContact.Birthdate__c = role.Contact__r.Birthdate;
                accreditationContact.Email__c = role.Contact__r.Email;
                accreditationContact.ISO_Country__c = role.Contact__r.ISO_Country__c;
                accreditationContact.Training_dangerous_goods_completed__c = role.Contact__r.Training_dangerous_goods_completed__c;
                accreditationContact.list_Dangerous_Goods_Awareness__c = role.Contact__r.list_Dangerous_Goods_Awareness__c;
            }
            else{
                accreditationContact.First_Name__c = role.Person__r.First_Name__c;
                accreditationContact.Last_Name__c = role.Person__r.Lastname__c;
                accreditationContact.Phone__c = role.Person__r.Phone__c;
                accreditationContact.Mobile__c = role.Person__r.Mobile__c;
                accreditationContact.FAX__c = role.Person__r.Fax__c;
                accreditationContact.Birthdate__c = role.Person__r.DOB__c;
                accreditationContact.Email__c = role.Person__r.Email__c;
            }

        }
        //Account ownership
        else if(role.Owner_Account__c != null){
            accreditationContact.Company__c   = role.Owner_Account__c;
            accreditationContact.RecordTypeId = AMS_Utils.AccreditationContactCompanyRT;
        }
        //Legacy Owners
        else{
            accreditationContact.Last_Name__c = role.Owner_Name__c;
            accreditationContact.Legacy_External_Id__c = role.Legacy_External_Id__c;
            accreditationContact.RecordTypeId = AMS_Utils.AccreditationContactPersonRT;
        }

        return accreditationContact;
    }

    //Will create an accreditation contacts to match with account roles present on a specific agency
    //Once these accreditation Contacts are moved to master data they will be identical to the account roles they were created from
    public static void mirrorAccrediationContactsFromAccountRole(List<AMS_OSCAR__c> oscars, Map<Id,AMS_OSCAR__c> oldMap){

        //accreditation contact that need to be deleted because a sync with owners of a target agency must be performed
        List<AMS_Accreditation_Contact__c> accreditationContactsToDelete = new List<AMS_Accreditation_Contact__c>();
        List<AMS_Accreditation_Contact__c> accreditationContactsToInsert = new List<AMS_Accreditation_Contact__c>();

        Set<Id> oscarTargetAgencyIds = new Set<Id>();
        Set<Id> oscarOnlineAccredIds = new Set<Id>();

        //On Insert process we should process the mirroring immediately if the target agency on the oscar is not null
        //On Update do it only when the target agency is modified
        for (AMS_OSCAR__c oscar : oscars) {

            oscarOnlineAccredIds.add(oscar.AMS_Online_Accreditation__c);
            //if((insert AND target not null) OR (update and target was changed))
            if(oscar.Type_of_change__c != null && oscar.Type_of_change__c.contains(AMS_Utils.OWNERSHIP_IATA) && ((oscar.AMS_Target_Agency__c != null && oldMap == null) || (oldMap != null && oldMap.get(oscar.Id).AMS_Target_Agency__c <> oscar.AMS_Target_Agency__c)))
                oscarTargetAgencyIds.add(oscar.AMS_Target_Agency__c);
        }

        if(!oscarTargetAgencyIds.isEmpty()){


            Map<Id, List<AMS_Accreditation_Contact__c>> accreditationContactsPerOnlineAccreditation = new Map<Id, List<AMS_Accreditation_Contact__c>>();

            List<AMS_Accreditation_Contact__c> accreditationContactsInContext = new List<AMS_Accreditation_Contact__c>([SELECT Id, AMS_Pax_Accreditation_Form__c FROM AMS_Accreditation_Contact__c WHERE AMS_Pax_Accreditation_Form__c IN :oscarOnlineAccredIds]);

            for(AMS_Accreditation_Contact__c ac: accreditationContactsInContext){
                if(!accreditationContactsPerOnlineAccreditation.containsKey(ac.AMS_Pax_Accreditation_Form__c))
                    accreditationContactsPerOnlineAccreditation.put(ac.AMS_Pax_Accreditation_Form__c, new List<AMS_Accreditation_Contact__c>());
                accreditationContactsPerOnlineAccreditation.get(ac.AMS_Pax_Accreditation_Form__c).add(ac);
            }

            //get the account roles for target agencies 
            Map<Id, List<AMS_Account_Role__c>> accountRolesInTargetAgencies = new Map<Id, List<AMS_Account_Role__c>>();

            //get only the active records having record type ownership 
            List<AMS_Account_Role__c> activeRolesInTargetAgencies = new List<AMS_Account_Role__c>([ SELECT Id, Account__c, Contact__c, Person__c, Duty__c, IsManager__c, Legacy_External_ID__c,
                                                                                                          Percentage__c, Position__c, Owner_Account__c, Employee_Name__c, Hours__c, Owner_Name__c,
                                                                                                          Contact__r.FirstName, Contact__r.LastName, Contact__r.Membership_Main_Contact__c,
                                                                                                          Contact__r.Financial_Assessment_Contact__c, Contact__r.Phone, Contact__r.Mobilephone,
                                                                                                          Contact__r.Fax, Contact__r.Birthdate, Contact__r.Email, Contact__r.ISO_Country__c,
                                                                                                          Contact__r.Training_dangerous_goods_completed__c, Contact__r.list_Dangerous_Goods_Awareness__c,
                                                                                                          Person__r.First_Name__c, Person__r.Lastname__c, Person__r.Phone__c, Person__r.Mobile__c,
                                                                                                          Person__r.Fax__c, Person__r.DOB__c, Person__r.Email__c
                                                                                                    FROM AMS_Account_Role__c
                                                                                                    WHERE Account__c
                                                                                                    IN :oscarTargetAgencyIds 
                                                                                                    AND Active__c = true AND RecordTypeId = :AMS_Utils.AccountRoleOwnershipRT]);

            for(AMS_Account_Role__c role : activeRolesInTargetAgencies){
                if(!accountRolesInTargetAgencies.containsKey(role.Account__c))
                    accountRolesInTargetAgencies.put(role.Account__c, new List<AMS_Account_Role__c>());
                accountRolesInTargetAgencies.get(role.Account__c).add(role);
            }
            
            for(AMS_OSCAR__c oscar: oscars){
                //only need to process the oscars which have target agency in the list compiled before
                if(oscarTargetAgencyIds.contains(oscar.AMS_Target_Agency__c)){

                    //STEP1 - delete all accreditation contacts in staging area
                    if(accreditationContactsPerOnlineAccreditation.get(oscar.AMS_Online_Accreditation__c) != null)
                        accreditationContactsToDelete.addAll(accreditationContactsPerOnlineAccreditation.get(oscar.AMS_Online_Accreditation__c));

                    //if target agency has active roles we need to create a matching accreditation Contact
                    if(accountRolesInTargetAgencies.get(oscar.AMS_Target_Agency__c) != null){

                        //STEP2 - get active account roles on the target agency
                        List<AMS_Account_Role__c> activeRolesInTargetAgency = accountRolesInTargetAgencies.get(oscar.AMS_Target_Agency__c);

                        //STEP3 - generate accreditation contacts from the account roles
                        if(!activeRolesInTargetAgency.isEmpty()){

                            for(AMS_Account_Role__c role: activeRolesInTargetAgency){
                                AMS_Accreditation_Contact__c accredContactToInsert = AMS_AccreditationContactHelper.createAccreditationContactFromAccountRole(role, oscar.AMS_Online_Accreditation__c);
                                System.debug('mirrorAccrediationContactsFromAccountRole: Accreditation Contact to insert: ' + accredContactToInsert);
                                if(accredContactToInsert != null)
                                    accreditationContactsToInsert.add(accredContactToInsert);
                            }
                        }
                    }
                }
            }

            Savepoint sp = Database.setSavepoint();

            try {

                if(!accreditationContactsToDelete.isEmpty())
                    delete accreditationContactsToDelete;

                if(!accreditationContactsToInsert.isEmpty())
                    insert accreditationContactsToInsert;

            } catch (Exception ex) {
                System.debug('Exception: ' + ex);
                Database.rollback(sp);
                throw ex;
            }
        }

    }

}
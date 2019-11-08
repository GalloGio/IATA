@isTest
public class OneId_NDCRelationsController_Test {
    
    public static String generateUniqueUserEmail() {
        return (System.now().getTime() + '@test' + UserInfo.getOrganizationId() + '.org').toLowerCase();
    }
    
    public static User createUserWithRole() {
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);
        
        String userEmail = generateUniqueUserEmail();
        
        Profile pf = [SELECT Id 
                      FROM Profile 
                      WHERE Name = 'System Administrator'];
        User userWithRole = new User(alias = 'hasrole', email = userEmail, userroleid = r.id,
                                     emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                     localesidkey='en_US', profileid = pf.Id, 
                                     timezonesidkey='America/Los_Angeles', username = userEmail, License_Cost_Center__c = 'ISF005CH01');
        
        insert userWithRole;
        return userWithRole;
    }
    
    public static User createUserWithAirlineAccount() {
        
        Id p = [SELECT id 
                FROM profile 
                WHERE name='ISS Portal Airline User (Partner)'].id;
        
        System.runAs(createUserWithRole()){
            String roleRecordTypeId = Schema.SObjectType.Account_Role__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Airline Headquarters').getRecordTypeId();
            String sProviderRecordTypeId = Schema.SObjectType.One_Id_Service_Provider_Config__c.getRecordTypeInfosByDeveloperName().get('Service_Provider').getRecordTypeId();
            
            Account ac = new Account(RecordTypeId = recordTypeId, Name ='AirlineAcc', Sector__c = 'Airline', Category__c = 'Passenger only');
            insert ac;
            
            Account_Roles__c ars = new Account_Roles__c(Name = 'Airline - Passenger only', Sector__c = 'Airline', Category__c = 'Passenger only');
            insert ars;
            
            Portal_Applications__c pa = new Portal_Applications__c(Name = 'One Id NDC Matchmaker');
            insert pa;
            
            One_Id_Service_Provider_Config__c oneIdService = new One_Id_Service_Provider_Config__c(Portal_Service__c = pa.Id, Service_Provider_Name__c = 'NDCMM', RecordTypeId = sProviderRecordTypeId);
            insert oneIdService;
            
            Contact con = new Contact(LastName ='AirlineCon',AccountId = ac.Id, Email='testuser@example.com');
            insert con;
            
            Account_Role__c rol = new Account_Role__c (Account__c = ac.Id, RecordTypeId = roleRecordTypeId, Account_Roles__c = ars.Id);
            insert rol;
            
            Account_Role_Service__c arserv = new Account_Role_Service__c(Account_Role__c = rol.Id);
            insert arserv;
            
            NDC_Account_Service_Detail__c det = new NDC_Account_Service_Detail__c(Account_Role_Service__c = arserv.Id, Contact_Email__c = 'airlineRole@example.com', NDC_capable__c = true);
            insert det;
        }
        Contact cont = [SELECT Id 
                        FROM Contact 
                        WHERE LastName = 'AirlineCon'];
        User user = new User(Alias = 'testuser', Email='testuser@example.com',
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocalesIdKey='en_US', ProfileId = p, Country='United States', IsActive =true,
                             ContactId = cont.Id,
                             TimeZonesIdKey='America/Los_Angeles', Username='testuser@example.com', License_Cost_Center__c = 'ISF005CH01');
        
        insert user;
        return user;
    }
    
    public static User createUserWithNonAirlineAccount() {
        
        Id p = [SELECT id 
                FROM profile 
                WHERE name='ISS Portal (Partner)'].id;
        
        System.runAs(createUserWithRole()){
            String roleRecordTypeId = Schema.SObjectType.Account_Role__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            String sProviderRecordTypeId = Schema.SObjectType.One_Id_Service_Provider_Config__c.getRecordTypeInfosByDeveloperName().get('Service_Provider').getRecordTypeId();
            
            Account ac = new Account(RecordTypeId = recordTypeId, Name ='NonAirlineAcc', Sector__c = 'Travel Agent', Category__c = 'Non-IATA Travel Agent');
            insert ac;
            
            Account_Roles__c ars = new Account_Roles__c(Name = 'Travel Agent - Non-IATA Travel Agent', Sector__c = 'Travel Agent', Category__c = 'Non-IATA Travel Agent');
            insert ars;
            
            Portal_Applications__c pa = new Portal_Applications__c(Name = 'One Id NDC Matchmaker');
            insert pa;
            
            One_Id_Service_Provider_Config__c oneIdService = new One_Id_Service_Provider_Config__c(Portal_Service__c = pa.Id, Service_Provider_Name__c = 'NDCMM', RecordTypeId = sProviderRecordTypeId);
            insert oneIdService;
            
            Contact con = new Contact(LastName ='NonAirlineCon',AccountId = ac.Id, Email='testuser@example.com');
            insert con;
            
            Account_Role__c rol = new Account_Role__c (Account__c = ac.Id, RecordTypeId = roleRecordTypeId, Account_Roles__c = ars.Id);
            insert rol;
            
            Account_Role_Service__c arserv = new Account_Role_Service__c(Account_Role__c = rol.Id);
            insert arserv;
            
            NDC_Account_Service_Detail__c det = new NDC_Account_Service_Detail__c(Account_Role_Service__c = arserv.Id, Contact_Email__c = 'nonAirlineRole@example.com', NDC_capable__c = true);
            insert det;
        }
        Contact cont = [SELECT Id 
                        FROM Contact 
                        WHERE LastName = 'NonAirlineCon'];
        User user = new User(Alias = 'testuser', Email='testuser@example.com',
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocalesIdKey='en_US', ProfileId = p, Country='United States', IsActive =true,
                             ContactId = cont.Id,
                             TimeZonesIdKey='America/Los_Angeles', Username='testuser@example.com', License_Cost_Center__c = 'ISF005CH01');
        
        insert user;
        return user;
    }

    @isTest
    public static void testGetUserInfoAirline() {
        
        User usr = CreateUserWithAirlineAccount();
        Boolean isAirline;
        Test.startTest();
        System.runAs(usr) {
            isAirline = OneId_NDCRelationsController.getUserInfo();
        }
        Test.stopTest();
        System.assertEquals(True, isAirline);
    }
    
    @isTest
    public static void testGetUserInfoNonAirline() {
        
        User usr = CreateUserWithNonAirlineAccount();
        Boolean isAirline;
        Test.startTest();
        System.runAs(usr) {
            isAirline = OneId_NDCRelationsController.getUserInfo();
        }
        Test.stopTest();
        System.assertEquals(False, isAirline);
    }
    
    @isTest
    public static void testGetNDCRelationsAirline() {
        
        User usr = CreateUserWithAirlineAccount();        
        User usrQuery = [SELECT Id, AccountId FROM User WHERE Id =: usr.Id];
        Account_Role__c role = [SELECT Id FROM Account_Role__c WHERE Account__c =: usrQuery.AccountId];
        
        System.runAs(createUserWithRole()){
            String roleRecordTypeId = Schema.SObjectType.Account_Role__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            String relationshipRecordTypeId = Schema.getGlobalDescribe().get('Account_Role_Relationship__c').getDescribe().getRecordTypeInfosByName().get('Flat').getRecordTypeId();
            String sProviderRecordTypeId = Schema.SObjectType.One_Id_Service_Provider_Config__c.getRecordTypeInfosByDeveloperName().get('Service_Provider').getRecordTypeId();
            
            Account ac = new Account(RecordTypeId = recordTypeId, Name ='NonAirlineAccForRel', Sector__c = 'Travel Agent', Category__c = 'Non-IATA Travel Agent');
            insert ac;
            
            Account_Roles__c ars = new Account_Roles__c(Name = 'Travel Agent - Non-IATA Travel Agent', Sector__c = 'Travel Agent', Category__c = 'Non-IATA Travel Agent');
            insert ars;
            
            One_Id_Service_Provider_Config__c oneIdService = [SELECT Portal_Service__c 
                                                              FROM One_Id_Service_Provider_Config__c 
                                                              WHERE Service_Provider_Name__c = 'NDCMM' 
                                                              AND RecordType.DeveloperName = 'Service_Provider' LIMIT 1];
            
            Contact con = new Contact(LastName ='NonAirlineCon',AccountId = ac.Id, Email='testQuery@example.com');
            insert con;
            
            Account_Role__c rol = new Account_Role__c (Account__c = ac.Id, RecordTypeId = roleRecordTypeId, Account_Roles__c = ars.Id);
            insert rol;
            
            Account_Role_Service__c arserv = new Account_Role_Service__c(Account_Role__c = rol.Id);
            insert arserv;
            
            NDC_Account_Service_Detail__c det = new NDC_Account_Service_Detail__c(Account_Role_Service__c = arserv.Id, Contact_Email__c = 'testQuery@example.com', NDC_capable__c = true);
            insert det;
            
            Account_Role_Relationship__c ndcRel = new Account_Role_Relationship__c(From__c = rol.Id, To__c = role.Id, Relationship_Type__c = 'NDC Player', RecordTypeId = relationshipRecordTypeId, Relationship_Status__c = 'Active', Portal_Service__c = oneIdService.Portal_Service__c);
            insert ndcRel;
        }
                
        List<OneId_NDCRelationsController.AirlineWrapper> AirlineList = new List<OneId_NDCRelationsController.AirlineWrapper>();
        
        Test.startTest();
        System.runAs(usr) {
            AirlineList = OneId_NDCRelationsController.getNDCRelations();
        }
        Test.stopTest();
        System.assertEquals(1, AirlineList.size());
    }
    
    @isTest
    public static void testGetNDCRelationsNonAirline() {
        
        User usr = CreateUserWithNonAirlineAccount();        
        User usrQuery = [SELECT Id, AccountId 
                         FROM User 
                         WHERE Id =: usr.Id];
        Account_Role__c role = [SELECT Id 
                                FROM Account_Role__c 
                                WHERE Account__c =: usrQuery.AccountId
								AND RecordType.DeveloperName = 'Default'];
        
        System.runAs(createUserWithRole()){
            String roleRecordTypeId = Schema.SObjectType.Account_Role__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Airline Headquarters').getRecordTypeId();
            String relationshipRecordTypeId = Schema.getGlobalDescribe().get('Account_Role_Relationship__c').getDescribe().getRecordTypeInfosByName().get('Flat').getRecordTypeId();
            String sProviderRecordTypeId = Schema.SObjectType.One_Id_Service_Provider_Config__c.getRecordTypeInfosByDeveloperName().get('Service_Provider').getRecordTypeId();
            
            Account ac = new Account(RecordTypeId = recordTypeId, Name ='AirlineAccForRel', Sector__c = 'Airline', Category__c = 'Passenger only');
            insert ac;
            
            Account_Roles__c ars = new Account_Roles__c(Name = 'Airline - Passenger only', Sector__c = 'Airline', Category__c = 'Passenger only');
            insert ars;
            
            One_Id_Service_Provider_Config__c oneIdService = [SELECT Portal_Service__c 
                                                              FROM One_Id_Service_Provider_Config__c 
                                                              WHERE Service_Provider_Name__c = 'NDCMM' 
                                                              AND RecordType.DeveloperName = 'Service_Provider' LIMIT 1];
            
            Contact con = new Contact(LastName ='AirlineCon',AccountId = ac.Id, Email='testQuery@example.com');
            insert con;
            
            Account_Role__c rol = new Account_Role__c (Account__c = ac.Id, RecordTypeId = roleRecordTypeId, Account_Roles__c = ars.Id);
            insert rol;
            
            Account_Role_Service__c arserv = new Account_Role_Service__c(Account_Role__c = rol.Id);
            insert arserv;
            
            NDC_Account_Service_Detail__c det = new NDC_Account_Service_Detail__c(Account_Role_Service__c = arserv.Id, Contact_Email__c = 'testQuery@example.com', NDC_capable__c = true);
            insert det;
            
            Account_Role_Relationship__c ndcRel = new Account_Role_Relationship__c(From__c = role.Id, To__c = rol.Id, Relationship_Type__c = 'NDC Player', RecordTypeId = relationshipRecordTypeId, Relationship_Status__c = 'Active', Portal_Service__c = oneIdService.Portal_Service__c);
            insert ndcRel;
        }
                
        List<OneId_NDCRelationsController.AirlineWrapper> AirlineList = new List<OneId_NDCRelationsController.AirlineWrapper>();
        
        Test.startTest();
        System.runAs(usr) {
            AirlineList = OneId_NDCRelationsController.getNDCRelations();
        }
        Test.stopTest();
        System.assertEquals(1, AirlineList.size());
    }
    
    @isTest
    public static void testDeleteRelations() {
        
        User usr = CreateUserWithNonAirlineAccount();        
        User usrQuery = [SELECT Id, AccountId 
                         FROM User 
                         WHERE Id =: usr.Id];
        Account_Role__c role = [SELECT Id 
                                FROM Account_Role__c 
                                WHERE Account__c =: usrQuery.AccountId
								AND RecordType.DeveloperName = 'Default'];
        
        System.runAs(createUserWithRole()){
            String roleRecordTypeId = Schema.SObjectType.Account_Role__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Airline Headquarters').getRecordTypeId();
            String relationshipRecordTypeId = Schema.getGlobalDescribe().get('Account_Role_Relationship__c').getDescribe().getRecordTypeInfosByName().get('Flat').getRecordTypeId();
            String sProviderRecordTypeId = Schema.SObjectType.One_Id_Service_Provider_Config__c.getRecordTypeInfosByDeveloperName().get('Service_Provider').getRecordTypeId();

            Account ac = new Account(RecordTypeId = recordTypeId, Name ='NonAirlineAccForRel', Sector__c = 'Travel Agent', Category__c = 'Non-IATA Travel Agent');
            insert ac;
            
            Account_Roles__c ars = new Account_Roles__c(Name = 'Travel Agent - Non-IATA Travel Agent', Sector__c = 'Travel Agent', Category__c = 'Non-IATA Travel Agent');
            insert ars;
            
            One_Id_Service_Provider_Config__c oneIdService = [SELECT Portal_Service__c 
                                                              FROM One_Id_Service_Provider_Config__c 
                                                              WHERE Service_Provider_Name__c = 'NDCMM' 
                                                              AND RecordType.DeveloperName = 'Service_Provider' LIMIT 1];
            
            Contact con = new Contact(LastName ='NonAirlineCon',AccountId = ac.Id, Email='testQuery@example.com');
            insert con;
            
            Account_Role__c rol = new Account_Role__c (Account__c = ac.Id, RecordTypeId = roleRecordTypeId, Account_Roles__c = ars.Id);
            insert rol;
            
            Account_Role_Service__c arserv = new Account_Role_Service__c(Account_Role__c = rol.Id);
            insert arserv;
            
            NDC_Account_Service_Detail__c det = new NDC_Account_Service_Detail__c(Account_Role_Service__c = arserv.Id, Contact_Email__c = 'testQuery@example.com', NDC_capable__c = true);
            insert det;
            
            Account_Role_Relationship__c ndcRel = new Account_Role_Relationship__c(To__c = role.Id, From__c = rol.Id, Relationship_Type__c = 'NDC Player', RecordTypeId = relationshipRecordTypeId, Relationship_Status__c = 'Active', Portal_Service__c = oneIdService.Portal_Service__c);
            insert ndcRel;
        }
        
        OneId_NDCRelationsController.AirlineWrapper wrapper = new OneId_NDCRelationsController.AirlineWrapper();
        List<OneId_NDCRelationsController.AirlineWrapper> airlineList = new List<OneId_NDCRelationsController.AirlineWrapper>();
        
        Account_Role_Relationship__c ndcRelation = [SELECT Id, From__r.Account__r.Name
                                                    FROM Account_Role_Relationship__c 
                                                    WHERE From__r.Account__r.Name = 'NonAirlineAccForRel'];
        wrapper.AirlineId = ndcRelation.Id;
        wrapper.AirlineName = ndcRelation.From__r.Account__r.Name;
        airlineList.add(wrapper);
        String airlineListSerialized = JSON.serialize(airlineList);
        
        Test.startTest();
        System.runAs(usr) {
            OneId_NDCRelationsController.deleteRelations(airlineListSerialized);
        }
        Test.stopTest();
        
        List<Account_Role_Relationship__c> relList = [SELECT Id 
                                                      FROM Account_Role_Relationship__c 
                                                      WHERE From__r.Account__r.Name = 'NonAirlineAccForRel'];
        System.assertEquals(0, relList.size());
    }
    
    @isTest
    public static void testGetAirlines() {
        
        User usr = CreateUserWithNonAirlineAccount();
        
        System.runAs(createUserWithRole()){
            
            String roleRecordTypeId = Schema.SObjectType.Account_Role__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Airline Headquarters').getRecordTypeId();
            String sProviderRecordTypeId = Schema.SObjectType.One_Id_Service_Provider_Config__c.getRecordTypeInfosByDeveloperName().get('Service_Provider').getRecordTypeId();
            
            Account ac = new Account(RecordTypeId = recordTypeId, Name ='AirlineAccForRel', Sector__c = 'Airline', Category__c = 'Passenger only');
            insert ac;
            
            Account_Roles__c ars = new Account_Roles__c(Name = 'Airline - Passenger only', Sector__c = 'Airline', Category__c = 'Passenger only');
            insert ars;
            
            One_Id_Service_Provider_Config__c oneIdService = [SELECT Portal_Service__c 
                                                              FROM One_Id_Service_Provider_Config__c 
                                                              WHERE Service_Provider_Name__c = 'NDCMM' 
                                                              AND RecordType.DeveloperName = 'Service_Provider' LIMIT 1];
            
            Contact con = new Contact(LastName ='AirlineCon',AccountId = ac.Id, Email='testQuery@example.com');
            insert con;
            
            Account_Role__c rol = new Account_Role__c (Account__c = ac.Id, RecordTypeId = roleRecordTypeId, Account_Roles__c = ars.Id);
            insert rol;
            
            Account_Role_Service__c arserv = new Account_Role_Service__c(Account_Role__c = rol.Id);
            insert arserv;
            
            NDC_Account_Service_Detail__c det = new NDC_Account_Service_Detail__c(Account_Role_Service__c = arserv.Id, Contact_Email__c = 'testQuery@example.com', NDC_capable__c = true);
            insert det;
        }
        
        List<OneId_NDCRelationsController.AirlineWrapper> airlineList = new List<OneId_NDCRelationsController.AirlineWrapper>();
        
        Test.startTest();
        System.runAs(usr) {
            airlineList = OneId_NDCRelationsController.getAirlines();
        }
        Test.stopTest();
        
        System.assertEquals(1, airlineList.size());
    }
    
    @isTest
    public static void testCreateRelations() {
        
        User usr = CreateUserWithNonAirlineAccount();
        
        System.runAs(createUserWithRole()){
            
            String roleRecordTypeId = Schema.SObjectType.Account_Role__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Airline Headquarters').getRecordTypeId();
            String sProviderRecordTypeId = Schema.SObjectType.One_Id_Service_Provider_Config__c.getRecordTypeInfosByDeveloperName().get('Service_Provider').getRecordTypeId();
            
            Account ac = new Account(RecordTypeId = recordTypeId, Name ='AirlineAccForRel', Sector__c = 'Airline', Category__c = 'Passenger only');
            insert ac;
            
            Account_Roles__c ars = new Account_Roles__c(Name = 'Airline - Passenger only', Sector__c = 'Airline', Category__c = 'Passenger only');
            insert ars;
            
            One_Id_Service_Provider_Config__c oneIdService = [SELECT Portal_Service__c 
                                                              FROM One_Id_Service_Provider_Config__c 
                                                              WHERE Service_Provider_Name__c = 'NDCMM' 
                                                              AND RecordType.DeveloperName = 'Service_Provider' LIMIT 1];
            
            Contact con = new Contact(LastName ='AirlineCon',AccountId = ac.Id, Email='testQuery@example.com');
            insert con;
            
            Account_Role__c rol = new Account_Role__c (Account__c = ac.Id, RecordTypeId = roleRecordTypeId, Account_Roles__c = ars.Id);
            insert rol;
            
            Account_Role_Service__c arserv = new Account_Role_Service__c(Account_Role__c = rol.Id);
            insert arserv;
            
            NDC_Account_Service_Detail__c det = new NDC_Account_Service_Detail__c(Account_Role_Service__c = arserv.Id, Contact_Email__c = 'testQuery@example.com', NDC_capable__c = true);
            insert det;            
        }
        
        Account_Role__c airlineRole = [SELECT Id, Account__r.Name 
                                       FROM Account_Role__c 
                                       WHERE Account__r.Name = 'AirlineAccForRel'
                                       AND RecordType.DeveloperName = 'Default'];
        
        List<OneId_NDCRelationsController.AirlineWrapper> airlineList = new List<OneId_NDCRelationsController.AirlineWrapper>();
        
        OneId_NDCRelationsController.AirlineWrapper aw = new OneId_NDCRelationsController.AirlineWrapper();
        aw.AirlineId = airlineRole.Id;
        aw.AirlineName = airlineRole.Account__r.Name;
        airlineList.add(aw);
        
        String airlineListSerialized = JSON.serialize(airlineList);
        
        Test.startTest();
        System.runAs(usr) {
            OneId_NDCRelationsController.createRelations(airlineListSerialized);
        }
        Test.stopTest();
        
        Account_Role_Relationship__c rel = [SELECT Id, To__c 
                                            FROM Account_Role_Relationship__c 
                                            WHERE To__c =: airlineList[0].AirlineId];
        
        System.assertEquals(airlineList[0].AirlineId, rel.To__c);
    }
    
}
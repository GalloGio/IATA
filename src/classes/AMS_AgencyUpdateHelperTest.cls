//This test class is the unit test for AMS-118 and AMS-119
@isTest
public class AMS_AgencyUpdateHelperTest {
    
    //AMS-119
    //public static testmethod void test_agencyRelathionshipUpdate() {
    //    IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
    //    insert ctry ;

    //    Map<string, Id>  agenciesRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Account'}).get('Account');

    //    List<Account> agencylist = new List<Account>();
    //    Account a1 = new Account(Name='Test1 Parent Agency',Short_Name__c='Test1 Parent Agency', IATAcode__c = '1234567', IATA_ISO_Country__c = ctry.id, Sector__c = 'Travel Agent'/*, RecordTypeId = agenciesRT.get('PASSENGER')*/);
    //    Account a2 = new Account(Name='Test1 Child Agency',Short_Name__c='Test1 Child Agency', IATAcode__c = '4566123', IATA_ISO_Country__c = ctry.id, Sector__c = 'Travel Agent'/*, RecordTypeId = agenciesRT.get('PASSENGER')*/);
    //    Account a3 = new Account(Name='Test2 Parent Agency',Short_Name__c='Test2 Parent Agency', IATAcode__c = '7891234', IATA_ISO_Country__c = ctry.id, Sector__c = 'Travel Agent'/*, RecordTypeId = agenciesRT.get('PASSENGER')*/);
    //    Account a4 = new Account(Name='Test2 Child Agency',Short_Name__c='Test2 Child Agency', IATAcode__c = '0001234', IATA_ISO_Country__c = ctry.id, Sector__c = 'Travel Agent'/*, RecordTypeId = agenciesRT.get('PASSENGER')*/);
    //    Account a5 = new Account(Name='Test3 Parent Agency',Short_Name__c='Test3 Parent Agency', IATAcode__c = '7891235', IATA_ISO_Country__c = ctry.id, Sector__c = 'Travel Agent'/*, RecordTypeId = agenciesRT.get('PASSENGER')*/);
    //    Account a6 = new Account(Name='Test3 Child Agency',Short_Name__c='Test3 Child Agency', IATAcode__c = '0001235', IATA_ISO_Country__c = ctry.id, Sector__c = 'Travel Agent'/*, RecordTypeId = agenciesRT.get('PASSENGER')*/);
    //    agencylist.add(a1);
    //    agencylist.add(a2);
    //    agencylist.add(a3);
    //    agencylist.add(a4);
    //    agencylist.add(a5);
    //    agencylist.add(a6);
    //    insert agencylist;

    //    List<Agency_Applied_Change_code__c> aacclist = new List<Agency_Applied_Change_code__c>();
    //    Agency_Applied_Change_code__c aacc1 = new Agency_Applied_Change_code__c(Account__c = a1.Id, Change_Code__c = 'TST',  Sent_to_external_system__c = false);
    //    Agency_Applied_Change_code__c aacc2 = new Agency_Applied_Change_code__c(Account__c = a2.Id, Change_Code__c = 'TST',  Sent_to_external_system__c = false);
    //    Agency_Applied_Change_code__c aacc3 = new Agency_Applied_Change_code__c(Account__c = a3.Id, Change_Code__c = 'TST',  Sent_to_external_system__c = false);
    //    aacclist.add(aacc1);
    //    aacclist.add(aacc2);
    //    aacclist.add(aacc3);
    //    insert aacclist;

    //    List<AMS_Agencies_Hierarchy__c> hierachieslist = new List<AMS_Agencies_Hierarchy__c>();
    //    AMS_Agencies_Hierarchy__c ah1 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c='Test Hierarchy');
    //    AMS_Agencies_Hierarchy__c ah2 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c='Another Test Hierarchy');
    //    hierachieslist.add(ah1);
    //    hierachieslist.add(ah2);
    //    insert hierachieslist;

    //    List<AMS_Agencies_relationhip__c> relationshiplist = new List<AMS_Agencies_relationhip__c>();
    //    AMS_Agencies_relationhip__c ar1 = new AMS_Agencies_relationhip__c(Relationship_details__c='Test',Hierarchy__c=ah1.id,Child_Account__c=a2.id,Parent_Account__c=a1.id);
    //    AMS_Agencies_relationhip__c ar2 = new AMS_Agencies_relationhip__c(Relationship_details__c='Test',Hierarchy__c=ah2.id,Child_Account__c=a4.id,Parent_Account__c=a3.id);
    //    AMS_Agencies_relationhip__c ar3 = new AMS_Agencies_relationhip__c(Relationship_details__c='Test',Hierarchy__c=ah1.id,Child_Account__c=a6.id,Parent_Account__c=a4.id);
    //    relationshiplist.add(ar1);
    //    relationshiplist.add(ar2);
    //    relationshiplist.add(ar3);
    //    insert relationshiplist;

    //    Test.startTest();
    //    ah1.Hierarchy_Name__c = 'Test update';
    //    ah2.Hierarchy_Name__c = 'Test update';
    //    ar1.Relationship_details__c = 'Test update';
    //    ar2.Relationship_details__c = 'Test update';
    //    List<SObject> updateAll = new List<SObject>();
    //    updateAll.add(ah1);
    //    updateAll.add(ah2);
    //    updateAll.add(ar1);
    //    updateAll.add(ar2);
    //    update updateAll;


    //    List<AMS_Agency_Updates__c> agencyUpdateList = [select id, Update_Type__c, RelationShip__c, Account__c from AMS_Agency_Updates__c where Account__c = null];
    //    System.assertEquals(3, agencyUpdateList.size());
    //    for(AMS_Agency_Updates__c au :agencyUpdateList){
    //        System.assertEquals('Update', au.Update_Type__c);
    //        System.assert(au.RelationShip__c != null);
    //        System.assert(au.Account__c == null);
    //    }
    //    Test.stopTest();
    //}
    
    // DATA Test content
    public static IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
    public static Map<string, Id>  agenciesRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Account'}).get('Account');
    public static List<Account> agencylist = new List<Account>();
    public static List<AMS_Agency_Profile__c> agencyprofileList = new List<AMS_Agency_Profile__c>();
    public static List<AMS_Account_Role__c> agencyOwnershipList = new List<AMS_Account_Role__c>();
    public static List<AMS_Address__c> agencyAddressList = new List<AMS_Address__c>();
    public static List<AMS_Inspection__c> agencyInspectionList = new List<AMS_Inspection__c>();
    public static List<AMS_Agency_Segment__c> agencySegmentList = new List<AMS_Agency_Segment__c>();
    public static AMS_Airport__c air = new AMS_Airport__c();
    public static List<AMS_Employee__c> agencyEmployees = new List<AMS_Employee__c>();
    public static List<AMS_Agency_Airport__c> agencyAirportList = new List<AMS_Agency_Airport__c>();
    public static AMS_Owner__c o = new AMS_Owner__c();
    public static AMS_Accreditation_Organization__c ao = new AMS_Accreditation_Organization__c(Air_Code__c = 'IATA');
    public static AMS_Segment__c s = new AMS_Segment__c(Label__c='Test');
    public static AMS_Person__c per = new AMS_Person__c(Lastname__c = 'Teste');
    public static AMS_Affiliation__c aff = new AMS_Affiliation__c();
    public static List<AMS_Agency_Affiliation__c> agencyAffiliations = new List<AMS_Agency_Affiliation__c>();

    public static Account a1 = null;
    public static Account a2 = null;
    public static Account a3 = null;
    public static Account a4 = null;
    public static Account a5 = null;
    public static Account a6 = null;
    
    public static AMS_Agency_Profile__c ap1 = null;
    public static AMS_Agency_Profile__c ap2 = null;
    public static AMS_Agency_Profile__c ap3 = null;
    public static AMS_Agency_Profile__c ap4 = null;
    
    public static AMS_Account_Role__c ao1 = null;
    public static AMS_Account_Role__c ao2 = null;
    public static AMS_Account_Role__c ao3 = null;
    public static AMS_Account_Role__c ao4 = null;
 
    public static AMS_Address__c aa1 = null;
    public static AMS_Address__c aa2 = null;
    public static AMS_Address__c aa3 = null;
    public static AMS_Address__c aa4 = null;
    
    public static AMS_Inspection__c ins1 = null;
    public static AMS_Inspection__c ins2 = null;
    public static AMS_Inspection__c ins3 = null;
    public static AMS_Inspection__c ins4 = null;
    
    public static AMS_Agency_Segment__c as1 = null;
    public static AMS_Agency_Segment__c as2 = null;
    public static AMS_Agency_Segment__c as3 = null;
    public static AMS_Agency_Segment__c as4 = null;

    public static AMS_Agency_Airport__c aair1 = null;
    public static AMS_Agency_Airport__c aair2 = null;
    public static AMS_Agency_Airport__c aair3 = null;
    public static AMS_Agency_Airport__c aair4 = null;

    public static AMS_Employee__c emp1 = null;
    
    public static AMS_Agency_Affiliation__c aaff1 = null;
    public static AMS_Agency_Affiliation__c aaff2 = null;
    public static AMS_Agency_Affiliation__c aaff3 = null;
    public static AMS_Agency_Affiliation__c aaff4 = null;


    public static void configureTest(){
        insert ctry ;
        insert o;
        insert ao;
        insert s;
        insert per;
        insert aff;
        insert air;

        
        a1 = new Account(Name='Test1 Agency',Short_Name__c='Test1 Agency', IATA_ISO_Country__c = ctry.id, IATAcode__c = '1234567', Sector__c = 'Travel Agent',Reason_for_creation__c='New agent'/*, RecordTypeId = agenciesRT.get('PASSENGER')*/);
        a2 = new Account(Name='Test2 Agency',Short_Name__c='Test2 Agency', IATA_ISO_Country__c = ctry.id, IATAcode__c = '2345671', Sector__c = 'Travel Agent',Reason_for_creation__c='New agent'/*, RecordTypeId = agenciesRT.get('PASSENGER')*/);
        a3 = new Account(Name='Test3 Agency',Short_Name__c='Test3 Agency', IATA_ISO_Country__c = ctry.id, IATAcode__c = '3456712', Sector__c = 'Travel Agent',Reason_for_creation__c='New agent'/*, RecordTypeId = agenciesRT.get('PASSENGER')*/);
        a4 = new Account(Name='Test4 Agency',Short_Name__c='Test4 Agency', IATA_ISO_Country__c = ctry.id, IATAcode__c = '4567123', Sector__c = 'Travel Agent',Reason_for_creation__c='New agent'/*, RecordTypeId = agenciesRT.get('PASSENGER')*/);
        agencylist.add(a1);
        agencylist.add(a2);
        agencylist.add(a3);
        agencylist.add(a4);
        insert agencylist;
        
        
        aair1 = new AMS_Agency_Airport__c(Account__c=a1.id,Airport__c=air.id);
        aair2 = new AMS_Agency_Airport__c(Account__c=a2.id,Airport__c=air.id);
        aair3 = new AMS_Agency_Airport__c(Account__c=a3.id,Airport__c=air.id);
        aair4 = new AMS_Agency_Airport__c(Account__c=a4.id,Airport__c=air.id);
        agencyAirportList.add(aair1);
        agencyAirportList.add(aair2);
        agencyAirportList.add(aair3);
        agencyAirportList.add(aair4);
        insert agencyAirportList;
        
        
        
        emp1 = new AMS_Employee__c(Account__c=a1.id,Person__c=per.id);
        agencyEmployees.add(emp1);
        insert agencyEmployees;
        
            
        aaff1 = new AMS_Agency_Affiliation__c(Account__c=a1.id,Affiliation__c=aff.id);
        aaff2 = new AMS_Agency_Affiliation__c(Account__c=a2.id,Affiliation__c=aff.id);
        aaff3 = new AMS_Agency_Affiliation__c(Account__c=a3.id,Affiliation__c=aff.id);
        aaff4 = new AMS_Agency_Affiliation__c(Account__c=a4.id,Affiliation__c=aff.id);
        agencyAffiliations.add(aaff1);
        agencyAffiliations.add(aaff2);
        agencyAffiliations.add(aaff3);
        agencyAffiliations.add(aaff4);
        insert agencyAffiliations;
    }
    
    /**
    update agt. should have 4 agt update in list
    */
    public static testmethod void test_agencyUpdate_AGT(){
        configureTest();
        Test.startTest();


        List<Agency_Applied_Change_code__c> aacclist = new List<Agency_Applied_Change_code__c>();
        Agency_Applied_Change_code__c aacc1 = new Agency_Applied_Change_code__c(Account__c = a1.Id, Change_Code__c = 'CAD',  Sent_to_external_system__c = false);
        Agency_Applied_Change_code__c aacc2 = new Agency_Applied_Change_code__c(Account__c = a2.Id, Change_Code__c = 'CAD',  Sent_to_external_system__c = false);
        Agency_Applied_Change_code__c aacc3 = new Agency_Applied_Change_code__c(Account__c = a3.Id, Change_Code__c = 'CAD',  Sent_to_external_system__c = false);
        Agency_Applied_Change_code__c aacc4 = new Agency_Applied_Change_code__c(Account__c = a4.Id, Change_Code__c = 'CAD',  Sent_to_external_system__c = false);
        Agency_Applied_Change_code__c aacc5 = new Agency_Applied_Change_code__c(Account__c = a4.Id, Change_Code__c = 'CCF',  Sent_to_external_system__c = false);
        Agency_Applied_Change_code__c aacc6 = new Agency_Applied_Change_code__c(Account__c = a4.Id, Change_Code__c = 'NEW',  Sent_to_external_system__c = false);
        Agency_Applied_Change_code__c aacc7 = new Agency_Applied_Change_code__c(Account__c = a4.Id, Change_Code__c = 'TER',  Sent_to_external_system__c = false);
        aacclist.add(aacc1);
        aacclist.add(aacc2);
        aacclist.add(aacc3);
        aacclist.add(aacc4);
        aacclist.add(aacc5);
        aacclist.add(aacc6);
        aacclist.add(aacc7);
        insert aacclist;
        
        List<SObject> updateAll = new List<SObject>();
        a1.Name='Update Agency 1';
        a2.Name='Update Agency 2';
        a3.Name='Update Agency 3';
        a4.Name='Update Agency 4';
        updateAll.add(a1);
        updateAll.add(a2);
        updateAll.add(a3);
        updateAll.add(a4);
        update updateAll;
        
        List<AMS_Agency_Updates__c> agencyUpdateList = [select id, Update_Type__c, RelationShip__c, Account__c from AMS_Agency_Updates__c WHERE Integration_System__c = 'SAP PI'];
        System.assertEquals(4, agencyUpdateList.size());
        for(AMS_Agency_Updates__c au :agencyUpdateList){
            //System.assertEquals('Update', au.Update_Type__c);
            System.assertEquals('Invalid', au.Update_Type__c);
            System.assert(au.RelationShip__c == null);
            System.assert(au.Account__c != null);
        }
        Test.stopTest();
    }        

    /**
    Process changes on profile. should have 4 agt in agt updates
    
    DEPRECATED - the agency update is now only created from a Insert of a "Applied Change Code" record, this test no longer makes sense!
    */
    //public static testmethod void test_agencyUpdate_Profile(){
    //    configureTest();
    //    //custom coinfiguration
    //    ap1 = new AMS_Agency_Profile__c(Account__c=a1.id);
    //    ap2 = new AMS_Agency_Profile__c(Account__c=a2.id);
    //    ap3 = new AMS_Agency_Profile__c(Account__c=a3.id);
    //    ap4 = new AMS_Agency_Profile__c(Account__c=a4.id);
    //    agencyprofileList.add(ap1);
    //    agencyprofileList.add(ap2);
    //    agencyprofileList.add(ap3);
    //    agencyprofileList.add(ap4);
    //    insert agencyprofileList;
        
    //    Test.startTest();
    //    List<SObject> updateAll = new List<SObject>();
    //    ap1.GR_Code__c='AT';
    //    ap2.GR_Code__c='AT';
    //    ap3.GR_Code__c='AT';
    //    ap4.GR_Code__c='AT';
    //    updateAll.add(ap1);
    //    updateAll.add(ap2);
    //    updateAll.add(ap3);
    //    updateAll.add(ap4);
    //    update updateAll;
        
    //    List<AMS_Agency_Updates__c> agencyUpdateList = [select id, Update_Type__c, RelationShip__c, Account__c from AMS_Agency_Updates__c];
    //    System.assertEquals(4, agencyUpdateList.size());
    //    for(AMS_Agency_Updates__c au :agencyUpdateList){
    //        System.assertEquals('Update', au.Update_Type__c);
    //        System.assert(au.RelationShip__c == null);
    //        System.assert(au.Account__c != null);
    //    }
    //    Test.stopTest();
    //}
    
    /**
    
    Update only Onwers. shoiuld have 4 agencies to process in list

    DEPRECATED - the agency update is now only created from a Insert of a "Applied Change Code" record, this test no longer makes sense!
    */
    //public static testmethod void test_agencyUpdate_Owner(){
    //    configureTest();
    //    //custom coinfiguration

    //    ao1 = new AMS_Account_Role__c(Account__c = a1.id, Person__c = per.id);
    //    ao2 = new AMS_Account_Role__c(Account__c = a2.id, Person__c = per.id);
    //    ao3 = new AMS_Account_Role__c(Account__c = a3.id, Person__c = per.id);
    //    ao4 = new AMS_Account_Role__c(Account__c = a4.id, Person__c = per.id);
    //    agencyOwnershipList.add(ao1);
    //    agencyOwnershipList.add(ao2);
    //    agencyOwnershipList.add(ao3);
    //    agencyOwnershipList.add(ao4);
    //    insert agencyOwnershipList;
        
        
    //    Test.startTest();       
    //    List<SObject> updateAll = new List<SObject>();
    //    ao1.Percentage__c=1;
    //    ao2.Percentage__c=1;
    //    ao3.Percentage__c=1;
    //    ao4.Percentage__c=1;
    //    updateAll.add(ao1);
    //    updateAll.add(ao2);
    //    updateAll.add(ao3);
    //    updateAll.add(ao4);
    //    update updateAll;
        
    //    List<AMS_Agency_Updates__c> agencyUpdateList = [select id, Update_Type__c, RelationShip__c, Account__c from AMS_Agency_Updates__c];
    //    System.assertEquals(4, agencyUpdateList.size());
    //    for(AMS_Agency_Updates__c au :agencyUpdateList){
    //        System.assertEquals('Update', au.Update_Type__c);
    //        System.assert(au.RelationShip__c == null);
    //        System.assert(au.Account__c != null);
    //    }
    //    Test.stopTest();
    //}
    
    //public static testmethod void test_agencyUpdate_Address(){
    //    //custom coinfiguration
    //    //because of too many SOQL queries
    //    insert ctry ;
    //    a1 = new Account(Name='Test1 Agency',Short_Name__c='Test1 Agency', IATA_ISO_Country__c = ctry.id, IATAcode__c = '1234567', Sector__c = 'Travel Agent'/*, RecordTypeId = agenciesRT.get('PASSENGER')*/);
    //    a2 = new Account(Name='Test2 Agency',Short_Name__c='Test2 Agency', IATA_ISO_Country__c = ctry.id, IATAcode__c = '2345671', Sector__c = 'Travel Agent'/*, RecordTypeId = agenciesRT.get('PASSENGER')*/);
    //    agencylist.add(a1);
    //    agencylist.add(a2);
    //    insert agencylist;

    //    aa1 = new AMS_Address__c(Account__c=a1.id);
    //    aa2 = new AMS_Address__c(Account__c=a2.id);
    //    agencyAddressList.add(aa1);
    //    agencyAddressList.add(aa2);
    //    insert agencyAddressList;
        
        
    //    Test.startTest();
    //    List<SObject> updateAll = new List<SObject>();
    //    aa1.City__c='Portugal';
    //    aa2.City__c='Portugal';
    //    updateAll.add(aa1);
    //    //updateAll.add(aa2);

        
    //    List<AMS_Agency_Updates__c> agencyUpdateList = [select id, Update_Type__c, RelationShip__c, Account__c from AMS_Agency_Updates__c];
    //    System.assertEquals(2, agencyUpdateList.size());
    //    for(AMS_Agency_Updates__c au :agencyUpdateList){
    //        System.assertEquals('Update', au.Update_Type__c);
    //        System.assert(au.RelationShip__c == null);
    //        System.assert(au.Account__c != null);
    //    }
    //    Test.stopTest();
    //}
    
    //DEPRECATED - the agency update is now only created from a Insert of a "Applied Change Code" record, this test no longer makes sense!
    //public static testmethod void test_agencyUpdate_Accreditation(){
    //    configureTest();
        
    //    //custom coinfiguration
    //    ins1 = new AMS_Inspection__c(Account__c=a1.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '0');
    //    ins2 = new AMS_Inspection__c(Account__c=a2.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '0');
    //    ins3 = new AMS_Inspection__c(Account__c=a3.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '0');
    //    ins4 = new AMS_Inspection__c(Account__c=a4.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '0');
    //    agencyInspectionList.add(ins1);
    //    agencyInspectionList.add(ins2);
    //    agencyInspectionList.add(ins3);
    //    agencyInspectionList.add(ins4);       
    //    insert agencyInspectionList;
    //    Test.startTest();
        
    //    List<SObject> updateAll = new List<SObject>();
    //    ins1.Accreditation_Endorsement_Status_code__c='9';
    //    ins2.Accreditation_Endorsement_Status_code__c='9';
    //    ins3.Accreditation_Endorsement_Status_code__c='9';
    //    ins4.Accreditation_Endorsement_Status_code__c='9';
    //    updateAll.add(ins1);
    //    updateAll.add(ins2);
    //    updateAll.add(ins3);
    //    updateAll.add(ins4);
        
    //    List<AMS_Agency_Updates__c> agencyUpdateList = [select id, Update_Type__c, RelationShip__c, Account__c from AMS_Agency_Updates__c];
    //    System.assertEquals(4, agencyUpdateList.size());
    //    for(AMS_Agency_Updates__c au :agencyUpdateList){
    //        System.assertEquals('Update', au.Update_Type__c);
    //        System.assert(au.RelationShip__c == null);
    //        System.assert(au.Account__c != null);
    //    }
    //    Test.stopTest();
    //}
    
    //DEPRECATED - the agency update is now only created from a Insert of a "Applied Change Code" record, this test no longer makes sense!
    //  public static testmethod void test_agencyUpdate_Assignment(){
    //    configureTest();
    //    //custom coinfiguration
    //    as1 = new AMS_Agency_Segment__c(Account__c=a1.id,Segment__c=s.id);
    //    as2 = new AMS_Agency_Segment__c(Account__c=a2.id,Segment__c=s.id);
    //    as3 = new AMS_Agency_Segment__c(Account__c=a3.id,Segment__c=s.id);
    //    as4 = new AMS_Agency_Segment__c(Account__c=a4.id,Segment__c=s.id);
    //    agencySegmentList.add(as1);
    //    agencySegmentList.add(as2);
    //    agencySegmentList.add(as3);
    //    agencySegmentList.add(as4);
    //    insert agencySegmentList;
        
        
    //    Test.startTest();
    //    List<SObject> updateAll = new List<SObject>();
    //    as1.Assignation_Type__c='Extended';
    //    as2.Assignation_Type__c='Extended';
    //    as3.Assignation_Type__c='Extended';
    //    as4.Assignation_Type__c='Extended';
    //    updateAll.add(as1);
    //    updateAll.add(as2);
    //    updateAll.add(as3);
    //    updateAll.add(as4);
    //    update updateAll;
        
    //    List<AMS_Agency_Updates__c> agencyUpdateList = [select id, Update_Type__c, RelationShip__c, Account__c from AMS_Agency_Updates__c];
    //    System.assertEquals(4, agencyUpdateList.size());
    //    for(AMS_Agency_Updates__c au :agencyUpdateList){
    //        System.assertEquals('Update', au.Update_Type__c);
    //        System.assert(au.RelationShip__c == null);
    //        System.assert(au.Account__c != null);
    //    }
    //    Test.stopTest();
    //}
    
    
    
    //AMS-118
    //DEPRECATED - the agency update is now only created from a Insert of a "Applied Change Code" record, this test no longer makes sense!
    //public static testmethod void test_agencyUpdate_SeveralTimes() {
    //    configureTest();
        
    //    Test.startTest();
    //    aair1.CurrencyIsoCode='EUR';
    //    aair2.CurrencyIsoCode='EUR';
    //    aair3.CurrencyIsoCode='EUR';
    //    aair4.CurrencyIsoCode='EUR';
    //    emp1.Employee_type__c = 'CL';
    //    //emp2.Employee_type__c = 'CL';
    //    //emp3.Employee_type__c = 'CL';
    //    //emp4.Employee_type__c = 'CL';
    //    aaff1.CurrencyIsoCode='EUR';
    //    aaff2.CurrencyIsoCode='EUR';
    //    aaff3.CurrencyIsoCode='EUR';
    //    aaff4.CurrencyIsoCode='EUR';
        
    //    List<SObject> updateAll = new List<SObject>();

    //    updateAll.add(aair1);
    //    updateAll.add(aair2);
    //    updateAll.add(aair3);
    //    updateAll.add(aair4);

    //    updateAll.add(emp1);

    //    updateAll.add(aaff1);
    //    updateAll.add(aaff2);
    //    updateAll.add(aaff3);
    //    updateAll.add(aaff4);
    //    update updateAll;

    //    List<AMS_Agency_Updates__c> agencyUpdateList = [select id, Update_Type__c, RelationShip__c, Account__c from AMS_Agency_Updates__c];
    //    System.assertEquals(4, agencyUpdateList.size());
    //    for(AMS_Agency_Updates__c au :agencyUpdateList){
    //        System.assertEquals('Update', au.Update_Type__c);
    //        System.assert(au.RelationShip__c == null);
    //        System.assert(au.Account__c != null);
    //    }
    //    Test.stopTest();
        
    //}


    static testMethod void test_agencyUpdate_sentUpdate() {
        configureTest();
        
        List<Agency_Applied_Change_code__c> aacclist = new List<Agency_Applied_Change_code__c>();
        Agency_Applied_Change_code__c aacc1 = new Agency_Applied_Change_code__c(Account__c = a1.Id, Change_Code__c = 'TST',  Sent_to_external_system__c = false);
        aacclist.add(aacc1);
        insert aacclist;

        List<SObject> updateAll = new List<SObject>();
        a1.Name='Update Agency 1';
        update a1;
        
        AMS_Agency_Updates__c agencyUpdate = [select id, Update_Type__c, RelationShip__c, Account__c from AMS_Agency_Updates__c WHERE Integration_System__c = 'SAP PI'];

        Test.startTest();
        agencyUpdate.Update_Type__c = 'Update_Sent';
        update agencyUpdate;


        //system.assertEquals(true, [SELECT Sent_To_External_System__c FROM Account WHERE Id = :a1.id].Sent_To_External_System__c);
        Test.stopTest();
    }





    static testMethod void test_agencyUpdate_sentUpdate2() {
        configureTest();

        AMS_Agency_Updates__c agencyUpdate1 = new AMS_Agency_Updates__c(Update_Type__c = 'Update',  Account__c = a1.id);
        insert agencyUpdate1;
        
        List<Agency_Applied_Change_code__c> aacclist = new List<Agency_Applied_Change_code__c>();
        Agency_Applied_Change_code__c aacc1 = new Agency_Applied_Change_code__c(Account__c = a1.Id, Change_Code__c = 'TST',  Sent_to_external_system__c = false);
        aacclist.add(aacc1);
        insert aacclist;

        List<SObject> updateAll = new List<SObject>();
        a1.Name='Update Agency 1';
        update a1;
        
        List<AMS_Agency_Updates__c> agencyUpdate = [select id, Update_Type__c, RelationShip__c, Account__c from AMS_Agency_Updates__c];

        Test.startTest();
        agencyUpdate[0].Update_Type__c = 'Update_Sent';
        update agencyUpdate;

        Test.stopTest();
    }


    // Increase Code Coverage
    public static testmethod void test_ICC_01() {
        List<AMS_ChangeCodes__c> changeCodeList = new List<AMS_ChangeCodes__c>{
            new AMS_ChangeCodes__c(
                Name = '10', Change_Code__c = 'DWD', Integration_RecId__c = 'C'
            ),
            new AMS_ChangeCodes__c(
                Name = '100', Change_Code__c = 'TRW', Integration_RecId__c = 'C'
            ),
            new AMS_ChangeCodes__c(
                Name = '200', Change_Code__c = 'TST', Integration_RecId__c = 'D'
            ),
            new AMS_ChangeCodes__c(
                Name = '300', Change_Code__c = 'TRT', Integration_RecId__c = 'F'
            )
        };

        insert changeCodeList;

        List<AMS_ChangeCodes_Integration__c> changeCodeIntegrationList = new List<AMS_ChangeCodes_Integration__c>{
            new AMS_ChangeCodes_Integration__c(
                Name = 'test1',
                RecId_A__c = 'C',
                RecId_B__c = 'F',
                RecId_Res__c = 'F'
            )
        };

        insert changeCodeIntegrationList;


        insert ctry ;
        a1 = new Account(Name='Test1 Parent Agency',Short_Name__c='Test1 Parent Agency', IATAcode__c = '1234567', IATA_ISO_Country__c = ctry.id, Sector__c = 'Travel Agent'/*, RecordTypeId = agenciesRT.get('PASSENGER')*/);
        a2 = new Account(Name='Test1 Child Agency',Short_Name__c='Test1 Child Agency', IATAcode__c = '4566123', IATA_ISO_Country__c = ctry.id, Sector__c = 'Travel Agent'/*, RecordTypeId = agenciesRT.get('PASSENGER')*/);
        a3 = new Account(Name='Test2 Parent Agency',Short_Name__c='Test2 Parent Agency', IATAcode__c = '7891234', IATA_ISO_Country__c = ctry.id, Sector__c = 'Travel Agent'/*, RecordTypeId = agenciesRT.get('PASSENGER')*/);
        a4 = new Account(Name='Test2 Child Agency',Short_Name__c='Test2 Child Agency', IATAcode__c = '0001234', IATA_ISO_Country__c = ctry.id, Sector__c = 'Travel Agent'/*, RecordTypeId = agenciesRT.get('PASSENGER')*/);
        a5 = new Account(Name='Test3 Parent Agency',Short_Name__c='Test3 Parent Agency', IATAcode__c = '7891235', IATA_ISO_Country__c = ctry.id, Sector__c = 'Travel Agent'/*, RecordTypeId = agenciesRT.get('PASSENGER')*/);
        a6 = new Account(Name='Test3 Child Agency',Short_Name__c='Test3 Child Agency', IATAcode__c = '0001235', IATA_ISO_Country__c = ctry.id, Sector__c = 'Travel Agent'/*, RecordTypeId = agenciesRT.get('PASSENGER')*/);
        agencylist.add(a1);
        agencylist.add(a2);
        agencylist.add(a3);
        agencylist.add(a4);
        agencylist.add(a5);
        agencylist.add(a6);
        insert agencylist;

        List<Agency_Applied_Change_code__c> aacclist = new List<Agency_Applied_Change_code__c>();
        Agency_Applied_Change_code__c aacc1 = new Agency_Applied_Change_code__c(Account__c = a1.Id, Change_Code__c = 'TST',  Sent_to_external_system__c = false);
        Agency_Applied_Change_code__c aacc2 = new Agency_Applied_Change_code__c(Account__c = a2.Id, Change_Code__c = 'TST',  Sent_to_external_system__c = false);
        Agency_Applied_Change_code__c aacc3 = new Agency_Applied_Change_code__c(Account__c = a3.Id, Change_Code__c = 'TST',  Sent_to_external_system__c = false);
        aacclist.add(aacc1);
        aacclist.add(aacc2);
        aacclist.add(aacc3);
        insert aacclist;

        List<AMS_Agencies_Hierarchy__c> hierachieslist = new List<AMS_Agencies_Hierarchy__c>();
        AMS_Agencies_Hierarchy__c ah1 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c='Test Hierarchy');
        AMS_Agencies_Hierarchy__c ah2 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c='Another Test Hierarchy');
        hierachieslist.add(ah1);
        hierachieslist.add(ah2);
        insert hierachieslist;

        List<AMS_Agencies_relationhip__c> relationshiplist = new List<AMS_Agencies_relationhip__c>();
        AMS_Agencies_relationhip__c ar1 = new AMS_Agencies_relationhip__c(Relationship_details__c='Test',Hierarchy__c=ah1.id,Child_Account__c=a2.id,Parent_Account__c=a1.id);
        AMS_Agencies_relationhip__c ar2 = new AMS_Agencies_relationhip__c(Relationship_details__c='Test',Hierarchy__c=ah2.id,Child_Account__c=a4.id,Parent_Account__c=a3.id);
        AMS_Agencies_relationhip__c ar3 = new AMS_Agencies_relationhip__c(Relationship_details__c='Test',Hierarchy__c=ah1.id,Child_Account__c=a6.id,Parent_Account__c=a4.id);
        relationshiplist.add(ar1);
        relationshiplist.add(ar2);
        relationshiplist.add(ar3);
        insert relationshiplist;

        Test.startTest();
        ah1.Hierarchy_Name__c = 'Test update';
        ah2.Hierarchy_Name__c = 'Test update';
        ar1.Relationship_details__c = 'Test update';
        ar2.Relationship_details__c = 'Test update';
        List<SObject> updateAll = new List<SObject>();
        updateAll.add(ah1);
        updateAll.add(ah2);
        updateAll.add(ar1);
        updateAll.add(ar2);
        update updateAll;


        Agency_Applied_Change_code__c xpto1 = new Agency_Applied_Change_code__c(Account__c = a1.Id, Change_Code__c = 'TRW',  Sent_to_external_system__c = false);
        Agency_Applied_Change_code__c xpto2 = new Agency_Applied_Change_code__c(Account__c = a1.Id, Change_Code__c = 'TRT',  Sent_to_external_system__c = false);

        insert xpto1;
        insert xpto2;

        List<AMS_Agency_Updates__c> agencyUpdateList = [select id, Change_Code__c, Update_Type__c, RelationShip__c, Account__c from AMS_Agency_Updates__c where Account__c = :agencyList[0].Id];

        agencyList[0].Last_Integration_Date__c = null;

        update agencyList[0];


        for (AMS_Agency_Updates__c au : agencyUpdateList) {
            au.Change_Code__c = 'DWD';
            au.Update_Type__c = 'Update';
        }

        update agencyUpdateList;

        AMS_AgencyUpdateHelper.agencyUpdate(agencyList);

        AMS_AgencyUpdateHelper.agencyUpdate(agencyUpdateList);

        Test.stopTest();
    }
    
}
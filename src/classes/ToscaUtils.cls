public with sharing class ToscaUtils {
    
    public static final String PASSWORD = 'testTosca77!';
    public static final String NEW_HE_CASH = 'HE Cash';
    public static final String NEW_HE_CASHLESS = 'HE Cashless';
    public static final String NEW_HE_STANDARD = 'HE Standard';
    public static final String NEW_HO_PASSENGER = 'HO Passenger';
    public static final String NEW_HO_CARGO = 'HO Cargo';
    public static final String NEW_HE_CHILD_ACCOUNT = 'Child Account';
    public static final String CREATE_RISK_EVENT = 'Create Risk Event';
    public static final String NEW_HO_TIDS = 'HO TIDS';

    public static final String NEW_HE_CASH_WITH_HIERARCHY = 'HE Cash with hierarchy';
    public static final String NEW_HE_CASHLESS_WITH_HIERARCHY = 'HE Cashless with hierarchy';
    public static final String NEW_HE_CASH_WITH_MULTIPLE_HIERARCHY = 'HE Cash with multiple hierarchy';
    public static final String NEW_HE_CASH_LIMITED_COMPANY = 'HE Cash Limited Company';    
    public static final String NEW_RISK_SIDRA_LITE_CASE = 'cenas';
    public static final String NEW_RISK_SIDRA_LITE_CASE_RISK_B = 'cenas2';
    public static final String NEW_RISK_SIDRA_LITE_CASE_RISK_B_COMMON_OWNERSHIP = 'HE Risk with Sidra Lite Case - Common Ownership';
    public static final String NEW_RISK_STATUS_B_PASSED = 'Risk Status B - Passed';
    public static final String NEW_RISK_STATUS_A_PASSED = 'Risk Status A - Passed';
    public static final String NEW_RISK_STATUS_B_PASSED_FAIL_FSECURITY = 'HE Risk Status B - Fail Financial Security';
  	public static final String NEW_AIRLINE_AIRCRAFT_OPERATOR = 'Airline - Aircraft Operator';
    public static final String NEW_AIRLINE_MEMBER_STATE = 'Airline - Member State';

    /********************************************************************************************************

                                                FRED PERMISSIONS

    ********************************************************************************************************/
    public static final String PERMISSION_SET_FRED_SSO = 'FRED_SSO';
    public static final String PERMISSION_SET_FRED_PROVISIONING = 'FRED_Provisioning';
    public static final String PERMISSION_SET_FRED_PRIMARY_USER = 'FRED_Primary_User';

    public static final List<String> ALL_FRED_PERMISSION_SET = new List<String>{PERMISSION_SET_FRED_SSO, PERMISSION_SET_FRED_PROVISIONING, PERMISSION_SET_FRED_PRIMARY_USER};

/**
              SELECTOR
**/ 

    public static Account fetchToscaAccounts(){
        Account[] toscaAcc = [SELECT id, IATACode__c, Name, Location_Class__c,IATA_ISO_Country__c FROM Account WHERE Name LIKE 'Tosca Account%' ORDER BY CreatedDate DESC limit 1];

        if(toscaAcc.size() == 0)
            return null;
        else
            return toscaAcc[0];
    }

    public static Account fetchParentAccount(String iataCode){
        Account[] parentAcc = [SELECT id, IATACode__c, Name, Location_Type__c, Company_Type__c, Location_Class__c,IATA_ISO_Country__c, IATA_ISO_Country__r.Name, Sector__c
                               FROM Account 
                               WHERE IATACode__c =:iataCode];

        if(parentAcc.size() == 0)
            return null;
        else
            return parentAcc[0];
    }

    public static Account fetchParentAccountById(String id){
        Account[] parentAcc = [SELECT id, IATACode__c, Name, Location_Type__c, Company_Type__c, Location_Class__c,IATA_ISO_Country__c, IATA_ISO_Country__r.Name, Sector__c
                               FROM Account WHERE Id =:id];

        if(parentAcc.size() == 0)
            return null;
        else
            return parentAcc[0];
    }

    public static Account fetchChildAccount(){
        Account[] toscaChildAcc = [SELECT id, IATACode__c, Name FROM Account WHERE Name LIKE 'Tosca Child Account%' ORDER BY CreatedDate DESC limit 1];

        if(toscaChildAcc.size() == 0)
            return null;
        else
            return toscaChildAcc[0];
    }

    public static AMS_Agencies_Hierarchy__c fetchToscaAgenciedHierarchy(){
            AMS_Agencies_Hierarchy__c[] agenHierarchy = [SELECT id, Name, Hierarchy_Name__c FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Tosca hierarchy' limit 1];

            if(agenHierarchy.size() == 0)
                return null;
            else
                return agenHierarchy[0];
    }

    public static AMS_Agencies_relationhip__c fetchToscaAgenciedRelationship(){
        AMS_Agencies_relationhip__c[] agenRelationhip = [SELECT id, Name FROM AMS_Agencies_relationhip__c WHERE Hierarchy__r.Name = 'Tosca hierarchy'];

        if(agenRelationhip.size() == 0)
            return null;
        else
            return agenRelationhip[0];
    }

    public static Contact fetchToscaContacts(){
        Contact[] contact = [SELECT id, LastName FROM Contact WHERE Name LIKE 'Tosca Contact%' ORDER BY CreatedDate DESC limit 1];

        if(contact.size() == 0)
            return null;
        else
            return contact[0];
    }

    public static Portal_Applications__c fetchPortalApplication(){
        Portal_Applications__c[] portalApplication = [SELECT Id, Name FROM Portal_Applications__c WHERE Name = 'IATA Accreditation & Changes'];

        if(portalApplication.size() == 0)
            return null;
        else
            return portalApplication[0];
    }

    public static AMS_Settlement_System__c fetchAmsSettlementSystem(){
        AMS_Settlement_System__c[] settlementSystem = [SELECT id, Name FROM AMS_Settlement_System__c WHERE Name = 'BSP-FR'];

        if(settlementSystem.size() == 0)
            return null;
        else
            return settlementSystem[0];
    }

    public static AMS_Operation__c fetchOperationCode(Id isoCountry){
        AMS_Operation__c[] operationCode = [SELECT Id FROM AMS_Operation__c WHERE Country__c = :isoCountry and Name LIKE '%BSP%' ];

        if(operationCode.size() == 0)
            return null;
        else
            return operationCode[0];
    }

    public static ANG_BSP_Attributes__c fecthBspAttributes4Times(Id operationCode){
        ANG_BSP_Attributes__c[] bspAttributes4times = [SELECT Id FROM ANG_BSP_Attributes__c where Operation__c = :operationCode AND Remittance_Frequency__c = 'W'];

        if(bspAttributes4times.size() == 0)
            return null;
        else
            return bspAttributes4times[0];
    }

    public static ANG_BSP_Attributes__c fecthBspAttributesMontly(Id operationCode){
        ANG_BSP_Attributes__c[] bspAttributesmontly = [SELECT Id FROM ANG_BSP_Attributes__c where Operation__c = :operationCode AND Remittance_Frequency__c = 'M'];

        if(bspAttributesmontly.size() == 0)
            return null;
        else
            return bspAttributesmontly[0];
    }

    public static ANG_BSP_Attributes__c fecthBspAttributes5days(Id operationCode){
        ANG_BSP_Attributes__c[] bspAttributes5days = [SELECT Id FROM ANG_BSP_Attributes__c where Operation__c = :operationCode AND Remittance_Frequency__c = 'S'];

        if(bspAttributes5days.size() == 0)
            return null;
        else
            return bspAttributes5days[0];
    }

    public static Agency_Authorization__c fecthAgencyAuthorization(Id account){
        Agency_Authorization__c[] agencyAuthorization = [SELECT Id, Account__c, Status__c,Email_Used_for_BSP_Creation__c FROM Agency_Authorization__c where Account__c = :account AND Status__c = 'Active' AND Email_Used_for_BSP_Creation__c = 'toscaAuthorization@tosca.com'];

        if(agencyAuthorization.size() == 0)
            return null;
        else
            return agencyAuthorization[0];
    }

    public static Case fecthCommunicationCase(Id caseId){
        Case[] comCase = [SELECT Id, CaseNumber FROM Case where id = :caseId];

        if(comCase.size() == 0)
            return null;
        else
            return comCase[0];
    }

    public static AMS_Accreditation_Contact__c fetchAccreditationContact(){
        AMS_Accreditation_Contact__c[] accContact = [SELECT id, Last_name__c FROM AMS_Accreditation_Contact__c WHERE Last_name__c LIKE 'Accreditation Contact%' ORDER BY CreatedDate DESC limit 1];

        if(accContact.size() == 0)
            return null;
        else
            return accContact[0];
    }

    public static ANG_Agency_Risk_Event__c fetchRiskEvent(Id accountId){
        ANG_Agency_Risk_Event__c[] checkRiskEvent = [SELECT id,ANG_AccountId__c FROM ANG_Agency_Risk_Event__c WHERE ANG_AccountId__c =:accountId limit 1];

        if(checkRiskEvent.size() == 0)
            return null;
        else
            return checkRiskEvent[0];
    }

    public static AMS_OSCAR__c fetchOscar(Id relAccount){
        AMS_OSCAR__c[] checkOscar = [SELECT id,Account__c FROM AMS_OSCAR__c WHERE Account__c  =:relAccount limit 1];

        if(checkOscar.size() == 0)
            return null;
        else
            return checkOscar[0];
    }
    
	public static User fetchUser(){
        User[] checkUser = [SELECT id FROM User WHERE ContactId  =:fetchToscaContacts().Id limit 1];

        if(checkUser.size() == 0)
            return null;
        else
            return checkUser[0];
    }

/**
            ENTITY CREATOR
**/

    public static IATA_ISO_Country__c createIATAISOCountry(Map<String,Object> fieldsOfObject){
        
        IATA_ISO_Country__c country = new IATA_ISO_Country__c();
        
        sObject obj = ANG_EntityCreator.addFieldsToObject((sObject)country, fieldsOfObject);
        
        return (IATA_ISO_Country__c)ANG_EntityCreator.addFieldsToObject((sObject)obj,fieldsOfObject);
    }

    public static IATA_ISO_State__c createIATAISOState(Map<String,Object> fieldsOfObject){
        
        IATA_ISO_State__c isoState = new IATA_ISO_State__c();
        
        sObject obj = ANG_EntityCreator.addFieldsToObject((sObject)isoState, fieldsOfObject);
        
        return (IATA_ISO_State__c)ANG_EntityCreator.addFieldsToObject((sObject)obj,fieldsOfObject);
    }

    public static AMS_Agencies_Hierarchy__c createAgenciesHierarchy(Map<String,Object> fieldsOfObject){
        
        AMS_Agencies_Hierarchy__c agencyRel = new AMS_Agencies_Hierarchy__c();
        
        sObject obj = ANG_EntityCreator.addFieldsToObject((sObject)agencyRel, fieldsOfObject);
        
        return (AMS_Agencies_Hierarchy__c)ANG_EntityCreator.addFieldsToObject((sObject)obj,fieldsOfObject);
    }

    public static AMS_Agencies_relationhip__c createAgenciesRelationship(Map<String,Object> fieldsOfObject){
        
        AMS_Agencies_relationhip__c agencyRel = new AMS_Agencies_relationhip__c();
        
        sObject obj = ANG_EntityCreator.addFieldsToObject((sObject)agencyRel, fieldsOfObject);
        
        return (AMS_Agencies_relationhip__c)ANG_EntityCreator.addFieldsToObject((sObject)obj,fieldsOfObject);
    }

    public static User createPortalUser(Map<String,Object> fieldsOfObject){
        
        User user = new User();
        
        sObject obj = ANG_EntityCreator.addFieldsToObject((sObject)user, fieldsOfObject);
        
        return (User)ANG_EntityCreator.addFieldsToObject((sObject)obj,fieldsOfObject);
    }

    public static Portal_Applications__c createPortalApplication(Map<String,Object> fieldsOfObject){
        
        Portal_Applications__c portalApplication = new Portal_Applications__c();
        
        sObject obj = ANG_EntityCreator.addFieldsToObject((sObject)portalApplication, fieldsOfObject);
        
        return (Portal_Applications__c)ANG_EntityCreator.addFieldsToObject((sObject)obj,fieldsOfObject);
    }

    public static Portal_Application_Right__c createPortalApplicationRight(Map<String,Object> fieldsOfObject){
        
        Portal_Application_Right__c portalApplicationRight = new Portal_Application_Right__c();
        
        sObject obj = ANG_EntityCreator.addFieldsToObject((sObject)portalApplicationRight, fieldsOfObject);
        
        return (Portal_Application_Right__c)ANG_EntityCreator.addFieldsToObject((sObject)obj,fieldsOfObject);
    }

    public static Case createSidraCase(Map<String,Object> fieldsOfObject){
        
        Case caseSidra = new Case();
        
        sObject obj = ANG_EntityCreator.addFieldsToObject((sObject)caseSidra, fieldsOfObject);
        
        return (Case)ANG_EntityCreator.addFieldsToObject((sObject)obj,fieldsOfObject);
    }

    public static AMS_Settlement_System__c createAMSSettlementSystem(Map<String,Object> fieldsOfObject){
        
        AMS_Settlement_System__c settlementSystem = new AMS_Settlement_System__c();
        
        sObject obj = ANG_EntityCreator.addFieldsToObject((sObject)settlementSystem, fieldsOfObject);
        
        return (AMS_Settlement_System__c)ANG_EntityCreator.addFieldsToObject((sObject)obj,fieldsOfObject);
    }

    public static AMS_Operation__c amsOperationCode(Map<String,Object> fieldsOfObject){
        
        AMS_Operation__c operationCode = new AMS_Operation__c();
        
        sObject obj = ANG_EntityCreator.addFieldsToObject((sObject)operationCode, fieldsOfObject);
        
        return (AMS_Operation__c)ANG_EntityCreator.addFieldsToObject((sObject)obj,fieldsOfObject);
    }

    public static ANG_BSP_Attributes__c angBSPAttributes(Map<String,Object> fieldsOfObject){
        
        ANG_BSP_Attributes__c bspAttributes = new ANG_BSP_Attributes__c();
        
        sObject obj = ANG_EntityCreator.addFieldsToObject((sObject)bspAttributes, fieldsOfObject);
        
        return (ANG_BSP_Attributes__c)ANG_EntityCreator.addFieldsToObject((sObject)obj,fieldsOfObject);
    }

    public static Agency_Authorization__c agencyAuthorization(Map<String,Object> fieldsOfObject){
        
        Agency_Authorization__c newAgencyAuthorization = new Agency_Authorization__c();
        
        sObject obj = ANG_EntityCreator.addFieldsToObject((sObject)newAgencyAuthorization, fieldsOfObject);
        
        return (Agency_Authorization__c)ANG_EntityCreator.addFieldsToObject((sObject)obj,fieldsOfObject);
    }

    public static ANG_Agency_Risk_Event__c agRiskEvent(Map<String,Object> fieldsOfObject){
        
        ANG_Agency_Risk_Event__c agencyRiskEvent = new ANG_Agency_Risk_Event__c();
        
        sObject obj = ANG_EntityCreator.addFieldsToObject((sObject)agencyRiskEvent, fieldsOfObject);
        
        return (ANG_Agency_Risk_Event__c)ANG_EntityCreator.addFieldsToObject((sObject)obj,fieldsOfObject);
    }

   public static ANG_Agency_Risk_Event__c updateRiskEvent(ANG_Agency_Risk_Event__c obj, Map<String,Object> fieldsOfObject){

        return (ANG_Agency_Risk_Event__c)ANG_EntityCreator.addFieldsToObject((sObject)obj, fieldsOfObject);
    }

    public static Agency_Applied_Change_code__c agChangeCodeNew(Map<String,Object> fieldsOfObject){
        
        Agency_Applied_Change_code__c agencyChangeCode = new Agency_Applied_Change_code__c();
        
        sObject obj = ANG_EntityCreator.addFieldsToObject((sObject)agencyChangeCode, fieldsOfObject);
        
        return (Agency_Applied_Change_code__c)ANG_EntityCreator.addFieldsToObject((sObject)obj,fieldsOfObject);
    }

    public static Agency_Applied_Change_code__c agChangeCodeFin(Map<String,Object> fieldsOfObject){
        
        Agency_Applied_Change_code__c agencyChangeCode = new Agency_Applied_Change_code__c();
        
        sObject obj = ANG_EntityCreator.addFieldsToObject((sObject)agencyChangeCode, fieldsOfObject);
        
        return (Agency_Applied_Change_code__c)ANG_EntityCreator.addFieldsToObject((sObject)obj,fieldsOfObject);
    }

    public static AMS_Account_Role__c accRole (Map<String,Object> fieldsOfObject){
        
        AMS_Account_Role__c accountRole = new AMS_Account_Role__c();
        
        sObject obj = ANG_EntityCreator.addFieldsToObject((sObject)accountRole, fieldsOfObject);
        
        return (AMS_Account_Role__c)ANG_EntityCreator.addFieldsToObject((sObject)obj,fieldsOfObject);
    }


    public ToscaUtils() {}
}
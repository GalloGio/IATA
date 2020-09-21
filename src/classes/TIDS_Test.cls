@IsTest
public with sharing class TIDS_Test {

    @TestSetup
    private static void setup() {
        
        Id headquarters = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency') ;

        country = new IATA_ISO_Country__c();
        country.Name = 'Canada';
        country.ISO_Code__c = 'CA';
        country.AIMS_Area_Name__c = 'Canada';
        country.AIMS_Area_ID__c = '1';
        insert country;
    
        IATA_ISO_State__c dstate = new IATA_ISO_State__c();
        dstate.Name = 'Prince Edwards';
        dstate.ISO_Code__c = 'CA-PE';
		dstate.IATA_ISO_Country__c=country.Id;
		dstate.Valid_for_Address__c=true;
        insert dstate;
        
        state = new IATA_ISO_State__c();
        state.Name = 'Quebec';
        state.ISO_Code__c = 'QC';
		state.IATA_ISO_Country__c=country.Id;
		state.Valid_for_Address__c=true;
        insert state;

        List<Account> accountsToInsert = new List<Account>();

        acc = new Account();
        acc.Name = 'TIDS account';
        acc.BillingCity = 'Montreal';
        acc.BillingCountry = 'Canada';
        acc.BillingStreet = 'some street';
        acc.IATA_ISO_Country__c = country.Id;
        acc.Location_Type__c = 'HO';
        acc.IATACode__c = null;
        acc.Location_Class__c='T';
        acc.Type = 'Agency';
		acc.Status__c = 'Approved';
		acc.RecordTypeId = headquarters;
		accountsToInsert.add(acc);

		Account accd = new Account();
        accd.Name = 'TIDS inc.';
        accd.BillingCity = 'Montreal';
        accd.BillingCountry = 'Canada';
        accd.BillingStreet = 'some street';
        accd.IATA_ISO_Country__c = country.Id;
        accd.Location_Type__c = 'HO';
        accd.IATACode__c = null;
        accd.Location_Class__c='T';
        accd.Type = 'Agency';
		accd.Status__c = 'Approved';
		accd.IATA_ISO_Country__c=country.Id;
        accd.RecordTypeId = headquarters;
        accountsToInsert.add(accd);

		insert accountsToInsert;
		
		createContact();
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency User (Partner)'].Id;

        createUser(profileId);
        
        //TIDS service
        portalApplications = new Portal_Applications__c();
        portalApplications.Name = 'TIDS';
        portalApplications.TIDS_Total_Ownership_Minimum__c=1;
        portalApplications.TIDS_Total_Ownership_Maximum__c=100;
        portalApplications.TIDS_Non_Eligible_Location_Countries__c='CA';
        insert portalApplications;

		List<Code_Range__c>  lrange  = new List<Code_Range__c>();
		for(integer i=0; i<10;i++){
			Code_Range__c  range  = new  Code_Range__c();
			range.IATA_ISO_State__c=dstate.Id;
			range.Area_Code__c=i;
			range.Area__c=null;
			range.IATA_ISO_Country__c=country.Id;
			range.Prefix__c='96';
			range.Program__c=null;
			range.Name=String.valueOf(i) + '-96-CA-CA-PE-T-[0-9999]';
			range.Min_Range__c=0;
			range.Max_Range__c=9999;
			range.ProgramCode__c='T';
			lrange.add(range);
		}
		insert lrange;
		
		List<AMS_Account_Role__c> amsroles = new List<AMS_Account_Role__c>();
		for (integer i=0; i<10; i++){
			AMS_Account_Role__c item = new AMS_Account_Role__c();
			item.Percentage__c=10;
			item.Owner_Category__c='Company';
			item.Owner_Name__c='Tids owner';
			item.Owner_Email__c='tids@iata.org';
			item.Account__c=acc.Id;
			amsroles.add(item);
		}
		insert amsroles;

		
		
		
        /*
        //GADM Participang Account Role
        Account_Roles__c accountRoles = new Account_Roles__c();
        accountRoles.Name = 'GADM Participant';
        insert accountRoles;

        Account_Role_Services__c accountRoleServices = new Account_Role_Services__c();
        accountRoleServices.Portal_Service__c = portalApplications.Id;
        accountRoleServices.Account_Roles__c = accountRoles.Id;
        insert accountRoleServices;

        Id defaultRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Default');

        Date today = Date.today();

        List<Account_Role__c> accountRolesToInsert = new List<Account_Role__c>();

        Account_Role__c accountRole = new Account_Role__c();
        accountRole.RecordTypeId = defaultRecordTypeId;
        accountRole.Account__c = acc.Id;
        accountRole.Account_Roles__c = accountRoles.Id;
        accountRole.Status__c = 'Active';
        accountRole.Effective_From_Date__c = today.addDays(-2);
        accountRole.Effective_To_Date__c = today;
        accountRolesToInsert.add(accountRole);

        insert accountRolesToInsert;
        */

    }
    private static Portal_Applications__c portalApplications {get;set;}
    private static Account acc {get;set;}
    private static IATA_ISO_Country__c country {get;set;}
    private static IATA_ISO_State__c state {get;set;}
    private static User testUser {get;set;}
    private static Contact testContact {get;set;}
    private static void createContact() {

        testContact = new Contact();
        testContact.AccountId = acc.id;
        testContact.Firstname = 'Primary';
        testContact.Lastname= 'Smith';
        testContact.Phone = '911111113';
        testContact.MobilePhone = '911111113';
        testContact.Email = 'Primary.Smith.test@somedomain.com';
        testContact.BSP_CASS_Payment_contact__c = false;
		testContact.User_Portal_Status__c = 'Approved';

		Contact testContact1 = new Contact();
        testContact1.AccountId = acc.id;
        testContact1.Firstname = 'Secondary';
        testContact1.Lastname= 'Smith';
        testContact1.Phone = '911111113';
        testContact1.MobilePhone = '911111113';
        testContact1.Email = 'Secondary.Smith.test@somedomain.com';
        testContact1.BSP_CASS_Payment_contact__c = false;
		testContact1.User_Portal_Status__c = 'Approved';
		
		List<Contact> lcontact = new List<Contact>();
		lcontact.add(testContact1);
		lcontact.add(testContact);
		
        insert lcontact;
    }
    private static void createProfileSetup(){
		/*
		Id profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency User (Partner)'].Id;

		ISSP_CS__c prof = new ISSP_CS__c();
		prof.Name='ISS_Portal_Agency_User';
		prof.value__c=String.ValueOf(profileId);
		*/
		
		ISSP_CS__c prof1 = new ISSP_CS__c();
		prof1.Name='Host';
		prof1.value__c='iata.org';

		List<ISSP_CS__c> lprof = new List<ISSP_CS__c>();
		//lprof.add(prof);
		lprof.add(prof1);
		insert lprof;
	}
    private static void createUser(Id profileId) {
        testUser = new User();
        testUser.alias = 'dsfsdfds';
        testUser.email = testContact.email;
        testUser.emailencodingkey = 'UTF-8';
        testUser.firstname = testContact.firstName;
        testUser.lastname = testContact.lastname;
        testUser.languagelocalekey = 'en_US';
        testUser.localesidkey = 'en_US';
        testUser.contactId = testContact.Id;
        testUser.FederationIdentifier = testContact.Id;
        testUser.timezonesidkey = 'Asia/Dubai';
        testUser.Username = testContact.Email;
        testUser.PortalRole = 'Manager';
        testUser.CommunityNickname = (testContact.FirstName + testContact.LastName).substring(0,8);
        testUser.ProfileId = profileId;
        testUser.IsActive = true;
        insert testUser;
    }
    private static String applicationReplace(String applicationstring){
        Map<String, String> appmap = new Map<String, String>();
        appmap.put('@userId', userId == null ? '':String.ValueOf(userId));
        appmap.put('@accountId', accountId == null ? '': String.ValueOf(accountId));
        appmap.put('@contactId', contactId == null ? '':String.ValueOf(contactId));
        appmap.put('@countryId', countryId == null ? '':String.ValueOf(countryId));
        appmap.put('@stateId', stateId == null ? '':String.ValueOf(stateId));
        appmap.put('@caseId', caseId == null ? '':String.ValueOf(caseId));
        for(String key:appmap.KeySet()){
            applicationstring = applicationstring.replaceAll(key, (String) appmap.get(key));
        }
		return applicationstring;        
	}
	private static void createProfiles(){
		List<GDP_Reference_Table__c> lcode = new List<GDP_Reference_Table__c>();

		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='NA', Corresponding_AMS_Code__c='NOGDS',Table__c='AIRSYS'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='SA', Corresponding_AMS_Code__c='SABR',Table__c='AIRSYS'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='SD', Corresponding_AMS_Code__c=null,Table__c='AIRSYS'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='SO', Corresponding_AMS_Code__c=null,Table__c='AIRSYS'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='WS', Corresponding_AMS_Code__c='WSPN',Table__c='AIRSYS'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='PA', Corresponding_AMS_Code__c=null,Table__c='AIRSYS'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='AB', Corresponding_AMS_Code__c='ABAC',Table__c='AIRSYS'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='AX', Corresponding_AMS_Code__c='AXSS',Table__c='AIRSYS'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='FL', Corresponding_AMS_Code__c='FLGX',Table__c='AIRSYS'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='IF', Corresponding_AMS_Code__c='INFI',Table__c='AIRSYS'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='KS', Corresponding_AMS_Code__c='CMAS',Table__c='AIRSYS'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='TK', Corresponding_AMS_Code__c='MINS',Table__c='AIRSYS'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='DA', Corresponding_AMS_Code__c=null,Table__c='AIRSYS'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='AM', Corresponding_AMS_Code__c='AGTD',Table__c='AIRSYS'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='AP', Corresponding_AMS_Code__c='UALA',Table__c='AIRSYS'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='GE', Corresponding_AMS_Code__c=null,Table__c='AIRSYS'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='GL', Corresponding_AMS_Code__c='GDSL',Table__c='AIRSYS'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='CO', Corresponding_AMS_Code__c=null,Table__c='AIRSYS'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='SA', Corresponding_AMS_Code__c=null,Table__c='APDEST'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='SC', Corresponding_AMS_Code__c=null,Table__c='APDEST'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='SP', Corresponding_AMS_Code__c=null,Table__c='APDEST'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='US', Corresponding_AMS_Code__c=null,Table__c='APDEST'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='AZ', Corresponding_AMS_Code__c=null,Table__c='APDEST'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='A3', Corresponding_AMS_Code__c=null,Table__c='APDEST'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='AF', Corresponding_AMS_Code__c=null,Table__c='APDEST'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='AH', Corresponding_AMS_Code__c=null,Table__c='APDEST'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='AL', Corresponding_AMS_Code__c=null,Table__c='APDEST'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='AS', Corresponding_AMS_Code__c=null,Table__c='APDEST'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='ME', Corresponding_AMS_Code__c=null,Table__c='APDEST'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='MX', Corresponding_AMS_Code__c=null,Table__c='APDEST'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='NA', Corresponding_AMS_Code__c=null,Table__c='APDEST'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='OT', Corresponding_AMS_Code__c=null,Table__c='APDEST'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='EU', Corresponding_AMS_Code__c=null,Table__c='APDEST'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='FR', Corresponding_AMS_Code__c=null,Table__c='APDEST'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='GB', Corresponding_AMS_Code__c=null,Table__c='APDEST'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='CB', Corresponding_AMS_Code__c=null,Table__c='APDEST'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='A1', Corresponding_AMS_Code__c=null,Table__c='APDEST'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='A2', Corresponding_AMS_Code__c=null,Table__c='APDEST'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='3', Corresponding_AMS_Code__c=null,Table__c='APEMP'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='1', Corresponding_AMS_Code__c=null,Table__c='APEMP'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='4', Corresponding_AMS_Code__c=null,Table__c='APEMP'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='2', Corresponding_AMS_Code__c=null,Table__c='APEMP'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='CT', Corresponding_AMS_Code__c=null,Table__c='APPRAC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='OL', Corresponding_AMS_Code__c=null,Table__c='APPRAC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='JK', Corresponding_AMS_Code__c=null,Table__c='APPRAC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='SS', Corresponding_AMS_Code__c=null,Table__c='APPRAC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='TO', Corresponding_AMS_Code__c=null,Table__c='APPRAC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='RT', Corresponding_AMS_Code__c=null,Table__c='APPRAC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='MC', Corresponding_AMS_Code__c=null,Table__c='APPRAC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='GI', Corresponding_AMS_Code__c=null,Table__c='APPRAC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='CN', Corresponding_AMS_Code__c=null,Table__c='APPRAC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='1', Corresponding_AMS_Code__c=null,Table__c='APSALE'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='2', Corresponding_AMS_Code__c=null,Table__c='APSALE'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='3', Corresponding_AMS_Code__c=null,Table__c='APSALE'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='4', Corresponding_AMS_Code__c=null,Table__c='APSALE'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='5', Corresponding_AMS_Code__c=null,Table__c='APSALE'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='6', Corresponding_AMS_Code__c=null,Table__c='APSALE'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='7', Corresponding_AMS_Code__c=null,Table__c='APSALE'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='SB', Corresponding_AMS_Code__c=null,Table__c='APSPEC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='SF', Corresponding_AMS_Code__c=null,Table__c='APSPEC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='SG', Corresponding_AMS_Code__c=null,Table__c='APSPEC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='SN', Corresponding_AMS_Code__c=null,Table__c='APSPEC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='SP', Corresponding_AMS_Code__c=null,Table__c='APSPEC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='ED', Corresponding_AMS_Code__c=null,Table__c='APSPEC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='IB', Corresponding_AMS_Code__c=null,Table__c='APSPEC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='IN', Corresponding_AMS_Code__c=null,Table__c='APSPEC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='RL', Corresponding_AMS_Code__c=null,Table__c='APSPEC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='BH', Corresponding_AMS_Code__c=null,Table__c='APSPEC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='AD', Corresponding_AMS_Code__c=null,Table__c='APSPEC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='ML', Corresponding_AMS_Code__c=null,Table__c='APSPEC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='OT', Corresponding_AMS_Code__c=null,Table__c='APSPEC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='EN', Corresponding_AMS_Code__c=null,Table__c='APSPEC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='ET', Corresponding_AMS_Code__c=null,Table__c='APSPEC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='GA', Corresponding_AMS_Code__c=null,Table__c='APSPEC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='GF', Corresponding_AMS_Code__c=null,Table__c='APSPEC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='GR', Corresponding_AMS_Code__c=null,Table__c='APSPEC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='HC', Corresponding_AMS_Code__c=null,Table__c='APSPEC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='HL', Corresponding_AMS_Code__c=null,Table__c='APSPEC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='CF', Corresponding_AMS_Code__c=null,Table__c='APSPEC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='CP', Corresponding_AMS_Code__c=null,Table__c='APSPEC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='CR', Corresponding_AMS_Code__c=null,Table__c='APSPEC'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='LAN', Corresponding_AMS_Code__c=null,Table__c='FOCUSVALUES'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='TOU', Corresponding_AMS_Code__c=null,Table__c='FOCUSVALUES'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='MEE', Corresponding_AMS_Code__c=null,Table__c='FOCUSVALUES'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='AIR', Corresponding_AMS_Code__c=null,Table__c='FOCUSVALUES'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='CRU', Corresponding_AMS_Code__c=null,Table__c='FOCUSVALUES'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='ACC', Corresponding_AMS_Code__c=null,Table__c='FOCUSVALUES'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='S', Corresponding_AMS_Code__c=null,Table__c='LGLTYP'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='E', Corresponding_AMS_Code__c=null,Table__c='LGLTYP'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='V', Corresponding_AMS_Code__c=null,Table__c='LGLTYP'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='T', Corresponding_AMS_Code__c=null,Table__c='LGLTYP'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='J', Corresponding_AMS_Code__c=null,Table__c='LGLTYP'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='L', Corresponding_AMS_Code__c=null,Table__c='LGLTYP'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='P', Corresponding_AMS_Code__c=null,Table__c='LGLTYP'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='R', Corresponding_AMS_Code__c=null,Table__c='LGLTYP'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='0', Corresponding_AMS_Code__c=null,Table__c='LGLTYP'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='O', Corresponding_AMS_Code__c=null,Table__c='LGLTYP'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='C', Corresponding_AMS_Code__c=null,Table__c='LGLTYP'));
		lcode.add(new GDP_Reference_Table__c(Valid_For_TIDS__c=true,Code__c='A', Corresponding_AMS_Code__c=null,Table__c='LGLTYP'));
		insert lcode;
	}
    private static Id userId {get;set;}
    private static Id accountId {get;set;}
	private static Id contactId {get;set;}
	private static Id secondaryId {get;set;}
    private static Id countryId {get;set;}
    private static Id stateId {get;set;}
    private static Id caseId {get;set;}
    private static void readObjectsId(){
		String emailp = 'Primary.Smith.test@somedomain.com';
		String emails = 'Secondary.Smith.test@somedomain.com';
        userId = [select Id From User where alias = 'dsfsdfds' limit 1].Id;
        accountId = [select Id From Account where name = 'TIDS account' limit 1].Id;
		contactId = [select Id From contact where Email =:emailp limit 1].Id;
		secondaryId = [select Id From contact where Email =:emails limit 1].Id;
        countryId = [select Id From IATA_ISO_Country__c where ISO_Code__c='CA' limit 1].Id;
        stateId = [select Id From IATA_ISO_State__c where ISO_Code__c='CA-PE' limit 1].Id;
  	}
	private static void readObjectsId2(){
		String emailp = 'Primary.Smith.test@somedomain.com';
		String emails = 'Secondary.Smith.test@somedomain.com';
        userId = [select Id From User where alias = 'dsfsdfds' limit 1].Id;
        accountId = [select Id From Account where name = 'TIDS account' limit 1].Id;
		contactId = [select Id From contact where Email =:emailp limit 1].Id;
		secondaryId = [select Id From contact where Email =:emails limit 1].Id;
	}   
    private static void createHORight(){
		Portal_Applications__c service = [ SELECT Id
				FROM Portal_Applications__c
				WHERE Name='TIDS'
				LIMIT 1];

        Portal_Application_Right__c right = new Portal_Application_Right__c();
		right.Contact__c=contactId;
		right.Portal_Application__c=service.Id;
		right.Access_Status_Reason__c='TIDS Admin HO Primary';
        right.Right__c='Access Granted';
        insert right;
    }
	
	@IsTest
    private static void runUtilities() {

        Test.startTest();
        String errorMessage = '';
        //System.runAs(testUser) {
            //try{
				set<String> l= new Set<String>{'APPRAC','APSALE','APDEST','APSPEC','LGLTYP','AIRSYS','FOCUSVALUES','PREFLANG','APEMP'};
				List<GDP_Reference_Table__c> ltable = new List<GDP_Reference_Table__c>();
				for(String key:l){
					GDP_Reference_Table__c t1 = new GDP_Reference_Table__c();
					t1.Name=key+'-TIDS';
					t1.Code__c='TIDS';
					t1.Valid_For_TIDS__c=true;
					t1.Table__c = key;
					ltable.add(t1);
				}
                insert ltable;
                TIDSUtil.companyTypes();
				TIDSUtil.mainMarketSpecialization();
				TIDSUtil.principalDestination();
				TIDSUtil.salesVolume();
				TIDSUtil.mainActivity();
				TIDSUtil.getNumberOfEmployees();
                TIDSUtil.getPreferedLanguages();
				TIDSUtil.getFocusValues();
				TIDSUtil.getGDSValues();
               
            //}catch(Exception e) {
            //	errorMessage = e.getMessage();
            //	System.debug('error message:: ' + errorMessage);
            //}
        //}
        Test.stopTest();
        //System.assertEquals(true, errorMessage.contains(System.Label.GADM_account_contact_role_gadm_user), 'Inserting duplicate should not be allowed!');
	}
	
	
    @IsTest
    private static void chgProfile() {

        Test.startTest();
        String errorMessage = '';
        //System.runAs(testUser) {
            //try{
                
                String applicationDecision;
                String userType='client';
                String applicationType='chg-business-profile-specialization';
                String applicationsettings;
                String reason='';
				//
				createProfiles();
                readObjectsId();
            	applicationsettings ='{\"userType\":\"client\",\"applicationType\":\"chg-business-profile-specialization\",\"userInfo\":{\"tidsAccount\":{\"Location_Type\":\"HO\",\"Id\":\"@accountId\"}},\"businessRules\":{\"Name\":\"TIDS\",\"Id\":\"@accountId\",\"TIDS_Total_Ownership_Minimum\":\"95\",\"TIDS_Total_Ownership_Maximum\":\"101\"},\"tidsCase\":{\"Id\":\"@caseId\"},\"sections\":{\"Welcome\":{\"cmpName\":\"new-applicant\",\"target\":\"NA\",\"values\":{\"companyLegalName\":\"Bottas Racing Inc.\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"NA\",\"vettingErrors\":[]},\"AgencyLegalStatus\":{},\"ShareholderDetails\":{},\"Address\":{\"sectionName\":\"Address\",\"cmpName\":\"address\",\"values\":{\"address\":\"15 Rue Papineau East\",\"city\":\"Montréal\",\"citygeonameId\":\"@cityId\",\"state\":{\"Id\":\"@stateId\",\"label\":\"Quebec\",\"value\":\"CA-QC\"},\"postalCode\":\"H2V4T8\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Mailing\":{\"sectionName\":\"Mailing\",\"cmpName\":\"mailing\",\"values\":{\"isMailingSameAsPhysicalAddress\":\"false\",\"mailingAddress\":\"33 Expedia Avenue\",\"city\":\"Seattle\",\"citygeonameId\":\"@cityId\",\"state\":{\"Id\":\"@stateId\",\"label\":\"Washington\",\"value\":\"US-WA\"},\"postalCode\":\"98888\",\"countryName\":\"United States\",\"countryIsoCode\":\"US\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Contact\":{\"sectionName\":\"Contact\",\"cmpName\":\"contact\",\"values\":{\"preferedLanguage\":\"ENG\",\"phone\":\"15148740202\",\"fax\":\"999888666\",\"businessEmail\":\"lorem@ipsum.com\",\"webSite\":\"www.loremipsum.com\",\"omFirstName\":\"Lorem\",\"omLastName\":\"Ipsum\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"BusinessProfile\":{\"sectionName\":\"Business Profile\",\"cmpName\":\"business-profile\",\"values\":{\"principalActivities\":{\"fieldName\":\"principalActivities\",\"values\":[{\"label\":\"Retail Travel Agent\",\"value\":\"RT\"}]},\"marketFocus\":{\"fieldName\":\"marketFocus\",\"values\":[{\"label\":\"Corporate\",\"value\":\"75\"},{\"label\":\"Leisure\",\"value\":\"25\"}]},\"salesMix\":{\"fieldName\":\"salesMix\",\"values\":[{\"label\":\"Online\",\"value\":\"95\"},{\"label\":\"Offline\",\"value\":\"5\"}]},\"travelSales\":{\"fieldName\":\"travelSales\",\"values\":\"1\"},\"GDS\":{\"fieldName\":\"GDS\",\"values\":[{\"label\":\"Farelogix\",\"value\":\"FLGX\"}]},\"numberEmployees\":{\"fieldName\":\"numberEmployees\",\"values\":\"3\"},\"numberOffices\":{\"fieldName\":\"numberOffices\",\"values\":\"9\"}},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"BusinessSpecialization\":{\"sectionName\":\"Business Specialization\",\"cmpName\":\"business-specialization\",\"values\":{\"percentageBreakdown\":{\"fieldName\":\"percentageBreakdown\",\"values\":[{\"label\":\"Air Travel\",\"value\":\"55\",\"id\":null,\"isSelected\":\"false\"},{\"label\":\"Cruises\",\"value\":null,\"id\":null,\"isSelected\":\"false\"},{\"label\":\"Tours & Packages\",\"value\":\"5\",\"id\":null,\"isSelected\":\"false\"},{\"label\":\"Meetings & Events\",\"value\":null,\"id\":null,\"isSelected\":\"false\"},{\"label\":\"Accommodation\",\"value\":\"25\",\"id\":null,\"isSelected\":\"false\"},{\"label\":\"Land Transportation\",\"value\":\"15\",\"id\":null,\"isSelected\":\"false\"}]},\"marketSpecialties\":{\"fieldName\":\"marketSpecialties\",\"values\":[{\"label\":\"Adventure\",\"value\":\"AD\"},{\"label\":\"Cruises\",\"value\":\"CR\"},{\"label\":\"Educational\",\"value\":\"ED\"}]},\"destinationSpecialties\":{\"fieldName\":\"destinationSpecialties\",\"values\":[{\"label\":\"France\",\"value\":\"FR\"},{\"label\":\"General\",\"value\":\"AL\"},{\"label\":\"Mexico\",\"value\":\"MX\"}]}},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"SupportingDocuments\":{}},\"sectionsDone\":[{\"id\":0,\"sectionName\":\"business-profile\",\"next\":\"business-specialization\"},{\"id\":1,\"sectionName\":\"business-specialization\",\"next\":\"submit-application\"}]}';
				applicationsettings=applicationReplace(applicationsettings);
			 	caseId = TIDSHelper.saveSettings(
                                    accountId,
                                    applicationsettings,
                                    applicationtype,
									null);
				applicationsettings=applicationReplace(applicationsettings);
				TIDS_Controller.applicationSubmitted(caseId, applicationsettings,applicationType );
				TIDS_Controller.autoApproved(new List<String>{String.ValueOf(caseId)});
				TIDSReportChanges.getBusinessProfileSpecialization(String.ValueOf(accountId), true);
				TIDSReportChanges.getBusinessProfileSpecialization(String.ValueOf(accountId), false);
	
            //}catch(Exception e) {
            //	errorMessage = e.getMessage();
            //	System.debug('error message:: ' + errorMessage);
            //}
        //}
        Test.stopTest();
        //System.assertEquals(true, errorMessage.contains(System.Label.GADM_account_contact_role_gadm_user), 'Inserting duplicate should not be allowed!');
	}
	@IsTest
    private static void chgName() {

        Test.startTest();
        String errorMessage = '';
        //System.runAs(testUser) {
            //try{
                
                String applicationDecision;
                String userType='client';
                String applicationType='chg-name-company';
                String applicationsettings;
                String reason='';
				//
				
				readObjectsId();
				TIDSReportChanges.accountHasChangeReportCase(String.ValueOf(accountId), applicationType);
            	applicationsettings ='{\"userType\":\"client\",\"applicationType\":\"chg-name-company\",\"userInfo\":{\"tidsAccount\":{\"Location_Type\":\"HO\",\"Id\":\"@accountId\"}},\"businessRules\":{\"Name\":\"TIDS\",\"Id\":\"@accountId\",\"TIDS_Total_Ownership_Minimum\":\"95\",\"TIDS_Total_Ownership_Maximum\":\"101\"},\"tidsCase\":{\"Id\":\"@caseId\"},\"sections\":{\"Welcome\":{\"sectionName\":\"Welcome\",\"cmpName\":\"new-applicant\",\"values\":{\"companyLegalName\":\"Bottas Racing Inc.\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"AgencyLegalStatus\":{\"sectionName\":\"Agency Legal Status\",\"cmpName\":\"agency-legal-status\",\"values\":{\"tradingName\":\"Bottas Wins Barcelona\",\"companyType\":\"L\",\"taxIdVATNumber1\":\"GST/1456784\",\"taxIdVATNumber2\":\"QST/96314-993\",\"businessRegistration\":\"123\",\"inOperationsSince\":\"2014-08-01\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"ShareholderDetails\":{\"sectionName\":\"Ownership Details\",\"cmpName\":\"shareholder-details\",\"values\":[{\"percentage\":\"90\",\"type\":\"Company\",\"name\":\"Bottas Limited Partnership\",\"email\":\"bottas@tids.iata.org\",\"id\":\"@accountId\"},{\"percentage\":\"10\",\"type\":\"Person\",\"name\":\"Bottas Family\",\"email\":\"bottasfamily@tids.iata.org\",\"id\":\"@accountId\"}],\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Address\":{},\"Mailing\":{},\"Contact\":{},\"BusinessProfile\":{},\"BusinessSpecialization\":{},\"SupportingDocuments\":{\"sectionName\":\"Supporting Documents\",\"cmpName\":\"supporting-documents\",\"values\":[],\"sectionDecision\":\"Not_Started\",\"errors\":[]}},\"sectionsDone\":[{\"id\":0,\"sectionName\":\"new-applicant\",\"next\":\"agency-legal-status\"},{\"id\":1,\"sectionName\":\"agency-legal-status\",\"next\":\"shareholder-details\"},{\"id\":2,\"sectionName\":\"shareholder-details\",\"next\":\"supporting-documents\"},{\"id\":3,\"sectionName\":\"supporting-documents\",\"next\":\"submit-application\"}]}';  
				applicationsettings=applicationReplace(applicationsettings);
				caseId = TIDSHelper.saveSettings(
                                    accountId,
                                    applicationsettings,
                                    applicationtype,
                                    null);
				applicationsettings=applicationReplace(applicationsettings);
				TIDS_Controller.applicationSubmitted(caseId, applicationsettings,applicationType );
				//Vetting Approved
				Case mycase = [Select Id, ContactId,Status From Case Where Id=:caseId limit 1];
                mycase.ContactId= contactId;
                update mycase;
				userType='vetting';
				applicationDecision='Approved';
				applicationsettings ='{\"applicationDecision\":\"Application_Approved\",\"userType\":\"vetting\",\"applicationType\":\"chg-name-company\",\"userInfo\":{\"tidsAccount\":{\"Location_Type\":\"HO\",\"Id\":\"@accountId\"}},\"businessRules\":{\"Name\":\"TIDS\",\"Id\":\"@accountId\",\"TIDS_Total_Ownership_Minimum\":\"95\",\"TIDS_Total_Ownership_Maximum\":\"101\"},\"tidsCase\":{\"Id\":\"@caseId\"},\"sections\":{\"Welcome\":{\"sectionName\":\"Welcome\",\"cmpName\":\"new-applicant\",\"values\":{\"companyLegalName\":\"Bottas Racing Inc.\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"AgencyLegalStatus\":{\"sectionName\":\"Agency Legal Status\",\"cmpName\":\"agency-legal-status\",\"values\":{\"tradingName\":\"Bottas Wins Barcelona\",\"companyType\":\"L\",\"taxIdVATNumber1\":\"GST/1456784\",\"taxIdVATNumber2\":\"QST/96314-993\",\"businessRegistration\":\"123\",\"inOperationsSince\":\"2014-08-01\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"ShareholderDetails\":{\"sectionName\":\"Ownership Details\",\"cmpName\":\"shareholder-details\",\"values\":[{\"percentage\":\"90\",\"type\":\"Company\",\"name\":\"Bottas Limited Partnership\",\"email\":\"bottas@tids.iata.org\",\"id\":\"@accountId\"},{\"percentage\":\"10\",\"type\":\"Person\",\"name\":\"Bottas Family\",\"email\":\"bottasfamily@tids.iata.org\",\"id\":\"@accountId\"}],\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Address\":{},\"Mailing\":{},\"Contact\":{},\"BusinessProfile\":{},\"BusinessSpecialization\":{},\"SupportingDocuments\":{\"sectionName\":\"Supporting Documents\",\"cmpName\":\"supporting-documents\",\"values\":[],\"sectionDecision\":\"Not_Started\",\"errors\":[]}},\"sectionsDone\":[{\"id\":0,\"sectionName\":\"new-applicant\",\"next\":\"agency-legal-status\"},{\"id\":1,\"sectionName\":\"agency-legal-status\",\"next\":\"shareholder-details\"},{\"id\":2,\"sectionName\":\"shareholder-details\",\"next\":\"supporting-documents\"},{\"id\":3,\"sectionName\":\"supporting-documents\",\"next\":\"submit-application\"}]}';  
				applicationsettings=applicationReplace(applicationsettings);
				reason='Last TIDS Application has been Approved and this case is now Closed';
				TIDS_Controller.updateCaseStatus(
					applicationDecision,
					userType,
					applicationType,
					String.ValueOf(caseId),
					applicationsettings,
					reason);

				TIDSReportChanges.getNameCompanyDetails(String.ValueOf(accountId), true);
            	TIDSReportChanges.getNameCompanyDetails(String.ValueOf(accountId), false);
            //}catch(Exception e) {
            //	errorMessage = e.getMessage();
            //	System.debug('error message:: ' + errorMessage);
            //}
        //}
        Test.stopTest();
        //System.assertEquals(true, errorMessage.contains(System.Label.GADM_account_contact_role_gadm_user), 'Inserting duplicate should not be allowed!');
	}
	@IsTest
    private static void chgContact() {

        Test.startTest();
        String errorMessage = '';
        //System.runAs(testUser) {
            //try{
                
                String applicationDecision;
                String userType='client';
                String applicationType='chg-address-contact';
                String applicationsettings;
                String reason='';
                //
                readObjectsId();
            	applicationsettings ='{\"userType\":\"client\",\"applicationType\":\"chg-address-contact\",\"userInfo\":{\"tidsAccount\":{\"Location_Type\":\"HO\",\"Id\":\"@accountId\"}},\"businessRules\":{\"Name\":\"TIDS\",\"Id\":\"@accountId\",\"TIDS_Total_Ownership_Minimum\":\"95\",\"TIDS_Total_Ownership_Maximum\":\"101\"},\"tidsCase\":{\"Id\":\"@caseId\"},\"sections\":{\"Welcome\":{\"cmpName\":\"new-applicant\",\"target\":\"NA\",\"values\":{\"companyLegalName\":\"Bottas Racing Inc.\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"NA\",\"vettingErrors\":[]},\"AgencyLegalStatus\":{},\"ShareholderDetails\":{},\"Address\":{\"sectionName\":\"Address\",\"cmpName\":\"address\",\"values\":{\"address\":\"15 Rue Papineau East\",\"city\":\"Montréal\",\"citygeonameId\":\"@cityId\",\"state\":{\"Id\":\"@stateId\",\"label\":\"Quebec\",\"value\":\"CA-QC\"},\"postalCode\":\"H2V4T8\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Mailing\":{\"sectionName\":\"Mailing\",\"cmpName\":\"mailing\",\"values\":{\"isMailingSameAsPhysicalAddress\":\"false\",\"mailingAddress\":\"33 Expedia Avenue\",\"city\":\"Seattle\",\"citygeonameId\":\"@cityId\",\"state\":{\"Id\":\"@stateId\",\"label\":\"Washington\",\"value\":\"US-WA\"},\"postalCode\":\"98888\",\"countryName\":\"United States\",\"countryIsoCode\":\"US\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Contact\":{\"sectionName\":\"Contact\",\"cmpName\":\"contact\",\"values\":{\"preferedLanguage\":\"ENG\",\"phone\":\"15148740202\",\"fax\":\"999888666\",\"businessEmail\":\"lorem@ipsum.com\",\"webSite\":\"www.loremipsum.com\",\"omFirstName\":\"Lorem\",\"omLastName\":\"Ipsum\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"BusinessProfile\":{},\"BusinessSpecialization\":{},\"SupportingDocuments\":{}},\"sectionsDone\":[{\"id\":0,\"sectionName\":\"address\",\"next\":\"mailing\"},{\"id\":1,\"sectionName\":\"mailing\",\"next\":\"contact\"},{\"id\":2,\"sectionName\":\"contact\",\"next\":\"submit-application\"}]}';
				applicationsettings=applicationReplace(applicationsettings);
				caseId = TIDSHelper.saveSettings(
                                    accountId,
                                    applicationsettings,
                                    applicationtype,
                                    null);
				applicationsettings=applicationReplace(applicationsettings);
				TIDS_Controller.applicationSubmitted(caseId, applicationsettings,applicationType );
				//Vetting Approved
				Case mycase = [Select Id, ContactId,Status From Case Where Id=:caseId limit 1];
                mycase.ContactId= contactId;
                update mycase;
				userType='vetting';
				applicationDecision='Approved';
				applicationsettings ='{\"applicationDecision\":\"Application_Approved\",\"userType\":\"vetting\",\"applicationType\":\"chg-address-contact\",\"userInfo\":{\"tidsAccount\":{\"Location_Type\":\"HO\",\"Id\":\"@accountId\"}},\"businessRules\":{\"Name\":\"TIDS\",\"Id\":\"@accountId\",\"TIDS_Total_Ownership_Minimum\":\"95\",\"TIDS_Total_Ownership_Maximum\":\"101\"},\"tidsCase\":{\"Id\":\"@caseId\"},\"sections\":{\"Welcome\":{\"cmpName\":\"new-applicant\",\"target\":\"NA\",\"values\":{\"companyLegalName\":\"Bottas Racing Inc.\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"NA\",\"vettingErrors\":[]},\"AgencyLegalStatus\":{},\"ShareholderDetails\":{},\"Address\":{\"sectionName\":\"Address\",\"cmpName\":\"address\",\"values\":{\"address\":\"15 Rue Papineau East\",\"city\":\"Montréal\",\"citygeonameId\":\"@cityId\",\"state\":{\"Id\":\"@stateId\",\"label\":\"Quebec\",\"value\":\"CA-QC\"},\"postalCode\":\"H2V4T8\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Mailing\":{\"sectionName\":\"Mailing\",\"cmpName\":\"mailing\",\"values\":{\"isMailingSameAsPhysicalAddress\":\"false\",\"mailingAddress\":\"33 Expedia Avenue\",\"city\":\"Seattle\",\"citygeonameId\":\"@cityId\",\"state\":{\"Id\":\"@stateId\",\"label\":\"Washington\",\"value\":\"US-WA\"},\"postalCode\":\"98888\",\"countryName\":\"United States\",\"countryIsoCode\":\"US\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Contact\":{\"sectionName\":\"Contact\",\"cmpName\":\"contact\",\"values\":{\"preferedLanguage\":\"ENG\",\"phone\":\"15148740202\",\"fax\":\"999888666\",\"businessEmail\":\"lorem@ipsum.com\",\"webSite\":\"www.loremipsum.com\",\"omFirstName\":\"Lorem\",\"omLastName\":\"Ipsum\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"BusinessProfile\":{},\"BusinessSpecialization\":{},\"SupportingDocuments\":{}},\"sectionsDone\":[{\"id\":0,\"sectionName\":\"address\",\"next\":\"mailing\"},{\"id\":1,\"sectionName\":\"mailing\",\"next\":\"contact\"},{\"id\":2,\"sectionName\":\"contact\",\"next\":\"submit-application\"}]}';
				applicationsettings=applicationReplace(applicationsettings);
				reason='Last TIDS Application has been Approved and this case is now Closed';
				TIDS_Controller.updateCaseStatus(
					applicationDecision,
					userType,
					applicationType,
					String.ValueOf(caseId),
					applicationsettings,
					reason);

				TIDSReportChanges.getAddressContactDetails(String.ValueOf(accountId));
			
            //}catch(Exception e) {
            //	errorMessage = e.getMessage();
            //	System.debug('error message:: ' + errorMessage);
            //}
        //}
        Test.stopTest();
        //System.assertEquals(true, errorMessage.contains(System.Label.GADM_account_contact_role_gadm_user), 'Inserting duplicate should not be allowed!');
    }
    @IsTest
    private static void saveandVettingHOApproved() {

        Test.startTest();
        String errorMessage = '';
        //System.runAs(testUser) {
            //try{
                
                String applicationDecision;
                String userType='client';
                String applicationType='NEW_HO';
                String applicationsettings;
                String reason='';
				//
				
				readObjectsId();
                applicationsettings ='{\"userType\":\"client\",\"applicationType\":\"NEW_HO\",\"userInfo\":{\"UserName\":\"PRIMARY USE FOR TIDS COND TEST\",\"UserId\":\"@userId\",\"ContactId\":\"@contatId\",\"tidsAccount\":{\"Id\":\"@accountId\",\"Country_ISO_Code\":\"CA\",\"RecordType\":{\"Name\":\"Standard Account\",\"Id\":\"@accountId\"}}},\"businessRules\":{\"Name\":\"TIDS\",\"Id\":\"a2w4E000000DaNDQA0\",\"TIDS_Total_Ownership_Minimum\":\"95\",\"TIDS_Total_Ownership_Maximum\":\"101\"},\"tidsCase\":{\"Id\":\"@caseId\"},\"sections\":{\"Welcome\":{\"sectionName\":\"Welcome\",\"cmpName\":\"new-applicant\",\"values\":{\"companyLegalName\":\"New HO Application - For Test Classes\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"AgencyLegalStatus\":{\"sectionName\":\"Agency Legal Status\",\"cmpName\":\"agency-legal-status\",\"values\":{\"tradingName\":\"Test Classes Application\",\"companyType\":\"C\",\"taxIdVATNumber1\":\"123456\",\"taxIdVATNumber2\":\"987654\",\"businessRegistration\":\"852963\",\"inOperationsSince\":\"2020-05-04\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"ShareholderDetails\":{\"sectionName\":\"Ownership Details\",\"cmpName\":\"shareholder-details\",\"values\":[{\"percentage\":\"50\",\"name\":\"Test\",\"email\":\"test@testclasses.com\",\"type\":\"Person\",\"id\":\"efba\"},{\"percentage\":\"50\",\"type\":\"Company\",\"name\":\"Class\",\"email\":\"class@testclasses.com\",\"id\":\"c6ab\"}],\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Address\":{\"sectionName\":\"Address\",\"cmpName\":\"address\",\"values\":{\"address\":\"10 Test Class Street\",\"city\":\"Laval\",\"citygeonameId\":6050610,\"state\":{\"Id\":\"@stateId\",\"label\":\"Quebec\",\"value\":\"CA-QC\"},\"postalCode\":\"H1H2H3\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Mailing\":{\"sectionName\":\"Mailing\",\"cmpName\":\"mailing\",\"values\":{\"isMailingSameAsPhysicalAddress\":\"false\",\"mailingAddress\":\"10 Mailing Street\",\"city\":\"Seattle\",\"citygeonameId\":5809844,\"state\":{\"Id\":\"@stateId\",\"label\":\"Washington\",\"value\":\"US-WA\"},\"postalCode\":\"98162\",\"countryName\":\"United States\",\"countryIsoCode\":\"US\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Contact\":{\"sectionName\":\"Contact\",\"cmpName\":\"contact\",\"values\":{\"preferedLanguage\":\"ENG\",\"phone\":\"15148740202\",\"fax\":\"15148743636\",\"businessEmail\":\"debonol@iata.org\",\"webSite\":\"www.testclasses.com\",\"omFirstName\":\"Test\",\"omLastName\":\"Classes\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"BusinessProfile\":{\"sectionName\":\"Business Profile\",\"cmpName\":\"business-profile\",\"values\":{\"principalActivities\":{\"fieldName\":\"principalActivities\",\"values\":[{\"label\":\"Online Travel Agency\",\"value\":\"OL\"}]},\"marketFocus\":{\"fieldName\":\"marketFocus\",\"values\":[{\"label\":\"Leisure\",\"value\":\"67\"},{\"label\":\"Corporate\",\"value\":\"33\"}]},\"salesMix\":{\"fieldName\":\"salesMix\",\"values\":[{\"label\":\"Online\",\"value\":\"39\"},{\"label\":\"Offline\",\"value\":\"61\"}]},\"travelSales\":{\"fieldName\":\"travelSales\",\"values\":\"3\"},\"GDS\":{\"fieldName\":\"GDS\",\"values\":[{\"label\":\"Farelogix\",\"value\":\"FLGX\"},{\"label\":\"Travelsky\",\"value\":\"MINS\"}]},\"numberEmployees\":{\"fieldName\":\"numberEmployees\",\"values\":\"2\"},\"numberOffices\":{\"fieldName\":\"numberOffices\",\"values\":\"8\"}},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"BusinessSpecialization\":{\"sectionName\":\"Business Specialization\",\"cmpName\":\"business-specialization\",\"values\":{\"percentageBreakdown\":{\"fieldName\":\"percentageBreakdown\",\"values\":[{\"id\":null,\"label\":\"Accommodation\",\"value\":\"12\",\"isSelected\":\"false\"},{\"id\":\"1\",\"label\":\"Air Travel\",\"value\":\"18\",\"isSelected\":\"false\"},{\"id\":\"2\",\"label\":\"Cruises\",\"value\":\"33\",\"isSelected\":\"false\"},{\"id\":\"3\",\"label\":\"Land Transportation\",\"value\":\"13\",\"isSelected\":\"false\"},{\"id\":\"4\",\"label\":\"Meetings & Events\",\"value\":\"14\",\"isSelected\":\"false\"},{\"id\":\"5\",\"label\":\"Tours & Packages\",\"value\":\"10\",\"isSelected\":\"false\"}]},\"marketSpecialties\":{\"fieldName\":\"marketSpecialties\",\"values\":[{\"label\":\"Inbound\",\"value\":\"IB\"},{\"label\":\"Adventure\",\"value\":\"AD\"},{\"label\":\"Conference/Exhibitions\",\"value\":\"CF\"}]},\"destinationSpecialties\":{\"fieldName\":\"destinationSpecialties\",\"values\":[{\"label\":\"France\",\"value\":\"FR\"},{\"label\":\"General\",\"value\":\"AL\"},{\"label\":\"Mexico\",\"value\":\"MX\"}]}},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"SupportingDocuments\":{\"sectionName\":\"Supporting Documents\",\"cmpName\":\"supporting-documents\",\"values\":[],\"sectionDecision\":\"Not_Started\",\"errors\":[]}},\"sectionsDone\":[{\"id\":0,\"sectionName\":\"new-applicant\",\"next\":\"agency-legal-status\"},{\"id\":1,\"sectionName\":\"agency-legal-status\",\"next\":\"shareholder-details\"},{\"id\":2,\"sectionName\":\"shareholder-details\",\"next\":\"address\"},{\"id\":3,\"sectionName\":\"address\",\"next\":\"mailing\"},{\"id\":4,\"sectionName\":\"mailing\",\"next\":\"contact\"},{\"id\":5,\"sectionName\":\"contact\",\"next\":\"business-profile\"},{\"id\":6,\"sectionName\":\"business-profile\",\"next\":\"business-specialization\"},{\"id\":7,\"sectionName\":\"business-specialization\",\"next\":\"supporting-documents\"},{\"id\":8,\"sectionName\":\"supporting-documents\",\"next\":\"submit-application\"}]}';
                caseId = TIDSHelper.saveSettings(
                                    accountId,
                                    applicationsettings,
                                    applicationtype,
                                    null);
                TIDSHelper.getUserInfo(userId);
                //Submit applicationsettings only if (appType === 'chg-business-profile-specialization')
                applicationsettings='';
                TIDS_Controller.applicationSubmitted(
                    caseId,
                    applicationsettings, 
                    applicationType);
                
        
            //}catch(Exception e) {
            //	errorMessage = e.getMessage();
            //	System.debug('error message:: ' + errorMessage);
            //}
        //}
        Test.stopTest();
        //System.assertEquals(true, errorMessage.contains(System.Label.GADM_account_contact_role_gadm_user), 'Inserting duplicate should not be allowed!');
	}
	@IsTest
    private static void saveandVettingHOSubmited() {

        Test.startTest();
        String errorMessage = '';
        //System.runAs(testUser) {
            //try{
                
                String applicationDecision;
                String userType='client';
                String applicationType='NEW_HO';
                String applicationsettings;
                String reason='';
				//
				
				readObjectsId();
                applicationsettings ='{\"userType\":\"client\",\"applicationType\":\"NEW_HO\",\"userInfo\":{\"UserName\":\"PRIMARY USE FOR TIDS COND TEST\",\"UserId\":\"@userId\",\"ContactId\":\"@contatId\",\"tidsAccount\":{\"Id\":\"@accountId\",\"Country_ISO_Code\":\"CA\",\"RecordType\":{\"Name\":\"Standard Account\",\"Id\":\"@accountId\"}}},\"businessRules\":{\"Name\":\"TIDS\",\"Id\":\"a2w4E000000DaNDQA0\",\"TIDS_Total_Ownership_Minimum\":\"95\",\"TIDS_Total_Ownership_Maximum\":\"101\"},\"tidsCase\":{\"Id\":\"@caseId\"},\"sections\":{\"Welcome\":{\"sectionName\":\"Welcome\",\"cmpName\":\"new-applicant\",\"values\":{\"companyLegalName\":\"New HO Application - For Test Classes\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"AgencyLegalStatus\":{\"sectionName\":\"Agency Legal Status\",\"cmpName\":\"agency-legal-status\",\"values\":{\"tradingName\":\"Test Classes Application\",\"companyType\":\"C\",\"taxIdVATNumber1\":\"123456\",\"taxIdVATNumber2\":\"987654\",\"businessRegistration\":\"852963\",\"inOperationsSince\":\"2020-05-04\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"ShareholderDetails\":{\"sectionName\":\"Ownership Details\",\"cmpName\":\"shareholder-details\",\"values\":[{\"percentage\":\"50\",\"name\":\"Test\",\"email\":\"test@testclasses.com\",\"type\":\"Person\",\"id\":\"efba\"},{\"percentage\":\"50\",\"type\":\"Company\",\"name\":\"Class\",\"email\":\"class@testclasses.com\",\"id\":\"c6ab\"}],\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Address\":{\"sectionName\":\"Address\",\"cmpName\":\"address\",\"values\":{\"address\":\"10 Test Class Street\",\"city\":\"Laval\",\"citygeonameId\":6050610,\"state\":{\"Id\":\"@stateId\",\"label\":\"Quebec\",\"value\":\"CA-QC\"},\"postalCode\":\"H1H2H3\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Mailing\":{\"sectionName\":\"Mailing\",\"cmpName\":\"mailing\",\"values\":{\"isMailingSameAsPhysicalAddress\":\"false\",\"mailingAddress\":\"10 Mailing Street\",\"city\":\"Seattle\",\"citygeonameId\":5809844,\"state\":{\"Id\":\"@stateId\",\"label\":\"Washington\",\"value\":\"US-WA\"},\"postalCode\":\"98162\",\"countryName\":\"United States\",\"countryIsoCode\":\"US\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Contact\":{\"sectionName\":\"Contact\",\"cmpName\":\"contact\",\"values\":{\"preferedLanguage\":\"ENG\",\"phone\":\"15148740202\",\"fax\":\"15148743636\",\"businessEmail\":\"debonol@iata.org\",\"webSite\":\"www.testclasses.com\",\"omFirstName\":\"Test\",\"omLastName\":\"Classes\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"BusinessProfile\":{\"sectionName\":\"Business Profile\",\"cmpName\":\"business-profile\",\"values\":{\"principalActivities\":{\"fieldName\":\"principalActivities\",\"values\":[{\"label\":\"Online Travel Agency\",\"value\":\"OL\"}]},\"marketFocus\":{\"fieldName\":\"marketFocus\",\"values\":[{\"label\":\"Leisure\",\"value\":\"67\"},{\"label\":\"Corporate\",\"value\":\"33\"}]},\"salesMix\":{\"fieldName\":\"salesMix\",\"values\":[{\"label\":\"Online\",\"value\":\"39\"},{\"label\":\"Offline\",\"value\":\"61\"}]},\"travelSales\":{\"fieldName\":\"travelSales\",\"values\":\"3\"},\"GDS\":{\"fieldName\":\"GDS\",\"values\":[{\"label\":\"Farelogix\",\"value\":\"FLGX\"},{\"label\":\"Travelsky\",\"value\":\"MINS\"}]},\"numberEmployees\":{\"fieldName\":\"numberEmployees\",\"values\":\"2\"},\"numberOffices\":{\"fieldName\":\"numberOffices\",\"values\":\"8\"}},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"BusinessSpecialization\":{\"sectionName\":\"Business Specialization\",\"cmpName\":\"business-specialization\",\"values\":{\"percentageBreakdown\":{\"fieldName\":\"percentageBreakdown\",\"values\":[{\"id\":null,\"label\":\"Accommodation\",\"value\":\"12\",\"isSelected\":\"false\"},{\"id\":\"1\",\"label\":\"Air Travel\",\"value\":\"18\",\"isSelected\":\"false\"},{\"id\":\"2\",\"label\":\"Cruises\",\"value\":\"33\",\"isSelected\":\"false\"},{\"id\":\"3\",\"label\":\"Land Transportation\",\"value\":\"13\",\"isSelected\":\"false\"},{\"id\":\"4\",\"label\":\"Meetings & Events\",\"value\":\"14\",\"isSelected\":\"false\"},{\"id\":\"5\",\"label\":\"Tours & Packages\",\"value\":\"10\",\"isSelected\":\"false\"}]},\"marketSpecialties\":{\"fieldName\":\"marketSpecialties\",\"values\":[{\"label\":\"Inbound\",\"value\":\"IB\"},{\"label\":\"Adventure\",\"value\":\"AD\"},{\"label\":\"Conference/Exhibitions\",\"value\":\"CF\"}]},\"destinationSpecialties\":{\"fieldName\":\"destinationSpecialties\",\"values\":[{\"label\":\"France\",\"value\":\"FR\"},{\"label\":\"General\",\"value\":\"AL\"},{\"label\":\"Mexico\",\"value\":\"MX\"}]}},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"SupportingDocuments\":{\"sectionName\":\"Supporting Documents\",\"cmpName\":\"supporting-documents\",\"values\":[],\"sectionDecision\":\"Not_Started\",\"errors\":[]}},\"sectionsDone\":[{\"id\":0,\"sectionName\":\"new-applicant\",\"next\":\"agency-legal-status\"},{\"id\":1,\"sectionName\":\"agency-legal-status\",\"next\":\"shareholder-details\"},{\"id\":2,\"sectionName\":\"shareholder-details\",\"next\":\"address\"},{\"id\":3,\"sectionName\":\"address\",\"next\":\"mailing\"},{\"id\":4,\"sectionName\":\"mailing\",\"next\":\"contact\"},{\"id\":5,\"sectionName\":\"contact\",\"next\":\"business-profile\"},{\"id\":6,\"sectionName\":\"business-profile\",\"next\":\"business-specialization\"},{\"id\":7,\"sectionName\":\"business-specialization\",\"next\":\"supporting-documents\"},{\"id\":8,\"sectionName\":\"supporting-documents\",\"next\":\"submit-application\"}]}';
                caseId = TIDSHelper.saveSettings(
                                    accountId,
                                    applicationsettings,
                                    applicationtype,
                                    null);
                
                Case mycase = [Select Id, ContactId,Status From Case Where Id=:caseId limit 1];
                mycase.ContactId= contactId;
                update mycase;
                //Return to drat for the case
                 //mycase.Status='Draft';
                //update mycase;
                //Vetting Approved
                applicationDecision='Approved';
                applicationsettings='{\"applicationDecision\":\"Application_Approved\",\"userType\":\"vetting\",\"applicationType\":\"NEW_HO\",\"userInfo\":{\"UserName\":\"Abdellah Abdellah Bellahssan\",\"UserId\":\"@userId\",\"ContactId\":\"@contactId\",\"tidsAccount\":{\"Id\":\"@accountId\",\"Country_ISO_Code\":\"CA\",\"RecordType\":{\"Name\":null,\"Id\":null}}},\"businessRules\":{\"Name\":\"TIDS\",\"Id\":\"a2w4E000000DaNDQA0\",\"TIDS_Total_Ownership_Minimum\":\"95\",\"TIDS_Total_Ownership_Maximum\":\"101\"},\"tidsCase\":{\"Id\":\"@caseId\"},\"sections\":{\"Welcome\":{\"sectionName\":\"Welcome\",\"cmpName\":\"new-applicant\",\"values\":{\"companyLegalName\":\"New HO Application - For Test Classes\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Section_Confirmed\",\"errors\":[]},\"AgencyLegalStatus\":{\"sectionName\":\"Agency Legal Status\",\"cmpName\":\"agency-legal-status\",\"values\":{\"tradingName\":\"Test Classes Application\",\"companyType\":\"C\",\"taxIdVATNumber1\":\"123456\",\"taxIdVATNumber2\":\"987654\",\"businessRegistration\":\"852963\",\"inOperationsSince\":\"2020-05-04\"},\"sectionDecision\":\"Section_Confirmed\",\"errors\":[]},\"ShareholderDetails\":{\"sectionName\":\"Ownership Details\",\"cmpName\":\"shareholder-details\",\"values\":[{\"percentage\":\"50\",\"name\":\"Test\",\"email\":\"test@testclasses.com\",\"type\":\"Person\",\"id\":\"efba\"},{\"percentage\":\"50\",\"type\":\"Company\",\"name\":\"Class\",\"email\":\"class@testclasses.com\",\"id\":\"c6ab\"}],\"sectionDecision\":\"Section_Confirmed\",\"errors\":[]},\"Address\":{\"sectionName\":\"Address\",\"cmpName\":\"address\",\"values\":{\"address\":\"10 Test Class Street\",\"city\":\"Laval\",\"citygeonameId\":6050610,\"state\":{\"Id\":\"@stateId\",\"label\":\"Quebec\",\"value\":\"CA-QC\"},\"postalCode\":\"H1H2H3\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Section_Confirmed\",\"errors\":[]},\"Mailing\":{\"sectionName\":\"Mailing\",\"cmpName\":\"mailing\",\"values\":{\"isMailingSameAsPhysicalAddress\":\"false\",\"mailingAddress\":\"10 Mailing Street\",\"city\":\"Seattle\",\"citygeonameId\":5809844,\"state\":{\"Id\":\"@stateId\",\"label\":\"Washington\",\"value\":\"US-WA\"},\"postalCode\":\"98162\",\"countryName\":\"United States\",\"countryIsoCode\":\"US\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Section_Confirmed\",\"errors\":[]},\"Contact\":{\"sectionName\":\"Contact\",\"cmpName\":\"contact\",\"values\":{\"preferedLanguage\":\"ENG\",\"phone\":\"15148740202\",\"fax\":\"15148743636\",\"businessEmail\":\"debonol@iata.org\",\"webSite\":\"www.testclasses.com\",\"omFirstName\":\"Test\",\"omLastName\":\"Classes\"},\"sectionDecision\":\"Section_Confirmed\",\"errors\":[]},\"BusinessProfile\":{\"sectionName\":\"Business Profile\",\"cmpName\":\"business-profile\",\"values\":{\"principalActivities\":{\"fieldName\":\"principalActivities\",\"values\":[{\"label\":\"Online Travel Agency\",\"value\":\"OL\"}]},\"marketFocus\":{\"fieldName\":\"marketFocus\",\"values\":[{\"label\":\"Leisure\",\"value\":\"67\"},{\"label\":\"Corporate\",\"value\":\"33\"}]},\"salesMix\":{\"fieldName\":\"salesMix\",\"values\":[{\"label\":\"Online\",\"value\":\"39\"},{\"label\":\"Offline\",\"value\":\"61\"}]},\"travelSales\":{\"fieldName\":\"travelSales\",\"values\":\"3\"},\"GDS\":{\"fieldName\":\"GDS\",\"values\":[{\"label\":\"Farelogix\",\"value\":\"FLGX\"},{\"label\":\"Travelsky\",\"value\":\"MINS\"}]},\"numberEmployees\":{\"fieldName\":\"numberEmployees\",\"values\":\"2\"},\"numberOffices\":{\"fieldName\":\"numberOffices\",\"values\":\"8\"}},\"sectionDecision\":\"Section_Confirmed\",\"errors\":[]},\"BusinessSpecialization\":{\"sectionName\":\"Business Specialization\",\"cmpName\":\"business-specialization\",\"values\":{\"percentageBreakdown\":{\"fieldName\":\"percentageBreakdown\",\"values\":[{\"id\":null,\"label\":\"Accommodation\",\"value\":\"12\",\"isSelected\":\"false\"},{\"id\":\"1\",\"label\":\"Air Travel\",\"value\":\"18\",\"isSelected\":\"false\"},{\"id\":\"2\",\"label\":\"Cruises\",\"value\":\"33\",\"isSelected\":\"false\"},{\"id\":\"3\",\"label\":\"Land Transportation\",\"value\":\"13\",\"isSelected\":\"false\"},{\"id\":\"4\",\"label\":\"Meetings & Events\",\"value\":\"14\",\"isSelected\":\"false\"},{\"id\":\"5\",\"label\":\"Tours & Packages\",\"value\":\"10\",\"isSelected\":\"false\"}]},\"marketSpecialties\":{\"fieldName\":\"marketSpecialties\",\"values\":[{\"label\":\"Inbound\",\"value\":\"IB\"},{\"label\":\"Adventure\",\"value\":\"AD\"},{\"label\":\"Conference/Exhibitions\",\"value\":\"CF\"}]},\"destinationSpecialties\":{\"fieldName\":\"destinationSpecialties\",\"values\":[{\"label\":\"France\",\"value\":\"FR\"},{\"label\":\"General\",\"value\":\"AL\"},{\"label\":\"Mexico\",\"value\":\"MX\"}]}},\"sectionDecision\":\"Section_Confirmed\",\"errors\":[]},\"SupportingDocuments\":{\"sectionName\":\"Supporting Documents\",\"cmpName\":\"supporting-documents\",\"values\":[],\"sectionDecision\":\"Section_Confirmed\",\"errors\":[]}},\"sectionsDone\":[{\"id\":0,\"sectionName\":\"new-applicant\",\"next\":\"agency-legal-status\"},{\"id\":1,\"sectionName\":\"agency-legal-status\",\"next\":\"shareholder-details\"},{\"id\":2,\"sectionName\":\"shareholder-details\",\"next\":\"address\"},{\"id\":3,\"sectionName\":\"address\",\"next\":\"mailing\"},{\"id\":4,\"sectionName\":\"mailing\",\"next\":\"contact\"},{\"id\":5,\"sectionName\":\"contact\",\"next\":\"business-profile\"},{\"id\":6,\"sectionName\":\"business-profile\",\"next\":\"business-specialization\"},{\"id\":7,\"sectionName\":\"business-specialization\",\"next\":\"supporting-documents\"},{\"id\":8,\"sectionName\":\"supporting-documents\",\"next\":\"submit-application\"}]}';
                applicationsettings=applicationReplace(applicationsettings);
                reason='Last TIDS Application has been Approved and this case is now Closed';
                TIDS_Controller.updateCaseStatus(
                    applicationDecision,
                    userType,
                    applicationType,
                    String.ValueOf(caseId),
                    applicationsettings,
                    reason);
                
                
        
            //}catch(Exception e) {
            //	errorMessage = e.getMessage();
            //	System.debug('error message:: ' + errorMessage);
            //}
        //}
        Test.stopTest();
        //System.assertEquals(true, errorMessage.contains(System.Label.GADM_account_contact_role_gadm_user), 'Inserting duplicate should not be allowed!');
    }
    @IsTest
    private static void saveandVettingHO2Rejected() {

        Test.startTest();
        String errorMessage = '';
        //System.runAs(testUser) {
            //try{
                String applicationDecision;
                String userType='client';
                String applicationType='NEW_HO';
                String applicationsettings;
                String reason='';
                //
                readObjectsId();
                applicationsettings ='{\"userType\":\"client\",\"applicationType\":\"NEW_HO\",\"userInfo\":{\"UserName\":\"PRIMARY USE FOR TIDS COND TEST\",\"UserId\":\"@userId\",\"ContactId\":\"@contatId\",\"tidsAccount\":{\"Id\":\"@accountId\",\"Country_ISO_Code\":\"CA\",\"RecordType\":{\"Name\":\"Standard Account\",\"Id\":\"@accountId\"}}},\"businessRules\":{\"Name\":\"TIDS\",\"Id\":\"a2w4E000000DaNDQA0\",\"TIDS_Total_Ownership_Minimum\":\"95\",\"TIDS_Total_Ownership_Maximum\":\"101\"},\"tidsCase\":{\"Id\":\"@caseId\"},\"sections\":{\"Welcome\":{\"sectionName\":\"Welcome\",\"cmpName\":\"new-applicant\",\"values\":{\"companyLegalName\":\"New HO Application - For Test Classes\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"AgencyLegalStatus\":{\"sectionName\":\"Agency Legal Status\",\"cmpName\":\"agency-legal-status\",\"values\":{\"tradingName\":\"Test Classes Application\",\"companyType\":\"C\",\"taxIdVATNumber1\":\"123456\",\"taxIdVATNumber2\":\"987654\",\"businessRegistration\":\"852963\",\"inOperationsSince\":\"2020-05-04\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"ShareholderDetails\":{\"sectionName\":\"Ownership Details\",\"cmpName\":\"shareholder-details\",\"values\":[{\"percentage\":\"50\",\"name\":\"Test\",\"email\":\"test@testclasses.com\",\"type\":\"Person\",\"id\":\"efba\"},{\"percentage\":\"50\",\"type\":\"Company\",\"name\":\"Class\",\"email\":\"class@testclasses.com\",\"id\":\"c6ab\"}],\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Address\":{\"sectionName\":\"Address\",\"cmpName\":\"address\",\"values\":{\"address\":\"10 Test Class Street\",\"city\":\"Laval\",\"citygeonameId\":6050610,\"state\":{\"Id\":\"@stateId\",\"label\":\"Quebec\",\"value\":\"CA-QC\"},\"postalCode\":\"H1H2H3\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Mailing\":{\"sectionName\":\"Mailing\",\"cmpName\":\"mailing\",\"values\":{\"isMailingSameAsPhysicalAddress\":\"false\",\"mailingAddress\":\"10 Mailing Street\",\"city\":\"Seattle\",\"citygeonameId\":5809844,\"state\":{\"Id\":\"@stateId\",\"label\":\"Washington\",\"value\":\"US-WA\"},\"postalCode\":\"98162\",\"countryName\":\"United States\",\"countryIsoCode\":\"US\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Contact\":{\"sectionName\":\"Contact\",\"cmpName\":\"contact\",\"values\":{\"preferedLanguage\":\"ENG\",\"phone\":\"15148740202\",\"fax\":\"15148743636\",\"businessEmail\":\"debonol@iata.org\",\"webSite\":\"www.testclasses.com\",\"omFirstName\":\"Test\",\"omLastName\":\"Classes\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"BusinessProfile\":{\"sectionName\":\"Business Profile\",\"cmpName\":\"business-profile\",\"values\":{\"principalActivities\":{\"fieldName\":\"principalActivities\",\"values\":[{\"label\":\"Online Travel Agency\",\"value\":\"OL\"}]},\"marketFocus\":{\"fieldName\":\"marketFocus\",\"values\":[{\"label\":\"Leisure\",\"value\":\"67\"},{\"label\":\"Corporate\",\"value\":\"33\"}]},\"salesMix\":{\"fieldName\":\"salesMix\",\"values\":[{\"label\":\"Online\",\"value\":\"39\"},{\"label\":\"Offline\",\"value\":\"61\"}]},\"travelSales\":{\"fieldName\":\"travelSales\",\"values\":\"3\"},\"GDS\":{\"fieldName\":\"GDS\",\"values\":[{\"label\":\"Farelogix\",\"value\":\"FLGX\"},{\"label\":\"Travelsky\",\"value\":\"MINS\"}]},\"numberEmployees\":{\"fieldName\":\"numberEmployees\",\"values\":\"2\"},\"numberOffices\":{\"fieldName\":\"numberOffices\",\"values\":\"8\"}},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"BusinessSpecialization\":{\"sectionName\":\"Business Specialization\",\"cmpName\":\"business-specialization\",\"values\":{\"percentageBreakdown\":{\"fieldName\":\"percentageBreakdown\",\"values\":[{\"id\":null,\"label\":\"Accommodation\",\"value\":\"12\",\"isSelected\":\"false\"},{\"id\":\"1\",\"label\":\"Air Travel\",\"value\":\"18\",\"isSelected\":\"false\"},{\"id\":\"2\",\"label\":\"Cruises\",\"value\":\"33\",\"isSelected\":\"false\"},{\"id\":\"3\",\"label\":\"Land Transportation\",\"value\":\"13\",\"isSelected\":\"false\"},{\"id\":\"4\",\"label\":\"Meetings & Events\",\"value\":\"14\",\"isSelected\":\"false\"},{\"id\":\"5\",\"label\":\"Tours & Packages\",\"value\":\"10\",\"isSelected\":\"false\"}]},\"marketSpecialties\":{\"fieldName\":\"marketSpecialties\",\"values\":[{\"label\":\"Inbound\",\"value\":\"IB\"},{\"label\":\"Adventure\",\"value\":\"AD\"},{\"label\":\"Conference/Exhibitions\",\"value\":\"CF\"}]},\"destinationSpecialties\":{\"fieldName\":\"destinationSpecialties\",\"values\":[{\"label\":\"France\",\"value\":\"FR\"},{\"label\":\"General\",\"value\":\"AL\"},{\"label\":\"Mexico\",\"value\":\"MX\"}]}},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"SupportingDocuments\":{\"sectionName\":\"Supporting Documents\",\"cmpName\":\"supporting-documents\",\"values\":[],\"sectionDecision\":\"Not_Started\",\"errors\":[]}},\"sectionsDone\":[{\"id\":0,\"sectionName\":\"new-applicant\",\"next\":\"agency-legal-status\"},{\"id\":1,\"sectionName\":\"agency-legal-status\",\"next\":\"shareholder-details\"},{\"id\":2,\"sectionName\":\"shareholder-details\",\"next\":\"address\"},{\"id\":3,\"sectionName\":\"address\",\"next\":\"mailing\"},{\"id\":4,\"sectionName\":\"mailing\",\"next\":\"contact\"},{\"id\":5,\"sectionName\":\"contact\",\"next\":\"business-profile\"},{\"id\":6,\"sectionName\":\"business-profile\",\"next\":\"business-specialization\"},{\"id\":7,\"sectionName\":\"business-specialization\",\"next\":\"supporting-documents\"},{\"id\":8,\"sectionName\":\"supporting-documents\",\"next\":\"submit-application\"}]}';
                caseId = TIDSHelper.saveSettings(
                                    accountId,
                                    applicationsettings,
                                    applicationtype,
                                    null);
                
                TIDSHelper.getUserInfo(userId);
                //Submit applicationsettings only if (appType === 'chg-business-profile-specialization')
                applicationsettings='';
                TIDS_Controller.applicationSubmitted(
                    caseId,
                    applicationsettings, 
                    applicationType);
                
                Case mycase = [Select Id, ContactId,Status From Case Where Id=:caseId limit 1];
                mycase.ContactId= contactId;
                update mycase;
                //Vetting Reject
                applicationDecision='Rejected';
                reason='Rejected By the test process';
                applicationsettings='"{\"applicationDecision\":\"Application_Rejected\",\"userType\":\"vetting\",\"applicationType\":\"NEW_HO\",\"userInfo\":{\"UserName\":\"Abdellah Abdellah Bellahssan\",\"UserId\":\"@userId\",\"ContactId\":\"@contactId\",\"tidsAccount\":{\"Id\":\"@accountId\",\"Country_ISO_Code\":\"CA\",\"RecordType\":{\"Name\":null,\"Id\":null}}},\"businessRules\":{\"Name\":\"TIDS\",\"Id\":\"a2w4E000000DaNDQA0\",\"TIDS_Total_Ownership_Minimum\":\"95\",\"TIDS_Total_Ownership_Maximum\":\"101\"},\"tidsCase\":{\"Id\":\"@caseId\"},\"sections\":{\"Welcome\":{\"sectionName\":\"Welcome\",\"cmpName\":\"new-applicant\",\"values\":{\"companyLegalName\":\"New HO Application - For Test Classes\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Section_Confirmed\",\"errors\":[]},\"AgencyLegalStatus\":{\"sectionName\":\"Agency Legal Status\",\"cmpName\":\"agency-legal-status\",\"values\":{\"tradingName\":\"Test Classes Application\",\"companyType\":\"C\",\"taxIdVATNumber1\":\"123456\",\"taxIdVATNumber2\":\"987654\",\"businessRegistration\":\"852963\",\"inOperationsSince\":\"2020-05-04\"},\"sectionDecision\":\"Section_Confirmed\",\"errors\":[]},\"ShareholderDetails\":{\"sectionName\":\"Ownership Details\",\"cmpName\":\"shareholder-details\",\"values\":[{\"percentage\":\"50\",\"name\":\"Test\",\"email\":\"test@testclasses.com\",\"type\":\"Person\",\"id\":\"efba\"},{\"percentage\":\"50\",\"type\":\"Company\",\"name\":\"Class\",\"email\":\"class@testclasses.com\",\"id\":\"c6ab\"}],\"sectionDecision\":\"Section_Confirmed\",\"errors\":[]},\"Address\":{\"sectionName\":\"Address\",\"cmpName\":\"address\",\"values\":{\"address\":\"10 Test Class Street\",\"city\":\"Laval\",\"citygeonameId\":6050610,\"state\":{\"Id\":\"@stateId\",\"label\":\"Quebec\",\"value\":\"CA-QC\"},\"postalCode\":\"H1H2H3\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Section_Confirmed\",\"errors\":[]},\"Mailing\":{\"sectionName\":\"Mailing\",\"cmpName\":\"mailing\",\"values\":{\"isMailingSameAsPhysicalAddress\":\"false\",\"mailingAddress\":\"10 Mailing Street\",\"city\":\"Seattle\",\"citygeonameId\":5809844,\"state\":{\"Id\":\"@stateId\",\"label\":\"Washington\",\"value\":\"US-WA\"},\"postalCode\":\"98162\",\"countryName\":\"United States\",\"countryIsoCode\":\"US\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Section_Confirmed\",\"errors\":[]},\"Contact\":{\"sectionName\":\"Contact\",\"cmpName\":\"contact\",\"values\":{\"preferedLanguage\":\"ENG\",\"phone\":\"15148740202\",\"fax\":\"15148743636\",\"businessEmail\":\"debonol@iata.org\",\"webSite\":\"www.testclasses.com\",\"omFirstName\":\"Test\",\"omLastName\":\"Classes\"},\"sectionDecision\":\"Section_Confirmed\",\"errors\":[]},\"BusinessProfile\":{\"sectionName\":\"Business Profile\",\"cmpName\":\"business-profile\",\"values\":{\"principalActivities\":{\"fieldName\":\"principalActivities\",\"values\":[{\"label\":\"Online Travel Agency\",\"value\":\"OL\"}]},\"marketFocus\":{\"fieldName\":\"marketFocus\",\"values\":[{\"label\":\"Leisure\",\"value\":\"67\"},{\"label\":\"Corporate\",\"value\":\"33\"}]},\"salesMix\":{\"fieldName\":\"salesMix\",\"values\":[{\"label\":\"Online\",\"value\":\"39\"},{\"label\":\"Offline\",\"value\":\"61\"}]},\"travelSales\":{\"fieldName\":\"travelSales\",\"values\":\"3\"},\"GDS\":{\"fieldName\":\"GDS\",\"values\":[{\"label\":\"Farelogix\",\"value\":\"FLGX\"},{\"label\":\"Travelsky\",\"value\":\"MINS\"}]},\"numberEmployees\":{\"fieldName\":\"numberEmployees\",\"values\":\"2\"},\"numberOffices\":{\"fieldName\":\"numberOffices\",\"values\":\"8\"}},\"sectionDecision\":\"Section_Confirmed\",\"errors\":[]},\"BusinessSpecialization\":{\"sectionName\":\"Business Specialization\",\"cmpName\":\"business-specialization\",\"values\":{\"percentageBreakdown\":{\"fieldName\":\"percentageBreakdown\",\"values\":[{\"id\":null,\"label\":\"Accommodation\",\"value\":\"12\",\"isSelected\":\"false\"},{\"id\":\"1\",\"label\":\"Air Travel\",\"value\":\"18\",\"isSelected\":\"false\"},{\"id\":\"2\",\"label\":\"Cruises\",\"value\":\"33\",\"isSelected\":\"false\"},{\"id\":\"3\",\"label\":\"Land Transportation\",\"value\":\"13\",\"isSelected\":\"false\"},{\"id\":\"4\",\"label\":\"Meetings & Events\",\"value\":\"14\",\"isSelected\":\"false\"},{\"id\":\"5\",\"label\":\"Tours & Packages\",\"value\":\"10\",\"isSelected\":\"false\"}]},\"marketSpecialties\":{\"fieldName\":\"marketSpecialties\",\"values\":[{\"label\":\"Inbound\",\"value\":\"IB\"},{\"label\":\"Adventure\",\"value\":\"AD\"},{\"label\":\"Conference/Exhibitions\",\"value\":\"CF\"}]},\"destinationSpecialties\":{\"fieldName\":\"destinationSpecialties\",\"values\":[{\"label\":\"France\",\"value\":\"FR\"},{\"label\":\"General\",\"value\":\"AL\"},{\"label\":\"Mexico\",\"value\":\"MX\"}]}},\"sectionDecision\":\"Section_Confirmed\",\"errors\":[]},\"SupportingDocuments\":{\"sectionName\":\"Supporting Documents\",\"cmpName\":\"supporting-documents\",\"values\":[],\"sectionDecision\":\"Section_Confirmed\",\"errors\":[]}},\"sectionsDone\":[{\"id\":0,\"sectionName\":\"new-applicant\",\"next\":\"agency-legal-status\"},{\"id\":1,\"sectionName\":\"agency-legal-status\",\"next\":\"shareholder-details\"},{\"id\":2,\"sectionName\":\"shareholder-details\",\"next\":\"address\"},{\"id\":3,\"sectionName\":\"address\",\"next\":\"mailing\"},{\"id\":4,\"sectionName\":\"mailing\",\"next\":\"contact\"},{\"id\":5,\"sectionName\":\"contact\",\"next\":\"business-profile\"},{\"id\":6,\"sectionName\":\"business-profile\",\"next\":\"business-specialization\"},{\"id\":7,\"sectionName\":\"business-specialization\",\"next\":\"supporting-documents\"},{\"id\":8,\"sectionName\":\"supporting-documents\",\"next\":\"submit-application\"}]}';
                applicationsettings=applicationReplace(applicationsettings);
                userType='vetting';
                TIDS_Controller.updateCaseStatus(
                    applicationDecision,
                    userType,
                    applicationType,
                    String.ValueOf(caseId),
                    applicationsettings,
                    reason);
        
                //Return to drat for the case
                mycase.Status='Draft';
                update mycase;
                                
                TIDSHelper.getVettingDoneCondition(String.ValueOf(caseId));
                TIDSHelper.getSortedBranches(String.ValueOf(accountId), 'Id', 'Desc', 'T');
                TIDSHelper.getSortedCases(String.ValueOf(accountId),'Id', 'Desc', '0');
                
        
            //}catch(Exception e) {
            //	errorMessage = e.getMessage();
            //	System.debug('error message:: ' + errorMessage);
            //}
        //}
        Test.stopTest();
        //System.assertEquals(true, errorMessage.contains(System.Label.GADM_account_contact_role_gadm_user), 'Inserting duplicate should not be allowed!');
    }
    @IsTest
    private static void saveandVettingHOCase() {

        Test.startTest();
        String errorMessage = '';
        //System.runAs(testUser) {
            //try{
                //setup();                
                String applicationDecision;
                String userType='client';
                String applicationType='NEW_HO';
                String applicationsettings;
                String reason='';
                //
                readObjectsId();
                applicationsettings ='{\"userType\":\"client\",\"applicationType\":\"NEW_HO\",\"userInfo\":{\"UserName\":\"PRIMARY USE FOR TIDS COND TEST\",\"UserId\":\"@userId\",\"ContactId\":\"@contatId\",\"tidsAccount\":{\"Id\":\"@accountId\",\"Country_ISO_Code\":\"CA\",\"RecordType\":{\"Name\":\"Standard Account\",\"Id\":\"@accountId\"}}},\"businessRules\":{\"Name\":\"TIDS\",\"Id\":\"a2w4E000000DaNDQA0\",\"TIDS_Total_Ownership_Minimum\":\"95\",\"TIDS_Total_Ownership_Maximum\":\"101\"},\"tidsCase\":{\"Id\":\"@caseId\"},\"sections\":{\"Welcome\":{\"sectionName\":\"Welcome\",\"cmpName\":\"new-applicant\",\"values\":{\"companyLegalName\":\"New HO Application - For Test Classes\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"AgencyLegalStatus\":{\"sectionName\":\"Agency Legal Status\",\"cmpName\":\"agency-legal-status\",\"values\":{\"tradingName\":\"Test Classes Application\",\"companyType\":\"C\",\"taxIdVATNumber1\":\"123456\",\"taxIdVATNumber2\":\"987654\",\"businessRegistration\":\"852963\",\"inOperationsSince\":\"2020-05-04\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"ShareholderDetails\":{\"sectionName\":\"Ownership Details\",\"cmpName\":\"shareholder-details\",\"values\":[{\"percentage\":\"50\",\"name\":\"Test\",\"email\":\"test@testclasses.com\",\"type\":\"Person\",\"id\":\"efba\"},{\"percentage\":\"50\",\"type\":\"Company\",\"name\":\"Class\",\"email\":\"class@testclasses.com\",\"id\":\"c6ab\"}],\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Address\":{\"sectionName\":\"Address\",\"cmpName\":\"address\",\"values\":{\"address\":\"10 Test Class Street\",\"city\":\"Laval\",\"citygeonameId\":6050610,\"state\":{\"Id\":\"@stateId\",\"label\":\"Quebec\",\"value\":\"CA-QC\"},\"postalCode\":\"H1H2H3\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Mailing\":{\"sectionName\":\"Mailing\",\"cmpName\":\"mailing\",\"values\":{\"isMailingSameAsPhysicalAddress\":\"false\",\"mailingAddress\":\"10 Mailing Street\",\"city\":\"Seattle\",\"citygeonameId\":5809844,\"state\":{\"Id\":\"@stateId\",\"label\":\"Washington\",\"value\":\"US-WA\"},\"postalCode\":\"98162\",\"countryName\":\"United States\",\"countryIsoCode\":\"US\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Contact\":{\"sectionName\":\"Contact\",\"cmpName\":\"contact\",\"values\":{\"preferedLanguage\":\"ENG\",\"phone\":\"15148740202\",\"fax\":\"15148743636\",\"businessEmail\":\"debonol@iata.org\",\"webSite\":\"www.testclasses.com\",\"omFirstName\":\"Test\",\"omLastName\":\"Classes\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"BusinessProfile\":{\"sectionName\":\"Business Profile\",\"cmpName\":\"business-profile\",\"values\":{\"principalActivities\":{\"fieldName\":\"principalActivities\",\"values\":[{\"label\":\"Online Travel Agency\",\"value\":\"OL\"}]},\"marketFocus\":{\"fieldName\":\"marketFocus\",\"values\":[{\"label\":\"Leisure\",\"value\":\"67\"},{\"label\":\"Corporate\",\"value\":\"33\"}]},\"salesMix\":{\"fieldName\":\"salesMix\",\"values\":[{\"label\":\"Online\",\"value\":\"39\"},{\"label\":\"Offline\",\"value\":\"61\"}]},\"travelSales\":{\"fieldName\":\"travelSales\",\"values\":\"3\"},\"GDS\":{\"fieldName\":\"GDS\",\"values\":[{\"label\":\"Farelogix\",\"value\":\"FLGX\"},{\"label\":\"Travelsky\",\"value\":\"MINS\"}]},\"numberEmployees\":{\"fieldName\":\"numberEmployees\",\"values\":\"2\"},\"numberOffices\":{\"fieldName\":\"numberOffices\",\"values\":\"8\"}},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"BusinessSpecialization\":{\"sectionName\":\"Business Specialization\",\"cmpName\":\"business-specialization\",\"values\":{\"percentageBreakdown\":{\"fieldName\":\"percentageBreakdown\",\"values\":[{\"id\":null,\"label\":\"Accommodation\",\"value\":\"12\",\"isSelected\":\"false\"},{\"id\":\"1\",\"label\":\"Air Travel\",\"value\":\"18\",\"isSelected\":\"false\"},{\"id\":\"2\",\"label\":\"Cruises\",\"value\":\"33\",\"isSelected\":\"false\"},{\"id\":\"3\",\"label\":\"Land Transportation\",\"value\":\"13\",\"isSelected\":\"false\"},{\"id\":\"4\",\"label\":\"Meetings & Events\",\"value\":\"14\",\"isSelected\":\"false\"},{\"id\":\"5\",\"label\":\"Tours & Packages\",\"value\":\"10\",\"isSelected\":\"false\"}]},\"marketSpecialties\":{\"fieldName\":\"marketSpecialties\",\"values\":[{\"label\":\"Inbound\",\"value\":\"IB\"},{\"label\":\"Adventure\",\"value\":\"AD\"},{\"label\":\"Conference/Exhibitions\",\"value\":\"CF\"}]},\"destinationSpecialties\":{\"fieldName\":\"destinationSpecialties\",\"values\":[{\"label\":\"France\",\"value\":\"FR\"},{\"label\":\"General\",\"value\":\"AL\"},{\"label\":\"Mexico\",\"value\":\"MX\"}]}},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"SupportingDocuments\":{\"sectionName\":\"Supporting Documents\",\"cmpName\":\"supporting-documents\",\"values\":[],\"sectionDecision\":\"Not_Started\",\"errors\":[]}},\"sectionsDone\":[{\"id\":0,\"sectionName\":\"new-applicant\",\"next\":\"agency-legal-status\"},{\"id\":1,\"sectionName\":\"agency-legal-status\",\"next\":\"shareholder-details\"},{\"id\":2,\"sectionName\":\"shareholder-details\",\"next\":\"address\"},{\"id\":3,\"sectionName\":\"address\",\"next\":\"mailing\"},{\"id\":4,\"sectionName\":\"mailing\",\"next\":\"contact\"},{\"id\":5,\"sectionName\":\"contact\",\"next\":\"business-profile\"},{\"id\":6,\"sectionName\":\"business-profile\",\"next\":\"business-specialization\"},{\"id\":7,\"sectionName\":\"business-specialization\",\"next\":\"supporting-documents\"},{\"id\":8,\"sectionName\":\"supporting-documents\",\"next\":\"submit-application\"}]}';
                caseId = TIDSHelper.saveSettings(
                                    accountId,
                                    applicationsettings,
                                    applicationtype,
                                    null);
          
          		Case mycase = [Select Id, ContactId,Status From Case Where Id=:caseId limit 1];
                mycase.Status='Pending Review';
                update mycase;
                TIDSHelper.actionApplication(String.ValueOf(caseId), 'vetting');
                TIDSHelper.actionApplication(String.ValueOf(caseId), 'recall');
                mycase.Status='Draft';
                update mycase;
                TIDSHelper.actionApplication(String.ValueOf(caseId), 'resume');
                TIDSHelper.discardApplication(String.ValueOf(caseId));
		
				TIDSHelper.getTidsCase(String.ValueOf(caseId), String.ValueOf(userId));
				TIDSHelper.assignToCaseOwner(String.ValueOf(caseId));				
				TIDSUtil.sendNotification(String.ValueOf(caseId), String.ValueOf(contactId));
			            
            //}catch(Exception e) {
            //	errorMessage = e.getMessage();
            //	System.debug('error message:: ' + errorMessage);
            //}
        //}
        Test.stopTest();
        //System.assertEquals(true, errorMessage.contains(System.Label.GADM_account_contact_role_gadm_user), 'Inserting duplicate should not be allowed!');
    }
    @IsTest
    private static void saveandVettingHOAdministratorAdd() {

        Test.startTest();
        String errorMessage = '';
        //System.runAs(testUser) {
            //try{
                //setup();                
                String applicationDecision;
                String userType='client';
                String applicationType='NEW_HO';
                String applicationsettings;
                String reason='';
				//
				createProfileSetup();
				readObjectsId2();
				createHORight();
				
				TIDSHelper.actionAdministrators(String.ValueOf(accountId), String.ValueOf(secondaryId), 'add', false);
            	TIDSHelper.getAdministrators(String.ValueOf(accountId), 'c');
				
                
             
            //}catch(Exception e) {
            //	errorMessage = e.getMessage();
            //	System.debug('error message:: ' + errorMessage);
            //}
        //}
        Test.stopTest();
        //System.assertEquals(true, errorMessage.contains(System.Label.GADM_account_contact_role_gadm_user), 'Inserting duplicate should not be allowed!');
	}
	@IsTest
    private static void saveandVettingHOAdministratorRemove() {

        Test.startTest();
        String errorMessage = '';
        //System.runAs(testUser) {
            //try{
                //setup();                
                String applicationDecision;
                String userType='client';
                String applicationType='NEW_HO';
                String applicationsettings;
                String reason='';
				//
				createProfileSetup();
				readObjectsId2();
				createHORight();
				
				TIDSHelper.actionAdministrators(String.ValueOf(accountId), String.ValueOf(contactId), 'remove', false);
				
                
             
            //}catch(Exception e) {
            //	errorMessage = e.getMessage();
            //	System.debug('error message:: ' + errorMessage);
            //}
        //}
        Test.stopTest();
        //System.assertEquals(true, errorMessage.contains(System.Label.GADM_account_contact_role_gadm_user), 'Inserting duplicate should not be allowed!');
	}
	@IsTest
    private static void saveandVettingHOAdministratorSwap() {

        Test.startTest();
        String errorMessage = '';
        //System.runAs(testUser) {
            //try{
                //setup();                
                String applicationDecision;
                String userType='client';
                String applicationType='NEW_HO';
                String applicationsettings;
                String reason='';
				//
				createProfileSetup();
				readObjectsId2();
				createHORight();
				
				TIDSHelper.actionAdministrators(String.ValueOf(accountId), String.ValueOf(contactId), 'add', false);
            	TIDSHelper.actionAdministrators(String.ValueOf(accountId), String.ValueOf(secondaryId), 'swap', false);
            	
                
             
            //}catch(Exception e) {
            //	errorMessage = e.getMessage();
            //	System.debug('error message:: ' + errorMessage);
            //}
        //}
        Test.stopTest();
        //System.assertEquals(true, errorMessage.contains(System.Label.GADM_account_contact_role_gadm_user), 'Inserting duplicate should not be allowed!');
    }
    @IsTest
    private static void saveandVettingHOSubFunctions() {

        Test.startTest();
        String errorMessage = '';
        //System.runAs(testUser) {
            //try{
                //setup();                
                String applicationDecision;
                String userType='client';
                String applicationType='NEW_HO';
                String applicationsettings;
                String reason='';
                //
                readObjectsId();
                applicationsettings ='{\"userType\":\"client\",\"applicationType\":\"NEW_HO\",\"userInfo\":{\"UserName\":\"PRIMARY USE FOR TIDS COND TEST\",\"UserId\":\"@userId\",\"ContactId\":\"@contatId\",\"tidsAccount\":{\"Id\":\"@accountId\",\"Country_ISO_Code\":\"CA\",\"RecordType\":{\"Name\":\"Standard Account\",\"Id\":\"@accountId\"}}},\"businessRules\":{\"Name\":\"TIDS\",\"Id\":\"a2w4E000000DaNDQA0\",\"TIDS_Total_Ownership_Minimum\":\"95\",\"TIDS_Total_Ownership_Maximum\":\"101\"},\"tidsCase\":{\"Id\":\"@caseId\"},\"sections\":{\"Welcome\":{\"sectionName\":\"Welcome\",\"cmpName\":\"new-applicant\",\"values\":{\"companyLegalName\":\"New HO Application - For Test Classes\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"AgencyLegalStatus\":{\"sectionName\":\"Agency Legal Status\",\"cmpName\":\"agency-legal-status\",\"values\":{\"tradingName\":\"Test Classes Application\",\"companyType\":\"C\",\"taxIdVATNumber1\":\"123456\",\"taxIdVATNumber2\":\"987654\",\"businessRegistration\":\"852963\",\"inOperationsSince\":\"2020-05-04\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"ShareholderDetails\":{\"sectionName\":\"Ownership Details\",\"cmpName\":\"shareholder-details\",\"values\":[{\"percentage\":\"50\",\"name\":\"Test\",\"email\":\"test@testclasses.com\",\"type\":\"Person\",\"id\":\"efba\"},{\"percentage\":\"50\",\"type\":\"Company\",\"name\":\"Class\",\"email\":\"class@testclasses.com\",\"id\":\"c6ab\"}],\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Address\":{\"sectionName\":\"Address\",\"cmpName\":\"address\",\"values\":{\"address\":\"10 Test Class Street\",\"city\":\"Laval\",\"citygeonameId\":6050610,\"state\":{\"Id\":\"@stateId\",\"label\":\"Quebec\",\"value\":\"CA-QC\"},\"postalCode\":\"H1H2H3\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Mailing\":{\"sectionName\":\"Mailing\",\"cmpName\":\"mailing\",\"values\":{\"isMailingSameAsPhysicalAddress\":\"false\",\"mailingAddress\":\"10 Mailing Street\",\"city\":\"Seattle\",\"citygeonameId\":5809844,\"state\":{\"Id\":\"@stateId\",\"label\":\"Washington\",\"value\":\"US-WA\"},\"postalCode\":\"98162\",\"countryName\":\"United States\",\"countryIsoCode\":\"US\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Contact\":{\"sectionName\":\"Contact\",\"cmpName\":\"contact\",\"values\":{\"preferedLanguage\":\"ENG\",\"phone\":\"15148740202\",\"fax\":\"15148743636\",\"businessEmail\":\"debonol@iata.org\",\"webSite\":\"www.testclasses.com\",\"omFirstName\":\"Test\",\"omLastName\":\"Classes\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"BusinessProfile\":{\"sectionName\":\"Business Profile\",\"cmpName\":\"business-profile\",\"values\":{\"principalActivities\":{\"fieldName\":\"principalActivities\",\"values\":[{\"label\":\"Online Travel Agency\",\"value\":\"OL\"}]},\"marketFocus\":{\"fieldName\":\"marketFocus\",\"values\":[{\"label\":\"Leisure\",\"value\":\"67\"},{\"label\":\"Corporate\",\"value\":\"33\"}]},\"salesMix\":{\"fieldName\":\"salesMix\",\"values\":[{\"label\":\"Online\",\"value\":\"39\"},{\"label\":\"Offline\",\"value\":\"61\"}]},\"travelSales\":{\"fieldName\":\"travelSales\",\"values\":\"3\"},\"GDS\":{\"fieldName\":\"GDS\",\"values\":[{\"label\":\"Farelogix\",\"value\":\"FLGX\"},{\"label\":\"Travelsky\",\"value\":\"MINS\"}]},\"numberEmployees\":{\"fieldName\":\"numberEmployees\",\"values\":\"2\"},\"numberOffices\":{\"fieldName\":\"numberOffices\",\"values\":\"8\"}},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"BusinessSpecialization\":{\"sectionName\":\"Business Specialization\",\"cmpName\":\"business-specialization\",\"values\":{\"percentageBreakdown\":{\"fieldName\":\"percentageBreakdown\",\"values\":[{\"id\":null,\"label\":\"Accommodation\",\"value\":\"12\",\"isSelected\":\"false\"},{\"id\":\"1\",\"label\":\"Air Travel\",\"value\":\"18\",\"isSelected\":\"false\"},{\"id\":\"2\",\"label\":\"Cruises\",\"value\":\"33\",\"isSelected\":\"false\"},{\"id\":\"3\",\"label\":\"Land Transportation\",\"value\":\"13\",\"isSelected\":\"false\"},{\"id\":\"4\",\"label\":\"Meetings & Events\",\"value\":\"14\",\"isSelected\":\"false\"},{\"id\":\"5\",\"label\":\"Tours & Packages\",\"value\":\"10\",\"isSelected\":\"false\"}]},\"marketSpecialties\":{\"fieldName\":\"marketSpecialties\",\"values\":[{\"label\":\"Inbound\",\"value\":\"IB\"},{\"label\":\"Adventure\",\"value\":\"AD\"},{\"label\":\"Conference/Exhibitions\",\"value\":\"CF\"}]},\"destinationSpecialties\":{\"fieldName\":\"destinationSpecialties\",\"values\":[{\"label\":\"France\",\"value\":\"FR\"},{\"label\":\"General\",\"value\":\"AL\"},{\"label\":\"Mexico\",\"value\":\"MX\"}]}},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"SupportingDocuments\":{\"sectionName\":\"Supporting Documents\",\"cmpName\":\"supporting-documents\",\"values\":[],\"sectionDecision\":\"Not_Started\",\"errors\":[]}},\"sectionsDone\":[{\"id\":0,\"sectionName\":\"new-applicant\",\"next\":\"agency-legal-status\"},{\"id\":1,\"sectionName\":\"agency-legal-status\",\"next\":\"shareholder-details\"},{\"id\":2,\"sectionName\":\"shareholder-details\",\"next\":\"address\"},{\"id\":3,\"sectionName\":\"address\",\"next\":\"mailing\"},{\"id\":4,\"sectionName\":\"mailing\",\"next\":\"contact\"},{\"id\":5,\"sectionName\":\"contact\",\"next\":\"business-profile\"},{\"id\":6,\"sectionName\":\"business-profile\",\"next\":\"business-specialization\"},{\"id\":7,\"sectionName\":\"business-specialization\",\"next\":\"supporting-documents\"},{\"id\":8,\"sectionName\":\"supporting-documents\",\"next\":\"submit-application\"}]}';
                caseId = TIDSHelper.saveSettings(
                                    accountId,
                                    applicationsettings,
                                    applicationtype,
                                    null);
			
				
                TIDSHelper.getcountryISOCode();
                TIDSHelper.getCountries('mailing');
                TIDSHelper.getMailingCountries();
                TIDSHelper.getCountry();
				TIDSHelper.getState('CA');
				TIDSHelper.companyNameUnique(String.ValueOf(accountId),'TIDS corporate','CA');
                TIDSHelper.companyNameUnique(String.ValueOf(accountId),'TIDS inc.','CA');
                TIDSHelper.caseSubjectText(applicationType);
				TIDSHelper.caseReasonText(applicationType);
				
				TIDSHelper.allMyTidsCases('My Cases');
				TIDSHelper.allMyTidsCases('Pending Review');
				TIDSHelper.allMyTidsCases('Pending Customer');
				TIDSHelper.allMyTidsCases('All');
				TIDSHelper.getLocalPlace('city','Montreal','CA');
				TIDSHelper.getLocalPlace('postal','H1M','CA');
				
				createHORight();
				TIDSHelper.newBranch(String.ValueOf(contactId));
				
             
            //}catch(Exception e) {
            //	errorMessage = e.getMessage();
            //	System.debug('error message:: ' + errorMessage);
            //}
        //}
        Test.stopTest();
        //System.assertEquals(true, errorMessage.contains(System.Label.GADM_account_contact_role_gadm_user), 'Inserting duplicate should not be allowed!');
    }
    @IsTest
    private static void saveandVettingBRTest() {

        Test.startTest();
        String errorMessage = '';
        //System.runAs(testUser) {
            //try{
                String applicationDecision;
                String userType='client';
                String applicationType='NEW_BR';
                String applicationsettings;
                String reason='';
                //
                readObjectsId();
                applicationsettings ='{\"userType\":\"client\",\"applicationType\":\"NEW_BR\",\"userInfo\":{\"UserName\":\"PRIMARY USE FOR TIDS COND TEST\",\"UserId\":\"@userId\",\"ContactId\":\"@contatId\",\"tidsAccount\":{\"Id\":\"@accountId\",\"Country_ISO_Code\":\"CA\",\"RecordType\":{\"Name\":\"Standard Account\",\"Id\":\"@accountId\"}}},\"businessRules\":{\"Name\":\"TIDS\",\"Id\":\"a2w4E000000DaNDQA0\",\"TIDS_Total_Ownership_Minimum\":\"95\",\"TIDS_Total_Ownership_Maximum\":\"101\"},\"tidsCase\":{\"Id\":\"@caseId\"},\"sections\":{\"Welcome\":{\"sectionName\":\"Welcome\",\"cmpName\":\"new-applicant\",\"values\":{\"companyLegalName\":\"New HO Application - For Test Classes\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"AgencyLegalStatus\":{\"sectionName\":\"Agency Legal Status\",\"cmpName\":\"agency-legal-status\",\"values\":{\"tradingName\":\"Test Classes Application\",\"companyType\":\"C\",\"taxIdVATNumber1\":\"123456\",\"taxIdVATNumber2\":\"987654\",\"businessRegistration\":\"852963\",\"inOperationsSince\":\"2020-05-04\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"ShareholderDetails\":{\"sectionName\":\"Ownership Details\",\"cmpName\":\"shareholder-details\",\"values\":[{\"percentage\":\"50\",\"name\":\"Test\",\"email\":\"test@testclasses.com\",\"type\":\"Person\",\"id\":\"efba\"},{\"percentage\":\"50\",\"type\":\"Company\",\"name\":\"Class\",\"email\":\"class@testclasses.com\",\"id\":\"c6ab\"}],\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Address\":{\"sectionName\":\"Address\",\"cmpName\":\"address\",\"values\":{\"address\":\"10 Test Class Street\",\"city\":\"Laval\",\"citygeonameId\":6050610,\"state\":{\"Id\":\"@stateId\",\"label\":\"Quebec\",\"value\":\"CA-QC\"},\"postalCode\":\"H1H2H3\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Mailing\":{\"sectionName\":\"Mailing\",\"cmpName\":\"mailing\",\"values\":{\"isMailingSameAsPhysicalAddress\":\"false\",\"mailingAddress\":\"10 Mailing Street\",\"city\":\"Seattle\",\"citygeonameId\":5809844,\"state\":{\"Id\":\"@stateId\",\"label\":\"Washington\",\"value\":\"US-WA\"},\"postalCode\":\"98162\",\"countryName\":\"United States\",\"countryIsoCode\":\"US\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Contact\":{\"sectionName\":\"Contact\",\"cmpName\":\"contact\",\"values\":{\"preferedLanguage\":\"ENG\",\"phone\":\"15148740202\",\"fax\":\"15148743636\",\"businessEmail\":\"debonol@iata.org\",\"webSite\":\"www.testclasses.com\",\"omFirstName\":\"Test\",\"omLastName\":\"Classes\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"BusinessProfile\":{\"sectionName\":\"Business Profile\",\"cmpName\":\"business-profile\",\"values\":{\"principalActivities\":{\"fieldName\":\"principalActivities\",\"values\":[{\"label\":\"Online Travel Agency\",\"value\":\"OL\"}]},\"marketFocus\":{\"fieldName\":\"marketFocus\",\"values\":[{\"label\":\"Leisure\",\"value\":\"67\"},{\"label\":\"Corporate\",\"value\":\"33\"}]},\"salesMix\":{\"fieldName\":\"salesMix\",\"values\":[{\"label\":\"Online\",\"value\":\"39\"},{\"label\":\"Offline\",\"value\":\"61\"}]},\"travelSales\":{\"fieldName\":\"travelSales\",\"values\":\"3\"},\"GDS\":{\"fieldName\":\"GDS\",\"values\":[{\"label\":\"Farelogix\",\"value\":\"FLGX\"},{\"label\":\"Travelsky\",\"value\":\"MINS\"}]},\"numberEmployees\":{\"fieldName\":\"numberEmployees\",\"values\":\"2\"},\"numberOffices\":{\"fieldName\":\"numberOffices\",\"values\":\"8\"}},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"BusinessSpecialization\":{\"sectionName\":\"Business Specialization\",\"cmpName\":\"business-specialization\",\"values\":{\"percentageBreakdown\":{\"fieldName\":\"percentageBreakdown\",\"values\":[{\"id\":null,\"label\":\"Accommodation\",\"value\":\"12\",\"isSelected\":\"false\"},{\"id\":\"1\",\"label\":\"Air Travel\",\"value\":\"18\",\"isSelected\":\"false\"},{\"id\":\"2\",\"label\":\"Cruises\",\"value\":\"33\",\"isSelected\":\"false\"},{\"id\":\"3\",\"label\":\"Land Transportation\",\"value\":\"13\",\"isSelected\":\"false\"},{\"id\":\"4\",\"label\":\"Meetings & Events\",\"value\":\"14\",\"isSelected\":\"false\"},{\"id\":\"5\",\"label\":\"Tours & Packages\",\"value\":\"10\",\"isSelected\":\"false\"}]},\"marketSpecialties\":{\"fieldName\":\"marketSpecialties\",\"values\":[{\"label\":\"Inbound\",\"value\":\"IB\"},{\"label\":\"Adventure\",\"value\":\"AD\"},{\"label\":\"Conference/Exhibitions\",\"value\":\"CF\"}]},\"destinationSpecialties\":{\"fieldName\":\"destinationSpecialties\",\"values\":[{\"label\":\"France\",\"value\":\"FR\"},{\"label\":\"General\",\"value\":\"AL\"},{\"label\":\"Mexico\",\"value\":\"MX\"}]}},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"SupportingDocuments\":{\"sectionName\":\"Supporting Documents\",\"cmpName\":\"supporting-documents\",\"values\":[],\"sectionDecision\":\"Not_Started\",\"errors\":[]}},\"sectionsDone\":[{\"id\":0,\"sectionName\":\"new-applicant\",\"next\":\"agency-legal-status\"},{\"id\":1,\"sectionName\":\"agency-legal-status\",\"next\":\"shareholder-details\"},{\"id\":2,\"sectionName\":\"shareholder-details\",\"next\":\"address\"},{\"id\":3,\"sectionName\":\"address\",\"next\":\"mailing\"},{\"id\":4,\"sectionName\":\"mailing\",\"next\":\"contact\"},{\"id\":5,\"sectionName\":\"contact\",\"next\":\"business-profile\"},{\"id\":6,\"sectionName\":\"business-profile\",\"next\":\"business-specialization\"},{\"id\":7,\"sectionName\":\"business-specialization\",\"next\":\"supporting-documents\"},{\"id\":8,\"sectionName\":\"supporting-documents\",\"next\":\"submit-application\"}]}';
                caseId = TIDSHelper.saveSettings(
                                    accountId,
                                    applicationsettings,
                                    applicationtype,
                                    null);
				
				Case mycase = [Select Id, ContactId,Status From Case Where Id=:caseId limit 1];
                mycase.ContactId= contactId;
                update mycase;
                //Return to drat for the case
                 //mycase.Status='Draft';
                //update mycase;
                //Vetting Approved
                applicationDecision='Approved';
                applicationsettings='{\"userType\":\"client\",\"applicationType\":\"NEW_BR\",\"userInfo\":{\"UserName\":\"Valteri Bottas\",\"UserId\":\"@userId\",\"ContactId\":\"@contactId\",\"role\":\"TIDS Admin HO Primary\",\"tidsAccount\":{\"Id\":\"@accountId\",\"Country_ISO_Code\":\"CA\",\"RecordType\":{\"Name\":\"Agency\",\"Id\":\"@accountId\"}}},\"businessRules\":{\"Name\":\"TIDS\",\"Id\":\"@accountId\",\"TIDS_Total_Ownership_Minimum\":\"95\",\"TIDS_Total_Ownership_Maximum\":\"101\"},\"tidsCase\":{\"Id\":\"@caseId\"},\"sections\":{\"Welcome\":{\"cmpName\":\"new-applicant\",\"target\":\"NA\",\"values\":{\"companyLegalName\":\"Bottas Racing Inc.\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"NA\",\"vettingErrors\":[]},\"AgencyLegalStatus\":{\"sectionName\":\"Agency Legal Status\",\"cmpName\":\"agency-legal-status\",\"values\":{\"tradingName\":\"BR Application for Test Classes\",\"companyType\":\"L\",\"taxIdVATNumber1\":\"GST/1456784\",\"taxIdVATNumber2\":\"QST/96314-778\",\"businessRegistration\":\"123\",\"inOperationsSince\":\"2020-09-09\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"ShareholderDetails\":{\"cmpName\":\"shareholder-details\",\"target\":\"NA\",\"values\":[{\"percentage\":90,\"type\":\"Company\",\"name\":\"Bottas Limited Partnership\",\"email\":\"bottas@tids.iata.org\",\"id\":\"a7B4E0000001ZdHUAU\"},{\"percentage\":10,\"type\":\"Person\",\"name\":\"Bottas Family\",\"email\":\"bottasfamily@tids.iata.org\",\"id\":\"a7B4E0000001ZdIUAU\"}],\"sectionDecision\":\"NA\"},\"Address\":{\"sectionName\":\"Address\",\"cmpName\":\"address\",\"values\":{\"address\":\"10 King Street\",\"city\":\"Toronto\",\"citygeonameId\":6167865,\"state\":{\"Id\":\"@stateId\",\"label\":\"Ontario\",\"value\":\"CA-ON\"},\"postalCode\":\"M4M4J4\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Mailing\":{\"sectionName\":\"Mailing\",\"cmpName\":\"mailing\",\"values\":{\"isMailingSameAsPhysicalAddress\":\"true\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Contact\":{\"sectionName\":\"Contact\",\"cmpName\":\"contact\",\"values\":{\"preferedLanguage\":\"ENG\",\"phone\":\"14186365241\",\"businessEmail\":\"tids@iata.org\",\"webSite\":\"www.iata.org/tids\",\"omFirstName\":\"Mr\",\"omLastName\":\"Freeze\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"BusinessProfile\":{\"sectionName\":\"Business Profile\",\"cmpName\":\"business-profile\",\"values\":{\"principalActivities\":{\"fieldName\":\"principalActivities\",\"values\":[{\"label\":\"Consolidator\",\"value\":\"CN\"}]},\"marketFocus\":{\"fieldName\":\"marketFocus\",\"values\":[{\"label\":\"Leisure\",\"value\":\"64\"},{\"label\":\"Corporate\",\"value\":\"36\"}]},\"salesMix\":{\"fieldName\":\"salesMix\",\"values\":[{\"label\":\"Online\",\"value\":\"93\"},{\"label\":\"Offline\",\"value\":\"7\"}]},\"travelSales\":{},\"GDS\":{\"fieldName\":\"GDS\",\"values\":[{\"label\":\"Sabre\",\"value\":\"SABR\"},{\"label\":\"Amadeus\",\"value\":\"AGTD\"}]},\"numberEmployees\":{\"fieldName\":\"numberEmployees\",\"values\":\"1\"},\"numberOffices\":{}},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"BusinessSpecialization\":{\"sectionName\":\"Business Specialization\",\"cmpName\":\"business-specialization\",\"values\":{\"percentageBreakdown\":{\"fieldName\":\"percentageBreakdown\",\"values\":[{\"id\":null,\"label\":\"Accommodation\",\"value\":\"75\",\"isSelected\":\"false\"},{\"id\":\"1\",\"label\":\"Air Travel\",\"value\":\"3\",\"isSelected\":\"false\"},{\"id\":\"2\",\"label\":\"Cruises\",\"value\":\"4\",\"isSelected\":\"false\"},{\"id\":\"3\",\"label\":\"Land Transportation\",\"value\":\"5\",\"isSelected\":\"false\"},{\"id\":\"4\",\"label\":\"Meetings & Events\",\"value\":\"6\",\"isSelected\":\"false\"},{\"id\":\"5\",\"label\":\"Tours & Packages\",\"value\":\"7\",\"isSelected\":\"false\"}]},\"marketSpecialties\":{\"fieldName\":\"marketSpecialties\",\"values\":[{\"label\":\"Adventure\",\"value\":\"AD\"},{\"label\":\"Inbound\",\"value\":\"IB\"},{\"label\":\"Cruises\",\"value\":\"CR\"}]},\"destinationSpecialties\":{\"fieldName\":\"destinationSpecialties\",\"values\":[{\"label\":\"General\",\"value\":\"AL\"},{\"label\":\"Europe\",\"value\":\"EU\"},{\"label\":\"Caribbean\",\"value\":\"CB\"}]}},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"SupportingDocuments\":{\"sectionName\":\"Supporting Documents\",\"cmpName\":\"supporting-documents\",\"values\":[],\"sectionDecision\":\"Not_Started\",\"errors\":[]}},\"sectionsDone\":[{\"id\":0,\"sectionName\":\"agency-legal-status\",\"next\":\"address\"},{\"id\":1,\"sectionName\":\"address\",\"next\":\"mailing\"},{\"id\":2,\"sectionName\":\"mailing\",\"next\":\"contact\"},{\"id\":3,\"sectionName\":\"contact\",\"next\":\"business-profile\"},{\"id\":4,\"sectionName\":\"business-profile\",\"next\":\"business-specialization\"},{\"id\":5,\"sectionName\":\"business-specialization\",\"next\":\"supporting-documents\"},{\"id\":6,\"sectionName\":\"supporting-documents\",\"next\":\"submit-application\"}]}';
			    applicationsettings=applicationReplace(applicationsettings);
                reason='Last TIDS Application has been Approved and this case is now Closed';
                TIDS_Controller.updateCaseStatus(
                    applicationDecision,
                    userType,
                    applicationType,
                    String.ValueOf(caseId),
                    applicationsettings,
                    reason);
				//}catch(Exception e) {
            //	errorMessage = e.getMessage();
            //}
        //}
        Test.stopTest();
        //System.assertEquals(true, errorMessage == '', 'Inserting account contact role with group record type should be allowed!');
    }
    
    @IsTest
    private static void saveandVettingVBTest() {
        Test.startTest();
        String errorMessage = '';
        //System.runAs(testUser) {
        //	try{
			String applicationDecision;
			String userType='client';
			String applicationType='NEW_VB';
			String applicationsettings;
			String reason='';
			//
			readObjectsId();
			applicationsettings ='{\"userType\":\"client\",\"applicationType\":\"NEW_VB\",\"userInfo\":{\"UserName\":\"PRIMARY USE FOR TIDS COND TEST\",\"UserId\":\"@userId\",\"ContactId\":\"@contatId\",\"tidsAccount\":{\"Id\":\"@accountId\",\"Country_ISO_Code\":\"CA\",\"RecordType\":{\"Name\":\"Standard Account\",\"Id\":\"@accountId\"}}},\"businessRules\":{\"Name\":\"TIDS\",\"Id\":\"a2w4E000000DaNDQA0\",\"TIDS_Total_Ownership_Minimum\":\"95\",\"TIDS_Total_Ownership_Maximum\":\"101\"},\"tidsCase\":{\"Id\":\"@caseId\"},\"sections\":{\"Welcome\":{\"sectionName\":\"Welcome\",\"cmpName\":\"new-applicant\",\"values\":{\"companyLegalName\":\"New HO Application - For Test Classes\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"AgencyLegalStatus\":{\"sectionName\":\"Agency Legal Status\",\"cmpName\":\"agency-legal-status\",\"values\":{\"tradingName\":\"Test Classes Application\",\"companyType\":\"C\",\"taxIdVATNumber1\":\"123456\",\"taxIdVATNumber2\":\"987654\",\"businessRegistration\":\"852963\",\"inOperationsSince\":\"2020-05-04\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"ShareholderDetails\":{\"sectionName\":\"Ownership Details\",\"cmpName\":\"shareholder-details\",\"values\":[{\"percentage\":\"50\",\"name\":\"Test\",\"email\":\"test@testclasses.com\",\"type\":\"Person\",\"id\":\"efba\"},{\"percentage\":\"50\",\"type\":\"Company\",\"name\":\"Class\",\"email\":\"class@testclasses.com\",\"id\":\"c6ab\"}],\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Address\":{\"sectionName\":\"Address\",\"cmpName\":\"address\",\"values\":{\"address\":\"10 Test Class Street\",\"city\":\"Laval\",\"citygeonameId\":6050610,\"state\":{\"Id\":\"@stateId\",\"label\":\"Quebec\",\"value\":\"CA-QC\"},\"postalCode\":\"H1H2H3\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Mailing\":{\"sectionName\":\"Mailing\",\"cmpName\":\"mailing\",\"values\":{\"isMailingSameAsPhysicalAddress\":\"false\",\"mailingAddress\":\"10 Mailing Street\",\"city\":\"Seattle\",\"citygeonameId\":5809844,\"state\":{\"Id\":\"@stateId\",\"label\":\"Washington\",\"value\":\"US-WA\"},\"postalCode\":\"98162\",\"countryName\":\"United States\",\"countryIsoCode\":\"US\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Contact\":{\"sectionName\":\"Contact\",\"cmpName\":\"contact\",\"values\":{\"preferedLanguage\":\"ENG\",\"phone\":\"15148740202\",\"fax\":\"15148743636\",\"businessEmail\":\"debonol@iata.org\",\"webSite\":\"www.testclasses.com\",\"omFirstName\":\"Test\",\"omLastName\":\"Classes\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"BusinessProfile\":{\"sectionName\":\"Business Profile\",\"cmpName\":\"business-profile\",\"values\":{\"principalActivities\":{\"fieldName\":\"principalActivities\",\"values\":[{\"label\":\"Online Travel Agency\",\"value\":\"OL\"}]},\"marketFocus\":{\"fieldName\":\"marketFocus\",\"values\":[{\"label\":\"Leisure\",\"value\":\"67\"},{\"label\":\"Corporate\",\"value\":\"33\"}]},\"salesMix\":{\"fieldName\":\"salesMix\",\"values\":[{\"label\":\"Online\",\"value\":\"39\"},{\"label\":\"Offline\",\"value\":\"61\"}]},\"travelSales\":{\"fieldName\":\"travelSales\",\"values\":\"3\"},\"GDS\":{\"fieldName\":\"GDS\",\"values\":[{\"label\":\"Farelogix\",\"value\":\"FLGX\"},{\"label\":\"Travelsky\",\"value\":\"MINS\"}]},\"numberEmployees\":{\"fieldName\":\"numberEmployees\",\"values\":\"2\"},\"numberOffices\":{\"fieldName\":\"numberOffices\",\"values\":\"8\"}},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"BusinessSpecialization\":{\"sectionName\":\"Business Specialization\",\"cmpName\":\"business-specialization\",\"values\":{\"percentageBreakdown\":{\"fieldName\":\"percentageBreakdown\",\"values\":[{\"id\":null,\"label\":\"Accommodation\",\"value\":\"12\",\"isSelected\":\"false\"},{\"id\":\"1\",\"label\":\"Air Travel\",\"value\":\"18\",\"isSelected\":\"false\"},{\"id\":\"2\",\"label\":\"Cruises\",\"value\":\"33\",\"isSelected\":\"false\"},{\"id\":\"3\",\"label\":\"Land Transportation\",\"value\":\"13\",\"isSelected\":\"false\"},{\"id\":\"4\",\"label\":\"Meetings & Events\",\"value\":\"14\",\"isSelected\":\"false\"},{\"id\":\"5\",\"label\":\"Tours & Packages\",\"value\":\"10\",\"isSelected\":\"false\"}]},\"marketSpecialties\":{\"fieldName\":\"marketSpecialties\",\"values\":[{\"label\":\"Inbound\",\"value\":\"IB\"},{\"label\":\"Adventure\",\"value\":\"AD\"},{\"label\":\"Conference/Exhibitions\",\"value\":\"CF\"}]},\"destinationSpecialties\":{\"fieldName\":\"destinationSpecialties\",\"values\":[{\"label\":\"France\",\"value\":\"FR\"},{\"label\":\"General\",\"value\":\"AL\"},{\"label\":\"Mexico\",\"value\":\"MX\"}]}},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"SupportingDocuments\":{\"sectionName\":\"Supporting Documents\",\"cmpName\":\"supporting-documents\",\"values\":[],\"sectionDecision\":\"Not_Started\",\"errors\":[]}},\"sectionsDone\":[{\"id\":0,\"sectionName\":\"new-applicant\",\"next\":\"agency-legal-status\"},{\"id\":1,\"sectionName\":\"agency-legal-status\",\"next\":\"shareholder-details\"},{\"id\":2,\"sectionName\":\"shareholder-details\",\"next\":\"address\"},{\"id\":3,\"sectionName\":\"address\",\"next\":\"mailing\"},{\"id\":4,\"sectionName\":\"mailing\",\"next\":\"contact\"},{\"id\":5,\"sectionName\":\"contact\",\"next\":\"business-profile\"},{\"id\":6,\"sectionName\":\"business-profile\",\"next\":\"business-specialization\"},{\"id\":7,\"sectionName\":\"business-specialization\",\"next\":\"supporting-documents\"},{\"id\":8,\"sectionName\":\"supporting-documents\",\"next\":\"submit-application\"}]}';
			caseId = TIDSHelper.saveSettings(
								accountId,
								applicationsettings,
								applicationtype,
								null);
			
			Case mycase = [Select Id, ContactId,Status From Case Where Id=:caseId limit 1];
			mycase.ContactId= contactId;
			update mycase;
			//Return to drat for the case
			 //mycase.Status='Draft';
			//update mycase;
			//Vetting Approved
			applicationDecision='Approved';
			applicationsettings='{\"userType\":\"client\",\"applicationType\":\"NEW_VB\",\"userInfo\":{\"UserName\":\"Valteri Bottas\",\"UserId\":\"@userId\",\"ContactId\":\"@contactId",\"role\":\"TIDS Admin HO Primary\",\"tidsAccount\":{\"Id\":\"@accountId\",\"Country_ISO_Code\":\"CA\",\"RecordType\":{\"Name\":\"Agency\",\"Id\":\"@accountId\"}}},\"businessRules\":{\"Name\":\"TIDS\",\"Id\":\"@accountId\",\"TIDS_Total_Ownership_Minimum\":\"95\",\"TIDS_Total_Ownership_Maximum\":\"101\"},\"tidsCase\":{\"Id\":\"@caseId\"},\"sections\":{\"Welcome\":{\"cmpName\":\"new-applicant\",\"target\":\"NA\",\"values\":{\"companyLegalName\":\"Bottas Racing Inc.\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"NA\",\"vettingErrors\":[]},\"AgencyLegalStatus\":{\"sectionName\":\"Agency Legal Status\",\"cmpName\":\"agency-legal-status\",\"values\":{\"tradingName\":\"VB Application for Test Classes\",\"companyType\":\"L\",\"taxIdVATNumber1\":\"GST/1456784\",\"taxIdVATNumber2\":\"QST/96314-778\",\"businessRegistration\":\"123\",\"inOperationsSince\":\"2020-06-01\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"ShareholderDetails\":{\"cmpName\":\"shareholder-details\",\"target\":\"NA\",\"values\":[{\"percentage\":90,\"type\":\"Company\",\"name\":\"Bottas Limited Partnership\",\"email\":\"bottas@tids.iata.org\",\"id\":\"a7B4E0000001ZdHUAU\"},{\"percentage\":10,\"type\":\"Person\",\"name\":\"Bottas Family\",\"email\":\"bottasfamily@tids.iata.org\",\"id\":\"a7B4E0000001ZdIUAU\"}],\"sectionDecision\":\"NA\"},\"Address\":{\"values\":{\"address\":\"15 Rue Papineau West\",\"city\":\"Montréal\",\"state\":{\"label\":\"Quebec\"},\"postalCode\":\"H2V4T8\",\"countryIsoCode\":\"Canada\",\"virtualCountryOfOperations\":{\"Id\":\"@countryId\",\"label\":\"Australia\",\"value\":\"AU\"}}},\"Mailing\":{\"sectionName\":\"Mailing\",\"cmpName\":\"mailing\",\"values\":{\"isMailingSameAsPhysicalAddress\":\"true\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"Contact\":{\"sectionName\":\"Contact\",\"cmpName\":\"contact\",\"values\":{\"preferedLanguage\":\"ENG\",\"phone\":\"1574301895\",\"fax\":\"154115615\",\"businessEmail\":\"vb@tids.iata.org\",\"webSite\":\"www.iata.org/tids/vb\",\"omFirstName\":\"Mr\",\"omLastName\":\"VB\"},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"BusinessProfile\":{\"sectionName\":\"Business Profile\",\"cmpName\":\"business-profile\",\"values\":{\"principalActivities\":{\"fieldName\":\"principalActivities\",\"values\":[{\"label\":\"Online Travel Agency\",\"value\":\"OL\"}]},\"marketFocus\":{\"fieldName\":\"marketFocus\",\"values\":[{\"label\":\"Leisure\",\"value\":\"100\"},{\"label\":\"Corporate\",\"value\":null}]},\"salesMix\":{\"fieldName\":\"salesMix\",\"values\":[{\"label\":\"Online\",\"value\":\"100\"},{\"label\":\"Offline\",\"value\":null}]},\"travelSales\":{},\"GDS\":{\"fieldName\":\"GDS\",\"values\":[{\"label\":\"Abacus\",\"value\":\"ABAC\"},{\"label\":\"Worldspan\",\"value\":\"WSPN\"},{\"label\":\"Travelsky\",\"value\":\"MINS\"}]},\"numberEmployees\":{\"fieldName\":\"numberEmployees\",\"values\":\"1\"},\"numberOffices\":{}},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"BusinessSpecialization\":{\"sectionName\":\"Business Specialization\",\"cmpName\":\"business-specialization\",\"values\":{\"percentageBreakdown\":{\"fieldName\":\"percentageBreakdown\",\"values\":[{\"id\":null,\"label\":\"Accommodation\",\"value\":\"50\",\"isSelected\":\"false\"},{\"id\":\"1\",\"label\":\"Air Travel\",\"value\":\"50\",\"isSelected\":\"false\"},{\"id\":\"2\",\"label\":\"Cruises\",\"value\":null,\"isSelected\":\"false\"},{\"id\":\"3\",\"label\":\"Land Transportation\",\"value\":null,\"isSelected\":\"false\"},{\"id\":\"4\",\"label\":\"Meetings & Events\",\"value\":null,\"isSelected\":\"false\"},{\"id\":\"5\",\"label\":\"Tours & Packages\",\"value\":null,\"isSelected\":\"false\"}]},\"marketSpecialties\":{\"fieldName\":\"marketSpecialties\",\"values\":[{\"label\":\"Conference/Exhibitions\",\"value\":\"CF\"},{\"label\":\"Educational\",\"value\":\"ED\"},{\"label\":\"Ethnic\",\"value\":\"ET\"}]},\"destinationSpecialties\":{\"fieldName\":\"destinationSpecialties\",\"values\":[{\"label\":\"France\",\"value\":\"FR\"},{\"label\":\"General\",\"value\":\"AL\"},{\"label\":\"Caribbean\",\"value\":\"CB\"}]}},\"sectionDecision\":\"Not_Started\",\"errors\":[]},\"SupportingDocuments\":{\"sectionName\":\"Supporting Documents\",\"cmpName\":\"supporting-documents\",\"values\":[],\"sectionDecision\":\"Not_Started\",\"errors\":[]}},\"sectionsDone\":[{\"id\":0,\"sectionName\":\"agency-legal-status\",\"next\":\"mailing\"},{\"id\":1,\"sectionName\":\"mailing\",\"next\":\"contact\"},{\"id\":2,\"sectionName\":\"contact\",\"next\":\"business-profile\"},{\"id\":3,\"sectionName\":\"business-profile\",\"next\":\"business-specialization\"},{\"id\":4,\"sectionName\":\"business-specialization\",\"next\":\"supporting-documents\"},{\"id\":5,\"sectionName\":\"supporting-documents\",\"next\":\"submit-application\"}]}';
        	applicationsettings=applicationReplace(applicationsettings);
			reason='Last TIDS Application has been Approved and this case is now Closed';
			TIDS_Controller.updateCaseStatus(
				applicationDecision,
				userType,
				applicationType,
				String.ValueOf(caseId),
				applicationsettings,
				reason);
        //	}catch(Exception e) {
        //		errorMessage = e.getMessage();
        //	}
        //}
        Test.stopTest();
        //System.assertEquals(true, errorMessage == '', 'Inserting account contact role with group record type should be allowed!');
	}
	//TIDS – Virtual Branch Relinquishment
	//{reason}
	//TIDS – Branch Office Reinstatement
	//{reason}

	@IsTest
    private static void saveandContactApplicant() {
        Test.startTest();
        String errorMessage = '';
        //System.runAs(testUser) {
        //	try{
			String applicationDecision;
			String userType='client';
			String applicationType='TIDS - Change of Address or Contact Details';
			String applicationsettings;
			String reason='';
			//
			readObjectsId();
			applicationsettings ='{\"applicationDecision\":\"Application_Errors\",\"userType\":\"vetting\",\"applicationType\":\"chg-address-contact\",\"userInfo\":{\"UserName\":\"Luc Debono\",\"UserId\":\"0054E000005CGEoQAO\",\"ContactId\":\"0034E000012JGhAQAW\",\"tidsAccount\":{\"Location_Type\":\"HO\",\"Id\":\"0014E00001BcLuGQAV\",\"Country_ISO_Code\":\"CA\",\"RecordType\":{\"Name\":null,\"Id\":null}}},\"businessRules\":{\"Name\":\"TIDS\",\"Id\":\"a2w4E000000DaNDQA0\",\"TIDS_Total_Ownership_Minimum\":\"95\",\"TIDS_Total_Ownership_Maximum\":\"101\"},\"tidsCase\":{\"Id\":\"5004E00000CzhMCQAZ\"},\"sections\":{\"Welcome\":{\"cmpName\":\"new-applicant\",\"target\":\"NA\",\"values\":{\"companyLegalName\":\"Bottas Racing Inc.\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"a0n4E000001Ql2zQAC\"},\"sectionDecision\":\"NA\",\"vettingErrors\":[]},\"AgencyLegalStatus\":{},\"ShareholderDetails\":{},\"Address\":{\"sectionName\":\"Address\",\"cmpName\":\"address\",\"values\":{\"address\":\"15 Rue Papineau East\",\"city\":\"Montréal\",\"citygeonameId\":\"aCX4E00000001rEWAQ\",\"state\":{\"Id\":\"a444E000000IsvnQAC\",\"label\":\"Quebec\",\"value\":\"CA-QC\"},\"postalCode\":\"H2V4T8\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"a0n4E000001Ql2zQAC\"},\"sectionDecision\":\"Error_Reported\",\"errors\":[{\"show\":true,\"description\":\"Comment 3\",\"fieldName\":\"address\",\"fieldLabel\":\"Address\"},{\"show\":true,\"description\":\"Comment 2\",\"fieldName\":\"city\",\"fieldLabel\":\"City\"},{\"show\":true,\"description\":\"Comment 1\",\"fieldName\":\"state\",\"fieldLabel\":\"State / Province\"},{\"show\":true,\"description\":\"Comment 4\",\"fieldName\":\"postalCode\",\"fieldLabel\":\"Postal Code\"}]},\"Mailing\":{\"sectionName\":\"Mailing\",\"cmpName\":\"mailing\",\"values\":{\"isMailingSameAsPhysicalAddress\":\"false\",\"mailingAddress\":\"33 Expedia Avenue\",\"city\":\"Seattle\",\"citygeonameId\":\"aCX4E00000001rJWAQ\",\"state\":{\"Id\":\"a444E000000DQzpQAG\",\"label\":\"Washington\",\"value\":\"US-WA\"},\"postalCode\":\"98888\",\"countryName\":\"United States\",\"countryIsoCode\":\"US\",\"countryId\":\"a0n4E0000018PutQAE\"},\"sectionDecision\":\"Error_Reported\",\"errors\":[{\"fieldLabel\":\"Address\",\"fieldName\":\"mailingAddress\",\"show\":true,\"description\":\"Comment 8\"},{\"fieldLabel\":\"City\",\"fieldName\":\"city\",\"show\":true,\"description\":\"Comment 7\"},{\"fieldLabel\":\"State / Province\",\"fieldName\":\"state\",\"show\":true,\"description\":\"Comment 6\"},{\"fieldLabel\":\"Postal Code\",\"fieldName\":\"postalCode\",\"show\":true,\"description\":\"Comment 9\"},{\"fieldLabel\":\"Country\",\"fieldName\":\"country\",\"show\":true,\"description\":\"Comment 5\"}]},\"Contact\":{\"sectionName\":\"Contact\",\"cmpName\":\"contact\",\"values\":{\"preferedLanguage\":\"ENG\",\"phone\":\"15148740202\",\"fax\":\"999888777\",\"businessEmail\":\"lorem@ipsum.com\",\"webSite\":\"www.loremipsum.com\",\"omFirstName\":\"Lorem\",\"omLastName\":\"Ipsum\"},\"sectionDecision\":\"Error_Reported\",\"errors\":[{\"show\":true,\"description\":\"Comment 10\",\"fieldName\":\"phone\",\"fieldLabel\":\"Phone Number\"},{\"show\":true,\"description\":\"Comment 11\",\"fieldName\":\"fax\",\"fieldLabel\":\"Fax Number\"},{\"show\":true,\"description\":\"Comment 12\",\"fieldName\":\"businessEmail\",\"fieldLabel\":\"Business Email address\"},{\"show\":true,\"description\":\"Comment 13\",\"fieldName\":\"website\",\"fieldLabel\":\"Web Site\"},{\"show\":true,\"description\":\"Comment 14\",\"fieldName\":\"omFirstName\",\"fieldLabel\":\"Office Manager - First Name\"},{\"show\":true,\"description\":\"Comment 15\",\"fieldName\":\"omLastName\",\"fieldLabel\":\"Office Manager - Last Name\"},{\"show\":true,\"description\":\"Comment 16\",\"fieldName\":\"preferedLanguage\",\"fieldLabel\":\"Prefered language of correspondance\"}]},\"BusinessProfile\":{},\"BusinessSpecialization\":{},\"SupportingDocuments\":{}},\"sectionsDone\":[{\"id\":0,\"sectionName\":\"address\",\"next\":\"mailing\"},{\"id\":1,\"sectionName\":\"mailing\",\"next\":\"contact\"},{\"id\":2,\"sectionName\":\"contact\",\"next\":\"submit-application\"}]}';
			caseId = TIDSHelper.saveSettings(
								accountId,
								applicationsettings,
								applicationtype,
								null);
			
			Case mycase = [Select Id, ContactId,Status From Case Where Id=:caseId limit 1];
			mycase.ContactId= contactId;
			update mycase;
			//Return to drat for the case
			//mycase.Status='Draft';
			//update mycase;
			//Vetting Approved
			applicationDecision='Contact Applicant';
			applicationsettings='{\"applicationDecision\":\"Application_Errors\",\"userType\":\"vetting\",\"applicationType\":\"chg-address-contact\",\"userInfo\":{\"UserName\":\"Abdellah Abdellah Bellahssan\",\"UserId\":\"@userId\",\"ContactId\":\"@contactId\",\"tidsAccount\":{\"Location_Type\":\"HO\",\"Id\":\"@accountId\",\"Country_ISO_Code\":\"CA\",\"RecordType\":{\"Name\":null,\"Id\":null}}},\"businessRules\":{\"Name\":\"TIDS\",\"Id\":\"@caseId\",\"TIDS_Total_Ownership_Minimum\":\"95\",\"TIDS_Total_Ownership_Maximum\":\"101\"},\"tidsCase\":{\"Id\":\"@caseId\"},\"sections\":{\"Welcome\":{\"cmpName\":\"new-applicant\",\"target\":\"NA\",\"values\":{\"companyLegalName\":\"Bottas Racing Inc.\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"NA\",\"vettingErrors\":[]},\"AgencyLegalStatus\":{},\"ShareholderDetails\":{},\"Address\":{\"sectionName\":\"Address\",\"cmpName\":\"address\",\"values\":{\"address\":\"15 Rue Papineau East\",\"city\":\"Montréal\",\"citygeonameId\":\"@cityId\",\"state\":{\"Id\":\"@stateId\",\"label\":\"Quebec\",\"value\":\"CA-QC\"},\"postalCode\":\"H2V4T8\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Error_Reported\",\"errors\":[{\"show\":true,\"description\":\"Comment 3\",\"fieldName\":\"address\",\"fieldLabel\":\"Address\"},{\"show\":true,\"description\":\"Comment 2\",\"fieldName\":\"city\",\"fieldLabel\":\"City\"},{\"show\":true,\"description\":\"Comment 1\",\"fieldName\":\"state\",\"fieldLabel\":\"State / Province\"},{\"show\":true,\"description\":\"Comment 4\",\"fieldName\":\"postalCode\",\"fieldLabel\":\"Postal Code\"}]},\"Mailing\":{\"sectionName\":\"Mailing\",\"cmpName\":\"mailing\",\"values\":{\"isMailingSameAsPhysicalAddress\":\"false\",\"mailingAddress\":\"33 Expedia Avenue\",\"city\":\"Seattle\",\"citygeonameId\":\"@cityId\",\"state\":{\"Id\":\"@stateId\",\"label\":\"Washington\",\"value\":\"US-WA\"},\"postalCode\":\"98888\",\"countryName\":\"United States\",\"countryIsoCode\":\"US\",\"countryId\":\"@countryId\"},\"sectionDecision\":\"Error_Reported\",\"errors\":[{\"fieldLabel\":\"Address\",\"fieldName\":\"mailingAddress\",\"show\":true,\"description\":\"Comment 8\"},{\"fieldLabel\":\"City\",\"fieldName\":\"city\",\"show\":true,\"description\":\"Comment 7\"},{\"fieldLabel\":\"State / Province\",\"fieldName\":\"state\",\"show\":true,\"description\":\"Comment 6\"},{\"fieldLabel\":\"Postal Code\",\"fieldName\":\"postalCode\",\"show\":true,\"description\":\"Comment 9\"},{\"fieldLabel\":\"Country\",\"fieldName\":\"country\",\"show\":true,\"description\":\"Comment 5\"}]},\"Contact\":{\"sectionName\":\"Contact\",\"cmpName\":\"contact\",\"values\":{\"preferedLanguage\":\"ENG\",\"phone\":\"15148740202\",\"fax\":\"999888777\",\"businessEmail\":\"lorem@ipsum.com\",\"webSite\":\"www.loremipsum.com\",\"omFirstName\":\"Lorem\",\"omLastName\":\"Ipsum\"},\"sectionDecision\":\"Error_Reported\",\"errors\":[{\"show\":true,\"description\":\"Comment 10\",\"fieldName\":\"phone\",\"fieldLabel\":\"Phone Number\"},{\"show\":true,\"description\":\"Comment 11\",\"fieldName\":\"fax\",\"fieldLabel\":\"Fax Number\"},{\"show\":true,\"description\":\"Comment 12\",\"fieldName\":\"businessEmail\",\"fieldLabel\":\"Business Email address\"},{\"show\":true,\"description\":\"Comment 13\",\"fieldName\":\"website\",\"fieldLabel\":\"Web Site\"},{\"show\":true,\"description\":\"Comment 14\",\"fieldName\":\"omFirstName\",\"fieldLabel\":\"Office Manager - First Name\"},{\"show\":true,\"description\":\"Comment 15\",\"fieldName\":\"omLastName\",\"fieldLabel\":\"Office Manager - Last Name\"},{\"show\":true,\"description\":\"Comment 16\",\"fieldName\":\"preferedLanguage\",\"fieldLabel\":\"Prefered language of correspondance\"}]},\"BusinessProfile\":{},\"BusinessSpecialization\":{},\"SupportingDocuments\":{}},\"sectionsDone\":[{\"id\":0,\"sectionName\":\"address\",\"next\":\"mailing\"},{\"id\":1,\"sectionName\":\"mailing\",\"next\":\"contact\"},{\"id\":2,\"sectionName\":\"contact\",\"next\":\"submit-application\"}]}';
			
			applicationsettings=applicationReplace(applicationsettings);
			reason='Last TIDS Application has been Approved and this case is now Closed';
			TIDSHelper.contactApplicant(
				String.ValueOf(caseId),
				'Pending customer',
				applicationsettings
			);
			
        //	}catch(Exception e) {
        //		errorMessage = e.getMessage();
        //	}
        //}
        Test.stopTest();
        //System.assertEquals(true, errorMessage == '', 'Inserting account contact role with group record type should be allowed!');
	}
	@IsTest
    private static void saveandVetting() {
        Test.startTest();
        String errorMessage = '';
        //System.runAs(testUser) {
        //	try{
			String applicationDecision;
			String userType='client';
			String applicationType='TIDS - Change of Address or Contact Details';
			String applicationsettings;
			String reason='';
			//
			readObjectsId();
			applicationsettings ='{\"applicationDecision\":\"Application_Errors\",\"userType\":\"vetting\",\"applicationType\":\"chg-address-contact\",\"userInfo\":{\"UserName\":\"Luc Debono\",\"UserId\":\"0054E000005CGEoQAO\",\"ContactId\":\"0034E000012JGhAQAW\",\"tidsAccount\":{\"Location_Type\":\"HO\",\"Id\":\"0014E00001BcLuGQAV\",\"Country_ISO_Code\":\"CA\",\"RecordType\":{\"Name\":null,\"Id\":null}}},\"businessRules\":{\"Name\":\"TIDS\",\"Id\":\"a2w4E000000DaNDQA0\",\"TIDS_Total_Ownership_Minimum\":\"95\",\"TIDS_Total_Ownership_Maximum\":\"101\"},\"tidsCase\":{\"Id\":\"5004E00000CzhMCQAZ\"},\"sections\":{\"Welcome\":{\"cmpName\":\"new-applicant\",\"target\":\"NA\",\"values\":{\"companyLegalName\":\"Bottas Racing Inc.\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"a0n4E000001Ql2zQAC\"},\"sectionDecision\":\"NA\",\"vettingErrors\":[]},\"AgencyLegalStatus\":{},\"ShareholderDetails\":{},\"Address\":{\"sectionName\":\"Address\",\"cmpName\":\"address\",\"values\":{\"address\":\"15 Rue Papineau East\",\"city\":\"Montréal\",\"citygeonameId\":\"aCX4E00000001rEWAQ\",\"state\":{\"Id\":\"a444E000000IsvnQAC\",\"label\":\"Quebec\",\"value\":\"CA-QC\"},\"postalCode\":\"H2V4T8\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"a0n4E000001Ql2zQAC\"},\"sectionDecision\":\"Error_Reported\",\"errors\":[{\"show\":true,\"description\":\"Comment 3\",\"fieldName\":\"address\",\"fieldLabel\":\"Address\"},{\"show\":true,\"description\":\"Comment 2\",\"fieldName\":\"city\",\"fieldLabel\":\"City\"},{\"show\":true,\"description\":\"Comment 1\",\"fieldName\":\"state\",\"fieldLabel\":\"State / Province\"},{\"show\":true,\"description\":\"Comment 4\",\"fieldName\":\"postalCode\",\"fieldLabel\":\"Postal Code\"}]},\"Mailing\":{\"sectionName\":\"Mailing\",\"cmpName\":\"mailing\",\"values\":{\"isMailingSameAsPhysicalAddress\":\"false\",\"mailingAddress\":\"33 Expedia Avenue\",\"city\":\"Seattle\",\"citygeonameId\":\"aCX4E00000001rJWAQ\",\"state\":{\"Id\":\"a444E000000DQzpQAG\",\"label\":\"Washington\",\"value\":\"US-WA\"},\"postalCode\":\"98888\",\"countryName\":\"United States\",\"countryIsoCode\":\"US\",\"countryId\":\"a0n4E0000018PutQAE\"},\"sectionDecision\":\"Error_Reported\",\"errors\":[{\"fieldLabel\":\"Address\",\"fieldName\":\"mailingAddress\",\"show\":true,\"description\":\"Comment 8\"},{\"fieldLabel\":\"City\",\"fieldName\":\"city\",\"show\":true,\"description\":\"Comment 7\"},{\"fieldLabel\":\"State / Province\",\"fieldName\":\"state\",\"show\":true,\"description\":\"Comment 6\"},{\"fieldLabel\":\"Postal Code\",\"fieldName\":\"postalCode\",\"show\":true,\"description\":\"Comment 9\"},{\"fieldLabel\":\"Country\",\"fieldName\":\"country\",\"show\":true,\"description\":\"Comment 5\"}]},\"Contact\":{\"sectionName\":\"Contact\",\"cmpName\":\"contact\",\"values\":{\"preferedLanguage\":\"ENG\",\"phone\":\"15148740202\",\"fax\":\"999888777\",\"businessEmail\":\"lorem@ipsum.com\",\"webSite\":\"www.loremipsum.com\",\"omFirstName\":\"Lorem\",\"omLastName\":\"Ipsum\"},\"sectionDecision\":\"Error_Reported\",\"errors\":[{\"show\":true,\"description\":\"Comment 10\",\"fieldName\":\"phone\",\"fieldLabel\":\"Phone Number\"},{\"show\":true,\"description\":\"Comment 11\",\"fieldName\":\"fax\",\"fieldLabel\":\"Fax Number\"},{\"show\":true,\"description\":\"Comment 12\",\"fieldName\":\"businessEmail\",\"fieldLabel\":\"Business Email address\"},{\"show\":true,\"description\":\"Comment 13\",\"fieldName\":\"website\",\"fieldLabel\":\"Web Site\"},{\"show\":true,\"description\":\"Comment 14\",\"fieldName\":\"omFirstName\",\"fieldLabel\":\"Office Manager - First Name\"},{\"show\":true,\"description\":\"Comment 15\",\"fieldName\":\"omLastName\",\"fieldLabel\":\"Office Manager - Last Name\"},{\"show\":true,\"description\":\"Comment 16\",\"fieldName\":\"preferedLanguage\",\"fieldLabel\":\"Prefered language of correspondance\"}]},\"BusinessProfile\":{},\"BusinessSpecialization\":{},\"SupportingDocuments\":{}},\"sectionsDone\":[{\"id\":0,\"sectionName\":\"address\",\"next\":\"mailing\"},{\"id\":1,\"sectionName\":\"mailing\",\"next\":\"contact\"},{\"id\":2,\"sectionName\":\"contact\",\"next\":\"submit-application\"}]}';
			caseId = TIDSHelper.saveSettings(
								accountId,
								applicationsettings,
								applicationtype,
								null);
			
			Case mycase = [Select Id, ContactId,Status,Subject,Reason1__c From Case Where Id=:caseId limit 1];
			mycase.ContactId= contactId;
			mycase.Status='Draft';
			mycase.Subject='TIDS – Virtual Branch Access Request';
			update mycase;
			
			ApexPages.StandardController sc1 = new ApexPages.standardController(mycase);
			TIDSVetting newvetting1 = new TIDSVetting(sc1);
			newvetting1.getRequestCase();
			newvetting1.isVirtualBranchRequest=false;
			newvetting1.approveRequest();
			newvetting1.rejectRequest();

			mycase.ContactId= contactId;
			mycase.Status='Draft';
			mycase.Reason1__c='TIDS – Relinquishment';
			update mycase;

			ApexPages.StandardController sc2 = new ApexPages.standardController(mycase);
			TIDSVetting newvetting2 = new TIDSVetting(sc2);
			newvetting2.getRequestCase();
			
			newvetting2.isVirtualBranchRequest=true;
			newvetting2.isRelinquishRequest=false;
			newvetting2.isReinstateRequest=false;
			newvetting2.approveRequest();
			newvetting2.isRelinquishRequest=true;
			newvetting2.isVirtualBranchRequest=false;
			newvetting2.isReinstateRequest=false;		
			newvetting2.approveRequest();
			newvetting2.isReinstateRequest=true;
			newvetting2.isVirtualBranchRequest=false;
			newvetting2.isRelinquishRequest=false;
			newvetting2.approveRequest();

			mycase.Status='Draft';
			mycase.Reason1__c='TIDS – Reinstatement';
			update mycase;

			ApexPages.StandardController sc3 = new ApexPages.standardController(mycase);
			TIDSVetting newvetting3 = new TIDSVetting(sc3);
			newvetting3.getRequestCase();
			
			newvetting3.isVirtualBranchRequest=true;
			newvetting3.isRelinquishRequest=false;
			newvetting3.isReinstateRequest=false;
			newvetting3.rejectRequest();
			newvetting3.isRelinquishRequest=true;
			newvetting3.isVirtualBranchRequest=false;
			newvetting3.isReinstateRequest=false;		
			newvetting3.rejectRequest();
			newvetting3.isReinstateRequest=true;
			newvetting3.isVirtualBranchRequest=false;
			newvetting3.isRelinquishRequest=false;
			newvetting3.rejectRequest();

			//	}catch(Exception e) {
        //		errorMessage = e.getMessage();
        //	}
        //}
        Test.stopTest();
        //System.assertEquals(true, errorMessage == '', 'Inserting account contact role with group record type should be allowed!');
	}
	@IsTest
    private static void TIDSobject() {

	    Test.startTest();
    	TIDS_Controller.vTIDS tids = new TIDS_Controller.vTIDS();
		tids.userInfo = new TIDS_Controller.vuserInfo();
		tids.sections = new TIDS_Controller.vsections();
		tids.sectionsDone = new List<TIDS_Controller.vsectionsDone>();
		tids.businessRules = new TIDS_Controller.vbusinessRules();
		tids.tidscase = new TIDS_Controller.vcase();
		tids.applicationType='';
		tids.userType='';
		TIDS_Controller.vslabel nl = new TIDS_Controller.vslabel('TIDS','TIDS');
		TIDS_Controller.verror nv = new TIDS_Controller.verror();
		nv.fieldLabel='';
		nv.fieldName='';
		nv.description='';
		TIDS_Controller.vsectionsDone nsd = new  TIDS_Controller.vsectionsDone();
		nsd.id='';
		nsd.sectionName='';
		nsd.next='';
		tids.sectionsDone.add(nsd);
		
		tids.sections.Welcome = new TIDS_Controller.sWelcome();
		tids.sections.AgencyLegalStatus = new TIDS_Controller.sAgencyLegalStatus();
		tids.sections.ShareholderDetails = new TIDS_Controller.sShareholderDetails();
		tids.sections.Address = new TIDS_Controller.sAddress();
		tids.sections.Mailing = new TIDS_Controller.sMailing();
		tids.sections.Contact = new TIDS_Controller.sContact();
		tids.sections.BusinessProfile = new TIDS_Controller.sBusinessProfile();
		tids.sections.BusinessSpecialization = new TIDS_Controller.sBusinessSpecialization();
		tids.sections.SupportingDocuments = new TIDS_Controller.sSupportingDocuments();
		
		tids.sections.SupportingDocuments.cmpName='';
		tids.sections.SupportingDocuments.sectionName='';
		tids.sections.SupportingDocuments.values = new List<TIDS_Controller.vslabel>{nl};
		tids.sections.SupportingDocuments.errors = new List<TIDS_Controller.verror>{nv};
		tids.sections.SupportingDocuments.sectionDecision='';
		tids.sections.BusinessSpecialization.sectionName='';
		tids.sections.BusinessSpecialization.errors = new List<TIDS_Controller.verror>{nv};
		tids.sections.BusinessSpecialization.values = new TIDS_Controller.vBusinessSpecialization();
		
		
		tids.sections.BusinessSpecialization.values.percentageBreakdown = new TIDS_Controller.spercentageBreakdown();
		tids.sections.BusinessSpecialization.values.marketSpecialties = new TIDS_Controller.smarketSpecialties();
		tids.sections.BusinessSpecialization.values.destinationSpecialties = new TIDS_Controller.sdestinationSpecialties();

		TIDS_Controller.vslabel vsl = new TIDS_Controller.vslabel('TIDS', 'TIDS');
		TIDS_Controller.vsfields vsf = new TIDS_Controller.vsfields();
		vsf.fieldName='';
		vsf.values = new List<TIDS_Controller.vslabel>{vsl};

		TIDS_Controller.vnfields vnf = new TIDS_Controller.vnfields();
		vnf.fieldName='';
		vnf.values = '';

		TIDS_Controller.smarketSpecialties smk = new TIDS_Controller.smarketSpecialties();
		smk.fieldName='';
		smk.values = new List<TIDS_Controller.vslabel>{vsl};

		TIDS_Controller.sdestinationSpecialties sdt = new TIDS_Controller.sdestinationSpecialties(); 
		sdt.fieldName='';
		sdt.values = new List<TIDS_Controller.vslabel>{vsl};
			
		
		TIDS_Controller.spercentageBreakdown  sp = new TIDS_Controller.spercentageBreakdown();
		sp.fieldName='percentageBreakdown';
		sp.values = new List<TIDS_Controller.vslabel>{vsl};

		TIDS_Controller.sBusinessProfile sbp = new TIDS_Controller.sBusinessProfile();
		sbp.cmpName='';
		sbp.sectionName='';
		sbp.sectionDecision='';
		sbp.values = new TIDS_Controller.vBusinessProfile();
		sbp.errors = new List<TIDS_Controller.verror>{nv};
		
		TIDS_Controller.vBusinessProfile vbp = new TIDS_Controller.vBusinessProfile();
		vbp.principalActivities = new TIDS_Controller.vsfields();
		vbp.marketFocus = new TIDS_Controller.vsfields();
		vbp.salesMix = new TIDS_Controller.vsfields();
		vbp.travelSales = new TIDS_Controller.vnfields();
		vbp.gds = new TIDS_Controller.vsfields();
		vbp.numberEmployees = new TIDS_Controller.vnfields();
		vbp.numberOffices = new TIDS_Controller.vnfields();
		
		TIDS_Controller.sBusinessSpecialization vbs = new TIDS_Controller.sBusinessSpecialization();
		vbs.sectionName='';
		vbs.errors = new List<TIDS_Controller.verror>{nv};
		vbs.values= new TIDS_Controller.vBusinessSpecialization();
		
		TIDS_Controller.vuserInfo  vui = new TIDS_Controller.vuserInfo();
		vui.Id=null;
		vui.Name='';
		vui.ContactId='';
		vui.AccountId='';
		vui.tidsAccount = new TIDS_Controller.vAccount();
		
		TIDS_Controller.vAccount vacc = new TIDS_Controller.vAccount();
		vacc.RecordTypeId='';
		vacc.Country_ISO_Code='';
		vacc.Id='';
		vacc.RecordType = new TIDS_Controller.vRecordType();
		
		TIDS_Controller.vRecordType vrt = new TIDS_Controller.vRecordType();
		vrt.Name='';
		vrt.Id='';
		
		
		TIDS_Controller.vbusinessRules vbrl= new TIDS_Controller.vbusinessRules();
		vbrl.TIDS_Reinstatement_Window=0;
		vbrl.Name='';
		vbrl.TIDS_Total_Ownership_Minimum=0;
		vbrl.TIDS_Total_Ownership_Maximum=0;
		vbrl.Id='';
		
		TIDS_Controller.vcase vce = new TIDS_Controller.vcase();
		vce.id='';
		
		TIDS_Controller.sWelcome swl = new TIDS_Controller.sWelcome();
		swl.cmpName='';
		swl.sectionName='';
		swl.sectionDecision='';
		swl.values = new TIDS_Controller.vWelcome();
		swl.errors = new List<TIDS_Controller.verror>();
			
		
		TIDS_Controller.vWelcome vwl = new TIDS_Controller.vWelcome();
		vwl.companyLegalName='';
		vwl.countryIsoCode='';
		vwl.countryName='';
		vwl.countryId='';
		
		
		TIDS_Controller.sAgencyLegalStatus sals = new TIDS_Controller.sAgencyLegalStatus();
		sals.cmpName='';
		sals.sectionName='';
		sals.sectionDecision='';
		sals.values = new TIDS_Controller.vAgencyLegalStatus();
		sals.errors = new List<TIDS_Controller.verror>();
			
		
		TIDS_Controller.vAgencyLegalStatus vals = new TIDS_Controller.vAgencyLegalStatus();
		vals.tradingName='';
		vals.companyType='';
		vals.taxIdVATNumber1='';
		vals.taxIdVATNumber2='';
		vals.businessRegistration='';
		vals.inOperationsSince='';
		
		
		TIDS_Controller.sShareholderDetails  sshd = new TIDS_Controller.sShareholderDetails();
		sshd.cmpName='';
		sshd.sectionName='';
		sshd.sectionDecision='';
		sshd.values = new List<TIDS_Controller.vShareholderDetails>();
		sshd.errors = new List<TIDS_Controller.verror>();
		
		
		TIDS_Controller.vShareholderDetails vshd =new TIDS_Controller.vShareholderDetails();
		vshd.type='';
		vshd.name='';
		vshd.percentage='';
		vshd.email='';
		vshd.id='';
		vshd.action='';
		
		
		TIDS_Controller.sAddress sadd = new TIDS_Controller.sAddress();
		sadd.cmpName='';
		sadd.sectionName='';
		sadd.sectionDecision='';
		sadd.values = new TIDS_Controller.vAddress();
		sadd.errors = new List<TIDS_Controller.verror>();
		
		TIDS_Controller.vAddress vadd=new TIDS_Controller.vAddress();
		vadd.address='';
		vadd.city='';
		//vadd.state='';
		vadd.postalCode='';
		vadd.country='';
		vadd.countryName='';
		vadd.countryIsoCode='';
		vadd.countryId='';
		vadd.citygeonameId='';
		vadd.virtualCountryOfOperations =new TIDS_Controller.vvirtualCountryOfOperations();
		vadd.state = new TIDS_Controller.vstate();
		
		TIDS_Controller.vvirtualCountryOfOperations vvco = new TIDS_Controller.vvirtualCountryOfOperations();
		vvco.countryid='';
		vvco.label='';
		vvco.value='';
		
		TIDS_Controller.vstate vstt = new TIDS_Controller.vstate();
		vstt.label='';
		vstt.value='';
		vstt.Id='';
		
		TIDS_Controller.sMailing smal =new TIDS_Controller.sMailing();
		smal.cmpName='';
		smal.sectionName='';
		smal.sectionDecision='';
		smal.values = new TIDS_Controller.vMailing();
		smal.errors = new List<TIDS_Controller.verror>();
		
		TIDS_Controller.vMailing vmal = new TIDS_Controller.vMailing();
		vmal.isMailingSameAsPhysicalAddress='';
		vmal.mailingAddress='';
		vmal.mailingOption='';
		vmal.otherAddress='';
		vmal.city='';
		vmal.postalCode='';
		vmal.country='';
		vmal.countryName='';
		vmal.countryIsoCode='';
		vmal.countryId='';
		vmal.citygeonameId='';
		vmal.state = new TIDS_Controller.vstate();
			
		TIDS_Controller.sContact sctt=new TIDS_Controller.sContact();
		sctt.cmpName='';
		sctt.sectionName='';
		sctt.sectionDecision='';
		sctt.values = new TIDS_Controller.vContact();
		sctt.errors = new List<TIDS_Controller.verror>();
			
		TIDS_Controller.vContact vctt = new TIDS_Controller.vContact();
		vctt.preferedLanguage='';
		vctt.phone='';
		vctt.fax='';
		vctt.businessEmail='';
		vctt.webSite='';
		vctt.omFirstName='';
		vctt.omLastName='';
		Test.stopTest();
		
	}
	@IsTest
    private static void TIDSHelperFunction1() {
	    Test.startTest();
    	String applicationType='ho';
		String reason='TIDS is a good reason';
		String payload='TIDS';
	
		readObjectsId();
	
		TIDSHelper.getAdmin(String.ValueOf(accountId));
		TIDSHelper.createTidsRequestReinstate(String.ValueOf(accountId),reason, applicationType);
		TIDSHelper.createTidsRequestRelinquish(String.ValueOf(accountId),reason, applicationType);
		TIDSHelper.createTidsRequestVirtualBranch(String.ValueOf(accountId),payload);
		TIDSHelper.createTidsCaseNewBranch(String.ValueOf(accountId),payload);
		TIDSHelper.createTidsCaseVirtualBranch(String.ValueOf(accountId),payload); 
		
		TIDSHelper.isTidsRequestPending(String.ValueOf(accountId), 'TIDS – Relinquishment');
		TIDSHelper.isTidsRequestPending(String.ValueOf(accountId), 'TIDS – Reinstatement');
		Test.stopTest();
			
	}
	@IsTest
    private static void TIDSHelperFunction2() {
	    Test.startTest();
    	String applicationType='ho';
		String reason='TIDS is a good reason';
		String payload='TIDS';
	
		readObjectsId();
	
		Account account = [Select Id, Status__c From Account Where Id=:accountId limit 1];
		account.Status__c='Terminated';
		update account;
		TIDSHelper.isTidsRequestPending(String.ValueOf(accountId), 'Terminated');
		GDP_Reference_Table__c gdpc = new GDP_Reference_Table__c();
		gdpc.Name='Terminated';
		gdpc.Code__c = 'T';
		insert gdpc;
		
		Accreditation__c accre = new Accreditation__c();
		accre.Class__c = gdpc.Id;
		accre.Termination_Date__c=System.Today();
		accre.Related_Account__c=accountId;
		insert accre;
		TIDSHelper.isTidsRequestPending(String.ValueOf(accountId), 'Terminated');
		accre.Termination_Date__c=System.Today().addDays(-1);
		update accre;
		TIDSHelper.isTidsRequestPending(String.ValueOf(accountId), 'Terminated');
		Test.stopTest();
	}

	@IsTest
    private static void sendEmail(){
		Test.startTest();
		
		String applicationDecision;
		String userType='client';
		String applicationType='TIDS - Change of Address or Contact Details';
		String applicationsettings;
		String reason='';
		//
		readObjectsId();
		applicationsettings ='{\"applicationDecision\":\"Application_Errors\",\"userType\":\"vetting\",\"applicationType\":\"chg-address-contact\",\"userInfo\":{\"UserName\":\"Luc Debono\",\"UserId\":\"0054E000005CGEoQAO\",\"ContactId\":\"0034E000012JGhAQAW\",\"tidsAccount\":{\"Location_Type\":\"HO\",\"Id\":\"0014E00001BcLuGQAV\",\"Country_ISO_Code\":\"CA\",\"RecordType\":{\"Name\":null,\"Id\":null}}},\"businessRules\":{\"Name\":\"TIDS\",\"Id\":\"a2w4E000000DaNDQA0\",\"TIDS_Total_Ownership_Minimum\":\"95\",\"TIDS_Total_Ownership_Maximum\":\"101\"},\"tidsCase\":{\"Id\":\"5004E00000CzhMCQAZ\"},\"sections\":{\"Welcome\":{\"cmpName\":\"new-applicant\",\"target\":\"NA\",\"values\":{\"companyLegalName\":\"Bottas Racing Inc.\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"a0n4E000001Ql2zQAC\"},\"sectionDecision\":\"NA\",\"vettingErrors\":[]},\"AgencyLegalStatus\":{},\"ShareholderDetails\":{},\"Address\":{\"sectionName\":\"Address\",\"cmpName\":\"address\",\"values\":{\"address\":\"15 Rue Papineau East\",\"city\":\"Montréal\",\"citygeonameId\":\"aCX4E00000001rEWAQ\",\"state\":{\"Id\":\"a444E000000IsvnQAC\",\"label\":\"Quebec\",\"value\":\"CA-QC\"},\"postalCode\":\"H2V4T8\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"a0n4E000001Ql2zQAC\"},\"sectionDecision\":\"Error_Reported\",\"errors\":[{\"show\":true,\"description\":\"Comment 3\",\"fieldName\":\"address\",\"fieldLabel\":\"Address\"},{\"show\":true,\"description\":\"Comment 2\",\"fieldName\":\"city\",\"fieldLabel\":\"City\"},{\"show\":true,\"description\":\"Comment 1\",\"fieldName\":\"state\",\"fieldLabel\":\"State / Province\"},{\"show\":true,\"description\":\"Comment 4\",\"fieldName\":\"postalCode\",\"fieldLabel\":\"Postal Code\"}]},\"Mailing\":{\"sectionName\":\"Mailing\",\"cmpName\":\"mailing\",\"values\":{\"isMailingSameAsPhysicalAddress\":\"false\",\"mailingAddress\":\"33 Expedia Avenue\",\"city\":\"Seattle\",\"citygeonameId\":\"aCX4E00000001rJWAQ\",\"state\":{\"Id\":\"a444E000000DQzpQAG\",\"label\":\"Washington\",\"value\":\"US-WA\"},\"postalCode\":\"98888\",\"countryName\":\"United States\",\"countryIsoCode\":\"US\",\"countryId\":\"a0n4E0000018PutQAE\"},\"sectionDecision\":\"Error_Reported\",\"errors\":[{\"fieldLabel\":\"Address\",\"fieldName\":\"mailingAddress\",\"show\":true,\"description\":\"Comment 8\"},{\"fieldLabel\":\"City\",\"fieldName\":\"city\",\"show\":true,\"description\":\"Comment 7\"},{\"fieldLabel\":\"State / Province\",\"fieldName\":\"state\",\"show\":true,\"description\":\"Comment 6\"},{\"fieldLabel\":\"Postal Code\",\"fieldName\":\"postalCode\",\"show\":true,\"description\":\"Comment 9\"},{\"fieldLabel\":\"Country\",\"fieldName\":\"country\",\"show\":true,\"description\":\"Comment 5\"}]},\"Contact\":{\"sectionName\":\"Contact\",\"cmpName\":\"contact\",\"values\":{\"preferedLanguage\":\"ENG\",\"phone\":\"15148740202\",\"fax\":\"999888777\",\"businessEmail\":\"lorem@ipsum.com\",\"webSite\":\"www.loremipsum.com\",\"omFirstName\":\"Lorem\",\"omLastName\":\"Ipsum\"},\"sectionDecision\":\"Error_Reported\",\"errors\":[{\"show\":true,\"description\":\"Comment 10\",\"fieldName\":\"phone\",\"fieldLabel\":\"Phone Number\"},{\"show\":true,\"description\":\"Comment 11\",\"fieldName\":\"fax\",\"fieldLabel\":\"Fax Number\"},{\"show\":true,\"description\":\"Comment 12\",\"fieldName\":\"businessEmail\",\"fieldLabel\":\"Business Email address\"},{\"show\":true,\"description\":\"Comment 13\",\"fieldName\":\"website\",\"fieldLabel\":\"Web Site\"},{\"show\":true,\"description\":\"Comment 14\",\"fieldName\":\"omFirstName\",\"fieldLabel\":\"Office Manager - First Name\"},{\"show\":true,\"description\":\"Comment 15\",\"fieldName\":\"omLastName\",\"fieldLabel\":\"Office Manager - Last Name\"},{\"show\":true,\"description\":\"Comment 16\",\"fieldName\":\"preferedLanguage\",\"fieldLabel\":\"Prefered language of correspondance\"}]},\"BusinessProfile\":{},\"BusinessSpecialization\":{},\"SupportingDocuments\":{}},\"sectionsDone\":[{\"id\":0,\"sectionName\":\"address\",\"next\":\"mailing\"},{\"id\":1,\"sectionName\":\"mailing\",\"next\":\"contact\"},{\"id\":2,\"sectionName\":\"contact\",\"next\":\"submit-application\"}]}';
		caseId = TIDSHelper.saveSettings(
								accountId,
								applicationsettings,
								applicationtype,
								null);
	
		String noreplyemail= 'noreply@iata.org';
		String emailto = 'nobody@iata.org';
        EmailMessageWrapper ew = new EmailMessageWrapper(noreplyemail,
											emailto,
                                            null,
                                            null,
                                            null,
                                            new map<string,string>(),
                                            null,
                                            new Map<String,String>()
											);
		TIDSUtil.sendMyEmail(new List<EmailMessageWrapper>{ew},'TIDS_NEW_USER', userId);
		TIDSUtil.sendNotification(String.ValueOf(caseId), String.ValueOf(contactId), 'mytemplate');
		TIDSUtil.getPicklistValues('LGLTYP','Code__c');
		TIDSUtil.saveFile(String.ValueOf(caseId),'data.json','json','erer',true);
		TIDSUtil.addAttachment(caseId, 'erer', 'data.json');
		TIDSUtil.relatedFiles(String.ValueOf(caseId));
		TIDSUtil.getAttachment(String.ValueOf(caseId), 'data.json');
		TIDSUtil.getSettings(String.ValueOf(caseId), 'json');

		TIDSUtil.getGDSValues();
		TIDSUtil.getNumberOfEmployees();
		TIDSUtil.getPreferedLanguages();
		TIDSUtil.getFocusValues();
		TIDSUtil.companyTypes();
		TIDSUtil.mainMarketSpecialization();
		TIDSUtil.principalDestination();
		TIDSUtil.salesVolume();
		TIDSUtil.mainActivity();
        TIDSUtil.ComposeMessage(null);
		TIDSUtil.deleteFiles(String.ValueOf(caseId));
		TIDSUtil.saveTidsConfiguration('TIDS', 'erer');
		TIDSUtil.getTidsConfiguration('TIDS');
		TIDSUtil.getTidsCases(String.ValueOf(caseId), true);
		
		Test.stopTest();
	}

	@IsTest
    private static void TidsBatchHelper() {
		Test.startTest();
    	String applicationDecision;
		String userType='client';
		String applicationType='TIDS - Change of Address or Contact Details';
		String applicationsettings;
		String reason='';
		//
		readObjectsId();
		applicationsettings ='{\"applicationDecision\":\"Application_Errors\",\"userType\":\"vetting\",\"applicationType\":\"chg-address-contact\",\"userInfo\":{\"UserName\":\"Luc Debono\",\"UserId\":\"0054E000005CGEoQAO\",\"ContactId\":\"0034E000012JGhAQAW\",\"tidsAccount\":{\"Location_Type\":\"HO\",\"Id\":\"0014E00001BcLuGQAV\",\"Country_ISO_Code\":\"CA\",\"RecordType\":{\"Name\":null,\"Id\":null}}},\"businessRules\":{\"Name\":\"TIDS\",\"Id\":\"a2w4E000000DaNDQA0\",\"TIDS_Total_Ownership_Minimum\":\"95\",\"TIDS_Total_Ownership_Maximum\":\"101\"},\"tidsCase\":{\"Id\":\"5004E00000CzhMCQAZ\"},\"sections\":{\"Welcome\":{\"cmpName\":\"new-applicant\",\"target\":\"NA\",\"values\":{\"companyLegalName\":\"Bottas Racing Inc.\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"a0n4E000001Ql2zQAC\"},\"sectionDecision\":\"NA\",\"vettingErrors\":[]},\"AgencyLegalStatus\":{},\"ShareholderDetails\":{},\"Address\":{\"sectionName\":\"Address\",\"cmpName\":\"address\",\"values\":{\"address\":\"15 Rue Papineau East\",\"city\":\"Montréal\",\"citygeonameId\":\"aCX4E00000001rEWAQ\",\"state\":{\"Id\":\"a444E000000IsvnQAC\",\"label\":\"Quebec\",\"value\":\"CA-QC\"},\"postalCode\":\"H2V4T8\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"a0n4E000001Ql2zQAC\"},\"sectionDecision\":\"Error_Reported\",\"errors\":[{\"show\":true,\"description\":\"Comment 3\",\"fieldName\":\"address\",\"fieldLabel\":\"Address\"},{\"show\":true,\"description\":\"Comment 2\",\"fieldName\":\"city\",\"fieldLabel\":\"City\"},{\"show\":true,\"description\":\"Comment 1\",\"fieldName\":\"state\",\"fieldLabel\":\"State / Province\"},{\"show\":true,\"description\":\"Comment 4\",\"fieldName\":\"postalCode\",\"fieldLabel\":\"Postal Code\"}]},\"Mailing\":{\"sectionName\":\"Mailing\",\"cmpName\":\"mailing\",\"values\":{\"isMailingSameAsPhysicalAddress\":\"false\",\"mailingAddress\":\"33 Expedia Avenue\",\"city\":\"Seattle\",\"citygeonameId\":\"aCX4E00000001rJWAQ\",\"state\":{\"Id\":\"a444E000000DQzpQAG\",\"label\":\"Washington\",\"value\":\"US-WA\"},\"postalCode\":\"98888\",\"countryName\":\"United States\",\"countryIsoCode\":\"US\",\"countryId\":\"a0n4E0000018PutQAE\"},\"sectionDecision\":\"Error_Reported\",\"errors\":[{\"fieldLabel\":\"Address\",\"fieldName\":\"mailingAddress\",\"show\":true,\"description\":\"Comment 8\"},{\"fieldLabel\":\"City\",\"fieldName\":\"city\",\"show\":true,\"description\":\"Comment 7\"},{\"fieldLabel\":\"State / Province\",\"fieldName\":\"state\",\"show\":true,\"description\":\"Comment 6\"},{\"fieldLabel\":\"Postal Code\",\"fieldName\":\"postalCode\",\"show\":true,\"description\":\"Comment 9\"},{\"fieldLabel\":\"Country\",\"fieldName\":\"country\",\"show\":true,\"description\":\"Comment 5\"}]},\"Contact\":{\"sectionName\":\"Contact\",\"cmpName\":\"contact\",\"values\":{\"preferedLanguage\":\"ENG\",\"phone\":\"15148740202\",\"fax\":\"999888777\",\"businessEmail\":\"lorem@ipsum.com\",\"webSite\":\"www.loremipsum.com\",\"omFirstName\":\"Lorem\",\"omLastName\":\"Ipsum\"},\"sectionDecision\":\"Error_Reported\",\"errors\":[{\"show\":true,\"description\":\"Comment 10\",\"fieldName\":\"phone\",\"fieldLabel\":\"Phone Number\"},{\"show\":true,\"description\":\"Comment 11\",\"fieldName\":\"fax\",\"fieldLabel\":\"Fax Number\"},{\"show\":true,\"description\":\"Comment 12\",\"fieldName\":\"businessEmail\",\"fieldLabel\":\"Business Email address\"},{\"show\":true,\"description\":\"Comment 13\",\"fieldName\":\"website\",\"fieldLabel\":\"Web Site\"},{\"show\":true,\"description\":\"Comment 14\",\"fieldName\":\"omFirstName\",\"fieldLabel\":\"Office Manager - First Name\"},{\"show\":true,\"description\":\"Comment 15\",\"fieldName\":\"omLastName\",\"fieldLabel\":\"Office Manager - Last Name\"},{\"show\":true,\"description\":\"Comment 16\",\"fieldName\":\"preferedLanguage\",\"fieldLabel\":\"Prefered language of correspondance\"}]},\"BusinessProfile\":{},\"BusinessSpecialization\":{},\"SupportingDocuments\":{}},\"sectionsDone\":[{\"id\":0,\"sectionName\":\"address\",\"next\":\"mailing\"},{\"id\":1,\"sectionName\":\"mailing\",\"next\":\"contact\"},{\"id\":2,\"sectionName\":\"contact\",\"next\":\"submit-application\"}]}';
		caseId = TIDSHelper.saveSettings(
								accountId,
								applicationsettings,
								applicationtype,
								null);
	
		TidsBatchHelper.testbatch(caseId);
		Test.stopTest();
	}
	@IsTest
    private static void TidsConditions() {
		Test.startTest();
    	String applicationDecision;
		String userType='client';
		String applicationType='TIDS - Change of Address or Contact Details';
		String applicationsettings;
		String reason='';
		//
		readObjectsId();
		applicationsettings ='{\"applicationDecision\":\"Application_Errors\",\"userType\":\"vetting\",\"applicationType\":\"chg-address-contact\",\"userInfo\":{\"UserName\":\"Luc Debono\",\"UserId\":\"0054E000005CGEoQAO\",\"ContactId\":\"0034E000012JGhAQAW\",\"tidsAccount\":{\"Location_Type\":\"HO\",\"Id\":\"0014E00001BcLuGQAV\",\"Country_ISO_Code\":\"CA\",\"RecordType\":{\"Name\":null,\"Id\":null}}},\"businessRules\":{\"Name\":\"TIDS\",\"Id\":\"a2w4E000000DaNDQA0\",\"TIDS_Total_Ownership_Minimum\":\"95\",\"TIDS_Total_Ownership_Maximum\":\"101\"},\"tidsCase\":{\"Id\":\"5004E00000CzhMCQAZ\"},\"sections\":{\"Welcome\":{\"cmpName\":\"new-applicant\",\"target\":\"NA\",\"values\":{\"companyLegalName\":\"Bottas Racing Inc.\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"a0n4E000001Ql2zQAC\"},\"sectionDecision\":\"NA\",\"vettingErrors\":[]},\"AgencyLegalStatus\":{},\"ShareholderDetails\":{},\"Address\":{\"sectionName\":\"Address\",\"cmpName\":\"address\",\"values\":{\"address\":\"15 Rue Papineau East\",\"city\":\"Montréal\",\"citygeonameId\":\"aCX4E00000001rEWAQ\",\"state\":{\"Id\":\"a444E000000IsvnQAC\",\"label\":\"Quebec\",\"value\":\"CA-QC\"},\"postalCode\":\"H2V4T8\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"a0n4E000001Ql2zQAC\"},\"sectionDecision\":\"Error_Reported\",\"errors\":[{\"show\":true,\"description\":\"Comment 3\",\"fieldName\":\"address\",\"fieldLabel\":\"Address\"},{\"show\":true,\"description\":\"Comment 2\",\"fieldName\":\"city\",\"fieldLabel\":\"City\"},{\"show\":true,\"description\":\"Comment 1\",\"fieldName\":\"state\",\"fieldLabel\":\"State / Province\"},{\"show\":true,\"description\":\"Comment 4\",\"fieldName\":\"postalCode\",\"fieldLabel\":\"Postal Code\"}]},\"Mailing\":{\"sectionName\":\"Mailing\",\"cmpName\":\"mailing\",\"values\":{\"isMailingSameAsPhysicalAddress\":\"false\",\"mailingAddress\":\"33 Expedia Avenue\",\"city\":\"Seattle\",\"citygeonameId\":\"aCX4E00000001rJWAQ\",\"state\":{\"Id\":\"a444E000000DQzpQAG\",\"label\":\"Washington\",\"value\":\"US-WA\"},\"postalCode\":\"98888\",\"countryName\":\"United States\",\"countryIsoCode\":\"US\",\"countryId\":\"a0n4E0000018PutQAE\"},\"sectionDecision\":\"Error_Reported\",\"errors\":[{\"fieldLabel\":\"Address\",\"fieldName\":\"mailingAddress\",\"show\":true,\"description\":\"Comment 8\"},{\"fieldLabel\":\"City\",\"fieldName\":\"city\",\"show\":true,\"description\":\"Comment 7\"},{\"fieldLabel\":\"State / Province\",\"fieldName\":\"state\",\"show\":true,\"description\":\"Comment 6\"},{\"fieldLabel\":\"Postal Code\",\"fieldName\":\"postalCode\",\"show\":true,\"description\":\"Comment 9\"},{\"fieldLabel\":\"Country\",\"fieldName\":\"country\",\"show\":true,\"description\":\"Comment 5\"}]},\"Contact\":{\"sectionName\":\"Contact\",\"cmpName\":\"contact\",\"values\":{\"preferedLanguage\":\"ENG\",\"phone\":\"15148740202\",\"fax\":\"999888777\",\"businessEmail\":\"lorem@ipsum.com\",\"webSite\":\"www.loremipsum.com\",\"omFirstName\":\"Lorem\",\"omLastName\":\"Ipsum\"},\"sectionDecision\":\"Error_Reported\",\"errors\":[{\"show\":true,\"description\":\"Comment 10\",\"fieldName\":\"phone\",\"fieldLabel\":\"Phone Number\"},{\"show\":true,\"description\":\"Comment 11\",\"fieldName\":\"fax\",\"fieldLabel\":\"Fax Number\"},{\"show\":true,\"description\":\"Comment 12\",\"fieldName\":\"businessEmail\",\"fieldLabel\":\"Business Email address\"},{\"show\":true,\"description\":\"Comment 13\",\"fieldName\":\"website\",\"fieldLabel\":\"Web Site\"},{\"show\":true,\"description\":\"Comment 14\",\"fieldName\":\"omFirstName\",\"fieldLabel\":\"Office Manager - First Name\"},{\"show\":true,\"description\":\"Comment 15\",\"fieldName\":\"omLastName\",\"fieldLabel\":\"Office Manager - Last Name\"},{\"show\":true,\"description\":\"Comment 16\",\"fieldName\":\"preferedLanguage\",\"fieldLabel\":\"Prefered language of correspondance\"}]},\"BusinessProfile\":{},\"BusinessSpecialization\":{},\"SupportingDocuments\":{}},\"sectionsDone\":[{\"id\":0,\"sectionName\":\"address\",\"next\":\"mailing\"},{\"id\":1,\"sectionName\":\"mailing\",\"next\":\"contact\"},{\"id\":2,\"sectionName\":\"contact\",\"next\":\"submit-application\"}]}';
		caseId = TIDSHelper.saveSettings(
								accountId,
								applicationsettings,
								applicationtype,
								null);
	
		TidsHelper.conditiontest(userId);
		Test.stopTest();
	}

	
	@IsTest
    private static void TidsRunBatchCleanse() {
		Test.startTest();
		String applicationDecision;
		String userType='client';
		String applicationType='TIDS - Change of Address or Contact Details';
		String applicationsettings;
		String reason='';
		//
		readObjectsId();
		applicationsettings ='{\"applicationDecision\":\"Application_Errors\",\"userType\":\"vetting\",\"applicationType\":\"chg-address-contact\",\"userInfo\":{\"UserName\":\"Luc Debono\",\"UserId\":\"0054E000005CGEoQAO\",\"ContactId\":\"0034E000012JGhAQAW\",\"tidsAccount\":{\"Location_Type\":\"HO\",\"Id\":\"0014E00001BcLuGQAV\",\"Country_ISO_Code\":\"CA\",\"RecordType\":{\"Name\":null,\"Id\":null}}},\"businessRules\":{\"Name\":\"TIDS\",\"Id\":\"a2w4E000000DaNDQA0\",\"TIDS_Total_Ownership_Minimum\":\"95\",\"TIDS_Total_Ownership_Maximum\":\"101\"},\"tidsCase\":{\"Id\":\"5004E00000CzhMCQAZ\"},\"sections\":{\"Welcome\":{\"cmpName\":\"new-applicant\",\"target\":\"NA\",\"values\":{\"companyLegalName\":\"Bottas Racing Inc.\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"a0n4E000001Ql2zQAC\"},\"sectionDecision\":\"NA\",\"vettingErrors\":[]},\"AgencyLegalStatus\":{},\"ShareholderDetails\":{},\"Address\":{\"sectionName\":\"Address\",\"cmpName\":\"address\",\"values\":{\"address\":\"15 Rue Papineau East\",\"city\":\"Montréal\",\"citygeonameId\":\"aCX4E00000001rEWAQ\",\"state\":{\"Id\":\"a444E000000IsvnQAC\",\"label\":\"Quebec\",\"value\":\"CA-QC\"},\"postalCode\":\"H2V4T8\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"a0n4E000001Ql2zQAC\"},\"sectionDecision\":\"Error_Reported\",\"errors\":[{\"show\":true,\"description\":\"Comment 3\",\"fieldName\":\"address\",\"fieldLabel\":\"Address\"},{\"show\":true,\"description\":\"Comment 2\",\"fieldName\":\"city\",\"fieldLabel\":\"City\"},{\"show\":true,\"description\":\"Comment 1\",\"fieldName\":\"state\",\"fieldLabel\":\"State / Province\"},{\"show\":true,\"description\":\"Comment 4\",\"fieldName\":\"postalCode\",\"fieldLabel\":\"Postal Code\"}]},\"Mailing\":{\"sectionName\":\"Mailing\",\"cmpName\":\"mailing\",\"values\":{\"isMailingSameAsPhysicalAddress\":\"false\",\"mailingAddress\":\"33 Expedia Avenue\",\"city\":\"Seattle\",\"citygeonameId\":\"aCX4E00000001rJWAQ\",\"state\":{\"Id\":\"a444E000000DQzpQAG\",\"label\":\"Washington\",\"value\":\"US-WA\"},\"postalCode\":\"98888\",\"countryName\":\"United States\",\"countryIsoCode\":\"US\",\"countryId\":\"a0n4E0000018PutQAE\"},\"sectionDecision\":\"Error_Reported\",\"errors\":[{\"fieldLabel\":\"Address\",\"fieldName\":\"mailingAddress\",\"show\":true,\"description\":\"Comment 8\"},{\"fieldLabel\":\"City\",\"fieldName\":\"city\",\"show\":true,\"description\":\"Comment 7\"},{\"fieldLabel\":\"State / Province\",\"fieldName\":\"state\",\"show\":true,\"description\":\"Comment 6\"},{\"fieldLabel\":\"Postal Code\",\"fieldName\":\"postalCode\",\"show\":true,\"description\":\"Comment 9\"},{\"fieldLabel\":\"Country\",\"fieldName\":\"country\",\"show\":true,\"description\":\"Comment 5\"}]},\"Contact\":{\"sectionName\":\"Contact\",\"cmpName\":\"contact\",\"values\":{\"preferedLanguage\":\"ENG\",\"phone\":\"15148740202\",\"fax\":\"999888777\",\"businessEmail\":\"lorem@ipsum.com\",\"webSite\":\"www.loremipsum.com\",\"omFirstName\":\"Lorem\",\"omLastName\":\"Ipsum\"},\"sectionDecision\":\"Error_Reported\",\"errors\":[{\"show\":true,\"description\":\"Comment 10\",\"fieldName\":\"phone\",\"fieldLabel\":\"Phone Number\"},{\"show\":true,\"description\":\"Comment 11\",\"fieldName\":\"fax\",\"fieldLabel\":\"Fax Number\"},{\"show\":true,\"description\":\"Comment 12\",\"fieldName\":\"businessEmail\",\"fieldLabel\":\"Business Email address\"},{\"show\":true,\"description\":\"Comment 13\",\"fieldName\":\"website\",\"fieldLabel\":\"Web Site\"},{\"show\":true,\"description\":\"Comment 14\",\"fieldName\":\"omFirstName\",\"fieldLabel\":\"Office Manager - First Name\"},{\"show\":true,\"description\":\"Comment 15\",\"fieldName\":\"omLastName\",\"fieldLabel\":\"Office Manager - Last Name\"},{\"show\":true,\"description\":\"Comment 16\",\"fieldName\":\"preferedLanguage\",\"fieldLabel\":\"Prefered language of correspondance\"}]},\"BusinessProfile\":{},\"BusinessSpecialization\":{},\"SupportingDocuments\":{}},\"sectionsDone\":[{\"id\":0,\"sectionName\":\"address\",\"next\":\"mailing\"},{\"id\":1,\"sectionName\":\"mailing\",\"next\":\"contact\"},{\"id\":2,\"sectionName\":\"contact\",\"next\":\"submit-application\"}]}';
		caseId = TIDSHelper.saveSettings(
								accountId,
								applicationsettings,
								applicationtype,
								null);

		TidsBatchCleanseCases obj = new  TidsBatchCleanseCases();
		DataBase.executeBatch(obj); 
		Test.stopTest();
	}

	@IsTest
    private static void TidsRunBatchCleanse2() {
		Test.startTest();
		String applicationDecision;
		String userType='client';
		String applicationType='TIDS - Change of Address or Contact Details';
		String applicationsettings;
		String reason='';
		//
		readObjectsId();
		applicationsettings ='{\"applicationDecision\":\"Application_Errors\",\"userType\":\"vetting\",\"applicationType\":\"chg-address-contact\",\"userInfo\":{\"UserName\":\"Luc Debono\",\"UserId\":\"0054E000005CGEoQAO\",\"ContactId\":\"0034E000012JGhAQAW\",\"tidsAccount\":{\"Location_Type\":\"HO\",\"Id\":\"0014E00001BcLuGQAV\",\"Country_ISO_Code\":\"CA\",\"RecordType\":{\"Name\":null,\"Id\":null}}},\"businessRules\":{\"Name\":\"TIDS\",\"Id\":\"a2w4E000000DaNDQA0\",\"TIDS_Total_Ownership_Minimum\":\"95\",\"TIDS_Total_Ownership_Maximum\":\"101\"},\"tidsCase\":{\"Id\":\"5004E00000CzhMCQAZ\"},\"sections\":{\"Welcome\":{\"cmpName\":\"new-applicant\",\"target\":\"NA\",\"values\":{\"companyLegalName\":\"Bottas Racing Inc.\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"a0n4E000001Ql2zQAC\"},\"sectionDecision\":\"NA\",\"vettingErrors\":[]},\"AgencyLegalStatus\":{},\"ShareholderDetails\":{},\"Address\":{\"sectionName\":\"Address\",\"cmpName\":\"address\",\"values\":{\"address\":\"15 Rue Papineau East\",\"city\":\"Montréal\",\"citygeonameId\":\"aCX4E00000001rEWAQ\",\"state\":{\"Id\":\"a444E000000IsvnQAC\",\"label\":\"Quebec\",\"value\":\"CA-QC\"},\"postalCode\":\"H2V4T8\",\"countryName\":\"Canada\",\"countryIsoCode\":\"CA\",\"countryId\":\"a0n4E000001Ql2zQAC\"},\"sectionDecision\":\"Error_Reported\",\"errors\":[{\"show\":true,\"description\":\"Comment 3\",\"fieldName\":\"address\",\"fieldLabel\":\"Address\"},{\"show\":true,\"description\":\"Comment 2\",\"fieldName\":\"city\",\"fieldLabel\":\"City\"},{\"show\":true,\"description\":\"Comment 1\",\"fieldName\":\"state\",\"fieldLabel\":\"State / Province\"},{\"show\":true,\"description\":\"Comment 4\",\"fieldName\":\"postalCode\",\"fieldLabel\":\"Postal Code\"}]},\"Mailing\":{\"sectionName\":\"Mailing\",\"cmpName\":\"mailing\",\"values\":{\"isMailingSameAsPhysicalAddress\":\"false\",\"mailingAddress\":\"33 Expedia Avenue\",\"city\":\"Seattle\",\"citygeonameId\":\"aCX4E00000001rJWAQ\",\"state\":{\"Id\":\"a444E000000DQzpQAG\",\"label\":\"Washington\",\"value\":\"US-WA\"},\"postalCode\":\"98888\",\"countryName\":\"United States\",\"countryIsoCode\":\"US\",\"countryId\":\"a0n4E0000018PutQAE\"},\"sectionDecision\":\"Error_Reported\",\"errors\":[{\"fieldLabel\":\"Address\",\"fieldName\":\"mailingAddress\",\"show\":true,\"description\":\"Comment 8\"},{\"fieldLabel\":\"City\",\"fieldName\":\"city\",\"show\":true,\"description\":\"Comment 7\"},{\"fieldLabel\":\"State / Province\",\"fieldName\":\"state\",\"show\":true,\"description\":\"Comment 6\"},{\"fieldLabel\":\"Postal Code\",\"fieldName\":\"postalCode\",\"show\":true,\"description\":\"Comment 9\"},{\"fieldLabel\":\"Country\",\"fieldName\":\"country\",\"show\":true,\"description\":\"Comment 5\"}]},\"Contact\":{\"sectionName\":\"Contact\",\"cmpName\":\"contact\",\"values\":{\"preferedLanguage\":\"ENG\",\"phone\":\"15148740202\",\"fax\":\"999888777\",\"businessEmail\":\"lorem@ipsum.com\",\"webSite\":\"www.loremipsum.com\",\"omFirstName\":\"Lorem\",\"omLastName\":\"Ipsum\"},\"sectionDecision\":\"Error_Reported\",\"errors\":[{\"show\":true,\"description\":\"Comment 10\",\"fieldName\":\"phone\",\"fieldLabel\":\"Phone Number\"},{\"show\":true,\"description\":\"Comment 11\",\"fieldName\":\"fax\",\"fieldLabel\":\"Fax Number\"},{\"show\":true,\"description\":\"Comment 12\",\"fieldName\":\"businessEmail\",\"fieldLabel\":\"Business Email address\"},{\"show\":true,\"description\":\"Comment 13\",\"fieldName\":\"website\",\"fieldLabel\":\"Web Site\"},{\"show\":true,\"description\":\"Comment 14\",\"fieldName\":\"omFirstName\",\"fieldLabel\":\"Office Manager - First Name\"},{\"show\":true,\"description\":\"Comment 15\",\"fieldName\":\"omLastName\",\"fieldLabel\":\"Office Manager - Last Name\"},{\"show\":true,\"description\":\"Comment 16\",\"fieldName\":\"preferedLanguage\",\"fieldLabel\":\"Prefered language of correspondance\"}]},\"BusinessProfile\":{},\"BusinessSpecialization\":{},\"SupportingDocuments\":{}},\"sectionsDone\":[{\"id\":0,\"sectionName\":\"address\",\"next\":\"mailing\"},{\"id\":1,\"sectionName\":\"mailing\",\"next\":\"contact\"},{\"id\":2,\"sectionName\":\"contact\",\"next\":\"submit-application\"}]}';
		caseId = TIDSHelper.saveSettings(
								accountId,
								applicationsettings,
								applicationtype,
								null);

		TidsBatchCleanseCases obj = new  TidsBatchCleanseCases();
		String chron = '0 0 23 * * ?';        
        String jobid = System.schedule('testScheduledApex', chron, obj);
        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];
        System.assertEquals(chron,ct.CronExpression);
		Test.stopTest();
	}
	 
	@IsTest
    private static void TidsRunBatchRelinquish() {
		Test.startTest();
		TidsBatchRelinquishment obj  =new TidsBatchRelinquishment();
		DataBase.executeBatch(obj); 
		Test.stopTest();
	}		
}	
@isTest
private class AMS_OSCARTriggerHandlerTest {
    
    @testSetup static void setup(){
        
        AMS_ChangeCodes__c cc = new AMS_ChangeCodes__c(Name = 'OOT', Change_Code__c = 'OOT', Billable__c = false, Integration_RecId__c='C', Billable_Location_Class__c = 'P');
        insert cc;

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US',ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account acc = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HE',Name='Agency HE',Short_Name__c='Agency HE', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert acc;

        //Case:
        Map<String,Object> fieldsOfObject = new Map<String,Object>();

        fieldsOfObject.put('Account_Concerned__c',acc.Id);
        fieldsOfObject.put('BSPCountry__c',acc.BillingCountry);
        fieldsOfObject.put('Region__c',acc.Region_formula__c);
        fieldsOfObject.put('CaseArea__c','Accreditation Process');
        fieldsOfObject.put('Origin','Internal User');
        fieldsOfObject.put('Reason1__c','Annual revalidation');
        fieldsOfObject.put('Subject','Annual revalidation - ' + acc.ANG_Accreditation_Model__c + ' - ' + acc.Name);
        fieldsOfObject.put('Type_of_customer__c','IATA Travel Agent');
        
        Case cse = ANG_EntityCreator.createCase(AMS_Utils.RECTYPE_OSCARCOMM, acc.Id, fieldsOfObject);
        insert cse;

        //StagingArea:
        fieldsOfObject = new Map<String,Object>();

        fieldsOfObject.put('Abbreviated_Address__c',acc.Abbreviated_address__c);
        fieldsOfObject.put('Abbreviated_name__c',acc.Abbreviated_name__c);
        fieldsOfObject.put('Accept_terms_and_conditions__c',true);
        fieldsOfObject.put('Account_Name__c',acc.Name);
        fieldsOfObject.put('Billing_State__c',acc.BillingState);
        fieldsOfObject.put('Branch_Office_City__c',acc.BillingCity);
        fieldsOfObject.put('Branch_Office_Country__c',acc.IATA_ISO_Country__c);
        fieldsOfObject.put('Branch_Office_Email__c',acc.Email__c);
        fieldsOfObject.put('Branch_Office_FAX__c',acc.Fax);
        fieldsOfObject.put('Branch_Office_Phone__c',acc.Phone);
        fieldsOfObject.put('Branch_Office_Postal_code__c',acc.BillingPostalCode);
        fieldsOfObject.put('Branch_Office_Street_name_number__c',acc.BillingStreet);
        fieldsOfObject.put('CASS_Number__c',acc.CASS_Number__c);
        fieldsOfObject.put('HO_Account__c',acc.Id);
        fieldsOfObject.put('IATACode__c',acc.IATACode__c);
        fieldsOfObject.put('IATA_ISO_State__c',acc.Iso_State__c);
        fieldsOfObject.put('ISSP_AMS_GDS_with_signed_contract__c',acc.GDS__c);
        fieldsOfObject.put('ISSP_AMS_Legal_Status__c',AMS_Utils.transformLegalStatus(acc.Company_Type__c));
        fieldsOfObject.put('ISSP_AMS_License_No__c',acc.License_Number__c);
        fieldsOfObject.put('ISSP_AMS_VAT_number__c',acc.VAT_Number__c);
        fieldsOfObject.put('Is_your_firm_handling_Dangerous_Goods__c',acc.Is_your_firm_handling_Dangerous_Goods__c);
        fieldsOfObject.put('Link_agent_name__c',acc.Id);
        fieldsOfObject.put('Location_Class__c',acc.Location_Class__c);
        fieldsOfObject.put('Location_Type__c',acc.Location_Type__c);
        fieldsOfObject.put('Mobile__c',acc.Mobile__c);
        fieldsOfObject.put('Operation__c',acc.Operation__c);
        fieldsOfObject.put('Remittance_frequency__c',acc.Remittance_frequency__c);
        fieldsOfObject.put('Shipping_City__c',acc.ShippingCity);
        fieldsOfObject.put('Shipping_Country__c',acc.ShippingCountry);
        fieldsOfObject.put('Shipping_ISO_Country__c',acc.IATA_ISO_Shipping_Country__c);
        fieldsOfObject.put('Shipping_ISO_State__c',acc.IATA_ISO_Shipping_State__c);
        fieldsOfObject.put('Shipping_Postal_Code__c',acc.ShippingPostalCode);
        fieldsOfObject.put('Shipping_State__c',acc.ShippingState);
        fieldsOfObject.put('Shipping_Street__c',acc.ShippingStreet);
        fieldsOfObject.put('Short_Name__c',acc.Short_Name__c);
        fieldsOfObject.put('Solicitation_Flag__c',acc.Solicitation_Flag__c);
        fieldsOfObject.put('Trade_Name__c',acc.TradeName__c);
        fieldsOfObject.put('VAT_Number_2__c',acc.VAT_Number_2__c);
        fieldsOfObject.put('Website__c',acc.Website);

        AMS_Pax_Accreditation_Form__c stagingArea = ANG_EntityCreator.createStagingArea(
            Schema.AMS_Pax_Accreditation_Form__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('New Gen Changes').getRecordTypeId(), acc.Id, cse.Id, fieldsOfObject);

        insert stagingArea;

        fieldsOfObject = new Map<String,Object>();

        //AMS_OSCAR__c:
        fieldsOfObject.put('Process__c',AMS_Utils.NGOPTINOUT);
        fieldsOfObject.put('Status__c','Open');
        fieldsOfObject.put('AMS_Online_Accreditation__c',stagingArea.Id);
        fieldsOfObject.put('ANG_FA_Opt_out__c','Opt-Out');

        AMS_Oscar__c oscar = ANG_EntityCreator.createOscar(AMS_Utils.RECTYPE_NEWGENOPTINOUT, acc.Id, fieldsOfObject);       
        insert oscar;

        cse.Oscar__c = oscar.Id;

        update cse;

        // Create a new Financial Institution
        Financial_Institution__c fi = new Financial_Institution__c(Name = 'Test FI', Region__c = 'Americas', Country__c = 'Canada', Institution_Type__c = 'Bank');
        insert fi;

        // Create a new Financial Security
        Financial_Security__c fs = new Financial_Security__c(Region__c = 'Americas', Security_status__c = 'Active', Account__c = acc.Id, CurrencyIsoCode = 'USD', Amount__c = 100,
                        Expiry_date__c = Date.today().addYears(2), Financial_Institution__c = fi.Id, Security_Type__c = 'Cross Border Guarantee', 
                        ValIdity_Start_Date__c = Date.today().addDays(-2), Reception_Case__c = cse.Id, Reception_Date__c = Date.today(), Reasonforrequest__c = 'New Application');
        insert fs;

        Agency_Applied_Change_code__c aacc1 = new Agency_Applied_Change_code__c(Account__c = acc.Id, Change_Code__c = 'FIN',  Sent_to_external_system__c = false, Active__c = true);
        insert aacc1;

    }

    @isTest static void processOscarOptinoutTest1() {

        Test.startTest();


        List<String> fieldListOscar = new List<String>();

        Map<String, Schema.SObjectField> schemaFieldMapOscars = AMS_OSCAR__c.sObjectType.getDescribe().fields.getMap();

        for (String field : schemaFieldMapOscars.keySet()){
                    fieldListOscar.add(field);
        }

        String query = 'SELECT '+ String.join(fieldListOscar, ', ') + ' FROM AMS_OSCAR__c LIMIT 1';

        List<AMS_Oscar__c> oscars =  Database.query(query);

        

        AMS_Oscar__c oscar = oscars.get(0);

        oscar.STEP1__c = 'Passed';

        update oscar;

        Test.stopTest();
    }

    @isTest static void testANGEmailTemplates() {

        Test.startTest();

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            insert new EmailTemplate(
                isActive = true,
                Name = 'ANG_Financial_Assesment_Opt_out_DIS_English',
                DeveloperName = 'ANG_Financial_Assesment_Opt_out_DIS_English',
                TemplateType = 'text',
                FolderId = UserInfo.getUserId()
            );
        }
        AMS_OSCARTriggerHandler.ANGemailTemplates(AMS_Utils.NGOPTINOUT, AMS_Utils.FAILED, false);

        Test.stopTest();
        
    }

    @isTest static void testFOPOSCAR() {

        AMS_ChangeCodes__c ccConfig = new AMS_ChangeCodes__c(
        Name = 'CCR',
        Change_Code__c = 'CCR',
        Reason_Code__c = '',
        Bulletin_Memo_Text__c ='Agent has complied to Agency Rules. Card payment methods are reinstated.',
        Published_in_bulletin__c = true,
        Integration_RecId__c = 'C',
        Reason_Code_Description__c = 'test',
        Account_status_change__c = '');

        insert ccConfig;

        List<IATA_ISO_Country__c> countrylist = new List<IATA_ISO_Country__c>();
        IATA_ISO_Country__c isoc1 = new IATA_ISO_Country__c(Name = 'Test1', ISO_Code__c = 'TS', 
                                                            Region__c = 'Americas', 
                                                            Case_BSP_Country__c= 'Canada'
                                                            );
        countrylist.add(isoc1);
        insert countrylist;
        
        List<Account> agencylist = new List<Account>();
        Account a1 = new Account(Name='Test1 Agency',
            IATA_ISO_Country__c = isoc1.id, Sent_to_external_system__c = true, 
            IATACode__c = '12345678', 
            Location_Class__c= AMS_Utils.LC_PASSENGER,
            Status__c= AMS_Utils.ACC_S9_APPROVED,
            RecordTypeId= AMS_Utils.RECTYPE_IATAAGENCY,
            Is_PCI_compliant__c = null,
            Location_Type__c = AMS_Utils.HO
            );
        agencylist.add(a1);
        insert agencylist;

        Agency_Applied_Change_code__c aChangeCode = new Agency_Applied_Change_code__c(Change_Code__c = 'FIN', Account__c = a1.Id, Reason_Description__c = 'ACCREDITED–MEETS–STANDARDS',  Reason_Code__c= '91', Active__c = true);
        insert aChangeCode;

        Agency_Authorization__c fop = new Agency_Authorization__c(Account__c = a1.Id, ANG_FormOfPayment_ID__c = 'CC', Status__c = 'Non-Active', 
                    RecordTypeId = Schema.Agency_Authorization__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Form Of Payment').getRecordTypeId());

        insert fop;

        Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', 
                                    Email = 'test@test.com', BSP_CASS_Payment_contact__c = true, User_Portal_Status__c = 'Approved Admin',
                                    Preferred_Language__c = 'English', Financial_Assessment_Contact__c = false);    
        insert co1;
         
        Test.startTest();

        Map<String,Object> fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.clear();
        fieldsOfObject.put('Process__c',AMS_Utils.NGFOP);
        fieldsOfObject.put('RecordTypeId',AMS_Utils.RECTYPE_NEWGENFOP);
        fieldsOfObject.put('ANG_FA_Opt_out__c','Not Applicable');

        AMS_Oscar__c oscar = ANG_EntityCreator.createOscar(AMS_Utils.RECTYPE_NEWGENFOP, agencylist[0].Id, fieldsOfObject);
        insert oscar;
        
        Id caseRT = AMS_Utils.getId('Case', 'OSCAR_Communication');

        fieldsOfObject.clear();
        fieldsOfObject.put('Oscar__c',oscar.Id);
        fieldsOfObject.put('BSPCountry__c',agencylist[0].BillingCountry);
        fieldsOfObject.put('CaseArea__c','Accreditation Process');
        fieldsOfObject.put('Origin','Portal');
        fieldsOfObject.put('Reason1__c','FoP Management');
        fieldsOfObject.put('Subject','FoP Management - ');
        fieldsOfObject.put('Type_of_customer__c','IATA Travel Agent');
        //fieldsOfObject.put('ContactId',co1.Id); - force error

        Case newCaseFop =ANG_EntityCreator.createCase(caseRT, agencylist[0].Id, fieldsOfObject);

        insert newCaseFop;
        
        oscar.STEP40__c = AMS_Utils.PASSED;
        oscar.ANG_Sanity_checks__c = AMS_Utils.PASSED;   

        try{
            update oscar;            
        }catch (Exception e){
            System.assert(e.getMessage().contains('In order to pass this step you need to check the Is PCI compliant field.'));
        }

        oscar.Is_PCI_compliant__c = 'Yes';

        try{
            update oscar;            
        }catch (Exception e){
            System.assert(e.getMessage().contains('For PCI compliance, you need to add an expiry date.'));
        }      

        oscar.ANG_PCI_compliance_expiry_date__c = Date.today();

        update oscar;

        System.assertEquals(Date.today(),[SELECT Id, ANG_PCI_compliance_expiry_date__c FROM Account WHERE ID = :a1.Id].ANG_PCI_compliance_expiry_date__c);

        Test.stopTest();
    }
    
}
@isTest
private class ANG_MasterData_Interface_test {
        private static final integer HTTP_STATUS_OK = 200;
        private static final integer HTTP_STATUS_BAD_REQUEST = 400;
        private static final integer HTTP_NOT_FOUND = 404;
        private static final integer HTTP_MULTIPLE_FOUND = 300;

	@testSetup static void testSetup(){

                IATA_ISO_Country__c isoCntr1 = new IATA_ISO_Country__c(Name = 'Portugal', Region__c = 'Europe', ISO_Code__c='PT', ANG_Enable_NewGen__c = true);
                
                IATA_ISO_Country__c ukCountry = new IATA_ISO_Country__c(
                    Name = 'United Kingdom', 
                    CurrencyIsoCode = 'EUR', 
                    ISO_Code_Numeric__c = 999, 
                    ISO_Code__c = 'UK',
                    AIMS_Area_ID__c='1',
                    ANG_Enable_NewGen__c = true,
                    ANG_IEP_Model__c = 'Model B+'
            	);

                insert new List<IATA_ISO_Country__c>{isoCntr1, ukCountry};

                Account acc = new Account(
                        name='acc1',
                        Location_Type__c=AMS_Utils.HE,
                        Location_Class__c= AMS_Utils.LC_PASSENGER,
                        Remittance_frequency__c=ANG_Risk_Helper.REMITTANCE_FREQUENCY_MONTHLY,
                        ANG_Accreditation_Model__c =AMS_Utils.ACCREDITATIONMODEL_CASH,
                        recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY,
                        IATACode__c ='123',
                        Accreditation_date__c = Date.valueOf('2017-01-01'),
                        IATA_ISO_Country__c = isoCntr1.Id
                );

                Account acc1 = new Account(
                        name='acc2',
                        Location_Type__c=AMS_Utils.HE,
                        Location_Class__c= AMS_Utils.LC_PASSENGER,
                        Remittance_frequency__c=ANG_Risk_Helper.REMITTANCE_FREQUENCY_MONTHLY,
                        ANG_Accreditation_Model__c =AMS_Utils.ACCREDITATIONMODEL_CASH,
                        recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY,
                        IATACode__c ='999',
                        Accreditation_date__c = Date.valueOf('2017-01-01'),
                        IATA_ISO_Country__c = isoCntr1.Id
                );

                Account acc2 = new Account(
                        name='acc2',
                        Location_Type__c=AMS_Utils.HE,
                        Location_Class__c= AMS_Utils.LC_PASSENGER,
                        Remittance_frequency__c=ANG_Risk_Helper.REMITTANCE_FREQUENCY_MONTHLY,
                        ANG_Accreditation_Model__c =AMS_Utils.ACCREDITATIONMODEL_CASH,
                        recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY,
                        IATACode__c ='999',
                        Accreditation_date__c = Date.valueOf('2017-01-01'),
                        IATA_ISO_Country__c = isoCntr1.Id
                );

                Account acc3 = new Account(
                        Name ='UK Test', 
                        Type = 'IATA Passenger Sales Agent',
                        Sector__c='Travel Agent', 
                        Location_Type__c = AMS_Utils.HE,
                        Location_Class__c = 'P',
                        ANG_FA_Opt_out__c = false,
                        IATACode__c='12345699',
                        IATA_ISO_Country__c = ukCountry.Id,
                        BillingCountry='UK Test',
                        ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
                        Status__c = AMS_Utils.ACC_S9_APPROVED,
                        ANG_HE_RiskHistoryAssessment__c = ANG_Risk_Helper.RISK_ASSESSMENT_PASSED,
                        Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY,
                        RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
                        ANG_IEP_Status__c = 'In Progress'
                );

                insert new list<account>{acc,acc1,acc2,acc3};

                Account accChild = new Account(
                        ParentId = acc.id,
                        name='acc3',
                        Location_Type__c=AMS_Utils.HE,
                        Location_Class__c= AMS_Utils.LC_PASSENGER,
                        Remittance_frequency__c=ANG_Risk_Helper.REMITTANCE_FREQUENCY_MONTHLY,
                        ANG_Accreditation_Model__c =AMS_Utils.ACCREDITATIONMODEL_CASH,
                        recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY,
                        IATACode__c ='12223',
                        IATA_ISO_Country__c = isoCntr1.Id,
                        Is_PCI_Compliant__c = 'Yes',
                        ANG_IEP_Status__c = 'Open'
                );

                insert accChild;

                Agency_Authorization__c agAurthRec = new Agency_Authorization__c(
                        Account__c= acc.id,
                        Email_Used_for_BSP_Creation__c ='asd@iata.org',
                        Last_Request_Result__c ='testRequestResult',
                        status__c = 'Active',
                        ANG_FormOfPayment_ID__c='CC',
                        recordtypeId =  RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c','BSPLink'),
                        Unique_Identifier__c='aa'
                );

                Agency_Authorization__c agAurthRec2 = new Agency_Authorization__c(
                        Account__c= accChild.id,
                        Email_Used_for_BSP_Creation__c ='as5d@iata.org',
                        recordtypeId =  RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c','FormOfPayment'),
                        Last_Request_Result__c ='testRequestResult',
                        status__c = 'Active',
                        ANG_FormOfPayment_ID__c='CC',
                        Unique_Identifier__c='bbb'
                );
                insert new list<Agency_Authorization__c>{agAurthRec,agAurthRec2};

                ANG_RHC_Information__c rhcRec = new ANG_RHC_Information__c(
                        ANG_AccountId__c = acc.id,
                        ANG_Financial_Security__c = 20000,
                        ANG_RHC_Amount__c = 20000,
                        CurrencyIsoCode = 'USD'
                );
                insert rhcRec;

                Contact con1 = new Contact(
                        LastName = 'Uk Test LN',
                        Email = 'uktest@istest.newgen', 
                        Preferred_Language__c = 'English',
                        BSP_CASS_Payment_contact__c = true, 
                        Financial_Assessment_Contact__c = true, 
                        AccountId = acc3.Id
                );

                insert con1;

                List<Portal_Applications__c> pas = new List<Portal_Applications__c>();
                pas.add(new Portal_Applications__c(Name = 'IATA EasyPay (EDENRED)'));
                pas.add(new Portal_Applications__c(Name = 'IATA EasyPay (MSTS)'));
                insert pas;

                Portal_Application_Right__c par = new Portal_Application_Right__c(
                        Right__c = 'Access Granted', 
                        ANG_Portal_Service_Role__c = 'IEP Admin', 
                        Portal_Application__c = pas[0].Id, 
                        Contact__c = con1.Id 
                );

                insert par;

	}

        private static RestResponse doCallOutToWS(String iataCode,Boolean getChildren, String changeCode){
                RestRequest request = new RestRequest(); 
                RestResponse response = new RestResponse();
                
                request.requestURI = '/ANG_GetMasterData/'+iataCode;  
                request.httpMethod = 'GET';
                if(getChildren)  request.addParameter('mode', 'f');
                if(String.isNotBlank(changeCode)) request.addParameter('ChangeCode', changeCode);

                RestContext.request = request;
                RestContext.response = response;
                ANG_MasterData_Interface.doGet();

                return response;
        }

        private static RestResponse doCallOutToWS(String iataCode,Boolean getChildren){
                return doCallOutToWS(iataCode, getChildren, null);
        }

        static testmethod void testHTTPrequestToWebserviceSuccess (){
              
                RestResponse response = doCallOutToWS('12223',false);
                System.assertEquals(HTTP_STATUS_OK, response.statusCode);
        }

         static testmethod void testHTTPrequestToWebserviceSuccessWithChilds (){

                RestResponse response = doCallOutToWS('123',true);
                System.assertEquals(HTTP_STATUS_OK, response.statusCode);
        }

        static testmethod void testHTTPrequestToWebserviceUnsuccessNoAccountForIATACode (){
               
                RestResponse response = doCallOutToWS('888',true);
                System.assertEquals(HTTP_NOT_FOUND, response.statusCode);      
        }

        static testmethod void testHTTPrequestToWebserviceUnsuccessMultipleAccountMatch(){
               
                RestResponse response = doCallOutToWS('999',false);
                System.assertEquals(HTTP_MULTIPLE_FOUND, response.statusCode); 
        }


        static testmethod void testHTTPrequestToWebserviceUnsuccessNoCodeSent(){
               
                
                RestResponse response = doCallOutToWS('',false);
                System.assertEquals(HTTP_STATUS_BAD_REQUEST, response.statusCode);       
        }
        
        @isTest static void dueDiligenceModelBPlusTest(){
                
            Account acct = 
                [SELECT 
                    Id,
                    Name,
                    IATACode__c,
                    BillingCountry,
                    Region_formula__c,
                    ANG_Accreditation_Model__c 
                 FROM 
                    Account 
                 WHERE 
                    Name = 'Uk Test' 
                 LIMIT 1
                ];

            Test.startTest();

            RestResponse response = doCallOutToWS(acct.IATACode__c, true, AMS_Utils.MBPDD_CHANGE_CODE);
            System.assertEquals(HTTP_STATUS_OK, response.statusCode, 'The service response must be ' + HTTP_STATUS_OK);
            
            String respBody = response.responseBody.toString();
        
            ANG_MasterData_Interface.MasterDataPayload payload = (ANG_MasterData_Interface.MasterDataPayload) JSON.deserialize(respBody, ANG_MasterData_Interface.MasterDataPayload.class);
        
            system.assert(payload.dueDiligence.size() == 0, 'Payload due diligence element must be empty');

            ANG_OscarProcessHelper.createIEPAccountOscar(new Map<Id, Account>{ acct.Id => acct}, 'B+');

            AMS_OSCAR__c oscar = [SELECT Id, Step17__c, Process__c FROM AMS_OSCAR__c LIMIT 1];
            
            response = doCallOutToWS(acct.IATACode__c, true, AMS_Utils.MBPDD_CHANGE_CODE);
            System.assertEquals(HTTP_STATUS_OK, response.statusCode, 'The service response must be ' + HTTP_STATUS_OK);
            
            respBody = response.responseBody.toString();
        
            payload = (ANG_MasterData_Interface.MasterDataPayload) JSON.deserialize(respBody, ANG_MasterData_Interface.MasterDataPayload.class);

            system.assert(payload.dueDiligence.size() > 0, 'Payload due diligence element must NOT be empty');
            system.assert(payload.dueDiligence.get(0).Type == AMS_Utils.MBPDD_CHANGE_CODE, 'Payload due diligence element must contain type=' + AMS_Utils.MBPDD_CHANGE_CODE);
            system.assert(payload.dueDiligence.get(0).Status != AMS_Utils.PASSED, 'Payload due diligence element must contain status != ' + AMS_Utils.PASSED);

            oscar.Step17__c = 'Passed';
            update oscar;

            response = doCallOutToWS(acct.IATACode__c, true, AMS_Utils.MBPDD_CHANGE_CODE);
            System.assertEquals(HTTP_STATUS_OK, response.statusCode, 'The service response must be ' + HTTP_STATUS_OK);
            
            respBody = response.responseBody.toString();
        
            payload = (ANG_MasterData_Interface.MasterDataPayload) JSON.deserialize(respBody, ANG_MasterData_Interface.MasterDataPayload.class);

            system.assert(payload.dueDiligence.size() > 0, 'Payload due diligence element must NOT be empty');
            system.assert(payload.dueDiligence.get(0).Type == AMS_Utils.MBPDD_CHANGE_CODE, 'Payload due diligence element must contain type=' + AMS_Utils.MBPDD_CHANGE_CODE);
            system.assert(payload.dueDiligence.get(0).Status == AMS_Utils.PASSED, 'Payload due diligence element must contain status=' + AMS_Utils.PASSED);

            Test.stopTest();

        }

        @isTest static void pciCompliantTest(){
                
            Account acct = 
                [SELECT 
                    Id,
                    Name,
                    IATACode__c,
                    Is_PCI_Compliant__c
                 FROM
                    Account 
                 WHERE 
                    Name = 'Uk Test' 
                 LIMIT 1
                ];

            Test.startTest();

            RestResponse response = doCallOutToWS(acct.IATACode__c, true);
            System.assertEquals(HTTP_STATUS_OK, response.statusCode, 'The service response must be ' + HTTP_STATUS_OK);
            
            String respBody = response.responseBody.toString();
        
            ANG_MasterData_Interface.MasterDataPayload payload = (ANG_MasterData_Interface.MasterDataPayload) JSON.deserialize(respBody, ANG_MasterData_Interface.MasterDataPayload.class);
        
            system.debug('PAYLOAD: ' + payload.isPciDss);
            system.assert(payload.isPciDss != NULL, 'Payload isPciDss element must NOT be empty');
            system.assert(!payload.isPciDss, 'Payload isPciDss element must be \'FALSE\'');
        
            acct.Is_PCI_Compliant__c = 'Nil CC';
            update acct;

            response = doCallOutToWS(acct.IATACode__c, true);
            System.assertEquals(HTTP_STATUS_OK, response.statusCode, 'The service response must be ' + HTTP_STATUS_OK);
            
            respBody = response.responseBody.toString();
        
            payload = (ANG_MasterData_Interface.MasterDataPayload) JSON.deserialize(respBody, ANG_MasterData_Interface.MasterDataPayload.class);
        
            system.assert(payload.isPciDss != NULL, 'Payload isPciDss element must NOT be empty');
            system.assert(!payload.isPciDss, 'Payload isPciDss element must be \'FALSE\'');

            acct.Is_PCI_Compliant__c = 'Corporate Card';
            update acct;

            response = doCallOutToWS(acct.IATACode__c, true);
            System.assertEquals(HTTP_STATUS_OK, response.statusCode, 'The service response must be ' + HTTP_STATUS_OK);
            
            respBody = response.responseBody.toString();
        
            payload = (ANG_MasterData_Interface.MasterDataPayload) JSON.deserialize(respBody, ANG_MasterData_Interface.MasterDataPayload.class);
        
            system.assert(payload.isPciDss != NULL, 'Payload isPciDss element must NOT be empty');
            system.assert(payload.isPciDss, 'Payload isPciDss element must be \'TRUE\'');
            
            //When the IEP Status is not 'open' or 'in progress' 
            //the pci compliant value must not be in the payload
            acct.ANG_IEP_Status__c = 'No IEP Account';
            update acct;

            response = doCallOutToWS(acct.IATACode__c, true);
            System.assertEquals(HTTP_STATUS_OK, response.statusCode, 'The service response must be ' + HTTP_STATUS_OK);
            
            respBody = response.responseBody.toString();
        
            payload = (ANG_MasterData_Interface.MasterDataPayload) JSON.deserialize(respBody, ANG_MasterData_Interface.MasterDataPayload.class);
        
            system.assert(payload.isPciDss == NULL, 'Payload isPciDss element must be NULL');

            Test.stopTest();

        }

}
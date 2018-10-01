@isTest
private class ANG_MasterData_Interface_test {
        private static final integer HTTP_STATUS_OK = 200;
        private static final integer HTTP_STATUS_BAD_REQUEST = 400;
        private static final integer HTTP_NOT_FOUND = 404;
        private static final integer HTTP_MULTIPLE_FOUND = 300;

	@testSetup static void testSetup(){

                IATA_ISO_Country__c isoCntr1 = new IATA_ISO_Country__c(Name = 'Portugal', Region__c = 'Europe', ISO_Code__c='PT', ANG_Enable_NewGen__c = true);
                insert isoCntr1;

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

                insert new list<account>{acc,acc1,acc2};

                Account accChild = new Account(
                        ParentId = acc.id,
                        name='acc3',
                        Location_Type__c=AMS_Utils.HE,
                        Location_Class__c= AMS_Utils.LC_PASSENGER,
                        Remittance_frequency__c=ANG_Risk_Helper.REMITTANCE_FREQUENCY_MONTHLY,
                        ANG_Accreditation_Model__c =AMS_Utils.ACCREDITATIONMODEL_CASH,
                        recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY,
                        IATACode__c ='12223',
                        IATA_ISO_Country__c = isoCntr1.Id
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
                        ANG_AccountId__c = acc.id
                );
                insert rhcRec;
	}
        private static RestResponse doCallOutToWS(String iataCode,Boolean getChildren){
                 RestRequest request = new RestRequest(); 
                RestResponse response = new RestResponse();
                
                request.requestURI = '/ANG_GetMasterData/'+iataCode;  
                request.httpMethod = 'GET';
                if(getChildren)  request.addParameter('mode', 'f');

                RestContext.request = request;
                RestContext.response = response;
                ANG_MasterData_Interface.doGet();

                return response;
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


        
}
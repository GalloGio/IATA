@isTest
private class AMS_InspectionHelperTest {

    @isTest static void test_setStatusCodeOnAccountForDOM(){
    	TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
                insert ctry ;

                Map<string, Id>  agenciesRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

        // for IATA
        
                List<AMS_Agency__c> agencylist = new List<AMS_Agency__c>();
                AMS_Agency__c a1 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'), IATACode__c='1234567',Name='Test1 Agency',Legal_Name_1__c='Test1 Agency');
                AMS_Agency__c a2 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'),IATACode__c='1234568',Name='Test2 Agency',Legal_Name_1__c='Test2 Agency');
                AMS_Agency__c a3 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'),IATACode__c='1234569',Name='Test3 Agency',Legal_Name_1__c='Test3 Agency');
                AMS_Agency__c a4 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'),IATACode__c='1234560',Name='Test4 Agency',Legal_Name_1__c='Test4 Agency');
                AMS_Agency__c a5 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'),IATACode__c='1234561',Name='Test5 Agency',Legal_Name_1__c='Test5 Agency');
                
        
                agencylist.add(a1);
                agencylist.add(a2);
                agencylist.add(a3);
                agencylist.add(a4);
                agencylist.add(a5);
        
                insert agencylist;

                AMS_Accreditation_Organization__c ao = new AMS_Accreditation_Organization__c(Air_Code__c = 'DOM');
                insert ao;

                Test.startTest();
                List<AMS_Inspection__c> agencyInspectionList = new List<AMS_Inspection__c>();
                AMS_Inspection__c ins1 = new AMS_Inspection__c(Agency__c=a1.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '0');
                AMS_Inspection__c ins2 = new AMS_Inspection__c(Agency__c=a2.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '1');
                AMS_Inspection__c ins3 = new AMS_Inspection__c(Agency__c=a3.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '2');
                AMS_Inspection__c ins4 = new AMS_Inspection__c(Agency__c=a4.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '3');
                AMS_Inspection__c ins5 = new AMS_Inspection__c(Agency__c=a5.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '8');

        
                agencyInspectionList.add(ins1);
                agencyInspectionList.add(ins2);
                agencyInspectionList.add(ins3);
                agencyInspectionList.add(ins4);
                agencyInspectionList.add(ins5);
        
                insert agencyInspectionList;

                List<AMS_Inspection__c> inspections = [select Accreditation_Endorsement_Status_code__c, Agency__r.Account__r.Status__c from AMS_Inspection__c insp where insp.Accreditation_Endorsement_organisation__r.Air_Code__c = 'DOM'];

                for(AMS_Inspection__c i:inspections){
                    
                    if(i.Accreditation_Endorsement_Status_code__c == '0')
                        System.assertEquals('Terminated', i.Agency__r.Account__r.Status__c);
                    if(i.Accreditation_Endorsement_Status_code__c == '1')
                        System.assertEquals('Not accreditated', i.Agency__r.Account__r.Status__c);
                    if(i.Accreditation_Endorsement_Status_code__c == '2')
                        System.assertEquals('New application pending', i.Agency__r.Account__r.Status__c);
                    if(i.Accreditation_Endorsement_Status_code__c == '3')
                        System.assertEquals('Not in operation', i.Agency__r.Account__r.Status__c);
                    if(i.Accreditation_Endorsement_Status_code__c == '4')
                        System.assertEquals('Not accreditated', i.Agency__r.Account__r.Status__c);
                    if(i.Accreditation_Endorsement_Status_code__c == '5')
                        System.assertEquals('Cash basis/no commission', i.Agency__r.Account__r.Status__c);
                    if(i.Accreditation_Endorsement_Status_code__c == '6')
                        System.assertEquals('Cash basis/with commission', i.Agency__r.Account__r.Status__c);
                    if(i.Accreditation_Endorsement_Status_code__c == '7')
                        System.assertEquals('Under review', i.Agency__r.Account__r.Status__c);
                    if(i.Accreditation_Endorsement_Status_code__c == '8')
                        System.assertEquals('Changes processed', i.Agency__r.Account__r.Status__c);
                    if(i.Accreditation_Endorsement_Status_code__c == '9')
                        System.assertEquals('Approved', i.Agency__r.Account__r.Status__c);
                }

                ins1.Accreditation_Endorsement_Status_code__c='0';
                ins2.Accreditation_Endorsement_Status_code__c='4';
                ins3.Accreditation_Endorsement_Status_code__c='5';
                ins4.Accreditation_Endorsement_Status_code__c='6';
                ins5.Accreditation_Endorsement_Status_code__c='9';

            
                List<SObject> updateAll = new List<SObject>();
                updateAll.add(ins1);
                updateAll.add(ins2);
                updateAll.add(ins3);
                updateAll.add(ins4);
                updateAll.add(ins5);
                
                update updateAll;
                
                inspections = [select Accreditation_Endorsement_Status_code__c, Agency__r.Account__r.Status__c from AMS_Inspection__c insp where insp.Accreditation_Endorsement_organisation__r.Air_Code__c = 'DOM'];

                for(AMS_Inspection__c i:inspections){
                    
                    if(i.Accreditation_Endorsement_Status_code__c == '0')
                        System.assertEquals('Terminated', i.Agency__r.Account__r.Status__c);
                    if(i.Accreditation_Endorsement_Status_code__c == '4')
                        System.assertEquals('Listed', i.Agency__r.Account__r.Status__c);
                    if(i.Accreditation_Endorsement_Status_code__c == '5')
                        System.assertEquals('Cash basis/no commission', i.Agency__r.Account__r.Status__c);
                    if(i.Accreditation_Endorsement_Status_code__c == '6')
                        System.assertEquals('Cash basis/with commission', i.Agency__r.Account__r.Status__c);
                    if(i.Accreditation_Endorsement_Status_code__c == '7')
                        System.assertEquals('Under review', i.Agency__r.Account__r.Status__c);
                    if(i.Accreditation_Endorsement_Status_code__c == '8')
                        System.assertEquals('Changes processed', i.Agency__r.Account__r.Status__c);
                    if(i.Accreditation_Endorsement_Status_code__c == '9')
                        System.assertEquals('Approved', i.Agency__r.Account__r.Status__c);
                }
    }
	
	@isTest static void test_setStatusCodeOnAccount() {
		TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
                IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
                insert ctry ;

                Map<string, Id>  agenciesRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

        // for IATA
        
				List<AMS_Agency__c> agencylist = new List<AMS_Agency__c>();
                AMS_Agency__c a1 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'), IATACode__c='1234567',Name='Test1 Agency',Legal_Name_1__c='Test1 Agency');
                AMS_Agency__c a2 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'),IATACode__c='1234568',Name='Test2 Agency',Legal_Name_1__c='Test2 Agency');
                AMS_Agency__c a3 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'),IATACode__c='1234569',Name='Test3 Agency',Legal_Name_1__c='Test3 Agency');
                AMS_Agency__c a4 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'),IATACode__c='1234560',Name='Test4 Agency',Legal_Name_1__c='Test4 Agency');
                AMS_Agency__c a5 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'),IATACode__c='1234561',Name='Test5 Agency',Legal_Name_1__c='Test5 Agency');
                
        
        		agencylist.add(a1);
                agencylist.add(a2);
                agencylist.add(a3);
                agencylist.add(a4);
                agencylist.add(a5);
        
                insert agencylist;

                AMS_Accreditation_Organization__c ao = new AMS_Accreditation_Organization__c(Air_Code__c = 'IATA');
                insert ao;

                Test.startTest();
                List<AMS_Inspection__c> agencyInspectionList = new List<AMS_Inspection__c>();
                AMS_Inspection__c ins1 = new AMS_Inspection__c(Agency__c=a1.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '0');
                AMS_Inspection__c ins2 = new AMS_Inspection__c(Agency__c=a2.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '4');
                AMS_Inspection__c ins3 = new AMS_Inspection__c(Agency__c=a3.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '5');
                AMS_Inspection__c ins4 = new AMS_Inspection__c(Agency__c=a4.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '6');
                AMS_Inspection__c ins5 = new AMS_Inspection__c(Agency__c=a5.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '7');

        
                agencyInspectionList.add(ins1);
                agencyInspectionList.add(ins2);
                agencyInspectionList.add(ins3);
                agencyInspectionList.add(ins4);
                agencyInspectionList.add(ins5);
        
                insert agencyInspectionList;

                List<AMS_Inspection__c> inspections = [select Accreditation_Endorsement_Status_code__c, Agency__r.Account__r.Status__c from AMS_Inspection__c insp where insp.Accreditation_Endorsement_organisation__r.Air_Code__c = 'IATA'];

                for(AMS_Inspection__c i:inspections){
                    
                	if(i.Accreditation_Endorsement_Status_code__c == '0')
                		System.assertEquals('Terminated', i.Agency__r.Account__r.Status__c);
                	if(i.Accreditation_Endorsement_Status_code__c == '4')
                		System.assertEquals('Listed', i.Agency__r.Account__r.Status__c);
                	if(i.Accreditation_Endorsement_Status_code__c == '5')
                		System.assertEquals('Cash basis/no commission', i.Agency__r.Account__r.Status__c);
                	if(i.Accreditation_Endorsement_Status_code__c == '6')
                		System.assertEquals('Cash basis/with commission', i.Agency__r.Account__r.Status__c);
                	if(i.Accreditation_Endorsement_Status_code__c == '7')
                		System.assertEquals('Under review', i.Agency__r.Account__r.Status__c);
                	if(i.Accreditation_Endorsement_Status_code__c == '8')
                		System.assertEquals('Changes processed', i.Agency__r.Account__r.Status__c);
                	if(i.Accreditation_Endorsement_Status_code__c == '9')
                		System.assertEquals('Approved', i.Agency__r.Account__r.Status__c);
                }

                ins1.Accreditation_Endorsement_Status_code__c='0';
                ins2.Accreditation_Endorsement_Status_code__c='4';
                ins3.Accreditation_Endorsement_Status_code__c='5';
                ins4.Accreditation_Endorsement_Status_code__c='6';
                ins5.Accreditation_Endorsement_Status_code__c='7';

        	
                List<SObject> updateAll = new List<SObject>();
                updateAll.add(ins1);
                updateAll.add(ins2);
                updateAll.add(ins3);
                updateAll.add(ins4);
                updateAll.add(ins5);
        		
                update updateAll;
                
                inspections = [select Accreditation_Endorsement_Status_code__c, Agency__r.Account__r.Status__c from AMS_Inspection__c insp where insp.Accreditation_Endorsement_organisation__r.Air_Code__c = 'IATA'];

                for(AMS_Inspection__c i:inspections){
                    
                	if(i.Accreditation_Endorsement_Status_code__c == '0')
                		System.assertEquals('Terminated', i.Agency__r.Account__r.Status__c);
                	if(i.Accreditation_Endorsement_Status_code__c == '4')
                		System.assertEquals('Listed', i.Agency__r.Account__r.Status__c);
                	if(i.Accreditation_Endorsement_Status_code__c == '5')
                		System.assertEquals('Cash basis/no commission', i.Agency__r.Account__r.Status__c);
                	if(i.Accreditation_Endorsement_Status_code__c == '6')
                		System.assertEquals('Cash basis/with commission', i.Agency__r.Account__r.Status__c);
                	if(i.Accreditation_Endorsement_Status_code__c == '7')
                		System.assertEquals('Under review', i.Agency__r.Account__r.Status__c);
                	if(i.Accreditation_Endorsement_Status_code__c == '8')
                		System.assertEquals('Changes processed', i.Agency__r.Account__r.Status__c);
                	if(i.Accreditation_Endorsement_Status_code__c == '9')
                		System.assertEquals('Approved', i.Agency__r.Account__r.Status__c);
                }
        
        
        // for IATAN
        
        		agencylist = new List<AMS_Agency__c>();
                a1 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'), IATACode__c='2234567',Name='Test1 Agency',Legal_Name_1__c='Test1 Agency');
                a2 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'),IATACode__c='2234568',Name='Test2 Agency',Legal_Name_1__c='Test2 Agency');
                a3 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'),IATACode__c='2234569',Name='Test3 Agency',Legal_Name_1__c='Test3 Agency');
                a4 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'),IATACode__c='2234560',Name='Test4 Agency',Legal_Name_1__c='Test4 Agency');
                a5 = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'),IATACode__c='2234561',Name='Test5 Agency',Legal_Name_1__c='Test5 Agency');
				
        		agencylist.add(a1);
                agencylist.add(a2);
                agencylist.add(a3);
                agencylist.add(a4);
                agencylist.add(a5);
        		
                insert agencylist;

                ao = new AMS_Accreditation_Organization__c(Air_Code__c = 'IATAN');
                insert ao;

                agencyInspectionList = new List<AMS_Inspection__c>();
        
                 ins1 = new AMS_Inspection__c(Agency__c=a1.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '0');
                 ins2 = new AMS_Inspection__c(Agency__c=a2.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '4');
                 ins3 = new AMS_Inspection__c(Agency__c=a3.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '5');
                 ins4 = new AMS_Inspection__c(Agency__c=a4.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '6');
                 ins5 = new AMS_Inspection__c(Agency__c=a5.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '7');
        
                agencyInspectionList.add(ins1);
                agencyInspectionList.add(ins2);
                agencyInspectionList.add(ins3);
                agencyInspectionList.add(ins4);
                agencyInspectionList.add(ins5);
        
                insert agencyInspectionList;

                inspections = [select Accreditation_Endorsement_Status_code__c, Agency__r.Account__r.Status__c from AMS_Inspection__c insp where insp.Accreditation_Endorsement_organisation__r.Air_Code__c = 'IATAN'];

                for(AMS_Inspection__c i:inspections){
                	if(i.Accreditation_Endorsement_Status_code__c == '0')
                		System.assertEquals('Terminated', i.Agency__r.Account__r.Status__c);
                	if(i.Accreditation_Endorsement_Status_code__c == '4')
                		System.assertEquals('Listed', i.Agency__r.Account__r.Status__c);
                	if(i.Accreditation_Endorsement_Status_code__c == '5')
                		System.assertEquals('Listed(BSP)', i.Agency__r.Account__r.Status__c);
                	if(i.Accreditation_Endorsement_Status_code__c == '6')
                		System.assertEquals('Under review', i.Agency__r.Account__r.Status__c);
                	if(i.Accreditation_Endorsement_Status_code__c == '7')
                		System.assertEquals('Approved', i.Agency__r.Account__r.Status__c);
                }

                ins1.Accreditation_Endorsement_Status_code__c='9';
                ins2.Accreditation_Endorsement_Status_code__c='8';
                ins3.Accreditation_Endorsement_Status_code__c='5';
                ins4.Accreditation_Endorsement_Status_code__c='6';
                ins5.Accreditation_Endorsement_Status_code__c='7';
                
        		updateAll = new List<SObject>();
                
        		updateAll.add(ins1);
                updateAll.add(ins2);
                updateAll.add(ins3);
                updateAll.add(ins4);
                updateAll.add(ins5);
                update updateAll;
                
                inspections = [select Accreditation_Endorsement_Status_code__c, Agency__r.Account__r.Status__c from AMS_Inspection__c insp where  insp.Accreditation_Endorsement_organisation__r.Air_Code__c = 'IATAN'];

                for(AMS_Inspection__c i:inspections){
                	if(i.Accreditation_Endorsement_Status_code__c == '0')
                		System.assertEquals('Terminated', i.Agency__r.Account__r.Status__c);
                	if(i.Accreditation_Endorsement_Status_code__c == '4')
                		System.assertEquals('Listed', i.Agency__r.Account__r.Status__c);
                	if(i.Accreditation_Endorsement_Status_code__c == '5')
                		System.assertEquals('Listed(BSP)', i.Agency__r.Account__r.Status__c);
                	if(i.Accreditation_Endorsement_Status_code__c == '6')
                		System.assertEquals('Under review', i.Agency__r.Account__r.Status__c);
                	if(i.Accreditation_Endorsement_Status_code__c == '7')
                		System.assertEquals('Approved', i.Agency__r.Account__r.Status__c);
                }
        
                Test.stopTest();
	}	
}
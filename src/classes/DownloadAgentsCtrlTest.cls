@isTest
private class DownloadAgentsCtrlTest {
       
       static testMethod void myUnitTest() {
       
        ID Hq  =Schema.SObjectType.Account.RecordTypeInfosByName.get('Airline Headquarters').RecordTypeId ;
        ID IFAPCaseID  =Schema.SObjectType.Case.RecordTypeInfosByName.get('IATA Financial Review').RecordTypeId ;
                
         IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1' );
         insert isoCountry;

                Account Hqrter = new Account(name ='IFAP ACCT',
                Fin_statements_submission_deadline__c= String.valueOF(date.today().Year()),
                    Has_Financial_Review_Open_Cases__c = false,
                                             industry = 'pluto',
                                             IATA_ISO_Country__c=isoCountry.id,
                                             recordtypeID = Hq,
                                             IATACode__c ='1234567',
                                             Type = 'IATA Cargo Agent',Status__c = 'Approved',    
                                             billingCountry = 'suisse',Location_Type__c = 'AO');
        insert Hqrter;
        
        
        Contact con = new Contact(firstName='Name',lastname ='bingo',email='bingo@asdf.it', accountID = Hqrter.id, Financial_Assessment_Contact__c = true);
        
        
                insert con;
                
        date dead = date.today().addDays(40);
        
        Case c = new Case(recordtypeID = IFAPCaseID,
        
                              Status = 'Assessment Performed',
                              Origin = 'asd',
                              IFAP_Area__c = 'asda',
                              Financial_Review_Type__c ='bla',
                              IFAP_Financial_Year__c =  String.valueOF(date.today().Year()),
                              Deadline_Date__c = dead,
                              contactid = con.id,
                              AccountId = Hqrter.id,
                              Assessment_Performed_Date__c = date.today(),
                              Financial_Review_Result__c = 'Satisfactory - No Action'                                                    
                              );
            
            insert c;
        
        PageReference pageRef = Page.DownloadAgents;
        Test.setCurrentPage(pageRef);
        
         ApexPages.currentPage().getParameters().put('agentStatus','Approved');
         ApexPages.currentPage().getParameters().put('agentType','IATA Cargo Agent');
         //ApexPages.currentPage().getParameters().put('country','suisse');
         ApexPages.currentPage().getParameters().put('ISOcountry',isoCountry.id);
         ApexPages.currentPage().getParameters().put('email','Available');
         ApexPages.currentPage().getParameters().put('exclClosedCases','false');
         ApexPages.currentPage().getParameters().put('exclOpenCases','false');
         ApexPages.currentPage().getParameters().put('targetFinancialYear','String.valueOF(date.today().Year())');
         ApexPages.currentPage().getParameters().put('yearend','--All--');
                 
        DownloadAgentsCtrl crtl = new DownloadAgentsCtrl();
        system.assertEquals(crtl.displayList.size(),1);
        
       }

}
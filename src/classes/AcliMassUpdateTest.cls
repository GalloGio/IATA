@isTest
private class AcliMassUpdateTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
             
             test.startTest();
                Id folderID = [select Id from user where isActive =true and profile.name = 'System Administrator'][0].id;
                
               //string CSV = '1263343 Alberta Ltd. t/a Enerjet                                                    ENJEG*119-1440 Aviation Park NE                                                       Calgary                  Alberta             Canada                                      T2E 7E2                                                                                                           Y   B     <br>';
               string CSV  = 'Aer Lingus Limited                                                              053 EINEI Dublin Airport                                                                  DUBLIN                                       Ireland                                                                                                                                                       YYY YI 053 0010000141X000000001234567890 Coding status                 20151014   ';
           
                Document d = new Document();
          
                csv = csv.replace('<span id="lblRawOutput"><font face="Verdana">','');
                csv = csv.replace('</font></span>','');
                d.FolderId = folderID;
                d.developername ='AcliUniqueFile';
                d.Name = 'AcliUniqueFile'+dateTime.now();
                d.Body = Blob.valueOf(CSV); 
                d.ContentType = 'text/plain';
                
                d.Type = 'txt';
    
                upsert d;
           
           
           ID hdqid = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
         	
           account a = new account(name = 'pippo', NAme_on_AOC__c = 'pippo', acli_status__c = 'Active Company', recordtypeID = hdqid);
           insert a;
           PageReference pageRef = Page.ACliMassUpdate;
           Test.setCurrentPage(pageRef);
            
          ACliMassUpdate controller = new ACliMassUpdate();
          controller.tab = '0';
          controller.First();
           
          list<AcliAccount> accts =     controller.getAcliAccountsPage();
          controller.AccountSite = accts[0].AccountSite;
          controller.convertToAccount();
          
          controller.tab = '1'; 
          controller.next();
          controller.previous();

          controller.UpdateAll();

             test.stopTEst();
          string newStatus = [SELECT ID, ACLI_STATUS__C FROM ACCOUNT WHERE ID =: A.ID LIMIT 1 ].ACLI_sTATUS__c;
          SYSTEM.ASSERTEQUALS(NEWSTATUS,'Inactive Company');

    }
}
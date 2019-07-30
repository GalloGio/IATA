@istest
private class AcliDownloadAndScheduleTest {
    
    /*static testmethod void test() {
        
                Id folderID = [select Id from user where isActive =true and profile.name = 'System Administrator'][0].id;
        list<UtilityCS__c> utilities = new list<UtilityCS__c>{
                                                                new UtilityCS__c(name ='AcliFolderID',value__c =folderID),
                                                                new UtilityCS__c(name = 'AcliURL',value__c = 'someURL')
                                                                };
        insert utilities;
        Test.startTest();

        String jobId = System.schedule('testBasicScheduledApex',
                                        '20 30 8 10 2 ?', 
         new AcliSchedule());

        Test.stopTest();
        
        
    document d =  [SELECT ID,BODY,TYPE,name,CONTENTTYPE,developername,FolderId 
                                        FROM Document 
                                        WHERE developername = 'AcliUniqueFile' 
                                        limit 1 ];
        system.assertEquals(d.developername,'AcliUniqueFile' );



   }*/
  
  static testmethod void test2() {
        
                Id folderID = [select Id from user where isActive =true and profile.name = 'System Administrator'][0].id;
        list<UtilityCS__c> utilities = new list<UtilityCS__c>{
                                                                new UtilityCS__c(name ='AcliFolderID',value__c =folderID),
                                                                new UtilityCS__c(name = 'AcliURL',value__c = 'someURL'),
                                                                new UtilityCS__c(name = 'AcliOwnerEmail',value__c = 'viticchies@iata.org') 
                                                                };
        insert utilities;
        Test.startTest();

		//AcliFileDownload.TEST_CSV = 'Aero Contractors Company Nigeria Ltd.                                           708 NIGNG Murtala Muhammed Airport Ikeja          P.M.B. 21090                            Lagos                                        Nigeria                                                                                                                                                           I     <br>';
		AcliFileDownload.TEST_CSV = 'Aer Lingus Limited                                                              053 EINEI Dublin Airport                                                                  DUBLIN                                       Ireland                                                                                                                                                       YYY YI 053 0010000141X000000001234567890 Coding status                 20151014   Aer Lingus Limited                                                              DIE';
        AcliFileDownload.downLoadAcliFile();

        Test.stopTest();
        
        
        document d =  [SELECT ID,BODY,TYPE,name,CONTENTTYPE,developername,FolderId 
                                        FROM Document 
                                        WHERE developername = 'asdasdasdasdasdgasedfg' 
                                        limit 1 ];
       system.assertEquals(d.developername,'asdasdasdasdasdgasedfg' );



   }

}
/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class GenerateLateRemittanceCSVControllerTest {

    static testMethod void myUnitTest() {
        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
        ID hqrt = Schema.SObjectType.Account.RecordTypeInfosByName.get('Airline Headquarters').RecordTypeId ;
        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('IATA_Financial_Review');
        ID SIDRAcaseRecordTypeID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('SIDRA');
        
        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c( Name = 'France',ISO_Code__c = 'FR', AIMS_Area_Name__c = 'France', AIMS_Area_ID__c = '1', SAP_Sales_Org__c = 'SIN1', 
                                                                    Region__c = 'Europe');
        insert isoCountry;
        
        Late_Payment_Fees_CASS_ISO_Countries_Exc__c excludedCountry = new Late_Payment_Fees_CASS_ISO_Countries_Exc__c(Name='France');
        insert excludedCountry;
        
        Account a = new Account( Name ='IFAP ACCT',
                                 Industry = 'pluto',
                                 IATA_ISO_Country__c = isoCountry.id,
                                 RecordTypeID = hqrt,
                                 IATACode__c ='1234567',
                                 Type = 'IATA Cargo Agent',
                                 BillingCountry = 'CH',Location_Type__c = 'AO');
        insert a;
        
        Contact con = new Contact( LastName = 'pluto' ,
                                 FirstName = 'Name',
                                 Phone = '123',
                                 AccountId = a.id,
                                 Financial_Assessment_Contact__c = true,
                                 Email = 'asd.arg@wewt.et',
                                 HasOptedOutOfEmail = false
                                 );
        insert con;
        
        Date deadline = date.newInstance(2015,5,20); //pInteger, pInteger, pInteger)date.today().addMonths(2).addDays(-1);
        Date twoweeksAgo = date.newInstance(2015,3,6); //date.today().addDays(- 14);
        Date dToday = date.newInstance(2015,3,20); //date.today();
        DateTime dtNow = Datetime.newInstance(2015,3,20); // Datetime.now();
        
        List <Case> csList = new List <Case> ();        
        // create an IFAP case, will be selected by the 3rd report when generating the CSV
        Case cs = new Case(recordtypeID = IFAPcaseRecordTypeID,
                          //Status = 'Financial Security Requested',
                          Financial_Review_Result__c = 'Satisfactory - New Financial Security',
                          Financial_Review_Type__c = 'Adhoc',
                          Type_of_customer__c = 'asfg',
                          FS_Submitted_Date__c = date.today(),
                          FS_Deadline_Date__c = twoweeksAgo,
                          Origin = 'asd',
                          IFAP_Area__c = 'asda',
                          IFAP_Financial_Year__c =  String.valueOF(dToday.month()),
                          Deadline_Date__c = deadline,
                          contactid = con.id,
                          AccountId = a.id,
                          Region__c = 'Europe',
                          BSPCountry__c = 'France',
                          Assessment_Performed_Date__c = dToday,
                          Subject = 'c2',
                          Phone_Redirected_to_Web__c = false, 
                          SIDRA_Exclude_from_report_exceptions__c = true,
                          BSP_CASS__c = 'BSP', 
                          CS_Rep_Acc_DEF__c = UserInfo.getUserId(),
                          Update_AIMS_DEF__c = dtNow,
                          DEF_Withdrawal_Reason__c = 'Bank error');
        //insert cs;
        csList.add(cs);
        // create a SIDRA case, that will be selected by the 2nd report when generating the CSV
        Case cs2 = new Case(recordtypeID = SIDRAcaseRecordTypeID,
                          Status = 'New',
                          Origin = 'asd',
                          Update_AIMS_REI_DEFWITH__c = deadline,
                          contactid = con.id,
                          AccountId = a.id,
                          Region__c = 'Europe',
                          BSPCountry__c = 'France',
                          BSP_CASS__c = 'BSP', 
                          Subject = 'c2',
                          Update_AIMS_DEF__c = dtNow,
                          Remittance_Date__c = dToday,
                          Late_Payment_Date__c = dToday.addDays(2),
                          Remittance_Period__c = '--',
                          DEF_Withdrawal_Reason__c = 'Bank error');
        //insert cs2;
        csList.add(cs2);
        
        // create a SIDRA case, that will be selected by the 1st report when generating the CSV
        Case cs3 = new Case(recordtypeID = SIDRAcaseRecordTypeID,
                          Status = 'New',
                          Origin = 'asd',
                          Update_AIMS_REI_DEFWITH__c = deadline,
                          contactid = con.id,
                          AccountId = a.id,
                          Region__c = 'Europe',
                          BSPCountry__c = 'France',
                          BSP_CASS__c = 'BSP', 
                          Subject = 'c3',
                          Update_AIMS_IRR__c = dtNow.addMonths(2),
                          Remittance_Date__c = dToday,
                          Late_Payment_Date__c = dToday.addDays(2),
                          Remittance_Period__c = '-',
                          IRR_Withdrawal_Reason__c = 'Bank Error');
        //insert cs3;
        csList.add(cs3);
        insert csList;
        
        
        
        test.startTest();
            
            GenerateLateRemittanceCSVController csvCtrl = new GenerateLateRemittanceCSVController();
            csvCtrl.strRegion = 'Europe';
            csvCtrl.strStartDate = dToday.addDays(-1).addMonths(2).toStartOfMonth().format();
            csvCtrl.strEndDate = dToday.addDays(-1).addMonths(3).toStartOfMonth().addDays(-1).format();
            csvCtrl.GenerateCSV();
            
            /*
            Case tcs = [SELECT RecordType.DeveloperName, SIDRA_Exclude_from_report_exceptions__c, DEF_Withdrawal_Reason__c, 
                            BSP_CASS__c, BSPCountry__c, Update_AIMS_DEF__c, Account.IATA_ISO_Country__r.SAP_Sales_Org__c, Deadline_Date__c, Region__c 
                            FROM Case 
                            WHERE Id = :cs.Id];
            system.debug(tcs);
            system.debug('Case Region: ' + tcs.Region__c + '; Controller filter region: ' + csvCtrl.strRegion );
            system.debug(csvCtrl.strStartDate);
            system.debug(csvCtrl.strEndDate);*/
            
            
            // build the expected result string
            String strExpectedCSVcontent = 'DocType,SalesOrg,DistChan,Division,SalesOffice,CustName,AgentCode,ContractNo,Ponumber,Podate,Sodesc,DocCurr,PayMethod,BillingDate,TextPrint,InternalRemark,Material,MatDesc,Quantity,UnitPrice,UnitPriceCurr,DateFrom,DateTo,CaseNumber,Region,IATACountry';
            // report 1 runs first
            strExpectedCSVcontent += '\nZO01,SIN1,01,51,,,1234567,,,,,,,,,,800395,Late Remittance Recovery -,1,,,' + dToday.addMonths(2).toStartOfMonth().format().replace('/','.') + ',' + dToday.addMonths(3).toStartOfMonth().addDays(-1).format().replace('/','.')+',,,';
            strExpectedCSVcontent += '\nZO01,SIN1,01,51,,,1234567,,,,,,,,,,800394,Late Remittance Interest -,2,,,' + dToday.format().replace('/','.') + ',' + dToday.addDays(2).format().replace('/','.')+',,,';
            // then runs report 2
            strExpectedCSVcontent += '\nZO01,SIN1,01,51,,,1234567,,,,,,,,,,800395,Late Remittance Recovery --,1,,,' + dToday.addMonths(2).toStartOfMonth().format().replace('/','.') + ',' + dToday.addMonths(3).toStartOfMonth().addDays(-1).format().replace('/','.')+',,,';
            strExpectedCSVcontent += '\nZO01,SIN1,01,51,,,1234567,,,,,,,,,,800394,Late Remittance Interest --,2,,,' + dToday.format().replace('/','.') + ',' + dToday.addDays(2).format().replace('/','.');
            strExpectedCSVcontent += '\nZO01,SIN1,01,51,,,1234567,,,,,,,,,,800402,,1,,,' + dToday.addMonths(2).toStartOfMonth().format().replace('/','.') + ',' + dToday.addMonths(3).toStartOfMonth().addDays(-1).format().replace('/','.')+',,,';
            // report 3 at the end
            strExpectedCSVcontent += '\nZO01,SIN1,01,51,,,1234567,,,,,,,,,,752026,,1,,,' + dToday.addMonths(2).toStartOfMonth().format().replace('/','.') + ',' + dToday.addMonths(3).toStartOfMonth().addDays(-1).format().replace('/','.')+',,,';
            
            system.assertEquals( strExpectedCSVcontent, csvCtrl.getCSVcontent() );
            
        test.stopTest();
    }
}
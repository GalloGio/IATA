@isTest
public class UpdateAccountandUserInfoTriggersTest {

    public static testMethod void testbothtriggers()
    {


    //create an account
    Account a = new Account();
    a.Name = 'TestAccount';
    a.BillingCity='Montreal';
    a.BillingCountry='Canada';
    a.Source_System__c = 'AIMS';
    a.Site = '1234567'; 
    a.Site = '1234567';
    insert a;


   Id RecordTypeId;

    RecordType recordType = [SELECT Id FROM RecordType WHERE Name =: 'SIDRA'];
    RecordTypeId = recordType.Id;


     Case obCase = new Case();
        obCase.RecordTypeId = RecordTypeId;
        obCase.Subject = 'TestCase';
        obCase.Status = 'New';
        obCase.Origin = 'Web';
        obCase.IATAcode__c = '1234567';
        obCase.CS_Contact_Result__c = 'Amount disputed';
       obCase.Update_AIMS_IRR__c = date.today();
       obCase.Update_AIMS_DEF__c = date.today();
       obCase.Update_AIMS_IRRWITH__c = date.today();
       obCase.Update_AIMS_REI_DEFWITH__c =date.today();
       obCase.Update_AIMS_TER__c = date.today();
       obCase.Late_Payment_Date__c = date.today();

        Insert obCase;




      obCase = [select AccountID  from Case where id =: obCase.Id];


    // System.assertEquals(obCase.AccountID, a.IATAcode__c);




     //add some values

   obCase.CS_Contact_Result__c = 'Agent closed';
   obCase.Update_AIMS_IRR__c = date.today();
   obCase.Update_AIMS_DEF__c = date.today();
   obCase.Update_AIMS_IRRWITH__c = date.today();
   obCase.Update_AIMS_REI_DEFWITH__c =date.today();
   obCase.Update_AIMS_TER__c = date.today();
   obCase.DEF_Approval_Rejection__c = 'Approved';
   obCase.IRR_Approval_Rejection__c = 'Approved';
   obCase.TER_Approval_Rejection__c = 'Approved';
   obCase.Termination_Reason__c  = 'Non Payment';
   obCase.DEF_Withdrawal_Approval_Rejection__c = 'Approved';
   obCase.DEF_Withdrawal_Reason__c = 'Billing Error';
   obCase.REI_ApprovalRejectin__c = 'Approved';
   obCase.IRR_Withdrawal_Approval_Rejection__c = 'Approved';
   obCase.IRR_Withdrawal_Reason__c = 'IATA Charges';
   Update obCase;

    }


    public static testMethod void testbothtriggers2()
    {

        Id RecordTypeId;

    RecordType recordType = [SELECT Id FROM RecordType WHERE Name =: 'SIDRA'];
    RecordTypeId = recordType.Id;


 Case obCase1 = new Case();
        obCase1.RecordTypeId = RecordTypeId;
        obCase1.Subject = 'TestCase';
        obCase1.Status = 'New';
        obCase1.Origin = 'Web';
        obCase1.IATAcode__c = '12345678';
        obCase1.CS_Contact_Result__c = 'Amount disputed';
       obCase1.Update_AIMS_IRR__c = date.today();
       obCase1.Update_AIMS_DEF__c = date.today();
       obCase1.Update_AIMS_IRRWITH__c = date.today();
       obCase1.Update_AIMS_REI_DEFWITH__c =date.today();
       obCase1.Update_AIMS_TER__c = date.today();
       obCase1.DEF_Approval_Rejection__c = 'Approved';
       obCase1.IRR_Approval_Rejection__c = 'Approved';
       obCase1.TER_Approval_Rejection__c = 'Approved';
       obCase1.Termination_Reason__c  = 'Non Payment';
       obCase1.DEF_Withdrawal_Approval_Rejection__c = 'Approved';
       obCase1.DEF_Withdrawal_Reason__c = 'Billing Error';
       obCase1.REI_ApprovalRejectin__c = 'Approved';
       obCase1.IRR_Withdrawal_Approval_Rejection__c = 'Approved';
       obCase1.IRR_Withdrawal_Reason__c = 'IATA Charges';

        Insert obCase1;

 obCase1 = [select AccountID, id, IATACode__c  from Case where id =: obCase1.Id];
 obCase1.IATAcode__c = '12345678902';
 update obCase1;

 Case obCase2 = new Case();
        obCase2.RecordTypeId = RecordTypeId;
        obCase2.Subject = 'TestCase';
        obCase2.Status = 'New';
        obCase2.Origin = 'Web';
        obCase2.IATAcode__c = '12345678901';
        obCase2.CS_Contact_Result__c = 'Amount disputed';
       obCase2.Update_AIMS_IRR__c = date.today();
       obCase2.Update_AIMS_DEF__c = date.today();
       obCase2.Update_AIMS_IRRWITH__c = date.today();
       obCase2.Update_AIMS_REI_DEFWITH__c =date.today();
       obCase2.Update_AIMS_TER__c = date.today();
       obCase2.DEF_Approval_Rejection__c = 'Approved';
       obCase2.IRR_Approval_Rejection__c = 'Approved';
       obCase2.TER_Approval_Rejection__c = 'Approved';
       obCase2.Termination_Reason__c  = 'Non Payment';
       obCase2.DEF_Withdrawal_Approval_Rejection__c = 'Approved';
       obCase2.DEF_Withdrawal_Reason__c = 'Billing Error';
       obCase2.REI_ApprovalRejectin__c = 'Approved';
       obCase2.IRR_Withdrawal_Approval_Rejection__c = 'Approved';
       obCase2.IRR_Withdrawal_Reason__c = 'IATA Charges';

        Insert obCase2;
        obCase2 = [select AccountID, id, IATACode__c  from Case where id =: obCase2.Id];
 obCase2.IATAcode__c = '12345678';
 update obCase2;
    }


        public static testMethod void testbothtriggers3()
    {


        Id RecordTypeId;

    RecordType recordType = [SELECT Id FROM RecordType WHERE Name =: 'SIDRA'];
    RecordTypeId = recordType.Id;

        Case obCase3 = new Case();
        obCase3.RecordTypeId = RecordTypeId;
        obCase3.Subject = 'TestCase';
        obCase3.Status = 'New';
        obCase3.Origin = 'Web';
        obCase3.IATAcode__c = '1234567890';
        obCase3.BSPCountry__c = 'Canada';
        obCase3.CS_Contact_Result__c = 'Amount disputed';
       obCase3.Update_AIMS_IRR__c = date.today();
       obCase3.Update_AIMS_DEF__c = date.today();
       obCase3.Update_AIMS_IRRWITH__c = date.today();
       obCase3.Update_AIMS_REI_DEFWITH__c =date.today();
       obCase3.Update_AIMS_TER__c = date.today();
       obCase3.DEF_Approval_Rejection__c = 'Approved';
       obCase3.IRR_Approval_Rejection__c = 'Approved';
       obCase3.TER_Approval_Rejection__c = 'Approved';
       obCase3.Termination_Reason__c  = 'Non Payment';
       obCase3.DEF_Withdrawal_Approval_Rejection__c = 'Approved';
       obCase3.DEF_Withdrawal_Reason__c = 'Billing Error';
       obCase3.REI_ApprovalRejectin__c = 'Approved';
       obCase3.IRR_Withdrawal_Approval_Rejection__c = 'Approved';
       obCase3.IRR_Withdrawal_Reason__c = 'IATA Charges';

        Insert obCase3;
 obCase3 = [select AccountID, id, IATACode__c  from Case where id =: obCase3.Id];
 obCase3.IATAcode__c = '1234567';
 update obCase3;


 Case obCase4 = new Case();
        obCase4.RecordTypeId = RecordTypeId;
        obCase4.Subject = 'TestCase';
        obCase4.Status = 'New';
        obCase4.Origin = 'Web';
        obCase4.BSPCountry__c = 'Canada';
        obCase4.CS_Contact_Result__c = 'Amount disputed';
       obCase4.Update_AIMS_IRR__c = date.today();
       obCase4.Update_AIMS_DEF__c = date.today();
       obCase4.Update_AIMS_IRRWITH__c = date.today();
       obCase4.Update_AIMS_REI_DEFWITH__c =date.today();
       obCase4.Update_AIMS_TER__c = date.today();
       obCase4.DEF_Approval_Rejection__c = 'Approved';
       obCase4.IRR_Approval_Rejection__c = 'Approved';
       obCase4.TER_Approval_Rejection__c = 'Approved';
       obCase4.Termination_Reason__c  = 'Non Payment';
       obCase4.DEF_Withdrawal_Approval_Rejection__c = 'Approved';
       obCase4.DEF_Withdrawal_Reason__c = 'Billing Error';
       obCase4.REI_ApprovalRejectin__c = 'Approved';
       obCase4.IRR_Withdrawal_Approval_Rejection__c = 'Approved';
       obCase4.IRR_Withdrawal_Reason__c = 'IATA Charges';

        Insert obCase4;
 obCase4 = [select AccountID, id, IATACode__c  from Case where id =: obCase4.Id];
 obCase4.IATAcode__c = '1234567891';
 update obCase4;


    }



 }
@isTest
private class FAResultsCtrlTest {

    @isTest
    static void runTest() {

        Case cse;
        List<ENZ__FTPAttachment__c> testDocs;


        ID IFAPcaseRecordType = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        Integer a = 1;
        String results = 'results';


        Case case1 = new Case();

        case1.CaseArea__c = 'TTBS';
        //case1.Tax_Effective_Date__c = Date.valueOf('2011-08-29');
        case1.Origin = 'Other';
        case1.SuppliedEmail = 'paia@iata.org';
        case1.SuppliedPhone = '12456987456';
        case1.Type = 'TFC update';
        case1.Description = 'Testing...';
        case1.Priority = '3';
        case1.Subject = 'TTBS Test Case';
        insert case1;

        Account t = new Account();

        ApexPages.StandardController tempCn  = new ApexPages.StandardController(t);

        ApexPages.StandardController controller   = new ApexPages.StandardController(case1);

        FAResultsCtrl fa = new FAResultsCtrl(controller) ;

        cse = fa.getCse();
        testDocs = fa.getDocs();

        fa.refreshDocs();

    }

}
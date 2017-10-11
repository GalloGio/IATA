@isTest
public class AMS_masterAndSlavePanelCtrlTest{


    private static IATA_ISO_Country__c c1 = new IATA_ISO_Country__c (Name='ARGENTINA',ISO_Code__c='AR')  ;
    private static IATA_ISO_Country__c c2 = new IATA_ISO_Country__c (Name='FRANCE',ISO_Code__c='FR')  ;
    private static IATA_ISO_Country__c c3 = new IATA_ISO_Country__c (Name='U.S.',ISO_Code__c='US')  ;
    private static IATA_ISO_Country__c c4 = new IATA_ISO_Country__c (Name='AUSTRALIA',ISO_Code__c='AU')  ;
    private static IATA_ISO_Country__c c5 = new IATA_ISO_Country__c (Name='AUSTRIA',ISO_Code__c='AT')  ;
    private static IATA_ISO_Country__c c6 = new IATA_ISO_Country__c (Name='CHILE',ISO_Code__c='CL')  ;
    private static IATA_ISO_Country__c c7 = new IATA_ISO_Country__c (Name='COLOMBIA',ISO_Code__c='CO')  ;
    
    
    private static IATA_ISO_State__c stateTX ;
    private static IATA_ISO_State__c stateCA ;
    private static IATA_ISO_State__c stateAL ;

    private static IATA_ISO_Country__c[] ctries = null;
    
    private static IATA_ISO_State__c[] states = null;


    public static void createData(boolean usingController){
        ctries =  new IATA_ISO_Country__c[]{c1,c2,c3,c4,c5,c6,c7};
        //insert ctries;
        upsert ctries;
        //add States
        stateTX = new IATA_ISO_State__c(IATA_ISO_Country__c=c3.Id, NAME='TEXAS',ISO_Code__c='TX');
        stateCA = new IATA_ISO_State__c(IATA_ISO_Country__c=c3.id, NAME='CALIFORNIA',ISO_Code__c='CA');
        stateAL = new IATA_ISO_State__c(IATA_ISO_Country__c=c3.id, NAME='ALABAMA',ISO_Code__c='AL');    
        states =  new IATA_ISO_State__c[]{stateTX,stateCA,stateAL};
        insert states;
        
    }
    
    
    public static String  resizeNumericString(String aString, integer expectedSize){
        String s = aString;
        while(s.length()<expectedSize){
                s = '0'+s;
        }
        system.debug('[IATA CODE Generator] update String from '+aString+' to '+s);
        return s;
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
    public static Account createAgency(String icode, IATA_ISO_Country__c c,String RecordTypeId){
        Account a = new Account(IATA_ISO_Country__c = c.Id);
       
        a.RecordTypeId = RecordTypeId ; 
        a.Name = generateRandomString(10);
        a.Short_Name__c =a.Name;
        a.IATACode__c = icode;
        return a;
    }


    static testMethod void testController(){
       //IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        //insert ctry;
        createData(false);
        Id accountRT = AMS_Utils.getId('Account', 'Standard_Account');
        List<Account> ags = new List<Account>();
        List<AMS_Address__c> adds = new List<AMS_Address__c>();
        for(Integer i=0;i<2;i++){
            String iCode = '102'+ resizeNumericString(''+i,4);
            Account ag = createAgency(iCode,c3, accountRt);
            ags.add(ag);
        }
        insert ags;
        
        AMS_masterAndSlavePanelCtrl ctr = new AMS_masterAndSlavePanelCtrl();
        ctr.setMasterObject(ags.get(0));
        
        ctr.setMasterObject(ags.get(0));
    }

    static testMethod void testController2(){

        PageReference pageRef = Page.AMS_DemoTreeViewPage;
        Test.setCurrentPageReference(pageRef);

        Account acct = new Account(Name='testAccount');
 
        insert acct;
        
        Contact con =new contact(lastname = 'pluto' ,
                                 firstname = 'name',
                                 phone = '123',
                                 accountid = acct.id,
                                 Financial_Assessment_Contact__c = false,
                                 email = 'asd.arg@wewt.et',
                                 HasOptedOutOfEmail = false
                                 );
        insert con;

    AMS_Person__c p1 = new AMS_Person__c(Name='test1', LastName__c='LastName', First_Name__c='FirstNameNotToUse', Email__c='unique@email.com', Contact__c = con.Id);

        insert p1;

        AMS_Employee__c e = new AMS_Employee__c(Name='Employee name',Account__c=acct.Id,Contact__c=con.Id, Person__c = p1.Id);

        insert e;

        ApexPages.CurrentPage().getparameters().put('id', e.id);
        ApexPages.StandardController sc = new ApexPages.standardController(e);
        
        AMS_masterAndSlavePanelCtrl controller = new AMS_masterAndSlavePanelCtrl(sc);

        AMS_masterAndSlavePanelCtrl.Pair p = new AMS_masterAndSlavePanelCtrl.Pair('test1','test2');

        String x1 = 'testString';
        String x2 = 'testString2.string3';

        AMS_masterAndSlavePanelCtrl masterslave = new AMS_masterAndSlavePanelCtrl();
/*
        Case c = new Case();

        masterslave.slaveObject = c;

        masterslave.getFieldValue('Case.CaseNumber');
        masterslave.getFieldValue('Case');
        AMS_masterAndSlavePanelCtrl.normalize('CaseNumber__c');
  */
    }

}
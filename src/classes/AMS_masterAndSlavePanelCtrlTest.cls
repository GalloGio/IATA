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

    private static  Map<string, Id>  agenciesRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');
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
    
    public static AMS_Agency__c createAgency(String icode, IATA_ISO_Country__c c,String RecordTypeId){
        AMS_Agency__c a = new AMS_Agency__c(Country__c = c.Id);
       
        a.RecordTypeId = RecordTypeId ; 
        a.Name = generateRandomString(10);
        a.Legal_Name_1__c =a.Name;
        a.IATACode__c = icode;
        return a;
    }


    static testMethod void testComtroller(){
       //IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        //insert ctry;
        createData(false);
        List<AMS_Agency__c> ags = new List<AMS_Agency__c>();
        List<AMS_Address__c> adds = new List<AMS_Address__c>();
        for(Integer i=0;i<2;i++){
            String iCode = '102'+ resizeNumericString(''+i,4);
            AMS_Agency__c ag = createAgency(iCode,c3,agenciesRT.get('PASSENGER'));
            ags.add(ag);
        }
        insert ags;
        
        AMS_masterAndSlavePanelCtrl ctr = new AMS_masterAndSlavePanelCtrl();
        ctr.setMasterObject(ags.get(0));
        
        Account acc = [select Id from Account where Id in (select Account__c from AMS_Agency__c where Id = :ags.get(1).Id ) limit 1];   
        ctr.setMasterObject(acc);
    }

}
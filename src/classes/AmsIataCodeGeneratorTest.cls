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
public class  AmsIataCodeGeneratorTest
{
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
    private static IATA_ISO_State__c stateFR ;
    private static IATA_ISO_State__c stateCOdefault ;
    private static IATA_ISO_State__c stateFRdefault ;

    //private static  Map<string, Id>  agenciesRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');
    private static  Map<string, Id>  accountsRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Account'}).get('Account');
    private static Id  programRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Segment__c'}).get('AMS_Segment__c').get('IATA_Code_Programs');
    private static Id  codeRangeRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Code_Range__c'}).get('Code_Range__c').get('IATA_Code');
    
    private static AMS_Segment__c p1 = new AMS_Segment__c (label__c='A',RecordTypeId=programRT );
    private static AMS_Segment__c p2 = new AMS_Segment__c (label__c='S',RecordTypeId=programRT );
    private static AMS_Segment__c p3 = new AMS_Segment__c (label__c='C',RecordTypeId=programRT );
    
    private static AMS_Segment__c[] prgms = null;
    
    private static IATA_ISO_Country__c[] ctries = null;
    
    private static IATA_ISO_State__c[] states = null;

    public static String SECTORPAX = 'Travel Agent';
    public static String CATEGORYPAX = 'IATA Passenger Sales Agent';
    public static String LOCCLASSPAX = 'P';
    
    public static String SECTORCASS = 'Cargo Agent';
    public static String CATEGORYCASS = 'IATA Cargo Sales Agent';
    public static String LOCCLASSCASS = 'C';
    
    public static String CHANGELOCATIONTYPE = 'Location type';
    public static String CHANGEOWNERSHIPIATA= 'Ownership to IATA Agent';
    public static String CHANGEOWNERSHIPNONIATA= 'Ownership to non-IATA Agent';

    public static void createData(boolean usingController){
        prgms = new AMS_Segment__c[]{p1,p2,p3};
        insert prgms;
        ctries =  new IATA_ISO_Country__c[]{c1,c2,c3,c4,c5,c6,c7};
        insert ctries;
        
        
        //add States
        stateTX = new IATA_ISO_State__c(IATA_ISO_Country__c=c3.Id, NAME='TEXAS',ISO_Code__c='TX');
        stateCA = new IATA_ISO_State__c(IATA_ISO_Country__c=c3.id, NAME='CALIFORNIA',ISO_Code__c='CA');
        stateAL = new IATA_ISO_State__c(IATA_ISO_Country__c=c3.id, NAME='ALABAMA',ISO_Code__c='AL');
        stateFR = new IATA_ISO_State__c(IATA_ISO_Country__c=c2.id, NAME='FRANCE',ISO_Code__c='FR');
        stateCOdefault = new IATA_ISO_State__c(IATA_ISO_Country__c=c7.id, NAME='COLOMBIA DEFAULT',ISO_Code__c='COdef');
        stateFRdefault = new IATA_ISO_State__c(IATA_ISO_Country__c=c2.id, NAME='FRANCE DEFAULT',ISO_Code__c='FRdef');
        states =  new IATA_ISO_State__c[]{stateTX,stateCA,stateAL,stateFRdefault,stateCOdefault,stateFR};
        insert states;
        
        c7.AMS_Default_State__c = stateCOdefault.ISO_Code__c;
        update c7;

        //c2.AMS_Default_state__c = stateFRdefault.ISO_Code__c;
        //update c2;
        // AMSU-107 forcing billing state to the default state of the ISO Country; 
        // countries that have a default state will have ONLY THAT state below them - as any other state would not be selectable and would be useless
        // => remove the default state for FR
        
        //Load range from Controller
        if(usingController){
            AMS_IataCodeRangesLoaderCtrl2 ctrl = new AMS_IataCodeRangesLoaderCtrl2();
            ctrl.importCSVFile();
            ctrl.saveRecord();
            
            AMS_SettlementsAndOperationLoaderCtrl ctrl2 = new AMS_SettlementsAndOperationLoaderCtrl();
            ctrl2.fileLoaderType = ctrl2.getItems().get(0).getLabel();
            ctrl2.selected=true;
            ctrl2.importCSVFile();
            ctrl2.saveRecord();
            
            
            AMS_SettlementsAndOperationLoaderCtrl ctrl3 = new AMS_SettlementsAndOperationLoaderCtrl();
            ctrl3.fileLoaderType = ctrl3.getItems().get(1).getLabel(); 
            ctrl3.selected=true;
            ctrl3.importCSVFile();
            ctrl3.saveRecord();
             
        }else{
            //create small ranges
            Code_Range__c r1 = new Code_Range__c (Name ='FR1',Area__c=1, 
                                            Area_Code__c=2,Prefix__c='10',IATA_ISO_Country__c=c2.Id,
                                            IATA_ISO_State__c=stateFR.Id,Max_Range__c=9999,Min_Range__c=1, ProgramCode__c = 'P', program__c=p1.id,RecordTypeId=codeRangeRT);
                                            
             Code_Range__c r2 = new Code_Range__c (Name ='US2',Area__c=2, 
                                            Area_Code__c=2,Prefix__c='17',IATA_ISO_Country__c=c3.Id,
                                            IATA_ISO_State__c=stateTX.Id, Max_Range__c=19,Min_Range__c=0, ProgramCode__c = 'C', program__c=p1.id,RecordTypeId=codeRangeRT);
                                            
            Code_Range__c r3 = new Code_Range__c (Name ='CA3',Area__c=3, 
                                            Area_Code__c=3,Prefix__c='17',IATA_ISO_Country__c=c3.Id,
                                            IATA_ISO_State__c=stateCA.Id, Max_Range__c=19,Min_Range__c=0, ProgramCode__c = 'P', program__c=p1.id,RecordTypeId=codeRangeRT);
                                            
            Code_Range__c r4 = new Code_Range__c (Name ='AL4',Area__c=4, 
                                            Area_Code__c=4,Prefix__c='17',IATA_ISO_Country__c=c3.ID,
                                            IATA_ISO_State__c=stateAL.Id, Max_Range__c=19,Min_Range__c=0, ProgramCode__c = 'C', program__c=p1.id,RecordTypeId=codeRangeRT);
                                            
            Code_Range__c r5 = new Code_Range__c (Name ='FR2',Area__c=3, 
                                            Area_Code__c=3,Prefix__c='02',IATA_ISO_Country__c=c2.Id,
                                            IATA_ISO_State__c=stateFRdefault.Id, Max_Range__c=1019,Min_Range__c=1000, ProgramCode__c = 'C', program__c=p1.id,RecordTypeId=codeRangeRT);
            
            Code_Range__c r7 = new Code_Range__c (Name ='FR4',Area__c=4, 
                                            Area_Code__c=3,Prefix__c='57',IATA_ISO_Country__c=c2.Id,
                                            IATA_ISO_State__c=stateFR.Id, Max_Range__c=9019,Min_Range__c=9000, ProgramCode__c = 'C', program__c=p1.id,RecordTypeId=codeRangeRT);

            // Colombia with default state. The accreditation will be having no state at all, but because this default state is set, it shall be used for code generation.
            Code_Range__c r8 = new Code_Range__c (Name ='CO1',Area__c=1, 
                                            Area_Code__c=1,Prefix__c='99',IATA_ISO_Country__c=c7.Id,
                                            IATA_ISO_State__c=stateCOdefault.Id, Max_Range__c=2019,Min_Range__c=2000, ProgramCode__c = 'C', program__c=p1.id, RecordTypeId=codeRangeRT);
            insert new Code_Range__c []{r1,r2,r3,r4,r5,r7,r8};
        }
        
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
    
    public static Account createAgency(String icode, IATA_ISO_Country__c c, String sector){
        //AMS_Agency__c a = null;
        Account a = null;
        /*if(icode == null){
            Account acc = new Account(Name='Test Account');
            insert acc ;
            a = new AMS_Agency__c(Account__c=acc.id, Country__c = c.Id);
        }else{
            a = new AMS_Agency__c(Country__c = c.Id);
        }*/
        a = new Account(IATA_ISO_Country__c = c.id, Sector__c = sector);
        a.Location_Class__c = 'C';
        a.RecordTypeId = accountsRT.get('Standard_Account'); 
        a.Name = generateRandomString(10);
        //a.Legal_Name_1__c =a.Name;
        a.IATACode__c = icode;
        a.Reason_for_creation__c = 'New agent';
        /*if(icode != null){
            a.C_Code__c = icode.substring(0,2);
            a.A_Code__c = icode.substring(2,3);
            a.N_Code__c = icode.substring(3,7);
        }*/
        return a;
    }
    
    public static AMS_Address__c createAgencyPrimaryAddress(Account ag, IATA_ISO_Country__c c,IATA_ISO_State__c s ){
        AMS_Address__c a = new AMS_Address__c(Account__c = ag.Id, Country__c = c.Id);
        a.Address_Type__c = 'Primary';
        a.Address_1__c = 'A street';
        if(s!=null)
            a.State__c = s.ID; 
        return a;
    }
    
    static testMethod void testNoISOStateInAccreditation_CountryDefaultStateUsed(){
         createData(false);
         List<Account> ags = new List<Account>();
         List<AMS_Address__c> adds = new List<AMS_Address__c>();
         List< AMS_Agency_Segment__c > agsgts = new List< AMS_Agency_Segment__c >();
         for(Integer i=0;i<10;i++){
            String iCode = '9912'+ AmsIataCodeGenerator.resizeNumericString(''+i,3);
            Account ag = createAgency(iCode,ctries[1],'Travel Agent');
            ags.add(ag);
         }
     
         insert ags;
   
         for(Account a:ags){
             System.debug('[UNITTEST][testNoISOStateInAccreditation_ErrorGivenIfOnlyStateRangesFound] SAve AGT with IATA Code:'+a.IATACode__c);
             agsgts.add(new AMS_Agency_Segment__c(account__c=a.Id, Segment__c = p1.Id));
         }
         insert agsgts;
         Account ag = createAgency(null,ctries[6],'Travel Agent');
         insert ag;
         AMS_Agency_Segment__c aas = new AMS_Agency_Segment__c(account__c=ag.Id, Segment__c = p1.Id);
         insert aas;
         Test.startTest();
         Case cse = new Case();
         insert cse;

         AMS_Pax_Accreditation_Form__c accre = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = cse.id, CASS_Number__c = '123', Location_Class__c = 'C', IATA_ISO_State__c = null, Branch_Office_Country__c = ctries[6].id);
         insert accre;

         ID rtNew = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();
        
         AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = rtNew, Account__c = ag.Id, Process__c = 'NEW.HO.1.0', AMS_Online_Accreditation__c = accre.Id );
         insert theOscar;

         theOscar.STEP6__c = 'Passed';
         update theOscar;

         cse.Oscar__c = theOscar.Id;

         update cse;

         ANG_OscarProcessHelper.EntityUpdater resultUpdated = AmsIataCodeGenerator.generatedAgencyIATACode(ag.Id,accre.id);
         ANG_OscarProcessHelper.updateUpdater(resultUpdated);
         System.debug('******************** result: ' + resultUpdated.errorMessage);
         Test.stopTest();
         system.assertEquals(false, resultUpdated.isFaulty);
         Account agf  = [select id, IATACode__c, Site from Account where Id = :ag.Id];
         System.assertEquals('99120101231', agf.IATACode__c);
    }
    
    static testMethod void testISOStateInAccreditation_ErrorGivenIfNoStateRangesFound(){
         createData(false);
         List<Account> ags = new List<Account>();
         List<AMS_Address__c> adds = new List<AMS_Address__c>();
         List< AMS_Agency_Segment__c > agsgts = new List< AMS_Agency_Segment__c >();
         for(Integer i=0;i<10;i++){
            String iCode = '0231'+ AmsIataCodeGenerator.resizeNumericString(''+i,3);
            Account ag = createAgency(iCode,ctries[1],'Travel Agent');
            ags.add(ag);
         }
     
         insert ags;
   
         for(Account a:ags){
             System.debug('[UNITTEST][testISOStateInAccreditation_ErrorGivenIfNoStateRangesFound] SAve AGT with IATA Code:'+a.IATACode__c);
             agsgts.add(new AMS_Agency_Segment__c(account__c=a.Id, Segment__c = p1.Id));
         }
         insert agsgts;
         Account ag = createAgency(null,ctries[1],'Travel Agent');
         insert ag;
         AMS_Agency_Segment__c aas = new AMS_Agency_Segment__c(account__c=ag.Id, Segment__c = p1.Id);
         insert aas;
         Test.startTest();
         Case cse = new Case();
         insert cse;

         AMS_Pax_Accreditation_Form__c accre = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = cse.id, CASS_Number__c = '123', Location_Class__c = 'C', IATA_ISO_State__c = stateCA.Id, Branch_Office_Country__c = ctries[1].id);
         insert accre;

         ID rtNew = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();
        
         AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = rtNew, Account__c = ag.Id, Process__c = 'NEW.HO.1.0', AMS_Online_Accreditation__c = accre.Id );
         insert theOscar;

         theOscar.STEP6__c = 'Passed';
         update theOscar;

         cse.Oscar__c = theOscar.Id;

         update cse;

         ANG_OscarProcessHelper.EntityUpdater resultUpdated = AmsIataCodeGenerator.generatedAgencyIATACode(ag.Id,accre.id);
         ANG_OscarProcessHelper.updateUpdater(resultUpdated);

         Test.stopTest();
         System.assertEquals(resultUpdated.isFaulty, true);
         System.assertEquals(resultUpdated.errorMessage,'System failed to find an existing range for the Agency based on Primary Address criteria and Type. Please contact your system Administrator.');
         
    }
    
    static testMethod void testHole(){
         //add agencies 
         createData(false);
         List<Account> ags = new List<Account>();
         List<AMS_Address__c> adds = new List<AMS_Address__c>();
         List< AMS_Agency_Segment__c > agsgts = new List< AMS_Agency_Segment__c >();
         for(Integer i=0;i<10;i++){
            String iCode = '0231'+ AmsIataCodeGenerator.resizeNumericString(''+i,3);
            Account ag = createAgency(iCode,c2,'Travel Agent');
            ags.add(ag); 
         }
         for(Integer i=12;i<20;i++){
            String iCode = '0231'+ AmsIataCodeGenerator.resizeNumericString(''+i,3);
            Account ag = createAgency(iCode,c2,'Travel Agent');
            ags.add(ag); 
         }
         
         insert ags;
         
         for(Account a:ags){
             System.debug('[UNITTEST][testHole] SAve AGT with IATA Code:'+a.IATACode__c);
             agsgts.add(new AMS_Agency_Segment__c(account__c=a.Id, Segment__c = p1.Id));
         }
         insert agsgts;
         
         Account ag = createAgency(null, ctries[1],'Travel Agent');
         ag.CASS_Number__c = '123';
         insert ag;
         AMS_Agency_Segment__c aas = new AMS_Agency_Segment__c(account__c=ag.Id, Segment__c = p1.Id);
         insert aas;
         
         Account ag2 = createAgency(null, ctries[1],'Travel Agent');
         ag2.CASS_Number__c = '124';
         insert ag2;
         AMS_Agency_Segment__c aas2 = new AMS_Agency_Segment__c(account__c=ag2.Id, Segment__c = p1.Id);
         insert aas2;
         
         Test.startTest();
         Case cse = new Case();
         insert cse;
         AMS_Pax_Accreditation_Form__c accre = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = cse.id, CASS_Number__c = '123', IATA_ISO_State__c = stateFRdefault.Id, Location_Class__c = 'C', Branch_Office_Country__c = ctries[1].id);
         insert accre;

         ID rtNew = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();
        
         AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = rtNew, Account__c = ag.Id, Process__c = 'NEW.HO.1.0', AMS_Online_Accreditation__c = accre.Id );
         insert theOscar;

         theOscar.STEP6__c = 'Passed';
         update theOscar;

         cse.Oscar__c = theOscar.Id;

         update cse;

         ANG_OscarProcessHelper.EntityUpdater resultUpdated = AmsIataCodeGenerator.generatedAgencyIATACode(ag.Id,accre.id);
         ANG_OscarProcessHelper.updateUpdater(resultUpdated);

         Case cse2 = new Case();
         insert cse2;
         AMS_Pax_Accreditation_Form__c accre2 = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = cse2.id, CASS_Number__c = '124', IATA_ISO_State__c = stateFRdefault.Id, Location_Class__c = 'C', Branch_Office_Country__c = ctries[1].id);
         insert accre2;
        
         AMS_OSCAR__c theOscar2 = new AMS_OSCAR__c(RecordTypeId = rtNew, Account__c = ag2.Id, Process__c = 'NEW.HO.1.0', AMS_Online_Accreditation__c = accre2.Id );
         insert theOscar2;

         theOscar2.STEP6__c = 'Passed';
         update theOscar2;

         cse2.Oscar__c = theOscar2.Id;

         update cse2;

         ANG_OscarProcessHelper.EntityUpdater resultUpdated2 = AmsIataCodeGenerator.generatedAgencyIATACode(ag2.Id,accre2.id);
         ANG_OscarProcessHelper.updateUpdater(resultUpdated2);

         Test.stopTest();
         
         Account agf  = [select id, IATACode__c from Account where Id = :ag.Id ];
         System.debug('********* [UNITTEST][testHole]generated  IATA Code:'+agf.IATACode__c);
         System.debug('********* [UNITTEST][testHole]generator Result :' + resultUpdated.errorMessage);
         // system.assertEquals('IATA Code generated correctly: 02300101230', s[1]);
         System.assertEquals(agf.IATACode__c, '02310101231');
         
         Account agf2  = [select id, IATACode__c from Account where Id = :ag2.Id ];
         System.debug('********* [UNITTEST][testHole]generated  IATA Code:'+agf2.IATACode__c);
         System.debug('********* [UNITTEST][testHole]generator Result :'+resultUpdated2.errorMessage);
         // system.assertEquals('IATA Code generated correctly: 02300111240', s2[1]);
         System.assertEquals(agf2.IATACode__c, '02310111241');

         system.assertEquals(0, AmsIataCodeGenerator.compare2Codes('1a234d f', ' 1234'));
    }

    static testMethod void testIterative(){
         //id, Area__c, Area_Code__c,CARGO__c,Prefix__c,IATA_ISO_Country__c,IATA_ISO_State__c,Max_Range__c,Min_Range__c,PAX__c 
         //add agencies
         createData(false);
         List<Account> ags = new List<Account>();
         List<AMS_Address__c> adds = new List<AMS_Address__c>();
         List< AMS_Agency_Segment__c > agsgts = new List< AMS_Agency_Segment__c >();

         for(Integer i=0;i<15;i++){
            String iCode = '5739'+ AmsIataCodeGenerator.resizeNumericString(''+i,3);
            Account ag = createAgency(iCode,ctries[1], 'Travel Agent');
            ags.add(ag);
           
         }
     
         insert ags;
   
         for(Account a:ags){
             System.debug('[UNITTEST] SAve AGT with IATA Code:'+a.IATACode__c);
             agsgts.add(new AMS_Agency_Segment__c(account__c=a.Id, Segment__c = p1.Id));
         }
         insert agsgts;
     
         Account ag = createAgency(null,ctries[1],'Travel Agent');
         ag.CASS_Number__c = '123';
         insert ag;
         AMS_Agency_Segment__c aas = new AMS_Agency_Segment__c(account__c=ag.Id, Segment__c = p1.Id);
         insert aas;
         Test.startTest();

         Case cse = new Case();
         insert cse;
         
         AMS_Pax_Accreditation_Form__c accre = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = cse.id, CASS_Number__c = '123', IATA_ISO_State__c = stateFR.Id, Location_Class__c = 'C', Branch_Office_Country__c = ctries[1].id);
         insert accre;

         ID rtNew = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();
        
         AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = rtNew, Account__c = ag.Id, Process__c = 'NEW.HO.1.0', AMS_Online_Accreditation__c = accre.Id );
         insert theOscar;

         theOscar.STEP6__c = 'Passed';
         update theOscar;

         cse.Oscar__c = theOscar.Id;

         update cse;

         ANG_OscarProcessHelper.EntityUpdater resultUpdated = AmsIataCodeGenerator.generatedAgencyIATACode(ag.Id, accre.id);
         ANG_OscarProcessHelper.updateUpdater(resultUpdated);

         Test.stopTest();
         Account agf  = [select id, IATACode__c from Account where Id = :ag.Id ];
         System.debug('[UNITTEST][testIterative]generated  IATA Code:'+agf.IATACode__c);
         System.debug('[UNITTEST][testIterative]generator Result :'+resultUpdated.errorMessage);
         // system.assertEquals('IATA Code generated correctly: 02310151233', s[1]);
         System.assertEquals('57390151232', agf.IATACode__c);
    }
    
    static testMethod void testIterativeForPassenger(){
         //id, Area__c, Area_Code__c,CARGO__c,Prefix__c,IATA_ISO_Country__c,IATA_ISO_State__c,Max_Range__c,Min_Range__c,PAX__c 
         //add agencies
         createData(false);
         List<Account> ags = new List<Account>();
         List<AMS_Address__c> adds = new List<AMS_Address__c>();
         List< AMS_Agency_Segment__c > agsgts = new List< AMS_Agency_Segment__c >();

         for(Integer i=1;i<16;i++){
            String iCode = '102'+ AmsIataCodeGenerator.resizeNumericString(''+i,4)+'3';
            Account ag = createAgency(iCode,ctries[1], 'Travel Agent');
            ags.add(ag);
           
         }
     
         insert ags;
   
         for(Account a:ags){
             System.debug('[UNITTEST] SAve AGT with IATA Code:'+a.IATACode__c);
             agsgts.add(new AMS_Agency_Segment__c(account__c=a.Id, Segment__c = p1.Id));
         }
         insert agsgts;
     
         Account ag = createAgency(null,ctries[1],'Travel Agent');
         ag.CASS_Number__c = '123';
         insert ag;
         AMS_Agency_Segment__c aas = new AMS_Agency_Segment__c(account__c=ag.Id, Segment__c = p1.Id);
         insert aas;
         Test.startTest();

         Case cse = new Case();
         insert cse;
         
         AMS_Pax_Accreditation_Form__c accre = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = cse.id, CASS_Number__c = '123', IATA_ISO_State__c = stateFR.Id, Location_Class__c = 'P', Branch_Office_Country__c = ctries[1].id);
         insert accre;

         ID rtNew = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();
        
         AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = rtNew, Account__c = ag.Id, Process__c = 'NEW.HO.1.0', AMS_Online_Accreditation__c = accre.Id );
         insert theOscar;

         theOscar.STEP6__c = 'Passed';
         update theOscar;

         cse.Oscar__c = theOscar.Id;

         update cse;


         ANG_OscarProcessHelper.EntityUpdater resultUpdated = AmsIataCodeGenerator.generatedAgencyIATACode(ag.Id, accre.id);
         ANG_OscarProcessHelper.updateUpdater(resultUpdated);
         Test.stopTest();
         Account agf  = [select id, IATACode__c from Account where Id = :ag.Id ];
         System.debug('[UNITTEST][testIterative]generated  IATA Code:'+agf.IATACode__c);
         System.debug('[UNITTEST][testIterative]generator Result :'+resultUpdated.errorMessage);
         
         System.assertEquals('10200164', agf.IATACode__c);
         
         
         
         Account ag2 = createAgency(null,ctries[1],'Travel Agent');
         ag2.CASS_Number__c = '123';
         insert ag2;
         AMS_Agency_Segment__c aas2 = new AMS_Agency_Segment__c(account__c=ag2.Id, Segment__c = p1.Id);
         insert aas2;

         Case cse2 = new Case();
         insert cse2;
         
         AMS_Pax_Accreditation_Form__c accre2 = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = cse2.id, CASS_Number__c = '123', IATA_ISO_State__c = stateFR.Id, Location_Class__c = 'P', Branch_Office_Country__c = ctries[1].id);
         insert accre2;
        
         AMS_OSCAR__c theOscar2 = new AMS_OSCAR__c(RecordTypeId = rtNew, Account__c = ag2.Id, Process__c = 'NEW.HO.1.0', AMS_Online_Accreditation__c = accre2.Id );
         insert theOscar2;

         theOscar2.STEP6__c = 'Passed';
         update theOscar2;

         cse2.Oscar__c = theOscar2.Id;

         update cse2;


         ANG_OscarProcessHelper.EntityUpdater resultUpdated2 = AmsIataCodeGenerator.generatedAgencyIATACode(ag2.Id, accre2.id);
         ANG_OscarProcessHelper.updateUpdater(resultUpdated2);

         Account agf2  = [select id, IATACode__c from Account where Id = :ag2.Id ];
         System.debug('[UNITTEST][testIterative]generated  IATA Code:'+agf2.IATACode__c);
         System.debug('[UNITTEST][testIterative]generator Result :'+resultUpdated2.errorMessage);
         
         System.assertEquals('10200175', agf2.IATACode__c);
    }
    
    
    
    static testMethod void testLongIATACode_shouldSubstring(){
         //id, Area__c, Area_Code__c,CARGO__c,Prefix__c,IATA_ISO_Country__c,IATA_ISO_State__c,Max_Range__c,Min_Range__c,PAX__c 
         //add agencies
         createData(false);
         List<Account> ags = new List<Account>();
         List<AMS_Address__c> adds = new List<AMS_Address__c>();
         List< AMS_Agency_Segment__c > agsgts = new List< AMS_Agency_Segment__c >();

         for(Integer i=0;i<15;i++){
            // create a longer than usual IATACode
            String iCode = '5739'+ AmsIataCodeGenerator.resizeNumericString(''+i,3)+'1234';
            Account ag = createAgency(iCode,ctries[1], 'Travel Agent');
            ags.add(ag);
         }
     
         insert ags;
   
         for(Account a:ags){
             System.debug('[UNITTEST] SAve AGT with IATA Code:'+a.IATACode__c);
             agsgts.add(new AMS_Agency_Segment__c(account__c=a.Id, Segment__c = p1.Id));
         }
         insert agsgts;
     
         Account ag = createAgency(null,ctries[1],'Travel Agent');
         ag.CASS_Number__c = '123';
         insert ag;
         AMS_Agency_Segment__c aas = new AMS_Agency_Segment__c(account__c=ag.Id, Segment__c = p1.Id);
         insert aas;
         Test.startTest();

         Case cse = new Case();
         insert cse;
         
         AMS_Pax_Accreditation_Form__c accre = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = cse.id, CASS_Number__c = '123', IATA_ISO_State__c = stateFR.Id, Location_Class__c = 'C', Branch_Office_Country__c = ctries[1].id);
         insert accre;

         ID rtNew = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();
        
         AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = rtNew, Account__c = ag.Id, Process__c = 'NEW.HO.1.0', AMS_Online_Accreditation__c = accre.Id );
         insert theOscar;

         theOscar.STEP6__c = 'Passed';
         update theOscar;

         cse.Oscar__c = theOscar.Id;

         update cse;


         ANG_OscarProcessHelper.EntityUpdater resultUpdated = AmsIataCodeGenerator.generatedAgencyIATACode(ag.Id, accre.id);
         ANG_OscarProcessHelper.updateUpdater(resultUpdated);

         Test.stopTest();
         Account agf  = [select id, IATACode__c, Site from Account where Id = :ag.Id ];
         System.debug('[UNITTEST][testLongIATACode_shouldSubstring]generated  IATA Code:'+agf.IATACode__c);
         System.debug('[UNITTEST][testLongIATACode_shouldSubstring]generator Result :'+resultUpdated.errorMessage);
         // system.assertEquals('IATA Code generated correctly: 02310151233', s[1]);
         System.assertEquals(agf.IATACode__c, '57390151232');
         System.assertEquals(agf.Site, '5739015123');
    }
    
    static testMethod void testWithDuplicateEntriesAndTooShortIATACode(){
         //id, Area__c, Area_Code__c,CARGO__c,Prefix__c,IATA_ISO_Country__c,IATA_ISO_State__c,Max_Range__c,Min_Range__c,PAX__c 
         //add agencies
         createData(false);
         List<Account> ags = new List<Account>();
         List<AMS_Address__c> adds = new List<AMS_Address__c>();
         List< AMS_Agency_Segment__c > agsgts = new List< AMS_Agency_Segment__c >();
         
         ags.add(createAgency('573', ctries[1], 'Travel Agent'));                      
         ags.add(createAgency('57390000000', ctries[1], 'Travel Agent'));
         ags.add(createAgency('57390010034', ctries[1], 'Travel Agent'));
         ags.add(createAgency('57390010012', ctries[1], 'Travel Agent'));
         ags.add(createAgency('57390020000', ctries[1], 'Travel Agent'));
         ags.add(createAgency('57390020000', ctries[1], 'Travel Agent'));
         ags.add(createAgency('57390020000', ctries[1], 'Travel Agent'));
         ags.add(createAgency('57390020000', ctries[1], 'Travel Agent'));
         ags.add(createAgency('57390020000', ctries[1], 'Travel Agent'));
         ags.add(createAgency('57390020000', ctries[1], 'Travel Agent'));
         insert ags;
        
         for(Account a:ags){
             System.debug('[UNITTEST] SAve AGT with IATA Code:'+a.IATACode__c);
             agsgts.add(new AMS_Agency_Segment__c(account__c=a.Id, Segment__c = p1.Id));
         }
         insert agsgts;
     
         Account ag = createAgency(null,ctries[1],'Travel Agent');
         ag.CASS_Number__c = '123';
         ag.ISO_State__c = StateFR.Id;
         insert ag;
         AMS_Agency_Segment__c aas = new AMS_Agency_Segment__c(account__c=ag.Id, Segment__c = p1.Id);
         insert aas;
         Test.startTest();

         Case cse = new Case();
         insert cse;
         System.debug('****************** fr: '+stateFR);
         AMS_Pax_Accreditation_Form__c accre = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = cse.id, CASS_Number__c = '123', IATA_ISO_State__c = stateFR.Id, Location_Class__c = 'C', Branch_Office_Country__c = ctries[1].id);
         insert accre;

         ID rtNew = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();
        
         AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = rtNew, Account__c = ag.Id, Process__c = 'NEW.HO.1.0', AMS_Online_Accreditation__c = accre.Id );
         insert theOscar;

         theOscar.STEP6__c = 'Passed';
         update theOscar;

         cse.Oscar__c = theOscar.Id;

         update cse;

         ANG_OscarProcessHelper.EntityUpdater resultUpdated = AmsIataCodeGenerator.generatedAgencyIATACode(ag.Id, accre.id);
         ANG_OscarProcessHelper.updateUpdater(resultUpdated);

         Test.stopTest();
         Account agf  = [select id, IATACode__c, Site from Account where Id = :ag.Id ];
         System.debug('[UNITTEST][testLongIATACode_shouldSubstring]generated  IATA Code:'+agf.IATACode__c);
         System.debug('[UNITTEST][testLongIATACode_shouldSubstring]generator Result :'+resultUpdated.errorMessage);
         // system.assertEquals('IATA Code generated correctly: 02310151233', s[1]);
         System.assertEquals('57390031230', agf.IATACode__c);
    }
    
    static testMethod void testWithDuplicateEntriesAndTooManyIataCodes(){
         //id, Area__c, Area_Code__c,CARGO__c,Prefix__c,IATA_ISO_Country__c,IATA_ISO_State__c,Max_Range__c,Min_Range__c,PAX__c 
         //add agencies
        createData(false);
        List<Account> ags = new List<Account>();
        List<AMS_Address__c> adds = new List<AMS_Address__c>();
        List< AMS_Agency_Segment__c > agsgts = new List< AMS_Agency_Segment__c >();
        for(Integer i=0;i<1000;i++)
        {
            String iCode = '573'+ AmsIataCodeGenerator.resizeNumericString(''+i,4)+'1234';
            Account ag = createAgency(iCode,ctries[1], 'Travel Agent');
            ags.add(ag);
        }
        
        insert ags;
        
        Test.startTest();
        List<Account> ags2 = new List<Account>();
        for(Integer i=999;i<1650;i++)
        {
            String iCode = '573'+ AmsIataCodeGenerator.resizeNumericString(''+i,4)+'1234';
            Account ag = createAgency(iCode,ctries[1], 'Travel Agent');
            ags2.add(ag);
        }
        insert ags2;
        
        Account ag = createAgency(null,ctries[1],'Travel Agent');
        ag.CASS_Number__c = '123';
        ag.ISO_State__c = StateFR.Id;
        insert ag;
        AMS_Agency_Segment__c aas = new AMS_Agency_Segment__c(account__c=ag.Id, Segment__c = p1.Id);
        insert aas;
        

        Case cse = new Case();
        insert cse;
        
        Code_Range__c r7 = [select Max_Range__c, Min_Range__c, Name from Code_Range__c where Min_Range__c = 9000 limit 1];
        r7.Min_Range__c = 0;
        r7.Max_Range__c = 9999;
        update r7;
        
        AMS_Pax_Accreditation_Form__c accre = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = cse.id, CASS_Number__c = '123', Location_Class__c = 'C', Branch_Office_Country__c = ctries[1].id, IATA_ISO_State__c = stateFR.Id);
        insert accre;

        ID rtNew = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();
        
         AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = rtNew, Account__c = ag.Id, Process__c = 'NEW.HO.1.0', AMS_Online_Accreditation__c = accre.Id );
         insert theOscar;

         theOscar.STEP6__c = 'Passed';
         update theOscar;

         cse.Oscar__c = theOscar.Id;

         update cse;


        ANG_OscarProcessHelper.EntityUpdater resultUpdated = AmsIataCodeGenerator.generatedAgencyIATACode(ag.Id, accre.id);
        ANG_OscarProcessHelper.updateUpdater(resultUpdated);

        Test.stopTest();
        Account agf  = [select id, IATACode__c, Site from Account where Id = :ag.Id ];
        System.debug('[UNITTEST][testLongIATACode_shouldSubstring]generated  IATA Code:'+agf.IATACode__c);
        System.debug('[UNITTEST][testLongIATACode_shouldSubstring]generator Result :'+resultUpdated.errorMessage);
        System.assertEquals('57316501233', agf.IATACode__c);
    }
    
    static testMethod void testGroupingOfDuplicateRecords_ExpectNoEffect(){
         //id, Area__c, Area_Code__c,CARGO__c,Prefix__c,IATA_ISO_Country__c,IATA_ISO_State__c,Max_Range__c,Min_Range__c,PAX__c 
         //add agencies
        createData(false);
        List<Account> ags = new List<Account>();
        List<AMS_Address__c> adds = new List<AMS_Address__c>();
        List< AMS_Agency_Segment__c > agsgts = new List< AMS_Agency_Segment__c >();
        for(Integer i=0;i<1000;i++)
        {
            String iCode = '57300001234';
            Account ag = createAgency(iCode,ctries[1], 'Travel Agent');
            ags.add(ag);
        }
        
        insert ags;
        
        Test.startTest();
        List<Account> ags2 = new List<Account>();
        for(Integer i=999;i<1650;i++)
        {
            String iCode = '57300011234';
            Account ag = createAgency(iCode,ctries[1], 'Travel Agent');
            ags2.add(ag);
        }
        insert ags2;
        
        Account ag = createAgency(null,ctries[1],'Travel Agent');
        ag.CASS_Number__c = '123';
        ag.ISO_State__c = StateFR.Id;
        insert ag;
        AMS_Agency_Segment__c aas = new AMS_Agency_Segment__c(account__c=ag.Id, Segment__c = p1.Id);
        insert aas;
        

        Case cse = new Case();
        insert cse;
        
        Code_Range__c r7 = [select Max_Range__c, Min_Range__c, Name from Code_Range__c where Min_Range__c = 9000 limit 1];
        r7.Min_Range__c = 0;
        r7.Max_Range__c = 1000;
        update r7;
        
        AMS_Pax_Accreditation_Form__c accre = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = cse.id, CASS_Number__c = '123', Location_Class__c = 'C', Branch_Office_Country__c = ctries[1].id, IATA_ISO_State__c = stateFR.Id);
        insert accre;

        ID rtNew = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();
        
         AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = rtNew, Account__c = ag.Id, Process__c = 'NEW.HO.1.0', AMS_Online_Accreditation__c = accre.Id );
         insert theOscar;

         theOscar.STEP6__c = 'Passed';
         update theOscar;

         cse.Oscar__c = theOscar.Id;

         update cse;


        ANG_OscarProcessHelper.EntityUpdater resultUpdated = AmsIataCodeGenerator.generatedAgencyIATACode(ag.Id, accre.id);
        ANG_OscarProcessHelper.updateUpdater(resultUpdated);

        Test.stopTest();
        Account agf  = [select id, IATACode__c, Site from Account where Id = :ag.Id ];
        System.debug('[UNITTEST][testLongIATACode_shouldSubstring]generated  IATA Code:'+agf.IATACode__c);
        System.debug('[UNITTEST][testLongIATACode_shouldSubstring]generator Result :'+resultUpdated.errorMessage);
        System.assertEquals('57300021236', agf.IATACode__c);
    }
    
    static testMethod void testGroupingOfDuplicateRecordsWithAHole(){
         //id, Area__c, Area_Code__c,CARGO__c,Prefix__c,IATA_ISO_Country__c,IATA_ISO_State__c,Max_Range__c,Min_Range__c,PAX__c 
         //add agencies
        createData(false);
        List<Account> ags = new List<Account>();
        List<AMS_Address__c> adds = new List<AMS_Address__c>();
        List< AMS_Agency_Segment__c > agsgts = new List< AMS_Agency_Segment__c >();
        for(Integer i=0;i<1000;i++)
        {
            String iCode = '57300001234';
            Account ag = createAgency(iCode,ctries[1], 'Travel Agent');
            ags.add(ag);
        }
        
        insert ags;
        
        Test.startTest();
        List<Account> ags2 = new List<Account>();
        for(Integer i=999;i<1650;i++)
        {
            String iCode = '57300021234';
            Account ag = createAgency(iCode,ctries[1], 'Travel Agent');
            ags2.add(ag);
        }
        insert ags2;
        
        Account ag = createAgency(null,ctries[1],'Travel Agent');
        ag.CASS_Number__c = '123';
        ag.ISO_State__c = StateFR.Id;
        insert ag;
        AMS_Agency_Segment__c aas = new AMS_Agency_Segment__c(account__c=ag.Id, Segment__c = p1.Id);
        insert aas;
        

        Case cse = new Case();
        insert cse;
        
        Code_Range__c r7 = [select Max_Range__c, Min_Range__c, Name from Code_Range__c where Min_Range__c = 9000 limit 1];
        r7.Min_Range__c = 0;
        r7.Max_Range__c = 1000;
        update r7;
        
        AMS_Pax_Accreditation_Form__c accre = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = cse.id, CASS_Number__c = '123', Location_Class__c = 'C', Branch_Office_Country__c = ctries[1].id, IATA_ISO_State__c = stateFR.Id);
        insert accre;

        ID rtNew = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();
        
         AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = rtNew, Account__c = ag.Id, Process__c = 'NEW.HO.1.0', AMS_Online_Accreditation__c = accre.Id );
         insert theOscar;

         theOscar.STEP6__c = 'Passed';
         update theOscar;

         cse.Oscar__c = theOscar.Id;

         update cse;

        ANG_OscarProcessHelper.EntityUpdater resultUpdated = AmsIataCodeGenerator.generatedAgencyIATACode(ag.Id, accre.id);
        ANG_OscarProcessHelper.updateUpdater(resultUpdated);

        Test.stopTest();
        Account agf  = [select id, IATACode__c, Site from Account where Id = :ag.Id ];
        System.debug('[UNITTEST][testLongIATACode_shouldSubstring]generated  IATA Code:'+agf.IATACode__c);
        System.debug('[UNITTEST][testLongIATACode_shouldSubstring]generator Result :'+resultUpdated.errorMessage);
        System.assertEquals('57300011230', agf.IATACode__c);
    }
    
    static testMethod void testNoSlot(){
         //id, Area__c, Area_Code__c,CARGO__c,Prefix__c,IATA_ISO_Country__c,IATA_ISO_State__c,Max_Range__c,Min_Range__c,PAX__c 
         //add agencies
         createData(false);
         List<Account> ags = new List<Account>();
         List<AMS_Address__c> adds = new List<AMS_Address__c>();
         List< AMS_Agency_Segment__c > agsgts = new List< AMS_Agency_Segment__c >();
         for(Integer i=0;i<20;i++){
            String iCode = '5739'+ AmsIataCodeGenerator.resizeNumericString(''+i,3)+'1239';
            Account ag = createAgency(iCode,ctries[1],'Travel Agent');
            ags.add(ag);
         }
     
         insert ags;
   
         for(Account a:ags){
             System.debug('[UNITTEST][NoSlot] SAve AGT with IATA Code:'+a.IATACode__c);
             agsgts.add(new AMS_Agency_Segment__c(account__c=a.Id, Segment__c = p1.Id));
         }
         insert agsgts;
         Account ag = createAgency(null,ctries[1],'Travel Agent');
         insert ag;
         AMS_Agency_Segment__c aas = new AMS_Agency_Segment__c(account__c=ag.Id, Segment__c = p1.Id);
         insert aas;
         Test.startTest();
         Case cse = new Case();
         insert cse;
         //AMS_Pax_Accreditation_Form__c accre = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = cse.id);
         AMS_Pax_Accreditation_Form__c accre = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = cse.id, CASS_Number__c = '123', IATA_ISO_State__c = stateFR.Id, Location_Class__c = 'C', Branch_Office_Country__c = ctries[1].id);
         insert accre;

         ID rtNew = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();
        
         AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = rtNew, Account__c = ag.Id, Process__c = 'NEW.HO.1.0', AMS_Online_Accreditation__c = accre.Id );
         insert theOscar;

         theOscar.STEP6__c = 'Passed';
         update theOscar;

         cse.Oscar__c = theOscar.Id;

         update cse;

         ANG_OscarProcessHelper.EntityUpdater resultUpdated = AmsIataCodeGenerator.generatedAgencyIATACode(ag.Id,accre.id);
         ANG_OscarProcessHelper.updateUpdater(resultUpdated);

         Test.stopTest();
         system.assertEquals(resultUpdated.isFaulty,true);
    }
    
    /*
    static testMethod void testStates(){
         //id, Area__c, Area_Code__c,CARGO__c,Prefix__c,IATA_ISO_Country__c,IATA_ISO_State__c,Max_Range__c,Min_Range__c,PAX__c 
         //add agencies
         createData(false);
         List<Account> ags = new List<Account>();
         List<AMS_Address__c> adds = new List<AMS_Address__c>();
         List< AMS_Agency_Segment__c > agsgts = new List< AMS_Agency_Segment__c >();
         for(Integer i=0;i<15;i++){
            String iCode = '113'+ AmsIataCodeGenerator.resizeNumericString(''+i,4);
            Account ag = createAgency(iCode,c3,'Travel Agent');
            ags.add(ag);
         }
     
         insert ags;
         for(Account a:ags){
             System.debug('[UNITTEST] SAve AGT with IATA Code:'+a.IATACode__c);
             agsgts.add(new AMS_Agency_Segment__c(account__c=a.id, Segment__c = p1.Id));
         }
         insert agsgts;

         System.debug('[UNITTEST][State]California 1');     
         Account ag = createAgency(null,c3, 'Travel Agent');
         insert ag;
         AMS_Agency_Segment__c aas = new AMS_Agency_Segment__c(agency__c=ag.Id, Account__c=ag.Id, Segment__c = p1.Id);
         insert aas;
         Test.startTest();
         //AMS_Address__c add = createAgencyPrimaryAddress( ag, c3,stateCA);
         //insert add;
         String[] s = AmsIataCodeGenerator.generatedAgencyIATACode(ag.Id);
         Account agf  = [select id, IATACode__c from Account where Id = :ag.Id ];
         System.debug('[UNITTEST][State]generated  IATA Code:'+agf.IATACode__c);
         System.debug('[UNITTEST][State]generator Result :'+s[0]+' /  '+s[1]);
         system.assert(s[1].equals('1130015'));
         
         System.debug('[UNITTEST][State]Texas');
         ag = createAgency(null,c3, 'Travel Agent');
         insert ag;
         aas = new AMS_Agency_Segment__c(agency__c=ag.Id, Account__c = ag.Id, Segment__c = p1.Id);
         insert aas;
         //add = createAgencyPrimaryAddress( ag, c3,stateTX);
         //insert add;
         s = AmsIataCodeGenerator.generatedAgencyIATACode(ag.Id);
         agf  = [select id, IATACode__c from AMS_Agency__c where Id = :ag.Id ];
         System.debug('[UNITTEST][State]generated  IATA Code:'+agf.IATACode__c);
         System.debug('[UNITTEST][State]generator Result :'+s[0]+' /  '+s[1]);
         system.assert(s[0].equals('2'));
         
         System.debug('[UNITTEST][State]California 2');
         ag = createAgency(null,c3,agenciesRT.get('PASSENGER'));
         insert ag;
         aas = new AMS_Agency_Segment__c(agency__c=ag.Id, Account__c=ag.Id, Segment__c = p1.Id);
         insert aas;
         //add = createAgencyPrimaryAddress( ag, c3,stateCA);
         //insert add;
         s = AmsIataCodeGenerator.generatedAgencyIATACode(ag.Id);
         System.debug('[UNITTEST][State]generator Result :'+s[0]+' /  '+s[1]);
         system.assert(s[1].equals('1130016'));

    }
    */
    
    /*
    static testMethod void testState2s(){
         //id, Area__c, Area_Code__c,CARGO__c,Prefix__c,IATA_ISO_Country__c,IATA_ISO_State__c,Max_Range__c,Min_Range__c,PAX__c 
         //add agencies
         createData(false);
         List<AMS_Agency__c> ags = new List<AMS_Agency__c>();
         List<AMS_Address__c> adds = new List<AMS_Address__c>();
         List< AMS_Agency_Segment__c > agsgts = new List< AMS_Agency_Segment__c >();
         for(Integer i=0;i<15;i++){
            String iCode = '113'+ AmsIataCodeGenerator.resizeNumericString(''+i,4);
            AMS_Agency__c ag = createAgency(iCode,c3,agenciesRT.get('PASSENGER'));
            ags.add(ag);
         }
     
         insert ags;
         for(AMS_Agency__c a:ags){
             System.debug('[UNITTEST] SAve AGT with IATA Code:'+a.IATACode__c);
             agsgts.add(new AMS_Agency_Segment__c(agency__c=a.Id, Segment__c = p1.Id));
         }
         insert agsgts;

         
         System.debug('[UNITTEST][State]ALABAMA');
         AMS_Agency__c ag = createAgency(null,c3,agenciesRT.get('PASSENGER'));
         insert ag;
         AMS_Agency_Segment__c aas = new AMS_Agency_Segment__c(agency__c=ag.Id, Segment__c = p1.Id);
         insert aas;
         Test.startTest();
         AMS_Address__c add = createAgencyPrimaryAddress( ag, c3,stateAL);
         insert add;
         String[] s = AmsIataCodeGenerator.generatedAgencyIATACode(ag.Id);
         Test.stopTest();
         System.debug('[UNITTEST][State]generator Result for AL :'+s[0]+' /  '+s[1]);
         system.assert(s[1].equals('1140000'));
    }
    */
    
    static testMethod void testChildCodeEqualsToParentForCargo_CassNumberDifferent(){
         //add agencies
         createData(false);
         List<Account> ags = new List<Account>();
         List<AMS_Address__c> adds = new List<AMS_Address__c>();
         List< AMS_Agency_Segment__c > agsgts = new List< AMS_Agency_Segment__c >();
         for(Integer i=0;i<10;i++){
            String iCode = '5739'+ AmsIataCodeGenerator.resizeNumericString(''+i,3);
            Account ag = createAgency(iCode,c2,'Travel Agent');
            ags.add(ag); 
         }
         for(Integer i=12;i<20;i++){
            String iCode = '5739'+ AmsIataCodeGenerator.resizeNumericString(''+i,3);
            Account ag = createAgency(iCode,c2,'Travel Agent');
            ags.add(ag); 
         }
         
         insert ags;
       
         for(Account a:ags){
             System.debug('[UNITTEST][testChildCodeEqualsToParent] Save AGT with IATA Code:'+a.IATACode__c);
             agsgts.add(new AMS_Agency_Segment__c(account__c=a.Id, Segment__c = p1.Id));
         }
         insert agsgts;
         
         Account ag = createAgency(null, ctries[1],'Travel Agent');
         ag.Sector__c = 'Cargo Agent';
         ag.Cass_Number__c = '121';
         ag.Category__c = '';
         insert ag;
         AMS_Agency_Segment__c aas = new AMS_Agency_Segment__c(account__c=ag.Id, Segment__c = p1.Id);
         insert aas;
         Test.startTest();
         Case cse = new Case();
         cse.QuantityProduct__c = '1';
         insert cse;
         AMS_Pax_Accreditation_Form__c accre = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = cse.id, CASS_Number__c = '123', IATA_ISO_State__c = stateFR.Id, Location_Class__c = 'C', Branch_Office_Country__c = ctries[1].id);
         insert accre;

         ID rtNew = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();
        
         AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = rtNew, Account__c = ag.Id, Process__c = 'NEW.HO.1.0', AMS_Online_Accreditation__c = accre.Id );
         insert theOscar;

         theOscar.STEP6__c = 'Passed';
         update theOscar;

         cse.Oscar__c = theOscar.Id;

         update cse;
         
         ANG_OscarProcessHelper.EntityUpdater resultUpdated = AmsIataCodeGenerator.generatedAgencyIATACode(ag.Id,accre.id);
         ANG_OscarProcessHelper.updateUpdater(resultUpdated);

         List<Account> accList = [select Location_Class__c, Check_Digit__c from account where id = :ag.id];
         System.assert(accList.get(0).Check_Digit__c != null);
         
         Account agf  = [select id, IATACode__c, Category__c from Account where Id = :ag.Id ];
         System.debug('[UNITTEST][testChildCodeEqualsToParent]generated  IATA Code:'+agf.IATACode__c);
         System.debug('[UNITTEST][testChildCodeEqualsToParent]generator Result :'+resultUpdated.errorMessage);
         //system.assertEquals('IATA Code generated correctly: 02310001234', s[1]);
         System.assertEquals(agf.IATACode__c, '57390101230');
         System.assertEquals(agf.Category__c, 'IATA Cargo Agent');
                  
         // Add a child agency and expect the same IATA code to be generated.
         Account ag2 = createAgency(null, ctries[1], 'Travel Agent');
         ag2.ParentId = ag.Id;
         ag2.Top_Parent__c = ag.Id;
         ag2.Cass_Number__c = '543';
         ag2.Sector__c = 'Cargo Agent';
         insert ag2;
         
         AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = ag2.Id);
         insert oscar;
         oscar.STEP6__c = 'Passed';
         update oscar;
         AMS_Agency_Segment__c aas2 = new AMS_Agency_Segment__c(account__c=ag2.Id, Segment__c = p1.Id);
         insert aas2;
         Case cse2 = new Case(accountId=ag2.id, Oscar__c = oscar.Id);
         insert cse2;
         AMS_Pax_Accreditation_Form__c accre2 = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = cse2.id, CASS_Number__c = '543', IATA_ISO_State__c = stateFR.Id, Location_Class__c = 'C', Branch_Office_Country__c = ctries[1].id);
         insert accre2;
         oscar.AMS_Online_Accreditation__c = accre2.Id;
         update oscar;
         
         Account agf2  = [select id, IATACode__c, Top_Parent__c, Check_digit__c from Account where Id = :ag2.Id];
         ANG_OscarProcessHelper.EntityUpdater resultUpdated2  = AmsIataCodeGenerator.generatedAgencyIATACode(ag2.Id,accre2.id);
         ANG_OscarProcessHelper.updateUpdater(resultUpdated2);
         
         agf2  = [select id, IATACode__c, Check_Digit__c from Account where Id = :ag2.Id ];
         // System.assertEquals(s2[1], s[1]);
         // system.assertEquals('IATA Code generated correctly: 02310005434', s2[1]);
         System.assertEquals('57390105430', agf2.IATACode__c);
         System.assertEquals('0', agf2.Check_Digit__c);
         Test.stopTest();
    }
    
    static testMethod void testChildCodeDoesNotEqualToParentForPassenger(){ // PARA ALTERAR
         //add agencies

         createData(false);
         List<Account> ags = new List<Account>();
         List<AMS_Address__c> adds = new List<AMS_Address__c>();
         List< AMS_Agency_Segment__c > agsgts = new List< AMS_Agency_Segment__c >();
         for(Integer i=0;i<10;i++){
            String iCode = '102'+ AmsIataCodeGenerator.resizeNumericString(''+i,4);
            Account ag = createAgency(iCode,c2,'Travel Agent');
            ag.Location_Class__c = 'P';
            ags.add(ag); 
         }

         for(Integer i=12;i<19;i++){
            String iCode = '102'+ AmsIataCodeGenerator.resizeNumericString(''+i,4);
            Account ag = createAgency(iCode,c2,'Travel Agent');
            ag.Location_Class__c = 'P';
            ags.add(ag); 
         }
         
         insert ags;
        
         for(Account a:ags){
             System.debug('[UNITTEST][testChildCodeEqualsToParent] Save AGT with IATA Code:'+a.IATACode__c);
             agsgts.add(new AMS_Agency_Segment__c(account__c=a.Id, Segment__c = p1.Id));
         }
         insert agsgts;
         
         Account ag = createAgency(null, ctries[1],'Travel Agent');
         ag.Location_Class__c = 'P';
         ag.Category__c = 'fdsfdsf';
         insert ag;
         AMS_Agency_Segment__c aas = new AMS_Agency_Segment__c(account__c=ag.Id, Segment__c = p1.Id);
         insert aas;

         Test.startTest();

         Case cse = new Case();
         insert cse;

         AMS_Pax_Accreditation_Form__c accre = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = cse.id , CASS_Number__c = '123', IATA_ISO_State__c = stateFR.Id, Location_Class__c = 'P', Branch_Office_Country__c = ctries[1].id);
         insert accre;

         ID rtNew = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();
         AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = rtNew, Account__c = ag.Id, Process__c = 'NEW.HO.1.0', AMS_Online_Accreditation__c = accre.Id);
         insert theOscar;
         theOscar.STEP6__c = 'Passed';
         update theOscar;

         cse.Oscar__c = theOscar.Id;

        Account theAccount = [SELECT Name, IATACode__c, Company_Type__c, Short_Name__c, TradeName__c, License_Number__c, VAT_Number__c, GDS__c, Operation__c,
                    BillingCountry, BillingStreet, BillingPostalCode, BillingState, BillingCity, IATA_ISO_Country__c, Iso_State__c, ShippingCountry,
                    ShippingStreet, ShippingPostalCode, ShippingState, ShippingCity, Email__c, Website, Phone, Fax, In_a_Airport__c, Abbreviated_name__c, Abbreviated_address__c,
                    Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c
                    ,IATA_ISO_Billing_State__c, IATA_ISO_Shipping_Country__c, IATA_ISO_Shipping_Country__r.Name, IATA_ISO_Shipping_State__c, IATA_ISO_Shipping_State__r.Name, ISO_State__r.Name,
                    Link_agent_name__c, ANG_Accreditation_Model__c, IATA_ISO_Country__r.CurrencyIsoCode, CNS_Agency__c,
                    (SELECT Id FROM RHC_Informations__r), Is_PCI_compliant__c,Link_agent_code__c, Sector__c, Category__c, Check_Digit__c, RecordTypeId,Due_Diligence_Status__c
                    FROM Account
                    WHERE Id =:ag.Id FOR UPDATE];

        AMS_Pax_Accreditation_Form__c theAccreditation = [SELECT Account_Name__c, IATACode__c, ISSP_AMS_Legal_Status__c, Short_Name__c, Trade_Name__c, ISSP_AMS_License_No__c, ISSP_AMS_VAT_number__c,
                    ISSP_AMS_GDS_with_signed_contract__c, Operation__c, Branch_Office_Country__r.Name, Branch_Office_Street_name_number__c, Branch_Office_Postal_code__c,
                    Billing_State__c, Branch_Office_City__c, IATA_ISO_State__c, Shipping_Country__c, Shipping_Street__c, Shipping_Postal_Code__c,
                    Shipping_State__c, Shipping_City__c, Branch_Office_Email__c, Website__c, Branch_Office_Phone__c, Branch_Office_FAX__c, ISSP_AMS_Premises_located_at_airport__c,
                    Abbreviated_name__c, Abbreviated_address__c, Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c
                    ,Shipping_ISO_Country__c,Shipping_ISO_State__c, Shipping_ISO_Country__r.Name, Shipping_ISO_State__r.Name, IATA_ISO_State__r.Name, Link_agent_name__c, IATA_ISO_State__r.Valid_for_Address__c,
                    Link_agent_name__r.Link_agent_code__c, Link_agent_name__r.IATACode__c,Chk_Dgt__c,SAAM_Case__r.Account.Top_Parent__c, SAAM_Case__r.OSCAR__r.Account__r.Top_Parent__r.IATACode__c,
                    Branch_Office_Country__c, Branch_Office_Country__r.AMS_Default_State__c, SAAM_Case__r.Account.Top_Parent__r.Check_Digit__c, SAAM_Case__r.Account.Top_Parent__r.N_Code__c, SAAM_Case__r.Account.Top_Parent__r.C_Code__c, 
                    SAAM_Case__r.Account.Top_Parent__r.A_Code__c, SAAM_Case__r.Account.Top_Parent__r.IATACode__c, ISO_country__c, N_Code__c, A_Code__c, C_Code__c,
                    SAAM_Case__r.OSCAR__r.Process__c, ANG_IsNewGenAgency__c, SAAM_Case__r.OSCAR__r.STEP6__c,Branch_Office_Country__r.Due_diligence_mandatory__c
                    FROM AMS_Pax_Accreditation_Form__c
                    WHERE Id = :accre.Id FOR UPDATE];

         ANG_OscarProcessHelper.EntityUpdater resultUpdated = AmsIataCodeGenerator.generatedAgencyIATACode(theAccount,theAccreditation, null);
         ANG_OscarProcessHelper.updateUpdater(resultUpdated);
         
         
         Account agf  = [select id, IATACode__c, Category__c, Location_Class__c from Account where Id = :ag.Id ];
         System.debug('[UNITTEST][testChildCodeEqualsToParent]generated  IATA Code:'+agf.IATACode__c);
         System.debug('[UNITTEST][testChildCodeEqualsToParent]generator Result :'+resultUpdated.errorMessage);
         // system.assertEquals('IATA Code generated correctly: 10200105', s[1]);
         System.assertEquals(agf.IATACode__c, '10200105');
         System.assertEquals(agf.Category__c, 'IATA Passenger Sales Agent');
         
         // Add a child agency and expect the same IATA code to be generated.
         Account ag2 = createAgency(null, ctries[1], 'Travel Agent');
         ag2.ParentId = ag.Id;
         ag2.Top_Parent__c = ag.Id;
         ag2.Location_Class__c = 'P';
         insert ag2;

         AMS_Agency_Segment__c aas2 = new AMS_Agency_Segment__c(account__c=ag2.Id, Segment__c = p1.Id);
         insert aas2;
         Case cse2 = new Case(accountId=ag2.id);
         insert cse2;
         AMS_Pax_Accreditation_Form__c accre2 = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = cse2.id, IATA_ISO_State__c=stateFR.Id, Location_Class__c = 'P', Branch_Office_Country__c = ctries[1].id);
         insert accre2;
         Account agf2  = [select id, IATACode__c, Top_Parent__c, Check_Digit__c, Site from Account where Id = :ag2.Id ];

         AMS_OSCAR__c theOscar2 = new AMS_OSCAR__c(RecordTypeId = rtNew, Account__c = agf2.Id, Process__c = 'NEW.HO.1.0', AMS_Online_Accreditation__c = accre2.Id);
         insert theOscar2;

         theOscar2.STEP6__c = 'Passed';
         update theOscar2;

         cse2.Oscar__c = theOscar2.Id;
         update cse2;
         
         ANG_OscarProcessHelper.EntityUpdater resultUpdated2  = AmsIataCodeGenerator.generatedAgencyIATACode(agf2.Id,accre2.id);
         ANG_OscarProcessHelper.updateUpdater(resultUpdated2);

         agf2  = [select id, IATACode__c, Site from Account where Id = :ag2.Id ];
         //System.assertEquals(s2[1], 'IATA Code generated correctly: 10200116');
         System.assertEquals('10200116', agf2.IATACode__c);
         System.assertEquals('1020011', agf2.Site);
         Test.stopTest();
    }
    
    static testMethod void testDigitCreation(){
        createData(false);
        List<Account> ags = new List<Account>();
        Account ag = createAgency('GB20000',ctries[1],'Travel Agent');
        ags.add(ag);
        insert ags;
        Case cse = new Case();
        insert cse;
        AMS_Pax_Accreditation_Form__c accre = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = cse.id,A_code__c='4',N_code__c='9876');
        insert accre;

        Test.startTest();
        AmsIataCodeGenerator.checkDigitCreation(accre,ag);
        Test.stopTest();
    }

    static testMethod void testUnexistingRange(){
         createData(false);
         Account ag = createAgency(null,ctries[0],'Travel Agent');
         insert ag;
         Case cse = new Case();
         insert cse;
         AMS_Pax_Accreditation_Form__c accre = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = cse.id, CASS_Number__c = '123', IATA_ISO_State__c = stateFR.Id, Location_Class__c = 'C', Branch_Office_Country__c = ctries[0].id);
         insert accre;

         ID rtNew = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();
         AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = rtNew, Account__c = ag.Id, Process__c = 'NEW.HO.1.0', AMS_Online_Accreditation__c = accre.Id);
         insert theOscar;

         theOscar.STEP6__c = 'Passed';
         update theOscar;

         cse.Oscar__c = theOscar.Id;

         update cse;

         Test.startTest();
         ANG_OscarProcessHelper.EntityUpdater resultUpdated = AmsIataCodeGenerator.generatedAgencyIATACode(ag.Id, accre.id);
         ANG_OscarProcessHelper.updateUpdater(resultUpdated);
         
         Test.stopTest();
         Account agf  = [select id, IATACode__c from Account where Id = :ag.Id ];
         System.debug('[UNITTEST][Unexisting]generated  IATA Code:'+agf.IATACode__c);
         System.debug('[UNITTEST][Unexisting]generator Result :'+ resultUpdated.errorMessage);
         system.assertEquals(resultUpdated.isFaulty,true);
    }
    
    
    static testMethod void testLogsToUser(){
         //id, Area__c, Area_Code__c,CARGO__c,Prefix__c,IATA_ISO_Country__c,IATA_ISO_State__c,Max_Range__c,Min_Range__c,PAX__c 
         //add agencies
         createData(false);
         List<Account> ags = new List<Account>();
         List<AMS_Address__c> adds = new List<AMS_Address__c>();
         List< AMS_Agency_Segment__c > agsgts = new List< AMS_Agency_Segment__c >();

         for(Integer i=0;i<15;i++){
            String iCode = '102'+ AmsIataCodeGenerator.resizeNumericString(''+i,4);
            Account ag = createAgency(iCode,ctries[1], 'Travel Agent');
            ags.add(ag);
           
         }
     
         insert ags;
   
         for(Account a:ags){
             System.debug('[UNITTEST] SAve AGT with IATA Code:'+a.IATACode__c);
             agsgts.add(new AMS_Agency_Segment__c(account__c=a.Id, Segment__c = p1.Id));
         }
         insert agsgts;

         Account ag = createAgency(null,ctries[1],'Travel Agent');
         insert ag;
         AMS_Agency_Segment__c aas = new AMS_Agency_Segment__c(account__c=ag.Id, Segment__c = p1.Id);
         insert aas;
         Test.startTest();
         Case cse = new Case();
         insert cse;
         AMS_Pax_Accreditation_Form__c accre = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = cse.id);
         insert accre;

         ID rtNew = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();
         AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = rtNew, Account__c = ag.Id, Process__c = 'NEW.HO.1.0', AMS_Online_Accreditation__c = accre.Id);
         insert theOscar;

         theOscar.STEP6__c = 'Passed';
         update theOscar;

         cse.Oscar__c = theOscar.Id;

         update cse;

         ANG_OscarProcessHelper.EntityUpdater resultUpdated = AmsIataCodeGenerator.generatedAgencyIATACode(ag.Id,accre.id);
         ANG_OscarProcessHelper.updateUpdater(resultUpdated);
         Test.stopTest();
    }

    @testSetup static void setup(){

        



    }

     static testMethod void validateCassUniquenessTest(){
        
        ID standardRT = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('Standard_Account') ;
        
        //HO
        Account account1 = new Account(RecordTypeId = standardRT, Name = 'My Travels HO',  IATA_ISO_Country__c = c2.Id, 
                         Sector__c = 'Cargo Agent', Category__c = 'Non-IATA Cargo Agent', 
                         Location_Class__c = 'C', Location_Type__c = 'HO', Status__c = 'New application pending',
                         Short_Name__c = 'Short name', BillingCity = 'Lisbon', Email__c = 'testeteste@fefe3.com',REASON_FOR_CREATION__C = 'Created by customer'
                         ,CASS_Number__c ='000', IATACode__c = '02310000000');
       
        
        insert account1;
        
        
        //BR
        Account account1Br = new Account(RecordTypeId = standardRT, Name = 'My Travels BR1',  IATA_ISO_Country__c = c2.Id,
                         Sector__c = 'Cargo Agent', Category__c = 'Non-IATA Cargo Agent', 
                         Location_Class__c = 'C', Location_Type__c = 'BR', Status__c = 'New application pending',
                         Short_Name__c = 'Short name', BillingCity = 'Lisbon', Email__c = 'testeteste@fefe3.com', ParentId=account1.Id,REASON_FOR_CREATION__C = 'Created by customer'
                         ,CASS_Number__c ='001', Top_Parent__c = account1.Id);
       
        
        

        //BR
        Account account2Br = new Account(RecordTypeId = standardRT, Name = 'My Travels BR2',  IATA_ISO_Country__c = c2.Id,
                         Sector__c = 'Cargo Agent', Category__c = 'Non-IATA Cargo Agent', 
                         Location_Class__c = 'C', Location_Type__c = 'BR', Status__c = 'New application pending',
                         Short_Name__c = 'Short name', BillingCity = 'Lisbon', Email__c = 'testeteste@fefe3.com',ParentId=account1.Id,REASON_FOR_CREATION__C = 'Created by customer'
                        ,CASS_Number__c ='002', Top_Parent__c = account1.Id);
       
        
        List<Account> accounts = new List<Account>{account1Br,account2Br};
        insert accounts;

        Contact contact1 = new Contact(FirstName = 'First', LastName = 'Contact',  AccountId = account1.Id, Email = 'thecontact1@gmail.com', Phone = '123123123');

        insert contact1;
        
    
        AMS_Agencies_Hierarchy__c hier = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c='Test Hierarchy');

        insert hier;

        List<AMS_Agencies_relationhip__c> rels = new List<AMS_Agencies_relationhip__c>();
        
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hier.Id, Parent_Account__c = account1.Id, Child_Account__c = account1Br.Id, HO_Flag__c = 'true'));
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hier.Id, Parent_Account__c = account1.Id, Child_Account__c = account2Br.Id, HO_Flag__c = 'true'));

        insert rels;

        
        Test.startTest();

        AMS_OSCAR__c oscar1 = createCaseAndOSCAR(account1,contact1,null);
        AMS_OSCAR__c oscar2 = createCaseAndOSCAR(account1Br,contact1,null);
        AMS_Accreditation_Contact__c ac = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = oscar2.AMS_Online_Accreditation__c, First_name__c='Joan', Last_name__c='Wylde', Phone__c='323562762', Email__c='jw@email.com', Valid_Until__c = (Date.today()+91), RecordTypeId=AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Trained_Staff'), Type_Of_Certificate__c = 'DGR');
        insert ac;
        oscar2.STEP6__c = 'Passed';
        update oscar2;
        AMS_OSCAR__c oscar3 = createCaseAndOSCAR(account2Br,contact1,account1Br.Cass_Number__c);
        AMS_Accreditation_Contact__c ac2 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = oscar3.AMS_Online_Accreditation__c, First_name__c='Joan', Last_name__c='Wylde', Phone__c='323562762', Email__c='jw@email.com', Valid_Until__c = (Date.today()+91), RecordTypeId=AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Trained_Staff'), Type_Of_Certificate__c = 'DGR');
        insert ac2;
        oscar3.STEP6__c = 'Passed';
        update oscar3;

        ANG_OscarProcessHelper.EntityUpdater resultUpdated = AmsIataCodeGenerator.generatedAgencyIATACode(account1Br.Id,oscar2.AMS_Online_Accreditation__c);
        ANG_OscarProcessHelper.updateUpdater(resultUpdated);

        ANG_OscarProcessHelper.EntityUpdater resultUpdated2 = AmsIataCodeGenerator.generatedAgencyIATACode(account2Br.Id,oscar3.AMS_Online_Accreditation__c);
        ANG_OscarProcessHelper.updateUpdater(resultUpdated2);
       

        accounts = [SELECT ID,IATACode__c,RecordTypeId,Name,IATA_ISO_Country__c,Sector__c,Category__c,Location_Class__c,Location_Type__c,Status__c,Short_Name__c,BillingCity,Email__c,ParentId,Reason_for_creation__c,CASS_Number__c  from Account];

        if(accounts.isEmpty())
            System.assert(true,false);

        for(Account acc: accounts){
            if(acc.name == 'My Travels HO')
                account1 = acc;
            if(acc.name == 'My Travels BR1')
                account1Br = acc;
            if(acc.name == 'My Travels BR2')
                account2Br = acc;        
        }

        System.debug('IATA code generated is ' + account1.IATACode__c);
        System.debug('IATA code generated is ' + account1Br.IATACode__c);
        System.debug('IATA code generated is ' + account2Br.IATACode__c);

        System.assertEquals(resultUpdated.isFaulty,false);

        System.assertEquals(resultUpdated2.isFaulty,true);
        System.assertEquals(resultUpdated2.errorMessage.contains('The IATA code generated is not unique. Please check the CASS Number (if it is a branch) in the hierarchy or search for the IATA Code '),true);
        
        Test.stopTest();

    }

     static testMethod void validateCASSNumberandIATACodeErrors(){
        
        ID standardRT = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('Standard_Account') ;
        
        //HO
        Account account1 = new Account(RecordTypeId = standardRT, Name = 'My Travels HO',  IATA_ISO_Country__c = c2.Id, 
                         Sector__c = 'Cargo Agent', Category__c = 'Non-IATA Cargo Agent', 
                         Location_Class__c = 'C', Location_Type__c = 'HO', Status__c = 'New application pending',
                         Short_Name__c = 'Short name', BillingCity = 'Lisbon', Email__c = 'testeteste@fefe3.com',REASON_FOR_CREATION__C = 'Created by customer'
                         ,CASS_Number__c ='000', IATACode__c = '02310000000');
       
        
        insert account1;
        
        
        //BR
        Account account1Br = new Account(RecordTypeId = standardRT, Name = 'My Travels BR1',  IATA_ISO_Country__c = c2.Id,
                         Sector__c = 'Cargo Agent', Category__c = 'Non-IATA Cargo Agent', 
                         Location_Class__c = 'C', Location_Type__c = 'BR', Status__c = 'New application pending',
                         Short_Name__c = 'Short name', BillingCity = 'Lisbon', Email__c = 'testeteste@fefe3.com', ParentId=account1.Id,REASON_FOR_CREATION__C = 'Created by customer'
                         ,CASS_Number__c ='001', Top_Parent__c = account1.Id);
       
        
        

        //BR
        Account account2Br = new Account(RecordTypeId = standardRT, Name = 'My Travels BR2',  IATA_ISO_Country__c = c2.Id,
                         Sector__c = 'Cargo Agent', Category__c = 'Non-IATA Cargo Agent', 
                         Location_Class__c = 'C', Location_Type__c = 'BR', Status__c = 'New application pending',
                         Short_Name__c = 'Short name', BillingCity = 'Lisbon', Email__c = 'testeteste@fefe3.com',ParentId=account1.Id,REASON_FOR_CREATION__C = 'Created by customer'
                        ,CASS_Number__c ='002', Top_Parent__c = account1.Id, IATACode__c = '123456789');



        //BR
        Account account3Br = new Account(RecordTypeId = standardRT, Name = 'My Travels BR2',  IATA_ISO_Country__c = c2.Id,
                         Sector__c = 'Cargo Agent', Category__c = 'Non-IATA Cargo Agent', 
                         Location_Class__c = 'G', Location_Type__c = 'BR', Status__c = 'New application pending',
                         Short_Name__c = 'Short name', BillingCity = 'Lisbon', Email__c = 'testeteste@fefe3.com',ParentId=account1.Id,REASON_FOR_CREATION__C = 'Created by customer'
                        ,CASS_Number__c ='003', Top_Parent__c = account1.Id);

        //BR
        Account account4Br = new Account(RecordTypeId = standardRT, Name = 'My Travels BR2',  IATA_ISO_Country__c = c2.Id,
                         Sector__c = 'Travel Agent', Category__c = 'Non-IATA Travel Agent', 
                         Location_Class__c = 'G', Location_Type__c = 'BR', Status__c = 'New application pending',
                         Short_Name__c = 'Short name', BillingCity = 'Lisbon', Email__c = 'testeteste@fefe3.com',ParentId=account1.Id,REASON_FOR_CREATION__C = 'Created by customer'
                        ,CASS_Number__c = '004', Top_Parent__c = account1.Id);

        //BR
        Account account5Br = new Account(RecordTypeId = standardRT, Name = 'My Travels BR2',  IATA_ISO_Country__c = c2.Id,
                         Sector__c = 'Cargo Agent', Category__c = 'Non-IATA Cargo Agent', 
                         Location_Class__c = 'G', Location_Type__c = 'BR', Status__c = 'New application pending',
                         Short_Name__c = 'Short name', BillingCity = 'Lisbon', Email__c = 'testeteste@fefe3.com',ParentId=account1.Id,REASON_FOR_CREATION__C = 'Created by customer'
                        ,CASS_Number__c ='005', Top_Parent__c = account1.Id);
       
        
        List<Account> accounts = new List<Account>{account1Br, account2Br, account3Br, account4Br, account5Br};
        insert accounts;

        Contact contact1 = new Contact(FirstName = 'First', LastName = 'Contact',  AccountId = account1.Id, Email = 'thecontact1@gmail.com', Phone = '123123123');

        insert contact1;
        
    
        AMS_Agencies_Hierarchy__c hier = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c='Test Hierarchy');

        insert hier;

        List<AMS_Agencies_relationhip__c> rels = new List<AMS_Agencies_relationhip__c>();
        
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hier.Id, Parent_Account__c = account1.Id, Child_Account__c = account1Br.Id, HO_Flag__c = 'true'));
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hier.Id, Parent_Account__c = account1.Id, Child_Account__c = account2Br.Id, HO_Flag__c = 'true'));
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hier.Id, Parent_Account__c = account1.Id, Child_Account__c = account3Br.Id, HO_Flag__c = 'true'));
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hier.Id, Parent_Account__c = account1.Id, Child_Account__c = account4Br.Id, HO_Flag__c = 'true'));
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hier.Id, Parent_Account__c = account1.Id, Child_Account__c = account5Br.Id, HO_Flag__c = 'true'));

        insert rels;

        
        Test.startTest();

        AMS_OSCAR__c oscar1 = createCaseAndOSCAR(account1,contact1,'000');

        AMS_OSCAR__c oscar2 = createCaseAndOSCAR(account1Br,contact1,'001');

        AMS_OSCAR__c oscar3 = createCaseAndOSCAR(account2Br,contact1,'002');

        /*AMS_OSCAR__c oscar4 = createCaseAndOSCAR(account3Br,contact1,'003');

        AMS_OSCAR__c oscar5 = createCaseAndOSCAR(account4Br,contact1,'004');

        AMS_OSCAR__c oscar6 = createCaseAndOSCAR(account5Br,contact1,'005');*/

        AMS_Pax_Accreditation_Form__c accreditationObj = [SELECT ID , CASS_Number__c from AMS_Pax_Accreditation_Form__c where Id in (select AMS_Online_Accreditation__c from AMS_OSCAR__c where Id = :oscar2.Id)];

        AMS_Accreditation_Contact__c ac2 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = accreditationObj.Id, First_name__c='Joan', Last_name__c='Wylde', Phone__c='323562762', Email__c='jw@email.com', Valid_Until__c = (Date.today()+91), RecordTypeId=AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Trained_Staff'), Type_Of_Certificate__c = 'DGR');
        insert ac2;

        oscar2.STEP6__c = 'Passed';
        update oscar2;

        account1Br.CASS_Number__c = null;
        update account1Br;
        accreditationObj.CASS_Number__c = null;
        update accreditationObj;


        ANG_OscarProcessHelper.EntityUpdater resultUpdated = AmsIataCodeGenerator.generatedAgencyIATACode(account1Br.Id,oscar2.AMS_Online_Accreditation__c);
        ANG_OscarProcessHelper.updateUpdater(resultUpdated);

        accreditationObj = [SELECT ID , IATACode__c from AMS_Pax_Accreditation_Form__c where Id in (select AMS_Online_Accreditation__c from AMS_OSCAR__c where Id = :oscar3.Id)];
        accreditationObj.IATACode__c = '123456789';
        update accreditationObj;

        AMS_Accreditation_Contact__c ac3 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = accreditationObj.Id, First_name__c='Joan', Last_name__c='Wylde', Phone__c='323562762', Email__c='jw@email.com', Valid_Until__c = (Date.today()+91), RecordTypeId=AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Trained_Staff'), Type_Of_Certificate__c = 'DGR');
        insert ac3;

        oscar3.STEP6__c = 'Passed';
        update oscar3;

        ANG_OscarProcessHelper.EntityUpdater resultUpdated2 = AmsIataCodeGenerator.generatedAgencyIATACode(account2Br.Id,oscar3.AMS_Online_Accreditation__c);       
        ANG_OscarProcessHelper.updateUpdater(resultUpdated2);
      
        accreditationObj = [SELECT ID , IATACode__c, Location_Class__c from AMS_Pax_Accreditation_Form__c where Id in (select AMS_Online_Accreditation__c from AMS_OSCAR__c where Id = :oscar3.Id)];
        accreditationObj.Location_Class__c = 'Z';
        accreditationObj.IATACode__c = null;
        update accreditationObj;

        account2Br.IATACode__c = null;
        update account2Br;
        
        ANG_OscarProcessHelper.EntityUpdater resultUpdated3 = AmsIataCodeGenerator.generatedAgencyIATACode(account2Br.Id,oscar3.AMS_Online_Accreditation__c);       
        ANG_OscarProcessHelper.updateUpdater(resultUpdated3);

        //accreditationObj = [SELECT ID , IATACode__c from AMS_Pax_Accreditation_Form__c where Id in (select AMS_Online_Accreditation__c from AMS_OSCAR__c where Id = :oscar4.Id)];
        //accreditationObj.IATACode__c = '123456789';
        //update accreditationObj;
              


        System.assertEquals(resultUpdated.isFaulty,true);
        System.assertEquals(resultUpdated.errorMessage,'C, I, R, Q and G Location Types must have a CASS number defined before generating the IATA code.');

        System.assertEquals(resultUpdated2.isFaulty,true);
        System.assertEquals(resultUpdated2.errorMessage.contains('This account has already an existing IATA code.'),true);

        System.assertEquals(resultUpdated3.isFaulty,true);
        System.assertEquals(resultUpdated3.errorMessage, 'IATA Code Generation is only allowed for A, C, D, I, K, P, Q, R, T, M, G, X and P Location Classes.');


        /*String[] result5 = AmsIataCodeGenerator.generatedAgencyIATACode(account3Br.Id,oscar4.AMS_Online_Accreditation__c);       

        String[] result6 = AmsIataCodeGenerator.generatedAgencyIATACode(account4Br.Id,oscar5.AMS_Online_Accreditation__c);

        accreditationObj = [SELECT ID , IATACode__c, Location_Class__c, Branch_Office_Country__c from AMS_Pax_Accreditation_Form__c where Id in (select AMS_Online_Accreditation__c from AMS_OSCAR__c where Id = :oscar6.Id)];
        accreditationObj.Location_Class__c = 'G';
        accreditationObj.Branch_Office_Country__c = c2.id;
        update accreditationObj;

        String[] result7 = AmsIataCodeGenerator.generatedAgencyIATACode(account5Br.Id,oscar6.AMS_Online_Accreditation__c);*/

        Test.stopTest();

    }

    static testMethod void validateNonNumericIATACodeDigitCreation(){
        
        ID standardRT = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('Standard_Account') ;
        
        //HO
        Account account1 = new Account(RecordTypeId = standardRT, Name = 'My Travels HO',  IATA_ISO_Country__c = c2.Id, 
                         Sector__c = 'Cargo Agent', Category__c = 'Non-IATA Cargo Agent', 
                         Location_Class__c = 'C', Location_Type__c = 'HO', Status__c = 'New application pending',
                         Short_Name__c = 'Short name', BillingCity = 'Lisbon', Email__c = 'testeteste@fefe3.com',REASON_FOR_CREATION__C = 'Created by customer'
                         ,CASS_Number__c ='000', IATACode__c = '02310000000');
       
        
        insert account1;
        
        
        //BR
        Account account1Br = new Account(RecordTypeId = standardRT, Name = 'My Travels BR1',  IATA_ISO_Country__c = c2.Id,
                         Sector__c = 'Cargo Agent', Category__c = 'Non-IATA Cargo Agent', 
                         Location_Class__c = 'C', Location_Type__c = 'BR', Status__c = 'New application pending',
                         Short_Name__c = 'Short name', BillingCity = 'Lisbon', Email__c = 'testeteste@fefe3.com', ParentId=account1.Id,REASON_FOR_CREATION__C = 'Created by customer'
                         ,CASS_Number__c ='001', Top_Parent__c = account1.Id);
       
        
        
        List<Account> accounts = new List<Account>{account1Br};
        insert accounts;

        Contact contact1 = new Contact(FirstName = 'First', LastName = 'Contact',  AccountId = account1.Id, Email = 'thecontact1@gmail.com', Phone = '123123123');

        insert contact1;
        
    
        AMS_Agencies_Hierarchy__c hier = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c='Test Hierarchy');

        insert hier;

        List<AMS_Agencies_relationhip__c> rels = new List<AMS_Agencies_relationhip__c>();
        
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hier.Id, Parent_Account__c = account1.Id, Child_Account__c = account1Br.Id, HO_Flag__c = 'true'));

        insert rels;

        
        Test.startTest();

        AMS_OSCAR__c oscar2 = createCaseAndOSCARNoCass(account1Br,contact1,null);

        AMS_Pax_Accreditation_Form__c accreditationObj = [SELECT ID , A_code__c, N_code__c, C_code__c,IATACode__c,Location_Class__C,Chk_Dgt__c from AMS_Pax_Accreditation_Form__c where Id in (select AMS_Online_Accreditation__c from AMS_OSCAR__c where Id = :oscar2.Id)];
        accreditationObj.A_code__c = null;
        accreditationObj.N_code__c = null;
        accreditationObj.C_code__c = null;
        update accreditationObj;

        AmsIataCodeGenerator.checkDigitCreation(accreditationObj, account1Br, true);

       
        accreditationObj = [SELECT ID , A_code__c, N_code__c, C_code__c,IATACode__c,Location_Class__C,Chk_Dgt__c from AMS_Pax_Accreditation_Form__c where Id in (select AMS_Online_Accreditation__c from AMS_OSCAR__c where Id = :oscar2.Id)];
        accreditationObj.IATACode__c = 'BR400000042';
        accreditationObj.A_code__c = '4';
        accreditationObj.N_code__c = '0000';
        accreditationObj.C_code__c = 'BR';
        update accreditationObj;

        AmsIataCodeGenerator.checkDigitCreation(accreditationObj, account1Br, true);

        Test.stopTest();

    }

     static testMethod void generatedAgencyIATACodeWithNullAccreditation(){

        ID standardRT = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('Standard_Account') ;
        Account account1 = new Account(RecordTypeId = standardRT, Name = 'My Travels HO',  IATA_ISO_Country__c = c2.Id, 
                         Sector__c = 'Cargo Agent', Category__c = 'Non-IATA Cargo Agent', 
                         Location_Class__c = 'C', Location_Type__c = 'HO', Status__c = 'New application pending',
                         Short_Name__c = 'Short name', BillingCity = 'Lisbon', Email__c = 'testeteste@fefe3.com',REASON_FOR_CREATION__C = 'Created by customer'
                         ,CASS_Number__c ='000', IATACode__c = '02310000000');
       
        
        insert account1;
       

        ANG_OscarProcessHelper.EntityUpdater opEU=AmsIataCodeGenerator.generatedAgencyIATACode(account1, null,null);
     }

    static AMS_OSCAR__c createCaseAndOSCAR(Account theAccount, Contact theContact, String cassNumber){

        // Create the Staging area for the Account
        //ID rtCommCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();

        Case cse = new Case();
        cse.QuantityProduct__c = '1';
        insert cse;

        ID rtAgency = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();

        if(cassNumber == null)
            cassNumber = theAccount.Cass_Number__c;

        AMS_Pax_Accreditation_Form__c theStagingAcc = new  AMS_Pax_Accreditation_Form__c(Account_Name__c = theAccount.Name, IATAcode__c = theAccount.IATAcode__c, Branch_Office_Country__c = c2.Id, 
                                                            Location_Class__c = theAccount.Location_Class__c, Location_Type__c = theAccount.Location_Type__c,CASS_Number__c = cassNumber, SAAM_Case__c = cse.id);
        insert theStagingAcc;

        System.debug('Staging location class is ' + theStagingAcc.Location_Class__c);

        // Create OSCAR and Communication Case
        ID rtNew = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();
        
        AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = rtNew, Account__c = theAccount.Id, Process__c = 'NEW.HO.1.0', AMS_Online_Accreditation__c = theStagingAcc.Id );
        insert theOscar;

        cse.Oscar__c = theOscar.Id;

        update cse;

        return theOscar;

        
    }

    static AMS_OSCAR__c createCaseAndOSCARNoCass(Account theAccount, Contact theContact, String cassNumber){

        // Create the Staging area for the Account
        //ID rtCommCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();

        Case cse = new Case();
        cse.QuantityProduct__c = '1';
        insert cse;

        ID rtAgency = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();

        AMS_Pax_Accreditation_Form__c theStagingAcc = new  AMS_Pax_Accreditation_Form__c(Account_Name__c = theAccount.Name, IATAcode__c = theAccount.IATAcode__c, Branch_Office_Country__c = c2.Id, 
                                                            Location_Class__c = theAccount.Location_Class__c, Location_Type__c = theAccount.Location_Type__c, SAAM_Case__c = cse.id);
        insert theStagingAcc;

        System.debug('Staging location class is ' + theStagingAcc.Location_Class__c);

        // Create OSCAR and Communication Case
        ID rtNew = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();
        
        AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = rtNew, Account__c = theAccount.Id, Process__c = 'NEW.HO.1.0', AMS_Online_Accreditation__c = theStagingAcc.Id );
        insert theOscar;

        cse.Oscar__c = theOscar.Id;

        update cse;

        return theOscar;

        
    }
}
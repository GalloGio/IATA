public class AMS_AgencyHelper {
    //lsit of Operations per countries, per type
    private static Map<String, List<Ams_operation__c>> cassOperationsPerCountriesIds = new Map<String, List<Ams_operation__c>>();
    private static Map<String, List<Ams_operation__c>> bspOperationsPerCountriesIds = new Map<String, List<Ams_operation__c>>();

    public static String fillType(String locationClass){

        if(locationClass == null)
            return null;

        if(locationClass.equalsIgnoreCase('A'))
          return 'Airline Point of Sale';
        if(locationClass.equalsIgnoreCase('C'))
          return 'IATA Cargo Agent';
        if(locationClass.equalsIgnoreCase('D'))
          return 'Domestic Agent';
        if(locationClass.equalsIgnoreCase('G'))
          return 'GSA General Sales Agent';
        if(locationClass.equalsIgnoreCase('K'))
          return 'CATO';
        if(locationClass.equalsIgnoreCase('P'))
          return 'IATA Passenger Sales Agent';
        if(locationClass.equalsIgnoreCase('Q'))
          return 'Courier';
        if(locationClass.equalsIgnoreCase('R'))
          return 'CASS Associate';
        if(locationClass.equalsIgnoreCase('T'))
          return 'TIDS Agent';
        if(locationClass.equalsIgnoreCase('X'))
          return 'Handling Agent';
        if(locationClass.equalsIgnoreCase('M'))
          return 'MSO Member Sales Office';
        if(locationClass.equalsIgnoreCase('I'))
          return 'Import Agent';

          return null;

    }


    public static String fillIndustry(String type){

        if(type == null)
            return null;

        if( type.equalsIgnoreCase('IATA Cargo Agent') || 
            type.equalsIgnoreCase('Courier') ||
            type.equalsIgnoreCase('CASS Associate') ||
            type.equalsIgnoreCase('Import Agent')
          )
          return 'Cargo Agent';

          return 'Travel Agent';

    }

    /**
    Method to help the transformation between Company Type (Acccount) and Specify Legal Status (AMS Online Accreditation)
    */
    public static String transformCompanyType(String companyType){

        if(companyType == null)
            return null;

        if(companyType.equalsIgnoreCase('A'))
            return 'Association';
        if(companyType.equalsIgnoreCase('C'))
            return 'Corporation';
        if(companyType.equalsIgnoreCase('P'))
            return 'Partnership';
        if(companyType.equalsIgnoreCase('R'))
            return 'Limited Partnership';
        if(companyType.equalsIgnoreCase('S'))
            return 'Sole Proprietorship';
        if(companyType.equalsIgnoreCase('T'))
            return 'Trust Company';
        if(companyType.equalsIgnoreCase('V'))
            return 'Co-operative';
        if(companyType.equalsIgnoreCase('J'))
            return 'Joint Venture';
        if(companyType.equalsIgnoreCase('L'))
            return 'Limited Company';
        if(companyType.equalsIgnoreCase('E'))
            return 'State Owned Enterprise';
        if(companyType.equalsIgnoreCase('O'))
            return 'Other';
        return null;

    }

        /**
    Method to help the transformation between GDS (Acccount) and Specify GDS with signed contract (AMS Online Accreditation)
    */
    public static String transformGDS(String gds){

        if(gds == null)
            return null;

        if(gds.equalsIgnoreCase('ABAC'))
            return 'Abacus';
        if(gds.equalsIgnoreCase('AGTD'))
            return 'Amadeus';
        if(gds.equalsIgnoreCase('AXSS'))
            return 'Axess';
        if(gds.equalsIgnoreCase('CMAS'))
            return 'Kiu System';
        if(gds.equalsIgnoreCase('DERD'))
            return 'Deutsche Reiseburo';
        if(gds.equalsIgnoreCase('FLGX'))
            return 'Farelogix';
        if(gds.equalsIgnoreCase('GDSL'))
            return 'Travelport (Galileo)';
        if(gds.equalsIgnoreCase('INFI'))
            return 'Infini';
        if(gds.equalsIgnoreCase('KOTI'))
            return 'Kotis Travel Info SE';
        if(gds.equalsIgnoreCase('MINS'))
            return 'Travelsky';
        if(gds.equalsIgnoreCase('RESI'))
            return 'Resiber';
        if(gds.equalsIgnoreCase('SABR'))
            return 'Sabre';
        if(gds.equalsIgnoreCase('SITA'))
            return 'SITA';
        if(gds.equalsIgnoreCase('STRA'))
            return 'Sirena';           
        if(gds.equalsIgnoreCase('TOPAS'))
            return 'Topas';
        if(gds.equalsIgnoreCase('UALA'))
            return 'Travelport (Apollo)';
        if(gds.equalsIgnoreCase('WSPN'))
            return 'Travelport (Worldspan)';
  
        return null;

    }

        
    /*
    jfo
    11/08//2015
    helper method call by trigger to force Agency Operation assignment
    
    */
    public static void updateAgenciesOperations(List<Account> operationHelpercandidate){
        Savepoint sp = Database.setSavepoint();
        
        if( cassOperationsPerCountriesIds.size()==0 || bspOperationsPerCountriesIds.size()==0 ){
            List<Ams_operation__c> allOperations = [select Id,Country__c,CASS_Operations__c, Settlement__r.recordtype.name from Ams_operation__c];
            for(Ams_operation__c op:allOperations ){
                if(op.CASS_Operations__c !=null){
                    if(cassOperationsPerCountriesIds.get(op.Country__c) ==null)
                        cassOperationsPerCountriesIds.put(op.Country__c, new List<Ams_operation__c>());
                    cassOperationsPerCountriesIds.get(op.Country__c).add(op);
                }else{
                    if(bspOperationsPerCountriesIds .get(op.Country__c) ==null)
                        bspOperationsPerCountriesIds.put(op.Country__c, new List<Ams_operation__c>());
                    bspOperationsPerCountriesIds.get(op.Country__c).add(op);
                }
            }
        }
        
         //new operations to create
        List<AMS_Agency_Operations__c> newAgencyOperations = new List<AMS_Agency_Operations__c>();

        Map<Id, Account> oldMap;
        if(Trigger.isUpdate)
            oldMap = (Map<Id,Account>) Trigger.oldMap;

        for(Account acc:operationHelpercandidate ){
           if(acc.Sector__c == 'Cargo Agent'){
               system.debug('[OPERATION]CARGO AGT look for OP. CTRY = '+acc.IATA_ISO_Country__c);
               if(cassOperationsPerCountriesIds.get(acc.IATA_ISO_Country__c)!=null)
                    for(Ams_operation__c op:cassOperationsPerCountriesIds.get(acc.IATA_ISO_Country__c)){
                        AMS_Agency_Operations__c aao = new AMS_Agency_Operations__c (Account__c =acc.Id, Operation__c=op.Id);
                        newAgencyOperations.add(aao);
                    }
            }
            else if(acc.Sector__c == 'Travel Agent') {
                 //CASE for PASSENGER
                system.debug('[OPERATION]PAXAGT look for OP. CTRY = '+acc.IATA_ISO_Country__c);
                if(bspOperationsPerCountriesIds.get(acc.IATA_ISO_Country__c)!=null)
                    for(Ams_operation__c op:bspOperationsPerCountriesIds.get(acc.IATA_ISO_Country__c)){
                        // Only allow operation codes with BSP settlements if agency is NEWGEN
                        if(Trigger.isUpdate && acc.ANG_IsNewGenAgency__c && acc.IATACode__c != null && oldMap.get(acc.id).IATACode__c == null && acc.RecordTypeId == ANG_ConversionHelper.ACCOUNT_AGENCY_RT && oldMap.get(acc.id).RecordTypeId == ANG_ConversionHelper.ACCOUNT_STANDARD_RT){
                            if(op.Settlement__r.recordtype.name == 'BSP'){
                                AMS_Agency_Operations__c aao = new AMS_Agency_Operations__c (Account__c = acc.Id, Operation__c=op.Id);
                                newAgencyOperations.add(aao);
                            }
                            //prevent NG agencies from passing here
                        }else if (!acc.ANG_IsNewGenAgency__c){
                            AMS_Agency_Operations__c aao = new AMS_Agency_Operations__c (Account__c = acc.Id, Operation__c=op.Id);
                            newAgencyOperations.add(aao);
                        }
                    }
                 else{
                     //create event?
                 
                 }
            }
        }
       
       
        try{
            insert  newAgencyOperations;
            system.debug('[OPERATIONS][SUCCESS] Update Agencies operation for '+newAgencyOperations.size()+ 'From request '+operationHelpercandidate.size());
            //DevsTools.sendSFDevsAlertMessage('[SUCCESS] Update Agencies operation for '+newAgencyOperations.size(), 'From request '+operationHelpercandidate.size());
        }catch(Exception e){
            System.debug('[OPERATIONS][failure] Update Agencies operation for '+newAgencyOperations.size()+' '+ e.getMessage());
            //DevsTools.sendSFDevsAlertMessage('[failure] Update Agencies operation for '+newAgencyOperations.size(), e.getMessage());        
            Database.rollback(sp);
        }
    }
    
   
    public static String  resizeNumericString(String aString, integer expectedSize){
        String s = aString;
        
        while(s.length()<expectedSize){
                s = '0'+s;
        }
        system.debug('[IATA CODE Generator] update String from '+aString+' to '+s);
        return s;
    }
    

 }
public class AMS_AgencyHelper {
    //lsit of Operations per countries, per type
    private static Map<String, List<Ams_operation__c>> cassOperationsPerCountriesIds = new Map<String, List<Ams_operation__c>>();
    private static Map<String, List<Ams_operation__c>> bspOperationsPerCountriesIds = new Map<String, List<Ams_operation__c>>();

    /*#AMSFTS
    public static boolean isAgencyAccredited(String anAgencyId){
        try{
            Account anAgency = [Select Id, Original_Approval_DAte__c from Account];
            return isAgencyAccredited(anAgency);
        }catch(Exception e){
            return false;
        }
    }


    public static boolean isAgencyAccredited(Account anAgency){
        return anAgency.Original_Approval_DAte__c !=null;
    }*/

    /*#AMSFTS
    public static void assignRT(List<AMS_Agency__c> agencies){
        Id rtcargo = Schema.SObjectType.AMS_Agency__c.getRecordTypeInfosByName().get('CARGO').getRecordTypeId();
        Id rtpassenger = Schema.SObjectType.AMS_Agency__c.getRecordTypeInfosByName().get('PASSENGER').getRecordTypeId();

        for(AMS_Agency__c a:agencies){
            if(a.CASS_Number__c == null || a.CASS_Number__c == '')
                a.RecordTypeId = rtpassenger;
            else
                a.RecordTypeId = rtcargo;
        }
    }

    public static void addAccountIfEmpty (list<AMS_Agency__c> agencies){
        Id rtagency = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        Id rtcargo = Schema.SObjectType.AMS_Agency__c.getRecordTypeInfosByName().get('CARGO').getRecordTypeId();

        Set<String> IATACodes = new Set<String>();
        Set<String> AIMSIDS= new Set<String>();
        Set<String> WEBSTARIDS= new Set<String>();
        
        
        Map<String,Account> IATAcodesToAccount = new Map<String,Account>();
        Map<String,Account> AIMSRecordIDToAccount = new Map<String,Account>();
        Map<String,Account> WSIDToAccount = new Map<String,Account>();
        
        for(AMS_Agency__c ag : agencies){
            if(ag.IATACode__c != null ){
                
                // jfo 24/09/15 [EDIT] maybe we should consider 7 digit agency
                // I need to look for iatacode 8 digits (existing before ams) and iatacode 7 digits + 1 checkdigit (ams accounts)
                // 7 digits
                //IATACodes.add(ag.IATACode__c);
                
                
                if(ag.recordTypeId == rtcargo ){
                    //11 digits for cargo
                    String cassN  = getFormattedCassNumber(ag);
                    String chkDgt = ag.Chk_Dgt__c;//getFormattedCheckDigit(ag);     
              
                    String cargoIataCode  =  ag.iatacode__c + (cassN !=null?''+cassN:'') + (chkDgt==null?'':''+chkDgt) ;
                    cargoIataCode = cargoIataCode.replace('.', '');
                    IATACodes.add(cargoIataCode);                          
                    //lets consider 8 digits also 
                    // 8 digits
                    //IATACodes.add(ag.IATACode__c + (ag.Chk_Dgt__c==null?'':''+ag.Chk_Dgt__c));
                }else {
                    // 8 digits
                    String chkDgt = ag.Chk_Dgt__c;//getFormattedCheckDigit(ag);     
              
                    String passengerIataCode =  ag.iatacode__c + (chkDgt==null?'':''+chkDgt) ;
                    passengerIataCode = passengerIataCode.replace('.', '');
                    IATACodes.add(passengerIataCode);
                }
                if(ag.Legacy_System__c!=null && ag.Legacy_System__c.contains('AIMS'))
                    AIMSIDS.add(ag.Legacy_External_ID__c);
                if(ag.Legacy_System__c!=null && ag.Legacy_System__c.contains('WEBSTAR'))
                    WEBSTARIDS.add(ag.Legacy_External_ID__c);
            }
        }

        // Look for existing Accounts (based on IATA Code)
        for(Account a : [SELECT Id, RecordTypeId, IATACode__c,WebStar_ID__c ,   AIMS_ID__c, BSP_CASS_Code__c, CASS_Number__c, (SELECT Id FROM Account.Agencies__r)  
                            FROM Account WHERE IATACode__c IN : IATACodes or AIMS_ID__c IN :AIMSIDS or WebStar_ID__c in :WEBSTARIDS]){
            //if(a.BSP_CASS_Code__c!=null)
                //IATAcodesToAccount.put(a.IATACode__c+''+a.BSP_CASS_Code__c, a);
            //else
            if(a.IATACode__c != null)
                IATAcodesToAccount.put(a.IATACode__c.left(7), a);   
            if(a.AIMS_ID__c !=null)
                AIMSRecordIDToAccount.put (a.AIMS_ID__c , a);
            if(a.WebStar_ID__c !=null)
                WSIDToAccount.put(a.WebStar_ID__c ,a);
        }
        
               
        // Try to match agents with existing accounts using legacy external id
        Map<String,Account> newAccounts = new Map<String,Account>();
        List<Account> updateAccounts = new List<Account>(); //FM 12-08-2015 - new field for update accounts
        List<GDP_Reference_Table__c> gdpReferencesList = [select Id, System_ID__c, Definition__c, System__c, Table__c, Code__c from GDP_Reference_Table__c];

        //LM:08/12/2015
        /*Set<Id> agencyIDS = new Set<Id>();
        Map<Id,List<AMS_Employee__c>> agEmployees = new Map<Id,List<AMS_Employee__c>>();

        for(AMS_Agency__c ag : agencies){
                agencyIDS.add(ag.ID);
        }

        Map<Id,AMS_Employee__c> employees = new Map<Id,AMS_Employee__c>([SELECT Agency__c,DUTY__c,Earning__c,Employee_type__c,Hours__c,Id,isManager__c,
                                                        isTicketingAgent__c,Name,Person__c,Position__c,Registration_Date__c,Stage__c,
                                                        Start_date__c,Termination_Date__c,Title__c,Valid__c,
                                                        Person__r.First_Name__c,Person__r.Lastname__c,Person__r.Language_of_correspondence__c 
                                                        FROM AMS_Employee__c
                                                        WHERE Agency__c IN : agencyIDS]);

        for(AMS_Employee__c emp: employees.values()){
            //if(emp.Agency__c != null)
                if(agEmployees.get(emp.Agency__c)==null)
                    agEmployees.put(emp.Agency__c, new List<AMS_Employee__c>{emp});
                else
                    agEmployees.get(emp.Agency__c).add(emp);
        }

        System.debug('MAC: Agency IDS-> ' + agencies);
        System.debug('MAC: Employees-> ' + employees);
        System.debug('MAC: AgEmployees-> ' + agEmployees);

        //LM:08/12/2015*/                                          

        /*for(AMS_Agency__c ag : agencies){
            Account theAccount = null;
            //if(ag.CASS_Number__c!=null)
            //    theAccount= IATAcodesToAccount.get(agencyiatacode+''+ag.CASS_Number__c);
            //else
                           
                           
            theAccount = null;
           
            if(ag.Legacy_System__c!=null && ag.Legacy_System__c.contains('AIMS'))
                theAccount = AIMSRecordIDToAccount.get(ag.Legacy_External_ID__c );
            if( ag.Legacy_System__c!=null && ag.Legacy_System__c.contains('WEBSTAR'))
                theAccount = WSIDToAccount.get(ag.Legacy_External_ID__c );
             if(theAccount==null)
                theAccount = IATAcodesToAccount.get(ag.IATACode__c);
                 
            ag.Account__c = theAccount==null ? null : theAccount.ID;
            
            if(theAccount!=null && theAccount.Agencies__r.size()>0){
                ag.addError(' Cannot bind this agency to the account '+ag.Name+' because the account is related to a different agency.');
                continue;
            }
            if(ag.Account__c == null){
                ///// this block of code its because the stub from dst transforms the cass number in to a double and the cass number is a int
                String cassN  = getFormattedCassNumber(ag);
                String chkDgt = ag.Chk_Dgt__c;//getFormattedCheckDigit(ag);     
              
                // !! removed  
                //String acctype = ag.RecordTypeId==rtcargo ? 'IATA Cargo Agent' : 'IATA Passenger Sales Agent';

                String acctype = fillType(ag.Location_Class__c);
                String acctcategory = acctype;
                String acctIndustry = fillIndustry(acctype);
                String acctSector = acctIndustry;




                //Get Employee field info
                //List<AMS_Employee__c> lAMS_Employee = AMS_EmployeeHelper.getAgencyEmployees(ag.Id);
                //List<AMS_Employee__c> lAMS_Employee = agEmployees.get(ag.Id);

                String sPreferred_Language = '';
                String sTicketing_Agent_First_Name = '';
                String sTicketing_Agent_Last_Name = '';
                String sManager_First_Name = '';
                String sManager_Last_Name = '';

                /**TO REVIEW
                for(AMS_Employee__c emp : lAMS_Employee){ 
                    //Assuming that the Preferred Language is equal to all employees
                    if(sPreferred_Language == ''){
                        sPreferred_Language = emp.Person__r.Language_of_correspondence__c;
                    }

                    //check if it's Manager
                    if(emp.isManager__c){
                        sManager_First_Name = emp.Person__r.First_Name__c;
                        sManager_Last_Name = emp.Person__r.Lastname__c;
                    }

                    //check if it's Manager
                    if(emp.isTicketingAgent__c){
                        sTicketing_Agent_First_Name = emp.Person__r.First_Name__c;
                        sTicketing_Agent_Last_Name = emp.Person__r.Lastname__c;
                    }

                }*/

                
                /*String keyAccount =  ag.iatacode__c + (cassN !=null?''+cassN:'') + (chkDgt==null?'':''+chkDgt) ;
                keyAccount = keyAccount.replace('.', '');
                String aName = ag.Legal_Name_1__c;
                if(ag.Legal_Name_2__c!= null && !ag.Legal_Name_2__c.equals(ag.Legal_Name_1__c))
                    aName += ' '+ag.Legal_Name_2__c;
                if(ag.Legal_Name_3__c!= null && !ag.Legal_Name_3__c.equals(ag.Legal_Name_1__c)   && !ag.Legal_Name_3__c.equals(ag.Legal_Name_2__c))
                    aName += ' '+ag.Legal_Name_3__c;
                if(aName ==null)
                    aName = ag.Name;
                
                Map<String,GDP_Reference_Table__c> gdpReferencesTable = new Map<String,GDP_Reference_Table__c>();
                for(GDP_Reference_Table__c ref:gdpReferencesList)
                    gdpReferencesTable.put(ref.System_ID__c,ref);
                    
                String tName = ag.Trading_Name_1__c;
                if(ag.Trading_Name_2__c!= null && !ag.Trading_Name_2__c.equals(ag.Trading_Name_1__c))
                    tName += ' '+ag.Trading_Name_2__c;
                
                //jfo 2016-02-01: we won't set IATA code on account if not needed
                String keyAccountIATACOde  =null;
                if(ag.RecordTypeId==rtcargo && keyAccount.length()>=10 )
                    keyAccountIATACOde =keyAccount ;
                else if(keyAccount .length()>=7)
                     keyAccountIATACOde =keyAccount ;
                
                Account newAccount = new Account(Name=aName ,
                                Short_Name__c = ag.Legal_Name_1__c,
                                RecordTypeId = rtagency,
                                Site =ag.iatacode__c,
                                IATACode__c =keyAccountIATACOde ,
                                TradeName__c = tName, 
                                Phone = (ag.Phone_Number_Int__c==null?'':ag.Phone_Number_Int__c + ' ') + (ag.Phone_Number_STD__c==null?'':ag.Phone_Number_STD__c) + (ag.Phone_Number__c==null?'':ag.Phone_Number__c),
                                Ownerid = ag.OwnerId, 
                                Sector__c = acctSector ,
                                Expiry_Date__c = ag.Recert_Expiry_Date__c,
                                Accreditation_date__c = ag.Original_Approval_DAte__c,
                                Source_System__c = ag.Legacy_System__c,
                                Location_Type__c = ag.Site_Type__c,//ag.Location_Class__c, 
                                VAT_Number__c = ag.Tax_Reference_Number__c,
                                VAT_Number_2__c = ag.Other_Tax_Reference_Number__c,
                                Is_AIMS_Account__c = ag.Legacy_System__c!=null ? ag.Legacy_System__c.startsWith('AIMS') : false,
                                CASS_Number__c = cassN,
                                AIMS_ID__c = (ag.Legacy_System__c!=null && ag.Legacy_System__c.startsWith('AIMS') ? ag.Legacy_External_ID__c : null),
                                Webstar_ID__c = (ag.Legacy_System__c=='Webstar' ? ag.Legacy_External_ID__c : null),
                                IATA_ISO_Country__c = ag.Country__c,

                                Status__c = mapAccountStatusFromAgency(ag.Agency_Status__c), 
                                //Financial_Year_End__c = ag.Financial_Year_End__c,
                                Accumulated_Irregularities__c = ag.Accumulated_Irregularities__c,
                                Type = acctype,
                                //FM 10-08-2015 - new entries for the eCom values
                                BSP_CASS_Code__c =ag.BSP_Code__c!=null? ag.BSP_Code__c.left(4) : null  ,
                                License_Number__c = ag.License_Number__c,
                                Tax_ID_1__c = ag.Tax_Reference_Number__c!=null? ag.Tax_Reference_Number__c.left( 20) : null ,
                                Tax_ID_2__c = ag.Other_Tax_Reference_Number__c!=null? ag.Other_Tax_Reference_Number__c.left( 20) : null ,
                                Preferred_Language__c = sPreferred_Language,
                                Ticketing_Agent_First_Name__c = sTicketing_Agent_First_Name,
                                Ticketing_Agent_Last_Name__c = sTicketing_Agent_Last_Name,
                                Manager_First_Name__c = sManager_First_Name,
                                Manager_Last_Name__c = sManager_Last_Name,
                                Category__c = acctcategory,
                                Industry = acctIndustry
                                );
                
                 if(gdpReferencesTable.get('LGLTYP'+    ag.Company_Type__c)!=null)                  
                     newAccount.Incorporation_Type__c = gdpReferencesTable.get('LGLTYP'+    ag.Company_Type__c).Id; 
                
                 IATAcodesToAccount.put( keyAccount ,newAccount);
                 newAccounts.put( keyAccount ,newAccount);
            }else{
                //FM 12-08-2015 - Change account recordtype to "agency", since its related now to an Agency
                if(theAccount != Null){
                    if(theAccount.RecordTypeId != rtagency){
                        theAccount.RecordTypeId = rtagency;
                        updateAccounts.add(theAccount);
                    }
                }
            }
        }
        
        // If I needed to create new Contacts I'll insert them in DB and I'll reference them from the agents
        if(newAccounts.size()>0){
            insert newAccounts.values();
            for(AMS_Agency__c ag : agencies){
                if(ag.Account__c == null){
                    //JFO 24/09 update the way we are getting account using IATACOde
                    //introducing the 3Dugit cass number
                    
                    
                    //11 digits for cargo
                    String cassN  = getFormattedCassNumber(ag);
                    String chkDgt = ag.Chk_Dgt__c;//getFormattedCheckDigit(ag);     
                    String agtIataCode ='';
                    if(ag.recordTypeId == rtcargo )
                        agtIataCode = ag.iatacode__c + (cassN !=null?''+cassN:'') + (chkDgt==null?'':''+chkDgt) ;
                    else 
                        agtIataCode =ag.iatacode__c + (chkDgt==null?'':''+chkDgt) ;
                    
                    if(newAccounts.get(agtIataCode)!=null)
                        ag.Account__c = newAccounts.get(agtIataCode).ID;
                    else
                        ag.addError('Failed to retreive account for Agency '+ag.Name+' with IATA CODE ='+agtIataCode);
                }
            }
        }
        
        //FM 12-08-2015 - update accounts to the right recordtype
        if(updateAccounts.size()>0){
            update updateAccounts;
        }
        return;
    }*/

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

    /*AMSFTS
    public static void Ensure0to1AccountLookup(list<AMS_Agency__c> agents){
        Map<Id,AMS_Agency__c> accountIdToAgency = new Map<Id,AMS_Agency__c>();
        
        for(AMS_Agency__c ag : agents){
            if(ag.Account__c!=null){
                if(accountIdToAgency.get(ag.Account__c)!=null){
                    ag.addError('There is already an Agency related to this Account');
                    continue;
                }
                accountIdToAgency.put(ag.Account__c,ag);   
            }
        }
        
        List<AMS_Agency__c> alreadyRelated = [SELECT Id, Account__c FROM AMS_Agency__c WHERE Account__c IN :accountIdToAgency.keySet()];
        for(AMS_Agency__c ag : alreadyRelated){
            AMS_Agency__c newAg = accountIdToAgency.get(ag.Account__c);
            newAg.addError('There is already an Agency related to this Account');
        }
        
        return;
    }*/

    /*
    RP
    31/08/2015
    helper method to update account when agency fields are updated
    */

    /*#AMSFTS 12/02/2016
    public static void updateAccounts(Map<Id, AMS_Agency__c> oldAgencies, Map<Id, AMS_Agency__c> newAgencies, Set<String> accounts){
        Map<Id, Account> theAccounts = new Map<Id, Account>([select id, Name, Short_Name__c, IATACode__c, TradeName__c, Phone, Ownerid, Sector__c,
                                                                Type, Passenger_And_Cargo__c, Expiry_Date__c, Accreditation_date__c, Source_System__c,
                                                                Is_AIMS_Account__c, AIMS_ID__c, Webstar_ID__c, Location_Type__c, VAT_Number__c, Tax_ID_1__c,
                                                                Tax_ID_2__c, VAT_Number_2__c, CASS_Number__c, Site, Status__c, Financial_Year_End__c, 
                                                                Accumulated_Irregularities__c, BSP_CASS_Code__c, License_Number__c from Account where id IN :accounts]);
        List<Account> updateAccounts = new List<Account>();
        Set<Id> accountIdToUpdate = new Set<Id>();
        List<GDP_Reference_Table__c> gdpReferencesList = [select Id, System_ID__c, Definition__c, System__c, Table__c, Code__c from GDP_Reference_Table__c];
        Map<String,GDP_Reference_Table__c> gdpReferencesTable = new Map<String,GDP_Reference_Table__c>();
        for(GDP_Reference_Table__c ref:gdpReferencesList)
            gdpReferencesTable.put(ref.System_ID__c,ref);
        
        AMS_Agency__c oldRecord = null;
        AMS_Agency__c newRecord = null;
        
        Id rtcargo = Schema.SObjectType.AMS_Agency__c.getRecordTypeInfosByName().get('CARGO').getRecordTypeId();

        for(String id: newAgencies.keySet()){
            oldRecord = oldAgencies.get(id);
            newRecord = newAgencies.get(id);
            String aName = newRecord.Legal_Name_1__c;
            if(newRecord.Legal_Name_2__c!= null && !newRecord.Legal_Name_2__c.equals(newRecord.Legal_Name_1__c))
                aName += ' '+newRecord.Legal_Name_2__c;
            if(newRecord.Legal_Name_3__c!= null && !newRecord.Legal_Name_3__c.equals(newRecord.Legal_Name_1__c)   && !newRecord.Legal_Name_3__c.equals(newRecord.Legal_Name_2__c))
                aName += ' '+newRecord.Legal_Name_3__c;
            if(aName ==null)
                aName = newRecord.Name;
                
            String tName = newRecord.Trading_Name_1__c;
             if(newRecord.Trading_Name_2__c!= null && !newRecord.Trading_Name_2__c.equals(newRecord.Trading_Name_1__c))
                    tName += ' '+newRecord.Trading_Name_2__c;
        
            String cassN  = getFormattedCassNumber(newRecord);

            String chkDgt = newRecord.Chk_Dgt__c;

            String iataCode = (newRecord.iatacode__c != null ?  newRecord.iatacode__c : '') + (cassN !=null?''+cassN:'') + (chkDgt==null?'':''+chkDgt) ;
            
            theAccounts.get(newRecord.Account__c).Name =aName ;
 
            theAccounts.get(newRecord.Account__c).Short_Name__c = newRecord.Legal_Name_1__c;
            theAccounts.get(newRecord.Account__c).TradeName__c =tName;
            //theAccounts.get(newRecord.Account__c).Expiry_Date__c = newRecord.Recert_Expiry_Date__c;
            theAccounts.get(newRecord.Account__c).Accreditation_date__c = newRecord.Original_Approval_DAte__c;
            theAccounts.get(newRecord.Account__c).Location_Type__c = newRecord.Site_Type__c;
            theAccounts.get(newRecord.Account__c).VAT_Number__c = newRecord.Tax_Reference_Number__c;
            theAccounts.get(newRecord.Account__c).Tax_ID_1__c = newRecord.Tax_Reference_Number__c!=null? newRecord.Tax_Reference_Number__c.left( 20) : null;
            theAccounts.get(newRecord.Account__c).VAT_Number_2__c = newRecord.Other_Tax_Reference_Number__c;
            theAccounts.get(newRecord.Account__c).CASS_Number__c = newRecord.CASS_Number__c;//cassN  ;//String.valueOf(newRecord.CASS_Number__c);
            
            if(newRecord.RecordTypeId==rtcargo && iataCode.length()>=10 )
                theAccounts.get(newRecord.Account__c).IATACode__c = iataCode;
            else if(iataCode.length()>=7)
               theAccounts.get(newRecord.Account__c).IATACode__c = iataCode;
               
               
            theAccounts.get(newRecord.Account__c).Site = iataCode;
            theAccounts.get(newRecord.Account__c).Status__c = mapAccountStatusFromAgency(newRecord.Agency_Status__c);
            //theAccounts.get(newRecord.Account__c).Financial_Year_End__c = newRecord.Financial_Year_End__c;
            theAccounts.get(newRecord.Account__c).Accumulated_Irregularities__c = newRecord.Accumulated_Irregularities__c;
            theAccounts.get(newRecord.Account__c).BSP_CASS_Code__c = newRecord.BSP_Code__c!=null? newRecord.BSP_Code__c.left(4) : null;
            theAccounts.get(newRecord.Account__c).License_Number__c = newRecord.License_Number__c;
            
            //jfo 6/10
            //adding Incorporation GDP field to item
 
            if(gdpReferencesTable.get('LGLTYP'+ newRecord.Company_Type__c)!=null){                 
                theAccounts.get(newRecord.Account__c).Incorporation_Type__c = gdpReferencesTable.get('LGLTYP'+ newRecord.Company_Type__c).Id;
                
            }
            if(oldRecord.Recert_Expiry_Date__c != newRecord.Recert_Expiry_Date__c){
                theAccounts.get(newRecord.Account__c).Expiry_Date__c = newRecord.Recert_Expiry_Date__c;
            }
            if(oldRecord.Phone_Number__c != newRecord.Phone_Number__c){
                theAccounts.get(newRecord.Account__c).Phone = (newRecord.Phone_Number_Int__c==null?'':newRecord.Phone_Number_Int__c + ' ') + (newRecord.Phone_Number_STD__c==null?'':newRecord.Phone_Number_STD__c) + (newRecord.Phone_Number__c==null?'':newRecord.Phone_Number__c);
            }
            

            /*
            if(oldRecord.RecordTypeId != newRecord.RecordTypeId){
                String type = newRecord.RecordTypeId==rtcargo ? 'IATA Cargo Agent' : 'IATA Passenger Sales Agent';

                theAccounts.get(newRecord.Account__c).Sector__c = type;
                theAccounts.get(newRecord.Account__c).Type = type;
            }*/

            /*if(newRecord.Location_Class__c != null){

                String acctype = fillType(newRecord.Location_Class__c);
                String acctcategory = acctype;
                String acctIndustry = fillIndustry(acctype);
                String acctSector = acctIndustry;

                theAccounts.get(newRecord.Account__c).Type = acctype;
                theAccounts.get(newRecord.Account__c).Category__c = acctcategory;
                theAccounts.get(newRecord.Account__c).Industry = acctIndustry;
                theAccounts.get(newRecord.Account__c).Sector__c = acctSector;
            }

            //jfo 2015-11-17
            //force to set the legacy data on account if needed for GDP
            //theAccounts.get(newRecord.Account__c).AIMS_ID__c  ==null && theAccounts.get(newRecord.Account__c).Webstar_ID__c ==null && (   
            if(newRecord.Legacy_System__c!=null){
                theAccounts.get(newRecord.Account__c).Source_System__c = newRecord.Legacy_System__c;
                theAccounts.get(newRecord.Account__c).Is_AIMS_Account__c = newRecord.Legacy_System__c!=null ? newRecord.Legacy_System__c.startsWith('AIMS') : false;
                theAccounts.get(newRecord.Account__c).AIMS_ID__c = (newRecord.Legacy_System__c!=null && newRecord.Legacy_System__c.startsWith('AIMS') ? newRecord.Legacy_External_ID__c : null);
                theAccounts.get(newRecord.Account__c).Webstar_ID__c = (newRecord.Legacy_System__c=='Webstar' ? newRecord.Legacy_External_ID__c : null);
            }
            accountIdToUpdate.add(newRecord.Account__c);     
        }

        if(accountIdToUpdate.size() > 0){
            for(Id theId: accountIdToUpdate){
                updateAccounts.add(theAccounts.get(theId));
            }

            update updateAccounts;
        }
    }
    #AMSFTS END*/
        
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
    
    //private static String getFormattedCheckDigit(Ams_agency__c ag){
    //    String chkDgt=null;
    //    if(ag.Chk_Dgt__c!= null){
    //        chkDgt = String.valueOf(ag.Chk_Dgt__c);
    //        if(chkDgt!=null)
    //            chkDgt=  chkDgt.replace('.0', '');
    //    }
    //    return chkDgt;
    //}
    
    /*AMSFTS
    public static String getFormattedCassNumber(Account ag){
        String cassN =null;
        if(ag.CASS_Number__c!= null){
            cassN =  ag.CASS_Number__c;
            if(cassN!=null){
                cassN  = resizeNumericString(cassN ,3) ;
            }
        }
        return cassN;
    }*/
   
    //LM: 01/10/2015
    /*AMSFTS TO BE DONE IN ONLINE ACCREDITATION
    public static void fillAgencyCodes(Account ag){
    
        ag.A_Code__c = ag.IATACode__c.substring(2,3);
        ag.C_Code__c = ag.IATACode__c.substring(0,2);
        ag.N_Code__c = ag.IATACode__c.substring(3,7);
                
        system.debug('A Code: '+ ag.A_Code__c + ' C Code ' + ag.C_Code__c + ' N Code ' + ag.N_Code__c);
       
    }
    /**
    jfo 2015-11-05 agency is accreditated and account is approved. Other values are fine.
    
    */
    /*AMSFTS
    public static String mapAccountStatusFromAgency(String agStatus){
        if(agStatus!=null && agStatus.equals('Accredited'))
            return 'Approved';
         return agStatus;
    }*/
   
    public static String  resizeNumericString(String aString, integer expectedSize){
        String s = aString;
        
        while(s.length()<expectedSize){
                s = '0'+s;
        }
        system.debug('[IATA CODE Generator] update String from '+aString+' to '+s);
        return s;
    }
    
    /*AMSFTS TO BE DONE IN ONLINE ACCREDITATION
    public static boolean isMissingCodes(Account ag){
        if(ag.IATACode__c != null && (ag.C_Code__c== null || ag.C_Code__c=='' ||
            ag.A_Code__c== null || ag.A_Code__c=='' || ag.N_Code__c == null || ag.N_Code__c== ''))
            return true;
        
        return false;
    }
    
    public static String genIATACodeFromCodes(Account ag){
        //String cassN  = getFormattedCassNumber(ag);
        return (ag.C_Code__c!=null?''+ag.C_Code__c:'') + (ag.A_Code__c!=null?''+ag.A_Code__c:'') + '' + (ag.N_Code__c!=null?''+ag.N_Code__c:'');
    }*/

 }
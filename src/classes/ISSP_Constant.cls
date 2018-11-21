public class ISSP_Constant {
    /*
Constant Class
*/
    
    //New Self Register Contact Status
    public final static string NEW_CONTACT_STATUS = 'Pending Approval';
    
    //Approved User Contact Status
    public final static string APPROVED_CONTACT_STATUS = 'Approved User';
    
    //Allow recursive account update for the batch (top parent account field)
    public static boolean fiilTopBatch = false;
    //Avoid ReExecute of trigger if Account updated by User trigger (avoid loop)
    public static boolean UserAccountChangeParent = false;
    
    //Create static Map from ISS custom Setting
    public static Map<String,String> customSetingMap;
    static{
        customSetingMap = new Map<String,String>();
        for(ISSP_CS__c cs : [select Name,value__c from ISSP_CS__c]){
            customSetingMap.put(cs.Name.trim(),cs.Value__c);
        }
        
    }
    
    //Static Map Profile name,ID
    public static Map<String,Id> profileIdByProfileNameMap = 
        new Map<String,Id>{ 
            'ISS Portal Agency User' => customSetingMap.get('ISS_Portal_Agency_User'),
                'ISS Portal Airline User' => customSetingMap.get('ISS_Portal_Airline_User'),
                'ISS Portal GSA User' => customSetingMap.get('ISS_Portal_GSA_User'),
                'ISS Portal' => customSetingMap.get('ISS_Portal'),
                
                'ISS Portal Agency Delegated Admin User' => customSetingMap.get('ISS_Portal_Agency_Delegated_Admin'),
                'ISS Portal Airline Delegated Admin User' => customSetingMap.get('ISS_Portal_Airline_Delegated_Admin'),
                'ISS Portal GSA Delegated Admin User' => customSetingMap.get('ISS_Portal_GSA_Delegated_Admin'),
                'ISS Portal Delegated Admin User' => customSetingMap.get('ISS_Portal_Delegated_Admin'),
                'ISS Portal DPC Admin' => customSetingMap.get('ISS_Portal_DPC_Admin')
            };
                    
                    
    public static set<Id> adminIdSet = new set<Id>{ customSetingMap.get('ISS_Portal_Agency_Delegated_Admin'),
        customSetingMap.get('ISS_Portal_Airline_Delegated_Admin'),
        customSetingMap.get('ISS_Portal_GSA_Delegated_Admin'),
        customSetingMap.get('ISS_Portal_Delegated_Admin'),
        customSetingMap.get('ISS_Portal_DPC_Admin')
        };
                            
    public static set<Id> ISSProfileSet = new set<Id>{ customSetingMap.get('ISS_Portal_Agency_Delegated_Admin'),
        customSetingMap.get('ISS_Portal_Airline_Delegated_Admin'),
        customSetingMap.get('ISS_Portal_GSA_Delegated_Admin'),
        customSetingMap.get('ISS_Portal_Delegated_Admin'),
        customSetingMap.get('ISS_Portal_Agency_User'),
        customSetingMap.get('ISS_Portal_Airline_User'),
        customSetingMap.get('ISS_Portal_GSA_User'),
        customSetingMap.get('ISS_Portal')
        }; 

     public static set<Id> ISSProfileSet_forContentUser = new set<Id>{ customSetingMap.get('ISS_Portal_Agency_Delegated_Admin'),
        customSetingMap.get('ISS_Portal_Airline_Delegated_Admin'),
        customSetingMap.get('ISS_Portal_GSA_Delegated_Admin'),
        customSetingMap.get('ISS_Portal_Airline_User'),
        customSetingMap.get('ISS_Portal_Agency_User'),
        customSetingMap.get('ISS_Portal_GSA_User'),
        customSetingMap.get('ISS_Portal_Agency_Delegated_Admin'),
        customSetingMap.get('ISS_Portal'),
        customSetingMap.get('ISS_Portal_DPC'),
        customSetingMap.get('ISS_Portal_PwC2'),
        customSetingMap.get('ISS_Default_Portal')
    };    
                                    
    public static Map<String,Map<String,String>> profilNameByUserTypeMap =  new Map<String,Map<String,String>>
    {
        'User' => new map<String,String>{
            'Agency'=>'ISS Portal Agency User',
            'Airline'=>'ISS Portal Airline User',
            //'Agency'=>'ISS Portal',
            //'Airline'=>'ISS Portal',
            'GSA'=>'ISS Portal GSA User',
            //'GSA'=>'ISS Portal',
            'Other'=>'ISS Portal',
            'GloballSalesAgent' => 'ISS Portal GSA User',
            //'GloballSalesAgent' => 'ISS Portal',
            'NonIATAAgent' => 'ISS Portal',
            'OtherCompany' => 'ISS Portal',
            'TIESS' => 'ISS Portal',
            'GeneralPublic' => 'ISS Portal'
        },
        'Admin' => new map<String,String>{
            'Agency'=>'ISS Portal Agency Delegated Admin User',
            'Airline'=>'ISS Portal Airline Delegated Admin User',
            'GSA'=>'ISS Portal GSA Delegated Admin User',
            'DPC' => 'ISS Portal DPC Admin',
            'Other'=>'ISS Portal Delegated Admin User'
        }
    };
        
    public static Map<String,String> userTypeByAccountRtDeveloperNameMap =  new Map<String,String>
    {
        'IATA_Agency'=>'Agency',
        'IATA_Airline_BR'=>'Airline',
        'IATA_Airline'=>'Airline',
        'IATA_GSA'=>'GSA'
        };
        
    public static Map<String,String> accountSectorType =  new Map<String,String>
    {
        'Cargo Agent'=>'Agency',
        'Travel Agent'=>'Agency',
        'Airline'=>'Airline',
        'Internal Use'=>null
        };
    
    public static Map<String,String> accountCategoryType =  new Map<String,String>
    {
        'DPC'=>'DPC'
    };
                                            
    public static Map<String, Set<String>> accountRecordTypeByUserType = new Map<String, Set<String>>
    {
        'Airline' => new set<string>{'IATA_Airline', 'IATA_Airline_BR', 'Standard_Account'},
        'GloballSalesAgent' => new set<string>{'IATA_GSA'},
        'Agency' => new set<string>{'IATA_Agency'},
        'NonIATAAgent' => new set<string>{'Others', 'Standard_Account'},
        'OtherCompany' => new set<string>{'Others', 'Standard_Account','TIP_Payment_Provider'},
        'TIESS' => new set<string>{'Others', 'IATA_Agency', 'IATA', 'Standard_Account'},
        'GeneralPublic' => new set<string>{'Standard_Account'}
    };
                                            
    public static Map<String, String> accountDefaultRecordTypeByCustomerType = new Map<String, String>
    {
        'Airline' => 'Standard_Account',
            //'Airline' => 'IATA_Airline',
            'GloballSalesAgent' => 'Standard_Account',
            'Agency' => 'IATA_Agency',
            'NonIATAAgent' => 'Standard_Account',
            //'NonIATAAgent' => 'Others',
            //'OtherCompany' => 'Others',
            'OtherCompany' => 'Standard_Account',
            //'TIESS' => 'Others',
            'GeneralPublic' => 'Standard_Account'
            };
                                                    
    //New Test Portal User Profile Id
    public final static string TEST_User_ProfileID = [select Id from profile where Name=:'ISS Portal Delegated Admin User'].Id;
    public final static string TEST_Basic_Airline_User_ProfileID = [select Id from profile where Name=:'ISS Portal Airline User (Partner)'].Id;
    public final static string Standard_Contact_Record_Type = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
    
    // owner for new account created by the ISSP Portal registration
    // because we cant create portal user it the account's owner is portal guest
    // retrived from custom settings
    public final static String newAccountOwnerId = customSetingMap.get('DefaultNewAccountOwnerId');
    //public final static String newAccountOwnerId = '00511000000u9VkAAI';
    
    // Case RecordType Names map
    public static final Map<String,String> caseTypeMap = new Map<String,String>{
        'DPC Service Request'   => 'DPCSR',
        'Inter DPCs'   => 'DPCSR',
            'IATA Service Request'  => 'IATASR',
            'IATA Financial Review' => 'IFAP',
            'Application Change Request (DPC Systems - locked)' => 'ACR',
            'Application Change Request (DPC Systems) - ACCA'  => 'ACR',
            'Cases - SIS Help Desk' => 'SIS',
            'ISS Portal PwC for IATA user' => 'PWC',
            'ISS Portal PwC' => 'PWC',
            'IDFS Airline Participation Process' => 'AP',
            'Process' => 'CSP',
            'Invoicing Collection Cases' => 'ICC',
            'SAAM' => 'SAAM',
            'OSCAR Communication' => 'OSCAR',
            'SIDRA' => 'SIDRA'
            };
                
    // Case Status Names Map: Case.Status => internal code
    public static final Map<String,String> caseStatusMap = new Map<String,String>{
            'Open'                                    => 'OPEN',
            'Closed'                                    => 'CLOSED',
            'DPC Investigating'                         => 'DPC_INVESTIGATING',
            'DPC investigating'                         => 'DPC_INVESTIGATING',
            'Development'                               => 'DEVELOPMENT',
            'Deployment'                                => 'DEPLOYMENT',
            'Escalated'                                 => 'ESCALATED',
            'New'                                       => 'NEW',
            'Scheduled'                                 => 'SCHEDULED',
            'UAT'                                       => 'UAT'
            }; 
                          
    public static final Map<String,Decimal> caseStatusMap_ACR_Internal = new Map<String,Decimal>{
            'Escalated to DPC for PQ'                   => 2.0,
            '2.0 IE approved - Escalated DPC for PQ'    => 2.0,
            '2.1 BC - Pending DPCM feedback'            => 2.1,
            '2.2 BC - Pending internal feedback'        => 2.2,
            '2.3 BC - Pending DPC feedback'             => 2.3,
            'PQ in progress'                            => 3.0,
            '3.0 BC completed - PQ in progress'         => 3.0,
            '3.1 PQ received'   						=> 3.1,
            '3.1 PQ received - pending DPCM feedback'   => 3.1,
            'PQ approved - pending development'         => 3.2,
            '3.2 PQ received - pend Internal feedback'  => 3.2,
            '3.3 PQ approved - Stakeholder comm done'   => 3.3,
            'Development'                               => 4.0,
            '4.0 UAT date received - Dev in progress'   => 4.0,
            '4.1 Development - pending IATA feedback'   => 4.1,
            '4.2 Development - pending DPC feedback'    => 4.2,
            'UAT'                                       => 5.0,
            '5.0 UAT results - pending DPCM approval'   => 5.0,
            '5.1 UAT Approval-Pend Internal Approval'   => 5.1,
            '5.2 UAT approval - pending DPC feedback'   => 5.2,
            '5.3 UAT approval - DPC feedback received'  => 5.3,
            '6.0 UAT Approval - DD - s/holder comm'     => 6.0,
            '6.1 DD Date Provided - DD in Progress'     => 6.1,
            '7.0 DD Completed - Doc review ongoing'     => 7.0,
            '7.1 Doc review - pending DPC feedback'     => 7.1,
            '7.2 Doc Review - DPC feedback received'    => 7.2,
            '8.0 Doc review - completed'                => 8.0,
            'Closed'                                    => 9.0,
            '9.0 Closed'                                => 9.0,
            '10. Rejected - before PQ'                  => 10.0,
            '11. Rejected - after PQ'                   => 11.0
            };
                           
                            
   // DPC Case Status Names Map: Case.Status => internal code
    public static final Map<String,Decimal> caseStatusMap_ACR_Portal = new Map<String,Decimal>{
            'DPC Investigating'                         => 2.0,
            '2.0 DPC Investigating'                     => 2.0,
            '2.0 New'                                   => 2.0,
            '2.1 BC - pending IATA feedback'            => 2.1,
            '2.3 BC - IATA feedback provided'           => 2.3,
            '3.0 BC completed - PQ in progress'         => 3.0,
            'Waiting for quotation approval'            => 3.0,
            '3.1 PQ delivered - waiting IATA approval'   => 3.1,
            '3.3 PQ approved'                            => 3.3,
            'In development'                             => 4.0,
            '4.0 UAT date provided - Dev in progress'    => 4.0,
            '4.1 Development - Pending IATA feedback'    => 4.1,
            '4.2 Development - pending DPC feedback'     => 4.2,
            'Waiting for test results approval'          => 5.0,
            '5.0 UAT results - pending IATA approval'    => 5.0,
            '5.2 UAT Approval - Pending DPC Feedback'    => 5.2,
            '5.3 UAT approval - DPC feedback provided'   => 5.3,
            '6.0 UAT Approved - DD in progress'         => 6.0,
            '6.1 DD Date Provided - DD in Progress'      => 6.1,
            '7.0 DD completed - Pending IATA review'     => 7.0,
            '7.1 Doc review - Pending DPC feedback'      => 7.1,
            '7.2 Doc review - DPC Feedback Provided'     => 7.2,
            '8.0 Doc review - completed'                 => 8.0,
            '9.0 Closed'                                 => 9.0,
            '10. Rejected - before PQ'                   => 10.0,
            '11. Rejected - after PQ'                    => 11.0
            }; 
            
    public static map<string,string> languageMap = new  map<string,string>{
        'es'=>'Spanish',
        'en_US'=>'English',
        'ko'=>'Korean',
        'zh_CN'=>'Chinese',
        'pt_BR'=>'Portuguese',
        'fr'=>'French',
        'ja'=>'Japanese',
        'it'=>'Italian',
        'de'=>'German',
        'th'=>'Thai',
        'in'=>'Indonesian',
        'vi'=>'Vietnamese'
    };
    
}
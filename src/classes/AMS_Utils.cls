public without sharing class AMS_Utils {

    public static Map<String,IATA_ISO_Country__c> mapCountries{

        get{

            if(mapCountries == null)
                mapCountries = mapCountries = new map<String,IATA_ISO_Country__c>([SELECT Id, ISO_Code__c FROM IATA_ISO_Country__c]);

            return mapCountries;

        }

    }

    public static Boolean runningContactInsertUpdateFromOSCAR = false;

    //public static Boolean isNewGenProcess = false;

    public static List<Profile> profiles;

    public static Set<Id> AMSPROFILES {
        get {
            Set<Id> toReturn = new Set<Id>();

            if(profiles == null)
                profiles = [select ID from profile where Name IN ('FDS Hub Analyst ARM', 'FDS – Agency Management - Supervisor (Approver)', 'IDFS Americas - Hub CS Management', 'IDFS Americas - Hub Staff')];

            for (Profile p : profiles)
                toReturn.add(p.Id);

            return toReturn;
        }
    }

    public static Map<String, IATA_ISO_State__c> iataIsoStates{
        get{
            if(iataIsoStates == null){
                iataIsoStates = new Map<String, IATA_ISO_State__c>();
                for(IATA_ISO_State__c state : [SELECT Id, Name, ISO_Code__c FROM IATA_ISO_State__c]){
                    iataIsoStates.put(state.Name.toLowerCase(), state);
                }
                System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - iataIsoStates] iataIsoStates - ' + iataIsoStates);
            }

            return iataIsoStates;
        }
        set;
    }

    public static Map<String, IATA_ISO_Country__c> iataIsoCountries{
        get{
            if(iataIsoCountries == null){
                iataIsoCountries = new Map<String, IATA_ISO_Country__c>();
                for(IATA_ISO_Country__c country : [SELECT Id, Name FROM IATA_ISO_Country__c]){
                    iataIsoCountries.put(country.Name.toLowerCase(), country);
                }
                System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - iataIsoCountries] iataIsoCountries - ' + iataIsoCountries);
            }

            return iataIsoCountries;
        }
        set;
    }

    public static List<AMS_ChangeCodes__c> CUSTOM_CHANGECODES {
        get {
            if(CUSTOM_CHANGECODES == null){
                CUSTOM_CHANGECODES = [SELECT Change_Code__c,Integration_RecId__c,Account_status_change__c,Billable__c,Bulletin_Memo_Text__c,
                                                                Reason_Code__c, Reason_Code_Description__c
                                                        FROM AMS_ChangeCodes__c];
            }
            return CUSTOM_CHANGECODES;
        }
        private set;
    }

    public static List<AMS_ChangeCodes_Integration__c> CUSTOM_CHANGECODES_INTEGRATION {
        get {
            if(CUSTOM_CHANGECODES_INTEGRATION == null){
                CUSTOM_CHANGECODES_INTEGRATION = [SELECT RecId_A__c,RecId_B__c,RecId_Res__c FROM AMS_ChangeCodes_Integration__c];

            }
            return CUSTOM_CHANGECODES_INTEGRATION;
        }
        private set;
    }

    //20-06-2017 - AMSU-93
    public static Map<String, String> JsonSpecialChars{
        get {
            if(JsonSpecialChars == null){
                JsonSpecialChars = AMS_Utils.loadJsonSpecialCharsFile();
            }
            return JsonSpecialChars;
        }
        private set;
    }

    private static Map<String, RecordType> currentCache = null;

    public static final String SANITYCHECK = 'Perform Sanity Check';
    public static final String APPROVAL = 'Manager Approval';
    public static final String WITHDRAWAL = 'Application Withdrawal';
    public static final String SUSPENSION = 'Process suspension';
    public static final String TERMINATION = 'Process termination';
    public static final String DUEDILIGENCE = 'Due Diligence';
    public static final String SETUPPROCESSING = 'Setup Processing';
    public static final String SETUPFINALIZATION = 'Setup finalization';

    public static final String PASSED = 'Passed';
    public static final String FAILED = 'Failed';
    public static final String IN_PROGRESS = 'In Progress';
    public static final String NOT_APPLICABLE = 'Not Applicable';

    public static final String AUTH_APPROVAL = 'Authorize Approval';
    public static final String AUTH_DISAPPROVAL ='Authorize Disapproval';
    public static final String LOCATION_TYPE = 'Location type';
    public static final String LOCATION = 'Location';
    public static final String LOCATION_INSPECTION = 'Location with inspection';
    public static final String OWNERSHIP_IATA = 'Ownership to IATA Agent';
    public static final String OWNERSHIP_NON_IATA = 'Ownership to non-IATA Agent';
    public static final String MAJ_SHAREHOLDING = 'Major Shareholding';
    public static final String MIN_SHAREHOLDING = 'Minor Shareholding';
    public static final String NAME = 'Name';
    public static final String LEGAL_STATUS = 'Legal status';
    public static final String VFMR = 'VMFR';
    public static final String REMOVALTRADENAME = 'CNS - Removal of trade name';


    public static final String ANG_LEGAL_NAME = 'Legal name';
    public static final String ANG_LEGAL_STATUS =  'Legal status';
    public static final String ANG_MINOR_SHAREHOLDING = 'Minor shareholding';
    public static final String ANG_MAJOR_SHAREHOLDING = 'Major shareholding';
    public static final String ANG_OWNERSHIP =  'Ownership';
    public static final String ANG_LOCATION_TYPE =  'Location type';
    public static final String ANG_LOCATION_TYPE_DIFFLEGALENTITY =  'Location type to different legal entity';
    public static final String ANG_LOCATION =  'Location';
    public static final String ANG_HIERARCHY =  'Hierarchy';
    public static final String ANG_TRADE_NAME = 'Trade name';
    public static final String ANG_VMFR =  'VMFR';
    public static final String ANG_ACCREDITATION_TYPE = 'Accreditation type';

    public static final Set<String> ANG_OSCAR_MAJOR_CHANGES_PROCESSES = new Set<String>{ANG_OWNERSHIP, ANG_HIERARCHY, ANG_LOCATION_TYPE_DIFFLEGALENTITY, ANG_LEGAL_NAME,
                                                                                ANG_LEGAL_STATUS, ANG_MAJOR_SHAREHOLDING, ANG_ACCREDITATION_TYPE};

    public static final String OSCAR_CLOSED = 'Closed';

    public static final String BR = 'BR';
    public static final String HO = 'HO';
    public static final String AO = 'AO';
    public static final String SA = 'SA';
    public static final String HE = 'HE';
    public static final String AE = 'AE';

    public static final String PORTAL_APP_ACCESS_GRANTED = 'Access Granted';

    //Processes of type NEW
    public static final String new_HO           = 'NEW.HO.1.0'      ;
    public static final String new_BR           = 'NEW.BR'          ;
    public static final String new_BR_ABROAD    = 'NEW.BR.ABROAD'   ;
    public static final String new_TIDS         = 'NEW.TIDS.1.0'    ;
    public static final String new_MSO          = 'NEW.MSO.1.0'     ;
    public static final String new_GSA          = 'NEW.GSA.1.0'     ;
    public static final String new_GSA_BSP      = 'NEW.GSA.1.0.BSP' ;
    public static final String new_GSSA         = 'NEW.GSSA.1.0'    ;
    public static final String new_AHA          = 'NEW.AHA.1.0'     ;
    public static final String new_AHA_BSP      = 'NEW.AHA.1.0.BSP' ;
    public static final String new_SA           = 'NEW.SA.1.0'      ;

    //Processes of type CHANGES
    public static final String COR              = 'CORRECTION.1.0'  ;
    public static final String AGENCYCHANGES    = 'MAJOR.CHANGES'   ;
    public static final String VOLRELINQUISH    = 'VR.1.0'          ;
    public static final String VOLRELINQUISH_CA = 'VR.1.0.CA'       ;
    public static final String BANKACCCHANGES   = 'BANK.ACCOUNT.CHANGES';
    public static final String CERTIFICATION    = 'CERTIFICATION.1.0';
    public static final String IEPBANKACCOUNTSETUP = 'IEP.BANK.ACCOUNT.SETUP';
    public static final String PCI_COMPLIANT    = 'PCI.COMPLIANT.1.0';

    //Process of type NewGen
    public static final String NEWHELITE        = 'ANG.NEW.HE.LITE.1.0';
    public static final String NEWHESTANDARD    = 'ANG.NEW.HE.STANDARD.1.0';
    public static final String NEWAE            = 'ANG.NEW.AE.1.0';
    public static final String NGCHANGES        = 'ANG.MAJOR.CHANGES.1.0';
    public static final String NGCORRECTION     = 'NGCORRECTION.1.0';
    public static final String NGFOP            = 'ANG.FOPMANAGEMENT.1.0';
    public static final String NGVR             = 'VR.1.0';
    public static final String NGOPTINOUT       = 'ANG.FS.OPTINOUT';
    public static final String NGANNUALREVAL    = 'ANG.ANNUAL.REVALIDATION';

    //AMSU-125
    public static final Set<String> oscarNewProcesses = new Set<String> {new_HO, new_BR, new_BR_ABROAD, new_TIDS, new_MSO, new_GSA, new_GSA_BSP, new_GSSA, new_AHA, new_AHA_BSP, new_SA};

	//AMSU-162
    public static final Set<String> AMS_ProcessesAddressToValidate = new Set<String> {new_HO, new_BR, new_BR_ABROAD, new_TIDS, new_GSA, new_GSA_BSP, new_GSSA, new_AHA, new_AHA_BSP, new_SA, new_MSO};

    //AMSU-180
    public static final Set<String> oscarAMSProcesses_ValidateOwnership = new Set <String>{new_HO, new_BR, AGENCYCHANGES, new_TIDS, new_SA, COR};

    public static final Set<String> oscarNewGenProcesses = new Set <String>{NEWHELITE, NEWHESTANDARD, NEWAE, NGCHANGES, NGCORRECTION, NGOPTINOUT, NGFOP};
    public static final Set<String> oscarNewGenNewAppProcesses = new Set <String>{NEWHELITE, NEWHESTANDARD, NEWAE};

    public static final Set<String> changesRequiringManagerApproval = new Set<String>{ANG_LEGAL_NAME,ANG_LEGAL_STATUS,ANG_MAJOR_SHAREHOLDING,
                                                                                    ANG_LOCATION_TYPE_DIFFLEGALENTITY,ANG_OWNERSHIP,ANG_HIERARCHY,ANG_ACCREDITATION_TYPE};

    public static final Set<String> oscarPCICompliantMigrationProcesses = new Set <String>{NEWHESTANDARD,NEWHELITE, NEWAE, NGCORRECTION};
    public static final Set<String> oscarPCICompliantValidationAttachement = new Set <String>{'Yes','Nil CC','Corporate Card'};
    public static final Set<String> oscarPCICompliantValidationExpiryDate = new Set <String>{'Yes','Nil CC'};

    //other types of process
    public static final String CERTIFICATE      = 'CER.1.0'         ;

    //Types of Certificate
    public static final String CERT_DGR         = 'DGR';
    public static final String CERT_DGA         = 'DGA';
    public static final String CERT_CATA        = 'CATA';
    public static final String CERT_TSA         = 'TSA';

    //Record Types
    public static final String RECTYPE_NEW          = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('AMS_OSCAR__c').get('NEW');
    public static final String RECTYPE_CHANGE       = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('AMS_OSCAR__c').get('CHANGE');
    public static final String RECTYPE_CERT         = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('AMS_OSCAR__c').get('CERTIFICATION');
    public static final String RECTYPE_NEWHE        = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('AMS_OSCAR__c').get('ANG_New_HE');
    public static final String RECTYPE_NEWAE        = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('AMS_OSCAR__c').get('ANG_New_AE');
    public static final String RECTYPE_NGCHANGES    = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('AMS_OSCAR__c').get('ANG_Agency_Changes');
    public static final String RECTYPE_NGCORRECTION = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('AMS_OSCAR__c').get('NGCORRECTION');
    public static final String RECTYPE_CORRECTION   = Schema.AMS_OSCAR__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('CORRECTION').getRecordTypeId();
    public static final String RECTYPE_NEWGENFOP   = Schema.AMS_OSCAR__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('NGFormsOfPayment').getRecordTypeId();
    public static final String RECTYPE_NEWGENOPTINOUT   = Schema.AMS_OSCAR__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('ANG.FS.OPTINOUT').getRecordTypeId();
    public static final String RECTYPE_NEWGENANNUALREVAL   = Schema.AMS_OSCAR__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('ANG.ANNUAL.REVALIDATION').getRecordTypeId();

    public static final String RECTYPE_OSCARCOMM    = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('OSCAR_Communication');
    public static final String RECTYPE_SIDRALITE    = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('SIDRA_Lite');
    public static final String RECTYPE_SAAM         = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('ProcessEuropeSCE');
    public static final String RECTYPE_SIDRA        = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('SIDRA');
    public static final String RECTYPE_IFAP         = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('IATA_Financial_Review');
    public static final String RECTYPE_IATAAGENCY   = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency');

    public static final String RECTYPE_IATAEASYPAY  = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('AP_Process_Form__c').get('IATA_EasyPay_Opt_in_Out');
    public static final String RECTYPE_IEP_MODEL_A  = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('AMS_Accreditation_Requirement__c').get('IEP_Model_A');

    public static final String RECTYPE_BSP = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('AMS_Settlement_System__c').get('BSP');

    public static final Id OSCAR_COMUNICATION = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();

    public static final Set<String> oscarAMSProcesses = new Set <String>{new_HO,new_BR,new_BR_ABROAD,new_TIDS,new_MSO,new_GSA,new_GSA_BSP,new_GSSA,new_AHA,new_AHA_BSP,new_SA, COR,NEWHELITE,NEWHESTANDARD};


    //public static final Set<String> oscarProcessesWithAppointments = new Set <String>{new_GSA,new_GSA_BSP,new_AHA,new_AHA_BSP,new_GSSA,new_MSO, new_HO,new_BR,new_BR_ABROAD};

    public static final String ACC_S0_TERMINATED = 'Terminated';
    public static final String ACC_S1_NOTACCREDITED = 'Not accreditated';
    public static final String ACC_S2_NEWAPPLICATIONPENDING = 'New application pending';
    public static final String ACC_S3_NOTINOPERATION = 'Not in operation';
    public static final String ACC_S4_LISTED = 'Listed';
    public static final String ACC_S5_CASHNOCOMMISSION = 'Cash basis/no commission';
    public static final String ACC_S6_CASHWITHCOMMISSION = 'Cash basis/with commission';
    public static final String ACC_S7_UNDERREVIEW = 'Under review';
    public static final String ACC_S8_CHANGESPROCESSED = 'Changes processed';
    public static final String ACC_S9_APPROVED = 'Approved';

    public static final Set<String> ACTIVEAGENCYSTATUS = new Set<String>{ACC_S4_LISTED, ACC_S5_CASHNOCOMMISSION, ACC_S6_CASHWITHCOMMISSION, ACC_S7_UNDERREVIEW, ACC_S8_CHANGESPROCESSED, ACC_S9_APPROVED};

    public static final String AACC_INPROGRESS = 'in progress';
    public static final String AACC_FINALIZED = 'finalized';
    public static final String AACC_WITHDRAWAL = 'withdrawn';
    public static final String AACC_DISAPPROVED = 'disapproved';
    public static final String AACC_RECONSIDERED = 'reconsidered';
    public static final Set<String> AACC_FINALS = new Set<String>{AACC_FINALIZED, AACC_DISAPPROVED, AACC_WITHDRAWAL};

    public static final String CHLOCTYPEBEHAVIOR_NOSWAP = 'Don’t change the parent';
    public static final String CHLOCTYPEBEHAVIOR_SWAP = 'Swap with the parent';
    public static final String CHLOCTYPEBEHAVIOR_STANDARD = CHLOCTYPEBEHAVIOR_SWAP;
    public static final String SECTOR_CARGO = 'Cargo Agent';
    public static final String SECTOR_PASSENGER = 'Travel Agent';
    public static final String CATEGORY_CASSASSOCIATE = 'CASS Associate';

    public static final String NEWFORM_AGENTTYPE_CASH = 'Standard with Cash';
    public static final String NEWFORM_AGENTTYPE_NO_CASH = 'Standard no Cash';
    public static final String CASE_REASON_HE_STANDARD = 'New HE standard';
    public static final String CASE_REASON_HE_LITE = 'New HE lite';
    public static final String CASE_REASON_ASSOCIATE_ENTITY_STANDARD = 'New AE';
    public static final String CASE_REASON_NEW_HO = 'New HO';
    public static final String CASE_REASON_AE_STANDARD = 'New AE standard';
    public static final String CASE_REASON_AE_LITE = 'New AE lite';

    public static final String CASE_REASON_BR_ABROAD = 'New BR Abroad';
    public static final String CASE_REASON_BR_IP = 'New BR / IP';
    public static final String CASE_AREA_ACCREDITATION_PROCESS = 'Accreditation Process';
    public static final String CASE_AREA_AGENCY_RISK_MANAGEMENT = 'Agency Risk Management';
    public static final String CASE_REASON_FOR_MANAGEMENT = 'FoP Management';
    public static final String CASE_REASON_VR_CLOSURE = 'CLO - Closure';
    public static final String CASE_REASON_OPT_OUT = 'Financial review opt-in / opt-out';
    public static final String CASE_REASON_PCI_DSS_COMPLIANT = 'PCI DSS Compliant';

    // Case - Origin
    public static final String CASE_ORIGIN_PORTAL = 'Portal';
    public static final String ANG_MASSIVE_FOP = 'Massive FOP Creation';
    public static final String ANG_FOP_AUTOMATIC_RENEWAL = 'FoP automatic renewal';

    // Case - Status
    public static final String CASE_STATUS_CLOSED = 'Closed';
    public static final String CASE_STATUS_FINANCIAL_SECURITY_REQUESTED = 'Financial Security Requested';

    // Case - Reason1__c //AMSU-165
    public static final String CASE_REASON_CHG_DATA_MAINTENANCE = 'CHG – Data Maintenance';

    //set with the ifap status to update the account's last financial review
    public static final Set<String> CASE_STATUS_UPDATE_FINANCIAL_REVIEW_SET= new Set<string>{CASE_STATUS_CLOSED};

    public static final String CASE_TYPE_OF_CUSTOMER_IATA_TRAVEL_AGENT = 'IATA Travel Agent';

    public static final String CATEGORY_TRAVEL_AGENT = 'Travel Agent';
    public static final String CATEGORY_PASSENGER_SALES_AGENT = 'IATA Passenger Sales Agent';
    public static final String CATEGORY_DOMESTIC_AGENT = 'Domestic Agent';
    public static final String CATEGORY_IMPORT_AGENT = 'Import Agent';
    public static final String CATEGORY_COURIER = 'Courier';

    public static final String TYPECHANGE_OWNERIATA2IATA = 'Ownership to IATA Agent';
    public static final String TYPECHANGE_OWNERIATA2NONIATA = 'Ownership to non-IATA Agent';
    public static final String TYPECHANGE_LOCATION = 'Location';
    public static final String TYPECHANGE_LOCATIONWITHINSPECTION = 'Location with inspection';
    public static final Id AccreditationContactPersonRT = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Person').getRecordTypeId();
    public static final Id AccreditationContactCompanyRT = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Company').getRecordTypeId();
    public static final Id AccreditationContactTrainedStaffRT = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Trained Staff').getRecordTypeId();
    public static final Id AccountRoleOwnershipRT = Schema.SObjectType.AMS_Account_Role__c.getRecordTypeInfosByName().get('Ownership').getRecordTypeId();

    public static final Set<String> LocationClassIFAPAllowed = new Set<String>{'P','C','R'};
    public static final Set<String> LocationClassCARGO = new Set<String>{'C','I','Q','R'};
    public static final Set<String> LocationClassDGR = new Set<String>{'C','R'};
    public static final Set<String> LocationClassPASSENGER = new Set<String>{'P','T','M','X','G','D'};
    public static final Set<String> LocationTypeAllHOTypes = new Set<String>{'EP','AO','SP','AA','HO','HE'};

    public static final String AGENTTYPE_WITHCASH = 'Standard with Cash';
    public static final String AGENTTYPE_NOCASH = 'Standard no Cash';

    //Account - ANG_Accreditation_Model__c
    public static final String ACCREDITATIONMODEL_CASH = 'Cash';
    public static final String ACCREDITATIONMODEL_CASHLESS = 'Cashless';
    public static final String ACCREDITATIONMODEL_LEGACY = 'Legacy';
    public static final String ACCREDITATIONMODEL_MULTICOUNTRY = 'Multicountry';

    public static final String IATAN_PASSENGER_AGENT = 'IATAN Passenger Agent';

    public static final String ARC_TRAVEL_AGENT_USA_ONLY = 'ARC Travel Agent (USA Only)';
    public static final String IATAN_PASSENGER_SALES_AGENT_USA_ONLY = 'IATAN Passenger Sales Agent (USA Only)';
    public static final String TRAVEL_SERVICE_INTERMEDIATES_TSI_USA_ONLY = 'Travel Service Intermediaries-TSI (USA Only)';


    //Account - Location_Class__c
    public static final String LC_PASSENGER = 'P';

    //officeTypes
    public static final String TYPE_EACP_HO = buildOfficeType(CASE_REASON_NEW_HO, 'EACP Intermediary');
    public static final String TYPE_EACP_BRANCH = buildOfficeType(CASE_REASON_BR_IP, 'EACP Intermediary');
    public static final String TYPE_CGO_HO = buildOfficeType(CASE_REASON_NEW_HO, 'IATA Cargo Agent');
    public static final String TYPE_CGO_BRANCH = buildOfficeType(CASE_REASON_BR_IP, 'IATA Cargo Agent');
    public static final String TYPE_COURIER_HO = buildOfficeType(CASE_REASON_NEW_HO, CATEGORY_COURIER);
    public static final String TYPE_COURIER_BRANCH = buildOfficeType(CASE_REASON_BR_IP, CATEGORY_COURIER);
    public static final String TYPE_IMPORT_HO = buildOfficeType(CASE_REASON_NEW_HO, CATEGORY_IMPORT_AGENT);
    public static final String TYPE_IMPORT_BRANCH = buildOfficeType(CASE_REASON_BR_IP, CATEGORY_IMPORT_AGENT);
    public static final String TYPE_CASS_ASSOC_HO = buildOfficeType(CASE_REASON_NEW_HO, CATEGORY_CASSASSOCIATE);
    public static final String TYPE_CASS_ASSOC_BRANCH = buildOfficeType(CASE_REASON_BR_IP, CATEGORY_CASSASSOCIATE);
    public static final String TYPE_PAX_BRANCH_ABROAD_PSA = buildOfficeType(CASE_REASON_BR_ABROAD, CATEGORY_PASSENGER_SALES_AGENT);
    public static final String TYPE_PAX_BRANCH_ABROAD_L = buildOfficeType(CASE_REASON_BR_ABROAD, ACCREDITATIONMODEL_LEGACY);
    public static final String TYPE_PAX_BRANCH_L = buildOfficeType(CASE_REASON_BR_IP, ACCREDITATIONMODEL_LEGACY);
    public static final String TYPE_PAX_AE_CASH = buildOfficeType(CASE_REASON_ASSOCIATE_ENTITY_STANDARD, NEWFORM_AGENTTYPE_CASH);
    public static final String TYPE_PAX_AE_NO_CASH = buildOfficeType(CASE_REASON_ASSOCIATE_ENTITY_STANDARD, NEWFORM_AGENTTYPE_NO_CASH);
    public static final String TYPE_PAX_HO = buildOfficeType(CASE_REASON_NEW_HO, ACCREDITATIONMODEL_LEGACY);
    public static final String TYPE_HE_ST_CASH = buildOfficeType(CASE_REASON_HE_STANDARD, AGENTTYPE_WITHCASH);
    public static final String TYPE_HE_LITE_NO_CASH = buildOfficeType(CASE_REASON_HE_LITE, AGENTTYPE_NOCASH);
    public static final Set<String> processesANGrequiredAttachValidation = new Set<String>{NEWHELITE,NEWHESTANDARD,NEWAE,NGCHANGES}; 
	public static final Set<String> processesAMSrequiredAttachValidation = new Set<String>{new_HO,new_BR,AGENCYCHANGES,CERTIFICATION,VOLRELINQUISH,PCI_COMPLIANT}; //AMSU-34

    public static final String OPEN = 'Open';
    public static final String NO_IEP_ACCOUNT = 'No IEP Account';

    public static final String CC = 'CC';
    public static final String CA = 'CA';
    public static final string EP = 'EP';
    public static final String IATA_ACCREDITATION_AND_CHANGES = 'IATA Accreditation & Changes';
    public static final String CGO_SIGNED_CONTRACT = 'CGO_SIGNED_CONTRACT';
    public static final String NOC_SIGNED_CONTRACT = 'NOC_SIGNED_CONTRACT';
    public static final String PCI_COMPLIANCE = 'PCI_COMPLIANCE';

    public static final String RECTYPE_CASEIFAP   = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('IATA_Financial_Review');

    //Mass created FOP case/OSCAR is assigned to one of theses queues when created:
    public static final Set<String> MASS_FOP_QUEUES = new Set<String>{'NewGen PCI - Africa & Middle East','NewGen PCI - Americas','NewGen PCI - Asia & Pacific','NewGen PCI - China & North Asia','NewGen PCI - Europe'};
	
	/* AMSU-139 */
    public static final String REJECTED = 'Rejected';
    public static final String REJECTED_CLOSED = 'Rejected Closed';
    public static final String ACCEPTED = 'Accepted';

    /* AMSU-37 */
    public static final String APP_DISAPPROVED = '12-APPLICATION DISAPPROVED';
    public static final String APP_WITHDRAWN = '11-APPLICATION WITHDRAWN';


    static {
        refreshCache();
    }

    public static String ENCRYPTION_KEY {
        get {
            return Test.isRunningTest() ? 'hasd==aSDFclDDGasjdhfclx' : AMS_SAP_Settings__c.getOrgDefaults().Encryption_Key__c;
        }
    }

    public static String ENCRYPTION_ALGORYTHM {
        get {
            return Test.isRunningTest() ? 'AES128' : AMS_SAP_Settings__c.getOrgDefaults().Encryption_Algorythm__c;
        }
    }

    private static String buildOfficeType(String reason, String category) {
        return reason + ' - ' + category;
    }

    public static Map<String, String> categoryCustomerMap = new Map<String, String> {
        'IATA Passenger Sales Agent' => 'IATA Travel Agent',
        'IATA Cargo Agent' =>   'IATA Cargo Agent',
        'Import Agent' =>   'IATA Cargo Agent',
        'CASS Associate' => 'CASS Associates',
        'Courier' =>    'IATA Cargo Agent',
        'Handling Agent' => 'IATA Travel Agent',
        'MSO Member Sales Office' => 'IATA Travel Agent',
        'TIDS Agent' => 'TIDS',
        'GSA General Sales Agent' =>    'General Sales Agent (GSA)',
        'GSSA Cargo' => 'GSSA Cargo'
    };

    public AMS_Utils() {}
    //private static final String ENCRYPTION_ALGORYTHM = 'AES128';

    @future
    public static void sendEmailAmsSupport( string subject, string message) {



        //List<ID> userIDs = getUserIds(getSupportEmails());
        List<ID> userIDs = new List<ID>();
        userIDs.add('0057E000000HpGoQAK');


        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        try {
            system.debug('Try to send message . ' + subject + ' ******  ' + message);



            for (ID userId : userIDs) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                //mail.setTargetObjectId(userId);
                //String[] toAddresses = new String[] {'mouzinhof@iata.org'};
                String[] toAddresses = new String[] {'fernando.mouzinho@gmail.com'};
                mail.setToAddresses(toAddresses);
                mail.setSenderDisplayName('Apex error message');
                mail.setSubject(subject);
                mail.setSaveAsActivity(false);
                mail.setPlainTextBody(message);
                emailsToSend.add(mail);

            }

            if (Test.isRunningTest() ) {
                Messaging.sendEmail(emailsToSend);
                System.debug('AMS_ApplicationException.SendEmailSupport skipped because this is a Test. Subject: ' + subject + ', message: ' + message);
                return;
            }


        } catch (Exception  e1) {
            system.debug('Failed to send email to users:' + e1.getMessage());
            system.debug('Failed to send email to users:' + e1.getStackTraceString());
        }

    }

    /**
     * Encrypts a string to be used as a GET parameter
     * @param sValue The string parameter to encrypt
     * @return The Encrypted parameter
     */
    public static String EncryptParameter(String sValue) {
        if (sValue == null || sValue == '')
            throw new AMS_ApplicationException('Value parameter is null or empty');
        return EncryptString(ENCRYPTION_KEY, sValue);
    }

    /**
     * Encrypts and URL encode a string to be used as a GET parameter
     * @param sValue The string parameter to encrypt and encode
     * @return The Encrypted/encoded parameter
     */
    public static String EncryptEncodeParameter(String sValue) {
        if (sValue == null || sValue == '')
            throw new AMS_ApplicationException('Value parameter is null or empty');
        return EncodingUtil.urlEncode(EncryptString(ENCRYPTION_KEY, sValue), 'UTF-8');
    }

    /**
     * Decrypts a string
     * @param sValue The string parameter to decrypt
     * @return The decrypted parameter
     */
    public static String DecryptParameter(String sValue) {
        if (Test.isRunningTest()) {sValue = sValue == '' ? 'X9Ecl9XVLvZQH6g5RP6PmjNOzNIOUsfLYtxbGkfxlfE=' : sValue;} //=test_password

        if (sValue == null || sValue == '')
            throw new AMS_ApplicationException('Nothing to decrypt');

        try {
            return DecryptString(ENCRYPTION_KEY, sValue);
        } catch (Exception ex) {
            throw new AMS_ApplicationException('Invalid parameter. Error: ' + ex.getMessage() + ' Stacktrace: ' + ex.getStackTraceString());
        }
    }

    /**
     * URL decode and decrypts a string
     * @param sValue The string parameter to decrypt/decode
     * @return The decrypted/decoded parameter
     */
    public static String DecodeDecryptParameter(String sValue) {
        if (Test.isRunningTest()) {sValue = sValue == '' ? 'X9Ecl9XVLvZQH6g5RP6PmjNOzNIOUsfLYtxbGkfxlfE=' : sValue;}

        if (sValue == null || sValue == '')
            throw new AMS_ApplicationException('Nothing to decrypt');

        try {
            return DecryptString(ENCRYPTION_KEY, Encodingutil.urlDecode(sValue, 'UTF-8'));
        } catch (Exception ex) {
            throw new AMS_ApplicationException('Invalid parameter. Error: ' + ex.getMessage());
        }
    }

    //public static Integer createEmployeePersonFromAccountContact(String agencyId){ #AMSFTS SE FOR NECESSARIO USAR A VF PAGE DOS CONTACTOS DA CONSOLA ESTE METODO TEM DE MUDAR PARA A ACCOUNT ROLE
    public static Integer createEmployeePersonFromAccountContact(String accountId) {
        Integer result = 0;
        /*List<AMS_Employee__c> newEmployees = new List<AMS_Employee__c>();
        Map<String,AMS_Person__c> mapContactPerson= new Map<String,AMS_Person__c>();

        //Map<String,Contact> contactsAccount = new Map<String,Contact>([select id, Person__c, Name, FirstName, LastName, Phone, MobilePhone, Birthdate, Email from Contact where AccountId IN (select Account__c from AMS_Agency__c where id =:agencyId) and Person__c = null]);#AMSFTS
        Map<String,Contact> contactsAccount = new Map<String,Contact>([select id, Person__c, Name, FirstName, LastName, Phone, MobilePhone, Birthdate, Email from Contact where AccountId = :accountId and Person__c = null]);
        if(contactsAccount.size() > 0){
            for(Contact c:contactsAccount.values()){
                AMS_Person__c p = new AMS_Person__c(Name=c.Name,First_Name__c=c.FirstName,Lastname__c=c.LastName,Phone__c=c.Phone,Mobile__c=c.MobilePhone,DOB__c=c.Birthdate,Email__c=c.Email, Contact__c=c.id);
                mapContactPerson.put(c.id,p);
            }
        }

        try{
            if(mapContactPerson.size() > 0){
                insert mapContactPerson.values();
                result += mapContactPerson.size();
            }
        }catch(DMLException e){
            system.debug('***************************** Failed to insert Persons ' + e.getMessage());
            return result;
        }

        for(String c:mapContactPerson.keySet()){
            //AMS_Employee__c e = new AMS_Employee__c(Name=mapContactPerson.get(c).Name,Agency__c=agencyid,Person__c=mapContactPerson.get(c).id,Contact__c=c);#AMSFTS
            AMS_Employee__c e = new AMS_Employee__c(Name=mapContactPerson.get(c).Name,Account__c=accountId,Person__c=mapContactPerson.get(c).id,Contact__c=c);
            newEmployees.add(e);
            contactsAccount.get(c).Person__c = mapContactPerson.get(c).id;
        }

        try{
            if(newEmployees.size() > 0){
                insert newEmployees;
                update contactsAccount.values();
                result += newEmployees.size();
            }
        }catch(DMLException e){
            system.debug('Failed to insert Employees ' + e.getMessage());
            return result;
        }
        */
        return result;
    }

    public static String getStatusDescFromChangeCode(String sChangeCode) {

        String sRes = '';

        if (sChangeCode.startsWithIgnoreCase('NEW')) {
            sRes = AACC_INPROGRESS;
        } else if (sChangeCode.startsWithIgnoreCase('FIN')) {
            sRes = AACC_FINALIZED;
        }
        else if (sChangeCode.startsWithIgnoreCase('DIS')) {
            sRes = (sChangeCode.indexOf('-CNS-')>0) ? 'denied' : AACC_DISAPPROVED;
        }
        else if (sChangeCode.startsWithIgnoreCase('REC')) {
            sRes = (sChangeCode.indexOf('-CNS-')>0) ? 'under reconsideration' : AACC_RECONSIDERED;
        }
        else if (sChangeCode.startsWithIgnoreCase('NWD')) {
            sRes = AACC_WITHDRAWAL;
        }

        return sRes;
    }
    /**
    //Based on the Change code passed we get the Rec ID
    Indicates if record is A=Added, C=Changed or D=Deleted.
    */
    public static String getRecIdFromChangeCode(String sChangeCode) {

        //Validates the Changes codes for "A=Added" and "D=Deleted", all other Change Codes not mentioned return "C=Changed"

        String sRes = '';

        for (AMS_ChangeCodes__c cc : CUSTOM_CHANGECODES ){

            if(cc.Change_Code__c.equalsIgnoreCase(sChangeCode)){
                sRes = cc.Integration_RecId__c;
                break;
            }

        }

        //Just in case we don't get a result, we set the value for the most common RecId - "C"
        if( sRes == ''){
            sRes = 'C';
        }
/*
        // «A» Section
        if (sChangeCode.equalsIgnoreCase('NEW')) {
            sRes = 'A';
        } else if (sChangeCode.equalsIgnoreCase('FIN')) {
            sRes = 'A';
        } else if (sChangeCode.equalsIgnoreCase('CON')) {
            sRes = 'A';
        } else if (sChangeCode.equalsIgnoreCase('NCA')) {
            sRes = 'A';
        } else if (sChangeCode.equalsIgnoreCase('NFN')) {
            sRes = 'A';
        } else if (sChangeCode.equalsIgnoreCase('NWH')) {
            sRes = 'A';
        } else if (sChangeCode.equalsIgnoreCase('REC')) {
            sRes = 'A';
        } else if (sChangeCode.equalsIgnoreCase('NEP')) {
            sRes = 'A';
        } else if (sChangeCode.equalsIgnoreCase('NAC')) {
            sRes = 'A';
        }
        // «D» Section
        else if (sChangeCode.equalsIgnoreCase('DIS')) {
            sRes = 'D';
        } else if (sChangeCode.equalsIgnoreCase('NWD')) {
            sRes = 'D';
        } else if (sChangeCode.equalsIgnoreCase('TER')) {
            sRes = 'D';
        } else if (sChangeCode.equalsIgnoreCase('CLO')) {
            sRes = 'D';
        }
        // «C» Section
        else {
            sRes = 'C';
        }
*/
        return sRes;
    }
/**
    //Based on the Change code passed we get the Rec ID
    Indicates if record is A=Added, C=Changed or D=Deleted.
    */
    public static String getRecIdFromIntegrationMatriz(String sRecIdA, String sRecIdB) {

        //Validates the Changes codes for "A=Added" and "D=Deleted", all other Change Codes not mentioned return "C=Changed"

        String sRes = '';

        for (AMS_ChangeCodes_Integration__c cc : CUSTOM_CHANGECODES_INTEGRATION ){

            if(cc.RecId_A__c.equalsIgnoreCase(sRecIdA)){
                if(cc.RecId_B__c.equalsIgnoreCase(sRecIdB)){
                    sRes = cc.RecId_Res__c;
                    break;
                }
            }

        }

        //Just in case we don't get a result, we set the value for the most common RecId - "C"
        if( sRes == ''){
            sRes = 'C';
        }

        return sRes;
    }

    public static Boolean isAddressEmpty(Account acc, String addressType) {

        //System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - isAddressEmpty] acc.BillingStreet - ' + acc.BillingStreet);
        //System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - isAddressEmpty] acc.BillingCity - ' + acc.BillingCity);
        //System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - isAddressEmpty] acc.BillingPostalCode - ' + acc.BillingPostalCode);
        //System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - isAddressEmpty] acc.IATA_ISO_Country__c - ' + acc.IATA_ISO_Country__c);
        //System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - isAddressEmpty] acc.Iso_State__c - ' + acc.Iso_State__c);
        //System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - isAddressEmpty] acc.ShippingStreet - ' + acc.ShippingStreet);
        //System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - isAddressEmpty] acc.ShippingCity - ' + acc.ShippingCity);
        //System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - isAddressEmpty] acc.ShippingPostalCode - ' + acc.ShippingPostalCode);

        if(addressType.equalsIgnoreCase('Billing')){
            //R3.1 - removed the state validation
            //return ((acc.BillingStreet == null && acc.BillingCity == null && acc.BillingPostalCode == null) || acc.IATA_ISO_Country__c == null || acc.Iso_State__c == null);
            //return ((acc.BillingStreet == null && acc.BillingCity == null && acc.BillingPostalCode == null) || acc.IATA_ISO_Country__c == null );
            return ((acc.BillingStreet == null && acc.BillingCity == null ) || acc.IATA_ISO_Country__c == null );
        }
        if(addressType.equalsIgnoreCase('Shipping')){
            //return ((acc.ShippingStreet == null && acc.ShippingCity == null && acc.ShippingPostalCode == null) );
            return ((acc.ShippingStreet == null && acc.ShippingCity == null) );
        }

        return false;
    }

    //VALID = TRUE; INVALID = FALSE
    public static Boolean isValidState(String state) {
        if(String.isEmpty(state)){
            return false;
        }
        state = state.toLowerCase().trim();
        if(AMS_Utils.iataIsoStates.get(state) == null){
            return false;
        }
        return true;
    }

    //VALID = TRUE; INVALID = FALSE
    public static Boolean isValidCountry(String country) {
        if(String.isEmpty(country)){
            return false;
        }
        country = country.toLowerCase().trim();
        if(AMS_Utils.iataIsoCountries.get(country) == null){
            return false;
        }
        return true;
    }


    public static List<String> splitAccName(String sText) {

        //String sText = 'LIDA BERLIN TRAVEL SERVICES UG (HAFTUNGSBESCHRANKT) (HAFTUNGSBESCHRANKT)';

        List<String> parts = sText.split(' ');
        List<String> res = new List<String>();

        String s1 = '';
        String s2 = '';
        String s3 = '';
        Boolean b1 = false;
        Boolean b2 = false;
        Boolean b3 = false;

        for (String s : parts) {
            String sAux = '';

            if (s.length() > 32) {
                s = s.mid(0, 32);
            }

            if (!b1) {
                sAux = s1 + s;
                if (sAux.length() > 32) {
                    b1 = True;
                    s1.removeEnd(' ');
                } else {
                    s1 = sAux.length() == 32 ? sAux : sAux + ' ';
                }
            }

            if (b1 && !b2) {
                sAux = s2 + s;
                if (sAux.length() > 32) {
                    b2 = True;
                    s2.removeEnd(' ');
                } else {
                    s2 = sAux.length() == 32 ? sAux : sAux + ' ';
                }
            }

            if (b1 && b2 && !b3) {
                sAux = s3 + s;
                if (sAux.length() > 32) {
                    b3 = True;
                    s3.removeEnd(' ');
                } else {
                    s3 = sAux.length() == 32 ? sAux : sAux + ' ';
                }
            }

        }

        res.add(s1);
        res.add(s2);
        res.add(s3);

        return res;
    }

    public static List<String> splitAccTradeName(String sText) {

        //String sText = 'LIDA BERLIN TRAVEL SERVICES UG (HAFTUNGSBESCHRANKT) (HAFTUNGSBESCHRANKT)';

        List<String> parts = sText.split(' ');
        List<String> res = new List<String>();

        String s1 = '';
        String s2 = '';
        Boolean b1 = false;
        Boolean b2 = false;

        for (String s : parts) {
            String sAux = '';

            if (s.length() > 32) {
                s = s.mid(0, 32);
            }

            if (!b1) {
                sAux = s1 + s;
                if (sAux.length() > 32) {
                    b1 = True;
                    s1.removeEnd(' ');
                } else {
                    s1 = sAux.length() == 32 ? sAux : sAux + ' ';
                }
            }

            if (b1 && !b2) {
                sAux = s2 + s;
                if (sAux.length() > 32) {
                    b2 = True;
                    s2.removeEnd(' ');
                } else {
                    s2 = sAux.length() == 32 ? sAux : sAux + ' ';
                }
            }

        }

        res.add(s1);
        res.add(s2);

        return res;
    }

/* DESCOUTINUED - TO BE REMOVED AFTER TESTING

    public static List<Account> createAAChangeCodes(List<AMS_OSCAR_JSON.ChangeCode> changeCodes, List<AMS_OSCAR__c> oscars, List<Account> oscarAgencies, Boolean isToUpdateAccounts) {

        Map<Account, Boolean> accountsChecker = new Map<Account, Boolean>();

        Integer index = 0;

        Set<Account> accountsToUpdate = new Set<Account>();

        List<Agency_Applied_Change_code__c> aaccToInsert = new List<Agency_Applied_Change_code__c>();

        for (AMS_OSCAR_JSON.ChangeCode cc : changeCodes) {

            Boolean isActive = false;

            if (!accountsChecker.containsKey(oscarAgencies.get(index))) {
                accountsChecker.put(oscarAgencies.get(index), false);
                isActive = true;
            }

            ChangeCodeStruct changeCodeResult = createAAChangeCode(cc, oscars.get(index), oscarAgencies.get(index), isActive);

            aaccToInsert.add(changeCodeResult.changeCode);

            if (changeCodeResult.acct != null && !accountsToUpdate.contains(changeCodeResult.acct))
                accountsToUpdate.add(changeCodeResult.acct);

            index++;

        }

        List<Account> accountsToUpdateList = new List<Account>(accountsToUpdate);

        if (!accountsToUpdate.isEmpty() && (!Trigger.isExecuting || isToUpdateAccounts)) {
            System.debug('The list of Accounts to update is ' + accountsToUpdate.size());
            update accountsToUpdateList;
        }

        if (!aaccToInsert.isEmpty()) {

            System.debug('The list of Change Codes to add is ' + aaccToInsert.size());

            insert aaccToInsert;
        }

        return accountsToUpdateList;

    }

    //Change Code Utils
    private static ChangeCodeStruct createAAChangeCode(AMS_OSCAR_JSON.ChangeCode changeCode, AMS_OSCAR__c oscar, Account oscarAgency, Boolean isActive) {

        Account toReturn = null;

        Id oscarId = null;

        if (oscar != null)
            oscarId = oscar.Id;

        System.debug('Creating a new Agency Applied Change Code for Account ' + oscarAgency.Id + ' with flag active set to ' + isActive);

        String source = UserInfo.getUserType() == 'PowerPartner' ? 'Portal' : 'Internal';

        Agency_Applied_Change_code__c aacNEW = new Agency_Applied_Change_code__c(
            Active__c = isActive
            , Account__c = oscarAgency.Id
            , Change_Code__c = changeCode.name
            , OSCAR__c = oscarId
            , Bulletin_Information__c = changeCode.memoText
            , Reason_Code__c = changeCode.reasonCode
            , Reason_Description__c = changeCode.reasonDesc
            , Source__c = source
        );

        //insert aacNEW;


        //update Agency Status
        String newVal = getIATAReadableStatus(changeCode.status);


        System.debug('Change code status is ' + changeCode.status);
        System.debug('Account status is ' + oscarAgency.Status__c);
        System.debug('New val is ' + newVal);


        if (newVal <> oscarAgency.Status__c && newVal != null) {

            oscarAgency.Status__c = newVal;
            toReturn = oscarAgency;
        }

        if(oscar != null){

            if( aacNEW.Change_Code__c == 'NEW' ){
                oscar.First_Step_Completed__c = true;

                if(!Trigger.isExecuting || Trigger.isAfter) update oscar; //used on the creation of the NEW via webservice
            }

            if( aacNEW.Change_Code__c == 'FIN' && !oscar.Flag_IATACode_Formula__c) oscar.addError('Please, make sure the IATA Code has been generated');
            if( oscar.RecordTypeId == RECTYPE_NEW && (aacNEW.Change_Code__c == 'FIN' || aacNEW.Change_Code__c == 'DIS') && !oscar.First_Step_Completed__c) oscar.addError('Approval/Disapproval can only be made after the NEW change code was created');
            if( oscar.RecordTypeId == RECTYPE_CHANGE && !oscar.First_Step_Completed__c){
                for(String status : AACC_FINALS) if(aacNEW.Bulletin_Information__c.endsWith(status)) oscar.addError('Approval/Disapproval can only be made after the initial change code was created');
            }
            if(aacNEW.Change_Code__c == 'FIN' && new Set<String>{'C','P'}.contains(oscar.Location_Class__c)){
                oscarAgency.Annual_Renewal_Certificates__c = true;
                toReturn = oscarAgency;
            }
        }

        if(aacNew.Change_Code__c == 'CER'){
            oscarAgency.Annual_Renewal_Certificates__c = true;
            oscarAgency.Certificate_Generated_Current_Year__c = true;
            toReturn = oscarAgency;
        }

        if( aacNEW.Change_Code__c == 'FIN' ){

            oscarAgency.Is_AIMS_Account__c = true;
            oscarAgency.Accreditation_Date__c = Date.Today();
            toReturn = oscarAgency;
        }

        if( aacNEW.Change_Code__c == 'CLO' ){

            oscarAgency.Expiry_Date__c = Date.Today();
            toReturn = oscarAgency;
        }

        if( aacNEW.Change_Code__c == 'REI' ){

            oscarAgency.Expiry_Date__c = null;
            toReturn = oscarAgency;
        }

        return new ChangeCodeStruct(aacNEW, toReturn);
    }
    */

 public static String getLocationClassDescr(String endorsmentCode) {

        /*
            C-Cargo
            D-Domestic
            E-External Registrars
            G-General Sales Agent
            I = Imports
            K-CATO
            M-Members & Airlines Sales Offices
            N-NISI
            O-SATO
            P-Passenger
            S-SSI
            R = CassAssociate
            T-TIDS
            Q = Courier
            V-Travel Service Intermediaries-TSI (USA Only)
            X-Handling Agents and Shipping Lines
            J-Joint Vent
         */
        if (endorsmentCode == 'P')
            return 'Passenger';
        else if (endorsmentCode == 'C')
            return 'Cargo';
        else if (endorsmentCode == 'D')
            return 'Domestic';
        else if (endorsmentCode == 'E')
            return 'External Registrars';
        else if (endorsmentCode == 'G')
            return 'General Sales Agents';
        else if (endorsmentCode == 'K')
            return 'CATO';
        else if (endorsmentCode == 'M')
            return 'Members & Airlines Sales Offices';
        else if (endorsmentCode == 'N')
            return 'NISI';
        else if (endorsmentCode == 'O')
            return 'SATO';
        else if (endorsmentCode == 'S')
            return 'SSI';
        else if (endorsmentCode == 'T')
            return 'TIDS';
        else if (endorsmentCode == 'V')
            return 'Travel Service Intermediaries-TSI (USA Only)';
        else if (endorsmentCode == 'X')
            return 'Handling Agents and Shipping Lines';
        else if (endorsmentCode == 'J')
            return 'Joint Vent';
        else if (endorsmentCode == 'I')
            return 'Import';
        else if (endorsmentCode == 'Q')
            return 'Courier';
        else if (endorsmentCode == 'R')
            return 'CassAssociate';

        return '';
    }

    public static String getIATAReadableStatus(String endorsmentCode) {

        if (endorsmentCode == '0')
            return ACC_S0_TERMINATED;
        else if (endorsmentCode == '1')
            return ACC_S1_NOTACCREDITED;
        else if (endorsmentCode == '2')
            return ACC_S2_NEWAPPLICATIONPENDING;
        else if (endorsmentCode == '3')
            return ACC_S3_NOTINOPERATION;
        else if (endorsmentCode == '4')
            return ACC_S4_LISTED;
        else if (endorsmentCode ==  '5')
            return ACC_S5_CASHNOCOMMISSION;
        else if (endorsmentCode == '6')
            return ACC_S6_CASHWITHCOMMISSION;
        else if (endorsmentCode == '7')
            return ACC_S7_UNDERREVIEW;
        else if (endorsmentCode == '8')
            return ACC_S8_CHANGESPROCESSED;
        else if (endorsmentCode == '9')
            return ACC_S9_APPROVED;

        return null;
    }

    public static String getIATANumericStatus(String statusDesc) {

        if (statusDesc == ACC_S0_TERMINATED)
            return '0';
        else if (statusDesc == ACC_S1_NOTACCREDITED)
            return '1';
        else if (statusDesc == ACC_S2_NEWAPPLICATIONPENDING)
            return '2';
        else if (statusDesc == ACC_S3_NOTINOPERATION)
            return '3';
        else if (statusDesc == ACC_S4_LISTED)
            return '4';
        else if (statusDesc == ACC_S5_CASHNOCOMMISSION)
            return '5';
        else if (statusDesc == ACC_S6_CASHWITHCOMMISSION)
            return '6';
        else if (statusDesc == ACC_S7_UNDERREVIEW)
            return '7';
        else if (statusDesc == ACC_S8_CHANGESPROCESSED)
            return '8';
        else if (statusDesc == ACC_S9_APPROVED || statusDesc == 'Active')
            return '9';

        return null;
    }


    public static String overrideEBulletinStatusDescr(String statusDesc) {

        if (statusDesc == ACC_S5_CASHNOCOMMISSION)
            return 'DEFAULT/SUSPENSION';
        else if (statusDesc == ACC_S6_CASHWITHCOMMISSION)
            return 'REVIEW/STDS REMOVAL/NOTICE OF TERMINATION';

        return statusDesc;
    }

    public static String getIATANReadableStatus(String endorsmentCode) {

        if (endorsmentCode == '0') {
            return 'Terminated';
        }
        if (endorsmentCode == '1') {
            return 'On hold';
        }
        if (endorsmentCode == '2') {
            return 'Applicant';
        }
        if (endorsmentCode == '3') {
            return 'Unregisterable STP';
        }
        if (endorsmentCode == '4') {
            return 'Listed';
        }
        if (endorsmentCode ==  '5') {
            return 'ARC registered';
        }
        if (endorsmentCode == '6') {
            return 'Review';
        }
        if (endorsmentCode == '7') {
            return 'Endorsed';
        }

        return null;
    }

    public static String getCNSReadableStatus(String code) {

        String status;
        if (code == '0') status = 'Terminated';
        else if (code == '2') status = 'Pending';
        else if (code == '9') status = 'Active';
        else status = getIATAReadableStatus(code);

        return status;
    }

    //OSCAR UTILS

    public static void syncOSCARwithIFAP(Case previousIFAPCase, Case updatedIFAPCase) {

        syncOSCARwithIFAP(previousIFAPCase, updatedIFAPCase, null, true);
    }

    public static AMS_OSCAR__c syncOSCARwithIFAP(Case previousIFAPCase, Case updatedIFAPCase, AMS_OSCAR__c oscar, Boolean updateOscar) {

        Boolean mustUpdateOSCAR = false;

        if(oscar == null){
            List<AMS_OSCAR__c> oscarlst = [select Financial_Assessment_requested__c, Financial_Assessment_deadline__c, Assessment_Performed_Date__c, Financial_Review_Result__c,
                                        Bank_Guarantee_amount__c, Reason_for_change_of_Financial_result__c, Requested_Bank_Guarantee_amount__c, Bank_Guarantee_Currency__c, Bank_Guarantee_deadline__c
                                        from AMS_OSCAR__c where Id = : updatedIFAPCase.OSCAR__c];
            if(!oscarlst.isEmpty())
                oscar = oscarlst.get(0);
        }

        if (oscar != null ) {

            if (previousIFAPCase.Financial_Assessment_requested__c <> updatedIFAPCase.Financial_Assessment_requested__c &&
                oscar.Financial_Assessment_requested__c <> updatedIFAPCase.Financial_Assessment_requested__c) {
                oscar.Financial_Assessment_requested__c = updatedIFAPCase.Financial_Assessment_requested__c;
                mustUpdateOSCAR = true;
            }

            if (previousIFAPCase.Deadline_Date__c <> updatedIFAPCase.Deadline_Date__c &&
                oscar.Financial_Assessment_deadline__c <> updatedIFAPCase.Deadline_Date__c
                ) {
                oscar.Financial_Assessment_deadline__c = updatedIFAPCase.Deadline_Date__c;
                mustUpdateOSCAR = true;
            }

            if (previousIFAPCase.Assessment_Performed_Date__c <> updatedIFAPCase.Assessment_Performed_Date__c &&
                oscar.Assessment_Performed_Date__c <> updatedIFAPCase.Assessment_Performed_Date__c
                ) {

                oscar.Assessment_Performed_Date__c = updatedIFAPCase.Assessment_Performed_Date__c;
                mustUpdateOSCAR = true;
            }

            if (previousIFAPCase.Financial_Review_Result__c <> updatedIFAPCase.Financial_Review_Result__c &&
                (oscar.Financial_Review_Result__c <> updatedIFAPCase.Financial_Review_Result__c ||
                 oscar.Reason_for_change_of_Financial_result__c <> updatedIFAPCase.Reason_for_change_of_Financial_result__c
                )
                ) {
                oscar.Financial_Review_Result__c = updatedIFAPCase.Financial_Review_Result__c;
                oscar.Reason_for_change_of_Financial_result__c = updatedIFAPCase.Reason_for_change_of_Financial_result__c;
                mustUpdateOSCAR = true;
            }

            if (previousIFAPCase.Financial_Security_Amount__c <> updatedIFAPCase.Financial_Security_Amount__c &&
                (oscar.Bank_Guarantee_amount__c <> updatedIFAPCase.Financial_Security_Amount__c ||
                 oscar.Requested_Bank_Guarantee_amount__c <> updatedIFAPCase.Financial_Security_Amount__c
                )
                ) {
                oscar.Bank_Guarantee_amount__c = updatedIFAPCase.Financial_Security_Amount__c;
                oscar.Requested_Bank_Guarantee_amount__c = updatedIFAPCase.Financial_Security_Amount__c;
                mustUpdateOSCAR = true;
            }

            if (previousIFAPCase.Financial_Security_Currency__c <> updatedIFAPCase.Financial_Security_Currency__c &&
                (oscar.Bank_Guarantee_Currency__c <> updatedIFAPCase.Financial_Security_Currency__c ||
                 oscar.Requested_Bank_Guarantee_Currency__c <> updatedIFAPCase.Financial_Security_Currency__c
                )
                ) {
                oscar.Bank_Guarantee_Currency__c = updatedIFAPCase.Financial_Security_Currency__c;
                oscar.Requested_Bank_Guarantee_Currency__c = updatedIFAPCase.Financial_Security_Currency__c;
                mustUpdateOSCAR = true;
            }

            if (previousIFAPCase.FS_Deadline_Date__c <> updatedIFAPCase.FS_Deadline_Date__c &&
                oscar.Bank_Guarantee_deadline__c <> updatedIFAPCase.FS_Deadline_Date__c) {
                oscar.Bank_Guarantee_deadline__c = updatedIFAPCase.FS_Deadline_Date__c;
                mustUpdateOSCAR = true;
            }

            if (mustUpdateOSCAR && updateOscar){
                update oscar;
                return null;
            }
        }

        if(!mustUpdateOSCAR && !updateOscar)
            return null;

        return oscar;

    }


    public static List<AMS_ChangeCodesHelper.ObjectChangesStruct> copyDataToAccount(List<AMS_OSCAR__c> oscars) {
        return copyDataToAccount(oscars, true);
    }


    //Map data from staging area (AMS Online Accreditation) to account
    public static List<AMS_ChangeCodesHelper.ObjectChangesStruct> copyDataToAccount(List<AMS_OSCAR__c> oscars, Boolean runOwnershipMigration) {

        AMS_AccountTriggerHandler.processMinorChangesValidationFlag = false;

        System.debug('Copying Data from Staging to Account');

        List<Account> accountsToUpdate = new List<Account>();
        List<AMS_Pax_Accreditation_Form__c> onlineAccToCreateAccountRole = new List<AMS_Pax_Accreditation_Form__c>();
        Map<Id, Set<Id>> stagingToAccount = new Map<Id, Set<Id>>();

        //DT: reindented and added 3 fields for iso shipping/billin
        Map<String, String> fieldsMapping = new Map<String, String> {'Name' => 'Account_Name__c'
                                                                    ,'IATACode__c' => 'IATACode__c'
                                                                    ,'Short_Name__c' => 'Short_Name__c'
                                                                    ,'TradeName__c' => 'Trade_Name__c'
                                                                    ,'License_Number__c' => 'ISSP_AMS_License_No__c'
                                                                    ,'VAT_Number__c' => 'ISSP_AMS_VAT_number__c'
                                                                    ,'BillingStreet' => 'Branch_Office_Street_name_number__c'
                                                                    ,'Website' => 'Website__c'
                                                                    ,'BillingPostalCode' => 'Branch_Office_Postal_code__c'
                                                                    //,'BillingState' => 'Billing_State__c'
                                                                    ,'BillingCity' => 'Branch_Office_City__c'
                                                                    ,'IATA_ISO_Country__c' => 'Branch_Office_Country__c'
                                                                    ,'Iso_State__c' => 'IATA_ISO_State__c'
                                                                    //,'ShippingCountry' => 'Shipping_Country__c'
                                                                    ,'ShippingStreet' => 'Shipping_Street__c'
                                                                    ,'ShippingPostalCode' => 'Shipping_Postal_Code__c'
                                                                    //,'ShippingState' => 'Shipping_State__c'
                                                                    ,'Email__c' => 'Branch_Office_Email__c'
                                                                    ,'Phone' => 'Branch_Office_Phone__c'
                                                                    ,'Fax' => 'Branch_Office_FAX__c'
                                                                    ,'ShippingCity' => 'Shipping_City__c'
                                                                    ,'Operation__c' => 'Operation__c'
                                                                    ,'Abbreviated_name__c' => 'Abbreviated_name__c'
                                                                    ,'Abbreviated_address__c' => 'Abbreviated_Address__c'
                                                                    ,'Remittance_frequency__c' => 'Remittance_frequency__c'
                                                                    ,'Solicitation_Flag__c' => 'Solicitation_Flag__c'
                                                                    ,'VAT_Number_2__c' => 'VAT_Number_2__c'
                                                                    ,'CASS_Number__c' => 'CASS_Number__c'
                                                                    ,'Location_Class__c' => 'Location_Class__c'
                                                                    ,'Location_Type__c' => 'Location_Type__c'
                                                                    ,'Mobile__c' => 'Mobile__c'
                                                                    ,'Is_your_firm_handling_Dangerous_Goods__c' => 'Is_your_firm_handling_Dangerous_Goods__c'
                                                                    ,'IATA_ISO_Billing_State__c' => 'IATA_ISO_State__c'
                                                                    ,'IATA_ISO_Shipping_Country__c' => 'Shipping_ISO_Country__c'
                                                                    ,'IATA_ISO_Shipping_State__c' => 'Shipping_ISO_State__c'
                                                                    ,'Link_agent_name__c' => 'Link_agent_name__c'};

        //Need to get Accounts and AMS Online Accreditation related to these oscars
        Set<Id> oscarAccountIds = new Set<Id>();
        Set<Id> oscarOnlineAccredIds = new Set<Id>();
        List<Account> createRHCInfo = new List<Account>();

        for (AMS_OSCAR__c oscar : oscars) {
            oscarAccountIds.add(oscar.Account__c);
            oscarOnlineAccredIds.add(oscar.AMS_Online_Accreditation__c);
        }

        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Name, IATACode__c, Company_Type__c, Short_Name__c, TradeName__c, License_Number__c, VAT_Number__c, GDS__c, Operation__c,
                BillingCountry, BillingStreet, BillingPostalCode, BillingState, BillingCity, IATA_ISO_Country__c, Iso_State__c, ShippingCountry,
                ShippingStreet, ShippingPostalCode, ShippingState, ShippingCity, Email__c, Website, Phone, Fax, In_a_Airport__c, Abbreviated_name__c, Abbreviated_address__c,
                Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c
                ,IATA_ISO_Billing_State__c, IATA_ISO_Shipping_Country__c, IATA_ISO_Shipping_Country__r.Name, IATA_ISO_Shipping_State__c, IATA_ISO_Shipping_State__r.Name, ISO_State__r.Name,
                Link_agent_name__c, ANG_Accreditation_Model__c, IATA_ISO_Country__r.CurrencyIsoCode,
                (SELECT Id FROM RHC_Informations__r), Is_PCI_compliant__c, IATA_ISO_Country__r.AMS_Settlement_System__r.CurrencyIsoCode, IATA_ISO_Country__r.AMS_Settlement_System__r.ANG_RHC_Amount_Equals_FS__c
                FROM Account
                WHERE Id IN :oscarAccountIds]);

        Map<Id, AMS_Pax_Accreditation_Form__c> onlineAccreditations = new Map<Id, AMS_Pax_Accreditation_Form__c>([SELECT Account_Name__c, IATACode__c, ISSP_AMS_Legal_Status__c, Short_Name__c, Trade_Name__c, ISSP_AMS_License_No__c, ISSP_AMS_VAT_number__c,
                ISSP_AMS_GDS_with_signed_contract__c, Operation__c, Branch_Office_Country__r.Name, Branch_Office_Street_name_number__c, Branch_Office_Postal_code__c,
                Billing_State__c, Branch_Office_City__c, ISO_Country__c, IATA_ISO_State__c, Shipping_Country__c, Shipping_Street__c, Shipping_Postal_Code__c,
                Shipping_State__c, Shipping_City__c, Branch_Office_Email__c, Website__c, Branch_Office_Phone__c, Branch_Office_FAX__c, ISSP_AMS_Premises_located_at_airport__c,
                Abbreviated_name__c, Abbreviated_address__c, Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c
                ,Shipping_ISO_Country__c,Shipping_ISO_State__c, Shipping_ISO_Country__r.Name, Shipping_ISO_State__r.Name, IATA_ISO_State__r.Name, Link_agent_name__c, IATA_ISO_State__r.Valid_for_Address__c
                FROM AMS_Pax_Accreditation_Form__c
                WHERE Id IN :oscarOnlineAccredIds]);

        List<Ams_ChangeCodesHelper.ObjectChangesStruct> changes = new List<Ams_ChangeCodesHelper.ObjectChangesStruct>();

        for (AMS_OSCAR__c oscar : oscars) {

            Account acc = accounts.get(oscar.Account__c);

            AMS_Pax_Accreditation_Form__c onlineAcc = onlineAccreditations.get(oscar.AMS_Online_Accreditation__c);

            Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships = AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{acc.Id});

            if (acc != null && onlineAcc != null) {

                List<AMS_ChangeCodesHelper.ObjectChange> accChanges = new List<AMS_ChangeCodesHelper.ObjectChange>();

                for (String accfield : fieldsMapping.keySet()) {
                    String onlineAccField = fieldsMapping.get(accfield);
                    Object newValue = onlineAcc.get(onlineAccField);

                    if( acc.get(accfield) != newValue ){

                        if(AMS_AccountTriggerHandler.minorChangesAccountFields.contains(accfield.toLowerCase())){
                            accChanges.add(new AMS_ChangeCodesHelper.ObjectChange('Account', accfield, String.valueOf(acc.get(accfield)), String.valueOf(newValue)));
                        }

                        acc.put(accfield, newValue);
                    }

                    System.debug(accfield + ':' + newValue);
                }

                if(acc.ShippingState != onlineAcc.Shipping_ISO_State__r.Name){
                    accChanges.add(new AMS_ChangeCodesHelper.ObjectChange('Account', 'ShippingState', acc.ShippingState, onlineAcc.IATA_ISO_State__r.Valid_for_Address__c == true ? onlineAcc.Shipping_ISO_State__r.Name : null));
                    acc.ShippingState = onlineAcc.IATA_ISO_State__r.Valid_for_Address__c == true ? onlineAcc.Shipping_ISO_State__r.Name : null;
                }
                if(acc.ShippingCountry != onlineAcc.Shipping_ISO_Country__r.Name){
                    accChanges.add(new AMS_ChangeCodesHelper.ObjectChange('Account', 'ShippingCountry', acc.ShippingCountry, onlineAcc.Shipping_ISO_Country__r.Name));
                    acc.ShippingCountry = onlineAcc.Shipping_ISO_Country__r.Name;
                }

                acc.In_a_Airport__c = (onlineAcc.ISSP_AMS_Premises_located_at_airport__c == 'Yes') ? true : false;
                acc.Company_Type__c = transformCompanyType(onlineAcc.ISSP_AMS_Legal_Status__c);
                acc.GDS__c = transformGDS(onlineAcc.ISSP_AMS_GDS_with_signed_contract__c);
                acc.BillingCountry = onlineAcc.Branch_Office_Country__r.Name;
                acc.ShippingCountry = onlineAcc.Shipping_ISO_Country__r.Name;
                acc.ShippingState = onlineAcc.IATA_ISO_State__r.Valid_for_Address__c == true ? onlineAcc.Shipping_ISO_State__r.Name : null;
                acc.BillingState = onlineAcc.IATA_ISO_State__r.Valid_for_Address__c == true ? onlineAcc.IATA_ISO_State__r.Name : null;

                acc.ANG_Accreditation_Model__c = decodeAMFromOscarProcess(oscar.Process__c,acc.ANG_Accreditation_Model__c);

                if(oscar.Process__c == NEWHESTANDARD && acc.RHC_Informations__r.isEmpty()) createRHCInfo.add(acc);

                onlineAccToCreateAccountRole.add(onlineAcc);

                if(oscarPCICompliantMigrationProcesses.contains(oscar.Process__c)){
                    acc.Is_PCI_compliant__c = oscar.Is_PCI_compliant__c;
                    if(acc.Is_PCI_compliant__c == 'Corporate Card')
                        acc.ANG_PCI_compliance_expiry_date__c = Date.newInstance(2099, 12, 31);
                }

                accountsToUpdate.add(acc);
                stagingToAccount.put(onlineAcc.Id, new Set<Id>{oscar.Account__c});


                changes.add(new Ams_ChangeCodesHelper.ObjectChangesStruct(accChanges));
            }

        }

        Savepoint sp = Database.setSavepoint();

        try {

            if (!accountsToUpdate.isEmpty())
                update accountsToUpdate;

            if(!stagingToAccount.isEmpty() && runOwnershipMigration)
                AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(stagingToAccount, true);

            if(!createRHCInfo.isEmpty()) ANG_RHCHelper.createRHCInfo(createRHCInfo, false);

            return changes;

        } catch (Exception ex) {
            System.debug('Exception: ' + ex);
            Database.rollback(sp);
            throw ex;
        }

        return null;

    }

    public static string decodeAMFromOscarProcess(String oscarProcess, String oldAccountValue){

        if(oscarProcess == NEWHELITE){

            return ACCREDITATIONMODEL_CASHLESS;

        }else if(oscarProcess == NEWHESTANDARD){

            return ACCREDITATIONMODEL_CASH;

        }

        return oldAccountValue;

    }

    private static boolean isEmptyAccountHierarchyRelationshipsMap(Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships){

        if(accountHierarchyRelationships.isEmpty())
            return true;

        if(accountHierarchyRelationships.values().isEmpty())
            return true;

        for(List<AMS_Agencies_relationhip__c> agency:accountHierarchyRelationships.values()){
            if(!agency.isEmpty())
                return false;
        }

        return true;
    }

    public static Boolean ownershipIsToBeMigrated(String typesOfChange){

        Set<String> fieldsToMigrate = AMS_AgencyChangesConfigHelper.getFieldsToMigrate(typesOfChange);
        if (fieldsToMigrate.contains('ISSP_AMS_Total_Ownership__c'))
            return true;

        return false;

    }

    //Map data from staging area (AMS Online Accreditation) to account
    public static Map<ID,AMS_ChangeCodesHelper.ObjectChangesStruct> copyDataToAccountForAgencyChanges(AMS_OSCAR__c oscar, List<Account> accounts, String typesOfChange, AMS_Pax_Accreditation_Form__c oscarOnlineAccreditation) {

        System.debug('AGENCY CHANGES: Types of Change (' + typesOfChange + ') ');

        Set<String> fieldsToMigrate = AMS_AgencyChangesConfigHelper.getFieldsToMigrate(typesOfChange);

        System.debug('AGENCY CHANGES: fields to migrate (' + fieldsToMigrate + ') for accounts: ' + (new Map<Id, Account>(accounts).keySet()));

        Map<ID,AMS_ChangeCodesHelper.ObjectChangesStruct> accountsToUpdate = new  Map<ID,AMS_ChangeCodesHelper.ObjectChangesStruct>();
        
        Map<String, Schema.SObjectField>  acctFieldsMap= Schema.SObjectType.Account.fields.getMap();
        
        //DT: Reindented and added 3 fields for addresses
        // Account Fields => AMS Pax Accreditation Fields (Staging area)
        Map<String, String> fieldsMapping = new Map<String, String> {'Name' => 'Account_Name__c'
                                                                    ,'IATACode__c' => 'IATACode__c'
                                                                    ,'Short_Name__c' => 'Short_Name__c'
                                                                    ,'TradeName__c' => 'Trade_Name__c'
                                                                    ,'License_Number__c' => 'ISSP_AMS_License_No__c'
                                                                    ,'VAT_Number__c' => 'ISSP_AMS_VAT_number__c'
                                                                    ,'BillingStreet' => 'Branch_Office_Street_name_number__c'
                                                                    ,'Website' => 'Website__c'
                                                                    ,'BillingPostalCode' => 'Branch_Office_Postal_code__c'
                                                                    //,'BillingState' => 'Billing_State__c'
                                                                    ,'BillingCity' => 'Branch_Office_City__c'
                                                                    ,'IATA_ISO_Country__c' => 'Branch_Office_Country__c'
                                                                    ,'Iso_State__c' => 'IATA_ISO_State__c'
                                                                    //,'ShippingCountry' => 'Shipping_Country__c'
                                                                    ,'ShippingStreet' => 'Shipping_Street__c'
                                                                    ,'ShippingPostalCode' => 'Shipping_Postal_Code__c'
                                                                    //,'ShippingState' => 'Shipping_State__c'
                                                                    ,'Email__c' => 'Branch_Office_Email__c'
                                                                    ,'Phone' => 'Branch_Office_Phone__c'
                                                                    ,'Fax' => 'Branch_Office_FAX__c'
                                                                    ,'ShippingCity' => 'Shipping_City__c'
                                                                    ,'Operation__c' => 'Operation__c'
                                                                    ,'Abbreviated_name__c' => 'Abbreviated_name__c'
                                                                    ,'Abbreviated_address__c' => 'Abbreviated_Address__c'
                                                                    ,'Remittance_frequency__c' => 'Remittance_frequency__c'
                                                                    ,'Solicitation_Flag__c' => 'Solicitation_Flag__c'
                                                                    ,'VAT_Number_2__c' => 'VAT_Number_2__c'
                                                                    ,'CASS_Number__c' => 'CASS_Number__c'
                                                                    ,'Location_Class__c' => 'Location_Class__c'
                                                                    ,'Location_Type__c' => 'Location_Type__c'
                                                                    ,'Mobile__c' => 'Mobile__c'
                                                                    ,'Is_your_firm_handling_Dangerous_Goods__c' => 'Is_your_firm_handling_Dangerous_Goods__c'
                                                                    ,'IATA_ISO_Billing_State__c' => 'IATA_ISO_State__c'
                                                                    ,'IATA_ISO_Shipping_Country__c' => 'Shipping_ISO_Country__c'
                                                                    ,'IATA_ISO_Shipping_State__c' => 'Shipping_ISO_State__c'
                                                                    ,'Link_agent_name__c' => 'Link_agent_name__c'};

        /*** AMSU-121 Start ***/
        if(!oscarNewGenProcesses.contains(oscar.Process__c)) {
            fieldsMapping.put('ShippingState', 'Shipping_State__c');
        }
        /*** AMSU-121 End ***/
        
        if (fieldsToMigrate != null && oscarOnlineAccreditation != null) {
            Map<String, Object> accountFieldNewValue = new Map<String,Object>();

            for (String key : fieldsMapping.keySet()) {
                String value = fieldsMapping.get(key);
                if (fieldsToMigrate.contains(value)) {
                
                    accountFieldNewValue.put(key, oscarOnlineAccreditation.get(value));
                    System.debug(key + ':' + oscarOnlineAccreditation.get(value));
                }
            }

            //fields that require transformation
            if (fieldsToMigrate.contains('ISSP_AMS_Premises_located_at_airport__c'))
                accountFieldNewValue.put('In_a_Airport__c', (oscarOnlineAccreditation.ISSP_AMS_Premises_located_at_airport__c == 'Yes') ? true : false);
            if (fieldsToMigrate.contains('ISSP_AMS_Legal_Status__c'))
                accountFieldNewValue.put('Company_Type__c', transformCompanyType(oscarOnlineAccreditation.ISSP_AMS_Legal_Status__c));
            if (fieldsToMigrate.contains('ISSP_AMS_GDS_with_signed_contract__c'))
                accountFieldNewValue.put('GDS__c', transformGDS(oscarOnlineAccreditation.ISSP_AMS_GDS_with_signed_contract__c));
            if (fieldsToMigrate.contains('Branch_Office_Country__c'))
                accountFieldNewValue.put('BillingCountry', oscarOnlineAccreditation.Branch_Office_Country__r.Name);
            if (fieldsToMigrate.contains('Shipping_ISO_Country__c'))
                accountFieldNewValue.put('ShippingCountry', oscarOnlineAccreditation.Shipping_ISO_Country__r.Name);
            //if (fieldsToMigrate.contains('Shipping_ISO_State__c'))/*** AMSU-121 ***/
            //    accountFieldNewValue.put('ShippingState', oscarOnlineAccreditation.IATA_ISO_State__r.Valid_for_Address__c == true ? oscarOnlineAccreditation.Shipping_ISO_State__r.Name : null);
            if (fieldsToMigrate.contains('IATA_ISO_State__c'))
                accountFieldNewValue.put('BillingState', oscarOnlineAccreditation.IATA_ISO_State__r.Valid_for_Address__c == true ? oscarOnlineAccreditation.IATA_ISO_State__r.Name : null);
            //if (fieldsToMigrate.contains('ISSP_AMS_Total_Ownership__c'))
                //AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(new List<AMS_Pax_Accreditation_Form__c>{onlineAcc}, accountsAffected);

            for(Account acc : accounts){

                Account newAcc = new Account(Id = acc.Id);
                List<AMS_ChangeCodesHelper.ObjectChange> objectChangesList = new List <AMS_ChangeCodesHelper.ObjectChange>();

                for(String accFieldApiName: accountFieldNewValue.keySet())
                {
                    
                    Schema.SObjectField field = acctFieldsMap.get(accFieldApiName);
                    Schema.DisplayType fldType = field.getDescribe().getType();
                    
                    system.debug('DDD Field value to migrate to account: ' + accFieldApiName);
                    system.debug('DDD Field Type to migrate to account: ' + fldType);

                    //Add Account Changes to be used when generating the Change Codes History Entities
                    
                    String newValue,oldValue,oldValueLookupID,newValueLookupID;
                    if (String.valueOf(fldType) == 'REFERENCE'){

                        oldValue = String.valueOf(processParentDependecies(accFieldApiName.replace('__c','__r.Name'),acc));
                        newValue = String.valueOf(processParentDependecies(fieldsMapping.get(accFieldApiName).replace('__c','__r.Name'),oscarOnlineAccreditation)); 
                        oldValueLookupID = String.valueOf(acc.get(accFieldApiName));
                        newValueLookupID = String.valueOf(accountFieldNewValue.get(accFieldApiName));
                        
                    }
                    else{
                   
                        oldValue = String.valueOf(acc.get(accFieldApiName));
                        newValue = String.valueOf(accountFieldNewValue.get(accFieldApiName));
                   }
                    
                    system.debug('DDD oldValue:' + oldValue);
                    system.debug('DDD newValue:' + newValue);
                    
                    if (oldValue != newValue)
                        objectChangesList.add(new AMS_ChangeCodesHelper.ObjectChange('Account',accFieldApiName,oldValue,newValue,oldValueLookupID,newValueLookupID));
                        

                    newAcc.put(accFieldApiName, accountFieldNewValue.get(accFieldApiName));
                }

                accountsToUpdate.put(acc.Id,new AMS_ChangeCodesHelper.ObjectChangesStruct(objectChangesList, newAcc));
            }
        }

    return accountsToUpdate;
}
    

/*** AMSU-1 ***/
    /*** AMSU-151 ***/
    public static Map<ID,AMS_ChangeCodesHelper.ObjectChangesStruct> copyDataToAccountForAgencyCorrections(AMS_OSCAR__c oscar, Set<Id> accountsAffected, String typesOfChange, Map<Id, Account> accounts, AMS_Pax_Accreditation_Form__c oscarOnlineAccreditation) {
        System.debug('AGENCY CHANGES: Types of Change (' + typesOfChange + ') ');
        List<String> parseTypeOfChange = typesOfChange.split('-');//AMSU-151 Link Agent Name special case
        typesOfChange = parseTypeOfChange[0];
        Set<String> fieldsToMigrate = AMS_AgencyChangesConfigHelper.getFieldsToMigrate(typesOfChange);

        System.debug('AGENCY CHANGES: fields to migrate (' + fieldsToMigrate + ') for accounts: ' + accountsAffected);


        Map<ID,AMS_ChangeCodesHelper.ObjectChangesStruct> accountsToUpdate = new  Map<ID,AMS_ChangeCodesHelper.ObjectChangesStruct>();
        Map<String, Schema.SObjectField>  acctFieldsMap= Schema.SObjectType.Account.fields.getMap();
        Map<String, String> fieldsMapping = new Map<String, String> {'Name' => 'Account_Name__c'
                                                                    ,'IATACode__c' => 'IATACode__c'
                                                                    ,'Short_Name__c' => 'Short_Name__c'
                                                                    ,'TradeName__c' => 'Trade_Name__c'
                                                                    ,'License_Number__c' => 'ISSP_AMS_License_No__c'
                                                                    ,'VAT_Number__c' => 'ISSP_AMS_VAT_number__c'
                                                                    ,'BillingStreet' => 'Branch_Office_Street_name_number__c'
                                                                    ,'Website' => 'Website__c'
                                                                    ,'BillingPostalCode' => 'Branch_Office_Postal_code__c'
                                                                    ,'BillingCity' => 'Branch_Office_City__c'
                                                                    ,'IATA_ISO_Country__c' => 'Branch_Office_Country__c'
                                                                    ,'Iso_State__c' => 'IATA_ISO_State__c'
                                                                    ,'ShippingStreet' => 'Shipping_Street__c'
                                                                    ,'ShippingPostalCode' => 'Shipping_Postal_Code__c'
                                                                    ,'Email__c' => 'Branch_Office_Email__c'
                                                                    ,'Phone' => 'Branch_Office_Phone__c'
                                                                    ,'Fax' => 'Branch_Office_FAX__c'
                                                                    ,'ShippingCity' => 'Shipping_City__c'
                                                                    ,'Operation__c' => 'Operation__c'
                                                                    ,'Abbreviated_name__c' => 'Abbreviated_name__c'
                                                                    ,'Abbreviated_address__c' => 'Abbreviated_Address__c'
                                                                    ,'Remittance_frequency__c' => 'Remittance_frequency__c'
                                                                    ,'Solicitation_Flag__c' => 'Solicitation_Flag__c'
                                                                    ,'VAT_Number_2__c' => 'VAT_Number_2__c'
                                                                    ,'CASS_Number__c' => 'CASS_Number__c'
                                                                    ,'Location_Class__c' => 'Location_Class__c'
                                                                    ,'Location_Type__c' => 'Location_Type__c'
                                                                    ,'Mobile__c' => 'Mobile__c'
                                                                    ,'Is_your_firm_handling_Dangerous_Goods__c' => 'Is_your_firm_handling_Dangerous_Goods__c'
                                                                    ,'IATA_ISO_Billing_State__c' => 'IATA_ISO_State__c'
                                                                    ,'IATA_ISO_Shipping_Country__c' => 'Shipping_ISO_Country__c'
                                                                    ,'IATA_ISO_Shipping_State__c' => 'Shipping_ISO_State__c'
                                                                ,'Link_agent_name__c' => 'Link_agent_name__c'
                                                                ,'In_a_Airport__c' => 'ISSP_AMS_Premises_located_at_airport__c'
                                                                ,'Company_Type__c' => 'ISSP_AMS_Legal_Status__c'}; //AMSU-151

        if (fieldsToMigrate != null && oscarOnlineAccreditation != null) {
            String fieldsINtheQuery = ''; 

            if(parseTypeOfChange.size() > 1) {//AMSU-151 Link Agent Name special case
                Set<String> setParseTypeOfChange = new Set<String>(parseTypeOfChange);
                System.debug('setParseTypeOfChange: ' + setParseTypeOfChange);  
                if(setParseTypeOfChange.contains('LINKAGENT')){
                    fieldsToMigrate.add('Link_agent_name__c');
                }
                if(setParseTypeOfChange.contains('ADD_VAT')){
                    fieldsToMigrate.add('ISSP_AMS_VAT_number__c');
                }
                if(setParseTypeOfChange.contains('ACCNAME')){
                    fieldsToMigrate.add('Account_Name__c');
                }
                if(setParseTypeOfChange.contains('REMOVE_VAT')){
                    fieldsToMigrate.remove('ISSP_AMS_VAT_number__c');
                }
            }
            System.debug('AGENCY CHANGES: fields to migrate revised list (' + fieldsToMigrate + ') ');  
          
                Map<String, Object> accountFieldNewValue = new Map<String,Object>();

                for (String key : fieldsMapping.keySet()) {
                    String value = fieldsMapping.get(key);
                    if (fieldsToMigrate.contains(value)) {
                        fieldsINtheQuery += ',' + key;
                    }
                }

            Set<Id> accountIds = new Set<Id>();
            accountIds.add(oscar.Account__c); 
            accountIds.addAll(accounts.keySet());
            String query = 'SELECT id,recordTypeID,ParentId,Is_Branch_Abroad__c,IATA_ISO_Country__r.ISO_Code__c, Link_agent_name__r.Name, Reason__c, ';
            if(!fieldsINtheQuery.contains('Location_Type__c')){
                query += 'Location_Type__c, ';                
            }
            query += 'IATA_ISO_Shipping_State__r.Name, ISO_State__r.Name,IATA_ISO_Country__r.Name, IATA_ISO_Billing_State__r.Name,IATA_ISO_Shipping_Country__r.Name' + fieldsINtheQuery + ' FROM Account WHERE  Id IN :accountIds'; 
            List<Account> queryResult = Database.query(query);
            System.debug('queryResult: ' + queryResult);

            Account oscarAcctDB;
            for(Account result : queryResult) {
                if(result.Id == oscar.Account__c) {
                    oscarAcctDB = result;
                }
                accounts.put(result.Id, result);    
            }

            System.debug('oscarAcctDB: ' + oscarAcctDB);

            for(String key : fieldsMapping.keySet()) {
                    String value = fieldsMapping.get(key);
                    if (fieldsToMigrate.contains(value)) {
                    if(key == 'Company_Type__c') {
                        if(oscarAcctDB.get(key) != transformCompanyType(oscarOnlineAccreditation.ISSP_AMS_Legal_Status__c)) {
                            accountFieldNewValue.put(key,transformCompanyType(oscarOnlineAccreditation.ISSP_AMS_Legal_Status__c));
                            System.debug('ADDED ENTRY :' + value + ':' + oscarOnlineAccreditation.get(value));
                        }
                    } else {
                        if(oscarAcctDB.get(key) != oscarOnlineAccreditation.get(value)) {
                            accountFieldNewValue.put(key, oscarOnlineAccreditation.get(value));
                            System.debug('ADDED ENTRY :' + value + ':' + oscarOnlineAccreditation.get(value));
                    	}
                    }
                }
            }

                if (fieldsToMigrate.contains('ISSP_AMS_Premises_located_at_airport__c'))
                    accountFieldNewValue.put('In_a_Airport__c', (oscarOnlineAccreditation.ISSP_AMS_Premises_located_at_airport__c == 'Yes') ? true : false);
                if (fieldsToMigrate.contains('ISSP_AMS_GDS_with_signed_contract__c'))
                    accountFieldNewValue.put('GDS__c', transformGDS(oscarOnlineAccreditation.ISSP_AMS_GDS_with_signed_contract__c));
                if (fieldsToMigrate.contains('Branch_Office_Country__c'))
                    accountFieldNewValue.put('BillingCountry', oscarOnlineAccreditation.Branch_Office_Country__r.Name);
                if (fieldsToMigrate.contains('Shipping_ISO_Country__c'))
                    accountFieldNewValue.put('ShippingCountry', oscarOnlineAccreditation.Shipping_ISO_Country__r.Name);
                if (fieldsToMigrate.contains('Shipping_ISO_State__c'))
                    accountFieldNewValue.put('ShippingState', oscarOnlineAccreditation.IATA_ISO_State__r.Valid_for_Address__c == true ? oscarOnlineAccreditation.Shipping_ISO_State__r.Name : null);
                if (fieldsToMigrate.contains('IATA_ISO_State__c'))
                    accountFieldNewValue.put('BillingState', oscarOnlineAccreditation.IATA_ISO_State__r.Valid_for_Address__c == true ? oscarOnlineAccreditation.IATA_ISO_State__r.Name : null);

            UtilityCS__c specialCountries = UtilityCS__c.getAll().get('AMS_COR_VAT_COUNTRIES');
            Set<String> specialCountriesCodes = new Set<String>();
            if(specialCountries != null && String.isNotBlank(specialCountries.Value__c)) {
                for(String country : specialCountries.Value__c.split(';')) {
                    specialCountriesCodes.add(country.trim());
                }
            }

            Boolean isOscarAccBranchAbroad = oscarAcctDB.Is_Branch_Abroad__c == 'Yes';
            for(Id accId: accountsAffected) {
                    List<AMS_ChangeCodesHelper.ObjectChange> objectChangesList = new List <AMS_ChangeCodesHelper.ObjectChange>();

                    Account acc = accounts.get(accId);

                System.debug('Oscar Acc : ' + isOscarAccBranchAbroad + ' - ' + oscarAcctDB.Id);
                System.debug('Accr Acc : ' + acc.Is_Branch_Abroad__c + ' - ' + acc.Id);

                for(String accFieldApiName: accountFieldNewValue.keySet()) {// AMSU-151    
                    Boolean accIsBranchAbroad = acc.Is_Branch_Abroad__c == 'Yes';
                    if(accFieldApiName.startsWith('VAT_Number') && acc.Id != oscarAcctDB.Id && specialCountriesCodes.contains(acc.IATA_ISO_Country__r.ISO_Code__c)) {
                        System.debug('special country');
                        continue;
                    } else if(accFieldApiName.startsWith('VAT_Number') && isOscarAccBranchAbroad && !accIsBranchAbroad) {
                        System.debug('from branch abroad to other');
                        continue;
                    } else if(accFieldApiName.startsWith('VAT_Number') && isOscarAccBranchAbroad && acc.Id != oscarAcctDB.Id) {
                        System.debug('from branch abroad to other branch abroad');
                        continue;
                    } else if(accFieldApiName.startsWith('VAT_Number') && !isOscarAccBranchAbroad && accIsBranchAbroad) {
                        System.debug('from other to branch abroad');
                        continue;
                    }
                        
                        Schema.SObjectField field = acctFieldsMap.get(accFieldApiName);
                        Schema.DisplayType fldType = field.getDescribe().getType();
                        
                        system.debug('DDD Field value to migrate to account: ' + accFieldApiName);
                        system.debug('DDD Field Type to migrate to account: ' + fldType);

                        //Add Account Changes to be used when generating the Change Codes History Entities
                        
                        String newValue,oldValue,oldValueLookupID,newValueLookupID;
                        if (String.valueOf(fldType) == 'REFERENCE'){

                            oldValue = String.valueOf(processParentDependecies(accFieldApiName.replace('__c','__r.Name'),acc));
                            newValue = String.valueOf(processParentDependecies(fieldsMapping.get(accFieldApiName).replace('__c','__r.Name'),oscarOnlineAccreditation)); 
                            oldValueLookupID = String.valueOf(acc.get(accFieldApiName));
                            newValueLookupID = String.valueOf(accountFieldNewValue.get(accFieldApiName));
                            
                        }
                        else{
                            oldValue = String.valueOf(acc.get(accFieldApiName));
                            newValue = String.valueOf(accountFieldNewValue.get(accFieldApiName));
                       }
                        
                        system.debug('DDD oldValue:' + oldValue);
                        system.debug('DDD newValue:' + newValue);
                        
                        if (oldValue != newValue)
                            objectChangesList.add(new AMS_ChangeCodesHelper.ObjectChange('Account',accFieldApiName,oldValue,newValue,oldValueLookupID,newValueLookupID));
                            

                        acc.put(accFieldApiName, accountFieldNewValue.get(accFieldApiName));
                    }

                if(!objectChangesList.isEmpty()) { //AMSU-151
                    AMS_ChangeCodesHelper.ObjectChangesStruct acctChangesStruct = new AMS_ChangeCodesHelper.ObjectChangesStruct(objectChangesList);

                    accountsToUpdate.put(acc.Id,acctChangesStruct);
                }
            }

        }

    return accountsToUpdate;
    }
                        
//Map data from staging area (AMS Online Accreditation) to account
    public static AMS_Pax_Accreditation_Form__c CopyDataFromAccountToStaging(String typesOfChange, Account account, AMS_Pax_Accreditation_Form__c onlineAccreditation) {

        System.debug('AGENCY CHANGES: Types of Change (' + typesOfChange + ') ');

        Set<String> fieldsToMigrate = AMS_AgencyChangesConfigHelper.getFieldsToMigrate(typesOfChange);

        System.debug('AGENCY CHANGES: fields to migrate (' + fieldsToMigrate + ') for accounts: ' + account);

        Map<String, String> fieldsMapping = new Map<String, String> {'Name' => 'Account_Name__c'
                                                                    ,'IATACode__c' => 'IATACode__c'
                                                                    ,'Short_Name__c' => 'Short_Name__c'
                                                                    ,'TradeName__c' => 'Trade_Name__c'
                                                                    ,'License_Number__c' => 'ISSP_AMS_License_No__c'
                                                                    ,'VAT_Number__c' => 'ISSP_AMS_VAT_number__c'
                                                                    ,'BillingStreet' => 'Branch_Office_Street_name_number__c'
                                                                    ,'Website' => 'Website__c'
                                                                    ,'BillingPostalCode' => 'Branch_Office_Postal_code__c'
                                                                    ,'BillingCity' => 'Branch_Office_City__c'
                                                                    ,'IATA_ISO_Country__c' => 'Branch_Office_Country__c'
                                                                    ,'Iso_State__c' => 'IATA_ISO_State__c'
                                                                    ,'ShippingStreet' => 'Shipping_Street__c'
                                                                    ,'ShippingPostalCode' => 'Shipping_Postal_Code__c'
                                                                    ,'Email__c' => 'Branch_Office_Email__c'
                                                                    ,'Phone' => 'Branch_Office_Phone__c'
                                                                    ,'Fax' => 'Branch_Office_FAX__c'
                                                                    ,'ShippingCity' => 'Shipping_City__c'
                                                                    ,'Operation__c' => 'Operation__c'
                                                                    ,'Abbreviated_name__c' => 'Abbreviated_name__c'
                                                                    ,'Abbreviated_address__c' => 'Abbreviated_Address__c'
                                                                    ,'Remittance_frequency__c' => 'Remittance_frequency__c'
                                                                    ,'Solicitation_Flag__c' => 'Solicitation_Flag__c'
                                                                    ,'VAT_Number_2__c' => 'VAT_Number_2__c'
                                                                    ,'CASS_Number__c' => 'CASS_Number__c'
                                                                    ,'Location_Class__c' => 'Location_Class__c'
                                                                    ,'Location_Type__c' => 'Location_Type__c'
                                                                    ,'Mobile__c' => 'Mobile__c'
                                                                    ,'Is_your_firm_handling_Dangerous_Goods__c' => 'Is_your_firm_handling_Dangerous_Goods__c'
                                                                    ,'IATA_ISO_Billing_State__c' => 'IATA_ISO_State__c'
                                                                    ,'IATA_ISO_Shipping_Country__c' => 'Shipping_ISO_Country__c'
                                                                    ,'IATA_ISO_Shipping_State__c' => 'Shipping_ISO_State__c'};

        if (fieldsToMigrate != null && onlineAccreditation != null) {
                Map<String, Object> onlineAccreditationFieldNewValue = new Map<String,Object>();

                for (String key : fieldsMapping.keySet()) {
                    String value = fieldsMapping.get(key);
                    if (fieldsToMigrate.contains(value)) {

                        onlineAccreditationFieldNewValue.put(value, account.get(key));
                        System.debug('copying stuff from target agency ' + value + ':' + account.get(key));
                    }
                    }

                //fields that require transformation
                if (fieldsToMigrate.contains('ISSP_AMS_Premises_located_at_airport__c'))
                    onlineAccreditationFieldNewValue.put('ISSP_AMS_Premises_located_at_airport__c', (account.In_a_Airport__c == true) ? 'Yes' : 'No');
                if (fieldsToMigrate.contains('ISSP_AMS_Legal_Status__c'))
                    onlineAccreditationFieldNewValue.put('ISSP_AMS_Legal_Status__c', account.Company_Type__c);
                if (fieldsToMigrate.contains('ISSP_AMS_GDS_with_signed_contract__c'))
                    onlineAccreditationFieldNewValue.put('ISSP_AMS_GDS_with_signed_contract__c', account.GDS__c);


                for(String accredFieldApiName: onlineAccreditationFieldNewValue.keySet())
                {

                    Schema.SObjectField field = Schema.SObjectType.AMS_Pax_Accreditation_Form__c.fields.getMap().get(accredFieldApiName);
                    Schema.DisplayType fldType = field.getDescribe().getType();

                    system.debug('Field value to migrate to online accreditation: ' + accredFieldApiName);
                    system.debug('Field Type to migrate to online accreditation: ' + fldType);

                    onlineAccreditation.put(accredFieldApiName, onlineAccreditationFieldNewValue.get(accredFieldApiName));
                }

        }

        system.debug('Online Accreditation fields populated: ' + onlineAccreditation);

        return onlineAccreditation;

}

//Deprecated necessary rework because status no longer changes only after change code generation
//get Inspections from oscar
    /*public static void UpdateInspectionsFromOscar(List<AMS_OSCAR__c> oscars){

        //query the the AMS Inspections to update the Account
        List<AMS_Inspection__c> lsInsToUpdate = new List<AMS_Inspection__c>();

        //Update Account Id on Inspections
        for(AMS_Inspection__c amsIns : [SELECT Id, Account__c,OSCAR__c,OSCAR__r.Account__c, Date_Organisation_Status_attained__c,Last_synchronization__c,Accreditation_Endorsement_Status_code__c FROM AMS_Inspection__c WHERE OSCAR__c IN :oscars])
        {

            amsIns.Account__c = amsIns.OSCAR__r.Account__c;

            amsIns.Date_Organisation_Status_attained__c = (amsIns.Date_Organisation_Status_attained__c == null) ? system.today() : amsIns.Date_Organisation_Status_attained__c;
            amsIns.Accreditation_Endorsement_Status_code__c = '9';
            amsIns.Last_synchronization__c = system.today();

            lsInsToUpdate.add(amsIns);
        }

        try {
            update lsInsToUpdate;
        } catch (DmlException e) {
            system.debug('Exception updating Inspection: ' + e.getMessage());
        }

    }*/

    public static List<AMS_Inspection__c> modifyInspectionStatus(List<AMS_Inspection__c> inspections, String statusToApply){

        List<AMS_Inspection__c> modifiedInspections = new List<AMS_Inspection__c>();

        if(inspections != null)
            for(AMS_Inspection__c insp: inspections)
            {

                if(String.isNotBlank(insp.OSCAR__c) && String.isNotBlank(insp.OSCAR__r.Account__c)){ 
                    insp.Account__c = insp.OSCAR__r.Account__c;
                }
                
                insp.Date_Organisation_Status_attained__c = (insp.Date_Organisation_Status_attained__c == null) ? system.today() : insp.Date_Organisation_Status_attained__c;
                insp.Accreditation_Endorsement_Status_code__c = statusToApply;
                insp.Last_synchronization__c = system.today();

                modifiedInspections.add(insp);
            }

        return modifiedInspections;

    }


/**
    Method to help the transformation between Company Type (Acccount) and Specify Legal Status (AMS Online Accreditation)
    */
public static String transformLegalStatus(String companyType) {

    if (companyType == null)
        return null;

    if (companyType.equalsIgnoreCase('A'))
        return 'Association';
    if (companyType.equalsIgnoreCase('C'))
        return 'Corporation';
    if (companyType.equalsIgnoreCase('E'))
        return 'State Owned Enterprise';
    if (companyType.equalsIgnoreCase('J'))
        return 'Joint Venture';
    if (companyType.equalsIgnoreCase('L'))
        return 'Limited Company';
    if (companyType.equalsIgnoreCase('O'))
        return 'Other';
    if (companyType.equalsIgnoreCase('P'))
        return 'Partnership';
    if (companyType.equalsIgnoreCase('R'))
        return 'Limited Partnership';
    if (companyType.equalsIgnoreCase('S'))
        return 'Sole Proprietorship';
    if (companyType.equalsIgnoreCase('T'))
        return 'Trust Company';
    if (companyType.equalsIgnoreCase('V'))
        return 'Co-operative';

    return companyType;

}

/**
    Method to help the transformation between Specify Legal Status (AMS Online Accreditation) and Company Type (Acccount)
    */
public static String transformCompanyType(String companyType) {

    if (companyType == null)
        return null;

    if (companyType.equalsIgnoreCase('Association'))
        return 'A';
    if (companyType.equalsIgnoreCase('Corporation'))
        return 'C';
    if (companyType.equalsIgnoreCase('State Owned Enterprise'))
        return 'E';
    if (companyType.equalsIgnoreCase('Joint Venture'))
        return 'J';
    if (companyType.equalsIgnoreCase('Limited Company'))
        return 'L';
    if (companyType.equalsIgnoreCase('Other'))
        return 'O';
    if (companyType.equalsIgnoreCase('Partnership'))
        return 'P';
    if (companyType.equalsIgnoreCase('Limited Partnership'))
        return 'R';
    if (companyType.equalsIgnoreCase('Sole Proprietorship'))
        return 'S';
    if (companyType.equalsIgnoreCase('Trust Company'))
        return 'T';
    if (companyType.equalsIgnoreCase('Co-operative'))
        return 'V';

    return null;

}

/**
Method to help the transformation between Specify GDS with signed contract (AMS Online Accreditation) and GDS (Acccount)
*/
public static String transformGDS(String gds) {

    String result = gds;

    if (result == null)
        return null;

    if (result.containsIgnoreCase('Abacus'))
        result = result.replace('Abacus', 'ABAC');
    if (result.containsIgnoreCase('Amadeus'))
        result = result.replace('Amadeus', 'AGTD');
    if (result.containsIgnoreCase('Axess'))
        result = result.replace('Axess', 'AXSS');
    if (result.containsIgnoreCase('Kiu System'))
        result = result.replace('Kiu System', 'CMAS');
    if (result.containsIgnoreCase('Deutsche Reiseburo'))
        result = result.replace('Deutsche Reiseburo', 'DERD');
    if (result.containsIgnoreCase('Farelogix'))
        result = result.replace('Farelogix', 'FLGX');
    if (result.containsIgnoreCase('Travelport (Galileo)'))
        result = result.replace('Travelport (Galileo)', 'GDSL');
    if (result.containsIgnoreCase('Infini'))
        result = result.replace('Infini', 'INFI');
    if (result.containsIgnoreCase('Kotis Travel Info SE'))
        result = result.replace('Kotis Travel Info SE', 'KOTI');
    if (result.containsIgnoreCase('Travelsky'))
        result = result.replace('Travelsky', 'MINS');
    if (result.containsIgnoreCase('Resiber'))
        result = result.replace('Resiber', 'RESI');
    if (result.containsIgnoreCase('Sabre'))
        result = result.replace('Sabre', 'SABR');
    if (result.containsIgnoreCase('SITA'))
        result = result.replace('SITA', 'SITA');
    if (result.containsIgnoreCase('Sirena'))
        result = result.replace('Sirena', 'STRA');
    if (result.containsIgnoreCase('Topas'))
        result = result.replace('Topas', 'TOPAS');
    if (result.containsIgnoreCase('Travelport (Apollo)'))
        result = result.replace('Travelport (Apollo)', 'UALA');
    if (result.containsIgnoreCase('Travelport (Worldspan)'))
        result = result.replace('Travelport (Worldspan)', 'WSPN');

    return result;

}

public static String errorMessageBeautifyer(Exception ex) {
    String errorString = ex.getMessage();
    String searchString = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
    String searchString2 = '##';
    System.debug('EXCEPTION!! ' + ex.getMessage() + '\n ' + ex.getStackTraceString());
    if (ex.getMessage().containsIgnoreCase(searchString)) {
        System.debug(ex.getMessage().indexOfIgnoreCase(searchString));
        Integer startOfErrorMessage = ex.getMessage().indexOfIgnoreCase(searchString) + searchString.length() + 2;
        errorString = ex.getMessage().substring(startOfErrorMessage, ex.getMessage().length());
        errorString = errorString.substringBefore(': [');
    }else if(ex.getMessage().containsIgnoreCase(searchString2)){
        System.debug(ex.getMessage().indexOfIgnoreCase(searchString2));
        Integer startOfErrorMessage = ex.getMessage().indexOfIgnoreCase(searchString2) + searchString2.length();
        errorString = ex.getMessage().substring(startOfErrorMessage, ex.getMessage().length());
        errorString = errorString.substringBefore('##');
    }
    return 'ERROR: ' + errorString.unescapeHtml4();
}

public static RecordType getRecordType(String sObjectType, String developerName) {
    RecordType result = currentCache.get(developerName + '%%' + sObjectType);
    if (result == null) {
        throw new AMS_ApplicationException('Could not find RecordType for ' + sObjectType + ', ' + developerName);
    }
    return result;
}

public static RecordType getRecordType(Id recordTypeId) {
    if (currentCache == null) {
        refreshCache();
    }

    RecordType result = currentCache.get(recordTypeId);
    if (result == null) {
        refreshCache();
        result = currentCache.get(recordTypeId);
    }
    return result;
}

/**
 * Get the recordTypeId for the given sObjectType and developerName
 */
public static Id getId(String sObjectType, String developerName) {
    RecordType rt = getRecordType(sObjectType, developerName);
    if (rt != null) {
        return rt.id;
    }
    return null;
}

/////////////////////////////////////////////////////////////////////////////////////
// Private methods

/**
 * Encrypts a string
 * @param key The key to use to encrypt
 * @param str The String to encrypt
 * @return The encrypted string
 */
private static String EncryptString(String key, String str) {
    Blob dataToEncrypt = Blob.valueOf(str);
    Blob encryptedData = Crypto.encryptWithManagedIV(ENCRYPTION_ALGORYTHM, EncodingUtil.base64Decode(key), dataToEncrypt);
    return EncodingUtil.base64Encode(encryptedData);
}

/**
 * Decrypts a string
 * @param key The key to use to decrypt
 * @param str The encrypted string
 * @return The decrypted string
 */
private static String DecryptString(String key, String str) {
    Blob encryptedData = Encodingutil.base64Decode(str);
    Blob decryptedData = Crypto.decryptWithManagedIV(ENCRYPTION_ALGORYTHM, EncodingUtil.base64Decode(key), encryptedData);
    return decryptedData.toString();
}

private static void refreshCache() {
    Map<String, RecordType> newCache = new Map<String, RecordType>();

    for (RecordType rt : [ select id, name, developerName, SObjectType from RecordType ]) {
        newCache.put(rt.developerName + '%%' + rt.SObjectType, rt);
        newCache.put(rt.Id, rt);
    }
    currentCache = newCache;
}

public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix) {

    System.debug('Input to find Record is ' + recordIdOrPrefix);

    String objectName = '';
    try {
        //Get prefix from record ID
        //This assumes that you have passed at least 3 characters
        String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0, 3);

        //Get schema information
        Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe();

        //Loop through all the sObject types returned by Schema
        for (Schema.SObjectType stype : gd.values()) {
            Schema.DescribeSObjectResult r = stype.getDescribe();
            String prefix = r.getKeyPrefix();

            //Check if the prefix matches with requested prefix
            if (prefix != null && prefix.equals(myIdPrefix)) {
                objectName = r.getName();
                System.debug('Found Object - Name:' + objectName);
                break;
            }
        }
    } catch (Exception e) {
        System.debug(e);

    }
    return objectName;
}

public static Map<String, String> getObjectLabels(String objectApiName) {

    Map<String, String> toReturn = new Map<String, String>();

    Map<String, Schema.SObjectField> fieldMap = getObjectFields(objectApiName);

    for (String fieldName : fieldMap.keySet()) {

        toReturn.put(fieldName.toLowerCase(), fieldMap.get(fieldName).getDescribe().getLabel());
    }

    return toReturn;

}


public static Map<String, Schema.SObjectField> getObjectFields(String objectApiName) {

    Map<String, String> toReturn = new Map<String, String>();

    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();

    Schema.SObjectType leadSchema = schemaMap.get(objectApiName);

    return leadSchema.getDescribe().fields.getMap();

}

//will carry change codes
public class Container {

    public List<AMS_OSCAR_JSON.ChangeCode> changeCodes;
    public List<Account> accts;
    public List<AMS_OSCAR__c> oscars;
    //public AMS_HierarchyHelper.HierarchyStruct relationshipsToManage;

    public Container(List<AMS_OSCAR_JSON.ChangeCode> changeCodes, List<Account> accts, List<AMS_OSCAR__c> oscars/*, AMS_HierarchyHelper.HierarchyStruct relationshipsToManage*/) {

        this.changeCodes = changeCodes;
        this.accts = accts;
        this.oscars = oscars;
        //this.relationshipsToManage = relationshipsToManage;

    }
}

public static boolean isAMSProfile(Id profileId) {
    return AMSPROFILES.contains(profileId);
}

//TD 20180607: "old" method signature to avoid issues with classes
public static String getChangeCodeMemoText(String process,String changeCodeId) {
	return (getChangeCodeMemoText(process, changeCodeId, null));
}

//Get Change Code memo Text (All this configs should be passed for a Custom Setting)
//TD 2018067 - added custom setting field in input
public static String getChangeCodeMemoText(String process,String changeCodeId, AMS_ChangeCodes__c CCConfig) {
	if(changeCodeId.indexOf('-CNS-')>-1){
		//CNS PROCESS. GET BULLETIN MEMO TEXT FROM CHANGE CODE CONFIGURATION
		if(CCConfig==null)	CCConfig = AMS_ChangeCodes__c.getInstance(changeCodeId);
		
		if(CCConfig!=null){
			string sMemoText = (string.isBlank(CCConfig.Bulletin_Memo_Text__c)?'':CCConfig.Bulletin_Memo_Text__c) 
								+ (string.isBlank(CCConfig.Bulletin_Memo_Text2__c)?'':CCConfig.Bulletin_Memo_Text2__c) 
								+ (string.isBlank(CCConfig.Bulletin_Memo_Text3__c)?'':CCConfig.Bulletin_Memo_Text3__c);
			if(string.isNotBlank(sMemoText))
				return sMemoText = sMemoText.toUpperCase();
		}
		return '';
	}else{
		//UNTOUCHED FOR NON CNS PROCESSES
		String memoText = 'New application';

		//Commented as CNS has been moved above
	    //if(changeCodeId == 'FIN-CNS-C') memoText = 'New Endorsment';
	    //if(changeCodeId.endsWithIgnoreCase('CNS-R')) return '';
	
	    if (process == new_HO || process == new_BR_ABROAD){
	        if(changeCodeId != 'NWD') memoText += ' - Head Office';
	    }else if (process == new_BR){
	        memoText += ' - Branch';
	    }else if (process == NEWHELITE || process == NEWHESTANDARD){
	        if(changeCodeId != 'NEW' && changeCodeId != 'NWD') memoText += ' - Head Entity';
	    }else if (process == NEWAE){
	        if(changeCodeId != 'NEW' && changeCodeId != 'NWD') memoText += ' - Associate Entity';
	    }else if (process == new_TIDS){
	        memoText += ' - TIDS';
	    }else if (process == new_SA){
	        memoText += ' - SA';
	    }else if (process == new_GSSA){
	        memoText += ' - GSSA';
	    }else if (process == new_GSA_BSP || process == new_GSA){
	        memoText += ' - GSA';
	    }else if (process == new_AHA_BSP || process == new_AHA){
	        memoText += ' - AHA';
	    }
 
	    return memoText + ' ' + getStatusDescFromChangeCode(changeCodeId);
	}
}


// Converts a base64 string into a list of integers representing the encoded bytes
public static List<Integer> B64ToBytes (String sIn) {
    Map<Integer,Integer> base64 = new Map<Integer,Integer>{65=>0,66=>1,67=>2,68=>3,69=>4,70=>5,71=>6,72=>7,73=>8,74=>9,75=>10,76=>11,77=>12,78=>13,79=>14,80=>15,81=>16,82=>17,83=>18,84=>19,85=>20,86=>21,87=>22,88=>23,89=>24,90=>25
                                                           ,97=>26,98=>27,99=>28,100=>29,101=>30,102=>31,103=>32,104=>33,105=>34,106=>35,107=>36,108=>37,109=>38,110=>39,111=>40,112=>41,113=>42,114=>43,115=>44,116=>45,117=>46,118=>47,119=>48,120=>49,121=>50,122=>51
                                                           ,48=>52,49=>53,50=>54,51=>55,52=>56,53=>57,54=>58,55=>59,56=>60,57=>61,43=>62,47=>63};

    List<Integer> lstOut = new List<Integer>();
    if ( sIn == null || sIn == '' ) return lstOut;

    sIn += '='.repeat( 4 - Math.mod( sIn.length(), 4) );

    for ( Integer idx=0; idx < sIn.length(); idx += 4 ) {
        if ( base64.get(sIn.charAt(idx+1)) != null ) lstOut.add( (base64.get(sIn.charAt(idx)) << 2) | (base64.get(sIn.charAt(idx+1)) >>> 4) );
        if ( base64.get(sIn.charAt(idx+2)) != null ) lstOut.add( ((base64.get(sIn.charAt(idx+1)) & 15)<<4) | (base64.get(sIn.charAt(idx+2)) >>> 2) );
        if ( base64.get(sIn.charAt(idx+3)) != null ) lstOut.add( ((base64.get(sIn.charAt(idx+2)) & 3)<<6) | base64.get(sIn.charAt(idx+3)) );
    }

    //System.Debug('B64ToBytes: [' + sIn + '] = ' + lstOut);
    return lstOut;
}//B64ToBytes
public static List<Integer> BlobToBytes (Blob input) {
    return B64ToBytes( EncodingUtil.base64Encode(input) );
}//BlobToBytes

// Converts a base64 string into a list of integers indicating at which position the bits are on
public static List<Integer> cnvBits (String b64Str) {
    List<Integer> lstOut = new List<Integer>();
    if ( b64Str == null || b64Str == '' ) return lstOut;

    List<Integer> lstBytes = B64ToBytes(b64Str);

    Integer i, b, v;
    for ( i = 0; i < lstBytes.size(); i++ ) {
        v = lstBytes[i];
        //System.debug ( 'i['+i+'] v['+v+']' );
        for ( b = 1; b <= 8; b++ ) {
            //System.debug ( 'i['+i+'] b['+b+'] v['+v+'] = ['+(v & 128)+']' );
            if ( ( v & 128 ) == 128 ) lstOut.add( (i*8) + b );
            v <<= 1;
        }
    }

    //System.Debug('cnvBits: [' + b64Str + '] = ' + lstOut);
    return lstOut;
}//cnvBits

public class TPicklistEntry{
    public string active {get;set;}
    public string defaultValue {get;set;}
    public string label {get;set;}
    public string value {get;set;}
    public string validFor {get;set;}
    public TPicklistEntry(){
    }
}//TPicklistEntry


/**
Process Dependent Picklists (Apex workaround)
*/
public static Map<String,List<String>> GetDependentOptions(String pObjName, String pControllingFieldName, String pDependentFieldName) {
    Map<String,List<String>> mapResults = new Map<String,List<String>>();

    //verify/get object schema
    Schema.SObjectType pType = Schema.getGlobalDescribe().get(pObjName);
    if ( pType == null ) return mapResults;
    Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();

    //verify field names
    if (!objFieldMap.containsKey(pControllingFieldName) || !objFieldMap.containsKey(pDependentFieldName)) return mapResults;

    //get the control & dependent values
    List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();
    List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();

    //clear heap
    objFieldMap = null;

    //initialize results mapping
    for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){
        mapResults.put( ctrl_ple[pControllingIndex].getLabel(), new List<String>());
    }
    //cater for null and empty
    mapResults.put('', new List<String>());
    mapResults.put(null, new List<String>());

    //serialize dep entries
    List<TPicklistEntry> objDS_Entries = new List<TPicklistEntry>();
    objDS_Entries = (List<TPicklistEntry>)JSON.deserialize(JSON.serialize(dep_ple), List<TPicklistEntry>.class);

    List<Integer> validIndexes;
    for (TPicklistEntry objDepPLE : objDS_Entries){

        validIndexes = cnvBits(objDepPLE.validFor);
        //System.Debug('cnvBits: [' + objDepPLE.label + '] = ' + validIndexes);

        for (Integer validIndex : validIndexes){
            mapResults.get( ctrl_ple[validIndex-1].getLabel() ).add( objDepPLE.label );
        }
    }

    //clear heap
    objDS_Entries = null;

    return mapResults;
}

//used to fill the Type_of_Customer__c field on the Oscar Comunication Case
public static String fetchTypeOfCustomer (String locationType , String category) {

    if(locationType == null)
        return null;

    if(locationType == 'SA')
        return 'IATA Travel Agent';

    if(category == null)
        return null;

    return categoryCustomerMap.get(category);

}

    /*
    public static final Date knownSunday = date.newInstance(2012, 7, 1);

    private static Map<String, Set<Integer>> weekendDaysPerBusinessHours{
        get{
            if(weekendDaysPerBusinessHours == null) weekendDaysPerBusinessHours = new Map<String, Set<Integer>>();
            return weekendDaysPerBusinessHours;
        }
        set;
    }

    private static Set<Integer> addBusinessHours(String businessHours){
        String findBusinessHours = (businessHours == null ? 'Default' : businessHours);

        if(!weekendDaysPerBusinessHours.containsKey(findBusinessHours)){
            List<BusinessHours> hs = [SELECT Id, Name, isDefault, isActive, SundayStartTime, MondayStartTime, TuesdayStartTime, WednesdayStartTime, ThursdayStartTime, FridayStartTime, SaturdayStartTime FROM BusinessHours WHERE isActive = true AND (Name = :findBusinessHours OR isDefault = true)];

            Set<Integer> weekendDays = new Set<Integer>();
            if(hs.isEmpty()){
                System.debug(loggingLevel.ERROR, '____ [cls AMS_Utils - addBusinessHours] ************ no businessHours found -- using Sunday and Saturday ');
                weekendDays.add(0);
                weekendDays.add(6);
                weekendDaysPerBusinessHours.put(findBusinessHours, weekendDays);
            }else{
                for(BusinessHours h : hs){
                    weekendDays = new Set<Integer>();
                    if(h.SundayStartTime == null) weekendDays.add(0);
                    if(h.MondayStartTime == null) weekendDays.add(1);
                    if(h.TuesdayStartTime == null) weekendDays.add(2);
                    if(h.WednesdayStartTime == null) weekendDays.add(3);
                    if(h.ThursdayStartTime == null) weekendDays.add(4);
                    if(h.FridayStartTime == null) weekendDays.add(5);
                    if(h.SaturdayStartTime == null) weekendDays.add(6);

                    if(h.Name == findBusinessHours) weekendDaysPerBusinessHours.put(h.Name, weekendDays);
                    else if(h.isDefault) weekendDaysPerBusinessHours.put('Default', weekendDays);
                }
                //if we went through all business hours and didn't find the desired one, copy the default
                if(!weekendDaysPerBusinessHours.containsKey(findBusinessHours)){
                System.debug(loggingLevel.ERROR, '____ [cls AMS_Utils - addBusinessHours] ************ no businessHours found for region -- copying default one ');
                    weekendDaysPerBusinessHours.put(findBusinessHours, weekendDaysPerBusinessHours.get('Default'));
                }
            }
        }

        return weekendDaysPerBusinessHours.get(findBusinessHours);
    }


    public static Boolean IsWeekendDay(Date dateParam, String businessHours){
        return IsWeekendDay(DateTime.newInstance(dateParam, Time.newInstance(0, 0, 0, 0)), businessHours);
    }

    public static Boolean IsWeekendDay(Datetime dateParam, String businessHours){
       //Integer dayOfWeek  = Integer.valueOf(dateParam.format('u'));
       //Integer dayOfWeek = dateParam.date().toStartOfWeek().daysBetween(dateParam.date());
       Integer dayOfWeek = Math.mod(knownSunday.daysBetween(dateParam.date()), 7);

       System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - AddBusinessDays] dateParam - ' + dateParam);
       System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - IsWeekendDay] dayOfWeek - ' + dayOfWeek);

       Set<Integer> weekendDays = new Set<Integer>();
       if(weekendDaysPerBusinessHours.containsKey(businessHours)) weekendDays = weekendDaysPerBusinessHours.get(businessHours);
       else weekendDays = addBusinessHours(businessHours);

       System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - IsWeekendDay] weekendDays - ' + weekendDays);

       return weekendDays.contains(dayOfWeek);
    }

    public static Date AddBusinessDays(Date d, Integer businessDaysToAdd, String businessHours){
        return AddBusinessDays(Datetime.newInstance(d, Time.newInstance(0, 0, 0, 0)), businessDaysToAdd, businessHours).date();
    }

    public static Datetime AddBusinessDays(Datetime d, Integer businessDaysToAdd, String businessHours){
        System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - AddBusinessDays] d - ' + d);
        System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - AddBusinessDays] businessHours - ' + businessHours);

        Datetime finalDate = d;

        //Add or decrease in businessDaysToAdd days
        Integer direction = businessDaysToAdd < 0 ? -1 : 1;

        while(businessDaysToAdd != 0){
            finalDate = finalDate.AddDays(direction);
            if (!isWeekendDay(finalDate, businessHours)) businessDaysToAdd -= direction;
        }

        System.debug(loggingLevel.Debug, '____ [cls AMS_Utils - AddBusinessDays] finalDate - ' + finalDate);
        return finalDate;
    }
    */
    public static Date lastDayOfMonth(Date dateField) {
        return dateField.addMonths(1).toStartOfMonth().addDays(-1);
    }


    /**
        Process Parent Objects fields (up to 5 Parents?)
    */
    public static Object processParentDependecies(String field , sObject sObj)
    {

            if(field.contains('.'))
            {
                //Get the Object directly related to the field
                wrapperData wDObj = new wrapperData(sObj,field);

                return (wDObj.sObj == null || wDObj.sObj.get(wDObj.fieldName) == null ) ? '' :wDObj.sObj.get(wDObj.fieldName);
            }

            else
                return (sObj.get(field) == null) ? '' : sObj.get(field);
    }

    /**
    Will trigger the integration with EasyPay and generate a change code
    **/
    public static void startIntegration(List<Account> newAccs, Map<Id,Account> oldMap){

        System.debug('startIntegration initiated.');
        // get the configurations for the change code
        Map<Account,AMS_ChangeCodes__c> mapAccCodeConf = AMS_ChangeCodesHelper.fetchChangeCodeConfiguration(newAccs, oldMap);

        //only run if there are codes to be created
        if(!mapAccCodeConf.keySet().isEmpty()){

        //first insert change codes
            Map<Account, Agency_applied_change_code__c> accChangeCodeMap = new Map<Account, Agency_applied_change_code__c>();
            for(Account acc :mapAccCodeConf.keySet()){
                accChangeCodeMap.put(acc,AMS_ChangeCodesHelper.generateIntegrationChangeCode(acc, mapAccCodeConf.get(acc)));
        }

            if(!accChangeCodeMap.values().isEmpty()){
                insert accChangeCodeMap.values();
        }

            //do call only after the change codes are succesfully inserted - commented since this is now handled via Process Builder.
            /* for(Account acc :accChangeCodeMap.keySet()){
                if(!Test.isRunningTest()){
                    ANG_IEP_CalloutHelper.invokeCustomImpl(accChangeCodeMap.get(acc).change_code__c,acc);
                }
           } */
        }
    }



    /**
     Wrapper Object for Mapping the Entity for Field
     Example : change_code__r.Account__r.name

    */
    private class wrapperData {

        private sObject sObj{get;set;}
        private String fieldName{get;set;}
    /**
         Get Object for the Field  (up to 5 Parents?)
    */
        private wrapperData(SObject sObjParent, String field){

            List <String> strList = field.split('\\.');
            integer lastPos = strList.size() -1;

            sObject sObj = sObjParent;

            for(integer i = 0 ; i < lastPos ; i++) //avoid last element
            {
                sObj = sObj.getSObject(strList.get(i));
            }

            this.sObj   = sObj;
            this.fieldName = strList.get(lastPos);

        }

    }
    public static Integer findGapInRange(Integer minRange, Integer maxRange, List<Integer> orderedSlotsOccupied){
        //invalid range
        if(maxRange-minRange < 0)
            return -1;

        Integer candidate = minRange;

        for(Integer occupiedSlot : orderedSlotsOccupied){
            if(occupiedSlot > candidate){
                System.debug('Candidate found : ' + candidate);
                return candidate;
            }
            else if(occupiedSlot == candidate){
                candidate++;
                if(candidate > maxRange){
                    return -1;
                }
            }
        }

        return candidate;
    }

    public static String CASE_REF_FORMAT = 'ref:{0}.{1}:ref';

    @testVisible
    private static String shortenOrgId(String id) {
         String part = id.substring(0,15);
         Pattern p = Pattern.compile('^([A-Za-z0-9]{5})([A-Za-z0-9]*)$');
         Matcher m = p.matcher(part);

         if (m.matches()) {
              return '_' + m.group(1) + m.group(2).replace('0', '');
         }

         return '';
    }

    @testVisible
    private static String shortenCaseId(String id) {
         String part = id.substring(0,15);
         Pattern p = Pattern.compile('^([A-Za-z0-9]{5})([A-Za-z0-9]*)([A-Za-z0-9]{5})$');
         Matcher m = p.matcher(part);

         if (m.matches()) {
              return '_' + m.group(1) + m.group(2).replace('0', '') + m.group(3);
         }

         return '';
    }

    public static String caseRefId(String orgId, String caseId) {
         if (orgId == null || caseId == null) {
              return '';
         }

         String shortenedOrgId = shortenOrgId(orgId);
         String shortenedCaseId = shortenCaseId(caseId);

         return String.format(
              CASE_REF_FORMAT,
              new List<String>{
                   shortenedOrgId,
                   shortenedCaseId
              }
         );
    }


    public static boolean isProcessUsingAppointments(AMS_OSCAR__c oscar){
        Set<String> oscarProcessesWithAppointments = new Set <String>{new_GSA,new_GSA_BSP,new_AHA,new_AHA_BSP,new_GSSA,new_MSO, VOLRELINQUISH_CA};
        Set<String> oscarCNSProcessesWithAppointments = new Set <String>{new_HO,new_BR,new_BR_ABROAD};

        return oscarProcessesWithAppointments.contains(oscar.Process__c) || (oscarCNSProcessesWithAppointments.contains(oscar.Process__c) && oscar.CNS_Process__c);
    }

    //FM 22-05-2017 - AMSU-1 - split reason comming form account in order to be able to populate the Applied change code "reason code" and "reason description"
    //Returns: List<String> with 2 entries:
    // 1st position : Reason code, if exists... othewise is empty
    // 2nd position : Reason Description
    // also could be null if the value passed is null or empty
    public static List<String> splitAccReason(String sReason){

        List<String> lRes = new List<String>();

        String reason_Code = '';
        String reason_Description = '';

        //check parameter for null or empty value
        if(sReason == null || sReason.equalsIgnoreCase('')){
            return null;
        }else
        //Check for char '-' in order to see if we can split by code and description
        if(sReason.indexOf('-') >= 0 && sReason.indexOf('-') <= 4){

            reason_Code = sReason.substringBefore('-');
            reason_Description = sReason.substringAfter('-');

            //Check if 1st part of the split is numeric in order to get the code
            if(reason_Code.isNumeric()){
                lRes.add(reason_Code);
                lRes.add(reason_Description);
            }else{
                lRes.add('');
                lRes.add(sReason);
            }

        }else{
            //no splitting was possible, so we only fill the description
            lRes.add('');
            lRes.add(sReason);
        }

        return lRes;
    }
	
    //AMSU-112
    public static String replaceTabCharcter(String str) {
        return String.isBlank(str) ? str : str.replaceAll('\t', ' ');
    }

    //20-06-2017 - Change AMSU-93 - special chars replacement
    public static String cleanSpecialChars(String s){

        String sRes = '';

        try{

            //Apply try catch{} return same string in case of error

            if(s == null){
                 return '';
            }

             if(s != null || !s.equalsIgnoreCase('')){

                Map<String, String> mSpecialChars = JsonSpecialChars;

                //String regex = '[^a-zA-Z0-9]';
                //String regex = '[a-zA-Z\\d\\!@#\\$%&,;\'"\\(\\-º\\){}?:+ª\\*]';
                //String regex = '[^a-zA-Z\\d\\!@#\\$%&;\'"\\-{}()\\[\\]?:_. ,+\\*\\\\/]';
                String regex = AMS_SAP_Settings__c.getOrgDefaults().RegEx_Special_Chars__c;

                String specialCharsToEscape = AMS_SAP_Settings__c.getOrgDefaults().Special_Chars_to_Escape_List__c;

                //System.debug('specialCharsToEscape: ' + specialCharsToEscape);

                sRes = s;

                Matcher m = Pattern.compile(regex).matcher(s);

                //System.debug('m: ' + m);
                //System.debug('m.groupCount(): ' + m.groupCount() );

                //Pattern p = Pattern.compile('regex');
                //Matcher mo = p.matcher('string');
                while (m.find()) {

                    //System.debug('m.group: ' + m.group());
                    if(mSpecialChars.containsKey( m.group() )) {
                        //System.debug('replace by value: ' + m.group() + ' by ' + mSpecialChars.get(m.group()) );
                        //System.debug('contains by value: ' + m.group() + ' by ' + specialCharsToEscape.contains(m.group()) );
                        //if(m.group() == '|'){
                        if(specialCharsToEscape.contains(m.group())){
                            sRes = sRes.replaceAll('\\'+m.group(), mSpecialChars.get(m.group()));
                        }else{
                            sRes = sRes.replaceAll(m.group(), mSpecialChars.get(m.group()));
                        }
                    }else{
                        //System.debug('replace by space: ' + m.group() + ' by ' + mSpecialChars.get('SPACE') );
                        //sRes = sRes.replaceAll(m.group(), '_');
                        sRes = sRes.replaceAll(m.group(), mSpecialChars.get('SPACE'));
                        //System.debug('sRes1: ' + sRes);
                    }

                }
            }
            System.debug('sRes: ' + sRes);

        }catch(Exception e){
            System.debug('Exception occurred: ' + e);
            sRes = s;
        }

        return sRes;

    }


    public static Map<String, String> loadJsonSpecialCharsFile(){
        /*
         *  LOAD JSON TO MAP
         */
        StaticResource jsonFile = [select Id , Name , Body from StaticResource where Name = 'AMS_SPECIAL_CHARS_MAP'];

        String JSONContent = EncodingUtil.urlDecode(jsonFile.Body.toString(), 'UTF-8');

        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(JSONContent);

        Map<String, String> mRes = new Map<String, String>();
        //System.debug('m: ' + m);

        for (String key : m.keySet()) {
            String value = (String)m.get(key);
            //System.debug('key: '+ key + ' || value: ' + value);
            mRes.put(key, (String)m.get(key));
        }
        return mRes;
        //return null;
    }


    public class Utility_RowIterator implements Iterator<String>, Iterable<String>
    {
       private String m_Data;
       private Integer m_index = 0;
       private String m_rowDelimiter = '\n';

       public Utility_RowIterator(String fileData)
       {
          m_Data = fileData;
       }
       public Utility_RowIterator(String fileData, String rowDelimiter)
       {
          m_Data = fileData;
          m_rowDelimiter = rowDelimiter;
       }

       public Boolean hasNext()
       {
          return m_index < m_Data.length() ? true : false;
       }
       public String next()
       {
          Integer key = m_Data.indexOf(m_rowDelimiter, m_index);

          if (key == -1)
            key = m_Data.length();

          String row = m_Data.subString(m_index, key);
          m_index = key + 1;
          return row;
       }
       public Iterator<String> Iterator()
       {
          return this;
       }
    }

    // compares two values in diff rates
    // if firstValue < secondValue , returns 1
    // if firstValue = secondValue , returns 0
    // if secondvalue < firstValuue , returns 2
    // if there is a rate problem, return -1
    // if there is a amount problem, return -2
    /*NEWGEN-2809
    public static Integer compareRates(String firstCurrencyISOCode, Decimal firstValue,String secondCurrencyISOCode, Decimal secondValue ){

        if(firstValue == null || secondValue == null){
            System.debug('Returning -2');
            return -2;
        }

        Set<String> currencies = new Set<String>{firstCurrencyISOCode, secondCurrencyISOCode};

        List<CurrencyType> types = [SELECT Id, ConversionRate, DecimalPlaces, IsoCode FROM  CurrencyType where IsoCode in :currencies and IsActive = true];

        if(types.size() != currencies.size()){
            System.debug('Returning -1');
            return -1;
        }

        Map<String,Double> rates = new Map<String,Double>();

        rates.put(types.get(0).IsoCode, types.get(0).ConversionRate);

        if(types.size() > 1)
            rates.put(types.get(1).IsoCode, types.get(1).ConversionRate);

        if(firstValue / rates.get(firstCurrencyISOCode) < secondvalue / rates.get(secondCurrencyISOCode)){
            System.debug('Returning 1');
            return 1;
        }

        if(firstValue / rates.get(firstCurrencyISOCode) > secondvalue / rates.get(secondCurrencyISOCode)){
            System.debug('Returning 2');
            return 2;
        }

        System.debug('Returning 0');
        return 0;

    }*/

    public static Contact getIEPContact(String conId) {
        return [SELECT User_Portal_Status__c,
                       Authorized_Signatory__c,
                       Account.Location_Type__c,
                       Account.Top_Parent__r.Location_Type__c,
                       Account.ANG_IEP_Status_FF__c,
                       Account.Is_Branch_Abroad__c,
                       Account.Status__c
                  FROM Contact WHERE Id = :conId limit 1];
    }

    /**
    Method to help the transformation of accrediation types to display on ebulletin
    */
    public static String transformAccreditationType(String accredType) {

        String result = accredType;

        if (result == null)
            return null;

        if (result.containsIgnoreCase('Cashless'))
            result = result.replace('Cashless', 'GoLite');
        if (result.containsIgnoreCase('Cash'))
            result = result.replace('Cash', 'GoStandard');
        if (result.containsIgnoreCase('Multicountry'))
            result = result.replace('Multicountry', 'GoGlobal');

        return result;

    }

    public static Map<String, Schema.SObjectField> getOSCARFieldMap() {

        return Schema.getGlobalDescribe().get('AMS_OSCAR__c').getDescribe().fields.getMap();

    }

    public static List<String> getOSCARStepsApiName() {

        List<String> oscarSteps = new List<String>();

        for (String fieldApiName : getOSCARFieldMap().keySet()) {
            if (fieldApiName.startsWithIgnoreCase('STEP'))
                oscarSteps.add(fieldApiName);

        }

        return oscarSteps;
    }

    public static Map<String, String> officialAccreditationTypeMap = new Map<String, String> {
        'Legacy' => 'Legacy',
        'Cashless' =>   'GoLite',
        'Cash' =>   'GoStandard',
        'Multicountry' => 'GoGlobal'
    };

    public static String getCustomLabel(String labelName) {
        if(labelName != null && labelName != '') {
            Component.Apex.OutputText output = new Component.Apex.OutputText();
            output.expressions.value = '{!$Label.' + labelName + '}';
            return string.valueOf(output.value);
        } else {
            return labelName;
        }
    }

    public static Date getBiggestDate(Date date1, Date date2) {
        if(date1 != null && date2 != null) return (date1 > date2) ? date1 : date2;
        if(date1 != null && date2 == null) return date1;
        if(date1 == null && date2 != null) return date2;
        return null;
    }

    public static String notNull(String value) {
        if (value == null) {
            return '';
        }
        return value;
    }

    public static Id getRegionalQueue(Case newCase) {
        //Available queue names
        Id qId;

        Set<String> queueNames = new Set<String> {'AgencyManagementAP', 'AgencyManagementAfricaME', 'AgencyManagementAmericas', 'AgencyManagementChinaNAsia', 'CasesACCEuropeOffOnshore'};
        Map<String, QueueSobject> mapRegionalQueue = new Map<String, QueueSobject>();
        //Build map queue.name -> queue
        for (QueueSobject queue : [Select Queue.Id, Queue.DeveloperName From QueueSobject Where Queue.DeveloperName in: queueNames]) {
            mapRegionalQueue.put(queue.Queue.DeveloperName, queue);
        }

        //Assigns queue according to region
        if (newCase.Region__c == 'Africa & Middle East') {
            if (mapRegionalQueue.get('AgencyManagementAfricaME') != null) {
                qId = mapRegionalQueue.get('AgencyManagementAfricaME').Queue.Id;
            }

        } else if (newCase.Region__c == 'Americas') {
            if (mapRegionalQueue.get('AgencyManagementAmericas') != null) {
                qId = mapRegionalQueue.get('AgencyManagementAmericas').Queue.Id;
            }

        } else if (newCase.Region__c == 'Asia & Pacific') {
            if (mapRegionalQueue.get('AgencyManagementAP') != null) {
                qId = mapRegionalQueue.get('AgencyManagementAP').Queue.Id;
            }
        } else if (newCase.Region__c == 'China & North Asia') {
            if (mapRegionalQueue.get('AgencyManagementChinaNAsia') != null) {
                qId = mapRegionalQueue.get('AgencyManagementChinaNAsia').Queue.Id;
            }
        } else if (newCase.Region__c == 'Europe') {
            if (mapRegionalQueue.get('CasesACCEuropeOffOnshore') != null) {
                qId = mapRegionalQueue.get('CasesACCEuropeOffOnshore').Queue.Id;
            }
        }
        System.DEBUG('Case region: ' + newCase.Region__c);
        System.DEBUG('AM Queue returned: ' + qId);
        return qId;
    }

    public static ANG_ISSP_AfpWrapper getANG_ISSP_AfpWrapper(Contact con, Account acc, Boolean isSearch) {
        List<Agency_Authorization__c> authorizations = new List<Agency_Authorization__c>();
        List<Portal_Application_Right__c> services = new List<Portal_Application_Right__c>();

        authorizations = [SELECT Id,
                                     ANG_FormOfPayment_ID__c
                                FROM Agency_Authorization__c
                               WHERE Account__c = :acc.Id AND Status__c = 'Active'];

        if(con != null) {
            services = [SELECT Id, Application_Name__c, Right__c, Application_Start_URL__c
                          FROM Portal_Application_Right__c
                         WHERE Contact__c = :con.Id];
        }

        return new ANG_ISSP_AfpWrapper(con, authorizations, services, acc, isSearch);
    }

    public static List<Account> fetchAgentDetails(String iataCode) {
        return [Select Id, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                       BillingCountry, Name
                  From Account
                 Where RecordType.DeveloperName = 'IATA_Agency'
                   And Sector__c = :AMS_Utils.SECTOR_PASSENGER  // agentSector
                   And IATACode__c Like :iataCode];
    }

    /*** AMSU-166 Start ***/
    /**
    *   Method that validates if the record fields contain only latin characters
    **/
    public static List<String> validateCharacters(sObject record, List<Schema.SObjectField> fieldsToCheck) {
        List<String> res = new List<String>();
        String ISO_8859_1_regEx = '^[\\x00-\\x7F\\xA0-\\xFF]+$';
        Pattern p = Pattern.compile(ISO_8859_1_regEx);

        for(Schema.SObjectField field : fieldsToCheck) {
            String fieldAPIName = field.getDescribe().getName();
            String fieldLabel = field.getDescribe().getLabel();
            Object value = record.get(fieldAPIName);
            if( value == null || !(value instanceof String)) {
                continue; //Skip non String fields
            }

            if(!p.matcher((String) value).matches()) {
                res.add(fieldLabel + ': ' + Label.ISSP_EnterValidString);
            }

            if(((String) value).contains('\t')) {
                res.add(fieldLabel + ': Please remove all tabs');
            }
        }

        return res;
    }

    public static final List<Schema.SObjectField> STAGING_AREA_FIELDS_TO_VALIDATE = new List<Schema.SObjectField> {
        AMS_Pax_Accreditation_Form__c.Account_Name__c, 
        AMS_Pax_Accreditation_Form__c.IATACode__c, 
        AMS_Pax_Accreditation_Form__c.CASS_Number__c, 
        AMS_Pax_Accreditation_Form__c.Short_Name__c, 
        AMS_Pax_Accreditation_Form__c.Trade_Name__c, 
        AMS_Pax_Accreditation_Form__c.ISSP_AMS_License_No__c, 
        AMS_Pax_Accreditation_Form__c.ISSP_AMS_VAT_number__c,
        AMS_Pax_Accreditation_Form__c.Branch_Office_Street_name_number__c, 
        AMS_Pax_Accreditation_Form__c.Branch_Office_Postal_code__c, 
        AMS_Pax_Accreditation_Form__c.Branch_Office_City__c, 
        AMS_Pax_Accreditation_Form__c.Shipping_Street__c, 
        AMS_Pax_Accreditation_Form__c.Shipping_Postal_Code__c,
        AMS_Pax_Accreditation_Form__c.Shipping_City__c, 
        AMS_Pax_Accreditation_Form__c.Branch_Office_Email__c, 
        AMS_Pax_Accreditation_Form__c.Website__c, 
        AMS_Pax_Accreditation_Form__c.Abbreviated_name__c, 
        AMS_Pax_Accreditation_Form__c.Abbreviated_Address__c, 
        AMS_Pax_Accreditation_Form__c.VAT_Number_2__c
    };
    /*** AMSU-166 End ***/

}
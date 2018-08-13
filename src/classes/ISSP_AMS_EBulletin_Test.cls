@isTest
private class ISSP_AMS_EBulletin_Test {


    @testSetup static void createEBulletinCustomSettings(){

        /**
         1.AMSEBulletinCCSections
        */
    
        List<AMSEBulletinCCSections__c> eBulletinCCSections = new List <AMSEBulletinCCSections__c>();

        eBulletinCCSections.add( new AMSEBulletinCCSections__c(Order__c=1,Name='NEW APPLICATIONS',Agency_Information__c='Agency_Info_New_Aplication_Processes__c',Track_CC_History__c=FALSE));
        eBulletinCCSections.add( new AMSEBulletinCCSections__c(Order__c=2,Name='NEW APPROVALS',Agency_Information__c='Agency_Info_New_Aplication_Processes__c',Track_CC_History__c=FALSE));
        eBulletinCCSections.add( new AMSEBulletinCCSections__c(Order__c=3,Name='NEW APPLICATIONS DISAPPROVED',Agency_Information__c='Agency_Info_New_Aplication_Processes__c',Track_CC_History__c=FALSE));
        eBulletinCCSections.add( new AMSEBulletinCCSections__c(Order__c=4,Name='CHANGES IN PROCESS',Agency_Information__c='Agency_Info_Agency_Changes__c',Track_CC_History__c=TRUE));
        eBulletinCCSections.add( new AMSEBulletinCCSections__c(Order__c=5,Name='CHANGES FINALISED',Agency_Information__c='Agency_Info_Agency_Changes__c',Track_CC_History__c=FALSE));
        eBulletinCCSections.add( new AMSEBulletinCCSections__c(Order__c=6,Name='CHANGE WITHDRAWN',Agency_Information__c='Agency_Info_Agency_Changes__c',Track_CC_History__c=FALSE));
        eBulletinCCSections.add( new AMSEBulletinCCSections__c(Order__c=7,Name='TERMINATIONS AND CLOSURES',Agency_Information__c='Agency_Info_Termination_Closures__c',Track_CC_History__c=FALSE));
        eBulletinCCSections.add( new AMSEBulletinCCSections__c(Order__c=8,Name='DEFAULT INFORMATION',Agency_Information__c='Agency_Info_Defaults__c',Track_CC_History__c=FALSE));
        eBulletinCCSections.add( new AMSEBulletinCCSections__c(Order__c=9,Name='REVIEWS/NOTICES OF TERM.',Agency_Information__c='Agency_Info_Reviews__c',Track_CC_History__c=FALSE));
        eBulletinCCSections.add( new AMSEBulletinCCSections__c(Order__c=10,Name='IRREGULARITIES',Agency_Information__c='Agency_Info_Irregularities__c',Track_CC_History__c=FALSE));
        eBulletinCCSections.add( new AMSEBulletinCCSections__c(Order__c=11,Name='REINSTATEMENTS',Agency_Information__c='Agency_Info_Reinstatements__c',Track_CC_History__c=FALSE));

        insert eBulletinCCSections;

        /**
         2.AMSEBulletinCCExtration
        */

        List<AMSEBulletinCCExtration__c> eBulletinExtraction = new List <AMSEBulletinCCExtration__c>();

        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CAD',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CCF',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES FINALISED'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CCL',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CCN',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CHC',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CHF',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES FINALISED'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CHI',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CHL',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CHM',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CHN',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CHO',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CHS',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CHV',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CIJ',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CJJ',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CLF',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES FINALISED'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CLI',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CLM',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CLO',Daily__c=TRUE,Weekly__c=TRUE,Section__c='TERMINATIONS AND CLOSURES'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CLR',Daily__c=FALSE,Weekly__c=FALSE,Section__c=''));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CNF',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES FINALISED'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CNL',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CNM',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='COL',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CON',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='COS',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CSC',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CSF',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES FINALISED'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CSL',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CSM',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CSN',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CTA',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES FINALISED'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='CWD',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGE WITHDRAWN'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='DEF',Daily__c=TRUE,Weekly__c=TRUE,Section__c='DEFAULT INFORMATION'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='DFE ',Daily__c=TRUE,Weekly__c=TRUE,Section__c='DEFAULT INFORMATION'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='DIS',Daily__c=FALSE,Weekly__c=TRUE,Section__c='NEW APPLICATIONS DISAPPROVED'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='DWD',Daily__c=TRUE,Weekly__c=TRUE,Section__c='DEFAULT INFORMATION'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='FIN',Daily__c=FALSE,Weekly__c=TRUE,Section__c='NEW APPROVALS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='FPY',Daily__c=TRUE,Weekly__c=TRUE,Section__c='DEFAULT INFORMATION'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='HIN',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='HIS',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='HNL',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='HSL',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='HSM',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='HSN',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='IRR',Daily__c=TRUE,Weekly__c=TRUE,Section__c='IRREGULARITIES'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='IRS',Daily__c=TRUE,Weekly__c=TRUE,Section__c='IRREGULARITIES'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='IRW',Daily__c=TRUE,Weekly__c=TRUE,Section__c='IRREGULARITIES'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='LRA',Daily__c=FALSE,Weekly__c=FALSE,Section__c=''));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='LRD',Daily__c=FALSE,Weekly__c=FALSE,Section__c=''));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='LRR',Daily__c=FALSE,Weekly__c=FALSE,Section__c=''));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='MCF',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES FINALISED'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='MCH',Daily__c=FALSE,Weekly__c=FALSE,Section__c='CHANGES FINALISED'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='MEP',Daily__c=TRUE,Weekly__c=TRUE,Section__c=''));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='NAC',Daily__c=FALSE,Weekly__c=TRUE,Section__c='NEW APPLICATIONS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='NEW',Daily__c=FALSE,Weekly__c=TRUE,Section__c='NEW APPLICATIONS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='NLI',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='NOT',Daily__c=TRUE,Weekly__c=TRUE,Section__c='REVIEWS/NOTICES OF TERM.'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='NTW',Daily__c=TRUE,Weekly__c=TRUE,Section__c='REVIEWS/NOTICES OF TERM.'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='NWD',Daily__c=FALSE,Weekly__c=TRUE,Section__c='NEW APPLICATIONS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='ONL',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='OSL',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='OSM',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='OSN',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='RCM',Daily__c=TRUE,Weekly__c=TRUE,Section__c='REINSTATEMENTS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='RCR',Daily__c=TRUE,Weekly__c=TRUE,Section__c='REINSTATEMENTS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='REC',Daily__c=FALSE,Weekly__c=TRUE,Section__c='NEW APPROVALS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='REI',Daily__c=TRUE,Weekly__c=TRUE,Section__c='REINSTATEMENTS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='RPY',Daily__c=TRUE,Weekly__c=TRUE,Section__c=''));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='RRC',Daily__c=FALSE,Weekly__c=FALSE,Section__c='REINSTATEMENTS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='RTE',Daily__c=TRUE,Weekly__c=TRUE,Section__c='REINSTATEMENTS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='RTR',Daily__c=TRUE,Weekly__c=TRUE,Section__c='REINSTATEMENTS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='RVW',Daily__c=TRUE,Weekly__c=TRUE,Section__c='REVIEWS/NOTICES OF TERM.'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='RWD',Daily__c=TRUE,Weekly__c=TRUE,Section__c='REVIEWS/NOTICES OF TERM.'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='SCL',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='SCM',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='SCN',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='SDR',Daily__c=TRUE,Weekly__c=TRUE,Section__c='REINSTATEMENTS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='SLI',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='SML',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='SMN',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='SNI',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='SNL',Daily__c=FALSE,Weekly__c=TRUE,Section__c='CHANGES IN PROCESS'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='SRM',Daily__c=TRUE,Weekly__c=TRUE,Section__c='REVIEWS/NOTICES OF TERM.'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='STR',Daily__c=TRUE,Weekly__c=TRUE,Section__c='REVIEWS/NOTICES OF TERM.'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='TER',Daily__c=TRUE,Weekly__c=TRUE,Section__c='TERMINATIONS AND CLOSURES'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='TRW',Daily__c=TRUE,Weekly__c=TRUE,Section__c='TERMINATIONS AND CLOSURES'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='VRR',Daily__c=TRUE,Weekly__c=TRUE,Section__c='TERMINATIONS AND CLOSURES'));
        eBulletinExtraction.add(new AMSEBulletinCCExtration__c(Name='VRW',Daily__c=TRUE,Weekly__c=TRUE,Section__c='TERMINATIONS AND CLOSURES'));

        insert eBulletinExtraction;


        /**
         3. AMSEBulletinSettings
        */

        List<AMSEBulletinSettings__c> eBulletinSettings = new List <AMSEBulletinSettings__c>();

        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='0-Section',Label__c='Section',API_Name__c='Section',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=0,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='1-Change Code',Label__c='Change Code',API_Name__c='Change_Code__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=1,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='2-Agency Code',Label__c='Agency Code',API_Name__c='Account__r.IATACode__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=2,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='3-Agency Name',Label__c='Agency Name',API_Name__c='Account__r.Name',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=3,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='4-Location Type',Label__c='Location Type',API_Name__c='Account__r.Location_Type__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=4,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='5-Legal Status',Label__c='Legal Status',API_Name__c='Account__r.Company_Type__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=5,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));    
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='6-Accreditation Type',Label__c='Accreditation Type',API_Name__c='Account__r.ANG_Accreditation_Model__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=6,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));      
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='7-Forms of Payment',Label__c='Forms of Payment',API_Name__c='Forms_of_Payment__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=7,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='8-Risk Status',Label__c='  Risk Status',API_Name__c='Account__r.ANG_RiskStatus__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=8,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='9-Cash Condition equal to FS',Label__c='Cash Condition equal to FS',API_Name__c='Account__r.ANG_CashCondition__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=9,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));       
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='10-Program',Label__c='Program',API_Name__c='Account__r.Location_Class__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=10,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='11-Hierarchy',Label__c='Hierarchy HO',API_Name__c='Account__r.Parent.IATACode__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=11,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='12-Trade Name',Label__c='Trade Name',API_Name__c='Account__r.TradeName__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=12,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='13-City',Label__c='City',API_Name__c='Account__r.BillingCity',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=13,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='14-Country or State',Label__c='Country or State',API_Name__c='Account__r.Iso_State__r.name,Account__r.Iso_State__r.ISO_Code__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=14,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='15-Country or State',Label__c='Country or State',API_Name__c='Account__r.IATA_ISO_Country__r.name,Account__r.IATA_ISO_Country__r.ISO_Code__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=14,do_not_show__c=TRUE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='16-Street',Label__c='Street',API_Name__c='Account__r.BillingStreet',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=15,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='17-Zip Code',Label__c='Zip Code',API_Name__c='Account__r.BillingPostalCode',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=16,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='18-Phone Number',Label__c='Phone Number',API_Name__c='Account__r.Phone',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=17,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='19-Fax Number',Label__c='Fax Number',API_Name__c='Account__r.Fax',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=18,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='20-Email',Label__c='Email',API_Name__c='Account__r.Email__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=19,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='21-VAT Number 1',Label__c='VAT Number 1',API_Name__c='Account__r.VAT_Number__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=20,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='22-VAT Number 2',Label__c='VAT Number 2',API_Name__c='Account__r.VAT_Number_2__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=21,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='23-Status',Label__c='Status',API_Name__c='AccountNewStatus__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=22,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='24-Effective Date',Label__c='User Date',API_Name__c='Created_Date_To_Show__c ',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=23,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));        
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='25-User Date',Label__c='Effective Date',API_Name__c='CreatedDate_User__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=24,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='26-Application Date',Label__c='Application Date',API_Name__c='Created_Date_To_Show__c ',Daily__c=FALSE,Weekly__c=FALSE,Number_Order__c=25,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='27-Reason',Label__c='Reason',API_Name__c='Reason_Description__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=26,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));       
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='28-Remarks',Label__c='Remarks',API_Name__c='Bulletin_Information__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=27,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='29-Financial Security',Label__c='Financial Security',API_Name__c='Financial_Security__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=28,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='30-Outstanding Amount',Label__c='Outstanding Amount',API_Name__c='Outstanding_Amount__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=29,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='31-Termination Date',Label__c='Termination Date',API_Name__c='Termination_Date__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=30,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='32-Irregularity Sequence',Label__c='Irregularity Sequence',API_Name__c='Irregularity_Sequence__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=31,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='33-Owners',Label__c='Owners',API_Name__c='Owners',Daily__c=FALSE,Weekly__c=FALSE,Number_Order__c=32,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='34-Owner1',Label__c='Owner1',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=33,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='35-Owner1 %',Label__c='Owner1 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=34,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='36-Owner2',Label__c='Owner2',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=35,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='37-Owner2 %',Label__c='Owner2 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=36,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='38-Owner3',Label__c='Owner3',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=37,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='39-Owner3 %',Label__c='Owner3 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=38,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='40-Owner4',Label__c='Owner4',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=39,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='41-Owner4 %',Label__c='Owner4 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=40,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='42-Owner5',Label__c='Owner5',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=41,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='43-Owner5 %',Label__c='Owner5 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=42,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='44-Owner6',Label__c='Owner6',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=43,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='45-Owner6 %',Label__c='Owner6 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=44,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='46-Owner7',Label__c='Owner7',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=45,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='47-Owner7 %',Label__c='Owner7 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=46,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='48-Owner8',Label__c='Owner8',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=47,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='49-Owner8 %',Label__c='Owner8 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=48,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='50-Owners Total %',Label__c='Owners Total %',API_Name__c='OwnersTotal',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=49,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='51-New Agency Name',Label__c='New Agency Name',API_Name__c='Account__r.Name',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=50,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='52-New Location Type',Label__c='New Location Type',API_Name__c='Account__r.Location_Type__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=51,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='53-New Legal Status',Label__c='New Legal Status',API_Name__c='Account__r.Company_Type__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=52,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='54-New Hierarchy',Label__c='New Hierarchy',API_Name__c='Account__r.Parent.IATACode__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=53,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='55-New Trade Name',Label__c='New Trade Name',API_Name__c='Account__r.TradeName__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=54,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='56-New Accreditation Type',Label__c='New Accreditation Type',API_Name__c='Account__r.ANG_Accreditation_Model__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=55,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='57-New City',Label__c='New City',API_Name__c='Account__r.BillingCity',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=56,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='58-New Country or State',Label__c='New Country or State',API_Name__c='Account__r.IATA_ISO_Billing_State__r.name,Account__r.IATA_ISO_Billing_State__r.ISO_Code__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=57,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='59-New Country or State',Label__c='New Country or State',API_Name__c='Account__r.IATA_ISO_Country__r.name,Account__r.IATA_ISO_Country__r.ISO_Code__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=57,do_not_show__c=TRUE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='60-New Street',Label__c='New Street',API_Name__c='Account__r.BillingStreet',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=58,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='61-New Zip Code',Label__c='New Zip Code',API_Name__c='Account__r.BillingPostalCode',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=59,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='62-New Phone Number',Label__c='New Phone Number',API_Name__c='Account__r.Phone',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=60,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='63-New Fax Number',Label__c='New Fax Number',API_Name__c='Account__r.Fax',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=61,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='64-New Email',Label__c='New Email',API_Name__c='Account__r.Email__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=62,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='65-New VAT Number 1',Label__c='New VAT Number 1',API_Name__c='Account__r.VAT_Number__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=63,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='66-New VAT Number 2',Label__c='New VAT Number 2',API_Name__c='Account__r.VAT_Number_2__c',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=64,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='67-New Owners',Label__c='New Owners',API_Name__c='Owners',Daily__c=FALSE,Weekly__c=FALSE,Number_Order__c=65,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='68-New Owner1',Label__c='New Owner1',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=66,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='69-New Owner1 %',Label__c='New Owner1 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=67,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='70-New Owner2',Label__c='New Owner2',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=68,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='71-New Owner2 %',Label__c='New Owner2 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=69,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='72-New Owner3',Label__c='New Owner3',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=70,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='73-New Owner3 %',Label__c='New Owner3 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=71,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='74-New Owner4',Label__c='New Owner4',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=72,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='75-New Owner4 %',Label__c='New Owner4 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=73,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='76-New Owner5',Label__c='New Owner5',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=74,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='77-New Owner5 %',Label__c='New Owner5 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=75,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='78-New Owner6',Label__c='New Owner6',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=76,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='79-New Owner6 %',Label__c='New Owner6 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=77,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='80-New Owner7',Label__c='New Owner7',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=78,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='81-New Owner7 %',Label__c='New Owner7 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=79,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='82-New Owner8',Label__c='New Owner8',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=80,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='83-New Owner8 %',Label__c='New Owner8 %',API_Name__c='Account__r.Owners',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=81,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='84-New Owners Total %',Label__c='New Owners Total %',API_Name__c='OwnersTotal',Daily__c=FALSE,Weekly__c=TRUE,Number_Order__c=82,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=TRUE,IRR_Field__c=FALSE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='85-IRR: Reason',Label__c='IRR: Reason',API_Name__c='Reason_Description__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=83,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=TRUE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='86-IRR: Period',Label__c='IRR: Period',API_Name__c='Start_Date__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=84,do_not_show__c=FALSE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=TRUE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='87-IRR: Period',Label__c='IRR: Period',API_Name__c='End_Date__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=84,do_not_show__c=TRUE,do_not_query__c=TRUE,Is_Field_New__c=FALSE,IRR_Field__c=TRUE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='88-IRR: Point',Label__c='IRR: Point',API_Name__c='Irregularities_Points__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=85,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=TRUE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='89-IRR: Accumulated Irregularities',Label__c='IRR: Accumulated Irregularities',API_Name__c='Account__r.Accumulated_Irregularities__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=86,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=TRUE));
        eBulletinSettings.add( new AMSEBulletinSettings__c(Name='90-IRR: End of Grace Period Date',Label__c='IRR: End of Grace Period Date',API_Name__c=' End_Of_Grace_Period_date__c',Daily__c=TRUE,Weekly__c=TRUE,Number_Order__c=87,do_not_show__c=FALSE,do_not_query__c=FALSE,Is_Field_New__c=FALSE,IRR_Field__c=TRUE));

        insert eBulletinSettings;

        /**
         4. ISSP_CS__c
        */

        List<ISSP_CS__c> isspCs = new List<ISSP_CS__c>();
        isspCs.add( new ISSP_CS__c(Name = 'eBulletin_UserGuide',Value__c = 'EBULLETIN-USERGUIDE-'));
        isspCs.add( new ISSP_CS__c(Name = 'eBulletin_StartDate',Value__c = '01/08/2015'));

        insert isspCs;

    }

	
	@isTest static void test_method_one() {
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
        							IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
        							IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 't1',
        							IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test',
                                    Region__c = 'Americas' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', IATA_Contry_KR__c = 'test2',
                                    IATA_COUNTRY_EN__c = 'testEN2' , IATA_Country_FR__c = 'testFR2' , IATA_Country_ZH__c = 'testZH2' ,
                                    IATA_Country_IT__c = 'testIT2' , IATA_Country_JP__c = 'testJP2' , ISO_Code__c = 't2',
                                    IATA_Country_PT__c = 'testPT2' , IATA_Country_SP__c = 'testSP2' , Case_BSP_Country__c = 'test2',
                                    Region__c = 'Americas');
        insert country2;

        IATA_ISO_Country__c country3 = new IATA_ISO_Country__c(name = 'test3', IATA_Contry_KR__c = 'test3',
                                    IATA_COUNTRY_EN__c = 'testEN3' , IATA_Country_FR__c = 'testFR3' , IATA_Country_ZH__c = 'testZH3' ,
                                    IATA_Country_IT__c = 'testIT3' , IATA_Country_JP__c = 'testJP3' , ISO_Code__c = 't3',
                                    IATA_Country_PT__c = 'testPT3' , IATA_Country_SP__c = 'testSP3' , Case_BSP_Country__c = 'test3',
                                    Region__c = 'Europe');
        insert country3;

        IATA_ISO_Country__c country4 = new IATA_ISO_Country__c(name = 'test4', IATA_Contry_KR__c = 'test4',
                                    IATA_COUNTRY_EN__c = 'testEN4' , IATA_Country_FR__c = 'testFR4' , IATA_Country_ZH__c = 'testZH4' ,
                                    IATA_Country_IT__c = 'testIT4' , IATA_Country_JP__c = 'testJP4' , ISO_Code__c = 't4',
                                    IATA_Country_PT__c = 'testPT4' , IATA_Country_SP__c = 'testSP4' , Case_BSP_Country__c = 'test4',
                                    Region__c = 'China & North Asia');
        insert country4;

		Id rtIdBr = [ SELECT Id FROM RecordType 
		WHERE SobjectType = 'Account'
		AND DeveloperName = 'IATA_Agency'][0].Id; 


		Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
		parent.sector__c = 'airline';
		parent.Location_Type__c = 'HO';
		parent.RecordTypeId = rtIdBr ;
		parent.IATACode__c = '100';
		 
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
		child.sector__c = 'airline';
        child.Top_Parent__c = null;
		child.IATA_ISO_Country__c = country.Id;
		child.RecordTypeId = rtIdBr ;
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
		con.Email = 'Test@test11.com';
		con.User_Portal_Status__c='Administrator';
        
        insert con;


       
        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        
        
        insert new ISSP_CS__c(Name = 'DefaultNewAccountOwnerId',Value__c = newUser.Id);
        insert new ISSP_CS__c(Name = 'eBulletin_UserGuide',Value__c = 'EBULLETIN-USERGUIDE-');
        insert new ISSP_CS__c(Name = 'eBulletin_StartDate',Value__c = '01/08/2015');
        insert new ISSP_PDF_Per_Region__c(Name = 'test_en_US',Address__c = 'test_en_US',Link_To_PDF__c = 'test_en_US');
        insert new ISSP_PDF_Per_Region__c(Name = 'test_PT_pt',Address__c = 'test_PT_pt',Link_To_PDF__c = 'test_PT_pt');
        
        insert new ISSP_PDF_Per_Region__c(Name = 'EBULLETIN-USERGUIDE-en_US',Address__c='EBULLETIN-USERGUIDE-en_US', Link_To_PDF__c = 'EBULLETIN-USERGUIDE-en_US');

        
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

        Test.startTest();
        System.runAs(newUser)
        {
            ISSP_AMS_EBulletin bulletin_0 = new ISSP_AMS_EBulletin();

            bulletin_0.fillMapCountries();
System.debug('mCountries 1: ' + bulletin_0.mCountries);
            List<String> lsStr = bulletin_0.getCountryName(new List<String>{'t1','t2','t4'});

            bulletin_0.newFormDaily.Area_1__c = true;
            bulletin_0.newFormWeekly.Area_1__c = true;
            bulletin_0.newFormDaily.Area_2__c = true;
            bulletin_0.newFormWeekly.Area_2__c = true;
            bulletin_0.newFormDaily.Area_3__c = true;
            bulletin_0.newFormWeekly.Area_3__c = true;

            bulletin_0.dailyCountrySelectAll = false;
            bulletin_0.weeklyCountrySelectAll = false;

            bulletin_0.dailyCountry = new List<String>{'t1','t2','t4'};
            bulletin_0.weeklyCountry =  new List<String>{'t1','t2','t4'};

            
            

            bulletin_0.dailyFileDownload = 'test';
            bulletin_0.weeklyFileDownload = 'test';
            bulletin_0.todayPeriod = 'test';
            bulletin_0.pDateStart = '01/01/2017';
            bulletin_0.pWeekStart = '01/01/2017';
            bulletin_0.pWeekEnd = '01/02/2017';
            bulletin_0.onOff = false;
            bulletin_0.dailyOnOff = false;
            bulletin_0.weeklyOnOff = false;
            PageReference pr_0 = bulletin_0.checkRedirect();
            String userguide = bulletin_0.getUserGuideFileLink('test_', 'PT_pt');
            List<SelectOption> timeZone = bulletin_0.getTimeZone();
            List<SelectOption> itemsDaysOfWeek = bulletin_0.getItemsDaysOfWeek();
            List<SelectOption> itemsWeeks = bulletin_0.getItemsWeeks();
            
            //bulletin_0.dailyCountrySelectAll();
            //bulletin_0.weeklyCountrySelectAll();

            bulletin_0.applyLanguage = 'es';
            
            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.dailyCountry);
            bulletin_0.weeklyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.weeklyCountry);
            List<String> lsStr1 = bulletin_0.getCountryName(bulletin_0.dailyCountry);
            List<String> lsStr2 = bulletin_0.getCountryName(bulletin_0.weeklyCountry);
            List<SelectOption> countryNameList1 = bulletin_0.countryNameListSelectOption('Daily');
            List<SelectOption> countryNameList2 = bulletin_0.countryNameListSelectOption('Weekly');

            bulletin_0.applyLanguage = 'fr';
            
            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.dailyCountry);
            bulletin_0.weeklyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.weeklyCountry);
            lsStr1 = bulletin_0.getCountryName(bulletin_0.dailyCountry);
            lsStr2 = bulletin_0.getCountryName(bulletin_0.weeklyCountry);
            countryNameList1 = bulletin_0.countryNameListSelectOption('Daily');
            countryNameList2 = bulletin_0.countryNameListSelectOption('Weekly');

            bulletin_0.applyLanguage = 'en_US';
            countryNameList1 = bulletin_0.countryNameListSelectOption('Daily');
            countryNameList2 = bulletin_0.countryNameListSelectOption('Weekly');

System.debug('mCountries 2: ' + bulletin_0.mCountries);

            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.dailyCountry);
            bulletin_0.weeklyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.weeklyCountry);
            lsStr1 = bulletin_0.getCountryName(bulletin_0.dailyCountry);
            lsStr2 = bulletin_0.getCountryName(bulletin_0.weeklyCountry);
            bulletin_0.applyLanguage = 'es';
            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.dailyCountry);
            bulletin_0.weeklyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.weeklyCountry);
            lsStr1 = bulletin_0.getCountryName(bulletin_0.dailyCountry);
            lsStr2 = bulletin_0.getCountryName(bulletin_0.weeklyCountry);
            bulletin_0.applyLanguage = 'fr';
            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.dailyCountry);
            bulletin_0.weeklyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.weeklyCountry);
            lsStr1 = bulletin_0.getCountryName(bulletin_0.dailyCountry);
            lsStr2 = bulletin_0.getCountryName(bulletin_0.weeklyCountry);
            bulletin_0.applyLanguage = 'en_US';
            
            bulletin_0.newFormDaily.Suspend_Subscription__c = true;
            PageReference pr_suspendSubscription = bulletin_0.suspendSubscription();
            bulletin_0.newFormDaily.Suspend_Subscription__c = false;
            pr_suspendSubscription = bulletin_0.suspendSubscription();

            Boolean bval = bulletin_0.validateCharactersInForm();

            PageReference pr_dailyReportDownload = bulletin_0.dailyReportDownload();
            PageReference pr_weeklyReportDownload = bulletin_0.weeklyReportDownload();

            PageReference checkBatchStatus = bulletin_0.checkBatchStatus();

            PageReference pr_Nav = bulletin_0.goToStepHome();
            pr_Nav = bulletin_0.goToStep1();
            pr_Nav = bulletin_0.goToStep1_1();
            pr_Nav = bulletin_0.goToStep1_2();
            pr_Nav = bulletin_0.goToStep2();
            pr_Nav = bulletin_0.goToStep3();
            pr_Nav = bulletin_0.saveAMSFormAndGoSideways();
            pr_Nav = bulletin_0.saveAMSFormAndGoForward();
            pr_Nav = bulletin_0.saveAMSFormAndGoBack();
            pr_Nav = bulletin_0.saveAMSFormAndStay();

            pr_Nav = bulletin_0.securityCheck();

            String str1 = bulletin_0.getMultiSelectToSave(bulletin_0.dailyCountry);
            String str2 = bulletin_0.getMultiSelectOptionsToSave(bulletin_0.countryNameListSelectOptionDaily);

            List<SelectOption> countryNameListDaily = bulletin_0.countryNameListSelectOptionDaily;
            List<SelectOption> countryNameListWeekly = bulletin_0.countryNameListSelectOptionWeekly;

            //System.debug('dailyCountrySelected 1: ' + bulletin_0.dailyCountrySelected);

            bulletin_0.dailyCountrySelectAll = true;
            bulletin_0.weeklyCountrySelectAll = true;
            bulletin_0.dailyCountrySelectAll();
            bulletin_0.weeklyCountrySelectAll();

            List<String> lstrTest = new List<String>{'t1','t4'};

            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(lstrTest);
            bulletin_0.weeklyCountrySelected =  bulletin_0.populateSelectedCountries(lstrTest);
            bulletin_0.newFormDaily.Area_2__c = false;
            bulletin_0.newFormWeekly.Area_2__c = false;

            //System.debug('dailyCountrySelected 2: ' + bulletin_0.dailyCountrySelected);

            countryNameListDaily = bulletin_0.countryNameListSelectOptionDaily;
            countryNameListWeekly = bulletin_0.countryNameListSelectOptionWeekly;

            lstrTest = new List<String>{'t1','t3','t4'};
            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(lstrTest);
            bulletin_0.weeklyCountrySelected =  bulletin_0.populateSelectedCountries(lstrTest);
            bulletin_0.newFormDaily.Area_2__c = true;
            bulletin_0.newFormWeekly.Area_2__c = true;
           

            
            ISSP_AMS_EBulletin bulletin_0_2 = new ISSP_AMS_EBulletin();
            PageReference pr_0_2 = bulletin_0_2.checkRedirect();

            ApexPages.currentPage().getParameters().put('step' ,'1' );
            ISSP_AMS_EBulletin bulletin_1 = new ISSP_AMS_EBulletin();
            PageReference pr_saveAMSFormAndGoSideways = bulletin_1.saveAMSFormAndGoSideways();
            PageReference pr_saveAMSFormAndGoForward = bulletin_1.saveAMSFormAndGoForward();

            ApexPages.currentPage().getParameters().put('step' ,'1_1' );
            ISSP_AMS_EBulletin bulletin_1_1 = new ISSP_AMS_EBulletin();
            bulletin_1_1.newFormDaily.Opt_in__c = true;
            pr_saveAMSFormAndGoSideways = bulletin_1_1.saveAMSFormAndGoSideways();
            pr_saveAMSFormAndGoForward = bulletin_1_1.saveAMSFormAndGoForward();
            PageReference pr_saveAMSFormAndStay = bulletin_1_1.saveAMSFormAndStay();

            ApexPages.currentPage().getParameters().put('step' ,'1_2' );
            ISSP_AMS_EBulletin bulletin_1_2 = new ISSP_AMS_EBulletin();
            bulletin_1_2.newFormWeekly.Opt_in__c = true;
            pr_saveAMSFormAndGoSideways = bulletin_1_2.saveAMSFormAndGoSideways();
            pr_saveAMSFormAndGoForward = bulletin_1_2.saveAMSFormAndGoForward();
            pr_saveAMSFormAndStay = bulletin_1_2.saveAMSFormAndStay();

            ApexPages.currentPage().getParameters().put('step' ,'2' );
            ISSP_AMS_EBulletin bulletin_2 = new ISSP_AMS_EBulletin();
            pr_saveAMSFormAndGoSideways = bulletin_2.saveAMSFormAndGoSideways();
            pr_saveAMSFormAndGoForward = bulletin_2.saveAMSFormAndGoForward();

            ApexPages.currentPage().getParameters().put('step' ,'3' );
            ISSP_AMS_EBulletin bulletin_3 = new ISSP_AMS_EBulletin();
            pr_saveAMSFormAndGoSideways = bulletin_3.saveAMSFormAndGoSideways();
            pr_saveAMSFormAndGoForward = bulletin_3.saveAMSFormAndGoForward();

            ApexPages.currentPage().getParameters().put('step' ,'home' );
            ISSP_AMS_EBulletin bulletin_home = new ISSP_AMS_EBulletin();

            PageReference pr_home = bulletin_home.checkRedirect();

            /*** AMSU-62 ***/
            bulletin_0.clearAllDaily();
            bulletin_0.clearAllWeekly();
    	}
        Test.stopTest();

	}
	
	@isTest static void test_CNS() {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 't1',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test',
                                    Region__c = 'Americas' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', IATA_Contry_KR__c = 'test2',
                                    IATA_COUNTRY_EN__c = 'testEN2' , IATA_Country_FR__c = 'testFR2' , IATA_Country_ZH__c = 'testZH2' ,
                                    IATA_Country_IT__c = 'testIT2' , IATA_Country_JP__c = 'testJP2' , ISO_Code__c = 't2',
                                    IATA_Country_PT__c = 'testPT2' , IATA_Country_SP__c = 'testSP2' , Case_BSP_Country__c = 'test2',
                                    Region__c = 'Americas');
        insert country2;

        IATA_ISO_Country__c country3 = new IATA_ISO_Country__c(name = 'test3', IATA_Contry_KR__c = 'test3',
                                    IATA_COUNTRY_EN__c = 'testEN3' , IATA_Country_FR__c = 'testFR3' , IATA_Country_ZH__c = 'testZH3' ,
                                    IATA_Country_IT__c = 'testIT3' , IATA_Country_JP__c = 'testJP3' , ISO_Code__c = 't3',
                                    IATA_Country_PT__c = 'testPT3' , IATA_Country_SP__c = 'testSP3' , Case_BSP_Country__c = 'test3',
                                    Region__c = 'Europe');
        insert country3;

        IATA_ISO_Country__c country4 = new IATA_ISO_Country__c(name = 'test4', IATA_Contry_KR__c = 'test4',
                                    IATA_COUNTRY_EN__c = 'testEN4' , IATA_Country_FR__c = 'testFR4' , IATA_Country_ZH__c = 'testZH4' ,
                                    IATA_Country_IT__c = 'testIT4' , IATA_Country_JP__c = 'testJP4' , ISO_Code__c = 't4',
                                    IATA_Country_PT__c = 'testPT4' , IATA_Country_SP__c = 'testSP4' , Case_BSP_Country__c = 'test4',
                                    Region__c = 'China & North Asia');
        insert country4;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'airline';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'airline';
        child.Top_Parent__c = null;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        con.User_Portal_Status__c='Administrator';
        
        insert con;


       
        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        
        
        insert new ISSP_CS__c(Name = 'DefaultNewAccountOwnerId',Value__c = newUser.Id);
        insert new ISSP_CS__c(Name = 'eBulletin_UserGuide',Value__c = 'EBULLETIN-USERGUIDE-');
        insert new ISSP_CS__c(Name = 'eBulletin_StartDate',Value__c = '01/08/2015');
        insert new ISSP_PDF_Per_Region__c(Name = 'test_en_US',Address__c = 'test_en_US',Link_To_PDF__c = 'test_en_US');
        insert new ISSP_PDF_Per_Region__c(Name = 'test_PT_pt',Address__c = 'test_PT_pt',Link_To_PDF__c = 'test_PT_pt');
        
        insert new ISSP_PDF_Per_Region__c(Name = 'EBULLETIN-USERGUIDE-en_US',Address__c='EBULLETIN-USERGUIDE-en_US', Link_To_PDF__c = 'EBULLETIN-USERGUIDE-en_US');

        
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

        Test.startTest();
        System.runAs(newUser)
        {
            CNS_EBulletin bulletin_0 = new CNS_EBulletin();

            bulletin_0.fillMapCountries();
System.debug('mCountries 1: ' + bulletin_0.mCountries);
            List<String> lsStr = bulletin_0.getCountryName(new List<String>{'t1','t2','t4'});

            bulletin_0.newFormDaily.Area_1__c = true;
            bulletin_0.newFormWeekly.Area_1__c = true;
            bulletin_0.newFormDaily.Area_2__c = true;
            bulletin_0.newFormWeekly.Area_2__c = true;
            bulletin_0.newFormDaily.Area_3__c = true;
            bulletin_0.newFormWeekly.Area_3__c = true;

            bulletin_0.dailyCountrySelectAll = false;
            bulletin_0.weeklyCountrySelectAll = false;

            bulletin_0.dailyCountry = new List<String>{'t1','t2','t4'};
            bulletin_0.weeklyCountry =  new List<String>{'t1','t2','t4'};

            
            

            bulletin_0.dailyFileDownload = 'test';
            bulletin_0.weeklyFileDownload = 'test';
            bulletin_0.todayPeriod = 'test';
            bulletin_0.pDateStart = '01/01/2017';
            bulletin_0.pWeekStart = '01/01/2017';
            bulletin_0.pWeekEnd = '01/02/2017';
            bulletin_0.onOff = false;
            bulletin_0.dailyOnOff = false;
            bulletin_0.weeklyOnOff = false;
            PageReference pr_0 = bulletin_0.checkRedirect();
            String userguide = bulletin_0.getUserGuideFileLink('test_', 'PT_pt');
            List<SelectOption> timeZone = bulletin_0.getTimeZone();
            List<SelectOption> itemsDaysOfWeek = bulletin_0.getItemsDaysOfWeek();
            List<SelectOption> itemsWeeks = bulletin_0.getItemsWeeks();
            
            //bulletin_0.dailyCountrySelectAll();
            //bulletin_0.weeklyCountrySelectAll();

            bulletin_0.applyLanguage = 'es';
            
            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.dailyCountry);
            bulletin_0.weeklyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.weeklyCountry);
            List<String> lsStr1 = bulletin_0.getCountryName(bulletin_0.dailyCountry);
            List<String> lsStr2 = bulletin_0.getCountryName(bulletin_0.weeklyCountry);
            List<SelectOption> countryNameList1 = bulletin_0.countryNameListSelectOption('Daily');
            List<SelectOption> countryNameList2 = bulletin_0.countryNameListSelectOption('Weekly');

            bulletin_0.applyLanguage = 'fr';
            
            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.dailyCountry);
            bulletin_0.weeklyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.weeklyCountry);
            lsStr1 = bulletin_0.getCountryName(bulletin_0.dailyCountry);
            lsStr2 = bulletin_0.getCountryName(bulletin_0.weeklyCountry);
            countryNameList1 = bulletin_0.countryNameListSelectOption('Daily');
            countryNameList2 = bulletin_0.countryNameListSelectOption('Weekly');

            bulletin_0.applyLanguage = 'en_US';
            countryNameList1 = bulletin_0.countryNameListSelectOption('Daily');
            countryNameList2 = bulletin_0.countryNameListSelectOption('Weekly');

System.debug('mCountries 2: ' + bulletin_0.mCountries);

            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.dailyCountry);
            bulletin_0.weeklyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.weeklyCountry);
            lsStr1 = bulletin_0.getCountryName(bulletin_0.dailyCountry);
            lsStr2 = bulletin_0.getCountryName(bulletin_0.weeklyCountry);
            bulletin_0.applyLanguage = 'es';
            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.dailyCountry);
            bulletin_0.weeklyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.weeklyCountry);
            lsStr1 = bulletin_0.getCountryName(bulletin_0.dailyCountry);
            lsStr2 = bulletin_0.getCountryName(bulletin_0.weeklyCountry);
            bulletin_0.applyLanguage = 'fr';
            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.dailyCountry);
            bulletin_0.weeklyCountrySelected = bulletin_0.populateSelectedCountries(bulletin_0.weeklyCountry);
            lsStr1 = bulletin_0.getCountryName(bulletin_0.dailyCountry);
            lsStr2 = bulletin_0.getCountryName(bulletin_0.weeklyCountry);
            bulletin_0.applyLanguage = 'en_US';
            
            bulletin_0.newFormDaily.Suspend_Subscription__c = true;
            PageReference pr_suspendSubscription = bulletin_0.suspendSubscription();
            bulletin_0.newFormDaily.Suspend_Subscription__c = false;
            pr_suspendSubscription = bulletin_0.suspendSubscription();

            Boolean bval = bulletin_0.validateCharactersInForm();

            try{ PageReference pr_dailyReportDownload = bulletin_0.dailyReportDownload();}catch(Exception e){}
            try{ PageReference pr_weeklyReportDownload = bulletin_0.weeklyReportDownload();}catch(Exception e){}

            PageReference pr_Nav = bulletin_0.goToStep1();
            pr_Nav = bulletin_0.goToStep1_1();
            pr_Nav = bulletin_0.goToStep1_2();
            pr_Nav = bulletin_0.goToStep2();
            pr_Nav = bulletin_0.goToStep3();
            //pr_Nav = bulletin_0.saveAMSFormAndGoSideways();
            pr_Nav = bulletin_0.saveAMSFormAndGoForward();
            pr_Nav = bulletin_0.saveAMSFormAndGoBack();
            pr_Nav = bulletin_0.saveAMSFormAndStay();

            pr_Nav = bulletin_0.securityCheck();

            String str1 = bulletin_0.getMultiSelectToSave(bulletin_0.dailyCountry);
            String str2 = bulletin_0.getMultiSelectOptionsToSave(bulletin_0.countryNameListSelectOptionDaily);

            List<SelectOption> countryNameListDaily = bulletin_0.countryNameListSelectOptionDaily;
            List<SelectOption> countryNameListWeekly = bulletin_0.countryNameListSelectOptionWeekly;

            //System.debug('dailyCountrySelected 1: ' + bulletin_0.dailyCountrySelected);

            bulletin_0.dailyCountrySelectAll = true;
            bulletin_0.weeklyCountrySelectAll = true;
            bulletin_0.dailyCountrySelectAll();
            bulletin_0.weeklyCountrySelectAll();

            List<String> lstrTest = new List<String>{'t1','t4'};

            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(lstrTest);
            bulletin_0.weeklyCountrySelected =  bulletin_0.populateSelectedCountries(lstrTest);
            bulletin_0.newFormDaily.Area_2__c = false;
            bulletin_0.newFormWeekly.Area_2__c = false;

            //System.debug('dailyCountrySelected 2: ' + bulletin_0.dailyCountrySelected);

            countryNameListDaily = bulletin_0.countryNameListSelectOptionDaily;
            countryNameListWeekly = bulletin_0.countryNameListSelectOptionWeekly;

            lstrTest = new List<String>{'t1','t3','t4'};
            bulletin_0.dailyCountrySelected = bulletin_0.populateSelectedCountries(lstrTest);
            bulletin_0.weeklyCountrySelected =  bulletin_0.populateSelectedCountries(lstrTest);
            bulletin_0.newFormDaily.Area_2__c = true;
            bulletin_0.newFormWeekly.Area_2__c = true;
           

            
            CNS_EBulletin bulletin_0_2 = new CNS_EBulletin();
            PageReference pr_0_2 = bulletin_0_2.checkRedirect();

            ApexPages.currentPage().getParameters().put('step' ,'1' );
            CNS_EBulletin bulletin_1 = new CNS_EBulletin();
            //PageReference pr_saveAMSFormAndGoSideways = bulletin_1.saveAMSFormAndGoSideways();
            PageReference pr_saveAMSFormAndGoForward = bulletin_1.saveAMSFormAndGoForward();

            ApexPages.currentPage().getParameters().put('step' ,'1_1' );
            CNS_EBulletin bulletin_1_1 = new CNS_EBulletin();
            bulletin_1_1.newFormDaily.Opt_in__c = true;
            //pr_saveAMSFormAndGoSideways = bulletin_1_1.saveAMSFormAndGoSideways();
            pr_saveAMSFormAndGoForward = bulletin_1_1.saveAMSFormAndGoForward();
            PageReference pr_saveAMSFormAndStay = bulletin_1_1.saveAMSFormAndStay();

            ApexPages.currentPage().getParameters().put('step' ,'1_2' );
            CNS_EBulletin bulletin_1_2 = new CNS_EBulletin();
            bulletin_1_2.newFormWeekly.Opt_in__c = true;
            //pr_saveAMSFormAndGoSideways = bulletin_1_2.saveAMSFormAndGoSideways();
            pr_saveAMSFormAndGoForward = bulletin_1_2.saveAMSFormAndGoForward();
            pr_saveAMSFormAndStay = bulletin_1_2.saveAMSFormAndStay();

            ApexPages.currentPage().getParameters().put('step' ,'2' );
            CNS_EBulletin bulletin_2 = new CNS_EBulletin();
            //pr_saveAMSFormAndGoSideways = bulletin_2.saveAMSFormAndGoSideways();
            pr_saveAMSFormAndGoForward = bulletin_2.saveAMSFormAndGoForward();

            ApexPages.currentPage().getParameters().put('step' ,'3' );
            CNS_EBulletin bulletin_3 = new CNS_EBulletin();
            //pr_saveAMSFormAndGoSideways = bulletin_3.saveAMSFormAndGoSideways();
            pr_saveAMSFormAndGoForward = bulletin_3.saveAMSFormAndGoForward();

            ApexPages.currentPage().getParameters().put('step' ,'home' );
            CNS_EBulletin bulletin_home = new CNS_EBulletin();

            PageReference pr_home = bulletin_home.checkRedirect();
        }
        Test.stopTest();

    }
	
}
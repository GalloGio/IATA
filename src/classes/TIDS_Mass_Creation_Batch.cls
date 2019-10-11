global class TIDS_Mass_Creation_Batch implements Database.Batchable<SObject>, Database.Stateful {
    
    global String uploadIdentifier {get;set;}
    global List<String> caseNumbers {get;set;}
    global List<ReportRow> rows {get;set;}
    global Map<Id,IATA_ISO_Country__c> countriesMap {get;set;}
    
    global TIDS_Mass_Creation_Batch(String uploadIdentifier) {
        this.uploadIdentifier = uploadIdentifier;
        this.caseNumbers = new List<String>();
        this.rows = new List<ReportRow>();
        this.countriesMap = new Map<Id,IATA_ISO_Country__c>(IATAIsoCountryDAO.getIsoCountries());
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String queryStr = 'SELECT Log__c FROM Technical_Logs__c  WHERE Record__c = \'' + this.uploadIdentifier +'\'';
        return Database.getQueryLocator(queryStr);
    }

    global void execute(Database.BatchableContext BC, List<Technical_Logs__c> scope) {
        Savepoint sp = Database.setSavepoint();
        
        for(Technical_Logs__c record : scope) {
            Map<String,SObject> mapObjs = (Map<String,SObject>) JSON.deserializeStrict(record.Log__c, Map<String,SObject>.class);
            AMS_Pax_Accreditation_Form__c form = (AMS_Pax_Accreditation_Form__c) mapObjs.get('AMS_Pax_Accreditation_Form__c');
            Account acc = new Account();
            acc.Name = form.Account_Name__c;
            acc.IATA_ISO_Country__c = form.Branch_Office_Country__c;
            acc.Location_Type__c = form.Location_Type__c;
            acc.Location_Class__c = form.Location_Class__c;
            acc.Source_System__c = 'NDC TIDS';
            Contact con = (Contact) mapObjs.get('Contact');
            con.AccountId = acc.Id;
            Case cse = new Case();      
            Boolean success = true;      
            String message = 'Successul Creation';
            try {
                insert acc;
                insert con;       

                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule= true;     

                IATA_ISO_Country__c country = this.countriesMap.get(acc.IATA_ISO_Country__c);
                if(country != null) {
                    cse.Region__c = country.Region__c;
                    cse.BSPCountry__c = country.Case_BSP_Country__c;
                }

                cse.AccountId = acc.Id;
                cse.ContactId = con.Id;
                cse.Subject = 'New TIDS';
                cse.Origin = 'NDC TIDs program';
                cse.CaseArea__c = 'Accreditation Products';
                cse.Reason1__c = 'New TIDS';
                cse.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication'); 
                cse.setOptions(dmo);
                insert cse;
                cse = [SELECT Id, CaseNumber, OwnerId FROM Case WHERE Id = :cse.Id];
                form.SAAM_Case__c = cse.Id;
                insert form;
                AMS_OSCAR__c oscar = new AMS_OSCAR__c();
                oscar.Name = cse.CaseNumber;
                oscar.Account__c = acc.Id;
                oscar.Process__c = 'NEW.TIDS.1.0';
                oscar.AMS_Online_Accreditation__c = form.Id;
                oscar.Status__c = 'Open';
                oscar.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'NEW'); 
                oscar.OwnerId = cse.OwnerId;
                insert oscar;
                cse.OSCAR__c = oscar.Id;
                update cse;
            } catch(Exception e) {
                success = false;
                message = e.getMessage();
                Database.rollback(sp);
            }
            ReportRow row = new ReportRow(acc, con, cse, success, message);
            this.rows.add(row);
        }
    }

    global void finish(Database.BatchableContext BC) {
        delete [SELECT Id FROM Technical_Logs__c WHERE Record__c = :this.uploadIdentifier];
        sendReport(this.rows);
    }

    public static void sendReport(List<ReportRow> rows) {
        List<OrgWideEmailAddress> owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@iata.org'];
        String report = 'Account Name, Contact Name, Contact Email, Case Number, Success, Message\n';
        for(ReportRow r : rows) {
            report += r.getCSVRow();
        }

        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
        emailToSend.setTargetObjectId(UserInfo.getUserId());
        emailToSend.saveAsActivity = false;
        emailToSend.setSubject('TIDs Mass Creation Report');
        emailToSend.setOrgWideEmailAddressId(owea[0].Id);
        emailToSend.setPlainTextBody('TIDs Mass Creation - Check attachment with execution results');
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        Blob csvReport = Blob.valueOf(report);
        csvAttc.setFileName('Report TIDs Mass Creation.csv');
        csvAttc.setBody(csvReport);

        emailToSend.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {emailToSend});
    }

    public class ReportRow {
        public String accountName {get;set;}
        public String contactName {get;set;}
        public String contactEmail {get;set;}
        public String caseNumber {get;set;}
        public Boolean success {get;set;}
        public String message {get;set;}

        public ReportRow(Account acc, Contact con, Case cse, Boolean success, String message) {
            this.accountName = getSafeValue(acc.Name);
            this.contactName = getSafeValue(con.FirstName) + ' ' + getSafeValue(con.LastName);
            this.contactEmail = getSafeValue(con.Email);
            this.caseNumber = getSafeValue(cse.CaseNumber);
            this.success = success;
            this.message = getSafeValue(message);
        }

        public String getCSVRow() {
            return this.accountName + ',' + this.contactName + ',' + this.contactEmail + ',' + this.caseNumber + ',' + this.success + ',' + this.message + '\n';
        }

        private String getSafeValue(String val) {
            return (String.isBlank(val) ? '' : val.escapeCSV());
        }
    }
}

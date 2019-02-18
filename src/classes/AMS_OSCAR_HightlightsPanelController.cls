public class AMS_OSCAR_HightlightsPanelController {

    public Boolean saveAction {get; set;}

    //person who submitted the OSCAR
    public AMS_Person__c submitter {get; set;}

    public String iataChangeCode {get; set;}

    public AMS_OSCAR__c theOSCAR {get; set;}

    public Case oscarCase {get; set;}

    public Id oscarId {get; set;}

    public Id caseId {get; set;}

    public AMS_OSCAR_HightlightsPanelController() {

        Id objectId = ApexPages.currentPage().getParameters().get('id');

        if (objectId == null) return;

        //is it an Oscar or a case?
        if (isObjectCase(objectId)) {

            this.oscarCase = fetchCaseFields(objectId, false);
            this.submitter = fetchPersonSubmiter(this.oscarCase.CreatedById);
            this.caseId = this.oscarCase.Id;

            if (this.oscarCase.OSCAR__c != null) {

                this.theOSCAR = fetchOscarFields(this.oscarCase.OSCAR__c);
                this.oscarId = this.theOSCAR.Id;
            }
        } else {

            this.theOSCAR = fetchOscarFields(objectId);
            this.oscarId = this.theOSCAR.Id;

            this.oscarCase = fetchCaseFields(objectId, true);
            this.caseId = this.oscarCase.Id;

            this.submitter = fetchPersonSubmiter(this.oscarCase.CreatedById);
        }

        if (this.oscarId != null) this.iataChangeCode = fetchActiveChangeCode(this.theOSCAR);
    }

    public void saveStatus() {
        try {
            update theOscar;
            this.saveAction = true;
        } catch(DmlException e) {
            /*** AMSU-37 ***/
            String e_message = e.getMessage();
            if(e_message.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                e_message = e_message.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e_message));
            } else {
                ApexPages.addMessages(e);
            }

            System.debug(loggingLevel.ERROR, '____ [cls AMS_OSCAR_HightlightsPanelController - saveStatus] error - ' + e.getMessage());
            this.theOSCAR = fetchOscarFields(this.oscarId);
        } catch(Exception e) {
            //DML Exceptions are sometimes displayed on the page
            if (e.getTypeName() != 'System.DmlException' || !ApexPages.hasMessages()) ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Couldn\'t save changes ' + e.getMessage()));
            System.debug(loggingLevel.ERROR, '____ [cls AMS_OSCAR_HightlightsPanelController - saveStatus] error - ' + e.getMessage());

            this.theOSCAR = fetchOscarFields(this.oscarId);
        }
    }

    public void cancelStatus() {
        return;
    }


    private AMS_OSCAR__c fetchOscarFields(ID oscarId) {

        AMS_OSCAR__c toReturn = null;

        List<AMS_OSCAR__c> oscars = [select Id, Account__c, Status__c, Account__r.IATA_ISO_Country__r.Name, Account__r.IATACode__c,
                                     Account__r.RecordType.Name, Account__r.Name,
                                     Account__r.Identify_as_Key_Customer__c, Account__r.Key_Customer__c,
                                     Owner.Name, CreatedDate from AMS_OSCAR__c where id = : oscarID LIMIT 1];

        if (!oscars.isEmpty()) toReturn = oscars.get(0);

        return toReturn;
    }

    private Id oSCARCaseRecordTypeID {
        get {
            if (oSCARCaseRecordTypeID == null) {
                oSCARCaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
            }
            return oSCARCaseRecordTypeID;
        }
        set;
    }

    private Case fetchCaseFields(ID objectId, Boolean isIdFromOscar) {

        Case toReturn = null;

        List<Case> cases = new List<Case>();

        if (isIdFromOscar) cases =  [SELECT Id, CaseNumber, CreatedBy.Name, CreatedById, CreatedDate, Subject, OSCAR__c FROM Case WHERE OSCAR__c = : objectId AND RecordTypeID = : oSCARCaseRecordTypeID AND ParentId = null LIMIT 1];
        else  cases = [SELECT Id, CaseNumber, CreatedBy.Name, CreatedById, CreatedDate, Subject, OSCAR__c FROM Case WHERE id = :objectId LIMIT 1];

        if (!cases.isEmpty()) toReturn = cases.get(0);

        return toReturn;

    }

    private boolean isObjectCase(Id objectToFind) {

        return AMS_Utils.findObjectNameFromRecordIdPrefix(objectToFind).equalsIgnoreCase('CASE');

    }


    public AMS_Person__c fetchPersonSubmiter(Id userId) {

        AMS_Person__c toReturn = null;

        List<AMS_Person__c> persons = [SELECT Id, Name FROM AMS_Person__c WHERE User__c = : userId LIMIT 1];

        if (!persons.isEmpty()) toReturn = persons.get(0);

        return toReturn;
    }

    private String fetchActiveChangeCode(AMS_OSCAR__c oscar) {

        String toReturn = null;

        List<Agency_Applied_Change_code__c> iataCCodeLst = [select Change_Code__c from Agency_Applied_Change_code__c where Account__c = :oscar.Account__c and Active__c = true ];

        if (!iataCCodeLst.isEmpty()) toReturn = iataCCodeLst.get(0).Change_Code__c;

        return toReturn;
    }
}

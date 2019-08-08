public class SidraLiteHelperForCNS {
    public static final Set<String> ALLOWED_ACCOUNT_STATUS = new Set<String>{'Approved', 'Changes processed'};
    public static final Id RECORDTYPE_IFAP = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
    
    public class SidraLiteException extends Exception {}

    public static void checkBussinessRules(Case parentCase) {
        
        //first time that 'SIDRA Lite Action' is pressed
        if(Date.today() < parentCase.SAAM_Deadline_Date__c) {
            Date deadlineDate = parentCase.SAAM_Deadline_Date__c;
            String deadlineDateStr = deadlineDate.month() + '/' + deadlineDate.day() + '/' + deadlineDate.year();
            throw new SidraLiteException('Sidra Lite case cannot be created before Deadline Date: ' + deadlineDateStr);
        }
    }

    public static Case createDummyCaseFirstNonCompliance(Case parentCase) {
        //parentCase.New_IFAP_Deadline_date__c = Date.today() + 7;
        //update parentCase;

        Case newCase = new Case();
        newCase.RecordTypeId = SidraLiteManager.RECORDTYPE_SIDRA_LITE;
        newCase.Subject = 'SIDRA Lite – CNS Collection';
        newCase.ParentId = parentCase.Id;
        newCase.Region__c = parentCase.Region__c;
        newCase.BSPCountry__c = parentCase.BSPCountry__c;
        newCase.BSP_CASS__c = 'CASS';
        //newCase.Priority = 'Normal';
        newCase.AccountId = parentCase.AccountId;
        newCase.ContactId = parentCase.ContactId;
        newCase.Origin = 'IATA Internal User';
        newCase.Status = 'Open';
        newCase.SIDRA_Lite_Reason__c = 'CNS Collection';
        newCase.NOT_Date__c = Date.today();
        //newCase.NOT_Approval__c ='Approved';
        newCase.CNSCase__c = true;

        return newCase; 
    }


    public static list<Case> updateSidraLiteAndParent(Case parentCase, Case childCase) {

        //second time that 'SIDRA Lite Action' is pressed
        if(Date.today() < parentCase.New_IFAP_Deadline_date__c) {
            Date deadlineDate = parentCase.New_IFAP_Deadline_date__c;
            String deadlineDateStr = deadlineDate.month() + '/' + deadlineDate.day() + '/' + deadlineDate.year();
            throw new SidraLiteException('Sidra Lite case cannot be updated before New Deadline Date: ' + deadlineDateStr);    
        }

        //third time that 'SIDRA Lite Action' is pressed
        if(childCase.Propose_Default__c != null) {
            throw new SidraLiteException('Second non payment action has already been taken from this case. There are no more actions to be taken on SIDRA Lite case.');
        }

        childCase.Propose_Default__c = Date.today();
        //childCase.Termination_Reason__c = 'Non Payment';

        list<Case> listUpdate = new list<Case>();
        listUpdate.add(childCase);
        listUpdate.add(parentCase);

        return listUpdate;
    }


    public static void throwPopUpMessage(Case parentCase) {
        throw new WSSidraLite.ShowConfirmationException('Update child Sidra Lite case, continue?');
    }

}
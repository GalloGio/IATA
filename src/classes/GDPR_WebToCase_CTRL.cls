global without sharing class GDPR_WebToCase_CTRL {
    
    @AuraEnabled
    public static List<PickListWrapper> getDataPrivacyRightsPickValues(){
        Schema.DescribeSObjectResult sobjectDescribe = Schema.getGlobalDescribe().get('Case').getDescribe();
        List<Schema.PicklistEntry> pickListValues = sobjectDescribe.fields.getMap().get('Data_Privacy_Rights__c').getDescribe().getPickListValues();
        
        List<PickListWrapper> options = new List<PickListWrapper>();
        
        PickListWrapper emptySelection = new PickListWrapper();  
        emptySelection.label = '-- Select One --';
        emptySelection.value = null;
        emptySelection.checked = true;
        options.add(emptySelection);
        
        for (Schema.PicklistEntry a : pickListValues) {
            PickListWrapper selection = new PickListWrapper();  
            selection.label = a.getLabel();
            selection.value = a.getValue();
            selection.checked = false;
            options.add(selection);
        }
        return options;
    }
    
    @AuraEnabled
    global static Case createEmptyCase(String creatorEmail){
        Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'GDPR_Request');
        String contactId = null;
        String cId = null;
        String userId = UserInfo.getUserId();
        Boolean isRegisteredUser = false;

        User userAux = [SELECT Id, ContactId,Contact.Data_Protection_Officer__c FROM User WHERE Id = :userId];
        if(userAux != null && userAux.ContactId != null){
            contactId = userAux.ContactId;
            isRegisteredUser = true;
        }else {
            list<Contact> contactAux = [SELECT Id FROM Contact WHERE Email = :creatorEmail];
            if(! contactAux.isempty()) cId = String.valueOf(contactAux[0].Id);
        }
        System.debug('cid - '+cId);
        Case caseAux = new Case();
        caseAux.RecordTypeId = rtId;
        caseAux.ContactId = contactId != null ? contactId:cId;
        caseAux.SuppliedEmail = creatorEmail;
        caseAux.Origin = 'Portal';
        caseAux.Do_Not_Send_Notification__c = !isRegisteredUser;
        
        return caseAux;
    }
    
    @AuraEnabled
    global static ReturnWrapper submitCase(String caseJSON, Boolean isDPOCase){
        ReturnWrapper returnwrapper = null;
        
        Savepoint sp = Database.setSavepoint();
        system.debug('caseJSON: ' + caseJSON);
        system.debug('isDPOCase: ' + isDPOCase);
        Case caseAux = (Case)JSON.deserialize(caseJSON, Case.class);
        
        if(isDPOCase){
            caseAux.DPO_Owner__c = caseAux.ContactId;
        }
        
        try {
			Database.insert(caseAux);
            returnwrapper = new ReturnWrapper('', 'SUCCESS', '');
        } catch (Exception e) {
            Database.rollback(sp);
            returnwrapper = new ReturnWrapper(e.getMessage(), 'ERROR', '');
        }
        
        return returnwrapper;
        
    }
    
    @AuraEnabled
    global static Boolean checkIfContactIsDPO(){
        String contactId = null;
        String userId = UserInfo.getUserId();

        User userAux = [SELECT Id, ContactId,Contact.Data_Protection_Officer__c FROM User WHERE Id = :userId];
        if(userAux != null && userAux.ContactId != null){contactId = userAux.ContactId;}
        
        
        if(contactId == null || contactId == '' || userAux.contact.Data_Protection_Officer__c == null ){return null;}
        
        Boolean isDPO = userAux.contact.Data_Protection_Officer__c;
        
        return isDPO;
    }
    
    global class PickListWrapper{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public Boolean checked;
        
        public PickListWrapper (){}
    }
    
    global class ReturnWrapper {
        @AuraEnabled
        public String message;
        @AuraEnabled
        public String severity;
        @AuraEnabled
        public String extraDetails;
        
        public ReturnWrapper(String messageAux, String severityAux, String extraDetailsAux){
            this.message = messageAux;
            this.severity = severityAux;
            this.extraDetails = extraDetailsAux;
        }
    }

}
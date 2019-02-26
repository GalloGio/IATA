global class ANG_RiskEventHistoryExtension {


    public Id deleteRecordId {get; set;}

	private Account acc;

    private Id accId{
        get{
            return this.acc.Id;
        }
    }

    private List<ANG_Agency_Risk_Event__c> recordList{
        get{
            Set<String> fieldsToQuery = new Set<String>{'Id', 'Name', 'ANG_AccountId__c', 'ANG_Source_Id__c', 'ANG_Risk_Type__c', 'ANG_Risk_ID__c', 'ANG_Event_Status__c'};
            fieldsToQuery.addAll(fieldNames);
            return Database.query('SELECT '+String.join(new List<String>(fieldsToQuery), ', ')+' FROM ANG_Agency_Risk_Event__c WHERE '+(acc.Location_Type__c == AMS_Utils.HE ? 'ANG_HE_AccountId__c' : 'ANG_AccountId__c')+' = :accId ORDER BY ANG_Issued_Date__c DESC, CreatedDate DESC');
        }
    }

    public List<String> fieldNames{
        get{
            if(fieldNames == null){
                fieldNames = new List<String>();
                for(Schema.FieldSetMember field : SObjectType.ANG_Agency_Risk_Event__c.FieldSets.RelatedList.getFields()) fieldNames.add(field.getFieldPath());
            }
            return fieldNames;
        }
        private set;
    }

    public Map<String, Boolean> isNumberField{
        get{
            if(isNumberField == null){
                isNumberField = new Map<String,Boolean>();
                for(String fieldName : fieldNames){

                    String fieldType = SObjectType.ANG_Agency_Risk_Event__c.fields.getMap().get(fieldName).getDescribe().getType().name();
                    
                    isNumberField.put(fieldName, (fieldType == 'CURRENCY' || fieldType == 'DOUBLE' || fieldType == 'PERCENT' || fieldType == 'INTEGER'));
                }
            }
            return isNumberField;
        }
        private set;
    }

    public ANG_RiskEventHistoryPagination paginator{
        get{
            if(paginator == null){
                paginator = new ANG_RiskEventHistoryPagination(recordList);
            }
            return paginator;
        }
        private set;
    }

    public ANG_RiskEventHistoryExtension(ApexPages.StandardController stdController) {
         if (!Test.isRunningTest()) stdController.addFields(new List<String>{'Location_Type__c', 'ANG_Accreditation_Model__c'});
        this.acc = (Account)stdController.getRecord();
    }

    public List<ANG_RiskEventHistoryPagination.RiskEvent> getRecords() {
        return paginator.getRecords();
    }

    public void resetPaginator() {
        paginator = null;
    }

    @RemoteAction
    global static void deleteRecord(Id recId) {
        delete new ANG_Agency_Risk_Event__c(Id = recId);
    }
}

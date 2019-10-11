public class KanbanBoardController {

    @AuraEnabled
    public static kanbanWrap getKanbanWrap(String objName, String[] objFields, String kanbanField, String kanbanColumns, String searchText) {
        List<String> lstPickvals = KanbanColumns__c.getAll().get(kanbanColumns).Headers__c.split(';');
        System.debug('____ [cls KanbanBoardController - getKanbanWrap] lstPickvals : ' + lstPickvals);
        
        String query = 'SELECT Id, ';
        for(String s:objFields){
            query += s+' ,';
        }
        query = query.removeEnd(',');
        query += ' FROM ' + objName;
        query += ' WHERE RecordTypeId = \'' + RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ClaimEU261') + '\'';

        if(searchText != '' && searchText != null)
            query += ' AND CaseNumber LIKE \'' + searchText + '%\'';

        System.debug('____ [cls KanbanBoardController - getKanbanWrap] query : ' + query);
        
        return new kanbanWrap(Database.query(query), lstPickvals);
    }
    
    @AuraEnabled
    public static String getUpdateStage(Id recId, String kanbanField, String kanbanNewValue) {
        SObject o1 = recId.getSObjectType().newSObject(recId);
        o1.put(kanbanField,kanbanNewValue);
        update o1;
        return 'Success';
    }  
    
    public class kanbanWrap{
        @AuraEnabled
        public List<sObject> records {get;set;}
        @AuraEnabled
        public List<String> pickVals {get;set;}
        
        public kanbanWrap(List<sObject> recs, List<String> pVals){
            this.records = recs;
            this.pickVals = pVals;
        }
    }
}
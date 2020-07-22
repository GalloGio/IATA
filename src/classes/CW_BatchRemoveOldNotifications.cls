/**
 * @description		Batch class to remove old notifications
 *
 * Edit Log:
 * @history			2020/05/11  |  sf-646  |  Creation.
 */
public with sharing class CW_BatchRemoveOldNotifications implements Database.Batchable<SObject> {
    final static String RT_NOTIFICATION_PRIVATE_AREA = CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA;
	final static Datetime dateDelimited = Datetime.now().addDays(-30);
    /**
     * @description		Method to collect the records or objects to be passed to the interface method execute
     * @param			context <Database.BatchableContext>
     * @return			Database.QueryLocator - prepared query
     */
    public Database.QueryLocator start(Database.BatchableContext context)
    { 
        String query = 'SELECT Id FROM ICG_Notification__c WHERE RecordTypeId =: RT_NOTIFICATION_PRIVATE_AREA AND Read__c = true AND CreatedDate <=: dateDelimited';
        return Database.getQueryLocator(query);
    }
 
    /**
     * @description		Description of the method
     * @param			context <Database.BatchableContext>
     * @param			scope <List of objects retrieved by query>
     */
    public void execute(Database.BatchableContext context, List<ICG_Notification__c> scope)
    {
        if(scope.size() > 0){
            delete scope;
        }
    }  

    /**
     * @description		This method is called after all batches are processed
     * @param			context <Database.BatchableContext>
     */
    public void finish(Database.BatchableContext context)
    {
        System.debug(LoggingLevel.FINE,'::::getStructurfinisheFacilities - doNothing ');
    }

}
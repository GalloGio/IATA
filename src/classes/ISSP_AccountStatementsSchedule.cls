/**
 */
global class ISSP_AccountStatementsSchedule implements Schedulable {

    public static final Notification_template__c NOTIFICATION_TEMPLATE = [
        Select Type__c, Subject__c, Notification_color__c, Name, Message__c, Master_Notification_template__c, Language__c, Id, Expire_in_days__c, Due_date__c, DDS_Update_Request__c, Alert_Contact_By_Email__c, Admins_Users__c, CriticalNotification__c,
            (Select Type__c, Subject__c, Notification_color__c, Name, Message__c, Master_Notification_template__c, Language__c, Id, Expire_in_days__c, Due_date__c, DDS_Update_Request__c, Alert_Contact_By_Email__c, Admins_Users__c, CriticalNotification__c
            from Notification_templates__r)
        From Notification_template__c
        Where Id = :ISSP_Notifications_Trigger__c.getValues('Account Statements').Notification_Template_Id__c
        Limit 1
    ];

    public Integer elemsPerBatch;
    public String region;
    public Integer daysToRemittance;

    public ISSP_AccountStatementsSchedule () {
        this.elemsPerBatch = 1;
        this.region = '';
        this.daysToRemittance = 1;
    }

    public ISSP_AccountStatementsSchedule (String region, Integer daysToRemittance) {
        this.elemsPerBatch = 1;
        this.region = region;
        this.daysToRemittance = daysToRemittance;
    }

    global void execute(SchedulableContext ctx) {
        launchBatch();
    }

    public void launchBatch() {

        // date to filter the remmitance date
        // by default is today + 1 day (so TOMORROW) but it can be changed
        DateTime remittanceDate = Date.today().addDays(this.daysToRemittance);
        String remittanceDateStr = remittanceDate.formatGMT('yyyy-MM-dd');

        /**
            Find all contacts related to accounts
            with right to access to Account statements application in Portal
            and have accepted terms and conditions
        **/
        ISSP_NotificationBatch bc = new ISSP_NotificationBatch();
        bc.Query = 'SELECT ' + String.join(ISSP_NotificationUtilities.getAllContactFields(), ',')
        + ' FROM Contact '
        + ' WHERE Account.Status__c IN (\'Approved\',\'Changes Processed\',\'Listed\')'
        + ' AND AccountId in ('
        + '   Select Account__c'
        + '   From Account_Statement__c'
        + '   where Remittance_Date__c = ' + remittanceDateStr + ')'
        + ' And id in ('
        + '   Select contact__c'
        + '   From Portal_Application_Right__c'
        + '   Where Right__c = \'Access Granted\''
        + '   And Enable_Notifications__c = true'
        + '   And Portal_Application__r.Name =  \'' + ISSP_Ctrl_AccountStatements.APP_NAME + '\')';
        //+ '   And Terms_Acceptance__c = true'
        if ( this.region != null && this.region != '' ) {
        	bc.Query += '   And Account.Region_Formula__c =  \'' + this.region + '\'';
        }

        bc.NotificationTemplate = NOTIFICATION_TEMPLATE;
        bc.MessagesByGroupMap = null;
        bc.ContactGroupField = null;
        Database.executeBatch(bc, elemsPerBatch);
    }
}
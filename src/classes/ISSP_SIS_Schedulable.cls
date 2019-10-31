public class ISSP_SIS_Schedulable implements Schedulable {

    private List<Id> listRecordId {get;set;}
    private String methodName {get;set;}
    
    public ISSP_SIS_Schedulable(List<Id> listRecordId, String methodName) {
        this.listRecordId = listRecordId;
        this.methodName= methodName;
    }
    
    public void execute(SchedulableContext sc) {
        if(methodName == 'invokeSisModifyUser'){
            ISSP_WS_Utilities.invokeSisModifyUser(listRecordId);
        }
        else if(methodName == 'invokeSisDeactivateUsers'){
            ISSP_WS_Utilities.invokeSisDeactivateUsers(listRecordId);
        }
        else if(methodName == 'invokeSisActivateUsers'){
            ISSP_WS_Utilities.invokeSisActivateUsers(listRecordId);
        }
        else if(methodName == 'invokeCreateAccount'){
            ISSP_WS_Utilities.invokeCreateAccount(listRecordId);
        }
        else if(methodName == 'invokeUpdateAccount'){
            ISSP_WS_Utilities.invokeUpdateAccount(listRecordId);
        }
        else if(methodName == 'invokeGiveSISAppToAccountUsers'){
            ISSP_WS_Utilities.invokeGiveSISAppToAccountUsers(listRecordId);
        }
        System.abortJob(sc.getTriggerId());
    }

    public static String getNextFireTime(){
        Datetime now = Datetime.now().addSeconds(3);
        String hour = String.valueOf(now.hour());
        String min = String.valueOf(now.minute()); 
        String ss = String.valueOf(now.second());
        String day = String.valueOf(now.day());
        String month = String.valueOf(now.month());
        String year = String.valueOf(now.year());
        //parse to cron expression
        return ss + ' ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;    
    }
}
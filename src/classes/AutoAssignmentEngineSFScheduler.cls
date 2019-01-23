global class AutoAssignmentEngineSFScheduler implements Schedulable{
    global void execute(SchedulableContext SC) {

        Integer MAX_BATCHES = 5;
        Integer iRunningBatchJobs = [
            select count()
            from AsyncApexJob
            where JobType = 'BatchApex'
            and status in ('Queued','Processing','Preparing')
        ];

        if (iRunningBatchJobs < MAX_BATCHES)
        {
        AutoAssignmentEngineSF btchProc = new AutoAssignmentEngineSF();
        Database.executeBatch(btchProc, 1);
        }   

        datetime nextScheduleTime = system.now().addMinutes(10);
        string minute = string.valueof(nextScheduleTime.minute());
        string second = string.valueof(nextScheduleTime.second());
        string cronvalue = second + ' ' + minute + ' * * * ?' ;
        string jobName = 'AutoAssignmentEngine ' + nextScheduleTime.format('hh:mm');        
 
        system.schedule(jobName, cronvalue , new AutoAssignmentEngineSFScheduler());

        if (sc != null)
        system.abortJob(sc.getTriggerId());     
    } 
}
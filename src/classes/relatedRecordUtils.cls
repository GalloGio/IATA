//use a public class so it can be called from a trigger
public class relatedRecordUtils{
//create a static method taking a list of ids as an argument using an ID list allows it to be more flexible
    public static void closeTasks(id[] records){
        //declare a list of tasks to hold tasks to be updated
        List<task> opentasks = new List<task>();
        //select a generic closed status, select statment could be replaced with a specific string if required
        TaskStatus closedStatus = [Select MasterLabel from TaskStatus where IsClosed = true Limit 1];
        /*use a SOQL for loop to select all related open tasks for any records in the passed in ID list*/
        for(task t:[Select id, status from Task Where WhatId IN:records and IsClosed = false]){
            //set status to closed for each record
            t.Status = closedStatus.MasterLabel;
            /*add updated tasks to list to be updated later doing a DML statement 
            here would cause code to hit governor limits*/
            opentasks.add(t);
            
        }
        //DML outside of all loop structures
        update opentasks;
    }
}
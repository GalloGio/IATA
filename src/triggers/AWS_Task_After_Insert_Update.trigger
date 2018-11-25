/**  
  * Description: After Insert process is supposed to happened once, if allowed the trigger will
  * run the Storage Case creation in Future mode because of the callout.
*/
trigger AWS_Task_After_Insert_Update on AWS_Task__c (after insert, after update) {
  //After Insert  
  if (Trigger.IsInsert)
  for(AWS_Task__c o:Trigger.new){
     if (o.Task_Campaign__c!=null ) {
       EBC_Manage_Task.StaticCreateAWSTask(false,test.isRunningTest(), o.Task_Campaign__c, o.Id); 
      }
  }  
  if (Trigger.IsUpdate)
  for(AWS_Task__c o:Trigger.new){
     if (o.Task_Campaign__c!=null && o.Task_Status__c=='RESUME SEND EMAILS') {
       EBC_Manage_Task.StaticCreateAWSTask(false,test.isRunningTest(), o.Task_Campaign__c, o.Id); 
      }
  }  
}
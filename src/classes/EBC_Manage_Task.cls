/* Description : Manages the AWS tasks 
 * Author : ABdellah Bellahssan
 * Requirements: callout made on future by trigger
*/

public class EBC_Manage_Task {
    
  @future(callout=true)  
  public static void StaticCreateAWSTask(Boolean isBatch, Boolean isTest,  String CampaignId, String TaskId){
    EBC_Manage_Task newfunc = new EBC_Manage_Task();
    newfunc.CreateAWSTask( isBatch, isTest, CampaignId, TaskId);  
  } 
    
  public  EBC_Manage_Task(){
  }
  
  public void  CreateAWSTask(Boolean isBatch, Boolean isTest,  String CampaignId, String TaskId){
      AWS_Manage_Task new_task = new AWS_Manage_Task();
      new_task.execute(false,CampaignId, 'campaign_batch');
    
  }
}
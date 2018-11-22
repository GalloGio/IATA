public class UpdateAgentLogOffTime {
    @InvocableMethod(label='Update Agents Log Off Time')
    public static void AgentUpdateTime(List<Id> agentIds)
    {
        List<Agents__c> agents =[select Id, Exact_Log_Off_Time__c, Log_Off_Time_After_Timeout__c, Region__c from Agents__c
                          where Id in :agentIds];
        system.debug('+++ im running for agents '+agents);
        for(Agents__c agent:agents) {
            if(agent.Exact_Log_Off_Time__c == null || agent.Log_Off_Time_After_Timeout__c == null) {
                agent.Exact_Log_Off_Time__c = DateTime.now();
                // get the timeout from Case_Agent_To_Queue_Assignment_Timeout__mdt
                Case_Agent_To_Queue_Assignment_Timeout__mdt timeout = [SELECT Timeout_In_Minutes__c FROM Case_Agent_To_Queue_Assignment_Timeout__mdt
                                                                       WHERE Region__c=:agent.Region__c LIMIT 1];
                if(timeout != null)
                    agent.Log_Off_Time_After_Timeout__c = DateTime.now().addMinutes(timeout.Timeout_In_Minutes__c.intValue());
                else {
                    Case_Agent_To_Queue_Assignment_Timeout__mdt defaultTimeout = [SELECT Timeout_In_Minutes__c FROM Case_Agent_To_Queue_Assignment_Timeout__mdt
                                                                                  WHERE DeveloperName='Default_Timeout'];
                    agent.Log_Off_Time_After_Timeout__c = DateTime.now().addMinutes(defaultTimeout.Timeout_In_Minutes__c.intValue());

                }
            }
        }
        
        update agents;
   }
}
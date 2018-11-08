public class UpdateAgentLogOffTime {
    @InvocableMethod(label='Update Agents Log Off Time')
    public static void AgentUpdateTime(List<Id> agentIds)
    {
        List<Agents__c> agents =[select Id from Agents__c
                          where Id in :agentIds];
        for(Agents__c agent:agents) {
            // TODO: utilize custom metadata for timeouts
            agent.Exact_Log_Off_Time__c = DateTime.now();
        	agent.Log_Off_Time_After_Timeout__c = DateTime.now().addMinutes(20);
        }
        
        update agents;
   }
}
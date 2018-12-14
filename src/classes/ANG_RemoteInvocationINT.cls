public interface ANG_RemoteInvocationINT {

	void doSanityCheck(Set<Remote_Invocation__c> remoteInvocationsIdToProcess);
	
	void doProcess(Set<Remote_Invocation__c> remoteInvocationsIdToProcess);

}
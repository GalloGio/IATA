trigger LVA_AfterChatTrigger on LiveChatTranscript (after insert) {
	LVA_AfterChatTriggerHandler.ProcessLiveChatTranscript(Trigger.New);
}
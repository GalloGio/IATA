trigger ICG_Account_Role_Capability_Assignment on ICG_Account_Role_Capability_Assignment__c(before insert, after insert) {
	new CW_ICG_Acc_Role_Cap_Assignment_Handler();
}
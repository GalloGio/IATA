trigger Account_Contact_Role on Account_Contact_Role__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	
	if (!AMS_TriggerExecutionManager.checkExecution(Account_Contact_Role__c.getSObjectType(), 'Account_Contact_Role')) { return; }
	
	if(trigger.isBefore){
		if(trigger.isInsert || trigger.isUpdate){

			Id tipRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Payment_Provider_Contact');		   
		   
			
			set<string> accRoleIdSet= new set<string>();
			set<string> companyCodeSet= new set<string>();
			list<Account_Contact_Role__c> acrList= new list<Account_Contact_Role__c>();

			for(Account_Contact_Role__c acr:trigger.new){

				if(acr.RecordTypeId == tipRT){
					acr.UniqueKey__c = TIP_Utils.AccountContactRoleGenerateUniquekey(acr);
				}


				if(trigger.isInsert && acr.RecordTypeId == PortalIftpUtils.ACC_CONT_ROLE_RT_ITP){
				   
					//ITP -On inserting new account contact role for IFTP,generates unique key to prevent duplicated employee codes within the ITP   
					acrList.add(acr);
					accRoleIdSet.add(acr.account_role__c);
					companyCodeSet.add(acr.company_code__c);
				
				}
			}
			
			//ITP -checks for existing values
			if(!acrList.isEmpty()){
				set<string> existingCodeSet= new set<string>();
				//retrieves possible dpublicated values for the records being inserted
				for(Account_Contact_Role__c acr:[SELECT account_role__c,company_code__c FROM Account_Contact_Role__c WHERE RecordTypeId =:PortalIftpUtils.ACC_CONT_ROLE_RT_ITP AND account_role__c in :accRoleIdSet AND  company_code__c in :companyCodeSet]){
					existingCodeSet.add(acr.account_role__c+acr.company_code__c);
				}
				
				//looking for matches on duplicate values
				for(Account_Contact_Role__c actr:acrList){
					if(existingCodeSet.contains(actr.account_role__c+actr.company_code__c)){
						actr.addError('Duplicate Employee Code Detected');
					}
				}
			}
		   

			Account_Contact_Role_Helper.generateGadmUniqueKey(Trigger.new);
			Account_Contact_Role_Helper.checkForGadmUserRole(Trigger.new);
		}
	}

	 
	if(trigger.isAfter){
		if(trigger.isInsert){
			set<id> accContRlIdList = new set<id>();
			list<Account_Contact_Role__c> accContRlIdListToUpdate = new list<Account_Contact_Role__c>();
			for(Account_Contact_Role__c acr:trigger.new){
				if(acr.RecordTypeId == PortalIftpUtils.ACC_CONT_ROLE_RT_ITP){
				   if(acr.Company_Code__c =='TC'){					  
					   accContRlIdListToUpdate.add(new Account_Contact_Role__c(
							id=acr.id,
							Company_Code__c ='TC-' + acr.Name.split('-').get(1).replaceFirst('^0+','')//generate employee code
					   ));
					}

					accContRlIdList.add(acr.id);
				}
			}
			
			//update the employee code with the definitive one
			if(accContRlIdListToUpdate.size()>0){
				update accContRlIdListToUpdate;
			}		   
			if(accContRlIdList.size()>0){
				portalIftpHistoryManagement.generateMassIFTPHistoryStartWorkingForITP (accContRlIdList);
			}		   
		}

		//Trigger the platform events if bypass custom permission is not assigned
		if(!FeatureManagement.checkPermission('Bypass_Platform_Events')){
			ShareObjectsToExternalUsers.shareObjectsByRoleOnAccountContactRoleChange(Trigger.new ,Trigger.oldMap);
			if((Limits.getLimitQueueableJobs() - Limits.getQueueableJobs()) > 0 && !System.isFuture() && !System.isBatch()) {
				System.enqueueJob(new PlatformEvents_Helper((trigger.isDelete?trigger.OldMap:Trigger.newMap), 'AccountContactRole__e', 'Account_Contact_Role__c', trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete));
			} else {
				PlatformEvents_Helper.publishEvents((trigger.isDelete?trigger.OldMap:Trigger.newMap), 'AccountContactRole__e', 'Account_Contact_Role__c', trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete);
			}
		}
	}
	
}

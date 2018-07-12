/*
 * @author: Constantin BUZDUGA, blue-infinity
 * @description: This trigger only handles ICCS Cases with the "FDS ASP Management" record type and is used to update the fields Authorized Signatories, Ongoing Request for Documents
 *      and Collection Case Indicator at Account level when the case is closed.
 */

trigger trgICCS_ASP_CaseClosed on Case (after insert, after update) {
	List<Account> lstAccountsToUpdate = new List<Account>();

	Id RT_ICCS_ASP_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ASP_Management') ;
	Id RT_ICC_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Invoicing_Collection_Cases') ;

	Set <Id> accountNotificationIdSet = new Set <Id>(); //TF

	for (Case c : Trigger.new) {
		if (c.AccountId != null) {
			// If the Case has just been closed
			if ( c.RecordTypeId == RT_ICCS_ASP_Id  &&  c.isClosed  &&  !Trigger.oldMap.get(c.Id).isClosed && c.AccountId != null ) {
				Account a = new Account(Id = c.AccountId, Document_Std_Instruction__c = c.Process_Approved__c, Ongoing_Request_for_Documents__c = false);
				lstAccountsToUpdate.add( a );
			}

			// If the case has just been created and is open, check the Ongoing Request for Documents box at account level
			if ( c.RecordTypeId == RT_ICCS_ASP_Id && !c.isClosed && Trigger.isInsert) {
				Account a = new Account(Id = c.AccountId, Ongoing_Request_for_Documents__c = true);
				lstAccountsToUpdate.add( a );
			}


			// Set / unset the Collection Case Indicator
			if (c.RecordTypeId == RT_ICC_Id && c.CaseArea__c == 'Collection' && c.Reason1__c == 'Debt Recovery') {

				// TF - Open debts notification to Admins
				if (Trigger.isInsert) {
					if (!ISSP_UserTriggerHandler.preventOtherTrigger) {
						accountNotificationIdSet.add(c.AccountId);//TF
						system.debug('adding account for insert: ' + c.AccountId);
					}
				} else if (Trigger.isUpdate) {
					Case oldCase = trigger.oldMap.get(c.Id);
					if (c.AccountId != oldCase.AccountId) {
						if (!ISSP_UserTriggerHandler.preventOtherTrigger) {
							accountNotificationIdSet.add(c.AccountId);//TF
							system.debug('adding account for update: ' + c.AccountId);
						}
					}
				}

				if (c.IsClosed && c.Has_the_agent_paid_invoice__c != null && c.Has_the_agent_paid_invoice__c != 'Not paid') {
					Account a = new Account(Id = c.AccountId, Collection_Case_Indicator__c = '');
					lstAccountsToUpdate.add( a );
				} else {
					Account a = new Account(Id = c.AccountId, Collection_Case_Indicator__c = 'Pending dues');
					lstAccountsToUpdate.add( a );
				}
			}
		}
	}

	if (!lstAccountsToUpdate.isEmpty()) {
		update lstAccountsToUpdate;

		//+++TF
		if (!accountNotificationIdSet.isEmpty()) {
			ISSP_UserTriggerHandler.preventOtherTrigger = true;
			system.debug('accountNotificationIdSet: ' + accountNotificationIdSet);
			List <Contact> contactNotificationList =
			    [SELECT Id FROM Contact
			     WHERE User_Portal_Status__c = 'Approved Admin'
			                                   AND (AccountId IN :accountNotificationIdSet
			                                        OR Account.Top_Parent__c IN :accountNotificationIdSet)];
			if (!contactNotificationList.isEmpty()) {
				if (ISSP_Notifications_Trigger__c.getValues('Outstanding invoice') != null) {
					String templateId = ISSP_Notifications_Trigger__c.getValues('Outstanding invoice').Notification_Template_Id__c;
					system.debug('templateId: ' + templateId);
					if (templateId != '' && templateId != null) {
						List<Notification_template__c> lstNotificationTemplate = [SELECT Name, Message__c, Admins_Users__c,
						                               Alert_Contact_By_Email__c, CriticalNotification__c,
						                               Due_date__c, Expire_in_days__c, Language__c,
						                               Master_Notification_template__c, Notification_color__c,
						                               Subject__c, Type__c
						                               FROM Notification_template__c
						                               WHERE Id = :templateId];
						if (!lstNotificationTemplate.isEmpty()) {
							system.debug('sending notification to: ' + contactNotificationList);
							Notification_template__c notificationTemplate = lstNotificationTemplate[0];
							ISSP_NotificationUtilities.sendNotification(contactNotificationList, notificationTemplate, null, null);
						}
					}
				}
			}
		}
		//---TF
	}

	if (Trigger.isUpdate) {
		//Hold list of IEC_Subscription_History record to be inserted
		List<IEC_Subscription_History__c> IEC_SubHistory_Lst_ToInsert = new List<IEC_Subscription_History__c>();
		//Hold list of Cases record to be Updated
		List<Case> CaseToUpdate_Lst = new List<Case>();


		for (Case c : Trigger.new) {

			Id CaseSAAMId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');//SAAM
			//If the case is Closed and Matches the following cretiria
			if ( c.RecordTypeId == CaseSAAMId  &&
			        c.Status == 'Closed' &&  Trigger.oldMap.get(c.Id).Status != 'Closed' &&
			        c.CaseArea__c == 'Accreditation Products' &&
			        c.Reason1__c == 'PAX/CARGO Certificate' &&
			        c.Product_Category_ID__c != null && !c.Product_Category_ID__c.contains('Triggered') &&
			        Integer.valueOf(c.QuantityProduct__c) > 0
			   ) {
				//Creates new IEC_Subscription_History
				IEC_Subscription_History__c  IEC_SubHistory  = new IEC_Subscription_History__c  () ;
				IEC_SubHistory.Related_Account__c			 = c.Account_Concerned__c ;
				IEC_SubHistory.Rate_Plan_Quantity__c		 = Integer.valueOf(c.QuantityProduct__c) ;
				IEC_SubHistory.Related_Contact__c			 = c.ContactId ;
				IEC_SubHistory.Billing_Account_Number__c	 = c.IATACodeProduct__c ;
				IEC_SubHistory.Invoice_Number__c			 = 'put any value for the moment';
				IEC_SubHistory.Billing_Street__c			 = c.Account_Concerned__r.BillingStreet ;
				IEC_SubHistory.Billing_City__c				 = c.Account_Concerned__r.BillingCity ;
				IEC_SubHistory.Billing_State__c				 = c.Account_Concerned__r.BillingState ;
				IEC_SubHistory.Billing_Zip__c				 = c.Account_Concerned__r.BillingPostalCode ;
				IEC_SubHistory.Billing_Country__c			 = c.Account_Concerned__r.BillingCountry ;

				List <Product_Category__c> ProductCategorytList = [SELECT Id, Name, Active__c, Short_Description__c
				        FROM  Product_Category__c
				        WHERE ID = : c.Product_Category_ID__c
				                   ORDER BY Name
				                                                  ];

				IEC_SubHistory.Purchased_Product_Category__c = ProductCategorytList != null ? ProductCategorytList[0].Id : '' ;
				IEC_SubHistory.Purchased_Product_SKU__c		 = ProductCategorytList != null ? ProductCategorytList[0].Short_Description__c : '' ;
				system.debug('XOXO IEC_SubHistory ===>>>' + IEC_SubHistory);
				//Add new IEC_Subscription_History record to List
				IEC_SubHistory_Lst_ToInsert.add(IEC_SubHistory);


				//Update the Case record to indecate that this specific case is been handled
				if (c.Product_Category_ID__c != null && !c.Product_Category_ID__c.contains('Triggered')) {
					Case cc = new Case(Id = c.Id , Product_Category_ID__c = c.Product_Category_ID__c + '_Triggered');
					CaseToUpdate_Lst.add(cc);
				}
			}
		}
		//Insert IEC_Subscription_History
		if (IEC_SubHistory_Lst_ToInsert != null && !IEC_SubHistory_Lst_ToInsert.isEmpty()) {
			insert IEC_SubHistory_Lst_ToInsert ;
		}
		//Update Cases
		if (CaseToUpdate_Lst != null && !CaseToUpdate_Lst.isEmpty()) {
			update CaseToUpdate_Lst ;
		}
	}
}
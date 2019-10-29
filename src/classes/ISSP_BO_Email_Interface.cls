global class ISSP_BO_Email_Interface implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();

		Messaging.InboundEmail.BinaryAttachment[] bAttachments = email.BinaryAttachments;
		system.debug('HERE');
		if (bAttachments != null){
			system.debug('HAS ATTACHMENTS');
			
			//Before creating report, check if one has already been created in the same day
			/*INC264882
			Date todayDate = System.Today();
			List <ISSP_BO_Report__c> reportList = [SELECT Id FROM ISSP_BO_Report__c WHERE Report_Date__c = :todayDate];
			if (!reportList.isEmpty()){
				system.debug('ending because there is already a report for this day');
				return result;
			}*/
			
			ISSP_BO_Report__c newReport = new ISSP_BO_Report__c(Report_Date__c = System.Today());
			insert newReport;
			system.debug('INSERTED REPORT');
			Attachment newAttach = new Attachment();
			newAttach.ParentId = newReport.Id;
			newAttach.Body = bAttachments[0].Body;  
            newAttach.Name = bAttachments[0].fileName;
            insert newAttach;
            system.debug('INSERTED ATTACH');
            
            //send notification to BO Report subscribers
            List <Portal_Application_Right__c> accessList = [SELECT Id, Contact__c FROM Portal_Application_Right__c
															WHERE Portal_Application__r.Name = 'Management Information Report'
															AND Right__c = 'Access Granted'];
			system.debug('ACCESS LIST: ' + accessList);
			if (!accessList.isEmpty()){
				Set <Id> contactIds = new Set <Id>();
				for (Portal_Application_Right__c thisAccess : accessList){
					contactIds.add(thisAccess.Contact__c);
				}

				String queryString = 'SELECT ' + String.join(ISSP_NotificationUtilities.getAllContactFields(), ',') 
							      + ' FROM Contact  WHERE Id IN :contactIds';

				List <Contact> contactList = Database.query(queryString);

				ISSP_Notifications_Trigger__c notificationsTrigger = ISSP_Notifications_Trigger__c.getValues('Management Information Report');
				if (notificationsTrigger != null){
					List<Notification_template__c> lstNotificationTemplate = [SELECT Name, Message__c, Admins_Users__c, 
																		  Alert_Contact_By_Email__c, CriticalNotification__c, 
																		  Due_date__c, Expire_in_days__c, Language__c, 
																		  Master_Notification_template__c, Notification_color__c, 
																		  Subject__c, Type__c 
		                                    							  FROM Notification_template__c 
		                                    							  WHERE Id = :notificationsTrigger.Notification_Template_Id__c];
					if (!lstNotificationTemplate.isEmpty())
					{
						Notification_template__c notificationTemplate = lstNotificationTemplate[0];
						ISSP_NotificationUtilities.sendNotification(contactList, notificationTemplate, null, null);
					}
				}
			}
		}

        return result;
    }
}
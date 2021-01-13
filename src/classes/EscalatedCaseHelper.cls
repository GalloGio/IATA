/**
 * Helper class used when emails from servicedesk@kaleconsultants.com are received
 * Created By Alexandre McGraw
 * Created On 2011-11-02
 */
public with sharing class EscalatedCaseHelper {

	//public static final String KALE_SUPPORT_EMAIL = 'servicedesk@kaleconsultants.com';
	public static final String KALE_SUPPORT_EMAIL = System.Label.KALE_SUPPORT_EMAIL;
	//public static final String KALE_SUPPORT_EMAIL = 'belislep@iata.org';	// ITS test
	//static final String KALE_SUPPORT_EMAIL = 'kaleuser@yahoo.com';	// Business UAT



	/**
	 * Returns true if the case has been escalated
	 * (is from Kale and subject contains a specific string)
	 */
	public static boolean caseHasBeenEscalatedToKale(Case theCase) {

		return theCase.SuppliedEmail == KALE_SUPPORT_EMAIL && theCase.Subject.contains('Your request has been logged with SCP request ID');
	}

	/**
	 * Returns true whenever a case status has been updated in SCP
	 */
	public static boolean caseStatusHasBeenUpdatedByKale(Case theCase) {

		return theCase.SuppliedEmail == KALE_SUPPORT_EMAIL &&
				(theCase.Subject.contains('SCP Incident No:') && theCase.Subject.contains('raised by you was updated - SF No.'));
	}

	/**
	 * Returns true if a new comment has been added to the SCP case
	 */
	public static boolean caseHasNewCommentByKale(Case theCase) {

		return theCase.SuppliedEmail == KALE_SUPPORT_EMAIL &&
				(theCase.Subject.contains('Re: [Request ID :') && theCase.Subject.contains('- SF Incident No.'));
	}

	/**
	 * Returns true if the case has been resolved by Kale
	 */
	public static boolean caseHasBeenResolvedByKale(Case theCase) {

		return theCase.SuppliedEmail == KALE_SUPPORT_EMAIL &&
				(theCase.Subject.contains('Your Request with ID') && theCase.Subject.contains('has been Resolved - SF No.'));
	}

	/**
	 *Returns true if the case has been closed by Kale
	 */
	public static boolean caseHasBeenClosedByKale(Case theCase) {

		return theCase.SuppliedEmail == KALE_SUPPORT_EMAIL &&
				(theCase.Subject.contains('Request : ##') && theCase.Subject.contains('raised by you was closed - SF No.'));
	}

	/**
	 * Updates the External Reference number with the Kale case number.
	 */
	//this function is no longer used and was replaced by updateExternalRefNumber
	public static void updateExternalReferenceNumber(Case theCase) {

		// extract Kale case number from email subject
		String kaleCaseNumberStr = theCase.Subject.split('##')[1].trim(); // the case number is in index 1

		System.debug('Kale Case Number : ' + kaleCaseNumberStr);
		// get SalesForce case number from the case subject
		String sfCaseNumber = extractSFCaseNumberFromSubject(theCase.Subject);
		System.debug('SF Case Number : ' + sfCaseNumber);
		if (sfCaseNumber == null) throw new EmailParsingException('ERROR: Cannot extract SalesForce Case Number from Kale\'s email subject.');

		// get the original case and update the ExternalReferenceNumber
		Case[] cObj = [Select id, subject from Case where CaseNumber =: + sfCaseNumber limit 1];

		if (cObj == null || cObj.size() == 0) throw new EmailParsingException('ERROR: Case Number ' + sfCaseNumber + ' was not found.');

		cObj[0].External_Reference_Number__c = kaleCaseNumberStr;
		System.debug('Kale Case Number : ' + cObj[0].External_Reference_Number__c);

		update cObj[0];
	}

	/**
	 * Add the case resolution as a case comment
	 */
	public static void updateCaseWithResolution(Case theCase) {

		String resolution = '';
		Boolean inResolution = false;
		Boolean inFooter = false;
		String sfCaseNumber = extractSFCaseNumberFromSubject(theCase.Subject);

		if (sfCaseNumber == null || sfCaseNumber.trim().length() == 0) throw new EmailParsingException('ERROR: Cannot extract SalesForce Case Number from Kale\'s email subject.');

		System.debug('ALEX - theCase.Description: ' + theCase.Description);

		// extract resolution from case description
		String[] lines = theCase.Description.split('\n');
		for (integer i=0; i< lines.size(); i++) {

		   if (lines[i].trim().startsWith('Resolution :'))
				inResolution = true;

			if (lines[i].trim().startsWith('For a prompt response, please address your correspondence') || lines[i].startsWith('\n\n'))
				inFooter = true;

			// add lines if between resolution and footer (or followed by 2 white lines)
			if (inResolution && !inFooter)
				resolution += lines[i] + '\n';
		}

		system.debug('ALEX - resolution: ' + resolution);

		String[] mailReceiver = new String []{'paia@iata.org', 'mcgrawa@iata.org'};
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setSenderDisplayName('SalesForce - Kale Resolution');
		//mail.setTargetObjectId(currentUser.id);
		mail.setSubject('SalesForce - Kale Resolution Details Comment ' + sfCaseNumber);
		mail.setPlainTextBody('Resolution:' + resolution + '\r\nEmailBody:' + theCase.Description);
		mail.saveAsActivity = false;
		mail.setToAddresses(mailReceiver);
		// send email if not running test
		//if (!Test.isRunningTest())
			//Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});

		// add the resolution as a CaseComment
		addCaseComment(sfCaseNumber, resolution);
	}

	/**
	 * Update the case with the new SCP case status (added as a case comment)
	 */
	public static void updateCaseWithKaleSCPStatus(Case theCase) {

		String newStatus = null;
		String sfCaseNumber = extractSFCaseNumberFromSubject(theCase.Subject);
		System.debug('SF Case Number : ' + sfCaseNumber);
		if (sfCaseNumber == null || sfCaseNumber.trim().length() == 0) throw new EmailParsingException('ERROR: Cannot extract SalesForce Case Number from Kale\'s email subject.');

		// extract new status from case description
		string[] emailLines = theCase.Description.split('\n');
		for (integer i=0; i< emailLines.size(); i++) {

			// search for the line containing the status
			if (emailLines[i].trim().startsWith('Status :')) {
				newStatus = emailLines[i].substring(emailLines[i].lastIndexOf(' : ') + 2);
				break;
			}
		}

		if (newStatus == null) throw new EmailParsingException('ERROR: Cannot extract SalesForce new status from Kale\'s email description.');

		// add the new status as a case comment
		addCaseComment(sfCaseNumber, 'The SCP case status has been updated to ' + newStatus.trim());
		// Update Kale Status Field
		updateCase_KaleStatus(sfCaseNumber, newStatus.trim());
	}

	/**
	 * Update the case with Kale's comment (added as a case comment)
	 */
	public static void updateCaseWithKaleComment(Case theCase) {

		String comment = '';
		String sfCaseNumber = extractSFCaseNumberFromSubject(theCase.Subject);

		if (sfCaseNumber == null || sfCaseNumber.trim().length() == 0) throw new EmailParsingException('ERROR: Cannot extract SalesForce Case Number from Kale\'s email subject.');

		// extract comment from case description
		String[] emailLines = theCase.Description.split('\n');
		for (integer i=0; i< emailLines.size(); i++) {

			// add lines from beginning to the line that starts with 'On '
			if (emailLines[i].trim().startsWith('On '))
				break;

			comment += emailLines[i] + '\n';
		}

		if (comment.trim() == '') throw new EmailParsingException('ERROR: Cannot extract Kale\'s comment from Kale\'s email description.' + sfCaseNumber);

		// add Kale comment as a CaseComment
		addCaseComment(sfCaseNumber, comment);
	}

	/**
	 * Add a CaseComment to an existing Case
	 */
	public static void addCaseComment(String caseNumber, String comment) {

		// add the resolution as a case comment
		List<Case> origCase = [Select id, subject, CaseNumber from Case where CaseNumber =: + caseNumber];
		if(origCase.size() > 0){

			CaseComment newCaseComment = new CaseComment();
			newCaseComment.ParentId = origCase[0].Id;
			newCaseComment.CommentBody = comment;

			insert newCaseComment;
		}else {
			throw new EmailParsingException('ERROR: Case Number ' + caseNumber + ' was not found.');
		}

	}

	public static void addCaseComment(Id caseId, String comment) {

		// add the resolution as a case comment
		try{
			CaseComment newCaseComment = new CaseComment();
			newCaseComment.ParentId = caseId;
			newCaseComment.CommentBody = comment;

			insert newCaseComment;
		}catch (Dmlexception e) {
			throw new EmailParsingException('ERROR: Case Number ' + caseId + ' was not found.');
		}

	}


	/**
	 * SIS HelpDesk Enhancement : December 2013.
	 * By : Kofi Johnson
	 * Update the Field "Kale Status" with the newStatus value
	 */
	public static void updateCase_KaleStatus(String caseNumber, String kaleStatus)
	{
		// SOQL call is made here to retrieve the parent of the case.
		//Since this part of code is called just by an Email-to-Case, this should not raise a SOQL Limit
		List<Case> origCase = [Select id, CaseNumber, Kale_Status__c from Case where CaseNumber =: + caseNumber];

		if (kaleStatus == 'Onhold')
			kaleStatus = 'On hold';
		if(origCase.size() > 0)
		{
			// Since the value "newStatus.trim" is a String from email, make sure the "newStatus" value is  field Kale Status. Only predefined statuses are allowed
			Schema.DescribeFieldResult kaleStatusField = Case.Kale_Status__c.getDescribe();
			List<Schema.PicklistEntry> kaleStatusPicklistEntries = kaleStatusField.getPicklistValues();
			Boolean statusFound = false;
			for (Schema.PicklistEntry p : kaleStatusPicklistEntries)
			{
				if (p.getValue().equalsIgnoreCase(kaleStatus))
				{
					statusFound = true;

					origCase[0].Kale_Status__c = p.getValue();
					break;
				}
			}
			if (statusFound)
				update origCase[0];
			else
				throw new EmailParsingException('ERROR: Received Kale Status ' + kaleStatus + ' was not recognized.');
		}
		else
			throw new EmailParsingException('ERROR: Case Number ' + caseNumber + ' was not found.');
	}

	/**
	 * Extracts the SF case number from the subject of a Kale notification email
	 * Template used for the subject:
	 * "Your request has been logged with SCP request ID ##1732## and SF No. 2069551"
	 */
	public static String extractSFCaseNumberFromSubject(String subject) {

		String[] parts = subject.split(' ');
		return parts[parts.size()-1];
	}

	public static void updateExternalRefNumber(list<Case> theseCases)
	{
		set<id> ListOfIds = new set<id>();
		for(Case TC: theseCases)
		{
			ListOfIds.add(TC.Id);
		}
		List<Case> origCase = [Select id, CaseNumber, External_Reference_Number__c from Case where Id in: ListOfIds];
		for(Case OC: origCase)
		{
			for(Case TC: theseCases)
			{
				if(TC.Id == OC.Id)
				{
					OC.External_Reference_Number__c = TC.External_Reference_Number__c;
					system.debug('\nOC.External_Reference_Number__c = ' + OC.External_Reference_Number__c);
				}
			}
		}
		update origCase;

	}
}

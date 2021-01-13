global class IFAP_Reminder_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts, database.stateful{


	global  Date TWOWEEKSTOGO = Date.today().addDays(+14);
	global  Date ONEWEEKTOGO = Date.today().addDays(+7);
	global  Date TWODAYSTOGO = Date.today().addDays(+2);
	global  Date ONEDAYTOGO = Date.today().addDays(+1);
	set<string> StatusFA = new set<string>{'Agent Notified (Mail)','Agent Notified (Email)'};
	set<string> StatusREVIEW =  new set<string>{'Financial Security Requested'};
	set<string> StatusSCF  = new set<string>{'Sanity Check Failure'};




	global Database.QueryLocator start(Database.BatchableContext BC){

	   String Query = 'SELECT Id, ParentID, Status, ContactId,CASENUMBER , AccountId, Subject, FS_Mass_Email_Send__c, Mass_Email_Send__c,  '
								   +' FS_Letter_Sent__c , FS_Reminder_EmailTemplate__c,FS_Deadline_Date__c , ' // financial review
								   +' FA_Letter_Sent__c,Reminder_EmailTemplate__c, Deadline_Date__c ,IFAP_Agent_Type__c, account.industry  '//  FA financial assesment
								//   +' , SCF_Letter_Sent__c, SCF_Reminder_Template__c ' // Sanity Check Failure
								   + 'FROM CASE  '
								   +' WHERE '
								   + 'recordtype.developername  = \'IATA_Financial_Review\' AND '
								 /*  + '  and(   '
								   + '  ('
										+ '( FS_Deadline_Date__c  =: TWOWEEKSTOGO OR '+
											'FS_Deadline_Date__c  =: ONEWEEKTOGO OR '+
											'FS_Deadline_Date__c  =: TWODAYSTOGO OR '+
											'FS_Deadline_Date__c  =: ONEDAYTOGO OR '+
											' FS_Second_Deadline_Date__c  =: TWOWEEKSTOGO OR '+
											'FS_Second_Deadline_Date__c  =: ONEWEEKTOGO OR '+
											'FS_Second_Deadline_Date__c  =: TWODAYSTOGO OR '+
											'FS_Second_Deadline_Date__c  =: ONEDAYTOGO OR  '+
											' FS_Third_Deadline_Date__c  =: TWOWEEKSTOGO OR '+
											' FS_Third_Deadline_Date__c  =: ONEWEEKTOGO OR '+
											' FS_Third_Deadline_Date__c  =: TWODAYSTOGO OR '+
											' FS_Third_Deadline_Date__c  =: ONEDAYTOGO )'
										+ ' AND Status =\'Financial Security Requested\'  )'
								   + ' OR (' */
										+ '( Deadline_Date__c  =: TWOWEEKSTOGO OR '+
											'Deadline_Date__c  =: ONEWEEKTOGO OR '+
											'Deadline_Date__c  =: TWODAYSTOGO OR '+
											'Deadline_Date__c  =: ONEDAYTOGO OR'+
											' FA_Second_Deadline_Date__c  =: TWOWEEKSTOGO OR '+
											'FA_Second_Deadline_Date__c  =: ONEWEEKTOGO OR '+
											'FA_Second_Deadline_Date__c  =: TWODAYSTOGO OR '+
											'FA_Second_Deadline_Date__c  =: ONEDAYTOGO OR '+
											' FA_Third_Deadline_Date__c  =: TWOWEEKSTOGO OR '+
											'FA_Third_Deadline_Date__c  =: ONEWEEKTOGO OR '+
											'FA_Third_Deadline_Date__c  =: TWODAYSTOGO OR '+
											'FA_Third_Deadline_Date__c  =: ONEDAYTOGO )'
										+' AND Status in (\'Agent Notified (Mail)\',\'Agent Notified (Email)\') AND Financial_Review_Type__c = \'Annual\'' //,\'Sanity Check Failure\'
										+' AND (account.Category__c != \'IATA Passenger Sales Agent\' OR IFAP_Country_ISO__c != \'DE\')' //INC196793
									  //  + ') )'
								   ;



			return Database.getQueryLocator(query);

	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){

	 system.debug('############ EXECUTE ('+scope.size()+')');
	  list<Case> casesToUpdate = new list<Case>();

		map<Id,Id> AccountIdPerCAseID= new map<Id,Id>();
		map<Id,Case> casePerCaseId = new map<Id,Case>();

		for(Case c:(list<Case>)Scope){

				AccountIdPerCAseID.put(c.id,c.AccountID);
				casePerCaseId.put(c.id,c);
		}


		// 'Cargo Agent', 'Travel Agent'

		//map<Id,Id> accountIdPerIsocountry=  new map<Id,Id>();



		map<string, map<Id,Id>> IsocountryPeraccountIdPerSector=  new map<string, map<Id,Id>>();
		set<Id> isocountryids= new set<Id>();
		for(Account a: [Select Id,IATA_ISO_Country__c, industry from Account where id in: AccountIdPerCAseID.values() ]){
				//accountIdPerIsocountry.put(a.IATA_ISO_Country__c, a.id);
			if(a.industry <> null){
			 string sectorLocal =(a.industry.contains('Cargo')) ?'CARGO' : 'PAX';

				if(IsocountryPeraccountIdPerSector.get(sectorLocal)==null)
					IsocountryPeraccountIdPerSector.put(sectorLocal, new map<Id,Id>());
				 IsocountryPeraccountIdPerSector.get(sectorLocal).put(a.id, a.IATA_ISO_Country__c);

				 isocountryids.add(a.IATA_ISO_Country__c);
		}
		}

		EmailTemplate__c financialSecurityTemplate = new EmailTemplate__c();

		map<string,map<Id,List<Id>>> TemplateIdPerIsoCountryIDPerSector = new map<string,map<Id,List<Id>>>();

		for(EmailTemplate__c e: [SELECT id,IATA_ISO_Country__c, Template_Type__c , Name from EmailTemplate__c
														where recordtype.name = 'IFAP' and
															Template_Type__c ='FA - Financial Assessment'
															and Is_reminder__c = true
															//and IATA_ISO_Country__c IN:accountIdPerIsocountry.keyset())
															and IATA_ISO_Country__c IN:isocountryids
														   ] ){


			 system.debug('###### result ' + e );
			string sectorLocal =(e.name.contains('PAX')) ?'PAX' : 'CARGO';


			if(TemplateIdPerIsoCountryIDPerSector.get(sectorLocal) == null)
				TemplateIdPerIsoCountryIDPerSector.put(sectorLocal, new map<Id, list<ID>>());

			if(TemplateIdPerIsoCountryIDPerSector.get(sectorLocal).get(e.IATA_ISO_Country__c)==null)
				TemplateIdPerIsoCountryIDPerSector.get(sectorLocal).put(e.IATA_ISO_Country__c, new List<Id>());
			TemplateIdPerIsoCountryIDPerSector.get(sectorLocal).get(e.IATA_ISO_Country__c).add(e.id);



		}



		for(Case c:(list<Case>)Scope){

			string sectorLocal =(c.account.industry.contains('Cargo')) ?'CARGO' : 'PAX';

	// account.industry
			if( (c.status =='Agent Notified (Mail)' || c.status =='Agent Notified (Email)')
			&&
				c.Reminder_EmailTemplate__c  == null
				&& AccountIdPerCAseID.get(c.id) <> null
				&& IsocountryPeraccountIdPerSector.get(sectorLocal) <> null
				&& IsocountryPeraccountIdPerSector.get(sectorLocal).get(AccountIdPerCAseID.get(c.id)) <> null
				&& TemplateIdPerIsoCountryIDPerSector.get(sectorLocal) <> null
				&& TemplateIdPerIsoCountryIDPerSector.get(sectorLocal).get(IsocountryPeraccountIdPerSector.get(sectorLocal).get(AccountIdPerCAseID.get(c.id))) <> null
				&& TemplateIdPerIsoCountryIDPerSector.get(sectorLocal).get(IsocountryPeraccountIdPerSector.get(sectorLocal).get(AccountIdPerCAseID.get(c.id))).size()==1

				){

			   c.Reminder_EmailTemplate__c = TemplateIdPerIsoCountryIDPerSector.get(sectorLocal).get(IsocountryPeraccountIdPerSector.get(sectorLocal).get(AccountIdPerCAseID.get(c.id)))[0];

				system.debug('############ CASE '+c.Subject+' SET reminder template: '+c.Reminder_EmailTemplate__c);
			}




			c.Mass_Email_Send__c = true;




			casesToUpdate.add(c);
		}

		system.debug('############ update '+casesToUpdate.size()+' cases');
		for(case c : casestoupdate)
		system.debug('############ update ' +C.ID +  '            ADSASD     '+c.Subject+' Reminder_EmailTemplate__c='+c.Reminder_EmailTemplate__c+' - FS_Reminder_EmailTemplate__c='+c.FS_Reminder_EmailTemplate__c);
		CaseChildHelper.noValidationsOnTrgCAseIFAP = TRUE;
		 system.debug('############ update '+casesToUpdate);
		if(!casesToUpdate.isEmpty())
			database.update(casesToUpdate, false);



	}

	global void finish(Database.BatchableContext BC){


	}

}

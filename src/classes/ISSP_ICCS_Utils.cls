public without sharing class ISSP_ICCS_Utils{
    
    public static final String ICCS_PORTAL_APPLICATION_NAME = 'ICCS';
    
    public static final Integer COLLAPSED_TABLE_ROWS = 3;
    
    public static final String ICCS_DEFAULT_REPORT_NOTIFICATION_TEMPLATE = 'ICCS_DefaultReportNotificationTemplate';

	public static final String ICCS_NOTIFICATION_TEMPLATE_ACCESS_REQUESTED	= 'ICCS_Service_Access_Requested';
	public static final String ICCS_NOTIFICATION_TEMPLATE_ACCESS_GRANTED	= 'ICCS_Service_Access_Granted';
	public static final String ICCS_NOTIFICATION_TEMPLATE_ACCESS_DENIED		= 'ICCS_Service_Access_Denied';
	public static final String ICCS_NOTIFICATION_TEMPLATE_ACCESS_REVOKED	= 'ICCS_Service_Access_Revoked';
	public static final String ICCS_NOTIFICATION_TEMPLATE_UPGRADE_REQUESTED	= 'ICCS_Role_Upgrade_Requested';
	public static final String ICCS_NOTIFICATION_TEMPLATE_UPGRADE_ACCEPTED	= 'ICCS_Role_Upgrade_Accepted';
	public static final String ICCS_NOTIFICATION_TEMPLATE_UPGRADE_DENIED	= 'ICCS_Role_Upgrade_Denied';

    public static final Map<String, String> ICCS_NOTIFICATION_TEMPLATE_NAMES_MAP = new Map<String, String>{
    	ICCS_NOTIFICATION_TEMPLATE_ACCESS_REQUESTED => null,
    	ICCS_NOTIFICATION_TEMPLATE_ACCESS_GRANTED => null,
    	ICCS_NOTIFICATION_TEMPLATE_ACCESS_DENIED => null,
    	ICCS_NOTIFICATION_TEMPLATE_ACCESS_REVOKED => null,
    	ICCS_NOTIFICATION_TEMPLATE_UPGRADE_REQUESTED => null,
    	ICCS_NOTIFICATION_TEMPLATE_UPGRADE_ACCEPTED => null,
    	ICCS_NOTIFICATION_TEMPLATE_UPGRADE_DENIED => null
    };
	// Fill the ICCS_NOTIFICATION_TEMPLATE_NAMES_MAP
    static{
    	for(Notification_Template__c template : [select Name, Identifier__c from Notification_Template__c where Identifier__c in : ICCS_NOTIFICATION_TEMPLATE_NAMES_MAP.keySet()]){
    		ICCS_NOTIFICATION_TEMPLATE_NAMES_MAP.put(template.Identifier__c, template.Name);
    	}
    }
    

    public static final String ACCESS_DENIED = 'Access Denied';
    public static final String ACCESS_GRANTED = 'Access Granted';
    public static final String ACCESS_REQUESTED = 'Access Requested';
    
    public static final String SI_STANDARD = 'Standard';
    public static final String SI_FUTURE = 'Future';
    public static final String SI_ADHOC = 'AdHoc';

	public static final String NONE = '-- None --';
    
    // ICCS Document types
    public static final String ICCS_DOCUMENT_AML = 'AML';
    public static final String ICCS_DOCUMENT_FORM_A = 'Form A';
    public static final String ICCS_DOCUMENT_FORM_K = 'Form K';
    public static final String ICCS_DOCUMENT_ASP = 'ASP';
    public static final String ICCS_DOCUMENT_BANK_ACCOUNTS = 'Bank Accounts';
    public static final String ICCS_DOCUMENT_DEACTIVATION = 'Deactivation';
    public static final String ICCS_DOCUMENT_MEMBERSHIP = 'Membership Agreement';
    public static final String ICCS_DOCUMENT_JOIN_PARTICIPATION = 'Join Participation';
    public static final String ICCS_DOCUMENT_LEAVE_PARTICIPATION = 'Leave Participation';	/* CHECK WHY WE HAD AN AMAZON FILE WITH THE VALUE 'Stop Operation' */
    public static final String ICCS_DOCUMENT_NOA_RELEASE = 'NoA Release';
    public static final String ICCS_DOCUMENT_REVISED_INSTRUCTIONS = 'Revised Instructions';

    // Account record type Ids
    public static final Id ACCOUNT_RECORD_TYPE_AGENCY = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
    public static final Id ACCOUNT_RECORD_TYPE_AIRLINE_HQ = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
    public static final Id ACCOUNT_RECORD_TYPE_AIRLINE_BRANCH = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR');

    // ICCS Case record types Ids
    public static final Id CASE_RECORD_TYPE_ASP = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ASP_Management');
    public static final Id CASE_RECORD_TYPE_BANK_ACCT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_Bank_Account_Management');
    public static final Id CASE_RECORD_TYPE_MEMBERSHIP = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_Membership_Management');
    public static final Id CASE_RECORD_TYPE_PARTICIPATION = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_Product_Management');
    
    public static final List<Id> CASE_RECORD_TYPES = new List<Id>{CASE_RECORD_TYPE_ASP,
																  CASE_RECORD_TYPE_BANK_ACCT,
																  CASE_RECORD_TYPE_MEMBERSHIP,
																  CASE_RECORD_TYPE_PARTICIPATION};

	// Cases Areas
	public static final String CASE_AREA_JOIN_SERVICE = 'ICCS – Join Service';
	public static final String CASE_AREA_LEAVE_SERVICE = 'ICCS – Leave Service';
	public static final String CASE_AREA_JOIN_PARTICIPATION = 'ICCS – Assign Product';
	public static final String CASE_AREA_LEAVE_PARTICIPATION = 'ICCS – Remove Product';
	public static final String CASE_AREA_ADD_BANK_ACCOUNT = 'ICCS – Create Bank Account';
	public static final String CASE_AREA_UPD_BANK_ACCOUNT = 'ICCS – Update Bank Account';
	public static final String CASE_AREA_CREATE_ASP = 'FDS - Create Authorized Signatories Package';
	public static final String CASE_AREA_UPDATE_ASP = 'FDS - Update Authorized Signatories Package';
	public static final String CASE_AREA_TERMINATE_NOA = 'ICCS – Terminate Notice of Assignment';

    // ICCS Membership statuses
    public static final String ICCS_MEMBERSHIP_NONE     	= null;
    public static final String ICCS_MEMBERSHIP_PROSPECT 	= 'Prospect';
    public static final String ICCS_MEMBERSHIP_ACTIVE 		= 'Active';
    public static final String ICCS_MEMBERSHIP_MEMBER   	= 'Member';
    public static final String ICCS_MEMBERSHIP_SUSPENDED 	= 'Suspended';
    public static final String ICCS_MEMBERSHIP_WITHDRAWN 	= 'Withdrawn';
    public static final String ICCS_MEMBERSHIP_INACTIVE 	= 'Inactive';

    // Portal User Statuses
    public static final String PORTAL_STATUS_APPROVED   = 'Approved User';
    public static final String PORTAL_STATUS_ADMIN      = 'Approved Admin';
    public static final String PORTAL_STATUS_INACTIVE   = 'Deactivated';
    public static final String PORTAL_STATUS_PENDING    = 'Pending Approval';
    public static final String PORTAL_STATUS_REG_ADMIN  = 'Regional Administrator';
    public static final String PORTAL_STATUS_NONE       = '';

    // User ICCS roles
    public static final String ICCS_ROLE_SIGNATORY = 'Signatory';
    public static final String ICCS_ROLE_LEVEL1 = 'Level 1';
    public static final String ICCS_ROLE_READ_ONLY = 'Read-only';
    public static final String ICCS_ROLE_REGISTRATION = 'Registration';

	public static final List<SelectOption> selectableRoles = new List<SelectOption>{
		new SelectOption(NONE, NONE),
		new SelectOption(ICCS_ROLE_READ_ONLY, ICCS_ROLE_READ_ONLY),
		new SelectOption(ICCS_ROLE_LEVEL1, ICCS_ROLE_LEVEL1)
	};
    
    public enum Page {
        HOMEPAGE,
        SERVICE_MGMT,
        CYCLE_MGMT,
        CASES,
        REPORTS,
        PROFILE,
        CASE_PROCESSES,
        SI_EDIT,
        ACCESS_DENIED,
        NONE
    }

    public Enum CaseProcessType {
        REGISTRATION,
        DEACTIVATION,
        BANK_ACCOUNT,
        PART_NEW,
        PART_DEL,
        ASP_UPD,
        NOA
    }

	// Map used to sort the settlement instructions
	/* Check if this can be moved somewhere else */
	public static Map<String, Integer> instructionTypeOrderMap = new Map<String, Integer>{SI_ADHOC => 1, SI_FUTURE => 2, SI_STANDARD => 3};

	// Returns the ICCS Membership status of the top Account of a Contact
    public static String getICCSMembershipStatus(String conId){
        Contact c = [SELECT User_Portal_Status__c,
                       Account.ICCS_Membership_Status__c,
                       Account.Top_Parent__c,
                       Account.Top_Parent__r.ICCS_Membership_Status__c
                  FROM Contact WHERE Id = :conId limit 1];
                  
		if(c.Account.Top_Parent__c == null){
			return c.Account.ICCS_Membership_Status__c;
		}
		else{
			return c.Account.Top_Parent__r.ICCS_Membership_Status__c;
		}
    }    

	// Returns the ICCS Portal Service record
    public static Portal_Applications__c getIccsPortalApplication(){
		List<Portal_Applications__c> portalApplications = [select Id from Portal_Applications__c where Name = : ICCS_PORTAL_APPLICATION_NAME limit 1];
    	if(!portalApplications.isEmpty()){
    		return portalApplications[0];
    	}
    	else{
    		return null;
    	}
    }

	// Called when a portal user requests a role within ICCS Service
	public static void requestRole(Portal_Application_Right__c requestor, String requestedRole, Boolean requestAccess){
		// Retrieve the admin users
		List<Portal_Application_Right__c> adminUsers = 
				[select Contact__c, Contact__r.Id, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, ANG_Portal_Service_Role__c, Right__c
				from Portal_Application_Right__c
				where Application_Name__c = : ISSP_ICCS_Utils.ICCS_PORTAL_APPLICATION_NAME
					and Right__c =: ACCESS_GRANTED
					and (ANG_Portal_Service_Role__c =: ICCS_ROLE_LEVEL1 or ANG_Portal_Service_Role__c =: ICCS_ROLE_SIGNATORY)
					and Top_Account__c =: requestor.Top_Account__c];

		// Define a sub-list of the admin users, depending on the role requested
		List<Portal_Application_Right__c> usrs = new List<Portal_Application_Right__c>();

		if(requestedRole == ICCS_ROLE_READ_ONLY){
			for(Portal_Application_Right__c adminUser : adminUsers){
				if(adminUser.ANG_Portal_Service_Role__c == ISSP_ICCS_Utils.ICCS_ROLE_LEVEL1){
					usrs.add(adminUser);
				}
			}		
		}

		if(requestedRole == ICCS_ROLE_LEVEL1 || usrs.isEmpty()){
			for(Portal_Application_Right__c adminUser : adminUsers){
				if(adminUser.ANG_Portal_Service_Role__c == ISSP_ICCS_Utils.ICCS_ROLE_SIGNATORY){
					usrs.add(adminUser);
				}
			}		
		}

		// If the portal user doesn't have access to the service yet
		if(requestAccess){
			String replaceStr = '%FIRST_NAME%!' + requestor.Contact__r.FirstName + '|' +
								'%LAST_NAME%!' + requestor.Contact__r.LastName + '|' +
								'%ICCS_ROLE%!' + requestedRole;
			createNotification(ICCS_NOTIFICATION_TEMPLATE_NAMES_MAP.get(ICCS_NOTIFICATION_TEMPLATE_ACCESS_REQUESTED), replaceStr, usrs);
		}
		// If the portal user has access to the service and requested a new role
		else{
			// Update the Portal Service Access record to store the requested role
			requestor.New_Role_Requested__c = requestedRole;
			update requestor;
			
			String replaceStr = '%FIRST_NAME%!' + requestor.Contact__r.FirstName + '|' +
								'%LAST_NAME%!' + requestor.Contact__r.LastName + '|' +
								'%ICCS_OLD_ROLE%!' + requestor.ANG_Portal_Service_Role__c + '|' +
								'%ICCS_NEW_ROLE%!' + requestedRole;
			createNotification(ICCS_NOTIFICATION_TEMPLATE_NAMES_MAP.get(ICCS_NOTIFICATION_TEMPLATE_UPGRADE_REQUESTED), replaceStr, usrs);
		}
	}


	public static void createNotification(String templateName, String replaceStr, List<Portal_Application_Right__c> usrs){
		// Retrieve notification hierarchy
		// The list should have only one element
		List <Notification_template__c> templateList = 
    				[Select n.Subject__c, n.Name, n.Message__c, n.Language__c,Type__c,Notification_color__c,Alert_Contact_By_Email__c,
                	Expire_in_days__c, CriticalNotification__c, LanguageLocaleKey__c,
                    (Select Subject__c, Name, Message__c, Language__c,Type__c,Notification_color__c,Alert_Contact_By_Email__c,
                	Expire_in_days__c, CriticalNotification__c, LanguageLocaleKey__c From Notification_templates__r)
                     From Notification_template__c n  where  Name = :templateName];

		// This map will contain the messages for each language
		Map<String, ISSP_WS_CreateNotification.languageMessage> messagePerLanguage = new Map<String, ISSP_WS_CreateNotification.languageMessage>();

		// This map will contain the recipients for each language
		Map<String, List<String>> emailPerLanguage = new Map<String, List<String>>();
		
		if (!templateList.isEmpty()){
			
			// Store the email for each contact
			Map<Id, String> emailPerContact = new Map<Id, String>();
			for(Portal_Application_Right__c usr : usrs){
				emailPerContact.put(usr.Contact__r.Id, usr.Contact__r.Email);
			}
			
			// Map of languages
			Map<String, String> languagesMap = ISSP_CreateNotification.getLanguagesMap();
			for(String language : languagesMap.keySet()){
				System.debug(language + ' - ' + languagesMap.get(language));
			}
			
			for(User user : [Select u.LanguageLocaleKey, u.ContactId From User u where ContactId in : emailPerContact.keySet()]){
				String languageKey = 'en_US';

				// Use the parent template by default
				Notification_template__c notificationTemplate = templateList[0];

				// Check if there is a notification template for the user's language
	            for(Notification_template__c ntTranslate : templateList[0].Notification_templates__r){
	            	if(ntTranslate.LanguageLocaleKey__c == user.LanguageLocaleKey.substring(0,2)){
	            		System.debug('FOUND A TRANSLATION');
	            		languageKey = user.LanguageLocaleKey;
	            		notificationTemplate = ntTranslate;
	            		break;
	            	}
	            }

				// Check if the message for this language has already been retrieved
				if(!messagePerLanguage.keySet().contains(languageKey)){
					ISSP_WS_CreateNotification.LanguageMessage inputMessage = new ISSP_WS_CreateNotification.LanguageMessage();
					inputMessage.subject = notificationTemplate.Subject__c;
		        	inputMessage.message = notificationTemplate.Message__c;
		        	inputMessage.languageCode = 'en_US';
					messagePerLanguage.put(languageKey, inputMessage);
					emailPerLanguage.put(languageKey, new List<String>()); 
				}

				// Add the user's email to the list of recipients for this language				
				emailPerLanguage.get(languageKey).add(emailPerContact.get(user.ContactId));
			}

			// Send one notification per language with the related list of users email
			for(String language : messagePerLanguage.keySet()){
				ISSP_WS_CreateNotification.inputData inputData = new ISSP_WS_CreateNotification.inputData();
			
		    	inputData.requestingSystem = 'ICCS Core';
		    	inputData.listOfUsers = emailPerLanguage.get(language);
		    	inputData.languageMessageList = new List<ISSP_WS_CreateNotification.languageMessage>{messagePerLanguage.get(language)};
		
		    	inputData.notificationType = templateList[0].Type__c;
		    	inputData.daysToExpire = templateList[0].Expire_in_days__c.intValue();
		    	inputData.emailAlert = templateList[0].Alert_Contact_By_Email__c;
		    	inputData.criticalNotification = templateList[0].CriticalNotification__c;
		    	inputData.replaceStr = replaceStr;
			    	
		    	ISSP_WS_CreateNotification.createNotification(inputData);				
			}
		}
	}
	
	// Returns the list of portal users having access to ICCS Service who subscribed to report notifications
	// and whose Account subscribed to the report type defined in the parameter
	public static List<Id> getReportNotificationRecipients(String reportType, String accountId){
		List<Id> usersToNotify = new List<Id>();
		
		// If accountId has not been specified, return an empty list
		if(accountId == null){
			System.debug('accountId is null');
			return usersToNotify;
		}

		// Check if the account subscribed to the specified report type
		List<Portal_Service_Account_Preference__c> subscriptions = [select Account__r.Id from Portal_Service_Account_Preference__c where Portal_Service__c =: getIccsPortalApplication().Id and Category__c = 'Report' and Subscribed__c = true and Name =: reportType and Account__r.Id = : accountId];
		if(subscriptions.isEmpty()){
			System.debug('Specified account did not subscribe to this report type : ' + reportType);
			return usersToNotify;
		}
		
		// Map of users per topAccount
		Map<String, List<Id>> usersPerTopAccountMap = new Map<String, List<Id>>();

		try{
			// Retrieve portal users having access to ICCS Service who subscribed to report notifications
			for(Portal_Service_User_Preference__c userPreference : [	select 	Id, 
																				Portal_Service_Access__c,
																				Portal_Service_Access__r.Contact__c,
																				Portal_Service_Access__r.Top_Account__c
																		from 	Portal_Service_User_Preference__c 
																		where 	Category__c = 'Notification' 
																				and Subscribed__c = true
																				and Portal_Service_Access__r.Right__c =: ACCESS_GRANTED
																				and Portal_Service_Access__r.Portal_Application__c = : getIccsPortalApplication().id
																				]){
				System.debug('Portal_Service_Access__r.Top_Account__c : ' + userPreference.Portal_Service_Access__r.Top_Account__c);
				System.debug('accountId : ' + accountId);
				
				if(userPreference.Portal_Service_Access__r.Top_Account__c == accountId){
					usersToNotify.add(userPreference.Portal_Service_Access__c);
				}
			}
		}
		catch(Exception e){
			System.debug(e.getMessage());
		}
		System.debug('Account subscribed to the report type. Maybe some users subscribed to notifications : ' + usersToNotify.size());

		return usersToNotify;
	}


	public virtual class ParticipationTable {
		public ISSP_ICCS_ComponentController componentController {get;set;}
		
		public String participantId;

		// Type of settlement instructions in this table: Standard, Future or Adhoc 
		public String type {get;set;}

		// Used for standard participation table
		public Boolean includeClosedParticipations {get;set;}

		// Cycle selected by the user. Null if type = Standard
		public String selectedCycle {get;set;}

		// List of participations
		public List<ParticipationRow> participationRows {get;set;}
		
		// Category map, Country map and Currency set retrieved from the list of participations
		public Map<String, Integer> categoryMap;
		public Map<String, String> countryMap;
		public Set<String> currencySet;
				
		// SelectOption lists of categories, countries and currencies , restricted to the selectableCategorySet values
		public List<SelectOption> categoryFilter {get;set;}
		public List<SelectOption> countryFilter {get;set;}
		public List<SelectOption> currencyFilter {get;set;}
		
		// Category, country and currency selected by the user
		public String selectedCategory {get;set;}
		public String selectedCountry {get;set;}
		public String selectedCurrency {get;set;}

		// Map of participations used for display
		public Map<Integer, ISSP_ICCS_CoreRest.Participation> participationsMap {
			get{
				if(transientParticipationsMap == null){
					transientParticipationsMap = getTransientParticipationsMap();
				}
				return transientParticipationsMap;
			}
		}
		public transient Map<Integer, ISSP_ICCS_CoreRest.Participation> transientParticipationsMap;
		

		// Map of settlement instructions used for display
		public Map<Integer, ISSP_ICCS_CoreRest.SettlementInstruction> settlementInstructionsMap {
			get{
				if(transientSettlementInstructionsMap == null){
					transientSettlementInstructionsMap = getTransientSettlementInstructionsMap();
				}
				return transientSettlementInstructionsMap;
			}
		}
		public transient Map<Integer, ISSP_ICCS_CoreRest.SettlementInstruction> transientSettlementInstructionsMap;

		
		/* CONSTRUCTORS */
		public ParticipationTable(ISSP_ICCS_ComponentController componentController, String type, String selectedCycle){
			System.debug('Creating ' + type + ' participationTable');

			this.componentController = componentController;
			this.type = type;
			this.selectedCycle = selectedCycle;
			this.includeClosedParticipations = false;
			
			resetTable(false);
		}

		public ParticipationTable(ISSP_ICCS_ComponentController componentController, Boolean includeClosedParticipations){
			System.debug('Creating Standard participationTable');

			this.componentController = componentController;
			this.type = SI_STANDARD;
			this.selectedCycle = null;
			this.includeClosedParticipations = includeClosedParticipations;
			
			resetTable(false);
		}
		

		public void cleanController(){
			categoryMap = null;
			categoryFilter = null;
			countryMap = null;
			countryFilter = null;
			currencySet = null;
			currencyFilter = null;
		}

		public void resetTable(Boolean keepStructure){

			/* STEP 1 : Reset category map, country map and currency set */

			categoryMap = new Map<String, Integer>();
			countryMap = new Map<String, String>();
			currencySet = new Set<String>();

			/* STEP 2 : Retrieve the participations, create ParticipationRows and fill the categoryMap, the countryMap and the currencySet */

			Map<Integer, ParticipationRow> participationRowsMap = new Map<Integer, ParticipationRow>();

			// Retrieve the configuration cashflows with all the details. Use the code as the key instead of the id as the cashflow id in cycle participations is not the same
			Map<String, ISSP_ICCS_CoreRest.Cashflow> detailedCashflowMap = new Map<String, ISSP_ICCS_CoreRest.Cashflow>();
			for(ISSP_ICCS_CoreRest.Cashflow cashflow : componentController.pageController.coreRest.getCashflows()){
				detailedCashflowMap.put(cashflow.code, cashflow);
			}
			
			if(type == SI_STANDARD || type == SI_FUTURE){
				// Retrieve the participations
				for(ISSP_ICCS_CoreRest.Participation participation : componentController.pageController.coreRest.getParticipations()){
					Boolean isActive = false;

					if(includeClosedParticipations || participation.endDate == null){
						isActive = true;
					}
					else{
						List<String> splitedDate = participation.endDate.split('-');
						if(splitedDate.size() == 3){
							try{
								Date endDate = Date.newInstance(Integer.valueOf(splitedDate[0]), Integer.valueOf(splitedDate[1]), Integer.valueOf(splitedDate[2]));
								if(Date.today() < endDate){
									isActive = true;
								}
							}
							catch(Exception e){
								// TO DO
							}
						}
					}

					if(isActive){
						// Add a participationRow in the ParticipationRowsMap
						participationRowsMap.put(participation.id, new ParticipationRow(this, participation.id));

						// Retrieve the detailed version of the cashflow to fill the category map, the country map and the currency set
						ISSP_ICCS_CoreRest.Cashflow cashflow = detailedCashflowMap.get(participation.cashflow.code);

						if(cashflow != null && cashflow.type.code != null && cashflow.country.name != null && cashflow.processingCurrency != null){
							categoryMap.put(cashflow.type.code, cashflow.type.id);
							countryMap.put(cashflow.country.name, cashflow.country.iso3Code);
							currencySet.add(cashflow.processingCurrency);
						}
					}
				}			
			}
			else{
				for(ISSP_ICCS_CoreRest.Participation participation : componentController.pageController.coreRest.getCycleParticipations(selectedCycle)){
					// Filter to retrieve only the current participant's participations
					if(participation.participant.code == componentController.pageController.participantId){
						// Add a participationRow in the ParticipationRowsMap
						participationRowsMap.put(participation.id, new ParticipationRow(this, participation.id));
					
						// Retrieve the detailed version of the cashflow to fill the category map, the country map and the currency set
						ISSP_ICCS_CoreRest.Cashflow cashflow = detailedCashflowMap.get(participation.cashflow.code);

						if(cashflow != null && cashflow.type.code != null && cashflow.country.name != null && cashflow.processingCurrency != null){
							categoryMap.put(cashflow.type.code, cashflow.type.id);
							countryMap.put(cashflow.country.name, cashflow.country.iso3Code);
							currencySet.add(cashflow.processingCurrency);
						}
					}
				}
			}

			/* STEP 3 : Retrieve the Settlement Instructions and create the SettlementInstructionRows */

			Map<Integer, SettlementInstructionRow> settlementInstructionRowsMap = new Map<Integer, SettlementInstructionRow>();
			
			if(type == SI_STANDARD){
				for(ISSP_ICCS_CoreRest.SettlementInstruction settlementInstruction : componentController.pageController.coreRest.getSettlementInstructions()){
					if(settlementInstruction.type.code == type && (settlementInstruction.cycle == null /* the following part should disappear once fixed in the core */ || settlementInstruction.cycle.cycleId == '' || settlementInstruction.cycle.cycleId == null)){
						// Retrieve the participationRow
						ParticipationRow participationRow = participationRowsMap.get(settlementInstruction.participation.id);
						if(participationRow != null){
							// Add a settlementInstructionRow in the participationRow
							SettlementInstructionRow settlementInstructionRow = new SettlementInstructionRow(participationRow, settlementInstruction.id, true);
							participationRow.settlementInstructionRows.add(settlementInstructionRow);
							// Add it in the settlementInstructionRowsMap as well
							settlementInstructionRowsMap.put(settlementInstruction.id, settlementInstructionRow);
						}
					}
				}
			}
			else if(type == SI_FUTURE){
				for(ISSP_ICCS_CoreRest.SettlementInstruction settlementInstruction : componentController.pageController.coreRest.getSettlementInstructions()){
					if(settlementInstruction.type.code == type && settlementInstruction.cycle != null && settlementInstruction.cycle.cycleId == selectedCycle){
						// Retrieve the participationRow
						ParticipationRow participationRow = participationRowsMap.get(settlementInstruction.participation.id);

						if(participationRow != null){	
							// Add a settlementInstructionRow in the participationRow
							SettlementInstructionRow settlementInstructionRow = new SettlementInstructionRow(participationRow, settlementInstruction.id, true);
							participationRow.settlementInstructionRows.add(settlementInstructionRow);
							// Add it in the settlementInstructionRowsMap as well
							settlementInstructionRowsMap.put(settlementInstruction.id, settlementInstructionRow);
						}
					}
				}
			}
			else{
				for(ISSP_ICCS_CoreRest.SettlementInstruction settlementInstruction : componentController.pageController.coreRest.getCycleSettlementInstructions(selectedCycle)){
					// Retrieve the participationRow
					ParticipationRow participationRow = participationRowsMap.get(settlementInstruction.participation.id);

					if(participationRow != null){
						// Add a settlementInstructionRow in the participationRow
						SettlementInstructionRow settlementInstructionRow = new SettlementInstructionRow(participationRow, settlementInstruction.id, false);
						participationRow.settlementInstructionRows.add(settlementInstructionRow);
						// Add it in the settlementInstructionRowsMap as well
						settlementInstructionRowsMap.put(settlementInstruction.id, settlementInstructionRow);
					}
				}
				
				// For AdHoc cycle participation table, the participations with settlement amount = 0 must be removed from the map
				Map<Integer, ParticipationRow> filteredParticipationRowsMap = new Map<Integer, ParticipationRow>();
				for(Integer participationId : participationRowsMap.keySet()){
					if(participationRowsMap.get(participationId).numericSettlementAmount != 0){
						filteredParticipationRowsMap.put(participationId, participationRowsMap.get(participationId));
					}
				}
				participationRowsMap = filteredParticipationRowsMap;
			}


			/* STEP 4 : Retrieve the old structure if requested */

			if(keepStructure && participationRows != null){
				// Loop on the old participationRows list
				for(ParticipationRow participationRow : participationRows){
					// Retrieve the new participationRow if it exists and set its displaySettlementInstructions variable
					if(participationRowsMap.keySet().contains(participationRow.participationId)){
						participationRowsMap.get(participationRow.participationId).displaySettlementInstructions = participationRow.displaySettlementInstructions;
	
						// Loop on the old settlementInstructionRows list
						for(SettlementInstructionRow settlementInstructionRow : participationRow.settlementInstructionRows){
							// Retrieve the new settlementInstructionRow if it exists and set its displayInstructionLines variable
							if(settlementInstructionRowsMap.keySet().contains(settlementInstructionRow.settlementInstructionId)){
								settlementInstructionRowsMap.get(settlementInstructionRow.settlementInstructionId).displayInstructionLines = settlementInstructionRow.displayInstructionLines;
							}
						}
					}
				}
	
				// Check that the selected filter values belong to the new category map, country map and currency set
				Set<Integer> categoryValuesSet = new Set<Integer>(categoryMap.values());
				if(selectedCategory != '' && selectedCategory != null && !categoryValuesSet.contains(Integer.valueOf(selectedCategory))){
					selectedCategory = '';
				}

				Set<String> countryValuesSet = new Set<String>(countryMap.values());
				if(! countryValuesSet.contains(selectedCountry)){
					selectedCountry = '';
				}

				if(! currencySet.contains(selectedCategory)){
					selectedCategory = '';
				}
			}
			else{
				// Erase the selection
				selectedCategory = '';
				selectedCountry = '';
				selectedCurrency = '';
			}
	
			/* STEP 5 : Set the participationRows list */

			participationRows = new List<ParticipationRow>(participationRowsMap.values());
			participationRows.sort();

			/* STEP 6 : Apply filter to build the category, country and currency SelectOption list */

			applyFilters();
		}
		
		public void partialTableReset(){
			resetTable(true);
		}

		public void applyFilters(){
			Set<String> selectableCategorySet = new Set<String>();
			Set<String> selectableCountrySet = new Set<String>();
			Set<String> selectableCurrencySet = new Set<String>();
			
			for(ParticipationRow participationRow : participationRows){
				List<String> selectableItems = participationRow.applyFilters();
				
				selectableCategorySet.add(selectableItems[0]);
				selectableCountrySet.add(selectableItems[1]);
				selectableCurrencySet.add(selectableItems[2]);				
			}

			// Remove the potential null value from the sets
			selectableCategorySet.remove(null);
			selectableCountrySet.remove(null);
			selectableCurrencySet.remove(null);

			// Set categoryFilter list
			categoryFilter = new List<SelectOption>{new SelectOption('', 'All categories')};
			List<String> categories = new List<String>(selectableCategorySet);
			categories.sort();
			for(String cat : categories){
				categoryFilter.add(new SelectOption(categoryMap.get(cat) + '', cat));
			}

			// Set countryFilter list
			countryFilter = new List<SelectOption>{new SelectOption('', 'All countries')};
			List<String> countries = new List<String>(selectableCountrySet);
			countries.sort();
			
			for(String country : countries){
				if(countryMap.get(country) != null){
					countryFilter.add(new SelectOption(countryMap.get(country), country));
				}
			}

			// Set currencyFilter list
			currencyFilter = new List<SelectOption>{new SelectOption('', 'All currencies')};
			List<String> currencies = new List<String>(selectableCurrencySet);
			currencies.sort();
			for(String curr : currencies){
				currencyFilter.add(new SelectOption(curr, curr));
			}
		}

		// Used to set the transientParticipationsMap
		public Map<Integer, ISSP_ICCS_CoreRest.Participation> getTransientParticipationsMap(){
			Map<Integer, ISSP_ICCS_CoreRest.Participation> participationsMap = new Map<Integer, ISSP_ICCS_CoreRest.Participation>();

			// Retrieve the list of participations from the core
			List<ISSP_ICCS_CoreRest.Participation> participations;
			if(type == SI_ADHOC){
				participations = componentController.pageController.coreRest.getCycleParticipations(selectedCycle);
			}
			else {
				participations = componentController.pageController.coreRest.getParticipations();
			}

			// Retrieve the configuration cashflows with all the details to update the participations
			Map<String, ISSP_ICCS_CoreRest.Cashflow> detailedCashflowMap = new Map<String, ISSP_ICCS_CoreRest.Cashflow>();
			for(ISSP_ICCS_CoreRest.Cashflow cashflow : componentController.pageController.coreRest.getCashflows()){
				detailedCashflowMap.put(cashflow.code, cashflow);
			}
			
			for(ISSP_ICCS_CoreRest.Participation participation : participations){
				// Update the cashflow value of the participation as it is incomplete
				ISSP_ICCS_CoreRest.Cashflow detailedCashflow = detailedCashflowMap.get(participation.cashflow.code);
				if(detailedCashflow != null){
					participation.cashflow.type = detailedCashflow.type;
					participation.cashflow.country = detailedCashflow.country;
					participation.cashflow.accountCode = detailedCashflow.accountCode;
				}
				
				participationsMap.put(participation.id, participation);
			}

			return participationsMap;
		}
		
		// Used to set the transientSettlementInstructionsMap
		public Map<Integer, ISSP_ICCS_CoreRest.SettlementInstruction> getTransientSettlementInstructionsMap(){
			Map<Integer, ISSP_ICCS_CoreRest.SettlementInstruction> settlementInstructionsMap = new Map<Integer, ISSP_ICCS_CoreRest.SettlementInstruction>();

			if(type == SI_ADHOC){
				for(ISSP_ICCS_CoreRest.SettlementInstruction cycleSettlementInstruction : componentController.pageController.coreRest.getCycleSettlementInstructions(selectedCycle)){
					if(cycleSettlementInstruction.instructionLines != null){
						cycleSettlementInstruction.instructionLines.sort();
					}
					settlementInstructionsMap.put(cycleSettlementInstruction.id, cycleSettlementInstruction);
				}
			}
			else if(type == SI_STANDARD){
				for(ISSP_ICCS_CoreRest.SettlementInstruction settlementInstruction : componentController.pageController.coreRest.getSettlementInstructions()){
					if(settlementInstruction.type.code == type && (settlementInstruction.cycle == null /* the following part should disappear once fixed in the core */ || settlementInstruction.cycle.cycleId == '' || settlementInstruction.cycle.cycleId == null)){
						if(settlementInstruction.instructionLines != null){
							settlementInstruction.instructionLines.sort();
						}
						settlementInstructionsMap.put(settlementInstruction.id, settlementInstruction);
					}
				}
			}
			else if(type == SI_FUTURE){
				for(ISSP_ICCS_CoreRest.SettlementInstruction settlementInstruction : componentController.pageController.coreRest.getSettlementInstructions()){
					if(settlementInstruction.type.code == type && settlementInstruction.cycle != null && settlementInstruction.cycle.cycleId == selectedCycle){
						if(settlementInstruction.instructionLines != null){
							settlementInstruction.instructionLines.sort();
						}
						settlementInstructionsMap.put(settlementInstruction.id, settlementInstruction);
					}
				}
			}

			return settlementInstructionsMap;
		}
	}


	public class ParticipationRow implements Comparable{
		public ParticipationTable participationTable {get;set;}

		public Integer participationId {get;set;}

		public ISSP_ICCS_CoreRest.Participation participation { get{ return participationTable.participationsMap.get(participationId); }}

		public List<SettlementInstructionRow> settlementInstructionRows {get;set;}
		public Boolean hasSettlementInstructions { get{ return settlementInstructionRows.size() > 0; }}
		public Boolean isFilteredOut {get;set;}
		public Boolean displaySettlementInstructions {get;set;}
		public Double numericSettlementAmount {
			get{
				if(settlementInstructionRows.isEmpty()){
					return 0;
				}
				if(settlementInstructionRows[0].settlementInstruction.settlementAmount == null){
					return 0;
				}
				return settlementInstructionRows[0].settlementInstruction.settlementAmount;
			}
		}
		public String settlementAmount {get{ return String.valueOf(numericSettlementAmount); }}

		/* Constructor */
		public ParticipationRow(ParticipationTable participationTable, Integer participationId){
			this.participationTable = participationTable;
			this.participationId = participationId;

			isFilteredOut = false;			

			settlementInstructionRows = new List<SettlementInstructionRow>();
			displaySettlementInstructions = false;
		}

		public void showSettlementInstructions(){
			settlementInstructionRows.sort();
			displaySettlementInstructions = true;
		}

		public void hideSettlementInstructions(){
			displaySettlementInstructions = false;
		}

		public List<String> applyFilters(){
			Boolean categoryFilteredOut = participationTable.selectedCategory != '' && participationTable.selectedCategory != null && participation.cashflow.type.id + '' != participationTable.selectedCategory;
			Boolean countryFilteredOut = participationTable.selectedCountry != '' && participationTable.selectedCountry != null && participation.cashflow.country.ISO3Code != participationTable.selectedCountry;
			Boolean currencyFilteredOut = participationTable.selectedCurrency != '' && participationTable.selectedCurrency != null && participation.cashflow.processingCurrency != participationTable.selectedCurrency;

			isFilteredOut = categoryFilteredOut || countryFilteredOut || currencyFilteredOut;

			List<String> selectableItems = new List<String>{null, null, null};

			if(!(countryFilteredOut || currencyFilteredOut)){
				selectableItems[0] = participation.cashflow.type.code;
			}

			if(!(categoryFilteredOut || currencyFilteredOut)){
				selectableItems[1] = participation.cashflow.country.name;
			}

			if(!(categoryFilteredOut || countryFilteredOut)){
				selectableItems[2] = participation.cashflow.processingCurrency;
			}
			return selectableItems;
		}

		public Integer compareTo(Object compareTo) {
			ParticipationRow compareToParticipationRow = (ParticipationRow) compareTo;
			
			if(participationTable.type == SI_ADHOC){
				// Criteria 1 : Check if settlement instructions exist
				if(settlementInstructionRows.size() == 0 && compareToParticipationRow.settlementInstructionRows.size() > 0){ return 1; }
				if(settlementInstructionRows.size() > 0 && compareToParticipationRow.settlementInstructionRows.size() == 0){ return -1; }

				// Criteria 2 : currency
				if(participation.cashflow.processingCurrency < compareToParticipationRow.participation.cashflow.processingCurrency){ return -1; }
				if(participation.cashflow.processingCurrency > compareToParticipationRow.participation.cashflow.processingCurrency){ return 1; }

				// Criteria 3 : cashflow name
				if(participation.cashflow.name < compareToParticipationRow.participation.cashflow.name){ return -1; }
				if(participation.cashflow.name > compareToParticipationRow.participation.cashflow.name){ return 1; }
	
				// Criteria 4 : country name
				if(participation.cashflow.country.name < compareToParticipationRow.participation.cashflow.country.name){ return -1; }
				if(participation.cashflow.country.name > compareToParticipationRow.participation.cashflow.country.name){ return 1; }
			}
			else{
				// Criteria 1 : Check if settlement instructions exist
				if(settlementInstructionRows.size() == 0 && compareToParticipationRow.settlementInstructionRows.size() > 0){ return 1; }
				if(settlementInstructionRows.size() > 0 && compareToParticipationRow.settlementInstructionRows.size() == 0){ return -1; }

				// Criteria 2 : cashflow name
				if(participation.cashflow.name < compareToParticipationRow.participation.cashflow.name){ return -1; }
				if(participation.cashflow.name > compareToParticipationRow.participation.cashflow.name){ return 1; }
	
				// Criteria 3 : country name
				if(participation.cashflow.country.name < compareToParticipationRow.participation.cashflow.country.name){ return -1; }
				if(participation.cashflow.country.name > compareToParticipationRow.participation.cashflow.country.name){ return 1; }
	
				// Criteria 4 : currency
				if(participation.cashflow.processingCurrency < compareToParticipationRow.participation.cashflow.processingCurrency){ return -1; }
				if(participation.cashflow.processingCurrency > compareToParticipationRow.participation.cashflow.processingCurrency){ return 1; }
			}

			return 0;
		}
	}

	
	public class SettlementInstructionRow implements Comparable{
		public ParticipationRow participationRow {get;set;}

		public Integer settlementInstructionId {get;set;}
		
		public ISSP_ICCS_CoreRest.SettlementInstruction settlementInstruction { get{ return participationRow.participationTable.settlementInstructionsMap.get(settlementInstructionId); }}
		
		public Boolean displayInstructionLines {get;set;}

		public SettlementInstructionRow(ParticipationRow participationRow, Integer settlementInstructionId, Boolean displayInstructionLines){
			this.participationRow = participationRow;
			this.settlementInstructionId = settlementInstructionId;
			this.displayInstructionLines = displayInstructionLines;
		}

		public void showInstructionLines(){
			displayInstructionLines = true;
		}

		public void hideInstructionLines(){
			displayInstructionLines = false;
		}

		public Integer compareTo(Object compareTo) {
			SettlementInstructionRow compareToSettlementInstructionRow = (SettlementInstructionRow) compareTo;
			
			// Particular sorting for AdHoc Sis
			if(participationRow.participationTable.type == SI_ADHOC){
				System.debug('sorting : ');
				System.debug('settlementInstruction.isApplied : ' + settlementInstruction.isApplied);
				System.debug('compareToSettlementInstructionRow.settlementInstruction.isApplied : ' + compareToSettlementInstructionRow.settlementInstruction.isApplied);
				System.debug('settlementInstruction.approvalStatus : ' + settlementInstruction.approvalStatus);
				System.debug('compareToSettlementInstructionRow.settlementInstruction.approvalStatus : ' + compareToSettlementInstructionRow.settlementInstruction.approvalStatus);
				
				if(settlementInstruction.isApplied == true & (compareToSettlementInstructionRow.settlementInstruction.isApplied == null || !compareToSettlementInstructionRow.settlementInstruction.isApplied)){ return -1; }
				if(compareToSettlementInstructionRow.settlementInstruction.isApplied == true & (settlementInstruction.isApplied == null || !settlementInstruction.isApplied)){ return 1; }
				
				if(settlementInstruction.approvalStatus == 'Pending Approval' & compareToSettlementInstructionRow.settlementInstruction.approvalStatus != 'Pending Approval'){ return -1; }
				if(settlementInstruction.approvalStatus != 'Pending Approval' & compareToSettlementInstructionRow.settlementInstruction.approvalStatus == 'Pending Approval'){ return 1; }
			}
			
			System.debug('instructionTypeOrderMap : ' + instructionTypeOrderMap);
			System.debug('settlementInstruction : ' + settlementInstruction);
			System.debug('compareToSettlementInstructionRow.settlementInstruction : ' + compareToSettlementInstructionRow.settlementInstruction);
			
			
			return instructionTypeOrderMap.get(settlementInstruction.type.code) - instructionTypeOrderMap.get(compareToSettlementInstructionRow.settlementInstruction.type.code);
		}
	}	
}
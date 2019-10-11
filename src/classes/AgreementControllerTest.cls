@isTest
private class AgreementControllerTest {
	
	@testSetup
	static void setup(){
		
        List<Profile> profilesLst = new List<Profile>(
        	[SELECT 
        		Id,
        		Name
        	 FROM 
        	 	Profile 
        	 WHERE 
        	 	Name IN ('System Administrator', 'IDFS Airline Participation Staff - HO')
        	]
        );
        
        Map<String, Id> profileMap = new Map<String, Id>();
        
        for(Profile prof : profilesLst){
        	profileMap.put(prof.Name, prof.Id);
        }
		
		User user = new User();
		user.Alias = 'astu';
		user.Country = 'Portugal';
		user.Email = 'adobesigntestuser@test.com';
		user.EmailEncodingKey='UTF-8';
		user.FirstName = 'Adobe Sign';
		user.LastName = 'Test User';
		user.LanguageLocaleKey='en_US';
		user.LocaleSidKey='en_US';
		user.ProfileId = profileMap.get('IDFS Airline Participation Staff - HO');
		user.TimeZoneSidKey='America/Los_Angeles';
		user.UserName='adobesigntestuser@test.com';
		user.License_Cost_Center__c = 'XSMW01JO01';

		User user2 = new User();
		user2.Alias = 'astu';
		user2.Country = 'Portugal';
		user2.Email = 'adobesigntestuser2@test.com';
		user2.EmailEncodingKey='UTF-8';
		user2.FirstName = 'Adobe Sign 2';
		user2.LastName = 'Test User 2';
		user2.LanguageLocaleKey='en_US';
		user2.LocaleSidKey='en_US';
		user2.ProfileId = profileMap.get('IDFS Airline Participation Staff - HO');		
		user2.TimeZoneSidKey='America/Los_Angeles';
		user2.UserName='adobesigntestuser2@test.com';
		user2.License_Cost_Center__c = 'XSMW01JO01';

		User admin = new User();
		admin.Alias = 'admin';
		admin.Country = 'Portugal';
		admin.Email = 'adobesigntestadmin@test.com';
		admin.EmailEncodingKey='UTF-8';
		admin.FirstName = 'Adobe Sign Admin';
		admin.LastName = 'Test Admin';
		admin.LanguageLocaleKey='en_US';
		admin.LocaleSidKey='en_US';
		admin.ProfileId = profileMap.get('System Administrator');
		admin.TimeZoneSidKey='America/Los_Angeles';
		admin.UserName='adobesigntestadmin@test.com';
		admin.License_Cost_Center__c = 'XSMW01JO01';
						
		insert new List<User>{user, user2, admin};
	
		System.runAs(admin){

			Group bankMandateGroup = new Group();
			bankMandateGroup.Name = 'Bank_Mandate_Agremeent_Group';
			
			insert bankMandateGroup;
		
			GroupMember gm = new GroupMember();
			gm.GroupId = bankMandateGroup.Id;
			gm.UserOrGroupId = user2.Id; 
			
			insert gm;
	
			Agreement_Types_Access_Group_Mapping__c accessGroupMap = new Agreement_Types_Access_Group_Mapping__c();
			accessGroupMap.Name = 'Bank Mandate';
			accessGroupMap.Group_Name_List__c = 'Bank_Mandate_Agreement_Group';
	
			insert accessGroupMap;
			
		}
		
		echosign_dev1__Agreement_Type__c aggTypeAM = new echosign_dev1__Agreement_Type__c();
		aggTypeAM.Name = 'AM';
		aggTypeAM.Description__c = 'Agency Management';

		echosign_dev1__Agreement_Type__c aggTypeAP = new echosign_dev1__Agreement_Type__c();
		aggTypeAP.Name = 'AP';
		aggTypeAP.Description__c = 'Airline Participation';

		echosign_dev1__Agreement_Type__c aggTypeGT = new echosign_dev1__Agreement_Type__c();
		aggTypeGT.Name = 'GA';
		aggTypeGT.Description__c = 'Generic Type';
				
		echosign_dev1__Agreement_Type__c aggTypeBM = new echosign_dev1__Agreement_Type__c();
		aggTypeBM.Name = 'BM';
		aggTypeBM.Description__c = 'Bank Mandate';
		
		insert new List<echosign_dev1__Agreement_Type__c>{ aggTypeAM, aggTypeAP, aggTypeBM, aggTypeGT};
		
		echosign_dev1__Agreement_Template__c amTemplate = new echosign_dev1__Agreement_Template__c();
		amTemplate.Name = 'My My Agency Managament Agreement Template';
		amTemplate.CurrencyIsoCode = 'USD';
		amTemplate.echosign_dev1__Account__c = '{!AccountId}';
		amTemplate.echosign_dev1__Language__c = 'English (United States)';
		amTemplate.echosign_dev1__Master_Object_Type__c = 'Case';
		amTemplate.echosign_dev1__Name__c	 = '{!IATA_Code__c} – {!CaseNumber} – My Agency Managament Agreement Template';
		amTemplate.Description__c = 'My Agreement Template for the units tests';
		amTemplate.echosign_dev1__Agreement_Type__c = aggTypeAM.Id;
		amTemplate.echosign_dev1__Active__c = true;

		echosign_dev1__Agreement_Template__c bankTemplate = new echosign_dev1__Agreement_Template__c();
		bankTemplate.Name = 'My Bank Mandate Agreement Template';
		bankTemplate.CurrencyIsoCode = 'USD';
		bankTemplate.echosign_dev1__Account__c = '{!AccountId}';
		bankTemplate.echosign_dev1__Language__c = 'English (United States)';
		bankTemplate.echosign_dev1__Master_Object_Type__c = 'Case';
		bankTemplate.echosign_dev1__Name__c	 = '{!IATA_Code__c} – {!CaseNumber} – My Bank Mandate Agreement Template';
		bankTemplate.Description__c = 'My Bank Mandate Agreement Template for the units tests';
		bankTemplate.echosign_dev1__Agreement_Type__c = aggTypeBM.Id;
		bankTemplate.echosign_dev1__Active__c = true;

		echosign_dev1__Agreement_Template__c gtTemplate = new echosign_dev1__Agreement_Template__c();
		gtTemplate.Name = 'My Generic Agreement Template';
		gtTemplate.CurrencyIsoCode = 'USD';
		gtTemplate.echosign_dev1__Account__c = '{!AccountId}';
		gtTemplate.echosign_dev1__Language__c = 'English (United States)';
		gtTemplate.echosign_dev1__Master_Object_Type__c = 'Case';
		gtTemplate.echosign_dev1__Name__c	 = '{!IATA_Code__c} – {!CaseNumber} – My Generic Agreement Template';
		gtTemplate.Description__c = 'My Generic Agreement Template for the units tests';
		gtTemplate.echosign_dev1__Agreement_Type__c = aggTypeGT.Id;
		gtTemplate.echosign_dev1__Active__c = true;
		
		echosign_dev1__Agreement_Template__c apTemplate = new echosign_dev1__Agreement_Template__c();
		apTemplate.Name = 'My Airline Participation Agreement Template';
		apTemplate.CurrencyIsoCode = 'USD';
		apTemplate.echosign_dev1__Account__c = '{!AccountId}';
		apTemplate.echosign_dev1__Language__c = 'English (United States)';
		apTemplate.echosign_dev1__Master_Object_Type__c = 'Case';
		apTemplate.echosign_dev1__Name__c	 = '{!IATA_Code__c} – {!CaseNumber} – My Airline Participation Agreement Template';
		apTemplate.Description__c = 'My Airline Participation Agreement Template for the units tests';
		apTemplate.echosign_dev1__Agreement_Type__c = aggTypeAP.Id;
		apTemplate.echosign_dev1__Active__c = true;
	
		echosign_dev1__Agreement_Template__c countryBasedTemplate = new echosign_dev1__Agreement_Template__c();
		countryBasedTemplate.Name = 'My Generic Agreement Country Based Template';
		countryBasedTemplate.CurrencyIsoCode = 'USD';
		countryBasedTemplate.echosign_dev1__Account__c = '{!AccountId}';
		countryBasedTemplate.echosign_dev1__Language__c = 'English (United States)';
		countryBasedTemplate.echosign_dev1__Master_Object_Type__c = 'Case';
		countryBasedTemplate.echosign_dev1__Name__c	 = '{!IATA_Code__c} – {!CaseNumber} – My Generic Agreement Country Based Template';
		countryBasedTemplate.Description__c = 'My Generic Agreement Country Based Template for the units tests';
		countryBasedTemplate.echosign_dev1__Agreement_Type__c = aggTypeGT.Id;
		countryBasedTemplate.echosign_dev1__Active__c = true;
		countryBasedTemplate.HQ_Country_Based__c = true;

		echosign_dev1__Agreement_Template__c furtherEditRequiredTemplate= new echosign_dev1__Agreement_Template__c();
		furtherEditRequiredTemplate.Name = 'My Generic Agreement Further Edit Req Template';
		furtherEditRequiredTemplate.CurrencyIsoCode = 'USD';
		furtherEditRequiredTemplate.echosign_dev1__Account__c = '{!AccountId}';
		furtherEditRequiredTemplate.echosign_dev1__Language__c = 'English (United States)';
		furtherEditRequiredTemplate.echosign_dev1__Master_Object_Type__c = 'Case';
		furtherEditRequiredTemplate.echosign_dev1__Name__c	 = '{!IATA_Code__c} – {!CaseNumber} – My Generic Agreement Further Edit Req Template';
		furtherEditRequiredTemplate.Description__c = 'My Generic Agreement Further Edit Req Template for the units tests';
		furtherEditRequiredTemplate.echosign_dev1__Agreement_Type__c = aggTypeGT.Id;
		furtherEditRequiredTemplate.echosign_dev1__Active__c = true;
		furtherEditRequiredTemplate.Further_Edit_Required__c = true;
								
		insert new List<echosign_dev1__Agreement_Template__c>{amTemplate, bankTemplate, apTemplate, gtTemplate, countryBasedTemplate, furtherEditRequiredTemplate};

		IATA_ISO_Country__c portugal = new IATA_ISO_Country__c();
		portugal.Name = 'Portugal';
		portugal.ISO_Code_Numeric__c = 620;
		portugal.ISO_Code__c = 'PT'; 
		portugal.Region__c = 'Europe';
		portugal.Allows_eSignature__c = true;

		IATA_ISO_Country__c venezuela = new IATA_ISO_Country__c();
		venezuela.Name = 'Venezuela';
		venezuela.ISO_Code_Numeric__c = 862;
		venezuela.ISO_Code__c = 'VE'; 
		venezuela.Region__c = 'Americas';

		insert new List<IATA_ISO_Country__c>{portugal, venezuela};

		Account acc = new Account();
		acc.Name = 'Airline HQ Example';
		acc.Sector__c = 'Airline';
		acc.Legal_name__c = 'Airline HQ Example LN';
		acc.IATA_ISO_Country__c = portugal.Id;

		Account acc2 = new Account();
		acc2.Name = 'Airline HQ Example 2';
		acc2.Sector__c = 'Airline';
		acc2.Legal_name__c = 'Airline HQ Example 2 LN';
		acc2.IATA_ISO_Country__c = venezuela.Id;

		insert new List<Account>{acc, acc2};

		Account acc3 = new Account();
		acc3.Name = 'Airline Branch Example';
		acc3.Sector__c = 'Airline';
		acc3.Top_Parent__c = acc2.Id;
		acc3.Legal_name__c = 'Airline Branch Example';
		acc3.IATA_ISO_Country__c = portugal.Id;
		
		system.debug('ACC3: ' + acc3);
		
		insert acc3;
		
		Case cse = new Case();
		cse.AccountId = acc.Id;

		Case cse2 = new Case();
		cse2.AccountId = acc2.Id;

		Case cse3 = new Case();
		cse3.Subject = 'Delete';
		cse3.AccountId = acc.Id;
		
		Case cse4 = new Case();
		cse4.AccountId = acc3.Id;
		
		insert new List<Case>{cse, cse2, cse3, cse4};
		
	}

	@isTest static void sendAgreementAutomaticallyTest() {
		
		Case cse = 
			[SELECT 
				Id
			 FROM 
			 	Case
			 WHERE 
			 	Account.IATA_ISO_Country__r.Allows_eSignature__c = TRUE 
			 LIMIT 1
			];

		PageReference pageRef = Page.AgreementTemplateSelection;
       
       	Test.setCurrentPage(pageRef);

       	ApexPages.currentPage().getParameters().put('CaseId', cse.Id);

       	AgreementController ctrl = new AgreementController();

		List<AgreementController.TemplateWrapper> templateOptions = ctrl.getTemplates();

    	system.assert(!templateOptions.isEmpty(), 'There should be templates available to select');

       	ctrl.sendAgreementAutomatically();
		
		Boolean messageFound = findApexPagesMessage(Label.AgreementTemplateNotSelected);
		
		System.assert(messageFound);
        
		for(AgreementController.TemplateWrapper wrapper : templateOptions){
			
			if(!wrapper.template.Further_Edit_Required__c && !wrapper.template.HQ_Country_Based__c){
				wrapper.selected = true;
				break;
			}
			
		}
	
       	ctrl.sendAgreementAutomatically();

	}

	@isTest static void agreementCanOnlyBeCreatedByCaseOwnerTest(){
		
		Case cse = 
			[SELECT 
				Id
			 FROM 
			 	Case
			 WHERE 
			 	Account.IATA_ISO_Country__r.Allows_eSignature__c = TRUE 
			 LIMIT 1
			];

		User user = [SELECT Id FROM User WHERE UserName = 'adobesigntestuser@test.com'];

		System.RunAs(user) {

			PageReference pageRef = Page.AgreementTemplateSelection;
	       
	       	Test.setCurrentPage(pageRef);
	
	       	ApexPages.currentPage().getParameters().put('CaseId', cse.Id);
	
	       	AgreementController ctrl = new AgreementController();
	
			List<AgreementController.TemplateWrapper> templateOptions = ctrl.getTemplates();
	
	    	system.assert(!templateOptions.isEmpty(), 'There should be templates available to select');
			
			for(AgreementController.TemplateWrapper wrapper : templateOptions){
				
				if(!wrapper.template.Further_Edit_Required__c && !wrapper.template.HQ_Country_Based__c){
					wrapper.selected = true;
					break;
				}
				
			}
			
	       	ctrl.editAgreement();
       	
        }
        
	}
	
	@isTest static void agreementFurtherEditRequiredTest() {
		
		Case cse = 
			[SELECT 
				Id
			 FROM 
			 	Case
			 WHERE 
			 	Account.IATA_ISO_Country__r.Allows_eSignature__c = TRUE 
			 LIMIT 1
			];

		PageReference pageRef = Page.AgreementTemplateSelection;
       
       	Test.setCurrentPage(pageRef);

       	ApexPages.currentPage().getParameters().put('CaseId', cse.Id);

       	AgreementController ctrl = new AgreementController();

		List<AgreementController.TemplateWrapper> templateOptions = ctrl.getTemplates();

    	system.assert(!templateOptions.isEmpty(), 'There should be templates available to select');

       	ctrl.sendAgreementAutomatically();
		
		Boolean messageFound = findApexPagesMessage(Label.AgreementTemplateNotSelected);
		
		System.assert(messageFound);
        
		for(AgreementController.TemplateWrapper wrapper : templateOptions){
			
			if(wrapper.template.Further_Edit_Required__c){
				wrapper.selected = true;
				break;
			}
			
		}
		
       	ctrl.sendAgreementAutomatically();

		messageFound = findApexPagesMessage(Label.Agreement_Not_Allow_Automatic_Send);
		
		System.assert(messageFound);
        
	}
	
	@isTest static void editAgreementsTest(){
		
		Case cse = 
			[SELECT 
				Id
			 FROM 
			 	Case
			 WHERE 
			 	Account.IATA_ISO_Country__r.Allows_eSignature__c = TRUE 
			 LIMIT 1
			];
			
		editAgreementTest(cse, 'AM', 'Agency Management');
		editAgreementTest(cse, 'AP', 'Airline Participation');
		
		User user = [SELECT Id FROM User WHERE UserName = 'adobesigntestuser2@test.com'];
		
		System.runAs(user){
			editAgreementTest(cse, 'GA', 'Generic Agreement');
			editAgreementTest(cse, 'BM', 'Bank Mandate');
		}
		
	}
	
	private static void editAgreementTest(Case cse, String templateType, String templateTypeDescription) {

		PageReference pageRef = Page.AgreementTemplateSelection;
       
       	Test.setCurrentPage(pageRef);

       	ApexPages.currentPage().getParameters().put('CaseId', cse.Id);

       	AgreementController ctrl = new AgreementController();
	
		for(SelectOption so : ctrl.templateTypesLst){
			
			String agreementType    = so.getValue();
			String agreementTypeLbl = so.getLabel();
			
			if(agreementTypeLbl.equals(templateTypeDescription)){
				ctrl.templateTypeFilter = agreementType;
				break;
			}
			
		}

       	ctrl.templateNameFilter = 'Template';
       	
       	ctrl.doSearch();

		List<AgreementController.TemplateWrapper> templateOptions = ctrl.getTemplates();

    	system.assert(!templateOptions.isEmpty(), 'There should be templates available to select');

       	ctrl.editAgreement();

		for(AgreementController.TemplateWrapper wrapper : templateOptions){
			
			if(templateType.equals(wrapper.template.echosign_dev1__Agreement_Type__r.Name)){
				wrapper.selected = true;
				break;
			}
			
		}

       	ctrl.editAgreement();

	}

	@isTest static void eSignatureNotAllowedTest() {

		Case cse = 
			[SELECT 
				Id,
				Owner.Name,
				Account.IATA_ISO_Country__r.Name
			 FROM 
			 	Case
			 WHERE 
			 	Account.IATA_ISO_Country__r.Allows_eSignature__c = FALSE 
			 LIMIT 1
			];
		
		system.debug('Case: ' + cse);
		
		PageReference pageRef = Page.AgreementTemplateSelection;
       
       	Test.setCurrentPage(pageRef);

       	ApexPages.currentPage().getParameters().put('CaseId', cse.Id);

       	AgreementController ctrl = new AgreementController();

		List<AgreementController.TemplateWrapper> templateOptions = ctrl.getTemplates();

    	system.assert(!templateOptions.isEmpty(), 'There should be templates available to select');

		for(AgreementController.TemplateWrapper wrapper : templateOptions){
			
			if(!'BM'.equals(wrapper.template.echosign_dev1__Agreement_Type__r.Name)){
				wrapper.selected = true;
				break;
			}
			
		}
		
       	ctrl.editAgreement();

		String expectedMessage 	= Label.Electronic_Signature_Not_Allowed_Prefix + ' "' + cse.Account.IATA_ISO_Country__r.Name  + '"';
        
        system.debug('EXPECTED MESSAGE: ' + expectedMessage);
        
		Boolean messageFound 	= findApexPagesMessage(expectedMessage);
		
		System.assert(messageFound);

       	ctrl.returnToCase();
       	       	
	}

	@isTest static void eSignatureNotAllowedInHQTest(){
		
		Case cse2 = 
			[SELECT 
				Id,
				Account.IATA_ISO_Country__r.Name,
				Account.Top_Parent__r.IATA_ISO_Country__r.Name
			 FROM 
			 	Case
			 WHERE 
			 	Account.Top_Parent__c != NULL 
			 AND 
			 	Account.Top_Parent__r.IATA_ISO_Country__r.Allows_eSignature__c = FALSE 
			 LIMIT 1
			];

       	ApexPages.currentPage().getParameters().put('CaseId', cse2.Id);

       	AgreementController ctrl = new AgreementController();

		List<AgreementController.TemplateWrapper> templateOptions = ctrl.getTemplates();

    	system.assert(!templateOptions.isEmpty(), 'There should be templates available to select');

		for(AgreementController.TemplateWrapper cbWrapper : templateOptions){
			
			if(cbWrapper.template.Name.contains('Country Based')){
				system.debug('CB Wrapper: ' + cbWrapper.template.Name);
				cbWrapper.selected = true;
				break;
			}
			
		}

       	ctrl.editAgreement();

		String expectedMessage = Label.Electronic_Signature_Not_Allowed_Prefix + ' "' + cse2.Account.Top_Parent__r.IATA_ISO_Country__r.Name  + '" from HQ';
		
		system.debug('EXPECTED MESSAGE: ' + expectedMessage);
		
		Boolean messageFound = findApexPagesMessage(expectedMessage);
		
		System.assert(messageFound);       	

       	ctrl.returnToCase();
       	
	}
	
	@isTest static void sendAgreementExceptionTest() {

		PageReference pageRef = Page.AgreementTemplateSelection;
       
       	Test.setCurrentPage(pageRef);

       	AgreementController ctrl = new AgreementController();

		Boolean messageFound = findApexPagesMessage('Unable to fetch the case information');
		
		System.assert(messageFound);
		
		Case cse = 
			[SELECT 
				Id
			 FROM 
			 	Case
			 WHERE 
			 	Subject = 'Delete'
			 LIMIT 1
			];
			
	 	ApexPages.currentPage().getParameters().put('CaseId', cse.Id);
 	    
 	   	AgreementController newCtrl = new AgreementController();
 	    
 	   	List<AgreementController.TemplateWrapper> templateOptions = ctrl.getTemplates();
 	    
		for(AgreementController.TemplateWrapper wrapper : templateOptions){
			
			if(!wrapper.template.Further_Edit_Required__c && !wrapper.template.HQ_Country_Based__c){
				wrapper.selected = true;
				break;
			}
			
		}

		delete cse; 
		
       	newCtrl.editAgreement();
       	
       	messageFound = findApexPagesMessage('Unable to create the agreement from the selected template');
       	
   		System.assert(messageFound);

	}
	
	private static Boolean findApexPagesMessage(String expectedMessage){
		
		ApexPages.Message[] pageMessages = ApexPages.getMessages();
		
		System.assertNotEquals(0, pageMessages.size());

		Boolean messageFound = false;

		for(ApexPages.Message message : pageMessages) {
			
			system.debug('MESSAGE DETAIL: ' + message.getDetail());
			
			if(message.getDetail().contains(expectedMessage)){
				return true;
			}

		}

		return false;
				
	}
	
}
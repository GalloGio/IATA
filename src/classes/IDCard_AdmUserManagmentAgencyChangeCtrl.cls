public class IDCard_AdmUserManagmentAgencyChangeCtrl extends IDCardAbstractController{

	public Map<String, AgencyChangeWrapper> changes {get;set;}
	
	public Map<String, AgencyChangeWrapper> currentRecords {get;set;}

	public List<SelectOption> IATAcodes {get;set;}
	
	public List<SelectOption> packages {get;set;}
	
	public List<SelectOption> months {get;set;}

	public List<SelectOption> title {get;set;}

	public AgencyChangeWrapper theChosenOne {get;set;}
	
	public boolean moreThan1000Iatacodes {get;set;}

	//USE AS TEMP
	public Contact searched {get;set;}
	//public String verNum {get;set;} 
	//public String IATACode {get;set;}
	public string removeId {get;set;}
	public string addid {get;set;}
    //public String LastName {get;set;}
    //public Date DateOfBirth {get;set;}
    //public String UIR {get;set;}

	public boolean success {get;set;}


	
	public IDCard_AdmUserManagmentAgencyChangeCtrl(){
		initialize(true);
		searched = new Contact();
		changes = new Map<String, AgencyChangeWrapper> ();
		currentRecords = new Map<string,AgencyChangeWrapper>();
		
		
		if(keyContactAndDelegateForAccountList.values().size()<=50){
            	IATAcodes = new list<SelectOption>();
				IATAcodes.add(new SelectOption('','-- None --'));
				for(string ic : keyContactAndDelegateForAccountList.keyset()){
					IATAcodes.add(new SelectOption(ic, ic));	
				}	
				IATAcodes.sort();
            }else{
            	moreThan1000Iatacodes = true;
            }
		
		
		
		packages = new List<SelectOption>(); 
        packages.add(new SelectOption('','--None--'));          
        for(Schema.PicklistEntry ple : ID_Card_Application__c.Package_of_Travel_Professionals_Course_1__c.getDescribe().getPicklistValues())
            packages.add(new SelectOption(ple.getValue(),ple.getLabel()));
            
        months = new List<SelectOption>(); 
        months.add(new SelectOption('','--None--'));          
        for(Schema.PicklistEntry ple : ID_Card_Application__c.Start_date_agency_month__c.getDescribe().getPicklistValues())
            months.add(new SelectOption(ple.getValue(),ple.getLabel()));

        title = new List<SelectOption>();
        title.add(new SelectOption('','--None--'));
        for(Schema.PicklistEntry ple : ID_Card_Application__c.Title__c.getDescribe().getPicklistValues())
            title.add(new SelectOption(ple.getValue(),ple.getLabel()));
            
        if(ApexPages.currentPage().getParameters().get('ImagedSaved')!=null){
        	Id idapp= ApexPages.currentPage().getParameters().get('ImagedSaved');
        	List<ID_Card_Application__c> apps = database.query('select Id, Displayed_Name__c, IATA_Code__c, VER_number__c, First_Name__c, Last_name__c, Photo__c, Title__c, Email_admin__c '+
				                                     			'from ID_card_application__c where  Id = :idapp LIMIT 1');
		
			if(apps.size()==1){
				theChosenOne = new AgencyChangeWrapper();
				theChosenOne.newIataCode = apps[0].IATA_Code__c;
				theChosenOne.verNum = apps[0].VER_number__c;
				theChosenOne.photo = apps[0].Photo__c;
				theChosenOne.title = apps[0].Title__c;
                theChosenOne.email = apps[0].Email_admin__c;
				theChosenOne.previousContact = new Contact(FirstName = apps[0].First_name__c, LastName = apps[0].Last_Name__c);
			}			
        	
        }
	}
	

	public void search4Contact(){
		date birthday = searched.Date_Of_Birth__c;
		string query = ' LastName = \''+(searched.LastName==null ? '' : String.escapeSingleQuotes(searched.LastName))+'\' AND Date_of_birth__c = :birthday ';
		if(!String.isBlank(searched.UIR__c))
			query += 'AND UIR__c = \''+(searched.UIR__c==null ? '' : String.escapeSingleQuotes(searched.UIR__c)) +'\' ';
		if(!String.isBlank(searched.VER_Number_2__c))
			query += 'AND VER_Number_2__c = \''+(searched.VER_Number_2__c==null ? '' : String.escapeSingleQuotes(searched.VER_Number_2__c)) +'\' ';
		
		
		system.debug(LoggingLevel.ERROR,'[search4Contact] execute query WHERE '+query);
		List<Contact> findContact = database.query('SELECT Name, FirstName, LastName, Phone, Email, Date_of_Birth__c, IATA_Code__c, Middle_Initial__c, Position__c, Duties__c, '+ 
		                                    	'VER_Number_2__c, Function__c, AccountId, Title, Start_Date_Agency_Month__c,  Start_Date_Agency_year__c, Start_Date_Industry__c, '+
		                                    	'Gender__c, Salutation, Revenue_Confirmation__c, Hours_per_week__c, AgencyShare_Confirmation__c, UIR__c '+
                                     			'FROM contact WHERE  '+query);
		
		for(Contact c : findContact){
			AgencyChangeWrapper acg = new AgencyChangeWrapper();
			acg.previousContact = c;
			acg.verNum = c.Ver_Number_2__c;
			acg.oldIATACode = c.IATA_Code__c;
			acg.title = c.Title;
            acg.firstName = c.FirstName;
            acg.lastName = c.LastName;
            acg.email = c.Email;
			currentRecords.put(acg.verNum, acg);
		}if(findcontact.size()==0) {
			//currentRecord.previousContact =NULL;
			  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Impossible to find a Contact using these information.'));
		}
		
		
		//look for the images:
		for(AggregateResult idcapp : [SELECT MAX(Valid_to_date__c) vd, VER_number__c ver, Photo__c ph, id id FROM ID_Card__c WHERE VER_Number__c IN :currentRecords.keyset() GROUP BY VER_Number__c, Photo__c, id]){
		system.debug('------------ currentRecords.keyset() = '+currentRecords.keyset() + ' -- EXTRACTING: '+String.valueOf(idcapp.get('ver')));
			currentRecords.get(String.valueOf(idcapp.get('ver'))).Photo = String.valueoF(idcapp.get('ph'));
		}
		return;
	}
	
	public void confirmContact(){
		success = true;
		if(String.isBlank(addId)){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You have to select a valid existing Id Card applicant.'));
			success = false;
			//return;
		}
		theChosenOne = currentRecords.get(addid);

		String fNameSize = theChosenOne.firstName;
        String lNameSize = theChosenOne.lastName;
        Integer totalSize = fNameSize.length() + lNameSize.length();

		system.debug('theChosenOne ' + theChosenOne + ' addid ' + addid);

		if(String.isBlank(theChosenOne.newIataCode) || !keyContactAndDelegateForAccountList.keyset().contains(theChosenOne.newIataCode)){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You have to select a valid IATA code for the applicant'));
			//theChosenOne = null;
			success = false;
			//return;
		}
		if(theChosenOne.newIataCode == theChosenOne.oldIATACode){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The new IATA code must be different from the previous one'));
			//theChosenOne = null;
			success = false;
			//return;
		}

		if(String.isBlank(theChosenOne.startyear)){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Schema.SobjectType.ID_Card_Application__c.fields.Start_Date_Agency_year__c.label+': please input a value'));
        	//theChosenOne = null;
			success = false;
			//return;
        }

        if(String.isBlank(theChosenOne.startmonth)){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Schema.SobjectType.ID_Card_Application__c.fields.Start_Date_Agency_month__c.label+': please input a value'));
        	//theChosenOne = null;
			success = false;
			//return;
        }

        if(String.isBlank(theChosenOne.email)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Schema.SobjectType.Contact.fields.Email.label+' : please insert a Email Address.'));
                success = false;
        }

        if(String.isBlank(theChosenOne.title)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Schema.SobjectType.Contact.fields.Title.label+' : please select a Title.'));
                success = false;
        
        }

        if((fNameSize.length() + lNameSize.length()) > 22){
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR,'The concatenation of First and Last Name should not pass 22 characters, you have now ' + totalSize + ' characters. Please reduce the Last Name.'));
        }
		try{
			Integer year = Integer.valueOf(theChosenOne.startyear);
			if(year>date.today().year()){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Schema.SobjectType.ID_Card_Application__c.fields.Start_Date_Agency_year__c.label+': the year cannot be greater than '+date.today().year()));
        		//theChosenOne = null;
				success = false;
				//return;
			}else if(year<theChosenOne.previousContact.Date_of_birth__c.year()){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Schema.SobjectType.ID_Card_Application__c.fields.Start_Date_Agency_year__c.label+': the year cannot be lower than '+theChosenOne.previousContact.Date_of_birth__c.year()));
        		//theChosenOne = null;
				success = false;
				//return;
			}
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Schema.SobjectType.ID_Card_Application__c.fields.Start_Date_Agency_year__c.label+' : please insert a valid year.'));
			//theChosenOne = null;
			success = false;
			//return;
		}
		
		if(theChosenOne != null){
			String iataCode = theChosenOne.newIataCode;
		
			List<Account> accStatus = [SELECT Status__c from Account where IATACode__c = :iataCode LIMIT 1];

			if(!accStatus.isEmpty()){
				if(accStatus[0].Status__c == IDCardUtil.ACCOUNT_STATUS_TERMINATED){
					String addIATACodeToLabel = Label.IDCard_Error_Message_Terminated_Account;
					addIATACodeToLabel = addIATACodeToLabel.replace('{iata_code}',iataCode);
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,addIATACodeToLabel));
					success = false;
					//theChosenOne.TerminatedIATACode = true;
				}
			}
		}

		if(success == false)
			return; 

		//changes.put(acw.verNum, acw);
		List<ID_Card_Application__c> openApplications = [SELECT Id
			                                           FROM ID_Card_Application__c
			                                           WHERE VER_Number__c = :theChosenOne.verNum
			                                           AND  (Application_Status__c = 'Pending' OR 
			                                                 Application_Status__c = 'Unpaid'  OR
			                                                (Mass_order_Application__c <> NULL AND Application_Status__c = :IDCardUtil.single_application_status_waiting))];
		
		if(openApplications.size()>0){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The contact selected can\'t be selected because he has an operation in pending status.'));
			theChosenOne = null;
			return;
		}
		
		
		theChosenOne.previousContact.AccountId = keyContactAndDelegateForAccountList.get(theChosenOne.newIataCode).Account__c;
		ID_Card_Application__c idcapp = IDCardApplicationFactory.createIDCardApplication(theChosenOne.previousContact,'Replacement');
        idcapp.Package_of_Travel_Professionals_Course_1__c = theChosenOne.packageTravel1;
        idcapp.Package_of_Travel_Professionals_Course_2__c = theChosenOne.packageTravel2;
        idcapp.Photo__c = theChosenOne.photo;
        idcapp.Start_Date_Agency_Month__c = theChosenOne.startmonth;
        idcapp.Start_Date_Agency_Year__c = theChosenOne.startyear;
        idcapp.Email_admin__c = theChosenOne.email;
        idcapp = IDCardApplicationFactory.applyApplicationFees(idcapp,keyContactAndDelegateForAccountList.get(theChosenOne.newIataCode).Account__r,null);
		
		database.Saveresult res = database.insert(idcapp,true);
		if(!res.isSuccess()){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Applicant '+idcapp.Displayed_Name__c+' with VER number '+idcapp.VER_Number__c+': '+res.getErrors()[0].getMessage()));
		}else{
			currentRecords = new Map<string,AgencyChangeWrapper>();
			addId = null;
			currentRecords.clear();
		}
		
		return;
 		
		
	}
	
	public void complete(){
		theChosenOne = null;
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'The change of agency was successfully requested. The ID card will be available at the end of payment process. '));
		return ;
	}
	
	public string getImageLink(){
        string ver = theChosenOne.verNum;
        return IDCardUtil.EncryptEncodeParameter(ver).replaceAll('%', '%25');
    }
	
	/*
	public void removeContact(){
		changes.remove(removeId);
		return;
	}
	
	public PageReference processChanges(){
		List<ID_Card_Application__c> apps = new List<ID_Card_Application__c>();
		
		//for(String vernum:changes.keySet()){
		for(AgencyChangeWrapper acw : changes.values()){
			acw.previousContact.AccountId = keyContactAndDelegateForAccountList.get(acw.newIataCode).Account__c;
			ID_Card_Application__c idcapp = IDCardApplicationFactory.createIDCardApplication(acw.previousContact,'Replacement');
	        idcapp.Package_of_Travel_Professionals_Course_1__c = acw.packageTravel1;
	        idcapp.Package_of_Travel_Professionals_Course_2__c = acw.packageTravel2;
	        idcapp = IDCardApplicationFactory.applyApplicationFees(idcapp,keyContactAndDelegateForAccountList.get(acw.newIataCode).Account__r,null);
	        apps.add(idcapp);
		}
		
		system.savepoint sp = database.setSavepoint();
		list<database.Saveresult> sres = database.insert(apps,true);
		boolean err = false;
		for(integer i=0; i<apps.size(); i++){
			database.Saveresult sr = sres[i];
			if(!sr.isSuccess()){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Applicant '+apps[i].Displayed_Name__c+' with VER number '+apps[i].VER_Number__c+': '+sr.getErrors()[0].getMessage()));
				err = true;
			}
		}
		if(err){
			database.rollback(sp);
			return null;
		}else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'The changement of agency was successfully requested for '+apps.size()+' applicants'));
			changes = new map<String, AgencyChangeWrapper>();
		}
		return new PageReference('/IDCard_AdmUserManagment');
	}
	*/
	
	public pagereference cancel(){
		return Page.IDCard_AdmUserList;
		return new pagereference('/IDCard_AdmUserList');
	}
	
	
	public class AgencyChangeWrapper {
		public String verNum {get;set;}
		public String oldIATACode  {get;set;}
		public String newIataCode  {get;set;}
        public string photo {get;set;}
		public boolean confirm {get;set;}
		public Contact previousContact {set;get;}
		public String packageTravel1 {get;set;}
		public String packageTravel2 {get;set;}
		public String title {get;set;}
        public String firstName {get;set;}
        public String lastName {get;set;}
        public String email {get;set;}
        public String displayedName {get;set;}
		//public boolean TerminatedIATACode {get;set;}
		public string startmonth {get;set;}
		public string startyear {get;set;}
		
        public String awsImageURL {
        	get{
        		return IDCardUtil.AWSImageAuthorizationLink(this.photo);
    		} set;}

		public AgencyChangeWrapper(){
			
		}
		
		
	}
	
	
	public void printerr(String msg){
		Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.error,msg));
	}
	
	public integer getChangesSize(){
		return changes.size();
	}
	public integer getCurrentRecordsSize(){
		return currentRecords.keyset().size();
	}

}
public with sharing class AMS_AccreditationContactController {
    
    public List<AccreditationContactWrapper> acWrapper {get; set;}
    public List<AMS_Accreditation_Contact__c> acList {get; set;}
    public AMS_Pax_Accreditation_Form__c aoa {get; set;}
    public Integer toUnselect {get; set;}
    public Integer toNullify {get; set;}
    public boolean successfulSave {get; set;}
    public List<AMS_Accreditation_Contact__c> forDeletion {get; set;}
    public String rowNumber {get; set;}
    public String linkedRecordId {get; set;}
    public List<AccountWrapper> accountWrapper {get; set;}
    public decimal ownership {get; set;}
    public boolean blockOwnershipEdit {get; set;}
    public boolean isCorrection {get; set;}
    public boolean isCertificationOSCAR {get; set;}
    public boolean isCargoAgency {get; set;}
    public boolean isCASSAssociate {get; set;}
    private Id AcPersonRt;
    private Id AcCompanyRt;
    private Id AcCurrentCompanyRt;
    private Id AcCurrentOwnerRt;
    public List<TrainedStaffWrapper> trainedStaffWrapper{get; set;}
    public boolean isNewProcess {get; set;}
    public boolean isChangeProcess {get; set;}
    public boolean isNewGenProcess {get; set;}
    public List<AMS_Agency_Regulation__c> agRegList {get; set;} //AMSU-132

    public List<AgRegItemWrapper> agRegValuesForDisplay{ //AMSU-132
        get{
            
            if(agRegValuesForDisplay == null) {
                agRegValuesForDisplay = new List<AgRegItemWrapper>();

                //FM AMSU-132 - Load Agency Regulations records associated with account
                this.agRegList = [SELECT Id,Account__c,Certificate_Name__c,Expired__c,Expiry_Date__c,
                            First_Name__c,Issuer__c,Last_Name__c,Name,OSCAR__c,OSCAR__r.Name,Type_Of_Certificate__c,
                             Position__c, Issued_on__c, Validity__c, Air_cargo_transport_business_exp__c,
                             IATA_FIATA_training_history__c, Training_dangerous_goods_completed__c, Registration_Number__c
                            FROM AMS_Agency_Regulation__c 
                            WHERE Account__c = :this.aoa.SAAM_Case__r.OSCAR__r.Account__c 
                            AND Type_Of_Certificate__c = 'DGR'
                            AND (Expiry_Date__c = LAST_N_YEARS:2 OR Expiry_Date__c > LAST_N_YEARS:2)];
                
                for(AMS_Agency_Regulation__c reg : this.agRegList){
                    Boolean bExist = false;
                    if(reg.OSCAR__c != null){
                        agRegValuesForDisplay.add(new AgRegItemWrapper(reg, false, false, false));
                    }else{
                        agRegValuesForDisplay.add(new AgRegItemWrapper(reg, false, false, true));
                    }
                    
                }
            }
            return agRegValuesForDisplay;
        }
        set;
    }

    public Boolean selectAll{ //AMSU-132
        get{
            if(selectAll == null) selectAll = false;
            return selectAll;
        }
        set;
    }

    //FM 09-10-2017 - AMSU-72 - get date format based on user regional settings
    date myDate = date.newInstance(2001, 12, 21);
    public String dateFormatToShow {
        get {
            String s = myDate.format();
            s = s.replace('2001', 'YYYY');
            s = s.replace('12', 'MM');
            s = s.replace('21', 'DD');
            return s;
        }
    }

    public static Map<String, String> accreditationContactRT = new Map<String, String> {

            RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person') => 'Person',
            RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner') => 'Person',

            RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Company') => 'Company',
            RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Company_Owner') => 'Company',

            RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Trained_Staff') => 'Trained Staff'


    };

    public static final List<String> NGOWNEREDITABLECHANGES = new List<String>{'minor shareholding','major shareholding','ownership'};

    
    // TODO at a later stage: after having 100% ownershiprate in total and saving the owners, need to update OSCAR's field that states that the 
    // Ownership is ready, so that the validation in the wizard can prevent users from using the left panel until the ownership + certain fields on OSCAR are filled.
    public AMS_AccreditationContactController(ApexPages.StandardController stdController)
    {
        acWrapper = new List<AccreditationContactWrapper>();
        accountWrapper = new List<AccountWrapper>();
        trainedStaffWrapper = new List<TrainedStaffWrapper>();
        String aoaId = ApexPages.CurrentPage().getParameters().get('id');
        successfulSave = false;
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
        if(aoa == null)
        {
            
            List<AMS_Pax_Accreditation_Form__c> aoaList = [select id, Name, Account_Name__c, IATACode__c, Type_of_Operation__c, Shipping_Street__c, Shipping_Postal_Code__c, 
                            Shipping_City__c, Shipping_State__c, Shipping_Country__c, SAAM_Case__r.AccountId, SAAM_Case__r.OSCAR__r.Account__c, 
                            SAAM_Case__r.OSCAR__r.Account__r.Location_class__c, SAAM_Case__r.OSCAR__r.Account__r.CNS_Agency__c, 
                            SAAM_Case__r.OSCAR__r.Account__r.Location_Type__c, SAAM_Case__r.OSCAR__r.Process__c, SAAM_Case__r.OSCAR__r.Type_of_change__c,
                            SAAM_Case__r.OSCAR__r.Account__r.Sector__c, SAAM_Case__r.OSCAR__r.Account__r.Category__c,
                            SAAM_Case__r.OSCAR__r.CNS_process__c, ANG_IsNewGenAgency__c,  SAAM_Case__r.OSCAR__r.ANG_Type_Of_Change__c, SAAM_Case__r.OSCAR__r.RecordTypeId,
                            SAAM_Case__r.OSCAR__c,SAAM_Case__r.OSCAR__r.AMS_Target_Agency__c //FM - AMSU-1
                            from AMS_Pax_Accreditation_Form__c where Id =: stdController.getRecord().id];
            this.aoa = aoaList.get(0);
            String commaSeparatedFields = AMS_AccreditationContactHelper.loadFieldsDynamically('AMS_Accreditation_Contact__c');
            String query = 'select ' + commaSeparatedFields + ', Company__r.Legal_Name__c, AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c, AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__r.Location_Type__c, AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Process__c, AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Type_of_change__c from AMS_Accreditation_Contact__c where  RecordType.DeveloperName IN (\'Company\',\'Current_Company_Owner\',\'Current_Owner\',\'Person\', \'Trained_Staff\') and AMS_Pax_Accreditation_Form__c = \'' + this.aoa.Id + '\'';
            acList = Database.query(query);
            if(acList.size() > 0)
            {
                
                // Need to go over the list to get to know if any Companies belong to the ownership to get a map of Ac.Id and Account
                Set<Id> accountsToLoadSet = new Set<Id>();
                for(AMS_Accreditation_Contact__c acTemp : acList)
                {
                    if(accreditationContactRT.get(acTemp.RecordTypeId) == 'Company')
                    {
                        accountsToLoadSet.add(acTemp.Company__c);
                    }
                }
                
                Map<Id, Account> accList = new Map<Id, Account>();
                if(accountsToLoadSet.size() > 0)
                {
                    accList = new Map<Id, Account>([select Id, Email__c, Name, Legal_Name__c, IATACode__c, Phone_Number__c from Account where Id in :accountsToLoadSet]);
                }
                
                AccreditationContactWrapper wrapper;
                AccountWrapper accWrapper;
                for(AMS_Accreditation_Contact__c ac : acList)
                {
                    if(accreditationContactRT.get(ac.RecordTypeId) == 'Trained Staff'){
                        trainedStaffWrapper.add(new TrainedStaffWrapper(ac));
                    }
                    else if(accreditationContactRT.get(ac.RecordTypeId) != 'Company')
                    {
                        wrapper = new AccreditationContactWrapper(ac);
                        acWrapper.add(wrapper); 
                    } else
                    {
                        if(accList.get(ac.Company__c) != null)
                        {
                            System.debug('********************* company found: '+accList.get(ac.Company__c));
                            accWrapper = new AccountWrapper(ac, accList.get(ac.Company__c), accList.get(ac.Company__c).Id, false);
                        }
                        else
                        {
                            System.debug('********************* no Company__c');
                            accWrapper = new AccountWrapper(ac, new Account(), '', false);
                        }
                        accountWrapper.add(accWrapper); 
                    }
                    
                }
                
            }
        }
        if(aoa.SAAM_Case__r.OSCAR__r.Account__r.CNS_Agency__c && aoa.SAAM_Case__r.OSCAR__r.Account__r.Location_Class__c == 'R')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'The ownership information is not needed for CASS Associates in CNS.'));
         
        }

        AcPersonRt = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');
        AcCompanyRt = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Company');
        AcCurrentCompanyRt = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Company_Owner');
        AcCurrentOwnerRt = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner');

        forDeletion = new List<AMS_Accreditation_Contact__c>();

        Boolean typeOfChangeContainsOwnershipToIATA = false;

        if(aoa.SAAM_Case__r.OSCAR__r.Type_of_change__c != null && aoa.SAAM_Case__r.OSCAR__r.Type_of_change__c.contains(AMS_Utils.OWNERSHIP_IATA))
            typeOfChangeContainsOwnershipToIATA = true;

        blockOwnershipEdit = (aoa.SAAM_Case__r.OSCAR__r.Account__r.Location_Type__c != AMS_Utils.HO
                                && aoa.SAAM_Case__r.OSCAR__r.Account__r.Location_Type__c != AMS_Utils.AO
                                && aoa.SAAM_Case__r.OSCAR__r.Account__r.Location_Type__c != AMS_Utils.HE
                                && aoa.SAAM_Case__r.OSCAR__r.Account__r.Location_Type__c != AMS_Utils.GE
                                && aoa.SAAM_Case__r.OSCAR__r.Process__c != AMS_Utils.COR
                                && aoa.SAAM_Case__r.OSCAR__r.Process__c != AMS_Utils.AGENCYCHANGES)
                            || typeOfChangeContainsOwnershipToIATA
                            || (aoa.SAAM_Case__r.OSCAR__r.CNS_process__c && aoa.SAAM_Case__r.OSCAR__r.Account__r.Location_Class__c =='R');

        if(aoa.ANG_IsNewGenAgency__c && (aoa.SAAM_Case__r.OSCAR__r.Process__c == AMS_Utils.MCAE || aoa.SAAM_Case__r.OSCAR__r.Process__c == AMS_Utils.NEWAE || (aoa.SAAM_Case__r.OSCAR__r.ANG_Type_Of_Change__c != null && ANG_AgencyChangesHelper.containsChange(NGOWNEREDITABLECHANGES,aoa.SAAM_Case__r.OSCAR__r.ANG_Type_Of_Change__c.toLowerCase()))))
            blockOwnershipEdit = false;

        if(aoa.ANG_IsNewGenAgency__c && aoa.SAAM_Case__r.OSCAR__r.Process__c == AMS_Utils.NGCHANGES && (aoa.SAAM_Case__r.OSCAR__r.ANG_Type_Of_Change__c == null || !(ANG_AgencyChangesHelper.containsChange(NGOWNEREDITABLECHANGES,aoa.SAAM_Case__r.OSCAR__r.ANG_Type_Of_Change__c.toLowerCase()))))
            blockOwnershipEdit = true;

        isCorrection = aoa.SAAM_Case__r.OSCAR__r.Process__c == AMS_Utils.COR;
        isCargoAgency = aoa.SAAM_Case__r.OSCAR__r.Account__r.Sector__c == AMS_Utils.SECTOR_CARGO;
        isCASSAssociate = aoa.SAAM_Case__r.OSCAR__r.Account__r.Category__c == AMS_Utils.CATEGORY_CASSASSOCIATE;

        isCertificationOSCAR = aoa.SAAM_Case__r.OSCAR__r.Process__c == AMS_Utils.CERTIFICATION ? true : false;

        isNewProcess = (aoa.SAAM_Case__r.OSCAR__r.RecordTypeId == AMS_Utils.RECTYPE_NEW)? true : false;
        isChangeProcess = aoa.SAAM_Case__r.OSCAR__r.RecordTypeId == AMS_Utils.RECTYPE_CHANGE? true : false;
        isNewGenProcess = AMS_Utils.oscarNewGenProcesses.contains(aoa.SAAM_Case__r.OSCAR__r.Process__c) ? true : false;

        //FM AMSU-1
        if(isCorrection){
            AMS_OSCAR__c auxOscar = new AMS_OSCAR__c();
            auxOscar.Account__c = this.aoa.SAAM_Case__r.OSCAR__r.Account__c;
            auxOscar.AMS_Target_Agency__c = this.aoa.SAAM_Case__r.OSCAR__r.AMS_Target_Agency__c;
            auxOscar.Id = this.aoa.SAAM_Case__r.OSCAR__c;
            auxOscar.AMS_Online_Accreditation__c = stdController.getRecord().id;
            this.oscarObj = auxOscar;
        }
    }
    
    public void addEmptyRow()
    {
        Id rt = this.aoa.SAAM_Case__r.OSCAR__r.Process__c == AMS_Utils.AGENCYCHANGES || this.aoa.SAAM_Case__r.OSCAR__r.Process__c == AMS_Utils.COR ? AcCurrentOwnerRt : AcPersonRt;

        AccreditationContactWrapper acWrapper = new AccreditationContactWrapper(new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = this.aoa.Id, RecordTypeId =  rt));
        this.acWrapper.add(acWrapper);
    }
    
    public void cloneLastRow()
    {

        if(this.acWrapper.size() > 0)
        {

            AMS_Accreditation_Contact__c lastRowACContact = this.acWrapper.get(this.acWrapper.size()-1).ac;

            if(lastRowACContact != null && lastRowACContact.Agency_Owner__c && blockOwnershipEdit){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'The last person is an Owner and cannot be copied because ownership editing is blocked.'));
                return;
            }

            if(this.acWrapper.get(this.acWrapper.size()-1).ac != null)
            {
                AccreditationContactWrapper newAc = new AccreditationContactWrapper(this.acWrapper.get(this.acWrapper.size() - 1).ac.clone());
                newAc.ac.RecordTypeId = AcPersonRt;
                this.acWrapper.add(newAc);
            }
        }
    }
    
    public void addEmptyCompanyRow()
    {
        Id rt = this.aoa.SAAM_Case__r.OSCAR__r.Process__c == AMS_Utils.AGENCYCHANGES || this.aoa.SAAM_Case__r.OSCAR__r.Process__c == AMS_Utils.COR ? AcCurrentCompanyRt : AcCompanyRt;
        
        this.accountWrapper.add(new AccountWrapper(new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = this.aoa.Id, RecordTypeId = rt, Last_Name__c = '-', Phone__c = '-'), new Account(), '', true));
    }

    public void addEmptyTrainedStaffRow()
    {
        Id rt = AMS_Utils.AccreditationContactTrainedStaffRT;
        
        this.trainedStaffWrapper.add(new TrainedStaffWrapper(new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = this.aoa.Id, RecordTypeId = rt/*, Last_Name__c = '-', Phone__c = '-'*/)));
    }
    
    public PageReference removeFromAcList()
    {
        //AMS_Accreditation_Contact__c acToDelete = this.acList.get(this.toUnselect);
        AMS_Accreditation_Contact__c acToDelete = acWrapper.get(toUnselect).ac;
        
        if(acToDelete.id != null)
        {
            this.forDeletion.add(acToDelete);
        }
        
        this.acWrapper.remove(this.toUnselect);
        return null;
    }

    public PageReference removeFromTsList()
    {
        //AMS_Accreditation_Contact__c acToDelete = this.acList.get(this.toUnselect);
        AMS_Accreditation_Contact__c acToDelete = trainedStaffWrapper.get(toUnselect).ac;
        
        if(acToDelete.id != null)
        {
            this.forDeletion.add(acToDelete);
        }
        
        //AMSU-132
        if(acToDelete.AgencyRegulation__c != null){
            System.debug('this.agRegValuesForDisplay: ' + this.agRegValuesForDisplay);            

            System.debug('acToDelete.AgencyRegulation__c: ' + acToDelete.AgencyRegulation__c);
            for(AgRegItemWrapper agRegItem : this.agRegValuesForDisplay){
                System.debug('agRegItem: ' + agRegItem);
                if(agRegItem.agReg.id == acToDelete.AgencyRegulation__c){
                    agRegItem.enable = true;
                    agRegItem.selected = false;
                    System.debug('agRegItem.enable: ' + agRegItem.enable);
                    System.debug('agRegItem.selected: ' + agRegItem.selected);
                }
            }
            System.debug('this.agRegValuesForDisplay: ' + this.agRegValuesForDisplay);  
        }
        
        this.trainedStaffWrapper.remove(this.toUnselect);
        return null;
    }
    
    public PageReference removeFromAccountList()
    {
        AMS_Accreditation_Contact__c acToDelete = accountWrapper.get(toUnselect).accountAc;
        if(acToDelete.id != null)
        {
            this.forDeletion.add(acToDelete);
        }
        
        this.accountWrapper.remove(this.toUnselect);
        return null;
    }
    
    public PageReference onSave()
    {
        if(aoa.SAAM_Case__r.OSCAR__r.Account__r.CNS_Agency__c && aoa.SAAM_Case__r.OSCAR__r.Account__r.Location_Class__c == 'R')
        {

            for(AccreditationContactWrapper ac : acWrapper)
            {
                if(ac.ac.Agency_owner__c == true)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'The ownership information is not needed for CASS Associates in CNS.'));
                    return null;
                }
            }
            
        }

        /*
        if(!isNewGenProcess && !calculateTotalOwnership() && !isCertificationOSCAR)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Total ownershiprate for all inserted contacts is ' + ownership + '%. Please set it to 100% before saving.'));
            return null;
        }
        */
        //AMSU-180
        if(!calculateTotalOwnership() && !isCertificationOSCAR)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Total ownershiprate for all inserted contacts is ' + ownership + '%. Please set it to at least 99.99% before saving.'));
            return null;
        }
        
        String firstErrorContact = verifyOwnerFlagIsSelectIfFinancialInterestAboveZero();
        if(firstErrorContact != null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please make sure all contacts with Financial Interest % value greater than zero (0%) are checked as Owners as well. First error with '+firstErrorContact+'.'));
            return null;
        }
        
        Integer numberOfIFAPs = verifyOnlyOneIFAPcontactExists();
        if(numberOfIFAPs > 1)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please make sure only one contact is marked as Financial Assessment Contact.'));
            return null;
        }
        
        String firstErrorDate = verifyDateFormatting();
        if(firstErrorDate != null && firstErrorDate != '')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please make sure the date field format is "YYYY-MM-DD". First error with: '+firstErrorDate));
            return null;
        }

        String duplicatedContacts = verifyEmailDuplication();
        if(duplicatedContacts != null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please make sure the Owners are not using the same email address: '+duplicatedContacts));
            return null;
        }

        String errorMissingExpiryDate = validateMandatoryExpiryDate();
        if(errorMissingExpiryDate != null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMissingExpiryDate));
            return null;
        }

        Integer numberPortalAdmin = 0;
        
        // Verify that no emails entered for "new" contacts are found in the system
        Set<String> emailSetToConfirm = new Set<String>();
        for(AccreditationContactWrapper ac : acWrapper)
        {
            if(ac.recordId == null && ac.ac.Email__c != null)
            {
                if(ac.ac.Email__c != '')
                    emailSetToConfirm.add(ac.ac.Email__c);
            }

            if(ac.ac.Portal_administrator__c == true)
                numberPortalAdmin++;

        }

        if(numberPortalAdmin > 1 /*&& isNewGenProcess AMSU-163*/){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'A maximum of 1 portal administrator is allowed on this page.'));
            return null;
        }


        if(emailSetToConfirm.size() >0)
        {
            Map<Id, Contact> idContactMap = AMS_AccreditationContactHelper.findContactsByEmail(emailSetToConfirm);
            Map<Id, AMS_Person__c> idPersonMap = AMS_AccreditationContactHelper.findPersonsByEmail(emailSetToConfirm);
            if(idContactMap.size() > 0 || idPersonMap.size() > 0)
            {
                Set<String> emailList = new Set<String>();
                for(Contact con : idContactMap.values())
                {
                    emailList.add(con.Email);
                }
                for(AMS_Person__c person : idPersonMap.values())
                {
                    emailList.add(person.Email__c);
                }
                String errorMsg = 'People with the following emails already exist in the system. Please link them to their original records by selecting \"Choose an existing contact\".\n\n[';
                for(String email : emailList)
                {
                    errorMsg = errorMsg + email + ', ';
                }
                errorMsg = errorMsg.subString(0, errorMsg.length()-2)+']';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
                return null;
            }
        }
        
        // If previously selected records are now being marked as removed, deletion needs to happen
        if ( forDeletion.size() > 0 )
        {
            delete(forDeletion);
            forDeletion.clear();
        }
        
        //try
        //{
            // Save Contact Ownership
            if(acWrapper.size() > 0)
            {
                setDateValuesForACs();
                List<AMS_Accreditation_Contact__c> upsertable = new List<AMS_Accreditation_Contact__c>();
                for(AccreditationContactWrapper wrapped : acWrapper)
                {
                    wrapped.ac.Name = wrapped.ac.First_Name__c + ' ' + wrapped.ac.Last_Name__c;
                    upsertable.add(wrapped.ac);
                }
                
                upsert(upsertable);
            }
            
            // Save Company Ownership
            if(accountWrapper.size() > 0)
            {
                Id standardAccountRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
                List<Account> accountInsertList = new List<Account>();
                List<AMS_Accreditation_Contact__c> acUpsertList = new List<AMS_Accreditation_Contact__c>();
                List<Account> acList = new List<Account>();
                Set<Id> idsAux = new Set<Id>();
                Boolean emptyList = false;
                Boolean invalidIataCode = false;
                for (AccountWrapper acw : accountWrapper)
                {
                    if(acw.account.IATACode__c != null)
                    {
                        acList = [SELECT Id, IATACode__c FROM Account WHERE IATACode__c = :acw.account.IATACode__c];
                        if(!acList.isEmpty() && acw.account.Id == null)
                        {
                            emptyList = true;
                        }

                        if(acList.isEmpty())
                        {
                            invalidIataCode = true;
                        }
                    }
                }

                if(emptyList)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please make sure that you link the IATACode that you insert with the right Legal Name.'));
                    return null;
                }

                if(invalidIataCode)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please make sure that you insert an existent IATACode.'));
                    return null;
                }

                for(AccountWrapper aw : accountWrapper)
                {
                    System.debug('ACCOUNT WRAPPER : ' + aw);
                    aw.accountAc.Financial_interest__c = aw.financialInterest;
                    aw.accountAc.Registration_number__c = aw.registrationNumber;

                    if(aw.account.Id == null)
                    {
                        aw.account.Name = aw.account.Legal_Name__c;
                        aw.account.RecordTypeId = standardAccountRtId;
                        aw.account.Reason_for_creation__c = 'Account is missing';
                        accountInsertList.add(aw.account);
                    }
                    aw.accountAc.Agency_owner__c = true;
                }

                if(accountInsertList.size() > 0)
                {
                    insert accountInsertList;
                }

                for(AccountWrapper aw : accountWrapper)
                {
                    aw.accountAc.Company__c = aw.account.Id;
                    aw.accountAc.Name = aw.account.Legal_Name__c;
                    acUpsertList.add(aw.accountAc);
                }
                upsert acUpsertList;
            }

            //save trained staff
            if(trainedStaffWrapper.size() > 0)
            {
                setDateValuesForTrainedStaffACs();
                List<AMS_Accreditation_Contact__c> upsertable = new List<AMS_Accreditation_Contact__c>();
                for(TrainedStaffWrapper tsw : trainedStaffWrapper)
                {
                    tsw.ac.Name = tsw.ac.First_Name__c + ' ' + tsw.ac.Last_Name__c;
                    upsertable.add(tsw.ac);
                }
                
                upsert(upsertable);
            }
            
            successfulSave = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'Records saved!'));
            return null;
        /*      
        }
        catch(Exception e)
        {
            System.debug('************* e: '+e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Something went wrong: '+e));
            return null;
        }
        */
    }
    
    public PageReference onCancel()
    {
        return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
    }
    
    //AMSU-132
    public void doSelectAll(){
        for(AgRegItemWrapper ar : agRegValuesForDisplay){
            ar.selected = selectAll;
        }
    }

    //AMSU-132
    public PageReference saveImport(){
        try {

            List<AMS_Agency_Regulation__c> agRegListLocal = new List<AMS_Agency_Regulation__c>(); 
            System.debug('before saveImport: agRegValuesForDisplay: ' + agRegValuesForDisplay);
            for(AgRegItemWrapper ari : agRegValuesForDisplay){
                System.debug('before saveImport: ari: ' + ari);
                 if(ari.selected){ 
                     ari.enable = false;
                     agRegListLocal.add(ari.agReg);
                 }
            }

            convertExistingAgencyRegulationsToAccContact(this.aoa.Id, agRegListLocal);
            
        } catch(Exception e) {
            //DML Exceptions are sometimes displayed on the page
            //if(e.getTypeName() != 'System.DmlException' || !ApexPages.hasMessages()) ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Couldn\'t save changes '+ e.getMessage()));
            System.debug(loggingLevel.ERROR, '____ [cls AMS_AccreditationContactController - save] error - ' + e.getMessage());
        }
        return null;
    }
    
    
    public boolean calculateTotalOwnership()
    {
        ownership = 0;
        for(AccreditationContactWrapper wrapped : acWrapper)
        {
            if(wrapped.ac.Financial_interest__c != null)
                ownership = ownership + wrapped.ac.Financial_interest__c;
        }
        for(AccountWrapper aWrapped : accountWrapper)
        {
            ownership = ownership + aWrapped.financialInterest;
        }
        
        if(aoa.SAAM_Case__r.OSCAR__r.Account__r.CNS_Agency__c == false && aoa.SAAM_Case__r.OSCAR__r.Account__r.Location_Type__c != 'BR' && ownership < 99.99) //AMSU-180
        {
            return false;
        } else
        {
            return true;
        }
    }

    public String validateMandatoryExpiryDate(){

        for(TrainedStaffWrapper tsw : trainedStaffWrapper)
        {
            
            if(tsw.ac.Type_of_certificate__c == AMS_Utils.CERT_DGR && (tsw.validUntil == null || tsw.validUntil == '')){
            
                String tsFirstName = tsw.ac.First_Name__c == null ? '' : tsw.ac.First_Name__c;
                String tsLastName = tsw.ac.Last_Name__c == null ? '' : tsw.ac.Last_Name__c;

                return tsFirstName + ' ' + tsLastName + ' ' + tsw.ac.Type_of_certificate__c + ' Certificate needs to have the field Valid Until populated.';
            }

        }

        return null;

    }
    
    public String verifyOwnerFlagIsSelectIfFinancialInterestAboveZero()
    {
        for(AccreditationContactWrapper wrapped : acWrapper)
        {
            if (wrapped.ac.Financial_interest__c > 0 && !wrapped.ac.Agency_owner__c)
            {
                return wrapped.ac.First_Name__c + ' ' + wrapped.ac.Last_Name__c;
            }
        }
        return null;
    }
    
    public Integer verifyOnlyOneIFAPcontactExists()
    {
        Integer numberOfIFAPs = 0;
        for(AccreditationContactWrapper wrapped : acWrapper)
        {
            if(wrapped.ac.Financial_Assessment_Contact__c)
            {
                numberOfIFAPs++;
            }
        }
        return numberOfIFAPs;
    }
    
    public String verifyEmailDuplication(){

        Set<String> emails = new Set<String>();

        for(AccreditationContactWrapper wrapped : acWrapper){

            if(wrapped.ac == null || wrapped.ac.Email__c == null)
                continue;
            if(emails.contains(wrapped.ac.Email__c))
                return wrapped.ac.Email__c;
            else
                emails.add(wrapped.ac.Email__c);
            
        }

        return null;
    }

    public static Boolean dateFieldValidation(String dateField){

        if(dateField == '' || dateField == null)
            return true;
        
        if(!dateField.contains('-'))
            return false;


        String numbersOnly = dateField.replace('-', '');
        if(!numbersOnly.isNumeric())
            return false;

        String[] fieldSplit = dateField.split('-');
        if(fieldSplit.size() != 3)
            return false;

        if(fieldSplit[0].length() != 4 || fieldSplit[1].length() > 2 || fieldSplit[2].length() > 2)
            return false;

        if(Integer.valueOf(fieldSplit[0]) < 1950 || Integer.valueOf(fieldSplit[0]) > 2100 ||
           Integer.valueOf(fieldSplit[1]) < 1 || Integer.valueOf(fieldSplit[1]) > 12 ||
           Integer.valueOf(fieldSplit[2]) < 1 || Integer.valueOf(fieldSplit[2]) > 31)
        {
            return false;
        }

        return true;

    }

    public String verifyDateFormatting(){

        for(AccreditationContactWrapper wrapped : acWrapper)
        {
            String fieldToCheck = '';
            boolean returnError = false;

            for(Integer i=0;i<5;i++)
            {
                if(i == 0){
                    if(wrapped.ac.Date_joined_agency__c != null){
                        DateTime dt = DateTime.newInstance(wrapped.ac.Date_joined_agency__c.year(), wrapped.ac.Date_joined_agency__c.month(),wrapped.ac.Date_joined_agency__c.day());
                        wrapped.dateJoined = dt.format('yyyy-MM-dd');
                    }
                    fieldToCheck = wrapped.dateJoined;
                }
                if(i == 1){
                    if(wrapped.ac.Prev_Job1_From__c != null){
                        DateTime dt = DateTime.newInstance(wrapped.ac.Prev_Job1_From__c.year(), wrapped.ac.Prev_Job1_From__c.month(),wrapped.ac.Prev_Job1_From__c.day());
                        wrapped.prev1From = dt.format('yyyy-MM-dd');
                    }
                    fieldtoCheck = wrapped.prev1From;
                }
                if(i == 2){
                    if(wrapped.ac.Prev_Job1_To__c != null){
                        DateTime dt = DateTime.newInstance(wrapped.ac.Prev_Job1_To__c.year(), wrapped.ac.Prev_Job1_To__c.month(),wrapped.ac.Prev_Job1_To__c.day());
                        wrapped.prev1To = dt.format('yyyy-MM-dd');
                    }
                    fieldtoCheck = wrapped.prev1To;
                }
                if(i == 3){
                    if(wrapped.ac.Prev_Job2_From__c != null){
                        DateTime dt = DateTime.newInstance(wrapped.ac.Prev_Job2_From__c.year(), wrapped.ac.Prev_Job2_From__c.month(),wrapped.ac.Prev_Job2_From__c.day());
                        wrapped.prev2From = dt.format('yyyy-MM-dd');
                    }
                    fieldtoCheck = wrapped.prev2From;
                }
                if(i == 4){
                    if(wrapped.ac.Prev_Job2_To__c != null){
                        DateTime dt = DateTime.newInstance(wrapped.ac.Prev_Job2_To__c.year(), wrapped.ac.Prev_Job2_To__c.month(),wrapped.ac.Prev_Job2_To__c.day());
                        wrapped.prev2To = dt.format('yyyy-MM-dd');
                    }
                    fieldtoCheck = wrapped.prev2To;
                }
                if(!dateFieldValidation(fieldtoCheck))
                    return wrapped.ac.First_Name__c + ' '+wrapped.ac.Last_Name__c + ' with date: ' + fieldToCheck;
            }

        }

        for(TrainedStaffWrapper tsw : trainedStaffWrapper)
        {

            String fieldToCheck = '';
            boolean returnError = false;

            for(Integer i=0;i<2;i++)
            {
                if(i == 0){
                    if(tsw.ac.Certificate_Issued_on__c != null){
                        DateTime dt = DateTime.newInstance(tsw.ac.Certificate_Issued_on__c.year(), tsw.ac.Certificate_Issued_on__c.month(),tsw.ac.Certificate_Issued_on__c.day());
                        tsw.certificateIssueDate = dt.format('yyyy-MM-dd');
                    }
                    fieldToCheck = tsw.certificateIssueDate;
                }    
                if(i == 1){
                    if(tsw.ac.Certificate_Issued_on__c != null && (tsw.ac.Type_of_certificate__c == 'DGR' || tsw.ac.Type_of_certificate__c == 'CATA')){
                        system.debug('RB Valid until: ' + tsw.ac.Valid_until__c);
                        DateTime dt = DateTime.newInstance(tsw.ac.Valid_until__c.year(), tsw.ac.Valid_until__c.month(),tsw.ac.Valid_until__c.day());
                        tsw.validUntil = dt.format('yyyy-MM-dd');
                    }
                    fieldtoCheck = tsw.validUntil;
                }    
                if(!dateFieldValidation(fieldtoCheck))
                {
                    String tsFirstName = tsw.ac.First_Name__c == null ? '' : tsw.ac.First_Name__c;
                    String tsLastName = tsw.ac.Last_Name__c == null ? '' : tsw.ac.Last_Name__c;

                    return tsFirstName + ' ' + tsLastName + ' with date: ' + fieldToCheck;
                }
            }

        }

        return null;

    }
    
    public void setDateValuesForACs()
    {
        String[] splitValues;
        for(AccreditationContactWrapper wrapped : acWrapper)
        {
            if(wrapped.dateJoined != null && wrapped.dateJoined != '')
            {
                splitValues = wrapped.dateJoined.split('-');
                wrapped.ac.Date_joined_agency__c = Date.newInstance(Integer.valueOf(splitValues[0]), Integer.valueOf(splitValues[1]), Integer.valueOf(splitValues[2]));
            }else{
                wrapped.ac.Date_joined_agency__c = null;
            }
            if(wrapped.prev1From != null && wrapped.prev1From != '')
            {
                splitValues = wrapped.prev1From.split('-');
                wrapped.ac.Prev_Job1_From__c = Date.newInstance(Integer.valueOf(splitValues[0]), Integer.valueOf(splitValues[1]), Integer.valueOf(splitValues[2]));
            }else{
                wrapped.ac.Prev_Job1_From__c = null;
            }
            if(wrapped.prev1To != null && wrapped.prev1To != '')
            {
                splitValues = wrapped.prev1To.split('-');
                wrapped.ac.Prev_Job1_To__c = Date.newInstance(Integer.valueOf(splitValues[0]), Integer.valueOf(splitValues[1]), Integer.valueOf(splitValues[2]));
            }else{
                wrapped.ac.Prev_Job1_To__c = null;
            }
            if(wrapped.prev2From != null && wrapped.prev2From != '')
            {
                splitValues = wrapped.prev2From.split('-');
                wrapped.ac.Prev_Job2_From__c = Date.newInstance(Integer.valueOf(splitValues[0]), Integer.valueOf(splitValues[1]), Integer.valueOf(splitValues[2]));
            }else{
                wrapped.ac.Prev_Job2_From__c = null;
            }
            if(wrapped.prev2To != null && wrapped.prev2To != '')
            {
                splitValues = wrapped.prev2To.split('-');
                wrapped.ac.Prev_Job2_To__c = Date.newInstance(Integer.valueOf(splitValues[0]), Integer.valueOf(splitValues[1]), Integer.valueOf(splitValues[2]));
            }else{
                wrapped.ac.Prev_Job2_To__c = null;
            }

        }

    }

    public void setDateValuesForTrainedStaffACs(){

        String[] splitValues;
        for(TrainedStaffWrapper tsw : trainedStaffWrapper)
        {
            if(tsw.certificateIssueDate != null && tsw.certificateIssueDate != '')
            {
                splitValues = tsw.certificateIssueDate.split('-');
                tsw.ac.Certificate_Issued_on__c = Date.newInstance(Integer.valueOf(splitValues[0]), Integer.valueOf(splitValues[1]), Integer.valueOf(splitValues[2]));
            }else{
                tsw.ac.Certificate_Issued_on__c = null;
            }
            if(tsw.validUntil != null && tsw.validUntil != '')
            {
                splitValues = tsw.validUntil.split('-');
                tsw.ac.Valid_until__c = Date.newInstance(Integer.valueOf(splitValues[0]), Integer.valueOf(splitValues[1]), Integer.valueOf(splitValues[2]));
            }else{
                tsw.ac.Valid_until__c = null;
            }
        }

    }
    
    public void linkACwithContactOrPersonSelection()
    {
        rowNumber = rowNumber.replace('page:form:contactRepeat:', '');
        Integer realRowNumber = Integer.valueOf(rowNumber.subString(0, 1));
        System.debug('************ Contact realRowNumber: '+realRowNumber);
        boolean isLinkedToContact = false;
        List<Contact> conList = [select id, FirstName, LastName, Title, Membership_Main_Contact__c, OtherCountry, OtherState, OtherStreet, OtherCity, 
                OtherPostalCode, Phone, MobilePhone, Fax, Birthdate, Email, ISO_Country__c, Financial_Assessment_Contact__c from Contact where Id = :linkedRecordId];
        if(conList.size() > 0)
        {
            isLinkedToContact = true;
            copyValuesToAcIfMissing(conList.get(0), realRowNumber);
        } else
        {
            List<AMS_Person__c> personList = [select Id, First_Name__c, Lastname__c, Phone__c, Mobile__c, Fax__c, DOB__c, Email__c from AMS_Person__c where Id = :linkedRecordId];
            copyValuesToAcIfMissing(personList.get(0), realRowNumber);
        }
    }
    
    public void linkAccountWithAccountSelection()
    {
        try
        {
            rowNumber = rowNumber.replace('page:form:accountRepeat:', '');
            Integer realRowNumber = Integer.valueOf(rowNumber.subString(0, 1));
            System.debug('************ Account realRowNumber: '+realRowNumber);
            List<Account> accList = [select id, Name, Legal_Name__c, IATACode__c, Phone_Number__c, Email__c from Account where Id = :linkedRecordId];
            if(accList.size() > 0)
            {
                copyValuesToAccountIfMissing(accList.get(0), realRowNumber);
            }
        } catch(Exception e)
        {
            System.debug('************* error linkAccountWithAccountSelection: '+e);
        }
    }
    
    private void copyValuesToAcIfMissing(Contact c, Integer rowNumber)
    {
        AccreditationContactWrapper wrapped = acWrapper.get(rowNumber);
        wrapped.ac.First_name__c = c.FirstName;
        wrapped.ac.Last_name__c = c.LastName;
        wrapped.ac.Name = c.FirstName + ' ' + c.LastName;
        wrapped.ac.Job_title__c = c.Title;
        wrapped.ac.Membership_Main_Contact__c = c.Membership_Main_Contact__c;
        wrapped.ac.AddressCountry__c = c.OtherCountry;
        wrapped.ac.Mailing_State__c = c.OtherState;
        wrapped.ac.AddressStreet__c = c.OtherStreet;
        wrapped.ac.AddressCity__c = c.OtherCity;
        wrapped.ac.AddressPostcode__c = c.OtherPostalCode;
        wrapped.ac.Phone__c = c.Phone;
        wrapped.ac.Mobile__c = c.MobilePhone;
        wrapped.ac.FAX__c = c.Fax;
        wrapped.ac.Birthdate__c = c.Birthdate;
        wrapped.ac.Email__c = c.Email;
        wrapped.ac.ISO_Country__c = c.ISO_Country__c;
        wrapped.recordId = c.Id;
        wrapped.ac.Contact__c = c.Id;
        //wrapped.ac.Authorised_signatory__c = null;
        wrapped.ac.Financial_Assessment_Contact__c = c.Financial_Assessment_Contact__c;
        //wrapped.ac.Designated Portal Admin???
        wrapped.ac.Date_joined_agency__c = System.today();
        nullifyPreviousEmploymentFields(wrapped);
    }
    
    private void copyValuesToAcIfMissing(AMS_Person__c p, Integer rowNumber)
    {
        // Fields being set to null don't exist on AMS_Person__c, so there's no way to copy them.
        AccreditationContactWrapper wrapped = acWrapper.get(rowNumber);
        wrapped.ac.First_name__c = p.First_Name__c;
        wrapped.ac.Last_name__c = p.Lastname__c;
        wrapped.ac.Name = p.First_Name__c + ' ' + p.LastName__c;
        wrapped.ac.Job_title__c = null;
        wrapped.ac.Membership_Main_Contact__c = false; // Missing from AMS_Person__c 
        wrapped.ac.AddressCountry__c = null;
        wrapped.ac.Mailing_State__c = null;
        wrapped.ac.AddressStreet__c = null;
        wrapped.ac.AddressCity__c = null;
        wrapped.ac.AddressPostcode__c = null;
        wrapped.ac.Phone__c = p.Phone__c;
        wrapped.ac.Mobile__c = p.Mobile__c;
        wrapped.ac.FAX__c = p.Fax__c;
        wrapped.ac.Birthdate__c = p.DOB__c;
        wrapped.ac.Email__c = p.Email__c;
        wrapped.recordId = p.Id;
        wrapped.ac.Person_AMS__c = p.Id;
        wrapped.ac.ISO_Country__c = null;
        // wrapped.ac.Authorised_signatory__c = null;
        wrapped.ac.Financial_Assessment_Contact__c = false;
        //wrapped.ac.Designated Portal Admin???
        wrapped.ac.Date_joined_agency__c = System.today();
        nullifyPreviousEmploymentFields(wrapped);
    }
    
    private void copyValuesToAccountIfMissing(Account acc, Integer rowNumber)
    {
        AccountWrapper wrapped = accountWrapper.get(rowNumber);
        if(acc.Legal_Name__c != null)
        {
            wrapped.account.Legal_Name__c = acc.Legal_Name__c;
            wrapped.account.Name = acc.name;
        }
        else
        {
            wrapped.account.Legal_Name__c = acc.Name;
            wrapped.account.Name = acc.Name;
        }   
        wrapped.accountAc.Name = acc.Name;
        wrapped.account.IATACode__c = acc.IATACode__c;
        wrapped.recordId = acc.Id;
        wrapped.account.Id = acc.Id;
        wrapped.accountAc.Company__c = acc.Id;
        wrapped.accountAc.IATACode__c = acc.IATACode__c;
        
        // fields that might get copied, but are not displayed on the form.
        if(acc.Email__c != null)
        {
            wrapped.accountAc.Email__c = acc.Email__c;
        }
        else
        {
            wrapped.accountAc.Email__c = '-';
        }   
        if(acc.Phone_Number__c != null)
            wrapped.accountAc.Phone__c = acc.Phone_Number__c;
        else
            wrapped.accountAc.Phone__c = '-';
        
        wrapped.accountAc.First_Name__c = '-';
        wrapped.accountAc.Last_Name__c = '-';
        
        //wrapped.registrationNumber = acc.registrationNumber;
    }
    
    private void nullifyPreviousEmploymentFields(AccreditationContactWrapper wrapped)
    {
        wrapped.ac.Agencies_prev_worked_for__c = null;
        wrapped.ac.Accredited_employer_1__c = null;
        wrapped.ac.Accredited_employer_2__c = null;
        wrapped.ac.Prev_Job1_Address__c = null;
        wrapped.ac.Prev_Job2_Address__c = null;
        wrapped.ac.Prev_Job1_IATA_accredited__c = false;
        wrapped.ac.Prev_Job2_IATA_accredited__c = false;
        wrapped.ac.Prev_Job1_IATA_code__c = null;
        wrapped.ac.Prev_Job2_IATA_code__c = null;
        wrapped.ac.Prev_Job1_Employer__c = null;
        wrapped.ac.Prev_Job2_Employer__c = null;
        wrapped.ac.Prev_Job1_Position__c = null;
        wrapped.ac.Prev_Job2_Position__c = null;
        wrapped.ac.Prev_Job1_To__c = null;
        wrapped.ac.Prev_Job2_To__c = null;
    }
    
    public void removeOwnership()
    {
        acWrapper.get(toNullify).ac.Financial_Interest__c = 0;
    }
    
    public class AccreditationContactWrapper
    {
        public AMS_Accreditation_Contact__c ac {get; set;}
        public String recordId {get; set;}
        public String dateJoined {get; set;}
        public String prev1From {get; set;}
        public String prev1To {get; set;}
        public String prev2From {get; set;}
        public String prev2To {get; set;}
        public boolean blockEdit
        {
            //edit on owner contacts is to be blocked when the account concerned is not an HO.
            //although when the associated process is a CORRECTION edit should be allowed
            get{
                return ac.Agency_Owner__c && 
                       (ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Type_of_change__c!=null && ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Type_of_change__c.contains(AMS_Utils.OWNERSHIP_IATA) ||
                       (ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__r.Location_Type__c != null &&
                       ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__r.Location_Type__c != AMS_Utils.HO && 
                       ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__r.Location_Type__c != AMS_Utils.HE &&
                       ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__r.Location_Type__c != AMS_Utils.GE &&
                       ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__r.Location_Type__c != AMS_Utils.AE && 
                       ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Process__c != AMS_Utils.COR && ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Process__c != AMS_Utils.AGENCYCHANGES));

                }
            set;
        }
        
        public AccreditationContactWrapper(AMS_Accreditation_Contact__c acParam)
        {
            this.dateJoined = String.valueOf(acParam.Date_Joined_agency__c);
            this.prev1From = String.valueOf(acParam.Prev_Job1_From__c);
            this.prev1To = String.valueOf(acParam.Prev_Job1_To__c);
            this.prev2From = String.valueOf(acParam.Prev_Job2_From__c);
            this.prev2To = String.valueOf(acParam.Prev_Job2_To__c);
            
            this.ac = acParam;
            /*if(this.ac.Company__c == null)
            {
                this.ac.Company__c = acParam.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c;
            }*/
            if(acParam.Person_AMS__c != null)
            {
                this.recordId = acParam.Person_AMS__c;
            }
            if(acParam.Contact__c != null)
            {
                this.recordId = acParam.Contact__c;
            }
        }
        
        /*public AccreditationContactWrapper(AMS_Accreditation_Contact__c acParam, String rId)
        {
            this.ac = acParam;
            if(this.ac.Company__c == null)
            {
                this.ac.Company__c = acParam.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c;
            }
            this.recordId = rId;
        }*/
    }
    
    public class AccountWrapper
    {
        public Account account {get; set;}
        public Decimal financialInterest {get; set;}
        //public String legalName {get; set;}
        public AMS_Accreditation_Contact__c accountAc {get; set;}
        public String registrationNumber {get; set;}
        public String recordId {get; set;}
        public boolean isNewRecord {get; set;}
        
        public AccountWrapper(AMS_Accreditation_Contact__c accountAc, Account acc, String accountRecordId, boolean isNewRecord)
        {
            this.recordId = accountRecordId;
            this.account = acc;
            this.accountAc = accountAc;
            this.financialInterest = accountAc.Financial_Interest__c;
            this.registrationNumber = accountAc.Registration_Number__c;
            this.accountAc.Company__c = this.account.Id;
            this.account.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

            if(this.account.Legal_Name__c == null)
            {
                this.account.Legal_Name__c = this.AccountAc.Name;
            }
            this.isNewRecord=isNewRecord;
        }
    }

    public class TrainedStaffWrapper
    {
        public AMS_Accreditation_Contact__c ac {get; set;}
        public String certificateIssueDate {get; set;}
        public String validUntil {get; set;}
        
        public TrainedStaffWrapper(AMS_Accreditation_Contact__c trainedStaffAc)
        {
            this.ac = trainedStaffAc;
            this.certificateIssueDate = String.valueOf(trainedStaffAc.Certificate_Issued_on__c);
            this.validUntil = String.valueOf(trainedStaffAc.Valid_until__c);
        }
    }

	//FM AMSU-1
    public AMS_OSCAR__c oscarObj { 
        get{ 
            if(this.oscarObj == null)
                return new AMS_OSCAR__c();
            else return this.oscarObj;
        }
        set; }

    //FM AMSU-1
    public Boolean isAllHierarchySelected{
        get{
            System.debug('isAllHierarchySelected - entrei - isAllHierarchySelected : ' + isAllHierarchySelected);
            if(isAllHierarchySelected != null){
                return isAllHierarchySelected;
            }else{
                Map<Id, List<AMS_Process_Detail__c>> processDetailPerOSCAR = new Map<Id, List<AMS_Process_Detail__c>>();
                Set<Id> accountIds = new Set<Id>();
                Set<Id> oscarIds = new Set<Id>();
                Set<Id> oscarOnlineAccredIds = new Set<Id>();
                Map<Id, Account> accounts = new Map<Id, Account>();
                
                //store all the updates to be made on account as consequence of migration of data from staging area to master data
                Map<Id,AMS_ChangeCodesHelper.ObjectChangesStruct> accountsToUpdate = new Map<Id,AMS_ChangeCodesHelper.ObjectChangesStruct>();
                
                accountIds.add(oscarObj.Account__c);
                accountIds.add(oscarObj.AMS_Target_Agency__c);
                oscarIds.add(oscarObj.Id);
                oscarOnlineAccredIds.add(oscarObj.AMS_Online_Accreditation__c);


                Map<Id, AMS_Pax_Accreditation_Form__c> onlineAccreditations = new Map<Id, AMS_Pax_Accreditation_Form__c>([SELECT Account_Name__c, IATACode__c, ISSP_AMS_Legal_Status__c, Short_Name__c, Trade_Name__c, ISSP_AMS_License_No__c, ISSP_AMS_VAT_number__c,
                    ISSP_AMS_GDS_with_signed_contract__c, Operation__c, Branch_Office_Country__r.Name, Branch_Office_Country__r.Due_diligence_mandatory__c, Branch_Office_Street_name_number__c, Branch_Office_Postal_code__c,
                    Billing_State__c, Branch_Office_City__c, ISO_Country__c, IATA_ISO_State__c, Shipping_Country__c, Shipping_Street__c, Shipping_Postal_Code__c,
                    Shipping_State__c, Shipping_City__c, Branch_Office_Email__c, Website__c, Branch_Office_Phone__c, Branch_Office_FAX__c, ISSP_AMS_Premises_located_at_airport__c,
                    Abbreviated_name__c, Abbreviated_address__c, Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c,
                    Shipping_ISO_Country__c, Shipping_ISO_State__c, Shipping_ISO_Country__r.Name, Shipping_ISO_State__r.Name, IATA_ISO_State__r.Name, IATA_ISO_State__r.Valid_for_Address__c   
                    FROM AMS_Pax_Accreditation_Form__c
                    WHERE Id IN :oscarOnlineAccredIds]);

                AMS_Pax_Accreditation_Form__c oscarOnlineAccreditation = onlineAccreditations.get(oscarObj.AMS_Online_Accreditation__c);

                //query the the Process Detail object for all the agencies that are being bought
                List<AMS_Process_Detail__c> allProcessDetails = new List<AMS_Process_Detail__c>([SELECT Id, Account__c, OSCAR__c, Account__r.Status__c, RecordType.Developername FROM AMS_Process_Detail__c WHERE OSCAR__c IN :oscarIds and RecordType.Developername = 'Agency_Involved']);

                for (AMS_Process_Detail__c pd : allProcessDetails) {
                    //TERMINATED AGENCIES IGNORED
                    if(pd.Account__c != null && pd.Account__r.Status__c != AMS_Utils.ACC_S0_TERMINATED){
                        if (processDetailPerOSCAR.get(pd.OSCAR__c) == null)
                            processDetailPerOSCAR.put(pd.OSCAR__c, new List<AMS_Process_Detail__c> {pd});
                        else
                            processDetailPerOSCAR.get(pd.OSCAR__c).add(pd);
                    }

                }

                Set<Id> oscarAccountIds = new Set<Id>();
                oscarAccountIds.add(oscarObj.Account__c);
                Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships = AMS_HierarchyHelper.getAccountsHierarchies(oscarAccountIds);

                for (List<AMS_Agencies_relationhip__c> hierarchyRelations : accountHierarchyRelationships.values()) {
                    for (AMS_Agencies_relationhip__c relationship : hierarchyRelations) {
                        if(relationship.Parent_Account__r.Status__c != AMS_Utils.ACC_S0_TERMINATED && relationship.Parent_Account__r.Status__c != AMS_Utils.ACC_S1_NOTACCREDITED && relationship.Parent_Account__r.Status__c != '' ){
                            accountIds.add(relationship.Parent_Account__c);
                            accounts.put(relationship.Parent_Account__c, new Account(id = relationship.Parent_Account__c, Status__c = relationship.Parent_Account__r.Status__c));
                        }
                        if(relationship.Child_Account__r.Status__c != AMS_Utils.ACC_S0_TERMINATED && relationship.Child_Account__r.Status__c != AMS_Utils.ACC_S1_NOTACCREDITED && relationship.Child_Account__r.Status__c != '' ){
                            accountIds.add(relationship.Child_Account__c);
                            accounts.put(relationship.Child_Account__c, new Account(id = relationship.Child_Account__c, Status__c = relationship.Child_Account__r.Status__c));
                        }
                    }
                }

                List<AMS_Process_Detail__c> pds = processDetailPerOSCAR.get(oscarObj.Id);

                Set<Id> agenciesAffected = new Set<Id>();
                Set<Id> agenciesAffectedWithHO = new Set<Id>();
                agenciesAffectedWithHO.add(oscarObj.Account__c);

                if (pds != null){
                    for (AMS_Process_Detail__c pd : pds){
                        agenciesAffected.add(pd.Account__c);
                        agenciesAffectedWithHO.add(pd.Account__c);
                    }
                }

                

                system.debug('applyChangeCodesWithDependencies() -> processDetailPerOSCAR : ' + processDetailPerOSCAR);
                system.debug('applyChangeCodesWithDependencies() -> accountHierarchyRelationships : ' + accountHierarchyRelationships);
                system.debug('applyChangeCodesWithDependencies() -> accountIds : ' + accountIds);
                system.debug('applyChangeCodesWithDependencies() -> accounts : ' + accounts);
                system.debug('applyChangeCodesWithDependencies() -> agenciesAffected : ' + agenciesAffected);
                

                //Checks if all Hierarchy was Selected
                isAllHierarchySelected = AMS_HierarchyHelper.isAllHierarchySelected(agenciesAffectedWithHO, accountHierarchyRelationships.get(oscarObj.Account__c), accounts);
                return isAllHierarchySelected;
                //system.debug('applyChangeCodesWithDependencies() -> isAllHierarchySelected : ' + isAllHierarchySelected);
            }
        }
        private set;
    }


    // AMSU-132
    public class AgRegItemWrapper{

        public AMS_Agency_Regulation__c agReg { get; set; }
        public Boolean main { get; set; }
        public Boolean selected { get; set; }
        public Boolean enable { get; set; }

        public AgRegItemWrapper(AMS_Agency_Regulation__c ar, Boolean main, Boolean selected, Boolean enable){
            this.agReg = ar;
            this.main = main;
            this.selected = selected;
            this.enable = enable;
        }
    }
    //AMSU-132
    public void convertExistingAgencyRegulationsToAccContact(Id stagingId, List<AMS_Agency_Regulation__c> regulations){

        List<AMS_Accreditation_Contact__c> accToInsert = new List<AMS_Accreditation_Contact__c>();

        //create trained staff accreditation contact from the existing agency regulations
        //in the accreditation contact we save the link to the agency regulation object.
        for(AMS_Agency_Regulation__c reg  :regulations){

            AMS_Accreditation_Contact__c ac = new AMS_Accreditation_Contact__c();

            ac.RecordTypeId = AMS_Utils.AccreditationContactTrainedStaffRT;
            ac.Certificate_Name__c = reg.Certificate_Name__c;
            ac.First_Name__c = reg.First_Name__c;
            ac.Last_Name__c = reg.Last_Name__c;
            ac.Position_trained_staff__c = reg.Position__c;
            ac.Type_of_Certificate__c = reg.Type_of_Certificate__c;
            ac.AMS_Pax_Accreditation_Form__c = stagingId;
            ac.Certificate_Issued_on__c = reg.Issued_on__c;
            ac.Certificate_Validity__c = reg.Validity__c;
            ac.Valid_until__c = reg.Expiry_Date__c;
            ac.Certificate_Issuer__c = reg.Issuer__c;
            ac.AgencyRegulation__c = reg.Id;
            ac.Air_cargo_transport_business_exp__c = reg.Air_cargo_transport_business_exp__c;
            ac.IATA_FIATA_training_history__c = reg.IATA_FIATA_training_history__c;
            ac.Training_dangerous_goods_completed__c = reg.Training_dangerous_goods_completed__c;
            ac.Registration_number__c = reg.Registration_Number__c; 

            this.trainedStaffWrapper.add(new TrainedStaffWrapper(ac));
        }
    }
}
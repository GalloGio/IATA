public with sharing class AMS_AccreditationContactController {
    
    public List<AccreditationContactWrapper> acWrapper {get; set;}
    public List<AMS_Accreditation_Contact__c> acList {get; set;}
    public AMS_Pax_Accreditation_Form__c aoa {get; set;}
    public Integer toUnselect {get; set;}
    public Integer toNullify {get; set;}
    public boolean successfulSave {get; set;}
    public List<AMS_Accreditation_Contact__c> forDeletion {get; set;}
    public Integer previousAgencies {get; set;}
    public String rowNumber {get; set;}
    public String linkedRecordId {get; set;}
    public List<AccountWrapper> accountWrapper {get; set;}
    public decimal ownership {get; set;}
    public boolean blockOwnershipEdit {get; set;}
    public boolean isCorrection {get; set;}
    public boolean isCertificationOSCAR {get; set;}
    public boolean isCargoAgency {get; set;}
    private Id AcPersonRt;
    private Id AcCompanyRt;
    private Id AcCurrentCompanyRt;
    private Id AcCurrentOwnerRt;
    public List<TrainedStaffWrapper> trainedStaffWrapper{get; set;}
    public boolean isNewProcess {get; set;}

    public static Map<String, String> accreditationContactRT = new Map<String, String> {

            AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Person') => 'Person',
            AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Current_Owner') => 'Person',

            AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Company') => 'Company',
            AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Current_Company_Owner') => 'Company',

            AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Trained_Staff') => 'Trained Staff'


    };

    
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
            //String acCompanyRtId = AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Company');
            
            List<AMS_Pax_Accreditation_Form__c> aoaList = [select id, Name, Account_Name__c, IATACode__c, Type_of_Operation__c, Shipping_Street__c, Shipping_Postal_Code__c, 
                            Shipping_City__c, Shipping_State__c, Shipping_Country__c, SAAM_Case__r.AccountId, SAAM_Case__r.OSCAR__r.Account__c,
                            SAAM_Case__r.OSCAR__r.Account__r.Location_Type__c, SAAM_Case__r.OSCAR__r.Process__c, SAAM_Case__r.OSCAR__r.Type_of_change__c,
                            SAAM_Case__r.OSCAR__r.Account__r.Sector__c
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
        
        AcPersonRt = AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Person');
        AcCompanyRt = AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Company');
        AcCurrentCompanyRt = AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Current_Company_Owner');
        AcCurrentOwnerRt = AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Current_Owner');

        forDeletion = new List<AMS_Accreditation_Contact__c>();

        Boolean typeOfChangeContainsOwnershipToIATA = false;

        if(aoa.SAAM_Case__r.OSCAR__r.Type_of_change__c != null && aoa.SAAM_Case__r.OSCAR__r.Type_of_change__c.contains(AMS_Utils.OWNERSHIP_IATA))
            typeOfChangeContainsOwnershipToIATA = true;

        blockOwnershipEdit = (aoa.SAAM_Case__r.OSCAR__r.Account__r.Location_Type__c != AMS_Utils.HO && 
                             aoa.SAAM_Case__r.OSCAR__r.Process__c != AMS_Utils.COR && aoa.SAAM_Case__r.OSCAR__r.Process__c != AMS_Utils.AGENCYCHANGES) || typeOfChangeContainsOwnershipToIATA;

        isCorrection = aoa.SAAM_Case__r.OSCAR__r.Process__c == AMS_Utils.COR;
        isCargoAgency = aoa.SAAM_Case__r.OSCAR__r.Account__r.Sector__c == AMS_Utils.SECTOR_CARGO;

        isCertificationOSCAR = aoa.SAAM_Case__r.OSCAR__r.Process__c == AMS_Utils.CERTIFICATION ? true : false;

        isNewProcess = aoa.SAAM_Case__r.OSCAR__r.RecordTypeId == AMS_Utils.RECTYPE_NEW? true : false;
    }
    
    public void addEmptyRow()
    {
        Id rt = this.aoa.SAAM_Case__r.OSCAR__r.Process__c == AMS_Utils.AGENCYCHANGES || this.aoa.SAAM_Case__r.OSCAR__r.Process__c == AMS_Utils.COR ? AcCurrentOwnerRt : AcPersonRt;

        AccreditationContactWrapper acWrapper = new AccreditationContactWrapper(new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = this.aoa.Id, RecordTypeId =  rt, Company__c = this.aoa.SAAM_Case__r.OSCAR__r.Account__c));
        this.acWrapper.add(acWrapper);
    }
    
    public void addEmptyTrainedStaffRow()
    {
        Id rt = AMS_Utils.AccreditationContactTrainedStaffRT;
        
        this.trainedStaffWrapper.add(new TrainedStaffWrapper(new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = this.aoa.Id, RecordTypeId = rt, Last_Name__c = '-', Phone__c = '-')));
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
        if(!calculateTotalOwnership() && !isCertificationOSCAR)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Total ownershiprate for all inserted contacts is ' + ownership + '%. Please set it to 100% before saving.'));
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
        if(firstErrorDate != null)
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
        
        // Verify that no emails entered for "new" contacts are found in the system
        Set<String> emailSetToConfirm = new Set<String>();
        for(AccreditationContactWrapper ac : acWrapper)
        {
            if(ac.recordId == null && ac.ac.Email__c != null)
            {
                if(ac.ac.Email__c != '')
                    emailSetToConfirm.add(ac.ac.Email__c);
            }
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
                Id standardAccountRtId = AMS_Utils.getId('Account', 'Standard_Account');
                List<Account> accountInsertList = new List<Account>();
                List<AMS_Accreditation_Contact__c> acUpsertList = new List<AMS_Accreditation_Contact__c>();
                for(AccountWrapper aw : accountWrapper)
                {
                    aw.accountAc.Financial_interest__c = aw.financialInterest;
                    aw.accountAc.Registration_number__c = aw.registrationNumber;
                    
                    if(aw.account.Id == null)
                    {
                        aw.account.Name = aw.account.Legal_Name__c;
                        aw.account.RecordTypeId = standardAccountRtId;
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
        
        if(ownership != 100)
        {
            return false;
        } else
        {
            return true;
        }
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




    public String verifyDateFormatting()
    {
        for(AccreditationContactWrapper wrapped : acWrapper)
        {
            
            // TODO: change the apex:inputField into apex:inputText and add the Strings into the wrapper class
            // First convert the value of the date field on load into YYYY-MM-DD and on save, validate the user input and convert back to Date and 
            // set the value of the Date field onto the Date_joined_agency__c and other relevant fields

            boolean returnError = false;
            String fieldToCheck = '';
            // make sure all fields are checked by looping through them
            for(Integer i=0;i<5;i++)
            {
                if(i == 0)
                    fieldToCheck = wrapped.dateJoined;
                if(i == 1)
                    fieldtoCheck = wrapped.prev1From;
                if(i == 2)
                    fieldtoCheck = wrapped.prev1To;
                if(i == 3)
                    fieldtoCheck = wrapped.prev2From;
                if(i == 4)
                    fieldtoCheck = wrapped.prev2To;

                // if data is not filled, try the next field
                if(fieldToCheck == '' || fieldToCheck == null)
                {
                    continue;
                }
                
                if(!fieldToCheck.contains('-'))
                {
                    returnError = true;
                    break;
                }
                
                String numbersOnly = fieldToCheck.replace('-', '');
                if(!numbersOnly.isNumeric())
                {
                    returnError = true;
                    break;
                }
                
                String[] fieldSplit = fieldToCheck.split('-');
                if(fieldSplit.size() != 3)
                {
                    returnError = true;
                    break;
                }
                if(fieldSplit[0].length() != 4 || fieldSplit[1].length() > 2 || fieldSplit[2].length() > 2)
                {
                    returnError = true;
                    break;
                }
                if(Integer.valueOf(fieldSplit[0]) < 1950 || Integer.valueOf(fieldSplit[0]) > 2100 ||
                   Integer.valueOf(fieldSplit[1]) < 1 || Integer.valueOf(fieldSplit[1]) > 12 ||
                   Integer.valueOf(fieldSplit[2]) < 1 || Integer.valueOf(fieldSplit[2]) > 31)
                {
                    returnError = true;
                    break;
                }
            }
            if(returnError)
            {
                return wrapped.ac.First_Name__c + ' '+wrapped.ac.Last_Name__c + ' with date: ' +fieldToCheck;
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
        try
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
        } catch(Exception e)
        {
            
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
            if(this.ac.Company__c == null)
            {
                this.ac.Company__c = acParam.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c;
            }
            if(acParam.Person_AMS__c != null)
            {
                this.recordId = acParam.Person_AMS__c;
            }
            if(acParam.Contact__c != null)
            {
                this.recordId = acParam.Contact__c;
            }
        }
        
        public AccreditationContactWrapper(AMS_Accreditation_Contact__c acParam, String rId)
        {
            this.ac = acParam;
            if(this.ac.Company__c == null)
            {
                this.ac.Company__c = acParam.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c;
            }
            this.recordId = rId;
        }
    }
    
    public class AccountWrapper
    {
        public Account account {get; set;}
        public Decimal financialInterest {get; set;}
        public String legalName {get; set;}
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
            this.account.RecordTypeId = AMS_Utils.getId('Account', 'IATA_Agency');
            //AMS-1669 this.accountAc.RecordTypeId = AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Company');
            if(this.account.Legal_Name__c == null)
            {
                this.account.Legal_Name__c = this.AccountAc.Name;
            }
            this.isNewRecord=isNewRecord;
        }
    }
    
    private static Boolean validateDateFormat(String field){

        if(!field.contains('-'))
            return false;
                    
        String numbersOnly = field.replace('-', '');
        if(!numbersOnly.isNumeric())
            return false;
                    
        String[] fieldSplit = field.split('-');
        if(fieldSplit.size() != 3)
            return false;
        
        if(fieldSplit[0].length() != 4 || fieldSplit[1].length() > 2 || fieldSplit[2].length() > 2)
            return false;

        if(Integer.valueOf(fieldSplit[0]) < 1950 || Integer.valueOf(fieldSplit[0]) > 2100 ||
            Integer.valueOf(fieldSplit[1]) < 1 || Integer.valueOf(fieldSplit[1]) > 12 ||
            Integer.valueOf(fieldSplit[2]) < 1 || Integer.valueOf(fieldSplit[2]) > 31)
            return false;
        
        return true;
    }

    public class TrainedStaffWrapper
    {
        public AMS_Accreditation_Contact__c ac {get; set;}
        public String certificateIssueDate {get; set;}
        public String validUntil {get; set;}
        public String expiryDate {
            get{
                if(validUntil != null)
                    return validUntil;
                else if(certificateIssueDate != null && ac.Certificate_Validity__c != null && validateDateFormat(certificateIssueDate)){
                
                    Date issueDate = Date.valueOf(certificateIssueDate+' 00:00:00');
                    Integer validityYears = Integer.valueOf(ac.Certificate_Validity__c.left(1));
                    Date expiryDate = issueDate + validityYears * 365;

                    return String.valueOf(expiryDate);

                }  
                    
                return null;
            }
            set;
        }
        
        public TrainedStaffWrapper(AMS_Accreditation_Contact__c trainedStaffAc)
        {
            this.ac = trainedStaffAc;
            this.certificateIssueDate = String.valueOf(trainedStaffAc.Certificate_Issued_on__c);
            this.validUntil = String.valueOf(trainedStaffAc.Valid_until__c);
        }
    }
}
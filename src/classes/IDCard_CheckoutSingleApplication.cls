public with sharing  class IDCard_CheckoutSingleApplication   extends IDCardAbstractController  {

    private ID_Card_Application__c idCardApplication;

    private Account account = null;

    private List<Contact> keyContact {get; set;}

    public String applicationId  {get; set;}

    public String keyContactEmail {get; set;}

    public IDCard_CheckoutSingleApplication() {
        initialize();
        keyContact = new List<Contact>();
        if (System.currentPageReference().getParameters().get(IDCardUtil.PARAM_APPID) == null) {
            system.debug('[IDCard_CheckoutSingleApplication] failed to load applicationId');
            throw new IDCardApplicationException('Missing parameter ' + IDCardUtil.PARAM_APPID);
        }

        system.debug('[IDCard_CheckoutSingleApplication] ');
        applicationId = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_APPID));
        system.debug('[IDCard_CheckoutSingleApplication] applicationId =' + applicationId);
        // retreive error msg if any (coming from CheckoutConfirmation)
        if (System.currentPageReference().getParameters().get(IDCardUtil.PARAM_ERRMSG) != null) {
            String errMsg = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_ERRMSG));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errMsg));
        }


    }

    public Pagereference updateRecord() {
        try {
            // get ID Card Application
            idCardApplication = [Select i.RecordtypeId, i.VER_Number__c, i.UIR__c, i.Revenue_Confirmation__c, i.Type_of_application__c, i.Title__c, i.Telephone__c, i.SystemModstamp,
                                 i.Start_Date_Industry__c, i.Start_Date_Agency_Year__c, i.Start_Date_Agency_Month__c, i.Solicitation_Flag__c,
                                 i.Promotion_Code__c, i.Position_in_Current_Agency__c, i.Position_Code__c, i.Photo__c,
                                 i.Package_of_Travel_Professionals_Course_2__c, i.Package_of_Travel_Professionals_Course_1__c, i.OwnerId, i.Name, i.Middle_Initial__c,
                                 i.Last_Name__c, i.LastModifiedDate, i.LastModifiedById, i.IsDeleted, i.Id, i.IDCard_Prefered_Language__c, i.IDCard_Expedite_Delivery__c,
                                 i.IDCard_Expedite_Delivery_Fee__c, i.ID_Card_Fee__c, i.ITDI_Courses_Fee__c, i.IATA_numeric_code_previous_employer_4__c, i.IATA_numeric_code_previous_employer_3__c,
                                 i.IATA_numeric_code_previous_employer_2__c, i.IATA_numeric_code_previous_employer_1__c, i.IATA_Code_for_previous_agency__c, i.IATA_Code__c,
                                 i.Hours_worked__c, i.Hours_Worked_Code__c, i.Gender__c, i.First_Name__c, i.Email_admin__c,
                                 i.Duties_in_Current_Agency__c, i.Duties_Code__c, i.Displayed_Name__c, i.Date_of_Birth__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById,
                                 i.ConnectionSentId, i.ConnectionReceivedId, i.Approving_Manager_s_Name__c, i.Approving_Manager_s_Email__c, i.Applicable_Fee__c,
                                 i.Tax_2_Name__c,  i.Tax_1_Name__c,  i.Tax_1_Value__c,  i.Tax_2_Value__c
                                 From ID_Card_Application__c i
                                 where i.Id = :applicationId
                                              limit 1];
            //set the Id Card as available for Key Contact:
            idCardApplication.Application_Status__c = 'Pending' ;
            update idCardApplication;


            account = [ Select BillingState, BillingCountry , Id from Account where IATACode__c = : idCardApplication.IATA_Code__c limit 1];
            system.debug('[IDCard_CheckoutSingleApplication]Acocunt Id   ' + account.Id);
            alertKeyContactForNewApplication();
        } catch (Exception ex) {
            system.debug('[IDCard_CheckoutSingleApplication] ERROR ' + ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        return null;
    }

    private void alertKeyContactForNewApplication() {
        //keyContact = [select ID, Name, Email from Contact where AccountId = :account.Id and IDCardContactType__c like   '%Key Contact %'];
        List<Managed_agency__c> managedAccountList = [select m.Id, m.Account__c, m.Contact__r.Email, m.Contact__r.IDcard_Email__c,
                                m.Contact__r.Id,  m.Account__r.IATACode__c , m.delegate__c from Managed_agency__c m where m.Account__c = :account.Id ];
        if (managedAccountList.size() == 0) {
            DevsTools.sendSFDevsAlertMessage('ID Card purchase alert', 'No Key contact for account ' + account.Id + ' Id card application womn t be process: ' + idCardApplication.Id);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'We failed to contact your manager. Please contact IATA or your manager to validate your application1 '));
            return ;
        }
        List<String> toRecipients = new List<String>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        system.debug('[IDCard_CheckoutSingleApplication]Emailing');
        /*for(Contact c :keyContact)
            toRecipients.add(c.Email);*/
        for (Managed_agency__c c : managedAccountList ) {
            if (!c.Delegate__c && !String.isBlank(c.Contact__r.IDCard_Email__c)) {
                keyContactEmail = c.Contact__r.IDCard_Email__c;
                email.setTargetObjectId(c.Contact__r.Id);
            }

            toRecipients.add(c.Contact__r.IDCard_Email__c);
        }

        String language = getSelectedLanguage();
        List<EmailTemplate> ets = new List<EmailTemplate>();

        if (language == 'fr') ets = [select ID from EmailTemplate where DeveloperName = 'KeyAccount_New_ApplicationFR'];
        if (language == 'es') ets = [select ID from EmailTemplate where DeveloperName = 'KeyAccount_New_ApplicationES'];
        if (language == 'en_US') ets = [select ID from EmailTemplate where DeveloperName = 'KeyAccount_New_Application'];

        if ( ets.size() > 0 && toRecipients.size() > 0) {
            EmailTemplate et = ets.get(0);
            system.debug('[IDCard_CheckoutSingleApplication]Email find recipeint and template');
            email.setToAddresses(toRecipients);
            email.setWhatId(idCardApplication.Id);
            email.setTreatTargetObjectAsRecipient(false);

            email.setTemplateId(et.Id);
            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                system.debug('[IDCard_CheckoutSingleApplication]Send email OK');
                return;
            } catch (EmailException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'We failed to contact your manager. Please contact IATA or your manager to validate your application2 '));
                //throw new UtilException('[U-02] sendTemplatedEmail error. ' + e.getMessage());
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'We failed to contact your manager. Please contact IATA or your manager to validate your application3 '));
            return ;
        }
    }


    public Pagereference terminate () {
        PageReference ref = new PageReference('http://www.iata.org');
        ref.setRedirect(true);
        return ref;
    }

}
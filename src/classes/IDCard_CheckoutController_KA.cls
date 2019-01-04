public  class IDCard_CheckoutController_KA extends IDCardAbstractController {
    
    public ID_Card_Application__c iDCardApplication {get;set;}
    
    public String orderNumber {get;set;}
    
    public IDCard_CheckoutController_KA(){
        initialize();
        
        orderNumber = ApexPages.currentPage().getParameters().get('orderNumber'); // get orderNumber (which is the ID Card Application auto-number)
        //trim first 3 characters to remove country ISOCode and the dash
        orderNumber = 'IDCA-'+orderNumber.substring(5, orderNumber.length());  
        iDCardApplication = [Select i.Case_Number__c, i.Tax_2_Name__c, i.Tax_1_Name__c, i.Tax_1_Value__c, i.Tax_2_Value__c, i.Renewal_From_Replace__c,i.ID_Card_Fee__c, i.VER_Number__c, i.UIR__c,i.Revenue_Confirmation__c, i.Type_of_application__c, i.Title__c, i.Telephone__c, i.SystemModstamp, i.Start_Date_Industry__c, i.Start_Date_Agency_Year__c, i.Start_Date_Agency_Month__c, i.Solicitation_Flag__c, i.Promotion_Code__c, i.Position_in_Current_Agency__c, i.Position_Code__c, i.Photo__c, i.Package_of_Travel_Professionals_Course_2__c, i.Package_of_Travel_Professionals_Course_1__c, i.OwnerId, i.Name, i.Middle_Initial__c, i.Last_Name__c, i.LastModifiedDate, i.LastModifiedById, i.IsDeleted, i.Id, i.IDCard_Prefered_Language__c, i.IDCard_Expedite_Delivery__c, i.IDCard_Expedite_Delivery_Fee__c, i.IATA_numeric_code_previous_employer_4__c, i.IATA_numeric_code_previous_employer_3__c, i.IATA_numeric_code_previous_employer_2__c, i.IATA_numeric_code_previous_employer_1__c, i.IATA_Code_for_previous_agency__c, i.IATA_Code__c, i.Hours_worked__c, i.Hours_Worked_Code__c, i.Gender__c, i.First_Name__c, i.Hours_Worked_Validation_Failed__c, i.Email_admin__c, i.Duties_in_Current_Agency__c, i.Duties_Code__c, i.Displayed_Name__c, i.Date_of_Birth__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Approving_Manager_s_Name__c, i.Approving_Manager_s_Email__c, i.Applicable_Fee__c, i.Payment_Credit_Card_Number__c, i.Payment_Date__c, i.Revenue_Confirmation_Validation_Failed__c, i.Payment_Transaction_Number__c, i.Payment_Amount__c From ID_Card_Application__c i where i.Name = :orderNumber limit 1];
         
    }

    public void validateIdCardApplicationRequest(){
               
        iDCardApplication.Payment_Type__c = IDCardUtil.PAYMENT_TYPE_KEY_ACCOUNT;
        update iDCardApplication;
                   
        // check if an ID Card already exists for the ID Card Application
        ID_Card__c[] existingIDCards = [Select i.Name_on_ID_Card__c From ID_Card__c i where i.ID_Card_Application__r.Id = :iDCardApplication.Id limit 1];
        if (existingIDCards != null && existingIDCards.size() > 0)
            throw new IDCardApplicationException(Label.IDCard_IDCardAlreadyExistsError);
             
        // embed ID Card and Case creation in a transaction
                           // SavePoint sp = database.setSavepoint();
        try {  
            
            System.debug('********* Creating Case');
            // Create the case
            Account theAccount = IDCardUtil.GetAccountObjectFromIATACode(iDCardApplication.IATA_Code__c); 
           // IDCardUtil.CreateIDCardApplicationCase(iDCardApplication, theAccount,false);
        
            
        }
        catch (Exception ex) {  
          //  database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));

            System.debug('********* EXCEPTION'+ ex.getMessage());
            throw ex;
        }

    }
}
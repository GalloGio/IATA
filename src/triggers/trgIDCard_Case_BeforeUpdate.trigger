trigger trgIDCard_Case_BeforeUpdate on Case (before update) {
    
    ID caseRecordType = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Application');
    List<Profile> currentUserProfile; 
    Boolean isCurrentUserProfileInit = false;    
    Boolean isSiteGuestUser = false;
    Boolean isAdmin = false;
    
    //update for New Interaction: if new case a parent case with type = Id Cards: update new interaction fields
    Map<String,Case> casePerParentId = new Map<String,Case>();
    
    
    for (Case aCase : trigger.new)
    {
        if (!isCurrentUserProfileInit && aCase.RecordTypeId == caseRecordType)
        {
            //R.A 6/17/2013: allow Admins to change the status of ID Card otherwise blocks the change of Approval, Pending Payment and Pending 
            currentUserProfile = [SELECT ID, Name FROM Profile WHERE id =: UserInfo.getProfileId() limit 1];
            if (currentUserProfile.size() > 0)
            {
                isAdmin = currentUserProfile[0].Name.toLowerCase().contains('system administrator');
                isSiteGuestUser = currentUserProfile[0].Name.toLowerCase().contains('idcard portal profile');
                isCurrentUserProfileInit = true;
            }
                            
        }
        
        if (isCurrentUserProfileInit && aCase.RecordTypeId == caseRecordType)
        {
            Case oldCase = Trigger.oldMap.get(aCase.ID);
            if ((!isAdmin && !isSiteGuestUser) || Test.isRunningTest() )
            {
                if (oldCase.ID_Card_Status__c == aCase.ID_Card_Status__c) {
                    continue;
                }                   
                 
                if(oldCase.ID_Card_Status__c == IDCardUtil.CASECARDSTATUS_APPROVED && aCase.ID_Card_Status__c != IDCardUtil.CASECARDSTATUS_REJECTED)
                {
                    aCase.addError('The ID Card Case cannot be updated if the status is ' + oldCase.ID_Card_Status__c);
                    continue;
                }
                if(oldCase.ID_Card_Status__c == IDCardUtil.CASECARDSTATUS_REJECTED && aCase.ID_Card_Status__c != IDCardUtil.CASECARDSTATUS_APPROVED)
                {
                    aCase.addError('The ID Card Case cannot be updated if the status is ' + oldCase.ID_Card_Status__c);
                    continue;
                }
                
                if(oldCase.ID_Card_Status__c == IDCardUtil.CASECARDSTATUS_PENDING_MNG_APPROVAL && (aCase.ID_Card_Status__c != IDCardUtil.CASECARDSTATUS_APPROVED && aCase.ID_Card_Status__c != IDCardUtil.CASECARDSTATUS_REJECTED))
                {
                    aCase.addError('The ID Card Case cannot be updated from the status ' + oldCase.ID_Card_Status__c + ' to the status ' + aCase.ID_Card_Status__c);
                    continue;
                }
    
            }               
                        
            //Case For Cheque Payment Manager Approval
            //Code not bulkied but this trigger runs only in case of cheque payment after the manager approves the case
            
            SavePoint sp = database.setSavepoint();             
            
            try
            {
                if (aCase.RecordTypeId == caseRecordType && aCase.ID_Card_Status__c == IDCardUtil.CASECARDSTATUS_APPROVED && oldCase.ID_Card_Status__c == IDCardUtil.CASECARDSTATUS_PENDING_MNG_APPROVAL)
                {                  
                        
                    //get IDCard and Application
                    ID_Card_Application__c application = [Select VER_Number__c, UIR__c, Type_of_application__c, Title__c, Terms_and_Conditions_Time_Stamp__c, Telephone__c, SystemModstamp, Start_Date_Industry__c, Start_Date_Agency_Year__c, Start_Date_Agency_Month__c, Solicitation_Flag__c, Selected_Preferred_Language__c, Revenue_Confirmation__c, Revenue_Confirmation_Validation_Failed__c, Renewal_From_Replace__c, Regional_Office__c, Promotion_Code__c, Profit_Center__c, Position_in_Current_Agency__c, Position_Code__c, Photo__c, Payment_Type__c, Payment_Transaction_Number__c, Payment_Date__c, Payment_Currency__c, Payment_Credit_Card_Number__c, Payment_Amount__c, Package_of_Travel_Professionals_Course_2__c, Package_of_Travel_Professionals_Course_1__c, OwnerId, Name, Middle_Initial__c, Last_Name__c, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, ITDI_Courses_Fee__c, ID_Card_Fee__c, IDCard_Prefered_Language__c, IDCard_Expedite_Delivery__c, IDCard_Expedite_Delivery_Fee__c, IATA_numeric_code_previous_employer_4__c, IATA_numeric_code_previous_employer_3__c, IATA_numeric_code_previous_employer_2__c, IATA_numeric_code_previous_employer_1__c, IATA_Code_for_previous_agency__c, IATA_Code__c, Hours_worked__c, Hours_Worked_Validation_Failed__c, Hours_Worked_Code__c, Gender__c, First_Name__c, Email_admin__c, Duties_in_Current_Agency__c, Duties_Code__c, Displayed_Name__c, Date_of_Birth__c, CurrencyIsoCode, CreatedDate, CreatedById, ConnectionSentId, ConnectionReceivedId, Case_Number__c, Approving_Manager_s_Name__c, Approving_Manager_s_Email__c, Applicable_Fee__c, AgencyShare_Confirmation__c From ID_Card_Application__c  WHERE ID =: aCase.Related_ID_Card_Application__c];
                    ID_Card__c[] existingIdCard = [Select Photo__c, Valid_To_Date__c, Valid_From_Date__c, Type_of_ID_Card__c, Related_Contact__c, Name_on_ID_Card__c, IsDeleted, Id, ID_Card_Application__c, Card_Status__c, Card_Code__c, Agency_IATA_Code__c From ID_Card__c WHERE ID_Card_Application__c =: application.ID limit 1];
                    
                    // To Avoid Creating Card/Contact more than once
                    if (existingIdCard.size() == 0)
                    {
                                                                        
                        ID_Card__c idCardNew = new ID_Card__c();     
                        
                        //**Create Contact only for new application
                        if (application.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_NEW)
                              aCase.ContactId = IDCardUtil.CreateContactWhenNewCardIsApproved(application);
                                                   
                        Contact[] contacts = [Select c.AgencyShare_Confirmation__c,c.ID_Card_Preferred_Language__c, c.VER_Number__c, c.Title, c.FirstName, c.Middle_Initial__c, c.LastName, c.UIR__c, c.Account.IATACode__c, c.Hours_per_week__c, c.Duties__c, c.Position__c, c.Solicitation_Flag__c, c.Revenue_Confirmation__c  From Contact c where c.VER_Number__c =: Decimal.valueof(application.VER_Number__c) and c.RecordType.Name =: 'Standard' and id=:aCase.ContactId];
    
                        if (contacts == null || contacts.size() == 0) {
                            throw new IDCardApplicationException(string.format(Label.ID_Card_Contact_Not_found_for_VER, new string[] {application.VER_Number__c}));
                        }        
                                
                        idCardNew = IDCardUtil.CreateIDCardObjectFromApplication(application, contacts[0]);
                            insert idCardNew;                                                                  
                    } 
                            
                    Contact theContact = [Select c.Id,c.AgencyShare_Confirmation__c,c.ID_Card_Preferred_Language__c, c.VER_Number__c, c.Title, c.FirstName, c.Middle_Initial__c, c.LastName, c.UIR__c, c.Account.IATACode__c, c.Hours_per_week__c, c.Duties__c, c.Position__c, c.Solicitation_Flag__c, c.Revenue_Confirmation__c  From Contact c where c.VER_Number__c =: Decimal.valueof(application.VER_Number__c) and c.RecordType.Name = : 'Standard' and id=:aCase.ContactId ];
                    
                    //Update Contact Info
                    theContact.LastName = application.Last_Name__c;
                    theContact.ID_Card_Preferred_Language__c = application.IDCard_Prefered_Language__c;
                    theContact.Phone = application.Telephone__c;
                    theContact.Email = application.Email_admin__c;                        
                    theContact.Position__c = application.Position_in_Current_Agency__c;
                    theContact.Duties__c = application.Duties_in_Current_Agency__c;
                    theContact.Hours_per_week__c = application.Hours_worked__c;
                    theContact.Solicitation_Flag__c = application.Solicitation_Flag__c;                       
                    theContact.Revenue_Confirmation__c = application.Revenue_Confirmation__c;
                    theContact.AgencyShare_Confirmation__c = application.AgencyShare_Confirmation__c;
                           
                    if (application.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REPLACEMENT)
                    {
                        Account theAccount;
                        try
                        {
                            Case a = [ Select Account.Id from Case where Related_ID_Card_Application__c =: application.Id limit 1];
                            theAccount = [ Select IATACode__c, BillingCountry,type, Id From Account where Id =: a.Account.Id limit 1];
                        }
                       
                       catch( Exception e)
                       {                    
                            System.debug('**** Error doing workaround '+ e);
                            theAccount = IDCardUtil.GetAccountObjectFromIATACode(application.IATA_Code__c);
                       } 
                                       
                       theContact.AccountId = theAccount.Id;                                    
                    }
        
                    update theContact;   
                        
                    //Update Existing Card Status
                    //existingIdCard[0].Card_Status__c = IDCardUtil.CARDSTATUS_APPROVED;
                    //update existingIdCard[0];       
    
                    // Change the status of the old card to "Cancelled" (only on reissue => Lost/stolen) 
                    if (application.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REISSUE)
                    {
                        //find old card to cancel it
                        ID_Card__c[] idCards = [Select Card_Status__c, Valid_To_Date__c From ID_Card__c where Related_Contact__c = :theContact.Id AND Card_Status__c =: IDCardUtil.CARDSTATUS_VALID order by CreatedDate desc];
                        if (idCards != null && idCards.size() > 0) {
                            idCards[0].Card_Status__c = IDCardUtil.CARDSTATUS_CANCELED;
                            update idcards[0];
                        }
                    } 
                                                            
                    // call the cropping tool web service to rename the photo filename (from a GUID to the UIR)
                    IDCardUtil.renameIDCardPhotoOfContact(application.ID, '', UserInfo.getSessionId());     
                }
            }  
            catch(Exception e)
            {
                database.rollback(sp);  
                aCase.addError('** Error '+ e.getMessage() + '  ' + e.getStackTraceString());
                break;
            }
             
        }
        //2014-07-17 new interactiuon feature
        else {
            //if case a now a parent id add it to map for checking
            if(aCase.ParentID!=null )
                casePerParentId.put(aCase.parentId,acase);
        }
        
    }
    //2014-07-17 new interactiuon feature
    if(casePerParentId.size()>0){
        //look for parent case which are Id cards type
        List<Case> idCardsParentCases = [select id,CaseNumber,New_interaction__c from case where Id in :casePerParentId.keyset() and RecordTypeId = :caseRecordType ];
        //for each of them we update New interaction on child case
        for(Case parentCase : idCardsParentCases){
            parentCase.New_interaction__c = 'New Related Case';
        }
        update idCardsParentCases;
    }
}
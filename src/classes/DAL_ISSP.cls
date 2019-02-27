public with sharing class DAL_ISSP {
    
    public static User getUser(Id userId) {
        if (userId == null)
            return null;
        List<User> users = [select Id,ContactId,contact.IFG_User_Status__c,Contact.AccountId,
		contact.IFG_Production__c, contact.IFG_PreProduction__c
        from User where Id =:userId];
        if (users.size() > 0)
            return users[0];
        return null;
    }
    
    public static list<User> getUserListByNameOrEmail(String nameOrEmail) {
        return
            [SELECT Id, Username, ContactId, Email, Portal_User_Frozen__c,
                IsActive, Portal_User_Frozen_Checkbox__c, Contact.Community__c
               FROM User 
              WHERE (Username=: nameOrEmail 
                 OR email =: nameOrEmail)
                 AND (IsActive = true OR Portal_User_Frozen_Checkbox__c = true)
                 AND ContactId != ''
                 limit 1];
    }
    
    public static list<LoginHistory> getLoginHistoryByUserId(ID userID) {
        return 
            [SELECT l.UserId 
               FROM LoginHistory l 
              WHERE UserId =: userId];
    }
    
    
    public static Contact getContact(Id contactId) {
        if (contactId == null)
            return null;
        List<Contact> contacts = [select Id, Name, FirstName, LastName, Title, Email, Phone, Fax, OtherPhone, 
                    OtherCity, OtherStreet, OtherState,OtherPostalCode, OtherCountry, Function__c, Membership_Function__c, 
                    User_Portal_Status__c, MobilePhone, Preferred_Language__c,Salutation,Airline_Contact_Type__c, Services__c ,
                    AccountId, Account.Name, Account.Status__c, Account.BillingStreet, Account.BillingCity,
                    Account.BillingCountry, Account.IATACode__c, Account.Airline_Prefix__c, Account.BillingPostalCode,Account.BillingState,
                    Account.TradeName__c, Account.ParentId, Account.Top_Parent__c, Account.Airline_designator__c,
                    Account.Accumulated_Irregularities__c,Account.Sector__c,Account.Category__c,Account.VAT_Number__c,
                   	Account.Fin_statements_submission_deadline__c, BSP_CASS_Payment_contact__c,Invoicing_contact__c,Airline_Credit_Risk_Manager__c,
               		Financial_Assessment_Contact__c, Account.Field_Head_Office__c, Account.Membership_status__c, Account.Phone, Account.Fax,Account.Email__c,Account.WebSite,
                    Account.ICAO_designator__c, Account.IATA_ISO_Country__r.Name, Account.IATA_ISO_Country__r.Region__c, Account.IATA_ISO_Country__r.ISO_Code__c,Account.IATA_ISO_Country__r.OSCAR_enabled__c,
               		Account.Location_Type__c, Account.RecordType.DeveloperName, Account.Overdue_Invoices_Indicator__c ,Account.Top_Parent__r.IATACode__c,Account.IATA_ISO_Country__r.Prevent_Portal_Trade_Name_Change__c,
					Account.Top_Parent__r.Location_Type__c , Account.Region_formula__c,PhoneNational__c,FAXNational__c,MobileNational__c,Account.IATA_ISO_Country__r.Enable_Minor_Changes_from_Portal__c,
					ID_Card_Holder__c, Account.DDS_status__c, Account.DDS_Last_Update_Date__c,Account.PhoneNational__c,Account.FAXNational__c,
                    Account.Location_Class__c, Account.CNS_Account__c,Account.IATA_ISO_Country__r.ANG_Portal_Service__c, Account.ANG_IEP_Status_FF__c, Account.Quality__c,Account.ANG_Accreditation_Model__c,Account.Legal_name__c,
		            Authorized_Signatory__c, Account.ANG_FA_Opt_out__c, Account.IATA_ISO_Country__r.ANG_Enable_NewGen__c, Account.Top_Parent__r.Legal_name__c, Account.Top_Parent__r.Name_on_AOC__c, Account.Name_on_AOC__c
                    from Contact where Id=:contactId];
        if (contacts.size() > 0)
            return contacts[0];
        return null;
    }
    
    public static List<AccountTeamMember> getPortalAdmins(Id accountId) {
        if (accountId == null)
            return null;
        List<AccountTeamMember> teamMembers = [select UserId, TeamMemberRole,
                User.Contact.Salutation, User.Contact.Name, User.Contact.Email, 
                User.Contact.Account.BillingCountry
                from AccountTeamMember where accountId=:accountId and 
                (TeamMemberRole='Portal Administrator' or TeamMemberRole='Portal Regional Administrator')];
                
        return teamMembers;
        
    }
    
    public static Case getCase(String caseId) {
        List<Case> cases = [select  
                (Select Id, IsPublished, CreatedDate From CaseComments),Product_Manager_ACR__c,ArchivedDate__c,Account.Type,Account.IATA_ISO_Country__c,account.IATA_ISO_Country__r.iso_code__c,
                Id,Subject,Description,CaseArea__c, Country_concerned_by_the_query__c,CaseNumber,Portal_Case_Status__c,
                ContactId, RecordType.Name, RecordType.DeveloperName, Type, Priority, Classification_SIS__c, Defect_Issue__c, Airline_Designator__c,
                Member_Code_Numeric__c, Contact.Name, Contact.Email, Contact.Phone, Contact.MobilePhone, Contact.Fax, Contact.FirstName, Contact.LastName ,
                CreatedDate, ClosedDate, Region__c, IATA_Code__c, BSPCountry__c, Account.Name, Account.Status__c, SAAM_Deadline_Date__c,
                Process_Approved__c, Process_Start_Date__c, Missing_Documents_A_B_received__c,Financial_Review_Type__c,Deadline_Date__c,FA_Second_Deadline_Date__c,
                Missing_Documents_A_B_requested__c, Rejection_Withdrawal_remarks__c,Type_of_customer__c,FA_Third_Deadline_Date__c,Submitted_Date__c,Financial_Review_Result__c,
                Reason,Sub_Type__c,IATA_office__c,BSP_s_concerned__c,Business_Criticality__c,DPC_Software__c,Financial_Security_Amount__c,Financial_Security_Currency__c,
                Status,ParentId,Origin,Account_Location_Type__c,AccountId,SuppliedEmail,DPC_Case_classification__c,FS_Deadline_Date__c,FS_Second_Deadline_Date__c,FS_Third_Deadline_Date__c,
                Planned_Start_CR__c,Planned_End_CR__c,CR_Status__c,DPC_Date_Time_New__c,DPC_Date_Time_Scheduled__c,FS_Submitted_Date__c,IFAP_Agent_Code__c,IFAP_Agent_Type__c,
                DPC_Date_Time_Completed__c,ACCA_Case_Age_for_Standard_CR__c,ACCA_Case_Age_for_Scheduled_CR__c,
                DPC_Case_Age_for_standard_DSR__c,DPC_Case_Age_for_Scheduled_DSR__c,ACCA_Owner__c, isDPCCurrentUser__c,
                Escalated_Status_ACCA__c, DPC_ACR_Number__c, DPC_Person_in_Charge__c, Object_Set_Up_Affected__c,
                Evaluation_Effort__c, Specification_Effort__c, Coding_Effort__c, Unit_Test_Effort__c, System_Test_Effort__c,
                QA_Effort__c, Documentation_Effort__c, Implementation_Effort__c, Other_Impact_and_Effort__c,
                Estimated_Total_Person_days__c, Estimated_Delivery_Date__c, Applicable_to_Which_Version_s__c,
                Impact_Analysis_Completed_By__c, Deployment_date_to_acca__c, Expected_Deadline__c,OwnerId, Owner.Name,
                CurrencyIsoCode, Estimated_Total_Development_Cost__c, Estimated_Processing_Cost_if_appl__c,Case_Language__c,
                Account_Concerned__c, IATAcode__c, Reason1__c,Planned_Implementation_Date__c,Documentation_Complete__c,Planned_Documentation_Date__c,
                PO_Number__c, Visible_on_ISS_Portal__c,Instant_Survey_Last_feedback_received__c,Dossier_reception_date__c, IFAP_Country_ISO__c,
                Outstanding_Amount__c,End_of_Grace_Period_Date__c,Total_Irregularities__c,Update_AIMS_IRR__c,Update_AIMS_IRRWITH__c,Update_AIMS_DEF__c,Reason_for_Default__c,
             	DEF_Withdrawal_Approval_Rejection__c,DEF_Withdrawal_Approval_Rejection_Date__c,Update_AIMS_REI_DEFWITH__c,Remittance_Date__c,Short_Payment_Amount__c,Billing_Amount__c,
                Collected_amount__c, E2CP__AdditionalCC__c, Has_the_agent_paid_invoice__c, Account.Location_Type__c, Reason_for_Deadline__c, Cost_Centre__c, Action__c, Due_Date__c, 
                Action_Person__c, Detailed_Description__c, Source_of_Case__c, IsClosed,
                OSCAR__c, Oscar__r.Process__c
                FROM Case where Id=:caseId];
        if (cases.size() > 0)
            return cases[0];
        return null;
        
    }
    
    public static boolean visibilityOnIATACertificate(String accCategory, String accStatus){
        List<VisibilityOnIATACertificates__c> VisibilityOnIATACertificatesCS = VisibilityOnIATACertificates__c.getall().values();
        String accountCategory, accountStatus;
       
        for(VisibilityOnIATACertificates__c v : VisibilityOnIATACertificatesCS){
            accountCategory = v.Account_Category__c;
            accountStatus = v.Account_Status__c;
           
            if(accountCategory == accCategory && accountStatus == accStatus){
                return true;
            }
        }
        return false;
    }
}
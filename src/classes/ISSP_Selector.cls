public with sharing class ISSP_Selector {
	public ISSP_Selector() {

	}

	public static AMS_Pax_Accreditation_Form__c fetchAMSProcessForm(Id caseId){

        List<AMS_Pax_Accreditation_Form__c> newForms = [
                    SELECT Id, Name, SAAM_Case__c, Submitted_to_IATA__c, CurrencyIsoCode, IATACode__c, ISSP_AMS_Bank_account__c, ISSP_AMS_Date_license_granted__c, ISSP_AMS_Date_Registration_granted__c, ISSP_AMS_GDS_with_signed_contract__c,
                    ISSP_AMS_Gross_Amnt_First_year__c, ISSP_AMS_Gross_Amnt_Second_year__c, ISSP_AMS_IATA_Registered_Cargo_Agent__c, ISSP_AMS_Legal_Reg_Name_Address__c, ISSP_AMS_Legal_Status__c,
                    ISSP_AMS_License_No__c, ISSP_AMS_Min_Paidup_capital__c, ISSP_AMS_Online_Agency_Application__c, ISSP_AMS_Online_Agency_URL__c, ISSP_AMS_Paidup_capital__c, Total_International_Sales__c,
                    ISSP_AMS_Pax_Office_Open_Date__c, ISSP_AMS_Cargo_Office_Open_Date__c, ISSP_AMS_Premises_located_at_airport__c, ISSP_AMS_Previous_default__c, ISSP_AMS_Prev_default_explanation__c, ISSP_AMS_Principal_business_Org__c, Branch_Office_Phone_National__c, Branch_Office_Fax_National__c,
                    ISSP_AMS_Registered_Capital__c, ISSP_AMS_IBAN__c, ISSP_AMS_SWIFT__c, ISSP_AMS_Trade_Reg_No__c, ISSP_AMS_VAT_number__c, ISSP_AM_Means_Identified_Travel_Agency__c, ISSP_AMS_where_incorporated__c,
                    ISSP_AMS_Entity_with_listed_shares__c, ISSP_AMS_when_incorporated__c, ISSP_AMS_Portal_admin__c, ISSP_AMS_Invoicing_Contact__c, Cargo_Agent_Account__c, ISSP_AMS_Total_Ownership__c, Validation_ERRORS__c, IsGSA__c, INVALID_Tax_number__c,
                    International_Sales_in_last_Year__c, Sales_Period_From__c, Sales_Period_To__c, Branch_Office_City__c, Branch_Office_Phone__c, Branch_Office_Street_name_number__c, Branch_Office_Country__c, Branch_Office_Email__c,
                    Branch_Office_Fax__c, Branch_Office_Postal_code__c, Wholly_managed_by_this_Head_Office__c, Wholly_owned_by_this_Head_Office__c, AMS_Agency_Id__c, ISSP_Branch_AccountId__c, ISSP_AMS_Date_of_incorporation__c,
                    ISSP_AMS_Date_of_Association__c, ISSP_AMS_Business_Activities__c, ISSP_AMS_Is_Make_Declarations__c, ISSP_AMS_Nominee_Trustee__c, ISSP_AMS_VAT_number_input__c, ISSP_AMS_Number_of_Years_Traded__c, ISSP_AMS_Type_of_License__c,
                    ISSP_AMS_State_Names_Addresses__c, ISSP_AMS_Is_Applicant_Parent__c, ISSP_AMS_For_whom_Nominee__c, ISSP_AMS_Date_legal_establishment__c, Give_full_details__c, List_the_airport_s_to_be_authorized__c, Does_your_firm_intend_to_request__c,
                    Operation_Type__c, Has_your_firm_ever_held_a_Cargo_Agency__c, Date_issued__c, Name_under_which_it_was_issued__c, Reason_for_cancellation__c, Is_your_firm_an_approved_IATA_Passenger__c, IATA_Agents_Numeric_Code__c,
                    Does_the_air_transportation_which_your__c, State_the_percentage_of_your_gross__c, Does_your_firm_sell_air_cargo__c, What_percentage_of_your_sales__c, Is_your_firm_a_General_Sales_Agent_GSA__c, List_carriers__c,
                    Been_found_guilty_of_infringements__c, Been_a_sole_proprietor__c, Been_director_or_had_a_financial__c, Agents_Numeric_Code_of_your_Head_Office__c, Been_involved_in_a_bankruptcy__c, Does_your_firm_now_share_or_intend__c,
                    If_yes_are_you_fully_and_legally__c, Is_there_any_relationship__c, Is_your_firm_acting_as_agent_for_surface__c, Is_your_firm_affiliated_directly__c, provide_details__c, Rail__c, Steamship__c, Trucking__c,
                    Were_all_IATA_Members_fully_repaid__c, Has_your_form_ever_held_CASS_Assoc_etc__c, CASS_Assoc_Code__c, CASS_Date_issued__c, CASS_Name_under_which_it_was_issued__c, State_full_name_of_such_Agent__c, Is_your_firm_insured_to_cover__c,
                    Explain_fully_stating_name__c, Does_your_firm_operate_a_cargo_cartage__c, CASS_Reason_for_cancellation__c, Does_your_firm_use_its_own_vehicles__c, Is_your_firm_a_member_of_a_national__c, Give_the_name_of_the_association_s__c, IATA_Cargo_Code__c, Type_of_Operation__c,
                    ISSP_AMS_Amount_of_credit_requested__c, ISSP_AMS_Bank_Address_1__c, ISSP_AMS_Bank_Account_Number_1__c, ISSP_AMS_Bank_Address_2__c, ISSP_AMS_Bank_Account_Number_2__c, ISSP_AMS_Bank_Address_3__c, ISSP_AMS_Bank_Account_Number_3__c, Total_Charges_Specialized_Traffic__c, Total_Number_of_Consignments__c,
                    Total_Tons_Special_Traffic__c, Total_Percentage_Specialized_Traffic__c, Total_Freight_Charges_monetary_value__c, Total_Freight_weight_Kgs__c, No_Consignments_Last_Year__c, Total_Projected_Value_Freight__c, Total_Projected_Weight_Kilos__c, Total_Projected_Number_Consignments__c, Specialize_in_particular_traffic_type__c,
                    DG_Number_of_Consignments__c, Live_Animals_No_of_Consignments__c, Other_Number_of_Consignments__c, DG_Tons__c, Live_Animals_Tons__c, Other_Tons__c, DG_Air_Freight_Charges__c, Live_Animals_Air_Freight_Charges__c, Other_Air_Freight_Charges__c, DG_Percentage__c, Live_Animals_Percentage__c, Other_Percentage__c, CGO_Region_Selection__c,
                    CGO_Region_Consignment_Selection__c, CGO_Region_Consignment_Total__c, CGO_Region_Percentage_Selection__c, CGO_Region_Percentage_Total__c, CGO_Region_Tons_Selection__c, CGO_Region_Tons_Total__c, CGO_Region_AirFreight_Total__c, CGO_Region_AirFreight_Selection__c, Total_SOIS_Prepaid_Collected__c, Total_SOIS_Charges_Collected__c, Total_SOIS_Weight__c,
                    Separate_user_access__c, Head_Office_have_access__c, Billing_payment_Head_Office__c, Billing_payment_Branch_Office__c, Billing_payment_Another_Branch__c, Branch_Office_Code__c, Payment_Via_Bank_Transfer__c, Payment_Via_Direct_Debit__c, Local_Legally_Registered_Name__c, Local_Physical_Address_Street__c, Local_Physical_Address_City__c, Local_Physical_Address_Postal_Code__c,
                    Local_Physical_Address_Province__c, Local_Physical_Address_Area__c, Local_Postal_Address_Street__c, Local_Postal_Address_City__c, Local_Postal_Address_Postal_Code__c, Local_Postal_Address_Province__c, Local_Postal_Address_Area__c, Local_Agent_Type__c, Accept_terms_and_conditions__c, Type_of_Cargo_Agent__c, Est_Future_Sales__c, Registered_to_hot_files__c, Agent_Type__c,
                    Is_change_bank_account_details__c, Is_change_legal_name__c, Is_change_location__c, Is_change_ownership_or_shareholding__c, State_Province__c, Mobile__c, MobileNational__c, Local_Physical_Address_Country__c, Local_Address_Country__c, Is_this_Branch_becoming_a_Head_Office__c, Is_this_Head_Office_becoming_a_Branch__c, Please_provide_details_for_the_change__c, Provide_details_for_change_affect_staff__c,
                    Provide_explanation_for_change_locations__c, Will_such_change_affect_locations__c, Will_such_change_affect_the_managers__c, Will_such_change_affect_the_premises__c, Will_the_change_of_ownership_cause__c, Effective_Date_Of_Change__c, Give_details_for_authorization_to_act__c, Give_details_for_the_change_of_ownership__c, Have_any_having_authorization_to_act__c, Issued_share_capital__c,
                    Specify_Legal_Status_After_Change__c, Issued_share_capital_After_Change__c, Trade_Name__c, ISSP_AMS_Curr_Entity_with_listed_shares__c, ISSP_AMS_Total_Current_Ownership__c, ISSP_AMS_Total_Previous_Ownership__c, Is_your_firm_handling_Dangerous_Goods__c, Country__c, Account_Name__c,Scope_of_Change__c,Agency_Codes_Concerned__c,Billing_State__c,Website__c,
                    Confirm_Legal_Details_are_correct__c,Notify_Change_Legal_Details__c,Confirm_Location_Details_are_correct__c,Notify_Change_Location__c,Confirm_Ownership_details_are_correct__c,Notify_Change_Ownership__c,Map_Company_Type_to_Legal_Status__c,New_Head_Office_IATA_Code__c,Shipping_Street__c,Shipping_City__c,Shipping_Postal_Code__c,Shipping_State__c,HO_Account__c,RecordTypeId,
                    IATAN_Code__c,IATA_Registered_IATAN_Agent__c,Enable_Credit_Card_FOP__c,IATAN_Agent_Account__c,AE_separate_Legal_Entity__c,ANG_AE_SameLegal__c,ANG_Accreditation_Model_to_Change__c, Notify_Change_Accreditation_Type__c, Confirm_accreditation_type_are_correct__c, Last_Scope_Of_Change__c, ANG_Accreditation_type__c
                    FROM AMS_Pax_Accreditation_Form__c
                    WHERE SAAM_Case__c = :caseId
                                         LIMIT 1
                ];
        if(newForms.size() != 0) return newForms[0]; else return null;
	}

	public static Map<String, String> getMapAmazonFileIdentifiers(Id caseId) {
        //Get File identifiers for AmzonFile records assoc. with case
        list<AmazonFile__c> listAmazonFile = [
                Select Size_MB__c, Name, Full_Name_Unique__c, CreatedDate, CreatedById, CreatedBy.Name, Case__c , File_Identifier__c
                From AmazonFile__c
                Where Case__c = :caseId
                                             ];

        SYSTEM.DEBUG('RETRIEVED listAmazonFile size:' + listAmazonFile.size());

        Map<String, String> mapAmazonFileIdentifiers = new Map<String, String>();
        for ( AmazonFile__c amazonFile : listAmazonFile) {
            if (!mapAmazonFileIdentifiers.containsKey(amazonFile.File_Identifier__c)) {
                //system.debug('FILE IN FOLDER: ' + folderName);
                mapAmazonFileIdentifiers.put(amazonFile.File_Identifier__c, amazonFile.File_Identifier__c);
            }
        }
        return mapAmazonFileIdentifiers;
    }

    public static Map<String, String> getLanguagesMap() {

        Map<String, String> languagesMap = new Map<String, String>();

        languagesMap.put('en_US','English');
        languagesMap.put('en_AU','English');
        languagesMap.put('en_CA','English');
        languagesMap.put('en_IN','English');
        languagesMap.put('en_MY','English');
        languagesMap.put('en_PH','English');
        languagesMap.put('fr', 'French');
        languagesMap.put('es', 'Spanish');
        languagesMap.put('ar', 'Arabic');
        languagesMap.put('zh_CN', 'Chinese');
        languagesMap.put('zh_TW', 'Chinese');
        languagesMap.put('de', 'German');
        languagesMap.put('in', 'Indonesian');
        languagesMap.put('it', 'Italian');
        languagesMap.put('ja', 'Japanese');
        languagesMap.put('ko', 'Korean');
        languagesMap.put('pt_BR', 'Portuguese');
        languagesMap.put('pt_PT', 'Portuguese');
        languagesMap.put('vi', 'Vietnamese');
        languagesMap.put('th', 'Thai');

    return languagesMap;
    }

    public static Account fetchAccountConcernedDetails (Id vAccountConcernedId) {
        Account accountConcerned = [
                            SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Legal_name__c,
                            TradeName__c, Membership_status__c, IATACode__c, Sector__c, Category__c, Due_Diligence_Status__c,
                            Due_Diligence_Remarks__c, Level_of_risk__c, Email__c, Website, Phone, PhoneNational__c, Fax, FaxNational__c,
                            Mobile__c, MobileNational__c , Location_Type__c, ParentId, ShippingStreet, ShippingCity, ShippingState,
                            ShippingPostalCode, ShippingCountry, VAT_Number__c, Short_Name__c, Location_Class__c, IATA_ISO_Country__c,
                            Iso_State__c, Abbreviated_name__c, Abbreviated_Address__c, Remittance_frequency__c, Solicitation_Flag__c,
                            VAT_Number_2__c, CASS_Number__c,Company_Type__c
                               FROM Account
                               WHERE Id = :vAccountConcernedId
                                          LIMIT 1
                           ];
        return accountConcerned;
    }


}
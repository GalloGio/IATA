/**
    Class to store definitions for controller ISSP_APProcess.cls
    These static maps are used to define the behavior of the Airline Participation
    Joining Applications Form 
**/
public class ISSP_AP_FieldLists {
    
    public static final Map<String,String> bspMandatoryFields = new Map<String,String>{
        'Contact_Resp_Job_Title__c'     			=> 'Contact Job Title',
            'Desired_commencment_date__c'				=> 'Desired commencment date',
            'Type_of_participation_desired__c'			=> '',
            'Contact_Resp_F_Name__c'                    => '',
            'Contact_Resp_L_Name__c'                    => '',
            'Contact_Resp_Email__c'                     => '',
            'Contact_Resp_Job_Title__c'                 => '',
            'Contact_Resp_Phone__c'						=> '',
            'Online_carrier_in_the_BSP_country__c'      => '',
            'ETSP_Contact_Salutation__c'        		=> '',
            'ETSP_Contact_F_Name__c' 					=> '',
            'ETSP_Contact_L_Name__c' 					=> '',
            'ETSP_Contact_Job_Title__c' 				=> '',
            'ETSP_Contact_Address__c' 					=> '',
            'ETSP_Contact_Phone__c' 					=> '',
            'ETSP_Contact_Email__c' 					=> '',
            'Fin_Adm_Contact__c' 						=> '',
            'Fin_Adm_Contact_F_Name__c' 				=> '',
            'Fin_Adm_Contact_L_Name__c' 				=> '',
            'Fin_Adm_Contact_Job_Title__c' 				=> '',
            'Fin_Adm_Contact_Phone__c' 					=> '',
            'Fin_Adm_Contact_Address__c' 				=> '',
            'Fin_Adm_Contact_Zip_Code__c' 				=> '',
            'Fin_Adm_Contact_City__c' 					=> '',
            'Fin_Adm_Contact_Country__c' 				=> '',
            'Fin_Adm_Contact_Email__c' 					=> '',
            'Receive_HOT_files__c' 						=> '',
            'BSPLink_access_level_requested__c'         => '',
            'Participate_in_any_Commission_Control__c'	=> '',
            'Participate_in_any_Remit_scheme__c' 		=> '',
            'Accept_payment_Cards_for_BSP_ticket__c' 	=> '',
            'Join_BSP_ECCB__c' 							=> '',
            'Flights_operated_in_the_BSP_country__c'	=> ''
            'BSP_Local_address__c' 						=> '',
            'BSP_Local_Zip_Code__c'						=> '',
            'BSP_Local_City__c' 						=> ''
            };

    // mandatory fields when Participate_in_any_Commission_Control__c == 'Yes'
    // only for BSP
    //  key = DPC_System__c value
    //  value = list of mandatory fields
    public static final Map<String,list<String>> bspCommissionMandatoryFields = new Map<String,list<String>>{
        'IBSPS'     => new list<String>{'Default_Commission_Rate__c','Maximum_Commission_Rate__c'},
        'Maestro'   => new list<String>{'Default_Commission_Rate__c','Minimum_Commission_Rate__c','Maximum_Commission_Rate__c'}
    };

    //Mandatory BSP fields specific to Brazil
    public static final Map<String,String> bsp_BR_MandatoryFields = new Map<String,String>{
        'AP_BR_Address_CNP__c'     					=> '',
            'AP_BR_Address_To_Insert__c'				=> '',
            'AP_BR_BankBeneficiary_Account_Holder__c'	=> '',
            'BSP_Country_VAT_Tax_number__c'				=> ''
            };
                          
   //Mandatory BSP fields specific to Mexico
    public static final Map<String,String> bsp_MX_MandatoryFields = new Map<String,String>{
        //'AP_BR_Address_CNP__c'     					=> '',
            'AP_BR_Address_To_Insert__c'				=> '',
            'BSP_Country_VAT_Tax_number__c'				=> ''
            };             
                            
    //Mandatory BSP fields specific to Argentina
    public static final Map<String,String> bsp_AR_MandatoryFields = new Map<String,String>{
        'Clave_Bancaria_Unificada_CBU__c'     		=> ''
            };
                                        
    //Mandatory BSP fields specific to Costa Rica
    public static final Map<String,String> bsp_CR_MandatoryFields = new Map<String,String>{
        'Other_TAX_Identification__c'     		=> ''
            };
                                        
    //Mandatory BSP fields specific to Cyprus
    public static final Map<String,String> bsp_CY_MandatoryFields = new Map<String,String>{
        'Cyprus_Turkey_based_Airline__c'     		=> ''
            };
                                            
                                       
	//Mandatory BSP fields specific to Ecuador
	public static final Map<String,String> bsp_EC_MandatoryFields = new Map<String,String>{
	    'Airline_s_Fiscal_Status__c'     		=> '',
	    'BSP_Country_VAT_Tax_number__c'			=> ''
	};
                                            
    //Mandatory BSP fields specific to Venezuela
    public static final Map<String,String> bsp_VE_MandatoryFields = new Map<String,String>{
        'Airline_s_Fiscal_Status__c'     		=> '',
        'BSP_Country_VAT_Tax_number__c'			=> ''
    };
                                            
    //Mandatory BSP fields specific to Korea
    public static final Map<String,String> bsp_KR_MandatoryFields = new Map<String,String>{
        'Local_CC_Settlement_Scheme__c'     		=> ''
    };
    
    //Mandatory BSP fields specific to Colombia
    public static final Map<String,String> bsp_CO_MandatoryFields = new Map<String,String>{
        'Name_Appearing_in_VAT__c'     		=> '',
        'Colombia_Type_of_Contributor__c' 	=> ''
    };
    
    //Mandatory BSP fields specific to Italy
    public static final Map<String,String> bsp_IT_MandatoryFields = new Map<String,String>{
        'Other_TAX_Identification__c'     		=> ''
    };    
   	
    //Mandatory BSP fields specific to Canada
    public static final Map<String,String> bsp_CA_MandatoryFields = new Map<String,String>{
        'Canada_Has_Principal_Office__c'     		=> ''
    };       
        
    public static final Map<String,Map<String,String>> bsp_MandatoryFieldsbyCountry = new Map<String,Map<String,String>>{
        'BR' => bsp_BR_MandatoryFields,
        'AR' => bsp_AR_MandatoryFields,
        'CR' => bsp_CR_MandatoryFields,
        'CY' => bsp_CY_MandatoryFields,
        'EC' => bsp_EC_MandatoryFields,
        'KR' => bsp_KR_MandatoryFields,
        'MX' => bsp_MX_MandatoryFields,
        'VE' => bsp_VE_MandatoryFields,
        'CO' => bsp_CO_MandatoryFields,
        'IT' => bsp_IT_MandatoryFields,
        'CA' => bsp_CA_MandatoryFields
    };
                                                                
    public static final Map<String,String> cassMandatoryFields = new Map<String,String>{
        'Desired_commencment_date__c' 					=> '',
            'Contact_Resp_Salutation__c' 					=> '',
            'Contact_Resp_F_Name__c' 						=> '',
            'Contact_Resp_L_Name__c' 						=> '',
            'Contact_Resp_Email__c' 						=> '',
            'Contact_Resp_Job_Title__c'		 				=> '',
            'Contact_Resp_Phone__c' 						=> '',
            'Online_carrier_in_the_BSP_country__c' 			=> '',     
            'CASSLink_Contact_Salutation__c' 				=> '',
            'CASSLink_Contact_F_Name__c' 					=> '',
            'CASSLink_Contact_L_Name__c' 					=> '',
            'CASSLink_Contact_Job_Title__c' 				=> '',
            'CASSLink_Contact_Email__c'						=> '',
            'CASSLink_Contact_Phone__c' 					=> '',
            'Airline_Billing_Data_File_Type__c' 			=> '',
            'Airline_Invoice_Address__c'					=> '',
            'Billing_File_Emrgcy_Contact_Salutation__c' 	=> '',
            'Billing_File_Emrgcy_Contact_F_Name__c' 		=> '',
            'Billing_File_Emrgcy_Contact_L_Name__c' 		=> '',
            'Billing_File_Emrgcy_Contact_Job_Title__c' 		=> '',
            'Billing_File_Emrgcy_Contact_Email__c' 			=> '',
            'Receive_HOT_files__c' 							=> '',
            'Receive_XLS_Reports__c' 						=> '',
            'Pay_Commission_to_agents__c' 					=> '',
            'Flights_operated_in_the_BSP_country__c'		=> ''
            };


    //Mandatory CASS fields specific where the country requirement Local_VAT_Mandatory__c is 'YES'
    public static final Map<String,String> cassLocalVATMandatoryFields = new Map<String,String>{
        'BSP_Country_VAT_Tax_number__c' => ''
    };

    //Mandatory CASS fields specific where the country requirement Local_VAT_Mandatory__c is not 'YES'
    public static final Map<String,String> cassLocalVATNOTMandatoryFields = new Map<String,String>{
        'VAT_Tax_number_in_your_home_country__c' => ''
    };

   	//Mandatory CASS fields specific to France
	public static final Map<String,String> cass_FR_MandatoryFields = new Map<String,String>{
		'Company_Registration_number__c'     	=> '',
		'Name_of_business_comm_assoc__c'		=> '',
        'Capital_amount_of_the_business__c'		=> ''   
	};
                                                                            
    //Mandatory CASS fields specific to Philippines
	public static final Map<String,String> cass_PH_MandatoryFields = new Map<String,String>{
		'CASS_PH_Bilateral_Agreement__c'     		=> '',
		'CASS_PH_Preferred_Billing_Currency__c'	=> ''
	};
                                                                          
    //Mandatory CASS fields specific to Romania
	public static final Map<String,String> cass_RO_MandatoryFields = new Map<String,String>{
		'Airline_Intra_Europe_Flights__c'     		=> ''
	};
        
    //Mandatory CASS fields specific to Italy
    public static final Map<String,String> cass_IT_MandatoryFields = new Map<String,String>{
        'Other_TAX_Identification__c'     		=> ''
    };       
	
    public static final Map<String,Map<String,String>> cass_MandatoryFieldsbyCountry = new Map<String,Map<String,String>>{
        'BR' => bsp_BR_MandatoryFields,
        'AR' => bsp_AR_MandatoryFields,
        'CY' => bsp_CY_MandatoryFields,
        'EC' => bsp_EC_MandatoryFields,
        'FR' => cass_FR_MandatoryFields,
        'MX' => bsp_MX_MandatoryFields,
        'PH' => cass_PH_MandatoryFields,
        'RO' => cass_RO_MandatoryFields,
        'VE' => bsp_VE_MandatoryFields,
        'CO' => bsp_CO_MandatoryFields,
        'IT' => cass_IT_MandatoryFields
    };

	public static final Map<String,String> changeMandatoryFields = new Map<String,String>{
            'Desired_commencment_date__c'				=> 'Desired commencment date',
            'Type_of_Change_Requested__c'				=> 'Type of change requested',
            'Contact_Resp_Job_Title__c'     			=> 'Contact Job Title',
            'Contact_Resp_F_Name__c'                    => '',
            'Contact_Resp_L_Name__c'                    => '',
            'Contact_Resp_Email__c'                     => '',
            'Contact_Resp_Job_Title__c'                 => '',
            'Contact_Resp_Phone__c'						=> ''
    };
    
    public static final Map<String,String> changeMasterTableMandatoryFields = new Map<String,String>{
            'Fin_Adm_Contact__c' 						=> '',
            'Fin_Adm_Contact_F_Name__c' 				=> '',
            'Fin_Adm_Contact_L_Name__c' 				=> '',
            'Fin_Adm_Contact_Job_Title__c' 				=> '',
            'Fin_Adm_Contact_Phone__c' 					=> '',
            'Fin_Adm_Contact_Address__c' 				=> '',
            'Fin_Adm_Contact_Zip_Code__c' 				=> '',
            'Fin_Adm_Contact_City__c' 					=> '',
            'Fin_Adm_Contact_Country__c' 				=> '',
            'Fin_Adm_Contact_Email__c' 					=> ''
    };
        
    public static final Map<String,String> changeBankMandatoryFields = new Map<String,String>{
            'Desired_commencment_date__c'				=> 'Desired commencment date',
            'Contact_Resp_Job_Title__c'     			=> 'Contact Job Title',
            'Contact_Resp_F_Name__c'                    => '',
            'Contact_Resp_L_Name__c'                    => '',
            'Contact_Resp_Email__c'                     => '',
            'Contact_Resp_Job_Title__c'                 => '',
            'Contact_Resp_Phone__c'						=> ''
    };
        
}
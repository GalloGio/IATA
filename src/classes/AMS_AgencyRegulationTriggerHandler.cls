public class AMS_AgencyRegulationTriggerHandler {

    public static void handleBeforeInsert() {

        //fill the contact lookup with the related account financial assessment Contact
        //fillFinancialAssessmentContact((List<AMS_Agency_Regulation__c>)Trigger.New);
        
    }

    public static void handleBeforeUpdate() {

        processPostNotifSentActions((List<AMS_Agency_Regulation__c>)Trigger.New, (Map<Id,AMS_Agency_Regulation__c>)Trigger.oldMap);
        
    }

    /*public static void fillFinancialAssessmentContact(List<AMS_Agency_Regulation__c> agRegs){

        List<Id> accts = new List<Id>();
        Map<Id, Id> finAssessmentContactPerAccount = new Map<Id, Id>();

        for(AMS_Agency_Regulation__c agReg: agRegs)
            accts.add(agReg.Account__c);

        for(Contact c: [SELECT Id, AccountId FROM Contact WHERE AccountId IN: accts AND Financial_Assessment_Contact__c = TRUE])
            finAssessmentContactPerAccount.put(c.AccountId, c.Id);

        for(AMS_Agency_Regulation__c agReg: agRegs){
            if(finAssessmentContactPerAccount.get(agReg.Account__c) != null)
                agReg.Account_Admin__c = finAssessmentContactPerAccount.get(agReg.Account__c);
        }

    }*/

    //After a notification is sent by email we need to create a certification renewal Oscar
    public static void processPostNotifSentActions(List<AMS_Agency_Regulation__c> agencyRegulations, Map<Id,AMS_Agency_Regulation__c> oldAgRegulationValues){

        List<AMS_Agency_Regulation__c> regulationsRequiringRenewalDGR = new List<AMS_Agency_Regulation__c>();
        List<AMS_Agency_Regulation__c> regulationsRequiringRenewalTSA = new List<AMS_Agency_Regulation__c>();
        List<Contact> keyContacts = new List<Contact>();

        Map<Id, List<Contact>> keyContactsPerAccount = new Map<Id, List<Contact>>();

        Set<Id> accountIds = new Set<Id>();

        for(AMS_Agency_Regulation__c aReg: agencyRegulations)
            accountIds.add(aReg.Account__c);

        List<Contact> allContacts = new List<Contact>([SELECT Id, Email, AccountId, Preferred_Language__c FROM Contact WHERE AccountId IN :accountIds AND (BSP_CASS_Payment_contact__c = TRUE OR Financial_Assessment_Contact__c = TRUE)]);

        for(Contact c: allContacts){
            if(!keyContactsPerAccount.containsKey(c.AccountId))
                keyContactsPerAccount.put(c.AccountId, new List<Contact>());

            keyContactsPerAccount.get(c.AccountId).add(c);
        }

        for(AMS_Agency_Regulation__c agReg: agencyRegulations){

            if(!oldAgRegulationValues.get(agReg.Id).Notification_Sent__c && agReg.Notification_Sent__c && (agReg.Type_of_Certificate__c == AMS_Utils.CERT_DGR || agReg.Type_of_Certificate__c == AMS_Utils.CERT_TSA)){
                //system.debug('sending renewal emails to :' + keyContactsPerAccount.get(agReg.Account__c));
                //sendEmailAlert(keyContactsPerAccount.get(agReg.Account__c));
                if(agReg.Type_Of_Certificate__c == AMS_Utils.CERT_TSA)
                	regulationsRequiringRenewalTSA.add(agReg);
                else
                	regulationsRequiringRenewalDGR.add(agReg);
            }

        }

        createRenewalOSCARs_DGR(regulationsRequiringRenewalDGR, keyContactsPerAccount);
        createRenewalOSCARs_TSA(regulationsRequiringRenewalTSA, keyContactsPerAccount);

    }

    public static void sendEmailAlert(List<Contact> recipents, Id oscarId) {
        
        EmailTemplate etEN = [SELECT Id, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName LIKE 'AMS_DGR_Renewal_EN'];
        
        List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();

        for(Contact recipient: recipents){

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.saveAsActivity = false;
            mail.setToAddresses(new List<String>{recipient.Email});
            mail.setTemplateId(etEN.id);
            mail.setTargetObjectId(recipient.Id);
            mail.setWhatId(oscarId);

            mailsToSend.add(mail);
        
        }

        if(!Test.isRunningTest())   
            Messaging.sendEmail(mailsToSend);
    }

    public static void createRenewalOSCARs_DGR(List<AMS_Agency_Regulation__c> regulationsRequiringRenewal, Map<Id, List<Contact>> keyContactsPerAccount){
	
		if(regulationsRequiringRenewal != null && regulationsRequiringRenewal.isEmpty() == false){
			
	        Set<Id> accts = new Set<Id>();
	        Set<Id> isoCountries = new Set<Id>();
	
	        Map<Id, List<AMS_Agency_Regulation__c>> DGRToRenewPerAccount = new Map<Id, List<AMS_Agency_Regulation__c>>();
	
	        Map<Id, List<AMS_Agency_Regulation__c>> allNonExpiredDGRPerAccount = new Map<Id, List<AMS_Agency_Regulation__c>>();
	
	        for(AMS_Agency_Regulation__c agReg: regulationsRequiringRenewal)
	            accts.add(agReg.Account__c);
	
	
	        //Need to get all the non expired agency regulations for each account
	        List<AMS_Agency_Regulation__c> allDGR = new List<AMS_Agency_Regulation__c>([SELECT Id, Account__c, First_Name__c, Last_Name__c, Position__c, Type_of_Certificate__c, Account__r.IATA_ISO_Country__c, Account__r.Location_Class__c FROM AMS_Agency_Regulation__c WHERE Account__c IN :accts AND Expired__c = FALSE AND Type_of_Certificate__c = 'DGR']);
	
	        for(AMS_Agency_Regulation__c agReg : allDGR){
	            if(!allNonExpiredDGRPerAccount.containsKey(agReg.Account__c))
	                allNonExpiredDGRPerAccount.put(agReg.Account__c, new List<AMS_Agency_Regulation__c>());
	            allNonExpiredDGRPerAccount.get(agReg.Account__c).add(agReg);
	        }
	
	        for(AMS_Agency_Regulation__c agReg : regulationsRequiringRenewal){
	            if(!DGRToRenewPerAccount.containsKey(agReg.Account__c))
	                DGRToRenewPerAccount.put(agReg.Account__c, new List<AMS_Agency_Regulation__c>());
	            DGRToRenewPerAccount.get(agReg.Account__c).add(agReg);
	        }
	
	        Map<Id, Account> accountData = new Map<Id, Account>([SELECT Abbreviated_address__c, Abbreviated_name__c, Name, BillingState, BillingCity, IATA_ISO_Country__c, 
	                                                                   Email__c, Fax, Phone, BillingPostalCode, BillingStreet, CASS_Number__c, IATACode__c, Iso_State__c, 
	                                                                   License_Number__c, VAT_Number__c, Is_your_firm_handling_Dangerous_Goods__c, Location_Class__c, 
	                                                                   Location_Type__c, Mobile__c, Operation__c, Remittance_frequency__c, ShippingCity, ShippingCountry, 
	                                                                   ShippingPostalCode, ShippingState, ShippingStreet, Short_Name__c, Solicitation_Flag__c, TradeName__c, 
	                                                                   VAT_Number_2__c, Website, BillingCountry, Region_formula__c, Legal_name__c, IATA_ISO_Country__r.Name
	                                                            FROM Account WHERE Id IN :accts]);
	
	        for(Account acc: accountData.values())
	            isoCountries.add(acc.IATA_ISO_Country__c);
	
	        //minimum requirements for location class 'R'
	        Map<String, Integer> minimumHODgrRequirements = new Map<String, Integer>();
	        Map<String, Integer> minimumBRDgrRequirements = new Map<String, Integer>();
	        for(IATA_ISO_Country__c country : [SELECT Id, (SELECT Id, Minimum_DGR_BR__c, Minimum_DGR_HO__c, Location_Class__c
	                                                       FROM AMS_Country_Specific_Attributes__r
	                                                       WHERE RecordType.Name = 'DGR Minimum Requirements')
	                                           FROM IATA_ISO_Country__c
	                                           WHERE Id IN :isoCountries])
	        {
	            system.debug('country.AMS_Country_Specific_Attributes__r ' + country.AMS_Country_Specific_Attributes__r);
	            for(AMS_Country_Specific_Attribute__c att : country.AMS_Country_Specific_Attributes__r){
	                if(att != null){
	                    minimumHODgrRequirements.put(''+country.Id+att.Location_Class__c, att.Minimum_DGR_HO__c == null ? 0 : Integer.valueOf(att.Minimum_DGR_HO__c));
	                    minimumBRDgrRequirements.put(''+country.Id+att.Location_Class__c, att.Minimum_DGR_BR__c == null ? 0 : Integer.valueOf(att.Minimum_DGR_BR__c));
	                }
	            }
	        }
	
	        system.debug('minimumHODgrRequirements ' + minimumHODgrRequirements);
	        system.debug('minimumBRDgrRequirements ' + minimumBRDgrRequirements);
	
	        system.debug('regulationsRequiringRenewal ' + regulationsRequiringRenewal);
	
	        for(AMS_Agency_Regulation__c agReg: regulationsRequiringRenewal){
	            //only create renewal if account is going below DGR/DGA requirements
	
	            String key = agReg.Account__r.IATA_ISO_Country__c + agReg.Account__r.Location_Class__c;
	            system.debug('key value ' + key);
	            Integer minDgrHO = minimumHODgrRequirements.get(key) == null ? 0 : minimumHODgrRequirements.get(key);
	            system.debug('minDgrHO ' + minDgrHO);
	            Integer minDgrBR = minimumBRDgrRequirements.get(key) == null ? 0 : minimumBRDgrRequirements.get(key);
	            system.debug('minDgrBR ' + minDgrBR);
	
	            system.debug('accountData ' + accountData.get(agReg.Account__c));
	
	            if(isToCreateRenewalForDGR(accountData.get(agReg.Account__c), allNonExpiredDGRPerAccount.get(agReg.Account__c).size(), minDgrHO, minDgrBR)){
	                system.debug('creating renewal for DGR');
	                AMS_OSCAR__c oscar = createStagingArea(agReg, accountData.get(agReg.Account__c), DGRToRenewPerAccount.get(agReg.Account__c));
	                sendEmailAlert(keyContactsPerAccount.get(agReg.Account__c), oscar.Id);
	            }
	        }
		}
    }

    public static void createRenewalOSCARs_TSA(List<AMS_Agency_Regulation__c> regulationsRequiringRenewal, Map<Id, List<Contact>> keyContactsPerAccount){

		if(regulationsRequiringRenewal != null && regulationsRequiringRenewal.isEmpty() == false){
	
	        Set<Id> accts = new Set<Id>();
	        Set<Id> isoCountries = new Set<Id>();
	
	        Map<Id, List<AMS_Agency_Regulation__c>> TSAToRenewPerAccount = new Map<Id, List<AMS_Agency_Regulation__c>>();
	
	        Map<Id, List<AMS_Agency_Regulation__c>> allNonExpiredTSAPerAccount = new Map<Id, List<AMS_Agency_Regulation__c>>();
	
	        for(AMS_Agency_Regulation__c agReg: regulationsRequiringRenewal)
	            accts.add(agReg.Account__c);
	
	
	        //Need to get all the non expired agency regulations for each account
	        List<AMS_Agency_Regulation__c> allTSA = new List<AMS_Agency_Regulation__c>([SELECT Id, Account__c, First_Name__c, Last_Name__c, Position__c, Type_of_Certificate__c, Account__r.IATA_ISO_Country__c, Account__r.Location_Class__c FROM AMS_Agency_Regulation__c WHERE Account__c IN :accts AND Expired__c = FALSE AND Type_of_Certificate__c = 'TSA']);
	
	        for(AMS_Agency_Regulation__c agReg : allTSA){
	            if(!allNonExpiredTSAPerAccount.containsKey(agReg.Account__c))
	                allNonExpiredTSAPerAccount.put(agReg.Account__c, new List<AMS_Agency_Regulation__c>());
	            allNonExpiredTSAPerAccount.get(agReg.Account__c).add(agReg);
	        }
	
	        for(AMS_Agency_Regulation__c agReg : regulationsRequiringRenewal){
	            if(!TSAToRenewPerAccount.containsKey(agReg.Account__c))
	                TSAToRenewPerAccount.put(agReg.Account__c, new List<AMS_Agency_Regulation__c>());
	            TSAToRenewPerAccount.get(agReg.Account__c).add(agReg);
	        }
	
	        Map<Id, Account> accountData = new Map<Id, Account>([SELECT Abbreviated_address__c, Abbreviated_name__c, Name, BillingState, BillingCity, IATA_ISO_Country__c, 
	                                                                   Email__c, Fax, Phone, BillingPostalCode, BillingStreet, CASS_Number__c, IATACode__c, Iso_State__c, 
	                                                                   License_Number__c, VAT_Number__c, Is_your_firm_handling_Dangerous_Goods__c, Location_Class__c, 
	                                                                   Location_Type__c, Mobile__c, Operation__c, Remittance_frequency__c, ShippingCity, ShippingCountry, 
	                                                                   ShippingPostalCode, ShippingState, ShippingStreet, Short_Name__c, Solicitation_Flag__c, TradeName__c, 
	                                                                   VAT_Number_2__c, Website, BillingCountry, Region_formula__c, Legal_name__c, IATA_ISO_Country__r.Name
	                                                            FROM Account WHERE Id IN :accts]);
	
	        for(Account acc: accountData.values())
	            isoCountries.add(acc.IATA_ISO_Country__c);
	
	        //minimum requirements for location class 'R'
	        Map<String, Integer> minimumHOTSARequirements = new Map<String, Integer>();
	        Map<String, Integer> minimumBRTSARequirements = new Map<String, Integer>();
	        for(IATA_ISO_Country__c country : [SELECT Id, (SELECT Id, Minimum_DGR_BR__c, Minimum_DGR_HO__c, Location_Class__c
	                                                       FROM AMS_Country_Specific_Attributes__r
	                                                       WHERE RecordType.Name = 'DGR Minimum Requirements')
	                                           FROM IATA_ISO_Country__c
	                                           WHERE Id IN :isoCountries])
	        {
	            system.debug('country.AMS_Country_Specific_Attributes__r ' + country.AMS_Country_Specific_Attributes__r);
	            for(AMS_Country_Specific_Attribute__c att : country.AMS_Country_Specific_Attributes__r){
	                if(att != null){
	                    minimumHOTSARequirements.put(''+country.Id+att.Location_Class__c, att.Minimum_DGR_HO__c == null ? 0 : Integer.valueOf(att.Minimum_DGR_HO__c));
	                    minimumBRTSARequirements.put(''+country.Id+att.Location_Class__c, att.Minimum_DGR_BR__c == null ? 0 : Integer.valueOf(att.Minimum_DGR_BR__c));
	                }
	            }
	        }
	
	        system.debug('minimumHOTSARequirements ' + minimumHOTSARequirements);
	        system.debug('minimumBRTSARequirements ' + minimumBRTSARequirements);
	
	        system.debug('regulationsRequiringRenewal ' + regulationsRequiringRenewal);
	
	        for(AMS_Agency_Regulation__c agReg: regulationsRequiringRenewal){
	            //only create renewal if account is going below TSA requirements
	
	            String key = agReg.Account__r.IATA_ISO_Country__c + agReg.Account__r.Location_Class__c;
	            system.debug('key value ' + key);
	            Integer minTSAHO = minimumHOTSARequirements.get(key) == null ? 0 : minimumHOTSARequirements.get(key);
	            system.debug('minTSAHO ' + minTSAHO);
	            Integer minTSABR = minimumBRTSARequirements.get(key) == null ? 0 : minimumBRTSARequirements.get(key);
	            system.debug('minTSABR ' + minTSABR);
	
	            system.debug('accountData ' + accountData.get(agReg.Account__c));
	
	            if(isToCreateRenewalForDGR(accountData.get(agReg.Account__c), allNonExpiredTSAPerAccount.get(agReg.Account__c).size(), minTSAHO, minTSABR)){
	                system.debug('creating renewal for TSA');
	                AMS_OSCAR__c oscar = createStagingArea(agReg, accountData.get(agReg.Account__c), TSAToRenewPerAccount.get(agReg.Account__c));
	                sendEmailAlert(keyContactsPerAccount.get(agReg.Account__c), oscar.Id);
	            }
	        }
		}
    }

    public static AMS_OSCAR__c createStagingArea(AMS_Agency_Regulation__c agReg, Account accountData, List<AMS_Agency_Regulation__c> regulations){

        AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = AMS_Utils.RECTYPE_CERT, Account__c = agReg.Account__c, 
                                    Process__c = AMS_Utils.CERTIFICATION, Status__c='Accepted_Future Date', Change_effective_as_of__c = regulations[0].Expiry_Date__c);
        insert theOscar;

        Case theCommunicationCase = new Case();

        theCommunicationCase.RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM;
        theCommunicationCase.OSCAR__c = theOscar.Id;
        theCommunicationCase.AccountId = agReg.Account__c;
        theCommunicationCase.Account_Concerned__c = agReg.Account__c;
        theCommunicationCase.BSPCountry__c = accountData.BillingCountry;
        //TODO:theCommunicationCase.CaseArea__c = 
        //TODO:theCommunicationCase.ContactId
        //TODO:theCommunicationCase.Origin
        //TODO:theCommunicationCase.Reason1__c
        theCommunicationCase.Region__c = accountData.Region_formula__c;
        if(agReg.Type_Of_Certificate__c == AMS_Utils.CERT_TSA)
        	theCommunicationCase.Subject = 'TSA renewal - ' + accountData.Legal_name__c + ' - ' + accountData.IATACode__c;
        else
        	theCommunicationCase.Subject = 'DGR renewal - ' + accountData.Legal_name__c + ' - ' + accountData.IATACode__c;
        //TODO:theCommunicationCase.Type_of_customer__c = 

        insert theCommunicationCase;

        AMS_Pax_Accreditation_Form__c theStagingArea = new AMS_Pax_Accreditation_Form__c();

        theStagingArea.SAAM_Case__c                             = theCommunicationCase.Id;
        theStagingArea.Abbreviated_Address__c                   = accountData.Abbreviated_address__c;
        theStagingArea.Abbreviated_name__c                      = accountData.Abbreviated_name__c;
        theStagingArea.Accept_terms_and_conditions__c           = True;
        theStagingArea.Account_Name__c                          = accountData.Name;
        theStagingArea.Billing_State__c                         = accountData.BillingState;
        theStagingArea.Branch_Office_City__c                    = accountData.BillingCity;
        theStagingArea.Branch_Office_Country__c                 = accountData.IATA_ISO_Country__c;
        theStagingArea.Branch_Office_Email__c                   = accountData.Email__c;
        theStagingArea.Branch_Office_FAX__c                     = accountData.Fax;
        theStagingArea.Branch_Office_Phone__c                   = accountData.Phone;
        theStagingArea.Branch_Office_Postal_code__c             = accountData.BillingPostalCode;
        theStagingArea.Branch_Office_Street_name_number__c      = accountData.BillingStreet;
        theStagingArea.CASS_Number__c                           = accountData.CASS_Number__c;
        theStagingArea.IATACode__c                              = accountData.IATACode__c;
        theStagingArea.IATA_ISO_State__c                        = accountData.Iso_State__c;
        //TODO:theStagingArea.ISSP_AMS_GDS_with_signed_contract__c  = accountData.AMSAccreditationGDS;
        //TODO:theStagingArea.ISSP_AMS_Legal_Status__c              = {!AMSAccreditedLegalStatus};
        theStagingArea.ISSP_AMS_License_No__c                   = accountData.License_Number__c;
        //TODO:theStagingArea.ISSP_AMS_Premises_located_at_airport__c  = accountData.AreThePremissesInAirportFormula;
        theStagingArea.ISSP_AMS_VAT_number__c                   = accountData.VAT_Number__c;
        theStagingArea.Is_your_firm_handling_Dangerous_Goods__c = accountData.Is_your_firm_handling_Dangerous_Goods__c;
        theStagingArea.Location_Class__c                        = accountData.Location_Class__c;
        theStagingArea.Location_Type__c                         = accountData.Location_Type__c;
        theStagingArea.Mobile__c                                = accountData.Mobile__c;
        theStagingArea.Operation__c                             = accountData.Operation__c;
        //TODO:theStagingArea.RecordTypeId                          = 
        theStagingArea.Remittance_frequency__c                  = accountData.Remittance_frequency__c;
        theStagingArea.Shipping_City__c                         = accountData.ShippingCity;
        theStagingArea.Shipping_Country__c                      = accountData.ShippingCountry;
        theStagingArea.Shipping_Postal_Code__c                  = accountData.ShippingPostalCode;
        theStagingArea.Shipping_State__c                        = accountData.ShippingState;
        theStagingArea.Shipping_Street__c                       = accountData.ShippingStreet;
        theStagingArea.Short_Name__c                            = accountData.Short_Name__c;
        theStagingArea.Solicitation_Flag__c                     = accountData.Solicitation_Flag__c;
        theStagingArea.Submitted_to_IATA__c                     = True;
        theStagingArea.Trade_Name__c                            = accountData.TradeName__c;
        theStagingArea.VAT_Number_2__c                          = accountData.VAT_Number_2__c;
        theStagingArea.Website__c                               = accountData.Website;

        insert theStagingArea;

        theOscar.AMS_Online_Accreditation__c = theStagingArea.Id;
        update theOscar;

        convertExistingAgencyRegulationsToAccContact(theStagingArea.Id, regulations);

        return theOscar;
    }

    public static void convertExistingAgencyRegulationsToAccContact(Id stagingId, List<AMS_Agency_Regulation__c> regulations){

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

            accToInsert.add(ac);

        }

        if(!accToInsert.isEmpty())
            insert accToInsert;

    }


    private static Boolean isToCreateRenewalForDGR(Account accountData, Integer numberOfActiveDGR, Integer minimumHODgrRequirements, Integer minimumBRDgrRequirements){

        if(accountData.Is_your_firm_handling_Dangerous_Goods__c == 'Yes'){
            if(accountData.IATA_ISO_Country__r.Name.equalsIgnoreCase('People\'s Republic of China') && accountData.Location_Class__c == 'C' && numberOfActiveDGR <= 3){
                return true;
            }
            else if(accountData.Location_Class__c == 'C'){
                if(accountData.Location_Type__c == AMS_Utils.HO && numberOfActiveDGR <= 2 )
                    return true;
                else if(accountData.Location_Type__c == AMS_Utils.BR && numberOfActiveDGR  <= 1)
                    return true;
            }else if(accountData.Location_Class__c == 'R'){
                //Only America is using DGR for Cass associate.
                if(accountData.Location_Class__c == AMS_Utils.HO && numberOfActiveDGR <= minimumHODgrRequirements )
                    return true;
                else if(accountData.Location_Type__c == AMS_Utils.BR && numberOfActiveDGR <= minimumBRDgrRequirements){
                    return true;
                }
            }
        }
        return false;
    }
}
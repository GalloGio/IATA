public class IDCardApplicationFactory {

    public static map<Id, Account> theAccounts {get; set;}
    private RecordTypeSingleton RecordTypeSingleton {get; set;}

    /**

    Create an Id card for Contact using his country information
    */
    public static ID_Card_Application__c createIDCardApplication(Contact c , String appType) {
        if (c.ver_number_2__c == null) {
            throw new IDCardApplicationException('Impossible to create an Id card to a contact without VERNUM');
        }
        if (theAccounts == null)
            theAccounts = new map<Id, Account>();
        Account theAccount = theAccounts.get(c.AccountId);

        ID_Card_Application__c application ;
        if (theAccount == null) {
            theAccount = [select Id, ID_Card_Key_Account_Discount__c, IDCard_Key_Account__c, Type, ID_Card_Corporate_Validation_Date__c, BillingState, BillingCountry, IATACode__c  from Account where Id = :c.accountId];
            if (theAccount == null)
                theAccount = [select Id, ID_Card_Key_Account_Discount__c, IDCard_Key_Account__c, ID_Card_Corporate_Validation_Date__c, Type, BillingState, BillingCountry, IATACode__c  from Account where IATACode__C = :c.IATA_Code__C];
            system.debug('select Id, IDCard_Key_Account__c, Type, BillingState, BillingCountry, IATACode__c  from Account where IATACode__C = ' + c.IATA_Code__C + '  7  ' + c.accountId);
            theAccounts.put(theAccount.Id, theAccount);
        }
        if (theAccount.IDCard_Key_Account__c)
            application = new ID_Card_Application__c(RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation'));
        else
            application = new ID_Card_Application__c(RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Standard'));

        application.Type_of_application__c = appType;

        applyContactInformations(application, c);
        applyAccountInformations(application, theAccount);
        applyApplicationFees(application, theAccount, null);
        return application;
    }

    /**

    Create an Id card for Contact using an other Account information form  payment
    */
    public static ID_Card_Application__c createIdCardApplicationForSpecificAccount(Contact c , Account acc , String appType) {
        if (c.ver_number_2__c == null) {
            throw new IDCardApplicationException('Impossible to create an Id card to a contact without VERNUM');
        }
        ID_Card_Application__c application ;
        if (acc.IDCard_Key_Account__c)
            application = new ID_Card_Application__c(RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation'));
        else
            application = new ID_Card_Application__c(RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Standard'));
        application.Type_of_application__c = appType;

        applyContactInformations(application, c);
        application.IATA_Code__c = c.IATA_Code__c;
        applyApplicationFees(application, acc, null);
        return application;
    }

    /*

    Create an Id card for Contact using his country information
    */
    public static ID_Card_Application__c createMassIDCardApplication(Contact c , List<ID_Card_Application__c> apps) {
        if (c.ver_number_2__c == null) {
            throw new IDCardApplicationException('Impossible to create an Id card to a contact without VERNUM');
        }

        Map<String, Account> iatacodeToAccount = new Map<String, Account>();
        Set<String> alliatacodes = new Set<String>();
        for (ID_Card_Application__c app : apps)
            alliatacodes.add(app.IATA_code__c);


        for (Account a : [SELECT Id, ID_Card_Key_Account_Discount__c, IDCard_Key_Account__c, ID_Card_Corporate_Validation_Date__c, Type, BillingState, BillingCountry , IATACode__c, CurrencyIsoCode, IATA_ISO_Country__c
                          FROM Account
                          WHERE IATACode__c = :c.IATA_Code__c
                                              OR IATACode__c = :alliatacodes]) {

            iatacodeToAccount.put(a.IATAcode__c, a);
        }

        Account massAccount = iatacodeToAccount.get(c.IATA_Code__c);
        ID_Card_Application__c application = new ID_Card_Application__c(RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Mass_Order_Application'));
        application.Application_Status__c = '';
        applyContactInformations(application, c);
        applyAccountInformations(application, massAccount);

        application.Applicable_Fee__c = 0;
        application.ID_Card_Fee__c = 0;
        application.IDCard_Expedite_Delivery_Fee__c = 0;
        application.ITDI_Courses_Fee__c = 0;
        application.Tax_2_Value__c = '0';
        application.Tax_1_Value__c = '0';

        try {
            String accountType = IDCardUtil.GetAgentTypeFromAccountType(massAccount.type);
            IATA_ISO_Country__c contactCountry = IDCardUtil.GetIATAISOCountryOfContact(massAccount.IATACode__c);
            Price_Table__c[] listPriceTables = getPriceTables(accountType, contactCountry.Id);
            //Price_Table__c[] listPriceTables = getPriceTables(massAccount.Type, massAccount.IATA_ISO_Country__c);
            application.CurrencyIsoCode = listPriceTables[0].CurrencyIsoCode;
        } catch (Exception e) {
            application.CurrencyIsoCode = massAccount.CurrencyIsoCode;
        }

        system.debug(LoggingLevel.ERROR, '********* createMassIDCardApplication() - before sum mass has fees = ' + application.Applicable_Fee__c + ' - tax1 = ' + application.Tax_1_Value__c + ' - tax2 = ' + application.Tax_2_Value__c);




        for (ID_Card_Application__c subApp : apps) {
            system.debug(LoggingLevel.ERROR, '********* createMassIDCardApplication() - app fees (before applyapplicationfees) = ' + subApp.Applicable_Fee__c + ' - tax1 = ' + subApp.Tax_1_Value__c + ' - tax2 = ' + subApp.Tax_2_Value__c);

            //FIX FOR INCIDENT INC165366
            //applyApplicationFees(subApp, iatacodeToAccount.get(subApp.IATA_code__c), null);
            system.debug(LoggingLevel.ERROR, '********* createMassIDCardApplication() - app fees = ' + subApp.Applicable_Fee__c + ' - tax1 = ' + subApp.Tax_1_Value__c + ' - tax2 = ' + subApp.Tax_2_Value__c);


            if (subApp.Applicable_Fee__c != null) application.Applicable_Fee__c += subApp.Applicable_Fee__c ;
            if (subApp.ID_Card_Fee__c != null)application.ID_Card_Fee__c += subApp.ID_Card_Fee__c ;
            //if(subApp.IDCard_Expedite_Delivery_Fee__c!=null)application.IDCard_Expedite_Delivery_Fee__c += subApp.IDCard_Expedite_Delivery_Fee__c ;
            if (subApp.ITDI_Courses_Fee__c != null)application.ITDI_Courses_Fee__c += subApp.ITDI_Courses_Fee__c ;


            /*
            INCIDENT INC165366: mass' tax is no longer the sum of all the singles' tax
                                it's now calculated as the key account rate applied on the total amount
            if(subApp.Tax_2_Value__c!=null){
                String numeralPart = application.Tax_2_Value__c.split(' ',0)[0];
                String numeralPart2 = subApp.Tax_2_Value__c.split(' ',0)[0];
                application.Tax_2_Value__c = String.valueOf(Decimal.valueOf(Double.valueOf(numeralPart) + Double.valueOf(numeralPart2)).setScale(2)) ;
            }
            if(subApp.Tax_1_Value__c!=null){
                String numeralPart = application.Tax_1_Value__c.split(' ',0)[0];
                String numeralPart2 = subApp.Tax_1_Value__c.split(' ',0)[0];
                application.Tax_1_Value__c = String.valueOf(Decimal.valueOf(Double.valueOf(numeralPart) + Double.valueOf(numeralPart2)).setScale(2)) ;
            }
            */

            system.debug(LoggingLevel.ERROR, '********* createMassIDCardApplication() - after sum mass has fees = ' + application.Applicable_Fee__c + ' - tax1 = ' + application.Tax_1_Value__c + ' - tax2 = ' + application.Tax_2_Value__c);

            //Calculating taxes on the total amount

            Map<String, String> taxes =  IDCardTaxUtil.GetTaxes(massAccount.BillingState, massAccount.BillingCountry);

            if (taxes.keySet().Size() == 1) {
                List<String> taxPercentage =  taxes.values();
                List<String> taxName = new List<String>();
                taxName.addAll(taxes.keySet());
                application.Tax_1_Name__c = String.ValueOf(taxName[0]) + '(' + String.ValueOf(taxPercentage[0]) + '%)' ;
                application.Tax_1_Value__c = IDCardTaxUtil.CalculateTaxes(String.ValueOf(taxPercentage[0]), String.ValueOf(application.Applicable_Fee__c)) + ' ' + application.CurrencyIsoCode;

            } else if (taxes.keySet().Size() == 2) {
                List<String> taxPercentage =  taxes.values();
                List<String> taxName = new List<String>();
                taxName.addAll(taxes.keySet());
                application.Tax_1_Name__c = String.ValueOf(taxName[0]) + '(' + String.ValueOf(taxPercentage[0]) + '%)' ;
                application.Tax_2_Name__c = taxName[1] + '(' + String.ValueOf(taxPercentage[1]) + '%)' ;

                // If I have 2 taxes, I must consider both in the calculation
                // As first I retrieve the total amount of the taxes
                decimal totaltaxpercentage = decimal.valueOf(taxPercentage[0]) + decimal.valueOf(taxPercentage[1]);
                decimal totaltaxamount = decimal.valueOf(IDCardTaxUtil.CalculateTaxes(String.valueOf(totaltaxpercentage), String.ValueOf(application.Applicable_Fee__c)));
                system.debug(LoggingLevel.ERROR, '########### TAX1 percentage = ' + String.ValueOf(taxPercentage[0]) + '%');
                system.debug(LoggingLevel.ERROR, '########### TAX2 percentage = ' + String.ValueOf(taxPercentage[1]) + '%');
                system.debug(LoggingLevel.ERROR, '########### totaltaxpercentage = ' + totaltaxpercentage);
                system.debug(LoggingLevel.ERROR, '########### totaltaxamount = ' + totaltaxamount);
                // Now I split the total tax amount in the two separate ones
                decimal taxamount1 = totaltaxamount / totaltaxpercentage * decimal.valueOf(taxPercentage[0]);
                decimal taxamount2 = totaltaxamount / totaltaxpercentage * decimal.valueOf(taxPercentage[1]);
                system.debug(LoggingLevel.ERROR, '########### TAX1 amount = ' + taxamount1.setScale(2));
                system.debug(LoggingLevel.ERROR, '########### TAX2 amount = ' + taxamount2.setScale(2));
                application.Tax_1_Value__c = taxamount1.setScale(2) + ' ' + application.CurrencyIsoCode;
                application.Tax_2_Value__c = taxamount2.setScale(2) + ' ' + application.CurrencyIsoCode;
            }
        }




        return application;
    }

    public static ID_Card_Application__c applyAccountInformations(ID_Card_Application__c application, Account acc) {
        application.IATA_Code__c = acc.IATACode__c;
        application.Regional_Office__c = (IDCardUtil.GetIATAISOCountryOfContact(application.IATA_Code__c)).IATA_Regional_Office__c;
        return application;
    }

    public static ID_Card_Application__c applyContactInformations(ID_Card_Application__c application, Contact c) {
        application.IATA_Code__c = c.IATA_Code__c;
        application.Title__c = c.Salutation;
        application.Date_of_Birth__c = c.Date_of_Birth__c;
        application.Last_Name__c = IDCardUtil.deAccent(c.lastName);
        application.First_Name__c = IDCardUtil.deAccent(c.FirstName);
        application.Gender__c = c.Gender__c;
        application.VER_Number__c = c.VER_Number_2__c;
        application.Telephone__c = c.Phone;
        application.Middle_Initial__c = c.Middle_Initial__c;
        application.Displayed_Name__c = IDCardUtil.calculateDisplayedName(c.FirstName, c.Middle_Initial__c, c.LastName);
        application.Email_admin__c = String.isEmpty(c.IDcard_Email__c) ? c.Email : c.IDcard_Email__c;
        //application.Email_admin__c = c.Email;
        application.Position_in_Current_Agency__c = c.Position__c;
        application.Duties_in_Current_Agency__c = c.Duties__c;
        application.Hours_worked__c = c.Hours_per_week__c;
        application.UIR__c = c.UIR__c;
        //application.Position_Code__c = c.Position__c;
        if (c.Start_Date_Agency_Month__c != null && c.Start_Date_Agency_Month__c.isNumeric())
            application.Start_Date_Agency_Month__c = IDCardUtil.GetMonthStringValue(Integer.valueOf(c.Start_Date_Agency_Month__c));
        else
            application.Start_Date_Agency_Month__c = c.Start_Date_Agency_Month__c;
        if (c.Start_Date_Agency_Year__c != null)
            application.Start_Date_Agency_Year__c = String.valueOf(c.Start_Date_Agency_Year__c);
        else
            application.Start_Date_Agency_Year__c = Date.today().year() + '';

        if (c.Start_Date_Industry__c != null)
            application.Start_Date_Industry__c = String.valueOf(c.Start_Date_Industry__c);
        else
            application.Start_Date_Industry__c = Date.today().year() + '';
        return application;
    }



    /**  **/
    private static Map<String, Map<String, List<Price_Table__c>>> pricesTableMaps = null;

    /**

    */
    public static List<Price_Table__c> getPriceTables(String agentClass, String countryId) {
        if (pricesTableMaps == null) {
            pricesTableMaps = new Map<String, Map<String, List<Price_Table__c>>>();
            Price_Table__c[] listPriceTables = [Select p.Type_Class_of_Agent__c, p.Expedite__c, p.Name, p.Profit_Center__c, p.ISO_Country__r.Id, p.currencyIsoCode, p.ID_Card_Fee__c, p.IATA_Package__c From Price_Table__c p];
            for (Price_Table__c pt : listPriceTables) {
                if (pricesTableMaps.get(pt.Type_Class_of_Agent__c) == null) {
                    pricesTableMaps.put(pt.Type_Class_of_Agent__c, new Map<String, List<Price_Table__c>>());
                }
                if (pricesTableMaps.get(pt.Type_Class_of_Agent__c).get( pt.ISO_Country__r.Id) == null) {
                    pricesTableMaps.get(pt.Type_Class_of_Agent__c).put( pt.ISO_Country__r.Id, new List<Price_Table__c>());
                }
                pricesTableMaps.get(pt.Type_Class_of_Agent__c).get( pt.ISO_Country__r.Id).add(pt);
            }
        }
        return  pricesTableMaps.get(agentClass).get(countryId);
    }



    public static  ID_Card_Application__c applyApplicationFees(ID_Card_Application__c application, Account acc, Promotion__c validPromotion) {
        Map<String, decimal> detailledFees = new Map<String, decimal>();
        // Map the account agent type to the Price Table agent type
        String accountType = IDCardUtil.GetAgentTypeFromAccountType(acc.type);

        // get the Price Table based on the country and on the type of agent
        IATA_ISO_Country__c contactCountry = IDCardUtil.GetIATAISOCountryOfContact(application.IATA_Code__c);
        Price_Table__c[] listPriceTables = getPriceTables(accountType, contactCountry.Id); // [Select p.Type_Class_of_Agent__c, p.Expedite__c, p.Name From Price_Table__c p where p.Type_Class_of_Agent__c = :accountType and p.ISO_Country__r.Id = :contactCountry.Id];
        if (listPriceTables == null || listPriceTables.size() == 0) {
            throw new IDCardApplicationException(String.Format(Label.IDCard_No_Price_Table_Found, new String[] {'<i>' + contactCountry.ISO_Code__c + '</i>', '<i>' + accountType + '</i>'}));
        }
        if (listPriceTables[0].Profit_Center__c != null && listPriceTables[0].Profit_Center__c != '')
            application.Profit_Center__c  = listPriceTables[0].Profit_Center__c;
        else
            application.Profit_Center__c  = '';

        application.CurrencyIsoCode = listPriceTables[0].currencyIsoCode;
        //String orderNumber = 'ID'+contactCountry.ISO_Code__c + '-'+ application.Name.substring(5, idCardApplication.Name.length());


        //Get the ITDI Courses Selection
        String[]  selectedITDICourses = new List<String>();
        if (!String.isBlank(application.Package_of_Travel_Professionals_Course_1__c))
            selectedITDICourses.add(application.Package_of_Travel_Professionals_Course_1__c);
        if (!String.isBlank(application.Package_of_Travel_Professionals_Course_2__c))
            selectedITDICourses.add(application.Package_of_Travel_Professionals_Course_2__c);

        ////////////////////////////////
        // calculate the applicable fee

        Boolean isReissue = (application.Type_of_application__c == IDCardUtil.APPLICATIONTYPE_REISSUE);
        Boolean isExpedite = application.IDCard_Expedite_Delivery__c;
        /*
        If single app: expedite alway false. Will be set separated
        */
        if (application.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation'))
            isExpedite = false;
        Boolean isITDIPackage = selectedITDICourses.size() > 0;
        detailledFees = IDCardUtil.GetDetailledFees(listPriceTables[0], isReissue, isExpedite, isITDIPackage, validPromotion);
        application.Applicable_Fee__c = IDCardUtil.GetApplicableFee(listPriceTables[0], isReissue, isExpedite, isITDIPackage, validPromotion);
        application.ID_Card_Fee__c = detailledFees.get('IDCardFee');
        application.IDCard_Expedite_Delivery_Fee__c = detailledFees.get('ExpediteFee');
        application.ITDI_Courses_Fee__c = detailledFees.get('ITDIFee');

        ///////////////
        application.ID_Card_Fee__c = application.ID_Card_Fee__c * ((100 - (acc.ID_Card_Key_Account_Discount__c == null ? 0 : acc.ID_Card_Key_Account_Discount__c)) / 100);
        application.Applicable_Fee__c = application.ID_Card_Fee__c + application.IDCard_Expedite_Delivery_Fee__c + application.ITDI_Courses_Fee__c;
        ///////////////

        application.CurrencyIsoCode = listPriceTables[0].CurrencyIsoCode;
        Map<String, String> taxes =  IDCardTaxUtil.GetTaxes(acc.BillingState, acc.BillingCountry);

        if (taxes.keySet().Size() == 1) {
            List<String> taxPercentage =  taxes.values();
            List<String> taxName = new List<String>();
            taxName.addAll(taxes.keySet());
            application.Tax_1_Name__c = String.ValueOf(taxName[0]) + '(' + String.ValueOf(taxPercentage[0]) + '%)' ;
            application.Tax_1_Value__c = IDCardTaxUtil.CalculateTaxes(String.ValueOf(taxPercentage[0]), String.ValueOf(application.Applicable_Fee__c)) + ' ' + application.CurrencyIsoCode;

        } else if (taxes.keySet().Size() == 2) {
            List<String> taxPercentage =  taxes.values();
            List<String> taxName = new List<String>();
            taxName.addAll(taxes.keySet());
            application.Tax_1_Name__c = String.ValueOf(taxName[0]) + '(' + String.ValueOf(taxPercentage[0]) + '%)' ;
            application.Tax_2_Name__c = taxName[1] + '(' + String.ValueOf(taxPercentage[1]) + '%)' ;

            // If I have 2 taxes, I must consider both in the calculation
            // As first I retrieve the total amount of the taxes
            decimal totaltaxpercentage = decimal.valueOf(taxPercentage[0]) + decimal.valueOf(taxPercentage[1]);
            decimal totaltaxamount = decimal.valueOf(IDCardTaxUtil.CalculateTaxes(String.valueOf(totaltaxpercentage), String.ValueOf(application.Applicable_Fee__c)));
            // Now I split the total tax amount in the two separate ones
            decimal taxamount1 = totaltaxamount / totaltaxpercentage * decimal.valueOf(taxPercentage[0]);
            decimal taxamount2 = totaltaxamount / totaltaxpercentage * decimal.valueOf(taxPercentage[1]);
            application.Tax_1_Value__c = taxamount1.setScale(2) + ' ' + application.CurrencyIsoCode;
            application.Tax_2_Value__c = taxamount2.setScale(2) + ' ' + application.CurrencyIsoCode;
        }
        return application;
    }


    public static Contact createContactFromApplication(ID_Card_Application__c app, Account a) {
        Contact c = new Contact(
            FirstName = app.First_Name__c,
            LastName = app.Last_Name__c,
            Salutation = app.Title__c,
            Date_of_Birth__c = app.Date_of_Birth__c,
            Gender__c = app.Gender__c,
            Phone = app.Telephone__c,
            Middle_Initial__c = app.Middle_Initial__c,
            //Email = app.Email_admin__c,
            IDCard_Email__c = app.Email_admin__c,
            Position__c = app.Position_in_Current_Agency__c,
            Duties__c = app.Duties_in_Current_Agency__c,
            Hours_per_week__c = app.Hours_worked__c,
            Start_Date_Agency_Month__c = app.Start_Date_Agency_Month__c,
            Start_Date_Agency_Year__c = app.Start_Date_Agency_Year__c == null ? null : Decimal.valueOf(app.Start_Date_Agency_Year__c),
            Start_Date_Industry__c = app.Start_Date_Industry__c == null ? null : Decimal.valueOf(app.Start_Date_Industry__c),

            VER_Number_2__c = app.VER_Number__c,
            UIR__c = app.UIR__c,

            AccountId = a.id,
            RecordTypeId = IDCardUtil.IDCardContactRecordTypeID

        );

        return c;
    }
}
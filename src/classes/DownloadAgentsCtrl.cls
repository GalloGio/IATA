public with sharing class DownloadAgentsCtrl {

    public Date sixMonthsAgo = date.today().addMonths(-6);
    public string casesQuery {get; set;}
    public list<cContact> displayList {get; set;}
    private set<id> listAgentIdWithClosedCase {get; set;}
    private list<Id> AllContacts {get; set;}

    private String soql {get; set;}

    public String agentType             {get; set;}
    public String agentStatus           {get; set;}
    public String country               {get; set;}
    public String email                 {get; set;}
    public String yearend               {get; set;}
    public String targetFinancialYear   {get; set;}
    public String exclOpenCases         {get; set;}
    public String exclClosedCases       {get; set;}

    public DownloadAgentsCtrl () {

        agentType = Apexpages.currentPage().getParameters().get('agenttype');
        agentStatus = Apexpages.currentPage().getParameters().get('agentstatus');
        //country = Apexpages.currentPage().getParameters().get('country');
        country = Apexpages.currentPage().getParameters().get('ISOcountry');
        email = Apexpages.currentPage().getParameters().get('email');
        yearend = Apexpages.currentPage().getParameters().get('yearend');  //phase 1 release 2
        targetFinancialYear = Apexpages.currentPage().getParameters().get('targetFinancialYear');  // phase 4
        exclOpenCases = Apexpages.currentPage().getParameters().get('exclOpenCases');  // phase 4
        exclClosedCases = Apexpages.currentPage().getParameters().get('exclClosedCases');  // phase 4

        runSearch();

    }


    // runs the search with parameters passed via Javascript
    public void runSearch() {
        system.debug('%%%%%%%%%%%% [runSearch] country : ' + country);
        soql = 'select Account.name, Account.IATACode__c, Account.Status__c, Account.Type, Account.BillingCountry, Account.Location_Type__c, account.CCG_Participant__c , account.CCG_IRR_Distribution_list__c, Account.Number_of_open_Financial_Review_Cases__c, FirstName, LastName, Email, Account.Region__c, ID, Financial_Assessment_Contact__c, Name from contact where account.name != null and Account.IATACode__c != null and Financial_Assessment_Contact__c = true';
        if (!country.equals('')) {
            //soql += ' and Account.BillingCountry LIKE \''+String.escapeSingleQuotes(country)+'%\'';
            //soql += ' and Account.BillingCountry = \''+String.escapeSingleQuotes(country).trim()+'\'';
            soql += ' and Account.IATA_ISO_Country__c = \'' + country + '\'';

            if (!agentType.equals('') ) {

                string[] aType = String.escapeSingleQuotes(agentType).split('-', 12);
                String b = '';

                if (aType.size() > 1)
                    b = '(';

                soql += ' and' + b + ' Account.Type LIKE \'' + aType[0] + '%\'';

                for (integer i = 1 ; i < aType.size(); i++) {
                    if (!aType[i].equals(''))
                        soql += ' or Account.Type LIKE \'' + aType[i] + '%\'';

                    if (i == aType.size() - 1)
                        soql += ')';
                }

            }
            if (!agentStatus.equals('')) {
                string[] words = String.escapeSingleQuotes(agentStatus).split('-', 12);
                String b = '';

                if (words.size() > 1)
                    b = '(';

                soql += ' and' + b + ' Account.Status__c LIKE \'' + words[0] + '%\'';

                for (integer i = 1 ; i < words.size(); i++) {
                    if (!words[i].equals(''))
                        soql += ' or Account.Status__c LIKE \'' + words[i] + '%\'';

                    if (i == words.size() - 1)
                        soql += ')';
                }
            }
            if (email.equals('1')) {
                soql += ' and Email != null';
                
            } else if (email.equals('2')) {
                soql += ' and Email = null';
            }

            //if (!yearend.equals('') && !yearend.equals('--All--'))   //phase 1 release 2
            //    soql += ' and Account.Financial_Year_End__c LIKE \''+String.escapeSingleQuotes(yearend)+'%\'';
            if (yearend != '' && yearend.equals('--All--'))
                soql += ' and Account.Fin_statements_submission_deadline__c != \'\'';
            else if (yearend != '')
                soql += ' and Account.Fin_statements_submission_deadline__c LIKE \'' + String.escapeSingleQuotes(yearend) + '%\'';

            // Location Type AO/HO/BR filter
            soql += ' and (Account.Location_Type__c LIKE \'AO%\' OR Account.Location_Type__c LIKE \'HO%\' OR Account.Location_Type__c LIKE \'BR%\' OR Account.Location_Type__c LIKE \'HE%\' OR Account.Location_Type__c LIKE \'AE%\')';

            // exclude opened cases
            if (exclOpenCases.equals('true'))
                soql += ' and Account.Has_Financial_Review_Open_Cases__c = false';
            else if (exclOpenCases.equals('false'))
                soql += ' and (Account.Has_Financial_Review_Open_Cases__c = true or Account.Has_Financial_Review_Open_Cases__c = false)';

            soql += ' and (((Account.Reinstated_Date__c = null or Account.Reinstated_Date__c < :sixMonthsAgo) and Account.Category__c = \'IATA Passenger Sales Agent\') or Account.Category__c != \'IATA Passenger Sales Agent\') ';


            // run the query again
            runQuery();

        }

    }

    public void runQuery() {

        AllContacts = new List<Id>();
        displayList = new List<cContact>();




        // test
        searchAgentsWithClosedCase();

        system.debug('query for donwload here: ' + soql);

        for (Contact cont : Database.query(soql)) {

            Boolean hasClosedCases = agentHasClosedCases(cont.AccountId);
            if (exclClosedCases.equals('false') || (exclClosedCases.equals('true') && !hasClosedCases)) {
                displayList.add(new cContact(cont, hasClosedCases));

            }
        }

    }



    private void searchAgentsWithClosedCase() {

        listAgentIdWithClosedCase = new Set<Id>();

        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');

        // search for agents that have closed cases for the same financial year
        String soql = 'select c.Contact.Account.Id, c.Contact.Account.Name from Case c where c.RecordTypeId=\'' + IFAPcaseRecordTypeID + '\' and c.Status = \'Closed\' and c.IFAP_Financial_Year__c = \'' + targetFinancialYear + '\' and c.Contact.Account.name != null and c.Contact.Account.IATACode__c != null and c.Contact.Financial_Assessment_Contact__c = true';

        if (!country.equals('')) {
            //soql += ' and c.Contact.Account.BillingCountry = \'' + String.escapeSingleQuotes(country).trim() + '\'';
            soql += ' and Account.IATA_ISO_Country__c = \'' + country + '\'';

        }

        if (!agentType.equals('') ) {

            string[] aType = String.escapeSingleQuotes(agentType).split('-', 12);
            String b = '';

            if (aType.size() > 1)
                b = '(';

            soql += ' and' + b + ' c.Contact.Account.Type LIKE \'' + aType[0] + '%\'';

            for (integer i = 1 ; i < aType.size(); i++) {
                if (!aType[i].equals(''))
                    soql += ' or c.Contact.Account.Type LIKE \'' + aType[i] + '%\'';

                if (i == aType.size() - 1)
                    soql += ')';
            }
        }

        if (!agentStatus.equals('')) {
            string[] words = String.escapeSingleQuotes(agentStatus).split('-', 12);
            String b = '';

            if (words.size() > 1)
                b = '(';

            soql += ' and' + b + ' c.Contact.Account.Status__c LIKE \'' + words[0] + '%\'';

            for (integer i = 1 ; i < words.size(); i++) {
                if (!words[i].equals(''))
                    soql += ' or c.Contact.Account.Status__c LIKE \'' + words[i] + '%\'';

                if (i == words.size() - 1)
                    soql += ')';
            }
        }
        if (email.equals('1'))
            soql += ' and c.Contact.Email != null';
        else if (email.equals('2'))
            soql += ' and c.Contact.Email = null';

        if (yearend != '' && yearend.equals('--All--'))
            soql += ' and c.Contact.Account.Fin_statements_submission_deadline__c != \'\'';
        else if (yearend != '')
            soql += ' and c.Contact.Account.Fin_statements_submission_deadline__c LIKE \'' + String.escapeSingleQuotes(yearend) + '%\'';
    
        // Location Type HO/ AO filter     
        soql += ' and (c.Contact.Account.Location_Type__c LIKE \'AO%\' OR c.Contact.Account.Location_Type__c LIKE \'HO%\' OR c.Contact.Account.Location_Type__c LIKE \'BR%\' OR c.Contact.Account.Location_Type__c LIKE \'HE%\'  OR c.Contact.Account.Location_Type__c LIKE \'AE%\')';
        casesQuery = soql;

        for (Case c : Database.query(soql)) { listAgentIdWithClosedCase.add(c.Contact.Account.Id);}
    }

    public Boolean agentHasClosedCases(Id agentId) {
        return listAgentIdWithClosedCase != null && listAgentIdWithClosedCase.contains(agentId);
    }

}

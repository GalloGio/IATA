public with sharing class CaseDueDiligence {

    public class DueDiligenceException extends Exception {}

    private static final Id RT_ICCS_ASP_ID = Schema.SObjectType.Case.RecordTypeInfosByDeveloperName.get('IDFS_Airline_Participation_Process').getRecordTypeId();
    private static final Id RT_CODING_ID = Schema.SObjectType.Case.RecordTypeInfosByDeveloperName.get('Airline_Coding_Application').getRecordTypeId();
    private static final set<String> REASONS_FOR_BSP_CASS = new set<String>{
        'BSP Direct - Member',
        'BSP Direct - Non-Member',
        'CASS Direct - Member',
        'CASS Direct - Non-Member',
        'CASS Export via GSSA - Member',
        'CASS Export via GSSA - Non-Member',
        'CASS Import Direct - Member',
        'CASS Import Direct - Non-Member'
    };
    private static final set<String> REASONS_FOR_CODING = new set<String>{
        'Designator Form',
        '3 Digit Form'
    };
    private static final DateTime TEN_MONTHS_AGO = Date.today().addMonths(-10);
    private static final set<String> LIST_IGNORED_STATUSES = new set<String>{'Closed_Rejected','Closed_Withdrawn','Closed - Dispute','Closed_ Not Accepted','Closed_Disapproved','Archived'};

    /**
        Checks if input id belongs to a Recycle group
        uses a static variable to avoid unnecessary calls to group object
    **/
    private static set<Id> LIST_RECYCLE_GROUPS;
    public static Boolean isRecycleGroup(Id userOrGroupId) {
        if (userOrGroupId.getSObjectType() == Schema.Group.SObjectType) {
            if (LIST_RECYCLE_GROUPS==null) {
                LIST_RECYCLE_GROUPS = new map<Id,Group>([SELECT Id FROM Group WHERE Name LIKE 'Recycle Bin%']).keyset();
            }
            return LIST_RECYCLE_GROUPS.contains(userOrGroupId);
        }
        return false;
    }

    /**
        Validates the Due diligence on case trigger before update when a case is closing
        If the validation fails it will prevent its closing
    **/
    public static void beforeUpdate(map<Id,Case> mapNews, map<Id,Case> mapOlds) {
        // Check Due dilligence for joining cases being closed
        list<Case> listClosedCasesToCheck = new list<Case>();
        list<Id> listAccountId = new list<Id>();
        for (Case newCase: mapNews.values()) {
            Case oldCase = mapOlds.get(newCase.Id);
            //if case belongs to Airline Joining (2 RTs) and it is being closed now...
            if ((newCase.RecordTypeId == RT_ICCS_ASP_ID || newCase.RecordTypeId == RT_CODING_ID)
                    && newCase.Status.containsIgnoreCase('closed')
                    && !oldCase.Status.containsIgnoreCase('closed')
                    && !LIST_IGNORED_STATUSES.contains(newCase.Status)
                    && !isRecycleGroup(newCase.OwnerId)
                    ) {
                listClosedCasesToCheck.add(newCase);
                listAccountId.add(newCase.AccountId);
            }
        }
        //validate clearance level for found accounts
        if (!listAccountId.isEmpty()) {
            map<Id,Account> mapAccount = new map<Id,Account>(
                [SELECT Id, Date_of_last_clearance__c, Clearance_level__c
                FROM Account
                WHERE Id IN :listAccountId]);
            
            for (Case newCase: mapNews.values()) {
                Account account = mapAccount.get(newCase.AccountId);
                try {
                    validate(newCase,account);
                } catch(Exception e) {
                    newCase.addError(e.getMessage());
                }
            }
        }
    }

    /**
        Returns tru if the case has a valid due diligence
    **/
    public static Boolean isValid(Case cse, Account account) {
        try {
            validate(cse,account);
            return true;
        } catch(DueDiligenceException e) {
            return false;
        }
    }

    /**
        Checks if input case (only for joining cases) has a valid due diligence
    **/
    public static void validate(Case cse, Account account) {
        if (cse.RecordtypeId == RT_ICCS_ASP_ID
            && cse.CaseArea__c ==  'Airline Joining') {
            //SIS TOU
            if (cse.Reason1__c == 'SIS Client' && cse.Type == 'TOU') {
                checkDueDiligence(account,1);
            }
            //SIS ISPA
            if (cse.Reason1__c == 'SIS Client' && cse.Type == 'ISPA') {
                checkDueDiligence(account,2);
            }
            //SIS ISUA
            if (cse.Reason1__c == 'SIS Client' && cse.Type == 'ISUA') {
                checkDueDiligence(account,2);
            }
            //MITA
            if (cse.Reason1__c == 'MITA') {
                checkDueDiligence(account,2);
            }
            //BSP/CASS Joining
            if (REASONS_FOR_BSP_CASS.contains(cse.Reason1__c)) {
                checkDueDiligence(account,3);
            }
            //NOA   (TBD)
        }
        //ICH
        if (cse.RecordtypeId == RT_ICCS_ASP_ID
            && cse.CaseArea__c ==  'ICH'
            && cse.Type == 'ICH Membership') {
            checkDueDiligence(account,4);
        }
        //Coding
        if (cse.RecordtypeId == RT_CODING_ID
            && cse.CaseArea__c ==  'Airline Coding Application'
            && REASONS_FOR_CODING.contains(cse.Reason1__c)) {
            checkDueDiligence(account,2);
        }
    }

    /**
        Get the account clearance level as a number
    **/
    private static Integer getClearanceLevel(Account account) {
        try {
            return Integer.ValueOf(account.Clearance_level__c);
        } catch (Exception e) {
            return 0;
        }
    }

    /**
        checks if input account has a valid Clearance level, throws an error with
        the right message for the user
    **/
    private static void checkDueDiligence(Account account, Integer minimumValidLevel) {
        // check first the date of last clearance, must be more than 10 months ago
        if (account.Date_of_last_clearance__c <= TEN_MONTHS_AGO) {
            throw new DueDiligenceException('Last clearance date is approaching the 12 months deadline. Please create an internal case for Corporate Compliance Team.');
        }
        Integer currentLevel = getClearanceLevel(account);
        // Specific message qhen clearance level is empty (or zero)
        if (minimumValidLevel > 0 && currentLevel == 0) {
            throw new DueDiligenceException('This account is missing Due Dilligence Clearance. Please create an internal case for Corporate Compliance Team.');
        }
        // message when the account has a clearance level but not enough
        if (currentLevel < minimumValidLevel) {
            throw new DueDiligenceException('The required Due Dilligence Clearance for this joining is ' + minimumValidLevel + ' and the related account holds a Cleareance of Level ' + currentLevel);
        }
    }
}
//v2

//ORIGINAL

global class AMS_CheckOwnershipAlignmentBatch implements Database.Batchable<sObject>, Database.Stateful {

    public final Integer GOVERNORLIMIT = 10000;
	public final Integer VOUCHERSPERPDF = 1000;
	String query;
    String qRegion;
    String emailAddress;
    List<AMS_Account_Role__c> roles;
    Map<string,List<AMS_Account_Role__c>> auxmapRole;
    List<AMS_Account_Role__c> auxownerlist;
    String topParentIATAcode;
    Map<string,Map<string,list<AMS_Account_Role__c>>> ownerbyaccByHO;

	//List<String> parentIataCodes;

	global List<String> iataCodesinError;


    global AMS_CheckOwnershipAlignmentBatch(String qReg, String emailToSend) {
        qRegion = qReg;
        emailAddress = emailToSend;
        roles = new List<AMS_Account_Role__c>();
        auxmapRole = new Map<string,List<AMS_Account_Role__c>>();
        auxownerlist = new List<AMS_Account_Role__c>();

		//parentIataCodes = new List<String>();
		iataCodesinError = new List<String>();



		query = 'select id from account where status__c <> \'terminated\''+ (qReg != 'All Countries'? ' and region_formula__c = \'' + qReg + '\'' : '') + ' and status__c <> \'Not accreditated\''+
            ' and recordtype.developername = \'IATA_Agency\' and (Location_Type__c = \'HO\' or Location_Type__c = \'AO\') ';
			System.debug('## query'+query);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

    global void execute(Database.BatchableContext BC, List<Account> scope) {

        System.debug('result:' + scope);
		ownerbyaccByHO = new map<string,map<string,list<AMS_Account_Role__c>>>();

		//query = ' (select id from account where status__c <> \'terminated\' and region_formula__c = \'' + qReg + '\' and status__c <> \'Not accreditated\' and recordtypeid = \'012w0000000QBMW\'  ) ' ;

        String accs = 'Select id from account where Top_Parent__c in :scope';
        List<Account> childsOwners = Database.Query(accs);
        childsOwners.addAll(scope);

        String childParentQuery = 'SELECT Id, RecordType.Name, Account__c, account__r.iatacode__c, account__r.top_parent__r.iatacode__c, Contact__c,'+
            ' Contact__r.Email, Owner_Account__c, Percentage__c, Person__c, Person__r.Contact__c, Person__r.Contact__r.Email , Owner_Name__c, Legacy_System__c, '+
            'Legacy_External_ID__c FROM AMS_Account_Role__c where Active__c = true and Termination_Date__c = null and RecordType.DeveloperName = \'Ownership\' '+
            'and Account__c in :childsOwners ';



		List<AMS_Account_Role__c> owners=  Database.Query(childParentQuery);
		for (AMS_Account_Role__c owner: owners){

            //top parent will be the iata code in case of an HO
            if (owner.account__r.iatacode__c != null){
                topParentIATAcode = owner.account__r.top_parent__r.iatacode__c != null  ? owner.account__r.top_parent__r.iatacode__c : owner.account__r.iatacode__c;
            }

            //HO exists
            if (ownerbyaccByHO.Keyset().contains(topParentIATAcode)){

                //HO exists and BR exists
                if (ownerbyaccByHO.get(topParentIATAcode).keyset().contains(owner.account__r.iatacode__c)){

                    ownerbyaccByHO.get(topParentIATAcode).get(owner.account__r.iatacode__c).add(owner);

                 // HO exists and BR don't exist - will have to create auxiliar list and put it in the top map
                }else{

                    auxownerlist = new list<AMS_Account_Role__c>();
                    auxownerlist.add(owner);
                    ownerbyaccByHO.get(topParentIATAcode).put(owner.account__r.iatacode__c,auxownerlist);
                }

            // Ho does NOT exist - we'll create an aux list map, put the list in the map and put the map in teh top map
            }else{
                System.debug('inserting in big map: ' + topParentIATAcode);
                auxmapRole = new Map<string,List<AMS_Account_Role__c>>();
                auxownerlist = new List<AMS_Account_Role__c>();
                auxownerlist.add(owner);
                auxmapRole.put(owner.account__r.iatacode__c,  auxownerlist);

                ownerbyaccByHO.put(topParentIATAcode, auxmapRole);
            }

        }
        System.debug('## ownerbyaccByHO: '+ ownerbyaccByHO);
        for (string key: ownerbyaccByHO.keyset()){
            if(ownerbyaccByHO.get(key).keyset().size() > 1){ //HO has chield. Must compare. Otherwise skip
                if (!compareRolesInAccounts(ownerbyaccByHO.get(key))){
                    System.debug('## HO has corrupt owners - iata code: '+key);
                    iataCodesinError.add(key);
                }else{
                    System.debug('## No errors: '+key);
                }
            }

        }
	}

    global void finish(Database.BatchableContext BC) {

        sendMail(iataCodesinError, qRegion, emailAddress);
    }



    private static boolean compareRolesInAccounts(Map<String, List<AMS_Account_Role__c>> accountsWithRoles) {

        System.debug('## comparing roles in accounts');
        Set<String> accountIds = accountsWithRoles.keySet();

        // for each Account we should compare it against all the others.
        for (String account : accountIds) {
            System.Debug('Role to iterate: ' + account);
            system.Debug('accounts with roles: ' + accountsWithRoles);
            List<AMS_Account_Role__c> roles = accountsWithRoles.get(account);
            system.Debug('roles: ' + roles);
            if (roles == null)
                return false;


            // so we do not compare against itself
            accountsWithRoles.remove(account);

            if (!deepCompareRolesInAccounts(roles, accountsWithRoles))
                return false;

            break;
        }

        return true;
    }

    private static boolean deepCompareRolesInAccounts(List<AMS_Account_Role__c> roles, Map<String, List<AMS_Account_Role__c>> accountsWithRoles) {

        System.debug('#comparing roles in hierarchies...');

        Set<String> accountIds = accountsWithRoles.keySet();
        System.debug('List of accounts: ' + accountsWithRoles);
        // for each Account we should compare it against all the others.
        for (String account : accountIds) {

            List<AMS_Account_Role__c> rolesToCompare = accountsWithRoles.get(account);
                    System.Debug('roles to compare: ' + rolesToCompare);

            if (rolesToCompare == null || !compareRolesList(roles, rolesToCompare))
                return false;

        }

        return true;

    }

    private static boolean compareRolesList(List<AMS_Account_Role__c> leftList, List<AMS_Account_Role__c> rightList) {

        // they have to have the same numbers of owners, otherwise we don't even have to compare it...
        System.Debug('Same number, continuing..');

        if (leftList.size() != rightList.size()) {
            System.debug('List of owners have diff sizes, returning false.');
            return false;
        }

        for (AMS_Account_Role__c role : leftList) {

            AMS_Account_Role__c elemFound = fetchRoleInList(role, rightList);

            if (elemFound == null) {
                System.debug('Did not find any role, returning false.');
                return false;
            }

            Set<AMS_Account_Role__c> tempSetRole = new Set<AMS_Account_Role__c>(rightList);

            tempSetRole.remove(elemFound);

            rightList = new List<AMS_Account_Role__c>(tempSetRole);

        }

        return true;

    }


    public static AMS_Account_Role__c fetchRoleInList(AMS_Account_Role__c roleToFind, List<AMS_Account_Role__c> listToFind) {

        for (AMS_Account_Role__c role : listToFind) {

            if (compareRoles(roleToFind, role)) {
                return role;
            }

        }

        System.debug('Comparison did not return any role, returning false.');
        return null;
    }

    public static boolean compareRoles(AMS_Account_Role__c roleOriginal, AMS_Account_Role__c roleList) {

        System.debug('Preparing to compare the following roles: ' + roleOriginal + ' and ' + roleList);

        if (roleOriginal.Contact__c != null && roleOriginal.Contact__c == roleList.Contact__c) {
            return true;
        }

        if (roleOriginal.Person__c != null && roleOriginal.Person__c == roleList.Person__c) {
            return true;
        }

        if (roleOriginal.Owner_Account__c != null && roleOriginal.Owner_Account__c == roleList.Owner_Account__c) {
            return true;
        }

        if (roleOriginal.Legacy_External_ID__c != null && roleOriginal.Owner_Name__c != null && roleOriginal.Owner_Name__c == roleList.Owner_Name__c  ) {
            return true;
        }

        System.debug('Could not find any kind of match between the 2 roles, returning false.');

        return false;

    }

    public static void sendMail(List<String> iataCodesinError, String qRegion, String emailAddress){

        string header = 'IATA Code\n';
        string finalstr = header;

        for(String s: iataCodesinError){
            string recordString = '"'+s +'"\n';
            finalstr = finalstr +recordString;
        }

        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(finalstr);
        string csvname= 'HOs not aligned'+qRegion+'.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {emailAddress};
        String subject ='HO\'s IATA Codes with non-aligned ownership through the hierarchy for '+qRegion;
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('Account CSV ');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});

    }

}

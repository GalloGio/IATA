public  class AccountTriggerHelper {

  private static boolean SectorCatToIndType = false;

  public static void SectorCatToIndType(list<Account> triggerNew, map<Id, Account> triggerOldMap) {

    // static variale to control this being called once
    //cat and subcat null? if null check industry and type and copy them back
    // or  the values were changed on industry and type we copy them  back to category and subcategory
    //if(!SectorCatToIndType )
    for (Account a : triggerNew) {

      if ( ((a.Sector__c == null || a.Category__c == null)
           ||
           trigger.isUpdate &&
           ( a.industry <> triggeroldMap.get(a.id).industry || a.Type <> triggeroldMap.get(a.id).Type)) && a.Type_of__c != 'S'
         ) {
        a.Sector__c =  (a.Sector__c == null) || trigger.isUpdate && ( a.industry <> triggeroldMap.get(a.id).industry) ? a.Industry : a.Sector__c;
        a.Category__c =  (a.Category__c == null) || trigger.isUpdate && ( a.Type <> triggeroldMap.get(a.id).Type ) ? a.Type : a.Category__c ;
      }
      // copy to industry and type anyways

      a.Industry = a.Sector__c ;
      a.Type = a.Category__c ;

    }
    // SectorCatToIndType = true;
  }



  public static void AccountNoDuplicateBranch (list<Account> triggerNew, map<Id, Account> triggerOldMap) {


    ID standardRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
    map<Integer, Account> TriggerNewAcctsMap = new map<Integer, Account>();

    Integer i = 0;
    for (account a : triggernew) {
      if ((a.recordtypeID == standardRT && a.Industry <> null && a.Industry == 'Airline')
          || (a.recordtypeID == standardRT && trigger.isUpdate && a.Industry == 'Airline' && a.Industry <> triggeroldMap.get(a.id).Industry )) {

        TriggerNewAcctsMap.put(i, a);
        i++;
      }
    }

    if (!TriggerNewAcctsMap.isEmpty())
      AcctNoDupe.PerformSearch(TriggerNewAcctsMap, null);

  }


  /**
    * Trigger that copies the country from the ISO Country lookup field to the Billing Country field, to ensure standard
    * country names are used
    *
    * 04/10/2013 REVIEWD and Added functionality: as for AIMS Accounts we need to fill the BillingCountry whith the matching Iso lookUp IATA_ISO_Country__c.name
    *
    */
  public static void CopyCountry (list<Account> TriggerNewList, map<Id, Account> triggeroldmap ) {




    list<Account> triggerNew = new list<Account>();

    for (Account a : TriggerNewList) {

      if (
        (trigger.isInsert  ||
         (a.IATA_ISO_Country__c <> NULL &&
          !a.Is_AIMS_Account__c && trigger.isUpdate &&
          a.IATA_ISO_Country__c <> triggeroldmap.get(a.id).IATA_ISO_Country__c) // we check if it needs to fire
         ||
         (a.BillingCountry  <> NULL &&
          a.Is_AIMS_Account__c
          && trigger.isUpdate
          && (a.BillingCountry <> triggeroldmap.get(a.id).BillingCountry
              || a.recordtypeid <>triggeroldmap.get(a.id).recordtypeid)
         )
        )
      ) {

        triggerNew.add(a);
      }

    }

    if (!triggerNew.isEmpty()) {



      set<String> developerNames = new set<String> {'IATA_Agency' , 'IATA_Airline_BR', 'IATA_Airline', 'IATA_GSA', 'IATA', 'Others', 'Standard_Account'};
      map<Id, String> developerNamePerRecordTypeIds = new map<Id, String>();
      set<id> recordTypeIds = new set<id>();
      map<integer, Account> AccountPerInteger = new map<integer, Account>();
      map<ID, list<Integer>> IsoIDPerAccount = new map<ID, list<Integer>>();
      set<Id> IataIDs = new set<Id>();
      set<string> billingNames = new set<String>();
      map<string, list<Integer>> AccIDsPerCountryName = new map<string, list<Integer>>();



      for (String rtName : developerNames) {
        ID rT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', rtName);
        developerNamePerRecordTypeIds.put(rT, rTname);
        recordTypeIds.add(rT);
      }

      integer i = 0;
      for (Account a : triggerNew) {
        if (      a.IATA_ISO_Country__c <> NULL &&
                  developerNamePerRecordTypeIds.get(a.RecordTypeId) <> 'IATA_Agency'  &&
                  recordTypeIds.contains(a.RecordTypeId) &&
                  !a.Is_AIMS_Account__c &&
                  a.IATA_ISO_Country__c <> null
                  &&
                  (trigger.isInsert  ||
                   (trigger.isUpdate && a.IATA_ISO_Country__c <> triggeroldmap.get(a.id).IATA_ISO_Country__c) // we check if it needs to fire
                  )
           ) {

          if (IsoIDPerAccount.get(a.IATA_ISO_Country__c) == null){
            IsoIDPerAccount.put(a.IATA_ISO_Country__c, new list<Integer>());
          }
          IsoIDPerAccount.get(a.IATA_ISO_Country__c).add(i);
          IataIDs.add(a.IATA_ISO_Country__c);
          AccountPerInteger.put(i, a);
          i++;


        } else if (a.BillingCountry  <> NULL &&
                    recordTypeIds.contains(a.RecordTypeId) &&
                    a.BillingCountry <> null &&
                    a.Is_AIMS_Account__c &&
                    (trigger.isInsert
                     ||
                     (trigger.isUpdate// we check if it needs to fire
                      && (a.BillingCountry <> triggeroldmap.get(a.id).BillingCountry
                          || a.recordtypeid <>triggeroldmap.get(a.id).recordtypeid )
                     )
                    )
                   ) { // AIMS LOGIC THAT IS THE OPPOSITE
          //  throw new transformationException('a.BillingCountry  ' + a.BillingCountry);
          if (AccIDsPerCountryName.get(a.BillingCountry) == null)
            AccIDsPerCountryName.put(a.BillingCountry, new list<Integer>());
          AccIDsPerCountryName.get(a.BillingCountry).add(i);
          billingNames.add(a.BillingCountry);
          AccountPerInteger.put(i, a);
          i++;

        }
      }



      if (!AccountPerInteger.isEmpty() ) {

        list<IATA_ISO_Country__c> isoCountriesByID = IATAIsoCountryDAO.getIsoCountriesByIds(IataIDs);
        list<IATA_ISO_Country__c> isoCountriesByAIMSAreaName = IATAIsoCountryDAO.getIsoCountriesByAIMSAreaName(billingNames);

        Set<IATA_ISO_Country__c> isoCountries = new Set<IATA_ISO_Country__c>(isoCountriesByID);
        isoCountries.addAll(isoCountriesByAIMSAreaName); 

        Map<Id, String> mapISOCountriesNamePerId = new   Map<Id, String>();
        Map<String, Id> IdPerMapISOCountriesName = new   Map<String, Id>();

        for (IATA_ISO_Country__c iataISo : isoCountries) {
          mapISOCountriesNamePerId.put(iataISo.Id, iataISo.Name);
          if (iataISo.AIMS_Area_Name__c <> null) {
            IdPerMapISOCountriesName.put(iataISo.AIMS_Area_Name__c.trim().tolowerCase(), iataISo.Id);
          }
        }

        for (Id idIso : IsoIDPerAccount.keySet()) {
          for (integer j : IsoIDPerAccount.get(idIso)) {
            AccountPerInteger.get(j).BillingCountry = mapISOCountriesNamePerId.get(idIso);

          }
        }


        for (String cName : AccIDsPerCountryName.keySet()) { // aims logic
          for (integer j : AccIDsPerCountryName.get(cName)) {
            //   throw new transformationException('PEOPLES REPUBLIC OF CHINA  ' + cName  +'      '+  IdPerMapISOCountriesName.get(cName.trim().tolowerCase()));
            if (IdPerMapISOCountriesName.get(cName.trim().tolowerCase())<> null)
              AccountPerInteger.get(j).IATA_ISO_Country__c = IdPerMapISOCountriesName.get(cName.trim().tolowerCase()); // to do trim and to lower and errors????????

          }
        }
      }

    }


  }



  public static void copyInfoFromHqToBranchOnInsertAndUpdate(list<Account> triggerNew, map<Id, Account> triggerOldMap) {


    //  throw new transformationException('' +triggerNew);

    set<string> fieldsToCheck = new set<String> {
      'Type',
      'Area_of_Operation__c',
      'Type_of_Service__c',
      'BSP_CI_Valid__c',
      'BSP_FOC_Valid__c',
      'CASS_CI_Valid__c',
      'CASS_FOC_Valid__c',
      'Airline_designator__c',
      'IATACode__c',
      'TradeName__c',
      'ACLI_Status__c'
    };

    ID hqRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
    ID brRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR');
    ID StandardRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

    map<Id, list<Account>> branchesPerParentIDs = new map<Id, list<Account>>();
    //      throw new transformationException('' +triggerisInsert  );
    for (Account a : triggernew) {
      for (String field : fieldsToCheck) {
        if ( // this first part is regarding the real branches

          a.parentId <> null &&

          (a.RecordTypeId == brRT  || ( a.RecordTypeId == StandardRT && a.industry == 'Airline' )) &&
          //    a.ParentId <> triggeroldmap.get(a.id).ParentId &&

          (
            (  trigger.isInsert)
            ||
            (trigger.isUpdate  &&  a.ParentId <> triggeroldmap.get(a.id).ParentId)
            ||
            (trigger.isUpdate  && a.RecordTypeId <> triggeroldmap.get(a.id).RecordTypeId)
          )

        ) {
          if (branchesPerParentIDs.get(a.parentId) == null)
            branchesPerParentIDs.put(a.parentID, new list<Account>());
          branchesPerParentIDs.get(a.ParentId).add(a);
        }
      }
    }


    if (!branchesPerParentIDs.isEmpty()) {
      set<ID> parentIDS = branchesPerParentIDs.keyset();
      list<Account> childrenTOUpdate = new list<Account>();
      string fieldsINtheQuery = '*';
      for (String field : fieldsToCheck)
        fieldsINtheQuery += ',' + field;

      fieldsINtheQuery = fieldsINtheQuery.replace('*,', '');

      string query = 'SELECT id,recordTypeID,ParentId,name,' + fieldsINtheQuery + ' FROM Account   WHERE  ID IN:parentIDS' ; //Id IN:parentIDS OR

      List<Account> AcctsDB = database.query(query);

      for (Account a : AcctsDB) {
        for (Account branch : branchesPerParentIDs.get(a.id)) {

          for (String field : fieldsToCheck) {
            branch.put(field, a.get(field));
          }

          string site = transformationHelper.buildSiteForAcli(a.IATACode__c, a.Airline_designator__c ,
                        branch.IATA_ISO_Country__r.ISO_Code__c,
                        null);
          
          if(Branch.Reason_For_Creation__c!=AMS_Utils.accountReasonForCreationPASS){//ignore the site update if the process is trying to update an account created from a PASS process.
            Branch.site = site;
            Branch.Site_index__c = site;
          }
        }
      }

    }


  }


  public static void CopyFromHqToBRAfterUpdate(map<id, Account> triggerNew) {


    set<string> fieldsToCheck = new set<String> {    'Area_of_Operation__c',
        'Type_of_Service__c', 'Type',
        'BSP_CI_Valid__c', 'BSP_FOC_Valid__c', 'CASS_CI_Valid__c',
        'CASS_FOC_Valid__c', 'Airline_designator__c', 'IATACode__c',
        'TradeName__c',  'ACLI_Status__c', 'Airline_Prefix__c'
                                                };

    ID hqRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
    ID brRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR');
    ID StandardRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');


    map<Id, Account> parentAcctPerIds = new map<Id, Account>();
    for (Account a : triggerNew.values()) {
      for (String field : fieldsToCheck) {
        if (a.RecordTypeId == hqRT && a.get(field)<> trigger.oldMap.get(a.id).get(field)) {
          parentAcctPerIds.put(a.Id, a);
        }
      }
    }


    if (parentAcctPerIds <> null && parentAcctPerIds.size() > 0) {

      set<ID> parentidS = parentAcctPerIds.keyset();
      list<Account> childrenTOUpdate = new list<Account>();
      string fieldsINtheQuery = '*';
      for (String field : fieldsToCheck)
        fieldsINtheQuery += ',' + field;

      fieldsINtheQuery = fieldsINtheQuery.replace('*,', '');

      string query = 'SELECT id,recordTypeID,parent.id,name,' + fieldsINtheQuery + ' FROM Account WHERE parent.id IN :parentidS and (recordtypeID =\'' + brRT + '\'OR recordtypeID =\'' + StandardRT + '\')';

      system.debug('wuery -->' + query);

      List<Account> AcctsDB = database.query(query);

      for (Account a : AcctsDB) {

        for (String field : fieldsToCheck) {
          a.put(field, parentAcctPerIds.get(a.parent.id).get(field));
        }
        //a.name =parentAcctPerIds.get(a.parent.id).TradeName__c <> null ? parentAcctPerIds.get(a.parent.id).tradename__c : parentAcctPerIds.get(a.parent.id).name;
        childrenTOUpdate.add(a);

      }

    if (!childrenTOUpdate.isEmpty()){
        Integer enqueuedJobs=[select count() from asyncApexJob where JobType = 'BatchApex' and status in ('Processing', 'Preparing', 'Queued')];
        if(enqueuedJobs == 0){
        	System.enqueueJob(new AsyncDML_Util(childrenTOUpdate, AsyncDML_Util.DML_UPDATE, false));
    	}
        else{
            Datetime now = Datetime.now().addSeconds(3);
            String hour = String.valueOf(now.hour());
            String min = String.valueOf(now.minute()); 
            String ss = String.valueOf(now.second());
            String day = String.valueOf(now.day());
            String month = String.valueOf(now.month());
            String year = String.valueOf(now.year());
            //parse to cron expression
            String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
            System.schedule('ScheduledJob ' + String.valueOf(Math.random()), nextFireTime, new AsyncDML_Util_Schedulable(childrenTOUpdate, AsyncDML_Util.DML_UPDATE, false));
        }
    }
    }

  }

}
trigger trgAccelyaRequestSetCountry on Case (before insert, after insert, before update) {

  ID caseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'BSPlink_Customer_Service_Requests_CSR');
  Boolean isAccelya = false;
  List<String> bspCountryList = new List<String>();
  List<Id> caseIds = new List<Id> {};
  List<Case> caseListtoValidate = new List<Case> {};
  List<Case> caseList = new List<Case> {};
  for (Case aCase : trigger.New) {
    if (aCase.RecordTypeId == caseRecordTypeID) {
      isAccelya = true;

    } else {
      break;
    }
  }

  if (isAccelya) {


    if (Trigger.isBefore) {

      for (Case c : trigger.New) {
//2014-02-04 INC073699: Replace Applicable_to_Which_BSP_s__c with Country_concerned__c
//                if((c.Case_Creator_Email__c == null || !(c.Case_Creator_Email__c.contains('@iata.org'))) && c.Accelya_Request_Type__c != null && c.Applicable_to_Which_BSP_s__c != null && c.BSPCountry__c == null){
        if ((c.Case_Creator_Email__c == null || !(c.Case_Creator_Email__c.contains('@iata.org'))) && c.Accelya_Request_Type__c != null && c.Country_concerned__c != null && c.BSPCountry__c == null) {

          //bspCountryList = c.Applicable_to_Which_BSP_s__c.split(';');
          bspCountryList = c.Country_concerned__c.split(';');
          c.BSPCountry__c = bspCountryList[0];
          c.RecordTypeId = caseRecordTypeID;
          System.debug('BSP Country ----> ' + c.BSPCountry__c);

        }
      }


    }

    if (Trigger.isAfter) {
      System.debug('isAccelya ----> ' + isAccelya);
      for (Case aCase : trigger.New) {


        caseIds.add(acase.Id);


      }
      System.debug('Number of cases...........: ' + caseIds.size() + '  Case ID: ' + caseIds[0]);
      caseListtoValidate = [Select Id, Case_Creator_Email__c, Accelya_Request_Type__c, Applicable_to_Which_BSP_s__c, BSPCountry__c, RecordTypeId from Case where Id in :caseIds];
      for (Case c : caseListtoValidate) {


        System.debug('Case record Type ----> ' + c.recordTypeId);
        /*if(c.Accelya_Request_Type__c != null && c.Applicable_to_Which_BSP_s__c != null && c.BSPCountry__c == null){

            bspCountryList = c.Applicable_to_Which_BSP_s__c.split(';');
            c.BSPCountry__c = bspCountryList[0];
            System.debug('BSP Country ----> ' + c.BSPCountry__c);

         }*/

        system.debug('\nc.Case_Creator_Email__c: ' + c.Case_Creator_Email__c);
        if (c.Case_Creator_Email__c == null || !(c.Case_Creator_Email__c.contains('@iata.org'))) {
          system.debug('\nAssignment Rule Begins');
          AssignmentRule AR = new AssignmentRule();
          AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];

          //Creating the DMLOptions for "Assign using active assignment rules" checkbox
          Database.DMLOptions dmlOpts = new Database.DMLOptions();
          dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;

          //Setting the DMLOption on Case instance
          c.setOptions(dmlOpts);
          caseList.add(c);
        }
      }
      update caseList;

    }
  } else {

    if (Trigger.isBefore && Trigger.isInsert) {
      for (Case aCase : trigger.New) {

        if (aCase.Accelya_Request_Type__c != null && aCase.RecordTypeId != caseRecordTypeID) {
          aCase.RecordTypeId = caseRecordTypeID;
          //caseIds.add(acase.Id);
        }


      }


    }

  }


}
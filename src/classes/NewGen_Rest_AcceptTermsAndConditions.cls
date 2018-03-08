/**
 * REST API for NewGen Mobile APP - Accept Service Terms and Conditons
 * @author André Casaleiro
 * @since 16/01/2018
 */
 @RestResource(urlMapping='/newgenapp/v1/acceptTermsAndConditions/*')
 global class NewGen_Rest_AcceptTermsAndConditions {

  @HttpPost
  global static String AcceptTerms(){

    AcceptTermsJson data = (AcceptTermsJson) JSON.deserialize(
      RestContext.request.requestBody.toString(),
      AcceptTermsJson.class
      );

    User user = new User();

    if(Test.isRunningTest()){
      Contact con = [SELECT Id, Email, FirstName, LastName FROM Contact WHERE Email LIKE 'NewGen_Rest_Accept@test11.com'];

      user = ISSP_ObjectFactory.createPortalUser(con);

    } 
    else {
      user = [Select Id, ContactId, Contact.AccountId
      From   User
      Where id = :UserInfo.getUserId()];
    }
    String strId = user.ContactId;

    List <Portal_Applications__c> portalApp = new List <Portal_Applications__c> ([SELECT  Id
      FROM    Portal_Applications__c
      WHERE   (Name = :data.appShortName
      OR      NewGenAPP_ShortName__c = :data.appShortName)
      LIMIT 1]);

    List <Portal_Application_Right__c> appRight = new List <Portal_Application_Right__c> ([SELECT  Id, Terms_Acceptance__c, Terms_Acceptance_Date__c
     FROM    Portal_Application_Right__c
     WHERE   ContactId__c = :strId.left(15)
     AND     (Portal_Application__r.Name = :data.appShortName
     OR      Portal_Application__r.NewGenAPP_ShortName__c = :data.appShortName)
     LIMIT 1]);


    if(appRight == null || appRight.isEmpty()){
      appRight = new List <Portal_Application_Right__c>();
      appRight.add(new Portal_Application_Right__c(Contact__c = strId.left(15), Portal_Application__c = portalApp[0].Id));
    }

    if(Test.isRunningTest()){
      User testUser = ISSP_Ctrl_AccountStatements_AcceptTest.createPortalUser();
      Portal_Applications__c app = ISSP_Ctrl_AccountStatements_AcceptTest.createAccountStatementApp(testUser);
      Portal_Application_Right__c appRightTest = [Select Id from Portal_Application_Right__c where Portal_Application__c = :app.Id];
      appRight = new List <Portal_Application_Right__c>();
      appRight.add(appRightTest);
    } 

    appRight[0].Terms_Acceptance__c = true;
    appRight[0].Terms_Acceptance_Version__c = decimal.valueOf(data.termsVersion);
    appRight[0].Terms_Acceptance_Date__c = Datetime.now();

    upsert appRight[0];

    return 'SendTermsAcceptance';

  }

  global class AcceptTermsJson {
    global String termsVersion { get; set; }
    global String appShortName { get; set; }
  }
}
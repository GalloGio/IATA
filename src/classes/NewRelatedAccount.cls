public class NewRelatedAccount {

  private String parentAccountId;
  private Account parentAccount {get; set;}
  public Account newStandard {get; set;}

  public NewRelatedAccount() {

    try {
      parentAccountId = ApexPages.currentPage().getParameters().get('accID');


      list<Account> accts = [select id, name, iatacode__c, Airline_designator__c, sector__c
                             , industry, type, TradeName__c, Legal_name__c, category__c,
                             IATA_ISO_Country__c, Reason_for_creation__c,
                             Comments_Reason_for_creation__c, Airline_Prefix__c
                             from account
                             where id = :parentAccountId];

      if (accts.isEmpty())
        throw new TransformationException(' No Account Found');


      newStandard = accts[0];
      newStandard.id = null;
      newStandard.IATA_ISO_Country__c = null;
      newStandard.Comments_Reason_for_creation__c = null;
      newStandard.recordtypeid = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');




    } catch (Exception e) {
      throw new transformationException('This Page should not be accessed directly or invalid ID');
    }

  }

  public List<SelectOption> getReasons() {
    List<SelectOption> options = new List<SelectOption>();


    Schema.DescribeFieldResult fieldResult = Account.Reason_for_creation__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    options.add(new SelectOption('', '--None--'));
    for ( Schema.PicklistEntry f : ple) {
      if (!f.getLabel().equals('Created by customer') )
        options.add(new SelectOption(f.getLabel(), f.getValue()));
    }


    return options;
  }

  public PageReference Save() {
    try {

      string standardRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

      Newstandard.ParentId = parentAccountID;
      Newstandard.recordtypeID = standardRT;

      insert Newstandard;
      PageReference acctPage = new PageReference('/' + Newstandard.ID);
      acctPage.setRedirect(true);
      return acctPage;

    } catch (Exception e) {

      system.debug('Error : ' + e.getMessage() );
      return null;

    }


  }

  public PageReference Cancel() {


    PageReference acctPage = new PageReference('/' + parentAccountId);
    acctPage.setRedirect(true);
    return acctPage;


  }



}
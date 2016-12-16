@isTest
private class AMS_OSCAR_AttachmentsTest {
  
  @testSetup static void setup(){
  WrapperAttachTest.loadTestCredentials();
  AMS_OSCAR_TestDataFactory.createOSCARtestData();
  }
  
  static testMethod void AMS_OSCAR_Attachments() {
  AMS_Oscar__c oscar = [SELECT Id FROM AMS_Oscar__c LIMIT 1];
  Case cse = [SELECT Id FROM Case WHERE OSCAR__c = :oscar.Id];
  AmazonFile amazonFile = WrapperAttachTest.createAmazonFile(cse);

  Attachment att = new Attachment(Body = Blob.valueOf('Test'), Name = 'Test attachment', ParentId = cse.Id);
  insert att;

  Archived_Attachment__c archAtt = new Archived_Attachment__c(Name = 'Test', Case__c = cse.Id, Bucket__c = 'Test');
  insert archAtt;
  
  PageReference pg = Page.AMS_OSCAR_Attachment_List;
  pg.getParameters().put('Id', oscar.Id);
    Test.setCurrentPage(pg);

  AMS_OSCAR_Attachments con = new AMS_OSCAR_Attachments();

  System.assertEquals(con.caseId, cse.Id);
  System.assertEquals(3, con.listAttachments.size());
  System.assert(con.getCanAttachFilesToCase(), 'Impossible to attach');

  System.assertEquals('No records to display', con.emptyList[0]);

  con.makeAllPrivate();
  System.assert(!con.listAttachments[0].isPublic);

  try{
    con.makeAllPublic();
    System.assert(con.listAttachments[0].isPublic);
  }catch(Exception e){
    System.assert(e.getMessage().contains('Id not specified'));
  }
  try{
    con.listAttachments[0].isPublic = false;
    con.updateAllAttach();
  }catch(Exception e){
    System.assert(e.getMessage().contains('Id not specified'));
  }
  
  con.refreshList();
  System.assert(!con.listAttachments[0].isPublic);    

  System.assert(con.getTransferAttachmentsUrl().indexOf(cse.Id) > -1);
  System.assert(con.goToAttachmentPage().getUrl().indexOf(cse.Id) > -1);

  //read
  System.debug(loggingLevel.INFO, '____ [cls AMS_OSCAR_AttachmentsTest - AMS_OSCAR_Attachments] con.amazonPath - ' + con.amazonPath);
  System.debug(loggingLevel.INFO, '____ [cls AMS_OSCAR_AttachmentsTest - AMS_OSCAR_Attachments] con.amazonURL - ' + con.amazonURL);
  System.debug(loggingLevel.INFO, '____ [cls AMS_OSCAR_AttachmentsTest - AMS_OSCAR_Attachments] con.credentialName - ' + con.credentialName);
  System.debug(loggingLevel.INFO, '____ [cls AMS_OSCAR_AttachmentsTest - AMS_OSCAR_Attachments] AMS_OSCAR_Attachments.getAllExpiringLink(cse.Id) - ' + AMS_OSCAR_Attachments.getAllExpiringLink(cse.Id));
  System.debug(loggingLevel.INFO, '____ [cls AMS_OSCAR_AttachmentsTest - AMS_OSCAR_Attachments] AMS_OSCAR_Attachments.getExpiringLink(testfileName.pdf) - ' + AMS_OSCAR_Attachments.getExpiringLink('testfileName.pdf'));
  System.debug(loggingLevel.INFO, '____ [cls AMS_OSCAR_AttachmentsTest - AMS_OSCAR_Attachments] AMS_OSCAR_Attachments.getExpiringLinkWS(testfileName.pdf) - ' + AMS_OSCAR_Attachments.getExpiringLinkWS('testfileName.pdf'));

  System.assert(!AMS_OSCAR_Attachments.deleteAttachment(amazonFile.getId(), amazonFile.getFullName()));
  System.assert(!AMS_OSCAR_Attachments.deleteAttachment(archAtt.Id, null));
  System.assert(AMS_OSCAR_Attachments.deleteAttachment(att.Id, null));

  }
  
}
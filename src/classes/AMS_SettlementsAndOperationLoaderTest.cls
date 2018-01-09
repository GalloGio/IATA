/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
 
@isTest
public class  AMS_SettlementsAndOperationLoaderTest{

  static testMethod void testSettlements(){
  
    IATA_ISO_Country__c c = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US');
    insert c;

    insert new AMS_Settlement_System__c(Name = 'CASS-MX');

    Blob b = Blob.valueof('Region,BSP,Countrie(s),Country ISO,DPC/BSPlink,DPC Provider,DPC System\r\nThe Americas,US,US,US,US,Maestro / Accelya, Test\r\nThe Americas,US,US,US,US,HP,Test\r\nThe Americas,MX,MX,MX,MX,HP,Test');
    AMS_SettlementsAndOperationLoaderCtrl ctrl = new AMS_SettlementsAndOperationLoaderCtrl();
    ctrl.fileLoaderType = ctrl.getItems().get(0).getLabel();
    ctrl.csvFileBody = b;
    ctrl.selected=false;
    ctrl.importCSVFile();
    ctrl.saveRecord();
    
  }

  static testMethod void test_noCollumns(){
  
    IATA_ISO_Country__c c = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US');
    insert c;
    Blob b = Blob.valueof('Test collumn\r\nerror');
    AMS_SettlementsAndOperationLoaderCtrl ctrl = new AMS_SettlementsAndOperationLoaderCtrl();
    ctrl.fileLoaderType = ctrl.getItems().get(0).getLabel();
    ctrl.csvFileBody = b;
    ctrl.selected=false;
    ctrl.importCSVFile();
    
  }

  static testMethod void test_noDPCSystem(){
  
    IATA_ISO_Country__c c = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US');
    insert c;
    Blob b = Blob.valueof('Region,BSP,Countrie(s),Country ISO,DPC/BSPlink,DPC Provider\r\nThe Americas,US,US,US,US,Maestro / Accelya');
    AMS_SettlementsAndOperationLoaderCtrl ctrl = new AMS_SettlementsAndOperationLoaderCtrl();
    ctrl.fileLoaderType = ctrl.getItems().get(0).getLabel();
    ctrl.csvFileBody = b;
    ctrl.selected=false;
    ctrl.importCSVFile();
    
  }
  
  static testMethod void testSettlementsAuto(){
  
    IATA_ISO_Country__c c = new IATA_ISO_Country__c (Name='Argentina',ISO_Code__c='AR');
    insert c;
    AMS_SettlementsAndOperationLoaderCtrl ctrl = new AMS_SettlementsAndOperationLoaderCtrl();
    ctrl.fileLoaderType = ctrl.getItems().get(0).getLabel();
    ctrl.selected=true;
    ctrl.importCSVFile();
    ctrl.saveRecord();
    
  }
  
  static testMethod void testoperations(){
    String body =   'Hub,Country,Operation Name,Bank Name,Account for MT940,Direct Debut Account Number,Settlement Message Type (Domestic),Direct Debit Message Type (Domestic)'+
            '\r\nMIA,US,US_BSP_Y_ARS_I,Santander US,*000937700ARS,,MT101,MT104'+
            '\r\nMAD,MX,MX_HP_L_ARS_I,Santander MX,*000937700ARS,,MT101,MT104'+
            '\r\nSPP,BR,WRONGISO_HP_L_ARS_I,Santander BR,*000937700ARS,,MT101,MT104'+
            '\r\nSPP,BR,OPERATIONERROR,Santander BR,*000937700ARS,,MT101,MT104';

    Blob b = Blob.valueof(body);
    testSettlements();
    AMS_SettlementsAndOperationLoaderCtrl ctrl = new AMS_SettlementsAndOperationLoaderCtrl();
    ctrl.fileLoaderType = ctrl.getItems().get(1).getLabel(); 
    ctrl.selected=false;
    ctrl.csvFileBody = b;
    ctrl.importCSVFile();
    ctrl.saveRecord();
  }
  
  static testMethod void testoperations_noName(){
    String body =   'Hub,Country,Bank Name,Account for MT940,Direct Debut Account Number,Settlement Message Type (Domestic),Direct Debit Message Type (Domestic)'+
            '\r\nMIA,US_BSP_Y_ARS_I,Santander US,*000937700ARS,,MT101,MT104'+
            '\r\nMIA,US_BSP_Y_ARS_I,Santander US,*000937700ARS,,MT101,MT104';

    Blob b = Blob.valueof(body);
    testSettlements();
    AMS_SettlementsAndOperationLoaderCtrl ctrl = new AMS_SettlementsAndOperationLoaderCtrl();
    ctrl.fileLoaderType = ctrl.getItems().get(1).getLabel(); 
    ctrl.selected=false;
    ctrl.csvFileBody = b;
    ctrl.importCSVFile();
    ctrl.saveRecord();
  }
  
  static testMethod void testoperations_auto(){
    testSettlements();
    AMS_SettlementsAndOperationLoaderCtrl ctrl = new AMS_SettlementsAndOperationLoaderCtrl();
    ctrl.fileLoaderType = ctrl.getItems().get(1).getLabel(); 
    ctrl.selected=true;
    ctrl.importCSVFile();
  }
  
  


}
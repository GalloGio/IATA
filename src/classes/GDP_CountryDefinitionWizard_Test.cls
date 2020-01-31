@isTest

public class GDP_CountryDefinitionWizard_Test{

	//@testSetup static void SetupTestData() {
	static testmethod void test_GDP_CountryDefinitionWizard(){
		//Data Country
		List<IATA_ISO_Country__c> clist=new List<IATA_ISO_Country__c>();
		IATA_ISO_Country__c c1 = new IATA_ISO_Country__c();
		c1.ISO_Code__c='CA';
		c1.Name='CANADA';
		c1.Region__c = 'North-America';
		clist.add(c1);
		IATA_ISO_Country__c c2 = new IATA_ISO_Country__c();
		c2.ISO_Code__c='US';
		c2.Name='United States of America';
		c2.Region__c = 'North-America';
		clist.add(c2);
		Insert clist;

		//Arrange
		GDP_Area_Definition__c areaDef = new GDP_Area_Definition__c(Country_Selection__c = 'CA,US');
		Insert areaDef;

		List<GDP_Area_Country__c> llist=new List<GDP_Area_Country__c>();
		GDP_Area_Country__c l1= new GDP_Area_Country__c();
		l1.Method__c='Include';
		l1.IATA_ISO_Country__c = c1.id;
		l1.GDP_Area_Definition__c = areaDef.id;
		llist.add(l1);
		Insert llist;


		ApexPages.StandardController sc = new ApexPages.StandardController(areaDef);
		GDP_CountryDefinitionWizard Wizzard = new GDP_CountryDefinitionWizard(sc);
		Wizzard.toSelect = '1';
		Wizzard.toUnselect = '1';
		Wizzard.FlagMessage = true;

		GDP_CountryDefinitionWizard.CountryItemCls CountryItem
			= new GDP_CountryDefinitionWizard.CountryItemCls(1, new IATA_ISO_Country__c())   ;
		GDP_CountryDefinitionWizard.CountrySelectedCls CountrySelected
			= new GDP_CountryDefinitionWizard.CountrySelectedCls(1, new IATA_ISO_Country__c(), new GDP_Area_Country__c());


		//First Test Without Update Virtual Add and remove
		Wizzard.GoBack();
		Wizzard.AddToCountryCart();
		Wizzard.RemoveCountryCart();

		//Second test With Update
		Wizzard.toSelect = '0';
		Wizzard.toUnselect = '0';

		Wizzard.AddToCountryCart();
		Wizzard.RemoveCountryCart();
		Wizzard.DoUpdate();


	}

	//2c92c0f951b3bf4a0151cb4eb69b3d09
	//@testSetup static void SetupTestData() {
	static testmethod void test_GDP_FileDefRatePlanDefWizard(){

		//Data File Description
		List<GDP_File_Description__c> clist=new List<GDP_File_Description__c>();
		GDP_File_Description__c c1 = new GDP_File_Description__c();
		c1.Name='File description 1';
		c1.Magnitude__c='Master';
		c1.Product_Type__c='GSS';
		c1.File_Format__c='TXT';
		c1.Class__c = 'G';
		clist.add(c1);

		GDP_File_Description__c c2 = new GDP_File_Description__c();
		c2.Name='File description 2';
		c2.Magnitude__c='Master';
		c2.Frequency__c='Monthly';
		c2.Product_Type__c='GSS';
		c2.File_Format__c='TXT';
		c2.Class__c = 'G';
		c2.Reference__c = c1.id;
		clist.add(c2);

		GDP_File_Description__c c3 = new GDP_File_Description__c();
		c3.Name='File description 3';
		c3.Magnitude__c='Master';
		c3.Frequency__c='Monthly';
		c3.Product_Type__c='GSS';
		c3.File_Format__c='TXT';
		c3.Class__c = 'G';
		c3.Reference__c = c1.id;
		clist.add(c3);
		Insert clist;



		List<Product2> zplist = new List<Product2>();
		Product2 zp1 = new Product2();
		zp1.Name='zProduct';
		zp1.zqu__SKU2__c='SKU-00000981';
		zp1.zqu__ZuoraId__c='2c92c0f851b3afa80151cb4cc8be43f2';
		zp1.ProductCategory__c='GSS';
		zp1.ProductAudience__c='Member Airline';
		zp1.Description = 'zProduct';
		zp1.zqu__EffectiveStartDate__c=System.Today();
		zp1.zqu__EffectiveEndDate__c=System.Today().AddDays(365);
		zplist.add(zp1);
		Insert zplist;

		List<zqu__ProductRatePlan__c> rplist=new List<zqu__ProductRatePlan__c>();
		zqu__ProductRatePlan__c rp1 = new zqu__ProductRatePlan__c();
		rp1.name='MyRatePlan';
		rp1.zqu__Product__c = zp1.id;
		rp1.zqu__ZuoraId__c='2c92c0f951b3bf4a0151cb4eb69b3d09';
		rplist.add(rp1);
		Insert rplist;

		//Arrange
		List<GDP_File_Description_To_Rate_Plan__c> alist = new List<GDP_File_Description_To_Rate_Plan__c>();
		GDP_File_Description_To_Rate_Plan__c areaDef1 = new GDP_File_Description_To_Rate_Plan__c();
		areaDef1.GDP_File_Description__c = c2.id;
		areaDef1.Product_Rate_Plan__c = rp1.id;
		alist.add(areaDef1);

		GDP_File_Description_To_Rate_Plan__c areaDef2 = new GDP_File_Description_To_Rate_Plan__c();
		areaDef2.GDP_File_Description__c = c3.id;
		areaDef2.Product_Rate_Plan__c = rp1.id;
		alist.add(areaDef2);

		Insert alist;


		ApexPages.StandardController sc = new ApexPages.StandardController(rp1);
		GDP_FileDefRatePlanDefWizard Wizzard = new GDP_FileDefRatePlanDefWizard(sc);

		Wizzard.fmagnitude='Master';
		Wizzard.ffileformat='TXT';
   		Wizzard.fproducttype='GSS';
		Wizzard.fcoverage='';
		Wizzard.toSelect = '1';
		Wizzard.toUnselect = '1';
		Wizzard.FlagMessage = true;


		//First Test Without Update Virtual Add and remove
		Wizzard.GoBack();
		Wizzard.AddToFileDescriptionCart();
		Wizzard.RemoveFileDescriptionCart();
		Wizzard.refetch();
		Wizzard.getMagnitudes();
		Wizzard.getProductTypes();
		Wizzard.getFileFormats();
		Wizzard.getGeoCoverages();

		//Second test With Update
		Wizzard.toSelect = '0';
		Wizzard.toUnselect = '0';

		Wizzard.AddToFileDescriptionCart();
		Wizzard.RemoveFileDescriptionCart();
		Wizzard.DoUpdate();


	}
}

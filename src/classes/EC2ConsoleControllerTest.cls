@isTest
private class EC2ConsoleControllerTest {

	@isTest
	static void t2() {
		try{
		EC2ConsoleController ecc = new EC2ConsoleController();
		ecc.getdescribeImages();
		}catch(Exception ex){
		}
	}

	@isTest
	static void t3() {
		try{
			EC2ConsoleController ecc = new EC2ConsoleController();
			ecc.refreshImages();
		}catch(Exception ex){
		}
	}

	@isTest
	static void t4() {
		try{
			EC2ConsoleController ecc = new EC2ConsoleController();
			ecc.RebootInstances();
		}catch(Exception ex){
		}
	}

	@isTest
	static void t5() {
		try{
			EC2ConsoleController ecc = new EC2ConsoleController();
			ecc.getOwners();
			ecc.TerminateInstances();
		}catch(Exception ex){
		}

	}

	@isTest
	static void t6() {
		try{
			EC2ConsoleController ecc = new EC2ConsoleController();
			ecc.RunInstances();
		}catch(Exception ex){
		}
	}

	@isTest
	static void t7() {
		try{
			EC2ConsoleController ecc = new EC2ConsoleController();
			ecc.getdescribeInstances();
		}catch(Exception ex){
		}
	}

	@isTest
	static void t8() {
		try{
			EC2ConsoleController ecc = new EC2ConsoleController();
			ecc.refreshInstances();
		}catch(Exception ex){
		}
	}

	@isTest
	static void t9() {
		try{
			EC2ConsoleController ecc = new EC2ConsoleController();
			ecc.refreshImages();
		}catch(Exception ex){
		}
	}

	@isTest
	static void testConstructor() {
	
		EC2ConsoleController contr = new EC2ConsoleController();

		AWSKey__c credentials = new AWSKey__c(name = 'production', Key__c = 'asd', Secret__c = 'asd');
		insert credentials;

		Test.startTest();

		List<EC2Connection.EC2Image> img = contr.images;
		List<EC2Connection.EC2Instance> instances = contr.instances;
		String owner = contr.owner;
		PageReference ref = contr.constructor();

		Test.stopTest();

		System.assertEquals(img, null);
		System.assertEquals(instances, null);
		System.assertEquals(ref, null);
	}

}

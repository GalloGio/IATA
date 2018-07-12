@isTest
private class AWSKeysTest {

	@isTest
	private static void testInstance() {
		try {
			AWSKeys k = new AWSKeys('badname');
		} catch (AWSKeys.AWSKeysException AWSExcept) {
			system.debug('here: ' + AWSExcept.getTypeName());
			system.assert(AWSExcept.getTypeName().contains('AWSKeys.AWSKeysException'));

		}

		AWSKey__c t1 = new AWSKey__c( key__c = 's1', secret__c = 's1', name = 'test' );
		insert t1;
		AWSKeys k = new AWSKeys('test');
		system.assert(k.key == 's1');
		system.assert(k.secret == 's1');


		try {
			AWSKey__c t2 = new AWSKey__c( secret__c = 's1', name = 'test2' );
			insert t2;
			k = new AWSKeys('test2');
		} catch (AWSKeys.AWSKeysException AWSExcept) {
			system.assert(AWSExcept.getTypeName().contains('AWSKeys.AWSKeysException'));

		}

		try {
			AWSKey__c t3 = new AWSKey__c( key__c = 's1', name = 'test3' );
			insert t3;
			k = new AWSKeys('test3');
		} catch (AWSKeys.AWSKeysException AWSExcept) {
			system.assert(AWSExcept.getTypeName().contains('AWSKeys.AWSKeysException'));

		}


	}

}
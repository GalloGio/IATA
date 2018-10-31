@isTest
private class ANG_UpdateRHCInformationSchedulerTest {
	
	@isTest static void test_method_one() {
		String hour = String.valueOf(Datetime.now().hour());
		String min = String.valueOf(Datetime.now().minute()); 
		String ss = String.valueOf(Datetime.now().second() + 5);
		String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
		
		System.schedule('ANG_UpdateRHCInformationScheduler ' + String.valueOf(Math.random()), nextFireTime, 
						new ANG_UpdateRHCInformationScheduler(new Set<Id>(), ANG_UpdateRHCInformationBatch.Process.CONSUMED, false, 1));
	}
	
	
}
@isTest
private class ANG_UpdateRHCInformationSchedulerTest {
  
  @isTest static void test_method_one() {
    Datetime execTime = Datetime.now().addSeconds(5);
    String hour = String.valueOf(execTime.hour());
    String min = String.valueOf(execTime.minute()); 
    String ss = String.valueOf(execTime.second()); 
    String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
    
    System.schedule('ANG_UpdateRHCInformationScheduler ' + String.valueOf(Math.random()), nextFireTime, 
    new ANG_UpdateRHCInformationScheduler(new Set<Id>(), ANG_UpdateRHCInformationBatch.Process.CONSUMED, false, 1));
  }  
  
}
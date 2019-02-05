@isTest
public class ANG_ProgressBar_Test {

    public static testMethod void test1() {
        Case cse = new Case(Status='Draft');
        insert cse;

        Test.StartTest();
        ANG_ProgressBarHelper helper = new ANG_ProgressBarHelper('IDFS Airline Participation Process|Airline', cse.Id);
        ANG_ProgressBar pb = new ANG_ProgressBar();
        pb.helper = helper;
        Test.StopTest();
    }
}
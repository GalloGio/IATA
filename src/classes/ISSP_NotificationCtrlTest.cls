/**
 * Created by FME on 12/2/2018.
 */
@isTest
public class ISSP_NotificationCtrlTest {

	@isTest
	static void test_NotificationPopup(){

		ISSP_NotificationCtrl rToTest = new ISSP_NotificationCtrl();

		rToTest.closeModalPopup();

		system.assertEquals(true, rToTest.closePopUp);

		rToTest.vfpage='/ISSP_Case';
		rToTest.attId='caseId';
		rToTest.recordId='5001q0000239SUc';

		pageReference pageToOpen = rToTest.openRecord();

		rToTest.showPopUp=true;
		rToTest.msgLabelTitle='testTitle';
		rToTest.msgLabelName='testMsg';
		rToTest.msgLabelButton='click on';
		rToTest.showButton=true;

	}


}
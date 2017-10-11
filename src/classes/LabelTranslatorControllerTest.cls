/**
 * Created by Manuel Conde on 10/05/2017.
 */
@IsTest
private class LabelTranslatorControllerTest {

    @isTest static void testTranslation(){

        PageReference pageRef = Page.LabelTranslator;
        Test.setCurrentPage(pageRef);
        LabelTranslatorController controller = new LabelTranslatorController();

    }

}
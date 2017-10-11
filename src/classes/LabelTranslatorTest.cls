/**
 * Created by Manuel Conde on 10/05/2017.
 */

@isTest
public class LabelTranslatorTest {

    @isTest static void testTranslation(){
        LabelTranslator a = new LabelTranslator();
        String test = a.translate('Test', 'en');

    }

}
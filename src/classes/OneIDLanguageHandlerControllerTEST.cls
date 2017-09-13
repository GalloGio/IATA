/**
 * Created by Manuel Conde on 10/05/2017.
 */
@isTest
public class OneIDLanguageHandlerControllerTEST {

    @isTest static void Metodostest()
        {

            Test.startTest();

            OneIdLanguageHandlerController.getLanguageInfo();
            OneIdLanguageHandlerController.changeLanguage('pt_BR');

            Test.stopTest();

        }
}
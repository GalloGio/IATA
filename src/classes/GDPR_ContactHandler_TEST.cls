@isTest
public class GDPR_ContactHandler_TEST {

    @isTest
    static void beforeInsertBeforeUpdateAfterDeleteTest(){

        //Create a Contact without Individual
        Contact c = new Contact(FirstName = 'Jake', LastName = 'Lockley', Salutation = 'Mr.',  Email = 'jake.lockley@marvel.com');
        INSERT c;

        //Remove the connection between Lead and Individual
        c.FirstName = 'Steven';
        c.IndividualId = null;
        c.email = 'steven.grant@marvel.com';
        UPDATE c;

        DELETE c;

    }

}
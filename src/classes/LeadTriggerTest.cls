@isTest
public class LeadTriggerTest {

    @isTest
    static void beforeInsertBeforeUpdateAfterDeleteTest(){

        //Create a Lead without Individual  
        Lead l = new Lead(FirstName = 'Marc', LastName = 'Spector', Salutation = 'Mr.',  Email = 'marc.spector@marvel.com', Company='Marvel');
        INSERT l;

        //Remove the connection between Lead and Individual
        l.FirstName = 'Steven';
        l.IndividualId = null;
        l.email = 'steven.grant@marvel.com';
        UPDATE l;

        DELETE l;

    }

    
}
public class IecUser{

public static User Istance = null;

          private IecUser() {}
  
            // Metodo della classe impiegato per accedere al singleton
    public static User geUserlocal(Id userId) {
        if (Istance != null) {
                  
                  
                  Istance = [SELECT UserType, Username, IsActive, AccountId, CompanyName, 
                                    ContactId, Email, FirstName, Name, LastName, Id, Portal_User_Frozen__c
                                    FROM User
                                    WHERE Id = :userId][0];
        }
        return Istance ;
    }
    
    }
public with sharing class SidraLiteUtil{


    /**
        Return default region based on current user role
    **/
    public static String getDefaultRegion() {
        try {
            UserRole role = [Select Name from UserRole where id = :UserInfo.getUserRoleId()];

            if (role.Name.contains('Africa & ME')) {
                return 'Africa & Middle East';
            }
            if (role.Name.contains('Americas')) {
                return 'Americas';
            }
            if (role.Name.contains('A&P')) {
                return 'Asia & Pacific';
            }
            if (role.Name.contains('China')) {
                return 'China & North Asia';
            }
            if (role.Name.contains('MAD')) {
                return 'Europe';
            }
        } catch (Exception e) {
            System.debug('Could not find a valid role ' + UserInfo.getUserRoleId());
        }
        return '';
    }

    /**
        Return true if input is Passenger account
    **/
    public static Boolean isPassenger(Account account) {
        return account.Type=='IATA Passenger Sales Agent' || account.Type=='Domestic Agent';
    }

    /**
        Return true if account is Cargo or CASS
    **/
    public static Boolean isCargoCASS(Account account) {
        return account.type=='IATA Cargo Agent' || account.type=='CASS Associate';
    }

    /**
        Return true if input account is active
    **/
    public static Boolean isAccountActive(Account account) {
        return account != null && account.Status__c!='Cash basis/no commission' && account.Status__c!='Terminated Associate';
    }

    /**
        Get last month day of current date
    **/
    public static Date lastMonthDay(Date dt) {
        Integer daysInMonth = Date.daysInMonth(dt.year(), dt.month());
        return Date.newInstance(dt.year(), dt.month(), daysInMonth);
    }

}

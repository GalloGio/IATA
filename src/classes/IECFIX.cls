public class IECFIX{
      
        public static Boolean bIgnoreCurrentUserProfile;

        public static String getSystemIntegrationProfileId() {
        List<Profile> lstProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator - automated processes'];
        return (lstProfile.isEmpty() ? null : lstProfile.get(0).Id) + '' + ((bIgnoreCurrentUserProfile == null || !bIgnoreCurrentUserProfile) ? ',' + Userinfo.getProfileId() : '');
    }

}
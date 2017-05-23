global virtual class SCIMUser {

    public class Meta {
        public String created;
        public String lastModified;
        public String version;
        public String location;
    }

    public class Roles {
        public String type;
        public String value;
        public String display;
        public Boolean primary;
    }

    public class Groups {
        public String type;
        public String value;
        public String display;
        public Boolean primary;
    }

    public class Entitlements {
        public String type;
        public String value;
        public String display;
        public Boolean primary;
    }


    public class Name {
        public String formatted;
        public String familyName;
        public String givenName;
    }

    public class Emails {
        public String type;
        public String display;
        public Boolean primary;
        public String value;
    }


    public class PhoneNumbers {
        public String type;
        public String value;
    }

    public class Photos {
        public String type;
        public String value;
    }

    // Public fields to serialize / deserialize
    public List<String> schemas;
    public String id;
    public String userName;
    public String externalId;
    public Name name;
    public String displayName;
    public String nickName;
    public List<Emails> emails;
    public List<PhoneNumbers> phoneNumbers;
    public List<Photos> photos;
    public String userType;
    public String preferredLanguage;
    public String locale;
    public Boolean active;
    public String title;
    public List<Entitlements> entitlements;
    public List<Groups> groups;
    public List<Roles> roles;
    public Meta meta;
    
    public SCIMUser() {
        this(null);
    }

    public SCIMUser(Process.PluginRequest request) {

        if(request == null) return;

        String userName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_USERNAME);
        String familyName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_FIRSTNAME);
        String givenName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_LASTNAME);
        String externalid = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_EXTERNALID);
        String email = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_EMAIL);
        String id = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_ID);
        String displayName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_DISPLAYNAME);
        String nickName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_NICKNAME);
        String userType = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_USERTYPE);
        String preferredLanguage = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_PREFERREDLANGUAGE);
        String locale = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_LOCALE);
        String title = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_TITLE);
        Boolean active = (Boolean)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_ACTIVE);

        schemas = new List<String> {'urn:scim:schemas:core:1.0'};

        if (userName != null) this.userName = userName;

        if ((familyName != null) || (givenName != null))  {
            SCIMUser.Name name = new SCIMUser.Name();
            if (familyName != null) name.familyName = familyName;
            if (givenName != null) name.givenName = givenName;
            this.name = name;
        }

        if (externalid != null) this.externalId = externalid;

        if (email != null) { 
            SCIMUser.Emails emails = new SCIMUser.Emails();
            emails.value = email;
            List<SCIMUser.Emails> emailsList = new List<SCIMUser.Emails>();
            emailsList.add(emails);
            this.emails = emailsList;
        } 

        if(id != null) this.id = id;
        if(displayName != null) this.displayName = displayName;
        if(nickName != null) this.nickName = nickName;
        if(userType != null) this.userType = userType;
        if(preferredLanguage != null) this.preferredLanguage = preferredLanguage;
        if(locale != null) this.locale = locale;
        if(title != null) this.title = title;
        if(active != null) this.active = active;
    }

    // Simple JSON deserialization
    public static SCIMUser parse(String json) {
        return (SCIMUser)System.JSON.deserialize(json, SCIMUser.class);
    }
    
    public List<String> getSchemas(){
    	return schemas;
    }
    
}

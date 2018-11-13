@isTest(SeeAllData = true)
public class TestClass_SetupVariables {
    public static EmailTemplate emailTemplateTest {
        get
        {
            List<EmailTemplate> listEmailTemplate = [Select id from EmailTemplate limit 1];
            return listEmailTemplate.size() > 0 ? listEmailTemplate[0] : null;
        }
    }
    public static ID SIScaseRecordTypeID {
        get
        {
            return RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Cases_SIS_Help_Desk');
        }
    }
    public static ID IFAPcaseRecordTypeID {
        get
        {
            return RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        }
    }
    public static ID gdpContactRecordTypeID {
        get
        {
            return RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'GDP_Contact');
        }
    }
    public static ID IATAAccountRecordTypeID
    {
     	get
        {
            List<RecordType> recTypId= [Select id, name from recordtype where name = 'Standard Account' limit 1];             
            return recTypId.size() > 0 ? recTypId[0].Id : null;  
        }
    }
    public static ID ExternalCasesInvoicesWorksID {
        get
        {
            return RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'External_Cases_InvoiceWorks');
        }
    }
    public static ID HighVolumeCustomPortalID {
        get
        {
            List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Name = 'Overage High Volume Customer Portal User Cloned' limit 1];
            System.debug('************** PROFILE ******' + profileList[0].Name);
            List<User> thisUser = [select Id, username from User where isactive = true   limit 1];
            System.debug('************** USER ******' + thisUser.size());
            return thisUser.size() > 0 ? thisUser[0].id : null;
        }
    }

}
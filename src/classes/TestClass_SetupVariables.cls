@isTest(SeeAllData=true)
public class TestClass_SetupVariables{
	public static EmailTemplate emailTemplateTest 
    {
        get 
        {
            List<EmailTemplate> listEmailTemplate= [Select id from EmailTemplate limit 1];             
            return listEmailTemplate.size() > 0 ? listEmailTemplate[0] : null;  
        }        
    }
    public static ID SIScaseRecordTypeID
    {
        get
        {
            return clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('Cases - SIS Help Desk');
        }
    }
    public static ID IFAPcaseRecordTypeID
    {
        get
        {
            return clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('IATA Financial Review');
        }
    }
     public static ID gdpContactRecordTypeID
    {
        get
        {
            return clsContactTypeIDSingleton.getInstance().RecordTypes.get('GDP Contact');
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
    public static ID ExternalCasesInvoicesWorksID
    {
        get
        {
            List<RecordType> recTypId= [select name from recordtype where name = 'External Cases (InvoiceWorks)' limit 1];             
            return recTypId.size() > 0 ? recTypId[0].Id : null;
        }
    }
    public static ID HighVolumeCustomPortalID
    {
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
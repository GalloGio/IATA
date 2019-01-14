public class AMS_SOQL_Export {

    public AMS_SOQL_Query_Export__c exporter     {get;set;}
    public list<sobject>        queryResults {get;set;}
    public list<string>         queryFields  {get;set;}
    public string               queryString  {get;set;}
    public string               fileName     {get;set;}
    
    public AMS_SOQL_Export(ApexPages.StandardController controller) 
    {
        //Because the fields of the exporter object are not refernced on the visualforce page we need to explicity tell the controller
        //to include them. Instead of hard coding in the names of the fields I want to reference, I simply describe the exporter object
        //and use the keyset of the fieldMap to include all the existing fields of the exporter object.
        
        //describe object
        Map<String, Schema.SObjectField> fieldMap = Schema.AMS_SOQL_Query_Export__c.sObjectType.getDescribe().fields.getMap();
        
        //create list of fields from fields map
        list<string> fields = new list<string>(fieldMap.keySet());
        
        //add fields to controller
        if(!Test.isRunningTest())
        {
            controller.addFields(fields);
        }
        //get the controller value
        exporter = (AMS_SOQL_Query_Export__c) controller.getRecord();

        //create a filename for this exported file
        fileName = exporter.name + ' ' + string.valueOf(dateTime.now());
                
        //get the proper SOQL order direction from the order direction on the exporter object (Ascending = asc, Descending = desc)
        string orderDirection = exporter.Order_Direction__c == 'Ascending' ? 'asc' : 'desc';
        
        //create a list of fields from the comma separated list the user entered in the config object
        queryFields =  exporter.fields__c.split(',');
        
        //create the query string using string appending and some ternary logic
        queryString = 'select ' + exporter.fields__c + ' from ' + exporter.object_name__c;
        queryString += exporter.where_condition__c != null ? ' where ' + exporter.where_condition__c : '';
        queryString += exporter.Order_by__c != null ? ' order by ' + exporter.Order_by__c + ' ' + orderDirection :'';
        queryString += exporter.Limit__c != null ? ' limit ' +string.valueOf(exporter.Limit__c) : ' limit 10000';
        
        //run the query
        queryResults = database.query(queryString);
        
        
    }

    //creates and returns a newline character for the CSV export. Seems kind of hacky I know, but there does not seem to be a better
    //way to generate a newline character within visualforce itself.
    public static String getNewLine() {
      return '\n';
    }
}
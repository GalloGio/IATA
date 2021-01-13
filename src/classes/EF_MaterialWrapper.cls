public class EF_MaterialWrapper {

	public EF_Material_Line_Item__c mmli {get; set;}
	public Boolean selected {get; set;}

	//This is the contructor method.
	public EF_MaterialWrapper(EF_Material_Line_Item__c m) {
		mmli = m;
		selected = true;
	}
}

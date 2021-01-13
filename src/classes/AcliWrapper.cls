public class AcliWrapper {

	public integer LastVisited {get;set;}
	public integer NumberOfLines {get;set;}
	public map<String,AcliAccount> AcliAccount {get;set;}


	public AcliWrapper(integer lastVisited,integer numberOfLines , map<String,AcliAccount> AcliAccount){
		this.NumberOfLines = numberOfLines;
		this.LastVisited = lastVisited;
		this.AcliAccount =acliAccount;
	}

}

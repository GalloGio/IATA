public class ContactProxy {
	public Contact c {get;set;}
	public ID_Card__c idc {get;set;}
	public string error {get;set;}
	public boolean pending {get;set;}
	public boolean pendingOpIsLocked {get;set;}
	public boolean selected {get;set;}
	public string applicationType {get;set;}
	public String pack1 {get;set;}
	public String pack2 {get;set;}
	public string Photo {get;set;}
	public boolean getHasPhoto(){return (Photo!=null);}
	public String IATACode {get;set;}
	public String previousIATACode {get;set;}
	public string country {get;set;}
	public boolean haveApp {get;set;}
	//public date validtodate {get;set;}

	public boolean emailduplicate {get;set;}

	public ContactProxy(Contact c){
		this.c = c;
		this.pending = false;
		this.pendingOpIsLocked = false;
		this.emailduplicate = false;

		if(this.c.Revenue_Confirmation__c==null)
			this.c.Revenue_Confirmation__c = true;
		if(this.c.AgencyShare_Confirmation__c==null)
			this.c.AgencyShare_Confirmation__c = true;
		if(this.c.Hours_per_week__c==null)
			this.c.Hours_per_week__c = 'less then 20 h';


		if(!String.isBlank(c.IDCard_Email__c) && String.isBlank(c.Email)){
			this.c.Email = this.c.IDCard_Email__c;
			this.emailduplicate = true;
		}
	}

	public void addApplication(ID_Card_Application__c app){
		if(app.Title__c!=null)							c.Title = app.Title__c;
		if(app.Gender__c!=null)							c.Gender__c = app.Gender__c;
		if(app.Position_in_Current_Agency__c!=null)		c.Position__c = app.Position_in_Current_Agency__c;
		if(app.Hours_worked__c!=null)					c.Hours_per_week__c = app.Hours_worked__c;
		if(app.Duties_in_Current_Agency__c!=null)		c.Duties__c = app.Duties_in_Current_Agency__c;
		if(app.Start_Date_Agency_Month__c!=null)		c.Start_Date_Agency_Month__c = app.Start_Date_Agency_Month__c;
		if(app.Start_Date_Agency_Year__c!=null)			c.Start_Date_Agency_Year__c = decimal.valueOf(app.Start_Date_Agency_Year__c);
		if(app.Start_Date_Industry__c!=null)			c.Start_Date_Industry__c = decimal.valueOf(app.Start_Date_Industry__c);
		if(app.Photo__c!=null)							Photo = app.Photo__c;
		haveApp = true;
		pack1 = app.Package_of_Travel_Professionals_Course_1__c;
		pack2 = app.Package_of_Travel_Professionals_Course_2__c;
		pending = true;
	}

	public void addIDcard(ID_Card__c card){
		if(idc==null || idc.Valid_To_Date__c<card.Valid_To_Date__c){
			if(card.Title__c!=null)				c.Title = card.Title__c;
			if(card.Gender__c!=null)			c.Gender__c = card.Gender__c;
			if(card.Position__c!=null)			c.Position__c = card.Position__c;
			if(card.Hours_per_week__c!=null)	c.Hours_per_week__c = card.Hours_per_week__c;
			if(card.Duties__c!=null)			c.Duties__c = card.Duties__c;
			if(card.Start_Date_Agency_Month__c!=null)	c.Start_Date_Agency_Month__c = card.Start_Date_Agency_Month__c;
			if(card.Start_Date_Agency_Year__c!=null)	c.Start_Date_Agency_Year__c = decimal.valueOf(card.Start_Date_Agency_Year__c);
			if(card.Start_Date_Industry__c!=null)		c.Start_Date_Industry__c = decimal.valueOf(card.Start_Date_Industry__c);
			if(card.Photo__c!=null)						Photo = card.Photo__c;
			idc = card;
		}
	}

	public static Contact copyValuesToTargetContact(Contact target, Contact source){
		target.Salutation                 = source.Salutation;
		target.FirstName                  = source.FirstName;
		target.LastName                   = source.LastName;
		target.Date_of_Birth__c           = source.Date_of_Birth__c;
		target.VER_Number_2__c            = source.VER_Number_2__c;
		target.Function__c                = source.Function__c;
		target.Phone                      = source.Phone;
		target.Email                      = source.Email;
		target.Position__c                = source.Position__c;
		target.Duties__c                  = source.Duties__c;
		target.Start_Date_Agency_Month__c = source.Start_Date_Agency_Month__c;
		target.Start_Date_Agency_Year__c  = source.Start_Date_Agency_Year__c;
		target.Start_Date_Industry__c     = source.Start_Date_Industry__c;
		target.AccountId 				  = source.AccountId;
		target.Hours_per_week__c 		  = source.Hours_per_week__c;
		return target;
	}

	public ContactProxy CloneWithoutId(){
		ContactProxy newcp = new ContactProxy(c.clone(false,true,true,true));
		newcp.idc = this.idc;
		newcp.applicationType = this.applicationType;
		newcp.error = this.error;
		newcp.pending = this.pending;
		newcp.pendingOpIsLocked = this.pendingOpIsLocked;
		newcp.selected = this.selected;
		newcp.pack1 = this.pack1;
		newcp.pack2 = this.pack2;
		newcp.IATAcode = this.IATAcode;
		//newcp.hasPhoto = this.hasPhoto;
		newcp.Photo = this.Photo;
		newcp.emailduplicate = this.emailduplicate;
		return newcp;
	}

	public ContactProxy(List<String> row){
		Integer NColumns = 22;
		////// CSV Structure /////
		// c.Salutation
		// c.FirstName
		// c.LastName
		// c.Date_of_Birth__c
		// IATACode__c
		// c.VER_Number_2__c
		// c.Function__c
		// c.Phone
		// c.Email
		// c.Position__c
		// c.Duties__c
		// c.Start_Date_Agency_Month__c
		// c.Start_Date_Agency_Year__c
		// c.Start_Date_Industry__c

		// Geographie et planification
		// Geographie par destination
		// Serving the travel
		// Introduction a BSP link
		// Le service au client voyageur
		// La vente de produits ferroviaires internationaux

		// Type of application
		// Previous IATA code

		// Valid To Date

		//printerr('row:\n'+row+'\nrow.size()'+row.size());
		if(row.size()!=NColumns){
			this.error = 'Wrong number of column ('+row.size()+' instead of '+NColumns+')';
			return;
		}
	 	string mydebug = '';
		try{
			for(integer i=0; i<row.size();i++)
				if(row[i]!=null && row[i].length()>1 && row[i].startsWith('"') && row[i].endsWith('"')){
					mydebug = 'row['+i+']=' + row[i]+'--> length='+row[i].length();
					row[i] = row[i].substring(1,row[i].length()-1);
				}
			this.IATAcode = row[4];
			if(String.isBlank(IATAcode)){
				this.error = 'No IATA Code have been specified for this contact.';
				return;
			}

			this.c = new Contact(
				Salutation = row[0],
				FirstName = row[1],
				LastName = row[2],
				Date_of_Birth__c = row[3]=='' ? null : date.valueOf(row[3]),
				Ver_Number_2__c = row[5],
				Function__c = row[6],
				Phone = row[7],
				Email = row[8],
				IDCard_Email__c = row[8],
				Position__c = row[9],
				Duties__c = row[10],
				Start_Date_Agency_Month__c = row[11],
				Start_Date_Agency_Year__c = row[12]=='' ? null : decimal.valueOf(row[12]),
				Start_Date_Industry__c = row[13]=='' ? null : decimal.valueOf(row[13])

			);

			List<string> packages = new List<String>();
			if(boolean.valueOf(row[14])==true)
				packages.add('Geography in Travel Planning');
			if(boolean.valueOf(row[15])==true)
				packages.add('Destination Geography');
			if(boolean.valueOf(row[16])==true)
				packages.add('Serving the Travel & Tourism Customer');
			if(boolean.valueOf(row[17])==true)
				packages.add('Introduction to BSPLink');
			if(boolean.valueOf(row[18])==true)
				packages.add('Le service au client voyageur');
			if(boolean.valueOf(row[19])==true)
				packages.add('Selling International Rail Transportation');

			if(packages.size()>2)
				this.error = 'Maximum 2 Package of Travel Professionals Course are allowed.';
			else if(packages.size()==2){
				this.pack1 = packages[0];
				this.pack2 = packages[1];
			}else if(packages.size()==1)
				this.pack1 = packages[0];

			this.applicationType = row[20];
			this.previousIATAcode = row[21];

			//this.validtodate = row[22];

			//  Application type is required
			if(this.applicationType != 'New' && this.applicationType != 'Replacement' && this.applicationType != 'Reissue' && this.applicationType != 'Renewal'){
				this.error = 'Application type is required and must have one of the following values: "New","Renewal","Reissue","Replacement"';
				return;
			}

			// Replacement application type needs a previous IATA code
			if(ApplicationType == 'Replacement' && String.isEmpty(previousIATAcode)){
				this.error = 'Previous IATA code is required if application type is "Replacement"';
				return;
			}

			// Old & new IATA code should be different
			if(previousIATAcode == IATACode){
				this.error = 'Previous IATA code, if specified, must be different from the current one';
				return;
			}

		}catch(Exception e){
			this.error = ''+e;//+' ---> '+e.getStackTraceString()+' -- '+mydebug;
		}
	}


	public static String printCSVheader(){
		return 	'"Salutation","FirstName","LastName","Date_of_Birth__c","IATAcode__c",'+
				'"VER_Number_2__c","Function__c","Phone","Email","Position__c",'+
				'"Duties__c","Start_Date_Agency_Month__c","Start_Date_Agency_Year__c","Start_Date_Industry__c",'+
				'"Geographie et planification","Geographie par destination","Serving the travel","Introduction a BSP link","Le service au client voyageur",'+
				'"La vente de produits ferroviaires internationaux","Application Type","Previous IATA Code","Valid_To_Date__c"\r\n';
	}

	public string printCSVrow(){
		return	'"'+printNotNull(c.Salutation)+'",'+
				'"'+printNotNull(c.FirstName)+'",'+
				'"'+printNotNull(c.LastName)+'",'+
				'"'+printNotNull(c.Date_of_Birth__c)+'",'+
				'"'+printNotNull(c.iata_Code__c)+'",'+
				'"'+printNotNull(c.VER_Number_2__c)+'",'+
				'"'+printNotNull(c.Function__c)+'",'+
				'"'+printNotNull(c.Phone)+'",'+
				'"'+printNotNull(c.Email)+'",'+
				'"'+printNotNull(c.Position__c)+'",'+
				'"'+printNotNull(c.Duties__c)+'",'+
				'"'+printNotNull(c.Start_Date_Agency_Month__c)+'",'+
				'"'+printNotNull(c.Start_Date_Agency_Year__c)+'",'+
				'"'+printNotNull(c.Start_Date_Industry__c)+'",'+


				(pack1=='Geography in Travel Planning'||pack2=='Geography in Travel Planning' ? '"true",' : '"",')+
				(pack1=='Destination Geography'||pack2=='Destination Geography' ? '"true",' : '"",')+
				(pack1=='Serving the Travel & Tourism Customer'||pack2=='Serving the Travel & Tourism Customer' ? '"true",' : '"",')+
				(pack1=='Introduction to BSPLink'||pack2=='Introduction to BSPLink' ? '"true",' : '"",')+
				(pack1=='Le service au client voyageur'||pack2=='Le service au client voyageur' ? '"true",' : '"",')+
				(pack1=='Selling International Rail Transportation'||pack2=='Selling International Rail Transportation' ? '"true"' : '"",')+



				'"","",'+
				(idc==null ? '"",' : '"' +printNotNull(idc.Valid_To_Date__c)+'"')+
				'\r\n';

	}



	/*
	public void UpdateFromContact(Contact c){
		this.c = c;
		return;
	}
	*/
	public Contact ProxyToContact(boolean copyId){
		return c.clone(copyId,true,true,true);
	}



	public string getUniqueId(){
		return c.FirstName+'-'+c.LastName+'-'+c.Date_of_Birth__c+'-'+IATACode;
	}

	public static string getUniqueId(Contact c){
		return c.FirstName+'-'+c.LastName+'-'+c.Date_of_Birth__c+'-'+c.IATA_Code__c;
	}

	public string getUniqueIdPreviousIATAcode(){
		return c.FirstName+'-'+c.LastName+'-'+c.Date_of_Birth__c+'-'+previousIATACode;
	}


	public static string getUniqueQuery(Contact c){
		string d = c.Date_of_Birth__c.year() +'-'+ (c.Date_of_Birth__c.month()<10 ? '0':'') + c.Date_of_Birth__c.month()+'-'+(c.Date_of_Birth__c.day()<10?'0':'')+c.Date_of_Birth__c.day();
		return '(FirstName=\''+clean(c.FirstName)+'\' AND LastName=\''+clean(c.LastName)+'\'  AND Date_of_Birth__c='+d+')';
	}

	public static string clean(string s){ return s.replaceAll('\\\\','').replaceAll('\'','\\\\\'');}

   /* public static void initCSVLoadingFromCSVHeader(List<string> header){
		Set<String> fieldsToBeFilled = new Set<String>();
		FieldsNameToCSVIndex = new map<String,Integer>();

		for(integer i=0; i<header.size(); i++){
			string field = header[i];
			if(fieldsToBeFilled.contains(field))
				FieldsNameToCSVIndex.put(field,i);
			else
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The column '+field+' was not recognized and it will be ignored'));
		}

	}
	*/



	private string printNotNull(Object obj){
		if(obj==null)return '';
		try{
			Date d = Date.valueOf(obj);
			return d.year()+'-'+d.month()+'-'+d.day();
		}catch(Exception e){}
		return String.valueOf(obj);
	}

}

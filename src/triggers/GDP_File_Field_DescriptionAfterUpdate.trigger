trigger GDP_File_Field_DescriptionAfterUpdate on GDP_File_Fields_Description__c (after insert, after Update, before Delete)
{
	final String ACCOUNTVIEW = 'GDP_Products_Account_View';
	class Xml_field{
		public string fieldname {get;set;}
		public string fieldtype {get;set;}
		public string objectname {get;set;}
		public string section {get;set;}
		public Xml_field()
		{

		}

	}
	class Xml_format{
		public string objectname {get;set;}
		public string section {get;set;}
		public string groupname {get;set;}
		public boolean unbounded {get;set;}
		public Map<string,Xml_field> fieldlist {get;set;}
		public Xml_format()
		{
			this.objectname='';
			this.unbounded=false;
			this.section='';
			this.fieldlist = new Map<string,Xml_field>();
		}
		public String xmlstructure()
		{
			if (fieldlist.size()==0) return '';
			String xmlcontent='';
			string substructure ='[1]';
			if (this.unbounded) substructure = '[n]';
			for(String fieldkey:fieldlist.KeySet())
			{
				Xml_field fieldstructure = (Xml_field) fieldlist.get(fieldkey);
				xmlcontent  += '\n'+this.groupname +'.'+ fieldstructure.objectname +'.' + substructure + '.' + fieldstructure.fieldname;

			}
			return xmlcontent;

		}
		public String xmlfield(integer tabnumber)
		{
			if (fieldlist.size()==0) return '';
			string tabs='\n\t';
			if (tabnumber==2) tabs = '\n\t\t';
			Set<String> fieldset = new Set<String>();
			fieldset = fieldlist.KeySet();
			String fieldpkey='';
			for(String fieldkey:fieldset) {fieldpkey=fieldkey; break;}
			Xml_field fieldheader = (Xml_field) fieldlist.get(fieldpkey);
			string xmlcontent = '';
			xmlcontent  =tabs +'<!-- definition of complex elements for "'+fieldheader.objectname+'"-->';
			xmlcontent +=tabs +'<xs:element name="'+fieldheader.objectname+'"';
			if (this.unbounded) xmlcontent +='  maxOccurs="unbounded"';
			xmlcontent +='>';
			xmlcontent +=tabs +'\t<xs:complexType>';
			xmlcontent +=tabs +'\t\t<xs:sequence>';

			for(String fieldkey:fieldset)
			{
				 Xml_field fieldstructure = (Xml_field) fieldlist.get(fieldkey);
				xmlcontent  +=tabs +'\t\t\t<xs:element name="'+fieldstructure.fieldname+'" type="xs:'+fieldstructure.fieldtype+'"/>';

			}
			xmlcontent +=tabs +'\t\t</xs:sequence>';
			xmlcontent +=tabs +'\t</xs:complexType>';
			xmlcontent +=tabs +'</xs:element>';
			return xmlcontent;

		}
	}

	//This trigger will build the Select Clause for the parent object
	//set of ids to be populated with unique ids from
	Set<Id> FileDescriptionIds = new Set<Id>();
	if (Trigger.isDelete){ //TODO: IS Deleted does not work, the delete trigger does not update correctly the parent object
		 for (GDP_File_Fields_Description__c ffd : Trigger.old){
			FileDescriptionIds.add(ffd.GDP_File_Description__c);
		}
	}
	else{
		for (GDP_File_Fields_Description__c ffd : Trigger.new){
			FileDescriptionIds.add(ffd.GDP_File_Description__c);
		}
	}
	Map<Id, GDP_File_Description__c> FileDescriptionIdMap = new Map<Id, GDP_File_Description__c>();
	for (GDP_File_Description__c FD : [Select id
											, Field_Object_Name__c
											, Field_Filter_Value__c
											, Field_Filter__c
											, Field_API__c
											, Field_Visible__c
											, Field_Type__c
											, Field_Label__c
											, Field_Length__c
											, Field_Hidden_Columns__c
											, XSD_Schema__c
											, Field_Xml_Structure__c
											, Field_Xml_Hidden__c
											, Field_Xml_Name__c
											, Field_Xml_Group__c
											, Field_Txt_Hidden__c
									   FROM GDP_File_Description__c
									   Where id in:FileDescriptionIds])
		FileDescriptionIdMap.put(FD.id, FD);

	list<GDP_File_Description__c> GDP_FD_list = new list<GDP_File_Description__c>();

	for(id fdId : FileDescriptionIds){
		string[] FieldDescriptionLabelLengthType=
		new List<String> { '', '', '', '', '', '', '', '', '', '','', '', '','', '', '','','', '', '', '', '', '', '',''};

		List<GDP_File_Fields_Description__c> fieldlist= new List<GDP_File_Fields_Description__c>();
		integer i=0;
		fieldlist = [Select API_Name__c
							,GDP_File_Description__c
							,Filter_Field_API_Name__c
							,Filter_Field_Value__c
							,API_Object_Name__c
							,Target__c
							,Name__c
							,Type__c
							,Size__c
							,Visible__c
							,Hidden_Column__c
							,Xml_Name__c
							,Xml_Hidden_Column__c
							,Txt_Hidden_Column__c
							,Xml_Group__c
						 From GDP_File_Fields_Description__c
						 Where GDP_File_Description__c = :fdId
							 Order by Target__c, Position__c];
		string delimiter='|';
		for(GDP_File_Fields_Description__c FileFields :fieldlist ){
			 delimiter='|';
			 if (i==0) delimiter='';
			 if (FileFields.Target__c==null) FileFields.Target__c='Agency';
			 FieldDescriptionLabelLengthType[1] += delimiter + (FileFields.Name__c==null? '':FileFields.Name__c).Trim();
			 FieldDescriptionLabelLengthType[2] += delimiter + (FileFields.Type__c==null? '':FileFields.Type__c).Trim();
			 FieldDescriptionLabelLengthType[3] += delimiter + String.ValueOf(FileFields.Size__c).Trim();
			 FieldDescriptionLabelLengthType[4] += delimiter + (FileFields.API_Name__c==null? '':FileFields.API_Name__c).Trim();
			 FieldDescriptionLabelLengthType[5] += delimiter + (FileFields.Visible__c ? '1':'0');
			 FieldDescriptionLabelLengthType[6] += delimiter + (FileFields.Filter_Field_API_Name__c==null? '':FileFields.Filter_Field_API_Name__c).Trim();
			 FieldDescriptionLabelLengthType[7] += delimiter + (FileFields.Filter_Field_Value__c==null? '':FileFields.Filter_Field_Value__c).Trim();
			 FieldDescriptionLabelLengthType[8] += delimiter + (FileFields.API_Object_Name__c==null? '':FileFields.API_Object_Name__c).Trim();
			 FieldDescriptionLabelLengthType[9] += delimiter + (FileFields.Target__c==null? '':FileFields.Target__c).Trim();
			 FieldDescriptionLabelLengthType[10] += delimiter + (FileFields.Hidden_column__c ? '1':'0');
			 FieldDescriptionLabelLengthType[11] += delimiter + (FileFields.Xml_Hidden_Column__c? '1':'0');
			 FieldDescriptionLabelLengthType[12] += delimiter + (FileFields.Xml_Name__c==null? '':FileFields.Xml_Name__c).Trim();
			 FieldDescriptionLabelLengthType[13] += delimiter + (FileFields.Xml_Group__c==null? '':FileFields.Xml_Group__c).Trim();
			 FieldDescriptionLabelLengthType[14] += delimiter + (FileFields.Txt_Hidden_Column__c? '1':'0');
			 i++;

			 if (FileFields.Target__c=='Agency') FieldDescriptionLabelLengthType[0] += delimiter + FileFields.API_Name__c;


		 }

		GDP_File_Description__c GDP_FD= new GDP_File_Description__c();
		GDP_FD.id = fdId;
		//Pas besoin car sujet a erreur
		//if(ConcatenatedListOfAPI_Names.length() >2)
		//    ConcatenatedListOfAPI_Names = ConcatenatedListOfAPI_Names.left(ConcatenatedListOfAPI_Names.length()-2);

		//GDP_FD.Select_Clause__c = ConcatenatedListOfAPI_Names;
		i=1;
		GDP_FD.Field_Label__c = FieldDescriptionLabelLengthType[i];
		i++;
		GDP_FD.Field_Type__c = FieldDescriptionLabelLengthType[i];
		i++;
		GDP_FD.Field_Length__c = FieldDescriptionLabelLengthType[i];
		i++;
		GDP_FD.Field_API__c = FieldDescriptionLabelLengthType[i];
		i++;
		GDP_FD.Field_Visible__c = FieldDescriptionLabelLengthType[i];
		i++;
		GDP_FD.Field_Filter__c = FieldDescriptionLabelLengthType[i];
		i++;
		GDP_FD.Field_Filter_Value__c = FieldDescriptionLabelLengthType[i];
		i++;
		GDP_FD.Field_Object_Name__c = FieldDescriptionLabelLengthType[i];
		i++;
		GDP_FD.Field_Group__c = FieldDescriptionLabelLengthType[i];
		i++;
		GDP_FD.Field_Hidden_Columns__c = FieldDescriptionLabelLengthType[i];
		i++;
		GDP_FD.Field_Xml_Hidden__c = FieldDescriptionLabelLengthType[i];
		i++;
		GDP_FD.Field_Xml_Name__c = FieldDescriptionLabelLengthType[i];
		i++;
		GDP_FD.Field_Xml_Group__c = FieldDescriptionLabelLengthType[i];
		i++;
		GDP_FD.Field_Txt_Hidden__c = FieldDescriptionLabelLengthType[i];

		//Build the XSD Schema per object

		Map<String, Xml_format> objectschema = new Map<String,Xml_format>();
		Set<String> GroupSet = new Set<String>();
		for(GDP_File_Fields_Description__c FileFields :fieldlist ){
			string fieldname =(FileFields.Name__c==null? '':FileFields.Name__c).Trim();
			if (FileFields.Xml_Hidden_Column__c) continue;
			if (fieldname=='Reserve') continue;
			if (fieldname=='ReserveAirline') continue;
			string groupname =FileFields.Target__c;
			string xmlgroup =(FileFields.Xml_Group__c==null? '':FileFields.Xml_Group__c);
			string fieldtype =(FileFields.Type__c==null? '':FileFields.Type__c).Trim();
			string objectname=(FileFields.API_Object_Name__c==null? '':FileFields.API_Object_Name__c).Trim().Replace('__c','');
			string filtername=(FileFields.Filter_Field_API_Name__c==null? '':FileFields.Filter_Field_API_Name__c).Trim().Replace('__c','');
			string filtervalue=(FileFields.Filter_Field_Value__c==null? '':FileFields.Filter_Field_Value__c).Trim().Replace('__c','');
			string xmlname=(FileFields.Xml_Name__c==null? '':FileFields.Xml_Name__c).Trim();
			if (xmlname!='') fieldname=xmlname;


			if (xmlgroup!='' ) objectname=xmlgroup;
			if (fieldtype=='Date YYYYMMDD') fieldtype='String';
			Xml_format newschema= new Xml_format();
			if (objectschema.ContainsKey(groupname+objectname))
			{
				newschema = (Xml_format) objectschema.get(groupname+objectname);
				if (newschema.fieldlist.ContainsKey(fieldname)) newschema.unbounded=true;
				if (!newschema.unbounded)
				{
					Xml_field fieldxml  = new Xml_field();
					fieldxml.fieldname  = fieldname;
					fieldxml.objectname = objectname;
					fieldxml.fieldtype  = fieldtype;
					newschema.fieldlist.put(fieldname, fieldxml);
					objectschema.put(groupname+objectname,newschema);
				}

			}
			else{

				Xml_field fieldxml  = new Xml_field();
				fieldxml.fieldname  = fieldname;
				fieldxml.objectname = objectname;
				fieldxml.fieldtype  = fieldtype;
				newschema.groupname = groupname;
				newschema.objectname = objectname;
				newschema.fieldlist.put(fieldname,fieldxml);
				objectschema.put(groupname+objectname,newschema);
			}
		}
		//Build Entire Schema

		string complexschema='';
		string startschema ='';
		String finalschema ='';
		startschema +='\n<?xml version="1.0" encoding="UTF-8" ?>';
		startschema +='\n<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">';
		startschema +='\n<xs:element name="Agency">';
		String fieldxmlstructure = '';
		boolean airlineflag=false;
		for(String key:objectschema.KeySet())
		{

			Xml_format schemastring=objectschema.get(key);
			if (schemastring.groupname=='Airline') airlineflag=true;
			if (schemastring.groupname!='Agency') continue;
			startschema  += schemastring.xmlfield(1);
			fieldxmlstructure+= schemastring.xmlstructure();
		}
		if (airlineflag){
			startschema +='\n\t<xs:element name="Airline" maxOccurs="unbounded">';
			for(String key:objectschema.KeySet())
			{

				Xml_format schemastring=objectschema.get(key);
				if (schemastring.groupname!='Airline') continue;
				startschema  += schemastring.xmlfield(2);
				fieldxmlstructure+= schemastring.xmlstructure();
			}
			startschema +='\n\t</xs:element>';
		}
		startschema +='\n</xs:element>';
		finalschema = startschema + complexschema +'\n</xs:schema>';
		GDP_FD.XSD_Schema__c = finalschema;
		//identify if the value is Single or Multiple
		//
		String newxmlstructure='';
		String kvalue='';
		i=0;
		for(GDP_File_Fields_Description__c FileFields :fieldlist ){
			delimiter='|';
			if (i==0) delimiter='';
			string fieldname =(FileFields.Name__c==null? '':FileFields.Name__c).Trim();

			string groupname =FileFields.Target__c;
			string xmlgroup =(FileFields.Xml_Group__c==null? '':FileFields.Xml_Group__c);
			string objectname=(FileFields.API_Object_Name__c==null? '':FileFields.API_Object_Name__c).Trim().Replace('__c','');
			string xmlname=(FileFields.Xml_Name__c==null? '':FileFields.Xml_Name__c).Trim();
			if (xmlname!='') fieldname=xmlname;
			if (xmlgroup!='' ) objectname=xmlgroup;
			string key = groupname+'.'+objectname+ '.[1].'+fieldname;
			kvalue='0';
			if (fieldxmlstructure.IndexOf(key)>=0) kvalue ='0';
			key = groupname+'.'+objectname+ '.[n].'+fieldname;
			if (fieldxmlstructure.IndexOf(key)>=0) kvalue ='1';

			newxmlstructure += delimiter + kvalue;
			i++;

		}
		GDP_FD.Field_Xml_Structure__c = newxmlstructure;
		GDP_FD_list.add(GDP_FD);

	}

	update GDP_FD_list;

}

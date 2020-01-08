public  class AmazonXMLParser {


		public class ListBucketResult {

				public String Name {get;set;}
				public String Prefix;
				public String Marker;
				public String NextMarker;
				public Integer MaxKeys;
				public String Delimiter;
				public Boolean IsTruncated;
				public ListEntry[] Contents;
		 	public PrefixEntry[] CommonPrefixes;

		}

			public class PrefixEntry {
				public String Prefix;
			}


	 public class Owner{

				public String ID;
				public String DisplayName;

	 }

	public class ListEntry {

				public String Key {get;set;}
				public DateTime LastModified {get;set;}
				public String ETag {get;set;}
				public Double Size {get;set;}
				public Owner Owner {get;set;}
				public String StorageClass {get;set;}

		}




		public ListBucketResult parseBucketCont(XmlStreamReader reader){

					ListBucketResult listBuckets = new ListBucketResult();
					boolean isSafeToGetNextXmlElement = true;

				while(reader.hasNext()) {


								if (reader.getEventType() == XmlTag.START_ELEMENT) {

										 string localName = reader.getLocalName();
										 if ('Name' == localName ) {
																				reader.next();
																				if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
																				 listBuckets.name  =reader.getText();
																				 }

															 }

										 else if ('Prefix' == localName ) {
																				reader.next();
																				if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
																				 listBuckets.Prefix=reader.getText();
																				 }

															 }
										 else   if ('Marker' == localName ) {
																				reader.next();
																				if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
																				 listBuckets.Marker=reader.getText();
																				 }

															 }
									else   if ('NextMarker' == localName ) {
																				reader.next();
																				if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
																				 listBuckets.NextMarker=reader.getText();
																				 }

															 }
									else    if ('MaxKeys' == localName ) {
																				reader.next();
																				if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
																				 listBuckets.MaxKeys= Integer.valueOF(reader.getText());
																				 }

															 }
									else   if ('Delimiter' == localName ) {
																				reader.next();
																				if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
																				 listBuckets.Delimiter=reader.getText();
																				 }

															 }
									else  if ('IsTruncated' == localName ) {
																				reader.next();
																				if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
																				 listBuckets.IsTruncated=boolean.valueOf(reader.getText());
																				 }

															 }
									else   if ('Contents' == localName ) {
																				reader.next();
																				// to be doneif(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
																				 listBuckets.Contents =parseListEntry(reader);
																				// }

															 }
									 else   if ('CommonPrefixes' == localName ) {
																				reader.next();
																				// to be doneif(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
																				 listBuckets.CommonPrefixes =parsePrefixes(reader);
																				// }

															 }
								}



					reader.next();
				}
				return listBuckets;

	}

		public list<PrefixEntry> parsePrefixes (XmlStreamReader reader){

			list<PrefixEntry> PrefixEntries = new list<PrefixEntry>();

			PrefixEntry PrefixEntry = new PrefixEntry();


			 while(reader.hasNext()) {
									if (reader.getEventType() == XmlTag.END_ELEMENT &&  'CommonPrefixes' == reader.getLocalName()) {

										return PrefixEntries;

									} else if (reader.getEventType() == XmlTag.END_ELEMENT &&  'Prefix' == reader.getLocalName()) {
											 PrefixEntries.add(PrefixEntry);
											 PrefixEntry = new PrefixEntry();

									}else  if (reader.getEventType() == XmlTag.START_ELEMENT) {


							string localName = reader.getLocalName();
										 	if ('Prefix' == localName ) {
																				reader.next();
																				if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
																				 PrefixEntry.Prefix=reader.getText();
																				 }

															 }

									}

						reader.next();
					}

			 return null ;



		}

	public list<ListEntry> parseListEntry (XmlStreamReader reader){

			 list<ListEntry>ListEntries = new list<ListEntry>();

				boolean isSafeToGetNextXmlElement = true;
				ListEntry ListEntry = new ListEntry();

				while(reader.hasNext()) {

								if (reader.getEventType() == XmlTag.END_ELEMENT &&  'Contents' == reader.getLocalName()) {
										 ListEntries.add(ListEntry);
																			//   throw new transformationException(''+ ListEntry);

										 ListEntry = new ListEntry();
								}else  if (reader.getEventType() == XmlTag.START_ELEMENT) {

										 string localName = reader.getLocalName();
										 if ('Key' == localName ) {
																				reader.next();
																				if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
																				 ListEntry.Key=reader.getText();
																				 }

															 }
										else if ('LastModified' == localName ) {
																				reader.next();
																				if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){

																				 string dateXML = reader.getText();
																					ListEntry.LastModified =  dateTime.newInstance(Integer.ValueOf(dateXML.substring(0,4)),//YEAR
																																					 Integer.ValueOf(dateXML.substring(5,7)),//MONTH
																																					 Integer.ValueOf(dateXML.substring(8,10)),//day
																																					 Integer.ValueOf(dateXML.substring(11,13)),//hour
																																					 Integer.ValueOf(dateXML.substring(14,16)),//minute
																																					 Integer.ValueOf(dateXML.substring(17,19))//second
																																					 );

																				 }

															 }
								else   if ('ETag' == localName ) {
																				reader.next();
																				if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
																				 ListEntry.ETag=reader.getText();
																				 }

															 }
									else  if ('Owner' == localName ) {
																				reader.next();
																				ListEntry.Owner=parseOwner(reader);

															 }
								 else   if ('StorageClass' == localName ) {
																				reader.next();
																				if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
																				 ListEntry.StorageClass=reader.getText();
																				 }

															 }
									else if ('Size' == localName ) {
																				reader.next();
																				if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
																				 ListEntry.Size=Double.valueOf(reader.getText());
																				 }

															 }
									else if ('Key' == localName ) {
																				reader.next();
																				if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
																				 ListEntry.Key=reader.getText();
																				 }

															 }

							}

				 reader.next();
				}

		 return ListEntries ;

	}

		public Owner parseOwner (XmlStreamReader reader){


						boolean isSafeToGetNextXmlElement = true;
						Owner Owner = new Owner();

						while(reader.hasNext()) {

							if (reader.getEventType() == XmlTag.END_ELEMENT &&  'Owner' == reader.getLocalName()) {
												return Owner ;

										}
							 else if (reader.getEventType() == XmlTag.START_ELEMENT) {
														 string localName = reader.getLocalName();
												 if ('ID' == localName ) {
																						reader.next();
																						if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
																						 owner.ID=reader.getText();
																						 }

																	 }
							 			else  if ('DisplayName' == localName ) {
																						reader.next();
																						if(reader.getEventType() == XmlTag.CHARACTERS && reader.HasText()){
																						 owner.DisplayName=reader.getText();
																						 }

																	 }
										}


					 reader.next();
						}

				 return null;
		}


}
		 /*

				AmazonRest demo = new AmazonRest();

				String str = '<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Name>sfdc-ifap-dev-23ea0b9fb2a21f7f</Name><Prefix>IFAP/</Prefix><Marker></Marker><MaxKeys>1000</MaxKeys><Delimiter>IFAP/</Delimiter><IsTruncated>false</IsTruncated><Contents><Key>IFAP/FinancialDocuments/500110000069W0HAAU/a.pdf</Key><LastModified>2015-07-29T14:57:38.000Z</LastModified><ETag>&quot;573e4f7531b6442d4c433568f22a12c1&quot;</ETag><Size>79751</Size><Owner><ID>e18db9b8fe5497707f9898c0757cd504274323d97f61502a3a5d1208e58bb5ff</ID><DisplayName>iataawsnonprod</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>IFAP/FinancialDocuments/50011000006kn5PAAQ/a.pdf</Key><LastModified>2015-07-29T14:10:56.000Z</LastModified><ETag>&quot;573e4f7531b6442d4c433568f22a12c1&quot;</ETag><Size>79751</Size><Owner><ID>e18db9b8fe5497707f9898c0757cd504274323d97f61502a3a5d1208e58bb5ff</ID><DisplayName>iataawsnonprod</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>IFAP/FinancialDocuments/50011000006kn5PAAQ/b.pdf</Key><LastModified>2015-07-29T14:21:08.000Z</LastModified><ETag>&quot;7c036d8798fc8faf177e961a0be0d300&quot;</ETag><Size>79751</Size><Owner><ID>e18db9b8fe5497707f9898c0757cd504274323d97f61502a3a5d1208e58bb5ff</ID><DisplayName>iataawsnonprod</DisplayName></Owner><StorageClass>STANDARD</StorageClass></Contents></ListBucketResult>';

				XmlStreamReader reader = new XmlStreamReader(str);
				AmazonRest.ListBucketResult ListBucketResult = demo.parseBucketCont(reader);

				System.debug(ListBucketResult);

				 */





	/* not used for now but maybe in the future
		public class PutObject_element {
				public String Bucket;
				public String Key;
				public S3.MetadataEntry[] Metadata;
				public Double ContentLength;
				public S3.AccessControlList AccessControlList;
				public String StorageClass;
				public String AWSAccessKeyId;
				public DateTime Timestamp;
				public String Signature;
				public String Credential;
		}

		public class PutObjectInline_element {
				public String Bucket;
				public String Key;
				public S3.MetadataEntry[] Metadata;
				public String Data;
				public Integer ContentLength;
				public S3.AccessControlList AccessControlList;
				public String StorageClass;
				public String AWSAccessKeyId;
				public DateTime Timestamp;
				public String Signature;
				public String Credential;
		}

		public class GetObject_element {
				public String Bucket;
				public String Key;
				public Boolean GetMetadata;
				public Boolean GetData;
				public Boolean InlineData;
				public String AWSAccessKeyId;
				public DateTime Timestamp;
				public String Signature;
				public String Credential;
		}

		public class ListAllMyBuckets_element {
				public String AWSAccessKeyId;
				public DateTime Timestamp;
				public String Signature;
		}

		 public class PutObjectResult {
				public String ETag;
				public DateTime LastModified;
		 }

		public class CreateBucketResponse_element {
				public S3.CreateBucketResult CreateBucketResponse;
		 }
		public class DeleteBucket_element {
				public String Bucket;
				public String AWSAccessKeyId;
				public DateTime Timestamp;
				public String Signature;
				public String Credential;
		}
			public class Status {
				public Integer Code {get;set;}
				public String Description {get;set;}
			}*/

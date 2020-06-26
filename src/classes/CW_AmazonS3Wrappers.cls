@SuppressWarnings('PMD')
public class CW_AmazonS3Wrappers {
	public class ListObjectsV2Output {
		public Boolean IsTruncated { get; set; }
		public List<Contents> Contents { get; set; }
		public String Name { get; set; }
		public String Prefix { get; set; }
		public String Delimiter { get; set; }
		public Integer MaxKeys { get; set; }
		public List<CommonPrefixes> CommonPrefixes { get; set; }
		public String EncodingType { get; set; }
		public Integer KeyCount { get; set; }
		public String ContinuationToken { get; set; }
		public String NextContinuationToken { get; set; }
		public String StartAfter { get; set; }
	}
	public class Contents {
		public String ETag { get; set; }
		public String Key { get; set; }
		public Datetime LastModified { get; set; }
		public Owner Owner { get; set; }
		public Integer Size { get; set; }
		public String StorageClass { get; set; }
	}
	public class CommonPrefixes {
		public String Prefix { get; set; }
	}
	public class Owner {
		public String DisplayName { get; set; }
		public String ID { get; set; }
	}

	public class ErrorResponse {
		public String Code { get; set; }
		public String Message { get; set; }
	}

	public static CW_AmazonS3Wrappers.ListObjectsV2Output parseListObjectsV2Output(XmlStreamReader reader) {
		CW_AmazonS3Wrappers.ListObjectsV2Output parsedItem = new ListObjectsV2Output();
		parsedItem.Contents = new List<CW_AmazonS3Wrappers.Contents>();
		parsedItem.CommonPrefixes = new List<CW_AmazonS3Wrappers.CommonPrefixes>();

		Boolean isSafeToGetNextXmlElement = true;
		while (isSafeToGetNextXmlElement) {
			if (reader.isStartElement()) {
				switch on reader.getLocalName() {
					when 'IsTruncated' {
						reader.next();
						if (reader.isCharacters()) {
							parsedItem.IsTruncated = boolean.valueOf(reader.getText());
						}
					}
					when 'Contents' {
						parsedItem.Contents.add(parseContents(reader));
					}
					when 'Name' {
						reader.next();
						if (reader.isCharacters() && reader.HasText()) {
							parsedItem.Name = reader.getText();
						}
					}
					when 'Prefix' {
						reader.next();
						if (reader.isCharacters() && reader.HasText()) {
							parsedItem.Prefix = reader.getText();
						}
					}
					when 'Delimiter' {
						reader.next();
						if (reader.isCharacters() && reader.HasText()) {
							parsedItem.Delimiter = reader.getText();
						}
					}
					when 'MaxKeys' {
						reader.next();
						if (reader.isCharacters() && reader.HasText()) {
							parsedItem.MaxKeys = Integer.valueOf(reader.getText());
						}
					}
					when 'CommonPrefixes' {
						parsedItem.CommonPrefixes.add(parseCommonPrefixes(reader));
					}
					when 'EncodingType' {
						reader.next();
						if (reader.isCharacters() && reader.HasText()) {
							parsedItem.EncodingType = reader.getText();
						}
					}
					when 'KeyCount' {
						reader.next();
						if (reader.isCharacters() && reader.HasText()) {
							parsedItem.KeyCount = Integer.valueOf(reader.getText());
						}
					}
					when 'ContinuationToken' {
						reader.next();
						if (reader.isCharacters() && reader.HasText()) {
							parsedItem.ContinuationToken = reader.getText();
						}
					}
					when 'NextContinuationToken' {
						reader.next();
						if (reader.isCharacters() && reader.HasText()) {
							parsedItem.NextContinuationToken = reader.getText();
						}
					}
					when 'StartAfter' {
						reader.next();
						if (reader.isCharacters() && reader.HasText()) {
							parsedItem.StartAfter = reader.getText();
						}
					}
				}
			}

			if (reader.hasNext()) {
				reader.next();
			} else {
				isSafeToGetNextXmlElement = false;
				break;
			}
		}
		return parsedItem;
	}

	private static CW_AmazonS3Wrappers.Contents parseContents(System.XmlStreamReader reader) {
		String localNameStopper = reader.getLocalName();

		CW_AmazonS3Wrappers.Contents parsedItem = new CW_AmazonS3Wrappers.Contents();
		Boolean isSafeToGetNextXmlElement = true;
		while (isSafeToGetNextXmlElement) {
			if (reader.isEndElement() && reader.getLocalName() == localNameStopper) {
				return parsedItem;
			} else if (reader.isStartElement()) {
				switch on reader.getLocalName() {
					when 'ETag' {
						reader.next();
						if (reader.isCharacters() && reader.hasText()) {
							parsedItem.ETag = reader.getText();
						}
					}
					when 'Key' {
						reader.next();
						if (reader.isCharacters() && reader.hasText()) {
							parsedItem.Key = reader.getText();
						}
					}
					when 'LastModified' {
						reader.next();
						if (reader.isCharacters() && reader.hasText()) {
							String timestamp8601 = String.format('"{0}"', new List<String>{ reader.getText() });
							parsedItem.LastModified = (Datetime) JSON.deserialize(timestamp8601, Datetime.class);
						}
					}
					when 'Owner' {
						parsedItem.Owner = parseOwner(reader);
					}
					when 'Size' {
						reader.next();
						if (reader.isCharacters() && reader.hasText()) {
							parsedItem.Size = Integer.valueOf(reader.getText());
						}
					}
					when 'StorageClass' {
						reader.next();
						if (reader.isCharacters() && reader.hasText()) {
							parsedItem.StorageClass = reader.getText();
						}
					}
				}
			}

			if (reader.hasNext()) {
				reader.next();
			} else {
				isSafeToGetNextXmlElement = false;
				break;
			}
		}
		return parsedItem;
	}

	private static CW_AmazonS3Wrappers.Owner parseOwner(System.XmlStreamReader reader) {
		String localNameStopper = reader.getLocalName();

		CW_AmazonS3Wrappers.Owner parsedItem = new CW_AmazonS3Wrappers.Owner();
		Boolean isSafeToGetNextXmlElement = true;
		while (isSafeToGetNextXmlElement) {
			if (reader.isEndElement() && reader.getLocalName() == localNameStopper) {
				return parsedItem;
			} else if (reader.isStartElement()) {
				switch on reader.getLocalName() {
					when 'DisplayName' {
						reader.next();
						if (reader.isCharacters() && reader.HasText()) {
							parsedItem.DisplayName = reader.getText();
						}
					}
					when 'ID' {
						reader.next();
						if (reader.isCharacters() && reader.HasText()) {
							parsedItem.ID = reader.getText();
						}
					}
				}
			}

			if (reader.hasNext()) {
				reader.next();
			} else {
				isSafeToGetNextXmlElement = false;
				break;
			}
		}
		return parsedItem;
	}

	private static CW_AmazonS3Wrappers.CommonPrefixes parseCommonPrefixes(System.XmlStreamReader reader) {
		String localNameStopper = reader.getLocalName();

		CW_AmazonS3Wrappers.CommonPrefixes parsedItem = new CW_AmazonS3Wrappers.CommonPrefixes();
		Boolean isSafeToGetNextXmlElement = true;
		while (isSafeToGetNextXmlElement) {
			if (reader.isEndElement() && reader.getLocalName() == localNameStopper) {
				return parsedItem;
			} else if (reader.isStartElement()) {
				switch on reader.getLocalName() {
					when 'Prefix' {
						reader.next();
						if (reader.isCharacters() && reader.HasText()) {
							parsedItem.Prefix = reader.getText();
						}
					}
				}
			}

			if (reader.hasNext()) {
				reader.next();
			} else {
				isSafeToGetNextXmlElement = false;
				break;
			}
		}

		return parsedItem;
	}

	public static CW_AmazonS3Wrappers.ErrorResponse parseError(XmlStreamReader reader) {
		CW_AmazonS3Wrappers.ErrorResponse parsedItem = new CW_AmazonS3Wrappers.ErrorResponse();

		Boolean isSafeToGetNextXmlElement = true;
		while (isSafeToGetNextXmlElement) {
			if (reader.isStartElement()) {
				switch on reader.getLocalName() {
					when 'Code' {
						reader.next();
						if (reader.isCharacters()) {
							parsedItem.Code = reader.getText();
						}
					}
					when 'Message' {
						reader.next();
						if (reader.isCharacters() && reader.HasText()) {
							parsedItem.Message = reader.getText();
						}
					}
				}
			}

			if (reader.hasNext()) {
				reader.next();
			} else {
				isSafeToGetNextXmlElement = false;
				break;
			}
		}
		return parsedItem;
	}
}
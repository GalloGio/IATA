public class CW_AmazonS3Connector {
	private static String generateQuery(Map<String, String> queryParamsMap) {
		List<String> queryParams = new List<String>();
		for (String currentKey : queryParamsMap.keySet()) {
			queryParams.add(currentKey + '=' + EncodingUtil.urlEncode(queryParamsMap.get(currentKey), 'UTF-8'));
		}
		queryParams.sort();
		return String.join(queryParams, '&');
	}

	/**
	 * @description		List objects from Amazon S3. Documentation: https://docs.aws.amazon.com/AmazonS3/latest/API/API_ListObjectsV2.html
	 * @param			queryParams			KeyValue pair to perform the request. Check allowed params in Amazon documentation
	 * @param			namedCredential		Named Credential configured in Salesforce to use in Amazon S3 requests
	 * @return			Returns some or all (up to 1,000) of the objects in a bucket.
	 */
	public static HttpResponse awsS3ListObjectsV2(Map<String, String> queryParams, String namedCredential) {
		queryParams.put('list-type', '2');

		String query = generateQuery(queryParams);
		if (query.length() > 0) {
			query = '?' + query;
		}

		// Generate request
		HttpRequest request = new HttpRequest();
		request.setMethod('GET');
		request.setEndpoint('callout:' + namedCredential + '/' + query);

		Http http = new Http();
		HttpResponse response = http.send(request);

		return response;
	}

	/**
	 * @description		List objects from Amazon S3. Documentation: https://docs.aws.amazon.com/AmazonS3/latest/API/API_ListObjectsV2.html
	 * @param			queryParams			KeyValue pair to perform the request. Check allowed params in Amazon documentation
	 * @param			namedCredential		Named Credential configured in Salesforce to use in Amazon S3 requests
	 * @return			Returns some or all (up to 1,000) of the objects in a bucket.
	 */
	public static AmazonXMLParser.ListBucketResult listObjectsV2(Map<String, String> queryParams, String namedCredential) {
		HttpResponse response = awsS3ListObjectsV2(queryParams, namedCredential);
		XmlStreamReader reader = new XmlStreamReader(response.getBody());
		return new AmazonXMLParser().parseBucketCont(reader);
	}

	/**
	 * @description		Retrieves objects from Amazon S3. Documentation: https://docs.aws.amazon.com/AmazonS3/latest/API/API_GetObject.html
	 * @param			objectKey			Key of the object to get
	 * @param			namedCredential		Named Credential configured in Salesforce to use in Amazon S3 requests
	 * @return			Returns Http Response from S3
	 */
	public static HttpResponse awsS3GetObject(String objectKey, String namedCredential) {
		// Generate request
		HttpRequest request = new HttpRequest();
		request.setMethod('GET');
		request.setEndpoint('callout:' + namedCredential + '/' + objectKey);

		Http http = new Http();
		HttpResponse response = http.send(request);
		return response;
	}

	/**
	 * @description		Converts the url resource stored in Amazon S3 to its Object Key
	 * @param			url 	Url to resource
	 * @param			bucket	bucket where resource is stored
	 * @return			Return the object key. Null if url is invalid
	 */
	public static String convertUrlResourceToS3ObjectKey(String url, String bucket) {
		if (!url.startsWithIgnoreCase('https://') || !url.containsIgnoreCase(bucket)) {
			return null;
		}

		return url.substring(url.indexOf(('/'), url.indexOf(bucket)) + 1);
	}
}
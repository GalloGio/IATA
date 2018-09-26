/**

		Project: eCommerce Enhancements
	       File: IEC_CookieStore.cls
	Description: Cookie Management for arbitrary content size.
	     Author: blue-infinity sa
	    History: aosantos, 2017-06-20, Initial Release.


	Detailed description:
		This class will abstract and manage a named store by cookies, allowing the
	abstraction of reading/writing the cookies and mantaining the needed implementation
	structure to allow the storage of an arbirtrary string of up-to 80K characters.

		A JSON string or a custom string implementing an arbirtrary data set will
	be managed by this class.

		Public Methods:

			Create the cookie store:
				IEC_CookieStore cookie = new IEC_CookieStore(
					'sampleCookieName',
					null, 					-- use the / path if null specified
					86400, 					-- this represents 1 day of age for the cookie,
					false 					-- cookie is not secure
				);

			Store some content to the store:
				cookie.storeContent('This is my longgggg string of any kind.');

			Retrieve some content from the store:
				String content = cookie.retrieveContent();

			Clear the content on the store:
				cookie.clearContent();

	--


	Reference: http://browsercookielimits.squawky.net

	Typically, the following are allowed:
	300 cookies in total
	4096 bytes per cookie
	20 cookies per domain
	81920 bytes per domain*
	
	- * Given 20 cookies of max size 4096 = 81920 bytes. 

	Cookies are stored as a single string containing name, value, expiry etc.
	Size limits apply to the entire cookie, not just its value.
	If you use characters only in the ASCII range, each character takes 1 byte, so you can typically store 4096 characters
	In UTF-8 some characters are more than 1 byte, hence you can not store as many characters in the same amount of bytes.
	The ';' character is reserved as a separator. Do not use it in the key or value.
	jQuery Cookie plugin stores the cookie using encodeURIComponent. Hence ÿ is stored as %C3%BF, 6 characters. This works well, as other you would lose the ';' character
	You cannot delete cookies with a key that hits the size limit and has a small value. The method to delete a cookie is to set its expiry value, but when the key is large there is not enough room left to do this. Hence I have not tested limitations around key size.
	It appears that some browsers limit by bytes, while others limit the number of characters.

*/
public without sharing class IEC_CookieStore {
	private String storeName;
	private String path;
	private Integer maxAge;
	private Boolean isSecure;

	private static final Integer MAX_COOKIE_SIZE = 4000;

	/**
		Constructor.

		If maxAge is -1 then this is considered a Session Cookie.

	*/
	public IEC_CookieStore(String storeName, String path, Integer maxAge, Boolean isSecure) {
		this.storeName = storeName;
		this.path = path;
		this.maxAge = maxAge;
		this.isSecure = isSecure;
	}

	/**
		Store the argument content in the store.

	*/
	public void storeContent(String content) {
		List<String> contentBlocks = new List<String>();
		Integer contentBlockNo;
		Cookie[] cookies;
		Map<String,Cookie> cookieMap = ApexPages.currentPage().getCookies();

		if (content == null) {
			content = '';
		}

		if (content.length() > MAX_COOKIE_SIZE) {
			// split
			Integer blockNo;
			Integer offsetStart;
			Integer offsetEnd;
			Integer maxBlockNo;

			maxBlockNo = content.length() / MAX_COOKIE_SIZE;
			if (maxBlockNo * MAX_COOKIE_SIZE < content.length()) {
				maxBlockNo++;
			}

			for (blockNo = 1; blockNo <= maxBlockNo; blockNo++) {
				String blockContent;

				offsetStart = (blockNo - 1) * MAX_COOKIE_SIZE;
				offsetEnd = offsetStart + MAX_COOKIE_SIZE;

				if (offsetEnd > content.length()) {
					offsetEnd = content.length();
				}

				blockContent = content.substring(offsetStart, offsetEnd);

				contentBlocks.add(blockContent);
			}

			cookies = new Cookie[maxBlockNo];
		} else {
			contentBlocks.add(content);

			cookies = new Cookie[1];
		}

		contentBlockNo = -1;
		for (String contentBlock : contentBlocks) {
			String cookieName;
			Cookie cookie;

			contentBlockNo++;

			cookieName = storeName + '_' + (contentBlockNo + 1);

			cookie = new Cookie(cookieName, contentBlock, path, maxAge, isSecure);

			cookies[contentBlockNo] = cookie;
		}

		// Clear/Truncate additional cookies if size of content is decreasing
		Cookie[] deleteCookies;
		List<Cookie> deleteCookieList = new List<Cookie>();
		Cookie cookie;
		
		contentBlockNo++;
		do {

			String cookieName = storeName + '_' + (contentBlockNo + 1);

			if (cookieMap.containsKey(cookieName)) {
				cookie = new Cookie(cookieName, '', path, maxAge, isSecure);
				
				deleteCookieList.add(cookie);
			} else {
				cookie = null;
			}

			contentBlockNo++;
		} while (cookie != null);

		if (deleteCookieList.isEmpty() == false) {
			deleteCookies = new Cookie[deleteCookieList.size()];

			contentBlockNo = 0;
			for (Cookie deleteCookie : deleteCookieList) {
				deleteCookies[contentBlockNo++] = deleteCookie;
			}
		}
		
		if (cookies != null && cookies.size() > 0) {
			System.debug('createCookies: ' + cookies);

			ApexPages.currentPage().setCookies(cookies);
		}

		if (deleteCookies != null && deleteCookies.size() > 0) {
			System.debug('deleteCookies: ' + deleteCookies);

			ApexPages.currentPage().setCookies(deleteCookies);
		}
	}

	/**
		Retrieve the content from the store.

	*/
	public String retrieveContent() {
		String content = '';
		Integer contentBlockNo = 1;
		Map<String,Cookie> cookiesMap = ApexPages.currentPage().getCookies();
		Cookie cookie;

		System.debug('retrieveCookies: ' + cookiesMap.values());

		do {
			String cookieName = storeName + '_' + contentBlockNo;
			String blockContent;

			if (cookiesMap.containsKey(cookieName)) {
				cookie = cookiesMap.get(cookieName);

				blockContent = cookie.getValue();

				if (blockContent != null) {
					content += blockContent;
				}
			} else {
				cookie = null;
			}

			contentBlockNo++;
		} while (cookie != null);

		return content;
	}

	/**
		Clear the content on the store.

	*/
	public void clearContent() {
		Integer contentBlockNo = 1;
		Map<String,Cookie> cookiesMap = ApexPages.currentPage().getCookies();
		Cookie cookie;
		List<Cookie> cookieList = new List<Cookie>();
		Cookie[] cookies;

		do {
			String cookieName = storeName + '_' + contentBlockNo;

			if (cookiesMap.containsKey(cookieName)) {
				cookie = new Cookie(cookieName, '', path, maxAge, isSecure);

				cookieList.add(cookie);
			} else {
				cookie = null;
			}

			contentBlockNo++;
		} while (cookie != null);

		if (cookieList != null && cookieList.isEmpty() == false) {
			cookies = new Cookie[cookieList.size()];

			contentBlockNo = 0;
			for (Cookie zcookie : cookieList) {
				cookies[contentBlockNo++] = zcookie;
			}

			ApexPages.currentPage().setCookies(cookies);
		}
	}
}
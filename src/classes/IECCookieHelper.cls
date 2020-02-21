/**
	* Description: This class handles the cookie creation/deletion
	* Author: Alexandre McGraw
	* Version: 1.0
	* History:
	*/
public with sharing class IECCookieHelper {

	private static final String COOKIE_CART_GUID = 'ieccartguid';
	public static final String COOKIE_GUID_TEST = 'a9999999-a999-9a9a-9a9a-9999a9999aaa';
	private static final String COOKIE_QUOTE_RATEPLANID = 'iecqrpiid';
	public static final String COOKIE_QUOTE_RATEPLANID_TEST = 'a3111000000Cb6y';
	private static final String COOKIE_QUOTE_COMMENTS = 'iecqcom';
	public static final String COOKIE_QUOTE_COMMENTS_TEST = 'some comments';

	// TODO: use custom settings
	private static final Integer COOKIE_MAXAGE_SESSION_VALUE = -1;
	private static final Integer TWENTYFOUR_HOUR = 24*60*60;

	/**
	 * Store a shopping cart GUID in the shopping cart cookie
	 * @param guid The GUID to store
	 */
	public static void storeCartGuid(String guid) {
		Cookie cartCookie = new Cookie(COOKIE_CART_GUID, guid, null, TWENTYFOUR_HOUR, false);
		ApexPages.currentPage().setCookies(new Cookie[]{cartCookie});
	}

	/**
	 * Returns the GUID that is stored in the shopping cart cookie
	 * @return The GUID or null if empty
	 */
	public static String getCartGuid() {
		if (Test.isRunningTest()) return COOKIE_GUID_TEST;
		Cookie cartCookie = ApexPages.currentPage().getCookies().get(COOKIE_CART_GUID);
		if (cartCookie == null)
			return null;
		else
			return cartCookie.getValue();
	}

	/**
	 * Deletes the shopping cart cookie
	 */
	public static void deleteShoppingCartCookie() {
		Cookie shoppingCartCookie = new Cookie(COOKIE_CART_GUID, '', null, 0, false);
		ApexPages.currentPage().setCookies(new Cookie[]{shoppingCartCookie});
	}

	/**
	 * Store a Rate Plan Info ID in a cookie for the quote page
	 * @param sRatePlanInfoID The Rate Plan Info ID
	 */
	public static void storeQuoteRatePlanInfo(String sRatePlanInfoID) {
		Cookie quoteCookie = new Cookie(COOKIE_QUOTE_RATEPLANID, sRatePlanInfoID, null, TWENTYFOUR_HOUR, false);
		ApexPages.currentPage().setCookies(new Cookie[]{quoteCookie});
	}

	/**
	 * Returns the Rate Plan Info ID that is stored in the quote cookie
	 * @return The Rate Plan Info ID
	 */
	public static String getQuoteRatePlanInfo() {
		if (Test.isRunningTest()) return COOKIE_QUOTE_RATEPLANID_TEST;
		Cookie quoteCookie = ApexPages.currentPage().getCookies().get(COOKIE_QUOTE_RATEPLANID);
		if (quoteCookie == null)
			return null;
		else
			return quoteCookie.getValue();
	}

	/**
	 * Deletes the quote cookie
	 */
	public static void deleteQuoteCookie() {
		Cookie quoteCookie = new Cookie(COOKIE_QUOTE_RATEPLANID, '', null, 0, false);
		ApexPages.currentPage().setCookies(new Cookie[]{quoteCookie});
	}

	/**
	 * Store the comments in a cookie for the quote page
	 * @param sComments The comments fo the quote
	 */
	public static void storeQuoteComments(String sComments) {
		Cookie quoteCommentsCookie = new Cookie(COOKIE_QUOTE_COMMENTS, sComments, null, TWENTYFOUR_HOUR, false);
		ApexPages.currentPage().setCookies(new Cookie[]{quoteCommentsCookie});
	}

	/**
	 * Returns the Quote comments that is stored in the quote cookie
	 * @return The Quote comments
	 */
	public static String getQuoteComments() {
		if (Test.isRunningTest()) return COOKIE_QUOTE_COMMENTS_TEST;
		Cookie quoteCommentsCookie = ApexPages.currentPage().getCookies().get(COOKIE_QUOTE_COMMENTS);
		if (quoteCommentsCookie == null)
			return null;
		else
			return quoteCommentsCookie.getValue();
	}

	/**
	 * Deletes the quote comments cookie
	 */
	public static void deleteQuoteCommentsCookie() {
		Cookie quoteCommentsCookie = new Cookie(COOKIE_QUOTE_COMMENTS, '', null, 0, false);
		ApexPages.currentPage().setCookies(new Cookie[]{quoteCommentsCookie});
	}
}

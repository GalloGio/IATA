/**
 * Navigation methods to centralize navigation for the portal
 *
 */

/**
 * Fires an event to listeners.
 * @param {object} baseUrl - Pagereference object
 * @param {object} paramsObject - Object containing the parameters to be incapsulated
 */
const navigateToPage = (baseURl, paramsObject) => {
	let ret = [];
	for (let d in paramsObject) {
		ret.push(encodeURIComponent(d) + '=' + encodeURIComponent(paramsObject[d].replace(new RegExp('\\+', 'g'),' ')));
	}

	let url = baseURl;
	if(ret.length > 0) {
		url = url + (url.indexOf('?') > 0 ? '&' : '?') + ret.join('&');
	}

	window.location.href = url;
};

const getParamsFromPage = () => {
	let prmstr = window.location.search.substr(1).toString();

	//create a JSON string, replacing & with comma (and quotes) and = with colon (and quotes)
	// Also replacing the + sign with %20 so it can be properly converted in a space
	let	paramsMap = prmstr ? decodeURIComponent('{"' + prmstr.replace(new RegExp('&', 'g'), '","').replace(new RegExp('=', 'g'),'":"').replace(new RegExp('\\+', 'g'),'%20') + '"}') : '{}';

	//parsing the JSON string into an object
	return JSON.parse(paramsMap);
};

const getPageName = () => {
	return window.location.pathname.substring(window.location.pathname.lastIndexOf("/") + 1);
}

export {
	navigateToPage,
	getParamsFromPage,
	getPageName
};
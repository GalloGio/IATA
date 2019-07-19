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
    console.log('paramsObject', paramsObject);
    
    let ret = [];
    for (let d in paramsObject) { 
        ret.push(encodeURIComponent(d) + '=' + encodeURIComponent(paramsObject[d]));
    }
    
    let url = baseURl;
    if(ret.length > 0) {
        url = url + '?' + ret.join('&');
    }
    
    window.location.href = url;
};


const getParamsFromPage = () => {
    let prmstr = window.location.search.substr(1);

    let paramsReturn = {};

    if(prmstr !== undefined && prmstr !== null && prmstr !== ''){
        let prmarr = prmstr.split("&");
        for ( let i = 0; i < prmarr.length; i++) {
            let tmparr = prmarr[i].split("=");
            paramsReturn[tmparr[0]] = tmparr[1];
        }
    }

    return paramsReturn;
};

const getPageName = () => {
    return location.pathname.substring(location.pathname.lastIndexOf("/") + 1);

    }



export {
    navigateToPage,
    getParamsFromPage,
    getPageName
};
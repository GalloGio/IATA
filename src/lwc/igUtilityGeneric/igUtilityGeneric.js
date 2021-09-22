/**
 * Return a new array where it replaces an arrays element at {index} position with the {element} element
 * @param {array} array 
 * @param {number} index 
 * @param {any} element 
 */
const replaceArray = (array, index, element) =>
    [...array.slice(0, index), element, ...array.slice(index+1)];
    
/**
 * Return a new array where it removes the element at {index} position
 * @param {array} array 
 * @param {number} index 
 */
const removeArray = (array, index) =>
    [...array.slice(0, index), ...array.slice(index+1)];

/**
 * Return a new array without duplicates
 * @param {array} array 
 */
const uniqueArray = (array) => array.filter((val, index, arr) => arr.indexOf(val) === index);

const debugLog = function() {
    console.log(...arguments);
};

const debugError = function() {
    console.error(...arguments);
};

const objectToPicklist = (obj) => Object.keys(obj).map(key => ({ label: obj[key], value: key }));

const objectCountValues = (obj, getCountableValue) => {
    if (!getCountableValue) {
        getCountableValue = (val) => val;
    }
    const accumulator = (acc, val) => 
        Object.assign(acc, {[getCountableValue(val)]: acc[getCountableValue(val)]? acc[getCountableValue(val)]+1: 1});
    return Object.values(obj).reduce(accumulator, {});
};

const groupByContent = (data, getId, getName, getExtraData) => {
    let grouped = {};
    for (const element of data) {
        if (!getId(element)) continue;
        if (grouped[getId(element)]) {
            grouped[getId(element)].list.push(element);
        } else {
            grouped[getId(element)] = Object.assign({
                id: getId(element),
                list: [element]
            }, 
            getExtraData ? getExtraData(element) : {},
            getName ? { name: getName(element) } : {});
        }
    }
    return Object.values(grouped);
};

const flattenObjectRecursively = (object, getChilds, getObjectId, collection = {}) => {
    const childs = getChilds(object);
    if (childs && childs.length > 0) {
        for (const child of childs) {
            collection[getObjectId(child)] = child;
            flattenObjectRecursively(child, getChilds, getObjectId, collection);
        }
    }
    return collection;
}

const dateDayDifference = (dateFrom, dateTo) => {
    return Math.round(((dateTo ? new Date(dateTo) : new Date()) - dateFrom)/(1000*60*60*24));
};

const humanizeTimeSpan = (dateFrom, dateTo) => { 
    const spanLabels = [
        { ceiling: 60, text: "right now" },
        { ceiling: 3600, text: "$minutes minutes ago" },
        { ceiling: 86400, text: "$hours hours ago" },
        { ceiling: 2629744, text: "$days days ago" },
        { ceiling: 31556926, text: "$months months ago" },
        { ceiling: null, text: "$years years ago" }
    ];
    const timeUnits = [ 
        { unit: 'years', divisor: 99, seconds: 31556926},
        { unit: 'months', divisor: 12, seconds: 2629744},
        { unit: 'days', divisor: 30, seconds: 86400},
        { unit: 'hours', divisor: 24, seconds: 3600},
        { unit: 'minutes', divisor: 60, seconds: 60},
        { unit: 'seconds', divisor: 60, seconds: 1} 
    ];
    dateFrom = new Date(dateFrom);
    dateTo = dateTo ? new Date(dateTo) : new Date();
    const secondsDifference = (dateTo - dateFrom) / 1000;
    const dateFormat = spanLabels.find(span => span.ceiling == null || secondsDifference <= span.ceiling);
    const timeBreakdown = timeUnits.reduce((acc, unit) => 
        Object.assign(acc, {[unit.unit]: Math.floor(secondsDifference / unit.seconds) % unit.divisor})
    , {});
    const finalResult = dateFormat.text.replace(/\$(\w+)/g, (str, matchUnit) => timeBreakdown[matchUnit]);
    return finalResult;
};

const formatString = function (string, mergeFields) {
    Object.keys(mergeFields).forEach(field => string.replaceAll(`{${field}}`, mergeFields[field]));
    return string;
};

const debounce = (func, wait, immediate) => {
	let timeout;
	return function() {
		const context = this, args = arguments;
		const later = function() {
			timeout = null;
			if (!immediate) func.apply(context, args);
		};
		const callNow = immediate && !timeout;
		clearTimeout(timeout);
		timeout = setTimeout(later, wait);
		if (callNow) func.apply(context, args);
	};
};

const throttle = (func, limit) => {
    let lastFunc;
    let lastRan;
    return function() {
        const context = this;
        const args = arguments;
        if (!lastRan) {
            func.apply(context, args);
            lastRan = Date.now();
        } else {
            clearTimeout(lastFunc);
            lastFunc = setTimeout(function() {
                if ((Date.now() - lastRan) >= limit) {
                    func.apply(context, args);
                    lastRan = Date.now();
                }
            }, limit - (Date.now() - lastRan));
        }
    }
}

const getURLParameters = (parameter) => {
    const urlParams = window.location.search.slice(1).split('&').reduce((acc, val) => Object.assign(acc, {[val.split('=')[0]]: decodeURIComponent(val.split('=')[1])}), {});
    if (parameter === undefined) {
        return urlParams;
    } else {
        return urlParams[parameter];
    }
}

const util = {
    array: {
        remove: removeArray,
        replace: replaceArray,
        group: groupByContent,
        unique: uniqueArray,
    },
    debug: {
        error: debugError,
        log: debugLog,
    },
    object: {
        countValues: objectCountValues,
        toPicklist: objectToPicklist,
        flattenRecursivity: flattenObjectRecursively,
    },
    date: {
        humanizeSpan: humanizeTimeSpan,
        dayDifference: dateDayDifference
    },
    string: {
        format: formatString
    },
    urlParameters: {
        get: getURLParameters
    },
    throttle: throttle,
    debounce: debounce,
};

export { util }
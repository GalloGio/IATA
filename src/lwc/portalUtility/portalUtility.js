/**
 * Returns a function, that, as long as it continues to be invoked, will not
 * be triggered. The function will be called after it stops being called for
 * `wait` milliseconds if it is not immediate.
 * @param {function} func 
 * @param {number} wait 
 * @param {any} immediate
 */
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

const util = {
 debounce: debounce,
};

export { util }
({
    sortData : function(component,fieldName,sortDirection) {
        var data = component.get('v.data');
        var reverse = sortDirection == 'asc' ? 1: -1;
        var key = function(a) { return a[fieldName]}
        data.sort(function(a,b) {
            var a = key(a) ? key(a) : '';
            var b = key(b) ? key(b) : '';
            return reverse * ((a>b) - (b>a));
        });
        component.set('v.data', data);
    }
})

({
    doInit : function(component, event, helper) {
        var concatedValues = component.get("v.concatedValues");
        var options = [];
        if(!$A.util.isEmpty(concatedValues)){
            var entries = concatedValues.split(';');
            entries.forEach(function(entry){
                var splittedEntry = entry.split(':');
                var option = {
                    label : splittedEntry[1],
                    value : splittedEntry[0]
                };
                options.push(option);
            });
        }
        component.set("v.options", options);
    }
})
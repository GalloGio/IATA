({
     openStep: function(cmp, step) {
         var section = 'section'+step;
        var sec = cmp.find(section);
         
        if(! $A.util.hasClass(sec, "slds-is-open")) {
            $A.util.removeClass(cmp.find('section1'), 'slds-is-open');
            $A.util.removeClass(cmp.find('section2'), 'slds-is-open');
            $A.util.removeClass(cmp.find('section3'), 'slds-is-open');
            $A.util.toggleClass(sec, 'slds-is-open');
        }
        cmp.set("v.activeSection", step);
     }
})
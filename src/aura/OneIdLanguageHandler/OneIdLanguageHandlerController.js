({
	doInit: function(component, evt, helper){
        console.log('helper.doInit.Begin');
        
        helper.initialize(component);
        
        console.log('Helper.doInit.End');
    },

	onLanguageChange : function(cmp, evt, helper) {
        var selectLangInput = cmp.find("InputSelectLanguage");
        var newLang = selectLangInput.get("v.value");
        
        console.log('Controller.onLanguageChange: '+newLang);

        //Change  current Language
        helper.changeLanguage(cmp, newLang);
    },
})
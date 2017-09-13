/**
 * @description javascript Controller for Language Handler
 *              lightning component
 *
 *
 * @creation  2017-04-04
 * @category  JS Controller
 * @package   LanguageHandler
 * @author    Paulo Bastos <paulo.bastos@rightitservices.com>
 * @copyright 2017 Rightit Services
 * @license   Copyright Rightit Services.
 *            All rights reserved.
 *            Reproduction in whole or part is
 *            prohibited without written consent of
 *            the copyright owner.
 * @link      http://www.rightitservices.com
 */
 ({
	doInit: function(component, evt, helper){
        console.log('helper.doInit.Begin');
        
        helper.initialize(component);
        
        console.log('helper.doInit.End');
    },

	onLanguageChange : function(cmp, evt, helper) {
        var selectLangInput = cmp.find("InputSelectLanguage");
        var newLang = selectLangInput.get("v.value");
        
        console.log('Controller.onLanguageChange: '+newLang);

        //Change  current Language
        helper.changeLanguage(cmp, newLang);
    },
})
import getTranslatedLabels from '@salesforce/apex/MFA_LoginFlowController.getMetadataLabelsByLanguage';
import { getParamsFromPage } from 'c/navigationUtils';

/**
 * @description Method to retrieve the active language established on params
 * @returns Active language set on parameter "language"
 */
function getLangFromURL(){
	var pageParams = getParamsFromPage();
	var selectedLang;
	if(pageParams !== undefined && pageParams.language !== undefined){
		selectedLang = pageParams.language;
	}else if(pageParams.retURL !== undefined){
		let languageResult = pageParams.retURL.match(/language=(.*)&/g);
		if(languageResult){
			selectedLang = languageResult[0].replace('language=', '').replace('&', '');
		}else{
			languageResult = pageParams.retURL.match(/language=(.*)/g);
			if(languageResult){
				selectedLang = languageResult[0].replace('language=', '');
			}else{
				selectedLang = 'en_US';
			}
		}
	}

	if(!selectedLang){
		selectedLang = 'en_US';
	}

	return selectedLang;
}

/**
 * @description Method to retrieve all the labels translated to the active language
 * @returns Translations for the language specified
 */
const getTranslations = () => {
	var language = getLangFromURL();
	return getTranslatedLabels({ lang: language });
}

const labelUtil = {
	getTranslations: getTranslations,
};

export { labelUtil }

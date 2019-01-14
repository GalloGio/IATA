public class LabelTranslator {
     
    public  String translate(String labelName, String language){

        String labelValue =  '';
        Pagereference r = Page.LabelTranslator;
        r.getParameters().put('label_lang', language);
        r.getParameters().put('label', labelName);  
        if(!Test.isRunningTest()){
            labelValue = r.getContent().toString();
        }else{
            labelValue = '<TAG>TEST<TAG>';
        }
        System.debug('labelValue ' + labelValue.substringBetween('<TAG>'));
        
        return labelValue.substringBetween('<TAG>');    
	}
    

}
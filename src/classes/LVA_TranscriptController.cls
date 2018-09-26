public class LVA_TranscriptController {
    private Integer MAX_LENGTH = 110;
    public LiveChatTranscript lva{get;set;}
    public LVA_TranscriptController(){
        try{
            lva=new LiveChatTranscript();
            Id lvaID = ApexPages.currentPage().getParameters().get('id');
            lva = [select body from LiveChatTranscript where id=:lvaID];
            
            String [] splitedBody = lva.body.split('<br>');
            
            for(Integer i = 0; i<splitedBody.size();i++){
                if(!splitedBody[i].contains('http://') && !splitedBody[i].contains('https://')){
                    if(!splitedBody[i].startsWithIgnoreCase('<p align="center">') && !splitedBody[i].endsWithIgnoreCase('</p>')){
                        if(splitedBody[i].length()>MAX_LENGTH){
                            lva.body = lva.body.replaceAll('\n','<br/>'); 
                            lva.body = lva.body.replace(splitedBody[i], splitedBody[i].replaceAll('(.{' + MAX_LENGTH + '})', '$1<br/>') + '<br>') ;
                            
                        } else if(String.isNotBlank(splitedBody[i])){
                            lva.body = lva.body.replace(splitedBody[i],splitedBody[i] + '<br>');
                        }
                    }
                } else {
                    if(splitedBody[i].length()>MAX_LENGTH){
                        String[] urlStr = splitedBody[i].split(' ');
                        
                        for(Integer j = 0; j<urlStr.size(); j++){
                            if((urlStr[j].startsWithIgnoreCase('http://') || urlStr[j].startsWithIgnoreCase('https://'))){
                                
                                String link = '<a href="' + urlStr[j] + '">link</a>';
                                
                                lva.body = lva.body.replace(splitedBody[i], splitedBody[i].replace(urlStr[j], link) + '<br/>' );
                            }
                        }
                    }
                }
            }
        }catch(Exception e){
            System.debug('lva ' + e.getMessage());
        }
    }
}
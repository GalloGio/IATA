dynamicallyLoadScript('//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js');
dynamicallyLoadScript('//ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js');

function displayKeyCustomerAlert(targetURL, popupTitle, popupText, newWindow) {	
	jQuery(function() {
		//Append the jQuery CSS CDN Link to the Head tag.
		jQuery('head').append('<link rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css"/>');

		//Create the HTML(DIV Tag) for the Dialog.
		var html = '<dialog id = "keyAlert"><div id="dialog" title="' + popupTitle + '">';
		html += '<div style="float: left; width: 30%; padding-top: 3%;"><img src="/resource/1552412186000/keyCustomerIcon" width="60px" height="60px"></div>';
		html += '<div style="float: left; width: 70%;">' + popupText + '</div>';
        html += '<button id = "ok"> OK </button></div></dialog>';

		//Check if the Dialog(DIV Tag) already exists if not then Append the same to the Body tag.
		if(!jQuery('[id=dialog]').size()){
			jQuery('body').append(html);
		}

		var dialog  = document.getElementById('keyAlert');
        var button = document.getElementById('ok');
        button.addEventListener('click', function(){
            if(targetURL != null) {
                goToURL(targetURL, newWindow);
            }
            dialog.close('keyAlert');
        });
        
        dialog.showModal();
	});
};

function goToURL(redirectUrl, newWindow) {
    if (sforce.console.isInConsole()) {
        sforce.console.getEnclosingTabId(function(enclosingResult){
            sforce.console.getEnclosingPrimaryTabId(function(primaryResult){
                sforce.console.openSubtab(primaryResult.id, redirectUrl, true, '', null);
            });
        });
    } else {
		if(newWindow == true) {
			var win = window.open(redirectUrl, '_blank');
			win.focus();
		}
		else {
			window.top.location.href = redirectUrl;
		} 
    }
};

function getEligibleCaseRTs() {
	var result = sforce.connection.query("Select Record_Type__c From Case_RTs_for_Key_Customer_alert__c");
    var results = result.getArray("records");

    var rt_names = [];
    
    if(results) {
        for(var i=0; i < results.length; i++) {
            rt_names.push(results[i].Record_Type__c);
        }
    }
	
    return rt_names;
}

function dynamicallyLoadScript(url) {
    var script = document.createElement("script"); 
    script.src = url;
    document.head.appendChild(script);
}
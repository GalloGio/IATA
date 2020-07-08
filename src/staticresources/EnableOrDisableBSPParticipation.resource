dynamicallyLoadScript('//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js');
dynamicallyLoadScript('//ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js');
dynamicallyLoadScript('//ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js');

function displayKeyCustomerAlert(popupTitle, disableText, enableText, userText, btEnable, btDisable, mYAccountID) {	
	jQuery(function() {
		//Append the jQuery CSS CDN Link to the Head tag.
		jQuery('head').append('<link rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css"/>');

		//Create the HTML(DIV Tag) for the Dialog.
		var html = '<div id="dialog" style="text-align:center;" title="' + popupTitle + '">';


		html += '<div id="putMessage"></div>';

		html += '</div>';


		//Check if the Dialog(DIV Tag) already exists if not then Append the same to the Body tag.
		if(!jQuery('[id=dialog]').size()){
			jQuery('body').append(html);
		}

		var userPermission = sforce.apex.execute("BSPParticipationManager","checkUserPermissionsBSPParticipation",{accountID:mYAccountID});
		if(userPermission[0] == 'true'){	
			var enableOrDisable = sforce.apex.execute("BSPParticipationManager","checkEnableOrDisableBSPParticipation",{accountID:mYAccountID});
			if(enableOrDisable[0] == 'true'){	
				//Open the jQuery Dialog.
				jQuery("#dialog").dialog({
					//position: ['center', 200],
					autoOpen: true,
					width: 370,
					modal: true,
					buttons:
							[{
								text: btDisable,
								click: function() {
									if(mYAccountID){
										var agency = sforce.apex.execute("BSPParticipationManager","disableBSPParticipation",{accountID:mYAccountID});
										if(agency != null){
											jQuery(this).dialog("close");
											document.location.reload(true);
										}
									}
								}
							}]
				});
				jQuery("#dialog").text(disableText);
			}else{
			//Open the jQuery Dialog.
				jQuery("#dialog").dialog({
					//position: ['center', 200],
					autoOpen: true,
					width: 370,
					modal: true,
					buttons:
							[{
								text: btEnable,
								click: function() {
									var agency = sforce.apex.execute("BSPParticipationManager","enableBSPParticipation",{accountID:mYAccountID});
									if(agency != null){
										jQuery(this).dialog("close");
										document.location.reload(true);
									}
								}
							}]
				})
				jQuery("#dialog").text(enableText);	
			}
		}else{
			jQuery("#dialog").dialog({
				//position: ['center', 200],
				autoOpen: true,
				width: 370,
				modal: true,
			});
			jQuery("#dialog").text(userText);
		}


		jQuery("#dialog").css("min-height", "");
	});
};


function dynamicallyLoadScript(url) {
    var script = document.createElement("script"); 
    script.src = url;
    document.head.appendChild(script);
}

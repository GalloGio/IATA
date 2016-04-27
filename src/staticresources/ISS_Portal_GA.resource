//	This javascript tags file downloads and external links in Google Analytics.
//	You need to be using the Google Analytics New Tracking Code (ga.js) 
//	for this script to work.
//	To use, place this file on all pages just above the Google Analytics tracking code.
//	All outbound links and links to non-html files should now be automatically tracked.
//
//	This script has been provided by Goodwebpractices.com
//	Thanks to ShoreTel, MerryMan and Colm McBarron
//
//	www.goodwebpractices.com
//	VKI has made changes as indicated below.	
//  Fix to ignore JavaScript in hrefs by Adviso
//Version cross domain + social media tracking v1

if (document.getElementsByTagName) 
{
	//valeur a remplacer par les liens des pages des reseaux sociaux à tracker
	var SocialMediaLinks=[''];
	
	
	 
	// Initialize external link handlers
	var hrefs = document.getElementsByTagName("a");
	for (var l = 0; l < hrefs.length; l++) 
	{
	 	var link = hrefs[l];
		var href = link.href;
	
		try
		{

			//protocol, host, hostname, port, pathname, search, hash
			if (hrefs[l].protocol == "mailto:") 
			{
			
				startListening(hrefs[l],"mousedown",trackMailto);
				// Fix to ignore JavaScript in hrefs and ignore links without href
			} else if (!hrefs[l].href.match(/^javascript:/) && hrefs[l].href) {
					startListening(hrefs[l],"mousedown",trackOutFileLinks);
			}
		}
		catch(e)
		{
			continue;
		}
	}
}

function startListening (obj,evnt,func) 
{
	if (obj.addEventListener) 
	{
			 obj.addEventListener(evnt,func,false);
	} else if (obj.attachEvent) {
			 obj.attachEvent("on" + evnt,func);
	}
}

function trackMailto (evnt) 
{  

	var href = (evnt.srcElement) ? evnt.srcElement.href : this.href;
  var category = 'Mailto';
  var action = (href.substring(7).split("\?"))[0]; 
  //on prend le lien a partir du 7 eme caractere puis on le coupe en plusieurs partie en fonction du caractere ? et on prend la premiere partie
  var label = document.location.pathname;

 ga(function() {

  ga('send', 'event', category, action, label);
	})
}

function trackOutFileLinks (evnt) 
{
	var e = (evnt.srcElement) ? evnt.srcElement : this;
	while (e.tagName != "A") 
	{
		e = e.parentNode;
	}

	var lnk = (e.pathname.charAt(0) == "/") ? e.pathname : "/" + e.pathname;
	if (e.search && e.pathname.indexOf(e.search) == -1) lnk += e.search;
  var category = '';
  var action = '';
  var label = document.location.pathname;
 
  if(e.hostname != location.host) 
  {
	
	
     i=0;
	 isSocialLink=false;
	 isExternalDocumentLink=lnk.match(/\.(?:doc|eps|jpg|png|gif|jpeg|svg|xls|ppt|pdf|xls|zip|txt|vsd|vxd|js|css|rar|exe|wma|mov|avi|wmv|mp3|rss)($|\&|\?)/);

	 re=new RegExp("^(http\:\/\/|https\:\/\/)");
	 FullLink=e.href;
	 FullLink=FullLink.replace(re,"");
	 
	 while(i<SocialMediaLinks.length)
	 {
		SocialMediaLinks[i]=SocialMediaLinks[i].replace(re,"");
		if(SocialMediaLinks[i]==FullLink)
		{
			isSocialLink=true;
		}
		i++;
	 }
	if(isExternalDocumentLink)
	{
		category = "Fichiers externes";
		action = e.hostname + lnk;
	}
	else if(isSocialLink)
	{
		category = "Liens externes - Médias sociaux";
		action = e.hostname + lnk;
		
	} else
	{
		category = "Liens externes";
		action = e.hostname + lnk;
	}	
    
  } else if(lnk.match(/\.(doc|xls|ppt|pdf|xls|zip|txt|vsd|vxd|js|css|rar|exe|wma|mov|avi|wmv|mp3|rss)($|\&|\?)/)) 
  {
    var matches = lnk.match(/([^\/]*\.(doc|xls|ppt|pdf|xls|zip|txt|vsd|vxd|js|css|rar|exe|wma|mov|avi|wmv|mp3|rss))(?:$|\&|\?)/);
    category = "File";
    action = matches[1];  
  } else if(lnk.match(/\.(eps|jpg|png|svg|gif|jpeg)($|\&|\?)/)) 
  {
    var matches = lnk.match(/([^\/]*\.(eps|jpg|png|svg|gif|jpeg))(?:$|\&|\?)/);
    category = "Image";
    action = matches[1];  
  }
  
   ga(function() {
	
   ga('send', 'event', category, action, label);
   
   });
}

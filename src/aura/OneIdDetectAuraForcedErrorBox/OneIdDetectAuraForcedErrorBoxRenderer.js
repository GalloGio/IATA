({
	afterRender : function(cmp,helper){
        console.log("detecting error");
        
        var a = document.querySelector(".auraForcedErrorBox");
        console.log("after render");
        if(a){
            console.log("calling render");
            var errorlabel = $A.get("$Label.c.OneId_InternetExplorer_NotSupported");
            //alert(errorlabel);
            //
            var div = document.createElement('div');
            div.style.width = "100%";
            div.style.height ="50px";
            div.style.backgroundColor = "#0a4279";
            div.style.textAlign ="center";
            div.style.color="white";
            div.innerHTML = '<span style="line-height:50px">'+errorlabel+'</span>';
            document.body.appendChild(div);
        }
    }
})
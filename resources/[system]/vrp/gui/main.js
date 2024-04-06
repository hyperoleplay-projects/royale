window.addEventListener("load",function(){
	errdiv = document.createElement("div");
	if (true){
		errdiv.classList.add("console");
		document.body.appendChild(errdiv);
		window.onerror = function(errorMsg,url,lineNumber,column,errorObj){
			errdiv.innerHTML += '<br />Error: ' + errorMsg + ' Script: ' + url + ' Line: ' + lineNumber + ' Column: ' + column + ' StackTrace: ' +  errorObj;
		}
	}

	var wprompt = new WPrompt();
	var requestmgr = new RequestManager();

	requestmgr.onResponse = function(id,ok){ $.post("http://vrp/request",JSON.stringify({ act: "response", id: id, ok: ok })); }
	wprompt.onClose = function(){ $.post("http://vrp/prompt",JSON.stringify({ act: "close", result: wprompt.result })); }

	window.addEventListener("message",function(evt){
		var data = evt["data"];

		if(data["act"] == "cfg"){
			cfg = data["cfg"]
		}

		if(data["act"] == "prompt"){
			wprompt.open(data["title"],data["text"]);
		}

		if(data["act"] == "request"){
			requestmgr.addRequest(data["id"],data["text"],data["time"]);
		}

		if(data["act"] == "event"){
			if(data["event"] == "Y"){
				requestmgr.respond(true);
			}
			else if(data["event"] == "U"){
				requestmgr.respond(false);
			}
		}

		if (data["death"] == true){
			$("#deathScreen").fadeIn()
		}

		if (data["death"] == false){
			$("#deathScreen").fadeOut()
		}

		if (data["deathtext"] !== undefined) {
			$("#deathScreen").html(data["deathtext"]);
		}

		if (data["wanted"] == true){
			if($("#wantedDiv").css("display") === "none"){
				$("#wantedDiv").css("display","block");
			}
		}

		if (data["wanted"] == false){
			if($("#wantedDiv").css("display") === "block"){
				$("#wantedDiv").css("display","none");
			}
		}

		if (data["wantedTime"] !== undefined){
			// $("#wantedDiv").html("As autoridades estão a sua procura, aguarde <b>"+parseInt(data["wantedTime"])+" segundos</b> até tudo se acalme.");
		}
	});
});
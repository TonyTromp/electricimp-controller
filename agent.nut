server.log("Say: " + http.agenturl() );

const html= @"<!DOCTYPE html>
<html lang=""en"">
<head>
<meta charset=""utf-8"">
<meta name=""description"" ""content"">
<meta name=""author"" ""content"">
<link rel=stylesheet href=""http://cdn.jsdelivr.net/foundation/5.0.2/css/normalize.css"">
<link rel=stylesheet href=""http://cdn.jsdelivr.net/foundation/5.0.2/css/foundation.min.css"">
<script language=""javascript"">
pinconfig = [
     {""name"":""switch-a"",""on"":""a1""}
    ,{""name"":""switch-b"",""on"":""b1""}
    ];
function UpdateSwitch() {
    var hardware = new Array();
    for (i=0;i<pinconfig.length;i++) {
        hardware[i] = (($('input[name='+ pinconfig[i].name +']:checked').attr('id') == pinconfig[i].on) ? 1 : 0);
    }
    return {""hardware"": {""pin"": hardware}};
}
function postBackJSON(cmd, jsonobject) {    
        $.ajax({
              type: ""POST"",                                
              url: ""?cmd=""+cmd, 
              data: JSON.stringify(jsonobject) ,
              contentType: ""application/json; charset=utf-8"",
              dataType: ""json"", 
              complete: function(jqXHR, textStatus){
                _header= jqXHR.getResponseHeader(""AgentResponce"");
              }
          }) .done(function( data ) {
                if (data!=null) {
                    if (data.callback=='getInfo') {
                        alert('GetInfo::Pin1: '+data.hardware.pin[0]);
                        alert('GetInfo::Pin2: '+data.hardware.pin[1]);
                    }
                }

          });
        }
</script>
</head>
<body>
<nav class=top-bar data-topbar>
<ul class=title-area>
<li class=name>
<h1><a href=#>Electric Imp</a></h1>
</li>
</ul>
<section class=top-bar-section>
<ul class=right>
<li class=has-dropdown>
<a href=#>Projects</a>
<ul class=dropdown>
<li><a href=""Javascript:postBackJSON('get')"">To be done</a></li>
</ul>
</li>
<li class=active><a href=#>Configurator</a></li>
<li><a href=https://ide.electricimp.com/ide>IDE</a></li>
<li><a href=https://electricimp.com/docs/>Documentation</a></li>
</ul>
<ul class=left>
<li><img src=http://moopz.com/assets_c/2012/05/electric-imp-logo-thumb-48x48-124239.png /></li>
</ul>
</section>
</nav>
<section role=main>
<div class=""large-9 medium-8 columns"">
<h1>Online Configurator</h1>
<h3 class=subheader>This application let you interact with your Electronic Imp online.</h3>
<hr/>
<p>
Changes are effective immediately using asynchronous (AJAX) callbacks to the Agent. Please ensure your Electric Imp is running correctly before applying any modifications. If you dont know what your doing please consult our online guide for configuring your Electronic Imp manually.
<div class=row>
<div class=""small-12 columns"" style=""border-top:#ececec 1px solid""></div>
</div>
<div class=row style=background-color:#fefefe>
<div class=""small-4 columns""><h6>#</h6></div>
<div class=""small-4 columns""><h6>Digital</h6></div>
<div class=""small-4 columns""><h6>Analog</h6></div>
</div>
<div class=row>
<div class=""small-12 columns"" style=""border-top:#ececec 1px solid""></div>
</div>
<br>
<div class=row>
<div class=""small-4 columns subheader"">Pin.1</div>
<div class=""small-4 columns"">
<div class=""switch small round subheader"" style=width:100px>
<input id=a name=switch-a type=radio checked onclick=""Javascript:postBackJSON('set',UpdateSwitch());"">
<label for=a class=""subheader"">Low</label>
<input id=a1 name=switch-a type=radio onclick=""Javascript:postBackJSON('set',UpdateSwitch());"">
<label for=a1 onclick>High</label>
<span></span>
</div>
</div>
<div class=""small-4 columns"" style=text-align:top><input type=text placeholder=voltage /></div>
</div>
<br/>
<div class=row>
<div class=""small-4 columns subheader"">Pin.2</div>
<div class=""small-4 columns"">
<div class=""switch small round"" style=width:100px>
<input id=""b"" name=""switch-b"" type=radio checked onclick=""Javascript:postBackJSON('set',UpdateSwitch());"">
<label for=b class=""subheader"">Low</label>
<input id=""b1"" name=""switch-b"" type=radio onclick=""Javascript:postBackJSON('set',UpdateSwitch());"" />
<label for=b1 class=""subheader"">High</label>
<span></span>
</div>
</div>
<div class=""small-4 columns"" style=text-align:top><input type=text placeholder=voltage /></div>
</div>
<br/>
<div class=row>
<div class=""small-12 columns"" style=""border-top:#ececec 1px solid""></div>
</div>
<br>
<div class=row>
<div class=""small-12 columns"" align=right>
<a href=# class=""tiny button success round"" style=width:100px>Done</a>
</div>
</div>
</p>
</div>
</section>
<script src=http://cdn.jsdelivr.net/foundation/5.0.2/js/jquery.js></script>
<script src=http://cdn.jsdelivr.net/foundation/5.0.2/js/foundation.min.js></script>
<script>
 $(document).foundation();
</script>
</body>
</html>";


function requestHandler(request, response) {
  server.log("Request Received");
  if (!device.isconnected()) {
      response.send(200, "IMP NOT CONNECTED!");
      return;
  }
  try {
    // check if the user sent led as a query parameter
    if ("cmd" in request.query) {
        device.on("callback", function(jsonobj) {
            response.send(200, http.jsonencode(jsonobj));
        });
        switch (request.query["cmd"]) {
            case "set":
                device.send("setPins", http.jsondecode(request.body));                
                break;
            case "get":
                 device.send("getInfo", request.query["cmd"]);
                break;
            default:
                 response.send(200, "Parameter value incorrect. Please use cmd=set or cmd=get");
                break;    
        }
    } else {
        server.log("200 - NO CMD SET, Sending GUI");
        response.send(200, html);
    }
  } catch (ex) {
    server.log("500 - Internal Server Error");
    response.send(500, "Internal Server Error: " + ex);
  }
}

// register the HTTP handler
http.onrequest(requestHandler);

 
device.onconnect(function() {
    server.log("Device connected to Agent");
});
 
device.ondisconnect(function() {
    server.log("Device disconnected from Agent");
});


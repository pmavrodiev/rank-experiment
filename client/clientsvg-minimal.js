(function(){var v=window,f=function(){this.windowWidth=window.innerWidth;this.windowHeight=window.innerHeight;this.buttonNext=document.getElementById("next");this.buttonNextText=document.getElementsByClassName("nextbuttontext")[0];this.buttonPrevious=document.getElementById("previous");this.instructionsText=document.getElementById("instructions");this.circleCanvasDiv=document.getElementById("circleCanvasDiv");this.instructionsDiv=document.getElementById("instructionsDiv");this.gameTextDiv=document.getElementById("gameTextDiv");
this.gameText=document.getElementById("gameText");this.gameTextWebSymbols=document.getElementsByClassName("websymbols")[0];this.compositeG=document.getElementById("svgCanvas");this.circleCanvas=document.getElementById("circleCanvas");this.majorCircle=document.getElementById("majorCircle");this.targetCircle=document.getElementById("targetCircle");this.rememberTargetCircle=this.circleCanvas.createSVGPoint();this.currentGuess=document.getElementById("currentGuess");this.angleLine=document.getElementById("angleLine");
this.rankText=document.getElementById("rankText");this.loaderIndex=0;this.loaderSymbols="01234567".split("");this.loaderRate=100;this.loadmetimer=null;this.maxGameRounds=0;this.instructionVector=[];this.instructionIndex=0;this.gameMode="";this.nextLevel=0;this.currentRank="";this.zoom_scale=0.1;this.zoom_level=0;this.previous_angle=Math.PI/2;this.isMacWebKit=-1!==navigator.userAgent.indexOf("Macintosh")&&-1!==navigator.userAgent.indexOf("WebKit");this.isFirefox=-1!==navigator.userAgent.indexOf("Firefox");
this.isBuggyFirefox=-1!==navigator.userAgent.indexOf("Firefox/13.0.1");this.serverURL="http://129.132.133.54:8080/";this.registered=!1;this.flip=0;this.isFirefox?window.load=this.windowListen():window.addEventListener("onload",this.windowListen(),!1)};f.prototype.windowListen=function(){var m,j,k,e,n,g,o,f,s,p,q,h,l,t,u,i,r,a=this;n=function(b){var c;c=a.circleCanvas.createSVGPoint();c.x=b.clientX;c.y=b.clientY;b=a.compositeG.getScreenCTM();return c.matrixTransform(b.inverse())};l=function(b,c){var d;
d=null;$.ajax({url:b,accepts:"*/*",contentType:"text/html",crossDomain:!0,context:a,type:"POST",data:c,async:!1,complete:function(b,c){"error"===c?(alert("Cannot connect to server"),clearTimeout(a.loadmetimer)):"success"!==c?(alert("Network problems "+c),clearTimeout(a.loadmetimer)):-1!==b.responseText.indexOf("inprogress")?(alert("Sorry, the game has already started"),a.gameMode=!1):-1!==b.responseText.indexOf("finished")?(alert("The game has already finished"),a.gameMode=!1):-1!==b.responseText.indexOf("maxrounds")&&
(a.maxGameRounds=parseInt(b.responseText.split(" ")[1]),a.registered=!0);return d=b.responseText}});return d};p=function(b){var c;c=l(a.serverURL,"rank "+a.nextLevel);console.log("Server said "+c);return-1!==c.indexOf("urrank")?(m(),a.currentRank=c.split(" ")[2],console.log("My rank at the beginning of round "+(a.nextLevel+1)+" is: "+a.currentRank),r(),i(!0),!0):setTimeout(function(){return p(b)},3E3)};o=function(){a.gameTextWebSymbols.innerHTML=a.loaderSymbols[a.loaderIndex];a.loaderIndex=a.loaderIndex<
a.loaderSymbols.length-1?a.loaderIndex+1:0;return a.loadmetimer=setTimeout(o,a.loaderRate)};i=function(b){if(b){clearTimeout(a.loadmetimer);a.gameTextWebSymbols.innerHTML="";a.gameText.setAttribute("style","font-weight:bold;");a.gameTextWebSymbols.setAttribute("class","");if(a.nextLevel===a.maxGameRounds-1)return a.gameText.textContent="Last Round "+(a.nextLevel+1),a.gameTextWebSymbols.textContent=": please make a guess. ";if(a.nextLevel===a.maxGameRounds)return a.gameText.setAttribute("style",""),
a.gameText.textContent="Thank you for playing the game. You can close your browser now.";a.gameText.textContent="Round "+(a.nextLevel+1);return a.gameTextWebSymbols.textContent=": please make a guess."}a.gameText.setAttribute("style","");a.gameTextWebSymbols.setAttribute("class","websymbols");a.gameText.textContent="Please wait for the other players";$(a).triggerHandler({type:"loadme"});return 4};r=function(){return a.nextLevel===a.maxGameRounds?a.rankText.textContent="Your final rank: "+a.currentRank:
a.rankText.textContent="Your current rank: "+a.currentRank};e=function(b){var c,d;c=b||window.event;b=-30*c.deltaY||c.wheelDeltaY/109||void 0===c.wheelDeltaY&&c.wheelDelta/109||-10*c.detail||0;a.isMacWebKit&&(b/=30);a.isFirefox&&(b=Math.abs(b)/(109*b/120));a.isFirefox&&"DOMMouseScroll"!==c.type&&a.circleCanvas.removeEventListener("DOMMouseScroll",e,!1);c.preventDefault&&c.preventDefault();c.stopPropagation&&c.stopPropagation();c.cancelBubble=!0;c.returnValue=!1;b=Math.pow(1+a.zoom_scale,0<b?1.1009174311926606:
-1.1009174311926606);30<=a.zoom_level&&1<b&&(b=1);-30>=a.zoom_level&&1>b&&(b=1);0===a.zoom_level&&(a.rememberTargetCircle.x=a.targetCircle.getAttribute("cx"),a.rememberTargetCircle.y=a.targetCircle.getAttribute("cy"));1<b?a.zoom_level++:1>b&&a.zoom_level--;c=a.compositeG.getScreenCTM();d=c.scale(b);b=a.circleCanvas.getScreenCTM();c=a.rememberTargetCircle.matrixTransform(c).matrixTransform(d.inverse());c=d.translate(c.x-a.rememberTargetCircle.x,c.y-a.rememberTargetCircle.y);b=b.inverse().multiply(c);
a.compositeG.setAttribute("transform","matrix("+b.a+","+b.b+","+b.c+","+b.d+","+b.e+","+b.f+")");return a.buttonNext.disabled=!1};h=function(b){var c,d;b&&(b=a.majorCircle.getAttribute("r"),a.angleLine.setAttribute("x2",0),a.angleLine.setAttribute("y2",b),a.currentGuess.setAttribute("cx",0),a.currentGuess.setAttribute("cy",b),a.targetCircle.setAttribute("cx",0),a.targetCircle.setAttribute("cy",b));d=Math.pow(1+a.zoom_scale,-(120/109)*a.zoom_level);c=a.compositeG.getScreenCTM();b=a.circleCanvas.getScreenCTM();
d=c.scale(d);c=a.rememberTargetCircle.matrixTransform(c).matrixTransform(d.inverse());c=d.translate(c.x-a.rememberTargetCircle.x,c.y-a.rememberTargetCircle.y);b=b.inverse().multiply(c);a.compositeG.setAttribute("transform","matrix("+b.a+","+b.b+","+b.c+","+b.d+","+b.e+","+b.f+")");return a.zoom_level=0};j=function(b){b=b||window.event;b=n(b);a.previous_angle=Math.atan2(b.y,b.x);b=a.majorCircle.getAttribute("r");a.currentGuess.setAttribute("cx",b*Math.cos(a.previous_angle));a.currentGuess.setAttribute("cy",
b*Math.sin(a.previous_angle));b=a.circleCanvas.getElementsByTagName("animate");b[0].setAttribute("dur","0.3s");b[0].beginElement();!a.flip&&1===a.instructionIndex&&(a.instructionsText.textContent+="\n\rThe small red circle at the selected position shows your last guess.\n\r",a.buttonNext.disabled=!1,a.flip=1);""!==a.rankText.textContent&&a.gameMode&&(a.rankText.textContent="Your current rank: ");if(a.gameMode)return a.nextLevel<a.maxGameRounds?(h(!1),l(a.serverURL,"estimate "+a.nextLevel+" "+180*
a.previous_angle/Math.PI),a.nextLevel++,i(!1),q(),$(a).triggerHandler({type:"queryServer",var1:"Howdy",information:"I could pass something here also"})):$(a).triggerHandler({type:"stopGame"})};k=function(b){var c,b=b||window.event,b=n(b),b=Math.atan2(b.y,b.x);c=a.majorCircle.getAttribute("r");a.angleLine.setAttribute("x2",c*Math.cos(b));a.angleLine.setAttribute("y2",c*Math.sin(b));a.targetCircle.setAttribute("cx",c*Math.cos(b));return a.targetCircle.setAttribute("cy",c*Math.sin(b))};f=function(){if("Start"===
a.buttonNextText.innerHTML&&!0!==a.gameMode)return a.gameMode=!0,$(a).triggerHandler({type:"startGame"});if(3>a.instructionIndex)return a.instructionIndex++,1===a.instructionIndex&&(a.compositeG.addEventListener("mousemove",k,!1),a.circleCanvas.addEventListener("click",j,!1)),2===a.instructionIndex&&(a.circleCanvas.onwheel=e,a.circleCanvas.onmousewheel=e,a.isFirefox&&a.circleCanvas.addEventListener("DOMMouseScroll",e,!1)),a.instructionsText.textContent=a.instructionVector[a.instructionIndex],a.buttonNext.disabled=
!0,a.buttonPrevious.disabled=!1,3===a.instructionIndex&&(a.rankText.textContent="Your Rank: 1 (25)",a.buttonNextText.innerHTML="Start",a.buttonNext.innerHTML='<text class="nextbuttontext">Start</text>.',a.buttonNext.disabled=!1),h(!0)};t=function(){if(a.registered)return h(!0),q(),a.instructionsDiv.parentNode.removeChild(a.instructionsDiv),a.gameTextDiv.setAttribute("style","height:100%;width:20%;float:left;padding-left:10px;padding-top:10px"),i(!1),a.buttonNext.parentNode.removeChild(a.buttonNext),
a.buttonPrevious.parentNode.removeChild(a.buttonPrevious),a.rankText.textContent="Your current rank: ",$(a).triggerHandler({type:"queryServer",var1:"Howdy",information:"I could pass something here also"});alert("You have not properly registered for the game.");return a.gameMode=!1};u=function(){a.gameMode=!1;i(!0);r();return m()};s=function(){a.flip=0;a.gameMode=!1;a.buttonPrevious.disabled=!1;a.buttonNextText.innerHTML="Next";a.instructionIndex--;0>=a.instructionIndex?(a.instructionIndex=0,a.buttonPrevious.disabled=
!0,a.buttonNext.disabled=!1):a.buttonPrevious.disabled=!1;a.instructionsText.textContent=a.instructionVector[a.instructionIndex];h(!0);if(0!==a.instructionIndex)return a.buttonNext.disabled=!0};g=function(){a.instructionVector[0]='Welcome to our guessing game.The purpose of the game is to find out the location of a hidden point randomly positioned on the blue circle to the left.You will compete with other players, and your performance, as well as reward, will be based on how close your final guess is to the hidden point, compared to others.\n\rThe game consists of 10 rounds. During each round, you make a guess by moving the green line around the circle and clicking on a desired position. A round finishes when all players have made their choices.\n\rAt the beginning of each round, you will be informed of your relative ranking. Your rank is 1 if you are the player currently closest to the hidden point. Conversely, if you are farthest from the point, you rank last.\n\rYour starting rank for round 1 will be determined randomly.\n\rClick "Next" for a quick practice.';
a.instructionVector[1]="Try moving the green line around the circle and click once it is positioned at a desired location ...";a.instructionVector[2]="For increased precision, you can zoom in and out of the circle with the mouse wheel. The zoom is with respect to the current position of the green line.\n\rTry zooming in and out a few times to get used to this functionality ... ";a.instructionVector[3]='Finally, your current rank is displayed above the circle. In the example shown, the number in the brackets shows the total number of players. Your rank will be updated at the end of each round, after all players  have submitted their choices, and will be presented to you at the beggining of the next round.\n\rWith this last bit of information, the practice session ends. You can continue playing with the circle, in which case random rank information will be presented. Alternatively, you can go back to read the instructions again. If anything is left unclear, please ask the administrator.\n\rOnce you are ready, hit "Start" to begin the game.';
return a.instructionsText.textContent=a.instructionVector[a.instructionIndex]};m=function(){a.compositeG.addEventListener("mousemove",k,!1);a.circleCanvas.addEventListener("click",j,!1);a.circleCanvas.onwheel=e;a.circleCanvas.onmousewheel=e;if(a.isFirefox)return a.circleCanvas.addEventListener("DOMMouseScroll",e,!1)};q=function(){a.compositeG.removeEventListener("mousemove",k,!1);a.circleCanvas.removeEventListener("click",j,!1);a.circleCanvas.onwheel=null;a.circleCanvas.onmousewheel=null;if(a.isFirefox)return a.circleCanvas.removeEventListener("DOMMouseScroll",
e,!1)};a.isBuggyFirefox?(alert("Sorry, you are using Firefox version 13.0.1, which has a bug in computing correct coordinates of SVG elements (https://bugzilla.mozilla.org/show_bug.cgi?id=762411). Use either the beta version of Firefox 14.0b10 or a different broswer."),g=!1):(a.buttonNext.onclick=f,a.buttonPrevious.onclick=s,a.buttonPrevious.disabled=!0,g(),console.log(l(a.serverURL,"announce")),$(a).on("queryServer",p),$(a).on("startGame",t),$(a).on("stopGame",u),g=$(a).on("loadme",o));return g};
v.rank_experiment=f}).call(this);
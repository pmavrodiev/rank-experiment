class window.rank_experiment
  constructor: () ->
    #general browser stuff
    @windowWidth = window.innerWidth
    @windowHeight = window.innerHeight
    @buttonNext = document.getElementById("next")
    @buttonNextText = document.getElementsByClassName("nextbuttontext")[0]
    @buttonPrevious = document.getElementById("previous")
    @instructionsText = document.getElementById("instructions")
    @circleCanvasDiv = document.getElementById("circleCanvasDiv")
    @instructionsDiv = document.getElementById("instructionsDiv")
    @gameTextDiv = document.getElementById("gameTextDiv")
    @gameText = document.getElementById("gameText")
    @gameTextWebSymbols = document.getElementsByClassName("websymbols")[0]
    @miscInfoDiv = document.getElementById("miscinfo")    
    @miscInfo = document.getElementById("miscinfotext")
    #drawing elements
    @compositeG=document.getElementById("svgCanvas") 
    @circleCanvas=document.getElementById("circleCanvas")
    @majorCircle=document.getElementById("majorCircle") 
    @targetCircle=document.getElementById("targetCircle")
    @rememberTargetCircle = @circleCanvas.createSVGPoint()
    @currentGuess=document.getElementById("currentGuess") 
    @angleLine=document.getElementById("angleLine") 
    @rankText=document.getElementById("rankText")   
    @userNameInput = document.getElementById("username")
    @username = ""
    
    #game-related stuff
    ### used to display a spinning waiting symbol when waiting for other players ###
    @loaderIndex = 0 
    @loaderSymbols=["0", "1", "2", "3", "4", "5", "6", "7"]
    @loaderRate=100
    @loadmetimer=null
    ### ###
    @maxGameRounds = 0 #obtained from the server upon announcement
    @maxGameStages = 0 #obtained from the server upon announcement
    @instructionVector = new Array()
    @instructionIndex = 0
    @gameMode = ""
    @nextLevel = 0
    @nextStage = 0
    @currentRank = ""       
    @tbody  = document.createElement("tbody")
    #payoffs
    @payoffs_per_stage = [10,6,4] #10CHF for 1st place and so on.
    @finalRanks = []
    @zoom_scale = 0.1
    @zoom_level = 0 #the nestedness of the zoom
    @previous_angle = Math.PI/2
    @isMacWebKit = navigator.userAgent.indexOf("Macintosh") != -1 &&
                navigator.userAgent.indexOf("WebKit") != -1
                
    @isFirefox = navigator.userAgent.indexOf("Firefox") != -1
    @isBuggyFirefox = navigator.userAgent.indexOf("Firefox/13.0.1") != -1
    
    #network stuff
    @serverURL = "http://192.168.1.161:8070/"
    @registered = false
    @customIdentity = Math.random().toString(36).substring(5)
    
    #misc
    @flip = 0    
    if (@isFirefox)
      window.load = @windowListen()
    else
      window.addEventListener('onload',@windowListen(),false)     
    
    
  windowListen: () ->   
  
   getCursorPosition = (e) => 
      pt = @circleCanvas.createSVGPoint()
      pt.x = e.clientX
      pt.y = e.clientY

   
      transformation_matrix = @compositeG.getScreenCTM()
      pt2 = pt.matrixTransform(transformation_matrix.inverse())  
      return pt2
   
   #for now return the full server response to queryRound, but in principle can return just a flag          
   send = (theURL, _data) =>
      serverResponse = null
      processError = (object, errorMessage, exception) =>
        alert("Cannot connect to server.")
        @gameMode = false
        clearTimeout(@loadmetimer)
      processServerResponse = (response, status) =>
        if status != "success" or status == "error"          
          @gameMode = false
          @registered = false
          clearTimeout(@loadmetimer)
        else #success          
          if response.responseText.indexOf("inprogress")  != -1
            alert("Sorry, the game has already started")
            @gameMode = false
            @registered = false
          else if response.responseText.indexOf("roundfinished")  != -1
            alert("Sorry, you have been disconnected from the game due to network problems.")
            @registered = false
            @gameMode = false
          else if response.responseText.indexOf("finished") != -1
            alert("The game has already finished")
            @registered = false
            @gameMode = false
          else if response.responseText.indexOf("maxroundsstages") != -1
            @maxGameRounds = parseInt(response.responseText.split(" ")[1])
            @maxGameStages = parseInt(response.responseText.split(" ")[2])
            @registered = true
          else if response.responseText.indexOf("insane") != -1
            alert("Sorry, you have been disconnected from the game due to network problems.")
            @registered = false
            @gameMode = false  
                
        serverResponse = response.responseText
                  
      $.ajax(
         url: theURL,
         accepts: "*/*"
         contentType: "text/html",
         crossDomain: true,
         context: @,
         type: "POST",
         data: _data,
         headers: {"Hex": @customIdentity, "Username": @username}
         async: false,        
         complete:  processServerResponse,
         error: processError
      )      
      serverResponse        
      
    
   queryRound = (data) =>      
      #send a POST request asking for rank info about the current level and current stage
      if not @gameMode
        $(this).triggerHandler(type:"stopGame")
        return true
      srvResponse = send(@serverURL,"rank "+@nextLevel + " " + @nextStage)      
      console.log("Server said " + srvResponse)
      if srvResponse.indexOf("urrank") != -1        
        addListeners()
        @currentRank = srvResponse.split(" ")[2]
        if @nextLevel == 0
          @initialEstimate = srvResponse.split(" ")[3]
          setEstimateAngle(@initialEstimate) #in radians
        #the +1 here is just because humans are used to indexing from 1.
        console.log("My rank at the beginning of round " + (@nextLevel+1) + " and stage " + (@nextStage+1)+" is: " + @currentRank)
        updateRankInfo()
        updateGameTextDiv(true)
        #decide to disconnect randomly before sending estimate
        #if Math.random() < 0.2
        #  $(this).triggerHandler(type:"stopGame")
        #  return true      
        #SEND AUTOMATIC RANDOM ANGLE TO THE SERVER
        #$(this).triggerHandler(type:"autoGuess")
        #decide to disconnect randomly before sending rank request, but after sending estimate
        #if Math.random() < 0.2
        #  $(this).triggerHandler(type:"stopGame")
        #  return true                  
        return true
      
      setTimeout((-> queryRound(data)),3000)
   
  
   autoGuess = () =>
      if @rankText.textContent!= "" and @gameMode
         @rankText.textContent="Your current rank: " 
      
      #should we send the click to the server?
      if @gameMode
        if @nextStage < @maxGameStages
            if @nextLevel < @maxGameRounds
              @miscInfo.textContent = ""
              resetZoom(false)
              #wait a bit
              ms=2000
              ms += new Date().getTime();
              while (new Date() < ms)
                g=5
              send(@serverURL,"estimate "+@nextLevel + " " + @nextStage + " " + @previous_angle*180/Math.PI)           
              @nextLevel++     
              #show wait for all players
              updateGameTextDiv(false)
              removeListeners()
              $(this).triggerHandler(type:"queryServer")
        else #stop game
              $(this).triggerHandler(type:"stopGame")
           
  
   loadme = () =>
      @gameTextWebSymbols.innerHTML = @loaderSymbols[@loaderIndex]      
      if @loaderIndex < @loaderSymbols.length-1
        @loaderIndex = @loaderIndex + 1
      else
        @loaderIndex = 0
      @loadmetimer=setTimeout(loadme, @loaderRate)
      
   
   updateGameTextDiv = (flag) =>
      if not flag
        #reset style and class to default
        @gameText.setAttribute("style","")
        @gameTextWebSymbols.setAttribute("class","websymbols")
        @gameText.textContent = "Please wait for the other players"
        $(this).triggerHandler(type:"loadme")       
      else
        clearTimeout(@loadmetimer)
        @gameTextWebSymbols.innerHTML = ""
        @gameText.setAttribute("style","font-weight:bold;")
        @gameTextWebSymbols.setAttribute("class","")
        if @gameMode
          if @nextLevel == (@maxGameRounds-1)
            @gameText.textContent = "Stage " + (@nextStage+1)+ ", Last Round " + (@nextLevel+1) 
            @gameTextWebSymbols.textContent = ": please make a guess. "
          else if @nextLevel == @maxGameRounds
            @gameText.setAttribute("style","")
            @gameText.textContent = "This is the end of Stage " + (@nextStage + 1)+". Click \"Next\" to begin "
            if (@nextStage+1)<(@maxGameStages-1)              
              @gameText.textContent = @gameText.textContent + "Stage " + (@nextStage+2) + "."
              $(this).triggerHandler(type:"nextStage")              
            else if (@nextStage+1)==(@maxGameStages-1)               
              @gameText.textContent = @gameText.textContent + "the last Stage " + (@nextStage+2) + "."              
              $(this).triggerHandler(type:"nextStage")
            else
              @gameText.textContent = "This is the end of the game. Thank you for playing. Click \"Next\" to see a summary of your performance."
              @gameMode = false
              $(this).triggerHandler(type:"summary")    
          else            
            @gameText.textContent = "Stage "+(@nextStage+1)+", Round " + (@nextLevel+1)
            @gameTextWebSymbols.textContent = ": \n please make a guess."            
            if @nextLevel == 0
              @miscInfo.textContent = "The random initial guess assigned to you is indicated by the red circle."         
              
   
   updateRankInfo = () =>
      if @nextLevel == 0
        @rankText.textContent = @username+", your initial rank is: "+@currentRank
      else if @nextLevel == @maxGameRounds
        @rankText.textContent = @username+", your final rank for stage " + (@nextStage+1) + " is: "+@currentRank
        @finalRanks[@nextStage] = parseInt(@currentRank.split("(")[0]) #save the final rank for this stage        
      else
        @rankText.textContent = @username+", your rank at the end of round " + @nextLevel + " is: "+@currentRank
   
   nextStage = () =>
     removeListeners()     
     #create the "Next" button
     nbutton=document.createElement("button")
     nbutton.setAttribute("type","button")
     nbutton.setAttribute("id","next_stage")
     nbutton.setAttribute("class","nextbutton")     
     nbuttonText = document.createElement("text")
     nbuttonText.setAttribute("class","nextbuttontext")
     nbuttonText.innerHTML = "Next"
     nbutton.appendChild(nbuttonText)
     @miscInfoDiv.appendChild(nbutton)
     #the div with id="playerinfo"
     @gameText.parentNode.setAttribute("style","height:20%;width:100%;float:left;") 
     @miscInfoDiv.setAttribute("style","height:80%;width:100%;float:left;")     
     nbutton.onclick = nextStageEvent
     #reset the display
     ###
     @gameText.parentNode.setAttribute("style","height:10%;width:100%;float:left;") 
     @miscInfoDiv.setAttribute("style","height:90%;width:100%;float:left;")     
     nbutton.parentNode.removeChild(nbutton)
     @nextStage++     
     @nextLevel = 0
     @currentRank = ""
     updateGameTextDiv(false)
     #notify the server that we are ready for the next stage
     send(@serverURL,"ready "+@nextStage)
     if @rankText.textContent!= "" and @gameMode
        @rankText.textContent="Waiting for other players."     
     $(this).triggerHandler(type:"queryServer")
     ###
     
          
   nextStageEvent = () =>
     #reset the display
     @gameText.parentNode.setAttribute("style","height:10%;width:100%;float:left;") 
     @miscInfoDiv.setAttribute("style","height:90%;width:100%;float:left;")
     nbutton=document.getElementById("next_stage")
     nbutton.parentNode.removeChild(nbutton)
     @nextStage++     
     @nextLevel = 0
     @currentRank = ""
     updateGameTextDiv(false)
     #notify the server that we are ready for the next stage
     send(@serverURL,"ready "+@nextStage)
     if @rankText.textContent!= "" and @gameMode
        @rankText.textContent="Waiting for other players."     
     $(this).triggerHandler(type:"queryServer")
                  
   summary = () =>
     #create the "Next" button
     nbutton=document.createElement("button")
     nbutton.setAttribute("type","button")
     nbutton.setAttribute("id","summary")
     nbutton.setAttribute("class","nextbutton")     
     nbuttonText = document.createElement("text")
     nbuttonText.setAttribute("class","nextbuttontext")
     nbuttonText.innerHTML = "Summary"
     nbutton.appendChild(nbuttonText)
     @miscInfoDiv.appendChild(nbutton)
     #the div with id="playerinfo"
     @gameText.parentNode.setAttribute("style","height:20%;width:100%;float:left;") 
     @miscInfoDiv.setAttribute("style","height:80%;width:100%;float:left;")     
     nbutton.onclick = summaryEvent
     
   summaryEvent = () =>
     @gameText.parentNode.setAttribute("style","height:10%;width:100%;float:left;") 
     @miscInfoDiv.setAttribute("style","height:90%;width:100%;float:left;")
     nbutton=document.getElementById("summary")
     nbutton.parentNode.removeChild(nbutton)
     #tell the server we are done     
     @gameMode = false
     send(@serverURL,"finito")
     total = 0
     for i in [1..@maxGameStages]
        #add row   
        row = document.createElement("tr")
        cell0 = document.createElement("th")
        cell0.appendChild(document.createTextNode("Stage "+i))
        cell1 = document.createElement("td")
        cell1.appendChild(document.createTextNode(@finalRanks[i-1]))
        cell2 = document.createElement("td")
        payoff=""        
        if @finalRanks[i-1] < 4
          payoff = @payoffs_per_stage[@finalRanks[i-1]-1] + " CHF"
          total = total + @payoffs_per_stage[@finalRanks[i-1]-1]
        else 
          payoff = "0 CHF"
        cell2.appendChild(document.createTextNode(payoff))
        row.appendChild(cell0)
        row.appendChild(cell1)
        row.appendChild(cell2)
        @tbody.appendChild(row)
     totalrow = document.createElement("tr") 
     cell0 = document.createElement("th")
     cell0.appendChild(document.createTextNode("Total"))
     cell1 = document.createElement("td")
     cell2 = document.createElement("td")
     cell2.appendChild(document.createTextNode(total + " CHF"))
     totalrow.appendChild(cell0)   
     totalrow.appendChild(cell1)
     totalrow.appendChild(cell2)
     @tbody.appendChild(totalrow)
     table = document.createElement("table")     
     table.setAttribute("class","summary_table")
     table.appendChild(@tbody)
     @gameTextDiv.parentNode.removeChild(@gameTextDiv)
     @circleCanvas.parentNode.removeChild(@circleCanvas)
     @circleCanvasDiv.appendChild(table)    
     @rankText.textContent = "Thank you "+@username+" for playing. You can close the page now."
   
   ccMouseWheel = (event) =>
   
      e = event || window.event; #standard or IE event object
      # Extract the amount of rotation from the event object, looking
      # for properties of a wheel event object, a mousewheel event object
      # (in both its 2D and 1D forms), and the Firefox DOMMouseScroll event.
      # Scale the deltas so that one "click" toward the screen is 30 pixels.
      # If future browsers fire both "wheel" and "mousewheel" for the same
      # event, we'll end up double-counting it here. Hopefully, however,
      # cancelling the wheel event will prevent generation of mousewheel.
      deltaX = e.deltaX*-30 || # wheel event
      e.wheelDeltaX/40 || # mousewheel
      0 # property not defined
      deltaY = e.deltaY*-30 || # wheel event
      e.wheelDeltaY/109 || # mousewheel event in Webkit
      (e.wheelDeltaY==undefined && # if there is no 2D property then
      e.wheelDelta/109) || # use the 1D wheel property
      e.detail*-10 || # Firefox DOMMouseScroll event
      0# property not defined

      ###  
      Most browsers generate one event with delta 120 per mousewheel click.
      On Macs, however, the mousewheels seem to be velocity-sensitive and
      the delta values are often larger multiples of 120, at
      least with the Apple Mouse. Use browser-testing to defeat this.
      ###
      if (@isMacWebKit) 
        deltaX /= 30;
        deltaY /= 30;
      
      if (@isFirefox)
        deltaY = Math.abs(deltaY) / (deltaY*109/120)
        
      # If we ever get a mousewheel or wheel event in (a future version of)
      # Firefox, then we don't need DOMMouseScroll anymore.
      if (@isFirefox && e.type != "DOMMouseScroll")
        @circleCanvas.removeEventListener("DOMMouseScroll", ccMouseWheel, false);
      # Get the current dimensions of the content element
      #contentbox = @compositeG.getBoundingClientRect();
      if (e.preventDefault) 
        e.preventDefault();
      if (e.stopPropagation) 
        e.stopPropagation();
      
      e.cancelBubble = true; #IE events
      e.returnValue = false; #IE events
      #Some stupid browsers give velocity-sensitive deltaYs. So we just set this to a "good" value
      if deltaY > 0
        deltaY = 1.1009174311926606
      else 
        deltaY = -1.1009174311926606      
      
      zoomLevel = Math.pow(1+@zoom_scale,deltaY)
      if @zoom_level >= 30 and zoomLevel > 1
        zoomLevel = 1   
      if @zoom_level <= -30 and zoomLevel < 1
        zoomLevel = 1
      #use the coordinates of the targetCircle as zoom focus only for zoomLevel 1     
      if @zoom_level == 0
        @rememberTargetCircle.x = @targetCircle.getAttribute("cx")
        @rememberTargetCircle.y = @targetCircle.getAttribute("cy")                 
      if zoomLevel > 1 
        @zoom_level++
      else if zoomLevel < 1
        @zoom_level--
        
      #console.log(@zoom_level)
    
      tm = @compositeG.getScreenCTM()
      tmscaled = tm.scale(zoomLevel)
      tmparent = @circleCanvas.getScreenCTM()
     
      circleParent = @rememberTargetCircle.matrixTransform(tm) #circleParent = tm * circle_xy
      circleScaled = circleParent.matrixTransform(tmscaled.inverse()) #circleParent = tmscaled * circleScaled
      
      
      translation_x = circleScaled.x-@rememberTargetCircle.x;  translation_y = circleScaled.y-@rememberTargetCircle.y 
      tmscaledtranslated = tmscaled.translate(translation_x,translation_y)
      
      smatrix = tmparent.inverse().multiply(tmscaledtranslated) # CTM(compositeG)=TMscaled=TMparent*s  
      s = "matrix("+ smatrix.a + "," +smatrix.b + "," +smatrix.c + "," + smatrix.d + "," +smatrix.e+ "," +smatrix.f+")"
      
      @compositeG.setAttribute("transform",s)
      #tm2 = @compositeG.getScreenCTM()
      
      @buttonNext.disabled=false
      return false  
   
   resetZoom = (flag) =>
      if flag
        radius = @majorCircle.getAttribute("r")
        @angleLine.setAttribute("x2",0)
        @angleLine.setAttribute("y2",radius)
        @currentGuess.setAttribute("cx",0)
        @currentGuess.setAttribute("cy",radius)     
        @targetCircle.setAttribute("cx",0)
        @targetCircle.setAttribute("cy",radius)
      
      ###
      Due to this bug: https://bugzilla.mozilla.org/show_bug.cgi?id=762411
      the latest stable release Firefox 13.0.1 gets the wrong transformation matrix
      for tmparent. This bug is fixed in the beta version Firefox 14.0b10.     
      ###
      needed_zoom = 0
      exponent = 120/109
      needed_zoom = Math.pow(1+@zoom_scale,-exponent*@zoom_level) 
      tm = @compositeG.getScreenCTM(); tmparent = @circleCanvas.getScreenCTM()
      tmscaled = tm.scale(needed_zoom)
      circleParent = @rememberTargetCircle.matrixTransform(tm) #circleParent = tm * circle_xy
      circleScaled = circleParent.matrixTransform(tmscaled.inverse()) #circleParent = tmscaled * circleScaled
      translation_x = circleScaled.x-@rememberTargetCircle.x;  translation_y = circleScaled.y-@rememberTargetCircle.y 
      tmscaledtranslated = tmscaled.translate(translation_x,translation_y)
      smatrix = tmparent.inverse().multiply(tmscaledtranslated)      
      s = "matrix("+ smatrix.a + "," +smatrix.b + "," +smatrix.c + "," + smatrix.d + "," +smatrix.e+ "," +smatrix.f+")"  
      @compositeG.setAttribute("transform",s)
      #tm2 = @compositeG.getScreenCTM();
      @zoom_level = 0      
      
   ccMouseClick = (e) =>
      e = e || window.event
      coord = getCursorPosition(e)    
      @previous_angle = Math.atan2(coord.y,coord.x)
      radius = @majorCircle.getAttribute("r")
      @currentGuess.setAttribute("cx",radius*Math.cos(@previous_angle))
      @currentGuess.setAttribute("cy",radius*Math.sin(@previous_angle))
      animatedElement = @circleCanvas.getElementsByTagName('animate')
      animatedElement[0].setAttribute("dur","0.3s")  
      animatedElement[0].beginElement()
      
      if !@flip and @instructionIndex == 1
        @instructionsText.textContent += "\n\rThe small red circle at the selected position shows your last guess.\n\r"
        @buttonNext.disabled=false
        @flip = 1
      
      if @rankText.textContent!= "" and @gameMode
        @rankText.textContent="Waiting for other players." 
      
      #should we send the click to the server?
      if @gameMode
        if @nextStage < @maxGameStages
            if @nextLevel < @maxGameRounds
              @miscInfo.textContent = ""
              resetZoom(false)
              send(@serverURL,"estimate "+@nextLevel + " " + @nextStage + " " + @previous_angle*180/Math.PI)           
              @nextLevel++     
              #show wait for all players
              updateGameTextDiv(false)
              removeListeners()
              $(this).triggerHandler(type:"queryServer")
        else #stop game
              $(this).triggerHandler(type:"stopGame")
    
   
   setEstimateAngle = (angle) => 
      #angle is in radians
      radius = @majorCircle.getAttribute("r")
      @angleLine.setAttribute("x2",radius*Math.cos(angle))
      @angleLine.setAttribute("y2",radius*Math.sin(angle))
      @targetCircle.setAttribute("cx",radius*Math.cos(angle))
      @targetCircle.setAttribute("cy",radius*Math.sin(angle))  
      @currentGuess.setAttribute("cx",radius*Math.cos(angle))
      @currentGuess.setAttribute("cy",radius*Math.sin(angle))    
      
   ccMouseMove = (e) =>
      e = e || window.event
      coord = getCursorPosition(e)
      angle = Math.atan2(coord.y,coord.x)
      radius = @majorCircle.getAttribute("r")
      @angleLine.setAttribute("x2",radius*Math.cos(angle))
      @angleLine.setAttribute("y2",radius*Math.sin(angle))
      @targetCircle.setAttribute("cx",radius*Math.cos(angle))
      @targetCircle.setAttribute("cy",radius*Math.sin(angle))
        
   restartGuessingTask = () =>    
      @circleCanvas.addEventListener('click', ccMouseClick, false)

      
        
   next = () =>
        if @buttonNextText.innerHTML == "Start" and @gameMode != true
            @gameMode = true            
            #start polling like a boss
            $(this).triggerHandler(type:"startGame")
        else if @instructionIndex < 3
            if  @userNameInput.value == ""               
              alert("Please enter your username")
            else
              if @username == ""                
                @username = @userNameInput.value.charAt(0).toUpperCase() + @userNameInput.value.slice(1) #capitalize first letter
                #remove the input form
                @userNameInput.parentNode.parentNode.removeChild(@userNameInput.parentNode)
              @instructionIndex++
              if @instructionIndex == 1
                @compositeG.addEventListener('mousemove', ccMouseMove, false) #fired when mouse is moved
                @circleCanvas.addEventListener('click', ccMouseClick, false) #fired when mouse is pressed AND released
              if @instructionIndex == 2
                @circleCanvas.onwheel = ccMouseWheel #future browsers
                @circleCanvas.onmousewheel = ccMouseWheel #most current browsers
                if (@isFirefox)
                  @circleCanvas.addEventListener("DOMMouseScroll",ccMouseWheel,false)
   
              @instructionsText.textContent = @instructionVector[@instructionIndex]      
              @buttonNext.disabled=true
              @buttonPrevious.disabled=false
      
              if @instructionIndex == 3   
                @rankText.textContent = "Your Rank: 1 (25)"             
                @buttonNextText.innerHTML = "Start"
                @buttonNext.innerHTML = "<text class=\"nextbuttontext\">Start</text>."              
                @buttonNext.disabled=false
            
              resetZoom(true)
        
   startGame = () =>
     if @registered
        #notify the server that this agent has finished the intructions
        send(@serverURL,"doneinstructions")
        resetZoom(true)
        removeListeners()
        @instructionsDiv.parentNode.removeChild(@instructionsDiv)            
        @gameTextDiv.setAttribute("style","height:100%;width:20%;float:left;padding-left:10px;padding-top:10px")        
        updateGameTextDiv(false)
        @buttonNext.parentNode.removeChild(@buttonNext)
        @buttonPrevious.parentNode.removeChild(@buttonPrevious)
        @rankText.textContent="Waiting for other players."
        $(this).triggerHandler(type:"queryServer")
      else
        alert("You have not properly registered for the game.")
        @gameMode = false
      
   stopGame = () =>
      @gameMode = false
      updateGameTextDiv(true)   
      updateRankInfo()
      addListeners()
   
   prev = () =>  
      @flip = 0
      @gameMode = false
      @buttonPrevious.disabled=false
      @buttonNextText.innerHTML = "Next"
      @buttonNext.innerHTML = "<text class=\"nextbuttontext\">Next</text>>"         
      @instructionIndex--
      if @instructionIndex<=0 
        @instructionIndex=0
        @buttonPrevious.disabled=true
        @buttonNext.disabled=false
      else
        @buttonPrevious.disabled=false

      @instructionsText.textContent = @instructionVector[@instructionIndex]
      
      resetZoom(true)      
      if @instructionIndex != 0
        @buttonNext.disabled=true
      
   initInstructions = () =>
      @instructionVector[0] = "Welcome to our guessing game."+ 
      "The purpose of the game is to find out the location of a hidden point " +
      "randomly positioned on the blue circle to the left."+
      "You will compete with other players, and your performance, as well as reward, "+
      "will be based on how close your guess is to the hidden point, compared to others.\n\r"+
      "The game consists of 5 identical stages. Each stage, in turn, consists of 10 rounds."+
      "During each round, you make a guess "+
      "by moving the green line around the circle and clicking on a desired position. "+
      "A round finishes when all players have made their choices. A stage finishes after round 10 is over.\n\r"+
      "At the beginning of round 1 of each stage, you will be assigned a random guess. It is used to calculate your starting rank for this stage."+      
      "Your rank is 1 if you are the player currently closest to the hidden point. "+
      "Similarly, if you are farthest from the point, you rank last.\n\r" +
      "Your payoff is based on your final rank at the end each stage. Rank 1 is worth 10 CHF, Rank 2 - 6 CHF, and Rank 3 - 4 CHF. For example, if you consistently"+
      " finish first in all 5 stages, your reward will be 10*5= 50 CHF.\n\r"+
      "To continue, enter a username in the box below and click \"Next\" for a quick practice."
      
      @instructionVector[1] = "Try moving the green line around the circle and click once it is positioned at a desired location ..."
      
      @instructionVector[2] = "For increased precision, you can zoom in and out of the circle with the mouse wheel.\n\r" +                              
                              "Try zooming in and out a few times to get used to this functionality ... "
      
      @instructionVector[3] = "Finally, your rank at the end of the previous round is displayed above the circle. "+
                              "In this example, the number in the brackets shows the current number "+
                              "of connected players. This number, together with your rank, will be updated at the end of each round, after all players "+ 
                              " have submitted their guesses. "+
                              "At the beggining of each new round, you will be shown your rank from the previous one.\n\r"+ 
                              
                              "With this last bit of information, the practice session ends. You can continue "+
                              "playing with the circle or "+
                              "you can go back to read the instructions again. If anything is left unclear, please ask the administrator in chat.\n\r"+
                              "Once you are ready, hit \"Start\" to begin the game. " +
                              "You will be assigned a random initial estimate (indicated by the red circle) on which your initial rank will be based."
                              
                              
     
            
      @instructionsText.textContent = @instructionVector[@instructionIndex] #idx should be 0
      
   addListeners = () =>
      @compositeG.addEventListener('mousemove', ccMouseMove, false) #fired when mouse is moved
      @circleCanvas.addEventListener('click', ccMouseClick, false) #fired when mouse is pressed AND released
      #add mousewheel event   
      @circleCanvas.onwheel = ccMouseWheel #future browsers
      @circleCanvas.onmousewheel = ccMouseWheel #most current browsers
      if (@isFirefox)
        @circleCanvas.addEventListener("DOMMouseScroll",ccMouseWheel,false)
        
   removeListeners = () =>
      @compositeG.removeEventListener('mousemove', ccMouseMove, false) #fired when mouse is moved
      @circleCanvas.removeEventListener('click', ccMouseClick, false) #fired when mouse is pressed AND released
      #add mousewheel event   
      @circleCanvas.onwheel = null
      @circleCanvas.onmousewheel = null
      if (@isFirefox)
        @circleCanvas.removeEventListener("DOMMouseScroll",ccMouseWheel,false)
        
        
   initSummaryTable = () =>
     #create the heading
     toprow =  document.createElement("tr")
     cell0 = document.createElement("th")
     cell1 = document.createElement("th")
     cell1.appendChild(document.createTextNode("Final Rank"))
     cell2 = document.createElement("th")
     cell2.appendChild(document.createTextNode("Payoff"))
     toprow.appendChild(cell0)
     toprow.appendChild(cell1)
     toprow.appendChild(cell2)
     @tbody.appendChild(toprow)
     #console.log(@finalRanks)       
   
   init = () =>   
      #sanity check
      if @isBuggyFirefox
        alert("Sorry, you are using Firefox version 13.0.1, which has a bug in computing correct" + 
        " coordinates of SVG elements (https://bugzilla.mozilla.org/show_bug.cgi?id=762411). "+
        "Use either the beta version of Firefox 14.0b10 or a different broswer.")
        return false
      #buttons
      @buttonNext.onclick = next
      @buttonPrevious.onclick = prev
      @buttonPrevious.disabled=true
      
      initInstructions()
      initSummaryTable()
     
      console.log(send(@serverURL,"announce"))
      $(this).on("queryServer",queryRound)
      $(this).on("startGame",startGame)
      $(this).on("stopGame",stopGame)
      $(this).on("loadme",loadme)
      $(this).on("nextStage",nextStage)
      $(this).on("summary",summary)      
      #$(this).on("autoGuess",autoGuess)   
      #START THE GAME IMMEDIATELY
      #@gameMode = true
      #$(this).triggerHandler(type:"startGame")
     
    
   init()

  
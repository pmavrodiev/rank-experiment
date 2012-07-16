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
    #drawing elements
    @compositeG=document.getElementById("svgCanvas") 
    @circleCanvas=document.getElementById("circleCanvas")
    @majorCircle=document.getElementById("majorCircle") 
    @targetCircle=document.getElementById("targetCircle")
    @rememberTargetCircle = @circleCanvas.createSVGPoint()
    @currentGuess=document.getElementById("currentGuess") 
    @angleLine=document.getElementById("angleLine") 
    @rankText=document.getElementById("rankText")   
    
    #game-related stuff
    @maxGameRounds = 0 #obtained from the server upon announcement
    @instructionVector = new Array()
    @instructionIndex = 0
    @gameMode = ""
    @nextLevel = 0
    @currentRank = ""
    @zoom_scale = 0.2
    @zoom_level = 0 #the nestedness of the zoom
    @previous_angle = Math.PI/2
    @isMacWebKit = navigator.userAgent.indexOf("Macintosh") != -1 &&
                navigator.userAgent.indexOf("WebKit") != -1
                
    @isFirefox = navigator.userAgent.indexOf("Firefox") != -1
    @isBuggyFirefox = navigator.userAgent.indexOf("Firefox/13.0.1") != -1
    
    #network stuff
    @serverURL = "http://129.132.133.54:8080/"
    @registered = false
     
    
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
      processServerResponse = (response, status) =>
        if status == "error"
          alert("Cannot connect to server")
        else if status != "success"
          alert("Network problems "+status)
        else #success
          if response.responseText.indexOf("announced") != -1
            @registered = true
          else if response.responseText.indexOf("inprogress")  != -1
            alert("Sorry, the game has already started")
            @gameMode = false
          else if response.responseText.indexOf("finished") != -1
            alert("The game has already finished")
            @gameMode = false
          else if response.responseText.indexOf("maxrounds") != -1
            @maxGameRounds = parseInt(response.responseText.split(" ")[1])    
                
        serverResponse = response.responseText
                  
      $.ajax(
         url: theURL,
         accepts: "*/*"
         contentType: "text/html",
         crossDomain: true,
         context: @,
         type: "POST",
         data: _data,
         async: false
         complete:  processServerResponse,
      )      
      serverResponse        
      
    
   queryRound = (data) =>      
      #send a POST request asking for rank info about the current level
      srvResponse = send(@serverURL,"rank "+@nextLevel)
      console.log("Server said " + srvResponse)
      if srvResponse.indexOf("urrank") != -1        
        addListeners()
        @currentRank = srvResponse.split(" ")[2]
        #the +1 here is just because humans are used to indexing from 1.
        console.log("My rank at the beginning of round " + (@nextLevel+1) + " is: " + @currentRank)
        updateRankInfo()
        updateGameTextDiv(true)                
        return true
      
      setTimeout((-> queryRound(data)),3000)
   
   loadme = (data) =>
      @gameTextWebSymbols.innerHTML = data.loaderSymbols[data.loaderIndex]
      data.loaderIndex = data.loaderIndex  < data.loaderSymbols.length - 1 ? data.loaderIndex + 1
      setTimeout(loadme(data), data.loaderRate)
      
   
   updateGameTextDiv = (flag) =>
      if not flag             
        @gameText.textContent = "Please wait for the other players"        
        $(this).triggerHandler(
           type:"loadme",
           loaderSymbols:["0", "1", "2", "3", "4", "5", "6", "7"],
           loaderRate:100,
           loaderIndex:0       
        )
        a=4
      else
        if @nextLevel == (@maxGameRounds-1)
            @gameText.textContent = "Last Round " + (@nextLevel+1) + ": please make a guess. "
        else if @nextLevel == @maxGameRounds
            @gameText.textContent = "Thank you for playing the game. You can close your browser now."
        else
            @gameText.textContent = "Round " + (@nextLevel+1) + ": please make a guess. "
              
   
   updateRankInfo = () =>
      if @nextLevel == @maxGameRounds
        @rankText.textContent = "Your final rank: " + @currentRank 
      else
        @rankText.textContent = "Your current rank: " + @currentRank
   
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
  
      zoomLevel = Math.pow(1+@zoom_scale,deltaY)
      #use the coordinates of the targetCircle as zoom focus only for zoom level 1
      if @zoom_level == 0
        @rememberTargetCircle.x = @targetCircle.cx.baseVal.value
        @rememberTargetCircle.y = @targetCircle.cy.baseVal.value       
      if zoomLevel > 1
        @zoom_level++
      else 
        @zoom_level--      
    
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
        @instructionsText.textContent += "\n\rThe small red circle at the selected position shows your last quess.\n\r"
        @buttonNext.disabled=false
        @flip = 1
      
      if @rankText.textContent!= "" and @gameMode
        @rankText.textContent="Your current rank: " 
      
      #should we send the click to the server?
      if @gameMode
         if @nextLevel < @maxGameRounds
            resetZoom(false)
            send(@serverURL,"estimate "+@nextLevel + " " + @previous_angle*180/Math.PI)       
            @nextLevel++     
            #show wait for all players
            updateGameTextDiv(false)
            removeListeners()
            $(this).triggerHandler(
                type:"queryServer",
                var1:'Howdy',
                information:'I could pass something here also'
            )
          else #stop game
              $(this).triggerHandler(type:"stopGame")
    

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
          $(this).triggerHandler(type:"startGame")
        else if @instructionIndex < 3
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
      resetZoom(true)
      removeListeners()
      @instructionsDiv.parentNode.removeChild(@instructionsDiv)            
      @gameTextDiv.setAttribute("style","height:100%;width:20%;float:left;padding-left:10px;")        
      updateGameTextDiv(false)
      @buttonNext.parentNode.removeChild(@buttonNext)
      @buttonPrevious.parentNode.removeChild(@buttonPrevious)
      @rankText.textContent="Your current rank: "
      $(this).triggerHandler(
        type:"queryServer",
        var1:'Howdy',
        information:'I could pass something here also'
      )
      
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
      #@buttonNext.innerHTML = "Next"
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
      "that we have randomly positioned on the blue circle to the left."+
      "You will compete with other players, and your performance, as well as reward, "+
      "will be based on how close your final guess is to the hidden point, compared to others.\n\r"+
      "The game consists of 10 rounds. During each round, you have to make a guess "+
      "by moving the green line around the circle and clicking on a desired position. "+
      "A round finishes when all players have made their choices.\n\r"+
      "At the beginning of each round, you will be informed of your relative ranking. "+
      "Your rank is 1 if you are the player currently closest to the hidden point. "+
      "Conversely, if you are farthest from the point, you rank last.\n\r" +
      "Your starting rank for round 1 will be determined randomly.\n\r" +  
      "Click \"Next\" for a quick practice."
      
      @instructionVector[1] = "Try moving the green line around the circle and click once it is positioned at a desired location ..."
      
      @instructionVector[2] = "For increased precision, you can zoom in and out of the circle with the mouse wheel. " + 
                              "The zoom is with respect to the current position of the green line.\n\r"+
                              "Try zooming in and out a few times to get used to this functionality ... "
      
      @instructionVector[3] = "Finally, your current rank is displayed above the circle. In the example shown, "+
                              "the number in the brackets shows the total number "+
                              "of players. Your rank will be updated at the end of each round, after all players "+ 
                              " have submitted their choices, and will be presented to you at the beggining of the next round.\n\r"+
                              "With this last bit of information, the practice session ends. You can continue "+
                              "playing with the circle, in which case random rank information will be presented. "+
                              "Alternatively, you can go back to read the instructions again. If anything is left unclear, please ask the administrator.\n\r"+
                              "Once you are ready, hit \"Start\" to begin the game."
                              
     
            
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
     
      console.log(send(@serverURL,"announce"))
      $(this).on("queryServer",queryRound)
      $(this).on("startGame",startGame)
      $(this).on("stopGame",stopGame)
      $(this).on("loadme",loadme)   
    
   init()

  
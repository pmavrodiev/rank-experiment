class window.rank_experiment
  constructor: () ->
    #general browser stuff
    @windowWidth = window.innerWidth
    @windowHeight = window.innerHeight
    @buttonNext = document.getElementById("next")
    @buttonPrevious = document.getElementById("previous")
    @instructionsText = document.getElementById("instructions")
    @circleCanvasDiv = document.getElementById("circleCanvasDiv")
    @instructionsDiv = document.getElementById("instructionsDiv")
    @gameTextDiv = document.getElementById("gameTextDiv")
    @gameText = document.getElementById("gameText")
    #drawing elements
    @compositeG=document.getElementById("svgCanvas") 
    @circleCanvas=document.getElementById("circleCanvas")
    @majorCircle=document.getElementById("majorCircle") 
    @targetCircle=document.getElementById("targetCircle")
    @rememberTargetCircle = @circleCanvas.createSVGPoint()
    @currentGuess=document.getElementById("currentGuess") 
    @angleLine=document.getElementById("angleLine") 
    @rankText=document.getElementById("rankText")
    #@angleText=document.getElementById("angleText")
    #@msgText=document.getElementById("msgText")
    
    #game-related stuff
    @instructionVector = new Array()
    @instructionIndex = 0
    @gameMode = false
    @currentLevel = -1
    
    @zoom_scale = 0.2
    @zoom_level = 0 #the nestedness of the zoom
    @previous_angle = Math.PI/2
    @timedHover
    @isMacWebKit = navigator.userAgent.indexOf("Macintosh") != -1 &&
                navigator.userAgent.indexOf("WebKit") != -1
                
    @isFirefox = navigator.userAgent.indexOf("Firefox") != -1
    
    #network stuff
    @serverURL = "http://129.132.133.54:8080/"
    @registered = false
   
    
    #misc
    @flip = 0
    
    if (@isFirefox)
      window.load = @windowListen()
    else
      window.addEventListener('onload',@windowListen(),false)     
    
  ### HEADERS
  client:
  POST / HTTP/1.1
  Host: 129.132.133.54:8080
  Connection: keep-alive
  Content-Length: 8
  Origin: http://localhost:3100
  User-Agent: Mozilla/5.0 (X11; Linux i686) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.47 Safari/536.11
  Content-Type: application/xml
  Accept: '*'/'*' remove the '
  Referer: http://localhost:3100/
  Accept-Encoding: gzip,deflate,sdch
  Accept-Language: en-US,en;q=0.8,bg;q=0.6
  Accept-Charset: windows-1251,utf-8;q=0.7,*;q=0.3
  
  server:
  HTTP/1.1 200 OK
  Access-Control-Allow-Origin: *
  Access-Control-Allow-Methods: GET, POST, OPTIONS
  Access-Control-Allow-Headers: Content-Type
  Content-Type: text/html;charset=UTF-8
  Content-Length: 0
  Server: Jetty(8.1.4.v20120524)
  ###        
  windowListen: () ->
    # the objects in the SVG code
  
   getCursorPosition = (e) => 
      pt = @circleCanvas.createSVGPoint()
      pt.x = e.clientX
      pt.y = e.clientY

   
      transformation_matrix = @compositeG.getScreenCTM()
      pt2 = pt.matrixTransform(transformation_matrix.inverse())  
      return pt2
   
  
          
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
        
      
    
   getRankCurLevel = () =>
      #send a POST request asking for rank info about the current level
      srvResponse = send(@serverURL,"Rank "+@currentLevel)
      console.log("Server said " + srvResponse)
      expectedResponse = "OK " + @currentLevel
      if srvResponse != expectedResponse
        setTimeout(3000)
        getRankCurLevel()
        
      console.log("HELL YEAH")      
   
   
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
   
   resetZoom = () =>
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
      #tm*s=tmscaled => s = tm^-1 * tmscaled
      s = "matrix("+ smatrix.a + "," +smatrix.b + "," +smatrix.c + "," + smatrix.d + "," +smatrix.e+ "," +smatrix.f+")"  
      @compositeG.setAttribute("transform",s)
      @zoom_level = 0
      #tm2 = @compositeG.getScreenCTM()
   
   ccMouseClick = (e) =>
      e = e || window.event
      coord = getCursorPosition(e)    
      @previous_angle = Math.atan2(coord.y,coord.x)
      radius = @majorCircle.attributes[3].value
      @currentGuess.setAttribute("cx",radius*Math.cos(@previous_angle))
      @currentGuess.setAttribute("cy",radius*Math.sin(@previous_angle))

      animatedElement = @circleCanvas.getElementsByTagName('animate')
      animatedElement[0].attributes[2].nodeValue = "1s"  
      animatedElement[0].beginElement()
      
      if !@flip and @instructionIndex == 1
        @instructionsText.textContent += "\n\rThe small red circle at the selected position shows your last quess.\n\r"
        @buttonNext.disabled=false
        @flip = 1
      
      if @rankText.textContent!= ""
        @rankText.textContent="Your Rank: "+ Math.floor(1+Math.random()*25) + " (25)"
      
      #@circleCanvas.removeEventListener('mousemove',ccMouseMove)
      #@circleCanvas.removeEventListener('click',ccMouseClick)      
      #setTimeout(restartGuessingTask, 4000)  
    
  
   
   
   ccMouseMove = (e) =>
      e = e || window.event
      coord = getCursorPosition(e)
      angle = Math.atan2(coord.y,coord.x)
      radius = @majorCircle.attributes[3].value
      @angleLine.setAttribute("x2",radius*Math.cos(angle))
      @angleLine.setAttribute("y2",radius*Math.sin(angle))

      @targetCircle.setAttribute("cx",radius*Math.cos(angle))
      @targetCircle.setAttribute("cy",radius*Math.sin(angle))



  
   restartGuessingTask = () =>    
      @circleCanvas.addEventListener('click', ccMouseClick, false)

      
        
   next = () =>
      if !@gameMode 
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
          @buttonNext.innerHTML = "Start"
          @buttonNext.disabled=false
          @gameMode = true
      
        resetZoom()
        
      else
        resetZoom()
        @instructionsDiv.parentNode.removeChild(@instructionsDiv)            
        styleIndex = 1
        #in Firefox the style information is the 0th attribute of the element
        #in Chrome it is the 1st. That's why we calculate the proper index'
        if @isFirefox 
          styleIndex = 0
        @gameTextDiv.attributes[styleIndex].nodeValue = "height:100%;width:20%;float:left;"
        @buttonNext.parentNode.removeChild(@buttonNext)
        @buttonPrevious.parentNode.removeChild(@buttonPrevious)
        @currentLevel = 0
        getRankCurLevel()
        
    
   prev = () =>  
      @flip = 0
      @gameMode = false
      @buttonPrevious.disabled=false  
      @buttonNext.innerHTML = "Next"
      @instructionIndex--
      if @instructionIndex<=0 
        @instructionIndex=0
        @buttonPrevious.disabled=true
        @buttonNext.disabled=false
      else
        @buttonPrevious.disabled=false

      @instructionsText.textContent = @instructionVector[@instructionIndex]
      
      resetZoom()      
      if @instructionIndex != 0
        @buttonNext.disabled=true
      
   initInstructions = () =>
      @instructionVector[0] = "Welcome to our guessing game."+ 
      "The purpose of the game is to find out the location of a hidden point " +
      "that we have randomly positioned on the blue circle to the left."+
      "You will compete with other players, and your performance, as well as reward, "+
      "will be based on how close your guess is to the hidden point, compared to others.\n\r"+
      "The game consists of 10 rounds. During each round, you have to make a guess "+
      "by moving the green line around the circle and clicking on a desired position. "+
      "A round finishes when all players have made their choices.\n\r"+
      "At the beginning of each round, you will be informed of your relative ranking. "+
      "Your rank is 1 if you are the player currently closest to the hidden point. "+
      "Conversely, if you are farthest from the point, you rank last.\n\r" + 
      "Click \"Next\" for a quick practice."
      
      @instructionVector[1] = "Try moving the green line around the circle and click once it is positioned at a desired location ..."
      
      @instructionVector[2] = "For increased precision, you can zoom in and out of the circle with the mouse wheel. " + 
                              "The zoom is with respect to the current position of the green line.\n\r"+
                              "Try zooming in and out a few times to get used to this functionality ... "
      
      @instructionVector[3] = "Finally, your current rank is displayed above the circle. "+
                              "The number in the brackets shows the total number "+
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
   
   init = () =>
     
    
      #addListeners()
    
      #buttons
      @buttonNext.onclick = next
      @buttonPrevious.onclick = prev
      @buttonPrevious.disabled=true
      
      initInstructions()
      #connect("http://192.168.1.52:8080/",params, "GET")
      console.log(send(@serverURL,"announce"))
           
      
   
    
   init()

  
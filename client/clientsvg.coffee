class window.rank_experiment
  constructor: () ->
    @compositeG=document.getElementById "svgCanvas" 
    @circleCanvas=document.getElementById("circleCanvas")
    @majorCircle=document.getElementById("majorCircle") 
    @targetCircle=document.getElementById("targetCircle")
    @rememberTargetCircle = @circleCanvas.createSVGPoint()
    @currentGuess=document.getElementById("currentGuess") 
    @angleLine=document.getElementById("angleLine") 
    @rankText=document.getElementById("rankText")
    @angleText=document.getElementById("angleText")
    @msgText=document.getElementById("msgText")
 

    
    @viewport_size=1050
    @viewport_axis_x = 525 #the translated x axis of the <g> component in svgcanvas.html
    @viewport_axis_y = 490 #the translated y axis of the <g> component in svgcanvas.html
  

    @zoom_scale = 0.2
    @zoom_level = 1 #the nestedness of the zoom
    @previous_angle = Math.PI/2
  
    @rankTextOpacity = 1  
    @timedHover
    @isMacWebKit = navigator.userAgent.indexOf("Macintosh") != -1 &&
                navigator.userAgent.indexOf("WebKit") != -1
                
    @isFirefox = navigator.userAgent.indexOf("Gecko") != -1
    
    window.addEventListener('onload',@windowListen(),false)     
    

          
  windowListen: () ->
    # the objects in the SVG code
  
   getCursorPosition = (e) => 
      pt = @circleCanvas.createSVGPoint()
      pt.x = e.x
      pt.y = e.y

      #transformation_matrix = @circleCanvas.getScreenCTM()
      transformation_matrix = @compositeG.getScreenCTM()
      pt2 = pt.matrixTransform(transformation_matrix.inverse())  
      return pt2
      
      
   
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
      zoom = 0
      
      if (deltaY > 0) 
        zoom = 1
      if (deltaY < 0) 
        zoom = -1
      ###  
      Most browsers generate one event with delta 120 per mousewheel click.
      On Macs, however, the mousewheels seem to be velocity-sensitive and
     the delta values are often larger multiples of 120, at
      least with the Apple Mouse. Use browser-testing to defeat this.
      ###
      if (@isMacWebKit) 
        deltaX /= 30;
        deltaY /= 30;
      
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
      if @zoom_level == 1
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
      tm2 = @compositeG.getScreenCTM()
      return false  
   
   ccMouseClick = (e) =>
      coord = getCursorPosition(e)    
      @previous_angle = Math.atan2(coord.y,coord.x)
      radius = @majorCircle.attributes[3].value
      @currentGuess.setAttribute("cx",radius*Math.cos(@previous_angle))
      @currentGuess.setAttribute("cy",radius*Math.sin(@previous_angle))

      @circleCanvas.getElementsByTagName('animate')[0].beginElement()
      @circleCanvas.removeEventListener('mousemove',ccMouseMove)
      @circleCanvas.removeEventListener('click',ccMouseClick)
      @msgText.textContent = "Wait for your opponents to guess..."
      @msgText.style.fill="green"
      @rankTextOpacity = 1
      
      setTimeout(restartGuessingTask, 4000)  
    
  
   
   
   ccMouseMove = (e) =>
      coord = getCursorPosition(e)
      angle = Math.atan2(coord.y,coord.x)
      radius = @majorCircle.attributes[3].value
      @angleLine.setAttribute("x2",radius*Math.cos(angle))
      @angleLine.setAttribute("y2",radius*Math.sin(angle))

      @targetCircle.setAttribute("cx",radius*Math.cos(angle))
      @targetCircle.setAttribute("cy",radius*Math.sin(angle))



  
   restartGuessingTask = () =>
      @rankText.textContent = "Your new rank is: "+ Math.ceil( Math.random()*20) 
      @rankText.style.fill="black"
      @rankTextOpacity = 1
    
      @circleCanvas.addEventListener('click', ccMouseClick, false)
  

  

  
  
   init = () =>
    
      @compositeG.addEventListener('mousemove', ccMouseMove, false) #fired when mouse is moved
      @circleCanvas.addEventListener('click', ccMouseClick, false) #fired when mouse is pressed AND released
      #add mousewheel event   
      @circleCanvas.onwheel = ccMouseWheel #future browsers
      @circleCanvas.onmousewheel = ccMouseWheel #most current browsers
      if (@isFirefox)
        @circleCanvas.addEventListener("DOMMouseScroll",ccMouseWheel,false)
    
      @rankText.textContent = ""

    
    
   init()

  
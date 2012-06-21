class window.rank_experiment
  constructor: () ->
    @compositeG=document.getElementById "svgCanvas" 
    @circleCanvas=document.getElementById("circleCanvas")
    @majorCircle=document.getElementById("majorCircle") 
    @targetCircle=document.getElementById("targetCircle") 
    @currentGuess=document.getElementById("currentGuess") 
    @angleLine=document.getElementById("angleLine") 
    @rankText=document.getElementById("rankText")
    @angleText=document.getElementById("angleText")
    @msgText=document.getElementById("msgText")
   

    
    @viewport_size=1050
    @viewport_axis_x = 525 #the translated x axis of the <g> component in svgcanvas.html
    @viewport_axis_y = 490 #the translated y axis of the <g> component in svgcanvas.html
    @centre_coord=circleCanvas.createSVGPoint()

    @zoom_scale = 0.2
    
    @previous_angle = Math.PI/2
  
    @rankTextOpacity = 1  
    @timedHover
    @isMacWebKit = navigator.userAgent.indexOf("Macintosh") != -1 &&
                navigator.userAgent.indexOf("WebKit") != -1
                
    @isFirefox = navigator.userAgent.indexOf("Gecko") != -1
    
    window.addEventListener('load',@windowListen(),false)     

    #window.addEventListener('load',@windowListen2(),false)
    
  windowListen2: () ->
    getCursorPosition2 = (e) => 
      pt = @circleCanvas.createSVGPoint()
      pt.x = e.x
      pt.y = e.y
      #transformation_matrix = @circleCanvas.getScreenCTM()
      transformation_matrix = @compositeG.getScreenCTM()
      pt2 = pt.matrixTransform(transformation_matrix.inverse())
      return pt2
      
    ccMouseClick2 = (e) =>
     coord = getCursorPosition2(e)
     xtmparent =  @circleCanvas.createSVGPoint(); xtm =  @circleCanvas.createSVGPoint(); circle_xy=@circleCanvas.createSVGPoint();
     xtmparent.x = e.x; xtmparent.y = e.y; xtm.x =  coord.x; xtm.y = coord.y
     circle_xy.x = @littleCircle.cx.baseVal.value
     circle_xy.y = @littleCircle.cy.baseVal.value
     
     tm = @compositeG.getScreenCTM()
     tmscaled = tm.scale(1.75)
     tmparent = @circleCanvas.getScreenCTM()
     xtmscaled = xtmparent.matrixTransform(tmscaled.inverse())
     circleParent = circle_xy.matrixTransform(tm)      
     circleScaled = circleParent.matrixTransform(tmscaled.inverse())
     smatrix = tmparent.inverse().multiply(tmscaled)
     
     s = "matrix("+ smatrix.a + "," +smatrix.b + "," +smatrix.c + "," + smatrix.d + "," +smatrix.e+ "," +smatrix.f+")"
     @littleCircle.setAttribute("cx",circleScaled.x)     
     @littleCircle.setAttribute("cy",circleScaled.y)
     @compositeG.setAttribute("transform",s)
     
     tmnew2 =  @compositeG.getScreenCTM()
     
     
    ccMouseMove2 = (e) =>
     coord = getCursorPosition2(e)    
     console.log(e.x+":"+e.y+":::"+coord.x + ":" + coord.y)
     
    animateRankText = () =>
    
    update_zoom = () =>
        ###
      viewport.setAttribute("transform",
                              "translate("+ centre_coord.x+","+ centre_coord.y +") "+
            "scale("+zoom_positions[zoom_level]+","+(-zoom_positions[zoom_level])+")")
        ###
  
    init_canvas = () =>
      #@angleLine.setAttribute("x2",@radius*Math.cos(@previous_angle))
      #@angleLine.setAttribute("y2",@radius*Math.sin(@previous_angle))
      #@centre_coord.x=@viewport_axis_x
      #@centre_coord.y=@viewport_axis_y
      #centre_coord.x=viewport_size*zoom_positions[zoom_level]/2
      #centre_coord.y=viewport_size*zoom_positions[zoom_level]/2
      update_zoom()
  
  
    init = () =>
      @zoom_level = 0.2
    
      @compositeG.addEventListener('mousemove', ccMouseMove2, false) #fired when mouse is moved
      @compositeG.addEventListener('click', ccMouseClick2, false) #fired when mouse is pressed AND released
      #add mousewheel event   
      #@circleCanvas.onwheel = ccMouseWheel #future browsers
      #@circleCanvas.onmousewheel = ccMouseWheel #most current browsers
      #if (@isFirefox)
       # @circleCanvas.addEventListener("DOMMouseScroll",ccMouseWheel,false)
    
      #@rankText.textContent = ""

      init_canvas()
    
    init()

  
          
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
      #if (e.preventDefault) e.preventDefault();
      #if (e.stopPropagation) e.stopPropagation();
      #e.cancelBubble = true; #IE events
      #e.returnValue = false; #IE events
      zoomLevel = Math.pow(1+@zoom_scale,deltaY)
      coord = getCursorPosition(e);
      circle_xy = @circleCanvas.createSVGPoint();   line_y = @circleCanvas.createSVGPoint()
      circle_xy.x = @targetCircle.cx.baseVal.value; circle_xy.y = @targetCircle.cy.baseVal.value
      tm = @compositeG.getScreenCTM()
      tmscaled = tm.scale(zoomLevel)
      tmparent = @circleCanvas.getScreenCTM()
      circleParent = circle_xy.matrixTransform(tm)
      circleScaled = circleParent.matrixTransform(tmscaled.inverse())
      smatrix = tmparent.inverse().multiply(tmscaled)   
      s = "matrix("+ smatrix.a + "," +smatrix.b + "," +smatrix.c + "," + smatrix.d + "," +smatrix.e+ "," +smatrix.f+")"
      @targetCircle.setAttribute("cx",circleScaled.x)
      @targetCircle.setAttribute("cy",circleScaled.y)
      @angleLine.setAttribute("x2",circleScaled.x) 
      @angleLine.setAttribute("y2",circleScaled.y)
      @majorCircle.setAttribute("r",Math.sqrt(Math.pow(circleScaled.x,2)+Math.pow(circleScaled.y,2)))
      @compositeG.setAttribute("transform",s)
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
      animateRankText()
      setTimeout(restartGuessingTask, 4000)  
    
  

   ccMouseMove = (e) =>
      coord = getCursorPosition(e)
      angle = Math.atan2(coord.y,coord.x)
      radius = @majorCircle.attributes[3].value
      @angleLine.setAttribute("x2",radius*Math.cos(angle))
      @angleLine.setAttribute("y2",radius*Math.sin(angle))

      @targetCircle.setAttribute("cx",radius*Math.cos(angle))
      @targetCircle.setAttribute("cy",radius*Math.sin(angle))
      #console.log(coord.x+":"+coord.y+":"+angle)
      # gets the position in the box = circleCanvas.getBBox()

   animateRankText = () =>
  
   restartGuessingTask = () =>
      @rankText.textContent = "Your new rank is: "+ Math.ceil( Math.random()*20) 
      @rankText.style.fill="black"
      @rankTextOpacity = 1
      animateRankText()
      @zoom_level = 0

      @circleCanvas.addEventListener('mousemove', ccMouseMove, false)
      @circleCanvas.addEventListener('click', ccMouseClick, false)
  
   update_zoom = () =>
        ###
      viewport.setAttribute("transform",
                              "translate("+ centre_coord.x+","+ centre_coord.y +") "+
            "scale("+zoom_positions[zoom_level]+","+(-zoom_positions[zoom_level])+")")
        ###
  
   init_canvas = () =>
      #@angleLine.setAttribute("x2",@radius*Math.cos(@previous_angle))
      #@angleLine.setAttribute("y2",@radius*Math.sin(@previous_angle))
      @centre_coord.x=@viewport_axis_x
      @centre_coord.y=@viewport_axis_y
      #centre_coord.x=viewport_size*zoom_positions[zoom_level]/2
      #centre_coord.y=viewport_size*zoom_positions[zoom_level]/2
      update_zoom()
  
  
   init = () =>
      @zoom_level = 0.2
    
      @compositeG.addEventListener('mousemove', ccMouseMove, false) #fired when mouse is moved
      @circleCanvas.addEventListener('click', ccMouseClick, false) #fired when mouse is pressed AND released
      #add mousewheel event   
      @circleCanvas.onwheel = ccMouseWheel #future browsers
      @circleCanvas.onmousewheel = ccMouseWheel #most current browsers
      if (@isFirefox)
        @circleCanvas.addEventListener("DOMMouseScroll",ccMouseWheel,false)
    
      @rankText.textContent = ""

      init_canvas()
    
   init()

  
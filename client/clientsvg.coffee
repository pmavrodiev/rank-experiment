class window.rank_experiment
  constructor: () ->
    @compositeG=document.getElementById "svgCanvas" 
    @circleCanvas=document.getElementById("circleCanvas")
    ###
    @majorCircle=document.getElementById("majorCircle") 
    @targetCircle=document.getElementById("targetCircle") 
    @currentGuess=document.getElementById("currentGuess") 
    @angleLine=document.getElementById("angleLine") 
    @rankText=document.getElementById("rankText")
    @angleText=document.getElementById("angleText")
    @msgText=document.getElementById("msgText")
   

    @radius = 480
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
    ###
    window.addEventListener('load',@windowListen2(),false)
    
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
     tm = @compositeG.getScreenCTM()
     tmparent = @circleCanvas.getScreenCTM()
     p = @circleCanvas.createSVGMatrix()
     p2 = p.translate(coord.x,coord.y)
     p3 = p2.scale(1.33)
     p4 = p3.translate(-coord.x/1.33,-coord.y/1.33)
     p5 = tm.multiply(p4)
     #s = "matrix("+ p5.a + "," + p5.b + "," +p5.c + "," +p5.d + "," +p5.e + "," +p5.f + ")"
     zoom = (1+2*tm.a)
     translation_x = tm.e
     translation_y = tm.f + zoom*coord.y
     s = "matrix("+ zoom + "," +tm.b + "," +tm.c + "," + (-zoom) + "," +translation_x+ "," +translation_y+")"
     @compositeG.setAttribute("transform",s)
     
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
      #pt2.x -= @centre_coord.x
      #pt2.y = @centre_coord.y  - pt2.y      
      return pt2
      
      
   
   ccMouseWheel = (event) =>
      sgn = (x) =>
        if(x>0)
          return 1
        else if(x<0)
          return -1
        else 
          return 0  
   
      e = event || window.event; #standard or IE event object
      coord = getCursorPosition(e);
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
      
      if (deltaY > 0) 
        @zoom_level++;
      if (deltaY < 0) 
        @zoom_level--;
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
      zoom = Math.pow(1+@zoom_scale,deltaY)
      #translate_x = @centre_coord.x+(sgn(zoom-1))*coord.x*(zoom-1);
      #translate_y = @centre_coord.y+(sgn(zoom-1))*coord.y*(zoom-1);
      
      #@compositeG.setAttribute("transform", 
       #     "translate("+translate_x+","+translate_y+") "+
        #    "scale("+zoom+","+(-zoom)+")")
      km = @circleCanvas.createSVGMatrix() 
      km_scaled = km.translate(coord.x,coord.y)
      km_scaled_zoomed = km_scaled.scaleNonUniform(zoom,zoom)
      km_scaled_zoomed_translated = km_scaled_zoomed.translate(-coord.x,-coord.y)
      
      k = km_scaled_zoomed_translated
      
      tm = @circleCanvas.getCTM()  
      m = tm.multiply(k)
     
      s = "matrix(" + m.a + ","+m.b + ","+m.c + ","+m.d + ","+m.e + ","+m.f+")" 
      @circleCanvas.setAttribute("transform",s)
      return false  
   
   ccMouseClick = (e) =>
      coord = getCursorPosition(e)    
      @previous_angle = Math.atan2(coord.y,coord.x)

      @currentGuess.setAttribute("cx",@radius*Math.cos(@previous_angle))
      @currentGuess.setAttribute("cy",@radius*Math.sin(@previous_angle))

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
      @angleLine.setAttribute("x2",@radius*Math.cos(angle))
      @angleLine.setAttribute("y2",@radius*Math.sin(angle))

      @targetCircle.setAttribute("cx",@radius*Math.cos(angle))
      @targetCircle.setAttribute("cy",@radius*Math.sin(angle))
      console.log(coord.x+":"+coord.y+":"+angle)
      # gets the position in the box = circleCanvas.getBBox()
      box = @circleCanvas.getBBox()
      #rankText.textContent = "["+ zoom_positions[zoom_level].toFixed(2)+"] "+ ( coord.x/zoom_positions[zoom_level] ).toFixed(2)+", "+ ( coord.y/zoom_positions[zoom_level] ).toFixed(2)
      #angleText.textContent = "("+(box.x/zoom_positions[zoom_level]).toFixed(2)+","+(box.y/zoom_positions[zoom_level]).toFixed(2)+") --> (" + (box.width/zoom_positions[zoom_level]).toFixed(2)+","+(box.height/zoom_positions[zoom_level]).toFixed(2)+ ")" 

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
    
      #@compositeG.addEventListener('mousemove', ccMouseMove, false) #fired when mouse is moved
      @circleCanvas.addEventListener('click', ccMouseClick2, false) #fired when mouse is pressed AND released
      #add mousewheel event   
      #@circleCanvas.onwheel = ccMouseWheel #future browsers
      #@circleCanvas.onmousewheel = ccMouseWheel #most current browsers
      #if (@isFirefox)
       # @circleCanvas.addEventListener("DOMMouseScroll",ccMouseWheel,false)
    
      @rankText.textContent = ""

      init_canvas()
    
   init()

  
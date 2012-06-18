class window.rank_experiment
  constructor: () ->
    @viewport=document.getElementById "viewport" 
    @majorCircle=document.getElementById("majorCircle") 
    @targetCircle=document.getElementById("targetCircle") 
    @currentGuess=document.getElementById("currentGuess") 
    @angleLine=document.getElementById("angleLine") 
    @rankText=document.getElementById("rankText")
    @angleText=document.getElementById("angleText")
    @msgText=document.getElementById("msgText")
    @circleCanvas=document.getElementById("circleCanvas")

    @radius = 480
    @viewport_size=1050
    @viewport_axis_x = 525 #the translated x axis of the <g> component in svgcanvas.html
    @viewport_axis_y = 490 #the translated y axis of the <g> component in svgcanvas.html
    @centre_coord=circleCanvas.createSVGPoint()

    @zoom_level = 0
    @zoom_positions = new Array(11)
    @previous_angle = Math.PI/2
  
    @rankTextOpacity = 1  
    @timedHover
    @isMacWebKit = navigator.userAgent.indexOf("Macintosh") != -1 &&
                navigator.userAgent.indexOf("WebKit") != -1
                
    @isFirefox = navigator.userAgent.indexOf("Gecko") != -1
    
    window.addEventListener('load',@windowListen(),false)     
    
  windowListen: () ->
    # the objects in the SVG code
  
    getCursorPosition = (e) => 
      pt = @circleCanvas.createSVGPoint()
      pt.x = e.x
      pt.y = e.y

      transformation_matrix = @circleCanvas.getScreenCTM()
      pt2 = pt.matrixTransform(transformation_matrix.inverse())
      pt2.x -= @centre_coord.x
      pt2.y = @centre_coord.y  - pt2.y
      return pt2
      
   
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
      @angleLine.setAttribute("x2",@radius*Math.cos(@previous_angle))
      @angleLine.setAttribute("y2",@radius*Math.sin(@previous_angle))
      @centre_coord.x=@viewport_axis_x
      @centre_coord.y=@viewport_axis_y
      #centre_coord.x=viewport_size*zoom_positions[zoom_level]/2
      #centre_coord.y=viewport_size*zoom_positions[zoom_level]/2
      update_zoom()
  
  
    init = () =>
      # :::~ Initialisation sequence
      for i in [0..(@zoom_positions.length-1)]
        @zoom_positions[i] = Math.exp( i*3/(@zoom_positions.length-1) * Math.log(2) ) # between 1 and 8
      
      @zoom_level = 0
    
      @circleCanvas.addEventListener('mousemove', ccMouseMove, false) #fired when mouse is moved
      @circleCanvas.addEventListener('click', ccMouseClick, false) #fired when mouse is pressed AND released
      #add mousewheel event   
      #@viewport.onwheel = ccMouseWheel #future browsers
      #@viewport.onmousewheel = ccMouseWheel #most current browsers
      #if (@isFirefox)
       # @viewport.addEventListener("DOMMouseScroll",ccMouseWheel,false)
    
      @rankText.textContent = ""

      init_canvas()
    
    init()

  
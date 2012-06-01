if(window.addEventListener) {

  

  window.addEventListener('load', function () {
  
  var circleCanvas=document.getElementById("circleCanvas");
  // :::~ the objects in the SVG code
  var compositeG=document.getElementById("compositeG"); 
  var majorCircle=document.getElementById("majorCircle"); 
  var targetCircle=document.getElementById("targetCircle"); 
  var currentGuess=document.getElementById("currentGuess"); 
  var angleLine=document.getElementById("angleLine"); 
  var rankText=document.getElementById("rankText"); 

  var rankTextOpacity = 1.;

  var radius = 500;
  var viewport_size=1024;
  var centre_coord=circleCanvas.createSVGPoint();

  var zoom_level = 0;
  var zoom_positions = new Array(11);
  var previous_angle = Math.PI/2.;
  
  
  var target_phase;
  var player_guesses = new Array(15);
  var guesses_error = new Array(15);
  
  
  function getCursorPosition(e) {
    var pt = circleCanvas.createSVGPoint();
    pt.x = e.clientX;
    pt.y = e.clientY;

    var pt2= pt.matrixTransform(circleCanvas.getScreenCTM().inverse());
    pt2.x -= centre_coord.x;
    pt2.y = centre_coord.y  - pt2.y;
    return pt2;
  }


  function ccMouseClick(e){
    coord = getCursorPosition(e);
    if(coord.y>466 && coord.x<-360)
       return;
    
    previous_angle = Math.atan2(coord.y,coord.x);
    rankText.textContent = angle / Math.PI *180;

    currentGuess.setAttribute("cx",radius*Math.cos(previous_angle));
    currentGuess.setAttribute("cy",radius*Math.sin(previous_angle));

    circleCanvas.getElementsByTagName('animate')[0].beginElement();
    circleCanvas.removeEventListener('mousemove',ccMouseMove);
    circleCanvas.removeEventListener('click',ccMouseClick);
    rankText.textContent = "Wait for your opponents to guess...";
    rankText.style.fill="green";
    rankTextOpacity = 1;
    animateRankText(  );
    
    setTimeout(restartGuessingTask, 4000);
  }

  function animateRankText(  ){
    rankTextOpacity /= 1.02;
   	rankText.setAttribute("opacity",rankTextOpacity);

    if(rankTextOpacity>0.01)
      setTimeout( animateRankText, 50 );
    else{
    	rankText.textContent = "";
    	rankText.setAttribute("opacity",0);
    	
    }
  }

  function restartGuessingTask(){
    rankText.textContent = "Your new rank is: "+ Math.ceil( Math.random()*20) ;
    rankText.style.fill="black";
    rankTextOpacity = 1;
  	animateRankText(  );

    zoom_level = 0;
    
    circleCanvas.addEventListener('mousemove', ccMouseMove, false);
    circleCanvas.addEventListener('click', ccMouseClick, false);
      	
  }

  function ccMouseMove(e) {
    coord = getCursorPosition(e);

    angle = Math.atan2(coord.y,coord.x);
    angleLine.setAttribute("x2",radius*Math.cos(angle));
    angleLine.setAttribute("y2",radius*Math.sin(angle));

    targetCircle.setAttribute("cx",radius*Math.cos(angle));
    targetCircle.setAttribute("cy",radius*Math.sin(angle));
    
    rankText.textContent = angle/Math.PI*180.;

  }

  function update_zoom(){
    centre_coord.x=viewport_size*zoom_positions[zoom_level]/2;
    centre_coord.y=viewport_size*zoom_positions[zoom_level]/2;
    compositeG.setAttribute("transform",
                             "translate("+ centre_coord.x+","+ centre_coord.y +") "+
                             "scale("+zoom_positions[zoom_level]+","+-zoom_positions[zoom_level]+")")
  }
    
  function init_canvas(){
     angleLine.setAttribute("x2",radius*Math.cos(previous_angle));
     angleLine.setAttribute("y2",radius*Math.sin(previous_angle));

     update_zoom();
  }
  
  function init () {
    // :::~ Initialisation sequence
    for(i=0;i<zoom_positions.length;i++){
       zoom_positions[i] = Math.exp( i*3./(zoom_positions.length-1) * Math.log(2.) ); // between 1 and 8
    }
    zoom_level = 0;
    
    circleCanvas.addEventListener('mousemove', ccMouseMove, false);
    circleCanvas.addEventListener('click', ccMouseClick, false);
    
    document.getElementById('buttonZoomOut').addEventListener('click', function (e){
        if(zoom_level==0) return; zoom_level-=1; update_zoom();
    }, false);
    document.getElementById('buttonZoomIn').addEventListener('click', function (e){
        if(zoom_level==zoom_positions.length-1) return; zoom_level+=1; update_zoom();
    }, false);
    document.getElementById('buttonZoomReset').addEventListener('click',  function (e){
        zoom_level=0; update_zoom();
    }, false);

    init_canvas();
  }

  function init_players(){
  	target_phase = Math.random() * 2. * Math.PI -Math.PI;
   
     for(i=0;i<player_guesses.length;i++){
         target_phase[i]  = Math.random() * 2. * Math.PI -Math.PI;
     }
     
  }

  init();
}, false); }

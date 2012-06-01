

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
  var rankText2=document.getElementById("rankText2");
  var rankText3=document.getElementById("rankText3");
  
  var radius = 480;
  var viewport_size=1050;
  var centre_coord=circleCanvas.createSVGPoint();

  var zoom_level = 0;
  var zoom_positions = new Array(11);
  var previous_angle = Math.PI/2.;
  
  var rankTextOpacity = 1.;
  
  var timedHover;
  
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
    
    previous_angle = Math.atan2(coord.y,coord.x);
//     rankText.textContent = angle / Math.PI *180;

    currentGuess.setAttribute("cx",radius*Math.cos(previous_angle));
    currentGuess.setAttribute("cy",radius*Math.sin(previous_angle));

    circleCanvas.getElementsByTagName('animate')[0].beginElement();
    circleCanvas.removeEventListener('mousemove',ccMouseMove)
    circleCanvas.removeEventListener('click',ccMouseClick)
    rankText3.textContent = "Wait for your opponents to guess...";
    rankText3.style.fill="green";
    rankTextOpacity = 1;
    animateRankText(  );
    setTimeout(restartGuessingTask, 4000);  
    
  }

  function ccMouseMove(e) {
    coord = getCursorPosition(e);

    angle = Math.atan2(coord.y,coord.x);
    angleLine.setAttribute("x2",radius*Math.cos(angle));
    angleLine.setAttribute("y2",radius*Math.sin(angle));

    targetCircle.setAttribute("cx",radius*Math.cos(angle));
    targetCircle.setAttribute("cy",radius*Math.sin(angle));

    // gets the position in the 
//     box = circleCanvas.getBBox();
    box = circleCanvas.getBBox();
    rankText.textContent = "["+ zoom_positions[zoom_level].toFixed(2)+"] "+ ( coord.x/zoom_positions[zoom_level] ).toFixed(2)+", "+ ( coord.y/zoom_positions[zoom_level] ).toFixed(2)
    rankText2.textContent = "("+(box.x/zoom_positions[zoom_level]).toFixed(2)+","+(box.y/zoom_positions[zoom_level]).toFixed(2)+") --> ("
                             + (box.width/zoom_positions[zoom_level]).toFixed(2)+","+(box.height/zoom_positions[zoom_level]).toFixed(2)+")";

  }

  function hoverHandle(e){
    coord = getCursorPosition(e);
    
    // gets the position in the 
    box = circleCanvas.getBBox();
    rankText3.textContent = "++"+ zoom_positions[zoom_level]+"] "+ coord.x +", "+ coord.y +" ... "+  box.height + "," + box.width;
  }
  
  function animateRankText(  ){
//     rankTextOpacity /= 1.02;
//     rankText.setAttribute("opacity",rankTextOpacity);
//     if(rankTextOpacity>0.01)
//       setTimeout( animateRankText, 50 );
//     else{
//       rankText.textContent = "";
//       rankText.setAttribute("opacity",0);
// 
//     }
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
  
  
  
  function hoveringIn(e_id){
//         centre_coord.x=viewport_size*zoom_positions[zoom_level]/2.;
//         centre_coord.y=viewport_size*zoom_positions[zoom_level]/2.;
        foo = "";
        if(e_id=="up"){
	 if (centre_coord.y/zoom_positions[zoom_level] > 2.*radius ) 
          centre_coord.y -= 10;
	 else foo = "..rejecting.."+e_id;
	}
        if(e_id=="down"){
	  if (centre_coord.y/zoom_positions[zoom_level]  < 0) 
            centre_coord.y += 10;
	 else foo = "..rejecting.."+e_id;
	}
        if(e_id=="right"){
          if (centre_coord.x/zoom_positions[zoom_level] < 2*radius ) 
            centre_coord.x += 10;
	 else foo = "..rejecting.."+e_id;
	}  
        if(e_id=="left"){
          if (centre_coord.x/zoom_positions[zoom_level] > 0 ) 
            centre_coord.x -= 10;
	 else foo = "..rejecting.."+e_id;
	}
        compositeG.setAttribute("transform",
                                  "translate("+ centre_coord.x+","+ centre_coord.y +") "+
                                  "scale("+zoom_positions[zoom_level]+","+-zoom_positions[zoom_level]+")" );
//  	rankText.textContent = "mouse in: "+e_id;
        rankText3.textContent = "["+zoom_positions[zoom_level].toFixed(2)+"]"+"_-_"+"("+ centre_coord.x.toFixed(2)+","+centre_coord.y.toFixed(2)+")  "+foo;
	timedHover = setTimeout(function (){hoveringIn(e_id);},10);
  }
  
  function update_zoom(){
    compositeG.setAttribute("transform",
                             "translate("+ centre_coord.x+","+ centre_coord.y +") "+
                             "scale("+zoom_positions[zoom_level]+","+-zoom_positions[zoom_level]+")")
  }
    
  function init_canvas(){
     angleLine.setAttribute("x2",radius*Math.cos(previous_angle));
     angleLine.setAttribute("y2",radius*Math.sin(previous_angle));
     centre_coord.x=viewport_size*zoom_positions[zoom_level]/2;
     centre_coord.y=viewport_size*zoom_positions[zoom_level]/2;

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
        if(zoom_level<=0) return; zoom_level-=1; update_zoom();
    }, false);
    document.getElementById('buttonZoomIn').addEventListener('click', function (e){
        if(zoom_level>=zoom_positions.length-1) return; zoom_level+=1; update_zoom();
    }, false);
    document.getElementById('buttonZoomReset').addEventListener('click',  function (e){
        zoom_level=0; update_zoom();
	
        centre_coord.x=viewport_size*zoom_positions[zoom_level]/2.;
        centre_coord.y=viewport_size*zoom_positions[zoom_level]/2.;
    }, false);
    rankText.textContent = "";

    $(".zoomHandle").bind(
      'mouseenter', function (e){
          hoveringIn(e.target.id);
	  e.target.setAttribute("opacity","1");
       }) ;
    $(".zoomHandle").bind(
      'mouseleave', function (e){
//           rankText.textContent = "mouse leave"+e.target.id;
	  clearTimeout(timedHover);
	  e.target.setAttribute("opacity","0.2");
       }) ;
        
    
    init_canvas();
  }

  init();
}, false); }

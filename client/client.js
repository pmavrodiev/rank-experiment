if(window.addEventListener) {
window.addEventListener('load', function () {
  var circleCanvas=document.getElementById("circleCanvas");
  var ccDrawingContext=circleCanvas.getContext("2d");
  var coordField=document.getElementById("coordinate");
  var centreCoord= new Coordinate( 
                  circleCanvas.width/2-circleCanvas.offsetLeft, 
                  circleCanvas.height/2-circleCanvas.offsetTop  );  
  var radius = 350;
  
  
  var previous_angle = Math.PI/2.;
  
  function Coordinate(xx, yy) {
    this.x = xx;
    this.y = yy;
    
  }
  
  
  function getCursorPosition(e) {
    /* returns Coordinate with .row and .column properties */
    var x;
    var y;
    if (e.pageX || e.pageY) { 
      x = e.pageX;
      y = e.pageY;
    } else { 
      x = e.offsetX;
      y = e.offsetY;
// //     var out="(";
//     out += coord.x;
//     out += ", ";
//     out += coord.y;
//     out += ")";
//       document.write(out);      
    } 
    x -= circleCanvas.offsetLeft;
    y -= circleCanvas.offsetTop;
    
    return new Coordinate(x-centreCoord.x,centreCoord.y-y);
  }

  function drawCircle(minRadius){
    minRadius = minRadius || 3;
    ccDrawingContext.clearRect(0,0,circleCanvas.width,circleCanvas.height);
//        ccDrawingContext.strokeStyle="rgb("+Math.floor(Math.random()*255)+","+Math.floor(Math.random()*255)+","+Math.floor(Math.ravndom()*255)+")";
    ccDrawingContext.strokeStyle="rgb(0,0,255)";
    ccDrawingContext.lineWidth = 2;
    ccDrawingContext.beginPath();
    ccDrawingContext.arc(centreCoord.x,centreCoord.y,radius,0,Math.PI*2);
    ccDrawingContext.closePath();
    ccDrawingContext.stroke();
    
    ccDrawingContext.strokeStyle="rgb(0,255,0)";
    ccDrawingContext.lineWidth = 2;
    ccDrawingContext.beginPath();
    ccDrawingContext.arc(centreCoord.x+radius*Math.cos(previous_angle),
			 centreCoord.y-radius*Math.sin(previous_angle),
			 minRadius,0,Math.PI*2);
    ccDrawingContext.closePath();
    ccDrawingContext.stroke();
  }
  

  
  function ccMouseMove(e) {
    coord = getCursorPosition(e);
    
    drawCircle(2 + current_radius);
    if(current_radius>0)
       angle=previous_angle;
    else
       angle = Math.atan2(coord.y,coord.x);
    ccDrawingContext.strokeStyle="rgb(0,0,0)";
    ccDrawingContext.lineWidth = 2;
    ccDrawingContext.beginPath();
    ccDrawingContext.moveTo(centreCoord.x,centreCoord.y);
    ccDrawingContext.lineTo(centreCoord.x+radius*Math.cos(angle),centreCoord.y-radius*Math.sin(angle));
    ccDrawingContext.closePath();
    ccDrawingContext.stroke();
  }

  var current_radius = 0;  
  
  function animateTarget( ){
    
    
    drawCircle(2 + current_radius);
    ccDrawingContext.strokeStyle="rgb(0,0,0)";
    ccDrawingContext.lineWidth = 2;
    ccDrawingContext.beginPath();
    ccDrawingContext.moveTo(centreCoord.x,centreCoord.y);
    ccDrawingContext.lineTo(centreCoord.x+radius*Math.cos(previous_angle),centreCoord.y-radius*Math.sin(previous_angle));
    ccDrawingContext.closePath();
    ccDrawingContext.stroke();
    current_radius -= 1;
    
    if(current_radius>0)
      setTimeout( animateTarget, 50 );
    
  
  }

  
  function ccMouseClick(e){
    coord = getCursorPosition(e);
    previous_angle = Math.atan2(coord.y,coord.x);
    coordField.innerHTML = angle / Math.PI *180;
    current_radius = 20;
    setTimeout( animateTarget, 50 );
  }

  
  // Initialization sequence.
  function init () {
    
    circleCanvas.addEventListener('mousemove', ccMouseMove, false);
    circleCanvas.addEventListener('mousedown', ccMouseClick, false);

    
    drawCircle();
    
  }

  init();
}, false); }



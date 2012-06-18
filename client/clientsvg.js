// Generated by CoffeeScript 1.3.3
(function() {

  window.rank_experiment = (function() {

    function rank_experiment() {
      this.viewport = document.getElementById("viewport");
      this.majorCircle = document.getElementById("majorCircle");
      this.targetCircle = document.getElementById("targetCircle");
      this.currentGuess = document.getElementById("currentGuess");
      this.angleLine = document.getElementById("angleLine");
      this.rankText = document.getElementById("rankText");
      this.angleText = document.getElementById("angleText");
      this.msgText = document.getElementById("msgText");
      this.circleCanvas = document.getElementById("circleCanvas");
      this.radius = 480;
      this.viewport_size = 1050;
      this.viewport_axis_x = 525;
      this.viewport_axis_y = 490;
      this.centre_coord = circleCanvas.createSVGPoint();
      this.zoom_level = 0;
      this.zoom_positions = new Array(11);
      this.previous_angle = Math.PI / 2;
      this.rankTextOpacity = 1;
      this.timedHover;
      this.isMacWebKit = navigator.userAgent.indexOf("Macintosh") !== -1 && navigator.userAgent.indexOf("WebKit") !== -1;
      this.isFirefox = navigator.userAgent.indexOf("Gecko") !== -1;
      window.addEventListener('load', this.windowListen(), false);
    }

    rank_experiment.prototype.windowListen = function() {
      var animateRankText, ccMouseClick, ccMouseMove, getCursorPosition, init, init_canvas, restartGuessingTask, update_zoom,
        _this = this;
      getCursorPosition = function(e) {
        var pt, pt2, transformation_matrix;
        pt = _this.circleCanvas.createSVGPoint();
        pt.x = e.x;
        pt.y = e.y;
        transformation_matrix = _this.circleCanvas.getScreenCTM();
        pt2 = pt.matrixTransform(transformation_matrix.inverse());
        pt2.x -= _this.centre_coord.x;
        pt2.y = _this.centre_coord.y - pt2.y;
        return pt2;
      };
      ccMouseClick = function(e) {
        var coord;
        coord = getCursorPosition(e);
        _this.previous_angle = Math.atan2(coord.y, coord.x);
        _this.currentGuess.setAttribute("cx", _this.radius * Math.cos(_this.previous_angle));
        _this.currentGuess.setAttribute("cy", _this.radius * Math.sin(_this.previous_angle));
        _this.circleCanvas.getElementsByTagName('animate')[0].beginElement();
        _this.circleCanvas.removeEventListener('mousemove', ccMouseMove);
        _this.circleCanvas.removeEventListener('click', ccMouseClick);
        _this.msgText.textContent = "Wait for your opponents to guess...";
        _this.msgText.style.fill = "green";
        _this.rankTextOpacity = 1;
        animateRankText();
        return setTimeout(restartGuessingTask, 4000);
      };
      ccMouseMove = function(e) {
        var angle, box, coord;
        coord = getCursorPosition(e);
        angle = Math.atan2(coord.y, coord.x);
        _this.angleLine.setAttribute("x2", _this.radius * Math.cos(angle));
        _this.angleLine.setAttribute("y2", _this.radius * Math.sin(angle));
        _this.targetCircle.setAttribute("cx", _this.radius * Math.cos(angle));
        _this.targetCircle.setAttribute("cy", _this.radius * Math.sin(angle));
        console.log(coord.x + ":" + coord.y + ":" + angle);
        return box = _this.circleCanvas.getBBox();
      };
      animateRankText = function() {};
      restartGuessingTask = function() {
        _this.rankText.textContent = "Your new rank is: " + Math.ceil(Math.random() * 20);
        _this.rankText.style.fill = "black";
        _this.rankTextOpacity = 1;
        animateRankText();
        _this.zoom_level = 0;
        _this.circleCanvas.addEventListener('mousemove', ccMouseMove, false);
        return _this.circleCanvas.addEventListener('click', ccMouseClick, false);
      };
      update_zoom = function() {
        /*
              viewport.setAttribute("transform",
                                      "translate("+ centre_coord.x+","+ centre_coord.y +") "+
                    "scale("+zoom_positions[zoom_level]+","+(-zoom_positions[zoom_level])+")")
        */

      };
      init_canvas = function() {
        _this.angleLine.setAttribute("x2", _this.radius * Math.cos(_this.previous_angle));
        _this.angleLine.setAttribute("y2", _this.radius * Math.sin(_this.previous_angle));
        _this.centre_coord.x = _this.viewport_axis_x;
        _this.centre_coord.y = _this.viewport_axis_y;
        return update_zoom();
      };
      init = function() {
        var i, _i, _ref;
        for (i = _i = 0, _ref = _this.zoom_positions.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          _this.zoom_positions[i] = Math.exp(i * 3 / (_this.zoom_positions.length - 1) * Math.log(2));
        }
        _this.zoom_level = 0;
        _this.circleCanvas.addEventListener('mousemove', ccMouseMove, false);
        _this.circleCanvas.addEventListener('click', ccMouseClick, false);
        _this.rankText.textContent = "";
        return init_canvas();
      };
      return init();
    };

    return rank_experiment;

  })();

}).call(this);

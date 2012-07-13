// Generated by CoffeeScript 1.3.3
(function() {

  window.rank_experiment = (function() {

    function rank_experiment() {
      this.windowWidth = window.innerWidth;
      this.windowHeight = window.innerHeight;
      this.buttonNext = document.getElementById("next");
      this.buttonPrevious = document.getElementById("previous");
      this.instructionsText = document.getElementById("instructions");
      this.circleCanvasDiv = document.getElementById("circleCanvasDiv");
      this.instructionsDiv = document.getElementById("instructionsDiv");
      this.gameTextDiv = document.getElementById("gameTextDiv");
      this.gameText = document.getElementById("gameText");
      this.compositeG = document.getElementById("svgCanvas");
      this.circleCanvas = document.getElementById("circleCanvas");
      this.majorCircle = document.getElementById("majorCircle");
      this.targetCircle = document.getElementById("targetCircle");
      this.rememberTargetCircle = this.circleCanvas.createSVGPoint();
      this.currentGuess = document.getElementById("currentGuess");
      this.angleLine = document.getElementById("angleLine");
      this.rankText = document.getElementById("rankText");
      this.maxGameRounds = 0;
      this.instructionVector = new Array();
      this.instructionIndex = 0;
      this.gameMode = "";
      this.nextLevel = 0;
      this.currentRank = "";
      this.zoom_scale = 0.2;
      this.zoom_level = 0;
      this.previous_angle = Math.PI / 2;
      this.isMacWebKit = navigator.userAgent.indexOf("Macintosh") !== -1 && navigator.userAgent.indexOf("WebKit") !== -1;
      this.isFirefox = navigator.userAgent.indexOf("Firefox") !== -1;
      this.isBuggyFirefox = navigator.userAgent.indexOf("Firefox/13.0.1") !== -1;
      this.serverURL = "http://129.132.133.54:8080/";
      this.registered = false;
      this.flip = 0;
      if (this.isFirefox) {
        window.load = this.windowListen();
      } else {
        window.addEventListener('onload', this.windowListen(), false);
      }
    }

    rank_experiment.prototype.windowListen = function() {
      var addListeners, ccMouseClick, ccMouseMove, ccMouseWheel, getCursorPosition, init, initInstructions, next, prev, queryRound, removeListeners, resetZoom, restartGuessingTask, send, startGame, stopGame, updateGameTextDiv, updateRankInfo,
        _this = this;
      getCursorPosition = function(e) {
        var pt, pt2, transformation_matrix;
        pt = _this.circleCanvas.createSVGPoint();
        pt.x = e.clientX;
        pt.y = e.clientY;
        transformation_matrix = _this.compositeG.getScreenCTM();
        pt2 = pt.matrixTransform(transformation_matrix.inverse());
        return pt2;
      };
      send = function(theURL, _data) {
        var processServerResponse, serverResponse;
        serverResponse = null;
        processServerResponse = function(response, status) {
          if (status === "error") {
            alert("Cannot connect to server");
          } else if (status !== "success") {
            alert("Network problems " + status);
          } else {
            if (response.responseText.indexOf("announced") !== -1) {
              _this.registered = true;
            } else if (response.responseText.indexOf("inprogress") !== -1) {
              alert("Sorry, the game has already started");
              _this.gameMode = false;
            } else if (response.responseText.indexOf("finished") !== -1) {
              alert("The game has already finished");
              _this.gameMode = false;
            } else if (response.responseText.indexOf("maxrounds") !== -1) {
              _this.maxGameRounds = parseInt(response.responseText.split(" ")[1]);
            }
          }
          return serverResponse = response.responseText;
        };
        $.ajax({
          url: theURL,
          accepts: "*/*",
          contentType: "text/html",
          crossDomain: true,
          context: _this,
          type: "POST",
          data: _data,
          async: false,
          complete: processServerResponse
        });
        return serverResponse;
      };
      queryRound = function(data) {
        var srvResponse;
        srvResponse = send(_this.serverURL, "rank " + _this.nextLevel);
        console.log("Server said " + srvResponse);
        if (srvResponse.indexOf("urrank") !== -1) {
          addListeners();
          _this.currentRank = srvResponse.split(" ")[2];
          console.log("My rank for " + (_this.nextLevel + 1) + " is: " + _this.currentRank);
          updateRankInfo();
          updateGameTextDiv(true);
          return true;
        }
        return setTimeout((function() {
          return queryRound(data);
        }), 3000);
      };
      updateGameTextDiv = function(flag) {
        if (!flag) {
          return _this.gameText.textContent = "Please wait for the other players...";
        } else {
          if (_this.nextLevel === (_this.maxGameRounds - 1)) {
            return _this.gameText.textContent = "Last Round " + (_this.nextLevel + 1) + ": please make a guess. ";
          } else if (_this.nextLevel === _this.maxGameRounds) {
            return _this.gameText.textContent = "Thank you for playing the game. You can close your browser now.";
          } else {
            return _this.gameText.textContent = "Round " + (_this.nextLevel + 1) + ": please make a guess. ";
          }
        }
      };
      updateRankInfo = function() {
        if (_this.nextLevel === _this.maxGameRounds) {
          return _this.rankText.textContent = "Your final rank: " + _this.currentRank;
        } else {
          return _this.rankText.textContent = "Your current rank: " + _this.currentRank;
        }
      };
      ccMouseWheel = function(event) {
        var circleParent, circleScaled, deltaX, deltaY, e, s, smatrix, tm, tmparent, tmscaled, tmscaledtranslated, translation_x, translation_y, zoomLevel;
        e = event || window.event;
        deltaX = e.deltaX * -30 || e.wheelDeltaX / 40 || 0;
        deltaY = e.deltaY * -30 || e.wheelDeltaY / 109 || (e.wheelDeltaY === void 0 && e.wheelDelta / 109) || e.detail * -10 || 0;
        /*  
        Most browsers generate one event with delta 120 per mousewheel click.
        On Macs, however, the mousewheels seem to be velocity-sensitive and
        the delta values are often larger multiples of 120, at
        least with the Apple Mouse. Use browser-testing to defeat this.
        */

        if (_this.isMacWebKit) {
          deltaX /= 30;
          deltaY /= 30;
        }
        if (_this.isFirefox) {
          deltaY = Math.abs(deltaY) / (deltaY * 109 / 120);
        }
        if (_this.isFirefox && e.type !== "DOMMouseScroll") {
          _this.circleCanvas.removeEventListener("DOMMouseScroll", ccMouseWheel, false);
        }
        if (e.preventDefault) {
          e.preventDefault();
        }
        if (e.stopPropagation) {
          e.stopPropagation();
        }
        e.cancelBubble = true;
        e.returnValue = false;
        zoomLevel = Math.pow(1 + _this.zoom_scale, deltaY);
        if (_this.zoom_level === 0) {
          _this.rememberTargetCircle.x = _this.targetCircle.cx.baseVal.value;
          _this.rememberTargetCircle.y = _this.targetCircle.cy.baseVal.value;
        }
        if (zoomLevel > 1) {
          _this.zoom_level++;
        } else {
          _this.zoom_level--;
        }
        tm = _this.compositeG.getScreenCTM();
        tmscaled = tm.scale(zoomLevel);
        tmparent = _this.circleCanvas.getScreenCTM();
        circleParent = _this.rememberTargetCircle.matrixTransform(tm);
        circleScaled = circleParent.matrixTransform(tmscaled.inverse());
        translation_x = circleScaled.x - _this.rememberTargetCircle.x;
        translation_y = circleScaled.y - _this.rememberTargetCircle.y;
        tmscaledtranslated = tmscaled.translate(translation_x, translation_y);
        smatrix = tmparent.inverse().multiply(tmscaledtranslated);
        s = "matrix(" + smatrix.a + "," + smatrix.b + "," + smatrix.c + "," + smatrix.d + "," + smatrix.e + "," + smatrix.f + ")";
        _this.compositeG.setAttribute("transform", s);
        _this.buttonNext.disabled = false;
        return false;
      };
      resetZoom = function(flag) {
        var circleParent, circleScaled, exponent, needed_zoom, radius, s, smatrix, tm, tmparent, tmscaled, tmscaledtranslated, translation_x, translation_y;
        if (flag) {
          radius = _this.majorCircle.getAttribute("r");
          _this.angleLine.setAttribute("x2", 0);
          _this.angleLine.setAttribute("y2", radius);
          _this.currentGuess.setAttribute("cx", 0);
          _this.currentGuess.setAttribute("cy", radius);
          _this.targetCircle.setAttribute("cx", 0);
          _this.targetCircle.setAttribute("cy", radius);
        }
        /*
              Due to this bug: https://bugzilla.mozilla.org/show_bug.cgi?id=762411
              the latest stable release Firefox 13.0.1 gets the wrong transformation matrix
              for tmparent. This bug is fixed in the beta version Firefox 14.0b10.
        */

        needed_zoom = 0;
        exponent = 120 / 109;
        needed_zoom = Math.pow(1 + _this.zoom_scale, -exponent * _this.zoom_level);
        tm = _this.compositeG.getScreenCTM();
        tmparent = _this.circleCanvas.getScreenCTM();
        tmscaled = tm.scale(needed_zoom);
        circleParent = _this.rememberTargetCircle.matrixTransform(tm);
        circleScaled = circleParent.matrixTransform(tmscaled.inverse());
        translation_x = circleScaled.x - _this.rememberTargetCircle.x;
        translation_y = circleScaled.y - _this.rememberTargetCircle.y;
        tmscaledtranslated = tmscaled.translate(translation_x, translation_y);
        smatrix = tmparent.inverse().multiply(tmscaledtranslated);
        s = "matrix(" + smatrix.a + "," + smatrix.b + "," + smatrix.c + "," + smatrix.d + "," + smatrix.e + "," + smatrix.f + ")";
        _this.compositeG.setAttribute("transform", s);
        return _this.zoom_level = 0;
      };
      ccMouseClick = function(e) {
        var animatedElement, coord, radius;
        e = e || window.event;
        coord = getCursorPosition(e);
        _this.previous_angle = Math.atan2(coord.y, coord.x);
        radius = _this.majorCircle.getAttribute("r");
        _this.currentGuess.setAttribute("cx", radius * Math.cos(_this.previous_angle));
        _this.currentGuess.setAttribute("cy", radius * Math.sin(_this.previous_angle));
        animatedElement = _this.circleCanvas.getElementsByTagName('animate');
        animatedElement[0].setAttribute("dur", "1s");
        animatedElement[0].beginElement();
        if (!_this.flip && _this.instructionIndex === 1) {
          _this.instructionsText.textContent += "\n\rThe small red circle at the selected position shows your last quess.\n\r";
          _this.buttonNext.disabled = false;
          _this.flip = 1;
        }
        if (_this.rankText.textContent !== "" && _this.gameMode) {
          _this.rankText.textContent = "Your current rank: ";
        }
        if (_this.gameMode) {
          if (_this.nextLevel < _this.maxGameRounds) {
            resetZoom(false);
            send(_this.serverURL, "estimate " + _this.nextLevel + " " + _this.previous_angle * 180 / Math.PI);
            _this.nextLevel++;
            updateGameTextDiv(false);
            removeListeners();
            if (_this.nextLevel < _this.maxGameRounds) {
              return $(_this).triggerHandler({
                type: "queryServer",
                var1: 'Howdy',
                information: 'I could pass something here also'
              });
            } else {
              return $(_this).triggerHandler({
                type: "stopGame"
              });
            }
          }
        }
      };
      ccMouseMove = function(e) {
        var angle, coord, radius;
        e = e || window.event;
        coord = getCursorPosition(e);
        angle = Math.atan2(coord.y, coord.x);
        radius = _this.majorCircle.getAttribute("r");
        _this.angleLine.setAttribute("x2", radius * Math.cos(angle));
        _this.angleLine.setAttribute("y2", radius * Math.sin(angle));
        _this.targetCircle.setAttribute("cx", radius * Math.cos(angle));
        return _this.targetCircle.setAttribute("cy", radius * Math.sin(angle));
      };
      restartGuessingTask = function() {
        return _this.circleCanvas.addEventListener('click', ccMouseClick, false);
      };
      next = function() {
        if (_this.buttonNext.innerHTML === "Start" && _this.gameMode !== false) {
          _this.gameMode = true;
          return $(_this).triggerHandler({
            type: "startGame"
          });
        } else if (_this.instructionIndex < 3) {
          _this.instructionIndex++;
          if (_this.instructionIndex === 1) {
            _this.compositeG.addEventListener('mousemove', ccMouseMove, false);
            _this.circleCanvas.addEventListener('click', ccMouseClick, false);
          }
          if (_this.instructionIndex === 2) {
            _this.circleCanvas.onwheel = ccMouseWheel;
            _this.circleCanvas.onmousewheel = ccMouseWheel;
          }
          if (_this.isFirefox) {
            _this.circleCanvas.addEventListener("DOMMouseScroll", ccMouseWheel, false);
          }
          _this.instructionsText.textContent = _this.instructionVector[_this.instructionIndex];
          _this.buttonNext.disabled = true;
          _this.buttonPrevious.disabled = false;
          if (_this.instructionIndex === 3) {
            _this.rankText.textContent = "Your Rank: 1 (25)";
            _this.buttonNext.innerHTML = "Start";
            _this.buttonNext.disabled = false;
          }
          return resetZoom(true);
        }
      };
      startGame = function() {
        resetZoom(true);
        removeListeners();
        _this.instructionsDiv.parentNode.removeChild(_this.instructionsDiv);
        _this.gameTextDiv.setAttribute("style", "height:100%;width:20%;float:left;");
        updateGameTextDiv(false);
        _this.buttonNext.parentNode.removeChild(_this.buttonNext);
        _this.buttonPrevious.parentNode.removeChild(_this.buttonPrevious);
        _this.rankText.textContent = "Your current rank: ";
        return $(_this).triggerHandler({
          type: "queryServer",
          var1: 'Howdy',
          information: 'I could pass something here also'
        });
      };
      stopGame = function() {
        _this.gameMode = false;
        updateGameTextDiv(true);
        updateRankInfo();
        return addListeners();
      };
      prev = function() {
        _this.flip = 0;
        _this.gameMode = false;
        _this.buttonPrevious.disabled = false;
        _this.buttonNext.innerHTML = "Next";
        _this.instructionIndex--;
        if (_this.instructionIndex <= 0) {
          _this.instructionIndex = 0;
          _this.buttonPrevious.disabled = true;
          _this.buttonNext.disabled = false;
        } else {
          _this.buttonPrevious.disabled = false;
        }
        _this.instructionsText.textContent = _this.instructionVector[_this.instructionIndex];
        resetZoom(true);
        if (_this.instructionIndex !== 0) {
          return _this.buttonNext.disabled = true;
        }
      };
      initInstructions = function() {
        _this.instructionVector[0] = "Welcome to our guessing game." + "The purpose of the game is to find out the location of a hidden point " + "that we have randomly positioned on the blue circle to the left." + "You will compete with other players, and your performance, as well as reward, " + "will be based on how close your guess is to the hidden point, compared to others.\n\r" + "The game consists of 10 rounds. During each round, you have to make a guess " + "by moving the green line around the circle and clicking on a desired position. " + "A round finishes when all players have made their choices.\n\r" + "At the beginning of each round, you will be informed of your relative ranking. " + "Your rank is 1 if you are the player currently closest to the hidden point. " + "Conversely, if you are farthest from the point, you rank last.\n\r" + "Click \"Next\" for a quick practice.";
        _this.instructionVector[1] = "Try moving the green line around the circle and click once it is positioned at a desired location ...";
        _this.instructionVector[2] = "For increased precision, you can zoom in and out of the circle with the mouse wheel. " + "The zoom is with respect to the current position of the green line.\n\r" + "Try zooming in and out a few times to get used to this functionality ... ";
        _this.instructionVector[3] = "Finally, your current rank is displayed above the circle. In the example shown " + "the number in the brackets shows the total number " + "of players. Your rank will be updated at the end of each round, after all players " + " have submitted their choices, and will be presented to you at the beggining of the next round.\n\r" + "With this last bit of information, the practice session ends. You can continue " + "playing with the circle, in which case random rank information will be presented. " + "Alternatively, you can go back to read the instructions again. If anything is left unclear, please ask the administrator.\n\r" + "Once you are ready, hit \"Start\" to begin the game.";
        return _this.instructionsText.textContent = _this.instructionVector[_this.instructionIndex];
      };
      addListeners = function() {
        _this.compositeG.addEventListener('mousemove', ccMouseMove, false);
        _this.circleCanvas.addEventListener('click', ccMouseClick, false);
        _this.circleCanvas.onwheel = ccMouseWheel;
        _this.circleCanvas.onmousewheel = ccMouseWheel;
        if (_this.isFirefox) {
          return _this.circleCanvas.addEventListener("DOMMouseScroll", ccMouseWheel, false);
        }
      };
      removeListeners = function() {
        _this.compositeG.removeEventListener('mousemove', ccMouseMove, false);
        _this.circleCanvas.removeEventListener('click', ccMouseClick, false);
        _this.circleCanvas.onwheel = null;
        _this.circleCanvas.onmousewheel = null;
        if (_this.isFirefox) {
          return _this.circleCanvas.removeEventListener("DOMMouseScroll", ccMouseWheel, false);
        }
      };
      init = function() {
        if (_this.isBuggyFirefox) {
          alert("Sorry, you are using Firefox version 13.0.1, which has a bug in computing correct" + " coordinates of SVG elements (https://bugzilla.mozilla.org/show_bug.cgi?id=762411). " + "Use either the beta version of Firefox 14.0b10 or a different broswer.");
          return false;
        }
        _this.buttonNext.onclick = next;
        _this.buttonPrevious.onclick = prev;
        _this.buttonPrevious.disabled = true;
        initInstructions();
        console.log(send(_this.serverURL, "announce"));
        $(_this).on("queryServer", queryRound);
        $(_this).on("startGame", startGame);
        return $(_this).on("stopGame", stopGame);
      };
      return init();
    };

    return rank_experiment;

  })();

}).call(this);

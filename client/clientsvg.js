// Generated by CoffeeScript 1.3.3
(function() {

  window.rank_experiment = (function() {

    function rank_experiment() {
      this.windowWidth = window.innerWidth;
      this.windowHeight = window.innerHeight;
      this.buttonNext = document.getElementById("next");
      this.buttonNextText = document.getElementsByClassName("nextbuttontext")[0];
      this.buttonPrevious = document.getElementById("previous");
      this.instructionsText = document.getElementById("instructions");
      this.circleCanvasDiv = document.getElementById("circleCanvasDiv");
      this.instructionsDiv = document.getElementById("instructionsDiv");
      this.gameTextDiv = document.getElementById("gameTextDiv");
      this.gameText = document.getElementById("gameText");
      this.gameTextWebSymbols = document.getElementsByClassName("websymbols")[0];
      this.miscInfoDiv = document.getElementById("miscinfo");
      this.miscInfo = document.getElementById("miscinfotext");
      this.timer = document.getElementById("timer");
      this.timeleft = document.getElementById("timeleft");
      this.compositeG = document.getElementById("svgCanvas");
      this.circleCanvas = document.getElementById("circleCanvas");
      this.majorCircle = document.getElementById("majorCircle");
      this.targetCircle = document.getElementById("targetCircle");
      this.rememberTargetCircle = this.circleCanvas.createSVGPoint();
      this.currentGuess = document.getElementById("currentGuess");
      this.angleLine = document.getElementById("angleLine");
      this.rankText = document.getElementById("rankText");
      this.userNameInput = document.getElementById("username");
      this.username = "";
      /* used to display a spinning waiting symbol when waiting for other players
      */

      this.loaderIndex = 0;
      this.loaderSymbols = ["0", "1", "2", "3", "4", "5", "6", "7"];
      this.loaderRate = 100;
      this.loadmetimer = null;
      this.timeout_trigger = null;
      this.GLOBAL_TIME_LIMIT = 30;
      this.timelimit = this.GLOBAL_TIME_LIMIT;
      /*
      */

      this.maxGameRounds = 0;
      this.maxGameStages = 0;
      this.instructionVector = new Array();
      this.instructionIndex = 0;
      this.gameMode = "";
      this.nextLevel = 0;
      this.nextStage = 0;
      this.currentRank = "";
      this.tbody = document.createElement("tbody");
      this.payoffs_per_stage = [10.6, 8.1, 5.0, 3.8, 3.8, 3.8, 3.1, 3.1, 3.1, 1.9, 1.9, 1.9, 1.9, 1.2, 1.2, 1.2, 1.2, 0.6, 0.6, 0.6];
      this.finalRanks = [];
      this.zoom_scale = 0.1;
      this.zoom_level = 0;
      this.previous_angle = Math.PI / 2;
      this.isMacWebKit = navigator.userAgent.indexOf("Macintosh") !== -1 && navigator.userAgent.indexOf("WebKit") !== -1;
      this.isFirefox = navigator.userAgent.indexOf("Firefox") !== -1;
      this.isBuggyFirefox = navigator.userAgent.indexOf("Firefox/13.0.1") !== -1;
      this.serverURL = "http://129.132.201.225:8070/";
      this.registered = false;
      this.customIdentity = Math.random().toString(36).substring(5);
      this.flip = 0;
      if (this.isFirefox) {
        window.load = this.windowListen();
      } else {
        window.addEventListener('onload', this.windowListen(), false);
      }
    }

    rank_experiment.prototype.windowListen = function() {
      var addListeners, autoGuess, ccMouseClick, ccMouseMove, ccMouseWheel, getCursorPosition, init, initInstructions, initSummaryTable, loadme, next, nextStage, nextStageEvent, prev, queryRound, removeListeners, resetZoom, restartGuessingTask, send, setEstimateAngle, startGame, stopGame, summary, summaryEvent, timeout, updateGameTextDiv, updateRankInfo,
        _this = this;
      window.oncontextmenu = function(event) {
        event.preventDefault();
        event.stopPropagation();
        return false;
      };
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
        var processError, processServerResponse, serverResponse;
        serverResponse = null;
        processError = function(object, errorMessage, exception) {
          alert("Cannot connect to server.");
          _this.gameMode = false;
          return clearTimeout(_this.loadmetimer);
        };
        processServerResponse = function(response, status) {
          if (status !== "success" || status === "error") {
            _this.gameMode = false;
            _this.registered = false;
            clearTimeout(_this.loadmetimer);
          } else {
            if (response.responseText.indexOf("inprogress") !== -1) {
              alert("Sorry, the game has already started");
              _this.gameMode = false;
              _this.registered = false;
            } else if (response.responseText.indexOf("roundfinished") !== -1) {
              alert("Sorry, you have been disconnected from the game due to timeout.");
              _this.registered = false;
              _this.gameMode = false;
            } else if (response.responseText.indexOf("finished") !== -1) {
              alert("The game has already finished");
              _this.registered = false;
              _this.gameMode = false;
            } else if (response.responseText.indexOf("maxroundsstages") !== -1) {
              _this.maxGameRounds = parseInt(response.responseText.split(" ")[1]);
              _this.maxGameStages = parseInt(response.responseText.split(" ")[2]);
              _this.registered = true;
            } else if (response.responseText.indexOf("insane") !== -1) {
              alert("Sorry, you have been disconnected from the game due to timeout.");
              _this.registered = false;
              _this.gameMode = false;
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
          headers: {
            "Hex": _this.customIdentity,
            "Username": _this.username
          },
          async: false,
          complete: processServerResponse,
          error: processError
        });
        return serverResponse;
      };
      queryRound = function(data) {
        var srvResponse;
        if (!_this.gameMode) {
          $(_this).triggerHandler({
            type: "stopGame"
          });
          return true;
        }
        srvResponse = send(_this.serverURL, "rank " + _this.nextLevel + " " + _this.nextStage);
        console.log("Server said " + srvResponse);
        if (srvResponse.indexOf("urrank") !== -1) {
          addListeners();
          _this.currentRank = srvResponse.split(" ")[2];
          if (_this.nextLevel === 0) {
            _this.initialEstimate = srvResponse.split(" ")[3];
            setEstimateAngle(_this.initialEstimate);
          }
          console.log("My rank at the beginning of round " + (_this.nextLevel + 1) + " and stage " + (_this.nextStage + 1) + " is: " + _this.currentRank);
          updateGameTextDiv(true);
          updateRankInfo();
          return true;
        }
        return setTimeout((function() {
          return queryRound(data);
        }), 3000);
      };
      autoGuess = function() {
        var random_angle;
        if (_this.rankText.textContent !== "" && _this.gameMode) {
          _this.rankText.textContent = "Your current rank: ";
        }
        if (_this.gameMode) {
          if (_this.nextStage < _this.maxGameStages) {
            if (_this.nextLevel < _this.maxGameRounds) {
              _this.miscInfo.textContent = "";
              resetZoom(false);
              clearTimeout(_this.timeout_trigger);
              random_angle = Math.random() * 360 - 180;
              send(_this.serverURL, "estimate " + _this.nextLevel + " " + _this.nextStage + " " + random_angle + " " + "*");
              setEstimateAngle(random_angle * Math.PI / 180);
              _this.nextLevel++;
              updateGameTextDiv(false);
              removeListeners();
              return $(_this).triggerHandler({
                type: "queryServer"
              });
            }
          } else {
            return $(_this).triggerHandler({
              type: "stopGame"
            });
          }
        }
      };
      loadme = function() {
        _this.gameTextWebSymbols.innerHTML = _this.loaderSymbols[_this.loaderIndex];
        if (_this.loaderIndex < _this.loaderSymbols.length - 1) {
          _this.loaderIndex = _this.loaderIndex + 1;
        } else {
          _this.loaderIndex = 0;
        }
        return _this.loadmetimer = setTimeout(loadme, _this.loaderRate);
      };
      updateGameTextDiv = function(flag) {
        if (!flag) {
          _this.gameText.setAttribute("style", "");
          _this.gameTextWebSymbols.setAttribute("class", "websymbols");
          _this.gameText.textContent = "Please wait for the other players";
          return $(_this).triggerHandler({
            type: "loadme"
          });
        } else {
          clearTimeout(_this.loadmetimer);
          _this.gameTextWebSymbols.innerHTML = "";
          _this.gameText.setAttribute("style", "font-weight:bold;");
          _this.gameTextWebSymbols.setAttribute("class", "");
          if (_this.gameMode) {
            if (_this.nextLevel === (_this.maxGameRounds - 1)) {
              _this.gameText.textContent = "Stage " + (_this.nextStage + 1) + ", Last Round " + (_this.nextLevel + 1);
              return _this.gameTextWebSymbols.textContent = ": please make a guess. ";
            } else if (_this.nextLevel === _this.maxGameRounds) {
              _this.gameText.setAttribute("style", "");
              _this.gameText.textContent = "This is the end of Stage " + (_this.nextStage + 1) + ". Click \"Next\" to begin ";
              if ((_this.nextStage + 1) < (_this.maxGameStages - 1)) {
                _this.gameText.textContent = _this.gameText.textContent + "Stage " + (_this.nextStage + 2) + ".";
                return $(_this).triggerHandler({
                  type: "nextStage"
                });
              } else if ((_this.nextStage + 1) === (_this.maxGameStages - 1)) {
                _this.gameText.textContent = _this.gameText.textContent + "the last Stage " + (_this.nextStage + 2) + ".";
                return $(_this).triggerHandler({
                  type: "nextStage"
                });
              } else {
                _this.gameText.textContent = "This is the end of the game. Thank you for playing. Click \"Next\" to see a summary of your performance.";
                _this.gameMode = false;
                return $(_this).triggerHandler({
                  type: "summary"
                });
              }
            } else {
              _this.gameText.textContent = "Stage " + (_this.nextStage + 1) + ", Round " + (_this.nextLevel + 1);
              _this.gameTextWebSymbols.textContent = ": \n please make a guess.";
              if (_this.nextLevel === 0) {
                return _this.miscInfo.textContent = "The random initial guess assigned to you is indicated by the red circle.";
              }
            }
          }
        }
      };
      updateRankInfo = function() {
        if (_this.nextLevel === 0) {
          _this.rankText.textContent = _this.username + ", your initial rank is: " + _this.currentRank;
          _this.timeleft.textContent = "Time: ";
          return $(_this).triggerHandler({
            type: "timeout"
          });
        } else if (_this.nextLevel === _this.maxGameRounds) {
          _this.rankText.textContent = _this.username + ", your final rank for stage " + (_this.nextStage + 1) + " is: " + _this.currentRank;
          _this.timeleft.textContent = "";
          _this.timer.textContent = "";
          return _this.finalRanks[_this.nextStage] = parseInt(_this.currentRank.split("(")[0]);
        } else {
          _this.rankText.textContent = _this.username + ", your rank at the end of round " + _this.nextLevel + " is: " + _this.currentRank;
          _this.timeleft.textContent = "Time: ";
          return $(_this).triggerHandler({
            type: "timeout"
          });
        }
      };
      timeout = function() {
        if (_this.timelimit === 9) {
          _this.timer.style.color = "red";
          _this.timeleft.style.color = "red";
          _this.timeleft.textContent = "HURRY! Time: ";
        }
        if (_this.timelimit === -1) {
          _this.timer.style.color = "black";
          _this.timeleft.textContent = "Time: ";
          _this.timeleft.style.color = "black";
          autoGuess();
          _this.timeleft.textContent = "";
          _this.timer.textContent = "";
          return _this.timelimit = _this.GLOBAL_TIME_LIMIT;
        } else {
          _this.timer.textContent = _this.timelimit;
          _this.timelimit = _this.timelimit - 1;
          return _this.timeout_trigger = setTimeout(timeout, 1000);
        }
      };
      nextStage = function() {
        var nbutton, nbuttonText;
        removeListeners();
        nbutton = document.createElement("button");
        nbutton.setAttribute("type", "button");
        nbutton.setAttribute("id", "next_stage");
        nbutton.setAttribute("class", "nextbutton");
        nbuttonText = document.createElement("text");
        nbuttonText.setAttribute("class", "nextbuttontext");
        nbuttonText.innerHTML = "Next";
        nbutton.appendChild(nbuttonText);
        _this.miscInfoDiv.appendChild(nbutton);
        _this.gameText.parentNode.setAttribute("style", "height:20%;width:100%;float:left;");
        _this.miscInfoDiv.setAttribute("style", "height:80%;width:100%;float:left;");
        return nbutton.onclick = nextStageEvent;
      };
      nextStageEvent = function() {
        var nbutton;
        _this.gameText.parentNode.setAttribute("style", "height:10%;width:100%;float:left;");
        _this.miscInfoDiv.setAttribute("style", "height:90%;width:100%;float:left;");
        nbutton = document.getElementById("next_stage");
        nbutton.parentNode.removeChild(nbutton);
        _this.nextStage++;
        _this.nextLevel = 0;
        _this.currentRank = "";
        updateGameTextDiv(false);
        send(_this.serverURL, "ready " + _this.nextStage);
        if (_this.rankText.textContent !== "" && _this.gameMode) {
          _this.rankText.textContent = "Waiting for other players.";
        }
        return $(_this).triggerHandler({
          type: "queryServer"
        });
      };
      summary = function() {
        var nbutton, nbuttonText;
        nbutton = document.createElement("button");
        nbutton.setAttribute("type", "button");
        nbutton.setAttribute("id", "summary");
        nbutton.setAttribute("class", "nextbutton");
        nbuttonText = document.createElement("text");
        nbuttonText.setAttribute("class", "nextbuttontext");
        nbuttonText.innerHTML = "Summary";
        nbutton.appendChild(nbuttonText);
        _this.miscInfoDiv.appendChild(nbutton);
        _this.gameText.parentNode.setAttribute("style", "height:20%;width:100%;float:left;");
        _this.miscInfoDiv.setAttribute("style", "height:80%;width:100%;float:left;");
        return nbutton.onclick = summaryEvent;
      };
      summaryEvent = function() {
        var cell0, cell1, cell2, i, nbutton, payoff, row, showupfeerow, table, total, totalrow, _i, _ref;
        _this.gameText.parentNode.setAttribute("style", "height:10%;width:100%;float:left;");
        _this.miscInfoDiv.setAttribute("style", "height:90%;width:100%;float:left;");
        nbutton = document.getElementById("summary");
        nbutton.parentNode.removeChild(nbutton);
        _this.gameMode = false;
        send(_this.serverURL, "finito");
        total = 0;
        for (i = _i = 1, _ref = _this.maxGameStages; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
          row = document.createElement("tr");
          cell0 = document.createElement("th");
          cell0.appendChild(document.createTextNode("Stage " + i));
          cell1 = document.createElement("td");
          cell1.appendChild(document.createTextNode(_this.finalRanks[i - 1]));
          cell2 = document.createElement("td");
          payoff = "";
          if (_this.finalRanks[i - 1] < 21) {
            payoff = _this.payoffs_per_stage[_this.finalRanks[i - 1] - 1] + " CHF";
            total = total + _this.payoffs_per_stage[_this.finalRanks[i - 1] - 1];
          } else {
            payoff = "0 CHF";
          }
          cell2.appendChild(document.createTextNode(payoff));
          row.appendChild(cell0);
          row.appendChild(cell1);
          row.appendChild(cell2);
          _this.tbody.appendChild(row);
        }
        total = total + 10.0;
        total = Math.round(total * 10) / 10.0;
        showupfeerow = document.createElement("tr");
        cell0 = document.createElement("th");
        cell0.appendChild(document.createTextNode("Show-up Fee"));
        cell1 = document.createElement("td");
        cell2 = document.createElement("td");
        cell2.appendChild(document.createTextNode("10 CHF"));
        showupfeerow.appendChild(cell0);
        showupfeerow.appendChild(cell1);
        showupfeerow.appendChild(cell2);
        _this.tbody.appendChild(showupfeerow);
        totalrow = document.createElement("tr");
        cell0 = document.createElement("th");
        cell0.appendChild(document.createTextNode("Total"));
        cell1 = document.createElement("td");
        cell2 = document.createElement("td");
        cell2.appendChild(document.createTextNode(total + " ~ " + Math.round(total) + " CHF"));
        totalrow.appendChild(cell0);
        totalrow.appendChild(cell1);
        totalrow.appendChild(cell2);
        _this.tbody.appendChild(totalrow);
        table = document.createElement("table");
        table.setAttribute("class", "summary_table");
        table.appendChild(_this.tbody);
        _this.gameTextDiv.parentNode.removeChild(_this.gameTextDiv);
        _this.circleCanvas.parentNode.removeChild(_this.circleCanvas);
        _this.circleCanvasDiv.appendChild(table);
        return _this.rankText.textContent = "Thank you " + _this.username + " for playing. A summary of your performance is shown below.";
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
        if (deltaY > 0) {
          deltaY = 1.1009174311926606;
        } else {
          deltaY = -1.1009174311926606;
        }
        zoomLevel = Math.pow(1 + _this.zoom_scale, deltaY);
        if (_this.zoom_level >= 30 && zoomLevel > 1) {
          zoomLevel = 1;
        }
        if (_this.zoom_level <= -30 && zoomLevel < 1) {
          zoomLevel = 1;
        }
        if (_this.zoom_level === 0) {
          _this.rememberTargetCircle.x = _this.targetCircle.getAttribute("cx");
          _this.rememberTargetCircle.y = _this.targetCircle.getAttribute("cy");
        }
        if (zoomLevel > 1) {
          _this.zoom_level++;
        } else if (zoomLevel < 1) {
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
        clearTimeout(_this.timeout_trigger);
        _this.timeleft.textContent = "";
        _this.timer.textContent = "";
        _this.timelimit = _this.GLOBAL_TIME_LIMIT;
        e = e || window.event;
        coord = getCursorPosition(e);
        _this.previous_angle = Math.atan2(coord.y, coord.x);
        radius = _this.majorCircle.getAttribute("r");
        _this.currentGuess.setAttribute("cx", radius * Math.cos(_this.previous_angle));
        _this.currentGuess.setAttribute("cy", radius * Math.sin(_this.previous_angle));
        animatedElement = _this.circleCanvas.getElementsByTagName('animate');
        animatedElement[0].setAttribute("dur", "0.3s");
        animatedElement[0].beginElement();
        if (!_this.flip && _this.instructionIndex === 1) {
          _this.instructionsText.textContent += "\n\rThe small red circle at the selected position shows your last guess.\n\r";
          _this.buttonNext.disabled = false;
          _this.flip = 1;
        }
        if (_this.rankText.textContent !== "" && _this.gameMode) {
          _this.rankText.textContent = "Waiting for other players.";
        }
        if (_this.gameMode) {
          if (_this.nextStage < _this.maxGameStages) {
            if (_this.nextLevel < _this.maxGameRounds) {
              _this.miscInfo.textContent = "";
              resetZoom(false);
              send(_this.serverURL, "estimate " + _this.nextLevel + " " + _this.nextStage + " " + _this.previous_angle * 180 / Math.PI);
              _this.nextLevel++;
              updateGameTextDiv(false);
              removeListeners();
              return $(_this).triggerHandler({
                type: "queryServer"
              });
            }
          } else {
            return $(_this).triggerHandler({
              type: "stopGame"
            });
          }
        }
      };
      setEstimateAngle = function(angle) {
        var radius;
        radius = _this.majorCircle.getAttribute("r");
        _this.angleLine.setAttribute("x2", radius * Math.cos(angle));
        _this.angleLine.setAttribute("y2", radius * Math.sin(angle));
        _this.targetCircle.setAttribute("cx", radius * Math.cos(angle));
        _this.targetCircle.setAttribute("cy", radius * Math.sin(angle));
        _this.currentGuess.setAttribute("cx", radius * Math.cos(angle));
        return _this.currentGuess.setAttribute("cy", radius * Math.sin(angle));
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
        if (_this.buttonNextText.innerHTML === "Start" && _this.gameMode !== true) {
          _this.gameMode = true;
          return $(_this).triggerHandler({
            type: "startGame"
          });
        } else if (_this.instructionIndex < 3) {
          if (_this.userNameInput.value === "") {
            return alert("Please enter your username");
          } else {
            if (_this.username === "") {
              _this.username = _this.userNameInput.value.charAt(0).toUpperCase() + _this.userNameInput.value.slice(1);
              _this.userNameInput.parentNode.parentNode.removeChild(_this.userNameInput.parentNode);
            }
            _this.instructionIndex++;
            if (_this.instructionIndex === 1) {
              _this.compositeG.addEventListener('mousemove', ccMouseMove, false);
              _this.circleCanvas.addEventListener('click', ccMouseClick, false);
            }
            if (_this.instructionIndex === 2) {
              _this.circleCanvas.onwheel = ccMouseWheel;
              _this.circleCanvas.onmousewheel = ccMouseWheel;
              if (_this.isFirefox) {
                _this.circleCanvas.addEventListener("DOMMouseScroll", ccMouseWheel, false);
              }
            }
            _this.instructionsText.textContent = _this.instructionVector[_this.instructionIndex];
            _this.buttonNext.disabled = true;
            _this.buttonPrevious.disabled = false;
            if (_this.instructionIndex === 3) {
              _this.rankText.textContent = "Your Rank: 1 (20)";
              _this.buttonNextText.innerHTML = "Start";
              _this.buttonNext.innerHTML = "<text class=\"nextbuttontext\">Start</text>.";
              _this.buttonNext.disabled = false;
            }
            return resetZoom(true);
          }
        }
      };
      startGame = function() {
        if (_this.registered) {
          send(_this.serverURL, "doneinstructions");
          resetZoom(true);
          removeListeners();
          _this.instructionsDiv.parentNode.removeChild(_this.instructionsDiv);
          _this.gameTextDiv.setAttribute("style", "height:100%;width:20%;float:left;padding-left:10px;padding-top:10px");
          updateGameTextDiv(false);
          _this.buttonNext.parentNode.removeChild(_this.buttonNext);
          _this.buttonPrevious.parentNode.removeChild(_this.buttonPrevious);
          _this.rankText.textContent = "Waiting for other players.";
          return $(_this).triggerHandler({
            type: "queryServer"
          });
        } else {
          alert("You have not properly registered for the game.");
          return _this.gameMode = false;
        }
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
        _this.buttonNextText.innerHTML = "Next";
        _this.buttonNext.innerHTML = "<text class=\"nextbuttontext\">Next</text>>";
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
        /*
              @instructionVector[0] = "Welcome to our guessing game."+ 
              "The purpose of the game is to find out the location of a hidden point " +
              "randomly positioned on the blue circle to the left."+
              "You will compete with other players, and your performance, as well as reward, "+
              "will be based on how close your guess is to the hidden point, compared to others.\n\r"+
              "The game consists of 5 identical stages. Each stage, in turn, consists of 10 rounds."+
              "During each round, you make a guess "+
              "by moving the green line around the circle and clicking on a desired position. "+
              "A round finishes when all players have made their choices. A stage finishes after round 10 is over.\n\r"+ 
               "You have 20 seconds to submit a guess. Failure to do so will disconnect you from the game."+
              "\n\r"+
              "Note that the position of the hidden point changes in every stage!\n\r"+      
              "At the beginning of round 1 of each stage, you will be assigned a random guess. It is used to calculate your starting rank for this stage."+      
              "Your rank is 1 if you are the player currently closest to the hidden point. "+
              "Similarly, if you are farthest from the point, you rank last.\n\r" +
              "Your payoff is based on your final rank at the end each stage. Rank 1 is worth 10 CHF, Rank 2 - 6 CHF, and Rank 3 - 4 CHF. For example, if you consistently"+
              " finish first in all 5 stages, your reward will be 10*5= 50 CHF.\n\r"+
              "To continue, enter a username in the box below and click \"Next\" for a quick practice."
        */

      };
      this.instructionVector[0] = "Welcome to our guessing game.\n\rIn this short practice session, you will learn how to work with the circle. " + "To continue, enter a username in the box below and click \"Next\".";
      this.instructionVector[1] = "Try moving the green line around the circle and click once it is positioned at a desired location ...";
      this.instructionVector[2] = "For increased precision, you can zoom in and out of the circle with the mouse wheel.\n\r" + "Try zooming in and out a few times to get used to this functionality ... ";
      this.instructionVector[3] = "Finally, your rank at the end of the previous round is displayed above the circle. " + "In this example, the number in the brackets shows number " + "of players. Your rank, will be updated at the end of each round, after all players " + " have submitted their guesses. " + "At the beggining of each new round, you will be shown your rank from the previous one.\n\r" + "With this last bit of information, the practice session ends. You can continue " + "playing with the circle or " + "you can go back to read the instructions again. If anything is left unclear, please ask the administrator.\n\r" + "Once you are ready, hit \"Start\" to begin the game. " + "You will be assigned a random initial estimate (indicated by the red circle) on which your initial rank will be based.";
      this.instructionsText.textContent = this.instructionVector[this.instructionIndex];
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
      initSummaryTable = function() {
        var cell0, cell1, cell2, toprow;
        toprow = document.createElement("tr");
        cell0 = document.createElement("th");
        cell1 = document.createElement("th");
        cell1.appendChild(document.createTextNode("Final Rank"));
        cell2 = document.createElement("th");
        cell2.appendChild(document.createTextNode("Payoff"));
        toprow.appendChild(cell0);
        toprow.appendChild(cell1);
        toprow.appendChild(cell2);
        return _this.tbody.appendChild(toprow);
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
        initSummaryTable();
        console.log(send(_this.serverURL, "announce"));
        $(_this).on("queryServer", queryRound);
        $(_this).on("startGame", startGame);
        $(_this).on("stopGame", stopGame);
        $(_this).on("loadme", loadme);
        $(_this).on("nextStage", nextStage);
        $(_this).on("summary", summary);
        return $(_this).on("timeout", timeout);
      };
      return init();
    };

    return rank_experiment;

  })();

}).call(this);

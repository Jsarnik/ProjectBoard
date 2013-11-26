<%@ Page Language="C#" AutoEventWireup="true"  CodeFile="Default.aspx.cs" Inherits="_Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<title>Project Schedules</title>
<!--<meta name="viewport" content="width=1100, user-scalable=false">-->
<meta name="viewport" content="initial-scale = 1.0,maximum-scale = 1.0" />
<meta http-equiv="refresh" content="1000">
<script src="http://code.jquery.com/jquery-1.10.1.min.js"></script>
<link href="style.css" rel="stylesheet" type="text/css" />
</head>
<body>
<form id="form1" runat="server">
<div id="content">

</div>
<script type="text/javascript">

    $(document).ready(function() {
        screenSavers();
        init('http://localhost:57272/ProjectBoard%20-%20Copy/json/main_json.txt');
    });

    $(window).resize(function() {
        if (initListener == 1) {
            canvasWidth = $('#content').width();
            canvasHeight = $('#content').width() * .136;
            canvas.width = canvasWidth;
            canvas.height = canvasHeight;
            fontsize = (canvasWidth * .043);

            buildCanvas(canvas.width * .02);
        }
    });


    // GLOBALS
    var arrayProjects = [];
    var canvas;
    var ctx;
    var time;
    var arrayIndex = 0;
    var counter = 0;
    var today = new Date();
    var dateString = dateFormat(today.getDate(), today.getMonth(), today.getFullYear());
    var today = new Date();
    var canvasWidth;
    var canvasHeight;
    var fontsize;
    var divCounter = 0;
    var screenSaver;
    var time;
    var restartScreenSaver;
    var panelDuration = 20000;  // 45sec = default
    var screenSaverDuration = 10000;  // 20sec = default
    var initListener = 0;

    function createCanvasHTML() {
        canvasWidth = $('#content').width();
        canvasHeight = $('#content').width() * .136;
        fontsize = (canvasWidth * .043);

        $('#content').html('<canvas id="myCanvas" width="' + canvasWidth + '" height="' + canvasHeight + '" style="background-color:#202020;"></canvas><div id="PanelBoard1"></div>');

        canvas = document.getElementById("myCanvas");
        ctx = canvas.getContext('2d');
    }

    function screenSavers() {
        var randomScreenSaver = Math.floor(Math.random() * 2);

        switch (randomScreenSaver) {
            case 0:
                words();
                break;
            case 1:
                firefly();
                break;
        }
        setTimeout(function() {
        //let the screensaver run for XX sec while the porject data is initialized - clear all timers
            clearTimeout(screenSaver);
            clearTimeout(restartScreenSaver);
            
            if (initListener == 1) { // if init is finished go to board, if not repeat screen savers
                createCanvasHTML();
                displayPanels(0);
            }
            else {
                screenSavers();
            }
        }, screenSaverDuration);
    }

    function init(URL) {
        $.getJSON(URL, function(json) {
            var programData = json;
            //fillProjArray(programData) // Proj Array is a List of ALL Projects
            fillArrayThenRun(programData);
        });
    }

    function fillArrayThenRun(programData) {
    
        var projectName;    
        var taskDesc;
        var taskID;

        tempArray = new Array();
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //jan = 0
        var yyyy = today.getFullYear();
        var spacing = 0;

        if (dd < 10) {
            dd = '0' + dd;
        }
        var todayCheck = mm + '/' + dd;
        var buildTime = 'TBD';

        for (var i in programData['projects']) {
            var tempRowArray = new Array();
            projectName = programData['projects'][i]['name'];
            for (var j in programData['projects'][i]['task']) {
                var taskDate = programData['projects'][i]['task'][j]['date'];
                if (taskDate == todayCheck) {
                    taskID = programData['projects'][i]['task'][j]['id'];
                    taskDesc = programData['projects'][i]['task'][j]['shortDesc'];
                    buildTime = programData['projects'][i]['task'][j]['time'];

                    if (taskDesc.length > 26) {
                        taskDesc = taskDesc.substr(0, 26) + '...';
                    }
                    spacing = 47 - (taskID.length + buildTime.length + taskDesc.length);
                    var spacingText = '';
                    for (k = 0; k < spacing; k++) {
                        spacingText = spacingText + ' ';
                    }
                    rowString = taskID + ' - ' + taskDesc + spacingText + buildTime;

                    tempRowArray.push(rowString);
                }
            }
            if (tempRowArray.length > 0) {
                var titleObject = new Object();
                titleObject.title = projectName;
                titleObject.rows = tempRowArray;
                tempArray.push(titleObject);
            }
        }
        arrayProjects = tempArray;
        initListener = 1; // init is finished
    }


function displayPanels(arrayIndex) {
    $('#PanelBoard1').html('') // clear panel board
    ctx.clearRect(0, 0, canvas.width, canvas.height); // clear entire canvas

    //colors array
    var randomIndex = 0;
    var classNames = Array('blue', 'green', 'red', 'purple');
    var classColor = classNames[Math.floor(Math.random() * classNames.length)];

    for (x = 0; x < arrayProjects[arrayIndex].rows.length; x++) {
        buildCSS(arrayProjects[arrayIndex].rows[x], x, classColor);
    }

    buildCanvas(canvas.width * .02);

    animate(counter);

    next();

}

function next() {
    arrayIndex++;
    if (arrayIndex >= arrayProjects.length) {
        arrayIndex = 0;
    }

    time = setTimeout(function() {
        displayPanels(arrayIndex);
    }, panelDuration);
}

function buildCSS(phrase, lineNo, classColor) {

var html = $('#PanelBoard1').html() + '<div class="backgroundBox" id=Row'+ lineNo +'>';

	for (i=0;i<phrase.length;i++){
		var letter = phrase.substr(i,1);
		html = html + '<div class="littleBox ' + classColor + '" id=' + lineNo + '-' + i + '>' + letter + '</div>';
	}

	html = html + '</div>';
	$('#PanelBoard1').html(html);	
}

function buildCanvas(startY){
    //logo
    var phrase = arrayProjects[arrayIndex].title;
    ctx.font = fontsize + "px 'Times New Roman', Times, serif";
    ctx.fillStyle = "#9900CC";
    ctx.fillText('Build Board', 0, canvasHeight * .265);


    var startX = ((canvasWidth - (dateString.length * (canvasWidth * .034))) / 2) - (canvasWidth * .034);
    var letters = '';
    for (i = 0; i < dateString.length; i++) {
        letters = dateString.substr(i, 1);
        startX += (canvasWidth * .034);
        drawLetterBox(startX, startY, letters);
    }

    startX = ((canvas.width - (phrase.length * (canvasWidth * .034))) / 2) - (canvasWidth * .034);
	for (i=0;i<phrase.length;i++){
		letters = phrase.substr(i,1);
		startX += (canvasWidth * .034);
		drawLetterBox(startX, startY + (canvasWidth * .043) + ((canvasWidth * .043)*.20), letters);
	}	
}

function drawLetterBox(startX,startY,letter){
		
	//letterBoxes
	ctx.fillStyle = '#303030';
	ctx.fillRect(startX, startY, (canvasWidth * .034), (canvasWidth * .043));
	ctx.strokeRect(startX, startY, (canvasWidth * .034), (canvasWidth * .043)); 

	ctx.fillStyle = "#D0D0D0";

	//Letter
	ctx.font= fontsize + "px 'Courier New', Courier, monospace";
	ctx.fillText(letter, startX + (((canvasWidth * .030) - ctx.measureText(letter).width) / 2), startY + (canvasWidth * .035));
}


function animate(counter) {
    setTimeout(function() {
        $('.littleBox').eq(counter).css('display', 'inline-block');
        counter++;
        if ($('.littleBox').size() >= counter) {
            animate(counter);
        }
    }, 35);
}

function fireflyAnimate() {
    screenSaver = setTimeout(function() {
    $('.circle').eq(divCounter).show();
        divCounter++;
        if ($('.circle').size() >= divCounter) {
            fireflyAnimate();
        }
        else {
            firefly();
        }
    }, 10);
}

function firefly() {
    var html = '';
    for (i = 0; i < 5000; i++) {
        var randomLeft = Math.floor(Math.random() * ($('body').width() - 0 + 1)) + 0;
        var randomTop = Math.floor(Math.random() * ($('body').height() - 0 + 1)) + 0;
        var randomSize = Math.floor(Math.random() * (5 - 0 + .5)) + 1;
        html = html + '<div class="circle fireflyGreen" style="left:' + randomLeft + 'px; top:' + randomTop + 'px; width:' + randomSize + 'vw; height:' + randomSize + 'vw; z-index:' + i + 10 + ';"></div>';
    }
    $('#content').html(html);
    divCounter = 0;
    fireflyAnimate();
}

function words() {
    var divCounter = 0;
    var wordCount = 5;
    var loadingWord = "loading..."    
    var randomH = (Math.ceil(Math.random() * $('body').height()) * 1.5);
    var randomW = (Math.ceil(Math.random() * $('body').width()) * 1.5);
    var randomTop = (Math.floor(Math.random() * 2) == 0) ? 0 - randomH : randomH;  
    var startLeftPos = (Math.floor(Math.random() * 2) == 0) ? 0 - randomW : randomW;
    var html = '<div class="letters" style="left:' + startLeftPos + 'px; top:' + randomTop + 'px;">' + loadingWord + '</div>';
    
    $('#content').html(html);
    wordsAnimate();
}

function wordsAnimate() {

    var colorArray = new Array('9900CC', '00FF99', 'FF9900', 'FF0033', '99FF00', '33FF66', '0066FF', 'FF66FF', '006699', 'FF3300', 'CCFF00', '6633FF', '00FF99', '3366FF', 'FF3399', 'FF3366');
    var color = '#' + colorArray[Math.floor(Math.random() * colorArray.length)];
    var finalTop = Math.floor(Math.random() * ($('body').height() - $('.letters').height())) + 0;
    var finalLeftPos = Math.floor(Math.random() * ($('body').width() - $('.letters').width())) + 0;
   
    screenSaver = setTimeout(function() {
        $('.letters').animate({
            opacity: 0.75,
            left: finalLeftPos,
            top: finalTop,
            color: '#' + color
        }, 3000, function() { });
        $('.letters').css('color', color);
        wordsAnimate();
    }, 800);
}


function dateFormat(dd, mm, yyyy) {
    var fdate;
    var month;
    switch (mm) {
        case 0:
            month = 'JAN';
            break
        case 1:
            month = 'FEB';
            break
        case 2:
            month = 'MAR';
            break
        case 3:
            month = 'APR';
            break
        case 4:
            month = 'MAY';
            break
        case 5:
            month = 'JUN';
            break
        case 6:
            month = 'JUL';
            break
        case 7:
            month = 'AUG';
            break
        case 8:
            month = 'SEPT';
            break
        case 9:
            month = 'OCT';
            break
        case 10:
            month = 'NOV';
            break
        case 11:
            month = 'DEC';
            break
    }
    if (dd < 10) {
        dd = '0' + dd;
    }

    var fDate = month + " " + dd + ", " + yyyy;
    return fDate;
}

</script>
    </form>
</body>
</html>

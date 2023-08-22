class JsScript {
  static const String isLinkScript = '''
function isLink() {
    if (window.getSelection().toString !== '') {
      const selection = window.getSelection().getRangeAt(0)
      if (selection) {
        if (selection.startContainer.parentNode.tagName === 'A'
        || selection.endContainer.parentNode.tagName === 'A') {
          return true
        } else { return false }
      } else { return false }
    }
  }
  function isEnd(){
all=document.querySelector('*');
text = all.innerText;
    let sel = getSelection(),
	result = {start: null, end: null};
	['start', 'end'].forEach(which => {
		let
		counter = 1,
		tmpNode = all.querySelector('span'),
		node = which == 'start' ? 'anchor' : 'focus'
		;
		if (!sel) return;
		while(tmpNode !== sel[node+'Node'].parentElement) {
			result[which] += tmpNode.innerText.length;
			counter++;
			tmpNode = all.querySelector('span:nth-child('+counter+')')
		}
		result[which] += sel[node+'Offset'] + (which == 'start' ? 1 : 0);
	});

  return result;
  }
function isOverTheEdge() {
    var el=document.getElementById('summernote-2');
    var atStart = false, atEnd = false;
    var selRange, testRange;
    if (window.getSelection) {
        var sel = window.getSelection();
        if (sel.rangeCount) {
            selRange = sel.getRangeAt(0);
            testRange = selRange.cloneRange();

            testRange.selectNodeContents(el);
            testRange.setEnd(selRange.startContainer, selRange.startOffset);
            atStart = (testRange.toString() == "");

            testRange.selectNodeContents(el);
            testRange.setStart(selRange.endContainer, selRange.endOffset);
            atEnd = (testRange.toString() == "");
        }
    } else if (document.selection && document.selection.type != "Control") {
        selRange = document.selection.createRange();
        testRange = selRange.duplicate();
        
        testRange.moveToElementText(el);
        testRange.setEndPoint("EndToStart", selRange);
        atStart = (testRange.text == "");

        testRange.moveToElementText(el);
        testRange.setEndPoint("StartToEnd", selRange);
        atEnd = (testRange.text == "");
    }

    return { atStart: atStart, atEnd: atEnd };
}


window.parent.postMessage(
  JSON.stringify(
    {
      "type": "toDart: isLinkSelected", 
      "isLinkSelected": isLink(),
      "textIndex": document.getSelection().focusOffset
    }
  ), 
  "*"
);  
''';

  static const String getSelectedLinkParts = '''
function getSelectedLink(){
  const selection= window.getSelection().getRangeAt(0)
  
  return selection.startContainer.parentNode.href
}

function getSelectedText(){
  const selection= window.getSelection().getRangeAt(0)

  return selection.endContainer.parentNode.innerHTML
}

window.parent.postMessage(
  JSON.stringify(
    {
      "type": "toDart: getSelectedLinkParts", 
      "text": getSelectedText(),
      "link": getSelectedLink()
     
    }
  ), 
  "*"
); 
''';

  static const String setStyleScript = '''
var allElements=document.querySelectorAll("*");
allElements.forEach((element) => element.style.fontFamily = "Avenir"); 
allElements.forEach((element) => element.style.fontSize = "16px");
allElements.forEach((element) => element.tagName !== 'A'? element.style.color = "black": element);
allElements.forEach((element) => element.style.backgroundColor = "transparent");
''';
}

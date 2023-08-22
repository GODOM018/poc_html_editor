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

window.parent.postMessage(
  JSON.stringify(
    {
      "type": "toDart: isLinkSelected", 
      "isLinkSelected": isLink(),
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

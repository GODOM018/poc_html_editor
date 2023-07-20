# POC html editor

This library is proof of the content of an html editor that converts its content to markdown. 

## Usage
The flow of the data is the following.

A Markdown Text can be inserted as initial text. It is converted to HTML using the library [Markdown](https://pub.dev/packages/markdown) and set as initial text in the editor.
The editor of the library [HTML Editor Enhanced](https://pub.dev/packages/html_editor_enhanced) contains the User Interface that allows the user to edit and format its text. It uses only HTML text, so the result is given in HTML. It must be converted to Markdown using the library [html2md](https://pub.dev/packages/html2md). 

The input and output should be in markdown because the app supports only the preview of markdown text. 

## Demo

The HTML Enhanced Editor is able to apply several basic styles to the same part of the text.

![Demo Video 2](https://github.com/GODOM018/poc_html_editor/assets/116824383/e4e939c7-6191-4304-a345-5467d5b03fbd)

Also, we can add styles over hyperlinks:

![Demo Video 3](https://github.com/GODOM018/poc_html_editor/assets/116824383/183554f3-3daa-4a95-b93a-d79f60833d67)

The library supports several types of markdowns, such as headings, code, and quotations.

![Screen Recording 2023-07-17 at 12 08 59](https://github.com/GODOM018/poc_html_editor/assets/116824383/2028f1cd-5f7d-4e24-9a50-20cbc48b4eb7)

It also supports tables!
![Screenshot 2023-07-18 at 14 36 55](https://github.com/GODOM018/poc_html_editor/assets/116824383/9e2fa9a8-c69d-4366-bfe4-e412e97fd28d)

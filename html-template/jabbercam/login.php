<html>
<head>
<title>Login JabberCam</title>

<script type="text/javascript">
function checkSubmit() {
if(uname.value == "" || pname.value == "")
return;

window.location.href="index.html?uname="+uname.value+"&pname="+pname.value+"&uconnect="+(uconnect.value?"true":"false");
}
</script>
</head>
<body>
Username: <input type="text" id="uname"/><br>
Partner: <input type="text" id="pname"/><br>
Auto Connect: <input type="checkbox" id="uconnect"/><br>
<input type="button" value="Submit" onclick="checkSubmit()" />
</body>
</html>
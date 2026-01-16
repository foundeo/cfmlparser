component {
	
	function onRequest() {
		cfheader(name="foo", value="#boo#");
		cfhttp(url="address.cfm", method=getMethod()) {
			cfhttpparam(name="foo", value="moo", type="header");
		}
	}

	function getMethod() {
		return "GET";
	}
}
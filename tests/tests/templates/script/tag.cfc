component {
	
	function onRequest() {
		cfheader(name="foo", value="#boo#");
		cfhttp(url="address.cfm") {
			cfhttpparam(name="foo", value="moo", type="header");
		}
	}
}
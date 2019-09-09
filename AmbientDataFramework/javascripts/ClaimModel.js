function Claim(key, value) {
	this.key = key;
	this.value = value;
	this.nestedValues = [];
	
	if (typeof(value) == "object") {
		this.value = null;
		for (var v in value) {
			this.nestedValues.push(new Claim(v, value[v]));
		}
	}
	
	this.contains = function(searchTerm) {
		var term = searchTerm.toLowerCase();
		var lowerCaseKey = this.key.toLowerCase();
		var lowerCaseValue = this.value != null ? this.value.toString().toLowerCase() : "";
		
		return lowerCaseKey.indexOf(term) > -1 || lowerCaseValue.indexOf(term) > -1 ||
			jQuery.grep(this.nestedValues, function(claim, index) {
				return claim.contains(term);
			}).length > 0;
	}
};

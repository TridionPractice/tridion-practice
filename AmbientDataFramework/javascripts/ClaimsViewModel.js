// View Model
function ClaimsViewModel() { 
	var self = this;
	self.loading = ko.observable(false);
	self.filter = ko.observable(null);
	self.allClaims = ko.observableArray();
	self.rawJson = ko.observable();
	self.autoRefresh = ko.observable(true).extend({persist: "autoRefresh"});
	self.refreshInterval = ko.observable(30);
	
	self.autoRefresh.subscribe(function(newValue) {
		if (newValue) {
			self.poller = setInterval(function() { self.refresh(); }, self.refreshInterval() * 1000);
		} else if (self.poller) {
			clearInterval(self.poller);
			self.poller = null;
		}
	});
	
	self.refresh = function() {
		self.loading(true);
		$.getJSON("?format=json", function(data) { 
			self.rawJson(JSON.stringify(data, null, 2));
			var result = [];
			for (var key in data)
			{
				result.push(new Claim(key, data[key]));
			}
			
			result.sort(function(a,b) {
				if (a.key > b.key) { return 1; }
				if (a.key < b.key) { return -1;}
				return 0;
            });
						
			self.allClaims(result);
			self.loading(false);
		});
	};
	
	self.claims = ko.computed(function() {
		var filter = self.filter();
		if (filter) {
			return jQuery.grep(self.allClaims(), function(claim, index) {
				return claim.contains(filter);
			});
		}
		
		return self.allClaims();
	});
	
	self.clearFilter = function(data, event) {
		self.filter(null);
	}
};

// Document load
$(document).ready(function() {
	var viewModel = new ClaimsViewModel();
	viewModel.refresh();
	ko.applyBindings(viewModel);
});
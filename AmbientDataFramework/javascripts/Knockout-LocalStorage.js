// Knockout extensions
(function(ko) {
	if (typeof (localStorage) === "undefined") return;

	ko.extenders.persist = function(target, key) {
		var initialValue = target();
		if (key && localStorage.getItem(key) !== null) {
			try {
				initialValue = JSON.parse(localStorage.getItem(key));
			} catch (e) {
			}
		}
		target(initialValue);

		target.subscribe(function (newValue) {
			localStorage.setItem(key, ko.toJSON(newValue));
		});
		return target;
	};
})(ko);
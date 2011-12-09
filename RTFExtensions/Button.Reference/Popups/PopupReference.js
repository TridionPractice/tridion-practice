Type.registerNamespace("RTFExtensions.Popups");

RTFExtensions.Popups.PopupReference = function (element) {
    Type.enableInterface(this, "RTFExtensions.Popups.PopupReference");
    this.addInterface("Tridion.Cme.View");
};

RTFExtensions.Popups.PopupReference.prototype.initialize = function () {
    $log.message("Initializing Button Reference popup...");
    this.callBase("Tridion.Cme.View", "initialize");

    var p = this.properties;
    var c = p.controls;

    p.HtmlValue = { value: null };

    c.InsertButton = $controls.getControl($("#InsertButton"), "Tridion.Controls.Button");
    $evt.addEventHandler(c.InsertButton, "click", this.getDelegate(this._execute));
};

RTFExtensions.Popups.PopupReference.prototype._execute = function () {
    this.properties.HtmlValue.value = "<p><u>Sample string of HTML</u></p>";
    this.fireEvent("submit", this.properties.HtmlValue);
    window.close();
};

$display.registerView(RTFExtensions.Popups.PopupReference);
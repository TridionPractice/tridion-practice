Type.registerNamespace("RTFExtensions.Commands");

RTFExtensions.Commands.ButtonReference = function Commands$ButtonReference(name) {
    Type.enableInterface(this, "RTFExtensions.Commands.ButtonReference");
    this.addInterface("Tridion.Cme.Command", [name || "ButtonReference"]);
    this.addInterface("Tridion.Cme.FaCommand", [name || "ButtonReference"]);
};

RTFExtensions.Commands.ButtonReference.prototype._isAvailable = function ButtonReference$_isAvailable(target) {
    if (target.editor.getDisposed()) {
        return false;
    }

    return true;
};

RTFExtensions.Commands.ButtonReference.prototype._isEnabled = function ButtonReference$_isEnabled(target) {
    if (!Tridion.OO.implementsInterface(target.editor, "Tridion.FormatArea") || target.editor.getDisposed()) {
        return false;
    }

    return true;
};

RTFExtensions.Commands.ButtonReference.prototype._execute = function ButtonReference$_execute(target) {
    if (target.item.isActivePopupOpened()) {
        return;
    }

    function ButtonReference$execute$onPopupCanceled(event) {
        target.item.closeActivePopup();
    };

    var url = $config.expandEditorPath("/Popups/PopupReference.aspx", "ButtonReference");
    var popup = $popup.create(url, "toolbar=no,width=100,height=100,resizable=yes,scrollbars=yes", null);

    $evt.addEventHandler(popup, "submit",
		function ButtonReference$execute$onPopupSubmitted(event) {
		    // Update FA
		    var value = event.data.value;
		    if (value) {
		        target.editor.applyHTML(value);
		    }

		    // Release
		    target.item.closeActivePopup();
		}
    );

    $evt.addEventHandler(popup, "unload", ButtonReference$execute$onPopupCanceled);

    target.item.setActivePopup(popup);
    popup.open();
};
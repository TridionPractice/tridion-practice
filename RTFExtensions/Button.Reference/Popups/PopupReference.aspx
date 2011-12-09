<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PopupReference.aspx.cs" Inherits="Button.Reference.Popups.PopupReference" %>

<%@ Import Namespace="Tridion.Web.UI.Core" %>
<%@ Import Namespace="Tridion.Web.UI" %>
<%@ Import Namespace="System.Web" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:c="http://www.sdltridion.com/web/ui/controls">

<head id="Head1" runat="server">
    <title>Reference Button Popup</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <h1>Reference Button Popup</h1>
        <p>
            <c:button id="InsertButton" runat="server" class="customButton greybutton" label="Insert" />
        </p>
    </div>
    </form>
</body>
</html>
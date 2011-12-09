using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Tridion.Web.UI.Controls;
using Tridion.Web.UI.Core.Controls;

namespace Button.Reference.Popups
{
    [ControlResourcesDependency(new Type[] { typeof(Popup), typeof(Tridion.Web.UI.Controls.Button), typeof(Stack), typeof(Dropdown), typeof(List) })]
    [ControlResources("RTFExtensions.ButtonReference")]
    public partial class PopupReference : TridionPage
    {
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            TridionManager tm = new TridionManager();

            tm.Editor = "PowerTools";
            System.Web.UI.HtmlControls.HtmlGenericControl dep = new System.Web.UI.HtmlControls.HtmlGenericControl("dependency");
            dep.InnerText = "Tridion.Web.UI.Editors.CME";
            tm.dependencies.Add(dep);

            System.Web.UI.HtmlControls.HtmlGenericControl dep2 = new System.Web.UI.HtmlControls.HtmlGenericControl("dependency");
            dep2.InnerText = "Tridion.Web.UI.Editors.CME.commands";
            tm.dependencies.Add(dep2);

            //Add them to the Head section
            this.Header.Controls.Add(tm); //At(0, tm);
        }
    }
}
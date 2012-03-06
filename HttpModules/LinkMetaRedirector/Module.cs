using System;
using System.Configuration;
using System.Web;

using Tridion.ContentDelivery.DynamicContent.Query;
using Tridion.ContentDelivery.Web.Linking;

namespace LinkMetaRedirector
{
    public class Module : IHttpModule
    {
        public void Init(HttpApplication app)
        {
            //app.Error += new EventHandler(OnError);
            app.BeginRequest += new EventHandler(TryRedirect);
        }

        public void Dispose() { }

        public delegate void RedirectEventHandler(Object s, EventArgs e);

        private RedirectEventHandler _redirectEventHandler = null;

        public event RedirectEventHandler RedirectEvent
        {
            add { _redirectEventHandler += value; }
            remove { _redirectEventHandler -= value; }
        }

        public void TryRedirect(Object s, EventArgs e)
        {
            HttpContext context = HttpContext.Current;

            int publicationId = int.Parse(ConfigurationManager.AppSettings["GlobalPubId"]);
            string redirectField = ConfigurationManager.AppSettings["RedirectUrlField"];

            string url = context.Request.Url.PathAndQuery;
            int pos = url.IndexOf("?");
            if (pos > 0) url = url.Substring(0, pos);

            PublicationCriteria publicationCriteria = new PublicationCriteria(publicationId);
            ItemTypeCriteria itemCriteria = new ItemTypeCriteria(64);
            CustomMetaValueCriteria cmvCriteria = new CustomMetaValueCriteria(new CustomMetaKeyCriteria(redirectField), url);
            AndCriteria andCriteria = new AndCriteria(new Criteria[] { publicationCriteria, itemCriteria, cmvCriteria });

            Query query = new Query(andCriteria);

            string[] results = query.ExecuteQuery();

            if (results.Length > 0)
            {
                PageLink pageLink = new PageLink(publicationId);
                Link link = pageLink.GetLink(results[0]);

                if (link.IsResolved)
                {
                    // Redirect
                    HttpResponse response = context.Response;
                    response.Clear();
                    response.RedirectLocation = link.Url;
                    response.StatusCode = 301;
                    response.StatusDescription = "301 Moved Permanently";
                    response.Write("Page has moved to " + link.Url);
                    response.End();
                }
            }
        }
    }
}

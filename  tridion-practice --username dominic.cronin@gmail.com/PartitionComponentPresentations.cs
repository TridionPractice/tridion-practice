using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Tridion.ContentManager.Templating.Assembly;
using Tridion.ContentManager.Templating;
using Tridion.ContentManager.ContentManagement;
using Tridion.ContentManager.CommunicationManagement;
using Tridion.ContentManager;


namespace ClassifyComponentPresentations
{
    abstract class PartitionComponentPresentations : ITemplate
    {
        Engine _engine;
        Package _package;
        virtual public void Transform(Engine engine, Package package)
        {
            _engine = engine;
            _package = package;
        }

        protected void partitionCPs(IList<PartitionDescriptor> partitionDescriptors)
        {
            var pageItem = _package.GetByType(ContentType.Page);
            if (pageItem == null)
            {
                // TODO - clean exception
                throw new Exception("This TBB can only be used in a page template.");
            }
            var pageAsSource = pageItem.GetAsSource();
            TcmUri pageUri = new TcmUri(pageAsSource.GetValue("ID"));
            Page page = (Page)_engine.GetSession().GetObject(pageUri);

            var cpLists = new Dictionary<string, ComponentPresentationList>();
            foreach (var pd in partitionDescriptors)
            {
                cpLists.Add(pd.name, new ComponentPresentationList()); 
            }

            try
            {
                cpLists.Add("Components", new ComponentPresentationList());
            }
            catch (Exception ex)
            {
                // TODO selectively catch and specifically throw
                throw new Exception("Can't use Components, we use that - pick your own name.", ex);
            }


            foreach (var cp in page.ComponentPresentations)
            {
                Tridion.ContentManager.Templating.ComponentPresentation templatingCP =
                    new Tridion.ContentManager.Templating.ComponentPresentation(
                    new TcmUri(cp.Component.Id), new TcmUri(cp.ComponentTemplate.Id));

                bool matched = false;
                foreach(var pd in partitionDescriptors)
                {
                    if (pd.test(cp.Component, cp.ComponentTemplate ))
                    {
                        cpLists[pd.name].Add(templatingCP);
                        matched = true;
                        break;
                    }
                }
                if (!matched)
                {
                    cpLists["Components"].Add(templatingCP );
                }
            }


        }

        protected struct PartitionDescriptor
        {
            public PartitionDescriptor(string name, Func<
                    Tridion.ContentManager.ContentManagement.Component
                    , Tridion.ContentManager.CommunicationManagement.ComponentTemplate
                    , bool> test) 
            
            {
                this.name = name;
                this.test = test;
            }
            public string name;
            public Func<
                    Tridion.ContentManager.ContentManagement.Component 
                    ,Tridion.ContentManager.CommunicationManagement.ComponentTemplate
                    , bool> test;
        }

    }
}

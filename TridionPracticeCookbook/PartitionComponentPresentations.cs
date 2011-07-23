using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Tridion.ContentManager.Templating.Assembly;
using Tridion.ContentManager.Templating;
using Tridion.ContentManager.ContentManagement;
using Tridion.ContentManager.CommunicationManagement;
using Tridion.ContentManager;


namespace TridionPractice
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
                throw new WrongKindOfRenderException();
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
                cpLists.Add(Package.ComponentsName, new ComponentPresentationList());
            }
            catch (ArgumentException ex)
            {			
                throw new ComponentsNameIsReservedException("Your own component presentation lists may not be called Components.", ex);
            }


            foreach (var cp in page.ComponentPresentations)
            {
                Tridion.ContentManager.Templating.ComponentPresentation templatingCP =
                    new Tridion.ContentManager.Templating.ComponentPresentation(
                    new TcmUri(cp.Component.Id), new TcmUri(cp.ComponentTemplate.Id));

                bool matched = false;
                foreach (var pd in partitionDescriptors)
                {
                    if (pd.test(cp.Component, cp.ComponentTemplate))
                    {
                        cpLists[pd.name].Add(templatingCP);
                        matched = true;
                        break;
                    }
                }
                if (!matched)
                {
                    cpLists[Package.ComponentsName].Add(templatingCP);
                }

                Item componentItem = _package.CreateTridionItem(ContentType.Component, new TcmUri(cp.Component.Id));
                _package.PushItem(Package.ComponentName, componentItem);

            }

            foreach (var list in cpLists)
            {
                ComponentPresentationList cpl = (ComponentPresentationList)list.Value;
                Item componentArray = _package.CreateStringItem(
                                ContentType.ComponentArray,
                                cpl.ToXml());
                _package.PushItem(list.Key, componentArray);
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
                    , Tridion.ContentManager.CommunicationManagement.ComponentTemplate
                    , bool> test;
        }

        [Serializable]
        public class ComponentsNameIsReservedException : Exception
        {
            public ComponentsNameIsReservedException() { }
            public ComponentsNameIsReservedException(string message) : base(message) { }
            public ComponentsNameIsReservedException(string message, Exception inner) : base(message, inner) { }
            protected ComponentsNameIsReservedException(
              System.Runtime.Serialization.SerializationInfo info,
              System.Runtime.Serialization.StreamingContext context)
                : base(info, context) { }
        }

        [Serializable]
        public class WrongKindOfRenderException : Exception
        {
            public WrongKindOfRenderException() : base("This TBB is only useful in page templates.") { } 
            public WrongKindOfRenderException( string message ) : base( message ) { }
            public WrongKindOfRenderException( string message, Exception inner ) : base( message, inner ) { }
            protected WrongKindOfRenderException( 
            System.Runtime.Serialization.SerializationInfo info, 
            System.Runtime.Serialization.StreamingContext context ) : base( info, context ) { }
        }
    }
}

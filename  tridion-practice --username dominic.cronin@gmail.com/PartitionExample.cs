using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Tridion.ContentManager.Templating;
using Tridion.ContentManager.Templating.Assembly;

namespace TridionPractice
{
    class PartitionExample : PartitionComponentPresentations
    {
        override public void Transform(Engine engine, Package package)
        {
            base.Transform(engine, package);
            partitionCPs(new List<PartitionDescriptor>(){
                   new PartitionDescriptor("AllTheFA3s", (c, ct) => c.Schema.Title == "FA3"), 
                   new PartitionDescriptor("Foo", (c, ct) => ct.Title == "CT Foo")
            });
        }
    }
}

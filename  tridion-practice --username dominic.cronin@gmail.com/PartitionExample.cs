using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Tridion.ContentManager.Templating;

namespace ClassifyComponentPresentations
{
    class PartitionExample : PartitionComponentPresentations
    {
        override public void Transform(Engine engine, Package package)
        {
            base.Transform(engine, package);
            partitionCPs(new List<PartitionDescriptor>(){
                   new PartitionDescriptor("banana", (c, ct) => c.Schema.Title == "Foobar"), 
                   new PartitionDescriptor("fruitcake", (c, ct) => ct.Title == "FrumpyPlump")
            });
        }
    }
}

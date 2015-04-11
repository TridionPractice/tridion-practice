# Partition Component Presentations #


## Problem ##
Your Tridion page has various types of component presentations, each of which fulfils a different purpose in the page. You may wish to have items where the component is based on a certain schema placed in your main content area. Perhaps you have a "Related Links" area, which should display items which are rendered by specific component templates, and so forth. This pattern is common enough that you want to have a general solution which you can easily re-use.


## Solution ##
### Introduction ###
The default template building block "Extract Components From Page" makes the component presentations in a page available to building blocks further down the pipeline as a ComponentArray package item called "Components". This is a representation of a Tridion.ContentManager.Templating.ComponentPresentationList which can, for example, be consumed by a DWT with code like this:

```
<!-- TemplateBeginRepeat name="Components" -->
@@RenderComponentPresentation()@@
<!-- TemplateEndRepeat -->
```

Using a similar technique, we want to divide the Component Presentations into several "partitions", and create a named ComponentArray package item for each. To keep the solution generic we need a way to describe each of our partitions. We will then create our [TBB](#Terminology.md) by inheriting from a base class that that takes care of the mechanics of looping through the component presentation and adding them to the correct array.

### Describing a Partition ###
In order to describe each partition, we need two things:

  1. A name
  1. A test which our base class can apply to a component presentation to determine whether it matches.

The test, at least in this cookbook example, will require access to the Component and the Component template that make up the component presentation. To allow this, we define a PartitionDescriptor with two fields:

```
        protected struct PartitionDescriptor
        {
            public string name;
            public Func<
                    Tridion.ContentManager.ContentManagement.Component
                    , Tridion.ContentManager.CommunicationManagement.ComponentTemplate
                    , bool> test;
        }

```

As you can see, the test is a delegate to a function that takes a component and a component template and returns a boolean. Fortunately, with the aid of a constructor, and lambda expression syntax, the client code you need to write is fairly straightforward. For example, to put all your link blocks in a ComponentArray in your package, you would instantiate your PartitionDescriptor like this:

```
new PartitionDescriptor("LinkBlocks", (c, ct) => c.Schema.Title == "LinkBlock")
```

Depending on your design, you might want something more robust than just checking the title, but that's beyond the scope of this recipe.

### Creating your template class ###
In the example code, you'll find the following:

```
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

```
As you can see, you need to call the partitionCPs method and pass in a list of PartitionDescriptors. The base class will work its way down the component presentations in the page, and for each one, it will process the PartitionDescriptors in order. Your component presentation will end up in one and only one ComponentArray. The first test that matches wins, and if none of the tests match, the ComponentPresentation will be added to "Components"

### The base class ###

The base class code can be viewed [here](https://code.google.com/p/tridion-practice/source/browse/TridionPracticeCookbook/PartitionComponentPresentations.cs)

The partitionCPs method first loops through the PartitionDescriptors and creates the necessary ComponentPresentationLists. (If you prefer, you could create these on demand.) It then loops again, applying the tests as described above. It also adds the components to the package, making it usable as a drop-in replacement for Extract Components From Page.
Finally it adds generates the ComponentArrays and adds them to the package.

## Using the Component Arrays ##
Once your partitioning template has executed, you can make use of the ComponentArrays in the familiar way. You simply specify the name that you used in your PartitionDescriptor.

```
<!-- TemplateBeginRepeat name="LinkBlocks" -->
@@RenderComponentPresentation()@@
<!-- TemplateEndRepeat -->
```

## Discussion ##

### Type inference and namespaces ###
You could consider an implementation where the signature of the function delegate is different. The choice to expose the Component and ComponentTemplate separately was made after a certain amount of experimentation to ensure that the compiler would be able to infer the types in the lambda expression unambiguously. This is because Tridion has a ComponentPresentation type in two different namespaces:

```
Tridion.ContentManager.Templating.ComponentPresentation
Tridion.ContentManager.CommunicationManagement.ComponentPresentation
```

It seems best to choose a design that hides this difficulty in the base class.

### Invoking the base class Transform method ###
It seems awkward to require the the derived class must invoke base.Transform(). Passing engine and package to partitionCPs might be better, but this also seems awkward. Unfortunately, the pipeline model doesn't give us access to constructors, so we probably just have to live with this.

## Terminology ##
Those of you who remember your high school mathematics, or have access to Wikipedia will know that the sets in a [partition](http://en.wikipedia.org/wiki/Partition_of_a_set) ought not to be empty. Leaving that fine distinction aside, and of course that the sets we're dealing with are sequences, it's a good enough name for what we're busy with here. And of course, to most computer people, "a partition" refers to one of the parts, and that goes here too. Nothing to see here, move along please.

For the rest, we're all Tridion folks here, and that's how we'll talk. So sometimes we'll say template when we mean template building block, and sometimes we'll say things like TBB and DWT without further explanation. OK?
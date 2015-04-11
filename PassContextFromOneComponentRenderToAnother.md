
# Introduction #

When working with compound templating, it is possible to pass a variable from the page render to each of the component renders by making use of the ContextVariables Dictionary in the engine.PublishingContext.RenderContext of the Page render, and retrieving it in a similar way in the Component render. Unfortunately, this technique is less useful than some people would wish, because the ContextVariables dictionary which you are handed in the Component render is a copy of the one in the Page Render, which means that your page template, and subsequent component templates aren't aware of any data you write back into the dictionary. In many ways the idea behind the restriction is a good one. It's fairly rare to find a genuine situation where you need to pass information out of the Component render, but for those few occasions, here is a technique to achieve this.

# The Context Bag #
Because ContextVariables is a dictionary of object, you can add a dictionary of your own as one of its items (or in this example, its only item)

We create this new dictionary in the page template. Your first template building block might look something like this:

```C#

[TcmTemplateTitle("SetUpContextBag")]
public class SetUpContextBag : ITemplate
{
void ITemplate.Transform(Engine engine, Package package)
{
Dictionary<string, object> contextBag = new Dictionary<string, object>();
engine.PublishingContext.RenderContext.ContextVariables.Add("contextBag", contextBag);
}
}
```

Then in your component templates you can read and write to the contextBag dictionary, and copy the values to and from package variables. To demonstrate this, imagine a page with two list components on it. We wish to prefix each item in the lists with a number, which must be incremented for each item, giving us a running count that spans both lists. (Admittedly, this is a contrived example for simplicity's sake. The question that prompted me to write this up was about placing numbered footnotes at the bottom of a multi-component page.)

For the example, I'm just hard-coding the running count. In a real implementation, you may wish to do more with package variables and parameters.

So the first building block of the component template grabs the running count from the contextBag. Because we won't know which component is first, I'm also covering the scenario where the value hasn't been set yet. The page template might also be a good place for this logic.

```C#

[TcmTemplateTitle("PullVariableFromContextBag")]
class PullVariableFromContextBag : ITemplate
{
public void Transform(Engine engine, Package package)
{
var contextBag = (Dictionary<string, object>)engine.PublishingContext.RenderContext.ContextVariables["contextBag"];
string runningCount;
if (contextBag.ContainsKey("RunningCount"))
{
runningCount = (string)contextBag["RunningCount"];
if (string.IsNullOrEmpty(runningCount))
{
runningCount = "0";
}
}
else { runningCount = "0"; }
Item runningCountItem = package.CreateStringItem(ContentType.Number, runningCount);
package.PushItem("RunningCount", runningCountItem);
}
}
```

Next in your component template comes the rendering TBB. I've written the example as a standard assembly TBB in C#. This kind of work is closer to programming than templating anyway, so you might find it difficult to do in Dreamweaver syntax (and probably impossible without a custom FunctionSource). In any case, C# shows the logic quite nicely.

```C#

[TcmTemplateTitle("RenderList")]
class RenderList : ITemplate
{
public void Transform(Engine engine, Package package)
{
var runningCount = int.Parse(package.GetByName("RunningCount").GetAsString());
Item componentItem = package.GetByName(Package.ComponentName);
var component = (Component)engine.GetObject(componentItem);
ItemFields itemFields = new ItemFields(component.Content, component.Schema);
var itemLines = (SingleLineTextField)itemFields["item"];
string output = "<ul>";
foreach (string textLine in itemLines.Values)
{
runningCount++;
output += string.Format("<li>{0} {1}

Unknown end tag for &lt;/li&gt;

", runningCount, textLine );
}
output += "

Unknown end tag for &lt;/ul&gt;

";
package.PushItem(Package.OutputName, package.CreateStringItem(ContentType.Html, output));
package.PushItem("RunningCount", package.CreateStringItem(ContentType.Number, runningCount.ToString()));
}
}
```

Having run the rendering TBB, the running count is updated in the package variable, and it only remains to push it back in to the context bag.

```C#

[TcmTemplateTitle("PushVariableToContextBag")]
class PushVariableToContextBag : ITemplate
{
public void Transform(Engine engine, Package package)
{
var runningCount = package.GetByName("RunningCount").GetAsString();
var contextBag = (Dictionary<string, object>)engine.PublishingContext.RenderContext.ContextVariables["contextBag"];
contextBag["RunningCount"] = runningCount;
}
}
```

The end result is something like this (if you'll grant me a little poetic license in the formatting etc.). As I said earlier, it's a contrived example, but it demonstrates that the counter is transmitted from one component presentation to another.

```
<html>
  <head>
    <title>RunningCountPage</title>
  <head>
  <body>
    <div id="main">     
      <ul>
        <li>1 One Potato</li>
        <li>2 Two Potato</li>
        <li>3 Three Potato</li>
        <li>4 Four</li>
      </ul>
      <ul>
        <li>5 Five Potato</li>
        <li>6 Six Potato</li>
        <li>7 Seven Potato</li>
        <li>8 More</li>
       </ul>      
    </div>
  </body>
</html>
```
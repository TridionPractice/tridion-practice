# Introduction #

Tridion's Content Delivery tier comes with `Query` and `Criteria` classes that allow you to build custom queries against its data storage layer. But in building such queries it can sometimes be a challenge to understand how the code you write, translates to a SQL statement executed against your database.

When you are using Microsoft SQL Server, you can use its SQL Server Profiler tool to look at the SQL statements that get generated from your code. By watching these statements, you can potentially see how changes to your code affect the generated query.

# Details #

Let's say that you have the following Java code that executes a query against your Content Delivery database:

```
Criteria searchCriteria = null;
SortParameter sortParam = null;
Calendar calendar = Calendar.getInstance();
calendar.add(Calendar.YEAR, 1);
searchCriteria = new ItemLastPublishedDateCriteria(calendar.getTime(), Criteria.LESS_OR_EQUAL_THAN);
sortParam = new SortParameter(SortParameter.ITEMS_LAST_PUBLISHED_DATE, SortParameter.DESCENDING);
searchCriteria = CriteriaFactory.And(searchCriteria, 
    CriteriaFactory.Or(new Criteria[] { 
        new ItemSchemaCriteria(29), new ItemSchemaCriteria(28), new ItemSchemaCriteria(27), 
        new ItemSchemaCriteria(26), new ItemSchemaCriteria(25) }));
searchCriteria = CriteriaFactory.And(searchCriteria, new PublicationCriteria(4));
System.out.println(searchCriteria.toString());

Query query = new Query(searchCriteria);
query.addSorting(sortParam);
System.out.println(query.toString());

String[] resultItems = query.executeQuery();
System.out.println("That query gave "+resultItems.length+" results");
if (resultItems != null && resultItems.length > 0) {
	for (String uri: resultItems) {
		System.out.println(uri);
	}
}
```

So this `Query` gets the URIs of recently published Components from the broker, filtered by their schema and publication.

Let's see what SQL gets generated for it.

Go into the Windows Start menu and then "Microsoft SQL Server 2008 [R2](https://code.google.com/p/tridion-practice/source/detail?r=2)" and "Performance Tools" start "SQL Server Profiler".

![https://tridion-practice.googlecode.com/svn/wiki/images/SQL%20Server%20Profiler%20-%20Start%20Menu.png](https://tridion-practice.googlecode.com/svn/wiki/images/SQL%20Server%20Profiler%20-%20Start%20Menu.png)

This will start SQL Server Profiler with an empty window. This tool can "listen in" on any SQL Server instance that you have access to and show you every query that is being executed. Each such listening session is called a **trace**, so let's first start a new trace:

![https://tridion-practice.googlecode.com/svn/wiki/images/SQL%20Server%20Profilter%20-%20New%20Trace.png](https://tridion-practice.googlecode.com/svn/wiki/images/SQL%20Server%20Profilter%20-%20New%20Trace.png)

This will pop up a connection dialog, that should look familiar if you've ever used SQL Server's Management Studio.

![https://tridion-practice.googlecode.com/svn/wiki/images/SQL%20Server%20Profiler%20-%20Connect%20to%20SQL%20Server.png](https://tridion-practice.googlecode.com/svn/wiki/images/SQL%20Server%20Profiler%20-%20Connect%20to%20SQL%20Server.png)

Just fill in the details of your SQL Server machine and the details you normally use to access it. In this screenshot we're using SQL Server's built-in authentication mechanism, but in many cases you'll probably use  Windows Authentication.

Next up we need to define the Trace Properties.

![https://tridion-practice.googlecode.com/svn/wiki/images/SQL%20Server%20Profiler%20-%20Trace%20Properties.png](https://tridion-practice.googlecode.com/svn/wiki/images/SQL%20Server%20Profiler%20-%20Trace%20Properties.png)

It is very tempting to simply skip this dialog. But if we do that, we'll end up with a trace that has way more information than we can reasonably go through.

A very simply way to reduce the amount of information in the trace is by filtering on database name. To do this, do to the second tab of the Trace Properties, called "Events Selection":

![https://tridion-practice.googlecode.com/svn/wiki/images/SQL%20Server%20Profiler%20-%20Events%20Selection.png](https://tridion-practice.googlecode.com/svn/wiki/images/SQL%20Server%20Profiler%20-%20Events%20Selection.png)

Check the "Show all columns" box (if it isn't checked yet), to make sure the Database Name column shows up. After that, click on "Column Filters" in the bottm right corner:

![https://tridion-practice.googlecode.com/svn/wiki/images/SQL%20Server%20Profiler%20-%20Filter%20on%20Database%20Name.png](https://tridion-practice.googlecode.com/svn/wiki/images/SQL%20Server%20Profiler%20-%20Filter%20on%20Database%20Name.png)

In the filter popup, select "DatabaseName" in the list on the left,  then enter your database name under the "Like" node on the right and click OK.

Now click Run in the Trace Properties dialog.

Your trace is now running. It will already show a first event in its output: the fact that the new trace has started. If the database you're looking at is being actively used, you will see events showing up almost immediately.

But in our case, nobody is using the database except us. So we run our Broker Query to see which SQL gets executed. The query shows up in the Trace Output window as an "RPC:Completed" event:

![https://tridion-practice.googlecode.com/svn/wiki/images/SQL%20Server%20Profiler%20-%20Trace%20Output.png](https://tridion-practice.googlecode.com/svn/wiki/images/SQL%20Server%20Profiler%20-%20Trace%20Output.png)

I suggest copy/pasting it into your favorite text editor and manually indenting it to increase its readability. Doing this shows that our code fragment above gets translated into this SQL statement:

```
select distinct itemmeta0_.PUBLICATION_ID as col_0_0_, itemmeta0_.ITEM_REFERENCE_ID as col_1_0_, itemmeta0_.ITEM_TYPE as col_2_0_, itemmeta0_.LAST_PUBLISHED_DATE as col_3_0_ 
from ITEMS itemmeta0_, COMPONENT componentm1_ 
inner join ITEMS componentm1_1_ on componentm1_.PUBLICATION_ID=componentm1_1_.PUBLICATION_ID and componentm1_.ITEM_REFERENCE_ID=componentm1_1_.ITEM_REFERENCE_ID 
where itemmeta0_.LAST_PUBLISHED_DATE<='2013-08-20 08:57:29.7460000' and (
	itemmeta0_.ITEM_REFERENCE_ID=componentm1_.ITEM_REFERENCE_ID and itemmeta0_.PUBLICATION_ID=componentm1_.PUBLICATION_ID and componentm1_.SCHEMA_ID=29 or 
	itemmeta0_.ITEM_REFERENCE_ID=componentm1_.ITEM_REFERENCE_ID and itemmeta0_.PUBLICATION_ID=componentm1_.PUBLICATION_ID and componentm1_.SCHEMA_ID=28 or 
	itemmeta0_.ITEM_REFERENCE_ID=componentm1_.ITEM_REFERENCE_ID and itemmeta0_.PUBLICATION_ID=componentm1_.PUBLICATION_ID and componentm1_.SCHEMA_ID=27 or 
	itemmeta0_.ITEM_REFERENCE_ID=componentm1_.ITEM_REFERENCE_ID and itemmeta0_.PUBLICATION_ID=componentm1_.PUBLICATION_ID and componentm1_.SCHEMA_ID=26 or 
	itemmeta0_.ITEM_REFERENCE_ID=componentm1_.ITEM_REFERENCE_ID and itemmeta0_.PUBLICATION_ID=componentm1_.PUBLICATION_ID and componentm1_.SCHEMA_ID=25
) and 
	itemmeta0_.PUBLICATION_ID=4 
order by itemmeta0_.LAST_PUBLISHED_DATE DESC
```

Now all that I have left to do, is figure out why the join condition from `itemmeta0_` to `componentm1_` is being pushed into the WHERE clause, instead of on a JOIN clause (like is being done from `componentm1_` to `componentm1_1_`).

Happy troubleshooting!
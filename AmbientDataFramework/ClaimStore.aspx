<%@Page Language="C#" EnableViewState="false"%>
<%@Import Namespace="Tridion.ContentDelivery.AmbientData" %>
<%@Import Namespace="System.Collections.Generic" %>
<html>
    <head>
        <title>Ambient Data Claim Store</title>
        <style type="text/css">
			body
			{
				font-family: "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;
				font-size: 12px;
			}
			table
			{
				background: #fff;
				width: 100%;
				border-collapse: collapse;
				text-align: left;
			}
			table th
			{
				font-size: 14px;
				font-weight: normal;
				color: #039;
				padding: 10px 8px;
				border-bottom: 2px solid #6678b1;
			}
			table td
			{
				border-bottom: 1px solid #ccc;
				color: #669;
				padding: 6px 8px;
			}
			table tbody tr:hover td
			{
				color: #009;
			}
			pre 
			{ 
				display: inline-block; 
				font-family: "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;
				font-size: 14px; 
				margin: 0px;
			}
			h2 { font-size: 20px; }
			.section { display: none; }
			.filter-area { background-color: #eee; color: navy;  }
			.filter { cursor: hand;}
			.filter:hover { background-color: black; color: white; }
			.SessionManagement { position: absolute; top: 7px; right: 10px; }
			
			/* Default section */
			#allClaimValues { display: inline }
        </style>
		
		<script language="javascript" type="text/javascript">
			var currentSection;
			var defaultSection = "allClaimValues";
			
			function GetInnerText(node)
			{
				if (node.textContent != undefined)
				{
					return node.textContent;
				}
				else if (node.innerText != undefined)
				{
					return node.innerText;
				}
				return node.text;
			}
			
			function FilterBySection(sectionId)
			{
				FilterByClaimUri("");
			
				if (!currentSection)
				{
					currentSection = document.getElementById(defaultSection);
				}
				
				currentSection.style.display = "none";
			
				var section = document.getElementById(sectionId);
				if (section)
				{
					section.style.display = "inline";
					currentSection = section;
				}
			}
			
			function FilterByClaimUri(claimUri)
			{
				if (claimUri == null)
				{
					claimUri = document.getElementById("filterText").value;
				}
			
				var allRows = document.getElementsByTagName("tr");
				for (var i = 0; i < allRows.length; i++)
				{
					var row = allRows[i];
					if (row.className == "row")
					{
						var cell = row.childNodes[0];
						row.style.display = (claimUri == "" || GetInnerText(cell).indexOf(claimUri) > -1) ? "" : "none";
					}
				}
			}
		</script>
        
        <script runat="server">
            protected ClaimStore _store = null;
			protected Dictionary<string, string> _sections = new Dictionary<string, string>();
			protected StringBuilder _output = new StringBuilder();

			/********************************************
			 * Event handlers
			 *******************************************/
			
            protected void Page_Load(object sender, EventArgs e)
            {
                _store = AmbientDataContext.CurrentClaimStore;
                OutputAllClaimValues();
                
                OutputHeaders();
                OutputServerVariables();
                OutputSessionVariables();
				
				WriteFilters();
				Output.Text = _output.ToString();
            }
			
            protected void AbandonSession_Click(object sender, EventArgs e)
            {
                Session.Abandon();
                Outcome.Text = "You've abandoned the session. Poor thing.";
            }
			/********************************************
			 * Utility methods
			 *******************************************/
			
			protected void WriteOut(string value)
			{
				_output.AppendLine(value);
			}

            public string StringArrayToString(object value)
            {
                if (value is string)
                {
                    return (string)value;
                }
                
                if (value is string[])
                {
                    return string.Join(" | ", ((string[])value));
                }

                return null;
            }

			protected string AsString(object targetObject)
			{
				if (targetObject == null)
				{
					return "(null)";
				}
				else
				{
					return targetObject.ToString();
				}
			}
			
			protected string EscapeValue(object value)
			{
				//return HttpUtility.HtmlEncode(AsString(value));
				return "<pre>" + HttpUtility.HtmlEncode(AsString(value)) + "</pre>";
			}

            protected SortedDictionary<string, object> SortDictionary(IDictionary dictionary)
            {
                SortedDictionary<string, object> result = new SortedDictionary<string, object>();
                
                foreach (DictionaryEntry entry in dictionary)
                {
                    result.Add(entry.Key.ToString(), entry.Value);
                }

                return result;
            }

            protected Uri GetUri(string uri)
            {
                return new Uri(uri, UriKind.RelativeOrAbsolute);
            }
			
            protected void WriteHeader(string header, string id)
            {
				_sections.Add(id, header);
                WriteOut(string.Format("<div id='{0}' class='section'><h2>{1}</h2><table><thead><th>Name</th><th>Value</th></thead><tbody>", id, header));
            }

            protected void WriteFooter()
            {
                WriteOut("</tbody></table></div>");
            }
            
            protected void WriteRow(string label, object value)
            {
				string id = label.Replace(" ", "_");
				id = id.Replace(":", "_");
                WriteOut(string.Format("<tr id='{0}' class='row'><td>{1}</td><td>{2}</td></tr>", id, label, value != null ? value : "(null)"));
            }
            

			/********************************************
			 * Sections
			 *******************************************/
			
            protected void OutputSessionVariables()
            {
                WriteHeader("Claim store session values", "sessionVariables");

                foreach (string key in Session)
                {
                    if (Uri.IsWellFormedUriString(key, UriKind.RelativeOrAbsolute))
                    {
                        object claimValue = _store.Get<object>(GetUri(key));
                        WriteRow(key, claimValue);
                    }
                }

                WriteFooter();
            }

            protected void OutputServerVariables()
            {
                WriteHeader("Server Variables", "serverVariables");

                IDictionary serverVariables = _store.Get<IDictionary>(GetUri("taf:server:variables"));
                if (serverVariables != null)
                {
                    foreach (DictionaryEntry entry in serverVariables)
                    {
                        WriteRow((string)entry.Key, StringArrayToString(entry.Value));
                    }
                }

                WriteFooter();
            }

            protected void OutputHeaders()
            {
                WriteHeader("Headers", "headers");

                IDictionary headers = _store.Get<IDictionary>(GetUri("taf:request:headers"));
                if (headers != null)
                {
                    foreach (DictionaryEntry entry in headers)
                    {
                        WriteRow((string)entry.Key, StringArrayToString(entry.Value));
                    }
                }

                WriteFooter();
            }
			
            protected void OutputAllClaimValues()
            {
                WriteHeader("All claim store values", "allClaimValues");

                System.Collections.Generic.IDictionary<System.Uri, object> values = _store.GetAll();

                SortedDictionary<string, object> sorted = SortDictionary((IDictionary)values);
                
                foreach (System.Collections.Generic.KeyValuePair<string, object> entry in sorted)
                {
					object value = entry.Value;
					
                    if (value is IDictionary)
                    {
                        string result = "";
                        
                        foreach (DictionaryEntry childValue in (IDictionary)value)
                        {
                            if (childValue.Value is object[])
                            {
                                result += "<ul>";
                                foreach (object grandChild in (object[])childValue.Value)
                                {
                                    result += string.Format("<li>{0}</li>", grandChild);
                                }
                                result += "</ul>";
                                continue;
                            }
                            
                            result += string.Format("<li>{0} = {1}</li>", AsString(childValue.Key), EscapeValue(childValue.Value));
                        }

                        WriteRow(entry.Key.ToString(), result);
                    }
                    else if (value is System.Collections.Generic.List<object>)
                    {
                        string result = "";

                        foreach (object childValue in (System.Collections.Generic.List<object>)value)
                        {
                            result += string.Format("<li>{0}</li>", EscapeValue(childValue));
                        }

                        WriteRow(entry.Key.ToString(), result);
                    }
					else if (value is string[])
					{
						WriteRow(AsString(entry.Key), EscapeValue(StringArrayToString(value)));
					}
                    else if (value is object[])
                    {
                        string result = "";

                        foreach (object childValue in (object[])value)
                        {
                            result += string.Format("<li>{0}</li>", EscapeValue(childValue));
                        }

                        WriteRow(entry.Key.ToString(), result);
                    }
                    else
                    {
                        WriteRow(AsString(entry.Key), EscapeValue(value));
                    }
                }

                WriteFooter();
            }
			
			/********************************************
			 * Filtering
			 *******************************************/
			
			protected void WriteFilters()
			{
				string result = "<div class='filter-area'>Filter: ";
				// Sections
				foreach (var entry in _sections)
				{
					result += String.Format("<span class='filter' onclick='FilterBySection(\"{0}\")'>{1}</span> | ", entry.Key, entry.Value);
				}
				
				// Specific cartridges
				result += "<span class='filter' onclick='FilterBySection(\"allClaimValues\"); FilterByClaimUri(\"taf:claim:ambientdata:sessioncartridge\")'>Session Cartridge</span> | ";
				result += "<span class='filter' onclick='FilterBySection(\"allClaimValues\"); FilterByClaimUri(\"taf:claim:audiencemanager\")'>AM Cartridge</span> | ";
				
				// Filter by free text (claim URI only)
				result += "<span class='filter'>By URI: <input id='filterText' type='text' value='' placeholder='Enter partial claim URI'></input><input type='button' onclick='FilterByClaimUri(null)' value='Filter'/></span></div>";
				Filters.Text = result;
			}

        </script>
    </head>
    <body>
        <form id="MainForm" runat="server">
			<asp:Literal ID="Filters" runat="server" />
			<asp:Literal ID="Output" runat="server"/>
			<div class="SessionManagement">
				<asp:Label ID="Outcome" Text="" runat="server" />
				<asp:Button ID="AbandonSession" Text="Abandon session" OnClick="AbandonSession_Click" runat="server" />
			</div>
        </form>
    </body>
</html>
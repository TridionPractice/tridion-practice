<%@ page language="java" contentType="text/html;charset=utf-8" pageEncoding="utf-8"
         import="com.tridion.ambientdata.*, 
		 com.tridion.ambientdata.claimstore.*, 
		 java.net.*, 
		 java.util.*, 
		 java.util.Map.Entry,
		 net.minidev.json.JSONObject"%>
<%!
		public String serializeClaimStore() {
			ClaimStore store = AmbientDataContext.getCurrentClaimStore();
			if (store == null) {
				return "{}";
			}
			
			TreeMap<String, Object> claims = new TreeMap<String, Object>();
			Map<URI, Object> allClaims = store.getAll();
			for (URI claimUri : allClaims.keySet()) {
				claims.put(claimUri.toString(), allClaims.get(claimUri));
			}
			
			JSONObject jsonObj = new JSONObject(claims);
			return jsonObj.toJSONString();
		}
%>
<%	
	if ("json".equals(request.getParameter("format"))) {
		out.println(serializeClaimStore());
		out.flush();
		out.close();
		return;
	}
%>
<html>
    <head>
        <title>Ambient Data Claim Store</title>

        <link rel="stylesheet" type="text/css" href="http://tridionpractice.github.io/tridion-practice/stylesheets/AmbientDataFramework/ClaimStore.css"></link>
		
		<script src="http://ajax.aspnetcdn.com/ajax/jQuery/jquery-2.1.4.min.js"></script>
		<script src="http://ajax.aspnetcdn.com/ajax/knockout/knockout-3.3.0.js"></script>
		<script src="http://tridionpractice.github.io/tridion-practice/javascripts/AmbientDataFramework/Knockout-LocalStorage.js"></script>
		<script src="http://tridionpractice.github.io/tridion-practice/javascripts/AmbientDataFramework/ClaimModel.js"></script>
		<script src="http://tridionpractice.github.io/tridion-practice/javascripts/AmbientDataFramework/ClaimsViewModel.js"></script>
    </head>
    <body>
		<div class='section'>
			<div class="topBar">
				Filter: <input type="text" placeholder="Enter search term" data-bind="textInput: filter" />
			</div>
			<div class="refreshArea">
				<span data-bind="visible: loading">Loading...</span>
				<button class="refreshButton" data-bind="click: refresh, visible:!autoRefresh()">Refresh</button>
				<input id="chkAutoRefresh" type="checkbox" data-bind="checked: autoRefresh"><label for="chkAutoRefresh">Refresh automatically</label></input>
			</div>
			<table>
				<thead>
					<th>Name</th>
					<th>Value</th>
				</thead>
				<tbody data-bind="foreach: claims">
					<tr>
						<td data-bind="text: key"></td>
						<!-- ko if: (nestedValues.length == 0) -->
						<td data-bind="text: value"></td>
						<!-- /ko -->							
						<!-- ko if: (nestedValues.length > 0) -->
						<td>
							<ul data-bind="foreach: { data: nestedValues, as: 'entry'}">
								<li>
									<span data-bind="text: entry.key"></span><!-- ko if: entry.value -->: <span data-bind="text: entry.value"></span><!-- /ko -->
								</li>
							</ul>
						</td>
						<!-- /ko -->
					</tr>
				</tbody>
			</table>
		</div>
    </body>
</html>
<!---
LICENSE INFORMATION:

Copyright 2008, Adam Tuttle

Licensed under the Apache License, Version 2.0 (the "License"); you may not
use this file except in compliance with the License.

You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.

VERSION INFORMATION:

This file is part of SweetTweets.
http://sweettweets.riaforge.org/
--->
<cfoutput>

	<!--- maximum number of tweets to show initially --->
	<cfset local.limit = getPref("tweetLimit") />

	<cfif getPref("useAjax") eq true>
		<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.1/jquery.min.js"></script>

		<!--- initial url to load --->
		<cfset local.ajaxURL = "#variables.fullPluginAssetPath#/SweetTweets.cfc?method=getTweetbacksHTML&uri=#urlEncodedFormat(local.uri)#&limit=#local.limit#&headerEmpty=#getPref('headerEmpty')#&headerNonEmpty=#getPref('headerNonEmpty')#&returnFormat=plain"/>

		<!-- jQuery code to do the refreshing -->
		<script type="text/javascript">
			$(document).ready(function(){
				$.get('<cfoutput>#local.ajaxURL#</cfoutput>',{},function(data){
					//if data is returned in a WDDX packet (as it will be if the server is CF7), clean it up
					if (data.indexOf('<wddxPacket') > -1){
						data = data.replace("<wddxPacket version='1.0'><header/><data><string>", "");
						data = data.replace("</string></data></wddxPacket>", "");
						data = data.replace(/&gt\;/gi, ">");
						data = data.replace(/&lt\;/gi, "<");
					}
					$("##tweetbackContainer").html(data);
				});
			});
		</script>

		<!--- div that will hold our ajax content --->
		<div id="tweetbackContainer">#unEscape(getPref("loadingMsg"))#</div>
	<cfelse>
		#variables.SweetTweets.getTweetbacksHTML(local.uri, local.limit, getPref("headerEmpty"), getPref("headerNonEmpty"))#
	</cfif>
</cfoutput>

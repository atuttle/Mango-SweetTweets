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

This file is part of SweetTweets (1.4).
http://sweettweets.riaforge.org/
--->
<cfscript>
	//handle form post
	if (structKeyExists(variables.data.externalData, "apply")){
		
		//tweetlimit
		variables.tweetlimit = variables.data.externalData.limit;
		setPref("tweetlimit",variables.tweetlimit);

		//use ajax
		if (structKeyExists(variables.data.externalData, "useAjax")){
			variables.useAjax = true;
		}else{
			variables.useAjax = false;
		}
		setPref("useAjax", variables.useAjax);

		//loading message
		variables.loadingMsg = variables.data.externalData.loadingMsg;
		setPref("loadingMsg", htmlEditFormat(variables.loadingMsg));

		//indicate success
		data.message.setstatus("success");
		data.message.setType("settings");
		data.message.settext("SweetTweets Settings Updated");
	}
</cfscript>

<cfoutput>
	<form action="#cgi.script_name#">
		<input type="hidden" value="event" name="action" />
		<input type="hidden" value="showSweetTweetsSettings" name="event" />
		<input type="hidden" value="true" name="apply" />
		<input type="hidden" value="SweetTweets" name="selected" />
		
		<fieldset>
			<legend>Display preferences</legend>
			
			<label for="limit">Tweet Limit</label> (0 = Unlimited)
			<input type="text" size="5" name="limit" id="limit" value="#variables.tweetLimit#"/><br /><br />
			
			<input type="checkbox" name="useAjax" id="useAjax" value="true" <cfif variables.useAjax>checked="checked"</cfif>/>
			<label for="useAjax">Use AJAX</label><br />
	
			<label for="loadingMsg">Loading Message</label> (When using AJAX)<br />
			<textarea rows="5" cols="40" name="loadingMsg" id="loadingMsg">#variables.loadingMsg#</textarea>
	
		</fieldset>
		
	    <input type="submit" class="primaryAction" value="Submit"/>
	</form>
</cfoutput>
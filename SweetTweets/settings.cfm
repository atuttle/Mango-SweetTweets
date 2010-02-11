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

		//headers
		setPref("headerEmpty", variables.data.externalData.headerEmpty);
		setPref("headerNonEmpty", variables.data.externalData.headerNonEmpty);

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

			<p>
				<label for="limit">Tweet Limit</label> (1-50)
				<input type="text" size="5" name="limit" id="limit" value="#variables.tweetLimit#"/>
			</p>

			<p>
				<input type="checkbox" name="useAjax" id="useAjax" value="true" <cfif variables.useAjax>checked="checked"</cfif>/>
				<label for="useAjax">Use AJAX</label>
			</p>

			<p>
				<label for="loadingMsg">Loading Message</label> (When using AJAX loading)<br />
				<textarea rows="5" cols="40" name="loadingMsg" id="loadingMsg">#variables.loadingMsg#</textarea>
			</p>

			<p>
				<label for="headerEmpty">Header Text</label> (<strong>No</strong> tweetbacks found)<br/>
				<span class="hint">
					You should probably include a heading tag, such as the default: H3.
				</span>
				<input type="text" size="40" name="headerEmpty" id="headerEmpty" value="#getPref('headerEmpty')#" />
			</p>

			<p>
				<label for="headerNonEmpty">Header Text</label> (Tweetbacks Found)<br/>
				<span class="hint">
					The token "{count}" (optional) will be replaced with the number of tweetbacks found.<br/>
					You should probably include a heading tag, such as the default: H3.
				</span>
				<input type="text" size="40" name="headerNonEmpty" id="headerNonEmpty" value="#getPref('headerNonEmpty')#" />
			</p>

		</fieldset>

	    <input type="submit" class="primaryAction" value="Submit"/>
	</form>
</cfoutput>
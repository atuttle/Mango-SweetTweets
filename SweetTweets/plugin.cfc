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
<cfcomponent>

	<cfset variables.package = "com/tuttle/plugins/SweetTweets"/>
	<cfset variables.id = "" />
	<cfset variables.name = "SweetTweets" />
	<cfset variables.pluginAssetPath = ""/>

	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
		
		<cfset var blogid = arguments.mainManager.getBlog().getId() />
		<cfset variables.path = blogid & "/" & variables.package />
		<cfset variables.prefManager = arguments.preferences />
		<cfset variables.blogManager = arguments.mainManager />
		
		<!--- save plugin asset base path --->
		<cfset variables.pluginAssetPath = variables.blogManager.getBlog().getBasePath() & "/assets/plugins/" & variables.name />

		<!--- set setting defaults --->
		<cfset defaultSetting("tweetLimit",10)/>
		<cfset defaultSetting("loadingMsg","Loading Tweetbacks...")/>
		<cfset defaultSetting("useAjax",true)/>

		<!--- instantiate our worker object --->
		<cfset variables.sweetTweets = createObject("component","SweetTweets").init(true)/>
			
		<cfreturn this/>
	</cffunction>

	<cffunction name="getName" access="public" output="false" returntype="string">
		<cfreturn variables.name />
	</cffunction>
	<cffunction name="setName" access="public" output="false" returntype="void">
		<cfargument name="name" type="string" required="true" />
		<cfset variables.name = arguments.name />
		<cfreturn />
	</cffunction>
	<cffunction name="getId" access="public" output="false" returntype="any">
		<cfreturn variables.id />
	</cffunction>
	<cffunction name="setId" access="public" output="false" returntype="void">
		<cfargument name="id" type="any" required="true" />
		<cfset variables.id = arguments.id />
		<cfreturn />
	</cffunction>
	<cffunction name="setup" hint="This is run when a plugin is activated" access="public" output="false" returntype="any">
		<cfset copyAssets()/>
		<cfreturn "SweetTweets plugin activated. Would you like to <a href='generic_settings.cfm?event=showSweetTweetsSettings&owner=SweetTweets&selected=showSweetTweetsSettings'>configure it now?</a>"/>
	</cffunction>
	<cffunction name="unsetup" hint="This is run when a plugin is de-activated" access="public" output="false" returntype="any">
		<cfset clearAssets()/>
		<cfreturn "SweetTweets plugin de-activated"/>
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />
		<cfreturn />
	</cffunction>
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />
		<cfset var local = StructNew() />
		
		<cfif arguments.event.name eq "tweetbacks">
			<cfset local.uri = "http://" & 
					cgi.server_name & 
					variables.blogManager.getBlog().getBasePath() &
					arguments.event.getContextData().currentPost.getURL()
					/>
			<cfset local.tweets = variables.sweetTweets.getTweetbacks(local.uri, variables.prefmanager.get(variables.package,"tweetLimit"))/>
			<cflog application="false" file="SweetTweets" text="Tweetback count: #arrayLen(local.tweets)# returned for #local.uri#"/>
			
			<cfsavecontent variable="local.tweetbackHTML">
				<cfinclude template="tweetbacks.cfm"/>
			</cfsavecontent>
			<cfset arguments.event.setOutputData(local.tweetbackHTML)/>

		
		<cfelseif arguments.event.name eq "settingsNav">
			<!--- add settings link --->
				<cfset link = structnew() />
				<cfset link.owner = "SweetTweets">
				<cfset link.page = "settings" />
				<cfset link.title = "SweetTweets" />
				<cfset link.eventName = "showSweetTweetsSettings" />				
				<cfset arguments.event.addLink(link)>
		
		<cfelseif arguments.event.name eq "showSweetTweetsSettings">
			<cfset data = arguments.event.data />
			
			<cfsavecontent variable="local.settingsPage">
				<cfinclude template="settings.cfm">
			</cfsavecontent>

			<cfset data.message.setTitle("SweetTweets Settings") />
			<cfset data.message.setData(local.settingsPage) />
		
		</cfif>
		
		<cfreturn arguments.event />
	</cffunction>

	<cfscript>
		function defaultSetting(name,defVal){
			if (not variables.prefmanager.nodeExists(variables.package,name)){
				variables.prefmanager.put(variables.package,name,defVal);
				variables[name] = defVal;
			}else{
				variables[name] = variables.prefmanager.get(variables.package,name);
				//double check
				if (variables[name] eq ''){
					variables.prefmanager.put(variables.package,name,defVal);
					variables[name] = defVal;
				}
			}
		}
		function setPref(name,val){
			variables.prefmanager.put(variables.package,name,val);
			variables[name] = val;
		}
		function getPref(name){
			return variables.prefmanager.get(variables.package,name);
		}
		function unEscape(data){
			data = rereplaceNoCase(data,"&gt;",">","ALL");
			data = rereplaceNoCase(data,"&lt;","<","ALL");
			data = rereplaceNoCase(data,"&quot;","""","ALL");
			data = rereplaceNoCase(data,"&amp;","&","ALL");
			return(data);
		}
	</cfscript>
	<cffunction name="copyAssets" access="private" output="false" returntype="void"
		hint="I'm used during plugin activation to copy files to a public location">
		<!--- copy assets to correct public folder --->
		<cfset var local = structNew()/>
		<cfset local.src = getCurrentTemplatePath() />
		<cfset local.src = listAppend(listDeleteAt(local.src, listLen(local.src, "\/"), "\/"), "assets", "/")/>
		<cfset local.dest = expandPath(variables.pluginAssetPath)/>
		<!--- create the destination folder if it doesn't exist --->
		<cfif not directoryExists(local.dest)>
			<cfdirectory action="create" directory="#local.dest#"/>
		</cfif>
		<!--- copy our assets to the root/assets/plugins/RelatedEntries folder so that they are web-accessible --->
		<cfdirectory action="list" directory="#local.src#" name="local.assets"/>
		<cfloop query="local.assets">
			<cffile action="copy" source="#local.assets.directory#/#local.assets.name#"
				destination="#local.dest#/#local.assets.name#"/>
		</cfloop>
	</cffunction>
	<cffunction name="clearAssets" access="private" output="false" returntype="void"
		hint="I'm used during plugin de-activation to remove public files">
		<cfset var local = StructNew()/>
		<cfset local.dir = expandPath(variables.pluginAssetPath)/>
		<!--- delete assets --->
		<cfdirectory action="delete" directory="#local.dir#" recurse="yes"/>
	</cffunction>

</cfcomponent>
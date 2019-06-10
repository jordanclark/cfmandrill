component {

	function init(
		required string apiKey
	,	string subaccount= ""
	,	string spoolDir= "ram:///mandrill"
	,	boolean compress= false
	,	string defaultFrom= ""
	,	string defaultReplyTo= ""
	,	string defaultBCC= ""
	,	numeric httpTimeOut= 120
	,	boolean stripQueryString= true
	,	boolean debug= ( request.debug ?: false )
	) {
		this.apiUrl= "https://mandrillapp.com/api/1.0/";
		this.subaccount= arguments.subaccount;
		this.apiKey= arguments.apiKey;
		this.spoolDir= arguments.spoolDir;
		this.compress= arguments.compress;
		this.debug= arguments.debug;
		this.defaultFrom= arguments.defaultFrom;
		this.defaultReplyTo= arguments.defaultReplyTo;
		this.defaultBCC= arguments.defaultBCC;
		this.httpTimeOut= arguments.httpTimeOut;
		this.stripQueryString= arguments.stripQueryString;
		if ( len( arguments.spoolDir ) && !directoryExists( arguments.spoolDir ) ) {
			directoryCreate( arguments.spoolDir );
		}
		this.blankMail= {
			to= ""
		,	bcc= arguments.defaultBCC
		,	from= arguments.defaultFrom
		,	replyTo= arguments.defaultReplyTo
		,	subject= ""
		,	htmlBody= ""
		,	textBody= ""
		,	tag= ""
		,	options= ""
		};
		return this;
	}

	function debugLog( required input ) {
		if ( structKeyExists( request, "log" ) && isCustomFunction( request.log ) ) {
			if ( isSimpleValue( arguments.input ) ) {
				request.log( "Mandrill: " & arguments.input );
			} else {
				request.log( "Mandrill: (complex type)" );
				request.log( arguments.input );
			}
		} else if( this.debug ) {
			cftrace( text=( isSimpleValue( arguments.input ) ? arguments.input : "" ), var=arguments.input, category="Mandrill", type="information" );
		}
		return;
	}

	string function htmlCompressFormat(required string html) {
		return reReplace( arguments.html, "[[:space:]]{2,}", chr( 13 ), "all" );
	}
	
	// ---------------------------------------------------------------------------------------------------------- 
	// USERS CALLS 
	// ---------------------------------------------------------------------------------------------------------- 

	/**
	 * Ping test
	 */
	function ping() {
		var out= this.apiRequest( "users/ping2.json" );
		return out;
	}

	/**
	 * User Info
	 */
	function user() {
		var out= this.apiRequest( "users/info.json" );
		return out;
	}

	/**
	 * User Info
	 */
	function userSenders() {
		var out= this.apiRequest( "users/senders.json" );
		return out;
	}

	// ---------------------------------------------------------------------------------------------------------- 
	// TAGS CALLS 
	// ---------------------------------------------------------------------------------------------------------- 

	/**
	 * Return all of the user-defined tag information
	 */
	function tags() {
		var out= this.apiRequest( "tags/list.json" );
		return out;
	}

	/**
	 * Return the recent history (hourly stats for the last 30 days) for all tags
	 */
	function tagsStats() {
		var out= this.apiRequest( "tags/all-time-series.json" );
		return out;
	}

	/**
	 * Return more detailed information about a single tag, including aggregates of recent stats
	 */
	function tag( required string tag ) {
		var out= this.apiRequest( "tags/info.json", { "tag"= arguments.tag } );
		return out;
	}

	/**
	 * Return the recent history (hourly stats for the last 30 days) for a tag
	 */
	function tagStats( required string tag ) {
		var out= this.apiRequest( "tags/time-series.json", { "tag"= arguments.tag } );
		return out;
	}

	// ---------------------------------------------------------------------------------------------------------- 
	// REJECTS CALLS 
	// ---------------------------------------------------------------------------------------------------------- 

	/**
	 * Retrieves your email rejection blacklist. Returns up to 1000 results. Reasons: hard-bounce, soft-bounce, spam, unsub
	 */
	function rejects() {
		var out= this.apiRequest( "rejects/list.json" );
		return out;
	}

	/**
	 * Retrieves your email rejection blacklist for an email address
	 */
	function reject( required string email ) {
		var out= this.apiRequest( "rejects/list.json", { "email"= arguments.email } );
		return out;
	}

	/**
	 * Adds an email to your email rejection blacklist.
	 */
	function rejectAdd( required string email, string comment= "" ) {
		var out= this.apiRequest( "rejects/add.json", { "email"= arguments.email, "comment"= arguments.comment } );
		return out;
	}

	/**
	 * Deletes an email rejection. There is no limit to how many rejections you can remove from your blacklist, but keep in mind that each deletion has an affect on your reputation.
	 */
	function rejectDelete( required string email ) {
		var out= this.apiRequest( "rejects/delete.json", { "email"= arguments.email } );
		return out;
	}

	// ---------------------------------------------------------------------------------------------------------- 
	// WHITELIST CALLS 
	// ---------------------------------------------------------------------------------------------------------- 

	/**
	 * Retrieves your email rejection whitelist. You can provide an email address or search prefix to limit the results. Returns up to 1000 results.
	 */
	function whitelists() {
		var out= this.apiRequest( "whitelists/list.json" );
		return out;
	}

	/**
	 * Retrieves your email whitelist for an email address
	 */
	function whitelist( required string email ) {
		var out= this.apiRequest( "whitelists/list.json", { "email"= arguments.email } );
		return out;
	}

	/**
	 * Adds an email to your email whitelist.
	 */
	function whitelistAdd( required string email, string comment= "" ) {
		var out= this.apiRequest( "whitelists/add.json", { "email"= arguments.email, "comment"= arguments.comment } );
		return out;
	}

	/**
	 * Removes an email address from the whitelist.
	 */
	function whitelistDelete( required string email ) {
		var out= this.apiRequest( "whitelists/delete.json", { "email"= arguments.email } );
		return out;
	}

	// ---------------------------------------------------------------------------------------------------------- 
	// SENDERS CALLS 
	// ---------------------------------------------------------------------------------------------------------- 

	/**
	 * Return the senders that have tried to use this account
	 */
	function senders() {
		var out= this.apiRequest( "senders/list.json" );
		return out;
	}

	/**
	 * Returns the sender domains that have been added to this account
	 */
	function domains() {
		var out= this.apiRequest( "senders/domains.json" );
		return out;
	}

	/**
	 * Return more detailed information about a single sender, including aggregates of recent stats
	 */
	function sender( required string email ) {
		var out= this.apiRequest( "senders/info.json", { "address"= arguments.email } );
		return out;
	}

	/**
	 * Return the recent history (hourly stats for the last 30 days) for a sender
	 */
	function senderStats( required string email ) {
		var out= this.apiRequest( "senders/time-series.json", { "address"= arguments.email } );
		return out;
	}

	// ---------------------------------------------------------------------------------------------------------- 
	// URLS CALLS 
	// ---------------------------------------------------------------------------------------------------------- 

	/**
	 * Get the 100 most clicked URLs
	 */
	function urls() {
		var out= this.apiRequest( "urls/list.json" );
		return out;
	}

	/**
	 * Return the 100 most clicked URLs that match the search query given
	 */
	function urlSearch( required string url ) {
		var out= this.apiRequest( "urls/list.json", { "q"= arguments.url } );
		return out;
	}

	/**
	 * Return the recent history (hourly stats for the last 30 days) for a url
	 */
	function urlStats( required string url ) {
		var out= this.apiRequest( "urls/time-series.json", { "q"= arguments.url } );
		return out;
	}

	// ---------------------------------------------------------------------------------------------------------- 
	// WEBHOOKS CALLS 
	// ---------------------------------------------------------------------------------------------------------- 

	/**
	 * Get the list of all webhooks defined on the account
	 */
	function webhooks() {
		var out= this.apiRequest( "webhooks/list.json" );
		return out;
	}

	/**
	 * Given the ID of an existing webhook, return the data about it
	 */
	function webhook( required numeric id ) {
		var out= this.apiRequest( "webhooks/info.json", { "q"= arguments.id } );
		return out;
	}

	/**
	 * Add a new webhook
	 */
	function webhookAdd( required string url, required string events ) {
		if ( isSimpleValue( arguments.events ) ) {
			arguments.events= listToArray( arguments.events, "," );
		}
		var out= this.apiRequest( "webhooks/add.json", {
			"url"= arguments.url
		,	"events"= arguments.events
		} );
		return out;
	}

	/**
	 * Add a new webhook
	 */
	function webhookUpdate( required numeric id, required string url, required string events ) {
		if ( isSimpleValue( arguments.events ) ) {
			arguments.events= listToArray( arguments.events, "," );
		}
		var out= this.apiRequest( "webhooks/update.json", {
			"id"= arguments.id
		,	"url"= arguments.url
		,	"events"= arguments.events
		} );
		return out;
	}

	/**
	 * Add a new webhook
	 */
	function webhookDelete( required numeric id ) {
		var out= this.apiRequest( "webhooks/delete.json", { "id"= arguments.id } );
		return out;
	}

	// ---------------------------------------------------------------------------------------------------------- 
	// INBOUND CALLS 
	// ---------------------------------------------------------------------------------------------------------- 

	/**
	 * List all routes
	 */
	function routes( required numeric domain ) {
		var out= this.apiRequest( "inbound/routes.json", { "domain"= arguments.domain } );
		return out;
	}

	// ---------------------------------------------------------------------------------------------------------- 
	// MESSAGES CALLS 
	// ---------------------------------------------------------------------------------------------------------- 

	struct function getBlankMail() {
		var mail= duplicate( this.blankMail );
		structAppend( mail, arguments, true );
		return mail;
	}

	/*
	 * mail structure
	 * - subject
	 * - htmlBody
	 * - textBody
	 * - from
	 * - replyTo
	 * - to (semicolon delimited list)
	 * - bcc (semicolon delimited list)
	 * - tag (semicolon delimited list)
	 * - options (list values: track-open,track-click,auto-text)
	 * - metadata
	 * - mergeVars
	 * - globalVars
	 * - attachments
	 * - gaDomains
	 * - gaCampaign
	 */	
	struct function sendMail( required struct mail, boolean spool= false, string send= true ) {
		var to= "";
		var out= {
			success= false
		};
		var args= {
			"key"= this.apiKey
		,	"message"= {
				"html"= arguments.mail.htmlBody
			,	"text"= arguments.mail.textBody
			,	"subject"= arguments.mail.subject
			,	"to"= []
			,	"url_strip_qs"= true
			,	"preserve_recipients"= false
			}
		};
		if ( find( "<", arguments.mail.from ) ) {
			args[ "message" ][ "from_email" ]= listGetAt( arguments.mail.from, 2, "<>" );
			args[ "message" ][ "from_name" ]= trim( listGetAt( arguments.mail.from, 1, "<>" ) );
		} else {
			args[ "message" ][ "from_email" ]= arguments.mail.from;
		}
		for ( to in listToArray( arguments.mail.to, ";" ) ) {
			if ( find( "<", to ) ) {
				arrayAppend( args[ "message" ][ "to" ], {
					"email"= listGetAt( to, 2, "<>" )
				,	"name"= trim( listGetAt( to, 1, "<>" ) )
				,	"type"= "to"
				});
			} else {
				arrayAppend( args[ "message" ][ "to" ], {
					"email"= to
				,	"type"= "to"
				});
			}
		}
		if ( structKeyExists( arguments.mail, "bcc" ) ) {
			for ( to in listToArray( arguments.mail.bcc, ";" ) ) {
				if ( find( "<", to ) ) {
					arrayAppend( args[ "message" ][ "to" ], {
						"email"= listGetAt( to, 2, "<>" )
					,	"name"= trim( listGetAt( to, 1, "<>" ) )
					,	"type"= "bcc"
					});
				} else {
					arrayAppend( args[ "message" ][ "to" ], {
						"email"= to
					,	"type"= "bcc"
					});
				}
			}
		}
		if ( structKeyExists( arguments.mail, "tag" ) ) {
			args[ "message" ][ "tags" ]= listToArray( arguments.mail.tag, ";" );
		}
		if ( structKeyExists( arguments.mail, "replyTo" ) ) {
			args[ "message" ][ "headers" ]= { "Reply-To"= arguments.mail.replyTo };
		}
		if ( structKeyExists( arguments.mail, "options" ) ) {
			if ( listFindNoCase( arguments.mail.options, "track-open" ) ) {
				args[ "message" ][ "track_opens" ]= true;
			}
			if ( listFindNoCase( arguments.mail.options, "track-click" ) ) {
				args[ "message" ][ "track_clicks" ]= true;
			}
			if ( listFindNoCase( arguments.mail.options, "auto-text" ) ) {
				args[ "message" ][ "auto_text" ]= true;
			}
			args[ "message" ][ "url_strip_qs" ]= this.stripQueryString;
		}
		if ( structKeyExists( arguments.mail, "metadata" ) ) {
			args[ "message" ][ "metadata" ]= arguments.mail.metadata;
		}
		if ( structKeyExists( arguments.mail, "mergeVars" ) ) {
			args[ "message" ][ "merge_vars" ]= arguments.mail.mergeVars;
		}
		if ( structKeyExists( arguments.mail, "globalVars" ) ) {
			args[ "message" ][ "global_merge_vars" ]= arguments.mail.globalVars;
		}
		if ( structKeyExists( arguments.mail, "attachments" ) ) {
			args[ "message" ][ "attachments" ]= arguments.mail.attachments;
		}
		if ( structKeyExists( arguments.mail, "gaDomains" ) ) {
			args[ "message" ][ "google_analytics_domains" ]= listToArray( arguments.mail.gaDomains, ";" );
		}
		if ( structKeyExists( arguments.mail, "gaCampaign" ) ) {
			args[ "message" ][ "google_analytics_domains" ]= arguments.mail.gaCampaign;
		}
		if ( this.compress ) {
			args[ "message" ][ "html" ]= this.htmlCompressFormat( args[ "message" ][ "html" ], 2 );
		}
		this.debugLog( "!!Send mail with mandrill to #arguments.mail.to#" );
		this.debugLog( args );
		if ( arguments.send ) {
			if ( !arguments.spool ) {
				out= this.apiRequest( "messages/send.json", args );
				if ( !out.success ) {
					arguments.spool= true;
				}
			}
			if ( arguments.spool && len( this.spoolDir ) ) {
				var fn= "#this.spoolDir#/send_#getTickCount()#_#randRange( 1, 10000 )#.json";
				fileWrite( fn, serializeJSON( args ) );
				this.debugLog( "Spooled mail to #fn#" );
				out.success= true;
			}
		}
		out.mandrill= args;
		out.mail= arguments.mail;
		return out;
	}

	struct function processSpool( numeric threads= 1 ) {
		var json= "";
		var out= {};
		if( !len( this.spoolDir ) ) {
			return out;
		}
		var aMail= directoryList( this.spoolDir, false, "path", "*.json", "DateLastModified", "file" );
		// lucee multithreading
		if( structKeyExists( server, "lucee" ) ) {
			arrayEach( aMail, function( fn ) {
				out[ fn ]= "";
				lock type="exclusive" name="mandrill_#fn#" timeout="0" {
					if ( fileExists( fn ) ) {
						json= fileRead( fn );
						if ( len( json ) ) {
							var send= this.apiRequest( "messages/send.json", json );
							out[ fn ]= ( send.success ? "sent" : "error:" & send.error );
							if( send.success ) {
								fileDelete( fn );
							}
						} else {
							out[ fn ]= "error: empty json file";
						}
					} else {
						out[ fn ]= "error: file #fn# is missing";
					}
				}
			}, ( arguments.threads > 1 ), arguments.threads );
		} else {
			arrayEach( aMail, function( fn ) {
				out[ file ]= "";
				lock type="exclusive" name="mandrill_#fn#" timeout="0" {
					if ( fileExists( fn ) ) {
						json= fileRead( fn );
						if ( len( json ) ) {
							var send= this.apiRequest( "messages/send.json", json );
							out[ fn ]= ( send.success ? "sent" : "error:" & send.error );
							if( send.success ) {
								fileDelete( fn );
							}
						} else {
							out[ fn ]= "error: empty json file";
						}
					} else {
						out[ fn ]= "error: file #fn# is missing";
					}
				}
			} );
		}
		return out;
	}

	struct function apiRequest( required string uri, json= {} ) {
		var http= {};
		var item= "";
		var out= {
			url= this.apiUrl&arguments.uri
		,	success= false
		,	error= ""
		,	status= ""
		,	statusCode= 0
		,	response= ""
		};
		this.debugLog( "mandrill: #out.url#" );
		if ( this.debug ) {
			this.debugLog( arguments.json );
			this.debugLog( out );
		}
		if ( isStruct( arguments.json ) ) {
			if ( !structKeyExists( arguments.json, "key" ) ) {
				arguments.json[ "key" ]= this.apiKey;
			}
			if ( !structKeyExists( arguments.json, "subaccount" ) && len( this.subaccount ) ) {
				arguments.json[ "subaccount" ]= this.subaccount;
			}
			arguments.json= serializeJSON( arguments.json );
		}
		cfhttp( result="http", method="POST", url=out.url, charset="utf-8", throwOnError=false, timeOut=this.httpTimeOut ) {
			// cfhttpparam( type="header", name="Accept", value="application/json" );
			// cfhttpparam( type="header", name="Content-Type", value="application/json" );
			cfhttpparam( type="body", value=arguments.json );
		}
		out.response= toString( http.fileContent );
		// this.debugLog( out.response );
		// this.debugLog( http );
		out.statusCode = http.responseHeader.Status_Code ?: 500;
		this.debugLog( out.statusCode );
		if ( len( out.error ) ) {
			out.success= false;
		} else if ( out.statusCode == "401" ) {
			out.error= "401 unauthorized";
		} else if ( out.statusCode == "422" ) {
			out.error= "422 unprocessable";
		} else if ( out.statusCode == "500" ) {
			out.error= "500 server error";
		} else if ( listFind( "4,5", left( out.statusCode, 1 ) ) ) {
			out.error= "#out.statusCode# unknown error";
		} else if ( out.statusCode == "" ) {
			out.error= "unknown error, no status code";
		} else if ( out.response == "Connection Timeout" || out.response == "Connection Failure" ) {
			out.error= out.response;
		} else if ( out.statusCode != "200" ) {
			out.error= "Non-200 http response code";
		} else {
			// out.success 
			out.success= true;
		}
		// parse response 
		if ( out.success ) {
			try {
				if ( left( http.responseHeader[ "Content-Type" ], 16 ) == "application/json" ) {
					out.response= deserializeJSON( out.response );
				} else {
					out.error= "Invalid response type: " & http.responseHeader[ "Content-Type" ];
				}
			} catch (any cfcatch) {
				out.error= "JSON Error: " & cfcatch.message & " " & cfcatch.detail;
			}
		}
		if ( len( out.error ) ) {
			out.success= false;
		}
		return out;
	}

}

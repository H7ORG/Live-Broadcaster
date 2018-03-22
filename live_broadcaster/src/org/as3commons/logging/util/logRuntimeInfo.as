/**
 * 
 */
package org.as3commons.logging.util {
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	
	
	/**
	 * Logs as much informations about the current runtime as it can get.
	 * 
	 * @param stage State to take the information that should be displayed.
	 * @param base DisplayObject to be used for scriptVersion and actionScriptVersion evaluation
	 * @author Martin Heidegger
	 * @since 2.5
	 * @version 2.0
	 */
	public function logRuntimeInfo(stage:Stage,base:DisplayObject=null): void {
		if( LOGGER.infoEnabled ) {
			SWFInfo.init(stage);
			if(!base) {
				base = stage.getChildAt(0);
			}
			try {
				log(stage, base);
			} catch(e:Error) {
				// The information about the compiled swf version is not
				// available before the root is instantiated.
				base.loaderInfo.addEventListener( Event.INIT, function(e:Event):void {
					log(stage, base);
				});
			}
		}
	}
}
import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.getLogger;
import org.as3commons.logging.util.GMT;
import org.as3commons.logging.util.IS_DEBUGGER;
import org.as3commons.logging.util.SWF_URL;

import flash.display.DisplayObject;
import flash.display.Stage;
import flash.system.Capabilities;

const LOGGER: ILogger = getLogger("org.as3commons.logging.util/logRuntimeInfo");

function log(stage:Stage, root:DisplayObject):void {
	if( LOGGER.infoEnabled ) {
		LOGGER.info(
			 "\n\tPlayer Version: " + Capabilities.version + " - " + Capabilities.playerType + ( IS_DEBUGGER ? "(debug)" : "" )
			+ "\n\t" + Capabilities.cpuArchitecture + " CPU architecture on OS: " + Capabilities.os
			+ "\n\tSWF path: " + SWF_URL + " (" + root.loaderInfo.bytesTotal  + " bytes, swf-version: " + root.loaderInfo.swfVersion + ", as" + root.loaderInfo.actionScriptVersion + ")"
			+ "\n\tContent Type: " + root.loaderInfo.contentType
			+ "\n\tStage: " + stage.stageWidth + "x" + stage.stageHeight + "@" + stage.frameRate + "fps  in state:" + stage.displayState
			+ "\n\tDisplay: " + Capabilities.screenResolutionX + "x" + Capabilities.screenResolutionY + "@" + Capabilities.screenColor
			+ "\n\tSupport: 32bit | 64bit | Accessability | IME | AudioEncoder | VideoEncoder | AV hardware disable"
			+ "\n\t         {0}   | {1}   | {2}           | {3} | {4}          | {5}          | {6} "
			+ "\n\tLocale: " + Capabilities.language + " in " + GMT
			+ "\n\tTouchscreen: " + getProp( Capabilities, "touchscreenType"),
			[
				check( Capabilities, "supports32BitProcesses" ),
				check( Capabilities, "supports64BitProcesses" ),
				check( Capabilities, "hasAccessibility"),
				check( Capabilities, "hasIME"),
				check( Capabilities, "hasAudioEncoder" ),
				check( Capabilities, "hasVideoEncoder" ),
				check( Capabilities, "avHardwareDisable" )
			]
		);
	}
}

function check( obj: Object, property: String ): String {
	return getProp( obj, property ) ? "yes": "no ";
}

function getProp( obj:Object, property: String ): * {
	if( obj.hasOwnProperty(property) ) {
		return obj[property];
	}
	return null;
}
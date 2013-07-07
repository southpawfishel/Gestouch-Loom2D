package org.gestouch.core
{
	/**
	 * @author Pavel fljot
	 */
	final public class GestureState
	{
		public static const POSSIBLE:GestureState = new GestureState("POSSIBLE");
		public static const RECOGNIZED:GestureState = new GestureState("RECOGNIZED", true);
		public static const BEGAN:GestureState = new GestureState("BEGAN");
		public static const CHANGED:GestureState = new GestureState("CHANGED");
		public static const ENDED:GestureState = new GestureState("ENDED", true);
		public static const CANCELLED:GestureState = new GestureState("CANCELLED", true);
		public static const FAILED:GestureState = new GestureState("FAILED", true);
		
		private static var allStatesInitialized:Boolean;
		
		
		private var name:String;
		private var eventType:String;
		private var validTransitionStateMap:Dictionary.<GestureState, Object> = new Dictionary.<GestureState, Object>();
		
		public static function GestureState()
		{
			_initClass();
		}
		
		
		public function GestureState(name:String, isEndState:Boolean = false)
		{
			if (allStatesInitialized)
			{
				throw new IllegalOperationError("You cannot create gesture states." +
				"Use predefined constats like GestureState.RECOGNIZED");
			}
			
			this.name = "GestureState." + name;
			this.eventType = "gesture" + name.charAt(0).toUpperCase() + name.substr(1).toLowerCase();
			this._isEndState = isEndState;
		}
		
		
		private static function _initClass():void
		{
			POSSIBLE.setValidNextStates(RECOGNIZED, BEGAN, FAILED);
			RECOGNIZED.setValidNextStates(POSSIBLE);
			BEGAN.setValidNextStates(CHANGED, ENDED, CANCELLED);
			CHANGED.setValidNextStates(CHANGED, ENDED, CANCELLED);
			ENDED.setValidNextStates(POSSIBLE);
			FAILED.setValidNextStates(POSSIBLE);
			CANCELLED.setValidNextStates(POSSIBLE);
			
			allStatesInitialized = true;
		}
		
		
		public function toString():String
		{
			return name;
		}
		
		
		private function setValidNextStates(...states):void
		{
			for each (var state in states)
			{
				validTransitionStateMap[state as GestureState] = true;
			}
		}
		
		
		public function gestouch_internal_toEventType():String
		{
			return eventType;
		}
		
		
		public function gestouch_internal_canTransitionTo(state:GestureState):Boolean
		{
			return (validTransitionStateMap[state] != null);
		}
		
		
		private var _isEndState:Boolean = false;
		public function get gestouch_internal_isEndState():Boolean
		{
			return _isEndState;
		}
	}
}

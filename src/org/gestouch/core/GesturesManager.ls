package org.gestouch.core
{
	import org.gestouch.gestures.Gesture;
	import org.gestouch.input.NativeInputAdapter;

	import loom2d.display.DisplayObject;
	import loom2d.display.Stage;
	import loom2d.events.Event;
	import loom2d.events.EventDispatcher;
	import loom2d.Loom2D;

	/**
	 * @author Pavel fljot
	 */
	public class GesturesManager
	{
		protected var _inputAdapters:Vector.<IInputAdapter> = new Vector.<IInputAdapter>();
		protected var _gesturesMap:Dictionary.<Gesture, Object> = new Dictionary.<Gesture, Object>(true);
		protected var _gesturesForTouchMap:Dictionary.<Touch, Vector.<Gesture>> = new Dictionary.<Touch, Vector.<Gesture>>();
		protected var _gesturesForTargetMap:Dictionary.<Object, Vector.<Gesture>> = new Dictionary.<Object, Vector.<Gesture>>(true);
		protected var _dirtyGesturesCount:uint = 0;
		protected var _dirtyGesturesMap:Dictionary.<Gesture, Object> = new Dictionary.<Gesture, Object>(true);
		protected var _stage:Stage;
		
		
		public function GesturesManager()
		{
			
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------
		
		protected function onStageAvailable(stage:Stage):void
		{
			_stage = stage;
			
			Gestouch.inputAdapter = Gestouch.inputAdapter ? Gestouch.inputAdapter : new NativeInputAdapter(stage);
		}
		
		
		protected function resetDirtyGestures():void
		{
			for (var gesture:Object in _dirtyGesturesMap)
			{
				(gesture as Gesture).reset();
			}
			_dirtyGesturesCount = 0;
			_dirtyGesturesMap = new Dictionary.<Gesture, Object>(true);
			Loom2D.stage.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		
		public function gestouch_internal_addGesture(gesture:Gesture):void
		{
			if (!gesture)
			{
				throw new ArgumentError("Argument 'gesture' must be not null.");
			}
			
			const target:Object = gesture.target;
			if (!target)
			{
				throw new IllegalOperationError("Gesture must have target.");
			}
			
			var targetGestures:Vector.<Gesture> = _gesturesForTargetMap[target] as Vector.<Gesture>;
			if (targetGestures)
			{
				if (targetGestures.indexOf(gesture) == -1)
				{
					targetGestures.push(gesture);
				}
			}
			else
			{
				targetGestures = _gesturesForTargetMap[target] = new Vector.<Gesture>();
				targetGestures.push(gesture);
			}
			
			
			_gesturesMap[gesture] = true;
			
			if (!_stage)
			{
				var targetAsDO:DisplayObject = target as DisplayObject;
				if (targetAsDO)
				{
					if (targetAsDO.stage)
					{
						onStageAvailable(targetAsDO.stage);
					}
					else
					{
						targetAsDO.addEventListener(Event.ADDED_TO_STAGE, gestureTarget_addedToStageHandler);
					}
				}
			}
		}
		
		
		public function gestouch_internal_removeGesture(gesture:Gesture):void
		{
			if (!gesture)
			{
				throw new ArgumentError("Argument 'gesture' must be not null.");
			}
			
			
			var target:Object = gesture.target;
			// check for target because it could be already GC-ed (since target reference is weak)
			if (target)
			{
				var targetGestures:Vector.<Gesture> = _gesturesForTargetMap[target] as Vector.<Gesture>;
				if (targetGestures.length > 1)
				{
					targetGestures.splice(targetGestures.indexOf(gesture), 1);
				}
				else
				{
					_gesturesForTargetMap.deleteKey(target);
					if (target is EventDispatcher)
					{
						(target as EventDispatcher).removeEventListener(Event.ADDED_TO_STAGE, gestureTarget_addedToStageHandler);
					}
				}
			}
			
			_gesturesMap.deleteKey(gesture);
			
			gesture.reset();
		}
		
		
		public function gestouch_internal_scheduleGestureStateReset(gesture:Gesture):void
		{
			if (!_dirtyGesturesMap[gesture])
			{
				_dirtyGesturesMap[gesture] = true;
				_dirtyGesturesCount++;
				Loom2D.stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
		}
		
		
		public function gestouch_internal_onGestureRecognized(gesture:Gesture):void
		{
			const target:Object = gesture.target;
			
			for (var key:Object in _gesturesMap)
			{
				var otherGesture:Gesture = key as Gesture;
				var otherTarget:Object = otherGesture.target;
				
				// conditions for otherGesture "own properties"
				if (otherGesture != gesture &&
					target && otherTarget &&//in case GC worked half way through
					otherGesture.enabled &&
					otherGesture.state == GestureState.POSSIBLE)
				{
					if (otherTarget == target ||
						gesture.gestouch_internal_targetAdapter.contains(otherTarget) ||
						otherGesture.gestouch_internal_targetAdapter.contains(target)
						)
					{
						// conditions for gestures relations
						if (gesture.gestouch_internal_canPreventGesture(otherGesture) &&
							otherGesture.gestouch_internal_canBePreventedByGesture(gesture) &&
							(gesture.gesturesShouldRecognizeSimultaneouslyCallback == null ||
							 gesture.gesturesShouldRecognizeSimultaneouslyCallback.call(gesture, otherGesture)) &&
							(otherGesture.gesturesShouldRecognizeSimultaneouslyCallback == null ||
							 otherGesture.gesturesShouldRecognizeSimultaneouslyCallback.call(otherGesture, gesture)))
						{
							otherGesture.gestouch_internal_setState_internal(GestureState.FAILED);
						}
					}
				}
			}
		}
		
		
		public function gestouch_internal_onTouchBegin(touch:Touch):void
		{
			var gesture:Gesture;
			var i:uint;
			
			// This vector will contain active gestures for specific touch during all touch session.
			var gesturesForTouch:Vector.<Gesture> = _gesturesForTouchMap[touch] as Vector.<Gesture>;
			if (!gesturesForTouch)
			{
				gesturesForTouch = new Vector.<Gesture>();
				_gesturesForTouchMap[touch] = gesturesForTouch;
			}
			else
			{
				// touch object may be pooled in the future
				gesturesForTouch.length = 0;
			}
			
			var target:Object = touch.target;
			const displayListAdapter:IDisplayListAdapter = Gestouch.gestouch_internal_getDisplayListAdapter(target);
			if (!displayListAdapter)
			{
				throw new Error("Display list adapter not found for target of type '" + target.getFullTypeName() + "'.");
			}
			const hierarchy:Vector.<Object> = displayListAdapter.getHierarchy(target);
			const hierarchyLength:uint = hierarchy.length;
			if (hierarchyLength == 0)
			{
				throw new Error("No hierarchy build for target '" + target +"'. Something is wrong with that IDisplayListAdapter.");
			}
			if (_stage && !(hierarchy[hierarchyLength - 1] is Stage))
			{
				// Looks like some non-native (non DisplayList) hierarchy
				// but we must always handle gestures with Stage target
				// since Stage is anyway the top-most parent
				hierarchy[hierarchyLength] = _stage;
			}
			
			// Create a sorted(!) list of gestures which are interested in this touch.
			// Sorting priority: deeper target has higher priority, recently added gesture has higher priority.
			var gesturesForTarget:Vector.<Gesture>;
			for each (var targetObject in hierarchy)
			{
				gesturesForTarget = _gesturesForTargetMap[targetObject] as Vector.<Gesture>;
				if (gesturesForTarget)
				{
					i = gesturesForTarget.length;
					while (i-- > 0)
					{
						gesture = gesturesForTarget[i];
						if (gesture.enabled &&
							(gesture.gestureShouldReceiveTouchCallback == null ||
							 gesture.gestureShouldReceiveTouchCallback.call(gesture, touch)))
						{
							//TODO: optimize performance! decide between unshift() vs [i++] = gesture + reverse()
							gesturesForTouch.unshift(gesture);
						}
					}
				}
			}
			
			// Then we populate them with this touch and event.
			// They might start tracking this touch or ignore it (via Gesture#ignoreTouch())
			i = gesturesForTouch.length;
			while (i-- > 0)
			{
				gesture = gesturesForTouch[i];
				// Check for state because previous (i+1) gesture may already abort current (i) one
				if (!_dirtyGesturesMap[gesture])
				{
					gesture.gestouch_internal_touchBeginHandler(touch);
				}
				else
				{
					gesturesForTouch.splice(i, 1);
				}
			}
		}
		
		
		public function gestouch_internal_onTouchMove(touch:Touch):void
		{
			var gesturesForTouch:Vector.<Gesture> = _gesturesForTouchMap[touch] as Vector.<Gesture>;
			var gesture:Gesture;
			var i:uint = gesturesForTouch.length;
			while (i-- > 0)
			{
				gesture = gesturesForTouch[i];
				
				if (!_dirtyGesturesMap[gesture] && gesture.isTrackingTouch(touch.id))
				{
					gesture.gestouch_internal_touchMoveHandler(touch);
				}
				else
				{
					// gesture is no more interested in this touch (e.g. ignoreTouch was called)
					gesturesForTouch.splice(i, 1);
				}
			}
		}
		
		
		public function gestouch_internal_onTouchEnd(touch:Touch):void
		{
			var gesturesForTouch:Vector.<Gesture> = _gesturesForTouchMap[touch] as Vector.<Gesture>;
			var gesture:Gesture;
			var i:uint = gesturesForTouch.length;
			while (i-- > 0)
			{
				gesture = gesturesForTouch[i];
				
				if (!_dirtyGesturesMap[gesture] && gesture.isTrackingTouch(touch.id))
				{
					gesture.gestouch_internal_touchEndHandler(touch);
				}
			}
			
			gesturesForTouch.length = 0;// release for GC
			
			_gesturesForTouchMap.deleteKey(touch);//TODO: remove this once Touch objects are pooled
		}
		
		
		public function gestouch_internal_onTouchCancel(touch:Touch):void
		{
			var gesturesForTouch:Vector.<Gesture> = _gesturesForTouchMap[touch] as Vector.<Gesture>;
			var gesture:Gesture;
			var i:uint = gesturesForTouch.length;
			while (i-- > 0)
			{
				gesture = gesturesForTouch[i];
				
				if (!_dirtyGesturesMap[gesture] && gesture.isTrackingTouch(touch.id))
				{
					gesture.gestouch_internal_touchCancelHandler(touch);
				}
			}
			
			gesturesForTouch.length = 0;// release for GC
			
			_gesturesForTouchMap.deleteKey(touch);//TODO: remove this once Touch objects are pooled
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		protected function gestureTarget_addedToStageHandler(event:Event):void
		{
			var target:DisplayObject = event.target as DisplayObject;
			target.removeEventListener(Event.ADDED_TO_STAGE, gestureTarget_addedToStageHandler);
			if (!_stage)
			{
				onStageAvailable(target.stage);
			}
		}
		
		
		private function enterFrameHandler(event:Event):void
		{
			resetDirtyGestures();
		}
	}
}
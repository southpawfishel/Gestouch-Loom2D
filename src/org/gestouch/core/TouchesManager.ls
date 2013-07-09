package org.gestouch.core
{
	import loom2d.display.Stage;
	import loom2d.math.Point;


	/**
	 * @author Pavel fljot
	 */
	public class TouchesManager
	{
		protected var _gesturesManager:GesturesManager;
		protected var _touchesMap:Dictionary.<uint, Touch> = {};
		protected var _hitTesters:Vector.<ITouchHitTester> = new Vector.<ITouchHitTester>();
		protected var _hitTesterPrioritiesMap:Dictionary.<ITouchHitTester, int> = new Dictionary.<ITouchHitTester, int>(true);
		
		
		public function TouchesManager(gesturesManager:GesturesManager)
		{
			_gesturesManager = gesturesManager;
		}
		
		
		protected var _activeTouchesCount:uint;
		public function get activeTouchesCount():uint
		{
			return _activeTouchesCount;
		}
		
		
		public function getTouches(target:Object = null):Vector.<Touch>
		{
			const touches:Vector.<Touch> = [];
			if (!target || target is Stage)
			{
				// return all touches
				var i:uint = 0;
				for each (var touch:Touch in _touchesMap)
				{
					touches[i++] = touch;
				}
			}
			else
			{
				//TODO
			}
			
			return touches;
		}
		
		
		public function gestouch_internal_addTouchHitTester(touchHitTester:ITouchHitTester, priority:int = 0):void
		{
			if (!touchHitTester)
			{
				throw new ArgumentError("Argument must be non null.");
			}
			
			if (_hitTesters.indexOf(touchHitTester) == -1)
			{
				_hitTesters.push(touchHitTester);
			}
			
			_hitTesterPrioritiesMap[touchHitTester] = priority;
			// Sort hit testers using their priorities
			_hitTesters.sort(hitTestersSorter);
		}
		
		
		public function gestouch_internal_removeInputAdapter(touchHitTester:ITouchHitTester):void
		{
			if (!touchHitTester)
			{
				throw new ArgumentError("Argument must be non null.");
			}
			
			var index:int = _hitTesters.indexOf(touchHitTester);
			if (index == -1)
			{
				throw new Error("This touchHitTester is not registered.");
			}
			
			_hitTesters.splice(index, 1);
			_hitTesterPrioritiesMap.deleteKey(touchHitTester);
		}
		
		
		public function gestouch_internal_onTouchBegin(touchID:uint, x:Number, y:Number, nativeTarget:Object = null):Boolean
		{			
			if (_touchesMap[touchID] != null)
				return false;// touch with specified ID is already registered and being tracked
			
			const location:Point = new Point(x, y);
			
			for each (var registeredTouch:Touch in _touchesMap)
			{
				// Check if touch at the same location exists.
				// In case we listen to both TouchEvents and MouseEvents, one of them will come first
				// (right now looks like MouseEvent dispatched first, but who know what Adobe will
				// do tomorrow). This check helps to filter out the one comes after.
				
				// NB! According to the tests with some IR multitouch frame and Windows computer
				// TouchEvent comes first, but the following MouseEvent has slightly offset location
				// (1px both axis). That is why Point#distance() used instead of Point#equals()
				
				if (Point.distance(registeredTouch.location, location) < 2)
					return false;
			}
			
			const touch:Touch = createTouch();
			touch.id = touchID;
			
			var target:Object;
			var altTarget:Object;
			for each (var hitTester:ITouchHitTester in _hitTesters)
			{
				target = hitTester.hitTest(location, nativeTarget);
				if (target)
				{
					if ((target is Stage))
					{
						// NB! Target is flash.display::Stage is a special case. If it is true, we want
						// to give a try to a lower-priority (Stage3D) hit-testers. 
						altTarget = target;
						continue;
					}
					else
					{
						// We found a target.
						break;
					}
				}
			}
			if (!target && !altTarget)
			{
				throw new Error("Not touch target found (hit test)." +
				"Something is wrong, at least flash.display::Stage should be found." +
				"See Gestouch#addTouchHitTester() and Gestouch#inputAdapter.");
			}
			
			touch.target = target != null ? target : altTarget;
			touch.gestouch_internal_setLocation(x, y, Platform.getTime());
			
			_touchesMap[touchID] = touch;
			_activeTouchesCount++;
			
			_gesturesManager.gestouch_internal_onTouchBegin(touch);
			
			return true;
		}
		
		
		public function gestouch_internal_onTouchMove(touchID:uint, x:Number, y:Number):void
		{
			const touch:Touch = _touchesMap[touchID] as Touch;
			if (!touch)
				return;// touch with specified ID isn't registered
			
			if (touch.gestouch_internal_updateLocation(x, y, Platform.getTime()))
			{
				// NB! It appeared that native TOUCH_MOVE event is dispatched also when
				// the location is the same, but size has changed. We are only interested
				// in location at the moment, so we shall ignore irrelevant calls.
				
				_gesturesManager.gestouch_internal_onTouchMove(touch);
			}
		}
		
		
		public function gestouch_internal_onTouchEnd(touchID:uint, x:Number, y:Number):void
		{
			const touch:Touch = _touchesMap[touchID] as Touch;
			if (!touch)
				return;// touch with specified ID isn't registered
			
			touch.gestouch_internal_updateLocation(x, y, Platform.getTime());
			
			_touchesMap.deleteKey(touchID);
			_activeTouchesCount--;
			
			_gesturesManager.gestouch_internal_onTouchEnd(touch);
			
			touch.target = null;
		}
		
		
		public function gestouch_internal_onTouchCancel(touchID:uint, x:Number, y:Number):void
		{
			const touch:Touch = _touchesMap[touchID] as Touch;
			if (!touch)
				return;// touch with specified ID isn't registered
			
			touch.gestouch_internal_updateLocation(x, y, Platform.getTime());
			
			_touchesMap.deleteKey(touchID);
			_activeTouchesCount--;
			
			_gesturesManager.gestouch_internal_onTouchCancel(touch);
			
			touch.target = null;
		}
		
		
		protected function createTouch():Touch
		{
			//TODO: pool
			return new Touch();
		}
		
		
		/**
		 * Sorts from higher priority to lower. Items with the same priority keep the order
		 * of addition, e.g.:
		 * add(a), add(b), add(c, -1), add(d, 1) will be ordered to
		 * d, a, b, c
		 */
		protected function hitTestersSorter(x:ITouchHitTester, y:ITouchHitTester):Number
		{
			const d:int = int(_hitTesterPrioritiesMap[x]) - int(_hitTesterPrioritiesMap[y]);
			if (d > 0)
				return -1;
			else if (d < 0)
				return 1;
			
			return _hitTesters.indexOf(x) > _hitTesters.indexOf(y) ? 1 : -1;
		}
	}
}

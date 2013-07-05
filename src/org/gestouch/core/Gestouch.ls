package org.gestouch.core
{
	import org.gestouch.extensions.loom2d.Loom2DDisplayListAdapter;
	import org.gestouch.extensions.loom2d.Loom2DTouchHitTester;

	import loom2d.display.DisplayObject;


	/**
	 * @author Pavel fljot
	 */
	final public class Gestouch
	{
		private static const _displayListAdaptersMap:Dictionary.<String, IDisplayListAdapter> = new Dictionary.<String, IDisplayListAdapter>();
		
		public static function Gestouch()
		{
			initClass();
		}
		
		
		/** @private */
		private static var _inputAdapter:IInputAdapter;
		
		/**
		 * 
		 */
		public static function get inputAdapter():IInputAdapter
		{
			return _inputAdapter;
		}
		public static function set inputAdapter(value:IInputAdapter):void
		{
			if (_inputAdapter == value)
				return;
			
			_inputAdapter = value;
			if (inputAdapter)
			{
				inputAdapter.touchesManager = touchesManager;
				inputAdapter.init();
			}
		}
		
		
		private static var _touchesManager:TouchesManager;
		/**
		 * 
		 */
		public static function get touchesManager():TouchesManager
		{
			if (!_touchesManager) _touchesManager = new TouchesManager(gesturesManager);
			return _touchesManager;
		}
		
		
		private static var _gesturesManager:GesturesManager;
		public static function get gesturesManager():GesturesManager
		{
			if (!_gesturesManager) _gesturesManager = new GesturesManager();
			return _gesturesManager;
		}
		
		
		public static function addDisplayListAdapter(targetClass:String, adapter:IDisplayListAdapter):void
		{
			if (!targetClass || !adapter)
			{
				throw new Error("Argument error: both arguments required.");
			}
			
			_displayListAdaptersMap[targetClass] = adapter;
		}
		
		
		public static function addTouchHitTester(hitTester:ITouchHitTester, priority:int = 0):void
		{
			touchesManager.gestouch_internal_addTouchHitTester(hitTester, priority);
		}
		
		
		public static function removeTouchHitTester(hitTester:ITouchHitTester):void
		{
			touchesManager.gestouch_internal_removeInputAdapter(hitTester);
		}
		
		
//		public static function getTouches(target:Object = null):Array
//		{
//			return touchesManager.getTouches(target);
//		}
		
		public static function gestouch_internal_createGestureTargetAdapter(target:Object):IDisplayListAdapter
		{
			const adapter:IDisplayListAdapter = Gestouch.gestouch_internal_getDisplayListAdapter(target);
			if (adapter)
			{
				if (adapter.reflect() == "Loom2DDisplayListAdapter")
				{
					return new Loom2DDisplayListAdapter(target as DisplayObject);
				}
				//return Type.getTypeByName(adapter.reflect()).getConstructor().invoke(target) as IDisplayListAdapter;
			}
			
			throw new Error("Cannot create adapter for target " + target + " of type " + target.getFullTypeName() + ".");
			return null;
		}
		
		
		public static function gestouch_internal_getDisplayListAdapter(object:Object):IDisplayListAdapter
		{
			for (var key:Object in _displayListAdaptersMap)
			{
				var targetClass:String = key as String;
				if (object == targetClass)
				{
					return _displayListAdaptersMap[key] as IDisplayListAdapter;
				}
			}
			
			return null;
		}
		
		
		private static function initClass():void
		{
			addTouchHitTester(new Loom2DTouchHitTester());
			addDisplayListAdapter("DisplayObject", new Loom2DDisplayListAdapter());
		}
	}
}

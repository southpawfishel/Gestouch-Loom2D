package org.gestouch.input
{
	import org.gestouch.core.IInputAdapter;
	import org.gestouch.core.TouchesManager;

	import Loom2D.Display.Stage;
	import Loom2D.Events.TouchEvent;


	/**
	 * @author Pavel fljot
	 */
	public class NativeInputAdapter implements IInputAdapter
	{
		protected var _stage:Stage;

		
		
		public function NativeInputAdapter(stage:Stage)
		{
			super();
			
			if (!stage)
			{
				throw new ArgumentError("Stage must be not null.");
			}
			
			_stage = stage;
		}
		
		
		protected var _touchesManager:TouchesManager;
		public function set touchesManager(value:TouchesManager):void
		{
			_touchesManager = value;
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		
		public function init():void
		{
			_stage.addEventListener(TouchEvent.TOUCH, touchHandler);
		}


		public function onDispose():void
		{
			_touchesManager = null;
			
			_stage.removeEventListener(TouchEvent.TOUCH, touchHandler);
		}

		
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		protected function touchHandler(event:TouchEvent):void
		{
            var beganTouches:Vector.<Touch> = event.getTouches(Loom2D.stage, TouchPhase.BEGAN);
            for each (var bt in beganTouches)
            {
                this.touchBeginHandler(bt);
            }

            var movedTouches:Vector.<Touch> = event.getTouches(Loom2D.stage, TouchPhase.MOVED);
            for each (var mt in movedTouches)
            {
                this.touchMoveHandler(mt);
            }

            var endedTouches:Vector.<Touch> = event.getTouches(Loom2D.stage, TouchPhase.ENDED);
            for each (var et in endedTouches)
            {
                this.touchEndHandler(et);
            }
		}
		
		protected function touchBeginHandler(touch:Touch):void
		{
			_touchesManager.gestouch_internal_onTouchBegin(touch.id, touch.globalX, touch.globalYY, touch.target);
		}
		
		
		protected function touchMoveHandler(touch:Touch):void
		{
			_touchesManager.gestouch_internal_onTouchMove(touch.id, touch.globalX, touch.globalYY, touch.target);
		}
		
		
		protected function touchEndHandler(touch:Touch):void
		{
			// TODO if Loom ever adds canceled touches
			// if (event.hasOwnProperty("isTouchPointCanceled") && event["isTouchPointCanceled"])
			// {
			// 	_touchesManager.gestouch_internal_onTouchCancel(event.touchPointID, event.stageX, event.stageY);
			// }
			// else
			{
				_touchesManager.gestouch_internal_onTouchEnd(touch.id, touch.globalX, touch.globalYY, touch.target);
			}
		}
	}
}

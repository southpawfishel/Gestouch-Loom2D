package org.gestouch.gestures
{
	import org.gestouch.core.GestureState;
	import org.gestouch.core.Touch;

	import loom.platform.Timer;


	/**
	 * 
	 * @author Pavel fljot
	 */
	public class TapGesture extends AbstractDiscreteGesture
	{
		public var numTouchesRequired:uint = 1;
		public var numTapsRequired:uint = 1;
		public var slop:Number = Gesture.DEFAULT_SLOP << 2;//iOS has 45px for 132 dpi screen
		public var maxTapDelay:uint = 400;
		public var maxTapDuration:uint = 1500;
		
		protected var _timer:Timer;
		protected var _numTouchesRequiredReached:Boolean;
		protected var _tapCounter:uint = 0;
		
		
		public function TapGesture(target:Object = null)
		{
			super(target);
		}
		
		
		
		
		// --------------------------------------------------------------------------
		//
		// Public methods
		//
		// --------------------------------------------------------------------------
		
		override public function reflect():String
		{
			return TapGesture.getTypeName();
		}
		
		
		override public function reset():void
		{
			_numTouchesRequiredReached = false;
			_tapCounter = 0;
			_timer.reset();
			
			super.reset();
		}
		
		
		override function gestouch_internal_canPreventGesture(preventedGesture:Gesture):Boolean
		{
			if (preventedGesture is TapGesture &&
				(preventedGesture as TapGesture).numTapsRequired > this.numTapsRequired)
			{
				return false;
			}
			return true;
		}
		
		
		
		
		// --------------------------------------------------------------------------
		//
		// Protected methods
		//
		// --------------------------------------------------------------------------
		
		override protected function preinit():void
		{
			super.preinit();
			
			_timer = new Timer(maxTapDelay);
			_timer.onComplete = timer_timerCompleteHandler;
		}
		
		
		override protected function onTouchBegin(touch:Touch):void
		{
			if (touchesCount > numTouchesRequired)
			{
				failOrIgnoreTouch(touch);
				return;
			}
			
			if (touchesCount == 1)
			{
				_timer.reset();
				_timer.delay = maxTapDuration;
				_timer.start();
			}
			
			if (touchesCount == numTouchesRequired)
			{
				_numTouchesRequiredReached = true;
				updateLocation();
			}
		}
		
		
		override protected function onTouchMove(touch:Touch):void
		{
			if (slop >= 0 && touch.locationOffset.length > slop)
			{
				setState(GestureState.FAILED);
			}
		}
		
		
		override protected function onTouchEnd(touch:Touch):void
		{
			if (!_numTouchesRequiredReached)
			{
				setState(GestureState.FAILED);
			}
			else if (touchesCount == 0)
			{
				// reset flag for the next "full press" cycle
				_numTouchesRequiredReached = false;
				
				_tapCounter++;
				_timer.reset();
				
				if (_tapCounter == numTapsRequired)
				{
					setState(GestureState.RECOGNIZED);
				}
				else
				{
					_timer.delay = maxTapDelay;
					_timer.start();
				}
			}
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		protected function timer_timerCompleteHandler(timer:Timer):void
		{
			if (state == GestureState.POSSIBLE)
			{
				setState(GestureState.FAILED);
			}
		}
	}
}
package org.gestouch.core
{
	import org.gestouch.utils.Point;


	/**
	 * @author Pavel fljot
	 */
	public interface ITouchHitTester
	{
		function hitTest(point:Point, nativeTarget:Object):Object;
	}
}

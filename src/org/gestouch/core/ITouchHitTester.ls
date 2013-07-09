package org.gestouch.core
{
	import loom2d.math.Point;


	/**
	 * @author Pavel fljot
	 */
	public interface ITouchHitTester
	{
		function hitTest(point:Point, nativeTarget:Object):Object;
	}
}

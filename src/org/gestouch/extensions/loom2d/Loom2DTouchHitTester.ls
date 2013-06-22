package org.gestouch.extensions.loom2d
{
	import loom2d.Loom2D;

	import org.gestouch.core.ITouchHitTester;

	import flash.geom.Point;


	/**
	 * @author Pavel fljot
	 */
	final public class Loom2DTouchHitTester implements ITouchHitTester
	{
		public function Loom2DTouchHitTester()
		{
		}
		
		
		public function hitTest(point:Point, nativeTarget:Object):Object
		{
			return Loom2D.stage.hitTest(point, true);
		}
	}
}

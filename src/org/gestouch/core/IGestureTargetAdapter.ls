package org.gestouch.core
{
	/**
	 * @author Pavel fljot
	 */
	public interface IGestureTargetAdapter
	{
		public function get target():Object;
		
		function contains(object:Object):Boolean;
	}
}
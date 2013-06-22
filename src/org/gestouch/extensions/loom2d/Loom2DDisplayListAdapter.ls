package org.gestouch.extensions.loom2d
{
	import loom2d.display.DisplayObject;
	import loom2d.display.DisplayObjectContainer;

	import org.gestouch.core.IDisplayListAdapter;


	/**
	 * @author Pavel fljot
	 */
	final public class Loom2DDisplayListAdapter implements IDisplayListAdapter
	{
		private var targetWeakStorage:Dictionary.<DisplayObject, Object>;
		
		
		public function StarlingDisplayListAdapter(target:DisplayObject = null)
		{
			if (target)
			{
				targetWeakStorage = new Dictionary.<DisplayObject, Object>(true);
				targetWeakStorage[target] = true;
			}
		}
		
		
		public function get target():Object
		{
			for (var key:Object in targetWeakStorage)
			{
				return key;
			}
			return null;
		}
		
		
		public function contains(object:Object):Boolean
		{
			const targetAsDOC:DisplayObjectContainer = this.target as DisplayObjectContainer;
			const objectAsDO:DisplayObject = object as DisplayObject;
			return (targetAsDOC && objectAsDO && targetAsDOC.contains(objectAsDO));
		}
		
		
		public function getHierarchy(genericTarget:Object):Vector.<Object>
		{
			var list:Vector.<Object> = new Vector.<Object>();
			var i:uint = 0;
			var target:DisplayObject = genericTarget as DisplayObject;
			while (target)
			{
				list[i] = target;
				target = target.parent;
				i++;
			}
			
			return list;
		}
		
		
		public function reflect():Class
		{
			return Loom2DDisplayListAdapter;
		}
	}
}
package
{
	import flash.events.Event;
	
	public class BestWayReady extends Event {
		public const BEST_WAY_READY:String = "bestWayReady";
		private var _way:Array;
		public function BestWayReady(way:Array) {
			super(BEST_WAY_READY, false, false);
			_way = way;
		}
		
		public function get way():Array {
			return _way;
		}
		override public function clone():Event {
			return new BestWayReady(_way);
		}
	}
}
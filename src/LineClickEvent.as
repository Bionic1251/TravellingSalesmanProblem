package {
	import flash.events.Event;

	public class LineClickEvent extends Event {
		public static const LINE_CLICKED:String = "lineClicked";
		private var _line:Line;

		public function LineClickEvent(type:String, line:Line) {
			super(type);
			_line = line;
		}

		public function get line():Line {
			return _line;
		}

		override public function clone():Event {
			return new LineClickEvent(type, _line);
		}
	}
}
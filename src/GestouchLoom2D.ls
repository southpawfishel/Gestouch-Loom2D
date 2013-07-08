package
{
    import loom.Application;
    import loom2d.display.Image;
    import loom2d.display.StageScaleMode;
    import loom2d.display.Quad;
    import loom2d.math.Point;
    import loom2d.textures.Texture;
    import loom2d.ui.SimpleLabel;

    import org.gestouch.events.GestureEvent;
    import org.gestouch.gestures.TapGesture;
    import org.gestouch.gestures.LongPressGesture;
    import org.gestouch.gestures.ZoomGesture;
    import org.gestouch.gestures.PanGesture;
    import org.gestouch.gestures.SwipeGesture;
    import org.gestouch.gestures.SwipeGestureDirection;
    import org.gestouch.gestures.RotateGesture;

    public class GestouchLoom2D extends Application
    {
        protected var sprite:Image = null;

        override public function run():void
        {
            super.run();

            // Comment out this line to turn off automatic scaling.
            stage.scaleMode = StageScaleMode.LETTERBOX;

            var bg = new Quad(stage.stageWidth, stage.stageHeight, 0xff0000);
            stage.addChild(bg);

            sprite = new Image(Texture.fromAsset("assets/logo.png"));
            sprite.pivotX = sprite.width / 2;
            sprite.pivotY = sprite.height / 2;
            sprite.x = 240;
            sprite.y = stage.stageHeight - 120;
            stage.addChild(sprite);

            var label = new SimpleLabel("assets/Curse-hd.fnt");
            label.text = "Hello Loom!";
            label.x = 240;
            label.y = stage.stageHeight - 240;
			label.center();
            stage.addChild(label);

            var doubleTap:TapGesture = new TapGesture(sprite);
            doubleTap.numTapsRequired = 2;
            doubleTap.addEventListener(GestureEvent.GESTURE_RECOGNIZED, onDoubleTap);

            var longPress:LongPressGesture = new LongPressGesture(sprite);
            longPress.addEventListener(GestureEvent.GESTURE_BEGAN, onLongPress);
            longPress.addEventListener(GestureEvent.GESTURE_CHANGED, onLongPress);
            longPress.addEventListener(GestureEvent.GESTURE_ENDED, onLongPress);

            var zoom = new ZoomGesture(stage);
            zoom.addEventListener(GestureEvent.GESTURE_BEGAN, onZoom);
            zoom.addEventListener(GestureEvent.GESTURE_CHANGED, onZoom);
            zoom.addEventListener(GestureEvent.GESTURE_ENDED, onZoom);

            var pan = new PanGesture(sprite);
            pan.addEventListener(GestureEvent.GESTURE_BEGAN, onPan);
            pan.addEventListener(GestureEvent.GESTURE_CHANGED, onPan);
            pan.addEventListener(GestureEvent.GESTURE_ENDED, onPan);

            var swipe = new SwipeGesture(bg);
            swipe.direction = SwipeGestureDirection.HORIZONTAL;
            swipe.addEventListener(GestureEvent.GESTURE_RECOGNIZED, onSwipe);

            var rotate = new RotateGesture(stage);
            rotate.addEventListener(GestureEvent.GESTURE_CHANGED, onRotate);
            rotate.addEventListener(GestureEvent.GESTURE_ENDED, onRotate);
        }

        private function onDoubleTap(event:GestureEvent):void
        {
            trace("DOUBLE TAP!");
        }

        private function onLongPress(event:GestureEvent):void
        {
            trace("LONG PRESS! " + event.type);
        }

        private function onZoom(event:GestureEvent):void
        {
            var zoom = event.target as ZoomGesture;

            if (event.type == GestureEvent.GESTURE_CHANGED)
            {
                sprite.scaleX *= zoom.scaleX;
                sprite.scaleY *= zoom.scaleY;
            }
            else if (event.type == GestureEvent.GESTURE_ENDED)
            {
                sprite.scale = 1;
            }
        }

        private function onPan(event:GestureEvent):void
        {
            var pan = event.target as PanGesture;

            if (event.type == GestureEvent.GESTURE_CHANGED)
            {
                sprite.x += pan.offsetX;
                sprite.y += pan.offsetY;
            }
            else if (event.type == GestureEvent.GESTURE_ENDED)
            {
                sprite.x = 240;
                sprite.y = stage.stageHeight - 120;
            }
        }

        private function onSwipe(event:GestureEvent):void
        {
            var swipe = event.target as SwipeGesture;

            if (event.type == GestureEvent.GESTURE_RECOGNIZED)
            {
                if (swipe.offsetX > 0)
                {
                    trace("USER SWIPED RIGHT!");
                }
                else
                {
                    trace("USER SWIPED LEFT!");
                }
            }
        }

        private function onRotate(event:GestureEvent):void
        {
            var rotate = event.target as RotateGesture;

            if (event.type == GestureEvent.GESTURE_CHANGED)
            {
                sprite.rotation += rotate.rotation;
            }
            else if (event.type == GestureEvent.GESTURE_ENDED)
            {
                sprite.rotation = 0;
            }
        }
    }
}
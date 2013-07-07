package
{
    import loom.Application;
    import loom2d.display.Image;
    import loom2d.display.StageScaleMode;
    import loom2d.display.Quad;
    import loom2d.math.Point;
    import loom2d.textures.Texture;
    import loom2d.ui.SimpleLabel;

    import org.gestouch.gestures.TapGesture;
    import org.gestouch.events.GestureEvent;

    public class GestouchLoom2D extends Application
    {
        override public function run():void
        {
            super.run();

            // Comment out this line to turn off automatic scaling.
            stage.scaleMode = StageScaleMode.LETTERBOX;

            // Setup anything else, like UI, or game objects.
            // var bg = new Image(Texture.fromAsset("assets/bg.png"));
            // bg.pivotX = bg.width / 2;
            // bg.pivotY = bg.height / 2;
            // bg.x = 240;
            // bg.y = 160;
            // bg.scale = 0.5;
            // stage.addChild(bg);

            var bg = new Quad(stage.stageWidth, stage.stageHeight, 0xff0000);
            stage.addChild(bg);

            var sprite = new Image(Texture.fromAsset("assets/logo.png"));
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
        }

        private function onDoubleTap(event:GestureEvent):void
        {
            // handle double tap!
            trace("DOUBLE TAP!");
        }
    }
}
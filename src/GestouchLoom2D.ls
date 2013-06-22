package
{
    import loom.Application;
    import loom2d.display.Image;
    import loom2d.display.Loom2DGame;
    import loom2d.display.StageScaleMode;
    import loom2d.display.Quad;
    import loom2d.math.Point;
    import loom2d.text.BitmapFont;
    import loom2d.textures.Texture;
    import loom2d.ui.Label;

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

            var fontTexture = Texture.fromAsset("assets/Curse-hd.png");
            var fontAsset = File.loadTextFile("assets/Curse-hd.fnt");
            var font = new BitmapFont(fontTexture, fontAsset);
            var fontSprite = font.createSprite(480, 128, "Hello Loom!", -1, 0xffffff, "center", "center", false, true, null);          
            fontSprite.x = 240;
            fontSprite.y = stage.stageHeight - 240;
            fontSprite.pivotX = fontSprite.width / 2;
            fontSprite.pivotY = fontSprite.height / 2;
            stage.addChild(fontSprite);

            // var label = new Label("assets/Curse-hd.fnt", new Point(480, 128));
            // label.text = "Hello Loom!";
            // label.pivotX = label.width / 2;
            // label.pivotY = label.height / 2;
            // label.x = 240;
            // label.y = stage.stageHeight - 240;
            // stage.addChild(label);
        }
    }
}
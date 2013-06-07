// THIS IS THE ENTRY POINT TO YOUR APPLICATION
// YOU DON'T WANT TO MESS WITH ANYTHING HERE
// UNLESS YOU KNOW WHAT YOU'RE DOING
package
{
    import cocos2d.Cocos2DApplication;

    static class Main extends Cocos2DApplication
    {
        protected static var game:GestouchLoom2D = new GestouchLoom2D();

        public static function main()
        {
            initialize();
            onStart += game.run;
        }
    }
}
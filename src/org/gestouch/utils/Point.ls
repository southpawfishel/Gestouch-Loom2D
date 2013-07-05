package org.gestouch.utils 
{
    /**
     * A slightly less simple Point class.
     */
    public struct Point 
    {
        public var x:Number, y:Number;
 
        // CREATION / ASSIGNMENT
 
        public function Point(_x:Number = 0, _y:Number = 0)
        {
            x = _x;
            y = _y;
        }
 
        public function setTo(_x:Number, _y:Number):void
        {
            x = _x;
            y = _y;
        }
 
        public static operator function =(p1:Point, p2:Point):Point
        {
            p1.setTo(p2.x, p2.y);
            return p1;
        }
 
        public function copyFrom(p:Point):void
        {
            x = p.x;
            y = p.y;
        }
 
        public function clone():Point
        {
            return new Point(x, y);
        }
 
        // QUERIES
 
        public function toString():String
        {
            return "[Point " + x + ", " + y + "]";
        }
 
        public function get length():Number
        {
            return Math.sqrt(lengthSquared);
        }
 
        public function get lengthSquared():Number
        {
            return x*x + y*y;
        }
 
        public function equals(p:Point):Boolean
        {
            if (x != p.x)
                return false;
            if (y != p.y)
                return false;
            return true;
        }
 
        // OPERATIONS
 
        public function normalize(thickness:Number = 1):void
        {
            var oldLength = this.length;
            if (oldLength == 0) return;
            
            var thickNessOverLength = thickness / oldLength;
            x *= thickNessOverLength;
            y *= thickNessOverLength;
        }
 
        public function offset(dx:Number, dy:Number):void
        {
            x += dx;
            y += dy;
        }
 
        public function add(p:Point):Point
        {
            return new Point(x + p.x, y + p.y);
        }
 
        public static operator function +(p1:Point, p2:Point):Point
        {
            return p1.add(p2);
        }    
 
        public operator function +=(p:Point):void
        {
            x += p.x;
            y += p.y;
        }
 
        public function subtract(p:Point):Point
        {
            return new Point(x - p.x, y - p.y);
        }
 
        public static operator function -(p1:Point, p2:Point):Point
        {
            return p1.subtract(p2);
        }    
 
        public operator function -=(p:Point):void
        {
            x -= p.x;
            y -= p.y;
        }
    
        // STATIC HELPERS
 
        public static function distance(p1:Point, p2:Point):Number
        {
            return Math.sqrt(Point.distanceSquared(p1, p2));
        }
 
        public static function distanceSquared(p1:Point, p2:Point):Number
        {
            var dx = p2.x - p1.x;
            var dy = p2.y = p1.y;
            return dx*dx + dy*dy;
        }
 
        public static function interpolate(p1:Point, p2:Point, t:Number):Point
        {
            var newX = p2.x + ((1-t) * (p1.x - p2.x));
            var newY = p2.y + ((1-t) * (p1.y - p2.y));
            return new Point(newX, newY);
        }
 
        public static function polar(len:Number, angle:Number):Point
        {
            return new Point(len * Math.cos(angle), len * Math.sin(angle));
        }
    }
}
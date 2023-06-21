module canvas

import math

pub fn angle(x Number, y Number) Number {
	if x > 0 {
		if y > 0 {
			return math.atan2(y, x)
		} else if y == 0 {
			return 0
		} else if y < 0 {
			return math.atan2(y, x)
		}
	} else if x == 0 {
		if y > 0 {
			return math.pi/2
		} else if y == 0 {
			return 0
		} else if y < 0 {
			return 3*math.pi/2
		}
	} else {
		if y > 0 {
			return math.atan2(y, x)
		} else if y == 0 {
			return math.pi
		} else if y < 0 {
			return math.atan2(y, x)
		}
	}
	return 0
}
pub struct Point2{
	x Number
	y Number
	z Number
	t Number
	tag string
}

pub fn (this Point2) length_squared() Number{
	return this.x*this.x + this.y*this.y + this.z*this.z + this.t*this.t
}
pub fn (this Point2) length() Number{
	return math.sqrt(this.length_squared())
}
pub fn (this Point2) angle_xy() Number{
	return angle(this.x,this.y)
}
pub fn (this Point2) angle_xz() Number{
	return angle(this.x,this.z)
}
pub fn (this Point2) angle_xt() Number{
	return angle(this.x,this.z)
}

pub fn (this Point2) normalized() Point2{
	a:=this.angle_xy()
	return Point2{
		x: math.cos(a)
		y: math.sin(a)
		z: this.z
		t: this.t
		tag: this.tag
	}
}


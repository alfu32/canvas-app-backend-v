module canvas

import math


type Number =f64
type CanvasImageSource=string
type Point2D=[]f64
type PointPath=string
type Path2D=[]Point2D
type ImageDataSettings=map[string]string
type ImageData=string

struct SVGMatrix{
pub mut:
	a11 Number=1.0
	a12 Number=0.0
	a13 Number=0.0
	a21 Number=0.0
	a22 Number=1.0
	a23 Number=0.0
	a31 Number=0.0
	a32 Number=0.0
	a33 Number=1.0
}
pub fn create_matrix(a Number, b Number, c Number, d Number, e Number, f Number)SVGMatrix{

	return SVGMatrix{
		a11:a
		a12:b
		a13:c
		a21:d
		a22:e
		a23:f
		a31:0.0
		a32:0.0
		a33:1.0
	}
}
pub fn (mut m SVGMatrix) mul(n SVGMatrix) SVGMatrix{
	return SVGMatrix{
		a11:m.a11*n.a11+m.a12*n.a21+m.a13*n.a31
		a12:m.a11*n.a12+m.a12*n.a22+m.a13*n.a32
		a13:m.a11*n.a13+m.a12*n.a23+m.a13*n.a33
		a21:m.a21*n.a11+m.a22*n.a21+m.a23*n.a31
		a22:m.a21*n.a12+m.a22*n.a22+m.a23*n.a32
		a23:m.a21*n.a13+m.a22*n.a23+m.a23*n.a33
		a31:m.a31*n.a11+m.a32*n.a21+m.a33*n.a31
		a32:m.a31*n.a12+m.a32*n.a22+m.a33*n.a32
		a33:m.a31*n.a13+m.a32*n.a23+m.a33*n.a33
	}
}
pub fn (mut m SVGMatrix) translate(x Number,y Number) SVGMatrix{
	return SVGMatrix{
		a11:m.a11
		a12:m.a12
		a13:m.a13+x
		a21:m.a21
		a22:m.a22
		a23:m.a23+y
		a31:m.a31
		a32:m.a32
		a33:m.a33
	}
}
pub fn (mut m SVGMatrix) rotate(a Number) SVGMatrix{
	sa:=math.sin(a)
	ca:=math.cos(a)
	m0:=SVGMatrix{
		a11:ca
		a12:-sa
		a13:0.0
		a21:sa
		a22:ca
		a23:0.0
		a31:0.0
		a32:0.0
		a33:1.0
	}
	return m.mul(m0)
}
pub fn (mut m SVGMatrix) scale(x Number,y Number) SVGMatrix{
	m0:=SVGMatrix{
		a11:x
		a12:0.0
		a13:0.0
		a21:0.0
		a22:y
		a23:0.0
		a31:0.0
		a32:0.0
		a33:1.0
	}
	return m.mul(m0)
}
pub fn (mut m SVGMatrix) transform(a Number, b Number, c Number, d Number, e Number, f Number) SVGMatrix{
	mut m0:=create_matrix(a,b,c,d,e,f)
	return m.mul(m0)
}
pub fn (mut m SVGMatrix) to_svg_string() string {
	return  "${m.a11} ${m.a12} ${m.a13} ${m.a21} ${m.a22} ${m.a23}"
}

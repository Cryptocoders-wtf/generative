# Fully-On-Chain.sol

Fully-On-Chain.sol consists of a set of Solidity libraries, which help developers and artists 
to create fully on-chain generative art, dynamically generating images in SVG format,
typically responding to tokenURI() method of ERC721.

It consists of three libraries.

- SVG.sol - SVG generations
- Vector.sol - Vector operations
- Path.sol - Path generations

## Basic Concept

To generate an SVG image, you need to create a series of SVG elements,
combine them, and generate an SVG string.

SVG library has a set of method to create SVG elements, such as rect() and circle(). For exmaple, the following code creates a rectangle element with origin=(256, 256) and size=(512, 512) 
```
SVG.rect(256, 256, 512, 512);
```
To convert it into a string, you need to call its svg() method.
```
SVG.rect(256, 256, 512, 512).svg();
```
It will return the following string.
```
<rect x="256" y="256" width="512" height="512"/>
```
When you are ready to generate a full SVG document, you need to write this.
```
SVG.document(
  "0 0 1024 1024", // viewbox
  "",              // defs (empty)
  SVG.rect(256, 256, 512, 512).svg()
);
```
It will generate the following SVG string.
```
<svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <rect x="256" y="256" width="512" height="512"/>
</svg>
```
If you render it, the box will be displayed in black (which is the default color).

![](https://i.imgur.com/mwDv189.png)

You need to use the fill() method to specify the color.
```
SVG.rect(256, 256, 512, 512)
  .fill("yellow");
```

![](https://i.imgur.com/Y2Z0ZJF.png)

Please notice that fill() method returns another SVG element, which allows to apply multiple methods in chain.

```
SVG.rect(256, 256, 512, 512)
  .fill("yellow");
  .stroke("blue", 10)
  .transform("rotate(30 512 512)");
```

![](https://i.imgur.com/MLEUGD5.png)

You can create a group like this.
```
SVG.group([
  SVG.rect(256, 256, 640, 640).fill("yellow"),
  SVG.circle(320, 320, 280)
]).id("test");
```

![](https://i.imgur.com/TVfvcJY.png)

Because a group is also an SVG element, you can apply methods as well. The method id() assigns an id to the SVG element, and makes it possible to make a reference to it later.

```
SVG.group([
  SVG.use("test")
    .fill("green")                      
    .transform("scale(0.5)"),
  SVG.use("test")
    .fill("red")                      
    .transform("translate(512 0) scale(0.5)"),
  SVG.use("test")
    .fill("blue")                      
    .transform("translate(0 512) scale(0.5)"),
  SVG.use("test")
    .fill("grey")                      
    .transform("translate(512 512) scale(0.5)")
]);
```
![](https://i.imgur.com/vf6GWhw.png)

In order to create complex images, you need to use path() method, which takes a series of *control points* as a parameter. You need to use Vector and Path libraries to generate those control points.

```
uint count = 12;
int radius = 511;
Vector.Struct memory center = Vector.vector(512, 512);
uint[] memory points = new uint[](count * 2);    
for (uint i = 0; i < count * 2; i += 2) {
  int angle = Vector.PI2 * int(i) / int(count) / 2;
  Vector.Struct memory vector = Vector.vectorWithAngle(angle, radius);
  points[i] = Path.roundedCorner(vector.add(center));
  points[i+1] = Path.sharpCorner(vector.div(2).rotate(Vector.PI2 / int(count) / 2).add(center));
}
SVG.path(points.closedPath());
```
![](https://i.imgur.com/oGtTv8R.png)
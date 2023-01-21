# Fully-On-Chain.sol

Fully-On-Chain.sol consists of a set of Solidity libraries, which help developers and artists 
to create fully on-chain generative art, dynamically generating images in SVG format,
typically responding to tokenURI() method of ERC721.

It consists of six Solidity libraries.

- SVG.sol - SVG generations
- Vector.sol - Vector operations
- Path.sol - Path generations
- Transform.sol - Transform generations
- SVGFilter.sol - SVG filters
- Text.sol - Text generations

## Basic Concept

### SVG Elements

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
<?xml version="1.0" encoding="UTF-8"?>
<svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <rect x="256" y="256" width="512" height="512"/>
</svg>
```
If you render it, the box will be displayed in black, which is the default color.

![](https://i.imgur.com/mwDv189.png)

### Attributes

You need to use the fill() method to specify the color.
```
SVG.rect(256, 256, 512, 512)
  .fill("yellow");
```

![](https://i.imgur.com/Y2Z0ZJF.png)

Please notice that fill() method returns another SVG element, which allows you to apply multiple methods in chain.

```
SVG.rect(256, 256, 512, 512)
  .fill("yellow")
  .stroke("blue", 10)
  .transform("rotate(30 512 512)");
```

![](https://i.imgur.com/MLEUGD5.png)

### Groups

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

### Transform

The Transform library makes it easy to dynamically generate transform strings like "translate(512 512) scale(0.5)".

```
SVG.use("test")
    .fill("grey")                      
    .transform(TX.translate(512,512).scale1000(500));
```

### Path

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
  points[i+1] = Path.sharpCorner(vector.div(2)
                    .rotate(Vector.PI2 / int(count) / 2).add(center));
}
SVG.path(points.closedPath());
```
![](https://i.imgur.com/oGtTv8R.png)

### Vector Data Import

It is possible to import vector images from external tools such as Adobe Illustrator. You need to export them as SVG files, and copy the "d" attributes of path elements.

```
bytes constant bitcoin = "M2947.77 1754.38c40.72,-272.26 -166.56,-418.61 -450,-516.24l91.95 -368.8 -224.5 -55.94 -89.51 359.09c-59.02,-14.72 -119.63,-28.59 -179.87,-42.34l90.16 -361.46 -224.36 -55.94 -92 368.68c-48.84,-11.12 -96.81,-22.11 -143.35,-33.69l0.26 -1.16 -309.59 -77.31 -59.72 239.78c0,0 166.56,38.18 163.05,40.53 90.91,22.69 107.35,82.87 104.62,130.57l-104.74 420.15c6.26,1.59 14.38,3.89 23.34,7.49 -7.49,-1.86 -15.46,-3.89 -23.73,-5.87l-146.81 588.57c-11.11,27.62 -39.31,69.07 -102.87,53.33 2.25,3.26 -163.17,-40.72 -163.17,-40.72l-111.46 256.98 292.15 72.83c54.35,13.63 107.61,27.89 160.06,41.3l-92.9 373.03 224.24 55.94 92 -369.07c61.26,16.63 120.71,31.97 178.91,46.43l-91.69 367.33 224.51 55.94 92.89 -372.33c382.82,72.45 670.67,43.24 791.83,-303.02 97.63,-278.78 -4.86,-439.58 -206.26,-544.44 146.69,-33.83 257.18,-130.31 286.64,-329.61l-0.07 -0.05zm-512.93 719.26c-69.38,278.78 -538.76,128.08 -690.94,90.29l123.28 -494.2c152.17,37.99 640.17,113.17 567.67,403.91zm69.43 -723.3c-63.29,253.58 -453.96,124.75 -580.69,93.16l111.77 -448.21c126.73,31.59 534.85,90.55 468.94,355.05l-0.02 0z";
SVG.path(bitcoin).fill("#F7931A").transform("scale(0.25)");

```
The text representation is, however, quite large (1073 bytes above). You can use pathUtils.ts to compress it to the binary representation (287 bytes below).
```
bytes constant bitcoin = "\x4d\x70\xe1\xb7\x06\x63\x0a\x45\xbc\xd6\x44\x97\x90\x44\x7f\x6c\x50\x17\xa4\x44\xc8\xf2\x44\xea\x5a\x05\x63\xf1\x44\xfc\xe2\x44\xf9\xd3\x44\xf5\x6c\x50\x17\xa6\x44\xc8\xf2\x44\xe9\x5c\x05\x63\xf4\x44\xfd\xe8\x44\xfa\xdc\x44\xf8\x6c\x50\x00\x00\x45\xb3\xed\x44\xf1\x3c\x05\x63\x00\x55\x00\x2a\x55\x0a\x29\x55\x0a\x17\x55\x06\x1b\x55\x15\x1a\x55\x21\x6c\x40\xe6\x69\x05\x63\x02\x55\x00\x04\x55\x01\x06\x55\x02\xfe\x54\x00\xfc\x44\xff\xfa\x44\xff\x6c\x40\xdb\x93\x05\x63\xfd\x54\x07\xf6\x54\x11\xe6\x54\x0d\x01\x55\x01\xd7\x44\xf6\xd7\x44\xf6\x6c\x40\xe4\x40\x55\x49\x12\x05\x63\x0e\x55\x03\x1b\x55\x07\x28\x55\x0a\x6c\x40\xe9\x5d\x55\x38\x0e\x55\x17\xa4\x04\x63\x0f\x55\x04\x1e\x55\x08\x2d\x55\x0c\x6c\x40\xe9\x5c\x55\x38\x0e\x55\x17\xa3\x04\x63\x60\x55\x12\xa8\x55\x0b\xc6\x45\xb4\x18\x45\xba\xff\x44\x92\xcc\x44\x78\x25\x45\xf8\x40\x45\xdf\x48\x45\xae\x6c\x50\x00\x00\x05\x7a\x6d\x40\x80\xb4\x05\x63\xef\x54\x46\x79\x54\x20\x53\x54\x17\x6c\x50\x1f\x84\x04\x63\x26\x55\x09\xa0\x55\x1c\x8e\x55\x65\x7a\x00\x6d\x11\x45\x4b\x63\x40\xf0\x3f\x45\x8f\x1f\x45\x6f\x17\x05\x6c\x1c\x45\x90\x63\x50\x20\x08\x55\x86\x17\x55\x75\x59\x05\x6c\x00\x55\x00\x7a\x00";
SVG.path(Path.decode(bitcoin)).fill("#F7931A");
```
![](https://i.imgur.com/LvsJPMM.png)

### Font and Text Output

Text output is also possible as long as you have a font provider, which implements IFontProvider iterface. 

```
IFontProvider font = new LondrinaSolid();
SVG.group([
  SVG.text(font, "hello"),
  SVG.text(font, "nouns").transform('translate(0 1024)')
]).transform('scale(0.4)');
```
![](https://i.imgur.com/XNwvVfI.png)

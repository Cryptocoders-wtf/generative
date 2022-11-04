# Fully-On-Chain.sol

Fully-On-Chain.sol consists of a set of Solidity libraries, which help developers and artists 
to create fully on-chain generative art, dynamically generating images in SVG format,
typically responding to tokenURI() method of ERC721.

It consists of three libraries.

- SVG.sol - SVG generations
- Vector.sol - Vector operations
- Path.sol - Path generation for <path>

## Basic Concept

To generate an SVG image, you need to create a series of SVG elements,
combine them appropriately, convert them into a string and return as a SVG string.

SVG library has a set of method to create SVG elements, such as rect() and circle(). For exmaple, the following code create a rectangle element with origin=(0,0) and size=(100,100) 
```
SVG.rect(0,0,100,100);
```
To convert it into a string, you need to call its svg() method.
```
SVG.rect(0,0,100,100).svg();
```
It will return the following string.
```
<rect x="0" y="0" width="100" height="100"/>
```
If you render it (with proper SVG tag around it), the box will be displayed in black (which is the default coloir).

If you want to specify the color, you need to use the fill() method.
```
SVG.rect(0,0,100,100).fill("red");
```
This will generate the following string.
```
<rect x="0" y="0" width="100" height="100" fill="red"/>
```

import { Point, randomize, pathFromPoints, svgPartFromPath, svgFromBody, svgImageFromSvg } from "@/models/point";

const generatePoints = (
  count: number,
  thickness: number,
  dot: number
) => {
  const points: Point[] = [];
  const [cx, cy] = [512, 512];
  const r0 = 280;
  points.push({
    x: cx,
    y: cy,
    c: true,
    r: 0    
  });
  points.push({
    x: cx,
    y: cy + r0,
    c: true,
    r: 0    
  });
  const army = thickness;
  const armx = army * 1.73;
  for (let r = r0, f = 1; r > 0; r -= army, f = (f+1) % 2) {
    points.push({
      x: cx + armx * (f + 1),
      y: cy + r + army * (f + 1),
      c: false,
      r: 1    
    });
    points.push({
      x: cx + armx * (f + 1),
      y: cy + r - army + army * (f + 1),
      c: false,
      r: 1    
    });
  }
  points.push({
    x: cx + armx,
    y: cy + army,
    c: true,
    r: 0    
  });
  return points;
};

export const generateSVGImage = (color: string) => {
  const points = generatePoints(
    randomize(30, 0),
    randomize(30, 0.5),
    randomize(0.3, 0)
  );
  const path = pathFromPoints(points);
  const uses = Array(6).fill(0).map((v, index) => {
    return `<use href="#asset" fill="${color}" transform="rotate(${index * 60}, 512, 512)" />\n`
    + `<use href="#asset" fill="${color}" transform="rotate(${index * 60}, 512, 512) scale(-1, 1) translate(-1024, 0) " />\n`;

  }).join('');
  const svg = svgFromBody(svgPartFromPath(path, "asset") + uses);
  return svgImageFromSvg(svg);
};

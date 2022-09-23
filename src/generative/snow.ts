import { Point, randomize, pathFromPoints, svgPartFromPath, svgFromBody, svgImageFromSvg } from "@/models/point";

const generatePoints = (
  style: number,
  thickness: number,
  growth: number
) => {
  const points: Point[] = [];
  const [cx, cy] = [512, 512];
  const r0 = 511;
  let army = thickness;
  let armx = army * 1.73;
  const dir = (style > 2) ? -1 : 1;
  points.push({
    x: cx,
    y: cy,
    c: true,
    r: 0    
  });
  const r1 = r0 - army / 2 - dir * army / 2; 
  points.push({
    x: cx,
    y: cy + r1,
    c: true,
    r: 0    
  });
  for (let r = r1, f = 1; r > 0; r -= army, f = (f % 2) + 1) {
    points.push({
      x: cx + armx * f,
      y: cy + r + dir * army * f,
      c: false,
      r: 0.588    
    });
    points.push({
      x: cx + armx * f,
      y: cy + r - army + dir * army * f,
      c: false,
      r: 0.588    
    });
    armx *= 1 + growth;
    army *= 1 + growth;
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
    randomize(2, 0.5),
    randomize(40, 0.6),
    randomize(0.05, 1.0)
  );
  const path = pathFromPoints(points);
  const uses = Array(6).fill(0).map((v, index) => {
    return `<use href="#asset" fill="${color}" transform="rotate(${index * 60}, 512, 512)" />\n`
    + `<use href="#asset" fill="${color}" transform="rotate(${index * 60}, 512, 512) scale(-1, 1) translate(-1024, 0) " />\n`;

  }).join('');
  const svg = svgFromBody(svgPartFromPath(path, "asset") + uses);
  return svgImageFromSvg(svg);
};

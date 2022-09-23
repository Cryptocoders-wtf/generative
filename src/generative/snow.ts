import { Point, randomize, pathFromPoints, svgPartFromPath, svgFromBody, svgImageFromSvg } from "@/models/point";

const generatePoints = (
  count: number,
  length: number,
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
  const arm = 20;
  points.push({
    x: cx + arm,
    y: cy + r0 + arm,
    c: true,
    r: 0    
  });
  points.push({
    x: cx + arm,
    y: cy + arm,
    c: true,
    r: 0    
  });
  return points;
};

export const generateSVGImage = (color: string) => {
  const points = generatePoints(
    randomize(30, 0),
    randomize(0.2, 0),
    randomize(0.3, 0)
  );
  const path = pathFromPoints(points);
  const body = svgPartFromPath(path, "asset") + `<use href="#asset" fill="${color}" />`;
  const svg = svgFromBody(body);
  return svgImageFromSvg(svg);
};

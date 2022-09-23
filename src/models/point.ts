export interface Point {
  x: number;
  y: number;
  c: boolean; // true:line, false:bezier
  r: number; // ratio (0 to 1)
}

export interface Transform {
  tx: number;
  ty: number;
  scale: number;
  rotate: number;
}

export const identityTransform: Transform = {
  tx: 0,
  ty: 0,
  scale: 1,
  rotate: 0,
};

export const transformString = (xf: Transform) => {
  if (
    xf.tx == identityTransform.tx &&
    xf.ty == identityTransform.ty &&
    xf.scale == identityTransform.scale &&
    xf.rotate == identityTransform.rotate
  ) {
    return "";
  }
  const d = Math.round(512 * (xf.scale - 1));
  return (
    `translate(${xf.tx - d} ${xf.ty - d}) ` +
    `scale(${xf.scale}) rotate(${xf.rotate} 512 512)`
  );
};

export const transformStyle = (xf: Transform, ratio: number) => {
  return (
    `translate(${xf.tx * ratio}px,${xf.ty * ratio}px)` +
    ` scale(${xf.scale}) rotate(${xf.rotate}deg) `
  );
};

export const pathFromPoints = (points: Point[]) => {
  const length = points.length;
  return points.reduce((path, cursor, index) => {
    const prev = points[(index + length - 1) % length];
    const next = points[(index + 1) % length];
    const sx = (cursor.x + prev.x) / 2;
    const sy = (cursor.y + prev.y) / 2;
    const head = index == 0 ? `M${sx},${sy},` : "";
    const ex = (cursor.x + next.x) / 2;
    const ey = (cursor.y + next.y) / 2;
    const last = `${ex},${ey}`;
    if (cursor.c) {
      return path + head + `L${cursor.x},${cursor.y},` + last;
    }
    const c1x = sx + cursor.r * (cursor.x - sx);
    const c1y = sy + cursor.r * (cursor.y - sy);
    const c2x = ex + cursor.r * (cursor.x - ex);
    const c2y = ey + cursor.r * (cursor.y - ey);
    return path + head + `C${c1x},${c1y},${c2x},${c2y},` + last;
  }, "");
};

const svgHead =
  '<svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">\n';

export const svgPartFromPath = (path: string, tag: string) => {
  return `<defs><g id="${tag}"><path d="${path}" /></g></defs>`;
};
  
export const svgImageFromPath = (path: string, color: string) => {
  const svgTail = `<use href="#asset" fill="${color}" /></svg>`;
  const svg = svgHead + svgPartFromPath(path, "asset") + svgTail;
  return "data:image/svg+xml;base64," + Buffer.from(svg).toString("base64");
};

export const randomize = (value: number, ratio: number) => {
  return value + (Math.random() - 0.5) * value * ratio * 2;
};

export const sampleColors = [
  "#E26A6A",
  "#9C9C6A",
  "#6AE270",
  "#AEC7E3",
  "#6A7070",
  "#E2706A",
  "#A7B8EB",
  "#6A89E2",
  "#6B56EB",
  "#FF6961",
  "#77B6EA",
  "#6E6EFD",
  "#69D2FF",
  "#D6B900",
  "#EFCP00",
  "#9EB500",
  "#625103",
  "#8B280D",
];

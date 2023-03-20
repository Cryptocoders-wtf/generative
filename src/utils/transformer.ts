const scaleMatrix = (scaleX: number, scaleY: number) => {
  return [scaleX, 0, 0, scaleY, 0, 0];
};
const translateMatrix = (x: number, y: number) => {
  return [1, 0, 0, 1, x, y];
};
const rotateMatrix = (theta: number) => {
  return [
    Math.cos(theta),
    Math.sin(theta),
    -Math.sin(theta),
    Math.cos(theta),
    0,
    0,
  ];
};
const rotateMatrix2 = (theta: number, x: number, y: number) => {
  return [
    Math.cos(theta),
    Math.sin(theta),
    -Math.sin(theta),
    Math.cos(theta),
    x - x * Math.cos(theta) + y * Math.sin(theta),
    y - x * Math.sin(theta) - y * Math.cos(theta),
  ];
};

const skewX = (theta: number) => {
  return [1, 0, Math.tan(theta), 1, 0, 0];
};
const skewY = (theta: number) => {
  return [1, Math.tan(theta), 0, 1, 0, 0];
};

const matirixMatrix = (matrix: number[]) => {
  return matrix;
};

const parseTransform = (tags: string): number[][] => {
  const match = tags.match(/([a-zA-Z]+)\(([^)]+)\)/g);
  const dataSet = (match || [])
    .map((tag) => {
      const m = tag.match(/([a-zA-Z]+)\(([^)]+)\)/) || [];
      if (m.length === 3) {
        const name = m[1];
        const nums = (m[2] || "")
          .trim()
          .split(/[,\s]+/)
          .map(Number);
        if (name === "translate") {
          if (nums.length === 1) {
            return translateMatrix(nums[0], 0);
          }
          if (nums.length === 2) {
            return translateMatrix(nums[0], nums[1]);
          }
        }
        if (name === "scale") {
          if (nums.length === 1) {
            return scaleMatrix(nums[0], nums[0]);
          }
          if (nums.length === 2) {
            return scaleMatrix(nums[0], nums[1]);
          }
        }
        if (name === "rotate") {
          if (nums.length === 1) {
            return rotateMatrix(nums[0]);
          }
          if (nums.length === 3) {
            return rotateMatrix2(nums[0], nums[1], nums[2]);
          }
        }
        if (name === "skewX" && nums.length === 1) {
          return skewX(nums[0]);
        }
        if (name === "skewY" && nums.length === 1) {
          return skewY(nums[0]);
        }
        if (name === "matrix") {
          if (nums.length === 6) {
            return matirixMatrix(nums);
          }
        }
        console.log("skip: ", tag);
      }
      return [];
    })
    .filter((a) => a.length > 0);
  return dataSet;
};

export const transforms2matrix = (
  transforms: string[],
  max: number
): number[] => {
  const matrixes = transforms.map(parseTransform).flat();
  const ratio = max / 1024;
  const reverseRatio = 1024 / max;
  matrixes.unshift(scaleMatrix(reverseRatio, reverseRatio));
  matrixes.push(scaleMatrix(ratio, ratio));

  // matrix multiplication
  return matrixes.reduce((o, n) => {
    if (o.length === 0) {
      return n;
    }
    return [
      o[0] * n[0] + o[2] * n[1],
      o[1] * n[0] + o[3] * n[1],
      o[0] * n[2] + o[2] * n[3],
      o[1] * n[2] + o[3] * n[3],
      o[0] * n[4] + o[2] * n[5] + o[4],
      o[1] * n[4] + o[3] * n[5] + o[5],
    ];
  }, []);
};
export const roundMatrix = (matrix: number[]) => {
  return [
    Math.round(matrix[0] * 100) / 100,
    Math.round(matrix[1] * 100) / 100,
    Math.round(matrix[2] * 100) / 100,
    Math.round(matrix[3] * 100) / 100,
    Math.round(matrix[4]),
    Math.round(matrix[5]),
  ];
};

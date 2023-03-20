const scaleMatrix = (scale: number) => {
  return [Number(scale), 0, 0, Number(scale), 0, 0];
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
const matirixMatrix = (matrix: number[]) => {
  return [
    Number(matrix[0]),
    Number(matrix[1]),
    Number(matrix[2]),
    Number(matrix[3]),
    Number(matrix[4]),
    Number(matrix[5]),
  ];
};

const parseTransform = (tags: string): number[][] => {
  const match = tags.match(/[a-zA-Z]+\([^)]+\)/g);

  const dataSet = (match || [])
    .map((tag) => {
      const ret = {};
      const translate = tag.match(/translate\(([\d-.e]+)[,\s]([\d-.e]+)\)/);
      if (translate && translate.length === 3) {
        return translateMatrix(Number(translate[1]), Number(translate[2]));
      }

      const scale = tag.match(/scale\(([\d-.e]+)\)/);
      if (scale && scale.length === 2) {
        return scaleMatrix(Number(scale[1]));
      }

      const rotate = tag.match(/rotate\(([\d-.e]+)\)/);
      if (rotate && rotate.length === 2) {
        const theta = Number(rotate[1]);
        return rotateMatrix(theta);
      }

      const matrix = tag.match(
        /matrix\(\s*([\d-.e]+)[,\s]+([\d-.e]+)[,\s]+([\d-.e]+)[,\s]+([\d-.e]+)[,\s]+([\d-.e]+)[,\s]+([\d-.e]+)\s*\)/
      );
      if (matrix && matrix.length === 7) {
        return matirixMatrix(matrix.slice(1, 7).map(Number));
      }
      if (Object.keys(ret).length === 0) {
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
  matrixes.unshift(scaleMatrix(reverseRatio));
  matrixes.push(scaleMatrix(ratio));

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

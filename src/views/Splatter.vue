<template>
  <div class="mx-auto max-w-3xl p-2 text-left">
    <p class="mb-2">{{ $t("message.touchToUpdate") }}</p>
    <div @click="updateImage">
      <img
        v-for="image in images"
        :key="image"
        :src="image"
        class="mr-1 mb-1 inline-block w-32"
      />
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";
import { Point, pathFromPoints, svgImageFromPath } from "@/models/point";

export default defineComponent({
  setup() {
    const images = ref<string[]>([]);
    const randomize = (value: number, ratio: number) => {
      return value + (Math.random() - 0.5) * value * ratio * 2;
    };
    const generatePoints = (
      count: number,
      length: number,
      dot: number
    ) => {
      const points: Point[] = [];
      const [cx, cy] = [512, 512];
      const r0 = 280, speed = Math.PI / count;
      for (
        var i = speed, alt = 0, r1 = r0;
        i < Math.PI * 2;
        i += randomize(speed, 0.9),
          alt = (alt + 1) % 3,
          r1 = (randomize(r1, 0.2) * 2 + r0) / 3
      ) {
        if (alt == 0) {
          const r = r1 * (1 + randomize(length, 1));
          const arc = randomize(dot, 0.5);
          points.push({
            x: cx + r1 * Math.cos(i - (speed * arc) / 2),
            y: cy + r1 * Math.sin(i - (speed * arc) / 2),
            c: false,
            r: 0.588,
          });
          points.push({
            x: cx + r * Math.cos(i - (speed * arc) / 2),
            y: cy + r * Math.sin(i - (speed * arc) / 2),
            c: false,
            r: 0.588,
          });
          points.push({
            x: cx + r * (1 + arc / 2) * Math.cos(i - speed * arc),
            y: cy + r * (1 + arc / 2) * Math.sin(i - speed * arc),
            c: false,
            r: 0.588,
          });
          points.push({
            x: cx + r * (1 + arc / 2) * Math.cos(i + speed * arc),
            y: cy + r * (1 + arc / 2) * Math.sin(i + speed * arc),
            c: false,
            r: 0.588,
          });
          points.push({
            x: cx + r * Math.cos(i + (speed * arc) / 2),
            y: cy + r * Math.sin(i + (speed * arc) / 2),
            c: false,
            r: 0.588,
          });
          points.push({
            x: cx + r1 * Math.cos(i + (speed * arc) / 2),
            y: cy + r1 * Math.sin(i + (speed * arc) / 2),
            c: false,
            r: 0.588,
          });
        } else {
          points.push({
            x: cx + r1 * Math.cos(i),
            y: cy + r1 * Math.sin(i),
            c: false,
            r: 0.588,
          });
        }
      }
      return points;
    };
    const updateImage = () => {
      const color = [
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
      images.value = color.map((color) => {
        const points = generatePoints(
          randomize(30, 0.5),
          randomize(0.2, 0.5),
          randomize(0.3, 0.5)
        );
        const path = pathFromPoints(points);
        return svgImageFromPath(path, color);
      });
    };
    updateImage();
    return {
      images,
      updateImage,
    };
  },
});
</script>

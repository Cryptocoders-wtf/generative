<template>
  <div class="mx-auto max-w-4xl p-2 text-left">
    <div>
      <img v-for="image in images" :key="image" 
        :src="image" @click="updateImage"
        class="mr-1 mb-1 inline-block w-32 rounded-xl" />
    </div>
  </div> 
</template>

<script lang="ts">
import { defineComponent, ref, computed } from "vue";
import { Point, pathFromPoints, svgImageFromPath } from "@/models/point";
// https://github.com/Sikorkaio/sikorka/blob/master/contracts/trigonometry.sol

export default defineComponent({
  setup() {
    const image = ref<string>("");
    const images = ref<string[]>([]);
    const randomize = (value:number, ratio:number) => {
      return value + (Math.random() - 0.5) * value * ratio * 2;
    };
    const generate = (color:string, count:number, length:number, dot:number) => {
      const points:Point[] = [];
      const [cx, cy] = [512, 512];
      var r0 = 280;   
      var speed = Math.PI / count;
      for (var i = speed, alt = 0, jump = 1, r1 = r0; i < Math.PI * 2; i += randomize(speed, 0.9), alt = (alt + 1) % 3, r1 = (randomize(r1, 0.2) * 2 + r0) / 3) {
        if (alt == 0) {
          const r = r1 * (1 + randomize(length, 1));
          const arc = randomize(dot, 0.5);
          points.push({
            x: cx + r1 * Math.cos(i - speed * arc/2),
            y: cy + r1 * Math.sin(i - speed * arc/2),
            c: false,
            r: 0.588
          });
          points.push({
            x: cx + r * Math.cos(i - speed * arc/2),
            y: cy + r * Math.sin(i - speed * arc/2),
            c: false,
            r: 0.588
          });
          points.push({
            x: cx + r * (1 + arc/2) * Math.cos(i - speed * arc),
            y: cy + r * (1 + arc/2) * Math.sin(i - speed * arc),
            c: false,
            r: 0.588
          });
          points.push({
            x: cx + r * (1 + arc/2) * Math.cos(i + speed * arc),
            y: cy + r * (1 + arc/2) * Math.sin(i + speed * arc),
            c: false,
            r: 0.588
          });
          points.push({
            x: cx + r * Math.cos(i + speed * arc/2),
            y: cy + r * Math.sin(i + speed * arc/2),
            c: false,
            r: 0.588
          });
          points.push({
            x: cx + r1 * Math.cos(i + speed * arc/2),
            y: cy + r1 * Math.sin(i + speed * arc/2),
            c: false,
            r: 0.588
          });
        } else {
          points.push({
            x: cx + r1 * Math.cos(i),
            y: cy + r1 * Math.sin(i),
            c: false,
            r: 0.588
          })
        }
      }
      const path = pathFromPoints(points);
      return svgImageFromPath(path, color);
    };
    const updateImage = () => {
      image.value = generate("green", randomize(30,0.5), randomize(0.2, 0.5), randomize(0.3, 0.5));
      const color = ["#E26A6A", "#9C9C6A", "#6AE270", "#AEC7E3", "#6A7070",
      "#EB6B56", "#E2706A", "#A7B8EB", "#6A89E2", "#6B56EB",
      "#FF6961", "#77B6EA", "#6E6EFD", "#69C9FF", "#69D2FF",
      "#D6B900", "#EFCP00", "#8DB600", "#88BB00", "#9EB500",
      "#650005", "#625103", "#8B280D", "#A1350B", "#A1350B",
      "#2B0202", "#2B0202", "#2B0202", "#2B0202", "#2B0202",
      "#9B9200", "#8B8B00", "#B2B200", "#B2B200", "#B2B200"];
      images.value = color.map(color => {
        return generate(color, randomize(30,0.5), randomize(0.2, 0.5), randomize(0.3, 0.5));
      });
    };
    updateImage();
    return {
      image,
      images,
      updateImage
    };
  },
});
</script>
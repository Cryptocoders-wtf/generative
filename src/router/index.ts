import { createRouter, createWebHistory, RouteRecordRaw } from "vue-router";
import Layout from "@/components/Layout.vue";
import Blank from "@/components/Blank.vue";
import NotFound from "@/components/NotFound.vue";

import Home from "@/views/Home.vue";
import Splatter from "@/views/Splatter.vue";
import Snow from "@/views/Snow.vue";
import Nouns from "@/views/Nouns.vue";
import Paper from "@/views/Paper.vue";
import Bitcoin from "@/views/Bitcoin.vue";
import Reddit from "@/views/Reddit.vue";
import Sample from "@/views/Sample.vue";
import Experiment from "@/views/Experiment.vue";
import Star from "@/views/Star.vue";
import Alphabet from "@/views/Alphabet.vue";

import Svg from "@/views/SVG.vue";
import SvgTest from "@/views/SVGTest.vue";
import Message from "@/views/Message.vue";
import MessagePNouns from "@/views/MessagePNouns.vue";

import P2SeaItem from "@/views/P2SeaItem.vue";

const routeChildren: Array<RouteRecordRaw> = [
  {
    path: "",
    component: Svg,
  },
  {
    path: "splatter",
    component: Splatter,
  },
  {
    path: "snow",
    component: Snow,
  },
  {
    path: "nouns",
    component: Nouns,
  },
  {
    path: "paper",
    component: Paper,
  },
  {
    path: "bitcoin",
    component: Bitcoin,
  },
  {
    path: "reddit",
    component: Reddit,
  },
  {
    path: "exp",
    component: Experiment,
  },
  {
    path: "star",
    component: Star,
  },
  {
    path: "svg",
    component: Svg,
  },
  {
    path: "svgtest",
    component: SvgTest,
  },
  {
    path: "message",
    component: Message,
  },
  {
    path: "message_pnouns",
    component: MessagePNouns,
  },
  {
    path: "alphabet",
    component: Alphabet,
  },
  {
    path: "sample",
    component: Sample,
  },
  {
    path: "p2sea_item/:token_id",
    component: P2SeaItem,
  }
];

const routes: Array<RouteRecordRaw> = [
  {
    path: "/",
    component: Layout,
    children: [
      {
        path: "/:lang(en|ja)",
        component: Blank,
        children: routeChildren,
      },
      {
        path: "",
        component: Blank,
        children: routeChildren,
      },
    ],
  },
  {
    path: "/:page(.*)",
    name: "NotFoundPage",
    component: Layout,
    children: [
      {
        path: "",
        component: NotFound,
      },
    ],
  },
];

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes,
});

export default router;
